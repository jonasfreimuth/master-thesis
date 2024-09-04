import::here("data.table", "fread")
import::here("knitr", "combine_words")
import::here("magrittr", .all = TRUE)
import::here("purrr", "iwalk", "map", "pmap", "walk")
import::here("rlang", "list2")
import::here("rmarkdown", "yaml_front_matter")
import::here("stringr", "str_replace", "str_detect")
import::here("yaml", "read_yaml")

update_analysis_dir <- function(dir_name = c("main_plots", "param_tables"),
                                new_path,
                                analysis_root = "cancer-cleaning-output") {
  # Currently, I link in analysis dirs from the repository where they were
  # created. The analysis dirs are either "main_plots" or "param_tables",
  # and in this project they live under "analysis_root". The path to which
  # the dir should be updated is "new_path".
  dir_path <- paste(analysis_root, dir_name, sep = "/")
  unlink(dir_path)

  system2("ln", c("-s", new_path, dir_path))
}

update_dirs_from_rds <- function(rds_path = "./dir_list.RDS", ...) {
  iwalk(
    readRDS(rds_path),
    \(path, name) update_analysis_dir(dir_name = name, new_path = path, ...)
  )
}

update_dirs_from_table <- function(table_path = "./latest_summary_dirs.csv",
                                   ...) {
  # The script for running all summary scripts in the analysis repo outputs
  # a table.
  read.csv(table_path) %>%
    pmap(..., list2) %>%
    walk(\(row) {
      update_analysis_dir(dir_name = row$name, new_path = row$path, ...)
    })
}

param_file_path_to_name <- function(param_file_path) {
  param_file_path %>%
    basename() %>%
    str_replace("\\.[a-zA-Z0-9]+$", "")
}

load_param_objs <- function(analysis_dir, pattern, load_fun) {
  files <- dir(analysis_dir, full.names = TRUE, pattern = pattern) %>%
    set_names(param_file_path_to_name(.))

  map(
    files,
    load_fun
  )
}

load_yaml_objs <- function(analysis_dir) {
  load_param_objs(analysis_dir, pattern = ".yaml$", load_fun = read_yaml)
}

load_table_objs <- function(analysis_dir) {
  load_param_objs(analysis_dir, pattern = ".csv$", load_fun = fread)
}

load_param_table_dir <- function(param_table_dir) {
  analysis_dirs <- dir(param_table_dir, full.names = TRUE) %>%
    # Analysis dirs are all dirs in the param table dir excluding the
    # reproducibility dir.
    extract(!str_detect(., "reproducibility")) %>%
    set_names(basename(.))

  table_dirs <- analysis_dirs %>%
    map(\(dir) paste0(dir, "/tables"))

  yaml_dirs <- analysis_dirs %>%
    map(\(dir) paste0(dir, "/yaml"))

  list(
    table_objs = map(table_dirs, load_table_objs),
    yaml_objs = map(yaml_dirs, load_yaml_objs)
  )
}

formatted_yaml_value <- function(param_obj, value_name) {
  yaml_value <- param_obj %>%
    extract2(value_name)

  value_formatted <- if (is.character(yaml_value)) {
    yaml_value %>%
      str_replace("_", " ")
  } else if (is.numeric(yaml_value)) {
    yaml_value %>%
      round(3) %>%
      format(big.mark = "'")
  } else {
    yaml_value
  }

  combine_words(value_formatted)
}

render_book <- function(book_root = "./bookdown",
                        format = "html",
                        adaptive_html_theme = FALSE) {
  # Render the book at `book_root` to `format`, either "html" or "pdf".
  # Existing debug files preventing the rendering will be cleared beforehand.
  # If `adaptive_html_theme` and its dark out (i.e., between 20 and 8 o'clock),
  # a dark theme will be used for html output.
  # FIXME Figure out how to do this for pdf output.
  html_dark_theme <- "darkly"

  # Merged debug file bookdown leaves after errors. I don't want to manually
  # delete it every time, it hasn't been helpulf so far.
  debug_files <- c(
    paste0(book_root, "/_main.Rmd"),
    paste0(book_root, "/_main.md")
  )

  walk(
    debug_files,
    \(debug_file) if (file.exists(debug_file)) unlink(debug_file)
  )

  # Get the settings key which needs to match what's in book_root/index.Rmd.
  # As per markdown custom, it doubles as a callable function, the result of
  # which goes into the `output_format` arg of the `render_book` call.
  settings_key <- switch(format,
    "html" = "bookdown::html_document2",
    "pdf" = "bookdown::pdf_document2",
    stop(paste("Can't render to unknown format", format))
  )

  output_settings <- yaml_front_matter(paste0(book_root, "/index.Rmd")) %>%
    extract2("output") %>%
    extract2(settings_key)

  # Split off potential package specifiers by splitting on the namespace
  # delimiter and using the last element of whatever comes out.
  fun_components <- strsplit(settings_key, "::") %>%
    unlist()

  fun <- if (length(fun_components) == 2) {
    # We're assuming we have the format package::fun_name.
    getFromNamespace(fun_components[[2]], ns = fun_components[[1]])
  } else if (length(fun_components) == 1) {
    # We're assuming we have format fun_name, and further assume that fun comes
    # from bookdown.
    getFromNamespace(fun_components[[1]], ns = "bookdown")
  } else {
    stop(paste(
      "Somehow an erroneous settings_key was specified:", settings_key
    ))
  }

  if (adaptive_html_theme && format == "html") {
    current_hour <- Sys.time() %>%
      format("%H") %>%
      as.integer()

    if (current_hour >= 20 || current_hour <= 8) {
      output_settings$theme <- html_dark_theme
    }
  }

  # Define the output format by calling our format function
  output_format <- do.call(fun, output_settings)

  message(
    bookdown::render_book(
      book_root,
      output_format = output_format
    )
  )
}

copy_output <- function(from, to) {
  # Simple, non-fussy wrapper around file.copy.
  invisible(file.copy(from, to, overwrite = TRUE))
}

main_plot_handles_from_path <- function(plot_path, plot_prefixes) {
  # Get a list of all the handles available for main plots.
  list(
    plot_paths = map(
      plot_prefixes,
      \(prefix) paste(plot_path, paste0(prefix, ".png"), sep = "/")
    ),
    plot_caps = map(
      plot_prefixes,
      \(prefix) {
        paste(plot_path, paste0(prefix, "_plot_caption.txt"), sep = "/")
      }
    ) %>%
      map(readLines),
    plot_data_paths = map(
      plot_prefixes,
      \(prefix) paste(plot_path, paste0(prefix, ".csv"), sep = "/")
    ),
    table_caps = map(
      plot_prefixes,
      \(prefix) {
        paste(plot_path, paste0(prefix, "_table_caption.txt"), sep = "/")
      }
    ) %>%
      map(readLines)
  )
}

supp_plot_handles_from_path <- function(plot_path, plot_prefixes) {
  # Get a list of all the handles available for supplementary plots.
  list(
    plot_paths = map(
      plot_prefixes,
      \(prefix) paste(plot_path, paste0(prefix, ".png"), sep = "/")
    ),
    plot_caps = map(
      plot_prefixes,
      \(prefix) {
        paste(plot_path, paste0(prefix, "_caption.txt"), sep = "/")
      }
    ) %>%
      map(readLines)
  )
}

style_bib_entries <- function(bib_file = "citations//cancer-cleaning_File.bib",
                              style_script = "citations//sort_bib_file.sh") {
  # Run the styling script for bib files on my bib file.
  system2(style_script, bib_file)
}

archive_run_summary_dirs <- function(analysis_root) {
  exclude_pattern <- "reproducibility"
  output_file <- paste0(
    format(Sys.time(), "%Y%m%d"),
    "_run_output_summaries.tar.gz"
  )

  summary_dirs <- dir(analysis_root, full.names = TRUE) %>%
    map(
      \(summary_dir) {
        dir(summary_dir) %>%
          extract(!str_detect(., exclude_pattern)) %>%
          {
            paste0(summary_dir, "/", .)
          }
      }
    ) %>%
    unlist()

  system2("tar", c("-czf", output_file, summary_dirs))
}

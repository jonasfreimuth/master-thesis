import::here("data.table", "fread")
import::here("knitr", "combine_words")
import::here("magrittr", .all = TRUE)
import::here("purrr", "iwalk", "map", "walk")
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

render_book <- function(book_root = "./bookdown", format = "html") {
  # Render the book at `book_root` to `format`, either "html" or "pdf".
  # Existing debug files preventing the rendering will be cleared beforehand.

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

  switch(
    format,
    "html" = message(
      bookdown::render_book(
       book_root,
        output_format = "bookdown::html_document2"
      )
    ),
    "pdf" = message(
      bookdown::render_book(
        book_root,
        output_format = "bookdown::pdf_document2"
      )
    ),
    stop(paste("Can't render to unknown format", format))
  )
}

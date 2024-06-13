
suppressPackageStartupMessages({
  library("yaml")
  library("dplyr")
})

embed_cap_plot <- function(plot_file, caption = NULL) {
  if (is.null(caption)) {
    cap_filename <- paste0(
        stringr::str_replace(plot_file, "\\.[^.]+$", ""),
        "_caption.txt"
      )
    caption <- readLines(con = cap_filename)
  }

  paste0(
    "![](", plot_file, ")\n*", caption, "*"
  )
}

embed_list_table <- function(list) {
  header <- paste(
    "| Name | Value |",
    "|-----:|:------|",
    sep = "\n"
  )

  x <- unlist(list)

  body <- paste(
    "|", names(x), "|", x, "|",
    collapse = "\n"
  )

  paste(
    header, "\n", body, collapse = "\n"
  )
}

embed_perf_table <- function(table_file) {
  data.table::fread(table_file) %>%
    select(-matches("*_name")) %>%
    select(feature_set, everything()) %>%
    mutate(across(where(is.numeric), function(x) round(x, 3))) %>%
    DT::datatable()
}
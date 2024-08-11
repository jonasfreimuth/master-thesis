import::from("here", "here")
import::from("purrr", "walk")

suppressMessages(here::i_am("render_book.R"))

# Merged debug file bookdown leaves after errors. I don't want to manually
# delete it every time, it hasn't been helpulf so far.
debug_files <- c(
  here("bookdown/_main.Rmd"),
  here("bookdown/_main.md")
)

walk(
  debug_files,
  \(debug_file) if (file.exists(debug_file)) unlink(debug_file)
)

output_type <- "html"

switch(
  output_type,
  "html" = message(
    bookdown::render_book(
      here("bookdown"),
      output_format = "bookdown::html_document2"
    )
  ),
  "pdf" = message(
    bookdown::render_book(
      here("bookdown"),
      output_format = "bookdown::pdf_document2"
    )
  )
)
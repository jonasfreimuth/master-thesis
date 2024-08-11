import::from("here", "here")
import::from("purrr", "walk")

suppressMessages(here::i_am("render_book.R"))

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

render_book(here("bookdown"), format = "html")

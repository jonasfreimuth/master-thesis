import::from("here", "here")

suppressMessages(here::i_am("render_book.R"))

# Merged debug file bookdown leaves after errors. I don't want to manually
# delete it every time, it hasn't been helpulf so far.
debug_file <- here("bookdown/_main.Rmd")

if (file.exists(debug_file)) unlink(debug_file)

message(
  bookdown::render_book(
    here("bookdown"),
    output_format = bookdown::html_document2(
      toc = TRUE
    )
  )
)
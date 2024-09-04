import::from("here", "here")
import::from("purrr", "walk")

suppressMessages(here::i_am("render_book.R"))

import::from(
  "utils.R",
  "copy_output",
  "render_book",
  .character_only = TRUE,
  .directory = here("modules")
)

filename <- "jonas_freimuth_master_thesis"

html_outfile <- here("bookdown/_main.html")
pdf_outfile <- here("bookdown/_book/_main.pdf")

render_book(here("bookdown"), format = "html")
copy_output(html_outfile, here(paste0(filename, ".html")))

render_book(here("bookdown"), format = "pdf")
copy_output(pdf_outfile, here(paste0(filename, ".pdf")))

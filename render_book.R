import::from("here", "here")
import::from("purrr", "walk")

suppressMessages(here::i_am("render_book.R"))

import::from(
  "utils.R",
  "render_book",
  .character_only = TRUE,
  .directory = here("modules")
)

render_book(here("bookdown"), format = "html")

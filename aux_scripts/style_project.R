import::from("here", "here")
import::from("magrittr", .all = TRUE)
import::from("purrr", "map")
import::from("styler", "style_file")

suppressMessages(here::i_am("aux_scripts/style_project.R"))

dirs <- c("aux_scripts", "bookdown", "modules") %>%
  map(here)

dirs %>%
  map(\(src_dir) dir(src_dir, full.names = TRUE, pattern = "*.R(md)?$")) %>%
  unlist() %>%
  style_file()

import::from("magrittr", .all = TRUE)
import::from("purrr", "map")
import::from("styler", "style_file")

dirs <- c("aux_scripts", "bookdown")

dirs %>%
  map(\(src_dir) dir(src_dir, full.names = TRUE, pattern = "*.R(md)?$")) %>%
  unlist() %>%
  style_file()

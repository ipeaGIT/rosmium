extract <- function(input_path,
                    borders,
                    output_path,
                    overwrite = FALSE,
                    echo = TRUE,
                    echo_cmd = FALSE,
                    spinner = TRUE) {
  checkmate::assert_file_exists(input_path)
  checkmate::assert_multi_class(borders, c("sf", "bbox"))
  checkmate::assert_logical(overwrite, any.missing = FALSE, len = 1)
  checkmate::assert_logical(echo, any.missing = FALSE, len = 1)
  checkmate::assert_logical(echo_cmd, any.missing = FALSE, len = 1)
  checkmate::assert_logical(spinner, any.missing = FALSE, len = 1)
  checkmate::assert_string(output_path)

  border_arg <- create_border_input(borders)
  output_arg <- paste0("--output=", output_path)
  overwrite_arg <- if (overwrite) "--overwrite" else character()

  args <- c(
    "extract",
    input_path,
    border_arg,
    output_arg,
    "--strategy=complete_ways",
    overwrite_arg
  )

  logs <- processx::run(
    "osmium",
    args,
    echo = echo,
    spinner = spinner,
    echo_cmd = echo_cmd
  )

  return(logs)
}

create_border_input <- function(x) {
  if (inherits(x, "bbox")) {
    border_input_from_bbox(x)
  } else {
    border_input_from_polygon(x)
  }
}

border_input_from_bbox <- function(x) {
  bottom_left_edge <- paste(x$xmin, x$ymin, sep = ",")
  top_right_edge <- paste(x$xmax, x$ymax, sep = ",")

  input <- paste0("--bbox=", bottom_left_edge, ",", top_right_edge)

  return(input)
}

border_input_from_polygon <- function(x) {
  if (nrow(x) > 1) x <- sf::st_union(x)

  # simplify needs to be FALSE, otherwise objects with only one feature (which
  # is always our case) are represented as a geojson vector, even though we need
  # it to be either a feature or a feature collection

  geojson_content <- geojsonsf::sf_geojson(x, simplify = FALSE)

  tmp_geojson <- tempfile("polygon", fileext = ".geojson")
  writeLines(geojson_content, tmp_geojson)

  input <- paste0("--polygon=", tmp_geojson)

  return(input)
}

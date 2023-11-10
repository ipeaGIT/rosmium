extract <- function(input_path,
                    borders,
                    output_path,
                    overwrite = FALSE,
                    echo = TRUE,
                    echo_cmd = FALSE,
                    spinner = TRUE) {
  checkmate::assert_file_exists(input_path)
  checkmate::assert_logical(overwrite, any.missing = FALSE, len = 1)
  checkmate::assert_logical(echo, any.missing = FALSE, len = 1)
  checkmate::assert_logical(echo_cmd, any.missing = FALSE, len = 1)
  checkmate::assert_logical(spinner, any.missing = FALSE, len = 1)
  assert_borders(borders)
  assert_output_path_multi_ext(output_path, overwrite)

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

  return(normalizePath(output_path))
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
  # simplify needs to be FALSE, otherwise objects with only one feature (which
  # is always our case) are represented as a geojson vector, even though we need
  # it to be either a feature or a feature collection

  geojson_content <- geojsonsf::sf_geojson(x, simplify = FALSE)

  tmp_geojson <- tempfile("polygon", fileext = ".geojson")
  writeLines(geojson_content, tmp_geojson)

  input <- paste0("--polygon=", tmp_geojson)

  return(input)
}

check_borders <- function(borders) {
  multi_class_res <- checkmate::check_multi_class(borders, c("sf", "bbox"))
  if (!isTRUE(multi_class_res)) return(multi_class_res)

  if (inherits(borders, "bbox")) {
    is_numeric_len_4 <- checkmate::test_numeric(
      borders,
      finite = TRUE,
      any.missing = FALSE,
      len = 4
    )

    is_correctly_named <- checkmate::test_subset(
      names(borders),
      choices = c("xmin", "ymin", "xmax", "ymax")
    )

    if (!(is_numeric_len_4 && is_correctly_named)) {
      return(
        paste0(
          "Bounding box must contain 4 elements named 'xmin', 'ymin', 'xmax' ",
          "and 'ymax'"
        )
      )
    }
  } else {
    if (nrow(borders) > 1) {
      return(
        paste0(
          "sf object must contain only one feature. Hint: try using ",
          "sf::st_union() to union multiple features into a single one"
        )
      )
    }

    geometry_type <- as.character(sf::st_geometry_type(borders))
    if (! geometry_type %in% c("POLYGON", "MULTIPOLYGON")) {
      msg <- paste0(
        "Geometry type of sf object must be either POLYGON or MULTIPOLYGON. ",
        "Found ", geometry_type, " instead"
      )

      if (geometry_type == "GEOMETRYCOLLECTION") {
        msg <- paste0(
          msg,
          ". Hint: try using sf::st_collection_extract(type = \"POLYGON\") to ",
          "extract the polygons/multipolygons from the collection"
        )
      }

      return(msg)
    }
  }

  return(TRUE)
}

assert_borders <- checkmate::makeAssertionFunction(check_borders)

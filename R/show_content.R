#' Show the contents of an OSM file
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' pbf_path <- system.file("extdata/cur.osm.pbf", package = "rosmium")
#'
#' small_pbf <- tags_filter(pbf_path, "n/note", tempfile(fileext = "osm.pbf"))
#'
#' rosmium:::show_content(small_pbf)
#'
#' @keywords internal
show_content <- function(
  input_path,
  output_format = c("debug", "opl", "xml"),
  object_type = c("all", "node", "way", "relation", "changeset"),
  echo_cmd = FALSE,
  spinner = TRUE,
  preview = TRUE
) {
  assert_osmium_is_installed()

  checkmate::assert_file_exists(input_path)
  checkmate::assert_logical(echo_cmd, any.missing = FALSE, len = 1)
  checkmate::assert_logical(spinner, any.missing = FALSE, len = 1)
  checkmate::assert_logical(preview, any.missing = FALSE, len = 1)

  output_format_arg <- assert_and_assign_output_fmt(output_format)

  args <- c(
    "show",
    input_path,
    output_format_arg
  )

  logs <- processx::run(
    "osmium",
    args,
    spinner = spinner,
    echo_cmd = echo_cmd,
    echo = FALSE
  )

  tmpfile <- write_content_to_file(logs$stdout, output_format)
  if (preview && interactive()) utils::browseURL(tmpfile)

  return(normalizePath(tmpfile))
}

assert_and_assign_output_fmt <- function(output_format) {
  possible_choices <- c("debug", "opl", "xml")

  if (!identical(output_format, possible_choices)) {
    coll <- checkmate::makeAssertCollection()
    checkmate::assert_string(output_format, add = coll)
    checkmate::assert_names(
      output_format,
      subset.of = possible_choices,
      add = coll
    )
    checkmate::reportAssertions(coll)
  }

  output_format_input <- output_format[1]

  output_format_input <- if (output_format_input == "input") {
    character()
  } else {
    paste0("--format-", output_format)
  }

  return(output_format_input)
}

write_content_to_file <- function(content, output_format) {
  output_format <- output_format[1]

  fileext <- if (output_format == "debug") {
    ".html"
  } else {
    paste0(".", output_format)
  }

  tmpfile <- tempfile("osm_content", fileext = fileext)

  if (output_format == "debug") {
    content <- fansi::to_html(fansi::html_esc(content))
    content <- gsub("\r|\n|\r\n", "<br>", content)
  }

  cat(content, file = tmpfile)

  return(normalizePath(tmpfile))
}

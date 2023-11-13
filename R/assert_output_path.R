check_output_path_multi_ext <- function(output_path, overwrite) {
  valid_output_res <- checkmate::check_path_for_output(
    output_path,
    overwrite = overwrite
  )
  if (!isTRUE(valid_output_res)) return(valid_output_res)

  valid_formats <- get_valid_output_formats()
  pattern_to_match <- paste(paste0(valid_formats, "$"), collapse = "|")

  if (! grepl(pattern_to_match, output_path)) {
    return(
      paste0(
        "Invalid file extension, must be one of: ",
        paste(valid_formats, collapse = ", ")
      )
    )
  }

  return(TRUE)
}

assert_output_path_multi_ext <- checkmate::makeAssertionFunction(
  check_output_path_multi_ext
)

get_valid_output_formats <- function() {
  # valid output formats taken from
  # https://docs.osmcode.org/osmium/latest/osmium-file-formats.html
  valid_output_formats <- c(
    ".osm",
    ".xml",
    ".osh",
    ".osc",
    ".osm.pbf",
    ".pbf",
    ".osm.opl",
    ".opl",
    ".osm.debug"
  )
  valid_output_formats <- c(
    rbind(
      valid_output_formats,
      paste0(valid_output_formats, ".gz"),
      paste0(valid_output_formats, ".bz2")
    )
  )

  # using .pbf.gz or .pbf.bz2 doesn't actually results in an error, but doesn't
  # affect the output either (compression doesn't work). in order to make it
  # clear that compressing pbf is not supported, we also forbid these formats.

  valid_output_formats <- valid_output_formats[
    -grep("\\.pbf\\.gz|\\.pbf\\.bz2", valid_output_formats)
  ]

  return(valid_output_formats)
}

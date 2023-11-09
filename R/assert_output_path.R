assert_output_path <- function(output_path, overwrite) {
  valid_formats <- get_valid_output_formats()

}

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

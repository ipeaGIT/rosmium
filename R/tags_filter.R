#' Filter objects matching specified keys/tags
#'
#' @examples
#' pbf_path <- system.file("extdata/cur.osm.pbf", package = "rosmium")
#'
#' @keywords internal
tags_filter <- function(input_path,
                        filters,
                        output_path,
                        overwrite = FALSE,
                        echo_cmd = FALSE,
                        echo = TRUE,
                        spinner = TRUE) {
  assert_osmium_is_installed()

  checkmate::assert_file_exists(input_path)
  checkmate::assert_string(filters)
  checkmate::assert_logical(overwrite, any.missing = FALSE, len = 1)
  checkmate::assert_logical(echo_cmd, any.missing = FALSE, len = 1)
  checkmate::assert_logical(echo, any.missing = FALSE, len = 1)
  checkmate::assert_logical(spinner, any.missing = FALSE, len = 1)

  filters_arg <- assert_and_assign_filters(filters)
  output_arg <- paste0("--output=", output_path)
  overwrite_arg <- if (overwrite) "--overwrite" else character()

  args <- c(
    "tags-filter",
    input_path,
    filters_arg,
    output_arg,
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

assert_and_assign_filters <- function(filters) {
  filters_input <- unlist(strsplit(filters, " "))

  assert_filters(filters_input)

  return(filters_input)
}

check_filters <- function(filters_input) {
  is_option <- grepl("^--", filters_input)
  contains_option <- any(is_option)

  if (contains_option) {
    return(
      paste0(
        "Must not contain option, but found at least one: ",
        paste(filters_input[is_option], collapse = ", ")
      )
    )
  }

  # slashes are used to specify the object type that may be affected by the
  # filter. to do this, one should specify the object type (either n, w, r or
  # a), use a slash, and then specify the key or key-value pair used in the
  # filter - e.g nw/highway means that and any node or way tagged as highway
  # should be kept. so we have to check if the characters before the slash are
  # actually n, w, r or a, otherwise osmium throws an error.

  contains_slash <- grepl("/", filters_input)

  # the regex below extracts all the text that appears before the first slash.

  text_before_slash <- sub("(^[^/]*).*", "\\1", filters_input)

  contains_invalid_char <- grepl("[^nwra]", text_before_slash)

  if (length(filters_input[contains_slash & contains_invalid_char]) > 0) {
    return(
      paste0(
        "At least one filter expression refers to an unknown object type: ",
        paste(
          paste0(
            "'", filters_input[contains_slash & contains_invalid_char], "'"
          ),
          collapse = ", "
        ),
        ". Valid object types are 'n', 'w', 'r' and 'a'"
      )
    )
  }

  return(TRUE)
}

assert_filters <- checkmate::makeAssertionFunction(check_filters)

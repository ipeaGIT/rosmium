#' Assert Osmium is installed
#'
#' Asserts Osmium is installed, throwing an error otherwise.
#'
#' @return Throws an error if Osmium is not installed, invisibly returns `TRUE`
#'   otherwise.
#'
#' @keywords internal
assert_osmium_is_installed <- function() {
  is_installed <- tryCatch(
    processx::run("osmium", "--version"),
    error = function(cnd) cnd
  )

  if (inherits(is_installed, "error")) {
    stop(
      "Could not find osmium in system. ",
      "Please make sure it has been installed and added to PATH."
    )
  }

  return(invisible(TRUE))
}

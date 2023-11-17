pbf_path <- system.file("extdata/cur.osm.pbf", package = "rosmium")

tester <- function(input_path = pbf_path,
                   filters = "n/amenity",
                   output_path = tempfile(fileext = ".osm.pbf"),
                   invert_match = FALSE,
                   omit_referenced = FALSE,
                   remove_tags = FALSE,
                   overwrite = FALSE,
                   echo_cmd = FALSE,
                   echo = TRUE,
                   spinner = TRUE,
                   verbose = FALSE,
                   progress = FALSE) {
  tags_filter(
    input_path,
    filters,
    output_path,
    invert_match,
    omit_referenced,
    remove_tags,
    overwrite,
    echo_cmd,
    echo,
    spinner,
    verbose,
    progress
  )
}

test_that("input should be correct", {
  expect_error(tester(1))
  expect_error(tester("a.osm.pbf"))

  expect_error(tester(filters = 1))
  expect_error(tester(filters = "n/amenity --help"))
  expect_error(tester(filters = "oie/amenity"))

  tmpfile <- tempfile(fileext = ".osm.pbf")
  file.create(tmpfile)
  expect_error(tester(output_path = tmpfile, overwrite = FALSE))
  expect_error(tester(output_path = "a.gz"))

  expect_error(tester(invert_match = 0))
  expect_error(tester(invert_match = NA))
  expect_error(tester(invert_match = c(TRUE, TRUE)))

  expect_error(tester(omit_referenced = 0))
  expect_error(tester(omit_referenced = NA))
  expect_error(tester(omit_referenced = c(TRUE, TRUE)))

  expect_error(tester(remove_tags = 0))
  expect_error(tester(remove_tags = NA))
  expect_error(tester(remove_tags = c(TRUE, TRUE)))

  expect_error(tester(overwrite = 0))
  expect_error(tester(overwrite = NA))
  expect_error(tester(overwrite = c(TRUE, TRUE)))

  expect_error(tester(echo_cmd = 0))
  expect_error(tester(echo_cmd = NA))
  expect_error(tester(echo_cmd = c(TRUE, TRUE)))

  expect_error(tester(echo = 0))
  expect_error(tester(echo = NA))
  expect_error(tester(echo = c(TRUE, TRUE)))

  expect_error(tester(spinner = 0))
  expect_error(tester(spinner = NA))
  expect_error(tester(spinner = c(TRUE, TRUE)))

  expect_error(tester(verbose = 0))
  expect_error(tester(verbose = NA))
  expect_error(tester(verbose = c(TRUE, TRUE)))

  expect_error(tester(progress = 0))
  expect_error(tester(progress = NA))
  expect_error(tester(progress = c(TRUE, TRUE)))
})

test_that("returns normalized path to output and writes output to path", {
  tmpfile <- tempfile(fileext = ".osm.pbf")

  result <- tester(output_path = tmpfile)
  expect_identical(result, normalizePath(tmpfile))

  expect_snapshot_file(tmpfile, name = "tester_default_output")
})

test_that("overwrite arguments works", {
  tmpfile <- tempfile(fileext = ".osm.pbf")

  result <- tester(output_path = tmpfile)

  expect_error(tester(output_path = tmpfile, overwrite = FALSE))
  expect_no_error(tester(output_path = tmpfile, overwrite = TRUE))
})

# arguments that control the filter behavior. imo it's not the role of this
# package to check if the actual filters are correct, but we still conduct some
# "sanity checks" just to make sure we're actually setting the arguments
# correctly

test_that("invert_match arguments works", {
  tmpfile <- tempfile(fileext = ".osm.pbf")

  output_keeping <- tester(
    filters = "barrier",
    output_path = tmpfile,
    invert_match = FALSE,
    omit_referenced = TRUE
  )
  sf_keeping <- sf::st_read(output_keeping, layer = "lines", quiet = TRUE)
  expect_true(!any(is.na(sf_keeping$barrier)))

  output_dropping <- tester(
    filters = "barrier",
    output_path = tmpfile,
    invert_match = TRUE,
    omit_referenced = TRUE,
    overwrite = TRUE
  )
  sf_dropping <- sf::st_read(output_dropping, layer = "lines", quiet = TRUE)
  expect_true(all(is.na(sf_dropping$barrier)))
})

test_that("omit_referenced arguments works", {
  tmpfile <- tempfile(fileext = ".osm.pbf")

  output_not_omitting <- tester(
    filters = "barrier",
    output_path = tmpfile,
    omit_referenced = FALSE
  )
  sf_not_omitting <- sf::st_read(
    output_not_omitting,
    layer = "points",
    quiet = TRUE
  )
  expect_true(any(is.na(sf_not_omitting$barrier)))

  output_omitting <- tester(
    filters = "barrier",
    output_path = tmpfile,
    omit_referenced = TRUE,
    overwrite = TRUE
  )
  sf_omitting <- sf::st_read(output_omitting, layer = "points", quiet = TRUE)
  expect_true(!any(is.na(sf_omitting$barrier)))
})

test_that("remove_tags arguments works", {
  tmpfile <- tempfile(fileext = ".osm.pbf")

  output_not_removing <- tester(
    filters = "barrier",
    output_path = tmpfile,
    omit_referenced = FALSE,
    remove_tags = FALSE
  )
  sf_not_removing <- sf::st_read(
    output_not_removing,
    layer = "points",
    quiet = TRUE
  )

  output_removing <- tester(
    filters = "barrier",
    output_path = tmpfile,
    omit_referenced = FALSE,
    remove_tags = TRUE,
    overwrite = TRUE
  )
  sf_removing <- sf::st_read(output_removing, layer = "lines", quiet = TRUE)

  # --remove-tags remove the tags of objects that do not match the filter but
  # are kept in the output because they are referenced by other objects. but the
  # objects referenced by others may also reference others, which increases even
  # more the number of features in the output.
  #
  # originally, the idea behind the tests would be to test if the features that
  # were kept in the output but do not include the filtering tag are "cleared",
  # but this hasn't worked in any of the tests we conducted because the features
  # kept in the output when remove_tags = FALSE that do not match the filter are
  # exactly features that were kept because they are referenced by a previously
  # referenced feature (and whose tags were cleared, so they don't reference the
  # "offending" feature anymore). therefore, we only test if the output not
  # removing tags is larger than the output removing.
  expect_true(nrow(sf_not_removing) > nrow(sf_removing))
  expect_true(nrow(subset(sf_not_removing, is.na(barrier))) > 0)
  expect_true(nrow(subset(sf_removing, is.na(barrier))) == 0)
})

# arguments that control the verbosity of the output. spinner doesn't work on
# non-interactive sessions, so we skip its tests

test_that("echo_cmd argument works", {
  expect_output(
    a <- tester(echo_cmd = TRUE, spinner = FALSE),
    regexp = "^Running osmium tags-filter"
  )

  output <- capture.output(a <- tester(echo_cmd = FALSE, spinner = FALSE))
  expect_identical(output, character(0))
})

test_that("echo argument works", {
  expect_output(
    a <- tester(echo = TRUE, spinner = FALSE, verbose = TRUE),
    regexp = "^\\[ 0:00\\] Started osmium tags-filter"
  )

  output <- capture.output(
    a <- tester(echo = FALSE, spinner = FALSE, verbose = TRUE)
  )
  expect_identical(output, character(0))
})

test_that("verbose argument works", {
  expect_output(
    a <- tester(echo = TRUE, spinner = FALSE, verbose = TRUE),
    regexp = "^\\[ 0:00\\] Started osmium tags-filter"
  )

  output <- capture.output(
    a <- tester(echo = TRUE, spinner = FALSE, verbose = FALSE)
  )
  expect_identical(output, character(0))
})

test_that("progress argument works", {
  expect_output(
    a <- tester(echo = TRUE, spinner = FALSE, progress = TRUE),
    regexp = "^\\[=*\\] 100%"
  )

  output <- capture.output(
    a <- tester(echo = TRUE, spinner = FALSE, progress = FALSE)
  )
  expect_identical(output, character(0))
})

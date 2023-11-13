tester <- function(output_path, overwrite = FALSE) {
  assert_output_path_multi_ext(output_path, overwrite)
}

test_that("respects overwrite", {
  tmpfile <- tempfile(fileext = ".pbf")
  file.create(tmpfile)
  expect_error(tester(tmpfile, overwrite = FALSE))
  expect_identical(tester(tmpfile, overwrite = TRUE), tmpfile)
})

test_that("it works with all supported file extensions", {
  supported_extensions <- get_valid_output_formats()

  for (ext in supported_extensions) {
    tmpfile <- tempfile(fileext = ext)
    expect_no_error(tester(!!tmpfile))
  }
})

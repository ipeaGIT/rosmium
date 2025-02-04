testthat::skip_on_cran()

pbf_path <- system.file("extdata/cur.osm.pbf", package = "rosmium")

test_that("time filter output is generated", {
  output <- tempfile(fileext = ".osm.pbf")

  filtered_file_path <- time_filter(
    input_path = pbf_path,
    timestamp = "2015-01-01T00:00:00Z",
    output_path = output
  )
  expect_true(file.exists(filtered_file_path))
})

test_that("Date Object as Timestamp", {
  output <- tempfile(fileext = ".osm.pbf")

  filtered_file_path <- time_filter(
    input_path = pbf_path,
    timestamp = as.Date("2015-01-01"),
    output_path = output
  )
  expect_true(file.exists(filtered_file_path))
})

test_that("POSIXct Object as Timestamp", {
  output <- tempfile(fileext = ".osm.pbf")

  filtered_file_path <- time_filter(
    input_path = pbf_path,
    timestamp = as.POSIXct("2015-01-01 00:00:00", tz = "UTC"),
    output_path = output
  )
  expect_true(file.exists(filtered_file_path))
})

test_that("Invalid Timestamp Format", {
  output <- tempfile(fileext = ".osm.pbf")

  expect_error(
    time_filter(
      input_path = pbf_path,
      timestamp = "invalid-date",
      output_path = output
    ),
    regexp = "Invalid timestamp format"
  )
})

test_that("Non-Existent Input Path", {
  output <- tempfile(fileext = ".osm.pbf")

  expect_error(
    time_filter(
      input_path = "non_existent_file.osm.pbf",
      timestamp = "2015-01-01T00:00:00Z",
      output_path = output
    ),
    "File does not exist"
  )
})

test_that("Overwrite Test", {
  output <- tempfile(fileext = ".osm.pbf")
  time_filter(pbf_path, "2015-01-01T00:00:00Z", output)

  expect_error(
    time_filter(pbf_path, "2015-01-01T00:00:00Z", output, overwrite = FALSE),
    "already exists"
  )

  filtered_file_path <- time_filter(pbf_path, "2015-01-01T00:00:00Z", output, overwrite = TRUE)
  expect_true(file.exists(filtered_file_path))
})

test_that("Missing Output Path Extension", {
  expect_error(
    time_filter(
      input_path = pbf_path,
      timestamp = "2015-01-01T00:00:00Z",
      output_path = tempfile(fileext = "")
    ),
    "Invalid file extension"
  )
})

test_that("Verbose and Echo Command Flags", {
  output <- tempfile(fileext = ".osm.pbf")

  filtered_file_path <- time_filter(
    input_path = pbf_path,
    timestamp = "2015-01-01T00:00:00Z",
    output_path = output,
    verbose = TRUE,
    echo_cmd = TRUE
  )
  expect_true(file.exists(filtered_file_path))
})

test_that("Handling of Edge Date (Future Date)", {
  output <- tempfile(fileext = ".osm.pbf")

  filtered_file_path <- time_filter(
    input_path = pbf_path,
    timestamp = "2100-01-01T00:00:00Z",
    output_path = output
  )
  expect_true(file.exists(filtered_file_path))
  expect_gte(file.size(filtered_file_path), 0) # Ensure file is created even if empty
})

test_that("Spinner Flag Functionality", {
  output <- tempfile(fileext = ".osm.pbf")

  filtered_file_path <- time_filter(
    input_path = pbf_path,
    timestamp = "2015-01-01T00:00:00Z",
    output_path = output,
    spinner = FALSE
  )
  expect_true(file.exists(filtered_file_path))
})

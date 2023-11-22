pbf_path <- system.file("extdata/cur.osm.pbf", package = "rosmium")

small_pbf <- tags_filter(
  pbf_path,
  "note",
  tempfile(fileext = "osm.pbf"),
  omit_referenced = TRUE
)

tester <- function(
  input_path = small_pbf,
  output_format = c("html", "opl", "xml"),
  object_type = c("all", "node", "way", "relation", "changeset"),
  echo_cmd = FALSE,
  spinner = TRUE,
  preview = FALSE
) {
  show_content(
    input_path,
    output_format,
    object_type,
    echo_cmd,
    spinner,
    preview
  )
}

test_that("input should be correct", {
  expect_error(tester(1))
  expect_error(tester("a.osm.pbf"))

  expect_error(tester(output_format = 1))
  expect_error(tester(output_format = c("html", "opl")))
  expect_error(tester(output_format = "oi"))

  expect_error(tester(object_type = 1))
  expect_error(tester(object_type = "oi"))

  expect_error(tester(echo_cmd = 0))
  expect_error(tester(echo_cmd = NA))
  expect_error(tester(echo_cmd = c(TRUE, TRUE)))

  expect_error(tester(spinner = 0))
  expect_error(tester(spinner = NA))
  expect_error(tester(spinner = c(TRUE, TRUE)))

  expect_error(tester(preview = 0))
  expect_error(tester(preview = NA))
  expect_error(tester(preview = c(TRUE, TRUE)))
})

test_that("results in output with correct format", {
  output <- tester(output_format = "html")
  expect_true(grepl("\\.html$", output))

  output <- tester(output_format = "xml")
  expect_true(grepl("\\.xml$", output))

  output <- tester(output_format = "opl")
  expect_true(grepl("\\.opl$", output))
})

test_that("output contains correct object types", {
  # the regex below means that each line starts with the type identification
  # (either n [node], w [way] or r [relation] in our case) and a numeric id,
  # then followed by a whitespace
  output <- tester(object_type = "all", output_format = "opl")
  content <- readLines(output)
  expect_true(all(grepl("^[n|w|r]\\d* ", content)))

  output <- tester(object_type = c("node", "way"), output_format = "opl")
  content <- readLines(output)
  expect_true(all(grepl("^[n|w]\\d* ", content)))
})

test_that("echo_cmd argument works", {
  expect_output(
    a <- tester(echo_cmd = TRUE, spinner = FALSE),
    regexp = "^Running osmium show"
  )

  output <- capture.output(a <- tester(echo_cmd = FALSE, spinner = FALSE))
  expect_identical(output, character(0))
})

test_that("test", {
  local_test_context()
  expect_type(tester(preview = TRUE), "character")
})

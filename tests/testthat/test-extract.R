testthat::skip_on_cran()

pbf_path <- system.file("extdata/cur.osm.pbf", package = "rosmium")

lines <- sf::st_read(pbf_path, layer = "lines", quiet = TRUE)
bbox <- sf::st_bbox(lines)
bbox_polygon <- sf::st_as_sf(sf::st_as_sfc(bbox))

smaller_bbox_poly <- sf::st_buffer(sf::st_transform(bbox_polygon, 5880), -4000)
smaller_bbox_poly <- sf::st_transform(smaller_bbox_poly, 4326)

linestring <- sf::st_cast(smaller_bbox_poly, "LINESTRING")
geomcollection <- sf::st_as_sf(
  sf::st_combine(rbind(linestring, smaller_bbox_poly))
)

tester <- function(input_path = pbf_path,
                   extent = smaller_bbox_poly,
                   output_path = tempfile(fileext = ".osm.pbf"),
                   strategy = c("complete_ways", "smart", "simple"),
                   overwrite = FALSE,
                   echo_cmd = FALSE,
                   echo = TRUE,
                   spinner = TRUE,
                   verbose = FALSE) {
  extract(
    input_path,
    extent,
    output_path,
    strategy,
    overwrite,
    echo_cmd,
    echo,
    spinner,
    verbose
  )
}

test_that("input should be correct", {
  expect_error(tester(1))
  expect_error(tester("a.osm.pbf"))

  expect_error(tester(extent = unclass(bbox)))

  bad_bbox <- bbox
  bad_bbox[4] <- Inf
  expect_error(tester(extent = bad_bbox))
  bad_bbox[4] <- NA
  expect_error(tester(extent = bad_bbox))
  bad_bbox[4] <- 25
  names(bad_bbox)[4] <- "oi"
  expect_error(tester(extent = bad_bbox))
  names(bad_bbox)[4] <- "ymax"
  bad_bbox[5] <- 12
  expect_error(tester(extent = bad_bbox))

  expect_error(tester(extent = rbind(bbox_polygon, bbox_polygon)))
  expect_error(tester(extent = linestring))
  expect_error(tester(extent = geomcollection))

  tmpfile <- tempfile(fileext = ".osm.pbf")
  file.create(tmpfile)
  expect_error(tester(output_path = tmpfile, overwrite = FALSE))
  expect_error(tester(output_path = "a.gz"))

  expect_error(tester(strategy = 0))
  expect_error(tester(strategy = c("complete_ways", "simple")))
  expect_error(tester(strategy = "oi"))

  expect_error(tester(overwrite = 0))
  expect_error(tester(overwrite = NA))
  expect_error(tester(overwrite = c(TRUE, TRUE)))

  expect_error(tester(echo = 0))
  expect_error(tester(echo = NA))
  expect_error(tester(echo = c(TRUE, TRUE)))

  expect_error(tester(echo_cmd = 0))
  expect_error(tester(echo_cmd = NA))
  expect_error(tester(echo_cmd = c(TRUE, TRUE)))

  expect_error(tester(spinner = 0))
  expect_error(tester(spinner = NA))
  expect_error(tester(spinner = c(TRUE, TRUE)))
})

test_that("returns normalized path to output and writes output to path", {
  tmpfile <- tempfile(fileext = ".osm.pbf")

  result <- tester(output_path = tmpfile)
  expect_identical(result, normalizePath(tmpfile))

  expect_snapshot_file(tmpfile, name = "tester_default_output")
})

test_that("works with bbox and results in same output as with equiv poly", {
  tmpfile <- tempfile(fileext = ".osm.pbf")
  smaller_bbox <- sf::st_bbox(smaller_bbox_poly)

  result <- tester(extent = smaller_bbox, output_path = tmpfile)
  expect_identical(result, normalizePath(tmpfile))

  # same snapshot as the above test, which was generated with the polygon
  expect_snapshot_file(tmpfile, name = "tester_default_output")
})

test_that("overwrite arguments works", {
  tmpfile <- tempfile(fileext = ".osm.pbf")

  result <- tester(output_path = tmpfile)

  expect_error(tester(output_path = tmpfile, overwrite = FALSE))
  expect_no_error(tester(output_path = tmpfile, overwrite = TRUE))
})

test_that("strategy argument works", {
  expect_output(
    a <- tester(spinner = FALSE, verbose = TRUE),
    regexp = "Running 'complete_ways' strategy"
  )

  expect_output(
    a <- tester(strategy = "smart", spinner = FALSE, verbose = TRUE),
    regexp = "Running 'smart' strategy"
  )

  expect_output(
    a <- tester(strategy = "simple", spinner = FALSE, verbose = TRUE),
    regexp = "Running 'simple' strategy"
  )
})

# arguments that control the verbosity of the output. spinner doesn't work on
# non-interactive sessions, so we skip its tests

test_that("echo_cmd argument works", {
  expect_output(
    a <- tester(echo_cmd = TRUE, spinner = FALSE),
    regexp = "^Running osmium extract"
  )

  output <- capture.output(a <- tester(echo_cmd = FALSE, spinner = FALSE))
  expect_identical(output, character(0))
})

test_that("echo argument works", {
  expect_output(
    a <- tester(echo = TRUE, spinner = FALSE, verbose = TRUE),
    regexp = "^\\[ 0:00\\] Started osmium extract"
  )

  output <- capture.output(
    a <- tester(echo = FALSE, spinner = FALSE, verbose = TRUE)
  )
  expect_identical(output, character(0))
})

test_that("verbose argument works", {
  expect_output(
    a <- tester(echo = TRUE, spinner = FALSE, verbose = TRUE),
    regexp = "^\\[ 0:00\\] Started osmium extract"
  )

  output <- capture.output(
    a <- tester(echo = TRUE, spinner = FALSE, verbose = FALSE)
  )
  expect_identical(output, character(0))
})

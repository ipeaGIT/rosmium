pbf_path <- system.file("extdata/cur.osm.pbf", package = "rosmium")

lines <- sf::st_read(pbf_path, layer = "lines", quiet = TRUE)
bbox <- sf::st_bbox(lines)
bbox_polygon <- sf::st_as_sf(sf::st_as_sfc(bbox))

smaller_bbox_poly <- sf::st_buffer(sf::st_transform(bbox_polygon, 5880), -3000)
smaller_bbox_poly <- sf::st_transform(smaller_bbox_poly, 4326)

linestring <- sf::st_cast(smaller_bbox_poly, "LINESTRING")
geomcollection <- sf::st_as_sf(
  sf::st_combine(rbind(linestring, smaller_bbox_poly))
)

tester <- function(input_path = pbf_path,
                   borders = smaller_bbox_poly,
                   output_path = tempfile(fileext = ".osm.pbf"),
                   overwrite = FALSE,
                   echo = TRUE,
                   echo_cmd = FALSE,
                   spinner = TRUE) {
  extract(input_path, borders, output_path, overwrite, echo, echo_cmd, spinner)
}

test_that("input should be correct", {
  expect_error(tester(1))
  expect_error(tester("a.osm.pbf"))

  expect_error(tester(borders = unclass(bbox)))

  bad_bbox <- bbox
  bad_bbox[4] <- Inf
  expect_error(tester(borders = bad_bbox))
  bad_bbox[4] <- NA
  expect_error(tester(borders = bad_bbox))
  bad_bbox[4] <- 25
  names(bad_bbox)[4] <- "oi"
  expect_error(tester(borders = bad_bbox))
  names(bad_bbox)[4] <- "ymax"
  bad_bbox[5] <- 12
  expect_error(tester(borders = bad_bbox))

  expect_error(tester(borders = rbind(bbox_polygon, bbox_polygon)))
  expect_error(tester(borders = linestring))
  expect_error(tester(borders = geomcollection))

  tmpfile <- tempfile(fileext = ".osm.pbf")
  file.create(tmpfile)
  expect_error(tester(output_path = tmpfile, overwrite = FALSE))
  expect_error(tester(output_path = "a.gz"))

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

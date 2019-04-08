context("test-test_big")

test_that("read_big_osmar returns a valid osmar object", {
  boston_xml_file <- unzip(system.file("extdata/boston.xml.zip", package = "bigosm", mustWork = TRUE), exdir = tempdir())
  boston_osmar <- read_big_osm(boston_xml_file, way_keys = "highway")

  node_attr_names <- list(id = "numeric", lat = "numeric", lon = "numeric", version = "character", timestamp = "character", changeset = "numeric", uid = "numeric", user = "character")
  base_attr_names <- list(id = "numeric", version = "character", timestamp = "character", changeset = "numeric", uid = "numeric", user = "character")

  tag_names <- list(id = "numeric", k = "character", v = "character")
  ref_names <- list(id = "numeric", ref = "numeric")
  relation_names <- list(id = "numeric", type = "character", ref = "numeric", role = "character")

  expect_is(boston_osmar, "osmar")

  expect_is(boston_osmar[["nodes"]], "list")
  expect_is(boston_osmar[["nodes"]], "osmar_element")
  expect_is(boston_osmar[["nodes"]], "nodes")
  expect_is(boston_osmar[["nodes"]][["attrs"]], "data.frame")
  expect_equivalent(lapply(boston_osmar[["nodes"]][["attrs"]], class), node_attr_names)
  expect_is(boston_osmar[["nodes"]][["tags"]], "data.frame")
  expect_equivalent(lapply(boston_osmar[["nodes"]][["tags"]], class), tag_names)

  expect_is(boston_osmar[["ways"]], "list")
  expect_is(boston_osmar[["ways"]], "osmar_element")
  expect_is(boston_osmar[["ways"]], "ways")
  expect_is(boston_osmar[["ways"]][["attrs"]], "data.frame")
  expect_equivalent(lapply(boston_osmar[["ways"]][["attrs"]], class), base_attr_names)
  expect_is(boston_osmar[["ways"]][["tags"]], "data.frame")
  expect_equivalent(lapply(boston_osmar[["ways"]][["tags"]], class), tag_names)
  expect_is(boston_osmar[["ways"]][["refs"]], "data.frame")
  expect_equivalent(lapply(boston_osmar[["ways"]][["refs"]], class), ref_names)
  expect_true(all(boston_osmar[["ways"]][["refs"]][["id"]] %in% boston_osmar[["ways"]][["attrs"]][["id"]]))
  expect_true(all(boston_osmar[["ways"]][["refs"]][["ref"]] %in% boston_osmar[["nodes"]][["attrs"]][["id"]]))

  expect_is(boston_osmar[["relations"]], "list")
  expect_is(boston_osmar[["relations"]], "osmar_element")
  expect_is(boston_osmar[["relations"]], "relations")
  expect_is(boston_osmar[["relations"]][["attrs"]], "data.frame")
  expect_equivalent(lapply(boston_osmar[["relations"]][["attrs"]], class), base_attr_names)
  expect_is(boston_osmar[["relations"]][["tags"]], "data.frame")
  expect_equivalent(lapply(boston_osmar[["relations"]][["tags"]], class), tag_names)
  expect_is(boston_osmar[["relations"]][["refs"]], "data.frame")
  expect_equivalent(lapply(boston_osmar[["relations"]][["refs"]], class), relation_names)
  expect_true(all(boston_osmar[["relations"]][["refs"]][["id"]] %in% boston_osmar[["relations"]][["attrs"]][["id"]]))
})


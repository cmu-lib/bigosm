context("test-test_big")

test_that("read_big_osmar returns a valid osmar object", {
  boston_xml_file <- unzip(system.file("extdata/boston.xml.zip", package = "bigosm", mustWork = TRUE), exdir = tempdir())

  way_keys <- "highway"
  relation_keys <- "type"

  boston_osmar <- read_big_osm(boston_xml_file, way_keys = way_keys, relation_keys = relation_keys)
  # reference_osmar <- get_osm(complete_file(), source = osmsource_file(boston_xml_file))

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
  expect_true(all(boston_osmar[["nodes"]][["tags"]][["id"]] %in% boston_osmar[["nodes"]][["attrs"]][["id"]]),
              info = "All Node tags must be in attributes table")

  expect_is(boston_osmar[["ways"]], "list")
  expect_is(boston_osmar[["ways"]], "osmar_element")
  expect_is(boston_osmar[["ways"]], "ways")
  expect_is(boston_osmar[["ways"]][["attrs"]], "data.frame")
  expect_equivalent(lapply(boston_osmar[["ways"]][["attrs"]], class), base_attr_names)
  expect_is(boston_osmar[["ways"]][["tags"]], "data.frame")
  expect_equivalent(lapply(boston_osmar[["ways"]][["tags"]], class), tag_names)
  expect_is(boston_osmar[["ways"]][["refs"]], "data.frame")
  expect_equivalent(lapply(boston_osmar[["ways"]][["refs"]], class), ref_names)
  expect_true(all(boston_osmar[["ways"]][["tags"]][["id"]] %in% boston_osmar[["ways"]][["attrs"]][["id"]]),
              info = "All Way tags must be in attributes table")
  expect_true(all(boston_osmar[["ways"]][["refs"]][["id"]] %in% boston_osmar[["ways"]][["attrs"]][["id"]]),
              info = "All Way references must be in attributes table")
  expect_true(all(boston_osmar[["ways"]][["refs"]][["ref"]] %in% boston_osmar[["nodes"]][["attrs"]][["id"]]),
              info = "All Way references to nodes must be in node attributes table")
  expect_true(all(subset(boston_osmar[["ways"]][["tags"]], k %in% way_keys)[["id"]] %in% boston_osmar[["ways"]][["attrs"]][["id"]]),
              info = "All Way tags must have keys present in way_keys")

  expect_is(boston_osmar[["relations"]], "list")
  expect_is(boston_osmar[["relations"]], "osmar_element")
  expect_is(boston_osmar[["relations"]], "relations")
  expect_is(boston_osmar[["relations"]][["attrs"]], "data.frame")
  expect_equivalent(lapply(boston_osmar[["relations"]][["attrs"]], class), base_attr_names)
  expect_is(boston_osmar[["relations"]][["tags"]], "data.frame")
  expect_equivalent(lapply(boston_osmar[["relations"]][["tags"]], class), tag_names)
  expect_is(boston_osmar[["relations"]][["refs"]], "data.frame")
  expect_equivalent(lapply(boston_osmar[["relations"]][["refs"]], class), relation_names)
  expect_true(all(boston_osmar[["relations"]][["refs"]][["id"]] %in% boston_osmar[["relations"]][["attrs"]][["id"]]),
              info = "All Way references must be in attributes table")
  expect_true(all(boston_osmar[["relations"]][["tags"]][["id"]] %in% boston_osmar[["relations"]][["attrs"]][["id"]]),
              info = "All Relation tags must be in attributes table")
  expect_true(all(subset(boston_osmar[["relations"]][["tags"]], k %in% relation_keys)[["id"]] %in% boston_osmar[["relations"]][["attrs"]][["id"]]),
              info = "All Relation tags must have keys present in relation_keys")
})


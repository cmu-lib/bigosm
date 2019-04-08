context("test-test_big")

test_that("error on bad XML", {
  badfile <- system.file("extdata/bad.xml", package = "bigosm", mustWork = TRUE)
  expect_error(read_big_osm(badfile))
})

test_that("read_big_osmar returns a valid osmar object", {
  node_attr_names <- list(id = "numeric", visible = "factor",
                          timestamp = c("POSIXlt", "POSIXt"), version = "numeric",
                          changeset = "numeric", user = "factor", uid = "factor",
                          lat = "numeric", lon = "numeric")

  base_attr_names <- list(id = "numeric", visible = "factor",
                          timestamp = c("POSIXlt", "POSIXt"), version = "numeric",
                          changeset = "numeric", user = "factor", uid = "factor")


  tag_names <- list(id = "numeric", k = "factor", v = "factor")
  ref_names <- list(id = "numeric", ref = "numeric")
  relation_names <- list(id = "numeric", type = "factor", ref = "numeric", role = "factor")

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

test_that("resulting osmar conforms to baseline reference", {
  if (!requireNamespace("osmar", quietly = TRUE)) skip("Skipping because osmar not installed.")
  if (Sys.info()["sysname"] == "Windows") skip("Skipping because Windows provides inconsistent comparisons.")
  # Skip this long-running test on CRAN
  skip_on_cran()
  # Get full object and osmar reference object
  reference_osmar <- osmar::get_osm(osmar::complete_file(), source = osmar::osmsource_file(boston_xml_file))
  complete_big_osmar <- read_big_osm(boston_xml_file)
  expect_equal(complete_big_osmar, reference_osmar)
})

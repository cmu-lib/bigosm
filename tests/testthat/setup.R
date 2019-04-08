suppressMessages({
  boston_xml_file <- unzip(system.file("extdata/boston.xml.zip", package = "bigosm", mustWork = TRUE), exdir = tempdir())

  way_keys <- "highway"
  relation_keys <- "type"

  # Object to test the key filtering functioons
  boston_osmar <- read_big_osm(boston_xml_file, way_keys = way_keys, relation_keys = relation_keys)
})

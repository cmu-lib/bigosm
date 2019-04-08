suppressMessages({
  if (!requireNamespace("osmar", quietly = TRUE)) stop("Must have osmar installed to run tests")
  boston_xml_file <- unzip(system.file("extdata/boston.xml.zip", package = "bigosm", mustWork = TRUE), exdir = tempdir())

  way_keys <- "highway"
  relation_keys <- "type"

  # Object to test the key filtering functioons
  boston_osmar <- read_big_osm(boston_xml_file, way_keys = way_keys, relation_keys = relation_keys)

  # Get full object and osmar reference object
  reference_osmar <- osmar::get_osm(osmar::complete_file(), source = osmar::osmsource_file(boston_xml_file))
  complete_big_osmar <- read_big_osm(boston_xml_file)
})

# Top Level Accessors ----

#' Read large OSM XML files
#'
#' [osmar][osmar::osmar] is an R package for reading
#' [OpenStreetMap](https://openstreetmap.org) XML data exports. It relies on
#' reading an entire file into an R string and then parsing with the XML
#' package. This method breaks on particularly large files (generally those in
#' excess of 400 MB). `read_big_osm()` instead relies on direct queries of an XML
#' file via the xml2 package.
#'
#' You may further subset the OSM objects to import by specifying
#' [Way](https://wiki.openstreetmap.org/wiki/Way) or
#' [Relation](https://wiki.openstreetmap.org/wiki/Relation) [key
#' values](https://wiki.openstreetmap.org/wiki/Tags) that must be present in
#' those elements' tags in order for them and their associated
#' [Nodes](https://wiki.openstreetmap.org/wiki/Node) to be imported.
#'
#' @param file Path to the file
#' @param way_keys Character. Filter Ways extracted from XML to those that
#'   contain at least one of these key labels in their tags.
#' @param relation_keys relation_keys Filter Relations extracted from XML to
#'   those that contain at least one of these key labels in their tags.
#' @return An [`osmar`][osmar::osmar] object
#' @import xml2
#' @export
read_big_osm <- function(file, way_keys = NULL, relation_keys = NULL) {
  message("Reading xml...", appendLF = FALSE)
  osm_xml <- read_xml(file, options = "HUGE")
  if (is.na(xml_find_first(osm_xml, "./node")))
    stop("No valid OSM data found in ", file)
  message("done.")

  way_l <- ways(osm_xml, way_keys)
  relation_l <- relations(osm_xml, relation_keys)
  node_ids <- unique(way_l$refs$ref)
  node_l <- nodes(osm_xml, node_ids, way_keys, relation_keys)

  structure(list(nodes = node_l, ways = way_l, relations = relation_l), class = c("osmar", "list"))
}

# XML Extraction Functions ----

# Cast the character vector list into a matrix and then convert to a data.frame
attrs_to_df <- function(nodes) {
  raw_node_attrs <- xml_attrs(nodes)
  first_node <- raw_node_attrs[[1]]
  node_matrix <- matrix(unlist(raw_node_attrs), nrow = length(nodes),
                        ncol = length(first_node), byrow = TRUE,
                        dimnames = list(NULL, names(raw_node_attrs[[1]])))
  node_df <- as.data.frame(node_matrix, stringsAsFactors = FALSE)
  colnames(node_df) <- names(first_node)
  node_df
}

base_attrs <- function(elem) {
  df <- attrs_to_df(elem)
  df[["id"]] <- as.numeric(df[["id"]])
  df[["timestamp"]] <- strptime(df[["timestamp"]], format = "%Y-%m-%dT%H:%M:%S")
  df[["visible"]] <- factor(NA)
  df[["version"]] <- as.numeric(df[["version"]])
  df[["changeset"]] <- as.numeric(df[["changeset"]])
  df[["user"]] <- as.factor(df[["user"]])
  df[["uid"]] <- as.factor(df[["uid"]])
  df
}

base_tags <- function(elem) {
  df <- attrs_to_df(elem)
  df[["k"]] <- as.factor(df[["k"]])
  df[["v"]] <- as.factor(df[["v"]])
  df
}

# Nodes ----

nodes <- function(osm_xml, node_ids, way_keys, relation_keys) {
  message("Identifying nodes...", appendLF = FALSE)
  node_nodes <- xml_find_all(osm_xml, "./node")
  full_node_ids <- as.numeric(xml_attr(node_nodes, "id"))

  # Only subset the retrieved nodes if either Ways or Relations have been
  # subset. Otherwise, return everything
  if (!is.null(way_keys) | !is.null(relation_keys)) {
    node_indices <- full_node_ids %in% node_ids
    node_nodes <- node_nodes[node_indices]
  } else {
    node_ids <- full_node_ids
  }

  message(length(node_nodes), " nodes found.")
  structure(list(
    attrs = node_attrs(node_nodes),
    tags = node_tags(node_nodes, node_ids)
  ), class = c("nodes", "osmar_element", "list"))
}

node_attrs <- function(nodes) {
  message("Collecting node attributes...", appendLF = FALSE)
  node_df <- base_attrs(nodes)
  node_df[["lat"]] <- as.numeric(node_df[["lat"]])
  node_df[["lon"]] <- as.numeric(node_df[["lon"]])
  message("done.")
  node_df[,c("id", "visible", "timestamp", "version", "changeset", "user", "uid", "lat", "lon")]
}

node_tags <- function(nodes, node_ids) {
  message("Collecting node tags...", appendLF = FALSE)
  node_tag_counts <- xml_find_num(nodes, "count(./tag)")
  replicated_node_ids <- rep(node_ids, times = node_tag_counts)
  node_tag_nodes <- xml_find_all(nodes, "./tag")
  tag_df <- base_tags(node_tag_nodes)
  message("done.")
  cbind(data.frame(id = replicated_node_ids), tag_df)
}

# Ways ----

ways <- function(osm_xml, way_keys) {
  message("Finding ways...", appendLF = FALSE)
  if (is.null(way_keys)) {
    way_nodes <- xml_find_all(osm_xml, "./way")
  } else {
    key_query <- paste0("./way/tag[@k='", way_keys, "']", collapse = " | ")
    way_nodes <- xml_parent(xml_find_all(osm_xml, key_query))
  }
  message(length(way_nodes), " found.")

  message("Collecting way attributes...", appendLF = FALSE)
  way_a <- way_attrs(way_nodes)
  message("done.")

  message("Collecting way tags...", appendLF = FALSE)
  way_t <- way_tags(way_nodes, parent_ids = way_a[["id"]])
  message("done.")

  message("Collecting way refs...", appendLF = FALSE)
  way_r <- way_refs(way_nodes, parent_ids = way_a[["id"]])
  message("done.")

  structure(list(
    attrs = way_a,
    tags = way_t,
    refs = way_r
  ), class = c("ways", "osmar_element", "list"))
}

way_attrs <- function(ways) {
  base_attrs(ways)[,c("id", "visible", "timestamp", "version", "changeset", "user", "uid")]
}

way_tags <- function(ways, parent_ids) {
  # Figure out how many times to replicate the parent ids for binding onto the final data frame
  parent_way_num_children <- xml_find_num(ways, "count(./tag)")
  replicated_parent_ids <- rep(parent_ids, times = parent_way_num_children)
  way_tag_nodes <- xml_find_all(ways, "./tag")
  kv_df <- base_tags(way_tag_nodes)
  cbind(data.frame(id = replicated_parent_ids), kv_df)
}

way_refs <- function(way_nodes, parent_ids) {
  parent_way_num_children <- xml_find_num(way_nodes, "count(./nd)")
  replicated_parent_ids <- rep(parent_ids, times = parent_way_num_children)
  way_ref_nodes <- xml_find_all(way_nodes, "./nd")
  node_refs <- as.numeric(xml_attr(way_ref_nodes, "ref"))

  data.frame(
    id = replicated_parent_ids,
    ref = node_refs
  )
}

# Relations ----

relations <- function(osm_xml, relation_keys) {
  message("Finding relations...", appendLF = FALSE)
  if (is.null(relation_keys)) {
    relation_nodes <- xml_find_all(osm_xml, "./relation")
  } else {
    key_query <- paste0("./relation/tag[@k='", relation_keys, "']", collapse = " | ")
    relation_nodes <- xml_parent(xml_find_all(osm_xml, key_query))
  }

  message(length(relation_nodes), " found.")

  message("Collecting relation attributes...", appendLF = FALSE)
  relation_a <- relation_attrs(relation_nodes)
  message("done.")

  message("Collecting relation tags...", appendLF = FALSE)
  relation_t <- relation_tags(relation_nodes, parent_ids = relation_a[["id"]])
  message("done.")

  message("Collecting relation refs...", appendLF = FALSE)
  relation_r <- relation_refs(relation_nodes, parent_ids = relation_a[["id"]])
  message("done.")

  structure(list(
    attrs = relation_a,
    tags = relation_t,
    refs = relation_r
  ), class = c("relations", "osmar_element", "list"))
}

relation_attrs <- function(relation_nodes) {
  base_attrs(relation_nodes)[,c("id", "visible", "timestamp", "version", "changeset", "user", "uid")]
}

relation_tags <- function(relation_nodes, parent_ids) {
  parent_relation_num_children <- xml_find_num(relation_nodes, "count(./tag)")
  replicated_parent_ids <- rep(parent_ids, times = parent_relation_num_children)
  relation_tag_nodes <- xml_find_all(relation_nodes, "./tag")
  kv_df <- base_tags(relation_tag_nodes)
  cbind(data.frame(id = replicated_parent_ids), kv_df)
}

relation_refs <- function(relation_nodes, parent_ids) {
  relation_ref_nodes <- xml_find_all(relation_nodes, "./member")

  relation_ref_counts <- xml_find_num(relation_nodes, "count(./member)")
  replicated_parent_ids <- rep(parent_ids, times = relation_ref_counts)

  ref_df <- attrs_to_df(relation_ref_nodes)
  ref_df[["ref"]] <- as.numeric(ref_df[["ref"]])
  ref_df[["type"]] <- as.factor(ref_df[["type"]])
  ref_df[["role"]] <- as.factor(ref_df[["role"]])
  cbind(data.frame(id = replicated_parent_ids), ref_df)
}

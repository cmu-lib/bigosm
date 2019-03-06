#' Read large OSM XML files
#'
#' @param file Path to the file
#' @import xml2
#' @export
read_big_osm <- function(file) {
  file_xml <- read_xml(file)

  structure(list(
    nodes = nodes(file_xml),
    ways = ways(file_xml),
    relations = relations(file_xml)
  ), class = c("list", "osmar"))
}

nodes <- function(osm_xml) {
  node_nodes <- xml_find_all(osm_xml, "./node")
  list(
    attrs = node_attrs(node_nodes),
    tags = node_tags(node_nodes)
  )
}

ways <- function(osm_xml) {
  way_nodes <- xml_find_all(osm_xml, "./way")
  list(
    attrs = way_attrs(way_nodes),
    tags = way_tags(way_nodes),
    refs = way_refs(way_nodes)
  )
}

relations <- function(osm_xml) {
  relation_nodes <- xml_find_all(osm_xml, "./relation")
  list(
    attrs = relation_attrs(relation_nodes),
    tags = relation_tags(relation_nodes),
    refs = relation_refs(relation_nodes)
  )
}

node_attrs <- function(nodes) {
  base_node_attrs <- base_attrs(nodes)
  positions <- data.frame(
    lat = as.numeric(xml_attr(nodes, "lat")),
    lon = as.numeric(xml_attr(nodes, "lon"))
  )

  cbind(base_node_attrs, positions)
}

node_tags <- function(nodes) {
  node_tag_nodes <- xml_find_all(nodes, "./tag")
  base_tags(node_tag_nodes)
}

way_attrs <- function(ways) {
  base_attrs(ways)
}

way_tags <- function(ways) {
  way_tag_nodes <- xml_find_all(ways, "./tag")
  base_tags(way_tag_nodes)
}

way_refs <- function(ways) {
  way_ref_nodes <- xml_find_all(ways, "./nd")
  data.frame(
    id = parent_ids(way_ref_nodes),
    ref = as.numeric(xml_attr(way_ref_nodes, "ref"))
  )
}

relation_attrs <- function(relations) {
  base_attrs(relations)
}

relation_tags <- function(relations) {
  relation_tag_nodes <- xml_find_all(relations, "./tag")
  base_tags(relation_tag_nodes)
}

relation_refs <- function(relations) {
  relation_ref_nodes <- xml_find_all(relations, "./member")
  data.frame(
    id = parent_ids(relation_ref_nodes),
    type = xml_attr(relation_ref_nodes, "type"),
    ref = as.numeric(xml_attr(relation_ref_nodes, "ref")),
    role = xml_attr(relation_ref_nodes, "role"),
    stringsAsFactors = FALSE
  )
}

parent_ids <- function(nodes) {
  vapply(nodes, function(el) as.numeric(xml_attr(xml_parent(el), "id")), FUN.VALUE = numeric(1))
}

base_attrs <- function(elem) {
  data.frame(
    id = as.numeric(xml_attr(elem, "id")),
    visible = xml_attr(elem, "visible"),
    version = as.integer(xml_attr(elem, "version")),
    changeset = as.numeric(xml_attr(elem, "changeset")),
    user = xml_attr(elem, "user"),
    uid = xml_attr(elem, "uid"),
    stringsAsFactors = FALSE)
}

base_tags <- function(elem) {
  data.frame(
    id = parent_ids(elem),
    k = xml_attr(elem, "k"),
    v = xml_attr(elem, "v")
  )
}

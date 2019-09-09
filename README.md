
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bigosm

[![Travis build
status](https://travis-ci.org/cmu-lib/bigosm.svg?branch=master)](https://travis-ci.org/cmu-lib/bigosm)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/cmu-lib/bigosm?branch=master&svg=true)](https://ci.appveyor.com/project/cmu-lib/bigosm)
[![Coverage
status](https://codecov.io/gh/cmu-lib/bigosm/branch/master/graph/badge.svg)](https://codecov.io/github/c/bigosm?branch=master)

bigosm reads in particularly large OSM XML exports (\>400MB) that cause
[osmar](https://cran.r-project.org/package=osmar)’s XML reader to choke.

## Installation

You can install the development version of bigosm from GitHub with:

``` r
# install.packages("devtools")
install_github("cmu-lib/bigosm")
```

## Usage

`read_big_osm` does what it says on the label. By specifying required
keys for both [Ways](https://wiki.openstreetmap.org/wiki/Way) and
[Relations](https://wiki.openstreetmap.org/wiki/Relation) you can
pre-filter the XML that ends up getting pulled into R.

``` r
boston_xml <- system.file("extdata/boston.xml.zip", package = "bigosm")

boston_osm <- read_big_osm(file = boston_xml, way_keys = "highway")
#> Reading xml...done.
#> Finding ways...1101 found.
#> Collecting way attributes...done.
#> Collecting way tags...done.
#> Collecting way refs...done.
#> Finding relations...118 found.
#> Collecting relation attributes...done.
#> Collecting relation tags...done.
#> Collecting relation refs...done.
#> Identifying nodes...6308 nodes found.
#> Collecting node attributes...done.
#> Collecting node tags...done.

summary(boston_osm)
#> osmar object
#> 6308 nodes, 1101 ways, 118 relations 
#> 
#> osmar$nodes object
#> 6308 nodes, 1650 tags 
#> 
#> ..$attrs data.frame: 
#>     id, visible, timestamp, version, changeset, user, uid, lat,
#>     lon 
#> ..$tags data.frame: 
#>     id, k, v 
#>  
#> Bounding box:
#>          lat       lon
#> min 42.35182 -71.14842
#> max 42.37785 -71.10424
#> 
#> Key-Value contingency table:
#>           Key                   Value Freq
#> 1 attribution Office of Geographic...  522
#> 2      source massgis_import_v0.1_...  448
#> 3     highway                crossing  116
#> 
#> 
#> osmar$ways object
#> 1101 ways, 5966 tags, 8082 refs 
#> 
#> ..$attrs data.frame: 
#>     id, visible, timestamp, version, changeset, user, uid 
#> ..$tags data.frame: 
#>     id, k, v 
#> ..$refs data.frame: 
#>     id, ref 
#>  
#> Key-Value contingency table:
#>           Key                   Value Freq
#> 1 attribution Office of Geographic...  455
#> 2     highway                 footway  337
#> 3     surface                 asphalt  306
#> 
#> 
#> osmar$relations object
#> 118 relations, 623 tags, 334 node_refs, 5661 way_refs 
#> 
#> ..$attrs data.frame: 
#>     id, visible, timestamp, version, changeset, user, uid 
#> ..$tags data.frame: 
#>     id, k, v 
#> ..$refs data.frame: 
#>     id, type, ref, role 
#>  
#> Key-Value contingency table:
#>           Key        Value Freq
#> 1        type  restriction   47
#> 2        type        route   36
#> 3 restriction no_left_turn   26
```

## Context

This package is one of several originally developed by [Matthew
Lincoln](https://github.com/mdlincoln) for use by Carnegie Mellon
University’s [“Bridges of Pittsburgh”](http://bridgesofpittsburgh.net/)
project:

  - [konigsberger](https://cmu-lib.github.io/konigsbergr/index.html)
    (end-user package)
      - [pathfinder](https://github.com/cmu-lib/pathfinder/)
      - [bigosm](https://github.com/cmu-lib/bigosm)
      - [simplygraph](https://github.com/cmu-lib/simplygraph)

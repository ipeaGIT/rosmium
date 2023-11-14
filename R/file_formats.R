#' Supported file formats
#'
#' @description
#' Please note that most of this documentation has been adapted from Osmium
#' documentation. Please see
#' <https://docs.osmcode.org/osmium/latest/osmium-file-formats.html> for the
#' original documentation.
#'
#' ## File types
#'
#' OSM uses three types of files for its main data:
#'
#' - Data files: these are the most common files. They contain the OSM data from
#' a specific point in time. At most one version of every object (node, way or
#' relation) is contained in this file. Deleted objects are not in this file.
#' The usual suffix used is `.osm`.
#'
#' - History files: these files contain not only the current version of an
#' object, but their history too. So for any object (node, way or relation)
#' there can be zero or more versions in this file. Deleted objects can also be
#' in this file. The usual suffix used is `.osm` or `.osh`. Because sometimes
#' the same suffix is used as for normal data files (`.osm`) and because there
#' is no clear indicator in the header, it is not always clear what type of file
#' you have in front of you.
#'
#' - Change files: sometimes called *diff files* or *replication diffs*, these
#' files contain the changes between one state of the OSM database and another
#' state. Change files can contains several versions of an object and also
#' deleted objects. The usual suffix used is `.osc`.
#'
#' All these files have in common that they contain OSM objects (nodes, ways
#' and relations). History files and change files can contain several versions
#' of the same object and also deleted objects; data files can't.
#'
#' Where possible, Osmium commands can handle all file types. For some commands
#' only some file types make sense.
#'
#' ## Formats
#'
#' Osmium supports all major OSM file formats plus some more. These are:
#'
#' - The classical XML format in the variants `.osm` (for data files), `.osh`
#' (for data files with history) and `.osc` (for change files).
#'
#' - The PBF binary format (usually with suffix `.osm.pbf` or just `.pbf`).
#'
#' - The OPL format (usually with suffix `.osm.opl` or just `.opl`).
#'
#' - The O5M/O5C format (usually with suffix `.o5m` or `.o5c`) (reading only).
#'
#' - The "debug" format (usually with suffix `.osm.debug`) (writing only).
#'
#' In addition, files in all formats except PBF can be compressed using *gzip*
#' or *bzip2* (add `.gz` or `.bz2` suffixes, respectively - e.g.
#' `data.osm.bz2`).
#'
#' @name file_formats
NULL

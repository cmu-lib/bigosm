#' Set all factor data to character
#'
#' While many internal [`osmar::osmar`] functions rely on internal table to use
#' factors, it can be useful to have those data frame columns cast to character
#' instead. Note that several functions such as [`osmar::find`] will no longer
#' work on the resulting object.
#'
#' @param osmar An [`osmar::osmar`] object.
#' @return A [`defactored_osmar`] object with all internal tables set to use
#'   character
#' @aliases defactored_osmar
#' @export
defactor <- function(osmar) {
  osmar[["nodes"]][["attrs"]][["visible"]] <- as.character(osmar[["nodes"]][["attrs"]][["visible"]])
  osmar[["nodes"]][["attrs"]][["user"]] <- as.character(osmar[["nodes"]][["attrs"]][["user"]])
  osmar[["nodes"]][["attrs"]][["uid"]] <- as.character(osmar[["nodes"]][["attrs"]][["uid"]])
  osmar[["nodes"]][["tags"]][["k"]] <- as.character(osmar[["nodes"]][["tags"]][["k"]])
  osmar[["nodes"]][["tags"]][["v"]] <- as.character(osmar[["nodes"]][["tags"]][["v"]])

  osmar[["ways"]][["attrs"]][["visible"]] <- as.character(osmar[["ways"]][["attrs"]][["visible"]])
  osmar[["ways"]][["attrs"]][["user"]] <- as.character(osmar[["ways"]][["attrs"]][["user"]])
  osmar[["ways"]][["attrs"]][["uid"]] <- as.character(osmar[["ways"]][["attrs"]][["uid"]])
  osmar[["ways"]][["tags"]][["k"]] <- as.character(osmar[["ways"]][["tags"]][["k"]])
  osmar[["ways"]][["tags"]][["v"]] <- as.character(osmar[["ways"]][["tags"]][["v"]])

  osmar[["relations"]][["attrs"]][["visible"]] <- as.character(osmar[["relations"]][["attrs"]][["visible"]])
  osmar[["relations"]][["attrs"]][["user"]] <- as.character(osmar[["relations"]][["attrs"]][["user"]])
  osmar[["relations"]][["attrs"]][["uid"]] <- as.character(osmar[["relations"]][["attrs"]][["uid"]])
  osmar[["relations"]][["tags"]][["k"]] <- as.character(osmar[["relations"]][["tags"]][["k"]])
  osmar[["relations"]][["tags"]][["v"]] <- as.character(osmar[["relations"]][["tags"]][["v"]])
  osmar[["relations"]][["refs"]][["type"]] <- as.character(osmar[["relations"]][["refs"]][["type"]])
  osmar[["relations"]][["refs"]][["role"]] <- as.character(osmar[["relations"]][["refs"]][["role"]])

  class(osmar) <- c("defactored_osmar", class(osmar))

  return(osmar)
}

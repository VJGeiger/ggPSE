#' Highlight specific elements on a periodic table
#'
#' A pipe-friendly layer that overlays a colored border on selected elements.
#' Can be added to an existing ggPSE() object or used standalone.
#' Multiple calls can highlight different groups simultaneously.
#'
#' @param plot A ggplot object from ggPSE() or ggPSE_bubble(). If NULL,
#'   a blank table is created first.
#' @param symbols Character vector of element symbols to highlight.
#' @param color Border color for highlighted tiles. Default "#e63946".
#' @param fill Fill color for highlighted tiles. NA keeps the existing fill.
#' @param linewidth Border thickness. Default 1.2.
#' @param label Character. Optional text label for the legend.
#'
#' @return The input ggplot object with a highlight layer added.
#' @export
#'
#' @examples
#' ggPSE() |>
#'   ggPSE_highlight(c("Li", "Co", "Ni"), color = "#2166ac") |>
#'   ggPSE_highlight(c("Nd", "Dy"),       color = "#e63946")
ggPSE_highlight <- function(
    plot      = NULL,
    symbols,
    color     = "#e63946",
    fill      = NA,
    linewidth = 1.2,
    label     = NULL
) {
  if (is.null(plot)) plot <- ggPSE()

  grid      <- .ggpse_elements()
  highlight <- grid[grid$symbol %in% symbols, , drop = FALSE]

  if (nrow(highlight) == 0) {
    warning("No matching elements found for: ", paste(symbols, collapse = ", "))
    return(plot)
  }

  plot +
    ggplot2::geom_tile(
      data        = highlight,
      ggplot2::aes(x = .data[["col"]], y = -.data[["row"]]),
      fill        = fill,
      color       = color,
      width       = 0.92,
      height      = 0.92,
      linewidth   = linewidth,
      inherit.aes = FALSE
    )
}

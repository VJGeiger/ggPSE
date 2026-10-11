#' Plot a periodic table with in-tile bar encoding
#'
#' Maps a continuous value to the length of a bar drawn inside each element
#' tile. The bar occupies a fixed thickness along the chosen edge and grows
#' in length proportionally to the normalised value. All tiles are drawn in
#' a neutral background so the bars are the primary visual signal.
#'
#' By default the bars start at zero, so their length is proportional to the
#' value (twice the value, twice the length). If the values contain negative
#' numbers the bars start at the minimum instead. Use \code{limits} to choose
#' the scale yourself, e.g. \code{limits = range(x)} to start at the smallest
#' value (that value then has no visible bar). The plot has no legend.
#'
#' @param data A data frame containing element symbols and a value column.
#'   If NULL, a blank table is drawn.
#' @param value_col Character. Column in data to map to bar length.
#' @param symbol_col Character. Column in data containing element symbols.
#'   Default "symbol".
#' @param bar_side Character. Edge from which the bar grows. One of
#'   "bottom" (default), "top", "left", or "right".
#' @param bar_color Hex fill color for bars. Default "#2166ac".
#' @param bar_alpha Numeric. Bar opacity 0-1. Default 0.85.
#' @param bar_thickness Numeric. Thickness of the bar as a fraction of the
#'   tile. Default 0.2 (20 percent of tile height/width).
#' @param color_na Hex color for tile backgrounds. Default "#ffffff".
#' @param tile_border Hex color for tile borders. Default "transparent".
#' @param legend_title Ignored: the bar plot has no legend. Kept so that existing
#'   calls keep working; a warning is given if it is set.
#' @param show_atomic_number Logical. Show atomic numbers. Default FALSE.
#' @param base_size Numeric. Base font size in pt. Default 10.
#' @param limits Numeric vector of length 2, \code{c(lower, upper)}: the values
#'   that correspond to an empty and a full-length bar. Values outside are drawn
#'   clipped (with a warning). Default \code{NULL} uses \code{c(min(0, min(x)),
#'   max(x))}.
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' supply_risk <- data.frame(
#'   symbol = c("Li", "Co", "Nd", "Dy", "Pt", "Ni", "Cu"),
#'   risk   = c(0.62, 0.91, 0.84, 0.88, 0.52, 0.70, 0.45)
#' )
#'
#' # Bar growing from the bottom
#' ggPSE_bar(supply_risk, value_col = "risk")
#'
#' # Bar growing from the left
#' ggPSE_bar(supply_risk, value_col = "risk",
#'           bar_side = "left", bar_color = "#e63946")
#'
#' # Start the bars at the smallest value instead of zero
#' ggPSE_bar(supply_risk, value_col = "risk", limits = range(supply_risk$risk))
ggPSE_bar <- function(
    data               = NULL,
    value_col          = NULL,
    symbol_col         = "symbol",
    bar_side           = "bottom",
    bar_color          = "#2166ac",
    bar_alpha          = 0.85,
    bar_thickness      = 0.2,
    color_na           = "#ffffff",
    tile_border        = "transparent",
    legend_title       = NULL,
    show_atomic_number = FALSE,
    base_size          = 10,
    limits             = NULL
) {
  bar_side <- match.arg(bar_side, c("bottom", "top", "left", "right"))
  if (!is.null(legend_title))
    warning("ggPSE_bar() draws no legend; 'legend_title' is ignored.", call. = FALSE)
  if (!is.null(limits) && (!is.numeric(limits) || length(limits) != 2L ||
                           anyNA(limits) || !all(is.finite(limits)) || limits[1] >= limits[2]))
    stop("'limits' must be two finite numbers c(lower, upper) with lower < upper.",
         call. = FALSE)
  
  grid <- .ggpse_elements()
  

  # validate the data and join it onto the tiles; helper in zzz.R
  if (!is.null(data)) {
    joined    <- .join_element_data(grid, data, symbol_col, value_col,
                                    fn = "ggPSE_bar()")
    grid      <- joined$grid
    value_col <- joined$value_col
  }
  grid$text_color <- "grey20"
  
  # ── Base tiles ────────────────────────────────────────────────────────────────
  p <- ggplot2::ggplot(
    grid,
    ggplot2::aes(x = .data[["col"]], y = -.data[["row"]])
  ) +
    ggplot2::geom_tile(
      fill      = color_na,
      color     = tile_border,
      width     = 0.92,
      height    = 0.92,
      linewidth = 0.3
    )
  
  # ── Bar layer ─────────────────────────────────────────────────────────────────
  if (!is.null(value_col) && value_col %in% names(grid)) {
    grid_bars <- grid[!is.na(grid[[value_col]]), , drop = FALSE]
    
    # Normalise values to 0-1. Default: bars start at zero (or at the minimum
    # if there are negative values), so that length is proportional to value.
    vals <- grid_bars[[value_col]]
    if (is.null(limits)) {
      lims <- c(min(0, vals), max(vals))
    } else {
      lims <- limits
      n_out <- sum(vals < lims[1] | vals > lims[2])
      if (n_out > 0)
        warning(sprintf("%d value(s) lie outside 'limits' and are drawn clipped.", n_out),
                call. = FALSE)
    }
    span <- lims[2] - lims[1]
    # no range (e.g. all values zero): no visible bars instead of NaN
    grid_bars$bar_norm <- if (span > 0) pmin(pmax((vals - lims[1]) / span, 0), 1) else 0
    
    hw <- 0.46                  # half of tile size (0.92 / 2)
    th <- bar_thickness * 0.92  # bar thickness in data units
    
    # bar_norm controls the length along the tile edge (0 to full tile width)
    # th controls the fixed narrow dimension of the bar
    grid_bars <- switch(bar_side,
                        bottom = within(grid_bars, {
                          xmin <- col - hw
                          xmax <- col - hw + bar_norm * 0.92
                          ymin <- -row - hw
                          ymax <- -row - hw + th
                        }),
                        top = within(grid_bars, {
                          xmin <- col - hw
                          xmax <- col - hw + bar_norm * 0.92
                          ymin <- -row + hw - th
                          ymax <- -row + hw
                        }),
                        left = within(grid_bars, {
                          xmin <- col - hw
                          xmax <- col - hw + th
                          ymin <- -row + hw - bar_norm * 0.92
                          ymax <- -row + hw
                        }),
                        right = within(grid_bars, {
                          xmin <- col + hw - th
                          xmax <- col + hw
                          ymin <- -row + hw - bar_norm * 0.92
                          ymax <- -row + hw
                        })
    )
    
    p <- p +
      ggplot2::geom_rect(
        data        = grid_bars,
        ggplot2::aes(
          xmin = .data[["xmin"]],
          xmax = .data[["xmax"]],
          ymin = .data[["ymin"]],
          ymax = .data[["ymax"]]
        ),
        fill        = bar_color,
        alpha       = bar_alpha,
        inherit.aes = FALSE
      )
  }
  
  # ── Symbol text ───────────────────────────────────────────────────────────────
  p <- p +
    ggplot2::geom_text(
      ggplot2::aes(label = .data[["symbol"]], color = .data[["text_color"]]),
      fontface = "bold",
      size     = base_size * 0.40,
      vjust    = 0.5
    )
  
  if (show_atomic_number) {
    p <- p +
      ggplot2::geom_text(
        ggplot2::aes(
          x     = .data[["col"]] - 0.42,
          y     = -.data[["row"]] + 0.38,
          label = .data[["atomic_number"]],
          color = .data[["text_color"]]
        ),
        hjust    = 0,
        vjust    = 1,
        size     = base_size * 0.22,
        fontface = "plain"
      )
  }
  
  # ── Scales and theme ──────────────────────────────────────────────────────────
  p <- p +
    ggplot2::scale_color_identity() +
    ggplot2::coord_fixed() +
    ggplot2::theme_void(base_size = base_size) +
    ggplot2::theme(
      legend.position  = "bottom",
      legend.key.width = ggplot2::unit(1.5, "cm"),
      legend.title     = ggplot2::element_text(size = base_size),
      legend.text      = ggplot2::element_text(size = base_size * 0.85),
      plot.margin      = ggplot2::margin(4, 4, 4, 4)
    )
  
  p
}
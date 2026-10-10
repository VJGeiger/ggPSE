#' Plot a periodic table with bubble size encoding
#'
#' Maps a continuous value to the size of a circle drawn inside each element
#' tile. All tiles are drawn in a neutral background color so the bubbles
#' are the primary visual signal. Useful when color is already used for
#' another variable, or when you want to show magnitude without implying
#' a color direction.
#'
#' @param data A data frame containing element symbols and a value column.
#'   If NULL, a blank table is drawn.
#' @param size_col Character. Column in data to map to bubble size.
#' @param symbol_col Character. Column in data containing element symbols.
#'   Default "symbol".
#' @param color_na Hex color for tile backgrounds. Default "#f0f0f0".
#' @param tile_border Hex color for tile borders. Default "transparent".
#' @param bubble_color Hex fill color for bubbles. Default "#2166ac".
#' @param bubble_border Hex border color for bubbles. Default "white".
#' @param bubble_alpha Numeric. Bubble opacity 0-1. Default 0.85.
#' @param size_range Numeric vector of length 2. Min and max bubble size.
#'   Default c(1, 9).
#' @param legend_title Character. Legend title. Defaults to size_col.
#' @param show_atomic_number Logical. Show atomic numbers. Default FALSE.
#' @param base_size Numeric. Base font size in pt. Default 10.
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' supply_risk <- data.frame(
#'   symbol = c("Li", "Co", "Nd", "Dy", "Pt", "Ni", "Cu"),
#'   risk   = c(0.62, 0.91, 0.84, 0.88, 0.52, 0.70, 0.45)
#' )
#' ggPSE_bubble(supply_risk, size_col = "risk",
#'              legend_title = "Supply risk score")
ggPSE_bubble <- function(
    data               = NULL,
    size_col           = NULL,
    symbol_col         = "symbol",
    color_na           = "#ffffff",
    tile_border        = "transparent",
    bubble_color       = "#2166ac",
    bubble_border      = "white",
    bubble_alpha       = 0.85,
    size_range         = c(1, 9),
    legend_title       = NULL,
    show_atomic_number = FALSE,
    base_size          = 10
) {
  grid <- .ggpse_elements()
  
  legend_title <- legend_title %||% size_col %||% ""

  # validate the data and join it onto the tiles; helper in zzz.R
  if (!is.null(data)) {
    joined   <- .join_element_data(grid, data, symbol_col, size_col,
                                   fn = "ggPSE_bubble()", value_arg = "size_col")
    grid     <- joined$grid
    size_col <- joined$value_col
  }
  
  # Text is always dark on the neutral background
  grid$text_color <- "grey20"
  
  p <- ggplot2::ggplot(
    grid,
    ggplot2::aes(x = .data[["col"]], y = -.data[["row"]])
  ) +
    # Neutral tile background
    ggplot2::geom_tile(
      fill      = color_na,
      color     = tile_border,
      width     = 0.92,
      height    = 0.92,
      linewidth = 0.3
    )
  
  # Bubble layer
  if (!is.null(size_col) && size_col %in% names(grid)) {
    grid_bubbles <- grid[!is.na(grid[[size_col]]), , drop = FALSE]
    
    p <- p +
      ggplot2::geom_point(
        data   = grid_bubbles,
        ggplot2::aes(
          x    = .data[["col"]],
          y    = -.data[["row"]],
          size = .data[[size_col]]
        ),
        shape  = 21,
        fill   = bubble_color,
        color  = bubble_border,
        alpha  = bubble_alpha,
        stroke = 0.4
      ) +
      ggplot2::scale_size_continuous(
        range = size_range,
        name  = legend_title
      )
  }
  
  # Symbol text on top of bubble
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
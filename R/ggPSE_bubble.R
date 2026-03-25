#' Plot a periodic table with bubble size encoding
#'
#' Maps a value to the radius of a circle drawn inside each element tile.
#' Useful when combining a categorical fill with a continuous size signal,
#' or when color is already used for another variable.
#'
#' @inheritParams ggPSE
#' @param size_col Character. Column in data to map to bubble size.
#' @param fill_col Character. Optional column to map to tile fill color.
#' @param size_range Numeric vector of length 2. Min and max bubble size in pt.
#'   Default c(1, 8).
#' @param bubble_color Character. Fill color for bubbles. Default "#2166ac".
#' @param bubble_alpha Numeric. Bubble opacity 0-1. Default 0.7.
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' supply_risk <- data.frame(
#'   symbol = c("Li", "Co", "Nd", "Dy", "Pt"),
#'   risk   = c(0.6, 0.9, 0.85, 0.88, 0.5)
#' )
#' ggPSE_bubble(supply_risk, size_col = "risk", legend_title = "Supply risk")
ggPSE_bubble <- function(
    data         = NULL,
    size_col     = NULL,
    symbol_col   = "symbol",
    fill_col     = NULL,
    color_low    = "#ffffff",
    color_high   = "#9a031e",
    color_na     = "#e8e8e6",
    legend_title = NULL,
    size_range   = c(1, 8),
    bubble_color = "#2166ac",
    bubble_alpha = 0.7,
    show_atomic_number = TRUE,
    base_size    = 8
) {
  grid <- .ggpse_elements()

  if (!is.null(data)) {
    cols_keep <- unique(c(symbol_col, size_col, fill_col))
    cols_keep <- cols_keep[cols_keep %in% names(data)]
    data      <- data[, cols_keep, drop = FALSE]
    names(data)[names(data) == symbol_col] <- "symbol"
    grid <- merge(grid, data, by = "symbol", all.x = TRUE)
  }

  legend_title <- legend_title %||% size_col %||% ""

  p <- ggplot2::ggplot(
    grid,
    ggplot2::aes(x = .data[["col"]], y = -.data[["row"]])
  ) +
    ggplot2::geom_tile(
      ggplot2::aes(
        fill = if (!is.null(fill_col) && fill_col %in% names(grid))
                 .data[[fill_col]] else NA_real_
      ),
      color = "white", width = 0.92, height = 0.92, linewidth = 0.3
    )

  if (!is.null(size_col) && size_col %in% names(grid)) {
    p <- p + ggplot2::geom_point(
      ggplot2::aes(size = .data[[size_col]]),
      shape  = 21,
      fill   = bubble_color,
      color  = "white",
      alpha  = bubble_alpha,
      stroke = 0.3
    ) +
      ggplot2::scale_size_continuous(range = size_range, name = legend_title)
  }

  p <- p +
    ggplot2::geom_text(
      ggplot2::aes(label = .data[["symbol"]]),
      fontface = "bold",
      size     = base_size * 0.40
    ) +
    { if (!is.null(fill_col) && fill_col %in% names(grid))
        ggplot2::scale_fill_gradient(
          low = color_low, high = color_high, na.value = color_na
        )
      else
        ggplot2::scale_fill_continuous(na.value = color_na, guide = "none")
    } +
    ggplot2::coord_fixed() +
    ggplot2::theme_void(base_size = base_size) +
    ggplot2::theme(
      legend.position  = "bottom",
      legend.key.width = ggplot2::unit(1.5, "cm"),
      plot.margin      = ggplot2::margin(4, 4, 4, 4)
    )

  p
}

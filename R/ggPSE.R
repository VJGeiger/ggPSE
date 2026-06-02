#' Plot a periodic table with a continuous value overlay
#'
#' The core plotting function of ggPSE. Returns a ggplot2 object that can be
#' further modified with + as usual: add themes, annotations, facets, etc.
#'
#' @param data A data frame containing element symbols and a value column.
#'   If NULL, a blank table using the NA color is drawn.
#' @param value_col Character. Column name in data to map to fill color.
#' @param symbol_col Character. Column in data containing element symbols.
#'   Default "symbol".
#' @param label_value Logical. Print numeric values inside tiles. Default TRUE.
#' @param value_digits Integer. Decimal places for displayed values. Default 2.
#' @param color_low Hex color for the low end of the gradient. Default "#ffffff".
#' @param color_high Hex color for the high end of the gradient. Default "#9a031e".
#' @param color_na Hex color for elements with no data. Default "#e8e8e6".
#' @param legend_title Character. Legend title. Defaults to value_col.
#' @param show_atomic_number Logical. Show atomic numbers. Default TRUE.
#' @param base_size Numeric. Base font size in pt. Default 8.
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' battery <- data.frame(
#'   symbol     = c("Li", "Co", "Ni", "Mn", "Fe"),
#'   importance = c(0.95, 0.88, 0.75, 0.60, 0.45)
#' )
#' ggPSE(battery, value_col = "importance", legend_title = "Battery relevance")
ggPSE <- function(
    data         = NULL,
    value_col    = NULL,
    symbol_col   = "symbol",
    label_value  = TRUE,
    value_digits = 2,
    color_low    = "#ffffff",
    color_high   = "#9a031e",
    color_na     = "#e8e8e6",
    legend_title = NULL,
    show_atomic_number = TRUE,
    base_size    = 8
) {
  grid <- .ggpse_elements()

  if (!is.null(data)) {
    if (!symbol_col %in% names(data))
      stop(sprintf("Column '%s' not found in data. Set symbol_col to the correct column name.", symbol_col))
    if (!is.null(value_col) && !value_col %in% names(data))
      stop(sprintf("Column '%s' not found in data.", value_col))
    cols_keep <- unique(c(symbol_col, value_col))
    data      <- data[, cols_keep, drop = FALSE]
    names(data)[names(data) == symbol_col] <- "symbol"
    grid <- merge(grid, data, by = "symbol", all.x = TRUE)
  }

  legend_title <- legend_title %||% value_col %||% ""
  fill_col     <- if (!is.null(value_col) && value_col %in% names(grid)) value_col else NULL

  p <- ggplot2::ggplot(
    grid,
    ggplot2::aes(
      x    = .data[["col"]],
      y    = -.data[["row"]],
      fill = if (!is.null(fill_col)) .data[[fill_col]] else NA_real_
    )
  ) +
    ggplot2::geom_tile(
      color     = "white",
      width     = 0.92,
      height    = 0.92,
      linewidth = 0.3
    ) +
    ggplot2::geom_text(
      ggplot2::aes(label = .data[["symbol"]]),
      fontface = "bold",
      size     = base_size * 0.40,
      vjust    = if (label_value && !is.null(fill_col)) 0.15 else 0.5
    )

  if (show_atomic_number) {
    p <- p + ggplot2::geom_text(
      ggplot2::aes(
        x     = .data[["col"]] - 0.43,
        label = .data[["atomic_number"]]
      ),
      hjust    = 0,
      vjust    = 1,
      size     = base_size * 0.20,
      color    = "grey50",
      fontface = "plain"
    )
  }

  if (label_value && !is.null(fill_col)) {
    p <- p + ggplot2::geom_text(
      ggplot2::aes(
        y     = -.data[["row"]] - 0.27,
        label = ifelse(
          is.na(.data[[fill_col]]), "",
          formatC(.data[[fill_col]], digits = value_digits, format = "f")
        )
      ),
      size  = base_size * 0.20,
      color = "grey30"
    )
  }

  p <- p +
    { if (!is.null(fill_col))
        ggplot2::scale_fill_gradient(
          low = color_low, high = color_high,
          na.value = color_na, name = legend_title
        )
      else
        ggplot2::scale_fill_continuous(na.value = color_na, guide = "none")
    } +
    ggplot2::coord_fixed() +
    ggplot2::theme_void(base_size = base_size) +
    ggplot2::theme(
      legend.position  = "bottom",
      legend.key.width = ggplot2::unit(2, "cm"),
      legend.title     = ggplot2::element_text(size = base_size),
      legend.text      = ggplot2::element_text(size = base_size * 0.85),
      plot.margin      = ggplot2::margin(4, 4, 4, 4)
    )

  p
}

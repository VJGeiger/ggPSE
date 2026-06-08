#' Plot a periodic table with a continuous value overlay
#'
#' The core plotting function of ggPSE. Returns a ggplot2 object that can be
#' further modified.
#'
#' @param data A data frame containing element symbols and a value column.
#'   If NULL, a blank table using the NA color is drawn.
#' @param value_col Character. Column name in data to map to fill color.
#' @param symbol_col Character. Column in data containing element symbols.
#'   Default "symbol".
#' @param label_value Logical. Print numeric values inside tiles. Default TRUE.
#' @param value_digits Integer. Decimal places for displayed values. Default 2.
#' @param color_low Hex color for the low end of the gradient. Default "#fdf0f2".
#' @param color_high Hex color for the high end of the gradient. Default "#9a031e".
#' @param color_na Hex color for elements with no data. Default "#f0f0f0".
#' @param tile_border Hex color for tile borders. If NULL (default), grey border
#'   on light backgrounds, transparent on dark. Set "transparent" to suppress.
#' @param highlight A list of highlight groups. Each group is a list with:
#'   \describe{
#'     \item{symbols}{Character vector of element symbols to highlight.}
#'     \item{color}{Fill color for highlighted tiles.}
#'     \item{label}{Optional legend label for this group.}
#'   }
#'   Example: \code{list(list(symbols = c("Li","Co"), color = "#2166ac",
#'   label = "Battery metals"))}
#' @param legend_title Character. Legend title. Defaults to value_col.
#' @param show_atomic_number Logical. Show atomic numbers in top-left of tile.
#'   Default FALSE.
#' @param base_size Numeric. Base font size in pt. Default 8.
#' @param groups Integer vector of length 2. Range of IUPAC groups (columns)
#'   to display, e.g. \code{c(3, 12)} for transition metals only. Default NULL
#'   shows all groups.
#' @param periods Integer vector of length 2. Range of periods (rows 1-7) to
#'   display, e.g. \code{c(4, 6)} for periods 4 to 6. Default NULL shows all
#'   periods. Note: lanthanides and actinides are controlled separately via
#'   \code{lanthanides} and \code{actinides}.
#' @param lanthanides Logical. Show the lanthanide row. Default TRUE.
#' @param actinides Logical. Show the actinide row. Default TRUE.
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
#'
#' ggPSE(highlight = list(
#'   list(symbols = c("Li", "Co", "Ni"), color = "#2166ac", label = "Battery"),
#'   list(symbols = c("Nd", "Dy", "Tb"), color = "#e63946", label = "Magnets")
#' ))
#'
#' # Show only transition metals (groups 3-12, periods 4-6)
#' ggPSE(groups = c(3, 12), periods = c(4, 6), lanthanides = FALSE, actinides = FALSE)
ggPSE <- function(
    data               = NULL,
    value_col          = NULL,
    symbol_col         = "symbol",
    label_value        = TRUE,
    value_digits       = 2,
    color_low          = "#fdf0f2",
    color_high         = "#9a031e",
    color_na           = "#f0f0f0",
    tile_border        = NULL,
    highlight          = NULL,
    legend_title       = NULL,
    show_atomic_number = FALSE,
    base_size          = 10,
    groups             = NULL,
    periods            = NULL,
    lanthanides        = TRUE,
    actinides          = TRUE
) {
  grid <- .ggpse_elements()

  # ── Subset grid by groups / periods / lanthanides / actinides ────────────────
  grid <- .filter_grid(grid, groups, periods, lanthanides, actinides) #helper in zzz.R
  
  #error catching
  if (!is.null(data)) {
    if (!symbol_col %in% names(data))
      stop(sprintf("Column '%s' not found in data. Set symbol_col to the correct column name.", symbol_col))
    if (!is.null(value_col) && !value_col %in% names(data))
      stop(sprintf("Column '%s' not found in data. Set value_col to the correct column name.", value_col))
    cols_keep <- unique(c(symbol_col, value_col))
    data      <- data[, cols_keep, drop = FALSE]
    names(data)[names(data) == symbol_col] <- "symbol"
    grid <- merge(grid, data, by = "symbol", all.x = TRUE)
  }
  
  legend_title <- legend_title %||% value_col %||% ""
  fill_col     <- if (!is.null(value_col) && value_col %in% names(grid)) value_col else NULL
  
  # ── Bake highlight colors into grid ──────────────────────────────────────────
  grid$highlight_label <- NA_character_
  
  if (!is.null(highlight)) {
    for (grp in highlight) {
      idx <- grid$symbol %in% grp$symbols
      grid$highlight_label[idx] <- grp$label %||% grp$color
    }
  }
  
  # ── Text contrast color ───────────────────────────────────────────────────────
  # helper from zzz.R
  if (!is.null(fill_col) && fill_col %in% names(grid)) {
    val <- grid[[fill_col]]
    nv  <- .normalize_values(val, color_low, color_high, color_na)
    norm_val        <- nv$norm_val
    grid$text_color <- nv$text_color
  } else if (!is.null(highlight)) {
    hi_colors <- rep(color_na, nrow(grid))
    for (grp in highlight) {
      hi_colors[grid$symbol %in% grp$symbols] <- grp$color
    }
    grid$text_color <- vapply(hi_colors, .contrast_color, character(1))
  } else {
    grid$text_color <- "grey20" #standard text color
  }
  # ── Tile border ───────────────────────────────────────────────────────────────
  tile_border <- tile_border %||% "transparent"
  
  # ── Build tile layer ──────────────────────────────────────────────────────────
  p <- ggplot2::ggplot(
    grid,
    ggplot2::aes(
      x = .data[["col"]],
      y = -.data[["row"]]
    )
  )
  
  if (!is.null(highlight)) {
    # Highlight mode: discrete fill mapped to group labels
    hi_values <- stats::setNames(
      vapply(highlight, function(g) g$color, character(1)),
      vapply(highlight, function(g) g$label %||% g$color, character(1))
    )
    p <- p +
      ggplot2::geom_tile(
        ggplot2::aes(fill = .data[["highlight_label"]]),
        color     = tile_border,
        width     = 0.92,
        height    = 0.92,
        linewidth = 0.3
      ) +
      ggplot2::scale_fill_manual(
        values   = hi_values,
        na.value = color_na,
        name     = NULL,
        breaks   = names(hi_values),
      )
  } else if (!is.null(fill_col)) {
    # Gradient mode
    p <- p +
      ggplot2::geom_tile(
        ggplot2::aes(fill = .data[[fill_col]]),
        color     = tile_border,
        width     = 0.92,
        height    = 0.92,
        linewidth = 0.3
      ) +
      ggplot2::scale_fill_gradient(
        low      = color_low,
        high     = color_high,
        na.value = color_na,
        name     = legend_title
      )
  } else {
    # Blank table
    p <- p +
      ggplot2::geom_tile(
        fill      = color_na,
        color     = tile_border,
        width     = 0.92,
        height    = 0.92,
        linewidth = 0.3
      )
  }
  
  # ── Symbol text ───────────────────────────────────────────────────────────────
  p <- p +
    ggplot2::geom_text(
      ggplot2::aes(label = .data[["symbol"]], color = .data[["text_color"]]),
      fontface = "bold",
      size     = base_size * 0.40,
      nudge_y  = -0.08,
      vjust    = if (label_value && !is.null(fill_col)) 0.15 else 0.5
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
  
  if (label_value && !is.null(fill_col)) {
    p <- p +
      ggplot2::geom_text(
        ggplot2::aes(
          y     = .data[["row"]] * -1 - 0.25,
          label = ifelse(
            is.na(.data[[fill_col]]), "",
            formatC(.data[[fill_col]], digits = value_digits, format = "f")
          ),
          color = .data[["text_color"]]
        ),
        size = base_size * 0.20
      )
  }
  
  # ── Scales and theme ──────────────────────────────────────────────────────────
  p <- p +
    ggplot2::scale_color_identity() +
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
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
#' @param highlight Elements to colour by category. Either
#'   \itemize{
#'     \item a \emph{named list of symbol vectors}, e.g.
#'       \code{list("Alkali metals" = c("Li", "Na", "K"), Halogens = c("F", "Cl"))}.
#'       The names become the legend labels and the list order the legend
#'       order. \code{split(df$symbol, df$category)} gives such a list; use a
#'       factor for \code{category} to control the order. Colours come from
#'       \code{highlight_colors}.
#'     \item or a list of groups, each a list with
#'       \code{symbols} (character vector of element symbols), \code{color}
#'       (fill color) and an optional \code{label} (legend label), e.g.
#'       \code{list(list(symbols = c("Li","Co"), color = "#2166ac",
#'       label = "Battery metals"))}.
#'   }
#'   Unknown symbols and elements listed in more than one group give a warning
#'   (in that case the last group wins).
#' @param highlight_colors Colours for a named-list \code{highlight}: either a
#'   vector named by group (order does not matter, extra names are ignored) or
#'   an unnamed vector matched by position. Any R colour is accepted. Default
#'   \code{NULL} uses a colour-blind-safe palette (Okabe-Ito, extended beyond 8
#'   groups). Ignored, with a warning, if the groups carry their own
#'   \code{color}.
#' @param legend_title Character. Legend title. Defaults to value_col; for
#'   \code{highlight} groups there is no title unless you set one.
#' @param show_atomic_number Logical. Show atomic numbers inside the tile.
#'   Default FALSE. See \code{number_position} for where it is drawn.
#' @param base_size Numeric. Base font size in pt. Default 10.
#' @param groups Integer vector of length 2. Range of IUPAC groups (columns)
#'   to display, e.g. \code{c(3, 12)} for transition metals only. Default NULL
#'   shows all groups.
#' @param periods Integer vector of length 2. Range of periods (rows 1-7) to
#'   display, e.g. \code{c(4, 6)} for periods 4 to 6. Default NULL shows all
#'   periods. Note: lanthanides and actinides are controlled separately via
#'   \code{lanthanides} and \code{actinides}.
#' @param lanthanides Logical. Show the lanthanide row. Default TRUE.
#' @param actinides Logical. Show the actinide row. Default TRUE.
#' @param symbol_position Where the element symbol is drawn inside the tile:
#'   \code{"center"} (default), \code{"top"}, \code{"bottom"}, \code{"left"}
#'   or \code{"right"}. If a value label is shown (\code{label_value = TRUE}),
#'   it is placed on the opposite side for \code{"top"} / \code{"bottom"}, and
#'   stacked under the symbol for \code{"left"} / \code{"right"}.
#' @param symbol_size Size of the element symbol in ggplot2 text units (mm,
#'   as in the \code{size} argument of \code{geom_text()}). Default \code{NULL}
#'   scales with \code{base_size} (\code{base_size * 0.4}). Only the symbol is
#'   affected; the value and atomic number keep scaling with \code{base_size}.
#'   Large symbols need more room, see \code{symbol_position}.
#' @param label_na Logical. Draw symbols (and atomic numbers / values) on tiles
#'   without data? Default \code{TRUE}. With \code{FALSE}, tiles that have no
#'   value (or are not part of a \code{highlight} group) stay blank, which is
#'   useful when only a subset of elements is covered by your data. Ignored
#'   when neither \code{value_col} nor \code{highlight} is given.
#' @param text_color A single colour used for all tile text instead of the
#'   automatic black/white contrast colour. Default \code{NULL}. Useful when the
#'   fill scale is replaced afterwards (e.g. with
#'   \code{scale_fill_gradient2()}), because the automatic colour is derived
#'   from \code{color_low} / \code{color_high}.
#' @param symbol_nudge,number_nudge Numeric. Vertical shift of the symbol /
#'   atomic number in tile units (a tile is 0.92 high; positive moves up),
#'   added to the position set by \code{symbol_position} /
#'   \code{number_position}. Default \code{0}. The value label is not moved,
#'   and the overlap warning does not take the nudge into account.
#' @param number_position Where the atomic number is drawn when
#'   \code{show_atomic_number = TRUE}: \code{"top-left"} (default),
#'   \code{"top"}, \code{"top-right"}, \code{"left"}, \code{"right"},
#'   \code{"bottom-left"}, \code{"bottom"} or \code{"bottom-right"}. A
#'   warning is given if it overlaps with the symbol or value text.
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
#' # Categories from a named list, with your own colours
#' ggPSE(highlight = list(Alkali = c("Li", "Na", "K"), Halogens = c("F", "Cl", "Br")),
#'       highlight_colors = c(Alkali = "firebrick", Halogens = "steelblue"),
#'       legend_title = "Group")
#'
#' # Show only transition metals (groups 3-12, periods 4-6)
#' ggPSE(groups = c(3, 12), periods = c(4, 6), lanthanides = FALSE, actinides = FALSE)
#'
#' # Symbol at the top, atomic number in the bottom-right corner
#' ggPSE(battery, value_col = "importance",
#'       symbol_position = "top", show_atomic_number = TRUE,
#'       number_position = "bottom-right")
#'
#' # Smaller symbols independent of base_size
#' ggPSE(battery, value_col = "importance", symbol_size = 3)
#'
#' # Only label the elements that have data, with one fixed text colour
#' ggPSE(battery, value_col = "importance", label_na = FALSE, text_color = "grey15")
#'
#' # Fine-tune: symbol slightly above its position
#' ggPSE(battery, value_col = "importance", symbol_position = "top",
#'       symbol_nudge = 0.05)
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
    actinides          = TRUE,
    symbol_position    = "center",
    number_position    = "top-left",
    symbol_size        = NULL,
    label_na           = TRUE,
    text_color         = NULL,
    symbol_nudge       = 0,
    number_nudge       = 0,
    highlight_colors = NULL
) {
  symbol_position <- match.arg(symbol_position, .symbol_positions)
  number_position <- match.arg(number_position, .number_positions)
  .check_text_color(text_color)
  .check_nudge(symbol_nudge, "symbol_nudge")
  .check_nudge(number_nudge, "number_nudge")
  highlight <- .normalize_highlight(highlight, highlight_colors)

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
  
  highlight_title <- legend_title            # NULL = no title for highlight groups
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
  # fixed text colour overrides the automatic contrast colour
  if (!is.null(text_color)) grid$text_color <- text_color
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
        name     = highlight_title,
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
  
  # ── Text layers (symbol, atomic number, value) ───────────────────────────────
  # layout logic lives in zzz.R so ggPSE() and ggPSE_interactive() stay in sync
  .check_text_collision(symbol_position, number_position, show_atomic_number,
                        label_value && !is.null(fill_col))
  p <- .add_tile_text(
    p,
    symbol_position    = symbol_position,
    number_position    = number_position,
    show_atomic_number = show_atomic_number,
    fill_col           = fill_col,
    label_value        = label_value,
    value_digits       = value_digits,
    base_size          = base_size,
    symbol_size        = symbol_size,
    hide               = if (!label_na) .na_mask(grid, fill_col, highlight),
    symbol_nudge       = symbol_nudge,
    number_nudge       = number_nudge
  )

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
#' Plot a periodic table with a continuous value overlay
#'
#' The core plotting function of ggPSE. Returns a ggplot2 object that can be
#' further modified.
#'
#' @param data A data frame with the element symbols (case-sensitive, e.g.
#'   \code{"Cl"}) and the value column. Rows may repeat for an element (e.g. one
#'   row per country) as long as they agree on the value; different values for
#'   the same element, unknown or \code{NA} symbols and non-numeric values give an
#'   error. If \code{NULL}, a blank table using the NA color is drawn.
#' @param value_col Character. Column name in data to map to fill color.
#' @param symbol_col Character. Column in data containing element symbols.
#'   Default "symbol".
#' @param label_value Logical. Print numeric values inside tiles. Default TRUE.
#' @param value_digits Integer. Decimal places for displayed values. Default 2.
#' @param color_low,color_high Colors of the low and high end of the gradient.
#'   Defaults \code{"#fdf0f2"} and \code{"#9a031e"}. Shorthand for
#'   \code{colors = c(color_low, color_high)}.
#' @param colors Character vector of two or more colors for the gradient, from
#'   low to high, evenly spaced. Overrides \code{color_low} and
#'   \code{color_high}. The text colour of every tile is chosen against the
#'   colour the tile really gets, so you do not have to replace the fill scale
#'   afterwards.
#' @param midpoint Numeric. For diverging scales: the value that gets the middle
#'   one of (at least three) \code{colors}, e.g. \code{midpoint = 0}.
#' @param limits Numeric vector \code{c(lower, upper)}: the values that get the
#'   first and the last color. Fix it to keep colours (and the legend) identical
#'   between plots, e.g. for the frames of an animation; without it the range of
#'   each plot's own data is used. Values outside the limits get the end colors.
#' @param breaks,labels Legend breaks (values) and their labels, as in
#'   \code{ggplot2::scale_fill_gradientn()}.
#' @param color_na Hex color for elements with no data. Default "#f0f0f0".
#' @param tile_border Color for tile borders. If NULL (default) no border is
#'   drawn (\code{"transparent"}). Set a color such as \code{"white"} or
#'   \code{"grey30"} to draw borders.
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
#' @param text_color Colour of the tile text instead of the automatic
#'   black/white contrast colour. Either a single colour for all tiles, or the
#'   name of a column in \code{data} with one colour per element (\code{NA} = automatic
#'   colour for that element), e.g. \code{ifelse(x > 200, "white", "grey15")}.
#'   Default \code{NULL}.
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
#'
#' # Own palette with a fixed range (same colours in every plot / animation frame)
#' ggPSE(battery, value_col = "importance",
#'       colors = c("#1f4ec9", "#e0a940", "#2ca02c"), limits = c(0, 1))
#'
#' # Diverging scale around zero
#' ggPSE(data.frame(symbol = c("Li", "Fe", "Cu"), E = c(-3.04, -0.44, 0.34)),
#'       value_col = "E", colors = c("#8fa6cb", "#f5f0e6", "#FF5A5F"), midpoint = 0)
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
    highlight_colors = NULL,
    colors          = NULL,
    midpoint        = NULL,
    limits          = NULL,
    breaks          = ggplot2::waiver(),
    labels          = ggplot2::waiver()
) {
  symbol_position <- match.arg(symbol_position, .symbol_positions)
  number_position <- match.arg(number_position, .number_positions)
  tc_col <- .text_color_column(text_color, data)      # text_color can name a column of `data`
  if (is.null(tc_col)) .check_text_color(text_color)
  .check_fill_args(colors, color_low, color_high, midpoint, limits)
  .check_nudge(symbol_nudge, "symbol_nudge")
  .check_nudge(number_nudge, "number_nudge")
  highlight <- .normalize_highlight(highlight, highlight_colors)

  grid <- .ggpse_elements()

  # ── Subset grid by groups / periods / lanthanides / actinides ────────────────
  grid <- .filter_grid(grid, groups, periods, lanthanides, actinides) #helper in zzz.R
  
  # validate the data (element symbols, one row per element, numeric values)
  # and join it onto the tiles; helper in zzz.R
  data_value_col <- value_col
  if (!is.null(data)) {
    joined         <- .join_element_data(grid, data, symbol_col, value_col,
                                         fn = "ggPSE()", category_hint = TRUE,
                                         text_col = tc_col)
    grid           <- joined$grid
    data_value_col <- joined$value_col
  }
  
  highlight_title <- legend_title            # NULL = no title for highlight groups
  legend_title <- legend_title %||% value_col %||% ""
  fill_col     <- if (!is.null(data_value_col) && data_value_col %in% names(grid)) data_value_col else NULL
  
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
  # one fill scale for the plot and for the colour estimate: the text colour is
  # chosen against the colour each tile really gets (also for tiles without data)
  make_fill_scale <- function(name)
    .fill_scale(colors, color_low, color_high, midpoint, limits, breaks, labels,
                color_na, name)
  if (!is.null(fill_col) && fill_col %in% names(grid)) {
    tile_fill       <- .tile_fill_colors(grid, fill_col, make_fill_scale(ggplot2::waiver()))
    grid$text_color <- vapply(tile_fill, .contrast_color, character(1))
  } else if (!is.null(highlight)) {
    hi_colors <- rep(color_na, nrow(grid))
    for (grp in highlight) {
      hi_colors[grid$symbol %in% grp$symbols] <- grp$color
    }
    grid$text_color <- vapply(hi_colors, .contrast_color, character(1))
  } else {
    grid$text_color <- "grey20" #standard text color
  }
  # a given text colour overrides the automatic contrast colour: either one
  # colour for all tiles, or a column with one colour per element (NA = automatic)
  if (!is.null(tc_col)) {
    user_tc         <- as.character(grid$.pse_text_color)
    grid$text_color <- ifelse(is.na(user_tc), grid$text_color, user_tc)
    grid$.pse_text_color <- NULL
  } else if (!is.null(text_color)) {
    grid$text_color <- text_color
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
      make_fill_scale(legend_title)
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
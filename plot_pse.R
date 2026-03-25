# plot_pse.R
# A clean ggplot2-based periodic table visualization function
# Dependencies: ggplot2, dplyr, periodicdata (suggested)

#' Plot a Periodic System of Elements with custom value overlay
#'
#' @param data A data frame with at least a column matching elements by symbol or atomic number.
#'   Must contain element symbols in a column named 'symbol' (or specify via `symbol_col`).
#'   If NULL, plots a blank PSE using built-in positions.
#' @param value_col Character. Name of the column in `data` containing values to visualize.
#' @param symbol_col Character. Name of the column in `data` containing element symbols. Default "symbol".
#' @param label_value Logical. Whether to print numeric values inside tiles. Default TRUE.
#' @param value_digits Integer. Number of decimal places for displayed values. Default 2.
#' @param color_low Character. Hex color for the low end of the gradient. Default "#ffffff".
#' @param color_high Character. Hex color for the high end of the gradient. Default "#9a031e".
#' @param color_na Character. Hex color for elements with no data. Default "#eeeeee".
#' @param legend_title Character. Title for the color legend. Default is `value_col`.
#' @param show_atomic_number Logical. Whether to display atomic numbers. Default TRUE.
#' @param tile_size Numeric. Controls spacing between tiles. Default 0.9.
#' @param base_size Numeric. Base font size. Default 8.
#'
#' @return A ggplot2 object.
#' @export
#'
#' @examples
#' # Plot with random values for demonstration
#' library(ggplot2)
#' demo_data <- data.frame(
#'   symbol = c("H", "C", "N", "O", "Fe", "Cu", "Au"),
#'   affinity = c(0.75, 0.15, 0.30, 0.90, 0.45, 0.60, 0.80)
#' )
#' plot_pse(demo_data, value_col = "affinity", legend_title = "Affinity")

plot_pse <- function(
    data         = NULL,
    value_col    = NULL,
    symbol_col   = "symbol",
    label_value  = TRUE,
    value_digits = 2,
    color_low    = "#ffffff",
    color_high   = "#9a031e",
    color_na     = "#eeeeee",
    legend_title = NULL,
    show_atomic_number = TRUE,
    tile_size    = 0.9,
    base_size    = 8
) {

  # ── 1. Built-in element grid positions ─────────────────────────────────────
  # Standard 18-column IUPAC layout. Replace this block with periodicdata::elements
  # once that package is declared as a dependency.
  element_grid <- .pse_element_positions()

  # ── 2. Merge user data ──────────────────────────────────────────────────────
  if (!is.null(data)) {
    if (!symbol_col %in% names(data)) {
      stop(paste0("Column '", symbol_col, "' not found in data. ",
                  "Specify the correct column name via `symbol_col`."))
    }
    if (!is.null(value_col) && !value_col %in% names(data)) {
      stop(paste0("Column '", value_col, "' not found in data."))
    }

    data <- data[, c(symbol_col, if (!is.null(value_col)) value_col), drop = FALSE]
    names(data)[1] <- "symbol"

    element_grid <- merge(element_grid, data, by = "symbol", all.x = TRUE)
  }

  # ── 3. Legend title fallback ────────────────────────────────────────────────
  if (is.null(legend_title)) {
    legend_title <- if (!is.null(value_col)) value_col else ""
  }

  # ── 4. Build fill aesthetic ─────────────────────────────────────────────────
  fill_col <- if (!is.null(value_col) && value_col %in% names(element_grid)) {
    value_col
  } else {
    NULL
  }

  # ── 5. Construct plot ───────────────────────────────────────────────────────
  p <- ggplot2::ggplot(
    element_grid,
    ggplot2::aes(
      x = col,
      y = -row,  # invert so period 1 is at the top
      fill = if (!is.null(fill_col)) .data[[fill_col]] else NA_real_
    )
  ) +

    # Tiles
    ggplot2::geom_tile(
      color  = "white",
      width  = tile_size,
      height = tile_size,
      linewidth = 0.4
    ) +

    # Element symbol (centered, bold)
    ggplot2::geom_text(
      ggplot2::aes(label = symbol),
      fontface = "bold",
      size     = base_size * 0.4,
      vjust    = if (label_value && !is.null(fill_col)) 0.2 else 0.5
    ) +

    # Atomic number (top-left of tile)
    { if (show_atomic_number)
        ggplot2::geom_text(
          ggplot2::aes(
            x     = col - tile_size / 2 + 0.08,
            label = atomic_number
          ),
          hjust    = 0,
          vjust    = 1,
          size     = base_size * 0.22,
          color    = "grey40",
          fontface = "plain"
        )
    } +

    # Value label (below symbol)
    { if (label_value && !is.null(fill_col))
        ggplot2::geom_text(
          ggplot2::aes(
            label = ifelse(
              is.na(.data[[fill_col]]),
              "",
              formatC(.data[[fill_col]], digits = value_digits, format = "f")
            ),
            y = -row - 0.28
          ),
          size  = base_size * 0.22,
          color = "grey20"
        )
    } +

    # Color scale
    { if (!is.null(fill_col))
        ggplot2::scale_fill_gradient(
          low      = color_low,
          high     = color_high,
          na.value = color_na,
          name     = legend_title
        )
      else
        ggplot2::scale_fill_continuous(na.value = color_na, guide = "none")
    } +

    # Fixed coordinates so tiles are square
    ggplot2::coord_fixed() +

    # Minimal theme — strip all axis chrome
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


# ── Internal: element grid positions ──────────────────────────────────────────
# Returns a data frame with symbol, name, atomic_number, period (row), group (col).
# This is the minimal data needed for layout. Richer property data should come
# from periodicdata::elements or a user-supplied data frame.
.pse_element_positions <- function() {
  # Standard 18-column IUPAC layout
  # Lanthanides: row 9, cols 3-17 (displayed below main table with gap)
  # Actinides:   row 10, cols 3-17
  data.frame(
    symbol = c(
      "H",                                                                                  "He",
      "Li","Be",                                              "B", "C", "N", "O", "F", "Ne",
      "Na","Mg",                                              "Al","Si","P", "S", "Cl","Ar",
      "K", "Ca","Sc","Ti","V", "Cr","Mn","Fe","Co","Ni","Cu","Zn","Ga","Ge","As","Se","Br","Kr",
      "Rb","Sr","Y", "Zr","Nb","Mo","Tc","Ru","Rh","Pd","Ag","Cd","In","Sn","Sb","Te","I", "Xe",
      "Cs","Ba","La","Hf","Ta","W", "Re","Os","Ir","Pt","Au","Hg","Tl","Pb","Bi","Po","At","Rn",
      "Fr","Ra","Ac","Rf","Db","Sg","Bh","Hs","Mt","Ds","Rg","Cn","Nh","Fl","Mc","Lv","Ts","Og",
      # Lanthanides (row 9, offset cols 3-17)
      "Ce","Pr","Nd","Pm","Sm","Eu","Gd","Tb","Dy","Ho","Er","Tm","Yb","Lu",
      # Actinides (row 10, offset cols 3-17)
      "Th","Pa","U", "Np","Pu","Am","Cm","Bk","Cf","Es","Fm","Md","No","Lr"
    ),
    atomic_number = c(
       1,                                                                                    2,
       3,  4,                                               5,  6,  7,  8,  9, 10,
      11, 12,                                              13, 14, 15, 16, 17, 18,
      19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36,
      37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54,
      55, 56, 57, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86,
      87, 88, 89,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,
      # Lanthanides
      58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71,
      # Actinides
      90, 91, 92, 93, 94, 95, 96, 97, 98, 99,100,101,102,103
    ),
    col = c(
       1,                                                                                   18,
       1,  2,                                              13, 14, 15, 16, 17, 18,
       1,  2,                                              13, 14, 15, 16, 17, 18,
       1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
       1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
       1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
       1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
      # Lanthanides cols 4-17
       4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17,
      # Actinides cols 4-17
       4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17
    ),
    row = c(
      1,                                                                                    1,
      2,  2,                                               2,  2,  2,  2,  2,  2,
      3,  3,                                               3,  3,  3,  3,  3,  3,
      4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
      5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,
      6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,
      7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,
      # Lanthanides row 9 (gap row 8 is empty = visual separation)
      9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,
      # Actinides row 10
     10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
    ),
    stringsAsFactors = FALSE
  )
}

#' Interactive periodic table with hover tooltips
#'
#' Wraps [ggPSE()] with \pkg{ggiraph} interactivity. Each tile becomes
#' hoverable, showing a tooltip with element name, atomic number, and any
#' additional columns you specify. Returns a \code{girafe} object that
#' renders as an interactive SVG in HTML documents, Shiny apps, and
#' RStudio Viewer.
#'
#' Requires the \pkg{ggiraph} package. Install with:
#' \code{install.packages("ggiraph")}
#'
#' @inheritParams ggPSE
#' @param tooltip_cols Character vector of column names from \code{data} to
#'   include in the tooltip. Element name and atomic number are always shown.
#'   Default \code{NULL} shows only name, atomic number, and \code{value_col}
#'   if supplied.
#' @param tooltip_digits Integer. Decimal places for numeric tooltip values.
#'   Default \code{3}.
#' @param hover_fill Character. Tile fill color on hover. Default
#'   \code{"#ffd700"} (gold).
#' @param hover_stroke Character. Tile border color on hover. Default
#'   \code{"#333333"}.
#' @param width_svg Numeric. Width of the SVG output in inches. Default
#'   \code{12}.
#' @param height_svg Numeric. Height of the SVG output in inches. Default
#'   \code{5}.
#'
#' @return A \code{girafe} object (interactive SVG).
#' @export
#'
#' @examples
#' \dontrun{
#' battery <- data.frame(
#'   symbol     = c("Li", "Co", "Ni", "Mn", "Fe"),
#'   importance = c(0.95, 0.88, 0.75, 0.60, 0.45)
#' )
#' ggPSE_interactive(battery,
#'                   value_col    = "importance",
#'                   legend_title = "Battery relevance")
#'
#' # Show extra columns in tooltip
#' data(ggpse_elements)
#' ggPSE_interactive(ggpse_elements,
#'                   value_col    = "electronegativity",
#'                   tooltip_cols = c("name", "atomic_weight",
#'                                    "electronegativity", "block"),
#'                   legend_title = "Electronegativity (Pauling)")
#' }
ggPSE_interactive <- function(
    data          = NULL,
    value_col     = NULL,
    symbol_col    = "symbol",
    label_value   = TRUE,
    value_digits  = 2,
    color_low     = "#fdf0f2",
    color_high    = "#9a031e",
    color_na      = "#f0f0f0",
    tile_border   = NULL,
    highlight     = NULL,
    legend_title  = NULL,
    show_atomic_number = FALSE,
    base_size     = 10,
    groups        = NULL,
    periods       = NULL,
    lanthanides   = TRUE,
    actinides     = TRUE,
    tooltip_cols  = NULL,
    tooltip_digits = 3,
    hover_fill    = "#ffd700",
    hover_stroke  = "#333333",
    width_svg     = 12,
    height_svg    = 5
) {
  if (!requireNamespace("ggiraph", quietly = TRUE))
    stop("Package 'ggiraph' is required for ggPSE_interactive(). ",
         "Install it with: install.packages(\"ggiraph\")",
         call. = FALSE)

  # ── Build the grid ────────────────────────────────────────────────────────────
  grid <- .ggpse_elements()

  if (!is.null(groups)) {
    if (length(groups) != 2 || !is.numeric(groups))
      stop("'groups' must be a numeric vector of length 2, e.g. c(3, 12).")
    grid <- grid[grid$col >= min(groups) & grid$col <= max(groups), ]
  }

  if (!is.null(periods)) {
    if (length(periods) != 2 || !is.numeric(periods))
      stop("'periods' must be a numeric vector of length 2, e.g. c(4, 6).")
    grid <- grid[grid$row > 7 | (grid$row >= min(periods) & grid$row <= max(periods)), ]
  }

  if (!lanthanides) grid <- grid[grid$row != 9L, ]
  if (!actinides)   grid <- grid[grid$row != 10L, ]

  # ── Merge user data ───────────────────────────────────────────────────────────
  if (!is.null(data)) {
    if (!symbol_col %in% names(data))
      stop(sprintf("Column '%s' not found in data.", symbol_col))
    if (!is.null(value_col) && !value_col %in% names(data))
      stop(sprintf("Column '%s' not found in data.", value_col))
    names(data)[names(data) == symbol_col] <- "symbol"
    
    # Drop columns from data that already exist in grid to avoid .x/.y conflicts
    grid_cols <- names(grid)
    overlap   <- setdiff(intersect(names(data), grid_cols), "symbol")
    data      <- data[, !names(data) %in% overlap, drop = FALSE]
    
    grid <- merge(grid, data, by = "symbol", all.x = TRUE)
  }

  # reset row names after merge so indexing is clean
  rownames(grid) <- NULL

  # ── Resolve tooltip columns ───────────────────────────────────────────────────
  has_name <- "name" %in% names(grid)

  if (is.null(tooltip_cols)) {
    tooltip_cols <- c(
      if (has_name) "name",
      if (!is.null(value_col) && value_col %in% names(grid)) value_col
    )
  } else {
    missing_cols <- setdiff(tooltip_cols, names(grid))
    if (length(missing_cols) > 0)
      warning("Tooltip columns not found and will be skipped: ",
              paste(missing_cols, collapse = ", "))
    tooltip_cols <- intersect(tooltip_cols, names(grid))
  }

  # ── Build tooltip string vectorised ──────────────────────────────────────────
  # Start with symbol + atomic number for every row
  tt <- paste0("<b>", grid$symbol, "</b> (Z = ", grid$atomic_number, ")")

  # Append each requested column
  for (col in tooltip_cols) {
    vals <- grid[[col]]
    num_vals <- suppressWarnings(as.numeric(vals))
    formatted <- ifelse(
      is.na(vals),
      "",
      ifelse(
        !is.na(num_vals),
        formatC(num_vals, digits = tooltip_digits, format = "f"),
        as.character(vals)
      )
    )
    # Only append line where value is not empty
    tt <- ifelse(
      formatted == "",
      tt,
      paste0(tt, "<br/>", col, ": ", formatted)
    )
  }

  grid$tooltip <- tt

  # ── Build highlight / fill logic ──────────────────────────────────────────────
  legend_title <- legend_title %||% value_col %||% ""
  fill_col     <- if (!is.null(value_col) && value_col %in% names(grid)) value_col else NULL

  grid$highlight_label <- NA_character_
  if (!is.null(highlight)) {
    for (grp in highlight) {
      idx <- grid$symbol %in% grp$symbols
      grid$highlight_label[idx] <- grp$label %||% grp$color
    }
  }

  # ── Text contrast ─────────────────────────────────────────────────────────────
  if (!is.null(fill_col) && fill_col %in% names(grid)) {
    val     <- grid[[fill_col]]
    val_min <- min(val, na.rm = TRUE)
    val_max <- max(val, na.rm = TRUE)
    norm_val <- if (val_max == val_min) {
      ifelse(is.na(val), 0.5, 0.5)
    } else {
      ifelse(is.na(val), 0.5, (val - val_min) / (val_max - val_min))
    }
    grid$text_color <- vapply(norm_val, function(ti)
      .contrast_color(.interp_hex(color_low, color_high, ti)), character(1))
  } else if (!is.null(highlight)) {
    hi_colors <- rep(color_na, nrow(grid))
    for (grp in highlight) hi_colors[grid$symbol %in% grp$symbols] <- grp$color
    grid$text_color <- vapply(hi_colors, .contrast_color, character(1))
  } else {
    grid$text_color <- "grey20"
  }

  tile_border <- tile_border %||% "transparent"

  # ── Build interactive plot ────────────────────────────────────────────────────
  p <- ggplot2::ggplot(
    grid,
    ggplot2::aes(x = .data[["col"]], y = -.data[["row"]])
  )

  if (!is.null(highlight)) {
    hi_values <- stats::setNames(
      vapply(highlight, function(g) g$color, character(1)),
      vapply(highlight, function(g) g$label %||% g$color, character(1))
    )
    p <- p +
      ggiraph::geom_tile_interactive(
        ggplot2::aes(
          fill    = .data[["highlight_label"]],
          tooltip = .data[["tooltip"]],
          data_id = .data[["symbol"]]
        ),
        color = tile_border, width = 0.92, height = 0.92, linewidth = 0.3
      ) +
      ggplot2::scale_fill_manual(
        values = hi_values, na.value = color_na,
        name = NULL, breaks = names(hi_values)
      )
  } else if (!is.null(fill_col)) {
    p <- p +
      ggiraph::geom_tile_interactive(
        ggplot2::aes(
          fill    = .data[[fill_col]],
          tooltip = .data[["tooltip"]],
          data_id = .data[["symbol"]]
        ),
        color = tile_border, width = 0.92, height = 0.92, linewidth = 0.3
      ) +
      ggplot2::scale_fill_gradient(
        low = color_low, high = color_high,
        na.value = color_na, name = legend_title
      )
  } else {
    p <- p +
      ggiraph::geom_tile_interactive(
        ggplot2::aes(
          tooltip = .data[["tooltip"]],
          data_id = .data[["symbol"]]
        ),
        fill = color_na, color = tile_border,
        width = 0.92, height = 0.92, linewidth = 0.3
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
        hjust = 0, vjust = 1,
        size  = base_size * 0.22,
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

  # ── Wrap in girafe ────────────────────────────────────────────────────────────
  ggiraph::girafe(
    ggobj      = p,
    width_svg  = width_svg,
    height_svg = height_svg,
    options    = list(
      ggiraph::opts_hover(
        css = paste0(
          "fill:", hover_fill, ";",
          "stroke:", hover_stroke, ";",
          "stroke-width:1.5px;",
          "cursor:pointer;"
        )
      ),
      ggiraph::opts_tooltip(
        css = paste0(
          "background-color:white;",
          "border:1px solid #cccccc;",
          "border-radius:4px;",
          "padding:6px 10px;",
          "font-size:12px;",
          "font-family:sans-serif;",
          "box-shadow:2px 2px 4px rgba(0,0,0,0.15);"
        ),
        use_fill = FALSE
      ),
      ggiraph::opts_sizing(rescale = TRUE)
    )
  )
}

#' Plot a single period, group, or f-block row with a trend line
#'
#' Extracts a single period (row), group (column), lanthanide row, or actinide
#' row from the periodic table and combines it with a line plot of a numeric
#' property using \pkg{patchwork}. Useful for visualising periodic trends.
#'
#' Exactly one of \code{period}, \code{group}, \code{lanthanides}, or
#' \code{actinides} must be supplied.
#'
#' For periods 1-3, the d-block gap is compressed and indicated with a dashed
#' vertical line in the line plot. Lanthanides and actinides are never included
#' in period strips - use \code{lanthanides = TRUE} or \code{actinides = TRUE}
#' to plot those rows separately.
#'
#' @param data A data frame containing element data.
#' @param value_col Character. Column name of the numeric property to plot.
#' @param period Integer. Period 1-7 to display. Mutually exclusive with
#'   \code{group}, \code{lanthanides}, \code{actinides}.
#' @param group Integer. IUPAC group 1-18 to display. Mutually exclusive with
#'   \code{period}, \code{lanthanides}, \code{actinides}.
#' @param lanthanides Logical. Plot the lanthanide row (La-Lu).
#'   Default \code{FALSE}.
#' @param actinides Logical. Plot the actinide row (Ac-Lr).
#'   Default \code{FALSE}.
#' @param symbol_col Character. Column containing element symbols.
#'   Default \code{"symbol"}.
#' @param position Character. Position of the line plot relative to the tile
#'   strip. For periods/lanthanides/actinides: \code{"below"} (default) or
#'   \code{"above"}. For groups: \code{"right"} (default) or \code{"left"}.
#' @param color_high Character. High end fill color. Default \code{"#9a031e"}.
#' @param color_low Character. Low end fill color. Default \code{"#fdf0f2"}.
#' @param color_na Character. NA tile fill color. Default \code{"#f0f0f0"}.
#' @param line_color Character. Trend line color. Default \code{"#2166ac"}.
#' @param point_color Character. Point color. Default \code{"#2166ac"}.
#' @param legend_title Character. Legend title. Defaults to \code{value_col}.
#' @param base_size Numeric. Base font size. Default \code{10}.
#' @param tile_ratio Numeric. Relative size of tile strip vs line plot.
#'   Default \code{0.4}.
#'
#' @return A patchwork object.
#' @export
#'
#' @examples
#' \dontrun{
#' data(ggpse_elements)
#'
#' # Period 2 — compact strip, dashed line for d-block gap
#' ggPSE_profile(ggpse_elements, value_col = "electronegativity", period = 2)
#'
#' # Period 4 — full d-block included
#' ggPSE_profile(ggpse_elements, value_col = "electronegativity", period = 4)
#'
#' # Group 1 — alkali metals, line to the right
#' ggPSE_profile(ggpse_elements, value_col = "atomic_radius_pm", group = 1)
#'
#' # Lanthanide row
#' ggPSE_profile(ggpse_elements, value_col = "electronegativity",
#'               lanthanides = TRUE)
#'
#' # Actinide row
#' ggPSE_profile(ggpse_elements, value_col = "melting_point_K",
#'               actinides = TRUE)
#' }
ggPSE_profile <- function(
    data,
    value_col,
    period       = NULL,
    group        = NULL,
    lanthanides  = FALSE,
    actinides    = FALSE,
    symbol_col   = "symbol",
    position     = NULL,
    color_high   = "#9a031e",
    color_low    = "#fdf0f2",
    color_na     = "#f0f0f0",
    line_color   = "#2166ac",
    point_color  = "#2166ac",
    legend_title = NULL,
    base_size    = 10,
    tile_ratio   = 0.4
) {
  if (!requireNamespace("patchwork", quietly = TRUE))
    stop("Package 'patchwork' is required for ggPSE_profile(). ",
         "Install it with: install.packages(\"patchwork\")",
         call. = FALSE)

  # ── Validate mode ─────────────────────────────────────────────────────────────
  n_active <- sum(!is.null(period), !is.null(group), lanthanides, actinides)
  if (n_active != 1)
    stop("Supply exactly one of: 'period', 'group', 'lanthanides = TRUE', or 'actinides = TRUE'.")

  mode <- if (!is.null(period)) "period" else if (!is.null(group)) "group" else
    if (lanthanides) "lanthanides" else "actinides"

  # ── Default position ──────────────────────────────────────────────────────────
  if (is.null(position)) {
    position <- if (mode == "group") "right" else "below"
  }

  valid_pos <- if (mode == "group") c("left", "right") else c("above", "below")
  if (!position %in% valid_pos)
    stop(sprintf("For %s, 'position' must be one of: %s",
                 mode, paste(valid_pos, collapse = ", ")))

  # ── Validate data ─────────────────────────────────────────────────────────────
  data <- .validate_element_data(data, symbol_col, value_col, fn = "ggPSE_profile()")

  legend_title <- legend_title %||% value_col

  # ── Get full grid ─────────────────────────────────────────────────────────────
  grid <- .ggpse_elements()

  # ── Filter grid to selected slice ─────────────────────────────────────────────
  d_block_cols <- 3:12

  if (mode == "period") {
    if (length(period) != 1L || !is.numeric(period) || !period %in% 1:7)
      stop("'period' must be a single integer between 1 and 7.", call. = FALSE)
    slice     <- grid[grid$row == period, ]
    has_d_gap <- period %in% 1:3
  } else if (mode == "group") {
    if (length(group) != 1L || !is.numeric(group) || !group %in% 1:18)
      stop("'group' must be a single integer between 1 and 18.", call. = FALSE)
    slice     <- grid[grid$col == group & grid$row %in% 1:7, ]
    has_d_gap <- FALSE
  } else if (mode == "lanthanides") {
    slice     <- grid[grid$row == 9, ]
    has_d_gap <- FALSE
  } else {
    slice     <- grid[grid$row == 10, ]
    has_d_gap <- FALSE
  }

  # ── Merge user data ───────────────────────────────────────────────────────────
  names(data)[names(data) == symbol_col] <- "symbol"
  slice <- merge(slice, data[, c("symbol", value_col), drop = FALSE],
                 by = "symbol", all.x = TRUE)

  # ── For group mode, drop rows with no data ───────────────────────────────────
  # ── Drop rows with no data ────────────────────────────────────────────────────
  slice <- slice[!is.na(slice[[value_col]]), ]
  if (nrow(slice) == 0)
    stop("No data found for any element in this slice.")

  # ── Compute plot coordinates ──────────────────────────────────────────────────
  if (mode == "group") {
    # Vertical strip — keep row as y, fix col to 1
    slice$col_plot <- 1L
    slice$row_plot <- slice$row
  } else {
    # Horizontal strip
    slice$row_plot <- 1L
    if (has_d_gap) {
      # Remove d-block columns and shift p-block left
      slice <- slice[!slice$col %in% d_block_cols, ]
      slice$col_plot <- ifelse(
        slice$col > 12,
        slice$col - length(d_block_cols),
        slice$col
      )
    } else {
      slice$col_plot <- slice$col
    }
    # Normalize to start at 1
    slice$col_plot <- slice$col_plot - min(slice$col_plot) + 1
  }

  # ── Compute tile fill colors ──────────────────────────────────────────────────
  val     <- slice[[value_col]]
  val_min <- min(val, na.rm = TRUE)
  val_max <- max(val, na.rm = TRUE)
  norm_val <- if (val_max == val_min) {
    ifelse(is.na(val), 0.5, 0.5)
  } else {
    ifelse(is.na(val), NA_real_, (val - val_min) / (val_max - val_min))
  }
  slice$fill_color <- ifelse(
    is.na(norm_val), color_na,
    vapply(norm_val, function(t) {
      if (is.na(t)) color_na else .interp_hex(color_low, color_high, t)
    }, character(1))
  )
  slice$text_color <- vapply(slice$fill_color, .contrast_color, character(1))

  # ── Tile strip plot ───────────────────────────────────────────────────────────
  tile_plot <- ggplot2::ggplot(
    slice,
    ggplot2::aes(x = .data[["col_plot"]], y = -.data[["row_plot"]])
  ) +
    ggplot2::geom_tile(
      ggplot2::aes(fill = .data[["fill_color"]]),
      color = "transparent", width = 0.92, height = 0.92
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::geom_text(
      ggplot2::aes(label = .data[["symbol"]], color = .data[["text_color"]]),
      fontface = "bold", size = base_size * 0.35
    ) +
    ggplot2::scale_color_identity() +
    ggplot2::coord_fixed(
      xlim = c(min(slice$col_plot) - 0.5, max(slice$col_plot) + 0.5),
      ylim = c(-max(slice$row_plot) - 0.5, -min(slice$row_plot) + 0.5),
      expand = FALSE
    )+
    ggplot2::theme_void(base_size = base_size) +
    ggplot2::theme(legend.position = "none")

  # ── Line plot data ────────────────────────────────────────────────────────────
  if (mode == "group") {
    line_data <- slice[!is.na(slice[[value_col]]), ]
    line_data <- line_data[order(line_data$row), ]
    x_var     <- "row"
    x_breaks  <- line_data$row
    x_labels  <- line_data$symbol
  } else {
    line_data <- slice[!is.na(slice[[value_col]]), ]
    line_data <- line_data[order(line_data$col_plot), ]
    x_var     <- "col_plot"
    x_breaks  <- line_data$col_plot
    x_labels  <- line_data$symbol
  }

  # ── Line plot ─────────────────────────────────────────────────────────────────
  if (mode == "group") {
    # Vertical line plot — period 1 at top, period 7 at bottom
    line_data$y_idx <- seq_len(nrow(line_data))  # 1,2,3... in row order
    
    line_plot <- ggplot2::ggplot(
      line_data,
      ggplot2::aes(x = .data[[value_col]], y = .data[["y_idx"]])
    ) +
      ggplot2::geom_path(color = line_color, linewidth = 0.8)+
      ggplot2::geom_point(color = point_color, size = 2.5) +
      ggplot2::scale_y_continuous(
        breaks = line_data$y_idx,
        labels = line_data$symbol,
        limits = c(min(line_data$y_idx) - 0.5, max(line_data$y_idx) + 0.5),
        expand = c(0, 0),
        trans  = "reverse"
      ) +
      ggplot2::labs(x = legend_title, y = NULL) +
      ggplot2::theme_minimal(base_size = base_size) +
      ggplot2::theme(
        panel.grid.minor = ggplot2::element_blank(),
        axis.text.y      = ggplot2::element_text(face = "bold"),
        axis.title.y     = ggplot2::element_blank()
      )
  } else {
    # Horizontal line plot
    line_plot <- ggplot2::ggplot(
      line_data,
      ggplot2::aes(x = .data[[x_var]], y = .data[[value_col]])
    ) +
      ggplot2::geom_line(color = line_color, linewidth = 0.8) +
      ggplot2::geom_point(color = point_color, size = 2.5) +
      ggplot2::scale_x_continuous(
        breaks = x_breaks,
        labels = x_labels,
        limits = c(min(x_breaks) - 0.5, max(x_breaks) + 0.5),
        expand = c(0, 0)
      )+
      ggplot2::labs(x = NULL, y = legend_title) +
      ggplot2::theme_minimal(base_size = base_size) +
      ggplot2::theme(
        panel.grid.minor = ggplot2::element_blank(),
        axis.text.x      = ggplot2::element_text(face = "bold"),
        axis.title.x     = ggplot2::element_blank()
      )

    # Dashed line for d-block gap in periods 1-3
    if (has_d_gap) {
      line_plot <- line_plot +
        ggplot2::geom_vline(
          xintercept = 2.5,
          linetype   = "dashed",
          color      = "grey50",
          linewidth  = 0.5
        )
    }
  }

  # ── Compose with patchwork ────────────────────────────────────────────────────
  if (mode == "group") {
    if (position == "right") {
      patchwork::wrap_plots(tile_plot, line_plot,
                            ncol = 2, widths = c(tile_ratio, 1))
    } else {
      patchwork::wrap_plots(line_plot, tile_plot,
                            ncol = 2, widths = c(1, tile_ratio))
    }
  } else {
    if (position == "below") {
      patchwork::wrap_plots(tile_plot, line_plot,
                            nrow = 2, heights = c(tile_ratio, 1))
    } else {
      patchwork::wrap_plots(line_plot, tile_plot,
                            nrow = 2, heights = c(1, tile_ratio))
    }
  }
}

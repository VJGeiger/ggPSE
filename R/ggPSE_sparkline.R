#' Overlay sparkline or sparkbar charts on a periodic table
#'
#' Draws a small time-series chart inside each element tile showing the
#' development of a numeric value over time. Supports both line charts
#' (\code{type = "line"}) and bar charts (\code{type = "bar"}).
#'
#' When \code{show_axis = TRUE}, a minimal ruler strip is appended showing
#' a solid horizontal line with tick marks at each time point and labels
#' for the first and last time point only. Requires \pkg{patchwork}.
#'
#' @param plot A ggplot object from [ggPSE()] or similar. If \code{NULL},
#'   a blank table is created with white tile backgrounds.
#' @param data A data frame in long format with one row per element-timepoint.
#' @param time_col Character. Column containing time points. Default \code{"year"}.
#' @param value_col Character. Column containing numeric values. Default \code{"value"}.
#' @param symbol_col Character. Column containing element symbols. Default \code{"symbol"}.
#' @param type Character. \code{"line"} (default) or \code{"bar"}.
#' @param color Character. Line or bar color. Default \code{"#2166ac"}.
#' @param color_high Character. Optional diverging color for bars above element
#'   mean (only for \code{type = "bar"}). Default \code{NULL}.
#' @param line_width Numeric. Line width. Default \code{0.4}.
#' @param point_size Numeric. Point size. Set to \code{0} to hide. Default \code{0.8}.
#' @param alpha Numeric. Opacity. Default \code{0.85}.
#' @param normalize Character. \code{"element"} (default) or \code{"global"}.
#' @param show_symbol Logical. Redraw element symbols on top. Default \code{TRUE}.
#' @param show_axis Logical. Show a magnified legend tile with a full x-axis.
#' @param legend_tile Logical. Show the magnified legend tile when
#'   \code{show_axis = TRUE}. Set to \code{FALSE} to return the main plot only.
#'   Default \code{TRUE}.
#'   Requires \pkg{patchwork}. Default \code{FALSE}.
#' @param axis_symbol Character. Which element to show in the magnified legend
#'   tile. Default \code{NULL} uses the first element with data.
#' @param axis_position Character. Where to place the legend tile relative to
#'   the main plot: \code{"below"} (default), \code{"above"}, \code{"left"},
#'   or \code{"right"}.
#' @param axis_width Numeric. Relative width of the legend tile when positioned
#'   \code{"left"} or \code{"right"}. Default \code{0.3}.
#' @param axis_height Numeric. Relative height of the legend tile when positioned
#'   \code{"above"} or \code{"below"}. Default \code{0.25}.
#' @param axis_color Character. Color of the border highlight on the legend
#'   element tile and the line/bar in the legend plot. Defaults to \code{color}.
#' @param axis_label_size Numeric. Font size for tick labels (numbers) in the
#'   legend tile. Default \code{NULL} uses \code{base_size}.
#' @param axis_title_size Numeric. Font size for the y-axis title in the legend
#'   tile. Default \code{NULL} uses \code{base_size}.
#' @param base_size Numeric. Base font size. Default \code{10}.
#'
#' @return A ggplot or patchwork object.
#' @export
#'
#' @examples
#' \dontrun{
#' prices <- data.frame(
#'   symbol = c("Li","Li","Li","Li","Li",
#'              "Co","Co","Co","Co","Co",
#'              "Ni","Ni","Ni","Ni","Ni"),
#'   year   = rep(2020:2024, 3),
#'   price  = c(6, 8, 70, 20, 15,
#'              30, 50, 80, 35, 25,
#'              14, 18, 25, 21, 17)
#' )
#'
#' # Line chart, no axis
#' ggPSE() |>
#'   ggPSE_sparkline(prices, time_col = "year", value_col = "price")
#'
#' # With magnified legend tile below
#' ggPSE() |>
#'   ggPSE_sparkline(prices, time_col = "year", value_col = "price",
#'                   show_axis = TRUE, axis_symbol = "Li")
#'
#' # Bar chart with legend tile to the right
#' ggPSE() |>
#'   ggPSE_sparkline(prices, time_col = "year", value_col = "price",
#'                   type = "bar", show_axis = TRUE,
#'                   axis_symbol = "Co", axis_position = "right")
#'
#' # Transition metals only
#' ggPSE(groups = c(3, 12), periods = c(4, 6),
#'       lanthanides = FALSE, actinides = FALSE) |>
#'   ggPSE_sparkline(prices, time_col = "year", value_col = "price",
#'                   show_axis = TRUE, axis_symbol = "Li", axis_height = 0.3)
#' }
ggPSE_sparkline <- function(
    plot          = NULL,
    data,
    time_col      = "year",
    value_col     = "value",
    symbol_col    = "symbol",
    type          = c("line", "bar"),
    color         = "#2166ac",
    color_high    = NULL,
    line_width    = 0.4,
    point_size    = 0.8,
    alpha         = 0.85,
    normalize     = c("element", "global"),
    show_symbol   = TRUE,
    show_axis     = FALSE,
    legend_tile   = TRUE,
    axis_symbol   = NULL,
    axis_position = c("below", "above", "left", "right"),
    axis_width    = 0.3,
    axis_height   = 0.25,
    axis_color    = NULL,
    axis_label_size = NULL,
    axis_title_size = NULL,
    base_size     = 10
) {
  type          <- match.arg(type)
  normalize     <- match.arg(normalize)
  axis_position <- match.arg(axis_position)

  axis_color      <- axis_color %||% color
  axis_label_size <- axis_label_size %||% base_size
  axis_title_size <- axis_title_size %||% base_size

  if (show_axis && !requireNamespace("patchwork", quietly = TRUE))
    stop("Package 'patchwork' is required when show_axis = TRUE. ",
         "Install it with: install.packages(\"patchwork\")",
         call. = FALSE)

  if (show_axis && !is.null(axis_symbol) && !axis_symbol %in% unique(data$symbol))
    warning(sprintf("axis_symbol '%s' not found in data — using first available element.", axis_symbol))

  if (is.null(plot))
    plot <- ggPSE(color_na = "#ffffff", tile_border = "#e0e0e0")

  # ── Validate inputs ───────────────────────────────────────────────────────────
  for (col in c(symbol_col, time_col, value_col)) {
    if (!col %in% names(data))
      stop(sprintf("Column '%s' not found in data.", col))
  }

  names(data)[names(data) == symbol_col] <- "symbol"
  names(data)[names(data) == time_col]   <- "time"
  names(data)[names(data) == value_col]  <- "value"

  # ── Clip to symbols in the plot ───────────────────────────────────────────────
  plot_symbols <- unique(plot$data$symbol)
  data         <- data[data$symbol %in% plot_symbols, ]

  if (nrow(data) == 0)
    stop("No matching elements found between data and the plotted elements.")

  # ── Grid positions ────────────────────────────────────────────────────────────
  grid <- .ggpse_elements()[, c("symbol", "col", "row")]
  data <- merge(data, grid, by = "symbol")

  # ── Sort time points ──────────────────────────────────────────────────────────
  time_levels   <- sort(unique(data$time))
  data$time_idx <- as.integer(factor(data$time, levels = time_levels))
  n_times       <- length(time_levels)

  # ── Normalize for tile rendering (0-1) ───────────────────────────────────────
  if (normalize == "element") {
    data <- do.call(rbind, lapply(split(data, data$symbol), function(d) {
      mn <- min(d$value, na.rm = TRUE)
      mx <- max(d$value, na.rm = TRUE)
      d$norm     <- if (mx == mn) 0.5 else (d$value - mn) / (mx - mn)
      d$mean_val <- mean(d$value, na.rm = TRUE)
      d
    }))
  } else {
    mn            <- min(data$value, na.rm = TRUE)
    mx            <- max(data$value, na.rm = TRUE)
    data$norm     <- if (mx == mn) 0.5 else (data$value - mn) / (mx - mn)
    data$mean_val <- stats::ave(data$value, data$symbol,
                                FUN = function(x) mean(x, na.rm = TRUE))
  }

  # ── Tile geometry ─────────────────────────────────────────────────────────────
  tile_h   <- 0.54
  tile_w   <- 0.88
  tile_top <- 0.42

  # ── Remove existing text layers ───────────────────────────────────────────────
  if (show_symbol)
    plot$layers <- Filter(function(l) !inherits(l$geom, "GeomText"),
                          plot$layers)

  # ── Build chart layer ─────────────────────────────────────────────────────────
  if (type == "line") {
    data$x_plot <- data$col - tile_w / 2 +
      (data$time_idx - 1) * tile_w / max(n_times - 1, 1)
    data$y_plot <- -data$row - tile_top + data$norm * tile_h

    p <- plot +
      ggplot2::geom_path(
        data        = data[order(data$symbol, data$time_idx), ],
        ggplot2::aes(x = .data[["x_plot"]], y = .data[["y_plot"]],
                     group = .data[["symbol"]]),
        color = color, linewidth = line_width, alpha = alpha,
        inherit.aes = FALSE
      )

    if (point_size > 0)
      p <- p +
        ggplot2::geom_point(
          data        = data,
          ggplot2::aes(x = .data[["x_plot"]], y = .data[["y_plot"]]),
          color = color, size = point_size, alpha = alpha,
          inherit.aes = FALSE
        )

  } else {
    bar_gap   <- tile_w / n_times
    bar_w     <- bar_gap * 0.85

    data$xmin <- data$col - tile_w / 2 + (data$time_idx - 1) * bar_gap
    data$xmax <- data$xmin + bar_w
    data$ymin <- -data$row - tile_top
    data$ymax <- data$ymin + data$norm * tile_h

    data$bar_fill <- if (!is.null(color_high))
      ifelse(data$value >= data$mean_val, color_high, color)
    else
      color

    p <- plot +
      ggplot2::geom_rect(
        data        = data,
        ggplot2::aes(xmin = .data[["xmin"]], xmax = .data[["xmax"]],
                     ymin = .data[["ymin"]], ymax = .data[["ymax"]],
                     fill = .data[["bar_fill"]]),
        alpha = alpha, color = NA, inherit.aes = FALSE
      ) +
      ggplot2::scale_fill_identity()
  }

  # ── Redraw symbols ────────────────────────────────────────────────────────────
  if (show_symbol) {
    label_data <- unique(plot$data[, c("symbol", "col", "row")])
    p <- p +
      ggplot2::geom_text(
        data        = label_data,
        ggplot2::aes(x = .data[["col"]], y = -.data[["row"]] + 0.34,
                     label = .data[["symbol"]]),
        fontface = "bold", size = base_size * 0.30,
        color = "grey20", inherit.aes = FALSE
      )
  }

  # ── Magnified legend tile with axis ──────────────────────────────────────────
  if (!show_axis || !legend_tile) return(p)

  # Pick element to show
  avail_syms <- unique(data$symbol)
  leg_sym    <- if (!is.null(axis_symbol) && axis_symbol %in% avail_syms)
    axis_symbol else avail_syms[1]

  # ── Highlight the legend element tile with a colored border ──────────────────
  leg_tile_data <- plot$data[plot$data$symbol == leg_sym, ]
  if (nrow(leg_tile_data) > 0) {
    p <- p +
      ggplot2::geom_tile(
        data        = leg_tile_data,
        ggplot2::aes(x = .data[["col"]], y = -.data[["row"]]),
        fill        = NA,
        color       = axis_color,
        linewidth   = 1.2,
        width       = 0.92,
        height      = 0.92,
        inherit.aes = FALSE
      )
  }

  leg_data <- data[data$symbol == leg_sym, ]
  leg_data <- leg_data[order(leg_data$time_idx), ]

  # Real value range for this element
  mn_leg <- min(leg_data$value, na.rm = TRUE)
  mx_leg <- max(leg_data$value, na.rm = TRUE)

  # x positions for legend tile
  mag_w <- tile_w * 2

  if (type == "line") {
    leg_data$lx <- (leg_data$time_idx - 1) * mag_w / max(n_times - 1, 1)

    leg_plot <- ggplot2::ggplot(
      leg_data,
      ggplot2::aes(x = .data[["lx"]], y = .data[["value"]])
    ) +
      ggplot2::geom_path(color = axis_color, linewidth = line_width * 2,
                         alpha = alpha) +
      ggplot2::geom_point(color = axis_color, size = point_size * 2, alpha = alpha)

  } else {
    bar_gap2     <- mag_w / n_times
    bar_w2       <- bar_gap2 * 0.85
    leg_data$lx  <- (leg_data$time_idx - 1) * bar_gap2
    leg_data$lxe <- leg_data$lx + bar_w2

    if (!is.null(color_high)) {
      leg_data$bfill <- ifelse(
        leg_data$value >= mean(leg_data$value, na.rm = TRUE),
        color_high, color)
    } else {
      leg_data$bfill <- color
    }

    leg_plot <- ggplot2::ggplot(leg_data) +
      ggplot2::geom_rect(
        ggplot2::aes(xmin = .data[["lx"]], xmax = .data[["lxe"]],
                     ymin = mn_leg, ymax = .data[["value"]],
                     fill = .data[["bfill"]]),
        alpha = alpha, color = NA
      ) +
      ggplot2::scale_fill_identity()
  }

  # x-axis breaks matching chart positions
  x_breaks <- if (type == "line") {
    (seq_len(n_times) - 1) * mag_w / max(n_times - 1, 1)
  } else {
    (seq_len(n_times) - 1) * (mag_w / n_times) + (mag_w / n_times * 0.85) / 2
  }

  leg_plot <- leg_plot +
    ggplot2::scale_x_continuous(
      breaks = x_breaks,
      labels = as.character(time_levels),
      expand = c(0.02, 0.02)
    ) +
    ggplot2::scale_y_continuous(
      limits = c(mn_leg - (mx_leg - mn_leg) * 0.05,
                 mx_leg + (mx_leg - mn_leg) * 0.08),
      expand = c(0, 0)
    ) +
    ggplot2::labs(x = NULL, y = value_col) +
    ggplot2::theme_minimal(base_size = axis_label_size) +
    ggplot2::theme(
      panel.background   = ggplot2::element_rect(fill = "#f0f4f8", color = NA),
      panel.grid.major.y = ggplot2::element_line(color = "white", linewidth = 0.4),
      panel.grid.minor   = ggplot2::element_blank(),
      axis.text.x        = ggplot2::element_text(size = axis_label_size * 0.7,
                                                  angle = 45, hjust = 1),
      axis.text.y        = ggplot2::element_text(size = axis_label_size * 0.7),
      axis.ticks.y       = ggplot2::element_line(color = "grey60"),
      axis.title.y       = ggplot2::element_text(size = axis_title_size),
      plot.margin        = ggplot2::margin(4, 8, 4, 4)
    )

  # ── Compose with patchwork ────────────────────────────────────────────────────
  if (axis_position == "below") {
    patchwork::wrap_plots(p, leg_plot, nrow = 2, heights = c(1, axis_height))
  } else if (axis_position == "above") {
    patchwork::wrap_plots(leg_plot, p, nrow = 2, heights = c(axis_height, 1))
  } else if (axis_position == "right") {
    patchwork::wrap_plots(p, leg_plot, ncol = 2, widths = c(1, axis_width))
  } else {
    patchwork::wrap_plots(leg_plot, p, ncol = 2, widths = c(axis_width, 1))
  }
}

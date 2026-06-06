#' Overlay sparkline or sparkbar charts on a periodic table
#'
#' Draws a small time-series chart inside each element tile showing the
#' development of a numeric value over time. Supports both line charts
#' (\code{type = "line"}) and bar charts (\code{type = "bar"}).
#'
#' Useful for visualising commodity price history, production trends, or
#' any time-series data per element. The charts are automatically clipped
#' to only show elements present in the input plot, so subsetting via
#' \code{groups}, \code{periods}, \code{lanthanides}, or \code{actinides}
#' in [ggPSE()] is respected.
#'
#' @param plot A ggplot object from [ggPSE()] or similar. If \code{NULL},
#'   a blank table is created with white tile backgrounds.
#' @param data A data frame in long format with one row per element-timepoint.
#' @param time_col Character. Column containing time points (numeric or
#'   factor). Default \code{"year"}.
#' @param value_col Character. Column containing numeric values. Default
#'   \code{"value"}.
#' @param symbol_col Character. Column containing element symbols.
#'   Default \code{"symbol"}.
#' @param type Character. Chart type: \code{"line"} (default) or
#'   \code{"bar"}.
#' @param color Character. Line or bar color. Default \code{"#2166ac"}.
#' @param color_high Character. Optional second color for diverging bars
#'   (only used when \code{type = "bar"}). Bars above the element mean use
#'   \code{color_high}, bars below use \code{color}. Default \code{NULL}.
#' @param line_width Numeric. Line width for \code{type = "line"}.
#'   Default \code{0.4}.
#' @param point_size Numeric. Point size for \code{type = "line"}.
#'   Set to \code{0} to hide points. Default \code{0.8}.
#' @param alpha Numeric. Fill opacity for bars or line. Default \code{0.85}.
#' @param normalize Character. How to normalize values within each element.
#'   \code{"element"} (default) normalizes each element independently.
#'   \code{"global"} uses the same scale across all elements.
#' @param show_symbol Logical. Redraw element symbols on top of the chart.
#'   Default \code{TRUE}.
#' @param base_size Numeric. Font size for element symbols. Default \code{10}.
#'
#' @return A ggplot object.
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
#' # Line chart (default)
#' ggPSE() |>
#'   ggPSE_sparkline(prices, time_col = "year", value_col = "price")
#'
#' # Bar chart
#' ggPSE() |>
#'   ggPSE_sparkline(prices, time_col = "year", value_col = "price",
#'                   type = "bar")
#'
#' # Transition metals only — more readable
#' ggPSE(groups = c(3, 12), periods = c(4, 6),
#'       lanthanides = FALSE, actinides = FALSE) |>
#'   ggPSE_sparkline(prices, time_col = "year", value_col = "price")
#'
#' # Diverging bar colors — above/below mean
#' ggPSE() |>
#'   ggPSE_sparkline(prices, time_col = "year", value_col = "price",
#'                   type = "bar", color = "#2166ac",
#'                   color_high = "#d73027")
#'
#' # Global normalization — compare magnitudes across elements
#' ggPSE() |>
#'   ggPSE_sparkline(prices, time_col = "year", value_col = "price",
#'                   normalize = "global")
#' }
ggPSE_sparkline <- function(
    plot         = NULL,
    data,
    time_col     = "year",
    value_col    = "value",
    symbol_col   = "symbol",
    type         = c("line", "bar"),
    color        = "#2166ac",
    color_high   = NULL,
    line_width   = 0.4,
    point_size   = 0.8,
    alpha        = 0.85,
    normalize    = c("element", "global"),
    show_symbol  = TRUE,
    base_size    = 10
) {
  type      <- match.arg(type)
  normalize <- match.arg(normalize)

  if (is.null(plot)) {
    plot <- ggPSE(color_na = "#ffffff", tile_border = "#e0e0e0")
  }

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

  # ── Get grid positions ────────────────────────────────────────────────────────
  grid <- .ggpse_elements()[, c("symbol", "col", "row")]
  data <- merge(data, grid, by = "symbol")

  # ── Sort time points ──────────────────────────────────────────────────────────
  time_levels   <- sort(unique(data$time))
  data$time_idx <- as.integer(factor(data$time, levels = time_levels))
  n_times       <- length(time_levels)

  # ── Normalize values ──────────────────────────────────────────────────────────
  if (normalize == "element") {
    data <- do.call(rbind, lapply(split(data, data$symbol), function(d) {
      val_min    <- min(d$value, na.rm = TRUE)
      val_max    <- max(d$value, na.rm = TRUE)
      d$norm     <- if (val_max == val_min) 0.5 else
        (d$value - val_min) / (val_max - val_min)
      d$mean_val <- mean(d$value, na.rm = TRUE)
      d
    }))
  } else {
    val_min       <- min(data$value, na.rm = TRUE)
    val_max       <- max(data$value, na.rm = TRUE)
    data$norm     <- if (val_max == val_min) 0.5 else
      (data$value - val_min) / (val_max - val_min)
    data$mean_val <- stats::ave(data$value, data$symbol,
                                FUN = function(x) mean(x, na.rm = TRUE))
  }

  # ── Usable tile dimensions — leave top 20% for label ────────────────────────
  tile_h <- 0.58
  tile_w <- 0.88
  tile_top <- 0.44   # y offset from tile center to chart top

  # ── Remove existing text layers if redrawing symbols ─────────────────────────
  if (show_symbol) {
    plot$layers <- Filter(function(l) !inherits(l$geom, "GeomText"),
                          plot$layers)
  }

  # ── Build layer ───────────────────────────────────────────────────────────────
  if (type == "line") {

    # x: evenly spaced across tile width
    # y: normalized value mapped to tile height
    data$x_plot <- data$col - tile_w / 2 +
      (data$time_idx - 1) * tile_w / max(n_times - 1, 1)
    data$y_plot <- -data$row - tile_top + data$norm * tile_h

    data$line_color <- color

    p <- plot +
      ggplot2::geom_path(
        data        = data[order(data$symbol, data$time_idx), ],
        ggplot2::aes(
          x     = .data[["x_plot"]],
          y     = .data[["y_plot"]],
          group = .data[["symbol"]]
        ),
        color       = color,
        linewidth   = line_width,
        alpha       = alpha,
        inherit.aes = FALSE
      )

    if (point_size > 0) {
      p <- p +
        ggplot2::geom_point(
          data        = data,
          ggplot2::aes(
            x = .data[["x_plot"]],
            y = .data[["y_plot"]]
          ),
          color       = color,
          size        = point_size,
          alpha       = alpha,
          inherit.aes = FALSE
        )
    }

  } else {
    # Bar chart
    bar_w <- tile_w / n_times * 0.85
    bar_gap <- tile_w / n_times

    data$xmin <- data$col - tile_w / 2 + (data$time_idx - 1) * bar_gap
    data$xmax <- data$xmin + bar_w
    data$ymin <- -data$row - tile_top
    data$ymax <- data$ymin + data$norm * tile_h

    if (!is.null(color_high)) {
      data$bar_fill <- ifelse(data$value >= data$mean_val, color_high, color)
    } else {
      data$bar_fill <- color
    }

    p <- plot +
      ggplot2::geom_rect(
        data        = data,
        ggplot2::aes(
          xmin = .data[["xmin"]],
          xmax = .data[["xmax"]],
          ymin = .data[["ymin"]],
          ymax = .data[["ymax"]],
          fill = .data[["bar_fill"]]
        ),
        alpha       = alpha,
        color       = NA,
        inherit.aes = FALSE
      ) +
      ggplot2::scale_fill_identity()
  }

  # ── Redraw symbols on top ─────────────────────────────────────────────────────
  if (show_symbol) {
    label_data <- unique(plot$data[, c("symbol", "col", "row")])
    p <- p +
      ggplot2::geom_text(
        data        = label_data,
        ggplot2::aes(
          x     = .data[["col"]],
          y     = -.data[["row"]] + 0.38,
          label = .data[["symbol"]]
        ),
        fontface    = "bold",
        size        = base_size * 0.30,
        color       = "grey20",
        inherit.aes = FALSE
      )
  }

  p
}

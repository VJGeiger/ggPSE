#' Overlay donut or pie charts on a periodic table
#'
#' Draws a small donut (or pie) chart inside each element tile showing a
#' categorical breakdown - for example supply mix by country, composition by
#' phase, or any other proportional split. Requires the \pkg{ggforce} package
#' for \code{geom_arc_bar()}.
#'
#' The donut is automatically clipped to only show elements present in the
#' input plot, so subsetting via \code{groups}, \code{periods},
#' \code{lanthanides}, or \code{actinides} in [ggPSE()] is respected.
#' Element symbols are redrawn centered in the donut hole on top of the arcs.
#'
#' @param plot A ggplot object from [ggPSE()] or similar. If \code{NULL},
#'   a blank table is created first.
#' @param data A data frame with one row per element-category combination.
#' @param symbol_col Character. Column containing element symbols.
#'   Default \code{"symbol"}.
#' @param category_col Character. Column containing category labels (e.g.
#'   country, phase, source). Default \code{"category"}.
#' @param share_col Character. Column containing shares (0-1 or percentages —
#'   values above 1 are assumed to be percentages and divided by 100
#'   automatically). Default \code{"share"}.
#' @param r Numeric. Outer radius of the donut as a fraction of tile width.
#'   Default \code{0.42}.
#' @param r0 Numeric. Inner radius (donut hole) as a fraction of tile width.
#'   Default \code{0.20}. Set to \code{0} for a pie chart instead.
#' @param colors Named or unnamed character vector of fill colors for each
#'   category. If \code{NULL} (default), uses a built-in qualitative palette.
#' @param color_legend Logical. Show a color legend. Default \code{TRUE}.
#' @param legend_title Character. Legend title. Default \code{"Category"}.
#' @param base_size Numeric. Font size for element symbol labels. Default
#'   \code{10}.
#' @param plot_all Logical. If \code{TRUE} (default), labels are shown for
#'   all elements in the plot. If \code{FALSE}, labels are shown only for
#'   elements that have a donut chart.
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' \dontrun{
#' supply <- data.frame(
#'   symbol   = c("Li","Li","Li", "Co","Co", "Nd","Nd", "Pt"),
#'   category = c("CL","AU","AR", "CD","AU", "CN","RU", "ZA"),
#'   share    = c(0.60, 0.30, 0.10, 0.70, 0.30, 0.80, 0.20, 1.00)
#' )
#'
#' # All labels shown (default)
#' ggPSE() |>
#'   ggPSE_donut(supply, category_col = "category", share_col = "share")
#'
#' # Only donut elements get a label
#' ggPSE() |>
#'   ggPSE_donut(supply, category_col = "category", share_col = "share",
#'               plot_all = FALSE)
#'
#' # Pie chart (r0 = 0)
#' ggPSE() |>
#'   ggPSE_donut(supply, category_col = "category", share_col = "share",
#'               r0 = 0)
#'
#' # Combine with gradient fill
#' criticality <- data.frame(
#'   symbol = c("Li", "Co", "Nd", "Pt"),
#'   value  = c(0.70, 0.91, 0.85, 0.60)
#' )
#' ggPSE(criticality, value_col = "value", legend_title = "Criticality") |>
#'   ggPSE_donut(supply, category_col = "category", share_col = "share",
#'               legend_title = "Producer")
#'
#' # Respects subsetting
#' ggPSE(groups = c(3, 12), periods = c(4, 6),
#'       lanthanides = FALSE, actinides = FALSE) |>
#'   ggPSE_donut(supply, category_col = "category", share_col = "share")
#' }
ggPSE_donut <- function(
    plot          = NULL,
    data,
    symbol_col    = "symbol",
    category_col  = "category",
    share_col     = "share",
    r             = 0.42,
    r0            = 0.20,
    colors        = NULL,
    color_legend  = TRUE,
    legend_title  = "Category",
    base_size     = 10,
    plot_all      = TRUE
) {
  # for now this is done with ggforce, stability to be seen
  if (!requireNamespace("ggforce", quietly = TRUE))
    stop("Package 'ggforce' is required for ggPSE_donut(). ",
         "Install it with: install.packages(\"ggforce\")",
         call. = FALSE)
  geom_arc_bar <- getExportedValue("ggforce", "geom_arc_bar")
  if (is.null(plot)) plot <- ggPSE()

  # ── Validate inputs ───────────────────────────────────────────────────────────
  for (col in c(symbol_col, category_col, share_col)) {
    if (!col %in% names(data))
      stop(sprintf("Column '%s' not found in data.", col))
  }

  # Rename for internal use
  names(data)[names(data) == symbol_col]   <- "symbol"
  names(data)[names(data) == category_col] <- "category"
  names(data)[names(data) == share_col]    <- "share"

  # ── Normalise shares ──────────────────────────────────────────────────────────
  if (max(data$share, na.rm = TRUE) > 1) {
    data$share <- data$share / 100
  }

  data <- do.call(rbind, lapply(split(data, data$symbol), function(d) {
    d$share <- d$share / sum(d$share, na.rm = TRUE)
    d
  }))
  rownames(data) <- NULL

  # ── Join with grid positions ──────────────────────────────────────────────────
  grid     <- .ggpse_elements()[, c("symbol", "col", "row")]
  arc_data <- merge(data, grid, by = "symbol")

  # ── Clip to symbols actually in the plot ─────────────────────────────────────
  plot_symbols <- unique(plot$data$symbol)
  arc_data     <- arc_data[arc_data$symbol %in% plot_symbols, ]

  if (nrow(arc_data) == 0)
    stop("No matching elements found between data and the plotted elements.")

  # ── Compute arc start/end angles per element ──────────────────────────────────
  arc_data <- do.call(rbind, lapply(split(arc_data, arc_data$symbol), function(d) {
    d        <- d[order(d$share, decreasing = TRUE), ]
    cum_sh   <- cumsum(d$share)
    d$end    <- cum_sh * 2 * pi - pi / 2
    d$start  <- c(-pi / 2, utils::head(d$end, -1))
    d
  }))
  rownames(arc_data) <- NULL

  # ── Color palette ─────────────────────────────────────────────────────────────
  categories <- unique(arc_data$category)
  n          <- length(categories)
  
  # set color palette
  if (is.null(colors)) {
    default_pal <- c(
      "#2166ac", "#d73027", "#1a9850", "#f46d43", "#762a83",
      "#fdae61", "#4dac26", "#d01c8b", "#b2abd2", "#abd9e9",
      "#fee090", "#a6dba0"
    )
    pal_n  <- min(n, length(default_pal))
    colors <- stats::setNames(default_pal[seq_len(pal_n)],
                              categories[seq_len(pal_n)])
    if (n > length(default_pal)) {
      extra  <- grDevices::hcl.colors(n - length(default_pal), palette = "Set2")
      colors <- c(colors,
                  stats::setNames(extra, categories[(length(default_pal) + 1):n]))
    }
  } else if (is.null(names(colors))) {
    colors <- stats::setNames(colors[seq_len(n)], categories)
  }

  # ── Remove existing text layers and redraw cleanly ────────────────────────────
  # otherwise problems with double layers
  plot$layers <- Filter(function(l) {
    !inherits(l$geom, "GeomText")
  }, plot$layers)

  # Decide which elements get a label
  if (plot_all) {
    label_data <- unique(plot$data[, c("symbol", "col", "row")])
  } else {
    label_data <- unique(arc_data[, c("symbol", "col", "row")])
  }

  # ── Build plot ────────────────────────────────────────────────────────────────
  plot +
    geom_arc_bar(
      data        = arc_data,
      ggplot2::aes(
        x0    = .data[["col"]],
        y0    = -.data[["row"]],
        r0    = r0,
        r     = r,
        start = .data[["start"]],
        end   = .data[["end"]],
        fill  = .data[["category"]]
      ),
      color       = "white",
      linewidth   = 0.2,
      inherit.aes = FALSE
    ) +
    ggplot2::scale_fill_manual(
      values = colors,
      name   = if (color_legend) legend_title else NULL,
      guide  = if (color_legend) ggplot2::guide_legend() else "none"
    ) +
    ggplot2::geom_text(
      data        = label_data,
      ggplot2::aes(
        x     = .data[["col"]],
        y     = -.data[["row"]],
        label = .data[["symbol"]]
      ),
      fontface    = "bold",
      size        = base_size * 0.40,
      vjust       = 0.5,
      hjust       = 0.5,
      color       = "grey20",
      inherit.aes = FALSE
    )
}

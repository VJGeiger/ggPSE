#' Add a line of text from a data column to every tile
#'
#' Adds one extra text line per element to a plot created with [ggPSE()]
#' (or any function built on it), taking the text from a column of your data.
#' It replaces the usual workaround of merging the element positions into your
#' data and placing a \code{geom_text()} by hand. Call it several times to
#' stack more lines, for example a classification at the \code{"center"} and a
#' value at the \code{"bottom"}.
#'
#' The text is anchored at the chosen edge of the tile and grows into the tile,
#' so multi-line text (\code{"\\n"}) stays inside it. Elements that are not in
#' \code{data}, or whose text is \code{NA} or empty, get no text. Elements in
#' \code{data} that are not part of the plot (e.g. outside a \code{periods}
#' subset) are ignored.
#'
#' @note [ggPSE_donut()] removes every text layer from the plot it receives.
#'   Call \code{ggPSE_text()} \emph{after} the donut.
#'
#' @param plot A plot created with [ggPSE()]. If \code{NULL}, a blank
#'   periodic table is used.
#' @param data A data frame with the element symbols and the text column.
#' @param text_col Character. Column in \code{data} with the text to draw. It is
#'   converted with \code{as.character()}, so format numbers beforehand
#'   (e.g. with \code{sprintf()}).
#' @param symbol_col Character. Column in \code{data} with the element
#'   symbols. Default \code{"symbol"}.
#' @param position Where in the tile the text is anchored: \code{"bottom"}
#'   (default), \code{"top"} or \code{"center"}.
#' @param position_nudge Numeric. Vertical shift in tile units (positive = up)
#'   added to \code{position}, to fine-tune the placement. A tile is 0.92
#'   high. Default \code{0}. (Unlike \code{ggplot2::position_nudge()} this is a
#'   single vertical value.)
#' @param size Numeric. Text size in ggplot2 text units (mm). Default
#'   \code{2.5}.
#' @param fontface Character. \code{"plain"} (default), \code{"bold"},
#'   \code{"italic"} or \code{"bold.italic"}.
#' @param color Either a single colour (default \code{"grey15"}) or the name of
#'   a column in \code{data} that holds one colour per element.
#' @param lineheight Numeric. Line spacing for multi-line text. Default
#'   \code{0.9}.
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' data(ggpse_elements)
#' d <- data.frame(
#'   symbol = c("Li", "Na", "K", "Fe", "Cu"),
#'   E      = c(-3.04, -2.71, -2.92, -0.41, 0.34),
#'   eq     = c("Li\u207a+e\u207b\u2192Li", "Na\u207a+e\u207b\u2192Na",
#'              "K\u207a+e\u207b\u2192K", "Fe\u00b2\u207a+2e\u207b\u2192Fe",
#'              "Cu\u00b2\u207a+2e\u207b\u2192Cu")
#' )
#' d$E_label <- sprintf("%+.2f", d$E)
#'
#' p <- ggPSE(d, value_col = "E", label_value = FALSE, label_na = FALSE,
#'            symbol_position = "center", periods = c(1, 4),
#'            lanthanides = FALSE, actinides = FALSE)
#' p <- ggPSE_text(p, d, "E_label", position = "top", fontface = "bold")
#' ggPSE_text(p, d, "eq", position = "bottom", size = 2)
ggPSE_text <- function(
    plot           = NULL,
    data,
    text_col,
    symbol_col     = "symbol",
    position       = c("bottom", "top", "center"),
    position_nudge = 0,
    size           = 2.5,
    fontface       = "plain",
    color          = "grey15",
    lineheight     = 0.9
) {
  position <- match.arg(position)
  if (is.null(plot)) plot <- ggPSE()

  # ── Validate inputs ───────────────────────────────────────────────────────────
  if (!inherits(plot, "ggplot"))
    stop("'plot' must be a ggplot object created with ggPSE().", call. = FALSE)
  if (!all(c("symbol", "col", "row") %in% names(plot$data)))
    stop("'plot' must be created with ggPSE(): its data lacks the tile positions.",
         call. = FALSE)
  if (missing(data) || !is.data.frame(data))
    stop("'data' must be a data frame.", call. = FALSE)
  for (cl in c(symbol_col, text_col)) {
    if (!cl %in% names(data))
      stop(sprintf("Column '%s' not found in data.", cl), call. = FALSE)
  }
  .check_nudge(position_nudge, "position_nudge")
  if (!is.numeric(size) || length(size) != 1L || !is.finite(size) || size <= 0)
    stop("'size' must be a single positive number.", call. = FALSE)

  color_is_col <- length(color) == 1L && is.character(color) && color %in% names(data)
  if (!color_is_col) .check_text_color(color)

  # ── Join with the tiles that are actually in the plot ────────────────────────
  tiles <- unique(plot$data[, c("symbol", "col", "row")])
  d <- data.frame(
    symbol = data[[symbol_col]],
    label  = as.character(data[[text_col]]),
    stringsAsFactors = FALSE
  )
  if (color_is_col) d$tcolor <- as.character(data[[color]])
  d <- d[!is.na(d$label) & nzchar(d$label), , drop = FALSE]
  d <- merge(d, tiles, by = "symbol")

  if (nrow(d) == 0) {
    warning("No elements in 'data' match the tiles of 'plot'; nothing added.",
            call. = FALSE)
    return(plot)
  }

  # ── Anchor at the tile edge; text grows into the tile ────────────────────────
  pad  <- 0.40
  slot <- switch(position,
    top    = list(y =  pad, vjust = 1),
    center = list(y =  0,   vjust = 0.5),
    bottom = list(y = -pad, vjust = 0)
  )
  d$x <- d$col
  d$y <- -d$row + slot$y + position_nudge

  # ── Layer ─────────────────────────────────────────────────────────────────────
  if (color_is_col) {
    mapping <- ggplot2::aes(x = .data[["x"]], y = .data[["y"]],
                            label = .data[["label"]], color = .data[["tcolor"]])
    plot + ggplot2::geom_text(
      data = d, mapping = mapping, inherit.aes = FALSE,
      hjust = 0.5, vjust = slot$vjust, size = size,
      fontface = fontface, lineheight = lineheight
    )
  } else {
    mapping <- ggplot2::aes(x = .data[["x"]], y = .data[["y"]],
                            label = .data[["label"]])
    plot + ggplot2::geom_text(
      data = d, mapping = mapping, inherit.aes = FALSE,
      hjust = 0.5, vjust = slot$vjust, size = size, color = color,
      fontface = fontface, lineheight = lineheight
    )
  }
}

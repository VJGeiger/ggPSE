#' Mark elements with symbols by category
#'
#' Draws small point symbols (\code{pch}) in the tiles of a plot created with
#' [ggPSE()], one symbol \emph{shape and colour} per category. It is made for
#' yes/no style information that has to sit \emph{on top of} another
#' encoding, for example marking all elements that are produced
#' aluminothermically or by distillation on a periodic table that is coloured by
#' abundance. An element can belong to several categories; it then gets one
#' marker per category.
#'
#' @details
#' \strong{Layout.} The markers sit in one row at the very \emph{bottom} edge of
#' the tile, centred horizontally. An element can have at most four markers. Each
#' shape has its own measured width and height, so the gaps between neighbouring
#' markers are equal, the group is centred by its outer edges, and all markers
#' rest on the same bottom line, whatever their shapes. To make room, the element
#' symbol (and the value label, if there is one) is moved up (\code{move_text =
#' TRUE}); the same result as building the plot with \code{symbol_position =
#' "top"}. If \code{size} is too large for the busiest tile, it is reduced with a
#' message. The spacing is calibrated for tiles of about 1 cm (e.g. a plot 20 cm
#' wide with the default \code{base_size}), like the text layout of [ggPSE()].
#'
#' \strong{White edge.} With \code{halo = TRUE} (the default) every marker has a
#' white edge, so it stays visible on dark or coloured tiles. For the filled shapes
#' 21 to 25 the edge is the outline of the shape. All other shapes get a slightly
#' larger white copy drawn underneath.
#'
#' \strong{Legend.} A legend for the shapes and colours is added to the plot.
#' It uses ggplot2's \code{shape} scale, so call \code{ggPSE_symbols()} only
#' once per plot, and do not combine it with another layer that uses a shape
#' scale. Use \code{legend = FALSE} to suppress it.
#'
#' @param plot A plot created with [ggPSE()]. If \code{NULL}, a blank periodic
#'   table is used.
#' @param data A data frame with one row per element and category. An element
#'   that belongs to several categories appears in several rows, but can have at
#'   most four. Repeated rows are ignored; rows whose category is \code{NA} or
#'   empty are dropped.
#' @param category_col Character. Column in \code{data} with the category.
#'   Default \code{"category"}. A factor keeps the order of its levels, other
#'   columns are sorted alphabetically. There is no limit to the number of
#'   categories, but an element can have at most four (see \code{data}).
#' @param symbol_col Character. Column in \code{data} with the element symbols.
#'   Default \code{"symbol"}.
#' @param pch Point shapes (whole numbers from 0 to 25, see
#'   \code{\link[graphics]{points}}), either a named vector (names = categories)
#'   or an unnamed vector in category order. Each category gets one shape, and
#'   together with its colour it is the marker of that category. Default
#'   \code{NULL}: shapes 21 (circle), 24 (triangle), 22 (square), 23 (diamond),
#'   25 (inverted triangle) and 8 (star), repeated if there are more than six
#'   categories (the colours then still tell the categories apart).
#' @param colors Colours, named by category or unnamed in category order. Each
#'   category gets one colour. Default \code{NULL}: the colour-blind-safe
#'   Okabe-Ito palette used by [ggPSE()] for groups (further colours are added for
#'   more than seven categories).
#' @param size Numeric. Marker size in ggplot2 point units. Default \code{1.6},
#'   the largest size at which four of the default shapes fit side by side (about
#'   0.2 of a tile at 1 cm tile size). Larger values are reduced automatically if
#'   some element has so many markers that they would not fit into one row.
#' @param move_text Logical. Move the element symbol up to the top of the tile
#'   (and the value label, if shown, to the middle) so that the bottom is free for
#'   the markers. Default \code{TRUE}. Nothing is moved if the symbol is already
#'   at the top (\code{symbol_position = "top"}), and the plot you pass in is not
#'   changed. A \code{symbol_nudge} you set is replaced by the new position. If
#'   the symbol is drawn at the bottom of the tile, a warning is given instead,
#'   because it would sit on the markers. The atomic number, if shown, stays where
#'   it is: it is drawn at the top left by default, so check that it does not
#'   overlap the symbol.
#' @param position_nudge Numeric. Vertical shift of all markers in tile units
#'   (positive = up; a tile is 0.92 high). Default \code{0}.
#' @param halo Logical. Draw a white edge around the markers (see Details).
#'   Default \code{TRUE}.
#' @param legend Logical. Add a legend. Default \code{TRUE}.
#' @param legend_title Character. Legend title. Default: the name of
#'   \code{category_col}.
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' # An illustrative selection (not a curated reference): elements whose metal
#' # is made by aluminothermic reduction, by distillation, or both.
#' prod <- data.frame(
#'   symbol   = c("Cr", "V", "Nb", "Ca", "Sr", "Ba",
#'                "Hg", "Zn", "Cd", "Ca", "Sr", "Ba", "N", "O", "Ar", "Ne", "Kr", "Xe"),
#'   category = c(rep("aluminothermic", 6), rep("distillation", 12))
#' )
#' ggPSE_symbols(ggPSE(), prod,
#'               pch = c(aluminothermic = 24, distillation = 21),
#'               colors = c(aluminothermic = "#D55E00", distillation = "#0072B2"),
#'               legend_title = "Production")
#'
#' # on top of a colour gradient the markers keep a white edge
#' data(ggpse_elements)
#' p <- ggPSE(ggpse_elements, value_col = "melting_point_K", label_value = FALSE,
#'            legend_title = "Melting point (K)")
#' ggPSE_symbols(p, prod, legend_title = "Production")
ggPSE_symbols <- function(
    plot           = NULL,
    data,
    category_col   = "category",
    symbol_col     = "symbol",
    pch            = NULL,
    colors         = NULL,
    size           = 1.6,
    move_text      = TRUE,
    position_nudge = 0,
    halo           = TRUE,
    legend         = TRUE,
    legend_title   = NULL
) {
  if (is.null(plot)) plot <- ggPSE()

  # ── Validate inputs ───────────────────────────────────────────────────────────
  if (!inherits(plot, "ggplot"))
    stop("'plot' must be a ggplot object created with ggPSE().", call. = FALSE)
  if (!all(c("symbol", "col", "row") %in% names(plot$data)))
    stop("'plot' must be created with ggPSE(): its data lacks the tile positions.",
         call. = FALSE)
  if (missing(data) || !is.data.frame(data))
    stop("'data' must be a data frame.", call. = FALSE)
  for (cl in c(symbol_col, category_col)) {
    if (!is.character(cl) || length(cl) != 1L || !cl %in% names(data))
      stop(sprintf("Column '%s' not found in data.", as.character(cl)[1]), call. = FALSE)
  }
  .check_symbols(data[[symbol_col]], symbol_col)
  .check_nudge(position_nudge, "position_nudge")
  if (!is.logical(move_text) || length(move_text) != 1L || is.na(move_text))
    stop("'move_text' must be TRUE or FALSE.", call. = FALSE)
  if (!is.numeric(size) || length(size) != 1L || !is.finite(size) || size <= 0)
    stop("'size' must be a single positive number.", call. = FALSE)
  if (!is.logical(halo) || length(halo) != 1L || is.na(halo))
    stop("'halo' must be TRUE or FALSE.", call. = FALSE)
  if (!is.logical(legend) || length(legend) != 1L || is.na(legend))
    stop("'legend' must be TRUE or FALSE.", call. = FALSE)
  if (!is.null(legend_title) &&
      !(is.character(legend_title) && length(legend_title) == 1L))
    stop("'legend_title' must be a single character string or NULL.", call. = FALSE)

  # ── Categories ────────────────────────────────────────────────────────────────
  d <- data.frame(symbol   = as.character(data[[symbol_col]]),
                  category = as.character(data[[category_col]]),
                  stringsAsFactors = FALSE)
  keep <- !is.na(d$category) & nzchar(d$category)
  cats <- if (is.factor(data[[category_col]]))
    levels(droplevels(data[[category_col]][keep])) else sort(unique(d$category[keep]))
  d <- unique(d[keep, , drop = FALSE])
  if (length(cats) == 0L) {
    warning("'data' has no non-missing categories; nothing added.", call. = FALSE)
    return(plot)
  }
  pch    <- .resolve_symbol_pch(pch, cats)
  colors <- .resolve_symbol_colors(colors, cats)

  # ── Join with the tiles that are in the plot ─────────────────────────────────
  tiles <- unique(plot$data[, c("symbol", "col", "row")])
  d <- merge(d, tiles, by = "symbol")
  if (nrow(d) == 0L) {
    warning("No elements in 'data' match the tiles of 'plot'; nothing added.", call. = FALSE)
    return(plot)
  }
  d$cat_i <- match(d$category, cats)
  d <- d[order(d$symbol, d$cat_i), , drop = FALSE]

  # ── At most four markers per element, all in one row ─────────────────────────
  n_per <- table(d$symbol)
  if (any(n_per > .symbol_max_per_tile))
    stop(sprintf(paste0("ggPSE_symbols() draws at most %d markers per element, but %s %s more: %s. ",
                        "Merge or drop categories for these elements."),
                 .symbol_max_per_tile, .list_values(names(n_per)[n_per > .symbol_max_per_tile]),
                 if (sum(n_per > .symbol_max_per_tile) == 1L) "has" else "have",
                 paste(sprintf("%s (%d)", names(n_per)[n_per > .symbol_max_per_tile],
                               as.integer(n_per[n_per > .symbol_max_per_tile])), collapse = ", ")),
         call. = FALSE)
  d$pch <- vapply(d$category, function(cat) pch[[cat]], numeric(1))
  size_max <- .symbol_fit_size(split(d$pch, d$symbol), halo)
  if (size > size_max + 1e-9) {
    message(sprintf("'size' reduced from %g to %.2g so that the markers fit into one row.",
                    size, floor(size_max * 100) / 100))
    size <- floor(size_max * 100) / 100
  }

  # ── Make room: move the element symbol (and the value) up ─────────────────────
  info <- .tile_text_info(plot)
  if (!is.na(info$symbol_dy)) {
    if (info$symbol_dy <= -0.15) {
      warning(paste0("The element symbol is drawn at the bottom of the tile (symbol_position = ",
                     "\"bottom\") and will sit on the markers. Use symbol_position = \"top\" ",
                     "or \"center\" in ggPSE()."), call. = FALSE)
    } else if (move_text) {
      plot <- .move_tile_text(plot, info)
    }
  }

  # ── Positions: one row at the very bottom edge, placed by the measured shape sizes
  parts <- lapply(split(d, d$symbol), function(g) {
    cbind(g, .symbol_layout(g$pch, size, halo))
  })
  d <- do.call(rbind, parts)
  d$x <- d$col + d$dx
  d$y <- -d$row + d$dy + position_nudge

  # ── Layers: all halos first, then all markers ────────────────────────────────
  stroke <- 0.6
  present <- cats[cats %in% d$category]
  p <- plot
  if (halo) {
    for (cat in present) {
      sh <- pch[[cat]]
      if (sh %in% 21:25) next                  # the outline of these shapes is the edge
      m <- d[d$category == cat, , drop = FALSE]
      p <- p + ggplot2::geom_point(
        data = m, mapping = ggplot2::aes(x = .data[["x"]], y = .data[["y"]]),
        inherit.aes = FALSE, show.legend = FALSE, shape = sh, colour = "white",
        size   = if (sh %in% 15:20) size + 2 * .symbol_halo_width else size,
        stroke = if (sh %in% 15:20) stroke else stroke + 2 * .symbol_halo_width)
    }
  }
  for (cat in present) {
    sh <- pch[[cat]]; col <- colors[[cat]]
    m  <- d[d$category == cat, , drop = FALSE]
    p <- p + ggplot2::geom_point(
      data = m, mapping = ggplot2::aes(x = .data[["x"]], y = .data[["y"]]),
      inherit.aes = FALSE, show.legend = FALSE, shape = sh, size = size, stroke = stroke,
      colour = if (sh %in% 21:25 && halo) "white" else col,
      fill   = col)
  }

  # ── Legend: an invisible layer that carries the shape scale; the keys get their
  #    colours from override.aes, so no colour or fill scale is touched ───────────
  if (legend) {
    leg <- data.frame(x = tiles$col[1], y = -tiles$row[1],
                      category = factor(present, levels = present))
    p <- p +
      ggplot2::geom_point(data = leg,
                          mapping = ggplot2::aes(x = .data[["x"]], y = .data[["y"]],
                                                 shape = .data[["category"]]),
                          inherit.aes = FALSE, alpha = 0, size = size, show.legend = TRUE) +
      ggplot2::scale_shape_manual(
        name   = if (is.null(legend_title)) category_col else legend_title,
        values = pch[present], drop = FALSE) +
      ggplot2::guides(shape = ggplot2::guide_legend(
        title.position = "top",
        override.aes = list(alpha = 1, size = size, stroke = stroke,
                            colour = unname(unlist(colors[present])),
                            fill   = unname(unlist(colors[present])))))
  }
  p
}

# ── Internals ────────────────────────────────────────────────────────────────

.symbol_default_pch    <- c(21L, 24L, 22L, 23L, 25L, 8L)
# At most this many markers per element; they always fit into one row.
.symbol_max_per_tile <- 4L
.symbol_usable_width <- 0.88                   # usable tile width (a tile is 0.92 wide)
.symbol_gap          <- 0.02                   # gap between the outer edges of two markers
.symbol_edge_pad     <- 0.02                   # distance of the markers from the bottom edge
.symbol_halo_width   <- 0.5                    # width of the white edge (size units)
# Where the text goes when it is moved up (offsets from the tile centre).
.symbol_top_dy   <- 0.20
.symbol_value_dy <- -0.03

# Measured size of every point shape (pch 0-25) in tile units, as straight lines in `size`:
# width = aw * size + bw, and the distance from the point down to the bottom of the shape
# = ad * size + bd; _h with the white edge, _p without. Measured by rendering each shape at
# sizes 1, 1.8 and 3 on dark tiles at 600 dpi (stroke 0.6, white edge 0.5) and fitting lines
# (the residuals are below 0.005 of a tile). Measure again if the stroke or the edge changes.
.symbol_shapes <- data.frame(
  pch = 0:25,
  aw_h = c(0.0742, 0.0761, 0.1013, 0.106, 0.0761, 0.1055, 0.1018, 0.0742, 0.1055, 0.1055, 0.0742,
         0.1018, 0.0761, 0.0761, 0.0742, 0.0758, 0.0758, 0.1018, 0.0739, 0.0758, 0.0505, 0.0764,
         0.0678, 0.0933, 0.1015, 0.1015),
  bw_h = c(0.1675, 0.1596, 0.1895, 0.195, 0.1623, 0.1983, 0.1904, 0.1675, 0.1983, 0.1983, 0.1675,
         0.1904, 0.1596, 0.1623, 0.1675, 0.1025, 0.1025, 0.1395, 0.1058, 0.1362, 0.1021, 0.0628,
         0.0597, 0.0729, 0.0736, 0.0736),
  ad_h = c(0.0382, 0.038, 0.0294, 0.053, 0.0382, 0.0528, 0.0594, 0.0382, 0.0528, 0.0528, 0.0382,
         0.0594, 0.038, 0.0382, 0.0382, 0.038, 0.038, 0.0276, 0.0379, 0.0358, 0.0253, 0.036,
         0.0337, 0.0464, 0.0298, 0.0572),
  bd_h = c(0.0802, 0.0798, 0.0725, 0.0996, 0.0802, 0.0992, 0.1014, 0.0802, 0.0992, 0.0992,
         0.0802, 0.1014, 0.0798, 0.0802, 0.0802, 0.0503, 0.0503, 0.0441, 0.0503, 0.0721, 0.0489,
         0.0343, 0.0287, 0.0363, 0.0264, 0.0428),
  aw_p = c(0.0764, 0.0758, 0.0994, 0.106, 0.0742, 0.1074, 0.1015, 0.0764, 0.1077, 0.1077, 0.0764,
         0.1015, 0.0755, 0.0742, 0.0764, 0.0739, 0.0758, 0.1018, 0.0742, 0.0758, 0.0505, 0.0764,
         0.0655, 0.0933, 0.1015, 0.1015),
  bw_p = c(0.0628, 0.0602, 0.0765, 0.0763, 0.0657, 0.075, 0.0736, 0.0628, 0.0731, 0.0731, 0.0628,
         0.0736, 0.0622, 0.0657, 0.0628, 0.0317, 0.0265, 0.0378, 0.0318, 0.0602, 0.0514, 0.0628,
         0.0626, 0.0729, 0.0736, 0.0736),
  ad_p = c(0.0382, 0.038, 0.0275, 0.053, 0.0382, 0.0547, 0.0594, 0.0379, 0.0547, 0.0528, 0.0379,
         0.0594, 0.0378, 0.0382, 0.0379, 0.0378, 0.0378, 0.0276, 0.036, 0.0358, 0.0253, 0.036,
         0.0337, 0.0464, 0.0298, 0.0572),
  bd_p = c(0.0293, 0.0292, 0.0313, 0.0403, 0.0293, 0.0349, 0.0378, 0.0312, 0.0349, 0.0401,
         0.0312, 0.0378, 0.0311, 0.0293, 0.0312, 0.0142, 0.0142, 0.0144, 0.0173, 0.0342, 0.0236,
         0.0343, 0.0287, 0.0363, 0.0264, 0.0428)
)

.shape_coef <- function(pch, halo) {
  s <- .symbol_shapes[match(pch, .symbol_shapes$pch), ]
  sfx <- if (halo) "_h" else "_p"
  list(aw = s[[paste0("aw", sfx)]], bw = s[[paste0("bw", sfx)]],
       ad = s[[paste0("ad", sfx)]], bd = s[[paste0("bd", sfx)]])
}

# Largest size at which the markers of every element fit into one row. `pch_by_tile` is a
# list with the shapes of the markers of each element.
.symbol_fit_size <- function(pch_by_tile, halo) {
  fit <- vapply(pch_by_tile, function(p) {
    k <- .shape_coef(p, halo)
    (.symbol_usable_width - (length(p) - 1L) * .symbol_gap - sum(k$bw)) / sum(k$aw)
  }, numeric(1))
  min(fit)
}

# Offsets of the markers of one tile from the tile centre, in tile units: one row, equal
# gaps between the outer edges, centred as a group, all bottoms on the same line at the
# very bottom edge. `pch` are the shapes of the markers of this tile, in order.
.symbol_layout <- function(pch, size, halo) {
  k <- .shape_coef(pch, halo)
  w <- k$aw * size + k$bw                      # widths
  n <- length(pch)
  total <- sum(w) + (n - 1L) * .symbol_gap
  left  <- c(0, cumsum(w + .symbol_gap))[seq_len(n)]
  data.frame(dx = -total / 2 + left + w / 2,
             dy = -0.46 + .symbol_edge_pad + (k$ad * size + k$bd))
}

# The text layers that ggPSE() draws: the element symbol (label = symbol) and, if shown,
# the value (label contains formatC). Their vertical offset from the tile centre is
# written into the y mapping, e.g. -row + -0.08.
.text_layer_index <- function(plot) {
  txt <- which(vapply(plot$layers, function(l) inherits(l$geom, "GeomText"), logical(1)))
  lab <- vapply(txt, function(i) {
    q <- plot$layers[[i]]$mapping$label
    if (is.null(q)) "" else paste(deparse(rlang::quo_get_expr(q)), collapse = "")
  }, character(1))
  list(symbol = txt[lab == ".data[[\"symbol\"]]"], value = txt[grepl("formatC", lab, fixed = TRUE)])
}
.layer_dy <- function(layer) {
  q <- layer$mapping$y
  if (is.null(q)) return(NA_real_)
  tryCatch(as.numeric(rlang::eval_tidy(q, data = data.frame(col = 0, row = 0))),
           error = function(e) NA_real_)
}
.tile_text_info <- function(plot) {
  idx <- .text_layer_index(plot)
  list(idx = idx, has_value = length(idx$value) > 0L,
       symbol_dy = if (length(idx$symbol)) .layer_dy(plot$layers[[idx$symbol[1]]]) else NA_real_)
}
# Return the plot with the symbol (and value) layers moved to new offsets. The layers
# are cloned, so the plot that the user passed in is not changed.
.move_tile_text <- function(plot, info) {
  set_dy <- function(layer, dy) {
    new <- ggplot2::ggproto(NULL, layer)
    new$mapping$y <- rlang::new_quosure(rlang::expr(-.data[["row"]] + !!dy),
                                        rlang::quo_get_env(layer$mapping$y))
    new
  }
  for (i in info$idx$symbol) plot$layers[[i]] <- set_dy(plot$layers[[i]], .symbol_top_dy)
  for (i in info$idx$value)  plot$layers[[i]] <- set_dy(plot$layers[[i]], .symbol_value_dy)
  plot
}

# pch per category: named (by category) or unnamed (by position) or NULL (defaults)
.resolve_symbol_pch <- function(pch, cats) {
  n <- length(cats)
  if (is.null(pch)) return(setNames(as.list(rep_len(.symbol_default_pch, n)), cats))
  if (!is.numeric(pch) || anyNA(pch) || any(pch != round(pch)) || any(pch < 0 | pch > 25))
    stop("'pch' must be whole numbers between 0 and 25.", call. = FALSE)
  if (!is.null(names(pch))) {
    miss <- setdiff(cats, names(pch))
    if (length(miss))
      stop(sprintf("'pch' has no shape for: %s", paste(miss, collapse = ", ")), call. = FALSE)
    pch <- pch[cats]
  } else {
    if (length(pch) < n)
      stop(sprintf("'pch' has %d shapes but there are %d categories.", length(pch), n),
           call. = FALSE)
    pch <- pch[seq_len(n)]
  }
  setNames(as.list(as.integer(unname(pch))), cats)
}

.resolve_symbol_colors <- function(colors, cats) {
  n <- length(cats)
  if (is.null(colors)) return(setNames(as.list(.categorical_palette(n)), cats))
  if (!is.character(colors) || anyNA(colors))
    stop("'colors' must be a character vector of colours.", call. = FALSE)
  if (!is.null(names(colors))) {
    miss <- setdiff(cats, names(colors))
    if (length(miss))
      stop(sprintf("'colors' has no colour for: %s", paste(miss, collapse = ", ")),
           call. = FALSE)
    colors <- colors[cats]
  } else {
    if (length(colors) < n)
      stop(sprintf("'colors' has %d colours but there are %d categories.", length(colors), n),
           call. = FALSE)
    colors <- colors[seq_len(n)]
  }
  bad <- vapply(colors, function(x)
    inherits(try(grDevices::col2rgb(x), silent = TRUE), "try-error"), logical(1))
  if (any(bad))
    stop(sprintf("Invalid colour(s) in 'colors': %s", paste(colors[bad], collapse = ", ")),
         call. = FALSE)
  setNames(as.list(unname(colors)), cats)
}

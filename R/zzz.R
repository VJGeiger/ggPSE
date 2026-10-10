# Null-coalescing operator — returns x if not NULL, otherwise 
`%||%` <- function(x, y) if (!is.null(x)) x else y

# Returns "black" or "white" depending on which contrasts better against a given hex background color.
.contrast_color <- function(hex) {
  if (is.na(hex)) return("grey20")
  hex <- gsub("#", "", hex)
  r <- strtoi(substr(hex, 1, 2), 16L) / 255
  g <- strtoi(substr(hex, 3, 4), 16L) / 255
  b <- strtoi(substr(hex, 5, 6), 16L) / 255
  luminance <- 0.2126 * r + 0.7152 * g + 0.0722 * b
  if (luminance > 0.4) "grey20" else "white"
}

# Interpolates between two hex colors at position t (0-1)
.interp_hex <- function(low, high, t) {
  low  <- col2rgb(low)
  high <- col2rgb(high)
  r    <- as.integer(round(low[1] + (high[1] - low[1]) * t))
  g    <- as.integer(round(low[2] + (high[2] - low[2]) * t))
  b    <- as.integer(round(low[3] + (high[3] - low[3]) * t))
  sprintf("#%02X%02X%02X", r, g, b)
}

# Filters the element grid by groups, periods, lanthanides, actinides
.filter_grid <- function(grid, groups = NULL, periods = NULL,
                         lanthanides = TRUE, actinides = TRUE) {
  if (!is.null(groups)) {
    if (length(groups) != 2 || !is.numeric(groups))
      stop("'groups' must be a numeric vector of length 2, e.g. c(3, 12).")
    grid <- grid[grid$col >= min(groups) & grid$col <= max(groups), ]
  }
  
  if (!is.null(periods)) {
    if (length(periods) != 2 || !is.numeric(periods))
      stop("'periods' must be a numeric vector of length 2, e.g. c(4, 6).")
    grid <- grid[grid$row > 7 | (grid$row >= min(periods) &
                                   grid$row <= max(periods)), ]
  }
  
  if (!lanthanides) grid <- grid[grid$row != 9L, ]
  if (!actinides)   grid <- grid[grid$row != 10L, ]
  
  grid
}

# Normalizes values to 0-1 and computes text contrast colors
.normalize_values <- function(val, color_low, color_high, color_na) {
  val_min  <- min(val, na.rm = TRUE)
  val_max  <- max(val, na.rm = TRUE)
  norm_val <- if (val_max == val_min) {
    ifelse(is.na(val), 0.5, 0.5)
  } else {
    ifelse(is.na(val), 0.5, (val - val_min) / (val_max - val_min))
  }
  text_color <- vapply(norm_val, function(ti)
    .contrast_color(.interp_hex(color_low, color_high, ti)), character(1))
  list(norm_val = norm_val, text_color = text_color)
}

# ── Tile text layout ───────────────────────────────────────────────────────────
# Single source of truth for where the symbol, the value and the atomic number
# are drawn inside a tile. Used by ggPSE() and ggPSE_interactive().
# All offsets are in data units (a tile is 0.92 wide/high, i.e. +/- 0.46).

.symbol_positions <- c("center", "top", "bottom", "left", "right")
.number_positions <- c("top-left", "top", "top-right", "left", "right",
                       "bottom-left", "bottom", "bottom-right")

# Returns offsets + justification for the symbol and (if shown) the value.
# For "top" / "bottom" the value goes to the opposite side; for "left" / "right"
# it is stacked under the symbol. "center" reproduces the layout of
# ggPSE <= 0.2.0 exactly.
.text_layout <- function(position, show_value) {
  pad <- 0.40   # distance from tile centre for left / right anchoring
  switch(position,
    center = list(
      symbol = list(dx = 0, dy = -0.08, hjust = 0.5,
                    vjust = if (show_value) 0.15 else 0.5),
      value  = list(dx = 0, dy = -0.25, hjust = 0.5, vjust = 0.5)),
    top = list(
      symbol = list(dx = 0, dy =  0.20, hjust = 0.5, vjust = 0.5),
      value  = list(dx = 0, dy = -0.22, hjust = 0.5, vjust = 0.5)),
    bottom = list(
      symbol = list(dx = 0, dy = -0.20, hjust = 0.5, vjust = 0.5),
      value  = list(dx = 0, dy =  0.22, hjust = 0.5, vjust = 0.5)),
    # left / right: left- or right-aligned text block; the value is stacked
    # under the symbol (side by side does not fit in a tile at usual sizes)
    left = list(
      symbol = list(dx = -pad, dy = if (show_value) -0.08 else 0, hjust = 0,
                    vjust = if (show_value) 0.15 else 0.5),
      value  = list(dx = -pad, dy = -0.25, hjust = 0, vjust = 0.5)),
    right = list(
      symbol = list(dx =  pad, dy = if (show_value) -0.08 else 0, hjust = 1,
                    vjust = if (show_value) 0.15 else 0.5),
      value  = list(dx =  pad, dy = -0.25, hjust = 1, vjust = 0.5))
  )
}

# Atomic-number anchor: any of the 8 border positions of the tile.
# "top-left" reproduces the layout of ggPSE <= 0.2.0 exactly.
.number_layout <- function(position) {
  h <- (grepl("right", position)) - (grepl("left", position))    # -1, 0, 1
  v <- (grepl("top", position))   - (grepl("bottom", position))  # -1, 0, 1
  list(dx = 0.42 * h, dy = 0.38 * v,
       hjust = (h + 1) / 2, vjust = (v + 1) / 2)
}

# Number positions that collide with the symbol / value text (determined by
# rendering every combination at ~1 cm tile size, base_size = 10).
.text_zones <- function(symbol_position, show_value) {
  top    <- c("top-left", "top", "top-right")
  bottom <- c("bottom-left", "bottom", "bottom-right")
  zones <- switch(symbol_position,
    center = list(symbol = c("left", "right"), value = bottom),
    top    = list(symbol = top,    value = bottom),
    bottom = list(symbol = bottom, value = top),
    left   = list(symbol = "left",  value = c("bottom-left",  "bottom")),
    right  = list(symbol = "right", value = c("bottom-right", "bottom")))
  c(zones$symbol, if (show_value) zones$value)
}

# Warn when the atomic number would sit on top of the symbol or the value.
.check_text_collision <- function(symbol_position, number_position,
                                  show_atomic_number, show_value) {
  if (show_atomic_number &&
      number_position %in% .text_zones(symbol_position, show_value))
    warning(sprintf(
      "number_position = \"%s\" overlaps with the symbol or value text when symbol_position = \"%s\"; choose another number_position.",
      number_position, symbol_position), call. = FALSE)
  invisible(NULL)
}

# Symbol text size in ggplot2 text units (mm). NULL = scale with base_size
# (the behaviour of ggPSE <= 0.2.0).
.resolve_symbol_size <- function(symbol_size, base_size) {
  if (is.null(symbol_size)) return(base_size * 0.40)
  if (!is.numeric(symbol_size) || length(symbol_size) != 1L ||
      !is.finite(symbol_size) || symbol_size <= 0)
    stop("'symbol_size' must be a single positive number (ggplot2 text size in mm) or NULL.",
         call. = FALSE)
  symbol_size
}

# Adds the symbol, atomic-number and value text layers to a tile plot.
# `p` must be built on a data frame with columns col, row, symbol,
# atomic_number and text_color.
.add_tile_text <- function(p, symbol_position, number_position,
                           show_atomic_number, fill_col, label_value,
                           value_digits, base_size, symbol_size = NULL) {
  show_value  <- label_value && !is.null(fill_col)
  symbol_size <- .resolve_symbol_size(symbol_size, base_size)
  lay <- .text_layout(symbol_position, show_value)
  s   <- lay$symbol

  p <- p +
    ggplot2::geom_text(
      ggplot2::aes(
        x     = .data[["col"]]  + !!s$dx,
        y     = -.data[["row"]] + !!s$dy,
        label = .data[["symbol"]],
        color = .data[["text_color"]]
      ),
      fontface = "bold",
      size     = symbol_size,
      hjust    = s$hjust,
      vjust    = s$vjust
    )

  if (show_atomic_number) {
    n <- .number_layout(number_position)
    p <- p +
      ggplot2::geom_text(
        ggplot2::aes(
          x     = .data[["col"]]  + !!n$dx,
          y     = -.data[["row"]] + !!n$dy,
          label = .data[["atomic_number"]],
          color = .data[["text_color"]]
        ),
        hjust    = n$hjust,
        vjust    = n$vjust,
        size     = base_size * 0.22,
        fontface = "plain"
      )
  }

  if (show_value) {
    v <- lay$value
    p <- p +
      ggplot2::geom_text(
        ggplot2::aes(
          x     = .data[["col"]]  + !!v$dx,
          y     = -.data[["row"]] + !!v$dy,
          label = ifelse(
            is.na(.data[[fill_col]]), "",
            formatC(.data[[fill_col]], digits = value_digits, format = "f")
          ),
          color = .data[["text_color"]]
        ),
        hjust = v$hjust,
        vjust = v$vjust,
        size  = base_size * 0.20
      )
  }
  p
}

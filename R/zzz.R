# Null-coalescing operator — returns x if not NULL, otherwise 
`%||%` <- function(x, y) if (!is.null(x)) x else y

# Returns a dark or white text colour depending on which contrasts better with
# a given background colour (hex or any R colour name).
.contrast_color <- function(hex) {
  if (is.na(hex)) return("grey20")
  rgb <- grDevices::col2rgb(hex)[, 1] / 255
  luminance <- 0.2126 * rgb[[1]] + 0.7152 * rgb[[2]] + 0.0722 * rgb[[3]]
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

# TRUE for tiles that carry no data and whose text should be hidden when
# label_na = FALSE. Follows what is actually drawn: highlight mode first, then
# the value gradient. A plot without data/highlight has no "empty" tiles.
.na_mask <- function(grid, fill_col, highlight) {
  if (!is.null(highlight))    return(is.na(grid$highlight_label))
  if (!is.null(fill_col))     return(is.na(grid[[fill_col]]))
  rep(FALSE, nrow(grid))
}

# Vertical nudge in tile units (positive = up), a single finite number.
.check_nudge <- function(x, name) {
  if (!is.numeric(x) || length(x) != 1L || !is.finite(x))
    stop(sprintf("'%s' must be a single number (vertical shift in tile units).", name),
         call. = FALSE)
  invisible(NULL)
}

# Fixed text colour override (NULL = automatic contrast colour).
.check_text_color <- function(text_color) {
  if (is.null(text_color)) return(invisible(NULL))
  ok <- is.character(text_color) && length(text_color) == 1L &&
    !is.na(text_color) &&
    !inherits(try(grDevices::col2rgb(text_color), silent = TRUE), "try-error")
  if (!ok)
    stop("'text_color' must be a single valid colour (e.g. \"grey15\") or NULL.",
         call. = FALSE)
  invisible(NULL)
}

# Adds the symbol, atomic-number and value text layers to a tile plot.
# `p` must be built on a data frame with columns col, row, symbol,
# atomic_number and text_color.
.add_tile_text <- function(p, symbol_position, number_position,
                           show_atomic_number, fill_col, label_value,
                           value_digits, base_size, symbol_size = NULL,
                           hide = NULL, symbol_nudge = 0, number_nudge = 0) {
  show_value  <- label_value && !is.null(fill_col)
  symbol_size <- .resolve_symbol_size(symbol_size, base_size)
  # optional subset of tiles that get text (NULL = inherit all tiles)
  txt_data <- if (!is.null(hide) && any(hide)) p$data[!hide, , drop = FALSE]
  lay <- .text_layout(symbol_position, show_value)
  s   <- lay$symbol

  p <- p +
    ggplot2::geom_text(
      data = txt_data,
      ggplot2::aes(
        x     = .data[["col"]]  + !!s$dx,
        y     = -.data[["row"]] + !!(s$dy + symbol_nudge),
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
        data = txt_data,
        ggplot2::aes(
          x     = .data[["col"]]  + !!n$dx,
          y     = -.data[["row"]] + !!(n$dy + number_nudge),
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
        data = txt_data,
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


# ── Categorical highlight groups ───────────────────────────────────────────────

# Colour-blind safe default palette (Okabe-Ito without black), extended with
# hcl colours if more than 8 groups are needed.
.categorical_palette <- function(n) {
  base <- unname(grDevices::palette.colors(palette = "Okabe-Ito"))[-1]
  if (n <= length(base)) return(base[seq_len(n)])
  c(base, grDevices::hcl.colors(n - length(base), palette = "Dark 3"))
}

# One colour per group label: named vector (matched by name), unnamed vector
# (matched by position) or NULL (default palette).
.resolve_highlight_colors <- function(labels, cols) {
  n <- length(labels)
  if (is.null(cols)) return(as.list(.categorical_palette(n)))
  if (!is.character(cols) || anyNA(cols))
    stop("'highlight_colors' must be a character vector of colours.", call. = FALSE)
  if (!is.null(names(cols))) {
    miss <- setdiff(labels, names(cols))
    if (length(miss))
      stop(sprintf("'highlight_colors' has no colour for: %s",
                   paste(miss, collapse = ", ")), call. = FALSE)
    cols <- cols[labels]
  } else {
    if (length(cols) < n)
      stop(sprintf("'highlight_colors' has %d colours but there are %d groups.",
                   length(cols), n), call. = FALSE)
    cols <- cols[seq_len(n)]
  }
  bad <- vapply(cols, function(x)
    inherits(try(grDevices::col2rgb(x), silent = TRUE), "try-error"), logical(1))
  if (any(bad))
    stop(sprintf("Invalid colour(s) in 'highlight_colors': %s",
                 paste(cols[bad], collapse = ", ")), call. = FALSE)
  as.list(unname(cols))
}

# Error on typos, warn about elements that sit in more than one group.
.check_highlight_symbols <- function(groups) {
  valid <- .ggpse_elements()$symbol
  seen  <- character(0)
  for (g in groups) {
    unk <- setdiff(g$symbols, valid)
    if (length(unk))
      stop(sprintf("Highlight group '%s' contains unknown element symbols: %s.",
                   g$label %||% g$color, .list_values(unk)), call. = FALSE)
    seen <- c(seen, unique(intersect(g$symbols, valid)))
  }
  dup <- unique(seen[duplicated(seen)])
  if (length(dup))
    warning(sprintf("Element(s) in more than one highlight group (the last group wins): %s",
                    paste(dup, collapse = ", ")), call. = FALSE)
  invisible(NULL)
}

# Brings both accepted forms of `highlight` into the internal form
# list(list(symbols=, color=, label=), ...):
#  1. a named list of symbol vectors (+ optional `highlight_colors`)
#  2. the explicit list of groups (unchanged behaviour)
.normalize_highlight <- function(highlight, highlight_colors = NULL) {
  if (is.null(highlight)) return(NULL)
  if (!is.list(highlight) || length(highlight) == 0L)
    stop("'highlight' must be a non-empty list.", call. = FALSE)

  is_group  <- vapply(highlight, function(g) is.list(g) && !is.null(g$symbols), logical(1))
  is_vector <- vapply(highlight, function(g) is.character(g) || is.factor(g), logical(1))

  if (all(is_group)) {
    groups <- highlight
    if (!is.null(highlight_colors))
      warning("'highlight_colors' is ignored because the highlight groups define their own 'color'.",
              call. = FALSE)
  } else if (all(is_vector)) {
    labels <- names(highlight)
    if (is.null(labels) || anyNA(labels) || any(!nzchar(labels)))
      stop("A highlight list of symbol vectors must be fully named; the names are the legend labels.",
           call. = FALSE)
    if (anyDuplicated(labels))
      stop("The names of 'highlight' must be unique.", call. = FALSE)
    cols   <- .resolve_highlight_colors(labels, highlight_colors)
    groups <- lapply(seq_along(highlight), function(i)
      list(symbols = as.character(highlight[[i]]), color = cols[[i]], label = labels[[i]]))
  } else {
    stop("'highlight' must be a named list of symbol vectors, or a list of groups ",
         "list(symbols = , color = , label = ).", call. = FALSE)
  }
  .check_highlight_symbols(groups)
  unname(groups)
}

# ── Validating and joining user data ───────────────────────────────────────────

# Formats offending values for an error message (at most 10 shown).
.list_values <- function(x, max_n = 10) {
  x <- unique(x)
  shown <- ifelse(is.na(x), "NA", paste0("\"", x, "\""))
  out <- paste(utils::head(shown, max_n), collapse = ", ")
  if (length(x) > max_n) out <- paste0(out, sprintf(" (and %d more)", length(x) - max_n))
  out
}

# Every value must be an element symbol such as "Cl" (case-sensitive).
.check_symbols <- function(x, col = "symbol") {
  x   <- as.character(x)
  bad <- is.na(x) | !x %in% .ggpse_elements()$symbol
  if (any(bad))
    stop(sprintf(paste0(
      "Column '%s' must contain element symbols such as \"Cl\" ",
      "(case-sensitive, no spaces, not element names). Not recognised: %s."),
      col, .list_values(x[bad])), call. = FALSE)
  invisible(NULL)
}

# Functions that draw one value per element accept repeated rows as long as
# they agree (e.g. one data frame with a row per element and country, passed to
# both ggPSE() and ggPSE_badge()). Different values for the same element would
# be ambiguous and are an error.
.check_conflicting_values <- function(syms, values, symbol_col, value_col, fn) {
  syms <- as.character(syms)
  dup  <- unique(syms[duplicated(syms)])
  if (!length(dup) || is.null(values)) return(invisible(NULL))
  conflict <- dup[vapply(dup, function(s) length(unique(values[syms == s])) > 1L, logical(1))]
  if (length(conflict))
    stop(sprintf(paste0(
      "%s needs one value per element, but column '%s' has different values for the ",
      "same element in column '%s': %s. Aggregate first, e.g. aggregate(%s ~ %s, data, mean)."),
      fn, value_col, symbol_col, .list_values(conflict), value_col, symbol_col),
      call. = FALSE)
  invisible(NULL)
}

.check_numeric_values <- function(x, col, fn, category_hint = FALSE) {
  if (all(is.na(x)))
    stop(sprintf("Column '%s' has no non-missing values (%s).", col, fn), call. = FALSE)
  if (!is.numeric(x))
    stop(sprintf("Column '%s' must be numeric but is %s (%s).%s", col, class(x)[1], fn,
                 if (category_hint)
                   " To colour by category use highlight = split(data$symbol, data$category)."
                 else ""), call. = FALSE)
  invisible(NULL)
}

# Existence of the columns plus the content checks above. Returns the data with
# one row per element.
.validate_element_data <- function(data, symbol_col, value_col = NULL,
                                   fn = "ggPSE()", value_arg = "value_col",
                                   category_hint = FALSE) {
  if (!is.data.frame(data))
    stop(sprintf("'data' must be a data frame (%s).", fn), call. = FALSE)
  if (!symbol_col %in% names(data))
    stop(sprintf("Column '%s' not found in data. Set symbol_col to the correct column name.",
                 symbol_col), call. = FALSE)
  if (!is.null(value_col) && !value_col %in% names(data))
    stop(sprintf("Column '%s' not found in data. Set %s to the correct column name.",
                 value_col, value_arg), call. = FALSE)
  if (nrow(data) == 0L)
    stop(sprintf("'data' has no rows (%s).", fn), call. = FALSE)
  syms <- as.character(data[[symbol_col]])
  .check_symbols(syms, symbol_col)
  if (!is.null(value_col))
    .check_numeric_values(data[[value_col]], value_col, fn, category_hint)
  .check_conflicting_values(syms, if (!is.null(value_col)) data[[value_col]], symbol_col, value_col, fn)
  # repeated rows that agree: keep the first one per element
  data[!duplicated(syms), , drop = FALSE]
}

# Validates user data and joins it onto the tile grid. Returns the new grid and
# the name of the value column inside it: a value column that clashes with one
# of the grid's own columns (atomic_number, col, row) is renamed internally, so
# the data can never overwrite the tile positions.
# all_columns = TRUE keeps every column of `data` (used for tooltips).
.join_element_data <- function(grid, data, symbol_col, value_col = NULL,
                               fn = "ggPSE()", value_arg = "value_col",
                               all_columns = FALSE, category_hint = FALSE) {
  data <- .validate_element_data(data, symbol_col, value_col, fn, value_arg, category_hint)

  keep <- if (all_columns) names(data) else unique(c(symbol_col, value_col))
  data <- data[, keep, drop = FALSE]
  if (symbol_col != "symbol" && "symbol" %in% names(data)) data[["symbol"]] <- NULL

  out_value <- value_col
  grid_cols <- setdiff(names(grid), "symbol")
  if (!is.null(value_col) && value_col %in% grid_cols) {
    out_value <- ".pse_value"
    names(data)[names(data) == value_col] <- out_value
  }
  names(data)[names(data) == symbol_col] <- "symbol"

  # other columns that exist in the grid are dropped: the tile positions win
  overlap <- setdiff(intersect(names(data), grid_cols), out_value)
  data    <- data[, !names(data) %in% overlap, drop = FALSE]

  list(grid = merge(grid, data, by = "symbol", all.x = TRUE), value_col = out_value)
}

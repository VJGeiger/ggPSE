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

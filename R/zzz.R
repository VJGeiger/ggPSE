# Null-coalescing operator (base R < 4.4 does not export %||%)
`%||%` <- function(x, y) if (!is.null(x)) x else y

# Returns "black" or "white" depending on which contrasts better
# against a given hex background color.
.contrast_color <- function(hex) {
  hex <- gsub("#", "", hex)
  r   <- strtoi(substr(hex, 1, 2), 16L) / 255
  g   <- strtoi(substr(hex, 3, 4), 16L) / 255
  b   <- strtoi(substr(hex, 5, 6), 16L) / 255
  # Relative luminance (WCAG formula)
  luminance <- 0.2126 * r + 0.7152 * g + 0.0722 * b
  if (luminance > 0.4) "grey20" else "white"
}

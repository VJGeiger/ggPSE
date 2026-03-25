# Null-coalescing operator (base R < 4.4 does not export %||%)
`%||%` <- function(x, y) if (!is.null(x)) x else y

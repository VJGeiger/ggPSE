#' Overlay country-of-origin badges on a periodic table
#'
#' Adds country flags (via \pkg{ggflags}) or ISO 3166-1 alpha-2 country code
#' text labels to element tiles, indicating primary production country.
#' Useful for critical raw materials supply chain analysis.
#'
#' If \pkg{ggflags} is installed, flags are rendered automatically.
#' Otherwise falls back to text badges. Country codes must be ISO 3166-1
#' alpha-2 (e.g. "CN", "CL", "CD"). The function converts to lowercase
#' automatically for \pkg{ggflags}.
#'
#' Multiple countries per element are supported by passing multiple rows
#' per element in \code{data}. A maximum of 3 flags per tile are shown;
#' additional entries are silently dropped.
#'
#' @param plot A ggplot object to add badges to. If NULL, a blank table
#'   is created first.
#' @param data A data frame with element symbols and country codes.
#'   Multiple rows per element are allowed for multiple flags per tile.
#' @param symbol_col Character. Column containing element symbols. Default "symbol".
#' @param country_col Character. Column containing ISO 3166-1 alpha-2 country
#'   codes. Case insensitive. Default "country".
#' @param badge_size Numeric. Size of flags or text badges. Default 3.5 for
#'   flags, base_size * 0.22 for text fallback.
#' @param x_anchor Numeric. Horizontal position of rightmost flag. Default 0.38.
#' @param y_anchor Numeric. Vertical position of flags. Default 0.35.
#' @param flag_spacing Numeric. Horizontal spacing between flags. Default 0.38.
#' @param badge_color Character. Text color for text fallback badges.
#'   Default "#333333".
#' @param base_size Numeric. Base font size matching the ggPSE() call.
#'   Default NULL uses ggPSE()'s default of 10.
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' # Single country per element
#' supply <- data.frame(
#'   symbol  = c("Li", "Co", "Nd", "Pt"),
#'   country = c("CL", "CD", "CN", "ZA"),
#'   value   = c(0.70, 0.91, 0.85, 0.60)
#' )
#' ggPSE(supply, value_col = "value") |>
#'   ggPSE_badge(supply, country_col = "country")
#'
#' # Multiple countries per element
#' supply_multi <- data.frame(
#'   symbol  = c("Li", "Li", "Co", "Nd", "Nd"),
#'   country = c("CL", "AU", "CD", "CN", "RU"),
#'   value   = c(0.70, 0.70, 0.91, 0.85, 0.85)
#' )
#' ggPSE(supply_multi, value_col = "value", symbol_col = "symbol") |>
#'   ggPSE_badge(supply_multi, country_col = "country")
ggPSE_badge <- function(
    plot         = NULL,
    data,
    symbol_col = "symbol",
    country_col  = "country",
    badge_size   = NULL,
    base_size    = NULL,    
    x_anchor     = 0.38,
    y_anchor     = 0.35,
    flag_spacing = 0.38,
    badge_color  = "#333333"
) {
  if (is.null(plot)) plot <- ggPSE()
  
  if (!country_col %in% names(data))
    stop(sprintf("Column '%s' not found in data.", country_col))
  
  if (!symbol_col %in% names(data))
    stop(sprintf("Column '%s' not found in data.", symbol_col))
  
  grid <- .ggpse_elements()
  names(data)[names(data) == symbol_col] <- "symbol"
  
  badge_data <- merge(
    grid,
    data[, c("symbol", country_col), drop = FALSE],
    by = "symbol"
  )
  
  # Convert to lowercase for ggflags
  badge_data[[country_col]] <- tolower(badge_data[[country_col]])
  
  # Cap at 3 flags per element and compute horizontal index
  badge_data <- badge_data[order(badge_data$symbol), ]
  badge_data$flag_idx <- ave(
    seq_len(nrow(badge_data)),
    badge_data$symbol,
    FUN = seq_along
  )
  badge_data$flag_idx <- as.integer(badge_data$flag_idx)
  
  # Drop anything beyond 3
  badge_data <- badge_data[badge_data$flag_idx <= 3, , drop = FALSE]
  
  # x position: rightmost flag at x_anchor, each additional flag shifts left
  badge_data$flag_x <- badge_data$col + x_anchor -
    (badge_data$flag_idx - 1) * flag_spacing
  
  badge_data$flag_y <- -badge_data$row + y_anchor
  
  if (requireNamespace("ggflags", quietly = TRUE)) {
    size <- badge_size %||% 3.5 
    
    plot +
      ggflags::geom_flag(
        data        = badge_data,
        ggplot2::aes(
          x       = .data[["flag_x"]],
          y       = .data[["flag_y"]],
          country = .data[[country_col]]
        ),
        size        = size,
        inherit.aes = FALSE
      )
  } else {
    size <- badge_size %||% (base_size %||% 10) * 0.22
    
    message("Install ggflags for flag icons: remotes::install_github('rensa/ggflags')")
    
    plot +
      ggplot2::geom_text(
        data        = badge_data,
        ggplot2::aes(
          x     = .data[["flag_x"]],
          y     = .data[["flag_y"]],
          label = toupper(.data[[country_col]])
        ),
        size        = size,
        color       = badge_color,
        fontface    = "bold",
        inherit.aes = FALSE
      )
  }
}
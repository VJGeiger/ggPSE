#' Overlay country-of-origin badges on a periodic table
#'
#' Adds small ISO 3166-1 alpha-2 country code labels to element tiles,
#' indicating primary production country. Useful for critical raw materials
#' supply chain analysis.
#'
#' @param plot A ggplot object to add badges to. If NULL, a blank table
#'   is created first.
#' @param data A data frame with element symbols and country codes.
#' @param symbol_col Character. Column containing element symbols. Default "symbol".
#' @param country_col Character. Column containing ISO country codes. Default "country".
#' @param badge_size Numeric. Font size for badges. Default 1.8.
#' @param badge_color Character. Text color for badges. Default "#333333".
#' @param vjust_badge Numeric. Vertical position within tile. Default -2.2.
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' supply <- data.frame(
#'   symbol  = c("Li", "Co", "Nd", "Pt"),
#'   country = c("CL", "CD", "CN", "ZA"),
#'   value   = c(0.70, 0.91, 0.85, 0.60)
#' )
#' ggPSE(supply, value_col = "value") |>
#'   ggPSE_badge(supply, country_col = "country")
ggPSE_badge <- function(
    plot        = NULL,
    data,
    symbol_col  = "symbol",
    country_col = "country",
    badge_size  = 1.8,
    badge_color = "#333333",
    vjust_badge = -2.2
) {
  if (is.null(plot)) plot <- ggPSE()

  if (!country_col %in% names(data))
    stop(sprintf("Column '%s' not found in data.", country_col))

  grid       <- .ggpse_elements()
  names(data)[names(data) == symbol_col] <- "symbol"
  badge_data <- merge(grid, data[, c("symbol", country_col)], by = "symbol")

  plot +
    ggplot2::geom_text(
      data = badge_data,
      ggplot2::aes(
        x     = .data[["col"]],
        y     = -.data[["row"]],
        label = .data[[country_col]]
      ),
      size        = badge_size,
      color       = badge_color,
      vjust       = vjust_badge,
      fontface    = "bold",
      inherit.aes = FALSE
    )
}

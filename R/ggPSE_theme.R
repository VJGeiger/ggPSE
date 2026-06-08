#' Apply a pre-built theme to a periodic table plot
#'
#' Applies one of several pre-built visual themes to a ggPSE plot.
#'
#' Note for highlight plots, you may want to adjust the highlight colors manually
#' to suit the background.
#'
#' @param plot A ggplot object from [ggPSE()] or similar. If \code{NULL},
#'   a blank table is created first.
#' @param theme Character. One of:
#'   \describe{
#'     \item{\code{"minimal"}}{Clean white background, subtle tile borders,
#'       muted styling. Good for presentations.}
#'     \item{\code{"dark"}}{Dark background, light tile borders, white text.
#'       Good for dashboards and dark mode documents.}
#'     \item{\code{"publication"}}{Maximum ink reduction. No background,
#'       no borders, minimal chrome. Suitable for journal figures.}
#'     \item{\code{"crazy"}}{Randomly assigns a unique color to each tile.
#'       Each call produces a different result.}
#'   }
#' @param seed Integer. Random seed for \code{"crazy"} theme for
#'   reproducibility. Default \code{NULL} gives a different result each call.
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' \dontrun{
#' # Minimal
#' ggPSE() + ggPSE_theme("minimal")
#'
#' # Dark
#' ggPSE() + ggPSE_theme("dark")
#'
#' # Publication
#' ggPSE(ggpse_elements, value_col = "electronegativity") +
#'   ggPSE_theme("publication")
#'
#' # Crazy — different every time
#' ggPSE() + ggPSE_theme("crazy")
#'
#' # Crazy — reproducible
#' ggPSE() + ggPSE_theme("crazy", seed = 42)
#' }
ggPSE_theme <- function(
    plot  = NULL,
    theme = c("minimal", "dark", "publication", "crazy"),
    seed  = NULL
) {
  theme <- match.arg(theme)

  if (is.null(plot)) plot <- ggPSE()
  
  # Remove existing colour scales to avoid conflicts
  plot$scales$scales <- Filter(function(s) {
    !any(c("colour", "color", "fill") %in% s$aesthetics)
  }, plot$scales$scales)

  if (theme == "minimal") {

    plot +
      ggplot2::theme_void() +
      ggplot2::theme(
        plot.background  = ggplot2::element_rect(fill = "#ffffff", color = NA), # white background
        panel.background = ggplot2::element_rect(fill = "#ffffff", color = NA), # white background
        legend.position  = "bottom",
        legend.key.width = ggplot2::unit(2, "cm"),
        plot.margin      = ggplot2::margin(8, 8, 8, 8)
      )

  } else if (theme == "dark") {
    # originally the tile borders were targeted to be white to have a proper dark look. 
    # this was too comple for now and might be adopted in alter versions.
    
    # Dark background colors
    bg       <- "#1a1a2e"
    tile_bg  <- "#16213e"
    border   <- "#0f3460"
    text_col <- "#e0e0e0"

    # Replace tile fill for NA tiles and override plot background
    plot$layers <- lapply(plot$layers, function(l) {
      if (inherits(l$geom, "GeomTile")) {
        l$aes_params$colour <- border
      }
      l
    })

    plot +
      ggplot2::theme_void() +
      ggplot2::theme(
        plot.background  = ggplot2::element_rect(fill = bg, color = NA),
        panel.background = ggplot2::element_rect(fill = bg, color = NA),
        legend.position  = "bottom",
        legend.key.width = ggplot2::unit(2, "cm"),
        legend.text      = ggplot2::element_text(color = text_col),
        legend.title     = ggplot2::element_text(color = text_col),
        plot.margin      = ggplot2::margin(8, 8, 8, 8)
      ) +
      ggplot2::scale_color_identity()

  } else if (theme == "publication") {

    plot +
      ggplot2::theme_void() +
      ggplot2::theme(
        plot.background  = ggplot2::element_rect(fill = "transparent", color = NA),
        panel.background = ggplot2::element_rect(fill = "transparent", color = NA),
        legend.position  = "bottom",
        legend.key.width = ggplot2::unit(2.5, "cm"),
        legend.key.height = ggplot2::unit(0.3, "cm"),
        legend.title     = ggplot2::element_text(size = 8, face = "plain"),
        legend.text      = ggplot2::element_text(size = 7),
        plot.margin      = ggplot2::margin(2, 2, 2, 2)
      )

  } else {
    # crazy — random color per tile
    if (!is.null(seed)) set.seed(seed)

    n_tiles <- nrow(plot$data)
    crazy_colors <- grDevices::hcl(
      h = sample(seq(0, 360, length.out = n_tiles), n_tiles),
      c = sample(seq(50, 100, length.out = n_tiles), n_tiles),
      l = sample(seq(45, 75, length.out = n_tiles), n_tiles)
    )

    # Per-tile text contrast
    text_colors <- vapply(crazy_colors, .contrast_color, character(1))

    color_map <- stats::setNames(crazy_colors, plot$data$symbol)
    text_map  <- stats::setNames(text_colors,  plot$data$symbol)

    # Remove existing fill and text color layers
    plot$layers <- Filter(function(l) {
      !inherits(l$geom, "GeomTile")
    }, plot$layers)

    # Rebuild tiles with crazy colors
    tile_data            <- plot$data
    tile_data$crazy_fill <- crazy_colors[match(tile_data$symbol,
                                               names(color_map))]
    tile_data$crazy_text <- text_colors[match(tile_data$symbol,
                                              names(text_map))]
    
    plot +
      ggplot2::geom_tile(
        data        = tile_data,
        ggplot2::aes(
          x    = .data[["col"]],
          y    = -.data[["row"]],
          fill = .data[["crazy_fill"]]
        ),
        color       = "white",
        width       = 0.92,
        height      = 0.92,
        linewidth   = 0.3,
        inherit.aes = FALSE
      ) +
      ggplot2::geom_text(
        data        = tile_data,
        ggplot2::aes(
          x     = .data[["col"]],
          y     = -.data[["row"]],
          label = .data[["symbol"]],
          color = .data[["crazy_text"]]
        ),
        fontface    = "bold",
        size        = 3.5,
        inherit.aes = FALSE
      ) +
      ggplot2::scale_fill_identity(guide = "none") +
      ggplot2::scale_color_identity() +
      ggplot2::theme_void() +
      ggplot2::theme(
        plot.background = ggplot2::element_rect(fill = "#ffffff", color = NA),
        plot.margin     = ggplot2::margin(8, 8, 8, 8)
      )
  }
}

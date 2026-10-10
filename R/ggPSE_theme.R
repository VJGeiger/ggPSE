#' Apply a pre-built theme to a periodic table plot
#'
#' Applies one of several pre-built visual themes to a ggPSE plot. Your colour
#' scales (gradient, \code{highlight_colors}, ...) are kept; only the
#' non-data styling changes, except for \code{"crazy"}, which replaces the fill
#' colours.
#'
#' The themes are complete ggplot2 themes and replace earlier \code{theme()}
#' settings of the plot. Apply the theme first, then add your own tweaks:
#' \code{ggPSE(...) |> ggPSE_theme("publication") + theme(legend.position = "none")}.
#' The plot you pass in is not modified.
#'
#' Note for highlight plots, you may want to adjust the highlight colors manually
#' to suit the background.
#'
#' @param plot A ggplot object from [ggPSE()] or similar. If \code{NULL},
#'   a blank table is created first.
#' @param theme Character. One of:
#'   \describe{
#'     \item{\code{"minimal"}}{Clean white background, legend at the bottom.
#'       Tile borders are kept as they are. Good for presentations and the web.}
#'     \item{\code{"dark"}}{Dark background, dark tile borders, light legend
#'       text. Tiles without data and the symbol colours keep their light-theme
#'       look, so this is a starting point rather than a finished dark mode.}
#'     \item{\code{"publication"}}{For print: solid white background, thin
#'       dark-grey tile borders (so light and empty tiles stay visible in print
#'       and in greyscale; a \code{tile_border} you set yourself is kept),
#'       white tiles for elements without data (so they cannot be mistaken
#'       for the lowest values in black and white; a \code{color_na} you set
#'       yourself is kept), a compact legend with fixed small type (8 pt title, 7 pt labels), small
#'       margins and plain left-aligned title, subtitle and caption styles.
#'       Meant for figures of about 18 cm (double column). For a narrower
#'       figure use a smaller \code{base_size} in [ggPSE()] and shorten the
#'       legend bar, e.g. \code{+ theme(legend.key.width = unit(0.7, "cm"))}
#'       for 8.5 cm.}
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
#' data(ggpse_elements)
#' p <- ggPSE(ggpse_elements, value_col = "electronegativity",
#'            label_value = FALSE, legend_title = "Electronegativity")
#'
#' p |> ggPSE_theme("minimal")
#' p |> ggPSE_theme("publication")
#' p |> ggPSE_theme("dark")
#'
#' # Crazy: different every time, or reproducible with a seed
#' ggPSE() |> ggPSE_theme("crazy", seed = 42)
ggPSE_theme <- function(
    plot  = NULL,
    theme = c("minimal", "dark", "publication", "crazy"),
    seed  = NULL
) {
  if (!is.null(plot) && !inherits(plot, "ggplot"))
    stop("'plot' must be a ggplot object, e.g. ggPSE(...) |> ggPSE_theme(\"publication\").",
         call. = FALSE)
  theme <- match.arg(theme)

  if (is.null(plot)) plot <- ggPSE()

  # ggplot2 scales are reference objects: work on a copy so that the plot the
  # caller passed in is never modified
  plot$scales <- plot$scales$clone()

  if (theme == "minimal") {

    plot +
      ggplot2::theme_void() +
      ggplot2::theme(
        plot.background  = ggplot2::element_rect(fill = "#ffffff", color = NA),
        panel.background = ggplot2::element_rect(fill = "#ffffff", color = NA),
        legend.position  = "bottom",
        legend.key.width = ggplot2::unit(2, "cm"),
        plot.margin      = ggplot2::margin(8, 8, 8, 8)
      )

  } else if (theme == "dark") {
    # Dark background colors. Tiles without data and the symbol colours keep
    # their light-theme look (a proper dark mode is on the roadmap).
    bg       <- "#1a1a2e"
    border   <- "#0f3460"
    text_col <- "#e0e0e0"

    plot <- .restyle_tiles(plot, colour = border, only_if_unset = FALSE)

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
      )

  } else if (theme == "publication") {

    # hairline dark-grey borders keep pale and empty tiles visible in print
    plot <- .restyle_tiles(plot, colour = "grey30", linewidth = 0.15,
                           only_if_unset = TRUE)
    # tiles without data: white instead of light grey, so they cannot be
    # mistaken for the lowest values in black-and-white print
    plot <- .whiten_na_tiles(plot)

    plot +
      ggplot2::theme_void() +
      ggplot2::theme(
        plot.background       = ggplot2::element_rect(fill = "#ffffff", color = NA),
        panel.background      = ggplot2::element_rect(fill = "#ffffff", color = NA),
        plot.margin           = ggplot2::margin(4, 4, 4, 4, unit = "mm"),
        plot.title            = ggplot2::element_text(face = "bold", size = 10,
                                                      hjust = 0, colour = "black"),
        plot.subtitle         = ggplot2::element_text(size = 8, hjust = 0,
                                                      colour = "grey20",
                                                      margin = ggplot2::margin(b = 3)),
        plot.caption          = ggplot2::element_text(size = 6.5, hjust = 0,
                                                      colour = "grey30"),
        plot.title.position   = "plot",
        plot.caption.position = "plot",
        legend.position       = "bottom",
        legend.key.width      = ggplot2::unit(1.5, "cm"),   # colourbars are 5x this long
        legend.key.height     = ggplot2::unit(0.3, "cm"),
        legend.title          = ggplot2::element_text(size = 8, face = "plain",
                                                      colour = "black"),
        legend.text           = ggplot2::element_text(size = 7, colour = "black"),
        legend.box.spacing    = ggplot2::unit(3, "mm")
      )

  } else {
    # crazy — random color per tile; it rebuilds fills and text colours, so the
    # existing colour / fill scales are removed first to avoid conflicts
    plot$scales$scales <- Filter(function(s) {
      !any(c("colour", "color", "fill") %in% s$aesthetics)
    }, plot$scales$scales)

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

# Restyles the tile borders without touching the caller's plot. ggplot2 layers
# are reference objects, so they are cloned before being changed.
# only_if_unset = TRUE keeps borders the user has set explicitly.
.restyle_tiles <- function(plot, colour = NULL, linewidth = NULL,
                           only_if_unset = TRUE) {
  plot$layers <- lapply(plot$layers, function(l) {
    if (!inherits(l$geom, "GeomTile")) return(l)
    ap    <- l$aes_params
    unset <- is.null(ap$colour) || is.na(ap$colour) ||
      identical(ap$colour, "transparent")
    if (only_if_unset && !unset) return(l)
    l2 <- ggplot2::ggproto(NULL, l)
    if (!is.null(colour))    ap$colour    <- colour
    if (!is.null(linewidth)) ap$linewidth <- linewidth
    l2$aes_params <- ap
    l2
  })
  plot
}

# Tiles without data are drawn light grey ("#f0f0f0") by default. Make them
# white, but only if the user kept that default. Expects cloned scales.
.whiten_na_tiles <- function(plot, default = "#f0f0f0") {
  is_default <- function(x) !is.null(x) && length(x) == 1L && !is.na(x) &&
    identical(tolower(as.character(x)), default)
  for (sc in plot$scales$scales) {
    if ("fill" %in% sc$aesthetics && is_default(sc$na.value)) sc$na.value <- "white"
  }
  plot$layers <- lapply(plot$layers, function(l) {
    if (!inherits(l$geom, "GeomTile") || !is_default(l$aes_params$fill)) return(l)
    l2 <- ggplot2::ggproto(NULL, l)
    ap <- l2$aes_params; ap$fill <- "white"; l2$aes_params <- ap
    l2
  })
  plot
}

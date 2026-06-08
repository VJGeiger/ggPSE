#' Save a periodic table plot with sensible defaults
#'
#' A convenience wrapper around [ggplot2::ggsave()] with defaults tuned for
#' periodic table plots: a wide landscape aspect ratio, 400 dpi, and a
#' white background. Supports all file formats that \pkg{ggplot2} supports
#' including PNG, PDF, SVG, and TIFF.
#'
#' @param plot A ggplot or patchwork object to save. Default \code{NULL}
#'   uses the last plot displayed.
#' @param filename Character. Output file path including extension. The
#'   file format is inferred from the extension (e.g. \code{".png"},
#'   \code{".pdf"}, \code{".svg"}).
#' @param width Numeric. Plot width. Default \code{18}.
#' @param height Numeric. Plot height. Default \code{14}.
#' @param units Character. Units for width and height: \code{"cm"}
#'   (default), \code{"in"}, \code{"mm"}, or \code{"px"}.
#' @param dpi Numeric. Resolution in dots per inch. Default \code{400}.
#'   Ignored for vector formats (PDF, SVG).
#' @param bg Character. Background color. Default \code{"white"}.
#' @param ... Additional arguments passed to [ggplot2::ggsave()].
#'
#' @return Invisibly returns the file path.
#' @export
#'
#' @examples
#' \dontrun{
#' p <- ggPSE(ggpse_elements, value_col = "electronegativity")
#'
#' # PNG at default size
#' ggPSE_save(p, "electronegativity.png")
#'
#' # PDF for publication
#' ggPSE_save(p, "electronegativity.pdf")
#'
#' # SVG for web
#' ggPSE_save(p, "electronegativity.svg")
#'
#' # Custom size
#' ggPSE_save(p, "electronegativity.png", width = 24, height = 9)
#'
#' # High resolution
#' ggPSE_save(p, "electronegativity.png", dpi = 600)
#' }
ggPSE_save <- function(
    plot     = NULL,
    filename,
    width    = 18,
    height   = 14,
    units    = "cm",
    dpi      = 400,
    bg       = "white",
    ...
) {
  if (is.null(plot)) {
    ggplot2::ggsave(
      filename = filename,
      width    = width,
      height   = height,
      units    = units,
      dpi      = dpi,
      bg       = bg,
      ...
    )
  } else {
    ggplot2::ggsave(
      filename = filename,
      plot     = plot,
      width    = width,
      height   = height,
      units    = units,
      dpi      = dpi,
      bg       = bg,
      ...
    )
  }

  invisible(filename)
}

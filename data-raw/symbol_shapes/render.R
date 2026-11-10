# Renders every point shape (pch 0-25) as ggPSE_symbols() draws it, at three sizes, with and
# without the white edge, on dark tiles at 600 dpi. The images are measured by analyse.py.
# Run:  Rscript render.R <output folder>
library(ggplot2)
library(ggPSE)

out <- commandArgs(TRUE)[1]
if (is.na(out)) out <- "shapes"
dir.create(out, showWarnings = FALSE)

render <- function(size, file, halo = TRUE) {
  syms <- c("K","Ca","Sc","Ti","V","Cr","Mn","Fe","Co","Ni","Cu","Zn","Ga","Ge","As","Se","Br","Kr",
            "Rb","Sr","Y","Zr","Nb","Mo","Tc","Ru")                              # 26 tiles, one per shape
  v <- data.frame(symbol = syms, value = 1)
  base <- ggPSE(v, value_col = "value", periods = c(4, 5), colors = c("#08306b", "#08306b"),
                lanthanides = FALSE, actinides = FALSE, label_value = FALSE)
  base$layers <- base$layers[!vapply(base$layers, function(l) inherits(l$geom, "GeomText"), logical(1))]
  tiles <- unique(base$data[base$data$symbol %in% syms, c("symbol", "col", "row")])
  tiles <- tiles[match(syms, tiles$symbol), ]
  stroke <- 0.6; halo_width <- 0.5               # the values used in ggPSE_symbols()
  p <- base
  for (i in 0:25) {
    m <- data.frame(x = tiles$col[i + 1], y = -tiles$row[i + 1])
    solid <- i %in% 15:20; filled <- i %in% 21:25
    if (halo && !filled)
      p <- p + geom_point(data = m, aes(x, y), inherit.aes = FALSE, shape = i, colour = "white",
                          size = if (solid) size + 2 * halo_width else size,
                          stroke = if (solid) stroke else stroke + 2 * halo_width)
    p <- p + geom_point(data = m, aes(x, y), inherit.aes = FALSE, shape = i, size = size, stroke = stroke,
                        colour = if (filled && halo) "white" else "#D55E00", fill = "#D55E00")
  }
  ggsave(file.path(out, file), p, width = 20, height = 5, units = "cm", dpi = 600, bg = "white")
}
for (s in c(1, 1.8, 3)) {
  render(s, sprintf("halo_%.1f.png", s), halo = TRUE)
  render(s, sprintf("plain_%.1f.png", s), halo = FALSE)
}

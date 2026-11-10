# symbol_shapes

`ggPSE_symbols()` places its markers by the measured size of each point shape (`pch` 0 to 25),
so the gaps between markers are equal and all markers rest on the same bottom line. The
numbers are in `.symbol_shapes` in `R/ggPSE_symbols.R`.

To measure them again (for example after changing the stroke or the width of the white edge in
`ggPSE_symbols()`):

```
Rscript render.R shapes
python3 analyse.py shapes
```

`render.R` draws each shape at sizes 1, 1.8 and 3, with and without the white edge, on dark tiles
at 600 dpi. `analyse.py` (numpy, scipy, pillow) measures the width and the distance from the point to
the bottom of the drawn shape, fits straight lines against `size`, and prints the R code for
`.symbol_shapes`. The fits agree with the measurements to within 0.005 of a tile.

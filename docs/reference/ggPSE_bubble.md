# Plot a periodic table with bubble size encoding

Maps a continuous value to the size of a circle drawn inside each
element tile. All tiles are drawn in a neutral background color so the
bubbles are the primary visual signal. Useful when color is already used
for another variable, or when you want to show magnitude without
implying a color direction.

## Usage

``` r
ggPSE_bubble(
  data = NULL,
  size_col = NULL,
  symbol_col = "symbol",
  color_na = "#ffffff",
  tile_border = "transparent",
  bubble_color = "#2166ac",
  bubble_border = "white",
  bubble_alpha = 0.85,
  size_range = c(1, 9),
  legend_title = NULL,
  show_atomic_number = FALSE,
  base_size = 10
)
```

## Arguments

- data:

  A data frame containing element symbols and a value column. If NULL, a
  blank table is drawn.

- size_col:

  Character. Column in data to map to bubble size.

- symbol_col:

  Character. Column in data containing element symbols. Default
  "symbol".

- color_na:

  Hex color for tile backgrounds. Default "#f0f0f0".

- tile_border:

  Hex color for tile borders. Default "transparent".

- bubble_color:

  Hex fill color for bubbles. Default "#2166ac".

- bubble_border:

  Hex border color for bubbles. Default "white".

- bubble_alpha:

  Numeric. Bubble opacity 0-1. Default 0.85.

- size_range:

  Numeric vector of length 2. Min and max bubble size. Default c(1, 9).

- legend_title:

  Character. Legend title. Defaults to size_col.

- show_atomic_number:

  Logical. Show atomic numbers. Default FALSE.

- base_size:

  Numeric. Base font size in pt. Default 10.

## Value

A ggplot object.

## Examples

``` r
supply_risk <- data.frame(
  symbol = c("Li", "Co", "Nd", "Dy", "Pt", "Ni", "Cu"),
  risk   = c(0.62, 0.91, 0.84, 0.88, 0.52, 0.70, 0.45)
)
ggPSE_bubble(supply_risk, size_col = "risk",
             legend_title = "Supply risk score")
```

# Overlay sparkline or sparkbar charts on a periodic table

Draws a small time-series chart inside each element tile showing the
development of a numeric value over time. Supports both line charts
(`type = "line"`) and bar charts (`type = "bar"`).

## Usage

``` r
ggPSE_sparkline(
  plot = NULL,
  data,
  time_col = "year",
  value_col = "value",
  symbol_col = "symbol",
  type = c("line", "bar"),
  color = "#2166ac",
  color_high = NULL,
  line_width = 0.4,
  point_size = 0.8,
  alpha = 0.85,
  normalize = c("element", "global"),
  show_symbol = TRUE,
  show_axis = FALSE,
  legend_tile = TRUE,
  axis_symbol = NULL,
  axis_position = c("below", "above", "left", "right"),
  axis_width = 0.3,
  axis_height = 0.25,
  axis_color = NULL,
  axis_label_size = NULL,
  axis_title_size = NULL,
  base_size = 10
)
```

## Arguments

- plot:

  A ggplot object from \[ggPSE()\] or similar. If `NULL`, a blank table
  is created with white tile backgrounds.

- data:

  A data frame in long format with one row per element-timepoint.

- time_col:

  Character. Column containing time points. Default `"year"`.

- value_col:

  Character. Column containing numeric values. Default `"value"`.

- symbol_col:

  Character. Column containing element symbols. Default `"symbol"`.

- type:

  Character. `"line"` (default) or `"bar"`.

- color:

  Character. Line or bar color. Default `"#2166ac"`.

- color_high:

  Character. Optional diverging color for bars above element mean (only
  for `type = "bar"`). Default `NULL`.

- line_width:

  Numeric. Line width. Default `0.4`.

- point_size:

  Numeric. Point size. Set to `0` to hide. Default `0.8`.

- alpha:

  Numeric. Opacity. Default `0.85`.

- normalize:

  Character. `"element"` (default) or `"global"`.

- show_symbol:

  Logical. Redraw element symbols on top. Default `TRUE`.

- show_axis:

  Logical. Show a magnified legend tile with a full x-axis.

- legend_tile:

  Logical. Show the magnified legend tile when `show_axis = TRUE`. Set
  to `FALSE` to return the main plot only. Default `TRUE`. Requires
  patchwork. Default `FALSE`.

- axis_symbol:

  Character. Which element to show in the magnified legend tile. Default
  `NULL` uses the first element with data.

- axis_position:

  Character. Where to place the legend tile relative to the main plot:
  `"below"` (default), `"above"`, `"left"`, or `"right"`.

- axis_width:

  Numeric. Relative width of the legend tile when positioned `"left"` or
  `"right"`. Default `0.3`.

- axis_height:

  Numeric. Relative height of the legend tile when positioned `"above"`
  or `"below"`. Default `0.25`.

- axis_color:

  Character. Color of the border highlight on the legend element tile
  and the line/bar in the legend plot. Defaults to `color`.

- axis_label_size:

  Numeric. Font size for tick labels (numbers) in the legend tile.
  Default `NULL` uses `base_size`.

- axis_title_size:

  Numeric. Font size for the y-axis title in the legend tile. Default
  `NULL` uses `base_size`.

- base_size:

  Numeric. Base font size. Default `10`.

## Value

A ggplot or patchwork object.

## Details

When `show_axis = TRUE`, a minimal ruler strip is appended showing a
solid horizontal line with tick marks at each time point and labels for
the first and last time point only. Requires patchwork.

## Examples

``` r
if (FALSE) { # \dontrun{
prices <- data.frame(
  symbol = c("Li","Li","Li","Li","Li",
             "Co","Co","Co","Co","Co",
             "Ni","Ni","Ni","Ni","Ni"),
  year   = rep(2020:2024, 3),
  price  = c(6, 8, 70, 20, 15,
             30, 50, 80, 35, 25,
             14, 18, 25, 21, 17)
)

# Line chart, no axis
ggPSE() |>
  ggPSE_sparkline(prices, time_col = "year", value_col = "price")

# With magnified legend tile below
ggPSE() |>
  ggPSE_sparkline(prices, time_col = "year", value_col = "price",
                  show_axis = TRUE, axis_symbol = "Li")

# Bar chart with legend tile to the right
ggPSE() |>
  ggPSE_sparkline(prices, time_col = "year", value_col = "price",
                  type = "bar", show_axis = TRUE,
                  axis_symbol = "Co", axis_position = "right")

# Transition metals only
ggPSE(groups = c(3, 12), periods = c(4, 6),
      lanthanides = FALSE, actinides = FALSE) |>
  ggPSE_sparkline(prices, time_col = "year", value_col = "price",
                  show_axis = TRUE, axis_symbol = "Li", axis_height = 0.3)
} # }
```

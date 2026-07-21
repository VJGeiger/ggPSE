# Overlay donut or pie charts on a periodic table

Draws a small donut (or pie) chart inside each element tile showing a
categorical breakdown - for example supply mix by country, composition
by phase, or any other proportional split. Requires the ggforce package
for `geom_arc_bar()`.

## Usage

``` r
ggPSE_donut(
  plot = NULL,
  data,
  symbol_col = "symbol",
  category_col = "category",
  share_col = "share",
  r = 0.42,
  r0 = 0.2,
  colors = NULL,
  color_legend = TRUE,
  legend_title = "Category",
  base_size = 10,
  plot_all = TRUE
)
```

## Arguments

- plot:

  A ggplot object from \[ggPSE()\] or similar. If `NULL`, a blank table
  is created first.

- data:

  A data frame with one row per element-category combination.

- symbol_col:

  Character. Column containing element symbols. Default `"symbol"`.

- category_col:

  Character. Column containing category labels (e.g. country, phase,
  source). Default `"category"`.

- share_col:

  Character. Column containing shares (0-1 or percentages — values above
  1 are assumed to be percentages and divided by 100 automatically).
  Default `"share"`.

- r:

  Numeric. Outer radius of the donut as a fraction of tile width.
  Default `0.42`.

- r0:

  Numeric. Inner radius (donut hole) as a fraction of tile width.
  Default `0.20`. Set to `0` for a pie chart instead.

- colors:

  Named or unnamed character vector of fill colors for each category. If
  `NULL` (default), uses a built-in qualitative palette.

- color_legend:

  Logical. Show a color legend. Default `TRUE`.

- legend_title:

  Character. Legend title. Default `"Category"`.

- base_size:

  Numeric. Font size for element symbol labels. Default `10`.

- plot_all:

  Logical. If `TRUE` (default), labels are shown for all elements in the
  plot. If `FALSE`, labels are shown only for elements that have a donut
  chart.

## Value

A ggplot object.

## Details

The donut is automatically clipped to only show elements present in the
input plot, so subsetting via `groups`, `periods`, `lanthanides`, or
`actinides` in \[ggPSE()\] is respected. Element symbols are redrawn
centered in the donut hole on top of the arcs.

## Examples

``` r
if (FALSE) { # \dontrun{
supply <- data.frame(
  symbol   = c("Li","Li","Li", "Co","Co", "Nd","Nd", "Pt"),
  category = c("CL","AU","AR", "CD","AU", "CN","RU", "ZA"),
  share    = c(0.60, 0.30, 0.10, 0.70, 0.30, 0.80, 0.20, 1.00)
)

# All labels shown (default)
ggPSE() |>
  ggPSE_donut(supply, category_col = "category", share_col = "share")

# Only donut elements get a label
ggPSE() |>
  ggPSE_donut(supply, category_col = "category", share_col = "share",
              plot_all = FALSE)

# Pie chart (r0 = 0)
ggPSE() |>
  ggPSE_donut(supply, category_col = "category", share_col = "share",
              r0 = 0)

# Combine with gradient fill
criticality <- data.frame(
  symbol = c("Li", "Co", "Nd", "Pt"),
  value  = c(0.70, 0.91, 0.85, 0.60)
)
ggPSE(criticality, value_col = "value", legend_title = "Criticality") |>
  ggPSE_donut(supply, category_col = "category", share_col = "share",
              legend_title = "Producer")

# Respects subsetting
ggPSE(groups = c(3, 12), periods = c(4, 6),
      lanthanides = FALSE, actinides = FALSE) |>
  ggPSE_donut(supply, category_col = "category", share_col = "share")
} # }
```

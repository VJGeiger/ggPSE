# Plot a single period, group, or f-block row with a trend line

Extracts a single period (row), group (column), lanthanide row, or
actinide row from the periodic table and combines it with a line plot of
a numeric property using patchwork. Useful for visualising periodic
trends.

## Usage

``` r
ggPSE_profile(
  data,
  value_col,
  period = NULL,
  group = NULL,
  lanthanides = FALSE,
  actinides = FALSE,
  symbol_col = "symbol",
  position = NULL,
  color_high = "#9a031e",
  color_low = "#fdf0f2",
  color_na = "#f0f0f0",
  line_color = "#2166ac",
  point_color = "#2166ac",
  legend_title = NULL,
  base_size = 10,
  tile_ratio = 0.4
)
```

## Arguments

- data:

  A data frame containing element data.

- value_col:

  Character. Column name of the numeric property to plot.

- period:

  Integer. Period 1-7 to display. Mutually exclusive with `group`,
  `lanthanides`, `actinides`.

- group:

  Integer. IUPAC group 1-18 to display. Mutually exclusive with
  `period`, `lanthanides`, `actinides`.

- lanthanides:

  Logical. Plot the lanthanide row (La-Lu). Default `FALSE`.

- actinides:

  Logical. Plot the actinide row (Ac-Lr). Default `FALSE`.

- symbol_col:

  Character. Column containing element symbols. Default `"symbol"`.

- position:

  Character. Position of the line plot relative to the tile strip. For
  periods/lanthanides/actinides: `"below"` (default) or `"above"`. For
  groups: `"right"` (default) or `"left"`.

- color_high:

  Character. High end fill color. Default `"#9a031e"`.

- color_low:

  Character. Low end fill color. Default `"#fdf0f2"`.

- color_na:

  Character. NA tile fill color. Default `"#f0f0f0"`.

- line_color:

  Character. Trend line color. Default `"#2166ac"`.

- point_color:

  Character. Point color. Default `"#2166ac"`.

- legend_title:

  Character. Legend title. Defaults to `value_col`.

- base_size:

  Numeric. Base font size. Default `10`.

- tile_ratio:

  Numeric. Relative size of tile strip vs line plot. Default `0.4`.

## Value

A patchwork object.

## Details

Exactly one of `period`, `group`, `lanthanides`, or `actinides` must be
supplied.

For periods 1-3, the d-block gap is compressed and indicated with a
dashed vertical line in the line plot. Lanthanides and actinides are
never included in period strips - use `lanthanides = TRUE` or
`actinides = TRUE` to plot those rows separately.

## Examples

``` r
if (FALSE) { # \dontrun{
data(ggpse_elements)

# Period 2 — compact strip, dashed line for d-block gap
ggPSE_profile(ggpse_elements, value_col = "electronegativity", period = 2)

# Period 4 — full d-block included
ggPSE_profile(ggpse_elements, value_col = "electronegativity", period = 4)

# Group 1 — alkali metals, line to the right
ggPSE_profile(ggpse_elements, value_col = "atomic_radius_pm", group = 1)

# Lanthanide row
ggPSE_profile(ggpse_elements, value_col = "electronegativity",
              lanthanides = TRUE)

# Actinide row
ggPSE_profile(ggpse_elements, value_col = "melting_point_K",
              actinides = TRUE)
} # }
```

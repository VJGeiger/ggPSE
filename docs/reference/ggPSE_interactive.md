# Interactive periodic table with hover tooltips

Wraps \[ggPSE()\] with ggiraph interactivity. Each tile becomes
hoverable, showing a tooltip with element name, atomic number, and any
additional columns you specify. Returns a `girafe` object that renders
as an interactive SVG in HTML documents, Shiny apps, and RStudio Viewer.

## Usage

``` r
ggPSE_interactive(
  data = NULL,
  value_col = NULL,
  symbol_col = "symbol",
  label_value = TRUE,
  value_digits = 2,
  color_low = "#fdf0f2",
  color_high = "#9a031e",
  color_na = "#f0f0f0",
  tile_border = NULL,
  highlight = NULL,
  legend_title = NULL,
  show_atomic_number = FALSE,
  base_size = 10,
  groups = NULL,
  periods = NULL,
  lanthanides = TRUE,
  actinides = TRUE,
  tooltip_cols = NULL,
  tooltip_digits = 3,
  hover_fill = "#ffd700",
  hover_stroke = "#333333",
  width_svg = 12,
  height_svg = 5
)
```

## Arguments

- data:

  A data frame containing element symbols and a value column. If NULL, a
  blank table using the NA color is drawn.

- value_col:

  Character. Column name in data to map to fill color.

- symbol_col:

  Character. Column in data containing element symbols. Default
  "symbol".

- label_value:

  Logical. Print numeric values inside tiles. Default TRUE.

- value_digits:

  Integer. Decimal places for displayed values. Default 2.

- color_low:

  Hex color for the low end of the gradient. Default "#fdf0f2".

- color_high:

  Hex color for the high end of the gradient. Default "#9a031e".

- color_na:

  Hex color for elements with no data. Default "#f0f0f0".

- tile_border:

  Hex color for tile borders. If NULL (default), grey border on light
  backgrounds, transparent on dark. Set "transparent" to suppress.

- highlight:

  A list of highlight groups. Each group is a list with:

  symbols

  : Character vector of element symbols to highlight.

  color

  : Fill color for highlighted tiles.

  label

  : Optional legend label for this group.

  Example:
  `list(list(symbols = c("Li","Co"), color = "#2166ac", label = "Battery metals"))`

- legend_title:

  Character. Legend title. Defaults to value_col.

- show_atomic_number:

  Logical. Show atomic numbers in top-left of tile. Default FALSE.

- base_size:

  Numeric. Base font size in pt. Default 8.

- groups:

  Integer vector of length 2. Range of IUPAC groups (columns) to
  display, e.g. `c(3, 12)` for transition metals only. Default NULL
  shows all groups.

- periods:

  Integer vector of length 2. Range of periods (rows 1-7) to display,
  e.g. `c(4, 6)` for periods 4 to 6. Default NULL shows all periods.
  Note: lanthanides and actinides are controlled separately via
  `lanthanides` and `actinides`.

- lanthanides:

  Logical. Show the lanthanide row. Default TRUE.

- actinides:

  Logical. Show the actinide row. Default TRUE.

- tooltip_cols:

  Character vector of column names from `data` to include in the
  tooltip. Element name and atomic number are always shown. Default
  `NULL` shows only name, atomic number, and `value_col` if supplied.

- tooltip_digits:

  Integer. Decimal places for numeric tooltip values. Default `3`.

- hover_fill:

  Character. Tile fill color on hover. Default `"#ffd700"` (gold).

- hover_stroke:

  Character. Tile border color on hover. Default `"#333333"`.

- width_svg:

  Numeric. Width of the SVG output in inches. Default `12`.

- height_svg:

  Numeric. Height of the SVG output in inches. Default `5`.

## Value

A `girafe` object (interactive SVG).

## Details

Requires the ggiraph package. Install with:
`install.packages("ggiraph")`

## Examples

``` r
if (FALSE) { # \dontrun{
battery <- data.frame(
  symbol     = c("Li", "Co", "Ni", "Mn", "Fe"),
  importance = c(0.95, 0.88, 0.75, 0.60, 0.45)
)
ggPSE_interactive(battery,
                  value_col    = "importance",
                  legend_title = "Battery relevance")

# Show extra columns in tooltip
data(ggpse_elements)
ggPSE_interactive(ggpse_elements,
                  value_col    = "electronegativity",
                  tooltip_cols = c("name", "atomic_weight",
                                   "electronegativity", "block"),
                  legend_title = "Electronegativity (Pauling)")
} # }
```

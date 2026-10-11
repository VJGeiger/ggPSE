# Plot a periodic table with a continuous value overlay

The core plotting function of ggPSE. Returns a ggplot2 object that can
be further modified.

## Usage

``` r
ggPSE(
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
  symbol_position = "center",
  number_position = "top-left",
  symbol_size = NULL,
  label_na = TRUE,
  text_color = NULL,
  symbol_nudge = 0,
  number_nudge = 0,
  highlight_colors = NULL
)
```

## Arguments

- data:

  A data frame with the element symbols (case-sensitive, e.g. `"Cl"`)
  and the value column. Rows may repeat for an element (e.g. one row per
  country) as long as they agree on the value; different values for the
  same element, unknown or `NA` symbols and non-numeric values give an
  error. If `NULL`, a blank table using the NA color is drawn.

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

  Color for tile borders. If NULL (default) no border is drawn
  (`"transparent"`). Set a color such as `"white"` or `"grey30"` to draw
  borders.

- highlight:

  Elements to colour by category. Either

  - a *named list of symbol vectors*, e.g.
    `list("Alkali metals" = c("Li", "Na", "K"), Halogens = c("F", "Cl"))`.
    The names become the legend labels and the list order the legend
    order. `split(df$symbol, df$category)` gives such a list; use a
    factor for `category` to control the order. Colours come from
    `highlight_colors`.

  - or a list of groups, each a list with `symbols` (character vector of
    element symbols), `color` (fill color) and an optional `label`
    (legend label), e.g.
    `list(list(symbols = c("Li","Co"), color = "#2166ac", label = "Battery metals"))`.

  Unknown symbols and elements listed in more than one group give a
  warning (in that case the last group wins).

- legend_title:

  Character. Legend title. Defaults to value_col; for `highlight` groups
  there is no title unless you set one.

- show_atomic_number:

  Logical. Show atomic numbers inside the tile. Default FALSE. See
  `number_position` for where it is drawn.

- base_size:

  Numeric. Base font size in pt. Default 10.

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

- symbol_position:

  Where the element symbol is drawn inside the tile: `"center"`
  (default), `"top"`, `"bottom"`, `"left"` or `"right"`. If a value
  label is shown (`label_value = TRUE`), it is placed on the opposite
  side for `"top"` / `"bottom"`, and stacked under the symbol for
  `"left"` / `"right"`.

- number_position:

  Where the atomic number is drawn when `show_atomic_number = TRUE`:
  `"top-left"` (default), `"top"`, `"top-right"`, `"left"`, `"right"`,
  `"bottom-left"`, `"bottom"` or `"bottom-right"`. A warning is given if
  it overlaps with the symbol or value text.

- symbol_size:

  Size of the element symbol in ggplot2 text units (mm, as in the `size`
  argument of `geom_text()`). Default `NULL` scales with `base_size`
  (`base_size * 0.4`). Only the symbol is affected; the value and atomic
  number keep scaling with `base_size`. Large symbols need more room,
  see `symbol_position`.

- label_na:

  Logical. Draw symbols (and atomic numbers / values) on tiles without
  data? Default `TRUE`. With `FALSE`, tiles that have no value (or are
  not part of a `highlight` group) stay blank, which is useful when only
  a subset of elements is covered by your data. Ignored when neither
  `value_col` nor `highlight` is given.

- text_color:

  A single colour used for all tile text instead of the automatic
  black/white contrast colour. Default `NULL`. Useful when the fill
  scale is replaced afterwards (e.g. with `scale_fill_gradient2()`),
  because the automatic colour is derived from `color_low` /
  `color_high`.

- symbol_nudge, number_nudge:

  Numeric. Vertical shift of the symbol / atomic number in tile units (a
  tile is 0.92 high; positive moves up), added to the position set by
  `symbol_position` / `number_position`. Default `0`. The value label is
  not moved, and the overlap warning does not take the nudge into
  account.

- highlight_colors:

  Colours for a named-list `highlight`: either a vector named by group
  (order does not matter, extra names are ignored) or an unnamed vector
  matched by position. Any R colour is accepted. Default `NULL` uses a
  colour-blind-safe palette (Okabe-Ito, extended beyond 8 groups).
  Ignored, with a warning, if the groups carry their own `color`.

## Value

A ggplot object.

## Examples

``` r
battery <- data.frame(
  symbol     = c("Li", "Co", "Ni", "Mn", "Fe"),
  importance = c(0.95, 0.88, 0.75, 0.60, 0.45)
)
ggPSE(battery, value_col = "importance", legend_title = "Battery relevance")


ggPSE(highlight = list(
  list(symbols = c("Li", "Co", "Ni"), color = "#2166ac", label = "Battery"),
  list(symbols = c("Nd", "Dy", "Tb"), color = "#e63946", label = "Magnets")
))


# Categories from a named list, with your own colours
ggPSE(highlight = list(Alkali = c("Li", "Na", "K"), Halogens = c("F", "Cl", "Br")),
      highlight_colors = c(Alkali = "firebrick", Halogens = "steelblue"),
      legend_title = "Group")


# Show only transition metals (groups 3-12, periods 4-6)
ggPSE(groups = c(3, 12), periods = c(4, 6), lanthanides = FALSE, actinides = FALSE)


# Symbol at the top, atomic number in the bottom-right corner
ggPSE(battery, value_col = "importance",
      symbol_position = "top", show_atomic_number = TRUE,
      number_position = "bottom-right")
#> Warning: number_position = "bottom-right" overlaps with the symbol or value text when symbol_position = "top"; choose another number_position.


# Smaller symbols independent of base_size
ggPSE(battery, value_col = "importance", symbol_size = 3)


# Only label the elements that have data, with one fixed text colour
ggPSE(battery, value_col = "importance", label_na = FALSE, text_color = "grey15")


# Fine-tune: symbol slightly above its position
ggPSE(battery, value_col = "importance", symbol_position = "top",
      symbol_nudge = 0.05)
```

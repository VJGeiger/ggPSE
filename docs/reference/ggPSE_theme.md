# Apply a pre-built theme to a periodic table plot

Applies one of several pre-built visual themes to a ggPSE plot. Your
colour scales (gradient, `highlight_colors`, ...) are kept; only the
non-data styling changes, except for `"crazy"`, which replaces the fill
colours.

## Usage

``` r
ggPSE_theme(
  plot = NULL,
  theme = c("minimal", "dark", "publication", "crazy"),
  seed = NULL
)
```

## Arguments

- plot:

  A ggplot object from \[ggPSE()\] or similar. If `NULL`, a blank table
  is created first.

- theme:

  Character. One of:

  `"minimal"`

  : Clean white background, legend at the bottom. Tile borders are kept
    as they are. Good for presentations and the web.

  `"dark"`

  : Dark background, dark tile borders, light legend text. Tiles without
    data and the symbol colours keep their light-theme look, so this is
    a starting point rather than a finished dark mode.

  `"publication"`

  : For print: solid white background, thin dark-grey tile borders (so
    light and empty tiles stay visible in print and in greyscale; a
    `tile_border` you set yourself is kept), white tiles for elements
    without data (so they cannot be mistaken for the lowest values in
    black and white; a `color_na` you set yourself is kept), a compact
    legend with fixed small type (8 pt title, 7 pt labels), small
    margins and plain left-aligned title, subtitle and caption styles.
    Meant for figures of about 18 cm (double column). For a narrower
    figure use a smaller `base_size` in \[ggPSE()\] and shorten the
    legend bar, e.g. `+ theme(legend.key.width = unit(0.7, "cm"))` for
    8.5 cm.

  `"crazy"`

  : Randomly assigns a unique color to each tile. Each call produces a
    different result.

- seed:

  Integer. Random seed for `"crazy"` theme for reproducibility. Default
  `NULL` gives a different result each call.

## Value

A ggplot object.

## Details

The themes are complete ggplot2 themes and replace earlier `theme()`
settings of the plot. Apply the theme first, then add your own tweaks:
`ggPSE(...) |> ggPSE_theme("publication") + theme(legend.position = "none")`.
The plot you pass in is not modified.

Note for highlight plots, you may want to adjust the highlight colors
manually to suit the background.

## Examples

``` r
data(ggpse_elements)
p <- ggPSE(ggpse_elements, value_col = "electronegativity",
           label_value = FALSE, legend_title = "Electronegativity")

p |> ggPSE_theme("minimal")

p |> ggPSE_theme("publication")

p |> ggPSE_theme("dark")


# Crazy: different every time, or reproducible with a seed
ggPSE() |> ggPSE_theme("crazy", seed = 42)
```

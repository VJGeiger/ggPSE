# Apply a pre-built theme to a periodic table plot

Applies one of several pre-built visual themes to a ggPSE plot.

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

  : Clean white background, subtle tile borders, muted styling. Good for
    presentations.

  `"dark"`

  : Dark background, light tile borders, white text. Good for dashboards
    and dark mode documents.

  `"publication"`

  : Maximum ink reduction. No background, no borders, minimal chrome.
    Suitable for journal figures.

  `"crazy"`

  : Randomly assigns a unique color to each tile. Each call produces a
    different result.

- seed:

  Integer. Random seed for `"crazy"` theme for reproducibility. Default
  `NULL` gives a different result each call.

## Value

A ggplot object.

## Details

Note for highlight plots, you may want to adjust the highlight colors
manually to suit the background.

## Examples

``` r
if (FALSE) { # \dontrun{
# Minimal
ggPSE() + ggPSE_theme("minimal")

# Dark
ggPSE() + ggPSE_theme("dark")

# Publication
ggPSE(ggpse_elements, value_col = "electronegativity") +
  ggPSE_theme("publication")

# Crazy — different every time
ggPSE() + ggPSE_theme("crazy")

# Crazy — reproducible
ggPSE() + ggPSE_theme("crazy", seed = 42)
} # }
```

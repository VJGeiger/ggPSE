# Save a periodic table plot with sensible defaults

A convenience wrapper around \[ggplot2::ggsave()\] with defaults tuned
for periodic table plots: a wide landscape aspect ratio, 400 dpi, and a
white background. Supports all file formats that ggplot2 supports
including PNG, PDF, SVG, and TIFF.

## Usage

``` r
ggPSE_save(
  plot = NULL,
  filename,
  width = 18,
  height = 14,
  units = "cm",
  dpi = 400,
  bg = "white",
  ...
)
```

## Arguments

- plot:

  A ggplot or patchwork object to save. Default `NULL` uses the last
  plot displayed.

- filename:

  Character. Output file path including extension. The file format is
  inferred from the extension (e.g. `".png"`, `".pdf"`, `".svg"`).

- width:

  Numeric. Plot width. Default `18`.

- height:

  Numeric. Plot height. Default `14`.

- units:

  Character. Units for width and height: `"cm"` (default), `"in"`,
  `"mm"`, or `"px"`.

- dpi:

  Numeric. Resolution in dots per inch. Default `400`. Ignored for
  vector formats (PDF, SVG).

- bg:

  Character. Background color. Default `"white"`.

- ...:

  Additional arguments passed to \[ggplot2::ggsave()\].

## Value

Invisibly returns the file path.

## Examples

``` r
if (FALSE) { # \dontrun{
p <- ggPSE(ggpse_elements, value_col = "electronegativity")

# PNG at default size
ggPSE_save(p, "electronegativity.png")

# PDF for publication
ggPSE_save(p, "electronegativity.pdf")

# SVG for web
ggPSE_save(p, "electronegativity.svg")

# Custom size
ggPSE_save(p, "electronegativity.png", width = 24, height = 9)

# High resolution
ggPSE_save(p, "electronegativity.png", dpi = 600)
} # }
```

# ggPSE <img src="man/figures/logo.png" align="right" height="139"/>

<!-- badges: start -->
[![R-CMD-check](https://github.com/VJGeiger/ggPSE/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/VJGeiger/ggPSE/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

**ggPSE** is a ggplot2-based toolkit for visualizing PSE (periodic system of elements) data. Every function returns a `ggplot2` object - so plots can be extended.

---
## Disclaimer

This is an old script I wrote back in the day of my PhD thesis and never uploaded. Right now, this is a small pet project with low maintenance and I do not put in SERIOUS effort.
Furthermore, this is my first published R project, so, keep that in mind... 

---

## Installation

```r
# Install from GitHub (requires remotes)
remotes::install_github("VJGeiger/ggPSE")
```

If you want to plot with country flag badges :us: :it: :uk:, also install ggflags (not on CRAN, but GitHub):

```r
remotes::install_github("rensa/ggflags")
```

---

## Quick start

```r
library(ggPSE)

# Blank periodic table
ggPSE()
```
![](man/figures/ggPSE_plot.png)

```r
# Color gradient from your own data
battery <- data.frame(
  symbol     = c("Li", "Co", "Ni", "Mn", "Fe", "P", "C"),
  importance = c(0.95, 0.88, 0.75, 0.60, 0.45, 0.40, 0.35)
)
ggPSE(battery, value_col = "importance", legend_title = "Battery relevance")
```

---

## Visualization modes

### Color gradient — `ggPSE()`

Map any numeric variable to a fill color gradient across all elements.

```r
ggPSE(battery,
      value_col    = "importance",
      color_low    = "#f7fbff",
      color_high   = "#08306b",
      legend_title = "Battery relevance")
```

### Highlight element groups — `ggPSE(highlight = ...)`

Color named subsets of elements with a legend entry per group.

```r
ggPSE(highlight = list(
  list(symbols = c("Li", "Co", "Ni", "Mn", "Fe", "P"),
       color   = "#2166ac",
       label   = "Battery metals"),
  list(symbols = c("Nd", "Dy", "Tb", "Pr", "La", "Ce"),
       color   = "#e63946",
       label   = "Rare earth magnets")
))
```

### Bubble size encoding — `ggPSE_bubble()`

Map a numeric variable to bubble size on a clean white background.

```r
supply_risk <- data.frame(
  symbol = c("Li", "Co", "Nd", "Dy", "Pt", "Rh", "In", "Ga"),
  risk   = c(0.62, 0.91, 0.84, 0.88, 0.52, 0.70, 0.78, 0.65)
)
ggPSE_bubble(supply_risk, size_col = "risk", legend_title = "Supply risk")
```

### In-tile bar encoding — `ggPSE_bar()`

Draw a proportional bar inside each tile growing from a chosen edge
(`"bottom"`, `"top"`, `"left"`, or `"right"`).

```r
ggPSE_bar(supply_risk, value_col = "risk",
          bar_side  = "bottom",
          bar_color = "#2166ac",
          legend_title = "Supply risk")
```

### Country-of-origin badges — `ggPSE_badge()`

Overlay country flags (via ggflags) or ISO 3166-1 alpha-2 text codes.
Up to three flags per tile are supported.

```r
supply <- data.frame(
  symbol  = c("Li", "Co", "Nd", "Pt"),
  country = c("CL", "CD", "CN", "ZA"),
  value   = c(0.70, 0.91, 0.85, 0.60)
)
ggPSE(supply, value_col = "value", legend_title = "Criticality") |>
  ggPSE_badge(supply, country_col = "country")
```

---

## Built-in element data

ggPSE ships with `ggpse_elements`, a data frame of 17 physical and chemical
properties for all 118 elements (IUPAC 2021, NIST WebBook, Pauling 1960):

```r
data(ggpse_elements)
ggPSE(ggpse_elements, value_col = "electronegativity",
      legend_title = "Electronegativity (Pauling)")
```

---

## Saving figures

```r
p <- ggPSE(battery, value_col = "importance")
ggsave("pse.pdf", p, width = 18, height = 8, units = "cm")
ggsave("pse.png", p, width = 18, height = 8, units = "cm", dpi = 300)
```

---

## Roadmap

See [TODO.md](TODO.md) for the full roadmap including planned interactivity
via `ggiraph`, sparkline tiles for time-series data, and supply chain
visualization features.

---

## Contributing

Issues and pull requests welcome. Please open an issue before starting
significant work so we can discuss the approach first.

---

## Citation

If you use ggPSE in a publication, please cite it as:

```
Valentin Geiger (2025). ggPSE: Periodic Table Visualization with ggplot2.
R package version 0.1.0. https://github.com/VJGeiger/ggPSE
```
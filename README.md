# ggPSE <img src="man/figures/logo.png" align="right" height="139"/>

<!-- badges: start -->
[![R-CMD-check](https://github.com/VJGeiger/ggPSE/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/VJGeiger/ggPSE/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

**ggPSE** is a ggplot2-based toolkit for visualizing element-resolved data on
the periodic table of elements. It returns standard `ggplot2` objects — so
every plot can be extended with additional layers, scales, and themes, or
composed with `patchwork` and `cowplot`.

---

## Installation

```r
# Install from GitHub (requires remotes)
remotes::install_github("yourname/ggPSE")
```

---

## Quick start

```r
library(ggPSE)
library(ggplot2)

# Blank periodic table
ggPSE()

# Color gradient from your own data
dat <- data.frame(
  symbol = c("Li", "Co", "Ni", "Mn", "Cu", "Fe"),
  price  = c(22, 55, 14, 3, 9, 1)
)
ggPSE(dat, value_col = "price", legend_title = "Price (USD/kg)")
```

---

## Visualization modes

### Color gradient — `ggPSE()`

Map any numeric variable to a fill color gradient across all elements.

```r
ggPSE(dat, value_col = "price", color_low = "#f7fbff", color_high = "#08306b")
```

### Highlight selected elements — `ggPSE_highlight()`

Add colored borders to a named subset of elements. Call multiple times for
multiple groups.

```r
ggPSE() +
  ggPSE_highlight(c("Li", "Co", "Ni", "Mn"), color = "#1565c0",
                label = "Battery metals") +
  ggPSE_highlight(c("Nd", "Pr", "Dy"),       color = "#e65100",
                label = "Magnet REEs")
```

### Size encoding — `ggPSE_bubble()`

Map a numeric variable to bubble size inside each tile. Combine with a
gradient for dual encoding.

```r
ggPSE(dat, value_col = "price") +
  ggPSE_bubble(dat, value_col = "demand", color = "#333333", alpha = 0.4)
```

### Text badges — `ggPSE_badge()`

Overlay short text on tiles — useful for ISO country codes showing primary
production sources.

```r
supply <- data.frame(
  symbol  = c("Co", "Li", "Nd", "Ga"),
  country = c("CD", "CL", "CN", "CN")
)
ggPSE() +
  ggPSE_highlight(supply$symbol, color = "#c62828") +
  ggPSE_badge(supply, badge_col = "country")
```

### Composing layers

Because `ggPSE()` returns a plain ggplot2 object, the full ggplot2 grammar
works naturally:

```r
ggPSE(dat, value_col = "price") +
  ggPSE_highlight(c("Li", "Co", "Ni"), color = "#1565c0") +
  ggPSE_badge(supply, badge_col = "country") +
  scale_fill_viridis_c(name = "Price (USD/kg)", na.value = "#eeeeee") +
  labs(title = "Critical battery metal prices and primary producers",
       caption = "Source: USGS Mineral Commodity Summaries 2024") +
  theme(plot.title = element_text(size = 11, face = "bold"))
```

### Small multiples with facet_wrap()

```r
# dat_multi has columns: symbol, value, condition
ggPSE(dat_multi, value_col = "value") +
  facet_wrap(~condition)
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
Your Name (2025). ggPSE: Periodic Table Visualization with ggplot2.
R package version 0.1.0. https://github.com/yourname/ggPSE
```

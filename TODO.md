# ggPSE — roadmap and todo

The roadmap summarizes what features are upcoming and some ideas. Roughly ordered by priority within each section.

---
## v0.2.0 
- [ ] ggPSE_group() and ggPSE_period: Density or trendlines 


## v0.3.0 — advanced visualization modes

- [ ] `pse_sparkline()` - mini chart per tile for time-series data
  - Decide implementation strategy: `annotation_custom()` grobs vs separate function
  - Target use case: commodity price development over 5 years
- [ ] Dual-value tile: diagonal split encoding two variables simultaneously
  - Top-left triangle = variable A, bottom-right = variable B
  - Requires custom geom - plan for this carefully
- [ ] `pse_facet()` helper - convenience wrapper for `facet_wrap()` over the PSE
  - Main challenge: legend and axis consistency across facets
  - Document the `facet_wrap(~condition)` pattern explicitly

---

## known issues / technical debt
- [ ] `ggnewscale` in Suggests: when both `value_col` and `highlight` are supplied
  simultaneously, scale conflict occurs — proper fix needs `ggnewscale::new_scale_fill()`
- [ ] `ggPSE_bubble()` combined with `ggPSE()`: using both together requires
  manual legend cleanup — document the recommended pattern or add a combined helper
- [ ] `coord_fixed()` in `ggPSE()` interacts badly with `patchwork` multi-panel
  layouts — investigate and document workaround
- [ ] Lanthanide/actinide row gap: currently hardcoded as row 9/10 offset —
  consider making the gap size a parameter
- [ ] `ggflags` not on CRAN — installation requires `remotes::install_github("rensa/ggflags")`
  and system libraries (`libjpeg-turbo-devel`, `libpng-devel` on Fedora/RHEL)

---

## ideas / maybe someday
**here realism stops and dreams begin** 
- [ ] `ggPSE_profile()`: Function that allows the selection of a group or a period 
  and plots a line plots of a parameter next to it.
- [ ] trendlines over the PSE
- [ ] adding of brackets to describe certain groups
- [ ] ggPSE_trends: adding the option for visualizing continous trends along the PSE.
- [ ] ggPSE_shape(): leveraging pattern instead of tiles to magnify parts of the PSE.
- [ ] using `ggdensity` package to visualize certain clusters
- [ ] update ggPSE_badge(): add sizing of the flags as another parameter to create a sort of hierarchy.
- [ ] ggPSE_sparkbar(): A per-tile bar chart displaying continous values.
- [ ] ggPSE_connect(): connect elements in either a "graph-style" or alluvial-style
- [ ] Shiny app companion: upload CSV, see PSE update live
- [ ] Include oxidation states as information
- [ ] `ggPSE_left_step()` - Janet left-step periodic table layout
- [ ] Export helper: `save_pse()` wrapping `ggsave()` with sensible PSE defaults
  (aspect ratio, resolution)
- [ ] ggplot2 extension: proper `StatPSE` so users can use `ggplot(data) + stat_pse()`
  idiom natively
- [ ] Add `pse_theme()` - a few pre-built theme variants (minimal, dark, publication)
- [ ] pkgdown site setup (`_pkgdown.yml`)
- [ ] Publishing on CRAN
- [ ] Implementing flowmapper or ggarrow

---

## Done

- [x] Initial proof-of-concept script (original research script)
- [x] Rewrote without custom grob machinery - replaced with `geom_tile()` + `geom_text()`
- [x] Core test suite covering all exported functions
- [x] `ggPSE_highlight()` deleted — merged into `ggPSE()` via `highlight` parameter
- [x] `.interp_hex()` moved to `R/zzz.R` as package-level internal helper
- [x] Two datasets: `ggpse_grid` (4 cols) and `ggpse_elements` (17 cols, IUPAC 2021 + NIST)
- [x] NAMESPACE generated via roxygenise()
- [x] Tile border parameter with transparent default
- [x] Per-tile text contrast via WCAG luminance calculation
- [x] Atomic number display in top-left corner via `show_atomic_number`

### v0.1.0 - get it working

- [x] Finalize `ggPSE()` function
  - [x] introduce adaptive colors
  - [x] optimize styling for basic plots
  - [x] fix text overlaps when `show_atom_label = TRUE`
  - [x] add `highlight` parameter for discrete element groups with legend
  - [x] add `tile_border` parameter with auto-detection
- [x] Write `data-raw/prepare_element_data.R` - have option for built-in small data set or periodicsystem bigger data set.
- [x] Change the ggPSE_highlight() to a simple highlight option in ggPSE()
- [x] Finalize `ggPSE_badge()` - country flags via ggflags, text fallback, up to 3 flags per tile
- [x] Finalize `ggPSE_bubble()` - white tile background, bubble-only signal, NA rows filtered silently
- [x] Finalize `ggPSE_bar()` - in-tile bar encoding, 4 sides, fixed thickness, proportional length
- [x] Write roxygen2 docs for all exported functions
- [x] Run `rcmdcheck::rcmdcheck()` - reach zero errors, zero warnings, zero notes
- [x] Write introduction vignette (`vignettes/getting-started.Rmd`)
- [x] Write a `README.md` with install instructions and a minimal example with output image

---

## v0.2.0 — updates for usecases

### new features
- [x] zooming for subsets of data
- [x] `ggPSE_donut()` - doughtnut/pie chart per tile showing supply mix by country
  
### interactivity

- [x] Add `ggPSE_interactive()` wrapper using `ggiraph`
  - Tooltip content configurable via a `tooltip_cols` argument
- [x] Test `ggiraph` output in Quarto HTML documents
- [x] Test `ggiraph` output in Shiny


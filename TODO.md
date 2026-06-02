# ggPSE — roadmap and todo

Currently under construction. Roughly ordered by priority within each section.

---

## v0.1.0 — get it working (current focus)

### Must-have before any public release
- [x] Finalize `ggPSE()` function
  - [x] introduce adaptive colors
  - [x] optimize styling for basic plots
  - [x] fix text overlaps when `show_atom_label = TRUE`
- [x] Write `data-raw/prepare_element_data.R` - have option for built-in small data set or periodicsystem bigger data set.
- [x] Change the ggPSE_highlight() to a simple highlight option
- [x] Finalize `ggPSE_badge()` - test overflow behavior for long badge strings
- [x] Decide on meaningfulness and use of `ggPSE_bubble()` - validate scale_size_area interaction with ggplot2 fill scale
- [x] Write roxygen2 docs for all exported functions
- [ ] Run `rcmdcheck::rcmdcheck()` - reach zero errors, zero warnings, zero notes
- [ ] Write introduction vignette (`vignettes/introduction.Rmd`)
- [ ] Write a `README.md` with install instructions and a minimal example with output image

---

## v0.2.0— interactivity

### interactivity

- [ ] Add `ggPSE_interactive()` wrapper using `ggiraph`
  - Hover tooltip showing element name, atomic number, and user value
  - Tooltip content configurable via a `tooltip_cols` argument
- [ ] Test `ggiraph` output in Quarto HTML documents
- [ ] Test `ggiraph` output in Shiny

### documentation
- [ ] Vignette: interactive PSE in a Quarto document

### new features
- [ ] introduce optional selection of showcased groups
---

## v0.3.0 supply chain / critical materials features

- [ ] `pse_supply()` - pie chart per tile showing supply mix by country
  - Needs `ggforce::geom_arc_bar()` or custom grob
  - Input: data frame with symbol, country, share (%) columns
- [ ] Bundle a `critical_materials` dataset
  - EU Critical Raw Materials Act list
  - Primary production country (ISO codes)
  - Basic price history (source: USGS Mineral Commodity Summaries)
- [ ] Vignette: critical raw materials supply chain analysis

---

## v0.4.0 — advanced visualization modes

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

- [ ] `ggPSE_highlight()` legend: multiple groups via repeated calls doesn't compose
  cleanly - investigate `ggnewscale::new_scale_color()` as solution
- [ ] `ggPSE_bubble()` + `ggPSE()` gradient: two separate legends for fill and size
  need manual cleanup - document workaround or fix
- [ ] `coord_fixed()` in `ggPSE()` interacts badly with `patchwork` multi-panel
  layouts - investigate and document workaround
- [ ] Lanthanide/actinide row gap: currently hardcoded as row 9/10 offset —
  consider making the gap size a parameter

---

## ideas / maybe someday

- [ ] Shiny app companion: upload CSV, see PSE update live
- [ ] Include oxidation states as information.
- [ ] `ggPSE_left_step()` - Janet left-step periodic table layout
- [ ] Export helper: `save_pse()` wrapping `ggsave()` with sensible PSE defaults
  (aspect ratio, resolution)
- [ ] ggplot2 extension: proper `StatPSE` so users can use `ggplot(data) + stat_pse()`
  idiom natively
- [ ] Add `pse_theme()` - a few pre-built theme variants (minimal, dark, publication)
- [ ] pkgdown site setup (`_pkgdown.yml`)
- [ ] publishing on CRAN?

---

## Done

- [x] Initial proof-of-concept script (original research script)
- [x] Rewrote without custom grob machinery - replaced with `geom_tile()` + `geom_text()`
- [x] Core test suite covering all exported functions

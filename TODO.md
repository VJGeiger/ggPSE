# ggPSE — roadmap and todo

A living document. Items are roughly ordered by priority within each section.
Move completed items to the **Done** section at the bottom with a date.

---

## v0.1 — get it working (current focus)

### Must-have before any public release
- [ ] Finalize `ggPSE()` function API and argument names
- [ ] Finalize `ggPSE_highlight()` — test multiple group legend behavior
- [ ] Finalize `ggPSE_bubble()` — validate scale_size_area interaction with ggplot2 fill scale
- [ ] Finalize `ggPSE_badge()` — test overflow behavior for long badge strings
- [ ] Write `data-raw/build_elements.R` to document where element grid data comes from
- [ ] Write roxygen2 docs for all exported functions
- [ ] Run `devtools::document()` and commit generated `man/` files
- [ ] Run `devtools::check()` — reach zero errors, zero warnings, zero notes
- [ ] Write introduction vignette (`vignettes/introduction.Rmd`)
- [ ] Write a `README.md` with install instructions and a minimal example with output image

### Nice to have for v0.1
- [ ] Add `pse_theme()` — a few pre-built theme variants (minimal, dark, publication)
- [ ] Decide on `periodicdata` as a suggested dependency vs bundling own element data
- [ ] pkgdown site setup (`_pkgdown.yml`)

---

## v0.2 — interactivity

- [ ] Add `ggPSE_interactive()` wrapper using `ggiraph`
  - Hover tooltip showing element name, atomic number, and user value
  - Tooltip content configurable via a `tooltip_cols` argument
- [ ] Test `ggiraph` output in Quarto HTML documents
- [ ] Test `ggiraph` output in Shiny
- [ ] Vignette: interactive PSE in a Quarto document

---

## v0.3 — advanced visualization modes

- [ ] `pse_sparkline()` — mini bar chart per tile for time-series data
  - Decide implementation strategy: `annotation_custom()` grobs vs separate function
  - Target use case: commodity price development over 5 years
  - This is Tier 2 complexity — budget 3-5 days
- [ ] Dual-value tile: diagonal split encoding two variables simultaneously
  - Top-left triangle = variable A, bottom-right = variable B
  - Requires custom geom — plan for this carefully
- [ ] `pse_facet()` helper — convenience wrapper for `facet_wrap()` over the PSE
  - Main challenge: legend and axis consistency across facets
  - Document the `facet_wrap(~condition)` pattern explicitly

---

## supply chain / critical materials features

- [ ] `pse_supply()` — pie chart per tile showing supply mix by country
  - Needs `ggforce::geom_arc_bar()` or custom grob
  - Input: data frame with symbol, country, share (%) columns
- [ ] Bundle a `critical_materials` dataset
  - EU Critical Raw Materials Act list
  - Primary production country (ISO codes)
  - Basic price history (source: USGS Mineral Commodity Summaries)
- [ ] Vignette: critical raw materials supply chain analysis

---

## packaging / CRAN prep

- [ ] Decide: GitHub-only first, or aim for CRAN?
- [ ] If CRAN: resolve `geom_label2` provenance (not in current version — confirm it's fully removed)
- [ ] Add `cran-comments.md`
- [ ] Add `.github/workflows/R-CMD-check.yaml` for CI
- [ ] Add `.github/workflows/pkgdown.yaml` for auto-deploy docs site
- [ ] Add `.github/ISSUE_TEMPLATE/bug_report.md`
- [ ] Add `.github/ISSUE_TEMPLATE/feature_request.md`
- [ ] Add `NEWS.md` for changelog

---

## known issues / technical debt

- [ ] `ggPSE_highlight()` legend: multiple groups via repeated calls doesn't compose
  cleanly — investigate `ggnewscale::new_scale_color()` as solution
- [ ] `ggPSE_bubble()` + `ggPSE()` gradient: two separate legends for fill and size
  need manual cleanup — document workaround or fix
- [ ] `coord_fixed()` in `ggPSE()` interacts badly with `patchwork` multi-panel
  layouts — investigate and document workaround
- [ ] Lanthanide/actinide row gap: currently hardcoded as row 9/10 offset —
  consider making the gap size a parameter

---

## ideas / maybe someday

- [ ] Shiny app companion: upload CSV, see PSE update live
- [ ] `ggPSE_left_step()` — Janet left-step periodic table layout
- [ ] Export helper: `save_pse()` wrapping `ggsave()` with sensible PSE defaults
  (aspect ratio, resolution)
- [ ] ggplot2 extension: proper `StatPSE` so users can use `ggplot(data) + stat_pse()`
  idiom natively

---

## Done

- [x] Initial proof-of-concept script (original research script)
- [x] Rewrote without custom grob machinery — replaced with `geom_tile()` + `geom_text()`
- [x] Established repo structure and package scaffold
- [x] Core test suite covering all exported functions

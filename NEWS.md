# ggPSE 0.3.0
- New `symbol_position` argument in `ggPSE()` and `ggPSE_interactive()` to draw the
  element symbol at the `"center"` (default), `"top"`, `"bottom"`, `"left"` or `"right"`
  of each tile. 
- New `number_position` argument to place the atomic number at any of the eight
  border positions of the tile (default `"top-left"`). 
- New `symbol_size` argument to set the symbol size independently of `base_size`. 
- New `ggPSE_text()` adds a line of text per tile from a data column (positions
  `"top"`, `"center"`, `"bottom"`, plus a fine-tuning `position_nudge`). 
  Call it after `ggPSE_donut()`, which removes all text layers.
- New `symbol_nudge` and `number_nudge` arguments shift the symbol / atomic number
  vertically from their `*_position`.
- New `label_na` argument (hide symbols on tiles without data) and `text_color`
  (one fixed text colour instead of the automatic contrast colour) in `ggPSE()` and
  `ggPSE_interactive()`.
- `highlight` now also accepts a named list of symbol vectors, e.g.
  `highlight = split(df$symbol, df$category)`, with the new `highlight_colors` argument
  (named or by position).  `legend_title` now labels the highlight legend. 
- `ggPSE_theme()` no longer removes your colour scales (`"minimal"`, `"publication"` and
  `"dark"` used to replace gradients and highlight colours by ggplot2's defaults and turn the
  symbols salmon). Only `"crazy"` replaces the fills. The plot you pass in is no longer
  modified, and the docs examples now use `ggPSE(...) |> ggPSE_theme("publication")`.
- Redesigned `"publication"` theme for print: white background, thin dark-grey tile borders,
  white tiles for elements without data, compact legend that fits, and plain title, subtitle
  and caption styles.
- Data given to `ggPSE()`, `ggPSE_interactive()`, `ggPSE_bubble()`, `ggPSE_bar()` and
  `ggPSE_profile()` is checked: symbols that are not element symbols (typos, lower case,
  stray spaces, element names, `NA`) are now an error that names them instead of leaving the
  tile silently blank, and so are non-numeric or all-`NA` value columns. Repeated rows for an
  element are allowed if they agree (e.g. one row per country), different values for the
  same element are an error. `ggPSE_badge()`, `ggPSE_donut()` and `ggPSE_text()` check the
  symbols too. Unknown symbols in `highlight` are an error.
- A value column named `atomic_number`, `col` or `row` no longer clashes with the internal
  tile table (it used to give a blank plot or an error; `ggPSE_interactive()` silently used
  the tile positions instead of your values).
- `ggPSE_bubble()` without `size_col` draws a blank table instead of failing.
- README: fixed typos `gPSE_donut` and `ggpse_elemts`.
- `ggPSE_bar()`: bars now start at zero by default, so their length is proportional to the
  value; before, the smallest value got no bar and constant values gave `NaN`. New `limits`
  argument; `limits = range(x)` gives the previous scaling. `legend_title` was never used
  (bars have no legend) and now warns when set. This changes the look of existing bar plots.
- The element tables are lazy-loaded (`LazyData: true`): `ggpse_elements` and `ggpse_grid`
  are available after `library(ggPSE)` without `data()`, and the hard-coded copy of the
  tile table inside the package is gone.
- `ggPSE_badge()`: `badge_size` was multiplied by 0.22 when ggflags is not installed; an
  unknown country code is shown as given instead of `NA` in the legend; elements with more
  than 3 countries and rows without a country code (e.g. Namibia's `"NA"` read by
  `read.csv()`) now give a warning.
- `ggPSE_profile()` gives a clear error if `period` or `group` is not a single number.
- Documentation: `tile_border` no longer claims to detect the background.
- Text layout is now defined in one internal helper shared by `ggPSE()` and
  `ggPSE_interactive()`.
- Documentation fix: `base_size` default is 10, not 8.

# ggPSE 0.2.0
- Added selection parameters for `ggPSE()`
- New `ggPSE_profile()` to plot alongside groups or periods identifying trends.
- Added interactivity using `ggiraph`
- Updated the license to MIT. 
- Added a possible hierarchy for `ggPSE_badge()` and optional legend
- Added `ggPSE_theme` wrapper for ease of publishing
- `ggPSE_save()` for ease of use  

# ggPSE 0.1.0
* Initial release

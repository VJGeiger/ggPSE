# ggPSE 0.3.0
- New `symbol_position` argument in `ggPSE()` and `ggPSE_interactive()` to draw the
  element symbol at the `"center"`, `"top"`, `"bottom"`, `"left"` or `"right"`
  of each tile. 
- New `number_position` argument to place the atomic number at any of the eight
  border positions of the tile. 
- New `symbol_size` argument to set the symbol size independently of `base_size`. 
- New `ggPSE_text()` adds a line of text per tile from a data column (positions
  `"top"`, `"center"`, `"bottom"`, plus a fine-tuning `position_nudge`). 
- New `symbol_nudge` and `number_nudge` arguments shift the symbol / atomic number.
- New `label_na` argument and `text_color` in `ggPSE()` and  `ggPSE_interactive()`.
- `highlight` now also accepts a named list of symbol vectors, e.g.
  `highlight = split(df$symbol, df$category)`, with the new `highlight_colors` argument
  (named or by position).
- `ggPSE_theme()` no longer removes your colour scales 
- Redesigned `"publication"` theme for print
- Data check for given data to `ggPSE()`, `ggPSE_interactive()`, `ggPSE_bubble()`, `ggPSE_bar()` and
  `ggPSE_profile()` for typos, spaces, etc.
- A value column named `atomic_number`, `col` or `row` no longer clashes with the internal
  tile table 
- `ggPSE_bubble()` without `size_col` draws a blank table instead of failing.
- README: fixed typos `gPSE_donut` and `ggpse_elemts`.
- `ggPSE_bar()`: bars now start at zero by default, so their length is proportional to the
  value
- The element tables are lazy-loaded (`LazyData: true`): `ggpse_elements` and `ggpse_grid`
  are available after `library(ggPSE)` 
- `ggPSE_badge()`: `badge_size` was multiplied by 0.22 
- `ggPSE_profile()` gives a clear error if `period` or `group` is not a single number.
- Documentation: `tile_border` no longer claims to detect the background.
- Colours: `ggPSE()` and `ggPSE_interactive()` have new arguments `colors` (two or more
  colours), `midpoint` (diverging scales), `limits` (a fixed colour range, e.g. for the frames
  of an animation), `breaks` and `labels`, so the fill scale no longer has to be replaced
  afterwards. The text colour of each tile is now chosen against the colour the tile really
  gets Fills are unchanged - in the default gradient the symbol colour changes
  on a few tiles where it was wrong (4 of 87 in the electronegativity example).
- `text_color` can now name a column in `data` with one colour per element.
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

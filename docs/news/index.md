# Changelog

## ggPSE 0.3.2

- New
  [`ggPSE_symbols()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_symbols.md)
  marks elements by category with point symbols: up to six categories
  and four per elements. \# ggPSE 0.3.0
- New `symbol_position` argument in
  [`ggPSE()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE.md) and
  [`ggPSE_interactive()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_interactive.md)
  to draw the element symbol at the `"center"`, `"top"`, `"bottom"`,
  `"left"` or `"right"` of each tile.
- New
  [`ggPSE_symbols()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_symbols.md)
  marks elements by category with point symbols: up to six categories
  (at most four per element), one `pch` and colour each. The markers sit
  in one row at the very bottom of the tile, placed by the measured size
  of their shapes (equal gaps, centred, one common bottom line), while
  the element symbol and value move up. A white edge keeps them visible
  on coloured tiles (`halo = TRUE/FALSE`), and a legend is added.
- New `symbol_position` argument in
  [`ggPSE()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE.md) and
  [`ggPSE_interactive()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_interactive.md)
  to draw the element symbol at the `"center"`, `"top"`, `"bottom"`,
  `"left"` or `"right"` of each tile.
- New `number_position` argument to place the atomic number at any of
  the eight border positions of the tile.
- New `symbol_size` argument to set the symbol size independently of
  `base_size`.
- New
  [`ggPSE_text()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_text.md)
  adds a line of text per tile from a data column (positions `"top"`,
  `"center"`, `"bottom"`, plus a fine-tuning `position_nudge`).
- New `symbol_nudge` and `number_nudge` arguments shift the symbol /
  atomic number.
- New `label_na` argument and `text_color` in
  [`ggPSE()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE.md) and
  [`ggPSE_interactive()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_interactive.md).
- `highlight` now also accepts a named list of symbol vectors, e.g.
  `highlight = split(df$symbol, df$category)`, with the new
  `highlight_colors` argument (named or by position).
- [`ggPSE_theme()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_theme.md)
  no longer removes your colour scales
- Redesigned `"publication"` theme for print
- Data check for given data to
  [`ggPSE()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE.md),
  [`ggPSE_interactive()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_interactive.md),
  [`ggPSE_bubble()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_bubble.md),
  [`ggPSE_bar()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_bar.md)
  and
  [`ggPSE_profile()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_profile.md)
  for typos, spaces, etc.
- A value column named `atomic_number`, `col` or `row` no longer clashes
  with the internal tile table
- [`ggPSE_bubble()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_bubble.md)
  without `size_col` draws a blank table instead of failing.
- README: fixed typos `gPSE_donut` and `ggpse_elemts`.
- [`ggPSE_bar()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_bar.md):
  bars now start at zero by default, so their length is proportional to
  the value
- The element tables are lazy-loaded (`LazyData: true`):
  `ggpse_elements` and `ggpse_grid` are available after
  [`library(ggPSE)`](https://github.com/VJGeiger/ggPSE)
- [`ggPSE_badge()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_badge.md):
  `badge_size` was multiplied by 0.22
- [`ggPSE_profile()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_profile.md)
  gives a clear error if `period` or `group` is not a single number.
- Documentation: `tile_border` no longer claims to detect the
  background.
- Colours:
  [`ggPSE()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE.md) and
  [`ggPSE_interactive()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_interactive.md)
  have new arguments `colors` (two or more colours), `midpoint`
  (diverging scales), `limits` (a fixed colour range, e.g. for the
  frames of an animation), `breaks` and `labels`, so the fill scale no
  longer has to be replaced afterwards. The text colour of each tile is
  now chosen against the colour the tile really gets Fills are
  unchanged - in the default gradient the symbol colour changes on a few
  tiles where it was wrong (4 of 87 in the electronegativity example).
- `text_color` can now name a column in `data` with one colour per
  element.
- Text layout is now defined in one internal helper shared by
  [`ggPSE()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE.md) and
  [`ggPSE_interactive()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_interactive.md).
- Documentation fix: `base_size` default is 10, not 8.

## ggPSE 0.2.0

- Added selection parameters for
  [`ggPSE()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE.md)
- New
  [`ggPSE_profile()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_profile.md)
  to plot alongside groups or periods identifying trends.
- Added interactivity using `ggiraph`
- Updated the license to MIT.
- Added a possible hierarchy for
  [`ggPSE_badge()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_badge.md)
  and optional legend
- Added `ggPSE_theme` wrapper for ease of publishing
- [`ggPSE_save()`](https://vjgeiger.github.io/ggPSE/reference/ggPSE_save.md)
  for ease of use

## ggPSE 0.1.0

- Initial release

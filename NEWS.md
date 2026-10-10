# ggPSE 0.3.0
- New `symbol_position` argument in `ggPSE()` and `ggPSE_interactive()` to draw the
  element symbol at the `"center"` (default), `"top"`, `"bottom"`, `"left"` or `"right"`
  of each tile. 
- New `number_position` argument to place the atomic number at any of the eight
  border positions of the tile (default `"top-left"`). 
- New `symbol_size` argument to set the symbol size independently of `base_size`. 
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

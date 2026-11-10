"""Measures the shapes rendered by render.R and prints the R code of .symbol_shapes.

Usage: python3 analyse.py <folder with the PNG files>
Needs numpy, scipy and pillow. For every shape it measures the width of the drawn
marker (including the white edge) and the distance from the point down to the bottom of
the shape, in tile units (a tile is 0.92 wide), and fits straight lines against size.
"""
import sys
import numpy as np
from PIL import Image
from scipy import ndimage

folder = sys.argv[1] if len(sys.argv) > 1 else "shapes"
SIZES = (1.0, 1.8, 3.0)

def measure(prefix):
    rows = []
    for s in SIZES:
        im = np.array(Image.open(f"{folder}/{prefix}_{s:.1f}.png").convert("RGB")).astype(int)
        dark = (abs(im[:, :, 0] - 8) < 14) & (abs(im[:, :, 1] - 48) < 14) & (abs(im[:, :, 2] - 106) < 16)
        lab, _ = ndimage.label(dark)
        tiles = [o for o in ndimage.find_objects(lab)
                 if 180 < o[1].stop - o[1].start < 320 and 180 < o[0].stop - o[0].start < 320]
        tiles.sort(key=lambda o: (round(o[0].start / 60), o[1].start))
        assert len(tiles) >= 26, f"found {len(tiles)} tiles in {prefix}_{s}"
        for pch, o in enumerate(tiles[:26]):
            y0, y1, x0, x1 = o[0].start, o[0].stop, o[1].start, o[1].stop
            sub = ~dark[y0:y1, x0:x1]
            sub[:5, :] = sub[-5:, :] = False
            sub[:, :5] = sub[:, -5:] = False                       # ignore the anti-aliased tile border
            ys, xs = np.nonzero(sub)
            unit = (x1 - x0) / 0.92
            cy = (y0 + y1) / 2
            rows.append((s, pch, (xs.max() - xs.min() + 1) / unit, (ys.max() + y0 + 1 - cy) / unit))
    return rows

def fit(rows):
    out = {}
    for pch in range(26):
        d = [r for r in rows if r[1] == pch]
        sz = [r[0] for r in d]
        aw, bw = np.polyfit(sz, [r[2] for r in d], 1)
        ad, bd = np.polyfit(sz, [r[3] for r in d], 1)
        out[pch] = (aw, bw, ad, bd)
    return out

def column(f, idx):
    return "c(" + ", ".join(f"{f[p][idx]:.4f}" for p in range(26)) + ")"

h, p = fit(measure("halo")), fit(measure("plain"))
print("data.frame(\n  pch = 0:25,")
for name, f, idx in (("aw_h", h, 0), ("bw_h", h, 1), ("ad_h", h, 2), ("bd_h", h, 3),
                     ("aw_p", p, 0), ("bw_p", p, 1), ("ad_p", p, 2), ("bd_p", p, 3)):
    print(f"  {name} = {column(f, idx)}" + ("," if name != "bd_p" else ""))
print(")")

# Extension unit CRT2 (the CRT scanlines follow-up: speed and sharpness) - record

## Result

"CRT scanlines" no longer slows civ64 down and no longer smooths the picture: with it on, every pixel is the same
pixel as with it off (nearest-neighbour or the chosen filter, as the scaling options say), only darkened by its row's
scanline weight (the gaps) and brightened by the filter's tonal curve, exactly as DOSBox Pure Unleashed's filter does
for a uniform area with the user's settings. The cost per pixel fell from about 50 ns to a few table reads (a whole
3840x2160 client in a few milliseconds; test_crt's timing check).

## Status

Landed 2026-10-19 after CRT and AMS (see "Landing").

## The user's words

The user's report of 2026-10-18 about 23:50 UTC after checking build "crt" (verbatim, through the orchestrator):
"Checked 'crt', there is a extreme slowdown problem when CRT scanlines option enabled from the menu, investigate and
fix the implementation. Aside from that this implementation smoothes display, the choice combinations I specified on
DosBoxPure Unleashed has not such effect, re check implementation for this issue."

## What was wrong

* **Slowdown:** CRT's `present_crt_apply` resampled every shown pixel from 2 source rows x 4 source columns x 3
  channels with 64-bit multiply-adds, decode and tone tables: about 50 ns a pixel, so a whole 1920x1080 show took
  about 100 ms and a 3840x2160 one about 400 ms. Whole-client shows are frequent in the DOS graphics (the intro's
  panorama and credits, fades and palette steps, every relayout, every switch), so civ64 fell to a few frames a second.
  The buffers and tables were not reallocated per frame (they follow the layout), and the dirty rectangles were kept;
  the per-pixel work alone was the cause (static review of `present/crt.c`; the new timing check measures the new code).
* **Smoothing:** the shader's horizontal taps 2^(-7 d^2) ("Sharpest", HorizontalBlur -7) mix two source columns
  50/50 at their boundary, and its two-row scan sum mixes two source rows between their centres. DOSBox Pure Unleashed
  draws its shader at the screen's resolution with many screen pixels per source pixel, where that mixing covers a
  sliver of each pixel and is not seen; civ64 shows a source pixel on 2..5 host pixels, so the mixed pixels were whole
  visible columns and rows: a one-pixel blur at every edge. Re-read of the source (read-only, codeberg
  schelling/dosbox-pure-unleashed main.cpp `fragment_shader_crt_src` and its option mapping): "Only Scanlines" is
  ShadowMask 1 (no mask, tone mask 1), "Normal gaps" ScanlineThinness 0.65, "Sharpest" HorizontalBlur -7; nothing
  else of the filter is active with the user's settings.

## Design

* No resampling (`present/crt.c`): each image pixel keeps its clean (scaled) pixel; per image row one scan weight
  w = own + neighbour of the shader (own = scan(a T), neighbour = scan((1 - a) T), a the row's distance from its own
  source row's centre), which is what the shader gives a uniform area, so the gaps are as dark as the shader's; then
  the shader's tonal curve. A table `fac[level][brightest channel]` (256 x 256, 16.16, made once) gives w f(p) / p; a
  pixel is 3 decode reads, 1 factor read, 3 multiplies and 3 encode reads; a run of equal pixels reuses the result.
* Each output pixel depends on its own clean pixel only: `present_crt_expand` returns the rectangle itself (no reach).
* present.c, the menu, the settings and the source grid (DOS rows for the DOS A frame) are unchanged.

## Deviations

* F335: the shader's horizontal taps and its blend of two source rows are left out (CRT's F329 post-process remains);
  with the user's settings and civ64's few host pixels per source pixel they only blurred the picture. The scan weight
  is the shader's own + neighbour sum per row (equal to the shader on uniform areas; at an edge between two rows each
  row keeps its own colour).

## Tests

* `tests/test_crt.c` rewritten for CRT2 (sharpness and time): the scan levels (255 at the row centres, equal at equal
  distances, 0.583 x 255 at 0.4 source rows), white at a row centre stays white, white between rows darker, black
  within one step, mid grey brighter at a row centre, the border copied; **sharpness**: equal clean pixels in a row give
  equal output, one changed clean pixel changes exactly one output pixel (no blending), no reach; a golden SHA-256 of
  the filtered pattern; **timing**: a whole 3840x2160 client (a 320x200 picture at 4:3 fit) filtered under 120 ms (the
  measured time is printed; CRT's code needed about 400 ms); the presentation's option checks as before.

## For the records

* DESIGN: the CRT section: no resampling, the per-row weight and the table; the cost.
* FIDELITY: F335 (amends F329/F330: the post-process keeps the clean pixel; the fixed-point note stands).
* RUNNING: nothing new.

## What the user checks

* **CRT2-1** Turn "CRT scanlines" on (Display) and play: the intro, the title, scrolling and zooming the map, opening
  menus and dialogs are as fast and smooth as with it off, in both graphics and in full screen.
* **CRT2-2** With it on, the picture is as sharp as with it off: each pixel's edges stay hard (no soft or doubled
  columns at the edges of letters, units and the map squares); only the dark gaps between the pixel rows are added.
* **CRT2-3** Re-check CRT-1..CRT-5 of build "crt" with this build (the item, one gap per DOS row in the DOS graphics
  and per Windows row in the Windows graphics, scaling and the 4:3 items, zoom, the setting remembered).

## Expected changes at the build slot

* test_crt's checks and golden change (rewritten); every other count and golden unchanged (the option is off by
  default). P0 unchanged.

## Rebase notes

Bases: `BASE-SHA256.txt` (the tree's present/crt.c, crt.h and tests/test_crt.c after CRT landed; AMS does not touch
them).

## Landing

CRT2 landed at the build slot of session E5 on 2026-10-19 after AMS (build/ams-prep/LANDED.txt).

* **Bases** unchanged since CRT's landing (AMS does not touch the three files). Private overlay (tree + CRT2) Checked,
  CheckedNoObs and Release BUILD_OK, every unit and Win32-headless test passing; test_crt's timing 8.2, 8.2 and 9.0 ms
  for a whole 3840x2160 client (CRT's code: about 400 ms).
* **Copy-in** 00:32:45 UTC (`build/a43-prep/land.py crt2 --write`, 3 files, LF as the tree).
* **The cycle** (`build/crt2-status.txt`): 1 `build.cmd checked` BUILD_OK 00:32:51..00:36:29; 2 `test.cmd checked`
  TESTS_OK 00:36:29..01:05:46 (test_crt PASS 21 checks, timing 49.0 ms under test.cmd's parallel sections, bound
  120); 3 `ext_g1.py check` EXT_G1_OK runs 77 unchanged: **ALL_GREEN** 01:05:46 UTC; 4 `build.cmd` (Release)
  BUILD_OK 01:05:46..01:08:54: **RELEASE_OK**.
* **Against the predictions** (`build/crt2-prep/predictions.txt`): as predicted; the timing under load is higher than
  alone (49 ms against 8 ms): the bound keeps a margin of more than two, but a much more loaded host could exceed it
  (an open point: make it informational if it ever flakes).
* **User build** `build/user-builds/crt2/` (CRT2-1..CRT2-3). FIDELITY F335.

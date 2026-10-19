# Extension unit CRT (the "CRT scanlines" filter) - record

## Result

A new check item "CRT scanlines" in the window menu's Display submenu (below the filters) turns on one fixed CRT
filter in both graphics profiles: DOSBox Pure Unleashed's CRT filter with exactly the user's eight settings (only
scanlines, normal gaps, sharpest, default phosphor mask strength, no curvature, no rounded corners, aspect from civ64's
4:3 items, no overscan border). It is applied by the host presentation after scaling, under every scaling policy and
filter, over the map zoom layer too. The setting is remembered (civ64.cfg key `crt_scanlines`, off by default) and
`--crt 0|1` sets it for one run. The core, its timing and input are unchanged (P0).

## Status

Staged in `build/crt-stage/` on A43's staged copies (A43 lands first) and WL's. Landed 2026-10-18 (see "Landing").

## The user's words

The user's request of 2026-10-17 (verbatim in `docs/verify/BRIEF-extras.md`, item 3): "Implement optional scanlines
filter from DosBox Pure Unleashed" with CTRL+F12 settings CRT Filter "Only Scanlines", Scanline Intensity "Normal
gaps", Blur/Sharpness "Sharpest", Phosphor Mask Strength "Default", Curvature "Disabled", Rounded Corner "Disabled",
Aspect Ratio Correction "Tied to our 4:3 options", Overscan Border Size "Off"; "a on/off option host application
context menu named 'CRT scanlines'". Placement: BRIEF-hm.md's last section (Display, below the filters).

## Source and licence

* The filter: `fragment_shader_crt_src` in DOSBox Pure Unleashed's `main.cpp`
  (https://codeberg.org/schelling/dosbox-pure-unleashed, (C) Bernhard Schelling, GPL-2.0-or-later), read read-only on
  2026-10-18; the option values from the dosbox-pure core's `core_options.h` (read through a mirror of the core,
  github.com/danibiker/Salvia `libretro/dosbox-pure/core_options.h`): CRT Filter "1" = Only Scanlines, Scanline
  Intensity "3" = Normal gaps, Blur/Sharpness "7" = Sharpest, Phosphor Mask Strength "2" = Default, Curvature and
  Rounded Corner "0" = Disabled. `main.cpp` maps them to the shader's uniforms: ShadowMask = 1, ScanlineThinness =
  0.5 + 3 x 0.05 = 0.65, HorizontalBlur = -7, MaskValue = 1 - 0.25 x 2 = 0.5 (unused: the scanlines mode sets the tone
  mask to 1 and draws no mask), Curvature 0, Corner 0.
* civ64 copies no code: `present/crt.c` reimplements the shader's arithmetic in its own portable C (fixed-point
  weights and tables), with the attribution in `present/crt.h`. The formulas are listed in `crt.h`.

## Design

* **The math** (crt.h): per image pixel, the source position (px, py) of its centre; two source rows y0, y0 + 1 around
  py with the scan weights scanA/scanB (a cosine window: 1 and 0 at a row's centre, about 0.27 each between rows: the
  dark gaps); per row four source columns x0 .. x0 + 3 weighted by 2^(-7 d^2), normalised (sharpest: nearly nearest);
  linear light (sRGB decoded); then the shader's tonal curve (brightens to make up for the gaps; white stays white);
  sRGB encoded.
* **civ64's place** (present.c): a post-process of the scaled client image. With the option on, the scaler and the map
  layer draw into a clean client buffer; `show()` filters the written rectangle, grown by the filter's reach (3 source
  columns and 2 source rows), into the back end's buffer and shows that. Each source pixel is read at the image pixel
  that holds its centre, so under the integer policy and the nearest filter the filter sees the frame's pixels exactly,
  and under fit and sharp the scaled pixel there. The map zoom layer is filtered with the picture.
* **The source grid:** the visible frame's pixels; for the DOS A frame (DOS art at 2x on the Windows layout,
  input_frame 2) its DOS pixels (half the frame's size), so DOS gameplay has one scanline per DOS row as in DOSBox; the
  Windows graphics one per Windows pixel row (a VGA 640x480 picture's lines).
* **Aspect:** the layout's (both A43 items): the filter maps output pixels to source positions through the laid-out
  image, so a 4:3 picture has 4:3 scanlines; no overscan border (the image only; the black border is copied).
* **Tables:** per layout (rebuilt when the layout or grid changes): per image column the 4 client columns and weights,
  per image row the 2 client rows and scan weights; static decode/encode/gain tables.
* **Performance:** per filtered pixel 8 reads, 3 table lookups, about 30 integer multiply-adds. A whole 3840x2160
  client is about 8.3 million pixels per full redraw (a relayout, a switch); core presents filter only their damage
  rectangles.
* **Menu and settings:** Display: ... "Sharp filter", a separator, "&CRT scanlines" (SC_CIV_CRT 0x1130, check; the id
  audit: ids to 0x1120 in use), a separator, the two 4:3 items. Its hook, then the settings hook; `hw_set_crt` for the
  start state. civ64: `--crt 0|1`, else the key `crt_scanlines` ("1" on), else off; written only after the player's
  choice.

## Deviations

* F329: the filter is a post-process of civ64's scaled image (source pixels read at the image pixels showing their
  centres), not a resampling of the frame texture as the shader does; with integer scaling and the nearest filter the
  two are equal; with fit and the sharp filter the scaled (area-averaged) pixel is the source.
* F330: fixed-point arithmetic (weights to 2^-16, linear light in 16 bits, the gain table indexed by the peak's 12
  high bits) instead of the shader's floating point: output bytes may differ by about one step.
* F331: the DOS gameplay's scanlines follow the DOS rows (the A frame's 2x2 DOS pixels), the Windows graphics' the
  Windows rows.

## Tests

* New `tests/test_crt.c` (20 checks): the tables (each column's weights sum to 2^16; a row centre's scan weights
  1 and 0, its rows read at the source rows' centres; between rows below 0.9), white stays white at a row centre and black within one step (the shader's own sRGB pair and tonal gain
  lift 0 to 1/255, as the shader does), white between rows darker, mid grey at a row centre brighter (the tonal curve), the border copied, a
  golden SHA-256 of a filtered synthetic pattern (pins the arithmetic), the reach (a changed source pixel's expanded
  rectangle updated alone equals the whole filtered again), fit 4:3 tables inside the image; through the presentation
  (Windows profile, 1920x1440): on filters the view at once, a damaged core present under the filter equals a whole
  redraw, off gives the unfiltered picture again. It fails on the base (no crt.h).
* `tests/win32/test_host_win32.c`: Display's 12 entries (with WL's and A43's), the item's text and mark, its command,
  hook and settings hook, `hw_set_crt`, `--crt 0|1|on`.

## For the records

* DESIGN: 12.x "CRT scanlines" (the post-process, the grid, the reach, the tables), 12.2 menu.
* FIDELITY: F329 .. F331.
* RUNNING: `--crt 0|1`, the key `crt_scanlines`, the Display item; attribution of the filter's source.
* FEATURES: host row "CRT scanlines" (both graphics).

## What the user checks

Open the window menu (the icon at the left of civ64's title bar, or right-click the title bar), then Display.

* **CRT-1** Display shows "CRT scanlines" below "Sharp filter", between two separator lines, unchecked at first.
  Choose it: the picture at once shows thin dark horizontal gaps between the pixel rows, like DOSBox Pure Unleashed's
  "Only Scanlines" CRT filter with normal gaps; the picture stays sharp (no blur, no colour mask, no curvature, no
  rounded corners, no extra border) and about as bright as before. Choose it again: the plain picture returns.
* **CRT-2** In DOS graphics (title screen, intro and in play) there is one dark gap per DOS pixel row; in Windows
  graphics one per Windows pixel row (finer). Switch graphics with Ctrl+Shift+Backspace while it is on: it stays on.
* **CRT-3** With "CRT scanlines" on, try "Fit to window" and "Integer scaling", the sharp filter, full screen
  (Alt+Enter) and resizing the window: the scanlines follow the picture every time, with no stripes left on the black
  borders and no stale picture parts; with the 4:3 items checked the scanlines are spaced as the taller 4:3 rows.
* **CRT-4** In play, zoom the map (Ctrl+Shift+Plus/Minus) and move units: the zoomed map has the scanlines too, and
  the picture updates without flicker or lag that was not there before.
* **CRT-5** Close civ64 with "CRT scanlines" on and start it again: still on. `--crt 0` starts without it for that
  run.

## Expected changes at the build slot

* New unit test test_crt (about 19 checks); test_host_win32 + about 4 checks; every other count and golden unchanged
  (the option is off by default and in every existing test and harness run).
* P0 unchanged (presentation only). Coverage: present/crt.c entered by test_crt only.

## Rebase notes

Bases: `BASE-SHA256.txt` (the tree's files when staged, 2026-10-18 about 21:25 UTC) and `BASE-STAGE-SHA256.txt` (the
A43/WL stage copies CRT started from; kept in `obj/base-stage/`). After A43 lands, each file is 3-way merged
read-only (`git merge-file -p crt base-stage tree-after-A43`).

## Landing

CRT landed at the build slot of session E5 on 2026-10-18 after A43 (build/a43-prep/LANDED.txt).

* **Rebase:** A43's landed copies equal the A43 stage copies CRT was built on (line endings aside: both normalised to
  the tree's LF); the three copies CRT did not change (civ64_cfg.c/.h, harness_main.c) were dropped from the stage;
  BASE-SHA256.txt refreshed. Private overlay (tree + CRT) Checked, CheckedNoObs and Release BUILD_OK, every unit and
  Win32-headless test passing.
* **Copy-in** 22:54:38 UTC (`build/a43-prep/land.py crt --write`, 11 files, 3 new; LF as the tree).
* **The cycle** (`build/crt-status.txt`): 1 `build.cmd checked` BUILD_OK 22:54:48..22:58:25 (portable sources 312);
  2 `test.cmd checked` TESTS_OK 22:58:25..23:29:44; 3 `ext_g1.py check` EXT_G1_OK runs 77 unchanged: **ALL_GREEN**
  23:29:44 UTC; 4 `build.cmd` (Release) BUILD_OK 23:29:44..23:33:30: **RELEASE_OK**.
* **Against the predictions** (`build/crt-prep/predictions.txt`): test_crt PASS 20 checks (new), test_host_win32
  480 -> 484, portable sources 311 -> 312; every other test and harness section green as before.
* **User build** `build/user-builds/crt/` (CRT-1..CRT-5). FIDELITY numbers F329..F331.
* Not done here: the docs pass ("For the records"), the checklist rows and STATUS (the orchestrator's).

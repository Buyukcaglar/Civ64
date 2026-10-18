# Extension unit MZW (the World Map's rectangle follows the map zoom level) - record

Draft for the build slot.  The user's request on D6d-6 (STATUS "User directions" 2026-10-16 about 15:35 UTC; the
results page, quoted in manual-checklist-ext.md D6d-6): "Yes this is working as described here but in game world
map's coverage area rectangle shall change along with the zoom level also."  The orchestrator's unit: the World
Map's rectangle for the main map's visible area follows the zoom level, larger at -1, smaller at +1, unchanged at
0, in both graphics, presentation only (P0), replacing the core-drawn rectangle without corrupting the map pixels
under it, with the method recorded.  Staged in `build/mzw-stage/` after MZ (MZW's copies of `pmap_layer.c`,
`pmap_zoom.c`, `pmap_int.h`, `tests/test_map.c` and `tests/harness/ext_zoom.py` are MZ's staged files with MZW's
additions; `obj/base-mz/` keeps MZ's copies), before D6e.  Private builds and runs in `build/mzw-stage/obj/` only
(an overlay `obj/src` = tree + stage built with build.cmd's own flags; private harness copies in `obj/exe`).

## Status

READY_TO_BUILD (after MZ).  At levels -1 and +1, while the map layer is live, the World Map shows the main map
window's actual area: the layer's world rectangle on the World Map's image, outlined in the core's own frame colour
as the core outlines its view; the core's rectangle (the core's view, which at -1 and +1 is not what the map window
shows) is hidden by the pixels the core's own drawing left under it.  At level 0 nothing changes: the core's World
Map and its rectangle as before.  The core, its window and the virtual screen are untouched (only reads, inside the
observer's guard).  Private results: three builds (294 portable sources), unit tests 0 failures (test_map 285),
OBS_LINT_OK files 120, REGISTRY_OK, NODOS_OK, testpar 0; P0_OK 164 (V0, V4, V4d) with every presented.log's
relation_mismatches 0; RUNADAPT 14/14 (every line as MZ's); the zoom golden rewritten (all 628 -1/+1 samples change:
every zoomed view holds the World Map) and every differing pixel of MZ's and MZW's pictures inside the World Map
window.

## The core's World Map (the facts the method rests on)

* `DrawSmTiles` 1210:09B4 (`core/seg066_1208_p2.c`): nothing while its data's visible flag is 0 (1210:0A00).  The
  view frame is the view's columns and rows times the scale (1 or 2 pixels a square), centred in the client
  (CenterRectInRect 1210:0E29), vertically at the view's row when Map Making is known and the client is exactly 50
  rows (1210:0E84); `g_smMapViewFrame` 1420:B3CC keeps it.  The image's origin is `ox = fl - viewLeft s`, `oy = ft -
  viewTop s` (1210:0EBD): world pixel X is at `ox + X s / 32`.  The image goes to the window by CopyPortToWindow
  with its east-west wrap copy 80 s to one side (1210:0F42).  Then the frame: a white brush (0xFFFFFF, 1210:1092)
  and FrameRect (1210:10C1) of the frame widened by 2 to the right and the bottom (1210:108A): the border at x = l,
  x = r + 1, y = t, y = b + 1.
* `PlotSmMapSquare` 1210:07AE blits single squares (the blink of the active unit's square, moved units) straight to
  the window.
* All of it is drawn on the window: the virtual screen holds the World Map with the core's frame on it, and the
  pixels under the frame are gone from the screen.

## The method (how the core's rectangle is replaced without corrupting the map pixels)

Presentation only, in a new module `present/map/pmap_smrect.c` (observer builds; CIV_OBSERVER 0 compiles it to
nothing):

1. **What is under the core's frame** (`under`).  The observer's OBS_DRAW events on the World Map's window (its DC's
   window, on the screen) report the changed screen rectangle after each drawing.  For every draw but FrameRect the
   changed client pixels are copied from the virtual screen into a client-sized index image `under`, marked known
   and not framed.  At FrameRect the border pixels of its rectangle that now hold the brush's colour (the colour most
   of them hold: a covered part keeps another window's pixels) are marked framed, and `under` keeps what the image
   drew there.  So `under` is the World Map as the core drew it, without its frames; a square plotted over the frame
   later is an ordinary draw (known, not framed).  The frame's colour (the ink) is the screen index the core's white
   brush drew (before the first frame: the palette entry nearest white).
2. **The patch** (at -1 and +1 while the layer's geometry is live).  Every visible client pixel of the World Map
   (its window's visible region, less menus' popups and a move or size outline, as the layer's own exclusions) is
   written into the Windows profile's frame (S1's `g_win`, XRGB through the core palette): the zoom rectangle's
   border in the ink; else `under` where the core's frame is the last writer; else the screen's own pixel.  A framed
   pixel never seen without the frame is kept as drawn and counted (`smrect_unknown`, 0 in every run).  The frame's
   damage, the DOS composition's core damage (the DOS profile's A frame copies `g_win`) and the layer's restore
   rectangle (re-scaled before the overlay, present.c) cover the client, so both profiles show it at the next show.
3. **The rectangle.**  The layer's world area `[Xo, Xo + Wl) x [Yo, Yo + Hl)` (pmap_layer.c's geometry, the same in
   both profiles) becomes `[ox + floor(Xo s / 32), ox + ceil((Xo + Wl) s / 32))` and likewise for the rows, clipped
   to the world's 50 rows (the layer shows black beyond the poles), the whole width when wider than 80 columns,
   framed as the core frames: `(l, t, r + 2, b + 2)`.  At level 0 the formula gives the core's own frame.  East-west
   each border pixel is drawn at x and at x +- 80 s (the image's wrap).
4. **When.**  At every core present whose rectangle meets the World Map's client (the core redrew it or something
   over it: `g_win` was just converted there), and at the layer's update (a zoom, a view change, a resize, a switch)
   when the rectangle, the level or the World Map's place changed.  Leaving -1 or +1 writes the screen's pixels back
   once (the core's frame returns).  The small map (the window, its frame, scale, view, visible region) is read only
   inside the observer's guard, at the World Map's draw events and at every core present, and kept for the layer's
   update (pmap_layer.c reads nothing of the emulation).

Nothing is written to the emulation, no random number is drawn, no core statement runs differently (P0).

## What was built

* `present/map/pmap_smrect.c` (new): the method above; `pmap_smrect_event`, `pmap_smrect_present`,
  `pmap_smrect_update`, `pmap_smrect_rect` (the zoom rectangle now, for D6e), `pmap_smrect_reset`,
  `pmap_smrect_diag`, the test seam `pmap_smrect_test_screen`.
* `present/map/pmap.h`: `PmapSmMap` gains `hwnd` (the World Map's window) and `drawn` (shown, not iconic, its data's
  visible flag set: DrawSmTiles draws it).
* `present/map/pmap_input.c`: `read_smmap` fills them; `pmap_smmap_read` and `pmap_smmap_hwnd` expose the small map
  to pmap_smrect.c (the test seam `pmap_test_smmap` serves both).
* `present/map/pmap_int.h`: `PmapSmRectDiag` and the declarations.
* `present/map/pmap_inview.c`: `pmap_on_event` passes the events (after the D6a model); `core_present` calls
  `pmap_smrect_present` after the palette is taken.
* `present/map/pmap_layer.c`: `pmap_layer_update` calls `pmap_smrect_update` after its work (the body is now the
  static `layer_update`).
* `present/map/pmap_zoom.c`: `pmap_reset` resets it; presentation-diag.log's `pmap` line gains `smrect l t r b`
  (the last rectangle drawn), `smrect_patches`, `smrect_frames`, `smrect_unknown`, `smrect_no_screen`, `smrect_ink`
  and `smrect_hidden` (the last patch's border and hidden-frame pixels), `smframe fl ft fr fb` and `smimage ox oy
  scale` (the World Map as last read).
* `present/map/pmap.h` and `pmap_smrect.c`: `pmap_smrect_owns(x, y)`: whether the last patch replaced that pixel of
  `g_win` (a border pixel of the zoom rectangle or a hidden pixel of the core's frame); 0 under CIV_OBSERVER 0.
* `tests/headless/harness.c` (one delimited block): the `--presented` relation check (S1, extension 5.1: at every
  core show the Windows frame is the RGB conversion of the virtual screen through the system palette) admits exactly
  the pixels `pmap_smrect_owns` names; every other pixel is compared as before.
* No core, w16, profile, DOS-profile or input file changes.

## Tests

* `tests/test_map.c` `world_map_rect()` (22 checks, after MZ's `view_changes()`): a synthetic World Map (160 x 100
  at scale 2) and virtual screen, its draw events and core presents through `pwin_core` and `pmap_on_core_present`:
  level 0 untouched (no patch, the core's frame shown); -1 the layer's area as FrameRect (51, 19, 113, 72) around
  the core's frame (66, 32, 98, 58), drawn in the ink with the whole border (226 pixels) and the whole core's frame
  hidden (112 pixels), every client pixel as expected, the damage and the restore over the client, `g_win` the
  screen's RGB but for the pixels `pmap_smrect_owns` names (and none owned back at 0); a present over
  the client patches again, one beside it and an unchanged update do not; a square plotted over the core's frame
  shows as plotted; back to 0 the screen's pixels (the core's frame) once, no patch after; +1 a smaller rectangle
  inside the core's frame; -1 across the image's edge (the border at x -5 drawn at 155); the visible region only (a
  window over the right half keeps the screen's pixels); a World Map no longer drawn: the screen once, then nothing;
  a frame over pixels never seen: kept and counted.
* `tests/harness/ext_zoom.py` (extension MZW block in MZ's centring runs): in play, at -1, in the Windows and the DOS
  profile, near the south pole and in mid-latitudes: the World Map's last rectangle equals the layer's area computed
  from presentation-diag.log's origin, layer size, `smimage` and `smframe`, contains the core's frame, the border was
  drawn and the core's frame hidden, no pixel unknown, no frame of another size; the two profiles' rectangles equal.

## Results (private, `build/mzw-stage/obj/`)

The overlay `obj/src` is the tree after MZ's landing (17:41:59 UTC) with the stage on top; every base was rechecked
(`BASE-SHA256.txt`, BASE_OK).

* **Builds** (`final.sh`, build.cmd's flags): Checked, CheckedNoObs and Release BUILD_OK, portable sources checked
  294 (c11, c17, c99 parse); cc.cmd's strict checks CC_OK in the three variants on `pmap_smrect.c`, `pmap_zoom.c`,
  `pmap_layer.c`, `pmap_input.c`, `pmap_inview.c`, `tests/test_map.c` and `tests/headless/harness.c`.
* **Unit tests**: 47 programs in each variant, 0 failures; `test_map` 285 checks in Checked and Release (MZ's 263
  + 22), 1 in CheckedNoObs (the layer is not in that build).
* **Checks**: OBS_LINT_OK files 120 probes 203 callsites 98; `testpar.py check` exit 0 (test.cmd unchanged);
  `registry.py check` REGISTRY_OK; `nodos.py check` NODOS_OK (0 hits).
* **ext_zoom, the whole matrix** (`runzoom.py Checked --update -j 3`, the harness before `pmap_smrect_owns`, SHA-256
  d842be54...; the product's drawing is the same as the final one's, which only adds that query): ZOOM_GOLDEN
  written 628 samples; `ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32 centre runs 4`.  Against
  MZ's golden all 628 sample hashes changed (5 sizes x 3 scenarios x -1/+1 in both profiles, and s4's 148): every
  sample is a view hash of the whole host view, and every zoomed view holds the World Map with its new rectangle.
  Every `ZOOM ok` line (the shows by profile, the samples) equals MZ's run; the four centring lines gain the World
  Map's part: pole `World Map rectangle [42, 20, 123, 76] around the core's frame [62, 40, 102, 68] (scale 2, 270
  border and 132 hidden pixels)`, mid `[42, 26, 123, 82]`, the same in both profiles.
* **Where the pictures change** (`vdiff.py`: S3 in host form as the centring run `mid` to 62 s, MZ's private harness
  against MZW's final one, the last presented frame and the last zoomed view compared pixel by pixel):
  -1 Windows: 402 frame pixels differ (box [45, 48, 126, 104]; 402 = the 270 border pixels + the 132 hidden
  frame pixels) and 3618 view pixels (box [135, 144, 378, 312]); -1 DOS: 402 and 3618 (frame box [45, 50, 126,
  106]); +1 Windows: 206 and 1854.  Every differing pixel lies inside the World Map window (0, 0, 166, 127; x3 in the
  view); nothing else in the picture changes.  The same number of presents in both harnesses.
* **The final harness** (with `pmap_smrect_owns` and the relation block; SHA-256 f0ff1f4b...):
  * P0 (`ext_p0.py Checked --vars V0,V4,V4d -j 3`): P0_OK checks 164, every line equal to MZ's private run except
    `PASS V4 menus zoom (presented.log): 791 shows with the layer, refused 0` (MZ: 790).  The one more show is a
    tick show at virtual 215102150 us at +1, between core frames 1694 and 1695: the layer followed the active unit
    at its update, the rectangle moved, and the patch's damage was shown at the next tick (the same in both MZW
    harnesses).  All 54 presented.logs end with `relation_mismatches 0`.  The first harness (before the decision
    "S1's relation keeps its strength") had 696 `relation MISMATCH` core shows in V4 `menus`.
  * The centring runs (`--only centre`): the same four lines.
  * ext_adapt's map runs (`runadapt.py`): RUNADAPT checks 14 failed 0, every PASS line equal to MZ's private run;
    every presented.log `relation_mismatches 0`.
* The private runs' copies of the game files (their `run` folders) were deleted after the runs.

## Expected changes at the build slot

Against MZ's cycle (`build/test/Checked` after MZ's landing):

* `sections/unit.log`: `test_map` 263 -> 285 checks; the OBS_COST line (host time).
* `ext-zoom.txt`: the four `ZOOM centre ok` lines gain `; World Map rectangle [42, 20, 123, 76] around the core's
  frame [62, 40, 102, 68] (scale 2, 270 border and 132 hidden pixels)` (pole) and `[42, 26, 123, 82]` (mid), in both
  profiles; every other line, ZOOM_OK included, unchanged.  The golden file's 628 samples all change (reason above:
  the view hashes hold the World Map); they are compared silently against the landed golden.
* `ext-p0.txt`: `PASS V4 menus zoom (presented.log): 790 -> 791 shows with the layer` (the tick show of the moved
  rectangle, above); `P0_OK checks 476` and every other line unchanged.
* `obs-lint.txt` and `sections/d3a_obs_lint.log`: OBS_LINT_OK files 119 -> 120 (`pmap_smrect.c`); probes 203 and
  call sites 98 unchanged.
* `nodos.txt`: 1729 -> 1731 files (`pmap_smrect.c` and this record), other byte totals; 0 hits, NODOS_OK.
* `coverage.txt`, `sections/coverage.log`: possibly "other functions entered" (informational); `sections/times.txt`.
* Unchanged: ext_adapt (every line), ext_frames, ext_timeline, ext_continue, ux3_aspect, bs1..bs3, ext_mirror,
  ext_replay, ext_slots, gate3b, uninit, scenarios, p4tests (its `relation_mismatches 0` run is at level 0),
  harness_stub, d2_registry, d3a_obs_tables, d4a_pdos_scene, d4c1_adapters.  Only ext_zoom, ext_p0's V4/V4d and
  ext_adapt's map runs zoom; level 0 is untouched.
* ext_g1: EXT_G1_OK runs 77 (amended 1) unchanged (the core is untouched).  Release: BUILD_OK, portable sources 294.

## Rebase notes

* **MZ** first: MZW's copies of `pmap_layer.c`, `pmap_zoom.c`, `pmap_int.h`, `tests/test_map.c` and
  `tests/harness/ext_zoom.py` contain MZ's changes (bases: MZ's staged copies, `obj/base-mz/`, and the tree's for the
  rest).  If MZ lands unchanged, MZW's files replace them; otherwise reapply MZW's delimited blocks (`extension MZW`).
* **harness.c**: MZW's one delimited block in `shown()`'s relation loop.  D6e stages `tests/headless/harness.c` too
  (its small-map sample); it rebases on MZW's copy.
* **D6e** (paused; after MZW): D6e draws the World Map in DOS art in the DOS profile (`pdos_aplay`'s small-map
  element, with its own view frame from `g_smMapViewFrame`).  On its rebase it draws the zoom rectangle instead at -1
  and +1 (`pmap_smrect_rect`, the same client coordinates; its frame colour 15 as now), so the DOS World Map follows
  the zoom level too.  The DOS files include no map header (registry.py's include rule), so the map side passes the
  rectangle to the DOS element (as pmap_dos.c does for the map element).  Until then the DOS profile shows MZW's
  patch through the A frame's copy of `g_win`.  D6e's "not zoomed" check (draft D 19) compares the small map with
  level 0's outside the two rectangles (the zoom rectangle and the core's frame).
* Shared counts: one new portable source (`present/map/pmap_smrect.c`): build.cmd's portable sources 293 -> 294,
  obs_lint's files 119 -> 120 (probes 203 and call sites 98 unchanged).  A unit landing before MZW that adds a source
  moves both by its own count.

## Build-slot steps

1. After MZ: copy the staged files (`BASE-SHA256.txt`'s list) and this record into the tree; test.cmd and build.cmd
   unchanged (`BUILD-TEST-ADDITIONS.md`: none; build.cmd picks up `present\map\*.c`).
2. The three-step cycle: `build.cmd checked`, `test.cmd checked` (expected changes above), `ext_g1.py check`
   (EXT_G1_OK unchanged: the core is untouched).
3. The user build for the checks below.

## Decisions

* **Patch the Windows frame, not the screen.**  The virtual screen is the core's (P0); the World Map is drawn into
  the profile frame that both profiles show (`g_win`; the DOS A frame copies it).
* **Rebuild what is under the core's frame from the core's own draws** (OBS_DRAW events), not by redrawing the
  World Map from the game's data: the pixels are exactly the core's (cities, units, the blink, its colours), and the
  rectangle moves without any rendering of terrain.  A pixel never seen without the frame is kept, never invented.
* **The frame's colour** is the index the core's own white brush drew, so the new rectangle looks like the old one.
* **Rows beyond the poles are not outlined**: the layer shows black there; the rectangle stops at the World Map's top
  or bottom edge of the world (the pole limit the user kept, MZ).
* **S1's relation keeps its strength.**  Patching `g_win` makes the Windows frame differ from the RGB conversion of
  the virtual screen on the rectangle's border and the hidden core's frame (the first private P0 run, before this
  decision: 696 `relation MISMATCH` core shows in V4 `menus`, HARNESS_PRESENT_MISMATCH printed in zoom runs).
  Rather than lose the check at -1 and +1, the harness admits exactly the pixels the patch owns
  (`pmap_smrect_owns`), so any other difference (a layer or profile writing into `g_win`) is still a mismatch.

## Deviations from the design

* Draft D (the layer, section 5) drew only into the map window's client; MZW adds a second presentation-only drawing
  into the World Map's client of `g_win` at -1 and +1.  Draft D 7.4 (one geometry for both profiles) is kept: the
  rectangle derives from that geometry.
* S1 / extension 5.1 (DESIGN.md 12.1, "the Windows profile's frame is the RGB conversion of the virtual screen"):
  at -1 and +1, while the World Map is drawn, that holds for every pixel but those the patch owns (the rectangle's
  border and the hidden core's frame); the harness's relation check admits exactly those (Decisions).  Level 0, and
  every run without the zoom, keep the relation for every pixel.
* Draft D 2 / 5.8 "Not zoomed" (the small map is not zoomed; rule coverage 19: "ext_zoom (small map pixels equal
  level 0's)") now holds for the World Map's image only: its view rectangle follows the zoom level (the user's
  request).  The World Map is still not magnified, and the status window and the World Map report are unchanged.
  D6e's planned "not zoomed" check compares the small map's pixels with level 0's outside the rectangle's border
  and the core's frame (rebase note).

## User direction 2026-10-16 (no added Go Back / Cancel rows) and checklist item D5-7

MZW draws no screen and adds no row; no Go Back or Cancel row is added anywhere.  The named screen of D5-7 stays
D6f's.

## What the user checks

In the Windows graphics and in the DOS graphics (switch with Ctrl+Shift+Backspace or the system menu), during play,
with the World Map window open.  Zoom out (-1): Ctrl+Shift+Minus, the wheel over the map or "Zoom out (half)" in the
system menu; zoom in (+1): Ctrl+Shift+Plus or the wheel; back to normal (0): Ctrl+Shift+0.

* **MZW-1** At the normal zoom (0) the World Map's white rectangle is exactly as before.
* **MZW-2** Zoom out (-1): the rectangle on the World Map becomes larger, about twice as wide and high, and outlines
  the area the main map window now shows.  The old small rectangle is gone, and the World Map's land, sea, cities
  and units are intact where it was (no white remnants, no holes).
* **MZW-3** Zoom in (+1): the rectangle becomes smaller and outlines the zoomed-in area of the main map.
* **MZW-4** At -1 and at +1, move the view (press C, let the game go to the next unit, move a unit until the map
  scrolls, click in the World Map): the rectangle follows every time, and no old rectangle stays behind.
* **MZW-5** (expected near a pole) At -1 near the north or the south edge of the world the rectangle stops at the
  World Map's top or bottom edge of the world, because the zoomed-out map shows nothing beyond the poles: not a
  failure.
* **MZW-6** Back to 0: the game's own rectangle returns at once; nothing of the larger or smaller one remains.
* **MZW-7** At -1 and at +1, switch the graphics: the World Map shows the same rectangle in the other graphics (in
  the DOS graphics the World Map is still the Windows game's World Map until unit D6e draws the DOS one).
* **MZW-8** At -1, open a menu or a dialog over the World Map, or move a window across it: they are drawn normally
  over the World Map; when they go, the World Map and its rectangle are intact.

## For the records

* **draft D** (`docs/verify/ext-d1-draft-D.md`, section 5 and 7.4): MZW's World Map rectangle (method above), drawn
  into `g_win` at -1 and +1 from the one geometry; section 2 "Not zoomed" (5.8) and 19's row "5.8 not zoomed": the
  World Map's image is not zoomed, its view rectangle follows the level (MZW).
* **RUNNING.md** (the "not zoomed" sentence, with FIDELITY.md): the World Map's rectangle follows the zoom level.
* **DESIGN.md** (the zoom paragraph near 4319): at -1 and +1 the World Map outlines the map window's area; the core's
  rectangle hidden by the core's own pixels; presentation only.  12.1 (the headless relation, near 1768): "except,
  at map zoom -1 and +1, the World Map pixels that MZW's patch owns (`pmap_smrect_owns`)".
* **RUNNING.md** (the `presented.log` row): the relation check admits the World Map pixels MZW's patch owns at -1 and
  +1.
* **FIDELITY.md** F185: at -1 and +1 the World Map's rectangle shows the zoomed area instead of the core's view
  (the user's request 2026-10-16); level 0 unchanged; P0; tests test_map world_map_rect, ext_zoom's centring runs;
  user checks MZW-1..MZW-8.
* **manual-checklist-ext.md**: D6d-6's remark answered by MZW; items MZW-1..MZW-8 (above).
* **STATUS.md**: unit MZW READY (staged), then landed by the build slot.

## Landing (2026-10-16, build slot)

**Landed 2026-10-16 18:37:25 UTC; cycle ALL_GREEN 19:04:41 UTC; RELEASE_OK 19:12:04 UTC; user build
`build/user-builds/mzw/`.**  Done by the build slot directly after MZ's user build, as the orchestrator allowed (MZW
green; no docs pass between MZ and MZW).

1. **Bases.** `build/mzw-prep/land.py` (12 rows): the 10 tree files still had their bases
   (`build/mzw-stage/BASE-SHA256.txt`: MZ's landed copies for `pmap_int.h`, `pmap_layer.c`, `pmap_zoom.c`,
   `test_map.c`, `ext_zoom.py` and the golden; the tree's for the rest), this record and `pmap_smrect.c` were absent,
   and the 12 staged copies had the SHA-256 frozen in `build/mzw-prep/staged.sha256` (frozen about 18:36 UTC after
   the record's last staging edit); test.cmd and build.cmd had their bases. Dry run `DRY_RUN_OK 12`. No rebase was
   needed at the slot.
2. **Snapshot and copy.** Before writing: the tree's Checked test outputs (59 files of `build/test/Checked`, MZ's
   cycle) in `build/mzw-prep/before`, the tree's previous 10 files in `build/mzw-prep/tree-before`. The 12 files byte
   for byte (10 changed, 2 new): `LANDED 12`; manifest `build/mzw-prep/landed.sha256` (with test.cmd's and
   build.cmd's unchanged SHA-256); `landed-at.txt`. No build.cmd or test.cmd change.
3. **Cycle** (`build/mzw-prep/mzw-cycle.ps1`; status `build/mzw-status.txt`, logs `build/mzw-<n>-<step>.log`):
   - 1 build-checked: exit 0, 196 s, BUILD_OK; portable sources checked 294.
   - 2 test-checked: exit 0, 1434 s, TESTS_OK, 27 sections, failed 0. `w32_test_host_win32` passed at the first run
     (395 checks): no GetKeyState rerun and no -r2 test step were needed.
   - 3 g1-checked: exit 0, EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events): **ALL_GREEN**.
   - 4 build-release: exit 0, 224 s, BUILD_OK, portable sources 294: **RELEASE_OK**.
4. **Comparison** (`build/mzw-prep/compare.py`, output `compare.txt`; the predictions in
   `build/mzw-prep/predictions.txt` were written at 18:37:05 UTC, before the copy-in; one word, their stated writing
   time, was corrected at 18:37:34 UTC, before any output of the cycle; prediction against output in
   `build/mzw-prep/comparison.txt`): 50 of 59 files equal (lines with times left out). The differences, all
   predicted:
   - `sections/unit.log`: `test_map` 263 -> 285 checks; the OBS_COST line (host time).
   - `ext-zoom.txt`: the four `ZOOM centre ok` lines gain the World Map's part (`World Map rectangle [42, 20, 123, 76]
     around the core's frame [62, 40, 102, 68] (scale 2, 270 border and 132 hidden pixels)` at the pole, `[42, 26,
     123, 82]` mid-latitudes, both profiles); `ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32 centre
     runs 4` and every other ZOOM line unchanged (the 628 changed golden samples matched the landed golden).
   - `ext-p0.txt`: `PASS V4 menus zoom (presented.log): 790 -> 791 shows with the layer` (the tick show of the moved
     rectangle); `P0_OK checks 476` unchanged.
   - `obs-lint.txt` and `sections/d3a_obs_lint.log`: OBS_LINT_OK files 119 -> 120 (probes 203, callsites 98).
   - `nodos.txt`: 1729 -> 1731 files (`pmap_smrect.c` and this record), 0 hits.
   - `coverage.txt` and `sections/coverage.log`: "other functions entered" 665 -> 662 (informational).
   - `sections/times.txt`: section times (wall 1432.5 s).
   Every other output equal: EXT_ADAPT_OK checks 154 (every line), REGISTRY_OK, NODOS_OK, OBS_TABLES_OK probes 203
   sites 98, ADAPT_OK rows 98 steps 22, EXT_ASPECT_OK, MIRROR_OK runs 29, REPLAY_OK checks 70, EXT_FRAMES_OK,
   EXT_TIMELINE_OK, EXT_CONTINUE_OK, EXT_SLOTS_OK, EXT_BS_OK, p4tests and the other sections.
5. **User build** `build/user-builds/mzw/`: `civ64.exe` (the Release build, SHA-256 a4293be6...af10f9ac),
   `CIVWIN.zip` and `civdos.zip` (byte-identical copies from `user-builds/d4`, SHA-256 checked) and
   `WHAT-TO-CHECK.txt` (MZW-1..MZW-8 in plain words, MZW-5 the pole limit as expected; the test save MZTEST.SAV of
   the checks chat for MZW-4, MZW-5 and MZ-1..MZ-3; the builds it contains: mz, ux4b, d5p, ux4, d6d, sl and the
   earlier ones; the still-open items from the checklist's pending rows at 19:13 UTC: MZ-1..MZ-7, M-3b,
   D5P-1..D5P-10, UX3-6, P47-1, with D6d-4 replaced by MZ-4 and D6-1, D5-7 coming with D6f).
6. **Not done here**: the entries of "For the records" (draft D 5, 7.4 and 5.8 with 19's row, RUNNING (the "not
   zoomed" sentence and the `presented.log` row), DESIGN (the zoom paragraph and 12.1's relation), FIDELITY F185, the
   checklist's D6d-6 and MZW-1..MZW-8, STATUS) are the next joint docs pass's.

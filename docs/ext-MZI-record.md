# Extension unit MZI (the centring at map zoom level +1) - record

Draft for the build slot.  A priority bug fix from the user's report (2026-10-16 about 19:24 UTC, direct): "Note that
MZ is accepted but now we have a problem centering with the zoomed in view. I've uploaded test save, cavalry on the
north position does not center properly when zoomed in mode. investigate and explain problem an the fix.", then "not
north -> south of the screen", then (about 19:45 UTC) "zoom +1 problem was not related to vertical but this time
rather horizontal for the given case."  The orchestrator's ruling (target behaviour): at +1, whenever the game
centres its view on a unit (C, or its automatic centring or scroll to the next unit), the active unit's square lands
at the centre of the map window, except where the +1 layer would have to leave the game's view (an edge limit);
plain moves of the same unit keep D6d-3's least pan with a one-square margin; a wheel's or a menu zoom's anchor holds
until the next such event; both profiles share the one geometry; -1 (MZ) unchanged.  The orchestrator accepted both
parts of the planned fix (about 19:42 UTC): the game's request at every SetMapViewAndRedraw, and a different active
unit centred where the +1 view would have to scroll ("what the user's 'automatically performed by the game itself'
means at +1, even where the game's own view does not move").

Staged in `build/mzi-stage/` on the tree after the MZ and MZW landings; bases copied 2026-10-16 19:39:35 UTC
(`BASE-SHA256.txt`).  Private builds and runs only in `build/mzi-stage/obj/` (an overlay `obj/src` = tree + stage,
built with build.cmd's own flags through `obj/b.cmd`; harness copies in `obj/exe`: `base-harness.exe` = the tree's
Checked harness of 18:40:41 UTC, after MZW's landing, byte-identical to the tree's at copying; `mzi-harness.exe` the
overlay's).  The test save is a read-only copy of the user's `MZTEST.SAV` (`obj/data/`, SHA-256 424588ed...).

## Status

READY_TO_BUILD.  At +1, whenever the game sets its view (its centring on a unit: C, the next unit, a unit reaching the
edge of its view; also a World Map click and the scroll keys), the zoomed-in map puts the middle square of the game's
request (the unit's square) exactly at the map window's centre, even when the game's own view does not move; a
different active unit that the zoomed-in map would have to scroll to is centred too.  The only limit: the zoomed-in
map never leaves the game's own view (an edge limit: the game view's edges, and with Map Making the map's north and
south edges).  Plain moves of the same unit keep D6d-3's least pan; a wheel's or a menu zoom's anchor holds until the
next such event; -1 (MZ) is unchanged; both profiles share the one geometry.  In MZTEST.SAV the Cavalry, before 3.4
squares east and 1.9 south of the centre, is centred (within 0.8 of a world pixel) in both graphics.  Builds, unit
tests (test_map 305), ext_zoom (with 12 new runs and the golden's 244 +1 samples, the base proven to reproduce the
old golden), P0 (164 lines equal) and ext_adapt's map runs pass privately (Results).

## The user's report, reproduced on the base build (before any change)

`obj/repro.py` (private) loads MZTEST.SAV from the title menu (`l`, Enter, the Open dialog answered MZTEST.SAV) at
1920x1440 (k = 3; the map client 624 x 427 virtual pixels = 19.5 x 13.3 squares; at +1 the layer shows 312 x 214
world pixels = 9.75 x 6.7 squares, the middle half of the game's view each way), then real key presses (`w` wait,
`c` centre).  `--probe`s on BlinkActiveUnitUntilInput (the active unit) and CenterMapViewOn (the game's centring)
name the unit and the square; presentation-diag.log gives the game's view (xv, yv, cw, ch) and the layer's origin.
"Offset" is the unit square's centre less the world pixel at the map window's centre (+x east, +y south), in world
pixels and squares (32 world pixels).

**A. Zoomed in with the wheel near the top of the map window** (the usual way in; at 24,000 ms, before the game's
first centring), then `w`, `w`, `c`, ... (the game centres its view on each unit):

| Base build, Windows (DOS identical) | Game's view (xv, yv) | Layer origin | Offset |
|---|---|---|---|
| Militia 68,13 after load | 1888, 224 | 2044, 266 | -8, +59 (-0.25, **+1.85 squares**: the layer's bottom margin) |
| Legion 41,24 after C (game centres) | 1024, 576 | 1064, 618 | **+108, +59 (+3.38, +1.85 squares)** |
| **Cavalry 13,43** (game centres, CenterMapViewOn(13,43)) | 128, 1184 | 168, 1226 | **+108, +59 (+3.38 east, +1.85 south)** |

**B. Zoomed in from the start (--zoom +1: the layer centred at first)**, `w`, `w`, `c`, `w`, `c`:

| Base build | Game's view | Layer origin | Offset |
|---|---|---|---|
| Militia, Legion 49,25 (game centres) | 1888,224; 1280,608 | centred | -8, -6 (the game view's own half-square) |
| `w` to Legion 2 41,24 (inside the game's view: the game does not move) | 1280, 608 | 1280, 715 | -108, -38 (-3.38 west, -1.18 north) |
| `c` on Legion 2 (game centres) | 1024, 576 | 1064, 683 | **+108 (+3.38 squares east)** |
| `w` to the Cavalry (game centres) | 128, 1184 | 168, 1291 | **+108, -6 (+3.38 squares east)** |

**C. Zoomed in with the wheel in play, then C on the same unit** (the wheel at 25,500 ms, C at 26,000 ms): the game's
view does not move (1888, 224 both times); base: the Militia stays +1.85 squares south (no layer change at all).

The game's own view is centred on the Cavalry in every case: its centre is 8 and 5.5 world pixels from the square's
centre (the view is whole squares: 19 columns, 13 rows, CenterMapViewOn 1110:03AE `left = x - cols/2`, `top = y -
rows/2`).  The south edge is not involved: the view (y 1184..1611) passes the south edge by 11 pixels because the
Romans of MZTEST.SAV do not know Map Making (advance 8): without it SetMapViewOrigin (1208:2140) lets the view go up
to 25 rows beyond either pole (findings: "possible without advance 8"); with it the view stops at the edges (the
scroll range 0..1600 - client height).  The user's case is mostly horizontal (+3.38 squares east), as the user said.

## Cause (plain words)

At +1 the zoomed-in map is a magnifier over the middle half of the game's own view: it may only show what lies inside
the game's view.  The +1 rules before MZI were:

1. a new game view keeps the magnifier's place in the window (draft D 11.3: "the layer keeps its offset relative to
   the client"), i.e. whatever offset from the game view's centre it had, it keeps;
2. then it stays inside the game's view;
3. then the active unit is followed with the least pan that shows it one square inside the magnifier's edge (D6d-3).

So any offset the magnifier once picked up stays for the rest of the session: a wheel zoom (it zooms at the pointer,
so the magnifier sits around the pointed part of the game's view) or a least pan to a unit that the game did not
centre (the next unit already inside the game's view, or a unit moving within it).  When the game then centres on
the Cavalry, rule 1 carries the old offset over, and rule 3 only pulls the Cavalry one square inside the
magnifier's edge: 3.4 squares east and 1.9 south of the centre in the user's case.  Pressing C changes nothing when
the game's view does not move (the magnifier sees no new view at all).  Rule 2 and the south edge are not the cause:
the game's view is centred on the Cavalry and the magnifier could be centred there.

In code: `pmap_layer.c` (the view-change branch, +1: [2 C statements condensed: setting `xo`, `yo`], then `pmap_geo_clamp`), and
`pmap_inview.c` (BlinkActiveUnitUntilInput: `pmap_follow_square` only).  The same mechanism as MZ's ratchet at -1,
which MZ fixed at -1 only.

## The fix

* **The game's request** (`pmap_inview.c`): at the entry of SetMapViewAndRedraw (1110:03E9, an existing observer probe
  with the entry phase; its callers are CenterMapViewOn for every centring on a unit or a city, the World Map click
  and the scroll keys), while the level is +1 and the view is not ProcessCity's temporary one, the requested square
  is taken: `(left + cols/2, top + rows/2)`, which for CenterMapViewOn is exactly its square (left and top before
  SetMapViewOrigin's limits and wrap).  It is attached to the view snapshot of that redraw (`take_view`), dropped if
  no snapshot comes before the next input wait.  The next layer update (`pmap_layer.c`) puts that square's centre at
  the map window's centre (`pmap_centre_square`: the copy of the square nearest the game view's centre, so a request
  across the date line never jumps a world width), then the +1 clamp (inside the game's view).  This happens whether
  or not the game's view moved, so C always centres.  The view changes without a request (the scroll bars,
  ProcessCity's restore) keep the old rule (the place on the client).
* **A different active unit** (`pmap_inview.c`, BlinkActiveUnitUntilInput's entry): the blinking unit is tracked at
  every level; when it is a different unit than the last one and the magnifier would have to pan to show it with the
  one-square margin, the magnifier is centred on it (`pmap_centre_unit`), then clamped to the game's view.  A unit
  already shown with the margin does not move the magnifier (the game's own rule for its view, EnsureSquareInMapView
  11C0:231D, at the magnifier's size).  The same unit after a move keeps the least pan (D6d-3).
* **Anchors**: a wheel's or a menu zoom's new geometry drops a pending request (the anchor holds until the next
  request or the next new unit; the blinking unit tracked at level 0 too, so zooming in does not count as a new unit).
* **-1 unchanged** (MZ): a request there is ignored (MZ's centring on every view change, then the pole rule).
* Diagnostics: presentation-diag.log's map line gains `centre_view N centre_unit N` at its end.
* Both profiles: the geometry is shared (the probes run whichever profile is shown); the DOS runs give the same
  numbers.  Nothing reads or writes the emulation that was not read before except SetMapViewAndRedraw's three
  arguments and the view's columns, rows and the two "temporary view" flags at its entry (reads inside the guard).

## Edge limit (plain words)

The magnifier never leaves the game's view (at +1 there is no picture outside it).  So:

* **When the game centres its view on the unit** (C, or the game moving its view to the next unit or to a unit that
  walked to the edge of its view), the unit is centred exactly, everywhere on the map, as long as the game's own view
  is centred on it.  The game's view stops at the north and south edges only once your civilization knows **Map
  Making**: then a unit within about **3 rows of the north or south edge** (a quarter of the map window's height;
  rows 0-2 and 47-49 at 1920x1440) stays off the centre toward that edge.  Without Map Making (as in MZTEST.SAV) the
  game's view itself passes the edges, and the unit is centred even on the last row.
* **When the next unit is already inside the game's view** (the game does not move its view), the magnifier centres
  it if it can; if the unit is within about a quarter of the window's width or height of the game's view's edge
  (about 5 columns or 3 rows at 1920x1440), the magnifier goes as far as the game's view allows, and the unit stays
  toward that edge, one square inside the magnifier.  In MZTEST.SAV: Legion 2 at 41,24 after `w` from Legion 1 (the
  game's view starts at column 40) stays 3.4 squares west of the centre; pressing C makes the game centre on it, and
  then it is centred exactly.

## Tests

* `tests/test_map.c` `mzi_centring()` (20 checks, after MZ's `view_changes()`), a 480 x 400 client at k = 2 (+1:
  240 x 200 world pixels): +1 by the wheel near the top left; the game's centring on 55,22 (exact; the old rule kept
  the wheel's place); the wheel again, its anchor held; C with the view unchanged (centred); a view without a request
  keeps the place (11.3); a request waiting for its snapshot does nothing; the pole stop (Map Making): the unit on
  row 1 52 world pixels north of the centre, row 3 centred; across the date line: column 80, column 0 (the copy
  nearest the view) and column 91 (= 11, a request beyond the wrap); a new unit shown with the margin (the layer
  stays), one to pan to (centred), one column inside the game view's west edge (the edge limit, one square inside);
  the same unit moving (the least pan, D6d-3); -1 unchanged (MZ's centring); a wheel at a new level drops a pending
  request.
* `tests/harness/ext_zoom.py` (extension MZI block): MZTEST.SAV made again from CAE3540B.SAV with saveedit
  (`MZI_EDITS`, 4028 byte edits; the decoded image equals the user's save, checked privately), loaded from the title
  menu, at 1920x1440, Windows (`win`) and DOS from the start (`dos`), six runs each: `wheel` (25,900 ms: the wheel's
  anchor holds), `c` (26,900: C, the view unchanged, centred), `legion2` (29,900: the edge limit at the game view's
  west edge), `cavalry` (31,900: the user's case, centred), `dateline` (25,900: a World Map click on column 0, the game
  view across the date line, column 80 centred) and `dateline2` (26,900: the request's column 91, column 11 centred);
  every layer inside the game's view; the two profiles' geometries equal; one `ZOOM mzi` line per run; ZOOM_OK gains
  `mzi runs 12`.

## Results (private, `build/mzi-stage/obj/`)

All on the overlay `obj/src` (the tree + the stage) with build.cmd's own flags (`obj/b.cmd`, `--nogen` after the MSVC
set-up); private outputs under `obj/` only.

* **Builds**: Checked, CheckedNoObs and Release BUILD_OK, portable sources checked 294 (c11, c17, c99 parse); the
  Checked overlay rebuilt after the test vectors (`b-src-checked2.log`) and once more on the tree after UX5's landing
  with the final (LF) staged files (`b-src-checked3.log`: BUILD_OK, 294; with it test_map PASS 305, the twelve MZI runs identical to the earlier ones (`obj/run/mzi-final.txt`), RUNADAPT 14/0 with the same lines, OBS_LINT_OK 120/203/98).
* **Unit tests** (`ut.cmd`: every `test_*.exe` and `w32_test_*.exe`, the tree's build/gamedata read): failed 0 in
  Checked (89 programs), CheckedNoObs (86) and Release (89); test_map PASS 305 checks (base 285: the tree's Checked
  test_map copied and run privately), CheckedNoObs 1.
* **obs_lint** OBS_LINT_OK files 120 probes 203 callsites 98 (unchanged); **registry.py check** REGISTRY_OK (the
  tree's build/dosdata and build/dos/disasm read); **nodos.py check --variant Checked** NODOS_OK, 0 hits; test.cmd
  not staged (testpar.py not needed).
* **The report on the base build** (`obj/exe/base-harness.exe`; `obj/repro.py`, tables above) and **on MZI**
  (`obj/exe/mzi-harness.exe`), the same runs:

| MZTEST.SAV, 1920x1440, both profiles | Base offset (squares) | MZI offset (world pixels) |
|---|---|---|
| wheel near the top at 25,500 ms, before any key (the anchor) | -0.25, +2.85 | -8.0, +91.2 (anchor held) |
| C on the Militia, the game's view unchanged | -0.25, +1.85 | 0.0, -0.8 (centred) |
| Legion 1 49,25 (game centres) | -0.25, +1.85 | 0.0, -0.8 |
| `w` to Legion 2 41,24 (game view unchanged) | -3.38, +0.85 | -108.0, -0.8 (edge limit: the layer at the game view's west edge, Legion 2 one square inside) |
| C on Legion 2 (cycle run) | +3.38, -0.18 | 0.0, -0.8 |
| **the Cavalry 13,43 (game centres)** | **+3.38, +1.85** | **0.0, -0.8 (centred)** |
| World Map click on column 0 (game view x 2272..2896, across the date line) | -0.25, -0.18 | 0.0, -0.8 (column 80 = 0) |
| next World Map click, request column 91 (= 11) | -0.25, -0.18 | 0.0, -0.8 |

  (-0.8: the map client is 427 virtual pixels high, 213.5 world pixels at +1, so its exact centre lies 0.75 of a world
  pixel below the world pixel on which the square's centre is put.)
* **ext_zoom.py** (the staged copy through `obj/runzoom.py`, which runs it as the tree's with the tree's ext_p0.py):
  - `--only mzi` on MZI: ZOOM_OK ... mzi runs 12, all twelve `ZOOM mzi ok` (the numbers above in both profiles; the
    two profiles' geometries equal).  On the base harness (`obj/run/mzi-on-base.txt`): ZOOM_FAILED=10 (`wheel` ok
    in both, the anchor; `c`, `legion2`, `cavalry`, `dateline`, `dateline2` FAIL in both, e.g. `cavalry` +108.0,
    +59.2 world pixels).
  - the whole matrix with `--update -j 8` on MZI (`obj/run/zoom-update.txt`, 28 min 45 s): ZOOM_OK combinations 32
    runs 108 samples 628 map comparisons 32 centre runs 4 mzi runs 12; MZ's centring lines unchanged (pole +0.0,
    +96.5; mid +0.0, +0.5); the golden rewritten: 244 of 628 samples differ, exactly every +1 sample of load, orders
    and s4 (`obj/run/golden-base.txt` is the tree's golden).
  - **the base reproduces the tree's golden**: the tree's own ext_zoom.py with `base-harness.exe`
    (`obj/run/zoom-base-check.txt`, 40 min 39 s at -j 6): ZOOM_OK combinations 32 runs 108 samples 628 map
    comparisons 32 centre runs 4.  So the 244 changed samples are MZI's.
* **P0** (the tree's `ext_p0.py --vars V0,V4,V4d -j 3` with `mzi-harness.exe`, private root): P0_OK checks 164; the
  164 lines equal the tree's last P0 output line for line (`build/ux5-prep/before/ext-p0.txt`).
* **ext_adapt.py's map runs** (`obj/runadapt.py`: the tree's ext_adapt.py `plain` and m_runs): RUNADAPT checks 14
  failed 0 on MZI and on the base; the outputs differ in the one `ring: posted` line above.
* **The save**: `MZI_EDITS` applied to CAE3540B.SAV gives an image equal to MZTEST.SAV's decoded image (4028
  edits: the 4000 visibility bytes `|= 2` (3913 of them change), 13 unit bytes, 5 other bytes, 10 map-page bytes).

## Expected changes at the build slot

Against the tree's last cycle (UX5's):

* `sections/unit.log`: `test_map` 285 -> 305 checks (Checked; Release the same), CheckedNoObs 1 (the refusal,
  unchanged); the OBS_COST line (host time).
* `ext-zoom.txt`: twelve new lines `ZOOM mzi ok <run> win|dos ...` (the numbers under Results) and `ZOOM_OK
  combinations 32 runs 108 samples 628 map comparisons 32 centre runs 4 mzi runs 12`; the 32 `ZOOM ok` combination
  lines and MZ's four `ZOOM centre ok` lines unchanged.  The golden file changes in **244 of 628 samples, exactly
  every +1 sample of `load`, `orders` and `s4`** (100 + 70 + 74; both profiles; from the first sample after loading,
  25,000 ms): after a load the game centres its view on its first unit, and the layer is now centred exactly on the
  unit's square instead of on the game view's centre (8 and 5.5 world pixels away), so every later +1 picture
  differs.  All -1 samples and the `new` scenario's (no centring at +1 inside its samples) are unchanged.  Section
  time: twelve more runs of 26..32 s of virtual time (about 40 s of wall time at -j 8).
* `ext-adapt.txt`: one line, `PASS ring: posted ...`: its last release after the `zoom +1` command is posted at
  `0202(639,248)` instead of `0202(639,253)`: between the press and the release the game sets its view, and the +1
  layer now centres the requested square (5 world pixels from the view's centre).  `ring equals ringref` passes;
  EXT_ADAPT_OK's count unchanged.
* `nodos.txt`: one more file (this record), 0 hits.
* `coverage.txt`, `sections/coverage.log` possibly ("other functions entered", informational); `sections/times.txt`.
* Unchanged: P0 (the 164 V0/V4/V4d lines equal the tree's, `V4 menus zoom ... 791 shows` included), ext_frames,
  ext_mirror, ext_timeline, ext_continue, ext_replay, ext_slots, ux3_aspect, the BS sections, scenarios, p4tests,
  obs_lint (files 120, probes 203, call sites 98), REGISTRY_OK; ext_g1 EXT_G1_OK unchanged (the core is untouched).

## Rebase notes

* Bases (`BASE-SHA256.txt`, copied 2026-10-16 19:39:35 UTC, after MZ's and MZW's landings): the 7 staged files'
  bases still equal the tree after UX5's landing (rechecked); test.cmd changed under UX5 (its ux3_aspect echo; MZI
  does not stage test.cmd).  Every hunk carries an `extension MZI` comment; the ext_zoom.py block is delimited
  (`# ---- extension MZI ... # ---- end of extension MZI ----`), plus four small hooks in `main()` (the job list, the
  pool's futures, the checks after MZ's, the ZOOM_OK line) and the docstring paragraph.
* **UX5** (landing during staging): touches comments in present/present.c, present/dos/pdos_profile.c,
  win64/civ64_main.c, harness_main.c, profile.h, plus pdos_seq.c/.h and test.cmd: none of MZI's files.
* **D6e** (staging): shares `tests/harness/ext_zoom.py` (its "not zoomed" small-map check) and possibly
  `tests/headless/harness.c` and `present/map/pmap_smrect.c` (not MZI's).  Whichever lands second reapplies its
  delimited block; the ZOOM_OK line then carries both additions (`... centre runs 4 mzi runs 12` and D6e's).  If D6e
  changes the +1 zoomed pictures (the small map at +1), the golden's +1 samples change for both reasons: re-record
  after both, with the base proof of the one landed first.  MZW's World Map rectangle at +1 follows the layer as it
  does after a follow (pmap_smrect_update at every layer update), so D6e's DOS small map gets MZI's layer place
  through `pmap_smrect_rect` unchanged.
* **D6f** (menus) and the docs pass: no shared file.
* Shared counts: none (no new source file: portable sources 294 and obs_lint's files 120 unchanged; probes 203 and
  call sites 98 unchanged: MZI uses SetMapViewAndRedraw's existing entry phase).

## Build-slot steps

1. Copy the staged files (`BASE-SHA256.txt`'s list: `present/map/pmap_int.h`, `pmap_zoom.c`, `pmap_layer.c`,
   `pmap_inview.c`, `tests/test_map.c`, `tests/harness/ext_zoom.py`, `tests/harness/ext-zoom-golden.txt`) and this
   record into the tree; test.cmd and build.cmd unchanged (no `BUILD-TEST-ADDITIONS.md`).
2. The three-step cycle: `build.cmd checked`, `test.cmd checked` (expected changes above), `ext_g1.py check`
   (EXT_G1_OK unchanged: the core is untouched).
3. The user build for the checks below (Release).

## What the user checks

In the Windows graphics and in the DOS graphics (switch with Ctrl+Shift+Backspace or the system menu).  Load your
save **MZTEST.SAV** (File, Load).  The Romans have four units: a Militia far east (no moves left), **Legion 1** and
**Legion 2** in the middle of the map (Legion 2 a little west of Legion 1), and the **Cavalry** far west, near the
south edge.  Zoom in (+1): Ctrl+Shift+Plus, the mouse wheel forward over the map, or "Zoom in (double)" in the
system menu.  `w` (wait) makes the next unit active; `c` centres the map on the active unit.

* **MZI-1** (the report) Zoom in with the mouse wheel while the pointer is near the top of the map window (away from
  the centre).  Press `w` until the Cavalry blinks (the game moves its view to it): the Cavalry's square is in the
  centre of the map window.  Before MZI it was about 3 to 4 squares to the right (east) and about 2 squares below the
  centre.
* **MZI-2** (C on the same unit) Zoom out to normal, then zoom in with the wheel with the pointer near a corner of the
  map: the map zooms in around the pointer (as M-2 accepted), so the blinking unit may be away from the centre.  Press
  `c`: the unit's square comes to the centre (before MZI nothing moved when the game's own view stayed where it was).
* **MZI-3** (the Legions in the middle of the map) Make Legion 1 active and press `c`: it is in the centre.  Do the
  same with Legion 2: centred.  Each time, nothing is off to the left or right.
* **MZI-4** (`w` to Legion 2: expected, not a failure) With Legion 1 active and centred, press `w`: Legion 2 becomes
  active, but the game does not move its own view (Legion 2 is already in it, one column from its left edge), and
  the zoomed-in map can only show what the game's own view holds.  So the zoomed-in map moves left as far as it can:
  Legion 2 is about 3 squares left (west) of the centre, one square inside the left edge.  The game itself does the
  same at normal zoom (0): there, too, `w` leaves Legion 2 near the window's left (west) edge, in the second column,
  because the game does not scroll for a unit that is already in its view; the zoomed-in map matches what the game
  does.  Press `c`: the game centres on Legion 2 and it is exactly in the centre.  (A next unit that is not that close
  to the edge of the game's own view is centred at once.)
* **MZI-5** (D6d-3 unchanged) Move a unit square by square with the keys: the zoomed-in map follows it with a
  one-square margin, as before (it does not jump to the centre at every step).  When the unit reaches the edge of the
  game's own view, the game moves its view to the unit, and the zoomed-in map then shows the unit in the centre.
* **MZI-6** (the east-west wrap) Click the World Map near its left or right edge, so that the game centres near the
  place where the map wraps around (in the Windows graphics; in the DOS graphics too if its World Map takes the
  click): the clicked square is in the centre of the zoomed-in map, the map runs on across the wrap, and it does not
  jump.
* **MZI-7** At +1, switch the graphics with Ctrl+Shift+Backspace: the other graphics show the same place with the same
  unit in the centre; switch back: the same.  Zoom out (-1): MZ-1..MZ-7 as you accepted them (unchanged).

Expected limit (not a failure; MZTEST.SAV cannot show it): once your civilization knows **Map Making**, the game's
own view stops at the north and south edges of the map.  A unit within about 3 rows of the north or south edge then
stays a little off the centre toward that edge when the game centres on it (the same kind of limit as MZ-3 at -1).
Without Map Making, as in MZTEST.SAV, the game's view goes beyond the edges, and units there are centred too.

## Decisions

* **The game's request, not every view change** (unlike MZ at -1): SetMapViewAndRedraw's entry is the one place where
  the game says "show this view", including C when the view does not move (which no view change shows), and its
  arguments give the exact square (the game's view itself is whole squares, up to half a square off the unit).  View
  changes without it (the scroll bars, ProcessCity's restore) keep 11.3's place on the client.
* **The scroll keys** (11F0:3AE9, SetMapViewOrigin then SetMapViewAndRedraw) now also centre the layer on the new
  view's middle square (before: the layer moved with the view, keeping its place).  It is the game setting its view;
  the layer shows its middle, like the World Map click.
* **A new active unit** (the orchestrator's acceptance of point 2): centred only when the layer would have to pan to
  show it with the margin (the game's own EnsureSquareInMapView rule at the layer's size), so a next unit already well
  inside the zoomed-in map does not move it.
* **No world limit at +1**: the layer stays inside the game's view (11.2 at +1, unchanged); where the game's own view
  shows rows beyond a pole (without Map Making), the layer may show them, as level 0 does.  With Map Making the
  game's view stops at the poles, and so does the layer (the edge limit).
* **The unit's square's centre, not the game view's centre**, at the map window's centre: exact, where centring on the
  view would leave up to half a square (16 world pixels; 8 and 5.5 at 1920x1440).

## Deviations from the design

* Draft D 11.3 "View changes" (+1: the layer keeps its offset relative to the client) now holds only for view changes
  without the game's request; "The active unit" gains the centring of a different active unit where the layer would
  have to pan.  11.1 (anchors) and 11.2 (clamps) unchanged.

## For the records

* **draft D 11.3** (`docs/verify/ext-d1-draft-D.md`): "View changes" at +1: the game's setting of its view
  (SetMapViewAndRedraw) centres the layer on the middle square of the request (the unit's), then 11.2; other view
  changes keep the layer's place on the client.  "The active unit": a different active unit is centred where the
  layer would have to pan; the same unit's moves keep the least pan with the one-square margin.
* **DESIGN.md** (the zoom paragraph; the anchors): as above; the edge limit (the game's view; Map Making's pole stop).
* **FIDELITY.md** F185: at +1 the game's centring is shown centred except where the layer would have to leave the
  game's view; presentation only (P0); tests test_map `mzi_centring`, ext_zoom's MZI runs; user checks MZI-1..MZI-7.
* **manual-checklist-ext.md**: D6d-3 refined by MZI (MZI-5 covers it); items MZI-1..MZI-7 (below).
* **STATUS.md**: unit MZI READY (staged), then landed by the build slot.

## Landing (2026-10-16, build slot)

**Landed 2026-10-16 21:29:09 UTC; cycle ALL_GREEN 22:08:45 UTC; RELEASE_OK 22:18:42 UTC; user build
`build/user-builds/mzi/` (about 22:19 UTC).**  Done by the build slot on the orchestrator's instruction, after UX5's
landing (21:17 UTC; the orchestrator rechecked MZI's bases at 21:27 UTC).

1. **Bases.** `build/mzi-prep/land.py` (8 rows): the 7 tree files still had their bases
   (`build/mzi-stage/BASE-SHA256.txt`), this record was absent, and the 8 staged copies had the SHA-256 frozen in
   `build/mzi-prep/staged.sha256`; build.cmd had its base and test.cmd UX5's landed SHA-256 (e7c5015c...).  Dry run
   `DRY_RUN_OK 8`.  No rebase was needed (UX5 shares no file with MZI).
2. **Snapshot and copy.** Before writing: the tree's Checked test outputs (59 files of `build/test/Checked`, UX5's
   cycle) in `build/mzi-prep/before`, the tree's previous 7 files in `build/mzi-prep/tree-before`.  The 8 files byte
   for byte (7 changed, this record new): `LANDED 8`; manifest `build/mzi-prep/landed.sha256` (with build.cmd's and
   test.cmd's unchanged SHA-256); `landed-at.txt`.  No build.cmd or test.cmd change.
3. **Cycle** (`build/mzi-prep/mzi-cycle.ps1`; status `build/mzi-status.txt`, logs `build/mzi-<n>-<step>.log`):
   - 1 build-checked: exit 0, 321 s, BUILD_OK; portable sources checked 294; no warning.
   - 2 test-checked: exit 0, 2036 s, TESTS_OK, 27 sections, failed 0 (wall 2033.0 s).  `w32_test_host_win32` passed
     at the first run (395 checks): no GetKeyState rerun and no -r2 test step were needed.
   - 3 g1-checked: exit 0, EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events): **ALL_GREEN**.
   - 4 build-release: exit 0, 580 s, BUILD_OK, portable sources 294: **RELEASE_OK**.
4. **Comparison** (`build/mzi-prep/compare.py`, output `compare.txt`; the predictions in
   `build/mzi-prep/predictions.txt` were written about 21:29 UTC, before any output of the cycle; prediction against
   output in `build/mzi-prep/comparison.txt`): 51 of 59 files equal (lines with times left out).  The differences:
   - `sections/unit.log`: `test_map` 285 -> 305 checks, 0 failures; the OBS_COST line (host time).
   - `ext-zoom.txt`: the twelve `ZOOM mzi ok` lines, both graphics equal, with the private run's numbers (wheel
     -8.0, +91.2 world pixels from the client's centre, the wheel's anchor kept; c, cavalry, dateline and dateline2
     +0.0, -0.8; legion2 -108.0, -0.8 with the layer at the game view's west edge, origin [1280, 678]) and
     `ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32 centre runs 4 mzi runs 12`; the landed
     golden matched (its 244 changed +1 samples included); MZ's four `ZOOM centre ok` lines equal.
     **Not as predicted**: six `ZOOM ok` combination lines changed their show counts (the frames shown per run, not
     samples): orders +1 at the five sizes win 246 -> 248 (at 1920x1440 also sw 287 -> 288; dos 244 unchanged), and
     s4 1920x1440 +1 sw 3892 -> 3900, win 3616 -> 3629.  These are exactly the counts of the private golden update
     with the MZI build (`build/mzi-stage/obj/run/zoom-update.txt`), while the private base run gives the old ones
     (`zoom-base-check.txt`): the extra frames are MZI's +1 recentring redraws.  The prediction overlooked them;
     nothing differs from the private runs.  `sections/ext_zoom.log`: the ZOOM_OK line.
   - `ext-adapt.txt`: the one predicted line, "ring: posted ... 0201(522,253) 0202(639,248)" (was 0202(639,253)):
     the last in-view click lands on the recentred +1 layer; `EXT_ADAPT_OK checks 154` unchanged.
   - `nodos.txt`: 1733 files as before, 1546259724 -> 1546466301 bytes, 0 hits.  **Not as predicted** in the file
     count (1734 predicted for this record): after the cycle the scanned set is 1679 files of the tree outside
     build/ (this record among them) and 54 Checked executables, so one file fewer elsewhere than at UX5's cycle; it
     is not one of MZI's and is not identified (nodos keeps no file list).  The bytes grew by the rebuilt
     executables and MZI's files.
   - `coverage.txt` and `sections/coverage.log`: "other functions entered" 665 -> 670 (informational).
   - `sections/times.txt`: section times.
   Every other output equal: P0_OK checks 476, REGISTRY_OK, NODOS_OK, OBS_TABLES_OK probes 203 sites 98, OBS_LINT_OK
   files 120 probes 203 callsites 98, ADAPT_OK rows 98 steps 22, EXT_ASPECT_OK, MIRROR_OK runs 29, REPLAY_OK checks
   70, EXT_FRAMES_OK, EXT_TIMELINE_OK, EXT_CONTINUE_OK, EXT_SLOTS_OK, EXT_BS_OK and the other sections.
5. **User build** `build/user-builds/mzi/` (`build/mzi-prep/mk_userbuild.py`, `USER_BUILD_OK 4`): `civ64.exe` (the
   Release build, SHA-256 366aa4ff...6c700776), `CIVWIN.zip` and `civdos.zip` (byte-identical copies from
   `user-builds/d4`, SHA-256 058d4e00... and 0eac32c9... checked) and `WHAT-TO-CHECK.txt` (SHA-256 99866efd...,
   CRLF, ASCII): MZI-1..MZI-7 in plain words as in "What the user checks" (MZI-1 the east and south offset of the
   report; MZI-4 the `w` to Legion 2 case as expected, with the game's own zoom-0 behaviour), the Map Making limit,
   where MZTEST.SAV is (`%LOCALAPPDATA%\civ64\CivWin`), the builds it contains (ux5, mzw, mz, ux4b, d5p, ux4, d6d,
   sl and the earlier ones) and the items still open from the checklist's pending rows at 22:18 UTC: UX5-1..UX5-7,
   D5P-7 and P47-1 checkable; D6-1 and D5-7 with unit D6f, MZW-8 with unit MZS.
6. **Not done here**: the checklist's MZI section (the orchestrator adds it) and the entries of "For the records"
   (draft D 11.3, DESIGN, FIDELITY F185, STATUS) are the next joint docs pass's.

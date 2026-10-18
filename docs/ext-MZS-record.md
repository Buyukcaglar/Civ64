# Extension unit MZS (menus, dialogs and moved windows over the zoomed map) - record

Draft for the build slot.  A defect fix from the user's checklist result MZW-8 (2026-10-16 about 20:16 UTC, results page,
the section names build mzw), verbatim: "opening a menu at -1 casts a left shifted thick shadow over the play area
map. same thing happens +1 also".  MZW-8 asked that at -1, in both graphics, menus, dialogs and windows moved over the
World Map are drawn normally and that, when they go, the World Map and its rectangle are intact.  The orchestrator's
ruling (the target): at -1, 0 and +1, in both graphics, menus, drop-downs, dialogs and moved windows over the main map
or the World Map look exactly as at zoom 0 (no shadow, hole or offset; their own normal shadow stays); when they close
the map is intact; the zoom geometry, centring and follow are not MZS's (MZI's); the game, the core and the saves are
unchanged.  The orchestrator accepted the proposed fix (2026-10-16, after the interim report): "Covered pixels come
from the port bitmap at the same coordinates (WdwMapProc's WM_PAINT, 1208:0332). Where the bitmap has none, keep the
previous pixel. Apply the same to M_dos. Fix the move-outline band too, once you have verified the ghost.", with one
requirement: "the check that catches this must run in the three-step cycle, test.cmd or ext_g1, using civ64's own
layout (--fit-layout 1). It must open a menu and a dialog at -1 and +1, in both graphics."

Staged in `build/mzs-stage/` on MZI's staged copies (MZI landed its copy-in at about 21:28 UTC, before these bases were
copied at 21:29:14 UTC: they are also the tree's; `BASE-SHA256.txt`) and the tree's `pmap_dos.c`.  Private builds
and runs only in `build/mzs-stage/obj/` (an overlay `obj/src` = tree + stage built with build.cmd's own flags through
`obj/b.cmd`; harness copies in `obj/exe`: `tree-harness.exe` = a Checked harness of the tree before MZS (the defect);
the user builds' civ64.exe copies in `obj/uiexe/<build>`).  The test save is a read-only copy of the user's
`MZTEST.SAV` (`obj/data/`, SHA-256 424588ed...); the cycle makes the same save again with MZI's `mzi_save`.

## Status

LANDED 2026-10-16 23:47:40 UTC; cycle ALL_GREEN 2026-10-17 00:25:05 UTC, RELEASE_OK 00:30:32 UTC; user build
`build/user-builds/mzs/` (see Landing).  READY_TO_BUILD was reported about 23:20 UTC.  At -1 and +1, in both graphics, a
menu, a drop-down or a dialog over the main map no longer leaves a black block in the zoomed map beside it (the user's
"thick shadow"); dragging a window across the zoomed map shows only the moving outline, no smaller copy of it; when they
close the map is intact (it already was).  The fix fills the zoom layer's in-view source as the game's own repaint does:
the covered pixels from the map's off-screen bitmap at the same coordinates, the rest kept.  Level 0, the geometry, the
centring (MZ, MZI), the World Map's rectangle (MZW), the core and the saves are unchanged.  Agent observation in civ64
itself (the Release overlay build) and in the harness, both graphics, -1 and +1; the user's checks MZS-1..MZS-6 and
MZW-8 again are pending (user build `build/user-builds/mzs/` at landing).

## What the user saw (step 1, reproduced)

Reproduced privately in civ64 itself (the user builds' civ64.exe copies, a private home and data directory: the
user's `%LOCALAPPDATA%\civ64` files were hashed before and after and are unchanged) and in the harness with civ64's
layout (`--fit-layout 1`), both graphics, -1 and +1:

* **A drawn black block, not a hole and not a shadow.**  The menu and its normal 2-pixel shadow are drawn correctly.
  Besides them, the zoom layer draws a solid black rectangle: the image of the pixels the menu covers, in black, at the
  zoom's scale and place.  At -1 it is half the menu's size, towards the map window's centre (for the Advisors menu:
  below it and inside its width, "left shifted" relative to the menu's right part); at +1 it is twice the menu's size,
  away from the centre (left of and above the menu).  It is there while the menu is open and goes when it closes: the
  map is intact afterwards.  The same for dialogs (Find City), except that at -1 a dialog in the middle of the window
  covers its own half-size image, so nothing shows there.
* **Evidence** (`obj/shots`, `obj/ui/<build>/shots`): `ui-mzw-win-b-open1-half.png` (-1, user build mzw),
  `ui-mzw-win-p1-open.png` (+1), `ui-d4-win-open.png` (user build d4 shows it already), `ui-mzw-win-d-after-half.png`
  (intact after the close); harness `w-m1-fit-v21.png` and `d-m1-fit-v21.png` (Windows and DOS graphics,
  `--fit-layout 1`); `w-m1-v20.png`, `d-m1-v21.png` (the default harness layout: no block).

## The cause

* The layer's in-view source M (`present/map/pmap_inview.c`, `refill`) takes a client pixel from the virtual screen
  where the map window's client is visible and from the map port's bitmap where it is covered (g_mapOffscreenPort
  12D8:4542, bitmap 12D8:455C, the image WdwMapProc's WM_PAINT 1208:0332 copies to the client at the same
  coordinates).  It used the bitmap only when its size equalled the client's; otherwise it filled the covered pixels
  black (draft D 6.1 "Sizes", counter `port_size`): base lines 188..227 (`b.w == m->cw && b.h == m->ch`, then the
  `memset(..., PMAP_BLACK, ...)` branch).  The DOS source M_dos (`present/map/pmap_dos.c`,
  `pmap_dos_inview_present`, base about lines 937..1029) did the same: P_dos or Wn_dos of another size than the client
  was dropped (lines 955..958, `dos_port_size`) and the covered pixels were DOS black.
* With civ64's layout (FIDELITY F103: the map window 165,0..640,480 with its scroll bars) the client is 453 x 421 at
  168,40 and the core's port bitmap is **454 x 421** (measured: a temporary log in a private build, 5 presents at
  1920x1440, `port_bmp 6772 ... bmp 454 x 421 bpp 8 ... client 453 x 421`; removed before staging).  So every covered
  client pixel was black in M (and M_dos), and the layer drew that black at its scale and place, outside the menu's
  own rectangle (the layer's clip leaves out only the menu and its shadow).  Why the core makes the bitmap one column
  wider is not traced (ResizeMapWindow 1208:0F62 closes and remakes the port before UpdateMapViewMetrics 1208:10C6
  sets the scroll ranges; a scroll bar appearing after the port was made would explain it); the fix does not depend
  on it.
* The harness's default layout (the map client 171,40 624 x 427) has a bitmap of the client's size, so every check of
  the cycle drew the layer without the defect: it hid there from unit M (2026-10-11) until the user's MZW-8.
* **First build:** the Windows graphics since unit M (the layer and M, 2026-10-11): user build d4 already shows it
  (`ui-d4-win-open.png`); the DOS graphics since unit D6d (M_dos; the DOS graphics had no zoom before).
* **The move outline's ghost (verified):** while a window is dragged across the main map at -1, the move outline is an
  XOR band drawn on the screen (user_syscmd.c `outline()`); the layer's clip leaves the band out, but M's visible region
  does not, so `refill` copied the band's XOR pixels into M and the layer drew a half-size ghost of the outline towards
  the centre.  Harness run `w-drag-fit` (`--fit-layout 1`, CAE3540B.SAV, the World Map's caption dragged from host
  300,36 to 1000,402 at 1920x1440): `shots/w-drag-v70.png` (view-00070, during the drag) shows the band at half-view
  350..598 x 183..370 and its ghost at 472..598 x 280..375, which is the band's image under the -1 transform (M's area
  starts at about 421,218 in that view; 421 + 0.75 x 65 = 470 .. 421 + 0.75 x 231 = 594, 218 + 0.75 x 82 = 280 ..
  218 + 0.75 x 207 = 373); `w-drag-v104.png` (after the drop: no ghost).  The large black areas around it are the
  save's unexplored squares, not the defect.

## The fix (the orchestrator's accepted proposal)

* **M** (`pmap_inview.c`): `refill` takes the port bitmap's pixels where it has them, the overlap at the same client
  coordinates (as WM_PAINT's BitBlt copies no source pixel outside the bitmap, w16_BitBlt likewise); a covered pixel
  the bitmap does not have, or every one when there is no usable bitmap, keeps M's previous pixel (`port_size` still
  counts those presents); black only where M never had a pixel (M is black when allocated).  The visible pixels come
  from the screen as before, **less the move or size outline's band strips** (PmapMap.band, the strips of
  `pmap_screen_exclusions`): those stay the port's (or the previous) pixels, so the layer shows no ghost.
* **M_dos** (`pmap_dos.c`): the row fill moves to `md_fill`; P_dos and Wn_dos each give the pixels they have, the
  overlap at the same client coordinates; a pixel neither has keeps M_dos's previous one; DOS black only in a new
  M_dos.  `dos_port_size` still counts.  Wn_dos is the DOS rule set's shadow of the window, not the screen: the XOR
  band never reaches it, so M_dos needs no band rule.
* Nothing else changes: the layer, its clip, the geometry, centring and follow (MZI), the World Map's rectangle (MZW),
  the core, the saves and P0 (M and M_dos are presentation memory; nothing is written to the emulation).  At the
  default layout (sizes equal, no band) M and M_dos are filled exactly as before.

## What was built

| File | Change |
|---|---|
| `present/map/pmap_inview.c` | header (MZS paragraph); `copy_less_band`, `fill_m` (the overlap, the kept pixels, the band), `refill` (the bitmap query), M black at allocation; test seam `pmap_test_refill` |
| `present/map/pmap_dos.c` | header (MZS paragraph); `md_fill` (the overlaps, the kept pixels) out of `pmap_dos_inview_present`; test seam `pmap_test_dos_fill` |
| `present/map/pmap_int.h` | the two test seams' declarations (CIV_OBSERVER only); `n_dos_port_size`'s comment |
| `tests/test_map.c` | `mzs_sources` (33 checks) |
| `tests/harness/ext_zoom.py` | extension MZS's four runs and their frame check (docstring paragraph, `mzs_*`, main) |
| `docs/ext-MZS-record.md` | this record |

No build.cmd or test.cmd change (ext_zoom.py already runs in test.cmd's `ext_zoom` section, Checked): no
`BUILD-TEST-ADDITIONS.md`.  No new file under `present/`, `platform/` or `core/`; no observer probe, no new SSSS:OOOO
address; DOS-PROFILE.md unchanged.

## Tests

* **test_map `mzs_sources`** (33 checks, through the seams, the user's geometry: client 453 x 421 at 168,40 on a
  640 x 480 screen, the map pattern never black):
  - M with a 454 x 421 bitmap under the Advisors menu (frame and shadow 300,40..520,160): every covered pixel the
    bitmap's at the same coordinates, every visible one the screen's, none black, `port_size` 1;
  - a 452 x 420 bitmap under a popup at the client's bottom-right corner: its overlap; the covered pixels beyond it
    keep M's previous ones;
  - no bitmap under a dialog: the covered pixels kept;
  - the outline's band (250,100..450,260, 3 wide, XOR on the screen) over a fully visible client: its pixels the
    port's, the rest the screen's; without a bitmap the band's pixels kept;
  - the Windows layer at -1 and +1, 1920 x 1440 (k 3), with the menu, then a dialog (250,150..560,380), open and after
    they close: every in-view pixel of the layer's image is the map's, none black (before the fix the covered pixels
    were black);
  - M_dos with a 454 x 421 P_dos and a 453 x 421 Wn_dos under the menu; with a Wn_dos one column narrower (P_dos
    there); a 452 x 420 P_dos at the corner (its overlap, the rest kept); a new M_dos without P_dos (DOS black only
    where it never had a pixel);
  - the DOS layer at -1 and +1 with the menu, then the dialog, open and after they close: the same.
* **ext_zoom.py, extension MZS** (test.cmd's `ext_zoom` section, the three-step cycle's step 2; the orchestrator's
  requirement): four runs, `--fit-layout 1` (civ64's layout), MZTEST.SAV (MZI's `mzi_save`), 1920x1440, `--zoom -1`
  and `--zoom +1`, the Windows graphics and the DOS graphics from the start, `--dump-presented`:
  - the Advisors menu: Alt+A at 25,600 ms, Escape twice from 26,800 ms;
  - Find City (dialog 131): Ctrl+F at 28,000 ms, closed at 29,200 ms by a click on its Cancel button (422,364:
    Escape does not close that list dialog in the harness; the same in the tree's `p49-findcity`, whose comment says
    "Escape closes it" but whose events show it open to the run's end: an observation outside MZS);
  - samples, each the last zoomed view (`view-N.bmp`) in its window: menu 25,900..26,800 ms, menu-closed
    27,300..28,000, dialog 28,000..29,200 (a modal dialog stops the map's animation: this is the view that drew it),
    dialog-closed 29,500..30,500;
  - the check: no 32 x 32 host-pixel square inside the layer (presentation-diag.log `layer`) of black pixels that no
    view of 24,600..25,600 ms (before the menu) shows black.  The defect's block is such a square; the menu's shadow
    (6 host pixels wide), text, frames, the blinking unit and the ocean's twinkles are not (the map keeps changing
    while the menu is open, so the frames cannot be compared for equality);
  - also: the popup event and dialog 83 in their windows, each open sample at or after its event, a `windows` event
    after the click on Cancel (the dialog closed), the map client 168,40 453 x 421, the level, the dos runs started in
    the DOS graphics.  One `ZOOM mzs` line per run; the dumps are deleted (a failed run keeps its failing samples and
    the last view before the menu).  Cost: about 2 minutes wall for the four runs with 4 jobs (2 min 4 s with the tree's
    harness; inside the section's pool of 8 they run beside the soak, which stays the critical path); while running each
    Windows run writes about 0.9 GB of dumps (528 core frames of 0.9 MB and 45 views of 8.3 MB) and each DOS run about
    0.4 GB, deleted by the check (about 30 MB stay for the four).
  - At -1 a dialog in the middle of the window covers its own half-size image (the defect shows nothing there): at -1
    the menu's sample catches the defect, at +1 both the menu's and the dialog's.

## Results (private, `build/mzs-stage/obj/`)

All in `build/mzs-stage/obj/` (the overlay `obj/src`: the tree after MZI + the 5 staged sources, built by
`b.cmd`; the harness copy `exe/mzs-harness.exe`; the defect: `exe/tree-harness.exe`, a Checked harness of the tree
before MZS).

* **Builds** (build.cmd's own steps and flags on the overlay): Checked, CheckedNoObs and Release BUILD_OK (portable
  sources checked 294: c11, c17, the C99 parse and clang-tidy).  `cc.cmd` (the strict checks per file) on the three
  changed C files: CC_OK in Checked, CheckedNoObs and Release.  Release `civ64.exe` SHA-256 fa2ae0d10271728e...
* **Unit tests** (`ut.sh`: every test_*.exe but test_ne): Checked failed 0 (`test_map` PASS 338 checks: 305 after MZI
  + 33 `mzs_sources`); CheckedNoObs failed 0 (`test_map` 1 check); Release failed 0 (`test_map` PASS 338 checks;
  the 47 tests but test_ne).
* **The unit test against the defect** (`mutate.py`: the two sources with the tree's fill logic before MZS, relinked
  with the Checked objects): `test_map` FAIL, 16 of the 33 MZS checks: M under the menu (26,400 pixels black), the
  smaller bitmap, no bitmap and the band; M_dos under the menu, the narrower Wn_dos and the corner; and every
  layer-open check (-1 menu 59,400 black in-view pixels, -1 dialog 160,425, +1 menu 112,050, +1 dialog 1,675,647,
  the same in the DOS layer).  With the fix: PASS.
* **The cycle check against the defect** (`zoomrun.py`: the staged ext_zoom.py through the overlay, `--only mzs`):
  - the tree's harness (the defect): `ZOOM_FAILED=4`: -1 win and -1 dos `menu (view-00023.bmp, 26749 ms): a new black
    32 x 32 square at host 1058,477`; +1 win and +1 dos the menu at host 672,120 and the dialog (view-00035.bmp,
    28067 ms) at host 504,120 (`zr-tree/ext-zoom.txt`);
  - the fixed harness: four `ZOOM mzs ok` lines (45 views each, 8 before the menu; samples view-00023, -00032, -00035,
    -00045), `ZOOM_OK ... mzs runs 4` (`zr-fix/ext-zoom.txt`).
* **The whole ext_zoom.py with the fixed harness** (`zr-full/`, 8 jobs, 23 min 20 s beside the builds): `ZOOM_OK
  combinations 32 runs 108 samples 628 map comparisons 32 centre runs 4 mzi runs 12 mzs runs 4`; every line but the
  four `ZOOM mzs` lines equals MZI's cycle output `build/test/Checked/ext-zoom.txt` (22:08 UTC): the 628 golden samples
  match the unchanged golden; the MZ, MZW and MZI lines are the same.
* **Static checks on the overlay**: `obs_lint.py` OBS_LINT_OK files 120 probes 203 callsites 98 (unchanged);
  `nodos.py check --variant Checked` (the tree's DOS and Windows copies, `--root` the overlay, this record in it)
  NODOS_OK.  registry.py and obs_tables.py read only what MZS does not touch (the registry, DOS-PROFILE.md; no new
  probe or address).
* **Harness views** (`shots/`): fixed `fx-w-m1-v29.png`, `fx-w-p1-v29.png`, `fx-d-m1-v29.png`, `fx-d-p1-v29.png` (the
  Advisors menu open at -1 and +1, both graphics: the menu and its 2-pixel shadow, the map whole around them); the drag
  at -1: `w-drag-v73.png` (tree: the ghost) and `fx-drag-w-v73.png` (fixed: none); the DOS graphics
  `tr-drag-d-v67.png` and `fx-drag-d-v67.png` (no ghost before or after: Wn_dos never holds the XOR band).
* **civ64 itself** (`uidrive.py`: the visible civ64.exe with a private home and data copy, MZTEST.SAV; captures of
  civ64's own window only, `ui/<tag>/shots`, half-size PNGs in `shots/ui-*`; the user's `%LOCALAPPDATA%` civ64 files
  hashed before and after: unchanged in every run).  User build mzw (before): the File menu at -1
  (`ui-mzw-file-half.png`: the block below the menu), Find City at +1 (`ui-mzw-win-p1-d-dialog.png`: black to the left
  of and above the dialog), the drag at -1 (`ui-mzw-drag-h2.png`, `ui-mzw-win-m1-f-drag.png`: the outline and its
  ghost inside it).  The fixed Release build (`uiexe/mzs/civ64.exe`, the steps `steps-fx3-win-*.txt`,
  `steps-fx-dos-*.txt`, `steps-drag.txt`): `ui-mzs-<win|dos>-<m1|p1>-b-menu.png` (the Advisors menu),
  `-d-dialog.png` (Find City), `-g-dropped.png` (the World Map dropped on the main map) and `ui-mzs-drag-h2.png` (the
  drag at -1: the outline only): no black block, no ghost, the map whole, in both graphics at -1 and +1.  Not an MZS
  matter, noted for the tools: in about half of the launches civ64 took no posted input at all (the intro not skipped,
  the title's clicks ignored), with the mzw build as with the mzs build; those runs were repeated.

## Expected changes at the build slot

Predictions for the cycle (the tree after MZI; "before" = `build/test/Checked` of MZI's cycle):

* `sections/unit.log` (Checked): `test_map: PASS (338 checks, 0 failures)` (305 before); the `test_map` cost lines
  (host time) vary.  CheckedNoObs `test_map` 1 check, unchanged.
* `ext-zoom.txt`: four new lines after the `ZOOM mzi` lines, in this order:
  `ZOOM mzs ok -1 win map [168, 40, 453, 421] layer [504, 120, 1863, 1383]: 45 views, before the menu 8; menu
  view-00023, menu-closed view-00032, dialog view-00035, dialog-closed view-00045`, then the same for `-1 dos`,
  `+1 win`, `+1 dos`; the last line `ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32 centre runs 4 mzi
  runs 12 mzs runs 4`.  Every other line unchanged; `tests/harness/ext-zoom-golden.txt` unchanged (MZS writes no
  golden).  The section's time a little longer at most (the four runs beside the soak); while it runs up to about
  2.6 GB of dumps under `build/harness/Checked/zoom/mzs-*/dump`, deleted by the check.
* `nodos.txt` and `sections/nodos.log`: one file more (this record), 0 hits.
* Every other output unchanged: ext_p0 (P0_OK, V4's shows with the layer), ext_adapt, ext_mirror, ext_frames,
  ext_timeline, ext_continue, ext_aspect, ext_slots, ext_bs, ext_replay, p4tests, obs-lint (files 120), obs-tables,
  registry, coverage (its informational lines may move), and ext_g1 (EXT_G1_OK runs 77, amended 1).  Why: M and M_dos
  are filled exactly as before wherever the port bitmap (P_dos, Wn_dos) has the client's size and no move outline is
  shown; in the tree's 638 presentation-diag logs `port_size` and `dos_port_size` are 0 except `p49-prf-fit` and
  `p49-prf-game` (port_size 44, at level 0, where M feeds no checked output; the counter counts the same presents as
  before), and no cycle script moves or sizes a window.
* Release: BUILD_OK; the Release unit tests as Checked's for test_map's count.  No build.cmd or test.cmd change; G-1
  unamended.

## Rebase notes

* **MZI** (landed 21:29 UTC, ALL_GREEN 22:08:45 UTC): the bases are MZI's landed copies (checked against the tree at
  about 22:15 UTC: all five OK).
* **D6f** (staged, `build/d6f-stage`; its bases are before MZI): `pmap_dos.c`: D6f adds `#include "dos/pdos_reskin.h"`
  and `pmap_dos_cover` after `pmap_dos_frame_ok`; MZS adds a header paragraph (after the D6d paragraph), moves
  `pmap_dos_inview_present`'s row loop into `md_fill` just above it and adds `pmap_test_dos_fill` after
  `pmap_test_dos`: different places, apply both.  `pmap_int.h`: D6f adds `PMAP_COVER_MAX` and `pmap_dos_cover`'s
  declaration just before the `#if CIV_OBSERVER` test-seam block, where MZS adds its two seams (after
  `pmap_test_world_dos`) and changes `n_dos_port_size`'s comment: adjacent, not overlapping; keep both.  After D6f the
  DOS graphics' menus are DOS boxes on the A canvas, which the layer no longer covers; the core's popup and dialog
  events stay and M_dos's covered pixels are still the core popup's, so the MZS check should hold; whoever lands
  second re-runs `ext_zoom.py --only mzs` (a DOS box with a solid black area of 32 x 32 host pixels or more would be
  flagged; none is known).
* **D6e** (staged; its `ext_zoom.py` is based before MZI): D6e changes the docstring (a D6e paragraph), `profiles()`
  (`smmap`) and `compare_maps`; MZS adds a docstring paragraph after MZI's, `import struct`, its section after MZI's and
  four hooks in `main()`: different places, apply both.  No golden change from MZS.
* **SI** (`win64/civ64_main.c`, `civ64_start.*`, `drive_civ64.py`) and **TLD** (`host_win32.c`, `host.h`, `gdi_pal.c`,
  `commdlg.c`, `test.cmd`, `host_headless.c`): no file in common with MZS.  TLD changes test.cmd; MZS does not.  UX5
  landed before MZI (no common file).

## Build-slot steps

1. Base re-check: each tree file equals its `BASE-SHA256.txt` hash (MZI's landed copies and the tree's `pmap_dos.c`);
   test.cmd and build.cmd unchanged by MZS.  A changed base: rebase as in "Rebase notes", rebuild privately, re-run
   test_map and `ext_zoom.py --only mzs`.
2. Snapshot `build/test/Checked` to `build/mzs-prep/before`; copy the 6 staged files in; `build/mzs-prep/landed.sha256`.
3. Predictions (this record's "Expected changes") written before the cycle; build.cmd checked, test.cmd checked,
   `tests/harness/ext_g1.py check`, status in `build/mzs-status.txt`; comparison after.
4. Release build (RELEASE_OK); user build `build/user-builds/mzs/` (civ64.exe, CIVWIN.zip and civdos.zip from
   `user-builds/d4`, WHAT-TO-CHECK.txt with "Still open" from the checklist's pending rows at landing time).
5. A "Landing" section here.

## What the user checks

In the Windows graphics and in the DOS graphics (switch with Ctrl+Shift+Backspace or the system menu).  Load a game,
for example your **MZTEST.SAV** (File, Load).  Zoom out (-1): Ctrl+Shift+Minus, the wheel over the map, or "Zoom out
(half)" in the window's system menu; zoom in (+1): Ctrl+Shift+Plus or "Zoom in (double)"; back to normal: Ctrl+Shift+0.

* **MZS-1** (your report, -1) At -1, open each menu of the menu bar in turn (File, Orders, Advisors, World, ...): the
  menu is drawn with its thin shadow exactly as at the normal zoom, and the map around it stays as it was: no black
  block below it, beside it or to its left.  Close the menu (Escape, or a click outside it): the map is intact.
* **MZS-2** (your report, +1) The same at +1: no black block to the left of or above the menu; after it closes, the map
  is intact.
* **MZS-3** (dialogs) At -1 and at +1, open File > Find City... (Ctrl+F) and close it with Cancel; also open File > Tax
  Rate (Ctrl+T) and close it: around the dialog the map stays as it was (no black area), and after it closes the map is
  intact.
* **MZS-4** (moving a window) At -1, drag the World Map window (or the Status window) by its title bar across the main
  map and drop it there: while you drag, only the moving outline is drawn, with no second, smaller outline inside the
  map; after the drop the window and the map are drawn normally.  Drag it back.  The same at +1.
* **MZS-5** (both graphics) MZS-1..MZS-4 in the DOS graphics: the same results.
* **MZS-6** (normal zoom unchanged) At the normal zoom (0) menus, dialogs and dragged windows behave exactly as before.

**MZW-8 again** (failed in build mzw; MZS fixes the cause): at -1, open a menu or a dialog over the World Map, or move a
window across it: they are drawn normally over the World Map; when they go, the World Map and its rectangle are
intact.  Re-check it in build `build/user-builds/mzs/`, in both graphics, after MZS-1..MZS-4 (the black block you
reported was over the main map; MZW-8's own World Map part is checked again here).

## For the records

* **draft D** (`docs/verify/ext-d1-draft-D.md`): 6.1 "Sizes": "`M` is reallocated when the client size changes (black
  where it never had a pixel) and refilled whole at the next present.  A port bitmap of another size than the client
  gives the covered pixels it has, the overlap at the same client coordinates (as WdwMapProc's WM_PAINT 1208:0332
  copies it; BitBlt copies no pixel outside the bitmap); a covered pixel it does not have, or every one without a
  bitmap, keeps M's previous pixel (`map_port_size` counts those presents).  With civ64's layout the bitmap is
  454 x 421 for a 453 x 421 client (extension MZS; before, those pixels were black and the layer drew a black block
  beside open menus and dialogs at -1 and +1, the user's MZW-8)."  6.1, a new bullet **Move outline**: "The move or
  size outline's XOR band (`user_syscmd.c` `outline()`, 3 pixels) is drawn on the screen and is not among the visible
  region's exclusions; M takes its pixels as covered ones (the port's), so the layer shows no ghost of the outline
  (MZS); the layer's clip leaves the band itself out (5.2)."  6.2's "Implemented in D6d" paragraph: "DOS 0 where a
  shadow is missing or of another size" becomes "each shadow's pixels where it has them (the overlap at the same
  client coordinates), M_dos's previous pixel where neither has one, DOS 0 only where M_dos never had one
  (`dos_port_size` counts the presents with a size that differs; MZS); Wn_dos never holds the outline's XOR band".
* **DESIGN.md** 12.9 (the in-view source M and "As implemented (D6d; area D)"): the same two rules (the overlap and
  the kept pixels for M and M_dos; the outline's band taken as covered in M).
* **RUNNING.md**: the `test_map` row, after MZI's count: "Since MZS also `mzs_sources` (M and M_dos with a port
  bitmap or shadows of another size, without one, and the move outline's band; the layer at -1 and +1 with a menu or a
  dialog open and after it closes, both profiles): 338 checks in Checked and Release, 1 in `checked noobs`"; the
  `ext_zoom.py` row: "Since MZS also four runs with civ64's layout (`--fit-layout 1`; MZTEST.SAV; -1 and +1, the
  Windows and the DOS graphics): the Advisors menu and Find City opened and closed, each sample free of a new solid
  black 32 x 32 square in the layer (one `ZOOM mzs ok` line each): `... mzi runs 12 mzs runs 4`".
* **FIDELITY.md**, a new entry (the orchestrator numbers it): | F? | the zoom layer under menus, dialogs and the move
  outline (`present/map/pmap_inview.c` `fill_m`, `copy_less_band`; `present/map/pmap_dos.c` `md_fill`; draft D 6.1,
  6.2 "Sizes") | The original has no zoom.  WdwMapProc's WM_PAINT 1208:0332 repaints the map client from the map
  port's bitmap (12D8:455C) at the same coordinates; BitBlt copies no source pixel outside the bitmap; with civ64's
  layout (F103) the bitmap is 454 x 421 for a 453 x 421 client | At -1 and +1 the layer's in-view pixels under a menu,
  drop-down, dialog or moved window come from the port's bitmap at the same coordinates where it has them, otherwise
  keep the last pixel shown (black only where none was ever seen); the move or size outline's band is taken from the
  port, so the layer shows no copy of it; the DOS graphics the same from P_dos and Wn_dos.  Menus, dialogs and moved
  windows then look over the zoomed map as at level 0 (**choice**, modelled on WM_PAINT; the orchestrator's ruling on
  the user's MZW-8, 2026-10-16).  Before MZS the covered pixels were black when the bitmap's size differed, so with
  civ64's layout a black block appeared beside every open menu or dialog at -1 and +1 (since M in the Windows graphics,
  since D6d in the DOS graphics; the harness's default layout, whose bitmap has the client's size, hid it), and
  dragging a window at -1 showed a half-size ghost of its outline.  Presentation only, P0.  Status: implemented in MZS;
  tests `test_map` `mzs_sources` (305 -> 338), `ext_zoom.py`'s MZS runs (`--fit-layout 1`, -1 and +1, both graphics,
  a menu and a dialog); user checks MZS-1..MZS-6 and MZW-8 again pending (build `build/user-builds/mzs/`) |
  `ext-MZS-record.md`; F185; F103 |.  And in F185's MZW part: "user check MZW-8 failed 2026-10-16 about 20:16 UTC (a
  black block beside menus at -1 and +1 over the main map: unit MZS)".
* **manual-checklist-ext.md**: MZW-8's row: "comes with MZS (menus over the zoomed map); no user build yet" becomes
  "MZS (landed ...); check again in build `build/user-builds/mzs/`"; a new section MZS with MZS-1..MZS-6 (above, in the
  user's words), build `build/user-builds/mzs/`; the pending counts.
* **STATUS.md**: unit MZS READY (staged 2026-10-16), then landed by the build slot: the zoom layer's covered pixels from
  the port bitmap (MZW-8's black block), the move outline's ghost removed; the check in the cycle with civ64's layout
  (the orchestrator's requirement).  An observation for the base track, not MZS's: in the harness Escape does not close
  Find City (dialog 131, RunListBoxDialog 1098:1909); `p49-findcity`'s comment says it does, but its events show the
  dialog open to the run's end.

## Landing (2026-10-16/17, build slot)

**Landed 2026-10-16 23:47:40 UTC; cycle ALL_GREEN 2026-10-17 00:25:05 UTC; RELEASE_OK 00:30:32 UTC; user build
`build/user-builds/mzs/` (about 00:31 UTC).**  Done by the build slot on the orchestrator's instruction, after SI's
landing (RELEASE_OK 23:45:07 UTC).

1. **Bases.** `build/mzs-prep/land.py` (6 rows): the 5 tree files still had their bases
   (`build/mzs-stage/BASE-SHA256.txt`, MZI's landed copies), this record was absent, and the 6 staged copies (LF) had
   the SHA-256 frozen in `build/mzs-prep/staged.sha256`; build.cmd (40de571d...) and test.cmd (e7c5015c..., after
   UX5) unchanged.  Dry run `DRY_RUN_OK 6`.  No rebase was needed: SI (`win64/civ64_main.c`, `civ64_start.*`,
   `tests/win32/test_single.c`, `drive_civ64.py`) shares no file with MZS; D6f and D6e are not landed yet (their
   overlaps: "Rebase notes").
2. **Snapshot and copy.** Before writing: the tree's Checked test outputs (59 files of `build/test/Checked`, SI's
   cycle) in `build/mzs-prep/before`, the tree's previous 5 files in `build/mzs-prep/tree-before`.  The 6 files byte
   for byte (5 changed, this record new): `LANDED 6`; manifest `build/mzs-prep/landed.sha256` (with build.cmd's and
   test.cmd's unchanged SHA-256); `landed-at.txt`.  No build.cmd or test.cmd change.
3. **Cycle** (`build/mzs-prep/mzs-cycle.ps1`; status `build/mzs-status.txt`, logs `build/mzs-<n>-<step>.log`):
   - 1 build-checked: exit 0, 307 s, BUILD_OK; portable sources checked 294; no warning.
   - 2 test-checked: exit 0, 1927 s, TESTS_OK, 27 sections, failed 0 (wall 1923.3 s).  `w32_test_host_win32` passed
     at the first run (395 checks): no GetKeyState rerun and no -r2 test step were needed.
   - 3 g1-checked: exit 0, EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events): **ALL_GREEN**.
   - 4 build-release: exit 0, 317 s, BUILD_OK: **RELEASE_OK**.
4. **Comparison** (`build/mzs-prep/compare.py`, output `compare.txt`; the predictions in
   `build/mzs-prep/predictions.txt` were written about 23:47 UTC, before the copy-in; prediction against output in
   `build/mzs-prep/comparison.txt`): 52 of 59 files equal (lines with times left out).  The differences, all as
   predicted:
   - `sections/unit.log`: `test_map` 305 -> 338 checks, 0 failures; the OBS_COST line (host time).
   - `ext-zoom.txt`: the four `ZOOM mzs ok` lines (-1 win, -1 dos, +1 win, +1 dos: map 168,40 453 x 421, layer
     504,120..1863,1383, 45 views, 8 before the menu, samples view-00023, -00032, -00035, -00045) and
     `ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32 centre runs 4 mzi runs 12 mzs runs 4`; every
     other line equal (the combination lines' show counts, MZ's and MZI's lines, the golden's 628 samples).
     `sections/ext_zoom.log`: the ZOOM_OK line.  The orchestrator's requirement holds: the check runs in test.cmd's
     `ext_zoom` section with civ64's layout (`--fit-layout 1`), a menu and a dialog at -1 and +1, both graphics.
   - `nodos.txt`: 1736 -> 1737 files (this record), 0 hits.
   - `coverage.txt` and `sections/coverage.log`: "other functions entered" 669 -> 667 (informational).
   - `sections/times.txt`: section times.
   Every other output equal: P0_OK, EXT_ADAPT_OK checks 154, OBS_LINT_OK, REGISTRY_OK, OBS_TABLES_OK, ADAPT_OK,
   EXT_ASPECT_OK, MIRROR_OK, REPLAY_OK, EXT_FRAMES_OK, EXT_TIMELINE_OK, EXT_CONTINUE_OK, EXT_SLOTS_OK, EXT_BS_OK,
   TRACE_OK and the other sections.
5. **User build** `build/user-builds/mzs/` (`build/mzs-prep/mk_userbuild.py`, `USER_BUILD_OK 4`): `civ64.exe` (the
   Release build, SHA-256 6db5363e...a9cc325f, 4,342,784 bytes), `CIVWIN.zip` and `civdos.zip` (byte-identical copies
   from `user-builds/d4`, SHA-256 058d4e00... and 0eac32c9... checked) and `WHAT-TO-CHECK.txt` (SHA-256 37797930...,
   CRLF, ASCII): MZS-1..MZS-6 and MZW-8 again in plain words as in "What the user checks", where MZTEST.SAV is, the zoom
   keys, the builds it contains (si, mzi, ux5, mzw, mz, ux4b, d5p, ux4, d6d, sl and the earlier ones), the note that it
   runs only once at a time (SI), and the items still open from the checklist's pending rows at 00:30 UTC: SI-1..SI-6,
   MZI-1..MZI-7, UX5-1..UX5-7, D5P-7 and P47-1 checkable; D6-1 and D5-7 with unit D6f.
6. **Not done here**: the checklist's MZS section and MZW-8's row (the orchestrator), the FIDELITY entry's number and
   the other entries of "For the records" (the next joint docs pass).

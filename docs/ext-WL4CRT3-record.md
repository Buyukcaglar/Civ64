# Extension units WL4 and CRT3 (the Windows menu skin in windowless play; the double-scanned CRT scanlines) - record

## Result

* **WL4** In windowless play with the Windows graphics, the menu bar across the top of the canvas is the Status
  window's gray instead of white, and the menus that drop from it have the Status window's background texture (the
  stone tile the Status panel shows around its boxes) instead of white. Text, gray (unavailable) items, borders,
  shadows, separators and the blue highlight with its white text are unchanged. The DOS graphics and the windowed
  game are unchanged.
* **CRT3** "CRT scanlines" now draws the DOS graphics as DOSBox Pure Unleashed does with "Aspect Ratio Correction:
  On (double-scan when applicable)": two scanlines per DOS row (400 for the 320 x 200 picture), so the dark gaps are
  twice as many and half as thick. The Windows graphics keep one scanline per Windows row (their 480-line mode is not
  double-scanned). CRT2's speed and sharpness are unchanged.

## Status

Staged and landed together as unit "wl4crt3" (see "Landing"); user checks WL4-1..WL4-3 and CRT3-1..CRT3-2 pending
(build `build/user-builds/wl4crt3/`).

## The user's words

2026-10-20 (verbatim, through the orchestrator): "Two revisions before IWC; 1. in Windowless play mode, for Windows
graphics, change top menu bg color to game's popup or status windows gray color, and for the actual menus of the top
menu bar, put status window bg pattern/image to those menus 2. Latest implementation of Dosbox Pure Unleashed CRT
scanlines filter is visually accepted, but the scanlines themselves seems to be thicker than the DosBox Pure Unleashed
configuration I used. This is probably due to I forgot to mention that I'm using Setting -> Video -> Aspect Ratio
Correction -> On (double-scan when applicable) option. Investigate and update accordingly. Provide a single user
testable build for these two revisions, after I test them I'll direct you to update github later manually."

## WL4: design (present/wl.c, wl.h)

* **What the Status window shows** (port source, = the binary's listing): RedrawStatusWindow 1218:0842..0891 tiles
  the whole Status back port with `TileShapeInPort(port, bounds, g_wholeTileShapes[9])` (TileShapeInPort 10D0:0BEE:
  rows of `DrawTileOpaque` from the port's top-left, the tile's width and height from its TileBlock); its unit panel is
  `DrawSunkenPanel(rect, g_uiColors[13])` 1218:08B7 (a FillRect with the brush of that palette index, 11F8:028B..02AB,
  white and dark pens around it). The TileBlock (`OF_TileBlock_width` 0, `height` 2, `pixels` 4) holds the rows of
  palette indices; the port bitmap, its copy to the window and w16's screen keep those indices (w16's BitBlt does no
  colour translation), and the Windows frame is the screen through the system palette (`pwin_core`), so the system
  palette gives exactly the colours the Status window shows (inferred from the port's code; the harness view below
  shows the popup's texture matching the Status panel's margins).
* **`read_skin`** (Windows graphics only, inside the observer's guard, read-only queries): `skin_gray` = the system
  palette's colour of `g_uiColors[13]` (12D8:45FB; 0xC0C0C0 if unreadable); the tile = `g_wholeTileShapes[9]`
  (1420:98C0) through `w16q_block`/`w16q_read`, at most 64 x 64 (else no tile: the popups get the gray). A changed
  gray or tile composes the whole canvas again (`take`).
* **`skin`** in `compose`: after the bar piece (with its last column repeated across the canvas, F337), each bar row's
  runs of white frame pixels become `skin_gray`; after each menu popup float (`PwlFloat.menu`: the popup's rectangle
  without its shadow, `W16qMenu.lv[].frame`), its white runs become the tile, its origin the popup's top-left. A white
  run whose two neighbours in the row are both the highlight colour (0, 0, 128) is a highlighted title's or item's
  text and stays white. A canvas pixel is changed only where it still shows that white (hidden parts are black). The
  decision reads the frame only, so a damaged part composes exactly as the whole canvas (`pwl_check`, the harness's
  `wl ... mismatches` stay 0).
* Unchanged: the arrangement, the pieces, the floats' places, the input (pwl_point), the DOS graphics (no skin), the
  windowed game, the game's own screen (P0: presentation only, no core call, no RNG).

## CRT3: the DOSBox finding (read-only source reading, codeberg schelling/dosbox-pure and dosbox-pure-unleashed)

* DOSBox Pure's core option `dosbox_pure_aspect_correction` ("Aspect Ratio Correction") has the values "Off
  (default)", "On (single-scan)", "On (double-scan when applicable)" (`doublescan`), and padded variants
  (`core_options.h`). `doublescan` sets `dbp_doublescan` (dosbox_pure_libretro.cpp, the option's apply).
* `GFX_StartUpdate`: with `dbp_doublescan` the output buffer is `width << render.src.dblw` by
  `height << render.src.dblh`; `GFX_EndUpdate`: with `render.aspect` and `dbp_doublescan`, each source line is
  written twice (`trg[0] = trg[pitch]`). `render.src.dblh` is DOSBox's VGA scan doubling: the 200- (and 240-) line
  modes, among them DOS Civilization's 320 x 200; 350-, 400- and 480-line modes are not doubled.
* DOSBox Pure Unleashed (main.cpp): the CRT shader's `InputSize` uniforms are the core frame's size
  (`srfCore` scaled to the frame's width and height in `retro_video_refresh_cb`), and the shader's scanline is one
  input row (`y0 = floor(pos.y - 0.5) + 0.5` in input rows). With double-scan the input is 400 rows: 400 scanlines
  over the DOS picture, each half a DOS row high; without it, 200 (civ64's CRT and CRT2).
* So civ64's DOS graphics take two scanlines per DOS row; the Windows graphics' screen is Windows 3.1's 640 x 480
  mode (480 lines, not double-scanned by VGA, `dblh` 0): one scanline per row, as before (the same rule; a mode below
  350 lines would be doubled).

## CRT3: design (present/crt.c, crt.h, present.c)

* `present_crt_scanlines(rows, mode_lines)`: `mode_lines < 350 ? 2 * rows : rows`. `crt_sync` passes the DOS A
  frame's 200 rows as its own mode (400 scanlines) and the Windows frame with Windows 3.1's 480 lines (its rows).
* Everything else is CRT2's: the per-row weight own + neighbour of the shader at T = 0.65, the tonal curve, the
  256 x 256 factor table, no resampling, no reach. With twice as many scanlines over the same image rows, each
  scanline covers half as many host rows: at the 4:3 full-screen 1920 x 1080 picture about 2.7 host rows a scanline
  (the gap one or two host rows) instead of about 5.4.
* `present_crt_rows()` (tests): the scanlines of the frame now shown.

## Deviations

1. **WL4, the colours are chosen by the user's words**: the bar's gray is the Status window's sunken-panel gray
   (the game's own "popup/status" gray), the popups' texture is the Status window's background tile at its own size
   (not stretched), aligned to each popup's top-left (the Status window aligns it to its own top-left).
2. **WL4, the highlight test is by colour**: a white run between two highlight pixels in the same row stays white.
   W16 draws a highlighted title or item as one highlight rectangle with white text, so this keeps exactly that text;
   other whites (the background, the separators' rows) are skinned.
3. **CRT3, the line count rule** (below 350 lines doubled) follows VGA's and DOSBox's scan doubling; civ64 has only
   the two cases (DOS 200 lines, Windows 480 lines).
4. **CRT3, small pictures**: at a scale of under two host rows per DOS row (a window smaller than 400 pixels high)
   the 400 scanlines are finer than the host rows; the weights still follow each host row's place (no moire control).

## Tests

* `tests/test_crt.c` (21 -> 25 checks): `doublescan()` - the 200- and 240-line modes give 400 and 480 scanlines, the
  350-, 400- and 480-line modes their rows; a 320 x 200 picture at 4:3 fit in 3840 x 2160 has 399 gaps between its 400
  scanlines (199 with one per row); `option()` - the Windows screen's scanlines through the presentation are 480;
  the timing check now filters the DOS grid of 400 scanlines (overlay: 10.2 ms, bound 120). The golden of the 5 x 5
  pattern is unchanged (`present_crt_set` unchanged). Fails on the base: `present_crt_scanlines` and
  `present_crt_rows` do not exist there (no build); the gap count with the base's grid is 199.
* `tests/test_wl.c` (93 -> 101 checks): `wl4()` - a scene with the skin, a bar with text and a highlighted title, a
  popup with a border, a highlighted item, gray and black text and a shadow: the bar's white is the gray across the
  canvas (the repeated columns too), the highlighted title's white text stays; the popup's white is the tile from its
  top-left; the highlight's text, the gray/black text, the border and the shadow kept; `pwl_check` 0; the highlight
  moved by a damaged part (the old item's white text becomes the tile, the new one's stays, `pwl_check` 0); without
  the skin the white stays (the DOS graphics; the base's behaviour, where these checks fail).
* Harness view (not a test): the overlay's Checked harness with ext_wl's wl-win host input cut at 56,200 ms (the Help
  popup open), `--windowless 1 --dump-presented`: the canvas showed the gray bar, the textured Help popup with "Game
  Help" highlighted, `wl shows 70 ... mismatches 0` (`build/wl4crt3-stage/obj/vis/last.png`, `popup-zoom.png`).

## For the records

* FIDELITY: F341 (WL4, amending F337), F342 (CRT3, amending F335 and F329's one gap per row) - applied in this unit.
* DESIGN: the WL section (the skin over the bar and popups) and the CRT section (the scanline count) - left to the
  docs pass.
* RUNNING, FEATURES: nothing new (no option, no switch).

## What the user checks

* **WL4-1** Windows graphics (Ctrl+Shift+Backspace switches), Display > Windowless play on, in a game: the menu bar
  across the top is gray (the same gray as the Status panel's unit box on the left) instead of white; its titles are
  black and readable; a title you open is still blue with white letters.
* **WL4-2** Open each menu of the bar (File .. Help): the menu's background is the Status window's stone texture (the
  pattern you see around the Status panel's boxes); the items' letters, the gray (unavailable) items, the separator
  lines, the black border and the shadow are as before, and the highlighted item is still blue with white letters as
  you move over the items; nothing flickers or leaves white bits behind.
* **WL4-3** Unchanged: Windowless play off (the windowed game keeps Windows' white menus) and the DOS graphics in
  windowless play (the DOS menu bar and drop-downs as before).
* **CRT3-1** Display > CRT scanlines on, DOS graphics (intro, title, map, city screen; windowed and full screen):
  the dark gaps between the pixel rows are twice as many and about half as thick as in build "crt2", as in DOSBox Pure
  Unleashed with Aspect Ratio Correction "On (double-scan when applicable)"; the picture stays as sharp and as fast.
* **CRT3-2** CRT scanlines in the Windows graphics: as in build "crt2" (one gap per Windows row; their 640 x 480 mode
  is not double-scanned).

## Expected changes at the build slot

* test_crt 21 -> 25 checks (golden unchanged), test_wl 93 -> 101; every other count and golden unchanged (the skin is
  presentation only and applies to windowless play in the Windows graphics; the CRT option is off by default; ext_wl's
  runs check points and pwl_check, not pixels). P0 unchanged. ext_g1 runs 77 unchanged.

## Rebase notes

Bases: `BASE-SHA256.txt` (the tree's present/wl.c, wl.h, crt.c, crt.h, present.c, present.h, tests/test_crt.c,
tests/test_wl.c and docs/FIDELITY.md on 2026-10-20 after WL3, CRT2 and the docs pass). The edits were made by
`build/wl4crt3-prep/wl4_edit.py`, `wl4_test_edit.py`, `docs_edit.py` (anchored replacements) and two small Python
edits for CRT3 (recorded in `build/wl4crt3-stage/STATE.md`).

## Landing

WL4 and CRT3 landed together as unit "wl4crt3" at the build slot on 2026-10-20.

* **Bases** as staged (the tree unchanged since WL3, CRT2 and the docs pass). Private overlay (tree + the stage)
  Checked, CheckedNoObs and Release BUILD_OK; Checked and CheckedNoObs unit tests all passing (test_crt 25, timing
  10.2 ms; test_wl 101); nodos NODOS_OK, obs_lint OBS_LINT_OK, adapters ADAPT_OK, pdos_scene_check PASS, registry
  REGISTRY_OK on the tree (no present/dos file changed).
* **Copy-in** 20:56:28 UTC (`build/a43-prep/land.py wl4crt3 --write`, 8 files, LF as the tree) and docs/FIDELITY.md
  (F341, F342) after its base check (`build/wl4crt3-prep/landed.sha256`, `tree-before/`).
* **The cycle** (`build/wl4crt3-status.txt`): 1 `build.cmd checked` BUILD_OK 20:56:34..21:00:36; 2 `test.cmd checked`
  TESTS_OK 21:00:36..21:32:40 (test_crt PASS 25 checks, timing 31.5 ms under load, bound 120; test_wl PASS 101); 3
  `ext_g1.py check` EXT_G1_OK runs 77 unchanged (its standing "amended 1" note as in WL3 and CRT2): **ALL_GREEN**
  21:32:41 UTC; 4 `build.cmd` (Release) BUILD_OK 21:32:41..21:36:33: **RELEASE_OK**.
* **Against the predictions** (`build/wl4crt3-prep/predictions.txt`): as predicted.
* **User build** `build/user-builds/wl4crt3/` (WL4-1..WL4-3, CRT3-1..CRT3-2). FIDELITY F341, F342. Release civ64.exe
  5,007,872 bytes, sha256 8621ea3f...2ab22f21.

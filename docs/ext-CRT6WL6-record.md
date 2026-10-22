# Extension units CRT6 (the gameplay's scanlines on the accepted base) and WL6 (disabled menu items) - record

## Result

* **CRT6** With "CRT scanlines" on, the game now has the same scanlines as the accepted intro, title, Birth and setup
  screens on the same monitor: the same thickness, spacing and darkness on screen, in both graphics, windowed, full
  screen and in windowless play. Before, the gameplay's scanlines were finer (on the user's 2560 x 1600 monitor a gap
  every 2 screen rows where the title has one every 3, in the DOS graphics every 2 to 3.3 rows where the DOS title has
  one every 4). The accepted screens are unchanged, byte for byte.
* **WL6** In windowless play with the Windows graphics, the drop-down menus' disabled (grayed, unselectable) items are
  drawn as a checker of two dark grays, visible on the stone background and clearly different from the black enabled
  items. Before, their gray was the stones' own lighter gray, so they could not be seen.

## Status

Staged in `build/crt6wl6-stage/` and landed at the build slot in one cycle (see "Landing"); user checks CRT6-1..CRT6-5
and WL6-1..WL6-2 pending (build `build/user-builds/crt6wl6/`).

## The user's words

2026-10-22 (verbatim, through the orchestrator): "1. crt5: This time, scanlines on the gameplay is super-fine, but on
the intro/title screen & birth-*, and game setup screens they are what they shall be. Filter shell be consistent on all
screens, so note that intro/title screen & birth-* screens implementation is accepted and apply that base into
gameplay. 2. wl5: All ok. Single revision, disabled menu items are not visible, draw unselectable disabled menu items
in patterned dark gray (but shall be easily distinguished from black). Provide single build final output and user test
build for me check."

## CRT6 findings (measured)

* **The cause.** `crt_sync` (present.c) made the filter's tables from the shown frame: two scanlines per source row
  (CRT4) spaced over the rows that frame has full screen on the window's monitor (CRT5b), with CRT5's grid rule decided
  on that pair. The accepted screens are the 640 x 480 Windows screen and the 320 x 200 DOS N frame, whose full-screen
  rows are the title's. The gameplay's frames are others: the Windows game screen and the windowless canvas take the
  client's size at the game's kept scale (F105, F110, WL3), and the DOS graphics show the A frame (DOS art at 2x over
  that game screen; its DOS rows are half the game screen's rows, not 200). Their rows per screen row differ from the
  title's, so the scanlines' period and depth followed the game's scale instead of the title's: typically finer (the
  scale is kept from the window the game started in, and a larger client adds rows, not scale).
* **Measurements** (`build/crt6wl6-stage/obj/measure/measure.c`: white frames through the presentation with the
  option on, the tree's Checked objects for the base (`base.txt`) and the stage's for CRT6 (`stage.txt`); the DOS
  graphics through a stand-in profile with the A frame's input frame and `in_play`; monitors 2560 x 1600 (the
  user's), 1920 x 1080, 3840 x 2160, integer and fit; "gap" = a row darker than both neighbours, depth = 1 - darkest
  / brightest). On the user's 2560 x 1600 monitor, integer (fit in brackets):

| screen | base: a gap every .. rows, depth | CRT6 |
| --- | --- | --- |
| Windows title 640 x 480 full screen (accepted) | 3.00, 0.17 (2.50, 0.18) | unchanged |
| Windows game 1280 x 800 (game started in a 1280 x 960 window, then full screen) | 2.00, 0.20 (2.00, 0.20) | 3.00, 0.17 (2.50, 0.18) |
| Windows game 1280 x 760 in a maximized 2560 x 1520 window | 2.00, 0.20 (2.00, 0.20) | 3.00, 0.17 (2.50, 0.18) |
| Windows game 853 x 533 full screen (started in 1920 x 1440) | 3.00, 0.17 (3.00, 0.17) | 3.00, 0.17 (2.50, 0.18) |
| windowless canvas at 1.5x full screen | 2.00, 0.20 (2.00, 0.20) | 3.00, 0.17 (2.50, 0.18) |
| DOS title 320 x 200 at 4:3 full screen (accepted) | 4.01, 0.15 | unchanged |
| DOS A frame in play, 853 x 533 / 1280 x 800 full screen | 3.01 / 2.00, 0.20 | 4.01, 0.15 |
| DOS A frame in play, 640 x 480 in a 1280 x 960 window | 3.35, 0.20 | 4.02, 0.15 |

  With CRT6 every one of the 48 gameplay cases (three monitors, two policies) has exactly the title's image rows
  (the gameplay image's first rows equal the full-screen title's rows; `stage.txt`: 0 differing, base 51 lines
  differing), and every title and pre-game line is identical to the base.

## CRT6 design (present/present.c, present.h)

* `crt_base(gh, &lines, &ph)`: the accepted screens keep their own base, exactly as before: in the Windows graphics a
  frame of at most 640 x 480 (the intro, title, Birth scenes, setup screens; the Windows profile never shows a smaller
  one), in the DOS graphics every frame before play (profile.h `in_play` 0: the N frame's intro, title, Birth and setup
  screens, an A frame over the 640 x 480 layout): `lines` = two per source row, `ph` = the frame laid out full screen
  on the monitor (CRT5b, now `frame_period_rows`). Every other frame (the Windows game screen and windowless canvas
  larger than 640 x 480; every DOS frame in play: the A frame and the in-play 320 x 200 screens) takes the accepted
  screen of its graphics as the reference: Windows 640 x 480, square pixels, 960 scanlines; DOS 320 x 200 with the
  intro's 4:3 item (as the title is shown), 400 scanlines; laid out with the policy and filter full screen on the
  window's monitor (without a monitor, the headless host, in the client). `present_crt_set_period` (CRT5b, unchanged)
  then gives image row e the reference's row e weight; rows past the reference's continue its spacing (the same
  expression), and CRT5's grid rule is decided on the reference, so the period, depth and phase are the title's.
* `crt_sync` returns 1 when it made new tables; `show()` then filters the whole client from the clean image (the base
  can change with the layout unchanged, at the DOS graphics' start of play with the gameplay aspect item off).
  `present_crt_period_rows()` gives the base's rows (tests). `present_set_screen`, the apply loop, crt.c and crt.h,
  the weights, the tonal curve and the speed are unchanged.
* P0: presentation only; no core call, no RNG draw, no `w16_present` added, removed or delayed.

## WL6 design (present/wl.c `skin`)

* w16 draws a grayed menu item's text, accelerator and tick in (128, 128, 128) (`user_menutrack.c` `draw_item`,
  `RGB_DKGRAY`), the lighter stone gray of both the game's tile (WL4) and the user's image (WL5), so on the stones the
  disabled items vanished (and were faint on the darker (96, 96, 96) stones).
* In a popup (`skin` with the texture, inside the popup without its shadow) a row's run of that gray next to the
  popup's white (left or right neighbour in the frame) becomes a checker of `SKIN_DIS_DARK` (32, 32, 32) and
  `SKIN_DIS_LIGHT` (80, 80, 80), phase ((column + row) from the popup's top-left) & 1, the tile's origin; only canvas
  pixels still showing that gray (not a float above). A highlighted disabled item (its gray between highlight pixels)
  keeps the gray on the blue; the bar (no texture), the shadow (outside the popup's rectangle), the black text, the
  highlight, the border, the separators and the DOS graphics (no skin) are unchanged. Decided from the frame alone, so
  a damaged part composes as the whole canvas (`pwl_check`).
* The colours: a prototype on the user's image (`build/crt6wl6-stage/obj/proto/proto.png`, `proto.py`) compared solid
  128 (today: invisible), checkers 32/80, 0/80, 48/88, 32/72 and 64/tile at 3x; 32/80 keeps both tones darker than the
  darker stone (96) and reads as a dotted dark gray, clearly not the solid black of the enabled items. Guide: Windows
  3.1's grayed text through GrayString's 50 % pattern (**inferred** from the SDK).
* P0: presentation only; selection, commands and the menu loop are the game's and w16's as before.

## Deviations

1. CRT6: the gameplay's scanlines no longer follow the gameplay frame's source rows (CRT4's two per source row): they
   follow the title's, in screen pixels (the user's direction). F346.
2. CRT6: the DOS reference uses the intro's 4:3 item (the accepted title's look); with the gameplay item different the
   in-play picture's aspect and the scanlines' base can differ (the rows differ only where the 4:3 and square titles
   have different heights, not on 16:10 or 16:9 monitors, whose title fills the height either way).
3. WL6: the two grays are fixed (not derived from the image); a menu image with very dark stones would need others.
   F347.

## Tests

* `tests/test_crt.c` 41 -> 62 checks, `gameplay()`: through the presentation on a 2560 x 1600 monitor, with integer and
  fit: the Windows game screen 1280 x 800 and 853 x 533 full screen, 1280 x 760 in a maximized window, a windowless
  canvas 1706 x 1066, the game screen 640 x 480 in a 1280 x 960 window, a DOS A frame in play (a stand-in profile) at
  1280 x 800 full screen, 853 x 506 maximized and 640 x 480 in a window: each with the title's rows, gap period
  (within 0.02) and depth (within 0.005), the same scanlines and period rows (16 checks); the accepted screens' own
  base (Windows 960 over 1440, DOS title 400 over 1080, a DOS A frame before play 480 over 1440); the headless base;
  the start of play with the same layout filters the whole picture (a small damage equals a whole redraw). **Fails on
  the base**: the same test linked with the tree's objects (`obj/Checked/test_crt-base.exe`): 16 failures (14 gameplay
  cases, the headless one, the start of play); the 640 x 480 window case and the accepted screens pass there too.
  Golden and timing unchanged.
* `tests/test_wl.c` 116 -> 125 checks, `wl6()`: a disabled item's letters (two stems and a bar, 44 pixels) are the
  checker at its phase on a two-gray tile; both grays differ from black and from the stones; the highlighted disabled
  item, the black text, the border, the shadow and the bar's gray title unchanged; `pwl_check` 0; the highlight moving
  onto it composes as the whole canvas; on a menu image (a synthetic PNG) too; without the skin the gray stays. WL4's
  check of the popup's gray text now expects the checker. **Fails on the base** (`test_wl-base.exe`): 5 failures.
* Private overlay (`build/crt6wl6-stage/obj/mk.cmd`, tree + stage, /W4 /WX, c11 and c17): Checked and Release
  test_crt 62 PASS, test_wl 125 PASS; CheckedNoObs compiled (the tree's CheckedNoObs objects predate WL5, not linked).

## For the records

* FIDELITY: F346 (CRT6, amending F343 and F345) and F347 (WL6, amending F341 and F344) - applied in this unit.
* DESIGN (CRT section: the base; WL section: the disabled items), FEATURES, RUNNING: left to the docs pass.

## What the user checks

* **CRT6-1** Windows graphics, Display > CRT scanlines on, full screen (Alt+Enter): look at the title menu, then load
  a game (CAE3540B.SAV or CHIEF.SAV from this folder) or start one. The map, the World Map, the Status window, the
  menus and dialogs show the same scanlines as the title menu: the same thickness, the same spacing and the same
  darkness on your screen. Before (build "crt5") the game's lines were finer and closer together than the title's.
  Try it with integer scaling and with fit.
* **CRT6-2** The same comparison windowed: the title menu and the game in the window, then maximize the window,
  restore it and make it larger and smaller during the game: the game's scanlines stay those of the title (and of full
  screen); they do not become finer when the window grows.
* **CRT6-3** Windowless play (Windows graphics, Display > Windowless play) with the option on, windowed and full screen:
  the canvas, its menu bar and the floating windows show the title's scanlines, not finer ones.
* **CRT6-4** The DOS graphics (Ctrl+Shift+Backspace), windowed and full screen, also with windowless play: the map,
  the city screen and the other game screens show the same scanlines as the DOS intro and title menu (two thin gaps
  per DOS title row). Before, the game's were clearly finer than the title's.
* **CRT6-5** Unchanged: the intro, the title menu, the Birth scenes and the setup screens look exactly as in build
  "crt5", in both graphics, windowed and full screen; with the option off there are no scanlines anywhere.
* **WL6-1** Windowless play, Windows graphics, in a game: open the menus of the top bar (for example Orders with a
  unit selected, and the others). The items you cannot choose now show in a dotted dark gray, readable on the stone
  background and clearly different from the solid black of the items you can choose; clicking them still does
  nothing, as before. Before (build "wl5") they were invisible.
* **WL6-2** Unchanged: the black items, the blue highlight with white letters (a highlighted unavailable item keeps
  its gray letters on the blue), the borders, the shadow and the bar; Windowless play off keeps Windows' white menus
  with their gray items; the DOS graphics' menus are as before.

## Expected changes at the build slot

* test_crt 41 -> 62, test_wl 116 -> 125 in Checked and Release (CheckedNoObs, not part of this cycle: test_wl keeps its
  single refusal check; test_crt's new checks use no observer function and should give 62 there too, not run
  privately); every other count and golden unchanged (the CRT option is off in every harness run; the windowless
  skin appears in no harness run). P0 unchanged (presentation only). ext_g1 runs 77 unchanged. No new source files;
  build.cmd and test.cmd unchanged.

## Rebase notes

Bases: `BASE-SHA256.txt` (the tree's present/present.c, present.h, wl.c, tests/test_crt.c, test_wl.c and
docs/FIDELITY.md on 2026-10-22, equal to CRT5b's and WL5's landed files). Code edits: anchored replacements in the
stage (LF kept). FIDELITY: F346 and F347 appended (`obj/fid_rows.md`). Private tools: `obj/mk.cmd`, `obj/rsp.py`,
`obj/mk-base-test.cmd`, `obj/measure/measure.c`, `obj/proto/proto.py`.

## Landing

CRT6 and WL6 landed together at the build slot on 2026-10-22 (times UTC), in one cycle.

* **Bases** as staged (the tree unchanged since CRT5b and WL5). `build/a43-prep/land.py crt6wl6` dry run `DRY_RUN_OK 5`;
  copy-in 10:32:28 (present/present.c, present.h, wl.c, tests/test_crt.c, test_wl.c; LF as the tree;
  `build/crt6wl6-prep/landed.sha256`, `tree-before/`, the Checked test outputs before in `before/`), then
  docs/FIDELITY.md (F346, F347) after its base check (`FIDELITY.before.md`) and this record.
* **The cycle** (`build/a43-prep/cycle.ps1 -Unit crt6wl6`, `build/crt6wl6-status.txt`): 1 `build.cmd checked` BUILD_OK
  10:32:38..10:36:46; 2 `test.cmd checked` TESTS_OK 10:36:46..11:10:54 (test_crt PASS 62, test_wl PASS 125, golden
  unchanged, nodos 0 hits); 3 `ext_g1.py check` EXT_G1_OK runs 77 (its standing "amended 1" note): **ALL_GREEN**
  11:10:54; 4 `build.cmd` (Release) BUILD_OK 11:10:54..11:15:53: **RELEASE_OK**.
* **Against the predictions** (`build/crt6wl6-prep/predictions.txt`): as predicted. Of the Checked test outputs only
  informational lines changed (`build/crt6wl6-prep/after/`): coverage's "other functions entered" 670 -> 671, nodos
  1881 -> 1883 files (0 hits), timeline-partitions' host timings.
* **User build** `build/user-builds/crt6wl6/` (CRT6-1..CRT6-5, WL6-1..WL6-2): the Release civ64.exe (5,020,160 bytes,
  sha256 b6c5e572...28ee3fb8), CIVWIN.zip and civdos.zip from build "d4", CHIEF.SAV, CAE3540B.SAV, MusicSfx.zip and
  civ-winmenu-bg.png from build "crt5", WHAT-TO-CHECK.txt. FIDELITY F346, F347.
* **Back-out**: `build/crt6wl6-prep/tree-before/` over the tree, docs/FIDELITY.md from `FIDELITY.before.md`, delete
  this record, then `build.cmd checked` and `build.cmd`.

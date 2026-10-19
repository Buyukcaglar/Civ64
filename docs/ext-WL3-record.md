# Extension unit WL3: windowless play on the whole window (both graphics), version 1.2

## Result

Windowless play now draws on the whole client area in both graphics: the black border around the stitched picture is
gone (at most a remainder below one scale step, k - 1 host pixels, as in the windowed game).  civ64's version
information and About box say 1.2 for the public release v1.2.

## Status

Implemented and landed at the build slot of session E5 on 2026-10-19 (see "Landing"); user checks WL3-1..WL3-4
pending (build `build/user-builds/wl3/`).

## The user's words

2026-10-19 about 06:40 UTC: "wl2 accepted but there is one minor flaw, when switched to windowless play, game always
ends with having a black border around the play area, check the uploaded screenshot, windowless play shall also
utilize/draw on full canvas area without that black border. Try to fix now with remaining usage, and update Github
with the release v1.2" (screenshot `build/e5rev/WL3-border.png`, DOS graphics, 1903x1354 window); then: "game always
ends with having a black border around the play area for both graphics modes, not just DOS".

## The cause

The game screen (the virtual screen, F105/F110) is the client's size at the game's scale, so the windowed game fills
the client.  WL's canvas is that screen without the three windows' captions, frames and scroll bars (WL2's start-up
layout: 640x480 -> 613x439), and `present.c` lays the canvas out at the same scale and centres it: black borders of
about the removed chrome times the factor on every side (WL's decision 5, the orchestrator's answer 5, F322).  At the
screenshot's 2x: about 27 x 41 logical pixels, the borders seen.

## Design (present/wl.c, wl.h, present/present.c)

* `pwl_screen_of` (pure) / `pwl_screen_for_view`: the game screen for a view of vw x vh logical pixels so that the
  canvas fills it: each side grown by the frame's size minus the canvas's, on a side only while the canvas follows the
  screen there one to one: the map window's right (bottom) edge on the screen's edge, so that F110's follow sizes it,
  and at the bottom the map client the canvas's tallest piece.  Otherwise that side keeps the view's size (no runaway
  growth; the border stays on that side only).
* `present_game_screen_follow` (`follow_size`): while the option is on, the following game screen is the view's size
  grown that way (clamped to 640..max).  The map window grows by the chrome, so the canvas becomes the view's size and
  is laid out at the game's scale at origin (0, 0).  Off again: the screen goes back to the view's size.  The bar, the
  World Map/Status column keep WL2's places; S still reaches the bottom (F338).  Fixed point: the chrome is constant,
  so the next follow asks the same size.
* Unchanged: `present_game_screen` (the first screen, F105), the headless host (fixed `--game-screen`), the arrangement,
  the composition, the inverse map, the map layer.
* Version 1.2: `win64/civ64.rc` FILEVERSION/PRODUCTVERSION 1,2,0,0, "1.2"; `host_win32.c` `g_about_title` "... v1.2".

## Evidence

Inferred / accepted design change (the user's direction); the screenshot; WL2's start-up numbers in `test_wl`.  No DOS
data involved.

## Deviations

1. **Switching windowless play resizes the game screen** by the chrome (a few dozen logical pixels), at the game's
   PeekMessage calls by F110's rule, as if the player had enlarged or shrunk the host window: the map window grows or
   shrinks with it (WM_SIZE to the game, as for the player's own sizing).  Until then (one message loop pass) the
   canvas shows at the old size.  WL and WL2 changed nothing the game sees; this is presentation-driven host input the
   player could have produced (P0's rule), recorded as a choice.
2. **A map window moved off the screen's right or bottom edge** keeps the border on that side (the screen cannot make
   the canvas follow there); with the Status column taller than the map client, the bottom keeps it too.
3. **The remainder**: a client not a multiple of the scale leaves at most k - 1 host pixels, as in the windowed game.

## Tests

* `test_wl` 78 -> 93 checks: `wl3_pure` (8: the grown screen 667x521 for a 640x480 view, the canvas 640x480 on it,
  S to the bottom, the fixed point, another view, the sides that keep the view's, no canvas) and `wl3_facade` (7: the
  follow off/on/off through `present.c`, the canvas the view's size laid out at 2x with origin (0, 0)).  They fail on
  the base (the functions do not exist; the base's canvas is laid out at origin (27, 41)).
* `test_host_win32`: the version checks expect 1.2 (count unchanged).

## For the records

Applied directly in this unit (no docs pass): FIDELITY F339 (windowless play on the whole client) and F340 (version
1.2), F322's border note amended; DESIGN 12.12 ("The whole client"), 12.x's About/version lines; RUNNING (`test_wl`
row, Display's text, the About box's title).

## What the user checks

* **WL3-1** Windows graphics, Display > Windowless play on, in a game: the picture (menu bar on top, World Map and
  Status on the left, the map on the right) fills the whole window: no black border on the left, right, top or
  bottom.  The map shows a bit more land than before; the Status panel still reaches the bottom.
* **WL3-2** The same in the DOS graphics (Ctrl+Shift+Backspace switches): no black border around the picture.
* **WL3-3** Both graphics: make the window larger and smaller, full screen (Alt+Enter), and the Display scaling choices:
  after each change the picture fills the window again (a pixel or two at an edge is the rounding).  Switch
  windowless play off and on a few times: the windows come back as before (the map window a little smaller when off).
* **WL3-4** Re-check WL2-1..WL2-5 (menus under their titles, no scroll bars, World Map and map clicks, dialogs, the
  setting remembered, the screens before the game unchanged), and the About box (system menu > About...) says
  "v1.2"; the file's Properties > Details show version 1.2.

## Expected changes at the build slot

* test_wl 78 -> 93 checks; every other count and golden unchanged (the headless follow is the fixed `--game-screen`;
  ext_p0's windowless rows compare core outputs only).  P0 checks unchanged.

## Rebase notes

Bases `BASE-SHA256.txt`: the tree after WL2 and the E5 docs pass (present/wl.c, wl.h, present/present.c,
tests/test_wl.c, win64/civ64.rc, platform/win32/host_win32.c, tests/win32/test_host_win32.c, docs FIDELITY, DESIGN,
RUNNING).  All LF.

## Landing

WL3 landed at the build slot of session E5 on 2026-10-19 after WL2 and the E5 docs pass.

* **Bases** equal to the tree (`BASE-SHA256.txt`, 7 code files and 3 docs).  Copy-in 06:51:42 UTC
  (`build/wl2-prep/land.py wl3 --write`, 7 files; FIDELITY, DESIGN, RUNNING copied from the stage; their originals in
  `build/wl3-prep/tree-before/docs`).  Quick checks after step 1: `test_wl` PASS 93, `test_host_win32` PASS 495.
* **The cycle** (`build/wl3-status.txt`): 1 `build.cmd checked` BUILD_OK 06:51:59..06:55:30; 2 `test.cmd checked`
  TESTS_OK 06:55:44..07:24:01 (1,697 s; test_wl PASS 93 checks, test_host_win32 PASS 495, WL_PAIRS_OK checks 15,
  P0_OK checks 577, EXT_ADAPT_OK checks 389); 3 `ext_g1.py check` EXT_G1_OK runs 77: **ALL_GREEN** 07:24:01 UTC;
  4 `build.cmd` (Release) BUILD_OK 07:24:01..07:27:11: **RELEASE_OK**.  Release `civ64.exe` 07:27:07 UTC, 5,005,824
  bytes, SHA-256 92d4c8408f1043fcff8b3acc84ac975891d05161262c3459191cf7569a2d1a91.
* **Against the predictions** (`build/wl3-prep/predictions.txt`): as predicted.
* **User build** `build/user-builds/wl3/` (WL3-1..WL3-4; with CHIEF.SAV and MusicSfx.zip from build "wl2").
  FIDELITY F339, F340.

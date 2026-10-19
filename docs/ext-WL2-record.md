# Extension unit WL2: windowless play revisions (both graphics)

## Result

In windowless play, in the Windows and the DOS graphics:

1. the menu bar starts at the canvas's top left and runs across the whole canvas, above the World Map; the World Map,
   the Status panel and the play map lie below it; the menus that drop from it (Windows popups, DOS drop-downs) open
   under their titles;
2. the Status panel reaches the canvas's bottom: it is taller, with the same frame, texture, fonts and contents layout,
   the extra height being more of its own panel background (nothing is stretched).

No scroll bars, the World Map and play-map click jumps, the on-the-fly switch, the remembered setting, full screen,
scaling and zoom, and the screens before the game are as WL left them.

## Status

Implemented, built and tested privately (overlay = tree after D7g3 + this stage); landed (section "Landing").  The user
checks WL2-1..WL2-5, which include the re-check of WL-1..WL-9.

## The user's words

Brief `docs/verify/BRIEF-e5rev.md`, "Unit WL2" (verbatim there, 2026-10-18 about 23:20 UTC): "1. Both DOS and Windows
menu bar/area shall start from the top left of the canvas effectively above the "World Map" 2. Again for both graphics
mode 'Status' window's bottom shall be aligned with the bottom of the play canvas (increase status window height while
preserving its visual identity)".

## Design (present/wl.c, wl.h)

* **The bar piece B** (`PwlArr.p[PWL_B]`, `PWL_B` = 3, pwl_point's part `PWL_PART_BAR`): the map window's menu bar
  rectangle (w16q_menu_bar; in the DOS graphics the DOS bar drawn there) at canvas (0, 0).  The canvas is the column's
  width plus the client's (at least the bar's width); beyond the bar's own width its rows repeat its last column (the
  bar's background; nothing of the frame right of the bar is shown).  M is the client alone, below the bar
  (its translation is unchanged, so the map layer is as before); the column (W, S) starts at the bar's bottom.
* **Menus with the bar**: the Windows menu loop's popups (w16q_menu_saved) and the DOS drop-downs
  (`pdos_reskin_a_rects_drop`, `PDOS_RK_DROP`) are anchored at B (`PwlScene.flbar`), so they open under their titles.
* **S grown** (`s_cut`, `s_ext`): when S is the column's last piece and the canvas is taller than the column, `s_ext`
  rows are inserted at frame row `s_cut` (`PWL_FOOT` = 12 rows above the client's bottom: the Windows Status panel's
  inner frame lies 11 rows up, the DOS panel's lower edge 4), filled with the band of `PWL_BAND` = 32 rows above the
  cut repeated (both graphics' panel interior and textured margins repeat without a seam at that period; the DOS 2x
  rows stay paired); the rows below the cut, and the floats anchored at S below it (D7g3's recommendation on the
  Status bottom), move down by `s_ext`.  When a float lies over the band, the cut moves up in steps of 2 until the band
  is clear (at most to S's middle), so a box is never repeated.  The contents keep their size and place.
* `piece_cv`, `cv_to_frame`, `dmg_piece`: the pieces' canvas rectangles, the inverse map and the damage through the bar
  fill and S's inserted rows; `put_part` composes one part (D7g3's black rule per part's translation).  pwl_check,
  pwl_point (latched parts included), the float footprints and the take's damage use them.
* Harness: the `wl arrange` fact line gains `barpiece on l t r b dx dy sext cut ext`; ext_wl.py's model follows (the
  bar part is piece 3; the bar clicks expect it).
* P0: presentation only; the frame, the game screen and the core are unchanged; no core read is added.

## Evidence

* Inferred / accepted design change (the user's direction); the Windows Status panel's geometry measured on the
  harness's frames (`obj/run/windows/`, `obj/run/dos/`; private).  No DOS data involved.

## Deviations

1. **The bar's fill**: beyond the map window's bar width the bar's last column is repeated to the canvas's right side.
2. **S grows only when it is the column's last piece** (the default layout); with the Status above the World Map it
   keeps its height (the World Map would otherwise be pushed off).
3. **The band is fixed** (12 and 32 rows): a Status content drawn within its lowest 44 rows would be repeated; the
   Windows and DOS Status panels draw nothing there in the observed layouts.

## Tests

* **test_wl** (60 -> 78 checks): the arrangement's new numbers (canvas 613x439 for the start-up layout, B at (0, 0),
  W at (0, 18), S at (0, 120) grown by 12 rows, M at (160, 18)); `wl2`: a popup with the bar, the cut above a box on the
  Status bottom and the box moved down with S's foot, the bar's rows (its pixels then its last column), S's inserted
  rows repeating the band, S's last row at the canvas's bottom, the definition model and pwl_check, band damage
  reaching the inserted rows; the model (`model`) follows the new definition; the bar points (top left, fill, latched)
  (fails on the base: no `PWL_B`/`flbar`).
* **ext_wl** (wl-win, wl-dos): the bar clicks (Help title, DOS GAME zone) on the bar part; the popups/drop-down rows
  and the rest as before (private run below).
* Frames viewed (private): `obj/run/dos/`, `obj/run/windows/` (1920x1400, windowless: the bar across the top, the
  Status panel to the bottom, in the DOS graphics with D7g3's recommendation on its bottom).

## For the records

* FIDELITY: F337 (amends F322: the bar piece at the canvas's top left across its width, its last column repeated;
  the column and M below it; menus with the bar); F338 (the Status panel grown to the canvas's bottom by repeating
  its own band, the rows below the cut and their floats moved down; only when S is the column's last piece).
* DESIGN: the WL section (pieces B, M, W, S; S's growth).  RUNNING: test_wl 78; the `wl arrange` fact fields.

## What the user checks

* **WL2-1** Windowless play on (Display), both graphics (Ctrl+Shift+Backspace switches): the menu bar runs across the
  very top of the picture from its left edge, above the World Map; the World Map, the Status panel and the map are
  below it.  The menus open under their titles and work with the mouse and the keyboard.
* **WL2-2** Windowless play on, both graphics: the Status panel reaches the bottom of the picture.  It looks the same
  as before, only taller: the same frame, texture, letters and numbers, nothing stretched; the extra height is more of
  the same panel background.
* **WL2-3** DOS graphics, windowless play, CHIEF.SAV's science advisor recommendation (D7g3-1): the recommendation
  stands on the Status panel's bottom left at its width, at the bottom of the picture.
* **WL2-4** Window larger, smaller, full screen (Alt+Enter), the Display scaling choices and the map zoom (Ctrl+Shift+Plus/Minus): the bar stays
  at the top left and the Status panel at the bottom.
* **WL2-5** Re-check WL-1..WL-9 of build "wl" with this build (the menu item, no scroll bars, the World Map and
  play-map clicks, dialogs over the picture, the setting remembered, full screen/scaling/zoom, the screens before the
  game unchanged).

## Expected changes at the build slot

* test_wl 60 -> 78 checks; ext_wl's pairs unchanged in number (WL_PAIRS_OK 15); every other count and golden unchanged
  (ext_p0's V9/V9d/V9t windowless rows compare core outputs only).  P0 unchanged.

## Rebase notes

Bases `BASE-SHA256.txt`: the tree after D7g3's landing (present/wl.c, wl.h, present/dos/pdos_reskin.c, .h,
tests/test_wl.c, tests/headless/harness.c, tests/harness/ext_wl.py).  All LF.

## Landing

WL2 landed at the build slot of session E5 on 2026-10-19 after D7g3 (build/d7g3-prep/LANDED.txt).

* **Bases** equal to the tree after D7g3 (`BASE-SHA256.txt`, 7 files).  Private overlay (tree + WL2) Checked,
  CheckedNoObs and Release BUILD_OK, every unit and Win32-headless test passing in the three variants; REGISTRY_OK,
  OBS_LINT_OK, pdos_scene_check PASS 1086, ADAPT_OK 166 rows, NODOS_OK; ext_wl WL_PAIRS_OK checks 15.
* **Copy-in** 03:01:07 UTC (`build/wl2-prep/land.py wl2 --write`, 7 files, LF as the tree).
* **The cycle** (`build/wl2-status.txt`): 1 `build.cmd checked` BUILD_OK 03:01:11..03:04:29; 2 `test.cmd checked`
  TESTS_OK 03:04:29..03:34:16 (1,787 s; test_wl PASS 78 checks, WL_PAIRS_OK checks 15, P0_OK checks 577,
  EXT_ADAPT_OK checks 389); 3 `ext_g1.py check` EXT_G1_OK runs 77: **ALL_GREEN** 03:34:16 UTC; 4 `build.cmd`
  (Release) BUILD_OK 03:34:16..03:37:25: **RELEASE_OK**.
* **Against the predictions** (`build/wl2-prep/predictions.txt`): as predicted.
* **User build** `build/user-builds/wl2/` (WL2-1..WL2-5; with CHIEF.SAV from build/user-builds/d7g). FIDELITY F337,
  F338.

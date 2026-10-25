# Unit ONE (1:1 pixels in gameplay) - record

## The user's words (2026-10-25, times UTC)

* About 08:00: "Add a experimental 1:1 graphics drawing feature for the gameplay, when selected from menu draws all
  the graphics including simulated win16 layer's window graphics on their original size on both graphics mode. Do
  this on a separate local branch not on the main right now."
* About 08:30: "In DOS graphics, draw the play screen at half size so each DOS pixel is one screen pixel." Then about
  08:40: "roll back only latest update" (the half-size DOS play screen was reverted; see "History").
* About 08:45: "in 1:1 mode disable zoom out beyond normal."
* About 15:40, with a screenshot of the maximized window at 1:1: "1:1 implementation accepted but at least a single
  rule/check/threshold shall be implemented. When 1:1 is selected, actual visible map area canvas can not be smaller
  than the whole world map coverage". After the agent's restatement (1:1 gives way to the smallest whole step once
  the client is larger than the largest game screen, so the visible map never covers more than the whole world):
  "Ok go on they way you explained seems like the thing I tried to describe; 1. Yes DOS graphics also 2. Remove
  (experimental) from 1:1 pixels pixels in gameplay 3. 1:1 option selection is not persisted/remembered, it should be".
* About 16:30: "Accepted, update application version to v1.2.5 and update relevant documentation and areas. Commit &
  push both repos, update latest release for both variants."

## Change

* **The option** (`present/present.h` `present_set_one_to_one`, `present_one_to_one`, `present_one_to_one_active`):
  while it is on and the game is in play (the game has opened its map window, `present_game_screen`; or the visible
  profile is in play, `profile.h` `in_play`), every frame of both graphics is laid out one host pixel per pixel:
  the Windows game screen with the emulated Win16 windows, the windowless canvas, the DOS A frame (its DOS art at 2x
  as always) and the in-play 320 x 200 N frames. Square pixels (the 4:3 items do not apply), centred, never filtered.
  Before play (the intro, title menu, Birth, setup) the Integer / Fit choice applies unchanged.
* **The scaler** (`present/scale.h`, `scale.c`): the policy `PRESENT_ONE` gives an integer layout with
  kx = ky = 1 (a frame larger than the client: fit, as `integer` does); `present_layout_compute_k` gives the same
  layout at the largest whole step up to k at which the frame fits. Every reader of a layout still sees an integer or
  a fit layout.
* **The game screen** (`present/present.c` `present_game_screen`, `present_game_screen_follow`; FIDELITY F105, F110):
  while 1:1 applies it is the client in host pixels (at the whole step k below), whatever scale the game began at; it
  follows at the game's next message loop when the option changes, as for a resize. The scale the game keeps (F110)
  is not taken from a 1:1 layout, so turning the option off returns to the earlier scale.
* **The threshold** (`present.c` `one_k`, `lay`): the visible map may not cover more than the whole world. The game
  screen's largest size, 2726 x 1600 (`w16_int.h` `W16_SCREEN_MAX_W/H`: the original's largest map window
  0xA00 x 0x640, the 2560 x 1600 world, and the 166-pixel World Map/Status column beside it), is the threshold: on a
  larger client, 1:1 gives way to the smallest whole step k = max(1, ceil(cw / 2726), ceil(ch / 1600)), every frame in
  play drawn at k x k, in both graphics, so the picture fills the client instead of standing in a black border (a 4K
  client: k = 2, the game screen 1920 x 1080). Up to 2726 x 1600, k = 1.
* **The map layer** (`present/map/pmap_layer.c`): lays the core's frame out through `present_layout_frame` (the view's
  policy, aspect and step). **No zoom out beyond normal** (`pmap_zoom.c`): while 1:1 applies `pmap_request_zoom`
  refuses the levels out ("no zoom out beyond normal in 1:1 mode"), `pmap_zoom_command` stops at normal, and a level
  out returns to normal when 1:1 begins to apply (`present.c` `one_zoom_clamp`); the levels in are unchanged.
* **The pointer**: the game's cursor follows the layout's factors (1 at 1:1); the DOS pointer the UX1b factors of
  the 1:1 layouts.
* **The window menu** (`platform/win32/host_win32.c`, `host_win32.h`): Display's check item "&1:1 pixels in gameplay"
  (SC 0x1150), below Fit to window; Map zoom's Zoom out is grayed at normal while 1:1 applies.
  `hw_set_one_to_one` and its hook.
* **Remembered** (`win64/civ64_main.c`): the key `one_to_one` of `civ64.cfg` ("1" on), written after the player's
  choice, read at the start.
* **Version 1.2.5** (`win64/civ64.rc`, the About box `g_about_title`; FIDELITY F355). `Civ64-Win7.exe` takes the
  version from `civ64.rc` (`claude/Win7Port/tools/make_rc.py`).
* **Tests**: `tests/test_present.c` (the 1:1 layout, its fit fallback, the whole step and its largest fitting
  factor); `tests/win32/test_host_win32.c` (Display's new item; the version 1.2.5).

## History

The work was done on the local branch `experimental/one-to-one-pixels` (commits 931e431, 36dc786, its revert
14050b8, ec31f05, 32e838a) and fast-forwarded into `main` for 1.2.5. 36dc786 drew the DOS A frame at half size
(`PRESENT_HALF`, each DOS pixel one screen pixel, the game screen twice the client) at the user's direction; the
user rolled it back (14050b8) before the threshold, so the DOS play screen is drawn 1:1 as frame pixels.

## Checks (agent-observed, this PC, 2026-10-25)

* `build.cmd` Release BUILD_OK after each step; `build.cmd all` before the release (see the commit).
* `test_present` 978 checks, `test_map` 367, `test_wl` 150, `test_crt` 62, `test_input` 704, `test_start` 110,
  `test_pdos_aspect` 140, `test_pdos_cursor` 62, `test_pdos_profile` 63: PASS (Release). `w32_test_host_win32` 554,
  `w32_test_dos_host` 56, `w32_test_locate` 56, `w32_test_slots_host` 19: PASS (Release).
* `claude\Win7Port\build.cmd`: BUILD_OK, WIN7_IMPORTS_OK (258 imports).
* User builds `build/user-builds/one2one/` (civ64.exe and Civ64-Win7.exe; WHAT-TO-CHECK.txt ONE-1..ONE-9). The user
  accepted the feature at each step (manual-checklist-ext.md "ONE").

## Not covered

* The long harness suites (`ext_p0.py`, `ext_zoom.py`, `ext_adapt.py`, `ext_wl.py`) were not run; the option is off
  by default and they run with it off.
* While 1:1 applies the game screen follows the client in host pixels, so the game's windows see a larger desktop
  than at the earlier scales; same-seed comparisons (F105) take the size as an input as before.
* The macOS application has no "1:1 pixels in gameplay" item yet (the portable `present/` code is shared; the menu
  item and the key belong to `platform/macos/host_macos.m` and `macos/civ64_mac.m`); NEXT-SESSION-E5 2m.

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
* The macOS application had no "1:1 pixels in gameplay" item in PUB8; the session on the Mac added it (below, "The
  macOS port").

## Publication (PUB8, 2026-10-25, times UTC)

* Civ1RE `cb86729` (version 1.2.5, the documents, the public sources) pushed `c9bb907..cb86729`, with the branch's
  commits `931e431..32e838a`.
* Civ64 `3dbe2d5` (README, User Guide, docs/README and the generated docs for 1.2.5) pushed `e43cf20..3dbe2d5`.
* Release [v1.2.5](https://github.com/Buyukcaglar/Civ64/releases/tag/v1.2.5) Latest, published 16:29:05:
  `civ64.exe` 5,042,688 bytes, SHA-256 `99dc7c58...5e5a079d`; `Civ64-Win7.exe` 4,937,728 bytes, SHA-256
  `f91e3e16...b38cdfaa`. The macOS application stays 1.2.4 in release v1.2.4; the README and User Guide point Mac
  users there. State: `build/pub-stage/STATE.md` "Unit PUB8".

## The macOS port (session on the Mac, 2026-10-25, times UTC)

The user, about 16:35: "pull latest civ1re repo look for updates and changes, apply them to mcOs app and and update
latest release for Civ64 repo with v1.2.5 binary"; then "commit & push you changes also".

* Civ1RE fast-forwarded `9b3cc4a..81dadf4`, Civ64 `1edafe8..3dbe2d5`. The portable part of ONE builds unchanged.
* `platform/macos/host_macos.m`, `host_macos.h`: Display's check item "1:1 Pixels in Gameplay" (`CMD_ONE`, below Fit
  to Window), checked by `present_one_to_one`; the choice calls `hm_set_one_to_one` (`present_set_one_to_one`, the
  cursor at the new layout's factors, the menu), then `hm_set_one_to_one_hook`'s hook and the settings hook, as
  host_win32.c's SC_CIV_ONE. Map Zoom's Zoom Out is grayed at normal while `present_one_to_one_active`.
* `macos/civ64_mac.m`: the key `one_to_one` ("1" on) read at the start, written after the player's choice; no command
  line option (as on Windows). `macos/mac_cfg.h` lists the key.
* The macOS client is in device pixels, so on a Retina display 1:1 is one device pixel per pixel and the threshold
  (2726 x 1600) counts device pixels: a client of up to 2726 x 1600 device pixels draws at 1, a larger one at the
  smallest whole step (a 5K display in full screen, 5120 x 2880: k = 2).
* Version 1.2.5: `macos/Info.plist` (CFBundleShortVersionString and CFBundleVersion), `macos/READ-FIRST.txt`; the About
  box reads Info.plist (F355).
* `build-mac.sh`: BUILD_OK (313 portable sources, c11, c17, c99; 64 test programs; Release arm64).
  `test-mac.sh`: TESTS_OK (31 sections, 0 failed).
* `package-mac.sh --out build/user-builds/v1.2.5` (16:40): PACKAGE_OK; universal (x86_64 arm64); NODOS_OK; Developer
  ID, hardened runtime; `Civ64-1.2.5-macOS.dmg` notarized (submission `7b7eab0b-88e0-468d-81ee-ff96497af3dd`:
  Accepted) and stapled; Gatekeeper accepts the application and the image; SHA-256
  `f46a4b26d5daf93a230bd3f80b4e6f026cef4cb71607028c4af1d0a05a71996a`, 4,895,146 bytes. Info.plist says 1.2.5; both
  architectures hold "1:1 Pixels in Gameplay" and "one_to_one".
* Seen on this Mac (agent-observed): the packaged application started with the player's settings and ran for 8
  seconds, then was stopped; `civ64.cfg` unchanged.

### Not covered (macOS)

* The 1:1 item, its Zoom Out gray, the threshold and the remembered `one_to_one` were not exercised in a running game
  on the Mac (no menu interaction); the portable layouts are covered by `test_present`, the menu code is the Windows
  host's pattern. The long harness suites were not run.

### Published, macOS

* Civ64 `README.md` (Quick start on macOS: `Civ64-1.2.5-macOS.dmg` from the latest release; "New in version 1.2.5"
  says the macOS application is 1.2.5), `docs/USER-GUIDE.md` (the opening, section 15: version 1.2.5, the download, the
  Display item), `docs/README.md` (the result row 1.2.5, the 1.2.5 paragraph; the same in
  `build/pub-stage/docs-README.head.md`); the generated docs by `stage_mac.py`. NODOS_OK over the clone (486 files).
* Civ1RE `181232b` pushed non-force `81dadf4..181232b`. Civ64 `524be88` (noreply author and committer, 7 files)
  pushed non-force `3dbe2d5..524be88`.
* `gh release upload v1.2.5`: `Civ64-1.2.5-macOS.dmg` 4,895,146 bytes, GitHub digest
  `sha256:f46a4b26d5daf93a230bd3f80b4e6f026cef4cb71607028c4af1d0a05a71996a` (`shasum -c` OK before the upload), and
  its `.sha256`; `civ64.exe` and `Civ64-Win7.exe` unchanged. `gh release edit v1.2.5 --notes-file` the merged notes:
  the body equals the file. `releases/latest` = v1.2.5; `releases/latest/download/Civ64-1.2.5-macOS.dmg` resolves
  (200).

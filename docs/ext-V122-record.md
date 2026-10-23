# Unit V122 (the macOS session's two DOS fixes in the Windows civ64.exe; version 1.2.2) - record

## The user's words (2026-10-23, about 05:30 UTC, session on Windows)

> pull latest Civ1RE repository, macOs work found 2 two bugs related to DOS code, investigate and apply them to the
> Windows executable, update application version v1.2.2, push to both repos and publish a new release update relevant
> documentation.

## The two bugs

The macOS session (unit series MAC, [verify/BRIEF-mac.md](verify/BRIEF-mac.md)) found and fixed them in unit MACB1
([ext-MACB1-record.md](ext-MACB1-record.md), Civ1RE commit `75f1d92`), on the user's report of 2026-10-22 about 19:10
UTC on the macOS build. Both are in code that the Windows and the macOS builds share (`present/`), so `civ64.exe`
v1.2.1 has them too; MACB1 compiled and tested them on macOS only ("not rebuilt or run on Windows here").

| # | The user's report | Cause | Fix (MACB1) | FIDELITY |
|---|---|---|---|---|
| 1 | "Windowless play switch from Windows to DOS causes CIVILIOPEDIA menu title display problem" | In windowless play the canvas's bar right of the map window's bar repeats that bar's last column (WL2). The DOS bar's titles stand at DOS's fixed places across 320 DOS pixels (CIVILOPEDIA at 240; R:0238:1005..1075), so a map window narrower than about 330 DOS pixels cut CIVILOPEDIA and the repeated column drew a stripe of its letters | In the DOS graphics, right of the map window's bar, the DOS bar's own pixels (the same titles at DOS's places, across DOS's full width, in the play palette): `present/wl.c`, `wl.h` (`PwlScene.dos`), `present/dos/pdos_reskin.c`, `.h` (`pdos_reskin_bar_ext`) | F353 |
| 2 | "DOS graphics Advisors -> Trade Advisor: Portrait of advisor on right top is wrong colored, but only on first view, subsequent views have no such problem" | After Load a Saved Game, DOS's main sets the play palette with the government's BACK palette (R:01A8:014D..016A, R:0238:1B44, R:0238:1BEB). The port set it only at a report's return, so the first report after a load showed the portrait in SP257.PIC's upper colours | At the first play state, after SP257.PIC's palette, the BACK palette when the core's last title choice was Load: `present/dos/pdos_profile.c`, `pdos_seq.c`, `.h` (`pdos_seq_title_last`), `pdos_aplay.c`, `.h` (`pdos_aplay_palette_back`) | F354 |

MACB1's two other fixes (the Mac key equivalents of the graphics switch, the system arrow outside the game picture) and
MACB2's (a Command shortcut's Shift no longer ends the intro, [ext-MACB2-record.md](ext-MACB2-record.md)) are in the
macOS back end only (`platform/macos/`); MACB2's portable `pi_arrive_host_shortcut` is called only by it. The Windows
graphics switch, Ctrl+Shift+Backspace, is taken whole by the arrival stage and was never affected.

## Investigation on Windows

* `git pull --ff-only` brought the nine macOS commits `081ea38..e9810e3` onto `fd2bf7a` (v1.2.1); the local
  uncommitted record edits were stashed and restored without conflict.
* The shared changes were read against the Windows build: `wl.c` already includes `pdos_reskin.h`; `PwlScene.dos` is
  set in `read_scene` from the profile the scene is read for, on every host; `pdos_reskin_bar_ext` reads only the
  presentation's own DOS bar surface and the A machine's DAC; the load palette reads the DOS sequence's last title
  choice. None touches the core, rt, w16, `platform/win32` or the Windows graphics, and none draws from the RNG (P0).
* The MAC0..MACB2 commits also changed shared test files (the harness scripts' program places, `hostbin.py`,
  `testpar.py`, the headless harness, `ext-zoom-golden.txt`); the Windows cycle below runs all of them.

## Version 1.2.2

`win64/civ64.rc` `VERSIONINFO` 1,2,2,0 and "1.2.2"; `platform/win32/host_win32.c` `g_about_title` "About Sid Meier's
Civilization 64bit v1.2.2"; `tests/win32/test_host_win32.c` checks both; `docs/RUNNING.md`. FIDELITY F355. The
macOS application's `macos/Info.plist` is the macOS units' own: the macOS session set it to 1.2.2 the same
morning (commit `64662bb`, [ext-MAC4-record.md](ext-MAC4-record.md) "Version 1.2.2"), before this unit's push; that
record's sentence "civ64.exe stays 1.2.1" was true when it was written and is superseded by this unit.

## Landing

* Hash check of the originals at the start: HASH_BEFORE_OK 38 of 38, DOS_HASH_BEFORE_OK 176 of 176
  (`hashes/20261023T053431Z-*`).
* Cycle (`build/a43-prep/cycle.ps1 -Unit v122`, `build/v122-status.txt`; times UTC): build checked BUILD_OK 05:38:28
  (the macOS commits' shared changes compile on Windows, C11/C17 /W4 /WX and the C99 parse); test.cmd checked
  TESTS_OK 06:10:24 (1,916 s), among them `test_host_win32` PASS 543 (the 1.2.2 values), `test_wl` PASS 150,
  `test_input` PASS 704 and ext_zoom `ZOOM_OK combinations 32 runs 108 samples 628`: the DOS goldens of the scenarios
  `load` and `orders` at -1 that MACB1 wrote on arm64 are equal on Windows x64, so the load palette (F354) gives the
  same pixels here; ext_g1 `EXT_G1_OK runs 77` (its one recorded amendment, unchanged) = ALL_GREEN; Release BUILD_OK
  06:14:17 = RELEASE_OK.
* Release `civ64.exe` of 2026-10-23 06:14:13 UTC: 5,037,568 bytes, sha256
  a696be52183c968d666bb6680f10dfc1632eb28c054d5c7630a72eb8fe86ae19.
* The bar on Windows (agent-observed, harness): the Checked `civ_harness.exe` with `load-save.script` (Load a Saved
  Game, CAE3540B.SAV) to 40,000 ms, `--host-size 1920x1440 --windowless 1 --graphics dos --zoom +1
  --dump-presented` (the map layer on, so the host's whole composed view is written; `build/v122-check/`). The
  arrangement: canvas 631 x 461 frame pixels, the map window's bar 171..640, narrower than the DOS titles. The last
  view (`view-00100.bmp`, `bar-strip.png`) shows GAME, ORDERS, ADVISORS, WORLD and CIVILOPEDIA whole at their DOS
  places, CIVILOPEDIA ending inside the canvas, with no repeated stripe. A view of v1.2.1 was not made for comparison.
* Hash check of the originals at the end: HASH_AFTER_OK 38 of 38, DOS_HASH_AFTER_OK 176 of 176
  (`hashes/20261023T061622Z-*`).
* User build `build/user-builds/v122/` (civ64.exe; CAE3540B.SAV, CHIEF.SAV, MusicSfx.zip, CIVWIN.zip, civdos.zip as in
  ico1; WHAT-TO-CHECK.txt with V122-1..V122-3). Checklist items V122-1..V122-3 pending the user's check.
* Publication (PUB5): see STATUS.

## Not covered

* MACB1's own limits stand (F353, F354): a map window narrower than CIVILOPEDIA's place still maps a click right of
  its bar to the bar's last column; the CIVILOPEDIA drop-down in windowless play opens left of its title; an in-game
  load (File > Load Game) was not traced.
* The user's own check of the two fixes in the Windows build.

# Extension unit PAU1 (the window menu pauses the game; version 1.2.1; the Civ64 link; the menu tile inside civ64.exe) - record

## Result

* While civ64's window menu is open (the title bar's right click, the icon, Alt+Space, and its submenus Display, Map
  zoom and Graphics), while the window is moved or sized, and while one of civ64's own boxes is open (About, the exit
  warning, "Locate DOS files...", civ64's messages), the game now stands completely still, in both graphics and every
  state (intro, Birth, title, setup, play, windowless play, full screen): no game time passes, the sound and music
  pause, and afterwards everything goes on where it stopped, without catching up.
* civ64 is version 1.2.1: the file's version information and the About box's title.
* The About box's link is https://github.com/Buyukcaglar/Civ64 (it was http://github.com/Buyukcaglar/Civ1).
* The windowless Windows menus' background, the user's reworked stone tile `civ-winmenu-bg.png`, is inside civ64.exe
  (a resource); the release no longer needs the file beside civ64.exe, and the user build no longer carries it.

## Status

Complete at the build slot (see Landing); the user's checks PAU1-1..PAU1-8 are pending.

## The user's words

* 2026-10-22 about 13:10 UTC: "1. Opening application context menu does not entirely pause game, rather causes
  animation cycles to be accumulated and played back at full speed. This is not just during gameplay, but on the intro
  screens and birth-* screens also. Sound continues to play on the background when context menu open and animations
  hastens after menu is dismissed. This is not an excepted behavior, opening host application menu shall completely
  pause current state of the game. investigate and fix. 2. Update game version (About dialog box and executable
  metadata) to v1.2.1 3. Update github repo link in about dialog to Civ64 'https://github.com/Buyukcaglar/Civ64'
  4. Provide single user-build for 1,2 & 3"
* About 13:25 UTC (through the orchestrator): "You user builds has 'civ-winmenu-bg.png' files in it, this shall be
  included in the civ64.exe as a resource and the final release shall not require its existence as a separate file."
* About 13:30 UTC: "That rule still stands, this single tile is an exception to that rule."

## Findings (the cause)

* civ64 runs one thread (no CreateThread, SetTimer or timeSetEvent in platform/win32, win64, present or res). The
  back end pumps its window's messages on the game thread (`pump`, at the game's polls and waits). The window menu
  and a move or size of the window are Windows' modal loops, entered from `DefWindowProc` inside that pump: the game
  thread waits in them.
* Every clock of the game follows `host_now_us` (`platform/win32/host_win32.c`, before PAU1 the raw
  QueryPerformanceCounter, never paused): `platform/w16/host_sync.c` `w16_host_sync` computes `real = host_now_us() -
  g_origin` and, with `--timing host` (the default), advances the emulated clock to it; its waits sleep only while the
  emulated clock is ahead. GetTickCount, the timers (`clock.c`) and `w16q_now_us` (the presentation's profiles: the
  DOS and Windows intro clocks, Birth, `pbs_view_advance`; `present_tick_at`) are that emulated clock.
* So after the menu the emulated clock was behind the host clock by the whole span, every wait of the game found the
  clock behind and did not sleep, and the game ran the accumulated animation at full speed until it had caught up.
  The sound: `host_play_sound` used PlaySoundW, which cannot pause, so it played on.
* Agent's real-loop check (inferred from observation; a private debug civ64 from the staged sources, its own settings
  root, a silent copy of the Windows data, `--multi-instance`, not activated; at 6 s the window procedure ran
  `TrackPopupMenu` on the window's system menu, Windows' real modal loop with its own WM_ENTERMENULOOP and
  WM_EXITMENULOOP, closed by WM_CANCELMODE at 10 s; `build/pau1-stage/evidence-real-loop.txt`): with the pause
  disabled (the base behaviour) the Windows intro presented a frame every 3-4 ms after the menu, 158 frames and 8.0 s
  of emulated time in the next 3.99 s of real time; with PAU1, the first present after the menu was 0.021 s of
  emulated time later, then the usual 55 ms cadence, 80 frames and 3.976 s emulated in 3.974 s real.

## Design

* The host pause (`host_win32.c`): `hw_pause_begin` / `hw_pause_end`, nestable (the outermost pair counts; an unpaired
  end is ignored). While paused, `host_now_us` stands at the pause's start; afterwards it is the raw clock minus every
  paused span. Everything that follows `host_now_us` (the emulated clock, so GetTickCount, the timers, the intro and
  Birth clocks of both graphics, the presentation's tick throttle) never sees the span: no catch-up, no timer due
  because of it. `host_sleep_until_us` returns at once while paused.
* The pause's places: WM_ENTERMENULOOP .. WM_EXITMENULOOP (the window menu and its submenus, however opened),
  WM_ENTERSIZEMOVE .. WM_EXITSIZEMOVE (move, size), and around the back end's own boxes: `hw_about`, `exit_warning`,
  the Locate item's hook, `host_message`. `hw_destroy_window` ends a pause still open.
* Not paused (the game's own time, as before): the game's menu bar and dialogs inside the emulation (Windows 3.1 or
  DOS graphics), the game's Open/Save chooser (`host_choose_file`, the DOS slot screen) and the overwrite question.
* The sound: an asynchronous sound (the game's sndPlaySound with SND_ASYNC, and the AMS replacements) plays through
  waveOut on the wave mapper in the file's own format (`wo_play`; the file read whole, at most 64 MB; the RIFF reader
  `hw_wav_parse`), one at a time as PlaySoundW; the pause pauses it (waveOutPause) and resumes it where it was
  (waveOutRestart). A synchronous sound (the game waits, no menu can open meanwhile) and a sound waveOut refuses (no
  device, a format it cannot open) keep PlaySoundW. A stop (sndPlaySound NULL) and each new sound end the one playing.
* The global intro skip and the concurrent DOS/Windows intro clocks are unchanged: both clocks run on the same
  emulated clock, which simply does not move during a pause.
* P0: no core, rt, w16 or present source changes; no RNG draw; no present added, removed or delayed (the game thread
  was already waiting during these loops; only the clock it reads afterwards changes).
* Version 1.2.1: `win64/civ64.rc` FILEVERSION/PRODUCTVERSION 1,2,1,0, "1.2.1"; `g_about_title` "About Sid Meier's
  Civilization 64bit v1.2.1".
* The link: `ABOUT_URL` "https://github.com/Buyukcaglar/Civ64" (shown and opened); `hw_about_url` for the tests.
* The menu tile: `win64/civ-winmenu-bg.png` (the copy of WL5's `build/e5rev/civ-winmenu-bg.png`, 5419 bytes, sha256
  9df6ecb352442e068d3d4d40d2dff0d50fc7c8d274d714485407102db85e405b) is `2 RCDATA` in `win64/civ64.rc`;
  `win64/civ64_main.c` `menu_image` gives the resource's bytes to `present_set_menu_png` at the start. Chosen: the
  lookup of the file beside civ64.exe is dropped (no optional override): one image, always the same. A resource the
  PNG reader refuses leaves WL4's game tile, without a message, as before.
* The published civ64.exe now contains this user-reworked tile, by the user's decision. The rule that no original or
  game-derived art goes in the exe or the repository still stands; this single tile is an exception to that rule, and
  the only one: `win64/civ-winmenu-bg.png`. The tile is not a DOS asset; `gen/dos/nodos.py check` passes with it in
  the tree and in civ64.exe (no allowance was needed; if a later check flags it, the allowance is for that one file
  only).

## Deviations

* A click on the title bar enters Windows' move loop for the length of the click, so it pauses the game (and a
  playing sound) for that moment.
* The waveOut path plays the same bytes as PlaySoundW did; formats the wave mapper cannot open fall back to PlaySoundW
  and are not pausable (none known among the game's and the AMS files; unverified for every AMS file).

## Tests

* `w32_test_host_win32` 507 -> 530 checks: `test_pau1_host` (15: the simulated menu loop pauses, the host clock
  stands still over 120 ms, a wait returns at once, a nested pause leaves the outer one, the span is counted and left
  out, the clock runs again, an unpaired end is ignored, the WAV reader on a file with an odd chunk and its pad, a
  short data chunk, not RIFF, a short fmt chunk, no data chunk, one second of silence through waveOut paused by the
  menu and resumed (counted either way; exercised when a waveOut device exists), stopped); `test_sync` +3 (with host
  timing a 400 ms menu span leaves the emulated clock unchanged at a sync point within it, the clock and GetTickCount
  go on without it afterwards, a 220 ms timer is not due: no burst); `test_tld_view` +2 (a move or size pauses until
  its end); the About box's link +1; version checks updated to 1,2,1,0 and "1.2.1"; civ64.exe's RCDATA 2 present
  (5419 bytes, a PNG) and accepted by `present_set_menu_png` +2. Every new check fails on the base (the functions and
  the resource do not exist there; the version strings differ).
* Overlays (`build/pau1-stage/obj/mk.cmd`): Checked and Release `w32_test_host_win32` PASS 530 (the sound's pause
  exercised: a waveOut device was present); CheckedNoObs compiled. `gen/dos/nodos.py check --root build/pau1-stage`
  NODOS_OK (the PNG and the overlay civ64.exe included).

## For the records

* FIDELITY: F349 (the host pause), F350 (version 1.2.1 and the Civ64 link, amending F340 and F108), F351 (the tile
  inside civ64.exe, amending F344); F108's link sentence notes the new link. Applied in this unit.
* RUNNING: the About box's title and link; a paragraph "The window menu pauses the game"; the menu background
  paragraph (inside civ64.exe, the single exception). Applied in this unit.
* DESIGN / FEATURES / DOS-PROFILE: nothing required (DESIGN.md's version note says 1.2 since WL3; F350 carries 1.2.1).

## What the user checks

* **PAU1-1** Windows graphics, the intro (start civ64 and let the opening play): right-click the title bar (or click
  the icon at its left, or press Alt+Space) and leave the window menu open for about ten seconds, also with a submenu
  (Display, Map zoom or Graphics) open. Nothing moves and the music stops. Close the menu (Escape or a click
  elsewhere): the intro goes on exactly where it stopped, at its normal speed, with no fast catch-up, and the music
  continues where it stopped.
* **PAU1-2** The same in a Birth scene (after choosing a tribe in a new game, while a Birth animation plays) and at the
  title screen and the setup screens: no motion while the menu is open, no catch-up afterwards.
* **PAU1-3** The same in play (load CAE3540B.SAV or CHIEF.SAV, copied to your saves folder): with the menu open the
  game stands still (blinking units, animations, sounds); after it nothing hurries.
* **PAU1-4** PAU1-1..PAU1-3 in the DOS graphics (Ctrl+Shift+Backspace), in windowless play (Display > Windowless play)
  and in full screen (Alt+Enter): the same.
* **PAU1-5** Moving or resizing the window, and an open About box or exit warning (Cancel), also pause the game; the
  game's own menus (its menu bar in either graphics) work as before and do not pause it.
* **PAU1-6** The About box (window menu > About...) is titled "About Sid Meier's Civilization 64bit v1.2.1" and shows
  the link https://github.com/Buyukcaglar/Civ64, which opens that page in your browser.
* **PAU1-7** In Explorer, civ64.exe > Properties > Details shows File version 1.2.1.0 and Product version 1.2.1.
* **PAU1-8** This folder has no civ-winmenu-bg.png: in windowless play in the Windows graphics the drop-down menus
  still show your stone image behind them, as in the earlier builds that had the file.

## Expected changes at the build slot

* build.cmd checked: BUILD_OK (no new source file; civ64.rc gains RCDATA 2 from win64/civ-winmenu-bg.png).
* test.cmd checked: TESTS_OK; `w32_test_host_win32` PASS 530 (507 before); every other count, golden and section
  output unchanged (no portable source changed; headless back end unchanged); nodos NODOS_OK with one more file
  (the PNG) and the larger civ64.exe.
* ext_g1.py check: EXT_G1_OK runs 77 unchanged. Release BUILD_OK.
* P0 unchanged (Win32 back end and civ64 start-up only).

## Rebase notes

* Changed files: platform/win32/host_win32.c, platform/win32/host_win32.h, win64/civ64.rc, win64/civ64_main.c,
  tests/win32/test_host_win32.c, docs/FIDELITY.md, docs/RUNNING.md; new: win64/civ-winmenu-bg.png,
  docs/ext-PAU1-record.md. Bases in `build/pau1-stage/BASE-SHA256.txt`.

## Landing

* Copy-in 2026-10-22 13:38:04 UTC (`build/pau1-prep/landed-at.txt`, manifest `build/pau1-prep/landed.sha256`, the
  tree's former files in `build/pau1-prep/tree-before/`, predictions `build/pau1-prep/predictions.txt`).
* Cycle (`build/a43-prep/cycle.ps1 -Unit pau1`, `build/pau1-status.txt`): build.cmd checked BUILD_OK 13:42:35;
  test.cmd checked TESTS_OK 14:16:05 (`w32_test_host_win32` 530 checks, 507 before; every other PASS line as CUR1's;
  NODOS_OK); ext_g1 EXT_G1_OK runs 77 14:16:05 = ALL_GREEN; build.cmd Release BUILD_OK 14:19:49 = RELEASE_OK (UTC).
  As predicted.
* User build `build/user-builds/pau1/` (PAU1-1..PAU1-8): the Release civ64.exe (5,036,032 bytes, sha256
  17d17cd6dbd7c121651fb3132d99708cf65dbcb3750cdab21d59a44d878ff219), CAE3540B.SAV, CHIEF.SAV, MusicSfx.zip,
  CIVWIN.zip and civdos.zip from build "cur1", WHAT-TO-CHECK.txt; no civ-winmenu-bg.png.
* Back-out: copy `build/pau1-prep/tree-before/*` over the tree, delete `win64/civ-winmenu-bg.png` and this record,
  then build.cmd checked and build.cmd (Release).

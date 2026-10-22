# Extension unit ICO1 (the title bar's icon after a start in full screen) - record

## Result

civ64's window now carries the application icon (the user's civ-new icon, resource 1 of `win64/civ64.rc`) as its own
icon, not only as its window class's icon, and sets it again at every full-screen switch. Started in full screen (the
remembered setting or `--fullscreen`) and switched to windowed with Alt+Enter, the title bar shows the icon again.
Version stays 1.2.1. One file of the product changes (`platform/win32/host_win32.c`, with its header); one test grows
(`w32_test_host_win32` 530 -> 543).

## Status

Staged in `build/ico1-stage`, compiled in all three variants, `w32_test_host_win32` PASS 543 (Checked and Release
overlays), the fix seen on the real window. Landed with the three-step cycle and Release (see "Landing").

## The user's words

2026-10-22 about 14:25 UTC: "Build approved but there is one more bug fix that is not related to the build, it is
required to fix and then good to. Bug is; When the game launched in full screen, then returned back to windowed mode
after pressing alt+enter (host) application's icon is missing from title bar."

## Findings (the cause)

* Before: `hw_create_window_ex` gave the icon only to the window class (`WNDCLASSEXW.hIcon`/`hIconSm`, loaded at
  SM_CXICON and SM_CXSMICON). The window was created with WS_OVERLAPPEDWINDOW and, for a full-screen start,
  `hw_set_fullscreen(1)` changed its style to WS_POPUP (no caption, no window menu) before it was first shown.
  Leaving full screen (`hw_set_fullscreen(0)`) restored WS_OVERLAPPEDWINDOW with SWP_FRAMECHANGED and the placement.
* Observed on the real window (agent check; a private probe civ64 built from the tree's `host_win32.c` with its own
  settings root, a silent copy of the Windows data, `--multi-instance`, not activated, `--dos-data none`;
  `build/ico1-stage/obj/dbg/drive.py`, title bars captured with PrintWindow into `evidence-titlebars.png`):
  * started full screen, then the Full screen command (what Alt+Enter does): the title bar has the caption text but no
    icon - the user's report reproduced;
  * started windowed, then full screen, then windowed again: the icon is there through every switch;
  * WM_GETICON (ICON_BIG, ICON_SMALL, ICON_SMALL2) returned 0 in both cases (the window had no icon of its own; only
    the class had them, the same handles in both cases).
* So Windows takes the title bar's icon when the window is shown; a window first shown without a caption has none
  there, and the later style change does not take it again (Windows' rule is not documented; **inferred** from the
  observations). Remedies tried on the full-screen-started window after the switch (`obj/dbg/inject.py`,
  `remedies.png`, `remedies2.png`): RedrawWindow of the frame, SWP_FRAMECHANGED (also with SWP_SHOWWINDOW),
  SetWindowTheme, the dark title bar attribute again, WM_NCACTIVATE, clearing the WTNCA theme flags, no dark theme at
  all (`CIV64_NOTHEME`): no icon. Hiding and showing the window: icon. WM_SETICON with NULL and then the icons: icon.
  WM_SETICON with the handle the window already has: no change (the first fix attempt, which set the icons at the
  creation and at each switch without clearing, still showed no icon after a full-screen start).

## Design

* `app_icons_load` loads resource 1 once per run at SM_CXICON x SM_CYICON and SM_CXSMICON x SM_CYSMICON (the sizes
  the class icons had); the class gets the same handles.
* `app_icons_set(hwnd)`: WM_SETICON ICON_SMALL 0, ICON_BIG 0, then ICON_BIG and ICON_SMALL with the icons - a real
  change each time, so Windows takes them for the title bar again. Called right after CreateWindowExW (before the
  window is first shown, windowed or full screen) and at the end of every `hw_set_fullscreen` switch (both
  directions: Alt+Enter and the window menu's Full screen item go through it). A call without a switch (already in
  that mode) does nothing, as before.
* The icons are never destroyed (the class holds them; per-window icons are not destroyed by Windows).
* Tests: `hw_icon_sets()` counts the sets; `hw_set_icon_module(module)` lets the test program, which has no icon
  resource, take the icon from `civ64.exe` beside it loaded as a resource file (NULL: civ64.exe itself, the product).
* No core, rt, w16 or present change, no RNG draw, no `w16_present` added or removed (P0). DOS-free: no DOS byte.

## Deviations

None from the original game (the host window is civ64's own). The cause is observed, not documented (see Findings).

## Tests

* `w32_test_host_win32` (`tests/win32/test_host_win32.c` `test_ico1_host`, after `test_placement`): 530 -> 543
  checks (+13): civ64.exe loaded as a resource file; the window created full screen (a popup without a caption);
  WM_GETICON gives both icons (non-null, different, the system's large and small sizes) started full screen, after
  Alt+Enter to windowed (caption and window menu back), full screen again, windowed again; the same started windowed,
  through full screen and back; the icons cleared and set again exactly once per creation and per switch; no switch,
  no new set. On the base the icon checks fail (WM_GETICON gives 0, observed above; the base has no `hw_icon_sets`).
* Overlay (`build/ico1-stage/obj/mk.cmd`): Checked, CheckedNoObs and Release compiled with /W4 /WX;
  `w32_test_host_win32` Checked and Release PASS (543 checks, 0 failures).
* Real window (agent check): the fixed probe shows the icon in both start modes (`obj/dbg/evidence-titlebars.png`:
  rows base full, base windowed, fix full, fix windowed).
* `gen/dos/nodos.py check --root build/ico1-stage`: NODOS_OK; `gen/dos/registry.py check`: REGISTRY_OK (no present/dos
  file changes).

## For the records

* FIDELITY: F352 (new row, "the title bar's icon after a start in full screen"); F95 gets a one-sentence ICO1 note.
* RUNNING: the window-menu paragraph says the title bar keeps the icon after every switch, also after a full-screen
  start.
* DESIGN, FEATURES, DOS-PROFILE: unchanged.

## What the user checks

* **ICO1-1** Start civ64 from this folder in full screen (Alt+Enter once and close civ64 so that it remembers full
  screen, then start it again; or start it with --fullscreen), then press Alt+Enter: the window's title bar shows
  civ64's icon at its left, before "Sid Meier's Civilization 64bit".
* **ICO1-2** Press Alt+Enter a few more times (and use the window menu's Full screen item): every time the window comes
  back, the icon is in the title bar; started windowed, it is there as before.
* **ICO1-3** The same icon shows in the taskbar and in Alt+Tab in both start modes, and clicking the icon in the title
  bar opens the window menu as before.

## Expected changes at the build slot

* `w32_test_host_win32` 530 -> 543 checks; no other test count or golden changes (no present/core change).
* `ext_g1.py check`: unchanged (presentation not touched).
* P0 intact; coverage unchanged apart from the new host lines.

## Rebase notes

Base: the tree after PAU1 (`BASE-SHA256.txt`: host_win32.c 2318e106..., test_host_win32.c 765c1015...; host_win32.h,
FIDELITY.md and RUNNING.md as copied at 14:29 UTC). The edits are three insertions in host_win32.c (globals, the two
helpers before `hw_set_fullscreen`, the calls in `hw_set_fullscreen` and `hw_create_window_ex`), two declarations
in host_win32.h, the new test and its call in main.

## Landing

* Copy-in 2026-10-22 14:41:37 UTC (`build/ico1-prep/land.py --write`: host_win32.c, host_win32.h,
  test_host_win32.c, docs/FIDELITY.md, docs/RUNNING.md, new docs/ext-ICO1-record.md; `build/ico1-prep/tree-before`,
  `landed.sha256`).
* Cycle (`build/a43-prep/cycle.ps1 -Unit ico1`, `build/ico1-status.txt`): build checked BUILD_OK 14:45:59 UTC;
  test.cmd checked TESTS_FAILED=1 at 15:26:53 on one wall-clock bound only, test_crt's "a whole 3840x2160 client
  filtered in 352.0 ms (bound 120)" under the suite's parallel load (ICO1 changes no present/crt code; test_crt alone
  9.2, 10.8 and 12.2 ms, PASS 62; `w32_test_host_win32` PASS 543 in that run). Rerun as -r2: TESTS_OK 16:04:52
  (test_crt 45.5 ms PASS 62, `w32_test_host_win32` PASS 543), ext_g1 EXT_G1_OK runs 77 16:04:52 = ALL_GREEN; Release
  BUILD_OK 16:08:36 UTC = RELEASE_OK.
* Release `civ64.exe` 5,037,056 bytes, sha256 4293fea46183d281c972fd46512aa92200604e0a56866de355eeb7f8eb953a10.
* User build `build/user-builds/ico1/` (civ64.exe; CAE3540B.SAV, CHIEF.SAV, MusicSfx.zip, CIVWIN.zip, civdos.zip from
  pau1; WHAT-TO-CHECK.txt with ICO1-1..ICO1-3).

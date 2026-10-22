# Extension unit CUR1 (the torch cursor over the Windows graphics' menus) - record

## Result

* In the Windows graphics the menu bar and an open drop-down menu now always show the game's Windows torch cursor
  (the game's own cursor 129), windowed, full screen and in windowless play, also when the pointer comes from the
  World Map (plainly or dragging with the button held) and while a menu is open. Everywhere else the cursor is the
  game's own as before: the World Map's target inside the World Map, the map's torch and edge arrows, the busy
  cursor. The DOS graphics' pointer is unchanged.

## Status

Staged in `build/cur1-stage/` and landed at the build slot in one cycle (ALL_GREEN 12:46:54, RELEASE_OK 12:51:37 UTC) (see "Landing"); user checks CUR1-1..CUR1-5
pending (build `build/user-builds/cur1/`).

## The user's words

2026-10-22 about 11:40 UTC (verbatim, through the orchestrator): "crt6wl6 accepted a bug/revision not related to
crt6wl6 is the Windows Graphic menu shall display Windows torch cursor. Currently cursor stays on worldmap target
cursor while dragged from world map area."

## Findings (the cause)

* **The game chooses its cursor on mouse moves.** SetGameCursor (1098:09xx; `LoadCursor` of the module's cursor group
  0x80 + n, then `SetCursor`) is called from the game windows' WM_MOUSEMOVE handlers: the World Map's
  WdwSmMapProc case 0x200 -> SetSmMapCursor 1210:071D, cursor 130 (DOS-PROFILE C3, the "small-map pointer": the
  target); the Status window's TrackStatusWindowMouse 1218:06B9, cursor 129 (C2, the torch); the map window
  1208:14AA, 129, or near its edges 0x87 + direction, the scroll arrows 136..143 (C9..C16) (DOS listing not needed:
  Windows binary, the translated core).
* **Nothing changes it over the menus.** The menu bar is the main (map) window's non-client area: w16 routes a move
  there as WM_NCMOUSEMOVE with WM_SETCURSOR(HTMENU), and w16's DefWindowProc sets only HTCLIENT class cursors ("the
  arrow and sizing cursors of the frame are not modelled", `platform/w16/user_wnd.c`; Windows 3.1 would show the
  system arrow there, **inferred** from the SDK; F75). The menu loop holds w16's capture (`user_menutrack.c`), under
  which no WM_SETCURSOR is sent at all. So over the bar and the open popups the last game cursor stays: the World
  Map's target after the pointer left the World Map upwards (its caption is non-client too).
* **The drag.** The back end (`platform/win32/host_win32.c`) shows the game's cursor on Win32's WM_SETCURSOR(HTCLIENT)
  and when the game changes it (host_set_cursor). A press takes the host window's capture (the arrival stage's
  PI_CAPTURE_TAKE), and Windows sends no WM_SETCURSOR to a capturing window, so during a drag the host never chose a
  cursor at all; with a drag from the World Map the game also keeps receiving the World Map's own moves in windowless
  play (the press is latched to its part), which keep setting 130.
* **Real-game check** (a private debug civ64, never shipped: `build/cur1-stage/obj/dbg/`, the staged sources with
  host_log lines, its own settings folder `obj/dbg/userroot`, driven by a copy of `tests/win32/drive_civ64.py` with
  CAE3540B.SAV, `--multi-instance --dos-data none --music-sfx none`; log `obj/dbg/frames/c7-cur1dbg/debug.txt`): the
  torch's resource (cursor 129, 512 bytes) is seen at the start; after the load the kept area is the map window's
  bar (168,22)-(637,40); the pointer from the World Map onto the bar, plainly and dragging, chooses the torch and back
  on the World Map the game's cursor; a click on the bar's title at x 220 opens a popup, kept as (208,39)-(347,183)
  with the bar's visible part around it, the popup chooses the torch, the map below the game's cursor; Escape closes
  it and the kept areas return to the bar alone.

## The DOS graphics

Not the same bug, not changed. The DOS graphics show their own pointer (`present/dos/pdos_cursor.c` `pointer_for`):
the game's cursors 129, 130 and 134 all give the DOS torch (DOS-PROFILE C2, C3, C7), so the World Map's target never
appears there and a drag from the DOS World Map onto the DOS menu bar shows the torch already. Recorded, not
verified at run time: the map's edge arrows 136..143 keep the game's own cursor in the DOS graphics too (C9..C16), so
after the pointer leaves the map at its top edge an arrow could stay over the DOS menu bar; that is another case than
the user's and is left as it is (an open item, below).

## Design

* **present/present.c, present.h** (the menu areas and the torch; presentation only):
  * `menu_read` (inside the observer's guard: at every core present and at the ticks, at most every 8 ms of host
    time): while the Windows graphics are visible, the frame rectangles of each shown top-level window's menu bar
    (`w16q_menu_bar`) within its visible region (`w16q_wnd_vis`), and of the popups open in the menu loop
    (`w16q_menu_state` levels 1..depth); kept with a generation that changes when they change. The reads start at
    the back end's first `present_menu_at`; a run without such a host (every harness run) reads nothing.
  * `present_cursor` keeps the torch: when the game's new cursor is the module's cursor 129 (`w16q_cursor`), its
    RT_CURSOR bytes (living for the run).
  * `present_menu_at(hx, hy)`: 1 when the client point shows a menu area of the Windows graphics: through
    `present_view_point_part` (the layout, the windowless canvas's parts), the canvas's bar piece (with its filled
    width beyond the bar) or a frame point inside a kept area (a popup float, the bar); 0 elsewhere, outside the image,
    for the DOS graphics, during the Birth synchronisation's view and under CIV_OBSERVER 0 (no reads).
    `present_menu_cursor`, `present_menu_gen`; `present_menu_test` for the tests.
* **platform/win32/host_win32.c, host_win32.h** (what the back end shows):
  * `cursor_at`: the torch (made from the kept resource at the game cursor's factors, `torch_cursor`; `res_cursor`
    is the former body of `make_cursor`) when the point is over a menu area, else the game's cursor; a hidden cursor
    stays hidden; a profile's own pointer (the DOS graphics) is never replaced.
  * Applied on WM_SETCURSOR(HTCLIENT) (as before, with the choice), on every WM_MOUSEMOVE and button message when the
    choice changes (this covers the capture of a drag and the menu loop, where no WM_SETCURSOR comes), on a resize's
    new factors (`refresh_cursor`), and after each message pump when the kept areas' generation changed (a menu
    opened or closed under a still pointer, `cursor_menu_check`). `host_set_cursor` (the game changed its cursor,
    called inside the presentation) keeps the torch when the back end last showed it for a menu area, without asking
    the presentation again. `hw_menu_cursor`, `hw_menu_cursor_shown` for the tests.
* **P0**: no core call, no RNG draw, no `w16_present` added, removed or delayed; the game's cursor (SetCursor's state),
  its input events (the same points, the latch unchanged), the menu loop and the World Map's own cursor are
  unchanged; only what the host window shows over the menus changes. The observer reads are read-only (`obs_lint`
  OK).

## Deviations

1. The torch over the menus is the user's choice; Windows 3.1 would show its system arrow over the menu bar
   (**inferred**), and the port before CUR1 showed whatever the game last set. F348.
2. The popups' shadows are not menu areas (the cursor there is the game's), nor are the other frames' parts (captions,
   borders, scroll bars), which keep the last game cursor as before.

## Tests

* `tests/test_wl.c` 125 -> 150 checks, `cur1()`: windowed at 2x, the bar, its corners, beside it, a popup and its top
  row, the map and the World Map; a press on the World Map latched and dragged onto the bar and into the popup (the
  game gets the same moves as before, the choice is the torch), back on the World Map, the release; the popup closed
  (a new generation, its place the game's cursor); on the windowless canvas the bar piece, its filled width, the
  popup float, the map and World Map pieces, a press on the World Map piece dragged onto the bar (the move goes
  through the World Map's part as before, the choice is the torch) and into the popup; the tests' areas gone.
* `tests/win32/test_host_win32.c` 495 -> 507 checks, `test_cur1_host` (after `test_window_s2`): through the window
  procedure at 1280 x 960: no torch before cursor 129; a press on the World Map, moves under the capture onto the bar
  and into a popup show the torch (`GetCursor()` the torch, no WM_SETCURSOR involved), the game setting its cursor
  meanwhile keeps the torch, on to the map the game's cursor again, released over the bar; the game's events are the
  press, the moves and the release at their frame points as before; the menu gone, the game's cursor; a hidden game
  cursor not replaced.
* **On the base**: both tests use the new functions (`present_menu_at`, `present_menu_test`, `hw_menu_cursor`), so
  they cannot be built against the base; the base's behaviour is the cause above (no cursor choice under the capture,
  none over HTMENU), confirmed by the real-game debug run's choices.
* Private overlay (`build/cur1-stage/obj/mk.cmd`; tree objects + the staged present.c (c11 and c17) and
  host_win32.c, /W4 /WX): Checked and Release test_wl 150 PASS, w32_test_host_win32 507 PASS; CheckedNoObs compiled.
  `obs_lint.py` on a mirror with the staged present files: OBS_LINT_OK.

## For the records

* FIDELITY: F348 - applied in this unit.
* DESIGN (the cursor route 8.5: the menu areas' torch), RUNNING (the cursor over the menus), FEATURES: left to the docs
  pass. DOS-PROFILE unchanged.

## What the user checks

* **CUR1-1** Windows graphics, windowed, in a game (load CAE3540B.SAV or CHIEF.SAV from this folder): move the pointer
  over the World Map (the target cursor), then straight up onto the menu bar at the top. On the menu bar the cursor is
  the game's torch, not the target. Back on the World Map it is the target again.
* **CUR1-2** The same with the button held: press the left button on the World Map and, holding it, drag onto the menu
  bar and along it. The cursor becomes the torch on the bar (before, the target stayed). Release there, and also try
  releasing back on the World Map: the World Map does what it did before.
* **CUR1-3** Open a menu by clicking a title of the menu bar (for example Orders or Advisors) and move the pointer over
  the open drop-down menu: the torch. Open one by pressing on a title and dragging down into its items with the
  button held: the torch over the bar and the menu. Do this right after coming from the World Map, too. Off the menu
  (over the map) the cursor is the game's own as before; after the menu closes the cursors are as before.
* **CUR1-4** Windowless play (Display > Windowless play) and full screen (Alt+Enter): the same as CUR1-1..CUR1-3 on
  the top bar (also its part right of the last title) and in its drop-down menus.
* **CUR1-5** Unchanged: inside the World Map the target cursor, on the map the torch and the arrows at its edges, the
  busy cursor; the DOS graphics' pointer (Ctrl+Shift+Backspace) is as before, also on the DOS menu bar.

## Expected changes at the build slot

* test_wl 125 -> 150 and w32_test_host_win32 495 -> 507 in Checked; every other count and golden unchanged (the menu
  areas are read only after a Win32 host asked, so no harness run reads them; the cursor trace is unchanged). P0
  unchanged (presentation only). ext_g1 runs 77 unchanged. No new source files; build.cmd and test.cmd unchanged.

## Rebase notes

Bases: `BASE-SHA256.txt` (the tree's present/present.c, present.h, platform/win32/host_win32.c, host_win32.h,
tests/test_wl.c, tests/win32/test_host_win32.c and docs/FIDELITY.md on 2026-10-22, equal to CRT6/WL6's landed
files). Code edits: anchored replacements in the stage (LF kept). FIDELITY: F348 appended. Private tools:
`obj/mk.cmd`, `obj/rsp.py`, `obj/dbg/` (the debug civ64 and its drive; never staged).

## Landing

CUR1 landed at the build slot on 2026-10-22 (times UTC), in one cycle.

* **Bases** as staged (the tree unchanged since CRT6/WL6). `build/a43-prep/land.py cur1` dry run `DRY_RUN_OK 6`;
  copy-in 12:08:24 (present/present.c, present.h, platform/win32/host_win32.c, host_win32.h, tests/test_wl.c,
  tests/win32/test_host_win32.c; LF as the tree; `build/cur1-prep/landed.sha256`, `tree-before/`, the Checked test
  outputs before in `before/`), then docs/FIDELITY.md (F348) after its base check (`FIDELITY.before.md`) and this
  record.
* **The cycle** (`build/a43-prep/cycle.ps1 -Unit cur1`, `build/cur1-status.txt`): 1 `build.cmd checked` BUILD_OK
  12:08:29..12:12:58; 2 `test.cmd checked` TESTS_OK 12:12:58..12:46:53 (test_wl PASS 150, w32_test_host_win32 PASS
  507, golden unchanged, obs_lint OK, nodos 0 hits); 3 `ext_g1.py check` EXT_G1_OK runs 77 (its standing "amended 1"
  note): **ALL_GREEN** 12:46:54; 4 `build.cmd` (Release) BUILD_OK 12:46:54..12:51:37: **RELEASE_OK**.
* **Against the predictions** (`build/cur1-prep/predictions.txt`): as predicted. Of the Checked test outputs only
  informational lines changed (`build/cur1-prep/after/`): nodos 1883 -> 1884 files (0 hits), timeline-partitions'
  host timings.
* **User build** `build/user-builds/cur1/` (CUR1-1..CUR1-5): the Release civ64.exe (5,024,768 bytes, sha256
  4e6e0ead...c7c80c7e521aeac165a2639d0831bc278b), CHIEF.SAV,
  CAE3540B.SAV, MusicSfx.zip, civ-winmenu-bg.png, CIVWIN.zip and civdos.zip from build "crt6wl6", WHAT-TO-CHECK.txt.
  FIDELITY F348.
* **Back-out**: `build/cur1-prep/tree-before/` over the tree, docs/FIDELITY.md from `FIDELITY.before.md`, delete
  this record, then `build.cmd checked` and `build.cmd`.

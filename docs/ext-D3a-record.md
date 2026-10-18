# Extension phase D3, unit D3a (the observer core) — record

Prompt: `claude/docs/x64-port-scaling-dos-prompt.md`, phase D3 (section 9): "Observer, probes and
presentation tick in `w16`; composition; profile switching (...); the P0 test runner and the 7.8 harness
mode." Gate: "7.3 (without zoom) and 7.4 pass with switching; probe verification recorded." D3 is done
in two units; this record is D3a's (the observer core). D3's gate is D3b's and is recorded in
`ext-D3-acceptance.md`, which links this record. Session D3a, 2026-10-11. Brief:
[verify/BRIEF-d3.md](verify/BRIEF-d3.md). Design: [verify/ext-d1-draft-A.md](verify/ext-d1-draft-A.md)
(revision 3) sections 2..7, 9, 13.3, 13.4, with [verify/ext-d1-decisions.md](verify/ext-d1-decisions.md)
and DESIGN.md 12.5, 12.10, 12.11. Probe verification:
[ext-D3-probe-verification.md](ext-D3-probe-verification.md).

Labels: **compiled** (the three language checks and `/W4 /WX`), **headless** (test programs and the
harness on `build/gamedata`), **Win32-headless** (the Win32 back end without a visible window). No DOS
program was executed; nothing was written to `C:\Projects\Civ1RE\dos` or `build/dosdata`; no UI was
shown; civ64.exe was not started. Asan was not built or run (deferred by the user, 2026-10-10 21:20).

## What was built

* **The probe table and the hooks** (`platform/w16/vm.h`, `vm.c`; draft A 4.1, 4.2). `CIV_OBSERVER`
  (default 1 in `vm.h`; 0 compiles the observer out). `vm_probe_install` / `vm_probe_count`: open
  addressing over 2,048 slots with at most 256 keys (`VM_PROBE_MAX`), keyed by `FrameDesc.addr`, hash
  `(addr * 2654435761u) >> 21`, linear probing; -1 and an empty table on more than 256 keys, address 0,
  a duplicate or a NULL function. The entry hook runs at the end of `fr_enter` (the frame complete; `ra`
  as stored: full for a far return, the offset for a near one); the exit hook is the first statement of
  `fr_leave`, before `vm_site` and the control stack are restored and before any pop (`ra` from the
  control stack, 0 beyond its depth). A run without keys pays one load and one branch per frame.
  Checked forbid checks (`W16_OBS_FORBID`, active only inside the observer's guard) in
  `vm_api_enter`, `vm_step`, `acc_chk`, `vm_resolve` (writes), `vm_block_alloc`, `fr_enter` and
  `fr_leave`; the Checked sentinel's counters `vm_obs_writes` (every emulated write) and
  `vm_obs_allocs` (every selector and handle allocation).
* **The w16 side** (`platform/w16/w16_obs.h`, `w16_obs.c`; draft A 3, 5, 6.1, 7.1). The emission
  macros `W16_OBS_*` (empty under `CIV_OBSERVER 0`) and the event builders `w16_obs_*` (an event
  carries `t_us = w16_clock_us()`); `w16_obs_draw_init` (an `ObsDraw` with the DC's state now: colours,
  background mode, alignment, font, brush, pen, ROP2) and `w16_obs_rect32` (a clamped rectangle). The
  guard `w16_obs_begin(in, id)` / `w16_obs_end()`: one level; in Checked a nested call faults
  ("O4: probe re-entry" / "O4: observer re-entry") and the sentinel compares `vm_steps`, `vm_site`,
  the registers, the clock, the queued input and the write and allocation counters before and after
  every observer call ("O4 sentinel: <what>"); in Release a nested call is dropped and counted.
  `W16_OBS_FORBID(what)` / `W16_OBS_FORBID_ALLOC(what)` fault "O4: <what>" in Checked while the guard
  is held, at the sites above and at `w16_target_done`, `w16_screen_dirty`, `w16_present`, input
  posting, `PostMessage`, the key state, the focus change, `SetCapture`, `ReleaseCapture`, the clock
  advance and the handle pool (`hpool_alloc`). The probe hook (`probe_hook` → `obs_probe`, with the
  argument base of draft A 4.2 for BP and `FR_NONE` frames). `W16_TICK()` at the four sites of draft A
  7.1 (queue.c `w16_PeekMessage`, clock.c `w16_GetTickCount` before the poll's cost, dos.c INT 21h
  AH=2Ch, user_cursor.c `w16_SetCursor`), each right after `w16_present(0)`, calling `w16_obs_tick` →
  `obs_tick` inside the guard: empty until D3b fills it. The read-only queries of draft A 5.1
  (`w16q_now_us`, the readers `w16q_rd8/16/32`, `w16q_read` (follows the tiles of a huge block),
  `w16q_strn`, the argument and return readers, `w16q_block`, the window, control, menu-state, GDI,
  screen, system-palette and cursor queries, `w16q_diag`) and `w16q_obs_start` (installs a table and
  clears the diagnostics). Readers give 0 for an address the emulation would fault on and for
  `g_randSeed` 1420:4EE0..4EE3, counted in `W16qDiag`. The five queries of draft A 5.2 that belong to
  M and D4 (`w16q_sys_track`, `w16q_draw_on`, `w16q_msgbox`, `w16q_menu_item`, `w16q_menu_bar`) are
  not D3a's.
* **Read-only module accessors** under `#if CIV_OBSERVER` for the queries over file-static state
  (draft A 5.3, Open A7): `w16_wnd_info`, `w16_wnd_vis`, `w16_wnd_client_vis_obs`, `w16_wnd_desktop`
  (user_wnd.c),
  `w16_btn_info`, `w16_edit_info` (user_ctl.c), `w16_lb_info`, `w16_lb_text` (user_listbox.c),
  `w16_menu_track_info` with the pointer to the running loop `g_obs_mt` (user_menutrack.c),
  `w16_cursor_info` (user_cursor.c). See the deviations.
* **The O1 emission sites** (draft A 3.3, Open A2 settled; the full list with the matrix counts is
  below): gdi_draw.c (FILLRECT, FRAMERECT, LINE, POLYLINE, POLYGON, SETPIXEL, BITBLT), gdi_font.c
  (TEXTOUT, DRAWTEXT), gdi_dc.c (`OBS_BITMAP` damage in `w16_target_done`), gdi_pal.c
  (`OBS_SCREEN_DAMAGE` in `w16_screen_dirty`, REALIZE, ANIMATE), gdi_obj.c (bitmap create, bits,
  delete; palette select and set), user_wnd.c (create, destroy, show, hide, rectangle, z-order,
  activate, focus, text, enable, screen size, NC_PAINT and EXPOSE), user_dlg.c (dialog create),
  user_ctl.c (CTL_PAINT, pressed, edit text and selection), user_listbox.c (insert, delete, reset,
  select, top), user_menutrack.c (track start and end, open, highlight, close, MENU_PAINT),
  user_syscmd.c (NC_PAINT of the outline; `OBS_SYS_TRACK` start and end), user_cursor.c (cursor),
  user_misc.c (sound, beep).
* **The presentation side** (`present/observe.h`, `observe.c`; draft A 3.1, 4.2): the event and probe
  types (`ObsEvent`, `ObsDraw`, `ObsProbe`, `OBS_*`, `OBS_OP_*`), `obs_init` (resets the listeners,
  the hit and event counts, installs the 203 keys through `w16q_obs_start`), `obs_listen` (at most
  `OBS_LISTENERS_MAX`, called in registration order), `obs_event`, `obs_probe` (fills `ObsProbe`:
  phase, `far_ret`, address, `ra`, the matching call-site row, `t_us`, the argument base; counts;
  dispatches), `obs_tick` (empty until D3b), `obs_probe_hits`, `obs_event_count`, `obs_callsite`,
  `obs_callsite_in` (the same search over a caller's table, for tests), `obs_probe_phases` and the
  empty marker `OBS_AT_EXIT`.
* **The generated tables** `present/obs_tables.h`, `obs_tables.c` (Open A1 settled: generated) by
  `gen/obs_tables.py` (`--check`, `--report`): 203 keys (`OBS_PROBES[]`, `OBS_P_<Name>` row
  constants, `OBS_NPROBES`) and 98 call-site rows (`OBS_CALLSITES[]`), each key and row verified in
  [ext-D3-probe-verification.md](ext-D3-probe-verification.md).
* **The static check** `tests/harness/obs_lint.py` (draft A 6.2; the checks that apply without B, C
  and D code; the consumer-table checks activate as those tables appear, see the deviations).
* **The tests** `tests/test_observer.c` (draft A 13.4; see "Test counts").
* **The build variant** `checked noobs` (`build.cmd checked noobs`, `test.cmd checked noobs`;
  `CIV_OBSERVER=0`; `build\x64\CheckedNoObs`, `build\obj\CheckedNoObs`, harness runs under
  `build\harness\CheckedNoObs`); `test.cmd` runs the rule 6.6 UNINIT step in Checked and
  CheckedNoObs, `obs_tables.py --check` and `obs_lint.py` in every variant; `scenarios.py` and
  `p4tests.py` accept the variant.
* **The harness** (`tests/headless/harness.c`, `harness.h`, `harness_main.c`): `obs_init` after
  `present_reset` and before the core starts; the guard reset after the run's longjmp; at the end of
  every run `<out>/observer-probes.log` (each key's phases and entry/exit hits, the events by type) and
  `<out>/presentation-diag.log` (`W16qDiag`); neither is `run.log`, `events.log` or `presented.log`.
  `--probes 0` leaves the table empty (Open A5's comparison, informational).
* **civ64** (`win64/civ64_main.c`): `obs_init()` after `w16_host_start` and before the game runs
  (draft A 4.1, RV1-11); a refusal ends with "The presentation observer could not be set up."

Files (under `claude/port`). New: `platform/w16/w16_obs.h`, `w16_obs.c`; `present/observe.h`,
`observe.c`; `present/obs_tables.h`, `obs_tables.c` (generated); `gen/obs_tables.py`;
`tests/harness/obs_lint.py`; `tests/test_observer.c`. Changed: `platform/w16/vm.h`, `vm.c`, `clock.c`,
`dos.c`, `handles.c`, `queue.c`, `rgn.c`, `gdi_dc.c`, `gdi_draw.c`, `gdi_font.c`, `gdi_obj.c`,
`gdi_pal.c`, `user_ctl.c`, `user_cursor.c`, `user_dlg.c`, `user_listbox.c`, `user_menutrack.c`,
`user_misc.c`, `user_syscmd.c`, `user_wnd.c`; `tests/headless/harness.c`, `harness.h`,
`harness_main.c`; `tests/harness/scenarios.py`, `p4tests.py`; `win64/civ64_main.c`; `build.cmd`,
`test.cmd`; the two documents of this unit. (`build.cmd` rewrites its generated files, such as
`core/gen/civ_api.c` and `docs/API-MAP.md`, on every build; their content is not D3a's.)

## Acceptance items

| Item | Method | Result |
|---|---|---|
| Builds | `build.cmd checked`, `build.cmd checked noobs`, `build.cmd` (strict C17/x64, `/W4 /WX /permissive-`; the 241 portable sources also `/std:c11`, `/std:c17` and the clang-tidy C99 parse) | compiled: BUILD_OK Checked (2026-10-11 11:22:56..11:25:41 UTC), CheckedNoObs (11:31:41..11:34:39 UTC), Release (11:41:05..11:43:57 UTC) |
| Base tests | `test.cmd checked`, `test.cmd checked noobs` (every base test program, gate 3b references and repeats, the stub-core harness runs, scenarios, UNINIT, phase-4 scenarios and tests, D2's checks, TRACE, coverage), `test.cmd` (Release: the test programs, the Win32-headless tests, D2's checks, TRACE) | TESTS_OK Checked (11:25:41..11:31:26 UTC), CheckedNoObs (11:34:39..11:40:39 UTC), Release (11:43:57..11:44:31 UTC); every other test program's count equal in Checked and CheckedNoObs |
| G-1 (P0) | `ext_g1.py check` after `test.cmd checked`; `ext_g1.py check --variant CheckedNoObs` after `test.cmd checked noobs` (core frame lines, snapshot and result lines and `events.log` of the 77 runs against the pre-extension baseline) | **EXT_G1_OK runs 77** on Checked (11:31 UTC) and on CheckedNoObs (11:40 UTC; all 77 outputs newer than the CheckedNoObs build, none with an observer log) |
| P0 with and without the table | soak S4 (load `CAE3540B.SAV`, Space/Enter every 500 ms to the game's end: 63,877,031 steps, 392.5 s virtual, 4,085 frames) four times each in Checked with the table, in Checked with `--probes 0` and in CheckedNoObs | the 12 runs' core frame lines, snapshot and result lines and `events.log` are identical (one digest) |
| Tables (Open A1) | `obs_tables.py --check` in `test.cmd`; showfunc on every row | `OBS_TABLES_OK probes 203 sites 98` in every variant; `SHOWFUNC probes 203 sites 98 mismatches 0` |
| Static check (6.2) | `obs_lint.py` in `test.cmd` | `OBS_LINT_OK files 27 probes 203 callsites 98` in every variant |
| Probe verification (6.3) | [ext-D3-probe-verification.md](ext-D3-probe-verification.md) | recorded: 203 keys and 98 rows verified; hits of 81 runs (192 keys hit); 11 keys never hit, listed; the queries, accessors and hook reviewed independently, three findings fixed |
| O4 (6.1, 6.4) | `test_observer` (Checked: eleven trap cases, the sentinel, probe stepping; Release: a nested event dropped, a nested table refused; the spin test in both) | PASS (see "Test counts") |
| No DOS bytes | `nodos.py check` in `test.cmd` | NODOS_OK in every variant |
| Cost (Open A5) | `test_observer`'s timing loops (Checked, Release); soak S4 wall time (see "Cost") | measured, informational |
| Asan | — | **deferred** (the user's direction 2026-10-10 21:20) |

### Test counts

| Program | Checked | CheckedNoObs | Release |
|---|---|---|---|
| `test_observer` | PASS 103 checks, 0 failures | PASS (1 check: the observer is compiled out) | PASS 92 checks, 0 failures (the Checked-only trap, sentinel and record cases excluded) |

The other test programs gave the same counts as in D2's runs (`build/d2-test-checked.log`,
`d2-test-release.log`), CheckedNoObs as Checked (for example `test_user` 319, `test_present` 477,
`test_gdi` 95, `test_queue` 117, `test_vm` 66 / 51 in Release, `test_host_win32` 148). Logs:
`build/d3a-build-*.log`, `d3a-test-*.log`, `d3a-g1-*.log`, `d3a-a5.log`.

### Cost (Open A5)

Timing loops of `test_observer` (2,000,000 iterations each; ns per call; the final runs, with the
range of earlier runs of the same day in brackets):

| | Checked | Release |
|---|---|---|
| an event, no listener | 26.3 [26.1] | 6.5 |
| an event, one no-op listener | 26.5 [26.5..27.8] | 8.1 |
| `fr_enter` + `fr_leave`, no table | 49.4 [49..68] | 32.1 |
| the same with the 203-key table, a miss | 50.9 [47..54] | 32.9 |
| the same with a hit at both phases (two hook calls, no probe listener) | 118.5 [115..118] | 71.7 |

So a miss costs nothing measurable over the frame pair (draft A 4.2 estimated 1 to 2 ns), a hit about
20 ns (Release) or 35 ns (Checked) per hook, and an event 6.5 ns (Release), well under draft A 3.3's
"under 50 ns".

Soak S4 (draft A 16 A5 asks for Release; `build.cmd` builds the harness only for the Checked variants,
so the soak ran in Checked and CheckedNoObs, see the deviations). S4 makes 284,300 events and 944,229
entry and 671,969 exit hook calls. Wall time in seconds, four passes alternating the three modes
(2026-10-11 about 11:45..11:49 UTC; the first pass was slower in every mode, a warm-up):

| Mode | Pass 1 | Pass 2 | Pass 3 | Pass 4 | Median of 2..4 |
|---|---|---|---|---|---|
| Checked, the 203-key table | 18.16 | 16.50 | 16.36 | 16.31 | 16.36 |
| Checked, `--probes 0` (no table) | 17.43 | 16.35 | 16.55 | 16.42 | 16.42 |
| CheckedNoObs (observer compiled out) | 16.56 | 16.18 | 16.16 | 16.26 | 16.18 |

The observer as a whole (events, hooks, the table) costs about 0.2 s of 16.2 s (about 1 %); the table
alone is below the run-to-run spread (about 0.2 s). Informational, as A5 asks; nothing depends on it.

### Events in the runs (Open A2)

The events by type, summed over the 81 `observer-probes.log` files of the final Checked run
(2026-10-11 11:25..11:31 UTC, every log newer than the build; the earlier run of 11:03..11:09 UTC gave
the same counts):

| Type | Count | Type | Count |
|---|---|---|---|
| `OBS_WND_CREATE` | 3,211 | `OBS_MENU_TRACK` | 202 |
| `OBS_DLG_CREATE` | 490 | `OBS_MENU_OPEN` | 120 |
| `OBS_WND_DESTROY` | 2,927 | `OBS_MENU_HILITE` | 368 |
| `OBS_WND_SHOW` | 3,214 | `OBS_MENU_CLOSE` | 120 |
| `OBS_WND_HIDE` | 2,500 | `OBS_SYS_TRACK` | 4 |
| `OBS_WND_RECT` | 2,988 | `OBS_DRAW` | 993,996 |
| `OBS_WND_ZORDER` | 3,237 | `OBS_SCREEN_DAMAGE` | 490,080 |
| `OBS_WND_ACTIVATE` | 1,197 | `OBS_BITMAP` | 986,411 |
| `OBS_FOCUS` | 1,641 | `OBS_PAL_ANIMATE` | 21,907 |
| `OBS_WND_TEXT` | 3,274 | `OBS_PAL_REALIZE` | 0 (see the deviations) |
| `OBS_WND_ENABLE` | 26 | `OBS_PAL_SELECT` | 966 |
| `OBS_CTL_CHECK` | 0 (no site, A2) | `OBS_PAL_SET` | 70 |
| `OBS_CTL_PRESSED` | 122 | `OBS_CURSOR` | 1,154 |
| `OBS_LB` | 366 | `OBS_SOUND` | 563 |
| `OBS_EDIT` | 70 | `OBS_BEEP` | 2 |
| | | `OBS_SCREEN_SIZE` | 1 |

`test_observer` emits every type with a site, `OBS_PAL_REALIZE` included, through the w16 fixtures.

## Deviations from the design

| Design | What | Why |
|---|---|---|
| DESIGN.md 12.10; A 5.1, 5.3, Open A7 | **12.10's list is widened** by read-only accessors under `#if CIV_OBSERVER`: user_wnd.c `w16_wnd_info`, `w16_wnd_vis`, `w16_wnd_client_vis_obs`, `w16_wnd_desktop`; user_ctl.c `w16_btn_info`, `w16_edit_info`; user_listbox.c `w16_lb_info`, `w16_lb_text`; user_menutrack.c `w16_menu_track_info` with the observer-only pointer `g_obs_mt` (set when the loop's state is complete, cleared before it is freed); user_cursor.c `w16_cursor_info` | the queries' window, control, list-box, menu-loop and cursor state is file-static and has no getter (A7: no existing getter can be reused for it). The accessors only copy (reviewed, [probe verification](ext-D3-probe-verification.md) 4, 5), follow 5.2's `w16_msgbox_info` pattern and are compiled out with the observer |
| DESIGN.md 12.10; A 5.3 | **12.10's list is widened** by `rgn.c`: inside the observer's guard a region over `W16_RGN_MAX` rectangles is counted in `W16qDiag.rgn_overflows` instead of logged | review finding 1: a query reaching `rgn.c`'s overflow would call `host_log`, which 5.3 forbids; the emulation's own overflows are logged as before |
| A 5.1 | `w16q_wnd_vis` and `w16q_wnd_client_vis` give an empty region (0) for a window being destroyed; `w16q_wnd_client_vis` calls the new accessor `w16_wnd_client_vis_obs`, not `w16_wnd_client_vis` directly | review finding 2: `free_tree` emits `OBS_WND_DESTROY` after a window's children are freed, and `vis_region` would follow the freed child list. The emulation's `w16_wnd_client_vis` is unchanged |
| A 4.1 | `w16q_obs_start` returns -1 inside the observer (Checked: "O4: w16q_obs_start") | review finding 3: a call from a handler would reset the guard depth and change the table during a run (4.1: never) |
| A 3.3 `OBS_DLG_CREATE` | emitted after the template's controls are created, before WM_INITDIALOG (user_dlg.c), not at the `W16_TRACE("dialog")` line | that trace precedes the control loop; the table's own condition "children created" needs the later point |
| A 3.3 `OBS_WND_CREATE` | emitted when the record is complete, just before it is linked into the z-order (`link_top`/`link_bottom` then emit `OBS_WND_ZORDER`), before WM_CREATE | a listener meets the window before the z-order event that names it |
| A 3.3 `OBS_WND_DESTROY` | emitted in `free_tree` for each window (children first) while its record exists; `free_tree` and `w16_DestroyWindow` also emit `OBS_FOCUS` and `OBS_WND_ACTIVATE` where they clear the focus and the active window without `set_focus_raw`/`activate` | `free_tree` is where each record is freed ("before its record is freed"); the silent clears are state changes a profile tracks |
| A 3.3 `OBS_CTL_CHECK` (Open A2) | no emission site; the type is kept | w16's `BM_SETCHECK` does nothing and `BM_GETCHECK` returns 0 (user_ctl.c): no button keeps a check state, so there is no change to report. The other A2 points: `OBS_EDIT` after `edit_replace` (text) and after every selection or caret change in `edit_proc`; `OBS_LB` after insert, delete, reset, `user_select`, `LB_SETCURSEL` and every change of the top item (`OBS_LB_TOP`, an added kind, from the list box's own layout) |
| A 3.3 `OBS_PAL_REALIZE` | only when RealizePalette changed physical entries (`count` = the entries changed), at the existing trace, before `w16_present(1)` | "after the entries changed": a realize that changes nothing makes no trace and no present. No base run changes an entry by realizing (also no "realize" line in any `events.log`); `test_observer` covers the event |
| A 3.3 `OBS_DRAW` DRAWTEXT | no event for `DT_CALCRECT` | it draws nothing |
| A 3.2 | `ObsEvent.u.bmp` gains `hdc` (the memory DC of a damage, `CreateDIBitmap`'s DC); `ObsDraw.rop2` is always 13 (R2_COPYPEN); `OBS_POLYLINE`/`OBS_POLYGON` copy at most `OBS_PTS_MAX` (256) points, read with `w16q_rd16` (non-faulting) | a profile maps a damaged bitmap to its DC without a query; w16 has no SetROP2; a bounded stack copy |
| A 3.2, 3.3 | `OBS_SYS_TRACK` (marked M) is emitted in D3a (start after the first outline, end after the last; `u.menu.r` the outline rectangle) | the site is in user_syscmd.c beside D3a's NC_PAINT emission; M adds `w16q_sys_track` |
| A 5.3 | `W16qDiag` gains `dropped`, `rgn_overflows` and `nlast` | the Release guard's drops and finding 1's count; the ring of the last 16 needs its count |
| A 5.3 | Win32 does not yet write the diagnostics to the debug log | civ64's presentation is D3b's (the tick and the profiles); the harness writes `presentation-diag.log` |
| A 6.1 | `W16_OBS_GUARD_BEGIN(in, id)` takes the kind (event, probe, tick) and the event type or probe id; the depth is kept in Release too (a nested call is dropped and counted) | the sentinel's fault names the event or probe; 6.1's "dropped in Release" needs the depth |
| A 6.1 | the sentinel compares the queued input count (`w16_queue_input_count`), not a queue write index; one counter `vm_obs_allocs` counts handle and selector allocations | the queue is an array with insertion and removal and has no write index; every posting path also has a forbid check |
| A 4.2 | `obs_callsite_in(rows, n, callee, ra)` added beside `obs_callsite` (the same search over a caller's table) | the near-callee comparison is tested on synthetic rows; the generated table has no near key (Open A6) |
| A 6.2 | `obs_lint.py`: the `#include "w16_obs.h"` / `"w16_int.h"` lines of `present/` are exempt from the `w16_` rule; `PdosMacro` and `PdosSceneRow` initialisers make the lint fail until it is extended to read them (their field layouts are B's and D's); the DESIGN.md/TRACE.md row check activates when a "\| observer probe \|" row exists | the observer's types are declared there; the lint cannot know a future struct's fields, so a consumer table cannot pass unchecked; the rows do not exist yet (see "For the records") |
| A 4.3, Open A1 | the tables are separate generated files `present/obs_tables.h`/`.c` (not inside `observe.c`), with `OBS_P_<Name>` row constants; `obs_tables.py --check` runs in `test.cmd` | generated, never typed (A1); the row constants serve `OBS_AT_EXIT(OBS_P_<Name>)` and the lint |
| A 6.4 | the spin test runs headless: a GetTickCount loop with a probe on a callee and an event per iteration gives the same `vm_steps` and clock as without them, which is what classifies each query | `host_sync.c`'s Win32 classification is driven by those two values; no Win32 window is needed |
| A 16 (A5), 4.2 | the harness gained `--probes 0` (an empty table) for the soak comparison; the soak S4 ran in Checked (with and without the table) and CheckedNoObs, not Release; Release's cost is the timing loops' | A5 asks for the wall time with and without the table, and nothing else installs or removes it; `build.cmd` builds `civ_harness.exe` only for the Checked variants (Release has no harness) |
| A 7.2 | `obs_tick` is empty | D3b fills it (`present_tick`) |
| A 8.5, 10 | `present_cursor`, `host_set_cursor_pixels`, `HostEvent.frame`, `host_sync.c`'s hooks are not changed in D3a | D3b's (BRIEF-d3) |

Behaviour-equivalent restructurings for the emission points (G-1 shows no change): `w16_screen_dirty`
(the early return of the first rectangle became an else branch, so the damage event follows both
paths), `w16_EnableWindow` (the focus clear moved after the enable event, the same state changes in
the same order), `link_bottom` (remembers the window it links after).

## For the records

The orchestrator applies these; D3a did not edit the files.

* **DESIGN.md 12.5**: the observer core as built: `vm.h`/`vm.c` (table, hooks, forbid checks, the
  Checked counters), `platform/w16/w16_obs.[ch]` (guard, sentinel, events, queries, tick hook),
  `present/observe.[ch]`, the generated `present/obs_tables.[ch]` (`gen/obs_tables.py`, `--check` in
  `test.cmd`), `tests/harness/obs_lint.py`, `tests/test_observer.c`, the `checked noobs` variant, the
  harness logs `observer-probes.log` and `presentation-diag.log` and `--probes 0`, civ64's
  `obs_init`. Close Open **A1** (generated: WI 10 + A 4.3 additions + area C's two keys; 203 keys,
  98 rows), **A2** (the points above; no `OBS_CTL_CHECK` site), **A5** (the measured cost, "Cost"
  above), **A6** (no key has an `FR_NONE` or near frame; the paths are tested synthetically), **A7**
  (existing getters reused; the file-static state needs the accessors of the first deviation).
* **DESIGN.md 12.10**: two rows: "user_wnd.c, user_ctl.c, user_listbox.c, user_menutrack.c,
  user_cursor.c: read-only accessors for the `w16q_*` window, control, list-box, menu-state and cursor
  queries (`#if CIV_OBSERVER`) | O3, A7 | D3 | read-only, reviewed (probe verification 4, 5); G-1;
  `test_observer.c`" and "rgn.c: a region overflow inside the observer counted, not logged | O3 (5.3) |
  D3 | G-1 (the emulation's path unchanged)". In the paragraph after the table: the harness gains
  `--probes 0`.
* **DESIGN.md 12.5 / TRACE.md "observer probe" rows**: none exist yet. When the orchestrator adds a
  probe table (DESIGN.md) or TRACE.md rows, each row must start `| observer probe |` and name the
  key's address, its function and its phases as one cell (`E`, `X` or `EX`); `obs_lint.py` then checks
  every row against `OBS_PROBES[]`. The 203 rows can be taken from
  [ext-D3-probe-verification.md](ext-D3-probe-verification.md) section 2.
* **RUNNING.md**: `build.cmd checked noobs` / `test.cmd checked noobs` (the CheckedNoObs variant,
  `CIV_OBSERVER=0`, `build\x64\CheckedNoObs`, harness runs under `build\harness\CheckedNoObs`;
  `ext_g1.py check --variant CheckedNoObs` after it); the harness's `observer-probes.log` and
  `presentation-diag.log` (written by every run of an observer build; neither is compared by G-1) and
  `--probes 0`; `gen/obs_tables.py [--check|--report]` and `tests/harness/obs_lint.py` (both in
  `test.cmd`); the UNINIT step also runs in CheckedNoObs.
* **STATUS.md** (extension track): D3a complete in Checked, CheckedNoObs and Release on 2026-10-11
  (this record); Asan deferred to the final pass with `test_observer`; D3b next (the tick, profiles,
  switching, input stages, P0 runner, 7.8 mode, the D3 gate).
* **FIDELITY.md**: none (no behaviour of the emulation changed; the observer is presentation-only).
* **For D3b** (not a document entry): `obs_tick` is the hook `present_tick` fills; the Win32 debug-log
  output of `W16qDiag`; the cursor route, `HostEvent.frame` and `host_sync.c`'s hooks are untouched;
  the A-3/A-B3/A-B4 queries belong to M and D4; the 11 never-hit keys are re-derived from the P0
  matrix's logs.

## Not verified

* Asan builds and tests (deferred by the user).
* civ64.exe was not started: its `obs_init` call is compiled (Checked, CheckedNoObs, Release) but
  its start with the observer was not observed; the Win32 back end ran only in the Win32-headless
  tests.
* The reviewer of the queries is a separate read-only agent session, not a person; its findings were
  fixed by the implementer and re-tested, not re-reviewed.
* 11 of the 203 keys were not hit by any base run (listed in the probe verification); their
  addresses and frames are verified statically only.
* `OBS_PAL_REALIZE` and `OBS_CTL_CHECK` occur in no base run (the first only in `test_observer`, the
  second nowhere, by design).
* The cost of the observer under a real listener (D3b's profiles) is not measured: the runs here
  have no listener.

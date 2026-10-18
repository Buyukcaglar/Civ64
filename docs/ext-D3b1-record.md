# Extension phase D3, unit D3b1 (presentation, switching and the P0 runners) — record

Prompt: `claude/docs/x64-port-scaling-dos-prompt.md`, phase D3 (section 9): "Observer, probes and
presentation tick in `w16`; composition; profile switching (...); the P0 test runner and the 7.8 harness
mode." Gate: "7.3 (without zoom) and 7.4 pass with switching; probe verification recorded." D3 is done
in three units: D3a (the observer core, [ext-D3a-record.md](ext-D3a-record.md)), this unit D3b1
(presentation, switching and the P0 runners) and D3b2 (input stages, chord and menu, the 7.8 mode and
the gate record `ext-D3-acceptance.md`). Session D3b1, 2026-10-11. Brief:
[verify/BRIEF-d3.md](verify/BRIEF-d3.md) ("D3b split"). Design:
[verify/ext-d1-draft-A.md](verify/ext-d1-draft-A.md) (revision 3) sections 7.2, 7.3, 8, 9, 11, 12.1..12.3,
13.1, 13.2, 13.4, with [verify/ext-d1-decisions.md](verify/ext-d1-decisions.md) and DESIGN.md 12.5,
12.10, 12.11.

Labels: **compiled** (the three language checks and `/W4 /WX`), **headless** (test programs and the
harness on `build/gamedata`, the DOS profile with `--dos-data build\dosdata`), **Win32-headless** (the
Win32 back end with a hidden window). No DOS program was executed; nothing was written to
`C:\Projects\Civ1RE\dos` or `build/dosdata` (read only, through the asset store); no visible window was
shown; civ64.exe was not started. Asan was not built or run (deferred by the user, 2026-10-10 21:20).

## What was built

* **The profile interface** (`present/profile.h`; draft A 8.1, 8.2, 7.2). `PresentProfile` with the
  callbacks of 8.1 (`available`, `reset`, `on_event`, `on_probe`, `on_core_present`, `advance`,
  `shows_core_frame`, `frame`, `peek`, `cursor`, `indexed`, `input_frame`), `PresentCursor`, the show
  reasons `PRESENT_SHOW_CORE/TICK/VIEW`, the tick clocks `PRESENT_TICK_VIRTUAL` (16,667 us) and
  `PRESENT_TICK_HOST`; registration (`present_profiles_init`, the test seam
  `present_profile_register`), `present_profile`, `present_profile_name`, `present_request_profile`,
  `present_start_profile`, `present_profile_visible`, `present_profile_pending`,
  `present_visible_shows_core`, `present_tick`, `present_set_tick_clock` / `present_get_tick_clock`,
  `present_show_reason`, and the harness's hooks `PresentHooks` (`on_switch`, `on_sample`,
  `sample_every_us`) with `present_set_hooks`.
* **The Windows profile** (`present/profile_win.c`): S1's frame `g_win` moved out of `present.c`
  (`pwin_frame`, `pwin_reset`, `pwin_core` with S1's game-screen rule, FIDELITY F105); it shows the
  core frame (`shows_core_frame` 1), uses the game's cursor, has no 8-bit form, input frame 0.
* **The DOS profile** (`present/dos/pdos_profile.c`; A 8.4 Choice, RV1-18): available when
  `pdos_assets_status() == PDOS_OK` (else the store's message), registered by `obs_init` for the whole
  run; in D3 its frame is the Windows frame (`present_core_xrgb`) with the damage of the core presents
  accumulated since its last take, shown only through the tick (`shows_core_frame` 0); the game's
  cursor; no 8-bit form; input frame 2; no event, probe or advance callback yet (B's from D4 on).
* **`present.c`** (rewritten around the profiles; draft A 7.2, 7.3, 8.2, 8.3, 8.5):
  * `present_core_frame(screen, w, h, rgb768, &r)`: the Windows frame first (`pwin_core`), then every
    registered profile's `on_core_present` (so `present_core_xrgb` is current inside them, A-B5), then,
    when the visible profile shows the core frame, its damage scaled and shown (CORE; a frame of a new
    size: a new layout and the whole client). `w16_present` calls it inside the observer's guard and
    then calls `host_present` itself, whatever the profile (see the deviations). `present_core` (the
    same plus `host_present`) is kept for the unit tests.
  * **The tick** `present_tick` → `present_tick_at(w16q_now_us())` (`obs_tick` now calls it): 1. a
    pending request switches (the new frame's layout, the whole client redrawn, VIEW, no throttle; the
    cursor issued again; `g_tick_last = now`; the switch hook); 2. every registered profile's `advance`;
    3. the visible profile's pointer issued again when it reports a change, or the game's cursor when
    it stops having one; 4. the sample hook at the first tick at or after each multiple of
    `sample_every_us`; 5. a profile that shows the core frame returns here; 5a. a visible frame whose
    size changed (A-B6): re-layout, the whole client (VIEW), the cursor again, no throttle; 6. the
    throttle (the virtual clock's 16,667 us headless, `host_now_us()` at the monitor's period in
    Win32); 7, 8. the visible frame's damage scaled and shown (TICK).
  * The view functions follow the visible profile (`present_view_point`, `present_view_layout`,
    `present_shown_frame`); `present_core_xrgb` is always `g_win`; `present_shown_indexed` asks the
    visible profile's `indexed`; `present_game_screen(_follow)` read only 640x480, the client and the
    options, never the profile (K1).
  * **The cursor route** `present_cursor(res, len, idc)` (8.5): the game's current cursor is kept and
    issued, unless the visible profile has a pointer of its own (`host_set_cursor_pixels`); a switch, a
    frame-size change and a reported pointer change issue it again; before the game sets a cursor, the
    end of a profile's pointer restores the back ends' arrow (IDC 32512).
  * Requests: an unregistered profile is refused with the reason (`pdos_assets_message()`, or "The DOS
    graphics are not in this build." under `CIV_OBSERVER 0`, 10.2).
  * `present_diag_log()`: the observer's `W16qDiag` and the DOS store's accessor diagnostics
    (`pdos_diag_*`) as `host_log` lines (draft A 5.3: Win32's debug log).
* **w16** (`platform/w16`): `gdi_pal.c` `w16_present`: `present_core_frame` inside
  `W16_OBS_GUARD_BEGIN(W16_OBS_IN_OTHER, W16_OBS_OTHER_PRESENT)`, then `host_present` with the same
  screen, palette and rectangle as before, unconditionally. `user_cursor.c` `w16_SetCursor`: the two
  `host_set_cursor` calls became one `present_cursor` call inside
  `W16_OBS_GUARD_BEGIN(W16_OBS_IN_OTHER, W16_OBS_OTHER_CURSOR)`; `g_current`, the result and the
  `OBS_CURSOR` event are unchanged. `w16_obs.h`: the ids `W16_OBS_OTHER_PRESENT`, `_CURSOR`,
  `_COMMAND` of the guard kind `W16_OBS_IN_OTHER`. `host.h`: `host_set_cursor_pixels`.
* **`present/observe.c`**: `obs_init` calls `present_profiles_init()` (the Windows profile, and the DOS
  profile when available, each reset and listening when it has an event or probe callback) before it
  installs the probe table; `obs_tick` calls `present_tick()`.
* **The headless back end** (`tests/headless/host_headless.[ch]`): `host_set_cursor_pixels`; the cursor
  trace hook `hh_cursor_fn` (and `hh_cursor_count`) describing each issued cursor as presented.log's
  `cursor` line has it; `--dump-presented` files (`hh_presented_dir`): `presented-NNNNN.bmp` (24-bit
  Windows frame, numbered by core frames) at `host_present` while the visible profile shows the core
  frame, `tick-NNNNN.bmp` at each TICK or VIEW show while it does not (8-bit through
  `present_shown_indexed`, else 24-bit; `hh_tick_dumps`); `hh_write_bmp24`.
* **The Win32 back end** (`platform/win32/host_win32.[ch]`): `host_set_cursor_pixels` (a copy of the
  pixels made into a cursor by `CreateIconIndirect` from a 32-bit colour DIB and a 1-bit mask set where
  alpha is 0, scaled by the cursor factors by nearest neighbour with the hot spot, made again when the
  factors change; NULL hides; a game cursor replaces it and vice versa); the tick clock
  (`present_set_tick_clock(PRESENT_TICK_HOST, round(10^6 / Hz))` with `dmDisplayFrequency` of the
  window's monitor, 60 Hz when it reads 0 or 1; after the window is created, on WM_DISPLAYCHANGE, and on
  WM_MOVE when the monitor changed); `--dump-presented`: `presented-NNNNN.bmp` only while the visible
  profile shows the core frame, `tick-NNNNN.bmp` at TICK and VIEW shows otherwise (8-bit with
  `write_bmp8`, the writer of `--dump-frames`, or 24-bit; `hw_ticks_dumped`); `present_diag_log()` at
  `host_exit` and `host_fault` (the debug log).
* **civ64** (`win64/civ64_start.[ch]`, `civ64_main.c`; draft A 11): `--graphics windows|dos`
  (`Civ64Options.graphics`, -1 when not given; an invalid value is a usage error, exit 2). `--graphics
  dos` without a working store exits 2 with the store's message right after `pdos_assets_open` (under
  `CIV_OBSERVER 0`: "The DOS graphics are not in this build."). After `obs_init` the start profile is
  the command line's, else the settings key `graphics` (`windows`|`dos`, anything else absent), else
  windows; a remembered `dos` that is unavailable starts windows without a message. The `--aspect`
  default is 4:3 (decision X3; the remembered `aspect` key and the command line still win).
* **The harness** (`tests/headless/harness.[ch]`, `harness_main.c`; draft A 12.1, 12.2, 7.3):
  * options `--graphics windows|dos` (dos without a store: exit 2 with the message),
    `--switch-every MS` (a toggle request when a multiple of MS virtual ms has passed),
    `--profile-samples MS`, `--dump-presented DIR`; the `--aspect` default 4:3 (X3); under
    `CIV_OBSERVER 0` `--graphics dos`, `--switch-every` and the `profile` command exit 2;
  * script commands `at <ms> profile windows|dos|toggle`, `at <ms> policy integer|fit [nearest|sharp]
    [square|4:3]`, `at <ms> hostsize WxH` (and `zoom`: refused, exit 2, until M), applied in `step()`
    at `VM_STEP_API` when due, inside `W16_OBS_GUARD_BEGIN(W16_OBS_IN_OTHER, W16_OBS_OTHER_COMMAND)`,
    calling only `present_request_profile`, `present_set_options` and `hh_set_view`;
  * `<out>/profiles.log` (whenever `--graphics`, `--switch-every`, `--profile-samples` or a `profile`
    command is used): `start virtual_us US profile P registered windows[,dos]`, `request virtual_us US
    to P`, `switch virtual_us US from A to B`, `switch virtual_us US refused B: <reason>`, `sample K
    virtual_us US windows SHA [dos SHA]` (each registered profile's `peek()` frame, hashed as the
    presented frame hash), `end requests R switches S refused F pending P replaced Q`;
  * `presented.log` by show reason: CORE lines keep S1's format and relation check (now against
    `present_core_xrgb()` while the Windows profile is visible), `presented N tick ... profile P` and
    `presented N view ... profile P` (replacing S1's `view_attached` line), `cursor virtual_us US
    game LEN sha256 SHA | idc N | pixels WxH hot X,Y sha256 SHA | none`, end line `end presents N
    relation_mismatches M tick_shows T`; `presentation-diag.log` gains the line `pdos <name> <count>
    ...` (the DOS store's accessor diagnostics).
* **The tests**: `tests/test_present.c` (draft A 13.4: a test profile in the DOS slot; see "Test
  counts"), `tests/win32/test_host_win32.c` (7.2: the tick clock, `host_set_cursor_pixels` at 2x2 and
  1x1 with its hot spot and the game's cursor replacing it, the tick dumps 24-bit and 8-bit,
  `presented-NNNNN.bmp` only under a profile that shows the core frame, the `--graphics` parse cases),
  `tests/harness/ext_p0.py` (7.3, 13.1) and `tests/harness/ext_frames.py` (7.4, 13.2), both in
  `test.cmd checked` (and `ext_p0.py CheckedNoObs` in `test.cmd checked noobs`, V5).
  `tests/harness/p4tests.py`: the p49-prf-game check reads the new end line of `presented.log`.
  `gen/dos/registry.py`: the include rule admits `present.h`/`profile.h` in `pdos_profile.c`.

Files (under `claude/port`). New: `present/profile.h`, `present/profile_win.c`,
`present/dos/pdos_profile.c`, `tests/harness/ext_p0.py`, `tests/harness/ext_frames.py`, this record.
Changed: `present/present.h`, `present/present.c`, `present/observe.h`, `present/observe.c`;
`platform/w16/host.h`, `gdi_pal.c`, `user_cursor.c`, `w16_obs.h`; `platform/win32/host_win32.h`,
`host_win32.c`; `tests/headless/host_headless.h`, `host_headless.c`, `harness.h`, `harness.c`,
`harness_main.c`; `tests/test_present.c`, `tests/win32/test_host_win32.c`; `tests/harness/p4tests.py`;
`win64/civ64_start.h`, `civ64_start.c`, `civ64_main.c`; `gen/dos/registry.py`; `test.cmd`.
(`build.cmd` rewrites its generated files on every build; their content is not D3b1's.)

## Acceptance items

The final cycle (after the review fixes, see "Review"), 2026-10-11:

| Item | Method | Result |
|---|---|---|
| Builds | `build.cmd checked`, `build.cmd checked noobs`, `build.cmd` (strict C17/x64, `/W4 /WX /permissive-`; the 243 portable sources, two of them new, also `/std:c11`, `/std:c17` and the clang-tidy C99 parse) | compiled: BUILD_OK Checked (12:54:46..12:57:45 UTC), CheckedNoObs (13:09:23..13:12:24 UTC), Release (13:19:37..13:22:25 UTC) |
| Base tests | `test.cmd checked`, `test.cmd checked noobs`, `test.cmd` (every base test program, gate 3b, the stub-core runs, scenarios, UNINIT, phase-4 scenarios and tests, D2's and D3a's checks, TRACE) | TESTS_OK Checked (12:57:45..13:09:23 UTC), CheckedNoObs (13:12:24..13:19:36 UTC), Release (13:22:25..13:23:00 UTC); GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK, P4_TESTS_OK, TRACE_OK |
| G-1 (P0) | `ext_g1.py check` after `test.cmd checked`; `ext_g1.py check --variant CheckedNoObs` after `test.cmd checked noobs` | **EXT_G1_OK runs 77** on Checked (13:09 UTC) and on CheckedNoObs (13:19 UTC) |
| 7.3 P0 without zoom (13.1) | `ext_p0.py Checked` in `test.cmd checked` (V0, V1, V2, V3, V6, V6r, V6w); `ext_p0.py CheckedNoObs` in `test.cmd checked noobs` (V5) | **P0_OK checks 170** (Checked), **P0_OK checks 54** (CheckedNoObs); no FAIL line (see "P0 variations and results") |
| 7.4 (13.2) and the dump check (13.4) | `ext_frames.py Checked` in `test.cmd checked` | **EXT_FRAMES_OK**; again 13:23:12..13:24:32 UTC after a label-only edit of its assertion text (`build/d3b1-ext-frames-final.log`) |
| Probe verification (D3a's "For D3b") | the union of the hits in the P0 matrix's 114 `observer-probes.log` files | recorded under "Probe hits" |
| Tables and the static check | `obs_tables.py --check`, `obs_lint.py` in `test.cmd` | `OBS_TABLES_OK probes 203 sites 98`, `OBS_LINT_OK files 30 probes 203 callsites 98` in every variant |
| No DOS bytes; E's include rule | `nodos.py check`, `registry.py check` in `test.cmd` | NODOS_OK and REGISTRY_OK in every variant; `nodos.py check` again at the end: NODOS_OK. `build/dosdata` and `C:\Projects\Civ1RE\dos`: no file newer than the session's first build |
| `CIV_OBSERVER 0` refusals (A 9) | the CheckedNoObs harness with `--graphics dos`, `--switch-every 997`, a script `at 5 profile dos` | exit 2 with "not in this build (CIV_OBSERVER 0)" each; `--graphics windows` runs (exit 0) |
| Asan | — | **deferred** (the user's direction 2026-10-10 21:20) |

Earlier cycles of the session: Checked build 12:22:07..12:24:57 UTC, `test.cmd checked`
12:25:22..12:31:22 UTC **TESTS_FAILED=1** (`REGISTRY_FAIL`: `include rule pdos_profile.c: 20
"present.h"`; fixed in `registry.py`, the third deviation), G-1 EXT_G1_OK 77. Checked build
12:32:52..12:35:55 UTC, followed only by focused runs (`test_present`, `test_host_win32`, trial
`ext_p0.py` subsets and `ext_frames.py`) before the next build. Checked cycle 12:39:15..12:53:44 UTC
(before the review fixes): BUILD_OK, TESTS_OK with P0_OK checks 170 and EXT_FRAMES_OK, EXT_G1_OK
runs 77.

### Test counts

| Program | Checked | CheckedNoObs | Release | D3a |
|---|---|---|---|---|
| `test_present` | PASS 521 checks, 0 failures | 521 | 521 | 477 |
| `test_host_win32` (Win32-headless) | PASS 166 checks, 0 failures | 166 | 166 | 148 |

Every other test program gave D3a's counts in each variant (for example `test_observer` 103 / 1 / 92,
`test_user` 319, `test_start` 110, `test_gdi` 95, `test_dos` 23,200). `test_present`'s 44 new checks
(a test profile in the DOS slot): the switch at the next tick (VIEW, the hook), the show reasons, the
throttle on the virtual clock (no show without damage, damage after an idle period shown at once),
the sample hook's multiples, refused requests (an unregistered profile, slots out of range), the
frame-size change's re-layout with the cursor issued again, the view functions and the 8-bit form
following the visible profile, the game screen independent of the profile, X3's 4:3 layouts, and the
cursor route (the game's cursor, a profile's pointer, an unchanged pointer not issued again, back to
the game's last cursor, the arrow before any game cursor). `test_host_win32`'s 18 new checks: the
tick clock, the pixel cursor, the tick and presented dumps and the `--graphics` parse cases. Logs:
`build/d3b1-build-*.log`, `d3b1-test-*.log`, `d3b1-g1-*.log`, `d3b1-*-times-*.txt`,
`d3b1-ext-frames-final.log`; the runners' outputs `build/test/<variant>/ext-p0.txt`, `ext-frames.txt`.

### P0 variations and results

27 runs per variation: the 23 rows of `scenarios.py` and gate3b's S2, S2b, S2c, S3 (S1 is `start`).
"Equal" means `run.log`'s frame, snapshot and result lines, the whole `events.log` and the exit status.

| Variation | Options (beside the scenario's) | Runs | Checks | Result |
|---|---|---|---|---|
| V0 | none (4:3 default) | 27 | 27 | every run equals its `ext-g1-baseline.txt` row (frames, state, events digests), exit 0 |
| V1 | `--dos-data build\dosdata --graphics dos --presented 1` | 27 | 54 | equal to V0; profiles.log `start ... profile dos registered windows,dos` in all 27, refused 0 |
| V2 | `--dos-data build\dosdata --switch-every 997 --presented 1` | 27 | 54 | equal to V0; 1,866 requests, 1,866 switches, refused 0, pending 0, replaced 0 |
| V3 | a generated script: the scenario's lines plus `policy` and `hostsize` commands, `--presented 1` | 27 | 27 | equal to V0 |
| V6 | `--dos-data build\dosdata --game-screen view --switch-every 997 --presented 1` (s3, orders) | 2 | 4 | equal to V0; 137 requests, 137 switches |
| V6w / V6r | `--host-size 1920x1080 --game-screen view` with (V6w) and without (V6r) the DOS options and `--switch-every 997` (s3, orders) | 2 + 2 | 4 | V6w equal to V6r; 137 switches. The game screen is 960x540 (events.log's `screen 3C0 21C` event), so V6r's trace differs from V0's by design and is V6w's reference |
| V5 | the V0 options on CheckedNoObs | 27 | 54 | every run equals its baseline row and the Checked V0 outputs |

The shows (from `presented.log`, not compared): V1 16,149 tick shows and, per run, only the first
view besides them (no CORE show); V2 7,633 tick shows between core shows; V3 0 tick shows; relation
mismatches 0 in all 85 presented logs. Each `observer-probes.log` of V1, V2, V3 equals V0's, V6's
equals V0's and V6w's equals V6r's (85 comparisons, informational).

7.4 (`ext_frames.py`, runs A `--graphics dos`, A' its repeat, B `--switch-every 997`, C `--graphics
windows`, all with `--profile-samples 100`): start 299, s3 719, birth 2,049 sample lines identical
across A, A', B, C for both profiles; A's `presented.log` equal to A''s (381, 625, 966 lines); the
switch assertions of A and B; A shows only through the tick (374, 609, 955 tick shows, no core show).
Dump check: `start --graphics dos --dump-presented` wrote 375 `tick-NNNNN.bmp` (24-bit) and no
`presented-NNNNN.bmp`.

### Probe hits

The 114 `observer-probes.log` files of the Checked P0 matrix hit **179 of the 203 keys**; 24 were never
hit. They are D3a's 11 (`1000:4124`, `1018:17DB`, `1030:8C11`, `1098:28E4`, `10E0:0000`, `10E8:32C1`,
`1180:17E9`, `11B0:237C`, `11B8:0C3D`, `1208:1534`, `1220:114B`, see
[ext-D3-probe-verification.md](ext-D3-probe-verification.md)) and 13 keys that D3a's 81 runs (11
under `build/harness/Checked`, the 70 G-1 runs under `build/harness/game`) did hit, by that list, but
the 27 scenarios of 13.1 do not reach:
`1040:068E` ProcessCityDisaster, `1050:0000` ResolveCombat, `1070:1952` HumanPlaceSpaceshipPart,
`1070:2015` LaunchSpaceship, `1168:06C1` SetGovernment, `1188:0DB8` ShowHistorianReport, `11A0:0000`
StartCivilWar, `11B0:1B63` PlayCityCaptureAnimation, `11B0:1FAC` PlayCivilDisorderAnimation,
`11B8:0000` DiplomatEntersCity, `11B8:0F26` TransferCityByRevolt, `11D8:087F` ShowCivilizationDestroyed,
`11D8:0BD2` WaitTicksOrInput. Every variation hits the same keys (V0..V3: 179; V6: 121; V6r, V6w: 120
on two runs); adding the 11 stub-core runs and the 13 `ext_frames.py` runs under
`build/harness/Checked` leaves 179.
The G-1 outputs under `build/harness/game` were rewritten by `test.cmd checked noobs` (no observer
logs), so this session did not recount their hits; D3a's list of 11 stays the list of keys no base
run reaches.

### Review

A separate read-only agent session reviewed the changes (P0 first) after the 12:39 cycle had started.
It found no P0 hazard (every new entry from w16 or the harness inside a guard; `host_present`
unconditional after the guard; the tick, cursor and command paths write only the presentation's logs
and dumps and read the clock through `w16q_now_us`/`w16_clock_us`; the game screen independent of the
profile). Its seven findings and what was done:

| # | Finding | Done |
|---|---|---|
| 1 | harness.c: `if (!W16_OBS_GUARD_BEGIN(...)) return;` becomes `if (!1)` under `CIV_OBSERVER 0` (C4127 risk at `/W4 /WX`) | the positive form of the other sites (`commands_apply` inside `if (GUARD_BEGIN) { ...; GUARD_END(); }`) |
| 2 | `ext_p0.py` compared the exit status with -1 when the reference variation was not run in the same call (`--vars V1`) | each run's status is written to `<name>.exit` beside its output and the reference's is read from there; `ext_p0.py Checked --vars V1,V6w --only start,s3` then gave P0_OK checks 6 |
| 3 | a request replacing a pending one would show only as `switches + pending < requests` | `profiles.log`'s end line counts `replaced`; the assertion keeps 13.1's `switches + pending == requests` ("every request became a switch") and requires `replaced 0` (deviation row) |
| 4 | `run_error` did not close `presented.log` or clear the show hook and the presentation hooks | it closes `g_presented`, clears `hh_show_fn` and calls `present_set_hooks(NULL)` |
| 5 | `present_core_frame` may widen `*r`, and `host_present` received the widened rectangle | `w16_present` passes a copy; `host_present` gets the original rectangle (both back ends ignore it today) |
| 6 | `hw_destroy_window` left the pixel cursor, the game cursor's copy and the cursor flags; `g_ticks_dumped` was never reset | freed and reset there; `hw_set_presented_dir` resets the dump counter |
| 7 | under `CIV_OBSERVER 0` `--graphics windows` and `--profile-samples` are accepted and no profiles.log is written | kept and recorded (the A 9 deviation row): only the options A 9 lists are refused |

The fixes were not re-reviewed; the final cycle above ran on them.

## Deviations from the design

| Design | What | Why |
|---|---|---|
| A 8.3 (the `present_core` pseudo-code), DESIGN.md 12.10 | `present_core` is split: `present_core_frame` (the profiles, the CORE show) runs inside the guard that `gdi_pal.c`'s `w16_present` opens (`W16_OBS_IN_OTHER`, `W16_OBS_OTHER_PRESENT`), and `w16_present` then calls `host_present` with the unchanged arguments itself; `present_core` stays as a wrapper for the unit tests. 12.10's gdi_pal.c row widens accordingly | present/ may not call `w16_obs_begin` (O3, `obs_lint.py`: no `w16_` identifiers in present/), so the guard cannot be inside `present_core` as 8.3 draws it. `host_present` after the guard, also when a nested call is dropped, keeps the core frame trace whatever happens in the presentation |
| A 6.1 | three ids for the guard kind `W16_OBS_IN_OTHER`: `W16_OBS_OTHER_PRESENT`, `_CURSOR`, `_COMMAND` (w16_obs.h) | the sentinel's fault names the kind and the id (D3a's deviation); D3 adds the first `IN_OTHER` callers |
| E.2.2 (include rule, `registry.py check`) | `pdos_profile.c` may also include `"present.h"` and `"profile.h"` | the rule was written for E's modules; area A's profile module (RV1-18) implements the renderer interface. Both headers include no emulation header, so the rule's purpose (no emulation state, no `CIV_CHECKED`) is kept; the first Checked test run reported `REGISTRY_FAIL` before the change |
| A 12.1 (`policy`) | an omitted filter or aspect keeps its current value | the design does not say; V3's cycle then alternates `fit sharp 4:3` with `integer sharp 4:3` |
| A 12.2 (`--switch-every`) | one toggle request per `VM_STEP_API` step when one or more multiples have passed (never two at once); a toggle targets the other profile than the pending request's, else than the visible one; `requests` counts every request, refused ones included | the design says "at every multiple"; two requests in one step could only replace each other. With these rules `switches + pending == requests` held in every run (no request was replaced) |
| A 12.2 (`profiles.log`) | the end line also carries `replaced Q` (requests made while another was pending, which 8.2 lets the new one replace); `ext_p0.py`'s switch assertions require `replaced 0` | without it a replacement shows only as `switches + pending < requests`; the separate count names it (review finding) |
| A 7.3 | `presented.log`'s first line (the view attached before the core runs) is now `presented 1 view virtual_us 0 profile windows ...` instead of S1's `... view_attached`; `p4tests.py`'s p49-prf-game check reads the end line with `tick_shows` | as 7.3 specifies (the reason replaces the flag); the S1-era check compared the end of the line |
| A 5.3, brief ("the Win32 diagnostics log (`presentation-diag.log`)") | Win32 writes the diagnostics to the debug log (`host_log` → `OutputDebugStringA`) at `host_exit` and `host_fault`, as `presentation-diag ...` lines; the harness's `presentation-diag.log` gains the `pdos ...` line | 5.3: "The harness writes them to `presentation-diag.log` at the end of the run. Win32 writes them to the debug log." civ64 writes no log files |
| A 13.1 (V5) | `ext_p0.py` in `test.cmd checked` runs V0, V1, V2, V3, V6; V5 runs in `test.cmd checked noobs` (`ext_p0.py CheckedNoObs`) against the Checked V0 outputs of the preceding `test.cmd checked` and against `ext-g1-baseline.txt` | the CheckedNoObs harness is built after `test.cmd checked` in the serialized build order, so V5 can only run in its own variant's test |
| A 13.1 (runs) | the scenario options are replicated without `--dump-frames`/`--dump-step`/`--dump-from`; scenarios.py's edited saves are written to `build/p0/saves`; `fame-reload` and `s2c` read their own variation's `retire`/`s2b` run (a second wave) | the dumps write files only (no compared line depends on them); p4 and gate3b outputs stay untouched; each variation stays self-contained |
| A 13.1 (V6) | added **V6w** (`--host-size 1920x1080 --game-screen view --dos-data build\dosdata --switch-every 997`) against **V6r** (the same without the DOS options), on s3 and orders | V6 at the default 640x480 view gives a 640x480 game screen, so it equals V0 but does not show a game screen of another size; V6w's game screen is 960x540 (one `screen` event) |
| A 13.1 | V1, V2, V3, V6, V6w also pass `--presented 1` | evidence of the shows (`presented.log`, not compared) |
| A 9 | under `CIV_OBSERVER 0` the harness accepts `--graphics windows` and `--profile-samples` (nothing to sample: no tick runs) | only `--graphics dos`, `--switch-every`, `--host-input`, `--zoom` and the `profile`/`zoom` commands are listed as refused |
| A 11 | civ64 checks `--graphics dos` right after `pdos_assets_open` (before the window); the start profile is applied after `obs_init`. The settings key `graphics` is read only; writing it belongs to the player's switch (chord, menu), which is D3b2's | the store's result is final then (E.4.2); the profiles exist only after `obs_init`; 11: "The settings hook writes it when the player switches by chord or menu" |
| A 7.2 | `present_set_tick_clock` also resets the throttle's last show time | a new period (another monitor) applies at once |
| A 8.1 | `present_tick_at(now_us)`, `present_profile_register(id, p)` and `hw_ticks_dumped()` added as test seams | the unit tests drive the tick and a test profile without the emulation |

## Seams for D3b2

* **Requests and refusal.** The chord and the system menu call `present_request_profile(other, &why)`;
  `why` is the store's message or the `CIV_OBSERVER 0` text. The refusal cadence (one `host_message`
  with E's message and the Locate hint, then beeps) is not built.
* **Input frame.** Every profile has `input_frame()` (Windows 0, DOS 2 in D3) for `HostEvent.frame`
  stamping in `present/arrive.c` / `present/input.c`; `present_view_point` already maps into the
  visible frame's layout.
* **Settings key.** `civ64_main.c`'s `save_settings` does not write `graphics`; D3b2 adds it when a
  player's switch is accepted (`g_graphics` holds the names; the command line is not written).
* **System menu.** `add_menu`/`hw_update_menu`/`civ_command` (host_win32.c) have no profile items yet
  (`SC_CIV_PROF_WIN 0x1090`, `SC_CIV_PROF_DOS 0x10A0`, `SC_CIV_DOS_LOCATE 0x10B0`); the visible
  profile is `present_profile_visible()`, a pending one `present_profile_pending()`.
* **Harness.** `load_script` dispatches command lines to `load_command`, and `commands_due` applies
  them inside the guard; the 7.8 host-form lines (`hkey`, `hmouse`, ..., `sync N`) and
  `coreinput.log` can be added beside them. `ext_p0.py`'s `VAR_OPTS` and the default variation list
  take the input-stage variations; `switch_assertions` is reusable (ext_frames.py uses it).
* **Untouched:** `host_sync.c` (no hooks), `HostEvent` (no `frame` field), host_win32.c's arrival code.

## For the records

The orchestrator applies these; D3b1 did not edit the files.

* **DESIGN.md 12.5**: the profiles as built (profile.h, profile_win.c, pdos_profile.c, present.c's
  tick, switching, re-layout and cursor route); `present_core_frame` + `host_present` in `w16_present`
  (first deviation); the `W16_OBS_OTHER_*` ids; the harness's commands, `profiles.log`, the new
  `presented.log` lines and `--dump-presented`; `ext_p0.py` (V0..V3, V5, V6 and the extra V6w/V6r)
  and `ext_frames.py` in `test.cmd`.
* **DESIGN.md 12.10**: gdi_pal.c `w16_present`: "`present_core_frame` (on a copy of the rectangle)
  inside the observer's guard, then `host_present` with the unchanged arguments | O1, P0 | D3 | G-1,
  7.3"; user_cursor.c
  `w16_SetCursor`: "`present_cursor` inside the guard instead of `host_set_cursor` | K2, 8.5 | D3 |
  G-1, 7.3, `test_present`"; w16_obs.h: the `W16_OBS_OTHER_*` ids.
* **DESIGN.md 12.2 / 12.11** (civ64 options and settings): `--graphics windows|dos`, the settings
  key `graphics` (read in D3b1; written by the switch from D3b2), the `--aspect` default 4:3.
* **FIDELITY.md**: decision X3 (the `--aspect` default 4:3; it acts on 320x200 frames only, so the
  Windows profile, the S1/S2 outputs and the game screen are unchanged); draft A 7.2's T6 pause (during
  CPU-bound core work without polls no tick runs and the DOS view pauses; Birth inside world creation
  still ticks at GetTickCount).
* **RUNNING.md**: civ64 `--graphics windows|dos` (the remembered profile; `dos` without the DOS files
  stops with the message); the `--aspect` row: "Without it: your last choice, else `4:3`"; the
  `--dump-presented` row: `presented-NNNNN.bmp` while a profile that shows the core frame is visible,
  `tick-NNNNN.bmp` otherwise (24-bit, or 8-bit for an 8-bit frame); the harness options
  `--graphics`, `--switch-every`, `--profile-samples`, `--dump-presented`, the script commands
  `profile`, `policy`, `hostsize`, the logs `profiles.log` (end line `end requests R switches S
  refused F pending P replaced Q`) and the new `presented.log` lines; the
  `--aspect` default 4:3 of the harness; `tests/harness/ext_p0.py` and `ext_frames.py` (in
  `test.cmd checked`; V5 in `test.cmd checked noobs`).
* **STATUS.md** (extension track): D3b1 complete in Checked, CheckedNoObs and Release on 2026-10-11
  (this record): 7.3 without zoom and 7.4 pass with switching; D3b2 next (input stages, chord, menu,
  Locate, refusal cadence, 7.8 mode, the D3 gate record). Asan deferred.
* **manual-checklist-ext.md** D3 (pending, user): D3-5's `--graphics dos` part is now built (exit with
  the store's message); a new item for D3's DOS profile: start with `--graphics dos` (DOS files
  present): the picture is the Windows picture (D3 has no DOS renderer), shown at the monitor's rate;
  the X3 default changes nothing visible in the Windows profile.
* **FEATURES.md**: none (no game feature changed).
* **The D1 drafts**: A 8.3's pseudo-code and A 12.2's `--switch-every` and toggle rules as built
  (deviations above); A 12.2's `profiles.log` end line with `replaced Q` and 13.1's switch assertion
  with `replaced 0`; E.2.2's include rule with the `pdos_profile.c` exception; A 13.1's V5 placement
  and V6w.
* **D3a's "For D3b"** (the 11 never-hit keys re-derived from the P0 matrix): see "Probe hits".

## Not verified

* Asan builds and tests (deferred by the user).
* civ64.exe was not started: its `--graphics` handling, the start profile, the 4:3 default, the
  monitor-rate tick, the pixel cursor and the debug-log diagnostics are compiled and covered by the
  Win32-headless tests (hidden window) and the start-up parse tests only; no picture was looked at.
* The Win32 tick clock was checked to be the host clock with a period in [4,000, 41,667] us; the
  monitor change (WM_MOVE to another monitor) was not exercised (one monitor).
* The DOS profile shows the Windows frame in D3, so 7.4's sample identity holds by construction (as
  13.2 says); it tests the mechanism, not a DOS timeline.
* The reviewer of the changes is a separate read-only agent session, not a person (see "Review").

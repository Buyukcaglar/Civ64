# Extension phase D3 (observer, presentation tick, switching, input stages) — acceptance record

Prompt: `claude/docs/x64-port-scaling-dos-prompt.md`, phase D3 (section 9): "Observer, probes and
presentation tick in `w16`; composition; profile switching (...); the P0 test runner and the 7.8
harness mode." Gate: "7.3 (without zoom) and 7.4 pass with
switching; probe verification recorded." Under the user's direction of 2026-10-10 21:20 Asan runs are
deferred to the end of the queue (decision K8), so the gate is met in Checked, CheckedNoObs and Release
with the Asan run recorded as deferred. Brief: [verify/BRIEF-d3.md](verify/BRIEF-d3.md). Design:
[verify/ext-d1-draft-A.md](verify/ext-d1-draft-A.md) (revision 3) with
[verify/ext-d1-decisions.md](verify/ext-d1-decisions.md) and DESIGN.md 12.5, 12.10, 12.11.

D3 was done in three sequential units, each with its own record:

* **D3a, the observer core:** [ext-D3a-record.md](ext-D3a-record.md) (the probe table and hooks,
  `CIV_OBSERVER` and the `checked noobs` variant, events, the `w16q_*` queries, the Checked guard and
  sentinel, the generated probe and call-site tables, `obs_lint.py`, `test_observer.c`) and the probe
  verification [ext-D3-probe-verification.md](ext-D3-probe-verification.md).
* **D3b1, presentation, switching and the P0 runners:** [ext-D3b1-record.md](ext-D3b1-record.md) (the
  profile interface, the Windows and D3 DOS profiles, the tick and switching, re-layout, the cursor
  route, `--graphics`, the 4:3 default, the harness commands and logs, `ext_p0.py`, `ext_frames.py`).
* **D3b2, the input stages, chord and menu, the 7.8 mode:** [ext-D3b2-record.md](ext-D3b2-record.md)
  (the arrival stage `present/arrive.c`, the filter stage `present/input.c`, `HostEvent.frame`,
  `host_sync.c`'s hooks, the chord Ctrl+Shift+Backspace with its audit, the system-menu profile items,
  "Locate DOS files...", the refusal cadence, the settings key `graphics` written by the player's
  switch, `--host-input` / `--core-input-log`, `test_input.c`, `ext_p0.py` V7, `ext_adapt.py`).

Labels: **compiled** (the three language checks and `/W4 /WX`), **headless** (test programs and the
harness on `build/gamedata`, the DOS profile with `--dos-data build\dosdata`), **Win32-headless** (the
Win32 back end with a hidden window). No DOS program was executed; nothing was written to
`C:\Projects\Civ1RE\dos` or `build/dosdata`; no visible window was shown; civ64.exe was not started.

## Gate

The gate's items as run in D3b2's final cycle, 2026-10-11, after all three units' changes (times UTC;
the details are in [ext-D3b2-record.md](ext-D3b2-record.md#acceptance-items)):

| Gate item | Method | Result |
|---|---|---|
| **7.3 without zoom** (A 13.1, with switching) | `ext_p0.py Checked` in `test.cmd checked`: V0 (the baseline), V1 (start in the DOS profile), V2 (`--switch-every 997`), V3 (`policy`/`hostsize` commands), V6 and V6w/V6r (the game-screen view with switching), V7 (the player's chords through the arrival and filter stages); `ext_p0.py CheckedNoObs` in `test.cmd checked noobs`: V5 | **P0_OK checks 224** (Checked) and **P0_OK checks 54** (CheckedNoObs), no FAIL line: every run's frames, snapshots, result, `events.log` and exit status equal V0's (V0: its G-1 baseline row; V6w: V6r's). Switching in the runs: V2 1,866 switches, V6 and V6w 137 each, V7 928 player switches (Ctrl+Shift+Backspace) with 910 Alt+Enter; refused 0, replaced 0 everywhere |
| **7.4 with switching** (A 13.2) and the dump check (13.4) | `ext_frames.py Checked` in `test.cmd checked`: runs A `--graphics dos`, A' its repeat, B `--switch-every 997`, C `--graphics windows`, all with `--profile-samples 100`, on start, s3 and birth | **EXT_FRAMES_OK**: 299, 719 and 2,049 sample lines identical across A, A', B and C for every registered profile; A's `presented.log` equal to A''s; the switch assertions of A and B; A shows only through the tick; the dump check wrote 375 24-bit `tick-NNNNN.bmp` and no `presented-NNNNN.bmp` |
| **Probe verification** | D3a: [ext-D3-probe-verification.md](ext-D3-probe-verification.md) (each of the 203 probe addresses verified against the listing and `showfunc.py`; the 98 call-site rows with their call instructions and return addresses; the `w16q_*` queries' verdicts); D3b1 and D3b2: the union of hits over the Checked P0 matrix | **recorded**: 203 probes installed in every Checked run; the final matrix (141 `observer-probes.log` files) hits 179 of 203; the 24 never-hit keys are listed under "Not verified"; V1, V2, V3, V6 and V7 give V0's probe logs, V6w V6r's |
| G-1 (P0 of the existing scenarios) | `ext_g1.py check` after `test.cmd checked`, `--variant CheckedNoObs` after `test.cmd checked noobs` | **EXT_G1_OK runs 77** on Checked (15:23) and on CheckedNoObs (15:33) |
| Builds | `build.cmd checked`, `build.cmd checked noobs`, `build.cmd` (strict C17/x64, `/W4 /WX`, 245 portable sources with `/std:c11`, `/std:c17` and the C99 parse) | BUILD_OK Checked (15:02:05..15:05:15), CheckedNoObs (15:23:02..15:26:07), Release (15:33:02..15:36:01) |
| Base tests | `test.cmd checked`, `test.cmd checked noobs`, `test.cmd` | TESTS_OK Checked (15:05:15..15:23:02), CheckedNoObs (15:26:07..15:33:01), Release (15:36:01..15:36:36); `test_observer` 103 / 1 / 92, `test_present` 521, `test_input` 140 / 122 / 140, `test_host_win32` 185, `test_locate` 36 |
| 7.8, I7 (A 13.4) | `ext_adapt.py Checked` in `test.cmd checked` (S3 in host form, without and with chords) | **EXT_ADAPT_OK checks 11**: the chord run's `coreinput.log`, frames, snapshots, events and exit equal the plain run's |
| Tables, lint, no DOS bytes | `obs_tables.py --check`, `obs_lint.py`, `nodos.py check`, `registry.py check` in every `test.cmd` | `OBS_TABLES_OK probes 203 sites 98`, `OBS_LINT_OK files 33`, NODOS_OK, REGISTRY_OK in every variant |
| Asan | — | **deferred** (below) |

**Gate met in Checked, CheckedNoObs and Release** (2026-10-11, D3b2's final cycle); the Asan run is
deferred.

## Deviations (summary)

Each unit's record has the full table (design section, what, why). In short:

* **D3a** ([deviations](ext-D3a-record.md#deviations-from-the-design)): DESIGN.md 12.10's w16 list is
  widened by read-only accessors under `#if CIV_OBSERVER` (window, control, list-box, menu-loop and
  cursor state) and by `rgn.c` counting an overflow inside the observer; the window queries give an
  empty region for a window being destroyed; `w16q_obs_start` refused inside the observer; emission
  points of `OBS_DLG_CREATE`, `OBS_WND_CREATE`, `OBS_WND_DESTROY` (and the focus/activation clears),
  `OBS_PAL_REALIZE` placed where the state is complete, no `OBS_CTL_CHECK` site (w16 keeps no check
  state), no DRAWTEXT event for `DT_CALCRECT`; `ObsEvent`/`ObsDraw`/`W16qDiag` additions; the guard
  takes the kind and id and keeps a depth in Release; the sentinel compares the queued input count;
  `obs_callsite_in`; the `obs_lint.py` include exemption and consumer-table rules; the tables as
  generated files; the spin test headless; `--probes 0`; `obs_tick` left empty for D3b.
* **D3b1** ([deviations](ext-D3b1-record.md#deviations-from-the-design)): `present_core` split
  (`present_core_frame` inside `w16_present`'s guard, then `host_present` with the unchanged arguments);
  the guard ids `W16_OBS_OTHER_PRESENT/_CURSOR/_COMMAND`; E.2.2's include rule admits `present.h` /
  `profile.h` in `pdos_profile.c`; `policy` keeps omitted values; `--switch-every`'s one toggle per
  step and the toggle target; `profiles.log`'s `replaced Q` and the `replaced 0` assertion;
  `presented.log`'s view line; the Win32 diagnostics to the debug log; V5 placed in `test.cmd checked
  noobs`; the P0 runs without frame dumps, with their own saves and second wave; the extra V6w/V6r;
  `--presented 1` on the DOS variations; `--graphics windows` and `--profile-samples` accepted under
  `CIV_OBSERVER 0`; `--graphics dos` checked right after `pdos_assets_open`; the tick-clock reset; test
  seams (`present_tick_at`, `present_profile_register`, `hw_ticks_dumped`).
* **D3b2** ([deviations](ext-D3b2-record.md#deviations-from-the-design)): `PI_OUT_MAX` 264; focus loss
  releases keys only, buttons at capture loss (S2's rule); the chord key's repeats swallowed after
  the modifier's release (the only S2 behaviour changed, an edge); no chord on a Backspace already
  down; Alt+Enter serves only the held Alt; a lone release after the presses held before it; a press
  not delivered leaves the held keys held; the capture-loss release's position and frame; unpaired
  releases still delivered (S2); the player's switch through `present_player_profile` (the profile to
  come, withdrawal) with radio marks for the profile to come; `civ64_locate_dos_choose`'s `owner`;
  Locate grayed without the observer; a separate profile hook; `profiles.log`'s player lines and
  `withdrawn W`; `hostinput.log`; `--core-input-log` refused under `CIV_OBSERVER 0` and empty without
  `--host-input`; `--script` together with `--host-input`; sorted commands and host lines; the guard id
  `W16_OBS_OTHER_INPUT`; the extra variation V7; `ext_adapt.py`'s S3 conversion; the C-11 case with
  area C's real note left to D4.

## Asan

**Deferred** (the user's direction 2026-10-10 21:20; decision K8): no Asan build or test ran in D3.
`test_observer`, `test_present`, `test_input` and the D3 harness runs join the final Asan pass.

## For the records

Gathered from the three records; the orchestrator applies them (no D3 unit edited these files).

* **DESIGN.md 12.5**: the observer core as built (D3a: `vm.h`/`vm.c`, `w16_obs.[ch]`,
  `present/observe.[ch]`, the generated `present/obs_tables.[ch]` with `obs_tables.py --check`,
  `obs_lint.py`, `test_observer.c`, the `checked noobs` variant, `observer-probes.log`,
  `presentation-diag.log`, `--probes 0`, civ64's `obs_init`; Open A1, A2, A5, A6, A7 closed as D3a
  states); the profiles as built (D3b1: profile.h, profile_win.c, pdos_profile.c, the tick, switching,
  re-layout and the cursor route; `present_core_frame` + `host_present` in `w16_present`; the
  `W16_OBS_OTHER_*` ids; the harness commands, `profiles.log`, the `presented.log` lines,
  `--dump-presented`); "Input (I2, I7)" as built (D3b2: the arrival and filter stages and their rules
  as recorded; V7 is the P0 run that goes through them); "Tests and the D3 gate": `ext_p0.py` V0..V3,
  V5, V6 (with V6w/V6r) and V7, `ext_frames.py`, `ext_adapt.py`.
* **DESIGN.md 12.2**: the system menu's profile items (0x1090, 0x10A0 radio, the profile to come;
  0x10B0 Locate, grayed without the observer) and WM_INITMENU; the chord audit of D3b2; the Alt rule
  with K3's Ctrl/Shift rule in `present/arrive.c`; `test_window_d3b2`.
* **DESIGN.md 12.10**: D3a's two rows (the read-only accessors; `rgn.c`'s counted overflow) and the
  `--probes 0` sentence; D3b1's `gdi_pal.c` `w16_present` and `user_cursor.c` `w16_SetCursor` rows and
  the `W16_OBS_OTHER_*` ids; D3b2's `host_sync.c` row as built (`take_input`, `W16_OBS_OTHER_INPUT`,
  the post hook in `posted()`, `W16_TIMING_SCRIPT`), the host side's profile and locate hooks,
  `hw_messages`, `civ64_cfg_unset`, `civ64_locate_dos_choose` (with `owner`), `civ64_locate_set_ui`.
* **DESIGN.md 12.2 / 12.11** (civ64 options and settings): `--graphics windows|dos`; the key
  `graphics` read at the start (D3b1) and written by the player's accepted switch (D3b2, never from
  `--graphics`); the `--aspect` default 4:3.
* **DESIGN.md 12.5 / TRACE.md "observer probe" rows** (D3a): none exist yet; when added, each row
  starts `| observer probe |` and names the address, function and phases; `obs_lint.py` then checks
  them against `OBS_PROBES[]` (the 203 rows are in the probe verification, section 2).
* **FIDELITY.md**: X3 (the `--aspect` default 4:3, 320x200 frames only) and A 7.2's T6 pause (D3b1);
  F100's and F101's code reference `present/arrive.c`; F101: the chord key's repeats swallowed after
  the modifier's release, unpaired releases delivered as in S2; F114 implemented (with the lone-release
  order, Alt+Enter taking only Alt, no chord on a Backspace already down, a press outside the image
  leaving the held keys); F117 and F118 implemented (D3b2).
* **RUNNING.md**: `build.cmd checked noobs` / `test.cmd checked noobs`, `ext_g1.py check --variant
  CheckedNoObs`, `observer-probes.log`, `presentation-diag.log`, `--probes 0`, `obs_tables.py`,
  `obs_lint.py` (D3a); civ64 `--graphics`, the `--aspect` row, `--dump-presented`, the harness's
  `--graphics`, `--switch-every`, `--profile-samples`, `--dump-presented`, the commands `profile`,
  `policy`, `hostsize`, `profiles.log`, `presented.log`, `ext_p0.py`, `ext_frames.py` (D3b1); the system
  menu's profile items and Locate, the remembered `graphics`, the refusal cadence, `--host-input`,
  `--core-input-log`, `hostinput.log`, `coreinput.log`, `profiles.log`'s player lines and `withdrawn W`,
  `ext_adapt.py`, V7 (D3b2).
* **STATUS.md** (extension track): D3 complete (gate met in Checked, CheckedNoObs and Release on
  2026-10-11; this record and the three unit records); Asan deferred; next D4 (area C replaces the
  filter's stubs; the C-11 case with the real note).
* **manual-checklist-ext.md** D3 (user, pending): D3-1..D3-5 as written (now checkable); D3b1's item (a
  start with `--graphics dos`: the Windows picture at the monitor's rate, the X3 default changing
  nothing in the Windows profile); D3b2's items (the radio marks follow the chord and the menu at once,
  the picture at the next tick; a chord pressed twice quickly leaves the profile; Ctrl+Backspace,
  Ctrl+S, Shift+letter and Alt+Enter as before; `graphics` remembered at the next start).
* **FEATURES.md**: none (no game feature changed).
* **The D1 drafts**: D3a's items (the widened 12.10 list, the guard's arguments, the emission points);
  D3b1's (A 8.3's pseudo-code, A 12.2's `--switch-every` and toggle rules, `replaced Q`, E.2.2's include
  rule, V5's placement and V6w); D3b2's (A 10.1's `PiOut` size, focus-loss and capture-loss rules;
  A 10.2's chord action and chord-key rules, the hold-rule details, `civ64_locate_dos_choose`'s owner;
  A 11's marks, profile hook and grayed Locate; A 12.2's player lines; A 12.4's `hostinput.log`,
  `--script` with `--host-input`, the `--core-input-log` rules, sorted lines; A 13.1's V7; A 13.4's S3
  conversion; A 6.1's `W16_OBS_OTHER_INPUT`).
* **`obs_lint.py`** (D3b2's review): the uppercase `W16_` macros, `vm_` symbols outside area C and the
  include exemption are gaps without a current violation.
* **D3a's "For D3b"**: done (`obs_tick` filled, the Win32 debug-log diagnostics, the cursor route,
  `HostEvent.frame`, `host_sync.c`'s hooks; the never-hit keys re-derived from the P0 matrix, below).

## D3 user checks

The D3 section of [manual-checklist-ext.md](manual-checklist-ext.md) (D3-1 the lone Ctrl/Shift intro
skip at the release, D3-2 the chord during the intro without a skip and the game's own keys, D3-3
clicks with Ctrl or Shift held, D3-4 Locate during a run, D3-5 the refusal message then beeps and
`--graphics dos` without the DOS files) stays **pending**: the user checks it; no D3 unit ran civ64.

## Not verified

* Asan builds and tests (deferred by the user).
* civ64.exe was not started in D3: `obs_init`, `--graphics`, the start profile, the 4:3 default, the
  monitor-rate tick, the pixel cursor, the debug-log diagnostics, the chord, the menu items, the refusal
  message and beeps, Locate's dialogs and the remembered `graphics` key are compiled and covered by the
  Win32-headless tests (hidden window, `hw_window_message`, quiet mode, test seams) only; no picture was
  looked at.
* The Win32 tick clock's monitor change (one monitor); a real focus change with a button down.
* D3's DOS profile shows the Windows frame, so 7.4's sample identity holds by construction; the filter
  stage's adapter, note, release and ring run only with stubs and test tables until D4 and M.
* Probe hits: the final Checked P0 matrix hits 179 of the 203 keys. Never hit there: D3a's 11 that no
  base run reaches (`1000:4124`, `1018:17DB`, `1030:8C11`, `1098:28E4`, `10E0:0000`, `10E8:32C1`,
  `1180:17E9`, `11B0:237C`, `11B8:0C3D`, `1208:1534`, `1220:114B`; OBS_PAL_REALIZE and OBS_CTL_CHECK
  occur in no base run) and 13 that D3a's G-1 runs hit but the 27 scenarios of 13.1 do not reach
  (`1040:068E`, `1050:0000`, `1070:1952`, `1070:2015`, `1168:06C1`, `1188:0DB8`, `11A0:0000`,
  `11B0:1B63`, `11B0:1FAC`, `11B8:0000`, `11B8:0F26`, `11D8:087F`, `11D8:0BD2`; names in
  [ext-D3b1-record.md](ext-D3b1-record.md#probe-hits)). The G-1 outputs under `build/harness/game`
  are rewritten by `test.cmd checked noobs` (no observer logs), so their hits were not recounted.
* The reviewers of the three units were separate read-only agent sessions, not people; their findings
  were fixed or recorded by the implementers and not re-reviewed.

# Brief for the D3 implementers (extension phase D3)

Written 2026-10-11 by the orchestrator. Phase D3 of the extension prompt
`claude/docs/x64-port-scaling-dos-prompt.md` (section 9): "Observer, probes and presentation tick in `w16`;
composition; profile switching (the DOS profile may still show the Windows frame); the P0 test runner and
the 7.8 harness mode." Gate: "7.3 (without zoom) and 7.4 pass with switching; probe verification recorded."
Asan runs are deferred to the end of the queue (the user's direction of 2026-10-10 21:20; K8).

D3 is done in two sequential units, each by one implementer with exclusive ownership of the files it
changes: **D3a** (the observer core) and then **D3b** (presentation, switching, input stages, tests).

## Authority and design

* The design is DESIGN.md 12.5 (summary), 12.10 (the admitted w16 changes), 12.11 (scope of P0) and the
  detailed design `claude/port/docs/verify/ext-d1-draft-A.md` (Revision 3), with the resolutions in
  `ext-d1-decisions.md`. Interfaces other areas use are fixed there (B: `ext-d1-draft-B.md`, C:
  `-C.md`, D: `-D.md`, E: `-E.md`). Implement as written; where the code shows the design is wrong or
  incomplete, make the smallest correct fix and record it as a deviation (design section, what and why)
  in your acceptance record. Never widen 12.10's list of w16 changes without recording why.
* Area E's code (phase D2: `present/dos/pdos_*`, `host_dos_read`) exists; use its public API
  (`pdos_assets_status()` and the accessors) as `ext-D2-acceptance.md` documents it.
* The extension prompt (1 P0, 2.0, 4 D-2, G-1, G-2, 5.1, 5.2, 5.5 T2, 5.6 I1, I2, I7, 5.7, 5.11, 7.2,
  7.3, 7.4, 7.8, 8) and the base prompt `claude/docs/x64-port-prompt.md` sections 1 (language rules),
  5.0 (build), 7 (tests) and 9 (determinism) govern. Follow the conventions, style and comment density
  of the surrounding code.

## Rules

* **P0 above all.** No change may alter a core frame hash, a checkpoint, `events.log`, the emulated clock,
  `vm_steps`, `vm_site`, a handle number, a checked-build diagnostic, `g_randSeed`, the queue or the key
  state of any existing scenario. After every build: `test.cmd checked` (all base tests, gate3b
  references, scenarios) and `C:/Python314/python -B C:/Projects/Civ1RE/claude/port/tests/harness/ext_g1.py check`
  must stay green (EXT_G1_OK 77 runs). A failure is fixed before anything else.
* **Builds are yours alone** during your unit. `cmd /c C:\Projects\Civ1RE\claude\port\build.cmd checked`,
  `... test.cmd checked`, then Release (`build.cmd`, `test.cmd`); the new `checked noobs` variant where
  your unit adds it. No Asan (deferred). Timeout 600000 ms for these commands; logs under
  `claude/port/build/`.
* **Files.** Edit the code, tests and build files your unit needs (see the task) and write your
  acceptance record. Do not edit `DESIGN.md`, `FIDELITY.md`, `STATUS.md`, `RUNNING.md`, `FEATURES.md`,
  the D1 drafts or the D0 documents: list the needed entries under "For the records" in your record.
* **Independence and DOS rules** as before: never read the main project's excluded paths
  (`claude/port/docs/verify/BRIEF-d0.md` lists them) or use AGENTS.md's GFX/DOS/Modern/Mac/SNES sections;
  no DOS bytes in the repository or a binary (`gen/dos/nodos.py check` must pass); never write
  `C:\Projects\Civ1RE\dos` or `claude/port/build/dosdata`; never execute a DOS program.
* **UI.** Win32-headless tests use hidden windows (as `tests/win32`). You may launch a visible civ64 window
  for a short agent check only if your unit needs one (the UI-launch grant: civ64 windows only,
  screenshots under `claude/port/build/`); close it promptly. An agent observation is not user acceptance.
* No git writes. Use absolute paths; do not chain `cd` into shell commands. Python only as
  `C:/Python314/python -B` (never `-I`). Write files containing backslashes (C escapes, Windows paths)
  with the Write or Edit tool, never through heredocs or sed.

## Tasks

* **D3a: the observer core.** `vm.h`/`vm.c` (`CIV_OBSERVER`, the probe table and the hooks in `fr_enter`
  and `fr_leave`), `platform/w16/w16_obs.[ch]` (the `w16q_*` queries D3 needs, the emission macros, the
  Checked guard and forbid checks), the O1 emission sites in `gdi_*.c` and `user_*.c` (A 3.3; settle Open
  A2), `W16_TICK()` at the four tick sites calling a hook that D3b fills (a no-op until then),
  `present/observe.[ch]` (events, `ObsProbe`, dispatch to registered listeners, `OBS_PROBES[]`,
  `OBS_CALLSITES[]` generated or written per Open A1, `obs_callsite`, `obs_probe_phases`, `OBS_AT_EXIT`),
  `tests/harness/obs_lint.py` (the checks of A 6.2 that apply without B/C/D code; the consumer-table
  checks activate as those tables appear), `tests/test_observer.c`, the `checked noobs` build variant
  (`CIV_OBSERVER=0`, `build\x64\CheckedNoObs`), `ext_g1.py` run on both Checked and CheckedNoObs, the
  measured event and probe cost (Open A5), and `claude/port/docs/ext-D3-probe-verification.md` (each
  probe: the address verified against `claude/src` and showfunc, reads only, its phases). Record:
  `claude/port/docs/ext-D3a-record.md`.
* **D3b: presentation, switching, input stages and the P0 tests.** `present/profile.h`, `profile_win.c`,
  `present/dos/pdos_profile.c` (registered when `pdos_assets_status() == PDOS_OK`; in D3 it shows the
  Windows frame through the tick path, A Choice), `present_tick` and switching, re-layout, the cursor
  route (`present_cursor`, `host_set_cursor_pixels`, `user_cursor.c`), `present_core_xrgb`,
  `present_shown_indexed`, the arrival stage `present/arrive.c` (moved from `host_win32.c`, behaviour of
  S2 kept, plus the K3 hold rule, masked MK bits and the RV2-3 press latch), the filter stage
  `present/input.c` with `HostEvent.frame` (stubs for C's and D's functions until D4/M), `--graphics`,
  the key `graphics`, the system-menu profile items and the Ctrl+Shift+Backspace chord (audit recorded),
  "Locate DOS files..." (RV1-6), the refusal cadence (RV1-8), the 4:3 aspect default (X3), the harness
  commands and logs (`profile`, `policy`, `hostsize`; `profiles.log`, `--dump-presented`), the 7.8 mode
  (`W16_TIMING_SCRIPT`, `sync N`, `coreinput.log`), `tests/test_input.c`, the `test_present.c` and
  7.2 Win32-headless additions, `tests/harness/ext_p0.py` (7.3 without zoom: V0..V6 as A 13.1 defines,
  every DOS variation with `--dos-data build\dosdata`, switch assertions from `profiles.log`) and
  `ext_frames.py` (7.4), both added to `test.cmd checked`. Then write `claude/port/docs/ext-D3-acceptance.md`
  (the gate; the D3a record and the probe verification linked; deviations; "For the records"; the user
  checks of `manual-checklist-ext.md` D3 section left pending).

## D3b split (orchestrator, 2026-10-11 11:50 UTC)

D3a is complete (`claude/port/docs/ext-D3a-record.md`; read its "Left to D3b" and deviations first:
`obs_tick` is an empty hook, `GUARD_BEGIN(in, id)` takes arguments, `--probes 0` exists). To keep each
implementer's context lean, D3b is done in two sequential units with the same rules:

* **D3b1: presentation, switching and the P0 runners.** `present/profile.h`, `profile_win.c`,
  `present/dos/pdos_profile.c` (registered when `pdos_assets_status() == PDOS_OK`; in D3 it shows the
  Windows frame through the tick path), `present_tick` filling `obs_tick`, switching and re-layout, the
  cursor route (`present_cursor`, `host_set_cursor_pixels`, `user_cursor.c`), `present_core_xrgb`,
  `present_shown_indexed`, `--graphics` and the settings key `graphics`, the 4:3 aspect default (X3),
  the Win32 diagnostics log (`presentation-diag.log`), the harness commands and logs (`profile`,
  `policy`, `hostsize`; `profiles.log`, `--dump-presented`), the `test_present.c` and 7.2
  Win32-headless additions for these, `tests/harness/ext_p0.py` (7.3 without zoom: V0..V6 as A 13.1
  defines, except variations that need D3b2's input stages, which D3b2 adds; every DOS variation with
  `--dos-data build\dosdata`; switch assertions from `profiles.log`) and `ext_frames.py` (7.4), both
  added to `test.cmd checked`. Record: `claude/port/docs/ext-D3b1-record.md`.
* **D3b2: input stages, chord and menu, the 7.8 mode and the gate.** The arrival stage
  `present/arrive.c` (moved from `host_win32.c`, behaviour of S2 kept, plus the K3 hold rule, masked MK
  bits and the RV2-3 press latch), the filter stage `present/input.c` with `HostEvent.frame` (stubs for
  C's and D's functions until D4/M), the `host_sync` hooks, the system-menu profile items and the
  Ctrl+Shift+Backspace chord (audit recorded), "Locate DOS files..." (RV1-6), the refusal cadence
  (RV1-8), the 7.8 mode (`W16_TIMING_SCRIPT`, `sync N`, `coreinput.log`), `tests/test_input.c`, the 7.2
  Win32-headless additions for input and chords, the remaining `ext_p0.py` variations. Record:
  `claude/port/docs/ext-D3b2-record.md`, then the gate record `claude/port/docs/ext-D3-acceptance.md`
  (gate: 7.3 without zoom and 7.4 pass with switching; probe verification recorded; the three unit
  records and the probe verification linked; deviations; "For the records" gathered from all three
  records; the D3 user checks of `manual-checklist-ext.md` left pending; not verified).

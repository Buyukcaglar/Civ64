# Extension phase X9 (final audit and the one Asan pass) - audit record

Prompt: `claude/docs/x64-port-scaling-dos-prompt.md`, phase X9 (section 9): "Final audit: an independent adversarial
check of every section-4 item; the base suite unchanged; hashes; final report."  The result is "Done" or "delivered
with open items".  Session E4, 2026-10-18.  The auditor was a fresh agent that implemented no unit.  Phase 1 was a
read-only check of the records, logs and status files.  Phase 2 ran the one Asan pass (the user's direction of
2026-10-10 21:20) and then, on the orchestrator's ruling of about 18:20 UTC, completed the X9 gate's eight-step cycle.

Labels follow prompt section 10: **compiled**, **headless**, **Win32-headless**, **agent-observed**,
**DOS listing (model)**, **user-confirmed**.  No DOS-oracle run took place in the extension.  7.9 is optional, and the
fallback of prompt 2.2 applies, so every DOS pixel and timing claim is "DOS listing (model)".  This audit ran no DOS
program and no original game.  It wrote nothing to `C:\Projects\Civ1RE\dos`, `original/CIVWIN`, `build/dosdata`,
`build/gamedata` or `%LOCALAPPDATA%\civ64`, and made no git writes.

## Verdict

**Delivered with open items.**  Every implementation item of section 4 is met or met with a recorded caveat.

The Asan pass is clean:
* BUILD_OK and TESTS_OK.
* 67 test programs, each with the same check count as D7o's Checked run.
* EXT_G1_OK runs 77 under Asan.
* No AddressSanitizer report.

The base suite is unchanged in Checked, Asan, CheckedNoObs and Release.

The open items are these:
1. **G-3:** `TRACE.md` does not list the observer probes.
2. **G-4:** the session-end hash check belongs to the orchestrator and had not run when this record was written.
3. **User checks:** the user's checklist items are still pending.
4. **Comment-only source items:** carried to the next session.

The section "Open items" below has the details.

## Phase 2: the X9 gate's eight-step cycle (`build/x9-status.txt`, X9_ALL_GREEN)

Script `build/x9-prep/x9-cycle.ps1` (from `build/d7o-prep/d7o-cycle.ps1`). Each step is guarded by its log's last
line, not by its exit code.  It started at 18:24:43 UTC, after `build/docs-d8-done.txt` (18:24:30 UTC), with no other
build or test process running.

| Step | Time (UTC) | Log | Result |
| --- | --- | --- | --- |
| 1 `build.cmd asan` | 18:24:43..18:27:59 (195 s) | `build/x9-1-build-asan.log` | BUILD_OK variant=Asan |
| 2 `test.cmd asan` (serial, its default) | 18:27:59..18:55:15 (1637 s) | `build/x9-2-test-asan.log` | TESTS_OK variant=Asan |
| 3 `ext_g1.py check --variant Asan` | 18:55:15 | `build/x9-3-g1-asan.log` | EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) |
| 4 `build.cmd checked noobs` | 18:55:15..18:58:32 (196 s) | `build/x9-4-build-noobs.log` | BUILD_OK variant=CheckedNoObs |
| 5 `test.cmd checked noobs` | 18:58:32..19:04:15 (343 s) | `build/x9-5-test-noobs.log` | TESTS_OK variant=CheckedNoObs (P0_OK checks 62) |
| 6 `ext_g1.py check --variant CheckedNoObs` | 19:04:15 | `build/x9-6-g1-noobs.log` | EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) |
| 7 `test.cmd` (Release; D7o's Release build of 18:08:29 UTC, not rebuilt, the orchestrator's ruling) | 19:04:15..19:09:19 (304 s) | `build/x9-7-test-release.log` | TESTS_OK variant=Release |

With D7o's second cycle, these make the eight steps on the final tree:
* `build/d7o-1-build-checkedb.log`: BUILD_OK.
* `build/d7o-2-test-checkedb.log`: TESTS_OK, 17:38:19..18:05:09 UTC.
* `build/d7o-3-g1-checkedb.log`: EXT_G1_OK runs 77.
* `build/d7o-4-build-releaseb.log`: BUILD_OK Release, 18:08:29 UTC.

D8 changed only documents after that cycle (`build/docs-d8-done.txt`).  Its own checks after applying were all OK:
* CHECK_DOCS_OK, NODOS_OK, OBS_TABLES_OK and OBS_LINT_OK.
* `pdos_scene_check` PASS 1086, ADAPT_OK and REGISTRY_OK.
* `build/docs-d8-stage/checks/`.

Before X9, the D6 gate (`build/d6-gate-status.txt`, 2026-10-17 06:02:50 UTC) had been the last CheckedNoObs and
Release test runs.  D7a..D7o landed with three-step cycles and Release builds only.  Steps 4..7 close that gap for the
final tree.

## The Asan result

* **Build:** `build.cmd asan` BUILD_OK.  These are the Checked definitions plus `/fsanitize=address`, with warnings
  as errors.  The previous Asan build was from 2026-10-10 23:47 local time (E1), so the extension's code from D0 to
  D7o was never built under ASan before this pass.
* **Tests:** `test.cmd asan` TESTS_OK in 1637 s, serial.  It ran these:
  * the 67 test programs;
  * REGISTRY_OK, NODOS_OK, GATE3B_OK, P4_SCENARIOS_OK and P4_TESTS_OK;
  * OBS_TABLES_OK probes 203 sites 103, OBS_LINT_OK files 152, ADAPT_OK rows 166 steps 27 and TRACE_OK.

  The extension's harness checks (UNINIT, P0, EXT_*, MIRROR, REPLAY, ZOOM) are Checked-only in `test.cmd` by design,
  so they did not run under Asan.  Every test program's check count equals D7o's Checked run
  (`build/x9-prep/suitecmp.txt`).  Among them:
  * `test_dos` 23,293, which includes D2's 3,894 truncations and 10,816 bit flips of the DOS files, and the malformed
    vectors of every decoder.  This closes the "rejected cleanly under ASan" part of prompt 7.6 and D-1.
  * `test_zip` 5,869, `test_present` 956, `test_input` 698 and `test_host_win32` 453.
  * Every `test_pdos_*` program.
* **ASan reports:** none.  `build/x9-2-test-asan.log` contains no "AddressSanitizer" line.  The test log captures
  stderr (`2>&1`).  Nothing needed triage.

  The log does contain a few lines that look like failures, but each is a deliberate negative case and also appears
  in D7o's Checked log:
  * `w16: activate ... Error`;
  * `failed_file FONTS.CV` (the injected failure);
  * `injected failures: 15 cases`;
  * the harness's allowlist note.
* **G-1 under Asan:** EXT_G1_OK runs 77.  `build/harness/Asan/*` and the shared `game/*` runs keep the baseline's core
  frame, state and event hashes, with only the recorded P47-R2 amendment.
* **Not covered by this pass:**
  * leak checking: MSVC's ASan on Windows has no LeakSanitizer;
  * the Win32 `civ64.exe` itself under ASan (built, not started);
  * `test.cmd asan parallel` against serial: CY's follow-up, not run, because serial is the default and is what
    G-1 names.

## The base suite against the last cycle

`build/x9-prep/suitecmp.py` puts six logs side by side, with the per-program check counts and the OK markers, in
`build/x9-prep/suitecmp.txt`:
* D7o's Checked;
* X9's Asan, CheckedNoObs and Release;
* the D6 gate's CheckedNoObs and Release.

* **The base track's test programs are unchanged in every variant.**  These are `test_ne`, `test_acc`,
  `test_commdlg`, `test_dir`, `test_float`, `test_gdi`, `test_heap`, `test_io`, `test_math`, `test_printf`,
  `test_queue`, `test_rt`, `test_sha`, `test_start`, `test_stdio`, `test_time`, `test_user`, `test_vm`,
  `test_worldsim` and `test_zip`.  Each count equals D7o's in the same variant class.  The only differences are
  between variants and are pre-existing:
  * Release `test_acc` 11, `test_vm` 51 and `test_worldsim` 17 against 35, 66 and 33: Checked-only checks.
  * These equal the D6 gate's Release counts.
* **The base harness is unchanged:**
  * GATE3B_OK, with the 7, 2, 3 and 12 checkpoint snapshots equal to the recorded reference and the repeats byte for
    byte;
  * UNINIT_OK in Checked and CheckedNoObs;
  * P4_SCENARIOS_OK and P4_TESTS_OK in Checked, Asan and CheckedNoObs;
  * EXT_G1_OK runs 77 in Checked (D7o), Asan and CheckedNoObs.
* **The extension's programs move only as the units' landings recorded.**  From the D6 gate to X9, for example:
  * `test_dos` 23,239 -> 23,293;
  * `test_input` 446 / 502 -> 641 / 698 (CheckedNoObs / Release);
  * `test_pdos_reskin` 110 / 121 -> 217 / 229;
  * new programs, among them `test_pdos_arrive`, `_city`, `_cityview`, `_end`, `_leader`, `_menu`, `_news`,
    `_palace`, `_pedia`, `_rdlg`, `_report` and `_space`;
  * OBS sites 101 -> 103.

  CheckedNoObs `test_pdos_scene` has 149 checks against 148 in Checked and Release.  That is an observer-free branch
  of an extension test, not a base test.

## Section-4 items

Each row names the evidence the auditor read and what the auditor checked again.  The method labels are those of
section 10.

| Item | Evidence | Adversarial check | Result |
| --- | --- | --- | --- |
| **S-1** windowed mode | `ext-S2-acceptance.md` (7.2 `test_window_s2`; agent UI check); `ext-G-acceptance.md` | Read the gate tables. The minimum 640x480 client, the maximize box and centring with black borders are Win32-headless and agent-observed; the user's check passed 2026-10-10 | **met with caveat**: `stretch` was removed (phase G, user decision). The game desktop takes the host client's size at the game's start and follows the window during the game (F105, F110, user decisions), so resizing does reach the emulation's screen size in play. A recorded user deviation from "Resizing never reaches the emulation"; same-seed play across window sizes is not expected to match |
| **S-2** full screen | `ext-S2-acceptance.md`; FEATURES host row "Full screen" | WS_POPUP over the hidden window's monitor, not topmost, restore of the placement (Win32-headless); agent-observed full screen 2560x1600 at k=3; display mode never changed | **met**; the user check passed (S2); there is no checklist item for full screen alone (FEATURES) |
| **S-3** mapping, cursor, DPI | `ext-S1-acceptance.md` (inverse mapping), `ext-S2-acceptance.md` (cursor recreation, WM_DPICHANGED), UX1 (pointer factors) | Re-read the not-verified lists | **met with caveat**: DPI v2 tested only with a synthetic WM_DPICHANGED; no real move between monitors of different DPI (S2, G) |
| **S-4** tests | 7.1 `test_present` 956 checks (all four variants above); 7.2 `test_host_win32` 453 (408 CheckedNoObs); S2 agent UI check; checklist | Counts re-read from X9's logs | **met**; user confirmation listed as pending where pending |
| **Z-1** zoom levels | `ext-M-acceptance.md` (Windows), `ext-D6-acceptance.md` "Z-1..Z-3 for the DOS profile" | `test_map` 342 (Checked, Asan, Release), ext_adapt zoomkeys(-dos), `ext_zoom` | **met**; the M agent UI check was interrupted, but D6's agent check covered the DOS zoom (shots 07..17); the user passed M-1..M-7, MZ-1..MZ-7 and D6d items |
| **Z-2** map renderer | M1 mirror checks (key 6,925, render 1,229, settled 86; 0 mismatches); MIRROR_OK runs 29 with `dos_mismatched 0` (D7o cycle); ZOOM_OK 628 samples | Markers re-read in D7o's Checked log | **met with caveat**: mirror equality covers what the 29 runs reach (RedrawMapRect never reached; M "Not verified") |
| **Z-3** input and P0 | ext_adapt ring/ringref (Windows and DOS); `ext_p0` V4 and V4d; CheckedNoObs V5 | P0_OK checks 477 (D7o Checked), 62 (X9 CheckedNoObs) | **met** |
| **D-1** assets at run time | `ext-D2-acceptance.md` (pins, EXEPACK 203,584 bytes and 2,525 relocations equal to CIV_UNP.EXE's load module, decoded goldens 0 differing, malformed input); NODOS_OK | `test_dos` 23,293 under ASan clean (this pass); NODOS_OK in all four variants; the user's six screenshots and GIF under `docs/screenshots/` (the user's exception of 2026-10-18 08:05) pass the nodos scan | **met**: the ASan part is closed by this pass. Decoders follow the listing by the Python models D0 checked against the listing (DOS listing (model)). The screenshots are DOS-derived images by the user's explicit exception |
| **D-2** switching and P0 | `ext-D3-acceptance.md` (V2 1,866 switches, V7 chords); `ext_frames` (A = A' = B = C); D7o full runs P0_OK 521 | EXT_FRAMES_OK in D7o's cycle and its full runs (16 checks with the real DOS frames of D4..D7) | **met** |
| **D-3** before the game | D4 gate (7.7 timelines, 7.8 adapters), BS gate, D4cF; FEATURES title rows | EXT_TIMELINE_OK and EXT_BS_OK in D7o's cycle; user passed D4-4..D4-29 and D3-1..D3-10 (most), BS | **met with caveat**: DOS timing, palette and pixels are "DOS listing (model)" ("derived from the listing, not observed", prompt 2.2); some user items are still pending |
| **D-4** setup and branches | D5 gate (29 DOS-form pairs), SL, D5K, D5P; DOS-PROFILE W3 (file choosers and `host_confirm_overwrite` class W with reason) | DOS-PROFILE 4 / W3 read | **met** (DOS listing (model)) |
| **D-5** play | D6 gate (map, small map, Status window, menus), D7 gate: 80 D7 rows (27 ready, 4 spanning, 1 A, 40 by unit tests and pairs, 8 W with reasons); counterpart ledger 140 rows and 7 effects closed | D7 ledger and counters (every D4..D7 row 0, no ROW_ALLOW) read from `ext-D7-acceptance.md` and D7o's `obj/full/steps.txt` (the full runs 16:05..16:45 UTC: P0 521, FEATURES_REACH_OK rows 108 dos 104 w 4, ext_adapt 421, ZOOM 628) | **met with caveat**: 5 D7 rows (DrawCivDossier, DrawBeveledLabelBox, AnnounceGovernmentChange, PlayCelebrationAnimation, FrameRectDoubleDevice) are reached by unit vectors only; OPEN L1/O7/O8 remain as `dos/OPEN.md` lists them |
| **D-6** register | `DOS-PROFILE.md` (D8); `pdos_scene_check` 1086 checks / 141 scene rows / 11 font rows; ADAPT_OK; OBS_TABLES_OK | Checked after D8's apply (D8 checks) and in X9's three suites (ADAPT_OK, OBS_TABLES_OK) | **met** |
| **D-7** features | `FEATURES.md` "DOS columns of every row" (108 rows: N 53, R 29, A 21, W 5) and "Host window (extension)" | Hashes checked against `build/harness/Checked/p0/V1/*/presented.log`: title.customize df19e53e... (run `custom`), title.hall-of-fame e32e308f... (present 946 of run `arrival`), title.load and screen.palette 123bf878... (presents 376..377) | **met with caveat**: "Looks like DOS" is claimed only for the user-confirmed rows (the rule holds). The four host rows (full screen, resizable window, map zoom, graphics switch) exist, but their frame column is "-" (host frames; their DOS class is stated in prose, not per row). A stable frame's listed time is the start of features.py's interval, not the present's own time (hall of fame: 99,030,950 us listed; present 99,000,950 us) |
| **G-1** no regression | X9's eight-step cycle above; D7o Checked | EXT_G1_OK 77 in Checked, Asan, CheckedNoObs; base programs unchanged in all four variants | **met with caveat**: one user-decided base-track amendment, P47-R2, alters 6 frames of `game/p4-menus` (frames and events, `ext-g1-amend.txt`, checked by `rest=`); the state field is never amended |
| **G-2** build checks | `build.cmd` portable loop (`/std:c11`, `/std:c17` `/W4 /WX`, clang-tidy C99 parse) in all builds; Asan builds | BUILD_OK Checked (D7o), Asan, CheckedNoObs (X9), Release (D7o) | **met**: no warning survives `/WX`; the Asan tests are clean (above) |
| **G-3** records | `DESIGN.md` 12 "Extension"; `FIDELITY.md` (through F321); `RUNNING.md`; `docs/dos/` (EXECUTABLE, FORMATS, PALETTE, SPRITES, SCENES, SCENES-PLAY, TIMING, OPEN, CORRESPONDENCE, OFFSETS, DRIVER, WINDOWS-INVENTORY, dos-hashes) | Searched `TRACE.md` for observer probes | **open**: `TRACE.md` lists no observer probe. Its only rows are generated by `gen/trace.py` (functions, adapters, imports). The 203 probes are listed only in `ext-D3-probe-verification.md` (D3a; DESIGN.md 12.5 describes them without a per-probe table) and are checked by `obs_tables.py --check`. DESIGN.md (line about 2455) still says no "observer probe" row exists |
| **G-4** hashes | session start E4 2026-10-17 07:21 UTC: HASH_BEFORE_OK 38, DOS_HASH_BEFORE_OK 176 (`docs/hashes/20261017T072114Z-*`) | - | **open at writing**: the session-end check (`build/e3-orchestrator/hashcheck.ps1`) is the orchestrator's |

## Carried items assigned to X9

* **Customize World's Escape (STATUS "Test open items"; FCE; F195): confirmed.**
  * The target: `g_worldParams` is 12D8:38F4 (`claude/src/include/civ_globals.h`), and worldParams[-200] is 400 bytes
    lower, 12D8:3764.  `g_advanceSource` is `signed char[8][72]` at 12D8:36B0, and 0x3764 - 0x36B0 = 0xB4 = 2*72 +
    36, so the write sets g_advanceSource[2][36] and [2][37].  The write is inside the emulated DGROUP.
  * The data segment lists five references to `g_advanceSource` (`claude/src/data/seg092_12D8.asm`):
    * GiveAdvance (1170:2B10) writes it;
    * InitCivilization (10E8:1428) sets every byte to -1 when the game begins after Customize World;
    * SerializeGameData (10F8:0D71, 0x240 bytes) replaces it on a load;
    * ShowPediaEntry (1068:1766, 1068:17C9) reads it for the human civ in a running game.
  * So the value never reaches play.  The write is harmless, as FCE recorded.
* **`w32_test_host_win32` flake** (lines about 1206 and 1240: GetKeyState with a real key held): not seen in X9's
  runs.  It is not fixed and stays open.
* **The coverage torn lines:** informational.  "Other functions entered" read 650 under Asan.  Not changed.

## Open items

1. **G-3:** add the observer probe rows to `TRACE.md`, each starting `| observer probe |` (D3a's rule), for example
   from `obs_tables.py`.  Then update DESIGN.md's sentence.  This is a documents and generator change, and it needs
   `trace.py --check` to stay TRACE_OK.
2. **G-4:** the session-end hash checks of `original/CIVWIN` and `dos/` (the orchestrator, at the session's end).
3. **User checks:** the pending items of `manual-checklist-ext.md` (175 open at 18:08 UTC by D7o's user build note).
   This is the user's end-of-development bulk check (the user's direction of 2026-10-17 07:40).  Failed items are
   reworked as one batch.
4. **Comment-only source items** (the orchestrator's ruling: no source edits in X9; for the next session):
   * `win64/civ64_main.c`: the comment above `remembered_placement` ("meets no monitor ...", UX4);
   * `platform/w16/host.h`: the comment of `host_set_cursor_pixels` ("logical pixels of the presented frame", UX1);
   * `platform/win32/host_win32.c`: the comment of `cursor_factors` ("the Windows game cursor's pixel size ...",
     UX1b);
   * `tests/headless/harness.c`: the command names end at `PI_CMD_ZOOM_RESET` (no `PI_CMD_CLOSE`, UX1);
   * `tests/harness/scenarios.py` p4-menus: "Escape closes it" (FCE finding 6; Windows Escape does not close Find
     City).

   The UX1 note on `present/present.h` no longer matches the source and needs no change.
5. **Test flake:** `w32_test_host_win32`'s GetKeyState checks (above).
6. **Not verified, carried from the phase records:**
   * DOS-oracle comparisons (7.9, optional; not run);
   * a real multi-monitor DPI move;
   * same-seed and full-game qualification;
   * RedrawMapRect's settled check;
   * the probe keys no run hits (D3);
   * the costs measured on one machine;
   * WL (windowless play) and the extras AMS, A43 and CRT, moved to the next session by the user (2026-10-18 06:42).
   * CY's follow-up "make `test.cmd asan parallel` the default after a cy_equiv proof" was not done.  This pass ran
     serial.

## Method notes

* Counts were taken from the logs, not from the records.  Every count this record quotes was read in a log named
  here.
* The hashes in FEATURES were spot-checked against the presented logs D7o's cycle wrote.  The other rows were not
  recomputed.
* Phase 1 read the acceptance records, STATUS, the D7 gate and D7o's record (`obj/full/steps.txt`), the status files
  and `tests/harness/ext_g1.py` with its amendment list.
* Phase 2 ran only the commands listed above.  Asan was run once.

# Phase 8 acceptance record: final audit

Phase 8 (prompt section 9): "Final audit: an independent adversarial check of every section 4
item; re-hash the originals; the README line; the final report." Gate: "Done, or 'delivered with
open items'."

**State, 2026-10-10 (UTC): delivered with open items.** The final report is
[final-report.md](final-report.md); its section 3 lists the open items.

## 1. The independent audits (2026-10-10 15:09..15:25 UTC)

Three auditor agents, each given only the prompt, the port's records, the recovered inputs
(`claude/`) and the logs, with no write access except their own report and no build, test, UI or
original runs (brief: section 5 below). Their reports are stored unchanged:

| Auditor | Items | Report | Verdicts as found |
|---|---|---|---|
| A | 1 Build, 2 Assets, 10 Usage; no original bytes; host isolation | [verify/phase8-audit-A.md](verify/phase8-audit-A.md) | all met with caveats; 11 minor findings A1..A11 |
| B | 3 Features, 5 Files, 9 Fidelity register | [verify/phase8-audit-B.md](verify/phase8-audit-B.md) | 3 and 5 met with caveats; 9 not met as "complete" (B12 blocker: no fonts entry); B1..B19 |
| C | 4 Rules, 6 Original bugs, 7 No undefined behaviour, 8 Traceability | [verify/phase8-audit-C.md](verify/phase8-audit-C.md) | 4 not met as worded (C1 blocker: no checkpoint state compared with a reference); 6 and 7 met with caveats; 8 met (recounted); C1..C14 |

## 2. Resolution of the findings

| Finding | Resolution (phase 8) | State |
|---|---|---|
| C1, C2 (item 4: no checkpoint reference; determinism only by hand) | `tests/harness/gate3b.py` now checks every checkpoint snapshot of S2, S2b, S2c and S3 (24 snapshots: after load, before each save, each turn, after world generation, after setup, each Space; all images, the emulated stack and the global blocks, unmasked) against the SHA-256 in `tests/harness/gate3b-golden.txt`, and runs S2 and S3 a second time and compares every snapshot byte for byte. The reference is the port's own earlier run (**model, self-consistency**), not the original. The Checked and the Asan builds give the same 24 snapshots; `test.cmd` now runs the gate in both | fixed; headless-tested |
| C3 (mask) | The comparisons above are unmasked (stricter than the mask); the handle-field part of the mask, needed only for comparisons with other programs, stays open (`DESIGN.md` 9) | open (no comparison needs it) |
| C4, C5 (checkpoint placement, an unimplemented seed option in DESIGN) | recorded here: after-worldgen is taken where BeginWorldCreation returns (11E0:01B2), before-save at 10F8:0370, "turn" at the start of each turn; the world seed is injected by `test_worldsim.c`, not by a harness option | recorded |
| C6, C7 (item 6 overstated; R5 not cited) | `phase-4-acceptance.md` phase-8 note; FIDELITY F93 | recorded; item 6 met with caveats |
| C8 (no C9 hang test) | not added | open |
| C9 (divide-error and float-entry entries) | FIDELITY F92 | fixed |
| C10 (no record that every 32-bit arithmetic site was checked) | not done in phase 8 | **open** (item 7) |
| C11 (stack depth in the records) | auditor C's measurement from the current runs: lowest emulated SP 0xCB08, a 5,706-byte margin, no overflow | recorded |
| C12 (allowlisted ids without entries) | FIDELITY F91 | fixed (general rule) |
| C13 (Asan does not run gate3b) | `test.cmd` runs `gate3b.py` in Asan too; `uninit.py` stays Checked-only | partly fixed |
| C14 (TRACE wording) | not changed (the mapping is correct) | recorded |
| B12, B13, B14, B16, B18 (register gaps) | FIDELITY F88 (fonts), F89 (time, Q1..Q4), F90 (open questions), F91 (out-of-range and fault sites), ids for F4, F5, F8 | fixed; F90 leaves the per-question re-check open |
| B15, B17 (F1 selector policy; F10 address) | F1 rewritten (reuse after about 3,450 allocations, review B2, pending the user); F10 and `DESIGN.md` 3.1 name the statement 1030:28A7 and the address 12D8:4642 of the fault run | fixed |
| B1 (22 accelerators never pressed) | stated in `FEATURES.md` | open (no new scenario) |
| B2 (sound row) | the Sound row says the call was reached and that no sound was heard | fixed |
| B3, B4, B6 (templated texts, shared hashes, rows without an own scenario) | not changed | recorded |
| B5 (cmd.503 best result) | `FEATURES.md` statuses exclude the run c7-menus (superseded by c7-menus-c64) | recorded |
| B7 (stale "Last run" cells) | S2..S5 cells updated; S1's cell still names g-26 (before F85) | partly fixed |
| B8, A2 (no Release test of the final binary) | all three variants built and tested after the phase-8 changes (section 3) | fixed |
| B9, B10 (synchronized scenario only load-then-save; stale-tail tests for famehall/.rep) | stated in `phase-7-acceptance.md` | open |
| B19 (re-hash) | section 4 | done |
| A1 (`<stdio.h>` in `platform/w16`) | removed from `user_menutrack.c` and `user_misc.c` (own decimal text) | fixed |
| A3 (strength of the c99 clang parse) | not changed | open (caveat) |
| A4 (`'vswhere.exe' is not recognized` at the top of every build log) | the message is printed while `scripts/Setup-Msvc.cmd` prepares the MSVC environment (`build.cmd` line 10); that script may only be executed, not read (prompt 2.3), so its cause was not examined; the build continues and every build ends BUILD_OK with warnings as errors | recorded |
| A5 (the original folder through a junction, link or substituted drive) | `civ64_open_data` also refuses the directory's final path (GetFinalPathNameByHandleW); Win32-headless check of the `\\?\` form | fixed; the link case itself is not exercised |
| A6 (DOS device names) | `hw_valid_relpath` refuses CON, PRN, AUX, NUL, COM1..9, LPT1..9 in any component; FIDELITY F94; checks | fixed |
| A7, A10 (RUNNING: replay name; Windows version; Help) | `RUNNING.md` corrected | fixed |
| A8 (failure branches "met" but not exercised) | `phase-6-acceptance.md` phase-8 note | recorded |
| A9 (`--timing` default) | default is now `classic` as prompt 5.5 says (`civ64_start.c`, `DESIGN.md` 6, `RUNNING.md`, test) | fixed |
| A10 (Help menu: no message box) | `w16_WinHelp` shows a message box for every command except HELP_QUIT (FIDELITY F84); `p4-menus` closes it with Enter; the agent viewed the new frame (p4-menus stable frame 1788: the box "Civilization Help" over the map) | fixed; agent-observed headless |
| A11 (`inventory/strings.md` lists 1,001 original strings) | the phase-0 inventory the prompt requires ("string literals with addresses"); the same texts are in the recovered inputs (`claude/src`); local and unpublished, nothing of it is compiled into `civ64.exe` (auditor A's byte scan) | recorded |
| font check against GDI (prompt 5.5) | not done | open (F88) |
| icon | FIDELITY F95 | recorded |

## 3. Builds and tests after the phase-8 changes

| UTC | Command | Result |
|---|---|---|
| 15:3x | `build.cmd checked`, `gate3b.py Checked --record` (writes the reference), `build.cmd asan`, `gate3b.py Asan` | BUILD_OK; GATE3B_OK in both (REF 24 snapshots, REP S2 7 and S3 12 snapshots byte-identical); the Asan snapshots equal the Checked reference |
| 15:3x..15:44 | `test.cmd checked` | TESTS_OK: `test_host_win32` 104 checks, GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK (108 of 108 rows), P4_TESTS_OK, TRACE_OK |
| 15:4x..16:00 | `test.cmd asan` | TESTS_OK: `test_host_win32` 104 checks, GATE3B_OK, P4_SCENARIOS_OK, P4_TESTS_OK, TRACE_OK, no AddressSanitizer report |
| 16:01..16:03 | `build.cmd`, `test.cmd` (Release; the final `civ64.exe`) | BUILD_OK (warnings as errors); TESTS_OK: `test_host_win32` 104 checks, TRACE_OK |

## 4. Hash check of the originals

2026-10-10 16:03:23 UTC (`hashes/20261010T160323Z-after.txt`, the inline snippet of prompt section 10, no project scripts): 38 of 38 files present, every SHA-256 equal to `claude/docs/original-hashes-before.txt`, attributes and LastWriteTimeUtc unchanged since the session-start record `hashes/20261008T115412Z-before.txt`: **pass**.

## 5. Labels (prompt section 10)

* **Compiled:** civ64.exe and the tests in Release, Checked and Asan with the phase-8 changes.
* **Headless-tested / Win32-headless:** the suites above; the checkpoint reference and repeats
  (model, self-consistency).
* **Agent-observed:** the Help message box frame (headless); the audits' static findings.
* **Oracle-compared:** unchanged from phase 7 (two save files byte-identical; key behaviour).
* **User-confirmed:** none yet for civ64 (asked 2026-10-10 about 15:07; pending).
* **Unverified:** the open items of the final report.

The auditors' brief (scratch `p8/brief.md`, summarised): read only `claude/` and the logs; never
read the main project's folders; write only the own report; no build, test, UI, OTVDM or original
run; Python only for reading; be adversarial (sample rows, recount, check labels against
methods); verdict per item (MET / MET WITH CAVEATS / NOT MET / NOT VERIFIABLE STATICALLY) with
evidence and numbered findings.

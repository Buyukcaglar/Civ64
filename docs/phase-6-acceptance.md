# Phase 6 acceptance record

Phase 6 (prompt section 9) is the full Win32 build of `civ64.exe`. Gate: "Clean build;
data-directory verification; `RUNNING.md`." (prompt 4 items 1, 2 and 10.)

**State, 2026-10-10 12:25 UTC: the gate is met.** The last table line records the final builds:
Release, Checked and Asan BUILD_OK with linker /WX at 12:24, Release TESTS_OK. The labels of
prompt section 10 are kept apart at the end.

| Gate item | Method | Result |
|---|---|---|
| 1. Clean build | `cmd /c C:\Projects\Civ1RE\claude\port\build.cmd`: MSVC x64 Release, `/MT`, `/W4 /WX` with the recorded `/wd4702` only; the linker now also runs with `/WX` (a linker warning fails the build; the Win32 and headless test programs link with `/SUBSYSTEM:CONSOLE`, which removed LNK4031); the three language checks (c11, c17, c99 parse) of the portable sources | **met**: BUILD_OK variant=Release at 12:18 (226 portable sources checked; `build/link-civ64.log` holds only the full-link note) |
| 2. Data-directory verification | `win64/civ64_start.c` (`civ64_open_data`): the original directory (`\original\CIVWIN`, any case) refused; a missing or unreadable directory; a missing, unreadable, wrong-size or wrong-SHA-256 `civ.exe`; each with a message box naming the cause and exit code 2. Win32-headless: `test_host_win32` checks each refusal and the accepted test copy. Agent-observed: civ64 on a copy whose `civ.exe` has one byte changed | **met**: test PASS (98 checks) in all three variants; civ64 showed "civ.exe in …\w32-hash is not the pinned version (its SHA-256 differs)." and exited with code 2 |
| 3. `RUNNING.md` | `docs/RUNNING.md`: requirements, building, preparing a data directory, the command line `civ64.exe [--data <dir>] [--scale auto\|1\|2\|3] [--timing classic\|host] [--dump-frames <dir>]`, playing, files written (data directory only), exit codes, known deviations (link to `FIDELITY.md`) | **met** (written; not yet read by the user) |
| Command line and port-level failures (prompt 4 item 10) | `civ64_parse_args` (unknown or malformed options: the usage or the option's rule), `civ64_open_dump`, `civ64_check_fonts` (vgasys.fon), the window and DIB section (`hw_create_window` -1 / -2) | met: Win32-headless checks of every option rule; `--dump-frames` writes 8-bit BMPs (agent-observed: 173 frames of 308,278 bytes in 8 s at `--scale 1`) |
| All variants | `build.cmd` Checked, Release, Asan; `test.cmd` in each (11:51–12:16, scratch `frchk/all3-p56.cmd`); start-up g-51 | TESTS_OK in all three (Checked: GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK, P4_TESTS_OK, TRACE_OK); g-51 equals g-50 (final snapshot a0d7593a…, 444 frames, 0 out-of-range records). After the linker change (12:16–): see STATUS "Last build and test results" |

## Labels (prompt section 10)

* **Compiled:** civ64.exe in Release, Checked and Asan; clean Release build with compiler and
  linker warnings as errors.
* **Headless-tested / Win32-headless:** the full suites; `test_host_win32` 98 checks (option
  parsing, every data-directory refusal, the dump directory, the font check, the frame format).
* **Agent-observed:** the refused `civ.exe` (message box text, exit code 2); a `--dump-frames`
  run at scale 1 (the opening credits drawn; 173 frames). Phase 5's smoke run at scale 3.
* **Oracle-compared:** none in this phase.
* **User-confirmed:** none yet for civ64 itself (`RUNNING.md` and a first play are for the user).
* **Unverified:** behaviour on a DPI change, sound output, the visible file dialogs, long play
  under both timings; the full bring-up is phase 7.

## Phase 8 note (2026-10-10, audit A8; `verify/phase8-audit-A.md`)

"Met" for the port-level failures means implemented, reviewed and partly exercised: the option
errors and every data-directory refusal are tested, but the DIB-section and window failures,
"civ.exe could not be loaded" and the out-of-memory exit (code 4) were never exercised, and the
font check only tests that `vgasys.fon` can be read (an unparseable file falls back to the first
added face without a message; FIDELITY F88). Phase 8 added the refusal of the original
directory through its final path (junctions, links, substituted drives; audit A5) and the
refusal of DOS device names (F94); see `phase-8-acceptance.md`.

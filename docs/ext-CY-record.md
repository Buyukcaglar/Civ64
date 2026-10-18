# Extension unit CY (a faster build-and-test cycle without dropping any test) - record

Unit CY makes the test runs and the phase gates' builds faster without removing, weakening or skipping
any test: `test.cmd` runs its sections at the same time (bounded), keeps every section's output and
prints it in the old order with the old markers and counts, and keeps the old sequential order behind
`serial`; `build.cmd all` builds the gate's three variants at the same time after one generation step.

Brief: [verify/BRIEF-cy.md](verify/BRIEF-cy.md) (the user's decision of 2026-10-15 about 14:09 UTC: the
cycle rule B and this unit, E). Session E3, 2026-10-15. Staged in `build/cy-stage` until the build slot
(the orchestrator's staging protocol); the sequential baseline is the D4 gate's eight-step run
(`build/d4c2-status.txt`, the orchestrator's decision in EXT-HANDOFF.md of 16:20 UTC).

Labels:

* **measured**: wall times from status files, the runner's `times.txt` and the modification times of a
  run's output files (seconds).
* **headless**: `test.cmd` runs and `ext_g1.py check`.
* **digest**: `tests/harness/cy_equiv.py` over the files a run wrote.

Scope:

* No test, check, expectation or golden was removed or changed; no compiler flag, source or build output
  changed. Not edited: `core/`, `rt/`, `platform/`, `present/`, `gen/` outputs, `win64/`, every test's
  checks, every document other than this record (the rest is under "For the records").
* Files: `test.cmd`, `build.cmd`, `tests/harness/ext_p0.py` (option plumbing only, below), new
  `tests/harness/testpar.py` and `tests/harness/cy_equiv.py`.
* No git command that writes; nothing written to `C:\Projects\Civ1RE\dos` or `build/dosdata`; no UI;
  Asan not built or run.

## Status

DONE. `test.cmd` runs its 21 sections (24 since the BS landing, 2026-10-15) in parallel (bounded: at most `CIV_TEST_BUDGET` processes, 20 by
default), prints them in the old order with the old markers and counts, and keeps the old order
behind `serial`; `build.cmd all` builds Checked, CheckedNoObs and Release at the same time. The parallel
runner's equivalence with the old sequential run is shown on the same binaries for Checked, CheckedNoObs
and Release (section 5: every marker and count equal, every run directory's frames, state and events
equal, every other difference a wall-clock value, the tree's own change or the coverage report's existing
variation). The eight-step cycle with the final files and `build.cmd all` ended `ALL_GREEN` in 2,503 s
(42 min) against the D4 gate's 4,452 s (74 min); `test.cmd checked` 1,166 s against 2,279 s (section 6,
"Before and after").

## 1. Measurements before CY (item 1)

Eight-step cycles (measured, `build/<unit>-status.txt`):

| step | d4b4 (unloaded) | d4c2 (the D4 gate; CY's sequential baseline) |
|---|---|---|
| 1 `build.cmd checked` | 195 s | 284 s |
| 2 `test.cmd checked` | 1,952 s | 2,279 s |
| 3 `ext_g1.py check` | 0 s | 0 s |
| 4 `build.cmd checked noobs` | 197 s | 254 s |
| 5 `test.cmd checked noobs` | 766 s | 906 s |
| 6 `ext_g1.py check --variant CheckedNoObs` | 0 s | 0 s |
| 7 `build.cmd` | 203 s | 212 s |
| 8 `test.cmd` | 421 s | 517 s |
| in all | 3,734 s (62 min) | 4,452 s (74 min) |

A build (measured from the object files' times, d4b4 Release and CheckedNoObs): about 6 s generation
(`dispatch`, `interfaces`, `oob_allowlist`, `registry.py gen`), about 164 s for the 272 portable sources
one after another (each `/std:c11`, `/std:c17` and the clang-tidy C99 parse, about 0.6 s per source),
21..26 s for the 40 test programs (compile and link each) and the harness, about 6 s for the Win32 part
(six sources, `rc`, `civ64.exe` and the three `w32_` tests).

`test.cmd` sections of the baseline (measured, the d4c2 run's output files):

| section | Checked (2,279 s) | CheckedNoObs (906 s) | Release (517 s) |
|---|---|---|---|
| unit tests (`test_ne`, the 40 `test_*.exe`, three `w32_test_*.exe`) | 63 | 62 | 72 |
| `registry.py check` | 5 | 7 | 7 |
| `nodos.py check` | 368 | 415 | 434 |
| harness stub core, gate3b, uninit, scenarios, p4tests | 368 | 2 + 25 + 52 + 132 + 136 | - |
| `obs_tables`, `obs_lint`, `adapters.py`, `pdos_scene_check` | 3 | 3 | 4 |
| `ext_p0.py` (8 processes) | 520 | 71 (V5) | - |
| `ext_frames.py` (up to 8) | 78 | - | - |
| `ext_timeline.py` (a pool) | 52 | - | - |
| `ext_continue.py` (a pool) | 40 | 0 | - |
| `ext_adapt.py` | 87 | - | - |
| `ext_mirror.py` (4) | 103 | - | - |
| `ext_zoom.py` (8; the four soak runs about 740 s each in an earlier run) | 591 | - | - |
| `trace.py --check`, `coverage.py` | 1 | 1 | 0 |

So about 830 s of Checked's 2,279 s ran one process at a time (8 cores, 16 logical processors), and
`nodos.py` alone is most of CheckedNoObs and Release.

## 2. Dependencies (item 2)

Every section reads the variant's programs in `build/x64/<variant>`, `build/gamedata` (the harness copies
it into each run directory) and, where named, `build/dosdata`, both read-only; and writes only under
`build/`. Run ids are unique per section (the harness refuses an existing run directory); the game run ids
(`build/run`, `build/harness/game`, `build/frames`) are not per variant, so the variants stay one after
another.

| section | writes (besides its `build/test/<variant>` text files) | reads from other sections | must follow |
|---|---|---|---|
| `unit` | `build/test/<variant>/*` (own names), `coverage-test_*.txt` | - | - |
| `d2_registry`, `d2_nodos`, `d3a_obs_tables`, `d3a_obs_lint`, `d4a_pdos_scene`, `d4c1_adapters`, `trace` | nothing else (checks of sources, documents, goldens, binaries) | - (`nodos` scans the port tree without `build/`, which no section writes) | - |
| `harness_stub` | `run/h-<variant>-*`, `harness/<variant>/{normal,...}` | - | - |
| `gate3b` | `gate3b-*` (`run`, `harness/game`, `frames`) | its own `gate3b-s2b` save | - |
| `uninit` | `uninit-s2..s5` | - | - |
| `scenarios` | `p4-*`, `build/p4/scripts/<name>.script`, `build/p4/saves/` (its 8 edits), `harness/features.txt`, `decoded.txt`, `pictures16.txt` | its own `p4-retire`, `p4-conquest`, `p4-display16` | - |
| `p4tests` | `p49-*`, `build/p4/scripts/p49-*.script`, `build/p4/saves/` (`FIND*`, `C2*`) | - | - |
| `ext_p0` | `harness/<variant>/p0`, `run/p0-*`, `build/p0/scripts` and `saves` (shared, below) | CheckedNoObs: Checked's `p0/V0` of the preceding `test.cmd checked` | (the variant order) |
| `ext_frames` | `harness/Checked/frames74`, `run/fr-*`, `build/p0/scripts` (shared) | - | - |
| `ext_timeline` | `harness/Checked/timeline`, `build/timeline/scripts` | - | - |
| `ext_continue` | `harness/<variant>/continue`, `run/ac-*`, `build/continue/scripts` | - | - |
| `ext_adapt` | `harness/Checked/adapt`, `run/adapt-*`, `build/adapt` | - | - |
| `ext_mirror` | `harness/Checked/mirror`, `run/mirror-*`, `build/p0/scripts` and `saves` (shared) | `harness/Checked/p0/V0/*` (`ext_p0`) and `harness/game/uninit-s4`, `-s5` (`uninit`) | `ext_p0`, `uninit` |
| `ext_zoom` | `harness/Checked/zoom`, `run/zoom-*`, `build/p0/scripts` and `saves` (shared) | - | - |
| `coverage` | - | `build/x64/<variant>/coverage-*.txt`, appended by every harness and test program | every other section |
| (`ext_g1.py check`, after `test.cmd`) | - | `harness/<variant>/{stub runs}`, `harness/game/{gate3b,uninit,p4,p49}` | `test.cmd` |

The shared files: `ext_p0`, `ext_frames`, `ext_mirror` and `ext_zoom` all write `build/p0/scripts`
(`ext_p0.runs()`: every scenario's script) and three of them `build/p0/saves`
(`ext_p0.edited_saves()`) at their start, truncating and rewriting each file, while the harness runs of
the others read them; at the same time that is a race. With `CIV_TESTPAR=1` (set by the runner only)
`ext_p0.py` writes such a file only when its bytes change, and then by renaming a new file over it
(retried after reading again if another run has it open); the bytes are those of `Script.write` and
`saveedit.edit` (checked on all 21 scripts, 8 saves and 27 run rows). Without the variable the files are
written as before.

Wall-clock measurements: no test asserts one. Informational lines print times (`test_dos`'s activation
"Release budget 150 ms", `test_map`'s costs, `test_present`'s and `test_timeline`'s timings, `OBS_COST`,
the PIC bit-flip and decode totals), `timeline-partitions.txt` holds seconds, and the map layer's
`presentation-diag.log` holds host wall-clock cost fields (`snap_us`, `snap_turn_max_us`, `world_us`,
`world_max_us`, `present/map/pmap_snap.c`, "informational"); parallel load changes those numbers. The only
real-time limit is `test_host_win32`'s 30 s wait for its child process. The harness's watchdogs are steps
and virtual time. `coverage.py`'s report is informational; concurrent appends to one coverage file (the
existing pools already ran 8 harness processes at once) can lose lines in it.

## 3. The runner (item 3)

`test.cmd` keeps its usage, adds `serial` and `parallel`:

    cmd /c C:\Projects\Civ1RE\claude\port\test.cmd [checked [noobs]|asan] [serial|parallel]

* The start (MSVC, the variables, the `gamedata`/`dosdata` checks, the missing-program check, the coverage
  files removed) and the end (`TESTS_FAILED=n` or `TESTS_OK variant=...`) are unchanged.
* Its test commands are grouped in 21 sections (24 since the BS landing, 2026-10-15), each under a label `:sec_NAME` ended by `goto :eof`, the
  commands byte-identical to the old file (a mechanical comparison: only the split of the old shared
  `if` blocks - scenarios/p4tests, and the Checked/CheckedNoObs `ext_p0` and `ext_continue` - differs). The
  list, in the sequential order:

      rem @section unit est=70
      rem @section d2_registry est=6
      rem @section d2_nodos est=340
      rem @section harness_stub est=3
      rem @section gate3b est=25
      rem @section uninit est=60
      rem @section scenarios est=170
      rem @section p4tests est=150
      rem @section d3a_obs_tables est=2
      rem @section d3a_obs_lint est=2
      rem @section d4a_pdos_scene est=2
      rem @section d4c1_adapters est=3          (in D4c1's "extension D4c1 (begin)".."(end)" comments)
      rem @section ext_p0 cpu=8 est=560
      rem @section ext_frames cpu=8 est=110
      rem @section ext_timeline cpu=7 est=60
      rem @section ext_continue cpu=6 est=70
      rem @section ext_adapt est=95
      rem @section ext_mirror after=ext_p0,uninit cpu=4 est=125
      rem @section ext_zoom cpu=8 est=780
      rem @section trace est=2
      rem @section coverage after=* est=1

* `parallel` (the default; for `asan` only when given): `tests/harness/testpar.py sections` runs every
  section as `cmd /d /s /c ""test.cmd" --section NAME VARIANT"` (the section entry skips the MSVC setup,
  whose environment it inherits, sets the variables and `FAILED=0`, calls the label, prints the end line
  `@@CY_END NAME FAILED` and exits with FAILED) with `CIV_TESTPAR=1`, a section only after those of its
  `after=` (they must be earlier in the list; `*` every earlier one), at most `CIV_TEST_BUDGET` (default
  20) processes by the sections' `cpu=` counts (a section starts anyway when nothing runs), the longest
  remaining chain first (from `est=`, or from the previous run's `times.txt`). Each section writes
  `build\test\<variant>\sections\NAME.log`; the logs are printed unchanged, without the end line, in the list
  order as soon as a section and all before it have ended. A section that ends without its end line, or
  with another status, counts one failure more and gets `TEST_ERROR=testpar: section NAME ended with status
  N without its end line`. Then one line `TEST_SECTIONS 21 parallel, budget 20, wall S s, failed F[: names]
  (logs and times: DIR)` and the runner exits with the sum of the sections' failures, which `test.cmd` adds
  to its FAILED. `times.txt` holds each section's start, end, time and failures.
* `serial` (and `asan` by default): `testpar.py check` verifies the list (exit status: problems, added to
  FAILED), then the sections are called one after another in the list order inside the one cmd: the old
  order and output.
* `testpar.py check` (both modes; `parallel` runs it as part of `sections`) refuses: a list line without a
  name or with an unknown token, a duplicate, an `after=` naming no earlier section, a section without
  exactly one `:sec_NAME` label, and lines without CRLF. **`test.cmd` now has CRLF line endings**: cmd's
  label search (`call :sec_NAME`, `goto`) is unreliable in LF-only batch files, and a label not found would
  skip a section without a failure.
* Why asan stays serial by default: its equivalence was not run in CY (Asan is deferred to the final
  pass); `test.cmd asan parallel` uses the same runner.

### How a unit adds a section

1. One line in the list at the section's place in the sequential order, at the start of the line:
   `rem @section NAME [after=NAME,NAME,...] [cpu=N] [est=SECONDS]` (NAME of letters, digits and `_`).
2. The commands under `:sec_NAME`, ended by `goto :eof`, using `PORT`, `B`, `VARIANT`, `OUT`, `T` and
   `PY` and `set /a FAILED+=1` per failure, exactly as a block of the old file; a block for some variants
   tests `VARIANT` itself (`if /i "%VARIANT%"=="Checked" ( ... )`); its marker line (`echo [...]`) first.
3. `after=` when the new section reads another section's outputs (run directories, logs, `features.txt`)
   or writes, cleans or rewrites a file or directory another section reads or writes; `after=*` when it
   must follow everything (like `coverage`). `cpu=N` when it runs N processes at once (a pool). `est=` its
   time in seconds on this machine (only the first start order).
4. Keep the CRLF line endings (an editor or tool that writes LF breaks `testpar.py check`, which then
   fails the run); a unit's delimiting comments (`extension X (begin)` .. `(end)`) may surround both the
   list line and the label block, as D4c1's do.
5. Run `C:/Python314/python -B tests/harness/testpar.py check test.cmd` (prints nothing and exits 0 when
   the list is good) and `testpar.py list test.cmd`. A new `test_*.c` needs nothing: the `unit` section's
   loop runs every `test_*.exe`.

## 4. `build.cmd all` (item 4)

`build.cmd all` runs the generation steps and the clang-tidy probe once, then `testpar.py build-all`
starts `build.cmd checked --nogen`, `build.cmd checked noobs --nogen` and `build.cmd --nogen` at the same
time and waits; each writes its output to `build\build-all-<variant>.log`, which are printed in that order,
then `BUILD_ALL Checked exit 0 S s, ...; wall S s` and `BUILD_ALL_OK variants=Checked,CheckedNoObs,Release`
(or `BUILD_ERROR=build.cmd all: a variant failed`, exit 1). `--nogen` (internal): no MSVC setup (the
environment of `build.cmd all`), no generation steps (they write `core/gen`, `rt`, `platform/w16`,
`present/dos` and `build/cache`, which the other variants compile and read), and the per-variant log names
`build\cl-c11-<variant>.log`, `cl-c17-`, `tidy-`, `tidy-checks-`, `cl-host-`, `cl-test-`, `link-`,
`cl-harness-`, `cl-win32-`, `rc-civ64-`, `link-civ64-` (one variant's build writes them in turn; the three
at once would race on the shared names). The objects, compiler PDBs (`/Fd` per variant directory), the
linker outputs and response files are per variant already; the compiler and linker commands and flags are
those of the single-variant build. A single-variant `build.cmd [checked [noobs]|asan]` is unchanged
(the same log names). Inside one variant the sources stay one after another: running them at once would
need `/FS` or per-source `/Fd`, a change of compiler options the brief excludes (see "For the records").

## 5. Equivalence (item 5)

Method. The sequential reference is the D4 gate's run with the **old** `test.cmd` (steps 2, 5 and 8 of
`build/d4c2-status.txt`, 17:55:31..19:05:46 UTC) on the binaries of its steps 1, 4 and 7; after each step
the orchestrator took a digest with this unit's staged `cy_equiv.py` (`build/cy-equiv/seq-checked.json`,
27,306 entries; `seq-noobs.json`, 9,109; `seq-release.json`, 34; start epochs `seq-starts.txt`). Nothing
was rebuilt before the replay. Then the docs agent applied D4c2's records (19:15:40 UTC,
`build/docs-d4c2-done.txt`; DESIGN.md is a test input), CY's files were copied in (19:15:50 UTC), and the
**parallel** `test.cmd checked`, `test.cmd checked noobs` and `test.cmd` ran on the same binaries, each
followed by a digest (`par-checked.json`, `par-noobs.json`, `par-release.json`; epochs `par-starts.txt`)
and, for the two Checked variants, `ext_g1.py check`; `cy_equiv.py compare` (digests) and `cy_equiv.py
logs` (the outputs line by line) against the reference (`build/cy-equiv/compare-*.txt`, `logs-*.txt`,
`par-status.txt`; logs `build/cy-par-test-checked.log`, `-noobs.log`, `-release.log`). To separate run-to-run
variation from the runner, `test.cmd checked serial` then ran on the same binaries too
(`build/cy-ser-test-checked.log`, `ser-checked.json`, compared with both).

Results (headless, digest):

| | Checked | CheckedNoObs | Release |
|---|---|---|---|
| result | TESTS_OK, EXT_G1_OK runs 77 (amended 1) | TESTS_OK, EXT_G1_OK runs 77 (amended 1) | TESTS_OK |
| output lines (old / parallel) | 692 / 692 | 664 / 664 | 343 / 343 |
| lines that differ | 14 of each, all informational timings | 7 of each, all timings | 13 of each, all timings |
| run directories (frames, state, events as `ext_g1.py` digests them) | 406, all equal | 112, all equal | - |
| files written by both runs that differ | 302 | 2 | 2 |
| files only in the old run's digest | 29 (below) | 29 | 0 |

Every section marker (`[...]`) and every result line with its counts is identical, among them
`REGISTRY_OK`, `NODOS_OK`, `OBS_TABLES_OK probes 203 sites 98`, `OBS_LINT_OK files 86 probes 203
callsites 98`, `PASS pdos_scene_check: 1075 checks`, `ADAPT_OK rows 36 steps 12`, `P0_OK checks 279` (56 on
CheckedNoObs), `EXT_FRAMES_OK`, `EXT_TIMELINE_OK`, `EXT_CONTINUE_OK`, `EXT_ADAPT_OK checks 56`, `MIRROR_TOTAL`
and `MIRROR_OK runs 29`, `ZOOM_OK combinations 32 runs 64 samples 388`, `TRACE_OK`, `COVERAGE files 14; rt
entries entered 145 of 155; other functions entered 661` and every unit test's PASS/FAIL count. The docs
agent's edits changed no marker or count (the documents are inputs of `obs_lint`, `pdos_scene_check`,
`adapters.py`, `registry.py` and `trace.py`, whose lines are equal).

Every difference, explained:

1. **Informational timing lines** (the only output lines that differ): `test_dos`'s `activation: N ms,
   again N ms (Release budget 150 ms, ...)` (printed, not checked; 290 and 436 ms in the parallel Checked
   run), its `bit flips: ... (N ms)` and `decodes on changed copies: ...; total N s`, `test_map`'s six
   `cost ... N ms` lines, `test_observer`'s `OBS_COST ...`, `test_present`'s three `timing ... (informational)`
   lines and `test_timeline`'s `tick independence: ... N s`. They change from run to run anyway: the old and
   the new serial run, both sequential, differ in 13 of them (all but `tick independence`) and in the
   COVERAGE count (6.).
2. **`presentation-diag.log`** in 300 of the 406 Checked run directories: the map layer's host wall-clock
   cost fields (`snap_us`, `snap_turn_max_us`, `world_us`, `world_max_us`, "informational",
   `present/map/pmap_snap.c`). The 300 files are exactly those with a non-zero such field; the 106 with all
   of them zero are equal. With those four values masked (`cy_equiv.py`'s `|diag` entries, added after the
   reference was taken) all 406 are equal between the serial and the parallel run on the same binaries; the
   old and the new serial runs differ in the same 300 files. CheckedNoObs writes no presentation-diag.log
   (the observer is compiled out).
3. **`timeline-partitions.txt`** (all three variants): `test_timeline`'s seconds per partition set.
4. **`nodos.txt`** (all three): its first line counts the files and bytes scanned: 1,644 files and
   1,473,782,138 bytes before, 1,646 and 1,473,842,300 after (CheckedNoObs): the two new files
   `testpar.py` and `cy_equiv.py`, CY's changed `test.cmd`, `build.cmd` and `ext_p0.py`, and the documents
   the docs agent edited; `NODOS_OK` with 0 hits in both. (The serial run's count is 1,101 bytes higher
   again: `cy_equiv.py` grew by the `|diag` entries between the two runs.)
5. **The 29 shared P0 files** (`build/p0/scripts`, 21 scenario scripts, and `build/p0/saves`, 8 edited
   saves): the parallel run did not rewrite them (`CIV_TESTPAR=1`: their bytes were already right), so they
   are not in its digest; their current content equals the old run's hashes (110 of 110 `p0/` entries of
   `seq-checked.json`, 30 of 30 of `seq-noobs.json`), and no `.tmp`/`.new` file is left.
6. **`coverage.txt`** is equal between the old and the parallel run, but differs between them and the new
   serial run (`other functions entered 663` against 661): the informational report already varies between
   two sequential runs (the pools' concurrent appends to one coverage file, section 2).

So the parallel runner reproduces the sequential run: the same tests, the same results and counts, the
same core frames, state and events in every run directory, the same files, apart from wall-clock
measurements, the tree's own changes (nodos's count), the not-rewritten P0 files and the coverage
report's existing variation. The serial switch was exercised too: `test.cmd checked serial` TESTS_OK in
2,682 s, EXT_G1_OK runs 77, its output equal to the old runner's in all but 13 timing lines and the COVERAGE
count.

## 6. The cycle with the final files (item 6)

The eight-step cycle once, with the final files (the tree equal to `build/cy-stage`, compared byte for
byte) and `build.cmd all` (measured, headless; status `build/cy-status.txt`, logs `build/cy-<n>-<step>.log`):

| step | command | exit | time (UTC) | last line |
|---|---|---|---|---|
| 1 (with 4 and 7) | `build.cmd all` | 0 | 297 s (20:41:08..20:46:05) | `BUILD_ALL_OK variants=Checked,CheckedNoObs,Release` |
| 2 | `test.cmd checked` | 0 | 1,166 s (20:46:05..21:05:31) | `TESTS_OK variant=Checked` |
| 3 | `ext_g1.py check` | 0 | 1 s | `EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)` |
| 5 | `test.cmd checked noobs` | 0 | 553 s (21:05:32..21:14:45) | `TESTS_OK variant=CheckedNoObs` |
| 6 | `ext_g1.py check --variant CheckedNoObs` | 0 | 0 s | `EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)` |
| 8 | `test.cmd` | 0 | 485 s (21:14:46..21:22:51) | `TESTS_OK variant=Release` |
| in all | | | 2,503 s (20:41:08..21:22:51) | `ALL_GREEN` |

* `build.cmd all`: `BUILD_ALL Checked exit 0 289.9 s, CheckedNoObs exit 0 287.9 s, Release exit 0 272.9 s;
  wall 289.9 s`, plus about 7 s for the generation and the clang-tidy probe before them; 276 portable
  sources in each variant.
* The runner's `times.txt` (`build\test\<variant>\sections`): Checked wall 1,163.4 s, the longest chain
  `ext_p0` (979.8 s) then `ext_mirror` (183.2 s), with `ext_zoom` 1,040 s and `d2_nodos` 1,000 s beside
  it (`unit` started at 472 s, when the budget allowed, and took 175 s); CheckedNoObs wall 550.3 s, of which
  `d2_nodos` 549.9 s (everything else had ended by 128 s); Release wall 481.7 s, `d2_nodos` 481.4 s.
* The cycle's outputs against the old runner's (`cy_equiv.py logs`, `build/cy-equiv/logs-d4c2-cy-*.txt`):
  692 / 692, 664 / 664 and 343 / 343 lines, the differing ones only the informational timing lines of
  section 5 (14, 7 and 14 of each) and, in Checked, the COVERAGE count (`other functions entered 663`
  against 661, section 5, 6.).

## Before and after

Measured, seconds (the old runner: the D4 gate's run; the replay: the parallel runner on the same
binaries; the cycle: the final files after `build.cmd all`):

| | old runner (d4c2) | parallel replay | the cycle | old / cycle |
|---|---|---|---|---|
| `test.cmd checked` | 2,279 | 1,153 | 1,166 | 1.95 |
| `test.cmd checked noobs` | 906 | 460 | 553 | 1.64 |
| `test.cmd` (Release) | 517 | 404 | 485 | 1.07 |
| the three builds | 750 (284 + 254 + 212, one after another) | - | 297 (`build.cmd all`) | 2.53 |
| the two `ext_g1.py` checks | 0 | 0 | 1 | - |
| the eight-step cycle | 4,452 (74 min) | - | 2,503 (42 min) | 1.78 |
| the three-step cycle (estimated: a single `build.cmd checked` is unchanged, about 284 s) | 2,563 (43 min) | - | about 1,450 (24 min) | 1.77 |
| `test.cmd checked serial` (the old order, the new file) | - | 2,682 | - | - |

* The floor of Checked is the chain `ext_p0` then `ext_mirror` (about 1,160 s; `ext_zoom`'s 1,040 s and
  `nodos.py`'s 1,000 s beside it); the floor of CheckedNoObs and Release is `nodos.py` alone (one
  process), which runs slower beside the other sections (457..550 s in parallel against 415..434 s alone),
  hence their smaller gain.
* The same tests vary by 10..20 % between runs on this machine (the replay against the cycle: NoObs 460
  against 553 s, Release 404 against 485 s, both `nodos.py`; the serial run 2,682 s against the old
  runner's 2,279 s with the same commands in the same order); the machine's other load (other sessions'
  work) was not controlled.

## Deviations

1. **Asan stays serial by default.** Its equivalence was not run (Asan is deferred to the final pass;
   nothing was built or run for it); `test.cmd asan parallel` is available for that proof.
2. **The eight-step cycle with `build.cmd all`** runs the brief's steps 1, 4 and 7 as one step 1 (the
   status file says so), then 2, 3, 5, 6, 8 in the brief's order. A single-variant `build.cmd ...` is
   unchanged, so the cycle rule B's three-step cycle needs no change.
3. **The sequential baseline is the D4 gate's run** (the orchestrator's decision), not a CY run: between it
   and the replay the docs agent edited D4c2's documents and CY's files were copied in; no marker or count
   changed, and `nodos.py`'s file and byte counts changed by exactly those files (section 5).
4. **Option plumbing in `ext_p0.py`** (allowed by the brief): with `CIV_TESTPAR=1`, set only by the
   parallel runner, the shared P0 scripts and saves are written only when their bytes change, by a rename;
   the bytes and every check are unchanged, and without the variable it writes as before. So a parallel
   run does not rewrite those 29 files (section 5, 5.).
5. **The masked `presentation-diag.log` entries (`|diag`)** were added to `cy_equiv.py` after the old
   run's digests had been taken; to compare those logs under the mask the extra `test.cmd checked serial`
   run was made on the same binaries (serial against parallel: all 406 equal).
6. **`test.cmd` has CRLF line endings** now (the whole file; cmd's label search), and `testpar.py check`
   refuses LF lines; `build.cmd` stays LF (it has no labels).
7. **`testpar.py`'s `times.txt` header** was changed to UTC after the replays (a comment line; the cycle
   used the final file).
8. **Inside one variant the sources are still compiled one after another**: compiling them at once would
   need `/FS` or a per-source `/Fd`, a compiler-option change the brief excludes.
9. **The coverage report** (`coverage.py`, informational) differs between runs (661 against 663) because
   of concurrent appends to one coverage file that the existing pools already make; not changed (a harness
   change outside CY), not a check.

## For the records

For the documents CY does not own (to be applied by their owner):

* **RUNNING.md, "Building"**: add
  `cmd /c C:\Projects\Civ1RE\claude\port\build.cmd all`: the generation steps and the clang-tidy probe
  once, then `checked`, `checked noobs` and Release at the same time (outputs as the single-variant
  builds; each variant's output in `build\build-all-<variant>.log`, its tool logs with the variant in the
  name, `build\cl-c11-<variant>.log` ...); ends with `BUILD_ALL ...` and `BUILD_ALL_OK
  variants=Checked,CheckedNoObs,Release`, or `BUILD_ERROR=build.cmd all: a variant failed` (exit 1); about
  300 s against about 750 s for the three one after another. The phase gate's eight-step cycle may use it
  for its steps 1, 4 and 7. (`--nogen` is internal to it.)
* **RUNNING.md, "Tests"**: the usage becomes
  `cmd /c C:\Projects\Civ1RE\claude\port\test.cmd [checked [noobs]|asan] [serial|parallel]`. `parallel`
  (the default, except for `asan`) runs the sections of `test.cmd` at the same time, at most
  `CIV_TEST_BUDGET` processes (default 20), each section's output in
  `build\test\<variant>\sections\<name>.log`, printed in the sequential order, with the times in
  `times.txt` there and one more output line `TEST_SECTIONS 21 parallel, budget 20, wall S s, failed F
  (...)`; `serial` (the default for `asan`) runs them one after another in one cmd (the old order and
  output; for diagnosis). Markers, counts and `TESTS_OK`/`TESTS_FAILED` are unchanged. `ext_g1.py check`
  still runs after `test.cmd`. Times on this machine: about 1,170 s Checked, 460..550 s CheckedNoObs,
  400..490 s Release.
* **RUNNING.md, the tools table**: `tests\harness\testpar.py sections|check|list|build-all` (the runner;
  `check TEST.CMD` verifies the section list and labels, `list` prints it); `tests\harness\cy_equiv.py
  digest|compare|logs` (CY's equivalence evidence: digests of a run's outputs, as section 5); and in
  `ext_p0.py`'s row: with `CIV_TESTPAR=1` (set by the runner) the shared `build\p0\scripts` and `saves` are
  written only when their bytes change, by a rename.
* **RUNNING.md or the brief template, for later units**: a new `test.cmd` step goes in as a section:
  `rem @section NAME [after=...] [cpu=N] [est=S]` in the list and its commands under `:sec_NAME` ... `goto
  :eof`; `after=` for any output or shared file of another section; CRLF line endings; check with
  `testpar.py check` (section 3, "How a unit adds a section").
* **STATUS.md**: unit CY (session E3, 2026-10-15) done: the parallel `test.cmd` (default) with `serial`,
  and `build.cmd all`; equivalence with the old sequential runner shown on the same binaries for all three
  variants; the eight-step cycle with `build.cmd all` `ALL_GREEN` at 21:22:51 UTC in 2,503 s (42 min)
  against 4,452 s (74 min) at the D4 gate; `test.cmd checked` 1,166 s against 2,279 s. Record
  docs/ext-CY-record.md.

Possible follow-ups (not done; each needs a decision):

* A parallel option for `nodos.py check` (the scan of 1,646 files, 1.47 GB, in one process): it is the
  whole floor of CheckedNoObs and Release (about 450..550 s) and a 1,000 s section of Checked. It touches a
  check's own code path, so CY left it.
* Compiling the sources of one variant at the same time (`/FS` or a per-source `/Fd`): a compiler-option
  change, excluded by the brief; a single-variant build would go from about 280 s towards an estimated
  60..80 s (the 272 sources at about 0.6 s each on 8 cores).
* Checked's floor is `ext_p0.py` (8 processes, about 980 s) followed by `ext_mirror.py`; a larger pool in
  `ext_p0.py` would be a runner option of that script.
* The budget (`CIV_TEST_BUDGET`, 20) can be tuned; the sections' `est=` only set the first start order.
* Asan: prove `test.cmd asan parallel` against `serial` with `cy_equiv.py` at the final Asan pass, then
  make parallel its default.
* Per-process coverage files would make `coverage.py`'s report independent of concurrent appends.

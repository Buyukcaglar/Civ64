# Brief: unit CY (faster build-and-test cycle without dropping any test)

Written 2026-10-15 by the orchestrator of extension session E3. The user's decision (2026-10-15 about
14:09 UTC, STATUS.md "User directions"): "Apply your recommendation B plus E to the 'eight-step
build-and-test run' process." B is the new cycle rule (below); E is this unit: make the runs themselves
faster **without removing, weakening or skipping any test**. One implementer on the session's own model,
started when the orchestrator gives it the build slot.

## The cycle rule from now on (B)

* **Per unit, the three-step cycle** after the last source change: 1 `build.cmd checked`, 2 `test.cmd
  checked`, 3 `C:/Python314/python -B tests/harness/ext_g1.py check`. Logs `build/<unit>-<n>-<step>.log`,
  status `build/<unit>-status.txt` ending `ALL_GREEN`.
* **At each phase gate** (D4, BS, D5, D6, D7, X9 and WL's end, and before the final Asan pass) the full
  eight-step cycle: the three steps plus 4 `build.cmd checked noobs`, 5 `test.cmd checked noobs`, 6
  `ext_g1.py check --variant CheckedNoObs`, 7 `build.cmd`, 8 `test.cmd`.

## Task (E)

1. **Measure.** From recent logs (`build/d4b4-2-test-checked.log`, `-5-`, `-8-`, and the build logs) and,
   if needed, one timed run: the time of every `test.cmd` section (the `echo [...]` blocks) and of the
   builds' phases (generation, compilation per target, linking).
2. **Dependencies.** For every `test.cmd` section: what it reads (build outputs, `build/harness/...` run
   directories of other sections, documents, `build/dosdata`, `build/gamedata`) and what it writes
   (run directories, logs, temporary files, `features.txt`, goldens). Find the sections that are
   independent and those that must follow others (for example `ext_g1.py` and `ext_p0.py` V5 read other
   sections' run outputs; a script that cleans or rewrites a shared directory). Note any test that
   measures wall-clock time (performance limits) and would be distorted by parallel load.
3. **Parallel runner.** Change `test.cmd` (and, if useful, small runner options in the Python harness
   scripts, never their checks) so that independent sections run concurrently with a bounded number of
   jobs (the machine has 16 logical processors and 64 GB; leave headroom), each section's output kept in
   its own log and then printed in the original order, the overall result `TESTS_OK` only if every
   section passed, exactly as today's markers and counts. Keep a switch for the old sequential order
   (for example `test.cmd checked serial`) for diagnosis.
4. **Builds (optional, for the gate cycle).** If `build.cmd`'s generation step can run once and the three
   variants then compile concurrently into their separate output directories without races, add that as
   a separate command (for example `build.cmd all`); otherwise record why not. Do not change compiler
   flags, sources, or what is built.
5. **Prove equivalence.** On the same build, run the old sequential `test.cmd checked` and the new parallel
   one; every section's result marker and every check count must be identical, every harness run
   directory's outputs identical (digest them as `ext_g1.py` does: frames, state, events, plus
   `coreinput.log`, `timeline.log`, presentation traces where present), and `ext_g1.py check` green after
   each. Do the same for `checked noobs` and Release (their tests) if you parallelise them. Report the
   times before and after.
6. Then the three-step cycle once with the final `test.cmd` (and, if you changed `build.cmd` or the gate
   variants, the eight-step cycle once). Record `claude/port/docs/ext-CY-record.md`: measurements,
   dependency table, the runner, the equivalence evidence, before/after times, deviations, "For the
   records" (RUNNING.md's test and build commands, STATUS).

## Files you own

`test.cmd`, `build.cmd` (only for item 4), runner helpers under `tests/harness/` (new files, or option
plumbing in existing scripts that does not touch any check), your record. Not `present/`, `platform/`,
`core/`, `rt/`, `gen/` outputs, `win64/`, tests' checks or expectations, or other documents.

## Rules

As `BRIEF-d4.md` "Rules" (no git writes; absolute paths; Python only as `C:/Python314/python -B`;
Write/Edit for files with backslashes; independence; never write `dos/` or `build/dosdata`; lean
context). If the orchestrator sends "wrap up", restore a working `test.cmd` (the old sequential one if the
parallel one is not proven) and write the record.

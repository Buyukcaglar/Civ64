# Phase 3c acceptance record

**State, 2026-10-09 15:35 UTC: the gate is met.** All three items below hold; the labels of
prompt section 10 are kept apart at the end.

Phase 3c (prompt section 9) covers all remaining units, giant functions by fragment. Gate:
"Every unit passes the section 1 checks. `TRACE.md` is complete and checked by script. All
verifier reports are stored."

| Gate item | Method | Result |
|---|---|---|
| Every unit passes the section 1 checks | build: `build.cmd` (Release), `build.cmd checked`, `build.cmd asan` run the three language checks of section 1 on every portable source (`core`, `rt`, `platform/w16`: "portable sources checked: 220 (c11, c17, c99 parse)") and compile strict C17 x64 with the recorded `/wd` list | BUILD_OK for all three variants (2026-10-09 14:58–15:03, after F11; "portable sources checked: 220 (c11, c17, c99 parse)" in each build log); the 170 units are among the 220 sources |
| `TRACE.md` is complete and checked by script | script: `gen/trace.py --check` (in `test.cmd`, every variant) rebuilds the map from `functions.json`, the core headers, `rt/rt_api.h` and the rt definitions, findings D1 and `civ_adapters.h`, and fails on any difference | TRACE_OK: 1,065 functions = 699 port functions + 155 replaced by rt + 211 dead (D1); 2 call adapters; 56 run-time functions with pseudo-intrinsics; 10 imports outside the live Win16 surface. A deliberately altered TRACE.md fails (TRACE_FAILED=1) |
| All verifier reports are stored | files: `docs/verify/<unit>.md` for each of the 170 units (every round appended), the round briefs `BRIEF-round*.md`, the fixer records `round5-fixes.md` .. `round8-fixes.md` (which also holds F9 to F11), the generator reviews (`round3-casts.md`, `round3-findings-sites.md`, `round6-findings-sites.md`) and the batch reports `round*-R*.md` | stored; the recount finds a report with a verdict for every function: 699 of 699 translated functions PASS (137,887 of 137,887 instructions; recount 15:30, after round 11). |

## Translation and verification

* **Translated:** all 699 live game functions in 170 units; the 155 live run-time functions are
  replaced by `rt`; the 211 dead functions are not ported (rule 6.8; `TRACE.md`). Giant functions
  are split into fragments by unit (`_p1`, `_p2`, ... in `gen/units.json`).
* **Verified:** 699 of 699 translated functions PASS (137,887 of 137,887 instructions; recount 15:30, after round 11). Rounds 1 to 4 are recorded in `phase-3a-acceptance.md`, rounds 5 to 11 in
  `phase-3b-acceptance.md` and the `round*-fixes.md` records. Each round's verifiers checked the generated C against the
  listing independently of the translator; every TRANSLATOR or RECOVERY finding was fixed and
  re-verified in a later round. Round 11's nine NOTEs (`verify/round11-R11A.md`) and round10-R10A
  N2 concern record wording (FIDELITY F48, F65, F74, inventory P8 and C9's citation, DESIGN 3.2,
  comments in `core/acc.h` and the order of `gen/annot.py`), not generated code; they are open
  record items (F12).

## Labels (prompt section 10)

* **Headless-tested:** the phase-3a and 3b scenarios (start-up, worldsim vectors, load/save, new
  game, the S4/S5 soaks) under all three variants (2026-10-09 14:58–15:03; start-up g-37);
  model (self-consistency) evidence only.
* **Agent-observed:** nothing in phase 3c.
* **Oracle-compared:** nothing in phase 3c.
* **User-confirmed:** nothing in phase 3c.
* **Unverified:** same-seed fidelity is not claimed; rules and screens beyond the scenarios are
  translated and verified against the listing but not exercised.

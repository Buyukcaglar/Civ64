# Phase 8 audit C: section 4 items 4 (Rules), 6 (Original bugs), 7 (No UB), 8 (Traceability)

Auditor C, static review plus read-only Python (own scripts in the scratchpad `p8/c/`). Nothing
was built or run; `claude/tools/worldsim.py` was run (read-only).

Verdicts

| Item | Verdict |
|---|---|
| 4 Rules | **NOT MET as worded** (worldsim vectors, labelling and no same-seed claims are met; the state-at-every-checkpoint comparison and the repeated-run test of the game core are missing) |
| 6 Original bugs | **MET WITH CAVEATS** (run-time effect shown for 14 of 94 findings; for the rest only "a cited statement executed" plus the listing verification) |
| 7 No undefined behaviour | **MET WITH CAVEATS** (checked and ASan runs are clean; the "every 32-bit arithmetic site was checked" claim has no record behind it) |
| 8 Traceability | **MET** (independently recounted; only minor wording caveats) |

Notes on evidence available to me

* `claude/port/build/test-release.log`, `test-checked.log`, `test-asan.log` are NOT the
  2026-10-10 15:04 UTC logs the brief names: their file times are 2026-10-08 20:27..20:28 local
  (phase-2 era; `test_acc` 8/17 checks, no `test_worldsim`). The current Checked and Asan logs
  are `scratchpad/p7/t-checked.log` (17:45 local) and `t-asan.log` (18:01); there is no current
  Release test log at all. The Release `TESTS_OK` of `phase-7-acceptance.md` (line 18) cannot be
  confirmed from logs. The only Release `test_worldsim` log is `build/test-3a-release.log`
  (2026-10-09, 17 checks).
* The build outputs of the last test runs are on disk (`build/harness/game/*`, snapshots,
  `events.log`); I read those directly.

---------------------------------------------------------------------------------------------

## Item 4: Rules

**What I checked and found sound**

* Both worldsim vectors: I ran `claude/tools/worldsim.py`; it prints 0x89abcdef (0,2,0,2) ->
  3428805747 after 5996 draws, 0xffffffff (2,0,2,0) -> 3527905266 after 5555, and the model-only
  0xea0d (1,1,1,1) -> 3320891781 after 5544. `tests/test_worldsim.c` lines 244..250 carry exactly
  these constants and draw counts, injects seed and `g_worldParams` before the translated
  `GenerateWorldMap`, and `t-checked.log` and `t-asan.log` show `final seed 3428805747 after 5996
  draws`, `3527905266 after 5555`, `3320891781 after 5544` and `test_worldsim: PASS (33
  checks)`. The first vector is repeated from a fresh VM with identical map-page and DGROUP
  SHA-256 (`2836ea80...`, `121abf18...`). The third vector is labelled "model only"
  (test_worldsim.c lines 9..11, phase-3a record). The two original-observed states are quoted in
  `claude/docs/crosscheck/world-generation.md` lines 58 and 146.
* Labelling: `grep` over all phase records finds no same-seed claim (RUNNING.md 101,
  phase-3a 104, 3b 88, 3c 37, 4 73, 7 32 all disclaim it). Recovered-C-derived tests are labelled
  "model (self-consistency)" in `phase-2-acceptance.md` 44, `gate3b.py`, `p4tests.py` (docstring
  end), `uninit.py`, `savecheck.py`, `phase-4-acceptance.md` "Labels". Equality with the
  original is claimed only for oracle files (SAVE1.SAV, ORIG2.SAV in `phase-7-acceptance.md`)
  and the two worldsim states.
* Own determinism checks (nothing in `test.cmd` makes them): `build/harness/game/g-50` and `g-51`
  `watchdog.snap` are byte-identical (`cmp`), with identical 444 frame-hash lines; the S2 and S3
  scenarios were run twice by `test.cmd checked` (`gate3b-*` and `uninit-*`) and their
  `watchdog.snap` files and frame-hash sequences are byte-identical (S2 947,972 bytes, S3
  948,068 bytes, 752/763 frames).

**Findings**

* **C1 (BLOCKER for item 4 as worded).** No test compares the port's state with a reference at
  the DESIGN checkpoints. Prompt 4 item 4: "the port's state equals the reference that the tests
  encode at every checkpoint ... 'State' means all images, the emulated stack and the global
  blocks, under the comparison mask". What exists: `gate3b.py` lines 126..155 only checks that
  `after-load`, `turn`, `before-save`, `after-worldgen`, `after-setup`, `turn-N` snapshot files
  exist and reads two words from them (`g_gameTurn`, `g_gameYear`); `savecheck.py` compares the
  saved file with the serialized image of `before-save.snap` (state-to-file, not
  state-to-reference). `after-load` and `after-setup` snapshots are never read by any test. There
  is no stored golden snapshot or golden hash anywhere in `tests/` (the only 64-hex literals are
  SHA-256 test vectors in `test_sha.c`). The `--compare ... --expect-equal/--mask` machinery
  (`test.cmd` lines 75..92) is used only on the phase-2 stub core, never on the translated
  game. Fix: store per-checkpoint snapshot hashes (per image and per global, as the harness
  already computes) for S2/S3 and assert them in `test.cmd`, or at least run each scenario twice
  and `--compare --expect-equal` every named checkpoint.
* **C2 (MAJOR).** "Identical across repeated runs" for the game core is not a test. The only
  automated repeats are the stub core (`test.cmd` 72..76) and `test_worldsim`'s repeat of
  vector 1. The repeated start-up runs ("g-47 equals g-46", "g-51 equals g-50", STATUS rows
  484/485, `phase-4-acceptance.md` 30) were made with scratch scripts (`frchk/all3-*.cmd`, named in STATUS lines 484/485) that
  are not in the repository (`find` finds none), and the S3 repeat ("A repeat S3 run gives
  identical snapshots and frame hashes", `phase-3b-acceptance.md` 17) is a one-off statement.
  Intermediate checkpoints (`turn-2..5`, `before-save`, `after-load`) are written once per run
  and never compared across runs. Fix: as C1.
* **C3 (MAJOR).** The comparison mask is incomplete and has never been used on game state.
  `tests/headless/harness.c` lines 21..23 and `DESIGN.md` 1391..1394 still say "Open (before
  the first comparison with a non-port snapshot, phase 7 at the latest): handle-typed game
  globals ... and the pointer and handle fields inside structures and arrays"; phase 7 passed
  without closing it (oracle comparisons were file bytes only). The mask is exercised only by
  synthetic edits of a stub-core snapshot (`snapmod.py`). So "under the comparison mask" cannot
  currently be claimed for any game-core snapshot comparison against a non-port run. Fix: finish
  the `gen/layout.py` pointer/handle mask or state the limitation in the item-4 record.
* **C4 (MINOR).** Checkpoint placement differs from `DESIGN.md` 1357..1359: `after-worldgen` is
  11E0:01B2 (BeginWorldCreation has returned; DESIGN says "GenerateWorldMap 1028:0000
  returns"); `before-save` is 10F8:0370 (inside CivSaveGame after the BlockMove; DESIGN says
  "CivSaveGame entry"); `turn-N` is 1088:000F, the start of turn N (DESIGN says "after each
  scripted turn"). Fix: align the DESIGN text with `gate3b.py`.
* **C5 (MINOR).** `DESIGN.md` 1433..1437 describes "a harness option [that] stops at
  GenerateWorldMap 1028:0100 and writes the LCG state"; no such option exists in `harness_main.c`
  or `harness.c` (grep for world/inject/0x4EE0: nothing). The injection is done by
  `test_worldsim.c` before calling `GenerateWorldMap` (before 1028:0100; justified in the test
  header, and the listing of 1028:0000..00FB shows only SetGameCursor/PlaySoundEffect and flag
  stores before the random path). Fix: correct the DESIGN paragraph.

## Item 6: Original bugs

**Counts I recomputed.** `findings.md` has 70 G headings (G38 and G40 are "moved to H48/H49"
stubs, so 68 live), 20 C and 6 R: 94 in scope. The core cites 93 of them (all but R5), so the
`findcov` "93 of 93" means "93 of the 93 that are cited", not 93 of 94.

**Which findings are effect-checked.** From `t-checked.log` (31 `findings Xn statements
executed` lines) and the `PASS ... Gn:/Cn:` effect lines: effect checked at run time for 14:
G2, G6, G10, G12, G13, G16, G19, G31, G33, G44, G53, C6 (`p4tests.py` `fx_*`), plus C1 and C2
(`p4tests.py c1`, `c2`). A further 18 findings (C4, C7, G4, G5, G8, G9, G21, G22, G34, G35,
G39, G48, G55, G56, G57, G58, G60, G67) have an enforced targeted scenario that asserts only
that a cited statement ran (14 + 18 = 32 findings with an enforced check). The remaining 62 (C3, C5, C8..C20, 41 G, R1..R4,
R6, and the uncited R5) have no assertion in `test.cmd` at all: `findcov.py` is not invoked by
`test.cmd` (grep: referenced only in a `p4tests.py` docstring), so the "93 of 93" is a manual,
post-hoc report (`build/harness/findings-coverage.txt`, 11:37 local, before the final builds).
I recomputed it from the current `events.log` files with `findmarks.finding_marks()`: it still
holds (every finding has at least one executed mark) but 58 of 304 finding marks never ran, and
24 findings have unexecuted sites (G70 1/7, G39 1/5, G52 1/5, G5 2/6, G1 14/20, C6 1/3, G6 1/2,
...).

**Is "statement executed" "behaves as documented"?** No. `findmarks.py` says so itself ("A mark
that is hit means that the finding's statement ran, not that the finding's effect occurred") and
the mark is any-of over a finding's sites. Example: G1's 20 sites include the generic
`CivHasActiveWonder` test at 1030:7EA4, executed in every game; nothing checks a lost wonder
keeping a stray owner. What does support "behaves as documented" for the unexercised findings is
the translation: `/* BUG/OOB: findings Xn */` comments generated from `findings.md` addresses
(`gen/findings_sites.py`) and verifier "comments" rounds checking them at real sites, and the
unit verification of 699/699 functions against the listing. I spot-checked G9 (`core/seg018_1088_p1.c`
lines 171..180): the `i = RandomBelow(0x80)` inside the `for (i < 2)` is retained and commented.

* **C6 (MAJOR).** `phase-4-acceptance.md` line 36 marks "Every reachable G, C and R finding in a
  targeted scenario" as **pass**. Prompt section 7 asks for a targeted scenario per reachable
  finding; the port has an enforced targeted scenario for 31 (plus C1) of 94, and run-time effect
  checks for 14. The other 62 are reached only incidentally by generic scenarios/soaks, with
  nothing asserting even that. The record's own sentence is honest, but the table verdict and
  STATUS lines 24..27 ("all 93 findings cited in the core with a statement executed") read as full coverage. Of the 8
  C findings "reachable in normal play" (findings.md 5.1: C1..C8) only C1, C2, C6 are
  effect-checked; C3 (double delete of a stack), C5, C8 and the C4/C7 effects are not. No R finding
  has an effect check (R1: the city-view reseed value, which prompt section 7 relies on for the
  oracle resynchronization; R2 starfield; R3; R4; R6 quiz draws), although section 7 lists these
  RNG consumers explicitly. Fix: enforce `findcov` in `test.cmd`, add scenarios or unit checks for
  the missing effects, or relabel the verdict "reachability shown for 93/94, effects for 14".
* **C7 (MINOR).** R5 (DrawMiniPalace's private LCG, `findings.md` line 1559) is not cited in
  `core/*.c`, in any record, or in any test (grep `R5`: only unrelated STATUS text). The function
  is ported (`core/seg018_1088_p2.c` 13..120: `lcgState * 5 + 1`, local only) and runs in the
  scenarios (coverage file), but nothing shows it leaves the shared stream alone. Fix: cite it
  and add an "g_randSeed unchanged across DrawMiniPalace" check.
* **C8 (MINOR).** C9's hang (prompt 5.3 "Hangs"; `DESIGN.md` 1399 "a test that expects a hang
  (findings C9 ...) passes on that result") has no test: grep for `C9`/`TextBoxSetup` in `tests/`
  finds nothing. The WATCHDOG expectation is demonstrated only on the stub core (`test.cmd` 97..100).
  C9 is "latent" in findings.md but it is the prompt's own example. Fix: add a one-word-too-wide
  text-box scenario expecting WATCHDOG, or list it as not tested.
* **C9 (MINOR).** Faults are not all listed in `FIDELITY.md` (prompt 5.3: "Each site gets a
  fidelity entry"). The register has the memory-limit and return-frame faults (F10, F33, F58,
  F59, F64..F66, F72..F74) but no entry for the divide-error policy sites (prompt 6.3 known
  sites; e.g. H61 10B0:068B, H62 10A8:0154/01E6, U3 1038:0937: `grep H61|H62|U3 FIDELITY.md` finds
  nothing) and none for the ten `rt` floating-point entries that fault at entry
  (`rt/README.md` lines 8, 76..79; `rt/rt_math.c` `unproven()`; no "float"/"pow" in FIDELITY).
  The divide helpers in `core/cx.h` (including the zero-divisor and -32768/-1 faults) are not
  unit-tested: no test includes `cx.h`; `test_rt.c` 882 covers only qsort's own division.
  C2's in-play masks 0xE5 and 0xE7 (prompt 5.3) are not exercised; `p4tests c2` uses 0xBF and
  0xFF (the 0xFF fault is F10).

## Item 7: No undefined behaviour

**Checked and ASan evidence (sound)**

* `t-checked.log` ends `TESTS_OK variant=Checked`; `t-asan.log` ends `TESTS_OK variant=Asan`
  (449 lines; no "AddressSanitizer", "SUMMARY" or "heap-buffer" text). The Asan executables
  contain the ASan runtime strings (`grep -a __asan_init` hits 1 in `Asan/civ_harness.exe` and
  `test_worldsim.exe`, 0 in the Checked ones). Build logs `b-checked/asan/release.log`:
  `portable sources checked: 226 (c11, c17, c99 parse)`, `BUILD_OK` for all three.
* Every scenario/test line asserts "no fault, no unlisted out-of-range record"; the console files
  of the 65 game runs show `HARNESS_OOB records N lost 0 unlisted 0 (allowlist 352 sites)` (max N
  = 17). I decoded the kind-6 records of every run's final snapshot: 21 distinct hit sites, 20
  covered by a site-specific allowlist entry, 1 (1070:1206, IsSpaceshipStructureAt, finding U5)
  only by a function-level entry.
* Stack: `vm.c` `stk_check` (lines 656..666) faults `VM_FAULT_STACK` in checked builds; all runs
  end `fault_kind 0`. Lowest `sp_min` over all run snapshots: 0xCB08 (p4-menus), i.e. 3,510 bytes
  below the initial SP 0xD8BE and 5,706 bytes above the 0xB4BE limit; soak S5 0xCD66.

**Findings**

* **C10 (MAJOR).** The claim "the phase-3 verifier has checked every 32-bit arithmetic site" has
  no record behind it. No acceptance record, STATUS row or verify report says it (grep
  "32-bit arithmetic|arithmetic site|every 32-bit|signed overflow": nothing in port docs). The
  only dedicated scan, `docs/verify/round3-casts.md` (W3), covers implementation-defined casts
  and right shifts in `core/*.c` and lists under "Not checked" (lines 157..166) "Left shifts of
  negative values and signed overflow in general", and "core/gen/*.c and the platform/rt layers".
  The final verification round `verify/round11-R11A.md` has zero hits for
  arithmetic/wrap/overflow. What exists is check 4 (arithmetic) of each unit's PASS and the
  translator's design (`W16/W32`, `cx_*` helpers): my grep of 168 `W32(` uses in `core/seg*.c`
  found no unwrapped signed 32-bit `+ - *` (32-bit work is done in `uint32_t` then `W32`), so I
  found no counter-example, but this is sampling, not the required per-site check, and no
  tool (clang `-fsanitize=undefined` is not used though VS's clang front end is in the build) backs
  it. Also: `cx_idiv16` (`core/cx.h` 51..67) evaluates `num / den` before testing the quotient,
  which is C UB for `INT32_MIN / -1`; callers (`IDIV16`) only pass 16-bit dividends, so it is
  latent. The wrap helpers `vm_s16/vm_s32/W16/W32` and `cx_*` have no direct test (no test
  references them; phase-4 record row 28 lists "wrap helpers" under `test_rt`/`test_vm`/etc.).
  Fix: add a verifier sweep record (or a clang-cl UBSan build of the core), and unit tests for
  `vm_s*`, `cx_idiv*`, `cx_sh*`.
* **C11 (MINOR).** Prompt 5.2 item 7: "Each acceptance record states the maximum emulated stack
  depth its tests reached." Only `phase-3a-acceptance.md` 68..69 does (S1: 2,194 bytes;
  test_worldsim 478). Phases 3b, 3c, 4, 5, 6, 7 are silent although the soaks and 23 scenarios
  reach deeper (3,510 bytes, p4-menus). Fix: add the figure (it is in each snapshot's
  `stack ... sp_min` line).
* **C12 (MINOR).** The "triaged" allowlist is coarse and its FIDELITY.md leg is incomplete.
  `gen/oob_allowlist.py` allows every statement marker of a function when an OOB comment sits
  after the function header: 10 such function-level allowances cover 131 markers (CompleteResearch
  C12: 52; CheckAdjacentForeignUnits U4: 17; ChooseFileToOpen C19: 16; TakeAdvanceFromCiv C10: 13
  ...), so any new out-of-object access in those functions would be silent. The allowlist is
  352 entries/346 sites/44 finding ids; prompt 5.2 item 3 says a real original OOB access gets an
  OOB entry in `FIDELITY.md`; 26 of the 44 ids (e.g. U2..U5, G1, G14, G23, G50, C1, C4, C6..C9,
  C11, C14, C16, C19, P1, P10..P13) do not appear in FIDELITY.md; they are in the generated
  `inventory/out-of-range.md` (an "allowlist seed" derived from findings.md addresses). So
  "triage" is by construction (finding text names the site) rather than a per-site review
  record. Only one hit site actually relied on a function-level entry (see above).
* **C13 (MINOR).** ASan scope. `test.cmd` runs `gate3b.py` (S2/S2b/S2c/S3) and `uninit.py`
  (S2..S5 soaks, 92 and 111 turns) in the Checked variant only (lines 110..118); the Asan
  variant runs the unit tests, the stub-core harness gates, `scenarios.py` and `p4tests.py`.
  Load/save and the long soaks therefore run under ASan only by hand (phase-3b 17 says S3 once).
  ASan also cannot see out-of-object accesses inside the emulated images (one big host block);
  that is what the Checked build covers, as designed. The Asan/Checked executables (17:48/17:41
  local) predate the final Release rebuild (18:04), which regenerated `core/gen/*` headers
  (timestamps newer); contents are deterministic output and presumably unchanged, not verified.

## Item 8: Traceability

**Independent recount** (`scratchpad/p8/c/trace_audit.py`, `dead_audit.py`, `hdr_def.py`):

* `claude/docs/db/functions.json`: 1,065 functions, 1,065 distinct addresses. `TRACE.md`
  "## Functions": 1,065 rows, 1,065 distinct; sets equal in both directions; 0 name mismatches.
  Dispositions: 699 "port function", 155 "replaced by rt" (all in segment 1000), 211 "dead, not
  ported" (178 "D1 unreferenced" + 33 "D1 reachable only from dead code"; 160 outside segment
  1000, 51 inside). 699 + 155 + 211 = 1,065.
* Headers: `core/*.c` has exactly 699 `/* SSSS:OOOO  Name */` header lines, no duplicates; the
  address set equals the 699 port rows and every name equals the TRACE name. All 699 headers are
  followed within 4 lines by a definition of that name (my check; `gen/trace.py` only matches the
  header regex). 30 random port rows (seed 8) all resolved to a header (StepPaletteFadeOut
  10A8:018E, AddUnitToTile 1110:1767, CityScreenWndProc 1030:9C17, RunCivilizationQuiz
  1178:0000, ...).
* Dead rows: 211 of 211 have a reason; against `functions.json` no live function lists a dead
  function among its callees or tail calls, no dead function has a live caller, all 178
  "unreferenced" rows have empty `callers`. The four "reachable only from dead code" rows with
  no callers (RadioMenuDlgSubclassProc 11E0:0B73, `_scantod`, `_scanpop`, `_scanrslt`) are
  address-taken/hook-table cases explained in findings D1 (`functions.json` reasons
  `offset_reloc@11E0:0A3B`, `rtl_hook_table@...`).
* Adapters: `core/gen/civ_adapters.h` has two (`ADAPT_RegisterRandomControlClasses_1`,
  `ADAPT_GetDialogItemText_4`), both in TRACE "Call adapters"; the prompt's third case
  `StubReturnZero_1098_18F7` is correctly omitted (only callers 1068:0000/0026, both dead:
  `functions.json`).
* `gen/trace.py --check` (build in `test.cmd` 128..129) rebuilds the text from `functions.json`,
  core headers, `rt_api.h`, rt definitions, findings D1 and `civ_adapters.h` and fails on any
  difference; `t-checked.log`/`t-asan.log` end `TRACE functions 1065 port 699 rt 155 dead 211
  adapters 2` / `TRACE_OK`.

**Findings**

* **C14 (MINOR).** Wording: (a) ten of the 155 "replaced by rt" rows are rt entries that fault
  at entry by design (unproven float paths; `rt/README.md` 8, 76..79) and TRACE shows them as
  plain "replaced by rt" with no pointer to that behaviour; (b) "dead, not ported" reasons are
  only the D1 category tag, not a per-function reason (acceptable but terse); (c) no row is
  "replaced by w16" although the prompt allows it (none needed). No defect in the mapping itself.

---------------------------------------------------------------------------------------------

## Short list (for the caller)

* Item 4 NOT MET as worded: C1 BLOCKER (no state-vs-reference comparison at checkpoints), C2
  MAJOR (repeat-run determinism of the game core not tested; manual only), C3 MAJOR (comparison
  mask incomplete, never used on game state), C4/C5 MINOR (checkpoint placement and a described
  harness option that does not exist). Worldsim vectors, labelling, no same-seed claims: OK.
* Item 6 MET WITH CAVEATS: C6 MAJOR ("pass" for targeted scenarios overstated; effects for 14 of
  94; 62 findings with no enforced check; no R finding effect-checked), C7 MINOR (R5 uncited),
  C8 MINOR (C9 hang untested), C9 MINOR (divide-error and float faults not in FIDELITY;
  `cx.h` helpers untested).
* Item 7 MET WITH CAVEATS: C10 MAJOR (32-bit-arithmetic verification claim unrecorded; W3 scan
  excludes signed overflow), C11 MINOR (stack depth missing from records 3b..7), C12 MINOR
  (coarse allowlist; OOB entries mostly not in FIDELITY.md), C13 MINOR (ASan does not run
  gate3b/soaks).
* Item 8 MET: 1,065 = 699 + 155 + 211 recounted; 699 headers verified; adapters match; C14
  MINOR wording only.

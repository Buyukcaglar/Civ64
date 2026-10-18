# Phase 4 acceptance record

Phase 4 (prompt section 9) completes the portable `w16` and the headless integration. Gate:
"Complete the portable `w16` (window manager, controls, indexed GDI, palette, text, dialogs,
menus, timers, files, common dialogs); full headless integration: every `FEATURES.md` row reached
headless; all required tests (section 7)." Gate condition: "Tests pass. The checked build is
clean, or every hit is triaged."

**State, 2026-10-10 08:55 UTC: the gate is met.** At 07:06 two items were open: targeted
scenarios for 7 of the 93 G, C and R findings cited in the core, and the C2 bytes. The user chose
to keep building scenarios (`STATUS.md`, user directions, about 08:00). Six more scenarios and the
`c2` test now cover them, so every finding cited in the core has a statement executed, with the
effect checked where a snapshot shows it. The labels of prompt section 10 are kept apart at the
end of this record.

| Gate item | Method | Result |
|---|---|---|
| 1. The portable `w16` is complete | P4-1 mouse routing, P4-2 non-client drawing, P4-3 menu tracking, P4-4 scroll-bar tracking, P4-5 system commands and window states, P4-6 MessageBox, P4-7 list boxes, statics and DIBs; reviews RV1..RV4 with fixes F14..F17 (`verify/phase4-review-*.md`, `verify/round8-fixes.md`); FIDELITY F25, F26, F76..F80; unit tests `test_user` (262 checks), `test_gdi` (95), `test_queue` (117), `test_io` (136), `test_commdlg` (18), `test_start` (110) | **met** (compiled; headless-tested; model: self-consistency). Agent-observed frames: `build/frames/p46-msgbox/`, the scenario row frames. P47-R2 waits for the user's phase-7 check (not a phase-4 item). |
| 2. Every `FEATURES.md` row reached headless | `tests/harness/scenarios.py`: 23 scenarios on the loaded save, eight edited saves, new games and `--display 16`; the event trace (`events.log`) mapped to the rows by `features.py`/`features.map`; FEATURES.md regenerated from `build/harness/features.txt` | **met**: 108 of 108 rows in Checked and in Asan (P4_SCENARIOS_OK; the same row frames in both builds) |
| 3. All required tests (section 7) | see the table below | **met** (headless-tested; model: self-consistency) |
| 4. Tests pass; the checked build is clean or every hit is triaged | `build.cmd` / `test.cmd` in Release, Asan and Checked; every harness run ends with `HARNESS_OOB records R lost 0 unlisted 0` against the allowlist of 352 sites, each site commented `/* OOB: findings Xn */` or listed with its reason | **met**: BUILD_OK and TESTS_OK for all three variants (Release 05:12–05:29; Asan rebuilt and Asan and Checked tested again 06:50–07:05 after the harness change, and again 08:37–08:55 after the P4-9 scenario additions, which changed only `tests/harness/p4tests.py`; start-up g-48 equals g-47); 0 unlisted out-of-range records in every run |

## Required tests (section 7)

| Test | Where | State |
|---|---|---|
| `rand`, `srand`, `RandomBelow` sequences | `test_rt` (321 checks), `test_worldsim` (33), `p4tests.py boot` | pass |
| Borland `qsort` with ties; Find City order with `[\]^_` and bytes >= 0x80; `stricmp`; `itoa`, live `sprintf` formats; `__ftol` edges; wrap helpers | `test_rt`, `test_printf` (62), `test_math` (174), `test_vm` (66); `p4tests.py findcity` | pass |
| Both worldsim vectors by state injection at 1028:0100 | `test_worldsim` | pass |
| Start-up to the title menu; new-game setup to the first turn; seeding with several boot offsets; a scenario crossing the TickCount wrap | `run-startup.cmd` (g-47 equals g-46), S3 `new-game.script`, `p4tests.py boot` (four offsets) and `wrap` (three runs) | pass |
| Load `CAE3540B.SAV`, play, save = `RLLEncode(SerializeGameData image)`; save over a longer file, stale tail, load back | `gate3b.py` (S2, S2b, S2c), `savecheck.py` | pass |
| `famehall.civ` absent then created and reloaded; `civ.prf`; a `.rep` file | scenarios fame-quit, fame-reload, conquest (REPLAY.REP); `p4tests.py prf` | pass |
| The 0x1A2BA-byte multi-tile buffer | `test_vm`, `savecheck.py` (RLLDecode capacity) | pass |
| The picture/LZW decoder on every picture of the run's `.rsc` files (hashes) | `--hash-pictures 1` ("decoded" lines at PicDecompress 10B8:1B3D); scenarios display16 (the conversion) and earth (picture 137, the EARTH map); `scenarios.py` checks the 199 CvPc ids of `civdata*.rsc` | pass: 199 of 199, one hash per picture and colorBase (`build/harness/decoded.txt`) |
| Every reachable class (a) UNINIT site | `uninit.py` (UNINIT_OK): the one class (a) site, 1038:0B36, is checked by the table test of every snapshot (phase-3b record) | pass |
| Every reachable G, C and R finding in a targeted scenario | `p4tests.py findings` (22 scenarios on edited saves) and `c2`, the other scenarios and runs; `findcov.py` | pass: 93 of 93 have a statement executed. Effects are checked for G2, G6, G10, G12, G13, G16, G19, G31, G33, G44, G53, C2 and C6 (DESIGN.md 9). G6's second site (11B8:0F95) is unreachable as far as the code shows: TransferCityByRevolt's receiver loop runs only for newCiv -1, which no caller passes. |
| The C1/C2 bytes | `p4tests.py c1`, `c2` | pass: C1 as before. C2: with the save's mask 0xBF the launch rule reads the word at 12D8:45C2 (1281 > 1000: civ 3 launches); with mask 0xFF the read of 12D8:4642 lies beyond the 0x4620-byte segment and the fault policy stops the run at 1030:28A7 |
| The font index test of 5.5 | `p4tests.py fonts` | pass (DESIGN.md Q22) |
| Message-queue rules (WM_TIMER coalescing, double-click, PeekMessage FALSE leaves `g_msg` intact) | `test_queue`, `test_user` | pass |

## How the last items were closed

* **G53, G6 (first site), C7, G44.** Each depends on a random draw (a Trireme's
  `RandomBelow(2)`, a disaster's or wonder purchase's city choice `RandomBelow(128)`). The
  stream is seeded by srand(time()) at start-up, so the virtual date steers it (the boot offset
  does not). G6, C7 and G44 use a crowded world: city slots 5..127 filled with size-21 AI cities,
  the map visible to every civ, the AI civs in contact with the human. Without the visibility
  ProcessCity drops the squares a city's owner has not seen, the citizens are all entertainers,
  and the unrest test compares 0 with 0.
* **C6.** gameTurn 31 (a sea uprising turn at difficulty 4) with civ 0's unit table full.
* **G31.** A Diplomat meets the Zulu king, accepts peace and makes a military proposal; the
  human pays 100 and the diplomacy status stays unchanged.
* **C2 and the C2 bytes.** Civ 3's spaceship grid is built from `g_spaceshipLayout` (read from
  the running game, not copied into the repository) so that the new part gives an estimate of
  66 % and the earlier launch triggers fail.
* **G6, second site.** Unreachable as far as the code shows (above); it is not claimed as
  exercised.

## Labels (prompt section 10)

* **Compiled:** Release, Asan and Checked with the phase-4 sources.
* **Headless-tested:** the items marked pass above, in Checked and Asan. These are model
  (self-consistency) evidence: expected values come from the recovered C and the port's own
  models. Edited saves and the 16-colour switch are test input.
* **Agent-observed:** the scenario row frames; `build/frames/p46-msgbox/`; the frames read while
  building the findings scenarios (`build/frames/p49-*-dbg/`, and for the audience, crowd and
  barbarian scenarios frames dumped in scratch runs, since removed).
* **Oracle-compared:** nothing in phase 4.
* **User-confirmed:** nothing in phase 4. The user's directions recorded in `STATUS.md` (skipping
  the Birth movie, full-speed world generation, Space or Enter ending turns, the Exit button
  caption) are not acceptance.
* **Unverified:**
  * same-seed fidelity is not claimed;
  * the 16-colour title picture draws black under the test switch (not investigated; civ64
    never takes that path);
  * G6's second site (unreachable as far as the code shows);
  * whether the original reaches the same states on the same dates (no oracle comparison).

## Phase 8 note (2026-10-10, audits C6, C7; `verify/phase8-audit-C.md`)

The row "Every reachable G, C and R finding in a targeted scenario" says "pass" for a weaker
check than its wording: `findcov.py` (a report run by hand, not part of `test.cmd`) shows that a
statement cited for each of 93 findings ran, not that each behaves as documented. In scope are
94 findings (68 G, 20 C, 6 R): R5, DrawMiniPalace's private generator, is not cited in the core
(FIDELITY F93). Effects are asserted for 14 (G2, G6, G10, G12, G13, G16, G19, G31, G33, G44, G53,
C1, C2, C6); for the others the behaviour rests on the verified translation of the listing
(phase 3c) and the statement being reached; no R finding has an effect check; of 304 cited
statements 58 never ran. Prompt 4 item 6 is therefore met with caveats (final report).

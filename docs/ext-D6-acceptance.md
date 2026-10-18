# Extension phase D6 (play in the DOS profile: class A, menus, zoom) — acceptance record

Prompt: `claude/docs/x64-port-scaling-dos-prompt.md`, phase D6 (section 9): "Play, class A: DOS map rules in the
renderer, small map, status window, map palette animation, menus (R); zoom in the DOS profile."  Gate: "Tests; P0;
Z-1..Z-3 for the DOS profile; agent check."  Brief: [verify/BRIEF-d6.md](verify/BRIEF-d6.md) (decisions 1..9 with the
orchestrator's rulings of 2026-10-15 and the user's direction of 2026-10-16, "no added Go Back / Cancel rows").  The
DOS-oracle comparisons of 7.9 are optional and **not run in D6** (see STATUS): D6's pixel and timing claims are
labelled "DOS listing (model)".  Asan runs are deferred to the end of the queue (the user's direction of 2026-10-10
21:20).  Under the user's direction of 2026-10-15 about 14:09 the phase gate runs the full eight-step cycle (below).
Design: DESIGN.md 12.7, 12.9, 12.11; [verify/ext-d1-draft-D.md](verify/ext-d1-draft-D.md) 9, 10, 14, 16, 19;
[verify/ext-d1-draft-B.md](verify/ext-d1-draft-B.md) 5.5, 7, 8, 11, 12; [verify/ext-d1-draft-C.md](verify/ext-d1-draft-C.md)
C.12.8, C.12.9, C.15.4.

D6 was done in seven units, each with its own record, and four priority units on the user's zoom reports between
them:

* **D6a, the map display model with the Windows rule set (M2) and the present check:**
  [ext-D6a-record.md](ext-D6a-record.md).
* **D6b, logical replay and provenance for play (`pdos_replay`, `pdos_prov`; S3):** [ext-D6b-record.md](ext-D6b-record.md).
* **D6c, the DOS map rules in view (`pmap_dos.c`) and the dos-settled check:** [ext-D6c-record.md](ext-D6c-record.md)
  (with its review, folded into D6d as D6cF).
* **D6d, the DOS ring, zoom in the DOS profile and the map palette animation:** [ext-D6d-record.md](ext-D6d-record.md).
* **MZ, MZW, MZI, MZS** (the user's zoom reports of 2026-10-16: the unit centred at -1 and +1, the World Map's
  rectangle at every level, menus and dialogs over the zoomed map, both graphics): [ext-MZ-record.md](ext-MZ-record.md),
  [ext-MZW-record.md](ext-MZW-record.md), [ext-MZI-record.md](ext-MZI-record.md), [ext-MZS-record.md](ext-MZS-record.md).
* **D6e, the small map, the status window and the unit panel (class A); the play palette's return (B 5.5 item 2) and
  R3; draft D 19 "not zoomed":** [ext-D6e-record.md](ext-D6e-record.md).
* **D6f, menus (R) on the A canvas (the bar, the drop-downs, the 2x placement of D5b's re-skins); I-play and
  I-menubar:** [ext-D6f-record.md](ext-D6f-record.md).
* **D6g, the sweep, the agent check and this gate:** [ext-D6g-record.md](ext-D6g-record.md).

Labels as in `ext-D5-acceptance.md`: **compiled**, **headless**, **Win32-headless**, **DOS listing (model)**,
**agent-observed**, **DOS-oracle-compared** (not run in D6), **user-confirmed**, **unverified**.  No DOS program was
executed; nothing was written to `C:\Projects\Civ1RE\dos` or `build/dosdata`.

## Gate

Every row ran in the final cycle's `test.cmd checked` (step 2) unless it says otherwise; the markers are that run's
(section "The final cycle").

| Gate item | Scenes (DOS-PROFILE rows) | Method | Evidence (unit) | Result |
| --- | --- | --- | --- | --- |
| the DOS map: squares, units, cities, labels, unexplored edges | 96, 133, 134, 135, 140 | headless; DOS listing (model) | `test_map` (16.1's DOS composition order, the layer order of 14.2), `ext_mirror` dos-settled (P_dos at every DrawTilesToPort / RedrawMapRect exit equals the DOS rules' redraw; `dos_unexplained 0`) (D6c) | **PASS**: test_map 338 (Release 338; CheckedNoObs 1), MIRROR_OK runs 29 (`dos_settled 86 dos_mismatched 0 dos_skipped 0 dos_unexplained 0`); agent-observed (shot 04); user-confirmed D6c-1..D6c-4, D6c-6, D6c-7 |
| animations at the core's pace (move, combat, blink) | 132, 133, 134 | headless; DOS listing (model) | the model's CONTEXT macros (AnimateUnitMove, ResolveCombat), `ext_mirror` (D6a, D6c) | **PASS**: MIRROR_OK runs 29 (`present 13386 present_mismatched 0 unexplained 0`); user-confirmed D6c-5 (passed 2026-10-16 about 11:38 UTC) |
| the map palette animation | 107 | headless; DOS listing (model) | `test_pdos_profile` `test_play_cycle` (one step per CyclePaletteColors entry; D6cF G2), `test_map` (the element composed again on a step), `test_pdos_pal` (R3: the position kept) (D6c, D6d, D6e) | **PASS**: test_pdos_profile 51 (CheckedNoObs 47), test_map 338, test_pdos_pal 239; user-confirmed D6c-5, D6d-5 |
| the small map | 96, 139 | headless; DOS listing (model) | `test_pdos_play` (colours and frame from a synthetic snapshot), ext_zoom's "not zoomed" (draft D 19) (D6e) | **PASS**: test_pdos_play 46 (every variant), ZOOM_OK `not zoomed 38/448`; agent-observed (shots 04, 07, 19); D6e-1..D6e-7 pending (user) |
| the status window and the unit panel | 96, 136, 138 | headless; DOS listing (model) | `test_pdos_play` (status lines, unit-panel lines, the stack's "+") (D6e) | **PASS**: test_pdos_play 46; agent-observed (shot 04); D6e items pending (user) |
| the play palette's return (B 5.5 item 2), R3 | 107 | headless; DOS listing (model) | `test_pdos_pal` (D6e) | **PASS**: test_pdos_pal 239 (every variant) |
| the menu bar and drop-downs | 121 (and the menu items' rows as drop-down rows) | headless; DOS listing (model) | `test_pdos_reskin` (titles, colours, positions, drop-down rows), ext_adapt (a menu-bar click and a drop-down choice against the Windows profile's) (D6f) | **PASS**: test_pdos_reskin 121 (CheckedNoObs 110), EXT_ADAPT_OK checks 189; agent-observed (shots 04, 05: the bar and GAME's drop-down, no Cancel row); D6-1, D6f-1..D6f-8 pending (user) |
| the A-canvas re-skins of decision 1 | 14, 22 (MenuZ 136, 145: the rates 30, 31, the Options, Revolution, Retire and Quit boxes 33..43, the population message 137), 94, 141 (`#MsgBox`) | headless | `test_pdos_reskin` (2x placement, clipping), ext_adapt (D6f) | **PASS**: test_pdos_reskin 121, EXT_ADAPT_OK checks 189; D5-7 pending (user) |
| I-play and I-menubar | C.12.8 | headless | `test_input` (I-play pairs, I-menubar), ext_adapt (F-keys against Ctrl+digit, Alt+V, case 13) (D6f) | **PASS**: test_input 502 (CheckedNoObs 446, Release 502), EXT_ADAPT_OK checks 189 |
| Z-1..Z-3 for the DOS profile | 96 | headless; Win32-headless | the table "Z-1..Z-3 for the DOS profile" below | **PASS** (Z-1, Z-2, Z-3; below) |
| 7.5 `--mirror 2`: present and dos-settled checks | 96 | headless | `ext_mirror.py` (29 runs: checks, mismatches 0, `unexplained 0`, `present_mismatched 0`, `dos_mismatched 0`, `dos_unexplained 0` per run) (D6a, D6c) | **PASS**: MIRROR_OK runs 29; MIRROR_TOTAL checks 21712, present 13386, `present_mismatched 0`, `unexplained 0`, dos_settled 86, `dos_mismatched 0`, `dos_unexplained 0` |
| 7.3 P0 | every scenario | headless | `ext_p0.py` Checked (V0..V8s with V1, V2, V4d: the DOS profile and switching) and CheckedNoObs (V5) | **PASS**: P0_OK checks 476 (Checked), 62 (CheckedNoObs) |
| G-1 | 77 runs | headless | `ext_g1.py check` on Checked and CheckedNoObs | **PASS**: EXT_G1_OK runs 77 (amended 1) on both |
| 7.4 frame determinism | s3, birth, start; the zoomed frames | headless | `ext_frames.py`; `ext_zoom.py` (ZOOM_OK) | **PASS**: EXT_FRAMES_OK; ZOOM_OK combinations 32 runs 108 samples 628; the full matrix (decision 6, below) |
| 7.8 DOS-form equals Windows-form | every D4..D6 pair | headless | `ext_adapt.py` (EXT_ADAPT_OK) | **PASS**: EXT_ADAPT_OK checks 189; ADAPT_OK rows 116 steps 25 |
| decision 8: counters per D4 / D5 / D6 row | GATE_ROWS | headless | `ext_p0.py` V1, V2: `pdos_rows` (below) | **PASS**: every D4, D5 and D6 gate row 0 in V1 and V2 (33 runs each) beyond ROW_ALLOW's one recorded count (row 14 `unexplained` 2 in `city`: the city screen's fill, D7) |
| decision 6: the full ext_zoom matrix | 96 | headless | D6g's `sweep_zoom.py` (win a/b, dos a/b, sw at every size; the DOS soak) | **PASS**: ZOOM_OK combinations 32 runs 160 samples 776, not zoomed 64/796; the tree's 628 golden lines equal, the 148 new ones the DOS soak's (below) |
| tables and documents | - | headless | `adapters.py check`, `registry.py check`, `nodos.py check`, `pdos_scene_check.py`, `obs_tables.py --check`, `obs_lint.py` | **PASS**: ADAPT_OK rows 116 steps 25, REGISTRY_OK, NODOS_OK (1752 files, 0 hits), pdos_scene_check 1078 checks (141 scene rows, 8 font rows), OBS_TABLES_OK probes 203 sites 101, OBS_LINT_OK files 124 probes 203 callsites 101 |
| 7.9 DOS-oracle comparisons | - | not run in D6 (optional; see STATUS) | - | not run |
| agent UI check (decision 7) | play in the DOS profile; M's Windows-profile zoom | agent-observed | `ext-D6g-record.md` "The agent UI check"; shots `build/ext-d6-ui/` | **done**, one attempt (2026-10-17 06:03:13..06:09:05 UTC, 33 shots): as expected, with the main row's Ctrl+Shift+0 not reaching civ64 on this PC (known, M-3; Ctrl+Shift+Home used); no Go Back / Cancel row on a DOS screen; not user acceptance (below) |
| user checks | the D6 items | user-confirmed | `manual-checklist-ext.md` (below) | 58 of the checklist's 223 items pending, among them D6-1, D5-7, D6e-1..D6e-7 and D6f-1..D6f-8; D6c-1..D6c-7, D6d-1..D6d-3, D6d-5, D6d-6, M-1d and MZ-4 passed |

Verdict: **the D6 gate is met** (D6 phase gate met 2026-10-17: the eight-step cycle ALL_GREEN 06:02:50 UTC, the full
ext_zoom matrix 06:49:31 UTC): play in the DOS profile (the DOS map rules in view, animations at the core's pace,
the map palette animation, the small map, the status window and the unit panel, the play palette's return, the menu
bar and the drop-downs, the A-canvas re-skins, I-play and I-menubar) and zoom in the DOS profile pass headless (the DOS
pixels and timings as **DOS listing (model)**) in Checked, CheckedNoObs and Release, with Z-1..Z-3 for the DOS profile,
decision 6's full ext_zoom matrix, 7.5's present and dos-settled checks, 7.8, P0 (with V1, V2, V4d and CheckedNoObs),
G-1's 77 runs on both Checked variants, 7.4 and decision 8's counters (every D4, D5 and D6 row 0 beyond row 14's one
recorded count in `city`); the agent UI check done (agent-observed).  Known differences: **R1** and **R2**, rows the
DOS game lacks, with no owner unit; informational: **X9**'s coverage torn lines (section "Known differences and open
items").  Not part of the verdict: the DOS-oracle comparisons (not run in D6, optional), Asan (deferred), the 58
pending user checks and the items under "Not verified".

## The final cycle

The D6 phase gate ran the full eight-step cycle at the D6g landing (the stager in the build slot, given by the
orchestrator at 05:13:30 UTC after the docs pass for FCE and D6f; copy-in 05:14:08 UTC: `tests/harness/ext_p0.py` and
the draft of `ext-D6g-record.md`, `build/d6g-prep/landed.sha256`).  Status `build/d6-gate-status.txt` (ends
ALL_GREEN), logs `build/d6-gate-<n>-<step>.log`, every step at its first run (the w32_test_host_win32 GetKeyState
flake did not occur):

| Step | Command | Exit | Seconds | UTC | Last line |
| --- | --- | --- | --- | --- | --- |
| 1 | `build.cmd checked` | 0 | 191 | 05:14:16..05:17:27 | BUILD_OK variant=Checked |
| 2 | `test.cmd checked` | 0 | 1575 | 05:17:27..05:43:42 | TESTS_OK variant=Checked |
| 3 | `ext_g1.py check` | 0 | 0 | 05:43:42 | EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) |
| 4 | `build.cmd checked noobs` | 0 | 210 | 05:43:42..05:47:12 | BUILD_OK variant=CheckedNoObs |
| 5 | `test.cmd checked noobs` | 0 | 382 | 05:47:12..05:53:34 | TESTS_OK variant=CheckedNoObs |
| 6 | `ext_g1.py check --variant CheckedNoObs` | 0 | 0 | 05:53:34 | EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) |
| 7 | `build.cmd` | 0 | 205 | 05:53:34..05:56:59 | BUILD_OK variant=Release |
| 8 | `test.cmd` | 0 | 351 | 05:56:59..06:02:50 | TESTS_OK variant=Release |

* **Markers.**  Checked (29 sections in parallel, wall 1573.1 s, failed 0): REGISTRY_OK, NODOS_OK, GATE3B_OK,
  UNINIT_OK, P4_SCENARIOS_OK, P4_TESTS_OK, OBS_TABLES_OK probes 203 sites 101, OBS_LINT_OK files 124 probes 203
  callsites 101, pdos_scene_check 1078 checks (141 scene rows, 8 font rows), ADAPT_OK rows 116 steps 25, P0_OK checks
  476, EXT_FRAMES_OK, EXT_TIMELINE_OK (base and bs), EXT_CONTINUE_OK, EXT_ASPECT_OK, EXT_BS_OK (assets, mirror),
  EXT_ADAPT_OK checks 189, EXT_SLOTS_OK, EXT_TLD_OK, EXT_FCE_OK runs 8, MIRROR_OK runs 29 (MIRROR_TOTAL checks 21712,
  present 13386, present_mismatched 0, unexplained 0, dos_settled 86, dos_mismatched 0, dos_skipped 0, dos_unexplained
  0), REPLAY_OK checks 70, ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32 centre runs 4 mzi runs 12
  mzs runs 4 not zoomed 38/448, TRACE_OK; coverage "other functions entered" 663 (X9, below).  CheckedNoObs: the same
  without the Checked-only sections, P0_OK checks 62.  Release: REGISTRY_OK, NODOS_OK, OBS_TABLES_OK, OBS_LINT_OK,
  pdos_scene_check 1078, ADAPT_OK rows 116 steps 25, TRACE_OK.  55 test programs in each variant, 0 failures
  (test_input 502 / 446 / 502, test_map 338 / 1 / 338, test_host_win32 410 / 381 / 410, test_pdos_reskin 121 / 110 /
  121, test_pdos_play 46 / 46 / 46, test_dos 23,239; Checked / CheckedNoObs / Release).
* **Against the predictions** (`build/d6g-prep/predictions.txt`, written before the copy-in; the snapshot of
  `build/test/Checked` from D6f's cycle, `build/d6g-prep/before/`, compared by `build/d6g-prep/compare.py`,
  `comparison.txt`): 57 of 63 files the same.  The differences: `ext-p0.txt`'s 66 PASS lines of decision 8 (33 V1,
  33 V2) with the new wording "D4's, D5's and D6's scene rows" (P0_OK 476, no FAIL; predicted); coverage's "other
  functions entered" 664 -> 663 (X9's torn lines; predicted as a possible move); nodos 1751 -> 1752 files (the staged
  record, new in `docs/`; not in the predictions, explained); `unit.log`'s OBS_COST line and `times.txt` (timings).
  No other change.
* **CheckedNoObs and Release** (`obj/land/variants.py`, D5 gate -> D6 gate, 80 items, 49 unchanged): every change in
  CheckedNoObs and Release goes with the change Checked shows over the same span (the new and extended tests and
  markers of the units landed since the D5 gate), CheckedNoObs' counts lower by its observer-only checks as at D5
  (test_map 1, test_pdos_fce 1, P0_OK 62 unchanged).  No unexplained difference.

## Decision 8: the counters by scene row

`ext_p0.py` (as landed by D6g) requires 0 for D4's, D5's and D6's rows: GATE_ROWS 1..9, 16, 20, 21, 25, 27, 105, 116
and D6_ROWS (52: 14, 22, 30, 31, 33..66, 94, 96, 107, 121, 132..140, 141; `ext-D6g-record.md` "What D6g does"), for
`unexplained`, `w_over_n`, `font_unmapped`, `colour_nearest` and `prov_unknown`, in every V1 and V2 run, beyond
ROW_ALLOW's recorded counts (D6g's per-run form).  In the gate's step 2, every gate row is 0 in every run except the
one recorded count:

* row 14 (136 plain message, MenuZ) `unexplained` 2 in `city` only (V1 and V2): the city screen's window (row 97, D7)
  filled twice (FILLRECT 0,0,512,320, no probe open) while dialog 136's box is on top of the stack, before the city
  window is active again; the box over a D7 screen.  `ROW_ALLOW[(14, "unexplained")]` covers the run `city` only.

In V1 and V2 alike (33 runs each; `obj/rowsum_d6.py --md` over the gate's outputs,
`build/d6g-stage/obj/rowsum-gate.txt`, the same table line for line as on D6f's cycle; `w_over_n`, `colour_nearest`
and `prov_unknown` are 0 for every row), the rows that keep counts:

| Row (DOS-PROFILE) | Counter | V1 (= V2) | Runs | Whose |
| --- | --- | --- | --- | --- |
| 0 (an empty stack) | unexplained 258, font_unmapped 72 | 6 | arrival, load, quiz, research, research2, s2 | the leader audience's later speeches on dialog 142 (below): D7k |
| 11 (130 Civilopedia page and list) | unexplained 82, font_unmapped 2 | 2 | research, research2 | D7 |
| 14 (136 plain message, MenuZ) | unexplained 2 | 1 | city | ROW_ALLOW (city): the city screen's fill under the box (row 97, D7) |
| 15 (137 text entry), 17 (140 production list) | unexplained 1, 1 | 1 | city | D7 |
| 19 (142 leader audience) | unexplained 54, font_unmapped 24 | 6 | the runs from a save | D7k |
| 23, 24 (146, 147 discovery), 26 (149 quiz) | unexplained 12, 12, 27 | 1 each | research, research2, quiz | D7 |
| 67..79 (the Advisors, World and Civilopedia menus' screens) | unexplained 1..91, font_unmapped 1 (79) | 1 (75: 4) | menus (75 also arrival, conquest, retire; 78 spaceship) | D7 |
| 88, 97, 98, 101..104 | unexplained 4, 2272, 22, 6, 1, 1001, 9 | 1..4 | city, new, s3, settlers, menus, the game ends | the city screen, reports, the newspaper, the spaceship, the replay, the palace: D7 |
| 109, 114, 120, 122, 124, 130 | unexplained 67, 2, 29, 9, 2, 167 | 1..3 | new, s3, settlers, conquest, arrival, retire | play animations and endings: D7 |

No play row (96, 107, 121, 132..140) and no menu row of play has a count in any run.

Row 0 (an empty stack), which D5's table gave to D6's play renderer, is the leader audience's later speeches on
dialog 142 after RequestLeaderAudience's return has popped rows 100 and 19: D7k's (`ext-D6g-record.md` "Row 0 after
a Load"; read with a private diagnostic build over the six runs from a save, 330 events, none of them a play drawing).

## Z-1..Z-3 for the DOS profile

From the gate's outputs (`obj/ztable.py` over step 2's `build/test/Checked`, step 5's `CheckedNoObs` and the full
matrix; `build/d6g-stage/obj/ztable-gate-sweep.txt`):

| Z item (DOS profile) | Method | Evidence | Result |
| --- | --- | --- | --- |
| **Z-1** levels -1, 0, +1 (m = 2*s_l, the even origin at -1); chords, wheel, reset, menu items in the DOS profile | compiled; headless; Win32-headless | `test_map` (the DOS geometry tables: m = 2*s_l, k x k DOS art pixels at -1, the even origin), `test_host_win32` (the zoom items, `--zoom`), ext_adapt zoomkeys-dos (chords and wheel in the DOS profile), `ext_zoom` dos runs at five host sizes and both levels | **PASS**: test_map 338 checks (Release 338, CheckedNoObs 1), test_host_win32 410 (CheckedNoObs 381); zoomkeys-dos equals the plain run, its 79 chord and wheel lines `events 0` with their commands, one switch (requests 1 switches 1 refused 0), the DOS layer drawn in 72 shows; agent-observed (shots 07..17) |
| **Z-2** the DOS layer: in view the DOS pixels (M_dos), the ring by the DOS rules (G_dos), pixel-perfect at -1 for every k; deterministic zoomed DOS frames; the profile-switch half | headless | `ext_zoom` dos a = dos b, the DOS goldens, sw, the layer samples `map windows` / `map dos` equal in win b, dos a, dos b and sw, the "not zoomed" pairs; `ext_mirror` dos-settled | **PASS**: test.cmd's ZOOM_OK combinations 32 runs 108 samples 628 (the tree's 240 DOS golden lines); the full matrix ZOOM_OK combinations 32 runs 160 samples 776, not zoomed 64/796 (dos a = dos b at every size and in the soak; the tree's 628 golden lines equal; below); MIRROR_OK runs 29 with `dos_mismatched 0 dos_unexplained 0` |
| **Z-3** input in the zoomed DOS map; P0 under zoom changes | headless; Win32-headless | ext_adapt ring-dos = ringref (a ring click equals the small-map click), zoomkeys-dos = plain; `ext_p0` V4d (27 runs at 1920x1440, the zoom cycling, DOS shown and switching every 997 ms, equal to V0); CheckedNoObs V5 and the zoom refusals; MZ / MZI / MZS dos runs; EXT_G1_OK on both Checked variants | **PASS**: ring-dos equals ringref-dos (ring_press 1, ring_refused 0, the DOS layer drawn in 151 shows); V4d: the map layer drawn in the DOS profile in 22 runs, in the Windows profile in 22; P0_OK checks 476; CheckedNoObs P0_OK checks 62 (V5 refuses `--zoom` and the zoom command: exit 2); MZI 12 and MZS 4 runs ok; agent-observed (shots 18, 19, 32) |

## Decision 6: the full ext_zoom matrix

`build/d6g-stage/obj/sweep_zoom.py` (the tree's `tests/harness/ext_zoom.py` with its matrix rule replaced: win a and b,
dos a and b, sw at every host size of the three scenarios and the soak at 1920x1440; every check ext_zoom.py's own)
ran once after the cycle, 2026-10-17 06:09:26..06:49:31 UTC (40 min), `-j 4`, with a copy of step 1's Checked harness
(`obj/exe/gate/civ_harness.exe`), its runs and its goldens in a private root (`obj/run/sweep`; nothing written to
`build/` or to the tree's goldens):

* `SWEEP_ZOOM runs 160 (win 64 dos 64 sw 32) exit 0`; every one of the 32 combinations (new, load and orders at
  640x480, 1280x960 and 1920x1440 integer, 2560x1600 fit-sharp and 1366x768 fit-nearest, the soak at 1920x1440
  integer; -1 and +1 each) "ZOOM ok"; the centre (4), MZI (12) and MZS (4) runs ok.
* `ZOOM_OK combinations 32 runs 160 samples 776 map comparisons 32 centre runs 4 mzi runs 12 mzs runs 4 not zoomed
  64/796` (test.cmd's matrix: runs 108 samples 628, not zoomed 38/448).
* `obj/golden_cmp.py` (the private golden against `tests/harness/ext-zoom-golden.txt`): tree lines 628, private
  776, equal 628, missing 0, differing 0; the 148 extra lines are the DOS soak's (74 at -1, 74 at +1), which
  test.cmd's matrix does not run (checked by dos a = dos b and the layer samples against win b and sw);
  GOLDEN_CMP_OK.

ext_mirror (`--mirror 2`, 29 runs), ext_p0 (V1, V2, V4d) and ext_frames run in full in `test.cmd checked`; the cycle's
step 2 is their full run (section "The final cycle").

## The agent UI check

Decision 7, ruling 7: one attempt, 2026-10-17 06:03:13..06:09:05 UTC, after the cycle, with a private copy of the
gate's Release `civ64.exe` (the user build's), a private data copy without sound, a private home (the user's
`%LOCALAPPDATA%\civ64` untouched: its `civ64.cfg` last written 2026-10-10) and `--multi-instance` (the user's own
civ64 from build d6f, running at the time, was not touched).  civ64 windows only; 33 shots and the step log in
`claude/port/build/ext-d6-ui/` (method and steps: `ext-D6g-record.md` "The agent UI check").  **Agent-observed, not
user acceptance**: no checklist item is marked by it.

* **Completed as planned**; every step had the expected result except the main row's Ctrl+Shift+0, which does not
  reach civ64 on this PC (no effect at -1 and at +1, shots 08 and 12).  That is the known condition of M-3 ("a running
  keyboard tool takes it first"; the user chose Ctrl+Shift+Home, UX4b): Ctrl+Shift+Home reset the zoom (shot 13), as
  did the window menu's "Normal map zoom" (shot 28).  The command itself is covered headless (`test_host_win32`,
  ext_adapt zoomkeys-dos).
* **Play in the DOS graphics** (shots 01..06): the DOS intro, the DOS title menu, the DOS load slot screen, and after
  the Load the DOS map at twice the size, the World Map's DOS small map with its white frame, the DOS status panel and
  unit panel, the DOS menu bar; a click on GAME opens its DOS drop-down (Save Game .. QUIT to DOS), Escape closes it
  and the map is whole.  No Go Back / Cancel row on any DOS screen seen (title, slot screen, drop-down), as the user's
  direction of 2026-10-16 requires.
* **Zoom in the DOS graphics** (shots 07..19): Ctrl+Shift+Minus -1 (the DOS ring, the World Map's rectangle larger),
  Ctrl+Shift+Plus back to 0 and to +1, Ctrl+Shift+Home to 0; the wheel over the map -1, 0, +1, 0; at -1 a left click
  on a ring square recentres the map there and the World Map's frame follows.
* **The switch at -1 and M's Windows-profile checks** (shots 20..33): Ctrl+Shift+Backspace shows the Windows map at
  -1 at the same place; the chords and the wheel (0, +1, 0, -1); the window menu's zoom items (the mark on the current
  level; "Normal map zoom" and "Zoom out (half)" chosen by keyboard); a ring click recentres; Ctrl+Shift+Backspace
  back to the DOS graphics at -1 at the same place.
* **The window menu** was opened by a click on civ64's window icon: Alt+Space was taken by PowerToys Run on the
  user's desktop (its global hotkey; its box was open about 20 s, nothing was typed into it, and it closed when civ64
  was brought to the front), and a posted SC_KEYMENU does nothing (civ64's host keeps Alt and F10 for the game's
  menus).
* **End**: the exit warning's Exit Anyway; civ64 ended, its private `civ64.cfg` (zoom=-1, graphics=dos) read and the
  private data removed; no civ64 of the agent's left running.

## Deviations (summary, one line each)

* D6a: DrawMapTile's leave for the Windows set (the bevel's undefined colour from the core's port, GetColorIndexRGB
  1098:01B0); window draws and copies change only `ObsDraw.changed` (clipped by the visible and update regions), the
  owner copies map-to-map SRCCOPYs itself; the DAMAGE, logical-source and owner-once rules with the per-rule-set
  unexplained count; the game's SectRect 1100:0685 for labels; `ext_mirror.py` passes `--graphics windows`.
* D6b: no replay while a scripted row is on the stack, logical shadows only in ready N replay rows, kinds 1 and 2 only
  into existing or owner-claimed shadows (`scripted`, `no_scene`, `no_shadow`); a disposed tile handle keeps its
  provenance entry until reused (TileDispose 11A8:00D1 has no probe).
* D6c: D806 taken as 0 (no writer in the listing); no Wn_dos reference check (dos-settled is on P_dos only).
* D6d: the DOS layer's palette step under `fit` sharp renders the whole image again; the DOS layer is not drawn while
  the DOS profile shows an N frame in play (`dos_frame`).
* MZ, MZW, MZI, MZS: their records' deviations (the centring rules at -1 and +1, the World Map's rectangle, the
  in-view source under menus and dialogs).
* D6e: the module is `pdos_aplay` (B 2's `pdos_play` collides with the play palette's names); Choice B17's alternative
  (the module's own reads); `PDOS_OWNER_MAX` 4 -> 5; the unit panel's lines are the core's strings with the DOS static
  words; the DOS outline one DOS pixel outside the core's frame; the palace strips' top row clipped by the column; the
  palette return applied at RestoreMapAfterDialog only when the palette changes (the TX fades D7's); R3 by keeping the
  position (`pdos_play_back`).
* D6f: Choices D6f-1 (I-play only while the menu bar's window is active), D6f-2 (a drop-down covers its Windows popup
  with its shadow), D6f-3 (an unpaired item: the core's text with its accelerator in colour 15), D6f-4 (Alt+V on a
  MenuZ box consumed; deviation from C.12.8's outline), D6f-5 (Alt+C and Alt+H with the Windows meaning, O3), D6f-6 (an
  A box at least its Windows window's size); R1..R4 below.
* D6g: ROW_ALLOW's entries name the runs they cover (row 14 `unexplained` in `city` only); the probe-less D6 rows
  (96, 107, 121, 135 and most menu rows) are in GATE_ROWS for completeness and cannot fail; the full ext_zoom matrix
  as a private run (`sweep_zoom.py`, the tree's runner with its matrix rule replaced; goldens to a private file).

## Known differences and open items

* **R1** (known difference, no owner unit): the drop-downs of the Windows-only menus EDIT, CITY and HELP, rows the DOS
  game lacks (their titles are P24's settled design); no D7 unit takes the menu bar or the drop-downs (BRIEF-d7.md
  D7a..D7o); they stay by design (P24, ruling 2) unless the orchestrator assigns them (ext-D6f-record.md "Report
  items"; FIDELITY F196, F197).
* **R2** (known difference, no owner unit): the Windows separators as empty disabled rows, and ORDERS with every
  Windows item including the grayed ones (colour 3), where DOS builds only the orders available on the square
  (R:1C84:01D8); ruling 2: the core's state decides which rows exist.
* R3 (the message boxes in play are re-skinned Windows dialogs: Revolution's, row 41, D7g; Help > Game Help's box with
  its OK row, row 94, and the system message boxes, row 141, recorded as W by D7o) and R4 (dialog 145's boxes without
  DOS's "(HELP AVAILABLE)" line, DGROUP:2FBD: D7g) have owners in D7.
* **X9, the coverage torn lines**: `build/x64/Checked/coverage-civ_harness.txt` gets torn lines from the concurrent
  appends of the parallel harness runs (for example the malformed keys `11E0:01110:1767` and `368`), which coverage.py
  counts as functions, so `coverage.txt`'s "other functions entered" moves from run to run (668, 666, 664 in the last
  cycles; 663 in this gate's, "The final cycle").  Informational; recorded in STATUS beside the coverage append race
  item for X9 (coverage.py or host_coverage), not changed in D6.
* Row 0's counts are the leader audience's (D7k), not D6's (section "Decision 8").

## Asan

Deferred under the user's direction of 2026-10-10 21:20 (the end of the queue); not run in D6.

## For the records

Gathered from the seven unit records and the four MZ units; none is applied by the stagers (DESIGN, FIDELITY, STATUS,
RUNNING, FEATURES, DOS-PROFILE, the manual checklist and the D0 / D1 documents are the docs agent's):

| Unit | Its "For the records" | Applied |
| --- | --- | --- |
| D6a | [ext-D6a-record.md](ext-D6a-record.md) | by the docs pass after its landing (build/docs-d6a-done.txt) |
| D6b | [ext-D6b-record.md](ext-D6b-record.md) | docs-d6b |
| D6c | [ext-D6c-record.md](ext-D6c-record.md) | docs-d6c |
| D6d (with D6cF) | [ext-D6d-record.md](ext-D6d-record.md) | docs-d6d |
| MZ, MZW | their records | docs-mzw |
| MZI, MZS | their records | docs-mzs (2026-10-17 00:53:30 UTC) |
| D6e | [ext-D6e-record.md](ext-D6e-record.md) | docs-tld (with TLD; 2026-10-17 02:28:30 UTC) |
| D6f | [ext-D6f-record.md](ext-D6f-record.md) | docs-d6f (with FCE; 2026-10-17 05:13:30 UTC) |
| D6g | [ext-D6g-record.md](ext-D6g-record.md) | pending (this gate) |

The earlier units' items are applied (the table); D6g's, in one list for the docs agent:

* **STATUS**: the D6 phase gate met (2026-10-17: the cycle ALL_GREEN 06:02:50 UTC, the full ext_zoom matrix
  06:49:31 UTC; the verdict above); the user build d6g
  (`claude/port/build/user-builds/d6g/`, no new items, the 58 pending items checkable there); the known differences
  R1 and R2 (no owner unit) and the X9 coverage torn-lines item (beside the coverage append race item); the agent
  check's result (agent-observed, not user acceptance).
* **DOS-PROFILE.md**: rows 96, 107, 121, 132..140, 14, 22, 94, 141 and the menu rows of play (30, 31, 33..66) are
  D6 gate rows (decision 8: 0 for every counter in V1 and V2); row 14's recorded count in `city` (the city screen's
  fill under dialog 136's box, D7).  Row 0's counts after a Load are D7k's (the leader audience), not D6's.
* **For D7k** (BRIEF-d7.md): the audience's whole span on the scene stack (row 100 entered at
  HoldDiplomaticAudience 1160:0000, or a window-bound row kept until its window goes when a row beneath it pops) and
  the leader font table (`pdos_fontmap_set_leader_table`) set in the product; then row 0's 258 / 72 counts become
  row 19's (`ext-D6g-record.md` "Row 0 after a Load").
* **For D7** (the city screen): row 14's ROW_ALLOW entry (city) goes when the city screen's fill under a MenuZ box is
  D7's renderer's.
* **RUNNING**: the full ext_zoom matrix (`sweep_zoom.py`) is D6g's private tool and not a harness option; nothing new
  to run.
* **FEATURES**: none from D6g.
* **The checklist**: no new items (the coordinator's sections; the agent check marks none).

## User checks left pending

From `manual-checklist-ext.md` at the gate (its Count, 2026-10-17 after the docs pass for FCE and D6f; recounted by
D6g's `obj/land/pending.py`, about 06:03 UTC; the checklist last changed 05:14:02 UTC): **223 items: 162 passed,
58 pending (all checkable, none "not yet implemented"), 3 superseded.**  The D6 items among the pending: D6-1 (the DOS
menu bar) and D5-7 (the tax-rate box as a DOS menu box), D6e-1..D6e-7 and D6f-1..D6f-8.  All 58 can be checked in
the gate's user build `claude/port/build/user-builds/d6g/` (made 2026-10-17 about 06:03 UTC from the gate's Release: `civ64.exe` SHA-256
7256863d9c7e13c3bd48bec7b89a412acfa12424bd0c7b75c2ae5feade0b9353, 4,414,464 bytes; `CIVWIN.zip` and `civdos.zip` as
in build d4; it contains every earlier build's changes).  Its `WHAT-TO-CHECK.txt` has no new items: "the D6 phase
gate's build; all pending items checkable here", with the pending list by the build that brought them:

| Build | Pending items |
| --- | --- |
| d6f | D6-1, D5-7, D6f-1..D6f-8 (10) |
| fce | FCE-1..FCE-5 (5) |
| tld | TLD-1..TLD-7 (7) |
| d6e | D6e-1..D6e-7 (7) |
| mzs | MZS-1..MZS-6, MZW-8 (7) |
| si | SI-1..SI-6 (6) |
| mzi | MZI-1..MZI-7 (7) |
| ux5 | UX5-1..UX5-7 (7) |
| d5p | D5P-7 (1) |
| any | P47-1 (1) |

The brief's other D6 names are passed: M-1d (M-1's DOS sentence) in build d6d; M-2 in the DOS profile (the ring click
at -1) as D6d-4, superseded and checked again as MZ-4 (passed 2026-10-16 about 19:24 UTC).  The agent UI check (above)
is an agent observation, not user acceptance: none of these items is marked by it.

## Not verified

* Coverage limited to what the scenarios reach (as at M): the settled and dos-settled checks cover the squares, units,
  cities and labels the 29 mirror runs draw; RedrawMapRect's settled check as reached.
* The combat sparks' DOS routine (OPEN L10 / DOS-PROFILE Open 8).
* Costs from one machine under varying load (the DOS layer's palette step under `fit` sharp: D6d).
* The full-screen scenes' TX fades around the play palette's return (D7); rows 93 and 110 (D7, decision 9).
* DOS-oracle comparisons (7.9): not run.  Same-seed and full-game qualification are outside D6.
* The D6 user checks still pending (above).

# Extension phase D7 (every remaining N and R scene of the scene table) - acceptance record

Prompt: `claude/docs/x64-port-scaling-dos-prompt.md`, phase D7 (section 9): "Every remaining N and R scene of the scene
table."  Gate: "Every row implemented or class W with a reason."  Brief: [verify/BRIEF-d7.md](verify/BRIEF-d7.md)
(decisions 1..17 with the orchestrator's rulings, and the user's directions recorded in STATUS "User directions",
among them "no added Go Back / Cancel rows" in the DOS graphics).  D7 completes the third and fourth bullets of D-5
(prompt 4) and reaches every `FEATURES.md` row headless in the DOS profile (prompt 7.10); the FEATURES DOS columns
(D-7) and the completion of DOS-PROFILE.md (D-6) are D8's.  The DOS-oracle comparisons of 7.9 are optional and **not
run in D7** (see STATUS): D7's pixel and timing claims are labelled "DOS listing (model)".  Asan runs are deferred to
the end of the queue (the user's direction of 2026-10-10 21:20).  Each unit ended with the three-step cycle (the
user's decision of 2026-10-15 about 14:09 UTC; `verify/BRIEF-cy.md`).

D7 was done in these units, each with its own record:

* **D7a, N scenes in play, the return to the map, the O14 frame, City Status:** [ext-D7a-record.md](ext-D7a-record.md).
* **D7b, the advisors' reports:** [ext-D7b-record.md](ext-D7b-record.md).
* **D7c, the World reports and the historian:** [ext-D7c-record.md](ext-D7c-record.md).
* **D7d, the DOS city screen:** [ext-D7d-record.md](ext-D7d-record.md) (two recorded follow-ups for row 97 landed with
  D7o: [ext-D7o-record.md](ext-D7o-record.md)).
* **D7e, the city view, the founding scene, the city animations:** [ext-D7e-record.md](ext-D7e-record.md).
* **D7f, the list, entry, production and stack dialogs:** [ext-D7f-record.md](ext-D7f-record.md).
* **D7g, the science advisor's boxes:** [ext-D7g-record.md](ext-D7g-record.md).
* **D7g2, the rest of D7g's rows: the notes, the government menu, the event boxes, the sale question; the DOS boxes centred on the A canvas:**
  [ext-D7g2-record.md](ext-D7g2-record.md).
* **D7h, the Civilopedia:** [ext-D7h-record.md](ext-D7h-record.md) (a recorded follow-up for row 79 landed with D7o).
* **D7h2, the DOS entry page above the menu boxes (the user's D7h-6):** [ext-D7h2-record.md](ext-D7h2-record.md).
* **D7i, the newspaper, New Cabinet, the discoveries and the quiz:** [ext-D7i-record.md](ext-D7i-record.md) (a
  recorded follow-up for rows 23, 24 and 26 landed with D7o).
* **D7j, the palace:** [ext-D7j-record.md](ext-D7j-record.md).
* **D7k, diplomacy and leaders:** [ext-D7k-record.md](ext-D7k-record.md).
* **D7l, the spaceship screens and the arrival:** [ext-D7l-record.md](ext-D7l-record.md); **D7l2, the spaceship
  arrival:** [ext-D7l2-record.md](ext-D7l2-record.md).
* **D7m, the end of the game:** [ext-D7m-record.md](ext-D7m-record.md).
* **D7n, the conqueror ending and the nuclear explosion:** [ext-D7n-record.md](ext-D7n-record.md).
* **D7o, the sweep, the reach and this gate:** [ext-D7o-record.md](ext-D7o-record.md).

Labels as in `ext-D6-acceptance.md`: **compiled**, **headless**, **Win32-headless**, **DOS listing (model)**,
**agent-observed**, **DOS-oracle-compared** (not run in D7), **user-confirmed**, **unverified**.  No DOS program was
executed; nothing was written to `C:\Projects\Civ1RE\dos` or `build/dosdata`.

## Gate

The full runs of decision 13 ran on D7o's private overlay (the staged tree with its own builds) before the landing;
the final cycle's markers are under "The final cycle" below.

| Gate item | Scenes (DOS-PROFILE rows) | Method | Evidence (unit) | Result |
| --- | --- | --- | --- | --- |
| every row of 1.1..1.5 implemented or class W with a reason | all | headless; DOS listing (model) | the scene ledger below (D7o's `obj/ledger.py` over the full runs) | met: D7's 80 rows: 27 ready, 4 spanning their function, 1 class A reached, 40 covered by unit tests and pairs, 8 W with section-4 reasons; D4..D6's rows by their gates |
| every row of 2.1..2.7 closed (decision 17) | - | headless; DOS listing (model) | the counterpart ledger below | met: 140 numbered rows and 7 effects closed, none pending |
| 7.10: every FEATURES row reached in the DOS profile, its frame the DOS form or class W | every FEATURES row | headless | `features.py --scenes --require-all` over the V1 outputs (D7o, decision 16) | met: FEATURES_REACH_OK rows 108 dos 104 w 4 |
| decision 8: the counters 0 for every D7 row | D7_ROWS | headless | `ext_p0.py` V1, V2 from scenes.log | met: every count 0, no ROW_ALLOW entry; the run `city`'s r97 w_over_n 5 listed apart as scripted w16 input (excluded) |
| 7.3 P0 | every scenario; decision 12's G-1 runs | headless | `ext_p0.py` Checked (V0..V8s, `--g1`) and CheckedNoObs (V5) | met: P0_OK checks 521; P0_OK checks 62 |
| G-1 | the G-1 runs | headless | `ext_g1.py check` on Checked and CheckedNoObs | met: EXT_G1_OK runs 77 (the final cycle); V0 of the nine p49 runs equals ext-g1-baseline in the full runs |
| 7.4 frame determinism | | headless | `ext_frames.py`; `ext_zoom.py` | met: EXT_FRAMES_OK; ZOOM_OK combinations 32 runs 108 samples 628 |
| 7.7 the D7 TX effects | | headless; DOS listing (model) | every `ext_timeline.py` entry | met: EXT_TIMELINE_OK (65 checks, every entry) |
| 7.8 DOS-form equals Windows-form | every D7 pair | headless | every `ext_adapt.py` entry | met: EXT_ADAPT_OK checks 421 (every entry) |
| tables and documents | - | headless | `adapters.py check`, `registry.py check`, `nodos.py check`, `pdos_scene_check.py`, `obs_tables.py --check`, `obs_lint.py` | met in the full runs: ADAPT_OK rows 166 steps 27, REGISTRY_OK, NODOS_OK, pdos_scene_check 1086 checks 0 failed; obs_tables and obs_lint in the final cycle's TESTS_OK |
| the agent check (decision 14) | | agent-observed | `obj/ui/agentui.py` | completed: one attempt, 11 shots (below) |

## The scene ledger

D7's rows (the brief's unit list), generated by D7o's `obj/ledger.py` from the scene table and the full runs' outputs
(ext_p0's, ext_adapt's and ext_timeline's scenes.log; the counters as ext_p0's gate attributes them).  "Headless" counts
the runs in which the row was the innermost scene row or the innermost non-R row at a shown frame; a row whose scene
shows through an inner row (25, the picture dialog; 98, the O14 frame) is never innermost there, and its reach is
decision 16's FEATURES reach and its ext_adapt pair.  "Spans its function": an N row of its function only (ProcessCity,
the diplomacy span, the spaceship span, the replay), whose screens' own rows are ready.  No W is provisional (decision
7).  The D4..D6 rows are closed by their gates (`ext-D4-acceptance.md`, `ext-D5-acceptance.md`, `ext-D6-acceptance.md`);
the 1.6 omitted DOS-only scenes and row 25's openers are as DOS-PROFILE 1.6 and WI 4.2 list them.

| Row | Scene | Class | Unit | Renderer | Adapter | Tests | Headless (scenes.log) | Counters (V1, V2) | Result |
|---|---|---|---|---|---|---|---|---|---|
| 98 | Advisors and reports | N | D7a | pdos_scn_report.c (O14 frame, City Status) | REPORT | test_pdos_report, test_pdos_scene; ext_adapt d7a-report | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 67 | 401 Advisors > City Status | N | D7a | pdos_scn_report.c (O14 frame, City Status) | REPORT | test_pdos_report, test_pdos_scene; ext_adapt d7a-report | 6 runs, ready in 6 (e.g. V1/menus) | 0 | ready |
| 25 | 148 picture dialog | N | D7a | pdos_scn_report.c (O14 frame, City Status) | UNSET | test_pdos_report, test_pdos_scene; ext_adapt d7a-report | 272 runs, ready in 272 (e.g. V1/arrival) | 0 | ready |
| 68 | 402 Advisors > Military Advisor | N | D7b | pdos_scn_report.c (advisors' reports) | REPORT | test_pdos_report; ext_adapt d7b-info | 4 runs, ready in 4 (e.g. V1/menus) | 0 | ready |
| 69 | 403 Advisors > Intelligence Advisor | N | D7b | pdos_scn_report.c (advisors' reports) | REPORT | test_pdos_report; ext_adapt d7b-info | 6 runs, ready in 6 (e.g. V1/menus) | 0 | ready |
| 70 | 404 Advisors > Attitude Advisor | N | D7b | pdos_scn_report.c (advisors' reports) | REPORT | test_pdos_report; ext_adapt d7b-info | 4 runs, ready in 4 (e.g. V1/menus) | 0 | ready |
| 71 | 405 Advisors > Trade Advisor | N | D7b | pdos_scn_report.c (advisors' reports) | REPORT | test_pdos_report; ext_adapt d7b-info | 4 runs, ready in 4 (e.g. V1/menus) | 0 | ready |
| 72 | 406 Advisors > Science Advisor | N | D7b | pdos_scn_report.c (advisors' reports) | REPORT | test_pdos_report; ext_adapt d7b-info | 4 runs, ready in 4 (e.g. V1/menus) | 0 | ready |
| 73 | 501 World > Wonders of the World | N | D7c | pdos_scn_report.c, pdos_scn_world.c | REPORT | test_pdos_report, test_pdos_seq; ext_adapt d7c-world | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 74 | 502 World > Top Five Cities | N | D7c | pdos_scn_report.c, pdos_scn_world.c | REPORT | test_pdos_report, test_pdos_seq; ext_adapt d7c-world | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 75 | 503 World > Civilization Score | N | D7c | pdos_scn_report.c, pdos_scn_world.c | REPORT | test_pdos_report, test_pdos_seq; ext_adapt d7c-world | 18 runs, ready in 18 (e.g. V1/arrival) | 0 | ready |
| 76 | 504 World > World Map | N | D7c | pdos_scn_report.c, pdos_scn_world.c | REPORT | test_pdos_report, test_pdos_seq; ext_adapt d7c-world | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 77 | 505 World > Demographics | N | D7c | pdos_scn_report.c, pdos_scn_world.c | REPORT | test_pdos_report, test_pdos_seq; ext_adapt d7c-world | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 123 | ShowHistorianReport 11880DB8 | N | D7c | pdos_scn_report.c, pdos_scn_world.c | WAIT | test_pdos_report, test_pdos_seq; ext_adapt d7c-world | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 97 | City screen and city view | N | D7d | pdos_scn_city.c | CITY | test_pdos_city; ext_adapt d7d-city | 21 runs, ready in 0 | V2 city w_over_n 5 scripted w16 input (excluded); V1 city w_over_n 5 scripted w16 input (excluded) | spans its function (its screens' rows ready) |
| 85 | 701 City > Auto Production | N | D7d | pdos_scn_city.c | CITY | test_pdos_city; ext_adapt d7d-city | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 90 | 706 City > General Information | N | D7d | pdos_scn_city.c | CITY | test_pdos_city; ext_adapt d7d-city | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 91 | 707 City > Happiness Chart | N | D7d | pdos_scn_city.c | CITY | test_pdos_city; ext_adapt d7d-city | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 92 | 708 City > Area Map | N | D7d | pdos_scn_city.c | CITY | test_pdos_city; ext_adapt d7d-city | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 93 | 709 City > Close City Display | A | D7d | pdos_scn_city.c | CITY | test_pdos_city; ext_adapt d7d-city | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 88 | 704 City > Aerial View of City | N | D7e | pdos_scn_cityview.c | WAIT | test_pdos_cityview; ext_adapt d7e-found, d7e-view, d7e-city | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 109 | ShowCityFoundedAnimation 11B814E5 | N | D7e | pdos_scn_cityview.c | WAIT | test_pdos_cityview; ext_adapt d7e-found, d7e-view, d7e-city | 61 runs, ready in 37 (e.g. V2/new) | 0 | ready |
| 111 | PlayCityCaptureAnimation 11B01B63 | N | D7e | pdos_scn_cityview.c | WAIT | test_pdos_cityview; ext_adapt d7e-found, d7e-view, d7e-city | 4 runs, ready in 4 (e.g. V1/p49-find-capture) | 0 | ready |
| 112 | PlayCivilDisorderAnimation 11B01FAC | N | D7e | pdos_scn_cityview.c | WAIT | test_pdos_cityview; ext_adapt d7e-found, d7e-view, d7e-city | 1 runs, ready in 1 (e.g. V1/uninit-s4) | 0 | ready |
| 113 | PlayCelebrationAnimation 11B0237C | N | D7e | pdos_scn_cityview.c | WAIT | test_pdos_cityview; ext_adapt d7e-found, d7e-view, d7e-city | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 12 | 131 Find City list | R | D7f | pdos_rdlg.c | TEXT | test_pdos_rdlg; ext_adapt d7f-prod, d7f-stack, d7f-buy, d7f-name, d7f-find | 6 runs, ready in 6 (e.g. V1/menus) | 0 | ready |
| 32 | 104 Find City | R | D7f | pdos_rdlg.c | UNSET | test_pdos_rdlg; ext_adapt d7f-prod, d7f-stack, d7f-buy, d7f-name, d7f-find | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 15 | 137 text entry | R | D7f | pdos_rdlg.c | TEXT | test_pdos_rdlg; ext_adapt d7f-prod, d7f-stack, d7f-buy, d7f-name, d7f-find | 65 runs, ready in 65 (e.g. V1/city) | 0 | ready |
| 89 | 705 City > Rename City | R | D7f | pdos_rdlg.c | TEXT | test_pdos_rdlg; ext_adapt d7f-prod, d7f-stack, d7f-buy, d7f-name, d7f-find | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 17 | 140 production list | R | D7f | pdos_rdlg.c | MENU | test_pdos_rdlg; ext_adapt d7f-prod, d7f-stack, d7f-buy, d7f-name, d7f-find | 8 runs, ready in 8 (e.g. V1/city) | 0 | ready |
| 86 | 702 City > Change Production | R | D7f | pdos_rdlg.c | MENU | test_pdos_rdlg; ext_adapt d7f-prod, d7f-stack, d7f-buy, d7f-name, d7f-find | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 87 | 703 City > Buy Improvement | R | D7f | pdos_rdlg.c | MENU | test_pdos_rdlg; ext_adapt d7f-prod, d7f-stack, d7f-buy, d7f-name, d7f-find | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 18 | 141 unit stack list | R | D7f | pdos_rdlg.c | STACK | test_pdos_rdlg; ext_adapt d7f-prod, d7f-stack, d7f-buy, d7f-name, d7f-find | 6 runs, ready in 6 (e.g. V1/city) | 0 | ready |
| 14 | 136 plain message (MenuZ) | R | D7g | pdos_reskin.c, pdos_ui.c (D7g) | WAIT | test_pdos_reskin, test_pdos_ui; ext_adapt d7g-dos, d7g-flip, d7g-switch, d7g-esc | 109 runs, ready in 102 (e.g. V1/arrival) | 0 | ready |
| 22 | 145 MenuZ with Help | R | D7g | pdos_reskin.c, pdos_ui.c (D7g) | MENU | test_pdos_reskin, test_pdos_ui; ext_adapt d7g-dos, d7g-flip, d7g-switch, d7g-esc | 19 runs, ready in 19 (e.g. V1/research) | 0 | ready |
| 13 | 135 one-line note | R | D7g2 | pdos_rdlg.c, pdos_reskin.c (D7g2) | WAIT | test_pdos_rdlg, test_pdos_reskin, test_input; ext_adapt d7g2-note-*, d7g2-gov-*, d7g2-sale-*; ext_p0 --g1 runs for rows 115, 126..128 | 87 runs, ready in 85 (e.g. V1/custom) | 0 | ready |
| 41 | 113 Revolution | R | D7g2 | pdos_rdlg.c, pdos_reskin.c (D7g2) | MENU | test_pdos_rdlg, test_pdos_reskin, test_input; ext_adapt d7g2-note-*, d7g2-gov-*, d7g2-sale-*; ext_p0 --g1 runs for rows 115, 126..128 | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 115 | SetGovernment 116806C1 (government menu) | R | D7g2 | pdos_rdlg.c, pdos_reskin.c (D7g2) | MENU | test_pdos_rdlg, test_pdos_reskin, test_input; ext_adapt d7g2-note-*, d7g2-gov-*, d7g2-sale-*; ext_p0 --g1 runs for rows 115, 126..128 | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 117 | ShowInstantAdvice 10E0077F | R | D7g2 | pdos_rdlg.c, pdos_reskin.c (D7g2) | WAIT | test_pdos_rdlg, test_pdos_reskin, test_input; ext_adapt d7g2-note-*, d7g2-gov-*, d7g2-sale-*; ext_p0 --g1 runs for rows 115, 126..128 | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 118 | ShowErrorNote 10E007E8 | R | D7g2 | pdos_rdlg.c, pdos_reskin.c (D7g2) | WAIT | test_pdos_rdlg, test_pdos_reskin, test_input; ext_adapt d7g2-note-*, d7g2-gov-*, d7g2-sale-*; ext_p0 --g1 runs for rows 115, 126..128 | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 126 | ProcessCityDisaster 1040068E | R | D7g2 | pdos_rdlg.c, pdos_reskin.c (D7g2) | WAIT | test_pdos_rdlg, test_pdos_reskin, test_input; ext_adapt d7g2-note-*, d7g2-gov-*, d7g2-sale-*; ext_p0 --g1 runs for rows 115, 126..128 | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 127 | StartCivilWar 11A00000 | R | D7g2 | pdos_rdlg.c, pdos_reskin.c (D7g2) | WAIT | test_pdos_rdlg, test_pdos_reskin, test_input; ext_adapt d7g2-note-*, d7g2-gov-*, d7g2-sale-*; ext_p0 --g1 runs for rows 115, 126..128 | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 128 | DiplomatEntersCity 11B80000 TransferCityByRevo | R | D7g2 | pdos_rdlg.c, pdos_reskin.c (D7g2) | MENU | test_pdos_rdlg, test_pdos_reskin, test_input; ext_adapt d7g2-note-*, d7g2-gov-*, d7g2-sale-*; ext_p0 --g1 runs for rows 115, 126..128 | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 137 | population message ShowTextDialog 122000D2 (ca | R | D7g2 | pdos_rdlg.c, pdos_reskin.c (D7g2) | WAIT | test_pdos_rdlg, test_pdos_reskin, test_input; ext_adapt d7g2-note-*, d7g2-gov-*, d7g2-sale-*; ext_p0 --g1 runs for rows 115, 126..128 | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 11 | 130 Civilopedia page and list | N | D7h | pdos_scn_pedia.c | PEDIA | test_pdos_pedia; ext_adapt d7h-pedia | 28 runs, ready in 28 (e.g. V1/research) | 0 | ready |
| 79 | 601 Civilopedia > Complete | N | D7h | pdos_scn_pedia.c | PEDIA | test_pdos_pedia; ext_adapt d7h-pedia | 6 runs, ready in 6 (e.g. V1/menus) | 0 | ready |
| 80 | 602 Civilopedia > Civilization Advances | N | D7h | pdos_scn_pedia.c | PEDIA | test_pdos_pedia; ext_adapt d7h-pedia | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 81 | 603 Civilopedia > City Improvements | N | D7h | pdos_scn_pedia.c | PEDIA | test_pdos_pedia; ext_adapt d7h-pedia | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 82 | 604 Civilopedia > Military Units | N | D7h | pdos_scn_pedia.c | PEDIA | test_pdos_pedia; ext_adapt d7h-pedia | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 83 | 605 Civilopedia > Terrain Types | N | D7h | pdos_scn_pedia.c | PEDIA | test_pdos_pedia; ext_adapt d7h-pedia | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 84 | 606 Civilopedia > Miscellaneous | N | D7h | pdos_scn_pedia.c | PEDIA | test_pdos_pedia; ext_adapt d7h-pedia | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 99 | Civilopedia | N | D7h | pdos_scn_pedia.c | PEDIA | test_pdos_pedia; ext_adapt d7h-pedia | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 101 | Newspaper | N | D7i | pdos_scn_news.c | WAIT | test_pdos_news; ext_adapt d7i-disc, d7i-disc-early, d7i-news, d7i-cab, d7i-quiz; ext_timeline discovery | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 119 | AnnounceGovernmentChange 10E832C1  ShowNewspap | N | D7i | pdos_scn_news.c | WAIT | test_pdos_news; ext_adapt d7i-disc, d7i-disc-early, d7i-news, d7i-cab, d7i-quiz; ext_timeline discovery | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 23 | 146 discovery | N | D7i | pdos_scn_news.c | WAIT | test_pdos_news; ext_adapt d7i-disc, d7i-disc-early, d7i-news, d7i-cab, d7i-quiz; ext_timeline discovery | 22 runs, ready in 22 (e.g. V1/research) | 0 | ready |
| 24 | 147 discovery (advance 0x36 known) | N | D7i | pdos_scn_news.c | WAIT | test_pdos_news; ext_adapt d7i-disc, d7i-disc-early, d7i-news, d7i-cab, d7i-quiz; ext_timeline discovery | 4 runs, ready in 4 (e.g. V1/research2) | 0 | ready |
| 26 | 149 quiz | N | D7i | pdos_scn_news.c | MENU | test_pdos_news; ext_adapt d7i-disc, d7i-disc-early, d7i-news, d7i-cab, d7i-quiz; ext_timeline discovery | 8 runs, ready in 8 (e.g. V1/quiz) | 0 | ready |
| 104 | Palace view | N | D7j | pdos_scn_palace.c | PALACE | test_pdos_palace; ext_adapt d7j-palace; ext_timeline palace, palace_view | 14 runs, ready in 14 (e.g. V1/city) | 0 | ready |
| 124 | RunPalaceImprovement 11580000 | N | D7j | pdos_scn_palace.c | PALACE | test_pdos_palace; ext_adapt d7j-palace; ext_timeline palace, palace_view | 12 runs, ready in 12 (e.g. V1/conquest) | 0 | ready |
| 19 | 142 leader audience | N | D7k | pdos_scn_leader.c | MENU | test_pdos_leader; ext_adapt d7k-leader | 38 runs, ready in 38 (e.g. V1/arrival) | 0 | ready |
| 100 | Diplomacy screens (D7k: HoldDiplomaticAudience's whole span) | N | D7k | pdos_scn_leader.c | MENU | test_pdos_leader; ext_adapt d7k-leader | 44 runs, ready in 0 | 0 | spans its function (its screens' rows ready) |
| 78 | 506 World > Spaceships | N | D7l | pdos_scn_space.c | SPACE | test_pdos_space; ext_adapt d7l-space; ext_timeline space | 7 runs, ready in 0 | 0 | spans its function (its screens' rows ready) |
| 102 | Spaceship screens | N | D7l | pdos_scn_space.c | SPACE | test_pdos_space; ext_adapt d7l-space; ext_timeline space | 9 runs, ready in 9 (e.g. V1/p49-c2) | 0 | ready |
| 130 | ShowSpaceshipArrival 11D80000 | N | D7l2 | pdos_scn_arrive.c, pdos_scn_space.c | WAIT | test_pdos_arrive, test_pdos_space; ext_p0 arrival | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 106 | End-game sequences | N | D7m | pdos_scn_end.c, pdos_scn_report.c, pdos_scn_fame.c | WAIT | test_pdos_end; ext_adapt d7m-end | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 42 | 114 Retire | R | D7m | pdos_scn_end.c, pdos_scn_report.c, pdos_scn_fame.c | MENU | test_pdos_end; ext_adapt d7m-end | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 122 | ShowPowerGraph 118807AD | N | D7m | pdos_scn_end.c, pdos_scn_report.c, pdos_scn_fame.c | WAIT | test_pdos_end; ext_adapt d7m-end | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 103 | Replay | N | D7m | pdos_scn_end.c, pdos_scn_report.c, pdos_scn_fame.c | MENU | test_pdos_end; ext_adapt d7m-end | 10 runs, ready in 0 | 0 | spans its function (its screens' rows ready) |
| 120 | ShowCivilizationRatingRanking 108006FF | N | D7m | pdos_scn_end.c, pdos_scn_report.c, pdos_scn_fame.c | WAIT | test_pdos_end; ext_adapt d7m-end | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 129 | InsertHallOfFameEntry 10800595 | N | D7m | pdos_scn_end.c, pdos_scn_report.c, pdos_scn_fame.c | WAIT | test_pdos_end; ext_adapt d7m-end | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 114 | ShowConquerorEnding 1180152F ShowConqueredCivL | N | D7n | pdos_scn_end.c, pdos_scn_report.c; pdos_aplay.c (110) | WAIT | test_pdos_end, test_pdos_play; ext_adapt d7n-conq, d7n-nuke; ext_timeline conquest | never innermost in a shown state of these runs (an inner row such as 25 or 98 on top, or not reached) | 0 | covered by its unit tests and pairs; never innermost here |
| 110 | AnimateNuclearExplosion 11B80C3D | A | D7n | pdos_scn_end.c, pdos_scn_report.c; pdos_aplay.c (110) | NONE | test_pdos_end, test_pdos_play; ext_adapt d7n-conq, d7n-nuke; ext_timeline conquest | 2 runs, ready in 0 | 0 | reached (class A: the A canvas) |
| 10 | 129 About | W | D7o (recorded) | none | PASS | - | seen | - | W: W1 (About) |
| 28 | 666 16-colour conversion | W | D7o (recorded) | none | PASS | - | seen | - | W: W2 (16-colour conversion) |
| 94 | 801 Help > Game Help | W | D7o (recorded) | none | PASS | - | seen | - | W: W4 (Game Help) |
| 95 | 803 Help > About | W | D7o (recorded) | none | PASS | - | - | - | W: W1 (About command) |
| 108 | Sound | W | D7o (recorded) | none | UNSET | - | - | - | W: W5 (sound) |
| 125 | ShowSaveFileDialog 109826D4 (replay file call  | W | D7o (recorded) | none | PASS | - | seen | - | W: W3 (file choosers; Load and Save Game superseded by extension SL in the DOS graphics) |
| 131 | ShowCivilizationDestroyed 11D8087F (call site  | W | D7o (recorded) | none | PASS | - | - | - | W: W9 (ShowCivilizationDestroyed) |
| 141 | system MessageBox (FIDELITY F79) ShowErrorMess | W | D7o (recorded) | none | PASS | - | - | - | W: W6 (system MessageBox) |

## The counterpart ledger

Closures: **implemented** (the unit whose renderer draws the counterpart; for the shared tables the module), **not drawn /
not used** (the row's own reason, precedent T21, F11, E2), **W** (section 4), **pending** (a unit not landed when this
draft was made: D7h, D7i; filled at their landing).  The classes are the rows' own.

### 2.1 Pictures (38 rows)

| Row | Class | Closure |
|---|---|---|
| P1 | N | implemented: the DOS intro (D4b2b1, D4b2b2; pdos_intro.c, pdos_seq.c) |
| P2 | N | implemented: DOS Birth (D4b3; pdos_birth.c) |
| P3 | N | implemented: the logo and the title (D4b2b2, D4c1; pdos_intro.c) |
| P4 | – | not drawn: `MAP.PIC` is the DOS EARTH map, never drawn (the row's reason; EARTH's world comes from the core) |
| P5 | N | implemented: Customize World (D5e; pdos_scn_custom.c) |
| P6 | N | implemented: the setup pages (D5c, D5d; pdos_scn_setup.c) |
| P7 | N | D7i: DISCOVR1/2.PIC with its own palette at once (R:0ADE:1764), then the 30-step fade from it to the recipe (pdos_scn_news.c pdos_news_disc_page; test_pdos_news; ext_adapt d7i-disc; ext_timeline discovery) |
| P8 | A | implemented: the nuclear explosion's A element, DOS art only there (D7n; pdos_aplay.c) |
| P9 | A, N | implemented: the play map's shapes (D6a..D6e; pmap_dos) and the N scenes' shapes (D7a..D7n) |
| P10 | R | implemented: the text-box header slices (D5b, D6f, D7g; pdos_reskin.c) |
| P11 | N, R | implemented: the leader screens' attendants (D7k) and the advisor portraits (T1: D7a, D7b, D7g) |
| P12 | N | implemented: the leaders (D7k) and the conquered leaders (D7n) |
| P13 | N | D7h: the Civilopedia page's picture of the kind, the first cell of the ICONPG sheet equal to the item, centred by O8:16F7 (pdos_scn_pedia.c; test_pdos_pedia; ext_adapt d7h-pedia) |
| P14 | N | D7h: the Civilopedia's ICONPG pictures (pdos_scn_pedia.c); D7i: the discoveries' and the quiz's cells of ICONPG<1 + c / 9> (pdos_news_cell) |
| P15 | N | D7h: the Civilopedia's terrain picture (ICONPG_TERRAIN; pdos_scn_pedia.c) |
| P16 | N | implemented: the city view's hill (D7e; pdos_scn_cityview.c) |
| P17 | N | implemented: the city view's wonders (D7e) |
| P18 | N | implemented: the city view's buildings (D7e) |
| P19 | N | implemented: the city view's houses (D7e) |
| P20 | N | implemented: the city view's roads (D7e) |
| P21 | N | implemented: the city view's citizens (D7e) |
| P22 | N | implemented: the celebration (D7e) |
| P23 | N | implemented: the disorder (D7e) |
| P24 | N | implemented: the capture (D7e) |
| P25 | N | implemented: the founding scene (D7e) |
| P26 | N | implemented: the palace's background and the sad palace (D7j; pdos_scn_palace.c) |
| P27 | N | not drawn: 4446 has no DOS counterpart identified (ruling 8, D7j's record) |
| P28 | N | implemented: the palace's backgrounds (D7j) |
| P29 | N | implemented: the palace's brushes (D7j) |
| P30 | N | implemented: the palace's castle pieces (D7j) |
| P31 | W | W1 (the About box) |
| P32 | N | implemented: the arrival's planet (D7l2; pdos_scn_arrive.c) |
| P33 | N | implemented: the arrival's ship (D7l2) |
| P34 | N | implemented: the arrival's frames (D7l2) |
| P35 | N | implemented: the spaceship screen's `DOCKER.PIC` and its part records (D7l; pdos_scn_space.c) |
| P36 | W | W9 (ShowCivilizationDestroyed) |
| P37 | N | implemented: the conqueror ending's strip (D7n; pdos_scn_end.c) |
| P38 | N | implemented: the Hall of Fame's DOS screen, colour 15 and text (D5f; pdos_scn_fame.c) |

### 2.2 Shapes cut from picture 200 (23 rows)

| Row | Class | Closure |
|---|---|---|
| S1, S2, S3, S4, S6, S8, S9, S14, S15, S16, S20, S22 | A | implemented: the play map, the small map and the status window (D6a, D6c, D6e; pmap_dos, pdos_aplay.c) |
| S5 | N | implemented: the city screen's pollution icon (D7d; pdos_scn_city.c) |
| S7 | A, N | implemented: A (D6c's map); N: the historian's and the replay's mini palace (D7c, D7m) |
| S10 | N | implemented: the city screen's D4CE icons (D7d) |
| S11 | N | implemented: the city screen (D7d, decision 17: after reading OPEN L22) |
| S12 | N | implemented: the N city screen draws the DOS yields (D7d, decision 17's rule) |
| S13 | N, A | implemented: the city screen's citizens (D7d) and the play rows (D6e) |
| S17 | A, N | implemented: the play map's units (D6c) and the city screen's units (D7d) |
| S18 | N | implemented: the improvement icons of the city screen and the reports (D7d, D7a..D7c) |
| S19 | N | implemented: as S18 (D6b's inference; D7d) |
| S21 | A, N | implemented: D6b's whole-tile shapes (D6b, D6c) |
| S23 | N | implemented: the rating's border tiles (D7m) |

### 2.3 Shapes cut from other pictures (21 rows)

| Row | Class | Closure |
|---|---|---|
| T1 | N, R | implemented: the advisor portraits of the reports (D7a, D7b) and of the text-box headers (D7g) |
| T2, T3, T4 | N | implemented: the leader screen (D7k; pdos_scn_leader.c) |
| T5 | N | implemented: the attendants' frames (D7k, decision 9) |
| T6 | N | implemented: the conquered leader (D7n) |
| T7 | N | implemented: the palace's pieces (D7j) |
| T8, T9, T10, T11, T12 | N | implemented: the city view (D7e) |
| T13, T14, T15 | N | implemented: the capture, the disorder and celebration, the founding (D7e) |
| T16 | A | implemented: the nuclear explosion (D7n) |
| T17 | N | implemented: the arrival's frames (D7l2; decision 7's open item closed) |
| T18 | N | implemented: the spaceship parts (D7l) |
| T19 | N | D7h: an improvement's 49 x 49 cell of CITYPIX2.PIC, copied, no zoom (pdos_scn_pedia.c; test_pdos_pedia) |
| T20 | N | D7i: O8:16C4's first match in ICONPG_ADVANCE, its cell of ICONPG<1 + c / 9> through O8:16F7, centred at (58, Y0 + 64) (pdos_news_cell; ext_adapt d7i-quiz) |
| T21 | – | not drawn (the row's reason: g_scratchShape32 has none) |

### 2.4 Fonts (18 rows)

| Row | Class | Closure |
|---|---|---|
| F1, F2 | N, R | implemented: the font map (D4a; pdos_fontmap.c) for the N scenes and the R re-skins (D5b, D6f, D7f, D7g); D7o: id 0 at TextFont 1100:0A40 after a Civilopedia page -> DOS font 1 (inferred; row 79) |
| F3 | N | implemented for the intro's credits and Birth (D4b); D7i: the newspaper's masthead, tag, price and date at the core's draws (pdos_scn_news.c pdos_news_draw; ext_adapt d7i-news) |
| F4, F5, F6, F7 | N | implemented: the font map (D4a) in the N scenes that use them (D4..D7); D7h: the Civilopedia's category in font 7 and name in font 6 (pdos_scn_pedia.c) |
| F8 | A | implemented: the play rows' font by number (D4a, D6e) |
| F9, F10 | N | implemented: the leader font (D7k, decision 17: O6:251D, LEADER_FONT) |
| F11 | N | not drawn (the row's reason) |
| F12 | W | W1 (the About box's family 216) |
| F13, F14 | R | implemented: the DOS popup's font (D5b, D6f) |
| F15 | N | implemented: the city screen's own text, the EXIT font (D7d, decision 17) |
| F16 | – | not used: CreateAndSelectRomanFont has no caller (dead) |
| F17 | – | implemented: DOS font 9 (no Windows id) in the leader screen (D7k, decision 17) |
| F18 | N | implemented: the report titles (D4a, D7a) |

### 2.5 Cursors (16 rows)

| Row | Class | Closure |
|---|---|---|
| C1, C8 | – | not used: cursors 128 and 135 have no setter (never shown) |
| C2 | N, R, A | implemented: the torch (D4a; pdos_cursor.c; its size since UX1, UX1b) |
| C3 | A | implemented: the torch for the small-map pointer (D4a, the row's proposal) |
| C4 | N | implemented: hidden in the intro and Birth (D4a) |
| C5 | N, R, A | implemented: hidden (D4a, Choice B5: OPEN P21's decision) |
| C6 | A | implemented: the GO arrow (D4a) |
| C7 | N | implemented: the torch (D4a; the row's "not shown" is the Windows cursor's) |
| C9..C16 | W | W8 (the map scroll cursors) |

### 2.6 Palette effects of the Windows game (24 rows)

| Row | Class | Closure |
|---|---|---|
| E1 | A | implemented: the map's palette cycling (D6c, D6d; T7: pdos_prov) |
| E2, E3, E7, E10 | N | not used (the rows' reasons: the DOS intro's own palette) |
| E4, E5, E6 | N | implemented: the DOS intro's and Birth's palette (D4b2b1, D4b2b2, D4b3) |
| E8 | – | not used: movie types 12 and 14 are never used |
| E9 | A | implemented: the sprite sheet's colours on the map (D6a, D6c) |
| E11 | N | D7h: the page palette of the kind (pdos_recipe_pedia with ICONPG1.PAL / ICONPGA.PAL / HILL.PAL, pdos_recipe_terrain_page with SP256.PAL, pdos_recipe_grey253; pdos_scn_pedia.c) |
| E12 | N | implemented: the arrival draws its own text, no caption colours (D7l2) |
| E13, E14, E24 | – | not used: dead code (no caller) |
| E15 | R, N | implemented: the advisor portraits' colours (D7a, D7b, D7k) |
| E16 | A | implemented: NUKE1's palette, then the return (D7n, decision 11) |
| E17, E23 | N | implemented: `SLAM1.PAL` with the leader's colours (D7n) |
| E18 | N | D7i: ICONPG1.PAL with entries 0..84 of DISCOVRn.PAL, the target of the 30-step fade (pdos_tl_fade, TX; ext_timeline discovery) |
| E19, E20 | N | implemented: the city view's palette and the animations' (D7e) |
| E21 | N | implemented: the leader screens' palette (D7k) |
| E22 | N | implemented: Customize World's palette after its fade (D5e) |

### 2.7 DOS-only palette effects kept as TX (7 rows)

| Effect | Closure |
|---|---|
| intro cycling slot 1 | implemented (D4b2b1; pdos_intro.c) |
| logo cycling slot 4 | implemented (D4b2b2) |
| Birth cycling per picture | implemented (D4b3) |
| spaceship cycling, five slots | implemented (D7l) |
| city view cycling slot 4 | implemented (D7e) |
| fades in play scenes | implemented: D7a (R:0238:1B66, 1C86 returns), D7c, D7e (O19:0EB9, O22:10FC), D7j (O17:0CB9), D7m, D7n (O9:1079, O9:124C); D7i: the discovery's fade (R:0ADE:198C, 30 steps; ext_timeline discovery) |
| start-up fades | implemented: Customize (D5e), after Birth (D4b3) |

Counts: 140 numbered rows and 7 effects; none pending after D7h's and D7i's landings; D7g2's and D7h2's landings
(checked at the rebases onto them) add no 2.x counterpart.

## Methods and results

* **compiled:** the overlay's Checked, CheckedNoObs and Release builds (D7o, `obj/ball.py`), then the final cycle's.
* **headless:** decision 13's full runs (`ext-D7o-record.md` "Decision 13"): ext_p0 Checked V0..V8s `--g1` P0_OK checks
  521 with decision 16's FEATURES_REACH_OK rows 108 dos 104 w 4 and decision 12's G-1 runs (11) in V0 and V1;
  CheckedNoObs V5 P0_OK checks 62; EXT_FRAMES_OK; EXT_TIMELINE_OK (every entry); EXT_ADAPT_OK checks 421 (every entry);
  ZOOM_OK; the counters per row 0 for every gate row (D4..D7).
* **Win32-headless:** the units' own (their records); the final cycle's test.cmd.
* **agent-observed:** decision 14's attempt (below).
* **DOS listing (model):** every unit's pixel and timing claims, as their records label them.
* **tables:** ADAPT_OK rows 166 steps 27; REGISTRY_OK; NODOS_OK; pdos_scene_check 1086 checks, 141 scene rows, 11 font
  rows; OFFSETS rows as the units added them (their records).

## Coverage

* **G-1-run V1 replays (decision 12):** p49-c2 (LaunchSpaceship), p49-find-capture, -civilwar, -diplomat, -mercenary,
  -riot, -sabotage, -space, -unrest, uninit-s4 and -s5 (the capture and disorder animations, ShowHistorianReport,
  SetGovernment, StartCivilWar, DiplomatEntersCity, TransferCityByRevolt, ProcessCityDisaster, HumanPlaceSpaceshipPart,
  ShowCivilizationDestroyed, WaitTicksOrInput).
* **Edited saves (ext_adapt):** D7n's ShowConqueredCivLeader and AnimateNuclearExplosion; D7g2's notes, government menu
  and sale question; D7m's end screens; D7l's spaceship.
* **Unit vectors only:** DrawCivDossier, DrawBeveledLabelBox, AnnounceGovernmentChange, PlayCelebrationAnimation and
  FrameRectDoubleDevice (never reached by any run; decision 12's list).
* **Never innermost in a shown state of the full runs** (reached through an inner row or by their pairs): the 40 rows
  so marked in the scene ledger.

## The agent check

One attempt by D7o, 16:45..16:47 UTC, completed (`ext-D7o-record.md` "Decision 14"): a private copy of the overlay's
Release civ64 (`--multi-instance`, private data and home) in the DOS graphics; shots of civ64's client only, under
`build/ext-d7-ui/`: 01-title (the DOS intro), 02-menu (the title box), 03-load (the SL chooser), 04-play, 05-city (the
DOS city screen after the load: SP299's texture and the icons, d7d2), 06-change (the DOS production list), 07-pedia and
08-after-pedia (the Civilopedia entry's pages A and B with the DOS border after a load, opened by Alt+H on the list:
d7d2, d7h3), 09-back-list, 10-play2, 11-status (F1's City Status in the O14 frame); log.txt.  No fault.  An agent
observation is not user acceptance: D7o's user checks are in its user build.

## Deviations

* D7a 1: `ext_timeline.py` and `ext_p0.py` unchanged; the return fade is covered by test_pdos_report's fade vectors,
  test_pdos_profile's `test_return_fade` and ext_adapt's d7a pair.
* D7a 2: ShowTopFiveCities's title row added with F1's enumeration (font 1, inferred), although D7c renders Top 5.
* D7a 3: City Status's production column pen text drawn in colour 15 (DOS's one string), not the core's grey 7.
* D7a 4: Monochrome mode (the opener's background 0) not distinguished; the page takes the background the opener
  passes.
* D7a 5: `PDOS_OWNER_MAX` 5 -> 6 (`pdos_shadow.h`): the renderer is the fifth owner; test_pdos_profile's synthetic
  owner needs one more.
* D7a 6: `present/dos/pdos_scene_tab.c` unchanged: rows 25, 67 and 98 exist; D7a only sets their readiness.
* D7a 7: The advisor portraits load at every report opener, not only the advisors' (state read at use; D7b draws
  them).
* D7a 8: The DOS-form run opens City Status with Ctrl+1 (the core's accelerator; D6f's F1 maps to it); the d7a pair
  keeps Ctrl+1.
* D7b 1: The shadow engine gains the negative claim (`pdos_shadow.c/.h`) for a report's DrawTile bitmaps (rows 68,
  70..72); `test_pdos_shadow.c` covers it.
* D7b 2: `pdos_prov.c` and `pdos_scene_tab.c` unchanged: S10, S13, S17..S19 resolve since D6b; rows 68..72 exist, the
  renderer sets readiness.
* D7b 3: `pdos_replay.c/.h` gain the place hook (ruling 4 by call site), called at the exit draw only; unregistered,
  nothing changes.
* D7b 4: `ext_timeline.py` and `ext_p0.py` unchanged: no recorded flow opens a dossier; test_pdos_report checks exit
  kind 1B44 after one.
* D7b 5: Intelligence's close takes two inputs: DOS O14:0D43 ends at the first; the core's CloseReportScreen waits
  again (C.12.7).
* D7b 6: Military's two pages follow at once; DOS restores the map (O14:060C) between them, the core draws
  DrawCasualtyReport in place.
* D7b 7: The Intelligence report and dossier use DOS's background 1 where the core passes 0 (row 69, O14:0D4B,
  O14:116B).
* D7c 1: `pdos_prov.c`, `pdos_scene_tab.c`, `pdos_adapt_tab.c` unchanged: S7/S13/S18/S19 resolve, rows 73..77 and 123
  exist; 0x10000000 stays free.
* D7c 2: `pdos_adapt.c` and `pdos_profile.c`: `pdos_report_shown()` becomes `pdos_report_active()` so a quiet Wonders
  report keeps I-report.
* D7c 3: Wonders with no wonder built is quiet (DOS O12:080D draws nothing): the A frame stays, the core's drawing
  dropped (choice).
* D7c 4: The Score shows as the core draws it, not composed on page 1 (G#20); row spacing follows g_scoreRowSpacing,
  not DGROUP:5116.
* D7c 5: The historian's rows at the core's pace (TC), not DOS's 60 frames per row (O12:0CA1).
* D7c 6: Top 5's row name drawn at the row's ProcessCity (1080:0BE8) after DrawCenteredScreenText (1080:0BDD); the
  screen is the same.
* D7c 7: World Map pairings inferred (g_revealAll for D806, core terrain order); a city bit without a city unmarked;
  mode B278 unused (OPEN L2).
* D7d 1: A DOS-layout renderer replaces the logical replay: the core's city screen draws via DrawTileToPortPixels
  11A8:15CE (raw bits, no probe).
* D7d 2: The CHANGE blink's grid runs from the render that found the condition; DOS restarts at each redisplay (up to
  10 frames apart).
* D7d 3: DOS's redisplay-only presses (square outside radius or unseen, map cursor Escape) give the core '#'
  (1030:5F88), changing no state.
* D7d 4: A sale while the core's list is scrolled is refused (counted `refused`); DOS's list has no scroll.
* D7d 5: The DOS cursors are the renderer's presentation state; Return or Space gives the core the click of the unit,
  row or square.
* D7d 6: R:0D12:6ED4's [bp-2] is never written by the routine; taken as non-zero at every call (inferred).
* D7d 7: Keys reach the core as character messages (WM_CHAR, no key down); the DOS key H shows HAPPY, the accelerator
  does not take it.
* D7d 8: Escape, Return, e and q passed as typed where both screens leave; every other leaving key becomes Escape.
* D7d 9: Boxes and scenes over the city screen (lists 140, rename 137, Buy/sale, city view) show the A frame until
  D7e..D7g.
* D7d 10: `tests/dos-decoded.txt`: the registry's goldens gain the seven tables' lines that test_dos compares.
* D7e 1: The city view draws the core's grid with DOS's cells; DOS's generator O19:0000 (reseeding the shared C
  stream) not run (P0, Open 21).
* D7e 2: Animations at the core's pace (TC): figures move in the core's 142, 94, 98 frames where DOS takes 220, 156,
  156.
* D7e 3: The founding's fade ends at once (black) when the core leaves without a view; DOS completes its 60 frames.
* D7e 4: A new wonder/improvement's 60 frames and dissolve run during the core's key wait; a key ends the view at
  once.
* D7e 5: The view after a founding is drawn once the founding's fade has ended (DOS's order); the core draws it at
  once.
* D7e 6: An A-frame show at a scene change's instant precedes the city screen's first show; rows 88, 25 pop before the
  animation's entry.
* D7e 7: The return to the city screen takes the play palette at once (inferred; DOS's R:0238:1BEB fades it in over
  black).
* D7e 8: G#32's cells clipped to the page; out-of-grid road-mask neighbours taken as -1; DOS slots cut from their
  picture when drawn.
* D7e 9: Test is `tests/test_pdos_cityview.c`; ext_timeline unchanged; pdos_fx, pdos_prov, pdos_pal, pdos_scene_tab,
  pdos_adapt_tab unchanged.
* D7e 10: `PDOS_OWNER_MAX` 9 -> 10 (orchestrator, 2026-10-17 16:25 UTC) for the ninth profile owner `cityview`.
* D7f 1: The five dialogs live in a new `pdos_rdlg.c/.h` and `tests/test_pdos_rdlg.c`; pdos_reskin.c gains only the
  help flag and hand-over hooks.
* D7f 2: P19 stands: the production advisor boxes are not drawn (the core's counterpart is ShowInstantAdvice); a
  ruling changes `prod_build` only.
* D7f 3: No header icon (R:0ADE:0421 never sets DGROUP:2F9E) and no selection flash (G#3 for 20 frames; TX not built).
* D7f 4: P26 refined: with several units DOS's popup stays (R:0866:21C6..2259); a row click wakes the core's row,
  Return (OK) ends it.
* D7f 5: Find City is a window over the core's list (P16): (64, 8) on N, the Windows dialog's place on A; rows scroll,
  no "more..." row.
* D7f 6: Production list rows keep the core's strings (decision 15); DOS's >29-entry second-page quirk (R:0ADE:0931)
  not reproduced.
* D7f 7: The `rdlg` diag line added in `tests/headless/harness.c` (presentation-diag.log, after the space line).
* D7g 1: A places are D6fSd's; D7g adds the header offset (42 left, 8 above; R:1D05:0667..0699); the first stage's
  menu-bar origin rule is gone.
* D7g 2: The research choice appears milliseconds after the recommendation (the core's box takes the posted Return);
  not visible.
* D7g 3: The posted Return while the user's Return is still down carries the previous-state bit; the core takes it the
  same.
* D7g 4: Advance names are DOS's where the core's name equals or ends with DOS's after a space; recommendation
  units/improvements are the core's.
* D7g 5: Unpaired texts keep D6fSc's line rule on the core's text in the same font and place; header and help line
  still drawn.
* D7g2 1: The notes stand at the centre of dialog 135's Windows window (user's direction of 10:57), not at DOS's (56,
  16).
* D7g2 2: A note whose DOS section is missing shows the core's text folded in the same box (counted without
  `note_paired`); not met.
* D7g2 3: Row 126's map recentre: the core recentres (CenterMapViewOn 1110:03AE); equality with DOS's x - 10, y - 6
  unknown; nothing added.
* D7g2 4: The sale question's building name and price are the core's (same words and numbers as DOS's: cost times 10).
* D7g2 5: The recommendation keeps D6fSd's DOS place on A (27, 344) so it stays seen beside the centred research
  choice; user rules by D7g2-9.
* D7g2 6: The N canvases keep DOS's places (orchestrator's reading, 10:58): the city screen's, throne room's and
  palace's boxes.
* D7h 1: Rows 79..84 are class N, not R: O8:0000 is a full DOS screen drawn on N; class counts change (DOS-PROFILE
  1.8, test_pdos_scene.c).
* D7h 2: New PDOS_AS_PEDIA (bit 32; scene fields widened to 64 bits, test_input.c with them) and PDOS_DEC_PEDIA;
  READY/INTRO/WAIT reused.
* D7h 3: DOS's mouse mode only (ruling H2): any key is EXIT, a press names its entry; no keyboard G#3 cursor
  (O8:049A..04F2).
* D7h 4: Files beyond the brief (pdos_rdlg, pdos_scn_palace, pdos_replay, pdos_seq, pdos_profile, harness, tests,
  registry); pdos_reskin.c, pdos_prov.c unchanged.
* D7h 5: Option without "*NAME": the core waits twice (page A, B), DOS once; the first key ends the core's page A wait
  (counted `skip_a`).
* D7h 6: After ShowCivilopediaEntry the N page and DAC are restored from the entry snapshot; over an A screen the
  return is R:0238:1B44's fade.
* D7h 7: Picture cells of -1 (SPRITES 8): the page has no picture (counted `cell_none`), as DOS's O8:16C4/1790/17C3
  callers skip it.
* D7h 8: Side fix: `tests/test_input.c`'s `g_tp` lacked the `square_only` initializer (cc.cmd's clang C99 parse); NULL
  added, CC_OK.
* D7h 9: The page's Return, and Space while OK 101 has focus, are passed (PDOS_RDV_PASS, `focus_ok`); other keys and
  buttons produce Return.
* D7h 10: D7g's test expectation adapted (`ext_adapt.py` D7G_ROWS): the advance page's waits decided by
  I-pedia/page-key; Windows forms unchanged.
* D7h2 1: The A-canvas cover is the page at 2x centred with colour index 0 round it; never seen in the runs, it hides
  the research box.
* D7h2 2: An A-frame show at an entry's opening instant before the page draws (seen, not changed); for the
  orchestrator if a flicker is reported.
* D7h2 3: A unit's entry page without pictures keeps the unit's small figure (O8:0A8F..0AA4); only the big picture is
  omitted (D7h2-1).
* D7i 1: Texts are the core's (ruling 6), folded, advances in DOS spelling; DOS's own words (ornaments, discovery
  sentence, KING.TXT) kept.
* D7i 2: No R:0238:1B44 before New Cabinet: the core goes on at once, so the cabinet shows at once in the play
  palette.
* D7i 3: A key or click during the discovery's 180-frame fade ends the discovery at once (DOS reads it at R:0ADE:1994
  after the fade).
* D7i 4: The discovery's research choice follows over the play screen (D7g's A box) without R:0238:1B44 after it (the
  core's order).
* D7i 5: The quiz's question and answers are the core's (its choice of advances and answers); "Pages" is the core's
  text at DOS's place.
* D7i 6: DISCOVR2's text font inferred as font 1 (R:0ADE:1861..1869 sets font 6 for DISCOVR1 only; DOS keeps the font
  in effect).
* D7i 7: The slogan is paired by name (D6fSd): the KING.TXT section of the core's slogan name, else the core's text.
* D7i 8: The masthead's " News" width fallback (O21's second form) is not applied; the core's choice of name form is
  kept.
* D7i 9: Between the quiz's two questions (wrong first answer, O16:04AC) the A frame may show for one present.
* D7i 10: The A newspaper's wait is the A view's I-pass (WaitForKeyOrClick 1038:0C2A), not a frame-1 I-wait; row 101's
  I-wait holds over N.
* D7i 11: No new PDOS_AS bit, owner, adapter or scene-table row; pdos_scene_tab.c, pdos_adapt_tab.c, pdos_fx.c,
  pdos_tl.c unchanged.
* D7j 1: Row 104's exit is GR_DialogClose's entry (`pdos_scene_tab.c`), not OpenPalaceView's return: DOS shows the
  palace through the last wait.
* D7j 2: Class W for I-palace/press; `adapters.py`'s passed frame-1 press rule extended by W_SCENES beside P_SCENES;
  test_input.c likewise.
* D7j 3: The sad palace's fade O17:0CB9 is the arrival's (D7l), not run; D7j provides sad = 1 and
  `pdos_palace_sad_fades` / `_finish`.
* D7j 4: `pdos_fx.c` unchanged: the reveal uses `pdos_tl_dissolve` on the palace's timeline, the return D7a's exit
  kind 1B44.
* D7j 5: The KING box anchored at DOS's (20, 16) (not in the brief), found in E4's first look at the core's (0, 0).
* D7j 6: The palace port claimed at the device resolution and followed when replaced (not in the brief).
* D7j 7: `PDOS_OWNER_MAX` 8, the stacked tracks' combined value (report 6, city 7, palace 8); test_pdos_shadow follows
  it unchanged.
* D7k 1: The idle animation follows the core (TC), which draws none in the runs (pending WM_PAINT starves MenuZ's
  WM_TIMER); still leader.
* D7k 2: The text strip is a frameless box element removed at the MenuZ's return, not a page copy of rows 128..199;
  same pixels.
* D7k 3: The message boxes keep font 1 (DOS's port font would be the leader font); none seen in an audience.
* D7k 4: The text-only path (O6:1D49..1E29, DOS without the picture disk) is not drawn.
* D7k 5: The portrait is DOS's (`LEADER_PORTRAIT[tribe]`); another core KING picture is counted `portrait_differs` (0
  in the runs).
* D7k 6: No new owner and no new PDOS_AS bit: the owner "palace" delegates; I-menu decides.
* D7l 1: The arrival (row 130) is not implemented (ruling 7): the animation was not established; its open items go to
  D7's gate.
* D7l 2: The launch's black screen O18:15C3 is not drawn; the core's LaunchSpaceship 1070:2015 text box shows,
  re-skinned as R.
* D7l 3: Input translated into clicks (I-space): keys and buttons click the spaceship window; a timed showing is not
  cut short by a key.
* D7l 4: No new action bit: launch actions behind PDOS_AA_HOTKEY (PDOS_AA_LAUNCH clashed with PDOS_AA_DEAD); new
  PdosAdaptSc `l_hwnd`.
* D7l 5: `pdos_fx.c` and `pdos_scene_tab.c` unchanged although listed.
* D7l 6: The stars move at the core's pace: before the launch they stand still where DOS moves them every frame (TC);
  for D7's gate.
* D7l2 1: The pace is the core's (TC): pan 153 steps of 12 ticks (30.6 s, DOS 36.53 s), chunks one per core caption
  (3.33 s, DOS 2.28 s).
* D7l2 2: A key or click ends the rest's chunks early (the core's second loop); DOS's chunk loop O2:137E..1469 has no
  key test.
* D7l2 3: The first pan chunk is not drawn (DOS's own effect of O2:0ECA, inferred visible): kept.
* D7l2 4: The right button is consumed (I-wait/right, C.12.7); DOS's key wait R:1459:0918 ends at any button.
* D7l2 5: DOS's star motion is presentation-side with `pdos_rand` where the core's stars stand; the core's next star
  frame replaces them.
* D7l2 6: The arrival's port bitmaps are declined (no shadow): the core's picture, caption strip and palace port have
  no DOS counterpart.
* D7l2 7: No new PDOS_AS bit and no new owner: I-wait and the owner "space" cover the arrival.
* D7m 1: The replay map is drawn with fills R:0000:0BFA (1 ocean, 8 land) as O9:0113..0191 does, not with D7c's 4x4
  tiles.
* D7m 2: DOS has no wait after a replay (O9:083D -> 0877); the core's WaitForKeyOrClick 1180:0162 is kept (P0).
* D7m 3: Complete Replay's pace is the core's (DelayTimerTicks(5) per event, any key ends it); DOS waits for a key per
  event.
* D7m 4: The replay question is asked again after every mode (RunReplayMenu's loop, P0); DOS asks again only after
  modes 1 and 2.
* D7m 5: Mode 3: the core asks for the file name first (row 125); the view opens at PlayReplay's entry; DOS's CR LF
  not drawn on the bar.
* D7m 6: The graph's scale reads at most 256 samples (`PDOS_GRAPH_SAMPLES`) through w16q_read, covering turn 1023.
* D7m 7: No new scene bit, adapter or scene-table row (report state reused); pdos_scene_tab, pdos_adapt_tab,
  pdos_prov, pdos_scn_fame unchanged.
* D7m 8: The fade fix changes D7a's `begin` (not in the brief): one condition, recorded.
* D7n 1: The waits are the core's (TC): O9:0F79's 240-frame wait and wait(3Ch) replaced by the core's copies; fades
  and dissolve DOS's (TX).
* D7n 2: The lines are the core's texts (the same words as DOS's DGROUP strings, folded), the final panel's too.
* D7n 3: Row 114's I-wait is served by the report state (PDOS_AS_REPORT, I-report/key to WaitForKeyOrClick 1180:17B0);
  no adapter row.
* D7n 4: The explosion follows the core (decision 11): 139 (or 63) frames of 5 ticks at the core's square, no DOS
  clamp or restore.
* D7n 5: NUKE1's palette applied at the first frame shown, not at the core's palette call (11B8:0C8B) before its
  0AAh-tick wait.
* D7n 6: Row 110's drop macros are DOS_ONLY, so ext_mirror's WIN mirror still counts the core's DrawTile as
  unexplained (Open D5).
* D7n 7: OPEN P27: SLAM2's 197-pixel rows drawn `width` wide (D1's settlement); never visible here.
* D7n 8: No new PDOS_AS bit, owner, adapter or scene-table row; `pdos_fx.c`, `pdos_prov.c`, `pdos_scene_tab.c`
  unchanged.
* D7n 9: The conquest runs' `pdos_rows` r101 2 (the newspaper, row 101) is D7m's too, not D7n's.
* D7o 1: the full runs ran on the private overlay (the staged tree, its own builds) before the landing.
* D7o 2: the cause class "scripted w16 input" lists sc_city's five w_over_n counts apart instead of counting them.
* D7o 3: a D7i follow-up (rows 23, 24, 26) and three tooling fixes found by the full runs carried in D7o's landing.

## For the records

* DESIGN 12.7 / 12.8 (As implemented (D7))
  * Report renderer and table (rows 67, 98, 25; row 97 held during ProcessCity(city, -1)); shadow owner "report";
    production pen text. (D7a)
  * Return exit kinds in `pdos_fx` (trigger, 30-frame fade-in, map slots held, abandonment C.9); page-2 portraits, T1;
    I-report; `report` diag line. (D7a)
  * Advisors' rows; the replay's place hook and site table (ruling 4 by call site); portraits (T1); Attitude citizens
    at R:0D12:6ED4's places. (D7b)
  * INFO buttons as R:0D12:71BF; Intelligence's INFO wait (class P), nested dossier, exit kind 1B44; shadow engine's
    negative claim; new counters. (D7b)
  * World reports and historian with DOS backgrounds; second site table; World Map from core state (`pdos_scn_world`);
    mini palace R:0238:14A3. (D7c)
  * The quiet Wonders report and `pdos_report_active`; new `report` counters. (D7c)
  * DOS city renderer `pdos_scn_city` (ruling 4's alternative); owner `city`; rows 97, 25 dynamic readiness; exit
    kinds from [6B64]; I-city; `city` line. (D7d)
  * City-view renderer `pdos_scn_cityview` (O19:0000 from the core's grid; founding O22:0EAF; animations O19:167B,
    18C1, 1AE1); rows 88, 109, 111..113, 25. (D7e)
  * Owner `cityview`; TX effects; exit kinds (1BEB, play palette, 1B44); I-wait PDOS_AS_WAIT; WONDER_RECTS, DIR_DX/DY,
    CITY_ANIM_DX/DY; owners 9 of 10. (D7e)
  * Module `pdos_rdlg.c/.h` (five dialog kinds, N over the city screen, A at 2x); help line; `pdos_reskin_a_place`;
    PDOS_AS_RLIST 0x10000000, PDOS_DEC_RLIST. (D7f)
  * Acts PDOS_A_LBPICK, LBHELP, STACKROW; predicates PDOS_PR_LB_SEL/DONE; hooks rd_decide..rd_point; header lines
    (`pdos_r_spec_dos_lines`); `rdlg` line. (D7f)
  * Header variant (`PdosMenuBox.header`); science advisor pairing (1170:29EC, 1170:286F); `a_place_box`;
    recommendation's DOS flow, `PDOS_AC_ADVICE`; Escape FIRST. (D7g)
  * Centring on A (`PdosRPlace.centre`, `pdos_r_place_xy`, `DOS_KEEP`); notes `PDOS_RL_NOTE`, `PDOS_AS_NOTE` (bit 34);
    `PDOS_R_PAIR_SALE` (1030:6291); N rule in `menu_build`. (D7g2)
  * Module `pdos_scn_pedia.c/.h` (index, pages, waits, passed keys, claims via "palace"); decision 10; PDOS_AS_PEDIA
    0x100000000 (64 bits), PDOS_DEC_PEDIA. (D7h)
  * Multicolumn list pick (`PdosRdLb.colw`); D7h's registry tables; the `pedia` diag line and the replay's `pedia`
    count. (D7h)
  * Entry page covers `PDOS_PEDIA_COVER_N_ID` 0xFF58 / `_A_ID` 0xFF59 (private ids); `PDOS_R_HELD_ID` 0xFF50;
    distinct-id vector in test_pdos_pedia. (D7h2)
  * `pdos_scn_news` for rows 23, 24, 26, 101, 119: N views (101 as A elements with a cover), DOS drawing O21:0000,
    O5:1BA2, R:0ADE:1584, O16:002C. (D7i)
  * D7i's discovery fade on a TX timeline; window claimed through owner "report"; quiz answers via
    `pdos_reskin_rows_only`; waits I-wait; no new bit or row. (D7i)
  * Palace renderer (composer O17:07EC(sad), improvement steps, view); rows 124, 104 (exit at GR_DialogClose), 25;
    reveal G#10(1, 20) TX; return 1B44. (D7j)
  * KING box anchor; owner "palace" (port at device resolution, followed); T7 (row 107); I-palace (W, X); sad helpers
    for D7l; `palace` line; PDOS_OWNER_MAX 8. (D7j)
  * `pdos_scn_leader` (claims via "palace" from LoadLeaderScreen; TS show, TC idle, exit kind 1; `h8`, `at_place`);
    owners 9 of 10, 0x10000000 free. (D7k)
  * Spaceship renderer (O18:0259 over EvaluateAndShowSpaceship 1070:0327): rows 102, 78, 25 ready, 97 held; owner
    "space"; place hook chained. (D7l)
  * T18 (row 118); stars L(d) = floor((10 d + 9) / 16); LAUNCH label; five slots TX; exit 1B44; I-space; SPACE_PARTS,
    SPACE_LAUNCH; owners 8 of 9. (D7l)
  * `pdos_scn_arrive` (pure) and the arrival glue in `pdos_scn_space` (rows 130, 25, 104; TC pan/chunks, TX
    fades/slots; I-wait); stars via `pdos_rand`. (D7l2)
  * Rows 122 (O12:0573), 103 (O9:0000), 120 (O3:065D) in the report table, drawn by pure `pdos_scn_end.c` via
    w16q_read; graph by D7c's sites. (D7m)
  * Replay views N from GR_DialogOpen to destruction; rating border via `pdos_rand` "border"; Hall of Fame play
    palette (L26); `begin` completes a fade. (D7m)
  * Row 114 (ShowConquerorEnding 1180:152F; O9:0DDE, O9:0F79) as N view from dialog 148; each conquered leader on a TX
    timeline. (D7n)
  * Row 110 (AnimateNuclearExplosion 11B8:0C3D; O22:0967) in `pdos_aplay`: DOS_ONLY drop macros, NUKE1.PIC A element
    at 2x, R:0238:1BEB exit. (D7n)
  * DESIGN 12.8's replay paragraph may name the unreplayed discovery and quiz TextBoxDraw frames with D7h's and D7k's
    owners. (D7o)
* FIDELITY
  * The return's fade-out of R:0238:1B44 is not shown; the fade-in starts from black (decision 3, ruling 3). (D7a)
  * City Status's production column in colour 15 at the DOS name width; improvement truncated by R:1F4D:04F7's rule.
    (D7a)
  * The report title's font: id 7 -> DOS font 1 at the report-title sites, inferred (OB4 open). (D7a)
  * A click anywhere closes an O14 report (class X); the right button is consumed where DOS's any button ends the
    wait. (D7a)
  * Monochrome mode's background not distinguished; advisor portraits loaded at every report opener. (D7a)
  * Intelligence's close takes a second key or click (the core's CloseReportScreen; DOS O14:0D43 ends at the first).
    (D7b)
  * Military's second page follows the first without the map's moment (O14:060C's O14:013B). (D7b)
  * Intelligence report and dossier in DOS's background 1 where the core passes 0. (D7b)
  * Advisor portraits at (278, 2) without the Windows sunken panel; Science's list and other report rows paged as the
    core pages them. (D7b)
  * Wonders with no wonder built draws nothing over the play screen. (D7c)
  * The Score shows as drawn, not composed on page 1; its row spacing follows the core's. (D7c)
  * The historian's rows at the core's pace, not 60 frames each. (D7c)
  * The World Map in DOS's 4 x 4 form from core state, pairings inferred, a city bit without a city unmarked. (D7c)
  * Top 5's and Demographics' DOS backgrounds (3 and 1) where the core passes 0. (D7c)
  * The city screen is a transcription of R:0D12:0483..4851 from core state, totals the core's, checked at every
    render. (D7d)
  * The CHANGE blink's grid runs from the render that found the condition. (D7d)
  * A redisplay-only press gives the core '#'. (D7d)
  * A sale is refused while the Windows list is scrolled. (D7d)
  * R:0D12:6ED4's unwritten [bp-2] taken as non-zero (inferred). (D7d)
  * Keys reach the core as character messages; the accelerators do not take H, D, J, K, N or P in the DOS city screen.
    (D7d)
  * Boxes and scenes over the city screen keep the A frame until D7e..D7g. (D7d)
  * The city view's layout is the core's grid with DOS's cells (DOS generator not run). (D7e)
  * City animations at the core's pace with the DOS counter at the core's position. (D7e)
  * The founding's fade ends at once when the core shows no view. (D7e)
  * A new wonder's 60 frames and dissolve run during the core's wait. (D7e)
  * The view after a founding is drawn after the fade. (D7e)
  * An A-frame show at the instant a scene hands over to the next N scene. (D7e)
  * The return to the city screen in the play palette at once (inferred). (D7e)
  * G#32 clipped, out-of-grid neighbours -1, slots cut when drawn; numbers to be assigned from F259. (D7e)
  * The production menu's rows keep the core's strings. (D7f)
  * The production advisor boxes are not drawn (P19). (D7f)
  * No selection flash after a choice. (D7f)
  * Find City is the core's list in a DOS menu box at a port position, not DOS's typed-name box (P16). (D7f)
  * The unit stack popup stays after a row click with several units and ends at a key, through the core's OK. (D7f)
  * The founding prompt's font 1 is inferred. (D7f)
  * The entry field shows at most 18 cells (DOS: 12, then the field grows as D5d's). (D7f)
  * The header variant on every dialog 136 and 145 MenuZ box with the core's message picture (shared numbering
    inferred). (D7g)
  * The research choice's DOS text and DOS names. (D7g)
  * The header box's A place: D6fSd's DOS place less the header frame's offset (42, 8). (D7g)
  * The recommendation in DOS's flow: the core's Windows dismissal posted, DOS picture held; quotes the user's
    2026-10-17 15:46 direction. (D7g)
  * Escape on the research choice chooses the first advance. (D7g)
  * The fold kept '\r' for the paired texts (the stray "?"). (D7g)
  * Observation: `tests/test_input.c` failed cc.cmd's clang C99 parse at line 189 (`g_tp`'s `square_only`); build.cmd
    does not cover it. (D7g)
  * Notes drawn as DOS's O4:02D3 and O4:03AA boxes from the core's name's DOS section, centred on dialog 135's window.
    (D7g2)
  * Notes' input: Return passed, any other key or left press posted as Return (ruling of 08:25). (D7g2)
  * The sale question in DOS's text and rows at DOS's (128, 80) on N, the core's name and price. (D7g2)
  * The N place rule: a generic MenuZ box on N with DOS's x, y stands there. (D7g2)
  * Row 126's map recentre: the core recentres; DOS's origin x - 10, y - 6 not proven equal (ruled 08:00). (D7g2)
  * A-canvas private ids: `PDOS_R_HELD_ID` and `PDOS_APLAY_NUKE_ID` both were 0xFF30; HELD now 0xFF50, news
    0xFF40..42, D7h2 0xFF58/59. (D7g2)
  * DOS boxes on A centred on their Windows windows (user, 2026-10-18 10:57, quoted verbatim), reversing F289, F202,
    mooting F299. (D7g2)
  * The recommendation's exception: it keeps D6fSd's DOS place on A beside the centred research choice. (D7g2)
  * Test harness: D7h2's `rrows = D_LOAD` extended the shared `D_LOAD`; fixed by D7g2 with `list(D_LOAD)`. (D7g2)
  * DOS's mouse mode only, no keyboard cursor in the Civilopedia. (D7h)
  * The option without "*NAME" waits twice. (D7h)
  * The N page restored from a snapshot after ShowCivilopediaEntry. (D7h)
  * The Civilopedia index's font 1 is inferred. (D7h)
  * Newspaper, New Cabinet and quiz texts are the core's (folded, DOS spelling), DOS's own words where DOS has them.
    (D7i)
  * No R:0238:1B44 fade before New Cabinet. (D7i)
  * A key or click during the discovery's fade ends it at once. (D7i)
  * DISCOVR2's text font inferred (font 1); the masthead's " News" fallback not applied. (D7i)
  * Between the quiz's two questions the A frame may show for one present. (D7i)
  * Palace section/style chosen by the core's rule (class W); the core lowers the key (1158:02AF), DOS does not:
    upper-case A..C differ. (D7j)
  * When the core ends the palace before the reveal's 146 frames, the rest of the dissolve shows at once. (D7j)
  * The KING box is the re-skinned row-14 MenuZ box at DOS's (20, 16), closing as the core's box. (D7j)
  * T7's level-0 pieces in quadrant 0 (inferred). (D7j)
  * The palace view's and improvement's end wait for the core's key or click while the N frame holds. (D7j)
  * The leader's idle animation follows the core, which draws none while its Status window's paint is pending. (D7k)
  * The leader screen's message boxes keep font 1. (D7k)
  * The leader's text-only path is not drawn. (D7k)
  * The D7F4 <-> g_playerCivId correspondence is inferred. (D7k)
  * The spaceship stars move at the core's pace; before the launch they stand still. (D7l)
  * Every key or button becomes a click in the spaceship window; launch actions click Launch; timed showings not cut
    short. (D7l)
  * The launch's black screen O18:15C3 is not drawn; the core's re-skinned text box shows. (D7l)
  * The star classes paired with DOS's by i mod 4 (inferred). (D7l)
  * The panel's "Prob. of Success" runs past the right edge in font 1 (bears on OB4). (D7l)
  * The arrival (row 130) is not implemented and shows the core's picture on the A frame. (D7l)
  * D7j's "Not in the unit" paragraph gains "(D7l2: row 130 composes the sad palace with them)". (D7l2)
  * D7l's paragraph: the arrival and the stars' DOS motion done in D7l2; OB4 still an inference; F243 superseded; F238
    superseded in part. (D7l2)
  * DOS's star motion (O18:0C49 every 4 frames, 2 after launch) from `pdos_rand` "space_stars" where the core's stars
    stand (choice). (D7l2)
  * The arrival's pace is the core's. (D7l2)
  * A key or click ends the rest's chunks early. (D7l2)
  * The pan's first chunk is not drawn (O2:0ECA; DOS's own effect, inferred visible). (D7l2)
  * The right button does not end the arrival's waits. (D7l2)
  * The sad palace's fade assumes DGROUP:DEBA 8 (inferred); planet's first cut and star count start (DGROUP:687A)
    unknown, taken 0. (D7l2)
  * The arrival's port bitmaps are declined. (D7l2)
  * After a Quick or Complete Replay the core waits for a key (1180:0162); DOS ends with no wait (O9:083D -> 0877).
    (D7m)
  * Complete Replay's pace is the core's (DelayTimerTicks(5), any key ends); DOS waits per event, Escape ends
    (O9:0830..089E). (D7m)
  * The replay question is asked again after every mode; DOS only after modes 1 and 2 (O9:0007). (D7m)
  * Write Replay to Disk asks the name in the core's Save dialog (row 125) first; DOS writes REPLAY.TXT without a
    dialog. (D7m)
  * The rating's border style is a seeded `pdos_rand` draw (Choice B11, "border"), never the core's RNG (P0; ext_p0
    conquest equals V0). (D7m)
  * A rating opening during the Score's return fade completes the fade at once (C.9); DOS's fade has run (inferred).
    (D7m)
  * The power graph's scale reads at most 256 history samples (turn 1023); DOS and core read turn / 4 (U5). (D7m)
  * The conquered leader's two waits are the core's, not DOS's 240 and 60 frames; fades (30, 48) and dissolve (219)
    DOS's. (D7n)
  * The nuclear explosion runs the core's 139 (63) frames of 5 ticks at the core's square, cells 21..27 repeating
    (decision 11). (D7n)
  * NUKE1's palette applied with the explosion's first frame. (D7n)
  * SLAM2's odd-width rows (OPEN P27) drawn `width` wide; DOS's stale 198th column not reproduced. (D7n)
  * The ending's key or click is the report state's I-report, as the other end screens. (D7n)
  * Alt+letter on the DOS city screen is decided as DOS reads it (the screen leaves, the letter not acted on), never
    passed (`pdos_adapt.c` city_out). (D7o)
  * D7h's F-new-4 extended: font id 0 at TextFont 1100:0A40 (ShowPediaEntry 1068:1B98) -> DOS font 1, inferred. (D7o)
* DOS-PROFILE
  * Row 25 ready while a renderer report shows; row 67 drawn as O14:186F over the core's report, exit kind none. (D7a)
  * Row 98: the O14 frame of every report in the table, closed by any key or click; 2.4 F18 and Open 16's F1 gap as
    staged; OB4 inference. (D7a)
  * Rows 68 (Military, O14:03AD/061F) and 69 (Intelligence, O14:0D43, background 1, OB2 answered by R:0D12:71BF's
    colours). (D7b)
  * Rows 70 (Attitude, O14:15F4), 71 (Trade, O14:07F1) and 72 (Science, O14:014B) with their backgrounds and pieces;
    1.7.2 as staged. (D7b)
  * Rows 73 (Wonders, O12:080D), 74 (Top 5, O3:09AC), 75 (Score, O20:0CA9, exit 1B44) as implemented in D7c. (D7c)
  * Rows 76 (World Map, O12:0000(1), OPEN L2), 77 (Demographics, O12:0D6D), 123 (historian, O12:09E2); row 98's
    wording extended to 123. (D7c)
  * Row 97 "extension D7d", row 14's allowance removed; 1.7.2 with I-city's four rows; row 97's `unexplained` drops
    2116 -> 331. (D7d)
  * Rows 25, 88, 97, 109, 111, 112 and 113 "as implemented in D7e" (as staged). (D7e)
  * Rows 12, 15, 17, 18, 87, 89 "as implemented in D7f"; SCENES 10.4 prompt at (88, 82); OPEN P16 and P26 settled.
    (D7f)
  * Rows 14 and 22 "extension D7g"; 1.7.2 generated (I-menu/advice, escape-row research choice); OPEN L8 resolved for
    136 and 145; P19 stands. (D7g)
  * Row 41 (`#MsgBox`): revolution path is ShowTextDialog 11F0:3B85 (dialog 136) then the newspaper; D8 can drop the
    `#MsgBox` wording. (D7g2)
  * The sale question built in D7g2 (row 97's screen, no own row): D8 may name it in row 97 or row 14. (D7g2)
  * Rows 13, 41, 97, 115, 117, 118, 126..128, 137 "extension D7g2" (centring named); 1.7.2 with five I-wait/note-*
    rows; OPEN none. (D7g2)
  * Rows 11, 79..84 and 99 "as implemented in D7h"; OPEN L24 not needed; P13..P15, T19 and E11 as implemented. (D7h)
  * Rows 11 and 99: the entry page above every box of both canvases (D7h2), DOS's whole-screen O8:062A (not staged).
    (D7h2)
  * Rows 23, 24, 26, 101, 119, P7, T20, E18, F1..F5 "as implemented in D7i" (staged). (D7i)
  * Rows 104 and 124 as staged ("as implemented in D7j"); 1.7.2 as generated. (D7j)
  * Rows 19, 100 "as implemented in D7k"; P11, P12, T2..T5, F9, F10, F17, E15, E21 closed; Open 11 and Open 16 closed.
    (D7k)
  * Rows 78 and 102, P35 and T18 "as implemented in D7l"; 1.7.2 as generated. (D7l)
  * Row 102's Differences corrected (end is R:0238:1B44 from black, exit kind 1, 30 frames) and extended by D7l2's
    star motion. (D7l2)
  * Row 130 "as implemented in D7l2"; P32..P34 and T17 inferred (role), medium; E12's arrival part none; 2.8 open
    counts; Open 5; 1.7.2. (D7l2)
  * OPEN L26 closed: Hall of Fame after the game in the play palette restored by the Score's R:0238:1B44 (O20:13EB).
    (D7m)
  * Rows 42 (Retire), 103 (Replay) and 106 (End-game order) "as implemented in D7m". (D7m)
  * Rows 120 (rating O3:065D), 122 (power graph) and 129 (Hall of Fame entry) "as implemented in D7m". (D7m)
  * Rows 106, 110 and 114, P8, P12, P37, T6, T16, E16, E17 and E23 "as implemented in D7n" (staged). (D7n)
  * 4.1: the City menu is unreachable from host input over the DOS city screen; its commands map to DOS keys (user's
    no-Go-Back rule). (D7o)
  * 1.7.2 / `pdos_adapt_tab.c` I-city/key texts name the Alt case; `gen/dos/adapters.py gen` regenerated 1.7.2
    (ADAPT_OK rows 166). (D7o)
  * 2.4 font map: id 0 at TextFont 1100:0A40 (ShowPediaEntry 1068:1B98) -> DOS font 1, inferred. (D7o)
  * Rows 23, 24 and 26: the core's TextBoxDraw frames of the discovery and the quiz are not replayed (page 0 holds
    DOS's screen). (D7o)
* FORMATS
  * 6.1: `[DGROUP:6444]` established: 22 entries of 8 bytes, entry 0 unused, edges to sizes by O19:1606 (OFFSETS
    WONDER_RECTS); 640A unchanged. (D7e)
  * 6.1 (decision 9's correction): `[DGROUP:640A]` holds `LEADER_FONT` (16 bytes) and `LEADER_FACE_X/Y` (10h, 48h),
    `LEADER_ATTEND_X/Y` (80h, F0h). (D7k)
* OFFSETS
  * NEWS_ORNAMENT, NEWS_PRESS, DISCOVERY_TEXTS, QUIZ_TEXTS and the note on the D7i rows (staged). (D7i)
  * The seven leader-screen rows and their note (staged). (D7k)
  * `SPACE_SECTION` DGROUP:32F2 and `SPACE2_SECTION` DGROUP:32F9 (staged). (D7l2)
  * `REPLAY_MENU` DGROUP:3FB0 (str, 1, 96 bytes, reader O9:0016) and its note (staged). (D7m)
  * The O9 readers of `LEADER_FACE_X` / `_Y` and the note on [642E] / [6430] (staged). (D7n)
* RUNNING
  * `report` diag line (opens..fade_abandoned); timeline steps `report`, `report_copy`, `report_end`, `return*`;
    d7a-report runs; test_pdos_report. (D7a)
  * `report` line gains placed, drawn_portraits, citizens, labels, dropped, nests, info_waits, tile_unknown;
    d7b-info-dos/-win runs. (D7b)
  * `report` line gains quiets, world_maps, world_squares, world_unread, palaces, names; `report_world`,
    `report_quiet` steps; d7c-world runs. (D7c)
  * `city` diag line (sessions..refused); the replay line's `city` counter; `city`, `city_draw`, `city_end` steps;
    d7d-city runs; test_pdos_city. (D7d)
  * `cityview` diag line; `cityview`, `found`, `anim` steps (sequence 1) and fade steps (sequence 3); d7e-found,
    d7e-view; test_pdos_cityview. (D7e)
  * `rdlg` diag line (creates..wakes); d7f-prod, -buy, -name, -find, -stack runs (DOS and Windows); test_pdos_rdlg.
    (D7f)
  * `preskin` pairs adv_shown, adv_posted, adv_held, adv_ended; d7g pairs (d7g-dos, -flip, -switch, -esc, -esc-ret)
    and save `CHIEF.SAV`. (D7g)
  * `rdlg` note_* pairs and `preskin2` nbox_*, held_* pairs; d7g2 pairs and their saves NOTE.SAV and GOV.SAV. (D7g2)
  * `pedia` diag line (indexes..unread) and replay `pedia`; pedia_index, _pick, _page, _end steps; d7h-pedia runs;
    test_pdos_pedia. (D7h)
  * `pedia` line ends with `covers`; d7h2 runs `d7h2-help-dos` / `-win`, `d7h2-research-dos`. (D7h2)
  * New `news` diag line; `news`, `news_shown`, `news_end`, `disc_faded`, `fade` steps; d7i runs (disc, disc-early,
    news, cab, quiz); `discovery`. (D7i)
  * `palace` diag line; `palace*` steps (sequence 1) and reveal steps (sequence 4); d7j-palace runs; ext_timeline
    palace runs; test_pdos_palace. (D7j)
  * The `leader` diag line, the replay's `leader` field and timeline.log's two steps; test_pdos_leader. (D7k)
  * `space` diag line (opens..unread); `space`, `space_launch_label`, `space_end`, `space_slot` steps; d7l-space runs;
    space run; test_pdos_space. (D7l)
  * The `space` line's new fields and timeline.log's new steps (section "Counters"); test_pdos_arrive. (D7l2)
  * `report` line gains graphs..end_unread; `report_graph`, `report_rating`, `report_replay`, `report_defer`,
    `report_quiet` steps; d7m pair. (D7m)
  * `report` line's ten `conq_*`; new `aplay` line with six `nuke*`; `conq_*` steps and fades; d7n runs; ext_timeline
    `conquest` run. (D7n)
  * scenes.log's w_over_n `in script S host H clean C` and `aown`; ext_p0's "scripted w16 input (excluded)";
    features.py's `aown`; replay `news N`. (D7o)
* Checklist items for D8
  * manual-checklist-ext.md: new items D7a-1..D7a-3. (D7a)
  * manual-checklist-ext.md: new items D7b-1..D7b-6, pointing to `build/user-builds/d7b/` when D7a and D7b land
    together. (D7b)
  * manual-checklist-ext.md: new items D7c-1..D7c-7, reached via the DOS bar's World menu and F7..F10 until D6fSb's
    WORLD menu. (D7c)
  * manual-checklist-ext.md: new items D7d-1..D7d-7. (D7d)
  * manual-checklist-ext.md: new items D7e-1..D7e-5. (D7e)
  * manual-checklist-ext.md: new items D7f-1..D7f-7. (D7f)
  * manual-checklist-ext.md: new items D7g-1..D7g-9 (D7g-1..4 the 15:37 items, D7g-5 the 15:41 report, D7g-6 the 15:46
    direction). (D7g)
  * manual-checklist-ext.md: new items D7g2-1..D7g2-9; rewrites of D6fSd-1, -2, -3, -5, -6, D7g-1, D5-7 and D6fSa-2.
    (D7g2)
  * manual-checklist-ext.md: new items D7h-1..D7h-7. (D7h)
  * STATUS / checklist: D7h-6 superseded by D7h2-1 (D7h2-1..3 pending). (D7h2)
  * STATUS / checklist: D7i done (the user checks D7i-1..6 pending). (D7i)
  * manual-checklist-ext.md: new items D7j-1..D7j-3. (D7j)
  * STATUS / checklist: D7k done (D7k-1..4 pending); OPEN L21 leader part, Open 11, 16 closed; rows 19, 100 and their
    items off the D7 gate. (D7k)
  * manual-checklist-ext.md: new items D7l-1..D7l-3. (D7l)
  * STATUS / checklist: D7l2 done (D7l2-1..4 pending); OPEN L1 arrival, Open 5 closed; row 130, P32..P34, T17, E12
    arrival off the D7 gate. (D7l2)
  * STATUS / checklist: D7m done (D7m-1..7 pending); L26 closed; row 125 (the Save dialog), D7n and D7l remain. (D7m)
  * STATUS / checklist: D7n done (D7n-1..4 pending); OPEN L1's mouth part resolved; D7o remains. (D7n)
* Other
  * FEATURES.md: the DOS City Status report in play, with the runners. (D7a)
  * STATUS.md: D7a landed (rows 25, 67, 98; F1 closed; return exit kinds in place); shadow owners 5 of
    `PDOS_OWNER_MAX` 6. (D7a)
  * User direction 2026-10-16: the report shows no Go Back / Cancel row; it closes by DOS's any key or click. Report
    items: none. (D7a)
  * Not edited: DESIGN, FIDELITY, STATUS, RUNNING, FEATURES, DOS-PROFILE outside F7, F18, Open 16 and 1.7.2,
    checklist, D1 drafts, D0 documents. (D7a)
  * FEATURES.md: the DOS advisors' reports in play, with the runners. (D7b)
  * STATUS.md: D7b landed (rows 68..72; OB2 answered; the shadow engine's negative claim). (D7b)
  * User direction 2026-10-16: no report shows a Go Back / Cancel row (Intelligence closes by a second input). Report
    items: none. (D7b)
  * Not edited: DESIGN, FIDELITY, STATUS, RUNNING, FEATURES, DOS-PROFILE outside 1.7.2, checklist, D1 drafts, D0
    documents. (D7b)
  * FEATURES.md: the DOS World reports and the historian in play, with the runners. (D7c)
  * STATUS.md: D7c landed (rows 73..77, 123; no new adapter row or PDOS_AS bit). (D7c)
  * User direction 2026-10-16: no screen shows a Go Back / Cancel row; each closes by any key or click. Report items:
    none. (D7c)
  * Not edited: DESIGN, FIDELITY, STATUS, RUNNING, FEATURES, DOS-PROFILE, checklist, D1 drafts, D0 documents. (D7c)
  * FEATURES.md: the DOS city screen in play, with the runners. (D7d)
  * STATUS.md: D7d landed (rows 97, 25; `PDOS_AS_CITY` 0x08000000; owner `city`, owners 7 of 8 with D7j's `palace`;
    row 14's allowance gone). (D7d)
  * User direction (no added Go Back / Cancel rows): the city screen shows none; EXIT and Escape leave. (D7d)
  * Not edited: DESIGN, FIDELITY, STATUS, RUNNING, FEATURES, DOS-PROFILE outside rows 14, 97 and 1.7.2, checklist, D1
    drafts, D0 documents. (D7d)
  * FEATURES.md: the DOS city view, founding scene and city animations in play, with the runners. (D7e)
  * STATUS.md: D7e landed (rows 88, 109, 111..113; row 97's city-view part); shadow owners 9 of `PDOS_OWNER_MAX` 10.
    (D7e)
  * User directions 2026-10-16 and 2026-10-17: the scenes have no box, row or highlight of their own; all on the N
    canvas at 2x. (D7e)
  * Not edited: DESIGN, FIDELITY, FORMATS, STATUS, RUNNING, FEATURES, DOS-PROFILE outside rows 25, 88, 97, 109,
    111..113, checklist, drafts. (D7e)
  * FEATURES.md: the DOS production menu, buy question, city-name box, Find City list and unit stack popup. (D7f)
  * STATUS.md: D7f landed (rows 12, 15, 17, 18, 87; 32, 86, 89 through them); P19 stands; D7g may reuse the help line.
    (D7f)
  * User directions 2026-10-16/17: Windows rows hidden by covers (Escape cancels, Alt+H is HELP); boxes at DOS size; A
    at 2x; items none. (D7f)
  * Not edited: DESIGN, FIDELITY, STATUS, RUNNING, FEATURES, DOS-PROFILE outside 1.7.2, checklist, D1 drafts, D0
    documents. (D7f)
  * FEATURES.md: the DOS science advisor's boxes (research choice, recommendation in DOS's flow) and the header
    variant on boxes. (D7g)
  * STATUS.md: D7g landed (rows 14, 22; the user's reports of 15:37, 15:41, 15:46); the brief's other D7g rows open.
    (D7g)
  * Findings: DOS's condition is the core's (Chieftain, Instant Advice); the core's 16 ShowInstantAdvice sites are
    O4:02D3 notes; P19 stands. (D7g)
  * User directions 2026-10-16/17: no row added; boxes as tall as DOS's (61-row header minimum); highlight only on the
    research choice. (D7g)
  * Not edited: DESIGN, FIDELITY, FORMATS, STATUS, RUNNING, FEATURES, OPEN, DOS-PROFILE outside rows 14, 22, 1.7.2,
    checklist. (D7g)
  * FEATURES.md: DOS boxes over the map centred as in Windows; DOS notes; the DOS sale question; the government menu
    checked. (D7g2)
  * STATUS.md: D7g2 landed (rows 13, 41, 115, 117, 118, 126..128, 137; the sale question; the centring on A). (D7g2)
  * Not edited: DESIGN, FIDELITY, STATUS, RUNNING, FEATURES, OPEN, DOS-PROFILE outside the rows above and 1.7.2,
    checklist. (D7g2)
  * Side fix: `tests/test_input.c`'s `g_tp` initializer completed (`square_only`), found by D7g. (D7h)
  * FEATURES.md: the DOS Civilopedia, its index and entry pages. (D7h)
  * STATUS.md: D7h landed (rows 11, 79..84, 99); decision 10 settled; OPEN L24 not needed; the user's Alt+H report of
    2026-10-17 covered. (D7h)
  * User directions 2026-10-16/17: no row added (EXIT is DOS's label), no index highlight (mouse mode), N frame at
    integer scale. (D7h)
  * Not edited: DESIGN, FIDELITY, STATUS, RUNNING, FEATURES, DOS-PROFILE outside rows 11, 79..84, 1.8, 1.7.2,
    checklist, drafts. (D7h)
  * SCENES-PLAY 7.11: DISCOVR1-only font 6, fade from the picture's palette (R:1FA1:026C), wait R:1459:0918 after it;
    DGROUP:BA06 shared. (D7i)
  * SCENES-PLAY 7.15: the quiz's first wrong answer goes on without INCORRECT (O16:04AC); answers box R:1D05:0018
    stays on page 0. (D7i)
  * Id collision found: `PDOS_R_HELD_ID` (D7g) and `PDOS_APLAY_NUKE_ID` (D7n) both 0xFF30 on A; D7i's ids
    0xFF40..0xFF42; for the orchestrator. (D7i)
  * FEATURES: with the DOS graphics the discoveries, newspaper, New Cabinet and quiz are DOS's. (D7i)
  * FEATURES.md: the DOS palace (view and improvement) in play, with the runners. (D7j)
  * STATUS.md: D7j landed (rows 104, 124; T7 row 107; composer ready for D7l); owners 7 of `PDOS_OWNER_MAX` 8 until
    D7d lands. (D7j)
  * User directions 2026-10-16/17: no Go Back / Cancel row; prompt box laid out for its lines, no highlight
    (DGROUP:DB38); N at 2x. (D7j)
  * Not edited: DESIGN, FIDELITY, STATUS, RUNNING, FEATURES, DOS-PROFILE outside rows 104, 124 and 1.7.2, checklist,
    drafts. (D7j)
  * SCENES-PLAY 7.9 and Open 8: the throne-room table read (frames by animation style, O6:2380..23AF, 2485..24C2).
    (D7k)
  * OPEN.md L21 (leader part resolved) and L23 (leader text's font read, O6:180F..1833). (D7k)
  * FEATURES.md: a D7k row: the DOS leader screen (rows 19, 100), the leader font by tribe, the runners. (D7k)
  * FEATURES.md: the DOS spaceship screen in play (World > Spaceships, part placed, launch); the arrival unchanged.
    (D7l)
  * STATUS.md: D7l landed (rows 102, 78; T18 row 118); row 130 not ready, its items for D7's gate; owners 8 of
    `PDOS_OWNER_MAX` 9. (D7l)
  * User directions 2026-10-16/17: no Go Back / Cancel row; "Which nation?" and launch question are re-skinned boxes
    at D6fS-a sizes. (D7l)
  * Not edited: DESIGN, FIDELITY, STATUS, RUNNING, FEATURES, DOS-PROFILE outside rows 78, 102, P35, T18 and 1.7.2,
    checklist, drafts. (D7l)
  * FEATURES.md: D7j's and D7l's rows reworded to name D7l2's arrival; a new D7l2 row (pan, landing or sad palace,
    stars' DOS motion). (D7l2)
  * OPEN.md L1: the arrival part resolved (O2:0BD7..1529 read whole); the other parts stay. (D7l2)
  * SCENES-PLAY 7.16 and Open 8's arrival read whole; TIMING 5.7: O2:0BD7 is the spaceship arrival, the core's pace
    used. (D7l2)
  * Code comments for a later touch: `pdos_scn_palace.h` line 48, `pdos_scn_palace.c` lines 41 and 1096 should say
    D7l2, not D7l. (D7l2)
  * FEATURES: the end of the game with DOS graphics: power graph, replay, rating ladder, Hall of Fame entry in the
    game's palette. (D7m)
  * OPEN L1's conqueror mouth rectangles read (O9:0F79): mouths 1 and 2 of `KING<p>.PIC` via LEADER_FACE_X/_Y; other
    L1 parts stay. (D7n)
  * FEATURES: with the DOS graphics the conqueror ending and the nuclear explosion are DOS's. (D7n)
* RUNNING (D7o): scenes.log; features.py's `--scenes` and `--require-all`; ext_p0's `--g1`; ext_adapt's and
  ext_timeline's `--representative` (test.cmd checked; every entry without it). (D7o)` correction, new checklist items for D8]

## Open items carried forward

* **OPEN L1** (`dos/OPEN.md`): the spaceship arrival O2:0BD7 is read whole (D7l2); the other parts stay as `OPEN.md`
  lists them (the conqueror mouth rectangles, the replay event table O9:080C, the city food-box height rule, the
  throne-room and wonder rectangle tables read at run time by D7e, D7j, D7k and D7n as their records say).
* **Decision 7:** no provisional W: row 130 (the arrival) is implemented by D7l2; every D7 row with a DOS counterpart is
  N, R or A (the scene ledger's 8 W rows have their section-4 reasons).
* **OPEN O7** (the odd-width rows of SLAG2/SLAM2) stays open as `OPEN.md` has it; **OPEN O8** (the human player's
  civilization destroyed): no DOS scene, row 131 class W (W9).
* **Pairings left unsure:** decision 10: the Civilopedia's body is DOS's text by evidence (D7h); decision 15: the R
  boxes' DOS static texts are paired with labels in D7f, D7g and D7g2, an unsure pairing keeping the core's text (their
  records list them).
* **Costs from one machine:** the full runs' times (D7o: ext_p0 Checked `--g1` 593 s, ext_adapt every entry 674 s,
  ext_zoom 909 s) and the units' cycle times are from this one host.
* **Not run in D7:** the DOS-oracle comparisons of 7.9 (optional; see STATUS); Asan (deferred to the end of the queue).

## The final cycle

Landed 2026-10-18: copy-in 17:03:05 UTC (`build/d7o-prep/land.py`, 22 files, `landed.sha256`; the tree's previous
files in `build/d7o-prep/tree-before/`).  First cycle: 1-build-checked BUILD_OK (17:03:10..17:06:25), 2-test-checked
TESTS_FAILED=1 (17:06:25..17:33:24): test_pdos_scene's font map count (10 rows; the row-79 row makes 11), a unit test
the staging had not run.  `tests/test_pdos_scene.c` staged on the tree's file and copied in at 17:35:00 UTC (11 rows
and the row's check; 147 -> 148; Checked, CheckedNoObs and Release built and run on the overlay first; recorded in
`landed.sha256`).  Second cycle (suffix b): 1-build-checked BUILD_OK 17:35:05..17:38:19 (194 s), 2-test-checked
TESTS_OK 17:38:19..18:05:09 (1610 s), 3-g1-checked EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) 18:05:09:
**ALL_GREEN**; 4-build-release BUILD_OK 18:05:22..18:08:29: **RELEASE_OK** (`build/d7o-status.txt`).
`build/d7o-prep/compare.py` against the snapshot before the landing: 52 of 66 outputs equal; the others as predicted
(test_input 689 -> 698, test_pdos_pedia 73 -> 79, test_pdos_profile 59 -> 63, test_pdos_scene 147 -> 148; ext_p0
P0_OK checks 476 -> 477 with the counters' lines naming D4..D7; EXT_ADAPT_OK checks 420 -> 389 under
`--representative` with d7h3-help; ext_timeline without palace_view; pdos_scene_check 1084 -> 1086 checks, 11 font
rows; ext_replay's V1 quiz, research and research2 draws 22, 1, 1 -> 0; d7d-city's `city` copies 209 -> 133 (the
declined DrawTile buffers); D7i's `news` absorbed counts higher; coverage, nodos' file count and times).  After the
landing, the tree's ext_p0 `--g1 --vars V0 --only p49-c2` on a fresh `--root` (`build/d7o-prep/g1check`): P0_OK checks
2 (the run folder fix).  User build `build/user-builds/d7o/` (18:12 UTC; WHAT-TO-CHECK.txt with D7o-1..D7o-4 and the
checklist's 175 open items of 18:08 UTC).  D7's gate is met ("Gate" above).

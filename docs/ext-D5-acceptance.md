# Extension phase D5 (setup screens, title branches, their R re-skins) — acceptance record

Prompt: `claude/docs/x64-port-scaling-dos-prompt.md`, phase D5 (section 9): the setup screens, the title branches
and the class R re-skins they use.  Brief: [verify/BRIEF-d5.md](verify/BRIEF-d5.md) (decisions 1..11 with the
orchestrator's rulings of 2026-10-15 and the user's direction of 2026-10-16, "no added Go Back / Cancel rows").
Gate (BRIEF-d5.md "The gate record"): one row per D-4 item with its method and result; 7.8 for the D5 pairs; P0
with V1 and V2 and CheckedNoObs; G-1's 77 runs on both Checked variants; 7.4; decision 8's counters per D4 and D5
row; ADAPT_OK, REGISTRY_OK, NODOS_OK and the scene check.  The DOS-oracle comparisons of 7.9 are optional and
**not run in D5** (see STATUS): D5's pixel and timing claims are labelled "DOS listing (model)".  Asan runs are
deferred to the end of the queue (the user's direction of 2026-10-10 21:20).  Under the user's direction of
2026-10-15 about 14:09 the phase gate runs the full eight-step cycle (below).  Design: DESIGN.md 12.7, 12.8,
[verify/ext-d1-draft-B.md](verify/ext-d1-draft-B.md) 11 and [verify/ext-d1-draft-C.md](verify/ext-d1-draft-C.md)
C.7.4, C.8.7, C.8.8, C.9, C.12.5..C.12.7, C.14.3, C.15.4.

D5 was done in six units, each with its own record, and two user reworks:

* **D5a, the N-window binding and the sequencer's title-branch and setup states:**
  [ext-D5a-record.md](ext-D5a-record.md).
* **D5b, class R re-skins on the N canvas (`pdos_reskin`: the menu box, the message box):**
  [ext-D5b-record.md](ext-D5b-record.md); the general rule of 2026-10-16 applied to it in D5f
  ([ext-D5f-record.md](ext-D5f-record.md) "The general rule in D5b's re-skin").
* **D5c, the DOS setup pages 0..2 and the T4 setup page (`pdos_scn_setup`, I-setup):**
  [ext-D5c-record.md](ext-D5c-record.md), with **D5cR** (no Go Back row on the three pages, no "Custom." row on
  the tribe page) in its section "User rework (D5cR)".
* **D5d, the name pages and dialog 151 (`pdos_fx`, `pdos_scn_init`, I-text, I-wait):**
  [ext-D5d-record.md](ext-D5d-record.md).
* **D5e, Customize World and the DOS help screen (`pdos_scn_custom`, I-custom):**
  [ext-D5e-record.md](ext-D5e-record.md), with **D5eR** (no Cancel row; the choices in sync between the graphics)
  in its section "User rework (D5eR)".
* **D5f, the Hall of Fame, the Load's fill, EARTH and Quit, decision 7's runs and decision 8's counters by row:**
  [ext-D5f-record.md](ext-D5f-record.md).

Labels as in `ext-D4-acceptance.md`: **compiled**, **headless**, **Win32-headless**, **DOS listing (model)**,
**agent-observed** (none in D5), **DOS-oracle-compared** (not run in D5), **user-confirmed**, **unverified**.
No DOS program was executed; nothing was written to `C:\Projects\Civ1RE\dos` or `build/dosdata`.

## Gate

Every row ran in the final cycle's `test.cmd checked` (step 2) unless it says otherwise; the markers are that
run's (section "The final cycle").  "ext_adapt" is `tests/harness/ext_adapt.py`'s DOS-form pairs (each DOS-form
run's `coreinput.log`, run.log frames, snapshots/result and events.log equal its Windows-form pair's).

| Gate item | Scenes (DOS-PROFILE rows) | Method | Evidence (unit) | Result |
| --- | --- | --- | --- | --- |
| difficulty page | SCENES 9.1 (21) | headless; DOS listing (model) | `test_pdos_setup` (the page from DIFFS.PIC, five levels, no added row, the row map; D5cR), ext_adapt d-setup-portrait, d-setup-escape (Escape = Chieftain), `ext_timeline` `birth` 4 (bgolden 12000: the T4 difficulty page) (D5c, D5cR) | pass: test_pdos_setup 164, EXT_ADAPT_OK, EXT_TIMELINE_OK (bgolden 12000 dd778d0b..., D5cR) |
| competition page | SCENES 9.2 (21) | headless; DOS listing (model) | `test_pdos_setup` (five counts, no Go Back row), ext_adapt d-setup-nogoback (a release where D5c's Go Back row was: consumed, asked again) (D5c, D5cR) | pass: test_pdos_setup, EXT_ADAPT_OK (d-setup-nogoback: coreinput 6, the release consumed) |
| tribe page | SCENES 9.3 (21) | headless; DOS listing (model) | `test_pdos_setup` (the tribe rows = core items 1..n, no Custom. / Go Back row, the bar where the core's selection has no row), ext_adapt d-setup-tribe (Escape = Custom.), d-setup-bar, d-switch-custom (D5c, D5cR) | pass: test_pdos_setup, EXT_ADAPT_OK (d-setup-tribe, d-setup-bar, d-switch-custom: the DOS name box at 42.102 s, the switch at 43.021 s) |
| tribe-name and leader-name pages | SCENES 9.4, 9.5 (21) | headless; DOS listing (model) | `test_pdos_setup` (the name boxes, the blink), `test_input` (I-text), ext_adapt d-text-custom (Ins as Space + Left) and the D5d pairs (D5d) | pass: test_input 397, EXT_ADAPT_OK; user-confirmed D5-8..D5-10 |
| dialog 151 | SCENES 9.6 (27) | headless; DOS listing (model) | `test_pdos_setup` (the border's generator ordinal, RV2-18), ext_adapt d-wait-key, d-wait-click (D5d) | pass: EXT_ADAPT_OK; user-confirmed D5-11, D5-12 |
| the T4 setup page (C.20-3) | C.8.7 (21) | headless; DOS listing (model) | `test_pdos_seq` (T4's held page at Birth's end), `ext_timeline` `birth` 3, 4 and `birth_skip` (D5c) | pass: test_pdos_seq 190, EXT_TIMELINE_OK |
| New Game | rows 2, 3 | headless | the setup rows above; `ext_p0` d5-goback, d5-tribe (D5f) | pass: P0_OK (d5-goback, d5-tribe: core traces equal) |
| Load | row 4 (class W) | headless | `test_pdos_seq` (cancel: the title box again; a game read: SCENES 7.2's fill), ext_adapt d-load-cancel, `ext_p0` d5-load-cancel, `load` (D5f) | pass: test_pdos_seq, EXT_ADAPT_OK (d-load-cancel coreinput 4), P0_OK |
| EARTH | row 5 | headless; recorded | `ext_p0` `earth` (V1, V2); nothing new drawn: MAP.PIC's palette as D4b3 left it (OPEN O3: inferred) (D5f) | pass (nothing new drawn) (visible effect unverified) |
| Customize World | SCENES 7.4 (6, 20) | headless; DOS listing (model) | `test_pdos_setup` (the transition's 31 frames, the four boxes of three items, the highlight from the core, the stale-box vectors; D5eR), ext_adapt d-custom-choices, d-custom-nocancel, d-custom-sync, `ext_timeline` `custom` (D5e, D5eR) | pass: test_pdos_setup, EXT_ADAPT_OK (d-custom-choices, d-custom-nocancel, d-custom-sync), EXT_TIMELINE_OK (`custom`); user-confirmed D5-13, D5-15, D5-17 |
| the choices in sync (D5eR item 2) | 6, 20 | headless | `custom_sync` at every presented frame (harness), ext_adapt d-custom-sync: stale 0 in both runs, both profiles shown, the Windows clicks in the DOS timeline within 20 ms (D5eR) | pass: custom_sync stale_dos 0 / stale_windows 0 in both runs (DOS-form shows_dos 7, shows_windows 5), the clicks shown 1 ms later |
| Hall of Fame | SCENES 7.5 (7, 105) | headless; DOS listing (model) | `test_pdos_setup` (O3:00D7's layout on a synthetic store, slot highlight, the 16-bit rating), `test_pdos_seq` (rows 7, 105, the pointer, the title box again), `test_input` (I-wait fame rows), ext_adapt d-fame-key, d-fame-click, `ext_p0` `fame-quit`, `fame-reload`, d5-fame-new, `retire` (D5f) | pass: test_pdos_setup, test_pdos_seq, test_input, EXT_ADAPT_OK (d-fame-key coreinput 6, d-fame-click 7), P0_OK |
| Quit | row 8 | headless; recorded | D4's title box and D4c's Q hotkey; ext_adapt d-title-quit (D4c2) | pass (recorded; D4-confirmed title box) |
| R re-skin: menu box | rows 14, 22 | headless | `test_pdos_reskin` (the builder, framed / frameless, the clamp, the hit test; no Go Back / Cancel row), `test_input` (I-menu) (D5b, D5f) | pass: test_pdos_reskin 67 (no recorded flow shows one over a DOS screen yet: D5-7, moved to D6) |
| R re-skin: message box | B4 | headless | `test_pdos_reskin` (one row per button except IDCANCEL; the default remapped) (D5b, D5f) | pass: test_pdos_reskin 67 |
| Go Back and Cancel rows | P17 (withdrawn) | headless | none drawn on any DOS screen (the user's direction of 2026-10-16): `test_pdos_setup`, `test_pdos_reskin`, `test_input` (no row maps to Go Back, Cancel, IDCANCEL); Escape the DOS form where the listing gives it (below) | pass (no such row anywhere; the table below) |
| R re-skin: the text entry | B 11.2 | headless | the name boxes (D5d) | pass: test_pdos_setup; user-confirmed D5-9 |
| R re-skin: the help screen | SCENES 10.3 (116) | headless; DOS listing (model) | `test_pdos_setup` (the help screen, O4:0045's no-section case), ext_adapt d-custom-help (D5e) | pass: test_pdos_setup, EXT_ADAPT_OK (d-custom-help); user-confirmed D5-15 |
| host dialogs: Load, Save, the overwrite confirmation | DOS-PROFILE 4 W3 | headless (class W) | the existing `--graphics dos` P0 runs `load` and `menus` (with `--file-answer`) (decision 10) | pass (class W: the host's dialogs, no DOS drawing) |
| 7.8 DOS-form equals Windows-form | every D4 and D5 pair | headless | ext_adapt: 29 pairs (D4c2's 13, D5c..D5f's) | pass: EXT_ADAPT_OK checks 107 (29 D-form pairs, 87 checks, and D3 / M's 20) |
| P0 | every scenario, decision 7's runs | headless | `ext_p0.py` Checked (V0..V8s with V1, V2) and CheckedNoObs (V5) | pass: P0_OK checks 394 (Checked), 62 (CheckedNoObs, V5) |
| G-1 | 77 runs | headless | `ext_g1.py check` on Checked and CheckedNoObs | pass: EXT_G1_OK runs 77 on both |
| 7.4 frame determinism | s3, birth, start | headless | `ext_frames.py` | pass: EXT_FRAMES_OK |
| decision 8: counters per D4 / D5 row | GATE_ROWS | headless | `ext_p0.py` V1, V2: `pdos_rows` (below) | pass: every gate row 0 in all 33 V1 and 33 V2 runs |
| tables and documents | - | headless | `adapters.py check`, `registry.py check`, `nodos.py check`, `pdos_scene_check.py`, `obs_tables.py --check`, `obs_lint.py` | pass: ADAPT_OK rows 98 steps 22, REGISTRY_OK, NODOS_OK, pdos_scene_check 1075, OBS_TABLES_OK 203 / 98, OBS_LINT_OK files 114 |
| 7.9 DOS-oracle comparisons | - | not run in D5 (optional; see STATUS) | - | not run |
| agent UI check | - | none in D5 (optional) | - | not done |
| user checks | the D5 items | user-confirmed | `manual-checklist-ext.md` D5 (below) | 9 passed (D5-3, D5-8..D5-13, D5-15, D5-17); 7 failed in their builds and reworked (D5cR, D5eR); the rest pending (below); D5-7 moves to D6 |

Verdict: **the D5 gate is met** (D5 phase gate met 2026-10-16 08:37:49 UTC): the setup screens, the title branches
and the R re-skins they use pass headless (the DOS pixels and timings as **DOS listing (model)**) in Checked,
CheckedNoObs and Release, with 7.8 (29 DOS-form pairs), P0 (with V1, V2 and CheckedNoObs), G-1's 77 runs on both
Checked variants, 7.4 and decision 8's counters (every D4 and D5 row 0); the eight-step cycle ALL_GREEN (below).
Not part of the verdict: the DOS-oracle comparisons (not run in D5, optional), the agent UI check (none), Asan
(deferred), the pending user checks and the items under "Not verified".

## The final cycle

The D5 phase gate ran the full eight-step cycle at the D5f landing (D5f with D5cR and D5eR; the stager in the build
slot, granted by the orchestrator at 07:25 UTC; copy-in 07:49:42 UTC).  Status `build/d5-gate-status.txt` (ends
ALL_GREEN), logs `build/d5-gate-<n>-<step>.log`, steps 7 and 8 `-r2`:

| Step | Command | Exit | Seconds | UTC | Last line |
| --- | --- | --- | --- | --- | --- |
| 1 | `build.cmd checked` | 0 | 190 | 07:50:31..07:53:41 | BUILD_OK variant=Checked |
| 2 | `test.cmd checked` | 0 | 1029 | 07:53:41..08:10:50 | TESTS_OK variant=Checked |
| 3 | `ext_g1.py check` | 0 | 0 | 08:10:50 | EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) |
| 4 | `build.cmd checked noobs` | 0 | 204 | 08:10:50..08:14:13 | BUILD_OK variant=CheckedNoObs |
| 5 | `test.cmd checked noobs` | 0 | 374 | 08:14:13..08:20:27 | TESTS_OK variant=CheckedNoObs |
| 6 | `ext_g1.py check --variant CheckedNoObs` | 0 | 0 | 08:20:27 | EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) |
| 7 | `build.cmd` | 0 | 220 | 08:26:51..08:30:31 | BUILD_OK variant=Release |
| 8 | `test.cmd` | 0 | 438 | 08:30:31..08:37:49 | TESTS_OK variant=Release |

* **The restart.**  A session restart killed the cycle's driver at 08:22:33 UTC during step 7's first run (started
  08:20:27 UTC; no status line written, `build/d5-gate-7-build-release.log` incomplete).  The orchestrator
  re-verified the 37 landed files against `build/d5f-prep/landed.sha256` (unchanged) and resumed at 08:26:28 UTC
  from step 7 (`-FirstStep 7 -RunSuffix '-r2'`).  Steps 1..6 stand; after the cycle (08:39:05 UTC) the landed files
  and build.cmd / test.cmd still had their hashes, so all three variants come from the same tree.
* **Markers.**  Checked: REGISTRY_OK, NODOS_OK, GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK, P4_TESTS_OK, OBS_TABLES_OK
  probes 203 sites 98, OBS_LINT_OK files 114 probes 203 callsites 98, pdos_scene_check 1075, ADAPT_OK rows 98
  steps 22, P0_OK checks 394, EXT_FRAMES_OK, EXT_TIMELINE_OK (base and bs), EXT_CONTINUE_OK, EXT_BS_OK (assets,
  mirror), EXT_ADAPT_OK checks 107, MIRROR_OK runs 29, ZOOM_OK combinations 32 runs 64 samples 388, REPLAY_OK
  checks 70, TRACE_OK.  CheckedNoObs: the same without the Checked-only sections (ext_frames, ext_timeline,
  ext_adapt, ext_mirror, ext_zoom, ext_replay), P0_OK checks 62.  Release: REGISTRY_OK, NODOS_OK, OBS_TABLES_OK,
  OBS_LINT_OK, pdos_scene_check 1075, ADAPT_OK rows 98 steps 22, TRACE_OK.  49 test programs in each variant, 0
  failures (test_pdos_setup 164 / 164 / 164, test_pdos_seq 190 / 190 / 190, test_input 397 / 370 / 397,
  test_pdos_reskin 67 / 56 / 67, test_dos 23,227; Checked / CheckedNoObs / Release).
* **Against the predictions** (`ext-D5f-record.md` "Landing", with the helper outputs in `build/d5f-prep/`):
  Checked against the D6b landing's outputs differs where D5f's "Expected changes at the build slot" says, plus
  four explained differences it did not list: nodos scanned four files more, not two (the two new records count);
  `replay.no_shadow` -> `replay.scripted` by 7 in arrival, conquest and retire (row 105 is now a scripted scene);
  D5d's pairs d-wait-key / d-wait-click one core input more in both forms (D5cR's bar-choose on the tribe page);
  `custom` 188 -> 187 shows (D5eR: the fourth box's Cancel-row redraw at custom_end is gone).  CheckedNoObs and
  Release were last tested at the BS gate; their differences since are, item by item, the per-variant counts the
  records of UX1b, D5a..D5e, D6a, D6b and D5f give (`variants-out.txt`: every change the change Checked shows over
  the same span).  No unexplained difference.

## Decision 8: the counters by scene row

`ext_p0.py` attributes every count of `unexplained`, `w_over_n`, `font_unmapped`, `colour_nearest` and
`prov_unknown` to the scene row on top of the stack (the picture dialog's row 25 to the row beneath it) and
requires 0 for D4's and D5's rows (GATE_ROWS 1..9, 16, 20, 21, 25, 27, 105, 116) in every V1 and V2 run.  Every
gate row is 0 for all five counters in every run.  The rows that keep counts are not gate rows:

In V1 and V2 alike (33 runs each: the 27 scenarios and decision 7's six; `obj/rowsum.py` over the private runs;
the final cycle's runs give the same table line for line, `build/d5f-prep/rowsum-gate.txt`; `w_over_n`,
`colour_nearest` and `prov_unknown` are 0 for every row):

| Row (DOS-PROFILE) | Counter | V1 (= V2) | Runs | Why not 0, and whose |
| --- | --- | --- | --- | --- |
| 0 (an empty stack) | unexplained 258, font_unmapped 72 | 6 runs | arrival, load, quiz, research, research2, s2 | after a Load the play's first drawing comes before the play scene's row is on the stack (SCENES 7.2's fill holds; the core then draws the map and the panels); D6's play renderer |
| 11 (130 Civilopedia page and list) | unexplained 82, font_unmapped 2 | 2 | research, research2 | play dialogs over the play screen (the A frame until D6); D6 / D7 |
| 14 (136 plain message, MenuZ) | unexplained 2 | 1 | city | D5b re-skins its menu box, but it opens only in play here, over the play screen (the A frame); the core's drawing around the box is the play's (D6); no recorded flow shows it over a DOS screen (D5-7) |
| 15 (137 text entry), 17 (140 production list) | unexplained 1, 1 | 1 | city | play dialogs (dialog 137's city-name box is D7, `ext-D5d-record.md`); D7 |
| 19 (142 leader audience) | unexplained 54, font_unmapped 24 | 6 | the runs from a save | play (D7) |
| 23, 24 (146, 147 discovery), 26 (149 quiz) | unexplained 12, 12, 27 | 1 each | research, research2, quiz | play (D7) |
| 67..79 (the Advisors, World and Civilopedia menus) | unexplained 1..91, font_unmapped 1 (79) | 1 (75: 4) | menus (75 also arrival, conquest, retire) | play menus (D6 / D7) |
| 88, 97, 98, 101..104 | unexplained 4, 2272, 22, 6, 1, 1001, 9 | 1..4 | city, new, s3, settlers, menus, the game ends | the city screen, reports, the newspaper, the spaceship, the replay, the palace: play (D6 / D7) |
| 109, 114, 120, 122, 124, 130 | unexplained 67, 2, 29, 9, 2, 167 | 1..3 | new, s3, settlers, conquest, arrival, retire | play animations and endings (D7) |

Rows 7 and 105 (the Hall of Fame), 25 (the picture dialog, counted for its opener) and every other gate row are 0
in every run, including `retire`, `conquest` and `arrival`, which end in the Hall of Fame.

## Obligations for D6 and D7

* **Escape on a re-skinned dialog is provisional per screen** (the orchestrator's condition on the general rule):
  letting Escape pass to the core's MenuZ or message box (I-menu/return-escape; a message box's IDCANCEL) is the
  DOS form of the core's Go Back / Cancel only where DOS's Escape on that screen has the same effect.  When a D6 or
  D7 renderer shows such a dialog over a DOS screen, it must check the listing; where DOS's own Escape there does
  something else (e.g. asks again), Escape takes the DOS meaning and the core's button becomes Windows-only,
  recorded with the listing address.
* **No added row**: no D6 / D7 DOS screen draws or hit-tests a Go Back, Cancel or similar dismiss row the DOS screen
  lacks; any other row the DOS screen lacks is reported to the orchestrator before it is added.
* Decision 8's counters stay 0 for D4's and D5's rows; D6 and D7 extend GATE_ROWS with their own.

## Where a core Go Back / Cancel has a DOS form (the general rule)

| Screen | Core button | DOS key with the same effect | Form |
| --- | --- | --- | --- |
| difficulty page | Go Back (102, disabled at step 0) | none: Escape is Chieftain (O5:009B..00A2) | Windows-only |
| competition page | Go Back (102) | none: Escape asks again (O5:0190..0196) | Windows-only |
| tribe page | Go Back (102) | none: Escape is the random tribe and its name (O5:05BA..05CE, O23:0173) | Windows-only |
| Customize World | Cancel (0x66) | none: Escape asks the question again (R:01A8:065A, 06B7, 0714, 0771) | Windows-only |
| a re-skinned MenuZ box (dialogs 136, 145) | Go Back / Cancel | Escape: MenuZ's -1 (R:1D05:0200 -> 0392) | Escape, provisional per screen |
| a re-skinned message box | IDCANCEL | Escape (the core's message box has the focus) | Escape, provisional per screen |
| the name pages, dialog 151, the Hall of Fame | none drawn | - | - |

## User checks

* **Passed** (user-confirmed, `manual-checklist-ext.md`): D5-8..D5-12 (D5d: the name pages, dialog 151, switching),
  D5-13, D5-15, D5-17 (D5e: the transition, the help screen, the fourth choice); D5-3 (the difficulty page's ways
  to choose; the user's results page, STATUS "User directions" 2026-10-16 about 08:05).
* **Failed in their builds and reworked** (D5cR, D5eR; the coordinator rewrites the items, "For the records"):
  D5-2, D5-4, D5-5, D5-6 (build d5c), D5-14, D5-16, D5-18 (build d5e); D5-1 affected (its "Go Back greyed").
* **Moved to D6**: D5-7 (the menu-box look; the user, about 08:05: "could not grasp which re-skinned DOS menu is in
  the question"; no recorded flow shows a re-skinned menu box over a DOS screen before D6; the orchestrator, 08:15
  UTC: a named screen in D6's user checks).
* **Pending**: D5-1 and the reworked items above; the new D5f items (`ext-D5f-record.md` "What the user checks":
  the Hall of Fame from the title and at a game's end, the Load's cancel and fill) and the D5cR / D5eR checks (the
  bar on the tribe page, Go Back / Cancel only in the Windows graphics, the Customize sync after a switch).  The
  user build is the coordinator's (`build/user-builds/d5`), from the gate's landed tree.

## Deviations (summary, one line each)

* D5a-1 `movie_wnd` is dialog 148's window, not GR_DialogOpen's AX; D5a-2 no OBS_CTL_CHECK (mz_sel read at the key
  poll); D5a-3 a missing dialog at a call site only counts PDOS_DIAG_SEQ; D5a-5 `update_n_window` takes logical
  templates only (`ext-D5a-record.md` "Deviations").
* D5b-1 the menu box's highlight is the core's selection; D5b-2 the message box is a menu box (no "OK in an outline",
  caption, icon); D5b-3..5 header wrap at 34 columns, DOS font 1, an even message-box y; D5b-6 Help / sound buttons
  not drawn, Alt+H / Alt+V and the right button consumed; D5b-7 a message box has no adapter scene.
* **The general rule of 2026-10-16** (replaces P17 and extension prompt 5.4 "Flow" for dismiss rows): no Go Back /
  Cancel row on any DOS screen; MenuZ boxes and message boxes without them; Escape passes, provisional per screen.
* D5c: dialog 144 drawn by a shadow owner (no DROP brackets); Up / Down passed only where MenuZ's wrap lands on the
  next row (the box's edges consumed); the drag highlight view-only until the core is ready; DGROUP:3936 assumed
  FFFFh; O5:05B6..0629 not modelled; row 21 PDOS_RD_SCRIPT.
* D5cR (reverses ruling 4 and P17's Go Back row): the setup box has DOS's rows only (tribe row k = core item k + 1);
  Go Back Windows-only on the three pages; the bar where the core's selection has no row (stays; row 0 on a new
  page); Up / Down / Return then by bar-move / bar-choose.
* D5d: the field's capacity (the DOS max or the core's limit, grown and scrolled); Ins as Space + Left; the first
  key's clear through the core's select-all; mouse: a left press accepts, the right consumed; the blink at sequencer
  steps; dialog 151's other tokens empty, no tune, BA06's size not modelled; C.15.1 item 7 restated (pdos_rand only
  through effect instances).
* D5e: the transition is pdos_scn_custom's own timeline (not a pdos_fx effect); the entry phase; the highlight the
  core's selection (a repeat of Up / Down consumed); the pointer moves and disk checks not modelled; Escape consumed;
  the help screen at the core's dialog 135; Open C-4 settled; the scene word 32 bits.
* D5eR (reverses ruling 5): no Cancel row; the core's Cancel Windows-only; a DOS box shows the core's selection when
  first drawn; a Windows radio click is a selection, not an answer (DOS's order stays).
* D5f: the Hall of Fame's "Clear" omitted (P18); a difficulty outside 0..4 shows no title or level; the rating's
  16-bit product as DOS; EARTH and Quit draw nothing new; decision 8's row 25 counted for its opener; the w_over_n
  fallback skips a hidden scene window (the title dialog's creation, dialog 143's close).

## Asan

Deferred under the user's direction of 2026-10-10 21:20 (the end of the queue); not run in D5.

## For the records

Gathered from the six unit records and the two reworks; none is applied by the stagers (DESIGN, FIDELITY, STATUS,
RUNNING, FEATURES, the manual checklist and the D0 / D1 documents are the docs agent's):

| Unit | Its "For the records" | Applied |
| --- | --- | --- |
| D5a, D5b, D5c | their records | by the docs agent after the D5 landing (STATUS session log) |
| D5d | [ext-D5d-record.md](ext-D5d-record.md) | by the docs agent after its landing |
| D5e | [ext-D5e-record.md](ext-D5e-record.md) | by the docs agent after its landing |
| D5cR | [ext-D5c-record.md](ext-D5c-record.md) "User rework (D5cR)" | pending |
| D5eR | [ext-D5e-record.md](ext-D5e-record.md) "User rework (D5eR)" | pending |
| D5f | [ext-D5f-record.md](ext-D5f-record.md) | pending |

Pending, in one list:

* **The manual checklist** (the coordinator): D5-1 ("Go Back greyed" removed), D5-2, D5-4, D5-5, D5-6 (D5cR's
  texts), D5-8 ("choose "Custom." on the tribe page, or press Escape there" becomes "press Escape on the tribe page,
  or click outside its box": no "Custom." row since D5cR), D5-14, D5-16, D5-18 (D5eR's texts), and the new D5f /
  D5cR / D5eR items (the records' "What the user checks" and "For the records").  D5-7 moves to D6 (the
  orchestrator, 08:15 UTC: a named screen and build in D6's user checks), its text changed from "a Go Back or Cancel
  row is the last row, in the item colour, and Escape goes back" to "no Go Back or Cancel row; Escape goes back
  where the dialog has one".  D5-3 passed (already recorded, 08:05).  The checklist's counts (91 items, 64 passed,
  27 pending after the 08:05 results) change with the new items and the moved one.
* **FIDELITY**: F162 (the setup pages: the added Go Back / Custom. rows and the mouse-only Go Back withdrawn; Go Back
  Windows-only, cited O5:009B, O5:0190, O5:05BA; the bar rule), the ruling-4 entry withdrawn, F135 / F166 (ruling 5's
  Cancel row withdrawn; Cancel Windows-only, R:01A8:065A..0771; the sync interpretation; a box first drawn on the
  core's selection), the general rule for re-skinned MenuZ and message boxes (Escape provisional per screen), the
  Hall of Fame (O3:00D7, OPEN L7 settled, "Clear" omitted), the Load's fill, EARTH's palette inferred (OPEN O3).
* **DESIGN** 12.7 / 12.8 "As implemented (D5)": the setup box's DOS rows only (row k = item k + 1) and bar-move /
  bar-choose; no Cancel row, the sync criteria and the harness's `custom_sync`; pdos_scn_fame; the picture windows'
  owner (template 148); decision 8's `pdos_rows` attribution; the general rule and the D6 / D7 Escape obligation
  (above); B 11.2's P17 rows withdrawn.  The Birth golden frame 12000 cited as d67d465f... in DESIGN, FEATURES and
  FIDELITY (and the D5a..D5c records) is dd778d0b... since D5cR.
* **DOS-PROFILE.md**: 3.2 / 3.3 (the setup pages: no Go Back; "Custom." only by Escape or the outside release), the
  3.x rows "Go Back in setup" and "Cancel in Customize" (Windows-only, no DOS form), rows 4, 5, 7, 8, 105 as
  implemented (rows 7 and 105 `PDOS_RD_SCRIPT`), row 6's text (three items per box), 16, 20, 21, 27, 116 as in their
  units; 1.7.2 regenerated here (98 rows).
* **RUNNING / FEATURES**: the DOS Hall of Fame and Load fill; presentation-diag.log's `pdos_rows` and `custom_sync`
  lines; the D5 DOS screens with Go Back / Cancel only in the Windows graphics.
* **STATUS**: D5f done and the D5 phase gate met 2026-10-16 08:37:49 UTC (the eight-step cycle ALL_GREEN, step 7
  resumed after a session restart; Checked, CheckedNoObs and Release; Asan deferred; DOS-oracle comparisons not
  run); the user build `build/user-builds/d5` and the pending D5 user checks (above).

## Not verified

* The timing of the DOS-only waits omitted after menu choices (C.7.4).
* The frameless highlight on pictures (OPEN O4).
* EARTH's palette effect at Birth's start (OPEN O3: inferred).
* DOS-oracle comparisons (7.9): not run.  Same-seed and full-game qualification are outside D5.
* The D5 user checks still pending (above), and D5-7 (moved to D6).

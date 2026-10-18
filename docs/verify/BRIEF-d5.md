# Brief for the D5 implementers (extension phase D5: setup screens, title branches, their R re-skins)

> **Cycle rule changed 2026-10-15 about 14:09 UTC (the user's decision, STATUS "User directions"; `verify/BRIEF-cy.md`):** wherever this brief says "the eight-step cycle", a unit now ends with the **three-step cycle** (`build.cmd checked`, `test.cmd checked`, `ext_g1.py check`); the full eight-step cycle runs only at phase gates (D4, BS, D5, D6, D7, X9, WL and before the final Asan pass).

Written 2026-10-15 for the orchestrator by a read-only planning agent (session E3); adopted by the
orchestrator 2026-10-15 with the rulings below "Decisions for the orchestrator". Phase D5 of the extension prompt
`claude/docs/x64-port-scaling-dos-prompt.md` (section 9): "Setup screens and the title branches; the R
re-skins they use." Gate: "7.8; P0." It delivers D-4 (prompt 4): every new-game setup screen and every
title branch (New Game, Load, EARTH, Customize World, Hall of Fame, Quit) in the DOS style, mapped onto
the Windows flow (5.4, 5.6); the file choice of Load and Save and the overwrite confirmation are host
dialogs (`host_choose_file`, `host_confirm_overwrite`), class W with that reason. Asan runs stay deferred
to the end of the queue (the user's direction of 2026-10-10 21:20).

D5 starts after the D4 gate (`ext-D4-acceptance.md`). D4 is still being completed when this is written:
D4b3 (Birth) runs, then D4c1 (the filter stage, `pdos_adapt` and `pdos_adapt_tab.c`, `pdos_mouse`) and
D4c2 (`pdos_pend`, the 7.8 scripts, the gate); see `BRIEF-d4.md`, last section. D5's adapters are rows
added to D4c's table and filter stage and use D4c2's pending translations; where D4c's final interfaces
differ from draft C, D5 uses what D4c built and records the difference.

## Decisions for the orchestrator

Design gaps and choices found while planning; no DOS fact is decided here. Each has a proposal.

1. **Unit cut.** The units below are vertical slices: each scene's renderer, its adapter rows and its
   7.8 pair in one unit (D4 cut horizontally: renderers in D4b, adapters in D4c). Reason: the setup and
   Customize adapters depend on the boxes their renderers lay out (`pdos_r_hit`, `PDOS_BOX_SETUP`), so a
   unit can prove its scene end to end. Alternative: renderers D5a..D5e, then one adapter unit.
2. **OFFSETS.md rows.** The strings D5 draws have no registry rows yet (`ext-D4b3-record.md`
   "Discrepancies" 6 names DGROUP:3526 and 3B28; draft B 20 E-B1 asks for `SETUP_DIFFICULTY` at D5). The
   rows needed are at least DGROUP:3526, 357B, 3595, 35A6, 53B8, 53AB, 35CE (setup), 1B48, 1B6F, 1BA0,
   1BC5 and the help topics 1B6A, 1B94, 1BBD, 1BFE (Customize), 33BE, 33CB (Hall of Fame) (DOS-PROFILE.md
   3.4; SCENES 7.4, 7.5, 9). OFFSETS.md's own rule is "a row is added by the phase that first consumes
   it", but the D4 rules forbid editing D0 documents. **Proposal:** allow D5 (and D6) implementers to add
   OFFSETS.md rows (a build input that `registry.py check` verifies against the listing), as an exception
   named in the Rules. Alternative: E's `pdos_table_resolve` with local descriptors (the D4b3 note).
3. **Checks against documents the implementers may not edit.** `gen/dos/adapters.py check` (ADAPT_OK,
   D4c1) compares `pdos_adapt_tab.c` with DOS-PROFILE.md 1.7 version 2, and `pdos_scene_check.py`
   compares `pdos_scene_tab.c` with DOS-PROFILE.md 1 and 2.4. New D5 adapter rows (I-setup, I-custom,
   I-text, I-wait) would fail the cycle until the document changes. **Proposal:** once D4c1 has fixed
   how `adapters.py` works, let D5 implementers regenerate only the generated 1.7 version 2 section
   (`adapters.py gen` or equivalent), as an exception; every other DOS-PROFILE.md change stays "For the
   records". Alternative: a docs agent applies each unit's rows before that unit's cycle.
4. **The core's "Custom." row on the DOS tribe page.** Draft B 11.2 re-skins every MenuZ child, which
   draws the core's item 0 "Custom." as a row; DOS has no such row (Escape is its DOS form: SCENES 9.3,
   DOS-PROFILE 3.3, draft C C.12.7), and C.12.5's "DOS row k = core item k" then needs an offset.
   **Decide:** show "Custom." as a row (one more row than DOS) or omit it (Escape only; rows shift by one).
5. **Customize's added Cancel row (P17).** C.12.7 says "the added Cancel row: click the dialog's Cancel"
   but not which of the four DOS boxes carries it. **Proposal:** the current question's box only.
6. **Hall of Fame scope.** Row 7 (from the title) and row 105 (the same ShowHallOfFame 1080:0119 at the
   end of a game) share one renderer. **Proposal:** D5 renders ShowHallOfFame for both rows;
   InsertHallOfFameEntry (row 129, the new-entry form, "Clear" omitted by P18) and the end-game palette
   (OPEN L26) stay D7.
7. **New coverage runs.** No scenario reaches Go Back, the Custom tribe path (setup step 3), Customize
   Cancel or help, a cancelled Load, or a new game after the Hall of Fame. **Proposal:** add them only as
   `ext_adapt.py` pairs and `ext_p0.py` runs; `scenarios.py`, `gate3b`, the G-1 baseline and its 77 runs
   stay unchanged.
8. **The counter criterion of the gate** (draft B 15.2: `unexplained`, `w_over_n`, `colour_nearest`,
   `font_unmapped`, `prov_unknown` are 0 "for covered scenes"). The P0 runs continue into play, which D6
   and D7 cover. **Proposal:** attribute each counted event to the scene row on top of the stack (B 7.6:
   the unexplained ring already holds the innermost open probe) and require 0 for D4's and D5's rows;
   alternative: count only up to WdwMapOpen 1208:0AF1.
9. **Help in Customize** (DOS-PROFILE row 116, ShowHelpNote 10E0:0000, dialog 135, R, DOS help screen
   O4:0000, "called from Customize only on Windows"). **Proposal:** D5e implements it, since Customize
   uses it; the other note rows (117, 118) stay D7.
10. **Host dialogs (D-4, W3).** Save and the overwrite confirmation are reached only in play.
    **Proposal:** D5's gate records all three host dialogs as class W with the reason of DOS-PROFILE 4 W3,
    on the evidence of the existing `--graphics dos` P0 runs (`load`, `menus` with `--file-answer`); no
    drawing is needed for them.
11. **D4b3's hand-over.** D4b3 planned to hold the faded screen after DOS Birth and leave the T4 setup
    page to D5 (`ext-D4b3-record.md`, "Plan"). **Proposal:** D5c owns the call from the post-Birth path
    into `pdos_setup_page` and may edit `pdos_birth.c` / `pdos_seq.c` for it.

### Rulings (orchestrator, session E3, 2026-10-15; these bind the D5 units)

1. Vertical slices adopted (renderer, adapter rows and 7.8 pair per scene).
2. Adopted: D5 and D6 implementers may **add** OFFSETS.md rows (never change or remove one), each with
   its listing address and evidence label, then run `registry.py` (generate and check) and `nodos.py
   check`; the rows go into the unit's record. Local descriptors only where a row cannot be justified.
3. Adopted, widened: implementers may regenerate the generated DOS-PROFILE.md sections (1.7 version 2
   by `adapters.py`) and may add or update the scene-table rows that their code tables mirror, so that
   `pdos_scene_check.py` and `adapters.py check` pass; after **any** DOS-PROFILE.md edit they run
   `C:/Python314/python -B gen/obs_tables.py --check` (DOS-PROFILE.md is its input: no new Windows
   `SSSS:OOOO` call addresses unless the observer tables are meant to change) and list the edit in the
   record. Every other DOS-PROFILE.md text stays "For the records".
4. **Show "Custom." as an added row** in the DOS style. Extension prompt 5.4 "Flow": a choice the Windows
   core needs but the DOS screen lacks is added in the DOS style; Escape alone would hide a choice the
   core offers. DOS row k maps to core item k+1 below it (C.12.5's offset recorded as a deviation);
   Escape keeps its DOS meaning as well. Recorded as a flow difference.
5. Adopted: the added Cancel row is on the current question's box.
6. Adopted (row 7 and row 105 share the renderer; rows 129 and L26 stay D7).
7. Adopted: new coverage only in `ext_adapt.py` pairs and `ext_p0.py` runs; `scenarios.py`, `gate3b`,
   the G-1 baseline (and its amendment list) unchanged by D5.
8. Adopted: attribute counted events to the innermost scene row and require 0 for D4's and D5's rows.
   If the attribution proves costly, fall back to counting up to WdwMapOpen and record why.
9. Adopted (D5e implements row 116; 117, 118 stay D7).
10. Adopted.
11. Adopted, after the D4 gate: D5c may edit `pdos_birth.c` / `pdos_seq.c` for the hand-over.

### User direction 2026-10-16: no added Go Back / Cancel rows (binds this phase and every later unit)

The user, 2026-10-16 about 06:10 UTC (STATUS "User directions"): "Yes: in DOS graphics never show a Go Back or
Cancel row the DOS game doesn't have, on any screen; where DOS has a key for it (e.g. Escape), that key does it,
otherwise that choice is only in the Windows graphics."

* OPEN P17's "extra row in the DOS menu box" (draft B 11.2 and 11.5; C.12.7's added Go Back / Cancel rows) is
  withdrawn for every DOS screen, and so is extension prompt 5.4 "Flow" for these rows. No DOS screen draws or
  hit-tests a Go Back, Cancel or similar dismiss row that the DOS screen lacks.
* A core Go Back / Cancel button has a DOS form only where the DOS listing gives that screen a key or action with
  the same effect (e.g. Escape), cited by listing address in the record. Otherwise no DOS form reaches it: it is
  recorded as Windows-only, reachable by switching to the Windows graphics.
* Before adding any other row that the DOS screen lacks (as "Custom." was), report it to the orchestrator; do not
  add it on the 5.4 "Flow" rule alone.
* The user's specific directions of 05:43..06:00 UTC (units D5cR and D5eR): no Go Back row on the DOS difficulty,
  competition and tribe pages; no "Custom." row on the tribe page (Escape chooses Custom, as in DOS); no Cancel
  row on the Customize boxes; the Customize choices in sync between the graphics while answering. They reverse
  BRIEF-d5 rulings 4 and 5.

## Authority and design

* The design is DESIGN.md 12.7 (area B, with "As implemented (D4a)", its "Limitations for D4b/D5" F2 and
  F5, and "Added in D4b2b2"), 12.8 (area C, with "As implemented (D4b)" and its "Left"), 12.10 (w16
  changes: D5 adds none without recording why), 12.11 (P0), and the detailed designs
  `verify/ext-d1-draft-B.md` and `verify/ext-d1-draft-C.md` (Revision 3), with `verify/ext-d1-decisions.md`.
  D4's code is the base: read `ext-D4a-record.md` ("What is left", "Second review (2026-10-12)": S4, O1,
  O2, O3, P1 are D5's), `ext-D4b2b1-record.md` (Deviation 3: the C.11.2 rows not yet resolved),
  `ext-D4b2b2-record.md` (the menu-box model; Deviation 2), `ext-D4b3-record.md` and the D4c records and
  gate record when they exist. Do not redo what exists.
* Sections of draft B: 2 and 2.1 (files, callback order), 4.4 (the menu-box model, built in D4b2b2),
  6.1, 6.3, 6.4 (N canvas, frame choice, W over N, B4), 7.2 ("Open for D5", S4), 7.3 (S3 still open),
  9.2, 9.3 (B11, RV2-18), 10.1..10.4, 11.1..11.5 (re-skins, placement on N, `pdos_r_hit`, the T4 setup
  page, B21), 15.1 (`test_pdos_reskin`, `test_pdos_setup`), 15.2, 19 (OB11 if met), 20 (E-B1).
* Sections of draft C: C.5.6, C.7.4 (after a title choice; back to the menu), C.8.7 and C.8.8 (the T4
  setup page and the post-Birth fade; decision C.20-3), C.9 (TX: the 5-step fades, the text-entry
  cursor; "menu confirmation: none modelled"), C.11.1..C.11.6, C.12.2, C.12.5, C.12.7 (D5 rows I-setup,
  I-custom, I-text, I-wait), C.12.9, C.13.3, C.13.6 example 4, C.14.2, C.14.3, C.15.2, C.15.4 (cases 9,
  10), C.19 (Open C-3, C-4).
* DOS-PROFILE.md: 1.1 rows 2..8, 1.2 rows 16, 20, 21, 27, 1.4 row 105, 1.5 rows 116, 141, 1.6, 1.7
  (I-title, I-setup, I-custom, I-text, I-wait), 1.7.1, 3.1 (start-up, New Game, EARTH, the DOS story
  ending with the world done, After Birth, Setup questions, Hall of Fame view), 3.2, 3.3, 3.4, 4 (W3, W6),
  4.1. DOS facts: `docs/dos/SCENES.md` 6, 7.1..7.5, 9 (preparation, 9.1..9.7), 10.1, 10.3, 10.4 and its
  Open 3, 4, 7, 8, 9, 11; `TIMING.md` 3.5, 5.4, 5.8; `docs/dos/OPEN.md` P17, L7, L28, O3, O4.
* Implement as written; where the code shows the design is wrong or incomplete, make the smallest correct
  fix and record it as a deviation (design section, what and why) in your record.
* DOS facts come only from `claude/port/docs/dos/*.md`, the listing in `claude/port/build/dos/disasm/`
  and the files in `claude/port/build/dosdata/` (read at run time through E's API; never copied into the
  repository). Never from memory. Cite the listing address (`R:ssss:oooo`, `O<n>:oooo`, `G:0000:oooo`,
  DGROUP) for every constant. Windows-side facts (control ids, globals, call sites, the setup steps) come
  from the port's own sources (`claude/src`, `core/`) and the listing tools the base prompt allows
  (showfunc); never from memory.
* The extension prompt (1 P0, 2.3, 4 D-2..D-4, 5.3..5.6, 5.9, 5.10, 7.3, 7.4, 7.8, 8) and the base prompt
  `claude/docs/x64-port-prompt.md` sections 1, 5.0, 7 and 9 govern.
* The user's directions (STATUS.md "User directions") that touch D5: the start-up through setup screens
  stay 4:3 (2026-10-10 about 21:00; decision X3: the `--aspect` default 4:3 for 320x200 frames; the
  virtual desktop stays 640x480 until WdwMapOpen, phase G); "Birth's DOS setup page shown early"
  (C.20-3) is a pending user check (`manual-checklist-ext.md` D5-1); every agent runs on the session's
  own model (2026-10-12 about 00:20).

## Rules

* **P0 above all.** The DOS profile reads only through `w16q_*`, writes only presentation memory, posts
  nothing except through the filter stage's documented translations (I1), and never reads `g_randSeed`.
  After every build: `test.cmd checked` (all base tests, gate3b references, scenarios, `ext_p0.py`,
  `ext_frames.py`, `ext_timeline.py`, `ext_adapt.py`, `ext_mirror.py`, `ext_zoom.py`, the M and D4 tests)
  and `ext_g1.py check` on Checked and CheckedNoObs stay green. A failure is fixed before anything else.
* **Each unit ends with the eight-step cycle green:** Checked build and tests, G-1, CheckedNoObs build,
  tests and G-1, Release build and tests; no Asan. **Builds are yours alone** during your unit. Timeout
  600000 ms; logs under `claude/port/build/`, named after your unit.
* **Files.** Edit the code, tests and build files your unit needs and write your record. Do not edit
  `DESIGN.md`, `FIDELITY.md`, `STATUS.md`, `RUNNING.md`, `FEATURES.md`, `DOS-PROFILE.md` (except as
  decision 3 allows), `manual-checklist-ext.md`, the D1 drafts or the D0 documents (except OFFSETS.md
  rows as decision 2 allows): list the entries under "For the records".
* **No DOS bytes** in the repository or a binary (`gen/dos/nodos.py check`); tests store only hashes,
  offsets, sizes and hand-written vectors. Never write `C:\Projects\Civ1RE\dos` or
  `claude/port/build/dosdata`; never execute a DOS program on the host.
* **Code rules of `present/dos`** (obs_lint's area-B and area-C rules): no `w16_` identifier except
  `w16q_`, no `g_randSeed`, no core `RandomBelow`, no `post_event`/`host_poll_event`/`vm_`, no
  `#if CIV_CHECKED`. DOS-only effects with no core decision use `pdos_rand` seeded per effect instance
  (B11), started only in `on_event`, `on_probe` or `advance` (RV2-18).
* **Renderers that transcribe DOS drawing** check D4a's F2 (the sprite arena of each G#18 against the
  grabs before the next G#18) and F5 (G#31's ghost pointer before a copy from that page) per call site
  and record the result.
* **Independence**: never read the main project's excluded paths (`verify/BRIEF-d0.md` lists them);
  ignore AGENTS.md's GFX/DOS/Modern/Mac/SNES sections.
* **UI.** Headless and Win32-headless tests. A short agent check with a visible civ64 window is allowed
  for D5f (civ64 windows only, `--graphics dos`, screenshots under `claude/port/build/ext-d5-ui/`), not
  required. An agent observation is not user acceptance.
* No git writes. Absolute paths; no `cd` chaining. Python only as `C:/Python314/python -B`. Files with
  backslashes only through the Write or Edit tool.
* Keep your context lean: read the sections you implement.

## Units

Six sequential units, each by one implementer on the session's own model with exclusive ownership of
the files it changes, each ending with the eight-step cycle green and its record
`claude/port/docs/ext-<unit>-record.md`. Each implementer's final message: result, files changed, test
counts, deviations and the "For the records" list. If the orchestrator sends "wrap up" (usage limit
near), stop adding, make the build and tests green, and write the record with what is done and what
remains.

* **D5a: the N-window binding and the sequencer's title-branch and setup states** (about 1.5 to 2 h).
  * Implements: draft B 7.2 "Open for D5" (S4): at most one shadow attached to page 0, detached and
    attached on each change of the N window, a private client copied into page 0 at its logical
    position (clipped, counted), with O1 (clearing page 0 at attach) decided with it; P1
    (`update_wover` compares the N scene window's top-level ancestor); O3 (`OBS_DLG_CREATE` with more
    than one pending window-bound slot); O2 (measure `update_n_window` and `update_wover` per event).
    Draft C C.11.2's rows that D4 left (`ext-D4b2b1-record.md` Deviation 3, minus what D4b2b2..D4c
    resolved): LoadGameFromFileDialog 1130:000E (ra 11E0:0807), CustomizeWorldDialog 1108:0243 (ra
    11E0:0826) and GR_DialogOpen exit of dialog 143 (ra 1108:0290), ShowHallOfFame 1080:0119 (ra
    11E0:0847), RunNewGameSetup 10E8:0000 (ra 11E0:020A) entry and exit, MenuZ of kind setup (ra
    10E8:0528), GR_DialogOpen exits of dialogs 144 and 151 (ra 10E8:0067, 10E8:10BE), RunTextInputDialog
    1220:16FD (ra 10E8:056F), GR_DialogClose 1098:1612 (ra 11E0:0217), the MenuZ children's
    OBS_WND_CREATE / OBS_CTL_CHECK / OBS_WND_ENABLE / OBS_WND_DESTROY (`mz_items`, `mz_sel`, Go Back
    enabled), OBS_FOCUS / OBS_EDIT on EDIT 450; C.11.3's transitions for LOAD, CUSTOM, HOF and back,
    SETUP and PLAY; C.11.4's step identification with Open C-3 settled against the Windows listing
    (RunNewGameSetup's header) or the alternative it names; C.11.6 for the new states. If S3 (draft B
    7.3) is still open and any D5 macro will draw at `leave`, resolve it here with option (a) or (b) and
    its vector; otherwise record that it stays open for D6.
  * Files: `present/dos/pdos_shadow.c/.h`, `pdos_compose.c/.h`, `pdos_scene.c/.h`, `pdos_seq.c/.h`,
    `pdos_profile.c`; tests `test_pdos_shadow.c` (S4's vector: two 512x320 logical N dialogs, a redraw of
    the lower one while the upper is the N window, then the upper's destruction), `test_pdos_compose.c`,
    `test_pdos_scene.c`, `test_pdos_seq.c` (each new state from synthesized probes; the C.11.4 cases).
  * Tests (prompt 7): 7.3 and 7.4 unchanged (no renderer is ready yet, so no DOS frame changes except
    where S4 changes which surface is page 0: record each changed expectation).
  * Record `ext-D5a-record.md`. Depends on the D4 gate.
  * Not in the unit: any drawing of the new scenes; adapter rows.
* **D5b: class R re-skins on the N canvas (`pdos_reskin`)** (about 2 h).
  * Implements: draft B 11.1; 11.2 rows Menu box (MenuZ 1220:0156 children, header from SplitMenuText,
    highlighted row from the checked or focused child), Message box (`#MsgBox` read with `w16q_msgbox` at
    `OBS_WND_SHOW`, B4, 6.4), Go Back / Cancel (P17: one extra last row with the core's button text,
    disabled colour 3); 11.3 for the N canvas (`pdos_reskin_anchor` for a scene's DOS position; clamp
    inside the canvas); 11.4 `pdos_r_hit` for frame 1; 6.1's R overlays composed at frame time (B2), a
    frameless box sampling the composed page 0; static text from the DOS program where the DOS box has
    the element (DOS-PROFILE 3.4), core text folded (10.4). The input side: draft C C.12.5 for
    re-skinned boxes through `pdos_r_hit` (control-rectangle class C, C.14.2, C.14.3), added to D4c's
    filter path for menu boxes; OPEN L28 (colour 22, y = 139) read where a D5 box can meet it.
  * Files: `present/dos/pdos_reskin.h/.c` (new), `pdos_compose.c/.h`, `pdos_profile.c` (draft B 2.1
    step 4 of `on_event`), D4c's `pdos_adapt.c` and `pdos_adapt_tab.c`, `build.cmd`/`test.cmd` for the
    new test; `tests/test_pdos_reskin.c` (new; B 15.1's N parts: row height, framed versus frameless,
    colours, highlight, the message box from a synthetic `W16qMsgBox`, `pdos_r_hit` rows and controls),
    `tests/test_input.c` (the re-skinned menu-box rows of C.15.2).
  * Record `ext-D5b-record.md`. Depends on D5a.
  * Not in the unit: the A-canvas placement at 2x, the menu bar and drop-downs, ext-D4a C1 (all D6f);
    text-entry and help-screen looks (D5d, D5e); the list box (D7).
* **D5c: the setup pages 0..2 and the T4 setup page (`pdos_scn_setup.c`), adapter I-setup**
  (about 2 h).
  * Implements: SCENES 9 preparation (R:01A8:087C, O5:0000: `DIFFS.PIC` with its palette, font 7), 9.1
    difficulty (O5:0031..0129), 9.2 competition (O5:012E..021B), 9.3 tribe (O5:0309..0587), each with
    its DOS result screen drawn when the core's MenuZ returns the choice, the core's MenuZ re-skinned as
    the frameless box at (160, 35) through D5b's anchor; draft B 11.5 (`pdos_setup_page`,
    `pdos_ui_box(PDOS_BOX_SETUP)`, the takeover without a redraw, Choice B21) and the post-Birth call
    into it (draft C C.8.7, decision 11); the scene-level DROP macros that keep the core's own drawing
    into dialog 144 out of the DOS view (draft B 7.3 "Registration"; `unexplained` stays 0); the
    adapter I-setup (C.12.7: the menu-box model on the core's MenuZ of kind setup, the difficulty
    portraits at DOS x < 135, Escape per page, the Go Back row as button 102, consumption during the
    post-Birth fade, the T4 mode with the I4 queue of C.13.6 example 4); decision 4's choice.
  * Files: `present/dos/pdos_scn_setup.h/.c` (new), `pdos_birth.c` or `pdos_seq.c` (the hand-over
    only), `pdos_scene_tab.c` (row 21's renderer field), `pdos_adapt_tab.c`, `pdos_profile.c`,
    OFFSETS.md rows (decision 2); `tests/test_pdos_setup.c` (new; B 15.1: the T4 page on a synthetic
    store, then a synthetic dialog 144 at step 0 changing only the highlight, a different Go Back text
    redrawing only its row; plus pages 1 and 2 and the result screens against hand-written vectors),
    `tests/test_input.c` (I-setup rows), `tests/harness/ext_adapt.py` (C.15.4 case 9: Escape on the
    difficulty page, a portrait click, Escape on the tribe page, the Go Back row; each against its
    Windows-form pair), `tests/harness/ext_timeline.py` (the `birth` run's "T4 setup page after the
    story", C.15.3, if D4b3 left it).
  * Tests (prompt 7): 7.8 (case 9 pairs equal in `coreinput.log` and checkpoints), 7.3 V1/V2 with the
    pages drawn, 7.4 (`ext_frames.py`), the counters of decision 8 for row 21.
  * Record `ext-D5c-record.md`. Depends on D5b and D4b3.
  * Not in the unit: the name pages and dialog 151 (D5d).
* **D5d: the name pages and the introduction text (dialog 151), adapters I-text and I-wait**
  (about 1.5 to 2 h).
  * Implements: SCENES 9.4 (O23:0173, only after the Custom path: setup step 3) and 9.5 (O23:00D6) as
    pages of `pdos_scn_setup.c`, drawn from the core's EDIT 450 text (`w16q_edit`) in the DOS box of
    SCENES 10.4 (O23:0414 look; the field's capacity is the core's EDIT limit, draft B 11.2 "Text entry";
    core text folded, B 10.4; name entry still accepts what the core accepts, prompt 5.10); the cursor
    blink as TX (C.9: 10 on, 10 off, phase restarted at each OBS_EDIT event) in `pdos_fx.c` (create it if
    D4b3 did not); SCENES 9.6 (O5:0657..07BD) for dialog 151: screen colour 15, the ornamental border
    R:0866:260E with `pdos_rand` (B 9.3 names it as a user; seeds B11), the difficulty portrait at
    (134, 20), `KING.TXT` section INIT through E's section reader with the core's names through the `$`
    tokens (R:1F4D:0471) and the core's starting advances, DGROUP:35CE, font 1 at (88, 81); adapters
    I-text (C.12.7: Ins becomes a space then Left; a left press becomes Return) and I-wait for dialog 151
    (class X, C.14.3).
  * Files: `pdos_scn_setup.c`, `present/dos/pdos_scn_init.h/.c` (new, dialog 151), `pdos_fx.h/.c`,
    `pdos_scene_tab.c` (row 27), `pdos_adapt_tab.c`, OFFSETS.md rows; tests `test_pdos_setup.c`
    (name pages, the border's generator ordinal independent of visibility as RV2-18 requires),
    `test_timeline.c` or `test_pdos_seq.c` (the cursor blink frames), `test_input.c` (I-text, I-wait),
    `ext_adapt.py` (the Custom path with a typed tribe name and Ins; dialog 151 dismissed by a key and by
    a click; each against its Windows-form pair).
  * Record `ext-D5d-record.md`. Depends on D5c.
  * Not in the unit: dialog 137's city-name box (D7; the I-text row is shared).
* **D5e: Customize World (dialog 143), its fade and help, adapter I-custom** (about 2 h).
  * Implements: SCENES 7.4 (R:01A8:0591..0792) as `pdos_scn_custom.c`: at the core's dialog 143 open
    (GR_DialogOpen exit ra 1108:0290) the TX fade to black of 5 steps (R:01A8:05B6; C.7.4, C.9: 30
    frames, +1 for the session's first fade) through `pdos_fx`, then `CUSTOM.PIC` with its palette and
    the four frameless boxes at x 200, y 1, 51, 101, 151 (DGROUP:1B48, 1B6F, 1BA0, 1BC5), the view state q
    and each box's highlight from the core's current selection in group q (C.12.7), decision 5's Cancel
    row; ShowHelpNote's dialog 135 as the DOS help screen O4:0000 (SCENES 10.3; row 116; decision 9) with
    the topic's `HELP.TXT` section; the back-to-title box over the current DOS screen after Cancel
    (C.7.4); adapter I-custom (C.12.7) with Open C-4 settled from CustomizeWorldWndProc 1108:0705 (the
    Region control ids 0x323..0x332 per group and item, the help request's control in cursor-134 mode);
    input during the fade consumed where DOS would flush it (C.9 last bullet).
  * Files: `present/dos/pdos_scn_custom.h/.c` (new), `pdos_fx.c`, `pdos_reskin.c` (the help screen, or a
    `pdos_scn_help.c`), `pdos_scene_tab.c` (rows 6, 20, 116), `pdos_adapt_tab.c`, OFFSETS.md rows; tests
    `test_pdos_custom` cases inside an existing or a new `tests/test_pdos_scn.c`, `test_input.c`
    (I-custom), `ext_adapt.py` (C.15.4 case 10: four DOS choices against four Region clicks and OK;
    Cancel; a help request), `ext_timeline.py` (a `custom` run: the fade's frames from `timeline.log`
    against the listing's 30 (+1); 7.7 style, "DOS listing (model)").
  * Record `ext-D5e-record.md`. Depends on D5b (and D5d's `pdos_fx`).
* **D5f: Hall of Fame, Load, EARTH and Quit; the P0 sweep; the gate** (about 1.5 to 2 h).
  * Implements: SCENES 7.5 (O3:002B, O3:00D7 with argument -1) as `pdos_scn_fame.c` for rows 7 and 105
    (decision 6): screen colour 15, the headings DGROUP:33BE, 33CB at (160, 16), (160, 24), the line at
    y 32, the entries from y 40 from the core's Hall of Fame data, with OPEN L7 (SCENES Open 9: the line
    layout beyond x 8 and 20) read from O3:00D7 and the palette the listing leaves; I-wait (R:1459:0918:
    any key or click); the title box drawn again over this screen on return (C.7.4, R:01A8:0807). Load
    (row 4, class W): the host chooser is outside the virtual screen (DOS-PROFILE 4 W3, 4.1), I-pass; the
    DOS view while it is open and after it (cancel: the title box again; success: SCENES 7.2's fill and
    the hold until the play frame). EARTH (row 5): whatever D4b3 left of `MAP.PIC`'s palette at Birth's
    start (O7:0049; `ext-D4b3-record.md` "Discrepancies" 5; OPEN O3: the visible effect is inferred).
    Quit (row 8): nothing beyond D4's box and D4c's Q hotkey; recorded. Then the sweep: `ext_p0.py` V1,
    V2 over every scenario and decision 7's runs, `ext_frames.py`, the counters of decision 8, and the
    gate record `ext-D5-acceptance.md` (below).
  * Files: `present/dos/pdos_scn_fame.h/.c` (new), `pdos_seq.c`, `pdos_scene_tab.c` (rows 4, 5, 7, 8,
    105), `pdos_adapt_tab.c`, OFFSETS.md rows; tests (fame layout vectors on a synthetic store),
    `ext_adapt.py` (a key and a click on the Hall of Fame against their Windows-form pairs; a cancelled
    Load), `ext_p0.py` (decision 7's runs), the counter check (decision 8).
  * Record `ext-D5f-record.md`, then `ext-D5-acceptance.md`. Depends on D5a..D5e.

## The gate record `claude/port/docs/ext-D5-acceptance.md`

* The gate table: one row per D-4 item, each with its method (compiled; headless; Win32-headless;
  agent-observed if D5f ran the optional check; DOS listing (model)) and result: the difficulty,
  competition, tribe, tribe-name and leader-name pages and dialog 151; the T4 setup page (C.20-3); each
  title branch (New Game, Load, EARTH, Customize World, Hall of Fame, Quit); the R re-skins they use
  (menu box, message box, Go Back and Cancel rows, the text entry, the help screen); the host dialogs of
  Load and Save and the overwrite confirmation as class W with the reason of DOS-PROFILE 4 W3
  (decision 10).
* 7.8: `ext_adapt.py` with the D5 pairs (C.15.4 cases 9, 10 and the units' added pairs): equal
  `coreinput.log` and checkpoints; EXT_ADAPT_OK count. P0: `ext_p0.py` P0_OK counts (Checked, with V1 and
  V2, and CheckedNoObs), EXT_G1_OK runs 77 on both Checked variants. 7.4: EXT_FRAMES_OK. The counters of
  decision 8 per D4 and D5 row. ADAPT_OK, REGISTRY_OK, NODOS_OK, `pdos_scene_check` count.
* The six unit records linked; every deviation, one line each; DOS-oracle comparisons "not run in D5
  (optional; see STATUS)"; Asan deferred; "For the records" gathered from all six records (DESIGN 12.7 and
  12.8 "As implemented (D5)", FIDELITY entries for every recorded DOS/Windows difference and choice,
  DOS-PROFILE.md rows 2..8, 16, 20, 21, 27, 105, 116 and 1.7, RUNNING, FEATURES, new checklist items).
* User checks: `manual-checklist-ext.md` D5-1 and the new D5 items left pending; "not verified" (at least
  the timing of the DOS-only waits omitted after menu choices, C.7.4; the frameless highlight on
  pictures, OPEN O4; EARTH's palette effect, OPEN O3).

## Size

About 10.5 to 12 hours of implementation in six units (D5a 1.5..2 h, D5b 2 h, D5c 2 h, D5d 1.5..2 h,
D5e 2 h, D5f 1.5..2 h), each followed by its eight-step cycle (about an hour of build and test time at
D4a's figures: `test.cmd checked` alone took 1818 s).

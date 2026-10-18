# Extension phase D5, unit D5d (the name pages, dialog 151's introduction text, `pdos_fx`; adapters I-text and I-wait) - record

Landed in the build slot on 2026-10-16 (section "Landing"; BRIEF-d5.md "Units" D5d).  Staged in `build/d5d-stage/`, first on D5c's stage and then
rebased on the tree after the D5 landing (UX1b, D5a, D5b, D5c; `build/d5l-status.txt` ALL_GREEN 01:20:28 UTC) and
the docs pass for D5a..D5c (`build/docs-d5c-done.txt`); `BASE-SHA256.txt` lists every base.  Private builds and
runs in `build/d5d-stage/obj/` only.

## Status

Landed (2026-10-16, `build/d5d-status.txt` ALL_GREEN 02:36:49 UTC; section "Landing").  With `--graphics dos` the core's two name pages (RunTextInputDialog at setup steps 3 and 4) are
shown as the DOS program's name boxes (O23), and the core's dialog 151 (the introduction text after the setup) as
the DOS program's screen O5:0657..07BD, both drawn on page 0 of the N machine.  Before D5d the DOS view stayed on
the setup page's last screen (the name pages) or showed the A frame (dialog 151).  The core and its inputs are
unchanged: P0 holds in every ext_p0 scenario privately (P0_OK checks 304; the base/D5d matrix's core traces equal in all 24
compared runs).  Dialog 151's ornamental border is the first DOS-only effect drawn with `pdos_rand` in a scene
renderer: its generator is the effect instance's (Choice B11), started only at a sequencer step, never by a
frame, a peek or a profile switch (RV2-18).

## What was built

### `present/dos/pdos_fx.h/.c` (new; C.9, draft B 9.3, Choice B11)

* The text-entry cursor's blink `PdosBlink`: 10 frames on (O23:04DE), 10 off (O23:0514) on its own frame grid,
  restarted with the cursor shown (`pdos_blink_restart`), `pdos_blink_on(t)` = (frames since the restart) mod 20
  < 10, `pdos_blink_next(t)` the next change.  Times are given; no clock is read.
* Effect instances: `pdos_fx_start(effect)` returns the next ordinal of the named effect (0 after the profile's
  reset, `pdos_fx_reset`), `pdos_fx_rand(r, effect, ordinal)` = `pdos_srand(r, pdos_effect_seed(effect,
  ordinal))`.  At most 8 effect names are counted (`PDOS_FX_EFFECTS`); a ninth shares the last counter and notes
  PDOS_DIAG_SEQ.  RV2-18: the callers start instances only in sequencer steps (below).

### The name pages (`present/dos/pdos_scn_setup.h/.c`; SCENES 9.4, 9.5, 10.4; B 11.2 "Text entry")

* While the core's RunTextInputDialog runs (PdosCore.text_active) at setup step 3 (the tribe name: only after the
  tribe page's "Custom.", C.11.4) or 4 (the leader name), the setup view's phase is `PDOS_SP_TEXT`: the screen DOS
  shows there, then the name box over it.  Step 3: the tribe page as "Custom." left it (O5:049E -> O23:0173).
  Step 4 on the Custom path: that page with the typed tribe name as the plural in colour 15 at (46, 92) and the
  right part black (O5:0587 with O23:0208's text, O5:0645); step 4 after a listed tribe: the tribe's result screen
  (O5:0587, O5:0645 -> O23:00D6).
* The box (O23:00DB..0126 leader, O23:017E..01C9 tribe): R:0000:0BFA(158, 88, 160, 32, 15), the outline
  R:1D05:0A05(..., 11), the prompt NAME_LEADER / NAME_TRIBE through R:0182:005C at (166, 90) in colour 0.  The
  field O23:0414(166, 104, max): fill (x, y, 7 max, 11, 15), outline (x, y - 1, 8 max + 8, 13, 0), background 15;
  the cells O23:06C1 from (168, 106): each an 8 x 8 fill 15 and its character (R:0182:002A, colour 0), advancing
  by its G#4 width; cells after the text are spaces.
* The field's text and caret are the core's EDIT control 450 (`w16q_edit` at probe and event steps, or the test
  query `pdos_setup_set_edit_query`), each byte folded (B 10.4).  Capacity: the DOS max (13 leader, O23:0144;
  11 tribe, O23:01E7), or the EDIT limit when smaller, grown to the text's cells + 1 up to PDOS_NAME_ROOM = 17
  (the most cells whose outline stays inside the box), the cells scrolled so the caret's cell is shown.  The
  field is redrawn when the core's EDIT changes (OBS_EDIT / OBS_FOCUS events counted by the sequencer:
  `setup_field` step, O23:06C1); a smaller capacity redraws the whole box.
* The cursor: the caret's cell (O23:073B..0756) recoloured 15 -> 11 over (x_c, 105, w_c, 10) while the blink is on
  (O23:04B9..0518), off while the field is redrawn.  The blink restarts at the page's first draw and at each
  OBS_FOCUS / OBS_EDIT event of the EDIT (its event time, C.9), and is evaluated at every sequencer step (advance
  included), so it never depends on visibility.  After the core's text page returns the box stays with the
  cursor off (as DOS leaves it) until the next page, dialog 151 or the core's MenuZ after Go Back.
* Logged steps: `setup_name` (O23:0173 / O23:00D6, arg step x 256 + custom), `setup_field` (O23:06C1, the caret's
  cell).  `pdos_setup_name_field` (tests) returns the field as drawn.  `pdos_setup_shown` is now "active and
  drawn" (D5c also required no text page).

### Dialog 151 (`present/dos/pdos_scn_init.h/.c`, new; SCENES 9.6; DOS-PROFILE row 27)

* Shown from the core's GR_DialogOpen exit ra 10E8:10BE (PdosCore.dlg_intro_text, D5a) in scene SETUP, at a core
  point only (a probe or event step), until its window is destroyed or the core leaves its setup; the setup view
  is idled.  The shadow owner "setup" claims template 151's windows as it does 144's (the core's drawing into
  the dialog is explained and never attached to page 0).
* The text (O5:0657..0719): font 1; KING.TXT's section INIT_SECTION through E's section reader (R:1F4D:044F ->
  R:1F4D:01AD into the text buffer), the tokens R:1F4D:0471 with "$US" = the core's tribe plural and "$RPLC1" =
  its leader name (O5:0660..0684, folded; the other three tokens empty), R:1F4D:0000(80) = `pdos_wrap_prepare`;
  then for each advance i < 72 the core's human knows (O5:06B6..070F, the core's own rule PlayerKnowsAdvance
  1170:3190: never for i >= 47h or player 0, else bit i mod 16 of word i / 16 of g_civKnownAdvances) the name of
  ADVANCE_NAMES record i (22 bytes, O5:06C9..06D7) and INIT_SEP, INIT_BREAK after the second (O5:06EF..0705),
  then INIT_ROADS (O5:0711).  The tribe's tune (R:01A8:046C) is sound and not modelled.
* The screen (O5:0740..07B0): R:0000:0BFA(0, 0, 320, 200, 15); the ornamental border R:0866:260E (`pdos_border`,
  its tile set from the generator of instance `ordinal` of effect "border"); the core difficulty's portrait from
  page 1 (DIFFS.PIC: x 80 for an odd level, else 21; y 35 d + 6; 53 x 47) copied to (134, 20) (O5:0766..0799,
  G#20); the text through R:1F4D:0088(99, 88, 81, 0) = `pdos_wrap_draw` in colour 0.  Page 2 holds SP299.PIC's art
  from the post-Birth step R:01A8:0576 (and the profile's start), the border's tile source.
* The core's state is read with w16q_* under CIV_OBSERVER (g_humanPlayer, g_difficultyLevel, g_leaderNames,
  g_civPluralNames, g_civKnownAdvances) or the test query `pdos_init_set_query`; unread, the screen is drawn
  without names, advances or portrait and PDOS_DIAG_SEQ is noted.
* RV2-18: `pdos_fx_start("border")` runs only in `pdos_init_sync` at a core point, which `pdos_setup_sync` calls
  first at every sequencer step (on_event, on_probe, advance), whether the DOS profile is shown or not; frame(),
  peek() and a profile switch draw nothing and start nothing.  Step `init_text` (O5:0657, arg the ordinal).

### The input side (`pdos_adapt.c/.h`, `pdos_adapt_tab.c`, `gen/dos/adapters.py`; C.12.7, C.14.3)

* Scene bits PDOS_AS_TEXT (a name page: core READY while the core's text page runs at the page's step with its
  EDIT focused, else WAIT) and PDOS_AS_WAIT (dialog 151's view, its window `x_hwnd` for class X); action bits
  PDOS_AA_INS (Ins) and PDOS_AA_EDIT (a printable key, Left, Right, Del, Backspace); step actions PDOS_A_SPACE
  and PDOS_A_LEFT.
* Rows (83 in all, ADAPT_OK rows 83 steps 21): I-text/ins/core-ready (Space then Left, now), I-text/edit/core-ready
  (passed: the editing keys, Return, Escape), I-text/press/core-ready (Return, its release consumed), I-text/other
  (consumed); I-wait/mod (consumed), I-wait/key (passed), I-wait/press (passed in class X at dialog 151's window,
  else the movie's), I-wait/right (consumed).  DOS-PROFILE 1.7.2 regenerated by the staged adapters.py.

### Scene table and registry

* `pdos_scene_tab.c` row 21: timelines TX | TS (the cursor blink); row 27 (dialog 151): PDOS_RD_SCRIPT.
  DOS-PROFILE row 21's text: "TS + TX (cursor blink 10 frames) | I-setup, I-text" and the name boxes O23:0173,
  O23:00D6.
* `gen/dos/registry.py`: OBSERVER_FILES += `pdos_scn_init.c`.  `pdos_registry.h/.c` and `tests/dos-decoded.txt`
  regenerated (159 files, 26 tables; 1345 lines).

## F2 / F5 per call site (BRIEF-d5.md)

* **Name pages** (O23:00DB..0126, O23:017E..01C9, O23:0414, O23:06C1, O23:04B9..0518): F2 not applicable (no G#18;
  the calls are R:0000:0BFA fills, R:1D05:0A05 outlines, R:0182:005C / R:0182:002A text and the cursor's
  recolour); F5 none (no copy).  The screen below the box is D5c's setup-page replay (its F2/F5 as recorded in
  ext-D5c-record.md).
* **Dialog 151** (O5:0740..07B0): F2 not applicable (no G#18).  F5: none.  Its copies are the border's 8 x 8
  tiles from page 2 ([19E8], R:0866:2649..277D) and the portrait from page 1 ([19D4], O5:0799, G#20); G#31 draws
  the ghost pointer on the screen page only, never on pages 1 or 2.

## OFFSETS.md rows (ruling 2)

NAME_LEADER DGROUP:53AB (reader O23:0122), NAME_TRIBE 53B8 (O23:01C5), INIT_SECTION 35C3 (O5:0691), INIT_SEP 35C9
(O5:06DF), INIT_BREAK 35CC (O5:06F8), INIT_ROADS 35CE (O5:0711) (strings) and ADVANCE_NAMES 04DA (1584 bytes = 72
records of 22, reader O5:06CF).  No writer found for any.  Regenerated: `present/dos/pdos_registry.h/.c`,
`tests/dos-decoded.txt` (REGISTRY_OK; nodos OK).

## Tests

* `test_pdos_setup.c` (94 checks, was 50), on the real DOS store, structural checks only: the tribe name page over
  the Custom. tribe page (page 0 equal to it outside the box; the box's colours 15 / 11 / 0; the prompt; the
  field's outline and fill; an empty 11-cell field with the cursor on cell 0 at the first draw); an EDIT event:
  the field redrawn (`setup_field`), three cells; the blink at frames 9, 10, 20, 29, 30 after the event (core
  points and advance steps); 20 characters: 17 cells from cell 4; shorter again: the box redrawn (the longer
  outline gone); the text page returned: the box kept, the cursor off; the leader name page over the typed
  plural (colour 15 only on the left part, x >= 150 black outside the box); the leader name page over a listed
  tribe's result screen.  Dialog 151: not started at an advance step; at a core point shown, the setup view gone,
  `init_text` instance 0; the leader once and the plural twice in the text; the text's tail exactly advances 1,
  3, 40 with the separators, the break after the second and the closing text, not advance 71 (47h); the portrait
  equal to page 1's source; the screen mostly colour 15, text pixels in colour 0, the border's corners and edges
  page 2's tiles of one set; more steps start nothing; the window destroyed ends it; a second dialog: instance 1,
  player 0 lists no advance; play ends it; after the profile's reset instance 0 again with the same pixels; an
  unread core state still shows the screen without the names.  The owner claims template 151.
* `test_timeline.c` (158, was 148): the blink over 2000 frames, before its restart, the next changes, a restart
  in the off phase; the effect counters (per name, the reset, a long name, the shared ninth with its
  diagnostic); instance k's generator = `pdos_srand(pdos_effect_seed(effect, k))`, another instance's differs.
* `test_pdos_seq.c` (172, was 170): dialog 151's view starts at the GR_DialogOpen exit step through the sequencer
  (one "border" instance, its generator calls) and ends at the window's destruction; C.15.1 item 7 restated for
  the whole sequencer test: every DOS generator call is an effect instance's (dialog 151's border).
* `test_input.c` (336 / 309 / 336, was 293 / 266 / 293): the 8 I-text / I-wait row vectors; `adapt_text_wait`: Ins
  posts Space (with its character) and Left; 12 keys passed or consumed by row; the core not ready consumes keys
  and presses; a press posts Return; dialog 151's press at its window in class X, its release passed; the
  movie's window without `x_hwnd`; a key passed whatever the core's state.  Row count 83.
* `tests/harness/ext_adapt.py` (C.15.4 case 9): d-text-custom (Custom. by Escape, A, b, Ins, Return on the tribe
  name page, Return on the leader name page <-> the same with Space and Left at the Ins press), d-wait-key
  (Return through the pages, X on dialog 151), d-wait-click (a press on dialog 151 <-> a press at the point the DOS
  run gave the core; its release where the DOS run's went: the press ends the wait and dialog 151's view, so the
  release meets the A frame and keeps its own point, C.12.2).  `d_info` records the releases' points (`lup`).

## Results (private, `build/d5d-stage/obj/`)

* Strict c11 / c17 / clang C99 of every changed product source (pdos_fx.c, pdos_scn_init.c, pdos_scn_setup.c,
  pdos_adapt.c, pdos_adapt_tab.c, pdos_registry.c, pdos_scene_tab.c), Checked, CheckedNoObs, Release: CC_STRICT_OK.
  `cc all` (every portable source, the 45 test programs, the harness, civ64.exe) in the three variants: CC_ALL_OK.
* Unit tests, three variants: all pass but test_dos, which reads the tree's tests/dos-decoded.txt (its output
  equals the staged golden; 23,215 checks).  Counts: above.
* lint (the tree's obs_lint.py over the overlay): OBS_LINT_OK files 105.  registry: gen unchanged, REGISTRY_OK.
  adapters: ADAPT_OK rows 83 steps 21.  obs_tables --check over the staged DOS-PROFILE.md: OBS_TABLES_OK probes
  203 sites 98.  pdos_scene_check over the staged files: PASS 1075 checks.  nodos over the staged files and the
  private binaries of three variants: 0 hits.
* ext_p0 (the tree's script, `--exe` the private Checked harness, `--root` obj/p0r): **P0_OK checks 304**.  Its
  presentation-diag.log against the landed tree's Checked outputs: only `pdos unexplained` lower by 8 in 25 runs
  (V1, V2, V7, V8, V8s of new, earth, custom, settlers; V1, V2, V6, V6w, V7 of s3: 615 -> 607, 541 -> 533,
  580 -> 572, 610 -> 602): the core's drawing into dialog 151 is the owner's.  profiles.log: all equal.
* The base/D5d matrix (obj/hpriv.py: the landed tree's sources against the stage's, V1's options with
  `--profile-samples 100`, 24 scenarios): P0 PASS in all; Windows samples equal everywhere; DOS samples differ in
  new, s3 and settlers from 30.6 to 36.0 s, earth from 32.6 to 38.0 s and custom from 36.6 to 42.0 s (55 samples
  each): the leader name page (setup_name O23:00D6 at 30.5 s in new; the field redrawn with each typed key) and
  dialog 151 (init_text at 33.5 s in new, s3, settlers; 34.5 s earth; 38.5 s custom) where the base showed the
  setup page's last screen and then the A frame; equal again once the game starts.  The other 19 scenarios: no
  difference.  The Birth goldens (start 6 frames, Birth 8 frames up to frame 12000): all equal.
* ext_timeline both groups (`--exe`, `--root` obj/tlr): EXT_TIMELINE_OK, EXT_TIMELINE_OK.  ext_continue
  (`--root` obj/cont): EXT_CONTINUE_OK (31 checks).  ext_bs assets and mirror (`--root` obj/bsr): EXT_BS_OK,
  EXT_BS_OK.
* ext_adapt case 9 (the staged copy through obj/adapt_case9.py, outputs under obj/adapt): ADAPT_CASE9_OK, the
  seven pairs (D5c's four and D5d's three) equal to their Windows-form pairs and decided by the expected rows
  (21 checks).
* Not run privately (they have no output redirection): ext_frames, ext_mirror, ext_zoom; D5d changes no map-layer
  or mirror code.

## Expected changes at the build slot (DOS frames)

1. **ext_p0** (test.cmd): P0 unchanged.  presentation-diag.log: `pdos unexplained` 8 lower in the 25 runs listed
   above (new / s3 615 -> 607, earth 541 -> 533, custom 580 -> 572, settlers 610 -> 602); no new diagnostic field.
   The DOS frames of the runs that reach the name pages and dialog 151 change from the name page on (the private
   samples above); test.cmd's ext_p0 writes no samples.
2. **ext_adapt**: EXT_ADAPT_OK checks 68 -> 77 (three new pairs, three PASS lines each).
3. **ext_frames**: presented.log lengths of the runs that reach the name pages (s3; birth does not) may change;
   every A against A' comparison holds (both runs draw the same).
4. **adapters-check** rows 75 -> 83, steps 19 -> 21; **dos-decoded.txt** and registry-check: the 7 rows;
   **obs-lint** files 101 -> 105; nodos: four files more; build.cmd: 285 portable sources.
5. ext_timeline, ext_continue, ext_bs, the Birth goldens: unchanged.

## Build-slot steps

1. Copy the staged files onto the tree (BASE-SHA256.txt: every base is the tree's file now; DOS-PROFILE.md is the
   docs pass's with row 21 and 1.7.2 regenerated: if the tree's file moves again, take it, put this stage's row
   21 line in and run `gen/dos/adapters.py gen`).  Run `gen/dos/registry.py gen` + `check` (unchanged output
   expected), `gen/dos/adapters.py check`, `gen/obs_tables.py --check`, `gen/dos/nodos.py check`.
2. The three-step cycle: `build.cmd checked`, `test.cmd checked`, `ext_g1.py check` (no test.cmd / build.cmd
   change; the counts of BUILD-TEST-ADDITIONS.md).
3. Compare with "Expected changes"; then the user build.

## Decisions and deviations

* **Capacity** (B 11.2): the field shows the DOS max or the core's EDIT limit when smaller, grown with the core's
  text up to 17 cells and scrolled to the caret (a port choice: the core accepts every character, prompt 5.10;
  DOS refuses keys past its max).
* **Ins**: DOS inserts a space at the caret and keeps the caret (O23:0599..05D2); the port posts Space then Left,
  so the core's EDIT does the same unless text is selected (the core selects its whole text at the start: then
  the space replaces it).
* **The first key**: DOS clears the field at the first printable key (O23:064B..0669); the core's select-all has
  the same effect, and the field always shows the core's EDIT text.
* **Mouse**: a left press accepts the field (Return) and ends dialog 151's wait (passed, class X); the right
  button is consumed on both (DOS takes any button, [DB3A]; C.12.7 passes the left press only).  The I-wait
  press's release meets the A frame (the press ends the view) and keeps its own point (C.12.2).
* **The blink** is evaluated at sequencer steps (advance included): each change shows at the first step at or
  after its frame edge.
* **The box after the text page** stays drawn with the cursor off until the next page, dialog 151 or the core's
  MenuZ.
* **Dialog 151**: the tokens other than $US / $RPLC1 are empty (what DOS last stored there is not modelled); the
  tribe's tune is not modelled; the text buffer DGROUP:BA06's size is not modelled (2048 bytes, every text
  fits); an unread core state draws the screen without names, advances or portrait and notes PDOS_DIAG_SEQ.
* **C.15.1 item 7** (test_pdos_seq): restated from "the sequencer never calls the DOS generator" to "only through
  effect instances": dialog 151's border is a scene renderer's DOS-only effect (B 9.3 names R:0866:260E as a
  user; B11 seeds it).  The intro and Birth programs still never call it (test_timeline's stub rule unchanged).
* `pdos_setup_shown` is "active and drawn": the name pages are part of the setup view; D5c's check "the text page
  hides the view" became the name-page checks.

## What the user checks (DOS graphics, after landing)

Start a new game with the DOS graphics, then on the setup pages:

1. **Tribe name** (choose "Custom." on the tribe page, or press Escape there): the tribe page stays and a white
   box with a light blue border appears at the right, with the name prompt and an input field outlined in black;
   the cursor cell blinks in light blue (about 3.5 times a second).
2. **Typing**: letters appear in the DOS font in the field; Backspace, Delete, Left and Right edit; Ins inserts a
   space; a long name scrolls inside the box; Return or a left click accepts; Escape behaves as the core does.
3. **Leader name**: after a typed tribe name the left part shows that name in white above the portraits and the
   right part is black, with the leader box over it; after a listed tribe, the leader box is over the tribe's
   result screen.  The core's suggested name is in the field.
4. **Introduction text** (after the leader name): a white screen with the ornamental border, the chosen
   difficulty's portrait at the top centre and the introduction text in black with the leader's name and the
   tribe's plural, followed by the starting advances and "and Roads."; any key or a left click goes on to the
   game.
5. **Switching profiles** on these screens: the Windows profile shows the core's dialogs; back on DOS the same
   DOS screens (the same border).

## For the records

* FIDELITY: the name pages and dialog 151 transcribed from the DOS listing (O23:00D6..0756, O5:0657..07BD) with the
  capacity, Ins, first-key, mouse and blink deviations above; the tokens and the tune of dialog 151 not modelled.
* FEATURES / STATUS: the DOS name pages and the introduction text under `--graphics dos`; the D5 setup path is
  DOS from the T4 page to the game's start.
* The manual checklist: the five user checks above.
* DESIGN (B 9.3, B 11.2, B 7.5; C.9, C.12.7, C.14.3, C.15.1 item 7): `pdos_fx` (blink and effect instances),
  `pdos_scn_init`, the owner "setup" claims templates 144 and 151, I-text / I-wait rows, item 7 restated.
* RUNNING: the counts of BUILD-TEST-ADDITIONS.md; ext_adapt 77 and the three new pairs; 285 portable sources.
* DOS-PROFILE: 1.7.2 regenerated (83 rows) and row 21's text; row 27 unchanged in text.

## Landing (build slot, 2026-10-16)

D5 stager, in the build slot after the coordinator accepted D5d (the docs pass for D5a..D5c had finished:
`build/docs-d5c-done.txt` 01:42:51 UTC; no docs agent running).

* **Copy** (02:15:28 UTC, `build/d5d-prep/land.py`): the 22 files of `build/d5d-stage/BASE-SHA256.txt`, each
  only while the tree's file still had its listed base SHA-256 and the staged copy its listed SHA-256 (the four
  new files had to be absent).  Every base matched, so nothing was rebased.  Manifest
  `build/d5d-prep/landed.sha256`; the tree's previous files in `build/d5d-prep/tree-before/`; the landed tree's
  Checked outputs before the cycle (559 files) in `build/d5d-prep/before/`.
* **Generators and checks** before the cycle: `gen/dos/registry.py gen` (unchanged output: 159 files, 26
  tables) and `check` REGISTRY_OK; `gen/dos/adapters.py check` ADAPT_OK rows 83 steps 21; `gen/obs_tables.py
  --check` OBS_TABLES_OK probes 203 sites 98; `tests/harness/pdos_scene_check.py` PASS (1075 checks).
* **Cycle** (`build/d5d-prep/d5d-cycle.ps1`; each step waits on its own cmd.exe process only):
  1. `build.cmd checked`: exit 0, 205 s (02:15:57..02:19:22 UTC), BUILD_OK (285 portable sources);
  2. `test.cmd checked`: exit 0, 1047 s (02:19:22..02:36:49), TESTS_OK (24 sections, 0 failed);
  3. `ext_g1.py check`: EXT_G1_OK runs 77 (amended 1).
  `build/d5d-status.txt` ends ALL_GREEN; logs `build/d5d-1-build-checked.log`, `build/d5d-2-test-checked.log`,
  `build/d5d-3-g1-checked.log`.
* **Against "Expected changes at the build slot"** (`build/d5d-prep/compare.py`, output
  `build/d5d-prep/compare-out.txt`: the cycle's Checked outputs against the snapshot):
  1. P0_OK checks 304.  presentation-diag.log: only `pdos unexplained` changed, 8 lower in 34 runs: the 25
     ext_p0 runs predicted (custom 580 -> 572, earth 541 -> 533, new / s3 615 -> 607, settlers 610 -> 602) and 9
     runs of the other harness sections whose runs also reach dialog 151 (ext_adapt's chords, plain, ring,
     ringref, zoomkeys and ext_frames' frames74 A, A2, B, C of s3: 615 -> 607), the same cause (the owner claims
     dialog 151's drawing).  No other field changed (pmap timing fields only, run-to-run noise).
  2. profiles.log: the four frames74 runs of s3 differ in content with equal line counts.  The prediction said
     test.cmd's runs record no samples; ext_frames' runs do, and their DOS samples change from the leader name
     page and dialog 151 on, as in the private matrix.  Every other profiles.log is equal.
  3. ext_adapt: EXT_ADAPT_OK checks 77 (was 68); d-text-custom, d-wait-key and d-wait-click PASS.
  4. ext_frames: EXT_FRAMES_OK; s3's presented.log 672 -> 689 lines (tick shows 643 -> 656), A equals A'.
  5. adapters-check ADAPT_OK rows 83 steps 21 (was 75 / 19); dos-decoded.txt the 7 new rows; registry-check 25
     more ok lines; obs-lint OBS_LINT_OK files 105 (was 101); nodos 1687 files (was 1680), 0 hits.
  6. Unchanged as predicted: EXT_TIMELINE_OK (both groups), EXT_CONTINUE_OK, EXT_BS_OK (assets, mirror),
     MIRROR_OK runs 29, ZOOM_OK, the Birth goldens.
  7. Informational: coverage.txt "other functions entered" 665 -> 661.  This count varies between cycles (the
     build logs hold 659 to 665 for earlier cycles, 661 the most frequent); it is not a test result.
* Not run in this landing: the CheckedNoObs and Release cycles (the three-step cycle only) and Asan (deferred).

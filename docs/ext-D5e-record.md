# Extension phase D5, unit D5e (Customize World: dialog 143's transition, its four questions and the DOS help screen; adapters I-custom and the help screen's I-wait) - record

Landed in the build slot on 2026-10-16 (section "Landing").  Staged in `build/d5e-stage/` on the tree after the D5d landing (`build/d5d-status.txt` ALL_GREEN 02:36:49 UTC;
BRIEF-d5.md "Units" D5e).  D6a landed into the tree during the staging (03:47..03:48 UTC, `build/d6a-status.txt`
ALL_GREEN 04:10:15 UTC); none of its files is a D5e file; every base was checked again and every private build and
run below was repeated on the tree after it.  `BASE-SHA256.txt` lists every base.  Private builds and runs in
`build/d5e-stage/obj/` only.

## Status

Landed (2026-10-16, `build/d5e-status.txt` ALL_GREEN 04:58:43 UTC; section "Landing").  With `--graphics dos` the core's Customize World (CustomizeWorldDialog,
dialog 143) is shown as the DOS program's Customize screens (SCENES 7.4, R:01A8:0591..0792): the title's screen
fades to black, CUSTOM.PIC appears and the four questions are asked in frameless menu boxes at (200, 1 + 50q), each
with the core's current choice highlighted; the DOS help screen O4:0000 (SCENES 10.3) answers a help request.
Before D5e the DOS view showed the A frame (rows 6 and 20 were replays without a renderer).  The core and its
inputs are unchanged: P0 holds privately (ext_p0 Checked P0_OK checks 304, as the tree's D6a cycle; the presentation-diag.log counters change only in the `custom` run of the DOS variations).

## What was built

### `present/dos/pdos_scn_custom.h/.c` (new; SCENES 7.4, 10.3; DOS-PROFILE rows 6, 20, 116)

* Phases: NONE; WAIT (CustomizeWorldDialog entered from the title, dialog 143 not yet open: rows 6 and 20 ready,
  page 0 - the title's screen with the chosen row - kept, so no A frame shows between the title and the
  transition); FADE (the transition); ASK (question q's box); HELP (the help screen); DONE (dialog 143 closed: the
  screen stays to the core's next scene).
* The transition: a timeline program of its own on the DOS session (sequence PDOS_SEQ_FX_FADE, the step log's
  sequence 3): `custom` R:01A8:0591 (the pointer hidden, R:01A8:0268; the disk check R:01A8:02A4(7, 1L) has no
  output), the fade R:0000:04D4(5, 0, 0, 0) to black at R:01A8:05B6 ([D762] VGA): 30 frames (M5) and one more for
  the session's first fade (M4; the intro has no fade, so the first Customize of a run has 31), then the fill
  black R:01A8:05D1, CUSTOM.PIC with its palette into page 1 R:01A8:05E1 (R:1FA1:0220; R:01A8:02A4(0, 1L) no
  output), G#20 page 1 to the screen R:01A8:0611 (`custom_pic`) and the pointer shown R:01A8:0619 (`pointer`).
  The tail runs at once when the core's dialog ends, the core asks for help or the core leaves Customize during the
  fade.
* The questions (R:01A8:061D..0792): the registry strings CUSTOM_LAND, CUSTOM_TEMP, CUSTOM_CLIMATE, CUSTOM_AGE
  (DGROUP:1B48, 1B6F, 1BA0, 1BC5, copied to BA06 at R:01A8:0633, 0690, 06ED, 074A) split at their line feeds and
  drawn with the menu-box model (R:0238:0008(BA06, 200, y), y = 1, 33h, 65h, 97h: y odd, frameless; h8 as at the
  title) over the picture.  The current question's box has an added Cancel row (ruling 5) with dialog 143's button
  0x66 text ('&' marks removed, folded to DOS bytes; "Cancel" when the core is unread); when the view moves on,
  the left box is restored from page 1 and drawn again without it.  Every drawn box's highlight is the core's
  selection of its group (g_worldParams, VA 12D8:38F4, 4 x i16, read with w16q_rd16 at core points; C.12.7).
  Row map: item i of question q is Region control 0x323 + 4q + i; the Cancel row PDOS_CUSTOM_ROW_CANCEL.  The
  fourth box (y 151) has its five lines ((192 - 151) / 8).
* The next question: the adapter's view action PDOS_AV_CUSTOM after each DOS choice (`custom_next`, R:0238:0008 of
  the next question); after the fourth the boxes stay.
* The help screen (O4:0000): when the core's dialog 135 (ShowHelpNote -> ShowTextNoteDialog) is created during the
  questions, at the next step: the name HELP_PREFIX (DGROUP:34B0) + the question's topic upper-cased (CUSTOM_HELP_*,
  DGROUP:1B6A, 1B94, 1BBD, 1BFE; R:2045:298A), HELP.TXT's section by that name (R:1F4D:01AD; none: no screen,
  `help_none`, O4:0045), the screen saved (R:0866:25B6), filled with colour 2 (O4:0065), the name centred at
  (160, 192) in colour 0 (R:0182:00B3), the section in 32 columns from (32, 32) in colour 15 (R:1F4D:0088;
  `help`).  At the dialog's destruction the screen is restored (O4:009B: R:0866:25D7, `help_end`) and the
  question asked again; after the fourth question's help the third (R:01A8:0789..078C: jmp 072F), as in DOS.
* The end: dialog 143 destroyed: DONE (`custom_end`, R:01A8:078E; a help screen still shown is restored first);
  the core's next scene (the title again after Cancel, or the outro and Birth after OK): NONE, rows 6 and 20 not
  ready.  The pointer is hidden during the transition and the help screen.
* The owner "setup" (pdos_scn_setup.c) claims template 143 and, while the view runs, 135: their drawing is the
  owner's, never page 0's.

### The sequencer (`pdos_seq.c`)

* CustomizeWorldDialog's entry in the title: `pdos_custom_enter` (WAIT).  GR_DialogOpen's exit at ra 1108:0290
  (dialog 143) in the Customize scene: `pdos_custom_open` (the transition starts; a probe step reads the core).  A
  dialog 143 or a CustomizeWorldDialog out of its scene is counted (D5a) and starts no view.
* The view runs at each `run_to` (before the setup check), is synced at each step (`pdos_custom_sync`; core points
  read the core), sees dialog 135's creation and destruction (`pdos_custom_on_event`), is abandoned with the other
  views (C.11.6), logs to the step log (sequence 3) and joins the pointer rule.

### The input side (`pdos_adapt.c/.h`, `pdos_adapt_tab.c`, `gen/dos/adapters.py`; C.12.7)

* Scene bits PDOS_AS_CFADE (the transition), PDOS_AS_CUSTOM (questions 1..3), PDOS_AS_CUSTOM3 (the fourth),
  PDOS_AS_HELP (the help screen); the scene words of PdosAdaptRow and PdosAdaptSc widened to uint32_t.  Action
  bits PDOS_AA_CANCEL and PDOS_AA_HELP; the view PDOS_AV_CUSTOM; step actions PDOS_A_REGION (a click at dialog
  143's control 0x323 + k, class C) and PDOS_A_CANCEL (button 0x66); PdosAdaptSc.cq (the question); hooks
  `custom_ctl` and `custom_next` (appended).
* Core READY in the questions: dialog 143 open and the view's box shown.  The core's help dialog open without a DOS
  screen (HELP.TXT without the topic's section) is the HELP scene: the next key or left press closes it.
* Keys: Up and Down select the item above or below (no wrap; the Cancel row by the mouse only; otherwise EDGE),
  an item's hotkey selects it, Return and Space choose the highlighted item, Alt+H requests help (R:1D05:03E3 ->
  0386); the right button requests help (R:1D05:0180); a left press is a drag whose release in an item's row
  chooses it, in the Cancel row cancels, elsewhere asks again.
* Rows (95 in all, ADAPT_OK rows 95 steps 24): I-custom/fade (consumed), I-custom/help/core-ready (the group's help
  region 0x326 + 4q), I-custom/cancel/core-ready (button 0x66), I-custom/choose/core-ready (the item's Region, then
  the next question), I-custom/choose-last/core-ready (the Region, then Return: the core's OK), I-custom/select/
  core-ready (the Region only), I-custom/press (the drag), I-custom/other (consumed: Escape, the edges, outside the
  box, any other key or button, and everything while the core is not ready); I-wait/help-mod (consumed),
  I-wait/help-key and I-wait/help-press (Return: the core's note closes), I-wait/help-other (consumed).
  DOS-PROFILE 1.7.2 regenerated by the staged adapters.py (its preamble names the I-custom rows and the help
  screen; the scene, view and step names).

### Scene table and registry

* `pdos_scene_tab.c` rows 6 and 20: PDOS_RD_SCRIPT (pdos_scn_custom; their DOS-PROFILE text already reads as the
  view does: no change); row 116's comment.
* `gen/dos/registry.py`: OBSERVER_FILES += `pdos_scn_custom.c`.  `pdos_registry.h/.c` and `tests/dos-decoded.txt`
  regenerated (159 files, 35 tables; 1354 lines).

## F2 / F5 per call site (BRIEF-d5.md)

* **Customize** (R:01A8:05D1 fill, 05E1 into page 1, 0611 G#20 page 1 to the screen, R:0238:0008's frameless boxes:
  R:1D05 text and recolour; the port's restore of a left box from page 1): F2 not applicable (no G#18).  F5 none:
  the copies go from page 1 to the screen page; G#31 draws the ghost pointer on the screen page only, never on
  page 1.
* **Help screen** (O4:0065 fill, O4:007C name, O4:008E text, R:0866:25B6 / 25D7 save and restore: a memory copy of
  the screen page): F2 not applicable (no G#18).  F5 none.

## OFFSETS.md rows (ruling 2)

CUSTOM_LAND DGROUP:1B48 (reader R:01A8:0633), CUSTOM_TEMP 1B6F (R:01A8:0690), CUSTOM_CLIMATE 1BA0 (R:01A8:06ED),
CUSTOM_AGE 1BC5 (R:01A8:074A), CUSTOM_HELP_LAND 1B6A (R:01A8:0666), CUSTOM_HELP_TEMP 1B94 (R:01A8:06C3),
CUSTOM_HELP_CLIMATE 1BBD (R:01A8:0720), CUSTOM_HELP_AGE 1BFE (R:01A8:077D) and HELP_PREFIX 34B0 (O4:0006), all
strings; no writer found for any.  Regenerated: `present/dos/pdos_registry.h/.c`, `tests/dos-decoded.txt`
(REGISTRY_OK; nodos OK).

## Tests

* `test_pdos_setup.c` (126 checks, was 94), on the real DOS store, structural checks only: the entry (rows 6 and
  20 ready, page 0 kept, nothing read); the transition from a white DAC: the picture at frame 31 (30 + 1), the
  DAC CUSTOM.PIC's palette, page 1 CUSTOM.PIC; question 1 frameless at (200, 1) with three items and the Cancel
  row ('C' its key), the highlight the core's 1, the row map, page 0 the picture outside the box; the highlight
  following the core only at core points; the next question: question 1 drawn again smaller (no Cancel row),
  question 2 at (200, 51) with the row map 4 + i, page 0 the picture outside both boxes; the core's dialog 135
  (the owner's): the help screen (HELP.TXT's section found; rows 0..31 colour 2, colour 15 text, colour 0 name at
  y 192), drawn once, the screen restored at the destruction, question 2 again; the fourth question (five lines,
  row map 12 + i) and its help asking the third again; dialog 143 closed: DONE, then the core's next scene: NONE,
  rows not ready; a second transition in the session: 30 frames, the core unread (no highlight, "Cancel", one
  diagnostic); a help request during the transition; a scene change during it (the picture at once).  The owner
  claims template 143, not 135 outside the view.
* `test_pdos_seq.c` (179, was 172): the view at CustomizeWorldDialog's entry (WAIT, rows ready, the pointer
  shown), its transition at dialog 143's open (the pointer hidden), DONE at the destruction, NONE at the title
  again and at the outro after OK; dialog 143 out of its scene starts none (the counts of D5a unchanged).
* `test_input.c` (377 / 350 / 377, was 336 / 309 / 336): the 12 I-custom / I-wait row vectors; `adapt_custom`:
  Space and a drag's release choose (the Region 0x323 + 4q + i at the control's point, the next question once);
  the fourth question's Return (the Region, then Return); Down, Up and the hotkeys select only, the edges and the
  Cancel row's hotkey are consumed; the right button and Alt+H click the help region 0x326 + 4q (another Alt key
  consumed); the Cancel row's release clicks 0x66, a release outside the box and Escape are consumed; the core not
  ready or no Region window: the whole action consumed, no next question; the transition consumes presses and
  characters; on the help screen a key or a left press posts Return once (repeat, character and releases
  consumed).  Row count 95.
* `tests/harness/ext_adapt.py` (C.15.4 case 10, from the title's hotkey c and Return): d-custom-choices (Return,
  Down and Return, a drag's release on question 3's item 0, Return <-> five Region clicks at the points the DOS
  run gave the core, then Return: the core's OK, after-worldgen reached), d-custom-cancel (the Cancel row <->
  button 0x66: the title again), d-custom-help (the right button, X on the help screen, Return <-> the help
  region's click, Return, a Region click).  `d_info` keeps every produced click (`clicks`); each case checks
  their number.
* `tests/harness/ext_timeline.py`: the `custom` run (host input: X at 1 s, the hotkey c and Return, four Returns)
  and its checks: the transition's frames (the picture and the pointer at frame 31, "DOS listing (model)"), the four
  decisions and the next questions at their instants, `custom_end`, then Birth; every show from the title choice on
  the 320x200 N frame.

## Results (private, `build/d5e-stage/obj/`)

On the tree after D6a's landing (`obj/src-base` the tree's sources, `obj/src` with this stage's; every output
under `obj/`, three variants unless named):

* **Compilation**: the strict c11 + c17 /W4 /WX compile and the clang C99 parse of every changed and new source in
  Checked, CheckedNoObs and Release: CC_STRICT_OK; every portable source with the tests, the harness (not Release)
  and civ64.exe: CC_ALL_OK.
* **Unit tests** (test.cmd's unit loop over the private binaries): all pass in the three variants (test_pdos_setup
  126, test_pdos_seq 179, test_input 377 / 350 / 377) except test_dos, which reads the tree's
  `tests/dos-decoded.txt`: its output equals this stage's golden (23,224 checks; "decoded content differs" only for
  the nine new rows).
* **Generators and checks**: OBS_LINT_OK files 108 probes 203 callsites 98; REGISTRY_OK (dos-decoded 1354 lines,
  35 tables); ADAPT_OK rows 95 steps 24; OBS_TABLES_OK probes 203 sites 98; pdos_scene_check PASS 1075 checks;
  NODOS_OK (163 files: this stage's and the private binaries, 0 hits).
* **ext_adapt** (C.15.4 cases 9 and 10 with this stage's runner, `obj/adapt`): 10 pairs, 30 PASS, every DOS-form run
  equal to its Windows-form pair in `coreinput.log` and checkpoints; case 10: d-custom-choices (coreinput 21,
  after-worldgen reached), d-custom-cancel (7, the title again), d-custom-help (12).  In the three case 10 runs only
  the start-up frame is an A frame (presented.log against the Windows form's frames); their counters:

  | Run | unexplained | w_over_n | bad_handles |
  |---|---|---|---|
  | d-custom-choices | 540 | 2 | 0 |
  | d-custom-cancel | 532 | 2 | 0 |
  | d-custom-help | 530 | 1 | 0 |

  (520 of them in every run are the intro's, as in the base's `start`.)
* **ext_timeline** (this stage's script, `--port` the tree, goldens the tree's): group base EXT_TIMELINE_OK, 41 PASS
  (`custom`'s four among them); group bs EXT_TIMELINE_OK.
* **ext_continue** EXT_CONTINUE_OK; **ext_bs** assets and mirror EXT_BS_OK (the tree's scripts on the private build).
* **ext_p0** Checked (the tree's runner, -j 2, `obj/p0r`): P0_OK checks 304.  Against the tree's own outputs
  (`build/harness/Checked/p0`, D6a's cycle) the presentation-diag.log counters differ only in `custom` of V1, V2, V7,
  V8 and V8s: `pdos.unexplained` 572 -> 534, `pdos.w_over_n` 1 -> 2 (timing counters of pmap aside); profiles.log
  equal in all 90 runs that write one.  CheckedNoObs (V5) is left to test.cmd (that build has no DOS profile: "The DOS
  graphics are not in this build").
* **Base against D5e** (`obj/hpriv.py`: both private builds, the 24 P0 scenarios with `--graphics dos` and samples):
  the core traces equal in all 24; the DOS samples equal except `custom` (50 of 459 differ, from 22.6 s: the
  Customize screens instead of the frozen title); the 14 model golden frames of ext_timeline equal.

## Expected changes at the build slot (DOS frames)

* `ext_p0.py` (Checked): P0_OK checks 304 as before; in `presentation-diag.log` only `custom` of the DOS variations
  changes: `unexplained` lower (572 -> 534 privately: the core's drawing into dialogs 143 and 135 is the owner's),
  `w_over_n` one more (dialog 143's close; Decisions).  `ext_g1.py check`: EXT_G1_OK runs 77 (the Windows-only V0
  is unchanged).
* The DOS frames of `custom` (and of every run through Customize World) from the title choice on: the fade, then
  CUSTOM.PIC and the four question boxes, instead of the title screen; nothing else changes (hpriv: every other
  scenario's DOS samples equal).
* Counts: EXT_ADAPT_OK checks 77 -> 86; ext_timeline group base +1 run and +4 checks; ADAPT_OK rows 83 -> 95 steps
  21 -> 24; REGISTRY_OK tables 26 -> 35, `tests/dos-decoded.txt` 1345 -> 1354 lines; OBS_LINT_OK files 106 -> 108;
  portable sources 286 -> 287; nodos two files more; pdos_scene_check (1075) and OBS_TABLES_OK (203 / 98) unchanged;
  test_pdos_setup 94 -> 126, test_pdos_seq 172 -> 179, test_input 336 / 309 / 336 -> 377 / 350 / 377, test_dos
  23,215 -> 23,224.

## Build-slot steps

1. Copy the staged files onto the tree (BASE-SHA256.txt: every base is the tree's file now; DOS-PROFILE.md is the
   D5d landing's with 1.7.2 regenerated: if the tree's file moves again, take it and run `gen/dos/adapters.py
   gen`).  Run `gen/dos/registry.py gen` + `check` (unchanged output expected), `gen/dos/adapters.py check`,
   `gen/obs_tables.py --check`, `gen/dos/nodos.py check`.
2. The three-step cycle: `build.cmd checked`, `test.cmd checked`, `ext_g1.py check` (no test.cmd / build.cmd
   change; the counts of BUILD-TEST-ADDITIONS.md).
3. Compare with "Expected changes"; then the user build.

## Decisions and deviations

* **The transition's timeline** is pdos_scn_custom's own program on the DOS session (its fade is a pdos_tl wait
  with the session's M4/M5 state), not a pdos_fx effect (BRIEF-d5.md's file list names pdos_fx for the fade):
  pdos_fx holds effect instances and the blink only.
* **The entry phase** (WAIT): found privately - without it one A frame was presented at the instant the title
  ended and dialog 143 opened (presented.log of d-custom-choices: a 640x480 frame equal to the Windows form's);
  with it the DOS-form runs present only the start-up frame as A, as the base's do.
* **The highlight** is the core's selection (C.12.7): Up, Down and a hotkey click the item's Region (the core
  selects) and the view follows at the next core point; it does not follow a drag; after the help screen it shows
  the core's selection (DOS's box starts on its default).  A repeat of Up or Down is consumed (DOS moves once per
  typematic key).
* **The Cancel row** (ruling 5) is on the current question only.  Its hotkey (C) never chooses: the DOS hotkey
  search does not wrap (R:1D05:03FD) and the Cancel row is last, so where it finds the Cancel row DOS finds nothing.
* **Not modelled**: the pointer moves R:0000:16AE to (210, y + 10) (the host's pointer); the disk checks
  R:01A8:02A4 (no output); strupr's code page (the topics are ASCII).
* **Escape** is consumed (DOS asks the question again, -1).
* **The help screen** is drawn when the core's dialog 135 is created (the core's answer to the help region's
  click), not at the DOS key's instant; HELP.TXT without the topic's section shows no screen (O4:0045) and the
  core's note waits for the next key or left press (DOS asks again at once).
* **The scene word** of the adapter's rows and scene is 32 bits (17 scene bits).
* **w_over_n**: dialog 143's close by OK or Cancel adds one (the core's main window is activated above the hidden
  dialog before its destruction; 6.4's fallback counts it, as it counts the title dialog's creation in every run);
  no A frame is presented there (presented.log).  In both cases the N scene's window is not shown at that moment
  (shown 0).  A rule that skips the count while the scene window is hidden would remove both; it changes the
  fallback of every scene, so it is left to D5f's counter work (ruling 8: the counters are 0 for the D4 and D5
  rows).
* A dialog 143 or a CustomizeWorldDialog out of its scene starts no view (D5a counts it); an unread core state is
  noted once per view (PDOS_DIAG_SEQ).
* **Open C-4 settled**: the core's controls of dialog 143 are the Regions 0x323 + 4q + col, column 3 the question's
  help region (ShowHelpNote(topic), dialog 135); the d-custom-help pair shows it (equal core input and checkpoints).
* **After Cancel** the title box is drawn over the Customize screen (D5a's title_again, R:01A8:0807), as DOS does;
  the Customize picture stays behind it until the next choice.
* **Tests** went into the existing `test_pdos_setup.c` (the owner and the DOS store are there) rather than a new
  test program: no test.cmd change.
* **The bad-handle fix**: while the core destroys dialog 143 its children are still listed but gone; the Cancel
  row's text is read once per view (pdos_custom_open clears it), so no child is read during the teardown
  (bad_handles 0 in every case).

## What the user checks (DOS graphics, after landing)

Start with the DOS graphics and choose Customize World on the title (its row, or the hotkey C, then Return):

1. **Transition**: the title screen fades to black (about half a second), then the Customize picture appears.
2. **Questions**: the first box at the top right (land mass) lists three choices and a Cancel row, the current
   setting highlighted; Up and Down (or an item's letter) move the highlight; Return, Space or a click on an item
   chooses it and the next box appears below, the previous one staying without its Cancel row.  Four boxes in all
   (land mass, temperature, climate, age).
3. **Help**: the right button or Alt+H on a question shows the DOS help screen (one colour, the topic's name at the
   bottom, the help text from the top left); any key or a left click returns to the same question (after the
   age question's help the climate question is asked again, as in DOS).
4. **Cancel**: a click on the Cancel row returns to the title.
5. **After the fourth choice** the game goes on to the world's creation and Birth with the chosen parameters.
6. **Switching profiles** during Customize: the Windows profile shows dialog 143; back on DOS the same DOS screen.

## For the records

* FIDELITY: Customize World transcribed from the DOS listing (R:01A8:0591..0792, O4:0000..00A0) with the highlight,
  Cancel row, help-timing, Escape and not-modelled points above.
* FEATURES / STATUS: the DOS Customize World screens and help screen under `--graphics dos`.
* The manual checklist: the six user checks above.
* DESIGN (C.7.4, C.9, C.12.7, B 9.3): pdos_scn_custom (its timeline on the session, the questions, the help
  screen), the owner "setup" claims 143 and 135, I-custom / I-wait help rows, the WAIT entry.
* RUNNING: the counts of BUILD-TEST-ADDITIONS.md; ext_adapt 86 and the three new pairs; ext_timeline's `custom`
  run; 287 portable sources.
* DOS-PROFILE: 1.7.2 regenerated (95 rows); the scene-table rows 6, 20, 116 unchanged in text.
* OFFSETS.md: the nine rows above.

## Landing (build slot, 2026-10-16)

D5 stager, in the build slot after the coordinator accepted D5e (the docs pass for D6a had finished:
`build/docs-d6a-done.txt` 04:22:07 UTC; no docs agent running).

* **Copy** (04:37:30 UTC, `build/d5e-prep/land.py`): the 20 files of `build/d5e-stage/BASE-SHA256.txt`, each
  only while the tree's file still had its listed base SHA-256 and the staged copy its listed SHA-256 (the two
  new files had to be absent).  Every base matched (the bases had been taken again after D6a's landing), so
  nothing was rebased; DOS-PROFILE.md's base was the tree's, so the staged copy (1.7.2 regenerated) went in as it
  is.  Manifest `build/d5e-prep/landed.sha256`; the tree's previous files in `build/d5e-prep/tree-before/`; the
  tree's Checked outputs before the cycle (D6a's) in `build/d5e-prep/before/`.
* **Generators and checks** before the cycle: `gen/dos/registry.py gen` (unchanged output: 159 files, 35
  tables) and `check` REGISTRY_OK; `gen/dos/adapters.py check` ADAPT_OK rows 95 steps 24; `gen/obs_tables.py
  --check` OBS_TABLES_OK probes 203 sites 98; `tests/harness/pdos_scene_check.py` PASS (1075 checks).
* **Cycle** (`build/d5e-prep/d5e-cycle.ps1`; each step waits on its own cmd.exe process only):
  1. `build.cmd checked`: exit 0, 189 s (04:38:08..04:41:17 UTC), BUILD_OK (287 portable sources);
  2. `test.cmd checked`: exit 0, 1045 s (04:41:17..04:58:42), TESTS_OK;
  3. `ext_g1.py check`: EXT_G1_OK runs 77 (amended 1).
  `build/d5e-status.txt` ends ALL_GREEN; logs `build/d5e-1-build-checked.log`, `build/d5e-2-test-checked.log`,
  `build/d5e-3-g1-checked.log`.  (A first launch of the cycle script failed before any step: `powershell.exe`
  was not on the tool shell's PATH; it was started again with the full path.  No step had run.)
* **Against "Expected changes at the build slot"** (`build/d5e-prep/compare.py`, output
  `build/d5e-prep/compare-out.txt`: the cycle's Checked outputs against the snapshot):
  1. P0_OK checks 304.  presentation-diag.log: only `pdos unexplained` and `pdos w_over_n` changed.  The predicted
     ones: `custom` of V1, V2, V7, V8 and V8s, unexplained 572 -> 534 and w_over_n 1 -> 2.  Not named in the
     prediction but the same cause (their runs reach dialog 143, whose drawing is now the owner's):
     `mirror/custom` (ext_bs mirror; 572 -> 534, w_over_n 1 -> 2) and ext_adapt's d-title-mouse-dos and
     d-title-mouse-win (567 -> 529; they end before dialog 143 closes, so their w_over_n is unchanged).  No other
     field changed (pmap timing fields only, run-to-run noise).
  2. profiles.log: none differs.
  3. ext_adapt: EXT_ADAPT_OK checks 86 (was 77); d-custom-choices, d-custom-cancel and d-custom-help PASS.
  4. ext_timeline group base: the `custom` run and its four checks PASS, EXT_TIMELINE_OK; group bs unchanged.
  5. adapters-check ADAPT_OK rows 95 steps 24 (was 83 / 21); dos-decoded.txt the 9 new rows (1354 lines);
     registry-check 29 more ok lines; obs-lint OBS_LINT_OK files 108 (was 106); nodos 1692 files (was 1690), 0
     hits; portable sources 287.
  6. Unit tests: test_pdos_setup 126, test_pdos_seq 179, test_input 377, test_dos 23,224 checks, all passing.
  7. Unchanged as predicted: EXT_FRAMES_OK, EXT_CONTINUE_OK, EXT_BS_OK (assets, mirror), MIRROR_OK runs 29,
     ZOOM_OK, the Birth goldens, EXT_G1_OK runs 77.
  8. Informational: coverage.txt "other functions entered" 661 -> 662 (it varies between cycles; not a test
     result).
* Not run in this landing: the CheckedNoObs and Release cycles (the three-step cycle only) and Asan (deferred).

## User rework (D5eR, staged with D5f, 2026-10-16)

The user, about 05:50 UTC, on the landed D5e screens (the coordinator marks manual checklist D5-14, D5-16 and
D5-18 failed): "1. In Dos graphics mode there shall be no Cancel menu item visible. 2. Dos and Windows mode shall
sync player choices as they choose the earth customization on this screen".  The general direction of 06:10 UTC
(BRIEF-d5.md "User direction 2026-10-16": no Go Back / Cancel row the DOS screen lacks, on any screen) binds item 1.
The Windows profile, the core, P0, G-1 and the core's frames, state and events are unchanged.

### Item 1: no Cancel row (ruling 5 reversed by the user)

* Each Customize box has DOS's header and three items only (`pdos_scn_custom.c`: `LINES` 6, `build(b, q)`,
  `draw_box(q, t)`); ruling 5's Cancel row on the current question, its text read from dialog 143's Cancel and
  `PDOS_CUSTOM_TEXT` are removed.  The box a question leaves stays as drawn, with its highlight (DOS draws nothing
  over it); D5e's redraw of the left box without the Cancel row is gone with the row.
* **The core's Cancel (button 0x66) is Windows-only.**  The DOS listing has no key with its effect on this
  screen: Escape and the release outside the box are MenuZ's -1 (R:1D05:0200 -> 0392, R:1D05:01A1..01B2), and the
  listing asks the question again (R:01A8:065A, 06B7, 0714, 0771).  `I-custom/other` consumes both, as before
  (now also the release below the three items, where the Cancel row was); `I-custom/cancel/core-ready` and its
  query `q_now_cancel` are removed (`PDOS_A_CANCEL`, `PDOS_AA_CANCEL` stay declared, in no row).
* When the core leaves dialog 143 by its Cancel (in the Windows graphics), the DOS view ends and the title box is
  drawn again over the Customize screen (D5a's title_again, R:01A8:0807), as before.

### Item 2: the choices in sync between the graphics (investigation and proof)

* **Interpretation (recorded):** a Windows radio click is a **selection**, as DOS's Up / Down are; it does not
  answer the DOS question.  DOS's sequential order stays: the DOS view asks questions 1..4 in turn, and only a
  DOS choice (Return, Space, a hotkey's choice, a release on a row) moves it to the next question.  The sync
  criteria (the coordinator's (a)..(c)): (a) every DOS selection or choice is the core's selection before the next
  present (the adapter clicks the item's Region at once, `q_now_click`); (b) every change of the core's selection,
  including a Windows radio click, is shown at once in every drawn DOS box when the DOS profile is presented
  (the view reads `g_worldParams[q]` at the core points: the probe and event steps; no timer read, no RNG
  effect); (c) the DOS highlight never differs from the core's selection at any presented DOS frame.
* **Investigation** (headless switching runs on the private build, `build/d5f-stage/obj/sync`): in both
  directions (DOS choices then the switch to Windows; Windows radio clicks on drawn boxes then the switch back)
  the DOS timeline's `custom_sel` step followed each Windows click within 1 ms, and no presented DOS frame showed a
  highlight unlike the core's.  The state was in sync already in D5e; what the user most likely saw is DOS's
  sequential order: a Windows choice for a question the DOS view has not reached yet (questions 3, 4 while DOS
  asks 1) is not visible in DOS until DOS asks that question; its box then starts on the core's selection, not on
  DOS's default.  (D5e also redrew the box a question left, smaller, without its Cancel row, when the next
  question started; that redraw is gone with item 1.)  No source change beyond item 1 was needed for (a)..(c); the proof is new.
* **Proof:** `pdos_custom_box_sel(q)` (box q's highlight as drawn) and `pdos_custom_stale()` (the drawn boxes
  whose highlight differs from the core's selection read now; 0 outside the questions), called only by the
  harness: at every presented frame while the questions are asked, `custom_check()` (tests/headless/harness.c)
  counts the shows and the stale boxes per visible profile; presentation-diag.log gains the line
  `custom_sync shows_dos N stale_dos N shows_windows N stale_windows N first_us N` (before D6b's replay line).
  Vectors (`test_pdos_setup.c`): after a core-side selection change and before the core point the stale count is
  2, after it 0; the fourth box, first drawn after the change, shows the core's selection.  Switching run
  (`ext_adapt.py` `d-custom-sync`, with `--presented 1`): Return, Down, the profile chord, Windows radio clicks
  on groups 0, 1 and 3 (3: a question DOS has not reached), the chord, Up, Return, Return, the chord, against the
  same without the chords: both runs' `custom_sync` stale_dos 0 and stale_windows 0, the DOS-form run shows both
  profiles, and the clicks on groups 0 and 1 are in the DOS timeline within 20 ms; equal core input and
  checkpoints.  `d-custom-cancel` is replaced by `d-custom-nocancel` (a release where the Cancel row was, then
  Escape: both consumed, nothing reaches the core).

The results are in `ext-D5f-record.md` ("Results") and `ext-D5-acceptance.md`.

**Landed** with D5f and D5cR (copy-in 2026-10-16 07:49:42 UTC; the D5 gate's eight-step cycle ALL_GREEN 08:37:49 UTC,
`build/d5-gate-status.txt`; `ext-D5f-record.md` "Landing").  D5eR's results in the cycle (Checked): ext_adapt
d-custom-nocancel (coreinput 4) and d-custom-sync (28; `custom_sync` DOS-form shows_dos 7 stale_dos 0 shows_windows 5
stale_windows 0, Windows-form shows_windows 8 stale 0; the clicks on groups 0 and 1 shown 1 ms later), both equal
to their Windows-form pairs; test_pdos_setup 164 in all three variants; ext_timeline `custom` EXT_TIMELINE_OK with
187 shows after the title choice (was 188: D5e's redraw of the fourth box without its Cancel row at custom_end,
11.0011 s, was a frame of its own; without the row the frame after the fourth box, 10.0011 s, is already the final
one).  P0 and G-1 unchanged.

### For the records (D5eR)

* Manual checklist (the coordinator): D5-14 "lists three choices and a Cancel row" becomes "lists three choices",
  and "the previous one staying without its Cancel row" becomes "the previous one staying as drawn"; D5-16 becomes
  "no Cancel row in DOS: Escape or a click outside the items does nothing (DOS asks again); Cancel exists only in
  the Windows graphics, and after it the DOS title box shows over the Customize screen"; D5-18 adds "a choice
  changed in the Windows graphics (Ctrl+Shift+Backspace) shows at once in every DOS box on the screen after
  switching back; a question DOS has not reached yet starts on the Windows choice when DOS asks it; a DOS choice
  shows in the Windows radio buttons".
* FIDELITY (F135, F166): ruling 5's added Cancel row is no longer a deviation; new entries: the core's Customize Cancel is
  Windows-only (R:01A8:065A..0771 cited above); a DOS box shows the core's selection when first drawn (DOS starts
  on its default), the sync interpretation above.
* DESIGN 12.8 "As implemented (D5)": no Cancel row; the sync criteria (a)..(c) and the harness's custom_sync
  check.  DOS-PROFILE 3.x "Cancel in Customize": Windows-only (no DOS form); row 6's text: three items per box.

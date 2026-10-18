# Extension phase D7, unit D7a (N scenes in play, the return to the map, the O14 frame, City Status) - record

Draft for the build slot (BRIEF-d7.md "Units" D7a, extension session E3).  Staged in `build/d7a-stage/` on the tree
after D6f's landing (RELEASE_OK at 04:54 UTC on 2026-10-17, `build/d6f-status.txt`): rebased onto it with the bases
copied to `obj/base/` at 04:57 UTC (`docs/DOS-PROFILE.md` again at 05:17 UTC, after the coordinator's D6f record pass;
section "Rebase notes"), and every base rechecked equal to the tree in `BASE-SHA256.txt`.  D6g landed at 05:14 UTC
(`tests/harness/ext_p0.py` and its record, no D7a file) and the D6 gate cycle was ALL_GREEN at 06:02 UTC
(`build/d6-gate-status.txt`); D7a lands at the coordinator's word, alone or together with D7b (`build/d7b-stage/`,
staged on D7a's copies).  Private builds and runs in `build/d7a-stage/obj/` only: an overlay `obj/src` = the tree + the
stage (`obj/mkoverlay.py`), built with the tree's build.cmd and flags (`obj/b.cmd`, `--nogen`), cc.cmd's stricter checks
per file (`obj/cc.cmd`), the unit programs and the harness runs from the overlay's binaries with every output under
`obj/`; the tree's build/gamedata, dosdata and cache read only.  Landed by the build slot on 2026-10-17 (section "Landing"; a landing of 06:54 UTC was backed out at
the user's stop, `build/d7a-prep/BACKED-OUT.txt`).

**Registry fix (session E4, 2026-10-17 about 07:30 UTC).**  `gen/dos/registry.py check` (test.cmd's d2_registry) failed
on the staged `pdos_scn_report.c` twice: it included `<stdio.h>` (for one `snprintf` of the diag line) and, including
`w16_obs.h`, was not in `OBSERVER_FILES`.  The diag line is now formed by a local `line_field` (pdos_replay.c's helper,
the same text), `<stdio.h>` is gone, and the staged `gen/dos/registry.py` (new in the stage, base: the tree) adds
`pdos_scn_report.c` to `OBSERVER_FILES` in its own block after `pdos_aplay.c` (D7j's staged registry.py adds the same
file with `pdos_scn_palace.c` at the set's end: the two hunks do not touch; at a landing after D7j the entry may appear
twice, which a Python set ignores).  Every base was rechecked equal to the tree (the D6 gate's state) and the overlay
variants rebuilt and rerun with REGISTRY_OK (section "Results").

## Result

D7a is staged and READY_TO_BUILD.  With the DOS graphics, Advisors > City Status (F1 through D6f's rows, or Ctrl+1)
shows the DOS O14 report on the N canvas: 320 x 200 on the dark grey background, the title centred in white without a
shadow, the empire and leader lines and the city rows drawn by the replay in the DOS fonts, the production column in
white at the DOS name widths; the pointer is hidden.  Any key or a click anywhere closes it, and the map returns at once
without a fade (exit kind none, as O14:013B); the return's fade-in (1B44 from black, 1BEB from the scene's DAC, 30
frames, the map slots held, abandonment C.9) is in place for the D7 scenes that name those kinds.  The page-2 GOVT
portraits are loaded at every report opener from the core's state, and T1 maps the core's advisor shapes to them (D7b
draws them).  F1 is closed (two report-title sites, font-map rows, DOS-PROFILE 2.4 F18).  The I-report rows decide the
report's input.  Privately, on the tree after D6f: the three variants build, every unit program passes in each, the d7a
pair passes 5 of 5 (the DOS-form run equals its Windows-form pair), ext_p0 V0/V1/V2 on `menus` P0_OK, and every check
script passes.

## Status

READY_TO_BUILD.  Built: rows 98 (the O14 frame and its close), 67 (Advisors > City Status) and 25 (dialog 148, the
report window's opener) for City Status; the N scene in play over A (draft B 6.3, 9.2); decision 3's exit kinds and the
return's fade-in in `pdos_fx` from D6e's trigger (RestoreMapAfterDialog's entry), with the fade-out abandoned (C.9); the
page-2 advisor portraits as presentation state (GOVT portraits at (160 + 40n, 140), SPRITES 7, O5:1AF6, GetCourtStyle's
rule, modern after advance 14h, read at use; T1 in `pdos_prov`); the D4a second review's F1 (the report-title font-7
sites enumerated, one font-map row each, DOS-PROFILE 2.4 F18, the row count in `pdos_scene_check.py`); the adapter rows
I-report (the report's close, position irrelevant).  Not in the unit: the other reports (D7b, D7c), the text-box headers
(D7g).

## What was built

### The N scene in play over A (B 6.3, 9.2)

The report renderer `present/dos/pdos_scn_report.c` (new; `pdos_scn_report.h`) keeps a table of the reports it draws
(D7a: row 67, ShowCityStatus 1018:208F, DOS O14:186F, exit kind none; D7b and D7c add their rows).  The scene engine
already pushes rows 67 (ShowCityStatus's entry), 25 (GR_DialogOpen of dialog 148, bound to its window) and 98
(CloseReportScreen's entry) as the core runs; D7a makes them ready while the report shows, so `pdos_scene_wants_n` turns
the frame to N (320 x 200) for the report and back to A at its end:

* the frame begins at OpenReportScreenWithHeader's entry inside a report of the table (O14:0000/001C): the N machine
  takes the play palette (PDOS_PAL_KEEP: the O14 reports change no DAC entry), page 0 is filled with the opener's
  background argument (8, dark grey, as O14:186F passes), rows 67, 98 and 25 are set ready (row 25's earlier readiness
  is kept and restored at the end), the pointer is hidden (O14:0000 R:01A8:0268 .. O14:013B R:01A8:0250);
* ShowCityStatus's ProcessCity(city, -1) (a computation without a screen; DOS R:0D12:0045) pushes row 97 above the
  report: its readiness is held while it runs, so the frame never turns to A inside it;
* the end is the report window's destruction (GR_DialogClose destroys it before calling RestoreMapAfterDialog): the rows
  are no longer ready, the report's exit kind is named for the return trigger, the step `report_end` is logged; a
  recycled window handle or the opener's exit without a destroy ends it as well;
* presentation-diag's `pdos_rows` counts the report's events on the opener's row (67) rather than on 25 or 98
  (`pdos_profile.c` diag_row: the rows 25 and 98 above it are skipped while a report shows).

### The O14 frame (O14:0000/001C) and its close (O14:013B)

The shadow owner "report" (draft B 7.5; the fifth owner, `PDOS_OWNER_MAX` raised to 6) claims the report window (dialog
148 of GR_DialogOpen's call in OpenReportScreenWithHeader) and the report port's bitmap (GR_PortOpen's call there, the
port's hBitmap at +1Ah) at the logical resolution:

* the core's fills of both (OpenReportScreenWithHeader's FillRect of the window, DrawReportHeader's of the port) fill
  them with the DOS background;
* the replay (D6b) draws the core's texts into the port's shadow in the DOS fonts and colours (the realm line and the
  leader and year line are the core's words, the same as DOS's, O14:0070..0131);
* the title: DrawReportHeader's DrawCenteredShadowedScreenText (Windows font 7, shadowed) is drawn again after the
  replay drew it: its rows are filled with the background and the title is drawn by `pdos_text_centred` at (160, 2) in
  colour 15, not shadowed, in the font in effect (F18: id 7 at that site -> font 1), as O14:003A..004E draws
  R:0182:00B3;
* each CopyPortToWindow (a SRCCOPY BitBlt at a page's end and in CloseReportScreen) copies the port's shadow to the
  window's with the engine's mapping and to page 0 (`report_copy` logged): the N screen shows each page when the core's
  window does;
* the close: CloseReportScreen's WaitForKeyOrClick takes any key or click (I-report below); the window's destruction
  ends the frame (O14:013B: the saved screen restored, no fade).

### City Status (O14:186F against ShowCityStatus 1018:208F)

Rows from y 32, 8 apart, 20 a page, as the core's (1018:20B6..24B5), drawn by the replay.  DOS draws the production
column at x 172 as one string in colour 15 (the name, then " (stored/cost)", O14's BA06); the core draws the name with
DrawScreenText and the rest with DrawTextAtPen in grey (7) at its pen.  The renderer draws that pen text at x 172 + the
DOS width of the name as the replay drew it (folded; an improvement truncated to 96 by R:1F4D:04F7's rule from
TruncateStringToLogicalWidth's original), in colour 15; with no production name (production 40h or more) the core's pen
text is the stats line again and is drawn at 172 as DOS draws BA06 there.

### The return to the map (decision 3, ruling 3; C.9)

`pdos_fx` gains the exit kinds (`PDOS_EXIT_NONE` for the O14 reports, `PDOS_EXIT_1B44` from black, `PDOS_EXIT_1BEB` from
the scene's DAC) and the return: an N renderer names its kind when its scene ends (`pdos_fx_exit_set`); D6e's trigger
(`pdos_aplay.c`, RestoreMapAfterDialog's entry, after the play palette was set) takes it
(`pdos_fx_return(&pdos_ma()->dac, &pdos_mn()->dac, t)`); kind none logs `return` and changes nothing; 1B44 and 1BEB
start a fade-in of R:0000:04AA's 5 steps = 30 frames (M5; frame j weighs `pdos_fade_weight(j, 30)`) on the A canvas's
play-palette layers, run by `dos_advance` (`pdos_fx_return_run`), the map slots not stepping while it runs (R:0238:1BFC
.. 1C8E; CyclePaletteColors held back).  The fade-out of 1B44 is abandoned (the core has left the scene first; the start
is black, where that fade would have ended).  Abandonment (C.9): an N scene wanted again before the fade's end (checked
after every event and probe, `return_check`) or a new trigger completes it at once (the target), counted and logged
(`return_fade_abandon`).  City Status names kind none: no fade, as DOS.

### The advisor portraits (page 2; SPRITES 7, O5:1AF6; T1)

At every report opener (OpenReportScreenWithHeader, OpenBlankReportScreen) the renderer reads the human player
(g_humanPlayer), its government and its known advance 14h (never for player 0, PlayerKnowsAdvance) through `w16q_read`,
chooses govt<d><a|m>.pic by GetCourtStyle's rule (government 3 alone, without a modern variant; else government / 2) and
copies its (0, 0, 160 x 60) to page 2 (160, 140) of the A machine (G#20), as O5:1B68..1B84.  `pdos_report_portrait`
copies portrait n from (160 + 40n, 140, 40 x 60), as O14:0206..0226 (for D7b).  `pdos_prov`'s T1 rule maps the core's
advisor shapes (pictures 400..406, cut by LoadAdvisors at device (538 + 105n, 161, 53 x 96)) to those page-2 rectangles
(row 101), and `pdos_prov_t1_header` maps text-box header 3 + n to advisor n.  `pdos_prov_rule` keeps a rule registered
again once (the profile's reset registers it at every reset).

### F1: the report-title font-7 sites (ext-D4a's second review)

The writes of Windows font id 7 to the screen port's font word before a title, enumerated in core/: DrawReportHeader
1018:015D (the O14 frame's title; its text call returns at 1018:0234) and ShowTopFiveCities 1080:099B (DOS O3:09AC,
R:0182:0086; its text call returns at 1080:0AFC).  The other writes of id 7 are not report titles:
ShowCivilizationRatingRanking (F7's rating ladder) and ShowConquerorEnding; SetCivFont(..., 7) is called only by the
Civilopedia and CustomizeWorldDialog.  `pdos_fontmap.c` gains one row per site (id 7 -> DOS font 1, the font in effect,
inferred; SP 7.14, OB4, L14); DOS-PROFILE.md 2.4 gains F18 (the functions named with their entry addresses, as F16 names
its function; no call-site addresses), F7 points to it, Open 16's gap paragraph says it is closed; `pdos_scene_check.py`
expects 10 font rows and 18 rows in 2.4 and checks F18 and the two sites (the logical-text form of the site check added:
`OF_ScreenPort_fontId), 7);` followed by the text call).

### The adapter rows I-report (C.12.7, class X; position irrelevant)

`pdos_adapt_tab.c`: I-report/mod (consume), I-report/key (pass: the report's wait ends), I-report/press (pass: the press
and its release at the I5 point when it lies in the report window, else at its centre; class X), I-report/right
(consume).  `pdos_adapt.c`'s scene: `PDOS_AS_REPORT` while `pdos_report_shown()`, the window `pdos_report_wnd()`.
`gen/dos/adapters.py` names the scene; DOS-PROFILE.md 1.7.2 regenerated (four rows).

## Files

New: `present/dos/pdos_scn_report.c/.h`, `tests/test_pdos_report.c`, this record.  Changed (`BASE-SHA256.txt`):
`present/dos/pdos_fx.c/.h` (the return), `pdos_aplay.c` (the trigger takes the kind), `pdos_profile.c` (reset, events,
probes, the cursor rule, diag_row, return_check, the cycle hold, the fade's run), `pdos_seq.c` (the timeline.log sinks
of the report and the return), `pdos_prov.c/.h` (T1), `pdos_fontmap.c` (F1's rows), `pdos_adapt.c/.h`,
`pdos_adapt_tab.c` (I-report), `pdos_shadow.h` (`PDOS_OWNER_MAX` 5 -> 6), `gen/dos/adapters.py`, `gen/dos/registry.py`
(`pdos_scn_report.c` in `OBSERVER_FILES`; E4's registry fix), `docs/DOS-PROFILE.md`
(F7, F18, Open 16, 1.7.2), `tests/test_pdos_scene.c` (F1 vectors), `tests/test_pdos_profile.c` (the return's fade in the
profile), `tests/test_input.c` (the I-report vectors), `tests/harness/pdos_scene_check.py`, `tests/harness/ext_adapt.py`
(the d7a pair), `tests/headless/harness.c` (the `report` diag line).  build.cmd and test.cmd unchanged
(test_pdos_report.c is picked up by the `tests\test_*.c` rule; no BUILD-TEST-ADDITIONS.md).  Every `extension D7a` block
is delimited where it adds more than a line; one-line hunks carry an `extension D7a` comment.

## Tests

* **`tests/test_pdos_report.c` (new, 110 checks in every variant):** the return (`pdos_fx`): kind none changes nothing
  and is logged, 1B44 from black and 1BEB from the scene's DAC, the weights of frames 1, 15 and 29 and the target
  exactly at frame 30 (`pdos_fade_weight`), the end time on the trigger's grid, abandonment by a new trigger and by
  `pdos_fx_return_abandon`, the counters, the log steps (sequence PDOS_SEQ_FX_FADE), the reset; GetCourtStyle's rule on
  the DOS files (governments 0..5 in both variants, 3 without a modern one, 6, 7, -1, 9); the portraits' load into page
  2 and `pdos_report_portraits` from the core's state (player 0 never modern, advance 14h, an unreadable state, govt3m);
  T1 (`pdos_prov_t1` for pictures 400..406 at the device rectangles, the header rule); the frame on a synthetic stream
  through the scene engine, the shadow engine and the renderer in the profile's order (ShowCityStatus,
  OpenReportScreenWithHeader, dialog 148, the port, DrawReportHeader, the stats, unit and truncated improvement pens,
  ProcessCity's row-97 hold, CopyPortToWindow, CloseReportScreen, the destroy): the fills in the DOS background, the
  title drawn again centred unshadowed (x 151 for the synthetic title), the pens at the DOS name widths, the copy to
  page 0, N while the report shows (CloseReportScreen's wait included), A after it, the exit kind none, row 25's
  readiness restored, a second report; reports outside the table untouched.  A synthetic font (A..D) stands in for the
  DOS fonts.
* **`tests/test_pdos_profile.c`** (51 -> 59 checks in Checked and Release; `test_return_fade`): through the profile, no
  map-slot step while the fade runs, an N row pushed but not ready leaves it running, ready: the next probe abandons it
  (the play palette at once), the profile's advance runs it (half way between black and the target, the target exactly
  at frame 30), the slots step again after it.
* **`tests/test_pdos_scene.c`** (136 -> 141 in Checked): F1's vectors (id 7 at 1018:0234 and 1080:0AFC -> 1, id 7
  elsewhere -> 7, ids 1 and 8 unaffected, `pdos_fontmap_port_font` at the title site and beside it), 10 font rows.
* **`tests/test_input.c`** (502 -> 506 in Checked): the four I-report vectors on a synthetic report (class X window),
  the table's row count 116 -> 120.
* **`tests/harness/pdos_scene_check.py`:** 18 rows in 2.4, F18's columns, 10 font rows, the two title sites against
  core/ (the logical-text form of the site check), DOS font 1, inferred (1078 -> 1084 checks).
* **`tests/harness/ext_adapt.py`, the d7a pair** (2 runs, 5 checks): City Status opened with Ctrl+1 in play at 55,500 ms
  in the DOS profile, closed by a press at an N point far from the report window at 57,000 ms; the press decided by
  I-report/press (one click, class X, no refusal or cancel); the DOS-form run equals its Windows-form pair (coreinput,
  frames, state, events, exit); timeline.log `report` (O14:186F, row 67), `report_copy`, `report_end` (O14:013B, kind 0)
  and the return trigger kind 0 after it, no fade step; 320 x 200 N shows while the report is open and A shows after it;
  the `report` diag line (one open and end, a title, a copy, return_none 1).
* `ext_timeline.py` and `ext_p0.py`: unchanged (deviation 1).

## Results (private, `build/d7a-stage/obj/`)

* **Builds:** Checked, CheckedNoObs and Release BUILD_OK (build.cmd's own flags on the overlay; portable sources 297,
  the tree's 296 + `pdos_scn_report.c`).
* **cc.cmd** (c11 and c17 at /W4 /WX, the clang C99 parse) in Checked, CheckedNoObs and Release: CC_OK for
  `pdos_scn_report.c`, `pdos_fx.c`, `pdos_aplay.c`, `pdos_profile.c`, `pdos_seq.c`, `pdos_prov.c`, `pdos_fontmap.c`,
  `pdos_adapt.c`, `pdos_adapt_tab.c`, `pdos_shadow.c` (for `pdos_shadow.h`), `test_pdos_report.c`, `test_pdos_scene.c`
  and `harness.c`; `test_pdos_profile.c` CC_OK in Checked and CheckedNoObs; `test_input.c` passes c11 and c17, and the
  clang parse reports only the base's own missing-field-initializer (`square_only`, line 165), as D6f recorded
  (build.cmd does not tidy the tests).
* **Unit** (`obj/unit.py`: test.cmd's unit section on the overlay's binaries, the tree's build/gamedata read only): all
  55 programs (test_ne aside) pass in Checked, CheckedNoObs and Release, w32_test_host_win32 included.  Checked against
  the tree's last Checked cycle (D6f's, `build/d6f-2-test-checked.log`): test_input 502 -> 506, test_pdos_profile 51 ->
  59, test_pdos_scene 136 -> 141, test_pdos_report new 110; every other count equal. Release: test_input 506,
  test_pdos_profile 59, test_pdos_scene 141, test_pdos_report 110.  CheckedNoObs: test_pdos_profile 55, test_pdos_scene
  142, test_pdos_report 110 (no tree CheckedNoObs log of this tree state to compare with).
* **Checks** on the overlay: `obs_lint.py` OBS_LINT_OK files 126 probes 203 callsites 101 (files 124 before);
  `pdos_scene_check.py` PASS 1084 checks, 141 scene rows, 10 font rows (1078 and 8 before); `adapters.py check` ADAPT_OK
  rows 120 steps 25 (rows 116 before); `obs_tables.py --check` OBS_TABLES_OK probes 203 sites 101 (unchanged); `nodos.py
  check` (the overlay and its three variants' binaries) NODOS_OK, 0 hits.
* **ext_adapt's d7a pair** (`obj/runadapt.py`: the staged runner's `d7a_runs` with the private Checked harness): 5 of 5
  (Ctrl+1 reaches the core through D6f's I-play/I-pass rows).  The press at the N point (20, 190) lies outside the
  report window: decided by I-report/press, one click at the window's centre (320, 240) (class X); the DOS-form run
  equals the Windows-form pair (coreinput 39 lines, frames 682; exit 0, 0); `report` at 55,550,650 us (O14:186F, row
  67), one `report_copy`, `report_end` (kind 0) and the return trigger (kind 0) at 57,001,650 us, no fade step; 2 N
  shows (320 x 200) during the report, 21 A shows after it; the `report` line: opens 1, ends 1, fills_window 2,
  fills_port 1, titles 1, pens 1, copies 1, city_holds 1, portraits 1, other 0, return_none 1.
* **ext_p0** (the tree's runner with `--exe` and `--root` under `obj/`): V0, V1, V2 on `menus` P0_OK (7 checks; V0
  equals its baseline as amended).  In V1 and V2 the menus run's `pdos_rows` no longer has `r67.unexplained` (1 in D6g's
  summary of the tree's runs: the report is the owner's now); `r98.unexplained` 14 (the other reports'
  CloseReportScreen, D7b/D7c); the `report` line: opens 1, ends 1, portraits 11 (one per report opener).
* **E4 rerun after the registry fix** (2026-10-17, 07:30..08:05 UTC; the overlay remade on the tree of the D6 gate with
  `docs/DOS-PROFILE.md` of 07:33): Checked, CheckedNoObs and Release BUILD_OK (262, 285, 268 s); cc.cmd (`ccall.py`)
  CC_OK for the 15 files above in every variant, `test_input.c`'s clang parse aside (the base's `square_only`, as
  before); unit: 55 programs pass in each variant, against the D6 gate's logs Checked and Release test_input 502 -> 506,
  test_pdos_profile 51 -> 59, test_pdos_scene 136 -> 141, test_pdos_report 110, CheckedNoObs test_input 446 -> 450,
  test_pdos_profile 47 -> 55, test_pdos_scene 137 -> 142, test_pdos_report 110, every other count equal;
  `registry.py check` REGISTRY_OK (0 failures; 317 `ok` lines, the tree's 315: the include rule ok for
  `pdos_scn_report.c/.h`; with the pre-fix file and the tree's registry.py: `FAIL include rule pdos_scn_report.c: 7
  <stdio.h>; 10 "observe.h"; 27 "w16_obs.h"`, REGISTRY_FAIL), OBS_LINT_OK files 126, OBS_TABLES_OK probes 203 sites 101,
  pdos_scene_check PASS 1084, ADAPT_OK rows 120 steps 25, NODOS_OK (1123 files, 0 hits); the d7a pair 5 of 5 (the same
  lines, the `report` diag line's text unchanged); ext_p0 V0/V1/V2 on `menus` P0_OK 7 checks (the `report` line opens
  1, ends 1, portraits 11, other 0).
* **A look at the frame** (private, not a test): the DOS-form run's N show at 55.57 s (`obj/run/report-n.png`, from
  `--dump-presented`): "CITY STATUS" centred at the top in white, "Empire of the Romans", "Emperor Augustus: 4000 BC",
  Rome's row with its figures and "Militia (0/10)" at x 172 on dark grey; the A show at 57.02 s shows the DOS map again
  (`obj/run/after-a.png`).

## Deviations from the brief

1. **`tests/harness/ext_timeline.py` and `ext_p0.py` unchanged.**  No recorded flow reaches a fade of the return: City
   Status names kind none, and the reports and scenes with 1B44 or 1BEB come with D7b, D7c and the city view.  The
   fade-in and its abandonment are covered by `test_pdos_report`'s fade vectors (the weights frame by frame, the 1B44
   and 1BEB starts, the end at frame 30, abandonment by a new trigger, the log steps) and `test_pdos_profile`'s
   `test_return_fade` (through the profile: the map slots held, abandonment by an N scene, the advance to frame 30); the
   report's timeline steps (`report`, `report_copy`, `report_end`, `return` kind 0, no fade step) and its N and A shows
   are checked by `ext_adapt.py`'s d7a pair.  The first D7 unit with a fading scene adds the ext_timeline case.
2. **ShowTopFiveCities's title row** is added with F1's enumeration (font 1, inferred), although D7c renders Top 5: F1
   asked for every report-title site.
3. **The production column's pen text** is drawn in colour 15 (DOS's one string), not the core's grey 7.
4. **Monochrome mode** (the opener's background 0) is not distinguished: the page takes the background the opener
   passes.
5. **`PDOS_OWNER_MAX` 5 -> 6** (`pdos_shadow.h`): the renderer is the fifth owner (setup, pmap, replay, aplay, report),
   and test_pdos_profile's synthetic owner needs one more slot (D6e's "+ one"); a later owner raises it again.
6. **`present/dos/pdos_scene_tab.c` unchanged**: rows 25, 67 and 98 exist; D7a sets their readiness.  The rows' prose
   for DOS-PROFILE.md is in "For the records".
7. **The portraits load at every report opener**, not only the advisors' (the state read at use; D7b draws them).
8. **The DOS-form run opens City Status with Ctrl+1** (the core's accelerator, which D6f's I-play/I-pass rows pass on
   A).  D6f's F1 maps to the same accelerator; its own checks are D6f's, so the d7a pair keeps Ctrl+1.

## What the user checks

On the user build `build/user-builds/d7b/` (D7a and D7b landed together; `civ64.exe`, DOS files present), in play (load a saved game or
start a new one, with at least one city) with the DOS graphics (Ctrl+Shift+Backspace or the host menu):

* **D7a-1** ADVISORS > City Status (or F1; Ctrl+1 works too): the whole window shows a 320 x 200 DOS screen (in the 4:3
  shape when "4:3 aspect ratio for 320 x 200 screens" is checked, square when it is not) on a dark grey background: the
  title centred at the top in white without a shadow, the empire and the leader/year lines below it, then one row per
  city (name, size and figures, and at the right the production with its progress in white).  No Go Back or Cancel row.
  The mouse pointer is hidden while the report shows.
* **D7a-2** Any key or a click anywhere (on or off the report) closes it (with more than 20 cities the first key or
  click shows the next page); the DOS map returns at once, without a fade, with its menus, windows and the pointer as
  before.
* **D7a-3** The same with the Windows graphics: City Status as before (the Windows report window, unchanged).

Not part of this check: the other advisors and the World reports (D7b, D7c), the advisor portraits (D7b draws them), the
text boxes' headers (D7g), switching the graphics while a report shows.

## For the records

* **DESIGN 12.x "As implemented (D7a; area B and C)":** the report renderer and its table (rows 67, 98, 25 made ready by
  the renderer; row 97 held during ProcessCity(city, -1)); the shadow owner "report" (window and port at the logical
  resolution, the DOS background, the title drawn again unshadowed, the copies to page 0); the production column's pen
  text; decision 3's exit kinds and the return in `pdos_fx` (the trigger, the 30-frame fade-in, the map slots held,
  abandonment C.9; the fade-out of 1B44 abandoned); the page-2 portraits and T1; I-report; the `report` diag line.
* **FIDELITY** (new entries, numbers to be assigned): (a) the return's fade-out of R:0238:1B44 is not shown (the core
  has left the scene first; the fade-in starts from black) (decision 3, ruling 3); (b) City Status's production column
  in colour 15 at the DOS width of the name (the core's pen text; DOS's one string), the improvement truncated by
  R:1F4D:04F7's rule; (c) the report title's font: id 7 -> DOS font 1 at the report-title sites, inferred (OB4 open);
  (d) a click anywhere closes an O14 report (class X: passed at the I5 point in the window, else at its centre); the
  right button is consumed where DOS's any button ends the wait; (e) monochrome mode's background not distinguished; (f)
  the advisor portraits loaded at every report opener from the state read then.
* **DOS-PROFILE.md prose** (rows as implemented in D7a): row 25 (dialog 148): ready while a report of the renderer's
  table shows (the window bound, its earlier readiness restored at the end); row 67 (Advisors > City Status): drawn as
  O14:186F over the core's report (the N frame, the rows by the replay, the production pen text), the exit kind none;
  row 98 (the O14 frame and its close): the frame of every report in the table (fill, title, copies), the close by any
  key or click (I-report), the end at the window's destruction; 2.4 F18 (as staged); Open 16's F1 gap closed (as
  staged); OB4 stays an inference.
* **RUNNING.md:** presentation-diag.log's `report` line (opens, ends, fills_window, fills_port, titles, pens, copies,
  city_holds, portraits, portrait_none, other, return_none, return_1b44, return_1beb, fade_ended, fade_abandoned);
  timeline.log's steps `report`, `report_copy`, `report_end` (sequence 1) and `return`, `return_fade_end`,
  `return_fade_abandon` (sequence 3, PDOS_SEQ_FX_FADE); ext_adapt's d7a-report-dos and d7a-report-win runs;
  test_pdos_report.
* **FEATURES.md:** the DOS City Status report in play (D7a), with the runners above.
* **STATUS.md:** D7a landed (rows 25, 67, 98; F1 closed; the return's exit kinds in place for D7b, D7c and the city
  view); the shadow owners 5 of `PDOS_OWNER_MAX` 6.
* **manual-checklist-ext.md:** new items D7a-1..D7a-3 (above).
* User direction 2026-10-16 (no added Go Back / Cancel rows): the report shows none; its close is DOS's any key (and any
  click), so there is no row to remove.  Report items: none.
* Not edited by this unit (as the brief says): DESIGN.md, FIDELITY.md, STATUS.md, RUNNING.md, FEATURES.md,
  DOS-PROFILE.md outside F7, F18, Open 16's paragraph and the generated section 1.7.2, manual-checklist-ext.md, the D1
  drafts and the D0 documents.

## Expected changes at the build slot

* **Unit** (Checked and Release): test_input 502 -> 506, test_pdos_profile 51 -> 59, test_pdos_scene 136 -> 141, a new
  program test_pdos_report (110); every other count unchanged.  Portable sources 296 -> 297; obs_lint files 124 -> 126;
  probes 203 and call sites 101 unchanged.
* `pdos-scene-check.txt`: PASS 1078 -> 1084 checks, font rows 8 -> 10.  `adapters-check.txt`: ADAPT_OK rows 116 -> 120
  steps 25.  `registry-check.txt`: REGISTRY_OK, 0 failures, two more include-rule lines (`pdos_scn_report.c/.h`; 315 ->
  317 `ok` lines).  `obs-tables.txt`: unchanged.  `nodos.txt`: byte counts grow with the binaries, the sources and the record;
  NODOS_OK.
* `ext-adapt.txt`: EXT_ADAPT_OK checks 189 -> 194 (the d7a lines); two more runs (d7a-report-dos, d7a-report-win; 60 s
  of virtual time each, about 10 s of host time each here).
* presentation-diag.log (harness): a new `report ...` line after the replay's line.  timeline.log: `report`,
  `report_copy`, `report_end` (sequence 1) and `return` (sequence 3) only in runs that open City Status (the d7a pair,
  ext_p0's `menus`): no golden holds them (ext_timeline's runs are the intro's and Birth's).
* ext_p0: P0_OK with unchanged counts; `menus`' `pdos_rows` without `r67.unexplained` (row 67 is not a gate row).
  ext_zoom, ext_frames, ext_mirror, ext_timeline: unchanged (none of their runs opens City Status).
* Core outputs, G-1 fields and `ext_g1.py check`: unchanged (presentation only; the d7a pair and ext_p0 V1/V2 equal
  their references).

## Rebase notes

* **Rebased onto D6f** at 04:57 UTC on 2026-10-17, after D6f's RELEASE_OK (04:54 UTC): every base refreshed from the
  tree (`obj/base/`; the earlier bases of 03:03..03:52 UTC kept in `obj/base-pre-d6f/`, the staged copies before the
  rebase in `obj/pre-rebase-d6f/`), each staged copy three-way merged from its earlier base, its staged copy and the
  tree's file (results in `obj/rebase-final/`, then staged).  The merges went as the trial merges against D6f's staged
  copies had predicted: `pdos_adapt.c`, `pdos_adapt_tab.c`, `pdos_profile.c` and `harness.c` merged without a conflict;
  the others conflicted only where both units add lines at the same place, resolved by keeping both, D6f's first:
  * `pdos_adapt.h`: D6f's `PDOS_AS_PLAY` .. `PDOS_AS_ANONE` (0x00200000 .. 0x01000000), then D7a's `PDOS_AS_REPORT`
    0x02000000 (no bit shared) and its doc paragraph.
  * `adapters.py`: SCENES: D6f's four rows, then D7a's; D6f's `A_SCENES` unchanged (`PDOS_AS_REPORT` is an N-canvas
    scene, frame 1); the generated text: D6f's sentence ending "I-pass's elsewhere" followed by "; extension D7a:
    I-report's rows for the O14 reports the DOS report renderer draws). The".
  * `docs/DOS-PROFILE.md`: F7, F18 and Open 16 merged cleanly; section 1.7.2 regenerated with `adapters.py` on the
    merged tree (not by hand).
  * `tests/test_input.c`: D6f's vectors, then D7a's four I-report vectors; the row count 116 + 4 = **120** (D6f's
    message with "; D7a: 4 I-report rows"); D7a's `ad_setup` lines for `PDOS_AS_REPORT` merged cleanly.
  * `tests/harness/ext_adapt.py`: the docstring paragraphs, the blocks (D6f's, then D7a's before D4c2's section) and the
    calls in `main` (D7a's `d7a_runs` after D6f's): all kept.
  * `harness.c`: D6f's `preskin` line, then D7a's `report` line.
* **`docs/DOS-PROFILE.md` again** (the coordinator's D6f record pass in the tree at 05:08 UTC: rows 12, 15 and 121, the
  menu bar's paragraph, L19 and L25): merged three ways without a conflict (`obj/rebase-docpass/`), D7a's delta
  unchanged (F7, F18, Open 16, 1.7.2); `adapters.py check` ADAPT_OK rows 120 steps 25, `adapters.py gen` leaves the
  merged file unchanged, `obs_tables.py --check` OBS_TABLES_OK probes 203 sites 101 and `pdos_scene_check.py` PASS 1084
  checks, rerun on the overlay. * **Rechecked on the merged tree** (section "Results", every private build, unit, check
  and run repeated): while a report shows the frame is N (`pdos_scene_wants_n`), so the I-report rows decide and D6f's
  I-play rows do not see the report's keys; Ctrl+1 on A reaches the core as its accelerator through D6f's I-play/I-pass
  rows.  The other staged files had bases D6f did not change (their merge is the staged copy).
* **One comment corrected in the rebase:** DrawTextAtPen's address in `pdos_scn_report.c/.h` reads 10D8:002D.
* The `extension D7a` blocks are delimited where they add more than a line; one-line hunks carry an `extension D7a`
  comment.
* **The owner table:** D7a raises `PDOS_OWNER_MAX` 5 -> 6 (setup, pmap, replay, aplay, report, and the one slot
  test_pdos_profile's synthetic owner needs; D6f registers no owner).
* **D6g** landed at 05:14 UTC, before the bases' recheck of 05:17 UTC: it changed `tests/harness/ext_p0.py` (a read-only
  reference here: da186fd5... in `BASE-SHA256.txt`, the runner of the private ext_p0 runs after the rebase) and added
  its record; no D7a base.  ext_p0's decision-8 rows: the report's events are counted on row 67 instead of 98 while a
  report shows, and the owner explains the report window's and port's fills and copies; rows 25, 67, 97 and 98 are D7's
  (not gate rows): no gate row changes.  The D6 gate cycle (ALL_GREEN 06:02 UTC) changed no D7a base either
  (`build/d7a-prep/land.py --units d7a` dry run: every base and reference unchanged).
* **D7b** (`build/d7b-stage/`) is staged on D7a's copies: its bases for the files D7a changes are D7a's staged copies
  ("d7a-stage" in its `BASE-SHA256.txt`); its edits to the shared tables follow D7a's in separate blocks.
* Shared counts: one new source pair (portable sources +1, obs_lint files +2), the obs tables unchanged (probes 203,
  call sites 101: D7a adds no probe or call site).
* **E4 recheck (2026-10-17 about 07:30 UTC):** the tree is the D6 gate's state (D6g changed only `tests/harness/ext_p0.py`
  and docs; the 06:54 copy-in was backed out byte-equal to `tree-before`): every base and reference of `BASE-SHA256.txt`
  equal to the tree, no rebase needed.  The registry fix adds `gen/dos/registry.py` (base: the tree, LF) to the staged
  files.  `gen/dos/registry.py` is shared with D7j (`build/d7j-stage/`): D7a's block sits after `"pdos_aplay.c",`, D7j's
  at the set's closing line; a three-way merge keeps both (D7j's line may then name `pdos_scn_report.c` a second time,
  harmless, or drop it).  The user's reworks D6fS, DBL and UX5b land before D7a: rebase on them at the slot as above.
* **`docs/DOS-PROFILE.md` again (E4, 07:33 UTC):** a docs pass of the D6 gate changed the tree's file after the 07:29
  recheck (the decision-8 gate-row paragraph before 1.1, rows 14 and 19, F10, L10's note): merged three ways with
  `git merge-file` on copies (`obj/rebase-e4/`: the old base, D7a's copy, the tree's file of 07:33) without a conflict;
  D7a's delta unchanged (F7, F18, Open 16, 1.7.2); the base in `BASE-SHA256.txt` is the tree's file of 07:33
  (`5a4ce265...`).  On the overlay `adapters.py gen` leaves the merged file unchanged, `adapters.py check` ADAPT_OK rows
  120, `obs_tables.py --check` OBS_TABLES_OK probes 203 sites 101, `pdos_scene_check.py` PASS 1084 checks.
* **Running the registry check in the overlay:** `obj/src/gen/dos/registry.py check --dosdata <tree>\build\dosdata
  --disasm <tree>\build\dos\disasm` (the overlay has no `build\dos\disasm`; without `--disasm` the check stops at "no
  listings").

## Build-slot steps

The scripts are in `build/d7a-prep/` and land D7a alone (`--units d7a`, user build `d7a`) or D7a and D7b together
(`--units d7a+d7b`, one cycle, user build `d7b` with the D7a-.. and D7b-.. checks; each unit keeps its own record and
Landing section, as D5f, D5cR and D5eR did).

1. **Bases:** `land.py --units d7a` (or `d7a+d7b`) without `--write`: every base of `BASE-SHA256.txt` (and with D7b,
   D7b's "d7a-stage" bases equal to D7a's staged copies and its "tree" bases to the tree), every staged copy's listed
   SHA-256 and the read-only references (build.cmd, test.cmd, `pdos_scene_tab.c`, `ext_timeline.py`, `ext_p0.py`):
   `DRY_RUN_OK`.  If the tree moved (a landing after these bases), rebase first (section "Rebase notes").
2. **Predictions** (`build/d7a-prep/predictions.txt`, before the copy-in) from "Expected changes" (with D7b, its
   record's as well) on the tree's last cycle.
3. **Snapshot and copy:** `land.py --units ... --write`: the tree's Checked test outputs into `build/d7a-prep/before`,
   the tree's previous files into `build/d7a-prep/tree-before`, the staged files byte for byte (a file both units
   stage lands as D7b's copy), `landed.sha256` and `landed-at.txt` (the units named).
4. **The cycle:** `d7a-cycle.ps1` (from `mk_cycle.py`; D6f's with the names changed): `build.cmd checked`, `test.cmd
   checked` (the counts in "Expected changes"), `ext_g1.py check` (EXT_G1_OK unchanged), status
   `build/d7a-status.txt`, logs `build/d7a-<n>-<step>.log`; the known flake (w32_test_host_win32's GetKeyState): rerun
   that program alone, then the test step with `-RunSuffix -r2`.  Then `-FirstStep 4 -LastStep 4`: Release,
   RELEASE_OK.
5. **Comparison:** `compare.py` (the Checked outputs against the snapshot, host times left out).
6. **User build:** `fill_stillopen.py d7a` (or `d7b`; the checklist's pending rows, read only; a build it does not know
   gets a plain line, printed as GENERIC for rewording) on `WHAT-TO-CHECK.d7a.draft.txt` (or `.d7b.`), then
   `mk_userbuild.py d7a|d7b DAY TIME CLTIME`: `build/user-builds/d7a/` (or `d7b/`).
7. **Landing section:** `add_landing.py d7a TEXT DAY` (and `d7b` for D7b's record) with the cycle's numbers.

## Landing

D7a landed together with D7b (`docs/ext-D7b-record.md`, "Landing") in one three-step cycle at the build slot of
session E4 (track A), 2026-10-17, with E4's registry fix ("Registry fix" above); E3's landing of 06:54 UTC had been
backed out (`build/d7a-prep/BACKED-OUT.txt`).  The user checks D7a-1..D7a-3 are in the user build `d7b`.

* **Bases:** rechecked against the tree at 08:05 UTC on 2026-10-17 (the D6 gate's tree with the D6 docs passes up to
  07:38 UTC; `land.py --units d7a+d7b` DRY_RUN_OK 30).  Scripts in `build/d7ab-prep/` (copied from E3's
  `build/d7a-prep/`, which stays as the record of E3's backed-out attempt).  Snapshot `build/d7ab-prep/before` (the
  tree's `build/test/Checked`, which still held outputs of E3's aborted D7a test step) and `tree-before` (the 25
  replaced files); copy-in at 08:07:35 UTC (`landed.sha256`: 30 files from the two stages, a file both stage lands as
  D7b's copy, 5 references unchanged; `landed-at.txt` "units d7a+d7b").  Predictions `build/d7ab-prep/predictions.txt`,
  written before the copy-in.
* **The three-step cycle** (`build/d7ab-status.txt`): 1 `build.cmd checked` BUILD_OK 08:07:45..08:12:43 (298 s;
  portable sources checked 297); 2 `test.cmd checked` TESTS_OK 08:12:43..08:45:16 (1953 s; TEST_SECTIONS 29 failed 0;
  no flake rerun); 3 `ext_g1.py check` EXT_G1_OK runs 77 (amended 1) unchanged: **ALL_GREEN**.  4 `build.cmd` (Release)
  BUILD_OK 08:45:32..08:50:57 (324 s; portable sources 297): **RELEASE_OK**.
* **Against the predictions** (`compare.py` against E3's snapshot `build/d7a-prep/before`, the D6 gate's complete
  outputs; 47 of 63 files equal, host times left out): as predicted, unit.log test_input 502 -> 522, test_pdos_profile
  51 -> 59, test_pdos_scene 136 -> 141, test_pdos_shadow 175 -> 181, test_pdos_report new 169, every other count equal;
  registry-check REGISTRY_OK with the two include-rule lines of `pdos_scn_report.c/.h` added; OBS_LINT_OK files 124 ->
  126; OBS_TABLES_OK probes 203 sites 101; pdos_scene_check PASS 1078 -> 1084 checks, font rows 8 -> 10; ADAPT_OK rows
  116 -> 123; EXT_ADAPT_OK checks 189 -> 198 (the d7a-report and d7b-info lines, equal to the private runs'); NODOS_OK,
  files 1752 -> 1764, 0 hits; P0_OK checks 476; every other section's result equal.  Not predicted, explained: (a)
  ext-replay's informational V1 `menus` counter line (its pass conditions, kind_mismatch 0 and point_mismatch 0, hold):
  brackets 0/314/0 -> 0/314/126, device 33 -> 78, draws 0 -> 75, muted 347 -> 442, no_shadow 416 -> 245, s3_deferred 0
  -> 8: the report owner now shadows the report window and port, so the replay draws the reports' texts there and the
  port-to-window copies are deferred after the replay's leave (S3); (b) ext-p0's V4d `menus` line: 869 -> 847 shows with
  the zoom layer (the run's six reports now show the N frame, not the zoomed A frame; the check count 476 unchanged);
  (c) coverage.txt "other functions entered" 663 -> 662 (informational: the union of the coverage files the test
  programs and harness runs wrote; the core's outputs, G-1 and P0 are equal).
* **User build** `build/user-builds/d7b/`: `civ64.exe` (the Release build, SHA-256 cef67410...), `CIVWIN.zip` and
  `civdos.zip` from `build/user-builds/d4/`, `WHAT-TO-CHECK.txt` (D7a-1..D7a-3 and D7b-1..D7b-6, the earlier builds up
  to "d6g", and the 53 items still pending in the checklist at 08:51 UTC).
* Not done at this slot: the checklist sections and STATUS rows (the orchestrator's); the tree's CheckedNoObs build is
  not part of the three-step cycle (the private overlay builds and units of the three variants are in "Results").

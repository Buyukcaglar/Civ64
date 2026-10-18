# Extension phase D5, unit D5b (class R re-skins on the N canvas, `pdos_reskin`) - record

Draft of the staging implementer (session E3, 2026-10-16), written in `build/d5b-stage/docs/`; the build
slot moves it to `claude/port/docs/ext-D5b-record.md` and completes "Status" and "Results (build slot)".

Authority: `docs/verify/BRIEF-d5.md` (decisions, the orchestrator's Rulings; unit D5b), the Rules of
`BRIEF-d4.md`; design: draft B 11.1..11.4, 6.1 (Choice B2), 6.4 (Choice B4), 4.4 (the menu-box model),
10.1, 10.4, OPEN P17, OPEN L28; draft C C.12.5, C.14.2, C.14.3, C.15.2; `ext-D5a-record.md` (S4, L(d)).

## Status

Staged in `build/d5b-stage/` (full copies of 14 existing files, 3 new files, `BASE-SHA256.txt`); nothing in
the tree, no build.cmd or test.cmd change (`BUILD-TEST-ADDITIONS.md`).  Based on D5a's staged
`pdos_profile.c` and on D4cF's staged `pdos_adapt.c/.h`, `pdos_adapt_tab.c`, `test_input.c` and
`DOS-PROFILE.md`, as the coordinator directed; the rest on the tree.  Private checks over an overlay of the
tree and every stage that lands before it: see "Results (private)".  The build slot's cycle has not run on
it.

## What was built

### The builder and the elements (`present/dos/pdos_reskin.h/.c`, new; B 11.1, 6.1)

* **`PdosRSpec`** is a box's content in DOS terms: id (its window), kind (MENU, MSGBOX, BUILT for D5c..D7
  renderers), font, DOS position, header lines then rows (each row `' ' + text`), the w16 control, its
  screen rectangle and the core's item index of each row, a disabled bit mask and the highlighted row.
  `pdos_r_spec_header` folds the core's text (10.4; a builder may pass the DOS program's static text raw,
  PROF 3.4), splits at line feeds and wraps at 34 columns by R:1F4D:0088's rule (Choice D5b-3), dropping a
  line's leading spaces and `_` (R:1D05:04EF would read such a line as an item).  `pdos_r_spec_row` folds
  and removes `&` marks (`&&` keeps one `&`).
* **`pdos_r_set`** lays the box out with B 4.4's `pdos_menubox_layout` in the spec's font (DOS font 1 by
  default, Choice D5b-4), clamps it inside the 320 x 200 canvas (moved left or up, y keeping its parity so
  the framed / frameless form of R:1D05:05E4 is kept, 11.3), allocates the element's surface, seeds it with
  the **composed** page 0 under the element (`pdos_compose_n_read`, below), draws the box with
  `pdos_menubox_draw` on a shallow copy of `pdos_mn()` whose page 0 is that surface, highlights the row
  with `pdos_menubox_select` and sets it as an opaque N element (B2: composed at frame time, z in first-set
  order, at most 4 at once).  A frameless box's bar colours therefore read what DOS would read there; it is
  drawn again when page 0's generation changes.
* **Highlight by the model's recolouring.**  When only `sel` changed, `pdos_r_set` / `pdos_r_select` move
  the highlight on the drawn box (R:1D05:0238), so the DOS order is kept, including **OPEN L28's effect**:
  a disabled row's colour 3 becomes 22 after the highlight leaves it (the bar's 22 -> 3 / 3 -> 22 swap).
* **`pdos_r_hit(frame, x, y)`** (11.4): frame 1 only (frame 2, the A canvas, has no element until D6f);
  topmost element first; the row from `pdos_menubox_row`, its disabled state, control, rectangle and item.
  Pure: it reads the last layouts, never w16.
* **`pdos_reskin_anchor(hwnd, x, y)`** (11.3): a scene renderer's DOS position for a window's box, taken at
  its next build, forgotten at the window's destruction (8 anchors).

### What the observer side builds (B 11.2; `CIV_OBSERVER` only)

* **Menu box.**  At MenuZ 1220:0156's ENTER the call is pushed (x = arg 4, y = arg 5, the text from arg
  2..3); at its first key poll (pdos_seq's `mz_polls`) it is bound when its dialog (`mz_dlg`) is the window
  of a class R scene row drawn by the re-skins (rows 14 and 22: ShowTextDialog 1220:00D2's dialogs 136
  and 145).  Header: the MenuZ text up to its first `_` (SplitMenuText 1220:0032's title).  Rows: the
  RanDoMRadio item controls 500 + k by id (text, enabled), then **one extra last row for a visible Go Back
  (102) or Cancel (2)** with the core's button text, disabled in colour 3 (OPEN P17).  The highlight
  follows `mz_sel` (g_menuSelection 12B0:009C as the key polls read it; deviation D5b-1).  The box is
  rebuilt when an event names its dialog or a child (TEXT, ENABLE, SHOW, HIDE); it is dropped at the
  dialog's HIDE or DESTROY.  The MenuZ EXIT pops the call; the box stays with its dialog.
* **Message box (Choice B4).**  At `OBS_WND_SHOW` of a `#MsgBox` the record is read with the new
  `w16q_msgbox` (below): its laid-out lines as header lines (folded, wrapped again at 34 columns), one row
  per button, the default button highlighted; `OBS_FOCUS` on a button moves the highlight to it (Return
  chooses the focused button).  Position: L(d) of the window's top-left from the N canvas's reference (the
  512 x 320 device rectangle centred on the desktop, D5a S4), y rounded down to even (Choice D5b-5: a
  framed box), then any anchor, then the clamp.  No caption and no icon (deviation D5b-2).  Kept until the
  window's HIDE / DESTROY.
* **B4 in the generic fallback** (`pdos_profile.c` `update_wover`): `pdos_reskin_is_elem(h)` leaves a
  window shown as an R element out of the windows over the N scene, so a `#MsgBox` over a ready N scene no
  longer forces the A frame.  ShowErrorMessage's MessageBox keeps the A frame through its own class W
  scene row 141 (the row is the top non-R row while it runs); B4 therefore changes the presented kind only
  for a `#MsgBox` with no W row of its own over a ready N scene (_ErrorMessage 1000:4124's).
* `pdos_profile.c`: `pdos_reskin_reset()` in `dos_reset`, `pdos_reskin_on_event` as on_event step 4 (B
  2.1), `pdos_reskin_on_probe` with the scene renderers at ENTER and EXIT.

### `w16q_msgbox` (`platform/w16/w16_obs.h/.c`, `user_msgbox.c`, `tests/harness/obs_lint.py`)

The reviewed getter of draft A 5.2 that the brief names: `W16qMsgBox` (window, up to 24 lines of 160
bytes, text origin, icon, up to 3 buttons with id, window and label, the default button).  `user_msgbox.c`
gains `w16_msgbox_info` (CIV_OBSERVER): it finds the record in the running message-box chain (`g_mb` and
its `outer` links) and answers only for a live, visible window; `w16q_msgbox` wraps it and notes a bad
handle in `g_diag.bad_handles` as the other getters do.  obs_lint's REVIEWED_CALLS gains
`w16_msgbox_info`.  `tests/test_observer.c` runs w16's own MessageBox (MB_YESNO, MB_ICONQUESTION) and
checks the answers at the box's create (not answered), show (the laid-out lines, icon, text origin, the
buttons' ids, labels and windows, the default's index) and destroy (not answered), for a window that is
no box, and after the box is gone.

### `pdos_compose_n_read` (`present/dos/pdos_compose.h/.c`)

`pdos_compose_n_read(rect, below, dst, pitch)`: page 0's rows of the rectangle with the visible N
elements below `below`'s z place composed over them (opaque and clip honoured; all elements when `below`
is not an element).  It is the "frameless box sampling the composed page 0" of the brief.

### The input side (`pdos_adapt.c/.h`, `pdos_adapt_tab.c`; C.12.5, C.14.2, C.14.3)

* **Scene `PDOS_AS_RMENU`**: `def_scene` takes it when the topmost R element is a core MenuZ's box
  (`pdos_reskin_menu`), before the title states; `sc->box` is that box's layout and `sc->r_hwnd` its
  dialog.  Core READY when that MenuZ is in its input loop for that dialog with a selection (`mz_active &&
  mz_ready && mz_dlg == r_hwnd && mz_sel >= 0`), else WAIT.  The adapter acts only on frame-1 (N canvas)
  events; on the A canvas every event passes in the Windows layout as before.
* **Two new hooks** at the end of `PdosAdaptHooks` (`r_hit`, `r_view_row`), defaulting to `pdos_r_hit` and
  `pdos_reskin_view_row`; the row under a point (`box_row_at`) and the drag highlight (`h_box_view`) use
  them for RMENU and the title box's model for BOX, so press / move / release, the R2 key repeat and the
  STEP / ROW / HIGHLIGHT view actions serve both.
* **Eleven `I-menu` rows** (table 38 -> 49 rows; 1.7.2 regenerated): Alt keys, the right button and
  characters consumed (Help of dialog 145 and command 109 are D6's); the edges consumed (no wrap); Up /
  Down, Return / Escape passed; Space as Return; a hotkey as the item's letter (select only); other keys
  consumed; the press drags the box's own highlight (C.12.5, view only); the release on an enabled row with
  a core item clicks that item's control and then Return once the core's selection is it
  (`q_click_sel_return`); a release outside, on a disabled row, or while MenuZ is not in its loop is
  consumed; keys pass while it is not in its loop.
* **The Go Back / Cancel row**: it has no core item, so its release is consumed; Escape reaches the core
  (the dialog's cancel, as on the Windows box).  A click on the row is D5c / D5e's (they build their own
  boxes with the control).

### OPEN L28 (colour 22, y = 139), read where a D5 box can meet it

* The colour effect is reachable through the builder: the incremental highlight reproduces it
  (test_pdos_reskin `test_framed`).  On the generic MenuZ box the highlight follows the core's selection,
  which never rests on a disabled item, and the drag view skips disabled rows: the effect is not reachable
  there.  D5c's setup pages and D5e's boxes, which may show a disabled row, meet it through the same path.
* y = 139: the model's frameless bar2 colour at y 139 (8, not 22) applies only when a box is drawn at
  y = 139.  The generic boxes use the core's MenuZ y or L(d) (message box, rounded even); none is 139 in
  the 25 recorded flows.  A D5c / D5e anchor at y = 139 meets it.

## Tests

* **`tests/test_pdos_reskin.c`** (new; B 15.1's N parts; a synthetic two-font set, no game or DOS file):
  the builder (folding, `&` marks, line feeds, the wrap, leading `_`); a framed box (row height 8 of font
  1, colours 7 / 15 / 8, the disabled colour 3, the highlight and the L28 3 -> 22 history); a frameless box
  (bar colours read from the composed canvas, an R element under it included; z order; removal); the clamp at (300,
  190) in font 2 with parity kept; `pdos_compose_n_read` below an element and outside the canvas;
  `pdos_r_spec_msgbox` from a synthetic `W16qMsgBox` (CIV_OBSERVER); `pdos_r_hit` (rows, disabled,
  controls, outside, frame 2 none); a full table, `pdos_reskin_menu` / `is_elem`, an empty spec, reset;
  a leak check.  63 checks (Checked, Release), 56 (CheckedNoObs).
* **`tests/test_input.c`**: hooks `a_r_hit` / `a_r_view`, `ad_setup` for RMENU, a vector for each of the
  11 rows (the row-count check is 49; I-menu/release's vector: the click's three events on item k's
  control and the pending Return) and `adapt_rmenu` (the drag highlight on the box's own window through
  `r_view_row`, not the title's view; a disabled row keeping it and its release consumed; the release on a
  row without a core item, and while MenuZ is not ready, consumed).  250 / 223 / 250 checks.
* **`tests/test_observer.c`**: `test_msgbox_query` and the listener's queries at create / show / destroy:
  108 / 1 / 97 checks (was 103 / 1 / 92).

## Results (private, `build/d5b-stage/obj/`)

Labels: static compile checks, headless unit tests and harness runs of this port; no original program,
no DOS program, nothing of the tree or a shared output folder written.

* **Overlay** (`obj/mkoverlay.py`): `src-base` = the tree, BS12 (host_win32.c with BS1's block), UX1's
  subset, BS34, D4cF (but pdos_seq.c/.h), D5a (but pdos_seq.c/.h), and pdos_seq.c/.h as `git merge-file`
  of D5a's and D4cF's copies resolved keeping both sides, D4cF's first (`obj/merge/`; identical to D5a's
  trial: 471a14fa... / 7b0fdd69...).  `src` = `src-base` with this stage on top.
* **Strict compile** (build.cmd's flags: /std:c11 and /std:c17 /W4 /WX, the clang-tidy C99 parse) of
  pdos_reskin.c, pdos_compose.c, pdos_profile.c, pdos_adapt.c, pdos_adapt_tab.c, w16_obs.c, user_msgbox.c:
  CC_STRICT_OK in Checked, CheckedNoObs and Release.
* **Everything built** (portable sources, all unit tests, the harness, the Win32 host, civ64.exe):
  CC_ALL_OK in all three variants.
* **Unit tests**: 44 of 44 pass in each variant (RUNTESTS_OK), counts above.
* **obs_lint** (this stage's copy, `obj/lint_priv.py`): OBS_LINT_OK files 99 probes 203 callsites 98 over
  `src` (97 files over `src-base`).  **adapters.py check** (`obj/adapt_priv.py`): ADAPT_OK rows 49 steps 12.
  **obs_tables.py --check** over the staged DOS-PROFILE.md: OBS_TABLES_OK probes 203 sites 98.
* **P0 and the DOS frames against the base** (`obj/hpriv.py`, Checked): ext_p0.py's 25 runs (its
  scenarios and gate3b's `s3`; not the s2/s2b/s2c save chain) on both builds with V1's options and
  `--profile-samples 100`.  All 25: **PASS P0** (core trace and exit status equal); **0 profiles.log
  sample lines differ** in every run (17,307 sample lines in all); presentation-diag.log equal but for the
  host wall-clock fields `pmap snap_us` / `snap_turn_max_us`.  ShowTextDialog runs in 12 of the 25 flows
  (arrival 3, conquest 4, menus 3, research and research2 2 each, city, load, orders, quiz, retire,
  revolution, spaceship 1 each), never with a ready N row below it, so its box is built but not presented
  (the equal samples).
* **ext_timeline's goldens** on the D5b build: the 6 intro and 8 Birth golden frames equal
  ext-timeline-golden.txt.
* Not run privately: `ext_adapt.py` (it writes into build/adapt, build/run and build/harness): the build
  slot runs it.  The adapter differs from the base only while a re-skinned menu box is topmost and the N
  frame is presented, which no recorded flow reaches.

## Decisions and deviations

1. **D5b-1 (deviation): the highlight follows the core's selection**, not "the checked or focused child":
   `W16qBtn` has no checked state; g_menuSelection read at MenuZ's key polls is the core's own state.  The drag highlight is view-only and kept until the core's selection
   moves.
2. **D5b-2 (deviation): the message box** is a menu box of its lines and one row per button; DOS's
   "OK in an outline" form, the caption and the icon are not modelled.
3. **Choice D5b-3**: header lines wrap at 34 columns (R:1F4D:0088's rule).
4. **Choice D5b-4**: the generic re-skins use DOS font 1 (the play font; OB4 stays open).
5. **Choice D5b-5**: a message box's y is rounded down to even, so it is always the framed form.
6. **Help and sound on a re-skinned box**: the Help button of dialog 145 is not drawn as a row and Alt+H,
   the right button and Alt+V are consumed (C.12.5 gives them to D6's I-menu rows).
7. **A message box has no adapter scene in D5b** (C.12.5's rows are the menu boxes'; the unit's input
   side is "for menu boxes"): with B4 its N-canvas input follows the scene below.  Keys reach the core,
   whose message box has the focus (Return chooses the focused button, which the box highlights); a
   press on the N canvas is consumed where the scene below consumes presses (I-none, I-title/hold) and
   passed in the Windows layout where it passes them (I-title/chosen).  Clicking a button row of a
   re-skinned message box is a later unit's (`pdos_r_hit` gives its control).  Reachable only for an
   _ErrorMessage box over a ready N scene (above).
8. **Elements are built on any frame**: a bound MenuZ box is built in play too, where the A frame is
   presented and N elements are not shown; this keeps one path for D6, when play becomes N.
9. **Files beyond the unit's list**: `w16_obs.h/.c`, `user_msgbox.c`, `obs_lint.py`, `test_observer.c`
   (the `w16q_msgbox` getter the unit uses), `pdos_adapt.h` (the RMENU scene, the hooks), `adapters.py`
   (the RMENU scene word in 1.7.2's scene list; "MenuZ ready" wording) and DOS-PROFILE.md 1.7.2
   (regenerated, decision 3).

## Rebase (the build slot)

* D5b's copies of `pdos_profile.c` (D5a's), `pdos_adapt.c`, `pdos_adapt.h`, `pdos_adapt_tab.c`,
  `test_input.c` and `DOS-PROFILE.md` (D4cF's) **replace** those stages' copies: they contain them.  Land
  D5b after D4cF and D5a; if either stage changes those files first, merge its change into these copies
  and, for DOS-PROFILE.md, regenerate 1.7.2 with `gen/dos/adapters.py gen` and run `gen/obs_tables.py
  --check`.
* D5b does not change `pdos_seq.c/.h`; it reads `mz_polls`, which D4cF adds, so D5a's pdos_seq merge with
  D4cF (ext-D5a-record.md, "Rebase") is a prerequisite.
* No other in-progress stage (CY, UX1, BS12, BS34) has a copy of any D5b file.  The other files are based
  on the tree, unchanged since (BASE-SHA256.txt).
* Line endings: each copy keeps its base's (CRLF: pdos_adapt.c, pdos_adapt.h, pdos_profile.c,
  test_input.c; LF: the rest, and the new files).

## What needs the build slot

1. Rebase (above), copy the 17 files into the tree, move this record to `claude/port/docs/`.
2. The cycle: `build.cmd checked`, `test.cmd checked`, `ext_g1.py check` (and the usual variants).  The
   new test is found by the wildcards; `d3a_obs_lint` needs the staged obs_lint.py; the adapters section
   needs the staged adapters.py and DOS-PROFILE.md.
3. Expected harness changes: **none** in any recorded expectation.  The private comparison found no DOS
   frame, core trace, diag or golden change in the 25 runs.  The boxes D5b draws are presented only when
   the top non-R scene row is a ready N row (the intro, the title, Birth and the setup rows while their
   views are on): no flow opens dialog 136 / 145 there (12 flows open them, none with a ready N row
   below) and none shows a `#MsgBox` there.  So no DOS-frame expectation changes for the menu box, the message box or the
   Go Back / Cancel rows.  7.3 (ext_p0) and 7.4 (ext_frames) compare runs with each other; ext_adapt's
   pairs do not reach an RMENU scene.
4. The one presented-kind change B4 makes when it is reached: a `#MsgBox` without a W row over a ready N
   scene now presents the N frame with a DOS box where the base presented the A frame (with the Windows
   message box); `pdos_diag.w_over_n` no longer counts it.

## User checks this makes possible

None in a user build of D5b alone: no known user flow reaches a scene where D5b's boxes are presented
(in the recorded flows dialogs 136 / 145 open with no ready N row below, mostly in play, which presents
the A frame until D6; ShowErrorMessage keeps the A frame by its W row; _ErrorMessage is a fatal
runtime-error path).  The first user-visible use
is D5c's setup pages through D5b's builder and anchor; checks to add then, on D5b's parts:

* a re-skinned menu box: DOS colours (box 7, bevel 15 / 8, items 0, disabled 3), font 1 rows of 8 pixels,
  the bar's highlight, and Up / Down / Return / Escape / a hotkey / a drag and release behaving as DOS;
* a Go Back or Cancel row as the last row in the item colour, Escape going back;
* a box near the canvas edge moved fully inside.

## For the records

* DESIGN.md 12.x: "As implemented (D5b)": `pdos_reskin` (builder, elements, hit geometry, anchors), the
  observer side (bound MenuZ boxes, B4 message boxes), `pdos_compose_n_read`, the RMENU adapter scene and
  its hooks, `w16q_msgbox`; Choices D5b-3..5 and deviations D5b-1, D5b-2.
* Draft B 11.1..11.4, 6.1 (B2) and 6.4 (B4) implemented for the N canvas; 11.3 / 11.4 for the A canvas stay
  D6f's.  OPEN P17 settled as one extra last row (core text, item colour, disabled 3).  OPEN L28 read
  (above): reachable through the builder; y = 139 only through a renderer's anchor.
* Draft A 5.2: `w16q_msgbox` added (the observer getter list and obs_lint's REVIEWED_CALLS).
* Draft C C.12.5 for re-skinned menu boxes (I-menu's D5b rows); I-menu's help / Alt+V rows and message-box
  input stay for D6 / later units.  C.15.2's re-skinned menu-box vectors added to test_input.
* DOS-PROFILE.md: 1.7.2 regenerated (decision 3); no OFFSETS row (D5b reads no new DOS offset; the
  R:1D05 / R:1F4D addresses cited are B 4.4's).  Row 141's W note (FIDELITY F79) is unchanged: its
  MessageBox keeps the A frame.
* No FEATURES.md, RUNNING.md or manual-checklist change now (no new diag counter, no user-visible scene);
  the user checks above go in with D5c.

## Landing (build slot, 2026-10-16)

D5 stager, in the build slot after the BS phase gate (`build/bs-status.txt` ALL_GREEN 00:10:04 UTC) and the
BS docs pass (`build/docs-bs-done.txt` 00:24:28 UTC).  One landing in the planned order: UX1b, then D5a + D5b,
then D5c (the latest copy of every file the three D5 stages changed).

* **Copy** (00:24:40 UTC, `build/d5l-prep/land.py`): 46 files, each only while the tree's file still had the
  expected SHA-256 (the base its copy or merge was made on; a new file had to be absent).  Manifest
  `build/d5l-prep/landed.sha256`; the tree's previous files in `build/d5l-prep/tree-before/`.
* **Rebase.** BS34 landed its staged copies unchanged for every file the D5 chain had based on them
  (`pdos_profile.c`, `test_pdos_seq.c`, `registry.py`, `ext-timeline-golden.txt`, ...), so 40 of the 46 files
  landed as staged.  `pdos_seq.c` / `pdos_seq.h`: the tree's (BS's merge of BS34 with D4cF, 918254a5... /
  199f161a...) is contained in D5c's copies: the change from the tree to D5b's merge (471a14fa... /
  7b0fdd69..., D5c's base) is D5a's own change (BS34's pre-merge to D5a) line for line, apart from one blank
  line (`build/d5l-prep/cmpdiff.py`), so D5c's copies landed as staged.  Three clean three-way merges
  (`git merge-file -p`, output to `build/d5l-prep/merge/` only, no conflict): `present/profile.h` (UX1b's
  comment on BS's file), `docs/DOS-PROFILE.md` (D5c's on the tree's UX1 paragraph and C2 row; base D4cF's
  staged copy) and `tests/harness/ext_timeline.py` (D5c's checks on BS's `bs_birth` / `bs_skip` scripts).
* **Regenerated / checked on the tree:** `gen/dos/registry.py gen` (159 files, 19 tables, unchanged) and
  `check` REGISTRY_OK; `gen/dos/adapters.py gen` (DOS-PROFILE.md unchanged by it: 1.7.2 with 75 rows) and
  `check` ADAPT_OK rows 75 steps 19; `gen/obs_tables.py --check` OBS_TABLES_OK probes 203 sites 98;
  `gen/dos/nodos.py check` NODOS_OK; `tests/harness/pdos_scene_check.py` PASS 1075 checks;
  `tests/harness/testpar.py check test.cmd` exit 0.  build.cmd and test.cmd are unchanged (the new sources and
  tests are found by their wildcards).
* **One fix at the slot** (the only failure): the first `test.cmd checked` failed one of its 24 sections,
  ext_continue: `FAIL dos: the DOS view follows the core into its setup: the 640x480 A frame shown at None
  us`.  BS4's check expected the A frame after Birth's hand-over; since D5c the DOS view shows the DOS setup
  page there (the same change as ext_timeline's `birth` 3 / `birth_skip`).  D5c's private harness did not run
  ext_continue, so its prediction did not list it.  `tests/harness/ext_continue.py` check 1 now requires
  timeline.log's `setup_page` step at the hand-over, the first DOS show within one second of it and every DOS
  show from the hand-over on the 320x200 N frame (re-evaluated over the failed run's outputs first: PASS, the
  setup page shown at 172402350 us).  No compiled source changed, so the cycle was rerun from step 2.
* **The cycle** (`build/d5l-status.txt`, logs `build/d5l-<n>-<step>[-r2].log`):

| step | result |
|---|---|
| 1 `build.cmd checked` | exit 0, BUILD_OK, 283 portable sources (c11, c17, c99 parse).  The build ended at 00:34:39; the step's 727 s include the wait for the compiler's telemetry helper (vctip.exe), which the build left running and the cycle's process wait included, until it was stopped at 00:43 |
| 2 `test.cmd checked` | first run exit 1 (ext_continue, above); rerun `-r2` exit 0, TESTS_OK, 24 sections, 0 failed, 1043 s |
| 3 `ext_g1.py check` | `-r2` exit 0, EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) |

ALL_GREEN at 01:20:28 UTC.  Only the Checked variant ran (the slot's three steps); CheckedNoObs and Release
were built and tested privately in the stages only.

* **Differences from the BS gate's Checked outputs** (`build/d5l-prep/compare.py` against the snapshot
  `build/d5l-prep/before/`, taken before the cycle):
  * presentation-diag.log (178 runs): `pdos unexplained` lower exactly as D5c predicted (V1, V2, ... runs of
    birth 680 -> 670, new and s3 675 -> 615, earth 602 -> 541, custom 640 -> 580, settlers 670 -> 610; 30
    runs); the new fields `setup_text_diff 0` (D5c) and `n_clip 0` (D5a, S4) in every run; nothing else but
    the pmap timing fields, which vary run to run.
  * profiles.log: all 90 equal.  ext_p0: P0 PASS in every scenario (TESTS_OK).
  * ext_timeline: `birth` 3 and `birth_skip` with the DOS setup page at the hand-over, `birth` 4 (the Birth
    goldens, including frame 12000 = d67d465f..., the T4 difficulty page) equal the landed golden;
    EXT_TIMELINE_OK, the bs group (bs3_timeline) EXT_TIMELINE_OK unchanged.
  * ext_adapt: EXT_ADAPT_OK checks 56 -> 68: D5c's four pairs d-setup-escape, d-setup-portrait,
    d-setup-tribe and d-setup-goback, three PASS lines each.
  * ext_frames: `s3` and `birth` presented.log lengths (s3 671 -> 672 lines, 645 -> 643 tick shows; birth
    3054 -> 3050, 3032 -> 3031): the DOS frames after the hand-over are now the setup page; every A against A'
    comparison still passes.
  * adapters-check rows 38 -> 75, steps 12 -> 19 (D5b's I-menu and D5c's I-setup rows); dos-decoded.txt and
    registry-check: D5c's 8 rows; obs-lint files 97 -> 101 (the four new files); nodos files scanned
    1671 -> 1680; coverage's informational "other functions entered" 661 -> 662 and 665 in the two runs of
    the same landed build (it varies run to run).
  * Nothing else differs.
* D5b's tests in the slot's run: test_pdos_reskin 63, test_observer 108, test_input 293 checks (now D5c's
  copy, which contains D5b's I-menu vectors), all PASS; d3a_obs_lint OBS_LINT_OK files 101 with this stage's
  obs_lint.py (`w16_msgbox_info` reviewed); registry check REGISTRY_OK with `pdos_reskin.c` / `pdos_reskin.h`
  in OBSERVER_FILES (the include-rule fix, landed with D5c's registry.py).

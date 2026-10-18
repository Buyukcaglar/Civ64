# Record: base-track fix RV4 P47-R2 (list dialogs show their border and scroll bar when they open)

Written 2026-10-15 by the P47-R2 implementer of extension session E3, under
`docs/verify/BRIEF-p47r2.md`. Authority: the user's decision of 2026-10-11 about 08:00 UTC
(STATUS.md "User directions": the scroll bar is displayed when the list's popup opens if and only
if the list holds more items than fit on one page). Cause: `verify/phase4-review-4.md` "RISK
P47-R2". Nothing here is an observation of the original game or of Windows 3.1; claims about
Windows 3.1 are labelled **inference**, the port's rules are **choices** implementing the user's
decision, and the test expectations are the port's model (model, self-consistency).

## Result

Implemented and tested; **the eight-step cycle is not yet ALL_GREEN** (see "Eight-step results"):
step 2 failed only on checks of extension unit D4b3's in-progress DOS Birth files (`present/dos/`,
`tests/test_pdos_seq.c`, `tests/harness/ext_timeline.py`, outside this unit; reported, not fixed)
and on `ext_p0.py`'s V0 comparison with the G-1 baseline, fixed by applying the G-1 amendments
there too (the change was made at 09:52 UTC, while step 2 was still running; it ended 09:55; review
finding 9). The cycle is to be run again once D4b3's checks pass.

When Find City (DIALOG 131) or the Civilopedia's list (DIALOG 130's created "Listbox") opens,
after the opening paints the list shows its black border and, when its items need more than one
page, its scroll bar (Find City: vertical; the Civilopedia: horizontal); when the items fit, the
border only. The same after each Civilopedia hide/show (1098:1C72, 1C8F). The fix is in
`platform/w16/user_wnd.c` only; `core/`, `rt/`, `gen/`, `present/` and the generated files are
unchanged, no game code changes, no core state (snapshot, checkpoint, result) changes in any run.

A second defect on the same path was found and fixed (see "Deviations"): Find City with more cities
than rows never finished its opening in the port (the harness run stopped at the step watchdog in
RunListBoxDialog's loop, 1098:1BEE), because showing the list's vertical bar exposed the windows
below the dialog and the loop, which passes messages to IsDialogMessage only, then retrieved the map
window's WM_PAINT for ever. In civ64 this would have hung the game, not only stopped the harness:
an unranged PeekMessage admits host input only when it finds nothing (F86), so no key or click
entered while the WM_PAINT kept being returned (by code reading; corrected 2026-10-15 after review
finding 1). Rule 2 removes that one exposure; the class of hang (any other window's WM_PAINT in such
a loop, for example after the game screen follows a host resize, F110) remained and is closed by
base-track unit P47b (`p47b-record.md`).

## Mechanism and why

**Rule 1, frames painted over (choice implementing the user's decision; candidate (b) of the brief,
narrowed).** At EndPaint of a window without WS_CLIPCHILDREN (its paint DC covers its descendants),
every visible descendant whose non-client area (its window rectangle less its client rectangle)
meets the region just painted is marked "frame needs painting" (`Wnd.nc_pending`). The descendant's
next BeginPaint sends it WM_NCPAINT (wParam 1) first, before it takes its update region and sends
WM_ERASEBKGND. DefWindowProc's WM_NCPAINT (`nc_paint`, which draws the whole frame, also the
synchronous one of showing, moving and exposing a window) clears the mark. The mark alone does not
make the window retrieve WM_PAINT and does not invalidate it.
`user_wnd.c`: `mark_frames`, `nc_meets`, w16_BeginPaint, w16_EndPaint, nc_paint; rule in the file
header ("Frames painted over").

Why this one:
* **Closest to Windows 3.1 (inference):** Windows 3.1 keeps a per-window "frame needs painting"
  state that BeginPaint serves by sending WM_NCPAINT before the client paint. It sets that state
  when the window's non-client area is invalidated, and the synchronous paint of a show or move or
  the next BeginPaint serves it; a parent's later paint does not set it, so Windows 3.1 most likely
  showed the same artifact (which is why the user had to decide). Marking at the parent's EndPaint
  is the port's own rule, without a Windows 3.1 counterpart (wording corrected 2026-10-15, review
  finding 8). The port had no such state: its frames were drawn only synchronously (show, move,
  expose), and BeginPaint never sent WM_NCPAINT, so a parent's later client paint covered a child's
  frame for good. Not observed here.
* **Narrowest that meets the requirement:** the mark is set only where a non-clipping parent really
  painted over a frame, and is served only by the descendant's own next BeginPaint. In the game the
  list's WM_PAINT follows the dialog's in the same paint cycle (both are invalidated together; the
  dialog's paint is retrieved first, parent before child), so the frame is drawn back in the same
  cycle. Not adding an invalidation (the brief's (b) "and is invalidated") keeps the client paints,
  WM_ERASEBKGND and WM_CTLCOLOR messages exactly as before: the only new message is the list's own
  WM_NCPAINT. Candidate (a) in full (a pending frame on every show, move, frame change and parent
  invalidation) would change when every frame in the game is drawn (the port draws them
  synchronously today, accepted in phase 7), a much wider change than the decision needs.
* **Messages added to game window procedures: none.** The game subclasses only its own windows and
  dialogs, never controls; the windows with a non-client area under a non-clipping parent are the
  three list boxes (LISTBOX 103 of DIALOG 131, 104 of DIALOG 140, the Civilopedia's "Listbox"), whose
  procedure is w16's own LISTBOX. DIALOG 140's list gets a WM_NCPAINT that draws the same pixels it
  had (it is filled while hidden; its frame is not painted over by a snapshot). The game's own
  top-level windows and dialogs are not children of a non-clipping parent's paint in this sense
  (top-level), and the EDIT controls have no border (F34), so nothing else is marked.

**Rule 2, a bar shown or hidden repaints the window itself only (choice; inference about Windows
3.1).** SetScrollRange's hide/show of a standard bar (P4-7) recalculates the client area and
repaints the window as before (frame at once, client area and children invalidated with the
synchronous erase, WM_SIZE when the client size changes) but no longer exposes the window's old
rectangle in its parent and in the windows below: the window's rectangle does not change
(`set_rect`'s new REPAINT_FRAME mode; `w16_SetScrollRange`; rule in the SetScrollRange comment).
Inference: Windows 3.1 redraws the changed frame only (a frame change without a move or size).
Before, the port repainted as for MoveWindow to the same rectangle, which invalidated the windows
below the list's dialog, the map window among them; RunListBoxDialog's loop (1098:1BEE: PeekMessage,
IsDialogMessage, no DispatchMessage for other windows) then retrieved the map window's WM_PAINT
for ever, so a Find City list that needed its bar never finished opening in the harness (virtual time
does not advance while PeekMessage keeps returning a message). The game's own SetScrollRange calls
are on the map window, which always has both bars and never an empty range (1208:0D89, 0DA1, 1138),
so only the list boxes use this path. Messages added to game window procedures: none. What it
removes (corrected 2026-10-15, review finding 4), in the many-cities Find City case only: the
removed exposure sent the dialog WM_NCPAINT and the synchronous WM_ERASEBKGND (DefDlgProc passes it
to the dialog procedure and sends WM_CTLCOLOR(CTLCOLOR_DLG)); the dialog's WM_PAINT is not removed,
its whole client area was invalid already. It also sent WM_NCPAINT and WM_ERASEBKGND, and left a
pending WM_PAINT, to every other top-level window whose rectangle meets the list's: the map
window's game procedure at least, the Status and World Map windows where they overlap. No base
output depends on it (the case never completed; G-1 shows no change from it).

## Files changed

* `platform/w16/user_wnd.c`: `Wnd.nc_pending`; `nc_meets`, `mark_frames`; w16_BeginPaint (WM_NCPAINT
  first when marked), w16_EndPaint (marks the frames painted over), nc_paint (clears the mark);
  `set_rect` REPAINT_FRAME and w16_SetScrollRange; header rule "Frames painted over" and the
  SetScrollRange rule.
* `tests/test_user.c`: `test_p47r2` (six cases, 12 new checks) and its paint-filling window procedure
  branch; header bullet.
* `tests/harness/p4tests.py`: frame-dump reading (`Frame`, `list_rect`, `find_bar`,
  `list_frame_check`, `dump_stable`, `stable_of`); `t_findcity` checks the list's frame (`p49-findcity`,
  five items: border, no bar) and now dumps its stable frames; new test `listbar`
  (`p49-findcity-bar`, `p49-pedia`, `p49-pedia-units`); `run` creates the frame folder; docstring.
* `tests/harness/ext_g1.py`: the amendment list (`ext-g1-amend.txt`) applied by `check`
  (`load_amendments`; a line needs RUN FIELD SHA256 NFRAMES and a reason naming the user decision;
  the amended frame count is checked; unknown runs or fields, duplicates and malformed lines fail;
  the OK line names the amended runs: `EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)`).
* `tests/harness/ext_p0.py` (outside the brief's list; see "Deviations"): `baseline()` applies the
  same amendments (via `ext_g1.load_amendments`) to V0's comparison with the G-1 baseline, and the
  PASS line says "as amended (ext-g1-amend.txt)"; docstring.
* `tests/harness/ext-g1-amend.txt` (new): `game/p4-menus` frames and events.
* `docs/p47r2-record.md` (this record).

Not changed: `user_listbox.c`, `user_dlg.c`, `user_ctl.c`, `user_scrolltrack.c`, `gdi_dc.c`,
`rgn.c`, `w16_int.h`, `user.h`, `scenarios.py`, `features.py`, `gate3b-golden.txt`, `test.cmd`,
`ext-zoom-golden.txt`, `ext-timeline-golden.txt`, and every file outside the brief's list.
(True when written; `test.cmd` (10:04 UTC), `w16_api.h` and `w16_unimpl.c` (10:06 UTC) changed
afterwards, not by this unit; review finding 9.)

## Tests and counts

From the cycle's step 2 (`build/p47r2-2-test-checked.log`, Checked) unless noted:

* `test_user`: PASS 331 checks, 0 failures (319 before; `test_p47r2` adds 12: (1) a list with ten
  items under a parent without WS_CLIPCHILDREN whose WM_PAINT fills its whole client: the parent's
  paint covered the frame, and after the paint cycle the border, the vertical bar's line, arrows
  (black triangles) and thumb are drawn again, equal to the frame before; (2) three items: no bar,
  the frame is the border only; (3) hide and show: border and bar back; (4) a hidden multicolumn
  list (the Civilopedia's style 0x40900203) shown under the parent's paint: border and horizontal
  bar; (5) a bordered child's message order WM_PAINT, WM_NCPAINT, WM_ERASEBKGND after the parent
  painted over its frame, and no WM_NCPAINT when the parent painted away from the frame or inside
  the child's client area; (6) a WS_CLIPCHILDREN parent: frame untouched, no WM_NCPAINT). With
  rule 1 disabled 8 of these checks fail.
* `p4tests.py` (P4_TESTS_OK): `findcity` 7 checks for `p49-findcity` (3 new: frame dumped, border,
  no bar); `listbar` 17 new checks (`p49-findcity-bar` 5: 30 items, border, vertical bar;
  `p49-pedia` 8: topic page shown, border and horizontal bar when opened and again after the topic's
  hide and show; `p49-pedia-units` 4: border, no bar).
* G-1: `EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)` on the step-2 outputs (run by
  hand after the failed step 2; step 3 itself did not run).
* `ext_p0.py Checked --vars V0 --only menus` after the `ext_p0.py` change: `PASS V0 menus equals
  ext-g1-baseline game/p4-menus as amended (ext-g1-amend.txt)`, `P0_OK checks 1`.
* Also in step 2: GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK (108 of 108 rows), EXT_FRAMES_OK,
  EXT_ADAPT_OK checks 20, MIRROR_OK runs 29, ZOOM_OK combinations 32 runs 64 samples 388, TRACE_OK,
  REGISTRY_OK, NODOS_OK, OBS_TABLES_OK, OBS_LINT_OK.

## Changed base outputs

Method: the runs that open DIALOG 130 or 131 (events.log `dialog 82`/`83`: p4-menus, p4-research,
p4-research2, p49-findcity, p49-find-wonder, uninit-s4, uninit-s5) and DIALOG 140 (p4-city) were run
with the fixed build before the cycle, and `game/p4-menus` also with the build before the fix (run
id `p47r2-old-menus`, equal to the G-1 baseline in all three fields); the cycle then reran
everything.

* **`game/p4-menus` frames** (G-1 amended): exactly six frame lines differ, the stable frames of the
  six Civilopedia list openings; the frame count (1844), every other frame and the state are
  unchanged. Reason: P47-R2, the list's border (and, where the items exceed one page, its horizontal
  bar) is drawn again after the dialog's snapshot paint. Viewed (frame dumps, old against new):

  | frame | menu command (FEATURES.md row) | after the fix | old sha256 | new sha256 |
  | --- | --- | --- | --- | --- |
  | 938 | 601 Complete (and dialog 130) | border and horizontal bar | fc7b74a0fb1657fdd9dfb9fb63775b5779b9add9ce13c9abf4e61e83265ccd89 | a9316b80bb3f0accc79c5c8deabfb0a2af713dcca12abc48b1e13a18deab1bf3 |
  | 985 | 602 Civilization Advances | border and horizontal bar | 3a3a7f77b7e6a343db4dc3e7574dbd15ba61ae4ed29ab13aa9be8bafe057ab2a | 167e24f35f3970e1cd092a39d8921b168a6cd83ea6b71c5bc57d1ec7468e743e |
  | 1007 | 603 City Improvements | border and horizontal bar | bc89627bb7e036904a0a86d73f8f9c6cd893d1cacb404a9be9ea6d3b22fc12a2 | 17953378a5b8bbdd537b4ac38998d745f84414f58402e83f5b6bc66cb61baf9f |
  | 1028 | 604 Military Units | border, no bar (items fit) | 20d52fbdffc7fd1ce75a0ad5cc1d8e2c807bcda65b934fe0de6e04e907158657 | 978a098d1453cea40b5ce9b46e6f900dae87f1cfbeff1014b1fed76d5d2eb570 |
  | 1050 | 605 Terrain Types | border, no bar (12 items) | dc96c8483007b09e8ffd45f616f2381c2937c694c6fb0339fd5f863655d2d493 | 595b1b2391167347d60200fd3af7ca471d8008cdc7b6ac609528b51a90384851 |
  | 1072 | 606 Miscellaneous | border, no bar (two columns) | f72f72c56af657e47b9fca34e800a3396c66dbd89cae49f1c81afef7ce3996e9 | d5beb7fddc5f40e361b9cf9143090d0433ed09c3775a45460c471fda45afe580 |

  Find City's frame 1174 (dialog 131, one visible city: border, no bar; the border was already
  intact there) is unchanged.
* **`game/p4-menus` events** (G-1 amended): only the sha256 field of the 366 `stable` lines that name
  those six frames (178 for 938, 70 for 985, 48 for 1007, 31 for 1028, 15 for 1050, 24 for 1072);
  no event line is added, removed or changed. Same reason.
* **`game/p4-menus` state**: unchanged (no snapshot, checkpoint or result line differs).
* **`build/harness/features.txt`** (regenerated by `scenarios.py` on every run; not an expectation):
  the rows dialog 130 and 601..606 carry the new hashes above. FEATURES.md's copies are listed under
  "For the records". No expectation in `scenarios.py` or `features.py` names a frame hash, so neither
  changes.
* **New outputs**: `game/p49-findcity-bar`, `game/p49-pedia`, `game/p49-pedia-units` (new runs of
  the `listbar` test; not in the G-1 baseline) and the frame dumps `build/frames/p49-*`.
* **Unchanged**: the other 76 G-1 runs in all fields (p4-research, p4-research2, p4-city,
  p49-findcity, p49-find-wonder, uninit-s4 and uninit-s5 among them), `gate3b-golden.txt` (snapshot
  hashes), `ext-zoom-golden.txt`, `ext-timeline-golden.txt` and every other recorded expectation
  (see the eight-step results).

## Eight-step results

First run (started 2026-10-15 09:19 UTC; `build/p47r2-status.txt`):

| step | result |
| --- | --- |
| 1 `build.cmd checked` | exit 0, 210 s, BUILD_OK |
| 2 `test.cmd checked` | exit 1, 1942 s, TESTS_FAILED=3 (below) |
| 3..8 | not run (the cycle stops at the first failure); status ends `FAILED at 2-test-checked` |

The three failing groups of step 2:
1. `test_pdos_seq`: "C.6.6: Birth's start (SeekSequence ra 11E0:01AA) in the dissolve: abandon with
   finish, page 0 = page 1" (97 checks, 1 failed).
2. `ext_timeline.py`: "birth: 4. the Birth model goldens ... differ at [20, 69, 117, 1500, 4000,
   7000, 10000, 12000]" and "birth_skip: C.8.8: Birth abandoned ... the first after it with the
   core at its setup is none" (EXT_TIMELINE_FAILED=2). The `birth` and `birth_switch` runs' core
   outputs (P0 lines) pass.
3. `ext_p0.py`: "FAIL V0 menus equals ext-g1-baseline game/p4-menus (differs: frames, events)"
   (P0_FAILED=1): V0 compared with the unamended baseline; fixed (`ext_p0.py` applies the
   amendments; see "Tests and counts").

Groups 1 and 2 are D4b3's: the DOS Birth sequencer and timeline (`present/dos/pdos_seq.c`,
`pdos_birth.c`, `pdos_tl.c`, `tests/test_pdos_seq.c`, `tests/harness/ext_timeline.py`,
`tests/test_timeline.c`, `tests/headless/harness*.c`, modified 2026-10-15 08:39..09:10 UTC by that
unit, before this cycle) and do not involve the w16 window manager (a unit test of `pdos_seq` and
the DOS timeline's model goldens). Per the brief they are reported, not fixed. The eight-step cycle
must run again, in one run, after they pass (and after this unit's `ext_p0.py` change).

## Deviations

* **p49-findcity is the no-bar case.** The brief expected `p49-findcity`'s save to have more cities
  than rows; its edited save (FINDCITY.SAV, P4-9) shows five cities, which fit, so `p49-findcity`
  checks the border and no bar, and a new run `p49-findcity-bar` (FINDBAR.SAV: 25 cities of civ 2
  added with `saveedit.py`, every city visible to the human, 30 items) checks the vertical bar.
* **Rule 2 (the frame-only repaint of a bar shown or hidden)** is a second change outside the
  brief's two candidates. Without it the many-cities Find City case could not be tested and never
  finished opening in the harness (pre-existing: the build before this fix stops the same run at the
  same place). It stays in `platform/w16` and adds no message to a game procedure.
* **No invalidation with the mark** (the brief's candidate (b) says "and is invalidated"): not
  needed in the game's list dialogs, where the list's paint follows the dialog's; it would add client
  repaints. A frame painted over while its window has no update region stays covered until its next
  paint (choice, recorded in the header).
* **Escape in the p49 Find City scripts** (a key-down without a character) does not close the dialog;
  the runs end in the dialog loop at their virtual-time limit, as `p49-findcity` did before
  (pre-existing, outside this fix; the checks read the frames while the dialog is open).
* **`tests/harness/ext_p0.py` changed** although not in the brief's file list: its V0 check compares
  with `ext-g1-baseline.txt` directly, so requirement 5 (P0_OK) could not hold with the G-1
  amendment alone. The change only applies the same amendment list (no new expectation); D4b3 does
  not own this file.
* **The cycle is not ALL_GREEN** (see "Eight-step results"): blocked by D4b3's in-progress checks.
* No agent check with a visible civ64 window was made (optional in the brief).

## For the records

Entries for the owners of the documents (this unit edits none of them):

* **DESIGN.md 5**, "Non-client drawing" (P4-2): add that BeginPaint sends WM_NCPAINT (wParam 1)
  first to a window whose frame a parent without WS_CLIPCHILDREN painted over (marked at the
  parent's EndPaint, cleared by any whole-frame drawing; the mark alone is no WM_PAINT reason), and
  that a standard bar shown or hidden by SetScrollRange repaints the window's frame and client only,
  exposing nothing in the parent or below (RV4 P47-R2; rules in `user_wnd.c`'s header "Frames painted
  over" and the SetScrollRange comment; choices implementing the user's decision of 2026-10-11,
  inference about Windows 3.1). "List boxes, statics and DIBs" (P4-7): the list dialogs' lists show
  their border, and their bar when the items need more than a page, once the opening paints are done
  and after each Civilopedia hide/show. Tests: `test_user` (`test_p47r2`), `p4tests.py` `findcity`
  and `listbar`.
* **FIDELITY.md F80**: replace "**Open (RV4 P47-R2):** ... **fix queued, not yet implemented**" by:
  "**Fixed (RV4 P47-R2, 2026-10-15; `p47r2-record.md`):** choices implementing the user's decision:
  a frame that a non-clipping parent's paint covered is drawn again by the window's next BeginPaint
  (WM_NCPAINT before the client paint), so the game's list dialogs show the list's border and, when
  the items need more than one page, its scroll bar once the opening paints are done and after each
  Civilopedia hide/show; a bar shown or hidden by SetScrollRange repaints the window itself only
  (its frame at once, its client area and children invalidated with the synchronous erase, WM_SIZE
  when the client size changes), exposing nothing in its parent or below (inference: Windows 3.1
  redraws the changed frame only; before, the exposed map window stalled RunListBoxDialog's loop
  1098:1BEE when Find City needed its bar, and would have hung civ64, F86). (Text corrected
  2026-10-15, review finding 5: the earlier "repaints the window's frame only" was wrong.) Whether Windows 3.1 showed the
  snapshot over the bar remains not known. User's visual check pending." Keep the "User decision"
  sentence.
* **STATUS.md**: base track "Next concrete step": P47-R2 implemented; eight-step cycle ALL_GREEN once rerun after D4b3's checks pass (first run: FAILED at step 2, D4b3 and the since-fixed ext_p0 V0 check)
  (`build/p47r2-status.txt`), record `p47r2-record.md`; the user's visual check pending. Ledger:
  G-1 amended for `game/p4-menus` frames and events (`tests/harness/ext-g1-amend.txt`, reason
  "P47-R2, user decision 2026-10-11"); the found Find City stall (many cities) fixed with it.
  Line 16/21's "fix queued" wording becomes "implemented 2026-10-15, user's visual check pending".
* **FEATURES.md**: the frame hashes of the rows dialog 130 and menu commands 601..606 (p4-menus
  stable frames 938, 985, 1007, 1028, 1050, 1072) change: take the new ones from
  `build/harness/features.txt` (listed under "Changed base outputs"); the "agent-observed" notes
  of those rows predate the border and bar. Row 131 (frame 1174) is unchanged.
* **verify/phase4-review-4.md**: status of "RISK P47-R2": fixed 2026-10-15 (`p47r2-record.md`),
  the user's visual check pending; in "Effects on the game", the Civilopedia's and Find City's
  "painted over by the dialog's snapshot until the user scrolls" become "shown once the dialog has
  opened (P47-R2 fixed)", and Find City's bullet notes that a list needing its bar no longer stalls
  the dialog's loop (the map window is no longer exposed).
* **manual-checklist-ext.md**: a new pending item for the user's visual check in civ64: Find City
  with more visible cities than rows (vertical bar and border) and with few (border, no bar); the
  Civilopedia's Complete, Civilization Advances and City Improvements (horizontal bar and border),
  Military Units, Terrain Types and Miscellaneous (border, no bar), and Complete again after
  choosing a topic and returning to the list (bar and border back). Pending.
* **EXT-HANDOFF.md item 1a**: implemented; done when the rerun cycle is ALL_GREEN (visual check pending).

Added 2026-10-15 by P47b (review finding 5; the docs agent applied the F80, DESIGN.md 5 and
`phase4-review-4.md` entries with the corrected wording before this addition):

* **STATUS.md** line 236 (the visual-confirmation row: "fix queued") and line 650 ("Queued fix ...
  it is still not started and is item 1a ... Then a FIDELITY F80 update, a headless or Win32-headless
  test of both dialogs ... and the user's check") also need the "implemented 2026-10-15, user's
  visual check pending" wording (line numbers as of the review).
* **FEATURES.md** line 154 ("Windows, screens and effects", row "Civilopedia", frame 938,
  `fc7b74a0...`) carries one of the changed hashes too: frame 938 is now `a9316b80...` (table under
  "Changed base outputs").
* **verify/phase4-review-4.md**: NOTE P47-N4 lists "the dialog repaint (P47-R2)" as a test gap:
  now covered (`test_user` `test_p47r2`, `p4tests.py` `findcity`/`listbar`); RISK P47-R2's "Related
  choice: the SetScrollRange hide/show path repaints 'as by MoveWindow to the same rectangle' ...
  Not recorded, not tested" is resolved by rule 2 (recorded in `user_wnd.c`'s SetScrollRange
  comment and F80; tested directly since P47b, `test_user` `test_p47b` (2)); both need a status line.
* **F80**: the consequence of review finding 7 (a frame covered by a parent's paint that meets only
  the child's frame stays covered until the child paints again) and the inference wording of
  finding 8 (the state is set at invalidation; the EndPaint rule is the port's own).

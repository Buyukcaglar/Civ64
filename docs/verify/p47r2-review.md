# Review: base-track fix RV4 P47-R2 (list dialogs show their border and scroll bar when they open)

Written 2026-10-15 by an independent, adversarial, read-only reviewer (session E3), under the
orchestrator's review request. Read: `verify/BRIEF-p47r2.md`, `p47r2-record.md`,
`verify/phase4-review-4.md` (RISK P47-R2, "Effects on the game"), `DESIGN.md` 5 (window manager,
non-client drawing, list boxes, queue). Code: `platform/w16/user_wnd.c` (header rule, `Wnd.nc_pending`,
`nc_meets`, `mark_frames`, `w16_BeginPaint`, `w16_EndPaint`, `nc_paint`, `set_rect`/REPAINT_FRAME,
`w16_SetScrollRange`, `expose*`, `invalidate_tree`, `paint_walk`, `w16_screen_follow`), `queue.c`
(PeekMessage), `user_listbox.c`, `user_ctl.c` (EDIT), `user_dlg.c` (templates), the tests
(`tests/test_user.c` `test_p47r2`, `tests/harness/p4tests.py` `findcity`/`listbar`, `ext_g1.py`,
`ext-g1-amend.txt`, `ext_p0.py`) and the driving core code (`core/seg020_1098_p1_r.c`
RunListBoxDialog / ListDialogSubclassProc, `seg013_1060.c` OnCivilopediaListSelect,
`seg014_1068_p2_r.c` RunPediaModalLoop, `seg027_10D0.c` CopyPortToWindow). Nothing was built,
run or edited except this report. Two read-only scratch scripts (outside the project) were used:
one listed the DIALOG templates of `build/gamedata/civ.exe` (control classes and styles), one
recomputed the G-1 digests of the existing outputs `build/harness/game/p4-menus` and
`p47r2-old-menus`. Nothing here is an observation of the original game or of Windows 3.1.

## What was verified (no finding)

* **Rule 1 mechanics.** `mark_frames` (user_wnd.c:3251-3267) marks every visible descendant
  (recursively; also under a WS_CLIPCHILDREN child, correct because the painting parent's DC does
  not clip its descendants) whose rectangle-less-client meets the parent's paint region
  (`nc_meets` 3236-3247: an intersection reaching outside the client rectangle). It sends nothing,
  so the child walk cannot be invalidated by a procedure. `w16_EndPaint` (3327-3345) marks only
  for a DCK_WINDOW DC that is painting, of a shown window without WS_CLIPCHILDREN; the desktop is
  WS_CLIPCHILDREN (4586) and is never painted through BeginPaint (`paint_walk` starts at its
  children, 4497-4510), so top-level windows can never be marked. An icon's children are skipped
  (3254). `w16_BeginPaint` (3280-3290) clears the mark before sending WM_NCPAINT (no recursion
  through a nested BeginPaint), re-looks the window up after the send and returns 0 with a zeroed
  PAINTSTRUCT when it was destroyed; then takes the update region and sends WM_ERASEBKGND, which is
  Windows' BeginPaint order. wParam 1 is what every other WM_NCPAINT of the port sends (1632,
  2378). `nc_paint` clears the mark only when it really draws (1427-1430). A hidden marked window
  gets no WM_PAINT; its show (`invalidate_tree`) draws the frame and clears the mark. A destroyed
  window's `Wnd` is freed; `host_alloc` zero-fills, so a reused handle starts unmarked.
* **Requirement, game paths.** Find City: GR_DialogOpen shows the dialog (whole client invalid),
  the template list's border is drawn by the show before the snapshot (1098:19EC), filling shows
  the bar (now REPAINT_FRAME: frame and client of the list only), the loop's first WM_PAINT is the
  dialog's (pre-order), ListDialogSubclassProc blits the snapshot over the list
  (seg020_1098_p1_r.c:558-603), EndPaint marks the list, the list's WM_PAINT sends WM_NCPAINT.
  Civilopedia: the list is created hidden after the snapshot, filled hidden, shown at 1BD0; same
  sequence. Harness evidence (`build/p47r2-2-test-checked.log` 534-557): border and vertical bar
  (`p49-findcity-bar`, 30 items), border and horizontal bar (`p49-pedia`), border and no bar
  (`p49-findcity`, `p49-pedia-units`).
* **The stall.** RunListBoxDialog's loop (seg020_1098_p1_r.c:396-423) calls PeekMessage(hwnd 0,
  PM_REMOVE) and only IsDialogMessage, which returns FALSE for another window's message; WM_PAINT is
  synthesized from update regions (queue.c:533-544) and nothing validates the map's, so the same
  WM_PAINT is returned for ever and a TRUE PeekMessage charges no virtual time. The old path
  (`set_rect` repaint 1 → `expose(&old, list)`) invalidated every top-level window whose rectangle
  meets the list's, the map behind the dialog included (`expose_tree_rgn` ignores occlusion,
  1606-1648). Evidence: `game/p47r2-old` (pre-fix build, the `p49-findcity-bar` script) ends
  `WATCHDOG ... site 1098:1BEE steps 900000000 virtual_us 25051450` (step watchdog, time stuck);
  the fixed run ends at its virtual-time limit (`virtual_us 31000450`).
* **REPAINT_FRAME when a bar is hidden.** The window rectangle is unchanged, so nothing in the
  parent or below is uncovered; the pixels the bar occupied become client area, which
  `invalidate_tree` invalidates (with the synchronous erase) and the list's WM_SIZE handler
  repaints at once through GetDC (`user_listbox.c` 796-800, 551-562, `paint` fills the whole
  client), and its WM_PAINT again. Nothing stays stale. Order: client recalculated (no
  WM_NCCALCSIZE, F80's existing choice), WM_NCPAINT, invalidation and erase, then WM_SIZE: unchanged
  from before except the removed exposure.
* **P0.** The DIALOG templates in `civ.exe` (read-only dump): the game-class controls
  (`RandomUser`, `Region`, `Random*`) are all 0x50000000-type styles without WS_BORDER, frames or
  bars; the only controls with a non-client area are LISTBOX 103 (DIALOG 131) and 104 (DIALOG 140),
  0x50A00001, and the EDIT 103 of DIALOGs 137 and 2000 (0x50810000), whose WS_BORDER the EDIT
  removes at WM_NCCREATE (user_ctl.c:831-837, F34); the game's CreateWindow children (owner-drawn
  and launch buttons, MenuZ statics/buttons, RunTextInputDialog's static/EDIT) have none besides
  that EDIT; all ten game `SetWindowLong(-4)` subclasses target window ports (dialogs and windows),
  never a control. So rule 1 reaches only w16's LISTBOX procedure: no message is added to a game
  procedure. No core memory, clock or queue state is touched (`p4-menus` state hash unchanged). The
  code is portable C without conditionals: identical in the headless and Win32 builds.
* **G-1 evidence, recomputed independently.** `p47r2-old-menus` (pre-fix) equals the baseline in
  all three fields; the current `p4-menus` equals both amended hashes
  (frames `b294e212...`, events `c041d8a3...`), 1844 frames; exactly six frame lines differ
  (938, 985, 1007, 1028, 1050, 1072, same virtual_us, hashes as in the record's table); state lines
  identical; 1897 event lines each, 366 differ, all `stable` lines differing only in the sha256
  (178/70/48/31/15/24), no other line. The record's table and counts are exact.
* **Counts.** `test_p47r2` has 12 CHECKs; with rule 1 disabled exactly the 8 checks at
  test_user.c:2875, 2879, 2885, 2889, 2900, 2918, 2922, 2943 fail by construction (2866, 2873,
  2962, 2981 hold either way), matching the record. Step-2 log: `test_user: PASS (331 checks)`,
  `findcity` 7, `listbar` 17, P4_TESTS_OK, the three failing groups as listed.

## Findings

### 1. MAJOR (pre-existing, outside this fix; does not block it): the RunListBoxDialog stall remains for any exposure of another window, and in civ64 it is a hang

`core/seg020_1098_p1_r.c:396-423`; `platform/w16/queue.c:443-449, 533-544, 558-559`;
`platform/w16/user_wnd.c:1606-1674` (`expose_tree_rgn`/`expose`), `3066-3114` (`follow_window`),
`3116-3156` (`w16_screen_follow`).

Rule 2 removes the one exposure the list's bar caused, but the class of failure stays: while any
list dialog is open, anything that gives a window other than the dialog an update region makes the
loop retrieve that WM_PAINT for ever. `expose` ignores occlusion, so a hide, move or destroy of any
window anywhere invalidates the map window even where the dialog covers it. In civ64 this is not
just a stuck harness: an unranged PeekMessage admits host input only when it finds nothing
(queue.c:443-446, 559; F86), so while the WM_PAINT keeps being returned no key or click ever enters
and the game freezes. Concrete path: in civ64 with the game screen following the host (F105/F110
view mode), resize the host window while Find City or the Civilopedia list is open: every unranged
PeekMessage calls `w16_screen_follow` (queue.c:447-449), which moves/stretches the map window with
`MoveWindow(..., TRUE)` (3111; expose + `invalidate_tree`) and exposes the new screen strips
(3145-3152); the map's WM_PAINT is then returned for ever. The same applied to the pre-fix
many-cities Find City: it would have frozen civ64, not only the harness (the record mentions only
the harness). The Civilopedia's own hide at 1098:1C72 also exposes the map, but harmlessly,
because RunPediaModalLoop (seg014_1068_p2_r.c:386-480) dispatches every message before the list
returns.

Suggested fix (separate unit, user decision because G-1 outputs may move): clip each window's
exposure to its visible region as Windows does (an update region never covers a wholly hidden
window); suspending `w16_screen_follow` is no remedy, because w16 cannot tell that the game sits in
a loop that dispatches only the dialog's messages. At least record the hazard (F80/F110, STATUS)
and add the host-resize case to the user's manual check. Also record in F80 that the pre-fix bar
case froze civ64.

### 2. MINOR: rule 2 has no direct test

`tests/test_user.c:2824-2987`; `tests/harness/p4tests.py:132-135, 470-476`.

No `test_user` case checks that a bar shown or hidden by SetScrollRange leaves the parent and the
windows below without an update region, WM_NCPAINT or WM_ERASEBKGND: `test_p47r2` (1) passes with
or without rule 2 (the parent is wholly invalid anyway). The only coverage is indirect:
`p49-findcity-bar` produces a stable frame after dialog 131 only when the loop does not stall, and
`ends()` accepts the step watchdog and the virtual-time watchdog alike (`result WATCHDOG` both).
Suggested fix: a `test_user` case (a bordered WS_VSCROLL child of a popup that is above a second
top-level window; both painted; LB fill or SetScrollRange show and hide; check that neither the
popup nor the lower window gets an update region or a message, and that the child's frame and
client repaint); in `listbar`, assert that `p49-findcity-bar` reached its virtual-time limit
(`virtual_us >= 31000000`, not `steps 900000000`).

### 3. MINOR: the Civilopedia "after hide and show" harness check is very likely not discriminating, and the hide/show artifact is not shown to exist in the port

`tests/harness/p4tests.py:477-494`; `core/seg020_1098_p1_r.c:453-471`;
`core/seg014_1068_p2_r.c:386-480`; `core/seg027_10D0.c:440` (10D0:08D7).

Between the hide (1C72) and the show (1C8F) the topic runs RunPediaModalLoop, which subclasses the
dialog and dispatches every message, so the dialog's WM_PAINT from the hide's exposure is served
by the topic's paint while the list is hidden (no mark: the list is not visible), and
CopyPortToWindow validates what it draws. At 1C8F the show draws the list's frame and nothing
leaves the dialog an update region, so ListDialogSubclassProc does not blit the snapshot over the
list again. The pre-fix build would therefore most likely pass the `p49-pedia` "after the topic,
hidden and shown again" checks too, and RV4's "the hide/show repeats it" may not hold in the port.
The w16-level sequence is covered by `test_p47r2` (3), so the requirement is tested, but the
harness check proves nothing about the fix. Suggested fix: run `p49-pedia` once with the pre-fix
build (as `p47r2-old` did for the bar case) and either keep the check as a guard, labelled so, or
drop the claim; word the records "verified after the hide/show" rather than implying the fix was
needed there.

### 4. MINOR: the record understates what rule 2 removes from game procedures

`docs/p47r2-record.md` "Rule 2"; `platform/w16/user_wnd.c:1616-1647`, `user_dlg.c:32`.

The record says rule 2 removes "the WM_ERASEBKGND and WM_PAINT that the dialog procedure got for
the exposed area". In the removed path, `expose_tree_rgn` sent the dialog WM_NCPAINT (its `nc` test
is true for every framed window) and the synchronous WM_ERASEBKGND (DefDlgProc then passes it to
the DLGPROC and sends WM_CTLCOLOR(CTLCOLOR_DLG)); the dialog's WM_PAINT is not removed (its whole
client was invalid already). It also sent WM_NCPAINT and WM_ERASEBKGND, and left a pending
WM_PAINT, to every other top-level window whose rectangle meets the list's: the map window's game
procedure at least, the status and world-map windows when they overlap. No base output depends on
it (the case never completed). Suggested fix: correct the sentence in the record and in the F80 /
DESIGN entries.

### 5. MINOR: "For the records" is incomplete and one proposed text is inaccurate

`docs/p47r2-record.md` "For the records"; `docs/STATUS.md:236, 650`; `docs/FEATURES.md:154`;
`docs/verify/phase4-review-4.md:302-308, 344-353`; `docs/FIDELITY.md:117`.

* STATUS.md: besides lines 16/21 and "Next concrete step", line 236 (the visual-confirmation row:
  "fix queued") and line 650 ("Queued fix ... it is still not started and is item 1a ... Then a
  FIDELITY F80 update, a headless or Win32-headless test of both dialogs ... and the user's check")
  also need updating.
* FEATURES.md: line 154 ("Windows, screens and effects", row "Civilopedia", frame 938,
  `fc7b74a0...`) carries one of the changed hashes; the record names only the rows dialog 130 and
  601..606.
* phase4-review-4.md: NOTE P47-N4 lists "the dialog repaint (P47-R2)" as a test gap (now covered),
  and RISK P47-R2's "Related choice: the SetScrollRange hide/show path repaints 'as by MoveWindow
  to the same rectangle' ... Not recorded, not tested" is now resolved by rule 2; both need a
  status line.
* F80 proposed text: "a bar shown or hidden by SetScrollRange repaints the window's frame only" is
  wrong: the client area and the children are invalidated with the synchronous erase and WM_SIZE is
  sent; say "repaints the window itself only (its frame at once, its client area invalidated),
  exposing nothing in its parent or below", as the DESIGN entry and the code comment do.

### 6. NOTE: G-1 amendment mechanism: sound, two hardening suggestions

`tests/harness/ext_g1.py:39-59, 140-157`; `tests/harness/ext_p0.py:252-267, 443-451`.

`check` still fails on any unlisted difference, an amendment for an unknown run or field, a
duplicate or malformed line, a reason without "user decision", a frame-count mismatch, and an
amendment that no longer matches (stale); the OK line names the amended runs. `ext_p0.py` applies
the same list to V0/V5's baseline comparison and only those; its other comparisons are within one
build. Limits: (a) an amendment pins a whole-field hash, so whatever else differed when it was
recorded is absorbed; "only frames 938..1072 changed" is the record's diff (verified above), not
machine-checked. Hardening: store with each amendment the hash of the field with the named frame
lines (and their `stable` lines) removed, which must equal the same digest of the baseline-equal
pre-fix run, and check it. (b) `state` is amendable with any reason naming "user decision",
although the brief makes a state change a stop-and-report condition; refuse `state` amendments.
`ext_p0.baseline()` ignores `load_amendments`' problems (ext_g1 reports them; acceptable). The
CheckedNoObs (step 6) and Release reproductions of the amended hashes are still pending with the
rerun cycle.

### 7. NOTE: a frame that a parent covers without touching the child's client area stays covered

`platform/w16/user_wnd.c:785-798` (`upd_add` clips to the client), `3159-3173`, `3251-3267`.

A child's update region is limited to its client rectangle, so a parent invalidation (or exposure)
that meets only a child's border or bar gives the child a mark but no WM_PAINT; the parent's paint
covers the frame and it stays covered until the child paints for another reason. Windows 3.1
(inference) keeps window-relative update regions that include the frame, so such a child would
get WM_PAINT and its WM_NCPAINT. Not reachable in the game's list dialogs (their paints cover the
whole client, and the lists are invalidated with them). The record's "Deviations" states the
choice; the header states only "the mark alone does not make the window retrieve WM_PAINT".
Suggested fix: state the consequence in the header and F80 (or make a frame-only invalidation set
the mark and queue a WM_PAINT for the child).

### 8. NOTE: the Windows 3.1 inference wording

`platform/w16/user_wnd.c:60-73`; `docs/p47r2-record.md` "Why this one".

In Windows 3.1 (inference) the "frame needs painting" state is set when the window's non-client
area is invalidated and is served by the synchronous paint of a show or by the next BeginPaint; it
is not set by a parent's later paint, so Windows 3.1 most likely showed the same artifact (which
is why the user had to decide). Marking at the parent's EndPaint is a port rule without a Windows
counterpart. The record labels it a choice and keeps "whether Windows 3.1 showed the snapshot over
the bar remains not known", which is right; the header's "leaves a child of a parent without
WS_CLIPCHILDREN to its own paint, after the parent's" can be read as Windows repainting the
child's frame afterwards. Suggested fix: say explicitly that Windows sets the state at
invalidation and that the EndPaint rule is the port's.

### 9. NOTE: untested edges and process details

* No test of nested descendants (a bordered grandchild under a non-clipping grandparent) or of a
  window destroyed by its WM_NCPAINT inside BeginPaint; the code handles both (above), the game
  has neither.
* Between the dialog's paint and the list's paint a present may show the covered frame for one
  (non-stable) frame; the stable frames show the bar. Harmless.
* `tests/harness/ext_p0.py` was modified at 09:52 UTC, while step 2 was still running (it ended
  09:55); the record says "after step 2". Immaterial: the cycle must run again anyway.
  `test.cmd` (10:04 UTC), `w16_api.h` and `w16_unimpl.c` (10:06 UTC) changed after the record,
  not by this unit (the record's "not changed: test.cmd" was true when written).
* The attribution of step 2's `test_pdos_seq` and `ext_timeline.py` failures to D4b3's in-progress
  files is plausible (no list box or bar in the Birth path, which rule 1 and rule 2 cannot reach)
  but is only confirmed when the combined cycle passes.

## Verdict

**Accept (P47-R2 is correct and meets the requirement), with the records corrected (findings 4
and 5), a direct rule-2 test added (2) and the hide/show harness claim settled (3); acceptance
still needs the rerun eight-step cycle ALL_GREEN (EXT_G1_OK "amended 1" in Checked and
CheckedNoObs, P0_OK) and the user's visual check.** No blocker: both rules are correct for every
game path, add no message to a game procedure, change no core state and are identical in both
builds; the G-1 amendment is exact and its evidence reproduces. Finding 1 is a pre-existing hang
class that this fix narrows but does not close; it should get its own unit and a record entry.

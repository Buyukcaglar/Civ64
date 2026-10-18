# Brief: base-track fix RV4 P47-R2 (list dialogs show their scroll bar when they open)

Written 2026-10-15 by the orchestrator of extension session E3. One implementer, on the session's own
model (the user's direction of 2026-10-12 00:20), with exclusive ownership of the files below. This is a
base-track fix queued by the user's decision; it runs before extension unit D4b3 builds.

## Authority

* The user, 2026-10-11 about 08:00 UTC (STATUS.md "User directions"): "scroll bar shall be displayed
  upon related popup/window opening if and only if there are more items present in the list that fits
  to single page. Otherwise player may not understand that s/he has more pages to traverse to find
  desired topic."
* Cause: `verify/phase4-review-4.md` "RISK P47-R2" (and the "Effects on the game" bullets for the
  Civilopedia and Find City). RunListBoxDialog snapshots the dialog's client (1098:19EC) before the list
  is filled or created; ListDialogSubclassProc's WM_PAINT copies the snapshot back over its update region
  (`core` `seg020_1098_p1.c` 773-785, 943-957); the dialog (0x80400080) has no WS_CLIPCHILDREN, so its
  paint DC covers the children; the list's frame and bars were drawn earlier (synchronous WM_NCPAINT) and
  the list's later WM_PAINT repaints only its client (BeginPaint sends no WM_NCPAINT). Result: Find City
  (DIALOG 131) hides its vertical bar, the Civilopedia (DIALOG 130's created "Listbox") its horizontal bar
  and the list's border, until a scroll; the Civilopedia's hide/show around each selection (1098:1C72,
  1C8F) repeats it. City production (DIALOG 140) is not affected.
* Records: FIDELITY.md F80 "Open (RV4 P47-R2)" and "User decision"; STATUS.md base track "Next concrete
  step"; EXT-HANDOFF.md item 1a.

## Requirement

1. When Find City or the Civilopedia list opens, after the opening paints have completed, the list's
   scroll bar is visible if and only if the list holds more items than fit on one page (Find City: the
   vertical bar; Civilopedia: the horizontal bar of its multicolumn list), and the list's border is
   visible. The same after each Civilopedia hide/show. When the items fit on one page, no bar.
2. The fix is in `platform/w16` paint handling. `core/`, `rt/`, `gen/`, `present/` and the generated
   files are unchanged. The game's code is not changed and no game behaviour changes.
3. Choose the mechanism closest to the Windows 3.1 window manager's semantics, and record it as a port
   choice that implements the user's decision (evidence label "inference" for any claim about Windows
   3.1). Candidates (pick one, or a better one, and say why):
   * (a) a pending non-client paint per window (Windows' "frame needs painting"), set when a window's
     non-client area becomes part of an invalidation (show, MoveWindow, a frame change, a non-clipping
     parent's invalidation covering the child), consumed by BeginPaint/UpdateWindow sending WM_NCPAINT
     before the client paint; plus the rule that makes the list's frame be repainted after its
     non-clipping parent painted over it;
   * (b) at EndPaint of a window without WS_CLIPCHILDREN, every visible child whose non-client area
     intersects the region just painted gets its frame marked for redraw (and is invalidated), so the
     child's next BeginPaint sends WM_NCPAINT.
   Prefer the narrowest rule that meets the requirement. List every message the change adds to a game
   window procedure (prefer none; built-in control classes are `w16`'s own).
4. Every base output the change alters must be explained. Expected: only runs that open Find City or
   the Civilopedia (for example `game/p49-findcity` and the scenarios with Civilopedia rows). For each
   changed run or reference: the run, which output (frames, state, events, checkpoint), why.
   * G-1 (`tests/harness/ext_g1.py`, baseline `ext-g1-baseline.txt`, recorded pre-extension and never
     re-recorded): do NOT re-record the baseline. Add an explicit amendment list
     (`tests/harness/ext-g1-amend.txt`: run, field, new hash, frame count, reason "P47-R2, user decision
     2026-10-11") that `check` applies, printing the amended runs (for example `EXT_G1_OK runs 77
     (amended 2: ...)`). An amendment must name the reason; `check` still fails on any other difference.
   * `gate3b-golden.txt`, `scenarios.py`/`features.py` expectations, `ext-zoom-golden.txt`,
     `ext-timeline-golden.txt` and every other recorded expectation: change only an entry the fix
     really affects, with the reason in your record. If a core state (snapshot) changes, stop and
     report before amending: the user's decision is about drawing only.
5. P0 stays: `ext_p0.py` P0_OK (it compares variations within one build), EXT_FRAMES_OK, MIRROR_OK,
   ZOOM_OK, EXT_TIMELINE_OK, EXT_ADAPT_OK, all base tests.

## Tests

* `tests/test_user.c` (portable unit test): a dialog-like parent without WS_CLIPCHILDREN whose WM_PAINT
  fills its whole client over the children (the snapshot's effect), with a list box: (1) more items than
  a page: after the paint cycle the bar's pixels (arrow and thumb) and the border are present; (2) items
  that fit: no bar; (3) a hide/show of the list repeats (1); (4) a multicolumn list with a horizontal
  bar. Also a case with WS_CLIPCHILDREN unchanged.
* `tests/harness/p4tests.py`: `p49-findcity` checks the bar strip's pixels in the frame after the dialog
  opened (bar present; the run's save has more cities than rows); a Civilopedia check (an existing
  scenario that opens it, or a new small run) for the horizontal bar and the border; and, if a save
  with few enough cities exists or can be made with `saveedit.py` (as P4-9 made FINDCITY.SAV), a Find
  City run without a bar. Frame pixels come from the harness's frame dumps (`--dump-frames` or the
  existing mechanism the p49 runs use).
* A short agent check with a visible civ64 window is allowed but not required (civ64 windows only,
  screenshots under `claude/port/build/p47r2-ui/`). The user's visual check follows; list it as pending.

## Rules

* **Files you own:** `platform/w16/user_wnd.c`, `user_listbox.c`, `user_dlg.c`, `user_ctl.c`,
  `user_scrolltrack.c`, `gdi_dc.c`, `rgn.c`, `w16_int.h`, `user.h` (only what the fix needs),
  `tests/test_user.c`, `tests/harness/p4tests.py`, `tests/harness/ext_g1.py`,
  `tests/harness/ext-g1-amend.txt` (new), `tests/harness/scenarios.py`, `features.py`, `gate3b-golden.txt`
  (only for explained entries), `test.cmd` (only if a step must be added), and your record
  `claude/port/docs/p47r2-record.md`. Do not edit `present/`, `tests/headless/`, `tests/test_timeline.c`,
  `tests/test_pdos_*`, `tests/harness/ext_timeline.py`, `build.cmd`, or any document other than your
  record: list the entries for DESIGN.md 5, FIDELITY.md F80, STATUS.md, `phase-4-review-4.md`'s status
  and `manual-checklist-ext.md` (the user's check) under "For the records".
* **Builds are yours alone** during this unit (Checked, `checked noobs`, Release; no Asan, the user's
  direction of 2026-10-10 21:20). Another agent may be editing `present/dos/` files at the same time
  without building; ignore its in-progress files. If a build fails in a `present/` file you did not
  touch, report it at once instead of fixing it.
* **The eight-step cycle** after the last source change, in one run, logs `build/p47r2-<n>-<step>.log`,
  status `build/p47r2-status.txt` ending `ALL_GREEN`: 1 `build.cmd checked`, 2 `test.cmd checked`,
  3 `C:/Python314/python -B tests/harness/ext_g1.py check`, 4 `build.cmd checked noobs`, 5 `test.cmd
  checked noobs`, 6 `ext_g1.py check --variant CheckedNoObs`, 7 `build.cmd`, 8 `test.cmd`. Timeout
  600000 ms per command (`test.cmd checked` takes about 33 minutes: run it in the background and wait
  for its completion notice). Earlier focused builds and runs are fine.
* Never modify `C:\Projects\Civ1RE\original\CIVWIN`, `C:\Projects\Civ1RE\dos`, `claude/port/build/dosdata`
  or `build/gamedata`; never execute a DOS program on the host. No git writes. Absolute paths; no `cd`
  chaining. Python only as `C:/Python314/python -B` (never `-I`). Write files containing backslashes with
  the Write or Edit tool, not shell heredocs. Independence: never read the main project's excluded paths
  (`verify/BRIEF-d0.md` lists them); ignore AGENTS.md's GFX/DOS/Modern/Mac/SNES sections.
* Keep your context lean: read the code you change and its direct callers.
* If the orchestrator sends "wrap up", stop adding, make the build and tests green and write the record.

## Record and final message

`claude/port/docs/p47r2-record.md`: the mechanism and why; the files changed; the tests and counts; every
changed base output with its reason; the eight-step results; deviations; "For the records". Final
message: result, files changed, test counts, changed outputs, deviations, the "For the records" list.

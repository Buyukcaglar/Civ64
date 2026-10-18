# Brief: base-track unit P47b (P47-R2 review fixes; list-dialog stall on exposure)

> **Cycle rule changed 2026-10-15 about 14:09 UTC (the user's decision, STATUS "User directions"; `verify/BRIEF-cy.md`):** wherever this brief says "the eight-step cycle", a unit now ends with the **three-step cycle** (`build.cmd checked`, `test.cmd checked`, `ext_g1.py check`); the full eight-step cycle runs only at phase gates (D4, BS, D5, D6, D7, X9, WL and before the final Asan pass).

Written 2026-10-15 by the orchestrator of extension session E3. One implementer on the session's own
model, exclusive ownership of the files below, after D4b4 (it starts when the orchestrator gives it the
build slot). Read first: `verify/BRIEF-p47r2.md` (the earlier unit's brief and rules, which apply here
too), `p47r2-record.md`, and the independent review `verify/p47r2-review.md` (verdict: accept; nine
findings).

## Tasks

1. **Review finding 1 (MAJOR, pre-existing): the RunListBoxDialog stall on any other exposure.**
   RunListBoxDialog's busy loop at 1098:1BEE (PeekMessage + IsDialogMessage, no dispatch) receives
   another window's WM_PAINT forever when any other window is exposed while a list dialog is open; in
   civ64 this is a full hang, because host input is not admitted while an unranged PeekMessage keeps
   finding a message (FIDELITY F86). Example from the review: resizing the host window during play (the
   game screen follows the window, F110) while Find City or the Civilopedia is open: `expose`
   invalidates the map even where the dialog covers it.
   * Reproduce it headless first (a harness run that opens Find City or the Civilopedia and then changes
     the game-screen size, or exposes the map by another route the harness has), confirm the hang with
     the current build (step or virtual-time watchdog at 1098:1BEE), and in a Win32-headless test if the
     host path matters.
   * Find the cause in `w16` (which window gets the WM_PAINT, why the exposure reaches a covered window,
     what PeekMessage returns and in which order, F86's admission rule) and fix it in `platform/w16`
     with the core unchanged, by the rule closest to Windows 3.1's behaviour (evidence label "inference"
     for any claim about Windows 3.1; say what the original would plausibly have done with this loop).
     Candidate directions, not decisions: exposure limited to the visible region not covered by
     windows above; WM_PAINT retrieval order or the way an undispatched WM_PAINT is treated by
     PeekMessage; host input admission while the loop spins. Record the choice.
   * Test: the reproduction passes (the dialog still answers keys and closes), every base output
     unchanged except where explained; a test_user or test_queue unit vector for the mechanism.
2. **Review finding 2:** a direct test of rule 2 (REPAINT_FRAME): a `test_user` case, and in p4tests an
   assert that `p49-findcity-bar` ends at its virtual-time limit, not the step watchdog.
3. **Review finding 3:** settle what the `p49-pedia` "after hide/show" check proves: test it against the
   pre-fix behaviour (rule 1 disabled by a test-only switch, or a recorded reasoning); if it does not
   discriminate, reword it and rely on test_user case (3), or make it discriminate.
4. **Review findings 4, 5, 7, 8, 9:** correct `p47r2-record.md` (what rule 2 removes; "For the records":
   STATUS.md lines about the queued fix, FEATURES.md's Civilopedia row, `phase4-review-4.md` P47-N4 and
   "Related choice" status lines, the corrected F80 text: the client is invalidated too and WM_SIZE is
   sent; finding 7's consequence; finding 8's wording) and the `user_wnd.c` header comments; add the
   untested cases of finding 9 (nested descendants; destroy inside WM_NCPAINT) to test_user if cheap.
5. **Review finding 6:** harden `ext_g1.py`'s amendments: refuse `state` amendments; optionally store,
   per amended field, the hash with the named frame lines removed, so the script itself checks that only
   those lines changed.

## Files you own

`platform/w16/user_wnd.c`, `queue.c`, `queue.h`, `host_sync.c`, `user_dlg.c`, `user_listbox.c`,
`w16_int.h`, `tests/test_user.c`, `tests/test_queue.c`, `tests/win32/test_host_win32.c` (only if the host
path matters), `tests/harness/p4tests.py`, `ext_g1.py`, `ext-g1-amend.txt`, `ext_p0.py` (amendment use
only), `test.cmd` (only if a step must be added), `p47r2-record.md` (corrections) and your record
`claude/port/docs/p47b-record.md`. Not `present/`, `core/`, `rt/`, `gen/` outputs, or other documents:
list entries under "For the records" (DESIGN.md 5, FIDELITY.md F80/F86, STATUS.md, FEATURES.md,
`phase4-review-4.md`, `manual-checklist-ext.md`: a pending user check "resize the window while Find City
is open: no hang").

## Cycle and record

The eight-step cycle of `BRIEF-p47r2.md` after the last source change (logs `build/p47b-<n>-<step>.log`,
status `build/p47b-status.txt` ending `ALL_GREEN`). Record: the cause, the mechanism and why, files,
tests and counts, every changed base output with its reason, results, deviations, "For the records".

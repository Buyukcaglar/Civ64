# Record: base-track unit P47b (P47-R2 review fixes; the list-dialog stall on exposure)

Written 2026-10-15 by the P47b implementer of extension session E3, under `docs/verify/BRIEF-p47b.md`
(rules of `verify/BRIEF-p47r2.md`), after the independent review `verify/p47r2-review.md` (findings
1..9). Nothing here is an observation of the original game or of Windows 3.1: claims about Windows
3.1 are labelled **inference**, the port's rules are **choices**, and the test expectations are the
port's model (model, self-consistency). Cycle: the user's decision of 2026-10-15 about 14:09 UTC
(relayed by the orchestrator) makes the three-step cycle (Checked build, `test.cmd checked`, G-1)
the per-unit cycle; the observer-free (CheckedNoObs) and Release variants of this unit's changes
are deferred to the next phase gate's eight-step cycle.

## Result

Finding 1 (MAJOR) is fixed in `platform/w16` with the core unchanged: a loop that passes another
window's WM_PAINT on without dispatching it (RunListBoxDialog 1098:1BEE through IsDialogMessage)
no longer stalls. The WM_PAINT is still returned again and again, as in Windows 3.1, but each such
idle repeat now costs virtual time like an idle poll and takes host input, so the dialog still
answers keys and closes, and the window is painted once the game's main loop dispatches its
WM_PAINT. The headless reproduction (the host view grows while Find City is open) failed at the
step watchdog before and passes now (`p49-findcity-resize`). Findings 2, 3, 4, 5, 6, 7, 8 and 9
are addressed (below). Every base output is unchanged (no amendment); the only new outputs are
`p49-findcity-resize`'s. The three-step cycle's results are under "Cycle results".

## Finding 1: the cause

Reproduced headless first, with the build before this unit (`build/x64/Checked`, the D4b4 cycle's
build): run `p47b-repro-old` (script `build/p4/scripts/p47b-repro.script`: FINDCITY.SAV, Load a
Saved Game, Find City by Ctrl+F at 25 s, `at 26000 hostsize 1024x768` with `--game-screen view`,
an Enter character for the dialog at 28 s, limit 31 s, `--max-steps 150000000`) ends
`result WATCHDOG ... site 1098:1C05 steps 150000000 virtual_us 26000450`: the step watchdog inside
RunListBoxDialog's loop, the virtual clock standing at the moment of the screen change
(`screen 400 300 game screen follows the host (F110)` at 26000450 is the last event; the Enter at
28 s never came, the dialog never closed).

* **Which window gets the WM_PAINT, and why.** At the loop's next unranged PeekMessage after the
  view grew, `w16_screen_follow` (F110) let the top-level windows follow: the Status window
  (`WdwStatus`, 2030 in this run), whose bottom edge lay on the old screen's bottom edge, was moved
  down by MoveWindow(TRUE) (its position follows, F105's rule), which invalidates its whole client
  area (`invalidate_tree`) and exposes its old rectangle in the windows below (`expose`, which ignores
  occlusion: the map window is invalidated there too). The pre-order paint walk (topmost first,
  parent before children) finds the dialog and its list validated, then the Status window: its
  WM_PAINT is the one returned (diagnostic run below: 2,000 repeats, all hwnd 2030 at 1098:1BEE).
  Any window would do: the map window gets one from the same follow when its edge lay on the screen
  edge (a fitted layout), or from any hide, move or destroy elsewhere.
* **What PeekMessage returns, in which order.** Sent messages, the quit flag, posted messages,
  input, WM_PAINT, WM_TIMER (`queue.c` header). WM_PAINT is synthesized from the update regions at
  every call and stays retrievable until the window is validated (BeginPaint, ValidateRect,
  DispatchMessage's validation). RunListBoxDialog's loop (1098:1BEE, `core/seg020_1098_p1_r.c`
  396-423: PeekMessage(NULL, 0, 0, PM_REMOVE), IsDialogMessage(dialog), no TranslateMessage or
  DispatchMessage) passes the Status window's WM_PAINT to IsDialogMessage, which returns FALSE for
  another window's message; nothing validates the region, so the next call returns it again, for
  ever. WM_TIMER, behind WM_PAINT, never comes.
* **Why time stood still and input never came.** A TRUE PeekMessage charges nothing to the virtual
  clock (only a FALSE one charges W16_COST_PEEK_FALSE_US) and IsDialogMessage charges nothing, so
  the loop ran with the virtual clock frozen: the harness posts script input by virtual time, so the
  Enter never arrived and the step watchdog stopped the run. In civ64 the clock follows the host,
  but F86 admits host input into the emulated queue for an unranged PeekMessage only when it ends
  finding nothing, which never happens while the WM_PAINT is pending: no key or click entered, and
  the game hung (review finding 1, by code reading; the Win32-headless check below shows the host
  path).
* **What the original would plausibly have done (inference).** Under Windows 3.1 the same loop
  would have spun as well, with the WM_PAINT pending: Windows 3.1 also synthesizes WM_PAINT until
  the window is validated, and IsDialogMessage does not dispatch another window's message. But real
  time passed while it spun, and keyboard and mouse input, which the system queue collects from the
  hardware meanwhile and which GetMessage/PeekMessage return before WM_PAINT, still reached the
  dialog: the dialog stayed usable (busy-waiting), the covered window stayed unpainted, and the
  game's main loop painted it after the dialog closed. In Windows 3.1 the trigger is another
  program's window moved over and away from the game's, or the game's own window changes; civ64
  adds the host resize (F110).

## Finding 1: the rule chosen, and why

**Rule (choice; `queue.c` header "An undispatched WM_PAINT"):** a PeekMessage with PM_REMOVE that
returns the WM_PAINT of the window whose WM_PAINT the previous such retrieval returned, while no
update region has been validated or dropped since (`w16_wnd_validations`, a count in `user_wnd.c`
that grows in `upd_clear` (BeginPaint, ValidateRect(NULL), DispatchMessage's and UpdateWindow's
validation, a minimized window's dropped region), a partial ValidateRect, a freed window and a
window-manager reset), and while the virtual clock, read when the call starts (before its own host
synchronization), still shows the time at which that retrieval returned (nothing between the two
calls charged time or synchronized with the host: the caller only passed the message on), returns
it again (as Windows 3.1 does) but counts as an idle poll: it charges W16_COST_PEEK_FALSE_US and
is a wait point with the host input of a FALSE PeekMessage (`w16_host_sync(W16_SYNC_WAIT)`; for a
ranged PeekMessage holding WM_PAINT, WAIT without input, as its FALSE end), before the message is
written. Input taken there is returned by the next PeekMessage, ahead of the WM_PAINT (input
precedes WM_PAINT), so F86's principle (input arriving while the game waits goes to the game's
next call) is kept. PM_NOREMOVE retrievals neither count nor charge.

**Why the clock condition (found on the way; see "Deviations").** The first form of the rule had
no clock condition. A diagnostic build (temporary, removed: one line per idle repeat to a file
named by an environment variable) and a full `test.cmd checked` showed that 169 base-run processes
reached it: MenuZ's loop (PeekMessage at 1220:0ACE, statement 1220:0AC0) and the city screen's
PumpCityScreenMessage (1030:9AED, statement 1030:9B03) get another window's WM_PAINT (the Status
window's, 2030, in MenuZ's case) again and again without dispatching it, in many runs. They do not
hang, because they poll something else between (MenuZ's key pump, a ranged PeekMessage that
returns FALSE, charges 1 ms and takes host input at its start, F86), and the extra charge changed
their timing, frames and core state (gate3b's snapshot references, P4_SCENARIOS p4-arrival, ext_p0
V0 against G-1 failed). The run was stopped there; nothing was amended. With the clock condition
those loops are not idle by the rule and behave exactly as before; only a loop that does nothing
but pass the message on, which in the port never advances the clock and never takes host input,
is.

Why this one, against the brief's candidate directions:
* **Exposure limited to the visible region** (Windows 3.1 keeps update regions inside the visible
  region, inference): rejected as the fix. The windows the screen change moves or sizes need
  painting in any model (the Status window above is moved, not uncovered; a stretched map window
  gains area), so the loop would still get a WM_PAINT it does not dispatch, and the hang would stay;
  and `expose` runs at every hide, move and destroy of the game, so clipping would change the
  paints (WM_NCPAINT, WM_ERASEBKGND, WM_PAINT traffic and frames) of many base runs. Recorded as a
  standing choice in `user_wnd.c`'s header ("Exposure ignores occlusion").
* **WM_PAINT retrieval order, or not returning an undispatched WM_PAINT again** (skipping it until
  something else happens): further from Windows 3.1, whose loop gets the same WM_PAINT again, and it
  would need a rule for when the skipped WM_PAINT comes back.
* **Host input admission while the loop spins** (F86 only): would free civ64 but not the virtual
  clock, so the harness (and every virtual-time consumer) would still stand still in such a loop.
* **The chosen rule** keeps Windows 3.1's observable behaviour (the WM_PAINT stays pending and is
  returned again; input comes first; the window is painted when a loop dispatches it) and models the
  time that passes in the spin the way the port models every idle poll. It is the narrowest: it
  changes nothing unless the very same WM_PAINT is removed twice with no validation anywhere and no
  time charged in between, which a loop that dispatches its messages, or polls anything else,
  never does; in the port such a loop could only stall. Evidence that no base run reaches it: the
  second diagnostic run (below). It is portable C in `platform/w16` only; `core/`, `rt/`, `gen/`,
  `present/` are unchanged; no message is added to or removed from any window procedure (the
  retrieval returns what it returned before; only the clock and the host input differ, and only in
  that case). The F86 entry stays true for every other case: an unranged PeekMessage that finds a
  message takes no host input, unless it is this idle repeat.

## Findings 2..9

* **Finding 2 (rule 2 untested):** `test_user` `test_p47b` (2): a bordered child with a vertical
  bar in a popup above a lower top-level window, all painted; SetScrollRange(SB_VERT, 0, 0) hides
  the bar: the child gets one WM_NCPAINT, WM_SIZE and one WM_PAINT and its frame is the border only;
  neither the popup nor the lower window gets any message; SetScrollRange(0, 10) shows it again:
  the bar's arrows are drawn, the first WM_PAINT is the child's, and again nothing reaches the popup
  or the lower window. In `p4tests.py` `listbar`, `p49-findcity-bar` must stop at its virtual-time
  limit (`vt_limit`: `virtual_us` at least 31,000,000 and fewer than 900,000,000 steps), not at the
  step watchdog.
* **Finding 3 (the `p49-pedia` hide/show check):** tested against the pre-fix behaviour
  with the experiment build (rule 1, rule 2 and the P47b rule switched off;
  `build/p47b-exp-listbar.log`): `p49-pedia`'s check of the stable frame after dialog 130 opened fails (no border,
  as before P47-R2), but the two checks "after the topic, hidden and shown again" (border and
  horizontal bar) pass. They do not discriminate: RunPediaModalLoop (1068:278C) dispatches every
  message, so the dialog's WM_PAINT from the hide is served while the list is hidden, and the show
  at 1098:1C8F draws the list's frame with nothing painting over it afterwards (the review's
  reading confirmed). The check is kept as a guard and reworded ("guard: holds without rule 1
  too", with a comment in `t_listbar` and the docstring); the w16 hide/show sequence is tested by
  `test_user` `test_p47r2` (3), which fails with rule 1 off. RV4's "the hide/show repeats it" does
  not happen in the port: the records should say "verified after the hide/show", not that the fix
  was needed there. The same run's other results: `p49-findcity-bar` and `p49-findcity-resize`
  stop at the step watchdog at virtual_us 25,051,450 (with rule 2 off the bar's exposure stalls
  first; with P47b off nothing frees the loop), `p49-pedia-units` loses its border; 8 failures
  in all.
* **Findings 4, 5, 7, 8, 9 (records and comments):** `p47r2-record.md` corrected: what rule 2
  removes (the dialog's WM_NCPAINT and synchronous WM_ERASEBKGND with DefDlgProc's WM_CTLCOLOR, not
  its WM_PAINT; WM_NCPAINT, WM_ERASEBKGND and a pending WM_PAINT for every other top-level window
  meeting the list's rectangle), that the pre-fix many-cities case would have hung civ64 (F86), the
  inference wording of "Why this one" (the state is set at invalidation; the EndPaint rule is the
  port's own), the rule-2 heading ("repaints the window itself only"), the F80 text proposed under
  "For the records" (frame at once, client area and children invalidated, WM_SIZE; exposing nothing
  in the parent or below), the time of the `ext_p0.py` change (during step 2) and the files changed
  after the record by others, and an "Added 2026-10-15 by P47b" block with the missing entries
  (STATUS.md lines 236 and 650, FEATURES.md line 154, `phase4-review-4.md` NOTE P47-N4 and the
  "Related choice" status, F80's finding-7 consequence and finding-8 wording). `user_wnd.c`'s
  header: finding 7's consequence (a frame covered by a parent invalidation that meets only the
  child's frame stays covered until the child paints again; Windows 3.1 would repaint it,
  inference), finding 8's wording, the marking at any depth (also below a WS_CLIPCHILDREN child) and
  the zeroed PAINTSTRUCT of a window that its own WM_NCPAINT destroys; also "Exposure ignores
  occlusion" and a pointer from the WM_PAINT bullet and the SetScrollRange comment to the new rule.
  Finding 9's untested cases are now tested (`test_p47b` (3) and (4), below); its process details
  are corrected in `p47r2-record.md`; its note that D4b3 caused step 2's other failures was
  confirmed by the combined D4b3 cycle (ALL_GREEN, `build/d4b3-status.txt`).
* **Finding 6 (G-1 amendments):** `ext_g1.py` now refuses a `state` amendment (a core-state change
  is a stop-and-report condition) and requires every amendment to name the frames it alters
  (`only=938,985,...`) and the hash of the field without their lines (`rest=`, taken from the
  pre-change run `game/p47r2-old-menus`, which equals the baseline in all three fields): `check`
  verifies both the amended hash and that the field without the named lines still has the rest
  hash, so "only those frames changed" is machine-checked (frames: the `frame N` lines of run.log;
  events: the `stable K frame N` lines of events.log). New subcommand `ext_g1.py rest RUN-DIR
  FIELD only=...` computes a rest hash. `ext-g1-amend.txt` has the two P47-R2 lines in this form;
  `ext_p0.py` reads the five-element amendment tuple (amendment use only).

## Files changed

* `platform/w16/queue.c`: the undispatched-WM_PAINT rule (header rule; `g_paint_hwnd`,
  `g_paint_valid`, `g_paint_us`; the entry clock; the idle charge and wait in w16_PeekMessage's
  WM_PAINT branch; reset).
* `platform/w16/user_wnd.c`: `g_validations` and `w16_wnd_validations` (grows in `upd_clear`, a
  partial ValidateRect, `wnd_free`, `w16_user_reset`); header: "Exposure ignores occlusion", the
  WM_PAINT bullet's pointer to the new rule, "Frames painted over" (any depth, the zeroed
  PAINTSTRUCT, finding 7's consequence, finding 8's inference); the SetScrollRange comment's pointer.
* `platform/w16/w16_int.h`: `w16_wnd_validations` prototype. `platform/w16/queue.h`: the hooks'
  comment names the rule.
* `tests/test_queue.c`: `test_paint_again` (12 checks). `tests/test_user.c`: `test_p47b` (12
  checks) and the test procedure's `g_kill_on_ncpaint`. `tests/win32/test_host_win32.c`: the host
  path (2 checks).
* `tests/harness/p4tests.py`: `vt_limit`; `listbar`: `p49-findcity-bar` must stop at its
  virtual-time limit, new run `p49-findcity-resize`; the docstring; finding 3's rewording.
* `tests/harness/ext_g1.py`, `tests/harness/ext-g1-amend.txt`, `tests/harness/ext_p0.py`
  (amendment use only): finding 6.
* `docs/p47r2-record.md` (corrections) and this record.

Not changed: `host_sync.c`, `user_dlg.c`, `user_listbox.c`, `test.cmd`, `core/`, `rt/`, `gen/`,
`present/`, `tests/headless/`, every golden and expectation file.

## Tests and counts

* `test_queue` 129 checks (117 before): `test_paint_again`: the first retrieval free, the repeat
  charged 1 ms, every further one, PM_NOREMOVE never, input first, another window's WM_PAINT and
  the first one's after it free, a range holding WM_PAINT the same, and free again after a FALSE
  key-range PeekMessage or a poll cost between (MenuZ's case).
* `test_user` 343 checks (331 before): `test_p47b` (1) the mechanism with real windows (a "map"
  below a "dialog", the dialog-only loop, a key first, the MenuZ-like case free, dispatched then
  new again; 7 checks), (2) rule 2 (finding 2; 3 checks), (3) a bordered grandchild below a
  WS_CLIPCHILDREN child under a non-clipping parent (finding 9), (4) a window destroyed by its own
  WM_NCPAINT inside BeginPaint (finding 9).
* `test_host_win32` 262 checks (260 before): with host timing, a dialog-like window's WM_PAINT not
  dispatched, a host key pressed, the next unranged PeekMessage returns the WM_PAINT again (an
  idle poll that takes host input) and the one after it the key.
* `p4tests.py` `listbar`: `p49-findcity-bar` stops at its virtual-time limit (virtual_us
  31,000,450, 11,055,600 steps); `p49-findcity-resize` (FINDBAR.SAV, `--game-screen view`, Ctrl+F
  at 25 s, `hostsize 1024x768` at 26 s, an Enter character at 28 s, limit 31 s): ends at its
  virtual-time limit (virtual_us 31,000,750, 11,207,780 steps, site 1098:02DE, the main loop), the
  screen followed to 1024x768 at 26,000,450 while dialog 131 (opened at 25,051,450) was open, the
  dialog closed at 28,000,450 (three windows left), and the last frame is 1024x768 (the Status
  window and the map repainted after the close, viewed in the frame dumps of the development run).
* Discrimination (experiment build, temporary, rules 1 and 2 and the P47b rule switched off by a
  zero variable; restored, and the cycle's build replaces it): `test_user` 15 failures (the 8
  P47-R2 checks the review listed, `test_p47b` (1) 3, (2) 2, (3) 1, (4) 1), `test_queue` 4
  failures, `test_host_win32` 1 failure (the key never arrives, "call -1"); `listbar`: see
  finding 3.

## Changed base outputs

None. Every recorded expectation (G-1's 77 runs with the existing P47-R2 amendment, gate3b's
snapshot references, the scenarios, ext_p0, ext_frames, ext_timeline, ext_continue, ext_adapt,
ext_mirror, ext_zoom) matches. New outputs only: `game/p49-findcity-resize` and
`build/frames/p49-findcity-resize` (not in the G-1 baseline). The development runs
`p47b-repro-old` and `p47b-repro-new` under `build/harness/game` are diagnostics, not base outputs.

## Cycle results

The three-step cycle ran on the final sources, after the diagnostic and experiment code had been
removed. It was one sequential script that stops at the first failure. Status:
`build/p47b-status.txt`, ending `ALL_GREEN` (2026-10-15 16:35:06 UTC).

| Step | Command | Exit | Time (UTC) | Last line of the log |
|---|---|---|---|---|
| 1 | `build.cmd checked` | 0 | 15:52:53..15:56:58 (245 s) | `BUILD_OK variant=Checked` (`build/p47b-1-build-checked.log`) |
| 2 | `test.cmd checked` | 0 | 15:56:58..16:35:06 (2287 s) | `TESTS_OK variant=Checked` (`build/p47b-2-test-checked.log`) |
| 3 | `C:/Python314/python -B tests/harness/ext_g1.py check` | 0 | 16:35:06 | `EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)` (`build/p47b-3-g1-checked.log`) |

Step 2's log shows the following results:
* the unit tests: `test_queue` 129, `test_user` 343 and `test_host_win32` 262 checks, 0 failures;
* the suite markers: `REGISTRY_OK`, `NODOS_OK`, `GATE3B_OK`, `UNINIT_OK`, `P4_SCENARIOS_OK`,
  `P4_TESTS_OK`, `P0_OK checks 279`, `EXT_FRAMES_OK`, `EXT_TIMELINE_OK`, `EXT_CONTINUE_OK`,
  `EXT_ADAPT_OK checks 20`, `MIRROR_OK runs 29`, `ZOOM_OK combinations 32 runs 64 samples 388` and
  `TRACE_OK`;
* the documentation checks: `OBS_TABLES_OK probes 203 sites 98`,
  `OBS_LINT_OK files 79 probes 203 callsites 98` and `pdos_scene_check` with 1075 checks and 0
  failed;
* no `FAIL` line.

G-1's single amendment is the existing P47-R2 one, now in the hardened form. Its rest hashes
were checked.

The cycle did not cover the observer-free (CheckedNoObs) and Release variants. The user's decision
of 2026-10-15 defers them to the next phase gate's eight-step cycle.

## Deviations

* **The first form of the rule changed base outputs** (no clock condition; see "Why the clock
  condition"): found by the diagnostic full run before any cycle, stopped, nothing amended; the
  rule was narrowed so that no base output changes.
* **Temporary diagnostic and experiment code** (an environment-variable trace in `queue.c`; zero
  switches for rules 1, 2 and P47b) was built for evidence only and removed before the cycle; the
  cycle's build replaces those binaries. Development logs: `build/p47b-dev-*.log`,
  `build/p47b-exp-*.log`, `build/p47b-diag-*.txt`.
* **Cycle:** the three-step cycle only, by the user's decision of 2026-10-15 about 14:09 UTC; the
  observer-free (CheckedNoObs) and Release variants of this unit's changes are deferred to the next
  phase gate's eight-step cycle (`queue.c` and `user_wnd.c` are portable C without conditionals,
  the same code in every variant, but that is not a run).
* An interim handback was sent before the cycle (the run was asked to hand back); the orchestrator
  asked to continue, and this record is the final state.
* No agent check with a visible civ64 window (not required); the host path is covered by
  `test_host_win32` only.

## For the records

Entries for the owners of the documents (this unit edits none of them):

* **FIDELITY.md F80**: replace the "**Open (pre-existing, review finding 1, MAJOR; queued as
  base-track unit P47b ...; not fixed)**" sentence by: "**Fixed (P47b, 2026-10-15;
  `p47b-record.md`):** a loop that passes another window's WM_PAINT on without dispatching it
  (RunListBoxDialog 1098:1BEE) still gets it again and again, as in Windows 3.1, but a PeekMessage
  that returns the same WM_PAINT again with no update region validated and no time charged since
  is an idle poll (1 ms, a wait that takes host input; `queue.c` "An undispatched WM_PAINT";
  **choice**); the dialog answers keys and closes, and the window is painted after it closes.
  **Inferred:** Windows 3.1 spins there too while real time passes, and input, retrieved before
  WM_PAINT, still reaches the dialog. Exposure still ignores occlusion (**choice**, `user_wnd.c`
  header): clipping would not remove the hang and would change many base runs' paints."
* **FIDELITY.md F86**: add: "Exception (P47b): an unranged PeekMessage that returns an idle repeat
  of the same undispatched WM_PAINT (no validation, no time charged since the previous retrieval)
  takes host input as a FALSE one does at its end; input taken there is returned by the next call.
  MenuZ's loop is not affected (its key pump charges time between)."
* **FIDELITY.md F110**: the hazard of a host resize while a dialog loop that does not dispatch is
  open is closed by P47b (the windows that follow are painted after the dialog closes).
* **DESIGN.md 5** ("Message queue" and invalidation): the undispatched-WM_PAINT rule (its
  conditions, the cost, the wait with host input; `w16_wnd_validations`), the standing choice that
  exposure ignores occlusion, the frame mark reaching descendants at any depth, finding 7's
  consequence.
* **STATUS.md**: P47b done (three-step cycle `build/p47b-status.txt`; CheckedNoObs and Release at
  the next phase gate); finding 1 of the P47-R2 review closed; base outputs unchanged; G-1
  amendments hardened (`ext_g1.py`: `only=`/`rest=`, no state amendments); the user's check
  pending.
* **FEATURES.md**: no hash changes.
* **verify/phase4-review-4.md**: Find City's and the Civilopedia's "Effects on the game" bullets: a
  host resize (or any other window's exposure) while the list dialog is open no longer hangs the
  game (P47b); NOTE P47-N4 and the "Related choice" status lines as listed in `p47r2-record.md`'s
  "Added 2026-10-15 by P47b" block.
* **manual-checklist-ext.md**: a new pending user check: in civ64 during play, open Find City (and
  the Civilopedia's list), resize the civ64 window: no hang; the arrow keys, Enter and Escape still
  work and the dialog closes; the windows the resize moved or enlarged are painted after it closes.

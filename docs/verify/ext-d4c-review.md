# D4c review: area C filter, adapter table, DOS mouse conversion, pending translations (independent, read-only)

Reviewer: independent adversarial read-only review (2026-10-15, extension session E3) of units D4c1 and
D4c2: `present/dos/pdos_adapt.c/.h`, `pdos_adapt_tab.c`, `pdos_mouse.c/.h`, `pdos_pend.c/.h`, the D4c changes
in `present/input.c/.h`, `pdos_seq.c`, `pdos_common.h`, `pdos_assets.c`, `gen/dos/adapters.py`,
`gen/dos/registry.py`, the tests `tests/test_input.c`, `test_pdos_adapt.c`, `test_pdos_mouse.c`,
`test_pdos_pend.c`, `tests/headless/ext_adapt.py`, the D4c2 parts of `ext_timeline.py` and `harness.c`,
against `docs/verify/BRIEF-d4.md` (D4c, "D4b3 restart and D4c split", Rules), `docs/ext-D4c1-record.md`,
`docs/ext-D4c2-record.md`, `docs/ext-D4-acceptance.md`, DESIGN 12.5/12.8, draft C (C.11..C.14, C.20) and
DOS-PROFILE.md 1.7.2 (through `gen/dos/adapters.py`, see "Not reviewed"). Supporting reads only:
`present/arrive.c` (modifier hold, mouse latches, focus/capture loss), `platform/w16/host_sync.c`
(`post_event`, `key_lparam`, `take_input` order), the DOS listings (root.lst, ovl02.lst, ovl07.lst) and the
core's MenuZ (`seg069_1220_p1.c`/`_p2.c`) and title (`seg061_11E0.c`) exports under `claude/`.

Nothing was built, compiled or executed (the D4c2 agent was running the gate's cycle). The only
execution was `C:/Python314/python -B` byte counting for line endings. At the time of review
`docs/ext-D4c2-record.md` (RESULT/TESTS/RESULTS placeholders) and `docs/ext-D4-acceptance.md`
(VERDICT/CYCLE/FOR_RECORDS placeholders) were still in progress; the build logs present were
`build/d4c1-2-test-checked.log` (TESTS_OK), `build/d4c2-2-test-checked.log` (TESTS_OK, Checked),
`build/d4c2-3-g1-checked.log` (EXT_G1_OK runs 77) and `build/d4c2-4-build-noobs.log`, which at that time
held only "'vswhere.exe' is not recognized" (the NoObs step looked unfinished or failed to start; not
judged here).

## Verdict

**Accept with fixes.** No BLOCKER. One MAJOR: a cancelled intro-shortcut translation leaves the DOS view
in the title HOLD state with no box while the core waits at its title (R1). The rest are MINOR: auto-repeat
breaks the "no wrap" decision and T4 stepping (R2), Shift+N is not the shortcut (R3), the MZ_SEL predicate
can hold on a stale selection (R4), capture loss during a box drag chooses a row (R5), a held OWN key's
passed repeats race the queued translation (R6), the D4c1 record overstates three behaviours (R7), and
the tests miss the selection-dependent and failure paths (R8). P0, the include rule, the DOS listing
citations, the mouse arithmetic and the pending queue's limits are correct.

## Findings

### R1 (MAJOR) A cancelled intro shortcut leaves the title in HOLD: no box, mouse consumed, keys blind

Where: `present/dos/pdos_seq.c:545-553` (`title_check`: a preselect sets `PDOS_TB_HOLD`), `:595-604`
(`title_again`: the only exit from HOLD, and only with `g_core.title_choice >= 0`);
`present/dos/pdos_adapt.c:689-690, 730, 755` (every key press, character and button press calls
`cancel_pending` before deciding); `present/dos/pdos_pend.c:221-233` (cancel), `:258-260` (timeout);
`present/dos/pdos_adapt_tab.c:52-60` (I-intro/shortcut/core-intro: OWN now, then letter+Return at
MZ_READY), `:66-70` (core-wait: letter+Return at MZ_READY), `:195-200` (I-title/hold-key passes keys,
hold-press consumes presses).

Evidence: the port mirrors R:01A8:04BB ("DGROUP:6B32 != -1, no box") by entering HOLD at the hand-over
whenever `pdos_intro_preselect >= 0`. In DOS the preselected item is then taken at once; in the port the
item is chosen only if the pending translation completes. The translation is cancelled by any later user
action on any frame (C.13.4), by the 10 s limit (P22) or by a lost state. Nothing tells the sequencer: HOLD
stays until the core makes a choice and opens dialog 139 again (`title_again` from `on_exit` of
`DialogOpen`, `pdos_seq.c:738-747`).

Failure scenario: DOS profile visible, the user presses N during the pan while the core is still in its
intro (row I-intro/shortcut/core-intro: N passes as the intro skip, letter+Return queued). Impatient, the
user presses Return (or N again, or clicks) before the core's title MenuZ polls its keys. The press
cancels the queue (`cancel_pending`), is decided in LATE (I-intro/key/core-intro passes it as another skip,
or I-intro/key/core-title consumes it), and the core's MenuZ flushes its input at entry
(FlushInputEvents). The DOS timeline reaches its hand-over, `title_check` sees the preselect and sets HOLD.
The core now waits at its title with selection 0 and no choice; the DOS view shows the logo on black with
no box indefinitely; presses are consumed (hold-press) and keys pass blind (hold-key): Up/Down move an
invisible selection and Return chooses it. The same follows if the core needs more than 10 s to reach its
title MenuZ after the skip (timeout), or for the core-wait row. The user sees an apparently hung title.
No unit, sequencer or ext_adapt case covers a cancelled shortcut translation.

Suggested fix: when a translation started by an I-intro shortcut row (or the T4 return-space rows) is
cancelled for any reason, and the title is in HOLD with no choice, show the box (`tb_show(tb_row(),
PDOS_TB_SHOWN, ...)`) through a sequencer hook called from `pdos_pend_cancel` (or have HOLD fall back to
SHOWN when the core's title MenuZ is ready and no translation is pending). Alternatively consume
non-cancelling input after a shortcut as DOS's box flush does (R:1D05:003E) and record it as a deviation;
the timeout still needs the fallback. Add a unit test (shortcut, then a key before MZ_READY: the scene
becomes BOX once the core is ready) and an ext_adapt/7.8 case.

### R2 (MINOR) Auto-repeat defeats "no wrap" in READY and stops T4 stepping after one row

Where: `present/dos/pdos_adapt.c:682-687` (a repeat takes the press's decision: FD_PASS repeats pass,
anything else is consumed, no view action); `pdos_adapt_tab.c:118-121` (I-title/edge only on the press),
`:122-126` (up-down/core-title PASS), `:127-130` (up-down/t4 CONSUME + PDOS_AV_STEP).

Evidence: the DOS box stops at its edges (R:1D05:020B..0214, 0368..0374); the core's MenuZ wraps
(MenuZSubclassWndProc, 1220:149D). The edge row is matched only for the first press; every repeat of a
passed Up/Down is passed unchanged. In T4 the press is consumed with a view STEP, and its repeats are
consumed with no view action, whereas DOS's typematic repeats each move the bar.

Failure scenario: core ready, the bar on row 3, the user holds Down: the first press moves to 4 (the last
row), the repeats reach MenuZ, which wraps to row 0 and keeps cycling; the DOS box follows the core's
selection (title_follow) and visibly wraps. The record's deviation 2 ("no wrap") and the pending user check
"Up and Down ... stop at the first and last row (no wrap)" (`docs/ext-D4c1-record.md:355-356`) fail as soon
as the key is held. In T4, holding Down moves one row only.

Suggested fix: re-decide Up/Down repeats on frame 1 in the BOX scene against the edge (consume at the
edge) without `cancel_pending` or `g_actions++`, and apply the view STEP for T4 repeats. Add a test with a
held Down at the last row and in T4.

### R3 (MINOR) Shift+N (an upper-case N) is not the shortcut

Where: `present/arrive.c:187-191, 196-203, 288` (K3: a held Shift is delivered before the next key);
`pdos_adapt.c:676-705` (the Shift press is decided on its own); `pdos_adapt_tab.c:71-76` (a lone Ctrl or
Shift is a skip key); `pdos_adapt.c:101-104` (PAN requires `in->nkeys == 0`).

Evidence: O2:09F1..0A4C accepts 'N' and 'n' (and L, E, C) as title items; Shift itself is never a BIOS key
in DOS. In the port the Shift press arrives first, is decided as I-intro/key/core-intro (PASS + view KEY),
which ends the DOS pan; the N that follows is decided in LATE, not PAN, so no shortcut.

Failure scenario: the user types a capital N (Shift+N) during the pan: both intros end and the title box
appears instead of the New Game preselection. The record's "(O2:09F1..0A4C, either case)"
(`docs/ext-D4c1-record.md:71`, and the row text at `pdos_adapt_tab.c:54`) holds only with Caps Lock.

Suggested fix: in PAN, defer the decision of a bare Shift press until the next key or its release (a
Shift followed by a shortcut letter becomes part of the shortcut; a lone Shift released is the K3 skip),
or record the deviation and correct "either case".

### R4 (MINOR) The MZ_SEL predicate can hold on a stale selection

Where: `present/dos/pdos_pend.c:80-81` (MZ_SEL: `mz_active && mz_ready && mz_sel >= 0 && mz_sel == arg`);
`pdos_seq.c:723-729` (`mz_ready`/`mz_sel` set at each IsKeyPending entry, ra 1220:0AA5), `:681-683,
750-752` (cleared only when MenuZ exits); `pdos_adapt_tab.c:35-38, 43-44` (q_click_sel_return: click,
then Return once the selection is k).

Evidence: the second step exists because a click is a mouse message that the key poll's ranged peek lets a
later Return overtake (C.12.5, the comment at `pdos_adapt_tab.c:35-36`). The predicate does not require a
poll after the click was posted: `mz_ready` is never cleared between polls, and when the core's selection
is already k (the user clicks the highlighted row, the most common click) it holds at the first sync after
the click.

Failure scenario: core ready, selection 1 (Load a Game), the user clicks row 1. The click is produced at
this sync; at the next input-taking sync MZ_SEL already holds and Return is produced. If that sync falls
inside MenuZ's key-range peek before the mouse messages are dispatched, Return chooses item 1 first; the
LBUTTONDOWN/LBUTTONUP stay queued and are dispatched to whatever the core shows next (the Load dialog is
then hit at the menu row's point). The outcome depends on where the next sync falls (not executed).

Suggested fix: make MZ_SEL require a key poll after the click step's release (a poll counter in
`PdosCore` incremented at SR_MZ_READY and captured by `pdos_pend` when the step is armed), or release
Return only when the poll that read `mz_sel == k` follows the click's retrieval. Add a test with
row == selection.

### R5 (MINOR) Capture loss during a box drag chooses the row under the last point

Where: `present/arrive.c:307-338, 360-364` (`pi_arrive_capture_lost` releases held buttons at the latched
press's last point and frame); `pdos_adapt.c:803-818` (an FD_DRAG release on frame 1 in a row decides
LREL_ROW); `pdos_adapt_tab.c:170-185` (release rows choose k).

Evidence: a capture loss (Alt+Tab, Ctrl+Esc, a system dialog) is not a user release. The synthetic
LBUTTONUP carries the drag's last frame-1 point, so the DOS rule "the release in an enabled row k: k is
chosen" (R:1D05:01CD..01D9) fires.

Failure scenario: the user presses in the box, drags over row 2 (Earth), then Alt+Tabs away: on capture
loss the game chooses Play on EARTH.

Suggested fix: mark releases produced by `release_buttons` (a HostEvent flag or a separate entry point)
and decide an FD_DRAG release from capture loss as LREL_OUT; or record the behaviour as a deviation (it
matches what a Windows drag release would do, but the DOS box has no such case).

### R6 (MINOR) A held OWN key's passed repeats race the queued translation

Where: `pdos_adapt.c:642-644` (an OWN step makes the press FD_PASS), `:682-686` (FD_PASS repeats pass
without `cancel_pending`); `pdos_adapt_tab.c:137-142` (I-title/return-space/core-intro: Return itself now,
letter+Return at MZ_READY); `platform/w16/host_sync.c:142, 179, 186` (`g_down` per vk, bit 30 from it);
`take_input` filters each event before the one `present_input_release` per sync.

Evidence: repeats are not user actions (C.13.4), so they neither cancel nor wait. In the sync in which the
core's title MenuZ first becomes ready, a passed repeat of the held Return is posted before the queued
letter+Return. MenuZSubclassWndProc chooses on WM_CHAR 0Dh (1220:13AA..14D4) with the selection it has.
Separately, the produced Return press is posted while `g_down[0x0D]` is still set by the user's held
Return (bit 30 set: it looks like a repeat), the produced release clears `g_down`, and later passed repeats
of the still-held key are posted as fresh presses (bit 30 clear), followed by a second KEYUP.

Failure scenario: T4, the box bar on row 1 (Load), the user presses and holds Return past the typematic
delay while the core finishes its intro: a repeat reaches the ready MenuZ first and chooses the core's
selection 0 (Start a New Game) instead of Load; the queued L and Return then go to the next screen. (By
static reading of the dispatch order; not executed.)

Suggested fix: while a translation is pending, consume repeats of a key whose press was an OWN step
(DOS's box flush, R:1D05:003E, discards them too), and do not release a produced press of a vk the user
still holds as passed (wait as for no room, or produce the user's KEYUP first). Add a unit test for both.

### R7 (MINOR, record) The D4c1 record overstates three behaviours

Where: `docs/ext-D4c1-record.md:68-69`, `:71`, `:73` and `:252-253`, `:355-356`.

Evidence: (a) "A release with nothing to follow on frame 1 ... is consumed with PDOS_DIAG_PAIR" holds for
buttons only (`pdos_adapt.c:782-786`); an unseen key release passes unchanged (`pdos_adapt.c:714-716`,
"a release with its press passed (or unseen)"). (b) "either case" for N, L, E, C: see R3. (c) "no wrap"
and the user check "stop at the first and last row": see R2.

Suggested fix: correct the text (key releases pass, button releases are consumed), and qualify or fix (b)
and (c).

### R8 (MINOR, tests) The selection-dependent and failure paths are not discriminated

Where: `tests/test_input.c:622-629` (`a_menu`: selection always 0), `:681-703` (items S, L, E, C,
distinct letters); `tests/test_pdos_adapt.c:54, 74` (real sequencer, distinct letters);
`tests/test_pdos_mouse.c:243-265` (class-C overlapping sibling fixture); `tests/test_pdos_pend.c`;
`tests/headless/ext_adapt.py` (D_CASES).

Evidence and gaps:
* `item_letter`'s search from selection + 1 with wrap (core 1220:13F6..145D) is never exercised with two
  items sharing a letter or a non-zero selection, so a search from 0 or without wrap would pass every
  vector. The real title has S/L/E/C/V/Q, so a regression would only show with a future menu; add one
  vector with a duplicate letter and selection != 0.
* `pdos_mouse_point`: no vector for the class-X fallback or for subtraction at an ancestor level
  (`above()`, `pdos_mouse.c:190-217`, walks up to the desktop; only a sibling at the control's own level is
  tested).
* The I-title/release/core-intro row (three steps, MOVIE then CLICK then RETURN) is never run against the
  real core sequence; HOLD cancellation (R1), held-key repeats at the edge and in T4 (R2), Shift+N (R3),
  row == selection (R4), capture loss in a drag (R5) and held OWN repeats (R6) have no case.
* `test_pdos_pend.c`'s timeout case checks the queue and the diagnostic, not the DOS view afterwards.
* ext_adapt's Windows form of each pair is built from the DOS run's own `adapt.log` sync numbers and the
  observed core click, so a wrong translation that the core still accepts is partly self-confirming. The
  cases compare against the independent Windows run's core state, which mitigates this.

## Observations (no severity)

* `run_steps` (`pdos_adapt.c:503, 513`) silently clamps a row's steps to 6 and acts to 4. `adapters.py`
  rejects such rows at generation time, so this is unreachable with the current table.
* A first step that resolves to more than 8 events is reported as `PDOS_DIAG_ADAPT`, not
  `PDOS_DIAG_PEND`, because `pdos_adapt_resolve` is called with max 8 (`pdos_adapt.c:524-527`). No row can
  produce that today (the most is a click: move, press, release).
* In T4 the box's own view row moves are dropped when the core becomes ready (the box then follows the
  core's selection, D4b2b2's design): T4 Up/Down/hotkeys change nothing in the core. This matches the
  recorded design; noted because a user can see the bar jump back.
* In READY a drag's highlight does not follow the pointer (PDOS_AV_HIGHLIGHT applies only while the core
  is before its title loop), while DOS moves the bar under the pointer and removes it outside rows
  (R:1D05:016A..01B7).
* A passed frame-1 click (I-intro/click rows) whose release arrives on frame 0 is released at its own
  press point (`pdos_adapt.c:791-801`); consistent with C.12.2.
* `above()` subtracts higher siblings at each level but not the control's own children; harmless for the
  current item controls, which have none.
* C.14.2's text says class P is the same as W "to 6553"; with the code's arithmetic P is exact only to
  3276. No current input reaches either bound.
* `pdos_seq_reset` resets the filter and the queue while a MAP key (Space as Return) may be held; its
  release then passes as Space. Reachable only through a reset with a key held.

## Confirmed correct

* **P0.** `present/input.c` routes notes and filters through `pdos_adapt_note`/`pdos_adapt_filter`, the
  pending release through `pdos_pend_release` once per input-taking sync, and the ring through
  `pmap_filter_ring`; the compile checks hold (`PDOS_PEND_EVENTS <= PI_MAX_OUT`, + 2, frame enumerations
  equal). Produced input is only the documented translations, the user's own events and D4b4's synthetic
  Escape (vk 1Bh once per Birth, DOS-visible only, `pdos_pend.c:302` with `out + n`, `max - n`, held
  without room for 2). Released pending events are not noted, so they cannot cancel themselves.
* **Pairing.** One decision per press; repeats, moves and releases follow it on any frame; a second press
  of a held consumed/pairs/drag button is dropped; FD_MAP releases produce the Return release; the frame-1
  point of a passed press is replayed for its release.
* **Pending queue.** 8 events per step, 6 steps, `fresh` (nothing at the start sync), order lost ->
  timeout -> holds -> resolve, resolve -1 cancels, more than 8 cancels (overflow), no room waits with
  nothing partial; start refusals for steps/acts/pred/act; the lost rules (MZ_READY title outside
  BOOT/INTRO/TITLE, MZ_SEL when MenuZ is inactive) match C.13.
* **Rows.** All 36 rows, their scene/core/action bits, decisions and the 8 sequences match the brief's
  table and the cited listing ranges: O2:04C1, 082A, 09D7..0A35, 0AF6..0B19, 0B8B (ovl02.lst);
  R:1D05:0031..0410 including 003E, 016A..01D9, 01E8..0214, 0238, 0368..0383, 03B8..0401 (root.lst);
  R:01A8:0481..051F including 0494, 04B8, 04BB, 0807; O7:1904..192F (ovl07.lst); MenuZ 1220:0AA0..0B47,
  13AA..14D4; title 11E0:0109..021F, 0715..0909.
* **Core reads.** `def_menu` reads 12D8:44FE (count), 12B0:009C (selection), 12D8:24DA (disabled bits),
  1420:B3E8 (item windows) with `w16q_rd16`; `item_letter` reproduces the core's letter search (from
  selection + 1, wrapping, letters only, disabled items skipped, fewer than 16 items).
* **Mouse.** `pdos_mouse_ceil16` ((8L+4)/5), `scale` (L*160/100), `back_p`/`back_w`, `centre`, `in` and
  `sub` (static 256-entry scratch, capacity checked) cannot overflow for 16-bit inputs; classes C, X, P,
  W, S follow C.14.2; the class-C deviation 7 (the point delivered to the control itself, overlapping
  siblings subtracted) is implemented and covered by the w16 fixture.
* **Hygiene.** The include rule holds (`gen/dos/registry.py` OBSERVER_FILES lists `pdos_adapt.c` and
  `pdos_mouse.c`); diagnostic names (29) match the enumeration (29); no file kept CRLF has mixed line
  endings; `pdos_adapt_tab.c`, `pdos_mouse.c/.h` are LF throughout; NULL hooks are tolerated
  (`g_pend.start == NULL`, `g_layer == NULL`); `adapters.py` reports ADAPT_OK rows 36 steps 12.

## Not reviewed

* The rest of `tests/headless/harness.c` and of `ext_timeline.py` beyond the D4c2 hostkey/adapt parts;
  `obs_lint` as a whole.
* `pdos_menubox_*` internals (`pdos_menubox_row`, `pdos_menubox_hotkey`) beyond their use by the filter.
* `present/arrive.c` beyond the modifier hold, the mouse latches and focus/capture loss.
* The rendered DOS-PROFILE.md 1.7.2 text itself (relied on `adapters.py`'s ADAPT_OK and its generator).
* The Win32 civ64 defaults outside `present/input.c`.
* D4c2's final results: its record and the acceptance file still held placeholders, and the NoObs build
  log showed only the vswhere error at the time of review.
* No execution of any build, test, harness, DOS program or the original; all scenarios above are from
  static reading and are marked where the outcome depends on run-time ordering.

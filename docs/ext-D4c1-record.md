# Extension phase D4, unit D4c1 (the DOS filter stage, adapters, mouse conversion) - record

Unit D4c1 of the "civ64" extension replaces D3's stub adapter and note with area C's filter stage for the
DOS profile: the pairing rule, the DOS-form key classes, the adapter table version 2 (rows I-intro,
I-title, I-birth and I-none), the decisions' events, the view actions, the step resolution for I4, and the
I5 mouse conversion with its proofs as unit vectors.

Brief: [verify/BRIEF-d4.md](verify/BRIEF-d4.md), "D4c1". Governing prompts: x64-port-scaling-dos-prompt.md and
x64-port-prompt.md 5.6 I1..I8 and 7.8. Design: [verify/ext-d1-draft-C.md](verify/ext-d1-draft-C.md)
C.12.1..C.12.6, C.12.9, C.14, C.15.2. Preceding units: [ext-D4b2b2-record.md](ext-D4b2b2-record.md)
(Deviation 2: "D4c decides the translation"), [ext-D4b4-record.md](ext-D4b4-record.md) ("Notes for D4c2").
Session E3, 2026-10-15.

Labels:

* **compiled**: the three language checks and `/W4 /WX`.
* **headless**: unit tests and harness runs.
* **DOS listing**: facts read from `build/dos/disasm/` with their DOS addresses (R:, O2:, O7:).
* **core listing**: facts read from the translated core (`claude/port/core`, read-only) with their
  segmented addresses.

Scope:

* No DOS program was executed. Nothing was written to `C:\Projects\Civ1RE\dos`, `build/dosdata` or
  `C:\Projects\Civ1RE\original`. No UI was shown. No DOS byte is in the repository or a binary (NODOS_OK).
  No git command that writes was run. Asan was not built or run.
* Not edited: `core/`, `rt/`, `platform/w16/*`, the generated tables other than DOS-PROFILE.md 1.7.2,
  `tests/test_user.c`, `tests/test_queue.c`, `p4tests.py`, `ext_g1.py`/`ext-g1-*.txt` and every document
  other than this record and DOS-PROFILE.md's generated section 1.7.2 (the rest is under "For the
  records").
* Worked in a stage (`build/d4c1-stage`, the orchestrator's staging protocol) until the build slot.

## Status

DONE. With the DOS profile visible, the player's own input on the DOS screens (the N canvas) is now
decided by area C's filter stage: in the DOS intro a key or a click ends the DOS intro (the click at the
movie window, Windows-only P25) and passes to the core while it is still in its intro, and is consumed once
the core waits at its title (I6); the DOS title box takes DOS keys (Up/Down without wrap, hotkeys that select
only, Return, Space as Return; Escape, Alt keys, the right button consumed); in DOS Birth keys and clicks
are the core's skip and a DOS key; in N scenes without a row keys pass and presses are consumed. The
translations that need a queued step (the intro shortcut before the core's title is ready, the T4 Return
and Space, every click on a box row) are consumed whole until D4c2 registers its queue (Deviation 4).

The three-step cycle is ALL_GREEN (`build/d4c1-status.txt`, 2026-10-15 17:29:49 UTC): build.cmd checked
(234 s), test.cmd checked (2,483 s, TESTS_OK), ext_g1.py check (EXT_G1_OK runs 77, amended 1). CheckedNoObs
and Release run at the D4 phase gate (the user's cycle rule of 14:09 UTC); the new tests also passed a
private CheckedNoObs build before the slot (test_input 203, test_pdos_adapt 48, test_pdos_mouse 20,
test_pdos_seq, test_present). No existing harness expectation changed: P0_OK 279, EXT_FRAMES_OK,
EXT_TIMELINE_OK, EXT_CONTINUE_OK, EXT_ADAPT_OK 20, MIRROR_OK 29, ZOOM_OK 32, EXT_G1_OK 77.

## What was built

### The filter stage (`present/dos/pdos_adapt.h/.c`, area C)

`pdos_adapt_filter(ev, out, max)` takes frames 1 (the N canvas) and 2 (the A canvas) and the later parts
the note routes to it; `pdos_adapt_note(ev)` takes frames 0, 3 and 4. They are `present/input.c`'s
`PiDispatch` defaults now (D3's `stub_note`/`stub_adapt` are gone); the default pending release stays D4b4's
`pdos_seq_autocontinue_release`. Every returned event is a Windows-form event (frame 0).

* **The pairing rule (C.12.2).** Two tables, `g_key[256]` and `g_btn[2]`, hold each held key's and button's
  decision: pass, consume, 1:1 (with the produced key), pairs, drag, or "elsewhere" (a press decided on
  frame 0, 3 or 4, with its last point). A user action (a key press that is not a repeat, a character, a
  button press) is decided once; its repeats, moves and release follow that decision whatever frame they
  arrive with. A release of a passed press goes where the press went; of a 1:1 press, the produced key's
  release; of a consumed, pairs or drag press, nothing (the drag's release decides through the table).
  The note returns 1 for a later part of an action decided here other than "pass", so area A routes it
  here (C-11); it cancels the pending translation (C.13.4) on a key press, a character or a button press of
  frames 0, 3 and 4, never on a repeat, a move or a release. A release with nothing to follow on frame 1
  (or a ring press, which has no point) is consumed with `PDOS_DIAG_PAIR` (C.12.2's defensive rule).
* **The DOS-form action (C.12.3, C.12.5).** A key press has the bits of every class it satisfies: any key;
  N, L, E, C (O2:09F1..0A4C, either case) as a shortcut with its title item 0..3; Escape, Return, Space;
  Alt held (posted elsewhere or here) makes every other key an Alt key (R:1D05:03E3); in the title box Up
  and Down with a row to move to, else the edge (R:1D05:0368..0374, 020B..0214, no wrap), and a character
  the box's hotkey search finds (`pdos_menubox_hotkey`, R:1D05:03FD..03E0). Characters without a key
  press, left and right presses and the drag's release in an enabled row or elsewhere are their own bits.
* **The scene at the sync (C.12.1).** The default scene hook runs `pdos_seq_advance(w16q_now_us())` first,
  then reads the DOS view: the intro's pan with no DOS key pending (pc START, O2:04C1, O2:082A), its later
  phases, its dissolve (O2:0B90); the title box shown, chosen or held (no box after a shortcut); the Birth
  view with the core in its Birth; else none. The core's state is its intro, its title MenuZ ready (active,
  ready at IsKeyPending ra 1220:0AA5, kind title, a readable selection), or waiting.
* **Decisions and events.** Pass returns the event (a frame-1 press only with class X: a move and the
  press at the movie window's point, the release there later); consume returns nothing; 1:1 is Space into
  Return (press now, release at Space's release); steps are instantiated from the row's templates with the
  action's item k; the first step, when it waits for nothing, is resolved at once, and the rest go to the
  pending translations; drag consumes the press and highlights. A step that cannot be resolved now
  (no MenuZ item, a letter the core's search would give another item, no window or point) consumes the
  action with `PDOS_DIAG_ADAPT`; one whose later steps have no queue, or a queue that refuses them, or more
  events than room, is consumed whole with `PDOS_DIAG_PEND` (nothing partial, C.12.1, C.13.4).
* **View actions.** The intro's and Birth's DOS key (`pdos_seq_view_key`: PDOS_KEY_ANY, or the shortcut
  letter), the box's own row one up or down, to the hotkey's item, or under the pointer during a drag
  (`pdos_seq_title_view_row`, refused by the sequencer while the core's MenuZ is ready). A view action runs
  only for an action not refused.
* **Step resolution (`pdos_adapt_resolve`).** Acts OWN (the user's press), RETURN (vk 0Dh, scan 1Ch,
  ch 800Dh, press and release), LETTER (core item k's first character as press and release: vk 'A'+..,
  the set-1 scan code, ch 8000h | the character; only when MenuZSubclassWndProc's letter search from its
  selection, 1220:13F6..145D, would select k: from the selection + 1, wrapping, skipping empty and
  disabled items, tolower compare, letters only), CLICK (move, press, release at core item k's control,
  class C) and MOVIE (the same at the movie window, class X). The MenuZ globals are read with `w16q_rd16`:
  `g_menuItemCount` 12D8:44FE, `g_menuSelection` 12B0:009C, `g_menuDisabledMask` 12D8:24DA (items from 16
  on have no bit), `g_menuItemWindows` 1420:B3E8, each item's first window-text byte through `w16q_wnd`.
* **Hooks for tests.** `pdos_adapt_set_hooks` (time, scene, view key, view row, MenuZ, movie window,
  point; NULL members take the defaults), `pdos_adapt_set_log`, `pdos_adapt_last_row`,
  `pdos_adapt_actions`. `pdos_adapt_set_pend(&PdosPendOps{start, cancel})` is D4c2's registration.
* **Diagnostics.** `PDOS_DIAG_ADAPT` ("adapt"), `PDOS_DIAG_PEND` ("pend"), `PDOS_DIAG_PAIR` ("pair") in
  `pdos_common.h` and `pdos_assets.c`'s names.
* `pdos_seq_reset` calls `pdos_adapt_reset` (the tables and counters; hooks, log and queue stay).

### The adapter rows (`present/dos/pdos_adapt_tab.c`; DOS-PROFILE.md 1.7.2)

Data only, 36 rows, 8 step sequences (12 steps); the first row whose scene, core state and action bits
match decides. DOS-PROFILE.md 1.7.2 ("Adapter table, version 2 (generated)") is generated from it by
`gen/dos/adapters.py` and checked by test.cmd (ADAPT_OK). In brief:

| Rows | Scene, core | Decision |
| --- | --- | --- |
| I-intro/shortcut/core-intro | pan, intro | the key itself (the core's skip), then at the ready title MenuZ item k's letter and Return; DOS key the letter |
| I-intro/shortcut/core-title | pan, title ready | item k's letter and Return at once; the key consumed; DOS key the letter |
| I-intro/shortcut/core-wait | pan, waiting | consumed; letter and Return queued for the ready MenuZ |
| I-intro/key, dissolve-key | intro phases, intro / title | pass (the core's skip) / consume (I6); DOS key except in the dissolve |
| I-intro/click, dissolve-click | intro phases, intro / title | the click at the movie window (X) / consume; DOS key except in the dissolve |
| I-intro/other | intro | right press, bare character: consume |
| I-title/escape-alt-right, edge, key | box | consume (no cancel, help, sound; no wrap) |
| I-title/up-down | box, ready / not ready | pass / consume and move the box's own row (T4) |
| I-title/return, space | box, ready | pass / Return 1:1 |
| I-title/return-space/core-intro, core-wait | box, T4 | own key then (or only) item k's letter and Return queued |
| I-title/hotkey | box, ready / not ready | item k's letter (selects only) / consume and move the box's own row |
| I-title/press, release/*, release-outside | box | drag; release in row k: click on item k's control and Return at selection k (with the movie click first in the core's intro); outside or disabled: consume |
| I-title/chosen, hold-key, hold-press | chosen / hold | pass (presses at the movie window) / pass keys, consume presses |
| I-birth/key, click, other | Birth | pass with a DOS key, click at the movie window, consume the rest |
| I-none/key, press | none | pass keys and characters, consume presses (no target without a row, C.14.1) |

### The hotkey decision (D4b2b2 Deviation 2)

The DOS title box's hotkey only selects (R:1D05:03FD..03E0 sets the selection, R:1D05:01C8; nothing is
chosen). With the core's title MenuZ ready the translation is core item k's letter (press and release),
which MenuZ's letter search turns into a selection without a choice (MenuZSubclassWndProc 1220:13F6..145D);
when that search from the core's selection would select another item first, the action is consumed
(`PDOS_DIAG_ADAPT`), so the two screens never disagree. Before the core's MenuZ (T4) the hotkey moves the
box's own row. C.12.5's and C.12.6's "select and choose" is not followed (Deviation 1).

### Mouse conversion (`present/dos/pdos_mouse.h/.c`, I5, C.14)

Pure arithmetic: `pdos_mouse_ceil16` (classes P and W: d = ceil(16 L / 10) = (8 L + 4) / 5),
`pdos_mouse_scale` (class S: floor(1.6 L) = L * 160 / 100, ScaleLogicalX / Y 11E8:0D81 / 0DA8), the core's
back conversions `pdos_mouse_back_p` ((int16)(10 d) / 16, PollMouseClick 1108:0169..018F) and
`pdos_mouse_back_w` ((uint16)(10 d) >> 4, WaitForKeyOrClick 1038:0CB6..0CE2), `pdos_mouse_device`,
`pdos_mouse_centre` (the largest rectangle's centre, the first of equal ones), `pdos_mouse_in`,
`pdos_mouse_sub` (a rectangle list less a rectangle). `pdos_mouse_point(cls, hwnd, lx, ly, &sx, &sy)`
under CIV_OBSERVER (0 without): class C the centre of the largest rectangle of the control's visible
region (`w16q_wnd_vis`) less the windows above it at each level; class X the client's centre when visible,
else the centre of the client's largest visible rectangle; classes P, W and S the client's origin plus d,
when inside the client's visible region. No target: 0, and the caller consumes (C.14.1).

The C.14.2 proofs are unit vectors in `test_pdos_mouse.c`: for L = 0..319 (x) and 0..199 (y) both back
conversions of ceil16(L) give L, d is the least such value, and d stays in the 512 x 320 client (x <= 511,
y <= 319); for every [L0, L1) within 0..320 and every L in it, floor(1.6 L) lies in [floor(1.6 L0),
floor(1.6 L1)); the class-P counterexample (the forward scale read back by PollMouseClick: L = 1 gives 0);
P and W agree for d = 0..3276 and differ from 3277 (10 d no longer fits 15 bits).

### Area A (`present/input.c/.h`)

The defaults are `{pdos_adapt_note, pdos_adapt_filter, pdos_seq_autocontinue_release, pmap_filter_ring}`;
`present_input_set_dispatch` takes NULL members as these. Two compile-time checks: PDOS_PEND_EVENTS <=
PI_MAX_OUT, and area C's frame numbers equal PiFrame's (pdos_adapt.h may not include input.h: the include
rule of `gen/dos/registry.py`).

### The generator and the lint

* `gen/dos/adapters.py check|gen|print`: parses the rows and step sequences of `pdos_adapt_tab.c` and the
  constants of `pdos_adapt.h`/`pdos_mouse.h`; checks unique ids, adapters named in DOS-PROFILE.md 0.3, known
  constants, steps only on STEPS rows, at most 6 steps of at most 4 acts and 8 events, OWN only in a first
  step that waits for nothing, passed presses class X, no `|` in a cell, no Windows SSSS:OOOO address in the
  generated text (obs_tables.py reads the document); renders section 1.7.2 between
  `<!-- adapters.py: begin/end -->` and checks the document against it (ADAPT_OK rows 36 steps 12).
* `tests/harness/obs_lint.py`: area C's rules now cover `present/dos/pdos_*.h` too, and I1's rule: a host
  event type `HOST_EV_<x>` appears in `present/dos/pdos_*.[ch]` code only in the filter stage
  (`pdos_adapt.c`, `pdos_adapt.h`) and inside `pdos_seq.c`'s `pdos_seq_autocontinue_release` (D4b4's
  exception); selftests for both.
* `gen/dos/registry.py`: `pdos_adapt.c` and `pdos_mouse.c` join OBSERVER_FILES (they include `w16_obs.h`
  for their `w16q_*` reads, under CIV_OBSERVER), see Deviation 5.
* `test.cmd`: one delimited section "extension D4c1 (begin) .. (end)" after D4a's pdos_scene_check: `[D4c1:
  adapters.py check]` (all variants).

## Tests

Checked counts (`build/d4c1-2-test-checked.log`); 39 test programs (37 before).

* **`tests/test_input.c`** 227 checks (142 before; CheckedNoObs 203): area C's filter stage on synthetic
  scenes through `pdos_adapt_set_hooks` (scene, MenuZ, movie window and points synthetic; view actions and
  a queue recorded), runnable in both observer variants:
  * `adapt_rows`: the table's bounds (36 rows, unique ids, steps only on STEPS rows, at most 6 steps of at
    most 8 events, passed presses class X) and one vector per row (36): the row chosen, the events
    returned, the steps queued with their row index, and after the release every posted press released
    and every event frame 0; a coverage check that each row has its vector.
  * `adapt_pairing`: pass, consume, 1:1, pairs and drag with repeats and releases; the letter-search
    conflict and an unreadable MenuZ (PDOS_DIAG_ADAPT); a disabled row; a click with no movie point; OWN
    first steps; a refusing queue and no queue (PDOS_DIAG_PEND, nothing posted, no view action); the
    output bound (4 events with room for 3: nothing); Alt held elsewhere.
  * `adapt_frames`: the note's cancels (frame-0 key press, character, frame-3 and frame-4 presses, frame-1
    press; not repeats, moves, releases) with the identity; a frame-0 press released on frame 1 at the last
    frame-0 point; a ring press released on frame 1 (PDOS_DIAG_PAIR); an unseen release; a consumed press
    and key whose later parts arrive on frame 0 (a switch or a focus loss); Space as Return released on
    frame 0; a box drag released on frame 3; a passed click released on frame 0; frame 2; the close box.
  * `filter`: the D3-stub checks now check the D4c1 defaults (frame 2 and the I-none row pass as frame 0,
    a frame-1 press consumed and its frame-0 release routed by the note, the default ring and release).
* **`tests/test_pdos_adapt.c`** (new) 48 checks: the real sequencer driven by synthetic probes with the DOS
  store: a key and a click in the pan with the core in its intro pass and end the DOS intro (the dissolve at
  11 s; without input the pan goes on); with the core at its title the key is consumed and still ends it;
  a shortcut with the title MenuZ ready gives core item 0's letter and Return and preselects (T4 hold), keys
  in the hold pass; the box in T4 (Down, a hotkey to Quit, the edge, Up, Escape, a drag highlighting and
  released with and without a queue) and with the core's MenuZ ready (Down passes, Space becomes Return,
  Return passes, a hotkey gives the core item's letter, a release a class-C click and a queued Return),
  `pdos_adapt_resolve`, the chosen box; Birth's key (a DOS key pending) and click; a scene without a row;
  the DOS generator never called.
* **`tests/test_pdos_mouse.c`** (new) 33 checks (20 in CheckedNoObs, without the fixture): the C.14.2
  vectors (classes P and W for every N coordinate, minimality, the 512 x 320 bound; class S for every
  [L0, L1) within 0..320, 5,512,640 cases; the class-P counterexample; P against W), the rectangle helpers
  (`pdos_mouse_sub` included), and the w16 fixture: two overlapping child controls, where the centre of the
  lower control's rectangle is delivered to the control above it but the class-C point to the lower
  control itself, class X and the client-origin classes delivered to the window, no point for a missing
  or hidden window.
* **Tools**: `adapters.py check` ADAPT_OK rows 36 steps 12 (test.cmd's new section); obs_lint OBS_LINT_OK
  with the I1 rule and its selftests (a planted HOST_EV_ in `pdos_ui.c`/`.h` was caught, in a scratch copy);
  REGISTRY_OK (the include rule with the new observer files); NODOS_OK; OBS_TABLES_OK probes 203 sites 98
  (DOS-PROFILE.md with 1.7.2).

## Results

`build/d4c1-status.txt`:

```
1-build-checked exit 0 seconds 234 start 16:44:30 end 16:48:25 log build/d4c1-1-build-checked.log last: BUILD_OK variant=Checked
2-test-checked exit 0 seconds 2483 start 16:48:25 end 17:29:49 log build/d4c1-2-test-checked.log last: TESTS_OK variant=Checked
3-g1-checked exit 0 seconds 0 start 17:29:49 end 17:29:49 log build/d4c1-3-g1-checked.log last: EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)
ALL_GREEN
```

In test.cmd checked: REGISTRY_OK, NODOS_OK, OBS_TABLES_OK probes 203 sites 98, OBS_LINT_OK files 84,
pdos_scene_check 1,075 PASS, ADAPT_OK rows 36 steps 12, GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK,
P4_TESTS_OK, P0_OK checks 279, EXT_FRAMES_OK, EXT_TIMELINE_OK, EXT_CONTINUE_OK, EXT_ADAPT_OK checks 20,
MIRROR_OK runs 29, ZOOM_OK combinations 32, TRACE_OK; test_pdos_seq 114, test_present 521. The rebase found
no drift (all ten BASE-SHA256 hashes equal at the copy, 16:38:25 UTC); the cycle started after
`build/docs-p47b-done.txt` (16:44:30 UTC).

## Deviations

Format: section; what; why.

1. **C.12.5, C.12.6 (the title box's hotkeys).** Select only, not "select and choose": the listing
   (R:1D05:03FD..03E0, 01C8) selects; the translation is core item k's letter, consumed when the core's
   cyclic search from its selection would select another item (D4b2b2 Deviation 2 decided here).
2. **C.12.6 (Up and Down).** No wrap: Up on the first row and Down on the last are consumed (row
   I-title/edge; R:1D05:0368..036E, 020B..0212), where C.12.6 said they wrap.
3. **C.12.1 (frame 2).** The A canvas passes every event unchanged (as frame 0) in D4; its rows come with
   the scenes that show it (D5..D7). Frame-1 presses in an N scene without a row are consumed (C.14.1: no
   target), keys and characters pass (rows I-none/*).
4. **C.13 (D4c1 without D4c2).** The I4 queue is D4c2's: D4c1 defines its interface (`PdosPendOps`,
   symbolic `PdosStep`s resolved at release by `pdos_adapt_resolve`) and, with none registered, consumes
   an action whose translation needs a queued step whole (`PDOS_DIAG_PEND`). Until D4c2 the rows
   I-intro/shortcut/core-intro and core-wait, I-title/return-space/core-intro and core-wait, and
   I-title/release/* do nothing (their DOS view actions do not run either).
5. **`gen/dos/registry.py`** (not in the unit's file list): OBSERVER_FILES gains `pdos_adapt.c` and
   `pdos_mouse.c`, which read the emulation through `w16q_*` like `pdos_seq.c`; a one-line change, needed
   by the include rule.
6. **C.15.2 (the test files).** The I5 vectors and the class-C fixture are in a new `tests/test_pdos_mouse.c`
   (the fixture needs civ.exe's NE image and the VM, which `test_input.c` does not set up); the real
   sequencer cases are in a new `tests/test_pdos_adapt.c` (they need the DOS store); `test_input.c` has the
   synthetic-scene cases.
7. **C.14.2 class C.** The control's visible region less the windows above it at each level, not the
   visible region alone: w16 keeps a child's higher siblings in its region unless WS_CLIPSIBLINGS
   (`vis_region`, as Windows 3.1), while the hit test takes the topmost window; the fixture's overlapping
   controls showed the difference.
8. **C.12.2 (a 1:1 key's repeats).** Consumed, not translated (Space's auto-repeat does not repeat Return).
9. **I-title/chosen.** Presses after the core's choice pass as clicks at the movie window (class X); when
   the movie window is gone they are consumed with `PDOS_DIAG_ADAPT`.

## What D4c2 must know

* **Register the queue** with `pdos_adapt_set_pend(&ops)`: `start(steps, n, row, now_us)` receives the steps
  after the first one released at once (or all of them when the first waits) and answers 1 when it keeps
  them, 0 to refuse (the filter then consumes the whole action with `PDOS_DIAG_PEND`); `cancel(why,
  now_us)` is called with `PDOS_PC_ACTION` on every user action of any frame (key press not a repeat,
  character, button press), before the new action is decided.
* **Steps are symbolic.** Each `PdosStep` has a predicate (`PDOS_PR_*` with arg, arg2) and up to 4 acts
  (`PDOS_A_*` with arg = the item; OWN carries the user's press). Resolve a step at its release with
  `pdos_adapt_resolve(step, out, max)`: 0..max events (frame 0), or -1 when it cannot be resolved now
  (cancel with PDOS_PC_STATE). Events of one step <= PDOS_PEND_EVENTS (8), steps <= PDOS_PEND_STEPS (6).
* **Predicates** read `pdos_seq_core()`: MZ_READY = `mz_active && mz_ready && mz_kind == arg && mz_sel >= 0`
  (the same test as the filter's "title ready"); MZ_SEL = `mz_sel == arg` (read at MenuZ's key poll).
* **The release entry.** `pdos_pend_release` replaces `pdos_seq_autocontinue_release` in `PiDispatch` and must
  call it once per call (D4b4's notes), sharing `out`/`max`.
* **Pairing.** A queued click is a complete move/press/release; a queued key is a press and release; the
  queue never holds a half pair. The filter has already decided the user's own press (FD_PASS when OWN was
  released, else consumed), so its release needs nothing from the queue.
* `PDOS_DIAG_PEND` counts every whole-action refusal; once D4c2 registers its queue the D4c1-only
  refusals (Deviation 4) stop.
* The rows that queue steps: I-intro/shortcut/core-intro, core-wait; I-title/return-space/core-intro,
  core-wait; I-title/release/core-title, core-intro, core-wait (the generated table lists them).

## For the records

For the docs agent; nothing below was edited by this unit except DOS-PROFILE.md 1.7.2 (generated, already
in place).

* **DESIGN.md 12.5** (area A, the filter stage paragraph): replace "Until D4 and M the four entries are
  D3's stubs (`PiDispatch`, replaceable by `present_input_set_dispatch` for tests), so D3's input reaches
  the core unchanged." with "The four entries are area C's `pdos_adapt_note` and `pdos_adapt_filter`
  (D4c1), D4b4's `pdos_seq_autocontinue_release` and M's `pmap_filter_ring` (`PiDispatch`; a NULL member of
  `present_input_set_dispatch` takes its default). `input.c` checks at compile time that
  PDOS_PEND_EVENTS <= PI_MAX_OUT and that area C's frame numbers equal PiFrame's." Add: "Every event the
  filter stage returns for frames 1 and 2 is a Windows-form event (frame 0)."
* **DESIGN.md 12.8** (area C): add "**Added in D4c1 (area C).** Record [ext-D4c1-record.md](ext-D4c1-record.md)
  (2026-10-15): `pdos_adapt` (the filter stage: pairing tables, DOS-form action bits, the first matching row
  of `pdos_adapt_tab.c` decides at the sync, decisions pass / consume / 1:1 / steps / drag, view actions
  through `pdos_seq_view_key` and `pdos_seq_title_view_row`, symbolic steps resolved by `pdos_adapt_resolve`,
  the queue interface `PdosPendOps` for D4c2, diagnostics adapt, pend, pair), `pdos_adapt_tab.c` (36 rows:
  I-intro, I-title, I-birth, I-none; DOS-PROFILE.md 1.7.2 generated by `gen/dos/adapters.py`, ADAPT_OK in
  test.cmd) and `pdos_mouse` (I5 classes X, C, P, W, S; class C less the windows above the control). The
  title box's hotkeys select only; Up/Down do not wrap; frame 2 passes; a translation needing a queued step
  is consumed whole until D4c2. Tests: `test_input` (synthetic scenes), `test_pdos_adapt` (the real
  sequencer), `test_pdos_mouse` (the C.14.2 proofs, the w16 class-C fixture); obs_lint's I1 rule." In the
  "Left" bullet of "As implemented (D4b)", replace the D4c sentence by "D4c2: `pdos_pend` (I4), the
  host-input run and the D4 gate."
* **FIDELITY.md**:
  * F146: replace "the view's own keys (`pdos_seq_view_key`) come with D4c" with "with the DOS profile
    visible the player's own key or click is also the DOS key at the sync (D4c1's filter stage, rows
    I-intro/*): a key passes to the core while it is in its intro and is consumed once it waits at its
    title (I6); either way the DOS intro ends".
  * A new row "the DOS filter stage (`present/dos/pdos_adapt.c`, `pdos_adapt_tab.c`; C.12, I1..I6)":
    DOS-form input on the N canvas is decided by the DOS view at the sync; the title box takes Up/Down (no
    wrap, R:1D05:0368..0374, 020B..0214), hotkeys that select only (R:1D05:03FD..03E0, 01C8; the core item's
    letter), Return, Space (as Return), and consumes Escape, Alt keys, the right button and characters; a
    left press in the DOS intro or Birth is a click at the movie window (**Windows-only**, P25: the DOS
    program reads no mouse); presses in N scenes without a row are consumed. Status: implemented in D4c1;
    the title box's click and the T4 translations need D4c2's queue. Label: **DOS listing** for the box's
    keys; **choice** for the Windows-only passes.
  * A new row "the DOS mouse conversion (`present/dos/pdos_mouse.c`; I5, C.14)": classes P and W
    d = ceil(16 L / 10) (PollMouseClick 1108:0169..018F, WaitForKeyOrClick 1038:0CB6..0CE2), S floor(1.6 L)
    (11E8:0D81 / 0DA8), C the control's visible centre less the windows above it, X the client centre;
    proved for every N coordinate by `test_pdos_mouse` (**core listing**, unit vectors).
* **RUNNING.md**: under the DOS profile, "Input with the DOS profile visible": keys and clicks act on the
  DOS screens as DOS reads them (the title box's keys; a click ends the intro); the diagnostics `adapt`,
  `pend`, `pair` in presentation-diag.log; `gen/dos/adapters.py check|gen|print` (regenerates
  DOS-PROFILE.md 1.7.2 after a row change).
* **STATUS.md**: D4c1 done (this record; three-step cycle ALL_GREEN, `build/d4c1-status.txt`); next D4c2 (the
  D4 gate). Test counts as in "Results".
* **DOS-PROFILE.md**: 1.7.2 is generated (done). Rows 1 (intro), 2 (title) and 9 (Birth) could point to
  1.7.2 for their input columns; 0.3's adapter list already names I-intro, I-title, I-birth and I-none (the
  generator checks it).
* **manual-checklist-ext.md** (pending user checks, Checked build with the DOS data):
  * D4-2 (a click ends the DOS intro) is now testable: with `--graphics dos`, click during the pan, the logo
    or the hold.
  * New: "With the DOS profile visible, press a key (not N, L, E, C) during the DOS intro's pan while the
    Windows intro still plays: both intros end; the DOS title box follows the dissolve."
  * New: "The DOS title box takes DOS keys: Up and Down move the bar and stop at the first and last row
    (no wrap); S, L, E, C, V, Q move the bar to that item without choosing it; Return or Space chooses the
    highlighted item (the core follows); Escape, Alt+H, Alt+V and the right button do nothing."
  * New (after D4c2): "A click on a row of the DOS title box chooses that row" and "N, L, E or C during the
    DOS pan preselects that item (no box) and the game opens it once its title menu is ready".
* **OFFSETS.md**: no rows added (the adapter reads no DOS data).
* **Files outside the unit's list**: `gen/dos/registry.py` (OBSERVER_FILES, Deviation 5).

## Review fixes (D4cF)

Unit D4cF (2026-10-15) fixes the findings of the independent review
[verify/ext-d4c-review.md](verify/ext-d4c-review.md) (accept with fixes: R1 MAJOR, R2..R8 MINOR) and carries out
the user's direction on checklist item D4-3 (about 19:30 UTC, "This should not be.": with the DOS profile visible
a lone Ctrl or Shift must not skip), which the orchestrator extended to Alt, Caps Lock, Num Lock and Scroll Lock
(19:45 UTC) and the user accepted (about 19:50 UTC, "your decision is sound and accepted"). The text above is the
record of D4c1 as built and stays; this section corrects it. D4c2's parts (R1's cancellation hook, R4, R6's wait)
are also in [ext-D4c2-record.md](ext-D4c2-record.md) "Review fixes (D4cF)". Status: done; its three-step cycle is
ALL_GREEN (`build/d4cf-status.txt`, 22:14:19 UTC; "Results" below).

### Corrections to the text above (R7)

* "The pairing rule (C.12.2)", its last sentence: only a **button** release with nothing to follow on frame 1 (or
  the release of a ring press) is consumed with `PDOS_DIAG_PAIR`; a **key** release whose press passed, or was
  never seen, passes unchanged (`pdos_adapt.c` `key_up`). The code was right, the text wrong. In the same
  paragraph, "its repeats ... follow that decision whatever frame they arrive with" now has two exceptions: the
  frame-1 repeats of an Up or Down that a title-box row decided are decided again (R2), and the repeats of a
  translation's OWN press are consumed on every frame (R6).
* "The DOS-form action (C.12.3, C.12.5)": "N, L, E, C (O2:09F1..0A4C, either case)" did not hold for a capital as
  built: the arrival stage delivers a held Shift just before the key it modifies (K3), the filter decided that
  Shift alone as a skip key (C.20-7, row I-intro/key/core-intro), the pan ended, and the N was no shortcut. It
  holds now (D4-3 below: the Shift is consumed, the N decided on its own).
* "no wrap" (the same paragraph; Deviation 2; the checklist text proposed under "For the records", "stop at the
  first and last row"): as built only the press was decided and its auto-repeats followed it, so a held Down
  passed in READY reached the core's MenuZ, which wraps, and a held Up or Down in T4 moved the box's own row once.
  It holds now for held keys too (R2).
* Row counts ("The adapter rows", "The generator and the lint", "Tests", "Results", "For the records"): the table
  has 38 rows since D4cF (I-intro/modifier and I-birth/modifier, D4-3); ADAPT_OK rows 38 steps 12; `test_input`'s
  `adapt_rows` checks 38 rows with one vector each.

### The fixes

Each rule is the one closest to the DOS listing and the brief. Each has a vector (in `tests/test_pdos_adapt.c`
unless named) that fails on the code as built and passes now (R8; "Results").

* **R1 (MAJOR): a cancelled shortcut voids the DOS preselection.** When the pending translation of an intro
  shortcut is cancelled (another user action, the 10 s limit, a lost state or an overflow) and the core has made
  no title choice, the DOS view takes its preselection as none, as DGROUP:6B32 = -1: the title code tests `cmp
  word ptr [6B32h], -1` at R:01A8:04BB and, with no choice, goes back to the box at R:01A8:0494 (R:01A8:04C0 `je`;
  the box's result is stored at R:01A8:04B8). From HOLD the box is drawn at once and the cancelling key is decided
  on it (row I-title/key); before the hand-over the DOS intro ends in the box, not the hold. Code:
  `pdos_seq_pend_cancelled` (new, `pdos_seq.h/.c`), called by `pdos_pend.c`'s cancel; `TitleBox.pre_void`. Row
  text I-title/hold-key. Vector `test_r1` (a cancellation before and one after the hand-over; the limit at 10 s
  and at 10 s + 1 us).
* **R2: the repeats of Up and Down on the title box are decided again.** A frame-1 auto-repeat of an Up or Down
  that a title-box row decided is decided by the row of its own moment: it passes only when its press passed and
  that row passes (READY with a row to move to); at the edge it is consumed (no wrap, R:1D05:0368..0374,
  020B..0214); in T4 it moves the box's own row one step, as the DOS box takes each typematic key. A repeat is no
  new action: no cancellation, no count, no log line. Code: `Fd.rep`, `box_repeat`. Row texts I-title/edge,
  I-title/up-down/t4. Vector `test_r2` (T4 to the last row; READY at the last row).
* **R3 and D4-3: a lone Ctrl, Shift, Alt, Caps Lock, Num Lock or Scroll Lock is no key in the DOS intro and the
  DOS Birth.** The user's direction (Ctrl and Shift directed about 19:30 UTC; Alt and the lock keys by the
  orchestrator's ruling of 19:45 UTC, accepted by the user about 19:50 UTC) replaces decision C.20-7 (F115's
  choice) for the DOS profile and settles R3. A press of one of these six keys (vk 10h, 11h, 12h, 14h, 90h, 91h)
  on the N canvas has the new action bit `PDOS_AA_MOD`; rows I-intro/modifier (pan, logo wait, reveal, hold,
  dissolve; any core state) and I-birth/modifier consume it with its repeats and release, whether the arrival
  stage delivers it alone at its release or just before another key (K3 for Ctrl and Shift, S2's Alt hold-back for
  Alt; the lock keys are delivered as they come). The host chords (Ctrl+Shift+Backspace and the zoom chords,
  Alt+Enter, UX1's Alt+F4) are taken by the arrival stage first and never reach the filter. The DOS program tests
  its keyboard with `kbhit` (R:2045:2098; SCENES 4.4 O2:04C1, O2:082A; 5 O2:0AF6..0B19; 8 O7:1912), which none of
  these keys satisfies alone (PC fact: alone none stores a key in the BIOS keyboard buffer), so neither the DOS
  view nor the core skips (the core would otherwise part from the DOS view). The key after it is decided on its
  own: Shift+N in the pan is the N shortcut (O2:09F1..0A4C reads either case), Ctrl+X is X (a skip and a DOS key),
  Alt+N is an Alt key and no shortcut (the BIOS gives Alt+letter no character, as the box's Alt test R:1D05:03E3
  reads it), so it passes as a skip and is a DOS key. With the Alt consumed, the emulation posts that key as
  WM_KEYDOWN (it makes WM_SYSKEYDOWN only after a posted Alt, `platform/w16/queue.c`), the message the core's
  intro skip takes. Such a press cancels no pending translation (it is no DOS key), and the MK_SHIFT / MK_CONTROL
  bits of the mouse events the filter passes are cleared while it holds Shift or Ctrl consumed, as the core's key
  state (GetKeyboardState) never saw it down (Windows has no MK_ bit for Alt). The pairing rule keeps the core's
  key state whole across a profile switch: a key pressed with the DOS profile and released with the Windows
  profile is consumed at both ends, one pressed with Windows passes at both ends. The Windows profile is unchanged
  (frame 0: these keys still reach the core and skip, F114). Lock state: the host's own lock state (its lights and
  its character translation, which gives the events their characters) is untouched; the emulated toggle bit
  (`queue.c`, flipped at each posted press, 0 at start whatever the host's lights) does not flip for a lock key
  consumed in the DOS sequences. The core reads a lock toggle only through GetKeyboardState at 1008:02E6, where
  the game loop saves the Num Lock byte (g_savedNumLockState) and sets its toggle, and at 1008:033D, where it
  restores it into the emulated state at exit; the core imports no GetKeyState and reads Caps Lock and Scroll Lock
  nowhere. So what the core no longer sees is a Num Lock press made during the DOS intro or Birth in the byte it
  saves and restores; the restore writes only the emulated state, so nothing visible changes. The direction came
  before the build slot, so R3's first staged fix (a Shift held back in the pan until the next event) never
  reached the tree. Code: `no_dos_key`, `key_act`, `key_down`, `seen_bits` (`pdos_adapt.c`), `PDOS_AA_MOD`
  (`pdos_adapt.h`), the two rows (`pdos_adapt_tab.c`). Row texts I-intro/shortcut/core-intro,
  I-intro/key/core-intro, I-birth/key. Vectors `test_d43`, for each of the six keys: alone and ahead of X in the
  pan; alone in the logo wait (55.85 s), the reveal (57.65 s), the hold (58.80 s, which goes on) and the dissolve;
  alone with the shortcut's translation waiting (it stays); alone and ahead of X in Birth; with the Windows
  profile alone and ahead of X in the pan and alone in Birth; held across a switch either way; and Shift+N, Alt+N
  and a click while a consumed Shift is held. `test_input`'s two row vectors.
* **R4: MZ_SEL waits for the click to be read.** MZ_SEL(k) holds when the core's MenuZ is in its key poll with
  selection k and at least four key polls (`PDOS_PEND_SEL_POLLS`) have passed since the step was armed. The core's
  MenuZ loop takes one input message per iteration (PeekMessage PM_REMOVE at 1220:0ACE, after the key poll
  IsKeyPending, ra 1220:0AA5, whose ranged peek takes keys first); the click is three messages (move, press,
  release), and the release's WM_COMMAND (RandomRadioProc 1058:0789) sets the selection in MenuZSubclassWndProc
  (1220:1516..152B); one poll more covers where the arming falls in an iteration. So a selection that is already k
  before the click no longer lets the Return overtake the click. Limitation: other non-key input queued before the
  click could need more polls (none in D4's rows). A state source without the poll count (`PDOS_PK_POLLS`) keeps
  the selection-only rule. Code: `PdosCore.mz_polls`, `PdosPendState.mz_polls`, `PdosPend.armed_polls`. Row text
  I-title/release/core-title. Vectors `test_r4`, `test_r8_release_intro`; `test_pdos_pend`'s example 5.
* **R5: a capture loss is no release on the box.** The arrival stage marks the button releases it makes at a
  capture loss (`HostEvent.ch` = `PI_CH_CAPTURE_LOST`, 1; the adapter's `PDOS_CH_LOST`, equal by a compile-time
  check in input.c); a box drag's release so marked is outside every row (I-title/release-outside, consumed): DOS
  chooses only on the button's own release (R:1D05:016A..01D9). Code: `arrive.c` `release_buttons`, `input.h`,
  `pdos_adapt.c`'s drag release. Row text I-title/press. Vectors `test_r5`; `test_input` (the capture loss's
  releases carry the mark, a user's release none).
* **R6: a held key the core holds.** The repeats of a press decided by a row's OWN act (the user's own key to the
  core: the T4 box's Return or Space, an intro shortcut) are consumed on every frame, as the DOS box's flush
  R:1D05:003E discards typematic keys; a pending step whose events press a key the user still holds from such a
  press (or a Space mapped to Return) waits for the user's release (`pdos_adapt_key_down`,
  `pdos_adapt_held_press`, called by `pdos_pend.c`; the 10 s limit still counts). Code: `Fd.own`, `fd_routed`. Row
  texts I-intro/shortcut/core-intro, I-title/return-space/core-intro. Vector `test_r6`.
* **R8 (tests).** Besides the vectors above: `test_r8_release_intro` (row I-title/release/core-intro with the real
  sequencer: the movie click, the click on item 2 at the ready title MenuZ, Return at the fourth poll),
  `test_r8_letters` (the core's letter search 1220:13F6..145D from the selection + 1 with wrap: a repeated letter,
  selections 1 and 2), `test_pdos_mouse` (class X falls back to the largest visible rectangle when a popup covers
  the client centre; a panel above the control's parent is subtracted at the ancestor level and class C's point
  goes to the control). `test_r8_letters` and `test_pdos_mouse`'s new vectors also pass on the code as built:
  guards of existing behaviour.
* **Observations.** Fixed: `run_steps` refuses a row with more than `PDOS_PEND_STEPS` steps or `PDOS_STEP_ACTS`
  acts (`PDOS_DIAG_ADAPT`, the action consumed) instead of clamping it, and a first step that resolves to more
  than `PDOS_PEND_EVENTS` events is `PDOS_DIAG_PEND`; both stay unreachable with the table (adapters.py). Left as
  they are (records only): in READY a drag's highlight does not follow the pointer (DOS moves the bar,
  R:1D05:016A..01B7); in T4 the box's own row moves are dropped when the core becomes ready, so the bar jumps to
  the core's selection (D4b2b2's design); `above()` does not subtract the control's own children (the item
  controls have none); C.14.2's "to 6553" for class P (exact only to 3276 with the code's arithmetic; no input
  reaches either); `pdos_seq_reset` while a MAP key (Space as Return) is held lets its release pass as Space.
  Found here and settled: a lone Alt, Caps Lock, Num Lock or Scroll Lock was still a key after the first D4-3
  change; the orchestrator's ruling, accepted by the user, treats them as Ctrl and Shift (above).

### Results

* **After the fixes**: private builds of the tree with the stage laid over it (`build/d4cf-stage/obj`, build.cmd's
  flags; the eight changed sources also as C11 and through the C99 parse), the test programs run with the gamedata
  read-only and their output under the stage: 39 of the 40 programs (`test_ne`, untouched, not run), PB_RAN=39
  PB_BAD=0 in Checked, CheckedNoObs and Release. Counts (Checked / CheckedNoObs / Release; before D4cF in
  brackets): `test_pdos_adapt` 145 / 145 / 145 (48), `test_pdos_pend` 104 / 104 / 104 (102), `test_input` 234 /
  207 / 234 (230 / 203 / 230), `test_pdos_mouse` 38 / 20 / 38 (33 / 20 / 33); `test_pdos_seq` 114, `test_timeline`
  148, `test_pdos_profile` 38, `test_map` 127, `test_present` 521 unchanged.
* **The new vectors on the code as built** (the tree's sources with the stage's tests, `obj/before`, Checked):
  `test_pdos_adapt` 58 of 145 fail (every R1, R2, R4, R5, R6 and D4-3 vector for the DOS profile and
  `test_r8_release_intro`; `test_r8_letters` and the D4-3 vectors of the Windows profile pass, as guards),
  `test_pdos_pend` 3 of 104 (R4), `test_input` 4 of 234 (R5's mark, the row count and the two new rows);
  `test_pdos_mouse` passes (R8's guards).
* **Checks on the merged tree** (`obj/src`): `adapters.py check` ADAPT_OK rows 38 steps 12 (after `gen`); obs_lint
  OBS_LINT_OK files 86 probes 203 callsites 98; the include rule (`registry.check_includes`) OK; `obs_tables.py
  --check` with the staged DOS-PROFILE.md OBS_TABLES_OK probes 203 sites 98.
* **The three-step cycle** (the build slot after unit CY; the 17 files copied into the tree at 21:29:10 UTC with
  no rebase needed, every base still matching; `build/d4cf-status.txt` ends ALL_GREEN, 22:14:19 UTC; logs
  `build/d4cf-<n>-<step>.log`): 1 `build.cmd checked` BUILD_OK (222 s; 276 portable sources); 2 `test.cmd checked`
  (parallel) TESTS_OK (1,168 s; 21 sections, failed 0): `test_pdos_adapt` 145, `test_pdos_pend` 104, `test_input`
  234, `test_pdos_mouse` 38 checks, REGISTRY_OK, NODOS_OK, OBS_TABLES_OK (probes 203, sites 98), OBS_LINT_OK
  (files 86), ADAPT_OK rows 38 steps 12 (36 before, as expected), P0_OK 279, EXT_FRAMES_OK, EXT_TIMELINE_OK
  (hostkey unchanged: Return released at sync 82147, 4.1225 s), EXT_CONTINUE_OK, EXT_ADAPT_OK 56 (every pair
  equal; d-title-mouse's Return now 0.004 s after the click, 0.003 s before, as expected from R4; d-pan-n-intro
  1.86875 s, d-pan-n-early 3.6225 s and d-box-t4 0.4225 s unchanged; d-cancel-frames one start cancelled by the
  user's X), MIRROR_OK 29, ZOOM_OK 32; 3 `ext_g1.py check` EXT_G1_OK runs 77 (amended 1: game/p4-menus frames
  events). No harness expectation or golden changed. Step 2's first run (21:33:09..21:53:55 UTC,
  `build/d4cf-2-test-checked-run1.log`) failed only `d2_nodos`: the cycle script's status lines had gone to a
  stray file `docs/System.Collections.Hashtable` (PowerShell's names ignore case, so the loop variable replaced
  the status path), which nodos.py listed and could not read after it was removed; the file was removed, the
  script fixed, step 1 kept (no change since the copy-in) and steps 2 and 3 run again (21:54:51..22:14:19 UTC).
  CheckedNoObs and Release: the private runs above only; Asan deferred (user direction).

### For the records (D4cF)

* **DOS-PROFILE.md** (mine; staged): 1.7.2 regenerated (38 rows; the two new rows and the texts of
  I-intro/shortcut/core-intro, I-intro/key/core-intro, I-title/edge, I-title/up-down/t4,
  I-title/return-space/core-intro, I-title/press, I-title/release/core-title, I-title/hold-key, I-birth/key);
  1.7's version-1 rows I-intro and I-birth note the lone Ctrl, Shift, Alt and lock keys.
* **FIDELITY.md**: F115 revised, for Ctrl, Shift, Alt and the lock keys: "With the DOS profile visible a lone
  Ctrl, Shift, Alt, Caps Lock, Num Lock or Scroll Lock is consumed in the DOS intro and the DOS Birth (rows
  I-intro/modifier, I-birth/modifier): neither the DOS view nor the core skips, as the DOS program's `kbhit`
  (R:2045:2098) never sees one of them alone; the key after it is decided on its own (Shift+N is the N shortcut,
  Alt+N an Alt key). With the Windows profile they still skip (F114). The user's direction on D4-3 (Ctrl and Shift
  directed 2026-10-15 about 19:30 UTC; Alt and the lock keys accepted about 19:50 UTC), no longer a choice;
  decision C.20-7 superseded for the DOS profile. The core no longer sees a Num Lock press made during the DOS
  sequences in the byte it saves at 1008:02E6 and restores at 1008:033D (emulated state only, nothing visible).
  Status: implemented in D4cF. Label: **DOS listing** with **PC fact**." F156: 38 rows; the held-key rules (R2,
  R6) and the capture-loss release (R5). F158 as listed in ext-D4c2-record.md. F114 unchanged.
* **DESIGN.md**: about line 2929, "lone modifiers are skip keys in DOS sequences (C.20-7)" becomes "lone Ctrl,
  Shift, Alt and lock keys are no keys in DOS sequences with the DOS profile visible (the user's direction on
  D4-3, superseding C.20-7; D4cF)"; 12.8 "Added in D4c1" (about line 3083): 38 rows.
* **docs/verify/ext-d1-decisions.md**: the C.20-7 row marked "superseded for the DOS profile by the user's
  direction on D4-3 (2026-10-15: Ctrl, Shift, Alt and the lock keys; D4cF)"; item 8 of that row unchanged.
* **manual-checklist-ext.md**: D4-3 rewritten to "During the DOS intro and the DOS Birth story press Ctrl, Shift,
  Alt, Caps Lock, Num Lock or Scroll Lock alone: nothing happens (the DOS program ignores these keys alone); with
  the Windows graphics they still skip." (pending, D4cF). New items: "Hold Down (or Up) on the DOS title box,
  before and after the game's title menu is ready: the bar stops at the last (first) row"; "Shift+N during the DOS
  pan preselects New Game, as N does"; "N during the DOS pan, then another key before the title: the DOS title box
  appears (no black screen without a box)".
* **RUNNING.md**: ADAPT_OK rows 38 steps 12.
* **STATUS.md**: D4cF after its cycle.

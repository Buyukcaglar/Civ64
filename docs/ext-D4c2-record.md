# Extension phase D4, unit D4c2 (pending translations, the 7.8 DOS-form scripts, the D4 gate) - record

Unit D4c2 of the "civ64" extension completes area C's input for D4: the pending translations of I4 (the steps
of a user action's translation that wait for a core state), the 7.8 DOS-form scripts of the intro, the title
box and Birth against their Windows-form pairs, the host-input run of 7.7, and the D4 phase gate
([ext-D4-acceptance.md](ext-D4-acceptance.md)).

Brief: [verify/BRIEF-d4.md](verify/BRIEF-d4.md), "D4c2" (and the D4c bullet for the gate record). Governing
prompts: `claude/docs/x64-port-scaling-dos-prompt.md` (5.6 I1..I8, 7.7, 7.8, 9's D4 gate) over
`claude/docs/x64-port-prompt.md`. Design: [verify/ext-d1-draft-C.md](verify/ext-d1-draft-C.md) C.13 and C.15.4
(C.12 as needed). Preceding units: [ext-D4c1-record.md](ext-D4c1-record.md) ("What D4c2 must know": the
`PdosPendOps` interface, symbolic steps, the rows that queue), [ext-D4b4-record.md](ext-D4b4-record.md)
("Notes for D4c2": the release entry calls the Birth auto-continue). Session E3, 2026-10-15.

Labels:

* **compiled**: the three language checks (`/std:c11`, `/std:c17` with `/W4 /WX`, the clang C99 parse).
* **headless**: unit tests and harness runs on `build/gamedata` (and the DOS copy `build/dosdata`, read).
* **DOS listing (model)**: timings on area C's clock model of the DOS program (no DOS oracle).
* **core listing**: facts read from the translated core (`claude/port/core`, read-only).

Scope:

* No DOS program was executed. Nothing was written to `C:\Projects\Civ1RE\dos`, `build/dosdata` or
  `C:\Projects\Civ1RE\original`. No UI was shown. No DOS byte is in the repository or a binary (NODOS_OK). No
  git command that writes was run. Asan was not built or run.
* Not edited: `core/`, `rt/`, `platform/w16/*`, the generated tables, `ext_g1.py`/`ext-g1-*.txt`,
  `p4tests.py`, `test_user.c` and every document other than this record and the gate record (the rest is under
  "For the records").
* Worked in a stage (`build/d4c2-stage`, the orchestrator's staging protocol) over D4c1's stage until the
  build slot; its code was compile-checked and its tests and harness runs were tried on a private mirror (the
  tree with both stages laid over it, built into the session's scratch directory) before the slot. At the slot
  (after D4c1's ALL_GREEN, 17:29:49 UTC) every modified file's tree copy still had its recorded base SHA-256
  (`build/d4c2-stage/BASE-SHA256.txt`: eight from D4c1's stage, three from the tree), so the stage was copied in
  unchanged; the cycle started after the D4c1 docs agent's `build/docs-d4c1-done.txt` (17:39:17 UTC).

## Status

**Done** (2026-10-15 19:05:46 UTC). Compiled and headless in Checked, CheckedNoObs and Release: the D4 gate's
eight-step cycle is ALL_GREEN (`build/d4c2-status.txt`; step 1 at 17:40:32..17:45:16 UTC kept after the session
ended during step 2's first run, steps 2..8 at 17:55:31..19:05:46 UTC; [ext-D4-acceptance.md](ext-D4-acceptance.md)
"The final cycle"). The gate record is [ext-D4-acceptance.md](ext-D4-acceptance.md). No DOS program was
executed; DOS-oracle comparisons not run; Asan not run; D4c2's user checks (D4-27, D4-28, the new item) pending.

## What was built

### The pending translations (`present/dos/pdos_pend.h/.c`, area C, C.13)

One translation at a time (`PdosPend`): the steps after the first one the filter released at once (or all of
them when the first waits), as D4c1's symbolic `PdosStep`s (a predicate with its arguments and up to four acts),
the user action's ordinal (`pdos_adapt_actions`), the adapter row, and the instant the current step was armed.

* **Start** (`pdos_pend_start`, D4c1's `PdosPendOps.start`). Refused (0; the filter then consumes the whole
  action with `PDOS_DIAG_PEND`, C.13.4) when it has no steps or more than `PDOS_PEND_STEPS` (6), a step with no
  act or more than `PDOS_STEP_ACTS` (4), an act that is not a produced key or click (RETURN, LETTER, CLICK,
  MOVIE; OWN, the user's own press, is the filter's first step only), or a predicate the state source cannot
  tell. Otherwise kept, armed at the action's sync and marked fresh.
* **Release** (`pdos_pend_release`, input.c's default `PiDispatch.pend_release`, C.13.2). Once per
  input-taking sync, after that sync's host events have been through the filter and its note. A translation
  started at this sync releases nothing more (its first step was this sync's). Otherwise the current step is
  checked in this order: its scene lost (cancel, `PDOS_PC_STATE`); armed more than `PDOS_PEND_LIMIT_US`
  (10,000,000 us of virtual time) ago (cancel, `PDOS_PC_TIMEOUT`); its predicate not holding (wait). When it
  holds the step is resolved by `pdos_adapt_resolve` at that instant (a control's point, an item's letter):
  unresolvable cancels (`PDOS_PC_STATE`), more than `PDOS_PEND_EVENTS` (8) events cancels
  (`PDOS_PC_OVERFLOW`), no room waits (nothing partial); else the events are returned (frame 0) and the next
  step is armed at this instant, so at most one step per sync. Then D4b4's Birth auto-continue
  (`pdos_seq_autocontinue_release`) is called once with the room left (`PI_MAX_OUT` 16 >= 8 + 2, a
  compile-time check in input.c).
* **Predicates** (`pdos_pend_holds`, C.13.3) read only a `PdosPendState` (none reads time): NONE always;
  MZ_READY(kind, step) MenuZ entered, in its key poll (IsKeyPending ra 1220:0AA5), of that kind, a readable
  selection (and the setup step for the setup kind); MZ_SEL(k) in the key poll with selection k; DLG_OPEN(id),
  EDIT_FOCUS, CURSOR(id), STACK_WOKEN(r) on the state's fields. The default state source is the sequencer's core
  state (`pdos_seq_core`), which tells NONE, MZ_READY and MZ_SEL in D4; `pdos_pend_set_state` installs another
  (tests; D5..D7 extend the default).
* **Lost state** (`pdos_pend_lost`, C.13.4): MZ_READY of the title while the core is outside BOOT, INTRO and
  TITLE (a branch, the outro, Birth, play); of the setup outside BIRTH and SETUP; MZ_SEL once its MenuZ has
  exited. The other predicates' scenes come with D5..D7 (the limit bounds them).
* **Cancellation** (`pdos_pend_cancel`, D4c1's `PdosPendOps.cancel`): another user action on any frame (the
  filter on frames 1 and 2, its note on frames 0, 3 and 4; not repeats, releases, moves, chords or switches:
  D4c1), a lost state, the limit or an overflow. A cancellation never produces input. Those other than a user
  action count the new presentation diagnostic `pend_cancel` (`PDOS_DIAG_PEND_CANCEL`).
* **Logs and counters**: `pdos_pend_set_log` (start, release with its events, done, cancel with its reason,
  refusal with its reason; the step's predicate and argument), `pdos_pend_stats`, `pdos_pend_active`;
  `pdos_pend_reset` from `pdos_seq_reset` (the state hook and the log stay).

### The wiring

* `pdos_adapt.c`: the default queue is `pdos_pend`'s (`{pdos_pend_start, pdos_pend_cancel}`;
  `pdos_pend_ops()` restores it); `pdos_adapt_set_pend(NULL)` still means none (D4c1's tests). So D4c1's rows
  that queue steps (I-intro/shortcut/core-intro and core-wait, I-title/return-space/core-intro and core-wait,
  I-title/release/*) now act (D4c1 Deviation 4 ends).
* `present/input.c`: the default pending release is `pdos_pend_release` (it was D4b4's
  `pdos_seq_autocontinue_release`, which it now calls).
* `pdos_seq.c`: `pdos_seq_reset` calls `pdos_pend_reset` after `pdos_adapt_reset`.
* `pdos_common.h`, `pdos_assets.c`: the diagnostic `pend_cancel` (presentation-diag.log gains the name).

### The harness's adapt.log (`tests/headless/harness.c`)

With `--host-input` and the DOS profile registered the harness writes `<outdir>/adapt.log` (C.13.4, C.15.4):
one `decide` line per user action the DOS filter stage decided (the row, the decision, the events returned),
one line per start, refusal, release, done and cancellation of a pending translation, each with the virtual
time and the input-taking sync's ordinal (`w16_host_input_syncs()`, the `sync N` of a Windows-form host
line), the released events as `event` lines, and an `end` line with the counters. Nothing else changes; the
file exists only in 7.8 runs with the DOS profile registered.

### The 7.8 DOS-form scripts (`tests/harness/ext_adapt.py`, C.15.4)

Thirteen pairs (26 runs, in parallel), each a DOS-form host script with `--graphics dos` (the N canvas
visible at the default 640x480 view: an N point (x, y) is the host pixel (2x + 1, 40 + 2y + 1) of
present_layout_compute's square integer layout) and a Windows-form host script with `--graphics windows`,
both with the checkpoints title-choice 11E0:0735, after-worldgen 11E0:01B2 and birth-end 11E0:01F7. Each pair
must give the same coreinput.log, run.log `frame`/`snapshot`/`result` lines, events.log and exit status. The
Windows-form events of a release come from the row (the produced letters, Return) as `sync N` lines at the DOS
run's release sync; a produced click's point from the DOS run's coreinput.log. Besides, from the DOS run's
adapt.log: the decided rows, the pending translations' counts (starts, releases, cancellations by a user
action; no refusal, timeout, lost state or overflow), each release within the limit, and the reached
checkpoints (or the result EXIT).

| Case | DOS form | Windows form |
| --- | --- | --- |
| d-intro-key | X in the pan, core in its intro | X (the core's skip) |
| d-pan-key-title | X in the pan, core at its ready title | nothing (consumed, I6) |
| d-pan-n-title | N in the pan, core at its ready title (example 1) | S, Return at once |
| d-pan-n-intro | N in the pan at 5 s, core in its intro (example 2) | N, then S, Return at the release |
| d-pan-n-early | N at 0.5 s (the longest wait) | N, then S, Return at the release |
| d-box-t4 | X at 1 s; Down, Up, Return on the box before the core's MenuZ (example 3) | X, Return, then S, Return at the release |
| d-title-arrows | Down, Down, Return on the box (the DOS intro ended by a consumed X) | the same |
| d-title-space | Space on the box | Return |
| d-title-hotkey | the box's hotkey e, Return | P (selects only), Return |
| d-title-quit | the box's hotkey q, Return | Q, Return (the core quits) |
| d-title-mouse | press and release on the box's row 3 (example 5) | a click on control 503, then Return at the release |
| d-birth-key | Return on the box, X in Birth after the world | Return, X (the core's Birth skip) |
| d-cancel-frames | N in the pan, the profile chord, X on the Windows profile before the release (case 12) | N, X (no S, Return) |

### The host-input run of 7.7 (`tests/harness/ext_timeline.py`, C.15.3 row 5)

Run `hostkey` (12,000 ms, `--graphics dos --host-input --core-input-log 1`): X at 1 s, Down at 3.3 s, Up at
3.5 s and Return at 3.7 s. Checked: the key is decided by the filter and ends DOS loop A at its first key test
after the decision, before the core's skip probe (view action source 2), with the box 146 frames later; the
core receives the key as its skip (T5); the box comes before the core's title MenuZ and Down/Up move its own
row (T4); Return starts a pending translation released at the core's ready MenuZ (S and Return posted there,
I4); the core chooses item 0 and starts Birth; adapt.log's counters.

### Tests (`tests/test_pdos_pend.c`, `tests/test_input.c`)

* `test_pdos_pend` (new). Part A, synthetic (a state source, the core's MenuZ items and the points are the
  test's): the refused starts; the release one step per sync with the start's sync fresh; every predicate of
  C.13.3; the lost states; the limit at its boundary (exactly 10 s waits, 1 us more cancels even with the
  predicate holding) and from each re-arming; unresolvable and overflowing steps; no room; the cancellation by
  a user action on frames 0 (key press, character), 1, 2, 3 and 4 through `pdos_adapt_filter` and
  `pdos_adapt_note`, not by a repeat, a release or a move; I1 (30 s of syncs without a user action produce
  nothing; a translation starts only in the filter's decision, with the action's ordinal); C.13.6 examples 4
  (setup) and 6 (stack) on synthetic states. Part B, the real sequencer driven by synthetic probes (the DOS
  store read at run time): C.13.6 examples 1, 2, 3 and 5; C.15.4 case 12; the limit with the core never
  reaching its title; the DOS generator never called.
* `test_input`: the default release gives a waiting step at the sync after its start (frame 0), nothing
  after it, and a frame-0 key press through the filter stage cancels it.

## Tests

Counts from the final cycle's logs (`build/d4c2-<n>-<step>.log`).

| Test | Checked | CheckedNoObs | Release | Change |
| --- | --- | --- | --- | --- |
| `test_pdos_pend` (new) | 102 | 102 | 102 | new |
| `test_input` | 230 | 203 | 230 | +3 Checked (the default-release block needs the observer; 227/203 before) |
| `test_pdos_adapt`, `test_pdos_mouse`, `test_pdos_seq`, `test_timeline` | 48, 33, 114, 148 | 48, 20, 114, 148 | 48, 33, 114, 148 | unchanged (D4c1's rows now queue through `pdos_pend`; their expectations unchanged) |
| test programs | 40 | 40 | 40 | +1 (`test_pdos_pend`; 39 before) |
| `ext_adapt.py` | EXT_ADAPT_OK checks 56 | not run (Checked only) | not run | +36 (13 D4c2 pairs; 20 before) |
| `ext_timeline.py` | EXT_TIMELINE_OK, 37 checks | not run | not run | +8 (run `hostkey`) |
| `obs_lint.py` | OBS_LINT_OK files 86 probes 203 callsites 98 | the same | the same | files +2 (`pdos_pend.c/.h`; 84 before) |
| `ext_p0.py` | P0_OK checks 279 | P0_OK checks 56 | not run (Checked sections) | unchanged |
| `ext_g1.py check` | EXT_G1_OK runs 77 (amended 1) | EXT_G1_OK runs 77 (amended 1) | (step 3 and 6 only) | unchanged |

Every other marker of `test.cmd` is unchanged in kind: REGISTRY_OK, NODOS_OK, GATE3B_OK, UNINIT_OK,
P4_SCENARIOS_OK, P4_TESTS_OK, OBS_TABLES_OK probes 203 sites 98, ADAPT_OK rows 36 steps 12, EXT_FRAMES_OK,
EXT_CONTINUE_OK, MIRROR_OK runs 29, ZOOM_OK combinations 32 runs 64 samples 388, TRACE_OK (Checked; the
CheckedNoObs and Release sections as `test.cmd` selects them).

## Results

* **Cycle.** As in the gate record: 1 BUILD_OK Checked (kept), 2 TESTS_OK Checked, 3 EXT_G1_OK runs 77, 4 BUILD_OK
  CheckedNoObs, 5 TESTS_OK CheckedNoObs, 6 EXT_G1_OK runs 77, 7 BUILD_OK Release, 8 TESTS_OK Release; the CY
  digests `build/cy-equiv/seq-checked.json`, `seq-noobs.json`, `seq-release.json`.
* **The 13 pairs** (`build/test/Checked/ext-adapt.txt`): each DOS-form run's decisions as listed in `D_CASES`,
  each equal to its Windows-form pair (coreinput 0..8 messages, frames 163..581). Pending translations: one
  start and one release each in d-pan-n-intro (released 1.86875 s after the N), d-pan-n-early (3.6225 s),
  d-box-t4 (0.4225 s) and d-title-mouse (0.003 s; the queued step's item 3); one start cancelled by the user's
  X in d-cancel-frames; no refusal, timeout, lost state or overflow in any run. Checkpoints reached as listed;
  d-title-quit ends with the result EXIT in both forms.
* **hostkey** (`build/test/Checked/ext-timeline.txt`): the key decided at 1.0 s ends loop A at frame 73, the box
  at frame 219 (3.124684 s) before the core's title MenuZ (4.1205 s); Down and Up consumed and the box's own row
  1 and back to 0; Return released at sync 82147, 4.1225 s (S and Return posted); the core chooses item 0 at
  4.1245 s and starts Birth; adapt.log end: starts 1 releases 1 done 1 cancel_timeout 0.
* **Before the slot** (private mirror, not the gate): the same tests and harness scripts passed on the tree with
  both stages laid over it (Checked and CheckedNoObs builds, the language checks, ext_timeline, ext_p0,
  ext_frames, the 13 pairs).

## The recorded limit (C.13.4, P22)

`PDOS_PEND_LIMIT_US` = 10,000,000 us of virtual time per step (under `--timing host` virtual time is real time).
On the model the longest waits in the 7.8 runs are the title waits after an early skip: N at 0.5 s is released
at the core's title MenuZ about 3.6 s later (d-pan-n-early), N at 5 s about 1.9 s later (d-pan-n-intro), Return
at 3.7 s on the T4 box 0.42 s later (d-box-t4, hostkey); a release on MZ_SEL follows its click by one key poll
(3 ms, d-title-mouse). The limit is P22 as settled in D1 (DESIGN.md 12.8; its frame count corrected by C.20-5,
ext-D1-acceptance.md); every wait is far inside it, and a timeout only cancels (test_pdos_pend's `a_timeout`,
`b_timeout`).

## I1 conformance (C.13.5)

* Every produced event is a key with its character, or a move and a left press and release at a device point of
  the core's own windows (`pdos_adapt_resolve`), at frame 0: the kinds a user produces on the Windows profile
  (test_pdos_pend's `user_kinds`; the 7.8 pairs show the same messages through the Windows profile's own path).
* A translation exists only because of one user action: `pdos_pend_start` is called only from the filter's
  decision of that action (`run_steps`), which records the action's ordinal; nothing time-driven starts or
  releases one (the release reads only the core's state); the limit only cancels. The lint keeps HOST_EV_ out of
  `pdos_pend.c` (D4c1's I1 rule: the module never names an event type).
* D4b4's Birth auto-continue stays the one recorded exception; `pdos_pend_release` calls it unchanged.

## Deviations

Format: section; what; why.

1. **C.13.1 (structures).** The queue keeps D4c1's symbolic `PdosStep`s (a predicate and acts) instead of
   `PdosPendStep`'s events; a step's events are made at its release by `pdos_adapt_resolve`. Why: C.12.6 reads a
   control's point and an item's letter at the release instant (D4c1's interface).
2. **C.13.2 (one step per sync).** A translation started at a sync releases nothing more at that sync, even
   when its first step waits. Why: the filter's own release is that sync's step, and a waiting first step cannot
   hold there (the row was chosen on the same core state).
3. **C.13.3 (predicates).** DLG_OPEN, EDIT_FOCUS, CURSOR and STACK_WOKEN are implemented over `PdosPendState`
   but D4's state source (the sequencer) cannot tell them, so a start with one is refused (no D4 row uses them).
   Why: their state (the dialogs, the focus, the cursor, the stack wake) is D5..D7's.
4. **C.13.4 (state lost).** Defined for MZ_READY (by the core's scene) and MZ_SEL (MenuZ's exit); a step that
   cannot be resolved at its release is cancelled as a lost state too. The other predicates rely on the limit
   until D5..D7.
5. **C.13.4 (the structure's bounds).** Steps and acts are refused at the start; a step's events are known only
   at its release, so more than eight cancels then (`PDOS_PC_OVERFLOW`) instead of consuming the action at its
   press. Unreachable with the table (`adapters.py`: at most 4 acts and 8 events a step).
6. **New diagnostic.** `pend_cancel` counts cancellations other than by a user action (not in C.13). Why: a
   timeout or lost state is worth seeing in runs; a user action's cancellation is ordinary.
7. **C.15.3 row 5 (the host-input run).** The DOS key is at 1 s, not 5 s: on the model a key at 5 s ends the
   DOS dissolve (box at 7.13 s) after the core's title MenuZ is entered (6.87 s), so T4 would not be shown; at
   1 s the box comes at 3.12 s and the core's MenuZ at 4.12 s.
8. **C.15.4 (cases).** Case 6 follows D4c1 Deviation 1 (hotkeys select only): the box's e or q gives the core
   item's letter (P, Q) and a Return is pressed in both forms. Cases 9 and 10 (setup, Customize) are D5's; case
   11 is ext_adapt's existing chord run; case 13 needs a DOS menu box over the map (D6, D7). Added: d-pan-n-early
   (the limit's margin), d-box-t4 (example 3), d-title-quit.
9. **C.15.4 (checkpoints).** MenuZ's return 11E0:0729 and DestroySequencePlayer's 11E0:01E8 are not statement
   sites of the translated core (core listing: `seg061_11E0.c`), so a checkpoint there never fires; the pairs
   use the next statements, 11E0:0735 (after the choice is stored) and 11E0:01F7 (after the Birth end's sound).
10. **Files beyond the brief's list.** `tests/headless/harness.c` (adapt.log; C.15.4 requires the release
    lines with their sync ordinals); `present/dos/pdos_common.h` and `pdos_assets.c` (the diagnostic).

## What D5..D7 must know

* **State for the other predicates.** Extend the default state source (`def_state` in `pdos_pend.c`, from
  `pdos_seq_core`) with the dialog open and enabled, the EDIT focus, the core's cursor and the stack wake, set
  their `known` bits, and give each a lost-state rule in `pdos_pend_lost`; until then a row using one is
  refused at its start (`PDOS_DIAG_PEND`).
* **MZ_READY(setup, step)** compares `setup_step` (arg2); D5 must keep `PdosCore.setup_step` current.
* **The T4 "Birth skip + choice"** (D4b3, D4b4): its first step passes the user's key (the core's skip, noted
  by input.c), so D4b4's auto-continue adds no second skip; its MZ_READY(setup 0) step is cancelled if the core
  is not at Birth or the setup.
* **7.8 pairs.** `ext_adapt.py`'s `D_CASES` takes a case as a DOS-form script, a Windows-form builder (from the
  DOS run's adapt.log and coreinput.log) and the expected rows and counts; add D5's cases 9 and 10 there.

## For the records

For the docs agent; nothing below was edited by this unit (the gate record lists the D4 phase's own entries).

* **DESIGN.md 12.5** (area A, the filter-stage paragraph): replace "D4b4's `pdos_seq_autocontinue_release`" by
  "D4c2's `pdos_pend_release` (I4's pending translations; it then calls D4b4's
  `pdos_seq_autocontinue_release` with the room left)" and add "`input.c` also checks at compile time that
  PDOS_PEND_EVENTS + 2 <= PI_MAX_OUT (a released step and the auto-continue's press and release in one
  sync)." In the D4b4 paragraph's first bullet ("The filter stage's default pending release") replace the last
  sentence by "Since D4c2 `pdos_pend_release` takes that place and calls it once per call, after its own step."
* **DESIGN.md 12.8** (area C): in "As implemented (D4b)" "Left", drop the D4c2 sentence (done, "Added in D4c2"
  below). Add after "Added in D4c1": "**Added in D4c2 (area C).** Record [ext-D4c2-record.md](ext-D4c2-record.md)
  (2026-10-15): `pdos_pend` (I4, C.13): one translation at a time as D4c1's symbolic steps, refused at its start
  beyond 6 steps or 4 acts a step, with a produced act other than a key or click, or with a predicate the state
  source cannot tell (DLG_OPEN, EDIT_FOCUS, CURSOR, STACK_WOKEN until D5..D7); released one step per
  input-taking sync (none at the start's own sync) when its predicate holds on the sequencer's core state
  (MZ_READY, MZ_SEL), resolved by `pdos_adapt_resolve` at that instant; cancelled by another user action, a
  lost state (the title's MenuZ outside BOOT/INTRO/TITLE, the setup's outside BIRTH/SETUP, MZ_SEL after its
  MenuZ exits), 10,000,000 µs of virtual time in one step (P22) or more than 8 events, never producing input;
  diagnostic `pend_cancel`. `pdos_pend_release` is `PiDispatch.pend_release`'s default and calls D4b4's
  auto-continue. Tests: `test_pdos_pend` (102 checks: every predicate, the lost states, the limit at its
  boundary, cancellation on frames 0..4, I1, C.13.6 examples 1..6), `test_input`'s default-release block,
  `ext_adapt.py`'s 13 DOS-form/Windows-form pairs (C.15.4, equal `coreinput.log`, frames, checkpoints and
  events) and `ext_timeline.py`'s host-input run `hostkey` (T5, T4, I4 on the model); the harness's
  `adapt.log` in 7.8 runs with the DOS profile registered. Compiled and headless in Checked, CheckedNoObs and
  Release at the D4 gate (eight-step cycle ALL_GREEN, `build/d4c2-status.txt`); no DOS program executed; Asan
  not run." In 12.8's I4 text (around "10,000,000 µs of virtual time in one step (P22)") add "(as built in
  D4c2: `pdos_pend`; deviations in its record: symbolic steps, one step per sync including the start's sync, the
  D5..D7 predicates refused, overflow at the release)".
* **DESIGN.md 12.10**: after the D4b4 sentence add "D4c2 (the pending translations) added no w16 change: its
  released steps take the same `present_input_release` path." In "Outside w16", add the harness's `adapt.log`
  to "the logs and the 7.8 mode".
* **FIDELITY.md**:
  * F156: replace the status clause "the title box's click and the T4 translations need D4c2's queue: until
    then an action whose translation needs a queued step is consumed whole (`PDOS_DIAG_PEND`; record Deviation
    4)" by "the queued steps (the box's click, the T4 choice, the shortcut while the core is in its intro) act
    since D4c2 (`pdos_pend`, F158)"; user checks D4-27 and D4-28 checkable (no longer "after D4c2").
  * A new row F158 "the pending translations (`present/dos/pdos_pend.c`; I4, C.13)": "With the DOS profile
    visible, a DOS-form action whose Windows-form translation needs a core state that has not come yet (the
    title box's Return or click before the game's title menu is ready; N, L, E, C in the DOS pan while the
    core is still in its intro) keeps its remaining steps and posts each at the first input-taking sync where
    the core state holds (its title MenuZ ready, the selection made): the same Windows-form events a player
    would press at that moment. Another user action, a lost scene, 10 s of virtual time in one step (P22) or an
    overflow cancels without input. Status: implemented in D4c2; the 7.8 pairs show each DOS-form run equal to
    its Windows-form pair (coreinput.log, frames, checkpoints, events). Label: **choice** (I4 is the
    extension's design; DOS reads its own keys at its own tests, `pdos_seq`), the waits on the model **DOS
    listing (model)**. Refs: I1, I4; C C.13; `ext-D4c2-record.md`."
* **RUNNING.md**:
  * The unit-test table: a new row `test_pdos_pend` (since D4c2): "the pending translations on synthetic
    states (refusals, release one step per sync, every predicate, lost states, the 10 s limit, resolve,
    overflow, room, cancellation on frames 0..4, I1, C.13.6 examples 4 and 6) and with the real sequencer
    (examples 1, 2, 3, 5, case 12, the limit) on the DOS copy `<gamedata>\..\dosdata`"; counts as in
    "Tests"/"Results" above. `test_input`'s counts as there; the test-program count gains one (40 in Checked
    since D4c2).
  * `ext_adapt.py`'s row: D4c2's 13 DOS-form/Windows-form pairs (26 runs in parallel under
    `build/harness/Checked/adapt/`), EXT_ADAPT_OK checks as in "Results"; `ext_timeline.py`'s row: the
    host-input run `hostkey`.
  * The 7.8 mode: with the DOS profile registered the harness also writes `adapt.log` (decide, start,
    release, done, cancel, refuse, event and end lines with the virtual time and the sync ordinal).
  * presentation-diag.log: the diagnostic `pend_cancel` (a pending translation cancelled by the limit, a lost
    state or an overflow).
* **STATUS.md**: D4c2 done (this record; the D4 gate's eight-step cycle ALL_GREEN, `build/d4c2-status.txt`);
  test counts as in "Results"; the D4 phase entries in the gate record.
* **DOS-PROFILE.md**: no change needed (1.7.2's rows are unchanged; their queued steps act since D4c2). Optional:
  0.3's adapter note "steps marked with a predicate wait in `pdos_pend` (D4c2)".
* **manual-checklist-ext.md**: D4-27 and D4-28 are checkable now (note 5: "with D4c2" instead of "after D4c2";
  the count's "of which D4-27 and D4-28 after D4c2" goes). New pending item: "With the DOS profile visible,
  press a key early in the DOS intro (in its first seconds): the DOS title box appears before the game's own
  title menu is ready; press Return on it at once: the game takes the highlighted item once its menu is ready
  (the choice is not lost)." (T4 and I4; F156, F158.)

## Review fixes (D4cF)

The review [verify/ext-d4c-review.md](verify/ext-d4c-review.md) R1, R4 and R6 touch the pending translations; the
rules, their listing addresses and the vectors are in [ext-D4c1-record.md](ext-D4c1-record.md) "Review fixes
(D4cF)", with the user's direction on D4-3. The text above is the record of D4c2 as built and stays; these are its
corrections (R7 for D4c2's parts).

* "Predicates": MZ_SEL(k) now also needs four key polls since the step was armed (`PDOS_PEND_SEL_POLLS`;
  `PdosPendState.mz_polls` with the `known` bit `PDOS_PK_POLLS`, from `PdosCore.mz_polls`, counted at each key
  poll of an active MenuZ); a state source without the count keeps the selection-only rule (R4).
* "Release": the order is now its scene lost, the limit, the predicate (with MZ_SEL's polls), the resolution, the
  overflow, then a held-press wait (R6: a step whose events press a key the core holds down from the user's own
  press waits for the user's release; `pdos_adapt_held_press`, so HOST_EV_ stays out of `pdos_pend.c`), then the
  room. The limit still counts while it waits. Each release re-arms the poll count with the time.
* "Cancellation": a cancellation now also calls `pdos_seq_pend_cancelled` (R1): when the core has made no title
  choice the DOS view's preselection is void (the title box at once from HOLD, or at the hand-over). It still
  produces no input. A Ctrl, Shift, Alt, Caps Lock, Num Lock or Scroll Lock press on the N canvas is no longer a
  cancelling user action (D4-3: it is no DOS key).
* "The recorded limit": "a release on MZ_SEL follows its click by one key poll" becomes "by at least four key
  polls" (R4).
* "Results", the 13 pairs: d-title-mouse's release 0.003 s after the click is D4c2's value; with R4 the Return
  comes at the fourth key poll after the click, so the wait grows (the cycle: 0.004 s). The pair's Windows form is
  built from the DOS run's own release sync, so it stays equal and EXT_ADAPT_OK is expected unchanged.
  d-cancel-frames: the hidden DOS view now shows the box at its hand-over instead of the hold (not compared).
  hostkey: unchanged (MZ_READY; the user's Return is released at 3.75 s, before the release at 4.1225 s). No pair,
  ext_timeline run or golden uses a lone Ctrl, Shift, Alt or lock key with the DOS profile visible (the chords'
  Ctrl, Shift and Alt are served by the arrival stage and never reach the filter).
* "Tests": `test_pdos_pend`'s example 5 polls three times (still waiting) before the fourth releases Return (104
  checks, 102 before).
* "I1 conformance (C.13.5)": unchanged; the new waits read only the filter's own pairing table and the core
  state's poll count, and a cancellation still produces nothing.
* Files of D4c2 changed by D4cF: `present/dos/pdos_pend.h/.c`, `tests/test_pdos_pend.c`, `present/input.c` (the
  compile-time check of R5's mark), this record.
* For the records: FIDELITY F158: MZ_SEL's four key polls (R4), the cancellation's voided preselection (R1), the
  held-key wait (R6). ext-D4-acceptance.md (the gate record) may note that D4cF changed these rules after the
  gate.
* Cycle: D4cF's three steps are ALL_GREEN (`build/d4cf-status.txt`, 22:14:19 UTC): `test_pdos_pend` 104,
  EXT_ADAPT_OK 56 with d-title-mouse released 0.004 s after the click and the other three releases unchanged,
  hostkey unchanged, EXT_G1_OK runs 77; details in ext-D4c1-record.md "Review fixes (D4cF)", "Results".

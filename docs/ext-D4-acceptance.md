# Extension phase D4 (credits, intro, title menu, Birth, the DOS pointer) — acceptance record

Prompt: `claude/docs/x64-port-scaling-dos-prompt.md`, phase D4 (section 9): "Credits, intro, title menu, Birth
with colour cycling, the DOS pointer; T-rules and adapters." Gate: "7.7 and 7.8 for these scenes; DOS-oracle
comparisons if granted." The DOS-oracle comparisons of 7.9 are granted as optional (extension 2.1) and are
**not run in D4** (optional; see STATUS): D4's timing and pixel claims are labelled "DOS listing (model)".
Under the user's direction of 2026-10-10 21:20 Asan runs are deferred to the end of the queue, so the gate is
met in Checked, CheckedNoObs and Release with the Asan run recorded as deferred. Under the user's direction of
2026-10-15 about 14:09 a phase gate runs the full eight-step cycle. Brief: [verify/BRIEF-d4.md](verify/BRIEF-d4.md).
Design: DESIGN.md 12.6..12.11, [verify/ext-d1-draft-B.md](verify/ext-d1-draft-B.md) and
[verify/ext-d1-draft-C.md](verify/ext-d1-draft-C.md) (Revision 3) with
[verify/ext-d1-decisions.md](verify/ext-d1-decisions.md).

D4 was done in nine sequential units, each with its own record:

* **D4a, the DOS machine and composition (area B's base):** [ext-D4a-record.md](ext-D4a-record.md) (`pdos_mach`,
  `pdos_draw`, `pdos_glyph`, `pdos_pal` with fades and cycling, `pdos_compose`, `pdos_shadow`, `pdos_scene`,
  `pdos_fontmap`, `pdos_cursor`, `pdos_rand`; the N and A frames).
* **D4b1, the clock and the timeline engine:** [ext-D4b1-record.md](ext-D4b1-record.md) (`pdos_clock`,
  `pdos_tl`, M1..M12, `test_timeline`).
* **D4b2a, the intro, credits and logo program:** [ext-D4b2a-record.md](ext-D4b2a-record.md) (`pdos_intro`).
* **D4b2b1, the sequencer and its wiring:** [ext-D4b2b1-record.md](ext-D4b2b1-record.md) (`pdos_seq`, the probe
  rows, `timeline.log`, the first `ext_timeline.py`).
* **D4b2b2, the title box, the menu-box model, the pointer rule:** [ext-D4b2b2-record.md](ext-D4b2b2-record.md)
  (C.7, B 4.4, C.11.5, S6, S7, S9, the model goldens).
* **D4b3, Birth:** [ext-D4b3-record.md](ext-D4b3-record.md) (`pdos_birth`, C.8.3's transcription of
  O7:17CF..1BB8, the post-Birth transition, F2's logical-text part, the Birth goldens).
* **D4b4, the Birth auto-continue (the user's direction of 2026-10-15):** [ext-D4b4-record.md](ext-D4b4-record.md)
  (the one I1/T3 exception, `ext_continue.py`).
* **D4c1, the filter stage, adapters and mouse conversion:** [ext-D4c1-record.md](ext-D4c1-record.md)
  (`pdos_adapt`, `pdos_adapt_tab.c` rows I-intro, I-title, I-birth, `pdos_mouse`, `gen/dos/adapters.py`, the
  area-C lint rules).
* **D4c2, the pending translations, the 7.8 DOS-form scripts and this gate:**
  [ext-D4c2-record.md](ext-D4c2-record.md) (`pdos_pend`, adapt.log, `ext_adapt.py`'s DOS-form pairs,
  `ext_timeline.py`'s host-input run).

Labels: **compiled** (the three language checks and `/W4 /WX`), **headless** (test programs and the harness on
`build/gamedata`, the DOS copy `build/dosdata` read at run time), **Win32-headless** (the Win32 back end with a
hidden window), **DOS listing (model)** (timings and pixels of area C's model of the DOS program; no DOS
oracle), **agent-observed** (a visible civ64 window looked at by an agent; none in D4), **DOS-oracle-compared**
(not run in D4), **user-confirmed** (the user's acceptances in STATUS "User directions" and
`manual-checklist-ext.md`), **unverified**. No DOS program was executed; nothing was written to
`C:\Projects\Civ1RE\dos` or `build/dosdata`.

## Gate

The prompt's gate for D4 is 7.7 (timelines: presented-frame hashes at listed virtual times, durations in ticks
equal to the listing's, the skip, switch and T-rules) and 7.8 (DOS-form scripts give the same core input and
checkpoints as the equivalent Windows-form scripts; I7's chords in that mode) for credits, intro, title menu,
Birth with colour cycling and the DOS pointer. Every row below ran in the final cycle's `test.cmd checked`
(step 2; `build/d4c2-2-test-checked.log`) unless it says otherwise; the markers are that run's.

| Gate item | Scenes | Method | Evidence (unit) | Result |
| --- | --- | --- | --- | --- |
| 7.7 presented-frame hashes at listed virtual times | credits, intro pan, logo | headless; DOS listing (model) | `ext_timeline.py` run `start` (75 s, `--dos-watch`): the six C-9 intro goldens and the gap frames of `ext-timeline-golden.txt` (D4b2a, D4b2b1) | pass: EXT_TIMELINE_OK; `start` 5: the six goldens (k = 54, 1952, 4040, 4120, 4620, 4766) equal; `start` 3: 679 of 679 samples before the hand-over show the DOS intro |
| 7.7 presented-frame hashes | Birth with colour cycling | headless; DOS listing (model) | run `birth` (205 s): the eight Birth goldens (`bgolden`, the cycled palette in the frames) (D4b3) | pass: `birth` 4: the eight Birth goldens (k = 20, 69, 117, 1500, 4000, 7000, 10000, 12000) equal |
| 7.7 presented frames | the title box | headless; DOS listing (model) | run `start`'s title-box checks (the box after the dissolve, its golden with the box); `test_pdos_seq` (the rows, the highlight following the core, the box staying and redrawn; `test_watch`) (D4b2b2) | pass: `start` 4: the box at the hand-over (frame 4766, 68.000007 s after t0), row 0; `test_pdos_seq` 114 checks |
| 7.7 durations in ticks equal to the listing's | intro, logo, dissolve, Birth | headless; DOS listing (model) | `test_timeline` (M1..M12, C.15.1 items 1..4, 6..8: the intro program's and the Birth schedule's tick counts), `test_pdos_seq` (D4b1, D4b2a, D4b3) | pass: `start` 2 (the intro's steps on C.6.3's frames: lines, clears, loops A and B, strips, dissolve), `birth` 2 (53 events, each at its due tick); `test_timeline` 148, `test_pdos_seq` 114 checks |
| 7.7 skip | intro, Birth | headless | runs `key` (T5: a key ends both intros), `birth_skip` (a key ends both Births), `hostkey` (the key through the host-input filter); `ext_continue.py` (D4b4's auto-continue, the one I1/T3 exception) | pass: `key` (the DOS reaction at the core's skip probe: loop A ends at frame 716, the box at 862), `birth_skip` (C.8.8), `hostkey` (T5); EXT_CONTINUE_OK (20 checks) |
| 7.7 switch (T2) | intro, Birth | headless | runs `switch`, `birth_switch` (`--switch-every 997`: each profile at its own instant, neither restarts); `ext_frames.py`'s switch assertions | pass: `switch` (749 DOS samples equal the DOS-all-along run's; 75 switches, 0 refused; the core outputs equal), `birth_switch` (2049 samples equal); `ext_frames.py`'s switch assertions (start, s3, birth) |
| 7.7 T-rules | T4, T5, T6 | headless | run `hostkey` (T4: the DOS box before the core's title MenuZ, its own rows; T5; I4's release at the ready MenuZ), run `burn` (T6), `test_pdos_seq` (T4's held next screen at Birth's end) | pass: `hostkey` T4 (the box at 3.124684 s before the core's title MenuZ at 4.1205 s; Down and Up move the box's own row) and I4 (released at the ready MenuZ, 4.1225 s); `burn` T6 (the gap logged once, the timeline catches up exactly); `birth` 3 (T4 at the story's end, C.8.7) |
| the DOS pointer (C.11.5) | intro, title, Birth | headless; user-confirmed (D4-19) | `test_pdos_seq` (the pointer rule `pdos_seq_pointer_hidden`: hidden while the DOS intro or Birth runs; D4b2b2, D4b3) and `test_pdos_cursor` (the DOS pointer itself, D4a); D4-14 pending | pass: `test_pdos_seq` 114, `test_pdos_cursor` 62 checks; D4-19 user-confirmed, D4-14 pending |
| 7.4 frame determinism of the DOS frames | intro, title, Birth | headless | `ext_frames.py` (the s3 and birth runs A, A', B, C; presented.log of A equals A'; the dump check) | pass: EXT_FRAMES_OK (start, s3, birth: the sample lines of A, A', B, C identical; presented.log of A equals A'; the dump check, 496 tick frames) |
| 7.8 DOS-form equals Windows-form | intro, title box, Birth | headless | `ext_adapt.py`'s 13 D4c2 pairs: each DOS-form run's `coreinput.log`, run.log frames, snapshots/result and events.log equal its Windows-form pair's; checkpoints title-choice, after-worldgen, birth-end (or the result EXIT) reached in both | pass: EXT_ADAPT_OK checks 56; all 13 pairs equal; the four waiting releases 0.003 s, 0.4225 s, 1.86875 s and 3.6225 s after their actions (limit 10 s); no refusal, timeout, lost state or overflow |
| 7.8 I7's chords in the mode | S3 in host form | headless | `ext_adapt.py`'s chord pair (D3) and M's zoom, wheel, ring and in-view click runs | pass: the chord run equals the plain run (coreinput 38, frames 764, snapshots/result 13, events 94); M's zoomkeys and ring runs |
| the filter stage, adapters, I4, I5 | rows I-intro, I-title, I-birth | headless | `test_input`, `test_pdos_adapt`, `test_pdos_mouse` (D4c1), `test_pdos_pend` (D4c2), `adapters.py check` | pass: `test_input` 230, `test_pdos_adapt` 48, `test_pdos_mouse` 33, `test_pdos_pend` 102 checks (CheckedNoObs 203, 48, 20, 102; Release 230, 48, 33, 102); ADAPT_OK rows 36 steps 12 |
| P0 and I1 (input only from user actions, D4b4's recorded exception) | all D4 scenes | headless | `ext_p0.py` (every scenario with the DOS profile and switching: the core's frames, state and events unchanged), `ext_g1.py` G-1, obs_lint's I1 rule, NODOS | pass: P0_OK checks 279 (CheckedNoObs 56); EXT_G1_OK runs 77 (amended 1) in Checked and CheckedNoObs; OBS_LINT_OK files 86; NODOS_OK in all three variants |
| 7.9 DOS-oracle comparisons | - | not run in D4 (optional; see STATUS) | - | not run |
| agent UI check | - | none in D4 (optional) | - | not done |
| user checks | intro and switching, title box, Birth, auto-continue | user-confirmed | `manual-checklist-ext.md` D4 (below) | 17 passed; the rest pending |

Verdict: **the D4 gate is met**: 7.7 and 7.8 for credits, intro, title menu, Birth with colour cycling and the DOS pointer pass headless (the DOS timings and pixels as **DOS listing (model)**) in Checked, CheckedNoObs and Release, with G-1 and P0 unchanged. Not part of the verdict: the DOS-oracle comparisons (not run in D4, optional), the agent UI check (none), Asan (deferred), the pending user checks and the items under "Not verified".

## The final cycle

The D4 phase gate ran the full eight-step cycle (the user's cycle rule of about 14:09 UTC: a phase gate runs
all eight steps). Status `build/d4c2-status.txt` (ends ALL_GREEN), logs `build/d4c2-<n>-<step>.log`:

| Step | Command | Exit | Seconds | UTC | Last line |
| --- | --- | --- | --- | --- | --- |
| 1 | `build.cmd checked` | 0 | 284 | 17:40:32..17:45:16 | BUILD_OK variant=Checked |
| 2 | `test.cmd checked` | 0 | 2279 | 17:55:31..18:33:30 | TESTS_OK variant=Checked |
| 3 | `ext_g1.py check` | 0 | 0 | 18:34:03..18:34:04 | EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) |
| 4 | `build.cmd checked noobs` | 0 | 254 | 18:34:04..18:38:18 | BUILD_OK variant=CheckedNoObs |
| 5 | `test.cmd checked noobs` | 0 | 906 | 18:38:19..18:53:25 | TESTS_OK variant=CheckedNoObs |
| 6 | `ext_g1.py check --variant CheckedNoObs` | 0 | 0 | 18:53:37 | EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) |
| 7 | `build.cmd` | 0 | 212 | 18:53:37..18:57:09 | BUILD_OK variant=Release |
| 8 | `test.cmd` | 0 | 517 | 18:57:09..19:05:46 | TESTS_OK variant=Release |

* **The interruption.** The session ended during step 2's first run (started 17:45:16 UTC, stopped in
  `[D2: nodos.py check --variant Checked]` about 17:46..17:51 UTC). By the coordinator's instruction of 17:54
  UTC step 1 was kept: its binaries were current (no source or test-input file changed after 17:40:38 UTC; the
  only newer files were build.cmd's own generated tables written at 17:40:38 inside step 1, and D4c2's record).
  The interrupted log is `build/d4c2-2-test-checked-interrupted.log`; the status file says "1-build-checked
  kept" and "2-test-checked interrupted (session ended), rerun". Steps 2..8 ran again as a detached process.
* **Markers.** Checked: REGISTRY_OK, NODOS_OK, GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK, P4_TESTS_OK,
  OBS_TABLES_OK probes 203 sites 98, OBS_LINT_OK files 86 probes 203 callsites 98, ADAPT_OK rows 36 steps 12,
  P0_OK checks 279, EXT_FRAMES_OK, EXT_TIMELINE_OK, EXT_CONTINUE_OK, EXT_ADAPT_OK checks 56, MIRROR_OK runs 29,
  ZOOM_OK combinations 32 runs 64 samples 388, TRACE_OK; 40 test programs, 0 failures. CheckedNoObs: the same
  through ADAPT_OK, P0_OK checks 56, EXT_CONTINUE_OK, TRACE_OK; 40 test programs. Release: REGISTRY_OK,
  NODOS_OK, OBS_TABLES_OK, OBS_LINT_OK, ADAPT_OK, TRACE_OK; 40 test programs.
* **Deferred variants covered.** This cycle is also the CheckedNoObs and Release cycle that P47b
  ([p47b-record.md](p47b-record.md), three-step cycle `build/p47b-status.txt`) and D4c1 (three-step cycle
  `build/d4c1-status.txt`) deferred to the D4 gate: their code is in these builds and passed steps 4..8.
* **Unit CY's sequential baseline** (orchestrator decision 16:20 UTC): before each `test.cmd` step its start
  time was taken as epoch seconds and right after it `build/cy-tool/cy_equiv.py digest` wrote
  `build/cy-equiv/seq-checked.json` (Checked, start 1792086931.8312685, 27306 entries),
  `build/cy-equiv/seq-noobs.json` (CheckedNoObs, 1792089499.0078354, 9109 entries) and
  `build/cy-equiv/seq-release.json` (Release, 1792090629.8104494, 34 entries), each exit 0; the three epochs
  are in `build/cy-equiv/seq-starts.txt`. No variant was rebuilt after the cycle (CY replays the tests on these
  binaries).

## User-confirmed

`manual-checklist-ext.md` section D4 (the user's words are in STATUS "User directions"):

* **The DOS intro and switching** (D4-4..D4-7): passed 2026-10-12 about 11:35 UTC, the user: "I ran a copy of
  latest Checked build, tried intro dos graphics switching. Visual inspection passed and accepted."
* **The title box** (D4-8..D4-13): passed 2026-10-12 about 11:40 UTC, the user: "Title box is checked and
  accepted also." (for the box as a whole).
* **The DOS Birth** (D4-15, D4-18, D4-19): passed 2026-10-15 about 10:00 UTC, the user accepted the DOS Birth
  scenes on the Checked build of 09:22:45 UTC (with the black wait noted, which D4b4 answered).
* **The Birth auto-continue** (D4-21..D4-24): passed 2026-10-15 about 13:51 UTC, the user: "D4b4 passed visual
  and user interaction inspection."

## User checks left pending

`manual-checklist-ext.md` section D4: D4-1 (4:3 by default), D4-2 (a click ends the DOS intro, C.20-2), D4-3
(Ctrl or Shift alone skips), D4-14 (no pointer during the DOS intro), D4-16 (the black wait, changed by D4b4
while DOS is visible), D4-17 (a key during Birth ends both Births), D4-20 (Play on EARTH's story), the D4a
informational item, D4c1's D4-25 (a key in the DOS pan ends both intros) and D4-26 (the box's DOS keys; the
hotkeys only select), D4-27 (a click on a box row chooses it) and D4-28 (N, L, E, C in the DOS pan preselect,
taken once the game's menu is ready), both checkable since D4c2, and D4c2's new item (a Return on the box before
the game's menu is ready is taken once it is; D4c2 "For the records"). Not done in D4: the optional agent UI
check with a visible civ64 window.

## Deviations (summary)

Each record lists its deviations with section, what and why; in brief:

* **D4a** (10): probe keys as observer row numbers; scene-row fields and single-probe pops; page-constant names;
  configuration errors counted, not faulted; the shadow engine's injectable query; `pdos_cycle_setup`'s result;
  exit-orphan rule; the A machine's DAC at reset; ext_frames' dump check.
* **D4b1** (11): bound timelines; the fade's measured flag; up to 8 pending keys; added wait kinds; key tests at
  one microsecond; continuing at the finish instant; M10's zero-length dissolve; the log record's `arg`; the
  engine's runaway counter; a program's end; C.15.1 item 4's partitions.
* **D4b2a** (9): the transcription's start at O2:01CD; the VGA path only; the logo sprite's storage; the credit
  buffer as an index; key ties; finish in the pan; the generator counter; the partitions; the step names.
* **D4b2b1** (10): rows 1, 25 and 2 marked ready; the interim finish; only the intro's rows; counted
  configuration errors; the C.11.6 cases; the API; events run the timelines; `timeline.log` by default; the
  75 s `start`; the switch run's start.
* **D4b2b2** (11): the core's selection at IsKeyPending; hotkeys select only (decided in D4c1); the menu-box API;
  `framed`; the finish in the pan or logo; the steps' sequence; the view's own row; C.11.5 for the intro only;
  `burn`; the goldens through the watch; S9 by closing at registration.
* **D4b3** (11): the T4 next screen held; M12's calls as waits; the blink phase; EARTH's D76A; the post-Birth
  steps on a second timeline; the Birth view's rows; a closed stream; not modelled (EGA, the DOS generation's
  drawing, sound); C.11.6's Birth skip; F2's tracker; **S3 still open**.
* **D4b4** (6): delivery by the pending release; "at once" at the first tick after the DOS end; nothing after a
  player's own press; the `autocontinue` diagnostic; the option starts the 7.8 syncs; the include rule.
* **D4c1**: see its record (hotkeys select only; no wrap on Up/Down; frame 2 passes in D4; the I4 queue left to
  D4c2; `registry.py`'s observer files; the test files; class C's region; a 1:1 key's repeats; presses after the
  choice).
* **D4c2** (10): symbolic steps in the queue; one step per sync including the start's sync; D5..D7 predicates
  refused until their state exists; the lost-state rules; the overflow cancelled at release; the `pend_cancel`
  diagnostic; the host-input run's key at 1 s; C.15.4's case set; statement-site checkpoints; files beyond the
  list (harness.c's adapt.log).

**S3** (D4a second review: a macro with a drawing `leave`) stays open: no D4 unit registers such a macro
(D4b3 record, deviation 11); it is due with the first one (D5..D7).

## Asan

**Deferred** (the user's direction of 2026-10-10 21:20): no Asan build or run in any D4 unit. The Asan runs of the
DOS profile's tests and harness runs remain pending at the end of the queue.

## For the records

Gathered from the nine records for a docs agent:

| Unit | Its "For the records" | Applied |
| --- | --- | --- |
| D4a, D4b1, D4b2a, D4b2b1, D4b2b2 | their records | applied by earlier docs agents (STATUS session log) |
| D4b3 (with RV4 P47-R2) | [ext-D4b3-record.md](ext-D4b3-record.md) (it also gathered D4b's) | applied, docs E3a 2026-10-15 11:31 UTC |
| D4b4 | [ext-D4b4-record.md](ext-D4b4-record.md) | applied, docs E3b 13:48 UTC |
| D4c1 | [ext-D4c1-record.md](ext-D4c1-record.md) | applied, docs agent 17:39:17 UTC (`build/docs-d4c1-done.txt`) |
| D4c2 | [ext-D4c2-record.md](ext-D4c2-record.md) "For the records" (DESIGN 12.5, 12.8, 12.10; FIDELITY F156 and a new F158; RUNNING; STATUS; DOS-PROFILE (no change needed); manual-checklist-ext D4-27, D4-28 checkable and one new item) | **to apply** |

The D4 gate's own entries (to apply):

* **STATUS.md**: phase D4 **complete** (this record, 2026-10-15; the D4 row of the phase table and the
  "Current extension phase" paragraph): the gate's eight-step cycle ALL_GREEN (`build/d4c2-status.txt`,
  step 1 at 17:40:32 UTC kept, steps 2..8 17:55:31..19:05:46 UTC), which is also the CheckedNoObs and
  Release cycle of P47b and D4c1 (both deferred to this gate) and unit CY's sequential baseline (digests
  `build/cy-equiv/seq-checked.json`, `seq-noobs.json`, `seq-release.json`, start epochs
  `build/cy-equiv/seq-starts.txt`). "Last build and test results": a D4c2/D4-gate row with the markers of
  "The final cycle" above. The interruption (the session ended during step 2's first run, 17:46..17:51 UTC;
  the log kept as `build/d4c2-2-test-checked-interrupted.log`) goes into the session log. "Next concrete step":
  CY's replay on these binaries, then D5 as STATUS orders. User checks: D4-27, D4-28 and the new D4c2 item
  pending, with the earlier pending D4 items.
* **DESIGN.md 12.8**: the phase line "D4..D7" unchanged; in "As implemented (D4b)" "Left", D4 has nothing left
  (D4c2's sentence goes with its record's entry).
* **FIDELITY.md**: no gate entry beyond D4c2's (F158); the D4 rows keep their labels (**DOS listing (model)**
  for every DOS timing and pixel claim; DOS-oracle comparisons not run).
* **RUNNING.md**: nothing beyond D4c2's entries.
* **manual-checklist-ext.md**: no change beyond D4c2's entries; the D4 section's pending items stay pending.

## Not verified

* **DOS-oracle comparisons (7.9)**: not run in D4 (optional; see STATUS). Every DOS timing and pixel claim is
  "DOS listing (model)": the clock model (M1..M12), the intro's frames (C.6.3), the Birth schedule (C.8), the
  model goldens (6 intro frames, 8 Birth frames) pin the model's output, they do not prove it against DOS.
* **Agent UI check**: none in D4 (optional for D4c); the visible behaviour rests on the user's checks above.
* **Not modelled**: the EGA path, the DOS world generation's drawing, the sound and the tune's timing beyond the
  tick model, DOS's own input handling outside the adapter rows (D4b2a, D4b3).
* **The D5..D7 predicates** (DLG_OPEN, EDIT_FOCUS, CURSOR, STACK_WOKEN) and their lost-state rules: built and
  unit-tested on synthetic states only; no D4 row uses them.
* **S3** (above) and **F2's leader-face part** (D7).
* **User checks** left pending (above); the new D4c items are pending.
* **Asan**: deferred.

## After the gate (added 2026-10-15 about 22:30 UTC by the E3 orchestrator)

* The user tested the gate's Release build (`build/user-builds/d4/`) and passed P47-2, D4-2, D4-14, D4-16,
  D4-17, D4-20 and D4-25..D4-29 (about 19:40 UTC); D4-3 failed (about 19:30 UTC: a lone Ctrl or Shift must not
  skip the DOS sequences).
* Unit **D4cF** (`ext-D4c1-record.md` and `ext-D4c2-record.md`, sections "Review fixes (D4cF)") changed the D4
  input rules after this gate: the independent review's R1..R8 (`verify/ext-d4c-review.md`) and the user's D4-3
  direction (a lone Ctrl, Shift, Alt, Caps Lock, Num Lock or Scroll Lock does not skip with the DOS profile
  visible; F115). Its three-step cycle is ALL_GREEN (`build/d4cf-status.txt`, 22:14:19 UTC); CheckedNoObs and
  Release tests run at the next phase gate (BS). User build `build/user-builds/d4cf/` for D4-3 and D4-30..D4-32.

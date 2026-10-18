# Brief for the D4 implementers (extension phase D4: credits, intro, title, Birth, pointer)

> **Cycle rule changed 2026-10-15 about 14:09 UTC (the user's decision, STATUS "User directions"; `verify/BRIEF-cy.md`):** wherever this brief says "the eight-step cycle", a unit now ends with the **three-step cycle** (`build.cmd checked`, `test.cmd checked`, `ext_g1.py check`); the full eight-step cycle runs only at phase gates (D4, BS, D5, D6, D7, X9, WL and before the final Asan pass).

Written 2026-10-11 by the orchestrator. Phase D4 of the extension prompt
`claude/docs/x64-port-scaling-dos-prompt.md` (section 9): "Credits, intro, title menu, Birth with colour
cycling, the DOS pointer; T-rules and adapters." Gate: "7.7 and 7.8 for these scenes; DOS-oracle
comparisons if granted." Asan runs are deferred to the end of the queue (the user's direction of
2026-10-10 21:20).

D4 starts after the M gate (`ext-M-acceptance.md`). It is done in three sequential units, each by one
implementer with exclusive ownership of the files it changes: **D4a** (the DOS machine, drawing,
palette, composition, shadows, scenes, fonts: area B's base), **D4b** (the clock, timelines, intro,
title box, Birth, sequencing, the pointer: area C's timing with B's menu-box model) and **D4c** (the DOS
filter stage, adapters, I4, I5, the 7.8 runs, the gate). The DOS-oracle comparisons of 7.9 are granted
as optional (extension 2.1); the orchestrator runs them as a separate unit after D4c when the usage
budget allows, otherwise D4's timing and pixel claims are labelled "DOS listing (model)".

## Authority and design

* The design is DESIGN.md 12.6 (E, delivered), 12.7 (B), 12.8 (C), 12.10 (w16 changes; D4 adds none
  without recording why), 12.11 (P0), and the detailed designs `verify/ext-d1-draft-B.md` and
  `verify/ext-d1-draft-C.md` (Revision 3), with `verify/ext-d1-decisions.md`. A's side is D3's code
  (`ext-D3-acceptance.md` and the unit records it links); D's is M's (`ext-M-acceptance.md`). DESIGN 12.7
  tags some of B's files "D3": D3 delivered only the profile skeleton (it shows the Windows frame), so
  every B item tagged D3 or D4 that D3 did not deliver is D4a's. Check the D3 records first; do not redo
  what exists.
* Implement as written; where the code shows the design is wrong or incomplete, make the smallest
  correct fix and record it as a deviation (design section, what and why) in your record.
* DOS facts come only from `claude/port/docs/dos/*.md`, the listing in `claude/port/build/dos/disasm/`
  and the files in `claude/port/build/dosdata/` (read at run time through E's API; never copied into the
  repository). Never from memory. Cite the listing address (`R:ssss:oooo`, `O<n>:oooo`, `G:0000:oooo`,
  DGROUP) for every constant.
* The extension prompt (1 P0, 2.3, 4 D-2..D-5, 5.3..5.7, 5.9, 5.10, 7.7, 7.8, 8) and the base prompt
  `claude/docs/x64-port-prompt.md` sections 1, 5.0, 7 and 9 govern.
* The user's directions (STATUS.md "User directions") that touch D4: the start-up through setup screens
  stay 4:3 (X3); a click ends the DOS intro (C.20-2) and Birth's DOS setup page shown early (C.20-3) are
  listed for the user's check and stay pending.

## Rules

* **P0 above all.** The DOS profile reads only through `w16q_*`, writes only presentation memory, posts
  nothing except through the filter stage's documented translations (I1), and never reads
  `g_randSeed`. After every build: `test.cmd checked` (all base tests, gate3b references, scenarios,
  `ext_p0.py`, `ext_frames.py` and the M tests) and `ext_g1.py check` on Checked and CheckedNoObs stay
  green. A failure is fixed before anything else.
* **Builds are yours alone** during your unit (Checked, `checked noobs`, Release; no Asan). Timeout
  600000 ms; logs under `claude/port/build/`, named after your unit.
* **Files.** Edit the code, tests and build files your unit needs and write your record. Do not edit
  `DESIGN.md`, `FIDELITY.md`, `STATUS.md`, `RUNNING.md`, `FEATURES.md`, `DOS-PROFILE.md`,
  `manual-checklist-ext.md`, the D1 drafts or the D0 documents: list the entries under "For the
  records".
* **No DOS bytes** in the repository or a binary (`gen/dos/nodos.py check`); tests store only hashes,
  offsets, sizes and hand-written vectors. Never write `C:\Projects\Civ1RE\dos` or
  `claude/port/build/dosdata`; never execute a DOS program on the host.
* **Independence**: never read the main project's excluded paths (`verify/BRIEF-d0.md` lists them);
  ignore AGENTS.md's GFX/DOS/Modern/Mac/SNES sections.
* **UI.** Headless and Win32-headless tests. A short agent check with a visible civ64 window is allowed
  for D4c (civ64 windows only, screenshots under `claude/port/build/ext-d4-ui/`), not required.
* No git writes. Absolute paths; no `cd` chaining. Python only as `C:/Python314/python -B`. Files with
  backslashes only through the Write or Edit tool.
* Keep your context lean: read the sections you implement.

## Tasks

* **D4a: the DOS machine and composition (area B's base).** Draft B sections 2 and 2.1 (files, the
  callback order in `pdos_profile.c`), 3 (`pdos_mach`), 4.1..4.3 (`pdos_draw`, `pdos_glyph`, root
  helpers), 5 (`pdos_pal`: the 6-to-8 rule, loads, splices, fades, cycling; the play palette's structure
  for D6), 6 (`pdos_compose`: the N canvas, the A canvas with the core frame and W elements, frame
  choice, W over N, damage, dumps, 6.6's frame sizes with X3's 4:3 default, 6.7 the pointer with E's
  shape and `pdos_cursor`), 7.1..7.4 and 7.6 (`pdos_shadow`; the 7.5 hook interface built and unit-tested
  for D6), 9 (`pdos_scene`, `pdos_scene_tab.c`, the stack, `pdos_rand`), 10 (`pdos_fontmap`,
  `pdos_charmap`, G#21 semantics, alignment, the Windows-1252 fold). After D4a the DOS profile presents
  its own N and A frames (A = the Windows layout with the core frame where no DOS art exists yet).
  Tests: draft B 15.1's `test_pdos_draw`, `_glyph`, `_pal`, `_shadow`, `_profile`, `_compose`, `_rand`,
  `_cursor`; `tests/harness/pdos_scene_check.py`; `ext_p0.py` and `ext_frames.py` still green with the
  DOS profile drawing. Record: `claude/port/docs/ext-D4a-record.md`.
* **D4b: clock, timelines, intro, title, Birth, sequencing (area C with B's menu box).** Draft C sections
  C.3..C.8 (`pdos_clock`, `pdos_tl`, `pdos_intro.c`, `pdos_birth.c`; C.8.3 transcribes O7:17CF..1BB8
  exactly, Open C-5), C.10, C.11 (`pdos_seq`, the 19 probe rows, the pointer scene rule); draft B 4.4
  (the menu box model `pdos_ui`, `pdos_menubox_row`), 8 where the intro, title or Birth needs replay or
  provenance (`pdos_replay`, `pdos_prov`), 11.5 (N pages before the core's dialog exists, as far as the
  title box needs). Open items C-6 (title-box wrap), OB3, OB10, OB11 where D4 settles them. Tests:
  `tests/test_timeline.c` (C.15.1), `tests/harness/ext_timeline.py` (7.7, C.15.3), added to `test.cmd
  checked`; model goldens recorded (C-9). Record: `claude/port/docs/ext-D4b-record.md`.
* **D4c: the DOS filter stage, adapters, I4, I5 and the gate.** Draft C sections C.12.1..C.12.6 and
  C.12.9 (`pdos_adapt`, `pdos_adapt_tab.c` with the D4 rows I-intro, I-title, I-birth), C.13
  (`pdos_pend`), C.14 (`pdos_mouse`), C.15.2 (`test_input.c` additions), C.15.4 (`ext_adapt.py`
  DOS-form scripts for intro, title and Birth against Windows-form pairs, equal `coreinput.log` and
  checkpoints), `gen/dos/adapters.py` (DOS-PROFILE.md 1.7 version 2 generated from the table; the
  document change itself goes under "For the records"), obs_lint's area-C rules. Record:
  `claude/port/docs/ext-D4c-record.md`, then the gate record `claude/port/docs/ext-D4-acceptance.md`:
  the gate table (7.7 and 7.8 for credits, intro, title menu, Birth with colour cycling, the pointer)
  with methods (compiled, headless, agent-observed, DOS listing (model)) and results; the three unit
  records linked; DOS-oracle comparisons "not run in D4 (optional; see STATUS)"; deviations; Asan
  deferred; "For the records" gathered from all three records; the user checks of
  `manual-checklist-ext.md` D4 section left pending; not verified.

Each implementer's final message: result, files changed, test counts, deviations and the "For the
records" list.

## D4b split (2026-10-12 04:55 UTC)

D4b is done in three sequential units, all on the session's own model (the user, 2026-10-12 00:20). Each
ends with the full eight-step cycle green (Checked build and tests, G-1, CheckedNoObs build, tests and G-1,
Release build and tests; no Asan) and its record. Read `ext-D4a-record.md` first (what exists, its
deviations, and "Second review (2026-10-12)": S3, S6, S7, S9 and F2 are D4b's).

* **D4b1: the clock and the timeline engine.** Draft C C.3 (the rows `pdos_clock.h/.c`, `pdos_tl.h/.c`,
  `tests/test_timeline.c`), C.4 complete (M1..M12 as functions: the grid of C.4.2, `pdos_tick_frame`,
  `pdos_ticks_after`, `pdos_fade_weight`, `pdos_cycle_steps`, M4's first-fade frame, M8's waits, M10's
  dissolve length, the C.4.3 primitive durations), C.5 complete except the sequence programs: `PdosTl`,
  `pdos_tl_start/run/key/abandon/finish`, `pdos_tl_frame_at`, the closed-form wait ends, the per-frame
  effects (fade, then cycling) with the C.5.4 shortcuts on area B's primitives, the `PdosLogStep` record
  and a log sink (the headless `timeline.log` writer and `ext_timeline.py` are D4b2's), C.5.7's limits and
  `PDOS_DIAG_SEQ`. The engine is exercised by test programs inside `test_timeline.c` (a `PdosProgFn` with
  frame waits, tick waits, key-or-tick waits, a fade, a cycling slot and a dissolve with a finish tail).
  Tests: C.15.1 items 1 (clock), 4 (tick independence: random partitions, equal step logs and equal
  `pdos_mn` hashes), 6 (abandon and finish) and 8 (T2), on the test programs. `pdos_profile.c` is not
  wired yet (no `pdos_seq`): the DOS profile's output does not change. Record `docs/ext-D4b1-record.md`.
* **D4b2 is done in two units** (2026-10-12 07:05 UTC, usage): **D4b2a**, the intro, credits and logo
  program alone: C.6 (`pdos_intro.c`, `PdosIntroVars` replacing D4b1's placeholder), driven by D4b1's
  engine and tested in `test_timeline.c` (C.15.1 items 2, 3 and 7's intro part, with the store from
  `build\dosdata`), not wired into the profile; record `docs/ext-D4b2a-record.md`. **D4b2b**, the rest of
  the D4b2 bullet below (the title box C.7, C.10, `pdos_seq` C.11 and the wiring, B 4.4, 8, 11.5, S3, S6,
  S7, S9, `timeline.log`, `ext_timeline.py`); record `docs/ext-D4b2b-record.md`. The user accepted the
  intro-switching design (T1..T6, C.5.6, C.6, C.7, as the orchestrator explained it) on 2026-10-12 about
  07:12 UTC (STATUS "User directions"): implement it as written; no time scaling between the intros.
* **D4b2b is done in two units** (2026-10-12 08:45 UTC, usage): **D4b2b1**, the sequencer and the
  wiring: `pdos_seq` (C.11.1..C.11.4, C.11.6), the probe rows it needs for the intro (start at
  CreateSequencePlayer ra 11E0:00A5, the skip sources of C.6.4, the core leaving the title or starting
  Birth: abandon with finish, C.6.6), the calls from `pdos_profile.c`'s `on_event`, `on_probe` and
  `advance` (C.3), the hidden-profile rule (C.5.6), the headless `timeline.log` writer, and a first
  `tests/harness/ext_timeline.py` with the C.15.3 `start` run's frame checks (frames of C.6.3 from the log,
  t0 at the probe) and the `--switch-every 997` T2 run; the DOS view shows the intro and then holds the
  last intro frame (the title box comes in D4b2b2); record `docs/ext-D4b2b1-record.md`. **D4b2b2**, the
  title box (C.7, B 4.4 `pdos_menubox_*`, 11.5), the pointer rule (C.11.5), C.10, B 8 where needed, S3,
  S6, S7, S9, the remaining `ext_timeline.py` runs and the model goldens (C-9); record
  `docs/ext-D4b2b2-record.md`.
* **D4b2: intro, credits, logo, title box, sequencing, the pointer rule.** C.6, C.7, C.10, C.11
  (`pdos_intro.c`, `pdos_seq`, the 19 probe rows, wiring into `pdos_profile.c`), draft B 4.4
  (`pdos_menubox_*`, `pdos_menubox_row`), 8 where needed (`pdos_replay`, `pdos_prov`), 11.5 as far as the
  title box needs; S3 resolved before the first macro with a drawing `leave` (record option (a) or (b)
  with its vector); S6, S7, S9 resolved or recorded; C.15.1 items 2, 3, 7 (intro part); the headless
  `timeline.log`; `tests/harness/ext_timeline.py` runs `start` and its variants of C.15.3, added to
  `test.cmd checked`; model goldens (C-9). Record `docs/ext-D4b2-record.md`.
* **D4b3: Birth.** C.8 (`pdos_birth.c`; C.8.3 transcribes O7:17CF..1BB8 exactly, Open C-5), the post-Birth
  transition, F2's logical-text part; C.15.1 items 5, 7 (Birth part); `ext_timeline.py` `birth` runs.
  Record `docs/ext-D4b3-record.md`, which also gathers the D4b "For the records" for D4c's gate record.

If the orchestrator sends "wrap up" (usage limit near), stop adding, make the build and tests green, and
write the record with what is done and what remains.

## D4b4: Birth auto-continue (the user's direction, 2026-10-15 about 10:00 UTC)

Authority: STATUS.md "User directions", 2026-10-15 about 10:00 (quoted there in full). The user accepted
the DOS Birth scenes and asked: "when and the if short one is the current active one (DOS in this case),
when the intro ends it automatically continues to game setup screens without waiting." Screen-by-screen
synchronisation of the two Birth flows is a separate backlog item that is **not** part of this unit.

* **Requirement.** When the DOS profile is visible at the moment the DOS Birth sequence ends (its last
  event and the hand-over, as D4b3 detects it) and the core is still in its Birth movie, the
  presentation gives the core the Birth skip at once, so the core continues to its setup dialogs and the
  DOS view follows the core into setup without the black wait. With the Windows profile visible at that
  moment nothing changes (the Windows movie runs at its pace; the hidden DOS timeline still ends as
  now). If the core has already left Birth, nothing is produced. A profile switch to DOS after the DOS
  Birth ended (core still in Birth) produces the skip at the switch's tick (the DOS view would otherwise
  hold black) — record this reading.
* **The input.** Exactly the input a player's skip at that moment gives on the Windows profile: a host
  input event (`HostEvent`) entering the normal path as a user's key or click would (filter stage, then
  `host_sync.c` posting at the core's poll), never a write to core state (O4) and never a Win16 post
  from presentation code. Choose the key or click from the core's Birth skip poll (11E0:01BD and the skip
  rule after GenerateWorldMap 11E0:01B2, `g_movieSkipRequested` 13E0:001E; the user's 2026-10-09
  direction "skip as soon as world generation complete") so that it is consumed by the skip and cannot
  reach the first setup dialog; prove it from the listing and the core's message loop, and test it. The
  core's own rule that the skip waits for the world stays: the event is produced only when the core is
  in the skip-able Birth state (observer), otherwise held until it is or cancelled when the core leaves
  Birth.
* **Rules changed by the user's direction (record them).** I1 ("nothing time-driven may produce input")
  and T3 get one exception, this Birth auto-continue; T4's hold after the DOS Birth is replaced by it.
  FIDELITY entry: the DOS profile shortens the Windows Birth movie to the DOS Birth's length. The
  produced event is logged in the core-input log (`coreinput.log`) and the presentation diagnostics
  (a counter, for example `autocontinue`), so runs show it.
* **P0.** P0 holds for any fixed stream of core input; this feature adds one event to the stream. Tests:
  (1) a DOS-visible new-game run with the feature produces exactly one skip at the DOS Birth's end and
  the core reaches setup then; (2) a Windows-profile run given that same event at the same virtual time
  (from the first run's `coreinput.log`) has identical checkpoints, core frames and base events from
  that point (P0 against the recorded input); (3) a Windows-visible run produces nothing; (4) a run that
  switches to Windows before the DOS end produces nothing, and one that switches to DOS after it produces
  the skip at the switch; (5) the existing P0 variations (`ext_p0.py` V1 `--graphics dos`, V2 switching)
  and G-1: decide whether they run with the feature off through a harness option (the harness's default
  must keep every base run and every existing expectation unchanged) or compare against the recorded
  input; civ64's default is on. A Win32-headless check that civ64 enables it.
* **Interaction with D4c.** D4c2's `pdos_pend` (C.13) will hold pending translations; build this so that
  D4c2 can fold it into `pdos_pend` later (record the interface), or use the smallest standalone queue.
* **Files.** `present/` (the sequencer and the presentation-side event source), the filter stage and the
  host input ring as needed (`present/input.c`, `platform/w16/host_sync.c` only if the host path needs a
  presentation-originated event, recorded as a w16 change in DESIGN 12.10's list), the harness option
  (`tests/headless/`), tests (`test_pdos_seq.c`, `test_input.c`, `tests/harness/ext_p0.py`,
  `ext_timeline.py` or a new script), `win64/`/`platform/win32` only for the civ64 default. Record
  `docs/ext-D4b4-record.md` with "For the records" (DESIGN 12.5/12.8, FIDELITY, RUNNING, STATUS,
  `manual-checklist-ext.md`: a pending user check "DOS Birth continues to setup without a black wait").
* Ends with the eight-step cycle green.

## D4b3 restart and D4c split (2026-10-15, session E3)

* **D4b3** was relaunched 2026-10-15 08:30 UTC on Opus from its bullet above and `ext-D4b3-record.md`'s
  restart notes. It ran beside the base-track fix P47-R2 (`BRIEF-p47r2.md`), which held the build slot:
  D4b3 wrote its code without building (single-file syntax checks into `build/d4b3-scratch/` only) and
  was resumed for its builds and cycle when P47-R2's cycle had ended.
* **D4c is done in two sequential units**, both on the session's own model, each ending with the
  eight-step cycle green and its record:
  * **D4c1: the filter stage, adapters and mouse conversion.** Draft C C.12.1..C.12.6 and C.12.9
    (`pdos_adapt`, `pdos_adapt_tab.c` with the rows I-intro, I-title, I-birth; key forms; the pairing
    rule; Windows-only keys recorded), C.14 (`pdos_mouse`: DOS point to device point per class, with
    the C.14.2 proofs as unit vectors), C.15.2 (`test_input.c` additions), `gen/dos/adapters.py`
    (DOS-PROFILE.md 1.7 version 2 generated from the table; the document change goes under "For the
    records"), obs_lint's area-C rules. The hotkey translation of the title box (D4b2b2 deviation 2:
    hotkeys only select, per R:1D05:03BF..03FD) is decided here. Consumption (I6) and T5's "a skip ends
    all" for host input. Record `docs/ext-D4c1-record.md`.
  * **D4c2: pending translations and the gate.** C.13 (`pdos_pend`: structures, release, predicates,
    cancellation and the recorded limit, I1 conformance, the worked examples as tests), C.15.4
    (`ext_adapt.py` DOS-form scripts for intro, title and Birth against Windows-form pairs: equal
    `coreinput.log` and checkpoints), the host-input `ext_timeline.py` run (the title box driven by
    DOS-form input through the filter), then the gate record `docs/ext-D4-acceptance.md` as the D4c
    bullet above describes (S3 stays open until a macro with a drawing `leave` is registered, unless D4b3
    resolved it). Record `docs/ext-D4c2-record.md`.

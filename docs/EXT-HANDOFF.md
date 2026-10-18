# Hand-off prompt: civ64 extension (scaling, zoom, DOS profile)

Written 2026-10-11 about 09:45 UTC by extension session E2, as the standing hand-off (the user's rule:
at 1 % usage left of any limit, wrap up and persist a hand-off). Updated at later checkpoints; the
ledger `claude/port/docs/STATUS.md` ("Extension track") is always the authority for the current state.

## Prompt for a new session (paste this)

> Open, read and continue where session E3 stopped: `C:\Projects\Civ1RE\claude\docs\x64-port-scaling-dos-prompt.md`
> (the extension prompt, over the base prompt `claude/docs/x64-port-prompt.md`). Read first
> `C:\Projects\Civ1RE\claude\port\docs\NEXT-SESSION-E4.md` (E3's hand-off: state, the user's latest feedback,
> the staged units, the queue, the protocols and the standing directions), then this file's "Session E3 ended",
> then STATUS.md's "User directions", "Extension track" and the last rows of "Session log" and "Last build and
> test results". Continue autonomously through the whole queue, providing user builds and never waiting for the
> user's checks (the user's direction of 2026-10-16 about 21:40 UTC), with a hand-off at 1 % usage left.

## Queued after the DOS profile (implement once D4..D8 are complete and verified; before X9, the user's direction of 2026-10-16 about 07:05 UTC)

* **WL, windowless play mode** (the user, 2026-10-15 about 10:47 UTC, STATUS "User directions", quoted
  there): an optional mode for the actual gameplay, selected from the host's system (context) menu and
  switchable on the fly, in both the Windows and the DOS graphics profile. It drops the window chrome
  around the three game windows (map, World Map, Status) and stitches them into one gameplay canvas.
  Presentation only: the emulated windows keep their styles and positions (P0), input maps back to the
  windows' client points. Start with a design note (menu bar and scroll bars, the stitched arrangement,
  dialogs over the canvas, moving and resizing, persistence in `civ64.cfg`), then implement and test
  (headless, Win32-headless, P0 variation, agent check); the user's visual check follows. Runs after D8
  and before X9 (the user swapped WL and X9, 2026-10-16 about 07:05 UTC), so X9's final audit and the one
  Asan pass after it both cover WL.

## Interim unit HM (the user, 2026-10-17 about 10:08 UTC, session E4)

* **HM**: the host window menu with the Display, Map zoom and Graphics submenus, "Close", "Switch graphics" and the live disabled "DOS files present" item (`verify/BRIEF-hm.md`, the user's layout verbatim). Lands after the units in progress at 10:08 UTC (D6fSa, D6fSb, DBL, UX5b, D7c, D7d, D7j) and before any later unit; host-only, may be staged earlier.

## Queued after the final Asan pass (the user, 2026-10-17 about 08:35 UTC, session E4)

* Three extra features at the very end of the run, "After ASAN checks", in this order (brief and the user's verbatim text: `verify/BRIEF-extras.md`; STATUS "User directions"):
  * **AMS**: alternative music and sound effects from an optional `MusicSfx.zip` or folder (looked up like the DOS data, asked after the DOS resource questions), any of the 24 original WAV names (case-insensitive), the rest from the original; system-menu item "Alternative music/soundfx".
  * **A43**: "4:3 aspect ratio for 320 x 200 screens" renamed "... DOS intro screens"; a new item "4:3 aspect ratio for 320 x 200 DOS gameplay" for the whole DOS gameplay presentation.
  * **CRT**: one fixed scanlines filter after DOSBox Pure Unleashed's CRT filter with the user's eight settings; system-menu item "CRT scanlines".
* Each unit: a design note, its three-step cycle, a user build, checklist items; then a closing all-variant build/test and the session-end hash check.

## Backlog (optional; never started without the user's specific request)

* (Empty.) The Birth screen-by-screen synchronisation was a backlog item from 2026-10-15 about 10:00 UTC
  until the user requested it at about 14:03 UTC: it is now unit **BS**, before D5 (below).

## User requests of 2026-10-15 about 14:03 UTC (STATUS "User directions")

* **UX1** (`verify/BRIEF-ux1.md`): the DOS pointer about the Windows cursor's size (whole-number
  nearest-neighbour factor); the host close button and Alt+F4 restored, the last system-menu item "Exit
  Sid Meier's Civilization 64bit", in the game a warning (unsaved progress lost; Exit Anyway / Cancel).
* **BS** (design `verify/BRIEF-bs.md`, adopted 14:40 UTC with rulings): the Windows Birth scenes follow
  the DOS Birth's timing, screen by screen; a presentation-side replica of the Windows Birth movie (proved
  pixel-identical by a shadow mirror) on a warp from the DOS Birth; units BS1 (assets, `host_data_read`),
  BS2 (replica, shadow mirror), BS3 (warp, Windows view), BS4 (Windows end, records, BS gate); the user
  sees and verifies it before D5 starts.
* Item 4 (the eight-step cycle: explanation and the costs of moving it to the end) was answered in chat;
  the cycle stays as it is until the user decides.

## Session E3 (from 2026-10-15 08:19 UTC)

* Start: hash checks OK (`hashes/20261015T082010Z-*`). P47-R2 implemented (`p47r2-record.md`; its cycle
  is completed by D4b3's combined cycle; review `verify/p47r2-review.md`). D4b3 relaunched (build slot
  from 10:00 UTC). BRIEF-d5.md and BRIEF-d6.md adopted with rulings; D4c split into D4c1/D4c2.
* The user visually accepted the DOS Birth scenes (Checked build of 09:22:45 UTC, about 10:00 UTC) and
  asked for **D4b4 (Birth auto-continue)**: when the DOS profile is visible and the DOS Birth ends before
  the core's Birth movie, the presentation gives the core its Birth skip so the setup screens follow at
  once (an explicit I1/T3/T4 exception; P0 checked against the recorded core input). Brief: `BRIEF-d4.md`
  "D4b4".
* The P47-R2 review (`verify/p47r2-review.md`, 2026-10-15 about 10:30 UTC) accepts the fix with minor
  findings and found a pre-existing MAJOR: RunListBoxDialog's loop (1098:1BEE) stalls, and civ64 hangs,
  when another window is exposed while a list dialog is open (for example a host resize during play).
  Base-track unit **P47b** (`verify/BRIEF-p47b.md`) fixes it and the review's minors.
* **D4b3 (DOS Birth) done** 2026-10-15 (`ext-D4b3-record.md`): its final eight-step cycle, which also
  covers P47-R2's changes, is ALL_GREEN (`build/d4b3-status.txt`); its and P47-R2's records applied by a
  docs agent.
* D4b4 launched about 11:20 UTC on Opus (holds the build slot; it waited for the docs pass's marker
  `build/docs-e3a-done.txt`, created 11:31 UTC). BRIEF-d7.md drafted by a planning agent and adopted with
  rulings (15 units D7a..D7o; row 130 stays "not ready" with open items if the listing does not settle it).
* **Cycle rule from 2026-10-15 about 14:09 UTC (the user chose "B plus E"):** a unit ends with the
  three-step cycle (`build.cmd checked`, `test.cmd checked`, `ext_g1.py check`); the eight-step cycle runs
  only at phase gates (D4, BS, D5, D6, D7, WL, X9, before the final Asan pass). Unit **CY**
  (`verify/BRIEF-cy.md`) parallelises `test.cmd` (and possibly the gate builds) with equivalence proven.
* 15:45 UTC: D4c1 and D4c2 are staged and READY_TO_BUILD (`build/d4c1-stage/`, `build/d4c2-stage/` on top
  of it, each with `BASE-SHA256.txt`); CY and UX1 staging from 15:45 (`build/cy-stage/`, `build/ux1-stage/`).
  Build-slot order: P47b (running), D4c1, D4c2 (D4 gate), CY, UX1, BS1..BS4. A unit given the slot rebases
  its stage on the tree (compare BASE-SHA256), copies it in, then runs its cycle.
* 16:20 UTC: CY staged, READY_TO_BUILD (`build/cy-stage/`: sectioned `test.cmd`, `tests/harness/testpar.py`,
  `build.cmd all`, `ext_p0.py` write-if-changed, `cy_equiv.py`; measured eight-step 62 min, expected 33-38 min,
  three-step 36 -> 22-26 min). **Merged gate:** D4c2's eight-step D4 gate run (old sequential `test.cmd`)
  doubles as CY's sequential baseline: D4c2 runs `build/cy-tool/cy_equiv.py digest <Variant> <start epoch>
  build/cy-equiv/seq-<variant>.json` after each of its three test steps (the copy in `build/cy-tool/` resolves
  the port root correctly). CY then copies its stage in and replays the three tests in parallel on the same
  builds (no rebuild in between), compares digests and logs, and ends with one eight-step run using
  `build.cmd all`.
* 16:35 UTC: **P47b done**, three-step cycle ALL_GREEN (`build/p47b-status.txt`, `p47b-record.md`); its
  records applied by a docs agent (marker `build/docs-p47b-done.txt`, 16:44 UTC; new user check P47-2).
  CheckedNoObs/Release for P47b run at the D4 gate. D4c1 holds the build slot from about 16:40 UTC.
* 17:30 UTC: **D4c1 done**, three-step cycle ALL_GREEN (`build/d4c1-status.txt`, `ext-D4c1-record.md`); a
  docs agent applies its records (marker `build/docs-d4c1-done.txt`). D4c2 holds the build slot from 17:32 UTC
  for the D4 gate (eight steps, with CY's digests into `build/cy-equiv/`).
* About 17:46-17:51 UTC the Claude session ended and stopped D4c2 (during step 2, `test.cmd checked`, in
  `nodos.py`) and the BS1/BS2 stager (`build/bs-stage/`). Both resumed 17:55 UTC: D4c2 keeps step 1's build
  (no source change since) and reruns from step 2; the BS stager continues and writes its `BASE-SHA256.txt`
  (its `harness.c` base predates D4c2's copy-in).
* 18:05 UTC: BS1+BS2 staged, READY_TO_BUILD (`build/bs-stage/`; one unit "BS12" with one three-step cycle after
  UX1; `BUILD-TEST-ADDITIONS.md` holds the build.cmd/test.cmd additions; private shadow mirror equal on p4-birth
  1436/1436 and an EARTH start 84/84). Incident: a stale private test binary wrote a synthetic
  `build/gamedata/pbs-movie/CivData0.rsc` at 18:02:51 UTC; removed 18:09 UTC with the user's approval (the folder's mtime stays changed).
* 18:15-18:20 UTC, the user: work autonomously; ask only real questions. The BS check does **not** block D5:
  after the BS gate, prepare a user-testable copy in `build/user-builds/<unit>/` (the user's scheme, 18:30 UTC; layout as `build/user-check-d4b4/`), tell the user, and start D5 at
  once. BS3+BS4 staging in `build/bs34-stage/`; an independent read-only review of D4c1/D4c2 writes
  `verify/ext-d4c-review.md` (fixes, if any, as a unit after CY).
* 18:40 UTC: the D4c review is in (`verify/ext-d4c-review.md`): accept with fixes, 0 BLOCKER, 1 MAJOR (R1: a
  cancelled intro-shortcut translation leaves the title box in HOLD), 7 MINOR (R2..R8). Unit **D4cF** stages the
  fixes in `build/d4cf-stage/` (D4c1's implementer) and lands after CY. User builds go to
  `build/user-builds/<unit>/` (the user, 18:30 UTC); `user-builds/d4` follows the D4 gate with R1 noted as known.
* 19:08 UTC: **D4 phase gate met** (D4c2's eight-step cycle ALL_GREEN 19:05:46 UTC, `ext-D4-acceptance.md`; CY's
  baseline digests in `build/cy-equiv/seq-*.json`). User build `build/user-builds/d4/` (with `WHAT-TO-CHECK.txt`).
  CY holds the build slot (replay on the gate's binaries, then its eight-step cycle with `build.cmd all`).
* 19:20 UTC: BS3+BS4 staged, READY_TO_BUILD (`build/bs34-stage/`). Build-slot order now: CY, D4cF (three steps),
  UX1 (three steps), BS12+BS34 landed together with the BS gate's eight-step cycle (`verify/BRIEF-bs.md` Rulings
  19:20), user build `build/user-builds/bs/`, then D5a (no wait for the user's BS check).
* 20:15 UTC: D4cF READY_TO_BUILD (`build/d4cf-stage/`: R1..R8 and the user's D4-3 direction, lone Ctrl, Shift,
  Alt and lock keys do not skip the DOS sequences; Alt and locks accepted by the user 19:50). D5a READY_TO_BUILD
  (`build/d5a-stage/`, based on BS34's `pdos_seq`/`pdos_profile`; 3-way merge with D4cF's `pdos_seq.c/.h` at landing,
  trial in its `obj/merge-trial2/`). D5b staging in `build/d5b-stage/`. User build `user-builds/d4`: all checks passed
  but D4-3 (the user, 19:40).
* 21:25 UTC: **CY done**, eight-step cycle with `build.cmd all` ALL_GREEN (`build/cy-status.txt`, 2,503 s against
  4,452 s at the D4 gate; `test.cmd checked` about 1,170 s; equivalence in `build/cy-equiv/`, `ext-CY-record.md`).
  New test steps are `rem @section` blocks (record section 3). D4cF holds the build slot from 21:25 UTC.
* 22:27 UTC: **D4cF done**, three-step cycle ALL_GREEN 22:14:19 UTC (`build/d4cf-status.txt`); user build
  `build/user-builds/d4cf/` (Release built 22:20 UTC from the same tree; `WHAT-TO-CHECK.txt`: D4-3 and the new
  items). UX1 holds the build slot (after the docs pass marker `build/docs-d4cf-done.txt`). D5ab lands with
  `gen/dos/registry.py`'s OBSERVER_FILES gaining `pdos_reskin.c/.h` (staged in `build/d5c-stage/`).
* 22:58 UTC: the user passed `user-builds/d4cf` ("d4cf all green", 22:45). **UX1 done**, three-step cycle ALL_GREEN
  22:51:42 UTC (`build/ux1-status.txt`, `ext-UX1-record.md`); user build `build/user-builds/ux1/` (UX1-1..UX1-6).
  The BS implementer holds the build slot: BS12+BS34 landing and the BS gate's eight-step cycle (`build/bs-status.txt`).
* 23:40 UTC: the user passed UX1-2..UX1-6; UX1-1 failed ("too small ... between the previous and the current
  one"): unit **UX1b** staged (`build/ux1b-stage/`, mean of the old and UX1 factors, a half up). D5c staged
  (`build/d5c-stage/`, the DOS setup pages). Landing after the BS gate: the D5 implementer lands UX1b, D5ab and
  D5c in one slot with one three-step cycle, then user build `build/user-builds/d5c/`. D5d staging in
  `build/d5d-stage/`.
* 2026-10-16 00:15 UTC: **BS phase gate met** (BS12+BS34 landed 23:00-23:35 UTC; eight-step cycle ALL_GREEN
  00:10:04 UTC, `build/bs-status.txt`, `ext-BS-acceptance.md`). User build `build/user-builds/bs/` (BS-1..BS-6;
  not a gate for D5). The D5 implementer holds the build slot for the UX1b+D5ab+D5c landing (`build/d5l-status.txt`).
* 01:28 UTC: the landing of UX1b, D5a, D5b and D5c is ALL_GREEN (01:20:28 UTC, `build/d5l-status.txt`; the
  first test run failed only ext_continue's check 1, changed for D5c's setup page). User build
  `build/user-builds/d5c/` (UX1-1 again and the DOS setup pages). D5d staging resumed (`build/d5d-stage/`); the
  build slot is free until D5d is ready.
* 02:46 UTC: **D5d landed**, three-step cycle ALL_GREEN 02:36:49 UTC (`build/d5d-status.txt`); user build
  `build/user-builds/d5d/` (name pages and the introduction text). D5e staging (`build/d5e-stage/`), then D5f and
  the D5 gate; D6a staging in parallel (`build/d6a-stage/`, lands after the D5 gate).
* 04:10 UTC: **D6a landed** early (orchestrator ruling 03:45: nothing visible, no D5 file; the D5 gate's eight
  steps cover it), three-step cycle ALL_GREEN (`build/d6a-status.txt`, `ext-D6a-record.md`). D6b staging
  (`build/d6b-stage/`) by the D6 implementer; D5e staging by the D5 implementer.
* 05:06 UTC: **D5e landed**, three-step cycle ALL_GREEN 04:58:43 UTC (`build/d5e-status.txt`); user build
  `build/user-builds/d5e/` (Customize World). D5f staging (then the D5 gate's eight steps); D6b staging.
* 05:29 UTC: the user: "build bs passed user test": BS-1..BS-6 **passed** (checklist 91 items, 43 passed,
  48 pending; STATUS "User directions"). Pending user checks: UX1-1 (UX1b) and D5-2..D5-18 (builds d5c..d5e).
* 05:45 UTC: the user's d5c feedback (STATUS "User directions" 05:43): with the DOS graphics no Go Back row on the
  difficulty, competition and tribe pages, no "Custom." row on the tribe page, Escape there does not open the tribe
  name box. Rework unit **D5cR** given to the D5 implementer, staged with D5f, landing in the D5 gate's eight-step
  cycle; checklist D5-2, D5-4, D5-5, D5-6 failed, D5-1, D5-8 in rework. User build `user-builds/d5` after the gate.
* 05:50 UTC: the user withdrew the Escape item: Escape on the DOS tribe page keeps opening the tribe name box (as in
  DOS); D5cR is the removal of the Go Back rows and of the "Custom." row only (amendment sent to the D5 implementer).
* 05:52 UTC: the user: "d5d passed its user test": D5-8..D5-12 **passed** (checklist 48 passed, 43 pending).
* 06:00 UTC: the user's d5e feedback: no Cancel row on the DOS Customize boxes; the choices in sync between the
  graphics while answering. Rework unit **D5eR** given to the D5 implementer (with D5f and D5cR, D5 gate); D5-13,
  D5-15, D5-17 passed, D5-14, D5-16, D5-18 failed (checklist 51 passed, 40 pending).
* 06:10 UTC: **user rule for every DOS screen**: no Go Back or Cancel row the DOS game lacks; a DOS key with the same
  effect (e.g. Escape) where the listing has one, otherwise the choice is Windows-only. Recorded in `dos/OPEN.md` P17,
  `verify/BRIEF-d5.md`, `BRIEF-d6.md`, `BRIEF-d7.md` ("User direction 2026-10-16"), STATUS "User directions";
  sent to the D5 implementer (D5b's generic re-skin row removed in the D5f stage) and the D6 implementer.
* 07:15 UTC: **D6b landed** (logical replay and provenance for play, S3 option (a); nothing user-visible): first cycle
  stopped at step 2 (registry include rule: `pdos_replay.c`, `pdos_prov.c` not in OBSERVER_FILES), fix 1 at 06:45 UTC,
  rerun ALL_GREEN 07:09:05 UTC (`build/d6b-status.txt`, `ext-D6b-record.md`). Docs D6b pass running (marker
  `build/docs-d6b-done.txt`); D6c staging; D5f + D5cR + D5eR staging (rebased onto D6b's five shared files), then the
  D5 gate. Queue after D7 (user, 07:05 UTC in another chat): D8, WL, X9, Asan.
* 07:49 UTC: D5f + D5cR + D5eR copy-in started by the D5 implementer; the D5 gate's eight-step cycle running
  (`build/d5-gate-status.txt`).
* 08:15 UTC: the user's results page (another chat; STATUS "User directions" 08:05; checklist 64 passed, 27 pending)
  gave two host items: unit **UX2** (the UX1 agent, staging in `build/ux2-stage/`, landing after the D5 gate):
  (a) the system menu's profile radio mark follows the starting profile (K7); (b) square is the default for
  320x200 pictures, 4:3 an option (X3/F116 superseded; an old civ64.cfg's stored aspect handled by the UX2 record).
  D5-7 moves to D6 (named screen in D6's user checks; the D5 gate's docs pass moves the item).
* 08:22:33 UTC: **session restart** (all agents stopped; old agent IDs not resumable). The D5 gate driver was
  restarted from step 7 by the orchestrator (`-r2` logs); new agents for the D5 landing records, UX2 and D6c.
* 08:37:49 UTC: **D5 phase gate met** (eight steps ALL_GREEN, `build/d5-gate-status.txt`; `ext-D5-acceptance.md`,
  `ext-D5f-record.md` "Landing"). User build `build/user-builds/d5/` (D5cR, D5eR, the no-added-rows rule, Hall of
  Fame, Load). Docs pass for the gate running (marker `build/docs-d5gate-done.txt`). Next: UX2 landing, D6c.
* 09:45 UTC: docs pass for the D5 gate done (09:04:39; checklist 96 items, 64 passed, 32 pending). **UX2 landed**,
  three-step cycle ALL_GREEN 09:34:18 UTC (`build/ux2-status.txt`, `ext-UX2-record.md`): the graphics radio mark follows
  the starting profile, square default for 320x200 (cfg key `aspect_320x200`). User build `build/user-builds/ux2/`.
  Docs pass for UX2 running (marker `build/docs-ux2-done.txt`); D6c staging.
* 10:30 UTC: **D6c landed** (the DOS map rules in view; ALL_GREEN 10:15 UTC, `build/d6c-status.txt`; user build
  `build/user-builds/d6c/`); docs pass running (marker `build/docs-d6c-done.txt`); D6d staging. New from the user
  (STATUS "User directions" 10:10..10:21): **D5K** (keyboard lost after a Windows-only Go Back and a switch to DOS),
  **SL** (DOS Save/Load slot screens: ten newest .SAV, no drive prompt, Save in play too), **UX3** (menu texts
  "Integer scaling", "4:3 aspect ratio for 320 x 200 screens"; 4:3 default again; DOS intro, title and Birth always
  square). All three staging; each lands after the previous docs marker.
* 11:13 UTC: **D5K** landing (root cause: the original disables the focused Go Back at 1220:07FC, the focus becomes
  NULL, MenuZ ignores the keys; fix in the DOS filter). The user chose to fix the Windows graphics too (STATUS 11:12):
  follow-up **D5K2** (platform focus rule), staged after D5K. D6c's cycling verified by the other chat (no defect;
  follow-ups folded into D6d as D6cF). Checklist: not-yet-implemented items marked so (D6-1, D5-7, D5-20), UX2-5/6
  superseded by UX3.
* 11:34 UTC: **D5K** ALL_GREEN (`build/d5k-status.txt`); user build `build/user-builds/d5k/` (D5K-1..4).
* 12:04 UTC: **UX3** ALL_GREEN (`build/ux3-status.txt`): "Integer scaling", "4:3 aspect ratio for 320 x 200
  screens" (4:3 the default again, key `aspect_4_3` only on a menu change), the DOS intro, title menu and Birth
  always square; user build `build/user-builds/ux3/` (UX3-1..10).
* 12:35 UTC: **D5K2** ALL_GREEN (`build/d5k2-status.txt`): a disabled focused dialog control gives the focus to
  the default button; user build `build/user-builds/d5k2/` (D5K2-1..3).
* 12:58 UTC: the user's results (other chat, STATUS 12:55): M-3 (Ctrl+Shift+0) and LP-8 (off-screen window)
  failed, LP-5 passed with a dark-mode request: unit **UX4** staging (`build/ux4-stage/`).
* 13:15 UTC: the orchestrator added the checklist sections D5K, UX3 and D5K2 (126 items, 101 passed, 23 pending,
  2 superseded); the other chat reloaded the results page.
* 13:45 UTC: **SL** landed (the DOS Save/Load slot screens; ALL_GREEN 13:34:58 after a rerun of the known
  w32_test_host_win32 GetKeyState flake, `build/sl-status.txt`); user build `build/user-builds/sl/` (D5-20
  rewritten, SL-1..7). One docs pass for D5K + UX3 + D5K2 + SL running (marker `build/docs-sl-done.txt`;
  FIDELITY F182 SL, F183 D5K, F184 D5K2). Next landings: D6d (with D6cF), UX4.
* 13:55 UTC: the user's results (other chat): D5K-1..4, UX3-1..5, UX3-7..10, D5K2-1..3 passed (126 items, 117
  passed, 7 pending, 2 superseded). New bug (STATUS "User directions" about 13:50): after Customize World's
  Windows-side Cancel a switch to DOS shows the Customize picture under the title box. Unit **D5P** staging
  (`build/d5p-stage/`): a return to the title menu taken with the Windows graphics visible leaves the DOS view on the
  original title menu; DOS-side returns keep the DOS listing's behaviour. Landing queue: D6d, UX4, D5P.
* 13:56 UTC: the user on build sl: 4:3 kept when returning from the Hall of Fame and Load; no Quit row in the DOS
  title menu. Both folded into **D5P** (the title menu's shape follows the picture behind its box). 14:03 UTC: docs
  pass D5K + UX3 + D5K2 + SL done (F182 SL, F183 D5K, F184 D5K2). 14:06 UTC: SL-1..7 passed (other chat).
* 14:39 UTC: **D6d** (with D6cF) landed: ALL_GREEN 14:34:38 (`build/d6d-status.txt`); user build
  `build/user-builds/d6d/` (D6d-1..6, M-1's DOS zoom). Docs pass D6d running (marker `build/docs-d6d-done.txt`);
  D6e staging.
* 15:05 UTC: the user chose "Add Ctrl+Shift+Home" for M-3's main row (follow-up **UX4b**). 15:27 UTC: **UX4**
  ALL_GREEN (keypad Ctrl+Shift+0, LP-8 placement, dark message boxes); user build `build/user-builds/ux4/`; the
  orchestrator added the UX4 checklist section; the user passed M-3, LP-8, UX4-1..4 (15:38..15:42).
* 15:30 UTC: the user's bug: centring at zoom -1 offset south -> unit **MZ** (the D6 implementer, before D6e; the
  user keeps the pole limit, 15:35). D6d results: D6d-4 failed (MZ), the rest passed; D6d-6's request: the World
  Map's rectangle follows the zoom level -> unit **MZW** (after MZ).
* 16:05 UTC: **D5P** ALL_GREEN (title-menu parity, 4:3 kept over sub-screens, no DOS Quit row, the C.6.6 box's
  font); user build `build/user-builds/d5p/` (D5P-1..10). Joint docs pass UX4 + D5P running (marker
  `build/docs-d5p-done.txt`). Next landings: MZ, UX4b, MZW; then D6e.
* 17:02 UTC: **UX4b** ALL_GREEN (Ctrl+Shift+Home for the normal map zoom; F188 the name-box deviation); user build
  `build/user-builds/ux4b/` (M-3b, passed 19:56).
* 18:12 UTC: **MZ** ALL_GREEN (zoom -1 centring: the layer re-centred at every core view change; the user's pole
  limit kept); user build `build/user-builds/mz/` (MZ-1..7; D6d-4 superseded as MZ-4). 19:15 the user asked to roll
  MZ back, then kept it after the orchestrator's clarification ("let it stay as it is for a while I'll test it
  further"); 19:24 "MZ is accepted" (MZ-1..7 passed).
* 19:04 UTC: **MZW** ALL_GREEN (the World Map's rectangle follows the zoom level); user build
  `build/user-builds/mzw/` (MZW-1..8; test save `MZTEST.SAV` in `%LOCALAPPDATA%\civ64\CivWin`, made by the checks
  chat). MZW-1..7 passed; MZW-8 failed 20:16 (a black block in the zoomed map under an open menu) -> unit **MZS**.
  Joint docs pass UX4b + MZ + MZW done 19:33:39 (`build/docs-mzw-done.txt`; F188; next free F189).
* 19:24..20:16 UTC, new units from the user: **MZI** (centring at +1 on MZTEST.SAV: the +1 layer kept its place
  at a core view change; fix: centre on the requested square at every SetMapViewAndRedraw and on a new active unit
  that needs a pan; mainly an east/west offset, the user 19:45); **UX5** (19:39: 4:3 also for the DOS intro and
  title menu, Birth stays square); **SI** (19:44: single instance; decided: the original's own box "Sorry! Only
  one game at a time!" of WinMain 1008:0070, then the running civ64 brought forward, the activation the deviation;
  another folder: civ64's box naming it; `--multi-instance` for drive_civ64.py); **TLD** (20:03: the Windows
  title's Load left a grey L of the menu box behind the file chooser: a stale present before
  `host_choose_file`, base track since phase 5; fix `w16_present_view()` before every blocking host call);
  **MZS** (20:16: popup-covered map pixels filled black when the port bitmap is not the client's size; since M,
  and D6d for DOS; fix from the port bitmap as WdwMapProc's WM_PAINT 1208:0332, plus a `--fit-layout 1` check in
  the cycle).
* 21:17 UTC: **UX5** ALL_GREEN; user build `build/user-builds/ux5/` (UX5-1..7); the orchestrator added the UX5
  checklist section and the superseded-in-part notes (177 items: 162 passed, 12 pending, 3 superseded). From about
  21:35 **MZI** in the build slot. **D6f** READY (waits for D6e), sent back for: Escape on the dialog-136 boxes in
  play per box with a proven -1 equivalent (O1), the zoom layer never over DOS boxes on A, the Cancel-row audit;
  Alt+C/Alt+H keep the Windows meaning (O3). Landing order: MZI, SI, TLD, MZS (on MZI), D6e, D6f; then a joint
  docs pass (MZI, UX5, SI, TLD, MZS; FIDELITY from F189), D6g and the D6 gate, D7.
* 21:40 UTC the user (verbatim): "Your goal is to continue working until all tasks are completed autonomously.
  Continue providing user builds, I'll be checking and verify them when I returned to computer, you are authorized
  to take any necessary actions to complete tasks." (STATUS "User directions"): the queue runs to its end without
  waiting for the user's checks; the standing constraints stay.
* 2026-10-16 22:08 .. 2026-10-17 00:53 UTC: **MZI** ALL_GREEN 22:08:45 (user build `build/user-builds/mzi/`,
  MZI-1..7), **SI** ALL_GREEN 23:38:15 (`si`, SI-1..6), **MZS** ALL_GREEN 00:25:05 (`mzs`, MZS-1..6; MZW-8 pending
  again there); the orchestrator added each checklist section (196 items: 162 passed, 31 pending, 3 superseded).
  Docs pass UX5 + MZI + SI + MZS done 00:53:30 (`build/docs-mzs-done.txt`; F189 SI, F190 MZS; next free **F191**).
  New unit **FCE** (`build/fce-stage/`): Escape on the game's list and modal dialogs (Find City, the Civilopedia
  lists): the original under Windows 3.1 ignores it (IsDialogMessage's IDCANCEL, no id-2 control; the game's
  WM_CHAR 1Bh handlers unreachable), so the Windows graphics stay; in the DOS graphics Escape posts the game's own
  cancel (DOS's screens cancel on Escape). Side finding for X9: Escape in Windows Customize World writes -1 to
  worldParams[-200] (12D8:3764) in the original too, reproduced faithfully. Landing order: D6e (after the docs
  marker), TLD, then D6f and FCE as READY; then D6g and the D6 gate (the D6 implementer).
* 2026-10-17 01:23 .. 06:52 UTC: **D6e** ALL_GREEN 01:23:53 (`d6e`, D6e-1..7), **TLD** 02:05:31 (`tld`, TLD-1..7),
  **FCE** 03:41:10 after a failed first run (d2_registry include rule; `fce`, FCE-1..5), **D6f** 04:51:44 (`d6f`,
  D6f-1..8, D6-1 and D5-7 rewritten); docs passes docs-tld (F191, F192) and docs-d6f (F193..F203; next free **F204**).
  **D6 phase gate met**: eight-step ALL_GREEN 06:02:50 (`build/d6-gate-status.txt`), the full zoom matrix, Z-1..Z-3,
  the agent UI check (`build/ext-d6-ui/`); `docs/ext-D6g-record.md`, `docs/ext-D6-acceptance.md`; user build `d6g`.
  Checklist 223 items: 162 passed, 58 pending (all checkable), 3 superseded. R1/R2 (Edit/City/Help drop-downs,
  separators and grayed ORDERS rows in the DOS graphics) are known differences with no owner (F196/F197).
* D7 runs on stacked tracks (each stages on D7a's copies, separable blocks in the shared tables, joint landings
  allowed): track A D7a (landing 06:55), D7b, then D7m; D7c (the D6 implementer); track B D7d (a DOS-layout city
  renderer from the core's state, ruling 4's alternative, accepted with read-only and self-check conditions), D7e,
  D7f, D7g, then D7h, D7i, D7k; track C D7j, D7l; then D7n, D7o (sweep and the D7 gate). Owners: PDOS_OWNER_MAX 6
  (D7a), 7 (D7d's "city"); scene bits D7a 0x02000000, D7b 0x04000000, D7d 0x08000000. Gate notes: row 14's
  ROW_ALLOW goes with D7d; row 0 (the audience span, leader font table) with D7k.
* Order (revised 14:45 UTC): D4b4 (done, accepted by the user 13:51 UTC), P47b (running;
  `verify/BRIEF-p47b.md`), CY (`verify/BRIEF-cy.md`), D4c1 (staged in `build/d4c1-stage/`, READY_TO_BUILD
  14:40 UTC: copy in, re-apply its delimited test.cmd block onto CY's test.cmd, three-step cycle), D4c2
  (staging from 14:50 UTC in `build/d4c2-stage/` on top of D4c1's stage; D4 gate with the eight-step cycle; moved before UX1/BS because D4c1 consumes DOS-form inputs that need a
  queued step until D4c2), UX1 (`verify/BRIEF-ux1.md`), BS1..BS4 (`verify/BRIEF-bs.md`; BS gate; the
  user's check before D5), D5 (`verify/BRIEF-d5.md`, units D5a..D5f), D6 (`verify/BRIEF-d6.md`, D6a..D6g),
  D7 (`verify/BRIEF-d7.md`, D7a..D7o), D8, WL (windowless play mode, queued above), X9, Asan.
* How E3 runs units: one implementer holds the build slot; a second agent may write code only if its files
  are not compiled by the builder's build (`build.cmd` globs `present/dos/*.c`: a parallel coder there
  breaks the builder's cycle, as happened at P47-R2's step 2); docs agents run beside a builder only before
  its final cycle (DESIGN.md and DOS-PROFILE.md are test inputs: obs_lint, pdos_scene_check, obs_tables),
  signalling the end with a marker file under `build/`. From 13:55 UTC a parallel coder uses a **staging
  directory** instead: D4c1 writes new files and full modified copies under `build/d4c1-stage/` (with
  `BASE-SHA256.txt` of each original), compile-checks there, reports READY_TO_BUILD, and copies the stage
  into the tree only when it is given the build slot (after P47b's cycle).

## Session E3 ended (2026-10-17 about 07:15 UTC, the user's stop)

The user: "stop and provide a full hand-off prompt for the next session". The full hand-off is
`claude/port/docs/NEXT-SESSION-E4.md`; this section is its summary.

* **Tree**: the D6 phase gate's state (eight-step ALL_GREEN 2026-10-17 06:02:50 UTC). D7a's copy-in of 06:54 was
  backed out at the stop (`build/d7a-prep/BACKED-OUT.txt`); its first cycle step had built (BUILD_OK) and its test
  step was stopped unfinished, so D7a is not landed. Newest user build `build/user-builds/d6g/`.
* **Landed in E3**: SL, D6d (+D6cF), UX4, D5P, UX4b, MZ, MZW, UX5, MZI, SI, MZS, D6e, TLD, FCE, D6f and the D6
  gate; docs passes through docs-d6f. FIDELITY next free **F204**. Hash checks after: OK
  (`docs/hashes/20261017T070311Z-*.txt`).
* **The user's feedback of 06:53..07:00 UTC** (D6-1 at 2x; the six-item revision list) is recorded in STATUS "User
  directions" and as failed checklist rows (D6-1, D5-7, D6f-1, D6e-5, UX5-5) with rework units **D6fS** (DOS menus
  exactly the DOS game's, no highlight, box heights, 2x bar), **DBL** (DOS blink periods; a contradiction between the
  listing's 0.285 s and the user's "slightly faster" must be settled first) and **UX5b** (no squashed title before
  Birth; cause found in pdos_seq.c's square switch at the Birth probe). All three are research only, with `STATE.md`
  in their stage dirs.
* **Staged D7**: D7a READY but needs its registry fix (`pdos_scn_report.c`: no `<stdio.h>`, add to OBSERVER_FILES);
  D7b READY on d7a-stage (same fix in its copy); D7d designed, nothing staged; D7j staged, not READY; D7c not started. Owner clash:
  D7d and D7j both set PDOS_OWNER_MAX 7 (the combined value is 8).
* **Queue**: the reworks D6fS, DBL, UX5b; D7a; the D7 tracks and the D7 gate; D8; WL; X9; the one Asan pass;
  the session-end hash check.
* Orchestration scripts for reuse: `build/e3-orchestrator/` (chk_lib.py, hashcheck.ps1, the chk_*.py and
  handoff_*.py examples, orchestrator-state.md with E3's full log). E3's agents cannot be resumed.

## Session E2 ended (2026-10-12 12:35 UTC, weekly usage 99 %)

* State: the tree is D4b2b2's state; its full eight-step cycle is ALL_GREEN (`build/d4b2b2-status.txt`), and
  a Checked rebuild after D4b3's revert is BUILD_OK (`build/e2-final-build-checked.log`, 12:40 UTC). No
  agent is running. Hash checks at the end are OK. D4b3's restart notes (`ext-D4b3-record.md`) list five
  places where the listing differs from draft C 8 (the listing wins) and two registry gaps.
* Done in E2's last day: D4a (with two Opus reviews and their fixes), the DOS-PROFILE/draft-B placements,
  D4b1 (clock, engine), D4b2a (intro program), D4b2b1 (sequencer, wiring: the DOS intro is visible),
  D4b2b2 (title box, menu-box model, pointer rule, S6/S7/S9), the D4b records in DESIGN/FIDELITY/RUNNING/
  FEATURES/checklist. The user accepted the intro-switching design (07:12) and visually accepted the DOS
  intro with switching (11:35) and the title box (11:40); checklist D4-4..D4-13 passed, D4-14 pending.
* Next, in order, all agents on the session's own model (Opus; the user's direction, never lower it):
  1. Session-start hash check.
  1a. **Base-track fix RV4 P47-R2 (the user's decision of 2026-10-11 about 08:00 UTC; queued then to run
     once E2 had finished, and not started because the weekly limit was at 99 % when E2 ended).** The
     Find City (dialog 131) and Civilopedia lists show their scroll bar when the dialog opens if and only
     if the list holds more items than fit on one page. Cause and plan: STATUS.md base track "Next
     concrete step", FIDELITY F80, `verify/phase4-review-4.md` P47-R2 (ListDialogSubclassProc's snapshot
     repaint covers the bar and border until a scroll). Fix in `platform/w16` paint handling, core
     unchanged; test both dialogs (bar when the items exceed a page, none otherwise), keep the full
     cycle green, update F80 and STATUS.md; the user's visual check follows.
     **Done 2026-10-15** (`p47r2-record.md`; review `verify/p47r2-review.md`, accept; covered by D4b3's
     combined cycle, ALL_GREEN, `build/d4b3-status.txt`; records applied; the user's visual check pending;
     the review's pre-existing MAJOR finding 1 is queued as P47b).
  2. **D4b3 (Birth)** from `verify/BRIEF-d4.md` "D4b split", reading `ext-D4b2b2-record.md`'s notes for
     D4b3 and `ext-D4b3-record.md`'s restart notes. Then a docs agent applies D4b3's records.
  3. **D4c** (filter stage, adapters, I4, I5, the 7.8 runs, the host-input `ext_timeline.py` run, hotkey
     translation (hotkeys only select in DOS), and the gate record `ext-D4-acceptance.md`). S3 stays open
     until a macro with a drawing `leave` is registered.
  4. D5, D6, D7, D8, X9, then the one Asan pass of the whole queue.
* Budget: a unit costs about 1 % of the weekly limit; the weekly limit resets 2026-10-15 08:00 UTC.

## Where the work stands (2026-10-12 about 02:45 UTC; see the section above for the end state)

| Phase | State | Record |
|---|---|---|
| X0, S1, S2, R, G | gates met (S2, R, G with the user's check; G's check came 07:50 UTC in a separate chat) | `ext-X0/S1/S2/R/G-acceptance.md` |
| D0 DOS recovery | gate met 07:45 | `ext-D0-acceptance.md`, `verify/ext-d0-review.md` |
| D1 design | gate met 09:25 | `ext-D1-acceptance.md`; DESIGN.md 12.5..12.11; detailed design `verify/ext-d1-draft-A..E.md` (Revision 3); decisions `verify/ext-d1-decisions.md`; reviews `verify/ext-d1-review.md` |
| D2 DOS assets | gate met 09:40 (Checked, Release; Asan deferred) | `ext-D2-acceptance.md` |
| D3 observer, tick, switching, P0 tests | gate met 15:36 UTC (D3a, D3b1, D3b2; Asan deferred); records applied to DESIGN/FIDELITY/RUNNING/checklist by a docs agent from 15:45 | `ext-D3-acceptance.md` |
| M map zoom | gate met 2026-10-11 21:27 UTC (Ma, Mb1, Mb2; 7.5 M1 checks and Z-1..Z-3 headless; agent UI check interrupted by a "user interrupt" on the first input, moved to the user's checks; Asan deferred); records applied by a docs agent from 21:40 | `ext-M-acceptance.md` |
| LP low-priority requests | complete 23:10 UTC (wheel item, version 1.0, titles and captions, licence note, placement; all variants green) | `ext-LP-record.md` |
| D4 | **in progress**: D4a (B base) complete 02:12 UTC on Sonnet (all eight steps green); Opus review 1 02:35 (0 MAJOR, 6 MINOR; `verify/ext-d4a-review.md`), fixes green 03:34; records applied 03:45; Opus review 2 03:52 (6 MAJOR; `verify/ext-d4a-review-2.md`), fixes green 04:48 UTC (S1, S2, S5 fixed with vectors; F1 open for D7; S3 for D4b, S4 for D5; minors listed; `ext-D4a-record.md` "Second review (2026-10-12)"); D4b split into D4b1 (clock, timeline engine; **done 07:00 UTC**, `ext-D4b1-record.md`), D4b2a (intro program; **done 08:40 UTC**, `ext-D4b2a-record.md`), D4b2b1 (sequencer, wiring; **done 10:20 UTC**, `ext-D4b2b1-record.md`), D4b2b2 (title box, pointer rule, S6/S7/S9; **done 12:00 UTC**, `ext-D4b2b2-record.md`; intro and title box visually accepted by the user 11:35/11:40), D4b3 (Birth; **not started**: launched 12:25 UTC and stopped at 12:32 UTC at the weekly limit's 99 %, its one edit reverted; `ext-D4b3-record.md` holds only restart notes; **this is the next unit**: relaunch it from `verify/BRIEF-d4.md` "D4b split" D4b3 bullet, with the D4b2b2 record's notes for D4b3); D4b1..D4b2b2 records applied 12:20 UTC (checklist D4-4..D4-13 passed, D4-14 pending) (`verify/BRIEF-d4.md` "D4b split"); then D4c (filter, gate), all on Opus | brief `verify/BRIEF-d4.md`; `ext-D4a-record.md` |
| D5..D8, X9 | not started | designs in drafts B (pixels), C (time and input), D (map) |

Estimated extension completion by the prompt's weights: about 63 % at 12:05 UTC on 2026-10-12 (S1, S2, D0,
D1, D2, D3, M done = 55; of D4's 12: D4a with both reviews about 4, D4b1, D4b2a, D4b2b1, D4b2b2 about 1
each; D4b3 about 1 and D4c about 3 remain). Usage: weekly 98 % at 12:01 UTC (resets 2026-10-15 08:00
UTC); a unit like D4b1 costs about 1 % of the weekly limit or less. Every agent runs on the session's own model (Opus) from now on (the user, 2026-10-12 00:20).

**If a unit's agent was cut off:** check its record (`ext-<unit>-record.md`; absent = not finished),
`git --no-optional-locks status -- claude/port` is not useful (untracked tree); instead run
`build.cmd checked`, `test.cmd checked` and `tests/harness/ext_g1.py check`. If anything is red, fix it
first (P0 and G-1 must stay green), then restart the unit from its brief with "continue the partly done
work; read the files already changed".

## How the work is organised (keep doing it this way)

* The orchestrator (main session) writes a brief per phase in `docs/verify/BRIEF-<phase>.md`, launches
  agents in the background with exclusive file ownership, serialises builds (one builder at a time), and
  records decisions in `verify/ext-d1-decisions.md`-style files. Agents report back; the orchestrator
  verifies, resolves conflicts (recorded), updates STATUS.md, writes or has written the gate record
  `ext-<phase>-acceptance.md`.
* Pattern per phase: design (done in D1) → implement (one agent per unit) → independent review where
  the gate asks → records (DESIGN, FIDELITY, RUNNING, FEATURES) by a docs-only agent.
* Agents that finished can be resumed with SendMessage (they keep their context); a fresh agent is
  cheaper when the earlier one's context is large.

## Standing rules and pitfalls

* **User directions** (STATUS "User directions"): never lower the agents' AI model to save budget (2026-10-12 00:20; every agent on the session's own model, Opus); D4a ran on Sonnet before that direction, so it gets a read-only Opus review of its DOS transcriptions against the listing, findings fixed on Opus; autonomous continuation; Asan builds/tests only once at
  the end of the whole queue (2026-10-10 21:20); no periodic progress reports (stopped 2026-10-10 16:22),
  but answer when asked; hand-off at 1 % usage left; the zoom levels -1, 0, +1; the game screen follows
  the host (phase G); `stretch` removed.
* **Hash checks** at session start and end, without project scripts (base 10, extension 10). E2 used a
  scratchpad script (`hashcheck.ps1`, gone with the session): hash every file of
  `C:\Projects\Civ1RE\original\CIVWIN` (38, against `claude/docs/original-hashes-before.txt`) and of
  `C:\Projects\Civ1RE\dos` (176, against `claude/port/docs/dos/dos-hashes.txt`), compare attributes and
  LastWriteTimeUtc with `docs/hashes/20261010T170031Z-before.txt` and `20261010T170101Z-dos-before.txt`,
  write `docs/hashes/<UTC>-before|after.txt` and `<UTC>-dos-before|after.txt`. E2's start: both OK
  (`hashes/20261011T055556Z-*`); interim check 23:43 UTC both OK (`hashes/20261011T234307Z-*`); interim check 2026-10-12 12:03 UTC both OK
  (CIVWIN 38/38, dos 176/176, no metadata difference; `hashes/20261012T120301Z-*`); **E2's session-end check
  2026-10-12 12:31 UTC both OK** (`hashes/20261012T123144Z-*`). The next session runs its own start check
  (rewrite the script as described above if the scratchpad is gone).
* Build and test: `cmd /c C:\Projects\Civ1RE\claude\port\build.cmd checked` then `test.cmd checked`
  (about 10 min), then `C:/Python314/python -B C:/Projects/Civ1RE/claude/port/tests/harness/ext_g1.py check`
  (EXT_G1_OK 77 runs); Release `build.cmd` / `test.cmd`. test.cmd now needs `build\dosdata`.
* Python: `C:/Python314/python -B`, never `-I` (capstone is in the user site-packages).
* Bash on this host drops backslashes in heredocs and sed: write files with backslashes via the Write or
  Edit tool (memory `bash-heredoc-backslashes`).
* Another chat of the user may edit STATUS.md (it did at 07:50 for G): always read-modify-write it fresh.
* **DOS-PROFILE.md is an input of `gen/obs_tables.py`:** every Windows address `SSSS:OOOO` written there
  that decodes to a call of a probe key becomes an observer call-site row, and `test.cmd`'s
  `obs_tables.py --check` then fails (2026-10-12 06:10 UTC: a docs note naming two SetCivFont call sites
  broke D4b1's first test run; reworded). Docs agents must not write new call addresses there unless the
  tables are meant to change (then regenerate and re-run the whole cycle); run `gen/obs_tables.py --check`
  after any DOS-PROFILE.md edit.
* No DOS bytes in the repository or binaries (`gen/dos/nodos.py check`); never write `dos/` or
  `build/dosdata`; never run a DOS program on the host (DOS oracle only under DOSBox Pure, grant in
  extension 2.1, not used yet).
* Independence: never read the main project's excluded paths (`docs/verify/BRIEF-d0.md` lists them);
  ignore AGENTS.md's GFX/DOS/Modern/Mac/SNES sections.
* No git writes (the tree is untracked; no commit without the user's request).

## Pending for the user (do not block on them)

* 2026-10-12 about 11:35 UTC the user checked the DOS intro and graphics switching during it on the
  Checked build of 11:01 UTC: "Visual inspection passed and accepted" (STATUS "User directions"). When the
  D4b docs agent adds D4b2b1's intro items to `manual-checklist-ext.md`, enter them as passed with this
  date; do not ask the user to repeat them. About 11:40 UTC the user also checked and accepted the DOS
  title box (D4b2b2, same build): enter D4b2b2's title-box items as passed too.

* `manual-checklist-ext.md`: 12 checks (D3 5, D4 3, D5 1, D6 1, M 2), all pending: the Ctrl/Shift hold
  rule (K3), the 4:3 default for 320x200 frames (X3), a click ends the DOS intro (C.20-2), Birth's DOS
  setup page shown early (C.20-3), a press outside the map view recentres (C6), zoom -1 at odd factors
  (C1), the DOS menu-bar text at 1x (X4), Locate at the next start (RV1-6), one refusal message (RV1-8).
* Base-track items still pending (STATUS "Decisions awaiting the user"): civ64 visual confirmation of
  phase 7, selector reuse B2.

## Next steps after D3

1. (done) D3.
2. (done) M. If the user asks, repeat the agent UI check of M (it was interrupted).
   Then unit **M+W** (the user, 2026-10-11 about 18:35, low priority, after all M checks): a system-menu
   option to disable mouse-wheel zoom (checkable item, remembered in the settings file; chords, menu items and
   `--zoom` unaffected; Win32-headless test; P0 unchanged). See STATUS "User directions".
   The same unit (renamed **LP**, low priority) also sets the application version to 1.0 (VERSIONINFO in
   `win64/civ64.rc`), the host window title to "Sid Meier's Civilization 64bit" and the About box title to
   "About Sid Meier's Civilization 64bit v1.0" (the user, 2026-10-11 about 20:15 and 22:00; the 22:00 titles supersede). Brief: `verify/BRIEF-m.md`, "Unit LP".
3. D4: D4a's fixes are done and green (`ext-D4a-record.md` "Review fixes (2026-10-12)"); its records are applied to
   DESIGN 12.7 "As implemented (D4a)", FIDELITY F144, RUNNING and the checklist. Still to place (by a docs agent):
   DOS-PROFILE.md 1.1..1.5 (rows 6, 24, 119 name no call site; exit probes of rows 5 (11E0:01AD's return of
   BeginWorldCreation) and 9 (DestroySequencePlayer from 11E0:01E3, entry); row 98 ends at CloseReportScreen's entry)
   and font rows F8 (city labels and size digits font 1, inferred, L23), F9/F10 (leader-font table 8 + b, 10 -> 3,
   O6:17EA..181E); draft B notes 4.2 (span column per machine, F3), 9.2 (multi-row pops), 7.3/9.1 (row-number keys).
   (Done 05:06 UTC by a docs agent: DOS-PROFILE.md rows 5, 6, 9, 24, 98, 119, 2.4 F7..F10 and Open 16 (F1
   gap for D7); draft B 4.2, 7.2 (S4), 7.3 (S2, S3), 7.5 (S5), 8.2, 9.1, 9.2 (S1); `pdos_scene_check` 1075
   PASS with no `info:` lines, NODOS_OK.) The second review's fixes are done (04:48 UTC).
   Then D4b in units per `verify/BRIEF-d4.md` "D4b split": D4b1 (clock, engine) **done 07:00 UTC**, green
   (`ext-D4b1-record.md`, with a section for D4b2/D4b3 on how to plug programs in); D4b2a (the intro
   program, pure, not wired) **done 08:40 UTC**, green (`ext-D4b2a-record.md`, with a section for D4b2b);
   D4b2b split in two (BRIEF "D4b split"): D4b2b1 (`pdos_seq`, wiring into `pdos_profile.c`, `timeline.log`,
   first `ext_timeline.py` runs) **done 10:20 UTC**, green (`ext-D4b2b1-record.md`; the DOS view shows the
   DOS intro, then holds its last screen); D4b2b2 **done 12:00 UTC**, green (`ext-D4b2b2-record.md`; S3 still
   open for the first unit with a drawing `leave`; D4c and D4b3 notes in its record): D4b2b2 (title box, pointer rule, S3 resolved before the first
   macro with a drawing `leave`, S6, S7, S9, the rest of `ext_timeline.py`, goldens), D4b3 (Birth); a docs agent then applies the
   D4b records (D4b1's: DESIGN 12.8, FIDELITY model labels, RUNNING `test_timeline` outputs and the `seq`
   counter). Then D4c per `verify/BRIEF-d4.md`
   (credits, intro, title, Birth, pointer; drafts B and C), D5 (setup and title branches), D6 (play,
   class A, DOS map rules, M2 mirror check), D7 (remaining N and R scenes), D8 (FEATURES DOS columns,
   records), X9 (final adversarial audit, base suite, hashes, final report), then the one Asan pass of
   the whole queue.
4. DOS-oracle comparisons (7.9) are granted and optional: DOSBox Pure Standalone, packages under
   `claude/port/build/dos-oracle/`, rules in extension 2.1.

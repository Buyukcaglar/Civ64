# Extension phase D4, unit D4b2b1 (the DOS scene sequencer and its wiring) - record

Unit D4b2b1 of the "civ64" extension: area C's scene sequencer `pdos_seq` and its wiring into the DOS
profile, so that the DOS view shows the DOS intro of D4b2a on the game's virtual time. Design:
[verify/ext-d1-draft-C.md](verify/ext-d1-draft-C.md) (revision 3) C.11.1..C.11.4, C.11.6, C.5.3, C.5.6,
C.6.1, C.6.4, C.6.6, C.15.3; draft B 2.1 (the callback order). Brief: [verify/BRIEF-d4.md](verify/BRIEF-d4.md),
"D4b split" (the D4b2b1 bullet). Engine and program: [ext-D4b1-record.md](ext-D4b1-record.md),
[ext-D4b2a-record.md](ext-D4b2a-record.md). User direction of 2026-10-12 07:12 (STATUS "User directions"):
native pace from one t0, no time scaling between the intros, both timelines advance at every tick, a switch
shows the other profile at the same virtual time, a skip ends both (T5), a Windows title choice during the
DOS intro abandons it with finish. Session D4b2b1, 2026-10-12.

Labels: **compiled** (the three language checks and `/W4 /WX`), **headless** (unit tests and harness runs),
**DOS listing (model)** for the frames of the intro (the clock model of C.4; no DOS-oracle comparison). No
DOS program was executed; nothing was written to `C:\Projects\Civ1RE\dos`, `build/dosdata` or
`C:\Projects\Civ1RE\original`; no UI was shown; no DOS byte is in the repository or a binary (NODOS_OK). No
git command that writes was run. Asan was not built or run. `present/obs_tables.c/.h`, `gen/obs_tables.py`
and DOS-PROFILE.md were not edited: every probe and call site needed was already in the generated tables.

## Status

DONE. The DOS profile now runs its intro timeline from the core's intro start and shows it as its N frame;
after the hand-over it holds the last intro screen until the core's next scene (the title box is
D4b2b2's). The final cycle is in "Results".

## What was built

| File | Contents |
|---|---|
| `present/dos/pdos_seq.h/.c` (new) | the flow state `PdosCore` of C.11.1 (the fields the intro needs), `pdos_seq_reset`, `_on_event`, `_on_probe`, `_advance` (C.3), `pdos_seq_view_key` (C.6.4 source 2's entry point for D4c's filter), `pdos_seq_set_log` (the step log sink, kept across resets), `pdos_seq_core`, `_intro`, `_intro_view`, `_config_errors`; the call-site rows of C.11.2 resolved at reset with `obs_callsite`; the intro timeline (`PdosTl`, `PdosTlSession`, `PdosIntroCtx`, static) on `pdos_mn()`; the scene-stack listener (`pdos_scene_listen`); C.11.6 with `PDOS_DIAG_SEQ` |
| `present/dos/pdos_profile.c` (changed) | the calls of `pdos_seq_*` at the places draft B 2.1 marked (below) |
| `gen/dos/registry.py` (changed) | `pdos_seq.c` joins `OBSERVER_FILES` (it includes `observe.h` and `w16_obs.h`; the include rule) |
| `tests/headless/harness.c`, `harness_main.c` (changed) | the headless `timeline.log` writer (C.15.3) and its documentation |
| `tests/test_pdos_seq.c` (new) | the unit test of the sequencer (43 checks; test.cmd's generic loop builds and runs it) |
| `tests/harness/ext_timeline.py` (new), `test.cmd` (changed) | the C.15.3 `start` run's frame and t0 checks and the `--switch-every 997` T2 run; in `test.cmd checked` after `ext_frames.py` |

### Probes used (C.11.2; every pair a row of `OBS_CALLSITES[]`, resolved at reset)

| Row (`pdos_seq.c`) | Probe, phase | Call site (ra) | Use |
|---|---|---|---|
| - | RunIntroAndTitleMenu 11E0:0000 entry, exit (any caller) | - | BOOT; at the exit PLAY and the intro view ends (also through the scene listener: row 1 popped) |
| `SR_MOVIE_DLG` | GR_DialogOpen 1098:124F exit | 11E0:0044 (call 11E0:003F) | `movie_wnd` = AX (`w16q_ret_ax`) |
| `SR_INTRO_T0` | CreateSequencePlayer 10B0:008A entry | 11E0:00A5 (call 11E0:00A0) | INTRO; the intro starts at t0 = the probe's time (C.6.1, T1) |
| `SR_SKIP_INTRO` | SetGameCursor 1098:096C entry | 11E0:08D7 (call 11E0:08D2) | the core's intro skip: `pdos_tl_key(intro, t, PDOS_KEY_ANY)` (C.6.4 source 1) |
| `SR_TITLE` | GR_DialogOpen exit | 11E0:06C5 (call 11E0:06C0) | TITLE |
| `SR_MENUZ_TITLE` | MenuZ 1220:0156 entry, exit | 11E0:0729 (call 11E0:0724) | `mz_active`, `mz_kind` TITLE; at the exit `title_choice` = AX and the intro is abandoned with finish (C.6.6) |
| `SR_MENUZ_SETUP` | MenuZ entry | 10E8:0528 (call 10E8:0523) | `mz_kind` SETUP; any other MenuZ is OTHER |
| `SR_LOAD`, `SR_CUSTOM`, `SR_HOF` | LoadGameFromFileDialog 1130:000E, CustomizeWorldDialog 1108:0243, ShowHallOfFame 1080:0119 entry, exit | 11E0:0807, 11E0:0826, 11E0:0847 | LOAD, CUSTOM, HOF; TITLE at their exits |
| `SR_OUTRO` | SeekSequence 10B0:005B entry | 11E0:0889 (call 11E0:0884) | OUTRO (nothing new in the DOS view, C.11.3) |
| `SR_BIRTH` | SeekSequence entry | 11E0:01AA (call 11E0:01A5) | BIRTH; the intro is abandoned with finish (C.6.6) and the intro view ends |
| `SR_MOVIE_GONE`, `SR_BIRTH_END` | DestroySequencePlayer 10B0:0287 entry | 11E0:0114, 11E0:01E8 | resolved, not acted on (Birth's end is D4b3's) |
| - | BeginWorldCreation 1108:01BC entry, exit | - | `world_running`, `world_done` |
| `SR_SETUP` | RunNewGameSetup 10E8:0000 entry, exit | 11E0:020A (call 11E0:0205) | SETUP (the intro view ends), PLAY at the exit |
| `SR_LOAD_PLAY` | GR_DialogClose 1098:1612 entry | 11E0:0217 (call 11E0:0212) | PLAY (the intro view ends) |

A call-site filter is a test of `ObsProbe.site` against the resolved row (C.11.2, RV2-4); under
`CIV_OBSERVER 0` (no observer table) the full return address is compared, as `pdos_scene.c` does. Every
action at an exit carries its `OBS_AT_EXIT` marker (obs_lint: every key has the X phase).

### The wiring order (draft B 2.1, C.3)

* `reset`: ... the scene stack's reset, the cursor's, then `pdos_seq_reset()` (the timelines idle and
  bound, the core state BOOT, the rows resolved, the scene listener registered), then the cursor update.
* `on_event`: 1. `pdos_scene_on_event` (window-bound rows pop), **2. `pdos_seq_on_event`** (the timelines
  reach the event's time, C.5.3), 3. `pdos_shadow_on_event`, then the window updates and the cursor.
* `on_probe`, entry: 1. `pdos_scene_on_probe` (push), **2. `pdos_seq_on_probe`** (the timelines reach the
  probe's time, then the flow), 3. font map, 4. shadow, the play palette's cycle step.
* `on_probe`, exit: **1. `pdos_seq_advance(p->t_us)`** (the timelines reach the probe's time first;
  RV2-12, Choice B24), 2. shadow, 5. font map, the play palette, 6. `pdos_scene_on_probe` (pop),
  **7. `pdos_seq_on_probe`** (the flow at the exit; its own run to the same time is a no-op).
* `advance`: **1. `pdos_seq_advance(now)`**, 2. the cursor update. **The hidden-profile rule (C.5.6)**:
  `present_tick` advances every registered profile at every tick, visible or not, and `advance` calls the
  sequencer unconditionally, so the DOS timelines are current at every tick and a switch shows the DOS view
  at the same virtual time (T2). Tested through the present layer (`test_pdos_seq`, the Windows profile
  visible) and in the harness (`ext_timeline.py` switch run).

### The DOS view and the interim hold

* The N frame is chosen by B's `pdos_compose_kind` (6.3): a ready N row on top of the scene stack. From the
  intro's start until the core's next scene (Birth's SeekSequence ra 11E0:01AA, RunNewGameSetup ra
  11E0:020A, GR_DialogClose ra 11E0:0217, RunIntroAndTitleMenu's exit) the sequencer marks scene rows
  **1** (the intro), **25** (dialog 148, the movie window: GR_DialogOpen ra 11E0:0044 at 11E0:003F; a
  window-bound row stays on the stack above row 1 until its window goes) and **2** (the title menu, dialog
  139) ready (`pdos_scene_set_ready`). The DOS profile then presents page 0 of `pdos_mn()`: the intro at the
  tick's time.
* **Interim hold (known gap for D4b2b2).** After the hand-over (frame 4,766, `pdos_intro_at_title`) the
  timeline is DONE and page 0 keeps the logo on black: the view holds it until the core's next scene,
  where DOS shows its title box (C.7). After an abandon with finish (the core's title choice, C.6.6) the
  view likewise holds the last DOS screen (the logo on black after a dissolve, the frozen pan after a
  stop) instead of the title box with the chosen row (`PdosCore.title_choice` is recorded for it). Back at
  the title from Load, Customize or the Hall of Fame (their rows are not ready: the A frame while they are
  on top) the held screen shows again without the box (C.7.4's redraw is D4b2b2's).
* Scenes with no DOS program yet (Birth and later) keep D4a's behaviour: their rows are not ready, the A
  frame (the core frame) is presented.

### The headless `timeline.log` (C.15.3)

Written by `tests/headless/harness.c` to `<outdir>/timeline.log` **by default whenever the DOS profile is
registered** (`--dos-data` with a working store; no option). Lines:

```
timeline virtual_us 0
step <seq> <op> frame F us U dos ADDR arg A      (each step of pdos_seq's timelines; seq 1 = the intro)
probe <name> enter|exit ra SSSS:OOOO us U        (CreateSequencePlayer, SetGameCursor, MenuZ, SeekSequence,
                                                  DestroySequencePlayer, RunNewGameSetup at a call-site row;
                                                  RunIntroAndTitleMenu)
end steps N probes M
```

The step lines come from `pdos_seq_set_log`; the probe lines from a listener of the harness's own,
registered after the profiles' (`obs_listen`), so they are an independent record of the probe times. The
file is not run.log, events.log or presented.log (P0 compares those).

## Tests

**`tests/test_pdos_seq.c`** (43 checks; synthetic probes of `tests/pdos_obs.h` through the profile's own
callbacks; the pictures and CREDITS.TXT from `build\dosdata` through E's store; the reference is the
intro driven directly with `pdos_intro_*` on a machine of its own, compared by step logs and by pages 0..3
and the DAC):

* **Start**: the call-site rows all resolve; CreateSequencePlayer from another call site starts nothing;
  before t0 the A frame; at the probe with ra 11E0:00A5 the intro runs from t0 (grid, `start` step at t0,
  frame 0, sequence 1), INTRO, rows 1 and 2 ready, the N frame; the movie window (row 25, dialog 148)
  on top keeps the N frame; 30 s of 16,667 us ticks equal the reference (log and machine at every sample).
* **Hidden profile** (C.5.6): through `present_tick_at` with the Windows profile visible, the DOS intro
  reaches every tick's time and equals the reference.
* **The skip source** (C.6.4 source 1): SetGameCursor ra 11E0:094E is no intro key; ra 11E0:08D7 at 10 s
  acts as `pdos_tl_key(PDOS_KEY_ANY)` (equal to the reference); the pan ends and the dissolve runs at 11 s.
* **Abandon with finish on the core's title exit** (C.6.6): the MenuZ exit with ra 11E0:0729 in the
  dissolve: tail, show, title, finish; page 0 = page 1 (the logo on black); the view holds it (N frame);
  nothing changes afterwards. In the pan: a plain stop (no tail, no show), the pan and slot 1 frozen. A
  MenuZ exit with ra 10E8:0528 finishes nothing.
* **Abandon with finish on Birth's start**: the outro (ra 11E0:0889) changes nothing; SeekSequence ra
  11E0:01AA in the dissolve finishes it (page 0 = page 1), BIRTH, the view ends (rows 1, 2, 25 not ready,
  the A frame); in the pan a plain stop.
* **Events and probes after a tick at the same microsecond** (C.5.3): at a key-test instant of loop A
  (column 150) and of loop B (column 100), a tick, an event and the core's skip at one microsecond give the
  same step log and machine as the skip alone, and as the reference with the key at that microsecond.
* **Source 2's entry point**: `pdos_seq_view_key('n')` in loop B preselects title item 0 at the hand-over;
  after the program's end a view key goes nowhere.
* **Order**: the title dialog (row 2) on top keeps the N frame; an exit probe's timelines reach its time
  (TITLE at GR_DialogOpen's exit with ra 11E0:06C5).
* **C.11.6**: a core skip with no intro, a MenuZ of unknown kind during the core's intro, a second start
  while the intro runs, RunIntroAndTitleMenu's exit and the setup's entry while it runs: each counts
  `PDOS_DIAG_SEQ` and abandons (a second start restarts at the new t0; a start after an abandon counts
  nothing).
* `pdos_rand_calls()` is unchanged over the whole test (C.15.1 item 7).

**`tests/harness/ext_timeline.py`** (`test.cmd checked`; outputs `build/harness/Checked/timeline/<run>`):
two headless runs of S1 (no input, 75,000 ms: the intro needs 68.0 s), `--dos-data build\dosdata
--profile-samples 100 --presented 1`: `start` (`--graphics dos`) and `switch` (`--switch-every 997`).
Checks: one intro start, t0 = 50 us = the logged probe time of CreateSequencePlayer ra 11E0:00A5; the
frames of C.6.3 exactly (lines 1..24 on 54..3,729, clears 299, 972, 2,259, 2,663, 3,852, loop A 1,952,
loop B 3,912, strips 0 and 79 on 4,040 and 4,119, 80 strips, the dissolve 4,620, show, title and end
4,766), each at t0 + `pdos_frame_us(F)`, no key read, abandon or finish; the DOS view shows the intro (every
sample before the hand-over differs from the Windows frame, every tick show after t0 is the 320x200 N frame)
and holds one frame after it; the switch run's DOS samples equal the `start` run's (T2), at least one
switch, none refused; both runs' core outputs equal (P0). The other C.15.3 runs (a base `key` at 10 s,
`birth`, host input, `burn`) and the model goldens of DOS frame hashes (C-9) are left to D4b2b2 and D4b3.

Development runs (headless, not part of the suite): S1 to 75 s: 1,496 steps, the hand-over at 68,000,057 us
(frame 4,766), `seq 0` in presentation-diag.log, every tick show the N frame; S1 with a scripted key at
10 s: the core's skip probe at 10,162,250 us, loop A's end at frame 716 (10,215,746 us), the dissolve, show
and hand-over at frame 862 (12,298,835 us), the core's title MenuZ at 11,919,900 us (the core at its title
before the DOS hand-over: C.7.1's T4 case).

| Test | Checked | CheckedNoObs | Release |
|---|---|---|---|
| `test_pdos_seq` (new) | 43 | 43 | 43 |
| `ext_timeline.py` (new) | 8 checks, EXT_TIMELINE_OK | - | - |
| `test_timeline` | 123 (unchanged) | 123 | 123 |
| `test_pdos_profile` | 38 (unchanged) | 36 | 38 |

### DOS frame expectations changed

None. `ext_frames.py` is unchanged and green: its sample lines stay identical across A, A', B and C (every
profile advances at every tick), and its dump check still finds a 24-bit frame (the start-up's view show
of the A frame at virtual 0, before t0 = 50 us) besides the 8-bit N frames that are now the intro's.
`test_pdos_profile` (38) and the other `test_pdos_*` are unchanged. No core frame, checkpoint, events.log
or P0 expectation was touched.

## Results

The eight steps of the brief, 2026-10-12, in one run; logs `build/d4b2b1-<n>-<step>.log`, status
`build/d4b2b1-status.txt` (ends `ALL_GREEN`); no Asan.

| Step | Result |
|---|---|
| 1 `build.cmd checked` | BUILD_OK, 198 s (271 portable sources: C11 + C17 `/W4 /WX` + clang C99 parse) |
| 2 `test.cmd checked` | TESTS_OK, 1972 s: `test_pdos_seq` 43, `test_timeline` 123, `test_pdos_profile` 38, REGISTRY_OK, NODOS_OK, P4_TESTS_OK, OBS_TABLES_OK, OBS_LINT_OK, `pdos_scene_check` 1075, P0_OK 279, EXT_FRAMES_OK, EXT_TIMELINE_OK, EXT_ADAPT_OK 20, MIRROR_OK 29, ZOOM_OK 32 |
| 3 `ext_g1.py check` | EXT_G1_OK runs 77 |
| 4 `build.cmd checked noobs` | BUILD_OK, 193 s |
| 5 `test.cmd checked noobs` | TESTS_OK, 742 s: `test_pdos_seq` 43, `test_timeline` 123, `test_pdos_profile` 36, NODOS_OK, OBS_TABLES_OK, OBS_LINT_OK, `pdos_scene_check` 1075, P0_OK 56 |
| 6 `ext_g1.py check --variant CheckedNoObs` | EXT_G1_OK runs 77 |
| 7 `build.cmd` (Release) | BUILD_OK, 189 s |
| 8 `test.cmd` (Release) | TESTS_OK, 376 s: `test_pdos_seq` 43, `test_timeline` 123, `test_pdos_profile` 38, NODOS_OK, OBS_TABLES_OK, OBS_LINT_OK, `pdos_scene_check` 1075 |

`ext_timeline.py` in step 2: t0 = 50 us = the probe time; every C.6.3 frame exact (hand-over 68.000007 s
after t0); 679 of 679 DOS samples before the hand-over differ from the Windows frame, 1,189 of 1,189 tick
shows after t0 are the 320x200 N frame, the 70 samples after it hold one frame; the switch run's 749 DOS
samples equal the `start` run's, 75 switches, 0 refused; equal core outputs (446 lines). `timeline.log`:
1,496 steps, 3 probe lines.

**P0.** No core value changed: P0_OK 279 (Checked, including V1 `--graphics dos` and V2 switching with the
intro now drawn) and 56 (CheckedNoObs), EXT_G1_OK on both observer variants, EXT_FRAMES_OK (sample lines of
A, A', B, C identical), EXT_ADAPT_OK. `pdos_seq.c` reads the emulation only through `w16q_ret_ax` under
`CIV_OBSERVER` inside the observer's guard, posts nothing, never reads `g_randSeed` and draws no random
number (OBS_LINT_OK, the include rule of `registry.py check`, `pdos_rand_calls` unchanged).

## Deviations from drafts B and C

Format: section; what; why.

1. **C.11.3 / B 6.3 (which rows the intro shows on).** Besides rows 1 and 2 the sequencer marks scene row
   25 (dialog 148, the picture dialog) ready while the intro view is on. Why: the core opens the movie
   window at 11E0:003F (GR_DialogOpen ra 11E0:0044, dialog 148) before CreateSequencePlayer, and B's stack
   keeps a window-bound row until its window goes (`pdos_scene.c`), so row 25 is the topmost N row for the
   whole intro and title; without it B would present the A frame. The readiness ends with the intro view,
   so later uses of dialog 148 (the Birth movie's window is the same one) stay D4a's A frame.
2. **C.6.6 bullet 2 (the title box with the chosen row).** Interim: abandon with finish, then the view holds
   the last DOS screen; the box is D4b2b2's (C.7). The choice is recorded (`title_choice`). A title exit after
   the hand-over finishes the DONE timeline (a stop; its slots are already stopped).
3. **C.11.2 (rows).** Only the rows the intro needs are resolved (the table above). Not yet: IsKeyPending
   ra 1220:0AA5 (`mz_ready`), OBS_WND_CREATE / OBS_CTL_CHECK / OBS_WND_ENABLE on the MenuZ children
   (`mz_sel`, `mz_items`, `mz_dlg`), GR_DialogOpen 144/151, RunTextInputDialog ra 10E8:056F (`setup_step`,
   D5), SetGameCursor ra 11E0:094E (Birth's skip, D4b3), DrawUnitStackList (P26), OBS_FOCUS / OBS_EDIT,
   OBS_CURSOR (C.11.5). Those `PdosCore` fields keep their reset values (-1 / 0).
4. **C.11.2 (an unresolved pair).** "A Checked fault" becomes a counted configuration error
   (`PDOS_DIAG_SEQ`, `pdos_seq_config_errors()`; the row never matches), as `pdos_scene_reset` does. Why:
   `present/` behaves the same in every variant (O1, no `#if CIV_CHECKED`); `test_pdos_seq` asserts 0.
5. **C.11.6 (cases).** Implemented: a core skip with no intro started (counted only), a MenuZ of unknown
   kind while the core is in its intro and the DOS intro runs, a second CreateSequencePlayer while the intro
   runs (counted, abandoned and **restarted** at the new t0: the probe is T1 again), RunIntroAndTitleMenu's
   exit, the setup's entry or the Load path's PLAY while the intro runs. Each abandon lets the core-driven
   scene draw (the intro view ends) except the restart.
6. **C.11.1 (API).** `pdos_seq_pointer_hidden` is not provided (C.11.5 is D4b2b2's); `pdos_seq_reset` does
   not call `pdos_adapt_reset` / `pdos_pend_cancel` (D4c's, not built). Added: `pdos_seq_view_key` (source
   2's entry point), `pdos_seq_set_log`, `pdos_seq_intro`, `pdos_seq_intro_view`, `pdos_seq_config_errors`.
7. **C.11.1 (`pdos_seq_on_event`).** Runs the timelines to the event's time (C.5.3) and clears `movie_wnd`
   when its window is destroyed; the MenuZ child events are D4b2b2's.
8. **C.15.3 (`timeline.log`).** Written by default whenever the DOS profile is registered (no option);
   `<seq>` is the `PdosSeq` number (as D4b1's `timeline-test-steps.txt`); each step line ends with ` arg A`;
   `probe` lines from a harness listener give the probe times the t0 check compares with; a first line
   `timeline virtual_us` and a last `end steps N probes M`.
9. **C.15.3 (`start`).** The run lasts 75,000 ms (scenarios.py's S1 lasts 30,000) so that the intro reaches
   its hand-over at 68.0 s; its no-input script is `build/timeline/scripts/start.script`. The DOS frame-hash
   goldens of the row (C-9) are D4b2b2's.
10. **C.15.3 (`--switch-every 997`).** The switch run starts in the Windows profile (as ext_frames.py's B);
    its `dos` sample field is compared with the `start` run's (the Windows field and the A/A'/B/C identity
    are ext_frames.py's).

## What D4b2b2 and D4b3 must know

* **One live timeline today.** `run_all` (`pdos_seq.c`) runs only the intro; `unexpected` and `next_scene`
  abandon only the intro. A new timeline (the title box, Birth) must be bound with `pdos_tl_set_log(tl,
  g_log, g_log_ctx)` (so it reaches `timeline.log`), run in `run_all` before anything is applied (C.5.3),
  and be handled in `unexpected` / `next_scene`.
* **The title box (D4b2b2).** Replace the hold after the hand-over: continue the intro timeline into the
  title box (D4b2a's "Taking over at the title box"), and on the MenuZ exit with ra 11E0:0729 show the box
  with `g_core.title_choice` (set before `intro_finish`) instead of the plain hold; the view rule (rows 1,
  25, 2 ready while `g_view`) stays. C.7.4's back-to-menu redraw: the Load/Customize/HOF exits set TITLE.
* **The pointer rule (C.11.5).** Add `pdos_seq_pointer_hidden()` (the intro timeline running:
  `pdos_tl_running(&g_intro)`, and Birth's) and call `pdos_cursor_set_hidden_rule`.
* **Birth (D4b3).** `SR_BIRTH` (SeekSequence ra 11E0:01AA) already finishes the intro and ends the intro
  view: start DOS Birth there at the probe's time (its T1) and make its row (9) ready; `SR_BIRTH_END`
  (DestroySequencePlayer ra 11E0:01E8) is resolved and unused; add Birth's skip (SetGameCursor ra
  11E0:094E, an `OBS_CALLSITES` row) as a row. `next_scene` treats a running intro at the setup as
  unexpected; extend it for Birth (C.8.7's T4 page).
* **t0 = 50 us.** In the base harness runs the core creates the intro movie at 50 us of virtual time: the
  intro starts before the first tick, so the DOS profile's frames from the first tick are the intro's.
* **ext_timeline.py** has the `start` and switch runs; add the `start` with a base `key` line at 10 s, the
  `birth` runs (and their switch variant), the host-input run, the `burn` run and the C-9 goldens.

## For the records

Entries for the documents this unit does not edit.

* **DESIGN.md 12.8 (area C)**: D4b2b1 delivered `pdos_seq.h/.c`: the flow state of C.11.1 kept from the
  probes of C.11.2 (call-site rows resolved at reset; unresolved ones counted, never matched), the intro
  timeline on `pdos_mn()` started at CreateSequencePlayer ra 11E0:00A5 (t0), the core's intro skip
  (SetGameCursor ra 11E0:08D7) as the DOS key, `pdos_seq_view_key` as source 2's entry point for D4c, abandon
  with finish at the MenuZ exit ra 11E0:0729 and at Birth's SeekSequence ra 11E0:01AA, C.11.6 with
  `PDOS_DIAG_SEQ`; wired into `pdos_profile.c` at draft B 2.1's places (reset; event step 2; entry step 2;
  exit steps 1 and 7; advance step 1, every tick, visible or not). While the intro view is on, scene rows
  1, 25 (dialog 148) and 2 are ready N rows, so the N frame is the intro; after its hand-over the last
  screen is held until the core's next scene (the title box is D4b2b2's).
* **FIDELITY.md**: the DOS profile's intro runs on the game's virtual time from the core's intro start
  (t0, the creation of the intro movie; 50 us after the start in the headless runs), at the DOS model's
  native pace (no time scaling between the DOS and Windows intros), whether the DOS profile is visible or
  not; a switch shows it at the same virtual time (T2, `ext_timeline.py`: equal DOS samples with switching
  every 997 ms). The core's intro skip is the DOS key (T5); a title choice made while the DOS intro runs
  ends it with finish (the dissolve completes at once; in the pan it freezes). Known gap until D4b2b2: after
  the intro (or a finish) the DOS view holds the last DOS screen; DOS shows the title box there. Labels:
  "DOS listing (model)" for the intro's frames (C.6.3, checked in the harness); no DOS-oracle comparison.
* **STATUS.md**: D4b2b1 done: `pdos_seq` and its wiring; the DOS view shows the DOS intro (`--graphics dos`
  or after a switch during the intro) and then holds its last screen until the core's next scene;
  `test_pdos_seq` (43 checks in Checked, CheckedNoObs and Release) and `ext_timeline.py` (EXT_TIMELINE_OK, in
  `test.cmd checked`); no core value changed (P0_OK, EXT_G1_OK); the 8-step cycle green (see Results).
* **RUNNING.md**: the headless harness writes `<outdir>/timeline.log` whenever the DOS profile is registered
  (`--dos-data` with a working store): `step <seq> <op> frame F us U dos ADDR arg A` per DOS step and `probe
  <name> enter|exit ra SSSS:OOOO us U` per hit of the sequencer's probes (no option). `test.cmd checked` runs
  `tests/harness/ext_timeline.py` (two 75 s runs, about 15 s; outputs `build/harness/Checked/timeline/`).
  `test_pdos_seq.exe <gamedata> <outdir>` reads the DOS copy `<gamedata>\..\dosdata` (it fails when the copy
  does not open). `presentation-diag.log`'s `seq` counter now also counts the sequencer's unexpected orders
  (C.11.6) and unresolved call-site rows.
* **FEATURES.md**: the DOS graphics profile shows the DOS intro (credits over the panorama, the logo
  reveal and its dissolve) at the game's pace with `--graphics dos`, or from the moment the player switches
  with Ctrl+Shift+Backspace during the intro; afterwards its last screen stays until the game moves on (the
  DOS title box comes later).
* **manual-checklist-ext.md** (D4 section, left pending for the user): the DOS intro is now visible with
  `--graphics dos` or after Ctrl+Shift+Backspace during the intro: (1) credits and pan from the start,
  the logo, the reveal and the dissolve to the logo on black at about 68 s; (2) switching back and forth
  during the intro shows each intro at the same moment, neither restarts nor speeds up; (3) a key during
  the intro ends both intros (the DOS one through its dissolve); (4) choosing a title item in the Windows
  view while the DOS intro still runs ends the DOS intro (at once in the dissolve); (5) after the intro the
  DOS view keeps the logo on black until the game moves on (no DOS title box yet: D4b2b2).
* **DOS-PROFILE.md**: nothing (no row, adapter or call site changed).

# Extension phase D4, unit D4b4 (Birth auto-continue) - record

Unit D4b4 of the "civ64" extension implements the user's direction of 2026-10-15 about 10:00 UTC
(STATUS.md "User directions", session E3): when the DOS profile is the visible one and its Birth ends
before the Windows Birth movie, the game continues to the setup screens at once instead of waiting on the
black screen. Screen-by-screen synchronisation of the two Births is a separate backlog item, not part of
this unit.

Brief: [verify/BRIEF-d4.md](verify/BRIEF-d4.md), "D4b4: Birth auto-continue". Preceding unit:
[ext-D4b3-record.md](ext-D4b3-record.md) ("What D4b4 must know"). Design areas: DESIGN.md 12.5 (area A,
input stages), 12.8 (area C), 12.10 (w16 changes), 12.11 (P0). Session E3, 2026-10-15.

Labels:

* **compiled**: the three language checks and `/W4 /WX`.
* **headless**: unit tests and harness runs.
* **core listing**: facts read from the translated core (`claude/port/core`, read-only) with their
  segmented addresses.

Scope:

* No DOS program was executed. Nothing was written to `C:\Projects\Civ1RE\dos`, `build/dosdata` or
  `C:\Projects\Civ1RE\original`. No UI was shown. No DOS byte is in the repository or a binary (NODOS_OK).
  No git command that writes was run. Asan was not built or run.
* Not edited: `core/`, `rt/`, `platform/w16/*` (no w16 change was needed), the generated tables,
  `tests/test_user.c`, `p4tests.py`, `ext_g1.py`/`ext-g1-*.txt` and every document other than this record.

## Status

DONE. With the DOS profile visible, the game's setup now follows the DOS Birth's end at once: in p4-birth's
start the DOS view leaves R:01A8:087C's black screen 13 ms after the hand-over (172.399 s) for the core's
setup (172.412 s), where it held for 25.8 s before (the core's Birth movie ended at 198.226 s). With the
Windows profile visible nothing changes. The user's visual check is pending ("For the records").

## Decisions (the orchestrator's, recorded as given)

* The feature is on in civ64 by default. When the DOS profile is visible at the DOS Birth's end and the core
  is still in Birth with the world done, the skip is produced once. With Windows visible, nothing. A switch
  to DOS after the DOS end, with the core still in Birth, produces it at the switch's tick. If the core has
  left Birth, nothing.
* It is an explicit exception, by the user's direction, to I1 and T3 (no time-driven input), and it replaces
  T4's hold after the DOS Birth. P0 is verified against the recorded core input: a Windows-profile run given
  the same event at the same virtual time is identical.
* The harness default keeps every existing expectation unchanged; a harness option turns the feature on
  for the new tests.
* The produced input (key or click) is chosen from the core's skip poll, so that the skip consumes it and it
  cannot reach the first setup dialog; proved from the core code and tested.

## Rule exceptions (the user's direction)

* **I1 and T3** (nothing time-driven may produce input; presentation time never drives the core): one
  exception, this Birth auto-continue. The DOS profile's own timeline (the DOS Birth's hand-over) decides
  one input event for the core.
* **T4** (the DOS view holds its last screen until the core's next scene): after the DOS Birth, the hold is
  replaced by the auto-continue while the DOS profile is visible. With the Windows profile visible the
  hidden DOS Birth still holds R:01A8:087C until the core's setup, or until a switch to DOS produces the
  skip.
* **P0** holds for any fixed stream of core input. This feature adds one key press and release to the
  stream, so P0 is checked against the recorded input (test 2 below), not against the run without it.

## What was built

### The produced input: an Escape press and release

`pdos_seq_autocontinue_release` returns two host events:

* `HOST_EV_KEYDOWN`, vk 1Bh (VK_ESCAPE), scan 01h, ch 801Bh (the host's character 1Bh);
* `HOST_EV_KEYUP`, vk 1Bh, scan 01h.

Both events have frame 0, x, y and buttons 0. This is exactly what the arrival stage makes of a player's
plain Escape tap (`hkey down 1B 01 ch 1B`, `hkey up 1B 01`). `host_sync.c` posts them as WM_KEYDOWN 1Bh with
lParam 00010001h and the character 1Bh, then WM_KEYUP 1Bh with lParam C0010001h.

**Proof that the skip consumes it and nothing reaches the setup** (core listing):

1. **The core's Birth loop** is 11E0:01BD..01DB. It starts after BeginWorldCreation returns (11E0:01B2).
   Before each `AdvanceMovie` (call 11E0:01D0) it tests `g_movieSkipRequested`, and leaves to
   DestroySequencePlayer (call 11E0:01E3) when the flag is set.
2. **The skip poll.** BirthMovieCallback 11E0:091E calls PumpMessagesCheckSkipInput (call 11E0:093F) on the
   movie frames with `frame % 30 == 0` (11E0:0928). PumpMessagesCheckSkipInput 11E0:095F loops
   `PeekMessage(&g_msg, 0, 0, 0, PM_REMOVE)` (call 11E0:09BD) until it returns FALSE. It removes every
   queued message, TranslateMessage (11E0:099F) and DispatchMessage (11E0:09AA) each one, and sets its
   result on WM_KEYDOWN 100h (11E0:0973) or WM_LBUTTONDOWN 201h (11E0:0986). On that result the callback
   calls SetGameCursor(84h) (call 11E0:0949; the probe ra 11E0:094E) and sets the flag.
3. **One poll removes all three messages.** The press and the release are posted in the same input-taking
   sync, one after the other, so they are queued together. One pump call removes the WM_KEYDOWN, the
   WM_CHAR 1Bh that its TranslateMessage posts, and the WM_KEYUP, because the loop runs until the queue is
   empty.
4. **No other reader during Birth.** While the core is in its skip-able Birth, the pump is the only reader
   of the message queue on the normal path. This was checked with a static call closure over `core/*.c`,
   from AdvanceMovie 10B0:0461, TickCount and BirthMovieCallback; AdvanceMovie itself calls no message API.
   The only other readers in that closure are on error paths:
   * MenuZ, through RLLEncode's ShowTextDialog when a 16-colour picture conversion cannot be written;
   * MessageBox, through GetResource, RestoMem and ShowErrorMessage on a memory failure.
5. **If the movie ends first.** The movie can end before its next poll (a skip produced in its last 30
   frames). Then the events stay queued until the setup's first MenuZ flushes them:
   * MenuZ calls FlushInputEvents at 1220:0248.
   * FlushInputEvents 11F0:4EA0 removes 100h..108h (11F0:4F04) and 200h..209h (11F0:4F1F), and sets
     `g_keyQueueCount` to 0.
   * Between the loop's end and that flush nothing reads the queue on the normal path (the same static
     closure). It covers DestroySequencePlayer (call 11E0:01E3), PlaySoundEffect (11E0:01EF),
     GR_DialogClose (11E0:01FD), RunNewGameSetup (call 11E0:0205) up to its MenuZ call at 10E8:0523, and
     MenuZ 1220:0156 up to 1220:0248. Its only readers are the same two error paths.
   * The case is the same as a player's key at that instant on the Windows profile.
6. **Why Escape.** The pump dispatches key messages to the focus window. The Birth movie plays in a GR
   dialog, whose procedure is DlgProc 1098:16E2 (GR_DialogOpen's MakeProcInstance at 1098:12A1).
   * DlgProc handles no WM_KEYDOWN or WM_KEYUP. Of WM_CHAR it acts on 0Dh only (1098:17CB: SendMessage
     WM_COMMAND 65h). w16's DefDlgProc passes key messages to DefWindowProc.
   * So Escape has no effect beyond the skip. Enter's WM_CHAR would send WM_COMMAND 65h.
   * Space could press a focused button (user_ctl.c: Space presses on WM_KEYDOWN, clicks on WM_KEYUP).
   * A click would go to the window under the point, and DlgProc handles 201h and 202h.
7. **Tested** (ext_continue.py `replay` and `user`, below):
   * A Windows run given the same press and release at the same sync is identical in everything.
   * A player's natural Escape (pressed at the same sync, released 50 ms later) gives the same first setup
     page and the same final state under the DESIGN.md 9 mask, with equal frames and events. The only
     masked differences are VK_ESCAPE's key-state byte in the queue record and two bytes of stack residue
     below SP: the pump removed two messages instead of three, and the player's release arrived during
     MenuZ.

### The decision (`present/dos/pdos_seq.h/.c`, area C)

`pdos_seq_autocontinue_release(out, max, now_us)` returns the two events when all of these hold:

* the setting is on (`pdos_seq_set_autocontinue`);
* nothing was produced in this Birth yet;
* there is room for both events (`max >= 2`; otherwise the skip is held);
* the core is in its skip-able Birth. Its scene is BIRTH (SeekSequence ra 11E0:01AA) and its world is done
  (BeginWorldCreation's exit, ra 11E0:01B2). Neither its skip (SetGameCursor ra 11E0:094E) nor its Birth end
  (DestroySequencePlayer ra 11E0:01E8) has been seen;
* DOS Birth has reached its hand-over R:01A8:087C (`pdos_birth_at_setup(&g_birth)`: the story's end,
  wait(180) and the post-Birth fade, or the DOS skip). This is the state of the last timeline run at a
  tick, probe or event;
* the DOS profile is visible. `pdos_profile_visible()` is implemented in `pdos_profile.c`, the profile's
  bridge to the present layer (`present_profile_visible()`), because the include rule of
  `gen/dos/registry.py` keeps `profile.h` and `input.h` out of `pdos_seq.c`.

Otherwise it returns 0. When it produces the skip, it also:

* counts it (`pdos_seq_autocontinue_count`, and the presentation diagnostic `autocontinue`,
  `PDOS_DIAG_AUTOCONTINUE`);
* calls the hook `pdos_seq_set_autocontinue_hook`, which the harness uses for coreinput.log.

The other rules:

* **Nothing added after a player's press.** If a key or left-button press of the player's has been
  returned by the filter for posting since Birth's start, nothing is produced in this Birth: the core's next
  poll takes the player's press as its skip. The filter notes each such press with `pdos_seq_note_press()`,
  and `pdos_seq_presses()` counts them since the last reset.
* **Once per Birth.** The per-Birth state is reset at each Birth start.
* **The setting and the hook** are kept across `pdos_seq_reset`. The default is off.

The visible profile changes only at ticks. A switch to DOS after the hand-over therefore produces the skip
at the first input-taking sync after the switch's tick. A switch to Windows before the sync produces nothing.

### The input path (`present/input.h/.c`, area A)

* The filter stage's default pending release (`PiDispatch.pend_release`) is now
  `pdos_seq_autocontinue_release` instead of D3's empty stub.
  * `host_sync.c` already calls `present_input_release` once per input-taking sync, inside the observer's
    guard and after that sync's host events. It posts what is returned (I4's path; draft A 10.1).
  * No presentation code posts (O4). The events are never produced inside a probe, and never written into
    core state.
  * `present_input_release` calls it only while the DOS profile is registered.
* `present_input_filter` notes every key press and left-button press it returns for posting to the DOS
  sequencer (`pdos_seq_note_press`). These are the core's movie-skip input, 11E0:0973 and 0986.

### civ64 (`win64/`)

`civ64_present_defaults()` (`civ64_start.c`) turns the auto-continue on. `civ64_main.c` calls it right
after `obs_init`. It is in `civ64_start.c` so that the Win32-headless test can check it.

### The harness (`tests/headless`)

* `--birth-continue 0|1` (default 0) turns the feature on. With 1:
  * the syncs take input as in the 7.8 mode (W16_TIMING_SCRIPT), also without `--host-input`, so the
    produced skip is posted;
  * `coreinput.log` (`--core-input-log 1`) gets `autocontinue virtual_us US sync N` just before the skip's
    two `post` lines. N is the input-taking sync, which a `sync N` host line replays.
* Under CIV_OBSERVER 0 the option exits 2.
* The `pdos` line of `presentation-diag.log` gains `autocontinue N`.

## Tests

* **`test_pdos_seq`**: +17 checks (114 on every variant). They drive DOS Birth to its hand-over through
  the profile's callbacks:
  * the default is off, and with it off nothing is produced;
  * the setting is kept across the reset;
  * nothing during the world's creation or the story;
  * nothing without room for both events;
  * then exactly the Escape pair, once, counted, with the diagnostic and the hook;
  * the core's skip, Birth end and setup follow, and the Birth view ends;
  * Windows visible at the hand-over: nothing. A switch requested but not yet applied: nothing. Applied at
    a tick: the pair, through input.c's default pending release (`present_input_release`);
  * the core's own skip seen first: nothing;
  * the core's Birth end while Windows is visible, then a switch to DOS: nothing, not even at the setup;
  * a press of the player's since Birth's start: nothing. With the observer it goes through the filter;
    under CIV_OBSERVER 0 it is noted directly.
* **`test_input`**: +2 checks (142 with the observer). The filter notes the key presses and left-button
  presses it returns for posting, the adapter's included, and not consumed events. The default release is
  off.
* **`w32_test_host_win32`**: +2 checks (260; 246 CheckedNoObs). The presentation's default is off, and
  `civ64_present_defaults()` turns it on (civ64's default).
* **`tests/harness/ext_continue.py`** (new; `test.cmd checked` and `checked noobs`). It makes 8 runs of
  p4-birth's start, 185 s virtual, about 36 s wall, and has 20 checks on Checked. On CheckedNoObs it checks
  the refusal. The checks cover the five P0 tests of the brief:
  1. **`dos`** (DOS visible, feature on):
     * one `autocontinue` at 172,398,650 us. That is 46 us after DOS Birth's hand-over (step 2 `setup` at
       172,398,604 us), the first sync after it;
     * its two posts and nothing else;
     * the core's skip, Birth end and setup at 172,411,900 us;
     * the DOS view shows the 640x480 setup frame at 172,411,900 us;
     * `autocontinue 1` in presentation-diag.log;
     * `ref` is still in Birth at 185 s.
  2. **`replay`** (Windows only, given `dos`'s skip as host lines at its sync 3,425,801): the same 1,670
     frame, snapshot and result lines, the same 42 events and the same posts. This is P0 against the
     recorded input.
  3. **`user`** (a player's Escape at that sync, released 50 ms later): the first setup page's MenuZ state
     after its flush (checkpoint 1220:0256, second hit) and the final state equal `dos`'s under the mask.
     The frames and events are equal.
  4. **`win`** (Windows visible), **`to_win`** (switched to Windows at 100 s, before the hand-over) and
     **`off`** (DOS visible, the harness default): nothing produced. The core outputs equal `ref`'s
     (1,678 lines).
  5. **`to_dos`** (Windows visible, switched to DOS at 180 s):
     * one skip at 180,000,050 us, the first sync after the switch's tick;
     * the core's skip, Birth end and setup at 180,431,000 us. The core polls every 30 movie frames.
* **The existing P0 variations and G-1** run with the feature off, the harness's default, so their
  expectations are unchanged:
  * ext_p0 V1 (`--graphics dos`), V2 (switching) and V7 (the only variation whose syncs take input; DOS
    registered);
  * ext_g1; ext_timeline's `birth`, `birth_switch` and `birth_skip`; the P4 scenarios; gate3b.

  The `off` run shows that a DOS-visible Birth to the hand-over and past it posts nothing by default.

## Results

The eight steps ran on 2026-10-15 in one run after the last source change, after the docs agent's
`build/docs-e3a-done.txt` (11:31:11 UTC). Logs are `build/d4b4-<n>-<step>.log`, and the status file
`build/d4b4-status.txt` ends `ALL_GREEN`. No Asan.

**The first cycle** (11:56..12:33 UTC; logs `build/d4b4-run1-*`) stopped at step 2:
* TESTS_FAILED=1, from `registry.py check`'s include rule: `pdos_seq.c` had included `input.h` and
  `profile.h` (deviation 6);
* every other step-2 result was green, EXT_CONTINUE_OK and P0_OK 279 included.

After the fix, the affected tests were run again on a fresh Checked build: REGISTRY_OK, `test_pdos_seq`
114, `test_input` 142, `test_host_win32` 260, OBS_LINT_OK, EXT_CONTINUE_OK. Then the whole cycle ran again
from step 1.

**The second cycle** (12:39..13:42 UTC):

| Step | Result |
|---|---|
| 1 `build.cmd checked` | BUILD_OK, 195 s (272 portable sources: C11 + C17 `/W4 /WX` + clang C99 parse) |
| 2 `test.cmd checked` | TESTS_OK, 1952 s: `test_pdos_seq` 114, `test_input` 142, `w32_test_host_win32` 260, `test_pdos_scene` 126, `test_timeline` 148, `test_user` 331, REGISTRY_OK, NODOS_OK, GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK, P4_TESTS_OK, OBS_TABLES_OK (probes 203, sites 98), OBS_LINT_OK, `pdos_scene_check` 1075, P0_OK 279, EXT_FRAMES_OK, EXT_TIMELINE_OK, EXT_CONTINUE_OK (20), EXT_ADAPT_OK 20, MIRROR_OK 29, ZOOM_OK 32, TRACE_OK |
| 3 `ext_g1.py check` | EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) |
| 4 `build.cmd checked noobs` | BUILD_OK, 197 s |
| 5 `test.cmd checked noobs` | TESTS_OK, 766 s: `test_pdos_seq` 114, `test_input` 122, `w32_test_host_win32` 246, `test_pdos_scene` 127, `test_timeline` 148, `test_user` 331, REGISTRY_OK, NODOS_OK, GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK, P4_TESTS_OK, OBS_TABLES_OK, OBS_LINT_OK, `pdos_scene_check` 1075, P0_OK 56, EXT_CONTINUE_OK (the refusal), TRACE_OK |
| 6 `ext_g1.py check --variant CheckedNoObs` | EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) |
| 7 `build.cmd` (Release) | BUILD_OK, 203 s |
| 8 `test.cmd` (Release) | TESTS_OK, 421 s: `test_pdos_seq` 114, `test_input` 142, `w32_test_host_win32` 260, NODOS_OK, OBS_LINT_OK, TRACE_OK |

**P0.** Every existing expectation is unchanged with the harness's default (feature off):

* P0_OK 279 (Checked) and 56 (CheckedNoObs);
* EXT_G1_OK on both observer variants;
* EXT_TIMELINE_OK (its `birth`, `birth_switch` and `birth_skip` runs), EXT_FRAMES_OK, EXT_ADAPT_OK;
* GATE3B_OK, P4_SCENARIOS_OK.

With the feature on, P0 holds against the recorded input (`ext_continue.py` `replay`).

What this unit's code reads and writes:

* The DOS code reads the emulation only through the probes and `w16q_*` (OBS_LINT_OK, the include rule).
* It never reads `g_randSeed` and never calls the DOS generator (`test_pdos_seq` item 7).
* It writes no core state. Its two events are posted by `host_sync.c`.

## Deviations

1. **The delivery is the filter stage's pending release, not the per-event filter.** The produced events
   are already in Windows form (frame 0); D4c's adapters must not translate them. So they come from
   `present_input_release`, the release that `host_sync.c` posts at every input-taking sync, after that
   sync's host events. This is the brief's "filter stage, then `host_sync.c` posting at the core's poll"
   with no w16 change. They do not go through the arrival stage's ring.
2. **When "at once" is.** The DOS end is noticed at the first presentation tick, probe or event at or after
   the hand-over's instant. The skip is posted at the next input-taking sync after that: 46 us in p4-birth.
   The core then takes up to 30 of its movie frames to poll: 13 ms in p4-birth, 431 ms in `to_dos`. The
   check is made at the syncs, not by running the timelines there, so the presentation's timeline calls are
   unchanged.
3. **Nothing after a player's own press** (beyond the brief's text; its hazard "a simultaneous user key"):
   * Only host-form input counts, that is, what the filter returns.
   * The harness's hwnd-form base-script keys are posted at VM_STEP_API without the filter. Such a key makes
     the core skip, and its skip probe then cancels the auto-continue.
   * A produced skip together with a player's key would also be harmless: one pump call drains both (item 3
     of the proof).
4. **The counter is a presentation diagnostic.** `autocontinue` is added to `PdosDiag`, whose other entries
   are faults. It is a record, as the brief suggests.
5. **The harness option starts the 7.8 syncs without `--host-input`.** The syncs with an empty ring do not
   change the core: `win` and `off` equal `ref`.
6. **The include rule.** `gen/dos/registry.py check` allows `pdos_seq.c` only the store-free headers, the
   `pdos_*.h` headers and the observer's. So the sequencer reaches the two area-A facts it needs another
   way:
   * The visible profile comes through `pdos_profile_visible()` in `pdos_profile.c`, which may include
     `present.h` and `profile.h`.
   * The player's presses are noted to the sequencer by the filter (`pdos_seq_note_press`), not read from
     `input.c`.

   The first cycle found this at step 2 ("Results").

## Notes for D4c2 (folding into `pdos_pend`)

* **The interface.** `int pdos_seq_autocontinue_release(HostEvent *out, int max, uint64_t now_us)` has
  `PiDispatch.pend_release`'s signature. It is input.c's default pending release.
  * D4c2's `pdos_pend_release` takes that place in the dispatch, so it must call
    `pdos_seq_autocontinue_release(out + n, max - n, now_us)` once per call (before or after its own
    translations), or move the decision into its own queue.
  * It returns 0 or 2. It needs room for 2, and holds the skip otherwise.
  * All its state is pdos_seq's (`g_ac`).
* **What to keep.**
  * The two events in one sync, press then release. Item 3 of the proof depends on it.
  * Frame 0, not adapted.
  * The decision only at a sync, never in a probe.
  * Once per Birth.
  * The guards: the core's skip or Birth end seen, the scene and the world flag, the visible profile.
* **D4c's T4 choice translation** ("Birth skip + choice", ext-D4b3-record.md "What D4c must know") must not
  add a second skip after the auto-continue. The core's skip probe marks the core as leaving.
* **`pdos_seq_note_press`** is called by the filter for its returned presses, adapters' outputs included.
  If D4c's adapters turn a press on the DOS view into a core key press during Birth, that counts as the
  player's skip (correct: the core's poll takes it). The pending release's own output is not noted.
* **The 7.8 run of C.15.3** with host input can use `--birth-continue 1` together with `--host-input`.

## For the records

Entries for the documents this unit does not edit.

* **DESIGN.md 12.5 (area A, input stages).**
  * The filter stage's default pending release is the DOS sequencer's Birth auto-continue
    (`pdos_seq_autocontinue_release`, D4b4), which D4c2's `pdos_pend_release` takes over and calls.
  * The filter notes the key and left-button presses it returns for posting to the DOS sequencer
    (`pdos_seq_note_press`).
* **DESIGN.md 12.8 (area C).** `pdos_seq` decides the Birth auto-continue:
  * when: DOS Birth at R:01A8:087C, the core in its skip-able Birth (scene BIRTH, world done, no skip or
    Birth end seen), the DOS profile visible, no press of the player's since Birth's start;
  * what: an Escape press and release once per Birth, released at the next input-taking sync;
  * on in civ64; off in the harness unless `--birth-continue 1`;
  * the exception to I1 and T3, replacing T4's hold after DOS Birth.
* **DESIGN.md 12.10 (w16 changes).** None. `host_sync.c` already posts the filter's released events at
  each input-taking sync (I4's path).
* **DESIGN.md 12.11 (P0) and the I1/T3/T4 rule texts.** One exception by the user's direction (2026-10-15):
  * The Birth auto-continue adds one input event to the core's stream when the visible DOS Birth ends first.
  * P0 is checked against the recorded input: `ext_continue.py`'s `replay` equals `dos`.
  * T4's hold after DOS Birth applies only while the Windows profile is visible.
* **FIDELITY.md** (new entry). With the DOS profile visible, the Windows Birth movie is shortened to the DOS
  Birth's length:
  * When the DOS Birth's hand-over (R:01A8:087C) comes first, the presentation gives the game its Birth
    skip (an Escape key press), and the setup follows. In p4-birth that is 172.4 s instead of 198.2 s.
  * With the Windows profile visible the movie plays to its end as before.
  * A switch to DOS after the DOS Birth's end skips at the switch.
* **RUNNING.md.**
  * civ64 has the Birth auto-continue on; there is no option.
  * The harness takes `--birth-continue 0|1` (default 0; it starts the 7.8 syncs; CIV_OBSERVER 0: exit 2).
  * `coreinput.log`'s `autocontinue virtual_us US sync N` line.
  * presentation-diag.log's `pdos ... autocontinue N`.
  * `tests/harness/ext_continue.py [Checked|CheckedNoObs]`: 8 runs of 185 s virtual, about 36 s, in
    `test.cmd checked` (and the refusal in `checked noobs`).
* **STATUS.md.** D4b4 done:
  * the Birth auto-continue (the user's direction of 2026-10-15 about 10:00);
  * `test_pdos_seq` 114, `test_input` 142, `test_host_win32` 260, `ext_continue.py` 20 checks;
  * the eight-step cycle all green.

  Screen-by-screen Birth synchronisation stays in the backlog (not started).
* **FEATURES.md.** With the DOS graphics visible, the game continues to the new-game setup as soon as the
  DOS Birth story ends (after its fade to black), instead of waiting for the Windows Birth movie. With the
  Windows graphics visible the Windows movie plays as before. Switching to DOS after the DOS story has ended
  continues at once.
* **DOS-PROFILE.md** (row 9 and 3.1). The T4 hold after the DOS story (R:01A8:087C's black screen) is
  replaced by the auto-continue while the DOS profile is visible. The black screen shows until the core's
  next skip poll (at most 30 movie frames; 13 ms in p4-birth). With the Windows profile visible, the hidden
  DOS Birth holds it as before, until the core's setup or a switch to DOS.
* **manual-checklist-ext.md** (D4 section, pending user checks). With `--graphics dos` (or civ64 remembering
  DOS):
  1. the DOS Birth continues to the setup screens without the black wait;
  2. with the Windows graphics visible, the Windows Birth movie plays to its end as before;
  3. switching to DOS after the DOS Birth has ended (while the Windows movie still plays) goes to the setup
     at once;
  4. the first setup screen takes no unintended choice, since the produced Escape does not reach it.

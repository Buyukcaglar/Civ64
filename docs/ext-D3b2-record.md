# Extension phase D3, unit D3b2 (input stages, chord and menu, the 7.8 mode) — record

Prompt: `claude/docs/x64-port-scaling-dos-prompt.md`, phase D3 (section 9): "Observer, probes and
presentation tick in `w16`; composition; profile switching (...); the P0 test runner and the 7.8 harness
mode." Gate: "7.3 (without zoom) and 7.4 pass with switching; probe verification recorded." D3 is done
in three units: D3a (the observer core, [ext-D3a-record.md](ext-D3a-record.md)), D3b1 (presentation,
switching and the P0 runners, [ext-D3b1-record.md](ext-D3b1-record.md)) and this unit D3b2 (input
stages, chord and menu, the 7.8 mode), which also writes the gate record
[ext-D3-acceptance.md](ext-D3-acceptance.md). Session D3b2, 2026-10-11. Brief:
[verify/BRIEF-d3.md](verify/BRIEF-d3.md) ("D3b split", D3b2). Design:
[verify/ext-d1-draft-A.md](verify/ext-d1-draft-A.md) (revision 3) sections 10.1, 10.2, 11, 12.4, 13.1,
13.4, with [verify/ext-d1-decisions.md](verify/ext-d1-decisions.md) (K3, K4, K5, RV1-6, RV1-8, RV1-13,
RV1-15, RV2-3, RV2-5) and DESIGN.md 12.2, 12.5, 12.10.

Labels: **compiled** (the three language checks and `/W4 /WX`), **headless** (test programs and the
harness on `build/gamedata`, the DOS profile with `--dos-data build\dosdata`), **Win32-headless** (the
Win32 back end with a hidden window). No DOS program was executed; nothing was written to
`C:\Projects\Civ1RE\dos` or `build/dosdata`; no visible window was shown; civ64.exe was not started.
No global hotkey, hook, ClipCursor or clipboard is used. Asan was not built or run (deferred by the
user, 2026-10-10 21:20).

## What was built

* **The arrival stage** `present/arrive.c` (new, always compiled, RV1-13; declarations in the new
  `present/input.h`; draft A 10.1, 10.2). S2's input rules moved here from `host_win32.c` (decision K4):
  * **S2's Alt rule (F101):** an Alt press (and its repeats) is held back until the next key event;
    Alt+Enter is the full-screen command (`PI_CMD_FULLSCREEN`, only a press without the repeat bit
    acts) and neither its Alt nor its Enter press, repeats or releases reach the game; another key
    while Alt is down gets the Alt press first; Alt released alone gets press and release together; a
    mouse press delivers a held Alt first; focus loss drops a held Alt. Focus loss releases every
    delivered key in key order, with a Tab press first while a delivered Alt is down (P5MT-2); capture
    loss releases the buttons still down where the mouse was last seen.
  * **The hold rule of decision K3:** a Ctrl or Shift press, and its repeats, is held back like Alt
    while Alt is up. **Ctrl+Shift+Backspace** (Backspace while Ctrl and Shift are down, by the host's
    modifier state or the arrival's own, and Alt is not) is the profile command `PI_CMD_PROFILE`: the
    held presses, the Backspace press, its repeats and release and the held keys' later releases never
    reach the game. A Backspace already delivered down makes no chord (its release must reach the
    game); Alt+Enter serves only the held Alt, so a Shift held before it is delivered as in S2.
    Another key (also after a chord) or a delivered mouse press delivers the held presses first, in
    press order, then the key with its character; a held key released alone is delivered as press and
    release together, after the presses held before it. While a Ctrl or Shift press is held back, its
    MK_CONTROL / MK_SHIFT bit is cleared in mouse moves and releases (RV1-15); a press carries the
    host's bits.
  * **The outside-image rule (F100):** a press outside the image (or, from M on, covered, a right press
    on the ring, beyond the poles) is not delivered, nor its release; the capture is taken so that the
    release is seen; buttons swallowed so are left out of later moves' button state; a release outside
    after a press inside is delivered at the clamped point.
  * **The press latch (RV2-3):** a delivered press fixes its class until its release: a ring press
    (frame 4, its square), a layer-view press (frame 3, D's clamped point over the ring and the poles
    too) or a press off the layer (the visible frame's mapping); a move while both buttons are held
    follows the one pressed first; moves and releases without a latched press are classified on their
    own (D 12.1's table; a release on the ring or beyond the poles is consumed). The map layer's
    classification is `pi_set_layer(PiLayerFn)`, NULL in D3 (only the third class occurs: today's
    behaviour); `test_input.c` drives it with a stub layer.
  * **`HostEvent.frame` (K5):** every event is stamped with the frame its coordinates belong to: the
    visible profile's `input_frame()` (`present_input_frame()`: Windows 0, D3's DOS profile 2) for keys,
    characters, quit, focus- and capture-loss releases and mouse events off the layer; 3 and 4 from the
    latch. `host.h`'s `HostEvent` gained `uint8_t frame`.
  * The wheel (`pi_arrive_wheel`) produces nothing (I8; zoom from M on).
  * Entry points `pi_arrive_key`, `pi_arrive_char`, `pi_arrive_mouse`, `pi_arrive_wheel`,
    `pi_arrive_focus_lost`, `pi_arrive_capture_lost`, `pi_arrive_quit`; `pi_reset` (called by
    `present_reset` and when the Win32 window is destroyed). Output `PiOut`: the events, at most one
    command with its anchor, a capture request. The stage writes only its own state; the back end
    pushes the events into its ring.
* **The filter stage** `present/input.c` (new; body under `#if CIV_OBSERVER`, an empty translation unit
  otherwise; draft A 10.1, C.12.1). `present_input_filter(ev, out, max)` dispatches by the frame stamped
  at arrival: frames 0 and 3 pass unchanged (I2), 1 and 2 go to area C's adapter, 4 to area D's ring
  translation; while the DOS profile is registered, `adapt_note` is asked for frames 0, 3 and 4 and a
  1 sends the event to the adapter (C-11, RV2-5); an unknown frame is consumed and counted
  (`present_input_unknown`). `present_input_release(out, max)` (I4) is 0 while the DOS profile is not
  registered, else area C's `pend_release(out, max, w16q_now_us())`. Until D4 and M the four entries
  are D3's stubs (`PiDispatch`, replaceable by `present_input_set_dispatch` for tests): the adapter
  passes its event, the note answers 0, nothing is pending, a ring event is consumed. D3's input
  therefore reaches the core unchanged (C.12.1 "D3").
* **`host_sync.c`** (`take_input`; draft A 10.1, 12.4; DESIGN.md 12.10): under `CIV_OBSERVER` each
  input-taking sync counts itself (`g_input_syncs`, w16-private, reset by `w16_host_start`), calls the
  7.8 hook `w16_host_input_sync_fn(n)`, passes each polled host event through `present_input_filter`
  inside `W16_OBS_GUARD_BEGIN(W16_OBS_IN_OTHER, W16_OBS_OTHER_INPUT)` and posts what it returns, then
  posts `present_input_release`'s events (inside the same guard kind); a guard that cannot be entered
  posts the event unchanged. `posted()` gives every message actually posted to the post hook
  `w16_host_post_fn` (`coreinput.log`). `W16_TIMING_SCRIPT` (3, `w16_int.h`) takes input this way and
  returns before the clock part (no host time, no sleep). Under `CIV_OBSERVER 0` the ring is posted
  directly as before. `w16_obs.h` gained the guard id `W16_OBS_OTHER_INPUT` (4).
* **The player's switch** (`present.c`, `profile.h`; draft A 10.2, 11; RV1-8):
  `present_player_profile(p)` with `p` a profile or `PRESENT_PROFILE_TOGGLE` (the other one than the
  profile to come: the pending request's, else the visible one): 0 requested (applied at the next
  tick), or a pending request withdrawn when `p` is the visible profile; 1 when `p` already is the
  profile to come; -1 refused. The run's first refusal shows one `host_message` ("Sid Meier's
  Civilization": the DOS store's sentence, then " To use them, choose \"Locate DOS files...\" in the
  window menu; the DOS graphics become available the next time civ64 starts."; under `CIV_OBSERVER 0`
  "The DOS graphics are not in this build."); later refusals in the run beep (`host_beep`).
  `present_reset` starts a new run's cadence; `present_player_refusals()` counts them.
* **The Win32 back end** (`platform/win32/host_win32.[ch]`): the input section now calls the arrival
  stage (S2's `g_held`, `g_mbuttons`, `g_alt_state`, `g_chord_vk`, `g_swallow` and the mouse rules
  moved out) and keeps the Win32 parts: `PiKey` from WM_KEYDOWN / WM_SYSKEYDOWN (repeat bit 30; PI_ALT
  from WM_SYSKEYDOWN with the context bit 29; PI_CTRL and PI_SHIFT from `GetKeyState`), TranslateMessage
  and the Windows-1252 character with the dead-character loop before the arrival (`PiKey.ch`; the
  arrival delivers it with the key's press or drops it with a held or chord-consumed press),
  SetCapture / ReleaseCapture on the request, and the commands: Alt+Enter toggles full screen
  and runs the settings hook (S2), Ctrl+Shift+Backspace calls `present_player_profile(TOGGLE)`.
  WM_CLOSE and WM_QUIT give `pi_arrive_quit`, WM_KILLFOCUS `pi_arrive_focus_lost`, WM_CAPTURECHANGED
  (to another window) `pi_arrive_capture_lost`, WM_CHAR / WM_SYSCHAR `pi_arrive_char`, WM_MOUSEWHEEL
  (`ScreenToClient`) `pi_arrive_wheel` (no event). **System menu** (draft A 11): after "Full screen" a
  separator, "&Windows graphics\tCtrl+Shift+Backspace" (0x1090) and "&DOS graphics\tCtrl+Shift+Backspace"
  (0x10A0) as radio items marking the profile to come (the DOS item stays enabled; its refusal is the
  message), "&Locate DOS files..." (0x10B0; grayed in a `CIV_OBSERVER 0` build, which has no DOS
  profile), then the separator and About. `hw_update_menu` also runs on
  WM_INITMENU of the system menu. An accepted switch (chord or menu) calls the profile hook
  `hw_set_profile_hook(fn(int profile))` with the profile to come; 0x10B0 calls the locate hook
  `hw_set_locate_hook(fn)`. `hw_messages()` counts quiet-mode messages (tests).
* **civ64** (`win64/civ64_main.c`, `civ64_locate.[ch]`, `civ64_cfg.[ch]`; draft A 10.2, 11; RV1-6):
  the profile hook records the player's choice and saves the settings: the key `graphics`
  (`windows`|`dos`) is written from the first accepted switch of the run on, never from `--graphics`
  alone; a refused switch writes nothing. The locate hook runs the new
  `civ64_locate_dos_choose(&where, &cfg, owner)` with the game window as the owner of its file dialog
  and messages: `ask_dos`'s choose-and-validate loop without the "not found"
  question (the file dialog; `use_path` validation against the pinned DOS version; an invalid choice is
  refused with its message and asked again; cancel ends it); a valid choice sets `dos_data`, removes
  `dos_ask=never` (new `civ64_cfg_unset`), saves `civ64.cfg`, frees the temporary `Civ64Found` and
  says "The DOS files are recorded. The DOS graphics become available the next time civ64 starts." The
  DOS store, the running game and its profiles are untouched. `civ64_locate_set_ui(pick, say)` is the
  test seam for the file choice and the messages.
* **The harness's 7.8 mode** (`tests/headless/harness.[ch]`, `harness_main.c`; draft A 12.4):
  * `--host-input FILE`: host-form lines `at <ms>` or `sync <n>` followed by `hkey down|up VK SCAN [ch
    HEX] [repeat] [alt] [ctrl] [shift]`, `hmouse move|ldown|lup|rdown|rup HX HY [buttons HEX]`,
    `hwheel DELTA HX HY`, `hchar HEX`, `hfocus lost`, `hcapture lost`, `hquit`, and the commands of
    12.1 (`profile`, `policy`, `hostsize`; `zoom` refused until M). The lines are sorted by time or
    sync (stable: equal ones keep the file's order). An `at` line goes through the
    arrival stage at the first `VM_STEP_API` at or after its time, a `sync` line at the start of the
    n-th input-taking sync (the hook), both inside `W16_OBS_GUARD_BEGIN(W16_OBS_IN_OTHER,
    W16_OBS_OTHER_INPUT)`; the events go into the headless ring, which the game's syncs post through the
    filter stage (`w16_host_start(W16_TIMING_SCRIPT)`). The chord's command acts as civ64's does
    (`present_player_profile(TOGGLE)`); full screen is only recorded. hwnd-form lines are refused
    (exit 2).
  * `<out>/hostinput.log`: `host virtual_us US sync N line L FORM events E cmd C` per host line.
  * `--core-input-log 1`: `<out>/coreinput.log`, `post virtual_us US msg MMMM wparam WWWW lparam
    LLLLLLLL x X y Y ch CC` for every message the syncs posted (without `--host-input` it stays
    empty: a script's hwnd-form input is posted at `VM_STEP_API`, not through the syncs).
  * `profiles.log` gains the player's lines `request virtual_us US to P player`, `withdraw virtual_us US
    to P player`, `switch virtual_us US refused dos: player chord, refusal N` and the end line's
    `withdrawn W`. Under `CIV_OBSERVER 0` `--host-input` and `--core-input-log` exit 2 ("not in this
    build (CIV_OBSERVER 0)"). The script's and the host input's commands are sorted by time (stable).
  * The headless back end counts `host_beep` and `host_message` (`hh_beep_count`, `hh_message_count`,
    `hh_last_message`).
* **The tests**:
  * `tests/test_input.c` (new, headless; draft A 13.4): S2's Alt cases moved (held, alone, Alt+Enter
    with repeat and releases, Alt+Enter then Alt+F, Alt released before Enter, a mouse press flushing
    Alt, focus loss with a held Alt, with a delivered Alt and Shift: Tab, Tab, Shift, Alt), the K3
    hold rule (Ctrl and Shift held with repeats, Ctrl+S, Shift+A, a lone Ctrl, the chord with repeat
    and releases, the chord by the arrival's own key state, another key after the chord flushing in
    press order, Ctrl+Backspace and Alt+Ctrl+Shift+Backspace not the chord, focus loss with six keys in
    key order), masked MK bits in moves and releases while held and the host's bits on a press, focus
    loss dropping held keys, a lone release after the presses held before it, a Shift held before
    Alt+Enter delivered at its release, a Backspace already down making no chord; the mouse (moves, an outside press and its release with the capture
    requests, the swallowed bit left out of a move, a release outside clamped, capture loss releasing at
    the last position and forgetting the swallow, the wheel); the press latch with a stub layer (ring
    press: moves and release over the view, beyond the poles and off the layer all frame 4 at its
    square; view press: frame 3 at the clamped point over the ring and beyond the poles; a press off the
    layer never frame 3 or 4; a right press on the ring and a covered press not delivered; a move with
    both buttons following the first; capture loss during a ring press giving the frame-4 release; focus
    loss leaving the button down); frame stamping for keys, characters, quit, moves and focus-loss
    releases under the Windows profile and a test profile with input frames 2 and 1; the filter
    (frames 0 and 3 the identity for every event kind, 1 and 2 to the adapter, 4 to the ring
    translation, an unknown frame consumed and counted, no note and no release without the DOS profile,
    the note for frames 0, 3 and 4 only with it, the note's 1 routing frames 0 and 4 to the adapter,
    the release with it, D3's stubs); the player's switch (the first refusal's message with the Locate
    hint, later refusals and the menu's DOS item beeping, a new run restarting the cadence, toggle,
    withdrawal, the menu's choice, the tick's switch, no message or beep for accepted switches).
  * `tests/win32/test_host_win32.c` (7.2): S2's About-position check updated for the inserted items;
    new `test_window_d3b2`: the items' texts and marks (Locate grayed only under `CIV_OBSERVER 0`),
    Ctrl+Shift+Backspace through `hw_window_message`
    putting nothing in the ring and requesting DOS (the hook called, the DOS item marked), again
    withdrawing, the menu items (requested, chosen again: nothing, Windows withdrawing), WM_INITMENU's
    marks, Ctrl+Backspace delivered with Ctrl first, a held Shift's MK_SHIFT masked in a move and the
    press carrying it after Shift, the wheel, and with no DOS profile the refusal cadence (one quiet
    message, then a beep each for the chord and the DOS item, nothing recorded) and Locate calling its
    hook with the run's profiles unchanged.
  * `tests/win32/test_locate.c`: `test_locate_dos` (cancel records nothing; a Windows `civ.exe` refused
    with its message, then a DOS `CIV.EXE` recorded; `civ64.cfg` reloaded: `dos_data` set, `dos_ask=never`
    removed, other keys kept; the next `civ64_locate` finds the remembered DOS files; a `dos_ask` other
    than `never` kept).
  * `tests/harness/ext_p0.py`: variation **V7** (below); `tests/harness/ext_adapt.py` (new, 7.8 I7,
    below); both in `test.cmd checked`.

Files (under `claude/port`). New: `present/input.h`, `present/arrive.c`, `present/input.c`,
`tests/test_input.c`, `tests/harness/ext_adapt.py`, this record, `ext-D3-acceptance.md`. Changed:
`platform/w16/host.h`, `host_sync.c`, `w16_int.h`, `w16_obs.h`; `present/present.c`, `profile.h`;
`platform/win32/host_win32.h`, `host_win32.c`; `win64/civ64_main.c`, `civ64_locate.h`, `civ64_locate.c`,
`civ64_cfg.h`, `civ64_cfg.c`; `tests/headless/harness.h`, `harness.c`, `harness_main.c`,
`host_headless.h`, `host_headless.c`; `tests/win32/test_host_win32.c`, `test_locate.c`;
`tests/harness/ext_p0.py`; `test.cmd`. (`build.cmd` rewrites its generated files on every build; their
content is not D3b2's.)

## The chord audit (Ctrl+Shift+Backspace; draft A 10.2, 5.11)

Read-only, on the pinned `build/gamedata/civ.exe` (its NE resource table) and the port's sources:

* **Accelerators.** The program has one accelerator table, ACCELERATOR 128, 24 entries: plain D H J K N
  P, Ctrl+R, Ctrl+0..9, Ctrl+D P F L Q S T (all virtual-key entries with the Ctrl flag or none). No
  entry is VK_BACK (08h) or the character 7Fh, and none has both Ctrl and Shift. TranslateAccelerator
  (1098:0321, 1098:0683) therefore never matches the chord.
* **Menus.** The one menu, MENU 128, has 89 items (File with Options, Edit, Orders, Advisors, World,
  Civilopedia, City, Help); their accelerator texts name only Ctrl+letter, Ctrl+digit or plain letters;
  none names Backspace or Ctrl+Shift.
* **Key handlers.** No WM_KEYDOWN handler of the core tests VK_BACK (ProcessKeyboardMessage 1098:02D1
  queues only VK 21h..28h; MenuZSubclassWndProc 1220:1289 handles navigation keys); the core has no
  WM_SYSKEYDOWN or WM_SYSCHAR handler and calls neither GetKeyState nor GetAsyncKeyState;
  GetKeyboardState is read only for Num Lock (1008:02E6, 1008:033D). Backspace's character 08h is a
  game key (MoveCivUnits' move switch, `case 8` at 11F0:1C40 beside '7': north-west) and the EDIT
  control's delete (`user_ctl.c`); Ctrl+Backspace's 7Fh is used by neither (the EDIT control inserts
  characters from 20h except 7Fh). The dialog manager (IsDialogMessage at 1098:1C11, 10B8:06DB,
  10E0:0689, 10F0:0175, 1108:0588, 1170:2001, 11C0:36BF, 1220:0AE6; w16's `user_dlg.c`) handles Tab,
  arrows, Enter and Escape, not Backspace.
* **Result.** Ctrl+Shift+Backspace is unused by the game's accelerators, menus and key handlers. The
  chord consumes its key down with the attached character, so the game loses no function: plain
  Backspace, '7' and the keypad still move north-west, Ctrl+Backspace still reaches the game (tested).
  The DOS adapters' keys are rechecked when area C fixes them (Open A3).

## Acceptance items

The final cycle (after the review fixes, see "Review"), 2026-10-11:

| Item | Method | Result |
|---|---|---|
| Builds | `build.cmd checked`, `build.cmd checked noobs`, `build.cmd` (strict C17/x64, `/W4 /WX /permissive-`; the 245 portable sources, two of them new (`present/arrive.c`, `present/input.c`), also `/std:c11`, `/std:c17` and the clang-tidy C99 parse) | compiled: BUILD_OK Checked (15:02:05..15:05:15 UTC), CheckedNoObs (15:23:02..15:26:07 UTC), Release (15:33:02..15:36:01 UTC) |
| Base tests | `test.cmd checked`, `test.cmd checked noobs`, `test.cmd` (every base test program, `test_input` and the Win32-headless programs included, gate 3b, the stub-core runs, scenarios, UNINIT, phase-4 scenarios and tests, D2's and D3's checks, TRACE) | TESTS_OK Checked (15:05:15..15:23:02 UTC), CheckedNoObs (15:26:07..15:33:01 UTC), Release (15:36:01..15:36:36 UTC); GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK and P4_TESTS_OK in Checked and CheckedNoObs, TRACE_OK in every variant |
| G-1 (P0) | `ext_g1.py check` after `test.cmd checked`; `ext_g1.py check --variant CheckedNoObs` after `test.cmd checked noobs` | **EXT_G1_OK runs 77** on Checked (15:23 UTC) and on CheckedNoObs (15:33 UTC) |
| 7.3 P0 without zoom (13.1) | `ext_p0.py Checked` in `test.cmd checked` (V0, V1, V2, V3, V6, V6r, V6w and the new V7); `ext_p0.py CheckedNoObs` in `test.cmd checked noobs` (V5) | **P0_OK checks 224** (Checked: D3b1's 170 and V7's 54), **P0_OK checks 54** (CheckedNoObs); no FAIL line (see "P0 variations and results") |
| 7.4 (13.2) and the dump check (13.4) | `ext_frames.py Checked` in `test.cmd checked` (with switching: runs A, A', B `--switch-every 997`, C) | **EXT_FRAMES_OK** |
| 7.8, I7 (13.4) | `ext_adapt.py Checked` in `test.cmd checked` | **EXT_ADAPT_OK checks 11** (see "7.8") |
| 7.2, input and chords (13.4) | `w32_test_host_win32.exe` (`test_window_d3b2`) and `w32_test_locate.exe` in every `test.cmd` | 185 and 36 checks, 0 failures, in every variant |
| Probe verification | the union of the hits in the 141 `observer-probes.log` files of the Checked P0 matrix (27 runs each of V0, V1, V2, V3, V7; two each of V6, V6r, V6w) | **179 of the 203 keys** hit; the 24 never-hit keys are D3b1's (D3a's 11 and the 13 the scenarios do not reach; listed in [ext-D3-acceptance.md](ext-D3-acceptance.md)); per variation V0..V3 and V7 179, V6 121, V6r and V6w 120, `ext_adapt.py`'s two runs 114 each; all 167 files under `build/harness/Checked` (with the stub-core, `ext_frames.py` and `ext_adapt.py` runs) leave 179. Every file reports `observer probes 203 installed 203 callsites 98`; each `observer-probes.log` of V1, V2, V3, V6 and V7 equals V0's and V6w's equals V6r's (112 comparisons, informational) |
| Tables and the static check | `obs_tables.py --check`, `obs_lint.py` in `test.cmd` | `OBS_TABLES_OK probes 203 sites 98`, `OBS_LINT_OK files 33 probes 203 callsites 98` in every variant (`present/arrive.c` and `present/input.c` among the linted files) |
| No DOS bytes; E's include rule | `nodos.py check`, `registry.py check` in `test.cmd` | NODOS_OK and REGISTRY_OK in every variant; `nodos.py check` again at the end: NODOS_OK (15:37 UTC; 837 files scanned, 0 hits). `build/dosdata` and `C:\Projects\Civ1RE\dos`: the newest entries date from 2026-10-10; nothing was written in the session |
| `CIV_OBSERVER 0` refusals (A 9) | the CheckedNoObs harness with `--host-input FILE`, then with `--core-input-log 1` | exit 2 with `harness: --host-input: not in this build (CIV_OBSERVER 0)` and `harness: --core-input-log: not in this build (CIV_OBSERVER 0)` (15:37 UTC); no run or output directory created |
| The chord audit | read-only, `build/gamedata/civ.exe`'s resource table and the port's sources | recorded above ("The chord audit") |
| Asan | — | **deferred** (the user's direction 2026-10-10 21:20) |

Earlier cycle of the session (before the review fixes): Checked 14:27:45..14:44:10 UTC (BUILD_OK;
TESTS_OK with P0_OK checks 224, EXT_FRAMES_OK, EXT_ADAPT_OK checks 11; EXT_G1_OK runs 77) and
CheckedNoObs 14:46:59..14:57:15 UTC (BUILD_OK; TESTS_OK with P0_OK checks 54; EXT_G1_OK runs 77).
Before it, single changed files were compiled into the scratchpad only (`cl /c /W4 /WX /permissive-
/std:c17` with the Checked, `CIV_OBSERVER 0` and Release definitions; no build products, nothing
counted); they found one warning treated as an error (C4100, an unused `argv` in `test_input.c`),
fixed before the first build. Every build and test of both cycles passed.

### Test counts

| Program | Checked | CheckedNoObs | Release | D3b1 |
|---|---|---|---|---|
| `test_input` (new, headless) | PASS 140 checks, 0 failures | 122 | 140 | — |
| `test_host_win32` (Win32-headless) | PASS 185 checks, 0 failures | 185 | 185 | 166 |
| `test_locate` (Win32-headless) | PASS 36 checks, 0 failed | 36 | 36 | 31 |

Every other test program gave D3b1's counts in each variant (for example `test_present` 521,
`test_observer` 103 / 1 / 92, `test_user` 319, `test_start` 110, `test_gdi` 95, `test_dos` 23,200).
`test_input`'s CheckedNoObs count is 18 lower: the filter stage's cases are compiled only under `CIV_OBSERVER` (the stage is an empty translation unit otherwise); the refusal message is checked in its `CIV_OBSERVER 0` form there. `test_host_win32`'s 19 new checks are `test_window_d3b2` (the About position check
kept its count); `test_locate`'s 5 are `test_locate_dos`. Logs: `build/d3b2-build-*.log`,
`d3b2-test-*.log`, `d3b2-g1-*.log`, `d3b2-*-times-*.txt` (suffix `-1` the earlier cycle, `-2` the
final one); the runners' outputs `build/test/<variant>/ext-p0.txt`, `ext-frames.txt`, `ext-adapt.txt`.

### P0 variations and results

27 runs per variation: the 23 rows of `scenarios.py` and gate3b's S2, S2b, S2c, S3. "Equal" means
`run.log`'s frame, snapshot and result lines, the whole `events.log` and the exit status. V0..V6w and
V5 are D3b1's, unchanged; V7 is new.

| Variation | Options (beside the scenario's) | Runs | Checks | Result |
|---|---|---|---|---|
| V0 | none (4:3 default) | 27 | 27 | every run equals its `ext-g1-baseline.txt` row, exit 0 |
| V1 | `--dos-data build\dosdata --graphics dos --presented 1` | 27 | 54 | equal to V0; start profile dos, registered windows,dos, refused 0 in all 27 |
| V2 | `--dos-data build\dosdata --switch-every 997 --presented 1` | 27 | 54 | equal to V0; 1,866 requests, 1,866 switches, refused 0, pending 0, replaced 0, withdrawn 0 |
| V3 | the scenario's lines plus `policy` and `hostsize` commands, `--presented 1` | 27 | 27 | equal to V0 |
| V6 | `--dos-data build\dosdata --game-screen view --switch-every 997 --presented 1` (s3, orders) | 2 | 4 | equal to V0; 137 requests, 137 switches |
| V6w / V6r | `--host-size 1920x1080 --game-screen view` with (V6w) and without (V6r) the DOS options and `--switch-every 997` (s3, orders) | 2 + 2 | 4 | V6w equal to V6r; 137 switches |
| **V7** | `--dos-data build\dosdata --presented 1 --host-input FILE`: the player's chords in host form from 1,009 ms on, every 1,009 ms up to the watchdog, Ctrl+Shift+Backspace (Ctrl, Shift, Backspace with character 7Fh, a Backspace auto-repeat, the releases) and Alt+Enter in turn, lines 10 ms apart; the scenario's own script stays its input | 27 | 54 | equal to V0 in all 27; profiles.log 928 requests, 928 switches, refused 0, pending 0, replaced 0, withdrawn 0; `hostinput.log` 10,136 lines (928 profile chords of 7 lines, 910 Alt+Enter of 4), every line `events 0`, the profile commands equal requests + withdrawn in every run |
| V5 | the V0 options on CheckedNoObs | 27 | 54 | every run equals its baseline row and the Checked V0 outputs |

V7 runs every P0 scenario in `W16_TIMING_SCRIPT`, so the filter stage runs at every input-taking sync
and the chord's command goes through `present_player_profile`; that the frames, snapshots, results,
events and exit statuses equal V0's shows that the stages, the sync hooks and the player's switches
change nothing the core receives. The shows (from `presented.log`, not compared): V7 8,073 tick shows
and 955 views (the 27 first ones and one per switch); V2 7,633 tick shows, as in D3b1.

### 7.8 (`ext_adapt.py`)

Two runs of gate3b's S3 (`new-game.script`, 72,000 ms) in host form through `--host-input` with
`--dos-data build\dosdata --core-input-log 1`: **plain** (the script converted line for line, the
`hwnd` lines dropped; deviation row) and **chords** (the same lines with six Ctrl+Shift+Backspace
chords, during the intro at 5,000 and 15,000 ms, during world creation and Birth at 23,000 ms and
23,900 ms, in the leader-name EDIT control between two typed letters at 32,310 ms and in play at
59,000 ms, and two Alt+Enter, at 10,000 and 50,000 ms). Final Checked result, 11 checks:

* both runs wrote `run.log`, `events.log` and `coreinput.log` (exit 0, 0);
* the chord run equals the plain run: `coreinput.log` (38 posted messages with their virtual times),
  764 frame lines, 13 snapshot and result lines, 94 events, the exit status;
* the plain run posted its input through the syncs (38 messages);
* both runs reach S3's 11 checkpoints (world generation, setup, turns 1 to 5, the four Spaces), and
  the after-setup snapshot holds the typed leader name in both;
* the chord run's `hostinput.log`: 50 chord lines, 38 script lines, 6 `cmd profile`, 2
  `cmd fullscreen`; no chord line put an event into the ring and every script line did (also in the
  plain run: 38 of 38);
* the chord run's `profiles.log`: requests 6, switches 6, refused 0, pending 0, replaced 0,
  withdrawn 0 (no chord skipped the intro: the title menu comes at the same virtual time).

`ext_adapt.py` uses only the DOS profile of D3 (area C's adapter, DOS-form scripts and the real
note come with D4; area D's wheel and ring scripts with M).

### Review

A separate read-only agent session reviewed the changes (P0 first) after the first Checked cycle
(14:27..14:44 UTC) and while the first CheckedNoObs cycle ran. It found **no P0 hazard**: under timing
NONE `w16_host_sync` returns before `take_input`; under HOST/CLASSIC the filter is the identity for
frames 0 and 2 (D3's stubs) and the release posts nothing; a guard that cannot be entered posts the
event unchanged; `g_input_syncs` and the hooks are w16-private; `W16_TIMING_SCRIPT` is set only with
`--host-input` and reset at the run's end and in `run_error`; nothing posts outside `host_sync.c`; every
S2 case of `test_window` and `test_window_s2` gives the same events in the same order; no stray
`WM_CHAR`; the capture handling; the arrival's bounds (at most 257 events, `vk & 0xFF`); the latch;
the harness hooks touch only presentation state and logs; the settings and Locate rules. Its 13
findings and what was done:

| # | Finding | Done |
|---|---|---|
| 1 | a chord on a key already delivered down swallowed that key's release (stuck key) | the profile chord requires its Backspace not delivered down; Alt+Enter kept as S2 (deviation row); `test_input.c` case |
| 2 | Locate's file dialog and messages had no owner: the game window took input meanwhile and could hide the dialog in full screen | `civ64_locate_dos_choose(w, cfg, owner)`; civ64 passes the game window (deviation row) |
| 3 | Alt+Enter swallowed a Shift held before it (S2 delivered it) | Alt+Enter serves only the held Alt; `test_input.c` case |
| 4 | a held key released alone jumped ahead of keys held before it | the earlier held presses are delivered first; `test_input.c` case |
| 5 | Win32: the peeks after `pi_arrive_key` could dispatch a sent WM_KILLFOCUS between the arrival and the push (a key's release before its press) | TranslateMessage and the peeks now run before the arrival (`PiKey.ch` before the call, as 10.1 says); the character of a press not delivered is dropped |
| 6 | releases whose press was not delivered reach the core (more reachable after the refusal message box) | kept: S2's rule (K4); recorded (deviation row, FIDELITY entry) |
| 7 | `--core-input-log 1` without `--host-input` writes an empty log | documented (`harness.h`, deviation row) |
| 8 | host lines were applied in file order (an out-of-order line held back the later ones) | sorted by time or sync, stable |
| 9 | `--script` accepted together with `--host-input` against 12.4 | recorded (deviation row); V7 relies on it |
| 10 | a capture-loss release takes the last delivered event's position and frame, not per button (matters from M on) | recorded (deviation row; D1 drafts for M) |
| 11 | a press that is not delivered does not flush the held keys; S2's order not covered by its tests | kept; recorded (deviation row) |
| 12 | Locate misleading in a `CIV_OBSERVER 0` civ64 | the item is grayed there; `test_window_d3b2` checks both variants |
| 13 | `obs_lint.py` gaps (uppercase `W16_` macros, `vm_` symbols outside area C, the include exemption) without a current violation | recorded under "For the records" (D3a's file) |

The fixes were not re-reviewed; the final cycle below ran on them.

## Deviations from the design

| Design | What | Why |
|---|---|---|
| A 10.1 (`PiOut` "0..8 HostEvents") | `PI_OUT_MAX` is 264 | focus loss releases every delivered key (S2: up to 256 keys after a Tab); the other arrivals give at most 4 events |
| A 10.1 ("Focus and capture loss release the held buttons"), 13.4 ("focus loss during a ring press (a frame-4 release)") | focus loss releases the keys only; the buttons are released, with their latched class, when the capture goes (`pi_arrive_capture_lost`); `test_input.c` checks the frame-4 release at capture loss and that focus loss leaves the button down | S2's code released buttons only on WM_CAPTURECHANGED; K4 keeps S2's behaviour exactly. In Win32 the capture goes when another window takes the mouse, which delivers the release |
| A 10.2 ("neither ... the chord key's press, repeats and release") | the chord key's later presses and repeats are swallowed until its release even when the modifier (Alt for Alt+Enter, Ctrl or Shift for the profile chord) was released first | in that order S2 delivered Enter's repeats as new key downs without a release (a key stuck down in the core); 10.2 says the chord key's repeats never reach the game. The only S2 behaviour changed, an edge (Alt released before Enter while Enter auto-repeats); `test_input.c` covers it |
| A 10.2 (the chord) | a Backspace already delivered down (`g_down`) makes no chord: Ctrl+Shift with its repeat delivers the held presses and the repeat; Alt+Enter is unchanged | otherwise the chord would swallow the release of a press the game got, leaving the key down in the core (review finding 1; reachable by 7.8 scripts more than by a keyboard). Alt+Enter keeps S2's rule exactly (K4) |
| A 10.2 ("neither the held presses ... reach the game") | Alt+Enter serves only the held Alt: a Shift (or Ctrl) held before it stays held and is delivered at its release or before the next key | S2 delivered Shift and Ctrl at once, so Alt+Enter never took them; 10.2 keeps Alt+Enter's S2 behaviour exactly (review finding 3) |
| A 10.2 ("a held key released alone: its press and release are delivered together") | the presses held before it are delivered first, in press order (Ctrl held, Shift held, Shift released: Ctrl, Shift, Shift's release) | keeps the press order K3 keeps for other keys (review finding 4); with Alt alone held this is S2's rule |
| A 10.2 ("Mouse press: held keys are delivered first") | a press that is not delivered (outside the image, F100; from M on covered, a right press on the ring, beyond the poles) leaves the held presses held | nothing reaches the game for that press; the held keys follow with the next key or delivered press. S2's tests do not cover the order of the outside test and the Alt flush in S2's `mouse` (review finding 11) |
| A 10.1 (capture loss "with their latched class"; K5 "the frame visible at arrival") | a capture-loss release of a button off the layer carries the last delivered mouse position and that event's frame (a ring press: its square, frame 4) | the coordinates and the frame then agree. From M on, with one button latched on the view and the other off the layer, the position and frame must be kept per button (review finding 10; for M) |
| S2 (kept), A 10.2 ("Every delivered press has a delivered release") | a key release whose press was not delivered (dropped at focus loss, or after a refusal message box took the focus) is still delivered as a WM_KEYUP | S2's rule (K4; `test_input.c` checks it). The first refusal's message box makes it more reachable (the Enter that closes it, chord keys released after it); an unpaired WM_KEYUP is not acted on by the core's key handlers (review finding 6; kept and recorded) |
| A 10.2 ("PI_CMD_PROFILE → `present_request_profile(other)`"), 11 (`hw_update_menu` "checks the visible profile") | `present_player_profile(p)`: the toggle targets the other one than the profile to come; choosing the visible profile while a request is pending withdraws it (no switch); 1 when `p` already is the profile to come. The radio items mark the profile to come, refreshed also on WM_INITMENU | a chord pressed twice before a tick would otherwise request the visible profile (a switch to itself with a whole-client redraw) or, with "other than the visible", request DOS twice; the marks show the player's choice at once although it applies at the next tick |
| A 10.2 (`civ64_locate_dos_choose(const Civ64Where *w, Civ64Cfg *cfg)`) | a third parameter `owner` (the game window from civ64; NULL in tests): the file dialog and the messages are owned by it, and a start-up question has none | the game window then waits disabled under the modal dialog and cannot hide it in full screen; unowned, the game window took clicks and keys into the ring meanwhile (review finding 2) |
| A 11 (the menu) | "Locate DOS files..." is grayed in a `CIV_OBSERVER 0` build | such a build has no DOS profile, so the recorded location could never take effect (review finding 12) |
| A 11 ("The settings hook writes it") | a separate profile hook `hw_set_profile_hook(fn(int))`; civ64's handler records the choice and calls the same `save_settings`, which writes `graphics` from the run's first accepted switch on | the settings hook takes no argument and also runs for other changes (options, placement), when `graphics` must not be written from `--graphics` alone |
| A 12.2 (`profiles.log`) | the player's chord in the 7.8 mode logs `request ... player`, `withdraw ... player` and `switch ... refused dos: player chord, refusal N`; the end line gains `withdrawn W`; a refused player chord counts as a request | the harness had no chord before 7.8; `withdrawn` keeps V7's balance `switches + pending + withdrawn == requests` checkable |
| A 12.4 | `<out>/hostinput.log` (one line per host line: virtual time, the input-sync count, line, form, events put in the ring, command) | `ext_adapt.py` and V7 assert that no chord line put an event into the ring; 12.4 names only `coreinput.log` |
| A 9, 12.4 | under `CIV_OBSERVER 0` the harness also refuses `--core-input-log` (exit 2, "not in this build (CIV_OBSERVER 0)") | the post hook exists only under `CIV_OBSERVER` (DESIGN.md 12.10's `host_sync.c` row) |
| A 12.4 ("`hwnd`-form scripts cannot be fed in this mode") | `--script` (hwnd form) may be given together with `--host-input`: its lines keep their direct posting; an hwnd-form line inside the host-input file is refused (exit 2) | V7 runs every P0 scenario with its own script and the player's chords through the arrival and filter stages; the scenario's input is then V0's |
| A 12.1, 12.4 | the commands of the script and of the host-input file are sorted by time, the host lines by time or sync (stable insertion sorts; equal keys keep the file's order) | both files may carry commands; an out-of-order host line would otherwise hold back the lines after it (review finding 8) |
| A 12.4 (`--core-input-log`) | accepted without `--host-input`; `coreinput.log` then stays empty | a script's hwnd-form input is posted at `VM_STEP_API`, not through the syncs (review finding 7; documented in `harness.h`) |
| A 6.1 | the guard id `W16_OBS_OTHER_INPUT` (4) for the filter stage and the 7.8 host lines; `take_input` posts an event unchanged when the guard cannot be entered | as D3b1's ids, the sentinel's fault names the kind and the id; no caller of a sync holds the guard, and the unchanged event is D3's filter result anyway |
| A 13.1 | the extra variation **V7** (every run with `--dos-data`, `--presented 1` and a host-input file of the player's chords) against V0, with switch and `hostinput.log` assertions | 13.1 has no variation through the input stages; the brief left "the remaining `ext_p0.py` variations" to D3b2, and V0..V6 were complete in D3b1. V7 puts every P0 scenario through `W16_TIMING_SCRIPT`, the filter at every input-taking sync and the player's switch |
| A 13.4 (7.8: "S3 in host form") | `ext_adapt.py` converts `new-game.script` line for line (`keydown` to `hkey down ... ch`, `keyup` to `hkey up`, `char` to `hchar`) and drops the `hwnd` lines (host input goes to the focus window) | 13.4 gives no conversion rule; this keeps every S3 checkpoint and the leader name |
| A 13.4 (C-11 "with C's real note") | the case with area C's real `pdos_adapt_note` is not in `test_input.c` | C's note arrives with D4; D3 tests the routing with a stub note |
| A 11 (menu texts) | as designed; "&Windows graphics" shares its mnemonic W with "Scale by &whole multiples" | noted only: Windows cycles between items with the same mnemonic; the texts are the design's |

## For the records

The orchestrator applies these; D3b2 did not edit the files.

* **DESIGN.md 12.2** (S2's window): the system-menu bullet gains, after Full screen, a separator,
  "Windows graphics" (0x1090) and "DOS graphics" (0x10A0) as radio items marking the profile to come
  (the DOS item enabled; refused with the message), "Locate DOS files..." (0x10B0), then the separator
  and About; `hw_update_menu` also on WM_INITMENU. The Chords bullet: Ctrl+Shift+Backspace audited in
  D3b2 (this record's chord audit); the Alt rule now lives in `present/arrive.c` with K3's Ctrl/Shift
  rule. The Tests bullet: `test_window_d3b2` and the updated About position.
* **DESIGN.md 12.5**: "Input (I2, I7)" as built (this record; `PI_OUT_MAX` 264, focus loss releasing
  keys only, the profile to come and the withdrawal, the profile and locate hooks); "P0 runs post
  scripted core input directly and never reach the filter" becomes: except V7, whose chords go through
  the arrival and filter stages; "Tests and the D3 gate": `ext_p0.py` V0..V3, V5, V6 (and V6w/V6r) and
  V7, `ext_adapt.py` (7.8 I7, in `test.cmd checked`).
* **DESIGN.md 12.10**: the `host_sync.c` row as built (`take_input`, the guard id
  `W16_OBS_OTHER_INPUT`, `posted()`'s post hook, `W16_TIMING_SCRIPT` returning before the clock part);
  `w16_obs.h`: `W16_OBS_OTHER_INPUT`; the host side: `host_win32.c`'s profile and locate hooks,
  `hw_messages`; `civ64_cfg.c`'s `civ64_cfg_unset`, `civ64_locate.c`'s `civ64_locate_dos_choose` and
  `civ64_locate_set_ui`.
* **FIDELITY.md**: F100's and F101's code reference becomes `present/arrive.c` (`pi_arrive_mouse`,
  `pi_arrive_key`), with the Win32 back end calling it; F101 gains: the chord key's presses and repeats
  are swallowed until its release even after the modifier's release (S2 delivered them); a key release
  whose press was not delivered (focus loss, a message box) still reaches the game, as in S2. F114's
  status: implemented in D3 (D3b2, 2026-10-11), with: a held key released alone comes after the
  presses held before it; Alt+Enter takes only the held Alt; a Backspace already down makes no chord; a
  press outside the image leaves the held keys held. F117 and F118: implemented in D3b2 (the hint's
  exact text as above; "Locate" saves `civ64.cfg` with `dos_data`, removes `dos_ask=never`, its file
  dialog and messages owned by the game window; grayed in a `CIV_OBSERVER 0` build).
* **RUNNING.md**: civ64's system menu items "Windows graphics" / "DOS graphics" (also
  Ctrl+Shift+Backspace) and "Locate DOS files..." (effective at the next start); the settings key
  `graphics` written when the player switches (chord or menu), never from `--graphics`; the refusal
  cadence. The harness: `--host-input FILE` (the host forms and `sync <n>`, the 7.8 mode),
  `--core-input-log 1`, `hostinput.log`, `coreinput.log`, `profiles.log`'s player lines and
  `withdrawn W`; `tests/harness/ext_adapt.py` and V7 of `ext_p0.py` (both in `test.cmd checked`).
* **STATUS.md** (extension track): D3b2 complete in Checked, CheckedNoObs and Release on 2026-10-11
  (this record); the D3 gate met ([ext-D3-acceptance.md](ext-D3-acceptance.md)); Asan deferred; next
  D4 (area C replaces the filter's stubs; the C-11 case with the real note).
* **manual-checklist-ext.md** D3 (pending, user): D3-1..D3-5 can now be checked (the chord, the hold
  rule, the masked modifier bits, Locate, the refusal cadence); add: the system menu's "Windows
  graphics" / "DOS graphics" marks follow the chord and the menu (the mark moves at once, the picture
  at the next tick); a chord pressed twice quickly leaves the profile unchanged; Ctrl+Backspace,
  Ctrl+S, Shift+letter and Alt+Enter behave as before; the settings key `graphics` remembers the last
  switch at the next start.
* **FEATURES.md**: none (no game feature changed).
* **The D1 drafts**: A 10.1's `PiOut` size (264), the focus-loss rule (keys only; buttons at capture
  loss), the capture-loss release's position and frame (per button from M on); A 10.2's chord action
  through `present_player_profile` (the profile to come, withdrawal), the chord-key rule after the
  modifier's release, no chord on a key already down, Alt+Enter serving only Alt, the lone release
  after earlier held presses, a press not delivered leaving the held keys, `civ64_locate_dos_choose`'s
  `owner`; A 11's radio marks (the profile to come), the profile hook and the grayed Locate without the
  observer; A 12.2's player lines and `withdrawn W`; A 12.4's `hostinput.log`, `--script` with
  `--host-input`, the `--core-input-log` refusal under `CIV_OBSERVER 0` and its empty log without
  `--host-input`, the sorted commands and host lines; A 13.1's V7; A 13.4's S3 conversion rule;
  A 6.1's `W16_OBS_OTHER_INPUT`.
* **`tests/harness/obs_lint.py`** (D3a's; not changed here, no current violation; review finding 13,
  by the reviewer's reading):
  the uppercase `W16_` macros (`W16_OBS_GUARD_BEGIN`, `W16_TICK`, `W16_OBS_FORBID`) are not banned in
  `present/`; `vm_` symbols other than `vm_step`, `vm_steps`, `vm_site` are banned only in area C's
  files; the include exemption (`INCLUDE_EXEMPT`) cannot match because the quoted path is blanked before
  the check, so any w16 header include passes. A later unit may tighten these.

## Not verified

* Asan builds and tests (deferred by the user).
* civ64.exe was not started: the chord, the menu items, the refusal message and beeps, Locate's file
  dialog and message boxes, the remembered `graphics` key and the arrival stage under a real keyboard
  and mouse are compiled and covered by the Win32-headless tests (hidden window, `hw_window_message`,
  quiet mode, the locate seam) only. `GetKeyState` there reads the real keyboard (no key down), so the
  Win32 chord cases exercise the arrival's own key state; the host's modifier state is covered by
  `test_input.c` and the 7.8 lines.
* The capture's loss at a real focus change (Alt+Tab with a button down) was not exercised; the
  arrival's rule is tested with `pi_arrive_capture_lost`.
* The filter stage's adapter, note, release and ring paths run only with stubs and test dispatch
  tables (D3); area C's and D's real functions come with D4 and M.
* The reviewer of the changes is a separate read-only agent session, not a person (see "Review").

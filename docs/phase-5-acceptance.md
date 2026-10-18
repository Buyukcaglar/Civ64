# Phase 5 acceptance record

Phase 5 (prompt section 9) is the Win32 back end and the remaining Win32-headless API tests. Gate:
"Each implemented API has a headless or Win32-headless test. The message tables are reviewed."

**State, 2026-10-10 11:45 UTC: the gate is met.** The labels of prompt section 10 are kept apart at
the end.

| Gate item | Method | Result |
|---|---|---|
| 1. Each implemented API has a headless or Win32-headless test | The Win16 APIs (`w16`): the phase-4 headless tests and scenarios (`phase-4-acceptance.md`). The host services of `platform/w16/host.h` implemented by `platform/win32/host_win32.c`, and the bridge `platform/w16/host_sync.c`: `tests/win32/test_host_win32.c` (built as `w32_test_host_win32.exe`, run by `test.cmd` in every variant), table below | **met** (Win32-headless; quiet mode: no dialog, no sound) |
| 2. The message tables are reviewed | Independent review (subagent, effort xhigh), `docs/verify/phase5-message-tables.md`: 2 defects, 3 risks, 8 notes; all defects and risks fixed, notes recorded; resolution table in the same file | **met** (reviewed; the fixes had no second independent review) |
| 3. All variants build and test (plan P5-6) | `build.cmd` Checked, Release, Asan; `test.cmd` in each | **met**: BUILD_OK in all three; TESTS_OK in all three (11:03–11:36, scratch `frchk/all3-p53.cmd`), `w32_test_host_win32` 79 checks; Checked also GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK, P4_TESTS_OK, TRACE_OK; start-up g-50 reaches the title menu (444 frames, 0 out-of-range records), its final frame differs from g-49 only by the OK button's focus rectangle (F85) |

## The host services and their tests

`test_host_win32.c` runs with a hidden window and `hw_set_quiet(1)` (host_message to stderr, the
file choice cancelled, sounds and beeps counted, never played).

| Service | Check |
|---|---|
| host_alloc, host_free | zero-filled block |
| host_fault, host_exit | child process of the test: the report text and exit code 3; exit code 7 |
| host_log, host_coverage | called (OutputDebugString; no-op) |
| host_file_open/read/write/seek/size/truncate/close/exists/delete, host_dir_list | the files sandbox under `<outdir>\win32-files`: round trip, truncate, 8.3 listing, refusals of `..`, drives, wildcards; `hw_valid_relpath`, `hw_refused_dir` (`\original\CIVWIN`, any case) |
| host_local_datetime, host_now_us, host_sleep_until_us | monotonic clock; sleep reaches its target |
| host_present | palette-to-DIB conversion, dirty rectangle, clipping (`hw_pixels`) |
| host_poll_event | keys (vk, scan, extended), the Windows-1252 character and dropped characters, mouse scale and clamp, capture release, focus loss (Tab first under Alt, every held key released), SC_KEYMENU, WM_CLOSE |
| host_set_cursor | predefined and module cursors; WM_SETCURSOR answered in the client area |
| host_play_sound, host_beep | quiet: one sound and one beep counted, a path with `..` refused, stop |
| host_system_font | vgasys.fon read once (or absent) |
| host_message, host_choose_file, host_confirm_overwrite | quiet: stderr; cancelled; no overwrite |
| host_sync (bridge) | a host key reaches the emulated queue; host timing follows the host clock; a poll never sleeps; poll costs are not slept off at the next wait; a wait sleeps; classic timing does not jump; the keypad under the emulated NumLock (VK_NUMPAD1, lParam), its key up after NumLock changed, Shift+keypad passes; no input dropped |

Not covered headless (recorded): the visible file-choice dialog and MessageBox, audible sound,
WM_DPICHANGED (needs a monitor change), ring overflow, SC_CLOSE posting with an active window.

## Fixes made during the gate (2026-10-10)

* Review P5MT-1..P5MT-13 (`docs/verify/phase5-message-tables.md`, resolution table): keys posted
  without a window (to the focus), focus/capture-loss releases, keypad modifiers and key-up mapping,
  DPI sizing, drop logging, poll costs never slept off at a later wait.
* F85 (user observation 2026-10-10, `STATUS.md` user directions): MenuZ's title mode keeps
  WM_ACTIVATE from DefDlgProc, so activation now gives a dialog the control CreateDialog chose
  (`user_wnd.c`, `user_dlg.c`); the first Enter at the title menu presses OK (headless: WM_COMMAND
  101, the menu closes at 22.0 s; a second Enter skips the Birth scenes after world creation).
* The Win32-headless test no longer shows UI (an earlier version showed a fault dialog on the
  user's desktop: `w16_reset` ran before civ.exe was loaded; fixed by loading the pinned civ.exe
  first and by quiet mode).

## Labels (prompt section 10)

* **Compiled:** civ64.exe and `w32_test_host_win32.exe` in Checked, Release and Asan (strict C17,
  x64, /W4 /WX as `build.cmd` sets).
* **Headless-tested:** the full suite (`test.cmd`) per variant; the Win32-headless test (79 checks).
  Headless experiments (Checked harness, scratch scripts, run directories removed afterwards): key
  presses without a window at the title menu (F85) and during the credits (any key jumps to the
  title menu: Enter at 5.0 s gives it at 6.87 s).
* **Agent-observed:** a silent civ64 smoke run (Release, data copy without .WAV files, window
  captured with PrintWindow into `build/frames/p53-civ64`, 2026-10-10 about 11:40): scale 3 (client
  1920 x 1440 at 96 DPI), the setup dialogs drawn, a posted Enter took "Chieftain" and showed "Level
  of Competition". The run had already passed the title menu and the Birth scenes before the
  agent's first key: the user confirmed (2026-10-10 about 11:45, "Yes I interacted inadvertently")
  that those inputs were theirs, on the foreground window.
* **Oracle-compared:** none in this phase.
* **User-confirmed:** the original's title-menu and Birth-skip behaviour (user's description, F85),
  the intro skip (user's description); civ64 itself not yet confirmed by the user.
* **Unverified:** behaviour on a DPI change, sound output, the visible common-dialog replacement,
  long play under `--timing host` and `classic`; full civ64 build and `RUNNING.md` are phase 6.

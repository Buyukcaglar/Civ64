# Brief: unit UX1 (DOS pointer size; host close, Alt+F4 and Exit with a warning)

> **Cycle rule changed 2026-10-15 about 14:09 UTC (the user's decision, STATUS "User directions"; `verify/BRIEF-cy.md`):** wherever this brief says "the eight-step cycle", a unit now ends with the **three-step cycle** (`build.cmd checked`, `test.cmd checked`, `ext_g1.py check`); the full eight-step cycle runs only at phase gates (D4, BS, D5, D6, D7, X9, WL and before the final Asan pass).

Written 2026-10-15 by the orchestrator of extension session E3. One implementer on the session's own model,
exclusive ownership of the files below, started when the orchestrator gives it the build slot (after
D4c1). The user's words are in STATUS.md "User directions", 2026-10-15 about 14:03 (items 1 and 2).

## 1. The DOS pointer's size

"DOS cursor (torch) is larger than Windows counterpart, make dos cursor size approx. windows counterpart
with integer scaled down. (without loosing its fidelity)"

* Today the DOS profile's pointer (E's shape, `pdos_cursor`, the cursor route of D3b1 and draft B 6.7) is
  scaled like the frame: the 320x200 frame's factor is about twice the 640x480 frame's at the same host
  size, so the torch appears about twice as large, relative to the window, as the Windows game's cursor.
* Requirement: the DOS pointer is drawn with a whole-number nearest-neighbour factor (no filtering, so
  every DOS pointer pixel stays an exact block: "without losing its fidelity") chosen so that its
  displayed size best approximates the Windows game cursor's displayed size at the same host size (for
  example the factor the Windows profile's 640x480 frame has, or the factor that best matches the visible
  extent of the Windows arrow; decide, state the rule and its formula, and test it at the 7.1 host sizes).
  At least 1. The hotspot is scaled by the same factor. It holds in N (320x200) and A (640x480) frames, in
  windowed and full-screen modes and after DPI changes; the factor is recomputed when the frame factor
  changes (5.7 "Cursor"). Mouse mapping is unchanged (it never depended on the pointer's size).
* Record as a FIDELITY entry (the user's direction; the DOS program's pointer relative to its 320x200
  screen is larger) and in DESIGN 12.7 (B 6.7). P0 unaffected (presentation and host cursor only).

## 2. Close button, Alt+F4 and "Exit Sid Meier's Civilization 64bit"

"Bring back close button to host application, make app respond and honor ALT+F4 and add 'Exit Sid
Meier's Civilization 64bit' to the end of the host context menu, this kind of abrupt exit shall issue a
warning dialog box if the player is in the actual game, that unsaved progress will be lost, along with
the Exit Anyway and Cancel buttons."

* This reverses F112 (the user's request of 2026-10-10 22:40) for the close button and Alt+F4. Read
  FIDELITY F112, F106, F108, F109 and the LP record (`ext-LP-record.md`) first.
* The host window's close button works again (no CS_NOCLOSE; the system menu keeps an enabled SC_CLOSE,
  which is what enables the button). The last item of the host system menu reads "Exit Sid Meier's
  Civilization 64bit" (with "Alt+F4" as its accelerator text if the standard Close item is reused for it;
  avoid two items that do the same thing). Alt+F4 on the host window, the close button, that item and the
  system menu's Close (if kept) all take the same path.
* Alt+F4 becomes a host command (5.11, I7): it never reaches the emulated queue, the emulated key state
  stays consistent (the Alt rule of I7 and DESIGN 5's Alt hold-back), and the chord audit of D3b2
  (`ext-D3b2-record.md`, DESIGN.md) is updated: what Alt+F4 did in the game before (the emulated
  DefWindowProc's SC_CLOSE path, P4-5) is recorded as the Windows behaviour the host now takes over.
* "In the actual game": from the moment the game window opens (WdwMapOpen, the same moment phase G's
  game desktop starts following the window, F105/F110) until civ64 exits. Before that (intro, title,
  Birth, setup screens) the exit happens at once, without a question. Decide how the host knows the
  state (an observer query or the existing G hook) and record it.
* In the game: a host modal dialog with the caption "Sid Meier's Civilization 64bit", a message that
  unsaved progress will be lost, and the buttons "Exit Anyway" and "Cancel" (Cancel the default and the
  Escape answer). It follows the colour preference like the About box (F109) if that is cheap; it is
  outside the virtual screen and the observer (class W, like the About box). Cancel returns to the game
  with nothing changed. While the dialog is open the game waits as it does for the About box.
* Exit: civ64 ends cleanly (the settings file and window placement written as at a normal exit, F111;
  the emulation stopped without running more game code; exit code 0). Never a save. The decision logic
  (state x command -> exit now / ask / ignore) is a pure helper with Win32-headless unit tests; the
  dialog itself is not shown in tests (quiet mode).
* P0: the emulation and the core input are untouched until the exit; a cancelled exit leaves no trace in
  the core. The harness is unaffected (no host window).

## Files you own

`platform/win32/host_win32.c`, `host_win32.h`, `win64/*` (civ64 shell, resource script if the menu text
lives there), `present/dos/pdos_cursor.c/.h` and the cursor route in `present/` as needed,
`tests/win32/test_host_win32.c`, `tests/test_pdos_cursor.c`, `tests/test_present.c` (cursor factor
goldens), `test.cmd` only if a step is added, your record `claude/port/docs/ext-UX1-record.md`. Not
`platform/w16/`, `core/`, `rt/`, `gen/` outputs, or documents other than your record ("For the records":
DESIGN 5 and 12.7, FIDELITY F112 (reversed in part) and new entries, RUNNING (chords, menu, the exit
dialog), FEATURES (host rows), STATUS, `manual-checklist-ext.md`: pending user checks for the pointer
size in DOS frames, the close button, Alt+F4, the Exit item, the warning in the game and none before it).

## Rules and cycle

As `BRIEF-d4.md` "Rules" (P0; no DOS bytes; never write `dos/` or `build/dosdata`; no DOS program; no git
writes; absolute paths; Python only as `C:/Python314/python -B`; Write/Edit for files with backslashes;
independence; lean context). A short agent check with a visible civ64 window is allowed (civ64 windows
only, screenshots under `claude/port/build/ext-ux1-ui/`; stop on "user interrupt", no retry), not
required. Eight-step cycle after the last source change (logs `build/ux1-<n>-<step>.log`, status
`build/ux1-status.txt` ending `ALL_GREEN`). If the orchestrator sends "wrap up", stop adding, make build
and tests green and write the record.

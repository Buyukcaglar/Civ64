# Extension unit UX4b (Ctrl+Shift+Home resets the map zoom) - record

Unit UX4b of the "civ64" extension adds the user's chosen extra key for the map zoom reset (STATUS.md "User
directions", row "2026-10-16 about 15:05"; checklist item M-3's main row, `docs/ext-UX4-record.md` Decision 3).
Session E3, 2026-10-16. Host only. Staged in `build/ux4b-stage/` (the orchestrator's staging protocol); bases taken
15:20 UTC from the tree after UX4's copy-in (each C base equals UX4's landed copy, `build/ux4-prep/landed.sha256`).
D5P landed meanwhile (copy-in 15:32:39 UTC) and changed `tests/harness/ext_adapt.py` (its d-title-noquit and
title-return cases, no overlap): UX4b's three blocks were re-applied onto D5P's copy at 15:50 UTC, which is that
file's base now; D5P touched none of the four other files. The private overlay was made at 15:34 UTC from the tree
after D5P's copy-in, so every private build and test ran on the tree with UX4 and D5P.

Labels:

* **compiled**: `build.cmd checked`, `build.cmd checked noobs` and `build.cmd` (Release) of a private overlay
  (`obj/mkoverlay.py`: the tree's source folders with the staged files on top, `obj/src`), each with `--nogen` by
  `obj/b.cmd` / `obj/ball.cmd`: strict C17/x64 (`/W4 /WX /permissive- /fp:precise`), `/std:c11` and `/std:c17` and
  the clang-tidy C99 parse of every portable source, the test programs, the harness, civ64.exe and the
  Win32-headless tests; every output under the overlay's own `build/`.
* **headless**: the overlay's `test_*.exe` (test.cmd's `unit` loop, `obj/ut.cmd`), argv[1] `build/gamedata`
  (read), argv[2] under the stage.
* **Win32-headless**: the overlay's `w32_test_*.exe` (hidden windows, quiet mode), the same arguments.
* **harness**: `obj/runadapt.py`, D6d's private runner: the STAGED `tests/harness/ext_adapt.py`'s `plain` run and
  extension M's runs (`m_runs`: zoomkeys, ring, ringref, and D6d's zoomkeys-dos and ring-dos) with the overlay's
  Checked `civ_harness.exe`, every run and output under `obj/run`; the tree's `build/gamedata`, `build/dosdata`
  and `build/cache` read only.

Scope: no DOS program was executed; nothing was written to `C:\Projects\Civ1RE\dos`, `C:\Projects\Civ1RE\original`,
`build/dosdata`, `build/gamedata`, `build/x64`, `build/harness` or any other shared output; build.cmd and test.cmd
of the tree were not run; civ64 was not launched and no window was shown (hidden test windows only); no git command
that writes was run; no global or low-level hook was installed. Read: only `claude/` (and the MSVC environment set up
by `scripts\Setup-Msvc.cmd` as build.cmd does). Not edited: `core/`, `rt/`, `res/`, `platform/w16/`, `present/input.h`,
`build.cmd`, `test.cmd`, the generated tables and every document other than this record ("For the records").


## Status

**LANDED 2026-10-16** (copy-in 16:30:48 UTC, ALL_GREEN 17:02:30 UTC, RELEASE_OK 17:06:49 UTC; user build
`build/user-builds/ux4b/`; section "Landing"). The user's check M-3b is pending on build "ux4b".

At staging: **READY_TO_BUILD.** Staged and tested privately (compiled, headless, Win32-headless, harness; Checked,
CheckedNoObs, Release; section "Results"). Its build slot comes after D5P's landing (the orchestrator); D5P is
landed (`build/d5p-status.txt`: ALL_GREEN 16:05:23, RELEASE_OK 16:10:16 UTC), and at 16:14 UTC the five bases
still equal the tree's, this record is absent from the tree, and the overlay equals the tree but for the five
staged files. The user's check M-3b is pending a user build ("ux4b"; a draft of its text:
`build/ux4b-stage/obj/WHAT-TO-CHECK.draft.txt`).


## The user's words

STATUS.md "User directions", 2026-10-16 about 15:05, the user's answer to the M-3 question (offered: Ctrl+Shift+keypad
\*, Ctrl+Shift+N, Ctrl+Shift+Home, or Ctrl+Shift+0 only), verbatim:

> "Add Ctrl+Shift+Home"

The orchestrator's brief for UX4b: Ctrl+Shift+Home also resets the map zoom, exactly like "Normal map zoom",
alongside the main-row and keypad Ctrl+Shift+0; the window menu's accelerator text names it; the gray Home key and
the keypad Home (Num Lock off) both count, with the decision and its reason recorded; without Ctrl+Shift, Home still
goes to the game unchanged.


## Findings

1. **How Windows delivers Home.** The gray Home key is `VK_HOME` (0x24) with scan code 0x47 and the extended bit
   (lParam bit 24), 0x147 in `PiKey.scan` (`scan_of`). The keypad's 7 is `VK_HOME` with scan 0x47, not extended,
   while Num Lock is off; with Num Lock on it is `VK_NUMPAD7` (0x67), and with Num Lock on and Shift down Windows
   first releases Shift itself (a system keystroke, UX4's `PiKey.fake`) and then gives `VK_HOME` 0x47, pressing Shift
   again after the key's release: the same mechanism as the keypad's 0 becoming `VK_INSERT` (UX4 Finding 1). So
   with Ctrl+Shift held, the gray Home and the keypad's 7 with Num Lock off arrive as `VK_HOME` with Ctrl and Shift
   down; the keypad's 7 with Num Lock on arrives as `VK_HOME` after Windows' Shift release.
2. **Free.** civ64's chords (Alt+Enter, Alt+F4, Ctrl+Shift+Backspace, Ctrl+Shift+Plus/Minus/0 and their keypad
   keys) do not use Home. The game's accelerator table (civ.exe's ACCELERATOR 128) has no Shift entry (UX4
   Decision 3), so no Ctrl+Shift chord is a game accelerator; this machine's IME hot keys (Ctrl+Shift+G/K/L/V,
   Ctrl+Shift+comma, read for UX4) do not use Home.
3. **What the game received before.** Ctrl+Shift+Home was no chord: the held Ctrl and Shift presses were delivered,
   then Home (K3). The emulated Windows 3.1 controls the game uses read `VK_HOME`: the EDIT control
   (`platform/w16/user_ctl.c`: the caret to the start, Shift extends the selection, Ctrl is not read), list boxes
   (`user_listbox.c`: the first item) and menus (`user_menutrack.c`). So in a Windows-profile name box,
   Ctrl+Shift+Home selected to the start of the text; from UX4b it is the zoom reset there too (the chords do not
   depend on the screen, as Ctrl+Shift+0 since M), while Shift+Home still selects to the start and Home alone still
   moves the caret.
4. **The arrival stage needs one case.** Since UX4, `zoom_key(vk, scan)` gives each zoom chord's command and
   `ctrl_shift_cmd` holds the chord condition (a press with Ctrl and Shift down, Alt up, the key not already
   delivered down; only a press without the repeat bit gives the command). UX4's held-back Windows Shift release is
   dropped only before the keypad's 0 (`VK_INSERT` with scan 0x52) making the reset; before any other key it is
   taken first.
5. **"Exactly like Normal map zoom".** The chord's command goes through `player_zoom` -> `pmap_zoom_command(RESET)`
   -> `pmap_request_zoom(0, no anchor)`, the menu item through `pmap_request_zoom(0, no anchor)`: the same level-0
   request with the centre anchor, recorded through the zoom hook (civ64's `zoom` key), the menu's radio mark
   following. (At level 0 the chord is a no-op and records nothing; the menu item re-records 0: no visible
   difference.)
6. **Runs for the reset chord.** `tests/harness/ext_adapt.py`'s **zoomkeys** run (extension M) is the zoom chords'
   end-to-end run in host form through the harness's arrival stage (each chord line `events 0` with its command, the
   run equal to `plain` in core input, frames, snapshots and events); D6d's **zoomkeys-dos** repeats its lines in the
   DOS profile. `ext_zoom.py` drives the zoom with script commands, not keys (no `hkey` line), and `test_map.c`'s
   chord loop lists the six M keys: neither needs a change.


## Decisions

1. **Both Home keys count: `VK_HOME` whatever its scan code.** The gray Home (0x147) and the keypad's Home with Num
   Lock off (0x47) are the same key to Windows and to the user (both labelled Home, both `VK_HOME` with Ctrl and
   Shift down). UX4 told the keypad's 0 from the gray Insert only because Insert has no zoom meaning while the
   keypad's 0 is the chord's 0; nothing like that separates the two Homes. A Home sent by a remapping tool (any scan
   code) counts too.
2. **The keypad's 7 with Num Lock on is not the chord** (unchanged from before UX4b: Ctrl, Shift, Windows' Shift
   release, Home reach the game). With Num Lock on that key is the digit 7; Windows makes it Home only by releasing
   Shift itself, and UX4's held-back release is dropped only for the keypad's 0, which the user's M-3 required with
   Num Lock on. Taking the 7 would make the keypad's Ctrl+Shift+7 a zoom key while the main row's Ctrl+Shift+7 is
   not, and the brief names "the keypad Home (Num Lock off)". No code is needed for this: after the release is
   taken, Shift is up and `ctrl_shift_cmd` gives no chord.
3. **Taken exactly as Ctrl+Shift+0.** One `case` in `zoom_key`: the same command (`PI_CMD_ZOOM_RESET`), the same
   rules (a press without the repeat bit gives one reset; its repeats and release and the Ctrl and Shift held for it
   never reach the game; with Alt down, or with Home already delivered down, no chord; without the observer
   (`CIV_OBSERVER 0`) no zoom chord at all, Home reaches the game).
4. **The menu text names both chords in full**: "&Normal map zoom\tCtrl+Shift+0, Ctrl+Shift+Home". A shorter form
   ("Ctrl+Shift+0 / Home", "or Home") would read as the Home key alone, which is the game's key. The mnemonic N
   stays; the accelerator column becomes wider (29 characters; Ctrl+Shift+Backspace was the widest, 20).
5. **ext_adapt's zoomkeys run gets four chords** at free times in play (the S3 lines leave 59,350..61,000 and
   61,050..64,000 ms free): the gray Ctrl+Shift+Home at 59,600 ms (after the zoom in at 59,300: level 1 to 0), a
   main-row Ctrl+Shift+Plus at 59,900 ms (back to 1), the keypad's Ctrl+Shift+Home with an auto-repeat at 62,000 ms
   (1 to 0) and a keypad Ctrl+Shift+Plus at 62,300 ms (back to 1). So both Home chords really reset, and the run is
   still at level 1 from 59,300 to 66,000 ms but for two 300 ms dips: a first try with the resets alone (and a zoom
   out between them) halved the run's zoomed shows (76 -> 34, DOS 74 -> 31), less coverage of the layer drawn at
   +1 across the turns at 61,000 and 64,000 ms. The existing checks cover the new lines (each `events 0` with its
   command, the run equal to `plain`; the same in zoomkeys-dos); no PASS line is added, so `EXT_ADAPT_OK checks 154`
   (since D5P) stays.


## What was built

* `present/arrive.c`: the header paragraph "Extension UX4b"; `#define PI_VK_HOME 0x24u`; in `zoom_key` (observer
  builds) `case PI_VK_HOME: return PI_CMD_ZOOM_RESET;`. Nothing else: `ctrl_shift_cmd`, the hold rule and UX4's
  held-back release are unchanged.
* `platform/win32/host_win32.c`: the header paragraph; "Normal map zoom"'s text in both branches of the system
  menu (grayed without the observer, as before).
* `tests/test_input.c`, `tests/win32/test_host_win32.c`, `tests/harness/ext_adapt.py`: section "Tests".
* This record.

Not changed: `present/input.h` (no new member or command), `host_win32.h`, civ64's settings (the reset is
recorded as before), test.cmd and build.cmd (no BUILD-TEST-ADDITIONS).


## Tests

`tests/test_input.c`, block "extension UX4b", `ux4b_home()` after UX4's `ux4_keypad()` (the arrival stage):

* observer builds (14 checks): Ctrl+Shift+gray Home (0x147): the reset, no event; its repeat: nothing; the chord's
  releases: nothing; Shift then Ctrl then the keypad's Home (0x47): the reset, no event; its releases: nothing; then
  A alone: the state is clean; Ctrl+Shift+keypad 7 with Num Lock on (Windows' Shift release, then Home 0x47 with
  Ctrl only): no command, Ctrl, Shift, its release, Home; Home alone: delivered (scan 0x147); its release; Shift+Home:
  Shift, Home; Ctrl+keypad Home: Ctrl, Home; Alt+Ctrl+Shift+Home: no chord, Home delivered; a Home delivered down
  before Ctrl+Shift: its repeat is no chord (Ctrl, Shift, Home delivered) and its release reaches the game.
* CheckedNoObs (1 check): Ctrl+Shift+Home: Ctrl, Shift, Home reach the game.

`tests/win32/test_host_win32.c` (the window procedure, `hw_window_message`, hidden window):

* `test_window_d3b2`: the zoom items' texts now expect "&Normal map zoom\tCtrl+Shift+0, Ctrl+Shift+Home" (the same
  check; in CheckedNoObs too: the grayed item has the same text).
* block "extension UX4b", `test_ux4b_home()` after UX4's `test_ux4_box()`; observer builds (8 checks), each from
  level +1 (the menu's Zoom in, UX4's `ux4_level1`) where a reset is expected: Ctrl+Shift+gray Home (lParam bit 24):
  level 0, no event; from +1 again, its auto-repeat and the releases: level stays +1, no event; Ctrl+Shift+keypad Home
  (0x47, Num Lock off): level 0, no event; Num Lock on (Windows' Shift release with bit 25, then `VK_HOME` 0x47):
  level stays +1, Ctrl, Shift, its release, Home reach the game; Home alone: `VK_HOME` 0x147 reaches the game, the
  level unchanged; its release; Shift+Home: Shift, Home; Ctrl+keypad Home: Ctrl, Home (scan 0x47). CheckedNoObs (1
  check): Ctrl+Shift+gray Home: Ctrl, Shift, Home reach the game, level 0.

`tests/harness/ext_adapt.py`: `ZOOM_VKS["24"] = "zoom_reset"` and the four `ZOOM_EVENTS` of Decision 5 (block
"extension UX4b"); the docstring names them.


## Results

Private, 2026-10-16 (Istanbul time is UTC+3). The overlay (`obj/mkoverlay.py`, 15:34 UTC) is the tree after UX4's
and D5P's copy-ins with the five staged files on top (the rebased `ext_adapt.py` copied in at 15:50 and again after
Decision 5's rework, 15:58 UTC); the C bases equal the tree's (`BASE-SHA256.txt`).

| variant | build (`obj/ball.cmd`: `obj/b.cmd`, build.cmd `--nogen`) | headless + Win32-headless (`obj/ut.cmd`) |
|---|---|---|
| Checked | `BUILD_OK` 15:43:32 UTC; portable sources checked: 293 (c11, c17, c99 parse) | 0 failed of 52 programs (and `check_ne.py` errors 0): `test_input` 449, `w32_test_host_win32` 395 |
| CheckedNoObs | `BUILD_OK` 16:02:24 UTC; 293 | 0 failed of 52 programs: `test_input` 393, `w32_test_host_win32` 366 |
| Release | `BUILD_OK` 16:08:36 UTC; 293 | 0 failed of 52 programs: `test_input` 449, `w32_test_host_win32` 395 |

Against UX4's private runs (`build/ux4-stage/obj/ut-*.log`, the tree before D5P) the PASS lines differ only in these
two programs and in D5P's three (`test_pdos_adapt` 145 -> 155, `test_pdos_aspect` 61 -> 80, `test_pdos_seq` 190 ->
214: D5P's own predictions, `build/d5p-prep/predictions.txt`); against D5P's landing run (`build/d5p-2-test-checked.log`,
Checked) only in `test_input` 435 -> 449 and `test_host_win32` 387 -> 395.

Harness (`obj/runadapt.py` with the overlay's Checked `civ_harness.exe`; `obj/runadapt-Checked.txt`, 16:04 UTC):
`RUNADAPT checks 14 failed 0`, the 14 PASS lines of extension M and D6d:
* `zoomkeys equals the plain run (coreinput 38, frames 764, snapshot/result 13, events 94)` (as before);
* "zoomkeys: 79 chord and wheel lines, each `events 0` with its command (zoom_in 6, zoom_out 3, zoom_reset 5, none
  65)" (was 54: zoom_in 4, zoom_out 3, zoom_reset 3, none 44); `the map layer drawn in 76 shows` (as before);
* ring, ringref, ring-dos: as before (ring equals ringref; ring-dos equals ringref; DOS layer 155 shows);
* `zoomkeys-dos equals the plain run`; `zoomkeys-dos: 79 chord and wheel lines` (was 54); one switch, `the DOS layer
  drawn in 72 shows` (was 74).
The first try (`obj/runadapt-Checked-1.txt`, the resets without the zoom-ins back: Decision 5) also passed all 14
(73 lines: zoom_in 4, zoom_out 4, zoom_reset 5, none 60) but with 34 and 31 zoomed shows instead of 76 and 74.

Other checks test.cmd runs, privately on the overlay: `tests/harness/obs_lint.py` (the overlay's): `OBS_LINT_OK
files 119 probes 203 callsites 98`; `gen/dos/registry.py check` (the overlay's, `--dosdata` and `--disasm` the
tree's, read): `REGISTRY_OK`; `gen/dos/nodos.py check --root <overlay> --variant V`: `NODOS_OK` for Checked (612
files), CheckedNoObs (612) and Release (611), 0 hits each. `testpar.py` was not run: test.cmd is unchanged. Not run:
the other harness sections (no harness C, core or w16 change), G-1 and P0 (the build slot's cycle).

The compiled overlay's sources equal the staged files (`STAGED-SHA256.txt`); the staged files keep their bases' line
endings (`obj/eol.py check`: EOL_OK).


## Expected expectation changes

* `test_input`: +14 checks in the observer builds (Checked 435 -> 449, Release 449), +1 in CheckedNoObs (392 -> 393).
* `w32_test_host_win32`: +8 in the observer builds (Checked 387 -> 395, Release 395), +1 in CheckedNoObs (365 -> 366).
  The zoom items' text check keeps its count with the new text.
* `ext_adapt.py` (section ext_adapt; `EXT_ADAPT_OK checks 154`, since D5P, unchanged): the zoomkeys line "54 chord
  and wheel lines, each `events 0` with its command (zoom_in 4, zoom_out 3, zoom_reset 3, none 44)" becomes "79 ...
  (zoom_in 6, zoom_out 3, zoom_reset 5, none 65)"; zoomkeys-dos's
  `54 chord and wheel lines` becomes `79` and its `the DOS layer drawn in 74 shows` becomes `72 shows` (two 300 ms
  dips to level 0 in DOS play); `the map layer drawn in 76 shows` and every other line as at D5P's landing; the
  host-input file `build/adapt/s3-host-zoomkeys.hostinput` gets the 25 new lines.
* Nothing else: the arrival stage's events are those of before for every input except Ctrl+Shift+Home with Ctrl and
  Shift down (Home and its held modifiers reached the game before); no script, golden or harness line other than
  ext_adapt's zoomkeys lines uses Ctrl+Shift+Home; the core is not touched (P0 and G-1 hold: no core, w16 or harness
  C change), so ext_g1 (`EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)`), P0, ext_zoom, test_map and the
  other sections stay as at D5P's landing cycle (which follows UX4's).

Predictions for the build slot: `build.cmd checked` BUILD_OK (portable sources checked 293, 52 test programs);
`test.cmd checked` TESTS_OK with the counts above, every other section's outputs as at D5P's landing cycle except
host-time lines (and coverage.py's informational "other functions entered", which moves from run to run);
`ext_g1.py check` `EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)`; `build.cmd` (Release) BUILD_OK.


## Rebase notes

Shared files and UX4b's blocks in them (each marked "extension UX4b"; re-apply onto a newer tree copy as listed).
The bases are UX4's landed files and D5P's landed `ext_adapt.py` (re-based once, see the head of this record):

* `present/arrive.c`: the header paragraph after UX4's ("Extension UX4 (end)."); the `PI_VK_HOME` define after UX4's
  defines; the `case PI_VK_HOME` in `zoom_key` after UX4's `case PI_VK_INSERT`. A unit that reworks `zoom_key` keeps
  `VK_HOME` -> `PI_CMD_ZOOM_RESET` for every scan code, observer builds only.
* `platform/win32/host_win32.c`: the header paragraph after UX4's; the "Normal map zoom" `AppendMenuW` line in both
  branches of the system menu (`add_menu`). A unit that changes that menu keeps the text, or changes
  `test_window_d3b2`'s expected text with it.
* `tests/test_input.c`: the block after UX4's block (it uses UX4's `fkey`, `T_HOME`) and the call after
  `ux4_keypad();` in `main`.
* `tests/win32/test_host_win32.c`: the comment and text in `test_window_d3b2`'s zoom-items array; the block after
  UX4's block end (it uses UX4's `ux4_level1`, `ux4_ctrl_shift`, `UX4_FAKE`, and `klp`); the call after
  `test_ux4_box();` in `main`.
* `tests/harness/ext_adapt.py`: the docstring's zoomkeys sentence; the block after `ZOOM_VKS` and the block after
  `ZOOM_EVENTS`. A unit that adds S3 lines between 59,350 and 64,000 ms must keep these times free (or move them).


## Build-slot steps

1. From the port root: check the 5 bases of `build/ux4b-stage/BASE-SHA256.txt` (and that the record is absent). Any
   base that changed since (D5P's landing is already in them): re-apply UX4b's blocks onto the tree's copy ("Rebase notes"), keeping the file's line
   endings (`tests/test_input.c` CRLF, the other four LF; `obj/eol.py check`), and recompile privately (`build/ux4b-stage/obj/mkoverlay.py`, `obj/ball.cmd`,
   `obj/ut.cmd src <variant>`, `obj/runadapt.py`) before going on.
2. Copy the 5 staged files into the tree at the same paths (`STAGED-SHA256.txt`); copy this record to
   `docs/ext-UX4b-record.md`. No build.cmd or test.cmd change.
3. The three-step cycle: `build.cmd checked`, `test.cmd checked`, `C:/Python314/python -B tests/harness/ext_g1.py
   check`, with the predictions above; then `build.cmd` (Release).
4. A user build "ux4b" (Release civ64.exe; CIVWIN.zip and civdos.zip as before) with `WHAT-TO-CHECK.txt` from "What
   the user checks"; the docs pass applies "For the records".


## What the user checks

* **M-3b** (new; Ctrl+Shift+Home, the extra key for normal zoom): in play, zoom in or out first (Ctrl+Shift+Plus or
  Ctrl+Shift+Minus, or the mouse wheel over the map). Then hold Ctrl and Shift and press **Home**: the map goes back
  to its normal size, and nothing else happens in the game (no unit moves, no menu opens). Do it with both Home keys
  if your keyboard has both: the Home key in the block above the arrow keys, and the 7 on the number pad with Num
  Lock **off** (the Num Lock light off; on the number pad that key is also labelled Home). Press Home alone, or
  Shift+Home: they work in the game as before (no zoom change). Open the window menu (the icon at the left of the
  title bar, or Alt+Space): "Normal map zoom" now shows "Ctrl+Shift+0, Ctrl+Shift+Home". With Num Lock **on**, the
  number pad's 7 is the digit 7 and Ctrl+Shift with it does not reset the zoom (on purpose). If Ctrl+Shift+Home does
  nothing at all on your PC, please say so: a keyboard tool may take it, as with the main row's Ctrl+Shift+0.
  A side effect to know (not a fault): in the Windows graphics' name boxes (leader and tribe names), Ctrl+Shift+Home
  used to select the text up to its start, as in Windows 3.1; now it resets the zoom instead. Shift+Home still
  selects to the start, and Home alone still moves the cursor to the start.


## For the records

For the docs pass (UX4b edits no document other than this record):

* **RUNNING.md**: the keys table row "Ctrl+Shift+Plus, Ctrl+Shift+Minus, Ctrl+Shift+0 (main row and keypad)": add
  Ctrl+Shift+Home (the gray Home and the keypad's 7 with Num Lock off) to the reset (and UX4's keypad sentence: with
  Num Lock on, Ctrl+Shift+keypad 0 now works; the keypad's 7 with Num Lock on is no chord); the system menu
  paragraph ("show Ctrl+Shift+Minus, Ctrl+Shift+0 and Ctrl+Shift+Plus"): "Ctrl+Shift+0, Ctrl+Shift+Home"; the
  ext_adapt row: zoomkeys has twelve zoom chords (was eight; two of them Ctrl+Shift+Home) and three wheel lines.
* **FIDELITY.md** (F114, the chords' list from M): "From UX4b also Ctrl+Shift+Home (`VK_HOME`, gray and keypad with
  Num Lock off)." And a **deviation note** (the orchestrator's direction at UX4b's build slot), in F114 or as its own
  entry next to it: "Deviation from Windows 3.1 (extension UX4b, the user's choice of Ctrl+Shift+Home for the zoom
  reset): Windows 3.1's EDIT control takes Ctrl+Shift+Home as Shift+Home with Ctrl (the caret to the start of the
  text, the selection extended to it; `platform/w16/user_ctl.c` does the same and does not read Ctrl). In civ64 the
  arrival stage takes Ctrl+Shift+Home as the map zoom reset before the game sees it, so in the Windows graphics' name
  boxes (leader and tribe names) Ctrl+Shift+Home no longer selects to the start of the text; Shift+Home still does,
  and Home alone still moves the caret. (**choice**, the user's direction of 2026-10-16 about 15:05 UTC; user check
  M-3b.)" The same holds for the list boxes and menus that read Home (`user_listbox.c`, `user_menutrack.c`):
  Ctrl+Shift+Home no longer reaches them, Home does.
* **DESIGN.md 12.5 / ext-d1-draft-D.md 13** (the zoom chords): Ctrl+Shift+Home as one more reset key.
* **win64/civ64_main.c** comment ("The player's change (Ctrl+Shift+Plus, Minus, 0, the wheel ...)"): add Home (a
  comment only; UX4b did not stage `civ64_main.c`).
* **manual-checklist-ext.md**: new item M-3b ("What the user checks"); M-3's main-row note points to it.
* **STATUS.md**: UX4b's row (the user's 15:05 direction implemented).


## Landing (2026-10-16, build slot)

**Landed 2026-10-16 16:30:48 UTC; cycle ALL_GREEN 17:02:30 UTC; RELEASE_OK 17:06:49 UTC; user build
`build/user-builds/ux4b/`.**  Done by the build slot on the orchestrator's instruction, after the joint UX4 + D5P
docs pass (`build/docs-d5p-done.txt`, 16:30:40 UTC, "docs-d5p done", not BLOCKED; it edited docs only). No MZ
landing was in progress (no `mz-prep` or `mz-status.txt`).

1. **Bases.** `build/ux4b-prep/land.py` (UX4's script with the UX4b names, 6 rows): all 5 tree files still had their
   bases (`build/ux4b-stage/BASE-SHA256.txt`; `ext_adapt.py`'s is D5P's landed copy, the others UX4's), this record
   was absent, and the 6 staged copies had the SHA-256 frozen in `build/ux4b-prep/staged.sha256` (frozen at 16:16 UTC
   after the record's last staging edit: the FIDELITY deviation note and the name-box note in M-3b, the
   orchestrator's direction). Dry run `DRY_RUN_OK 6`. No rebase was needed at the slot (the one rebase, onto D5P's
   `ext_adapt.py`, was made in staging).
2. **Snapshot and copy.** Before writing: the tree's Checked test outputs (59 files of `build/test/Checked`, D5P's
   cycle) in `build/ux4b-prep/before`, the tree's previous 5 files in `build/ux4b-prep/tree-before`. The 6 files byte
   for byte (5 changed, this record new): `LANDED 6`; manifest `build/ux4b-prep/landed.sha256` (with test.cmd's and
   build.cmd's unchanged SHA-256); `landed-at.txt`. No build.cmd or test.cmd change.
3. **Cycle** (`build/ux4b-prep/ux4b-cycle.ps1`; status `build/ux4b-status.txt`, logs `build/ux4b-<n>-<step>.log`):
   - 1 build-checked: exit 0, 234 s, BUILD_OK; portable sources checked 293; 52 test programs.
   - 2 test-checked: exit 0, 1663 s, TESTS_OK, 27 sections, failed 0. `w32_test_host_win32` passed at the first run
     (395 checks): no GetKeyState rerun and no -r2 test step were needed.
   - 3 g1-checked: exit 0, EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events): **ALL_GREEN**.
   - 4 build-release: exit 0, 247 s, BUILD_OK: **RELEASE_OK**.
4. **Comparison** (`build/ux4b-prep/compare.py`, output `compare.txt`; the predictions in
   `build/ux4b-prep/predictions.txt` were written about 16:17 UTC, before the copy-in; prediction against output in
   `build/ux4b-prep/comparison.txt`): 53 of 59 files equal (lines with times left out). The differences, all
   predicted:
   - `sections/unit.log`: `test_input` 435 -> 449 and `test_host_win32` 387 -> 395 checks; the OBS_COST line (host
     time).
   - `ext-adapt.txt`: "zoomkeys: 79 chord and wheel lines ... (zoom_in 6, zoom_out 3, zoom_reset 5, none 65)" (was
     54: zoom_in 4, zoom_out 3, zoom_reset 3, none 44); "zoomkeys-dos: 79 chord and wheel lines" (was 54); "the DOS
     layer drawn in 72 shows" (was 74). "zoomkeys: the map layer drawn in 76 shows" and `EXT_ADAPT_OK checks 154`
     unchanged.
   - `sections/times.txt`: section times (wall 1661 s).
   - `coverage.txt` and `sections/coverage.log`: "other functions entered" 666 -> 662 (informational, moves from run
     to run; rt entries 145 of 155 unchanged).
   - `nodos.txt`: 1727 -> 1728 files (this record), 0 hits.
   Every other output equal: REGISTRY_OK, NODOS_OK, OBS_TABLES_OK probes 203 sites 98, OBS_LINT_OK files 119 probes
   203 callsites 98, ADAPT_OK rows 98 steps 22, P0_OK checks 476, EXT_ASPECT_OK, MIRROR_OK runs 29, REPLAY_OK checks
   70, ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32, and the other sections.
5. **User build** `build/user-builds/ux4b/`: `civ64.exe` (the Release build, SHA-256 7aa33f0c...31c8dfdd3),
   `CIVWIN.zip` and `civdos.zip` (byte-identical copies from `user-builds/d4`, SHA-256 checked) and
   `WHAT-TO-CHECK.txt` (M-3b in plain words: both Home keys, Num Lock off for the keypad's, Num Lock on not a reset,
   Home and Shift+Home unchanged, the menu's text; the name-box side effect: in the Windows graphics' name boxes
   Ctrl+Shift+Home now resets the zoom instead of selecting to the start, Shift+Home still selects; the builds it
   contains: d5p, ux4, d6d, sl and the earlier ones; the items still open).
6. **Not done here**: the entries of "For the records" (RUNNING, FIDELITY F114 and the name-box deviation note,
   DESIGN 12.5 / draft D 13, civ64_main.c's comment, the checklist's M-3b, STATUS) are the next joint docs pass's.

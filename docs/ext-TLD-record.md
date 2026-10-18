# Extension unit TLD (the title menu behind the Load dialog) - record

Draft for the build slot.  The user's report (STATUS "User directions" 2026-10-16 about 20:03 UTC, with a screenshot):
"Windows mode, Load a Saved Game has adverse effect on the title menu."  The screenshot: the title picture and the
host's "Select a File" dialog; behind the dialog the title menu box is gone except a light-gray L (its top and left
edges), black inside.  The orchestrator's ruling: the screen behind the dialog must match the original (the whole
menu box or a cleanly erased area, never a partial frame); after Cancel the title menu returns whole, with its
selection intact; the Windows graphics' 4:3 and square shapes both work; the DOS graphics and the core's behaviour
are unchanged.  The coordinator's addition (accepting the fix as proposed): audit every other host call that blocks
the game thread while the host shows the last present, give each the same call where the core may have drawn since
the last present, add a check where it is visible, and list every path checked, including those that needed nothing.
Staged in `build/tld-stage/` on the tree after MZW and UX5.  MZI, SI and MZS landed later and changed none of TLD's
files.  Private builds and runs in `build/tld-stage/obj/` only:
* an overlay `obj/src` (tree + stage) built with build.cmd's own flags;
* private harness copies in `obj/exe`;
* GUI runs of civ64.exe with a private home and data copy.

## Status

LANDED: copy-in 2026-10-17 01:31:02 UTC, cycle ALL_GREEN 02:05:31 UTC, RELEASE_OK 02:09:36 UTC, user build
`build/user-builds/tld/` (section "Landing").  TLD-1..TLD-7 pending the user's checks.

* Behind the host's file dialog the Windows graphics now show the game's current picture.  At the title's Load a
  Saved Game this is the title picture with the menu's area cleanly redrawn (no box, no L), as in the original.
  After Cancel the title menu returns whole, as before.
* The same defect also showed in play, where a host file dialog opens right after the game closed a box.  Auto Save's
  dialog after the Civilization quiz stood over the closed quiz box; the dialog of the end game's Write Replay to Disk
  and a menu's Save Game showed an earlier picture.  These now show the current picture too.
* How: before the game thread blocks in a host box, w16 gives the presentation its pending output
  (`w16_present_view`, presentation only).  No present is added, so the core frame trace (frames, their times and
  count), the snapshots, the events and G-1 are unchanged.
* The same call guards the back end's own modal boxes and loops: the window menu, a move or size, the exit warning
  and the profile refusal.

Private results: section "Results".

## The cause

1. **The core, in the original's order** after MenuZ returns 1 (Load a Saved Game) at the title
   (`core/seg061_11E0.c`):
   * GetWindowRect of the menu window, 11E0:0740 (line 726);
   * OffsetRect by the movie window's WindowPort rectangle, 11E0:0764 (line 734): its window rectangle 60,76, not its
     client origin 64,80, so the rectangle is 4 pixels off to the top left;
   * GR_DialogClose of the menu, 11E0:076F (line 739): w16's SetWindowPos erase (`platform/w16/user_wnd.c`
     `sync_erase`) fills the uncovered movie area with its light-gray background;
   * FillRect with BLACK_BRUSH, 11E0:078E (line 750): the offset rectangle, which leaves a 4-pixel light-gray L at
     the menu window's top and left edges;
   * RedrawSequenceWindow, 11E0:07D7 (line 775): SetGodPaletteFromHandle 10B0:0406
     (`core/seg021_10A0_s.c` line 825) changes the palette, which forces a present (core frame 448: the L), then
     CopyPortToWindow 10B0:0452 (line 856) copies the whole 512x320 title picture back, which removes the L and the
     black from the virtual screen;
   * LoadGameFromFileDialog 11E0:0802 (line 783), then GetOpenFileName 1130:0107 (`core/seg039_1130.c` line 135).
2. **The port.**  The final CopyPortToWindow was never presented before the dialog.  `w16_present`
   (`platform/w16/gdi_pal.c` line 388) presents at most once per 16,667 us of virtual time (forced only by palette
   changes) and only at PeekMessage, the clock queries, SetCursor and the DOS calls.  `platform/w16/commdlg.c` line
   136 calls `host_choose_file` directly, and the Win32 back end's chooser (`platform/win32/host_win32.c` line 1968,
   DialogBoxIndirectParamW) blocks the game thread.  The window therefore showed the last present (frame 448, the
   L) for as long as the dialog was open.  The harness shows it: the chooser comes right after frame 448; the clean
   frames 449 and 450 come only after it returns.  Only the top and left edges remain because of the original's own
   4-pixel offset (11E0:0749..0764), which leaves the L for an instant.  The port froze that instant.

## The original

Under Windows 3.1 GDI output reaches the screen at once.  CopyPortToWindow 10B0:0452 repaints the whole movie
client before GetOpenFileName, and the common dialog's modal loop dispatches the movie window's pending WM_PAINT.
Behind the dialog the original therefore shows the title picture with the menu's area cleanly erased: the title
picture's own pixels there, no box, no L.  This is the core's virtual screen at the chooser.

After Cancel the core shows the title menu again (dialog 139), whole, with Start a New Game selected: 11E0:067A sets
`g_mainMenuChoice` to 0 before MenuZ.  This is the menu's selection as the original sets it, and civ64 already did
so before TLD.

## Since when

This is a base-track defect, not an extension regression.  It dates from phase 5 (the Win32 back end's chooser over
phase 4's throttled presentation; `commdlg.c` of 2026-10-09).

Every user build shows it.  GUI runs (`obj/gui.py`: the title, Load a Saved Game, a shot of the client with the
dialog open, Cancel, a shot) of all 21 builds:
* user-check-d4b4, d4, d4cf, ux1, bs, d5c, d5d, d5e, d5, ux2, d6c, d5k, ux3, d5k2, sl, d6d, ux4, d5p, ux4b, mz, mzw;
* each one shows the light-gray L with black inside while the dialog is open (`obj/lcheck.py`: the L at 214,300 and
  300,257, the menu's face absent at 300,300), and the whole menu box after Cancel.

G-1 is green on every landing, so the frame lines before the chooser in game/gate3b-s2 and p4-load equal the
pre-extension baseline: the pre-extension port presented the same frame 448 last.

## The other title choices and the DOS Load

The defect needs a host box or loop that blocks the game thread while output is pending.  At the title only Load a
Saved Game opens one (GetOpenFileName, through `host_choose_file`):
* **Start a New Game, Play on EARTH, Customize World, View Hall of Fame**: these are the core's own screens and
  dialogs (MenuZ, the Birth, the Hall of Fame).  They are drawn into the virtual screen and run their own message
  loops, which present.  No host box is involved, so they have nothing to fix.
* **Load a Saved Game, then a file chosen (Open)**: the same dialog as Cancel, over the same stale frame before
  TLD.  With TLD it opens over the clean title picture (ext_tld.py `w-load`), and the game loads as before.
* **The DOS graphics' Load** (unit SL): the DOS slot screen is drawn by the presentation over the DOS frame, so
  nothing of the stale Windows frame shows.  The core's sequence before GetOpenFileName is the same.  The DOS
  profile shows only through its ticks, so its view is unchanged by TLD (ext_tld.py `d-escape`: presented.log
  identical to the tree's).  A switch on the slot screen (Ctrl+Shift+Backspace) gives the Windows chooser for the
  same call.  Before TLD it showed the stale L behind it; with TLD it shows the clean title picture (`d-switch`).
* **The file dialogs in play** (the same COMMDLG path).  Each dialog was compared between the base harness and the
  fixed one: ext_p0's 27 scenarios in V2, V3 and V4, plus private runs with the `[chooser]` line.
  * At gate3b-s2's two Save Game dialogs (`w-save`), and at most others, nothing is pending.  The Windows frame was
    already current and TLD adds no show.
  * Three dialogs came right after the core drew, and showed an earlier picture before TLD (`windows_frame STALE`
    with a harness without the call; `obj/ingame.py`, `obj/png/ig-*.png`):
    * **scenarios.py's quiz**, Auto Save's GetSaveFileName at 60,000 ms, right after the third Enter closed the
      quiz box (MenuZ 149).  Before TLD the closed quiz box stayed behind the dialog (core frame 602); with TLD the map
      shows (the virtual screen's picture, frame 603's content).  `ext_tld.py` `w-quiz` checks it.
    * **conquest**, the dialog of Write Replay to Disk at 52,500,650 us, after the replay menu closed.
    * **menus**, the File menu's Save Game at 129,602,100 us: the map with the active unit's blink a frame earlier.
  * The soaks s4 and s5 of ext_mirror have such dialogs too: their present checks go +1 and +2 (section "Expected
    changes").

## The fix

* `platform/w16/gdi_pal.c`: new `w16_present_view()`, declared in `platform/w16/host.h` as a w16 service for the
  back ends.  When something is pending (the dirty rectangle, or the whole screen after a palette change) and a
  first present was made, it runs `present_core_frame` on that rectangle inside the observer's guard, exactly as
  `w16_present` does.  The result: the Windows frame, every profile's `on_core_present` and the shown picture (when
  the visible profile shows core frames) become the virtual screen's.  It does not call `host_present` and leaves
  the dirty rectangle, the palette flag and the throttle's clock as they are.  The next `w16_present` therefore
  presents the same output at the same virtual time as before: the core frame trace and the counts are unchanged.
  It is forbidden inside the observer's guard (`W16_OBS_FORBID`), as `w16_present` is.
* `platform/w16/commdlg.c`: `file_dialog` (GetOpenFileName and GetSaveFileName) calls it once, before its loop of
  `host_choose_file` calls (the Win32 chooser, the DOS slot screen, the headless answers).
* `platform/win32/host_win32.c`: `view_current()` (the call, counted for the tests: `hw_view_flushes`, declared in
  `host_win32.h`) at each modal entry the back end runs on the game thread:
  * WM_INITMENU, the window menu's opening; the boxes opened from it follow (About, Locate DOS files..., Exit);
  * WM_ENTERSIZEMOVE, a move or size of the window;
  * `exit_warning`: the close button (SC_CLOSE without the menu), Alt+F4 and WM_CLOSE;
  * `player_profile`: the profile chord and items, whose refusal shows a message box once per run.
* Under Windows 3.1 that output was on the screen already.  Presentation only: the core, w16's state and the frame
  trace are untouched (P0).  The DOS graphics show through their ticks, so `w16_present_view` changes nothing
  visible in DOS.  The DOS profile's `on_core_present` sees the same rectangle again at the next present, as after
  any present.

The design alternative, a forced `w16_present(1)` before the chooser, would add a frame line (a state change) to
every run with a title Load.  G-1 never amends state, so it was not taken.

## The audit of blocking host paths (the coordinator's addition)

The Win32 back end is single-threaded: the game thread runs its message loop (`pump`) at its polls
(`host_poll_event` from `w16_host_sync`, taken before the PeekMessage present), its waits (`host_sleep_until_us`),
`host_present` and the slot screen's loop.  Every modal host UI runs inside one of these.  Each path checked:

| Path | Where | Blocks the game thread | Output pending at entry | TLD |
| --- | --- | --- | --- | --- |
| COMMDLG GetOpenFileName / GetSaveFileName: the Win32 chooser | `commdlg.c` `file_dialog` -> `host_choose_file`, `host_win32.c` DialogBoxIndirectParamW (1968) | yes | yes (the title's Load: the redraw after the forced present) | `w16_present_view` in `file_dialog`; check `ext_tld.py` (fails before TLD: STALE, the L) |
| The DOS slot screen (SL) | the same call, the slot screen's loop | yes | yes (the same) | the same call (DOS: nothing visible changes); check `ext_tld.py` d-escape, d-switch |
| The overwrite question (Save As) | `commdlg.c` -> `host_confirm_overwrite`, `hw_message_box` | yes | no: no game code runs between the chooser (already flushed) and it | nothing needed |
| The window menu (Alt+Space, the icon, a right click on the title bar) | DefWindowProc's menu loop | yes | possible | `view_current` at WM_INITMENU; check `w32_test_host_win32` |
| About, Locate DOS files... (IFileOpenDialog, its notes), the profile items, Exit item | from the window menu (WM_SYSCOMMAND after WM_INITMENU) | yes | no new: no game code since WM_INITMENU | covered by WM_INITMENU |
| A move or size of the window (title bar drag, the frame) | DefWindowProc's move/size loop | yes | possible | `view_current` at WM_ENTERSIZEMOVE; check `w32_test_host_win32` |
| The exit warning | `exit_warning` (3078): the close button (SC_CLOSE), Alt+F4 (PI_CMD_CLOSE), WM_CLOSE | yes | possible | `view_current` in `exit_warning`; check `w32_test_host_win32` |
| The profile chord's refusal (Ctrl+Shift+Backspace without the DOS files) | `player_profile` -> `present_player_profile` -> `host_message` once per run | yes | possible | `view_current` in `player_profile`; check `w32_test_host_win32` (WM_SYSCOMMAND 0x1090: the same function) |
| A fault, an exhausted host memory | `host_message` (`host_win32.c` 198, 168) | yes | possible, but the run ends | nothing needed |
| civ64's start-up messages and questions (Locate at the start, `fail`) | `civ64_main.c`, `civ64_locate.c` (746, 775, 782) | yes | no: before the game runs (no present yet) | nothing needed |
| `host_sleep_until_us` | `w16_host_sync`'s wait | at most the throttle's interval | yes, briefly | nothing needed: no box; WM_PAINT shows the retained picture and the next present follows |
| `host_play_sound`, `host_beep` | the game's sounds (asynchronous; the only synchronous call is the stop, 1150:012D), MessageBeep | no | - | nothing needed |
| Alt+Enter (full screen), the zoom chords, the wheel, the zoom items | `arrived`, `player_zoom` | no (no modal loop) | - | nothing needed |
| The game's own MessageBox, dialogs and menus (Win16) | `user_msgbox.c`, `user_dlg.c`, `user_menutrack.c` | no: drawn into the virtual screen; their PeekMessage loops present | - | nothing needed |

The headless back end has no modal UI.  Its `host_choose_file` answers at once and now prints the `[chooser]` line
(section "Tests").  `civ64_cfg.c` has no dialog.

## What was built

| File | Change |
| --- | --- |
| `platform/w16/gdi_pal.c` | `w16_present_view` (above) |
| `platform/w16/host.h` | its declaration, a w16 service for the back ends |
| `platform/w16/commdlg.c` | the call before the choosers; the header comment's bullet |
| `platform/win32/host_win32.c` | `view_current` and `hw_view_flushes`; the calls at WM_INITMENU, WM_ENTERSIZEMOVE (new case), `exit_warning`, `player_profile` |
| `platform/win32/host_win32.h` | `hw_view_flushes` |
| `tests/headless/host_headless.c` | the `[chooser]` console line (`chooser_line`) |
| `tests/win32/test_host_win32.c` | `test_tld_view` |
| `tests/harness/ext_tld.py` (new) | the harness check |
| `test.cmd` | the section `ext_tld` (Checked) |
| `docs/ext-TLD-record.md` (new) | this record |

## Tests

* **The `[chooser]` console line** (`tests/headless/host_headless.c`), at each file dialog the headless back end
  answers (not at a slot screen the tokens answer):

      [chooser] open|save virtual_us US profile P shown N SHA windows_frame current|STALE|none

  It gives the visible profile, the shows so far, the last shown frame's hash, and whether the Windows frame equals
  the virtual screen's RGB.  That is S1's relation, with MZW's `pmap_smrect_owns` exception.
* **`tests/harness/ext_tld.py`** (test.cmd section `ext_tld`, Checked; 7 runs in parallel, 13 s to about 80 s
  depending on the machine's load; the docstring has the details).  All runs use `--presented 1`:
  * the runs:
    * w-cancel: the title's Load in host form (ext_slots.py's: ext_adapt's D5f title path, 30,000 ms) in the
      Windows graphics at 4:3, the dialog cancelled;
    * w-square: as w-cancel with `--aspect square`;
    * w-load: as w-cancel, answered CAE3540B.SAV;
    * d-switch: the DOS graphics, the chord on the slot screen, then the answer;
    * d-escape: the DOS graphics, Escape on the slot screen;
    * w-save: gate3b's S2 in the Windows graphics (Load and two Save Game dialogs);
    * w-quiz: scenarios.py's quiz in the Windows graphics (its script and edited QUIZ.SAV written by ext_tld.py
      itself, with the tree's `scenarios.sc_quiz` and `saveedit`).
  * M and P, from w-cancel: M is the title menu as first shown, and P is the picture shown just before it (the title
    picture without the menu).
  * The checks:
    * at the title's dialog of w-cancel, w-square, w-load, d-switch and w-save, the shown Windows frame is current
      and is P;
    * every core show keeps the relation;
    * after Cancel, the first show unlike P is M: the menu whole, Start a New Game selected;
    * w-square's show lines equal w-cancel's;
    * w-load, d-switch and w-save reach after-load;
    * at w-save's Save Game dialogs the frame is current with nothing pending: the only core frame number shown twice
      is the title's;
    * at w-quiz's three dialogs the frame is current; at Auto Save's after the quiz the pending output is shown (the
      core frame numbers shown twice are exactly the title's and Auto Save's);
    * d-escape shows the slot screen and no host dialog, and makes no core show.
  * `EXT_TLD_OK` (20 checks).  It fails on the defect:
    * the tree's harness (after MZI) has no `[chooser]` line (EXT_TLD_FAILED=9);
    * a private harness with the `[chooser]` line but without the call in `commdlg.c` (`obj/src-defect`) gives
      EXT_TLD_FAILED=8: `windows_frame STALE` and the L's hash 30bffdd5... at the title's dialog of all six runs, and
      at Auto Save's after the quiz STALE with the quiz box's frame (b7adc9f2...).
* **`w32_test_host_win32` `test_tld_view`** (15 checks, after test_exit, in its game state and window):
  * a pixel of the virtual screen changed with its rectangle dirty and no present;
  * WM_INITMENU, WM_ENTERSIZEMOVE, WM_CLOSE in the game (Cancel) and WM_SYSCOMMAND 0x1090 (the profile item, the
    chord's function) each show the pending pixel first (`present_shown_frame`);
  * each adds no present (`hw_frames`) and counts one view (`hw_view_flushes`);
  * the next `w16_present` still presents (the dirty rectangle kept);
  * with nothing pending, no present.
  * Against a back end whose `view_current` only counts (`obj/w32defect.cmd`) it fails its four entry checks.

## Results (private, `build/tld-stage/obj/`)

* **Builds** (`obj/final.sh`: the overlay `obj/src` from the tree after SI's copy-in plus the stage, build.cmd
  --nogen with its own flags): Checked, CheckedNoObs and Release each `BUILD_OK` with `portable sources checked: 294
  (c11, c17, c99 parse)`, no warning (1,351 s, 389 s and 299 s on the loaded machine).
* **A Checked build after MZS's copy-in** (the overlay remade from the tree with MZS's files plus the stage):
  `BUILD_OK`, `portable sources checked: 294 (c11, c17, c99 parse)`, no warning (347 s).
* **Strict checks of the changed C sources** (`obj/cc.cmd`: c11 and c17 /W4 /WX, the clang C99 parse; `gdi_pal.c`,
  `commdlg.c`, `host_win32.c`, `host_headless.c`, `test_host_win32.c`; each variant):
  * Checked and Release: `CC_OK`, all five files.
  * CheckedNoObs: c11 and c17 pass for all five, and the C99 parse for the first four.  On `test_host_win32.c` the C99
    parse reports three unused static functions (`wheel_lp` line 953, `ux4_level1` 1262, `ux4_post_pad0` 1281): they
    are called only inside `#if CIV_OBSERVER` blocks.  The tree's own copy gives the same three findings at the same
    lines (`obj/tidytree.cmd`), so they predate TLD; `test_tld_view` adds none.  build.cmd's C99 parse covers the
    portable sources only, not `tests/win32`, so the cycle is not affected.
* **Unit tests** (`obj/ut.sh` and `obj/ut32.sh`: every `test_*.exe` but test_ne, and every `w32_test_*.exe`, as
  test.cmd's unit section runs them; each variant): 47 + 5 programs, all PASS in Checked, CheckedNoObs and Release.
  `w32_test_host_win32`: Checked 410 checks, Release 410, CheckedNoObs 381.  The base test linked to the same
  CheckedNoObs objects (`obj/w32var.cmd`) gives 366, so `test_tld_view` adds 15 checks in every variant (Checked
  395 -> 410).
* **testpar.py check** on the staged test.cmd: exit 0.  **obs_lint** (the overlay): `OBS_LINT_OK files 120 probes
  203 callsites 98`, the tree's line unchanged.  **registry.py check**: `REGISTRY_OK`.  **nodos.py check** (Checked,
  the overlay): 615 files, 0 hits, `NODOS_OK`.
* **ext_tld.py**:
  * TLD's harness: `EXT_TLD_OK` (20 PASS); again with the harness built after MZS's copy-in: `EXT_TLD_OK` (20 PASS,
    13 s on a less loaded machine);
  * the tree's harness after MZI: `EXT_TLD_FAILED=9` (no `[chooser]` line);
  * the defect harness `obj/src-defect` (the `[chooser]` line, no call in commdlg.c): `EXT_TLD_FAILED=8`, with
    STALE and the L 30bffdd5... at every title dialog and the quiz box b7adc9f2... at Auto Save's.
* **w32_test_host_win32** (`obj/w32only.cmd`: the staged test linked to the overlay's Checked objects): PASS 410
  checks.  Linked against a `host_win32.c` whose `view_current` only counts (`obj/w32defect.cmd`): FAIL, 4 failures,
  exactly the four entry checks of `test_tld_view` (WM_INITMENU, WM_ENTERSIZEMOVE, WM_CLOSE, WM_SYSCOMMAND 0x1090).
* **The suites against the tree's harness after MZI** (section "Expected changes"): every core trace equal; the
  output text differences exactly those listed there.
* **GUI, civ64.exe with a private home and data copy** (`obj/gui.py`, PrintWindow shots of the client, `obj/lcheck.py`):
  * the overlay's Release:
    * Load a Saved Game, Cancel, again Load and Cancel: while the dialog is open the clean title picture (no L, no
      box), after each Cancel the whole menu with Start a New Game selected;
    * the same with `--aspect square`;
    * Load and Open CAE3540B.SAV: the game loads and play starts.
  * the overlay's Checked civ64 (the observer's O4 checks on):
    * Load and Cancel as above;
    * in play after a Load: the window menu opened (SC_KEYMENU) and closed, a keyboard move (SC_MOVE) started and
      ended, WM_CLOSE's exit warning; civ64 stayed alive through each, with no O4 fault (W16_OBS_FORBID in
      `w16_present_view` would end the run).
  * No civ64 process was left running after any run.
* **All 21 user builds** (section "Since when"): the L while the dialog is open, the whole menu after Cancel.

## Expected changes at the build slot

Against the tree's Checked test outputs at the slot: D6e's cycle (ALL_GREEN 01:23:53 UTC; D6e landed after MZS,
so its counts are the base below; the numbers D6e left as they were are MZS's too).  These come
from private runs of each suite with the tree's harness after MZI and with TLD's (`obj/suites.sh`, `obj/runp4.py`,
`obj/zooms4.sh`; `obj/cmproots.py` compares every run's frame, snapshot and result lines, `events.log`,
`coreinput.log`, `presented.log`, `profiles.log`, `mirror.log` and `timeline.log`), and for ext_zoom's other runs
with TLD's harness after MZS's copy-in against MZS's cycle (`obj/zoomrest.sh`):

* **The core trace: unchanged everywhere.**  The run.log frame, snapshot and result lines, `events.log` and
  `coreinput.log` of every compared run are equal: ext_p0 223 runs, ext_adapt 83, ext_mirror 29, ext_slots 15,
  ext_continue 11, ext_aspect 9, ext_timeline 9, ext_tld's 7, p4tests.  `tests/harness/ext_g1.py check`: EXT_G1_OK
  runs 77, amendments unchanged (amended 1: game/p4-menus frames events).
* **build**: BUILD_OK; `portable sources checked: 295` (D6e's count), unchanged: TLD adds no portable source.
* **sections**: the new section ext_tld (`[TLD: ext_tld.py Checked: ...]`, `EXT_TLD_OK`, `ext-tld.txt` with 20 PASS
  lines); 27 -> 28 sections in `sections/times.txt`.
* **unit** (`sections/unit.log`): `test_host_win32: PASS (395 checks, 0 failures)` -> 410 checks.  Every other
  test program unchanged.
* **ext-p0.txt**: `P0_OK checks 476` unchanged.  Two lines change, both from the quiz's Auto Save dialog, which now
  shows the current map with the layer:
  * `PASS V4 quiz zoom (presented.log): 101 -> 102 shows with the layer`;
  * `PASS V4d quiz zoom (presented.log): 120 -> 121 shows with the layer`.

  Every other line is equal.  Inside the outputs, the `presented.log` of 74 runs (V2 18, V3 17, V4 17, V4d 17,
  V6 1, V6w 1, V7 3; V1, V8 and V8s write it unchanged, V0 and V6r write none) gains one CORE show at the title's
  Load, plus one more in conquest, menus and quiz.  This is never compared.
* **ext-mirror.txt**: `MIRROR_OK runs 29`.  The present checks go +1 where a flush in play ran the map display
  model's present check (it passes: `present_mismatched 0`):
  * s4: checks 5342 -> 5343, present 3440 -> 3441;
  * s5: checks 7014 -> 7016, present 5644 -> 5646;
  * menus: 1708 -> 1709, 1313 -> 1314;
  * quiz: 544 -> 545, 132 -> 133;
  * conquest: 352 -> 353, 187 -> 188;
  * MIRROR_TOTAL: checks 21706 -> 21712, present 13380 -> 13386.

  The other 24 lines are equal.
* **p4tests** (`sections/p4tests.log`): `P4_TESTS_OK`.  One line changes: `PASS p49-prf-game: ... end presents 536 ->
  537 relation_mismatches 0 tick_shows 0` (the title's Load).
* **ext-zoom.txt** (`ZOOM_OK`; every sample equal to the golden, D6e's golden too if D6e lands first): the two s4
  lines' show counts go +2 in each profile, the two flushes in play (core frames 1938 and 3638; the title's flush at
  449 is no zoomed show).  D6e's cycle has the same s4 counts as MZS's, so:
  * `ZOOM ok s4 1920x1440 integer -1 shows sw 3993/win 3686 samples 78` -> `sw 3995/win 3688`;
  * `ZOOM ok s4 1920x1440 integer +1 shows sw 3900/win 3629 samples 78` -> `sw 3902/win 3631`.

  In each of the six s4 runs the CORE shows without TLD's three flushes equal the base run's (`obj/zoomdup.py`).
  Every other line (new, load, orders, centre, mzi, mzs: 50 lines) is equal to MZS's cycle's, with TLD's harness
  after MZS's copy-in (`obj/zoomrest.sh`).  The title's flush in the load, mzi and mzs runs is no zoomed show and
  no view.  The `ZOOM_OK` total line is unchanged, D6e's ` not zoomed 38/448` included (overlap notes, d6e).
* **Equal**, every line:
  * ext-adapt.txt: `EXT_ADAPT_OK checks 154`.  Inside, presented.log of d-load-escape-win and d-load-win-win gains
    the title's show, and d-load-win-dos's switch view shows the clean title picture instead of the L;
  * ext-slots.txt, ext-aspect.txt, ext-continue.txt, ext-timeline.txt: private runs equal line for line;
  * ext-frames.txt (start, s3, birth: no file dialog);
  * gate3b, scenarios, uninit (no `presented.log`);
  * ext-bs-*, ext-replay.txt (no file dialog).
* **nodos.txt**: files +2 (`tests/harness/ext_tld.py` and this record; D6e's cycle 1742 -> 1744), binaries
  unchanged, another byte total; 0 hits, `NODOS_OK`.  The private check on the overlay (without the record): 615
  files, 0 hits.
* **obs-lint.txt**: `OBS_LINT_OK files 122 probes 203 callsites 98` (D6e's line), unchanged (the overlay's run
  before D6e: 120 / 203 / 98, the tree's line then).
* **coverage.txt**: "other functions entered" may change (informational: `w16_present_view`, `chooser_line`).
* **Goldens**: none changes.
  * ext_zoom's golden: every sample equal (above).  The title's flush has no zoom fields, and the in-play flushes
    fall between samples.
  * ext_timeline's goldens: DOS shows only.
  * present-goldens.txt: test_present, no w16.
  * gate3b-golden.txt: frames unchanged.

## Overlap and rebase notes

* **Landed since the bases were taken.**
  * MZI (copy-in 21:29:09 UTC: `present/map/*`, `tests/test_map.c`, `ext_zoom.py`, its golden, its record), SI
    (22:42:18 UTC: `win64/civ64_main.c`, `civ64_start.c/h`, `tests/win32/test_single.c`, `drive_civ64.py`, its
    record) and MZS (23:47:40 UTC: `present/map/pmap_dos.c`, `pmap_int.h`, `pmap_inview.c`, `tests/test_map.c`,
    `ext_zoom.py`, its record) changed none of TLD's files; none of them changed test.cmd or build.cmd.
  * Every base was rechecked equal to the tree's file after MZS's copy-in (`BASE-SHA256.txt`).
  * UX5's test.cmd (landed 20:28 UTC) is TLD's base.
  * The final private overlay (three variants) was made from the tree after SI, so it contains MZI's and SI's files.
    A second Checked overlay, made after MZS's copy-in, contains MZS's files too; ext_tld.py and ext_zoom's other
    runs used it (section "Results").
* **d6e-stage** (has the build slot before TLD): no common file.  D6e changes `tests/headless/harness.c`,
  `ext_zoom.py` and its golden, and DOS files.
  * ext_tld.py reads presented.log's show lines by field name (`virtual_us`, `sha256`) and `core_frame` as the third
    word, so a field added at the end changes nothing.
  * ext_zoom after D6e: the ZOOM_OK line gains ` not zoomed 38/448` (the DOS small map's model, profiles.log
    `smmap`, compared -1 against +1 at the sample times), and the golden's 240 `dos` lines change.  Neither moves with
    TLD: the pairs and sample times are fixed by the runs, and `smmap` is taken at the sample times from the core's
    state, which TLD does not touch.  D6e leaves `dos_on_core_present` as it is, so the extra on_core_present of a
    flush stays a repeat of the next present's rectangle.  TLD's only ext_zoom change after D6e stays the two s4
    lines, +2 shows per profile on D6e's counts.
  * Not run privately: a combined D6e + TLD build.  The cycle at TLD's slot checks it (compare.py).
* **d6f-stage**: no common file.
  * `ext_adapt.py` is shared indirectly.  ext_tld.py imports D_LOAD, D_LOAD_W and d_write; D6f's copy adds its own
    runs and calls d_write, but leaves those three as they are.  ext_tld.py's other imports, `scenarios.py` and
    `saveedit.py`, are changed by no stage.
  * D6f's `w16_obs.h` adds menu queries but leaves W16_OBS_FORBID and the guard macros as they are.  Its
    `obs_lint.py` adds pure menu getters to its list; `w16_present_view` is no pure function and uses the guard as
    `w16_present` does.  Its `present/present.c` adds a diagnostic line; `present_core_frame`'s signature stays.
  * D6f's DOS profile changes: TLD's flush calls each profile's `on_core_present` with the pending rectangle once
    more before the next present, as an earlier present would.  If D6f lands first: rerun ext_tld.py (d-switch,
    d-escape) and ext_adapt's d-load-* runs.
* **mzs-stage** (`present/map/*`, `tests/test_map.c`, `ext_zoom.py`): no common file.
* **d6c-stage** (the restaged D6c: `present/dos/pdos_compose.*`, `present/map/*`, `ext_mirror.py`,
  `tests/test_map.c`): no common file.  If D6c lands first, ext_mirror's numbers move with D6c's changes; TLD's
  part stays +1 present check per flush in play (s4 +1, s5 +2, menus, quiz and conquest +1 each).
* **test.cmd**: the only shared file in the queue.  BUILD-TEST-ADDITIONS.md has the two insertions to re-apply if
  test.cmd changes first.
* **No rebase needed now**: none of TLD's 8 changed files differs from its base.

## Build-slot steps

1. Base re-check: every staged file's tree copy still has its base (`BASE-SHA256.txt`); the two new files absent.
2. Snapshot to `build/tld-prep/before`: the tree's Checked test outputs (`build/test/Checked`) and the tree's
   previous copies of the changed files.
3. Copy-in of the 10 files byte for byte; `build/tld-prep/landed.sha256` (with build.cmd's unchanged SHA-256).
4. Predictions written before the cycle; the three-step cycle (build.cmd checked, test.cmd checked,
   `tests/harness/ext_g1.py check`) with its status in `build/tld-status.txt`; then the comparison.  The known flake:
   `w32_test_host_win32`'s GetKeyState checks (lines 1207/1241 in the base and in TLD's copy: `test_tld_view` comes
   after them): rerun that test alone, then the test step as -r2.
5. Release (RELEASE_OK).
6. The user build `build/user-builds/tld/`: the Release civ64.exe, CIVWIN.zip and civdos.zip from
   `user-builds/d4`, WHAT-TO-CHECK.txt (TLD-1..TLD-7 and the checklist's pending rows at landing as "Still open").
7. A "Landing" section here.

## What the user checks

In the Windows graphics (the default, or switch with Ctrl+Shift+Backspace), at the title menu.  Each item names the
build `build/user-builds/tld/`.

* **TLD-1** Choose Load a Saved Game.  While the "Select a File" dialog is open, the picture behind it is the whole
  title picture: where the menu was there is only the picture itself (dark), with no gray L, no half-drawn box and
  no black rectangle with light edges.
* **TLD-2** Press Cancel.  The title menu comes back whole (frame, all rows), with Start a New Game highlighted, as
  before and as in the original game.  Choose Load a Saved Game again and cancel again: the same each time.
* **TLD-3** Uncheck "4:3 aspect ratio for 320 x 200 screens" in the window menu, then repeat TLD-1 and TLD-2: the
  same picture behind the dialog and the same menu after Cancel.  Check the item again when done.
* **TLD-4** Choose Load a Saved Game and open a saved game: it loads and play starts as before.
* **TLD-5** In the DOS graphics, choose Load a Saved Game: DOS's slot screen as before; Escape returns to the DOS
  title menu.  Choose it again and press Ctrl+Shift+Backspace on the slot screen: the Windows file dialog appears
  over the whole title picture (no gray L); Cancel gives the Windows title menu whole.
* **TLD-6** In play in the Windows graphics, every file dialog stands over the game's current picture, never over a
  box the game has already closed.  Three places where it did not before this build:
  * Auto Save after the quiz: when the game's quiz box closes and the Auto Save file dialog opens right after it,
    the map is behind the dialog, not the quiz box.
  * Write Replay to Disk at the end of a game: behind its file dialog is the game's picture of that moment, not the
    box you just answered.
  * Save Game (the File menu or Ctrl+S): behind the dialog is the map as it is now, not as it was a moment earlier
    (for example the active unit at the other step of its blink).

  Cancel or Save as usual each time.  Report any file dialog that still shows a box the game already closed.
* **TLD-7** In play, open the window menu (click the icon at the top left, or Alt+Space), and drag the window by
  its title bar; also click the close button and answer Cancel: during each the game's picture stays the current
  one (no older picture flashes behind the menu, the window or the question).

## For the records

* **DESIGN.md** (the present path, near 1742, after "w16_present then calls host_present itself, unconditionally"):
  "Since TLD, `w16_present_view` (`gdi_pal.c`, a w16 service in `host.h`) gives the pending rectangle (the whole
  screen after a palette change) to `present_core_frame` inside the observer guard without `host_present`, leaving
  the dirty rectangle, the palette flag and the throttle's clock unchanged.  `commdlg.c` calls it before the file
  choosers, and the Win32 back end before its modal boxes and loops on the game thread (WM_INITMENU,
  WM_ENTERSIZEMOVE, the exit warning, the profile switch).  So a host box stands over the game's current picture, as
  under Windows 3.1, and the core frame trace is unchanged."  Also 12.1 (the headless back end): the `[chooser]`
  console line.
* **FIDELITY.md** (a new entry, number from the orchestrator; next to F182):
  * the area: the picture behind the host's modal boxes (`platform/w16/gdi_pal.c` `w16_present_view`, `commdlg.c`,
    `platform/win32/host_win32.c` `view_current`);
  * the original: under Windows 3.1 every GDI output is on the screen at once, so the common dialog of the title's
    Load a Saved Game stands over the title picture that RedrawSequenceWindow 11E0:07D7 (CopyPortToWindow
    10B0:0452) redrew after the menu's erase (11E0:076F, 11E0:078E);
  * civ64: w16 presents at most once per 16,667 us of virtual time, so before a host box blocks the game thread the
    presentation gets the pending output without a present (frame trace unchanged).  Behind the dialog: the title
    picture with the menu's area redrawn, no longer the frozen erase (the light-gray L).  In play the file dialogs
    that follow a closed box (Auto Save after the quiz, Write Replay to Disk) stand over the current picture, not
    the closed box.  The same applies before the window menu, a move or size, the exit warning and the profile
    switch's refusal;
  * presentation only, P0 (**fix**, the user's report of 2026-10-16 about 20:03 UTC);
  * status: implemented in TLD; tests `ext_tld.py`, `w32_test_host_win32` `test_tld_view`; user checks
    TLD-1..TLD-7.
* **RUNNING.md**:
  * the test table: a row for `[TLD: ext_tld.py]` (section `ext_tld`, cpu 6; Checked only), with seven harness runs:
    * the title's Load in the Windows graphics at 4:3 and square, cancelled and answered;
    * the DOS slot screen's chord and Escape;
    * gate3b's S2 and scenarios.py's quiz in the Windows graphics.

    Behind the title's file dialog the Windows frame is current and is the title picture without the menu; after
    Cancel the menu as first shown; at Auto Save's dialog after the quiz, the current picture.  `EXT_TLD_OK` (20
    checks; `ext-tld.txt`);
  * the `presented.log` row: "Since TLD, a CORE show also comes when the presentation is given the pending output
    before a host file dialog (`w16_present_view`, no core present): its `core_frame` number is the next present's,
    which follows with the same number";
  * the harness's console: the `[chooser]` line (section "Tests" above);
  * `w32_test_host_win32` 395 -> 410 checks (CheckedNoObs 366 -> 381).
* **STATUS.md**: the user direction row of 2026-10-16 about 20:03 UTC answered by unit TLD (cause: a stale present
  before the host's file dialog, base track since phase 5); unit TLD READY (staged), then landed by the build slot.
* **manual-checklist-ext.md**: a section TLD with TLD-1..TLD-7 (above), pending, build `build/user-builds/tld/`.

## Landing (2026-10-17, build slot)

**Landed 2026-10-17 01:31:02 UTC; cycle ALL_GREEN 02:05:31 UTC; RELEASE_OK 02:09:36 UTC; user build
`build/user-builds/tld/` (about 02:10 UTC).**  Done by the build slot on the orchestrator's instruction, after D6e's
landing (ALL_GREEN 01:23:53 UTC, RELEASE_OK 01:28:06 UTC, its user build).

1. **Bases.** `build/tld-prep/land.py` (10 rows): the 8 tree files (test.cmd among them) still had their bases
   (`build/tld-stage/BASE-SHA256.txt`, rewritten after D6e's landing), the 2 new files (`tests/harness/ext_tld.py`,
   this record) were absent, and the 10 staged copies had the SHA-256 frozen in `build/tld-prep/staged.sha256`;
   build.cmd (40de571d...) unchanged.  Dry run `DRY_RUN_OK 10`.  No rebase was needed: D6e (DOS files,
   `tests/headless/harness.c`, `ext_zoom.py` and its golden, `pmap_smrect.c`) shares no file with TLD and left
   test.cmd unchanged.
2. **Predictions** (`build/tld-prep/predictions.txt`, 01:30:58 UTC, before the copy-in) on D6e's cycle: portable
   sources 295, nodos 1742 -> 1744, OBS_LINT_OK files 122, D6e's ZOOM_OK line (`... not zoomed 38/448`) and golden
   unchanged, the s4 lines +2 shows per profile on D6e's counts.
3. **Snapshot and copy.** Before writing: the tree's Checked test outputs (59 files of `build/test/Checked`, D6e's
   cycle) in `build/tld-prep/before`, the tree's previous 8 files in `build/tld-prep/tree-before`.  The 10 files byte
   for byte (8 changed, 2 new): `LANDED 10`; manifest `build/tld-prep/landed.sha256` (with build.cmd's unchanged
   SHA-256); `landed-at.txt`.  test.cmd is TLD's staged copy (the section `ext_tld`); no build.cmd change.
4. **Cycle** (`build/tld-prep/tld-cycle.ps1`; status `build/tld-status.txt`, logs `build/tld-<n>-<step>.log`):
   - 1 build-checked: exit 0, 258 s, BUILD_OK; portable sources checked 295; no warning.
   - 2 test-checked: exit 0, 1800 s, TESTS_OK, 28 sections, failed 0 (wall 1798.4 s; ext_tld 37.0 s).
     `w32_test_host_win32` passed at the first run (410 checks): no GetKeyState rerun and no -r2 test step were
     needed.
   - 3 g1-checked: exit 0, EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events): **ALL_GREEN**.
   - 4 build-release: exit 0, 232 s, BUILD_OK, portable sources checked 295, no warning: **RELEASE_OK**.
5. **Comparison** (`build/tld-prep/compare.py`, output `compare.txt`; prediction against output in
   `build/tld-prep/comparison.txt`): 49 of 61 files equal (59 before, 2 new; lines with times left out).  Every
   difference as predicted:
   - `ext-tld.txt` and `sections/ext_tld.log` (new): 20 PASS lines, `EXT_TLD_OK`.
   - `sections/unit.log`: `test_host_win32` 395 -> 410 checks, 0 failures; the OBS_COST line (host time).
   - `ext-p0.txt`: V4 quiz zoom 101 -> 102, V4d quiz zoom 120 -> 121 shows with the layer; `P0_OK checks 476`.
   - `ext-mirror.txt`: s4 5342 -> 5343 / present 3440 -> 3441, s5 7014 -> 7016 / 5644 -> 5646, menus 1708 -> 1709 /
     1313 -> 1314, quiz 544 -> 545 / 132 -> 133, conquest 352 -> 353 / 187 -> 188, MIRROR_TOTAL 21706 -> 21712 /
     13380 -> 13386, present_mismatched 0; `sections/ext_mirror.log`: the MIRROR_TOTAL line.
   - `sections/p4tests.log`: p49-prf-game end presents 536 -> 537.
   - `ext-zoom.txt`: the two s4 lines sw 3993/win 3686 -> 3995/3688 and sw 3900/win 3629 -> 3902/3631; every other
     line equal, the ZOOM_OK line too (`ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32 centre runs
     4 mzi runs 12 mzs runs 4 not zoomed 38/448`); every golden sample equal.
   - `nodos.txt`: 1742 -> 1744 files, 0 hits, NODOS_OK.
   - `coverage.txt` and `sections/coverage.log`: "other functions entered" 666 -> 668 (informational: the new
     `w16_present_view` and `chooser_line`).
   - `sections/times.txt`: section times and the new `ext_tld` line.

   Every other output equal: OBS_LINT_OK files 122 probes 203 callsites 98, EXT_ADAPT_OK checks 154, REGISTRY_OK,
   OBS_TABLES_OK, ADAPT_OK, EXT_ASPECT_OK, REPLAY_OK, EXT_FRAMES_OK, EXT_TIMELINE_OK, EXT_CONTINUE_OK, EXT_SLOTS_OK,
   EXT_BS_OK, TRACE_OK, gate3b, scenarios, uninit and the other sections.  No golden changed.
6. **User build** `build/user-builds/tld/` (`build/tld-prep/mk_userbuild.py`, `USER_BUILD_OK 4`): `civ64.exe` (the
   Release build, SHA-256 cfcac204...9664dbb, 4,368,896 bytes), `CIVWIN.zip` and `civdos.zip` (byte-identical copies
   from `user-builds/d4`, SHA-256 058d4e00... and 0eac32c9... checked) and `WHAT-TO-CHECK.txt` (SHA-256
   e0f1e74c..., CRLF, ASCII): TLD-1..TLD-7 in plain words as in "What the user checks" (TLD-6 naming Auto Save after
   the quiz, Write Replay to Disk and Save Game), the builds it contains (d6e, mzs, si, mzi, ux5, mzw, mz, ux4b,
   d5p, ux4, d6d, sl and the earlier ones), the note that it runs only once at a time (SI), and the items still open
   from the checklist's pending rows at 02:09 UTC: D6e-1..D6e-7, MZS-1..MZS-6 and MZW-8, SI-1..SI-6, MZI-1..MZI-7,
   UX5-1..UX5-7, D5P-7 and P47-1 checkable (36); D6-1 and D5-7 with unit D6f.
7. **Not done here**: the checklist's TLD section, the FIDELITY entry's number and the other entries of "For the
   records" (the orchestrator and the next joint docs pass).

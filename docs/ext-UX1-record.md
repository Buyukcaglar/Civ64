# Extension unit UX1 (the DOS pointer's size; the host close button, Alt+F4 and "Exit Sid Meier's Civilization 64bit" with an in-game warning) - record

Unit UX1 of the "civ64" extension carries out items 1 and 2 of the user's direction of 2026-10-15 about
14:03 UTC (STATUS.md "User directions"):

> 1. DOS cursor (torch) is larger than Windows counterpart, make dos cursor size approx. windows counterpart
> with integer scaled down. (without loosing its fidelity)
> 2. Bring back close button to host application, make app respond and honor ALT+F4 and add 'Exit Sid
> Meier's Civilization 64bit' to the end of the host context menu, this kind of abrupt exit shall issue a
> warning dialog box if the player is in the actual game, that unsaved progress will be lost, along with
> the Exit Anyway and Cancel buttons.

Brief: [verify/BRIEF-ux1.md](verify/BRIEF-ux1.md) (the three-step cycle per its note at the top,
[verify/BRIEF-cy.md](verify/BRIEF-cy.md)). Read first: FIDELITY F112, F106, F108, F109, F111,
[ext-LP-record.md](ext-LP-record.md), the chord audit of [ext-D3b2-record.md](ext-D3b2-record.md) and DESIGN.md
12.2 "Chords". Session E3, 2026-10-15 (staged before the build slot, built 2026-10-15 22:24 UTC on).

Labels:

* **compiled**: the three language checks (`/std:c11`, `/std:c17` with `/W4 /WX`, the clang C99 parse).
* **headless**: unit tests (`test_present`, `test_pdos_cursor`, `test_pdos_profile`) on `build/gamedata`
  and the DOS copy `build/dosdata` (read).
* **Win32-headless**: `w32_test_host_win32` (a hidden host window; quiet mode: no dialog ever) and its child
  processes.
* **core listing**: facts read from the translated core and the w16 sources (read-only).

Scope:

* No DOS program was executed. Nothing was written to `C:\Projects\Civ1RE\dos`, `build/dosdata` or
  `C:\Projects\Civ1RE\original`. No UI was shown and civ64 was not launched (the brief's optional agent check
  was not done: the warning box and the menu have not been seen on screen; their texts, ids and order are
  tested through the Win32 API and accessors). No DOS byte is in the repository or a binary. No git command
  that writes was run. Asan was not built or run.
* Not edited: `core/`, `rt/`, `platform/w16/*`, `tests/headless/*`, the generated tables, `test.cmd`,
  `build.cmd` and every document other than this record (the rest is under "For the records").
* Worked in a stage (`build/ux1-stage`, the orchestrator's staging protocol) until the build slot: full copies
  of the modified files with each original's SHA-256 (`build/ux1-stage/BASE-SHA256.txt`), compile-checked on a
  private mirror (the tree with the stage over it, in the session's scratch directory: `cl` c11/c17 `/W4 /WX`
  in the default, Checked and CheckedNoObs configurations, clang-tidy's C99 parse) and the pointer-factor
  table computed there by a scratch program from `scale.c` before the goldens were written. At the slot
  thirteen files still had their base SHA-256; `present/arrive.c` and `present/input.h` had been changed by
  D4cF, so UX1's hunks (arrive.c: a header paragraph, `PI_VK_F4`, the chord block after Alt+Enter; input.h:
  `PI_CMD_CLOSE`) were applied again to the tree's copies, both LF as the tree's, no overlap with D4cF's
  changes (the first staged copies kept in `build/ux1-stage/old/`). Copied in 22:24:08 UTC after
  `build/docs-d4cf-done.txt` (22:22:53 UTC); the copies' hashes are `build/ux1-stage/COPIED-SHA256.txt`.

## Status

**Complete.** Both items are implemented and tested headless and Win32-headless; the three-step cycle after
the last source change is green (`build/ux1-status.txt` ends `ALL_GREEN`; "Results").

The user tested the build `build/user-builds/ux1/` on 2026-10-15 (`manual-checklist-ext.md`):

* UX1-2..UX1-6 passed: the close button, the Exit item, Alt+F4, no warning before the game, the warning in the
  game, and its colour modes.
* UX1-1, the pointer's size, failed: "the DOS torch pointer is too small and shall be on the size between the
  previous and the current one".

Unit UX1b corrects UX1-1. Its section is at the end of this record ("UX1b (the user's correction of UX1-1)").
Sections 1 and "Results" describe UX1 as it was built and are kept as they were.

## 1. The DOS pointer's size

### The rule

Before UX1 the DOS pointer (E's shape ICON 7, the torch; ICON 2, the GO arrow; `pdos_cursor`) was given to the
back end in logical pixels of the presented frame (1x on the N frame, 2x on the A frame) and the back end drew
it at the visible layout's cursor factors (5.7 "Cursor": the whole number nearest to the image's scale). The
320x200 frame's factor is about twice the 640x480 frame's at the same host size, so the torch was about twice
as large, relative to the window, as the Windows game cursor (and on the A frame the 2x image did the same).

UX1's rule (**choice**, the user's direction): **one DOS pointer pixel is drawn as a block of whole host
pixels of the Windows game cursor's pixel size at the same host size**, never filtered:

* `pdos_cursor` gives the shape's own pixels on both frames (one argb pixel per DOS pixel, hot spot
  `PDOS_POINTER_HOT_X/Y`, (0, 0)); the 2x of the A frame is gone.
* The back end makes a profile's own pointer at `present_pointer_factors(&kx, &ky)` (present.c), which is
  `present_pointer_factors_of(V, W)` (scale.c) for V, the visible frame's current layout, and W, the layout of
  the Windows frame at its current size (640x480, or the game screen of F105/F110) in the same client with the
  same policy, filter and aspect:

  * kx = clamp(1, 16, (2·W.sw + W.w) div (2·W.w)), the Windows game cursor's horizontal factor (the 5.7 rule,
    now `present_cursor_factors_of`, a half rounded up);
  * ky = clamp(1, 16, nearest(kyW · a)), with kyW = (2·W.sh + W.h) div (2·W.h) the Windows cursor's vertical
    factor and a = (V.sh · V.w) / (V.h · V.sw) the visible image's pixel aspect, computed as
    num = kyW · V.sh · V.w, den = V.h · V.sw, q = num div den, q + 1 when 2·(num − q·den) > den or, at an exact
    half, when q < kyW (a half goes toward kyW).

  a is exactly 1 for every frame except a 320x200 frame shown at 4:3 (1.17..1.25 there, the realised 6/5
  pair or fit's exact size), so on square pixels the pointer has exactly the Windows cursor's factors; at 4:3
  it is as tall as the frame's own pixels allow, ties keeping the Windows size.
* The hot spot is multiplied by the same factors (`pixel_cursor`, unchanged). The game's own cursor (the
  Windows profile, and the DOS profile's scroll cursors 136..143) keeps the visible layout's cursor factors.
* The factors are computed again whenever they can change: WM_SIZE (a resize, maximize, full screen, a DPI
  change through WM_DPICHANGED's rectangle), an option change (`hw_set_presentation`), a frame-size change
  (present.c 5a issues the cursor again: N ↔ A) and a profile switch. `hw_cursor_factors` reports the factors
  of the cursor shown. Mouse mapping is unchanged (it never depended on the pointer).

### The 7.1 host sizes

The pointer's factors kx x ky (test_present's hand-written goldens, `g_ptr_golden`), with the factors before
UX1 in brackets (the N frame: its own cursor factors; the A frame: twice the Windows cursor's, the 2x image):

| client | integer, 640x480 (A) | integer, 320x200 (N) | integer, 320x200 at 4:3 (N) | fit, 640x480 (A) | fit, 320x200 (N) | fit, 320x200 at 4:3 (N) |
|---|---|---|---|---|---|---|
| 640x480 | 1x1 (2x2) | 1x1 (2x2) | 1x1 (2x2) | 1x1 (2x2) | 1x1 (2x2) | 1x1 (2x2) |
| 800x600 | 1x1 (2x2) | 1x1 (2x2) | 1x1 (2x2) | 1x1 (2x2) | 1x1 (3x3) | 1x1 (3x3) |
| 1024x768 | 1x1 (2x2) | 1x1 (3x3) | 1x1 (3x3) | 2x2 (4x4) | 2x2 (3x3) | 2x2 (3x4) |
| 1280x720 | 1x1 (2x2) | 1x1 (3x3) | 1x1 (3x3) | 2x2 (4x4) | 2x2 (4x4) | 2x2 (3x4) |
| 1366x768 | 1x1 (2x2) | 1x1 (3x3) | 1x1 (3x3) | 2x2 (4x4) | 2x2 (4x4) | 2x2 (3x4) |
| 1920x1080 | 2x2 (4x4) | 2x2 (5x5) | 2x2 (4x5) | 2x2 (4x4) | 2x2 (5x5) | 2x2 (5x5) |
| 2560x1440 | 3x3 (6x6) | 3x3 (7x7) | 3x3 (6x7) | 3x3 (6x6) | 3x3 (7x7) | 3x4 (6x7) |
| 3840x2160 | 4x4 (8x8) | 4x4 (10x10) | 4x5 (8x10) | 5x5 (10x10) | 5x5 (11x11) | 5x6 (9x11) |

The filter (fit with nearest or sharp) does not change a layout's size, so fit-sharp has fit-nearest's
factors. civ64's defaults are integer, nearest and 4:3 (FIDELITY F99, X3), the third column. In integer
clients smaller than 1280x960 the Windows frame is at 1x, so the pointer is too, while the 320x200 frame is
at 2x or 3x: the pointer is then a third to a half of its old size relative to the DOS picture, as the
Windows cursor is relative to the Windows picture.

## 2. The host's exit: the close button, Alt+F4 and "Exit Sid Meier's Civilization 64bit"

### One path

* **The close button.** The class has no `CS_NOCLOSE` any more (F112 reversed for it) and the system menu has
  an enabled SC_CLOSE, which is what Windows enables the caption's close button by.
* **The system menu.** The standard Close item and the separator above it still leave their place (F112's
  removal, so there are not two items for one thing); SC_CLOSE comes back as the **last item, "&Exit Sid
  Meier's Civilization 64bit" with "Alt+F4" as its accelerator text** (`L"&Exit " HOST_CAPTIONW L"\tAlt+F4"`;
  no other item of the menu uses E as its access key), below About... and a separator, and is the menu's
  default item (bold), as the standard Close was. The About item (F108) is no longer last.

  Order at the end: ... Zoom in (double), Mouse wheel zooms the map, separator, About..., separator,
  Exit Sid Meier's Civilization 64bit Alt+F4.
* **Alt+F4** on the host window is a host chord of the arrival stage (`present/arrive.c`, PI_CMD_CLOSE),
  taken exactly as Alt+Enter (5.11, I7; DESIGN 5's Alt hold-back): only a press with the host's Alt (the
  WM_SYSKEYDOWN context bit) and without the repeat bit gives the command; the held-back Alt it serves and
  F4's press, repeats and release never reach the emulated queue, so the emulated key state stays as if
  nothing was pressed; an F4 already delivered down (F4 held, then Alt) makes no chord, so its release still
  reaches the game. The back end's `arrived` calls the exit path.
* **WM_CLOSE from elsewhere** (Task Manager's End task, a window message) takes the same path; before UX1 it
  became HOST_EV_QUIT, which host_sync.c posts as SC_CLOSE to the game's active window (F82).
* SC_CLOSE (the close button, the Exit item, a double click on the window icon), Alt+F4 and WM_CLOSE all call
  `exit_request`, which asks the pure `hw_exit_decide(state, request)` (host_win32.h):

| state \ request | SC_CLOSE | Alt+F4 | WM_CLOSE |
|---|---|---|---|
| HW_IN_SETUP (intro, title, Birth, setup screens) | exit now | exit now | exit now |
| HW_IN_GAME (from the game window's opening) | ask | ask | ask |
| HW_IN_HOST_BOX (one of the back end's modal boxes open) | ignore | ignore | ignore |

  An unknown state or request is ignored. HW_IN_HOST_BOX holds while the About box, the warning itself, a
  host message, the file choice, the overwrite question or "Locate DOS files..." is open (a nested count), so
  a WM_CLOSE from elsewhere never opens a second box over one of them (the close button and Alt+F4 cannot
  reach the disabled host window meanwhile).
* **Exit now** is `host_exit(0)`, the game's own end: F111's settings and placement written through the
  settings hook (`save_settings`: civ64.cfg with `window=` and `maximized=`), the debug log, the files closed,
  `ExitProcess(0)` from inside the window procedure, so no more game code runs; never a save.

### "In the actual game"

The state comes from the existing G hook (**choice**): w16 calls `host_game_screen` once per run, as
WdwMapOpen (1208:0AF1) creates the game's map window (the top-level CIV window; F105, and F110's following
starts at the same moment); the back end's `host_game_screen` sets the in-game flag, which lasts until civ64
exits (reset only when a host window is created or destroyed: a new run in the tests). It works the same in a
`CIV_OBSERVER 0` build (no observer query), and covers new, loaded, EARTH and customized games alike, since
WinMain opens the map window once after RunIntroAndTitleMenu for all of them.

### The warning

In the game a modal box over the host window (class W, like the About box: outside the virtual screen and the
observer; the game waits while it is open, as for the About box and the system menu):

* caption "Sid Meier's Civilization 64bit" (`HOST_CAPTIONW`, F106), the system's warning icon and the text
  "A game is in progress. If you exit now, any unsaved progress will be lost.";
* buttons "Exit Anyway" and "Cancel". Cancel has the focus at the start and is the default (Enter); Escape,
  the box's own close button and Alt+F4 on the box answer Cancel. The default follows the focus (BN_SETFOCUS
  of the owner-drawn buttons sets DM_SETDEFID), so Enter answers the button that has the focus, as with
  Windows' push buttons;
* the colour preference (F109) as the About box: title bar through `theme_window`, a dark background and
  text, and the About box's owner-drawn button face (`box_button`, the About box's `about_button` made common;
  in light mode the system's themed push button, PBS_DEFAULTED only on the default one); a change of the
  preference while it is open applies at once;
* Exit Anyway: exit now (above). Cancel: back to the game with nothing changed in the emulation or the core
  input. As with the About box, the host window loses the keyboard focus while the box is open, so the
  arrival stage's focus-loss rule (S2, F101) applies: a held-back key press is dropped and a key already
  delivered down is released; Alt+F4's own Alt and F4 are never delivered, so after Alt+F4 and Cancel nothing
  reaches the game.
* Quiet mode (the tests) never shows it: `hw_set_exit_answer` sets the answer (Cancel unless set) and
  `hw_exit_asks` counts the questions.

### What Alt+F4 and the close commands did in the game before (the chord audit, updated)

Before UX1, Alt+F4 in the host window reached the game as keys (WM_SYSKEYDOWN VK_MENU, WM_SYSKEYDOWN VK_F4
with the context bit): the emulated DefWindowProc (`platform/w16/user_syscmd.c`, P4-5, FIDELITY F78) posted
WM_SYSCOMMAND SC_CLOSE to the window with the focus, whose default sends WM_CLOSE: on the map window that
reaches the game's Quit command (1208:05E1, F82), and in the game's own message boxes and dialogs WM_CLOSE ends
them (DESIGN 5 "Message boxes"). The host window's close request (only WM_CLOSE from elsewhere while F112 held)
posted the same SC_CLOSE (F82). The translated core handles no WM_SYSKEYDOWN of its own and ACCELERATOR 128 has
no Alt entry and no F4 (DESIGN 12.2 "Chords"). So the game loses exactly the Windows behaviour the host now
takes over: Alt+F4 as "close the active window", which on the map window was Quit with the game's own question
and in a game message box was its Close; the boxes keep their buttons and Escape, the game keeps File > Quit.
F4 without Alt still reaches the game.

## Files changed

| file | change |
|---|---|
| `present/scale.h`, `present/scale.c` | `present_cursor_factors_of` (the 5.7 rule moved from host_win32.c, unchanged) and `present_pointer_factors_of` (UX1's rule); header comment |
| `present/present.h`, `present/present.c` | `present_pointer_factors` (one new function after `present_view_layout`, nothing else changed in present.c); present.h: its declaration and the cursor route's comment |
| `present/profile.h` | comment only: `PresentCursor`'s pixels are the pointer's own, drawn at `present_pointer_factors` |
| `present/dos/pdos_cursor.h`, `pdos_cursor.c` | the image is the shape's own pixels on the N and the A frame (the 2x and the hot spot's x2 removed); comments |
| `present/arrive.c`, `present/input.h` | the Alt+F4 chord, `PI_VK_F4`, `PI_CMD_CLOSE` (after `PI_CMD_ZOOM_RESET`); header paragraph |
| `platform/win32/host_win32.h` | `hw_cursor_factors`'s comment; the exit API: `HW_QUIT_*`, `HW_IN_*`, `HW_EXIT_*`, `hw_exit_decide`, `hw_exit_state`, `hw_set_exit_answer`, `hw_exit_asks`, `hw_exit_text` |
| `platform/win32/host_win32.c` | below |
| `tests/test_present.c` | `pointer_factors()` (goldens and properties, the moved cursor rule) and six facade checks in `profiles_layout` |
| `tests/test_pdos_cursor.c`, `tests/test_pdos_profile.c` | the A frame's pointer at the shape's own size (were 2x) |
| `tests/win32/test_host_win32.c` | the menu and class checks, `test_ux1_pointer`, `test_exit` and its children `--close-setup/-game/-cancel`; the test profile's pointer on demand |

`platform/win32/host_win32.c` in detail (for the unit that lands on top of it, BS12+BS34):

1. File header: a UX1 paragraph.
2. New statics after `g_tick_hz`: `g_in_game`, `g_host_box`, `g_exit_answer`, `g_exit_asks`, and the forward
   declaration `static void exit_request(int request);`.
3. `host_message`: `g_host_box++` / `--` around its MessageBoxW.
4. `arrived`: a new branch `PI_CMD_CLOSE` → `exit_request(HW_QUIT_ALT_F4)`.
5. `host_game_screen`: sets `g_in_game = 1` before its `return present_game_screen(...)`.
6. `cursor_factors`: rewritten: with `g_cpix` (a profile's pointer) `present_pointer_factors`, else
   `present_cursor_factors_of(present_view_layout())` (the old inline arithmetic, moved to scale.c). Its
   callers `make_cursor` and `refresh_cursor` are unchanged.
7. `host_choose_file`, `host_confirm_overwrite`: `g_host_box` around their dialog and message box.
8. `g_exit_item` (new, before `add_menu`); `add_menu`: the comment, and after About... a separator, the
   SC_CLOSE item and `SetMenuDefaultItem(m, SC_CLOSE, FALSE)`.
9. `about_button` became `box_button(di, dark, bg, defaulted)` (text buffer 32, PBS_NORMAL when not the
   default) with a two-line `about_button` calling it with the About box's state; About's drawing is unchanged.
10. `hw_about`: `g_host_box` around its DialogBoxIndirectParamW.
11. New section after `hw_about`: `IDC_EXIT_ICON/TEXT/ANYWAY` (211..213), the texts, `g_warn_dark`,
    `g_warn_bg`, `hw_exit_decide`, `hw_exit_state`, `hw_set_exit_answer`, `hw_exit_asks`, `hw_exit_text`,
    `warn_buttons`, `warn_proc`, `exit_warning`, `exit_request`.
12. `civ_command`: the Locate hook call between `g_host_box++` / `--`; a new `case SC_CLOSE` →
    `exit_request(HW_QUIT_SYSCOMMAND)`.
13. `wndproc` WM_CLOSE: `exit_request(HW_QUIT_WM_CLOSE)` instead of `pi_arrive_quit` / `arrived`.
14. `hw_create_window_ex`: `wc.style = 0u` (was `CS_NOCLOSE`), `g_in_game = 0` after `g_full = 0`.
15. `hw_destroy_window`: `g_in_game = 0` after `g_full = 0`.

## Tests

* `test_present` (521 → 997 checks): `pointer_factors()`: for the three combos (integer, fit-nearest,
  fit-sharp) x three frame kinds (640x480, 320x200, 320x200 at 4:3) x the 12 client sizes of 7.1 and the odd
  ones, the factors equal the hand-written goldens at the eight 7.1 sizes (the table above), and at every size
  kx is the Windows cursor's, ky lies within a half of kyW x the pixel aspect, equals kyW on square pixels, the
  640x480 frame has exactly the Windows cursor's factors, a 320x200 frame's pointer is never above the frame's
  own factors, and no pointer is larger than before UX1; the moved cursor rule (1.5 to 2, 2.497 to 2, the clamp
  to 1..16, no layout 1x1). Through the facade (`profiles_layout`): 2x2 where a 320x200 frame is at 4x in
  1280x960, 2x2 on a 640x480 frame, 3x3 under 4:3 in 1920x1440 (6x7 frame, 3 x 7/6 = 3.5 to 3), 3x3 square, 3x3
  for a 640x480 frame under 4:3.
* `test_pdos_cursor` (62 checks, as before): the A frame's image is the shape at 1x through the play palette,
  the hot spot unscaled, the shape's own size; the A frame changes `gen` (another frame kind).
* `test_pdos_profile` (38, as before): the A frame's pointer has the torch's own size.
* `w32_test_host_win32` (262 → 279 checks):
  * the system menu: one enabled SC_CLOSE, the last item, text "&Exit Sid Meier's Civilization 64bit\tAlt+F4"
    (`GetMenuStringW`, equal to `hw_exit_text(4)`), the default item; no doubled separator; the class without
    CS_NOCLOSE; the positional order check of F108 moved by the two new items;
  * `test_ux1_pointer`: the test profile's 3x3 pointer (hot spot (1, 2)) over its 320x200 frame at 4x in a
    1280x960 client is made at 2x2 (6x6, hot spot (2, 4)); at 700x500 again at 1x1 (3x3, (1, 2)); with a
    640x480 frame, re-laid out at the tick, 2x2;
  * `test_exit`: the decision table (9 cells and unknown states and requests); the texts; HW_IN_SETUP before
    and HW_IN_GAME after `host_game_screen`; in the game with the answer Cancel, SC_CLOSE, WM_CLOSE and Alt+F4
    (with a repeat and both releases) each ask once, the window stays and no event reaches the ring; F4 alone
    reaches the game; Alt with an F4 already down makes no chord and the keys and releases reach the game;
  * three child processes (`child_close`, a hidden window, the settings hook writing `[settings]` to the
    child's stderr file): `--close-setup` (SC_CLOSE before the game) exits with code 0 having written the
    settings and not gone on; `--close-game` (Alt+F4 in the game, Exit Anyway) the same; `--close-cancel`
    (Alt+F4, Cancel) goes on (`[went on]`) and ends through its own `host_exit(5)`.
  * The test at the start of `test_window` that sent WM_CLOSE and expected HOST_EV_QUIT is replaced: before
    the game a WM_CLOSE now ends the process, so only the decision is checked there and the exits run in the
    children.

## Results

The three-step cycle after the last source change ran detached through `build/ux1-stage/ux1-cycle.ps1`, on
2026-10-15 UTC. Its record is `build/ux1-status.txt`, which ends `ALL_GREEN`:

| step | exit | seconds | UTC | log | last line |
|---|---|---|---|---|---|
| 1 `build.cmd checked` | 0 | 212 | 22:30:27..22:33:59 | `build/ux1-1-build-checked.log` | `BUILD_OK variant=Checked` (portable sources checked: 276, c11, c17, c99 parse) |
| 2 `test.cmd checked` | 0 | 1062 | 22:33:59..22:51:41 | `build/ux1-2-test-checked.log` | `TESTS_OK variant=Checked` (`TEST_SECTIONS 21 parallel, budget 20, wall 1059.6 s, failed 0`; TRACE_OK) |
| 3 `ext_g1.py check` | 0 | 1 | 22:51:41..22:51:42 | `build/ux1-3-g1-checked.log` | `EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)` |

UX1 left the G-1 baseline as it was. The one amendment that step 3 reports was already in the baseline.

The unit tests this unit touched, from step 2:

* `test_present`: PASS, 997 checks (521 before UX1).
* `w32_test_host_win32`: PASS, 279 checks (262 before UX1).
* `test_pdos_cursor`: PASS, 62 checks.
* `test_pdos_profile`: PASS, 38 checks.
* `test_input`: PASS, 234 checks (unchanged).

Every other section passed as well. UX1 changed no other test.

## Deviations

1. **Files outside the brief's list.** `present/scale.c/.h` (the pure rule lives with the layout arithmetic it
   reads), `present/arrive.c` and `present/input.h` (Alt+F4 as an arrival-stage chord, as I7 asks; small
   hunks, merged onto D4cF's copies), `present/profile.h` (a comment) and `tests/test_pdos_profile.c` (two
   checks that pinned the old 2x pointer). `tests/test_input.c` (D4c's) has no Alt+F4 case; the chord is
   tested through the window procedure in `test_host_win32`, like S2's chords.
2. **The vertical factor follows a 4:3 frame's pixel aspect** (choice beyond the brief's single factor): on
   every square-pixel frame the pointer has exactly the Windows cursor's factors; on a 320x200 frame at 4:3
   (civ64's default aspect) the DOS pixels are 1.17..1.25 times taller than wide and the old pointer followed
   that (for example 4x5), so ky is the nearest whole number to kyW x the aspect, a half toward kyW (2x2 at
   1920x1080, 3x3 at 2560x1440, 4x5 at 3840x2160).
3. **Not changed although now inexact** (not this unit's files): `platform/w16/host.h`'s comment of
   `host_set_cursor_pixels` still says "in logical pixels of the presented frame ... scales it as it scales
   the game's cursor"; `tests/headless/harness.c`'s host log names the command by a range ending at
   `PI_CMD_ZOOM_RESET`, so a scripted Alt+F4 in host form would log `cmd` as entry 0 (no harness script sends
   F4; the harness has no host window and takes no exit). HOST_EV_QUIT and `pi_arrive_quit` remain for
   WM_QUIT in the pump; the host window no longer produces them.
4. **No agent UI check** (allowed, not required): the warning box, the bold Exit item and the close button
   have been checked through the Win32 API only; their look is the user's check.

## For the records

* **DESIGN.md**
  * 5 "Win32 back end", Input: "Alt+F4 reaches the game as keys (the emulated window manager closes, F78).
    Closing the host window ... posts WM_SYSCOMMAND SC_CLOSE to the game's active window" → since UX1 Alt+F4,
    the close button, the system menu's Exit item and WM_CLOSE are the host's exit (`hw_exit_decide`: at once
    before the game window, the warning in the game); the "Close" bullet of 6 (host_sync: "the host window's
    close request posts WM_SYSCOMMAND SC_CLOSE") is kept for WM_QUIT only.
  * 5 "Cursor" and 12.2 "Window, full screen, cursor, chords and settings": a profile's own pointer is made at
    `present_pointer_factors` (the rule and formula above), the game's cursor at the visible layout's cursor
    factors (`present_cursor_factors_of`); the system menu's new last item and the default item; the
    "Chords" audit: Alt+F4 is a host chord (PI_CMD_CLOSE), with the audit paragraph above (what the game loses).
  * 12.7 (line 2694, "with the torch pointer at frame scale 2") → the pointer at its own pixels on both frames,
    drawn by the back end at the Windows game cursor's factors (UX1; draft B 6.7).
* **FIDELITY.md**
  * F112: reversed for the close button and the Close command (UX1): the class has no CS_NOCLOSE; SC_CLOSE is
    the last system-menu item "Exit Sid Meier's Civilization 64bit" with Alt+F4; Alt+F4 is the host's; the
    old Close item's place and separator stay removed.
  * F82 and F78 (the Alt+F4 part): superseded by UX1 for the host window: neither the host's close nor Alt+F4
    posts SC_CLOSE to the game any more; WM_QUIT still becomes HOST_EV_QUIT.
  * F108: About... is no longer the last item (the Exit item is, below a separator).
  * New entry (choice, the user's direction 2026-10-15): the DOS pointer's displayed size, rule, formula and
    the 7.1 table; the DOS program's pointer relative to its 320x200 screen is larger (one DOS pixel per screen
    pixel); P0 unaffected (presentation and host cursor only).
  * New entry (choice, the user's direction 2026-10-15): the host's exit and its in-game warning (states,
    requests, the G hook as the game's start, the box, Cancel the default, quiet mode, `host_exit(0)` with
    F111's settings, never a save); class W; P0: nothing reaches the emulation before the exit.
* **RUNNING.md**: line 347 ("the DOS torch pointer at twice the size") → at about the Windows cursor's size;
  the chords (Alt+F4 now the host's), the system menu's last item, the close button, the warning box and when it
  appears; RUNNING line 429 ("Alt+F4 and the host window's close box both ask the game to close its active
  window") → they end civ64, with the warning in the game.
* **FEATURES.md**: host rows: the close button, Alt+F4 and the Exit item (with the in-game warning); the DOS
  pointer's size.
* **DOS-PROFILE.md** 2.5 (row C2 and the pointer paragraph): the displayed size of the DOS pointer is the
  Windows cursor's pixel size (UX1).
* **STATUS.md**: UX1 complete (both items), the cycle green.
* **manual-checklist-ext.md** (pending user checks): (1) in the DOS profile the torch on the title and setup
  screens (N frames) and in the game (A frames) is about the Windows cursor's size and blocky (no blur), at a
  few window sizes and in full screen; (2) the caption's close button is enabled; (3) the system menu ends with
  "Exit Sid Meier's Civilization 64bit  Alt+F4"; (4) before the game (intro, title, Birth, setup) the close
  button, Alt+F4 and the Exit item end civ64 at once and the next start keeps the window placement; (5) in the
  game each of them shows the warning with "Exit Anyway" and "Cancel"; Cancel (and Escape) returns to the game
  unchanged, Exit Anyway ends civ64 without saving; (6) the warning follows dark and light mode.
* **platform/w16/host.h** (owner of platform/w16): `host_set_cursor_pixels`' comment (deviation 3).
* **tests/headless/harness.c** (owner of the harness): `PI_CMD_CLOSE` in the host log's command names
  (deviation 3).

## UX1b (the user's correction of UX1-1)

The user tested the build `build/user-builds/ux1/` on 2026-10-15 (`manual-checklist-ext.md` UX1-1):

> UX1 All passed except UX1-1 for UX1-1 the DOS torch pointer is too small and shall be on the size between the
> previous and the current one.

Unit UX1b carries out that direction for the DOS pointer only. The rest of UX1 is unchanged.

UX1b was staged in `build/ux1b-stage` while the BS landing held the build slot:

* The stage holds full copies of the changed files, with each original's SHA-256 in `BASE-SHA256.txt` (taken
  2026-10-15 23:09:59 UTC).
* It was checked privately under `build/ux1b-stage/obj` (see "Results (UX1b)").
* It lands after the BS gate.

### The rule

The rule is the user's direction, with the orchestrator's reading of "between":

> per axis, k = clamp(1, 16, ceil((k_before + k_UX1) / 2))

That is the arithmetic mean of two factors, with a half rounded up. Rounding up goes toward the larger factor,
because the user found UX1's pointer too small. In integers, k = clamp(1, 16, (k_before + k_UX1 + 1) div 2).

The two factors are:

* **k_UX1**, UX1's factors (section 1):
  * kx = the Windows game cursor's horizontal factor, `present_cursor_factors_of(W)`;
  * ky = nearest(kyW · a), with a = (V.sh · V.w) / (V.h · V.sw) and a half going toward kyW.
* **k_before**, the factor the pointer had before UX1:
  * On a 320x200 frame (the N frame: the DOS title box, the intro, Birth), it is that frame's own cursor factors,
    `present_cursor_factors_of(V)`. That is the old 1x image drawn at the visible layout's factors. At 4:3 its
    ky includes the frame's taller pixels, so the old ky and UX1's aspect-corrected ky are averaged alike.
  * On any other frame (the A frame: the Windows layout, 640x480 or the game screen of F105/F110), it is twice
    the Windows cursor's factors, 2 · `present_cursor_factors_of(W)`. That is the old 2x image at the A frame's
    factors, which are the Windows cursor's, because the A frame is the Windows layout.

As in UX1:

* Each DOS pointer pixel is a block of whole host pixels, never filtered.
* The hot spot is multiplied by the same factors (`pixel_cursor`, unchanged).
* The game's own cursor keeps the visible layout's cursor factors.
* The factors are computed again at the same moments: a resize, an option change, a frame-size change and a
  profile switch.

UX1's factor is never above the factor before UX1, at any size. So the pointer now always lies between the two:
never smaller than UX1's and never larger than before UX1.

**No new inputs** (choice). `present_pointer_factors_of(V, W)` already has both layouts. The frame kind is V's
size: exactly 320x200 is the N frame. scale.c already treats exactly 320x200 frames specially for the 4:3
aspect. So the whole change is inside `present_pointer_factors_of`, and `present/present.c` and
`platform/win32/host_win32.c` are unchanged.

**Small windows.** Two whole factors that differ by 1 have no whole number between them. The mean rounded up
then gives the factor before UX1. For example, before UX1 2 and UX1 1 give 2:

* at 640x480 this happens in every column;
* on the A frames under integer it happens up to 1366x768.

There the pointer has its size from before UX1. A size strictly between appears where the two factors differ by
2 or more.

### The 7.1 host sizes: before UX1 / UX1 / UX1b

Each cell gives kx x ky before UX1, then UX1's, then UX1b's.

The values were computed by the scratch program `build/ux1b-stage/obj/table.c` from the staged `scale.c`, and
checked against an independent recomputation of the formula (0 mismatches). They equal test_present's
hand-written goldens, `g_ptr_golden`. The filter does not change a layout's size, so fit with the sharp filter
has the same factors as fit with the nearest filter.

| client | integer, 640x480 (A) | integer, 320x200 (N) | integer, 320x200 at 4:3 (N) |
|---|---|---|---|
| 640x480 | 2x2 / 1x1 / **2x2** | 2x2 / 1x1 / **2x2** | 2x2 / 1x1 / **2x2** |
| 800x600 | 2x2 / 1x1 / **2x2** | 2x2 / 1x1 / **2x2** | 2x2 / 1x1 / **2x2** |
| 1024x768 | 2x2 / 1x1 / **2x2** | 3x3 / 1x1 / **2x2** | 3x3 / 1x1 / **2x2** |
| 1280x720 | 2x2 / 1x1 / **2x2** | 3x3 / 1x1 / **2x2** | 3x3 / 1x1 / **2x2** |
| 1366x768 | 2x2 / 1x1 / **2x2** | 3x3 / 1x1 / **2x2** | 3x3 / 1x1 / **2x2** |
| 1920x1080 | 4x4 / 2x2 / **3x3** | 5x5 / 2x2 / **4x4** | 4x5 / 2x2 / **3x4** |
| 2560x1440 | 6x6 / 3x3 / **5x5** | 7x7 / 3x3 / **5x5** | 6x7 / 3x3 / **5x5** |
| 3840x2160 | 8x8 / 4x4 / **6x6** | 10x10 / 4x4 / **7x7** | 8x10 / 4x5 / **6x8** |

| client | fit, 640x480 (A) | fit, 320x200 (N) | fit, 320x200 at 4:3 (N) |
|---|---|---|---|
| 640x480 | 2x2 / 1x1 / **2x2** | 2x2 / 1x1 / **2x2** | 2x2 / 1x1 / **2x2** |
| 800x600 | 2x2 / 1x1 / **2x2** | 3x3 / 1x1 / **2x2** | 3x3 / 1x1 / **2x2** |
| 1024x768 | 4x4 / 2x2 / **3x3** | 3x3 / 2x2 / **3x3** | 3x4 / 2x2 / **3x3** |
| 1280x720 | 4x4 / 2x2 / **3x3** | 4x4 / 2x2 / **3x3** | 3x4 / 2x2 / **3x3** |
| 1366x768 | 4x4 / 2x2 / **3x3** | 4x4 / 2x2 / **3x3** | 3x4 / 2x2 / **3x3** |
| 1920x1080 | 4x4 / 2x2 / **3x3** | 5x5 / 2x2 / **4x4** | 5x5 / 2x2 / **4x4** |
| 2560x1440 | 6x6 / 3x3 / **5x5** | 7x7 / 3x3 / **5x5** | 6x7 / 3x4 / **5x6** |
| 3840x2160 | 10x10 / 5x5 / **8x8** | 11x11 / 5x5 / **8x8** | 9x11 / 5x6 / **7x9** |

civ64's defaults are integer, nearest and 4:3 (FIDELITY F99, X3). At the defaults the pointer is:

* on the 320x200 frames (the DOS title box, the intro, Birth): 2x2 up to 1366x768, 3x4 at 1920x1080, 5x5 at
  2560x1440 and 6x8 at 3840x2160;
* on the A frames (the setup screens and the game): 2x2 up to 1366x768, 3x3 at 1920x1080, 5x5 at 2560x1440
  and 6x6 at 3840x2160.

In the game the A frame is the game screen (F105, F110), which is also the Windows frame W. The same A rule
applies there: the mean of twice the Windows cursor's factors at that screen and the Windows cursor's factors.

### Files changed (UX1b)

| file | change |
|---|---|
| `present/scale.c` | `present_pointer_factors_of`: UX1's factors, the factors before UX1, and their mean with a half up; comments |
| `present/scale.h` | the declaration's comment: the UX1 and UX1b rule |
| `present/profile.h`, `present/dos/pdos_cursor.h` | comments only: the pointer's displayed size is `present_pointer_factors`' (they said "the Windows game cursor's pixel size") |
| `tests/test_present.c` | `g_ptr_golden` (UX1b's factors), the properties, the five facade expectations, the header comment |
| `tests/win32/test_host_win32.c` | `test_ux1_pointer`'s three expectations and its comment; `test_window`'s pixel-cursor check (8.5), see below |

`test_window`'s pixel-cursor check draws its 3x3 test pointer over the 640x480 frame at the pointer factors. Its
expected sizes change from 2x2 to 3x3 at 1280x960, and from 1x1 to 2x2 at 700x500.

Not changed: `present/present.c` and `platform/win32/host_win32.c` (the BS landing), `present/present.h`,
`present/dos/pdos_cursor.c` and `tests/test_pdos_*.c`. The image is still the shape's own pixels.

### Tests (UX1b)

**`test_present`** (997 → 925 checks).

The goldens are UX1b's factors at the eight 7.1 sizes, for the three combos and the three frame kinds (the
tables above).

The properties are checked at all 12 sizes:

* On a 640x480 frame, the frame's factors are the Windows cursor's (the A frame is the Windows layout).
* kx = (k_before + the Windows cursor's + 1) div 2.
* 2·ky − by is UX1's vertical factor or one more, and that factor lies within a half of kyW times the pixel
  aspect.
* On square pixels, ky = (by + kyW + 1) div 2, and the pointer is never below UX1's.
* The pointer is never larger than before UX1.

Why there are 72 fewer checks: UX1 had, for each 320x200 kind, an "at most the frame's own factors" check. For a
320x200 frame those factors are exactly the bound of "never larger than before UX1", so that check is gone. It
was one check per combo, size and 320x200 kind: 3 x 12 x 2 = 72.

The facade checks:

| layout | pointer | mean of |
|---|---|---|
| 320x200 at 4x in 1280x960 | 3x3 | 4 and 2 |
| 640x480 at 2x | 3x3 | 2 · 2 and 2 |
| 4:3 in 1920x1440 (the frame at 6 x 7) | 5x5 | 6 and 3; 7 and UX1's 3 |
| square in 1920x1440 (the frame at 6x6) | 5x5 | 6 and 3 |
| 640x480 under 4:3 (at 3x) | 5x5 | 2 · 3 and 3 |

**`w32_test_host_win32`** (279 checks, the same count).

* `test_ux1_pointer`:
  * over the 320x200 frame at 4x in 1280x960: 3x3, hot spot (3, 6), 9x9;
  * at 700x500: 2x2, (2, 4), 6x6;
  * over the 640x480 frame at 2x: 3x3, (3, 6), 9x9.
* `test_window`'s pixel cursor: 3x3, then 2x2, then 3x3.

**`test_pdos_cursor`** (62) and **`test_pdos_profile`** (38) are unchanged.

### Results (UX1b)

**Private check**, under `build/ux1b-stage/obj`, 2026-10-15 23:15..23:18 UTC. The script `obj/private.cmd`
makes a mirror of the tree's sources with the stage copied over it, using the Checked definitions. It wrote
nothing in the tree or in shared outputs.

* All 276 portable sources compiled with `/std:c17 /W4 /WX`.
* `scale.c`, `pdos_cursor.c` and `present.c` also compiled with `/std:c11` and passed the clang C99 parse.
  Through them the three changed headers were checked as well.
* The tests ran with `build/gamedata` (read only) and their output in `obj/out`:

| test | result |
|---|---|
| `test_present` | PASS, 925 checks |
| `test_pdos_cursor` | PASS, 62 |
| `test_pdos_profile` | PASS, 38 |
| `w32_test_host_win32` | PASS, 279 |

For its version check, `w32_test_host_win32` needs civ64.exe beside it. The script put a read-only copy of the
tree's Checked civ64.exe there. A first run without that copy failed only that check.

**Landing** (the D5 build slot, 2026-10-16; `ext-D5a-record.md`, "Landing"). UX1b landed first, at 00:24:40
UTC: `scale.c`, `scale.h`, `pdos_cursor.h`, `test_present.c` and `test_host_win32.c` as staged; `profile.h` as
a clean three-way merge of this stage's comment with BS's landed file (base: the tree's file before BS,
c90f9cea...). The three-step cycle, shared with D5a, D5b and D5c (`build/d5l-status.txt`):

* `build.cmd checked`: BUILD_OK, 283 portable sources.
* `test.cmd checked`: TESTS_OK (after one D5c-side fix of ext_continue's expectation, unrelated to UX1b; the
  rerun's 24 sections all pass). `test_present` PASS 925 checks, `test_pdos_cursor` 62, `test_pdos_profile` 40
  (D5c's copy, which adds two checks), `w32_test_host_win32` 279.
* `ext_g1.py check`: EXT_G1_OK runs 77.

The user's check of UX1-1 (the pointer's size) remains pending (`manual-checklist-ext.md`).

### Deviations (UX1b)

1. **Files beyond `scale.c` and the goldens:**
   * `scale.h`, the declaration's contract;
   * `profile.h` and `pdos_cursor.h`, comments only, because they named the Windows cursor's size as the
     pointer's;
   * `test_window`'s 8.5 pixel-cursor check in `test_host_win32.c`, because it asserts the sizes of a
     profile's pointer over the 640x480 frame, which UX1b changes.
2. **The frame kind is read from V's size** (choice). Exactly 320x200 is the N frame. Every other frame takes
   the A frame's factor before UX1, twice the Windows cursor's. A profile's pointer over a frame that is not
   the DOS profile's follows the A rule, but only the tests make one.
3. **In small windows the size is the one from before UX1** (2x2: at 640x480 everywhere; on the A frames under
   integer up to 1366x768), because no whole factor lies between 2 and 1. The user's check should know this.
4. **Comments now inexact in files UX1b does not change** (the BS landing's files):
   * `present/present.h`, the comment of `present_pointer_factors`: "so the DOS pointer has the Windows game
     cursor's pixel size";
   * `platform/win32/host_win32.c`, the comment of `cursor_factors`: "the Windows game cursor's pixel size, not
     the 320x200 frame's about twice larger factor".

### For the records (UX1b)

* **FIDELITY.md F159** (updated by UX1b; the user's correction of 2026-10-15, UX1-1):
  * The rule becomes the mean, with a half up, of the factor before UX1 and UX1's, per axis, with the
    definitions above. It is still a block of whole host pixels, with the hot spot alike.
  * Quote the user's correction.
  * The defaults: on 320x200 frames 2x2 up to 1366x768, 3x4 at 1920x1080, 5x5 at 2560x1440, 6x8 at 3840x2160;
    on A frames 2x2, 3x3, 5x5, 6x6.
  * In small windows the size from before UX1.
  * The table is this record's UX1b section.
  * UX1's rule stays as the history.
* **DESIGN.md**:
  * 12.2 "A profile's own pointer" (about lines 1921..1931): the pointer is at `present_pointer_factors`,
    UX1b's mean; on square pixels it is no longer exactly the Windows cursor's factors.
  * Line 993 ("drawn at the Windows game cursor's factors") and line 2364.
  * 12.7, line 2825 ("drawn by the back end at the Windows game cursor's factors"): it becomes "between its
    size before UX1 and the Windows game cursor's (UX1b)".
* **RUNNING.md**:
  * Line 95: `test_present` has 925 checks in Checked (997 after UX1, 521 before).
  * Line 97: 279 checks, unchanged.
  * Lines 423..424 ("at about the Windows game cursor's size"): "between its size before UX1 and the Windows
    game cursor's (UX1b), the sizes before UX1 in small windows".
* **FEATURES.md**, line 184: the DOS pointer's size row, with UX1b's rule and the new cycle's result.
* **DOS-PROFILE.md** 2.5, row C2 ("displayed at the Windows cursor's pixel size (UX1, F159)"): "displayed
  between its size before UX1 and the Windows cursor's pixel size (UX1, UX1b, F159)".
* **manual-checklist-ext.md**:
  * UX1-1: back to pending for the UX1b user build, reworded as follows.

    > With the DOS graphics, the torch pointer on the DOS title box (a 320x200 N frame) and on the later
    > screens, where the DOS profile shows the Windows picture (640x480 A frames: the setup screens and the
    > game), is between its size before UX1 and its size in the build ux1. In small windows, where no whole
    > size lies between the two, it has its size from before UX1. It is blocky: each pixel of the DOS pointer
    > is a block of whole screen pixels, with no blur. Try a few window sizes and full screen. At the defaults
    > (integer, nearest, 4:3) the blocks are:
    >
    > * on the title box: 2x2 up to 1366x768, 3x4 at 1920x1080, 5x5 at 2560x1440 and 6x8 at 3840x2160;
    > * on the A frames: 2x2 up to 1366x768, 3x3 at 1920x1080, 5x5 at 2560x1440 and 6x6 at 3840x2160.
    >
    > The build ux1 had 1x1 up to 1366x768, then 2x2, 3x3 and 4x5 (4x4 on A frames).

    Its source column: "the user's direction 2026-10-15, item 1, and the user's correction 2026-10-15 (F159,
    UX1b)".
  * D4a-1's parenthesis ("since UX1 at about the Windows cursor's size instead, UX1-1"): "since UX1b between
    its size before UX1 and the Windows cursor's, UX1-1".
* **STATUS.md**: UX1b (UX1-1's correction) is implemented, with its cycle and the user's check pending until
  the landing and the user build.
* **present/present.h** and **platform/win32/host_win32.c**, for their owners after the BS landing: the two
  comments of deviation 4.

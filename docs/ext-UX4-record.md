# Extension unit UX4 (the keypad's Ctrl+Shift+0, the window placement Windows actually gives, message boxes in dark mode) - record

Unit UX4 of the "civ64" extension reworks three of the user's results of 2026-10-16 (STATUS.md "User directions",
row "2026-10-16 about 12:55"; `manual-checklist-ext.md` items M-3, LP-8 and LP-5's remark). Session E3,
2026-10-16. Host only. Staged in `build/ux4-stage/` (the orchestrator's staging protocol); bases taken 13:29 UTC
from the tree after SL's copy-in, re-verified unchanged after SL's ALL_GREEN (`build/sl-status.txt`), after D6d's
ALL_GREEN (`build/d6d-status.txt`, 14:34 UTC) and at the end, 14:53 UTC; the final private builds and tests ran on
the tree after D6d's landing (Results).

Labels:

* **compiled**: `build.cmd checked`, `build.cmd checked noobs` and `build.cmd` (Release) of a private overlay
  (`build/ux4-stage/obj/src`: the tree's source folders with the stage over them, `obj/mkoverlay.py`), run with
  `--nogen` by `obj/b.cmd` / `obj/ball.cmd`: strict C17/x64 (`/W4 /WX /permissive- /fp:precise`), `/std:c11` and
  `/std:c17` and the clang-tidy C99 parse of every portable source, the test programs, the harness, civ64.exe and
  the Win32-headless tests; every output under the overlay's own `build/`.
* **headless**: the overlay's `test_*.exe` (test.cmd's `unit` loop, `obj/ut.cmd`), argv[1] `build/gamedata`
  (read), argv[2] under the stage.
* **Win32-headless**: the overlay's `w32_test_*.exe` (hidden windows, quiet mode except the hidden modeless test
  boxes, which are never shown), the same arguments.
* **probe**: `obj/probe/lp8_probe.c`, a console program linked with the base's or the overlay's Checked objects,
  that creates the host window **hidden** with the user's LP-8 value and prints what Windows gave.

Scope: no DOS program was executed; nothing was written to `C:\Projects\Civ1RE\dos`, `C:\Projects\Civ1RE\original`,
`build/dosdata`, `build/gamedata`, `build/x64`, `build/harness` or any other shared output; build.cmd and test.cmd
of the tree were not run; civ64 was not launched and no window or box was shown (hidden test windows and hidden
modeless test boxes only); no git command that writes was run; no global or low-level hook was installed. Read
outside `claude/`: only the system state that M-3 needs (the registry keys of Windows' input-language hot keys,
`tasklist`), and the MSVC environment set up by `scripts\Setup-Msvc.cmd` as build.cmd does. Not edited: `core/`,
`rt/`, `res/`, `platform/w16/`, `build.cmd`, `test.cmd`, the generated tables, `tests/test_map.c` (D6d stages it)
and every document other than this record ("For the records").

## Status

**LANDED 2026-10-16** (copy-in 14:58:30 UTC, ALL_GREEN 15:27:18 UTC, RELEASE_OK 15:32:03 UTC; user build
`build/user-builds/ux4/`; section "Landing"). M-3's main-row question is answered: the user chose
**Ctrl+Shift+Home** as an extra reset chord (STATUS.md "User directions", about 15:05 UTC), the follow-up unit UX4b
(`docs/ext-UX4b-record.md`); this build does not have it.

At staging: **QUESTION for M-3's main row; the rest READY_TO_BUILD.** Staged and tested privately (compiled,
headless, Win32-headless; Checked, CheckedNoObs, Release):

* M-3 (a) the keypad: **fixed** (the reset chord with Num Lock off and on).
* M-3 (b) the main row: **not reproducible by civ64 and not fixable without a global hook**; civ64 handles the main
  row's Ctrl+Shift+0 whenever its key messages arrive (tested), so something on the user's machine takes the key
  before civ64's window sees it. Per the brief no chord was invented: the user is asked (Decision 3, three
  alternatives checked free). "Normal map zoom" in the window menu stays the way that works.
* LP-8: **fixed** (the remembered rectangle is checked as Windows gives it; the user's value now opens at the
  primary work area's top-left with the default size, and that rectangle is written back).
* LP-5's remark: **implemented** (civ64's own message boxes follow the light/dark app mode like UX1's warning).

The user's checks (rewritten M-3, LP-8, the new UX4 items) are pending a user build.

## The user's words

STATUS.md "User directions", 2026-10-16 about 12:55 (the user's answers on the page "civ64 User Checks", relayed
in a separate chat), verbatim:

> Custom M-3: "Ctrl+Shift+0 is not working both on numlock and keyboard row, the rest is ok."
>
> Custom LP-5: "Passed, but relevant dialog boxes does not follow system theme i.e. dark mode."
>
> Failed LP-8: "changed window parameters to window=-4050,-5130,2137,1412 manually, launched game, heard sound but
> game window not seen. Config parameters in window overriden by the game with the following values." (the note
> names no values)

## Findings

### M-3 (a): the keypad's 0 never arrived as a key of the chord

* `zoom_key` (`present/arrive.c`) mapped the reset to `'0'` (0x30) and `VK_NUMPAD0` (0x60) only.
* Windows' keyboard layer (the SDK's `kbd.h`: the keypad keys are `KBDNUMPAD | KBDSPECIAL`, their scan codes
  0x47..0x53 without the extended flag; "Key message lParam bits ... `FAKE_KEYSTROKE 0x02000000`") gives
  `VK_NUMPAD0` only while Num Lock is on **and Shift is up**. With Ctrl+Shift down the keypad's 0 is always
  `VK_INSERT` with scan code 0x52 (not extended): with Num Lock off directly, with Num Lock on after Windows
  releases Shift itself (a system keystroke with lParam bit 25) just before the key. So the chord could never be
  made from the keypad, in either Num Lock state; `VK_ADD` and `VK_SUBTRACT` do not change with Num Lock, which is
  why Plus and Minus worked ("the rest is ok").
* With Num Lock on, Windows' own Shift release also broke the chord on its own: the arrival stage took it as the
  player's release (K3: Ctrl's and Shift's held presses and Shift's release delivered), so even a known
  `VK_INSERT` would arrive with Shift up. Verified on the code paths by the new tests: before UX4's hold-back the
  sequence Ctrl, Shift, Windows' Shift release, keypad 7 gives Ctrl down, Shift down, Shift up, Home down; UX4
  keeps exactly these events for every key except the reset chord (Tests).
* The gray Insert key is `VK_INSERT` with scan 0x52 **extended** (0x152 in `PiKey.scan`), so the keypad's 0 is
  distinguished by the extended flag.

### M-3 (b): the main row's Ctrl+Shift+0 does not reach civ64 on the user's machine

* civ64 itself handles it: `zoom_key` maps 0x30, and the new Win32-headless test sends Ctrl, Shift, `'0'` (scan
  0x0B) to the host window: the zoom is reset and no event reaches the game (Tests). So the key messages do not
  arrive at the window, or arrive without being a chord.
* The hint (Windows' input-language hot key) was checked on this machine and **does not apply**:
  `HKCU\Keyboard Layout\Toggle` has `Hotkey`, `Language Hotkey` and `Layout Hotkey` 3 (not assigned);
  `HKCU\Control Panel\Input Method\Hot Keys` holds only 0x10..0x12, 0x70..0x72 and 0x200..0x203 (Ctrl+Space,
  Shift+Space, Ctrl+period, Ctrl+Shift+comma, Ctrl+Shift+G/K/L/V: IME hot keys), no per-layout hot key
  (0x100..0x1FF) and nothing with virtual key 0x30. Earlier in this unit `RegisterHotKey` for Ctrl+Shift+0
  succeeded, so no program owns it as a hot key.
* Running on this machine (`tasklist`): PowerToys with its **Keyboard Manager** module
  (`PowerToys.KeyboardManager`), Logi Options+ (`logioptionsplus_agent`), Windhawk. Each can take a key with a
  low-level keyboard hook before any window, raw input or hot key sees it (a key a low-level hook swallows
  produces no raw input), so neither raw input nor scan-code handling in civ64 can get it back; only a global
  low-level hook of civ64's own could, which the brief forbids. Their settings were not read (outside `claude/`).
  Whether the user's check ran on this machine is not known.
* Conclusion: not reliably fixable inside the window; per the brief a **question** with alternatives (Decision 3).

### LP-8: Windows gave the window its largest size above the displays, and civ64 wrote that back

* `window` is left,top,right,bottom in screen coordinates (`win64/civ64_main.c` `remembered_placement`), so the
  user's value is a 6187 x 6542 rectangle that meets the primary display (0,0..2137,1412 of it). LP's rule
  (`hw_place_decide`: kept while the requested rectangle meets any monitor) kept it.
* **Verified with the probe** on a hidden window, base host (this machine: one 5120 x 1600 display at 0,0,
  `SM_CXMAXTRACK` x `SM_CYMAXTRACK` 5140 x 1620, per-monitor-v2 as civ64.manifest): `GetWindowRect`
  -4050,-5130,1090,-3510 (5140 x 1620), `MonitorFromRect` NULL (on no monitor), `hw_placement` (what civ64 writes
  back as `window=` at exit) -4050,-5130,1090,-3510. Windows keeps the requested top-left and clamps the size to
  the largest window (`WM_GETMINMAXINFO`'s `ptMaxTrackSize`), which leaves the whole window above the display:
  "heard sound but game window not seen", and the "values" the user saw written back.
* Two weaknesses of the rule besides: it judged the monitors' rectangles, not their work areas (a title bar under
  a taskbar cannot be reached), and any one-pixel overlap counted as "on screen" (LP-8's own "partly off-screen
  stays" was meant for a usable window).
* After UX4 (the same probe on the overlay's host): `GetWindowRect` 0,0,1936,1479 (the default first size, scale
  3), on a monitor; `hw_place_last` `HW_PLACE_TOPLEFT` with the fit 5140 x 1620, strip 31; written back
  0,0,1936,1479.

### LP-5's remark: the system's message box is always light

* civ64's own boxes were `MessageBoxW` (`platform/win32/host_win32.c` `host_message` and
  `host_confirm_overwrite`; `win64/civ64_locate.c` `say`, `ask_windows`, `ask_dos` twice). Windows draws a
  `MessageBoxW` box light whatever the app mode; there is no documented switch for its body and buttons (F109's
  title bar and menus follow the app mode, UX1's exit warning is an own dialog that does). The core's w16 dialogs
  are not host boxes and are out of scope.

## Decisions

1. **Keypad 0 (M-3 a).** `VK_INSERT` with scan code 0x52 not extended is the keypad's 0 and makes the reset chord
   as `'0'` and `VK_NUMPAD0` do (`VK_NUMPAD0` kept); the gray Insert key (0x152) stays the game's key. Only the
   observer builds have the zoom chords, as before.
2. **Windows' own Shift release (M-3 a).** The Win32 back end marks a key message as Windows' own
   (`PiKey.fake`, new last member, 0 for every other source) when lParam bit 25 (`FAKE_KEYSTROKE`) is set, or, for
   a Shift release without it, when the next key message already in the window's queue has the same message time
   and is a keypad key (scan 0x47..0x53 not extended, not 0x4A/0x4E): a fallback for a system that posts the pair
   without the bit. The arrival stage holds such a Shift release back only while it may serve the chord (observer
   build, Shift down in the arrival's state, Ctrl down, Alt up) until the next event: when that is the keypad's 0
   making the reset chord, the release is dropped (Shift stays down and serves the chord, as the player holds it);
   every other next event (another key, a character, a mouse event, the wheel, focus or capture loss, quit) takes
   the release first, so the events are exactly those of before UX4, in the same order. No global hook, no raw
   input, no `RegisterHotKey`.
3. **Main row (M-3 b): a question, no new chord.** The brief: "If (b) cannot be made reliable, do not invent a new
   chord. Stop that part and report it as a question for the user with 2-3 concrete alternative chords". The
   alternatives, each checked free against civ64's chords (Alt+Enter, Alt+F4, Ctrl+Shift+Backspace, Ctrl+Shift+
   Plus/Minus/0 and their keypad keys), the game's accelerators (civ.exe's ACCELERATOR 128 has no Shift entry, so
   no Ctrl+Shift chord reaches a game accelerator) and this machine's IME hot keys (Ctrl+Shift+G/K/L/V,
   Ctrl+Shift+comma):
   * **Ctrl+Shift+keypad * (`VK_MULTIPLY`)**: beside the keypad's Plus and Minus that work for the user, and like
     them unchanged by Num Lock (no Shift release by Windows);
   * **Ctrl+Shift+N** ("Normal", as the menu item "&Normal map zoom");
   * **Ctrl+Shift+Home** (the gray Home key; also the keypad's 7 with Num Lock off).
   Any one would be one more `case` in `zoom_key` and the menu item's accelerator text; Ctrl+Shift+0 would stay.
   The user is also asked whether a keyboard tool (PowerToys Keyboard Manager, Logi Options+, a Windhawk mod) maps
   Ctrl+Shift+0, and on which PC the check ran: if a tool takes it, an alternative may be taken too, and freeing
   Ctrl+Shift+0 in the tool would make the existing chord work. Meanwhile "Normal map zoom" (window menu) works.
4. **The remembered placement (LP-8).** A remembered rectangle is kept only when
   * its size is positive and not larger than the largest window Windows gives (`WM_GETMINMAXINFO`'s
     `ptMaxTrackSize`, recorded at the window's creation; `SM_CXMAXTRACK`/`SM_CYMAXTRACK` at its DPI if none), and
   * a usable part of its title bar strip (the frame's top edge to the client: 31 pixels at 100 %, from
     `AdjustWindowRectExForDpi` at the window's DPI) lies in one monitor's **work area**: at least half the strip's
     height and at least twice its height in width (62 pixels at 100 %: enough of the caption to see it and drag
     it), or the whole strip when the window is narrower.
   Partly off-screen windows and windows straddling two monitors are kept as before when their title bar is
   usable. Else the window goes to the primary work area's **top-left corner** with the remembered size when that
   fits the work area, else the default first size clamped to it: LP's corner rule, unchanged (`hw_place_corner`).
   The brief mentioned "the first-start rule (centred, default size)"; UX4 keeps the corner because it is the
   user's own rule of 2026-10-11 about 22:20 UTC and the wording of LP-8 ("comes back at the top-left corner of
   the primary screen's work area"); changing it to centred is one line in `hw_create_window_ex`'s fallback if the
   user prefers.
5. **The rectangle Windows actually gives.** After the move `hw_create_window_ex` reads `GetWindowRect` and
   checks its title bar strip again at the window's DPI (a DPI change on another monitor, a size Windows adjusts);
   if it is not usable the window goes to the corner by the same rule (`HW_PLACE_MOVED`). With the size limit in
   Decision 4 this second check is a safety net: no test case reaches it on a real window (Tests).
6. **What is written back at exit.** Unchanged code path: civ64 writes `hw_placement`, the window's normal
   rectangle as it is. After a remembered value that was not used this is the corner rectangle the window really
   got, so an unusable value repairs itself at the first exit (the user's value becomes 0,0,1936,1479 on this
   machine) and a usable one is written back as before. A value the player never moved away from is not kept
   "as typed" (it would open off-screen again); `civ64_main.c`'s reading rule (`r - l` and `b - t` at least 100,
   every value within +-32768) is unchanged.
7. **Message boxes (LP-5).** `hw_message_box(owner, text, caption, type)` (`host_win32.h`) replaces the six
   `MessageBoxW` calls: an in-memory dialog built and themed with UX1's machinery (the `Tmpl` template builder,
   `box_button`'s owner-drawn buttons, `theme_wanted`/`theme_window`, F109's colours, the default following the
   focus). It keeps `MessageBoxW`'s caption, text (word-wrapped, no prefix, tabs expanded; a long word such as a
   path is broken), icon (the system's hand, question, exclamation or asterisk icon at the window's DPI) and its
   sound, the buttons of `MB_OK` .. `MB_CANCELTRYCONTINUE` with Windows' own (localised) labels from
   `MB_GetString`, `MB_DEFBUTTONn`, the answers, Escape and the close box (Cancel's answer; OK in an `MB_OK` box;
   nothing in `MB_YESNO` and `MB_ABORTRETRYIGNORE` boxes, whose close box is grayed), the layout of a text area
   above a button band with right-aligned buttons (light: the system's window and dialog colours; dark: RGB 32
   and 43 with white text), centred in the work area of the owner's monitor, modal over the owner. A change of the
   app mode while a box is open applies at once. Any other flag, or a dialog that cannot be made, is the system's
   `MessageBoxW` unchanged. Not kept: Ctrl+C copying a box's text; `MB_TASKMODAL` disables the owner (civ64's
   only window), not every window of the thread. Callers' `g_host_box` counting (UX1) is unchanged.
   `box_button` draws a label's mnemonic underline only while the keyboard cues show (`ODS_NOACCEL`), which
   changes nothing for UX1's and the About box's labels (they have no `&`).

## What was built

### Staged files

Full copies under `build/ux4-stage/` at the tree's paths, each with its base's line endings (LF: `arrive.c`,
`host_win32.c/.h`, `test_host_win32.c`; CRLF: `input.h`, `civ64_locate.c`, `test_input.c`; `obj/eol.py check`
EOL_OK); bases in `BASE-SHA256.txt`, the staged copies' hashes in `STAGED-SHA256.txt`. Every change sits in a
block or line marked "extension UX4". One new file: this record.

| file | change |
|---|---|
| `present/input.h` | header paragraph; `PiKey.fake` (new last member, UX4 block) |
| `present/arrive.c` | header paragraph; `PI_VK_INSERT`, `PI_SCAN_PAD0`; `g_fake`, `g_fake_key`; `pi_reset`'s line; `zoom_key(vk, scan)` with the `VK_INSERT` case; `ctrl_shift_cmd` (the chord condition moved out of `pi_arrive_key` unchanged); UX4 block `fake_may_serve`, `fake_release`; `pi_arrive_key`'s UX4 block (the held-back release) and its chord site through `ctrl_shift_cmd`; `fake_release` first in `pi_arrive_char`, `_quit`, `_focus_lost`, `_capture_lost`, `_wheel`, `_mouse` |
| `platform/win32/host_win32.h` | the placement comment; UX4 block `HwPlaceFit`, `hw_place_usable`, `hw_place_corner`, `HW_PLACE_MOVED`, `hw_place_last`; `hw_place_decide`'s new `fit` parameter (areas: work areas); UX4 block `hw_message_box`, `HW_BOX_ICON`/`HW_BOX_TEXT`, `hw_box_open`, `hw_box_answer`, `hw_box_close` |
| `platform/win32/host_win32.c` | header paragraph; `host_message` and `host_confirm_overwrite` through `hw_message_box`; UX4 block `HW_FAKE_KEYSTROKE`, `pad_key_message`, `fake_key`; `key_down`'s and `key_up`'s `k.fake`; the placement comment; UX4 block `g_place_last`, `g_place_fit`, `g_max_track`, `hw_place_last`, `hw_place_usable`, `hw_place_corner`; `hw_place_decide` with the fit (LP's `place_meets` removed); `mon_cb`'s UX4 block (work areas); `title_strip` after `outer_for_dpi`; `WM_GETMINMAXINFO` records `ptMaxTrackSize`; `hw_create_window_ex`: `g_max_track` reset, the fit, the check after the move, `g_place_last`; `box_button`'s `DT_HIDEPREFIX`; UX4 block (after `exit_request`) the message box: `BoxKind`, `Box`, `box_supported`, `box_label`, `box_init`, `box_template`, `box_dlu`, `box_measure`, `box_layout`, `box_theme`, `box_answer`, `box_proc`, `hw_message_box`, `hw_box_open`, `hw_box_answer`, `hw_box_close` |
| `win64/civ64_locate.c` | `say`, `ask_windows`, `ask_dos` (two): `hw_message_box` in place of `MessageBoxW` |
| `tests/test_input.c` | UX4 block `fkey`, `ux4_keypad` and its call after `hold_rule` |
| `tests/win32/test_host_win32.c` | UX4 block `ux4_level1`, `ux4_ctrl_shift`, `ux4_post_pad0`, `test_ux4_keys`, `ux4_box_buttons`, `ux4_defid`, `test_ux4_box` (calls after `test_window_d3b2`); `test_place_decide` with the fits, two changed expectations and the UX4 block; `test_placement`'s UX4 block |

No `build.cmd`, `test.cmd`, `civ64.manifest`, resource or library change (`hw_message_box` uses user32, gdi32,
uxtheme and dwmapi, already linked; `MB_GetString` through `GetProcAddress`).

## Tests

* **`tests/test_input.c`** `ux4_keypad` (18 checks in the observer builds, 2 in CheckedNoObs; 417 -> 435
  Checked): Num Lock off, Ctrl+Shift+`VK_INSERT` 0x52: the reset, no event; its repeat nothing; the releases
  nothing. Num Lock on: Windows' Shift release (fake) held back with no event; then `VK_INSERT` 0x52 (the host's
  Shift state up): the reset, no event; its release nothing; the keypad's 0 again with Shift still held: the reset;
  the player's own Shift release and Ctrl's: nothing; then A alone: one event (state clean). Windows' own Shift
  press after the chord: still held; then X: Ctrl, Shift, X (as after Ctrl+Shift+Backspace). The gray Insert
  (0x152): Ctrl, Shift, Insert, no command. Windows' release before keypad 7 (`VK_HOME` 0x47): Ctrl, Shift, Shift
  up, Home (before UX4's events). A mouse move after the held release: Ctrl, Shift, Shift up, the move. Focus loss
  after it: Ctrl, Shift, Shift up, Ctrl up. Windows' release without Ctrl: at once. The main row's 0 (0x0B): the
  reset. Without the observer: Windows' release at once (Ctrl, Shift, Shift up); the keypad's 0 reaches the game.
* **`tests/win32/test_host_win32.c`** (387 checks Checked, from 329):
  * `test_ux4_keys` through `hw_window_message` and the real queue (observer builds): Ctrl+Shift+keypad 0, Num Lock
    off (with a repeat): the zoom reset from level +1 to 0 (`pmap_level`), no event; Num Lock on with lParam bit
    25 on the Shift release: held back (no event, level still +1), then the reset; Num Lock on with the Shift
    release **posted** without the bit together with the keypad's 0 at one message time (`ux4_post_pad0`, which
    checks the two queued times and retries up to five times): taken from the queue by `host_poll_event`, the
    reset, no event, and the player's releases after it nothing; the main row's `'0'` (scan 0x0B): the reset;
    the gray Insert (bit 24): no zoom, Ctrl, Shift and Insert 0x152 reach the game; Windows' release before
    keypad 7: Ctrl, Shift, Shift up, Home, as before. Without the observer: the release at once, the keypad's 0
    reaches the game.
  * `test_ux4_box` (hidden modeless boxes, `hw_box_open`; quiet mode for `hw_message_box`): `MB_YESNO |
    MB_ICONWARNING` in light mode: hidden; the caption "Save As" and the two-line text; the warning icon shown;
    Yes and No, Yes the default, a non-empty Windows label; the text laid out inside the box; Escape/close answer
    nothing and the close box grayed; light colours (not the dark text); No answers `IDNO`. Dark mode, `MB_OK |
    MB_ICONEXCLAMATION | MB_TASKMODAL` with the port's caption: OK the default, the dark background and white
    text, Escape answers `IDOK`. `MB_OKCANCEL | MB_ICONINFORMATION | MB_DEFBUTTON2`: Cancel the default, the
    default following the focus to OK, Escape answers `IDCANCEL`. `MB_YESNOCANCEL | MB_DEFBUTTON3`,
    `MB_ABORTRETRYIGNORE | MB_DEFBUTTON4` (a default past the buttons: the first; Escape nothing), `MB_RETRYCANCEL`
    without an icon (none shown), `MB_CANCELTRYCONTINUE`: their buttons and defaults. `MB_TOPMOST`, `MB_HELP`,
    `MB_USERICON` and type 7: no box of ours (`MessageBoxW`'s). A 700-character text of words and one of a single
    long word: wrapped into several lines, the box narrower than the work area. Quiet `hw_message_box`: no box,
    the default's answer (`IDNO` for `MB_DEFBUTTON2` of Yes/No, `IDOK`), counted by `hw_messages`.
  * `test_place_decide`: every call with a fit (1940 x 1100 or 3860 x 1100, strip 31); two LP expectations changed
    (Expected expectation changes); new: exactly the largest window larger than the work area with its title bar
    shown kept, one pixel wider the corner; 62 pixels of the title bar on a negative-coordinate monitor kept, 61
    the corner; the user's LP-8 value: kept by LP's rule (no fit: the defect), the rectangle Windows gave it on no
    display (`hw_place_usable` 0 with and without a strip), with the fit (5140 x 1620) the corner with the default
    size; 15 of the strip's 31 rows on the display the corner with the remembered size, 16 kept; a title bar under
    a bottom taskbar the corner; 30 pixels of it at the right edge the corner, 62 kept; an empty rectangle the
    default and never usable; strip 0 is LP's any-overlap; `hw_place_corner` with an empty size and with a fitting
    one.
  * `test_placement`'s UX4 block on the hidden window: the user's LP-8 value: `hw_placement` (the write-back) is
    at the primary work area's top-left and inside it, `hw_place_last` `TOPLEFT` (or `MOVED`) with a positive fit,
    the window's rectangle on a display with its top in the work area; a remembered rectangle with its title bar
    shown: `KEPT`; the window's title bar above the work area (only its bottom on the display; run when no monitor
    is above): the corner, the remembered size 900 x 720.
* **Probe** (`obj/probe/lp8_probe.c`, hidden window): the base and the overlay host as in Findings.

## Results

Private, 2026-10-16 (Istanbul time is UTC+3); the overlay's bases equal the tree's (`BASE-SHA256.txt`, re-verified
after SL's ALL_GREEN and at the end).

The final overlay was made at 14:35:25 UTC from the tree **after D6d's landing** (D6d ALL_GREEN 14:34 UTC; its
files and UX4's do not overlap, so no UX4 block needed re-applying); an earlier full round on the tree before
D6d's copy-in gave the same UX4 results.

| variant | build (`obj/ball.cmd`: `obj/b.cmd`, build.cmd `--nogen`) | headless + Win32-headless (`obj/ut.cmd`) |
|---|---|---|
| Checked | `BUILD_OK` 14:39:45 UTC; portable sources checked: 293 (c11, c17, c99 parse) | 0 failed of 52 programs (and `check_ne.py` errors 0): `test_input` 435, `w32_test_host_win32` 387; every other count equal to the tree's `build/test/Checked/sections/unit.log` (D6d's run, 14:19 UTC): the only two differences in a diff of the PASS lines are these two |
| CheckedNoObs | `BUILD_OK` 14:43:52 UTC; 293 | 0 failed of 52 programs: `test_input` 392, `w32_test_host_win32` 365 |
| Release | `BUILD_OK` 14:49:12 UTC; 293 | 0 failed of 52 programs: `test_input` 435, `w32_test_host_win32` 387 |

Probe (Findings): the base host (before UX4's edits) and the final overlay's host (14:53 UTC), this machine,
hidden window.

Other checks test.cmd runs, privately on the final overlay: `tests/harness/obs_lint.py` (the overlay's):
`OBS_LINT_OK files 119 probes 203 callsites 98`; `gen/dos/registry.py check` (the overlay's, `--dosdata` and
`--disasm` the tree's, read): `REGISTRY_OK` (0 failures); `gen/dos/nodos.py check --root <overlay> --variant V`:
`NODOS_OK` for Checked (612 files), CheckedNoObs (612) and Release (611), 0 hits each. `testpar.py` was not run:
test.cmd is unchanged. Not run: the harness sections (no harness, core or w16 change; the 7.8 host-form keys never
set `fake`), G-1 and P0 (the build slot's cycle).

The compiled overlay's sources equal the staged files (`mkoverlay.py` copies them; `STAGED-SHA256.txt`); the staged
files keep their bases' line endings (`obj/eol.py check`: EOL_OK). The bases equal the tree's at 14:53 UTC.

## Expected expectation changes

Two LP expectations in `test_place_decide` change (the tests now pass a fit; LP's no-fit rule stays testable):

* "larger than the work area but on the display: kept" (-100,-100..2500,1500 on 1920 x 1080): now
  `HW_PLACE_TOPLEFT` at 0,0..1296,999 (2600 x 1600 is larger than the largest window 1940 x 1100; its title bar
  was above the display too).
* "one pixel on the negative-coordinate monitor: kept" (-2900,0..-1919,500): now `HW_PLACE_TOPLEFT` at
  0,0..981,500 (one pixel of title bar is not usable).

Counts: `test_input` +18 in the observer builds (Checked 417 -> 435, Release 435), +2 in CheckedNoObs (392);
`w32_test_host_win32` +58 in the observer builds (Checked 329 -> 387, Release 387), +51 in CheckedNoObs (365; its
key test has 2 checks instead of 9). Nothing else changes: the arrival stage's events are those of
before UX4 for every input except the keypad's reset chord (which reached the game before), every scripted line
and the harness have `fake` 0 (`harness.c` and `test_map.c` clear their `PiKey` with `memset`), and the core is not
touched (P0 and G-1 hold: no core, w16 or harness change; the harness's 7.8 host-form keys never set `fake`).
`test_map.c` (D6d's staging) keeps passing: its chord loop gives scan 0x0D to all six chord keys, and `zoom_key`
looks at the scan code only for `VK_INSERT`.

Predictions for the build slot: `build.cmd checked` BUILD_OK (portable sources checked unchanged in number);
`test.cmd checked` TESTS_OK with the counts above, every other section as at SL's gate; `ext_g1.py check`
`EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)` (unchanged).

## Rebase notes

Shared files and UX4's blocks in them (each marked "extension UX4"; re-apply onto a newer tree copy as listed).
SL and D6d have landed in the base (D6d after the bases were taken, without touching UX4's seven files; the final
private round ran on the tree with both):

* `platform/win32/host_win32.c` (SL landed its blocks in this base; UX3's, UX1's, LP's present): the header
  paragraph after UX3's; `host_message`'s two lines; the key block after `scan_of`; one line each in `key_down`
  and `key_up`; `host_confirm_overwrite`'s line (SL's slot-name lines before it are kept); the placement section
  (LP's comment's last sentence, the UX4 block before `hw_place_decide`, `hw_place_decide` itself, `mon_cb`'s
  block); `title_strip` after `outer_for_dpi`; the `WM_GETMINMAXINFO` line; `hw_create_window_ex`'s block;
  `box_button`'s last `DrawTextW`; the message-box block after `exit_request`. A unit that adds a host
  `MessageBoxW` should call `hw_message_box` instead.
* `platform/win32/host_win32.h`: the placement comment, the two UX4 blocks and `hw_place_decide`'s prototype. Any
  other caller of `hw_place_decide` (none in the tree) needs the `fit` argument (NULL gives LP's rule).
* `present/input.h`: `PiKey.fake` is the **last** member: a unit adding a member puts it after; every `PiKey` must be
  cleared (`memset`) or fully initialized.
* `present/arrive.c` (D6c/D6d may stage it): `zoom_key` takes the scan code; the chord condition lives in
  `ctrl_shift_cmd` (a new Ctrl+Shift chord goes there or into `zoom_key`); `fake_release(o)` must stay first after
  `begin(o)` in every `pi_arrive_*` entry, including any new one.
* `win64/civ64_locate.c`: four call sites.
* `tests/test_input.c`, `tests/win32/test_host_win32.c`: the blocks above; `test_place_decide`'s calls take the fit.

## Build-slot steps

1. From the port root: `sha256sum -c build/ux4-stage/BASE-SHA256.txt` (7 files). Any base that changed since
   13:29 UTC: re-apply UX4's blocks onto the tree's copy ("Rebase notes"), keeping the file's line endings, and
   recompile privately (`build/ux4-stage/obj/mkoverlay.py`, `obj/ball.cmd`, `obj/ut.cmd src <variant>`) before
   going on.
2. Copy the 7 staged files into the tree at the same paths (`STAGED-SHA256.txt`); copy this record to
   `docs/ext-UX4-record.md`. No build.cmd or test.cmd change.
3. The three-step cycle: `build.cmd checked`, `test.cmd checked`, `C:/Python314/python -B tests/harness/ext_g1.py
   check`, with the predictions above.
4. A user build (Release) with `WHAT-TO-CHECK.txt` from "What the user checks", and the user's answer to the M-3
   question (Status) relayed; the docs pass applies "For the records".

## What the user checks

Rewrites for `manual-checklist-ext.md` and new items (section UX4). Tell the user that the main row's
Ctrl+Shift+0 is a question this time (M-3 (b) below), not a fix.

* **M-3** (rewritten): Press Ctrl+Shift+Plus and Ctrl+Shift+Minus (main row or keypad): the map zooms in one
  level, out one level. Press Ctrl+Shift with the **keypad's 0**, once with Num Lock on and once with it off: the
  map goes back to normal (level 0) and nothing else happens in the game. Turn the mouse wheel over the map:
  forward zooms in, back zooms out, and the map point under the pointer stays under it. The wheel over anything
  else does nothing. (The main row's Ctrl+Shift+0: see the question; "Normal map zoom" in the window menu always
  works.)
* **M-3 question** (to answer, not to check): on your PC the main row's Ctrl+Shift+0 never reaches civ64 (civ64
  handles it when it arrives). Does a keyboard tool (PowerToys Keyboard Manager, Logi Options+, a Windhawk mod)
  use Ctrl+Shift+0, and was the check on this PC? Choose: keep Ctrl+Shift+0 only (free it in the tool), or add
  one of **Ctrl+Shift+keypad \*** (beside the keypad's Plus and Minus, not affected by Num Lock),
  **Ctrl+Shift+N** ("Normal") or **Ctrl+Shift+Home**.
* **LP-8** (rewritten): The `window` key in `civ64.cfg` is `window=left,top,right,bottom`: the window's outer
  rectangle in screen pixels (the primary screen's top-left is 0,0; `right` and `bottom` are one past the window,
  so the width is right - left). Move the window entirely off-screen (or remove a monitor it was on, or edit the
  value off-screen, for example `window=-4050,-5130,2137,1412`), close civ64 and start it again: the window
  comes back at the top-left corner of the primary screen's work area, with its size when that fits the screen,
  else the default size. A window left partly off-screen stays where it was while enough of its title bar to
  drag it (about two title-bar heights wide, at least half its height) is on a screen. After such a start,
  closing civ64 writes the rectangle the window really had back to `window`.
* **UX4-1** (LP-8, too large): edit `window` to a rectangle larger than all your screens together but starting on
  the screen (for example `window=0,0,9000,9000`): civ64 opens at the top-left corner of the primary work area with
  the default size, entirely visible.
* **UX4-2** (LP-8, title bar): edit `window` so that only the lower part of the window is on the screen (for
  example top -700 with a height of 900): it opens at the top-left corner with its size. Edit it so that the title
  bar is just inside the top of the screen: it stays there.
* **LP-5 remark / UX4-3**: with Windows in dark mode (Settings > Personalization > Colors > "Choose your app mode:
  Dark"), see civ64's own boxes: start civ64 with the DOS files missing (the note about them), choose "Locate DOS
  files..." and pick a wrong file (the refusal), and in the game save over an existing file (Windows graphics, the
  file chooser: "already exists. Do you want to replace it?"): each box has a dark title bar, a dark text area, a
  slightly lighter button band and dark buttons with white text, the right icon, the caption "Sid Meier's
  Civilization 64bit" (the overwrite question: "Save As"), and the same buttons and answers as before (Escape
  closes the note; Yes/No questions need Yes or No). In light mode the boxes look like Windows' own: a white text
  area above a grey button band. Switch the app mode while a box is open: it follows.
* **UX4-4**: the boxes' buttons work by mouse, Enter (the button with the focus), Tab and the underlined letters
  (shown after Alt is pressed).

## For the records

Wording changes for the docs pass (not edited by UX4):

* **manual-checklist-ext.md**: M-3 and LP-8 rewritten as above (status pending, "rework: unit UX4" replaced by the
  user build); LP-5's remark: "implemented by UX4 (UX4-3)"; new section UX4 with UX4-1..UX4-4 and the M-3 question
  until it is answered. **LP-8's key format**: `window=left,top,right,bottom` (outer rectangle, screen pixels, the
  primary screen's top-left 0,0, right and bottom exclusive), as in the rewrite.
* **FIDELITY.md F111**: append "Extension UX4 (2026-10-16, the user's LP-8 result): a remembered rectangle is kept
  only while Windows gives it as it is (not larger than the largest window, `WM_GETMINMAXINFO`) and a usable part
  of its title bar strip (at least half its height, twice its height wide) lies in a monitor's work area; else the
  primary work area's top-left corner (LP's size rule); the rectangle Windows gave is checked again after the move;
  the value written back is the window's real rectangle."
* **FIDELITY.md F109**: append "Extension UX4: civ64's own message boxes (host messages, the overwrite question,
  the DOS/Windows files notes and questions) follow the app mode too (`hw_message_box`)."
* **FIDELITY.md** (the chords' entry, F114/F132 or M's): "Extension UX4: the keypad's 0 makes Ctrl+Shift+0 as
  `VK_INSERT` with scan 0x52 (not extended; Num Lock off, or on with Windows' Shift release, which the arrival stage
  holds back and drops for this chord only); the gray Insert key stays the game's."
* **DESIGN.md 12.2** (the window placement, lines about `hw_place_decide(mons, nmon, ...)`): the new signature
  `hw_place_decide(areas, narea, work, have, want, def_w, def_h, fit, &out)` with work areas and `HwPlaceFit`,
  `hw_place_usable`, `hw_place_corner`, `HW_PLACE_MOVED`, and the post-move check; the message-box line ("Message
  box: MessageBoxW on the host window", DESIGN.md 5) becomes `hw_message_box` (in-memory dialog, F109's modes,
  MessageBoxW's semantics; MessageBoxW for other flags); the LP caption paragraph (`civ64_locate.c`'s "three
  MessageBoxW") likewise.
* **DESIGN.md 12.5 / ext-d1-draft-A.md 10.1** (the arrival stage): `PiKey.fake` and the held-back Windows Shift
  release.
* **win64/civ64_main.c** comment above `remembered_placement` ("meets no monitor at all goes to that work area's
  top-left corner"): "whose title bar is not usable, or which Windows cannot give as it is, goes to ..." (a comment
  only; UX4 did not stage `civ64_main.c`).
* **RUNNING.md** (the `civ64.cfg` keys, if it lists `window`): the format left,top,right,bottom as above.
* **STATUS.md**: UX4's row with the QUESTION for M-3's main row.

## Landing (2026-10-16, build slot)

**Landed 2026-10-16 14:58:30 UTC; cycle ALL_GREEN 15:27:18 UTC; RELEASE_OK 15:32:03 UTC; user build
`build/user-builds/ux4/`.**  Done by the build slot on the orchestrator's instruction, after the docs pass for D6d
(`build/docs-d6d-done.txt`, 14:58:19 UTC, "docs-d6d done", not BLOCKED; it touched docs only). The decision on LP-8
was kept as staged (the top-left corner: the user's rule of 2026-10-11).

1. **Bases.** `build/ux4-prep/land.py`: all 7 tree files still had their bases (`build/ux4-stage/BASE-SHA256.txt`,
   13:29 UTC; SL's, D6d's and the docs pass's landings touched none of them), this record was absent, and the 8
   staged copies had the SHA-256 frozen in `build/ux4-prep/staged.sha256`. Dry run `DRY_RUN_OK 8`. No rebase was
   needed.
2. **Snapshot and copy.** Before writing: the tree's Checked test outputs (59 files of `build/test/Checked`, D6d's
   cycle) in `build/ux4-prep/before`, the tree's previous 7 files in `build/ux4-prep/tree-before`. The 8 files byte
   for byte (7 changed, this record new): `LANDED 8`; manifest `build/ux4-prep/landed.sha256` (with test.cmd's and
   build.cmd's unchanged SHA-256); `landed-at.txt`. No build.cmd or test.cmd change.
3. **Cycle** (`build/ux4-prep/ux4-cycle.ps1`, D6d's script with the UX4 names and a step range; status
   `build/ux4-status.txt`, logs `build/ux4-<n>-<step>.log`):
   - 1 build-checked: exit 0, 236 s, BUILD_OK; portable sources checked 293; 52 test programs.
   - 2 test-checked: exit 0, 1486 s, TESTS_OK, 27 sections, failed 0. `w32_test_host_win32` passed at the first run
     (387 checks): no GetKeyState rerun and no -r2 test step were needed.
   - 3 g1-checked: exit 0, EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events): **ALL_GREEN**.
   - 4 build-release: exit 0, 240 s, BUILD_OK: **RELEASE_OK**.
4. **Comparison** (`build/ux4-prep/compare.py`, output `compare.txt`; the predictions in
   `build/ux4-prep/predictions.txt` were written before the copy-in; prediction against output in
   `build/ux4-prep/comparison.txt`): 54 of 59 files equal (lines with times left out). The differences:
   - `sections/unit.log`: `test_input` 417 -> 435 and `test_host_win32` 329 -> 387 checks, as predicted; the
     OBS_COST line's nanoseconds (host time, predicted); **not predicted**: two lines `[box] c: q`, the stderr note
     `hw_message_box` writes for a box in quiet mode (test_ux4_box's quiet-mode check makes two; the quiet
     `host_message` writes `[message] ...` the same way).
   - `sections/times.txt`: section times (wall 1484 s; ext_zoom's soak stays the critical path).
   - `coverage.txt` and `sections/coverage.log`: "other functions entered" 665 -> 666, **not predicted**: coverage.py
     is informational and that count moves from run to run without a core change (earlier landings' comparisons:
     661 to 665); rt entries 145 of 155 unchanged. UX4 changes no core, w16 or harness file.
   - `nodos.txt`: 1725 -> 1726 files, more bytes, 0 hits, **not predicted** (as at D6d's landing): the new file is
     this record, which nodos scans like every file of claude/port outside `build/`.
   Every other output equal, as predicted: REGISTRY_OK, NODOS_OK, OBS_TABLES_OK probes 203 sites 98, OBS_LINT_OK
   files 119 probes 203 callsites 98, ADAPT_OK rows 98 steps 22, P0_OK checks 476, EXT_ASPECT_OK, EXT_ADAPT_OK checks
   128, MIRROR_OK runs 29, REPLAY_OK checks 70, ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32,
   ext_frames, ext_timeline, ext_continue, bs1..bs3, ext_slots, gate3b, uninit, scenarios, p4tests, harness_stub,
   d4a_pdos_scene, d4c1_adapters, trace.
5. **User build** `build/user-builds/ux4/`: `civ64.exe` (the Release build, SHA-256 0064717f...49341981),
   `CIVWIN.zip` and `civdos.zip` (byte-identical copies from `user-builds/d4`, SHA-256 checked) and
   `WHAT-TO-CHECK.txt` (M-3 keypad with Num Lock on and off; the main row: the user chose Ctrl+Shift+Home, which comes
   in the follow-up build "ux4b"; LP-8 with the `window=left,top,right,bottom` format and how to test it, the user's
   value first; LP-5's dark boxes and how to make one appear; the builds it contains: d6d, sl, d5k2, ux3, d5k, d6c,
   ux2, d5).
6. **Not done here**: the entries of "For the records" (FIDELITY F109 and the chords' entry, DESIGN 12.2/12.5 and 5,
   draft A 10.1, civ64_main.c's comment, RUNNING, the checklist's M-3/LP-8 rewrites and UX4-1.., STATUS) are the
   docs pass's. M-3's main row continues as unit UX4b (Ctrl+Shift+Home).

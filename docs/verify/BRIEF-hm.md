# Brief: unit HM, the host window menu with submenus (the user's interim task)

Recorded 2026-10-17 about 10:08 UTC by session E4's orchestrator from the user's chat message (verbatim below). The
user calls it an "Interim task to be done after current set of work completed". The orchestrator's reading: HM lands
after the units now in progress have landed. Those are the user's reworks D6fSa, D6fSb, DBL and UX5b, and the D7 units
now staging (D7c, D7d, D7j). Later units (D7e onward, D7l, D7m ...) are not held back by HM: the user's words order HM only after the current set, so a later unit that is ready while the current set is still in flight may land first rather than leave the build slot idle (the orchestrator's amendment of 2026-10-17 about 14:40 UTC; the earlier wording "HM lands before any later unit" was the orchestrator's own reading, not the user's). It may be staged earlier,
because it is host-only and its files do not overlap the DOS-presentation units. It is one unit with a design note, the
three-step cycle, a user build `build/user-builds/hm/`, a record `ext-HM-record.md` and checklist items HM-1...

## The user's text (verbatim)

```
Interim task to be done after current set of work completed. Update host application context menu as outlined below;

Restore
Move
Size
Minimize
Maximize
──────────────────────────────
Full screen            Alt+Enter
Display                        >
Map zoom                  >
Graphics                     >
──────────────────────────────
About…
──────────────────────────────
Close                     Alt+F4

DISPLAY SUBMENU

● Integer scaling (whole steps)
  Fit to window
──────────────────────────────
● Nearest-pixel filter
  Sharp filter
──────────────────────────────
✓ Correct 320 × 200 to 4:3

MAP ZOOM SUBMENU

  Zoom out (half)       Ctrl+Shift+Minus
● Normal zoom          Ctrl+Shift+0
  Zoom in (double)     Ctrl+Shift+Plus
──────────────────────────────
✓ Mouse wheel zooms map

GRAPHICS SUBMENU

  Windows graphics
● DOS graphics
──────────────────────────────
  Switch graphics      Ctrl+Shift+Backspace
──────────────────────────────
  Locate DOS files…

Host application context menu shall display 'DOS files present' as disabled item instead of 'Locate DOS files...'  if and when dos files are already present.
```

## Mapping onto today's menu (`platform/win32/host_win32.c` `add_menu`, `hw_update_menu`)

### Top level

* The standard Restore, Move, Size, Minimize and Maximize items stay, then a separator.
* "Full screen" with "Alt+Enter" (`SC_CIV_FULL`).
* The three submenus Display, Map zoom and Graphics.
* A separator, then "About…" (`SC_CIV_ABOUT`; the ellipsis character U+2026, as written).
* A separator, then "Close" with "Alt+F4" (`SC_CLOSE`).
  * This replaces UX1's text "Exit Sid Meier's Civilization 64bit". The command, the default item, the caption's close
    button, Alt+F4 and UX1's in-game warning stay unchanged.

### Display

Items are listed top to bottom; ○ marks an item that is not selected now.

| Item | Command | Kind |
|---|---|---|
| ● "Integer scaling (whole steps)" | `SC_CIV_INTEGER` | radio group with the next item |
| ○ "Fit to window" | `SC_CIV_FIT` | radio group |
| (separator) | | |
| ● "Nearest-pixel filter" | `SC_CIV_NEAREST` | radio group with the next item |
| ○ "Sharp filter" | `SC_CIV_SHARP` | radio group |
| (separator) | | |
| ✓ "Correct 320 × 200 to 4:3" | `SC_CIV_ASPECT` | check item |

Notes:
* "Correct 320 × 200 to 4:3" is today's "4:3 aspect ratio for 320 x 200 screens", same meaning. The × is U+00D7.
* The radio items use radio marks (`MFT_RADIOCHECK`); the check item uses a check mark.

### Map zoom

| Item | Command | Kind |
|---|---|---|
| "Zoom out (half)" with "Ctrl+Shift+Minus" | `SC_CIV_ZOOM_OUT` | radio group |
| "Normal zoom" with "Ctrl+Shift+0, Home" | `SC_CIV_ZOOM_DEF` | radio group |
| "Zoom in (double)" with "Ctrl+Shift+Plus" | `SC_CIV_ZOOM_IN` | radio group |
| (separator) | | |
| ✓ "Mouse wheel zooms map" | `SC_CIV_WHEEL` | check item |

Notes:
* The three zoom items show the current level by a radio mark. Today they are commands with no mark.
* The accelerator text of "Normal zoom" is "Ctrl+Shift+0, Home": the user's correction of 2026-10-17 about 10:28 UTC
  (verbatim: "Ctrl+Shift+0, Home"), naming both reset chords, Ctrl+Shift+0 and UX4b's Ctrl+Shift+Home. This
  supersedes the layout's "Ctrl+Shift+0" for this item.
* The items stay grayed in a build without the observer, as today.

### Graphics

| Item | Command | Kind |
|---|---|---|
| "Windows graphics" | `SC_CIV_PROF_WIN` | radio group with the next item |
| ● "DOS graphics" | `SC_CIV_PROF_DOS` | radio group |
| (separator) | | |
| "Switch graphics" with "Ctrl+Shift+Backspace" | new command | switches the profile, as the chord does |
| (separator) | | |
| "Locate DOS files…" | `SC_CIV_DOS_LOCATE` | command |

Notes:
* The accelerator text moves off the two radio items to "Switch graphics".
* **"DOS files present" instead of "Locate DOS files…"**: shown as a disabled item whenever the DOS files are present
  (found at start-up, or after a successful Locate). It is updated live.
  * A build without the observer keeps a grayed "Locate DOS files…", as today.
  * Open for the design note: what happens if the DOS files later go missing while civ64 runs (proposed: the label
    follows the current state at each menu opening).

### For the design note and tests

* Submenus of the window menu send `WM_SYSCOMMAND`; verify the handler sees the command IDs from the popups.
* Mnemonics are free of clashes within each menu.
* Every mark is kept in step by `hw_update_menu`: the profile at start-up (UX2/K7), live switches, the chords, the
  wheel, `--zoom` and the remembered `civ64.cfg`.
* The dark mode of the menu is as today.
* Win32-headless tests in `tests/win32/test_host_win32.c` cover:
  * the structure and texts, including U+2026 and U+00D7;
  * the radio and check marks after each command and chord;
  * the Locate/present item in both states;
  * Close.
* P0 unchanged.

### Later units that add menu items

These units come after the final Asan pass (`verify/BRIEF-extras.md`). They place their items in this structure:

* **A43**: in Display. The user's two texts from that request replace "Correct 320 × 200 to 4:3": "4:3 aspect ratio for
  320 x 200 DOS intro screens", then "4:3 aspect ratio for 320 x 200 DOS gameplay" (the orchestrator's choice, keeping
  the user's exact later-given names).
* **CRT**: "CRT scanlines" in Display, below the filters.
* **AMS**: "Alternative music/soundfx" as a check item at the top level, below Graphics.

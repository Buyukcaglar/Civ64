# Extension unit LP (the low-priority requests) — record

Brief: `docs/verify/BRIEF-m.md`, "Unit LP"; this record replaces the planned `ext-MW-record.md`. Session LP,
2026-10-11 (UTC times below are the machine's clock). Host-only: nothing of the core, the emulation, the
harness' frames, the checkpoints or `events.log` changes (P0; see "Builds and tests"). The wheel reaches the
game in neither state (I8).

## The user's requests (verbatim, 2026-10-11) and what was built

1. **Mouse wheel zoom item** (about 18:35): "Add an option to disable mouse wheel zoom operations to the
   host application context menu. This is low priority, implement after all checks done for the M phase."
2. **Version 1.0** (about 20:15): "Set application version to 1.0 and update about dialog box title text to
   "About Sid Meier's Civilization x64 v1.0" this is also low priority and implement with other low priority
   tasks."
3. **Titles** (about 22:00, replaces the About title of 2): "Make host application title bar text to "Sid
   Meier's Civilization 64bit" and About title bar text to "About Sid Meier's Civilization 64bit v1.0"".
4. **Captions** (about 22:05): "yes update Error and message-box captions also".
5. **Licence text** (about 22:10): "Update licence text in the About box also if it refers to this host
   application."
6. **Placement** (about 22:15): "The host application shall start both vertically and horizontally centered
   on the screen on initial startup. Must remember its last position on the subsequent launches. And if it is
   for some reason out of display area, it should re align itself top left corner of the primary screen on
   startup (display check)."
7. **Display-check rule** (about 22:20): ""entirely off-screen" is the rule".

### 1. "Mouse wheel zooms the map" (system menu)

* **Item:** `SC_CIV_WHEEL` **0x10F0**, text `&Mouse wheel zooms the map` (shown "Mouse wheel zooms the map",
  mnemonic M), a checkable item, **checked by default**, placed directly below "Zoom in (double)" and above the
  separator before "About...". `hw_update_menu` sets the check (also on `WM_INITMENU`).
* **Behaviour** (`platform/win32/host_win32.c`): chosen, it flips `g_wheel_zoom`, updates the menu, drops the
  wheel's partial sum and calls the new wheel hook with the new state. `WM_MOUSEWHEEL` with the item off returns 0
  at once (no `pi_arrive_wheel`, so no zoom command and no event: I8 holds in both states); on, the path is
  unchanged. The chords (Ctrl+Shift+Plus/Minus/0), the three zoom items, `--zoom` and the harness `zoom` command
  do not look at the flag. API (`host_win32.h`): `hw_set_wheel_zoom(int)` (the start state and tests; no hook),
  `hw_wheel_zoom()`, `hw_set_wheel_hook(fn)`.
* **Small presentation-layer addition:** `pi_arrive_wheel_clear()` (`present/input.h`, `present/arrive.c`) drops
  the half step (`g_wheel`) so that no remainder of an earlier notch survives a switch; the arrival stage and its
  tests are otherwise untouched.
* **Without the observer** (`CIV_OBSERVER 0`): the item is created grayed (as the zoom items) and checked; its
  command is ignored (no change, no hook call); the settings key is neither read nor written.
* **Settings key `wheel_zoom`:** `1` (on, the default) or `0` (off); absent or any other value is ignored (the
  item stays on). `win64/civ64_cfg.c/.h`: `civ64_cfg_wheel_zoom()` (1, 0, -1 absent or invalid) and
  `civ64_cfg_set_wheel_zoom()`; `win64/civ64_main.c`: the hook `wheel_chosen` remembers the player's last state in
  `g_wheel_chosen` and `save_settings` writes the key only after a change by the player; the remembered `0` is
  applied with `hw_set_wheel_zoom(0)` after the window exists.

### 2. Version 1.0 (`win64/civ64.rc`)

`VERSIONINFO`: `FILEVERSION 1,0,0,0`, `PRODUCTVERSION 1,0,0,0`, `FILEOS VOS_NT_WINDOWS32`, `FILETYPE VFT_APP`;
block `040904B0` (English US, Unicode) with `FileVersion` "1.0", `ProductVersion` "1.0", `ProductName` "Sid
Meier's Civilization 64bit", `FileDescription` "Sid Meier's Civilization 64bit (civ64)", `InternalName` "civ64",
`OriginalFilename` "civ64.exe", `LegalCopyright` "Copyright (c) 2026 Onur BUYUKCAGLAR" (the About box's own
copyright line). civ64's own names only, no original game data. `build.cmd` links `version.lib` into the Win32
test programs (and civ64.exe, where it is not referenced).

### 3. Titles, captions, licence note

* **One constant:** `HOST_CAPTION` / `HOST_CAPTIONW` = "Sid Meier's Civilization 64bit" in
  `platform/w16/host.h` (next to `host_message`).
* **Host window title bar** (`CreateWindowExW`, class `Civ64Host`): `HOST_CAPTIONW`. The comment keeps the
  earlier direction ("Sid Meier's Civilization") as history.
* **About box title** (`g_about_title`, read through `hw_about_title()`): `L"About " HOST_CAPTIONW L" v1.0"` =
  "About Sid Meier's Civilization 64bit v1.0". No test pinned the old title (the box does not open in quiet
  mode); the new accessor lets the test pin the new one.
* **Captions changed to `HOST_CAPTION`/`HOST_CAPTIONW`, every site:**
  `platform/win32/host_win32.c` (`host_message` calls: "Out of host memory." and the host-fault message),
  `present/present.c` (the two `host_message` calls of the profile refusal), `win64/civ64_main.c` (`fail`),
  `win64/civ64_locate.c` (`say` and the three `MessageBoxW`: Windows files not found, DOS files not found,
  "Ask again ..."). Four files, nine call sites.
* **Licence text** (`g_license`, read through `hw_about_license()`): the closing note is now "The licence covers
  this port's own code (Sid Meier's Civilization 64bit). Sid Meier's Civilization, its program and its data belong
  to their owners; ..." (the parenthesis uses `HOST_CAPTIONW`). The MIT body, the copyright line and the second
  sentence (it names the original game) are unchanged.
* **Left unchanged (judged out of scope):** the game's own dialogs and everything inside the emulation
  (`w16_MessageBox`, `rt_exit.c` ErrorMessage); the "Save As" overwrite prompt's caption (`host_win32.c`, named
  by its action, not the game); the file-picker prompts ("Civilization for Windows: choose civ.exe or a ZIP
  file" and similar: prompts, not captions) and the boxes' body texts; the test caption "test"; the headless
  host (it prints whatever caption it is given).

### 4. Window placement (`hw_place_decide`, `hw_create_window_ex`)

* **Pure decision** `hw_place_decide(mons, nmon, work, have, want, def_w, def_h, &out)` (`host_win32.h`,
  `HwPlaceRect`, screen coordinates): returns `HW_PLACE_CENTRED` (nothing remembered, or `--window`/`--scale`
  gave the size: the default outer size centred horizontally and vertically in the work area, never above or left
  of it), `HW_PLACE_KEPT` (the remembered rectangle meets some monitor with a positive-area overlap: position and
  size kept, partly off-screen or straddling two monitors included) or `HW_PLACE_TOPLEFT` (it meets no monitor at
  all: the work area's top-left corner, the remembered size if it fits the work area, else the default size
  clamped to it; no monitor known counts as meeting none).
* **Window creation:** the window is created at the primary work area's top-left (so on the primary monitor, at its
  DPI; **no `CW_USEDEFAULT`**), its default outer size is taken with `AdjustWindowRectExForDpi` at that DPI,
  `EnumDisplayMonitors` supplies the rectangles, and `SetWindowPos` applies the result before the window is shown.
  The maximized state is applied as before (it also applies when the rectangle went to the corner, so the window
  maximizes on the primary monitor).
* **Remembering** is unchanged in mechanism (`WM_EXITSIZEMOVE`, maximize/restore, the game's end; the key `window`
  and `maximized`), but the rectangle is now in **screen coordinates**: `hw_placement` converts
  `WINDOWPLACEMENT`'s workspace coordinates by the primary monitor's work-area offset (`ws_offset`), and the start
  uses `SetWindowPos` instead of `SetWindowPlacement`.
* `fit_scale` (the default size) now uses the primary monitor's work area, as the centring does (it used the
  monitor under the cursor).

### The user's rule and the choices made for it (recorded for change)

* "The screen" means the **primary monitor's work area** (`rcWork`): a top or left taskbar is never covered.
* The display check is the user's rule: **entirely off-screen** (no overlap with any monitor rectangle) moves the
  window; a window only partly off-screen, or straddling two monitors, keeps its position. (The first draft of the
  coordinator, "any part outside", was replaced by this at about 22:20.)
* "Top left" means the **work area's top-left** corner.

## Audit of the new menu id

Read-only (`grep`): the host's own ids are the multiples of 16 `0x1010..0x10E0` (`0x1030` retired in phase G,
F105); the system's `SC_*` commands start at `0xF000`, and `WM_SYSCOMMAND` keeps its low four bits; the
emulation's `WM_SYSCOMMAND`s (`platform/w16/user_menutrack.c`, `host_sync.c`, `user_misc.c`) live in its own
message queue and never reach the host window procedure, and w16 never calls `GetSystemMenu` (`user_menu.c`);
the only other hits for the hexadecimal text are core addresses (`0x10F00000`.. in `core/gen`), a different
domain. `0x10F0`, the next multiple of 16, is unused. The test pins the item's position (n-3, below Zoom in),
text and check state, and `SC_CLOSE`/doubled-separator checks are unchanged.

## Builds and tests

Final cycle after the last source change (every step green; logs `build/lp-*`):

| Step | UTC | Result |
|---|---|---|
| `build.cmd checked` (`lp-build-checked.log`) | 2026-10-11 22:09:47..22:12:51 | BUILD_OK; 254 portable sources (c11, c17, C99 parse) |
| `test.cmd checked` (`lp-test-checked.log`) | 22:13:00..22:45:15 | **TESTS_OK**; `w32_test_host_win32` **258 checks, 0 failures** (Ma's record: 196); `test_input` 140, `test_map` 127; REGISTRY_OK, NODOS_OK, GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK, P4_TESTS_OK, **P0_OK checks 279**, EXT_FRAMES_OK, **EXT_ADAPT_OK checks 20** (the 7.8 wheel run, default on), MIRROR_OK runs 29, ZOOM_OK (32 combinations, 64 runs), TRACE_OK |
| `ext_g1.py check` (`lp-g1-checked.log`) | 22:45:30 | **EXT_G1_OK runs 77** |
| `build.cmd checked noobs` (`lp-build-checkednoobs.log`) | 22:45:35..22:48:44 | BUILD_OK |
| `test.cmd checked noobs` (`lp-test-checkednoobs.log`) | 22:48:48..23:01:03 | **TESTS_OK**; `w32_test_host_win32` **244 checks, 0 failures**; `test_map` 1, `test_input` 122; GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK, P4_TESTS_OK, **P0_OK checks 56** |
| `ext_g1.py check --variant CheckedNoObs` (`lp-g1-checkednoobs.log`) | 23:01:10 | **EXT_G1_OK runs 77** |
| `build.cmd` (`lp-build-release.log`) | 23:01:18..23:04:23 | BUILD_OK |
| `test.cmd` (`lp-test-release.log`) | 23:04:23..23:10:11 | **TESTS_OK**; `w32_test_host_win32` **258 checks, 0 failures** |

No Asan. Earlier in the session: development builds of Checked (21:41, 21:45, 21:49, 21:52 UTC) and one
`test.cmd checked` started at 21:55 that I stopped (TaskStop) when the placement request arrived; none of their
results is used. The 7.8 wheel run and all P0/G-1 results are those of the final cycle above.

New checks in `tests/win32/test_host_win32.c` (the program runs 258 checks Checked and Release, 244 CheckedNoObs): the menu order with the wheel item
(and `n >= 12`); the item's text, check and default; chosen: flips, unchecks, hook told 0/1; with the item on, a
notch over a test map window (`pmap_test_map`, `pmap_hit` true) zooms +1 and is no event; with it off, +120 and
-240 give no zoom and no event, the zoom item 0x10E0 still works, and the partial sum (60 before the switch) is
dropped at the switch; `hw_set_wheel_zoom`; the item grayed and inert without the observer; the About title, the
licence note, the window title (`GetWindowTextW` on the hidden window) and the caption macros; the settings key
(absent, written `wheel_zoom=0`/`1`, read back, eight invalid values and an invalid value in a file read as absent,
other keys still read); civ64.exe's version information through `GetFileVersionInfoW`/`VerQueryValueW`; 25 checks of
`hw_place_decide` (first start centred with taskbars at the bottom, top and left, default larger than the work
area; remembered inside; straddling two monitors; partly off-screen right/below/left kept; entirely off-screen,
to the right, edge-touching only, bigger than the work area, too tall, no monitor; a negative-coordinate monitor
to the left of the primary: inside, straddling, beyond, ending at its edge, one pixel on it); and, on real hidden
windows, first start centred (also with `--window`), the remembered placement taken, entirely off-screen at the
work area's top-left, partly off-screen kept.

## Version check (after the build)

`GetFileVersionInfoW` (in the test, every `test.cmd`): FILEVERSION and PRODUCTVERSION 1,0,0,0, `VFT_APP`,
`VOS_NT_WINDOWS32`, `FileVersion` "1.0", `ProductVersion` "1.0", `ProductName` "Sid Meier's Civilization 64bit",
`FileDescription`, `OriginalFilename` "civ64.exe", translation 0x0409/1200: all passed. PowerShell on the Release
and the Checked `civ64.exe` (`(Get-Item civ64.exe).VersionInfo`), 2026-10-11 23:11 UTC:

```
FileVersion=1.0 ProductVersion=1.0 ProductName=Sid Meier's Civilization 64bit
FileDescription=Sid Meier's Civilization 64bit (civ64) OriginalFilename=civ64.exe InternalName=civ64
LegalCopyright=Copyright (c) 2026 Onur BUYUKCAGLAR FileVersionRaw=1.0.0.0 ProductVersionRaw=1.0.0.0
```

A scan of Release `civ64.exe` finds the UTF-16 text "About Sid Meier's Civilization 64bit v1.0" and no "x64 v1.0".

## Deviations and interpretations

1. **FileDescription** also carries "64bit" (the user named the title bars and the product name; the description
   would otherwise be the one string still saying x64).
2. **`present/` is touched** twice, both host-side: `pi_arrive_wheel_clear` (item 1) and the two `host_message`
   captions in `present/present.c`; `platform/w16/host.h` gains the caption macros. No core, rt, w16 behaviour or
   frame is affected.
3. **Accessors for tests:** `hw_about_title()` and `hw_about_license()` exist only so that the quiet-mode tests can
   pin the dialog's strings.
4. **Screen coordinates for the remembered placement.** `WINDOWPLACEMENT` uses workspace coordinates; the
   conversion matters only with a top or left taskbar (offset 0 here). A `window` value written by an earlier
   version under such a taskbar is read as screen coordinates once (a shift of the taskbar's size, then
   rewritten); the display check protects it. The workspace origin is taken as the primary monitor's work-area
   offset (documented behaviour; the offset was 0 on this machine, so the non-zero case rests on the synthetic
   `hw_place_decide` tests and the documentation, not on a run).
5. **`fit_scale`** now follows the primary monitor (the centring needs the size to fit it).
6. **A remembered rectangle on an on-screen secondary monitor, maximized,** maximizes on that monitor (as before);
   only a rectangle that went to the corner maximizes on the primary one.
7. **Without the observer** the wheel item is grayed, inert and its key not read: there is no zoom to switch.
8. The wheel item is the only new system-menu item; no separator was added around it.

## For the records

* **DESIGN.md 12.2:** the system menu's new item "Mouse wheel zooms the map" (0x10F0, checkable, default on,
  below Zoom in; grayed without the observer; off: the wheel does nothing over the map and still never reaches the
  game, I8; the chords, the zoom items, `--zoom` and the harness command are unaffected); the settings key
  `wheel_zoom` (1/0, invalid ignored); the host window's title bar text "Sid Meier's Civilization 64bit"; the
  About title "About Sid Meier's Civilization 64bit v1.0" (the `x64 v1.0` form of 20:15 was superseded at 22:00);
  the message-box captions (one constant, `HOST_CAPTION`); the start-up placement (centred in the primary work
  area on the first start, remembered in screen coordinates, "entirely off-screen" returns to the work area's
  top-left, maximized state kept); the version information 1.0 in `civ64.rc`.
* **RUNNING.md:** the item and the key `wheel_zoom` (1 on, 0 off, in `civ64.cfg`); civ64.exe's file version 1.0
  (Explorer Properties > Details); the first start centred, later starts at the remembered position, a window
  entirely off-screen (a monitor removed) comes back at the top-left of the primary screen's work area; the
  captions.
* **FIDELITY.md:** F108's About entry (title "About Sid Meier's Civilization 64bit v1.0", the licence note
  "(Sid Meier's Civilization 64bit)", the item count/position under the zoom items) and its window-title mention
  (title bar text "Sid Meier's Civilization 64bit", the user's request of 2026-10-11 22:00 UTC, replacing
  "Sid Meier's Civilization"); the captions of the port-level message boxes; **F111's update**: the remembered
  placement is in screen coordinates, the first start is centred, "entirely off-screen" returns to the primary
  work area's top-left (the user's rule), with the choices above; all **choices**/user requests, not original
  behaviour.
* **FEATURES.md / STATUS.md:** the requests above (2026-10-11 18:35, 20:15, 22:00, 22:05, 22:10, 22:15, 22:20) as
  done by LP, with the builds/tests of this record.
* **manual-checklist-ext.md (pending user checks):** (a) the system menu shows "Mouse wheel zooms the map",
  checked; unchecking it makes the wheel over the map do nothing, the chords and zoom items still work, the state
  is remembered after a restart (`wheel_zoom=0`), re-checking restores the wheel; (b) the About box title reads
  "About Sid Meier's Civilization 64bit v1.0" and the licence note names "Sid Meier's Civilization 64bit"; (c) the
  window's title bar reads "Sid Meier's Civilization 64bit"; (d) civ64.exe > Properties > Details shows file and
  product version 1.0 and the product name; (e) an error or message box (for example the DOS-files refusal) is
  captioned "Sid Meier's Civilization 64bit"; (f) first start (no `window` key in `civ64.cfg`) centred
  horizontally and vertically on the primary screen, also with a taskbar at the top or left not covering it;
  (g) the position and size are remembered on the next launch; (h) a window moved entirely off-screen (or a
  monitor removed), or a `window` value edited off-screen, returns at the top-left of the primary work area on
  the next start; a window only partly off-screen stays where it was left.

## Not verified

* No visible window and no UI check: the system menu was exercised through `WM_SYSCOMMAND` messages on a hidden
  window, the About box was never opened (strings pinned, binary scanned), no screenshot, no Explorer Properties
  page, no real message box shown.
* The real civ64.exe wiring of the key (`wheel_chosen`, `save_settings`, the start-up read) is compiled, not run;
  the key's read/write/ignore rules are tested through `civ64_cfg`.
* Placement: `hw_place_decide` is tested with synthetic monitors; the real-window cases ran on this machine's two
  adjacent 2560x1600 displays (primary work area 2560x1552 at the origin, taskbar offset 0). Not exercised: a
  non-zero workspace offset (top/left taskbar), a monitor with a different DPI, a monitor removed or added between
  runs, full screen combined with the new placement beyond the existing test, `WM_DPICHANGED` on a remembered
  window.
* No Asan run (deferred).

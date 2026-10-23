# Unit MAC1 (the macOS back end and the program) - record

## Result

`Civ64.app` (`build/macos/<arch>/<Variant>/Civ64.app`, made by `build-mac.sh`) runs civ64 on macOS: the recovered
core, the Borland-exact run-time and the Win16 emulation of `civ64.exe` 1.2.1, unchanged, over a new back end for
AppKit. The portable layers are the Windows build's, byte for byte in source; only the host is new:

* `platform/macos/host_macos.m` (with `host_macos.h`): every service of `platform/w16/host.h`, section by section
  after `platform/win32/host_win32.c`, and the services the program needs (the counterpart of `host_win32.h`);
* `macos/civ64_mac.m`: the program (the start of `win64/civ64_main.c` and the checks of `civ64_start.c`);
* `macos/mac_cfg.c`: `civ64.cfg` in `~/Library/Application Support/civ64` (the format and keys of `civ64_cfg.c`);
* `macos/mac_locate.c`: the lookup of the game's files (`civ64_locate.c`: `--data`, the ZIPs next to the
  application with the Windows ZIP's extraction and manifest, the CivWin / CivDos / MusicSfx folders, the remembered
  locations, the questions);
* `macos/Info.plist`: bundle `com.buyukcaglar.civ64`, name civ64, display name "Sid Meier's Civilization 64bit",
  version 1.2.1, macOS 13 or later, category strategy games;
* the bundle's resources: `civ64.icns` (from the user's `win64/civ64.ico`; its largest image is 128 px, so the larger
  sizes are scaled up) and `civ-winmenu-bg.png` (the user's single exception, as in civ64.exe).

## Design (macOS's way where the Win32 back end used Windows')

* **One thread**, as the Win32 back end: the game runs on the main thread; `pump()` takes AppKit's events
  (`nextEventMatchingMask`) at the game's polls, presents and waits, and `host_sleep_until_us` waits in it, so input
  ends a wait early. Modal boxes, the menu bar's tracking and a live resize run AppKit's loops on that thread.
* **PAU1's pause**: the menu bar's tracking (NSMenuDidBegin/EndTrackingNotification), the window's live resize and
  every box of the back end (messages, the exit warning, About, Locate) pause the game's clock and its sound. Moving a
  window does not block macOS's main thread, so it is no pause (Windows' move loop is).
* **The picture**: the content view is layer-backed; the buffer present/ draws has the view's size in device pixels
  (Retina: the backing scale), so present/'s layout, scale steps and CRT rows are the Win32 client's; each show
  hands a copy of it to the layer (nearest-neighbour, no scaling by Core Animation).
* **Input**: AppKit key codes map to the Windows virtual keys and set-1 scan codes of a US keyboard (the keypad as
  Windows' with Num Lock on); letters and digits take the virtual key of the character the current layout gives
  them, as Windows does; characters become Windows-1252 (Backspace 08, Ctrl+Backspace 7F, Return 0D, Ctrl+Return 0A);
  Option is Alt (Alt's characters are the unmodified ones, as WM_SYSCHAR), Control is Ctrl; the Command key belongs
  to macOS and never reaches the game. Modifier keys come from flagsChanged, Caps Lock as a press and release at each
  change. Everything goes through the arrival stage (`present/input.h`), so the chords (Alt+Enter,
  Ctrl+Shift+Backspace, the zoom chords, Alt+F4) and the hold rule are the Windows build's.
* **Full screen** is macOS's own (a separate space): Alt+Enter, the app menu's item, Ctrl+Cmd+F and the green button.
* **The app menu "civ64"** holds the Windows window menu's items in its layout (extension HM): About, Full Screen,
  Display, Map Zoom, Graphics, Alternative Music/Soundfx, then Hide, Hide Others, Show All and Quit (the Close
  command: Cmd+Q, the Dock's Quit and a logout ask first in a game, UX1). Chords are named in the items' titles but
  are no key equivalents, so the keys reach the arrival stage unchanged. A Window menu holds Minimize and Zoom.
* **Sound**: AVAudioPlayer, one sound at a time; an asynchronous one pauses and resumes with the pause; a synchronous
  one keeps the game waiting until it ends (PlaySoundW's SND_SYNC). The game's WAVs (8-bit PCM, 11,025 Hz) and the
  user's alternative set (16-bit, 24 kHz) are formats Core Audio decodes.
* **Cursors**: the game's cursor resources (1, 4, 8, 24 and 32 bits per pixel with their AND masks) become NSCursor
  images at the cursor factors in device pixels; the DOS pointer likewise; the torch over the Windows menus (CUR1).
* **Boxes**: NSAlert (light or dark as the system is). The game's file chooser is a box with a combo box listing the
  data directory (no system dialog, as on Windows); the DOS slot screen is unchanged.

## macOS differences (each recorded; none reaches the core)

1. Settings: `~/Library/Application Support/civ64/civ64.cfg`; the extracted Windows ZIP there (`CivWin`,
   `CivWin.manifest`).
2. The window placement is an NSWindow frame string (`window_mac`), not Windows' rectangle (`window`).
3. "Next to civ64.exe" is next to `Civ64.app`. An application started translocated (Gatekeeper's App Translocation:
   from a quarantined download it was not moved out of) sees nothing next to it; the remembered location or the
   question applies.
4. The VGA system font is the player's own `vgasys.fon` in the data directory (or next to the application), decision
   3 of BRIEF-mac.md. Without it civ64 starts and w16 uses civfonts.fon's first face for SYSTEM_FONT (F88, audit A8);
   the Windows build refuses to start without it.
5. A directory entry that is not a plain 8.3 ASCII name is not listed to the game (Windows lists its 8.3 alias).
6. A cursor pixel that Windows would invert is drawn black (macOS cursors cannot invert).
7. IDC_WAIT has no public macOS cursor: the arrow.
8. The single instance: a lock file (`civ64.lock`, flock) and `civ64.owner` in the settings folder; a second start
   shows the game's own refusal (or the running copy's folder) and brings the running civ64 to the front.
9. Full screen is a separate space with its animation; the windowed placement is kept for the return.

## Test aids (environment variables, read by nothing in a normal run)

* `CIV64_EVENTS`: a schedule of AppKit events posted into the application's own queue (keys, modifier keys as
  flagsChanged, clicks, moves, menu bar items, snapshots, quit); no permission is needed, and the events take the
  player's path.
* `CIV64_SNAPSHOT` / `CIV64_SNAPSHOT_AT`: the layer tree as Core Animation composites it, as a PNG.
* `CIV64_SETTINGS_DIR`: the settings folder of a test run (never the player's).

## Seen on this Mac (agent-observed: screen captures and layer snapshots; 2026-10-22)

* The Windows graphics' intro credits, the title menu after Space, a click on
  OK starting the creation story (BIRTH01), the "Load a Saved Game" box listing the saves.
* The DOS graphics' intro (4:3 bands) and title menu; Alt+Enter into and out of full screen (2560 x 1600).
* A start with no arguments and CivWin.zip, CivDos.zip and MusicSfx.zip next to a copy of the application: the 38
  files extracted with their manifest, no question asked, the game running.
* A saved game (CAE3540B.SAV) loaded through the DOS slot screen; in play, the game's menus in the macOS menu bar
  (MAC3) and Advisors > Trade Advisor chosen there opening the Trade Report.

## Bug found and fixed

* After Alt+Enter, AppKit dropped the Return key's release during the full-screen transition; the arrival stage kept
  Return reserved for the chord, so the next Alt+Enter was swallowed. The back end now records each key it delivered
  as pressed and, after a full-screen transition and when the window becomes key, releases the keys the keyboard no
  longer holds (`CGEventSourceKeyState`).

## Not yet covered

* Sound was not heard (no audio check from this session); the user's bulk check.
* The app menu's items, the exit warning, About, Locate DOS files, live resize, the cursors on screen, CRT, windowless
  play and the zoom on screen were not exercised one by one; the user's bulk check (the manual checklist's macOS
  section).
* The macOS back end has no headless test program of its own yet (the Win32 back end has `w32_test_*`).
* Universal binary, Developer ID signing and notarization: MAC4.

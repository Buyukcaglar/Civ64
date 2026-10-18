# Sid Meier's Civilization 64bit: User Guide

This guide is for players of **Sid Meier's Civilization 64bit** (`civ64.exe`, "civ64") version 1.0.
civ64 runs the original *Sid Meier's Civilization for Windows* (the 16-bit Windows 3.1 release of
1992) as a native 64-bit Windows program, on your own copy of the game's files, and can show the
game with the graphics of *Civilization for DOS* at any moment.

> civ64 was made with the assistance of Anthropic's Claude AI and is provided "as is", without
> warranty of any kind; you use it at your own risk, and no liability is accepted for any damage,
> data loss or other harm arising from its use (see the [repository README](../README.md)). Back up
> your game files and saved games before you use it.

Contents

1. [Requirements](#1-requirements)
2. [Installation](#2-installation)
3. [Where civ64 finds the game](#3-where-civ64-finds-the-game)
4. [Starting and ending](#4-starting-and-ending)
5. [The window, scaling and full screen](#5-the-window-scaling-and-full-screen)
6. [The window menu](#6-the-window-menu)
7. [The graphics profiles: Windows and DOS](#7-the-graphics-profiles-windows-and-dos)
8. [The map zoom](#8-the-map-zoom)
9. [Playing the game](#9-playing-the-game)
10. [Keys](#10-keys)
11. [Saves, settings and the files civ64 writes](#11-saves-settings-and-the-files-civ64-writes)
12. [The command line](#12-the-command-line)
13. [Troubleshooting](#13-troubleshooting)
14. [Known differences from Windows 3.1](#14-known-differences-from-windows-31)

## 1. Requirements

* **Windows 10 (version 1607 or later) or Windows 11, 64-bit.** civ64 uses the per-monitor DPI
  functions of these versions. It needs no installer, no administrator rights and no extra run-time
  libraries; it uses only the standard Windows system libraries.
* **Your own copy of Sid Meier's Civilization for Windows** (the Windows 3.1 release) with all of its
  files: `civ.exe`, the `.rsc` and `.wav` files, `civfonts.fon` and the other files of the
  installation. civ64 runs exactly one release of the game and checks it at every start:
  `civ.exe` must be 832,512 bytes with SHA-256
  `a66ec64020f10adb81613964f3d08a11ea278b6a5a060c8e49d1ea1fd3ba1788`.
* **Optional: your own copy of Civilization for DOS, version 475.01** (`CIV.EXE` of 305,030 bytes,
  SHA-256 `22de2748e3089793644c7e501e2a95b553010ddec34a7ff42f4395cf779c9c2a`), for the DOS graphics
  profile. civ64 checks every DOS file it uses. Without the DOS files civ64 plays normally with the
  Windows graphics.
* The VGA system font `Fonts\vgasys.fon` of your Windows directory. It is part of every Windows
  installation; civ64 reads it and never installs a font.

civ64 contains none of the original games' files or bytes. Everything it shows comes from your own
copies, read at run time.

## 2. Installation

1. Download `civ64.exe` from the [latest release](https://github.com/Buyukcaglar/Civ1/releases/latest)
   and put it in a folder of its own, for example `C:\Games\civ64`.
2. Give civ64 the Windows game, in one of these ways:
   * a ZIP file of your Civilization for Windows files next to `civ64.exe`, named `CivWin.zip`,
     `Civ-Win.zip` or `Civ_Win.zip`; or
   * a folder named `CivWin` next to `civ64.exe` holding a copy of the game's files; or
   * nothing: at the first start civ64 asks you to choose the game's `civ.exe` or ZIP file.
3. Optionally, give civ64 the DOS game for the DOS graphics: a `CivDos.zip` (or `Civ-Dos.zip`,
   `Civ_Dos.zip`) or a `CivDos` folder next to `civ64.exe`, or choose its location when civ64 asks.
4. Run `civ64.exe`.

Use a **copy** of the game: civ64 writes saves, preferences and the Hall of Fame into the game's
folder (section 11). If you prepare the folder by hand, copy every file of the installation into a
folder of its own and make the files writable.

To uninstall, delete `civ64.exe`, your game folder if you no longer want it, and the folder
`%LOCALAPPDATA%\civ64` (civ64's settings and, when you used a ZIP, the extracted game files and the
saves made there). civ64 writes nothing to the registry, `WIN.INI` or the clipboard.

## 3. Where civ64 finds the game

**The Windows game** (required). Without the `--data` option civ64 looks, in this order (names are
compared ignoring case):

1. A ZIP file next to `civ64.exe` named `CivWin.zip`, `Civ-Win.zip` or `Civ_Win.zip`. civ64 checks
   its files (those in the ZIP's folder that holds `civ.exe`) and extracts them to
   `%LOCALAPPDATA%\civ64\CivWin`, which becomes the game folder. If you later replace the ZIP with a
   changed one, the files you have not changed are updated, and your saves and changed files stay.
2. A folder `CivWin` next to `civ64.exe`.
3. The folder of `civ64.exe` itself, when it holds `civ.exe`.
4. The location you chose before (remembered in `civ64.cfg`).
5. Otherwise civ64 asks you to choose the game's `civ.exe` or a ZIP file of the game in the Windows
   file dialog. A valid choice is remembered.

**The DOS game** (optional). civ64 looks for `--dos-data`, then for `CivDos.zip`, `Civ-Dos.zip` or
`Civ_Dos.zip` next to `civ64.exe` (read in place, never extracted or changed), a `CivDos` folder, the
remembered location, and otherwise asks. You can answer the question with **not now** or **don't ask
again**. Later you can use the window menu's **Graphics > Locate DOS files…** (section 6); the
location you choose there is used from the next start. To be asked again after "don't ask again",
delete the line `dos_ask=never` from `%LOCALAPPDATA%\civ64\civ64.cfg`, or put a DOS ZIP or `CivDos`
folder next to `civ64.exe`.

A file or folder that is found but is not the supported version stops civ64 with a message that
names it. civ64 refuses to run in a folder whose path ends in `original\CIVWIN`, a safeguard that
keeps a reference installation from ever being changed.

## 4. Starting and ending

**Starting.** civ64 opens its window and plays the opening credits and the intro. Any key skips to
the title menu: **Start a New Game**, **Load a Saved Game**, **Play on EARTH**, **Customize World**,
**View Hall of Fame** and **Quit**. A new game shows the Birth of Civilization sequence while the
world is created (a key skips it as soon as the world is ready), then the setup screens: difficulty,
level of competition, your tribe and your name.

**One civ64 at a time.** civ64 runs once per Windows logon session. If you start it again while it
runs, it shows the original game's own message ("Sorry! Only one game at a time!"), and after **OK**
the running civ64 comes to the front, restored if it was minimized. If the running civ64 is another
copy of the program in another folder, civ64's own message names that folder and asks you to close
it first. A civ64 that has ended, normally or not, never blocks the next start.

**Ending.** The game's own **File > Quit** works as in the original. You can also close the window
with its close button, the window menu's **Close** or **Alt+F4**:

* before a game has begun (the intro, the title menu, the Birth and the setup screens) civ64 ends at
  once;
* during a game a warning box appears: "A game is in progress. If you exit now, any unsaved progress
  will be lost." **Cancel** is the default (Enter, Escape and the box's close button also cancel) and
  the game goes on unchanged; **Exit Anyway** ends civ64 at once.

An exit writes civ64's settings and the window's place and size, but never saves the game: save
first through the game's **File > Save Game** (Ctrl+S).

## 5. The window, scaling and full screen

**The first start** opens a 4:3 window, the largest whole multiple of 640x480 that fits your primary
screen, centred on it. After that civ64 remembers the window's position and size, and whether it
was maximized. A window that would open entirely off-screen (for example after a monitor was
removed) comes back at the top-left corner of the primary screen.

**Resizing.** The window can be resized from a 640x480 client area upwards, maximized and restored.
The picture is scaled into the window by the **Display** choices of the window menu:

* **Integer scaling (whole steps)**: the picture is the largest whole multiple that fits, with sharp
  pixels and black borders. This is the default.
* **Fit to window**: the picture is as large as the window allows, keeping its proportions, with the
  **Nearest-pixel filter** (pixels repeated) or the **Sharp filter** (only the edges between pixels
  blended).
* **Correct 320 × 200 to 4:3** (on by default): the DOS graphics' 320x200 screens are shown with the
  4:3 shape of a DOS monitor, so their pixels are a little taller than wide; off, they keep square
  pixels. The DOS Birth of Civilization always keeps square pixels. The Windows graphics' pictures
  always keep square pixels.

**The game screen fills the window.** The opening credits, intro, title menu, Birth and setup screens
keep the original's 640x480 picture, with black borders in a wider window. When a game begins (new,
loaded, EARTH or customized), the game's screen takes the window's size at the current scale, so the
map uses the whole window: a 1920x1080 window at twice the size gives a 960x540 game screen instead of
640x480. From then on the game screen follows the window: enlarge, shrink, maximize or restore it,
or switch to full screen, and the game screen grows or shrinks at once. The map window keeps the
right and bottom edges it touches; the World Map and Status windows stay where they are. The desktop
around the game's windows is black.

**Full screen.** **Alt+Enter**, or the window menu's **Full screen**, makes the window cover its
monitor; press it again to return to the window. civ64 remembers it.

**Light and dark mode.** The title bar, the window menu, the About box and civ64's own message boxes
follow Windows' light or dark app mode (Settings > Personalization > Colors) and change with it at
once.

## 6. The window menu

Open it by clicking the icon at the left of the title bar, or by right-clicking the title bar. (Alt,
Alt+Space and F10 belong to the game's own menus.) From the top:

| Item | What it does |
|---|---|
| **Restore**, **Move**, **Size**, **Minimize**, **Maximize** | Windows' own window commands. |
| **Full screen** (Alt+Enter) | Full screen on or off. |
| **Display** > **Integer scaling (whole steps)** / **Fit to window** | How the picture fills the window (section 5). |
| **Display** > **Nearest-pixel filter** / **Sharp filter** | The filter for **Fit to window** (gray under integer scaling, which never filters). |
| **Display** > **Correct 320 × 200 to 4:3** | The 4:3 shape of the DOS graphics' 320x200 screens (checked by default). |
| **Map zoom** > **Zoom out (half)** (Ctrl+Shift+Minus) | Map zoom level -1 (section 8). |
| **Map zoom** > **Normal zoom** (Ctrl+Shift+0, Home) | Map zoom level 0. |
| **Map zoom** > **Zoom in (double)** (Ctrl+Shift+Plus) | Map zoom level +1; gray while the map window is too small for it. |
| **Map zoom** > **Mouse wheel zooms map** | Checked by default; unchecked, the mouse wheel does nothing over the map. |
| **Graphics** > **Windows graphics** / **DOS graphics** | Choose the graphics profile (section 7); the radio mark shows the current one. |
| **Graphics** > **Switch graphics** (Ctrl+Shift+Backspace) | Switch to the other profile. |
| **Graphics** > **Locate DOS files…** | Choose the DOS game's folder or ZIP; it is checked, remembered and used from the next start. It reads **DOS files present**, gray, while the DOS files are in use. |
| **About…** | The program's name and version, credits, the repository link and the licence. |
| **Close** (Alt+F4) | Exit civ64 (section 4); the menu's default item. |

The marks are current whenever a menu opens. A letter underlined in an open menu chooses its item.

## 7. The graphics profiles: Windows and DOS

civ64 has two graphics profiles for the same game:

* **Windows graphics**: the game as the Windows 3.1 release shows it.
* **DOS graphics**: the game with the pictures, palettes, fonts, menus and mouse pointer of
  *Civilization for DOS* (version 475.01), read from your DOS files.

**Switching.** Press **Ctrl+Shift+Backspace**, or choose **Graphics > Switch graphics**, **Windows
graphics** or **DOS graphics** in the window menu, at any moment: during the intro, the title menu,
the Birth, the setup screens or a turn. The whole picture is redrawn at the next tick, and the window
keeps its size. Two quick presses cancel each other. The animation at the top of the
[repository README](../README.md) shows a switch during play.

**Switching never changes the game.** Your game, the computer players, the random numbers and your
saves are the same in both profiles. Only what you see changes, with two deliberate exceptions: with
the DOS graphics the game continues to the setup as soon as the DOS Birth story ends, and the science
advisor's recommendation box closes itself as the DOS game's does.

**civ64 remembers** the profile you last switched to and starts in it; without usable DOS files it
starts with the Windows graphics. If the DOS files are not usable, the first refused switch of a run
shows the reason and points to **Graphics > Locate DOS files…**; later refusals only beep.

**What the DOS graphics show.**

* The DOS intro, with the credits over the panorama, the logo reveal and the dissolve, at the DOS
  version's own pace. Both intros run on the same clock, so a switch during the intro continues at
  the same moment. The DOS title box has the DOS version's five items; **Quit** is in the Windows
  graphics or on the window's close button.
* The Birth of Civilization scenes with their colour cycling. When the DOS files are present, the
  Windows Birth follows the DOS Birth's pictures and captions, so a switch shows the same moment.
* The setup pages (difficulty, competition, tribe, the name boxes and the introduction text), the
  Customize World screens, the Hall of Fame, and the DOS game's own Load and Save screens.
* During play, the game keeps the Windows window layout, but the main map, the small World Map, the
  Status window and the unit panel, the map's palette animation, the menu bar and its menus (GAME,
  ORDERS, ADVISORS, WORLD, CIVILOPEDIA) and the message and question boxes are drawn the DOS way.
* The DOS screens of the game: the city screen, the city view and founding a city, the production
  list and the buy question, Find City, the advisors' reports, the World reports, the historian, the
  palace, the Civilopedia, discoveries, the newspaper, New Cabinet, the quiz, diplomatic audiences,
  the spaceship screens and the arrival, the power graph, the replay, the rating and the Hall of
  Fame entry at the end, the conqueror ending and the nuclear explosion.
* The DOS mouse pointer, drawn with whole-pixel blocks, never blurred.

**Windows-only items** keep their Windows form in the DOS profile: the file dialogs (switch to the
Windows graphics at the DOS Load or Save screen to use the Windows file chooser for other files), the
system message boxes, the About box and Help. The Windows menus EDIT, CITY and HELP exist only in the
Windows graphics.

**Input with the DOS graphics** follows the DOS game:

* In DOS menu boxes, **Up** and **Down** move the highlight (no wrap), a row's letter moves to the
  next row with that letter, **Return** or **Space** chooses, **Escape** closes. A click on a row
  chooses it; a press held over the rows moves the highlight and chooses at the release.
* In play with the map active, **Alt+G**, **Alt+O**, **Alt+A**, **Alt+W** and **Alt+C** open GAME,
  ORDERS, ADVISORS, WORLD and CIVILOPEDIA; **F1**..**F10** open the advisors and the World reports;
  **Alt+V** switches the sound; **Alt+Q** asks whether to quit.
* On the DOS city screen: **i**, **h**, **m** the panels, **v** the city view, **b** buy, **c**
  change production, **r** rename, **1**..**9** specialists; **Escape**, **Return** or EXIT close it.
* Reports, scenes and notes close with any key or a left click. **Alt+H** or the right button on a
  list item opens its Civilopedia page where the DOS game offers help.

## 8. The map zoom

The map zoom shows the main map window at **half size** (level -1), **normal** (level 0) or **double
size** (level +1), in both graphics profiles. Only the main map is zoomed; the small World Map, the
Status window and the reports are not. The zoom only changes what you see: the game's own view and
input stay the same.

| Way | What it does |
|---|---|
| **Ctrl+Shift+Plus**, **Ctrl+Shift+Minus** (main row or keypad) | One level in or out. |
| **Ctrl+Shift+0** or **Ctrl+Shift+Home** | Back to normal. |
| The mouse wheel over the map | One level per notch, forward zooms in; the point under the pointer stays under it. |
| The window menu's **Map zoom** submenu | The three levels (zooming about the map's centre) and **Mouse wheel zooms map**. |
| `--zoom -1`, `0` or `+1` on the command line | The level for this run. |

The plain `=`, `-`, `0` and Home keys still reach the game.

* **At +1 (double size)** the picture follows your active unit, and it centres on the square the
  game centres on (C, the next unit, a click on the small map, the scroll keys). +1 is refused while
  the map window is too small to show 3 x 3 squares at double size.
* **At -1 (half size)** you see the game's whole view surrounded by the rest of the world, drawn from
  the game's state with the game's own map rules. A **left click** on a surrounding square centres the
  game's map there, as a click on the small map would.
* The small World Map's rectangle outlines the area the map window shows at every level.

civ64 remembers the level and the wheel setting.

## 9. Playing the game

The game behaves as the original under Windows 3.1, with its own windows (the map, World Map and
Status windows) inside civ64's window. Some details:

* **The game's menus** are **File** (Save Game Ctrl+S, Tax Rate Ctrl+T, Luxuries Rate Ctrl+L, Find
  City Ctrl+F, Options, Revolution Ctrl+R, Retire, Quit Ctrl+Q), **Edit** (Small Map, Status, and the
  original's Undo, Cut, Copy, Paste and Clear, which do nothing in the original either), **Orders**
  (the unit orders, for example No Orders N, Clean Up Pollution K, Pillage P, Home City H, Jump to Unit
  J, Disband Unit D), **Advisors** (City Status Ctrl+1 to Science Advisor Ctrl+6), **World** (Wonders
  of the World Ctrl+7, Top Five Cities Ctrl+8, Civilization Score Ctrl+9, World Map Ctrl+0,
  Demographics Ctrl+D, Spaceships Ctrl+P), **Civilopedia**, **City** (on the city screen) and
  **Help**. **File > Options** holds Instant Advice, Auto Save, End Of Turn, Animations, Sound, Enemy
  Moves, Civilopedia Text and Palace.
* **Window layout.** At the start of a game the map, World Map and Status windows take the places
  saved in the game folder's `civ.prf`. When those do not fit the game screen, or there is no
  `civ.prf`, they take the default layout. A layout saved on a different screen size follows the new
  size. Delete `civ.prf` to get the default layout back (it also holds the Game Options).
* **Keyboard.** Typing follows your keyboard layout (characters are passed in Windows-1252;
  characters without a code there are dropped). The numeric keypad gives digits whatever your
  NumLock state. Alt and F10 open the game's menus.
* **Sound** comes from the game folder's `.wav` files; a missing file is silent.
* **Help** (the original's `.hlp` file) cannot be opened, because Windows 10 and 11 have no viewer
  for it: **Help > Game Help** shows a message that says so.
* **Timing.** By default (`classic`) the game is paced like the original; world generation and the
  computer players' turns run at full speed.
* A click in the black border around the picture is ignored.

## 10. Keys

civ64's own keys never reach the game, nor do the Ctrl, Shift or Alt presses held for them.

| Key | What it does |
|---|---|
| Ctrl+Shift+Backspace | Switch between the Windows and the DOS graphics |
| Alt+Enter | Full screen on or off |
| Ctrl+Shift+Plus / Ctrl+Shift+Minus | Map zoom in / out |
| Ctrl+Shift+0, Ctrl+Shift+Home | Normal map zoom |
| Mouse wheel over the map | Map zoom (when **Mouse wheel zooms map** is checked) |
| Alt+F4 | Exit civ64 (with the warning during a game) |

The game's own keys are those of the original: the menu accelerators of section 9, Alt or F10 for
the menus, the unit keys on the map, Enter at the end of a turn, and any key to skip the opening
credits or the Birth. With the DOS graphics the DOS keys of section 7 apply.

## 11. Saves, settings and the files civ64 writes

civ64 writes only to the game folder and to its own folder `%LOCALAPPDATA%\civ64`.

| File | Where | Written by |
|---|---|---|
| saved games (`*.SAV`) | the game folder | **File > Save Game** (the names you choose; the DOS Save screen's empty line saves as `CIVILn.SAV`) |
| `civ.prf` | the game folder | the game's preferences (Game Options and window places) |
| `famehall.civ` | the game folder | the Hall of Fame |
| `*.rep` | the game folder | the replay at the end of a game, under the name you give |
| `civ64.cfg` | `%LOCALAPPDATA%\civ64` | civ64's settings |
| `CivWin\` and `CivWin.manifest` | `%LOCALAPPDATA%\civ64` | the extracted game when you use a `CivWin.zip` |

When you use a `CivWin.zip`, the game folder is `%LOCALAPPDATA%\civ64\CivWin`, so your saves are
there.

**Save compatibility.** Saved games, the Hall of Fame, the preferences and the replays use the
original formats. Your saves from the original game load in civ64, and civ64's saves load in the
original game. The load and save dialogs, and the DOS graphics' Load and Save screens, list the game
folder.

**civ64.cfg** holds civ64's own choices: the game and DOS locations (`dos_data`, and `dos_ask=never`
after "don't ask again"), the window's place and size (`window=left,top,right,bottom` in screen
pixels), full screen, the scaling and filter choices, the 4:3 choice (`aspect_4_3`), the graphics
profile (`graphics=windows` or `dos`), the map zoom level (`zoom=-1`, `0` or `1`), the wheel setting
(`wheel_zoom=1` or `0`) and the screen size the window layout was saved on (`layout_screen`). Options
given on the command line apply to that run only and are not written. civ64 reads no registry key,
INI file or environment variable; only the Windows file dialog keeps its own list of recent folders.

## 12. The command line

```
civ64.exe [--data <dir>] [--dos-data <dir|zip|none>] [--graphics windows|dos]
          [--zoom default|-1|0|+1] [--fullscreen] [--window <W>x<H>]
          [--scale auto|1..8] [--scale-mode integer|fit] [--filter nearest|sharp]
          [--aspect square|4:3] [--timing classic|host]
```

| Option | Meaning |
|---|---|
| `--data <dir>` | The game folder, with no search. Its `civ.exe` must be the supported release. |
| `--dos-data <dir\|zip\|none>` | The DOS game's folder or ZIP; `none`: not used and not asked for. |
| `--graphics windows\|dos` | The profile to start in (not remembered). `dos` without usable DOS files stops civ64 with a message. |
| `--zoom default\|-1\|0\|+1` | The map zoom level for this run. |
| `--fullscreen` | Start in full screen. |
| `--window <W>x<H>` | The window's first client size (at least 640x480), centred. |
| `--scale auto\|1..8` | The window's first size as a multiple of 640x480; `auto` (the default) uses the remembered size or the largest multiple that fits. |
| `--scale-mode integer\|fit` | Integer scaling or fit to the window. |
| `--filter nearest\|sharp` | The filter for `fit`. |
| `--aspect square\|4:3` | The shape of 320x200 screens for this run. |
| `--timing classic\|host` | `classic` (the default) paces the game like the original with fixed costs for its internal waits; `host` follows the PC's real clock. In both, world generation and the computer players' turns run at full speed. |

Two further options, `--dump-frames <dir>` and `--dump-presented <dir>`, write every picture to a
folder as BMP files; they are meant for checks and write thousands of files. `--multi-instance` is
an option for automated tests.

## 13. Troubleshooting

| Problem | What to do |
|---|---|
| civ64 asks where the game is at every start | Choose the game's `civ.exe` or ZIP; civ64 remembers a valid choice. Or put `CivWin.zip` or a `CivWin` folder next to `civ64.exe`. |
| A message says `civ.exe` is different or missing | civ64 runs only the supported release (section 1). Check the file's size (832,512 bytes) in Explorer. |
| A message names a DOS file | The DOS files are not version 475.01 or a file is damaged. Use a complete copy of that version, or start with `--dos-data none`. |
| Ctrl+Shift+Backspace only beeps | The DOS files are not available in this run. Use **Graphics > Locate DOS files…** and restart civ64. |
| "Sorry! Only one game at a time!" | civ64 is already running; after OK it comes to the front. |
| The game's windows are placed oddly | Delete `civ.prf` in the game folder for the default layout (it also resets the Game Options). |
| The window opens in an odd place or size | Delete the `window` line of `%LOCALAPPDATA%\civ64\civ64.cfg`, or start once with `--scale auto`. |
| The mouse wheel does nothing over the map | Check **Map zoom > Mouse wheel zooms map** in the window menu. |
| Zoom in is gray | The map window is too small for double size; make it larger. |
| Help shows a message instead of the help file | Expected: Windows 10 and 11 cannot open the original `.hlp` file. |
| A message "General protection fault ..." and civ64 ends | An error of the original program that Windows 3.1 would also have stopped on; civ64 ends with exit code 3. Load your last save. |

civ64's own messages are captioned "Sid Meier's Civilization 64bit". Port-level failures (a bad
option, a missing or wrong `civ.exe`, a folder that cannot be read) show a message and end civ64
with exit code 2; running out of memory ends it with code 4. The original game's own error messages
are shown unchanged.

## 14. Known differences from Windows 3.1

* **Help:** the original's `.hlp` help file cannot be opened on Windows 10 and 11.
* **Speed:** the game is not paced by the speed of a 1992 PC; `classic` timing uses fixed costs for
  the game's internal waits.
* **Window details:** Windows 3.1's frames, menus and controls are redrawn by civ64, so small visual
  differences are possible.
* **Same seed:** civ64 seeds its random numbers from its start time, so a game cannot be replayed in
  step with the original. The same seed plays the same game only at the same game screen size.
* **One game at a time:** as in the original, with the running civ64 brought to the front.
* The complete list of every place where civ64 does not or cannot reproduce the original exactly is
  the fidelity register, [FIDELITY.md](FIDELITY.md).

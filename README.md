# Sid Meier's Civilization 64bit (civ64)

<table>
  <tr>
    <td width="50%"><img src="docs/screenshots/Civ64-01-TitleMenu-Windows.png" alt="The title menu with the Windows graphics"></td>
    <td width="50%"><img src="docs/screenshots/Civ64-02-TitleMenu-DOS.png" alt="The title menu with the DOS graphics"></td>
  </tr>
  <tr>
    <td align="center"><sub>Title menu, Windows graphics</sub></td>
    <td align="center"><sub>Title menu, DOS graphics</sub></td>
  </tr>
  <tr>
    <td width="50%"><img src="docs/screenshots/Civ64-03-GameSetup-Windows.png" alt="The difficulty page of the game setup with the Windows graphics"></td>
    <td width="50%"><img src="docs/screenshots/Civ64-04-GameSetup-DOS.png" alt="The difficulty page of the game setup with the DOS graphics"></td>
  </tr>
  <tr>
    <td align="center"><sub>Game setup, Windows graphics</sub></td>
    <td align="center"><sub>Game setup, DOS graphics</sub></td>
  </tr>
  <tr>
    <td width="50%"><img src="docs/screenshots/Civ64-05-GamePlay-Windows.png" alt="The first turn of a game with the Windows graphics"></td>
    <td width="50%"><img src="docs/screenshots/Civ64-06-GamePlay-DOS.png" alt="The first turn of a game with the DOS graphics"></td>
  </tr>
  <tr>
    <td align="center"><sub>Game play, Windows graphics</sub></td>
    <td align="center"><sub>Game play, DOS graphics</sub></td>
  </tr>
  <tr>
    <td width="50%"><img src="docs/screenshots/Civ64-07-WindowlessPlay-Windows.png" alt="Windowless play with the Windows graphics"></td>
    <td width="50%"><img src="docs/screenshots/Civ64-08-WindowlessPlay-DOS.png" alt="Windowless play with the DOS graphics"></td>
  </tr>
  <tr>
    <td align="center"><sub>Windowless play, Windows graphics</sub></td>
    <td align="center"><sub>Windowless play, DOS graphics</sub></td>
  </tr>
</table>

<p align="center">
  <img src="docs/screenshots/OnTheFlyGraphicsSwitch.gif" width="100%" alt="Switching between the Windows and DOS graphics while playing">
  <br>
  <sub><b>On-the-fly graphics switch:</b> press <b>Ctrl+Shift+Backspace</b>, or use the window menu's
  <b>Graphics</b> submenu, at any moment, and the same game continues with the other graphics.</sub>
</p>

> **AI assistance and disclaimer of liability.** This project was made with the assistance of
> Anthropic's Claude AI. The reverse engineering, the program, the tests and this documentation were
> produced with Claude under my direction, and I tested the results myself. Because the work was
> produced with AI assistance, it may contain errors that neither the AI nor I have found.
> **Therefore the software and the documentation are provided "as is", without warranty of any
> kind, express or implied. You use them entirely at your own risk, and I accept no liability for
> any damage, data loss or other harm arising from their use.** Back up your game files and saved
> games before you use civ64.
>
> **Trademarks and affiliation.** Sid Meier's Civilization, its program, art, sound and data belong
> to their owners. This is a fan project. It is not affiliated with or endorsed by Firaxis Games,
> 2K, Take-Two Interactive or MicroProse. None of the game's files are included here or in the
> release: you need your own copy of the game to play.

**Sid Meier's Civilization 64bit** (`civ64.exe`, "civ64") runs the original 1992 *Sid Meier's
Civilization for Windows*, the 16-bit Windows 3.1 release, as a native 64-bit Windows program. It
needs no DOSBox, no winevdm/OTVDM and no virtual machine. It plays the whole original game, from the
opening credits to the end games, on your own copy of the game's files, and it can switch to the
graphics of *Civilization for DOS* and back at any moment.

## Quick start

**Requirements**

* Windows 10 (version 1607 or later) or Windows 11, 64-bit. No installer, no administrator rights,
  no extra run-time libraries.
* **Your own copy of Sid Meier's Civilization for Windows** (the Windows 3.1 release), with all of
  its files: `civ.exe`, the `.rsc` and `.wav` files, `civfonts.fon` and the others. civ64 accepts
  exactly one release: `civ.exe` of 832,512 bytes with SHA-256
  `a66ec64020f10adb81613964f3d08a11ea278b6a5a060c8e49d1ea1fd3ba1788`.
* **Optional, for the DOS graphics:** your own copy of *Civilization for DOS*, version 475.01
  (`CIV.EXE` of 305,030 bytes). civ64 checks every DOS file it uses. Without it civ64 plays normally
  with the Windows graphics.

**First run**

1. Download `civ64.exe` from the [latest release](https://github.com/Buyukcaglar/Civ64/releases/latest)
   into a folder of its own.
2. Next to it, put a `CivWin` folder holding a copy of your Civilization for Windows files, or a ZIP
   of them named `CivWin.zip` (also `Civ-Win.zip` or `Civ_Win.zip`). For the DOS graphics, add a
   `CivDos` folder or `CivDos.zip` (also `Civ-Dos.zip` or `Civ_Dos.zip`).
3. Run `civ64.exe`. If it finds no game files, it asks you to locate the game's `civ.exe` or ZIP file
   and remembers your choice.

**Optional extras (new in 1.1)**

* **Windowless play:** window menu > **Display** > **Windowless play** shows the menu bar, the map,
  the World Map and the Status panel as one picture, like the DOS game's screen, without window
  frames. It works with both graphics and can be switched at any time; since 1.2 the picture fills the
  whole window, without a black border.
* **4:3 DOS gameplay:** **Display** > **4:3 aspect ratio for 320 x 200 DOS gameplay** gives the whole
  game with the DOS graphics the 4:3 shape of a DOS monitor (the intro screens have their own item).
* **CRT scanlines:** **Display** > **CRT scanlines** adds the dark lines of a CRT monitor, with sharp
  pixels and no slowdown.
* **Your own music and sound effects:** put a `MusicSfx` folder or a `MusicSfx.zip` next to
  `civ64.exe`, holding WAV files named like the game's own (`OPENING.WAV`, `CANNON.WAV`, ... any of
  its 24 sound files). Each file you supply is played instead of the game's file of that name; the
  others stay the game's own. **No music or sound files are included: you supply your own.** The
  window menu's **Alternative music/soundfx** turns them off and on.

All of these are remembered between runs; the [User Guide](docs/USER-GUIDE.md) has the details.

**Main keys**

| Key or action | What it does |
|---|---|
| Ctrl+Shift+Backspace | Switch between the Windows and the DOS graphics |
| Alt+Enter | Full screen on or off |
| Ctrl+Shift+Plus, Ctrl+Shift+Minus | Map zoom in (double size) and out (half size) |
| Ctrl+Shift+0 or Ctrl+Shift+Home | Normal map zoom |
| Mouse wheel over the map | Map zoom around the pointer |
| Click the icon at the left of the title bar, or right-click the title bar | The window menu: Full screen, Display (windowless play, scaling, filter, CRT scanlines, 4:3), Map zoom, Graphics, Alternative music/soundfx, About |
| Any key during the opening credits | Skip to the title menu |
| Alt+F4 or the window's close button | Exit (during a game civ64 asks first; save through the game's File menu) |

The full **[User Guide](docs/USER-GUIDE.md)** covers installation, every menu and key, both
graphics, the map zoom, the window and full screen, saves, settings, the command line and
troubleshooting.

## What this project is

civ64 is a faithful port, not a remake. The original `civ.exe`, a 16-bit Borland C++ program, was
reverse-engineered from its machine code: all 1,065 of its functions were recovered as readable C
(about 67,000 lines). The 699 functions that can actually run were translated into portable C
(about 124,000 lines), and every one of them was compared instruction by instruction with the
original machine code (137,887 instructions, 11 review rounds). The Borland run-time library was
replaced by an exact re-implementation, and the Windows 3.1 environment the game expects (windows,
dialogs, controls, 256-colour palettes, fonts, timers and 16-bit memory) is re-created inside civ64.
The rules, the computer players, the map generator, the random-number generator, the save files and
the screens are the original's, its bugs included.

Additions only change what you see, never what happens in the game: a resizable window and full
screen, scaling with sharp or smooth pixels, a game screen that grows with the window, a three-level
map zoom, light and dark title bars, and the DOS graphics profile, which shows the DOS version's
pictures, palettes, fonts, menus and screens for the same running game. Save files keep the original
format: civ64 loads saves of the original game, and the original game loads civ64's saves.

### New in version 1.2

* **Windowless play fills the whole window** (Windows and DOS graphics): no black border around the
  picture any more; the game's map window grows by the removed frames and scroll bars, so the map
  shows a little more land.
* The program's version information and its About box say 1.2.

### New in version 1.1

* **Windowless play** (Windows and DOS graphics): the game's menu bar, map, World Map and Status
  panel form one frameless picture, laid out like the DOS game's screen; dialogs and menus float
  over it.
* **4:3 for the DOS gameplay**: the whole DOS-graphics game, not only the intro screens, can take the
  4:3 shape of a DOS monitor.
* **CRT scanlines**: an optional CRT scanline effect modelled on DOSBox Pure Unleashed's CRT filter,
  as sharp as the picture without it.
* **Alternative music and sound effects**: your own WAV files from a `MusicSfx` folder or
  `MusicSfx.zip` replace the game's sounds of the same names (none are included).
* **Fix:** with the DOS graphics, the science advisor's recommendation now stands on the Status
  window, as in the DOS game, instead of in a second box.

### Recovery coverage

![Recovery coverage of civ.exe: summary figures, where every code byte went, every function in address order and the recovery stages](docs/recovery-coverage.svg)

Every function of `civ.exe` has been recovered to C, and all 699 live game functions are ported into
civ64: **91.5% of the executable's code bytes**. The other 8.5% is the Borland C run-time library
(3.6%, replaced by civ64's own run-time layer) and dead code that nothing can call (4.9%). Details,
evidence and caveats: [docs/recovery-coverage.md](docs/recovery-coverage.md).

## What this repository holds, and why

| | |
|---|---|
| **Here now** | This README, the [User Guide](docs/USER-GUIDE.md) and the complete project documentation in [docs/](docs/README.md): the design, the fidelity register, the feature list, the DOS-profile tables, the phase and unit records, the reviews, the audits, the measured test results and the screenshots. The program itself is attached to each release as `civ64.exe`: the [latest release](https://github.com/Buyukcaglar/Civ64/releases/latest) is [v1.1](https://github.com/Buyukcaglar/Civ64/releases/tag/v1.1); the first was [v1.0](https://github.com/Buyukcaglar/Civ64/releases/tag/v1.0). |
| **Later** | The independently written code of civ64: the Windows 3.1 emulation layer and the Windows host, the run-time library replacement, the presentation (scaling, map zoom, the DOS graphics profile), the tests and the build scripts. It will be published here as the last task of the project. On its own it does not build a playable game. |
| **Not published** | The recovered C of `civ.exe` and the game core translated from it, the disassembly listings, the original game's string inventory, and every file of the original games. |

The recovered C and the core translated from it are readings of the copyrighted original program,
so they are not published. The released `civ64.exe` contains none of the original game's files or
bytes: it reads your own copy at run time and checks that it is the exact supported release. The
documentation describes the work in full; where a record quoted program code, the public copy
condenses that passage into a description ([audit summary in docs/README.md](docs/README.md#9-how-the-public-copy-was-prepared)).

## Documentation

* [docs/USER-GUIDE.md](docs/USER-GUIDE.md): how to install, run and play civ64.
* [docs/README.md](docs/README.md): the whole work from start to finish (phases, methodology,
  tests, findings and measured data) with an index of every document.

## Licence

civ64's About box carries its licence: the MIT licence, Copyright (c) 2026 Onur BUYUKCAGLAR, for
the port's own code. It does not cover Sid Meier's Civilization, its program or its data, which
belong to their owners.

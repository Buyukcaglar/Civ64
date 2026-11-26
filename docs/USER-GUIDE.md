# Sid Meier's Civilization 64bit: User Guide

This guide is for players of **Sid Meier's Civilization 64bit** ("civ64") version 1.3.4: `civ64.exe` for
Windows (`Civ64-Win7.exe` on Windows 7). civ64 runs the original *Sid Meier's Civilization for Windows* (the
16-bit Windows 3.1 release of 1992) as a native 64-bit program, on your own copy of the game's files, and
can show the same running game with the graphics of *Civilization for DOS* and of the Amiga, Atari ST,
PC-98 and SNES editions, and play their music and sound effects, at any moment.

Sections 1 to 14 describe the Windows program 1.3.4. The macOS application `Civ64.app` is at version 1.3.4 too, with
the same Options dialog, graphics styles, sounds, mods, filters, Save States, `units.ini`, numeric keypad and lower CPU
use; **on a Mac, also read
[section 15](#15-civ64-for-macos)**: it gives the Mac's download, folders, menus and keys, and its differences.

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
6. [The window menu and the Options dialog](#6-the-window-menu-and-the-options-dialog)
7. [The graphics styles](#7-the-graphics-styles)
8. [The map zoom](#8-the-map-zoom)
9. [Playing the game](#9-playing-the-game)
10. [Keys](#10-keys)
11. [Saves, settings and the files civ64 writes](#11-saves-settings-and-the-files-civ64-writes)
12. [The command line](#12-the-command-line)
13. [Troubleshooting](#13-troubleshooting)
14. [Known differences from Windows 3.1](#14-known-differences-from-windows-31)
15. [civ64 for macOS](#15-civ64-for-macos)

## 1. Requirements

* **Windows 10 (version 1607 or later) or Windows 11, 64-bit.** civ64 uses the per-monitor DPI
  functions of these versions. It needs no installer, no administrator rights and no extra run-time
  libraries; it uses only the standard Windows system libraries.
* **On Windows 7 SP1, 64-bit: `Civ64-Win7.exe`** (in the release since v1.2.4). It is the same
  program and version, built so that it also runs on Windows 7: where Windows 7 lacks the per-monitor
  DPI functions it uses the system DPI, and where it lacks the high-resolution timer it uses the
  system timer at 1 ms. It runs on Windows 8, 8.1, 10 and 11 too, but there use `civ64.exe`. It has
  not yet been run on Windows 7 itself; it passed a check that it uses no function Windows 7 lacks.
  Everything in this guide applies to it, with `Civ64-Win7.exe` in place of `civ64.exe`; its settings
  are the same as civ64.exe's.
* **Your own copy of Sid Meier's Civilization for Windows** (the Windows 3.1 release) with all of its
  files: `civ.exe`, the `.rsc` and `.wav` files, `civfonts.fon` and the other files of the
  installation. civ64 runs exactly one release of the game and checks it at every start:
  `civ.exe` must be 832,512 bytes with SHA-256
  `a66ec64020f10adb81613964f3d08a11ea278b6a5a060c8e49d1ea1fd3ba1788`.
* **Optional: your own copy of Civilization for DOS, version 475.05** (`CIV.EXE` of 305,030 bytes,
  SHA-256 `22de2748e3089793644c7e501e2a95b553010ddec34a7ff42f4395cf779c9c2a`), for the DOS VGA, DOS EGA
  and PC-98 graphics and the DOS game's sounds. civ64 checks every DOS file it uses. Without the DOS files
  civ64 plays normally with the Windows graphics.
* **Optional: your own copies of the other editions' files**, each for that edition's graphics and
  sounds (section 3): the Amiga edition, the Atari ST edition, the NEC PC-98 edition (version 475.02, with
  the DOS files above for its graphics), the SNES edition (the USA cartridge image), and for the DOS
  game's Roland MT-32 music the Roland MT-32's control ROM 1.07 and PCM ROM.
* The VGA system font `Fonts\vgasys.fon` of your Windows directory. It is part of every Windows
  installation; civ64 reads it and never installs a font.

civ64 contains none of the original games' files or bytes, no MT-32 ROM, no music and no graphics mod or
graphics pack. Everything it shows and plays comes from your own copies: civ64 copies the
files it needs into its `GameData` folder (section 2) and reads them from there at run time.

## 2. Installation

1. Download `Civ64-1.3.4-Windows.zip` from the
   [latest release](https://github.com/Buyukcaglar/Civ64/releases/latest) and unpack it into a folder of its
   own that you can write to, for example `C:\Games\civ64` (not under `C:\Program Files`). On Windows 7,
   download `Civ64-1.3.4-Win7.zip` instead (section 1). Since 1.3.1 the download is a ZIP file: it holds
   `civ64.exe` (or `Civ64-Win7.exe`), `units.ini` and `README-units.txt`, the optional unit rules of
   section 9; `units.ini` as shipped holds the original values, and civ64 runs the same without it.
2. Run `civ64.exe`. At the first start it asks one question only, and only when it has no Windows game
   yet: choose the game's `civ.exe` (in your Civilization for Windows folder) or a ZIP file of the game.
   Cancel ends civ64.
3. civ64 checks the choice and **copies the files it needs into the folder `GameData` next to
   `civ64.exe`** as `Civ-Windows.zip` (section 3), and from then on uses them from there. It does not ask
   again.
4. Everything else you set up yourself on the Options dialog (section 6), when you want it: the DOS files
   and the other editions' files (a card's **Choose files** on the Graphics page), your own music and
   sound effects (**Custom audio files** on the Audio page) and graphics mods (**Add mod…**). civ64 copies
   each into `GameData` in the same way and uses it from the next start. Cancel in a file dialog ends the
   choice with nothing changed; a file that is refused gives one message saying why.

**The game data lives in `GameData`.** Every edition's files, your own sounds and your graphics mods are
used from the archives in `GameData`, never from where you chose them. Your own files and folders are
only read, never changed, moved or deleted; after the copy you may move or delete them. The copies take
a few MB per edition (your own music, and some Modern-style packs, can take much more). You can also make
the archives yourself and put them into `GameData` (the table in section 3); civ64 checks them at every
start. Everything the game writes goes to a `Save` folder next to `civ64.exe` (section 11).

**Upgrading from 1.3, 1.3.1, 1.3.2 or 1.3.3.** Replace `civ64.exe` with the one in the ZIP file; your settings, `GameData` and
`Save` folders stay.

**Upgrading from 1.2.5 or earlier.** Replace `civ64.exe`; your settings in `%LOCALAPPDATA%\civ64` stay.

* A game or DOS location or a music source you chose in an earlier version (at its question or with
  **Locate DOS files…**) is copied into `GameData` at the first start of 1.3, without a question, and then
  used from there. If it is no longer there, civ64 uses the archive in `GameData` when there is one;
  otherwise the Windows game is asked for at the start, and the DOS files or the sounds stay unavailable
  until you choose them on the Options dialog.
* Version 1.3 no longer looks for the earlier names next to `civ64.exe` (`CivWin.zip`, `Civ-Win.zip`,
  `Civ_Win.zip`, `CivDos.zip`, `Civ-Dos.zip`, `Civ_Dos.zip`, `MusicSfx.zip` and the `CivWin`, `CivDos` and
  `MusicSfx` folders), and no longer extracts the Windows game to `%LOCALAPPDATA%\civ64\CivWin`. When civ64
  asks for the Windows game, choose your old `CivWin.zip` (or `civ.exe`); choose the DOS files and your sounds
  on the Options dialog. civ64 copies them into `GameData`.
* If you played from a `CivWin.zip`, your saves are in `%LOCALAPPDATA%\civ64\CivWin`: copy the `.SAV` files
  (and, if you like, `famehall.civ` and `civ.prf`) into the new `Save` folder; civ64 neither reads nor
  deletes that old folder.

To uninstall, delete civ64's folder (with `GameData` and `Save`, after keeping the saves you want), and
the folder `%LOCALAPPDATA%\civ64` (civ64's settings, and the saves when the `Save` folder next to
`civ64.exe` could not be written). civ64 writes nothing to the registry, `WIN.INI` or the clipboard.

## 3. Where civ64 finds the game

civ64 uses each edition's files from its archive in the `GameData` folder next to `civ64.exe`. The
archive holds only the files civ64 reads from that edition, at its root, and is read in memory, never
extracted. Names are compared ignoring case.

| Archive in `GameData` | Made from (your own copy) | Used for |
|---|---|---|
| `Civ-Windows.zip` | Civilization for Windows: its folder (choose `civ.exe`) or a ZIP of it | the game (required) |
| `Civ-DOS.zip` | Civilization for DOS 475.05, all of its files unchanged: its folder (choose `CIV.EXE`) or a ZIP | the DOS VGA, DOS EGA and PC-98 graphics, the DOS sounds |
| `Civ-Amiga.zip` | the Amiga edition's files, extracted from its disks: the folder with its `game` file, or a ZIP | the Amiga graphics and sounds |
| `Civ-AtariST.zip` | the Atari ST edition's files, extracted from its disks: the folder with its `GAME.PRG`, or a ZIP | the Atari ST graphics and sounds |
| `Civ-PC98.zip` | the NEC PC-98 edition's files (version 475.02), extracted from its disks: their folder (choose `YSOUND.CVL`) or a ZIP | the PC-98 graphics (with `Civ-DOS.zip`) and sounds; `YSOUND.CVL` alone gives the sounds only |
| `Civ-SNES.zip` | the SNES edition's USA cartridge image (`.sfc` or `.smc`; a copier header is removed), or a ZIP holding it | the SNES graphics and sounds |
| `CustomMusicSfx.zip` | your own WAV files (below): a WAV file of their folder, or a ZIP | the Custom sound source |
| `MT32-ROMs.zip` | **you make it:** the Roland MT-32's control ROM 1.07 as `MT32_CONTROL.ROM` and its PCM ROM as `MT32_PCM.ROM` | the DOS game's Roland MT-32 music |
| `Civ-Modern.zip`, `Mod-<name>.zip` | graphics mods and packs, added with **Add mod…** (section 7) | the Custom graphics style |

**How a copy is made.** Wherever you choose an edition's files (the first start's question for the Windows game, a card's
**Choose files** on the Options dialog, **Custom audio files**, **Add mod…**), civ64 first checks them
(the Windows `civ.exe`, every DOS file, the PC-98 sound driver and the SNES image against the supported
releases; the Amiga and Atari ST files by opening them). It then writes the archive to a temporary file in
`GameData`, reads it back and compares it with your files, and only then gives it its name. If anything
fails (`GameData` cannot be written, the disk is full, the copy does not match), nothing is changed, the
earlier archive stays, and a message says why. When `GameData` already holds the same files, nothing is
copied. A different choice for the same edition replaces its archive. A ZIP already inside `GameData`
under the edition's name is used where it is. A copy made during a game is used from the next start.

**The Windows game** (required). Without the `--data` option civ64 uses `GameData\Civ-Windows.zip`, or
`civ.exe` in the folder of `civ64.exe` itself (when you put `civ64.exe` into the game's folder; that
folder is read where it is). Otherwise it asks you to choose the game's `civ.exe` or a ZIP file of the
game, and copies it into `GameData`.

**The DOS game** (optional). Without `--dos-data` civ64 uses `GameData\Civ-DOS.zip`. civ64 never asks for
it: choose the DOS files on the Options dialog's Graphics page (the DOS VGA card's **Choose files**,
section 6); they are copied into `GameData` and used from the next start.

A file or folder that is found but is not the supported version is refused with a message that names
it. Every DOS file civ64 uses is checked, not only `CIV.EXE`: a copy with one file changed or missing (a
mod, or a file of another release next to a patched `CIV.EXE`) is named, file and folder or ZIP, and
refused. A wrong `CIV.EXE` says "Version 475.05 is required." (the game's own `INTRO.TXT` may still read
"Version 475.01"; the `CIV.EXE` is what counts). civ64 refuses to run in a folder whose path ends in
`original\CIVWIN`, a safeguard that keeps a reference installation from ever being changed.

**The other editions** (optional). The Amiga, Atari ST, PC-98 and SNES files are used from their archives
in `GameData`; the MT-32 ROMs only from `GameData\MT32-ROMs.zip` (both checked by size and SHA-256).
civ64 never asks for them at the start: a style or sound source whose files are not loaded is simply not
available, and its card on the Options dialog shows **Choose files**.

**Your own music and sound effects** (optional). civ64 can play your own WAV files instead of the
Windows game's 24 sound files, which are `AIRNUKE.WAV`, `ALEX.WAV`, `CANNON.WAV`, `CEAS.WAV`, `ELIZ.WAV`,
`FRED.WAV`, `GAND.WAV`, `GENG.WAV`, `HAMA.WAV`, `LINC.WAV`, `LOSE2.WAV`, `MAO.WAV`, `MONT.WAV`,
`NAPO.WAV`, `OPENING.WAV`, `RAMS.WAV`, `SHAK.WAV`, `STAL.WAV`, `S_BEEP.WAV`, `S_LAND.WAV`, `S_NUKE.WAV`,
`THEY_DIE.WAV`, `WE_DIE.WAV` and `WINTUNE.WAV`. **civ64 includes no music or sound files: you supply your
own.**

1. Put WAV files with any of those 24 names (upper or lower case) in a folder, at its top level, or in a
   ZIP file, in any one folder of it. You need not supply all 24.
2. Choose them on the Options dialog's Audio page (**Custom audio files**, **Choose file…**: a WAV file
   of the folder, or the ZIP). civ64 copies the valid files into
   `GameData` as `CustomMusicSfx.zip`.
3. Choose **Custom** on the Audio page. Each valid file you supplied is played instead of the game's
   file of that name; every other sound is the Windows game's own. New files take effect at the next
   start.

civ64 never asks for your sounds at the start.

The command-line options `--data`, `--dos-data`, `--amiga-data`, `--atari-data` and `--music-sfx`
(section 12) are the exception: they read the folder or ZIP you give where it is, for that run only, and
copy nothing.

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
The picture is scaled into the window by the **Scaling** choices of the Options dialog's Display page
(section 6):

* **Integer scaling**: the picture is the largest whole multiple that fits, with sharp pixels and black
  borders. This is the default.
* **Fit to window**: the picture is as large as the window allows, keeping its proportions.
* The **Filter** list (since 1.3.1; before, two choices that applied to Fit to window only) says how the
  art's pixels are drawn when they are larger than the screen's:
  * **Sharp pixels** (the default; "Nearest pixel filter" before): every pixel is a clean block.
  * **Smooth**: bilinear smoothing of the art's pixels.
  * **Smooth, crisp edges** ("Sharp filter" before): only the edges between pixels are blended; it differs
    from Sharp pixels only when the picture is fitted at an uneven scale.
  * **Scale2x / Scale3x**: stair-steps are rounded without adding colours.

  Smooth and Scale2x / Scale3x apply with every scaling choice and on the zoomed map (section 8), and
  together with CRT Scanlines. An entry that cannot change the picture shown now is gray and says "no effect
  now": for example every entry but Sharp pixels with the Windows graphics at 1:1 and normal map zoom, where
  one art pixel is one screen pixel.
* **Original pixel density (1:1)** (called "1:1 pixels in gameplay" in 1.2.5): during a game every picture
  is drawn at its original size, one screen pixel per pixel, in every graphics style: the Windows 3.1
  desktop with the game's windows, dialogs and menus, windowless play, the DOS play screen (its DOS art
  doubled, as always) and the DOS 320 x 200 screens (the city screen, the reports), which then stand in
  the middle of the window. The game screen takes the window's size, so a larger window shows more of the
  desktop and the map. The largest game screen, 2726 x 1600, is the whole world map beside the World Map
  and Status column; on a larger window (for example 4K full screen) the picture is drawn at the smallest
  whole step instead (2 x 2 up to 5452 x 3200, 3 x 3 beyond), so it fills the window and the map never
  covers more than the whole world. While it is selected the map zoom goes no further out than normal
  and the 4:3 items do not apply. Your choice is remembered. Two further choices apply only at 1:1 (they
  are gray otherwise):
  * **Draw popup content at: 1x, 2x, 3x** (new in 1.3): every popup over the map, from the Civilopedia
    to the city view, is shown 2 or 3 times larger, with sharp whole pixels, while the map stays 1:1. When
    the larger popup does not fit the window, the largest factor that fits is used. The game itself sees
    no change.
  * **Draw World Map and Status Windows at: 1x, 2x, 3x** (new in 1.3): the World Map and Status windows
    (or, in windowless play, their column) are drawn 2 or 3 times larger, in every graphics style.

  With a Modern-style pack in windowless play, the menu bar and its menus are drawn at twice the size at
  1:1 (since the 1.3.4 downloads of 2026-11-26), and the map begins below them. There is no setting for it yet.
* **4:3 aspect for 320x200 DOS intro screens** (on by default): the DOS graphics' 320x200 screens before
  a game (the intro, the title menu, the setup pages, the Hall of Fame, Load) are shown with the 4:3 shape
  of a DOS monitor, so their pixels are a little taller than wide; off, they keep square pixels. The DOS
  Birth of Civilization always keeps square pixels.
* **4:3 aspect for 320x200 DOS gameplay** (off by default, since 1.1): the whole game with the DOS
  graphics takes the DOS screen's 4:3 shape: the menu bar and its menus, the map, the World Map, the
  Status window, every DOS box and the full-screen DOS scenes (reports, the city screen, Civilopedia
  ...). The game screen's size and the game itself are unchanged. The Windows graphics' pictures always
  keep square pixels.
* **CRT Scanlines** (off by default, since 1.1): a CRT monitor's dark scanlines over the picture, after
  DOSBox Pure Unleashed's CRT filter (scanlines only, normal gaps, sharpest), double-scanned: two
  scanlines per pixel row of the picture, over the map zoom too. Where the screen has too few rows for
  that, they lie on the screen's own rows (one gap every two), so they show at every size. In a window
  they are spaced exactly as in full screen on the window's monitor. Every pixel stays as sharp as
  without it.

The intro, title, Birth and setup screens keep **Integer scaling** or **Fit to window** when 1:1 is
selected.

**Play style** (the Options dialog's Display page). **Windowed** shows the game's own windows (the map,
the World Map and the Status windows, the dialogs) in one of three styles:

* **Simulated Windows 3.1**: as the original under Windows 3.1, drawn by civ64. This is the default.
* **Simulated Apple System 7** (new in 1.3): the same windows, with the same sizes and behaviour, but their
  frames, title bars, menus, scroll bars and buttons drawn in the style of Apple's System 7, with a Chicago
  font. The game's own pictures and text are unchanged.
* **OS native** (new in 1.3): the game's windows become windows of their own with Windows' frames and
  title bars: the map window "CIVILIZATION" is civ64's main window, and the World Map, the Status window
  and the dialogs are windows over it, which you can move as usual. With the Amiga and Atari ST graphics,
  their World Map and Status panels become such windows, in their editions' look.

**Windowless play** (since 1.1) shows the game, during play, as one picture without captions, frames,
borders or scroll bars, laid out like the DOS game's screen: the menu bar across the top, the World Map
and the Status panel in a column below it on the left, and the map beside them. Menus open under their
titles; dialogs, message boxes and the DOS boxes float over the picture. It works with the Windows and the
DOS graphics, in a window and in full screen, and can be switched on and off at any time. The picture fills the
whole window: civ64 makes the game's map window larger by the removed frames and scroll bars (so
switching windowless play on or off resizes the map window a little). Before a game begins (the intro,
the title menu, the setup) the screens look as before. With the Windows graphics the menu bar across the
top is the Status window's gray and the menus that drop from it have a seamless stone background (built
into `civ64.exe`); their unavailable items are drawn in a dark checker so that they stay readable. With
the DOS graphics the menu bar shows the DOS game's five titles at their DOS places across the whole bar.

**OS native menu** (new in 1.3): with the Windows graphics, the game's menus (File, Edit, Orders, ...)
are shown in the window's own Windows menu bar instead of the game's emulated bar; the menus, their
items and their keys stay the game's. With the other graphics styles the game's own menu bar comes back.

Display changes apply at once; windowless play and 1:1 finish switching when you close the Options
dialog.

**The game screen fills the window.** The opening credits, intro, title menu, Birth and setup screens
keep the original's 640x480 picture, with black borders in a wider window. When a game begins (new,
loaded, EARTH or customized), the game's screen takes the window's size at the current scale, so the
map uses the whole window: a 1920x1080 window at twice the size gives a 960x540 game screen instead of
640x480. From then on the game screen follows the window: enlarge, shrink, maximize or restore it,
or switch to full screen, and the game screen grows or shrinks at once. The map window keeps the
right and bottom edges it touches; the World Map and Status windows stay where they are. The desktop
around the game's windows is black. Every graphics style fills the window in the same way.

**Full screen.** **Alt+Enter**, or the window menu's **Full screen**, makes the window cover its
monitor; press it again to return to the window. civ64 remembers it.

**Light and dark mode.** The title bar, the window menu, the Options dialog, the About box and civ64's
own message boxes follow Windows' light or dark app mode (Settings > Personalization > Colors) and
change with it at once.

## 6. The window menu and the Options dialog

**The window menu.** Open it by clicking the icon at the left of the title bar, or by right-clicking the
title bar. (Alt, Alt+Space and F10 belong to the game's own menus.) From the top:

| Item | What it does |
|---|---|
| **Restore**, **Move**, **Size**, **Minimize**, **Maximize** | Windows' own window commands. |
| **Full screen** (Alt+Enter) | Full screen on or off. |
| **Options…** | The Options dialog (below). |
| **Add screen to mod kit** | Adds the current screen's pictures to your mod kit; makes the kit first when there is none (section 7). |
| **Save State**, **Load State** (since 1.3.1) | Five quick-save slots (section 11); each line shows what the slot holds. Ctrl+F1 to Ctrl+F5 save, Ctrl+Shift+F1 to Ctrl+Shift+F5 load. |
| **Zoom out** (Ctrl+Shift+Minus) | The map zoom one level out (section 8); choose it again to go on. Gray at half size. |
| **Normal zoom** (Ctrl+Shift+0, Home) | The map zoom back to normal; checked at normal size. |
| **Zoom in** (Ctrl+Shift+Plus) | The map zoom one level in; choose it again to go on. Gray at double size and while the map window is too small for the next level. |
| **About…** | The program's name and version, credits, the repository link, the licence and the notices of the MT-32 emulation and of the Chicago font. |
| **Close** (Alt+F4) | Exit civ64 (section 4); the menu's default item. |

Version 1.3 moved the earlier **Display**, **Map zoom** (its **Mouse wheel zooms map**), **Graphics** and
**Alternative music/soundfx** items of this menu to the Options dialog.

**The game pauses** while the window menu or one of its submenus is open, while the window is moved or
resized, and while civ64's own boxes and the Options dialog are open: the game, its animations, the music
and the sounds stand still, and afterwards everything goes on where it stopped, without a fast catch-up.
The game's own menus and dialogs do not pause it, as in the original.

**A minimised window draws nothing** (since 1.3.3): the game keeps running, and when the window comes back it
shows the current picture.

**The Options dialog** (new in 1.3) has three pages, **Display**, **Graphics** and **Audio**, and opens
on Display. Click a page's tab, or use Ctrl+Tab and Ctrl+Shift+Tab. **Done**, Escape or the dialog's close
button closes it; there is no Cancel, because every change applies as you make it (or at the next start,
where the dialog says so). Every choice is remembered in `civ64.cfg`.

* **Display**: **Play style** (Windowed: Simulated Windows 3.1, Simulated Apple System 7 or OS native;
  Windowless play; OS native menu), **Scaling** (Integer scaling, Fit to window or Original pixel density
  (1:1), with the popup and World Map and Status sizes at 1:1), **Filter** (the list Sharp pixels, Smooth,
  Smooth with crisp edges, Scale2x / Scale3x; CRT Scanlines) and **Extras** (the two 4:3 items and **Use mouse wheel to zoom in/out**). All of
  them are described in section 5 and, for the wheel, section 8.
* **Graphics**: the **Graphics style** cards (Windows, DOS VGA, DOS EGA, Amiga, Atari ST, PC-98, SNES and
  Custom; section 7), the **Custom graphics mods** list (section 7), and **Graphics game files**.
  Each card says in words whether its style is **Shown now**, **Available**, waits for a restart, or needs
  files: a card that shows **Choose files** opens a file dialog for that edition's files (Windows:
  `civ.exe` or a ZIP; DOS: `CIV.EXE` or a ZIP; Amiga: the `game` file of the extracted folder or a ZIP;
  Atari ST: `GAME.PRG` or a ZIP; PC-98: `YSOUND.CVL` or a ZIP of its files; SNES: the cartridge image
  (`.sfc`, `.smc`) or a ZIP). civ64 checks the choice and copies the files it needs into `GameData` as that
  edition's archive (section 3); a message names the archive, and the style is available from the next
  start. A style whose files were refused shows **Files not usable**.
* **Audio**: the source of the music and sound effects: **Windows** (the game's own WAV files), **DOS IBM
  Sounds** (the PC speaker), **DOS Tandy sounds**, **DOS AdLib/Sound Blaster**, **DOS Roland MT-32 MIDI
  board** (an MT-32 emulated inside civ64, on your own copy of its ROMs), **Amiga**, **Atari ST**,
  **SNES**, **NEC PC-98**, or **Custom** (your own WAV files, section 3), each available when its files
  are loaded. The sound source is independent of the graphics style. A change applies from the next sound.
  **Custom audio files** (**Choose file…**) copies your WAV files into `GameData` as `CustomMusicSfx.zip`;
  new sound files apply after a restart. A Custom file that cannot be played falls back to the game's own
  sound. The editions' sounds follow the game's events as their own programs played them; they could not
  be compared with recordings of the original editions.

## 7. The graphics styles

civ64 shows the same game in one of these styles; only what you see changes:

* **Windows**: the game as the Windows 3.1 release shows it. The menu bar and an open menu always show the
  game's torch cursor.
* **DOS VGA**: the game with the pictures, palettes, fonts, menus and mouse pointer of *Civilization for
  DOS* (version 475.05), read from your DOS files, as its VGA driver draws them.
* **DOS EGA** (new in 1.3): the same DOS game as its own EGA driver draws it: 16 colours, the pictures
  dithered by their EGA tables, the EGA dissolve and the map's EGA shapes.
* **PC-98** (new in 1.3): the DOS game with the pictures, sprites and palettes of the NEC PC-98 edition. The text is in English, in the DOS game's Latin font drawn at twice the size,
  as the PC-98 edition draws its Latin text; it needs both the DOS and the PC-98 files.
* **Amiga** and **Atari ST** (new in 1.3): the game in those editions' own layouts, art, fonts and pointer,
  from the intro and Birth to the endings. Their play page draws its
  own map, World Map and Status panel.
* **SNES** (new in 1.3): the SNES edition's screens, art, fonts and windows, drawn from your cartridge image.
  Its intro runs at its own pace and is not kept in step when you switch. As on the SNES, the setup
  questions come first, in the SNES setup screen, then the Birth with the names you chose. In play the
  SNES vertical menus are replaced by a menu bar at the top, like the other styles', with the game's
  menus in the SNES font and windows. As in the SNES edition, the Japanese take the Zulus' place in the
  SNES graphics (their name, ruler and cities).
* **Custom** (new in 1.3): the graphics mod or pack selected in the Custom graphics mods list (below).

**Switching.** Press **Ctrl+Shift+Backspace**, or choose a card on the Options dialog's Graphics page, at
any moment: during the intro, the title menu, the Birth, the setup screens or a turn. Ctrl+Shift+Backspace
steps through the styles whose files are loaded: Windows, DOS VGA, DOS EGA, PC-98, Amiga, Atari ST, SNES and
Custom. The whole picture is redrawn at the next tick, and the window keeps its size. The DOS VGA, DOS EGA
and PC-98 drivers each run from the start, so they too switch live. The animation at the top of the
[repository README](../README.md) shows a switch during play.

**Switching never changes the game.** Your game, the computer players, the random numbers and your
saves are the same in every style. Only what you see changes, with two deliberate exceptions: with
the DOS graphics the game continues to the setup as soon as the DOS Birth story ends, and the science
advisor's recommendation box closes itself as the DOS game's does. That recommendation stands
on the Status window, its width the Status window's, as in the DOS game, and it follows the Status
window when it moves, the map zooms or windowless play is on.

**civ64 remembers** the style you last switched to and starts in it; without usable files for it, it
starts with the Windows graphics.

**What the DOS graphics show** (VGA, EGA and PC-98).

* The DOS intro, with the credits over the panorama, the logo reveal and the dissolve, at the DOS
  version's own pace. The Windows and DOS intros run on the same clock, so a switch during the intro
  continues at the same moment. The DOS title box has the DOS version's five items; **Quit** is in the
  Windows graphics or on the window's close button.
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

**Windows-only items** keep their Windows form in the other styles: the file dialogs (switch to the
Windows graphics at the DOS Load or Save screen to use the Windows file chooser for other files), the
system message boxes, the About box and Help. The Windows menus EDIT, CITY and HELP exist only in the
Windows graphics.

**Input with the DOS graphics** follows the DOS game:

* In DOS menu boxes, **Up** and **Down** move the highlight (no wrap), a row's letter moves to the
  next row with that letter, **Return** or **Space** chooses, **Escape** closes. A click on a row
  chooses it; a press held over the rows moves the highlight and chooses at the release.
* In play with the map active, **Alt+G**, **Alt+O**, **Alt+A**, **Alt+W** and **Alt+C** open GAME,
  ORDERS, ADVISORS, WORLD and CIVILOPEDIA; **F1**..**F10** open the advisors and the World reports;
  **Alt+V** switches the sound; **Alt+Q** asks whether to quit. The unit orders take the letters the DOS ORDERS box
  shows: **p** cleans up pollution (since 1.3.4; before, p was the Windows game's Pillage) and **Shift+P**
  pillages; the Windows letters (K for Clean Up Pollution) work too.
* On the DOS city screen: **i**, **h**, **m** the panels, **v** the city view, **b** buy, **c**
  change production, **r** rename, **1**..**9** specialists; **Escape**, **Return** or EXIT close it.
* Reports, scenes and notes close with any key or a left click. **Alt+H** or the right button on a
  list item opens its Civilopedia page where the DOS game offers help.

**The map in the Amiga, Atari ST and SNES styles** is moved as in the original game: a click on a square
centres the view there, a click on the World Map centres on that square, and the game centres on the
active unit. There is no scrolling at the screen's edge.

**Custom graphics mods** (new in 1.3). The list under the Graphics page's cards holds your graphics mods;
the one marked **Selected** is what the **Custom** card shows. civ64 includes no mods or packs. Since 1.3.1
a tileset mod's archive that you put into `GameData` yourself (`Mod-<name>.zip`) is listed at the next start
without **Add mod…**; one you remove from the list stays removed, and its file stays in `GameData`. A Modern
pack there (`Civ-Modern.zip`) is listed the same way (since the 1.3.4 downloads of 2026-11-26) and becomes the
selected mod when none was selected. Two kinds
are accepted:

* **Tileset mods** for the Windows graphics (a mod's `civdata0.rsc` to `civdata4.rsc`) or for the DOS
  graphics (the DOS game's `.PIC` and `.PAL` files of the same names), such as the community mods for
  Civilization for Windows. Each picture the mod holds replaces the game's; whatever the mod lacks, or a
  picture civ64 cannot use (for example a replacement of the EARTH map), is drawn from your original
  files. The mod's other files (texts, sounds, programs) are never read. A tileset mod shows after a
  restart.
* **Modern-style graphics packs**: a pack in civ64's Modern pack format, which you obtain separately (for
  example, made by someone with the mod kit below). It replaces the Windows graphics' pictures, map tiles,
  fonts, window parts and pointers with its own, at once; whatever the pack lacks is drawn in the Windows
  graphics.

The list's buttons:

* **Add mod…**: choose a mod's ZIP, its folder (any file in it), or a pack's ZIP or its `manifest.json`.
  civ64 checks it and copies it into the `GameData` folder as one archive (`Civ-Modern.zip` for a Modern
  pack, `Mod-<name>.zip` for a tileset mod); a mod already in the list, judged by its content, is not
  added twice. A ZIP already in `GameData` is used where it is.
* **Remove**: the mod leaves the list; its archive stays in `GameData`. Removing the mod the Custom card
  shows returns to the Windows graphics.
* **Use this mod**: marks the chosen mod **Selected** for the Custom card.

If the archive of the selected mod or pack is no longer in `GameData`, civ64 starts in the Windows graphics
without asking and keeps the entry and your choice; add the mod again with **Add mod…** to use it.

**The mod kit** (new in 1.3), for making your own Modern-style pack. **Create mod kit…** asks for a folder
(an empty one is best) and writes a web page, `index.html`, with reference pictures. Open it in a web
browser: it lists every picture a pack can replace, with its name, a short description, its id, the path
it has in a pack, its recommended size, a reference picture made from your own game files and, where
known, pictures of the screens where it is used; it has a search, filters and a coverage table. The window
menu's **Add screen to mod kit** adds the current screen's pictures to the kit's "where it is used"
pictures (reload the page to see them). The page's **Check a pack** checks a pack folder or ZIP and lists
its errors, its missing items and the files no entry names; a missing item is only a warning, because the
game draws it in the Windows graphics. The kit's pictures are made on your computer from your own files
and show the original game's art.

## 8. The map zoom

The map zoom shows the main map window at **half size** (level -2), **three quarters** (-1),
**normal** (0), **one and a half** (+1) or **double size** (+2), in every graphics style. Only the main
map is zoomed; the small World Map, the Status window and the reports are not. The zoom only changes
what you see: the game's own view and input stay the same.

| Way | What it does |
|---|---|
| **Ctrl+Shift+Plus**, **Ctrl+Shift+Minus** (main row or keypad) | One level in or out. |
| **Ctrl+Shift+0** or **Ctrl+Shift+Home** | Back to normal. |
| The mouse wheel over the map | One level per notch, forward zooms in; the point under the pointer stays under it (when the Options dialog's **Use mouse wheel to zoom in/out** is checked, the default). |
| The window menu's **Zoom out**, **Normal zoom** and **Zoom in** | One level each time (as the keys), zooming about the map's centre. |
| `--zoom -2`, `-1`, `0`, `+1` or `+2` on the command line | The level for this run. |

The plain `=`, `-`, `0` and Home keys still reach the game.

* **Zoomed in (one and a half, double)** the picture follows your active unit, and it centres on the
  square the game centres on (C, the next unit, a click on the small map, the scroll keys). A level in is
  refused while the map window is too small to show 3 x 3 squares at that size.
* **Zoomed out (three quarters, half)** you see the game's whole view surrounded by the rest of the world, drawn from
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
  **Help**. **File > Options** holds the game's own Instant Advice, Auto Save, End Of Turn, Animations,
  Sound, Enemy Moves, Civilopedia Text and Palace (civ64's settings are in the window menu's
  **Options…**, section 6).
* **Window layout.** At the start of a game the map, World Map and Status windows take the places
  saved in `civ.prf` (the one in the `Save` folder, else the game's own). When those do not fit the game
  screen, or there is no `civ.prf`, they take the default layout. So does a `civ.prf` written by the original game
  whose Status window is larger than civ64's (since 1.3.4); civ64 saves its own layout there when it ends.
  A moved or resized Status window keeps the World Map's width (since 1.3.4). A layout saved on a different screen
  size follows the new size. Delete `civ.prf` in the `Save` folder to get the default layout back (it also
  holds the Game Options).
* **Keyboard.** Typing follows your keyboard layout (characters are passed in Windows-1252;
  characters without a code there are dropped). The numeric keypad gives digits whatever your
  NumLock state, except in menus and dialogs (since 1.3.3): there its 8, 2, 4, 6, 7, 9, 1 and 3 move like
  the arrow keys, as in the DOS game: the game setup pages, Diplomacy, lists, message boxes, the menu bar
  and the Save/Load slot screens. On the map it still moves units, in text fields it still types digits,
  and with Shift, Ctrl or Alt held it gives its digits. With graphics other than Windows, the
  first-character choice of a list such as "3..7 Civilizations" then takes the digits of the main row, as
  in the DOS game. Alt and F10 open the game's menus.
* **Sound** comes from the source chosen on the Options dialog's Audio page (section 6); with the Windows
  source, from the game's `.wav` files. A missing file is silent.
* **Roads and railroads on ocean squares.** The original lets units build them there (a well known bug,
  kept). Since 1.3 the Windows graphics draw such a square as its own coast with the roads over it; the
  original drew coast pieces chosen by the roads, with land slivers in the open sea.
* **Help** (the original's `.hlp` file) cannot be opened, because Windows 10 and 11 have no viewer
  for it: **Help > Game Help** shows a message that says so.
* **Timing.** By default (`classic`) the game is paced like the original; world generation and the
  computer players' turns run at full speed.
* A click in the black border around the picture is ignored.

**Unit stats: `units.ini`** (since 1.3.1). An optional text file `units.ini` in the folder of `civ64.exe`
changes the attack, defense, moves and cost of any unit, one line per unit
(`Chariot = 3, 1, 2, 30`); units not listed keep their original values. civ64 reads it at the start; the
values apply to new games (Start a New Game, Play on EARTH, Customize World), and a saved game keeps the
values it was played with, because the game's own save format stores the unit table. A mistake in the file
is listed in one message at the start, and that line is ignored. Without the file, or with the file as
shipped (the original values), civ64 plays with the original rules. `README-units.txt`, which comes with
the program, has the format, the allowed values and the original table.

## 10. Keys

civ64's own keys never reach the game, nor do the Ctrl, Shift or Alt presses held for them.

| Key | What it does |
|---|---|
| Ctrl+Shift+Backspace | Switch to the next graphics style whose files are loaded (section 7) |
| Alt+Enter | Full screen on or off |
| Ctrl+Shift+Plus / Ctrl+Shift+Minus | Map zoom in / out |
| Ctrl+Shift+0, Ctrl+Shift+Home | Normal map zoom |
| Mouse wheel over the map | Map zoom (when **Use mouse wheel to zoom in/out** is checked) |
| Ctrl+F1 to Ctrl+F5 | Save State 1 to 5 (section 11) |
| Ctrl+Shift+F1 to Ctrl+Shift+F5 | Load State 1 to 5 |
| Alt+F4 | Exit civ64 (with the warning during a game) |

The game's own keys are those of the original: the menu accelerators of section 9, Alt or F10 for
the menus, the unit keys on the map, Enter at the end of a turn, and any key to skip the opening
credits or the Birth. With the DOS graphics the DOS keys of section 7 apply.

## 11. Saves, settings and the files civ64 writes

civ64 writes only to the `Save` and `GameData` folders next to `civ64.exe`, to its own folder
`%LOCALAPPDATA%\civ64`, and to a mod kit folder you choose. It never changes your own game files, the
folders and ZIP files you chose, or the archives in `GameData` other than by replacing one with a checked
copy of a new choice.

| File | Where | Written by |
|---|---|---|
| saved games (`*.SAV`) | the save folder | **File > Save Game** (the names you choose; the DOS Save screen's empty line saves as `CIVILn.SAV`) |
| `civ.prf` | the save folder | the game's preferences (Game Options and window places) |
| `famehall.civ` | the save folder | the Hall of Fame |
| `*.rep` | the save folder | the replay at the end of a game, under the name you give |
| `STATE1.SAV` to `STATE5.SAV` | `States` in the save folder | **Save State** (below) |
| `civ64.cfg` | `%LOCALAPPDATA%\civ64` | civ64's settings |
| `Civ-Windows.zip`, `Civ-DOS.zip`, `Civ-Amiga.zip`, `Civ-AtariST.zip`, `Civ-PC98.zip`, `Civ-SNES.zip`, `CustomMusicSfx.zip` | `GameData` | a choice of that edition's files at the start (Windows) or on the Options dialog (section 3) |
| `Civ-Modern.zip`, `Mod-<name>.zip` | `GameData` | **Add mod…** (section 7) |
| `index.html`, `ref\`, `ctx\` | the mod kit folder you chose | **Create mod kit…** and **Add screen to mod kit** |

**The save folder** is `Save` next to `civ64.exe`, made at the first start. When that folder cannot be
written (for example under `C:\Program Files`), civ64 uses `%LOCALAPPDATA%\civ64\Save`. The game sees one
folder: a file in the save folder hides the game's file of the same name. Saves in the game's own folder
(for example an installation's `CIVIL0.SAV`) can still be loaded; saved again, they go to the save
folder. A game file the game rewrites, such as an installation's `civ.prf`, is copied into the save folder
first.

**Save States** (since 1.3.1) are five quick-save slots. The window menu's **Save State > 1** to **5**
(Ctrl+F1 to Ctrl+F5) saves the game at once, without a question; **Load State > 1** to **5** (Ctrl+Shift+F1
to Ctrl+Shift+F5) brings it back: the screen stays for a few seconds, then the saved game is there. Each menu
line shows what the slot holds (civilization, leader, year, when saved). The files are
`Save\States\STATE1.SAV` to `STATE5.SAV`, ordinary saved games that the game's own Load Game opens too. A
state can be saved wherever the game's own Save Game works (your turn, at the map, no dialog open), not at
the title; loading works in play and at the title menu. Loading a state is the game's own load: as with any
loaded game, a unit that had moved has its moves again.

**Save compatibility.** Saved games, the Hall of Fame, the preferences and the replays use the
original formats. Your saves from the original game load in civ64, and civ64's saves load in the
original game. The load and save dialogs, and the DOS graphics' Load and Save screens, list the save
folder together with the game's folder.

**civ64.cfg** holds civ64's own choices (the editions' files themselves are in `GameData`; a location
remembered by an earlier version is removed once it has been copied there; the `dos_ask` and `music_ask`
lines of earlier versions are no longer read): the window's place and size (`window=left,top,right,bottom` in
screen pixels), full screen, the scaling and filter choices, the 4:3 choices (`aspect_4_3`,
`aspect_play_4_3`), the graphics style (`graphics`), the sound source (`audio_source`), the map zoom level
(`map_zoom=-2` to `2`) and the wheel setting (`wheel_zoom`), the screen size the window layout was saved
on (`layout_screen`), windowless play (`windowless`), the play style, CRT scanlines (`crt_scanlines`), 1:1
(`one_to_one`) with the popup and World Map and Status sizes (`popup_scale`, `tool_scale`), the OS native
menu (`native_game_menu`), the places of the Amiga and Atari ST panels as OS native windows
(`native_panels`), your Custom graphics mods, and the mod kit folder (`mod_kit`). Options given on the
command line apply to that run only and are not written. The filter is `filter=nearest`, `sharp`, `smooth`
or `scalenx`. Apart from the optional `units.ini` beside the program (section 9), civ64 reads no registry
key, INI file or environment variable; only the Windows file dialog keeps its own list of recent folders.

## 12. The command line

```
civ64.exe [--data <dir|zip>] [--dos-data <dir|zip|none>] [--amiga-data <dir|zip|none>]
          [--atari-data <dir|zip|none>] [--graphics windows|dos|dos-ega|dos-pc98|amiga|atarist|snes]
          [--zoom default|-2|-1|0|+1|+2] [--fullscreen] [--window <W>x<H>]
          [--scale auto|1..8] [--scale-mode integer|fit] [--filter nearest|sharp|smooth|scalenx]
          [--aspect square|4:3|gameplay|both] [--windowless 0|1] [--crt 0|1]
          [--music-sfx <dir|zip|none>] [--timing classic|host]
```

| Option | Meaning |
|---|---|
| `--data <dir\|zip>` | The Windows game's folder or ZIP for this run, read where it is (not copied), with no search. Its `civ.exe` must be the supported release. |
| `--dos-data <dir\|zip\|none>` | The DOS game's folder or ZIP for this run, read where it is (not copied); `none`: not used. |
| `--amiga-data <dir\|zip\|none>`, `--atari-data <dir\|zip\|none>` | The Amiga or Atari ST files' folder or ZIP for this run, read where it is (not copied); `none`: not used. |
| `--graphics windows\|dos\|dos-ega\|dos-pc98\|amiga\|atarist\|snes` | The style to start in (not remembered): `dos` the DOS VGA graphics, `dos-ega` DOS EGA, `dos-pc98` PC-98. `dos` or `snes` without usable files stops civ64 with a message. |
| `--zoom default\|-2\|-1\|0\|+1\|+2` | The map zoom level for this run (`-2` half, `+2` double size). |
| `--fullscreen` | Start in full screen. |
| `--window <W>x<H>` | The window's first client size (at least 640x480), centred. |
| `--scale auto\|1..8` | The window's first size as a multiple of 640x480; `auto` (the default) uses the remembered size or the largest multiple that fits. |
| `--scale-mode integer\|fit` | Integer scaling or fit to the window. |
| `--filter nearest\|sharp\|smooth\|scalenx` | The filter for this run: Sharp pixels, Smooth with crisp edges, Smooth, or Scale2x / Scale3x (section 5). |
| `--aspect square\|4:3\|gameplay\|both` | The shape of 320x200 screens for this run: `square` or `4:3` for the intro screens; `gameplay` and `both` also turn on the 4:3 DOS gameplay. |
| `--windowless 0\|1` | Windowless play off or on for this run. |
| `--crt 0\|1` | CRT scanlines off or on for this run. |
| `--music-sfx <dir\|zip\|none>` | Your music and sound effects from that folder or ZIP for this run, read where it is (not copied); `none`: not used. A source without one valid WAV file of the 24 names stops civ64 with a message. |
| `--timing classic\|host` | `classic` (the default) paces the game like the original with fixed costs for its internal waits; `host` follows the PC's real clock. In both, world generation and the computer players' turns run at full speed. |

Two further options, `--dump-frames <dir>` and `--dump-presented <dir>`, write every picture to a
folder as BMP files; they are meant for checks and write thousands of files. `--multi-instance` is
an option for automated tests.

## 13. Troubleshooting

| Problem | What to do |
|---|---|
| After an upgrade from 1.2.5, civ64 asks where the game is | Version 1.3 no longer looks for `CivWin.zip` or a `CivWin` folder: choose it (or the game's `civ.exe`) when asked; choose the DOS files and your sounds on the Options dialog. civ64 copies them into `GameData` (section 2). |
| civ64 asks where the game is at every start | The copy into `GameData` failed; the message said why. Most often the folder of `civ64.exe` cannot be written (for example under `C:\Program Files`): move civ64 to a folder of your own, such as `C:\Games\civ64`. |
| "The ... files could not be copied: the GameData folder ... cannot be written" | Move civ64 to a folder you can write to, or make `GameData` writable; nothing was changed. |
| "The ... files could not be copied ... (the disk may be full)" | Free some space on the drive of civ64's folder (each edition takes a few MB; your own music or a large graphics pack can take much more) and choose the files again. |
| "The copy of the ... files in GameData ... does not match the files chosen" | The copy could not be read back correctly (for example a failing drive or a file changed during the copy); nothing was changed. Choose the files again. |
| My saves from 1.2.5 are missing | With a `CivWin.zip` they were kept in `%LOCALAPPDATA%\civ64\CivWin`: copy them into the `Save` folder (section 2). |
| A message says `civ.exe` is different or missing | civ64 runs only the supported release (section 1). Check the file's size (832,512 bytes) in Explorer. |
| A message names a DOS file | That file is not the unchanged file of version 475.05: changed by a mod, left from another release, or damaged. Put the file of an unchanged 475.05 copy in its place or use another copy, or start with `--dos-data none`. |
| The DOS graphics or my sounds from 1.2.5 are gone | Their earlier location no longer exists (otherwise civ64 copies it in at the start). Choose them on the Options dialog: the DOS VGA card's **Choose files**, or **Custom audio files** on the Audio page; then restart civ64. |
| Cancel in a file dialog | Ends the choice; nothing is changed. Choose again whenever you like. |
| A graphics card or sound source is not available | Its files are not loaded: click the card's **Choose files** on the Options dialog (civ64 copies them into `GameData`), then restart civ64. For the MT-32, put `MT32-ROMs.zip` into `GameData` yourself (section 3). **Files not usable** means the files were refused. |
| Ctrl+Shift+Backspace only shows the Windows graphics | No other style's files are loaded in this run (section 3). |
| The Custom card shows nothing new | A tileset mod shows after a restart; check that it is marked **Selected** in the Custom graphics mods list. |
| A part of a mod or pack is drawn in the original look | The mod or pack lacks that picture, or civ64 could not use it; the original's picture is drawn instead. |
| "Sorry! Only one game at a time!" | civ64 is already running; after OK it comes to the front. |
| The game's windows are placed oddly | Delete `civ.prf` in the save folder for the default layout (it also resets the Game Options). |
| The window opens in an odd place or size | Delete the `window` line of `%LOCALAPPDATA%\civ64\civ64.cfg`, or start once with `--scale auto`. |
| The mouse wheel does nothing over the map | Check **Use mouse wheel to zoom in/out** on the Options dialog's Display page. |
| My own music or sound files are not played | Check the file names (the 24 names of section 3, `.wav`), that they are valid WAV files at the top level of the folder or in one folder of the ZIP, and that **Custom** is chosen on the Audio page; then restart civ64. |
| Zoom in is gray | The map is at double size, or the map window is too small for the next level; make it larger. |
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
* **The other editions:** their graphics and sounds are shown and played over the Windows game's rules,
  computer players and random numbers; nothing of their own rules or map generation is used.
* **One game at a time:** as in the original, with the running civ64 brought to the front.
* The complete list of every place where civ64 does not or cannot reproduce the original exactly is
  the fidelity register, [FIDELITY.md](FIDELITY.md).

## 15. civ64 for macOS

`Civ64.app` (version 1.3) is the same program as `civ64.exe` 1.3: the same recovered game, the same Windows 3.1
environment, the **Options** dialog, the graphics styles (Windows, DOS VGA, DOS EGA, Amiga, Atari ST, PC-98, SNES and
Custom), the editions' music and sound effects, the window styles, the 1:1 popup and tool-window sizes, graphics mods
and the mod kit, on a native macOS back end. Sections 1 to 14 apply, with the differences below. It is signed with the
developer's Developer ID and notarized by Apple, and is distributed here, not in the Mac App Store.

### Requirements

* **macOS 13 Ventura or later**, on a Mac with Apple silicon or an Intel processor (one universal application).
* **Your own copy of Sid Meier's Civilization for Windows**, the same release as on Windows (section 1). A Mac has
  no Windows directory, so the VGA system font is optional: copy `vgasys.fon` (from `C:\Windows\Fonts` of a Windows
  PC) into the game's folder for the exact Windows 3.1 font in the game's dialogs. Without it civ64 starts anyway and
  uses the game's own font for that text.
* **Optional:** your own copies of the other editions' files, as on Windows (section 3).

### Installation

1. Download `Civ64-1.3.4-macOS.dmg` from the [latest release](https://github.com/Buyukcaglar/Civ64/releases/latest)
   and open it. It also holds `units.ini` and `README-units.txt` (below).
2. Drag `Civ64.app` to the Applications folder (or any folder) and start it from there.
3. At the first start civ64 asks one thing only: the game's folder, its `civ.exe` or a ZIP of the game. It checks
   your choice and copies the files it needs into **`~/Library/Application Support/civ64/GameData`** as
   `Civ-Windows.zip`; it does not ask again.
4. Everything else is on **civ64 > Options…** (Command+,): a card's **Choose files** for the DOS and other editions,
   **Custom audio files** for your own sounds, **Add mod…** for graphics mods. Each is copied into the same
   `GameData` folder, as on Windows, and used from the next start. Cancel in a file dialog changes nothing.

On a Mac, `GameData` is in `~/Library/Application Support/civ64`, not next to the application: macOS may run a
downloaded application from a read-only place. The MT-32 ROMs are read from `GameData/MT32-ROMs.zip` there.

**Upgrading from 1.3, 1.3.1, 1.3.2 or 1.3.3.** Drag the new `Civ64.app` over the old one; your settings, `GameData` and saves
stay.

**Upgrading from 1.2.5.** Replace `Civ64.app`; your settings stay. At the first start of 1.3 civ64 copies, without a
question, what 1.2.5 used into `GameData`: the remembered game, DOS, music, Amiga and Atari ST locations, and a
`CivWin.zip`, `CivDos.zip` or `MusicSfx.zip` (or `CivWin`, `CivDos`, `MusicSfx`, `amiga` or `atarist` folder) next to
`Civ64.app`. Your saves stay where 1.2.5 kept them (below); saves in an old game folder are copied there too, without
replacing any file.

To uninstall, delete `Civ64.app` and the folder `~/Library/Application Support/civ64` (which holds your saves).

### Menus

* **The civ64 menu** (the application menu in the macOS menu bar) holds About, **Options…** (Command+,), Full
  Screen, and quick menus for the same choices as the Options dialog: Display (the window styles Simulated Windows
  3.1, Simulated Apple System 7 and Windowless, OS Native Menu, Integer Scaling, Fit to Window, 1:1 Pixels in
  Gameplay, Popup Scale and Tool Window Scale at 1:1, the filters, CRT Scanlines and the two 4:3 items), Map Zoom
  (Zoom Out, Normal Zoom, Zoom In, Mouse Wheel Zooms Map), Graphics (the graphics styles, Switch Graphics, Choose
  Files and Graphics Mods with Add Mod…, Remove and Create Mod Kit…), Add Screen to Mod Kit, Audio (the ten sound
  sources), then Hide civ64 and Quit civ64. The game pauses while a menu or the Options dialog is open.
* **The game's own menus** are shown in the game window, as in Windows 3.1, and in the macOS menu bar, where you can
  choose them as well. With **OS native menu** (Windows graphics) the game window's own bar is left out, as on
  Windows; Option or F10 opens the game's menus as a pop-up menu, Option with a letter opens that menu.

### Keys

Option is the Alt key. The Command key belongs to macOS and never reaches the game; civ64's commands have Mac
shortcuts with Command, and the Windows keys work too:

| On a Mac | Windows key | What it does |
|---|---|---|
| Command+, | (window menu, Options…) | The Options dialog |
| Shift+Command+Delete, or Control+Shift+Delete | Ctrl+Shift+Backspace | Switch to the next graphics style whose files are loaded |
| Control+Command+F, Option+Return or the window's green button | Alt+Enter | Full screen (macOS's own, in a space of its own) |
| Command+= / Command+- | Ctrl+Shift+Plus / Minus | Map zoom in / out |
| Command+0 | Ctrl+Shift+0, Ctrl+Shift+Home | Normal map zoom |
| Command+Q | Alt+F4 | Quit (during a game civ64 asks first) |
| Option with a letter | Alt with a letter | The game's menus (as Alt on Windows) |

Delete is the key above Return (Backspace on a PC keyboard). Releasing Shift, Control or Option after one of these
shortcuts does not count as a key press in the game, so a switch during the opening credits does not skip them.

**The numeric keypad** (since 1.3.3): in menus and dialogs its 8, 2, 4, 6, 7, 9, 1 and 3 move like the arrow keys,
as in the DOS game: the game setup pages, Diplomacy, lists, message boxes, the menu bar and the Save/Load slot
screens. On the map it still moves units, and in text fields it still types digits. With Shift, Control or Option
held it gives its digits. With graphics other than Windows, the first-character choice of a list such as
"3..7 Civilizations" then takes the digits of the main row, as in the DOS game.

### Files and settings

civ64 writes only to `~/Library/Application Support/civ64`: `civ64.cfg` (civ64's settings, the keys of version 1.3,
with the window's place as `window_mac`), `graphics-mods.cfg` (the mod list, the same file as on Windows),
`GameData` (the copies), the `CivWin` folder unpacked from `GameData/Civ-Windows.zip` (with its `CivWin.manifest`),
where the saves, `civ.prf`, the Hall of Fame and the replays are written in the original formats, and
`civ64.lock` / `civ64.owner`, which keep a second civ64 from starting (the running one comes to the front).

### Differences from the Windows program

* **Save States** are in the **civ64** menu, with Mac keys: Control+Command+1 to 5 saves, Control+Option+Command+1
  to 5 loads (Ctrl+F1 to Ctrl+F5 and Ctrl+Shift+F1 to Ctrl+Shift+F5 also work where macOS leaves those keys to
  the game). The states are kept in `~/Library/Application Support/civ64/CivWin/States`.
* **`units.ini`** is read beside `Civ64.app`, else in `~/Library/Application Support/civ64`; the disk image
  holds the file with the original values and `README-units.txt`.
* **OS native windows** (the World Map, Status and dialogs as real windows) are not in the macOS application: the
  Options dialog shows that window style as not available on macOS. Simulated Windows 3.1, Simulated Apple System 7
  and windowless play are.
* `GameData` and the saves are in `~/Library/Application Support/civ64`, not next to the program (above).
* Full screen is macOS's own: a space of its own with macOS's animation.
* While the window is minimised civ64 draws nothing (since 1.3.3, as on Windows); the game keeps running, and the
  Dock shows the picture from the moment it was minimised.
* Moving the window does not pause the game (on Windows it does); the menus, a live resize and civ64's own boxes
  do.
* civ64's boxes are macOS windows and follow the system's light or dark appearance. The Options dialog is a macOS
  window too, with the Windows program's dark design since 1.3.3 (the same tabs, panels, cards and Done button), whatever
  the system's appearance; System Settings' Increase Contrast strengthens its borders and secondary text.
* Only files and folders with plain 8.3 names are listed to the game (Windows also lists the short alias of a long
  name).
* Cursor pixels that Windows would invert are drawn black, and the hourglass cursor is the arrow (macOS has no
  public hourglass cursor).
* A Modern-style pack's own font files are not drawn with the pack's font: their letters come from the pack's
  picture of the font or the original font.
* The command line (section 12) has the options of version 1.2.5 when you start `Civ64.app/Contents/MacOS/civ64` from
  Terminal; `--graphics` also takes `dos-ega`, `dos-pc98` and `snes`.

# Brief: the user's three extra features (after the final Asan pass)

Recorded 2026-10-17 about 08:35 UTC by session E4's orchestrator from the user's chat message (verbatim below). The
user: "Add these three tasks to the very end of the run 'After ASAN checks' since they are extra features". They run
after the whole queue (D6fS, DBL, UX5b, D7, D8, WL, X9, the one Asan pass), in the order given, each as a unit with a
design note, its three-step cycle, a user build under `build/user-builds/<unit>/`, a record and checklist items, and a
closing all-variant build/test plus the session-end hash check after the last one. Unit names: **AMS** (alternative
music and sound effects), **A43** (4:3 for DOS gameplay and the rename), **CRT** (the scanlines filter).

## The user's text (verbatim)

> Add these three tasks to the very end of the run 'After ASAN checks' since they are extra features;
>
> 1. Add ability to replace in game Music/SoundFX with the optional selectable external Music/SoundFX folder or zip
> file named MusicSfx.zip like DOS graphics handled.
>
> There are 24 wave files present in the original Windows game;
> airnuke.wav
> alex.wav
> cannon.wav
> ceas.wav
> eliz.wav
> fred.wav
> gand.wav
> geng.wav
> hama.wav
> linc.wav
> lose2.wav
> mao.wav
> mont.wav
> napo.wav
> opening.wav
> rams.wav
> shak.wav
> stal.wav
> s_beep.wav
> s_land.wav
> s_nuke.wav
> they_die.wav
> we_die.wav
> wintune.wav
>
> Selected music location (folder or zipfile) may contain any arbitrary number of these files, file names must be
> same but the file matching must be case insensitive. Any provided valid and matched alternative music or soundfx
> shall be played instead of original one, and missing ones shall be played from original resources.
>
> This alternative Music/SoundFX feature shall be tied to a user selectable host application context menu option
> name 'Alternative music/soundFx', enabled automatically if user provides a valid source, and can be disabled by user
> at any thime by unchecking it.
>
> First time setup process shall be same DOS graphics setup and displayed after asking DOS resource questions.
>
>
> 2. Rename "4:3 aspect ratio for 320 x 200 screens" to "4:3 aspect ratio for 320 x 200 DOS intro screens"
> Add a new menu item under "4:3 aspect ratio for 320 x 200 DOS screens" name "4:3 aspect ratio for 320 x 200 DOS
> gameplay" This when selected shall apply 4:3 aspect ratio correction to all DOS gameplay graphics, including top Menu,
> menu items and their texts texts, popups, World Map, Play Map, Status Window, Texts, all the DOS game windows.
>
> 3. Implement optional scanlines filter from DosBox Pure Unleashed 'https://codeberg.org/schelling/dosbox-pure-unleashed'
> project, user interface configuration parameter configuration of the exact required filter on the DosBox Pure
> Unleashed follows;
>
> CTRL+F12 - Settings;
> 1. CRT Filter - Only Scanlines
> 2. CRT Filter Scanline Intensity - Notmal gaps
> 3. CRT Filter Blur/Sharpness Sharpest
> 4. CRT Filter Phosphor MAsk Strentgh - Default
> 5. CRT Filter Curvature - Disabled
> 6. CRT Filter Rounded Corner - Disabled
> 7. Aspect Ratio Correction - 'Tied to our 4:3 options'
> 8. Overscan Border Size - Off
>
> This will be single filter with the configuration provided above no other options from refernced source project is
> required, put this as a on/off option host application context menu named 'CRT scanlines'

## The orchestrator's reading (for each unit's design note; the user may correct it in the end-of-development feedback)

**AMS.**
* Sources are looked up the way phase R looks up the DOS data (`ext-R-acceptance.md`). That means `MusicSfx.zip`
  (name matched case-insensitively) or a `MusicSfx` subfolder next to `civ64.exe`. If neither exists, the first-time
  setup asks for and browses to a folder or ZIP. That question comes after the DOS resource questions, is optional
  (like DOS), and its answer is remembered.
* Only the 24 names listed are replaced, matched case-insensitively. A file is used only if it is a valid WAV that the
  host can play; any other file, and any missing name, falls back to the original game's own resource.
* The game core is unchanged (P0). The replacement happens in the host's sound service, where the core asks for a
  sound by its name or resource.
* The system-menu item "Alternative music/soundfx" (the user's corrected spelling of 2026-10-17 about 10:30 UTC, verbatim: "“Alternative music/soundFx” -> “Alternative music/soundfx”"; it supersedes the spelling in the quoted request above) is checkable. It is checked automatically when a valid source is
  found or chosen, the user can uncheck it at any time, and it is remembered in `civ64.cfg`.
* Open for the design note:
  * where the 24 sounds live in the Windows data, and how the core plays them (the sound service's entry points);
  * what happens when a source is changed or removed while civ64 runs;
  * ZIP extraction: as `%LOCALAPPDATA%\civ64\...` for CivWin per the user's decision of 2026-10-10, or read in memory;
  * whether a ZIP replaced later is refreshed.

**A43.**
* The existing item "4:3 aspect ratio for 320 x 200 screens" is renamed "4:3 aspect ratio for 320 x 200 DOS intro
  screens". It keeps its present scope: the DOS start-up, the title menu and the 320x200 DOS screens outside play;
  Birth stays square (UX5).
* A new checkable item "4:3 aspect ratio for 320 x 200 DOS gameplay" goes directly below it. The user's "under '... DOS
  screens'" is read as "below the renamed item". When checked, it applies 4:3 correction to the whole DOS gameplay
  presentation on the A canvas: the menu bar, drop-downs and their texts, popups and boxes, World Map, map, Status
  window, texts, and every DOS game window.
* Input mapping follows the shape, the Windows graphics are unchanged, the setting is remembered, and the `--aspect`
  option is extended.
* Open for the design note:
  * the in-play full-screen DOS scenes of D7 (reports, city screen, Civilopedia ...): whether they follow the
    gameplay item or the intro item (proposed: the gameplay item, since they are shown during play);
  * how the map zoom layer and the pointer follow the 4:3 shape.

**CRT.**
* One on/off system-menu item "CRT scanlines", remembered in `civ64.cfg`. It is one filter fixed to the user's eight
  settings, read from DOSBox Pure Unleashed's source (`https://codeberg.org/schelling/dosbox-pure-unleashed`, read-only
  web access): only scanlines, normal gaps, sharpest, default phosphor mask strength, no curvature, no rounded
  corners, no overscan border.
* Its aspect follows civ64's 4:3 items.
* It is applied by the host presentation after scaling, in both graphics profiles.
* Open for the design note:
  * the referenced project's licence (DOSBox Pure is GPL-2.0): reimplement the filter's math in civ64's own code with
    attribution and copy no code unless the licence allows it in this repository;
  * how the scanline pattern maps to non-integer and fit scaling;
  * performance at 4K;
  * a headless golden of the filtered frame.

**Menu placement (added 2026-10-17 about 10:08 UTC):** the interim unit HM (`verify/BRIEF-hm.md`) restructures the window menu into Display, Map zoom and Graphics submenus before these units; A43's two items and CRT's item go into Display, AMS's item at the top level below Graphics, as BRIEF-hm.md's last section says.

**Order after the extras (added 2026-10-18 about 07:35 UTC):** WL (`verify/BRIEF-wl.md`, deferred to the next session by the user at about 06:42 UTC) comes with these units. After the extras' closing all-variant build/test and the session-end hash check, the very last task is unit IWC (`verify/BRIEF-pub.md`, section "Unit IWC"): publishing the independently written code to the public repository `Buyukcaglar/Civ1`, without `port/core` and `claude/src`, by the user's direction of about 07:35 UTC.

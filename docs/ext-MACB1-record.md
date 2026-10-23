# Unit MACB1 (the user's first macOS bug reports) - record

## The user's words (2026-10-22, about 19:10 UTC, on the user build `build/user-builds/mac3/`)

> There are some bugs present with your build;
> 1. Graphics switch short cut does not work
> 2. Windowless play switch from Windows to DOS causes CIVILIOPEDIA menu title display problem
> 3. DOS graphics Advisors -> Trade Advisor: Portrait of advisor on right top is wrong colored, but only on first view,
> subsequent views have no such problem

and, during the work: "One more thing, outside the play windows cursor does not return to default OS cursor"

## Results

| # | Finding | Fix | Where | Seen fixed (agent-observed, macOS) |
|---|---|---|---|---|
| 1 | The Control chord (Ctrl+Shift+Backspace) works when it arrives (a synthetic event switched the graphics); a Mac player presses Command for "Ctrl", and Command belongs to macOS, never to the game | The app menu items get the Mac's own key equivalents: Switch Graphics Shift+Command+Delete, Zoom Out Command+Minus, Normal Zoom Command+0, Zoom In Command+=, Full Screen Control+Command+F; the Control chords stay as on Windows | `platform/macos/host_macos.m` (macOS only) | Shift+Command+Delete switched the graphics (the setting recorded `graphics=dos`) |
| 2 | In windowless play the canvas's bar is the map window's menu bar with its last column repeated to the canvas's width (WL2). The DOS titles stand at DOS's fixed places across 320 DOS pixels (GAME 8, ORDERS 64, ADVISORS 128, WORLD 192, CIVILOPEDIA 240; R:0238:1005..1075) and are drawn into the map window's bar at scale 2: with a map window narrower than about 330 DOS pixels (here the default 4:3 window, 1920 x 1440) CIVILOPEDIA was cut and the repeated last column drew a stripe of its letters. Shared code: the same on Windows with such a window | In the DOS graphics the bar right of the map window's bar shows the DOS bar's own pixels (the same titles at the same places, drawn at DOS's full width, in the play palette; the bar's fill beyond 320) when the windowless scene is the DOS graphics' (`PwlScene.dos`); the Windows graphics keep WL2's repeated column | `present/wl.c`, `wl.h` (`PwlScene.dos`), `present/dos/pdos_reskin.c`, `.h` (`pdos_reskin_bar_ext`) | All five DOS titles after DOS -> Windows -> DOS; a click on CIVILOPEDIA opens its drop-down |
| 3 | After Load a Saved Game, DOS's main sets the play palette with the government's BACK palette (R:01A8:014D..016A: DGROUP:6B32 == 1, Load, calls R:0238:1B44, whose R:0238:1BEB loads SP256.PAL with BACK<g><a\|m>.PAL over entries 128..255, the colours of the court and of the advisors' portraits, GOVT*.PIC). The port set that palette only at a report's return, so until the first report closed a loaded game's play palette kept SP257.PIC's upper entries: the first advisor report showed the portrait in wrong colours (magenta), the next ones right. Shared code (v1.2.1 on Windows too); a new game's Despotism court colours may coincide with SP257's | At the first play state (`WdwMapOpen`'s exit), after SP257.PIC's palette, the recipe is applied when the core's last title choice was Load (1), as DOS does | `present/dos/pdos_profile.c`, `pdos_seq.c`, `.h` (`pdos_seq_title_last`), `pdos_aplay.c`, `.h` (`pdos_aplay_palette_back`, was the static `palette_back`) | The first Trade Report after loading CAE3540B.SAV shows the advisor in the right colours |
| 4 | The back end sets the game's cursor itself (`[NSCursor set]`), so AppKit did not put the system arrow back when the pointer left the play area | The arrow when the pointer leaves the view (`mouseExited`) and during a drag outside it | `platform/macos/host_macos.m` (macOS only) | (not observable in a snapshot; the user's check) |

## Changes to shared code (the Windows build compiles them too; not rebuilt or run on Windows here)

* `present/wl.c`, `wl.h`: the scene's `dos` flag; the composition calls `pdos_reskin_bar_ext` (wl.c already includes
  `pdos_reskin.h`) only when it is set. A first version registered a hook from `pdos_profile.c`; that broke registry.py's
  include rule (present/dos includes no other present/ header but `present.h` and `profile.h`), so it was replaced.
* `present/dos/pdos_reskin.c`, `.h`: `pdos_reskin_bar_ext` and its full-width bar surface.
* `present/dos/pdos_profile.c`: the load palette at the first play state.
* `present/dos/pdos_seq.c`, `.h`: the last title choice.
* `present/dos/pdos_aplay.c`, `.h`: `palette_back` made `pdos_aplay_palette_back`.

None changes the core, the emulation or the Windows graphics; the DOS presentation's pixels change in windowless play
right of a narrow map window's bar, and after a load until the first report (P0: the core trace is unchanged).

## Tests (Checked, arm64)

The first full run on the fixes: 29 of 31 sections passed, G-1 `EXT_G1_OK runs 77`. Two failed:

* `d2_registry`: the include rule (the hook above); fixed.
* `ext_zoom`: the DOS goldens of the scenarios `load` and `orders` (both load CAE3540B.SAV from the title) at -1, at
  all five sizes (its report names the first differing sample, 25,000 ms); +1 and every other scenario equal. An
  x86_64 Checked copy with the load palette turned off reproduced the old golden (`723790de...`, 640 x 480, 25,000
  ms). The two copies' full 640 x 480 runs, every presented view compared: `load` 116 of 470 views differ, at most 47
  pixels each, all inside x 475..635, y 223..341 (the map's part that -1 adds right of the game's view): the fade into
  play and unit colours (for example DFDFDF to FFFFFF, 616DCA to 7D9EEF); `orders` 374 views, 2 pixels each, DFDFDF to
  FFFFFF only. These are colours of palette entries that DOS sets after a load (SP256.PAL under BACK<g><a|m>.PAL)
  instead of SP257.PIC's, until the first report as before. No view differs in geometry. `ext_zoom.py --update` wrote
  the goldens again: 60 lines changed, the dos `load` and `orders` samples at -1 of all five sizes; no other line.
* The second full run (after the include fix and the goldens): `TESTS_OK`, 31 sections, wall 970.8 s;
  `EXT_G1_OK runs 77` (its one recorded amendment, unchanged).

## Not covered

* A map window narrower than DOS's CIVILOPEDIA position (x < 240 DOS pixels): its title is drawn now, but a click right
  of the map window's bar still maps to the bar's last column (WL2's rule), which is then another DOS menu's zone.
* An in-game load (File > Load Game, not the title's): DOS's path after it was not traced in this unit.
* The CIVILOPEDIA drop-down in windowless play opens left of its title (under ADVISORS and WORLD, as before this
  unit); its place was not compared with DOS's.
* Bug 4 on screen, and bug 1 with the player's real keyboard: the user's check.

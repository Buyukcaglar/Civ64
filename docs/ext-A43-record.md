# Extension unit A43 (4:3 for DOS gameplay and the rename) - record

## Result

The Display submenu's 4:3 item is renamed "4:3 aspect ratio for 320 x 200 DOS intro screens" (its scope unchanged),
and a new check item "4:3 aspect ratio for 320 x 200 DOS gameplay" directly below it gives the whole DOS gameplay
presentation the 4:3 shape of the DOS screen: the menu bar, its drop-downs and texts, popups and boxes, the World Map,
the map, the Status window, the texts, every DOS game window, and the in-play full-screen DOS scenes (reports, city
screen, Civilopedia ...). The Windows graphics are unchanged; the game screen's size, the core and the input the game
receives are unchanged (P0). The setting is remembered (civ64.cfg key `aspect_play_4_3`, off by default) and
`--aspect` takes `square`, `4:3`, `gameplay` or `both`.

## Status

Staged in `build/a43-stage/` (session E5, extras implementer), on the WL stage's copies for the files WL changes
(WL lands first; rebase notes below). Overlay (tree + WL stage + A43 stage) built in Checked, CheckedNoObs and Release
with warnings as errors (the build's strict c11/c17/c99 checks of the portable sources included); every unit and
Win32-headless test passes in all three variants. Landed 2026-10-18 (see "Landing").

## The user's words

The user's request of 2026-10-17 (verbatim in `docs/verify/BRIEF-extras.md`, item 2): rename the item to
"4:3 aspect ratio for 320 x 200 DOS intro screens" and add "4:3 aspect ratio for 320 x 200 DOS gameplay" that "shall
apply 4:3 aspect ratio correction to all DOS gameplay graphics, including top Menu, menu items and their texts texts,
popups, World Map, Play Map, Status Window, Texts, all the DOS game windows". Menu placement: BRIEF-hm.md, last
section (both items in Display, replacing HM's "Correct 320 x 200 to 4:3").

## Design

* **The aspect is a bit set** (`present/scale.h`): `PRESENT_ASPECT_4_3` (1, the intro item, UX3's meaning: a 320x200
  frame gets the pixel aspect 6/5 outside play) and the new `PRESENT_ASPECT_PLAY` (2, the gameplay item: a frame of
  any size gets 6/5). The DOS gameplay's A frame is DOS art at 2x on the Windows layout, so stretching its rows by 6/5
  gives every DOS pixel the DOS screen's 4:3 shape, as a 320x200 picture on a 4:3 monitor (inferred: the DOS game
  draws 320x200 for a 4:3 display; civ64's own UX3 rule).
* **Layout** (`present_layout_compute`): the PLAY bit sets an/ad 6/5 for any frame. Under "Integer scaling" the 5 %
  whole pairs are searched as for UX3; a frame with no whole 6/5 pair (the game screen at its usual scales: 640x480 in
  1920x1080 has none) is laid out by fit with the current filter and recorded as fit, as F105 does for a frame larger
  than the client. Example: the 640x480 A frame in 1920x1080 is 1200x1080 at (360, 0); a 960x540 game screen
  1600x1080 at (160, 0).
* **Which frames** (`present.c present_layout_aspect`, new `PresentProfile.in_play`): while the visible profile is in
  play (`in_play()`; the DOS profile: `pdos_seq` core scene `PDOS_CS_PLAY`, from the setup's end GR_DialogClose ra
  11E0:0217 or a loaded game's start to the run's end) the gameplay item decides for every frame, the in-play 320x200
  scenes included (the brief's proposal: they are shown during play); otherwise UX3's rule with the intro item
  (320x200 frames, DOS Birth square). The Windows profile has no `in_play` (NULL): its frames are never changed.
  A change of `in_play` re-lays out at the next tick like a new frame size (UX3's mechanism).
* **What follows the shape:** the scaler, the client-to-frame mapping of the pointer and clicks (`present_map_point`
  through the view layout), the DOS pointer's factors (UX1's rule reads the visible layout's pixel aspect), the map
  zoom layer (`pmap_core_layout` lays the core's frame out with `present_layout_aspect`, so the zoomed map and its
  clip follow), and WL's windowless canvas (a frame of the DOS profile in play).
* **What does not:** the game screen's size (`present_game_screen`, `_follow`) and the Windows frame's layout for the
  pointer factors use the intro bit only, so the core's screen, window layout and input never depend on the item (P0).
* **Menu** (`host_win32.c`): Display's last two items "4:3 &aspect ratio for 320 x 200 DOS intro screens"
  (SC_CIV_ASPECT 0x1060, was HM's "&Correct 320 × 200 to 4:3") and "4:3 aspect ratio for 320 x 200 DOS &gameplay"
  (new SC_CIV_ASPECT_PLAY 0x1120; the id audit as WL's: ids 0x1010..0x1110 in use, 0x1030 retired). Each toggles its
  own bit; the new item's hook (`hw_set_aspect_play_hook`) then the settings hook. Without the observer (no DOS
  profile) the gameplay item is grayed and does nothing. Texts use "x" as the user wrote them (HM's U+00D7 leaves with
  the old text). Mnemonics a and g (c freed).
* **civ64:** `civ64_cfg_aspect_play` / `civ64_cfg_set_aspect_play` (key `aspect_play_4_3`, "1"/"0", written only after
  the player's menu choice, as UX3's key); `civ64_start_aspect` adds the bit when the key is "1"; `--aspect gameplay`
  and `--aspect both` (the harness takes the same values).

## Deviations

* F326: under "Integer scaling" the 4:3 DOS gameplay picture is laid out by fit (non-whole vertical steps, with the
  current filter) when no whole 6/5 pair fits, instead of falling back to square pixels as the intro item does.
* F327: the in-play full-screen DOS scenes (320x200) follow the gameplay item, not the intro item.
* F328: the game screen's size is not reduced for the 4:3 shape (P0: it depends only on the client and the intro
  bit); the 4:3 gameplay picture therefore fills the client's height with black bars at the sides.

## Tests

* `tests/test_present.c` `profiles_in_play` (new, 20 checks): the layout alone (640x480 PLAY integer -> fit 1200x1080,
  the intro bit alone square, 320x200 PLAY the 4x5 pair, 960x540 fit 1600x1080); through the facade with a test
  profile: in play the A frame square with the item off and 4:3 with it on (borders, image corners), client points map
  through the 4:3 layout, `present_layout_aspect` PLAY for any size, the game screen unchanged, out of play square at
  the next tick with one VIEW show, an in-play 320x200 screen follows the gameplay item and not the intro item, the
  Windows profile square under both bits. It cannot build on the base (the profile member and bit are new) and fails
  without the scale.c/present.c change.
* `tests/win32/test_host_win32.c`: the renamed text and the new item (texts, mnemonics a and g unique), Display's 10
  entries (WL's 9 + 1), the marks, the command toggling its own bit only, its hook before the settings hook, the intro
  item leaving the gameplay bit, grayed without the observer; the cfg key and `--aspect gameplay|both|square|wide`.
* `tests/test_input.c`, `present/profile_win.c`: the new member given explicitly (NULL).

## For the records

* DESIGN: 12.x (presentation, aspect): the bit set, `in_play`, `present_layout_aspect`, the fit fallback for PLAY,
  the game screen independent of it; 12.2 menu: the renamed item and the new item.
* FIDELITY: F326 .. F328 above.
* RUNNING: `--aspect square|4:3|gameplay|both`; the key `aspect_play_4_3`; Display's two 4:3 items.
* FEATURES: host row "4:3 for DOS gameplay" (both graphics: DOS only).
* DOS-PROFILE: the DOS profile's `in_play` (PDOS_CS_PLAY).

## What the user checks

Open the window menu (the icon at the left of civ64's title bar, or right-click the title bar) and its Display
submenu.

* **A43-1** Display's last two items read "4:3 aspect ratio for 320 x 200 DOS intro screens" (checked, as the old
  "Correct 320 × 200 to 4:3" was) and, directly below it, "4:3 aspect ratio for 320 x 200 DOS gameplay" (unchecked at
  first). The intro item behaves as before: the DOS intro, title menu and setup pages are 4:3 when it is checked.
* **A43-2** In DOS graphics, start or load a game and check "4:3 aspect ratio for 320 x 200 DOS gameplay": the whole
  game picture becomes taller and narrower at once (black bars at the sides): the menu bar and its drop-downs, the
  World Map, the map, the Status window, popups and dialogs all have the DOS screen's 4:3 shape; the DOS pointer is
  slightly taller. Uncheck it: the picture returns to square pixels at once.
* **A43-3** With the gameplay item checked, play a little: clicks and the pointer hit exactly what is under the
  pointer (menu items, map squares, World Map, buttons in dialogs); map zoom in and out (Ctrl+Shift+Plus/Minus) keeps
  the zoomed map in its window at the 4:3 shape.
* **A43-4** With the gameplay item checked, open a full-screen DOS screen during play (a report from the Advisors menu,
  a city screen, the Civilopedia): it is 4:3 too, even when the intro item is unchecked.
* **A43-5** Switch to Windows graphics (Ctrl+Shift+Backspace) with the gameplay item checked: the Windows graphics are
  unchanged (square pixels); switching back shows the 4:3 DOS gameplay again.
* **A43-6** Close civ64 with the gameplay item checked and start it again: the item is still checked and the DOS
  gameplay 4:3. Starting with `--aspect square` shows both items unchecked for that run only.

## Expected changes at the build slot

* Unit tests: test_present +18 checks (974 in the overlay with WL), test_input unchanged,
  test_host_win32 + about 11 (480 with WL; NoObs fewer: the grayed branch).
* No golden changes: the aspect bits keep every existing layout (PLAY is never set by existing tests or harness runs).
* P0 unchanged (no core call, no RNG; the game screen independent of the item). Coverage: present_layout_aspect,
  dos_in_play entered.

## Rebase notes

Bases: `BASE-SHA256.txt` (the tree's files when staged, 2026-10-18 20:50 UTC) and `BASE-WL-SHA256.txt` (the WL
stage's copies A43 started from). After WL lands, every file in BASE-WL-SHA256.txt is 3-way merged read-only
(`git merge-file -p a43 wl-stage-copy tree-after-WL`); files only in BASE-SHA256.txt are rechecked against the tree.

## Landing

A43 landed at the build slot of session E5 on 2026-10-18 after WL (build/wl-prep/LANDED.txt, RELEASE_OK 21:56:38 UTC).

* **Rebase:** WL's landed copies of the 12 shared files equal the WL stage copies A43 was built on (byte for byte), so
  the rebase was the BASE-SHA256.txt refresh only; the other 7 bases were unchanged.
* **Copy-in** 21:57:27 UTC (`build/a43-prep/land.py a43 --write`, 19 files; snapshot `build/a43-prep/tree-before`,
  `before`). The staged copies had CRLF line endings from the edit scripts (and harness_main.c LF): the first cycle
  was stopped in step 1 before anything compiled, `build/a43-prep/eol.py` gave every file its tree-before ending (LF;
  tests/headless/harness_main.c CRLF) in the stage and the tree, `landed.sha256` rewritten; content unchanged.
* **The cycle** (`build/a43-status.txt`, each step guarded by its log's OK marker): 1 `build.cmd checked` BUILD_OK
  21:59:10..22:02:41; 2 `test.cmd checked` TESTS_OK 22:02:41..22:34:28; 3 `ext_g1.py check` EXT_G1_OK runs 77
  (amended 1) unchanged: **ALL_GREEN** 22:34:29 UTC; 4 `build.cmd` (Release) BUILD_OK 22:34:29..22:37:55:
  **RELEASE_OK**.
* **Against the predictions** (`build/a43-prep/predictions.txt`): test_present 956 -> 974 (+18; predicted +20, the
  count of the new function's checks), test_host_win32 469 -> 480 (+11), test_input 698 unchanged; every other test,
  golden and harness section green as before.
* **User build** `build/user-builds/a43/` (22:40 UTC): the Release civ64.exe, CIVWIN.zip and civdos.zip from
  user-builds/d4, CAE3540B.SAV, WHAT-TO-CHECK.txt (A43-1..A43-6). FIDELITY numbers F326..F328 (WL holds F322..F325).
* Not done here: the docs pass ("For the records"), the checklist rows A43-1..A43-6 and STATUS (the orchestrator's).

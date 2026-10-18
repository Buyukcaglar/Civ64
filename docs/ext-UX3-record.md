# Extension unit UX3 (the menu texts "Integer scaling" and "4:3 aspect ratio for 320 x 200 screens"; 4:3 the default again, with the DOS intro, title box and Birth square) - record

Unit UX3 of the "civ64" extension carries out the user's direction of 2026-10-16 about 10:21 (STATUS.md "User
directions", row "2026-10-16 about 10:21"). Session E3, 2026-10-16. Staged in `build/ux3-stage/` (the
orchestrator's staging protocol, EXT-HANDOFF.md "Session E3"); bases taken 10:35:20 UTC.

Labels:

* **compiled**: `build.cmd checked`, `build.cmd checked noobs` and `build.cmd` (Release) of a private overlay
  (`build/ux3-stage/obj/src`: the tree's source folders with the stage over them, `obj/mkoverlay.py`), run with
  `--nogen` by `obj/b.cmd`: strict C17/x64 (`/W4 /WX /permissive- /fp:precise`), `/std:c11` and `/std:c17` and the
  clang-tidy C99 parse of every portable source, the test programs, the harness, civ64.exe and the Win32-headless
  tests; every output under the overlay's own `build/`.
* **headless**: the overlay's `test_*.exe` (test.cmd's `unit` loop, `obj/ut.cmd`), argv[1] `build/gamedata` (read),
  argv[2] under the stage.
* **Win32-headless**: the overlay's `w32_test_host_win32`, `w32_test_locate`, `w32_test_dos_host` (hidden windows,
  quiet mode), the same arguments.
* **harness**: the overlay's Checked `civ_harness.exe` on `build/gamedata` and `build/dosdata` (read), every run,
  output and script directory under the stage (`--exe`, `--root`, `--port`).

Scope: no DOS program was executed; nothing was written to `C:\Projects\Civ1RE\dos`, `C:\Projects\Civ1RE\original`,
`build/dosdata`, `build/gamedata`, `build/x64`, `build/harness` or any other shared output; build.cmd and test.cmd
of the tree were not run; civ64 was not launched and no UI was shown (hidden test windows only); no git command
that writes was run; nothing outside `C:\Projects\Civ1RE\claude` was read (the MSVC environment is set up by
`scripts\Setup-Msvc.cmd` as build.cmd does). Not edited: `core/`, `rt/`, `res/`, `platform/w16/`, `build.cmd`, the
generated tables and every document other than this record ("For the records").

## Status

**LANDED** 2026-10-16 (copied 11:41:57 UTC; the three-step cycle ALL_GREEN 12:04:47 UTC; Release 12:08:47 UTC;
user build `build/user-builds/ux3`; "Landing"). Staged as READY_TO_BUILD (compiled, headless, Win32-headless and
harness-tested privately in Checked, CheckedNoObs and Release), accepted by the orchestrator about 11:20 UTC with
the menu accelerators, the cfg rule, the intro reading and the switch points as recorded. All four items of the
direction are implemented: the two menu texts (items 1 and 2), 4:3 the default again with the new cfg rule (item
3), and the DOS-scene exemption with the title's three branches following the option (item 4). The user's checks
UX3-1..UX3-10 are pending (user build "ux3"); the docs pass ("For the records") is pending, one pass for D5K and
UX3.

## The user's words

STATUS.md "User directions", 2026-10-16 about 10:21 (Session E3), verbatim:

> 1. Rename "Scale by whole multiplies" host application context menu item to "Integer scaling" 2. Rename "4:3
> aspect for 320 x 200 pictures" to "4:3 aspect ratio for 320 x 200 screens" 3. "4:3 aspect ratio for 320 x 200
> screens" make default again 4. Intro, Title Menu and Birth-* scenes in DOS mode exempt from "4:3 aspect ratio
> for 320x200 screens" even if the option selected. But Title Menu has following exceptions; a. Customize World,
> Hall of Fame and Load a Game screens are affected by "4:3 aspect ratio for 320 x 200 screens" selected option.

## Decisions

1. **The menu texts and their mnemonics.** "Scale by &whole multiples" becomes "In&teger scaling", "4:3 &aspect
   for 320 x 200 pictures" becomes "4:3 &aspect ratio for 320 x 200 screens" (`host_win32.c` `add_menu`; the
   command ids 0x1010 and 0x1060 and every behaviour unchanged). Mnemonic of "Integer scaling": **t**, the first
   letter of the text that no civ64 item uses: I is "Zoom &in (double)"'s and n is "&Nearest-pixel filter"'s and
   "&Normal map zoom"'s (and the system's Minimize); the old W was shared with "&Windows graphics" since D3b2
   (ext-D3b2-record.md, A 11), which UX3 thereby ends. The aspect item keeps **a** (no other item). Every place
   that quotes the texts in code was updated (the menu, the comments of `host_win32.c` and `civ64_cfg.h`, the w32
   test's comments); civ64 has no command-line help that lists them; the documents are "For the records".
2. **The cfg rule: a new key `aspect_4_3`, written only after the player's menu choice.** `civ64.cfg` is written by
   `save_settings` (civ64_main.c, the back end's settings hook) at every presentation change by the player and at
   every exit (F111), from the current state; so every earlier build stored its aspect key whether or not the
   player ever chose it (`aspect`, D3b1..UX2: mostly 4:3; `aspect_320x200`, UX2: mostly square). UX3:
   * the key `aspect_4_3` (`1` the item checked, `0` unchecked; anything else reads as absent) is written only
     when the player changed the item through the system menu in that run: the back end calls the new aspect hook
     (`hw_set_aspect_hook`) with the item's new state for that command only, before the settings hook;
     civ64_main.c keeps it (`g_aspect_chosen`, -1 until a choice) and `save_settings` passes it to
     `civ64_cfg_set_aspect`, which writes `aspect_4_3` for 0 or 1 and leaves an existing `aspect_4_3` as it is for
     -1;
   * `--aspect 4:3|square` sets the run only and is never written (as `--graphics`); the start's order is
     `--aspect`, else `aspect_4_3`, else 4:3 (`civ64_start_aspect`);
   * neither old key is ever read, and `civ64_cfg_set_aspect` removes both at every save;
   * the one-time cost (accepted): a player who deliberately chose square in build ux2 sees 4:3 once and unchecks
     the item again (then `aspect_4_3=0` is remembered). A run without a menu change keeps whatever `aspect_4_3`
     the file has.
   DESIGN.md 12.2's pre-existing gap ("The command line wins for the run and is not written", while `scale_mode`,
   `filter` and `fullscreen` are written from the current state at every save, so their command-line values are
   written) is now closed for the aspect only; `scale_mode`, `filter` and `fullscreen` are unchanged (the same fix
   for them would need three more hooks and keys and changes behaviour the user has not asked about; noted under
   "For the records").
3. **The intro (the orchestrator's reading, recorded).** "Intro" is the DOS start-up sequence before the title box:
   the black before the intro movie (scene BOOT, from `RunIntroAndTitleMenu`'s entry and before it), the credits,
   the intro panorama and the logo/title reveal (scene INTRO), including a logo held on black after a preselecting
   key (`PDOS_TB_HOLD`). "Title Menu" is the DOS title box (the menu over the title picture) from its first draw
   (R:01A8:0494) through the chosen row that stays to Start a New Game's or Play on EARTH's outro (the box stays
   until Birth's first picture). "Birth-*" is DOS Birth: its story, its end fade and the black hold, up to the
   setup page at the hand-over R:01A8:087C.
4. **One predicate, in the DOS sequencer.** `pdos_seq_square_scene()` (pdos_seq.c; the DOS profile's new
   `square_only` callback, profile.h) is 1, square whatever the option, while:
   * the Birth view is on and the setup page is not yet shown (`g_bview && !pdos_setup_shown()`), or
   * the scene is BOOT, or
   * the intro view is on (`g_view`), no title branch's screen is up (`g_ux3_branch` 0), and the scene is INTRO,
     TITLE, CUSTOM (before dialog 143's transition) or OUTRO;

   else 0: the option applies. `g_ux3_branch` is set at a title branch's start (LoadGameFromFileDialog's entry,
   ShowHallOfFame's entry from the title, dialog 143's open when its transition starts) and cleared when the title
   box is drawn (`tb_show`: R:01A8:0494 and the redraw R:01A8:0807), at the intro's start, at Birth's start and at
   the reset. Every scene not named here (LOAD, HOF, SETUP, PLAY and any scene added later, such as unit SL's DOS
   Load/Save slot screens or the play screens of D6) follows the option by default. The Windows profile has no
   `square_only` (NULL): it shows no 320x200 frame.
5. **Where each switch happens** (the state the predicate is keyed on; the new layout is drawn at the next
   presentation tick, at most one tick period later, ext_aspect.py measures it):

   | transition | the screen | switch at | keyed on |
   |---|---|---|---|
   | start-up: black, credits, panorama, logo, title box | square | - | scene BOOT, then INTRO/TITLE with the intro view |
   | title -> Customize World | the title screen stays square while CustomizeWorldDialog waits for dialog 143 (`PDOS_CU_WAIT`); 4:3 from the transition's start (fade to black, CUSTOM.PIC, the questions, the help screen) | dialog 143's open (GR_DialogOpen exit ra 1108:0290; the transition R:01A8:0591 starts there) | `pdos_custom_open` -> `PDOS_CU_FADE`, `g_ux3_branch` 1 |
   | Customize Cancel -> title | the Customize screen stays 4:3 until the box is drawn over it, then square | the title box's redraw R:01A8:0807 (dialog 139's GR_DialogOpen exit ra 11E0:06C5, `title_again`) | `tb_show` clears `g_ux3_branch` |
   | Customize OK -> outro -> Birth | 4:3 through the outro (the Customize screen stays); square from Birth's start (its first picture fades in over the Customize screen, square) | SeekSequence ra 11E0:01AA (`birth_start`) | `g_bview` 1, `g_ux3_branch` 0 |
   | title -> Hall of Fame | 4:3 from the moment it is drawn | ShowHallOfFame's entry ra 11E0:0847 (`pdos_fame_open` draws it there) | scene HOF, `g_ux3_branch` 1 |
   | Hall of Fame -> title | the Hall of Fame picture stays (R:01A8:0807 draws the box over it); 4:3 until the box is drawn, square from then (the title menu again, its background still the Hall of Fame's) | the redraw R:01A8:0807 | `tb_show` |
   | title -> Load a Game | 4:3 from LoadGameFromFileDialog's entry ra 11E0:0807 (unit SL's slot screens follow; until SL lands the title screen behind the host's file chooser turns 4:3) | its entry | scene LOAD, `g_ux3_branch` 1 |
   | Load cancelled -> title | 4:3 until the box is drawn, then square | the redraw R:01A8:0807 | `tb_show` |
   | a game loaded -> play | 4:3 (the colour-7 fill, play) | - | scenes LOAD, PLAY |
   | Start a New Game / Play on EARTH -> outro -> Birth | square throughout (the box stays until Birth's first picture) | - | TITLE/OUTRO with the intro view, then the Birth view |
   | Birth -> setup | square through the end fade and the black hold; 4:3 from the setup page | the hand-over R:01A8:087C (the page is drawn at that instant, `pdos_setup_handover`) | `pdos_setup_shown()` |
   | setup pages, name pages, introduction text (dialog 151), play, the end game's Hall of Fame (row 105) | 4:3 | - | scenes SETUP, PLAY |

   The redraw is the switch point back because that is where the DOS screen becomes the title menu again;
   switching at the branch's exit instead would show the branch's picture square for the moment before the box.
6. **The relayout.** `present.c` lays a 320x200 frame out at 4:3 only when the option is on and the visible
   profile's `square_only` gives 0 (`frame_aspect`); the layout remembers the pixel aspect it was made with, and a
   change re-lays out exactly like a change of the frame's size (A-B6): at the next tick (5a) the whole client is
   drawn again, borders included (no stale letterbox), and the cursor is issued again at the new layout's factors
   (`present_pointer_factors`); a core-frame profile does the same at its core present. The mapping of host points
   (`present_view_point`, then the N canvas point to the DOS device in `pdos_mouse`, which is layout-independent)
   always uses the shown layout, so it is right under both shapes and between a predicate change and the tick
   (the old layout is still on screen then). When the new pixel aspect gives the same picture (an integer client
   with no whole 6/5 pair, such as 640x480: the 2x2 image at 0,40 either way) the layout only takes the new aspect
   and nothing is drawn again; this keeps every 640x480 harness output byte-identical (Results).
7. **The harness default follows civ64 again** (`o.aspect = PRESENT_ASPECT_4_3`), as from D3b1 to UX2. Its
   `--presented 2` (new; `1` unchanged) adds the layout to each show line and the pointer factors to each cursor
   line, which the new check reads.

## What was built

### Staged files

Full copies under `build/ux3-stage/` at the tree's paths, each with its base's line endings (the tree's files are
mixed: LF for the Win32, present and test sources below, CRLF for `present/dos/*`, the harness sources and
`test.cmd`); bases in `BASE-SHA256.txt`, the staged copies' hashes in `STAGED-SHA256.txt`. Two new files (LF).
Every change sits in a block or line marked "extension UX3".

| file | change |
|---|---|
| `platform/win32/host_win32.h` | `hw_set_aspect_hook` (new) |
| `platform/win32/host_win32.c` | header paragraph; `g_aspect_hook`; `add_menu`: the two texts and their comment; `hw_set_aspect_hook` after `hw_set_wheel_hook`; `civ_command`: the hook called for `SC_CIV_ASPECT` before the settings hook |
| `win64/civ64_cfg.h`, `civ64_cfg.c` | UX3 block: `civ64_cfg_aspect` reads `aspect_4_3`; `civ64_cfg_set_aspect(c, chosen)` removes `aspect` and `aspect_320x200`, writes `aspect_4_3` for 0/1, nothing for -1 |
| `win64/civ64_start.h`, `civ64_start.c` | `civ64_start_aspect`: `--aspect`, else `aspect_4_3`, else 4:3; comments |
| `win64/civ64_main.c` | header comment; `g_aspect_chosen`; `save_settings` through `civ64_cfg_set_aspect(&g_cfg, g_aspect_chosen)`; `aspect_chosen` (the hook); `hw_set_aspect_hook(aspect_chosen)` after `hw_set_wheel_hook`; the start's comment |
| `present/profile.h` | `PresentProfile.square_only` (new last member) |
| `present/profile_win.c` | its initializer: `NULL` |
| `present/present.c` | `g_lay_aspect`; UX3 block `frame_aspect`, `relayout_due`; `relayout` with `frame_aspect`; `present_core_frame`'s and the tick's 5a re-layout through `relayout_due`; `present_reset` |
| `present/dos/pdos_profile.c` | UX3 block `dos_square_only`; the initializer's last member |
| `present/dos/pdos_seq.h` | UX3 block: `pdos_seq_square_scene` |
| `present/dos/pdos_seq.c` | UX3 block `g_ux3_branch`; set at SR_LOAD's and SR_HOF's entries and after `pdos_custom_open` (FADE); cleared in `tb_show`, `intro_start`, `birth_start`, `pdos_seq_reset`; UX3 block `pdos_seq_square_scene` |
| `tests/headless/harness_main.c` | the `--aspect` default 4:3; `--presented 2`; the header comment |
| `tests/headless/harness.c` | UX3 block `layout_fields` (`--presented 2`); `cursor_line`'s factors; `g_presented_level` |
| `tests/test_present.c` | the test profile's `square_only` (`g_t_square`); UX3 block `profiles_square_only` and its call |
| `tests/win32/test_host_win32.c` | the w32 test profile's `square_only`; `test_ux2`'s aspect checks removed (its comment says so); UX3 block `test_ux3` and its call after `test_ux2` |
| `test.cmd` | the section `ux3_aspect` (two UX3 blocks; `BUILD-TEST-ADDITIONS.md`) |
| `tests/test_pdos_aspect.c` (new) | the predicate along the DOS flows and through the present layer |
| `tests/harness/ext_aspect.py` (new) | the harness check |

## Tests

* **`tests/test_pdos_aspect.c`** (new, 61 checks, every variant; the DOS store from `build/dosdata` as
  `test_pdos_seq`): through the DOS profile's callbacks with synthetic probes (`tests/pdos_obs.h`):
  * the start-up square at every tick: the reset (BOOT), RunIntroAndTitleMenu, the intro's start, every tick of
    the credits, panorama, logo and title box to 75 s, dialog 139 open;
  * Start a New Game: chosen, the outro, Birth's start, its story, the world, the skip and the core's Birth end all
    square at every tick; the setup entered during Birth's end fade still square; exactly one change, to 4:3, and
    only with the setup page shown (the hand-over); play and the end game's Hall of Fame 4:3;
  * Play on EARTH: its outro and Birth square;
  * the branches: View Hall of Fame chosen (square), ShowHallOfFame's entry 4:3, its exit (TITLE, the screen
    kept) still 4:3, the box redrawn square; Customize: CustomizeWorldDialog's entry square (`PDOS_CU_WAIT`),
    dialog 143's open 4:3 (`PDOS_CU_FADE`), the transition and questions 4:3 at every tick, Customize not
    confirmed (TITLE) 4:3, the box redrawn square; Load: chosen square, the entry 4:3, cancelled (TITLE) 4:3, the
    box redrawn square; Customize confirmed: 4:3 through its outro, Birth square; a game loaded: the fill and play
    4:3; a reset square again;
  * through the present layer (1920x1080, integer, 4:3; the DOS profile registered): the title box's N frame
    square 5x5 at 160,40; the Hall of Fame pixel 6/5, 4x5, 1280x1000 at 320,40; kept after its exit; the box redrawn
    square 5x5; the square option: the Hall of Fame square too.
* **`tests/test_present.c`** `profiles_square_only` (26 new checks; 925 -> 951): the test profile's `square_only`
  never read under the square option; under 4:3 square_only 1 keeps 5x5 at 1920x1080 (mapping, pointer 4x4, the
  image's extent); square_only 1 -> 0 with no frame change: one VIEW show and the cursor issued again, 4x5 at
  320,40, the old image's sides black (no stale letterbox), the image at 4x5, the client points mapped through
  4x5 (a point left of the new image outside), the pointer 3x4; no change, no show; back to square: one VIEW show,
  the cursor, the sides image again, the pointer 4x4; the square option: no show, not read; 640x480 integer: no
  show and no cursor at a change (2x2 at 0,40 either way), the layout's aspect following; 640x480 fit: 640x400 at
  0,40 and 640x480 at 0,0, a VIEW show, the bottom row mapped to row 199; a 640x480 frame never reads it; the
  Windows profile's frame square and the hidden profile's `square_only` not read.
* **`tests/win32/test_host_win32.c`** `test_ux3` (32 checks; `test_ux2`'s 14 aspect checks removed: 311 -> 329 in
  Checked and Release, 296 -> 314 in CheckedNoObs): the default 4:3 (no `--aspect`, no file); `aspect=square` and
  `aspect_320x200=square` not read (4:3); a save without a choice removes both and writes no `aspect_4_3`, the
  other keys kept; the player's square written (`aspect_4_3=0`) and read back; a later save without a choice keeps
  it; the player's 4:3 written and read back (`aspect_4_3=1`); only `aspect_4_3` counts against both old keys;
  `--aspect 4:3` over a remembered square and `--aspect square` over a remembered 4:3; six invalid values (`2`,
  empty, `4:3`, `square`, ` 1`, `01`) read as absent (4:3); the menu's texts by command (0x1010 "In&teger
  scaling", 0x1060 "4:3 &aspect ratio for 320 x 200 screens") and the mnemonics t and a unique among civ64's items,
  w only "Windows graphics"'; `hw_set_presentation` never calls the aspect hook; the 4:3 item unchecked and checked
  again: the hook with 0, then 1, before the settings hook, the mark following; the scaling and filter items call
  the settings hook only; on the hidden window, fit at 1280x960 under 4:3 with the test profile: square_only 1
  square 1280x800 at 0,80, the pointer made at 3x3 (hot spot (3,6), 9x9) and the client point (100,100) arriving
  as (25,5); square_only 0 re-laid out at the tick to 1280x960, the pointer made again at 3x4 (hot spot (3,8),
  9x12) and the same point arriving as (25,20); back: 3x3 and (25,5).
* **`tests/harness/ext_aspect.py`** (new; test.cmd section `ux3_aspect`, Checked): six harness runs, the DOS
  profile from the start, DOS-form host keys (X ends the intro at 1 s): `fame` (View Hall of Fame and back, Load
  cancelled, Start a New Game, the Birth skip, the setup page) and `custom` (Customize World, four Returns, Birth,
  the setup page) at 1920x1080 with `--presented 2` and the default 4:3; `fame_sq` and `custom_sq` with
  `--aspect square`; `fame640` and `fame640_sq` at 640x480 with `--presented 1`. Checks: the flows reached their
  steps; every 320x200 show square or 4:3 as the timeline's switch points say (Decision 5; at a switch only shows
  within three tick periods may keep the old layout; each 4:3 span has a 4:3 show; Load's span, which the harness
  cancels at once, is reported); every other show (the 640x480 A frame) square; every DOS pointer made at the
  shown layout's `present_pointer_factors` (recomputed in Python from scale.c's formulas); the square runs square
  throughout; P0: the core outputs (run.log frame/snapshot/result lines, events.log, coreinput.log) and exit
  status of the 4:3 and square runs equal; presented.log byte-identical at 640x480 under both.

The existing tests are unchanged and pass (`test_pdos_seq` 190, every other program as at the tree's last Checked
run; Results).

## Results

Private, 2026-10-16 10:55..11:15 UTC (Istanbul time is UTC+3); the overlay's bases equal the tree's
(`BASE-SHA256.txt`, re-verified before and after).

| variant | build (`obj/b.cmd`, build.cmd `--nogen`) | headless + Win32-headless (`obj/ut.cmd`) |
|---|---|---|
| Checked | `BUILD_OK` 11:00:24 UTC; portable sources checked: 291 (c11, c17, c99 parse) | 0 failed of 50 programs: `test_present` 951, `test_pdos_aspect` 61, `w32_test_host_win32` 329, every other count equal to the tree's `build/test/Checked/sections/unit.log` (13:05 local) |
| CheckedNoObs | `BUILD_OK` 11:04:44 UTC; 291 | 0 failed of 50 programs: `test_present` 951, `test_pdos_aspect` 61, `w32_test_host_win32` 314 |
| Release | `BUILD_OK` 11:04:37 UTC; 291 | 0 failed of 50 programs: `test_present` 951, `test_pdos_aspect` 61, `w32_test_host_win32` 329 |

Harness (Checked):

* `ext_aspect.py Checked --exe <overlay> --root obj/hr --port <port>`: **`EXT_ASPECT_OK`** (16 checks; 4.6 s wall on an idle machine, 12.3 s in a rerun beside other units' work; output `obj/chk-ext-aspect.txt`).
  `fame`: switches square@0, 4:3@5,502,100 us (the Hall of Fame), square@8,001,100 (the redraw), Load
  11,501,700..11,501,700 (one 4:3 show, then the redraw at the same virtual time: the harness cancels the file
  dialog at once), 4:3@24,596,282 (the setup page); 341 shows, 0 wrong; 12 pointers at 3x3 (the first A frame),
  4x4 and 3x4. `custom`: square@0, 4:3@5,502,100 (dialog 143, R:01A8:0591), square@11,757,150 (Birth after the
  outro at 11,001,100), 4:3@21,575,382 (the setup page; its VIEW show at 21,576,350, the next tick); 372 shows, 0
  wrong. P0: `fame`, `fame_sq`, `fame640`, `fame640_sq` equal (249 frame lines); `custom`, `custom_sq` equal (241).
  `fame640` and `fame640_sq`: presented.log byte-identical (47,326 bytes).
* UX2's differential again, with the default 4:3 (`obj/hr/aspect_diff.py`, `aspect_diff.txt`): the overlay's
  harness without `--aspect` against `--aspect square`, DOS profile, `--presented 1 --profile-samples 100`: p0's
  `start` (30 s) at 640x480, at 1920x1080 and at 1920x1080 fit, and p4's `birth` (205 s) at 640x480: all eleven
  output files equal (run.log without its first line, which names the run directory). p4's `birth` at 1920x1080:
  equal except presented.log, which has one more show (3,051 lines against 3,050): the VIEW show at 172,398,650 us
  where DOS Birth's hand-over draws the setup page and the layout becomes 4:3 (UX3's intended change; the frame
  hashes are equal); every other file equal, so the core is untouched (P0).
* The tree's harness checks with the overlay's harness (`--exe`, `--root obj/hr2`): `ext_timeline.py Checked`:
  `EXT_TIMELINE_OK` (41 PASS, 0 FAIL; its custom run: every show from the title choice on is the 320x200 N frame, 187 shows); `ext_continue.py Checked`: `EXT_CONTINUE_OK` (31 PASS, 0 FAIL).

The compiled overlay's C sources equal the staged files up to line endings (`STAGED-SHA256.txt`; the five CRLF
C files were given back their bases' CRLF after the builds, `obj/eol.py restore`); `ext_aspect.py` and `testpar.py`
ran on the staged script and `test.cmd` themselves.

Other checks test.cmd runs, privately: `tests/harness/obs_lint.py` on the overlay: `OBS_LINT_OK files 115 probes
203 callsites 98`; `gen/dos/registry.py check` (the tree's; UX3 changes none of its inputs, and the include rule's
files `present/dos/pdos_seq.c/h`, `pdos_profile.c` keep their includes, checked by diff): `REGISTRY_OK`;
`gen/dos/nodos.py check --root <overlay> --variant V` for Checked, CheckedNoObs and Release: `NODOS_OK` each (0 hits); `tests/harness/testpar.py check
build/ux3-stage/test.cmd`: exit 0 (no problem), `list`: `ux3_aspect after=- cpu=6 est=20`.

## Expected expectation changes

**None beyond the new tests.** Changes: `test_present` 925 -> 951, the new `test_pdos_aspect` (61),
`w32_test_host_win32` 311 -> 329 (Checked, Release) and 296 -> 314 (CheckedNoObs), the new section `ux3_aspect`
(`EXT_ASPECT_OK`).

Where the default and the exemption could matter (each checked):

* The aspect acts only on 320x200 frames, which only the DOS profile shows. G-1 (`ext_g1.py`) and P0 (`ext_p0.py`
  V0..V8s) compare the core only; V3 cycles `policy fit sharp 4:3` itself; V6w (1920x1080, DOS, switches) compares
  the core and the game screen, which a 640x480 layout decides (no 320x200 frame).
* presented.log, profiles.log samples, timeline.log and the dumps hash logical frames before scaling. The only
  run-visible difference the default makes is a VIEW show at a pixel-aspect switch, and only where 4:3 changes the
  picture: every test.cmd harness run with the DOS profile runs at the default host 640x480 under integer scaling,
  where 4:3 and square give the same 2x2 image, so no show is added (`fame640`/`fame640_sq` byte-identical,
  `aspect_diff.txt` 640x480 runs equal); the runs at other sizes (ext_adapt's M runs 1920x1440, ext_zoom, ext_p0 V4)
  show the Windows profile only; V6w compares the core only. The goldens `ext-timeline-golden.txt` and
  `ext-zoom-golden.txt` hash logical frames (timeline) and the Windows profile's view (zoom).
* `ext_adapt`'s DOS-form host scripts map host points at 640x480 (`n_host`: 2x2 at 0,40), the same under both
  aspects.
* `test_present`'s other tests and the unit tests name their aspect; `w32_test_host_win32`'s `test_window_s2`
  toggles the item from the present layer's own state (the aspect hook is not set there).

Predictions for the build slot: `build.cmd checked` BUILD_OK (portable sources checked: 291, unchanged; one new
test program); `test.cmd checked` TESTS_OK with the counts above, `EXT_ASPECT_OK`, every other section as at the
last gate; `ext_g1.py check` `EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)` (unchanged). At the next
phase gate: CheckedNoObs 314 and Release 329 for `w32_test_host_win32`; `test_present` 951 and `test_pdos_aspect`
61 in every variant.

## Rebase notes

Shared files and UX3's blocks in them (each marked "extension UX3"; re-apply onto a newer tree copy as listed):

* `platform/win32/host_win32.c`: the header paragraph; `g_aspect_hook` (after the other hooks' statics); the two
  menu texts and their comment in `add_menu`; `hw_set_aspect_hook` after `hw_set_wheel_hook`; three lines in
  `civ_command` after `hw_set_presentation`. `host_win32.h`: the declaration after `hw_set_wheel_hook`'s.
* `win64/civ64_cfg.h/.c`, `civ64_start.h/.c`, `civ64_main.c`: the UX3 blocks and lines listed above (the UX2 aspect
  lines they replace are gone).
* `present/profile.h`: the new last member `square_only`. **Every `PresentProfile` initializer must list it** (or
  leave it out only in test files compiled by cl alone): `profile_win.c` (`NULL`), `pdos_profile.c`
  (`dos_square_only`), `tests/test_present.c` (`t_square_only`), `tests/win32/test_host_win32.c`
  (`w32_square_only`); `tests/test_input.c` keeps its 13-member positional initializer (the member is NULL; cl
  does not warn). A unit that adds a member after UX3 adds it after `square_only`.
* `present/present.c`: `g_lay_aspect`; the UX3 block before `relayout`; `relayout`'s three changed lines; the two
  `relayout_due` calls (`present_core_frame`, tick step 5a) and their comments; `present_reset`'s line. D6c's
  landed `present/map/*` and `pdos_compose.*` are not touched.
* `present/dos/pdos_profile.c`: the UX3 block after `pdos_profile_bs_active` and the initializer's last line.
  (SL may stage this file: keep both units' blocks.)
* `present/dos/pdos_seq.c/.h` (D5K and SL may stage them): the `g_ux3_branch` block after `AC_CH`; one line each in
  `tb_show`, `intro_start`, `birth_start`, `pdos_seq_reset`, `on_enter`'s SR_LOAD and SR_HOF branches, and
  `on_exit`'s SR_CUSTOM_DLG branch (after `pdos_custom_open`); the `pdos_seq_square_scene` block before
  `pdos_seq_birth_view`; the header's block before "state (tests, D4b2b2)". **A new DOS scene or branch needs
  nothing**: it follows the option unless it is added to the predicate's square list; SL's slot screens under
  LOAD (and in play) follow it as the user asked. If SL changes Load's scene handling, keep `g_ux3_branch = 1u` at
  Load's entry.
* `tests/headless/harness_main.c`, `harness.c`: the default, `--presented 2`, the UX3 block before `shown`, the
  lines in `shown`, `cursor_line` and the presented setup.
* `tests/test_present.c`, `tests/win32/test_host_win32.c`, `test.cmd`: the blocks above (`BUILD-TEST-ADDITIONS.md`).

## Build-slot steps

1. From the port root: `sha256sum -c build/ux3-stage/BASE-SHA256.txt` (18 files). Any base that changed since
   10:35:20 UTC: re-apply UX3's blocks onto the tree's copy ("Rebase notes"), keeping the file's line endings,
   and recompile privately (`build/ux3-stage/obj/mkoverlay.py`, `obj/b.cmd src checked`, `obj/ut.cmd src
   Checked`) before going on.
2. Copy the 18 staged files and the two new files into the tree at the same paths (`STAGED-SHA256.txt` has all 20);
   record their hashes in `build/ux3-stage/COPIED-SHA256.txt`; copy this record to `docs/ext-UX3-record.md`. No
   build.cmd change, no registry change.
3. The three-step cycle: `build.cmd checked`, `test.cmd checked`, `C:/Python314/python -B tests/harness/ext_g1.py
   check`, with the predictions above.
4. A user build (Release, the scheme of `build/user-builds/ux2`) with `WHAT-TO-CHECK.txt` from "What the user
   checks" (including the one-time reset of a square chosen in build ux2); the docs pass applies "For the records".

## What the user checks

New items for `manual-checklist-ext.md` (section UX3). The 4:3 shape shows only where the window can hold it: under
"Integer scaling" in a window of the minimum size (640x480 inside) 4:3 and square look the same; use a larger
window, full screen or "Scale to fit".

* **UX3-1** (items 1, 2): the window menu (the icon at the left of the title bar, or Alt+Space) shows "Integer
  scaling" (was "Scale by whole multiples") and "4:3 aspect ratio for 320 x 200 screens" (was "4:3 aspect for 320
  x 200 pictures"), with t and a underlined; Alt+Space, then t or a, chooses them; "Windows graphics" is now the
  only item with W.
* **UX3-2** (item 3): with no remembered choice, the 4:3 item is checked at start. A `civ64.cfg` from an earlier
  build (its `aspect` or `aspect_320x200` line) is ignored: the first start of the UX3 build shows 4:3 even if you
  chose square in build ux2 (uncheck the item once; then it is remembered). Starting with `--aspect square` or
  `--aspect 4:3` changes only that run and is not remembered.
* **UX3-3** (item 4): in DOS graphics with the 4:3 item checked, the start-up (the black, the credits, the intro
  panorama, the logo and title reveal), the title menu, and Start a New Game or Play on EARTH through the whole
  Birth, including its end fade and the black before the first setup page, have square pixels: they look as with
  the item unchecked.
* **UX3-4** (4.a, Customize World): choose Customize World: the screen takes the 4:3 shape as the fade to black
  begins; the four questions and the help screen are 4:3; Cancel: the screen goes back to square when the title
  menu's box is drawn again; OK: the Customize screen stays 4:3 until Birth's first picture, then square.
* **UX3-5** (4.a, Hall of Fame): View Hall of Fame: 4:3 from when it appears; leaving it, the menu box is drawn
  over the Hall of Fame picture and from that moment everything is square (the title menu).
* **UX3-6** (4.a, Load a Game): Load a Game: 4:3 from its start (with the DOS slot screens of unit SL when they are
  in the build; before that the title picture behind Windows' file chooser turns 4:3); cancelled: square again
  when the menu box is drawn; a game loaded: 4:3 from then on.
* **UX3-7**: after Birth the setup pages (difficulty, competition, tribe), the name pages, the introduction text
  and play, and the Hall of Fame at a game's end, are 4:3.
* **UX3-8**: at each change of shape the whole window is redrawn: no black bars or picture remnants of the other
  shape stay; the pointer keeps pointing at what it shows (choose menu rows and question rows with the mouse right
  after a change); the DOS pointer is a little narrower in the 4:3 shape at large sizes.
* **UX3-9**: uncheck the item: every DOS screen is square, and it is remembered at the next start; check it again:
  4:3 (with the exemptions) is remembered.
* **UX3-10**: Windows graphics look exactly as before under either setting.

## For the records

Wording changes for the docs pass (not edited by UX3):

* **FIDELITY.md F116** (line 176): append "**Superseded again by UX3** (2026-10-16, the user's direction of about
  10:21: "4:3 aspect ratio for 320 x 200 screens make default again" and the exemption of the DOS intro, title menu
  and Birth; `ext-UX3-record.md`): the default for 320x200 frames is 4:3 again, in civ64 (`civ64_start_aspect`:
  `--aspect` when given, else `aspect_4_3`, else 4:3) and in the harness (`o.aspect = PRESENT_ASPECT_4_3`); with
  the DOS graphics the DOS intro (the black before it, the credits, the panorama, the logo and title reveal), the
  DOS title box and DOS Birth (to the setup page) keep square pixels whatever the option (`PresentProfile.
  square_only`, `pdos_seq_square_scene`), while every other 320x200 DOS screen follows it: Customize World from its
  transition, the Hall of Fame, Load (unit SL's slot screens), the setup and name pages, the introduction text and
  play (**choice**, the record's decisions 3..5; the switch points in decision 5). The remembered key is now
  `aspect_4_3` (`1`/`0`), written only when the player changes the item in the system menu during the run;
  `--aspect` is for its run only and never written; the keys `aspect` and `aspect_320x200` are not read and are
  removed at the next save (a deliberate square choice made in build ux2 comes back as 4:3 once; decision 2). The
  Windows profile is unchanged. Status: implemented in UX3; user checks UX3-2..UX3-10" (with the landing's
  cycle); the reference column: `win64/civ64_start.c civ64_start_aspect`, `win64/civ64_cfg.c`,
  `present/present.c frame_aspect`, `present/dos/pdos_seq.c pdos_seq_square_scene`, `tests/headless/
  harness_main.c`; the last column adds UX3. Line 166's list needs no change.
* **manual-checklist-ext.md**: UX2-5 and UX2-6: "superseded ... unit UX3, not yet landed; no user build yet" ->
  "superseded by UX3 (4:3 the default again; the DOS intro, title box and Birth square; checks UX3-2 and UX3-3;
  the one-time reset is UX3-2's)"; D4-1's last cell: add "reversed again by UX3 (4:3 the default again, with the
  start-up screens, the title menu and Birth always square: UX3-3)"; D3-10: "the aspect default (square since
  UX2; 4:3 under X3 when the user passed this item)" -> "the aspect default (4:3 again since UX3; square from UX2
  to UX3; 4:3 under X3 when the user passed this item)"; the header's list: "so are UX3-1..UX3-10 (record
  `ext-UX3-record.md`, the menu texts and the 4:3 aspect rule; tested headless, Win32-headless and in the harness;
  see section UX3 for the user build)"; a new section "UX3: the menu texts; 4:3 the default again with the DOS
  intro, title box and Birth square" with UX3-1..UX3-10 ("What the user checks"), and in the counts paragraph
  (line 361) UX3's 10 pending and UX2-5/UX2-6 superseded by UX3.
* **RUNNING.md**: line 254 (the harness's `--aspect`) "Default `square` (UX2; 4:3 was the default from D3 to UX2,
  X3)" -> "Default `4:3` (UX3, as from D3 to UX2, X3; `square` under UX2); only 320x200 frames are affected, and
  with the DOS profile not its intro, title box and Birth"; a `--presented 2` note at `--presented`'s row: "2 also
  writes ` layout SWxSH at OX,OY pixel AN/AD` on every show line and ` factors KXxKY` on every cursor line (UX3)";
  line 431 (civ64's `--aspect`) -> "For 320x200 screens (the DOS profile): the 4:3 shape of the DOS screen or
  square pixels, for this run only (not remembered). Without it: your choice in the window menu, else `4:3`
  (since UX3; square under UX2). Your menu choice is remembered as the `aspect_4_3` key of `civ64.cfg` (written
  only when you change the item); the `aspect` and `aspect_320x200` lines of earlier builds are ignored and removed
  at the next save. With the DOS graphics the intro, the title menu and Birth keep square pixels under 4:3;
  Customize World, the Hall of Fame, Load, the setup pages and play take the 4:3 shape (UX3). Pictures of other
  sizes, including everything the Windows profile shows, keep square pixels (F116)"; lines 437..438 (the window
  menu) "scale by whole multiples or to fit; ...; the 4:3 aspect for 320x200 pictures (off by default)" -> "Integer
  scaling or Scale to fit; ...; 4:3 aspect ratio for 320 x 200 screens (on by default; the DOS intro, title menu
  and Birth stay square)"; line 107 (the `w32_test_host_win32` row) add "since UX3 `test_ux3`: the 4:3 default, the
  `aspect_4_3` key (written only after the menu's choice), the old keys `aspect` and `aspect_320x200` ignored and
  removed, the menu texts and mnemonics, the aspect hook, a profile's `square_only` through the window (the mouse
  points and the pointer under both shapes); `test_ux2`'s aspect checks went to `test_ux3`: 329 checks in Checked
  and Release (311 before UX3), 314 in `checked noobs`"; the `test_present` row: "951 checks (925 before UX3:
  `profiles_square_only`)"; a new row `test_pdos_aspect` ("the DOS screens that keep square pixels under 4:3 along
  the intro, title, branches, Birth and setup, and through the present layer; reads build\dosdata; 61 checks");
  the test.cmd section list: `ux3_aspect` (`ext_aspect.py`).
* **DESIGN.md**: 12.2 "Settings" (line 1783) the key `aspect_320x200` -> `aspect_4_3` (1|0; since UX3, written only
  when the player changes the item in the run, through `hw_set_aspect_hook`; the keys `aspect` and `aspect_320x200`
  are not read and are removed at every save; decision 2 of `ext-UX3-record.md`); lines 1794..1797: the presentation
  keys written from the current state at every save are now `scale_mode`, `filter` and `fullscreen` (the aspect no
  longer: "The command line wins for the run and is not written" now holds for `aspect_4_3` too; for the other
  three the pre-existing gap stays); lines 1799..1803 "aspect square (UX2 ...)" -> "aspect 4:3 (UX3, the user's
  direction of 2026-10-16 about 10:21; as from D3b1 to UX2, X3; square under UX2), with the DOS profile's intro,
  title box and Birth square (`square_only`, 12.5); `civ64_start_aspect()`: `--aspect`, else `aspect_4_3`, else
  4:3"; 12.2 "System menu" (lines 1806..1808) "Scale by whole multiples" -> "Integer scaling" (mnemonic t, UX3) and
  "4:3 aspect for 320 x 200 pictures ... unchecked by default since UX2" -> "4:3 aspect ratio for 320 x 200 screens
  (check; checked by default again since UX3; its choice calls the aspect hook, then the settings hook)"; 12.5 / the
  profile interface (draft A 8.1): the new member `square_only` (1: the current frame keeps square pixels under
  4:3; NULL: never; read at every layout and tick); line 2373 (the tick's step 5a): "a visible frame whose size
  changed (A-B6), or (UX3) whose pixel aspect changed (the visible profile's `square_only` under the 4:3 option),
  is laid out again ...; a pixel-aspect change that leaves the picture as it is only takes the new layout"; 12.7
  (the DOS profile): `dos_square_only` = `pdos_seq_square_scene` with decision 5's table; line 1963 "(the default
  until UX2)" -> "(the default again since UX3; the DOS intro, title box and Birth are square)"; line 2056 (the
  Win32-headless tests) add UX3's `test_ux3` (the list in "Tests"; 311 -> 329 in Checked and Release, 296 -> 314 in
  CheckedNoObs; `test_ux2`'s aspect checks removed); `test_present` 951 (UX3's `profiles_square_only`); line 2250
  (5.11) "`--aspect` default square (UX2; X3's 4:3 superseded ...)" -> "4:3 again (UX3; square under UX2; 320x200
  frames only, the DOS intro, title box and Birth exempt)"; line 2450 (the harness) "the `--aspect` default is square
  (UX2 ...)" -> "4:3 (UX3, civ64's default; square under UX2)" and `--presented 2`; line 2543 "the square default
  since UX2" -> "4:3 again since UX3"; the test.cmd section list: `ux3_aspect`. Historical lines (unit records,
  4790 and earlier) stay.
* **FEATURES.md** "Host window (extension)": row 221 replaced by "4:3 is the default for 320x200 screens again; with
  the DOS graphics the intro, the title menu and Birth keep square pixels, Customize World, the Hall of Fame, Load,
  the setup pages and play take the 4:3 shape; '4:3 aspect ratio for 320 x 200 screens' is the option, remembered as
  `aspect_4_3` only when changed in the menu (UX3; F116 superseded again)" — scenarios `w32_test_host_win32`
  `test_ux3`, `test_pdos_aspect`, `test_present` `profiles_square_only`, `ext_aspect.py`; the user's checks UX3-2..
  UX3-10; a row "The window menu's 'Integer scaling' (was 'Scale by whole multiples') and '4:3 aspect ratio for
  320 x 200 screens' (UX3)" — `w32_test_host_win32` `test_ux3`; UX3-1.
* **STATUS.md**: UX3 staged (READY_TO_BUILD) / landed with its cycle; the "User directions" row of 10:21: items 1..4
  done by UX3.
* **EXT-HANDOFF.md** "Session E3": UX3's landing and user build.
* **DOS-PROFILE.md**: no statement of the aspect default; optionally one line in the scene notes: "the 4:3 option
  does not apply to the intro, the title box and Birth (UX3)".
* **ext-UX2-record.md**, **ext-D3-acceptance.md**, **ext-D3b1-record.md**, **ext-D3b2-record.md** (its note on the W
  mnemonic, now resolved by UX3) and the other unit records: historical, unchanged.

## Landing

Build slot after D5K (the orchestrator, about 11:20 UTC). D5K's cycle was ALL_GREEN at 11:34:48 UTC and its Release
build and user build `d5k` were done at 11:40:34 UTC (`build/d5k-status.txt`, `build/user-builds/d5k`); UX3 began
after both. Helpers and evidence in `build/ux3-prep/` (`land.py`, `snap.py`, `explain.py`, `ux3-cycle.ps1`).

1. **Bases.** `land.py` (dry run, 11:41 UTC): the 18 tree files still had their bases (`BASE-SHA256.txt`, taken
   10:35:20 UTC; D5K changed `pdos_adapt.c/.h`, `test_input.c` and `ext_adapt.py`, none of them UX3's), the two new
   files and this record absent from the tree, every staged copy at its `STAGED-SHA256.txt` hash: `LAND_DRY_OK 21`.
2. **Snapshot.** `snap.py take before`: `build/test/Checked`, `build/harness/Checked`, `build/harness/game` (D5K's
   test run): 8,501 files (path, size, SHA-256 in `before.tsv`; the small text files copied to `before/`).
3. **Copy.** `land.py --write`, 2026-10-16 11:41:57 UTC: 21 files byte for byte (the 18 staged files, the two new
   test files, this record); the tree's previous 18 files in `build/ux3-prep/tree-before/`; manifest
   `build/ux3-prep/landed.sha256` (with build.cmd's unchanged hash) and `build/ux3-stage/COPIED-SHA256.txt`.
   Re-verified against the tree after the Release build: all 21 unchanged.
4. **test.cmd.** The staged copy is the tree's base with `BUILD-TEST-ADDITIONS.md`'s two blocks (the base did not
   change), CRLF kept. `testpar.py check test.cmd`: exit 0; `list`: `ux3_aspect after=- cpu=6 est=20`, and
   `coverage`'s `after=` now includes it.
5. **The three-step cycle** from the port root (`ux3-cycle.ps1`: each step waits on its own cmd.exe; status
   `build/ux3-status.txt`, logs `build/ux3-<n>-<step>.log`):

   | step | exit | seconds | UTC | last line |
   |---|---|---|---|---|
   | 1 `build.cmd checked` | 0 | 257 | 11:42:06..11:46:22 | `BUILD_OK variant=Checked` (portable sources checked: 291) |
   | 2 `test.cmd checked` | 0 | 1105 | 11:46:23..12:04:47 | `TESTS_OK variant=Checked` (26 sections, failed 0) |
   | 3 `ext_g1.py check` | 0 | 0 | 12:04:47 | `EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)` |

   `ALL_GREEN`. The build log's first line ("'vswhere.exe' is not recognized") is in every landing's log (D5K, UX2).
6. **Comparison** (`snap.py take after`, `snap.py diff before after` > `diff.txt`, `explain.py` > `explain.txt`):
   8,501 -> 8,593 files; 329 changed, 92 only after, none only before. Every difference:
   * only after (92): the new section's outputs: `harness/Checked/aspect/` (90 files: the six runs `fame`,
     `fame_sq`, `custom`, `custom_sq`, `fame640`, `fame640_sq` and their console files), `test/Checked/ext-aspect.txt`
     (`EXT_ASPECT_OK`, the same 16 checks and values as the private run: switches `sq@0 ft@5502100 sq@8001100
     load@11501700 sq@11501700 ft@24596282` and `sq@0 ft@5502100 sq@11757150 ft@21575382`) and
     `test/Checked/sections/ux3_aspect.log` (5.8 s);
   * 323 `presentation-diag.log` files: host-time fields only (`pmap.snap_turn_max_us`, `pmap.snap_us`,
     `pmap.world_max_us`, `pmap.world_us`; equal with them masked), as at earlier landings;
   * `sections/unit.log`: the predicted counts (`test_pdos_aspect` 61 new; `test_present` 925 -> 951;
     `test_host_win32` 311 -> 329); every other differing line is a host-time measure (the activation and decode
     times, `test_map`'s costs, `OBS_COST`, the informational scaling timings, the tick-independence duration). The
     activation line read 335 ms (D5K's run 143 ms): a Checked measure, informational there (the Release budget is
     checked in Release), on a machine shared with other units' private builds;
   * `sections/times.txt` (section times, the new row `ux3_aspect`) and `timeline-partitions.txt` (durations only);
   * `nodos.txt`: 1,709 -> 1,713 files scanned, 0 hits both: the three new tree files and `test_pdos_aspect.exe`
     (4,481,225 bytes of the 4,572,853 more), the rest the grown sources and binaries;
   * `coverage.txt` and `sections/coverage.log`: "other functions entered" 665 -> 664; the run-time entries (145 of
     155) and the rest of `coverage.txt` are equal. The count is informational and includes malformed tokens: the
     parallel harness processes append to one `build/x64/Checked/coverage-civ_harness.txt`, and a buffer written by
     one can split another's line. This run's file has one such split (`10E8:3368 ResetSpaceship` around
     `1000:47F2 __SubHeapSegAllocBlock`), which adds two non-address tokens; without them the count is 662, the
     value before UX2's landing. D5K's files are not kept (test.cmd deletes them at each run), so its 665 cannot be
     taken apart; the core is unchanged by UX3 (P0 in `ext_aspect.py`, `EXT_G1_OK`);
   * everything else is byte-identical: every other harness output, the goldens and every other `ext-*.txt` report.

   The predictions ("Expected expectation changes") held.
7. **Release and the user build.** Step 4 `build.cmd` (no arguments): exit 0, 227 s, 12:05:01..12:08:47 UTC,
   `BUILD_OK variant=Release`; `RELEASE_OK`. `build/user-builds/ux3/` (12:09 UTC): `civ64.exe` from
   `build/x64/Release` (SHA-256 5bc24dfaa83d6a1b5c71fb72808433ebea896edffa933a87a611913cc8673aa1), `CIVWIN.zip`
   and `civdos.zip` copied from `build/user-builds/d4/` (hashes equal), `WHAT-TO-CHECK.txt` with UX3-1..UX3-10 in
   plain words, the one-time reset note, the note that 4:3 needs a window larger than the smallest under integer
   scaling, UX2-5/UX2-6 replaced, and that the build contains everything in `d5k`, `d6c`, `ux2` and `d5`.
8. **Not done here:** the docs pass ("For the records"; one pass after D5K and UX3), the user's checks UX3-1..UX3-10,
   the CheckedNoObs and Release test runs of the next phase gate (`w32_test_host_win32` 314 and 329 there,
   predicted).

# Extension unit UX2 (the system menu's profile mark at the start; square as the default for 320x200 pictures) - record

Unit UX2 of the "civ64" extension carries out the two host items of the user's results of 2026-10-16
(STATUS.md "User directions", row "2026-10-16 about 08:05"; checklist D3-9 and D4-1):

> (a) D3-9: "When I exit the game using DOS graphics and reopen it later context menu defaults to Windows
> graphics selected."
>
> (b) D4-1: "4:3 aspect for 320 x 200 pictures shall not be default."

Session E3, 2026-10-16. Staged in `build/ux2-stage/` (the orchestrator's staging protocol, EXT-HANDOFF.md
"Session E3"); the first stager was stopped by the session restart at 08:22:33 UTC, its partial stage
(bases taken 08:16:45 UTC) was reviewed, completed and re-verified by the second stager from 08:28 UTC.

Labels:

* **compiled**: build.cmd's flags on a private overlay (the tree with the stage over it), strict C17/x64
  (`/W4 /WX /permissive- /fp:precise`), plus `/std:c11` for the four changed Win32 sources.
* **Win32-headless**: `w32_test_host_win32`, `w32_test_locate`, `w32_test_dos_host` (hidden windows, quiet
  mode) linked from the overlay, argv[1] `build/gamedata` (read), argv[2] under the stage.
* **harness**: the overlay's Checked `civ_harness.exe` on `build/gamedata` and `build/dosdata` (read), every
  run and output directory under the stage.

Scope: no DOS program was executed; nothing was written to `C:\Projects\Civ1RE\dos`, `C:\Projects\Civ1RE\original`,
`build/dosdata`, `build/gamedata`, `build/x64`, `build/harness` or any other shared output; build.cmd and
test.cmd were not run; civ64 was not launched and no UI was shown (hidden test windows only); no git command
that writes was run. Not edited: `core/`, `rt/`, `res/`, `present/`, `platform/w16/`, `build.cmd`, `test.cmd`,
the generated tables and every document other than this record ("For the records").

## Status

**Landed; the three-step cycle is ALL_GREEN** (2026-10-16 09:34:18 UTC, `build/ux2-status.txt`; "Landing").
Staged, compiled and tested privately in Checked, CheckedNoObs and Release first (READY_TO_BUILD about 08:50 UTC,
accepted by the orchestrator about 09:00 UTC with the cfg rule). Both items are implemented: (a) the mark shows the
presented profile from the start and after every switch; (b) square is the default for 320x200 pictures, 4:3 the
option. User build `build/user-builds/ux2/` (UX2-1..UX2-6); the user's checks are pending.

## What was built

### (a) The profile radio mark (D3-9)

**Cause.** The system menu is built in `hw_create_window_ex` (`add_menu`, which marks the state of that moment:
the Windows profile, the only one before the start profile exists). civ64's start profile (the remembered key
`graphics`, K7, or `--graphics`) is set later in `civ64_main.c` by `present_start_profile`, which does not touch
the host's menu. The mark was meant to be refreshed as the menu opens (D3: `WM_INITMENU`), but that handler
refreshed only when the message named `GetSystemMenu(h, FALSE)`. For a window without a menu bar Windows tracks
the window menu through its own wrapper menu, so the handle that `WM_INITMENU` names is not the popup that
`GetSystemMenu` returns (inference from the window-menu structure and from the user's report: at the moment the
menu was opened the visible profile was DOS, and a refresh would have marked it; not observed on screen). So the
creation-time mark "Windows graphics" stayed until the player's first switch, whose handler marks explicitly.
The same pattern held for the map zoom's radio items: the remembered `zoom` level (or `--zoom`) is requested after
the menu exists and was not marked until a zoom command.

**Fix** (`platform/win32/host_win32.c/.h`, `win64/civ64_main.c`, `win64/civ64_start.c/.h`):

1. `hw_start_profile(profile)` (new): the run's start profile, the DOS one when requested and registered, else
   the Windows one (the fallback when the DOS files are missing, as before), through `present_start_profile`,
   then `hw_update_menu()`. civ64_main.c calls it with `civ64_start_graphics(&opt, &g_cfg)` (new, civ64_start.c:
   `--graphics` when given, else the key `graphics` = `windows`|`dos`, anything else absent, else Windows) in
   place of its inline choice; the choice itself is unchanged.
2. `WM_INITMENU` refreshes the marks whatever menu it names (the window has no menu bar, so the window menu is the
   only menu it can name), and `WM_INITMENUPOPUP` with the system-menu flag (HIWORD(lParam)) refreshes them too.
   Every checkable or grayed item is therefore current whenever the menu opens: the scaling and filter radio items,
   the grayed filters, the aspect item, Full screen, the profile items, the zoom items, "Zoom in" grayed while +1
   is refused, the wheel item.
3. After the start's remembered or command-line zoom request civ64_main.c calls `hw_update_menu()` at once.

The switches already marked explicitly and are unchanged: the chord Ctrl+Shift+Backspace and the menu items go
through `player_profile` → `hw_update_menu()` (the mark shows the accepted request, which the next presentation
tick makes visible, draft A 11); a refused switch (no DOS files) changes nothing and Windows stays marked. The
other checkable items were audited for the same stale-initial-state pattern: scaling, filter and aspect are set
before the window is created (marked correctly by `add_menu`); Full screen is applied after `add_menu` through
`hw_set_fullscreen`, which marks; the remembered wheel "off" goes through `hw_set_wheel_zoom`, which marks; only
the profile and the zoom items had the pattern, both fixed (1..3).

### (b) Square as the default for 320x200 pictures (D4-1)

* civ64's default aspect is `PRESENT_SQUARE` (was `PRESENT_ASPECT_4_3`, decision X3, FIDELITY F116):
  `civ64_start_aspect(&opt, &g_cfg)` (new, civ64_start.c): `--aspect` when given, else the remembered key
  `aspect_320x200` (`4:3` or `square`), else square.
* 4:3 stays available unchanged: the system-menu item "4:3 aspect for 320 x 200 pictures" (now unchecked by
  default), `--aspect 4:3` / `--aspect square`, and the remembered setting (below).
* The harness default follows civ64's (`tests/headless/harness_main.c`: `o.aspect = PRESENT_SQUARE`; its header
  comment), as D3b1 made both 4:3 together; `--aspect` and the script command `policy ... square|4:3` unchanged.
* `present.c`'s own default was already square; nothing in `present/` changes.

### The remembered aspect (civ64.cfg) and its one migration

* `win64/civ64_cfg.h/.c`: `civ64_cfg_aspect()` (1 for `4:3`, 0 for `square`, -1 absent or invalid) and
  `civ64_cfg_set_aspect()` (writes `aspect_320x200`, removes the old key `aspect`).
* `win64/civ64_main.c` `save_settings`: writes `aspect_320x200` through `civ64_cfg_set_aspect` instead of `aspect`;
  the unused `g_aspects` table is removed.

### Staged files

Full copies under `build/ux2-stage/` at the tree's paths, CRLF like the tree's; bases in `BASE-SHA256.txt` (taken
08:16:45 UTC, re-verified 08:28:36 and 08:49:18 UTC), the staged copies' hashes in `STAGED-SHA256.txt`. No new file.

| file | change |
|---|---|
| `platform/win32/host_win32.h` | `hw_update_menu`'s comment; `hw_start_profile` (new) |
| `platform/win32/host_win32.c` | header paragraph; `hw_start_profile` after `hw_update_menu`; `WM_INITMENU` without the handle comparison; `WM_INITMENUPOPUP` (fSystemMenu) |
| `win64/civ64_start.h`, `civ64_start.c` | `civ64_start_aspect`, `civ64_start_graphics` (new; civ64_start.c includes civ64_cfg.h) |
| `win64/civ64_cfg.h`, `civ64_cfg.c` | `civ64_cfg_aspect`, `civ64_cfg_set_aspect` (new; the key `aspect_320x200`) |
| `win64/civ64_main.c` | header comment; `g_aspects` removed; `save_settings` through `civ64_cfg_set_aspect`; the start's options through `civ64_start_aspect`; the start profile through `hw_start_profile(civ64_start_graphics(...))`; `hw_update_menu()` after the start's zoom request |
| `tests/headless/harness_main.c` | the `--aspect` default square (`o.aspect = PRESENT_SQUARE`) and its header comment |
| `tests/win32/test_host_win32.c` | `write_cfg`, `test_ux2` (before `test_exit`'s block), its call after `test_lp` |

## Decisions

1. **The cfg rule: a renamed key (`aspect` → `aspect_320x200`); the old key is never read again.** How civ64.cfg is
   written: `save_settings` (civ64_main.c) is the back end's settings hook. It runs at every presentation change by
   the player (system menu, Alt+Enter, the profile/zoom/wheel hooks) **and at every exit** (`host_exit`, F111: "the
   placement at the game's end too"), and each time it writes `scale_mode`, `filter`, `aspect` and `fullscreen` from
   the current state. So every civ64.cfg written before UX2 holds `aspect=4:3` after the first exit, whether or not
   the player ever chose it: a stored `4:3` is in almost every case X3's old default, not a choice, and cannot be
   told apart from one. Per the brief, a pre-UX2 cfg must not keep 4:3 by accident: the old key is ignored (square
   applies) and the first save of a UX2 build writes `aspect_320x200` (square unless the player checks the item)
   and removes `aspect`; from then on the remembered setting holds. A renamed key was chosen over a version
   marker: it needs no new key semantics, is visible in the file, and a pre-UX2 build run on the same file later
   only re-adds the key `aspect`, which UX2 builds ignore. Cost (accepted): a player who had deliberately chosen
   4:3 before UX2 sees square once and checks the item again. The new key keeps the file's existing rule for these
   presentation keys (written at every save, like `scale_mode` and `filter`; so, as before, an `--aspect` given for
   a run is written at that run's next save; this pre-existing behaviour is noted under "For the records" because
   DESIGN.md 12.2 says the command line "is not written").
2. **WM_INITMENU without the handle comparison.** The fix does not depend on which handle Windows passes; the
   refresh is cheap and idempotent. `WM_INITMENUPOPUP` (fSystemMenu) is a second refresh point for the drop-down.
3. **The start's mark is set where the profile starts** (`hw_start_profile` in the back end, called by civ64_main.c),
   so the testable function and the product use one code path; `civ64_start_graphics` / `civ64_start_aspect` move
   the start choices out of `wWinMain` into civ64_start.c, which the Win32-headless tests link.
4. **The mark during a pending switch** keeps draft A 11's "profile to come" (the accepted request, applied at the
   next presentation tick, about a frame later); it is the presented profile from that tick on.
5. **The harness default follows civ64** (rather than the runs naming `--aspect 4:3`): no harness run's expectation
   depends on the default ("Expected expectation changes"), so the honest smallest change is to keep the harness's
   default equal to civ64's, as F116 records it was since D3b1.

## Tests

`tests/win32/test_host_win32.c`: new `test_ux2(outdir)` after `test_lp`, before the exits (32 checks in Checked
and Release, 31 in CheckedNoObs, which has no zoom check):

* the new default: no `--aspect` and no settings file: square (also with no settings set at all);
* the cfg rule (files written in `<outdir>\ux2\civ64.cfg`): a pre-UX2 file `aspect=4:3`: the old key is kept in
  the set but not read, square; `civ64_cfg_set_aspect(0)` removes `aspect` and writes `aspect_320x200=square`; read
  back: square, no old key, the other keys kept; the player's 4:3 written and read back: 4:3 holds; with both keys
  (`aspect=square`, `aspect_320x200=4:3`) only the new key counts; `--aspect square` over a remembered 4:3,
  `--aspect 4:3` without one; five invalid values (`4:4`, empty, `4/3`, `Square`, ` 4:3`) read as absent: square;
* the start profile's choice: `graphics=dos` remembered: DOS; `--graphics windows` over it: Windows; `--graphics
  dos` over `graphics=windows`: DOS; an invalid `graphics=DOS` or no file: Windows;
* the radio mark at start-up, on the hidden window: before the start Windows is marked; `hw_start_profile` with the
  remembered `graphics=dos`: DOS shown, nothing pending, DOS graphics marked at once; `--graphics windows` over it:
  Windows marked; `--graphics dos`: DOS marked; the fallback, `graphics=dos` remembered without the DOS profile (its
  files missing): Windows shown and marked;
* the marks as the menu opens: a `present_start_profile` alone leaves the old mark (the old pattern, shown);
  `WM_INITMENU` naming another menu than `GetSystemMenu`'s: the presented profile marked; `WM_INITMENUPOPUP` with the
  system-menu flag: the same; (observer builds) a zoom level -1 set without the host's marks is marked as the menu
  opens;
* the marks after switches from the DOS start: Ctrl+Shift+Backspace: Windows requested, recorded by the profile
  hook and marked; after the tick Windows shown and marked; the menu's DOS graphics: DOS requested and marked;
  after the tick DOS shown and marked; the chord again: Windows shown and marked.

The existing D3b2 checks (marks after the chord and the menu from a Windows start, withdrawn requests, refusals with
Windows staying marked) are unchanged and still pass.

**Private results** (overlay build `build/ux2-stage/obj/private.cmd`, 2026-10-16 08:41..08:45 UTC; base counts from
the D5 gate's logs `build/d5-gate-2-test-checked.log`, `-5-test-noobs.log`, `-8-test-release-r2.log`):

| variant | build | `w32_test_host_win32` | `w32_test_locate` | `w32_test_dos_host` |
|---|---|---|---|---|
| Checked | OK (290 portable c17 objects, harness, civ64.exe, three w32 tests; c11 of the 4 changed Win32 sources) | PASS 311 checks (279 + 32) | PASS 36 | PASS 56 |
| CheckedNoObs | OK (as Checked) | PASS 296 (265 + 31) | PASS 36 | PASS 56 |
| Release | OK (no harness, as build.cmd) | PASS 311 (279 + 32) | PASS 36 | PASS 56 |

Checks test.cmd runs that read these files, run privately: `tests/harness/obs_lint.py` on the overlay:
`OBS_LINT_OK files 114 probes 203 callsites 98`; `gen/dos/registry.py check` (its inputs, present/dos, present/bs,
docs/dos and the generated tables, are not touched by UX2): `REGISTRY_OK`; `gen/dos/nodos.py check --root <overlay>
--variant V` over the overlay's files and its private binaries: `NODOS_OK` in Checked, CheckedNoObs and Release
(0 hits). test.cmd is not touched, so `testpar.py check` does not apply; no `BUILD-TEST-ADDITIONS.md`.

**Private harness differential** for the harness default (`build/ux2-stage/obj/hr/aspect_diff.py`, results
`aspect_diff.txt` and `aspect_diff2.txt`, 08:45..08:48 UTC): the overlay's Checked `civ_harness.exe` ran four DOS-profile
runs (`--dos-data build/dosdata --graphics dos --presented 1 --profile-samples 100`) once with `--aspect 4:3` (X3's
default) and once without `--aspect` (the new default, square): p4's `start` (30 s, no input) at the default host
640x480, at `--host-size 1920x1080` (4x5 under 4:3 against 5x5 square) and at 1920x1080 with `--scale-mode fit`, and
p4's `birth` (205 s, the DOS Birth) at 1920x1080. All exit 0; all eleven output files of each pair (run.log, events.log,
presented.log, profiles.log, timeline.log, presentation-diag.log, observer-probes.log, dos-assets.log, fonts.txt,
watchdog.txt/.snap) are byte-identical, except run.log's first line, which names the run directory (different by
construction). So the harness default's change alters no recorded output. (The runs' game-data copies under
`obj/hr/run` were deleted afterwards; the outputs stay in `obj/hr/out`.)

## Expected expectation changes

**None.** Only `w32_test_host_win32`'s check count changes (new checks).

Where the default aspect could matter: the aspect acts only on 320x200 frames (`present_layout_compute`), which
only the DOS profile shows. Every harness, golden or presented-frame expectation was checked:

* G-1 (`ext_g1.py`) and P0 (`ext_p0.py` V0..V8s) compare only the core's frames, state and events; presentation
  options never reach the core (no host mouse input is mapped through a 320x200 layout in any P0 run). V3 names
  `policy fit sharp 4:3` from its first command and runs the Windows profile only; V0 now runs on square, as the
  G-1 baseline itself was recorded on square (the harness default before D3b1).
* `presented.log`, `profiles.log` samples, `timeline.log`, the `--dump-presented` BMPs (`ext_frames`, `ext_timeline`
  and its golden `ext-timeline-golden.txt`, `ext_continue`, `ext_mirror`, `bs3_timeline`) hash or write the logical
  frames, before scaling; the scaled view is hashed only while the map layer is drawn, which needs the Windows
  profile (`ext_zoom` and its golden `ext-zoom-golden.txt`, `ext_adapt` M runs, `ext_p0` V4: 640x480 and game-screen
  frames, square under either default).
* `ext_adapt`'s DOS-form host scripts map host points through the N canvas at the default host 640x480, where
  a 320x200 frame is laid out 2x2 at (0, 40) under both aspects (4:3 finds no whole-number pair within 5 % of 6/5
  in 2x2, so it falls back to the square factors); the DOS-form pairs are therefore unchanged.
* `test_present` and the other unit tests set the aspect explicitly (`profiles_layout`'s 4:3 checks name
  `PRESENT_ASPECT_4_3`); `w32_test_host_win32`'s existing aspect checks toggle from the test's own state.

Predictions for the build slot: `build.cmd checked` BUILD_OK (portable sources checked: unchanged count, no new
file); `test.cmd checked` TESTS_OK with `w32_test_host_win32` PASS 311 checks and every other section as at the D5
gate; `ext_g1.py check` `EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)` (unchanged). At the next
phase gate: CheckedNoObs 296 and Release 311 checks.

## Build-slot steps

1. From the port root: `sha256sum -c build/ux2-stage/BASE-SHA256.txt` (nine files). Any base that changed since
   08:16:45 UTC: re-apply UX2's hunks onto the tree's copy (each file's hunks are listed in "What was built"; the
   files are CRLF like the tree's) and re-run `build/ux2-stage/obj/private.cmd mirror` / `Checked` before going on.
2. Copy the nine staged files into the tree at the same paths: `platform/win32/host_win32.c`, `host_win32.h`,
   `win64/civ64_main.c`, `civ64_start.c`, `civ64_start.h`, `civ64_cfg.c`, `civ64_cfg.h`,
   `tests/headless/harness_main.c`, `tests/win32/test_host_win32.c`; record their hashes in
   `build/ux2-stage/COPIED-SHA256.txt`. No new file, no build.cmd/test.cmd change, no registry change.
3. The three-step cycle: `build.cmd checked`, `test.cmd checked`, `C:/Python314/python -B tests/harness/ext_g1.py
   check` (status `build/ux2-status.txt`), with the predictions above.
4. Then a user build `build/user-builds/ux2/` (Release, the scheme of `user-builds/d4cf`) with
   `WHAT-TO-CHECK.txt` listing "What the user checks"; the docs pass applies "For the records".

## What the user checks

New items for `manual-checklist-ext.md` (UX2-1..UX2-6):

* **UX2-1** (D3-9's bug): switch to DOS graphics, end civ64 (close button, Exit item or Alt+F4), start it again
  without `--graphics`: it starts in DOS graphics **and the window menu marks "DOS graphics"**.
* **UX2-2**: with DOS remembered, start with `--graphics windows`: Windows graphics shown and marked; with Windows
  remembered, `--graphics dos`: DOS graphics shown and marked.
* **UX2-3**: switch a few times with Ctrl+Shift+Backspace and with the menu's items, opening the menu after each:
  the mark is always the profile shown.
* **UX2-4**: with a remembered map zoom (choose Zoom out or Zoom in, exit, start again), the first opening of the
  menu marks that level; Full screen, the aspect item and "Mouse wheel zooms the map" show their actual state.
* **UX2-5** (D4-1's change): in DOS graphics the start-up screens (credits, intro, logo, title, Birth, setup) have
  square pixels by default, and "4:3 aspect for 320 x 200 pictures" is unchecked; checking it shows the 4:3 shape
  (slightly taller pixels) and is remembered at the next start; `--aspect 4:3` / `--aspect square` set it for that
  run. The Windows profile looks as before.
* **UX2-6** (the migration): with a civ64.cfg written by an earlier build (it holds `aspect=4:3`), the first start of
  the UX2 build shows square; after that the setting is remembered as usual (`aspect_320x200` in civ64.cfg, the old
  `aspect` line gone after the first exit).

## For the records

Wording changes for the docs pass (not edited by UX2):

* **FIDELITY.md F116** (line 176): superseded by UX2 (the user's change request, 2026-10-16 about 08:05, D4-1: "4:3
  aspect for 320 x 200 pictures shall not be default"): the default for 320x200 frames is square again (civ64 and
  the harness); 4:3 is the player's option (system-menu item, unchecked by default; `--aspect 4:3`; remembered);
  the remembered key is now `aspect_320x200`, the pre-UX2 key `aspect` is no longer read (Decision 1); status
  "implemented in UX2"; references `win64/civ64_start.c civ64_start_aspect`, `tests/headless/harness_main.c`. Also
  line 166's list (F116 "implemented ... D3") needs no change beyond the entry.
* **RUNNING.md**: line 249 (the harness option table) `--aspect square|4:3` "Default `4:3` (decision X3)" → "Default
  `square` (UX2; 4:3 was the default from D3 to UX2, X3)"; line 426 (civ64's options) "Without it: your last
  choice, else `4:3`" → "else `square`" and "remembered as the `aspect_320x200` key of civ64.cfg; a civ64.cfg
  written before UX2 has its `aspect` line ignored once"; line 433 "the 4:3 aspect" → "the 4:3 aspect for 320x200
  pictures (off by default)"; line 465 ("The radio mark shows the profile you chose at once ...") add: "and from
  the start it marks the profile civ64 started in (the remembered one or `--graphics`)"; line 538 (the `graphics`
  key) add the same sentence about the mark; line 103 (`test_present` row) unchanged; line 105 (the
  `w32_test_host_win32`, `w32_test_locate` row) add "since UX2 `test_ux2`: the square default, the `aspect_320x200`
  key and the pre-UX2 `aspect` key ignored, the start profile's choice and mark (`graphics=dos`, `--graphics`, the
  Windows fallback), the marks as the menu opens and after switches" and "311 checks in Checked (279 before UX2)".
* **DESIGN.md**: 12.2 "Settings" (line 1783) the key list `aspect` (square|4:3) → `aspect_320x200` (square|4:3;
  since UX2; the pre-UX2 key `aspect` is not read and is removed at the next save), and lines 1795..1797 "aspect 4:3
  (decision X3, D3b1 ...)" → "aspect square (UX2; 4:3 from D3b1 to UX2, X3)"; note that the presentation keys
  `scale_mode`, `filter`, `aspect_320x200`, `fullscreen` are written from the current state at every save including
  the exit (F111), so the sentence "The command line wins for the run and is not written" holds for `graphics`,
  `zoom` and `wheel_zoom` only (pre-existing; UX2 keeps it); 12.2 "System menu" (line 1802..) the aspect item
  unchecked by default; the profile items "marking the profile to come" from the start (`hw_start_profile`) and
  refreshed at every `WM_INITMENU` (any menu handle) and `WM_INITMENUPOPUP` of the window menu (UX2); line 2039
  (Win32-headless tests) add UX2's `test_ux2` (the list in "Tests"; 279 → 311 checks in Checked and Release, 265 →
  296 in CheckedNoObs); line 2233 (5.11) "`--aspect` default 4:3 (X3, 320x200 frames only)" → "square (UX2; X3's 4:3
  superseded)"; line 2433 (the harness) "the `--aspect` default is 4:3 (X3)" → "square (UX2)"; line 2457 "V0 none
  (4:3 default)" → "V0 none (the square default since UX2; 4:3 from D3b1 to UX2)"; line 2526 "4:3 default" →
  "square default (UX2)". Historical lines (4443 and earlier unit records) stay.
* **FEATURES.md** "Host window (extension)": two rows: (1) "The window menu's marks show the current state whenever
  it opens; the profile items mark the profile civ64 started in (the remembered `graphics` key or `--graphics`, the
  Windows fallback without the DOS files) and follow every switch (UX2, D3-9)" — scenario `w32_test_host_win32`
  `test_ux2`; (2) "Square is the default for 320x200 pictures; '4:3 aspect for 320 x 200 pictures' is the option,
  remembered as `aspect_320x200` (a pre-UX2 `aspect` key ignored once) (UX2, D4-1; F116 superseded)" — scenario
  `w32_test_host_win32` `test_ux2`; the user's check.
* **manual-checklist-ext.md**: D3-9's note: the bug is fixed by UX2 (check UX2-1); D3-10 "the 4:3 default (X3)
  changes nothing visible in the Windows profile" → "the aspect default (square since UX2; 4:3 under X3 when the
  user passed this item) changes nothing visible in the Windows profile" (history kept); D4-1 "appear at 4:3
  (slightly taller pixels) without any option; `--aspect square` or the system-menu item ... unchecked shows them
  square" → reversed by UX2: "appear with square pixels without any option; `--aspect 4:3` or the system-menu item
  ... checked shows them at 4:3, and the setting is remembered" (the user's pass of 07:56 UTC was of the X3 form;
  the new form is UX2-5); new items UX2-1..UX2-6 ("What the user checks").
* **STATUS.md**: UX2 staged/landed with its cycle; the "User directions" row of 08:05: items (a) and (b) done by UX2.
* **EXT-HANDOFF.md** "Session E3": UX2's landing and user build.
* **DOS-PROFILE.md**: no change (it does not state the aspect default; checked 08:50 UTC).
* **ext-D3-acceptance.md**, **ext-D3b1-record.md** and other unit records: historical, unchanged.

## Landing

The orchestrator gave UX2 the build slot about 09:00 UTC, after the D5 gate's docs pass (marker
`build/docs-d5gate-done.txt`, 09:04:39 UTC, first line "docs-d5gate done", not BLOCKED; seen 09:05:07 UTC).

1. **Bases.** `sha256sum -c build/ux2-stage/BASE-SHA256.txt` at 09:05:12 UTC and again just before the copy: all nine
   OK, nothing to re-apply (the docs pass touched only docs).
2. **Copy-in** 09:06:39 UTC (`build/ux2-stage/COPIED-TIME.txt`): the nine staged files and this record
   (`docs/ext-UX2-record.md`, new); hashes in `build/ux2-stage/COPIED-SHA256.txt` (the nine equal
   `STAGED-SHA256.txt`). This "Landing" section and the Status paragraph were added to the tree's copy afterwards
   (docs only; no test reads this record).
3. **Three-step cycle** (`build/ux2-stage/ux2-cycle.ps1`, each step waiting on its own cmd.exe process;
   `build/ux2-status.txt` ends `ALL_GREEN`):

   | step | exit | seconds | UTC | log | last line |
   |---|---|---|---|---|---|
   | 1 `build.cmd checked` | 0 | 263 | 09:07:10..09:11:33 | `build/ux2-1-build-checked.log` | `BUILD_OK variant=Checked` (portable sources checked: 290, c11, c17, c99 parse) |
   | 2 `test.cmd checked` | 0 | 1365 | 09:11:33..09:34:17 | `build/ux2-2-test-checked.log` | `TESTS_OK variant=Checked` (`TEST_SECTIONS 25 parallel, budget 20, wall 1362.5 s, failed 0`; TRACE_OK) |
   | 3 `ext_g1.py check` | 0 | 0 | 09:34:17..09:34:18 | `build/ux2-3-g1-checked.log` | `EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)` |

   `w32_test_host_win32` PASS 311 checks (279 before UX2), `w32_test_locate` 36, `w32_test_dos_host` 56. Every
   prediction of "Expected expectation changes" held. (The D6c stager's private overlay builds and harness runs, all
   under `build/d6c-stage/`, ran at the same time; they share no output with the cycle.)
4. **Comparison with the Checked outputs before the copy-in.** `build/ux2-stage/snap/snap.py take before` at 09:05 UTC
   (before the copy-in) and `take after` after step 3, over `build/test/Checked`, `build/harness/Checked` and
   `build/harness/game` (manifests `before.tsv`/`after.tsv`, the small text files copied; `diff.txt`, `explain.txt`).
   The "before" outputs are the D5 gate's (its `test.cmd checked`, 08:10..08:25 UTC, for `build/test/Checked` and
   `build/harness/Checked`; its `test.cmd checked noobs` for `build/harness/game`, which both variants write).
   8,227 files before, 8,375 after: 269 changed, 148 only after, none only before. Every difference:
   * 263 `presentation-diag.log` under `build/harness/Checked` (adapt 11, frames74 4, mirror 24, p0 160, zoom 64):
     only the presentation layer's host-time fields `pmap ... snap_us`, `snap_turn_max_us`, `world_us`,
     `world_max_us` differ; with every `*_us`/`*_ms` value masked all 263 are equal (`explain.py`).
   * 148 files only after: `observer-probes.log` and `presentation-diag.log` of 74 base runs in `build/harness/game`.
     The "before" state of that folder was written by the D5 gate's CheckedNoObs run (CIV_OBSERVER 0 writes neither
     file); the Checked run writes them again. Every other file of those runs is byte-identical (Checked's core
     outputs equal CheckedNoObs's, as G-1 requires).
   * `build/test/Checked/sections/unit.log`: host timings (activation ms, bit-flip and decode times, test_map costs,
     OBS_COST ns, scaler timings, tick-independence seconds) and `test_host_win32: PASS (279 checks` → `(311 checks`;
     `sections/times.txt`: the section times; `timeline-partitions.txt`: wall seconds.
   * `coverage.txt` and `sections/coverage.log`: "other functions entered 662" → "663". This informational count (the
     translated functions entered, merged over the test programs' and harness runs' `coverage-*.txt`; it does not
     fail) varies from run to run without a source change: 661..666 in the Checked runs of the last day (d6b 666 and
     663 on its rerun, d5l 662 and 665). UX2 changes no core, rt, w16 or present code and no headless test; its one
     harness change (the default aspect) left every harness output identical in the private differential.
   * `nodos.txt`: 1,705 → 1,706 files and +147,961 bytes scanned, 0 hits both times: the new file is this record;
     the bytes are this record, UX2's larger sources, the D5 docs pass's edits since the D5 gate's run and the rebuilt
     Checked binaries.
   * The console logs (`build/d5-gate-2-test-checked.log` against `build/ux2-2-test-checked.log`): their 303 result
     lines (`_OK`, PASS/FAIL, check counts) differ only in `test_host_win32` 279 → 311; with times masked the whole
     logs differ besides only in OBS_COST (ns timings) and the COVERAGE line above.
   No golden, baseline or expectation file changed.
5. **Release and the user build.** `build.cmd` (Release) after the cycle: exit 0, 215 s, 09:37:03..09:40:38 UTC,
   `build/ux2-4-build-release.log` ends `BUILD_OK variant=Release` (290 portable sources). `build/user-builds/ux2/`
   (09:40 UTC): `civ64.exe` from `build/x64/Release` (SHA-256 6890e4d9...b5df), `CIVWIN.zip` and `civdos.zip` copied
   from `build/user-builds/d4/` (hashes equal), `WHAT-TO-CHECK.txt` (UX2-1..UX2-6 in plain words, the one-time reset
   of a remembered 4:3, and that the build contains everything in build "d5"). The user's checks are pending.
   CheckedNoObs and Release tests run at the next phase gate (predicted 296 and 311 checks).

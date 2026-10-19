# Extension unit WL (windowless play) - record

Unit WL of the civ64 extension: an optional windowless play mode, chosen on the fly in the host window menu, in the
Windows and the DOS graphics. Design: `docs/verify/BRIEF-wl.md` (the proposal with the orchestrator's answers of
2026-10-18 and the user's direction of 2026-10-18 about 06:20 UTC). Staged in `build/wl-stage/` (sessions E4 and
E5), landed by the E5 implementer (section "Landing").

## Result

* Display's first item "&Windowless play" (a check item, `SC_CIV_WINDOWLESS` 0x1110, then a separator) switches the
  mode on and off at any time, in both graphics. In play (the map window shown and not iconic, the Windows frame or the
  DOS A frame visible) the picture is one canvas: the map window's menu bar and client (M), the World Map's client (W)
  and the Status window's client (S), without captions, frames, borders or scroll bars, stitched as the DOS game's
  screen (the column W over S beside M, the bar on top). Dialogs, message boxes, menus and the move or size outline
  float over the canvas; a host click maps back to the windowed point of what it hits.
* **No scroll bars** in windowless play, in either graphics, without condition (the user's direction of 2026-10-18
  about 06:20 UTC). The play map moves as it does windowed: by a click on the World Map and by a left click on the
  play map. Both are verified through WL's input mapping against the windowed points (ext_wl.py, below).
* The setting is remembered in civ64.cfg (key `windowless`, written only after the player's change through the menu);
  `--windowless 0|1` wins for one run and is never written. Under `CIV_OBSERVER 0` the item is grayed and
  `--windowless 1` exits 2.
* P0: core, rt and platform/w16 are unchanged; no `w16_present` is added, removed or delayed; no random number is
  drawn; the game screen does not depend on the option (the core's outputs are equal with WL on and off: ext_p0 V9,
  V9d, V9t).

## Status

Implemented and landed (section "Landing"). The user's visual checks WL-1..WL-9 are pending (user build
`build/user-builds/wl/`).

## The design (as built)

* **present/wl.c, wl.h** (portable C, prefix `pwl_`).
  * The scene is read inside the observer's guard at every core present and tick (`pwl_read`): the three windows by
    their ports (**DOS listing / Windows binary**: g_mapWindowPort 12B0:0004 class "CIV", created by WdwMapOpen
    1208:0AF1 at 1208:0B4E with style 0x02FF0000, which includes WS_HSCROLL and WS_VSCROLL; g_worldMapWindowPort
    12B0:001C, WdwSmMapOpen 1210:025B; g_statusWindowPort 12B0:0034, WdwStatusOpen 1218:0386), their client visible
    regions (in the DOS graphics without the windows the DOS art hides), the map window's menu bar (`w16q_menu_bar`),
    and the floats: the other shown top-level windows, the menu loop's popups with their shadows (`w16q_menu_saved`),
    the move or size outline (`w16q_sys_track`) and, in the DOS graphics, the A canvas's DOS boxes and drop-downs
    (`pdos_reskin_a_rects`).
  * `pwl_arrange` (pure): M is the bar's rectangle down to the client's bottom at the wider of the bar's and the
    client's widths; only the client's and the bar's visible pixels are copied, so the **scroll bars are never
    copied** (the part of M right of the client below the bar is black). W and S form one column on the side of their
    windows' mean centre, ordered by their tops, all from canvas y 0. Default layout: canvas 629x439 (M at 160,0;
    S raised by 46 rows, M by 22). The harness's 640x480 layout (map client 171..795 x 40..467): canvas 631x445.
  * Floats are anchored by their centre (W, S, else M), moved by the anchor's translation and clamped inside the
    canvas; a float larger than the canvas pauses WL (the frame as without WL).
  * `pwl_frame` / `pwl_peek`: the canvas from the visible frame, with the frame's damage translated piece by piece;
    `pwl_point`: the inverse map (topmost float, else piece; a black part or a gap returns 0, a press there is not
    delivered, F100); a latched press keeps its part (drags). `pwl_check`: the canvas against its definition.
* **present.c / present.h**: the visible frame passes through `pwl_frame`/`pwl_peek` while WL shows; relayout when
  WL's showing changes; `present_view_point` maps through `pwl_point`; `present_pointer_factors` from the canvas's
  layout; `present_set_windowless`, `present_windowless`, `present_windowless_showing`. E5 addition: `wl_due()` at the
  tick (a scene change, or damage of the base frame written between core presents: MZW's World Map rectangle patch,
  `pmap_smrect.c`, which without it was not on the canvas at map zoom -1/+1).
* **arrive.c**: the press latch keeps the WL part. **pmap** (pmap_layer.c, pmap_input.c, pmap_zoom.c, pmap_dos.c):
  the map layer follows M (the canvas's layout, M's translation, the floats as cuts, the wheel anchor through the
  view point).
* **platform/win32/host_win32.c/h**: the item, its mark in `hw_update_menu`, the `civ_command` case,
  `hw_set_windowless`, `hw_set_windowless_hook`; grayed under CIV_OBSERVER 0. **win64**: `--windowless 0|1`, the
  civ64.cfg key `windowless` (1/0, anything else absent = off) through the hook, the start state (command line, else
  the key, else off).
* **Harness**: `--windowless 0|1`, script command `windowless on|off` (both refused under CIV_OBSERVER 0, exit 2);
  presented.log ` wl CWxCH` / ` wl MISMATCH` on show lines, the end line `wl shows S pauses P arranges A mismatches M`,
  `HARNESS_WL_MISMATCH`; while WL is used, the fact lines `wl arrange|bar|popup|windows|view` (guarded by
  CIV_OBSERVER) that ext_wl.py builds its points from.

## Deviations

1. Display grows from 7 to 9 entries (the item and a separator): a recorded deviation from HM's fixed layout
   (orchestrator's answer 1). test_hm's tables move with it.
2. The floats are read in wl.c through pdos_reskin's queries directly, not through a new profile.h callback as the
   brief's section 11 proposed (fewer files; same data).
3. M takes the bar's full width; below the bar's end, right of the map client, a 16-pixel strip is black (where the
   vertical scroll bar was). The bar's titles are therefore always inside M.
4. Covered parts are black: where a float or another of the three windows covers a piece on the virtual screen, that
   part of the piece shows black on the canvas (24 rows beside a dialog centred over the Status column at the default
   layout; the World Map's last 10 rows while the Status window's caption lies over them). Content is never invented.

## Tests

* `tests/test_wl.c` (new, 51 checks Checked/Release, 18 CheckedNoObs): the arrangement (default, narrower bar, column
  right, order, hidden W, no column, no map), floats (anchors, clamp, pause), composition against an independent model
  (black strip, damage, float removal), **the scroll bars painted with a colour the frame never has: none on the
  canvas, no canvas point maps onto them**, **the World Map click (canvas 80,51 -> frame 83,73, part W) and a play-map
  left click (canvas 182,228 -> 190,250, part M)**, the inverse map cases, N frames, the facade (2x layout, view
  point, game screen equal on/off), the NoObs refusal. Fails on the base (the module does not exist).
* `tests/win32/test_host_win32.c`: test_hm's Display table 9 entries, the real menu loop's item twice, `--windowless`
  parsing, `test_wl_host` (place, separator, mnemonic, command, marks, hooks, start state, NoObs gray and refusal, the
  cfg key written only after a change). 453 -> 469 checks (CheckedNoObs 423).
* `tests/harness/ext_wl.py` (new test.cmd section `ext_wl`): the input pairs wl-win and wl-dos, a windowed run A
  against a windowless run B (`--windowless 1`), 1280x960, host-form input: the bar's Help title, the Game Help item,
  the message box's OK (wl-win); the DOS bar's GAME zone, the drop-down's Luxuries row, the luxuries box's row
  (wl-dos); both: the World Map twice (the second west), the Status window, a press in a gap (B only; at the harness's
  layout the canvas has no interior gap, so a point of the layout's black border above the canvas: not delivered),
  two play-map left clicks, a drag from the map onto W's piece. Compared: coreinput.log, frames, snapshot/result,
  events, exit; DOS also adapt.log's decisions. Asserted: every action on its intended part, the gap's events 0, the
  canvas never paused and always as defined, and **the play map's view moved at both World Map clicks and both
  play-map clicks** (staging: worldmap +0,-32; worldmap-west -1024,-32; map-west -288,+0; map +96,-128 world pixels,
  both graphics). `WL_PAIRS_OK checks 15`, about 73 s.
* `tests/harness/ext_p0.py`: V9 (`--windowless 1 --host-size 1280x960`, every run), V9d (+ DOS, switch every 997 ms;
  the play runs), V9t (`--host-size 1920x1440`, commands every 1,103 ms `windowless on`, `zoom +1`, `windowless off`,
  `zoom reset`; the play runs): the core's outputs equal V0, `wl shows` > 0, mismatches 0; CheckedNoObs V5 adds the
  refusals of `--windowless 1` and the command.
* Agent check on a private civ64: not run (usage; the brief's section 12 lists it). The headless relation (every
  canvas pixel as defined, ext_p0 V9*) and the input pairs cover the picture's definition and the mapping; the
  user's checks below cover the real window.

## For the records

* **FIDELITY** (numbers from F322):
  * **F322** the windowless canvas (present/wl.c): the three windows' clients and the map window's bar stitched into
    one picture without chrome; presentation only, the game screen and the core unchanged (P0); under integer
    scaling the canvas is centred with black borders of about the removed chrome times the factor (orchestrator's
    answer 5).
  * **F323** no scroll bars in windowless play, in either graphics (the user's direction of 2026-10-18 about 06:20
    UTC): the map window's WS_HSCROLL/WS_VSCROLL bars (style 0x02FF0000 at 1208:0B4E) are not shown; the play map
    moves by a World Map click and by a left click on the play map, as windowed; the strip where the vertical bar was
    is black below the bar.
  * **F324** covered parts black (deviation 4) and the pause for a float larger than the canvas (orchestrator's
    answer 4).
  * **F325** Display 7 -> 9 entries ("Windowless play" and a separator first; deviation 1) and the floats read
    directly in wl.c (deviation 2).
* **DESIGN**: a new section "Windowless play" (present/wl.c, the seams in present.c, arrive.c, pmap, host, win64);
  12.11's P0 list gains WL; 12.2's menu gains the item.
* **RUNNING**: `--windowless 0|1`, the cfg key `windowless`, the menu item, the harness option, command and log
  lines, ext_wl.py and ext_p0's V9, V9d, V9t.
* **FEATURES**: a host row "Windowless play" (both graphics).
* Docs other than this record are unchanged in this landing (E5 direction); a docs pass applies the above.

## What the user checks

* **WL-1** In a running game, open civ64's window menu (right-click civ64's own title bar) and then Display: its
  first item is "Windowless play", followed by a separator. Choosing it switches windowless play on at once (a check
  mark appears) and choosing it again switches it off, in the Windows graphics and in the DOS graphics
  (Ctrl+Shift+Backspace switches the graphics).
* **WL-2** With windowless play on, the map, the World Map and the Status panel form one picture without title bars,
  frames or borders: the World Map above the Status panel on the left, the map on the right, the menu bar on top of
  the map. Both graphics.
* **WL-3** With windowless play on, no scroll bars are visible anywhere, in the Windows graphics and in the DOS
  graphics. (Right of the map, below the menu bar's end, a narrow black strip is where the scroll bar was.)
* **WL-4** With windowless play on, a click on the World Map jumps the play map to that place, as without windowless
  play. Both graphics.
* **WL-5** With windowless play on, a left click on the play map moves the map to that place, as without windowless
  play. Both graphics.
* **WL-6** With windowless play on, the menus of the menu bar, message boxes and dialogs open over the picture and work
  with the mouse and the keyboard. A dialog over the Status panel may have a black strip beside it (recorded). A click
  on a black area does nothing.
* **WL-7** The setting is remembered: close civ64 with windowless play on and start it again, it is on again; switch
  it off, close and start again, it stays off.
* **WL-8** Windowless play works with full screen (Alt+Enter), the Display scaling choices and the map zoom (the
  World Map's view rectangle follows the zoom). Under the whole-number scaling, black borders around the picture are
  expected.
* **WL-9** Before the game (the intro, the title menu, the setup) and on the DOS graphics' full-screen scenes (for
  example the city screen), the picture is the same as without windowless play.

## Expected changes at the build slot

* Unit tests: new `test_wl` (51 checks); `test_host_win32` 453 -> 469; test_present 956 and test_map 342 unchanged.
* test.cmd: new section `ext_wl` (est 90 s): `WL_PAIRS_OK checks 15`. ext_p0 gains V9, V9d, V9t (more runs and
  checks, all core outputs equal V0) and CheckedNoObs V5's WL refusals.
* Goldens: none (WL is off by default; ext_g1 unchanged). P0 holds by construction (off: every pwl path returns at
  once) and by V9*.
* Coverage: the new file present/wl.c; no FEATURES row changes in this landing.

## Rebase notes

* Staged against the tree after D7n (E4). E5 rebased onto the tree after D7g..D7o and D8: of 20 code bases only
  tests/headless/harness.c, tests/harness/ext_p0.py and test.cmd had moved; 3-way merged (harness.c: D7o's scenes
  block and WL's facts block both kept; in `shown()` WL's declaration before D7o's `scenes_line`). The three docs the
  E4 stage carried unchanged were dropped. Staged files that had been written CRLF while their tree originals are LF
  were normalised to LF.
* E5 staging fixes: the CheckedNoObs build (harness.c's WL fact block under `#if CIV_OBSERVER`); the tick's
  `wl_due()` (MZW's patch, found by ext_p0 V9t); ext_wl.py's gap point at a layout border and its view field index.

## Landing

* Copy-in 2026-10-18 21:15:59 UTC (`build/wl-prep/land.py --write`: 20 changed files, 5 new; every base equal to the
  tree; `build/wl-prep/landed.sha256`, `tree-before/`, `before/`).
* Cycle (`build/wl-prep/wl-cycle.ps1 -LastStep 4`, status `build/wl-status.txt`): 1 build.cmd checked BUILD_OK
  21:20:50 UTC (261 s); 2 test.cmd checked TESTS_OK 21:53:07 UTC (1,937 s); 3 ext_g1.py check EXT_G1_OK runs 77
  (amended 1, unchanged) 21:53:07 UTC: all three green; 4 build.cmd (Release) BUILD_OK 21:56:38 UTC, RELEASE_OK.
* Counts as predicted (`build/wl-prep/predictions.txt`): test_wl 51; test_host_win32 453 -> 469; WL_PAIRS_OK checks
  15; P0_OK checks 577 (D7o's 477 plus V9, V9d, V9t); EXT_ADAPT_OK 389, ZOOM_OK 628 samples, OBS_LINT 154/203/103,
  REGISTRY_OK, NODOS_OK, COVERAGE 674 unchanged. No golden changed.
* User build `build/user-builds/wl/` (Release civ64.exe, CIVWIN.zip, civdos.zip, CAE3540B.SAV, WHAT-TO-CHECK.txt
  with WL-1..WL-9). Not run in this landing: the CheckedNoObs and Release test suites (staging ran them privately on
  the overlay: unit tests, Win32-headless and ext_p0 CheckedNoObs V5 green) and the agent check on a private civ64.

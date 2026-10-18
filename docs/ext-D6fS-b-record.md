# Extension phase D6, unit D6fS-b (the DOS game's menus in play: the DOS bar, the DOS menus and ORDERS, the DOS keys and highlight) - record

Draft for the build slot (unit D6fS, extension session E4; the orchestrator's rulings of 2026-10-17 about 08:20 UTC split
D6fS into D6fS-a, `ext-D6fS-a-record.md`, landed 2026-10-17 (copy-in 13:36:26 UTC), and D6fS-b, this record).  Staged in
`build/d6fsb-stage/` on the tree after D6fS-a's landing (`build/d6fsa-status.txt` ALL_GREEN 14:19:04 UTC, RELEASE_OK
14:25:51 UTC; manifest `build/d6fsa-prep/landed.sha256`), the docs pass e4c (`build/docs-e4c-done.txt`), D7d's
landing (copy-in 14:57:21 UTC, manifest `build/d7d-prep/landed.sha256`; ALL_GREEN 15:29:05 UTC, RELEASE_OK 15:32:56
UTC), D7l's landing (copy-in 15:44:06 UTC, manifest `build/d7l-prep/landed.sha256`; ALL_GREEN 16:21:12 UTC,
RELEASE_OK 16:24:33 UTC) and D7m's landing (copy-in 16:34:07 UTC, manifest `build/d7m-prep/landed.sha256`;
ALL_GREEN 17:05:21 UTC, RELEASE_OK 17:08:34 UTC) and the docs pass e4d (`build/docs-e4d-done.txt`, 17:22 UTC; it
changed `docs/DOS-PROFILE.md`'s prose): the staged files whose bases D7d, D7l, D7m and e4d changed were rebased on
their landed files, and D7l's `tests/harness/ext_timeline.py` is staged for its spaceship run (Rebase notes); the
bases (`obj/base/BASES.txt`) are rechecked equal to the tree in `BASE-SHA256.txt`.  Private builds and runs in
`build/d6fsb-stage/obj/` only: an
overlay `obj/src` = the tree + the staged files (`obj/mkoverlay.py`), built with the tree's build.cmd and flags
(`obj/b.cmd`, `--nogen`), cc.cmd's stricter checks per file (`obj/cc.cmd`), the unit programs (`obj/ut.sh`) and the
harness runs from copies of the overlay's Checked harness (`obj/exe/`); every output under `obj/`; the tree's
build/gamedata, dosdata, cache and dos/disasm read only.  The base runs use a copy of the tree's own Checked harness
(`obj/exe/base-d7m/`, built by D7m's landing).

## Result

D6fS-b is staged and READY_TO_BUILD.  In the DOS graphics in play, the menu bar is the DOS game's own bar at 2x (GAME,
ORDERS, ADVISORS, WORLD, CIVILOPEDIA at the DOS places, no EDIT, CITY or HELP, never a title highlight), its menus are
the DOS game's own boxes with the DOS rows (GAME with View Replay and the disabled Save Game, Options with its marks,
ORDERS built per unit and square as the DOS listing builds it, ADVISORS, WORLD, CIVILOPEDIA) at their DOS places, each
row doing its job through the Windows command that does it, and the keys, mouse and highlight are the DOS ones as the
orchestrator's rulings H2, M2, 3 and 4 set them (the user's D6-1 answer and revision items 4 and 5).  Privately (the
tree after D7m + the rebased stage): Checked, CheckedNoObs and Release
BUILD_OK (portable sources 304), cc.cmd `CC_OK` for the eight changed C files in each variant, every unit program
passing (test_input 611, test_pdos_menu 43 new, test_pdos_reskin 147, test_dos 23257 against the staged goldens),
`EXT_ADAPT_OK checks 268` (D7m's 253 + 15 f6b lines; D7l's spaceship case reworked for the DOS WORLD box),
`EXT_TIMELINE_OK`, `ZOOM_OK` against the staged golden (its 240 `dos` lines regenerated: the 2x bar is in every DOS
view's hash), `EXT_FRAMES_OK`, `EXT_DBL_OK checks 4`, `OBS_LINT_OK files 140`, `ADAPT_OK rows 147 steps 27`,
`OBS_TABLES_OK`, `PASS pdos_scene_check`, `REGISTRY_OK`, `NODOS_OK`; on the base harness (the tree after D7m) every
f6b case's main line fails (10 of 15 checks).

## Status

READY_TO_BUILD.  Built: the DOS menu bar at 2x with the DOS game's five titles and its x / 60 zones (the ADVISORS /
WORLD boundary at 184, ruling 3); the DOS menus with their DOS rows (GAME with View Replay and Save Game's disabled
row, Options with its '^' marks, ORDERS built per unit and square as R:1C84:01D8 builds it, ADVISORS, WORLD with
SpaceShips' disabled row, CIVILOPEDIA) at their DOS places; the item map from each DOS row to the Windows command that
does its job; the DOS highlight exactly where the DOS listing draws one (ruling H2); the mouse through the w16 menu
loop's click model (ruling M2); the DOS keys in a menu box and in play (Alt+G/O/A/W/C, lone Alt and the other Alt keys
consumed, the hotkeys selecting without choosing, no wrap); the Options box open again after a toggle with the toggled
row highlighted (ruling 4); `W16qMenu.mouse` (a read-only field of the w16 menu query).  `PDOS_AA` 0x80000000 is
`PDOS_AA_DEAD` (the orchestrator's allocation).  Edit, City and Help have no DOS form: they are in the Windows graphics
only (the user's DOS rule of 2026-10-16).  None of UX5b's files is touched; build.cmd and test.cmd are unchanged (no
`BUILD-TEST-ADDITIONS.md`: the new `tests/test_pdos_menu.c` is built and run by their `tests\test_*.c` loops).

## The user's reports and the rulings

* The user, 2026-10-17 (STATUS "User directions", about 07:05 UTC): on D6-1, "1x is acceptable but menu items are
  looks like 2x, they have to be scaled effectively." and then "Changed my mind draw top menu at 2x, they all have to
  be consistent."; the revision list's items 4 and 5: "In game DOS Menus highlights selection, in real DOS game there
  is no highlighting present." and "DOS Menus still uses windows menu contents, DOS graphics shall exactly reflect DOS
  game menu and its contents".  D6-1, D6f-1 and D5-7's highlight part failed (rework D6fS; D5-7's size part was
  D6fS-a's).
* The user's DOS rule (2026-10-16 about 06:10 UTC): "in DOS graphics never show a Go Back or Cancel row the DOS game
  doesn't have, on any screen; where DOS has a key for it (e.g. Escape), that key does it, otherwise that choice is
  only in the Windows graphics."
* The orchestrator's rulings (2026-10-17 about 08:20 UTC):
  - **H2 (the listing-exact highlight).**  The DOS menu box draws its highlight at R:1D05:0238..0332 whenever its row
    `cur` differs from the drawn one, from its opening (cur 0, or [2F9A] when not -1), Up and Down, a hotkey and a
    held press dragged over its rows.  The port highlights exactly there: never on a hover without a button, never a
    title.  (Item 4's "no highlighting" is read against the listing: DOS draws one; the D5-7 tax box's opening row is
    the current rate, R:0403:3673..367C.)
  - **M2 (the click model).**  The w16 menu loop's click model is kept (a click on a title opens its menu and leaves
    it open; a click on a row chooses it); DOS's quick click that closes the menu and DOS's idiv row 0 under the bar
    are recorded deviations.
  - **Ruling 3:** the ADVISORS / WORLD boundary at bar x 184 (DOS 180: the ADVISORS title is drawn over 128..183).
  - **Ruling 4:** the Options box stays open after a toggle (the DOS loop R:1C84:013B..0199 opens it again with the
    toggled row highlighted); fallback, if unworkable: close it, recorded as a deviation (not needed).
  - The checklist's D6fS-9 wording for H2: "move the mouse over a menu without pressing: no highlight; press Alt+G:
    the first row is highlighted; Down moves it; the tax box opens with the current rate highlighted".

## DOS facts (the listing, `build/dos/disasm/root.lst`)

* **The bar** R:0238:0FEA: the rectangle (0, 0, 320, 8) filled in colour 0 (R:0000:0BFA); the five titles of
  DGROUP:1D6F..1D8E at x 8, 64, 128, 192, 240, y 1 (R:0238:1011..1071) in colour 15 through R:0182:005C (87h after the
  first letter switches the rest to 7).  No title is ever recoloured: R:1C84 and R:1D05 draw no title highlight.
* **The menus** R:1C84:0000: with argument -1 (a press on the bar, y < 8: R:0403:0676..) the menu is x / 60 clamped to
  0..4 (R:1C84:0019..002E through R:1DC4:007C); the screen is saved (R:0866:25B6), then GAME R:1C84:00AD, ORDERS 01D8
  (civ, unit), ADVISORS 0615, WORLD 06E4 or CIVILOPEDIA 07AF; at the end [654A] = 1 redraws the screen (R:0238:1B44),
  0 restores it (R:0866:25D7).  Each menu is one menu box R:1D05:0000 at its DOS place: GAME (16, 8), ORDERS (72, 8),
  ADVISORS (112, 8), WORLD (144, 8), CIVILOPEDIA (182, 8); GAME's Options box (24, 16).
* **GAME** R:1C84:00AD: rows Tax Rate, Luxuries Rate, FindCity, Options, Save Game, REVOLUTION!, a blank row, Retire,
  QUIT to DOS (DGROUP:2BD4) and View Replay (DGROUP:2C30) when [4CD8] & 100h; Save Game (row 4) disabled when the turn
  [81D2] is 0 ([B276] = 10h, R:1C84:00B6..00BE); the jump table cs:01C0 (the blank row does nothing, R:1C84:01D4).
* **Options** R:1C84:013B: DGROUP:2C3E (the header "Options:" and eight rows), the '^' marks from [19C0] (D7F2,
  R:1D05:0939..0951); a choice toggles that option and sets [2F9A] to the row (R:1C84:0189), and the loop draws the box
  again (its highlight on that row); -1 (Escape) or the help flag ends GAME.
* **ORDERS** R:1C84:01D8: no box for unit -1 or 80h (R:1C84:01E0..01F0); the rows (their keys) in the order of
  R:1C84:023D..05B6: No Orders (' '); for settlers Add to City or Found New City ('b'), Build Road or Build RailRoad
  (railroad when the road is there and advance 31h is known, R:0ADE:22B5) ('r'), Build Irrigation (disabled without
  water next to the square, R:1C84:030F..0323, R:0403:3FD0) or "Change to" a terrain ('i') unless irrigated, Build
  Mines or "Change to" ('m') unless mined, Clean up Pollution ('p'), Build Fortress (disabled before advance 2Dh,
  R:1C84:0454..046F); Fortify for other land units; 'f' for every land unit; Wait, Sentry, GoTo ('w', 's', 'g');
  Pillage ('P') on an improved square for a unit type below 1Ah other than 0Eh; Home City ('h') in a city; Unload
  ('u') for a transport with units aboard; the last row (Disband, 'D').  The terrain names: DGROUP:0282 + 13h x
  [2BA6 + 2 colour] (R:1C84:034A..035D, 03C9..03DC).
* **ADVISORS** R:1C84:0615, **WORLD** R:1C84:06E4 (SpaceShips, row 5, disabled when ([4CD8] & FE00h) == 0) and
  **CIVILOPEDIA** R:1C84:07AF: six rows each (DGROUP:2DD6 + 2E32, 2E5D + 2EA5, 2ED1 + 2F25).
* **The box loop** R:1D05:0031: cur = 0 (R:1D05:006F) or [2F9A] when it is not -1 (R:1D05:0074..007B); the highlight
  at R:1D05:0238..0332 whenever cur differs from the drawn row.  Up (0368) cur > 0: cur - 1; Down (020B) cur < n - 1:
  cur + 1 (no wrap; disabled rows not skipped); Space or Return (0377) choose unless the row is disabled; Escape (0392)
  -1; keys above 20h (03E3): Alt+H (2300h, 0386) sets the help flag [2F9C] and chooses; Alt+V (2F00h, 039A) toggles the
  sound; otherwise the hotkey search R:1D05:03FD, 03B8..03E0 from cur + 1 (no wrap, the low five bits, [DC4A]) moves
  the highlight only (01C8).  The mouse (016A..01D9) while a button is down or after a press: the right button sets the
  help flag (0180..0187); row = (my - y - 4) / h by idiv - [B1EC] (018A..019E); x outside the box: -1 (01A1..01B2); a
  disabled row keeps the previous one (01B7..01C8); the release chooses (01CD..01D9).  The exit (0456) sets [2F9A] to
  -1.  The chosen row is recoloured 0Bh with the help flag, else [654C].
* **Play keys** R:0403:3ABD..3C40: Alt+G 2200h, Alt+O 1800h, Alt+A 1E00h, Alt+W 1100h, Alt+C 2E00h open the five menus
  (R:1C84:0000 with the menu); Alt+Q 1000h quit, Alt+V 2F00h sound, Alt+H 2300h help screens, Alt+R 1300h and Alt+M
  3200h (not compared, OPEN L3); no Alt+F, Alt+E or Alt+P; Alt alone does nothing (no menu key).

## Design and decisions

### The bar (the user's D6-1 answer: 2x)

* `pdos_menu_bar_draw` (new `present/dos/pdos_menu.c`) draws the DOS bar on a surface of ceil(w / 2) x ceil(h / 2) for
  a Windows bar rectangle of w x h A pixels, put on the A canvas at 2x over the Windows bar of the shown top-level
  window with a menu (D6f's element, `bar_update`): every row filled in colour 0, the five titles from the registry's
  MENU_TITLES at their DOS x, y 1, font 1, colour 15 with the 87h switch.  No Edit, City or Help title (they are in
  the Windows graphics only); no title highlight (H2).  D6f's 1x model drawing (`pdos_r_bar_draw`,
  `pdos_r_bar_title`, `pdos_r_menu_title`) and ruling 2's paired texts (`pdos_r_drop_dos_text`,
  `pdos_r_drop_dos_header`) are removed; `PdosRBar` keeps the Windows titles' rectangles with each title's DOS menu
  (`menu`, `pdos_menu_of`) for the item map.
* **The zones** (`pdos_menu_zone`): logical bar x = (A x - bar.l) / 2; the menu is x / 60 clamped to 0..4, except that
  184..239 is WORLD (ruling 3; DOS 180); `pdos_reskin_bar_zone` returns -2 for ORDERS without a box (below), -1 off
  the bar.

### The menus (pdos_menu.c, pure)

* `pdos_menu_spec(menu, facts, spec)` builds a DOS menu box's lines from the DOS program's own data read at run time
  (the registry's tables MENU_GAME, MENU_OPTIONS, MENU_ADVISORS, MENU_WORLD, MENU_PEDIA and the four new ones,
  MENU_ORDERS, MENU_REPLAY, TERRAIN_BY_COLOUR, TERRAIN_NAMES: `docs/dos/OFFSETS.md`) in the listing's order, its place
  (`pdos_menu_box_xy`), its disabled rows and marks, and each row's Windows command in the new `PdosRSpec.cmd[]`
  (`PDOS_M_GAP` for a row with no command, `PDOS_M_POPUP | c` for a popup item).  -1 without DOS data (the caller keeps
  the core's items, D6f's form); 0 rows for ORDERS without a unit.
* **The facts** (`PdosMenuFacts`, `pdos_menu_facts_read`): read from the core's emulated memory through the observer's
  reader (no core call, P0): the turn (g_gameTurn 12D8:42FE), the spaceship flags (12D0:00B6: View Replay & 100h,
  SpaceShips & FE00h), and, for the active unit (the core's blink probe of a unit below 80h with its Orders menu not
  grayed, g_ordersMenuGrayed 1420:2E9A: UpdateOrdersMenu grays it for unit -1 or 80h, DOS's no-box case), the unit
  (g_units 1420:62FC), its type (g_unitTypes 1420:1A38: domain, role), the square's improvements (GetTileImprovements's
  map-page pixels), its terrain's irrigation and mining effects (g_terrainByMapColor, g_terrainImprovementRules) and
  the advances 31h and 2Dh (g_civKnownAdvances).  `pdos_reskin.c` adds the two facts the core keeps in its menu: the
  Options marks (items 105..112 checked) and the water (Orders item 304 enabled when the square could be irrigated).
* **The item map:** GAME 102, 103, 104, the Options popup (`PDOS_M_POPUP | 105`), 101, 113, none (the blank row), 114,
  115, none (View Replay: the core has no command for it); Options 105..112; ORDERS by the row's key (' ' 301, b 302,
  r 303, i 304, m 305, p 306, f 307, w 308, s 309, g 310, P 311, h 312, u 313, D 318); ADVISORS 401..406, WORLD
  501..506, CIVILOPEDIA 601..606 (resources.md MENU 128).  `map_rows` gives each row its Windows item's rectangle in
  the open popup; a row whose item the core grays is marked `PDOS_R_CMD_GRAYED` (it does nothing when chosen); a row
  whose command the popup lacks has no rectangle (as a row without a command).
* **The drop-downs** (`drop_build`): a popup of a DOS menu (by its first command: File GAME, its Options popup
  OPTIONS, Orders ORDERS, Advisors ADVISORS, World WORLD, Civilopedia CIVILOPEDIA) is drawn as that DOS menu box at its
  DOS place, the bar's top-left + 2 x the DOS position; ORDERS without a unit has no box (the Windows popup stays hidden
  by D6fS-a's cover).  Edit, City and Help, which the DOS bar never opens, keep D6f's form if a profile switch shows
  one open.

### H2: the DOS highlight

* Each drop-down level keeps its own DOS row (`spec.sel`); the w16 loop's own selection is never shown.  A new popup
  opens at row 0 (R:1D05:006F), except level 1 opened by the mouse: while the button is down the DOS box's mouse code
  runs before its first highlight and the press on the bar is outside the box, so no row (-1).  `W16qMenu.mouse` (new:
  the loop's mouse mode, `user_menutrack.c`, read-only) tells which.  The Options box (level 2) opens at row 0, or at
  the toggled row when it opens again (ruling 4).
* The highlight then moves only by the DOS keys (the adapter's view: Up, Down, a hotkey) and by a press or a held move
  over the deepest drop-down's rows (`pdos_reskin_menu_mouse`); a hover without a button moves nothing, a title is
  never highlighted.
* The re-skinned MenuZ boxes (the tax and luxuries rates, the revolution question) are unchanged: their highlight is
  the core's MenuZ selection from its first key poll, the current rate at the opening as R:0403:3673..367C sets
  [2F9A].

### M2: the mouse (`pdos_reskin_menu_mouse`)

* Only the deepest drop-down is the DOS box in its loop.  On it a press and a held move put the highlight on the row
  under the point (a disabled row keeps the previous one, the header and the frame none: `pdos_menubox_row`, the DOS
  idiv) and go to the w16 loop at the Windows popup's top-left (on no item, so the loop selects nothing); the release
  on an enabled row with a command goes to the centre of its Windows item (the loop chooses it; an Options row also
  asks for the reopening), on a row without a command to a corner off the menus (the loop ends: DOS's blank row does
  nothing), on a disabled row or a grayed item to the popup's top-left (nothing).  A press or a release on a lower
  drop-down, or on a hidden popup outside every drop-down (D6fS-a), goes to a corner off the menus (the loop ends; DOS:
  outside the box, -1); a move there does nothing.
* On the bar (a press only, out of the menu loop; in it a press, a release and a held move): the centre of the Windows
  title of the DOS zone, so the w16 loop opens that menu; a move without a button goes to a corner off the menus (no
  title opens under a hover); the ORDERS zone without an active unit and a zone without a Windows title go to a corner
  off the menus (I-play/dead in play).

### The keys (`pdos_adapt_tab.c`, I-menubar on the AMENU state, I-play)

* In a menu box (the deepest drop-down is the adapter scene's box, `pdos_reskin_drop_top`): Up and Down move the DOS
  highlight (consumed, the view), the edges do nothing (no wrap), a row's hotkey moves it to the next row with that
  letter below it (no wrap, nothing chosen), Return and Space choose the highlighted row (`PDOS_A_DCHOOSE`: a left press
  and release at its Windows item, an Options row's reopening path after it; a row without a command or none
  highlighted: Alt down and up, the loop ends; a disabled row or a grayed item: nothing), Escape ends the loop
  (`PDOS_A_DEND`: Alt down and up; in the Options box GAME ends too, R:1C84:0168), Alt+V keeps D6f's sound row; Alt
  alone and every other Alt key (Alt+H's help flag included) and every other key are consumed (the w16 loop's own keys,
  its bar moves, Home, End and mnemonics are Windows-only); a right press is consumed with its release (the rows' help
  has no Windows menu form).
* In play: Alt+G, Alt+O, Alt+A, Alt+W and Alt+C open the GAME, ORDERS, ADVISORS, WORLD and CIVILOPEDIA menus through
  their Windows titles' mnemonics (I-play/game; D6f had Alt+G only, Alt+C and Alt+H kept the Windows City and Help
  menus); Alt+O without an active unit, Alt alone (DOS has no menu key) and a press on the dead ORDERS zone are consumed
  with their release (I-play/dead, `PDOS_AA_DEAD` 0x80000000); every other Alt key is consumed (I-play/altkey; Alt+F4
  is the host's); Alt+Q and Alt+V keep D6f's rows; a press on the bar goes to the zone's Windows title (I-menubar/title).
* The user's Alt is never passed in the DOS graphics: the w16 loop ends at a VK_MENU key down, and DefWindowProc arms
  the bar at an Alt press and opens it at the release; the produced paths (`put_alt`, `put_reopen`) post their own Alt
  down and up while the loop runs or to open a title.

### Options open after a toggle (ruling 4)

* A choice of an Options row (Return, Space or a release) clicks its Windows item (the core toggles the option and the
  w16 loop ends) and then posts the path that opens the Options popup again: Alt down, the File title's letter, Alt up,
  the Options item's letter (`put_reopen`).  The w16 loop posts the item's WM_COMMAND when it ends, behind the
  reopening keys already queued; the reopened loop dispatches it (a menu loop dispatches the messages that are not
  its keys), so the core toggles the option while the Options popup is opening again, and the player sees DOS's order:
  the toggle, then the box again.
* While the path runs, `pdos_reskin_reopen_hold` keeps both drop-downs and their highlights on the A canvas (the GAME
  box with the Options row, the Options box with the toggled row; D6fS-a's covers close normally) until level 2 is open
  again, a window shows, or 1 s of virtual time passes; the reopened Options box keeps the toggled row highlighted
  ([2F9A]).  Escape then ends the whole menu (DOS: -1 ends GAME).

### Choices

* **D6fS-b-1** (ruling 3): the ADVISORS / WORLD boundary at 184.
* **D6fS-b-2:** a DOS row whose Windows item the core grays (for example an ORDERS row the core cannot do for that
  unit now) is drawn as DOS draws it and does nothing when chosen (DOS's disabled-row case, R:1D05:0377); the DOS
  disabled rows (Save Game at turn 0, Build Irrigation without water, Build Fortress before advance 2Dh, SpaceShips) are
  drawn in colour 3 as DOS draws them.
* **D6fS-b-3:** View Replay (GAME's tenth row when [4CD8] & 100h) is shown and chosen like the blank row: the menu
  ends, nothing else (the core has no replay command).
* **D6fS-b-4:** a drop-down of Edit, City or Help shown in the DOS graphics (only when a profile switch finds one open)
  keeps D6f's form (the core's items at the popup's place).
* **D6fS-b-5:** the Options box after a toggle: the reopening path above (ruling 4's preferred form; no fallback).

## Deviations and limits

* **The quick click (M2).**  DOS opens the menu at a press on the bar and its box loop chooses at the release: a click
  (press and release) on a title ends the menu at once (the release is outside the box: -1), so DOS's menus are used by
  dragging.  The port keeps the w16 click model: a click on a title opens the menu and leaves it open, a click on a row
  chooses it; dragging works as in DOS.
* **The idiv row 0 under the bar (M2).**  DOS's row = (my - y - 4) / h truncates toward zero, so for a box at y 8
  without a header line (the five bar menus) the bar's pixel rows y 5..7 above it, inside its x range, are its row 0
  (a held press there highlights row 0, the release chooses it).  The port keeps those rows for the bar (the zone's
  title).
* **Help on a row.**  DOS's Alt+H in a box and its right button choose the row with the help flag, and the caller shows
  that row's help; the port consumes both (the help has no Windows menu form; Help > Game Help stays in the Windows
  graphics).
* **Dragging across the bar.**  DOS takes the menu once, at the press; with the button held over another title its box
  sees the pointer outside (-1).  The port's held move over the bar goes to the zone's Windows title, so the w16 loop
  switches to that menu as Windows does (a hover without the button switches nothing, H2).
* **Grayed rows and View Replay:** Choices D6fS-b-2 and D6fS-b-3.
* **Lone Alt:** consumed in play and in a box, as DOS has no menu key; Alt+H, Alt+R and Alt+M in play are consumed (DOS's
  help screens and its two driver keys are not compared, OPEN L3).
* The Windows popup the DOS box replaces is hidden by D6fS-a's covers; a DOS box at its DOS place can lie away from the
  hidden popup (GAME at (16, 8) and the File popup at the File title coincide; Options at (24, 16) lies over GAME as
  in DOS).
* `PdosMenuFacts` is read at each drop-down build; an ORDERS box open while the unit's square changes keeps its rows
  until the loop ends (DOS's box is modal too).

## What was built

* `present/dos/pdos_menu.c/.h` (new, pure, portable C; includes only `pdos_*.h`): the zones, the titles' x, the boxes'
  places, the bar drawing, `pdos_menu_of`, `pdos_menu_group`, `PdosMenuFacts`, `pdos_menu_facts_read`, `pdos_menu_spec`
  (the six menus; ORDERS's builder with its terrain names).
* `present/dos/pdos_reskin.c/.h`: `PdosRSpec.cmd[]` and `PDOS_R_CMD_GRAYED`; `PdosRBar`'s `menu`; the bar at 2x
  (`bar_update` with `pdos_menu_bar_draw`); `drop_build` (the DOS menus at their places, `map_rows`, `menu_facts`, the H2
  opening); the H2 state `g_h2` (per level: the popup, the reopening state, the presented highlights' log);
  `pdos_reskin_menu_mouse` (replaces `pdos_reskin_menu_point`), `pdos_reskin_bar_zone`, `pdos_reskin_orders_box`,
  `pdos_reskin_menu_choice`, `pdos_reskin_drop_top`, `pdos_reskin_reopen_hold`; the removed D6f bar and text functions;
  the `preskin` diag line's new fields `h2_cur1`, `h2_cur2`, `reopen`, `reopens`, `holds_ended`, `h2_log1`, `h2_n1`,
  `h2_log2`, `h2_n2` (the logs: each level's presented DOS highlight at each change, row + 1, 0 none, 15 no drop-down,
  four bits each, the first seven; the counts of changes).
* `present/dos/pdos_adapt.c/.h`, `pdos_adapt_tab.c`: the hooks `menu_mouse`, `menu_choice`, `reopen_hold`, `orders`,
  the AMENU scene's box from the deepest drop-down, `put_alt`, `put_reopen`, the acts `PDOS_A_DCHOOSE` and
  `PDOS_A_DEND`, the action bit `PDOS_AA_DEAD`; the I-menubar rows dead, edge, updown, hotkey, choose, escape, key,
  press, rpress (replacing key and press) and the I-play rows dead and altkey, with game, title and key rewritten.
  `gen/dos/adapters.py`: the two acts' texts and step counts.
* `platform/w16/user_menutrack.c`, `w16_obs.h`: `W16qMenu.mouse` (read-only; P0: no behaviour change).
* The registry: `docs/dos/OFFSETS.md` four rows (MENU_ORDERS, MENU_REPLAY, TERRAIN_BY_COLOUR, TERRAIN_NAMES),
  `present/dos/pdos_registry.c/.h` and `tests/dos-decoded.txt` regenerated (`gen/dos/registry.py gen`, unchanged);
  `docs/DOS-PROFILE.md` regenerated (`gen/dos/adapters.py gen`: the generated adapter section only).
* Tests: `tests/test_pdos_menu.c` (new), `tests/test_pdos_reskin.c`, `tests/test_input.c`,
  `tests/harness/ext_adapt.py` and `tests/harness/ext_timeline.py` (its D7l `space` run's host text, below);
  `tests/harness/ext-zoom-golden.txt` (its `dos` lines regenerated by `ext_zoom.py --update --profiles dos`; the
  `win` lines unchanged).

## Tests

* **The DOS menus in play, headless (`tests/harness/ext_adapt.py`, `d6fsb_runs`, after `d6fs_runs`).**  Six cases in
  play in the DOS graphics (S3's lines in host form, the profile chord at 40,000 ms, the actions from 55,500 ms, before
  S3's Space at 58,000 ms); each case's pair is the DOS run's posted input (coreinput.log) replayed in Windows form at
  the actions' times (`f6_replay`: the key, character, Alt and Ctrl context and the mouse messages as host lines) in a
  run without the chord, and the two runs' core outputs must be equal (`trace`: coreinput, frames, events, exit): the
  DOS form only posts what a Windows player could.  presentation-diag.log's `preskin` `h2_log1` / `h2_log2` give each
  drop-down level's DOS highlight as presented, in order; events.log's `menu` events the commands chosen:
  - f6b-keys: Alt+G, Down, Down, Up, Escape: highlights 15 1 2 3 2 15 (no drop-down, row 0 at the opening, rows 1, 2,
    1, closed), no command; decisions I-play/dead (the user's Alt), I-play/game, I-menubar/updown x3, I-menubar/escape;
    the GAME box placed (its rows 9 or 10).
  - f6b-tax: Alt+G, Return: 15 1 15, command 102, the tax box shown on the A canvas; Return closes it.
  - f6b-options: Alt+G, o (Options' hotkey), Return, Down, Return, Escape: level 1 15 1 4 15, level 2 15 1 2 15 (the
    Options box at row 0, Down, the toggle keeping row 1 through the reopening), command 106, one reopening held until
    the Options popup was open again (`reopens` 1, `holds_ended` 0, `reopen` 0).
  - f6b-gap: Alt+G, Down six times, Return on the blank row: 15 1 2 3 4 5 6 (and 7 later changes: `h2_n1` 9), no
    command, the menu ends.
  - f6b-hover: a click on GAME's zone, moves over rows 1 and 2 without the button, Escape: 15 0 15 (opened by the mouse:
    no highlight; the hover moves nothing).
  - f6b-drag: a press on GAME's zone, held moves over rows 0 and 1, the release on row 1: 15 0 1 2 15, command 103 (the
    luxuries box); Return.
  Three checks per case (two for the others): the highlights, commands, decisions and one switch; the replay's
  equality; f6b-options's hold; f6b-tax's box; plus the GAME box's place (15 lines).
* **D6f's and D6fS-a's cases reworked for the DOS menus** (the Alt keys, the item map and the Windows-only Help menu):
  f6-sound (Alt held, V <-> Alt, F, Alt up, o, u: the user's Alt consumed, the path's own Alt around its first
  letter); f6-cal (the Game Help message box opened in the Windows graphics and shown in the DOS graphics,
  `f6_msgbox`: the harness's `profile windows` / `profile dos` script commands, two more switches, no core change;
  Alt+W's DOS WORLD drop-down with six rows); f6-menu (a click on the DOS WORLD zone, a click on the DOS row 2 <-> the
  DOS run replayed: the zone's press and release posted at the Windows World title, the row's press at the popup's
  corner on no item and its release at item 503); f6-drag (the message box by `f6_msgbox`); f6-retesc (Retire's
  question opened through File > Retire in the Windows graphics, then shown in the DOS graphics); f6s-msgbox (the same
  message box), f6s-game (Alt+G, Escape), f6s-options (Alt+G, o, Return: levels 1 and 2; Escape).  Their criteria are
  unchanged.
* **D7l's spaceship route reworked for the DOS WORLD box** (D7l landed with World > Spaceships as Alt+W, s, the
  Windows mnemonic choosing the item; in the DOS box s only highlights SpaceShips, R:1D05:03FD): ext_adapt's
  d7l-space-dos and ext_timeline's `space` run add Return at 29 s (I-menubar/choose: the DOS row's click on item 506);
  d7l-space's Windows form replays the DOS run's posted menu input (`f6_replay` over the DOS form's menu actions,
  `D7L_ACTS`) and its first check counts two produced clicks, the second (the one at or after the Space,
  `d7l_downs`, `d7l_click` from that time) in the spaceship window.  Their other criteria are unchanged.
* **Unit tests.**
  - `test_pdos_menu.c` (new): the zones and the 184 boundary, the titles' x, the boxes' places, `pdos_menu_of`, the
    bar's drawing at the DOS resolution (fill 0, the five titles, the colour switch, no highlight), each menu's rows,
    commands, disabled rows and marks (GAME at turn 0 and with View Replay, Options, ADVISORS, WORLD with and without a
    spaceship, CIVILOPEDIA, ORDERS for settlers on several squares with road, railroad, irrigation with and without
    water, "Change to" with the terrain names, mines, pollution, the fortress, a land unit, a sea unit, a transport
    with a unit after it, Pillage, Home City, the blank row and Disband; no box without a unit), and the facts from a
    synthetic core memory (the map page's offset wrapping, unit 80h, a free slot, the grayed Orders menu, a failed
    read).
  - `test_pdos_reskin.c`: D6f's bar and text tests removed; `pdos_reskin_menu_mouse` on two drop-downs (hover, press,
    held move, disabled row, below the rows, the release on an item, an Options row's reopening, a disabled row, a
    grayed item, a row without a command, a lower drop-down, off every drop-down), `pdos_reskin_menu_choice`,
    `pdos_reskin_view_row` on a drop-down, `pdos_reskin_drop_top`, no bar no zone.
  - `test_input.c`: the AMENU rows (dead, edge, updown, hotkey, choose with an item, with the reopening path, with no
    row and on a disabled row, escape, key, press with the mouse model's points, rpress) and the I-play rows (a lone
    Alt, Alt+C, Alt+O with and without a unit, Alt+H, the bar's zones and the dead ORDERS zone); the table's rows
    (D7l's 138 + 9 = 147).
* **ext_zoom's DOS goldens** (`tests/harness/ext-zoom-golden.txt`, its `dos` lines regenerated): ext_zoom's view hash
  covers the whole host view, the bar included, so the DOS bar at 2x changes every DOS view in play (below).
* **On the base** (a copy of the tree's own Checked harness after D7m, `obj/exe/base-d7m/`; the same staged
  ext_adapt.py's D6fS-b runs): every f6b case fails (below).

## Results (private, `build/d6fsb-stage/obj/`)

On the overlay of the tree after D7m's landing + the rebased staged files, built with build.cmd's flags (the staged
`docs/DOS-PROFILE.md` was regenerated on the docs pass e4d's file after this run; its adapter section is unchanged
and `adapters.py check` on it gives `ADAPT_OK rows 147 steps 27`, `obj/mini7`):

* **Builds** (`obj/final.sh`, `obj/run/final.txt`, logs `obj/final-b-*.log`): Checked, CheckedNoObs and Release
  BUILD_OK, `portable sources checked: 304` (D7m's 303 + `pdos_menu.c`), no warning, no error.
* **Strict compiles** (`obj/cc.cmd`: c11 and c17 /W4 /WX and the clang C99 parse with warnings as errors) of
  `user_menutrack.c`, `pdos_menu.c`, `pdos_reskin.c`, `pdos_adapt.c`, `pdos_adapt_tab.c`, `pdos_registry.c`,
  `test_pdos_menu.c` and `test_pdos_reskin.c` in Checked, CheckedNoObs and Release: `CC_OK` in each
  (`obj/run/final-cc-*.txt`).  `tests/test_input.c` is left to build.cmd's compile (its line 176, from before this
  unit, fails clang-tidy's missing-field check, which build.cmd does not apply to tests).
* **Unit programs**, every program of each variant (`obj/ut.sh`, `obj/run/final-ut-*.txt`; 55 programs): all pass but
  test_dos, which reads the tree's goldens there (it takes `<gamedata>\..\..\tests\`); against the staged goldens
  (`obj/tdos/`) test_dos passes, 23257 checks, in each variant (`obj/run/final-tdos-*.txt`).  Against D7m's cycle
  (`build/d7m-2-test-checked.log`, `obj/utcmp.py`): test_input 579 -> 611, test_dos 23253 -> 23257, test_pdos_menu new
  (43); the other 52 programs' counts equal (test_pdos_reskin 147; the five Win32-host programs are not in `ut.sh`).
  CheckedNoObs: test_input 555, test_pdos_reskin 136 (the observer-only checks compiled out), test_pdos_menu 43,
  test_dos 23257; Release: test_input 611, test_pdos_reskin 147, test_pdos_menu 43, test_dos 23257.
* **ext_adapt** (the full staged script, `obj/runadapt_full.py`, harness `obj/exe/d7m/` = the overlay's Checked harness,
  root `obj/full5`, `obj/run-full5.txt`): `EXT_ADAPT_OK checks 268` (D7m's 253 + 15), every line PASS, D7d's, D7l's
  (reworked) and D7m's lines included.
* **ext_timeline** (the staged script from the overlay, `--exe obj/exe/d7m/civ_harness.exe --root obj/tl1 --port` the
  tree, `obj/run-tl1.txt`): `EXT_TIMELINE_OK`, 53 PASS lines; the `space` run's four lines PASS (the open at
  31,002,100 us after the Return at 29 s, the end by I-space/end at 34,001,100 us).
* **Checks** on the overlay (`obj/run/final.txt`): `OBS_LINT_OK files 140 probes 203 callsites 101`, `ADAPT_OK rows 147
  steps 27`, `PASS pdos_scene_check: 1084 checks, 141 scene rows, 10 font rows, 0 failed`, `OBS_TABLES_OK probes 203
  sites 101`, `REGISTRY_OK` (0 failures; the goldens equal the Python models' output, 1387 lines), `NODOS_OK` (655
  files, 0 hits); no present/dos file includes `input.h` or `<stdio.h>`; D6fS-b's HOST_EV_* uses are in
  `pdos_adapt.c/.h` only (`pdos_menu.c` and `pdos_reskin.c` use none; the other files' uses are the tree's).
* **ext_zoom** (the tree's ext_zoom.py with its golden file pointed at the staged copy, `obj/zoompriv.py`, harness
  `obj/exe/d7m/`): `--update --profiles dos` (root `obj/zoom3`, `obj/run-zoom3.txt`) wrote the 240 `dos` lines (`ZOOM_OK
  combinations 32 runs 36 samples 240`, `ZOOM_GOLDEN written 628 samples`; the 391 other lines byte-equal, CRLF kept);
  then without `--update`, `--profiles dos,sw` (root `obj/zoom4`, `obj/run-zoom4.txt`): `ZOOM_OK combinations 32 runs
  44 samples 240 map comparisons 6 centre runs 2 mzi runs 6 mzs runs 2 not zoomed 22/249`.  Why the DOS lines change
  (`obj/zoomcmp.py`, the base harness after D7d against the overlay's, one DOS combination, load 640x480 at -1): 458
  of 458 view pairs differ, every one only inside the box (179, 24)-(624, 35), the menu bar (D6f's 1x bar there
  before, the DOS bar at 2x now); ext_zoom's view hash covers the whole host view, the bar included.  The Windows
  lines are unchanged (D6fS-b changes nothing in the Windows graphics).
* **ext_frames** (the tree's script, `obj/frames_priv.py exe/d7m/civ_harness.exe frames2 -j 6`, `obj/run-frames2.txt`):
  `EXT_FRAMES_OK`.
* **ext_dbl** (the tree's script, `--harness obj/exe/d7m/civ_harness.exe --root obj/dbl2`, `obj/run-dbl2.txt`):
  `EXT_DBL_OK checks 4`, as the tree's.
* Not run privately (no host, core, rt or w16 behaviour change; their inputs never reach the DOS menus): ext_p0
  (its V7 chords are the host's and deliver no events), ext_mirror, ext_continue, ext_slots, ext_tld, ext_fce,
  ext_aspect, ext_bs, ext_replay, scenarios, p4tests, gate3b, uninit, present-goldens, ext_g1 and the Win32-host
  programs; the build slot's cycle runs them.

**Before the rebase on D7l and D7m** (the tree after D7d, `obj/run/final-d7d.txt`, harness `obj/exe/d7d/`): Checked,
CheckedNoObs and Release BUILD_OK (`portable sources checked: 302`), every unit program passing (test_dos against the
staged goldens, 23254), `EXT_ADAPT_OK checks 257` (D7d's 242 + 15; `obj/run-full3.txt`), `OBS_LINT_OK files 136`,
`ADAPT_OK rows 143 steps 27`, `REGISTRY_OK`, `NODOS_OK`, `EXT_DBL_OK checks 4`; on the tree after D7l
(`obj/run/final-d7l.txt`, harness `obj/exe/d7l/`): BUILD_OK (303), cc.cmd `CC_OK`, every unit program passing
(test_input 611, test_dos 23256 against the staged goldens), `OBS_LINT_OK files 138`, `ADAPT_OK rows 147 steps 27`,
`REGISTRY_OK`, `NODOS_OK` (its ext_adapt run was stopped when D7m landed).

**Before the rebase on D7d** (the tree after D6fS-a and the docs pass, the same D6fS-b edits; `obj/run/final-1.txt`,
harness `obj/exe/final/`): Checked, CheckedNoObs and Release BUILD_OK (`portable sources checked: 301`), cc.cmd
`CC_OK` in each variant for the eight changed C files, every unit program passing but two test checks of mine (below),
`EXT_ADAPT_OK checks 252` (the tree's 237 + 15; `obj/run-full2.txt`, root `obj/full2`), `OBS_LINT_OK files 134 probes
203 callsites 101`, `ADAPT_OK rows 139 steps 27`, `PASS pdos_scene_check: 1084 checks`, `OBS_TABLES_OK probes 203
sites 101`, `REGISTRY_OK`, `NODOS_OK` (643 files, 0 hits), no present/dos file including `input.h` or `<stdio.h>`.
That run found two wrong checks in the new `test_pdos_menu.c` (two ORDERS cases compared fewer commands than the box
has rows; the builder's rows were right: a private debug copy, `obj/dbg/`, printed them), corrected before the rebase.
test_dos read the tree's goldens there (it reads `<gamedata>\..\..\tests\`); against the staged goldens (`obj/tdos/`:
a private copy of the DOS files and the two test text files) it passed, 23247 checks, in the three variants.

**The f6b cases** (the full staged ext_adapt.py, `obj/runadapt_full.py`): every line PASS:
* f6b-keys: the GAME box placed (9 rows, at A 203,38: the bar's top-left 171,22 + 2 x (16, 8)); highlights
  [15, 1, 2, 3, 2, 15] and [15]; decisions I-play/dead, I-play/game, I-menubar/updown x3, I-menubar/escape; no
  command; equal to its replay (coreinput 38, frames 682, events 98).
* f6b-tax: [15, 1, 15]; command 102; the tax box on the A canvas (box 8352, 2 sets); decisions I-play/game,
  I-menubar/choose, then I-menu/return-escape on the tax box; equal to its replay (40, 680, 108).
* f6b-options: [15, 1, 4, 15] and [15, 1, 2, 15]; command 106; `reopens` 1, `holds_ended` 0, `reopen` 0; decisions
  I-play/game, I-menubar/hotkey, I-menubar/choose, I-menubar/updown, I-menubar/choose, I-menubar/escape; equal to its
  replay (48, 683, 110).  (A first form with the Escape at 58,000 ms met S3's Space there, a choice key in the box:
  the Escape moved to 57,700 ms.)
* f6b-gap: [15, 1, 2, 3, 4, 5, 6] (`h2_n1` 9); no command; equal to its replay (38, 682, 98).
* f6b-hover: [15, 0, 15]; I-menubar/title then I-menubar/escape; no command; equal to its replay (38, 682, 98).
* f6b-drag: [15, 0, 1, 2, 15]; command 103; equal to its replay (38, 679, 108).
* The reworked f6 lines: f6-cal (the DOS bar drawn, the DOS WORLD drop-down's six rows, the message box placed),
  f6-menu (the WORLD zone's press and release posted at the Windows World title's middle x 412, the DOS row's press at
  the popup's corner 385,39 and its release at item 503's centre), f6-sound (decisions I-play/dead, I-play/sound),
  f6-drag (three switches, no click posted), f6-retesc, f6s-msgbox (3 switches; 0 other pixels over the hidden
  window), f6s-game and f6s-options (the GAME box 186 x 162 at A 203,38, 9 lines; the Options box at 219,54) PASS.

**On the base** (`obj/exe/base-d7m/`: the tree's own Checked harness after D7m; the staged ext_adapt.py's D6fS-b runs,
`obj/runadapt.py ... b`, root `obj/runs/base-d7m`, `obj/run/adapt-base-d7m.txt`): `RUNADAPT checks 15 failed 10`.
Every f6b case's main line fails: no `h2_*` fields (D6f draws the w16 loop's selection); the base's GAME drop-down is
D6f's File popup (11 rows at A 171,39); Alt+G, Return chose command 101 (the File popup's first item) instead of 102
and showed no tax box (box 0, 0 sets); Alt+G, o, Return chose 105 and nothing reopened (`reopens` missing); the gap
case chose 114 and differed from its replay; in the box the keys were the w16 loop's (`I-menubar/key`); the hover case
had no `h2_*` log, and the drag (its press at the DOS zone, the base's bar at the Windows extents) chose nothing.
The other five replay-equality lines pass on the base (the
base's DOS form passes keys unchanged).  The same runs on D6fS-a's base harness (`obj/exe/base/`,
`obj/run/adapt-base-b.txt`) failed in the same way, 15 checks, 10 failed.  test_pdos_menu, the new test_input vectors
and test_pdos_reskin's D6fS-b checks need the new functions (no base form).


## Expected changes at the build slot

Copy-in: the 21 staged files at their tree paths (18 changed, 3 new: `present/dos/pdos_menu.c/.h`,
`tests/test_pdos_menu.c`) and this record as `docs/ext-D6fS-b-record.md` (`BASE-SHA256.txt` lists the bases and the
staged copies' hashes; CRLF kept for `present/dos/pdos_adapt.c/.h`, `tests/test_input.c` and
`tests/harness/ext-zoom-golden.txt`).  No build.cmd or test.cmd change.  Against the tree after D7m (its cycle
`build/d7m-2-test-checked.log`), test.cmd Checked:

* build: `BUILD_OK`, `portable sources checked: 304` (D7m's 303 + `pdos_menu.c`), no warning;
* unit programs: test_input 579 -> 611 (+32), test_dos 23253 -> 23257 (the four new tables' goldens), test_pdos_menu
  new (43), one more program; every other program unchanged (test_pdos_reskin stays 147: D6f's bar and text checks
  replaced by D6fS-b's drop-down checks);
* `EXT_ADAPT_OK checks 253` -> `268`: 15 new lines (f6b-keys 3, f6b-tax 3, f6b-options 3, f6b-gap 2, f6b-hover 2,
  f6b-drag 2), twelve more harness runs (six DOS-form cases, six replays); the reworked f6 lines keep their number
  (f6-cal, f6-menu, f6-sound, f6-drag, f6-retesc, f6s-msgbox, f6s-game, f6s-options with their D6fS-b texts);
* **D7l's spaceship case** (Tests): d7l-space's five lines keep their number; the DOS form gains Return at 29 s on the
  DOS WORLD box's SpaceShips row (s only highlights it), so its first line reads "2 clicks produced at [(501, 139),
  (320, 240)] (the DOS WORLD box's SpaceShips row, then a click in the spaceship window)" and the pair compares
  coreinput 15, frames 558; ext_timeline's `space` run gains the same Return (its four `space` lines and
  `EXT_TIMELINE_OK` unchanged; the open at 31,002,100 us);
* `ADAPT_OK rows 138 steps 25` -> `rows 147 steps 27`, `OBS_LINT_OK files 138` -> `140` (probes 203, call sites 101
  unchanged), `REGISTRY_OK` (68 tables), `NODOS_OK`, `OBS_TABLES_OK probes 203 sites 101` and `PASS pdos_scene_check:
  1084 checks` unchanged;
* ext-zoom: `ZOOM_OK` with its numbers unchanged against the staged `ext-zoom-golden.txt`, whose 240 `dos` lines are
  new (the DOS bar at 2x is in every DOS view's whole-view hash; the 391 other lines unchanged);
* presentation-diag.log's `preskin` line: the new fields (`h2_cur1`, `h2_cur2`, `reopen`, `reopens`, `holds_ended`,
  `h2_log1`, `h2_n1`, `h2_log2`, `h2_n2`) after the existing ones;
* unchanged (compare.py, host times left out): ext-p0 (`P0_OK checks 476`; its V7 chords are the host's), ext-frames,
  ext-dbl, ext-mirror, ext-continue, ext-slots, ext-tld, ext-fce, ext-aspect, ext-bs-*, ext-replay, scenarios,
  p4tests, gate3b, uninit, present-goldens and the Win32-headless sections (no host, core, rt or w16 behaviour
  change; `W16qMenu.mouse` is a read-only query field); coverage.txt's informational lines may change.

Step 3 `EXT_G1_OK runs 77` unchanged (presentation only).  Release build: `BUILD_OK` (built privately with the same
flags).

## Rebase notes

* Every staged file's base is in `BASE-SHA256.txt` and was equal to the tree when it was written.  If a file changes
  in the tree before the copy-in, its D6fS-b edits are blocks marked "extension D6fS-b" (a three-way merge on the base):
  - `docs/DOS-PROFILE.md`: only the generated adapter section (between `<!-- adapters.py: begin -->` and `end`) is
    D6fS-b's.  Its base is the tree's file after D7d's and D7l's landings and the docs pass e4d (marker
    `build/docs-e4d-done.txt`, 17:22 UTC; prose only); the staged copy is that file with `gen/dos/adapters.py gen` run
    on the staged table (`obj/mini7`: `ADAPT_GEN rows 147`, then `ADAPT_OK rows 147 steps 27`; the pre-e4d staged copy
    in `obj/premerge-e4d/`).  If the file changes again before the copy-in, take the tree's file and run
    `adapters.py gen` the same way.  If a D7 unit's landing changes the adapter table first:
    merge `pdos_adapt_tab.c` (D6fS-b's rows are the I-menubar block from "I-menubar/dead" to "I-menubar/rpress", the
    two `q_now_d*` step sequences and the I-play rows game, dead, altkey, key and title) and regenerate.
  - `docs/dos/OFFSETS.md`: four table rows (after MENU_PEDIA) and one note paragraph; `present/dos/pdos_registry.c/.h`
    and `tests/dos-decoded.txt` are `gen/dos/registry.py gen` and `goldens`'s output from it (registry.py itself
    unchanged by D6fS-b): after a merge of OFFSETS.md, regenerate them (`pdos_registry: 159 files, 67 tables` with
    D7d's seven and D7l's two).
  - `tests/harness/ext-zoom-golden.txt`: only its `dos` lines are D6fS-b's (regenerated by `ext_zoom.py Checked
    --update --profiles dos` with the overlay's harness).  If a landing changes the file first, run that update again
    on the merged tree (the `win` lines stay as they are).
* **The rebase on D7d** (copy-in 14:57:21 UTC, `build/d7d-prep/landed.sha256`; its cycle was in its test step when the
  stage was rebased, about 15:12 UTC): D7d changed the bases of `docs/DOS-PROFILE.md`, `docs/dos/OFFSETS.md`,
  `gen/dos/adapters.py`, `present/dos/pdos_adapt.c/.h`, `pdos_adapt_tab.c`, `pdos_registry.c/.h`,
  `tests/dos-decoded.txt`, `tests/harness/ext_adapt.py` and `tests/test_input.c` (and `gen/dos/registry.py`, not
  staged).  `obj/rebase_d7d.py`: `git merge-file -p` of the D6fS-b edits (base: the tree before D7d, equal to the
  manifest's "tree before" hashes) onto D7d's landed files, each checked against the manifest: clean for OFFSETS.md,
  adapters.py, pdos_adapt.c (CRLF), pdos_adapt.h (CRLF), pdos_adapt_tab.c and ext_adapt.py; two conflicts in
  `test_input.c` (CRLF), resolved by `obj/resolve_d7d.py`: the hooks' initializer (D6fS-b's `a_menu_mouse`,
  `a_menu_choice`, `a_reopen_hold`, `a_orders`, then D7d's `a_city`, the merged `PdosAdaptHooks` order) and the
  table's row count (D7d's 134 + 9 = 143, both units' notes).  Regenerated on the merge: the registry's three outputs
  (`obj/mini3`, D7d's registry.py: D7d's seven tables and D6fS-b's four, 65 tables; the goldens are D7d's lines plus
  D6fS-b's four) and DOS-PROFILE.md's adapter section (`obj/mini`: D7d's file, only D6fS-b's rows differ).
  `obj/install_d7d.py --write` put them into the stage (the pre-merge copies in `obj/premerge-d7d/`) and the tree's
  files into `obj/base/`.  No `PDOS_AS`, `PDOS_AA` or `PDOS_A` value clashes (D7d adds `PDOS_AS_CITY` 0x08000000,
  `PDOS_DEC_CITY` and the `city` hook; `PDOS_AA_DEAD` stays 0x80000000).
* **The rebase on D7l** (copy-in 15:44:06 UTC, `build/d7l-prep/landed.sha256`; its cycle was in its test step when the
  stage was rebased, about 16:20 UTC, so D7l's files were read from `build/d7l-stage/`, each equal to its landed
  hash): D7l changed the same eleven staged files' bases and `gen/dos/registry.py` (and seven files not staged here).
  `obj/rebase_d7l.py`: `git merge-file -p` of the D6fS-b edits (base: the tree after D7d, equal to D7l's "tree
  before" hashes) onto D7l's landed files: clean for adapters.py, pdos_adapt.c (CRLF), pdos_adapt.h (CRLF),
  pdos_adapt_tab.c and ext_adapt.py (`d6fsb_runs` before D7d's and D7l's calls in `main()`); one conflict each in
  `docs/dos/OFFSETS.md` (the two appended note paragraphs: D7l's, then D6fS-b's) and `tests/test_input.c` (the row
  count: D7l's 138 + 9 = 147, both units' notes), resolved by `obj/resolve_d7l.py`.  Regenerated on the merge: the
  registry's three outputs (`obj/mini4`, D7l's registry.py: 67 tables, 1386 golden lines; the outputs equal D7l's
  plus D6fS-b's four tables) and DOS-PROFILE.md's adapter section (`obj/mini5`: D7l's file, only D6fS-b's rows
  differ).  `obj/install_d7l.py --write` put them into the stage (the pre-merge copies in `obj/premerge-d7l/`) and
  D7l's files into `obj/base/`.  No `PDOS_AS`, `PDOS_AA` or `PDOS_A` value clashes (D7l adds `PDOS_AS_SPACE`
  0x20000000 and `PdosAdaptSc.l_hwnd`, and marks its Launch key with the existing `PDOS_AA_HOTKEY`; no hook, act or
  action bit).
* **The rebase on D7m** (copy-in 16:34:07 UTC, `build/d7m-prep/landed.sha256`; its cycle was in its test step, about
  16:50 UTC, so D7m's files were read from `build/d7m-stage/`, each equal to its landed hash): D7m changed the bases of
  `docs/dos/OFFSETS.md`, `present/dos/pdos_registry.c/.h`, `tests/dos-decoded.txt` and `tests/harness/ext_adapt.py`.
  `obj/rebase_on.py d7m` (the generic form of `rebase_d7l.py`): one conflict in each merged file, both two appended
  paragraphs (OFFSETS.md's notes; ext_adapt.py's docstring: D6fS-b's sentence closing D7l's spaceship paragraph, then
  D7m's end-of-game paragraph), resolved by `obj/resolve_d7m.py` keeping D6fS-b's then D7m's; `d6fsb_runs` stays
  before D7d's, D7l's and D7m's calls in `main()`.  The registry's outputs regenerated (`obj/mini6`, D7l's
  registry.py, which D7m does not change: 68 tables, 1387 golden lines, equal to D7m's plus D6fS-b's four tables);
  `obj/install_d7m.py --write` (pre-merge copies in `obj/premerge-d7m/`).  D7m changes no adapter file
  (`DOS-PROFILE.md`'s adapter section stays as staged).  Every result below is of the rebased stage on the tree with
  D7m unless it says otherwise.
  - `present/dos/pdos_reskin.c/.h`: the bar (`bar_update`), the drop-downs (`drop_build`, `map_rows`, `menu_facts`),
    the D6fS-b section (the H2 state, `pdos_reskin_menu_mouse` and its helpers, the diag fields); D6f's removed bar and
    text functions.  `present/dos/pdos_adapt.c/.h`: the hooks and acts named above (`put_alt`, `put_reopen`,
    `a_mapped`'s mouse type, `key_act`'s Alt cases).
  - `platform/w16/user_menutrack.c` and `w16_obs.h`: one line each (`W16qMenu.mouse`).
  - `gen/dos/adapters.py`: two entries of `ACTS`.
  - `tests/harness/ext_adapt.py`: the D6fS-b block after "# ---- end of extension D6fS-a ----", one call line in
    `main()` after `d6fs_runs`, the docstring's D6f and D6fS-b paragraphs, and marked lines in D6f's and D6fS-a's blocks
    (`F6_KEYS`, `f6_msgbox`, `f6_row`, `f6_zone`, `f6_points`, `f6_replay`, f6-sound, f6-cal, f6-menu, f6-drag,
    `f6_open`, f6s-msgbox, f6s-game, f6s-options), and in D7l's block (its docstring paragraph's last sentence,
    `D7L_CHOOSE`, `D7L_ACTS`, `d7l_downs`, the marked lines of `d7l_common`, `d7l_click` and `d7l_runs`).  A D7
    unit's block elsewhere merges without conflict.
  - `tests/harness/ext_timeline.py`: D7l's `space` host text (one comment line and the Return at 29,000 ms)
    and one sentence of the docstring's spaceship paragraph.
  - `tests/test_input.c` (CRLF): the a_* hook stubs, the row count (143 with D7d) and the D6fS-b vectors; `tests/
    test_pdos_reskin.c`: D6f's bar / text tests removed, the D6fS-b drop-down tests added.
* New files: `present/dos/pdos_menu.c/.h`, `tests/test_pdos_menu.c` (LF).
* `PDOS_AA` 0x80000000 is `PDOS_AA_DEAD`; the two acts `PDOS_A_DCHOOSE` and `PDOS_A_DEND` are appended before
  `PDOS_A_COUNT` (their numbers are stored nowhere: a D7 unit appending acts merges by order).  The clash D6fS-a
  reported (`PDOS_AA_LAUNCH 0x80000000u` in D7l's stage) is gone: D7l landed without that bit (its Launch key is
  marked with the existing `PDOS_AA_HOTKEY`), and no other stage under `build/` (D7e, D7f, D7g, D7m among them)
  stages a `pdos_adapt.h` with an action bit at 0x80000000 (checked when this record was written).

## What the user checks

On the coordinator's user build `build/user-builds/d6fsb/` (`civ64.exe`, DOS files present), in play (load a saved game
or start a new one) with the DOS graphics (`--graphics dos` or Ctrl+Shift+Backspace), the main map window active.

* **D6-1, rewritten for unit D6fS-b (the menu bar).**  At the top of the main window: the DOS game's menu bar at twice
  the size, like the DOS map and the DOS boxes: black, with GAME, ORDERS, ADVISORS, WORLD and CIVILOPEDIA at the DOS
  game's places (the first letter white, the rest gray), no EDIT, CITY or HELP, and no title ever highlighted (with
  its menu open or not).  A click on a title opens its menu; so does a click anywhere on the bar, each part of the bar
  belonging to one menu as in DOS (the black space after CIVILOPEDIA opens CIVILOPEDIA; the end of ADVISORS opens
  ADVISORS, the space just before WORLD opens WORLD).  ORDERS opens only while a unit is active.
* **D6f-1, rewritten for unit D6fS-b (the menus' contents).**  Each menu opens as the DOS game's own menu box at its
  DOS place below the bar (Options over GAME), at 2x, with the DOS game's rows only: GAME - Tax Rate, Luxuries Rate,
  FindCity, Options, Save Game, REVOLUTION!, an empty row, Retire, QUIT to DOS (and View Replay when the game has a
  replay), Save Game in the gray disabled colour on the first turn; ORDERS - only the orders the active unit can take
  on its square, as DOS lists them (for Settlers: Found New City or Add to City, Build Road, or Build RailRoad once
  Railroad is known, Build Irrigation (gray without water next to the square) or "Change to" a terrain, Build Mines or
  "Change to", Clean up Pollution where there is pollution, Build Fortress (gray before Construction); for other land
  units Fortify; then Wait, Sentry, GoTo, Pillage on an improved square, Home City in a city, Unload on a loaded ship,
  Disband); ADVISORS, WORLD (SpaceShips gray until a spaceship exists) and CIVILOPEDIA - their six DOS rows.  No
  Windows texts or keys beside the rows, no separator lines, no EDIT, CITY or HELP menu.  Each row does its job: Tax
  Rate opens the tax box, an advisor's row its report, an ORDERS row gives that order, Retire and QUIT to DOS ask their
  question.
* **D6fSb-1** (ruling H2, the highlight).  Click GAME (press and release): the menu opens with no row highlighted;
  move the mouse over its rows and over the bar without pressing: nothing is highlighted.  Press Escape, then Alt+G:
  the first row (Tax Rate) is highlighted; Down moves the highlight down one row, Up back up; at the first and the last
  row it stops (no wrap); Return on Tax Rate: the tax box opens with the current rate highlighted.  In short: **move
  the mouse over a menu without pressing: no highlight; press Alt+G: the first row is highlighted; Down moves it; the
  tax box opens with the current rate highlighted.**
* **D6fSb-2** (the mouse).  Press on GAME and, holding the button, move down over its rows: the highlight follows the
  pointer (a gray row keeps the last one); release on Luxuries Rate: the luxuries box opens.  Click GAME, then click
  FindCity: Find City opens.  With a menu open, click on the map: the menu closes and nothing is chosen.
* **D6fSb-3** (the letters).  In GAME (Alt+G) press R: the highlight moves to REVOLUTION! without choosing it; press R
  again: it moves on to Retire; press Return: the retire question; Escape.  A letter no row below the highlight starts
  with does nothing; so do Left, Right, Home, End and Alt.
* **D6fSb-4** (ruling 4, Options).  GAME > Options, then choose a setting (Down to it and Return, or click it): its '^'
  mark changes and the Options box stays open, with the setting just chosen highlighted, as DOS opens it again; choose
  it again: the mark comes back.  Escape closes both boxes.
* **D6fSb-5** (ORDERS).  With a Settlers unit active, open ORDERS (Alt+O or a click on ORDERS) on two or three kinds
  of squares (grassland, hills, forest, on a road): the rows change with the square as in DOS (D6f-1); choosing Build
  Road (or another order) gives that order to the unit.  When no unit is active (every unit has moved and the turn
  waits for its end), ORDERS does not open and Alt+O does nothing.
* **D6fSb-6** (the empty row and Escape).  In GAME, move the highlight to the empty row between REVOLUTION! and Retire
  and press Return: the menu closes and nothing happens.  Escape closes any menu; Alt alone, Alt+F, Alt+E and Alt+H do
  nothing in play (no Windows menu bar highlight, no menu).
* **D6f-4, rewritten for unit D6fS-b (Alt keys).**  Alt+G, Alt+O (with a unit active), Alt+A, Alt+W and Alt+C open
  GAME, ORDERS, ADVISORS, WORLD and CIVILOPEDIA with their first row highlighted; Alt+V switches the sound (GAME >
  Options shows the Sound mark changed); Alt+Q asks whether to quit.  Alt+H, Alt+F and Alt+E do nothing (the Windows
  City and Help menus are in the Windows graphics only).
* **D6f-5, rewritten for unit D6fS-b (message boxes in play).**  The Help menu is in the Windows graphics only: switch
  to the Windows graphics (Ctrl+Shift+Backspace), choose Help > Game Help, and switch back to the DOS graphics while its
  message box is open: the box is a DOS menu box at 2x with an OK row and no Cancel row; Return or a click on OK closes
  it; a press on OK dragged off the box and released over the map does nothing.
* **D6f-7, rewritten for unit D6fS-b (Escape on the questions).**  Ctrl+R (or GAME > REVOLUTION!), then Escape: the
  question closes and no revolution starts.  Alt+Q (or GAME > QUIT to DOS, or Ctrl+Q), then Escape: the question closes
  and the game goes on; again, GAME > Retire, then Escape on its question: the game goes on.
* **D5-7, its highlight part rewritten for unit D6fS-b.**  As D6fS-a's text, with the highlight: the tax box (Ctrl+T,
  `=`, or GAME > Tax Rate) opens with the current rate highlighted; Up and Down move the highlight (no wrap); Return or
  Space choose the highlighted rate; a press on a row, a drag to another row and the release there choose that row.
  The rest (no Go Back or Cancel row, the box moved inside near the screen's edge, Escape keeping the rate, the same
  with Ctrl+L, no Windows dialog beside the box or while it closes) is unchanged.

Not part of this check: the city screen and the other in-game screens (D7); the system menu's items (unchanged).

## For the records

* **F-new-1 (FIDELITY; replaces F196's as-built column):** the DOS menu bar in play is the DOS bar at 2x over the
  Windows bar: fill 0, the five DOS titles at their DOS x (8, 64, 128, 192, 240), y 1, font 1 from colour 15 with the
  87h switch (R:0238:0FEA..1071); no Edit, City or Help title (Windows graphics only, the user's DOS rule; report item
  R1 settled); no title highlight (R:1C84 and R:1D05 draw none; P24's highlight removed); the menu under a press is the
  DOS zone x / 60 (R:1C84:0019..002E) with the ADVISORS / WORLD boundary at 184 (Choice D6fS-b-1, ruling 3; DOS 180),
  replacing D6f's identity at the Windows title extents (C.12.8 review R3-2).  Choice B15 (1x) is reversed by the
  user's answer to D6-1.
* **F-new-2 (FIDELITY; replaces F197's as-built column):** each DOS menu is the DOS game's own menu box with its DOS
  rows at its DOS place (R:1C84:00AD..07C5: GAME (16, 8) with View Replay and Save Game disabled at turn 0, Options (24,
  16) with its header and '^' marks, ORDERS (72, 8) built per unit and square as R:1C84:01D8, ADVISORS (112, 8), WORLD
  (144, 8) with SpaceShips disabled, CIVILOPEDIA (182, 8)); each row maps to the Windows command that does its job
  (the item map); ruling 2's one row per Windows item, Choice D6f-3 (the core's texts with accelerators) and report
  item R2 (Windows separators, grayed ORDERS rows) are settled by the DOS rows.  A grayed Windows item's row does
  nothing; View Replay and the blank row end the menu (Choices D6fS-b-2, D6fS-b-3).  ORDERS without an active unit has
  no box (R:1C84:01E0..01F0).
* **F-new-3 (FIDELITY; F198 rewritten):** in play Alt+G, Alt+O, Alt+A, Alt+W, Alt+C open the five DOS menus (R:0403:
  3B72..3BB4) with row 0 highlighted; Alt alone, Alt+O without a unit and the dead ORDERS zone do nothing
  (`PDOS_AA_DEAD`); the other Alt keys do nothing (Alt+H's help screens, Alt+R, Alt+M not compared, OPEN L3); Choice
  D6f-5 / O3 (Alt+C and Alt+H keep the Windows City and Help menus) is reversed.  In a DOS menu box: Up and Down
  without wrap, the hotkeys selecting only (R:1D05:03FD), Return and Space choosing, Escape ending the menu, every
  other key nothing (C.12.8 I-menubar's pass of the loop's keyboard navigation replaced).
* **F-new-4 (FIDELITY; ruling H2):** the DOS highlight exactly where R:1D05:0238..0332 draws it: at the opening row 0
  (or the toggled Options row, [2F9A]), none for a menu opened by a press on the bar while the button is down, moved by
  Up, Down, a hotkey and a held press over the rows; never on a hover, never a title.  The re-skinned MenuZ boxes open
  at the core's selection (the tax and luxuries boxes: the current rate, as R:0403:367C / 3770 set [2F9A]).
* **F-new-5 (FIDELITY; ruling M2, deviations):** the w16 menu loop's click model: a click on a title leaves its menu
  open (DOS: a quick click ends it); the bar's y 5..7 over a headerless box stay the bar's (DOS's idiv makes them row
  0); a held move across the bar switches the menu as Windows does (DOS: -1 outside the box).
* **F-new-6 (FIDELITY; ruling 4):** after an Options toggle the Options box opens again with the toggled row
  highlighted (R:1C84:013B..0199): the Windows Options popup reopened by its menu path, the DOS drop-downs held until it
  is open (`pdos_reskin_reopen_hold`).
* **F-new-7 (FIDELITY; deviation):** DOS's help flag on a menu row (Alt+H in a box, the right button,
  R:1D05:0180..0187, 0386) has no Windows menu form: both are consumed.
* **DESIGN 12.9 "As implemented (D6fS-b)":** `pdos_menu.c/.h` (pure: zones, places, the bar drawing, the menus' rows,
  the facts and their reader), the item map (`PdosRSpec.cmd`, `PDOS_R_CMD_GRAYED`, `map_rows`), H2's state and log,
  `pdos_reskin_menu_mouse` (M2), the reopening hold, `W16qMenu.mouse`; draft B 11.2 / 11.3 and C C.12.8 / C.12.9 (the
  I-menubar and I-play rows, `PDOS_A_DCHOOSE`, `PDOS_A_DEND`, `PDOS_AA_DEAD`).
* **RUNNING.md:** presentation-diag.log's `preskin` new fields (`h2_cur1`, `h2_cur2`, `reopen`, `reopens`,
  `holds_ended`, `h2_log1`, `h2_n1`, `h2_log2`, `h2_n2`; D6f's `title_l` / `title_r` are the Windows titles'); ext_adapt's
  f6b-* cases (f6b-keys, f6b-tax, f6b-options, f6b-gap, f6b-hover, f6b-drag, each with its Windows-form replay) and the
  reworked f6 cases (f6-sound, f6-menu, f6-cal, f6-drag, f6-retesc, f6s-msgbox, f6s-game, f6s-options).
* **RUNNING.md / D7l's runners:** ext_adapt's d7l-space and ext_timeline's `space` run open World > Spaceships in the
  DOS graphics with Alt+W, s and now Return at 29 s (s only highlights SpaceShips in the DOS WORLD box); d7l-space's
  Windows form replays the DOS run's posted menu input, and its first check counts two produced clicks.
* **FEATURES.md:** the DOS game's menus in play (the bar at 2x, the DOS rows, ORDERS per square, the DOS keys and
  highlight, Options open after a toggle), with the runners above.
* **DOS-PROFILE.md** (prose; the generated adapter section is staged): row 121 (the bar: 2x, the DOS titles, the DOS
  zones, no highlight), the I-menubar / I-play paragraph (the DOS keys and mouse), the choice rows on Edit and Help (now
  Windows-only), D6f's "rows the DOS game lacks" list (settled).
* **OPEN L3:** Alt+O, Alt+A, Alt+W and Alt+C compared and implemented; Alt+H, Alt+R, Alt+M remain not compared.
* **manual-checklist-ext.md:** D6-1, D6f-1, D6f-4, D6f-5, D6f-7 and D5-7's highlight part rewritten as above; new
  items D6fSb-1..D6fSb-6 (D6fSb-1 carries the D6fS-9 wording); user build `build/user-builds/d6fsb/`.
* Not edited by this unit: DESIGN.md, FIDELITY.md, STATUS.md, RUNNING.md, FEATURES.md, the prose of DOS-PROFILE.md,
  manual-checklist-ext.md, the D1 drafts and the D0 documents.

## Landing

D6fS-b landed alone at the build slot of session E4, 2026-10-17, after D7m's landing (RELEASE_OK 17:08:34 UTC,
`build/user-builds/d7m/`) and the docs pass e4d (`build/docs-e4d-done.txt`, 17:22 UTC), landed by its implementer as
the orchestrator directed (its message of about 17:40 UTC: the slot held for D6fS-b, D6fS-a's landing protocol; HM
waits).  The user checks are in the user build `d6fsb`: D6-1, D6f-1, D6f-4, D6f-5, D6f-7 and D5-7's highlight part
rewritten and the new D6fSb-1..D6fSb-6 ("What the user checks").

* **Bases:** rebased onto the tree after D7d's landing (about 15:12 UTC), D7l's (about 16:20 UTC), D7m's (about 16:50
  UTC) and the docs pass e4d (about 17:30 UTC: `docs/DOS-PROFILE.md`'s adapter section generated on its file) (Rebase
  notes); the overlay built and checked again on the tree after D7m ("Results"); `BASE-SHA256.txt` written by
  `obj/mkbases.py` (BASES rows 22, problems 0; every base equal to the tree at 17:42 UTC) and rechecked by
  `build/d6fsb-prep/land.py` (every base equal, the three new files and the record absent, build.cmd and test.cmd
  unchanged; DRY_RUN_OK 22).  Scripts in `build/d6fsb-prep/`: `land.py` (from D6fS-a's and D7m's, for this stage's
  BASE-SHA256 rows with new files), `d6fsb-cycle.ps1` and `compare.py` (from D7m's), `mk_userbuild.py` (from
  D6fS-a's), `fill_stillopen.py` (from D7m's: the group "d7m" added; D6f-4, D6f-5, D6f-7 and D5-7 left to this
  build's own list; D6f's group D6f-2, D6f-3, D6f-6 and D6fS-a's D6fSa-1..3, D6f-8).  Snapshot
  `build/d6fsb-prep/before` (the tree's `build/test/Checked` outputs of D7m's cycle, 65 files) and `tree-before` (the
  eighteen replaced files); copy-in at 17:44:37 UTC (`landed.sha256`: the 22 files, build.cmd and test.cmd unchanged;
  `landed-at.txt` "unit d6fsb").  Predictions `build/d6fsb-prep/predictions.txt`, written before the copy-in.
* **The three-step cycle** (`build/d6fsb-status.txt`, each step guarded by its log's OK marker): 1 `build.cmd checked`
  BUILD_OK 17:44:46..17:48:17 (210 s; portable sources checked 304); 2 `test.cmd checked` TESTS_OK 17:48:17..18:16:46
  (1709 s; TEST_SECTIONS 30 failed 0; no flake rerun); 3 `ext_g1.py check` EXT_G1_OK runs 77 (amended 1) unchanged:
  **ALL_GREEN** (18:16:46 UTC).  4 `build.cmd` (Release) BUILD_OK 18:16:47..18:20:37 (231 s): **RELEASE_OK**.
* **Against the predictions** (`build/d6fsb-prep/compare.py` against the snapshot; `compare.txt`: 51 of 65 files
  equal, host times left out): as predicted, unit.log test_pdos_menu new 43, test_input 579 -> 611, test_dos 23253 ->
  23257 ("decoded content" 1383 -> 1387 lines; registry 64 -> 68 tables), every other count equal; registry-check
  REGISTRY_OK with the four tables' 17 `ok` lines and the include rule of `pdos_menu.c/.h`, the goldens line 1383 ->
  1387; dos-decoded.txt the four `table` lines; OBS_LINT_OK files 138 -> 140 (probes 203, call sites 101);
  adapters-check ADAPT_OK rows 138 steps 25 -> rows 147 steps 27; obs-tables and pdos-scene-check (1084) unchanged;
  EXT_ADAPT_OK checks 253 -> 268 (the fifteen f6b lines equal to the private run; f6-cal, f6-menu, f6-sound, f6-drag
  and f6-zcover-menu with their D6fS-b texts (the GAME box now at A 203,38..389,200, 29760 pixels); d7l-space's first
  line "2 clicks produced at [(501, 139), (320, 240)]", its pair coreinput 15, frames 556 -> 558); ZOOM_OK
  (combinations 32 runs 108 samples 628, as D7m's, against the landed golden), EXT_TIMELINE_OK, EXT_FRAMES_OK,
  EXT_DBL_OK checks 4, P0_OK checks 476, MIRROR_OK runs 29, REPLAY_OK checks 70, NODOS_OK (0 hits) and every other
  harness section as before.  Not predicted in detail, explained: (a) the A-frame show count after the spaceship
  screen 73 -> 72 in ext_timeline's `space` and ext_adapt's d7l-space (informational: the DOS WORLD box's Return and
  click at 29 s shift the run's show phase; the screen opens at 31,002,100 us instead of 31,001,100); (b) the f6
  lines' "one switch" wording now "1 switch" (D6fS-b's counter text) and f6-drag's 3 switches (its `f6_msgbox` path); (c) coverage.txt "other functions
  entered" 666 -> 667 (informational); (d) nodos files 1795 -> 1800, 0 hits; (e) unit.log's OBS_COST line (host
  timing).
* **User build** `build/user-builds/d6fsb/`: `civ64.exe` (the Release build, SHA-256 badc0a0e...), `CIVWIN.zip` and
  `civdos.zip` from `build/user-builds/d4/`, `WHAT-TO-CHECK.txt` (D6-1, D6f-1, D6fSb-1..D6fSb-6, D6f-4, D6f-5, D6f-7,
  D5-7, the earlier builds up to "d7m", and the 103 items still pending in the checklist at 17:44 UTC).
* Not done at this slot: the checklist sections and STATUS rows (the orchestrator's: D6-1, D6f-1, D6f-4, D6f-5, D6f-7
  and D5-7's highlight part rewritten, D6fSb-1..D6fSb-6 new, from "What the user checks") and the docs pass for D6fS-b
  ("For the records"); the tree's CheckedNoObs build is not part of the three-step cycle (the private overlay builds
  and units of the three variants are in "Results").

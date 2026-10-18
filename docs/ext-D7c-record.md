# Extension phase D7, unit D7c (the World reports and the historian) - record

Draft for the build slot (BRIEF-d7.md "Units" D7c, extension session E4, track A).  Staged in `build/d7c-stage/` on
the tree after the D7a+D7b landing (copy-in 08:07:35 UTC on 2026-10-17, RELEASE_OK 08:50:57 UTC,
`build/d7ab-status.txt`) and UX5b's copy-in (09:35:23 UTC, `build/ux5b-prep/landed-at.txt`; its cycle ALL_GREEN 10:49 UTC,
`build/ux5b-status.txt`; none of D7c's files among its 11): the base of every changed file is the tree's file as
landed, its hash recorded at the copy (`obj/base-at-copy.txt`, 09:23:45 UTC) and rechecked equal to the tree
(`BASE-SHA256.txt`, section "Rebase notes"); the overlay was made at 09:47 UTC, so the private results include UX5b's
landed files.  Landed by the build slot on 2026-10-17 (section "Landing").  Private builds and runs in
`build/d7c-stage/obj/` only: an overlay `obj/src` = the tree + the stage (`obj/mkoverlay.py`), built with the tree's
build.cmd and flags (`obj/b.cmd`, `obj/ball.py`, `--nogen`), cc.cmd's stricter checks per file (`obj/cc.cmd`,
`obj/ccall.py`), the unit programs and the harness runs from the overlay's binaries with every output under `obj/`; the
tree's build/gamedata, dosdata and cache read only.

## Result

D7c is staged and READY_TO_BUILD.  With the DOS graphics, the six World screens show as the DOS ones on D7a's N frame:
Wonders of the World, Top 5 Cities and Civilization Score on cyan, Demographics on blue, the historian's report on cyan
with its mini palaces, and the World Map as DOS draws it: the explored squares as 4 x 4 DOS terrain tiles over the whole
black screen, cities as 4 x 4 squares and units as 3 x 3 squares with a black shadow in the civilizations' colours.
Wonders of the World with no wonder built draws nothing, as DOS: the map stays and the next key or click returns.  A
key or a click closes each screen, as in DOS; there is no Go Back or Cancel row.  The screens are reached as they are
reachable now: the DOS menu bar's World menu (D6f) and F7..F10 (I-play/fkey: Ctrl+7..Ctrl+0, commands 501..504);
Demographics through the World menu only; the historian by itself during the game.  D6fSb's DOS WORLD menu will reach
them later.  Privately, on the tree after the D7a+D7b landing and UX5b's: the three variants build, every unit program passes in
each, the d7a, d7b and new d7c adapter pairs pass (the d7c pair: F10 in the DOS form against Ctrl+0 in the Windows form,
the map closed by a press), ext_p0 V0/V1/V2 on `menus` P0_OK with no counter on rows 73..77, and every check script
passes.

## Status

READY_TO_BUILD.  Built: rows 73 (Wonders of the World, O12:080D), 74 (Top 5 Cities, O3:09AC), 75 (Civilization Score,
O20:0CA9), 76 (World Map, O12:0000), 77 (Demographics, O12:0D6D) and 123 (the historian, O12:09E2) in the report
renderer's table, each with its DOS background and its end; their bodies drawn by the replay on D7a's frame and placed
by the call site where the listings draw them elsewhere (D7b's place hook, a D7c site table); Top 5's citizens (S13) at
R:0D12:6ED4's places; the World Map drawn whole in its DOS form from the core's world state (new
`present/dos/pdos_scn_world.c/.h`); the historian's mini palace as R:0238:14A3 with the core's slot tiles (S7 by
provenance); Wonders with no wonder built quiet (no N frame).  No new adapter row and no new PDOS_AS bit: the World
reports and the historian reuse D7a's `PDOS_AS_REPORT` (I-report, class X) through the renderer's state.  Not in the
unit: the power graph (D7m), the wonders in the city view (D7e), the Spaceships screen (row 78, D7l).

## What was built

### The six reports in the table

The six rows join the renderer's table (`present/dos/pdos_scn_report.c`, D7a's frame: the N scene, the DOS fill of the
window and port, the copies to page 0, the close by any key or click), each with the DOS background where it differs
from the opener's argument and with its exit kind (decision 3):

| Row | Report | Core | DOS | Background | Exit |
|---|---|---|---|---|---|
| 73 | Wonders of the World | ShowWondersOfTheWorld 1188:0B3E | O12:080D | 3 (O12:092A) | none (R:0866:25D7, O12:09D4) |
| 74 | Top 5 Cities | ShowTopFiveCities 1080:099B | O3:09AC | 3 (O3:0A98); the core 0 | none (O3:0C68) |
| 75 | Civilization Score | ShowCivilizationScore 1040:1137 | O20:0CA9 | 3 (O20:0CC9) | R:0238:1B44 (O20:0D34, 13EB) |
| 76 | World Map | ShowWorldMap 1188:013F | O12:0000(1) | 0 (O12:002D) | none (G#20 back, O12:0381..0399) |
| 77 | Demographics | ShowDemographicsReport 1188:123A | O12:0D6D | 1 (O12:0D80); the core 0 | none (O12:1958) |
| 123 | the historian | ShowHistorianReport 1188:0DB8 | O12:09E2 | 3 (O12:0A03..0A17) | none (O12:0D5D) |

OpenBlankReportScreen 1188:0000 (rows 73, 74, 76, 77, 123) has the background as its only argument; the frame reads it
there (D7a read the third word of OpenReportScreenWithHeader).  The core's ProcessCity(city, -1) inside Top 5 (1080:0BE8),
the Score (1040:1376), Demographics (1188:13B5) and the historian (1188:0F08) holds row 97 as City Status's does (DOS
R:0D12:0045(city, -1) at O3:0B9D, O20:0E63, O12:0E6B: a computation).

### The places by call site (D7b's place hook; ruling 4)

A second site table in `pdos_scn_report.c` (`g_sites_c`, after D7b's table, each with its listing address) changes the
replayed primitives where the listings draw them differently:

* **Wonders of the World (O12:080D):** the title as R:0182:0086 draws it: at (64h, 0Ch), not centred, its shadow in 0 one
  row below (O12:0946..0956; the hook draws it); each wonder's frame R:1D05:0A05(8, y, 12Fh, 0Fh, [1946h + 2 owner])
  with its inclusive corners (O12:0891..08A9; the core's FrameRectLogical(8, y - 2, 12Fh, 13h, owner + 10h)); its icon
  R:0D12:7045(w + 18h, 10h, y + 3), 2 lower than the core's (O12:08B1..08C8).
* **Top 5 Cities (O3:09AC):** the title at (50h, 0Ch), not centred (O3:0AB4..0AC4); each row's name R:0182:00B3 centred
  at (A0h, y + 3) in [1946h + 2 owner] (O3:0B72..0B8E; the core's colour 15): the hook keeps it until the row's
  ProcessCity (1080:0BE8) names the city, then draws it in the owner's colour; the citizens as R:0D12:6ED4(city, 30h, y
  + 0Ah, specialists, A0h) places them (O3:0BA5..0BC0; the core's DrawCityPeopleRow(city, 18h, (y + 10) * 16 / 10,
  specialists, FAh)), with D7b's derivation from the core's sequence (the pitches 7 and A0h / n); the wonder icons left to
  right from 30h + clamp(8 size, 0, A0h) + 8, 13h apart, while x < 125h (O3:0BA5..0C1A, R:1DC4:007C the clamp,
  O3:0BFA..0BFF the stop; the core's from 119h right to left, 18h apart: the j-th icon by the core's x); the frame
  R:1D05:0A05(8, y, 12Fh, 19h, [1946h + 2 owner]) (O3:0C27..0C4B; the core's (8, y - 1, 12Fh, 1Eh, owner + 10h)).
* **Civilization Score (O20:0CA9):** the wonder lines begin 10h below the citizens (O20:0EF9..0EFF; the core's 12h,
  1040:1513) and end 0Ah above the next line (O20:1053; the core's 0Ch, 1040:16CC): the achievements line 2 higher
  (O20:1032..1041), each wonder's icon R:0D12:7045(id, x, y - 2) on DOS's line (O20:0F80..0F8C; the core's line + 0, -2
  or +1 by g_scoreRowSpacing, 1040:152E..1545), its name R:0182:005C(name, x + 14h, y, 11) (O20:0F94..0FAC; the core's
  x + 18h, colour 14), the SpaceShip line, the pollution, peace and future line and the total 4 higher (O20:10FD..110C,
  124E..125D, 1319..1328).
* **Demographics (O12:0D6D):** the best civilization's text ending at 13Eh by the DOS width, in [1946h + 2 civ]
  (O12:1B24..1B4A: R:0182:005C(text, 13Eh - R:0182:00EF(text), y, colour); the core's width and colour civ + 10h); the
  rows, labels, rank lines and values are at the same places as the core's.
* **The historian (O12:09E2):** each civilization's frame R:1D05:0A05(8, y, 12Fh, 0Fh, [1946h + 2 civ])
  (O12:0CD5..0CE8; the core's (8, y - 2, 12Fh, 11h)); the headings, rows and texts at the core's places.

### The World Map (O12:0000; `pdos_scn_world.c`)

DOS draws the explored world 4 x 4 over the whole screen; the Windows game draws 6 x 6 device squares in a frame.  The
core's map drawing on the report port (DrawMapTile, its FillRect and FrameRect calls) and its copies to the window
(CopyPortToWindow 1188:073B) are dropped; at the report port's GR_PortOpen exit inside OpenBlankReportScreen (after the
window's fill, 1188:009D) the DOS map is drawn into the report window's shadow, which shows it on page 0.  The content is
the core's world state as D6e's small map reads it (B 12.2, B17): g_humanPlayer, g_revealAll (DOS DGROUP:D806, the
reveal-all flag of SCENES-PLAY 7.3; the pairing inferred), g_capitalX[human], g_tileVisibility, the map page
(g_lpScreenBuffer: the terrain colour at (x, y) through g_terrainByMapColor, the improvements at (x, y + 100), the
occupancy at (x + 160, y)), g_cities and g_units.  Both DOS callers pass 1 (R:0403:3492, R:1C84:079C): terrain tiles,
not O12:0182..01A5's argument-0 fills; DGROUP:B278's world mode is not used (OPEN L2).

* **The layout** (O12:0048..0177): x offset 28h - the human's capital x (O12:006B..0078); y offset 19h - (min + max) / 2
  (truncated toward 0) over the y of the human's units (type not FFh, O12:008D..00E1) and cities (owner the human, no
  status test, O12:00E3..012B), 0..31h when row 0 or row 49 is seen anywhere (O12:012D..0165); with D806 both offsets 0
  (O12:007B..008A).
* **A square** (O12:017A..0372, rows then columns) is drawn when the human has seen it (visibility & 1 << human) and its
  row y + y offset is on the map (R:1AEA:1326), or always with D806 (O12:02B6..02EB): at (4 WrapMapX(x + x offset), 4 (y
  + y offset)) (O12:02ED..030D; one wrap step) the 4 x 4 terrain tile of page 2 at (160 + 4t, 111 + 4((x + y) & 1)) by
  G#20 (O12:032A..0359).
* **A city** (the improvements' bit 0, O12:01A8..01B8; R:1DC4:00BA's city): not marked when its known size is 0, D806 is
  0 and its owner is not the human (O12:01D3..01EC); else R:0000:0BFA(sx, sy, 4, 4, [1946h + 2 owner]) with the
  occupancy's owner (O12:01EF..0208, 0296..02A2).
* **Units** (the occupancy's bit 3, O12:020F..0225): a foreign civilization's only when the unit R:1AEA:1458 finds there
  was seen by the human (its +9 visibleTo; a stale occupancy reads unit -1's byte, the byte 3 before the civilization's
  first unit, as DOS's index -1 does) or with D806 (O12:0228..0264): R:0000:0BFA(sx + 1, sy + 1, 3, 3, 0) then (sx, sy,
  3, 3, [1946h + 2 civ]) (O12:0266..02A2).
* A city bit with no city at the square draws no mark (the core's check, 1188:04A6; DOS would read city -1).
* The key wait follows (CloseReportScreen's, I-report); the map's end restores the play screen without a fade.

The state is read through the renderer's query (`w16q_read` in the product, an injected function in the tests); an
unreadable state (or a human player outside 0..7) draws nothing and is counted (`world_unread`).

### The historian's mini palace (R:0238:14A3; S7)

ShowHistorianReport draws DrawMiniPalace(civ, size, 160h, ((y - 4) * 16) / 10) per civilization (1188:118B..11B3); DOS
draws R:0238:14A3(civ, size, 80h, y - 0Dh) (O12:0CAD..0CCD): the ground line (x - 5, y + 13)..(x + 44h, y + 13) in
colour 2 (R:0238:14B1..14C5), then each built slot i at (x + 7i, y - 1) by G#32 (R:0238:16B6..16CD).  The renderer drops
DrawMiniPalace's own drawing on the port, keeps the handles of its slot DrawTiles (1088:1D7F: slot i at x + 14i), and at
its exit draws the ground line and each slot's DOS shape by provenance (S7, as D6e's status panel draws the palace) at
DOS's place; the row's y is the device y back to logical (pdos_logical_of_device, +4).  The frame drawn after it (O12:0CD5)
covers the ground line, as in DOS.

### Wonders of the World with no wonder built

O12:080D draws a page only for a built wonder (O12:0902..0925: [6EA8h + 2w] != -1 for w 1..21, O12:0910); with none its
y stays 999, nothing is drawn and DOS waits over the play screen (O12:09CF..09D9), the pointer hidden (O12:0813).  The
core draws its title and "None discovered yet!".  The renderer reads g_wonderCities at the opener: with none the report
is quiet: no N frame (the A frame stays), its window's and port's events dropped, the pointer hidden, the I-report rows
apply, no exit kind named (`quiets`).

### Counters

presentation-diag.log's `report` line gains `quiets`, `world_maps`, `world_squares`, `world_unread`, `palaces` and
`names` (Top 5's row names drawn in the owner's colour).  DrawMapTile's tiles on the World Map's port are not counted as
`tile_unknown`.

## Files

Changed (`BASE-SHA256.txt`; every base the tree's file after the D7a+D7b landing): `present/dos/pdos_scn_report.c/.h`
(the six rows, the site table, the World Map and palace hooks, the quiet report, `pdos_report_active`, the counters),
`present/dos/pdos_adapt.c` (the I-report scene while a report is active, quiet included: one condition),
`present/dos/pdos_profile.c` (the scene-row counters while a report is active: one condition),
`tests/test_pdos_report.c`, `tests/harness/ext_adapt.py` (the d7c pair).  New: `present/dos/pdos_scn_world.c/.h`, this
record.  Unchanged, though the brief lists them: `present/dos/pdos_prov.c`, `pdos_scene_tab.c` and `pdos_adapt_tab.c`
(deviation 1).  build.cmd and test.cmd unchanged (build.cmd compiles `present\dos\*.c`); `pdos_scn_world.c` includes no
`w16_obs.h`, so `gen/dos/registry.py`'s OBSERVER_FILES is unchanged (the include rule passes for both new files).  No
BUILD-TEST-ADDITIONS.md.  Every `extension D7c` block is delimited where it adds more than a line, after D7b's blocks in
the shared files; one-line hunks carry an `extension D7c` comment.

## Tests

* **`tests/test_pdos_report.c`** (169 -> 229 checks in every variant): the 4 x 4 tile rule and the layout, pure
  (`pdos_scn_world.h`): the x offset from the human's capital and the y offset from its units' and cities' y range, row 0
  seen (the full range), D806 (offsets 0, every square drawn, a terrain beyond the tiles: no tile), a seen square, one
  seen by another civilization, one off the map below; the marks: the human's city, a foreign city of known size 0 (no
  mark) and known (its owner's colour), a city bit without a city, foreign units the human never saw and saw, a stale
  occupancy (unit -1's byte, with and without the human's bit), the human's own units; Top 5's icon places (the sixth
  off at 137h, a negative size clamped) and the Score's icon line for the three spacings; the whole map drawn (the fill,
  the squares counted, a tile copied 4 x 4 from page 2, a city's 4 x 4, the units' 3 x 3 with its shadow and the tile's
  fourth column beside); the World Map through the module (the state read from the emulated memory, the map on page 0
  after the window's fill, the logged step, the core's port drawing and copies dropped, DrawMapTile's tiles not counted,
  no fade, an unreadable state counted); Wonders quiet with no wonder (the A frame, the pointer hidden, the window the
  I-report one, its fills and copy dropped, no exit kind) and with one (background 3, the title at (64h, 0Ch) with its
  shadow, the frame and the icon); Top 5 (background 3 where the core passes 0, the title, a row's name held until its
  ProcessCity and drawn centred in the owner's colour, row 97 held, the first citizen at (30h, y + 0Ah), the wonder icons
  left to right and the sixth not drawn, the frame); the Score (background 3, the achievements, icon, name and total
  places, row 97 held, exit R:0238:1B44); Demographics (background 1 where the core passes 0, the best civilization by
  the DOS width in its colour); the historian (background 3, the mini palace's slot over its ground line from the core's
  DrawTile, the core's ground line dropped, the frame, row 97 held, no fade); the diag line's D7c counters.
* **`tests/harness/ext_adapt.py`, the d7c pair** (2 runs, 5 checks; `d7c_runs` after `d7b_runs`): the World Map opened by
  F10 in play at 55,500 ms in the DOS profile (I-play/fkey: Ctrl+0 produced, the core's command 504; as it is reachable
  now, before D6fSb's DOS WORLD menu) and closed by a press at an N point at 57,000 ms (the map's key wait); the Windows
  form opens it by Ctrl+0 at the same time and clicks where the DOS run gave the core.  Asserted: I-play/fkey then one
  I-report/press and one produced click; the DOS-form run equals its Windows-form pair; timeline.log `report` (O12:0000,
  row 76), `report_world` (the squares drawn), `report_end` (kind 0) and the return trigger kind 0 with no fade; the
  320 x 200 N frame while the map is open, the A frame after it; the `report` line (opens 1, ends 1, world_maps 1,
  world_squares > 0, world_unread 0, copies 0, other 0, tile_unknown 0, return_none 1).
* `ext_timeline.py` and `ext_p0.py`: unchanged (the Score's 1B44 fade-in is D7a's, covered by its unit tests; ext_p0's
  `menus` run opens the World reports and shows their rows' counters, section "Results").

## Results (private, `build/d7c-stage/obj/`)

Session E4 (2026-10-17, 09:47..11:00 UTC), on the overlay `obj/src` = the tree (after the D7a+D7b landing and UX5b's
copy-in) + the stage (`obj/mkoverlay.py`), the bases of `BASE-SHA256.txt` rechecked:

* **Builds** (`obj/ball.py`, the tree's build.cmd and flags with `--nogen`): Checked, CheckedNoObs and Release BUILD_OK
  (portable sources 298: `pdos_scn_world.c` added; 678, 1052 and 1005 s, slowed by UX5b's concurrent cycle).
* **cc.cmd** (`obj/ccall.py`: c11 and c17 /W4 /WX and the clang C99 parse, every variant) on `pdos_scn_world.c`,
  `pdos_scn_report.c`, `pdos_adapt.c`, `pdos_profile.c` and `test_pdos_report.c`: CCALL failed 0 (15 CC_OK).
* **Unit** (`obj/unit.py`, the tree's build/gamedata read only): all 55 programs (test_ne aside) pass in Checked,
  CheckedNoObs and Release, w32_test_host_win32 included; test_pdos_report 169 -> 229 in each.  Against the D7a+D7b
  cycle's log (`build/d7ab-2-test-checked.log`, `obj/cmpunit.py`): test_pdos_report 169 -> 229, and test_pdos_aspect
  93 -> 140 and test_pdos_seq 214 -> 215, which are UX5b's (its predictions); every other count equal.
* **Checks** on the overlay: `registry.py check` (with `--dosdata` and `--disasm` of the tree's build, read only)
  REGISTRY_OK, 0 failures (the include rule ok for `pdos_scn_world.c` and `.h`; 319 `ok` lines, the tree's 317);
  `obs_lint.py` OBS_LINT_OK files 128 probes 203 callsites 101; `obs_tables.py --check` (`obj/obstab.py`, the tree's
  listing) OBS_TABLES_OK probes 203 sites 101; `pdos_scene_check.py` PASS 1084 checks, 141 scene rows, 10 font rows;
  `adapters.py check` ADAPT_OK rows 123 steps 25; `nodos.py check --root obj/src` (the three variants' binaries; the
  tree's build/dosdata and build/gamedata read) NODOS_OK, 1127 files, 0 hits.
* **ext_adapt's d7a, d7b and d7c pairs** (`obj/runadapt.py` with the private Checked harness): 14 of 14.  d7a (5) and
  d7b (4) as their records (the `report` lines now end with the six D7c counters at 0).  d7c (5): F10 decided by
  I-play/fkey, the press by I-report/press at the window's centre (320, 240) (class X); the DOS-form run equals its
  Windows-form pair (coreinput 39 lines, frames 682; exit 0, 0); timeline.log `report` (O12:0000, row 76) and
  `report_world` (9 squares) at 55,500,750 us, `report_end` (kind 0) and the return trigger (kind 0, no fade) at
  57,001,750 us; two 320 x 200 shows while the map is open, 21 A-frame shows after it; the `report` line: opens 1,
  ends 1, world_maps 1, world_squares 9, world_unread 0, copies 0, dropped 23, fills_window 2, other 0, tile_unknown 0,
  return_none 1.
* **ext_p0** (the tree's runner, `--exe` the private Checked harness, `--root obj/p0root`): V0, V1, V2 on `menus` P0_OK
  (7 checks; V0 equals its baseline as amended; V1 and V2 equal V0).  V1's and V2's `pdos_rows`: `r79.unexplained 91
  r79.font_unmapped 1` only (the Civilopedia, D7h's); no count on rows 73..77 or 98 (D7b's run: `r98.unexplained` 2,
  Civilization Score's, and counts on rows 73..77).  The `report` line: opens 10, ends 10, fills_window 20, fills_port
  10, titles 8, pens 2, copies 11, city_holds 14, portraits 11, other 0, return_none 9, return_1b44 1 (the Score),
  fade_ended 1, placed 48, drawn_portraits 3, citizens 10, dropped 168, info_waits 1, tile_unknown 0, quiets 1 (Wonders:
  no wonder built in the run), world_maps 1, world_squares 87, world_unread 0, palaces 0, names 5.
* **Frames looked at** (private dumps, `--dump-presented`: `obj/dumpmenus.py` reruns V1 `menus`, `obj/dumpworld.py` the
  d7c-world-dos run; PNGs in `obj/p0root/dump/` and `obj/adaptroot/dump/`): Top 5 Cities on cyan with the title at
  (50h, 0Ch), five frames 20h apart in the owners' colours, the names centred in those colours and the citizens from x
  30h; the Civilization Score on cyan; Demographics on blue with its 13 rows and rank lines; the World Map: black with
  the explored island as 4 x 4 terrain tiles (ocean, grassland, forest), the cities as white 4 x 4 squares, 87 squares
  (9 in the d7c run: the capital's 3 x 3, the city over its square); the first 320 x 200 show of the map is black (the
  window's fill), the next one the map (as DOS fills before drawing, O12:002D).  The historian is not reached by any
  recorded flow: its rows are covered by the unit test only (user check D7c-6).

## Deviations from the brief

1. **`present/dos/pdos_prov.c`, `pdos_scene_tab.c` and `pdos_adapt_tab.c` unchanged** (all in the brief's list): S7
   (the palace slots), S13 (the citizens), S18 and S19 (the wonder icons, the replay's DrawImprovementIconLogical
   bracket) resolve by D6b's rules (`prov_unknown` 0); rows 73..77 and 123 exist with their keys, and the renderer sets
   their readiness as D7a does for row 67; the I-report rows (D7a) decide the input of every screen of the unit, the
   historian's included (row 123's I-wait is class X too), through the renderer's state, so no row and no PDOS_AS bit is
   added (the brief's allocation 0x10000000 stays free).
2. **`pdos_adapt.c` and `pdos_profile.c` change one condition each** (not in the brief's list): `pdos_report_shown()`
   becomes `pdos_report_active()` (shown or quiet), so a quiet Wonders report keeps the I-report rows and the scene-row
   counters its row.
3. **Wonders of the World with no wonder built is quiet** (DOS O12:080D draws nothing over the play screen; the core
   draws its title and "None discovered yet!"): the A frame stays (the play screen), the core's drawing is dropped, the
   next key or click returns (**choice**: the DOS form; recorded for FIDELITY).
4. **The Civilization Score shows as it is drawn:** DOS composes the screen on page 1 and shows it with G#20 at its end
   (O20); the N frame shows the replay's drawing as the core draws it (within a few frames, the core's pace).  DOS's row
   spacing DGROUP:5116 is kept from call to call and only decremented when the rows overflow; the renderer follows the
   core's g_scoreRowSpacing and the core's decisions of what fits (recorded for FIDELITY).
5. **The historian's rows at the core's pace** (TC, as the brief says): DOS waits 60 frames per row (O12:0CA1,
   R:0182:0134(3Ch)); the core's pace is kept.
6. **Top 5's row name is drawn at the row's ProcessCity** (1080:0BE8), just after the core's DrawCenteredScreenText
   (1080:0BDD), when the row's city and owner are known; DOS draws it at once in the owner's colour.  Nothing overlaps it
   in between, so the screen is the same.
7. **The World Map's pairings are inferred:** g_revealAll for DOS's D806 and the core's terrain numbering for the page-2
   tile columns (the same 0..15 terrain order as D6e's small map); a city bit with no city at the square follows the
   core's check (no mark; DOS would read city -1's bytes).  World mode B278 is not used (OPEN L2).

## What the user checks

On the coordinator's user build (`civ64.exe`, DOS files present), in play (a saved game or a new one, a few turns in,
with at least one city and a few units) with the DOS graphics (Ctrl+Shift+Backspace or the host menu).  The World
screens are reached as they are reachable now: the DOS menu bar's World menu, or F7 (Wonders), F8 (Top 5), F9 (Score)
and F10 (World Map); Demographics only through the World menu.  D6fSb's DOS WORLD menu reaches them later.  Each screen
fills the window as a 320 x 200 DOS screen (in the 4:3 shape when "4:3 aspect ratio for 320 x 200 screens" is checked,
square when it is not), the pointer hidden, with no Go Back or Cancel row; a key or a click closes it:

* **D7c-1** World > World Map (F10): a black screen with the squares you have explored as small DOS terrain tiles (4 x 4
  pixels), your capital's column near the middle, your cities and units as small squares in your colour (a unit's square
  with a black shadow), other civilizations' cities and the units you can see in theirs; a key or click returns to the
  map at once, without a fade.
* **D7c-2** World > Wonders of the World (F7): with no wonder built nothing appears (the map stays) and the next key or
  click returns; with wonders built, "The Wonders of the World" at the top left on cyan, each wonder in a frame of its
  owner's colour with its icon and its city.
* **D7c-3** World > Top 5 Cities (F8): on cyan, the title at the top left; per city a frame in its owner's colour, its
  name centred in that colour, its citizens as the DOS citizen shapes from the left, its wonder icons to their right.
* **D7c-4** World > Civilization Score (F9): on cyan, the citizens, the wonders (their icons and names in light cyan),
  the other lines and the total as DOS spaces them; closing it fades the map in from black.
* **D7c-5** World > Demographics: on blue, the 13 rows with their rank lines; where a row names the leading
  civilization in brackets at the right, it ends at the right edge in that civilization's colour.
* **D7c-6** The historian's report, when it appears by itself during the game (every 20 to 59 turns): on cyan, one row
  per civilization with its small palace standing on its frame, in its colour.
* **D7c-7** The same screens with the Windows graphics: the Windows report windows, unchanged.

Not part of this check: switching the graphics while a report shows; the Spaceships item (row 78, D7l); the power graph
and the end of the game (D7m).

## For the records

* **DESIGN 12.x "As implemented (D7c; area B and C)":** the World reports and the historian in the renderer's table with
  their DOS backgrounds and ends; the second site table (ruling 4 by call site); the World Map drawn whole in its DOS
  form from the core's world state (`pdos_scn_world`), the core's drawing and copies dropped; the historian's mini
  palace as R:0238:14A3 with the core's slot tiles; the quiet Wonders report and `pdos_report_active`; the new `report`
  counters.
* **FIDELITY** (new entries, numbers to be assigned): (a) Wonders with no wonder built draws nothing over the play screen
  (deviation 3); (b) the Score shows as it is drawn, not composed on page 1, and its row spacing follows the core's
  (deviation 4); (c) the historian's rows at the core's pace, not 60 frames each (deviation 5); (d) the World Map in its
  DOS 4 x 4 form from the core's world state, the pairings inferred, a city bit without a city unmarked (deviation 7);
  (e) Top 5's and Demographics' DOS backgrounds (3 and 1) where the core passes 0.
* **DOS-PROFILE.md prose** (rows as implemented in D7c): row 73 (Wonders): O12:080D in background 3, the title at (64h,
  0Ch) not centred, the frames R:1D05:0A05 in the owner's colour, the icons 2 lower; with no wonder built quiet (the A
  frame, FIDELITY (a)); exit kind none.  Row 74 (Top 5): O3:09AC in background 3, the title at (50h, 0Ch), the names in
  the owner's colour, the citizens S13 at R:0D12:6ED4's places, the wonder icons left to right while x < 125h, the
  frames (8, y, 12Fh, 19h); the core's ProcessCity holds row 97; exit kind none.  Row 75 (Score): O20:0CA9 in background
  3, the wonder lines on DOS's lines (icon y - 2, name x + 14h in colour 11), the later lines 4 higher; exit kind 1B44;
  FIDELITY (b).  Row 76 (World Map): O12:0000(1) drawn whole from the core's world state (`pdos_scn_world`): 4 x 4 tiles
  from page 2 (160 + 4t, 111 + 4((x + y) & 1)), cities 4 x 4 and units 3 x 3 with a shadow in [1946h + 2 civ], the
  layout of O12:0048..0177; world mode not used (OPEN L2); exit kind none; FIDELITY (d).  Row 77 (Demographics):
  O12:0D6D in background 1, the best civilization ending at 13Eh in its colour; exit kind none.  Row 123 (the
  historian): O12:09E2 in background 3, the mini palace R:0238:14A3 at (80h, y - 0Dh) with the core's slot tiles (S7),
  the frames in the civilization's colour; the rows at the core's pace (FIDELITY (c)); the close by I-report; exit kind
  none.  Row 98: "the reports of rows 73..77 are D7c's" becomes "the reports of rows 73..77 and 123 as implemented in
  D7c".
* **RUNNING.md:** presentation-diag.log's `report` line gains `quiets`, `world_maps`, `world_squares`, `world_unread`,
  `palaces`, `names`; timeline.log's `report_world` and `report_quiet` steps; ext_adapt's d7c-world-dos and d7c-world-win
  runs.
* **FEATURES.md:** the DOS World reports and the historian in play (D7c), with the runners above.
* **STATUS.md:** D7c landed (rows 73..77, 123; no new adapter row or PDOS_AS bit).
* **manual-checklist-ext.md:** new items D7c-1..D7c-7 (above), noting that the screens are reached through the current
  DOS bar's World menu and F7..F10 until D6fSb's DOS WORLD menu lands.
* User direction 2026-10-16 (no added Go Back / Cancel rows): no screen shows one; each closes by DOS's any key or
  click.  Report items: none.
* Not edited by this unit: DESIGN.md, FIDELITY.md, STATUS.md, RUNNING.md, FEATURES.md, DOS-PROFILE.md,
  manual-checklist-ext.md, the D1 drafts and the D0 documents.

## Expected changes at the build slot

Relative to the tree after the D7a+D7b landing and UX5b's (its cycle ALL_GREEN at 10:49 UTC):

* **Unit** (Checked and Release): test_pdos_report 169 -> 229; every other count unchanged.  Portable sources 297 ->
  298 (`pdos_scn_world.c`); obs_lint files 126 -> 128; probes 203 and call sites 101 unchanged.
* `registry-check.txt`: REGISTRY_OK with the two include-rule lines of `pdos_scn_world.c/.h` added (317 -> 319 `ok`
  lines).  `pdos-scene-check.txt` (1084), `obs-tables.txt` and `adapters-check.txt` (rows 123, steps 25): unchanged.
  `nodos.txt`: byte and file counts grow with the binaries, the two sources and the record; NODOS_OK.
* `ext-adapt.txt`: EXT_ADAPT_OK checks 198 -> 203 (the five d7c lines); two more runs (d7c-world-dos, d7c-world-win; 60
  s of virtual time each).
* ext_p0: P0_OK with unchanged check counts (476); the `menus` run's `pdos_rows` without rows 73..77 and 98 (only row 79,
  D7h's, remains).  Informational lines may change, as at D7b's landing: ext-replay's V1 `menus` counter line (the World
  reports now drawn by the replay on the report's shadows, the World Map's port drawing dropped) and ext-p0's V4d
  `menus` show count (the World reports now show the N frame).
* presentation-diag.log (harness): the `report` line's six new counters; timeline.log's `report_world` and
  `report_quiet` steps.
* Core outputs, G-1 fields and `ext_g1.py check`: unchanged (presentation only; the d7c pair and ext_p0 V1/V2 equal their
  references).

## Rebase notes

* **Bases:** the tree's files after the D7a+D7b landing (copy-in 08:07:35 UTC), their hashes recorded at the copy
  (`obj/base-at-copy.txt`, 09:23:45 UTC) and rechecked equal to the tree (`BASE-SHA256.txt`, its second line gives the
  time; `obj/basesha.py` writes and checks it).
* **UX5b** landed at 09:35:23 UTC (11 files: `pdos_birth.c/.h`, `pdos_seq.c/.h`, `pdos_tl.h`, `test.cmd`,
  `ext_aspect.py`, `test_pdos_aspect.c`, `test_pdos_seq.c`, its record, `build.cmd`), none of D7c's; the overlay holds
  them.  A later landing that changes a D7c file before D7c lands: each such file merged three ways (its base, its staged
  copy, the new tree file): D7c's hunks in `pdos_adapt.c` and `pdos_profile.c` are one condition each
  (`pdos_report_shown()` -> `pdos_report_active()`, with its comment), in `pdos_scn_report.c/.h` delimited `extension
  D7c` blocks and one-line hunks after D7b's; `ext_adapt.py` the `d7c_runs` block after `d7b_runs`, its call and its
  docstring paragraph (the docstring's closing sentence, which read "... no nest). and EXT_ADAPT_OK ..." after D7b, now
  reads "Prints PASS/FAIL lines and EXT_ADAPT_OK ...").
* **D7m** (next on track A) stages on D7c's copies of `pdos_scn_report.c/.h` and `test_pdos_report.c` where it needs
  them (the power graph, row 122, opens with OpenBlankReportScreen); it is staged after D7c's READY_TO_BUILD.
* **Tracks B and C** (D7d, D7j) do not change D7c's files as far as their briefs list; `PDOS_OWNER_MAX` is untouched by
  D7c (the report owner is D7a's).
* Shared counts: one new source file (`pdos_scn_world.c`: portable sources +1); obs tables unchanged (probes 203, call
  sites 101).

## Build-slot steps

D7c lands alone (UX5b has landed; or at the coordinator's word): the base check of `BASE-SHA256.txt`, the predictions of
"Expected changes", the copy-in of the eight files (six changed, two new) and this record, the three-step cycle, Release,
the user build with `WHAT-TO-CHECK` items D7c-1..D7c-7, and a Landing section here.

## Landing

D7c landed alone at the build slot of session E4 (track A), 2026-10-17, after UX5b's landing had finished (its
RELEASE_OK 10:56:23 UTC and `build/user-builds/ux5b/`).  The user checks D7c-1..D7c-7 are in the user build `d7c`.

* **Bases:** rechecked against the tree at 10:57 UTC (`build/d7c-prep/land.py`: every base of `BASE-SHA256.txt` equal,
  the three new files absent, the eight read-only references unchanged; DRY_RUN_OK 9).  Scripts in `build/d7c-prep/`
  (from `build/ux5b-prep/` by `mk_prep.py`; `land.py` and `fill_stillopen.py` adapted).  Snapshot
  `build/d7c-prep/before` (the tree's `build/test/Checked` outputs of UX5b's cycle, 63 files) and `tree-before` (the six
  replaced files); copy-in at 10:57:02 UTC (`landed.sha256`: the nine files, build.cmd and test.cmd unchanged;
  `landed-at.txt` "unit d7c").  Predictions `build/d7c-prep/predictions.txt`, written before the copy-in.
* **The three-step cycle** (`build/d7c-status.txt`): 1 `build.cmd checked` BUILD_OK 10:57:11..11:04:56 (465 s; portable
  sources checked 298); 2 `test.cmd checked` TESTS_OK 11:04:56..11:44:01 (2345 s; TEST_SECTIONS 29 failed 0; no flake
  rerun); 3 `ext_g1.py check` EXT_G1_OK runs 77 (amended 1) unchanged: **ALL_GREEN**.  4 `build.cmd` (Release) BUILD_OK
  11:44:24..11:49:54 (330 s; portable sources 298): **RELEASE_OK**.
* **Against the predictions** (`build/d7c-prep/compare.py` against the snapshot; `compare.txt`: 50 of 63 files equal,
  host times left out): as predicted, unit.log test_pdos_report 169 -> 229, every other count equal; registry-check
  REGISTRY_OK with the two include-rule lines of `pdos_scn_world.c/.h` added; OBS_LINT_OK files 126 -> 128;
  obs-tables, pdos-scene-check (1084) and adapters-check (rows 123) unchanged; EXT_ADAPT_OK checks 198 -> 203 (the five
  d7c-world lines equal to the private run: F10 by I-play/fkey, the press by I-report/press at (320, 240), coreinput
  39, frames 682, 9 squares; the d7a and d7b `report` lines with the six new counters at 0); P0_OK checks 476 with the
  V1/V2 gate-row lines unchanged; NODOS_OK, files 1766 -> 1770, 0 hits; ext-replay's pass conditions (kind_mismatch 0,
  point_mismatch 0) hold.  Not predicted in detail, explained: (a) ext-p0's V4d zoom lines: menus 847 -> 841, retire
  43 -> 36, conquest 112 -> 108, arrival 231 -> 226 shows with the layer: the retire, conquest and arrival runs end with
  the Civilization Score (timeline `report` O20:0CA9, row 75), which now shows the N frame instead of the zoomed A
  frame, as the menus run's World reports do; (b) ext-replay's informational V1 lines of menus (brackets 0/314/126 ->
  0/314/254, draws 75 -> 143, no_shadow 245 -> 90, s3_deferred 8 -> 10, no_scene 13 -> 19) and of retire, conquest and
  arrival (brackets 0/n/0 -> 0/n/17, draws 0 -> 10, s3_deferred 0 -> 2): the report owner now shadows these reports'
  windows and ports, so the replay draws their texts there and the copies wait for its leave; (c) ext-zoom's
  informational s4 lines: sw shows 3995 -> 3991 and 3902 -> 3898 (a World report on the N frame; ZOOM ok, golden
  unchanged); (d) coverage.txt "other functions entered" 663 -> 672 (informational: the union of the coverage files of
  the test programs and harness runs; the core's outputs, G-1 and P0 are equal); (e) unit.log's OBS_COST line (host
  timing; the machine shared with other agents' overlay builds).
* **User build** `build/user-builds/d7c/`: `civ64.exe` (the Release build, SHA-256 4aa29a89...), `CIVWIN.zip` and
  `civdos.zip` from `build/user-builds/d4/`, `WHAT-TO-CHECK.txt` (D7c-1..D7c-7, the earlier builds up to "ux5b", and the
  70 items still pending in the checklist at 11:44 UTC, UX5b's eight among them).
* Not done at this slot: the checklist sections and STATUS rows (the orchestrator's) and the docs pass (a joint UX5b +
  D7c pass follows); the tree's CheckedNoObs build is not part of the three-step cycle (the private overlay builds and
  units of the three variants are in "Results").

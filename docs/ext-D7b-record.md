# Extension phase D7, unit D7b (the advisors' reports) - record

Draft for the build slot (BRIEF-d7.md "Units" D7b, extension session E3).  Staged in `build/d7b-stage/` stacked on D7a's
staged copies (`build/d7a-stage/`), as D4c2 was on D4c1: the base of every file D7a changes is D7a's staged copy
("d7a-stage" in `BASE-SHA256.txt`), the base of every other file the tree after D6g's landing (05:14 UTC on 2026-10-17)
and the D6 gate cycle (ALL_GREEN 06:02 UTC, `build/d6-gate-status.txt`), copied to `obj/base/`.  D7b's edits to the
shared tables follow D7a's in separate blocks, so that D7a's rebase carries over mechanically (section "Rebase notes").
D7b lands with D7a in one cycle (or after it), at the coordinator's word.  Private builds and runs in
`build/d7b-stage/obj/` only: an overlay `obj/src` = the tree + D7a's staged files + D7b's (`obj/mkoverlay.py`), built
with the tree's build.cmd and flags (`obj/b.cmd`, `--nogen`), cc.cmd's stricter checks per file (`obj/cc.cmd`), the unit
programs and the harness runs from the overlay's binaries with every output under `obj/`; the tree's build/gamedata,
dosdata and cache read only.  Landed by the build slot on 2026-10-17 (section "Landing").

## Result

D7b is staged and READY_TO_BUILD.  With the DOS graphics, the five advisors' reports show as the DOS O14 reports on
D7a's N frame: Military (MILITARY STATUS on blue, then MILITARY LOSSES on dark red), Intelligence (blue where the
Windows game has black, its INFO buttons drawn the DOS way, the pointer shown while it waits for INFO, the dossier over
it), Attitude (light blue, the citizens as the DOS citizen shapes at their DOS places, the building icons), Trade
(green) and Science (blue), each with the DOS title, lines and rows, the unit and building icons as DOS shapes and the
advisor's DOS portrait at (278, 2) where DOS draws one.  A key or a click closes each, as in DOS; there is no Go Back or
Cancel row.  Privately, on the tree with D7a's staged files: the three variants build, every unit program passes in
each, the d7a and d7b adapter pairs pass (the d7b pair's DOS-point click equals its Windows-device-click pair), ext_p0
V0/V1/V2 on `menus` P0_OK with no counter on rows 68..72, and every check script passes.

## Status

READY_TO_BUILD.  Built: rows 68 (Military, O14:03AD and Losses O14:061F), 69 (Intelligence, O14:0D43 and its dossier
O14:1164), 70 (Attitude, O14:15F4), 71 (Trade, O14:07F1) and 72 (Science, O14:014B) in the report renderer's table;
their bodies drawn by the replay on D7a's frame and placed, recoloured or joined by the call site where the O14 listing
draws them differently (BRIEF-d7 ruling 4); the advisor portraits drawn (T1, from D7a's page 2); the Attitude citizens
(S13) at R:0D12:6ED4's places; the INFO buttons as R:0D12:71BF (OB2); Intelligence's wait for INFO with the DOS pointer
and the adapter rows I-report/info (class P); the nested dossier and its exit kind R:0238:1B44; the DOS backgrounds
where they differ (Intelligence 1 for the core's 0), recorded.  ext_p0's `menus` run (V1, V2): rows 68..72 have no
`unexplained`, `w_over_n`, `colour_nearest`, `font_unmapped` or `prov_unknown` count.  Not in the unit: the World
reports (D7c).

## What was built

### The report bodies (BRIEF-d7 ruling 4; the replay's place hook)

The five reports join the renderer's table (`present/dos/pdos_scn_report.c`, D7a's frame: the N scene, the DOS fill, the
title drawn again unshadowed, the copies to page 0, the close by O14:013B's any key or click):

| Row | Report | Core | DOS | Background | Exit |
|---|---|---|---|---|---|
| 68 | Military Status, Losses | ShowMilitaryReport 1018:067B, DrawCasualtyReport 1018:09CC | O14:03AD, O14:061F | 1 (O14:03B5), 4 (O14:0626) | none |
| 69 | Intelligence, the dossier | ShowIntelligenceAdvisor 1018:1221, DrawCivDossier 1018:17DB | O14:0D43, O14:1164 | 1 (O14:0D4B, 116B); the core 0 | none; 1B44 after a dossier |
| 70 | Attitude Survey | ShowAttitudeAdvisor 1018:1D5B | O14:15F4 | 9 (O14:15FB) | none |
| 71 | Trade | ShowTradeReport 1018:0BE0 | O14:07F1 | 2 (O14:0839) | none |
| 72 | Science | ShowScienceReport 1018:03F0 | O14:014B | 1 (O14:0152) | none |

Their texts, lines, fills, frames, unit sprites and building icons are the core's primitives drawn by the replay (D6b)
in the DOS fonts and colours.  Where the O14 listing draws a primitive at another place, in another colour or as one
string, the renderer changes it by the primitive's call site through a new hook of the replay, `pdos_replay_set_place`
(`pdos_replay.c/.h`: at a primitive's exit draw the hook gets its words, may change them, and may draw the DOS form
itself and return 0).  The site table of `pdos_scn_report.c` names each site with its listing address:

* **Science (O14:014B):** the bulb bar's fill at y 19h, 10h high (O14:022E..0244, R:0000:0BFA; the core 1Bh, 12h); the
  bulb icons (D4CE[12], S10) at y 21h (O14:0253..0270, R:1DC4:009A); the "Researching ..." line drawn by the hook as
  R:0182:00B3 draws it at y 1Ah: colour 0 at x + 1, then the text centred on x (O14:02D0..02F7), not the replay's shadow
  below; the advance rows 6 higher, from y 2Ah, 7 apart (O14:02FF..032F; the core's from 30h).
* **Military Status (O14:03AD):** the rule from x 24h to 13Fh (O14:03F1..0405, R:0182:000A); the unit sprites (S17) at x
  2 + 16 (n & 1) and one row lower (O14:040D..0432; the core 2 + 22 (n & 1)); the unit's name at x 24h, its strengths at
  x 70h and "in production" at x E8h (O14:0442..0453, 04F9..050D, 05B7..05CB); the Defense Minister's portrait.
* **Military Losses (O14:061F):** background 4 (DrawCasualtyReport's page; O14:0626 opens O14:0000 with 4); the rule and
  the sprites as on page 1 (O14:0680..06BF), the name at x 24h (O14:06C7..06DC); another civilization's losses in its
  DOS colour [1946h + 2 civ] (O14:078F..07A2; the core passes civ + 10h); the human player's frame R:1D05:0A05(64h, 19h,
  12h, y - 19h, [1946h + 2 human]) with its inclusive corners (O14:07C3..07E0).
* **Trade (O14:07F1):** a city in disorder in colour 10 (O14:0A7A..0A8A -> 0959..096F; the core's 4); the Domestic
  Advisor's portrait; ShowTradeReport's ProcessCity(city, -1) holds row 97 as City Status's does (O14:0A1D).
* **Intelligence (O14:0D43):** "No embassy established." and the government line in [1946h + 2 civ] (O14:105C..106B,
  0E84..0E98); the name and the relation as one DOS string in colour 7 (O14:0EB0..0ECE, 0EF0..0F0E: the core's
  DrawTextAtPen pen texts after the name, drawn in colour 7 at the pen, the pen going on after each).  The dossier
  (O14:1164): its lines one string each in colour 9, a relation in 7 (O14:11C8..1215, 1382..13A4, 13B8..13EA,
  13FE..1446, 1461..14A9, 14E6..1570).
* **The INFO buttons (OB2):** DrawBeveledLabelBox 1030:8C11 against R:0D12:71BF (O14:0FBE..0FE3): the same geometry, the
  DOS colours of c = [1946h + 2 civ] (O14:0FC6..0FCB): fill c (R:0D12:71C5..71E8), top and left lines c < 8 ? c + 8 : 7
  (71F0..7234), bottom and right lines c < 8 ? 8 : c - 8 (723C..7282), the centred label c ^ 8 (728A..72AE).
* **Attitude (O14:15F4):** the city's name at x 10h (O14:168E..169D; the core's 0Ah); the bar R:0000:0BFA(port, D4h, y -
  1, 5Ah, 0Ah, 11) (O14:16CE..16EC); the building icons (S18, S19) at D4h + 12h k (O14:16F9..1729, R:0D12:7045); the
  totals at x 10h (O14:17F9..180C); the citizens below.

### The Attitude citizens (S13; R:0D12:6ED4)

DrawCityPeopleRow 1030:830C draws each citizen with a DrawTile (1030:838C, 83DF, 8450, 84A0: happy, content, unhappy,
specialist).  The renderer draws the citizen's DOS shape (G#32 of DGROUP:6E96's shape, S13) at the DOS place derived
from the core's sequence: the row's first at 50h + stagger + (x - (64h + stagger)) / 2 (the stagger (4 (rows - 1)) & 7,
O14:16A5..16AB), each next at the previous + the DOS pitch + half the core's gap beyond its pitch (the pitches 0Eh and 7
for a city of n with 0C6h / n and 7Ch / n when too wide, 1030:8327..8342 and R:0D12:6EE9..6F04; the core's 4 and 8 pixel
gaps between the groups become DOS's 2 and 4, R:0D12:6F45, 6F9A, 6FFE), at y - 3 of the row's name (O14:16B9..16BF).
The first g_unhappyOverflow unhappy citizens are recoloured 5 -> 12 as R:0D12:6FC3..6FE5 does (G#3(port, x, y, 12, 14,
5, 12); g_unhappyOverflow is DGROUP:6542's counterpart).

### The advisor portraits (T1)

DrawAdvisorPortrait 1018:24C5's sunken panel (its palette copy, FillRect and DrawSunkenFrame3) has no DOS form: its
events are dropped.  Its DrawTile (1018:259A) of g_advisorShapes[n] is the DOS portrait: page 2 (160 + 40n, 140, 40 x
60) of D7a's GOVT picture to (116h, 2) = (278, 2), as G#20 at O14:0206..0226 (Science), 05E7..0603 (Military) and 0857
(Trade); the shape's index by T1 (`pdos_prov`).

### The DrawTile bitmaps of a report (no DOS counterpart)

Inside a DrawTile on the report port, DrawTileImpl makes its own bitmaps: the buffer (CreatePortBitmap at 11A8:12BC, the
port's rectangle copied in at 11A8:12F1, the tile composed as raw bits by SetBitmapBits at 11A8:135A, copied back at
11A8:137B) or, without a palette device, the image and mask bitmaps (11A8:0F2C, 116C).  DOS draws the shape directly.
The report declines a shadow for every bitmap made while its DrawTile runs: a negative claim, a small extension of the
shadow engine (`pdos_shadow.c/.h`: a claim below 0 makes no shadow, neither a later owner's nor the engine's own, and is
asked again at the next get).  So their copies and raw bits are not followed; their copy to the port is dropped (the DOS
shape was drawn at the DrawTile's entry).  The DrawTiles of the replay's own brackets (DrawShapeAndFlush's at 11E8:06D3,
DrawImprovementIconLogical's at 1030:851C) are the replay's and are left to it.

### The sheet and page-2 shapes by provenance (S10, S13, S17, S18, S19)

Every shape is resolved by D6b's provenance rules, unchanged: the bulb icon D4CE[12] (S10), the citizens (S13), the unit
sprites of the N column (S17: units 64 + 32c + j), the improvement icons (S18: [5c + r] at page 2 (161 + 19 (i / 5), 50
+ 10 (i % 5)); S19: 40, 41).  `pdos_prov.c` needs no change: `prov_unknown` is 0.

### Intelligence's wait for INFO, the dossier and the return

* **The wait (O14:1079..10D9):** ShowIntelligenceAdvisor polls PollMouseClick 1108:0000 at 1018:1641 (`RA_INFO_POLL`);
  from its first poll until CloseReportScreen or the dossier's opener the renderer is in the INFO wait: the DOS pointer
  is shown (O14:1079 shows it with R:01A8:0250), and `pdos_report_info_wait()` selects the adapter scene
  `PDOS_AS_REPORT_INFO`.
* **The adapter rows I-report/info** (`pdos_adapt_tab.c`, three rows after D7a's I-report rows; DOS-PROFILE 1.7.2
  regenerated): a modifier alone consumed; any key passed ('1'..'7' choose a dossier in both, O14:10A9..10B1 and the
  core's key); either button passed at the class-P point of the DOS point in the report's dialog 148 (C.14.2: the client
  origin + ceil(16L / 10), which PollMouseClick's (d * 10) / 16 turns back into the DOS point, so the core tests x >
  0x119 and the row (y - 0x1C) / 0x18 as DOS does, O14:1083..10D9).  Without the report's window or outside it the press
  is consumed (class P has no fallback window).  `pdos_adapt.c` gains the class-P path for frame-1 presses;
  `adapters.py` allows class P for that scene only.
* **The dossier (O14:1164; ShowNestedCivDossier 1018:176C):** its report window opens over the report's (O14:1164's own
  O14:0000, which saves the page): the renderer nests (the outer window, port and background kept), draws it in
  background 1 (O14:116B), and at its window's destruction returns to the report's window, still the N frame.  The INFO
  wait starts again at the next poll (O14:113F).
* **The return:** a report that showed a dossier ends with R:0238:1B44 (O14:110A, 1147..114D): its exit kind becomes
  1B44, so D7a's return fades the map in from black; without a dossier the kind is none (O14:1154: R:0866:25D7).

### Counters

presentation-diag.log's `report` line gains `placed`, `drawn_portraits`, `citizens`, `labels`, `dropped`, `nests`,
`info_waits` and `tile_unknown` (a DrawTile on the report port that is neither a portrait nor a citizen: dropped and
counted).

## Files

Changed (`BASE-SHA256.txt`; base "d7a-stage" = D7a's staged copy, "tree" = the tree's file):
`present/dos/pdos_scn_report.c/.h` (d7a-stage), `present/dos/pdos_replay.c/.h` (tree: the place hook),
`present/dos/pdos_shadow.c` (tree) and `pdos_shadow.h` (d7a-stage: the negative claim), `present/dos/pdos_adapt.c/.h`
and `pdos_adapt_tab.c` (d7a-stage), `gen/dos/adapters.py` (d7a-stage), `docs/DOS-PROFILE.md` (d7a-stage: 1.7.2
regenerated), `tests/test_pdos_report.c` (d7a-stage), `tests/test_pdos_shadow.c` (tree), `tests/test_input.c`
(d7a-stage), `tests/harness/ext_adapt.py` (d7a-stage: the d7b pair).  New: this record.  Unchanged, though the brief
lists them: `present/dos/pdos_prov.c` (every rule exists, deviation 2) and `present/dos/pdos_scene_tab.c` (rows 68..72
exist; the renderer sets their readiness).  build.cmd and test.cmd unchanged; no BUILD-TEST-ADDITIONS.md.  Every
`extension D7b` block is delimited where it adds more than a line, after D7a's blocks in the shared files; one-line
hunks carry an `extension D7b` comment.

## Tests

* **`tests/test_pdos_report.c`** (D7a's 110 -> 169 checks in every variant): the place hook registered at the reset;
  Science (background 1, the bar's fill, the icon's y, the advance rows, the centred line drawn by the hook with its
  shadow beside, four primitives placed; other call sites, other surfaces and no report unchanged; City Status
  unchanged); Military (background 1, the rule, the sprites' columns, the name; the Losses page in background 4, a
  civilization's colour, the human's frame; exit none); Trade (background 2, the disorder colour, row 97 held during its
  ProcessCity); Intelligence (background 1 where the core passes 0, the pointer hidden until the INFO wait, two INFO
  buttons' colours, a label site outside DrawBeveledLabelBox unchanged, the name and relation as one string in colour 7,
  a primitive ending the pen, the INFO wait with the pointer shown and its poll loop one wait, the dossier nested in
  background 1 and its end, the wait again, the exit kind 1B44 after a dossier and none without); Attitude (background
  9, the citizens' DOS places and pitches, the stagger of the second row, the unhappy recolour by g_unhappyOverflow, the
  Windows tile's drawing dropped, DrawTile's buffer declined with its raw bits not followed and nothing unexplained, the
  other branch's image declined, a bitmap made outside a DrawTile not the report's, the portrait's panel dropped and the
  advisor's page-2 portrait at (278, 2), unknown shapes and sites counted, another port's tile and the replay's sprite
  and icon DrawTiles not the report's); the diag line's counters.
* **`tests/test_pdos_shadow.c`** (175 -> 181 checks): the negative claim: a declining owner, then a claiming one; no
  shadow (the later owner not asked, no logical shadow of the engine's); a logical source copied into it makes none and
  its raw bits are not followed; a copy from it into a shadowed bitmap of no owner is unexplained (an unshadowed source,
  7.4); asked again at the next get.
* **`tests/test_input.c`** (D7a's 506 -> 522 checks in Checked): the four I-report/info vectors of the table (modifier
  consumed, key passed, a left and a right press at the class-P point) and `adapt_report_info` (the press and its
  release at 1000 + PDOS_I5_P in dialog 148 with the DOS point handed to the point hook, the right button, no window:
  consumed, a point outside: consumed, '3' passed, outside the wait I-report/press stays class X); the row count 120 ->
  123.
* **`tests/harness/ext_adapt.py`, the d7b pair** (2 runs, 4 checks; `d7b_runs` after D7a's `d7a_runs`): Intelligence
  opened with Ctrl+3 in play at 55,500 ms in the DOS profile, a left press at the DOS point (300, 52) of the report at
  56,700 ms (in the INFO wait: no embassy there, so the report ends) and a press at an N point at 57,400 ms
  (CloseReportScreen's wait); the first press decided by I-report/info-press at the client origin + ceil(16L/10) = (544,
  164), the second by I-report/press (class X); the DOS-form run equals its Windows-form pair (the same clicks given as
  device points); timeline.log `report` (O14:0D43, row 69) and `report_end` (kind 0) after the second press; the
  `report` line (opens 1, ends 1, info_waits 1, nests 0, return_none 1).
* `ext_timeline.py` and `ext_p0.py`: unchanged (deviation 4).

## Results (private, `build/d7b-stage/obj/`)

Rerun in session E4 (2026-10-17, 07:30..08:15 UTC) after D7a's registry fix and the rebase of section "Rebase notes",
on the overlay `obj/src` = the tree (the D6 gate's state, `docs/DOS-PROFILE.md` of 07:33 UTC) + D7a's staged files + D7b's
(`obj/mkoverlay.py`), the bases of `BASE-SHA256.txt` rechecked:

* **Builds** (`obj/ball.py`, the tree's build.cmd and flags with `--nogen`): Checked, CheckedNoObs and Release BUILD_OK
  (portable sources 297; 271, 278 and 231 s).
* **cc.cmd** (`obj/ccall.py`: c11 and c17 /W4 /WX and the clang C99 parse, every variant) on the 17 files of D7a and
  D7b (`pdos_scn_report.c`, `pdos_fx.c`, `pdos_aplay.c`, `pdos_profile.c`, `pdos_seq.c`, `pdos_prov.c`,
  `pdos_fontmap.c`, `pdos_adapt.c`, `pdos_adapt_tab.c`, `pdos_shadow.c`, `pdos_replay.c`, `test_pdos_report.c`,
  `test_pdos_scene.c`, `test_pdos_profile.c`, `test_pdos_shadow.c`, `test_input.c`, `harness.c`): CC_OK, except
  `test_input.c`'s clang parse, which reports only the base's own missing `square_only` initializer (line 176 here, 172
  in the tree; D6f and D7a recorded it; build.cmd does not tidy the tests); its c11 and c17 compiles pass.
* **Unit** (`obj/unit.py`, the tree's build/gamedata read only): all 55 programs (test_ne aside) pass in Checked,
  CheckedNoObs and Release, w32_test_host_win32 included.  Against the D6 gate's logs (`build/d6-gate-2-test-checked.log`,
  `-5-test-noobs.log`, `-8-test-release.log`): Checked and Release test_input 502 -> 522, test_pdos_profile 51 -> 59,
  test_pdos_scene 136 -> 141, test_pdos_shadow 175 -> 181, test_pdos_report new 169; CheckedNoObs test_input 446 ->
  466, test_pdos_profile 47 -> 55, test_pdos_scene 137 -> 142, test_pdos_shadow 173 -> 179, test_pdos_report 169; every
  other count equal.
* **Checks** on the overlay: `registry.py check` (with `--dosdata` and `--disasm` of the tree's build, read only)
  REGISTRY_OK, 0 failures (the include rule ok for `pdos_scn_report.c` and `.h`; 317 `ok` lines, the tree's 315);
  `obs_lint.py` OBS_LINT_OK files 126 probes 203 callsites 101; `obs_tables.py --check` (`obj/obstab.py`, the tree's
  listing) OBS_TABLES_OK probes 203 sites 101; `pdos_scene_check.py` PASS 1084 checks, 141 scene rows, 10 font rows;
  `adapters.py check` ADAPT_OK rows 123 steps 25 (`adapters.py gen` leaves DOS-PROFILE.md unchanged); `nodos.py check
  --root obj/src` (the three variants' binaries) NODOS_OK, 1124 files, 0 hits.
* **ext_adapt's d7a and d7b pairs** (`obj/runadapt.py` with the private Checked harness): 9 of 9.  d7a (5): as D7a's
  record.  d7b (4): the first press decided by I-report/info-press at (544, 164) (class P: the client origin +
  ceil(16L/10) of the DOS point (300, 52)), the second by I-report/press at the window's centre (320, 240) (class X);
  the DOS-form run equals its Windows-form pair (coreinput 42 lines, frames 683; exit 0, 0); timeline.log `report`
  (O14:0D43, row 69) at 55,550,650 us and `report_end` (kind 0) at 57,401,650 us; the `report` line: opens 1, ends 1,
  copies 2, placed 7, info_waits 1, nests 0, other 0, tile_unknown 0, return_none 1.
* **ext_p0** (the tree's runner, `--exe` the private Checked harness, `--root obj/p0root`): V0, V1, V2 on `menus` P0_OK
  (7 checks; V0 equals its baseline as amended).  V1's and V2's `pdos_rows`: no count on rows 67..72 (D7a alone: 1
  `unexplained` on each of 68..72 and 14 on row 98); `r98.unexplained` 2 (Civilization Score's CloseReportScreen, row
  75, D7c's), and rows 73..77 (D7c's) and 79 (D7h's) as before.  The `report` line: opens 6, ends 6, fills_window 12,
  fills_port 7, titles 7, pens 2, copies 8, city_holds 3, portraits 11, other 0, return_none 6, placed 35,
  drawn_portraits 3, citizens 2, labels 0, dropped 44, nests 0, info_waits 1, tile_unknown 0.

## Deviations from the brief

1. **The shadow engine gains the negative claim** (`pdos_shadow.c/.h`, not in the brief's file list): DrawTileImpl's
   buffer is composed as raw bits (SetBitmapBits), which the engine counts as unexplained on any shadowed bitmap outside
   a DROP bracket, and DrawTile is an entry-only probe (no DROP macro can bracket it).  The report's claim of the
   bitmaps made inside its DrawTile is the narrowest way to keep rows 68, 70, 71 and 72 at no unexplained event:
   existing owners return 0 or 1 and are unaffected; `test_pdos_shadow.c` covers the new return value.
2. **`present/dos/pdos_prov.c` and `pdos_scene_tab.c` unchanged** (both in the brief's list): S10, S13, S17, S18 and S19
   exist since D6b and resolve every shape (`prov_unknown` 0); rows 68..72 exist with their keys, and the renderer sets
   their readiness as D7a does for row 67.
3. **`pdos_replay.c/.h` gain the place hook** (not in the brief's list): ruling 4 moves a primitive by its call site,
   and the replay is where the primitive's words are formed.  The hook is called at the exit draw only; without a
   registered hook (the tree before D7b, the replay's tests) nothing changes.
4. **`ext_timeline.py` and `ext_p0.py` unchanged:** the advisors' return is kind none (no fade) except Intelligence
   after a dossier (1B44); no recorded flow opens a dossier (the menus run's Intelligence has no embassy), and the 1B44
   fade-in is D7a's, covered by its unit tests.  `test_pdos_report` checks the exit kind 1B44 after a nested dossier.
5. **Intelligence's close takes two inputs:** DOS O14:0D43 has no O14:013B wait after the INFO poll: any input that
   opens no dossier ends the report (O14:1093 sets the end flag, cleared at O14:110F only after a dossier, O14:1100..
   1104; then O14:1139..1159 without a further wait).  The core's ShowIntelligenceAdvisor calls CloseReportScreen, whose
   WaitForKeyOrClick waits for another key or click.  The presentation does not consume or synthesize core input
   (C.12.7), so the core's second wait stays; recorded for FIDELITY.
6. **Military's two pages follow at once:** DOS closes the first page with O14:013B (the map restored, O14:060C) before
   O14:061F opens the second; the core draws DrawCasualtyReport into the same window after WaitForKeyOrClick.  The N
   frame shows the second page at once; the map is not shown for that moment.
7. **The Intelligence report's background is DOS's 1 where the core passes 0** (row 69, O14:0D4B and the dossier's
   O14:116B): the renderer takes the DOS colour (the brief's "DOS background colours where they differ, recorded"); the
   other four take the core's argument, which equals DOS's.

## What the user checks

On the coordinator's user build `build/user-builds/d7b/` (D7a and D7b together; `civ64.exe`, DOS files present), in play
(a saved game or a new one, with at least one city and a few units) with the DOS graphics (Ctrl+Shift+Backspace or the
host menu); each report fills the window as a 320 x 200 DOS screen (in the 4:3 shape when "4:3 aspect ratio for 320 x
200 screens" is checked, square when it is not), with no Go Back or Cancel row:

* **D7b-1** ADVISORS > Military Advisor (F2): MILITARY STATUS on blue: the empire and leader lines, one row per kind of
  unit (its DOS icon at the left in two alternating columns, the name, its figures, how many are active and in
  production), the Defense Minister's DOS portrait at the top right; a key or click shows MILITARY LOSSES on dark red
  (the losses by civilization in its colour, a frame in your colour); another key or click closes it.
* **D7b-2** ADVISORS > Intelligence Advisor (F3): INTELLIGENCE REPORT on blue: each civilization's name and leader, its
  government in its colour, "No embassy established." in its colour where you have none, and an INFO button drawn the
  DOS way where you have one (filled in the civilization's colour, a light and a dark edge, the label centred).  The
  pointer is visible: INFO (or the civilization's number key) shows the dossier on blue; a key or click returns to the
  report.  Closing it takes a key or click, then one more (deviation 5); after a dossier the map fades in from black.
* **D7b-3** ADVISORS > Attitude Advisor (F4): ATTITUDE SURVEY on light blue: per city its name, its citizens as the DOS
  citizen shapes in their groups, a cyan bar with the city's building icons; the totals at the bottom.
* **D7b-4** ADVISORS > Trade Advisor (F5): TRADE REPORT on green with the Domestic Advisor's DOS portrait: the city
  trade column (a city in disorder in light green), the maintenance costs, the totals and the turns to the next
  discovery.
* **D7b-5** ADVISORS > Science Advisor (F6): SCIENCE REPORT on blue with the Science Advisor's DOS portrait: the
  "Researching ..." bar with its centred line, the row of research bulbs, the advances below.
* **D7b-6** The same reports with the Windows graphics: the Windows report windows, unchanged.

D7a-1..D7a-3 (City Status and the close) are in the same user build.  Not part of this check: the World reports (D7c),
switching the graphics while a report shows.

## For the records

* **DESIGN 12.x "As implemented (D7b; area B and C)":** the advisors' rows in the renderer's table; the replay's place
  hook and the site table (ruling 4 by call site, each with its listing address); the portraits drawn (T1); the Attitude
  citizens at R:0D12:6ED4's places; the INFO buttons as R:0D12:71BF; Intelligence's INFO wait (the DOS pointer,
  I-report/info, class P), the nested dossier and the exit kind 1B44; the negative claim of the shadow engine (a
  report's DrawTile bitmaps); the new `report` counters.
* **FIDELITY** (new entries, numbers to be assigned): (a) Intelligence's close takes a second key or click (the core's
  CloseReportScreen after the INFO poll; DOS O14:0D43 ends at the first) (deviation 5); (b) Military's second page
  follows the first without the map's moment between them (O14:060C's O14:013B) (deviation 6); (c) the Intelligence
  report and dossier in DOS's background 1 where the core passes 0 (deviation 7); (d) the advisor portraits at (278, 2)
  without the Windows sunken panel; (e) the advance list of Science and the rows of the other reports page as the core
  pages them (the DOS positions per row, the core's row counts).
* **DOS-PROFILE.md prose** (rows as implemented in D7b): row 68 (Military): O14:03AD and O14:061F over the core's report
  and DrawCasualtyReport, backgrounds 1 then 4, the portrait at (278, 2), exit kind none; row 69 (Intelligence):
  O14:0D43 in background 1, the INFO buttons as R:0D12:71BF (OB2 answered: R:0D12:71BF's colours from [1946h + 2 civ]),
  the INFO wait with the pointer and I-report/info (class P), the dossier O14:1164 nested, exit kind 1B44 after a
  dossier, else none; row 70 (Attitude): O14:15F4 in background 9, the citizens S13 at R:0D12:6ED4's places, the icons
  S18/S19; row 71 (Trade): O14:07F1 in background 2, the portrait, the disorder colour 10; row 72 (Science): O14:014B in
  background 1, the portrait, the bulbs S10, the centred line with its shadow beside.  1.7.2 as staged.
* **RUNNING.md:** presentation-diag.log's `report` line gains `placed`, `drawn_portraits`, `citizens`, `labels`,
  `dropped`, `nests`, `info_waits`, `tile_unknown`; ext_adapt's d7b-info-dos and d7b-info-win runs.
* **FEATURES.md:** the DOS advisors' reports in play (D7b), with the runners above.
* **STATUS.md:** D7b landed (rows 68..72; OB2 answered; the shadow engine's negative claim).
* **manual-checklist-ext.md:** new items D7b-1..D7b-6 (above), pointing to `build/user-builds/d7b/` when D7a and D7b
  land together.
* User direction 2026-10-16 (no added Go Back / Cancel rows): no report shows one; each closes by DOS's any key or click
  (Intelligence by a second one, deviation 5).  Report items: none.
* Not edited by this unit: DESIGN.md, FIDELITY.md, STATUS.md, RUNNING.md, FEATURES.md, DOS-PROFILE.md outside the
  generated section 1.7.2, manual-checklist-ext.md, the D1 drafts and the D0 documents.

## Expected changes at the build slot

Relative to the tree after D7a's landing (D7a's own expected changes come first when they land together):

* **Unit** (Checked and Release): test_pdos_report 110 -> 169, test_input 506 -> 522, test_pdos_shadow 175 -> 181; every
  other count unchanged.  Portable sources unchanged (D7b adds no source file); obs_lint files unchanged; probes 203 and
  call sites 101 unchanged.
* `adapters-check.txt`: ADAPT_OK rows 120 -> 123, steps 25.  `pdos-scene-check.txt`, `obs-tables.txt`: unchanged.
  `nodos.txt`: byte counts grow with the binaries, the sources and the records; NODOS_OK.
* `ext-adapt.txt`: EXT_ADAPT_OK checks 194 -> 198 (the d7b lines); two more runs (d7b-info-dos, d7b-info-win; 60 s of
  virtual time each).
* presentation-diag.log (harness): the `report` line's new counters.  ext_p0: P0_OK with unchanged counts; the `menus`
  run's `pdos_rows` without rows 68..72 (D7a's 14 `r98.unexplained`: 2 remain, Civilization Score's, row 75, D7c's).
* Core outputs, G-1 fields and `ext_g1.py check`: unchanged (presentation only; the d7b pair and ext_p0 V1/V2 equal
  their references).

## Rebase notes

* **Bases:** "d7a-stage" for the files D7a changes (D7a's staged copies of 05:17 UTC, rechecked against the tree since);
  "tree" for `pdos_replay.c/.h`, `pdos_shadow.c` and `test_pdos_shadow.c` (the tree after D6g's landing and the D6 gate
  cycle).  `BASE-SHA256.txt` names each.  When D7a is rebased (a landing before it), each D7b file on a "d7a-stage" base
  is merged three ways (its base, its staged copy, D7a's new copy) and its base updated; D7b's blocks follow D7a's in
  every shared file, so the merge is D7a's change plus D7b's unchanged blocks.
* **Shared tables:** `pdos_adapt.h` (`PDOS_AS_REPORT_INFO` 0x04000000 after D7a's `PDOS_AS_REPORT` 0x02000000),
  `pdos_adapt_tab.c` (the I-report/info block after D7a's I-report rows), `adapters.py` (SCENES after D7a's row,
  `P_SCENES`), `test_input.c` (the vectors after D7a's, the count 120 + 3 = 123), `ext_adapt.py` (`d7b_runs` after
  `d7a_runs`), DOS-PROFILE 1.7.2 (regenerated by `adapters.py gen` on the merged tree, never by hand).
* **`pdos_shadow.h`** is shared with D7j (`build/d7j-stage/`, `PDOS_OWNER_MAX` 6 -> 7 on D7a's copy): D7b's change is
  the claim hook's comment only, apart from that line; the merge keeps both.
* **D7d, D7j and later units** that own surfaces may use the negative claim for their own transient bitmaps.
* Shared counts: no new source file; the obs tables unchanged (probes 203, call sites 101).
* **E4 (2026-10-17 about 07:30..08:10 UTC): D7a's registry fix and the rebase.**  D7a's staged `pdos_scn_report.c` no
  longer includes `<stdio.h>` (its diag line is formed by a local `line_field`, pdos_replay.c's helper, the same text)
  and D7a stages `gen/dos/registry.py` with `pdos_scn_report.c` in `OBSERVER_FILES` (D7a's record, "Registry fix").
  D7b's copy of `pdos_scn_report.c` takes the same change: the include removed, the helper added, and D7b's eight
  counters appended to the diag line as `line_field` calls in a delimited `extension D7b` block (the text unchanged); its
  base is D7a's new copy.  `docs/DOS-PROFILE.md`: the tree's file changed at 07:33 UTC (a D6 docs pass: the decision-8
  paragraph, rows 14 and 19, F10, L10), D7a's copy was merged three ways onto it, and D7b's copy merged three ways
  (base: D7a's old copy, D7a's new copy, D7b's copy; `obj/rebase-e4/`) without a conflict, D7b's delta (1.7.2's
  I-report/info rows and sentence) unchanged; `adapters.py gen` leaves it unchanged.  Every other base equal (the tree
  is the D6 gate's state).  `BASE-SHA256.txt` rewritten (bases and staged hashes).

## Build-slot steps

D7b lands together with D7a (`build/d7a-prep/`, `--units d7a+d7b`; D7a's record, section "Build-slot steps"), or after
D7a with the same scripts and its own cycle.  One cycle for both: the base checks of both `BASE-SHA256.txt` files, the
predictions of both records' "Expected changes", the copy-in (a file both stage lands as D7b's copy), the three-step
cycle with `build/d7a-status.txt`, Release, the user build `build/user-builds/d7b/` (`WHAT-TO-CHECK.d7b.draft.txt`:
D7a-1..D7a-3 and D7b-1..D7b-6), and a Landing section in each record.

## Landing

D7b landed together with D7a (`docs/ext-D7a-record.md`, "Landing") in one three-step cycle at the build slot of
session E4 (track A), 2026-10-17, with D7a's registry fix carried into D7b's copy of `pdos_scn_report.c` ("Rebase
notes").  The user checks D7b-1..D7b-6 are in the user build `d7b`.

* **Bases:** rechecked against the tree at 08:05 UTC on 2026-10-17 (the D6 gate's tree with the D6 docs passes up to
  07:38 UTC; `land.py --units d7a+d7b` DRY_RUN_OK 30).  Scripts in `build/d7ab-prep/` (copied from E3's
  `build/d7a-prep/`, which stays as the record of E3's backed-out attempt).  Snapshot `build/d7ab-prep/before` (the
  tree's `build/test/Checked`, which still held outputs of E3's aborted D7a test step) and `tree-before` (the 25
  replaced files); copy-in at 08:07:35 UTC (`landed.sha256`: 30 files from the two stages, a file both stage lands as
  D7b's copy, 5 references unchanged; `landed-at.txt` "units d7a+d7b").  Predictions `build/d7ab-prep/predictions.txt`,
  written before the copy-in.
* **The three-step cycle** (`build/d7ab-status.txt`): 1 `build.cmd checked` BUILD_OK 08:07:45..08:12:43 (298 s;
  portable sources checked 297); 2 `test.cmd checked` TESTS_OK 08:12:43..08:45:16 (1953 s; TEST_SECTIONS 29 failed 0;
  no flake rerun); 3 `ext_g1.py check` EXT_G1_OK runs 77 (amended 1) unchanged: **ALL_GREEN**.  4 `build.cmd` (Release)
  BUILD_OK 08:45:32..08:50:57 (324 s; portable sources 297): **RELEASE_OK**.
* **Against the predictions** (`compare.py` against E3's snapshot `build/d7a-prep/before`, the D6 gate's complete
  outputs; 47 of 63 files equal, host times left out): as predicted, unit.log test_input 502 -> 522, test_pdos_profile
  51 -> 59, test_pdos_scene 136 -> 141, test_pdos_shadow 175 -> 181, test_pdos_report new 169, every other count equal;
  registry-check REGISTRY_OK with the two include-rule lines of `pdos_scn_report.c/.h` added; OBS_LINT_OK files 124 ->
  126; OBS_TABLES_OK probes 203 sites 101; pdos_scene_check PASS 1078 -> 1084 checks, font rows 8 -> 10; ADAPT_OK rows
  116 -> 123; EXT_ADAPT_OK checks 189 -> 198 (the d7a-report and d7b-info lines, equal to the private runs'); NODOS_OK,
  files 1752 -> 1764, 0 hits; P0_OK checks 476; every other section's result equal.  Not predicted, explained: (a)
  ext-replay's informational V1 `menus` counter line (its pass conditions, kind_mismatch 0 and point_mismatch 0, hold):
  brackets 0/314/0 -> 0/314/126, device 33 -> 78, draws 0 -> 75, muted 347 -> 442, no_shadow 416 -> 245, s3_deferred 0
  -> 8: the report owner now shadows the report window and port, so the replay draws the reports' texts there and the
  port-to-window copies are deferred after the replay's leave (S3); (b) ext-p0's V4d `menus` line: 869 -> 847 shows with
  the zoom layer (the run's six reports now show the N frame, not the zoomed A frame; the check count 476 unchanged);
  (c) coverage.txt "other functions entered" 663 -> 662 (informational: the union of the coverage files the test
  programs and harness runs wrote; the core's outputs, G-1 and P0 are equal).
* **User build** `build/user-builds/d7b/`: `civ64.exe` (the Release build, SHA-256 cef67410...), `CIVWIN.zip` and
  `civdos.zip` from `build/user-builds/d4/`, `WHAT-TO-CHECK.txt` (D7a-1..D7a-3 and D7b-1..D7b-6, the earlier builds up
  to "d6g", and the 53 items still pending in the checklist at 08:51 UTC).
* Not done at this slot: the checklist sections and STATUS rows (the orchestrator's); the tree's CheckedNoObs build is
  not part of the three-step cycle (the private overlay builds and units of the three variants are in "Results").

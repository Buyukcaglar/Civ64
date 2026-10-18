# Extension phase D7, unit D7m (the end of the game) - record

Draft for the build slot (BRIEF-d7.md "Units" D7m, extension session E4, track A).  Staged in `build/d7m-stage/` on
the tree after D7c's landing (its cycle ALL_GREEN 11:44:01 UTC on 2026-10-17, `build/d7c-status.txt`), DBL's (ALL_GREEN
12:28:57 UTC, `build/dbl-status.txt`) and D7j's copy-in (12:54 UTC; its cycle ran while D7m was staged,
`build/d7j-status.txt`): the base of every changed file is the tree's file at the time of its copy (`obj/base-at-copy.txt`;
`pdos_scn_report.c/.h` at 12:23 UTC, unchanged by DBL and D7j; `pdos_registry.c/.h`, `OFFSETS.md`, `dos-decoded.txt` and
`ext_adapt.py` copied again after D7j's copy-in, 13:08 UTC, before any D7m edit; `ext_adapt.py` rebased by a three-way
merge without conflict on D6fS-a's landing, 14:26 UTC; `OFFSETS.md` and `ext_adapt.py` merged three ways and the
registry files and goldens regenerated on D7d's landing, 15:33 UTC, and again on D7l's, 16:25 UTC) and is rechecked
against the tree in `BASE-SHA256.txt` (section "Rebase notes").  Private builds and runs in `build/d7m-stage/obj/`
only: an overlay `obj/src` = the tree + the stage (`obj/mkoverlay.py`, made again at 14:26 UTC after D6fS-a's release
build, at 15:33 UTC after D7d's and at 16:25 UTC after D7l's, each between landings; `obj/sync.py` lays later stage
edits over it without touching the tree), built with the tree's build.cmd and flags (`obj/b.cmd`, `obj/ball.py`,
`--nogen`), cc.cmd's stricter checks per file (`obj/cc.cmd`), the unit programs and the harness runs from the overlay's
binaries with every output under `obj/`; the tree's build/gamedata, dosdata and cache read only.

## Result

D7m is staged, rebased on D6fS-a's (ALL_GREEN 14:19:04 UTC), D7d's (RELEASE_OK 15:32:56 UTC) and D7l's (RELEASE_OK
16:24:33 UTC) landings and privately verified on each.  With the DOS graphics
the end of the game shows the DOS power graph (O12:0573: DOS's polylines and scale, the core's frame, grid, names and
title placed by call site), the replay (O9:0000: the question in D5b's DOS box, the map as DOS's fills, the event bar,
the territories), the rating ladder (O3:065D drawn whole: the border by `pdos_rand`, the advisors' portraits, the
texture, the ladder with the rank's yellow row) and the Hall of Fame entry in the play palette (L26 confirmed and
closed); the order (row 106) and Retire (row 42) are the core's, already DOS's.  No new scene bit, adapter row or
scene-table row; one registry row (`REPLAY_MENU`, DGROUP:3FB0) checks the question's words.  A fix in D7a's frame:
a running return fade is completed before an N view opens.  Privately: the three variants build (portable sources 301),
every unit program passes in each (test_pdos_end new, 155 checks; test_dos 23,244 with the staged goldens), the
registry, obs_lint, obs_tables, scene, adapters and nodos checks pass, ext_adapt's d7a, d7b, d7c and new d7m pairs pass
(20 of 20), ext_p0 on retire, conquest and arrival is P0_OK in V0, V1 and V2 and ext_mirror on them MIRROR_OK.  On
the tree after D7l (portable sources 303) the unit programs, the static checks and the 20 pairs pass again (section
"Results").  The D7d and D7l rebases were mechanical (adjacency conflicts kept both sides; section "Rebase notes").

## Status

READY_TO_BUILD, rebased at the build slot onto the tree after D7d's and D7l's landings (the private build, units
and runs repeated there, "Results"; landed, section "Landing").  Built: rows 122 (the power graph,
O12:0573), 103 (the replay, O9:0000) and 120 (the rating, O3:065D)
in the report renderer's table (`present/dos/pdos_scn_report.c`), with their DOS drawing in a new pure module
(`present/dos/pdos_scn_end.c/.h`); row 106's order checked against R:0238:08A0 (the same as RunEndGameSequence 1088:0B6D,
no change); row 42 (Retire's end scenes) is the same sequence without the replay; row 129 and L26 (the Hall of Fame after
the game in the play palette, confirmed from the listing); a new registry row `REPLAY_MENU` (DGROUP:3FB0) for the
replay question's check.  No new adapter row and no new PDOS_AS bit: the three screens reuse D7a's `PDOS_AS_REPORT`
(I-report, class X) through the renderer's state, the replay question is D5b's re-skinned box (I-menu); the brief's
allocation 0x10000000 stays free.  Not in the unit: D7n, D7l, row 125 (the replay file's Save dialog).

## What was built

### The order (row 106) and Retire (row 42)

DOS's end sequence R:0238:08A0 (DOS listing): O12:0573 (the power graph), O9:0000 (the replay) unless [DC48h] is 2 (the
game retired), R:01A8:0268, then unless [4CD8h] & 100h (a spaceship's arrival): O20:0CA9 (the score of the human, 1),
O3:065D((palaces / 2) - 1, the score), O3:002B (load the Hall of Fame), O3:0513 (insert the entry), O3:0083 (save it),
R:01A8:0250.  The core's RunEndGameSequence 1088:0B6D has the same calls in the same order with the same conditions
(g_quitRequested 2, g_spaceshipFlags & 100h, g_palaceImprovementCount / 2 - 1): the order needs no presentation of its
own; each screen is drawn where it opens.  Retire (File > Retire, row 42) runs the same sequence with g_quitRequested 2:
the power graph, the score, the rating and the Hall of Fame, no replay.

### The power graph (row 122; O12:0573, ShowPowerGraph 1188:07AD)

D7a's frame (OpenBlankReportScreen 1188:0000) in DOS's background 8 (O12:0585; the core passes 0), the core's primitives
drawn by the replay and placed by the call site (a D7m part of D7c's site table): the frame R:1D05:0A05(4, 9, 137h, B7h,
0) inclusive (O12:05A6..05B9; the core's FrameRectLogical(4, 9, 137h, B7h, 0)), the grid lines to C0h in 0 (O12:05E1..05EE;
the core's (x, 9, x, BFh, 8)), the civilizations' names in [1946h + 2 civ] (O12:06EF..070B; the core's civ + 10h), the
title R:0182:0086(DGROUP:43D8, 64h, 2, 15) left at x 64h with its shadow below (O12:071B..072B); the years are DOS's
(O12:065A..0667) and stay.  The polylines are DOS's (O12:0733..07E8), drawn into the port's shadow at CloseReportScreen's
entry, before its copy shows them; the core's MoveTo/LineTo lines (1188:0A7F..0AED) on the port are dropped.  For
civilizations 1..7 shown (alive, test [6B8Ah], or not above g_numAiOpponents + 1, O12:06D8..06ED), sample j below
turn / 4 (O12:0698..06A7, toward 0) and below 96h (O12:07B2): R:0182:000A from the previous point to (2j + 4, C0h - v),
v = (B4h * power) / max unsigned (O12:0751..075D), the first from (4, C0h); max from 32h (O12:05A1) over the
civilizations 1..8 shown and every sample (O12:0695..06CD, unsigned, no 96h limit).  The history and the colours are the
core's (g_powerHistory 12D8:3200, [1946h + 2 civ] through the registry table).  The end: R:0866:25D7 (O12:07F3), exit
kind none.

### The replay (row 103; O9:0000, RunReplayMenu 1180:0000)

The question (ChooseReplayModeAndOpenWindow's ShowTextDialog, DSTR 389Eh) is D5b's re-skinned box over the A frame
(I-menu): its words are the core's; DOS's (DGROUP:3FB0, O9:0016 -> R:0238:001E) are a registry row, and the renderer
counts whether they are the core's (`menu_same`, `menu_differs`; draws nothing of its own).  Each view of RunReplayMenu's
loop is an N view from its window's GR_DialogOpen (1180:01D4) to the window's destruction (CloseReplayWindow 1180:0297,
O9:0877): page 0 filled in DOS's 0 (O9:0113), the rows ready, the play palette (PDOS_PAL_KEEP); the def stays for the
next question.  At PlayReplay's entry (1180:02D3) the map is drawn as O9:0113..0191 draws it: the squares (4x, 4y + 4,
4, 4) of rows 1..48 in colour 1 for ocean (GetTerrainType == 0Ah, R:1AEA:134A) and 8 for land - fills, not tiles (the
map page read through w16q_read, its offset wrapping in its segment).  Each ShowReplayLine (1180:0E78) draws the bar
O9:08A3: the core's line (g_messageText) upper-cased (ASCII letters, R:2045:298A) for the human's events, folded, cut to
138h (R:1F4D:04F7), the fill (0, 0, 320, 8, 15), R:0182:005C at (4, 1) in colour 0, in the font in effect (1).  A city
event's territory (types 1 and 9; O9:0AC8) is drawn at the event's first square copy (RedrawReplayTerritory's
CopyPortToWindow, 1180:135C), when the core's city table already holds the change, or at PlayReplay's PollMouseClick
after the event (1180:0DC8) when nothing was copied: the squares x - 5 .. x + 4 clamped to 0..80 and y - 5 .. y + 4
clamped to 2..49, ocean left, the nearest city by R:1DC4:0289's distance (O9:0A64: the first least, from 3E7h), colour 8
from distance 6 or on another body (R:1AEA:1942: the map page's (x, y + 50)), the city's own square 7 for civilization 1
and 15 for the others, else [1946h + 2 owner].  The log (g_replayLog 1390:03AF, g_replayLogLength) is read at
PlayReplay's entry and followed by its polls (one after each event, the event's size from its type).  Mode 4
(g_forceSilentReplay) is quiet: no N view, the window's events dropped (O9:0027, 0111, 08A9, 0AD0).  Mode 3 (Write Replay
to Disk) opens the view at PlayReplay's entry: the core asks for the file's name (ShowSaveFileDialog, row 125) with its
window open, so the view, and I-report, wait until the dialog is over (DOS creates REPLAY.TXT before its map, O9:0037..
0085).  Every event and replayed primitive on the replay's window and port is dropped (page 0 holds the DOS screen).

### The rating (row 120; O3:065D, ShowCivilizationRatingRanking 1080:06FF)

The rank as O3:0663..06B8 computes it (the core's 1080:0711..075F, the same): with a score, pct = score * (difficulty + 1)
/ 50 in 16 bits (O3:0671..0677: imul, cwd, idiv) and the last i of 1..20 with i * i / 3 below pct, minus 1; without one
the caller's (palaces / 2 - 1); -1 no screen; at most 19.  The N view from the dialog's GR_DialogOpen (1080:0777): page 0
drawn whole as O3:065D draws it: the fill in 15 (O3:06D0), R:0866:260E's ornamental border (`pdos_border`: the tile set
C0h + 20h random(2) from page 2 (.., 120..135), a DOS-only choice through `pdos_rand`, the effect "border" as
`pdos_scn_init`/`pdos_scn_slots` name it, instance per screen; `pdos_rand` is the presentation's own generator, a local
state seeded by `pdos_fx_rand`, and never touches the core's RNG stream g_randSeed: P0), the portraits of advisors 1 and
2 from page 2 (200, 140)
and (240, 140), 40 x 60, at (10, 10) and (270, 10) (O3:06F1..073B; D7a's page-2 portraits, read at use), font 7
(O3:0742), the texture (80, 4, 160, 27) (R:1DC4:03CE) and the bevel (80, 4, 159, 26, 11, 8) (R:1D05:0A66), two heading
lines at y 6 and 14 (no score: g_fameHeadingTexts 0 and 1; a score: 2, then 3 + itoa(pct) + DGROUP:3473's tail), the
rank's line names[19 - rank] + its tail at y 22, all centred at 160 in 15 (O3:0788..08EA), the ladder names[19 - i]
centred at (160, 184 - 8i) for i = 0..rank in 7, the rank's own in 0 (O3:08F2..0955), and the rank's row (80, 183 -
8 rank, 160, 8) recoloured 15 -> 14 (O3:0957..097C).  The texts are the core's (g_fameRankNames 12A0:0000,
g_fameHeadingTexts 12A0:01F4, 1420:158B, 1420:159A; DOS R:26D4:0000, :01F4, DGROUP:3473, 3471/3482), folded.  The
window's events are dropped; the end at its destruction, exit kind none (O3:099E: R:0866:25D7).

### The Hall of Fame after the game (row 129; L26)

L26 confirmed (DOS listing): R:0238:08A0 loads no palette between the rating and O3:0513 (the insert) and O3:0083, and
O3:0513 and O3:00D7 load none: the Hall of Fame after the game shows in the play palette that the Score's R:0238:1B44
restored (O20:13EB).  At InsertHallOfFameEntry's entry (1080:0595) the N machine takes the play palette (a running return
fade completed first, C.9); D5f's renderer draws the screen (Clear omitted, the entry highlighted) as before.

### A fix in D7a's frame: a running return fade

The Score (row 75) ends with R:0238:1B44 (D7a: the fade-in from black on the A canvas, 30 frames).  In the end sequence
the rating opens at once after it, while that fade runs: D7a's `begin` (and D7m's view) copied the A machine's DAC, which
the fade held near black, so the N view would show in black.  The fade is now completed first (`pdos_fx_return_abandon`,
as C.9 says for an N scene shown before its end), in `begin`, the D7m views and the Hall of Fame's palette.

### Counters

presentation-diag.log's `report` line gains `graphs`, `graph_segments`, `ratings`, `replays`, `replay_lines`,
`replay_regions`, `replay_squares`, `menu_same`, `menu_differs`, `fame_palettes`, `end_unread`; timeline.log gains the
steps `report_graph` (O12:0733, the segments), `report_rating` (O3:065D, the rank), `report_replay` (O9:0113, the land
squares), `report_defer` (mode 3) and `report_end` with O9:0877 for a replay view; `report_quiet` for mode 4 (D7c's step).

## Files

Changed (`BASE-SHA256.txt`): `present/dos/pdos_scn_report.c/.h` (the three rows, the graph's sites, the D7m block, the
fade fix, the counters), `present/dos/pdos_registry.c/.h` and `tests/dos-decoded.txt` (generated by `registry.py gen` and
`goldens` from the new OFFSETS row), `docs/dos/OFFSETS.md` (`REPLAY_MENU`, DGROUP:3FB0, reader O9:0016, and its note),
`tests/harness/ext_adapt.py` (the d7m pair).  New: `present/dos/pdos_scn_end.c/.h`, `tests/test_pdos_end.c`, this
record.  Unchanged, though the brief lists them: `present/dos/pdos_scn_fame.c` (D5f already omits Clear and highlights
the entry), `pdos_prov.c` (no new shape rule: the rating's tiles and portraits are page-2 copies), `pdos_scene_tab.c`
(rows 103, 106, 120, 122 and 129 exist with their keys), `pdos_adapt_tab.c` (I-report and I-menu decide every input of
the unit), `ext_adapt.py`'s rows aside.  build.cmd and test.cmd unchanged (build.cmd compiles `present\dos\*.c`,
test.cmd runs every `test_*.exe`); `pdos_scn_end.c` includes no `w16_obs.h`, `input.h` or `<stdio.h>` (registry.py's
include rule passes; OBSERVER_FILES unchanged).  No BUILD-TEST-ADDITIONS.md.  The D7m parts of the shared files are
delimited `extension D7m` blocks after D7c's, one-line hunks with an `extension D7m` comment.

## Tests

* **`tests/test_pdos_end.c`** (new, 155 checks in every variant; synthetic memory, font, pictures and texts, no DOS
  byte): the power graph's rule (the civilizations shown, the scale from 32h over the shown civilizations 1..8 and every
  sample with no 96h limit, the polylines of civilizations 1..7 from (4, C0h), 2 pixels a sample, at most 96h samples,
  turn / 4 clamped) and its state read; the rating's rank (the 16-bit product, the last i with i * i / 3 below the
  percentage, -1 none, at most 19), its screen (the fill, the border's tiles from page 2 for both random(2) outcomes and
  the same screen for the same seed, the edges under the texture, the portraits, texture and bevel, both heading forms,
  the ladder and the rank's row recoloured 15 -> 14, nothing without a rank or machine) and its texts read; the
  replay's event sizes, distance (the x wrap), nearest city (the first least), map fills, map page read (the offset
  wrapping in its segment), territory colours and clamps, the event bar (upper-cased, cut to 138h) and the question's
  words against a DOS-form menu; through the module (synthetic ObsEvent / ObsProbe streams): the graph's sites, the
  core's lines dropped, the polylines in the port at CloseReportScreen's entry and on page 0 after the copy, an
  unreadable state counted; the rating on page 0 at its GR_DialogOpen with a running return fade completed first, its
  window's events dropped, the border per effect instance; the replay view (the map at PlayReplay, the bars, the
  territory at the first square copy or at the poll, the log followed through the polls), its end at the window's
  destruction (O9:0877), mode 4 quiet, mode 3 deferred to PlayReplay, the end at RunReplayMenu's return; L26 (the play
  palette at InsertHallOfFameEntry's entry); the diag line.  On the base it does not build (`pdos_scn_end.h` absent),
  and its module checks need rows 122, 103 and 120 of the renderer, which the base leaves undrawn.
* **`tests/harness/ext_adapt.py`, the d7m pair** (2 runs, 6 checks; `d7m_runs` after `d7j_runs`): the conquest route
  (D7j's save edit, `ENDGAME.SAV`; `REPLAY.REP` answered to the replay's Save dialog), 82,500 ms, the DOS profile from
  the chord at 45 s (the power graph's wait): Space on the graph, the question three times (q and Return: Quick Replay,
  Space in its wait; w and Return: Write Replay to Disk; n and Return: No replay, the item the bar opens on, so n is
  consumed by I-menu/key, R:1D05:03FD searching below the bar only), Space on the score, the rating and the Hall of
  Fame; the Windows form presses the letters the DOS form produced (Q, W) at the same times.  Asserted: the decisions
  (I-report/key; I-menu/hotkey and I-menu/return-escape twice; I-menu/key; no click, nothing refused); the DOS-form run
  equals its Windows-form pair; the same `REPLAY.REP` in both; timeline.log's `report` rows 122, 103, 103, 75, 120, one
  `report_graph` (O12:0733) before the graph's key, two `report_replay` (O9:0113), one `report_defer` (mode 3, not
  after the second view's start), no `report_quiet`, one `report_rating` (rank 0..19), five `report_end` with two
  O9:0877; the 320 x 200 N frame shown in each view after the chord; the `report` line (graphs 1, graph_segments > 0,
  ratings 1, replays 2, menu_same 3, menu_differs 0, fame_palettes 1, end_unread 0).  On the base the steps
  `report_graph`, `report_replay`, `report_rating` and the D7m counters do not exist: the timeline and diag checks fail.
* `ext_p0.py`, `ext_timeline.py`, `ext_frames.py`, `ext_mirror.py`: unchanged.  ext_p0's and ext_mirror's `retire`,
  `conquest` and `arrival` runs pass through the end sequence (section "Results").

## Results (private, `build/d7m-stage/obj/`)

Session E4 (2026-10-17), on the overlay `obj/src` = the tree after D6fS-a's landing + the stage (made 14:26 UTC), the
bases of `BASE-SHA256.txt` rechecked:

* **Builds** (`obj/ball.py`, the tree's build.cmd and flags with `--nogen`): Checked, CheckedNoObs and Release BUILD_OK,
  portable sources 301 (`pdos_scn_end.c` added; 369, 292 and 263 s).  Before the rebase (on D7j's tree) the same (243,
  246, 464 s).
* **cc.cmd** (`obj/ccall.py`: c11 and c17 /W4 /WX and the clang C99 parse, every variant) on `pdos_scn_end.c`,
  `pdos_scn_report.c`, `pdos_registry.c` and `test_pdos_end.c`: CCALL failed 0 (12 CC_OK).
* **Unit** (`obj/unit.py`, the tree's build/gamedata read only): all 57 programs (test_ne aside) pass in Checked,
  CheckedNoObs and Release, w32_test_host_win32 included, but test_dos's golden comparison: test_dos reads its goldens
  beside the gamedata it is given (the tree's `tests/dos-decoded.txt`, without `REPLAY_MENU`); its decoded output equals
  the staged `tests/dos-decoded.txt` line for line in each variant (the one new line), so at the build slot it passes.
  test_pdos_end 155 and test_dos 23,243 -> 23,244 checks in each variant; against D6fS-a's cycle log
  (`build/d6fsa-2-test-checked.log`, `obj/cmpunit.py`) every other Checked count is equal (test_pdos_report 229).
* **Checks** on the overlay: `registry.py check` (with `--dosdata` and `--disasm` of the tree's build, read only)
  REGISTRY_OK, 0 failures, 345 `ok` lines (the tree's 340: `REPLAY_MENU`'s three, the include rule for
  `pdos_scn_end.c` and `.h`; dos-decoded 1,374 lines); `registry.py gen` and `goldens` in the overlay reproduce the
  staged `pdos_registry.c/.h` and `dos-decoded.txt` byte for byte; `obs_lint.py` OBS_LINT_OK files 134 probes 203
  callsites 101 (the tree's 132: `pdos_scn_end.c` and `.h`); `obs_tables.py --check` (`obj/obstab.py`, the tree's
  listing) OBS_TABLES_OK probes 203 sites 101; `pdos_scene_check.py` PASS 1084 checks, 141 scene rows, 10 font rows;
  `adapters.py check` ADAPT_OK rows 130 steps 25; `nodos.py check --root obj/src` (the three variants' binaries; the
  tree's build/dosdata and build/gamedata read) NODOS_OK, 1,148 files, 0 hits.
* **ext_adapt's d7a, d7b, d7c and d7m pairs** (`obj/runadapt.py`, the staged ext_adapt.py with the private Checked
  harness): 20 of 20.  d7a (5), d7b (4) and d7c (5) as their records (the `report` lines end with the D7m counters at
  0).  d7m (6): the rows I-report/key, I-menu/hotkey, I-menu/return-escape, I-report/key, I-menu/hotkey,
  I-menu/return-escape, I-menu/key, I-menu/return-escape, I-report/key, I-report/key, I-wait/fame-key; the pair equal
  (coreinput 43 lines, frames 690; exit 0, 0); `REPLAY.REP` 4,847 bytes in both; timeline.log `report` O12:0573 (122),
  O9:0000 (103) twice, O20:0CA9 (75), O3:065D (120); `report_graph` 42 segments at 44,501,750 us (in the Windows
  profile, before the chord: the DOS renderer follows the core behind it); `report_replay` 589 land squares at
  49,001,750 and 55,001,750 us; `report_defer` at 55,001,750 us (the Save dialog answered at once by `--file-answer`, so
  the deferred view opens in the same instant); `report_rating` rank 19; `report_end` O14:013B, O9:0877 (52,501,750
  us, the quick replay's key), O9:0877 (55,038,750 us), O14:013B, O14:013B; 320 x 200 shows per view [1, 10, 3, 2, 1];
  the `report` line: opens 5, ends 5, graphs 1, graph_segments 42, ratings 1, replays 2, replay_lines 29,
  replay_regions 18, replay_squares 966, menu_same 3, menu_differs 0, fame_palettes 1, end_unread 0, fade_abandoned 1
  (the Score's fade-in completed when the rating opened), return_1b44 2, dropped 9,778 (the replay windows' events).
* **ext_p0** (the tree's runner, `--exe` the private Checked harness, `--root obj/p0root`, `--only
  retire,conquest,arrival`, V0, V1, V2): P0_OK checks 21 (V0 equals its baseline; V1 and V2 equal V0; the switch
  assertions; no count on a D4, D5 or D6 row).  V1's `pdos_rows`: no count on rows 42, 103, 106, 120, 122 or 129
  (retire: none; conquest: r101 2, r114 2, the newspaper's and the conqueror ending's; arrival: r0, r19, r101, r130,
  D7n's arrival among them).  V1's `report` lines: retire graphs 1 (35 segments), ratings 0 (the rank is -1 at that
  score: neither DOS nor the core shows the rating), fame_palettes 1; conquest as the d7m pair; arrival graphs 1,
  menu_same 1, fame_palettes 1, ratings 0.
* **ext_mirror** (the tree's runner, the private harness, `--only retire,conquest,arrival`): MIRROR_OK runs 3
  (dos_mismatched 0, dos_unexplained 0, P0 equal).
* **Frames looked at** (private dumps, `obj/dumpend.py` reruns d7m-end-dos with `--dump-presented`; PNGs in
  `obj/adaptroot/dump/png/`): the power graph on dark grey with the black frame from (4, 9), the names in their
  colours, the core's title text at x 64h with its shadow, "4000BC" under the grid and the short polylines at the
  bottom left (turn 23: five samples); the replay: blue ocean and grey land squares, the white bar with the event in
  black, the territories in the owners' colours with the cities' own squares; the first show of each replay view is
  black (the window's fill, O9:0113, one tick before PlayReplay draws the map); the rating: the ornamental border, the
  two portraits, the stone box with the two heading lines (the percentage 205) and the rank's line, the ladder of all
  20 names from the bottom up to the rank's yellow row at the top; the Hall of Fame in the play palette with the new
  entry highlighted; the replay question in the DOS box over the map with the bar on Quick Replay after q.
* **After the D7d and D7l rebases** (the overlay made again after each landing's release build, the Checked variant
  built with `obj/ball.py`): after D7d (15:33 UTC) BUILD_OK, portable sources 302; test_pdos_end 155,
  test_pdos_report 229, test_pdos_city 78, test_pdos_adapt 155, test_dos 23,251 (its output equal to the staged
  goldens); REGISTRY_OK 383 ok lines (the tree's 378); the 20 pairs pass (`obj/runadapt-d7d.log`).  After D7l (16:25
  UTC) BUILD_OK, portable sources 303 (16:29 UTC); test_pdos_end 155, test_pdos_report 229, test_pdos_space 73,
  test_pdos_city 78, test_pdos_adapt 155, test_pdos_profile 59, test_pdos_shadow 181, test_input pass, test_dos 23,253
  (its output equal to the staged goldens; `obj/u-d7l.log`); `registry.py check` REGISTRY_OK 402 ok lines (the tree's
  397: `REPLAY_MENU`'s three, the include rule for `pdos_scn_end.c/.h`; dos-decoded 1,382 -> 1,383 lines); obs_lint
  files 138 probes 203 callsites 101; obs_tables 203 / 101; pdos_scene_check 1084; ADAPT_OK rows 138 steps 25; the 20
  pairs pass (`obj/runadapt-d7l.log`, the d7m pair's counts as above).  `present/dos/pdos_shadow.h` (D7l's
  PDOS_OWNER_MAX 9) is the tree's: D7m adds no owner.

## Deviations from the brief

1. **The replay map is drawn with fills, not D7c's tiles:** the brief says "the replay map with D7c's 4x4 tiles"; O9:0113..
   0191 draws each square with the fill R:0000:0BFA in 1 (ocean) or 8 (land), no page-2 tile (DOS listing).  The DOS
   form is drawn.
2. **No DOS wait after a replay; the core's wait kept:** DOS's O9 ends the view after the last event (O9:083D -> 0877,
   no wait); the core's RunReplayMenu waits for a key or click after PlayReplay in modes 1 and 2
   (WaitForKeyOrClick 1180:0162).  The view stays until that key (P0: the core's flow; I-report passes it).
3. **Complete Replay's pace is the core's:** DOS's mode 2 waits for a key after each event (Escape ends the replay); the
   core waits DelayTimerTicks(5) per event and any key ends it.  The core decides (P0); recorded for FIDELITY.
4. **The question asked again:** DOS asks again only after modes 1 and 2 (mode < 3); the core's RunReplayMenu loops until
   "No replay" or a failed window.  The core's loop is kept (P0).
5. **Mode 3's file and view:** DOS writes REPLAY.TXT with no dialog and draws its map at once; the core asks for the
   file's name first (row 125, not in the unit).  The view opens at PlayReplay's entry (section "The replay"); the CR LF
   that DOS's mode 3 writes after a line is not drawn on the bar (the core's line has none).
6. **The scale reads 256 samples at most:** DOS and the core read turn / 4 samples for the scale with no 96h limit (the
   core's own reads past its 150 are findings U5); the renderer reads up to 256 (`PDOS_GRAPH_SAMPLES`) through
   w16q_read, which covers turn 1023.
7. **No new scene bit, no adapter or scene-table row:** the brief allows PDOS_AS 0x10000000; the report state is reused
   (section "Status"); `pdos_scene_tab.c`, `pdos_adapt_tab.c`, `pdos_prov.c` and `pdos_scn_fame.c` unchanged.
8. **The fade fix** (section "A fix in D7a's frame") changes D7a's `begin` (not in the brief): one condition, recorded.

## What the user checks

On the coordinator's user build (D7m landed; `civ64.exe`, DOS files present), in a game with the DOS graphics
(Ctrl+Shift+Backspace or the host menu).  Each screen fills the window as a 320 x 200 DOS screen (in the 4:3 shape when
"4:3 aspect ratio for 320 x 200 screens" is checked); none has a Go Back or Cancel row.  Two ways to the end of the game:
Retire (Game > Retire; the end without the replay) and the end of a game won by conquest (capturing the last city of the
last other civilization; ext_adapt's d7m pair reaches it from a copy of the pinned save with one rival left, see
"Results"), which adds the replay:

* **D7m-1** The power graph (first after the end): a dark grey screen with a black frame, black vertical grid lines, the
  years along the bottom, the civilizations' names in their colours and the title at the top left with its shadow; one
  line per civilization in its colour, starting at the bottom left and two pixels to the right per four turns.  Any key
  or click goes on.
* **D7m-2** After a conquest only (not after Retire): the replay question in the DOS box (as the other DOS questions
  look), with its four choices, the bar on "No replay"; a choice's first letter (q, c, w) moves the bar down to it and
  Return takes it (n does nothing there: DOS looks for the letter below the bar only, and the bar is on it).
* **D7m-3** Quick Replay: a black screen with the world as small squares (blue ocean, grey land), a white bar at the top
  with each event's text in black (your own events in capitals), and around each founded or captured city a block of
  squares in its owner's colour, the city's own square white (light grey for the white civilization's), grey where land
  is far from any city or across the water.  After the last event a key or click returns to the question.
* **D7m-4** Write Replay to Disk: the Windows Save dialog first (with the DOS graphics it is still the Windows dialog,
  row 125 is later work); after it, the same replay screen as D7m-3, then the question again.  "No replay" goes on.
* **D7m-5** After the Civilization Score: the rating screen: white, with the ornamental DOS border around the whole
  screen (one of two border styles), the two advisors' portraits in the top corners, a stone-textured box at the top
  with three white lines (your percentage and your title), and the ladder of titles from the bottom up in grey, your own
  title in black on a yellow row.
* **D7m-6** Then the Hall of Fame in the game's own colours (not the title screen's), your new entry highlighted, no
  "Clear" choice.
* **D7m-7** The same ends with the Windows graphics: the Windows screens, unchanged.

Not part of this check: switching the graphics while one of these screens shows; the spaceship arrival and the
civilization-destroyed screens (D7n); the Save dialog's DOS form (row 125).

## For the records

* **DESIGN** (12.x, the report renderer's "As implemented"): D7m adds rows 122 (O12:0573), 103 (O9:0000) and 120
  (O3:065D) to the report renderer's table, their DOS drawing in the pure module `pdos_scn_end.c` (the graph's
  polylines and scale, the rating screen, the replay's map, bar and territory, the question's word check), read through
  w16q_read only; the graph's frame, grid, names and title are placed by D7c's site table; each replay view is an N view
  from the replay window's GR_DialogOpen to its destruction (mode 3: from PlayReplay's entry, after the Save dialog;
  mode 4: quiet); the rating's border choice through `pdos_rand` with the effect "border" per screen instance; the
  Hall of Fame after the game takes the play palette (L26).  No new PDOS_AS bit (0x10000000 stays free), no adapter or
  scene-table row: the report state (I-report, class X) and D5b's re-skinned question box (I-menu) decide every input.
  D7a's `begin` completes a running return fade first (C.9).
* **FIDELITY** (new entries; numbers by the docs pass):
  * F-new-1: after a Quick or Complete Replay the core waits for a key or click (RunReplayMenu's WaitForKeyOrClick
    1180:0162); DOS ends the view after the last event with no wait (O9:083D -> 0877).  The view stays until that key.
  * F-new-2: Complete Replay's pace is the core's (DelayTimerTicks(5) per event, any key ends it); DOS waits for a key
    after each event and Escape ends the replay (O9:0830..089E).
  * F-new-3: the replay question is asked again after every mode until "No replay" (the core's loop); DOS asks again
    only after modes 1 and 2 (O9:0007, mode < 3).
  * F-new-4: Write Replay to Disk asks for the file's name in the core's Save dialog (row 125, still the Windows dialog)
    before the replay view opens; DOS writes REPLAY.TXT without a dialog and draws its map at once (O9:0037..0085); the
    CR LF DOS writes after each line is not drawn on the bar.
  * F-new-5: the rating screen's border style (DOS: random(2) from the C run time's shared stream, R:0866:261A) is a
    `pdos_rand` draw seeded per screen instance (Choice B11, effect "border"): either style, never the core's RNG.
    `pdos_rand` is a presentation-side generator (`present/dos/pdos_rand.c`, extension D4a): its state is a local
    `PdosRand` of the renderer (`rating()` in `pdos_scn_report.c`), seeded by `pdos_fx_rand` from the effect name and
    instance (`pdos_effect_seed`); it never reads, writes or advances the core's RNG stream (g_randSeed) and reads no
    clock, so the core's random draws and their order are unchanged (P0; ext_p0's conquest run, which shows the rating,
    equals V0 in V1 and V2).
  * F-new-6: when the rating opens while the Score's return fade-in (R:0238:1B44) still runs, the fade is completed at
    once (C.9) and the rating shows in the full play palette; in DOS the Score's fade has run its steps when R:0238:08A0
    calls O3:065D (inferred: R:0000:04AA's steps run inside the call).
  * F-new-7: the power graph's scale reads at most 256 history samples (turn 1023); DOS and the core read turn / 4
    samples (beyond 150 the core's own reads, U5).
* **DOS-PROFILE**: OPEN item 26 (L26) closed: R:0238:08A0 loads no palette between O3:065D and O3:0513 / O3:0083, and
  O3:0513 and O3:00D7 load none (DOS listing): the Hall of Fame after the game shows in the play palette restored by the
  Score's R:0238:1B44 (O20:13EB); as implemented in D7m.  The rows' prose (each "as implemented in D7m (2026-10-17,
  `pdos_scn_report` / `pdos_scn_end`)"):
  * row 42 (Retire): the end sequence of row 106 without the replay (g_quitRequested 2; R:0238:08A0's [DC48h] test).
  * row 103 (Replay): the question is the core's ShowTextDialog in D5b's re-skinned box (I-menu; its words compared
    with DGROUP:3FB0, the registry's `REPLAY_MENU`); each view an N view from the replay window's GR_DialogOpen to its
    destruction (O9:0877): the map O9:0113..0191 as fills (ocean 1, land 8, rows 1..48; not tiles), the event bar
    O9:08A3 (the human's events upper-cased, cut to 138h, at (4, 1) in 0 on a fill in 15), each city event's territory
    O9:0AC8 (the nearest city by R:1DC4:0289, colour 8 from distance 6 or on another body, the city's square 7 or 15);
    mode 3 from PlayReplay's entry after the Save dialog (row 125); mode 4 quiet; the post-replay wait, the pace and the
    question loop the core's (F-new-1..4).
  * row 106 (End-game sequences): the order of R:0238:08A0 is the core's RunEndGameSequence order (power graph, replay
    unless retired, score, rating, Hall of Fame load, insert, save), so no presentation of its own; each screen is drawn
    where it opens (rows 122, 103, 75, 120, 129).
  * row 120 (rating): O3:065D drawn whole on page 0 at the dialog's GR_DialogOpen (1080:0777): the fill in 15, the
    ornamental border R:0866:260E (`pdos_border`, F-new-5), the advisors' portraits from page 2 (200, 140) and (240,
    140) at (10, 10) and (270, 10), font 7, the texture (80, 4, 160, 27) and bevel (80, 4, 159, 26, 11, 8), the heading
    lines at y 6 and 14 and the rank's line at y 22 centred in 15, the ladder centred at (160, 184 - 8 i) in 7, the
    rank's in 0 on its row recoloured 15 -> 14; the rank O3:0663..06B8's (16-bit product); exit kind none.
  * row 122 (power graph): D7a's frame in DOS background 8; the core's frame, grid, names and title placed by call site
    (frame R:1D05:0A05(4, 9, 137h, B7h, 0), grid to C0h in 0, names in [1946h + 2 civ], the title at x 64h with its
    shadow); the polylines O12:0733..07E8 drawn into the port's shadow at CloseReportScreen's entry (the core's
    MoveTo/LineTo dropped), the scale from 32h over the shown civilizations 1..8 (F-new-7); exit kind none.
  * row 129 (Hall of Fame entry): after the game in the play palette (L26 closed; F-new-6 for a running fade); D5f's
    renderer, "Clear" omitted, the entry highlighted.
* **OFFSETS** (in the stage): `REPLAY_MENU` DGROUP:3FB0 (str, 1, 96 bytes, reader O9:0016) and its note.
* **RUNNING**: presentation-diag.log's `report` line gains `graphs`, `graph_segments`, `ratings`, `replays`,
  `replay_lines`, `replay_regions`, `replay_squares`, `menu_same`, `menu_differs`, `fame_palettes`, `end_unread`;
  timeline.log's steps `report_graph` (O12:0733), `report_rating` (O3:065D), `report_replay` (O9:0113), `report_defer`
  (mode 3), `report_quiet` (mode 4) and `report_end` with O9:0877 for a replay view; ext_adapt's d7m pair (the runs
  `d7m-end-dos`, `d7m-end-win`).
* **FEATURES**: the end of the game with the DOS graphics: the power graph, the replay (the question in the DOS box, the
  map, the event bar, the territories), the rating ladder with its border and portraits, the Hall of Fame entry in the
  game's palette.
* **STATUS / checklist**: D7m done (the user checks D7m-1..7 pending); L26 closed; row 125 (the Save dialog), D7n and
  D7l remain.

## Expected changes at the build slot

Against D7l's cycle (`build/d7l-status.txt`, ALL_GREEN 16:21:12 UTC, RELEASE_OK 16:24:33 UTC; the tree after D7d and
D7l):

* build.cmd: portable sources 302 -> 303 (`pdos_scn_end.c`); one more test program (`test_pdos_end.exe`).
* test.cmd checked: test_pdos_end new, 155 checks; test_dos 23,252 -> 23,253; every other unit count unchanged
  (test_pdos_report 229, test_pdos_space 73, test_pdos_profile 59, test_pdos_shadow 181).  `registry.py check`
  REGISTRY_OK (ok lines 397 -> 402); the golden `tests/dos-decoded.txt` 1,382 -> 1,383 decoded lines (file 1,387 ->
  1,388; `table REPLAY_MENU 77 ...`, staged); obs_lint files 136 -> 138 (probes 203, callsites 101 unchanged);
  obs_tables unchanged (203 / 101); pdos_scene_check 1084 unchanged; ADAPT_OK rows 138 steps 25 unchanged;
  EXT_ADAPT_OK checks 247 -> 253 (the d7m pair: 2 runs, 6 checks); P0_OK checks 476 unchanged; MIRROR_OK runs 29,
  REPLAY_OK 70, ZOOM_OK, EXT_FRAMES_OK, EXT_TIMELINE_OK and the other suites unchanged; NODOS_OK.
* ext_g1: EXT_G1_OK runs 77 unchanged (the Windows profile's frames do not change).
* No golden other than `dos-decoded.txt`; P0 unchanged (ext_p0's retire, conquest and arrival privately P0_OK in V0,
  V1, V2).  Informational only, not predicted to the count: MIRROR_TOTAL's DOS counters (the end screens now draw in
  the DOS view of the retire, conquest and arrival runs) and the coverage line's "other functions entered" (668; the
  new module's functions are portable code, not rt entries).

## Rebase notes

* **Bases:** the tree's files after the D7c, DBL, D7j, D6fS-a, D7d and D7l landings, their hashes recorded at the copy
  or merge (`obj/base-at-copy.txt`) and rechecked equal to the tree (`BASE-SHA256.txt`, its second line gives the
  time; `obj/basesha.py` writes and checks it).  `pdos_scn_report.c/.h` copied 12:23 UTC (unchanged by DBL, D7j,
  D6fS-a, D7d and D7l); `ext_adapt.py` merged three ways on D6fS-a's landing (base `build/d6fsa-prep/tree-before/`, no
  conflict).  build.cmd, test.cmd and `present/dos/pdos_shadow.h` are not D7m's files: the tree's (D7l's
  PDOS_OWNER_MAX 9 included; D7m adds no owner and no PDOS bit).
* **D7d** (RELEASE_OK 15:32:56 UTC; the stage's earlier bases kept in `obj/base-pre-d7d/`): `docs/dos/OFFSETS.md` and
  `tests/harness/ext_adapt.py` merged three ways at 15:33 UTC (`git merge-file -p` to stdout, read only to the
  repository; base: D7m's previous base; theirs: the tree's file after D7d; mine: the staged file; `obj/rebase-d7d/`
  base, theirs, merged, resolved): adjacency conflicts only (OFFSETS.md 1, ext_adapt.py 2), each resolved by keeping
  both sides, D7d's first (`obj/resolve.py`): OFFSETS.md's row table (D7d's CITY_* and IMPR_RECORDS rows, then
  `REPLAY_MENU`), ext_adapt.py's module docstring (D7d's paragraph, then D7m's) and `main()` (`d7d_runs`, then
  `d7m_runs`).  `present/dos/pdos_registry.c/.h` and `tests/dos-decoded.txt` regenerated, not merged, with the tree's
  `gen/dos/registry.py` (`gen`, then `goldens --dosdata build/dosdata`) on the merged OFFSETS.md (`obj/regen-d7d.txt`);
  the diff to the tree's files is `REPLAY_MENU`'s alone.  The tree's hashes after D7d in
  `obj/rebase-d7d/tree-after-d7d.sha256`.
* **D7l** (RELEASE_OK 16:24:33 UTC; earlier bases in `obj/base-pre-d7l/`): the same at 16:25 UTC (`obj/rebase-d7l/`):
  OFFSETS.md 2 and ext_adapt.py 2 adjacency conflicts, D7l's first: OFFSETS.md's row table (D7d's rows, D7l's
  SPACE_PARTS and SPACE_LAUNCH, then `REPLAY_MENU`) and its notes (D7l's SPACE_PARTS note, then `REPLAY_MENU`'s),
  ext_adapt.py's docstring (D7d's, D7l's, then D7m's paragraph) and `main()` (`d7d_runs`, `d7l_runs`, `d7m_runs`); the
  registry files and goldens regenerated again (`obj/regen-d7l.txt`).  The save names differ (D7j `PALACE.SAV`, D7l
  `SHIP.SAV`, D7m `ENDGAME.SAV`).  The tree's hashes after D7l in `obj/rebase-d7l/tree-after-d7l.sha256` (= the bases
  of `BASE-SHA256.txt`).
* **Another landing** that changes `pdos_scn_report.c/.h`: merge three ways; D7m's parts are the delimited `extension
  D7m` blocks after D7c's and one-line hunks with an `extension D7m` comment.  OFFSETS.md, ext_adapt.py and the
  generated files as above.
* **After the copy-in:** the base check, then build.cmd checked, test.cmd checked and ext_g1, guarded by each log's OK
  marker; the release build; the user build as the earlier D7 units'.

## Landing

D7m landed alone at the build slot of session E4 (track A), 2026-10-17, after D7l's landing (its RELEASE_OK 16:24:33
UTC and `build/user-builds/d7l/`), which followed D7d's (RELEASE_OK 15:32:56 UTC), as the orchestrator ordered.  The
user checks D7m-1..D7m-7 are in the user build `d7m`.

* **Bases:** rebased onto the tree after D7d's landing (15:33 UTC) and again after D7l's (16:25 UTC) (Rebase notes:
  `docs/dos/OFFSETS.md` and `tests/harness/ext_adapt.py` merged three ways, adjacency conflicts only (1 + 2 on D7d, 2 +
  2 on D7l) resolved by keeping both sides, theirs first; `present/dos/pdos_registry.c/.h` and `tests/dos-decoded.txt`
  regenerated by the tree's `gen/dos/registry.py`; `present/dos/pdos_shadow.h` (D7l's PDOS_OWNER_MAX 9) taken as the
  tree has it, D7m adding no owner and no PDOS bit); the overlay built and checked again (portable sources 303, the 20
  pairs, REGISTRY_OK 402, "Results"); `BASE-SHA256.txt` written by `obj/basesha.py` (BASESHA OK) and rechecked by
  `build/d7m-prep/land.py` (every base equal, the four new files absent, build.cmd and test.cmd unchanged, the other
  read-only references printed; DRY_RUN_OK 11).  Scripts in `build/d7m-prep/` (`mk_prep.py`: `land.py`,
  `d7m-cycle.ps1`, `compare.py` and `mk_userbuild.py` from `build/d7c-prep/`; `fill_stillopen.py` from
  `build/d7l-prep/` with a new group "d7l").  Snapshot `build/d7m-prep/before` (the tree's `build/test/Checked` outputs
  of D7l's cycle, 65 files) and `tree-before` (the seven replaced files); copy-in at 16:34:07 UTC (`landed.sha256`: the
  eleven files, build.cmd and test.cmd unchanged; `landed-at.txt` "unit d7m").  Predictions
  `build/d7m-prep/predictions.txt`, written before the copy-in.
* **The three-step cycle** (`build/d7m-status.txt`, each step guarded by its log's OK marker): 1 `build.cmd checked`
  BUILD_OK 16:34:15..16:37:51 (216 s; portable sources checked 303); 2 `test.cmd checked` TESTS_OK 16:37:51..17:05:20
  (1650 s; TEST_SECTIONS 30 failed 0; no flake rerun); 3 `ext_g1.py check` EXT_G1_OK runs 77 (amended 1) unchanged:
  **ALL_GREEN** (17:05:21 UTC).  4 `build.cmd` (Release) BUILD_OK 17:05:29..17:08:34 (184 s; portable sources 303):
  **RELEASE_OK**.
* **Against the predictions** (`build/d7m-prep/compare.py` against the snapshot; `compare.txt`: 52 of 65 files equal,
  host times left out): as predicted, unit.log test_pdos_end new 155, test_dos 23252 -> 23253 ("decoded content" 1382
  -> 1383 lines; registry 63 -> 64 tables), every other count equal; registry-check REGISTRY_OK with 5 more `ok` lines
  (REPLAY_MENU's three, the include rule of `pdos_scn_end.c/.h`; 397 -> 402) and the goldens line 1382 -> 1383;
  dos-decoded.txt the one `table REPLAY_MENU 77 ...` line; OBS_LINT_OK files 136 -> 138, probes 203, call sites 101;
  adapters-check ADAPT_OK rows 138 steps 25, obs-tables and pdos-scene-check (1084) unchanged; EXT_ADAPT_OK checks
  247 -> 253 (the six d7m-end lines equal to the private run: the decisions, the pair equal with coreinput 43 and
  frames 690, REPLAY.REP 4847 bytes in both forms, the report rows 122, 103, 103, 75, 120 with report_graph [42],
  report_replay [589, 589], one report_defer and report_rating [19], the N frame shows [1, 10, 3, 2, 1], the `report`
  line), the d7a, d7b and d7c `report` lines gaining the D7m counters at 0; EXT_TIMELINE_OK, P0_OK checks 476,
  MIRROR_OK runs 29, REPLAY_OK checks 70, ZOOM_OK, NODOS_OK (0 hits) and every other harness section as before.  Not
  predicted in detail, explained (each "may change" in the predictions): (a) ext-p0's V4d zoom lines of retire (36 ->
  30), conquest (103 -> 85) and arrival (236 -> 230) shows with the layer: the end screens now show the N frame instead
  of the zoomed A frame; (b) ext-replay's informational V1 lines of arrival, conquest and retire (brackets, device,
  draws, muted, no_shadow, no_scene): the end screens' primitives are now drawn or dropped by the report renderer; (c)
  coverage.txt "other functions entered" 668 -> 666 (informational); (d) nodos files 1790 -> 1795, 0 hits; (e)
  unit.log's OBS_COST line (host timing).
* **User build** `build/user-builds/d7m/`: `civ64.exe` (the Release build, SHA-256 92b5bd86...), `CIVWIN.zip` and
  `civdos.zip` from `build/user-builds/d4/`, `ENDGAME.SAV` (the d7m pair's edited save from `build/adapt/`, test input),
  `WHAT-TO-CHECK.txt` (D7m-1..D7m-7, the earlier builds up to "d7l", and the 100 items still pending in the checklist
  at 17:08 UTC, D7l's three among them).
* Not done at this slot: the checklist sections and STATUS rows (the orchestrator's) and the docs pass for D7m
  ("For the records", docs-e4d after this RELEASE_OK); the tree's CheckedNoObs build is not part of the three-step
  cycle (the private overlay builds and units of the three variants are in "Results", before the slot; at the slot the
  Checked variant).

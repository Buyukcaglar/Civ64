# Extension phase D7, unit D7n (the conqueror ending and the nuclear explosion) - record

Draft for the build slot (docs/verify/BRIEF-d7.md unit D7n: rows 114 and 110; T6, P12, P37 with OPEN P27, E17, E23;
P8, T16, E16; decisions 3, 11 and 16; OPEN L1's mouth rectangles; extension session E4, track A).  Staged in
`build/d7n-stage/` on the tree after D7f's landing (copy-in 02:30:03 UTC, ALL_GREEN 03:10:38 UTC, RELEASE_OK 03:15:33
UTC, 2026-10-18): the bases of `pdos_scn_end.c/.h`, `pdos_scn_report.c/.h`, `pdos_aplay.c/.h` and
`tests/test_pdos_end.c` copied at 02:34:18 UTC (`obj/base-at-copy-raw.txt`), the others as each first edit began
(`obj/base-added.txt`); rebased onto D6fSd's landing (copy-in 04:28:49 UTC: `tests/harness/ext_adapt.py` and
`tests/headless/harness.c` merged three ways); every base is the tree's file now, rechecked in `BASE-SHA256.txt`
(section "Rebase notes").
Private builds and runs in `build/d7n-stage/obj/` only: an overlay `obj/src` = the tree + the stage (`obj/mkoverlay.py`;
`obj/sync.py` lays later stage edits over it; `obj/ovcheck.py` compares it with the tree and the stage), built with the
tree's build.cmd and flags (`obj/b.cmd`, `obj/ball.py`, `--nogen`), cc.cmd's stricter checks per file (`obj/cc.cmd`,
`obj/ccall.py`), the unit programs and the harness runs from the overlay's binaries with every output under `obj/`; the
tree's build/gamedata, dosdata, dos/disasm and cache read only.

## Result

D7n is staged and privately verified.  With the DOS graphics the conqueror ending (row 114) is DOS's O9:0DDE: a black
320 x 200 screen on which, for each civilization the human destroyed (the core's ShowConqueredCivLeader 1180:17E9 from
PlayReplay's quiet mode 4), DOS's conquered leader O9:0F79 runs: the fade to black (O9:1079, 5 steps, 30 frames),
`SLAM1.PIC` with the trophy strip of `SLAM2.PIC` and the trophies taken so far, the leader's head and upper mouth from
`KING<p>.PIC`, the fade-in to `SLAM1.PAL` with KING's colours 64..143 (O9:124C, 8 steps, 48 frames), the new trophy at
DOS's centre-out place, then at the core's pace the two lines in font 6, the lower mouth and the dissolve
`G#10`(1, 1Eh) (219 frames); at the end DOS's panel (18, 150, 284, 32) in 22h with "The entire world hails ... the
CONQUEROR!" in its two colours, and the return fade (R:0238:1B44) when the window goes.  The nuclear explosion (row 110)
is DOS's `NUKE1.PIC` animation as an A element over the map: the core's frames, pace and place (decision 11), each frame
DOS's 44 x 44 cell at 2x with colour 0 transparent (the core's 88 x 88 square exactly), `NUKE1.PIC`'s palette from the
first frame, the play palette back with R:0238:1BEB's fade-in at the end.  OPEN L1's conqueror mouth rectangles are read
(O9:0F79: (1, 51, 59, 49) and (1, 151, 59, 49), at the place O9:1171..11A2 computes from D7k's `LEADER_FACE_X` / `_Y`
through the far words [DGROUP:642E] / [6430], the same segment as [640A]; OFFSETS.md lists the O9 readers).  No core
change, no core random draw, no new owner (the existing owners "report" and "aplay"; 9 of PDOS_OWNER_MAX 10 stay used),
no new PDOS_AS bit (PDOS_AS stays full; none needed: the ending's wait is the report state's I-report, the explosion has
no input), no adapter or scene-table row (rows 110 and 114 exist with their keys).

## Status

LANDED (2026-10-18: copy-in 05:35:13 UTC, ALL_GREEN 06:20:13 UTC, RELEASE_OK 06:28:33 UTC, user build
`build/user-builds/d7n/`; section "Landing"); the user checks D7n-1..D7n-4 are pending.  Staged, rebased onto D6fSd's
landing and the docs pass e4h; the private builds, units and runs in section "Results".
Built: row 114 (O9:0DDE, O9:0F79) in the
report renderer's table (`present/dos/pdos_scn_report.c`, its timeline g_tc for the leader's TX effects) with the DOS
drawing in `present/dos/pdos_scn_end.c/.h`; row 110 (O22:0967) in D6e's class-A module (`present/dos/pdos_aplay.c/.h`);
the counters, timeline steps and a test harness line (`tests/headless/harness.c`: the `aplay` diag line); OFFSETS.md
readers; DOS-PROFILE rows 106, 110, 114 and P8, P12, P37, T6, T16, E16, E17, E23 "as implemented in D7n".  Two test
scenarios as save edits (`saveedit.py`): CONQUEST.SAV (D7m's conquest route with the human as the destroyer of the two
replay-log conquests) and NUKE.SAV (a Nuclear unit beside a rival's city).  Not in the unit: D7o (the sweep and the
gate); the Windows-profile mirror counts of row 110 (Open D5, below).

## What was built

### The core's conqueror ending and DOS's (the core's reconstruction; DOS listing)

The core (claude/src seg 1180): ShowConquerorEnding 1180:152F (called at 1088:09F9, before RunEndGameSequence
1088:0B01) opens dialog 148 on g_replayWindow (GR_DialogOpen 1180:1546), fills (0, 0, 320, 200) with 0, reads picture
5591 into g_conquestBackgroundPort with its palette 48h..97h (E23), empties the 14 g_conquestTrophySlots, sets
g_replayMode 4 and runs PlayReplay 1180:16A3 quietly; PlayReplay calls ShowConqueredCivLeader(victim, year)
(1180:0D4F) for every replay event "civilization destroyed" whose destroyer is the human.  ShowConqueredCivLeader reads
the leader's picture (ExtractScaledTile (181, 67, 139, 133): DOS's head rectangle), its mouths and the trophy gallery,
draws the year and the two lines at (160, 151) and (160, 167) in 17h, copies its caption strip (CopyPortToWindow
1180:1EB6) and later its whole background (1180:1FA0), with DelayTimerTicks 14h, 3Ch, 0Ah, 3Ch, 0Ah between.  After
PlayReplay the core draws "The entire world hails" and the leader's name + " the CONQUEROR!" (DSTR 39AE, 39C5) on the
background, copies the bottom strip (1180:175F), plays the theme and waits (WaitForKeyOrClick 1180:17B0).

DOS (ovl09.lst): O9:0DDE forces replay mode 4 ([680E] = 1), empties the trophies (DGROUP:B1D4 = 0, the 14 bytes
es:[642C]:37C4 = FFh, O9:0DF4..0E12), fills the screen 0, sets the screen port's font word 6, runs the replay O9:0000
(mode 4: nothing drawn, O9:0111) which calls O9:0F79(victim, year) for each "destroyed by" event of the human
(O9:07D6..07ED), then draws the panel (18, 150, 284, 32) in 22h and the two lines centred at x 160, each first at
y + 1 in 14h, then at y in 17h (y 151 and 167; O9:0E5B..0F32), waits (R:1459:0918) and returns through R:0238:1B44
(O9:0F6A).  O9:0F79: the KING picture `KING<p>.PIC` (p = LEADER_PORTRAIT of the victim's tribe, O9:0F85..0F93) into page
1, the cuts head (181, 67, 139, 133), mouth 1 (1, 51, 59, 49) and mouth 2 (1, 151, 59, 49); `SLAM1.PIC` into page 1; the
fade to black R:0000:04D4(5) (O9:1079); page 1 to the screen; `SLAM2.PIC` (197 x 67) into page 1 at (0, 133); each
trophy of portrait k from page 1's cell (28 (k mod 7) + 1, 34 (k div 7) + 133, 27, 33) to the screen at place i
(46 (i mod 7) + 8, 49 - 42 (i div 7)); the head at (90, 0) and mouth 1 at (x, y - 2) with x = 5Ah + (X[2p] - B4h) -
X[2p + 1], y = (Y[2p] - 40h) - Y[2p + 1] (O9:1161..11A2: the words of LEADER_FACE_X / _Y, reached through
[DGROUP:642E] / [6430]); `SLAM1.PAL` with `KING<p>.PAL`'s 64..143 spliced in (O9:11F8..1242) and faded in
R:0000:04AA(8) (O9:124C); the trophy's place from the count n: n mod 7 odd -> 6 - (n mod 7 - 1) / 2, even -> (n mod
7) / 2, + 7 from the eighth (O9:1254..1299; signed byte, IDIV); page 1 rebuilt with every trophy (O9:12A3..134C); the
240-frame wait (O9:135A..1367); the two lines (the year, B.C./A.D., the human's civilization's name, " destroy", the
victim's civilization; DGROUP:413E..4157) at (160, 152)/(160, 151) and (160, 168)/(160, 167); the screen's strip (0,
133, 320, 67) into page 1, mouth 2 at (x, y - 2); wait(3Ch) (O9:14E9); `G#10` DissolveToScreen(1, 1Eh) from page 1;
page 1 shown (O9:1520..1543).

### The renderer (row 114: `pdos_scn_report.c`, `pdos_scn_end.c/.h`)

ShowConquerorEnding joins the report renderer's table (background 0, the end R:0238:1B44).  Its N view begins at its
dialog 148's GR_DialogOpen (1180:1546) as D7m's rating: page 0 filled 0 in the play palette (a running return fade
completed first, C.9), the rows ready; the trophies emptied (O9:0DF4..0E12); every event and replayed primitive on the
replay window and its port is dropped, and the bitmaps the scene makes while it shows (the background, the leader's
ports and tiles) are declined (no shadow).  Each ShowConqueredCivLeader entry starts O9:0F79 on the timeline g_tc
(`pdos_tl.h`, sequence PDOS_SEQ_FX_FADE; `conq_prog`): DOS's fades and dissolve are TX (DOS's frames from the leader's
start), its two waits are the core's (TC): the core's caption strip (1180:1EB6) releases the lines, the strip to page 1
and the lower mouth (in place of O9:135F's 240 frames; if it comes before the fade-in has ended, the lines wait for the
fade-in), the core's whole background (1180:1FA0) the dissolve (in place of O9:14E9's 60 frames).  A leader's entry or
the final strip completes a tail still running (`pdos_tl_finish`).  The leader's portrait p is DOS's
LEADER_PORTRAIT[g_playerCivId[victim]] (D7k's registry table), compared with the core's g_tribePortraitIndices
(`conq_portrait_differs`); the KING files by `pdos_leader_king_files` (D7k); SLAM1, SLAM2, SLAM1.PAL and KING from the
store (`conq_pic_missing` when one is absent or of another size: the leader is not drawn).  The lines are the core's
texts (the same words as DOS's strings, and the same loss of "the " by the strcpy, O9:141F..1441 / the core's
1180:1E3E..1E59), folded to DOS bytes, in font 6.  The final caption strip (1180:175F) draws O9:0E5B..0F32's panel and
lines and compares the trophies with the core's g_conquestTrophyCount and the places it took (`conq_trophy_differs`);
the view ends at the window's destruction with R:0238:1B44.  OPEN P27: SLAM2's rows are drawn 197 pixels wide (draft B
4.2 and 18: `width` pixels, the 198th byte of DOS's row copy is stale memory); they never show, since page 1's rows
133..199 are the screen's strip again before the dissolve shows page 1.

`pdos_scn_end.c/.h` (pure, the extension D7n block): `pdos_conq_reset`, `pdos_conq_add` (the place rule),
`pdos_conq_cell`, `pdos_conq_place`, `pdos_conq_pics_ok`, `pdos_conq_slam1`, `pdos_conq_show` (page 1 to page 0, SLAM2
at (0, 133), the trophies, the head and mouth 1 with colour 0 transparent), `pdos_conq_palette` (`pdos_recipe_king` on
SLAM1.PAL), `pdos_conq_rebuild`, `pdos_conq_lines`, `pdos_conq_strip`, `pdos_conq_page1_shown`, `pdos_conq_final`.

### The nuclear explosion (row 110: `pdos_aplay.c/.h`)

DOS O22:0967 (ovl22.lst): `NUKE1.PIC` into page 1 with its palette (R:1FA1:0220), 28 cells 44 x 44 at (45 (i mod 7) + 1,
45 (i div 7) + 1), the position clamped from the square (x 50h..114h, y 8..9Ch), sound 2Ah, 35 steps (cells 0..27, then
21..27), each drawn transparent (G#6) for 5 frames (wait(5), O22:0A92) with the rectangle restored after it; then
R:0238:1BEB (O22:0AEB).  The core (AnimateNuclearExplosion 11B8:0C3D): picture 144 (90h) with its palette 48h..97h on
the map window (11B8:0C8B), sound 2Ah, 28 tiles 88 x 88 (2 x 44), a 0AAh-tick wait, then frame n = 0 .. 8Bh - 1 (with
g_gameOptions & 10h, else 3Fh - 1; 11B8:0DE8): cell n below 28, else 21 + n mod 7 (11B8:0E50..0E6F, DOS's sequence for n
< 35), DrawTile into the scratch bitmap (11B8:0E73) and CopyPortToWindow to the map window at WrapMapX(x -
g_mapViewLeft) * 32 - g_mapScrollX - 28, (y - g_mapViewTop) * 32 - g_mapScrollY - 28 (11B8:0E91), 5 ticks each.

Decision 11: the core's frames, pace and position (TC).  Two shadow macros (DOS_ONLY, PDOS_MAC_DROP, keyed on
AnimateNuclearExplosion) drop the core's tiles into the scratch bitmap (g_offscreenPort's bitmap, DGROUP:44BE) and its
copies to the map window while the scene runs; the module follows the core's DrawTile (frame n -> cell n below 28, else
21 + n mod 7) and, at the frame's CopyPortToWindow, cuts DOS's cell from `NUKE1.PIC` into a 44 x 44 surface and sets it
as the A element 0xFF30 (`PDOS_APLAY_NUKE_ID`, a private id outside 2000h..2FFEh) on top of the map element at the
copy's destination rectangle in the map window's client, at 2x, colour 0 transparent (the element's new `opaque` 0),
clipped as the map window.  NUKE1's palette (G#28 on the A canvas's play palette, `pdos_dac_load_m0`) comes with the
first frame shown: DOS loads it just before its first frame, while the core's 0AAh-tick wait lies between its own palette
(11B8:0C8B) and its first frame.  At AnimateNuclearExplosion's exit the element goes and R:0238:1BEB returns: D6e's
`palette_back` with the fade-in from the scene's DAC (decision 3, ruling 3: `pdos_fx_return`, PDOS_EXIT_1BEB, 30
frames).  A nested entry ends the open one; with the map window hidden, iconic or unreadable the element is removed.
The zoom (D6c) needs nothing of its own: the element is placed in device pixels from the core's rectangle, which is in
the core's 32-pixel squares like the map element beneath it.

### Registry (OFFSETS.md; DOS listing, DOS file)

`LEADER_FACE_X` and `LEADER_FACE_Y` (D7k's rows) gain the readers O9:117B, O9:1186 and O9:1192, O9:119D, the
references SCENES-PLAY 7.17 and the unit D7n; a note: O9:1171..11A2 read the words through the far words
[DGROUP:642E] (X) and [DGROUP:6430] (Y) instead of [640A]; the three words are relocation entries holding the same
segment in the load module (26FAh; checked with `registry.Image` on the unpacked CIV.EXE: no writer in the listings, as
OPEN L1's [640A]), so the rows keep their single location.  `pdos_registry.c` regenerated by the tree's `gen/dos/
registry.py gen` (the reader strings only; `pdos_registry.h` and `tests/dos-decoded.txt` regenerate equal to the
tree's and are not staged).

### Counters and steps

presentation-diag.log's `report` line gains `conquests`, `conq_leaders`, `conq_trophies`, `conq_texts`,
`conq_dissolves`, `conq_finals`, `conq_portrait_differs`, `conq_trophy_differs`, `conq_pic_missing`, `conq_unread`; a
new `aplay` line (`pdos_aplay_diag_line`, written by the harness after the `rdlg` line): D6e's counters (sm_draws ..
elem_sets ..) and `nukes`, `nuke_frames`, `nuke_palettes`, `nuke_returns`, `nuke_pic_missing`, `nuke_unread`.
timeline.log gains the steps `conq_leader` (O9:0F79, arg p), `fade` O9:1079 (5) and O9:124C (8), `conq_head` (O9:11B3,
the trophies shown), `conq_trophy` (O9:1299, its place), `conq_text` (O9:13F3), `conq_dissolve` (O9:1518, 1Eh) and
`conq_shown` (O9:1538) on the leader's timeline (sequence 3), `conq_final` (O9:0E5B, the trophies) a probe step; row
110's return is D6e's `return` R:0238:1BEB (arg 2) with its `return_fade_end`.

## Files

Changed (`BASE-SHA256.txt`): `present/dos/pdos_scn_report.c/.h` (row 114, its timeline, the counters),
`present/dos/pdos_scn_end.c/.h` (the D7n block), `present/dos/pdos_aplay.c/.h` (row 110's element, the `aplay` diag
line), `present/dos/pdos_profile.c` (one line: `pdos_report_advance(now_us)` at every presentation tick, so the
leader's timeline runs while nothing else draws), `present/dos/pdos_registry.c` (generated), `docs/dos/OFFSETS.md`,
`docs/DOS-PROFILE.md` (the rows' prose), `tests/test_pdos_end.c`, `tests/test_pdos_play.c`, `tests/headless/harness.c`
(one line, CRLF kept), `tests/harness/ext_adapt.py` (the d7n runs; three hunks of the d7m pair, section "Tests"),
`tests/harness/ext_timeline.py` (the conquest run).
New: this record.  Unchanged, though the brief lists them: `present/dos/pdos_fx.c` (the TX fades and the dissolve are
`pdos_tl`'s; `pdos_fx_return` and PDOS_EXIT_1BEB exist since D6e/D7a), `present/dos/pdos_prov.c` (no provenance rule:
row 114's bitmaps are declined, row 110's tiles dropped by the shadow macros; P8 and the KING pictures never
substituted), `present/dos/pdos_scene_tab.c` (rows 110 and 114 exist: 110 PDOS_A on AnimateNuclearExplosion, 114
PDOS_N on ShowConquerorEnding with PDOS_TL_TC|PDOS_TL_TX).  `pdos_adapt_tab.c`, `pdos_shadow.h` (PDOS_OWNER_MAX 10, 9
used), build.cmd and test.cmd unchanged (build.cmd compiles `present\dos\*.c`; no new source file: portable sources
308).  The D7n parts of the shared files are delimited `extension D7n` blocks or one-line hunks with an `extension
D7n` comment.  No BUILD-TEST-ADDITIONS.md.

**DOS-PROFILE's prose names no new call address of a probe key.**  `gen/obs_tables.py` takes every address in
DOS-PROFILE.md that is a call to a probe key as a call-site row of `present/obs_tables.c` (OBS_NCALLSITES).  A first
draft of the rows' prose named eight such calls (the core's 1088:09F9, 1088:0B01, 1180:1546, 1180:175F, 1180:1EB6,
1180:1FA0, 11B8:0E73 and 11B8:0E91): `obs_tables.py --check` then failed (101 -> 109 sites).  The staged prose names
those copies and calls without their addresses (they are in this record only), and `obs_tables.py --check` passes
(203 probes, 101 sites) with `obs_tables.c/.h` unchanged.  The docs pass should keep these addresses out of
DOS-PROFILE.md (and out of WINDOWS-INVENTORY.md's sections 9.5 and 10) too.

## Tests

* **`tests/test_pdos_end.c`** (155 -> 193 checks in every variant; synthetic memory, font, pictures and texts, no DOS
  byte): the trophies' places (centre out from both ends, the second row from the eighth, the signed byte count), the
  cells and places; the drawing of one leader (SLAM1, the SLAM2 strip 197 wide, the trophies, the head with colour 0
  transparent, the mouths at the face place, the palette splice, page 1 rebuilt, the lines in font 6 with their 14h row
  below, the strip to page 1, the final panel); through the module (synthetic ObsEvent / ObsProbe streams): the view at
  its GR_DialogOpen, the window's events dropped and the scene's bitmaps declined, a leader's fades and dissolve on the
  timeline (TX) with the lines and the dissolve released by the core's copies (TC; the lines wait for the fade-in when
  the core's caption comes first), a leader's entry completing the last one's tail, the second leader, the final panel,
  the trophies compared with the core's, the end with R:0238:1B44, no leader (black, the play palette), the diag line.
  Two D7m checks adjusted (a probe rectangle moved off trophy place 6; the dissolve's 219 frames, 3.13 s, need a 4 s
  advance).  On the base it does not build (`pdos_conq_*` absent).
* **`tests/test_pdos_play.c`** (78 -> 89 checks): row 110 through the shadow engine and the module: the drop macros
  active while the scene runs (scratch bitmap and map window), other call sites ignored, frame 0 cell 0 with the
  palette once, frames 1..27 cells 1..27, frames 28..34 cells 21..27 again, the core's 63 frames, the element at the
  copy's rectangle at 2x with colour 0 transparent over the map element on the A frame, clipping at the map's edge, the
  exit (the element gone, the return R:0238:1BEB from the scene's DAC to the play palette in 30 frames).
* **`tests/harness/ext_adapt.py`, the d7n runs** (4 runs, 13 checks; `d7n_runs` after `d7f_runs`):
  * the conquest pair: CONQUEST.SAV = CAE3540B.SAV with `aliveCivsMask` 3 (D7m's edit) and the replay log's two
    type-0Dh events given the human as the destroyer (bytes 8B75h, 8B8Bh = 1) and the second the victim 3 (8B8Ah),
    61,500 ms: D7m's keys to the palace's end, the profile chord at 39.5 s, Space at 41.5 s (the ending opens) and at
    60 s (its wait); the Windows form the same without the chord.  Asserted: I-report/key decides the ending's key, no
    click, nothing refused; the pair equal; timeline.log's `report` O9:0DDE (114) after the chord, `conq_leader`
    portraits 13 and 11 (O9:0F79), the fades O9:1079 (5) and O9:124C (8) twice, `conq_head` 30 frames and
    `conq_trophy` 78 frames after each leader's start, places 0 and 6, two `conq_text`, two `conq_dissolve` (1Eh),
    two `conq_shown`, `conq_final` 2 after the last, `report_end` exit kind 1 at the last Space, the return
    R:0238:1B44; each dissolve shown whole 219 frames after its start; the 320 x 200 N frame meanwhile; the `report`
    line's D7n counters (conquests 1, conq_leaders 2, conq_trophies 2, conq_texts 2, conq_dissolves 2, conq_finals 1,
    the differs, missing and unread 0); no row 114 counter in `pdos_rows`.
  * the nuclear pair: NUKE.SAV = CAE3540B.SAV with the human's unit 0 a Nuclear (type 25) at (61, 12), status 0, 48
    move thirds, beside Zimbabwe's city at (60, 12); `--graphics dos` from the start (D_LOAD) against `--graphics
    windows` (D_LOAD_W), the keypad's 4 at 27.5 s (the attack), Return at 44 s (the message after it), 45,500 ms.
    Asserted: the actions decided, no click, nothing refused; the pair equal; the `aplay` line nukes 1, nuke_frames 139
    (the core's 8Bh frames), nuke_palettes 1, nuke_returns 1, missing and unread 0; the return R:0238:1BEB (2) after the
    attack and its fade's end 30 frames later; no row 110 counter in `pdos_rows` and the `pdos` line's unexplained 0;
    the A frame shown during the explosion.
  On the base the D7n steps and counters do not exist: the timeline and diag checks fail.
* **`tests/harness/ext_adapt.py`, the d7m pair adjusted** (three one-line hunks marked `extension D7n`): its conquest
  route (D7m's ENDGAME.SAV, no conquest of the human's in the replay log) now opens row 114 before the power graph
  (before the chord, in the Windows profile: the DOS renderer follows the core behind it, as D7m's own graph): the
  `report` rows are 114, 122, 103, 103, 75, 120 with six `report_end`, and the N frame is asserted from the third view
  (the first two before the chord, as before for the graph).  On the tree without D7n's renderer those two checks
  would fail (no row 114 view); with it, without the adjustment, they fail (the first run of the private d7m pair,
  section "Results").
* **`tests/harness/ext_timeline.py`, the conquest run** (1 run, 7 checks; `conquest_prepare`, `check_conquest`): the
  same save and keys as the d7n conquest pair (with `--core-input-log 1`): the ending's open (O9:0DDE, row 114) after the
  chord; each leader on its own grid from `conq_leader` (frame 0): the fade to black (O9:1079, 5) at frame 0,
  `conq_head` at frame 30 and the fade-in (O9:124C, 8) there, `conq_trophy` at frame 78 at its instant
  t0 + pdos_frame_us(78), places 0 and 6, the dissolve shown whole at frame F + 219 at its instant; `conq_final` 2
  after the leaders, the end (exit kind 1) after 60 s; the 320 x 200 N frame from the open to the end.
* `ext_p0.py`, `ext_mirror.py`, `ext_replay.py`, `ext_frames.py`: unchanged.  ext_p0's and ext_mirror's `conquest` run
  pass through row 114 (section "Results").

## Results (private, `build/d7n-stage/obj/`)

Session E4 (2026-10-18).  First on the overlay `obj/src` = the tree after D7f + the stage (04:12..04:30 UTC), then,
after the rebase, on the tree after D6fSd (and its cycle, kept off its test step) and the docs pass e4h + the stage
(05:11..05:34 UTC); the bases of `BASE-SHA256.txt` rechecked (BASESHA OK).

* **Builds** (`obj/ball.py`, the tree's build.cmd and flags with `--nogen`): on the tree after D7f Checked,
  CheckedNoObs and Release BUILD_OK, portable sources 308 (325, 296 and 275 s, 04:12:20..04:27:16 UTC); after the
  D6fSd rebase Checked again BUILD_OK, portable sources 308 (335 s, 05:11:51..05:17:26 UTC, after D6fSd's RELEASE_OK).
* **cc.cmd** (`obj/ccall.py`: c11 and c17 /W4 /WX and the clang C99 parse, every variant) on `pdos_scn_end.c`,
  `pdos_scn_report.c`, `pdos_aplay.c`, `pdos_profile.c`, `pdos_registry.c`, `test_pdos_end.c`, `test_pdos_play.c` and
  `tests/headless/harness.c`: CCALL failed 0 (24 CC_OK).
* **Unit** (`obj/unit.py`, the tree's build/gamedata read only): all 64 programs (test_ne aside) pass in Checked,
  CheckedNoObs and Release (before the rebase) and in Checked after it; test_pdos_end 193 and test_pdos_play 89 in each
  variant; against D7f's and D6fSd's cycle logs (`obj/cmpunit.py`) every other Checked count is equal (test_dos 23,281,
  test_pdos_report 229, test_pdos_reskin 209, test_pdos_leader 119).
* **Checks** on the overlay (after the rebases): `registry.py check` (`--dosdata`, `--disasm` of the tree's build, read
  only) REGISTRY_OK, 0 failures, 533 `ok` lines (the tree's 529 and the four O9 readers); `registry.py gen` in the
  overlay reproduces the staged `pdos_registry.c` and the tree's `.h` byte for byte; `obs_lint.py` OBS_LINT_OK files 148
  probes 203 callsites 101; `obs_tables.py --check` (`obj/obstab.py`, the real claude/src/asm listing) OBS_TABLES_OK
  probes 203 sites 101 (section "Files" for the call-address rule); `pdos_scene_check.py` PASS 1084 checks, 141 scene
  rows, 10 font rows; `adapters.py check` ADAPT_OK rows 153 steps 27; `nodos.py check --root obj/src` (the overlay's
  binaries; the tree's build/dosdata and build/gamedata read) NODOS_OK, 1,203 files, 0 hits.
* **ext_adapt, the whole suite** (`obj/runadapt.py ... all`: the staged ext_adapt.py's main with the private Checked
  harness, after the D6fSd rebase, 05:19..05:34 UTC): EXT_ADAPT_OK checks 342 (D6fSd's cycle 329 + the 13 d7n checks;
  the check names otherwise the tree's).  The d7n lines: d7n-conq decided by I-pass/key and I-report/key, the pair
  equal (coreinput 24, frames 684; exit 0, 0); `report` O9:0DDE at 41,501,750 us (after the chord at 39.5 s),
  `conq_leader` portraits 13 (41,503,750 us) and 11 (50,256,750 us), the fades O9:1079 (5) and O9:124C (8) twice,
  `conq_trophy` places 0 and 6, `conq_dissolve` at 46,412,750 and 55,200,750 us, `conq_shown` 3,123,733 and 3,117,269
  us later (219 frames from the frame of the core's whole background), `conq_final` 2 at 59,045,750 us, `report_end`
  exit kind 1 at 60,001,750 us, the return R:0238:1B44; 501 shows of the 320 x 200 N frame; the `report` line conquests
  1, conq_leaders 2, conq_trophies 2, conq_texts 2, conq_dissolves 2, conq_finals 1, the differs, missing and unread 0;
  `pdos_rows` only r101.unexplained 2 (the newspaper; D7m's run has it too).  d7n-nuke decided by I-intro/key,
  I-title/hotkey, I-title/return, I-play/key and I-menu/return-escape, the pair equal (coreinput 8, frames 681); the
  `aplay` line nukes 1, nuke_frames 139, nuke_palettes 1, nuke_returns 1, missing and unread 0; the return R:0238:1BEB
  (2) at 43,006,650 us and its fade's end 30 frames later (43,434,682 us); no `pdos_rows` counter, `pdos` unexplained
  0; 160 A-frame shows during the explosion.  The d7m pair with the adjustment: `report` rows 114, 122, 103, 103, 75,
  120, six `report_end` (two O9:0877), the N frame shows per view [0, 1, 10, 3, 2, 1], the `report` line conquests 1,
  conq_leaders 0, conq_finals 1 (the ending without a leader of the human's).  Before the adjustment (the first run of
  the sets d7n, d7m, on the tree after D7f) the d7m pair's report-row and N-frame checks failed exactly as described in
  section "Tests"; the d7n runs passed there too (13 of 13).
* **ext_timeline, the base group** (the staged ext_timeline.py with the private Checked harness, `--root obj/tlroot`,
  the tree's build read only): EXT_TIMELINE_OK, 60 PASS lines (the tree's 53, the conquest run's 7), before and after
  the D6fSd rebase.  The conquest: the open at 41,501,750 us; leader 0 (portrait 13): the head at frame 30 (41,931,782
  us), the trophy at frame 78 (place 0), the dissolve from frame 344 shown whole at frame 563 (49,536,483 us); leader 1
  (portrait 11): frame 30 at 50,684,782 us, place 6, the dissolve from frame 346 to 565 (58,318,019 us); conq_final 2 at
  59,045,750 us; the end (exit kind 1) at 60,001,750 us; 501 N-frame shows.
* **ext_p0** (the tree's runner, `--exe` the private Checked harness, `--root obj/p0root`, `--only
  retire,conquest,arrival`, V0, V1, V2, after the rebase): P0_OK checks 21 (V0 equals its baseline; V1 and V2 equal V0;
  no count on a D4, D5 or D6 row).  V1's conquest `pdos_rows`: r101.unexplained 2 only (r114 2 gone: the ending is
  drawn); its `report` line opens 6, ends 6, conquests 1; its `aplay` line nukes 0.
* **ext_mirror** (the tree's runner, the private harness, `--only retire,conquest,arrival`): MIRROR_OK runs 3
  (present_mismatched 0, unexplained 0, dos_mismatched 0).
* **Frames looked at** (private dumps with `--dump-presented`, `obj/cal/`): `conq-sheet.png` (the two leaders' fades,
  heads, trophies at the wall's left and right edges, lines in the panel and the dissolve), `conq-final.png` (the
  final panel's two lines over the wall with both trophies), `nuke-strip.png` (the flash, the fireball, the cloud and
  the rings centred on the Zimbabwe city at the core's square, the map around it).

## Deviations from DOS and the ruling

1. **The waits are the core's (TC):** O9:0F79's 240-frame wait (O9:135A..1367) and wait(3Ch) (O9:14E9) are replaced by
   the core's caption strip (1180:1EB6) and its whole background (1180:1FA0); the fades and the dissolve keep DOS's
   frames (TX).  The core's caption can come before the 48-frame fade-in has ended: the lines then wait for it.  The
   core's DelayTimerTicks decide the leaders' length (P0).
2. **The lines are the core's texts** (the same words as DOS's DGROUP strings, folded); the final panel's lines too.
3. **I-wait by I-report:** DOS-PROFILE's I-wait for row 114 is served by the report renderer's state (PDOS_AS_REPORT,
   I-report/key: the key or click passes to the core's WaitForKeyOrClick 1180:17B0), as D7m's screens; no adapter row.
4. **The explosion follows the core (decision 11):** the core's 139 (or 63) frames at 5 ticks each instead of DOS's 35
   steps of 5 frames (the cells beyond the 35th repeat 21..27), the core's square instead of DOS's clamped position
   (x 50h..114h, y 8..9Ch), no DOS restore of the rectangle (the element is replaced per frame over the map element).
5. **NUKE1's palette at the first frame shown**, not at the core's palette call (11B8:0C8B): between them lies the
   core's 0AAh-tick wait, while DOS loads it just before its first frame.
6. **The Windows-profile mirror of row 110:** the drop macros are DOS_ONLY; ext_mirror's WIN mirror still counts the
   core's DrawTile into the scratch bitmap as unexplained (Open D5, unchanged; no ext_mirror run reaches the
   explosion).
7. **OPEN P27:** SLAM2's 197-pixel rows drawn `width` wide (D1's settlement); never visible here.
8. **No new PDOS_AS bit, owner, adapter or scene-table row**; `pdos_fx.c`, `pdos_prov.c` and `pdos_scene_tab.c`
   unchanged (section "Files").
9. **The conquest runs' `pdos_rows` r101 2** (the newspaper, row 101) is D7m's too (its conquest run has it): not D7n's.

## What the user checks

On the coordinator's user build (D7n landed; `civ64.exe`, DOS files present), with the DOS graphics
(Ctrl+Shift+Backspace or the window menu).  Two save files in the user build's folder (copies of the test save, as the
automatic tests use them): copy them to your saves folder (%LOCALAPPDATA%\civ64\CivWin) yourself.

* **D7n-1** The conqueror ending: load CONQUEST.SAV (Load a Saved Game in the title menu), press Space for each unit
  until the turn ends, answer the palace question (Return, then 1 and 1, then Space), press Space on the newspaper:
  the screen goes black, then for each of two conquered civilizations (the Greek and the French leader): a golden
  panelled wall fades in from black with the conquered leader's head and shoulders at the top centre and a framed panel
  at the bottom; a small portrait of the leader (the trophy) appears on the wall; two lines of text appear in the
  panel (the year, your civilization destroyed the other's), the leader's expression changes, and the large head
  dissolves away, leaving the wall with the small portraits.  The first trophy is at the wall's left edge, the second
  at its right edge.
* **D7n-2** After the second leader: the wall with both trophies and in the panel the two lines hailing you as the
  conqueror; a key or click goes on to the end of the game (D7m's screens: the power graph first).
* **D7n-3** The nuclear explosion: load NUKE.SAV; the active unit is a Nuclear next to a Zimbabwe city on its left
  (west); press 4 on the numeric keypad (NumLock on): over the map, centred on the city, a white flash, an orange
  fireball that grows, darkens into a brown cloud and shrinks, then orange rings spreading around the city (the last
  rings repeat for a while, as the Windows game runs longer than DOS); then the map's colours fade back in; Return
  takes the message after it.  The map stays visible around it; the explosion is at the city's place also when the
  window is zoomed.
* **D7n-4** The same with the Windows graphics: the Windows screens and the Windows explosion, unchanged.

Not part of this check: switching the graphics while one of these screens shows.

## For the records

* **DESIGN** (12.x, the report renderer's and the class-A module's "As implemented"): D7n adds row 114
  (ShowConquerorEnding 1180:152F; O9:0DDE, O9:0F79) to the report renderer's table: an N view from dialog 148's
  GR_DialogOpen, every event and primitive on its window and port dropped and its bitmaps declined; each conquered
  leader (ShowConqueredCivLeader 1180:17E9) runs O9:0F79 on a TX timeline (the fades O9:1079, O9:124C and `G#10`(1, 1Eh)
  in DOS frames), its waits released by the core's copies (TC); the DOS drawing in `pdos_scn_end.c`; and row 110
  (AnimateNuclearExplosion 11B8:0C3D; O22:0967) to D6e's `pdos_aplay`: the core's tiles and copies dropped by two
  DOS_ONLY macros, an A element of DOS's `NUKE1.PIC` cell at the core's rectangle at 2x with colour 0 transparent,
  NUKE1's palette from the first frame, R:0238:1BEB at the exit (decision 11).  `pdos_report_advance` runs the
  leader's timeline at every presentation tick.  No PDOS_AS bit, owner, adapter or scene-table row.
* **FIDELITY** (new entries; numbers by the docs pass):
  * F-new-1: the conquered leader's two waits are the core's (its caption strip and whole background copies, after its
    DelayTimerTicks), not DOS's 240 frames and 60 frames (O9:135A..1367, O9:14E9); the fades (30 and 48 frames) and the
    dissolve (219 frames) are DOS's; when the core's caption comes during the fade-in, the lines wait for its end.
  * F-new-2: the nuclear explosion runs the core's 139 frames (63 without the option bit 10h) of 5 ticks at the core's
    square, cells 21..27 repeating beyond DOS's 35 steps (DOS: 35 steps of 5 frames at a clamped position); decision 11.
  * F-new-3: NUKE1's palette is applied with the explosion's first frame (DOS: just before its first frame; the core
    applies its own before a 0AAh-tick wait).
  * F-new-4: SLAM2's odd-width rows (OPEN P27) drawn `width` wide; the 198th column DOS copies from stale memory is
    not reproduced; not visible in the ending.
  * F-new-5: the ending's key or click is the report state's I-report (the core's WaitForKeyOrClick), as the other end
    screens.
* **DOS-PROFILE** (staged): rows 106, 110 and 114, P8, P12, P37, T6, T16, E16, E17 and E23 "as implemented in D7n".
* **OPEN** (`docs/dos/OPEN.md`, the docs pass): L1's "conqueror mouth rectangles" read (O9:0F79, DOS listing): mouth 1
  (1, 51, 59, 49) and mouth 2 (1, 151, 59, 49) of `KING<p>.PIC`, drawn at (x, y - 2) with x = 5Ah + (X[2p] - B4h) -
  X[2p + 1], y = (Y[2p] - 40h) - Y[2p + 1] of LEADER_FACE_X / _Y through [DGROUP:642E] / [6430] (the segment of
  [640A]); row 114 implemented (unit D7n).  The other parts of L1 stay as they are.
* **OFFSETS** (staged): the O9 readers of `LEADER_FACE_X` / `_Y` and the note on [642E] / [6430].
* **RUNNING**: presentation-diag.log's `report` line gains the ten `conq_*` counters; the new `aplay` line (D6e's
  counters and the six `nuke*`); timeline.log's steps `conq_leader`, `conq_head`, `conq_trophy`, `conq_text`,
  `conq_dissolve`, `conq_shown` and `conq_final` and the fades O9:1079 / O9:124C; ext_adapt's d7n runs
  (`d7n-conq-dos`, `d7n-conq-win`, `d7n-nuke-dos`, `d7n-nuke-win`); ext_timeline's `conquest` run.
* **FEATURES**: with the DOS graphics the conqueror ending (the conquered leaders, the trophies, the final panel) and
  the nuclear explosion are DOS's.
* **STATUS / checklist**: D7n done (the user checks D7n-1..4 pending); OPEN L1's mouth part resolved; D7o remains.

## Expected changes at the build slot

Against D6fSd's cycle (`build/d6fsd-status.txt`, ALL_GREEN 05:06:44 UTC; the tree after D7f, D6fSd and the docs pass
e4h):

* build.cmd: portable sources 308 unchanged (no new source file); the test programs unchanged in number.
* test.cmd checked: unit.log test_pdos_end 155 -> 193, test_pdos_play 78 -> 89; every other count unchanged (test_dos
  23,281, test_pdos_report 229, test_pdos_reskin 209).  `registry.py check` REGISTRY_OK with 4 more `ok` lines (529 ->
  533: the readers O9:117B, O9:1186, O9:1192, O9:119D); `dos-decoded.txt` and `pdos_registry.h` unchanged.  OBS_LINT_OK
  files 148, probes 203, call sites 101; OBS_TABLES_OK 203 / 101; pdos_scene_check 1084; ADAPT_OK rows 153 steps 27:
  all unchanged.
* EXT_ADAPT_OK checks 329 -> 342 (the d7n runs: 4 runs, 13 checks; the d7m pair's report lines now begin with
  ('O9:0DDE', 114) and list six `report_end`, its N-frame line one more view; the `report` lines of the D7a..D7m runs
  gain the ten `conq_*` counters at 0, the `aplay` line is new in every run's diag).
* EXT_TIMELINE_OK: the base group's checks 53 -> 60 (the conquest run, 7; the runs line names it).
* P0_OK checks 476, MIRROR_OK runs 29, REPLAY_OK checks 70, ZOOM_OK, EXT_FRAMES_OK, NODOS_OK (0 hits) and the other
  suites unchanged; EXT_G1_OK runs 77 unchanged (the Windows profile's frames do not change).
* Informational, not predicted to the count (each "may change"): ext-p0's V1 `pdos_rows` of conquest lose `r114 2`
  (row 114 drawn) and its V4d zoom lines of conquest (the ending's N frame instead of the zoomed A frame); ext-replay's
  informational V1 lines of conquest (the ending's primitives dropped); coverage.txt's "other functions entered"; nodos's
  file count; unit.log's OBS_COST line (host timing).

## Rebase notes

* **Bases:** the tree's files after D7f's landing (copy-in 02:30:03 UTC), each recorded at its copy
  (`obj/base-at-copy.txt`, `obj/base-at-copy-raw.txt`, `obj/base-added.txt` with the times) and rechecked equal to the
  tree in `BASE-SHA256.txt` (`obj/basesha.py`; its second line gives the time).  `pdos_registry.c` is generated (the
  tree's `gen/dos/registry.py gen` on the staged OFFSETS.md reproduces it byte for byte; its `.h` equals the tree's).
  build.cmd, test.cmd, `pdos_shadow.h` (PDOS_OWNER_MAX 10, 9 used), `pdos_scene_tab.c`, `pdos_fx.c`, `pdos_prov.c`
  and the other references are the tree's (`BASE-SHA256.txt`'s last part).
* **D6fSd** (copy-in 04:28:49 UTC, `build/d6fsd-prep/landed.sha256`): two shared files, `tests/harness/ext_adapt.py`
  and `tests/headless/harness.c`, merged three ways at 04:30 UTC (`git merge-file -p` to stdout, read only to the
  repository; base: `build/d6fsd-prep/tree-before/` = D7n's previous bases 06c23086... and 538cfe74...; theirs: the
  tree's files after D6fSd; mine: the staged files; `obj/rebase-d6fsd/` base, theirs, mine, merged, resolved; the
  previous staged copies and bases in `obj/base-pre-d6fsd/`).  harness.c merged cleanly (D6fSd's `preskin2` line two
  lines below D7n's `aplay` line, CRLF kept); ext_adapt.py had one adjacency conflict, the module docstring's end
  (D6fSd's paragraph, then D7n's; `obj/resolve.py` keeps both sides, theirs first); D6fSd's other hunks (the A boxes'
  places, `d6fsd_place`, the f6c/f6d rows) do not touch the d7m, d7k or d7n blocks.  The overlay was made again on the
  tree after D6fSd (`obj/mkoverlay.py`; `obj/ovcheck.py`: 987 tree files and 16 staged files, 0 differ).
* **The docs pass e4h** (applied 05:15:28 UTC, `build/docs-e4h-done.txt` 05:28:00 UTC; D7k, D7f and D6fSd's records):
  of the staged files it changed `docs/DOS-PROFILE.md` only (rows 12, 14, 15, 17, 18, 19, 22, 87, 89, 1.3's prose, Open
  1 and 2).  Merged three ways at 05:28 UTC (`obj/rebase-e4h/`: base the tree's file before the pass, e8a1b8c3..., =
  `build/docs-e4h-stage/before/docs/DOS-PROFILE.md` = D7n's previous base; theirs the tree's after it, 2b73b04b...):
  no conflict, the merged file is the tree's with D7n's eleven rows.  The overlay made again; `obs_tables.py --check`
  (203 / 101), `pdos_scene_check` (1084), `adapters.py check` (153 / 27) and `obs_lint` (148 / 203 / 101) pass on it.
* **Another landing** that changes a staged file: merge three ways the same way; D7n's parts are the delimited
  `extension D7n` blocks and one-line hunks marked `extension D7n`.  OFFSETS.md merged, `pdos_registry.c` regenerated
  (not merged).  DOS-PROFILE.md's D7n edits are confined to rows 106, 110, 114, P8, P12, P37, T6, T16, E16, E17 and
  E23 (the docs pass e4h, staged in `build/docs-e4h-stage/`, edits other rows: a three-way merge there is mechanical).
* **After the copy-in:** the base check, then build.cmd checked, test.cmd checked and ext_g1, guarded by each log's OK
  marker; the release build; the user build with CONQUEST.SAV and NUKE.SAV (`obj/saves/`, `obj/mksaves.py`).

## Landing

D7n landed alone at the build slot of session E4 (track A), 2026-10-18, after D6fSd's landing (RELEASE_OK 05:11:37
UTC, user build `build/user-builds/d6fsd/`) and the docs pass e4h (`build/docs-e4h-done.txt`, 05:28:00 UTC), as the
orchestrator ordered ("land straight away"; no word that D7g goes first; no other cycle or landing active).  The user
checks D7n-1..D7n-4 are in the user build `d7n`.

* **Rebases** (section "Rebase notes"): D6fSd's `tests/harness/ext_adapt.py` and `tests/headless/harness.c` merged three
  ways (04:30 UTC; one adjacency conflict in ext_adapt.py's docstring, both sides kept), the docs pass's
  `docs/DOS-PROFILE.md` merged three ways (05:28 UTC, no conflict); the overlay made again; the Checked build, the
  units, the whole ext_adapt suite (EXT_ADAPT_OK checks 342), ext_timeline (60), ext_p0 (P0_OK 21) and ext_mirror
  (MIRROR_OK 3) on conquest, retire and arrival, the static checks and nodos (0 hits) after the rebase, with D6fSd's
  test step left alone (section "Results").  `BASE-SHA256.txt` written again (BASESHA OK).
* **Bases:** `build/d7n-prep/land.py` (from D7f's) rechecked every base (DRY_RUN_OK 16; build.cmd and test.cmd
  unchanged; every read-only reference the same), took the snapshot `build/d7n-prep/before` (the tree's
  `build/test/Checked` outputs of D6fSd's cycle, 66 files) and `tree-before` (the 15 replaced files), and copied in at
  05:35:13 UTC (`landed.sha256`: the 15 changed files and this record, rechecked equal afterwards; `landed-at.txt`
  "unit d7n"; `land-write.log`).  Predictions `build/d7n-prep/predictions.txt`, written before the copy-in.  Scripts in
  `build/d7n-prep/` from `build/d7n-stage/obj/mk_prep.py`: `land.py` from D7f's (D7f's BASE-SHA256.txt format),
  `d7n-cycle.ps1` and `compare.py` from D6fSd's, `mk_userbuild.py` from D7f's with D7n's two saves, `fill_stillopen.py`
  from D6fSd's with a new group "d6fsd" (`fix_fill.py`: the checklist has D7k-2 under build "d6fsd", D7k-1, D7k-3 and
  D7k-4 under "d7k").
* **The three-step cycle** (`build/d7n-prep/d7n-cycle.ps1` through Windows PowerShell, status `build/d7n-status.txt`,
  each step guarded by its log's OK marker): 1 `build.cmd checked` BUILD_OK 05:35:20..05:39:38 (257 s; portable
  sources checked 308; no warning); 2 `test.cmd checked` TESTS_OK 05:39:38..06:20:13 (2435 s; TEST_SECTIONS 30 failed
  0, wall 2432.8 s: ext_adapt 2395.5, ext_zoom 2347.5, d2_nodos 1915.8, ext_p0 1619.3 s; no flake rerun); 3
  `ext_g1.py check` EXT_G1_OK runs 77 (amended 1) unchanged: **ALL_GREEN** 06:20:13.  4 `build.cmd` (Release) BUILD_OK
  06:20:27..06:28:33 (486 s, no warning): **RELEASE_OK**.
* **Against the predictions** (`build/d7n-prep/compare.py` against the snapshot, `build/d7n-prep/compare.txt`: 55 of 66
  files equal, host times left out): as predicted, unit.log test_pdos_end 155 -> 193 and test_pdos_play 78 -> 89,
  every other count equal; registry-check REGISTRY_OK with the four O9 readers' `ok` lines (529 -> 533);
  EXT_ADAPT_OK checks 329 -> 342, the changed lines exactly the predicted ones (the 13 d7n lines equal to the private
  run; d7m-end's timeline line with ('O9:0DDE', 114) first and six report_end, its N-frame line [0, 1, 10, 3, 2, 1];
  the whole `report` lines of d7a-report, d7b-info, d7c-world and d7m-end gaining the conq_* counters, d7m-end's
  conquests 1 and conq_finals 1); EXT_TIMELINE_OK with 60 PASS lines (53 + the conquest run's 7; the runs line names
  it); P0_OK checks 476, MIRROR_OK runs 29, REPLAY_OK checks 70, ZOOM_OK, EXT_FRAMES_OK, OBS_LINT_OK files 148 probes
  203 callsites 101, OBS_TABLES_OK probes 203 sites 101, ADAPT_OK rows 153 steps 27, pdos-scene-check 1084 and the
  other sections unchanged.  Informational, as predicted: ext-p0's V4d conquest zoom 85 -> 78 shows with the layer (the
  ending's N frame); ext-replay's V1 conquest line (brackets 139 -> 140, draws 22 -> 23, no_shadow 130 -> 129);
  coverage.txt "other functions entered" 669 -> 677; nodos files 1825 -> 1827, 0 hits; unit.log's OBS_COST line.
* **User build** `build/user-builds/d7n/` (06:29 UTC; `build/d7n-prep/mk_userbuild.py`): `civ64.exe` (the Release
  build, SHA-256 53e6a985...), `CIVWIN.zip` and `civdos.zip` from `build/user-builds/d4/`, `CONQUEST.SAV` (ab2dd64f...)
  and `NUKE.SAV` (887be310...) (`build/d7n-prep/`, from `build/d7n-stage/obj/saves/`: the d7n runs' saves), and
  `WHAT-TO-CHECK.txt` (D7n-1..D7n-4; the earlier builds up to "d6fsd"; the 144 items still pending in the checklist at
  06:20 UTC).
* **Host load:** D7g's private runs (`build/d7g-stage`) during the cycle; no flake, no rerun.
* Not done at this slot: the checklist sections and STATUS rows (the orchestrator's) and the docs pass for D7n ("For
  the records"); the tree's CheckedNoObs and Release unit programs are not part of the cycle (the private overlay's are
  in "Results").

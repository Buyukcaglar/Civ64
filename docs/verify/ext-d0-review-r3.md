<!-- Independent adversarial review R3 of the extension D0 drafts (scenes, inventory, correspondence,
     profile tables and open items), by a separate read-only reviewer agent, 2026-10-11 (first attempt
     00:44..00:55 UTC cut off without a report; this review re-derived everything and finished at about
     06:30 UTC). Scope: claude/port/docs/dos/SCENES.md, SCENES-PLAY.md, WINDOWS-INVENTORY.md,
     CORRESPONDENCE.md, OPEN.md and claude/port/docs/DOS-PROFILE.md, under BRIEF-d0-review.md.
     Scratch scripts are in claude/port/build/dos/scratch-r3/v2/ and are not part of the repository. -->

# D0 review R3: scenes, inventory, correspondence, profile tables and open items

Abbreviations: SC = `docs/dos/SCENES.md`, SP = `SCENES-PLAY.md`, WI = `WINDOWS-INVENTORY.md`,
CORR = `CORRESPONDENCE.md`, OPEN = `OPEN.md`, PROF = `docs/DOS-PROFILE.md`, "prompt" =
`claude/docs/x64-port-scaling-dos-prompt.md`.

## How I worked

I read BRIEF-d0-review.md, BRIEF-d0.md and the whole extension prompt (3, 5.2 O2, 5.3, 5.4, 5.5,
5.6, 5.9, 5.10, 6, 8 and 9 in detail), then the six documents in full, and the Open sections of
EXECUTABLE, DRIVER, TIMING, FORMATS, PALETTE and SPRITES (for OPEN's completeness only).

Sources and tools (all read-only):
- **Windows**: `C:/Python314/python -B claude/tools/showfunc.py <addr>` (whole functions and
  ranges); `claude/docs/db/functions.json` (call sites in, `call_sites_in`); `claude/docs`
  resources.md, data-tables.md, graphics.md (4.7, 4.9, 4.16), ui-dialogs.md; `FEATURES.md`,
  `TRACE.md`, `FIDELITY.md` (F79, F84), `API-MAP.md`, `phase-5-acceptance.md`.
- **Windows resources (a deviation, disclosed)**: my parser `rsc.py` read the resource maps and
  `CvPc` headers (id, width, height, colour count) of the Mac resource forks `civdata0..4.rsc` in
  the port's data copy `claude/port/build/gamedata/`, to check WI 1.1 and 1.2. That folder is
  not on the brief's list of Windows sources (claude/docs, claude/src, FEATURES, TRACE,
  showfunc). Only header fields were read; no pixel was decoded and nothing was written there.
  WI itself uses the same source under its label **resource** (R3-21). Discount rows 1..3 of table 1.3
  below if that source is not accepted.
- **DOS**: the listings in `claude/port/build/dos/disasm/` (root, ovl01..23, mgraphic, misc,
  `db.json` strings) through my helper `dl.py`; the DOS files in `claude/port/build/dosdata/`
  (sizes; line and marker counts of `CREDITS.TXT` and `STORY.TXT`; `FONTS.CV` font headers; four
  short DGROUP strings of `CIV_UNP.EXE` at DGROUP 2B01h). No DOS program was executed.
- Scripts (in `scratch-r3/v2/`): `wl.py` (showfunc wrapper, call-site lists), `dl.py` (DOS listing
  ranges), `rsc.py` (resource-fork headers), `counts.py` (PROF table rows and classes). Dumps:
  `dlgsites.txt` (all 32 GR_DialogOpen sites), `cursites.txt` (all cursor setters), `egss.txt`
  (ExtractGameSpriteShapes), `setup.txt` (RunNewGameSetup), `news.txt` (ShowNewspaper),
  `status.txt` (DrawStatusCivPanels). The files left at the top of `scratch-r3/` by the cut-off
  first attempt were not used.

Labels below: **showfunc**, **db** (functions.json), **doc** (claude/docs), **DOS listing**,
**DOS file**, **arith** (my arithmetic on stated values). Nothing was written outside this report
and my scratch folder; nothing was staged or committed.

## 1. Claims checked

Result: **pass** (re-derived, agrees), **fail** (re-derived, disagrees; see the finding),
**partial**.

### 1.1 SCENES.md (21 claims)

| # | Claim (SC section) | Result | Method |
|---|---|---|---|
| 1 | Title: R:01A8:0486 calls the menu box R:0238:0008(DGROUP:1AE2, 100, 140) and repeats while it returns −1 (6) | pass | DOS listing root |
| 2 | Title ends the tune on a phrase boundary: compares against 1495h and 120h (6) | pass | DOS listing |
| 3 | Title strings DGROUP:1AE2: five items, the third is "EARTH" (6) | pass | db.json strings |
| 4 | Logo waits until `S#5` ≥ 0D87h (5, O2:0A19) | pass | DOS listing O2 |
| 5 | Strip reveal: 80 steps of G#20 (x, 64, 4, 80) with wait(1) (5) | pass | DOS listing O2:0A19..0BB6 |
| 6 | Logo cycling: slot 4 = entries 224..239 at rate 14 (5) | pass | DOS listing |
| 7 | Hold: 100 × wait(5) or until `kbhit`; then `G#10(1, 20)` (5) | pass | DOS listing |
| 8 | Post-pan keys N, L, E, C (either case) give 0..3; any key jumps to O2:0B26 (4.4) | pass | DOS listing O2:09D7..0A51 |
| 9 | Credits: font 5 set at O2:052C; three draws centred on x 160 at y 184, 182, 183 in colours 252, 248, 250 (4.3) | pass | DOS listing |
| 10 | `CREDITS.TXT` holds 24 lines (4.3) | pass | DOS file |
| 11 | `STORY.TXT`: 8 one-character markers, 44 text lines, per picture 3, 3, 8, 5, 6, 8, 10, 1 (8.2) | pass | DOS file |
| 12 | Birth step O7:17CF: font 7, text at (160, 160) in colour 3 then 11 with wait(5); row restore with wait(10) (8.1) | pass | DOS listing O7:17CF..1A93 |
| 13 | Birth picture to page 2 without palette; 8-step fade out R:0000:04D4; `BIRTHk.PAL` to DGROUP:C5BE; 8-step fade in R:0000:04AA (8.1) | pass | DOS listing |
| 14 | "BUILDING NEW WORLD..." area cleared as (40, 160, 240, 8) (8.4) | pass | DOS listing |
| 15 | Customize: four menus at x 200, y 1, 51, 101, 151; pointer moved to (210, y + 10); `CUSTOM.PIC` with palette; 5-step fade at R:01A8:05B6 (7.4) | pass | DOS listing R:01A8:0591..0792 |
| 16 | Customize help topics DGROUP:1B6A, 1B94, 1BBD, 1BFE (7.4; CORR 3) | pass | DOS file (`CIV_UNP.EXE` DGROUP, four short names) and listing refs R:01A8:0666..077D |
| 17 | `FAME.DTA` is 276 bytes (7.5) | pass | DOS file |
| 18 | Menu box R:1D05:0475: row height = FontLineHeight with 9 → 8; right edge x + W + 8; bottom rows·h + y + 6 (+2 with help); rows clamped to (192 − y)/h; odd y = frameless (10.1) | pass | DOS listing |
| 19 | Drop-downs R:1C84: title index x / 60 clamped 0..4; positions GAME (16, 8), Options (24, 16), ORDERS (72, 8), ADVISORS (112, 8), WORLD (144, 8), CIVILOPEDIA (182, 8) (10.2) | pass | DOS listing R:1C84:0019..002E and following |
| 20 | GAME menu DGROUP:2BD4 nine lines (with a blank); Options DGROUP:2C3E eight items (10.2, CORR 5) | pass | db.json strings |
| 21 | Tribe name at logical (46, 92) in colour 15 (9.3) | pass | DOS listing O5:0571..0587 |

### 1.2 SCENES-PLAY.md (20 claims)

| # | Claim (SP section) | Result | Method |
|---|---|---|---|
| 1 | Square position px = wrap(x − D4CC)·16 + 80 (2.1) | pass | DOS listing R:1AEA:03BA |
| 2 | py = (y − D75E)·16 + 8 (2.1) | pass | same |
| 3 | Drawn only for 80 ≤ px < 320 and 8 ≤ py ≤ 192 (2.1) | pass | same |
| 4 | World mode (B278 = 1): 4x4 fills (2.2) | pass | same |
| 5 | Special formula with 13, 11, [6E80], +8, &15 / &31 (2.1) | pass | DOS listing R:1AEA:1836 |
| 6 | Hut formula, rows 2..47 (2.1) | pass | DOS listing R:1AEA:1894 |
| 7 | Hut visibility bit 0 of es:[63FA]:[50x + y + 740h] (2.1) | pass | same |
| 8 | Full redraw: one `random(256)`, then p = 5p + 1 masked to 8 bits (2.4) | pass | DOS listing R:1AEA:0008 |
| 9 | Column p & 15, row p >> 4; D75E clamped 0..38 (2.4, 3) | pass | same |
| 10 | Labels only for py < B8h; truncated to 327 − px; at (clamp(px − 8, 80, 999), py + 16) in colour 11 (2.3, 2.4) | pass | same |
| 11 | Menu bar titles at x 8, 64, 128, 192, 240, y 1, colour 15 (5.1) | pass | DOS listing R:0238:0FEA |
| 12 | Status panel (0, 58, 80, 39); sky fill (3, 60, 74, 11) colour 11 (5.2) | pass | DOS listing R:0238:107E |
| 13 | Peace bar 2 pixels per turn, colour 15; mini palace R:0238:14A3(player, [1C20], 8, 58) (5.2) | pass | same |
| 14 | Research icon index clamp(4·progress/(cost + 1), 0, 3), cost = (2·[6B86] + [D2DE] + 6)·techs·(1 BC / 2 AD) (5.2) | pass | DOS listing R:0238:11BE..11F3; same shape as showfunc 1088:13D5 |
| 15 | Rates drawn `10 − a − b`, a, b (5.2) | pass (order); naming of a/b inferred (R3-25) | DOS listing |
| 16 | Nuclear explosion: `NUKE1` with palette; x = clamp(16·wrap + 66, 80, 276), y = clamp(16·dy − 6, 8, 156); sound 2Ah; 35 steps, 28 frames (7.5) | pass | DOS listing O22:0967 |
| 17 | Newspaper fonts 4, 5, 3, 1, 2 (7.7) | pass | DOS listing O21 |
| 18 | New Cabinet: font 6 at (160, 102), titles font 2 (7.10) | pass | DOS listing O5:1BA2 |
| 19 | Power graph frame (4, 9, 311, 183), minimum scale 50 (7.17) | pass | DOS listing O12:05A1..05B9 |
| 20 | Blink 10 off, 10 on frames = about 0.29 s per phase change at 70 Hz (6.1) | pass | arith: 20 / 70.086 = 0.285 s |

### 1.3 WINDOWS-INVENTORY.md (21 claims)

| # | Claim (WI section) | Result | Method |
|---|---|---|---|
| 1 | 199 pictures, 199 distinct ids (1.1) | pass | rsc.py over the five resource forks |
| 2 | Distribution civdata0 4, civdata1 14, civdata2 31, civdata3 149, civdata4 1 (1.1) | pass | same |
| 3 | Every size and colour count of the 1.2 table | pass | same, row by row |
| 4 | GR_PicRead 23 callers / 34 sites; LoadPictureToPortBitmap 12 sites; LoadGifPicture 1 (1.2, 1.3) | pass | db |
| 5 | 24 templates with sizes; 19 opened, 5 never opened (133, 138, 150, 999, 2000) (4.1) | pass | resources.md; all 32 GR_DialogOpen sites, pushed id read at each (showfunc) |
| 6 | Dialog 148: 16 openers, 15 live, 1060:02A1 dead (4.2) | pass | dlgsites.txt |
| 7 | Cursor setters: 0x81 ×29 (2 via `push cs`), 0x84 ×32, 0x82 ×1, 0x83 ×4, 0x86 ×1, 0x85 through SetCursorAndMarkChanged at 1208:12B7, arrow 0x87 + dir at 1208:14A2; 128 and 135 no setter (5) | pass | SetGameCursor 68 sites + 2 (db, showfunc) |
| 8 | Hot spots of the 16 cursors (5) | pass | resources.md |
| 9 | SetCivFont 11E8:0B40 id → face/size table (3.2) | pass | showfunc |
| 10 | Intro movie 13D0:0000: 29 items, text flags 0x211 and 0x711 (6.1) | pass | data-tables.md, showfunc |
| 11 | Birth movie 13D8:0000: 78 items, 40-step fades over 0..223, text flags 0x111, per-picture texts 3, 3, 8, 5, 6, 8, 10, 1 (6.2) | pass | same |
| 12 | Shapes from picture 200: 23 rows; 20 ExtractPictureTile2x and 8 TileExtract calls (2.1) | pass | egss.txt against graphics.md 4.9 |
| 13 | Unit shapes T2(16(j % 20), 161 + 16(j / 20), 15, 15) (2.1) | pass | showfunc 10E8:2931..2954 (no +1) |
| 14 | Specials and sparks at (16i + 1, 113) and (16i + 1, 97) (2.1) | pass | showfunc 10E8:288B, 28BF |
| 15 | Picture 137 read in GenerateWorldMap 1028:0096..00D8 (subtract 10, hmemcpy) (8 #1) | pass | showfunc |
| 16 | GetPortPixelIndex 5 sites; GetTileOpaqueBounds 3; GetScreenBufferPixel 89; SetScreenBufferPixel 47 (8) | pass | db |
| 17 | GetPortPixelAtOffset, TestPaletteIdentityMapping, GR_PortChangeColor have no callers (8 #10) | pass | db |
| 18 | CyclePaletteColors 1208:22B7, SetTimer 200 ms at 1208:0E68..0E7B, call at 1208:01AF (9.1) | pass | showfunc |
| 19 | AnimatePaletteFromGrPort 26 sites; CopyPaletteEntries 27 (9) | pass | db |
| 20 | MapLogicalPointToPort 1220:0F2F, 9 callers (7.2) | pass | db |
| 21 | GR_DialogOpen 32 sites (4.1) | pass | db, showfunc |

### 1.4 CORRESPONDENCE.md (19 claims)

| # | Claim (CORR section) | Result | Method |
|---|---|---|---|
| 1 | O5:1455 and ExtractGameSpriteShapes cut the same tables "at the same logical rectangles", proved (1 finding 1; 13) | **fail** for units | DOS listing O5:19C5..19EE and O5:1A14..1A32 against showfunc 10E8:2931..2954 (R3-1) |
| 2 | Unit index rule 64 + 32c + j on both sides (1 finding 1) | pass | same |
| 3 | Combat sparks at (16i + 1, 97, 15, 15) (7) | pass (Windows side) | showfunc 10E8:28BF |
| 4 | Sheet rule (2x + 832, 2y − 100) for the four families (1 finding 2) | pass (arith only) | arith; g_wholeTileShapes[9] (1408, 140) ↔ page-2 (288, 120) also fits |
| 5 | Newspaper font ids equal DOS font numbers: 5, 3, 1, 2, 4 (1 finding 5) | pass | DOS listing O21; news.txt (1138:0000) |
| 6 | New Cabinet title font 6, portrait titles font 2 (11) | pass; position difference unrecorded (R3-19) | DOS listing O5:1BA2; showfunc 1138:01EF..0207 |
| 7 | Power graph frame (4, 9, 311, 183) shared (1 finding 6) | pass | DOS listing O12:05A9..05B9; showfunc 1188:07F0..07FC |
| 8 | Tribe name at (46, 92) in white on both sides (3) | pass | DOS listing O5:0571..0587; setup.txt |
| 9 | Setup portraits (20 + 2k, 100 + 3k) ↔ (32 + 3k, 160 + 4k) "(×1.6)", proved (3) | partial | arith (R3-13) |
| 10 | Title: "the first four item names are the same strings in the same order" (3) | **fail** | db.json strings (R3-14) |
| 11 | Customize topics name the same four help topics (3) | pass | DOS file DGROUP strings |
| 12 | Birth: 44 lines and 8 pictures on both sides (4) | pass, and per picture (R3-24) | DOS file `STORY.TXT`; data-tables.md |
| 13 | GAME menu items pair with commands 102, 103, 104, (Options), 101, 113, 114, 115 (5) | pass | db.json strings; FEATURES |
| 14 | F1..F10 report order = commands 0x131..0x139, 0x130, "inferred (order)" (1 finding 9) | pass; can be upgraded (R3-23) | db.json strings DGROUP:2DD6, 2E32, 2E5D, 2EA5 |
| 15 | Mini palace private LCG `5v + 1` seeded per civ; index (level − 1 clamped 0..3)·5 + type (10) | pass | SP 5.2; graphics.md 4.16 |
| 16 | Status rates: Windows draws lux first (`lux = 10 − tax − sci`) (1 finding 10) | pass | showfunc 1088:13D5 |
| 17 | Research-icon formula shared (1 finding 6) | pass | DOS listing R:0238:11BE..11F3; showfunc 1088:13D5 |
| 18 | Libraries "Microsoft C versus Borland C `rand`, PC fact" (1 finding 7) | label wrong | R3-16 |
| 19 | G#21 colour bytes 80h and above (13, Open 10) | pass | FORMATS 2.3 (G:0000:0F9C); FONTS.CV headers: every font ends at or below 7Fh (DOS file) |

### 1.5 DOS-PROFILE.md (20 claims)

| # | Claim (PROF section) | Result | Method |
|---|---|---|---|
| 1 | All 108 FEATURES rows (9 + 19 + 67 + 13) are rows of 1.1..1.4 | pass | counts.py against FEATURES.md |
| 2 | 1.2 covers every dialog template the game opens (19) | pass | WI 4.1, dlgsites.txt |
| 3 | 1.8 totals: 141 rows = N 57, R 43, A 30, W 9, open 2 | pass | counts.py per section (1.1 N8 W1; 1.2 N10 R6 W2 open1; 1.3 N17 R28 A19 W3; 1.4 N10 A2 W1; 1.5 N12 R9 A9 W2 open1) |
| 4 | 2.1: 38 rows cover all 199 ids | pass | counts.py against rsc.txt |
| 5 | 2.2: 23 rows = the graphics.md 4.9 tables from picture 200 | pass | egss.txt |
| 6 | 2.3: 21 rows; 2.4: 17 font rows; 2.5: 16 cursors; 2.6: 24 palette effects | pass | counts.py; WI 3, 5, 9 |
| 7 | F2, F6: id 2 → font 2, id 6 → font 6, proved at the newspaper and New Cabinet | pass | news.txt; DOS listing O21, O5:1BA2 |
| 8 | Rule 7: PollMouseClick stores signed `*10/16` (idiv at 1108:0169..017A) | pass | showfunc 1108:0169..018F |
| 9 | Rule 7: WaitForKeyOrClick uses an unsigned shift at 1038:0CB6..0CDA | pass | showfunc |
| 10 | Row 1: Windows title at about 21.2 s | pass | FEATURES (event 17 at 21,202,300 µs) |
| 11 | Row 2: DOS box at (100, 140), font 1 | pass | DOS listing R:01A8:0486 |
| 12 | Row 5: GR_PicRead of 137 at 1028:0096 | pass | showfunc |
| 13 | Row 96: map, small map and status windows stay class A (Windows layout) | pass | – |
| 14 | S17 DOS unit rectangle (16(j mod 20) + 1, 16(j div 20) + 161, 15, 15) | pass (via the copy of rows 160..191 to 128 at O5:1A14..1A32, cut at y 129) | DOS listing |
| 15 | Row 136 records "peace bar 2 per turn" against Windows | pass (Windows `3*g_peaceTurns`) | showfunc 1088:13D5 |
| 16 | Row 141 / W6: the system MessageBox is drawn by `w16` in the virtual screen | pass | FIDELITY F79 |
| 17 | Every W has a reason (section 4, W1..W8) | pass | – |
| 18 | Row 121 / I-menubar: menu bar rendered by R:0238:0FEA, hit test x / 60 | conflict with prompt 5.3 and the withheld layout | R3-2 |
| 19 | I-title: clicks at "the item control's device point (I5, ScaleLogical)" | fail | showfunc MenuZ 1220:0156 (R3-7) |
| 20 | I-intro: a mouse button "passes and, by T5, ends the DOS intro" | fail against I6 | R3-3 |

### 1.6 OPEN.md (18 claims: each Detail citation opened)

| # | Entry → cited item | Result |
|---|---|---|
| 1 | P1 → TIMING Open 2 | pass |
| 2 | P2 → TIMING Open 3, SC Open 1 | pass |
| 3 | P3 → SP Open 7, SC Open 8 | pass (the city view generator, PROF Open 21, is not named; R3-10) |
| 4 | P5 → "DRIVER.md G#11/G#16 notes" | **fail**: the colour switch is G#21 / FORMATS 2.3 (R3-20) |
| 5 | P7 → PALETTE Open 1, TIMING 3.5 | pass |
| 6 | P9 → SP Open 2; P10 → PALETTE Open 10 | pass |
| 7 | P11 → CORR Open 1, WI Open 11 | pass |
| 8 | O1, O2, O6 → TIMING Open 1, 4, 6; DRIVER Open 6 | pass |
| 9 | O3, O4 → SC Open 7, 2, 4 | pass |
| 10 | O5 → DRIVER Open 12; O7 → FORMATS Open 5 | pass |
| 11 | L1 → SP Open 8 | pass |
| 12 | L2, L3, L4 → SP Open 1, 3, 4..6 | pass |
| 13 | L5 → FORMATS Open 9; L6 → SP Open 12 | pass |
| 14 | L7, L8, L9 → SC Open 9, 10, 6 | pass |
| 15 | L10 → SPRITES Open 2, 3, 5, 6, 8; L11..L13 → PALETTE Open 2, 4, 9; L14 → SP Open 10 | pass |
| 16 | L15 → WI Open 2, 6, 8..11 | pass |
| 17 | X3 → DRIVER Open 1..5, 7..11, 13, 14; TIMING Open 10 | partial (two sub-items dropped; R3-9) |
| 18 | X1..X13 others (EXECUTABLE 11, FORMATS 1, 3, 6..8, PALETTE 3, 5, SPRITES 1, 4, 7, WI 1, 3..5, 7, SC 5, 12) | pass |

## 2. Findings

No blocker. 10 major, 11 minor, 5 notes. I found no DOS bytes in the six documents: the dense
lines are rectangles, offsets and formulas; the DOS text quotes are short and identifying. I
found no fact that looks filled from memory of the game, and no citation of main-project paths.

### Major

**R3-1 (major). CORR 1 finding 1 and CORR 13 (row O5:1455); PROF 2.2 S1/S17 labels.**
Claim: O5:1455 and ExtractGameSpriteShapes "cut the same tables at the same logical rectangles",
proved. Found: not for the unit sprites. DOS copies SP257 rows 160..191 to y 128 (G#20 at
O5:1A14..1A32) and cuts unit j with G#2 at x = 16(j mod 20) + 1, y = 16(j div 20) + 129, 15x15
(O5:19C5..19EE), i.e. SP257 (16(j mod 20) + 1, 161 + 16(j div 20)). Windows cuts
T2(16(j % 20), 161 + 16(j / 20), 15, 15) with no +1 (showfunc 10E8:2931..2954), while its
specials and sparks keep the +1 (10E8:288B, 28BF). The rectangles differ by one logical pixel in
x (**DOS listing**, **showfunc**). The index rule and PROF S17's DOS rectangle are right.
Correction: replace "same rectangles" by "same rectangles except the units, which DOS cuts one
pixel to the right"; keep S17's source as written, and have the P11 pixel check include the
unit band (whether the Windows art is shifted by one column is unknown).

**R3-2 (major). PROF 1.5 row 121 and 1.7 I-menubar.** Claim: the menu bar (R) is rendered by the
DOS bar routine R:0238:0FEA with the DOS drop-downs R:1C84, and a click on a "DOS menu title
(x / 60)" is translated. Found: R:0238:0FEA places the titles at the fixed DOS play-screen
positions x 8, 64, 128, 192, 240, y 1 (**DOS listing**), and x / 60 is the DOS bar's hit test
(R:1C84:0019..002E). That is the DOS play-screen menu bar of the withheld add-on (prompt 0.3),
and prompt 5.3 puts "class R re-skins at the Windows positions" on the A canvas. Correction:
row 121 renders the `w16` menu bar of the map window at its Windows geometry in the DOS style
(font, colours, title names from the DOS strings); I-menubar then passes clicks on that bar (or
maps the restyled title extents to the Windows ones), never x / 60. SP 5.1 stays a DOS fact.

**R3-3 (major). PROF 1.7 I-intro, mouse row.** Claim: "the click passes and, by T5, ends the DOS
intro". Found: the core reaches its title menu at about 21.2 s (FEATURES event 17) while the
DOS intro runs to about 68 s (PROF row 1). From 21.2 s on a passed click reaches MenuZ in dialog
139, which the user does not see in the DOS profile, and may choose an item there. I6/T5
require consumption once the core has left the intro (prompt 5.6 I6). The key row does this; the
mouse row does not. Correction: a click passes only while the core is in its intro; afterwards
it ends the DOS intro (T5) and is consumed. State the same explicitly for keys ("ends the DOS
intro and is consumed").

**R3-4 (major). PROF 4 (W6) and row 141; prompt 5.3 "W over N".** Claim: none; the profile has
no "W over N" record. Found: W6 (system MessageBox) is drawn by `w16` inside the virtual screen
(FIDELITY F79), and its callers include ShowErrorMessage, which the picture loader uses on a
failed read (WI 1.2 notes), and CheckLowResourcesWarning. Both can open while an N scene (intro,
Birth, setup, a dialog-148 scene) is visible. Prompt 5.3 requires each such case recorded, and
prefers making the element R. The host file chooser and overwrite prompts are host windows and
do not count. Correction: add a "W over N" subsection naming W6 with its N scenes, and either
re-class the in-game error box R or record that the A frame is shown while it is open.

**R3-5 (major). PROF (no 5.10 character rule); OPEN P5.** Claim: none on characters; P5 says
colour bytes "must be reproduced in the DOS text renderer". Found: every DOS font ends at code
7Fh or lower (`FONTS.CV` headers, **DOS file**; FORMATS 2.2) and G#21 treats every byte of 80h
and above as a colour change (FORMATS 2.3, G:0000:0F9C). The core's text is Windows-1252 (prompt
5.10), and names typed by the user can hold bytes of 80h and above. Applied to core text, P5
would turn such letters into colour changes; DOS has no substitution of its own. Prompt 5.10
requires a recorded rule. Correction: add a P entry and a PROF rule: colour bytes are honoured
only in DOS-sourced static text; core bytes of 80h and above (and below 20h) map by a recorded
substitution (for example a fixed fold to 7-bit letters, or a placeholder), decided in D1.

**R3-6 (major). WI 7 and PROF 1 (prompt 5.2 O2 "The D0 inventory fixes the probe list").**
Found: no consolidated probe list. WI 7 lists the logical primitives and PROF lists scene-entry
probes, but these required probe kinds are not named as probes with their arguments:
- text functions at the alignment level: DrawTextInRect 1098:0ED1 (24 sites), TextBoxSetup
  1068:2072 (14), TextBoxDraw 1068:258F, TextBoxDrawAndClose 1068:255A, DrawTextAtPortXY 10D8:00E0
  (19), and the MenuZ option text;
- recolouring ReplaceTileColor 11A8:022F (6 sites) and TileCacheInsert 1110:01A3;
- AdvanceMovie 10B0:0461 dispatch (script, item, frame), SeekSequence 10B0:005B (3 sites) and the
  skip;
- the DrawTilesToPort mode and order (named in row 96, not as a probe).

(**db**.) Correction: add one table (WI 8a or PROF 1.9) giving for each probe the address, entry
or exit, the arguments read and the consumer. WI Open 6 (TextOut centring) belongs there.

**R3-7 (major). PROF 0.6 rule 7 and 1.7 (prompt 5.6 I5, "prove this per scene").** Found: every
per-scene conversion is deferred ("D1 proves the rule per scene"; I-city, I-report, I-palace,
I-space, I-pedia "(I5)" without a rule), and OPEN has no entry for it. One stated case is wrong:
I-title says ScaleLogical, but MenuZ 1220:0156 creates its options as `RanDoMRadio` child
windows (CreateWindow at 1220:08D5 and 1220:09B0) laid out in device pixels from the template
and text metrics (**showfunc**). There is no logical conversion; the device point comes from the
control's rectangle in the `w16` tree. Correction: give each I-row its conversion class
(PollMouseClick ⌈16L/10⌉, WaitForKeyOrClick, ScaleLogical forward, or control rectangle), or
list the per-scene proof as a P entry. Fix I-title (and I-menu, I-setup, I-custom, which also use
controls) to "control rectangle".

**R3-8 (major). PROF row 18 (dialog 141), row 131 / P36 (ShowCivilizationDestroyed, picture 5590)
classes "open".** Prompt 5.4 gives every element one of four classes. For 141 the prompt names
"list dialogs" as R, so R (a DOS menu box from the `w16` list) is the evident class. For 5590
the drafts give no DOS scene. Correction: set 141 to R; for 5590 choose N with the nearest
proven DOS behaviour or W with a reason (6.7), and register the choice as a P entry rather than
L17 "listing work".

**R3-9 (major). OPEN completeness (prompt 6.5 "OPEN.md: the unknowns").** These Open items of the
drafts are not in OPEN (by number):
- CORR Open 5 (R:0238:1767), 6 (ORDERS menu), 7 (production advisors);
- PROF Open 3 (other text-entry callers; RENAME box), 4 (option on/off state), 9 (city screen
  keys and regions), 11 (advisor and leader cells), 15 (city icons), 16 except the two fonts
  (Civilopedia per-site ids, font 9), 19 (production advisors), 20 (text sections), 21 (city view
  layout generator), 23 (ORDERS), 24 (Hall of Fame "Clear");
- SC Open 3 (colour 22, the y = 139 case);
- PALETTE Open 8 (first-entry assumption of R:0000:04AA).

Also missing or uncited, minor: SP Open 9; EXECUTABLE 11 "`jmp si`" and "roles inferred"; TIMING
Open 5 (not cited in X4); FORMATS Open 4 (not cited in X3); DRIVER Open 2's R:01A8:01C2 and Open
3's G#2 page sign (dropped from X3). Correction: add them to the right group, with their source
item.

**R3-10 (major). OPEN P group is not complete for D1.** D1 designs classes, timelines, adapters,
the palette rule and text (prompt 9), and needs these decisions recorded as P entries:
- W-over-N handling (R3-4);
- the Windows-1252 rule (R3-5);
- the per-site Windows-font → DOS-font map where ids differ (PROF Open 16; CORR 1 finding 5: the
  Civilopedia and the movies);
- I5 per scene (R3-7);
- classes of 141 and 5590 (R3-8);
- Find City form, Cancel / Go Back form, Hall of Fame "Clear", production advisors (now in L17
  as "listing work", but they are design choices);
- the city view layout generator (PROF Open 21);
- the busy pointer (hide, or the torch);
- the I4 timeout limit;
- the 6-bit to 8-bit palette rule (prompt 5.9; FORMATS 1 only records the viewer's `v*255/63` as
  "a viewer choice");
- the menu bar geometry (R3-2);
- input while the DOS intro shows and the core sits at its menu (R3-3).

Correction: add them as P entries with their source item and the phase that decides.

### Minor

**R3-11 (minor). PROF 4 W3.** The file choosers omit the host overwrite confirmation
(`host_confirm_overwrite`, phase-5-acceptance.md) that Save Game can show. Add it to W3.

**R3-12 (minor). PROF row 11 versus rows 79..84.** Dialog 130 is N in row 11, while its list use
(RunListBoxDialog from ShowCivilopediaSection) is R in rows 79..84. Say in row 11 that the entry
page is N and the list use is R (prompt 5.4 names list dialogs R).

**R3-13 (minor). CORR 3, setup row.** "(×1.6)" holds for the portrait origin (20, 100) → (32, 160)
but not for the step: DOS (2k, 3k) scales to (3.2k, 4.8k), Windows uses (3k, 4k) (**arith**).
Keep "proved" for the tribe name position only; label the portrait stack "inferred (scaled
origin); step differs".

**R3-14 (minor). CORR 3, title row.** "The first four item names are the same strings in the same
order" contradicts the same cell's "EARTH" versus "Play on EARTH". Items 1, 2, 4 and 5 match
(DGROUP:1AE2, **db.json strings**). Reword.

**R3-15 (minor). PROF 2.6 E21.** The Hall of Fame palette is given only for the title branch
(`LOGO.PIC` after the title). After the game (row 129, O3:0513) the DOS screen follows play, so
that palette is not stated. Add the case or an Open entry.

**R3-16 (minor). CORR 1 finding 7.** "Microsoft C versus Borland C `rand`, PC fact": the compilers
are file and listing facts. DOS DGROUP:645E.. holds the C run-time messages "R6000".. (DOS file /
db.json), and the Windows listing names Borland helpers (for example `SCOPY@` at 10E8:00D4).
Name the evidence. The DOS `rand` algorithm for a presentation-local generator must come from
the DOS listing in any case.

**R3-17 (minor). PROF 1.4 row 107.** Class A row "palette cycling and fades" includes the movie
fades of the N scenes (intro, Birth). Split them: map cycling A (TC), N-scene fades TX.

**R3-18 (minor). PROF row 2, timeline cell.** "Shown under T4 when the DOS intro ends first"
does not arise: the DOS intro ends last (about 68 s against 21.2 s). The real case is the core
waiting at dialog 139 while the DOS intro still runs (I4 for N, L, E, C; I6 otherwise). Say so.

**R3-19 (minor). CORR 11 New Cabinet row and PROF row 119.** The title position differs: DOS
(160, 102) (SP 7.10), Windows (160, 110) logical (showfunc 1138:01FF..0207). Prompt 5.4 says
"Record every difference". Add it.

**R3-20 (minor). OPEN P5, Detail.** "DRIVER.md G#11/G#16 notes" is the wrong citation: DRIVER
Open 1 (G#11/G#16) concerns the font-table offset. The colour switch is G#21 (FORMATS 2.3,
G:0000:0F9C; CORR Open 10). Fix the citation.

**R3-21 (minor). WI 0 (label **resource**) and 1.1, 1.2, 3, 5.** WI reads Windows facts from the
game files in `claude/port/build/gamedata/` with scratch parsers that import civdis `ne.py` and
`resources.py`. BRIEF-d0 names only `claude/docs` and showfunc as Windows sources (and showfunc
as the only runnable tool of `claude/tools`). The facts so obtained are header metadata (ids,
sizes, colour counts, hot spots, template sizes) and agree with resources.md and with my own
header read (which has the same deviation, see "How I worked"). Correction: the orchestrator
either ratifies this source for resource headers, or WI re-labels these rows "**docs**" where
resources.md states them and lists the rest as needing that ratification.

### Notes

**R3-22 (note). OPEN ordering.** P11 sits between P3 and P4; L17 between L14 and L15. Sorting by
number would help references.

**R3-23 (note). CORR 1 finding 9 can be upgraded.** The DOS Advisors and World menu strings
(DGROUP:2DD6, 2E32, 2E5D, 2EA5) carry F1..F10 next to each item name (**db.json strings**), so
the key-to-report pairing is proved by string, not only inferred from order.

**R3-24 (note). CORR 4 Birth pairing.** The per-picture text counts agree, not only the totals:
`STORY.TXT` 3, 3, 8, 5, 6, 8, 10, 1 (**DOS file**) and the Birth script's per-picture texts
(data-tables.md, WI 6.2). This strengthens the "inferred (counts)" pairing.

**R3-25 (note). SP 5.2 and SP Open 6.** The drawing order of the rates is a listing fact. Only
which DGROUP word (DF0E, B210) is tax and which is science is inferred; the DOS tax-rate dialog
(GAME menu, Tax Rate) should settle it cheaply.

**R3-26 (note). WI.** Every sampled WI claim agreed (21 of 21). WI is a sound inventory; its
gaps are R3-6 (probe list) and its own Open list, all registered.

## 3. Completeness

### SCENES.md

| Required item (prompt 6.5) | Status |
|---|---|
| Credits, intro, logo, title | present |
| Every Birth scene | present |
| Setup screens (difficulty, competition, tribe, names, intro text) | present |
| Menus, popups, text entry | present (bevel and frameless-bar look open, O4) |
| Per scene: pictures, palette, text sources, layout, timing, cycling, transitions, input | present; Hall of Fame line layout partial (SC Open 9) |
| Loading messages | partial (SC Open 6) |
| Labels on every DOS fact | present in all sampled sections |

### SCENES-PLAY.md

| Required item (prompt 6.5) | Status |
|---|---|
| Map: terrain, coasts, rivers, specials, improvements, units, cities, labels, unexplored edges | present |
| Minimap and status panel | present |
| Every full-screen scene of the counterpart table | partial: spaceship arrival partly read, conqueror mouths, combat spark drawing not traced, no DOS scene for 5590 or dialog 141 |
| Input on the play screen | partial (right button and key table, SP Open 3) |
| Timing in frames | present (model; SP Open 9) |

### WINDOWS-INVENTORY.md

| Required item (prompt 9 D0, 3, 8) | Status |
|---|---|
| 199 pictures with sizes, colours, loaders | present |
| Shape tables of graphics.md 4.9 | present |
| Fonts | present |
| 16 cursors | present |
| Dialogs and openers | present |
| Movies | present |
| Logical-layer call sites | present |
| Pixels read as data (picture 137, row 399, GetPortPixelIndex, GetPixel, opaque bounds) | present |
| Probe list (5.2 O2) | absent as a list (R3-6) |
| Windows sources within BRIEF-d0's list | partial: resource headers from `build/gamedata` (R3-21) |

### CORRESPONDENCE.md

| Required item (prompt 6.6) | Status |
|---|---|
| Each DOS presentation function paired or "none" | present (sections 2..15, 17) |
| Windows functions without a DOS counterpart | present (16) |
| Evidence and labels per pair | present; one wrong "proved" (R3-1), two imprecise rows (R3-13, R3-14) |
| Font numbers per site | partial (finding 5 notes the exceptions; no per-site map) |

### DOS-PROFILE.md

| Required item (prompt 5.4, 5.5, 5.6, 5.10, 8) | Status |
|---|---|
| Scene table: all 108 FEATURES rows | present |
| Scene table: every dialog template opened (19) | present |
| Scene table: every scene probe | present (33 rows) |
| Class per row | partial: 2 open (R3-8) |
| Timeline per row (T1..T7 codes) | present (R3-17, R3-18 wording) |
| Adapter per interactive row | present; per-scene I5 absent (R3-7); I-intro mouse wrong (R3-3) |
| Counterpart: 199 picture ids | present (38 rows) |
| Counterpart: shape tables, fonts, 16 cursors, palette effects | present (23 + 21, 17, 16, 24 + DOS-only) |
| "Never substituted" pictures (8) | present (0.5, 2.1) |
| Flow differences and static-text sources | present (3) |
| W list with reasons | present (4); host overwrite prompt missing (R3-11) |
| "W over N" cases (5.3) | absent (R3-4) |
| Character rule for Windows-1252 (5.10) | absent (R3-5) |
| Play layout stays Windows (class A) | present for the windows (row 96); menu bar uses DOS geometry (R3-2) |

### OPEN.md

| Required item | Status |
|---|---|
| Every Open item of the six documents and the other docs/dos files | partial (R3-9) |
| P group complete for D1 | partial (R3-10) |
| Citations correct | partial (R3-20) |
| Oracle-answerable items grouped (O) | present |

## 4. Verdict

The drafts in my scope are a sound base for D1 once the findings are applied. The inventory is
accurate on every sampled item. The scene and counterpart tables are complete in rows and
counts, and their DOS facts re-derive from the listing and the files. No blocker, no DOS bytes
and no memory-filled fact were found. Before D1 relies on them:
- correct the unit-sprite "same rectangles" claim (R3-1);
- move the menu bar to the Windows geometry (R3-2);
- fix the I-intro click (R3-3);
- add the W-over-N record and the Windows-1252 rule (R3-4, R3-5);
- fix the probe list (R3-6);
- close the two open classes (R3-8);
- complete OPEN, especially its P group (R3-7, R3-9, R3-10).

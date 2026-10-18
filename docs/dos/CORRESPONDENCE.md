# DOS to Windows correspondence (extension D0, prompt 6 item 6)

Draft of 2026-10-11 by agent D0-F (task D0-F). It pairs each DOS presentation function named in
the D0 drafts with its Windows function, or with none. The scene and counterpart tables of
[DOS-PROFILE.md](../DOS-PROFILE.md) use these pairings. Independent review R3 (`docs/verify/ext-d0-review-r3.md`) and the R1/R2 items in its scope
were applied on 2026-10-11 by fixer F3 (`docs/verify/ext-d0-fixes-r3.md`).

Inputs: the D0 drafts [EXECUTABLE.md](EXECUTABLE.md), [DRIVER.md](DRIVER.md),
[TIMING.md](TIMING.md), [FORMATS.md](FORMATS.md), [PALETTE.md](PALETTE.md),
[SPRITES.md](SPRITES.md), [SCENES.md](SCENES.md) (part 1), [SCENES-PLAY.md](SCENES-PLAY.md)
(part 2) and [WINDOWS-INVENTORY.md](WINDOWS-INVENTORY.md); on the Windows side `claude/docs`
(architecture.md, functions.md, subsystems/*.md) and `claude/tools/showfunc.py` output read in
this task. No DOS program was run. No DOS bytes are reproduced: DOS strings are named by their
DGROUP offset and at most a word or two.

Scratch (analysis only, not part of the docs): `build/dos/scratch-d0f/` (`winfuncs.txt` the
Windows function index, `fontsites.py` and `wf/` the showfunc dumps of the Windows call sites
compared below, `menus.txt` / `menus2.txt` the DGROUP menu strings read from the DOS listing database `build/dos/disasm/db.json`,
`dosfuncs-in-drafts.txt` the coverage list of section 17).

## 0. Conventions

* DOS addresses carry a prefix (`R:`, `O<n>:`, `G#n`, `M#n`, `S#n`, `DGROUP:`), as in
  `docs/verify/BRIEF-d0.md`. Windows addresses are NE `ssss:oooo` without a prefix.
* DOS names: a routine is named by the draft's description (for example "square drawer") or by
  the driver name of DRIVER.md 4 (for example `G#20 CopyRect`). Windows names are those of
  `claude/docs/functions.md`.
* Each DOS fact cites its draft section (for example `SCENES-PLAY 2.1`) and keeps that draft's
  label. Each Windows fact cites `claude/docs` (file and section), WINDOWS-INVENTORY (`WI` and
  section) or `listing` (showfunc output read in this task).

Pairing labels (column "Label"):

| Label | Meaning |
|---|---|
| **proved** | a shared table, string or constant ties the two routines; the Evidence column names it |
| **inferred** | the pairing rests on role, call structure, order of calls, equal counts or a scaled numeric match; the Evidence column says which |
| **none** | no counterpart was found; the routine is listed in section 15 or 16 |
| **open** | the drafts do not decide it; listed in the Open section |

Confidence (column "Conf."): high, medium or low, for the pairing itself, not for the DOS or
Windows facts it rests on.

"×1.6" means the Windows device value is the DOS logical value times 160/100 (ScaleLogicalX/Y
11E8:0D81/0DA8, graphics.md 4.7); "×2" the map and sprite-sheet doubling (graphics.md 4.9).

## 1. Main findings

1. **The sprite sheet.** O5:1455 and ExtractGameSpriteShapes (10E8:231F) cut the same tables at
   the same logical rectangles, except the units, which DOS cuts one pixel to the right
   (SPRITES 4, 6; WI 2.1): **proved** for the shared rectangles. DOS copies `SP257.PIC` rows
   160..191 to y 128 (G#20 at O5:1A14..1A32) and cuts unit j with G#2 at
   (16(j mod 20) + 1, 16(j div 20) + 129, 15, 15) (O5:19C5..19EE), that is `SP257.PIC`
   (16(j mod 20) + 1, 161 + 16(j div 20)) (DOS listing). Windows cuts
   T2(16(j % 20), 161 + 16(j / 20), 15, 15) with no +1 (listing 10E8:2931..2954), while its
   specials and sparks keep the +1 (10E8:288B, 28BF). Whether the Windows unit art is shifted by
   one column against the DOS art is unknown (OPEN.md P11). The DOS icon table DGROUP:D4CE and
   g_mapSprites (1420:9350) use the same indices (4..6, 8..15, 16..39, 64 + 32c + j): **proved**
   (section 13). (Corrected 2026-10-11, review R3-1.)
2. **The "Windows-only" sheet region is SP299.PIC art (inferred).** Four shape families cut by
   TileExtract at device x >= 1152 fall on SP299.PIC's page-2 art by one rule,
   device (x, y) = (2x + 832, 2y − 100): building icons (161 + 19c, 50 + 10r) → (1154 + 38c,
   20r); status bulbs and discs (160 + 8k, 120 / 128) → (1152 + 16k, 140 / 156); whole-square
   coasts (224 + 16j, 100) → (1280 + 32j, 100) = g_wholeTileShapes[1..6]; border tiles
   (192 / 224 + 8c, 120 / 128) → (1216 + 64b + 16c, 140 + 16 row) = g_windowFrameShapes
   (SPRITES 7; WI 2.1). So the Windows sheet is SP257 (left, ×2), TER257 x 0..255 (right
   half, ×2) and SP299 x 160..319, y 50..199 (×2). This contradicts the "Windows-only"
   reading of WI 2.1 and WI Open 11; it is a numeric match, not a pixel comparison (Open 1).
3. **Shared drawing rules of the map** (SCENES-PLAY 2.1..2.3; graphics.md 4.10; world.md 4.12):
   the six whole-square coast masks, the quarter mask formula, the river bit at (x, y + 150),
   the grassland marker rule `(7x + 11y) & 2`, the special and hut formulas (13, 11, the world
   seed), the road and railroad link rule, the city marker rules and the unit letters and
   flags are the same constants: **proved**.
4. **The message box.** The DOS box header number DGROUP:2F9E (0..2 report icons, 3..6 advisor
   portraits) is the Windows g_messagePicture (0..2 slices of picture 202, 3 and above advisor
   portraits) with the same seven captions: **proved** (SCENES-PLAY 0.2; ui-dialogs 2.4, 4.4).
5. **Font numbers.** At the newspaper and New Cabinet sites the Windows game font ids equal the
   DOS font numbers (5 masthead, 3 corner tag, 1 price and date, 2 slogan, 4 headline, 6 cabinet
   title, 2 portrait titles; SCENES-PLAY 7.7, 7.10; listing 1138:0000), and both keep the font
   number in word +10h of the drawing port (DRIVER 3.2; listing 10D8:01B0): **proved** there.
   It does not hold everywhere: the Civilopedia entry uses ids 4, 3, 7 where DOS uses fonts 6
   and 7 (listing 1068:0A07..0A96; SCENES-PLAY 7.13), and the intro and Birth movies use id 3
   where DOS uses fonts 5 and 7 (WI 6.1, 6.2; SCENES 4.3, 8.1).
6. **Many full-screen scenes share layout constants** with the logical layer: the report header
   lines at (160, 2), (160, 10), (160, 18); the power graph frame (4, 9, 311, 183); the palace
   labels at (48i − 36, 144) and (120j + 40, 160); the leader portrait rectangle
   (181, 67, 139, 133); the setup tribe name at (46, 92); the city-founded frames at
   (1, 16i + 1); the newspaper's 300-pixel masthead limit; the research-icon formula of the
   status panel: **proved** (sections 3, 10, 11).
7. **Different random generators.** The DOS full map redraw takes one C `rand` value and walks a
   256-step LCG `p = 5p + 1` (SCENES-PLAY 2.4); Windows DrawTilesToPort mode 1 makes n pair swaps
   with RandomBelow on the shared game generator (world.md 4; runtime.md 4.1). The orders differ;
   by prompt 5.4 the DOS renderer follows the core's order. The city view re-seeds the C
   generator with the sum of the city name's characters on both sides (SCENES-PLAY 7.2;
   runtime.md 4.1), but the libraries differ, so a DOS layout needs a presentation-local
   generator (DOS-PROFILE 0.6 rule 2; OPEN.md P20). The DOS program is built with Microsoft C:
   the run-time string "MS Run-Time Library" at DGROUP:0008 (EXECUTABLE.md 5) and the C
   run-time messages "R6000".. at DGROUP:645E (DOS file, `db.json` strings). The Windows game is
   built with Borland C++ 3.x (claude/docs README.md; Borland helpers such as `SCOPY@` named at
   10E8:00D4, listing). The DOS `random(n)` R:1DC4:005D returns (rand() · n) >> 15 (through
   R:2045:31DE and R:2045:32C0); `rand` R:2045:2AEA is a 32-bit LCG with its state at
   DGROUP:5C38 and returns the high word & 7FFFh (DOS listing). A presentation-local generator
   takes this algorithm from the DOS listing. (Evidence named 2026-10-11, review R3-16.)
8. **Text sections.** KING.TXT, HELP.TXT and ERROR.TXT sections pair with the Windows TEXT
   resources KNG_, HLP_ and ERR_ by name (for example INIT, NEWSA..NEWSN, D1..D6, PALACE, QUIZ),
   and the five substitution tokens are the same: **proved** (FORMATS 3.3; ui-dialogs 4.9;
   listing 11D0:01F7).
9. **Report keys.** The DOS function keys F1..F10 (SCENES-PLAY 6.3, 7.14) list the same reports
   in the same order as the Windows command codes 0x131..0x139 and 0x130 of MoveCivUnits'
   global switch, which no Windows key produces (unit-movement.md 4.10). The DOS Advisors and
   World menu strings (DGROUP:2DD6, 2E32, 2E5D, 2EA5, read at R:1C84:061B..0708) carry the key
   name next to each report name ("City Status (F1)" .. "World Map (F10)"), and those names are
   the Windows menu items 401..406 and 501..504: **proved** by string (upgraded 2026-10-11,
   review R3-23). The DOS profile translates them to the accelerators Ctrl+1..Ctrl+0
   (DOS-PROFILE 1.7).
10. **Status rates and the unit panel.** The status rates are drawn luxury, tax, science on both
    sides: DrawStatusCivPanels 1088:13D5 draws `lux = 10 − tax − sci` first, and the DOS rate
    menus (SCENES-PLAY 7.20) show that DGROUP:DF0E is the tax rate and B210 the science rate,
    with the same item texts and update rules as the Windows menus in MoveCivUnits
    (11F0:3BF5..3D3B and 11F0:3D48..3E7A, ShowTextDialog(text, 100, 80) at 11F0:3CFC and
    3E4A): **proved** (DOS listing, listing; review R3-25). The unit panel's "(n)" is the range
    of fuel-limited aircraft (DrawUnitInfoPanel 11F0:468C; SCENES-PLAY Open 5): **inferred**
    from the shared formula.

## 2. Start-up and intro

| DOS | Windows | Evidence | Conf. | Label | Differences |
|---|---|---|---|---|---|
| R:01A8:0008 `main` (EXECUTABLE 5; SCENES 1) | WinMain 1008:0000 | both run the start-up, the intro and title, then the game loop (architecture.md 3.3) | medium | inferred | DOS loads `misc.exe`, asks the set-up questions and loads the drivers first |
| O1:0000 text-mode set-up screen (SCENES 2) | none | DOS-only | high | none | omitted by the profile (DOS-PROFILE 3) |
| O2:0000..0150 loading messages, driver loading (SCENES 3; DRIVER 1.1) | none | DOS-only | high | none | omitted |
| O2:01C8..09D4 intro: panorama loops A (O2:03D4..0442) and B (O2:06BF..0794) (SCENES 4.2) | RunIntroAndTitleMenu 11E0:0000 with movie 13D0:0000 item 11 Scroll (AdvanceMovie 10B0:0461) | the same art: `BIRTH0` + `BIRTH1` rows 0..175 (640x176 logical) and picture 128 (1024x320 = 640x200 ×1.6) (SCENES 4.2; WI 1.2, 6.1) | high | inferred (role, scaled size) | DOS pans two pictures by the sound tick, 5.25 ticks per column, with black bands and a strip; Windows scrolls one picture one pixel per 2 frames with fades |
| O2:19A3 credit line reader; cue table O2:0522..0995 (SCENES 4.3; TIMING 5.3) | movie Text items STR# 137 #2..#10 (WI 6.1) | role | medium | inferred | 24 `CREDITS.TXT` lines in a middle band, font 5, three layers (248, 250, 252) versus nine STR# texts |
| O2:0A19..0BD6 logo: wait, strip reveal, hold, dissolve (SCENES 5) | IntroMovieCallback 11E0:0221 case 3 and items 1180..1240 (WI 6.1) | role: the logo after the pan | high | inferred | strip reveal, hold and `G#10` dissolve versus palette fades |
| O2:04C1, O2:082A, O2:09D7..0A51 skip and shortcut keys (SCENES 4.4) | IntroMovieCallback skip test (frame % 20, input pending) (WI 6.1) | role | high | inferred | DOS: keys only; N, L, E, C preselect title items 0..3; Windows: any input, seek to 1164 |
| O2:02F4, O2:0AA0 intro and logo cycling (PALETTE 4) | none (movie item 14 never used, WI 6.5) | – | high | none | DOS-only effect |

## 3. Title and setup

| DOS | Windows | Evidence | Conf. | Label | Differences |
|---|---|---|---|---|---|
| R:01A8:0486 title menu and branches (SCENES 6) | IntroMovieCallback 11E0:0221 case 2 (dialog 139, MenuZ 1220:0156) | DGROUP:1AE2 holds five items; items 1, 2, 4 and 5 are the same strings as the Windows items in the same places, item 3 reads "EARTH" against "Play on EARTH" (`db.json` strings, SCENES 6; FEATURES title rows) | high | proved | DOS: five items, no Quit, a menu box at (100, 140) over the logo; Windows: six items with Quit |
| R:01A8:0511..058E New Game branch (SCENES 7.1) | IntroMovieCallback → BeginWorldCreation 1108:01BC | role | high | inferred | DOS keeps the menu box on screen until the first Birth fade |
| O11:0000, O11:0103, O11:05F8 Load: drive prompt and ten slots (SCENES 7.2) | LoadGameFromFileDialog 1130:000E (game-flow.md 3.1) | role | high | inferred | DOS drive letter and `CIVIL0..9.SVE`; Windows file dialog (civ64: host dialog) |
| R:01A8:0795..07BA EARTH branch (SCENES 7.3) | IntroMovieCallback → GenerateWorldMap 1028:0000 with picture 137 | role; `MAP.PIC` and picture 137 are both the EARTH data (WI 8 #1) | high | inferred | DOS loads `MAP.PIC` with its palette while the title is visible |
| R:01A8:0591..0792 Customize: four menus (SCENES 7.4) | CustomizeWorldDialog 1108:0243, CustomizeWorldWndProc 1108:0705 | help topics DGROUP:1B6A, 1B94, 1BBD, 1BFE name the same four topics as the Windows ShowHelpNote topics "Land", "Temperature", "Climate", "Age" (ui-dialogs 3.1) | high | proved | four sequential menus without Cancel versus one dialog with OK and Cancel |
| O3:002B read `FAME.DTA` (SCENES 7.5) | LoadHallOfFame 1080:0023 | role | high | inferred | – |
| O3:00D7 Hall of Fame screen (SCENES 7.5; SCENES-PLAY 7.17) | ShowHallOfFame 1080:0119 | role; argument −1 means "view" on both sides (game-flow.md 3.1) | high | inferred | DOS white screen and text; Windows picture 5600 |
| O3:0513 Hall of Fame after the game (SCENES-PLAY 7.17) | InsertHallOfFameEntry 1080:0595 | role | medium | inferred | DOS "Clear" box (SCENES 7.5) |
| R:01A8:087C setup preparation, `DIFFS.PIC` (SCENES 9) | RunNewGameSetup 10E8:0000 (picture 141, dialog 144) | role | high | inferred | – |
| O5:0000 setup questions O5:0031..0587 (SCENES 9.1..9.3) | RunNewGameSetup steps 0..3 (listing 10E8:0000) | the tribe plural name centred at logical (46, 92) in white (DOS colour 15): **proved**. The stacked portraits: DOS (20 + 2k, 100 + 3k), Windows (32 + 3k, 160 + 4k); the origin scales by 1.6 ((20, 100) → (32, 160)) but the step does not (DOS (2k, 3k) would give (3.2k, 4.8k)): **inferred** (scaled origin; step differs; review R3-13) | high | proved (name); inferred (portraits) | DOS Escape picks a random slot and asks the tribe name; Windows has a "Custom." item and Go Back |
| O23:0173 tribe name, O23:00D6 leader name (SCENES 9.4, 9.5, 10.4) | RunTextInputDialog 1220:16FD (setup steps 3, 4) | role; the same order (tribe, then leader) | high | inferred | DOS limits 11 and 13 characters |
| O5:0657..07BD introduction text (SCENES 9.6) | RunNewGameSetup → dialog 151 with TEXT KNG_INIT | section name INIT on both sides (SCENES 9.6, 9.7) | high | proved | DOS white screen, border, portrait |
| O5:1AF6 government pictures into pages 1 and 2 (SPRITES 7) | LoadAdvisors 10E8:31AA, GetCourtStyle 1160:3487 | the same selection rule: government 3 alone, otherwise government / 2, modern variant after advance 14h (listing 1160:3487) | high | proved | DOS file `govt<d><a/m>`; Windows picture 400 + style |
| R:01A8:02A4 disk check and prompt (SCENES 10.3) | none | DOS-only | high | none | omitted |

## 4. Birth

| DOS | Windows | Evidence | Conf. | Label | Differences |
|---|---|---|---|---|---|
| O7:0012 world generation with the story (SCENES 8.1; TIMING 5.5) | BeginWorldCreation 1108:01BC, GenerateWorldMap 1028:0000 | both advance the Birth presentation from inside world generation (WI 6.2) | high | inferred | – |
| O7:17CF story step (SCENES 8.1, 8.2) | BirthMovieCallback 11E0:091E; AdvanceMovie 10B0:0461 (script 13D8:0000) via UpdateActiveAnimation 1098:0157 | equal counts: 44 text lines and 8 pictures (`STORY.TXT`; STR# 139 #1..#44, pictures 128..135) (FORMATS 3.5; WI 6.2), and the same texts per picture, 3, 3, 8, 5, 6, 8, 10, 1, on both sides (`STORY.TXT`, DOS file; the Birth script, data-tables.md and WI 6.2; review R3-24) | high | inferred (counts per picture) | DOS schedule by the sound tick against R:2710:0083; 8-step fades through black; text at (160, 160) in colours 3 then 11 |
| O7:1A39, O7:1A93 Birth fades (PALETTE 3) | movie FadeOut and FadeIn items (WI 6.2) | role | high | inferred | 8 steps (48 frames) on 256 entries versus 40 steps over 100 movie frames on 0..223 |
| O7:1AF0..1B27 Birth cycling, table R:2710:0000 (PALETTE 4) | none | – | high | none | DOS-only effect |
| O7:1820..1847 "BUILDING NEW WORLD..." (SCENES 8.4) | none | – | high | none | DOS-only message |

## 5. Generic UI

| DOS | Windows | Evidence | Conf. | Label | Differences |
|---|---|---|---|---|---|
| R:1D05:0031 menu box, entries R:0238:0008, R:0238:001E, R:1D05:0000, R:1D05:0018 (SCENES 10.1) | MenuZ 1220:0156 through ShowTextDialog 1220:00D2 | header table: DGROUP:2F9E 0..2 report icons and 3..6 advisor portraits with titles (DGROUP:2FA6) versus g_messagePicture 0..2 picture-202 slices and 3 and above advisor portraits with g_messagePictureCaptions, the same seven captions (SCENES-PLAY 0.2; ui-dialogs 2.4, 4.4; advisors.md 2.2) | high | proved | DOS items are lines with a leading space or "_"; Windows splits at "_"; DOS Escape returns −1, Windows returns the checked index; DOS uses the x, y passed, ShowTextDialog ignores them |
| R:1D05:0475 box drawer, `(HELP AVAILABLE)` line, OK box (SCENES 10.1) | MenuZ steps 3..14, MenuZSubclassWndProc 1220:1289; dialog 145 Help button | role | high | inferred | DOS highlight by RecolourRect; Windows RanDoMRadio controls |
| R:1D05:096C box, R:1D05:0A66 bevel, R:1D05:0A05 outline, R:1DC4:03CE texture, R:0238:1BB2 panel (SCENES 0.2; SCENES-PLAY 0.1) | DrawSunkenPanel 11F8:0278, DrawSunkenFrame3 1220:0D38, FrameRectLogical 1220:1086, TileShapeInPort 10D0:0BEE; DrawTwoToneRect 1220:120A (dead) | role; DrawTwoToneRect groups the edges like the DOS bevel (top and right in one colour, bottom and left in the other; graphics.md 4.7) | medium | inferred | DOS stone texture from page 2; Windows grey panels |
| R:0238:0FEA menu bar; R:1C84:0000 drop-downs; R:1C84:0615, 06E4, 07AF menus (SCENES 10.2; SCENES-PLAY 5.1) | MENU 128 and HandleMenuCommand 1048:01CD (platform.md 2.5, 4) | item lists: GAME DGROUP:2BD4 has the File items 102, 103, 104, 101, 113, 114, 115 (plus Options); Options DGROUP:2C3E has the eight items of 105..112 in the same order; Advisors DGROUP:2DD6, 2E32 = 401..406; World DGROUP:2E5D, 2EA5 = 501..506; Civilopedia DGROUP:2ED1, 2F25 = 601..606 (DOS listing: `db.json` strings referenced from R:1C84; spellings differ in a few items) | high | proved | DOS has no Edit, City and Help menus; Windows has no View Replay item (DGROUP:2C30) |
| ORDERS menu built at run time (R:1C84, strings DGROUP:2D05..2D91) | UpdateOrdersMenu 1120:0000, commands 301..318 | role | medium | inferred | item list not decoded in the drafts (Open 6) |
| O4:0000 help screen (SCENES 10.3; SCENES-PLAY 7.18) | ShowHelpNote 10E0:0000 (dialog 135) | shared colours: background EGA 2, title 0, text 15; `HELP.TXT` sections and TEXT HLP_<topic> (ui-dialogs 4.9) | high | proved | DOS fills the whole screen; Windows a centred dialog |
| O4:02D3 instant advice (SCENES-PLAY 7.18) | ShowInstantAdvice 10E0:077F | the same condition (option bit, BC years) and the same note title (ui-dialogs 4.9) | high | proved | DOS box colour 2, outline 10 |
| O4:03AA error note (SCENES-PLAY 7.18) | ShowErrorNote 10E0:07E8 | `ERROR.TXT` and TEXT ERR_<topic>; the same note title | high | inferred | DOS colour 4, outline 12 |
| O23:0414 text field, O23:06C1 character cells (SCENES 10.4) | EDIT controls of RunTextEntryDialog 10F0:0066 and RunTextInputDialog 1220:16FD | role | high | inferred | DOS blinking cell cursor; Ins inserts a space; a click accepts |
| O23:0000 city name box (SCENES 10.4) | PromptCityName 10F0:0000 → RunTextEntryDialog (dialog 137) | role | high | inferred | 12 characters |
| O23:0319 find city: typed name (SCENES 10.4) | ShowFindCityDialog 1068:004C → RunListBoxDialog 1098:1909 (dialog 131) | role (listing 1068:004C) | high | inferred | DOS types a name; Windows chooses from a sorted list |
| R:1459:0918 wait for a key or a click (SCENES 0.3) | WaitForKeyOrClick 1038:0C1D | role | high | inferred | Windows stores the click as `lParam*10/16` with an unsigned shift (listing 1038:0CB6..0CDA) |
| R:0866:25B6, R:0866:25D7, R:0ADE:0394, R:0ADE:03BF save and restore the screen (SCENES 0.2; SCENES-PLAY 0.1) | GR_DialogOpen 1098:124F / GR_DialogClose 1098:1612, RestoreMapAfterDialog 1208:14D5 | role | medium | inferred | – |
| R:0866:260E ornamental border (SCENES 0.2, 9.6; SCENES-PLAY 7.17) | DrawWindowFrame 1098:21B8, DrawWindowFrameTiles 1098:2260 | the rating screen uses both (SCENES-PLAY 7.17; listing 1080:06FF); the tile rectangles match by the sheet rule of finding 2 | medium | inferred | DOS tile choice through R:1DC4:005D (SCENES Open 8) |

## 6. Map squares

| DOS | Windows | Evidence | Conf. | Label | Differences |
|---|---|---|---|---|---|
| R:1AEA:03BA square drawer (SCENES-PLAY 2.1) | ComputeTileAppearanceKey 1118:04B4, RenderTileFromKey 1118:0000, DrawMapTile 1110:04D0 | coast masks 1Ch, C1h, 07h, 70h, 8Fh, F8h as patterns 1..6; quarter mask `(mask << 2) + ((mask >> 6) & 3)`; river +16 from (x, y + 150) & 8; grassland marker for terrain 2 when `((7x + 11y) & 2) == 0`; road dot colours 0 and 6; railroad link when both squares have bits 11h (graphics.md 4.10) | high | proved | DOS draws to the screen with a land base (page 2 (256, 120)) and no cache; Windows composes a cached 32x32 tile |
| R:1AEA:1836 special resource (SCENES-PLAY 2.1) | HasSpecialResource 1110:1C72 | `(x >> 2)·13 + (y >> 2)·11 + seed`, `(x & 3)·4 + (y & 3)`, rows 2..47 (world.md 4.12) | high | proved | – |
| R:1AEA:1894 hut (SCENES-PLAY 2.1) | HasHut 1110:1CD9 | the same value + 8 compared with `& 31`, not ocean, visibility bit 0, no city | high | proved | – |
| R:1AEA:134A terrain from page 2 (SCENES-PLAY 1.1) | GetTerrainType 1110:16C0 | role | medium | inferred | – |
| R:1AEA:1585 improvements; R:1AEA:15C1 known improvements (SCENES-PLAY 1.1) | GetTileImprovements 1110:199B; GetKnownTileImprovements 1110:19E0 | the same page layout: (x, y + 100) + (x, y + 150) << 4; known at (x + 80, ...) | high | proved | – |
| R:1AEA:14E0, R:1AEA:1369, R:1AEA:138C occupancy (SCENES-PLAY 1.1) | GetTileOwner 1110:16EE, SetTileOwner 1110:171F, MarkTileOccupied 1110:1906 | the same byte (x + 160, y): bit 3 units present, bits 0..2 civilization | high | proved | – |
| R:0866:25F8 page-2 read (`G#14`); R:1AEA:17CF page-2 write (SCENES-PLAY 1.1) | GetScreenBufferPixel 11E8:0DCF; SetScreenBufferPixel 11E8:0E19 | the same 320x200 data page (WI 8 #9) | high | proved | DOS keeps art in the same page (x 160..319, y 50..199) |
| R:1AEA:0008 full redraw (SCENES-PLAY 2.4) | SetMapViewAndRedraw 1110:03E9 → RedrawMapWindow 1208:17DA → DrawTilesToPort 1208:1866 mode 1 | role | high | inferred | DOS: `random(256)` then `p = 5p + 1` over 16x16; Windows: n pair swaps with RandomBelow on the game generator (world.md 4); DOS also redraws the menu bar and the status panel |
| R:1AEA:0008 label step (SCENES-PLAY 2.3, 2.4) | CollectVisibleCityLabels 1208:1DD7, DrawCityLabels 1208:1F64 | role; at most 32 labels on both sides (world.md 4) | high | inferred | DOS colour 11 at (clamp(px − 8, 80, 999), py + 16), truncated; Windows font 8, yellow (EGA 14), centred under the square |
| R:1E31:119B x wrap (SCENES-PLAY 2.1) | WrapMapX 1128:177E | role | high | inferred | – |
| R:0403:0371..0433 keep in view and recentre; R:0866:16A9 (SCENES-PLAY 3) | EnsureSquareInMapView 11C0:231D, CenterMapViewOn 1110:03AE | recentre origin (x − 7, y − 6) for 15x12 squares and (x − cols/2, y − rows/2) (listing 11C0:231D) | medium | inferred | different margins of the keep-in-view test |
| R:0403:06B4..06F0 map click (SCENES-PLAY 3) | WdwMapProc 1208:0054, PollMouseClick 1108:0000 | role | medium | inferred | – |

## 7. Units

| DOS | Windows | Evidence | Conf. | Label | Differences |
|---|---|---|---|---|---|
| R:1AEA:11D4 square and top unit (SCENES-PLAY 2.2) | RedrawMapSquare 1110:1461 | role | high | inferred | – |
| R:1AEA:1458 find unit; R:1AEA:125B ship on an ocean stack (SCENES-PLAY 2.2) | FindUnitAtTile 1110:180E; DrawUnitStack 1110:1516 | the same rule: on ocean a ship (domain 2) is shown (listing 1110:1516) | high | inferred | – |
| R:1AEA:0E29 unit with stack shadow (SCENES-PLAY 2.2) | DrawUnit 1110:0DBA | stack shadow at logical (+1, +1) and device (+2, +2); a land unit with status bit 0 on ocean is hidden (listing 1110:0DBA) | high | proved | – |
| R:1AEA:0FB3 unit shape and marks (SCENES-PLAY 2.2) | DrawUnitAt 1110:0FF6 | shape index 64 + 32·civ + type; flag 8 → shape 29; flag 4 → "F"; goto → "G"; flags 2, 40h, 80h → R, I (type 0) or ?, M, F, P with a framed box (listing 1110:0FF6) | high | proved | sentry: DOS recolours 5 and 8 to 7; Windows replaces the civ colours by EGA 8 and 7 |
| R:0866:0AD6 blink (SCENES-PLAY 6.1) | BlinkActiveUnitUntilInput 11C0:0EC2, PlotSmMapSquare 1210:07AE | role; minimap square white in the hidden phase (listing 11C0:0EC2) | high | inferred | DOS 10 + 10 frames (1 with a key waiting); Windows a 1 s cycle; land colour 2 (DOS) versus 6; "End of Turn" 7/0 versus 14/0 |
| R:0866:1D55 move animation (SCENES-PLAY 6.2) | AnimateUnitMove 11C0:2C32 | role; the next stack member is drawn on the origin, on ocean only a ship (listing 11C0:2C32) | high | inferred | DOS 17 frames of 1 pixel; Windows 9 frames of 4 device pixels |
| R:0403:4508 both squares visible (SCENES-PLAY 6.2) | IsMapSquareOnScreen 11F0:4E26 | role | medium | inferred | – |
| R:0866:1F69 unit stack popup, from the map click R:0403:0C42 (SCENES-PLAY 7.19) | ShowUnitStackDialog 11C0:3023 (dialog 141, from MoveCivUnits 11F0:0BFA), DrawUnitStackList 11C0:3407, RunUnitStackDialogLoop 11C0:3644 | the same wake rule (flags C2h, moves := 3 × the type's moves, flags &= 30h, goto := FFh), the name with " (V)" in colour 15 and the home city in colour 14 (DOS listing R:0866:2209..2248; listing 11C0:3023..3644) | high | proved | DOS box at (100, 96 − 8n) with rows 16 apart, at most 12 units, keys Up/Down/Return/Space/Escape; Windows dialog rows 20 apart (added 2026-10-11, review R3-8) |
| combat sparks DGROUP:D50E (users not traced, SPRITES 6.3 and Open 3) | ResolveCombat 1050:0A9C..0AEA (g_mapSprites[32 + frame]) | the same rectangles (16i + 1, 97, 15, 15) (WI 2.1) | high | proved (shapes); the DOS drawing routine is open | Open 4 |

## 8. Cities

| DOS | Windows | Evidence | Conf. | Label | Differences |
|---|---|---|---|---|---|
| R:1AEA:03BA city layer (SCENES-PLAY 2.3) | DrawMapTile 1110:04D0 city marker (graphics.md 4.10.4) | a foreign city with known size 0 is skipped; real size for own cities, else known size; civil disorder draws citizen shape 4 instead of the size; units or a stored unit add an inner outline; walls (bit 80h) shape 29; city overlay shape 28 | high | proved | DOS fills 12x12 in the main colour with a 1-pixel white and secondary outline; Windows 26x26 with 2-pixel pens |
| R:0D12:0045 city screen (SCENES-PLAY 7.1) | ProcessCity 1030:0000, DrawCityScreenTitle 1030:8B39, CityScreenWndProc 1030:9C17, ShowCityScreen 1170:05AF | the key codes a, c, b, v, r, i, h, m are DOS keys and the codes the Windows City menu 701..708 queues (architecture.md "Commands become keys") | high | proved | DOS layout and tabs at DOS positions; Windows device layout in dialog 148 |
| R:0D12:7045 building icons (SCENES-PLAY 7.1; SPRITES 7) | DrawImprovementIcon 1030:8529, DrawImprovementIconLogical 1030:84BE | the same grid: icon n < 40 in column n div 5, row n mod 5, then two icons on a last row (g_improvementIcons[5c + r], [40], [41]; WI 2.1) | high | proved | – |
| R:0D12:710D city panel background (SCENES-PLAY 7.1) | DrawCityPanelBox 1030:895C | role | medium | inferred | DOS water texture page 2 (208, 100) |
| R:1F4D:04F7 truncate to a width (SCENES-PLAY 2.4) | TruncateStringToLogicalWidth 11D0:02E4 | role | medium | inferred | – |
| R:1459:08C6 city name (SCENES-PLAY 2.4) | AppendCityName 1038:0BBA | role | medium | inferred | – |
| R:0ADE:03EA, R:0ADE:0093, R:1459:0597 city screen callers (SCENES-PLAY 7.1) | ShowCityScreen 1170:05AF and the ProcessCity callers | role | medium | inferred | – |
| O19:0000 city view (SCENES-PLAY 7.2) | ShowCityView 11B0:0000 | both seed the C generator with the sum of the city name's characters (runtime.md 4.1) | high | proved | DOS 19x12 grid on `HILL.PIC`; Windows picture 3333 layout; different `rand` |
| O19:13A1..145F houses and roads; O19:14FB..1536 buildings (SCENES-PLAY 0.3, 7.2) | LoadCityViewSprites 11B0:1653 | buildings by (i div 4, i mod 4) on both sides; the second building picture after advance 25h / 0x25 (WI 1.2) | high | proved | – |
| `POP.PIC` citizens in the view (SCENES-PLAY 7.2) | DrawCityViewCitizens 11B0:1316 | role | medium | inferred | – |
| O19:167B invaders (SCENES-PLAY 7.3) | PlayCityCaptureAnimation 11B0:1B63 | the picture by advances 22h and 3Ah, three pictures; eight figures (listing 11B0:1B63) | high | proved | DOS 220 frames, 3 pixels per frame, 1 per 10 frames; Windows 142 frames at 10 per second |
| O19:18C1 civil disorder (SCENES-PLAY 7.3) | PlayCivilDisorderAnimation 11B0:1FAC | the picture by advance 0Dh; four figures (WI 1.2) | high | proved | – |
| O19:1AE1 celebration (SCENES-PLAY 7.3) | PlayCelebrationAnimation 11B0:237C | the picture by advance 23h; four figures (WI 1.2) | high | proved | – |
| O22:0EAF city founded (SCENES-PLAY 7.4) | ShowCityFoundedAnimation 11B8:14E5 | four frames at (1, 16i + 1) on both sides (Windows y scaled 192/100; WI 2.2); the caption "<city> founded" | high | proved | DOS ends with a fade (10 steps) or the city view with a fade-in |
| R:0ADE:0421 production menu (SCENES-PLAY 7.12) | ChooseCityProduction 1170:05CA (dialog 140) | role; help opens the Civilopedia (ui-dialogs 3.1) | high | inferred | DOS advisor boxes (option bit 1) with `PRODUCE.TXT` (Open 7) |
| O20:0540 disasters and city events (SCENES-PLAY 7.6) | ProcessCityDisaster 1040:068E | a case of 10 random cases; KING sections D1..D6 and TEXT KNG_D1..D6 (listing 1040:068E) | high | proved | DOS box with a header icon at (100, 80) or (100, 64) |
| O20:047C founding caller of O22 (SCENES-PLAY 7.4) | FoundCity 1040:0000 | role | medium | inferred | – |

## 9. Minimap

| DOS | Windows | Evidence | Conf. | Label | Differences |
|---|---|---|---|---|---|
| R:1AEA:0008 minimap part (01A0..03B0) (SCENES-PLAY 4) | DrawSmTiles 1210:09B4, RedrawSmMap 1210:073F | role; city dots in the owner's main colour for the player's cities or a known size (graphics.md 4.11) | high | inferred | DOS copies the 80x50 page-2 image with an offset and frames 15x9 squares (defect inferred); Windows draws the whole world and frames the real view |
| R:1AEA:17FF minimap city pixel (SCENES-PLAY 4) | DrawSmTiles step 5 | role | medium | inferred | – |
| R:0403:073A..0781 minimap click (SCENES-PLAY 3) | CenterMapOnSmMapClick 1210:056E | role | high | inferred | DOS offsets by (7, 14) from the click |

## 10. Status and unit panels

| DOS | Windows | Evidence | Conf. | Label | Differences |
|---|---|---|---|---|---|
| R:0238:107E status panel (SCENES-PLAY 5.2) | DrawStatusCivPanels 1088:13D5, RedrawStatusWindow 1218:0801 | research icon `clamp(4·progress / ((2·difficulty + bonus + 6)·count·(1 BC, 2 AD) + 1), 0, 3)`; warming icon `clamp(level / 4, 0, 3)`; peace bar when the counter > 1; the "#" and "$" suffixes; rates as luxury.tax.science with luxury = 10 − tax − science; the population message DGROUP:1DA5 (listing 1088:13D5) | high | proved | DOS bar 2 per turn, Windows 3; DOS sky fill colour 11 |
| R:0238:14A3 mini palace (SCENES-PLAY 5.2; SPRITES 6.2) | DrawMiniPalace 1088:1A82 | the private LCG `v = 5v + 1` seeded with civ × world seed; entry `(level − 1 clamped 0..3)·5 + kind` (graphics.md 4.16) | high | proved | DOS strips 7x15, Windows 7x16 |
| R:0238:1720 year text (SCENES-PLAY 5.2) | AppendGameYearText 1088:1DD0 | role | high | inferred | – |
| R:0403:35CE tax rate menu, R:0403:36B9 luxuries rate menu (SCENES-PLAY 7.20) | MoveCivUnits 11F0:3BF5..3D3B (keys `+`, `=`) and 11F0:3D48..3E7A (keys `-`, `_`): ShowTextDialog(text, 100, 80) at 11F0:3CFC and 3E4A | the same keys, headers and item texts ("Select new Tax rate:", "% Tax, (", "% Science)"; "Select new Luxuries rate:", "% Luxuries, ("), the same item ranges (0..tax + science; 0..10 − tax), defaults and updates (listing 11F0:3BF5..3E7A; DOS listing) | high | proved | DOS draws the box at (100, 80); ShowTextDialog ignores the position (added 2026-10-11, review R3-25) |
| R:1DC4:02CD population; R:1DC4:0337 format (SCENES-PLAY 5.2) | ComputeCivPopulation 11C8:0334 | role | medium | inferred | – |
| R:0238:16E7 palace threshold (SCENES-PLAY 7.8) | the palace call in ProcessGameTurn (1088:087F) | role | low | inferred | – |
| R:0403:4060 unit panel (SCENES-PLAY 5.3) | DrawUnitInfoPanel 11F0:468C | the same lines in the same order (adjective, type, "Veteran" 4 pixels further right, "Moves: n.r", the range in parentheses, home city, terrain, improvements, stack shapes) and the three end-of-turn lines (listing 11F0:468C) | high | proved | second end-of-turn line: "Press Enter" (DOS) versus "Press Return" |

## 11. Full-screen scenes

| DOS | Windows | Evidence | Conf. | Label | Differences |
|---|---|---|---|---|---|
| O14:0000, O14:001C report frame; O14:013B close (SCENES-PLAY 7.14) | OpenReportScreenWithHeader 1018:0000, DrawReportHeader 1018:015D, CloseReportScreen 1018:0380 | lines centred at (160, 2), (160, 10), (160, 18) (listing 1018:015D) | high | proved | DOS title in the current font without shadow; Windows font 7 with shadow |
| O14:186F City Status (F1) | ShowCityStatus 1018:208F | role; F1 and code 0x131 | high | inferred | – |
| O14:03AD, O14:061F Military (F2) | ShowMilitaryReport 1018:067B, DrawCasualtyReport 1018:09CC | role | high | inferred | – |
| O14:0D43, O14:1164 Intelligence and dossier (F3) | ShowIntelligenceAdvisor 1018:1221, DrawCivDossier 1018:17DB | role | high | inferred | background 1 (DOS) versus 0 |
| O14:15F4 Attitude (F4) | ShowAttitudeAdvisor 1018:1D5B | role | high | inferred | – |
| O14:07F1 Trade (F5) | ShowTradeReport 1018:0BE0 | role | high | inferred | – |
| O14:014B Science (F6) | ShowScienceReport 1018:03F0 | role | high | inferred | – |
| O12:080D Wonders (F7) | ShowWondersOfTheWorld 1188:0B3E | role | high | inferred | – |
| O3:09AC Top 5 Cities (F8) | ShowTopFiveCities 1080:099B | rows 32 pixels apart from y 32 (listing 1080:099B) | high | proved | background 3 (DOS) versus 0 |
| O20:0CA9 score, O20:13F8 icons (F9) | ShowCivilizationScore 1040:1137, DrawScoreCitizenIcon 1040:1B51 | role | high | inferred | – |
| O12:0000 World Map (F10) | ShowWorldMap 1188:013F | role | high | inferred | DOS 4x4 tiles from page 2; Windows 6x6 squares |
| O12:0D6D Demographics | ShowDemographicsReport 1188:123A, DrawDemographicsRank 1188:220A | thirteen rows on both sides (WI 7.3) | high | inferred | background 1 versus 0 |
| O12:09E2 historian (SCENES-PLAY 7.15) | ShowHistorianReport 1188:0DB8 | a mini palace per row on both sides (graphics.md 4.16) | high | inferred | DOS 60-frame wait per row |
| O12:0573 power graph (SCENES-PLAY 7.17) | ShowPowerGraph 1188:07AD | frame (4, 9, 311, 183); year labels in font 2 (listing 1188:07AD) | high | proved | DOS background 8, title at (100, 2); Windows black, centred (160, 2) |
| O8:0000 Civilopedia index; R:1C84:07AF its menu (SCENES-PLAY 7.13) | ShowCivilopediaSection 1068:0295, RunListBoxDialog 1098:1909 (dialog 130) | role; the same six sections (section 5) | high | inferred | SCENES-PLAY spells the Windows name "ShowCiviliopediaSection" |
| O8:062A Civilopedia entry; O8:16C4, O8:16F7 cell copy (SCENES-PLAY 7.13; SPRITES 8) | ShowPediaEntry 1068:06AF, AnimateTileZoomInRect 1068:1C13, ShowCivilopediaEntry 1020:0000 | role; one cell of a picture sheet per entry on both sides | high | inferred | DOS name font 6, category font 7; Windows ids 4, 3, 7; Windows zoom animation |
| R:0238:1767 caller of O8:062A (SCENES-PLAY 7.13) | MoveCivUnits right click → ShowCivilopediaEntry kind 3 (ui-dialogs 3.1) | role not traced | low | open | Open 5 |
| O21:0000 newspaper (SCENES-PLAY 7.7) | ShowNewspaper 1138:0000 | four masthead forms with the fallback over 300 pixels; fonts 5, 3, 1, 2, 4 at the corresponding items; KING sections NEWSA..NEWSN and TEXT KNG_NEWS + letter (listing 1138:0000) | high | proved | DOS torn edge from DGROUP:DF0C shapes; Windows pen lines; both draw random numbers |
| O5:1BA2 New Cabinet (SCENES-PLAY 7.10) | ShowNewspaper(−2) from AnnounceGovernmentChange 10E8:32C1 | "New Cabinet" in font 6, four portraits with titles in font 2 (listing 1138:0000) | high | proved | the title position: DOS (160, 102), Windows (160, 110) logical in colour 0 (listing 1138:01FF..020A; review R3-19) |
| R:1517:04A1 government change (SCENES-PLAY 7.10) | SetGovernment 1168:06C1, AnnounceGovernmentChange 10E8:32C1 | role | high | inferred | – |
| R:0ADE:1584 discoveries (SCENES-PLAY 7.11) | CompleteResearch 1170:21B3 (dialogs 146 / 147), GiveAdvance 1170:2AAA | the second scientist picture after advance 36h / 0x36; "wise men" before advance 14h / 0x14 (WI 1.2; listing 1160:3487 notes) | high | proved | DOS fade-in of 30 steps |
| O16:0000 quiz (SCENES-PLAY 7.15) | RunCivilizationQuiz 1178:0000, AskCivilizationQuizQuestion 1178:0022 | sections QUIZ and QUIZ2; a second wrong answer removes the units (listing 1178:0000) | high | proved | – |
| O17:0000 palace improvement; O17:07EC composer (SCENES-PLAY 7.8) | RunPalaceImprovement 1158:0000; OpenPalaceView 1158:08E7, LoadPalaceSectionSprites 1158:14B7 | the PALACE section; section labels at (48i − 36, 144) and garden labels at (120j + 40, 160) (listing 1158:0000) | high | proved | DOS final reveal by `G#10` dissolve |
| R:0403:0796 palace view from the map (SCENES-PLAY 7.8) | WdwStatusProc 1218:0000 palace click → OpenPalaceView(0) | role (click on the palace panel) | high | inferred | – |
| O2:1356 sad palace (inside O2:0BD7; SCENES-PLAY 7.8) | ShowSpaceshipArrival → OpenPalaceView(1), the alternative sky (listing 1158:08E7) | call structure: both reached from the arrival sequence | medium | inferred | – |
| O6:1D2B leader screen; O6:21AC throne room; O6:1B33 idle animation; O6:251D text strip; O6:16CD emissary (SCENES-PLAY 7.9) | LoadLeaderScreen 1160:2A38, DrawLeaderAnimationFrame 1160:2EE0, AnimateLeaderPortrait 1160:26EF, ShowLeaderMessage 1160:328E, HoldDiplomaticAudience 1160:0000, RequestLeaderAudience 1160:20C0, BuildEmissaryGreeting 1160:233C | the portrait rectangle (181, 67, 139, 133) (ExtractScaledTile in logical coordinates, WI 2.2); 14 expressions in rows of five | high | proved | DOS idle animation every 10 frames; Windows timer step with `RandomBelow(2)` |
| O18:0000, 016D, 0259, 0C49, 0D4F, 0F83, 1527, 15C3 spaceship (SCENES-PLAY 7.16) | OpenSpaceshipScreen 1070:0000, EvaluateAndShowSpaceship 1070:0327, AnimateSpaceshipStarfield 1070:12B5, ShowSpaceshipOfChosenNation 1070:1F58, HumanPlaceSpaceshipPart 1070:1952, LaunchSpaceship 1070:2015 | 20 stars drawn only on background pixels; ten part records (mass and rectangle) (runtime.md 4.1; WI 2.2, 8 #4) | high | proved (starfield); inferred (the other routines) | DOS cycles five slots; Windows stars from the game generator |
| O2:0BD7 space arrival sequence (TIMING 5.7; SCENES-PLAY 7.16) | ShowSpaceshipArrival 11D8:0000 | role; two caption lists (KING sections SPACE, SPACE2 versus STR# 0x9B, 0x9C) | medium | inferred | partly read (SCENES-PLAY Open 8) |
| O2:152A ARCH sequence (TIMING 5.7) | unknown | – | – | open | Open 3 |
| O9:0000 replay (SCENES-PLAY 7.17) | RunReplayMenu 1180:0000, ChooseReplayModeAndOpenWindow 1180:017A, PlayReplay 1180:02D3, ShowReplayLine 1180:0E78 | the "See Replay?" menu with the same four choices, DGROUP:3FB0 (listing 1180:0000) | high | proved | – |
| O9:0DDE, O9:0F79 conqueror (SCENES-PLAY 7.17) | ShowConquerorEnding 1180:152F, ShowConqueredCivLeader 1180:17E9 | role; gallery heads 27x33 and 45x55 cells (×1.6) | high | inferred | DOS `G#10` dissolve and fades |
| R:0238:08A0 after the end (SCENES-PLAY 7.17) | RunEndGameSequence 1088:0B6D | the same order: power graph, replay, score, rating, Hall of Fame (game-flow.md 3.3) | high | inferred | – |
| O3:065D rating ladder (SCENES-PLAY 7.17) | ShowCivilizationRatingRanking 1080:06FF | eight pixels per step; font 7; border tiles and window frame (listing 1080:06FF) | high | inferred | DOS background 15 and two advisors |
| R:0238:0092 game loop end checks (SCENES-PLAY 7.17) | ProcessGameTurn 1088:0000 | role | medium | inferred | – |
| O22:0967 nuclear explosion (SCENES-PLAY 7.5) | AnimateNuclearExplosion 11B8:0C3D | 28 frames on a 7-column grid on both sides, cells 45 and 90 apart (×2) (WI 2.2) | high | proved | DOS 35 steps of 5 frames |
| O15:0000 schism (SCENES-PLAY 7.18) | StartCivilWar 11A0:0000 | role | medium | inferred | – |
| O22:0000, O22:0639, O22:0AF5 diplomat and bribe events (SCENES-PLAY 7.18) | DiplomatEntersCity 11B8:0000, TransferCityByRevolt 11B8:0F26 | role | medium | inferred | – |
| R:0238:090A advertisement (SCENES-PLAY 7.17) | none | – | high | none | DOS-only |

## 12. Palette

| DOS | Windows | Evidence | Conf. | Label | Differences |
|---|---|---|---|---|---|
| R:0000:108E chunk walk, `G#28` LoadPaletteBlock, through R:1FA1:0220 and R:1FA1:026C (PALETTE 2.2) | GR_PicRead 10B8:079D colour base, AnimatePaletteFromGrPort 1200:0116, SetGodPaletteEntries 1090:0376 | role | high | inferred | DOS replaces all 256 entries at once; Windows installs ranges at a colour base (WI 9.5) |
| R:0000:04AA, R:0000:04D4 fades with R:0000:050C, 0554, 0573, 05B7, 0631 (PALETTE 2.3) | CreatePaletteFade 10A8:0000, StepPaletteFadeIn 10A8:00FC, StepPaletteFadeOut 10A8:018E, ApplyPaletteFadeLevel 10A8:0228 | role | high | inferred | Windows fades only in movies (WI 9.2); DOS fades in many play scenes too (PALETTE 3) |
| R:0000:0382, 03FA, 042B, 044A cycling (PALETTE 2.4) | CyclePaletteColors 1208:22B7 | role for the map slots | high | inferred | DOS eight slots used by intro, logo, Birth, map, space; Windows one map range |
| R:1DC4:05DD, R:1DC4:0626, R:1DC4:065F map cycling (PALETTE 2.4) | WdwMapOpen 1208:0AF1 timer (SetTimer 1208:0E68), CyclePaletteColors | role | high | inferred | DOS 96..103, 104..111, 112..127 every 15 frames; Windows 64..71 every 200 ms |
| R:0238:1BEB play palette (`SP256.PAL` + `BACK*.PAL`) (PALETTE 2.5) | WinMain 1008:023D (0..47h from g_hColorTable), MenuZ 1220:0B3F and DrawAdvisorPortrait 1018:2514 (48h, 50h) | role | medium | inferred | DOS fades in; the upper half carries the GOVT portrait colours |
| R:0238:1B44 return to the map (SCENES-PLAY 0.3) | RestoreMapAfterDialog 1208:14D5, RepaintMainWindows 1220:0EB8 | role | medium | inferred | DOS fades to black, redraws, fades in |
| R:1DC4:047D `ICONPG` palette with interface colours (PALETTE 2.5) | ShowPediaEntry 1068:0763 (g_pediaColors, PushPalette 1090:015E, PopPalette 1090:02D2) | role | medium | inferred | DOS entry 45 forced (PALETTE Open 2); the terrain page does not use R:1DC4:047D (`SP256.PAL` into C5BE through G#28 at O8:0B0B, then DAC 253 grey; PALETTE 2.5; review F2) |
| R:1DC4:0698 one DAC register (PALETTE 2.5) | SetGodPaletteEntries for one entry | role | low | inferred | – |
| `G#27` MapLow16Colours at O2:020E (PALETTE 2.1) | g_egaToSystemColor 12D8:45BE, InitGameColorTables 10E8:2D46 | role: interface colours 0..15 | medium | inferred | DOS takes 0..15 from each scene's palette (PALETTE 6); Windows from a fixed translation |
| O5:16CA..16F3 interface colours saved to DGROUP:6B34 (PALETTE 2.5) | InitGameColorTables 10E8:2D46 (nearest colours from picture 200 entries 1..64, WI 8 #3) | role | low | inferred | – |
| `G#37` SetVideoMode, `G#26` SetDacFromDefault (PALETTE 2.1) | InitGodPalette 1090:0488 | role | low | inferred | – |

## 13. Pictures, shapes, fonts and the pointer

| DOS | Windows | Evidence | Conf. | Label | Differences |
|---|---|---|---|---|---|
| R:1FA1:01A2 loader and wrappers R:1FA1:0220, 0254, 026C, 0288, 023A, 04C0; R:1FA1:000A open; R:1FA1:05E0, 05FE, 0644 word reader (FORMATS 1.1) | GR_PicRead 10B8:079D, LoadPictureToPortBitmap 10B8:0E00, LoadGifPicture 10B8:11BC | role | high | inferred | different formats (DOS chunks, LZW to 11 bits, RLE; Windows CvPc) |
| R:0000:1208, 1227, 1270, 12A6, 1318 decoder; R:0000:11A6 (FORMATS 1.3) | PicDecompress 10B8:158C | role | high | inferred | – |
| R:1FA1:044C whole picture as a sprite; R:1FA1:04D2, R:1FA1:0536 (FORMATS 1.1; SPRITES 1) | GR_PicRead + TileExtract of a whole picture (for example the palace gardens, 1158:1037) | role | medium | inferred | – |
| R:1FA1:066E, R:1FA1:0696 open failure (FORMATS 1.6) | ShowErrorMessage 1098:28E4 | role | low | inferred | DOS exits to text mode |
| R:1FA1:06C8, R:1FA1:0728 archive lookup (FORMATS Open 1) | none | – | high | none | unused |
| O5:1455 shape cutter (SPRITES 2..6) | ExtractGameSpriteShapes 10E8:231F | the same logical rectangles for terrain, coasts, river mouths, roads, railroads, rivers, palace strips, fog edges, icons, specials, city, walls, fortress, hut, sparks, citizens and grassland marker (SPRITES 9; WI 2.1) | high | proved | DOS one terrain variant for rows 6..9 (and all rows in low memory); palace strips 7x15 versus 7x16; units: DOS (16(j mod 20) + 1, 161 + 16(j div 20)) in `SP257.PIC` (O5:19C5..19EE after the copy O5:1A14..1A32), Windows T2(16(j % 20), 161 + 16(j / 20)) without the +1 (10E8:2931..2954): one logical pixel apart in x (finding 1) |
| `G#2` GrabSprite (DRIVER 4) | ExtractPictureTile2x 11E8:097C, ExtractPictureTile1x 10E8:33B9, TileExtract 11A8:05C7 | through O5:1455 | high | proved | Windows doubles; the unit rectangles differ by one logical pixel in x (finding 1) |
| `G#18`, `G#7`, `G#33..35` sprite store (DRIVER 4) | TileNew 11A8:0054, TileDispose 11A8:00D1 | role | low | inferred | – |
| `G#3` RecolourRect (DRIVER 4); unit recolouring O5:19B5..1AE8 (SPRITES 6.4) | ReplaceTileColor 11A8:022F in InitGameColorTables 10E8:2D46 | role: eight recoloured unit copies on both sides | medium | inferred | DOS also uses RecolourRect for highlights (menus, city screen) |
| R:1DC4:009A draw by index; `G#32` DrawSprite; `G#6` DrawSpriteClipped (SPRITES 1) | DrawMapSprite 11C8:008A, DrawShapeAndFlush 11E8:0674, DrawTile 11A8:0CB1 | the same index table D4CE / g_mapSprites (SPRITES 6.3; WI 2.1) | high | proved | – |
| `G#20` CopyRect (DRIVER 4) | CopyPortBits 10D0:03FA, RawPortToPort 10D0:06C0, CopyPortToWindow 10D0:0854 | role | medium | inferred | – |
| `G#10` DissolveToScreen (DRIVER 4; TIMING 3.7) | CreateDissolveState 10B0:151B, DissolveStep 10B0:17E5 (never used, WI 6.5) | role | low | inferred | the Windows dissolve never runs |
| `G#31` ShowPage, `G#22` DrawSpriteScaled, `G#36` (DRIVER 4) | none | – | high | none | – |
| R:0000:0BFA fill (port, x, y, w, h, c); R:0182:0148 fill by corners (SCENES 0.2) | FillRectLogical 11E8:0504; FillScreenRectInclusive 10D8:0612 (dead) | role; the same argument order | high | inferred | – |
| R:0182:000A line, through R:0000:100A (SCENES 0.2) | DrawScreenLine 10D8:0000, DrawAxisAlignedLine 11E8:0912 | role; (x1, y1, x2, y2, colour) | high | inferred | Windows axis-aligned only |
| R:1D05:0A05 outline (SCENES 0.2) | FrameRectLogical 1220:1086 | role | high | inferred | – |
| R:0182:002A, R:0182:005C text (SCENES 0.2) | DrawScreenText 10D8:01B0 | the font is word +10h of the drawing port on both sides (DRIVER 3.2; listing 10D8:01B0); (text, x, y, colour) | high | proved | – |
| R:0182:0086 shadowed text (SCENES 0.2) | DrawShadowedScreenText 10D8:01FA, DrawScreenTextWithShadow 10D8:02DF | role: text over a shadow in colour 0 | high | inferred | DOS draws colour 0 at (x, y + 1), then the text at (x, y), both through R:0182:005C: the shadow is below only, one logical pixel (DOS listing; review R2-23). Windows draws the shadow at device (x, y + 1), or (x + 1, y + 1) when the font's ascent is 18 or more, then the text (listing 10D8:02DF) |
| R:0182:00B3 centred text; R:0182:00EF width (SCENES 0.2) | DrawCenteredScreenText 10D8:0528; GetScreenTextWidth 10D8:05B8 | role | high | inferred | Windows width = device width × 10/16 |
| `G#21` DrawText, `G#4` CharWidth, `G#12` FontLineHeight (DRIVER 4; FORMATS 2.1) | DrawTextAtPortXY 10D8:00E0, GetCStringWidth 1100:00EA, SetCivFont 11E8:0B40 (line height) | role | medium | inferred | DOS bytes 80h and above switch the colour (Open 10) |
| `G#11` FontAddress, `G#16` ReplaceFont, R:1FA1:02E6 font loader (FORMATS 2.1) | none | – | high | none | unused |
| R:1F4D:0088 wrap and draw; R:1F4D:0000 line breaking (FORMATS 3.3) | TextBoxSetup 1068:2072, TextBoxDraw 1068:258F, TextBoxDrawAndClose 1068:255A | role | high | inferred | DOS `^` forces a break |
| R:1F4D:01AD section lookup; R:1F4D:044F `KING.TXT` (FORMATS 3.3) | LoadTextResource 11D0:00E4, LoadKingText 11D0:01F7 | section names: `*NAME` and TEXT `KNG_NAME`, `HLP_`, `ERR_` (finding 8) | high | proved | DOS writes index caches into its files (FORMATS 3.3 step 6); the port never writes DOS files |
| R:1F4D:0471 token replacement (FORMATS 3.3) | SubstituteTextTokens 11D0:022D | the five tokens `$US`, `$THEM`, `$BUCKS`, `$RPLC1`, `$RPLC2` (listing 11D0:01F7) | high | proved | – |
| R:0000:1697 set pointer shape; R:0000:16DB, 170B, 179A show, hide, move; `G#30`, `G#15`, `G#9` (FORMATS 4; DRIVER 1.5) | SetGameCursor 1098:096C, SetCursorAndMarkChanged 1200:0078 | role | high | inferred | DOS software sprite `TORCH.PIC`, hot spot (0, 0); Windows 16 cursors |
| R:01A8:0250, R:01A8:0268 show and hide the pointer (SCENES 0.3) | none | – | medium | none | Windows changes the shape (busy cursor 132) instead of hiding |
| R:0403:0FFD..10B8 in-play pointer: the case 67h (`g`) of the order switch R:0403:1AED, run once per dispatch; with the mouse (DGROUP:1A3C ≠ 0) R:0000:1697 at R:0403:10AB sets the GO arrow D4CE[2] while a local flag is clear and the torch D4CE[7] while it is set, and the xor at R:0403:10B3 toggles the flag; a map click while it is set stores the destination in unit bytes DGROUP:81DA/81DB and restores the torch (R:0403:09D9..0AEC) (SCENES-PLAY Open 3; corrected 2026-10-11, reviews R2-1 and F2) | UpdateMapMoveCursor 1208:121A (GoTo cursor 133 at 1208:12B7) | role: the GoTo pointer (inferred: the key `g` and the write at +6/+7 of the 12-byte unit record, the Windows Unit.gotoX/gotoY offsets) | medium | inferred | DOS shows the GO arrow from the first `g` until a click or a second `g`; Windows shows cursor 133; nothing in R:0403 selects a DOS pointer for the small map (SetSmMapCursor 1210:071D, cursor 130) or for scrolling (cursors 136..143) (Open 2) |
| R:0000:163E, R:0000:17DB mouse install and handler; R:0000:16AE set position; R:0000:1766 (FORMATS 4) | the Windows mouse messages (WdwMapProc 1208:0054 and the dialog procedures) | role | low | inferred | – |

## 14. Timing and input

| DOS | Windows | Evidence | Conf. | Label | Differences |
|---|---|---|---|---|---|
| R:0000:0000, 0051, 0077, 008F, 01A7, 0215, 0276, 030B, 0345 timer and frame routine (TIMING 2) | TimerProc 1008:0D68 (5 ms), TickCount 1100:02E1 (GetTickCount × 60/1000) | role: the presentation clock | high | inferred | DOS frame clock 70.086 Hz and sound tick 60.074 Hz (VGA, inferred); Windows 60 Hz ticks |
| R:0000:033A, R:0000:033E frame counter (TIMING 3.2) | TickCount 1100:02E1 | role | high | inferred | – |
| R:0182:0134 `wait(n)` (TIMING 3.3) | DelayTimerTicks 11E8:02A4; WaitTicksOrInput 11D8:0BD2 (with input) | role | high | inferred | DOS frames; Windows ticks or timer callbacks |
| `S#5` sound tick (TIMING 3.4) | the movie clock of AdvanceMovie (TickCount frames) | role: the schedule clock of intro and Birth | medium | inferred | – |
| R:2045:2098 `kbhit` (TIMING 3.7) | IsKeyPending 11E8:02FB (functions.md: "the Windows replacement for a DOS 'key pressed?' poll") | role | high | inferred | – |
| R:2045:20AC `getch`; R:1D05:0AC9 read key (SCENES 0.3) | GetQueuedKey 1008:09E3, DequeueKey 1008:0A22 | role | high | inferred | – |
| R:0403:4545 flush (SCENES 0.3) | FlushInputEvents 11F0:4EA0 | role | high | inferred | – |
| R:01A8:0223 mouse poll (SCENES 0.3) | PollMouseClick 1108:0000 | role | high | inferred | – |
| R:0403:0676..0846 play input dispatch, F1..F10 (SCENES-PLAY 6.3, 7.14) | MoveCivUnits global switch 11F0:39EB (codes 0x131..0x139, 0x130) and accelerators Ctrl+1..Ctrl+0 (platform.md 2.5) | the same reports in the same order (finding 9) | high | inferred | Windows has no key producing 0x13x |
| R:1DC4:0042 `srand(time())` (TIMING 3.7) | SeedRandomFromClock 11C8:0000 and `srand(time)` at 11E8:0423 (runtime.md 4.1) | role | high | inferred | – |
| R:1DC4:005D `random(n)` (SCENES-PLAY 2.4) | RandomBelow 11C8:003D | role | high | inferred | different libraries: DOS (rand() · n) >> 15 with the Microsoft C `rand` R:2045:2AEA (DOS listing, DOS file strings); Windows the Borland C++ library (claude/docs README.md) (finding 7) |
| R:1DC4:007C clamp (TIMING 5.5) | ClampInt 11C8:0063 | role | high | inferred | – |
| R:01A8:046C sound (SCENES-PLAY 0.1) | PlaySoundEffect 1150:00C9 | role | high | inferred | sound out of scope |

## 15. DOS presentation functions without a Windows counterpart

| DOS | Role | Source |
|---|---|---|
| O1:0000, R:0199:00A1, R:01A8:08DB | text-mode set-up screen | SCENES 2 |
| O2:0000..0150, R:01A8:02A4 | loading messages, disk prompts | SCENES 3, 10.3 |
| R:01A8:03F4 | Ctrl-Break and Ctrl-C handlers | SCENES 1 |
| O11:05F8, O11:0103 | drive prompt, slot headers | SCENES 7.2 |
| O7:1820..1847 | "BUILDING NEW WORLD..." | SCENES 8.4 |
| O2:02F4, O2:0AA0, O7:1AF0, O2:12B1..1329, O18:00E0..0140, O19:0ED8 | palette cycling outside the map | PALETTE 4; TIMING 5.6 |
| fades other than the movie fades (R:0238:1B66, R:0238:1C86, R:0ADE:198C, O2:122B, O9:1079, O9:124C, O17:0CB9, O19:0EB9, O22:10FC, R:01A8:05B6, R:01A8:0840) | scene transitions | PALETTE 3 |
| `G#10` uses at O2:0B8B, O17, O19, O9 | pixel dissolve | SCENES 5; SCENES-PLAY 7.2, 7.8, 7.17 |
| R:0238:090A | advertisement screen | SCENES-PLAY 7.17 |
| O10, O12:03AC, O13:0000, O13:0554 | debug screens (DGROUP:D806) | SCENES-PLAY 7.18 |
| R:0000:0732, R:0000:0A76, R:0000:0B1E | driver guard and loader | DRIVER 1 |

## 16. Windows presentation functions without a DOS counterpart

| Windows | Role | Source |
|---|---|---|
| ShowAboutBox 1010:0000, AboutMovieCallback 1010:00D6, movie 1230:0000 | About box | WI 6.4 |
| ConvertArtworkFor16ColorDisplay 10B8:0000, DitherPictureTo16Colors 10C8:0000 and the 10C0 colour matching | 16-colour displays | WI 1.3, 8 |
| TileCacheLookup 1110:030C, TileCacheInsert 1110:01A3, FlushTileCache 1110:0127 | tile cache | graphics.md 4.10.3 |
| WdwMapProc 1208:0054, WdwSmMapProc 1210:0000, WdwStatusProc 1218:0000, ScrollMapVertical 1208:068C, ScrollMapHorizontal 1208:08D8, ResizeMapWindow 1208:0F62 | windows and scroll bars | world.md 4 |
| UpdateMapMoveCursor 1208:121A (cursors 136..143) | map scroll arrows | WI 5 |
| OpenGameHelp 1048:04E8 | WinHelp (civ64: a message box, FIDELITY F84) | ui-dialogs 4.9 |
| PaintRandomRadio 1058:0000, PaintRandomStatic 1058:04F6 and the RanDoM classes | dialog controls | ui-dialogs 2.5 |
| IntroMovieCallback case 4 | caption on non-palette displays | WI 6.1 |
| PushPalette 1090:015E, PopPalette 1090:02D2 | palette stack | WI 9.4 |
| DrawPaletteTestPattern 1110:1E17, ShowDisplayDriverChecklist 1060:01C1 | debug and dead screens | functions.md |

## 17. Coverage

All 259 function entries of `db.json` that the drafts cite (list in
`build/dos/scratch-d0f/dosfuncs-in-drafts.txt`) appear above, in the excluded list below, or are
covered by a row that names their range:

* **Not presentation** (excluded): the C run time R:2045:019E, 0698, 1A64, 200E, 20C4, 25E6, 2932, 30CE;
  the world generation stages O7:065C, O7:0A33, O7:1440 (they only call O7:17CF); the
  game-rule routine R:0866:0F10 (quiz penalty, SCENES-PLAY 7.15); R:0ADE:22B5 (a knowledge test);
  O9:0F79 is covered with O9:0DDE.
* **Unreferenced in the drafts' scenes**: R:0000:104F (text at a position for O2:0BD7, TIMING 5.7)
  is covered by the O2:0BD7 row.

## Open

1. **Sheet mapping of finding 2.** The rule (2x + 832, 2y − 100) is a numeric match of four shape
   families. It is not a pixel comparison of SP299.PIC with Windows picture 200. It also leaves
   g_wholeTileShapes[8] (river base) on SP299 (272, 120), not on the land base (256, 120) that
   SPRITES 7 proposes; [7] would be (256, 120), and Windows reads neither [0] nor [7] nor [10]
   (WI 2.1). D1 should compare the pixels before relying on it.
2. **DOS pointer shapes.** R:0403:10AB selects only two shapes, the torch D4CE[7] and the GO
   arrow D4CE[2]. The flag that selects the arrow toggles once per dispatch of the order case
   67h; a map click while it is set stores the destination and restores the torch (section 13;
   reviews R2-1 and F2). Open: the game situation of case 67h, read as the GoTo order from the
   key `g` and the unit-record write, is not traced through the dispatch's callers (OPEN L5);
   if it is GoTo, the GO arrow is the counterpart of the Windows GoTo cursor 133. No DOS
   counterpart of the small-map cursor 130 or the scroll cursors 136..143 was found.
3. **O2:152A** (`ARCH.PIC`, KING section ARCH): its trigger and Windows counterpart are not
   established (TIMING 5.7).
4. **Combat sparks.** The DOS routine that draws DGROUP:D50E is not traced (SPRITES Open 3).
5. **R:0238:1767**, a caller of the Civilopedia entry: its role is not traced.
6. **ORDERS menu.** The DOS item list is built at run time (R:1C84, DGROUP:2D05..2D91) and was
   not decoded; the pairing with commands 301..318 is by role only.
7. **Production advisors.** The DOS advisor boxes of the production menu (`PRODUCE.TXT`, option
   bit 1) have no identified Windows counterpart.
8. **Unit stack popup.** Resolved 2026-10-11 (review R3-8): R:0866:1F69 pairs with dialog 141
   (section 7; SCENES-PLAY 7.19).
9. **ShowCivilizationDestroyed** (11D8:087F, picture 5590, called from ProcessGameTurn 1088:0189
   when the human has no cities and no settlers): no DOS scene was found. The DOS notice O5:0E6C
   (civ, by) ("civilization destroyed by") returns at once for civilization 0 and for the human
   player DGROUP:D7EE (O5:0E73..0E84); the DOS game-over paths of R:0238:0092 are the spaceship
   (DGROUP:1CF6), conquest (DGROUP:B884) and the year limit (R:0238:0718..0779, 07CE..0822)
   (DOS listing). What DOS shows when the human is destroyed is open (OPEN.md O8); the profile
   classes 5590 W (DOS-PROFILE.md row 131, P36, section 4 W9).
10. **Text colour bytes.** DOS strings switch colour with bytes 80h and above (G#21; FORMATS 2.3,
    G:0000:0F9C); every DOS font ends at code 7Fh or lower (FORMATS 2.2). The Windows core's text
    is Windows-1252 and has no colour bytes. The profile's rule (colour bytes honoured only in
    DOS-sourced static text; core bytes of 80h and above by a recorded substitution) is a D1
    decision: OPEN.md P5, P13.
11. **Find City.** Whether the DOS typed-name search (O23:0319) and the Windows list select the
    same city for the same name is not checked.

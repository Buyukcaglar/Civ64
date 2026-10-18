# Windows inventory for the DOS profile (D0, draft)

Draft by agent D0-D, 2026-10-11. Extension phase D0, task "Windows inventory" (extension prompt
`claude/docs/x64-port-scaling-dos-prompt.md`, section 9 row D0, with the needs of 5.4, 3 and 8).
Independent review R3 (`docs/verify/ext-d0-review-r3.md`) and the R1/R2 items in its scope
were applied on 2026-10-11 by fixer F3 (`docs/verify/ext-d0-fixes-r3.md`).

This file lists what the Windows game (the core that civ64 runs) draws and how: every picture,
every cut shape, font, dialog, cursor and movie, the callers of the logical 320x200 layer, the
pixels that the core reads back as data, and every palette effect. The DOS profile builds its
counterpart and scene tables on it. It holds no DOS facts and no original bytes: only ids,
sizes, addresses and prose.

## 0. Conventions

* Addresses are Windows NE selectors, `ssss:oooo` (segment = (selector - 0x1000)/8 + 1; DGROUP
  is 1420). They are never DOS addresses.
* Picture and dialog sizes are device pixels of the Windows game. "Logical" means the 320x200
  coordinates of the logical layer (section 7).
* "Colour base" is the `colorBase` argument of GR_PicRead (10B8:079D): file colour k goes to god
  palette entry base + k, which is system palette index base + k + 10. "Installed" is the
  `(first, count)` pair of the AnimatePaletteFromGrPort (1200:0116) call that puts the colours on
  a window. LoadGifPicture clamps the colour count to `236 - base` (docs: palette-pictures.md
  2.5), so a 256-colour header loaded at base 0x48 keeps 164 colours.
* "F:" names a row of `claude/port/docs/FEATURES.md`: a feature row of "Title menu, intro and
  Birth" or "Windows, screens and effects" by its name, a dialog row by its id, a menu row by its
  command number.

Evidence labels:

| Label | Meaning |
|---|---|
| **listing** | read in this task from `showfunc.py` output at the cited address |
| **resource** | header metadata (ids, sizes, colour counts, hot spots, template sizes, movie items) read in this task from the game files in `claude/port/build/gamedata/` with the scratch parsers below (civdis `ne.py`/`resources.py` imported read-only); see the note below |
| **db** | caller, callee and call-site lists of `claude/docs/db/functions.json` |
| **docs** | stated in `claude/docs` (file and section given), not re-derived here |
| **inferred** | concluded from the above; the reasoning is given |
| **unknown** | not determined; listed again in section 11 |

Note on **resource** (review R3-21, 2026-10-11). `claude/port/build/gamedata/` is not one of the
Windows sources BRIEF-d0 names (claude/docs, claude/src, FEATURES, TRACE, showfunc). Where
`claude/docs` states the same fact, it is also **docs**:
* dialog template sizes and styles, the 16 cursors, their hot spots and GROUP_CURSOR mapping:
  resources.md ("DIALOG nnn" sections, "Cursors and icons");
* the movie scripts: graphics.md 4.14.3 and data-tables.md;
* the picture count (199 `CvPc` in `civdata0..4.rsc`) and the sizes of the groups 128, 129..135,
  142, 143, 144, 200, 202, 400..406, 500..513, 1013, 1014, 1100..1166, 1200..1227 and
  5000..5006: the extension prompt ("Pictures") and crosscheck/startup-audits.md (129..135).

These rest on **resource** alone: header fields read from the pinned original files in
`claude/port/build/gamedata/` (the verified read-only copy of `original/CIVWIN`, base prompt 3; the
port reads the same files at run time). The orchestrator ratified that source on 2026-10-11 (review
R3-21; header fields only, no pixels or bytes in this document): the
per-file distribution (1.1), the colour count of every picture and the sizes of 136, 140, 141,
3333..3347, 4444..4469 and 5555..5600 (1.2), the absent ids of 1.3, and the font file table of
3.1. None of them is used by the DOS profile as more than a header fact.

Scratch files (all under `claude/port/build/dos/scratch-d0d/`): `enum_rsc.py` (Mac resource
forks of `civdata0..4.rsc`; output `rsc-summary.txt`, `rsc.json`), `enum_fon.py` (fonts,
cursors and dialogs; output `fon-exe.txt`), `movies.py` (movie scripts; output `movies.txt`),
`sites.py` (listing excerpts before each call site; outputs `picsites.txt`, `cursorsites.txt`,
`palsites.txt`, `palsites-short.txt`, `dlgsites.txt`, `dlgsites-short.txt`), `logical.py`
(logical-layer callers; output `logical.txt`), and showfunc dumps `egss.txt`, `pedia.txt`,
`research.txt`, `combat.txt`, `city.txt`, `rtfk.txt`.

## 1. Pictures

### 1.1 Counts

The pictures are `CvPc` resources in the Mac-format resource forks `civdata0..4.rsc`. There are
**199 pictures, 199 distinct ids, each in exactly one file** (**resource**, `enum_rsc.py`):

| File | CvPc | Other resource types |
|---|---|---|
| civdata0.rsc | 4 (137, 144, 202, 5581) | GDAT 7, KDAT 14, STR# 33, TEXT 399 |
| civdata1.rsc | 14 (128..136, 140, 400..403) | - |
| civdata2.rsc | 31 (404..406, 500..513, 5555..5566, 5590, 5591) | - |
| civdata3.rsc | 149 (141..143, 1013, 1014, 1100..1166, 1200..1227, 3333..3347, 4444..4469, 5000..5006, 5600) | - |
| civdata4.rsc | 1 (200) | - |

Every picture is read through GR_PicRead (10B8:079D), directly or through
LoadPictureToPortBitmap (10B8:0E00, GR_PicRead plus GR_PortDataToBitmap). LoadGifPicture has a
single caller, GR_PicRead (**db**). GR_PicRead has 34 call sites and LoadPictureToPortBitmap
12 (**db**; each site read in `picsites.txt`, **listing**). The movie engine reads pictures at
AdvanceMovie 10B0:0F40 (item type 6).

"Colours" below is the header colour count (**resource**).

### 1.2 Picture table

| Ids | File | W x H | Colours | Loader (call site) | Colour base; installed | Screen and use | F: |
|---|---|---|---|---|---|---|---|
| 128 | civdata1 | 1024x320 | 153 | intro item 7 at frame 40 and Birth item 0 at frame 1000 (AdvanceMovie 10B0:0F40) | base 0; intro Scroll copies 0..159, Birth SwapAndShow 0..223 | intro panorama, scrolled one pixel every 2 frames; first Birth picture, shown with x offset 512 (its right half) | Intro sequence; Birth sequence |
| 129..135 | civdata1 | 512x320 each | 224 each | Birth LoadPicture items at frames 1100, 1900, 2700, 4500, 5700, 7100, 8900 | base 0; SwapAndShow 0..223 | Birth pictures 2..8, each loaded one ahead of its SwapAndShow | Birth sequence |
| 136 | civdata1 | 502x145 | 256 | intro item 22 at frame 1180 | base 176; SwapAndShow 0..235 | title logo; composed by IntroMovieCallback case 3 in rect (5,20,507,165) | Intro sequence; Title menu |
| 137 | civdata0 | 320x200 | 256 | GR_PicRead at GenerateWorldMap 1028:0096 | base 0; never installed | EARTH map data, never displayed (section 8) | Play on EARTH |
| 140 | civdata1 | 512x320 | 256 | LoadPictureToPortBitmap at CustomizeWorldDialog 1108:02AB | base 0x10; installed 0x10/0xE0 at 1108:0302 (clamped to 16..235) | Customize World background | Customize World; 143 |
| 141 | civdata3 | 512x320 | 256 | LoadPictureToPortBitmap at RunNewGameSetup 10E8:0116 | base 0x10; installed 0x10/0xE0 at 10E8:0154 | setup background (difficulty art) | Start a New Game; 144 |
| 142, 143 | civdata3 | 512x320 | 64 | LoadPictureToPortBitmap at CompleteResearch 1170:248A, id 0x8E + di; di = 1 when the human knows advance 0x36 (1170:231A..2334) | base 0x48; installed 0x48/0x40 at 1170:24A2 | scientist picture of the discovery dialog 146 or 147 (same di) | 146; 147 |
| 144 | civdata0 | 640x400 | 128 | GR_PicRead at AnimateNuclearExplosion 11B8:0C6C | base 0x48; installed 0x48/0x50 on the map window at 11B8:0C8B | 28 explosion frames (section 2.3) | Map window (no own row) |
| 200 | civdata4 | 1472x400 | 128 | GR_PicRead at LoadGameSpriteSheet 11E0:09EE into g_picturePort 12D8:4466 | base 0; table kept as g_hColorTable 1420:B388; WinMain 1008:023D installs 0..0x47 on the map window | the sprite sheet (section 2.1); row 399 holds colour keys (section 8) | Map window, world-map window, status window |
| 202 | civdata0 | 243x116 | 64 | LoadPictureToPortBitmap at ExtractGameSpriteShapes 10E8:2348 into g_reportPicturesPort 1420:92FC | base 0x48; installed 0x48/0x50 by MenuZ 1220:0B3F | MenuZ message pictures: slice `g_messagePicture*81`, 81x116, for pictures 0..2 (docs: ui-dialogs.md MenuZ step 3) | 136; 145 |
| 400..406 | civdata1 (400..403), civdata2 (404..406) | 939x320 each | 400: 256; 405: 64; others 128 | (a) GR_PicRead at LoadAdvisors 10E8:31E1, id 400 + GetCourtStyle(human) (1160:3487); (b) GR_PicRead at LoadLeaderScreen 1160:2BB0, id 400 + GetCourtStyle(civ) | (a) base 0x48, table kept as g_hAdvisorColorTable 1420:0130, installed 0x48/0x50 by DrawAdvisorPortrait 1018:2514; (b) base 0x98, installed 0x48/0xA0 with the portrait at 1160:2C58 | court pictures: four advisor portraits (a) and the leader's court background, attendants and poses (b) (section 2.3) | Advisors and reports; 401..406; Diplomacy screens; 142 |
| 500..513 | civdata2 | 427x320 each | 502, 510, 513: 64; others 128 | (a) GR_PicRead at LoadLeaderScreen 1160:2AA5, id 500 + g_tribePortraitIndices (1360:0008); (b) GR_PicRead at ShowConqueredCivLeader 1180:182A, same table | base 0x48; (a) with the court as above; (b) installed 0x48/0x50 on g_replayWindow at 1180:184B | leader portrait: body and 14 face frames (a); conquered leader in the replay (b) | Diplomacy screens; 142; Replay |
| 1013, 1014 | civdata3 | 427x320 each | 64 | GR_PicRead at ShowPediaEntry 1068:114E, id 1013 + slot/6 (slot from GetPediaTerrainPictureSlot) | base 0x48; installed 0x48/0xA0 at 1068:1199 | Civilopedia terrain sheets, 3x2 cells of 143x139 | Civilopedia; 605 |
| 1100..1166 | civdata3 | 178x132 each | 64: 1100..1102, 1107..1110, 1113, 1114, 1116, 1118, 1119, 1128, 1131, 1133, 1136, 1139, 1141, 1144, 1148, 1149, 1151, 1153, 1156, 1157, 1159, 1161, 1163, 1164; 32: 1150; 128: the other 37 | (a) ShowPediaEntry 1068:114E, id 1100 + advance; (b) GR_PicRead at CompleteResearch 1170:25A2, id 1100 + g_researchTarget; (c) GR_PicRead at AskCivilizationQuizQuestion 1178:01E8, id 1100 + di | (a) base 0x48, installed 0x48/0xA0; (b) base 0x88, installed 0x88/0x60 at 1170:25BB; (c) base 0x48, installed 0x48/0xA0 at 1178:0208 | advance pictures (one 148x110 cell centred in 178x132 for the Civilopedia) | Civilopedia; 602; 146; 147; 149 |
| 1200..1227 | civdata3 | 215x100 each | 64: 1208, 1209, 1212, 1219..1222; 128: the other 21 | ShowPediaEntry 1068:114E, id 1200 + unit type | base 0x48; installed 0x48/0xA0 | Civilopedia unit pictures, one 213x98 cell | Civilopedia; 604 |
| 3333 (0xD05) | civdata3 | 512x320 | 128 | (a) GR_PicRead at ShowCityView 11B0:0AB0; (b) LoadPictureToPortBitmap at ShowCityFoundedAnimation 11B8:1549 | base 0x48; (a) installed 0x48/0x60 at 11B0:0ACA into g_cityViewDialog 1420:B2C4; (b) installed 0x48/0xA0 at 11B8:15A2 | city view background; city-founded background | City screen and city view; 704; 302 |
| 3334 (0xD06) | civdata3 | 512x485 | 128 | GR_PicRead at LoadCityViewSprites 11B0:1999 | base 0x48 (merged into the city view port) | wonders sheet, rects g_wonderSheetRects 13A8:0000 | City screen and city view |
| 3335, 3336 (0xD07, 0xD08) | civdata3 | 480x320 each | 128 | (a) GR_PicRead at LoadCityViewSprites 11B0:18C4: 0xD08 if the owner knows advance 0x25, else 0xD07; (b) ShowPediaEntry 1068:114E for improvements 2..21: 0xD08 if the human knows advance 0x25 (1068:07F8..0818) | base 0x48 | city view buildings (79x79 cells); Civilopedia improvements (80x80 cells, 4 per column) | City screen and city view; Civilopedia; 603 |
| 3337 (0xD09) | civdata3 | 512x103 | 128 | GR_PicRead at LoadCityViewSprites 11B0:1674 | base 0x48 | city view houses, 5 styles x 4 variants | City screen and city view |
| 3338 (0xD0A) | civdata3 | 307x52 | 128 | GR_PicRead at LoadCityViewSprites 11B0:17D5 | base 0x48 | city view roads, 16 tiles about 38x13 | City screen and city view |
| 3339 (0xD0B) | civdata3 | 512x216 | 64 | GR_PicRead at DrawCityViewCitizens 11B0:1333 | base 0xA8; installed 0xA8/0x40 at 11B0:134D | citizen figures, 9 frames of 57x97 (row by advance 0x23) | City screen and city view |
| 3340, 3341 (0xD0C, 0xD0D) | civdata3 | 512x384 each | 64 | GR_PicRead at PlayCelebrationAnimation 11B0:23BB: 0xD0D if the human knows advance 0x23, else 0xD0C | base 0xA8; installed 0xA8/0x40 at 11B0:243D | celebration figures | City screen and city view |
| 3342, 3343 (0xD0E, 0xD0F) | civdata3 | 512x384 each | 64 | GR_PicRead at PlayCivilDisorderAnimation 11B0:1FE1 / 2060: 0xD0E if the human knows advance 0x0D, else 0xD0F | base 0xA8; installed 0xA8/0x40 at 11B0:2114 | civil disorder figures | City screen and city view |
| 3344..3346 (0xD10..0xD12) | civdata3 | 512x384 each | 64 | GR_PicRead at PlayCityCaptureAnimation 11B0:1BA5 / 1C28 / 1CAB (by the conqueror's advances 0x22 and 0x3A) | base 0xA8; installed 0xA8/0x40 at 11B0:1D5F | city capture soldiers, 10 frames about 127x120 | City screen and city view |
| 3347 (0xD13) | civdata3 | 80x125 | 32 | GR_PicRead at ShowCityFoundedAnimation 11B8:155C | base 0xA8 (merged, then 0x48/0xA0 installed) | city-founded sprites, 4 frames | City screen and city view; 302 |
| 4444, 4445 (0x115C, 0x115D) | civdata3 | 512x211 each | 256 | GR_PicRead at OpenPalaceView 1158:0B34 (0x115D if useAltSky) | base 0x48; installed 0x48/0xA0 at 1158:0B4E | palace sky | Palace view |
| 4446 (0x115E) | civdata3 | 512x5 | 256 | GR_PicRead at OpenPalaceView 1158:0BE2 | base 0x48 | palace strip at y 211 | Palace view |
| 4447..4450 (0x115F..0x1162) | civdata3 | 512x104 each | 256 | GR_PicRead at OpenPalaceView 1158:0A67, id 0x115F + level of section 10 | base 0x48; installed 0x48/0xA0 at 1158:0A81 | palace ground at y 216 | Palace view |
| 4451..4456 (0x1163..0x1168) | civdata3 | 224x108, 218x80, 259x111, 218x88, 291x146, 217x143 | 256 | GR_PicRead at OpenPalaceView 1158:1037 (garden A, 0x1161 + 2*level) and 1158:1113 (garden C, 0x1162 + 2*level), levels 1..3 | base 0x48 | palace gardens | Palace view |
| 4457..4469 (0x1169..0x1175) | civdata3 | 256x160 or 280x160 (4460, 4463, 4466, 4469 are 280 wide) | 256 | GR_PicRead at LoadPalaceSectionSprites 1158:158A: 0x1169 for level 0, else 0x116A + (level-1)*3 + style | base 0x48 | palace section sprites | Palace view |
| 5000..5006 | civdata3 | 300x115 each | 64 | About movie LoadPicture items at frames 0, 160, 660, 1060, 1460, 1860, 2260 | bases 152, 88, 152, 88, 152, 88, 152; SwapAndShow installs 64 from the base | About box pictures | 129; 803 |
| 5555 (0x15B3) | civdata2 | 512x320 | 256 | LoadPictureToPortBitmap at ShowSpaceshipArrival 11D8:00F6 | base 0x48; installed 0x48/0xA0 at 11D8:010F | spaceship arrival background | End-game sequences |
| 5556 (0x15B4) | civdata2 | 512x320 | 256 | LoadPictureToPortBitmap at ShowSpaceshipArrival 11D8:05C8; also the mono arm of 11D8:00F6, dead (g_monochromeMode is always 0) | base 0x48; installed 0x48/0xA0 at 11D8:0644 | second arrival picture (docs: game-flow.md; role named "human ship" in the listing comments) | End-game sequences |
| 5557..5566 (0x15B5..0x15BE) | civdata2 | 116x113 each | 256 | GR_PicRead at ShowSpaceshipArrival 11D8:003B, id 0x15B5 + i | base 0x48 | ten arrival frames | End-game sequences |
| 5581 (0x15CD) | civdata0 | 48x360 | 128 | GR_PicRead at OpenSpaceshipScreen 1070:010A | base 0x48; installed 0x48/0xA0 at 1070:0122 | spaceship part sheet, 10 parts | Spaceship screens; 506 |
| 5590 (0x15D6) | civdata2 | 512x320 | 256 | LoadPictureToPortBitmap at ShowCivilizationDestroyed 11D8:08A2 | base 0x48; installed 0x48/0xA0 at 11D8:0910 | civilization destroyed | End-game sequences |
| 5591 (0x15D7) | civdata2 | 645x320 | 64 | LoadPictureToPortBitmap at ShowConquerorEnding 1180:15F1 into g_conquestBackgroundPort 1390:001C | base 0x98; installed 0x98/0x50 at 1180:165E | conqueror ending background | End-game sequences; Replay |
| 5600 (0x15E0) | civdata3 | 512x320 | 64 | LoadPictureToPortBitmap at ShowHallOfFame 1080:0164 | base 0x48; installed 0x48/0xA0 at 1080:018D | Hall of Fame background | View Hall of Fame; Hall of Fame |

All rows: sizes and colour counts **resource**; loaders, ids, bases and installed ranges
**listing** at the cited call sites (`picsites.txt`, `palsites-short.txt`); screen roles
**listing** comments and **docs** (graphics.md 4.14..4.19, palette-pictures.md 2.4,
advisors.md 4.2, game-flow.md 4.14).

### 1.3 Requested ids that do not exist, and dead loaders

* ShowConquerorEnding 1180:160E loads picture 0x1C2 = 450 at base 0x98 on a dead path
  (**listing**). No picture 450 exists (**resource**).
* ShowPictureInWindow 1068:062F (LoadPictureToPortBitmap at 1068:0648) has no caller (**db**).
* PreconvertPicture 10B8:076A (GR_PicRead at 10B8:0783) only pre-converts for 16-colour
  displays. ConvertArtworkFor16ColorDisplay 10B8:0000 walks the ranges 200..202, 1100..1300,
  128..144, 500..513, 400..406, 1013..1015, 5555..5591, 3333..3347, 4444..4469, 5000..5006
  and 5600 (331 ids, of which the 199 above exist); its progress total is 330 (**listing**
  10B8:01CC..047F). Ids 138, 139, 201, 1015, 1167..1199, 1228..1300, 5567..5580, 5582..5589 are
  walked but absent (**resource**).
* The dither pass is skipped for 137 only (docs: palette-pictures.md 2.5, GR_PicRead step 3).

## 2. Shapes

A shape (TileBlock) is a moveable block of `w*h + 6` bytes: width, height, then one byte per
pixel, already in system palette indices. Transparency: 0xFF opaque, 0 = the shape's top-left
pixel, any other value is that index (docs: graphics.md 2.4).

### 2.1 Shapes cut from picture 200 (ExtractGameSpriteShapes 10E8:231F)

ExtractGameSpriteShapes runs once from LoadGameSpriteSheet 11E0:09D0 after picture 200 is in
g_picturePort 12D8:4466. It first loads picture 202 (section 1.2) and reads the colour keys of
row 399 (section 8). Then it cuts in batches, calling UpdateActiveAnimation 1098:0157 between
them (docs: graphics.md 4.9; **listing** `egss.txt`).

Cutting helpers (**listing** 11E8:097C, `egss.txt` lines 15 and 575):
* **T2** = ExtractPictureTile2x (11E8:097C) `(xBase, x, y, w, h)`: the logical rectangle is
  doubled and cut at device `(xBase + 2x, 2y)` with size `2w x 2h`. xBase is 0 (left half) or
  0x280 = 640 (right half). A 16x16 logical shape becomes a full 32x32 map square.
* **T1** = ExtractPictureTile1x `(0, x, y, w, h)`: device pixels, not doubled.
* **TE** = TileExtract (11A8:05C7) with device coordinates.

| Table (address) | Entries | Cut | Users (**db**/**listing**) |
|---|---|---|---|
| g_terrainShapes (1420:972E) [12][16] | [t][m], t 0..9, m 0..15 (rows 10, 11 never filled) | T2 right half `(16m, 16t, 16, 16)` | RenderTileFromKey 1118:0000 |
| g_coastShapes (1420:95E2) [9][4] | [i][q], i 0..7: coast quadrants | T2 right half: q 0/1 `(16i + 8*(q&1), 176, 8, 8)`; q 2/3 `(16i + 8 - 8*(q&1), 184, 8, 8)` | RenderTileFromKey |
| g_coastShapes [8][0..3] | river mouths N, E, S, W | T2 right half `(128 + 16d, 176, 16, 16)` | RenderTileFromKey |
| g_roadRailShapes (1420:96EC) [33] | [0..7] road, [16..23] railroad | road `T2(16i, 48, 16, 16)`, rail `T2(128 + 16i, 96, 16, 16)` | RenderTileFromKey |
| g_roadRailShapes [32] | pollution icon of the city screen | `T2(48, 32, 16, 16)` | ProcessCity 1030:5681..56AF draws one per pollution point at `(252 + i*pitch, 253 + (i&1))` into g_cityOverlayPort 1260:0032 (**listing**) |
| g_riverShapes (1420:96AC) [32] | [1..15], [17..31]; [0], [16] empty | `T2(16i, 64, 16, 16)` and `T2(16i, 80, 16, 16)` | RenderTileFromKey |
| g_miniPalaceShapes (1420:9632) [3][20] | variant x (level x piece) | `T2(160 + 7i, 16v, 7, 16)` | DrawMiniPalace 1088:1A82 |
| g_unexploredEdgeShapes (1420:962A) [4] | fog edges, dirs 1, 3, 5, 7 | `T2(80 + 16i, 128, 16, 16)` | DrawMapTile 1110:04D0 |
| g_mapSprites (1420:9350) [4..6] | irrigation, mine, pollution | `T2(16i, 32, 16, 16)` | RenderTileFromKey 1118:0000 |
| g_mapSprites [8..15] | 7x7 icons | `T2(129 + 8*(i&3), 33 + 2*(i&4), 7, 7)` | ProcessCity 1030:0000 ([8], [9], [11..14] and indexed), DrawCityImprovementList 1030:8D33 ([11]); DrawMapSprite 11C8:008A takes any index (reports) |
| g_cityIconShapes (1420:933A) [0..2] | 7x7 | `T2(129 + 8i, 25, 7, 7)` | ProcessCity 1030:0000 |
| g_cityIconShapes [3..10] | 12x12 device | `T1(256 + 12*(i&3), 25 + 3*(i&4), 12, 12)` | AddWorkedSquareYields 1030:79CE |
| g_citizenShapes (1420:95D0) [9] | 8x16 citizens; [4] is the disorder icon | `T2(8i, 128, 8, 16)` | DrawCityPeopleRow 1030:830C, DrawCityPeopleRowToOverlay 1030:817E, DrawMapTile ([4]), DrawScoreCitizenIcon 1040:1B51 |
| g_mapSprites [16..31] | specials 16..27, city 28, walls 29, fortress 30, hut 31 | `T2(16i + 1, 113, 15, 15)` | RenderTileFromKey (specials indexed, [30], [31]), DrawMapTile ([28], [29]) |
| g_mapSprites [32..39] | combat explosion, 8 frames | `T2(16i + 1, 97, 15, 15)` | ResolveCombat 1050:0A9C..0AEA draws frame `g_mapSprites[32 + frame]` into g_offscreenPort and blits to the map window (**listing**) |
| g_grasslandShieldShape (1420:96AA) | 7x7 shield | `T2(153, 41, 7, 7)` | RenderTileFromKey |
| g_mapSprites [64 + 32c + j] | unit j 0..27 for civ c 0..7 | `T2(16*(j%20), 161 + 16*(j/20), 15, 15)`, cut eight times; InitGameColorTables 10E8:2D46 recolours copy c with ReplaceTileColor | DrawUnit 1110:0DBA, DrawUnitAt 1110:0FF6 (through DrawMapSprite), AnimateUnitMove 11C0:2C32, ResolveCombat 1050:0000, ProcessCity, ShowPediaEntry ([0x60 + type], civ-slot-1 colours) |
| g_improvementIcons (1420:98F4) [0..39] | 36x20 device icons `[5c + r]` | TE `(1154 + 38c, 20r)`, c 0..7, r 0..4 | DrawImprovementIcon 1030:8529, DrawImprovementIconLogical 1030:84BE |
| g_improvementIcons [40], [41] | 36x20 | TE `(1154, 100)`, `(1192, 100)` | same |
| g_statusIconShapes (1420:98E4) [8] | 16x16: research [0..3], global warming [4..7] | TE `(1152 + 16c, 140 + 16r)` | DrawStatusCivPanels 1088:13D5 |
| g_wholeTileShapes (1420:98AE) [0..6] | 32x32 | TE `(1248 + 32i, 100)` | [1..6] coast patterns in RenderTileFromKey 1118:0079 (index = key bits 27..29, values 1..6 only) |
| g_wholeTileShapes [7..10] | 32x32 | TE `(1344 + 32(i-7), 140)` | [8] river base (1118:01B7), [9] Status window background (RedrawStatusWindow 1218:0801) |
| g_windowFrameShapes (1420:98C4) [16] | 16x16 `[8b + 4row + c]` | TE `(1216 + 64b + 16c, 140 + 16row)` | DrawWindowFrameTiles 1098:2260; only [0..7] used (docs graphics.md 2.5, 4.8; the db records no direct DGROUP reference there, so the access is through a loaded segment) |

Cut rectangles: docs graphics.md 4.9, matching the **listing** comments in `egss.txt`. Users:
**db** (DGROUP references of every function except ExtractGameSpriteShapes and FreeAllShapes
1008:075B) and **listing** where an address range is given.

**Windows-only region.** Every TE shape lies at device x 1152..1471 (1152 + 16*3 + 16 = 1216,
1154 + 38*7 + 36 = 1456, 1248 + 32*6 + 32 = 1472). The T2 right-half shapes end at device x
1151 (640 + 2*256). Shapes whose device x is 1152 or more are, per docs graphics.md 4.9,
Windows-specific art (**inferred** there; this task did not compare with the DOS files).

**Unused cuts.** g_wholeTileShapes [0], [7] and [10] have no static reader: the only indexed
reader, RenderTileFromKey 1118:0079, uses coast patterns 1..6 (ComputeTileAppearanceKey 1118:04B4
produces no 0 or 7 there, docs graphics.md 4.10.1), and no function references 1420:98BC or
1420:98C2 (**db**). Status: **inferred** unused.

### 2.2 Shapes cut from other pictures

| Shapes (address) | Picture | Function (address) | Cut | Doubling |
|---|---|---|---|---|
| g_advisorShapes (1420:0128) [4] | 400 + court style of the human | LoadAdvisors 10E8:31AA | TE 53x96 at device `(g_advisorPortraitX[i], 161)`, x = 538, 643, 748, 853 (g_advisorPortraitX 1420:2A52) | device, 1:1 |
| g_leaderBodyTile (1420:B1A0) | 500 + portrait index | LoadLeaderScreen 1160:2A38 | `ExtractScaledTile(181, 67, 139, 133)` | ExtractScaledTile 1160:33FC: logical x*133/100 (32-bit), y*16/10, then TileExtract |
| g_leaderFaceTiles (1420:B168) [14][2] | same | LoadLeaderScreen | eyes 79x30 at device `((cell%5)*79, (cell/5)*81 + 1)`, mouth 79x40 30 rows lower; cells 8, 9, 13, 14 skipped | device |
| court attendants | 400 + court style | LoadLeaderScreen | `ExtractScaledTile(court, 385 + 80*variant, 101, 78, 99)` | x*133/100, y*16/10 |
| g_attendantFrameTiles (1420:B150) [4][3] | same | LoadLeaderScreen | 38x40 at device `(512 + ((k/2)*3 + f)*38, 80 + (k%2)*40)` | device |
| conquered leader | 500 + portrait index | ShowConqueredCivLeader 1180:17E9 | one ExtractScaledTile (**db**; rectangle not read here) | x*133/100, y*16/10 |
| g_palaceSprites (1420:B12E) [section][half] | 0x1169..0x1175 | LoadPalaceSectionSprites 1158:14B7 | device rows 2..160; piece type 0 x 0..84, 1 x 85..124, 2 x 125..164, 3 x 165..210 or 165..220, 4 x 211..256 or 220..275 ("wide" for style 1, or slot 2 in preview) | device; drawn at `(x << 4)/10`, `((y + level + offset) << 4)/10` (logical to device x1.6) |
| city view houses | 0xD09 | LoadCityViewSprites 11B0:1653 | 5 styles x 4 variants, 32x51 logical cells, x scaled 16/10 only | x only |
| city view roads | 0xD0A | LoadCityViewSprites | 16 tiles about 38x13 at `((i&7)*38.4, (i/8)*13 + (knows 0x3A ? 26 : 0))` | device |
| city view buildings | 0xD07 or 0xD08 | LoadCityViewSprites | 79x79 cell at `((i/4)*80 + 1, (i&3)*80 + 1)`, cut only for present buildings, `i == mode-1`, or `i > 20` | device |
| city view wonders | 0xD06 | LoadCityViewSprites | inclusive rects g_wonderSheetRects (13A8:0000), wonders 1..21 of this city | device |
| citizens | 0xD0B | DrawCityViewCitizens 11B0:1316 | 9 frames 57x97 at x = 56i, rows 0..97 or 102..199 (advance 0x23) | device |
| capture soldiers | 0xD10..0xD12 | PlayCityCaptureAnimation 11B0:1B63 | 10 frames about 127x120 | device |
| rioters, celebrants | 0xD0C..0xD0F | PlayCivilDisorderAnimation 11B0:1FAC, PlayCelebrationAnimation 11B0:237C | 10 frames, 4 figures | device |
| city-founded sprites | 0xD13 | ShowCityFoundedAnimation 11B8:14E5 | 4 frames `(1, (16i+1)*192/100) .. (76, (16i+16)*192/100)` | y scaled 192/100 |
| nuclear explosion | 0x90 (144) | AnimateNuclearExplosion 11B8:0C3D | 28 frames 88x88 at `((i%7)*90 + 2, (i/7)*90 + 2)` | device |
| arrival frames | 0x15B5 + i | ShowSpaceshipArrival 11D8:0000 | one frame picture per GR_PicRead (11D8:003B) | device |
| spaceship parts [10] | 0x15CD | OpenSpaceshipScreen 1070:0000 | rects g_spaceshipPartSprites (1420:12AA) `{mass, left, top, width, height}`; width passed as right edge (every left is 0) | device |
| Civilopedia picture tile | 1013+, 1100+, 1200+, 0xD07/0xD08 | ShowPediaEntry 1068:06AF | TileExtract of one cell (srcRect clamped to 427x320), then AnimateTileZoomInRect 1068:1C13 over 5 steps | device; zoom uses g_tileScaleNum/Den |
| quiz picture | 1100 + advance | AskCivilizationQuizQuestion 1178:0022 | TileExtract and DrawTile (**db**; rectangle not read here) | device |
| scratch | - | g_scratchShape32 (1420:AEA2) | freed only (docs) | - |

Sources: docs graphics.md 4.15..4.19, advisors.md 4.2, game-flow.md 4.14.1; ids and call sites
**listing**.

## 3. Fonts

### 3.1 The font file

`civfonts.fon` has 21 FONT resources plus a FONTDIR (**resource**, `enum_fon.py`). All are
raster fonts, weight 400, charset 0.

| FONT ids | Faces | Points | Pixel height | Characters |
|---|---|---|---|---|
| 200..206 | CIVBABYLON, CIVZULU, CIVEGYPT, CIVENGLISH, CIVGREEK, CIVRUSSIAN, CIVGERMAN | 14 | 15 | 32..213 |
| 208 | CIVCHINESE | 14 | 16 | 32..213 |
| 209..212 | CIVFRENCH, CIVROMAN, CIVINDIAN, CIVAMERICAN | 14 | 15 | 32..213 |
| 214, 215 | CIVAZTEC, CIVMONGOL | 14 | 15 | 32..213 |
| 216..222 | CIVTIMES10, 12, 14, 18, 24, 30, 36 | 10, 12, 14, 18, 24, 30, 36 | 11, 12, 15, 18, 24, 34, 38 | 32..255 |

There is no FONT 207 or 213.

### 3.2 Creation and selection

* **CreateCivFonts 1008:0E99** enumerates the installed faces through EnumFunc 1008:0E12, which
  calls CreateFontIndirect for every raster face starting "CIV", into g_civFonts 1420:5484 in
  enumeration order; g_civFontCount 12D8:0022 counts them (docs: text-files.md 2.1,
  platform.md start-up; **db**). The table order is therefore decided by GDI enumeration; the
  port fixes it (port docs DESIGN.md Q22: indices 0..13 the per-civ faces in FONT id order,
  14..20 CIVTIMES10..36). That order is not proven in the original (section 11).
* **SetCivFont 11E8:0B40** maps a font id to an index and stores a line height (docs:
  text-files.md 2.1). Any other id, including 0, leaves the font unchanged.

| Font id | Index | Face (per Q22) | Line height |
|---|---|---|---|
| 1, 2 | 15 | CIVTIMES12 | 12 |
| 3, 8 | 17 | CIVTIMES18 | 18 |
| 4 | 19 | CIVTIMES30 | 30 |
| 5 | 18 | CIVTIMES24 | 24 |
| 6, 7, 207, 213 | 16 | CIVTIMES14 | 14 |
| 200..206 | 0..6 | per-civ | 14 |
| 208..212 | 7..11 | per-civ | 14 |
| 214, 215 | 12, 13 | per-civ | 14 |
| 333 | 20 | CIVTIMES36 | 36 |

* The per-civ ids come from g_tribeLeaderFontIds 1360:0018, whose 0 entries rely on SetCivFont
  ignoring unknown ids (docs: text-files.md 2.1).
* **SetTextFontSizeColor 1068:1F7E** maps family 216 by point size 10, 12, 14, 18, 24, 30, 36
  to indices 14..20. Only this path selects index 14; PaintRandomStatic 1058:05DC can also
  fall back to `g_civFonts[g_currentFontIndex - 1]` (docs: text-files.md 2.1).
* Direct table reads: g_staticFontDefault 1420:519C = g_civFonts[16] (10E8:00B0),
  g_radioFontDefault 1420:51D0 = [16] or [17] (11E0:0A72), WM_SETFONT with [16]/[17] (e.g.
  1098:146E, 10F0:00D9, 1220:183A), SelectObject([15]) at 1030:98DC for the city screen Exit
  button (docs: text-files.md 2.1, cities.md).
* **CreateAndSelectRomanFont 1060:0000**: CreateFont of height 18, only for the dead
  ShowDisplayDriverChecklist 1060:01C1 (**db**: no caller).
* Dialog 138 names CIVTIMES12 12 pt (DS_SETFONT) but is never opened (section 4).
* Movie SetFont items use ids 333/36 and 3/18 (intro, Birth) and 1 with sizes 10, 12, 14
  (About) (section 6).

## 4. Dialogs

### 4.1 Templates and openers

The only CreateDialog call is in GR_DialogOpen 1098:124F (at 1098:12AC); GR_DialogOpenIndirect
is unreferenced (docs: ui-dialogs.md 2.1). Template numbers are treated as pixels: GR_DialogOpen
undoes the dialog-unit scaling with PixelsToDialogUnits 1098:0D43 and sets the current port to
the dialog (SetCurrentPort; **db**). Sizes and styles: **resource**. Openers: **listing** at
each GR_DialogOpen call (`dlgsites-short.txt`, 32 sites).

| Id | Size | Opened at (function) | Flags | Role | F: |
|---|---|---|---|---|---|
| 129 | 305x120 | 1010:0024 ShowAboutBox | 0x41 | About box, plays the About movie | 129; 803 |
| 130 | 512x320 | 1020:0040 ShowCivilopediaEntry; RunListBoxDialog 1098:1931 (from ShowCivilopediaSection) | 0x61 | Civilopedia page and list | 130; 601..606 |
| 131 | 300x282 | RunListBoxDialog 1098:1931 (from ShowFindCityDialog 1068:004C) | 0x61 | Find City list | 131; 104 |
| 135 | 480x87 | 10E0:03C2 ShowTextNoteDialog | 0 | one-line note | 135 |
| 136 | 80x84 | 1220:00FD ShowTextDialog (id in si) | 0 | plain message through MenuZ | 136 |
| 137 | 242x142 | 10F0:007E RunTextEntryDialog | 0x61 | city name and other text entry | 137 |
| 139 | 96x47 | 11E0:06C0 IntroMovieCallback | 0 | title menu (MenuZ) over dialog 148 | 139; Title menu |
| 140 | 324x200 | 1170:0651 ChooseCityProduction | 1 | production list | 140; 702 |
| 141 | 270x41 | 11C0:30BB ShowUnitStackDialog | 0 | unit stack list, resized | 141 |
| 142 | 512x320 | 1160:2251 RequestLeaderAudience (g_leaderDialog 1420:31B4) | 1 | leader audience | 142; Diplomacy screens |
| 143 | 512x320 | 1108:028B CustomizeWorldDialog | 1 | Customize World, picture 140 | 143; Customize World |
| 144 | 512x320 | 10E8:0062 RunNewGameSetup | 1 | setup pages, picture 141 | 144; Start a New Game |
| 145 | 142x86 | 1220:00FD ShowTextDialog (menu mode) | 0 | MenuZ with Help | 145 |
| 146, 147 | 512x320 | 1170:246D CompleteResearch, id 0x92 + di | 0x41 | discovery dialog (147 when the human knows advance 0x36), pictures 142/143 and 1100+ | 146; 147 |
| **148** | **512x320, no controls** | 15 sites, see 4.2 | 0x41, 0x61 or 1 | the empty full-screen picture dialog of every logical-layer screen | 148 |
| 149 | 512x320 | 1178:003C AskCivilizationQuizQuestion | 0x41 | quiz, picture 1100+ | 149 |
| 151 | 512x320, style 0x80800000, no controls | 10E8:10B9 RunNewGameSetup | 0x41 | introduction text after setup | 151 |
| 666 | 300x150 | 10B8:0115 ConvertArtworkFor16ColorDisplay | 0x41 | 16-colour artwork conversion progress | 666 |
| 133 | 142x52 | never opened | - | dead | - |
| 138 | 205x120, DS_SETFONT CIVTIMES12 12 | never opened | - | dead | - |
| 150 | 120x36 | never opened | - | dead | - |
| 999 | 256x160 | never opened | - | dead (leader-portrait test, docs **inferred**) | - |
| 2000 | 198x117 | never opened | - | dead (3D control test) | - |

Flags 0x41 = centre and show, 0x61 = centre, 0x20 and show, 1 = centre (docs: ui-dialogs.md;
**listing** comments).

### 4.2 Dialog 148 and the 512x320 logical-layer dialogs

Dialog 148 is a 512x320 CIVDIALOG with no controls (**resource**). It is the window of every
screen drawn with the logical layer (section 7): 512x320 = 320x200 x 1.6. Its openers
(**listing**, `dlgsites-short.txt`):

| Site | Function | Flags | Port / window global |
|---|---|---|---|
| 11E0:003F | RunIntroAndTitleMenu 11E0:0000 | 0x41 | intro window (movie) |
| 1018:0053 | OpenReportScreenWithHeader 1018:0000 | 0x41 | g_reportWindow 1420:5156 |
| 1188:0031 | OpenBlankReportScreen 1188:0000 | 0x41 | g_reportWindow |
| 1030:00F3 | ProcessCity 1030:0000 | 0x41 | city screen |
| 11B0:0A36 | ShowCityView 11B0:0000 | 0x41 | g_cityViewDialog 1420:B2C4 |
| 11B8:1508 | ShowCityFoundedAnimation 11B8:14E5 | 0x41 | local |
| 1138:0021 | ShowNewspaper 1138:0000 | 0x61 | local |
| 1070:0047 | OpenSpaceshipScreen 1070:0000 | 0x41 | g_spaceshipWindow 1290:0110 |
| 1080:0132 | ShowHallOfFame 1080:0119 | 1 | local |
| 1080:0777 | ShowCivilizationRatingRanking 1080:06FF | 0x41 | local |
| 1158:09B4 | OpenPalaceView 1158:08E7 | 1 | g_palaceWindow 1420:B12A |
| 1180:01D4 | ChooseReplayModeAndOpenWindow 1180:017A | 0x41 | g_replayWindow 1420:B2B0 |
| 1180:1546 | ShowConquerorEnding 1180:152F | 0x41 | g_replayWindow |
| 11D8:0092 | ShowSpaceshipArrival 11D8:0000 | 0x41 | local |
| 11D8:08B4 | ShowCivilizationDestroyed 11D8:087F | 0x41 | local |
| 1060:02A1 | ShowDisplayDriverChecklist 1060:01C1 | 0x41 | dead (no caller, **db**) |

Other 512x320 templates also carry logical-layer drawing while open: 130 (Civilopedia), 142
(leader), 143, 144 and 151 (setup), 146/147 (research), 149 (quiz) (**db**: their drawing
functions call the primitives of section 7).

## 5. Cursors

civ.exe has GROUP_CURSOR 128..143 mapping to CURSOR 1..16, all 32x32, 1 bit per pixel
(**resource**). Only SetGameCursor 1098:096C calls USER.LoadCursor and SetCursor; it caches the
handles in g_cursorCache 1420:1E76 (**db**; docs ui-dialogs.md). SetCursorAndMarkChanged
1200:0078 wraps it. The four registered window classes (CIV, WdwSmMap, WdwStatus, CIVDIALOG) all
have hCursor = 0 (**listing** InitApplication 1098:079C, 07EC, 0836, 0880).

SetGameCursor has 68 call sites and SetCursorAndMarkChanged 2 (**db**); the id at each site was
read from the listing (`cursorsites.txt`).

| Group id | Cursor | Hotspot | Use | Setters (call sites) |
|---|---|---|---|---|
| 128 (0x80) | 1 | (0,0) | none found | no static setter (**inferred** unused) |
| 129 (0x81) | 2 | (3,3) | normal pointer | 29 sites, e.g. WinMain 1008:02CE, GR_DialogOpen 1098:1264, MenuZ 1220:0250, WdwMapProc 1208:052F, ProcessCity 1030:574D/57B1, ShowCityView 11B0:112A, ShowPediaEntry 1068:1224, CustomizeWorldDialog 1108:0311, RunIntroAndTitleMenu 11E0:01B5, IntroMovieCallback 11E0:0605, WaitForKeyOrClick 1038:0C32, WaitTicksOrInput 11D8:0BE7 |
| 130 (0x82) | 3 | (7,7) | small-map pointer | SetSmMapCursor 1210:072A |
| 131 (0x83) | 4 | (7,7) | movie and world-creation pointer | RunIntroAndTitleMenu 11E0:00EE, IntroMovieCallback 11E0:088F, ShowAboutBox 1010:006C, GenerateWorldMap 1028:001F |
| 132 (0x84) | 5 | (4,7) | busy (loading, report opening, skip wait) | 32 sites, e.g. OpenReportScreenWithHeader 1018:012A, OpenBlankReportScreen 1188:0130, LoadGameSpriteSheet 11E0:09DD, BeginWorldCreation 1108:01CA, BirthMovieCallback 11E0:0949, AboutMovieCallback 1010:0101, LoadLeaderScreen 1160:2A4A, OpenPalaceView 1158:091B/09ED, OpenSpaceshipScreen 1070:0037/008F |
| 133 (0x85) | 6 | (14,0) | GoTo | UpdateMapMoveCursor 1208:12B7 |
| 134 (0x86) | 7 | (7,7) | Customize World help | CustomizeWorldWndProc 1108:0774 |
| 135 (0x87) | 8 | (0,0) | none found; 0x87 + direction is the base of the arrows | no static setter (**inferred** unused) |
| 136..143 (0x88..0x8F) | 9..16 | (6,1), (10,1), (12,6), (10,10), (6,12), (1,10), (1,6), (1,1) | map scroll arrows, 0x87 + g_mouseDirectionKey 1..8 | UpdateMapMoveCursor 1208:14A2 (variable id); SetCursorAndMarkChanged 1200:0085 passes its argument |

The hotspots fit the directions N, NE, E, SE, S, SW, W, NW for 136..143 (**inferred** from the
hotspot positions and the 1..8 direction order of docs graphics.md 4.10.1).

## 6. Movies

The movie engine is AdvanceMovie 10B0:0461, run at 60 Hz TickCount frames, with item types
1..14 (docs: graphics.md 4.14). The scripts are static far data; this task parsed them with
`movies.py` (**resource**) and they agree with docs graphics.md 4.14.3. A MovieItem is 30 bytes:
type, rect, start, end, p1..p4, state. Text flags: `p3 & 0xF` alignment (1 centre), 0x10 shadow
in colour+1, 0x100 load the 2 text colours at p4, 0x200 front port, 0x400 redraw every frame,
0x800 back port. Text colour index = p4 + 10.

### 6.1 Intro (13D0:0000, 29 items)

Player: RunIntroAndTitleMenu 11E0:0000 opens dialog 148, calls SetGodPaletteEntries(g_clut129Colors
12B0:005A, 0, 5, 0) at 11E0:0065, creates the movie with IntroMovieCallback 11E0:0221 and loops
`while (!AdvanceMovie(movie))` (**listing**, docs 4.14.4).

| Frames | Items |
|---|---|
| 0 | Blackout entries 0..159; LoadClut 129 (3 entries at 0); SetFont 333/36; FillRect colour 0 |
| 0..3 | FadeIn 3 steps, entries 0..159 |
| 3..5 | Text STR# 137 #1, flags 0x211, p4 1 |
| 5..7 | Callback 4 (caption on non-palette displays) |
| 40 | LoadPicture 128, base 0 |
| 100..140 | FadeOut 40 steps, entries 0..159 |
| 140 | LoadClut 130 (2 entries at 224); SetFont 3/18 |
| 140..1164 | Scroll, one pixel per 2 frames, colours 0..159 |
| 141..161 | FadeIn 20 steps |
| 160..1140 | Text STR# 137 #2..#10 at 160-240, 260-340, 360-490, 510-640, 660-740, 760-840, 860-940, 960-1040, 1060-1140; flags 0x711; p4 224 |
| 1180 | LoadPicture 136, base 176 |
| 1200..1220 | FadeOut 20 steps, entries 0..235 |
| 1220 | Callback 3, rect (5,20,507,165) (logo); SwapAndShow 0..235; FadeIn 1220..1240 20 steps |
| 1260 | Callback 2 (the title menu) |
| 100000..100040 | FadeOut 40 steps, reached by SeekSequence(movie, 100000) after the menu |

IntroMovieCallback 11E0:0221 (**listing**, docs): case 4 caption, case 3 logo composition, case
2 the title menu (dialog 139 at 11E0:06C0, MenuZ, LoadGameSpriteSheet with g_currentMovie set to
NULL, then SeekSequence 100000). On every frame with `frame % 20 == 0` and pending input it sets
skip and seeks to 1164 when `140 < frame < 1164`.

### 6.2 Birth (13D8:0000, 78 items, frames 1000..11500)

Played by RunIntroAndTitleMenu after SeekSequence(movie, 1000), with BirthMovieCallback
11E0:091E; it advances from inside world generation through UpdateActiveAnimation (docs 4.14.4).

| Picture | LoadPicture frame | SwapAndShow frame | FadeIn | FadeOut before the next |
|---|---|---|---|---|
| 128 (x offset 512) | 1000 | 1000 (p3 = 512) | 1000..1100 | 1700..1800 |
| 129 | 1100 | 1800 | 1800..1900 | 2500..2600 |
| 130 | 1900 | 2600 | 2600..2700 | 4300..4400 |
| 131 | 2700 | 4400 | 4400..4500 | 5500..5600 |
| 132 | 4500 | 5600 | 5600..5700 | 6900..7000 |
| 133 | 5700 | 7000 | 7000..7100 | 8700..8800 |
| 134 | 7100 | 8800 | 8800..8900 | 10900..11000 |
| 135 | 8900 | 11000 | 11000..11100 | 11400..11500 (final) |

All fades are 40 steps over entries 0..223; all pictures at base 0. At 1100: LoadClut 130 (2 at
224) and SetFont 3/18. 44 Text items, STR# 139 #1..#44, rect (0,280,512,310), flags 0x111,
colour 224, each `start..start+180` except #44 (11100..11380). Item types used: 2, 3, 4, 5, 6,
7, 9 (**resource**).

### 6.3 Empty (13E0:0000)

Terminator only; used only when g_monochromeMode != 0, which never happens (docs 2.10).

### 6.4 About (1230:0000, 63 items, frames 0..2600)

Played by ShowAboutBox 1010:0000 in dialog 129 with AboutMovieCallback 1010:00D6.

| Frames | Items |
|---|---|
| 0 | Blackout p1 88, p2 128; FillRect 255; LoadPicture 5000 base 152 |
| 1 | LoadClut 130 (3 entries at 224) |
| 10..40, 561..600, 961..1000, 1361..1400, 1761..1800, 2161..2200 | SetFont 1 with size 10, 12 or 14, then Text items STR# 154 into the back port, flags 0x901 or 0x911, rects x 115..300 |
| 40, 600, 1000, 1400, 1800, 2200, 2600 | SwapAndShow rect (0,0,300,115), p1 alternating 152 and 88, count 64, p3 1 |
| 160, 660, 1060, 1460, 1860, 2260 | LoadPicture 5001..5006, bases 88, 152, 88, 152, 88, 152 |

32 Text items: STR# 154 #1..#31 and the version string (p2 = 9191, g_versionString 1420:1796).

### 6.5 Callbacks and skip

| Callback | Address | Skip test |
|---|---|---|
| IntroMovieCallback | 11E0:0221 | frame % 20, input pending (above) |
| BirthMovieCallback | 11E0:091E | frame % 30 |
| AboutMovieCallback | 1010:00D6 | frame % 30 |

Other movie drivers: BeginWorldCreation 1108:01BC (Birth during world creation), StepActiveSequence
10B0:0000 from UpdateActiveAnimation 1098:0157. No shipped script uses types 12, 13 or 14, so
the dissolve code and its random draws never run (docs 4.14.5).

## 7. Logical-layer call sites

### 7.1 The mapping

MapLogicalPointToPort 1220:0F2F maps a 320x200 point and picks the target (docs: graphics.md
4.7; **listing**):

| Kind | Condition | Mapping | Target |
|---|---|---|---|
| 3 | a dialog is open (g_currentDialogPort 1420:9948 non-NULL) | x, y times 1.6 by ScaleLogicalX/Y 11E8:0D81/0DA8 (32-bit, truncating); if g_cityTileDrawMode 1260:002C is set, the map transform instead | g_curWindowPort = the dialog; g_currentGrPort = g_lastNonMainGrPort 1420:17AE; g_graf unchanged |
| 1 | x 0..199 | unchanged | Status window g_statusWindowPort 12B0:0034; current GrPort unchanged |
| 2 | x >= 200, y >= 8 | `(x-200)*2 - g_mapScrollX`, `(y-8)*2 - g_mapScrollY` | SetGrPort(g_mapOffscreenPort 12D8:4542); window g_mapWindowPort 12B0:0004 |
| 0 | otherwise | - | nothing drawn |

### 7.2 Primitives

Callers of MapLogicalPointToPort (9, **db**): DrawScreenText 10D8:01B0, DrawScreenTextWithShadow
10D8:02DF, DrawUnitAt 1110:0FF6 (direct call at 1110:11A6), FillRectLogical 11E8:0504,
DrawShapeAndFlush 11E8:0674, FlushSquareToWindow 11E8:07C3, FrameRectLogical 1220:1086,
FrameRectDoubleDevice 1220:114B and the dead PaintLogicalRect 1088:2335.

| Primitive | Address | Built on | Note |
|---|---|---|---|
| DrawScreenText | 10D8:01B0 | MapLogicalPointToPort | text in the current font |
| DrawShadowedScreenText | 10D8:01FA | DrawScreenTextWithShadow | |
| DrawScreenTextWithShadow | 10D8:02DF | MapLogicalPointToPort | |
| DrawCenteredShadowedScreenText | 10D8:046E | DrawCenteredScreenTextWithShadow | |
| DrawCenteredScreenTextWithShadow | 10D8:0495 | DrawScreenTextWithShadow, GetScreenTextWidth | |
| DrawCenteredScreenText | 10D8:0528 | DrawScreenText, GetScreenTextWidth | |
| GetScreenTextWidth | 10D8:05B8 | - | device width * 10/16 |
| DrawScreenLine | 10D8:0000 | DrawAxisAlignedLine 11E8:0912, then FillRectLogical | axis-aligned only |
| FillRectLogical | 11E8:0504 | MapLogicalPointToPort, ScaleLogicalX/Y | EGA colour via g_egaToSystemColor 12D8:45BE; kind 2 doubles w, h |
| FrameRectLogical | 1220:1086 | same | |
| FrameRectDoubleDevice | 1220:114B | MapLogicalPointToPort (target only) | rectangle in device pixels; only EvaluateAndShowSpaceship |
| DrawShapeAndFlush | 11E8:0674 | MapLogicalPointToPort | position mapped, shape not scaled; flush if g_autoFlushToWindow 12B0:009A |
| FlushSquareToWindow | 11E8:07C3 | MapLogicalPointToPort | 32x32 flush, only DrawUnitAt |
| DrawMapSprite | 11C8:008A | DrawShapeAndFlush | g_mapSprites[index] |
| DrawImprovementIconLogical | 1030:84BE | ScaleLogicalX/Y | |
| DrawBeveledLabelBox | 1030:8C11 | FillRectLogical, DrawScreenLine, DrawCenteredScreenText | only ShowIntelligenceAdvisor |
| TruncateStringToLogicalWidth | 11D0:02E4 | - | |
| ExtractScaledTile | 1160:33FC | - | logical rect to device (x*133/100, y*16/10) in a 427-wide picture |

Dead (no caller, **db**): FillScreenRectInclusive 10D8:0612, DrawTwoToneRect 1220:120A,
PaintLogicalRect 1088:2335, DrawShapeAndFlushReturnZero 11E8:08D6, DrawMessageTextBox 11D0:0010
(a direct ScaleLogicalX/Y user).

### 7.3 Callers grouped by screen

Primitive counts are call sites in the function (**db**, `logical.txt`). "Port" lists the
port-related callees of the function (**db**). All dialog screens draw with kind 3.

| Screen | Functions (address): primitives | Window and offscreen port | How it reaches the window |
|---|---|---|---|
| Report screens (Advisors menu, World menu, end of game) | DrawReportHeader 1018:015D: centred x2, centred shadowed x1; ShowScienceReport 1018:03F0: centred shadowed, DrawMapSprite, text, fill; ShowMilitaryReport 1018:067B: DrawMapSprite, line, text x4; DrawCasualtyReport 1018:09CC: DrawMapSprite, line, text x3, frame; ShowTradeReport 1018:0BE0: text x8, shadowed, truncate; ShowIntelligenceAdvisor 1018:1221: DrawBeveledLabelBox, line, text x4, shadowed; DrawCivDossier 1018:17DB: text x15, shadowed; ShowAttitudeAdvisor 1018:1D5B: icon, text x2, fill; ShowCityStatus 1018:208F: text x4, truncate; ShowCivilizationScore 1040:1137: centred, icon, text, shadowed x5, fill x2; DrawScoreCitizenIcon 1040:1B51: DrawShapeAndFlush; ShowTopFiveCities 1080:099B: centred, centred shadowed, icon, frame; ShowPowerGraph 1188:07AD: centred shadowed, line, text x2, frame; ShowWondersOfTheWorld 1188:0B3E: centred, centred shadowed x2, icon, text, fill, frame, truncate; ShowHistorianReport 1188:0DB8: centred x2, text, fill, frame; ShowDemographicsReport 1188:123A: centred, text x13, shadowed x13; DrawDemographicsRank 1188:220A: line, text, shadowed, width | dialog 148 g_reportWindow 1420:5156 opened by OpenReportScreenWithHeader 1018:0000 or OpenBlankReportScreen 1188:0000; GR_PortOpen g_reportPort 1238:0000 (512x320, god palette), SetGrPort | CloseReportScreen 1018:0380: CopyPortToWindow 512x320, wait for input, close (docs advisors.md); some reports blit earlier with CopyPortToWindow |
| World map (menu 504) | ShowWorldMap 1188:013F: no logical primitive; DrawMapTile at SetTileScale(6/32) with g_tileDrawNoClip | OpenBlankReportScreen, g_reportPort | CopyPortToWindow, CloseReportScreen |
| City screen | ProcessCity 1030:0000: centred x4, icon x3, line x2, text x3, truncate; DrawCityScreenTitle 1030:8B39: centred; DrawCityImprovementList 1030:8D33: truncate x2; DrawUnitAt from ProcessCity | dialog 148 (1030:00F3); g_cityScreenPort 1260:0070 and g_cityOverlayPort 1260:0032 (GR_PortOpen, SetGrPort); g_cityTileDrawMode 1260:002C = 1 while the radius squares are drawn (1030:08DC..09C2, docs globals.md) | CopyPortToWindow |
| City view (menu 704) | ShowCityView 11B0:0000: centred shadowed x2, fill | dialog 148 g_cityViewDialog 1420:B2C4; g_cityViewPort 13B0:00F0 | GR_PortDataToBitmap, CopyPortToWindow; animations blit strips |
| City founded | ShowCityFoundedAnimation 11B8:14E5: centred shadowed, fill | dialog 148; background and work ports (GR_PortOpen, SetGrPort, CopyPortBits) | CopyPortToWindow every 12 ticks |
| Civilopedia | ShowPediaEntry 1068:06AF: icon, text x22, ScaleLogicalX x1, ScaleLogicalY x2 | dialog 130; g_pediaPort 1420:51DC (GR_PortOpen, SetGrPort) | CopyPortToWindow, then AnimateTileZoomInRect blits |
| Spaceship | OpenSpaceshipScreen 1070:0000: fill x2; EvaluateAndShowSpaceship 1070:0327: centred, line x2, text x12, fill x3, FrameRectDoubleDevice | dialog 148 g_spaceshipWindow 1290:0110; g_spaceshipPort 1290:00D2 | CopyPortToWindow |
| Newspaper | ShowNewspaper 1138:0000: centred x3, text x4, width x2, ScaleLogicalY x1 | dialog 148 (0x61); local GR_PortOpen, SetGrPort | CopyPortToWindow |
| Hall of Fame | ShowHallOfFame 1080:0119: GetScreenTextWidth only | dialog 148; picture port of 5600 | CopyPortToWindow |
| Rating ranking | ShowCivilizationRatingRanking 1080:06FF: centred x5 | dialog 148; no offscreen port (**db**) | draws into the dialog's current port set by GR_DialogOpen (**inferred**) |
| Palace | RunPalaceImprovement 1158:0000: centred shadowed x2, shadowed x3; OpenPalaceView 1158:08E7: fill (the clear, before the port exists) | dialog 148 g_palaceWindow 1420:B12A; g_palacePort 1350:0056 | GR_PortDataToBitmap, CopyPortToWindow |
| Replay and endings | ChooseReplayModeAndOpenWindow 1180:017A: fill x2; ShowReplayLine 1180:0E78: text, fill; ShowConquerorEnding 1180:152F: centred shadowed x2, fill; ShowConqueredCivLeader 1180:17E9: centred shadowed x2, ExtractScaledTile | dialog 148 g_replayWindow 1420:B2B0; GR_PortOpen, SetGrPort; g_conquestBackgroundPort 1390:001C | CopyPortToWindow, CopyPortBits |
| Spaceship arrival, civilization destroyed | ShowSpaceshipArrival 11D8:0000: fill; ShowCivilizationDestroyed 11D8:087F: fill | dialog 148; GR_PortOpen, SetGrPort, CopyPortBits | CopyPortToWindow |
| Setup | RunNewGameSetup 10E8:0000: centred x6 | dialogs 144 and 151; GR_PortOpen | CopyPortToWindow, BlitDCRect |
| Quiz | AskCivilizationQuizQuestion 1178:0022: centred x2 | dialog 149; GR_PortOpen | CopyPortToWindow |
| Unit stack | DrawUnitStackList 11C0:3407: text x2, DrawUnitAt | dialog 141 from ShowUnitStackDialog 11C0:3023; GR_PortOpen, SetGrPort | CopyPortToWindow |
| Map window | DrawUnitAt 1110:0FF6: DrawMapSprite x2, shadowed x3, DrawShapeAndFlush, FlushSquareToWindow, direct MapLogicalPointToPort | kind 2: g_mapOffscreenPort 12D8:4542, window g_mapWindowPort 12B0:0004; kind 1 from DrawUnitInfoPanel (Status window, g_statusBackPort 12D8:4580); kind 3 from the city screen and unit stack | FlushSquareToWindow / DrawShapeAndFlush CopyPortToWindow when g_autoFlushToWindow |

Notes:
* In kind 3 the drawing goes to g_graf, which the caller set with SetGrPort (the offscreen port
  above); the text routines draw with g_pScreenPort 1420:2990 as the port argument, which they
  do not read (docs graphics.md 4.7).
* ScaleLogicalX/Y are also called directly by ShowPediaEntry, ShowNewspaper,
  DrawImprovementIconLogical, FillRectLogical, FrameRectLogical, MapLogicalPointToPort and the
  dead DrawMessageTextBox and PaintLogicalRect (**db**).

## 8. Pixels read as data

Pixels or palettes that the core reads back as data. Such pictures and shapes must never be
substituted on the core side; the DOS profile substitutes only in the presentation (extension
prompt section 8).

| # | What is read | Reader (address) | Why substitution would change the core |
|---|---|---|---|
| 1 | Picture 137 (EARTH), all 64,000 pixels | GenerateWorldMap 1028:0000: GR_PicRead at 1028:0096, then 1028:0096..00D8 locks the raw bits, subtracts 10 from 0xFA00 bytes and copies them with hmemcpy into g_lpScreenBuffer 1420:B394 (**listing**) | the pixels are the EARTH terrain map; GR_PicRead skips dithering for 137 for this reason (docs palette-pictures.md 2.5) |
| 2 | Picture 200 row 399, first 21 bytes | ExtractGameSpriteShapes 10E8:231F (**listing**, docs graphics.md 4.9) | they set g_shapeTransparentColor 12D8:44FB, the civ light/dark key colours 12D8:44F9/44FA, g_civLightColor 12D8:45CE and g_civDarkColor 12D8:45DE [8 each], panel fill 12D8:44FC and border 12D8:44FD; used by ReplaceTileColor (InitGameColorTables 10E8:2D46, DrawMapTile, DrawUnitAt) and as the transparent colour of almost every shape draw. DitherPictureTo16Colors rewrites them from g_pic200LegendRow 12F8:0000 so they survive the 16-colour conversion |
| 3 | Picture 200 palette, entries 1..64 of g_hColorTable 1420:B388 | InitGameColorTables 10E8:2D46 | it derives g_egaNearestColors 12D8:45FE and g_uiColors 12D8:45EE by nearest RGB (docs palette-pictures.md) |
| 4 | Port pixels via GetPixel | GetPortPixelIndex 1070:127A (GetPixel, then FindGodPaletteIndexForRGB 10B0:168A); sites EvaluateAndShowSpaceship 1070:0422 and AnimateSpaceshipStarfield 1070:14A6, 14E8, 1528, 1566 (**db**, **listing**) | g_spaceBackgroundColor 1290:00D0 is sampled at (2,13) of g_spaceshipPort; a star is drawn only where every covered pixel equals it. The wrap draw `RandomBelow(307)` happens either way, so the RNG stream does not depend on the pixels; what is drawn does |
| 5 | Shape opaque bounds | GetTileOpaqueBounds 11A8:00FE; sites DrawUnitAt 1110:11CC, ShowPediaEntry 1068:0B16 and 15DD (**db**) | the opaque rectangle of the unit sprite positions decorations in DrawUnitAt and centres the unit sprite in the Civilopedia |
| 6 | Leader portrait first raw pixel | LoadLeaderScreen 1160:2A38 sets g_leaderTransparentColor 1378:0068 (docs graphics.md 4.17) | transparent colour of the leader body |
| 7 | Shape top-left pixel (key 0) | DrawTile 11A8:0CB1, DrawTileToPortPixels 11A8:15CE and every caller passing 0: advisor portraits, palace, city view, leader, nuclear explosion, Civilopedia zoom (docs graphics.md 2.4, 4.15..4.19) | the transparent colour comes from the art |
| 8 | Top-left or top-right pixel of a picture | DitherPictureTo16Colors 10C8:0000 (16-colour displays only) | key colour of the conversion (docs graphics.md 4.13) |
| 9 | g_lpScreenBuffer 1420:B394 (the 320x200 virtual screen) | GetScreenBufferPixel 11E8:0DCF (89 sites), SetScreenBufferPixel 11E8:0E19 (47 sites) (**db**) | it is the map data layer of world generation and play (terrain, river bit read by ComputeTileAppearanceKey at y + 150); never displayed on Windows. It is fed by picture 137 on EARTH |
| 10 | Dead readers | GetPortPixelAtOffset 10B0:1749 (GetPixel), TestPaletteIdentityMapping 1090:0000 (GetSystemPaletteEntries), GR_PortChangeColor 10D0:09EE (GetBitmapBits) (**db**: no callers) | none at run time |

Rendering-only reads, not data: GetBitmapBits in PortTileBlt 11A8:0450 and DrawTileImpl
11A8:0F56 (**db**). These are the only GetPixel, GetBitmapBits, GetDIBits and palette-read API
users in the program (**db**, search of `apis`).

## 9. Palette effects

### 9.1 Timed effect: CyclePaletteColors

**CyclePaletteColors 1208:22B7** rotates god entries 64..71 (system 74..81). It runs on WM_TIMER
from WdwMapProc (call at 1208:01AF). Timer 1 with 200 ms is set by WdwMapOpen (SetTimer at
1208:0E68..0E7B). It pauses while g_mapWindowLocked 12B0:0000 is set and returns at once on
non-palette displays (**listing**; docs palette-pictures.md 2.4). It is the only timed palette
animation outside the movie engine (**db**: its one caller is WdwMapProc; no other palette
routine is driven by a timer).

### 9.2 Fades

All fades belong to the movie engine: CreatePaletteFade 10A8:0000, StepPaletteFadeIn 10A8:00FC,
StepPaletteFadeOut 10A8:018E and ApplyPaletteFadeLevel 10A8:0228 are reached only from
AdvanceMovie and DestroySequencePlayer (**db**). The fades are the type 3/4 items of section 6.

### 9.3 Movie palette items

| Type | Effect | Address |
|---|---|---|
| 1 Blackout | entries p1..p2-1 black, then SetGodPaletteEntries(lp, p1, p2, p1) | AdvanceMovie, SetGodPaletteEntries at 10B0:07D6 |
| 2 LoadClut | 129 = g_clut129Colors 12B0:005A, 130 = g_clut130Colors 12B0:0082, 133 = g_clut133Colors 12B0:006E into the movie palette copy | AdvanceMovie |
| 3, 4 FadeIn / FadeOut | CreatePaletteFade and steps | 10A8:0000..0228 |
| 7 Text | AnimatePortPalette(window, hPalette, p4, 2) for the text colours | 10B0:1144 |
| 9 SwapAndShow | copies p1..p1+p2-1 of the new front port; applies them with SetGodPaletteFromHandle when p3 == 1 | AdvanceMovie |
| 11 Scroll | BlackOutPortPaletteRange 1098:25B9 on the first frame | AdvanceMovie |
| 12, 14 | dissolve merge, palette cycle; never used | - |

RedrawSequenceWindow 10B0:03B0 re-applies entries 16..235 from the movie palette.

### 9.4 Static sets

| Effect | Entries | Site (**listing**) |
|---|---|---|
| sprite-sheet colours on the map window | 0..0x47 from g_hColorTable | WinMain 1008:023D (AnimatePortPalette) |
| intro start colours | 0..4 from g_clut129Colors | RunIntroAndTitleMenu 11E0:0065 |
| Civilopedia text colours | 233..235 from g_pediaColors 12B0:004E, with PushPalette 1090:015E / PopPalette 1090:02D2 (restores 0..235 at 1090:032E) | ShowPediaEntry 1068:0763 |
| caption colours | 0xE9, 0xEA from g_clut130Colors | ShowSpaceshipArrival 11D8:0325 and 06E1; ShowCivilizationDestroyed 11D8:0A82 |
| all black | 0..235 | ZeroGodPalette 1090:05DB (no caller, **db**) |
| identity test | 5 entries | TestPaletteIdentityMapping 1090:004B (dead) |

The god palette itself is built by InitGodPalette 1090:0488 from WinMain (**db**).

### 9.5 AnimatePaletteFromGrPort (1200:0116), 26 sites

| First / count | Sites |
|---|---|
| 0x48 / 0x50 | MenuZ 1220:0B3F, DrawAdvisorPortrait 1018:2514, AnimateNuclearExplosion 11B8:0C8B (map window), ShowConqueredCivLeader 1180:184B |
| 0x48 / 0x40 | CompleteResearch 1170:24A2 |
| 0x88 / 0x60 | CompleteResearch 1170:25BB |
| 0x48 / 0x60 | ShowCityView 11B0:0ACA |
| 0xA8 / 0x40 | PlayCelebrationAnimation 11B0:243D, PlayCivilDisorderAnimation 11B0:2114, PlayCityCaptureAnimation 11B0:1D5F, DrawCityViewCitizens 11B0:134D |
| 0x48 / 0xA0 | LoadLeaderScreen 1160:2C58, ShowPediaEntry 1068:1199, OpenSpaceshipScreen 1070:0122, ShowHallOfFame 1080:018D, OpenPalaceView 1158:0A81 and 0B4E, ShowCivilizationDestroyed 11D8:0910, ShowSpaceshipArrival 11D8:010F and 0644, AskCivilizationQuizQuestion 1178:0208, ShowCityFoundedAnimation 11B8:15A2 |
| 0x10 / 0xE0 | CustomizeWorldDialog 1108:0302, RunNewGameSetup 10E8:0154 |
| 0x98 / 0x50 | ShowConquerorEnding 1180:165E |
| variable | ShowPictureInWindow 1068:0674 (dead) |

CopyPaletteEntries 1098:201D (27 sites, **db**) copies the same ranges between colour tables so
that a later bitmap rebuild keeps them; it does not touch the screen palette.

## 10. Probe list (prompt 5.2 O2)

The D0 inventory fixes the observer's probe list (prompt 5.2 O2). Added 2026-10-11 by fixer F3
(review R3-6). Facts: **db** (call sites, `call_sites_in`) and **listing** (prototypes and the
instruction at each call site, showfunc); the purposes are **inferred** from the tables of
`DOS-PROFILE.md` that consume them.

Conventions:
* A probe fires on function entry in `fr_enter`. Its key is the original **function start**
  (column "Key"). An exit probe (in `fr_leave`) is listed only where a result or a later state is
  needed.
* Where a scene needs one particular caller, the row gives the **call site**: the address of the
  call instruction in the caller. The probe then filters on the return address, which is the
  address of the instruction after that call.
* Arguments are read from the emulated frame, read-only, with the names of the prototype in
  `claude/docs/db` (showfunc "Prototype" line).
* "Sites" is the number of static call sites (**db**). "–" means the function is reached through
  a pointer (window procedure or movie callback) and has no static call site.
* O2 column: the bullet of prompt 5.2 O2 the probe serves:

| Code | O2 bullet |
|---|---|
| a | logical-layer routines (graphics.md 4.7), before the 1.6 or 2 scaling |
| b | text functions at the level where the game chooses alignment (5.10) |
| c | picture loads and shape cutting, with source picture and rectangle |
| d | recolouring and tile-cache inserts |
| e | movie items: AdvanceMovie dispatch, SeekSequence, skips |
| f | scene entries and exits of the scene table |
| g | DrawMapTile, DrawUnitAt, DrawCityLabels, and the DrawTilesToPort mode and order |

### 10.1 Logical layer (O2 a)

| Probe | Key | Kind | Arguments read | Sites | Purpose |
|---|---|---|---|---|---|
| MapLogicalPointToPort | 1220:0F2F | entry, exit | `*px`, `*py` (logical on entry, device on exit), result (0 = not drawn) | 9 | target kind of the enclosing primitive (7.1): dialog, status window or map |
| DrawScreenText | 10D8:01B0 | entry | text, x, y, egaColor; font = word +10h of g_pScreenPort | 105 | left-aligned text at a logical point |
| DrawShadowedScreenText | 10D8:01FA | entry | text, x, y, egaColor (shadow colour 0) | 28 | shadowed text |
| DrawScreenTextWithShadow | 10D8:02DF | entry | text, x, y, egaColor, shadowEgaColor | 2 | shadowed text (also reached from the two above) |
| DrawCenteredShadowedScreenText | 10D8:046E | entry | text, centerX, y, egaColor | 15 | centred shadowed text (alignment chosen here) |
| DrawCenteredScreenTextWithShadow | 10D8:0495 | entry | text, centerX, y, egaColor, shadowEgaColor | 1 | centred shadowed text |
| DrawCenteredScreenText | 10D8:0528 | entry | text, centerX, y, egaColor | 31 | centred text |
| GetScreenTextWidth | 10D8:05B8 | entry, exit | text; result (device width × 10/16) | 6 | layouts that place text by its width (Hall of Fame, DrawDemographicsRank) |
| DrawScreenLine | 10D8:0000 | entry | x1, y1, x2, y2, egaColor | 17 | lines (DrawAxisAlignedLine 11E8:0912 is reached only from here and needs no probe) |
| FillRectLogical | 11E8:0504 | entry | port, x, y, width, height, color (EGA) | 23 | fills |
| FrameRectLogical | 1220:1086 | entry | x, y, width, height, egaColor | 5 | outlines |
| FrameRectDoubleDevice | 1220:114B | entry | x, y, width, height (device), egaColor | 1 | the device-pixel outline of EvaluateAndShowSpaceship |
| DrawShapeAndFlush | 11E8:0674 | entry | port, x, y, hShape | 4 | a shape at a logical point (the handle names the shape through 10.3) |
| FlushSquareToWindow | 11E8:07C3 | entry | x, y | 1 | DrawUnitAt's 32x32 flush |
| DrawMapSprite | 11C8:008A | entry | spriteIndex, x, y | 5 | g_mapSprites[index] at a logical point (reports, scores) |
| DrawImprovementIconLogical | 1030:84BE | entry | improvementId, x, y | 8 | improvement icons |
| DrawBeveledLabelBox | 1030:8C11 | entry | x1, y1, x2, y2, label, color | 1 | ShowIntelligenceAdvisor's labels |
| TruncateStringToLogicalWidth | 11D0:02E4 | entry, exit | str, logicalWidth; the string on exit | 6 | the cut text, re-cut with DOS metrics |
| ExtractScaledTile | 1160:33FC | entry, exit | port, x, y, width, height (logical, 427-wide picture); handle | 3 | leader and conquered-leader tiles (also O2 c) |
| ScaleLogicalX | 11E8:0D81 | entry | v | 8 | direct scaling by ShowPediaEntry, ShowNewspaper, DrawImprovementIconLogical (7.3 notes) |
| ScaleLogicalY | 11E8:0DA8 | entry | v | 9 | as ScaleLogicalX |

### 10.2 Text at the alignment level (O2 b)

| Probe | Key | Kind | Arguments read | Sites | Purpose |
|---|---|---|---|---|---|
| DrawTextInRect | 1098:0ED1 | entry | text, rect, flags (alignment), colorIndex | 24 | text in dialog rectangles (R elements and N dialogs) |
| TextBoxSetup | 1068:2072 | entry, exit | text, rect; the returned handle and `*pBottomDelta` | 14 | wrapped text boxes; the handle ties the text to its draw |
| TextBoxDraw | 1068:258F | entry | hTextBox, justify | 2 | draw of a prepared box |
| TextBoxDrawAndClose | 1068:255A | entry | hTextBox, justify | 13 | as TextBoxDraw |
| DrawTextAtPortXY | 10D8:00E0 | entry | text, x, y, egaColor | 19 | text at port coordinates |
| ShowTextDialog | 1220:00D2 | entry, exit | text (header and option lines); result | 90 | message and menu text of dialogs 136 and 145 |
| MenuZ | 1220:0156 | entry, exit | dlg, text, x, y, colorIndex, autoSize, backdrop; the chosen index | 5 | MenuZ option text and the choice (R and N menu boxes) |
| SplitMenuText | 1220:0000 | exit | items, `*maxWidth` | 1 | the option strings as MenuZ splits them |
| PaintRandomStatic | 1058:04F6 | entry | hwnd, hdc (text from the `w16` control) | 1 | static text controls |
| PaintRandomRadio | 1058:0000 | entry | hwnd, hdc, textColor | 1 | radio-button text (MenuZ options) |
| SetCivFont | 11E8:0B40 | entry | fontId | 41 | the font id for the 5.10 font map |
| SetTextFontSizeColor | 1068:1F7E | entry | fontId, pointSize, face, colorIndex | 5 | family-216 fonts chosen by point size |
| LoadKingText | 11D0:01F7 | entry | name (section) | 46 | static-text source (`KING.TXT` section of the same name) |
| LoadTextResource | 11D0:00E4 | entry | prefix, name | 3 | static-text source (`HELP.TXT`, `ERROR.TXT`) |
| SubstituteTextTokens | 11D0:022D | exit | the substituted text buffer (no arguments) | 9 | dynamic parts of a section text |

The logical text routines of 10.1 are also text probes: their centred variants carry the
alignment. TextOut centring in non-dialog windows (docs text-files.md 4.5) is not resolved here
(Open 6); D1 decides whether those windows need a further probe.

### 10.3 Pictures and shape cutting (O2 c)

| Probe | Key | Kind | Arguments read | Sites | Purpose |
|---|---|---|---|---|---|
| GR_PicRead | 10B8:079D | entry, exit | picId, colorBase, port; result | 34 | picture loads (the 1.2 table by call site) |
| LoadPictureToPortBitmap | 10B8:0E00 | entry, exit | picId, colorBase, port; result | 12 | picture loads |
| ExtractPictureTile2x | 11E8:097C | entry, exit | xBase, x, y, width, height (logical); the handle | 20 | sprite-sheet shapes (all in ExtractGameSpriteShapes 10E8:231F) |
| ExtractPictureTile1x | 10E8:33B9 | entry, exit | xBase, x, y, width, height; the handle | 1 | the one 1x shape |
| TileExtract | 11A8:05C7 | entry, exit | port, `*pRect`; the handle | 46 | every other shape: source port and rectangle |
| GetTileOpaqueBounds | 11A8:00FE | exit | hTile, `*pBounds`, transparentColor | 3 | core data read from shapes (8 #5) |
| DrawTile | 11A8:0CB1 | entry | hTile, port, x, y, transparentColor | 45 | shape draws outside the logical layer (sparks at call site 1050:0AEA, palace, city view) |

LoadGifPicture 10B8:11BC is reached only from GR_PicRead and needs no probe. The handle returned
on exit ties each later draw of a shape to its source picture and rectangle.

### 10.4 Recolouring and the tile cache (O2 d)

| Probe | Key | Kind | Arguments read | Sites | Purpose |
|---|---|---|---|---|---|
| ReplaceTileColor | 11A8:022F | entry | hTile, fromColor, toColor | 6 | recoloured shapes (civilization colours, sentry) |
| TileCacheInsert | 1110:01A3 | entry, exit | appearanceKey, terrainType, hShape; the bitmap | 1 | cache key to bitmap |
| TileCacheLookup | 1110:030C | exit | appearanceKey, terrainType; the bitmap or 0 | 1 | cache hits (a hit draws no new tile) |

### 10.5 Movies (O2 e)

| Probe | Key | Kind | Arguments read | Sites | Purpose |
|---|---|---|---|---|---|
| CreateSequencePlayer | 10B0:008A | entry | window, startOffset, commandCount, commands (the script), callback | 3 | which movie starts; call site 11E0:00A0 = the intro movie (T1 start of the intro) |
| AdvanceMovie | 10B0:0461 | entry, exit | movie: the script and the current frame before and after; result (finished) | 4 | the items dispatched in a step: those of the static script between the two frames (the item switch is inside the function and has no probe of its own) |
| IntroMovieCallback | 11E0:0221 | entry | movie, frame, item | – | per-frame intro events; the title-menu case (row 2) |
| BirthMovieCallback | 11E0:091E | entry | movie, frame, item | – | per-frame Birth events |
| SeekSequence | 10B0:005B | entry | player, frame | 3 | call site 11E0:01A5 = frame 1000, Birth start (T1); 11E0:090D = frame 1164, the intro skip (T5); 11E0:0884 = frame 100000, after the title choice |
| SetGameCursor | 1098:096C | entry | cursorId | 68 | the Birth skip: call site 11E0:0949 (cursor 132, set together with g_movieSkipRequested) |
| UpdateActiveAnimation | 1098:0157 | entry | none | 66 | Birth progress from world generation (StepActiveSequence 10B0:0000 is its only callee of interest) |
| DestroySequencePlayer | 10B0:0287 | entry | player | 4 | the end of a movie |

### 10.6 Map (O2 g)

| Probe | Key | Kind | Arguments read | Sites | Purpose |
|---|---|---|---|---|---|
| DrawTilesToPort | 1208:1866 | entry, exit | window, mode, port | 1 | the redraw mode (1 = randomised full redraw) and its extent |
| RedrawMapSquare | 1110:1461 | entry | x, y | 32 | the redraw order: inside DrawTilesToPort its call sites are 1208:1B40 and 1208:1C5F |
| DrawMapTile | 1110:04D0 | entry | x, y, screenX, screenY | 2 | one square (call sites RestoreBlockXY 1110:04AB, ShowWorldMap 1188:047A) |
| ComputeTileAppearanceKey | 1118:04B4 | exit | x, y; the key | 1 | the square's appearance (coasts, rivers, improvements) |
| DrawUnitAt | 1110:0FF6 | entry | civ, unit, vx, vy | 5 | a unit at a logical position |
| DrawUnit | 1110:0DBA | entry | civ, unit | 12 | a unit on its square |
| CollectVisibleCityLabels | 1208:1DD7 | entry | left, top, right, bottom | 2 | the label set |
| DrawCityLabels | 1208:1F64 | entry | updateRect | 4 | city labels (call sites 1208:1B66 and 1208:1CA8 inside DrawTilesToPort) |
| SetTileScale | 11A8:002C | entry | numerator, denominator | 19 | the world-map scale (6/32) |

### 10.7 Scene entries and exits (O2 f)

These are the probes of the scene table (`DOS-PROFILE.md` 1.1..1.5; "row" there). An exit is
the function's return unless stated.

| Probe | Key | Call site (filter) | Kind | Arguments read | Rows |
|---|---|---|---|---|---|
| RunIntroAndTitleMenu | 11E0:0000 | – | entry, exit | none | 1 |
| CreateSequencePlayer | 10B0:008A | 11E0:00A0 | entry | as 10.5 | 1 (T1 start) |
| SetGodPaletteEntries | 1090:0376 | 11E0:0065 | entry | src, srcStart, count, dstStart | 1 (intro start colours, E10) |
| GR_DialogOpen | 1098:124F | each site below | entry, exit | dialogId, flags; `*ppPort` on exit | 10..28 and every dialog-148 scene |
| GR_DialogClose | 1098:1612 | – | entry | port | dialog exits |
| IntroMovieCallback | 11E0:0221 | GR_DialogOpen at 11E0:06C0 | entry | movie, frame, item | 2, 16 |
| MenuZ | 1220:0156 | – | entry, exit | as 10.2 | 2, 8, 14, 22 |
| BeginWorldCreation | 1108:01BC | from RunIntroAndTitleMenu, call site 11E0:01AD | entry, exit | none | 3 |
| LoadGameFromFileDialog | 1130:000E | from IntroMovieCallback, call site 11E0:0802 | entry, exit | hwndOwner; result | 4 |
| GenerateWorldMap | 1028:0000 | from BeginWorldCreation, call site 1108:0211; GR_PicRead of 137 at call site 1028:0096 | entry | useEarthMap | 5 |
| CustomizeWorldDialog | 1108:0243 | GR_DialogOpen at 1108:028B | entry, exit | worldParams; result | 6, 20 |
| CustomizeWorldWndProc | 1108:0705 | – | entry | hwnd, msg, wParam, lParam | 6 (help mode, cursor 134) |
| LoadHallOfFame | 1080:0023 | – | entry | none | 7 |
| ShowHallOfFame | 1080:0119 | from IntroMovieCallback 11E0:0842 (view) or InsertHallOfFameEntry 1080:06E2 | entry, exit | newEntrySlot (−1 = view) | 7, 105, 129 |
| SeekSequence | 10B0:005B | 11E0:01A5 | entry | player, frame (1000) | 9 (T1 start) |
| BirthMovieCallback | 11E0:091E | – | entry | movie, frame, item | 9 |
| UpdateActiveAnimation | 1098:0157 | – | entry | none | 9 |
| ShowAboutBox | 1010:0000 | GR_DialogOpen at 1010:0024 | entry, exit | none | 10, 95 |
| ShowCivilopediaEntry | 1020:0000 | GR_DialogOpen at 1020:0040 | entry, exit | index, kind | 11, 99 |
| ShowCivilopediaSection | 1068:0295 | RunListBoxDialog at 1068:0544 | entry, exit | section | 11, 79..84, 99 |
| RunListBoxDialog | 1098:1909 | GR_DialogOpen at 1098:1931; callers 1068:0544 (Civilopedia), 1068:0183 (Find City) | entry, exit | dialogId, pictureId, itemCount, items, numColumns; `*pSelection` and result | 11, 12, 79..84 |
| ShowFindCityDialog | 1068:004C | RunListBoxDialog at 1068:0183 | entry, exit | none | 12, 32 |
| ShowTextNoteDialog | 10E0:03A2 | GR_DialogOpen at 10E0:03C2 | entry, exit | prefix, name, title, fontId, pointSize, bgColor, titleColor, textColor | 13 |
| ShowTextDialog | 1220:00D2 | GR_DialogOpen at 1220:00FD (id 136 or 145) | entry, exit | as 10.2 | 14, 22, 137 (call site 1088:19FB) |
| PromptCityName | 10F0:0000 | from FoundCity 1040:00FF or ProcessCity 1030:5F7F (rename) | entry, exit | cityIndex | 15, 89 |
| RunTextEntryDialog | 10F0:0066 | GR_DialogOpen at 10F0:007E | entry, exit | promptIndex, maxLen; result | 15, 89 |
| ChooseCityProduction | 1170:05CA | GR_DialogOpen at 1170:0651 | entry, exit | civ, city; result | 17, 86 |
| ShowUnitStackDialog | 11C0:3023 | from MoveCivUnits 11F0:0BFA; GR_DialogOpen at 11C0:30BB | entry, exit | civ, unit; result | 18 |
| RequestLeaderAudience | 1160:20C0 | GR_DialogOpen at 1160:2251 | entry, exit | civ, mapX, mapY | 19, 100 |
| LoadLeaderScreen | 1160:2A38 | – | entry | civ | 19 |
| HoldDiplomaticAudience | 1160:0000 | – | entry, exit | civ, mapX, mapY, humanInitiated | 19, 100 |
| RunNewGameSetup | 10E8:0000 | GR_DialogOpen at 10E8:0062 (144) and 10E8:10B9 (151) | entry, exit | none | 21, 27 |
| RunTextInputDialog | 1220:16FD | from RunNewGameSetup 10E8:056A | entry, exit | dlgPort, promptText, textBuffer, promptRect, editRect; the text on exit | 21 |
| CompleteResearch | 1170:21B3 | GR_DialogOpen at 1170:246D (id 0x92 + di) | entry, exit | player, sourceCiv | 23, 24 |
| AskCivilizationQuizQuestion | 1178:0022 | GR_DialogOpen at 1178:003C | entry, exit | firstAttempt; result | 26 |
| ConvertArtworkFor16ColorDisplay | 10B8:0000 | GR_DialogOpen at 10B8:0115 | entry | none | 28 |
| HandleMenuCommand | 1048:01CD | – | entry | commandId, lParam | 29..95, 121 |
| PostOrderMenuKey | 1008:0ADD | – | entry | orderIndex | 51..66 |
| OpenGameHelp | 1048:04E8 | – | entry, exit | none | 94 |
| WdwMapOpen | 1208:0AF1 | – | entry | none | 96 |
| RedrawMapWindow | 1208:17DA | – | entry | window, mode | 96 |
| RedrawSmMap | 1210:073F | – | entry | port | 96 |
| DrawSmTiles | 1210:09B4 | – | entry | port | 139 |
| RedrawStatusWindow | 1218:0801 | – | entry | window | 96 |
| DrawStatusCivPanels | 1088:13D5 | – | entry | none | 136, 137 |
| DrawUnitInfoPanel | 11F0:468C | – | entry | civ, unit | 138 |
| ProcessCity | 1030:0000 | GR_DialogOpen at 1030:00F3 | entry, exit | cityIndex, mode | 85, 90..93, 97 |
| CityScreenWndProc | 1030:9C17 | – | entry | hwnd, msg, wParam, lParam | 97 (I-city clicks) |
| ShowCityView | 11B0:0000 | – | entry, exit | cityIndex, mode | 88, 97 |
| OpenReportScreenWithHeader | 1018:0000 | – | entry | title, bgColor | 67..72, 98 |
| OpenBlankReportScreen | 1188:0000 | – | entry | bgEgaColor | 73, 76, 77, 98 |
| CloseReportScreen | 1018:0380 | – | entry | none | 98 (exit of a report) |
| ShowCityStatus | 1018:208F | – | entry, exit | civ | 67 |
| ShowMilitaryReport | 1018:067B | – | entry, exit | civ | 68 |
| DrawCasualtyReport | 1018:09CC | – | entry | civ | 68 |
| ShowIntelligenceAdvisor | 1018:1221 | – | entry, exit | none | 69 |
| DrawCivDossier | 1018:17DB | – | entry | civ | 69 |
| ShowAttitudeAdvisor | 1018:1D5B | – | entry, exit | civ | 70 |
| ShowTradeReport | 1018:0BE0 | – | entry, exit | civ | 71 |
| ShowScienceReport | 1018:03F0 | – | entry, exit | civ | 72 |
| ShowWondersOfTheWorld | 1188:0B3E | – | entry, exit | none | 73 |
| ShowTopFiveCities | 1080:099B | – | entry, exit | none | 74 |
| ShowCivilizationScore | 1040:1137 | – | entry, exit | civ, display | 75 |
| ShowWorldMap | 1188:013F | – | entry, exit | unused | 76 |
| ShowDemographicsReport | 1188:123A | – | entry, exit | civ | 77 |
| ShowPediaEntry | 1068:06AF | – | entry, exit | window, rect, category, index, title | 11, 99 |
| ShowSpaceshipOfChosenNation | 1070:1F58 | – | entry, exit | none | 78 |
| OpenSpaceshipScreen | 1070:0000 | – | entry | none | 78, 102 |
| EvaluateAndShowSpaceship | 1070:0327 | – | entry, exit | civ, displayTicks, allowLaunch | 102 |
| AnimateSpaceshipStarfield | 1070:12B5 | – | entry | none | 102 |
| HumanPlaceSpaceshipPart | 1070:1952 | – | entry, exit | civ, partCategory | 102 |
| LaunchSpaceship | 1070:2015 | – | entry | civ | 102 |
| ShowNewspaper | 1138:0000 | AnnounceGovernmentChange at 10E8:335E for New Cabinet | entry, exit | cityIndex (−2 = New Cabinet) | 101, 119 |
| AnnounceGovernmentChange | 10E8:32C1 | – | entry | none | 119 |
| SetGovernment | 1168:06C1 | – | entry | civ, newGovernment | 115 |
| RunReplayMenu | 1180:0000 | – | entry, exit | none | 103 |
| ChooseReplayModeAndOpenWindow | 1180:017A | – | entry | none | 103 |
| PlayReplay | 1180:02D3 | – | entry, exit | none | 103 |
| ShowReplayLine | 1180:0E78 | – | entry | none | 103 |
| ShowSaveFileDialog | 1098:26D4 | from RunReplayMenu 1180:00A7 or SaveGameAsDialog 1198:0178 | entry, exit | reply, prompt, defaultName | 29, 125 |
| OpenPalaceView | 1158:08E7 | – | entry, exit | useAltSky | 104 |
| WdwStatusProc | 1218:0000 | – | entry | hwnd, msg, wParam, lParam | 104 (palace click) |
| RunPalaceImprovement | 1158:0000 | – | entry, exit | improvementCount | 124 |
| InsertHallOfFameEntry | 1080:0595 | – | entry, exit | unusedArg | 105, 129 |
| RunEndGameSequence | 1088:0B6D | – | entry, exit | arrivedCiv | 106 |
| ShowSpaceshipArrival | 11D8:0000 | – | entry, exit | arrivingCiv | 106, 130 |
| ShowCivilizationDestroyed | 11D8:087F | from ProcessGameTurn 1088:0189 | entry, exit | none | 106, 131 |
| ShowConquerorEnding | 1180:152F | – | entry, exit | none | 106, 114 |
| ShowConqueredCivLeader | 1180:17E9 | – | entry | victimPlayer, year | 114 |
| CyclePaletteColors | 1208:22B7 | – | entry | none (the step is the event) | 107 |
| PlaySoundEffect | 1150:00C9 | – | entry | soundId | 108 (O1 also records `sndPlaySound`) |
| ShowCityFoundedAnimation | 11B8:14E5 | – | entry, exit | cityIndex | 109 |
| AnimateNuclearExplosion | 11B8:0C3D | – | entry, exit | mapX, mapY | 110 |
| PlayCityCaptureAnimation | 11B0:1B63 | – | entry, exit | conqueror | 111 |
| PlayCivilDisorderAnimation | 11B0:1FAC | – | entry, exit | none | 112 |
| PlayCelebrationAnimation | 11B0:237C | – | entry, exit | none | 113 |
| ShowHelpNote | 10E0:0000 | – | entry | topic | 116 |
| ShowInstantAdvice | 10E0:077F | – | entry | topic | 117 |
| ShowErrorNote | 10E0:07E8 | – | entry | topic | 118 |
| ShowCivilizationRatingRanking | 1080:06FF | – | entry, exit | fallbackRank, score | 120 |
| ShowPowerGraph | 1188:07AD | – | entry, exit | none | 122 |
| ShowHistorianReport | 1188:0DB8 | – | entry, exit | none | 123 |
| ProcessCityDisaster | 1040:068E | – | entry | cityIndex | 126 |
| StartCivilWar | 11A0:0000 | – | entry | civ | 127 |
| DiplomatEntersCity | 11B8:0000 | – | entry | city, civ, unit | 128 |
| TransferCityByRevolt | 11B8:0F26 | – | entry | cityIndex, newCiv | 128 |
| BlinkActiveUnitUntilInput | 11C0:0EC2 | – | entry, exit | civ, unit | 132 |
| AnimateUnitMove | 11C0:2C32 | – | entry, exit | civ, unit, dir | 133 |
| ResolveCombat | 1050:0000 | sparks: DrawTile at call site 1050:0AEA | entry, exit | attackerCiv, attackerUnit, defenderCiv, defenderUnit, resolve | 134 |
| SetMapViewAndRedraw | 1110:03E9 | – | entry | civ, left, top | 135 |
| RestoreMapAfterDialog | 1208:14D5 | from GR_DialogClose 1098:16D6 | entry | mapPort | return to the map (`DOS-PROFILE.md` 3.1) |
| ShowErrorMessage | 1098:28E4 | – | entry, exit | errorCode, message | 141 (W over N, `DOS-PROFILE.md` 4.1) |
| _ErrorMessage | 1000:4124 | – | entry | msg | 141 (C run-time error box) |
| AnimatePaletteFromGrPort | 1200:0116 | the call sites of 9.5 | entry | port, srcPort, firstIndex, count | the palette rows E15..E23 |
| PushPalette, PopPalette | 1090:015E, 1090:02D2 | – | entry | none | E11 |

Input context (prompt 5.6 I5; these tell the adapters which conversion the core is using):

| Probe | Key | Kind | Arguments read | Sites | Conversion |
|---|---|---|---|---|---|
| PollMouseClick | 1108:0000 | entry, exit | none; g_clickX/Y on exit | 5 | signed `*10/16` (1108:0169..018F) |
| WaitForKeyOrClick | 1038:0C1D | entry, exit | none; result | 27 | unsigned `*10 >> 4` (1038:0CB6..0CDA) |
| WaitTicksOrInput | 11D8:0BD2 | entry, exit | ticks; result | 2 | calls PollMouseClick (11D8:0BFC); any input ends the wait, the position is not used by the wait itself |
| CityScreenWndProc | 1030:9C17 | entry | hwnd, msg, wParam, lParam | – | unsigned `*10 >> 4` for g_mouseX/Y (1030:9CD0..9D3B) |

### 10.8 Counts

The tables have 182 rows and name 175 distinct functions: 21 logical-layer (10.1), 15 text
(10.2), 7 picture and shape (10.3), 3 recolouring and cache (10.4), 8 movie (10.5), 9 map
(10.6), 115 scene rows naming 116 functions (34 rows with a call-site filter) and 4 input rows
(10.7). Some functions appear in more than one table, with different call sites (for example
SeekSequence, SetGameCursor, GR_DialogOpen, MenuZ). Dead functions (7.2, 8 #10) are not probes.
`DOS-PROFILE.md` 1.1..1.5 names its probes in the same form: the function start, plus the call
site where one caller matters.

## 11. Open

1. **Font table order.** The order of g_civFonts 1420:5484 comes from Windows font enumeration
   in CreateCivFonts 1008:0E99; the port fixes it (DESIGN.md Q22). The original's order on a
   real Windows 3.1 system is not proven here.
2. **Cursors 128 and 135** have no static setter; whether any computed id reaches them is
   unknown (the arrow path computes 0x87 + 1..8 only).
3. **RanDoM control classes** (RegisterRandomControlClasses 1098:08A5): their hCursor was not
   checked.
4. **Movie palette header overlay** (docs graphics.md 7.1) remains open as in the docs.
5. **Text content** of STR# 137, 139 and 154 and of the TEXT resources is not inventoried here
   (no bytes); only ids and positions.
6. **TextOut versus logical-text centring** in non-dialog windows (docs text-files.md 4.5) is not
   resolved here. It bears on the text probes (10.2 note): whether those windows need a probe
   beyond the logical text routines is for D1.
7. **Unused shape slots.** g_wholeTileShapes [0], [7], [10] have no static reader (section 2.1);
   a computed index through another table was not searched.
8. **Rectangles not read**: the ExtractScaledTile rectangle in ShowConqueredCivLeader 1180:17E9,
   the quiz TileExtract rectangle in 1178:0022, and the per-part rectangles of
   g_spaceshipPartSprites 1420:12AA.
9. **Rating ranking drawing target**: ShowCivilizationRatingRanking 1080:06FF opens no offscreen
   port; that it draws through the dialog's own port set by GR_DialogOpen is inferred.
10. **Picture 5556 role.** The listing comments call it the human-ship picture; its exact use in
    ShowSpaceshipArrival after 11D8:05A4 was not traced.
11. **Windows-only sheet region.** That the shapes at device x >= 1152 have no DOS counterpart is
    inferred in the docs and not checked against the DOS files in this task.

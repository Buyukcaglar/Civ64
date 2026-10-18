# DOS sprites: which picture rectangles become which shapes (extension D0, prompt 6.5)

Draft of 2026-10-11 (task D0-E2). This file lists every rectangle that the DOS program cuts out
of SP257.PIC, TER257.PIC, SP299.PIC, SPRITES.PIC and TORCH.PIC, the variable that receives each
shape, where the shapes are used, and the Windows counterpart in picture 200 where one is clear.
It also says how ICONPG*.PIC is used (rectangle copies, not shapes). The scenes that draw these
shapes are in [SCENES-PLAY.md](SCENES-PLAY.md); the start-up and UI scenes are in SCENES.md.

Evidence labels: **DOS file** (read from the files in `build/dosdata/`), **DOS listing** (our
disassembly in `build/dos/disasm/`), **inferred**, **unknown**. No DOS bytes are reproduced: no
pictures, palettes or data tables, and strings only as a few words. Coordinates are logical
320x200 pixels. Addresses: R:ssss:oooo root, O<n>:oooo overlay, G:0000:oooo MGRAPHIC driver,
DGROUP:oooo data. Windows addresses (ssss:oooo, no prefix) come from `claude/docs`.

Driver functions are named as in [DRIVER.md](DRIVER.md): G#2 GrabSprite, G#3 RecolourRect,
G#6 DrawSpriteClipped, G#7 CloseSpriteArena, G#14 GetPixel, G#18 OpenSpriteArena, G#20
CopyRect, G#32 DrawSprite, G#33..35 EndSprite/AddSpriteRow/BeginSprite. A "view port" is the
DGROUP structure of DRIVER.md 3.2 (page, origin, limits, colours, font); DGROUP:00AA is the
current one, DGROUP:19D4, 19E8 and 19FC point at the view ports of pages 1, 2 and 3.

The picture format (chunks E0, M0, X0, X1; LZW and RLE) is in [FORMATS.md](FORMATS.md) section 1.
Visual checks were made with a scratch decoder (`build/dos/scratch-d0e2/picdec.py`, following
the listing's chunk walker R:0000:108E, LZW R:0000:1227..1318 and RLE R:0000:12A6) and contact
sheets of every cut table (`sheet0.png`, `sheet1.png`, `sheet2.png` in the same folder). Those
images are not part of the docs.

## 1. The shape mechanism

| Step | What happens | Address | Label |
|---|---|---|---|
| Open a batch | G#18 OpenSpriteArena before cutting; G#7 CloseSpriteArena after | O5:146F, O5:1AEB | DOS listing |
| Cut | G#2 GrabSprite(page, x, y, w, h) returns the shape's segment in AX; the caller stores it in a DGROUP word | O5:1455..1AEB | DOS listing |
| Format | run sprite: zero pixels at both ends of a row are not stored, zero pixels inside a row are stored and drawn transparent (DRIVER.md 3.3) | G:0000:0AE3..0B84 | DOS listing (DRIVER.md) |
| Draw | G#32 DrawSprite(view port, x, y, shape) or G#6 DrawSpriteClipped; colour 0 is transparent | many | DOS listing |
| Draw by index | R:1DC4:009A(i, x, y) draws DGROUP:D4CE[i] (word table) on the current view port with G#32 | R:1DC4:009A | DOS listing |
| Whole picture as one shape | R:1FA1:044C(name): opens the picture, walks its chunks without a palette, G#35(width, height), one G#34 per decoded row, G#33; returns the shape | R:1FA1:044C..04BF | DOS listing |
| Recolour before cutting | G#3 RecolourRect(view port, x, y, w, h, from, to) on the source page | O5:1A61..1ADB | DOS listing |

The shapes are cut once, at start-up, by **O5:1455**, which the start-up routine calls at
R:01A8:0810 (inside R:01A8:0486). Nothing frees or recuts them during play (DOS listing: no
other writer of these DGROUP words was found, except D4DC from [6E92] described below).

**Data or code.** The rectangles below are not data tables: each family is an immediate formula
inside a loop of O5:1455 (or of the drawing routine named for page-2 rectangles), given here
with its instruction range. The DGROUP words they fill (B886, D4CE, ...) are run-time shape
handles, not image data. The true data tables this file uses are the civilization colours
DGROUP:1946/1956, the terrain names DGROUP:0282, the unit table DGROUP:1138, the direction steps
DGROUP:1882/18E4 and the ICONPG lookup tables at R:271E (section 8). [FORMATS.md](FORMATS.md) 6
lists both kinds with their offsets (review finding R2-7).

## 2. Order of O5:1455 and the pages it uses

| # | Action | Address | Label |
|---|---|---|---|
| 1 | R:01A8:02A4(7, 1L), the disk prompt helper (string DGROUP:1A93) | O5:145D..146C | DOS listing; meaning inferred |
| 2 | G#18 | O5:146F | DOS listing |
| 3 | SP299.PIC into page 1 at (0,0), palette not applied (R:1FA1:0254) | O5:1474..147C | DOS listing |
| 4 | G#20: page 1 (160, 50, 160x150) to page 2 (160, 50). Page 2 keeps this art for play (section 7) | O5:1484..14A4 | DOS listing |
| 5 | Cut the three SP299 report portraits (section 3) | O5:14AC..14E3 | DOS listing |
| 6 | 256-colour mode (DGROUP:D762 not 0): TER257.PIC into page 1, palette not applied; cut terrain, coast quarters and river mouths (section 4) | O5:14E5..1635 | DOS listing |
| 6' | Otherwise (EGA): SPRITES.PIC into page 3 **with** its palette (R:1FA1:04C0), G#20 page 3 (0,0,320x200) to page 1; cut two terrain variants from page 3 (section 5) | O5:1637..16B1 | DOS listing |
| 7 | 256-colour mode only: SP257.PIC into page 1, palette not applied; the M0 chunk of SP256.PAL into the DGROUP buffer BDEE (R:1FA1:0288), then 48 bytes from BDF4 are copied to DGROUP:6B34 | O5:16B3..16F3 | DOS listing |
| 8 | Cut everything else from page 1, which now holds SP257.PIC (VGA) or the copy of SPRITES.PIC (EGA) at the same coordinates (section 6) | O5:16F5..19B2 | DOS listing |
| 9 | Unit shapes for the eight civilizations (section 6.4) | O5:19B5..1AE8 | DOS listing |
| 10 | G#7 | O5:1AEB | DOS listing |

The 48 bytes of step 7 are the RGB values of colours 0..15 of SP256.PAL (the M0 header is 6
bytes: tag, length, first, last). Their user is R:1DC4:047D, which writes them over entries
0..15 of every `.PAL` it applies (the interface colours; [PALETTE.md](PALETTE.md) 2.5, 2.6)
(**DOS listing**).

The play screen's palette is SP257.PIC's M0 chunk, applied after the cutting by
R:1FA1:026C("sp257.pic"), called at R:01A8:0867 (**DOS listing**). SP257.PIC's palette and SP256.PAL's
palette are identical; TER257.PIC's and SP299.PIC's palettes differ from it in some entries
(**DOS file**, compared in scratch). So TER257 and SP299 art is shown with SP257's colours.

All five pictures are 320x200. SP257, TER257 and SP299 are 8-bit (X0); SPRITES.PIC and
TORCH.PIC (13x14) are 4-bit (X1) (**DOS file**, chunk headers).

## 3. SP299.PIC

| Receiver | Rectangle (x, y, w, h) | Count | Use | Label |
|---|---|---|---|---|
| DGROUP:DF62[i] | (160 + 42i, 142, 41, 58), i 0..2 | 3 | Report box icons: drawn with G#32 at (x − 40, y − 5) of a text box whose header number DGROUP:2F9E is 0, 1 or 2 ("Spies", "Diplomats", "Travelers" plus " report:") | DOS listing (O5:14AC..14E3; user R:1D05:06B2) |
| page 2 (160..319, 50..199) | copy of the same area | 1 copy | resident art for the map and status panel (section 7) | DOS listing (O5:1484) |

Windows counterpart: none in picture 200's cutting list (graphics.md 4.9). **inferred**: the
Windows report headers use other art.

## 4. TER257.PIC (256-colour mode only)

| Receiver | Rectangle | Count | Use | Label |
|---|---|---|---|---|
| DGROUP:B886 + 32t + 2m (T[t][m]) | (16m, 16t, 16, 16), t 0..9, m 0..15 | 160 words | land terrain t by the same-terrain mask m (N = 1, E = 2, S = 4, W = 8) | DOS listing (O5:14FF..1577; user R:1AEA:03BA) |
| DGROUP:D294 + 8i + 2k (coast quarter) | k 0: (16i, 176, 8, 8); k 1: (16i + 8, 176, 8, 8); k 2: (16i + 8, 184, 8, 8); k 3: (16i, 184, 8, 8); i 0..7 | 32 | ocean squares: quarter k (0 top left, 1 top right, 2 bottom right, 3 bottom left) with land pattern i | DOS listing (O5:1579..15F7) |
| DGROUP:D2D4[d] | (128 + 16d, 176, 16, 16), d 0..3 | 4 | river mouths on ocean squares, toward N, E, S, W | DOS listing (O5:15F9..1635) |

Terrain variants (DOS listing, O5:151C..1567):
* Rows t 0..5 (Desert, Plains, Grassland, Forest, Hills, Mountains) are cut in all 16 mask
  variants when DGROUP:1A3E is 0.
* Rows t 6..9 (Tundra, Arctic, Swamp, Jungle), and all rows when DGROUP:1A3E is not 0, cut only
  m = 0; m 1..15 receive a copy of the m = 0 handle, so these terrains ignore their neighbours.
* DGROUP:1A3E is set to 1 by R:01A8:00FC when the 256-colour flag is set and the largest free
  block reported by G#1 (in paragraphs, forced to 0 when DGROUP:6DFC is set) is below 23BEh
  (**DOS listing**). Its purpose is a low-memory economy (**inferred**). It has no other user.
* Terrain names and numbers (DGROUP 0282 + 13h*t): 0 Desert, 1 Plains, 2 Grassland, 3 Forest,
  4 Hills, 5 Mountains, 6 Tundra, 7 Arctic, 8 Swamp, 9 Jungle, 10 Ocean, 11 River (**DOS file**).
  Ocean and river have no row here; they use the coast and river tables.

Not cut from TER257.PIC: the band y 160..175, x 192..319 of the band y 176..191, and rows
192..199 (**DOS listing**: no other reference to the file name; **DOS file**: art is present in
parts of those areas). Their purpose is unknown.

Windows counterpart (graphics.md 4.9, **inferred** from equal rectangles): g_terrainShapes
(1420:972E), g_coastShapes[i][q] and g_coastShapes[8][d] are cut from the **right half** of
picture 200 at the same logical rectangles. So the right half of Windows picture 200 has
TER257.PIC's layout. Windows cuts all 16 variants for every row 0..9 (no low-memory rule).

## 5. SPRITES.PIC (EGA mode only)

| Receiver | Rectangle (page 3) | Count | Use | Label |
|---|---|---|---|---|
| DGROUP:B886 + 32i (T[i][0]) | (16i, 0, 16, 16), i 0..11 | 12 | terrain i, variant 0 | DOS listing (O5:1667..16B1) |
| DGROUP:B886 + 32i + 2 (T[i][1]) | (16i, 16, 16, 16), i 0..11 | 12 | terrain i, variant 1 | DOS listing |
| page 3 itself | (16 mask, 64, 16, 16) | 16 cells | EGA ocean square by its 4-bit land mask (G#20 from page 3) | DOS listing (R:1AEA:0549..0546) |
| page 3 itself | (0, 80, 16, 16) | 1 | EGA base of every land square (G#20) | DOS listing (R:1AEA:0796..07B0) |

In EGA mode the map chooses variant `(x + y) & 1`, or for Grassland `((11y + 7x) & 2) >> 1`
(DOS listing, R:1AEA:03BA). SPRITES.PIC stays in page 3 during play (**inferred**: the map reads
it there). After step 6' page 1 holds a copy of SPRITES.PIC, and section 6 cuts the same
rectangles from it as from SP257.PIC (**DOS listing**); our decode shows a 16-colour version of
SP257's layout, with ocean cells in row 64 and river cells in row 80 (**DOS file**). So the
layout is not exactly SP257's: in EGA mode section 6.1 cuts the first river table 6DFE (row 64)
from ocean cells, and T[10]/T[11] above, at (160..191, 0 and 16), fall on non-terrain art
(**DOS file**, review note R2-20). The EGA path is outside the port's scope (prompt 3); it is
listed for completeness.

## 6. SP257.PIC (VGA) or the SPRITES.PIC copy (EGA), page 1

### 6.1 Map overlays

| Receiver | Rectangle | Count | Use | Windows counterpart | Label |
|---|---|---|---|---|---|
| DGROUP:B27A[i] | (16i, 48, 16, 16), i 0..7 | 8 | road from the square centre toward direction i + 1 | g_roadRailShapes[0..7] | DOS listing (O5:16F5..1745) |
| DGROUP:B29A[i] | (128 + 16i, 96, 16, 16), i 0..7 | 8 | railroad toward direction i + 1 | g_roadRailShapes[16..23] | DOS listing |
| DGROUP:B2BA | (48, 32, 16, 16) | 1 | city screen, drawn repeatedly at x 0A1h + (k & 1) (R:0D12:4828) | g_roadRailShapes[32] ("user not identified") | DOS listing (O5:1747..1760) |
| DGROUP:6DFE[i] | (16i, 64, 16, 16), i 1..15 | 15 | river square by its N/E/S/W river-or-ocean mask | g_riverShapes[1..15] | DOS listing (O5:1763..17AF) |
| DGROUP:6E1E[i] (= 6DFE[16 + i]) | (16i, 80, 16, 16), i 1..15 | 15 | second river set, chosen with +16 (section 6.3) | g_riverShapes[17..31] | DOS listing |
| DGROUP:7EEC[i] | (80 + 16i, 128, 16, 16), i 0..3 | 4 | unexplored edge toward N, E, S, W | g_unexploredEdgeShapes | DOS listing (O5:1826..185B) |
| DGROUP:B880 | (153, 41, 7, 7) | 1 | Grassland marker at (+4, +4) of qualifying squares | g_grasslandShieldShape | DOS listing (O5:197A..1993) |

Directions: 1 N, 2 NE, 3 E, 4 SE, 5 S, 6 SW, 7 W, 8 NW (x/y steps at DGROUP:1882 and 18E4,
**DOS file**; meaning **inferred** from their values).

### 6.2 Palace strips (status panel and reports)

| Receiver | Rectangle | Count | Label |
|---|---|---|---|
| DGROUP:D21C[i] | (160 + 7i, 0, 7, 15), i 0..19 | 20 | DOS listing (O5:17B1..1824) |
| DGROUP:D244[i] | (160 + 7i, 16, 7, 15) | 20 | DOS listing |
| DGROUP:D26C[i] | (160 + 7i, 32, 7, 15) | 20 | DOS listing |

The three tables are one array [style 0..2][20] (stride 28h bytes). R:0238:14A3 picks entry
`(level − 1 clamped to 0..3) * 5 + kind` where kind 0..4 comes from the neighbouring slots
(DOS listing, R:0238:1635..16CD). Users: the status panel's mini palace (R:0238:107E) and
O12:09E2. Windows counterpart: g_miniPalaceShapes[v][i], cut 7x16 at the same origin (DOS: 7x15).

### 6.3 The icon table DGROUP:D4CE

R:1DC4:009A indexes one word table starting at DGROUP:D4CE. O5:1455 fills it in pieces:

| Index | Receiver | Rectangle | Contents and users | Windows counterpart | Label |
|---|---|---|---|---|---|
| 0..6 | D4CE[i] | (16i, 32, 16, 16) | [0], [1]: empty cells (DOS file); [2] arrow with "GO": the in-play pointer while the GoTo flag of R:0403 is set (R:0403:109A..10AB; FORMATS.md 4); [3] same rectangle as B2BA; [4] irrigation; [5] mine; [6] pollution. Map users: [4], [5], [6] (R:1AEA:03BA) | g_mapSprites[4..6] (Windows cuts only 4..6) | DOS listing (O5:185D..188F); contents DOS file |
| 7 | D4DC | copy of DGROUP:6E92, the TORCH.PIC shape (section 6.5) | the normal mouse pointer shape; R:0403:1094..10AB selects it as D4CE[7] when dispatch value 67h finds the GoTo flag already set (FORMATS.md 4) | none (Windows uses cursors, inferred) | DOS listing (O5:1891..1894) |
| 8..15 | D4DE[i] | (129 + 8(i & 3), 33 + 2(i & 4), 7, 7), i 0..7 | 7x7 icons. Uses: city screen resource rows [8], [9], [10] (food, shields, trade), luxury/tax/science [14], [11], [12]; unhappy mark [13]; science report bulbs [12]. Look: food, shield, trade arrow, coin, bulb, two dots, gem, green loop. [15] has the same rectangle as B880 | g_mapSprites[8..15] | DOS listing (O5:1897..18D7; uses from helper reads of R:0D12:0045, O14:014B); look DOS file; names inferred |
| 16..27 | D4EE[t] | (16t + 1, 113, 15, 15), t 0..11 | special resource of terrain t (R:1AEA:1836 decides); cells 2 (Grassland) and 11 (River) are empty | g_mapSprites[16..27] | DOS listing (O5:1910..1943), DOS file |
| 28 | D4EE[12] | (193, 113, 15, 15) | city overlay, drawn at (+1, +1) on every city square | g_mapSprites[28] | DOS listing |
| 29 | D4EE[13] | (209, 113, 15, 15) | frame mark: city walls (city flag 80h) and fortified units (unit flag 8) | g_mapSprites[29] (walls) | DOS listing |
| 30 | D4EE[14] | (225, 113, 15, 15) | fortress (improvement 20h) | g_mapSprites[30] | DOS listing |
| 31 | D4EE[15] | (241, 113, 15, 15) | hut (R:1AEA:1894 decides) | g_mapSprites[31] | DOS listing |
| 32..39 | D50E[i] | (16i + 1, 97, 15, 15), i 0..7 | eight frames of growing sparks (**inferred**: combat explosion) | g_mapSprites[32..39] | DOS listing (O5:1945..1978); look DOS file |
| 40..63 | D51E..D54C | not cut | no writer found | none | DOS listing |
| 64 + 32c + j | D54E + 2(32c + j) | section 6.4 | unit type j of civilization c | g_mapSprites[64 + 32c + j] | DOS listing |

### 6.4 Units (eight recoloured copies)

For each civilization c = 0..7 (DOS listing, O5:19B5..1AE8):
1. G#20 copies page 1 (0, 160, 320x32) to page 1 (0, 128): the unit rows are moved over rows
   128..159, which were already cut.
2. If c's main colour (DGROUP:1946[c], **DOS file**) is 15, G#3 recolours 15 to 11 in
   (0, 128, 320, 32); if it is 7, 7 to 3 (**inferred**: keeps white or grey details visible
   against that civilization's colour).
3. G#3 recolours 10 to the main colour and 2 to the secondary colour (DGROUP:1956[c]).
4. j = 0..27: G#2(1, 16(j mod 20) + 1, 16(j div 20) + 129, 15, 15) to D54E + 2(32c + j).

So the base art is SP257.PIC (16(j mod 20) + 1, 16(j div 20) + 161, 15, 15): 20 units in the
first row and 8 in the second (**DOS listing**; **DOS file** shows 28 framed pictures). Unit
types 0..27 follow the unit table at DGROUP:1138 (stride 22h; byte 0 domain: 0 land, 1 air,
2 sea) (**DOS file**). Windows counterpart: g_mapSprites[64 + 32c + j], the same index j, but the rectangles differ by one
logical pixel in x: Windows cuts T2(16(j % 20), 161 + 16(j / 20), 15, 15) with no +1 (10E8:2931..2954,
showfunc; review R3-1, fixer F3), with the
key colours replaced by InitGameColorTables (10E8:2D46) (graphics.md 4.9).

### 6.5 Other single shapes

| Receiver | Source | Use | Windows counterpart | Label |
|---|---|---|---|---|
| DGROUP:6E92 | TORCH.PIC, the whole 13x14 picture as one shape (R:1FA1:044C, inside a G#18/G#7 pair at R:01A8:0102..0116) | mouse pointer: R:0000:1697(hot x, hot y, shape) with hot spot 0, 0 (FORMATS.md 4), called with 6E92 at R:01A8:0139 and with its copy D4DC at R:01A8:0891 and R:0403:046B, 095B, 0AEC; R:0403:10AB passes D4CE[7] (= D4DC) or the GO arrow D4CE[2] | none (inferred) | DOS listing |
| DGROUP:6E96[i] | (8i, 128, 8, 16), i 0..8 | citizens; [4] (6E9E) is the civil-disorder mark on city squares (R:1AEA:0D54) and the city screen uses the table (R:0D12:6FAD) | g_citizenShapes | DOS listing (O5:18D9..190E) |
| DGROUP:DF0C | (176, 128, 20, 9) | torn lower edge of the newspaper, 16 times along y about 100 (O21:014D) | none listed | DOS listing (O5:1996..19B2) |

### 6.6 Parts of SP257.PIC that are not cut

(0..159, 0..31), (112..127, 32..47) (a torch picture; the pointer uses TORCH.PIC instead),
(144..175, 128..143), (256..319, 176..191), the second unit row from x 129 on, and rows
192..199 (**DOS listing**: no cut; **DOS file**: art is present). SP257.PIC is loaded only by
O5:1455 and, for its palette only, at R:01A8:0867 (**DOS listing**). Their users are unknown.

## 7. Resident page-2 art used as rectangles

Page 2 is the map's data page (SCENES-PLAY.md 1.1). Its area x 160..319, y 50..199 holds
SP299.PIC art (step 4); x 160..319, y 140..199 is later overwritten by a government picture.
These rectangles are copied with G#20, not cut:

| Page 2 rectangle | Contents | User | Windows counterpart | Label |
|---|---|---|---|---|
| (224 + 16j, 100, 16, 16), j 0..5 | ocean squares with a whole-square coast shape | R:1AEA:03BA for land masks 1Ch, C1h, 07h, 70h, 8Fh, F8h (j in that order) | g_wholeTileShapes[1..6] (patterns 1..6) | DOS listing; look DOS file |
| (208, 100, 16, 16) | water-like texture | city screen panel background, tiled (R:0D12:710D) | none checked | DOS listing (rechecked R:0D12:7189..7195) |
| (256, 120, 16, 16) | grass texture | base of every land square in 256-colour mode (R:1AEA:07B2..07CD) | g_wholeTileShapes[8] (river base) (inferred) | DOS listing |
| (288, 120, 32, 16) | grey stone texture | panel background R:1DC4:03CE (status and unit panels, leader text strip, rating ladder) | g_wholeTileShapes[9] (Status window background) (inferred) | DOS listing |
| (192 or 224, 120 and 128), 8x8 | two border styles | rating ladder border R:0866:260E (also the civilopedia entry) | g_windowFrameShapes (inferred) | DOS listing (helper read) |
| (160 + 4t, 111 + 4v, 4, 4), v 0..1 | 4x4 terrain tiles | World Map report O12:0000, variant `(x + y) & 1` | none (Windows draws 6x6 squares) | DOS listing (rechecked O12:0330..0359) |
| (161 + 19c, 50 + 10r, 18, 10) and (161 + 19c, 100) | building icons | R:0D12:7045 (city screen, reports): icon n < 40 at column n div 5, row n mod 5; otherwise column n & 1 at y 100 | g_improvementIcons (inferred) | DOS listing (helper read) |
| (160 + 8k, 120, 8, 8), k 0..3 | four bulbs | status panel research icon (R:0238:11F6..1229) | g_statusIconShapes[0..3] | DOS listing; look DOS file |
| (160 + 8k, 128, 8, 8), k 0..3 | four discs | status panel global-warming icon (R:0238:125C..1280) | g_statusIconShapes[4..7] | DOS listing; look DOS file |
| (160 + 40n, 140, 40, 60), n 0..3 | four portraits from GOVTgx.PIC (O5:1AF6: page 1 (0, 0, 160x60) to page 2 (160, 140)) | text-box header n + 3 (Defense, Domestic, Foreign, Science advisor) | g_advisorShapes (inferred) | DOS listing (O5:1B68..1B84; R:1D05:05ED..0753, helper read) |
| (240..319, 0..49) | the 80x50 world map image, one pixel per square | minimap (SCENES-PLAY.md 4) | none (Windows draws it each time) | DOS listing |

The government picture name is "govt" + digit + letter: digit = government / 2, but 3 for
government 3; letter "a", or "m" when the player knows advance 14h (R:0ADE:22B5) (DOS listing,
O5:1B0F..1B58).

## 8. ICONPG*.PIC (rectangle copies)

ICONPG1..8, ICONPGA..E, ICONPGT1 and T2 are 320x200 pictures (E0, M0, X0) (**DOS file**). They
are not cut into shapes. The civilopedia (O8:062A) loads one into page 1 with R:1FA1:0254
(palette not applied), applies a palette by one of three fixed rules, and copies one cell with
O8:16F7(sx, sy, w, h, cx, cy): G#20 from page 1 to the current view port, clipped to the screen
and centred on (cx, cy) (**DOS listing**).

**Palettes.** Only `ICONPG1.PAL` and `ICONPGA.PAL` exist (**DOS file**); no other `ICONPG*.PAL`
is named or built by the program (**DOS listing**). The pictures' own `M0` palettes are never
applied.

| Pictures | Palette rule | Label |
|---|---|---|
| ICONPG1..8 (advances) | the constant `iconpg1.pal` (DGROUP:3CE6) through R:1DC4:047D (O8:0768..076C): entries 0..15 from DGROUP:6B34, entry 45 forced. The picture name is built in DGROUP:BA06 with its digit patched (O8:073B..0754); no code writes the palette name. ICONPG2..8.PIC's own palettes equal ICONPG1.PAL (**DOS file**) | DOS listing, DOS file |
| ICONPGA..E (units) | the constant `iconpga.pal` (DGROUP:3D4E) through R:1DC4:047D (O8:0A1C..0A20). ICONPGB..E.PIC's own palettes equal ICONPGA.PAL (**DOS file**) | DOS listing, DOS file |
| ICONPGT1..2 (terrain) | not R:1DC4:047D: `sp256.pal` into DGROUP:C5BE (O8:0AFB..0AFF), applied by G#28 (O8:0B0B), then DAC 253 set to a fixed grey by R:1DC4:0698 (O8:0B13..0B1D); no 6B34 or entry-45 step. Their own palettes differ from SP256.PAL in 17..31, 96..97, 109..110 and 224..255, so their cells show other colours there ([PALETTE.md](PALETTE.md) 2.5) | DOS listing, DOS file |
| O16 quiz, R:0ADE discovery | the constant `iconpg1.pal` (O16:0100..0104 through R:1DC4:047D; R:0ADE:1964 into C5BE with the discovery splice, PALETTE.md 2.5) | DOS listing |

**Cell grids** (each an immediate formula in O8:062A's code; FORMATS.md 6):

| Pictures | Cell n → file | Source rectangle | Centred on | Label |
|---|---|---|---|---|
| ICONPG1..8 | digit "1" + n div 9 (O8:074B..0754) | (1 + 111 (n mod 3), 1 + 69 ((n mod 9) div 3)), 110x68 | (62, 42) | DOS listing (O8:0774..07AF); DOS file (1-pixel separating lines) |
| ICONPGA..E | letter "a" + n div 6 (O8:09FF..0A08) | (1 + 160 (n & 1), 61 ((n mod 6) div 2)), 158x61 | (88, 42) | DOS listing (O8:0A28..0A5C) |
| ICONPGT1..2 | digit "1" + n div 6 (O8:0AD3..0ADC) | (1 + 107 (n mod 3), 5 + 87 ((n mod 6) div 3)), 106x77 | (76, 46) | DOS listing (O8:0B25..0B62) |

The same ICONPG1..8 lookup and grid, with their own centres (SCENES-PLAY.md), serve the
discovery scene (lookup R:0ADE:16B3, name R:0ADE:189C, copy R:0ADE:1931) and the quiz (O16:007A,
0085, 01CE) (**DOS listing**).

**Cell lookup: three byte tables in the root image.** DGROUP:6420 is a relocated word equal to
271Eh, so the tables lie at R:271E (**DOS file**). Each lookup is an inverse search: the cell n
is the first index whose (sign-extended) byte equals the number looked up, or −1 when none does
(O8:16CA..16F0; the sign extension is the `cbw` the listing prints). The
callers do not test −1 before the cell arithmetic (unknown whether it can occur in play).

| Table | Search routine | Bytes searched | Number looked up | Contents (DOS file) |
|---|---|---|---|---|
| Advances | O8:16C4 | R:271E:0000..0047 (72) | advance number (O8:072E) | 0..66 each once and one FFh (an unused cell) in 0000..0043; the search range runs 4 bytes into the next table (0044..0047), whose values all occur earlier, so the first match always lies before 0044 (68 distinct values in 72 bytes) |
| Units | O8:1790 | R:271E:0044..005F (28) | unit type (O8:09E2) | 0..27, each once, not in order |
| Terrain | O8:17C3 | R:271E:0061..006C (12) | terrain type (O8:0AB6) | 0..11, each once, not in order |

Byte R:271E:0060 (FFh) lies between the unit and terrain tables and is not searched. The tables
are data tables at image offsets (FORMATS.md 6); the profile reads them, never copies them.

The scenes are described in SCENES-PLAY.md (civilopedia, discoveries). Windows counterpart:
g_improvementIcons and the pedia pictures are other resources; no rectangle match was checked.

## 9. Windows counterpart summary

Inferred from equal rectangles (graphics.md 4.9): Windows picture 200 is SP257.PIC's layout in
its left half and TER257.PIC's layout in its right half, both at twice the size, plus
Windows-only art at device x 1152 and above. ExtractGameSpriteShapes (10E8:231F) cuts the same
tables as O5:1455, with these differences:

| Difference | DOS | Windows | Label |
|---|---|---|---|
| Terrain variants | rows 6..9 always one variant; rows 0..5 one variant when DGROUP:1A3E is set | 16 variants for rows 0..9 | DOS listing, graphics.md |
| Palace strips | 7x15 | 7x16 | DOS listing, graphics.md |
| D4CE[0..3] | cut | not cut | DOS listing, graphics.md |
| Pointer | TORCH.PIC shape | none | DOS listing |
| Report portraits | SP299 shapes DF62, GOVT pictures in page 2 | other shapes | DOS listing |
| Whole-square coasts, land base, status icons | page-2 rectangles copied with G#20 | g_wholeTileShapes, g_statusIconShapes cut from Windows-only art | DOS listing, graphics.md |
| City icons, improvement icons, window frames | none | g_cityIconShapes, g_improvementIcons, g_windowFrameShapes | graphics.md |

## Open

1. **DGROUP:1A3E.** Set when memory is short; its effect (single terrain variant for rows 0..5)
   is in the listing, but the threshold's unit and the meaning of DGROUP:6DFC are not traced.
2. **D4CE[0], [1], [3].** [0] and [1] are empty in SP257.PIC; the user of [3] was not traced
   (B2BA, the same rectangle, is used by the city screen). [2], the "GO" arrow, is the in-play
   pointer while R:0403's GoTo flag is set (FORMATS.md 4, review finding R2-1); only the game
   situation of that flag (inferred: the GoTo command) stays open (FORMATS.md Open 9).
3. **D50E table.** Its users (combat, inferred) were not traced.
4. **Uncut art** in SP257.PIC and TER257.PIC (sections 4 and 6.6): unknown purpose.
5. **The 48 bytes copied to DGROUP:6B34.** Closed 2026-10-11 (review finding R2-13): R:1DC4:047D
   writes them over entries 0..15 of each palette it applies (section 2; PALETTE.md 2.5, 2.6).
6. **Other page-2 cells** of the SP299 copy (for example the cells beside the bulbs and discs)
   were not matched to readers.
7. **EGA SPRITES.PIC** layout was only checked visually; the EGA map path is out of scope.
8. **ICONPG cell tables.** Closed 2026-10-11 (review finding R2-5): three byte tables in the root
   image at R:271E:0000, 0044 and 0061 (DGROUP:6420 holds the relocated segment), searched by
   O8:16C4, 1790 and 17C3 (section 8).

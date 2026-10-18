# DOS play screen and full-screen scenes (extension D0, prompt 6.5, play part)

Independent review R3 (`docs/verify/ext-d0-review-r3.md`) and the R1/R2 items in its scope
were applied on 2026-10-11 by fixer F3 (`docs/verify/ext-d0-fixes-r3.md`).

Draft of 2026-10-11 (task D0-E2). The prompt's `SCENES.md` (6 item 5) is kept as two files:
[SCENES.md](SCENES.md) (part 1, start-up and UI) and this one (part 2, play), because the other
D0 files cite both by section. This part covers the map, the
scroll and centring rules, the minimap, the left column (status and unit panels), the menu bar
row, and every full-screen or picture scene reached during play. The start-up and UI scenes
(intro, title menu, setup, Birth, generic menus) are in SCENES.md; the shapes are in
[SPRITES.md](SPRITES.md); frame waits and fades are in [TIMING.md](TIMING.md); driver functions
in [DRIVER.md](DRIVER.md).

Evidence labels: **DOS file**, **DOS listing**, **inferred**, **unknown**. No DOS bytes are
reproduced; strings are named by DGROUP offset and at most a few words. Coordinates are logical
320x200. Addresses: R:ssss:oooo root, O<n>:oooo overlay, G#n graphics driver slot, DGROUP:oooo
data. Windows addresses (ssss:oooo, no prefix) and names come from `claude/docs`; a Windows
counterpart is **inferred** from matching behaviour unless stated otherwise.

How this was made: D0-E2 read the map, panels, blink, movement, scroll and minimap code itself.
The full-screen scenes (section 7) were read from the listings by three read-only helper passes
and integrated here; D0-E2 rechecked the items listed in section 0.3 and corrected one rectangle.
All scene facts are **DOS listing** unless the row says otherwise.

## 0. Shared machinery

### 0.1 Helpers used by many scenes (DOS listing)

| Helper | Behaviour |
|---|---|
| R:0000:0BFA(port, x, y, w, h, c) | fill rectangle |
| R:0182:000A(x1, y1, x2, y2, c) | line on the current view port DGROUP:00AA |
| R:0182:005C(str, x, y, c) | text; R:0182:0086 shadowed text (colour 0 at y + 1, then c at y); R:0182:00B3 centred on x; R:0182:00EF width |
| R:1D05:0A05(x, y, w, h, c) | rectangle outline from (x, y) to (x + w, y + h) inclusive |
| R:1D05:0A66(x, y, w, h, cA, cB) | bevel: top and right edges cB, bottom and left edges cA |
| R:1DC4:03CE(x, y, w, h) | panel texture: 256-colour mode tiles page 2 (288, 120, 32x16); EGA fills colour 7 |
| R:0238:1BB2(x, y, w, h) | R:1DC4:03CE, then bevel (x, y, w − 1, h − 1, 15, 8) |
| R:01A8:0250 / R:01A8:0268 | show / hide the mouse pointer (counter DGROUP:DEEA; G#30 PointerDraw / G#15 PointerRestore) |
| R:0866:25B6 / R:0866:25D7 | G#20 copies the whole screen to page 1 / back. R:0ADE:0394 and 03BF wrap them with hide/show |
| R:0238:001E(str, x, y) | message box or menu with screen save: hide, save page 0 to page 1, R:1D05:0018, restore |
| R:1D05:0018 / R:1D05:0000 | text box or menu R:1D05:0031; with DGROUP:DB38 set it only draws and returns |
| R:1D05:0475 | the box drawer; header number DGROUP:2F9E selects an icon and title (section 0.2) |
| R:1459:0918 | flush input, wait for a key or a mouse click |
| R:0182:0134(n) | wait n frames of the frame counter DGROUP:005C (TIMING.md 3.3) |
| R:0000:04D4(n, r, g, b) / R:0000:04AA(n, buf) | fade to a colour / to a palette (TIMING.md 3.5) |
| R:1DC4:065F / R:1DC4:0626 | stop / restart the map's palette cycles (set up by R:1DC4:05DD: slots 1..3, rate 15, colours 60h..67h, 68h..6Fh, 70h..7Fh) |
| R:1F4D:01AD(file, key) | read a keyed section of a TXT file into DGROUP:BA06; R:1F4D:044F(key) does it for KING.TXT with token replacement |
| R:1F4D:0088(chars, x, y, c) | word-wrap DGROUP:BA06 at chars * 8 pixels; "^" breaks a line; stops below y 192 |
| R:01A8:02A4(n, flag) | disk prompt helper (string DGROUP:1A93 "Please insert Disk") (meaning inferred) |
| R:01A8:046C(id, ...) | sound, only when option bit DGROUP:19C0 & 10h |

### 0.2 Text box headers (DGROUP:2F9E)

| Value | Title (DGROUP 2FA6 table) | Icon | Label |
|---|---|---|---|
| 0, 1, 2 | "Spies", "Diplomats", "Travelers" plus " report:" | SP299 shape DF62[n] at (x − 40, y − 5) | DOS listing (R:1D05:05ED..0753) |
| 3, 4, 5, 6 | Defense Minister, Domestic Advisor, Foreign Minister, Science Advisor | G#20 from page 2 (40n + 40, 140, 40x60), a GOVT portrait | DOS listing |

The title is drawn at (x + 5, y − 4) in colour 15 with a colour-11 line under it.

### 0.3 Return to the map, and rechecked items

**R:0238:1B44** ends most scenes (DOS listing): stop cycles; set DGROUP:1C28; in 256-colour
mode fade to black R:0000:04D4(5, 0, 0, 0); hide pointer; full map redraw R:1AEA:0008 (which
also redraws the menu bar and status panel); unit panel frame R:0238:1BB2(0, 97, 80, 103); show
pointer; **R:0238:1BEB** (256-colour only): the M0 chunks of `back<g><a|m>.pal` and SP256.PAL
into DGROUP:C1D6 and C5BE, colours 128..255 of the first copied over the second, fade in
R:0000:04AA(5, C5BE); restart cycles.

Rechecked by D0-E2 in the listing: O8:0920..0992 and O19:14FB..1536 (building cut rectangles;
the helper had x and y swapped), O19:13A1..145F (houses, roads), O19:16FB..1731 (invaders),
O12:0330..0399 (world map tiles), R:1DC4:03CE (panel texture), R:0238:1BEB (map palette), G#10
calls at O17:0780 and O19:0E3C, and the picture names in DGROUP (DOS file).

## 1. The play screen

| Area | Rectangle | Drawn by | Label |
|---|---|---|---|
| Menu bar | (0, 0, 320, 8) | R:0238:0FEA | DOS listing |
| Minimap | (0, 8, 80, 50) | R:1AEA:0008 | DOS listing |
| Status panel | (0, 58, 80, 39) | R:0238:107E | DOS listing |
| Unit panel | (0, 97, 80, 103) | R:0403:4060 | DOS listing |
| Map view | (80, 8, 240, 192): 15 columns x 12 rows of 16x16 squares | R:1AEA:0008, R:1AEA:03BA | DOS listing |

Windows counterpart: the main map window, small-map window and Status window (graphics.md 4.10,
4.11, 4.20) in a resizable layout.

### 1.1 Pages during play

| Page | Contents | Label |
|---|---|---|
| 0 | the screen (A000h) | DOS listing (DRIVER.md 3.1) |
| 1 | scratch: screen save-under for boxes and reports, picture loading, the move animation's map copy | DOS listing |
| 2 | the map's data page and resident art (below) | DOS listing |
| 3 | EGA only: SPRITES.PIC (SPRITES.md 5) | DOS listing |

Page 2 as a data store (DOS listing; readers R:0866:25F8 = G#14 GetPixel(2, x, y), writers
R:1AEA:17CF):

| Page 2 area | Meaning |
|---|---|
| (x, y), x 0..79, y 0..49 | terrain colour; DGROUP:2BA6 maps colour to terrain type (R:1AEA:134A) |
| (x + 160, y) | bit 3 (value 8): units present; bits 0..2: a civilization number (R:1AEA:14E0 returns it when bit 3 is set, else −1; R:1AEA:1369 returns bits 0..2; R:1AEA:138C rewrites them keeping bit 3) |
| (x, y + 100), (x, y + 150) | improvement bits, low and high nibble (R:1AEA:1585): 1 city, 2 irrigation, 4 mine, 8 road, 10h railroad, 20h fortress, 40h pollution; (x, y + 150) & 8 also selects the second river set |
| (x + 80, y + 100), (x + 80, y + 150) | the improvements the player knows (R:1AEA:15C1) |
| (240..319, 0..49) | the minimap image, one pixel per square |
| (160..319, 50..199) | SP299.PIC art, and from y 140 the GOVT portraits (SPRITES.md 7) |

The meaning of improvement bits 20h and 40h is **inferred** from their drawing (fortress shape,
pollution shape) and the unit panel's "(Pollution)" line.

### 1.2 Palette

At the start of play the whole palette is SP257.PIC's (R:1FA1:026C at R:01A8:0867), with the
three map cycles set up (R:1DC4:05DD). After any scene that returns through R:0238:1B44 it is
SP256.PAL colours 0..127 plus `back<g><a|m>.pal` colours 128..255 (section 0.3). SP257.PIC and
SP256.PAL have the same palette (**DOS file**). The GOVT portraits in page 2 use only colours
144..248, which BACK0A.PAL supplies (**DOS file**, GOVT0A.PIC checked). The map cycles start only
when the 256-colour flag is set and DGROUP:2FEC is 0 (R:1DC4:0626). Windows counterpart: the
god palette with colour bases (palette-pictures.md).

## 2. The map

### 2.1 One square: R:1AEA:03BA(x, y)

Screen position (DOS listing, R:1AEA:03BA..0477): `px = wrap(x − [D4CC]) * 16 + 80`,
`py = (y − [D75E]) * 16 + 8`, where wrap adds or subtracts 80 (R:1E31:119B). The square is drawn
only when `80 <= px < 320` and `8 <= py <= 192`. The pointer is hidden around the drawing.
`T` = terrain (R:1AEA:134A); `I` = the improvements the player knows (R:1AEA:15C1), or all of
them when DGROUP:D806 is set (reveal-all flag, **inferred** debug).

Layers, in order (DOS listing):

| # | Layer | Rule | Shape |
|---|---|---|---|
| 1 | Ocean (T = 10), 256-colour | land mask: bit d − 1 set when neighbour d (x wrapped) is not ocean; `m9 = (mask << 2) + ((mask >> 6) & 3)`; quarter k uses pattern `(m9 >> 2k) & 7` | coast quarters D294 at (px, py), (px + 8, py), (px + 8, py + 8), (px, py + 8) |
| 1a | whole-square coasts | masks 1Ch, C1h, 07h, 70h, 8Fh, F8h | G#20 from page 2 (224 + 16j, 100, 16x16) over the quarters |
| 1b | river mouths | each of N, E, S, W whose neighbour is River | D2D4[d / 2] |
| 1' | Ocean, EGA | 4-bit N/E/S/W land mask | G#20 page 3 (16 mask, 64) |
| 2 | Land base | every non-ocean square | G#20 page 2 (256, 120, 16x16); EGA page 3 (0, 80) |
| 3 | Irrigation | I & 2, not ocean, DGROUP:DCFC clear, not a city | D4CE[4] |
| 4 | River (T = 11) | N/E/S/W mask of River or Ocean neighbours (no x wrap); + 16 unless 256-colour and page 2 (x, y + 150) & 8 | 6DFE[index] |
| 4' | Other land, 256-colour | N/E/S/W same-terrain mask | T[T][mask] (B886) |
| 4'' | Other land, EGA | variant `(x + y) & 1` (Grassland: `((11y + 7x) & 2) >> 1`) | T[T][variant] |
| 5 | Grassland marker | T = 2 and `((7x + 11y) & 2) == 0`, 256-colour | B880 at (px + 4, py + 4) |
| 6 | Pollution | I & 40h | D4CE[6]; EGA recolours the square (2 to 0, 10 to 15, 9 to 8, 11 to 0) |
| 7 | Road / railroad | I & 8: for each direction with a road neighbour, railroad shape B29A[d − 1] if both squares have city or railroad bits, else road B27A[d − 1]; no neighbour: a 2x2 dot at (px + 7, py + 7), colour 0 (railroad) or 6 (road) | |
| 8 | Mine | I & 4, DCFC clear | D4CE[5] |
| 9 | Special resource | R:1AEA:1836(T, x, y) | D4CE[16 + T] |
| 10 | Hut | R:1AEA:1894(T, x, y) | D4CE[31] |
| 11 | Fortress | I & 20h | D4CE[30] |
| 12 | Unexplored edges | unless D806: for N, E, S, W, the neighbour not seen by the player (visibility byte, bit player) | 7EEC[d / 2] |
| 13 | City | I & 1, DCFC clear (section 2.3) | |

**Special and hut rules** (DOS listing): both are false for y <= 1 or y >= 48. With
`s = (x >> 2) * 13 + (y >> 2) * 11 + [6E80]` and `p = (x & 3) * 4 + (y & 3)`, a special exists
when `p == (s & 15)`; a hut when T is not Ocean, the square's visibility byte has bit 0 clear,
it is not a city and `p == ((s + 8) & 31)`. DGROUP:6E80 is the world seed (**inferred**; the
Windows counterpart g_randomSeed is used the same way).

Windows counterpart: ComputeTileAppearanceKey (1118:04B4), RenderTileFromKey (1118:0000) and
DrawMapTile (1110:04D0) (graphics.md 4.10) compose the same layers into a cached 32x32 bitmap.
The DOS program draws straight to the screen without a cache.

### 2.2 Units

**R:1AEA:11D4(x, y)** draws the square, then its top unit: R:1AEA:1458 finds the unit; a
foreign unit is shown only if its visibility bit for the player is set, and none is drawn on the
player's own city square; R:1AEA:125B prefers a ship on an ocean stack (DOS listing).

**R:1AEA:0E29(civ, unit)** (DOS listing):
* Visibility as in 2.1. A land unit on ocean with flag 1 is not shown (**inferred**: carried).
* If the stack has another unit (unit + 0Ah not FFh), the unit's shape is drawn first at
  (px + 1, py + 1): a stack shadow.
* Then **R:1AEA:0FB3(civ, unit, px, py)**: shape D4CE[64 + 32 civ + type] at (px, py), then:

| Condition | Mark |
|---|---|
| flags & 8 (fortified) | D4CE[29] frame at (px, py) |
| else flags & 4 | shadowed "F" (DGROUP:2BA0) at (px + 4, py + 7), colour 9 for civ 1, else 15 |
| own unit with a goto target (unit + 6 not FFh) | shadowed "G" (DGROUP:2BA2) |
| flags & C2h, not an air unit | shadowed letter at (px + 4, py + 7) and outline (px − 1, py − 1, 15, 15, colour 7); letter by flags: 40h with type 0 "I", 40h otherwise "?", 80h "M", 80h + 40h "F", 80h + 2 "P", otherwise "R" |
| flags & 1 (sentry) | G#3 recolours 5 and 8 to 7 over the unit (dimmed) |

Letter meanings (irrigate, mine, fortress, pillage, road) are **inferred** from the letters.
Unit records: DGROUP:81D4 + civ * 600h + unit * 0Ch (**DOS listing**).

**World mode** (DGROUP:B278 == 1): squares are 4x4 fills at (4x, 4y) in colour 1 (ocean), 2
(land) or the owner's colour (city); units are a 3x3 colour-6 (type 0) or colour-0 fill at
(4x + 1, 4y + 1) under a 3x3 fill in the civilization colour. No writer of B278 was found
(**unknown** when it is set).

Windows counterpart: DrawUnitAt (1110:0FF6), FindBestDefenderOnSquare.

### 2.3 Cities on the map (DOS listing, inside R:1AEA:03BA)

City fields below are DGROUP offsets plus 1Ch * city (DOS listing).
* A foreign city whose known size (70F4) is 0 is skipped unless D806.
* Outline (px + 1, py + 1, 13, 13) colour 15; outline (px + 2, py + 1, 12, 12) in the secondary
  colour (DGROUP:1956[owner]); fill (px + 2, py + 2, 12, 12) in the main colour (1946[owner]).
* D4CE[28] at (px + 1, py + 1); G#3 recolours 5 to the secondary colour.
* Size: real size (70F3) for own cities or D806, else the known size, as text at
  `(px + 6 or px + 3 for two digits, py + 5)` colour 0; with civil disorder (70F2 bit 0) the
  citizen shape 6E96[4] at (px + 5, py + 2) instead.
* Units present or a stored unit (7106 not FFh): outline (px, py, 15, 15) colour 0.
* Walls (70EC bit 80h): D4CE[29] at (px + 1, py + 1).
* The label is recorded (px, py, city) in DGROUP:6DAC, 6E3E, DF20 for at most 32 cities.

City records: 128 records of 1Ch bytes; 70EC is the improvement word, 70F0/70F1 x/y, 70F7 the
owner (DOS listing; field names inferred from use). Windows counterpart: DrawMapTile's
city marker (graphics.md 4.10.4); DrawCityLabels (1208:1F64) for the labels.

### 2.4 Full redraw: R:1AEA:0008(civ, vx, vy)

DOS listing, R:1AEA:0008..03B9:
1. Hide pointer; clear DGROUP:1AE0; menu bar R:0238:0FEA; status panel R:0238:107E.
2. `[D4CC] = wrap(vx)`, `[D75E] = clamp(vy, 0, 38)`.
3. **Dissolve order**: `p = random(256)` (C rand through R:1DC4:005D), then 256 steps
   `p = (5p + 1) & FFh`, column `p & 15`, row `p >> 4`; for row < 12 and column < 15 a seen
   square is drawn with R:1AEA:11D4 and an unseen one filled black. Every square is drawn once,
   in a pseudo-random order, with no delay (**DOS listing**; whether the order is visible
   depends on drawing speed, **inferred**).
4. **City labels**: for each recorded city with py < B8h: the name (R:1459:08C6) truncated to
   `327 − px` pixels (R:1F4D:04F7), shadowed text at `(clamp(px − 8, 80, 999), py + 16)`,
   colour 11.
5. Minimap (section 4); show pointer.

The C rand call advances the C library generator, not the game's own RNG state (**inferred**;
TIMING.md and the RNG notes govern).

## 3. Scrolling, centring and the viewport

| Rule | Value | Address | Label |
|---|---|---|---|
| Viewport | 15 x 12 squares; origin DGROUP:D4CC (x, wraps 0..79) and D75E (y, 0..38) | R:1AEA:0008 | DOS listing |
| Keep-in-view test for the player's active unit (not working, flags & C2h clear) | stays if `D4CC < x <= D4CC + 14` and `D75E < y < D75E + 10` (unsigned, no wrap) | R:0403:0371..03B8 | DOS listing |
| Recentre | wait 30 frames (not in world mode), then R:1AEA:0008(civ, x − 7, y − 6) and the unit panel | R:0403:03CF..0433 | DOS listing |
| Minimap click | x < 80, y < 58: R:1AEA:0008(civ, wrap(mx + [6ED6] − 7), clamp(my + [70EA] − 14, 0, 49)) | R:0403:073A..0781 | DOS listing |
| Map click | square `((mx − 80) / 16 + D4CC, (my − 8) / 16 + D75E)` | R:0403:06B4..06F0 | DOS listing |
| Moves of other units | for the player's units, or any unit when option bit DGROUP:19C0 & 20h is set: R:0866:16A9 brings the square into view, the unit is drawn, and for another civilization the game waits 30 frames (not in world mode); otherwise the unit is drawn and, when it was visible, the game waits 10 frames | R:0403:31A9..323A | DOS listing |

The keep-in-view test does not handle the x wrap, so near x 79/0 a unit inside the view can
trigger a recentre (**inferred** from the unsigned compares). Windows counterpart:
EnsureSquareInMapView and CenterMapOnSmMapClick (1210:056E).

## 4. The minimap (world map window)

DOS listing, R:1AEA:0008 (01A0..03B0):
* Offsets: `offx = vx − 32` (wrapped into 0..79), `offy = vy − 19`, set to 0 when
  R:0ADE:22B5(1 << civ, 8) is true; rows outside the map are clipped. Stored in DGROUP:6ED6 and
  70EA.
* Fill (0, 8, 80, 50) colour 0; G#20 copies the image from page 2 (240 + offx, offy) to (0, 8 +
  ...) in two parts for the x wrap. With D806 the copy comes from page 2 (0..95, 0..49) with
  clamped offsets (the terrain colours themselves).
* Cities: for each city that is the player's or has a known size, a pixel in the owner's main
  colour (R:1AEA:17FF).
* Bevel R:1D05:0A66(0, 8, 79, 49, 15, 8).
* View rectangle R:1D05:0A05(vx − offx − 1, vy − offy + 7, 17, 10) colour 15: 15 columns but
  only 9 rows of the 12-row view are inside it (**DOS listing**; whether this is intended is
  **unknown**).

The call R:0ADE:22B5(1 << civ, 8) passes a bit mask where every other caller passes a civ number
(O5:1B48, R:0238:1C3A); **inferred** DOS defect. Windows counterpart: DrawSmTiles (1210:09B4)
draws the whole world every time and uses g_mapViewRows for the frame.

## 5. The left column and the menu bar

### 5.1 Menu bar: R:0238:0FEA

Fill (0, 0, 320, 8) colour 0; five titles (DGROUP:1D6F..1D8E: GAME, ORDERS, ADVISORS, WORLD,
CIVILOPEDIA) at x 8, 64, 128, 192, 240, y 1, colour 15. Each string has byte 87h after its first
letter (meaning **unknown**; **inferred** a font control). A click with y < 8 opens R:1C84:0000
(menus; SCENES.md). DOS listing.

This is the DOS play-screen bar. The profile does not use its geometry during play: the DOS
play-screen layout add-on is withheld, so the menu bar keeps the Windows layout and positions
(DOS-PROFILE.md row 121; OPEN.md P24).

### 5.2 Status panel: R:0238:107E

Not drawn in world mode. DOS listing, R:0238:107E..1387:

| y | Contents |
|---|---|
| 58..96 | panel R:0238:1BB2(0, 58, 80, 39) |
| 60..70 | fill (3, 60, 74, 11) colour 11 (sky) |
| 60 | if DGROUP:D808 > 1: bar (3, 60, clamp(2 [D808], 0, 60), 2) colour 15 (Windows: g_peaceTurns, so peace turns, **inferred**) |
| 57..71 | mini palace R:0238:14A3(player, [1C20], 8, 58): nine 7x15 strips at x 8 + 7i, y 57; ground line (3, 71)..(76, 71) colour 2 |
| 59 | with D806: free memory (G#1) as a number, colour 0 |
| 73 | population (R:1DC4:02CD, the sum of 1 + 2 + ... + size over the civ's cities, formatted by R:1DC4:0337) plus "#", colour 0, at x 2 |
| 81 | year: absolute DGROUP:B220 plus " BC" / " AD" (R:0238:1720), colour 0 |
| 80..87 | research icon: G#20 page 2 (160 + 8k, 120, 8x8) to (48, 80), k = clamp(4 [6DEC + 2 civ] / (cost + 1), 0, 3) with cost = (2 [6B86] + [D2DE] + 6) * [E898 + 2 civ] * (1 in BC years, else 2) (R:0238:11BE..11F3) |
| 80..87 | if DGROUP:B1EA (global warming counter) is not 0: G#20 page 2 (160 + 8k, 128) to (56, 80), k = clamp(B1EA / 4, 0, 3) |
| 89 | treasury DGROUP:B1D6[civ] + "$", then three rates `10 − a − b`, `a`, `b` with a = DGROUP:DF0E[civ] (tax), b = B210[civ] (science), so the order is luxury, tax, science; the meaning of DF0E and B210 is settled by the rate menus (7.20), colour 0 |

Then, once per milestone, a population message box (DGROUP:1DA5, "The population of the
fertile ...") at (100, 80) through R:0238:001E, header 4.

The mini palace: R:0238:14A3(civ, count, x, y) picks per slot a level and a style from
DGROUP:D91E and B222 for the player; for other civilizations from a private LCG `v = 5v + 1`
seeded with `civ * [6E80]` (R:0238:152F..1630). Kinds 0..4 come from neighbouring slots.
Windows counterpart: DrawStatusCivPanels (1088:13D5), DrawMiniPalace (1088:1A82).

A click at x < 80, 58 <= y < 72 opens the palace view (section 7.8).

### 5.3 Unit panel: R:0403:4060(civ, unit)

DOS listing, R:0403:4060..4507. Hide pointer; R:0238:1BB2(0, 97, 80, 103). Text colour 0, x 4:

| y | Line |
|---|---|
| 99 | civilization adjective (DGROUP:1982[civ]) |
| 107 | unit type name (DGROUP:112A + 22h type) |
| 115 | "Veteran" (DGROUP:20A3) at x 8, if unit flag 20h |
| next | "Moves: " + moves / 3, with "." + remainder when not whole; plus "(n)" for types whose table word +4 is set (**unknown** meaning) |
| next | home city name (unit + 0Bh) |
| next | "(" terrain name ")" |
| next lines | "(RailRoad)" or "(Road)", "(Irrigation)" or "(Mining)", "(Pollution)" from the square's improvements |
| +4, then rows of 16 | other units in the stack as shapes, 4 per row at x 8, 24, 40, 56, until y 184; on a city square the city's two stored units (DGROUP:7106 and 7107 + 1Ch * city) are drawn as fortified dummies first |
| 192 | "+" at x 74 when more units did not fit |

End of turn (unit = 80h): "End of Turn" (4, 124), "Press Enter" (4, 136), "to continue"
(4, 144) (DGROUP:207F, 208B, 2097). Windows counterpart: DrawUnitInfoPanel (11F0:468C).

## 6. Active unit blink and unit movement

### 6.1 Blink: R:0866:0AD6(civ, unit, cx, cy)

DOS listing, R:0866:0AD6..0CF4; called from the main loop R:0403:0655 before the key read:

| Phase | Drawing | Wait |
|---|---|---|
| A | square without the unit (R:1AEA:03BA); minimap pixel at (mx, my + 8) colour 15; end of turn: "End of Turn" (4, 124) colour 7; optional square cursor at (cx, cy): outline (px, py, 15, 15) colour 15 | 10 frames, or 1 frame if a key is waiting (`kbhit`, R:2045:2098) |
| B | the unit (R:1AEA:0E29); minimap pixel colour 1 (ocean) or 2 (land); "End of Turn" colour 0; cursor outline colour 0 | 10 frames or 1 |

The loop repeats while no key is waiting and DGROUP:DB3A (mouse button) is 0; R:01A8:0223 polls
the mouse between phases. Minimap position: `mx = wrap(x − [6ED6])`, `my = y − [70EA]`
(clipped to 0..49). Period: 20 frames (TIMING.md: about 0.29 s at 70 Hz, **inferred**).
Windows counterpart: BlinkActiveUnitUntilInput (11C0:0EC2) with PlotSmMapSquare.

### 6.2 Move animation: R:0866:1D55(civ, unit, dir)

DOS listing, R:0866:1D55..1F68. World mode: only the origin square is redrawn. Otherwise: hide
pointer; draw the origin square; if both squares are visible (R:0403:4508): draw the next stack
member on the origin (on ocean only a ship); G#20 copies the map area (80, 0, 240x200) from the
screen to page 1; then for s = 0..16: the unit shape at (px + dx s + 1, py + dy s + 1)
(R:1DC4:009A), wait 1 frame, restore the 16x16 rectangle at (px + dx s, py + dy s) from page 1.
So 17 frames, one pixel per frame. Show pointer. Windows counterpart: AnimateUnitMove
(11C0:2C32), 9 frames of 4 pixels (graphics.md 4.19).

### 6.3 Input on the play screen (DOS listing, R:0403:0676..0846)

Key read R:1D05:0AC9. Mouse: y < 8 menu bar; x < 80: minimap (y < 58), palace view
(58 <= y < 72), end of turn (y >= 72 when unit = 80h); x >= 80 map square; right button
(DB3A = 2) is handled from R:0403:0850 (not traced). Function keys F1..F10 open reports
(section 7.14, table from R:0403 3B7D..3BFF).

## 7. Full-screen scenes

Each entry: routines and callers; pictures; palette; text; layout; timing; transitions; input;
Windows counterpart. All are **DOS listing** unless marked. Unless stated, a scene draws straight
onto page 0 (no G#31 ShowPage or dissolve) and saves and restores the screen through page 1.

### 7.1 City screen: R:0D12:0045(city, mode)

| Item | Contents |
|---|---|
| Routine, callers | one function of about 27 KB; callers R:0ADE:03EA, R:0ADE:0093, R:1459:0597 |
| Pictures | none loaded; shapes from SPRITES.md (citizens 6E96, icons D4CE[8..15], units D54E, B2BA); building icons 18x10 from page 2 by R:0D12:7045: icon n (after skipping 16h..18h and shifting) at `(161 + 19 (n div 5), 50 + 10 (n mod 5))` for n < 40, else `(161 + 19 (n & 1), 100)`; panel background R:0D12:710D tiles page 2 (208, 100, 16x16) in 256-colour mode, fills colour 9 in EGA |
| Palette | none loaded; G#3 recolours: selected tab 9 to 15, building list 14 to 12, deficits 15 to 0, first unhappy citizen 5 to 12 |
| Text | title "name (Pop:n)" (DGROUP:24EC) centred at x 104, y 2, colour 15, font 2 |
| Layout | screen filled colour 0. Header (2,1)-(208,21) with citizens row at (8, 8, 192 wide). Resources panel (2,23)-(124,65): title bar colour 1, rows at y 33, 41, 49 (food, shield, trade icons), y 57 luxury/tax/science. Map panel (127,23)-(208,104): 21 squares by R:1AEA:03BA with a temporary origin (city x − 5, y − 3); worked squares outlined colour 12. Supported units (2,67)-(124,104). Food box from (2,106). Tabs INFO, HAPPY, MAP, VIEW at y 106..114 from x 95. Improvements list (211,1)-(317,97), 6 pixels per row, MORE button. Production box from (230,99) with CHANGE, BUY. RENAME (231,190)-(272,198), EXIT (284,190)-(316,198) colour 12 |
| Timing | blinking CHANGE button and cursors: 10 frames per phase (R:0D12:4A43 and others, TIMING.md 5.8) |
| Transitions | none |
| Input | keys A, b, c, i, h, m, v, a, s, 1..9, p, M, r; mouse regions per area; VIEW calls the city view O19:0000(city, −1); anything else exits |
| Windows | ProcessCity (1030:0000), ShowCityScreen (1170:05AF), CityScreenWndProc (1030:9C17) |

### 7.2 City view and new wonder: O19:0000(city, mode)

| Item | Contents |
|---|---|
| Callers, modes | R:0D12:1DD5 (wonder built: mode = item), R:0D12:4FDB (VIEW, −1), R:0D12:5D70, 615C, R:1459:0378 (−2, before an animation, 7.3), O22:1119 (−3, after the founding animation) |
| Pictures | CITYPIX1.PIC: houses 31x31 at (64s + 1, 1), (64s + 33, 1), (64s + 1, 33), (64s + 33, 33), s 0..4; roads 24x8 at (24 (i & 7), 41h or 51h + 8 (i div 8)). CITYPIX2.PIC (CITYPIX3.PIC after advance 25h): buildings 49x49 at `(50 (i div 4) + 1, 50 (i mod 4) + 1)` (rechecked). WONDERS.PIC and WONDERS2.PIC: rectangles from the far table at segment [6444]. HILL.PIC background in page 1; POP.PIC citizens 34x50 at (35i + 1, 1 or 52) |
| Palette | HILL.PIC's (R:1FA1:026C); from mode −3 a fade-in from HILL.PAL R:0000:04AA(15, BDEE); cycle slot 4, rate 15, colours 40h..4Fh |
| Text | city name centred at (161, 3) colour 0 and (160, 2) colour 15, year at y 16/15, font 6; or a pending message box at (80, 8) |
| Layout | 19 x 12 grid seeded by srand(sum of the name's characters); houses, roads, buildings and wonders placed on page 1, then copied to page 0 |
| Timing | new wonder: 60 frames, then redraw with the wonder and G#10 DissolveToScreen(1, 10) with sound 2Ch |
| Transitions | G#20 page 1 to page 0; dissolve for the wonder |
| Input | key or click (R:1459:0918); exit through R:0238:1BEB |
| Windows | ShowCityView (11B0:0000) |

### 7.3 Riot, celebration and invaders animations (O19)

| Item | Contents |
|---|---|
| Routines | O19:167B(civ) invaders (after plunder or capture), O19:18C1 civil disorder, O19:1AE1 celebration ("we love the king"); called after O19:0000(city, −2) |
| Pictures | when the civilization knows advance 22h: INVADERS.PIC (if it also knows 3Ah) or INVADER2.PIC, 10 cuts 78x60 at (79 (i mod 4), 61 (i div 4) + 2) (rechecked); INVADER3.PIC otherwise: 78x65 at (79 (i mod 4) + 1, 66 (i div 4) + 1). RIOT.PIC (advance 0Dh) or RIOT2.PIC; LOVE2.PIC (advance 23h) or LOVE1.PIC, 10 cuts each |
| Palette | invaders: DAC 0FDh set to (3, 3, 3) by R:1DC4:0698 |
| Layout | lower half (0, 100, 320x100) saved in page 1; each frame restores it, draws the figures with G#6 at y about 132 and copies the half to the screen. Invaders: 8 figures moving right 3 pixels per frame (220 frames). Riot: 4 figures, offsets DGROUP:4F42/4F4A. Celebration: 4 figures moving left |
| Timing | one frame per 10 frames of the counter (R:0000:033E / 033A) |
| Input | key or click aborts; then R:0238:1B44 |
| Windows | 11B0:1B63 (capture), 11B0:1FAC (disorder), 11B0:237C (celebration) |

### 7.4 City founded: O22:0EAF(city)

| Item | Contents |
|---|---|
| Caller | O20:047C (FoundCity, when option bit 8 and the disk check pass) |
| Pictures | SETTLERS.PIC: 4 cuts 47x15 at (1, 16i + 1); HILL.PIC |
| Palette | HILL.PIC's; at the end in 256-colour mode R:0000:04D4(10, 0, 0, 0) |
| Text | "<city> founded: <year>." centred at (160, 4) colour 0, font 6 |
| Layout | strip (0, 120, 320x40) saved; for x 80..119 four figures at (x + 13k, 120 + (10k & 15)) |
| Timing | one step per 10 frames |
| Transitions | then the city view O19:0000(city, −3) with a fade-in, unless a key is waiting |
| Windows | ShowCityFoundedAnimation (11B8:14E5) |

### 7.5 Nuclear explosion: O22:0967(x, y)

NUKE1.PIC into page 1 **with** its palette (R:1FA1:0220); 28 frames 44x44 at
(45 (i mod 7) + 1, 45 (i div 7) + 1). Position `x = clamp(16 wrap(mx − D4CC) + 66, 80, 276)`,
`y = clamp(16 (my − D75E) − 6, 8, 156)`. Sound 2Ah. 35 steps (frames 0..27, then 21..27), each
G#6 then wait 5 frames then restore the 44x44 rectangle. Map palette back with R:0238:1BEB.
Callers R:0D12:66B5, R:19F3:0DA1. Windows: AnimateNuclearExplosion (11B8:0C3D).

### 7.6 Disasters and city events: O20:0540(city) (text boxes, no pictures)

Random case of 10 (R:1DC4:005D): earthquake, KING.TXT sections "*D1".."*D6", riots or
corruption with a citizens' demand, defection. Own city: header 4 (Domestic Advisor portrait),
box at (100, 80) via R:0238:001E. Foreign city seen by the player: header 2, box at (100, 64),
then the map recentres R:1AEA:0008(player, x − 10, y − 6). Windows: ProcessCityDisaster
(1040:068E).

### 7.7 Newspaper: O21:0000(city)

| Item | Contents |
|---|---|
| Callers | about 20 sites (O5:1C14, O7:1BFE, R:0238:0710.., R:0403:35B1, R:0ADE:19A9, R:0D12:07E8.., R:1459:03BA); headline in DGROUP:BA06; −1 picks a player city, −2 draws without saving or waiting |
| Pictures | none; torn edge: 16 x DF0C (SPRITES.md 6.5) at (20k, 100 − random(2)) |
| Palette | none, no fades |
| Text | name in font 5, one of four forms with the city name (fallback "<city> News" over 300 pixels); corner tag font 3 ("EXTRA!" or "FLASH"); "10 cents" and "January 1, <year>" font 1; slogan font 2 from KING.TXT "*NEWSA".."*NEWSN"; headline font 4 wrapped from (16, 40) |
| Layout | fill (0, 0, 320, 100) colour 15; rules at y 1, 35, 97 and the side lines, colour 0 |
| Input | box "Press any key to continue." at (80, 128); then restore |
| Windows | ShowNewspaper (1138:0000) |

### 7.8 Palace: O17

| Item | Contents |
|---|---|
| Routines | O17:0000 improvement scene (from R:0238:0666 when the score threshold R:0238:16E7 is reached); O17:07EC(sad) composer; palace view from the map R:0403:0796; sad palace from O2:1356 |
| Pictures | CASTLE<L>.PIC (L 0..4) into page 1: section pieces cut from quadrant (style & 1) * 160, (style & 2) * 50 with widths 52, 24, 24, 28, 27 and height 99 (special 35-wide pieces at (160, 101) and (196, 101)); CBACK.PIC or SAD.PIC background; CBACKS1..3.PIC strip at y 135; CBRUSH<n>.PIC gardens as whole-picture shapes (R:1FA1:044C) at (0, 94 or 105) and (184, 94 or 105) |
| Palette | CBACK.PIC's (R:1FA1:026C); SAD.PIC's for the sad palace (after a fade to black when DGROUP:DEBA > 7) |
| Text | KING.TXT "*PALACE" in a box at (20, 16); prompt "Which section shall we improve?" at (40, 16); digits 1..7 at (48i − 36, 144) and letters A..C at (120j + 40, 160), shadowed, colour 14; "Select new section." centred at (160, 3) |
| Layout | palace composed on page 1 from y 36, sections from x 16; previews in three boxes (100j − 80, 10, 80, 92) |
| Timing | none; the final reveal is G#10 DissolveToScreen(1, 20) |
| Input | keys 1..7, a..c or mouse; then key or click |
| Windows | RunPalaceImprovement (1158:0000), OpenPalaceView (1158:08E7) |

The palace view (R:0403:0796): compose, fill black, CBACK palette, G#20 page 1 to page 0, wait,
R:0238:1B44.

### 7.9 Throne room and leader audience: O6

| Item | Contents |
|---|---|
| Routines | O6:16CD emissary; O6:1D2B leader screen; O6:21AC throne-room background; O6:1B33 idle animation; O6:251D text strip |
| Pictures | text-only path when option bit 8 is clear or no disk: panel (0, 128, 320, 72). Picture path: GOVT<g><a|m>.PIC figures 78x99 at (80i + 1, 101); KING<NN>.PIC (KINK.. in 16 colours for leaders 0 and 3): portrait 139x133 at (181, 67), 14 expression pairs 59x20 and 59x29 at ((k mod 5) 60 + 1, (k div 5) 50); BACK<g><a|m>.PIC background with figures at x 41, 199, 1, 239, y 34 and the portrait at (90, 0) |
| Palette | BACK palette with colours 64..143 from the KING palette, set directly with G#28 (no fade) |
| Timing | idle animation inside the box wait, 10 frames per step |
| Text | lower strip (0, 128, 320x72) saved and a box at (20, 139): O6:251D(text, 14h, 8Bh) passes x 14h, but R:0238:0008 gets 24h (O6:254E..2554), so the box stands at (36, 139), frameless with the bars of y 139, its lines 8 pixels apart in the leader font 8 + LEADER_FONT[tribe] (10 replaced by 3; O6:180F..1833); the strip is put back at the return (O6:2572..259A) (read 2026-10-18 by unit D7k, `../ext-D7k-record.md`) |
| Tables | read 2026-10-18 by unit D7k (OFFSETS; FORMATS 6.1): the far segment [640A] holds LEADER_FONT (its first 16 bytes) and the throne-room tables LEADER_FACE_X/Y (u16 x 28 at 10h and 48h) and LEADER_ATTEND_X/Y (u16 x 56 at 80h and F0h), the expressions' and the attendant frames' places by animation style (O6:2380..23AF, 2485..24C2); LEADER_PORTRAIT DGROUP:3938 (the portrait of each tribe) and LEADER_SLOT_X DGROUP:3AFE (the figures' x 41, 199, 1, 239) |
| Windows | HoldDiplomaticAudience (1160:0000), RequestLeaderAudience (1160:20C0) |

### 7.10 Government change and New Cabinet: R:1517:04A1, O5:1AF6, O5:1BA2

Menu "Select type of Government" through R:0238:001E(100, 64); then O5:1AF6 reloads the GOVT
portraits into page 2 (SPRITES.md 7), R:0238:1B44 and O5:1BA2: save, newspaper O21(−2), fill
(0, 100, 320, 100) colour 15, title "New Cabinet:" font 6 centred at (160, 102), the four
portraits from page 2 at (20 + 80i, 118) with their titles (DGROUP:2FAC) centred at
(80i + 40, 180/186) in font 2; wait; restore. Windows: SetGovernment (1168:06C1),
AnnounceGovernmentChange (10E8:32C1).

### 7.11 Discoveries: R:0ADE:1584(civ, ...)

| Item | Contents |
|---|---|
| Condition | pictures only if the advance is not 47h, DGROUP:DEBA > 3, the disk check passes and option bit 8; otherwise the newspaper O21(−1) |
| Pictures | DISCOVR1.PIC (DISCOVR2.PIC after advance 36h) full screen; the advance's ICONPG cell (SPRITES.md 8) centred at (174, 96), or (174, 87) with DISCOVR2 |
| Palette | 256-colour: DISCOVRn colours 0..84 over the ICONPG1.PAL palette, fade in R:0000:04AA(30, C5BE) |
| Text | "<adjective> scientists" (or "wise men" before advance 14h) "discover the secret of <advance>" in font 6, box at (96, 1) or (96, 25) |
| Then | key or click; science advisor choice box ("Which discovery..." at (80, 64)); KING help via O8:062A on request; R:0238:1B44 |
| Corrections (extension D7i, 2026-10-18, DOS listing; `../ext-D7i-record.md`) | the text is in font 6 with DISCOVR1 only (R:0ADE:1861..1869; with DISCOVR2 DOS keeps the font in effect); the fade starts from the picture's own palette (R:1FA1:026C at R:0ADE:1764), not from black; the wait for a key or click is R:1459:0918 at R:0ADE:1994, after the fade; the newspaper branch (O21(-1)) uses the same DGROUP:BA06 sentence, built at R:0ADE:178C..1834 for both branches |

### 7.12 Production menu and advisor boxes: R:0ADE:0421, R:1D05:0475

"What shall we build in <city>?" menu at (80, 8) (font 2 over 20 items); with option bit 1, a
Military Advisor box at (8, 160) and a Domestic Advisor box at (164, 160) with PRODUCE.TXT texts.
Help (right click or Alt-H) opens the civilopedia entry without pictures. R:1D05:0475 draws
"(HELP AVAILABLE)" in colour 10, font 2, and the header icon (section 0.2). Selection flashes
with G#3 for 20 frames. The production menu has no header icon: R:0ADE:0421 never sets DGROUP:2F9E
(the portrait variant, R:1D05:0613) (read 2026-10-18 by unit D7f, `../ext-D7f-record.md` deviation 3).

### 7.13 Civilopedia: O8

| Item | Contents |
|---|---|
| Routines | R:1C84:07AF menu at (182, 8); O8:0000 index; O8:062A(item, category) entry (also from R:0ADE:1584, 0421, R:0238:1767) |
| Cell lookup | each lookup searches a byte table for the first entry equal to the number and returns that index as the cell, or −1 when none matches (DOS listing; review R2-5). Three tables lie in the root image: advances R:271E:0000..0047 (72 bytes, searched by O8:16C4, ICONPG1..8, 9 cells each), units R:271E:0044..005F (28 bytes, O8:1790, ICONPGA..E, 6 cells each) and terrain R:271E:0061..006C (12 bytes, O8:17C3, ICONPGT1..2, 6 cells each). The advance range overlaps the unit table at 0044..0047; those four bytes repeat earlier values, so the first match always lies before them (DOS file). DGROUP:6420 is the relocated segment word 271Eh |
| Pictures | advances: ICONPG1..8 cells; improvements 2..21: CITYPIX2.PIC cut 49x49 at `(50 ((item − 2) div 4) + 1, 50 ((item − 2) mod 4) + 1)` (rechecked) drawn at (37, 17) with HILL.PAL; units: ICONPGA..E cells 158x61 at ((idx & 1) 160 + 1, ((idx mod 6) div 2) 61) centred at (88, 42) plus the unit shape of civ 1 at (216, 48); terrain: ICONPGT1/T2 cells 106x77 at ((idx mod 3) 107 + 1, ((idx mod 6) div 3) 87 + 5) centred at (76, 46) |
| Palette | background (O8:066D..069B): 0FDh with DAC 253 := (61, 61, 61) on VGA with pictures, 0FFh without pictures, 15 on EGA. Then per picture kind (DOS listing; review R2-2): advances load the fixed name `iconpg1.pal` (DGROUP:3CE6) through R:1DC4:047D (O8:0768..076C) for every ICONPG1..8 picture; units the fixed `iconpga.pal` (DGROUP:3D4E, O8:0A1C..0A20) for every ICONPGA..E picture; improvements `hill.pal` (DGROUP:3D14, O8:0930..0934). R:1DC4:047D sets colours 0..15 from DGROUP:6B34 and DAC 45 after the load (PALETTE.md 2.5). Terrain (ICONPGT1/T2) does not use R:1DC4:047D: `sp256.pal` into DGROUP:C5BE (O8:0AFB..0AFF), applied with G#28 (O8:0B0B), then DAC 253 := (61, 61, 61) by R:1DC4:0698 (O8:0B13..0B1D). R:1DC4:047D applies the whole file, so the advance, unit and improvement pages replace that grey in DAC 253 with their file's entry 253, (58, 58, 58) in `ICONPG1.PAL`, `ICONPGA.PAL` and `HILL.PAL` (DOS file; PALETTE.md 2.5). Only `ICONPG1.PAL` and `ICONPGA.PAL` exist; the ICONPGT pictures' own palettes differ from SP256 in entries 17..31, 96..97, 109..110 and 224..255 (DOS file) |
| Text | index title shadowed at (161, 4)/(160, 3) colour 10; EXIT (286, 4), MORE (8, 4) colour 12; entry name font 6 centred at (cx, 20), category font 7 at (cx, 36); body from BLURB<cat>.TXT |
| Input | index cursor G#3 15 to 10; arrows, m, Esc or x; mouse rows of 7 pixels |
| Windows | ShowCiviliopediaSection (1068:0295), ShowPediaEntry (1068:06AF) |

### 7.14 Reports and advisors (O14 frame)

Common frame O14:0000/001C(title, background colour): fill the screen, title centred at
(160, 2) colour 15 (current font, not shadowed), realm line at (160, 10), leader and year line at
(160, 18). Close O14:013B: key, restore. Advisor portraits are copied from page 2 to (278, 2).
Windows: OpenReportScreenWithHeader (1018:0000), DrawReportHeader (1018:015D, font 7, shadowed).

| Report | Routine (key) | Background | Picture | Notes | Windows |
|---|---|---|---|---|---|
| City Status | O14:186F (F1) | 8 | none | rows from y 32, 8 apart, 20 per page | ShowCityStatus 1018:208F |
| Military Status / Losses | O14:03AD, O14:061F (F2) | 1, then 4 | Defense Minister page 2 (160, 140) | unit icons at (2 + 16 (n & 1), y − 4) | ShowMilitaryReport 1018:067B |
| Intelligence | O14:0D43 (F3) | 1 | none | rows 24 apart, INFO buttons, dossier O14:1164 | ShowIntelligenceAdvisor 1018:1221 |
| Attitude Survey | O14:15F4 (F4) | 9 | citizens rows, building icons | rows 10 apart | ShowAttitudeAdvisor 1018:1D5B |
| Trade | O14:07F1 (F5) | 2 | Domestic Advisor page 2 (200, 140) | two columns, paging | ShowTradeReport 1018:0BE0 |
| Science | O14:014B (F6) | 1 | Science Advisor page 2 (280, 140) | bulb bar centred at x 160, icon D4CE[12] | ShowScienceReport 1018:03F0 |
| Wonders of the World | O12:080D (F7) | 3 | wonder icons (R:0D12:7045) | rows 24 apart, 7 per page | ShowWondersOfTheWorld 1188:0B3E |
| Top 5 Cities | O3:09AC (F8) | 3 | citizens, wonder icons | rows 32 apart | ShowTopFiveCities 1080:099B |
| Civilization Score | O20:0CA9 (F9) | report frame | icons via O20:13F8 | "SCORING COMPLETED" | ShowCivilizationScore 1040:1137 |
| World Map | O12:0000 (F10) | 0 | 4x4 terrain tiles G#20 from page 2 (160 + 4t, 111 + 4 ((x + y) & 1)) (rechecked) | cities 4x4 and units 3x3 in civ colours; key wait unless world mode | ShowWorldMap 1188:013F (6x6) |
| Demographics | O12:0D6D | 1 | none | 13 rows 12 apart | ShowDemographicsReport 1188:123A |

Background colours differ from the Windows docs for Intelligence, Top 5 and Demographics
(DOS 1, 3, 1; Windows 0). Menus: Advisors R:1C84:0615, World R:1C84:06E4 (SCENES.md).

### 7.15 Historian and quiz

* **Historian O12:09E2** (from the turn loop R:0238:0092): background 3; header centred at
  (160, 4) and (160, 12); rows 24 apart with a mini palace R:0238:14A3 at (128, y − 13); a
  60-frame wait before each row. Windows: ShowHistorianReport (1188:0DB8).
* **Quiz O16:0000** (from R:0238:0092): stops cycles; ICONPG cell of the asked advance centred
  near (58, Y0 + 64), with the fixed palette name `iconpg1.pal` (DGROUP:4A36, O16:0100..0104;
  review R2-2); background 0FDh (VGA) or 15; title "CIVILIZATION QUIZ" centred at (160, 8);
  KING.TXT "*QUIZ"/"*QUIZ2", "*CORRECT", "*INCORRECT"; a menu of up to 12 answers. A second
  wrong answer removes the human's units (R:0866:0F10, **inferred**). Windows: RunCivilizationQuiz
  (1178:0000). Corrections (extension D7i, 2026-10-18, DOS listing): the first wrong answer goes to the second
  question without INCORRECT (O16:04AC: only the second question shows it); the answers box (R:1D05:0018 at O16:0442)
  stays on page 0 under the result.

### 7.16 Spaceship: O18

| Item | Contents |
|---|---|
| Routines | O18:0000 open, O18:016D close, O18:0259(civ, frames, allowLaunch) draw, O18:0C49 stars, O18:0F83 build (human), O18:0D4F (others), O18:1527 menu "Which nation?", O18:15C3 launch |
| Pictures | DOCKER.PIC with its palette; ten part shapes from the 26-byte records at DGROUP:4BD0 (name, mass, rectangle) (**DOS file**) |
| Palette | cycles: slot 1 rate 30 D0h..DFh, slot 2 rate 11 C0h..CFh, slot 3 rate 20 E0h..EFh, slot 4 rate 8 90h..9Fh, slot 5 rate 150 80h..81h; close restores the map palette (BACK colours 128..255 over SP256) without a fade |
| Layout | parts on a 16-pixel grid at (16 col − 16, 16 row + 8); right panel (240, 8, 80, 192) in the civ colour with stats at x 242, y 16..128; "LAUNCH" at (256, 190) |
| Timing | star frame every 4 frames (2 after launch) |
| Input | key, click; launch confirmation box at (80, 100) |
| Windows | OpenSpaceshipScreen (1070:0000), EvaluateAndShowSpaceship (1070:0327), AnimateSpaceshipStarfield (1070:12B5) |

Star motion: 20 stars, classes i mod 4: +2 pixels colour 7, +1 colour 3, +1 on odd frames colour
8; drawn only on black pixels; wrap at x 240. The spaceship arrival sequence O2:0BD7 (PLANET1,
PLANET2, SPACEST, SPRITES pictures, cycle slots 1..6) was only partly read. Read whole 2026-10-17 (unit D7l2,
`../ext-D7l2-record.md` "What was built"): the set-up, the pan (320 columns of 8 frames with a catch-up skip, a text
chunk every 22 columns, PLANET2's cut k mod 23 at (135, 51), the ship's dot on odd columns), the human's SPACEST.PIC
after a fade to black with six cycling slots or another civilization's sad palace O17:07EC(1) (O2:1356), the rest's
chunks with the blinking dot (no key test) and the key wait R:1459:0918 (O2:146C).

### 7.17 Endings and Hall of Fame

| Scene | Routine | Contents |
|---|---|---|
| End checks | R:0238:0092 | retirement message at year `2080 − 20 [6B86]`; game over for spaceship, conquest or year `2100 − 20 [6B86]`: "*** GAME OVER ***" |
| Conqueror | O9:0DDE, O9:0F79 | fade to black; KING<NN>.PIC head 139x133 at (181, 67) and two mouth pictures 59x49 at (1, 51) and (1, 151) (rechecked, O9:0FFD..1049); SLAM1.PIC, SLAM2.PIC strip at y 133; gallery heads 27x33; palette SLAM1 with colours 64..143 from KING, fade in R:0000:04AA(8); G#10 DissolveToScreen(1, 1Eh); 240-frame and 60-frame waits; captions font 6 centred at (160, 152) and (160, 168); final panel (18, 150, 284, 32) |
| After the end | R:0238:08A0 | POWERGraph O12:0573, replay O9:0000, score O20:0CA9, rating O3:065D, Hall of Fame O3:0513 |
| Advertisement | R:0238:090A | ADSCREEN.PIC full screen with its palette, wait |
| POWERGraph | O12:0573 | background 8; frame (4, 9, 311, 183); polylines in civ colours; year labels font 2; title shadowed at (100, 2) |
| Replay | O9:0000 | menu "See Replay?" (DGROUP:3FB0) at (100, 80); 4x4 map; event bar (0, 0, 320, 8) colour 15; mode 1 waits 30 frames per city event, mode 2 a key per event |
| Rating ladder | O3:065D(rank, score) | background 15; border tiles from page 2 (192 or 224, 120/128); Domestic Advisor at (10, 10), Foreign Minister at (270, 10); ladder 8 pixels per step from y 184; font 7 |
| Hall of Fame | O3:00D7(highlight) | background 15; "CIVILIZATION" / "HALL OF FAME" centred at y 16 and 24; entries 26 pixels apart from y 40; highlight G#3 15 to 14; "Clear" box at (236, 187); FAME.DTA (**DOS file**) |

Windows: ShowConquerorEnding (1180:152F), ShowHallOfFame (1080:0119), ShowCivilizationRatingRanking
(1080:06FF), ShowPowerGraph (1188:07AD), RunReplayMenu (1180:0000).

### 7.18 Notes, schism, diplomats and debug screens

* **Help notes O4** (DOS listing): O4:0000 help (fill colour 2, key text at (160, 192), body
  wrapped from (32, 32)); O4:02D3 instant advice when option bit 1 and the year is BC (box
  (56, 16, 208, 6n + 10) colour 2, outline 10, "--- Civilization Note ---" at (160, 19)); O4:03AA
  error note (colour 4, outline 12). Windows: ShowHelpNote (10E0:0000), ShowInstantAdvice
  (10E0:077F), ShowErrorNote (10E0:07E8).
* **Schism O15:0000**: KING.TXT "*SCHISM"/"*ESCHISM" box at (80, 80) with header 5; no picture.
  Windows: StartCivilWar (11A0:0000).
* **Diplomat and bribe events O22:0000, 0639, 0AF5**: text boxes at (80, 80), (100, 80), (80, 40),
  (100, 32). Windows: DiplomatEntersCity (11B8:0000), TransferCityByRevolt (11B8:0F26).
* **Debug (DGROUP:D806)**: O10 army map, O12:03AC tables, O13:0000 and O13:0554, F3 shows page 2
  with G#31 ShowPage(2). Not part of normal play (**inferred**); D806 has no direct writer found.

### 7.19 Unit stack popup: R:0866:1F69(civ, unit)

Added 2026-10-11 (review R3-8). DOS listing, R:0866:1F69..226C. Called from the main loop at
R:0403:0C42 after a map click on a square that holds a unit of the player (civ = DGROUP:D7F0).

| Item | Contents |
|---|---|
| Entry | pointer hidden (R:01A8:0268); screen saved (R:0866:25B6) |
| Units | the stack ring through unit byte +0Ah, at most 12 units (n) |
| Box | R:1D05:096C(100, 96 − 8n, 120, 16n + 5, colour 3) (SCENES.md 0.2) |
| Row r | y0 = top + 5 + 16r: the unit shape R:1AEA:0FB3(civ, unit, 106, y0); the type name (DGROUP:112A + 22h·type) plus " (V)" (DGROUP:2224) when unit flag 20h is set, at (128, y0) in colour 15; the home city name (R:1459:08C6) at (128, y0 + 8) in colour 14 (R:0182:005C) |
| Keyboard (DGROUP:1A3C = 0) | the row is highlighted by G#3 on (105, top + 4 + 16r, 112, 17), colour 3 → 11; Up (4800h), Down (5000h); Return or Space choose; Escape leaves |
| Mouse | button 1 with x in 101..219; row = abs(mouse y − top − 5) >> 4 |
| Choice | the chosen unit is woken: if its flags have any of C2h set, its moves (unit +4) := 3 × the type's moves (word DGROUP:113A + 22h·type); flags &= 30h; goto byte (unit +6) := FFh. The stack is redrawn when n > 1; the screen is restored and the unit returned |

Windows counterpart: ShowUnitStackDialog 11C0:3023 (dialog 141, opened at 11C0:30BB, called
from MoveCivUnits 11F0:0BFA), DrawUnitStackList 11C0:3407 and RunUnitStackDialogLoop 11C0:3644
(showfunc). They wake the unit by the same rule (flags C2h, moves × 3, flags &= 30h, goto FFh)
and draw the name with " (V)" in colour 15 at (25, y + 1) and the home city in colour 14 at
(25, y + 10), rows 20 apart. The shared constants make the pairing **proved**
(CORRESPONDENCE.md 7).

### 7.20 Tax and luxuries rate menus: R:0403:35CE, R:0403:36B9

Added 2026-10-11 (review R3-25). DOS listing.

| Menu | Reached by | Header | Items | Default | Choice |
|---|---|---|---|---|---|
| Tax rate (R:0403:35CE..36B6) | keys `=` (3Dh) and `+` (2Bh) (R:0403:3ACA..3B0C) | DGROUP:1F9F ("Select new Tax rate:") | for i = 0..DF0E + B210: "10i% Tax, (10(DF0E + B210 − i))% Science)" (DGROUP:1FB6, 1FBF) | DF0E (DGROUP:2F9A) | DF0E := i; B210 += old DF0E − i |
| Luxuries rate (R:0403:36B9..37A3) | keys `-` (2Dh) and `_` (5Fh) (R:0403:3B0F..3B44) | DGROUP:1FCC ("Select new Luxuries rate:") | for i = 0..10 − DF0E: "10i% Luxuries, (10(10 − DF0E − i))% Science)" (DGROUP:1FE8, 1FF6) | 10 − DF0E − B210 | B210 := 10 − DF0E − i |

Both are menu boxes R:0238:001E(text, 100, 80) (y even: framed, SCENES.md 10.1); Escape (−1)
changes nothing; a choice redraws the status panel (R:0238:107E). So DGROUP:DF0E[civ] is the tax
rate, B210[civ] the science rate and the luxury rate is 10 − tax − science, in tenths. Windows
uses the same keys: HandleMenuCommand queues '=' for command 102 and '-' for 103 (DOS-PROFILE.md
1.3).

## Open

1. **DGROUP:B278** (world mode) and **DGROUP:D806** (reveal all, debug screens): no writer found;
   when they are set is unknown.
2. **Minimap rectangle** is 9 rows tall for a 12-row view; the R:0ADE:22B5 call there passes a
   mask (inferred defect). Not observed on the original.
3. **Right mouse button** on the map (R:0403:0850) and the main loop's full key table were not
   traced here. Read since (2026-10-11): the keys `=`, `+`, `-`, `_` open the rate menus (7.20);
   `?` and `/` go to R:0403:3521 (not traced); a map click on the player's unit opens the stack
   popup (7.19); the unit-order switch at R:0403:1AED..1B3B takes its value from the menu bar's
   result DGROUP:D4CA (R:0403:3AA4..3AB4) or from R:1E31:000E for a unit with a stored order
   (R:0403:0D0A..0D32). Its case 67h (`g`, inferred GoTo) runs R:0403:0FFD..10B8 once per dispatch: with the
   mouse (DGROUP:1A3C ≠ 0) R:0000:1697 at R:0403:10AB sets the GO arrow D4CE[2] while a local
   flag is clear and the torch D4CE[7] while it is set, and the xor at R:0403:10B3 toggles the
   flag, so the first `g` gives the arrow and the second the torch. A map click while the flag
   is set stores the square in the unit record bytes DGROUP:81DA/81DB (+ 600h·civ + 0Ch·unit;
   81DC := FFh) when the unit's domain allows it, clears the flag and restores the torch
   (R:0403:09D9..0AEC). Without the mouse the case starts or ends a keyboard square selection
   (R:0403:1007..1088), not a blink. Bytes +6/+7 of the 12-byte record are the offsets of the
   Windows Unit.gotoX/gotoY, so the GoTo reading is inferred from the key and that write; the
   dispatch's callers are not traced (OPEN L5; reviews R2-1 and F2).
4. **Letter marks** on units ("I", "?", "M", "F", "P", "R") and the "F" for flag 4: meanings
   inferred from letters only.
5. **Unit panel "(n)"** for some unit types (table word +4): meaning unknown.
6. **Status panel**: D808 (peace turns) is inferred from the Windows counterpart. The rate
   order (luxury, tax, science) is settled by the DOS rate menus (7.20, DOS listing).
7. **Dissolve order** of R:1AEA:0008 uses the C library rand; whether this disturbs any game
   random sequence must be settled with the RNG notes (no timer dependence, but a shared C rand
   state is possible).
8. **Partly read scenes**: the spaceship arrival O2:0BD7, the conqueror mouth rectangles, the
   replay event table O9:080C, the city screen's food-box height rule, the throne-room animation
   table at segment [640A], and the wonder rectangle table at segment [6444]. The spaceship arrival was read whole
   2026-10-17 (unit D7l2; 7.16). The wonder rectangle table at [6444] is established 2026-10-17 (unit D7e; FORMATS
   6.1, OFFSETS `WONDER_RECTS`) and the throne-room table at [640A] 2026-10-18 (unit D7k; 7.9, FORMATS 6.1, OFFSETS
   `LEADER_*`). The conqueror mouth rectangles are read 2026-10-18 (unit D7n; 7.17): the two mouth pictures drawn at
   the face place O9:1161..11A2 computes from `LEADER_FACE_X`/`_Y` (OPEN L1).
9. **Timing** in frames assumes the frame clock of TIMING.md; no original run was observed.
10. **Fonts** inherited by reports (current font, likely 1) are inferred.
11. **Sound ids** (22h, 2Ah, 2Ch, DGROUP:151A records) are unresolved (sound out of scope).
12. **Advance numbers** used as picture switches (0Dh, 14h, 22h, 23h, 25h, 36h, 3Ah) are not
    mapped to names here.

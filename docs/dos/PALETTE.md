# DOS palettes, fades and cycling (extension D0, prompt 6 item 5, task D0-E1)

Draft of 2026-10-11. This file describes how the DOS release sets the 256-entry VGA palette:
every palette routine (driver and root), the fades, the cycling, which palette is in effect in
each start-up and UI scene, how the 16 interface colours relate to the DAC, and what each `.PAL`
file is for. Scenes are in [SCENES.md](SCENES.md) and [SCENES-PLAY.md](SCENES-PLAY.md).

This file does not repeat: the picture and palette file layout ([FORMATS.md](FORMATS.md) 1),
the driver contracts ([DRIVER.md](DRIVER.md) 4; driver names below are its names), and the
durations of fades and cycling steps ([TIMING.md](TIMING.md) 3.5, 3.6, 5.6). Here they are
given as frames and steps only.

Evidence labels: **DOS file**, **DOS listing**, **inferred**, **unknown**; "PC fact" for general
VGA knowledge. No palette values are reproduced: palettes are compared by counts of equal
entries (scratch `build/dos/scratch-d0e1/palcmp.py`), pictures by the index ranges their pixels
use (scratch `pic.py`, `used.txt`).

## 1. Summary

| Item | Fact | Label |
|---|---|---|
| Palette data | Every picture's `M0` chunk and every `.PAL` file holds a full palette: first index 0, last 255, 6-bit RGB. A `.PAL` file is an `M0` chunk and an empty picture. | DOS file (FORMATS.md 1.2) |
| 6-bit values | No DOS routine scales a palette value; the DAC is linear with full scale 63 (PC fact). The profile's 6-to-8-bit rule (prompt 5.9) is a D1 decision; the facts and the candidate renderings are in FORMATS.md 1.4 (OPEN.md, P group). | DOS listing, PC fact |
| Who writes the DAC | The driver (`LoadPaletteBlock`, `MapLow16Colours`, `SetVideoMode`, all through its retrace-paced writer G:0000:01A1), the root's frame routine (fade batches R:0000:0631, cycling R:0000:044A), one BIOS call (R:1DC4:0698), and the fade measurement R:0000:0573 (rewrites unchanged values). | DOS listing |
| Who reads the DAC | Only the root: the fade snapshot R:0000:0554 and the cycling set-up R:0000:0382 (ports 3C7h/3C9h). The driver listing has no DAC read. | DOS listing |
| Fades | Always all 256 entries, linear with rounding, 6 frames per step, blocking; to black (R:0000:04D4) or to a palette block (R:0000:04AA). VGA path only. | DOS listing |
| Cycling | Eight slots of at most 16 consecutive entries, one step every `rate` frames, run by the frame routine; VGA path only. | DOS listing |
| Interface colours | The game draws its interface with indices 0..15. On the VGA path these are DAC entries 0..15 of whatever palette is loaded, which equal the standard EGA colours in some palettes and not in others (section 6). | DOS listing, DOS file |
| EGA path | No fades and no cycling: every fade call and every slot start found is behind a DGROUP:D762 test. Some set-ups (O2:02F4, R:1DC4:05DD, O18:00E0..0140) run on EGA too; they only read ports. `E0` chunks map pictures for the EGA driver (FORMATS.md 1.5). Out of scope. | DOS listing |

## 2. Routine contracts

### 2.1 Driver functions (summary of DRIVER.md 4)

| Routine | Inputs | Effects and outputs | Failure | Conf. | Label |
|---|---|---|---|---|---|
| `SetVideoMode` G#37, slot R:0000:0872 | flags (bit 7: keep video memory) | Mode 13h; DAC 0..127 := the driver's default table (data:0050, 128 triples). Entries 128..255 keep the BIOS mode-set values. | Mode not set: text mode, message, exit | high | DOS listing; BIOS values unknown |
| `SetDacFromDefault` G#26, R:0000:0825 | (index, entry) | DAC[index] := default entry. No callers. | Entry > 127 reads past the table | high | DOS listing |
| `MapLow16Colours` G#27, R:0000:082C | near pointer to 16 map bytes + border byte | DAC 0..15 := default entries named by the map; overscan := first k whose map byte equals the border byte. One caller: O2:020E with DGROUP:19FE: the identity map except entry 5, which names default entry 0 (black), and border byte 0 (DOS file), so DAC 5 is black, not EGA colour 5, and the border is entry 0. Builds the 16 triples in a scratch area at data:01D0..01FF. | none | high | DOS listing, DOS file |
| `LoadPaletteBlock` G#28, R:0000:0833 | near pointer to a chunk (tag, length, first, last, triples) | If the tag is `M0`: DAC first..last := the triples. Any other tag or a null pointer: nothing. | none | high | DOS listing |
| DAC writer G:0000:01A1 | first, count, triples | Waits for vertical retrace, writes while retrace lasts (counting k), then 13·k more without waiting, then waits again. Interrupts off per entry. | none (no time-out on the retrace wait) | high | DOS file, DOS listing |

The default table (**DOS file**, MGRAPHIC data:0050): entries 0..15 are the 16 standard EGA
colours; 16..31 are greys rising in 7 distinct levels; 32..127 are colours (16 is black). It is
on screen only before the first picture palette is applied (SCENES.md 3, 4.1), while the screen
is black (**DOS listing**).

### 2.2 Applying a picture's palette: R:0000:108E (mode)

Called by the picture loader R:1FA1:01A2 (wrappers in FORMATS.md 1.1).

| Field | Content |
|---|---|
| Inputs | `mode` (the loader's fifth argument): 0, 1, or a DGROUP buffer offset; the open file's word reader. |
| Effects | First `LoadPaletteBlock(0)` (nothing in MGRAPHIC). Then per chunk before the `X` chunk: an `M0` chunk is copied (tag, length, data) to DGROUP:BA08 when `mode` = 0 (kept, not applied), to DGROUP:BA06 and applied with `LoadPaletteBlock(BA06)` when `mode` = 1, or to DGROUP:`mode` (not applied) for any larger value. Any other chunk (`E0`) is copied to DGROUP:BA06 and passed to `LoadPaletteBlock` (ignored by MGRAPHIC). |
| Outputs | DGROUP:68F7 (X1 flag, byte), 68E6 (the `X` chunk's length word, unused), 68E2 width, 68E4 height; the decoder started (which overwrites DGROUP:BA06..D205 whenever width or height is not 0: 2.6). |
| Buffer layout | A stored chunk keeps its 6-byte head, so entry 0's triple is at buffer + 6 (all files have first = 0). R:0000:04AA relies on this. |
| Failure | FORMATS.md 1.6 (no length check on the copy; a missing `X` chunk loops). |
| Confidence, label | High. **DOS listing** (R:0000:108E..119F). |

Consequences: `R:1FA1:0220` and `R:1FA1:026C` change the DAC at once, with no fade; the
retrace-paced writer makes the change appear over about one frame (TIMING.md 3.7). **DOS
listing**, **inferred** (visual).

### 2.3 Fades: R:0000:04AA, R:0000:04D4 and their helpers

| Routine | Inputs | Effects and outputs | Failure | Conf. | Label |
|---|---|---|---|---|---|
| R:0000:04AA (steps, block) | `steps` (low byte used), near pointer to a stored `M0` chunk | Target DGROUP:BA06 := 768 bytes from block + 6 (entries 0..255); snapshot; set-up; busy-waits until DGROUP:0068 = 0. Returns when the fade is complete. | as R:0000:050C | high | DOS listing |
| R:0000:04D4 (steps, r, g, b) | as above, three colour components | Target := 256 copies of (r, g, b); the rest as 04AA. Every call site passes (0, 0, 0). | as R:0000:050C | high | DOS listing |
| R:0000:0554 | none | With interrupts off, waits for vertical retrace, then reads DAC 0..255 into DGROUP:BD06 (the start palette). | no time-out | high | DOS listing |
| R:0000:0573 | none | Measures `M`: entries writable in groups of 10 between the end of one retrace and the start of the next. Each group rewrites DAC 0..9 from the snapshot just taken, so nothing changes on screen. Also sets DGROUP:0060 (CPU flag, below). Called once (DGROUP:0066 caches `M`). | interrupts off; no time-out | high | DOS listing |
| R:0000:050C (AX = steps) | | Frames `F` = 6·steps (DGROUP:0068); batch size `E` = min(256, `M`/14) (DGROUP:0064); start index −`E` (DGROUP:0062); passes `p` = floor(`E`·`F`/256); weight step = 65,536 / (`p` − 1) into DGROUP:006C, and the weight DGROUP:006A starts at one step; prepares the first batch. | divide error or a frozen fade for small `E`·`F` (TIMING.md 3.5) | high | DOS listing; failure inferred |
| R:0000:05B7 | | Prepares the next `E` entries (wrapping at 256) into DGROUP:C006: each component round((start·(65,535 − w) + target·w) / 65,536); after each full pass w += step, saturating at 65,535. | none | high | DOS listing |
| R:0000:0631 (frame routine) | | If DGROUP:0068 ≠ 0: writes the batch to DAC from index DGROUP:0062 (no retrace wait), decrements 0068, prepares the next batch. | none | high | DOS listing |

Notes:

* The frame routine R:0000:0345 runs the fade step before the cycling step, so a cycling slot
  that is running during a fade overwrites the faded values of its range each time it steps
  (**inferred**; the program stops the Birth slots before its fades, O7:1A06, and the map slots
  before R:0238:1B66).
* DGROUP:0060 = (FFFFh shifted right by 32): 0 on an 8086/8088, FFFFh on later CPUs where the
  shift count is masked (PC fact). It selects `rep outsb` or a byte loop in R:0000:0631; the
  cycling data word R:25CF:0000 is set the same way (R:0000:038D). **DOS listing**
* DGROUP:BA06 is also the program's text buffer: a fade overwrites the current text
  (TIMING.md 3.5; SCENES.md 8.3). **DOS listing**

### 2.4 Cycling: R:0000:0382, R:0000:03FA, R:0000:042B, R:0000:044A

Data: segment R:25CF: word 0000 (CPU flag), eight record pointers at 0002 (end FFFFh), eight
102-byte records at 0014 + 66h·i, all zero in the file (**DOS file**). Record layout:
TIMING.md 3.6.

| Routine | Inputs | Effects and outputs | Failure | Conf. | Label |
|---|---|---|---|---|---|
| R:0000:0382 (slot, rate, lo, hi) | slot 1..8; `rate` (low byte stored); DAC range lo..hi | count = min(hi − lo + 1, 16); reads the count entries from DAC lo **at this moment** into the record (interrupts off), then appends a copy of them minus the last entry; stores lo and rate; stops the slot; position 0. | slot outside 1..8 or hi ≤ lo: nothing; ranges longer than 16 are cut | high | DOS listing |
| R:0000:03FA (s) | signed slot | slot \|s\|: step +3 for s > 0, −3 for s < 0; countdown := rate (starts it; rate 0 never runs). | slot outside 1..8: nothing | high | DOS listing |
| R:0000:042B (slot) | slot | countdown := 0. The DAC keeps the rotated colours (no restore). | as above | high | DOS listing |
| R:0000:044A (frame routine) | | For each running slot whose countdown reaches 0: reload, move the position by the step (wrapping in 3·count), write the count entries from the doubled copy to DAC lo.. | none | high | DOS listing |
| R:1DC4:05DD | none | Map cycling set-up: slot 1 = 96..103, slot 2 = 104..111, slot 3 = 112..127, rate 15 each, colours read from the DAC at the call. Call sites: R:01A8:086F (just after the play palette is set, 5), O2:1520, O18:024B. | | high | DOS listing |
| R:1DC4:0626 / R:1DC4:065F | none | VGA only: start slots 1..3 (+) / stop them; DGROUP:2FEC tracks the state, so repeated calls do nothing. | | high | DOS listing |

Direction: with a positive slot each entry takes its lower neighbour's colour every step, so the
colours move towards higher indices (**DOS listing**: R:0000:0471..0484 subtracts the step from
the position, wrapping in 3·count, and R:0000:0487..04A1 writes the count entries from the
doubled copy at that position to DAC lo..; as TIMING.md 3.6). Because the colours are captured at set-up, a slot set up under one palette and started
under another writes the old colours (**inferred**; no such case found in the start-up scenes).

### 2.5 Other palette writers

| Routine | Inputs | Effects | Failure | Conf. | Label |
|---|---|---|---|---|---|
| R:1DC4:047D (name) | a `.PAL` file name | VGA only: the file's chunk into DGROUP:BDEE; entries 0..15 of it replaced by the 48 bytes at DGROUP:6B34 (the saved interface colours, 2.6); `LoadPaletteBlock(BDEE)`; then entry 45 set by R:1DC4:0698 to a fixed colour. Callers, each with a constant name: O8:076C `iconpg1.pal` (DGROUP:3CE6, for all eight `ICONPG1..8.PIC`), O8:0934 `hill.pal` (DGROUP:3D14), O8:0A20 `iconpga.pal` (DGROUP:3D4E, for all five `ICONPGA..E.PIC`), O16:0104 `iconpg1.pal` (DGROUP:4A36). No code writes these strings. | file errors: FORMATS.md 1.6 | high | DOS listing |
| O8:0AF0..0B1D (civilopedia terrain page) | | VGA only: `sp256.pal` into DGROUP:C5BE (O8:0AFF) and applied with `LoadPaletteBlock(C5BE)` (O8:0B0B), with no 6B34 or entry-45 step; then DAC 253 set to a fixed grey (equal components) by R:1DC4:0698 (O8:0B13..0B1D). So `ICONPGT1..2.PIC` are shown with `SP256.PAL`'s colours, which differ from their own palettes in entries 17..31, 96..97, 109..110 and 224..255; their pixels use 19..21, 96..97, 109 and 253 (T1) and 18..23, 25..26 and 253 (T2) of those (DOS file). | | high | DOS listing, DOS file |
| O8:0687..0696 (civilopedia, before any picture) | | When pictures are shown (DGROUP:3C62 = 0), VGA: background colour 0FDh and DAC 253 set to the same fixed grey. The advance, improvement and unit pages then apply a whole `.PAL` through R:1DC4:047D, which replaces DAC 253 with the file's entry 253 (different from that grey in `ICONPG1.PAL`, `ICONPGA.PAL` and `HILL.PAL`, DOS file); the terrain page sets the grey again (row above). | | high | DOS listing, DOS file |
| R:1DC4:0698 (index, r, g, b) | | VGA only: INT 10h AX=1010h (through R:2045:20C4), one DAC register. Call sites: R:1DC4:04D2, O8:0696, O8:0B1D, O19:1698. | none | high | DOS listing; BIOS function PC fact |
| O5:16CA..16F3 | | `sp256.pal` into DGROUP:BDEE (not applied); its entries 0..15 copied to DGROUP:6B34. | | high | DOS listing |
| R:0238:1BEB | | VGA only (play screen): stops map cycling; `back<n><a/m>.pal` (name from the player's state) into DGROUP:C1D6 and `sp256.pal` into DGROUP:C5BE; entries 128..255 of the first copied into the second; fade to it in 5 steps; map cycling started. | | high | DOS listing; name rule SCENES-PLAY.md |
| R:0238:1B44 | | Play screen: map cycling stopped, VGA fade to black in 5 steps, redraw, then R:0238:1BEB. | | high | DOS listing |
| R:0ADE:1584 (part) | | A discovery scene: a `discovr` palette into DGROUP:C1D6, `iconpg1.pal` into C5BE, the first 85 entries of the former copied over the latter, fade in 30 steps. | | medium | DOS listing; scene SCENES-PLAY.md |

### 2.6 Palette buffers (DGROUP)

| Offset | Size | Use | Label |
|---|---|---|---|
| BA06 | 768 (+ head) | fade target; chunk scratch of R:0000:108E (`mode` 1); also the common text buffer | DOS listing |
| BD06 | 768 | fade start snapshot (R:0000:0554) | DOS listing |
| C006 | up to 768 | fade batch (R:0000:05B7) | DOS listing |
| BDEE | 774 | chunk buffer: `sp256.pal` (O5:16D2), R:1DC4:047D, `back<d><a/m>.pal` (O6:22C2), `slam1.pal` (O9:1220), `hill.pal` (O19:0EA9) | DOS listing |
| C1D6 | 774 | chunk buffer: `BACK*.PAL` (R:0238:1C52, O18:01F8), `king<NN>.pal` (O6:22B2, O9:1210), discovery palette (R:0ADE:1958) | DOS listing |
| C5BE | 774 | fade target chunk: `BIRTHn.PAL` (O7:1A83), `sp256.pal` (R:0238:1C62, O18:0208, O8:0AFF), `iconpg1.pal` (R:0ADE:1968) | DOS listing |
| 6B34 | 48 | entries 0..15 of `SP256.PAL`: the interface colours restored by R:1DC4:047D | DOS listing |
| 0060..006C | words | fade state: CPU flag, batch start, `E`, `M`, frames left, weight, weight step | DOS listing |
| R:2710:0000 | 131 bytes | Birth cycling table: 41 (lo, hi, speed) triples in 8 zero-terminated groups, one per picture (3, 7, 5, 8, 5, 4, 4, 5 triples) | DOS file, DOS listing |

**The decoder shares this region.** The LZW dictionary is DGROUP:BA06..D205 (2048 three-byte
entries, R:0000:1282..1291; FORMATS.md 1.3 item 4). It contains every buffer above except 6B34:
BA06, BD06, C006, BDEE, C1D6 and C5BE (DOS listing, offsets). Every decode of a `*.PIC` resets
the dictionary and so overwrites them, including a palette-only load of a picture
(R:1FA1:026C, or R:1FA1:0288 with a picture name), because R:0000:108E starts the decoder
(R:0000:119F) before R:1FA1:01D3 zeroes the height; a `*.PAL` load does not (R:0000:1227 returns
at 1230 for width = height = 0). The O8 civilopedia even builds its picture name in BA06
(O8:073F). Every order checked loads its `.PAL` files after the last picture decode and fades
or applies before the next: O6:22B2..230A, O7 Birth (O7:1A83..1A93), O8 (pictures at O8:0760,
0A14, 0AE8 before the palettes), O9:1210..124C, O19:0EA9..0EB9, R:0238:1BEB, R:0ADE:1958..198C
(DOS listing). Constraint for the profile: a stored palette in one of these buffers does not
survive a picture decode, so a port that shares buffers must keep this order.

## 3. Fades

All fades write all 256 entries, 6 frames per step (frame routine R:0000:0345), and block the
caller until done. None is skippable. Frames and seconds: TIMING.md 3.5 and 5.8.

| Call site | Routine (steps) | Target | Scene | Scope |
|---|---|---|---|---|
| R:01A8:05B6 | 04D4 (5) | black | Customize World, before `CUSTOM.PIC` | this file |
| R:01A8:0840 | 04D4 (5) | black | after Birth (choices 0, 2, 3), before the setup screens | this file |
| O7:1A39 | 04D4 (8) | black | Birth, before each picture | this file |
| O7:1A93 | 04AA (8) | `BIRTHn.PAL` (C5BE) | Birth, after each picture | this file |
| R:0238:1B66 | 04D4 (5) | black | play screen return (R:0238:1B44) | SCENES-PLAY.md |
| R:0238:1C86 | 04AA (5) | `SP256.PAL` 0..127 + `BACK*.PAL` 128..255 | play screen | SCENES-PLAY.md |
| R:0ADE:198C | 04AA (30) | discovery + `ICONPG1.PAL` | play event | SCENES-PLAY.md |
| O2:122B | 04D4 (5) | black | O2:0BD7 sequence, called from the game loop (TIMING.md 5.7) | SCENES-PLAY.md |
| O9:1079 | 04D4 (5) | black | O9 | SCENES-PLAY.md |
| O9:124C | 04AA (8) | `SLAM1.PAL` (BDEE) with entries 64..143 from `king<NN>.pal` (C1D6; bytes C0h..1AFh of the triples copied at O9:1228..1242) | O9 | SCENES-PLAY.md |
| O17:0CB9 | 04D4 (5) | black | O17 | SCENES-PLAY.md |
| O19:0EB9 | 04AA (15) | `HILL.PAL` (BDEE) | O19 | SCENES-PLAY.md |
| O22:10FC | 04D4 (10) | black | O22 | SCENES-PLAY.md |

**DOS listing** (call arguments read at each site).

The intro, the logo and the title use no fade at all; their transitions are cuts, a strip reveal
and `DissolveToScreen` (a pixel dissolve, not a palette effect; SCENES.md 5). A palette applied
by a picture load is a cut (2.2). **DOS listing**

## 4. Cycling

Set-ups in the start-up scenes (all set-ups of the program: TIMING.md 5.6):

| Where | Slot: DAC range | Rate (period source) | Direction | Started / stopped | Picture using the range | Label |
|---|---|---|---|---|---|---|
| Intro O2:02F4 | 1: 146..152 (7 entries) | 14, constant at the call | + | O2:030B (slots 1..3, VGA; 2 and 3 stay idle with rate 0) / O2:0B40 (slots 1..4, VGA) | `BIRTH1.PIC` (its pixels include the run 102..159); `BIRTH0.PIC`'s pixels use none of 146..152 | DOS listing, DOS file |
| Logo O2:0AA0 | 4: 224..239 (16) | 14, constant | + | O2:0AAC / O2:0B40 | `LOGO.PIC` (its pixels include the run 223..239) | DOS listing, DOS file |
| Birth O7:1AF0 | 1..k: the next group of the table R:2710:0000 (k = 3..8), read in order through the running offset DGROUP:3B66 | floor(300 / speed) from the table, low byte stored; one triple has speed 1, so its 300 is stored as 44 | + | O7:1B16 / O7:1A06 (before the next picture), O7:1BA5 (end) | `BIRTHn.PIC` | DOS listing, DOS file |
| Map R:1DC4:05DD | 1: 96..103, 2: 104..111, 3: 112..127 | 15, constant | + | R:1DC4:0626 / R:1DC4:065F | play map sprites (SCENES-PLAY.md) | DOS listing |

Of these, only the Birth ranges and speeds are a data table at an image offset (R:2710:0000).
The intro, logo and map slots, ranges and rates are immediates inside the set-up code (O2:02F4,
O2:0AA0, R:1DC4:05DD); FORMATS.md 6 lists each with its instruction range (review finding R2-7).

The stopped intro and logo ranges are not restored: the title menu, the Hall of Fame and the
load screens show `LOGO.PIC`'s palette with entries 146..152 and 224..239 in their last rotated
state (**DOS listing**: no palette write between O2:0B40 and the next picture load).

Birth table quirks (**DOS file**, **DOS listing**): the Birth set-up runs after the fade-in
(O7:1A93), so each slot captures the picture's own colours. One range of the second group spans
23 entries; R:0000:0382 cuts it to its first 16, so the other 7 do not cycle. A group ends at a
zero `lo` byte (O7:1B00).

Windows rotates only god entries 64..71 on the map window with a 200 ms timer; its intro and
Birth have no cycling (the movie cycle item is never used; WINDOWS-INVENTORY.md 9.1, 9.3). **Windows docs**

## 5. Palette and colour base per scene

M0 first/last is 0/255 in every file (**DOS file**), so a picture always replaces the whole
palette. "Picture indices" are the ranges the picture's pixels use (**DOS file**, scratch
decode); "UI indices" are the colours the scene's code draws with (**DOS listing**).

| Scene (SCENES.md) | Palette in effect and how it is set | Picture indices | UI / text indices | Cycled | Label |
|---|---|---|---|---|---|
| After the mode set (3) | default table 0..127, BIOS 128..255; then `MapLow16Colours` (0..15 = EGA except 5, which is black: 2.1) | none (screen black) | none | none | DOS listing, DOS file |
| Intro and credits (4) | `LOGO.PIC` (O2:02BE, a cut while the screen is black). The intermediate loads of `logo.pic`, `birth0.pic`, `birth1.pic` with palette are invisible. | `BIRTH0`: 0 and 28..223; `BIRTH1`: 0..223 | VGA 248, 250, 252 (credits); EGA 7, 15 | 146..152 | DOS listing, DOS file |
| Logo (5) | `LOGO.PIC` | `LOGO`: 0, 51, 87..239 | none | 224..239 | DOS listing, DOS file |
| Title menu (6), Hall of Fame (7.5), Load (7.2) | `LOGO.PIC`, rotated ranges frozen (on the title branch only; after a game the Hall of Fame, O3:0513 from R:0238:08A0, loads no palette, so the end scenes' palette stays: inferred, OPEN.md L26, review R3-15) | logo over black | menu box 0, 3, 7, 8, 11, 15 (SCENES.md 10.1); Hall of Fame adds 12, 14; Load adds 12 | none | DOS listing |
| Customize World (7.4) | fade to black, then `CUSTOM.PIC` (a cut); the help screen over it keeps the palette | `CUSTOM`: 3..253 (sparse) | menu box colours; help screen 0, 2, 15 | none | DOS listing, DOS file |
| Play on EARTH (7.3) | `MAP.PIC`'s palette applied at O7:0049 while the title screen is visible | `MAP`: within 0..15, drawn into page 1, not shown | none | none | DOS listing |
| Birth (8) | VGA: per picture, fade to black, then fade to `BIRTHn.PAL` (equal to `BIRTHn.PIC`'s palette); EGA: no palette change | `BIRTHn`: up to 0..254 | 3, 11 (text), 15 (building message) | per picture | DOS listing, DOS file |
| After Birth (8.5) | fade to black (R:01A8:0840); `SP257.PIC`'s palette applied (R:01A8:0867; equal to `SP256.PAL`); map cycling set up from it (R:01A8:086F), not started | none (screen black) | none | prepared | DOS listing, DOS file |
| Setup (9) | `DIFFS.PIC` with its palette (R:01A8:08A8, a cut while black) | `DIFFS`: 0..254 (sparse); portraits | menu box colours, 0, 11, 15; border tiles 2, 4, 5, 7, 12, 14, 15 | none (the map slots stay stopped) | DOS listing, DOS file |
| Play screen | `SP256.PAL` 0..127 + `BACK*.PAL` 128..255, faded in (R:0238:1BEB) | sprite sheets within 0..111 (and 255) | `SP256` 0..15 | 96..127 | DOS listing; SCENES-PLAY.md |

Remarks (all **DOS file** comparisons, scratch `palcmp.py`):

* `LOGO.PIC`'s palette equals `BIRTH0.PIC`'s and `BIRTH1.PIC`'s (which are identical) except
  entries 5, 7, 8, 11, 15 and 224..254. `BIRTH0` uses none of these; `BIRTH1` uses entry 8, so
  its index-8 pixels show the logo palette's colour 8 in the intro. The credit colours 248..252
  exist only in the logo palette's version.
* `SP257.PIC`, `SP257.PAL` and `SP256.PAL` are equal. `SP299.PIC` differs from them only in
  96..97, 109..110, 112..113 and 224..254; `TER257.PIC` only in 17..31, 96..97, 109..110 and
  224..254. The differences in 96..113 all lie in the map cycling ranges (**inferred**: other
  phases of the cycled colours). `SP299`'s pixels use 109..110 and `TER257`'s use some of
  17..31; drawn under the play palette they show `SP256`'s colours there, not the sheet's own.
* `DIFFS.PIC` and `CUSTOM.PIC` differ only in entries 5 and 48..79.
* The ornamental border of the introduction text (SCENES.md 9.6) is cut from `SP299.PIC` but
  drawn under `DIFFS.PIC`'s palette; it uses only indices 2, 4, 5, 7, 12, 14, 15, so it shows
  the low 16 of `DIFFS` (EGA colours except entry 5), not the game palette's (1 of 7 equal).
* The menu texture tile (SCENES.md 0.2, 10.1) uses indices 7 and 22 only.
* The pointer `TORCH.PIC` (indices 4, 5, 7, 12, 14, 15) is drawn with the current palette
  (FORMATS.md 4), so its colours change with the scene.

## 6. EGA colours 0..15 and DAC 0..15

The interface code (menus, boxes, text, the pointer) uses indices 0..15 on both drivers. On the
VGA driver index n is DAC entry n of the palette in effect; it shows standard EGA colour n only
where that palette's entry n equals it. Entries of each palette compared with the 16 standard
EGA colours of the driver's default table (**DOS file**):

| Palettes | Entries 0..15 that differ from EGA | Scenes |
|---|---|---|
| `BIRTH0..8` (`.PIC` and `.PAL`), `CUSTOM`, `MAP`, `CASTLE0..4`, `CBACKS1..3`, `CBRUSH0..5`, `DISCOVR1` (`.PIC`, `.PAL`), `PLANET1..2`, `SPACEST`, `ADSCREEN` | none | intro pictures' own palettes, Birth, Customize, EARTH |
| `DIFFS`, `CBACK` | 5 | setup |
| `DISCOVR2`, `SLAM1` (`.PIC`, `.PAL`), `SAD`, `SLAM2` | 15 | play |
| `LOGO` | 5, 7, 8, 11, 15 | intro, logo, title menu, Hall of Fame, load |
| `DOCKER` | 0, 5, 11 | play |
| `HILL` (`.PIC`, `.PAL`) | 5..11, 14 | play |
| `SP256.PAL`, `SP257` (`.PIC`, `.PAL`), `SP299`, `TER257`, `ICONPGT1..2` | all but 0, 3, 13 | play screen and every scene that keeps the play palette |
| `NUKE1` | all but 0, 3, 13, 15 | play |
| `ICONPG1..8`, `ICONPGA..E` (and `ICONPG1.PAL`, `ICONPGA.PAL`), `CITYPIX2`, `POP` | all but 0 and 13 | play; the civilopedia never applies these pictures' own palettes: R:1DC4:047D applies `ICONPG1.PAL` or `ICONPGA.PAL` (or `HILL.PAL`) with 0..15 replaced by `SP256`'s (2.5) |
| `CITYPIX1`, `CITYPIX3`, `INVADER2..3`, `INVADERS`, `LOVE1..2`, `RIOT`, `RIOT2`, `SETTLERS`, `WONDERS`, `WONDERS2` | all but 13 | play |
| `KINK00`, `KINK03`, `SLAG2` | all but 15 | play |
| `KING00..03`, `KING05` (`.PIC`, `.PAL`), `ARCH`, `GOVT1A`, `GOVT1M`, `GOVT3A`, `BACK0A`, `BACK0M`, `BACK2A`, `BACK2M`, `BACK3A` (`.PIC`) | all but 0 | play |
| `KING04`, `KING06..13` (`.PIC`, `.PAL`), `GOVT0A`, `GOVT0M`, `GOVT2A`, `GOVT2M` | all 16 | play |
| `BACK0A`, `BACK1A`, `BACK1M`, `BACK2A`, `BACK2M`, `BACK3A` (`.PAL`), `BACK1A`, `BACK1M` (`.PIC`) | 3, 5..15 | play; `BACK*.PAL` supply only entries 128..255 (2.5), so their low entries are never shown |
| `BACK0M.PAL` | 2, 3, 5..15 | as above |
| `TORCH` | 0, 5 | the pointer's own palette, never applied |
| `SPRITES` | no palette chunk | – |

So in the VGA profile the "same" interface colour differs between scenes: grey 7, for example,
is the EGA grey in Birth and Customize, the logo palette's entry 7 on the title menu, and
`SP256`'s entry 7 in play. A port must take interface colours from the scene's palette, not from
a fixed EGA table (**inferred** from the above).

Windows places the game palette above the system's low entries (god entry n is system entry
n + 10, WINDOWS-INVENTORY.md 9.1) and its dialogs use Windows' own colours (PC fact). DOS has
no reserved entries: an interface colour is whatever the scene's palette holds at 0..15.
**Windows docs**, **DOS listing**

## 7. The `.PAL` files

38 files (FORMATS.md 1.2). Each equals the palette of the same-named picture except five
`BACK` files. `BACK0A`, `BACK0M`, `BACK2A`, `BACK2M` and `BACK3A` differ from their pictures in
some of entries 1..23 and in entry 45. Some also differ in the upper half that the game uses:
`BACK0M` in 194..207, `BACK2A` in 161..162 and 208..211, `BACK2M` in 144..153, 176..177, 210..211
and 213..223. `BACK1A.PAL` and `BACK1M.PAL` equal their pictures. **DOS file**. Wherever a
`BACK` picture is shown under the palette built by R:0238:1BEB, its upper entries take the
`.PAL` values (**inferred**; where the pictures are drawn: SCENES-PLAY.md).

| Files | Reader (address) | Use | Scope | Label |
|---|---|---|---|---|
| `BIRTH1..8.PAL` | O7:1A83 → C5BE, faded in by O7:1A93 | Birth picture palettes (VGA) | this file | DOS listing |
| `BIRTH0.PAL` | none found (the Birth digit starts at 1; the intro uses `logo.pic`'s palette) | unused | – | DOS listing |
| `SP256.PAL` | O5:16D2 → BDEE; O8:0AFF → C5BE, applied with `LoadPaletteBlock` at O8:0B0B (civilopedia terrain page, `ICONPGT1..2`, 2.5); O18:0208 → C5BE; R:0238:1C62 → C5BE | play palette (entries 0..127), the saved interface colours (2.6), the terrain page | SCENES-PLAY.md | DOS listing |
| `SP257.PAL` | none found (`sp257.pic`'s palette is used instead, R:01A8:0867) | unused | – | DOS listing |
| `BACK0A..3A.PAL` (7) | R:0238:1C52 → C1D6 (name built from DGROUP:1E4B); O18:01F8 → C1D6 (name from DGROUP:4CDF, O18:01B4); O6:22C2 → BDEE (the `back` picture name with "pal" copied over its extension, O6:2279) | entries 128..255 of the play palette; with O6, the leader-screen palette (`KING` row) | SCENES-PLAY.md | DOS listing |
| `ICONPG1.PAL`, `ICONPGA.PAL`, `HILL.PAL` | R:1DC4:047D from O8:076C (`iconpg1`), O8:0934 (`hill`), O8:0A20 (`iconpga`), O16:0104 (`iconpg1`); O19:0EA5 (`hill`); R:0ADE:1964 (`iconpg1`) | civilopedia, quiz, discovery and report screens. Only these two `ICONPG*.PAL` files exist: `ICONPG2..8.PIC` are shown with `ICONPG1.PAL` (their own palettes equal it) and `ICONPGB..E.PIC` with `ICONPGA.PAL` (equal likewise); `ICONPGT1..2.PIC`, which have no `.PAL`, are shown with `SP256.PAL` (2.5) | SCENES-PLAY.md | DOS listing, DOS file |
| `KING00..13.PAL` | O6:22B2 → C1D6 (name `king00.pal` with its digits patched, O6:2285..22A7): entries 64..143 copied over the `BACK*.PAL` palette in BDEE (O6:22CA..22E4) and applied with `LoadPaletteBlock` (O6:230A); O9:1210 → C1D6 (the `king<NN>.pic` name with "pal" copied over its extension, O9:11F8..1200): entries 64..143 copied over `SLAM1.PAL` (O9:1228..1242), faded in at O9:124C | leader screens; the O9 scene | SCENES-PLAY.md | DOS listing |
| `DISCOVR1..2.PAL` | R:0ADE:1940..1958 (name built with ".pal") | discovery scene | SCENES-PLAY.md | DOS listing |
| `SLAM1.PAL` | O9:1220 → BDEE, with `KING` entries 64..143 spliced in, faded in at O9:124C | O9 scene | SCENES-PLAY.md | DOS listing |

## 8. Differences from Windows (palette)

| Item | Windows | DOS | Label |
|---|---|---|---|
| Intro | movie fades of 3, 20 and 40 steps on entries 0..159 or 0..235, Blackout, LoadClut and SwapAndShow items (WINDOWS-INVENTORY.md 6.1) | no fade; the logo palette from the start; cycling of 146..152 and 224..239 | DOS listing, Windows docs |
| Birth | movie FadeOut/FadeIn of 40 steps over 100 movie frames each, entries 0..223 (WINDOWS-INVENTORY.md 6.2) | 8-step fades (48 frames) through black on all 256 entries; per-picture cycling | DOS listing, Windows docs |
| Interface colours | game palette offset by 10 system entries; dialogs in Windows colours | entries 0..15 of each scene's palette | DOS listing, Windows docs, PC fact |
| Timed effects | one 200 ms map cycle of god entries 64..71 (WINDOWS-INVENTORY.md 9.1) | frame-paced fades and up to 8 cycling slots | DOS listing, Windows docs |

## Open

1. **Fade batch size.** `E` depends on a hardware measurement (R:0000:0573); the look of a fade
   (how many entries change per frame) is machine dependent; the total time is not
   (TIMING.md 3.5).
2. **Entry 45.** Why R:1DC4:047D forces entry 45 after loading `iconpg1`, `hill` or `iconpga`,
   and why five `BACK*.PAL` files differ from their pictures in low entries, entry 45 and some
   upper entries, is unknown.
3. **BIOS palette 128..255** after `SetVideoMode`: values not in the DOS files (BIOS); never
   visible in the reached code (the screen is black until a picture palette is applied).
4. **Cycling during fades.** The order fade-then-cycle in R:0000:0345 lets a running slot
   override faded entries; no start-up case runs both, but play scenes were not checked.
5. **EGA path.** How EGRAPHIC turns `E0` chunks into colours, and what Birth looks like without
   palette changes, is out of scope.
6. **`DissolveToScreen` timing** is calibrated per machine (DRIVER.md Open 6).
7. **Placeholder entries.** `KING*`/`ICONPG*` low entries look like placeholders; whether any
   scene shows them unreplaced (for example `KING*.PAL` through O6) is for SCENES-PLAY.md.
8. **First-entry assumption.** R:0000:04AA takes the block's triples from offset 6 as entries
   0..255 without reading first/last; it relies on every file having first 0 and last 255.
9. **Cut Birth range.** One range of the second Birth group spans 23 entries and only 16 cycle
   (section 4); it belongs to the second picture shown. Whether this cut is intended, and how
   much of that picture it affects, is not checked.
10. **Intro picture colours.** `BIRTH1.PIC`'s index-8 pixels show the logo palette's entry 8
   during the intro, not the picture's own (section 5). Whether this is visible depends on where
   those pixels fall in the panorama rows used (SCENES.md 4.2); not checked.
11. **Sheet colours in play.** `SP299`/`TER257` pixels at indices where their palettes differ from
   `SP256` (section 5) show `SP256`'s colours; any visible effect belongs to SCENES-PLAY.md.

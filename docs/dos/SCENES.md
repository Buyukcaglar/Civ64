# DOS start-up and UI scenes (extension D0, prompt 6 item 5, task D0-E1)

Draft of 2026-10-11. This file describes every scene from program start to the first play
screen, the first screen of each title branch, and the generic interface elements (menu boxes,
popups, text entry) of the DOS release. It is part 1 of the prompt's `SCENES.md` (6 item 5);
part 2, the play screen and every full-screen scene reached during play, is
[SCENES-PLAY.md](SCENES-PLAY.md). Palettes, fades and cycling are in [PALETTE.md](PALETTE.md).
Independent review R3 (`docs/verify/ext-d0-review-r3.md`) and the R1/R2 items in its scope
were applied on 2026-10-11 by fixer F3 (`docs/verify/ext-d0-fixes-r3.md`).

Other D0 files this one relies on and does not repeat:
[EXECUTABLE.md](EXECUTABLE.md) (address notation), [DRIVER.md](DRIVER.md) (driver function names
and contracts; names such as `CopyRect` below are its names), [TIMING.md](TIMING.md) (every
duration in seconds, the sound tick, the intro cue table), [FORMATS.md](FORMATS.md) (picture,
font and text formats, the picture loaders, the mouse pointer), [SPRITES.md](SPRITES.md) (the
shapes cut by O5:1455), [WINDOWS-INVENTORY.md](WINDOWS-INVENTORY.md) (the Windows movies,
dialogs and palette effects).

Evidence labels: **DOS file** (read from the files in `build/dosdata/`), **DOS listing** (the
listings in `build/dos/disasm/`, plus my own reading of call arguments), **inferred**,
**unknown**. "PC fact" marks general platform knowledge. Windows facts cite the port's Windows
documents. No DOS bytes are reproduced: strings are named by their DGROUP offset and at most a
few words, tables by their address and size.

Scratch (analysis only): `build/dos/scratch-d0e1/` (`callargs.py` rebuilds call argument lists
from the listings; `pic.py` decodes pictures for index counts; `palcmp.py` compares palettes
without printing them; `dg.py` reads DGROUP).

## 0. Conventions and shared machinery

### 0.1 Screen, pages and the drawing port

| Item | Fact | Label |
|---|---|---|
| Screen | 320 × 200, one byte per pixel (mode 13h on the VGA driver). Coordinates below are (x, y) of the top-left pixel; a rectangle is (x, y, w, h). | DOS listing (DRIVER.md 3.1) |
| Pages | Page 0 is the screen; pages 1..3 are 64,000-byte off-screen buffers of the same layout. | DOS listing (DRIVER.md 3.1) |
| Ports | DGROUP:[00AA] points to the current drawing port (DGROUP:0098, the screen port); DGROUP:[19D4], [19E8], [19FC] point to the ports of pages 1, 2, 3 (DGROUP:19C2, 19D6, 19EA). Port fields: DRIVER.md 3.2 (+00h page, +0Ah text style, +0Ch text colour, +0Eh text background, +10h font). | DOS listing |
| Fonts | "Font n" = `FONTS.CV` font n (1-based), set in port word +10h. Heights: font 1 = 7, font 2 = 5, font 5 = 16, font 7 = 8 (plus one empty row each). | DOS file, DOS listing (FORMATS.md 2.2) |
| Colours | A colour is a DAC index; what it looks like depends on the palette in effect, which PALETTE.md section 5 gives per scene. Inside a string, a byte of 80h or above switches the text colour to (byte AND 7Fh) for the rest of the string. | DOS listing (DRIVER.md G#21) |
| Profile paths | DGROUP:D762 ≠ 0 means the 256-colour driver (MGRAPHIC, "VGA" below). Fades and palette cycling run only on that path; the EGA/Tandy branches are noted where they differ. | DOS listing |

### 0.2 Drawing helpers used by the scenes

| Routine | Arguments | Effect | Label |
|---|---|---|---|
| R:0000:0BFA | (port, x, y, w, h, colour) | Solid rectangle. | DOS listing |
| R:0182:0148 | (x1, y1, x2, y2, colour) | Solid rectangle by corners on the current port. | DOS listing |
| R:0182:000A | (x1, y1, x2, y2, colour) | Line (through R:0000:100A). | DOS listing |
| R:0182:002A | (text, x, y, colour) | `DrawText` (G#21) on the current port with its style. | DOS listing |
| R:0182:005C | (text, x, y, colour) | Text with a transparent background (port +0Ah := 0 around the call). | DOS listing |
| R:0182:0086 | (text, x, y, colour) | Text with a colour-0 copy one pixel lower first (drop shadow). | DOS listing |
| R:0182:00B3 | (text, cx, y, colour) | Text centred on x = cx, transparent. | DOS listing |
| R:0182:00EF | (text) | Width in pixels with the current font (`CharWidth`, G#4). | DOS listing |
| R:1F4D:0088 | (columns, x, y, colour) | Draws the text in DGROUP:BA06 with R:0182:005C, one line per font line height (`FontLineHeight`, G#12), breaking at a newline, at `^`, or at the last space before columns × 8 pixels; stops below y = 192. Returns the next y. | DOS listing |
| R:1D05:0A05 | (x, y, w, h, colour) | Rectangle outline (x, y)–(x+w, y+h). | DOS listing |
| R:1D05:0A66 | (x, y, w, h, c1, c2) | Bevel: top edge and right edge in c2, bottom edge and left edge in c1. | DOS listing |
| R:1D05:096C | (x, y, w, h, colour) | Box: fill (x+1, y+1)–(x+w, y+h) in colour (when colour is 7 and DGROUP:2F98 ≠ 0, the texture R:1DC4:03CE instead); bevel R:1D05:0A66(x+1, y+1, w, h, 15, 8); black outline R:1D05:0A05(x, y, w+2, h+2, 0). | DOS listing |
| R:1DC4:03CE | (x, y, w, h) | VGA: fills the rectangle with copies of the 32 × 16 tile at page 2 (288, 120) (`CopyRect`); EGA: solid colour 7. | DOS listing |
| R:0866:25B6 / R:0866:25D7 | () | Save the screen into page 1 / restore it from page 1 (full-screen `CopyRect`). | DOS listing |
| R:0866:260E | () | Draws an ornamental 8-pixel border round the screen from 8 × 8 tiles of page 2 at y = 120, x = 192 or 224 (chosen by R:1DC4:005D(2)) and the next tiles to the right. | DOS listing; tile meaning inferred |
| R:0199:00A1 | (row, column, text) | Text mode only: BIOS character output at (row, column); a byte FFh followed by a byte sets the attribute. | DOS listing; BIOS functions PC fact |

Picture loading (FORMATS.md 1.1): R:1FA1:0220(page, name) picture and palette, R:1FA1:0254(page,
name) picture only, R:1FA1:026C(name) palette only, R:1FA1:0288(name, buffer) palette into a
buffer. A palette applied by a load is set at once, without a fade (**DOS listing**).

### 0.3 Waits, input and the pointer

| Routine | Role | Label |
|---|---|---|
| R:0182:0134(n) | `wait(n)`: n frames of the timer's frame counter. Durations: TIMING.md 3.3. | DOS listing |
| S#5 (R:0000:0A4E) | Sound tick; the intro, title menu and Birth schedule against it (TIMING.md 3.4). | DOS listing |
| R:2045:2098 / R:2045:20AC | `kbhit` (does not consume) / `getch` (INT 21h AH=08h). | DOS listing; names PC fact |
| R:1D05:0AC9 | Reads one key through `ReadKey` (M#1), translating the keypad; returns the character or, for extended keys, the BIOS key word. | DOS listing |
| R:0403:4545 | Flushes pending keys and waits until no mouse button is down. | DOS listing |
| R:01A8:0223 | Polls the mouse: buttons DGROUP:DB3A (1 left, 2 right), x DB3C, y DB3E. | DOS listing |
| R:1459:0918 | "Wait for a key or a click": flush, then poll the mouse and `kbhit` until either; consumes the key (and the second byte of an extended key). | DOS listing |
| R:01A8:0250 / R:01A8:0268 | Show / hide the pointer, counted in DGROUP:DEEA; only when the set-up chose "Mouse and Keyboard" (DGROUP:1A3C). The pointer itself (`TORCH.PIC`): FORMATS.md 4. | DOS listing |
| R:0000:16AE(x, y) | Moves the mouse position (INT 33h function 4). | DOS listing; INT 33h PC fact |
| R:01A8:02A4(disk, mode) | Disk check: tests a file of disk `disk` (name table DGROUP:1ACE); when missing, the disk prompt of section 9.4. | DOS listing |

## 1. Order of the scenes

| Step | Routine | Scene (section) | Label |
|---|---|---|---|
| 1 | R:01A8:0008 main | loads `misc.exe`, then O1:0000 | DOS listing |
| 2 | O1:0000 | text-mode set-up screen (2) | DOS listing |
| 3 | R:01A8:0008 | NumLock cleared (0040:0017 bit 5), Ctrl-Break/Ctrl-C handlers (R:01A8:03F4) | DOS listing |
| 4 | O2:0000 | loading messages in text mode (3); driver load, mode set, timer; intro and credits (4); logo (5) | DOS listing |
| 5 | R:01A8:0008 | memory check (`LargestFreeBlock`, G#1; a "*LOMEM" message when short); pointer shape from `torch.pic`; pointer shown | DOS listing |
| 6 | R:01A8:0486 | title menu (6), then one branch: New Game (7.1), Load (7.2), EARTH (7.3), Customize (7.4), Hall of Fame (7.5, back to the menu) | DOS listing |
| 7 | O7:0012 | world generation with the Birth story (8), for New Game, EARTH and Customize | DOS listing |
| 8 | R:01A8:0533..0587, O5:1455 | no visible output: `sp299.pic` into page 1, part of it into page 2, shapes cut (SPRITES.md) | DOS listing |
| 9 | R:01A8:0810..0875 | VGA and choice 0, 2 or 3: fade to black; screen cleared; play palette from `sp257.pic`; map cycling prepared | DOS listing |
| 10 | R:01A8:087C | new game only (DGROUP:81D2 = 0): `diffs.pic` and the setup screens (9), then O5:1AF6 (no visible output: a government picture into pages 1 and 2) | DOS listing |
| 11 | R:0238:0092 | game loop: play screen (SCENES-PLAY.md) | DOS listing |

Windows order (architecture.md 3.3): intro movie, title menu inside the movie callback, Birth
movie during world creation, then `RunNewGameSetup (10E8:0000)`. The order of the steps that
show something is the same; DOS cuts the game shapes after Birth (step 8), Windows when the
title menu first opens (`LoadGameSpriteSheet 11E0:09D0`). **DOS listing**, Windows docs.

## 2. Text-mode set-up screen (O1:0000)

A DOS-only scene: there is no Windows counterpart, and it is not a 320 × 200 screen.

* **Routine**: O1:0000; text helpers R:0199:00A1 and R:01A8:08DB (cursor position). Video mode 3
  is set at O1:0008..0017. **DOS listing**
* **Text**: `INTRO.TXT` lines 1..10 at rows 1..10 (a box of code page 437 characters), line 11
  above the graphics menu, line 12 above the sound menu; two bytes of line 3 at columns 54..55 are
  patched before display (FORMATS.md 3.1). Menu lines: four graphics drivers from the pointer
  table DGROUP:322A (") VGA (256 color)" ...), six sound drivers from DGROUP:3232, then
  "1. Mouse and Keyboard" (DGROUP:3203) and "2. Keyboard only" (DGROUP:3219). Each item is
  printed as its digit plus the table text at column 27 (1Bh). **DOS file**, **DOS listing**
* **Input**: one digit per question, read with echo by `ReadCharEcho` (M#2) at the cursor
  (row 13, columns 49 or 50); the graphics answer rewrites the first letter of the driver name
  DGROUP:1A22, the sound answer the first letter of DGROUP:1A30, the control answer
  DGROUP:1A3C. No timed waits. **DOS listing**
* **Order**: before any graphics; the graphics answer decides the driver and so the colour
  path of every later scene. **DOS listing**

## 3. Loading messages (O2:0000..0150)

* Text mode still: when the disk-1 test file is missing, "One Moment Please..." (DGROUP:3256)
  and "Please insert Disk 1." (DGROUP:326B) at row 16, column 29, attribute set by the FFh code
  at DGROUP:3253; `getch` waits. Then `mgraphic.exe` (or the chosen driver) with `fonts.cv` and
  the sound driver are loaded. **DOS listing**
* `SetVideoMode` (G#37) at O2:0166 switches to the 320 × 200 screen; DAC entries 0..127 take the
  driver's default palette (PALETTE.md 2.1). Pages are allocated (O2:0163..01BC). **DOS listing**

## 4. Intro and credits (O2:01C8..09D4)

### 4.1 Preparation (untimed)

| Step | Address | Action | Label |
|---|---|---|---|
| 1 | O2:01E0 | screen filled black (0, 0, 320, 200); EGA: page 3 too | DOS listing |
| 2 | O2:020E | `MapLow16Colours`(DGROUP:19FE): DAC 0..15 take the driver's default entries through the 16-byte map at DGROUP:19FE, which is the identity except entry 5 → default entry 0 (black); border 0. No visible effect: the screen is black and step 6 replaces these entries (corrected 2026-10-11, review R2-6) | DOS listing, DOS file |
| 3 | O2:0223, O2:023E | `logo.pic` into page 1 (with palette); rows 64..143 grabbed as a sprite (`GrabSprite`(1, 0, 64, 320, 80)) | DOS listing |
| 4 | O2:0256, O2:027C | `birth0.pic` into page 1 (with palette); its rows 76..99 copied to rows 176..199 of page 1 | DOS listing |
| 5 | O2:028C, O2:02B2 | `birth1.pic` into page 2 (with palette); the same copy on page 2 | DOS listing |
| 6 | O2:02BE | palette of `logo.pic` applied (`R:1FA1:026C`): the whole intro is shown with the logo's palette (PALETTE.md 5) | DOS listing |
| 7 | O2:02DC | rows 12..187 filled black | DOS listing |
| 8 | O2:02F4..031A | cycling slot 1 prepared; VGA: slots 1..3 started (PALETTE.md 4) | DOS listing |
| 9 | O2:031C..033D | sound bit set; `credits.txt` opened; frame counter cleared; tune 3 started | DOS listing |

### 4.2 The panorama

* **Pictures**: `BIRTH0.PIC` (page 1) then `BIRTH1.PIC` (page 2), each 320 × 200 of which rows
  0..175 are used. **DOS listing**
* **Layout** (every column step, loop A O2:03D4..0442 and loop B O2:06BF..0794):

  | Screen rows | Source rows | Content |
  |---|---|---|
  | 0..11 | none | black band |
  | 12..75 | picture rows 0..63 | panorama |
  | 76..99 | page 1 rows 176..199 (the "strip") | panorama rows 64..87 rebuilt each step, with the credit text drawn into it |
  | 100..187 | picture rows 88..175 | panorama |
  | 188..199 | none | black band |

  Loop A (column x = 0..319): the first x columns of `BIRTH0` appear at screen x = 320 − x,
  so the picture slides in from the right edge over black. Loop B (x = 0..319): `BIRTH0` from
  column x at screen x = 0 and the first x columns of `BIRTH1` at screen x = 320 − x: the view
  continues into the second picture and ends on `BIRTH1`. **DOS listing**
* **Strip**: each step the strip on page 1 is rebuilt (loop A: black left part
  (0, 176, 320 − x, 24), then `BIRTH0` rows 64..87 at the right, O2:04F7..051A; loop B:
  O2:0868..0897) before the text is drawn into it. **DOS listing**
* **EGA path**: frames are composed alternately on page 0 and page 3 and shown with
  `ShowPage` (O2:0449..046E); VGA draws on the screen directly. **DOS listing**; purpose
  **unknown**.

### 4.3 Credits

* **Text source**: `CREDITS.TXT`, 24 lines, one line read per cue by O2:19A3 (`fscanf`).
  Cues at loop A columns 10, 70, 120, 170..310 every 20; loop B 10, 30, 64, 84, 130..290 every
  20; the line is cleared (empty) at loop A 50 and 160 and loop B 50, 116 and 310. Cue times:
  TIMING.md 5.3. **DOS file**, **DOS listing**
* **Font**: 5, set at loop A column 10 (O2:052C). **DOS listing**
* **Layout**: the line is drawn into the page-1 strip three times, centred on x = 160
  (R:0182:00B3): at strip y 184 (VGA colour 252, EGA 7), y 182 (VGA 248, EGA 15) and y 183
  (VGA 250, EGA 15). Strip y 176 is screen y 76, so the text sits at screen y 82..84 plus the
  16-pixel font height: a dark copy two pixels down, a light copy, and the face one pixel down
  over it. **DOS listing**; the three-layer look inferred.
* **Colours**: VGA 248, 250, 252 are entries of `LOGO.PIC`'s palette (PALETTE.md 5). **DOS
  listing**, **DOS file**

### 4.4 Timing and input

* Waits: per column, `S#5` against floor(21·x/4) (loop A, O2:0476..04BF) or floor((21·x +
  6720)/4) (loop B, O2:07D0..0828), with a catch-up that skips one odd column when late.
  Durations: TIMING.md 5.3. **DOS listing**
* Skip: `kbhit` after each column (O2:04C1, O2:082A) sets x := 999, ending the loop; the key
  stays pending, so loop B ends after one column too. Mouse buttons do not skip. **DOS listing**
* After the pan (O2:09D7..0A51): if a key is pending it is read; N, L, E, C (either case)
  preselect title items 0, 1, 2, 3 (DGROUP:6B32); any key skips the logo reveal and hold (5).
  **DOS listing**

### 4.5 Differences from Windows

Windows plays the intro movie `13D0:0000` from `RunIntroAndTitleMenu (11E0:0000)`: one
1024 × 320 panorama (picture 128) scrolled one pixel every 2 frames, a caption and nine credit
texts from STR# 137, fades of 20..40 steps, input tested every 20 frames and seeking to frame
1164 (the logo still plays) (WINDOWS-INVENTORY.md 6.1). DOS: two 320-wide pictures panned by
the sound tick, 24 credit lines from `CREDITS.TXT` in a band across the middle, no fade at all,
the logo palette from the start, and a key that also skips the logo reveal and hold.
**DOS listing**, Windows docs.

## 5. Logo (O2:0A19..0BD6)

* **Picture**: the sprite grabbed from `LOGO.PIC` rows 64..143 (4.1 step 3), drawn with colour 0
  transparent. **DOS listing**
* **Sequence** (no key pressed):
  1. Wait until `S#5` ≥ 0D87h (O2:0A19). **DOS listing**
  2. The current screen (the last panorama frame) copied to page 1; the logo drawn on page 1 at
     (0, 64) (`DrawSprite`, O2:0A81). VGA: cycling slot 4 started (PALETTE.md 4). **DOS listing**
  3. Reveal: 80 steps, each copying page-1 rectangle (x, 64, 4, 80) to the screen and
     `wait(1)` (O2:0AB4..0AF4), left to right. **DOS listing**
  4. Hold: up to 100 × `wait(5)` (O2:0AFD..0B19), ended by `kbhit`; then R:0403:4545. **DOS
     listing**
* **End** (with or without a key): VGA stops cycling slots 1..4 (the rotated colours stay);
  page 1 cleared to black, the logo drawn on it at (0, 64), `DissolveToScreen`(1, 20)
  (O2:0B8B) replaces the screen pixel by pixel; page 1 copied to the screen; font 1; sprite
  freed. The title menu then opens on the logo over black. **DOS listing**
* **Durations**: TIMING.md 5.3 (after-the-pan table).
* **Windows**: picture 136 composed by `IntroMovieCallback` case 3 in rect (5, 20, 507, 165)
  with fades over entries 0..235, then the title menu at frame 1260 (WINDOWS-INVENTORY.md 6.1).
  DOS has a strip reveal and a dissolve instead of palette fades. **DOS listing**, Windows docs.

## 6. Title menu (R:01A8:0486)

* **Routine**: R:01A8:0486; menu box R:0238:0008 → R:1D05:0031 (section 10.1). **DOS listing**
* **Background**: the logo on black left by section 5, with `LOGO.PIC`'s palette. **DOS
  listing**
* **Text**: DGROUP:1AE2, five items ("Start a New Game", "Load a Saved Game", "EARTH",
  "Customize World", "View Hall of Fame"), no header line. Hotkeys: the first letter of each
  item (10.1). **DOS file**, **DOS listing**
* **Layout**: menu at (100, 140), font 1; y is even, so the box is framed (10.1): solid
  colour 7 (DGROUP:2F98 is still 0), bevel 15/8, black outline. **DOS listing**
* **Skip into the menu**: when the intro preselected an item (4.4), the box is not shown.
  **DOS listing**
* **After a choice** (R:01A8:04C2..04E1): waits for a phrase boundary of the tune (`S#5`
  against 1495h and 120h), then tune 1. Durations: TIMING.md 5.4. **DOS listing**
* **Branches**: 0 → 7.1, 1 → 7.2, 2 → 7.3, 3 → 7.4, 4 → 7.5. A failed load or the Hall of Fame
  return to the menu by drawing the box again over whatever is on screen (R:01A8:0807).
  **DOS listing**
* **Windows**: dialog 139 (`MenuZ`) inside `IntroMovieCallback` at frame 1260, six items
  including "Quit" (architecture.md 3.3). DOS has five items and no Quit; the box is drawn over
  the logo screen, not over a dialog. **DOS listing**, Windows docs.

## 7. First screens of the title branches

### 7.1 Start a New Game (R:01A8:0511..058E)

Pointer hidden; the four world parameters DGROUP:7EF6..7EFC := 1 (the middle choices); then
`O7:0012` (Birth, section 8). The menu box stays on screen until the first Birth picture fades
out. **DOS listing**

### 7.2 Load a Saved Game (O11:0000)

* **Drive prompt** (O11:05F8): screen filled with colour 15; no border (DGROUP:681A = 1 here);
  the text DGROUP:4295 ("Which drive contains your...") plus the drive letter, DGROUP:4314 and
  DGROUP:4351 ("Press Escape to cancel.") drawn by R:1F4D:0088(99, 80, 72, 0): at (80, 72),
  colour 0, font 1. Input: R:1D05:0AC9; a letter A..F (either case) changes the drive and the
  prompt rectangle (80, 88, 160, 24) is redrawn, Return accepts, Escape cancels (returns −1);
  then (8, 8, 304, 184) is filled with colour 15. "No Disk in Drive A." (DGROUP:436E) in a framed menu box
  at (100, 80) when the drive has no disk. **DOS listing**
* **Slot list**: the header DGROUP:41B0 ("Select Load File...", starting with colour code 8Ch
  = colour 12) and ten lines, one per `CIVIL0..9.SVE` (O11:0103 reads each header), in a menu
  box at (48, 65): y odd, so frameless (10.1). A slot without a file returns −1. **DOS
  listing**
* **After**: success → pointer hidden, screen filled with colour 7, steps 8..11 of section 1
  (no fade for this branch); failure → the title menu again. **DOS listing**
* **Windows**: `LoadGameFromFileDialog (1130:000E)` (architecture.md 3.3). **Windows docs**

### 7.3 Play on EARTH (R:01A8:0795..07BA)

Pointer hidden; DGROUP:D76A := 1; `O7:0012`, which loads `MAP.PIC` into page 1 **with** its
palette (O7:0049; the title screen is still visible, so its colours change at once,
**inferred**), skips the generation stages and runs the Birth story already skippable
(DGROUP:67FC = 1). Then as New Game. **DOS listing**

### 7.4 Customize World (R:01A8:0591..0792)

* **Transition**: pointer hidden; disk check (7); VGA: fade to black, 5 steps (R:01A8:05B6);
  screen filled black; `CUSTOM.PIC` into page 1 with its palette (a cut); page 1 copied to the
  screen; pointer shown. **DOS listing**
* **Questions** (four frameless menu boxes, x = 200, font 1, default item DGROUP:2F9A := 1,
  pointer moved to (210, y + 10) first):

  | Question | Text | y | Help topic | Result |
  |---|---|---|---|---|
  | Land mass | DGROUP:1B48 ("LAND MASS:" + 3 items) | 1 | DGROUP:1B6A | DGROUP:7EF6 |
  | Temperature | DGROUP:1B6F | 51 | DGROUP:1B94 | DGROUP:7EF8 |
  | Climate | DGROUP:1BA0 | 101 | DGROUP:1BBD | DGROUP:7EFA |
  | Age | DGROUP:1BC5 | 151 | DGROUP:1BFE | DGROUP:7EFC |

  **DOS file**, **DOS listing**
* **Input**: Escape returns −1, which asks the same question again (no cancel). A help request
  (right button or Alt+H, 10.1) shows the help screen O4:0000 for the topic (10.3) and asks
  again with the chosen item preselected. **DOS listing**
* **After**: pointer hidden; Birth (section 8) with these values. **DOS listing**
* **Windows**: `CustomizeWorldDialog (1108:0243)`, one dialog with OK and Cancel
  (architecture.md, function table). DOS asks four menus in turn over a picture, without
  cancel. **DOS listing**, Windows docs.

### 7.5 View Hall of Fame (O3:002B, O3:00D7)

* **Data**: `FAME.DTA` (276 bytes, six entries of 46 bytes) read by O3:002B into a far buffer.
  **DOS listing**
* **Layout** (O3:00D7 with argument −1): screen filled with colour 15; "CIVILIZATION"
  (DGROUP:33BE) and "HALL OF FAME" (DGROUP:33CB) centred at (160, 16) and (160, 24), colour 0,
  font 1; a line (80, 32)–(240, 32) in colour 14; then the six entries from y = 40, each a
  name line at x = 8 in colour 0 and further lines at x = 20 in colours 7 and 12, 8 pixels per
  line plus 2 between entries. **DOS listing**
* **Input**: R:1459:0918 (any key or click), then the title menu box is drawn over this screen.
  **DOS listing**
* **New-entry form** (other callers, argument ≥ 0): the new entry's rectangle recoloured from 15
  to 14 (`RecolourRect`), the word DGROUP:346A ("Clear", with an inline colour code) at
  (252, 189) in a rectangle (236, 187, 60, 10) of colour 11; C returns 1. **DOS listing**
* **Windows**: `LoadHallOfFame (1080:0023)`, `ShowHallOfFame (1080:0119)` (architecture.md
  3.3). **Windows docs**

## 8. Birth (O7:0012, O7:17CF)

### 8.1 Mechanism

* **Routines**: world generation `O7:0012` calls the step function `O7:17CF` from its loops;
  after generation it sets DGROUP:67FC = 1 and calls `O7:17CF` until it returns 0, then sets
  font 1 and copies the screen to page 2 (O7:05C6). Schedule and state: TIMING.md 5.5. **DOS
  listing**
* **Text source**: `STORY.TXT`, read one line per event (O7:18FF). 44 text lines and 8 picture
  markers ("_" lines, at most 3 characters); the first line is a marker. **DOS file**, **DOS
  listing**
* **Pictures and palettes**: marker k loads `BIRTHk.PIC` (k = 1..8; DGROUP:3B64 starts at 1)
  into page 2 without palette; VGA: fade to black over 8 steps (O7:1A39), page 2 copied to the
  screen, `BIRTHk.PAL` loaded into DGROUP:C5BE and faded in over 8 steps (O7:1A93); EGA: the copy
  only. `BIRTH0.PIC` and `BIRTH0.PAL` are not used here. **DOS listing**
* **Text layout**: font 7 (O7:1896); each line centred at (160, 160) (R:0182:00B3): drawn in
  colour 3, `wait(5)`, drawn again in colour 11. Before each new line (after the first picture)
  the rows 160..167 are restored from page 2 (O7:194A) and `wait(10)`. While fewer than 40 lines
  have been shown, the previous line is first redrawn in colour 3 with `wait(5)` (O7:18D2..18EB).
  **DOS listing**
* **Cycling**: on each picture, VGA starts one slot per entry of the picture's group in the table
  at R:2710:0000 (period source: that table; PALETTE.md 4). **DOS listing**
* **Skip**: `kbhit` when an event is due and DGROUP:67FC = 1 (O7:1912), that is only after world
  generation; the key is not consumed here. Mouse buttons do not skip. **DOS listing**
* **End**: at end of file `wait(180)`; tune 1; VGA cycling stopped; state 2. **DOS listing**

### 8.2 The eight picture scenes

| Scene | Picture (page 2) | Palette (VGA fade in) | Text lines shown | Cycling ranges | Windows picture | Label |
|---|---|---|---|---|---|---|
| 1 | `BIRTH1.PIC` | `BIRTH1.PAL` | 3 | 3 | 128, shown from x = 512 | DOS file, DOS listing |
| 2 | `BIRTH2.PIC` | `BIRTH2.PAL` | 3 | 7 | 129 | DOS file, DOS listing |
| 3 | `BIRTH3.PIC` | `BIRTH3.PAL` | 8 | 5 | 130 | DOS file, DOS listing |
| 4 | `BIRTH4.PIC` | `BIRTH4.PAL` | 5 | 8 | 131 | DOS file, DOS listing |
| 5 | `BIRTH5.PIC` | `BIRTH5.PAL` | 6 | 5 | 132 | DOS file, DOS listing |
| 6 | `BIRTH6.PIC` | `BIRTH6.PAL` | 8 | 4 | 133 | DOS file, DOS listing |
| 7 | `BIRTH7.PIC` | `BIRTH7.PAL` | 10 | 4 | 134 | DOS file, DOS listing |
| 8 | `BIRTH8.PIC` | `BIRTH8.PAL` | 1 | 5 | 135 | DOS file, DOS listing |

Picture-to-picture correspondence with Windows is by order only (**inferred**). `BIRTH1.PIC` is
also the second half of the intro panorama (4.2), as Windows' first Birth picture is the right
half of its panorama (**DOS listing**, Windows docs).

### 8.3 Quirk: the marker is drawn

A marker line goes through the text path before the picture change: it is drawn at (160, 160) in
colour 3 then 11 (O7:195E..198C), and stays visible during the VGA fade to black. On EGA the
buffer still holds it at the next call, which redraws it in colour 3 until the next line restores
the row (**inferred** from O7:18D2 and O7:194A; on VGA the fade overwrites the text buffer
DGROUP:BA06, TIMING.md 3.5). **DOS listing**

### 8.4 "BUILDING NEW WORLD..."

When the story ends before world generation, the call that reaches state 5 clears
(40, 160, 240, 8) to colour 0; later calls draw DGROUP:3B28 ("BUILDING NEW WORLD...") centred at
(160, 160) in colour 15 or 3 by the parity of (frame counter / 60) (O7:1820..1847), over the last
picture with its palette. **DOS listing**

### 8.5 After Birth (no visible change until the fade)

`O5:1455` and the steps 8 and 9 of section 1 leave the last Birth screen in place; on VGA (New
Game, EARTH, Customize) it then fades to black over 5 steps (R:01A8:0840), the screen is cleared
and the setup screen appears by a cut (section 9). **DOS listing**

### 8.6 Differences from Windows

Windows: movie `13D8:0000` (78 items), pictures 128..135 at base 0, fades of 40 steps over 100
frames on entries 0..223, 44 texts STR# 139 in rect (0, 280, 512, 310) in colour 224, a schedule
by movie frame from 1000 to 11500, skip tested every 30 frames (WINDOWS-INVENTORY.md 6.2). DOS:
eight files with their own `.PAL` files, 8-step fades (48 frames) through black, text centred at
(160, 160) in colours 3 then 11, a schedule against the music tick, skip only after world
generation, per-picture palette cycling, and the "BUILDING NEW WORLD..." message. **DOS
listing**, Windows docs.

## 9. Setup screens (R:01A8:087C, O5:0000), in DOS question order

**Preparation** (R:01A8:087C): pointer shape reset (R:0000:1697); `DIFFS.PIC` into page 1 with
its palette (a cut while the screen is black); disk check. `O5:0000` copies page 1 to the screen
and sets font 7. **DOS listing**

### 9.1 Difficulty (O5:0031..0129)

* **Picture**: `DIFFS.PIC`: five leader portraits of 53 × 47 in two columns, level n at
  x = 21 (n even) or 80 (n odd), y = 35·n + 6. **DOS listing** (the copy rectangles)
* **Text**: DGROUP:3526 ("Difficulty Level..." header and five levels). **DOS file**
* **Layout**: frameless menu box at (160, 35), font 7. **DOS listing**
* **Input**: menu keys and mouse (10.1). When the mouse was used (DGROUP:2FA2) and its x is
  below 135, the choice is clamp((mouse y − 12)/35, 0, 4) (a click on the portraits); any
  remaining −1 (Escape, or a click outside the box) becomes 0. **DOS listing**
* **Result screen**: (0, 0, 150, 200) filled black; the chosen portrait copied to (20, 100);
  (150, 0, 160, 200) restored from page 1. **DOS listing**

### 9.2 Level of competition (O5:012E..021B)

* **Text**: DGROUP:357B header, one item per count built with `itoa` and DGROUP:3595
  (" Civilizations"). **DOS file**, **DOS listing**
* **Layout**: frameless menu box at (160, 35); Escape asks again. **DOS listing**
* **Result screen**: the chosen difficulty portrait drawn once per civilization from the back:
  copies at (20 + 2k, 100 + 3k) for k = count..0. **DOS listing**

### 9.3 Pick your tribe (O5:0309..0587)

* **Text**: DGROUP:35A6 header, then the tribe names from the 58-byte tribe records (two groups
  of count + 1 names). **DOS file**, **DOS listing**
* **Layout**: (150, 0, 160, 200) restored from page 1; frameless menu box at (160, 35). **DOS
  listing**
* **Input**: a tribe item; Escape (−1) chooses a random slot and asks the tribe name (9.4).
  **DOS listing**
* **Result**: the tribe's plural name centred at (46, 92) in colour 15, above the portraits;
  then (150, 0, 170, 200) filled black. **DOS listing**

### 9.4 Name of your tribe (O23:0173, only after Escape in 9.3)

White box (158, 88, 160, 32) with an outline of colour 11; "Name of your Tribe..."
(DGROUP:53B8) at (166, 90) in colour 0; edit field (10.4) at (166, 104), 11 characters,
pre-filled with the slot's default name. A final "s" is dropped for the adjective, which is cut
to 10 characters. **DOS listing**

### 9.5 Your name (O23:00D6)

The same box; "Your Name..." (DGROUP:53AB) at (166, 90); edit field at (166, 104), 13
characters, pre-filled with the default leader name. **DOS listing**

### 9.6 The introduction text (O5:0657..07BD)

* **Text**: `KING.TXT` section "*INIT" (R:1F4D:044F), with the leader and tribe names
  (DGROUP:[30BE], [30B8]), followed by the names of the starting advances and DGROUP:35CE
  ("and Roads."). **DOS listing**; the substitution mechanism FORMATS.md 3.
* **Layout**: font 1; screen filled with colour 15; ornamental border (R:0866:260E); the
  difficulty portrait at (134, 20); the text by R:1F4D:0088(99, 88, 81, 0) at (88, 81) in
  colour 0. **DOS listing**
* **Sound**: the tribe's tune is started (O5:0738). **DOS listing**
* **Input**: R:1459:0918, any key or click; then `O5:1AF6` and the play screen. **DOS listing**

### 9.7 Differences from Windows

`RunNewGameSetup (10E8:0000)` shows dialog 144 for difficulty, competition, tribe and names,
then the KNG_INIT text in dialog 151 (architecture.md 3.3; WINDOWS-INVENTORY.md 4.1). DOS: one
frameless menu per question over `DIFFS.PIC` with portrait feedback on the left, white name
boxes, a tribe-name question only after Escape, and the introduction text on a white screen
with a border and the portrait. Same question order. **DOS listing**, Windows docs.

## 10. Generic interface

### 10.1 Menu box (R:1D05:0031)

Entry points: R:0238:0008(text, x, y) and R:1D05:0018 (keys flushed first), R:1D05:0000 (no
flush, used by the menu bar), R:0238:001E (the same, but the screen is saved to page 1 before
and restored after). Returns the item index, or −1. **DOS listing**

* **Text**: a string of lines separated by newline (DGROUP:BA06 after `strcpy`/`strcat`). A line
  starting with a space or "_" is an item; other lines are headers. The hotkey of an item is the
  character after that space or "_" (first 32 items, DGROUP:DC4A). **DOS listing**
* **Geometry** (R:1D05:0475): row height h = `FontLineHeight` of the current font, 9 becoming 8
  (and 8 when DGROUP:3936 ≠ −1); W = widest line in pixels. Lines at (x + 5, y + 5 + r·h).
  Right edge x + W + 8; bottom y + rows·h + 6 (+2 with the help line). The number of visible
  rows is clamped to (192 − y)/h. **DOS listing**
* **Framed or frameless**: y even, or y = 139: framed: box R:1D05:096C(x, y, right − x,
  bottom − y, 7) (0.2), solid colour 7 before DGROUP:2F98 is set (title screens) and textured
  after. y odd (≠ 139): no box; the "bar colour" is the screen pixel at (x, y) (`GetPixel`).
  **DOS listing**
* **Colours**: header lines in colour 15 (3 when the bar colour is 15), with a colour-0 copy one
  pixel lower when h > 9; items in colour 0, disabled items (bit set in DGROUP:B276) in colour 3.
  The selected row (rectangle (x + 3, y + 4 + r·h, W + 5, h)) is marked with `RecolourRect`:
  bar colour → 11 and, on VGA framed boxes, 22 → 3 (8 → 3 when y = 139); the row left is
  recoloured 11 → bar colour and 3 → 22 (or 8). The texture tile (page 2 (288, 120), from
  `SP299.PIC`) holds only colours 7 and 22, so the bar turns a textured row into 11 and 3.
  **DOS listing**, **DOS file** (tile indices). Side effect: colour-3 text (disabled items) on a
  row the bar has left becomes colour 22 (**inferred**).
* **Optional lines**: DGROUP:2FA0 → "(HELP AVAILABLE)" (DGROUP:2FBD) in font 2, colour 10, at
  (right − 74, bottom − 4); DGROUP:8066 → "OK" (DGROUP:2FCE) in colour 11 inside an outline
  (right − 20, bottom − 10, 20, 10). An advisor portrait variant (DGROUP:2F9E ≥ 0) widens the box
  and draws a 40 × 60 portrait left of it. **DOS listing**
* **Keys**: Up/Down move (keyboard can land on disabled items); Return or Space choose (not a
  disabled item); Escape returns −1; Alt+H chooses with the help flag DGROUP:2F9C = 1; Alt+V
  toggles sound (DGROUP:19C0 bit 10h); a hotkey letter (compared on its low 5 bits) selects and
  chooses. **DOS listing**; key names PC fact.
* **Mouse**: row = (mouse y − y − 4)/h; x outside [x, right] means no row. Moving with a button
  down highlights; releasing chooses (a disabled row keeps the previous one); right button sets
  the help flag. **DOS listing**
* **Confirmation**: EGA: the chosen row flashes (recolour 11 → colour 15, or 3); all paths then
  `wait(20)` (R:1D05:0441, TIMING.md 5.4). The box is not erased. **DOS listing**
* **Windows**: radio menu dialogs (`RunRadioMenuDialog 11E0:0A2A`, `MenuZ`; architecture.md
  segment table). **Windows docs**

### 10.2 Menu bar drop-downs (R:1C84)

The bar itself belongs to the play screen (SCENES-PLAY.md 5.1). This section records the DOS
drop-downs as DOS facts; during play the profile keeps the Windows menu bar geometry (the DOS
play layout add-on is withheld; DOS-PROFILE.md row 121, OPEN.md P24). Its five menus are chosen
from the mouse x / 60 (R:1C84:0019..002E) and open as menu boxes (R:1D05:0000, no flush) at y = 8 and
x = 16 (GAME, DGROUP:2BD4), 72 (ORDERS), 112 (ADVISORS, DGROUP:2DD6), 144 (WORLD), 182
(CIVILOPEDIA); the Options sub-menu (DGROUP:2C3E) at (24, 16). All framed (y even), textured.
The screen is saved and restored around them (R:0866:25B6/25D7). **DOS listing**; menu titles
inferred from the item texts.

### 10.3 Popups and text screens

| Element | Routine | Look | Label |
|---|---|---|---|
| Text screen | R:1F4D:0088 on a cleared screen | text in one colour at a fixed origin, wrapped at `columns` × 8 pixels (examples 7.2, 9.6) | DOS listing |
| Help screen | O4:0000(topic) | `HELP.TXT` section; screen saved (R:0866:25B6); filled with colour 2; the topic name centred at (160, 192) in colour 0; text R:1F4D:0088(32, 32, 32, 15) at (32, 32) in colour 15; any key or click; screen restored | DOS listing |
| Message in a menu box | R:0238:0008 with a text of header lines only, e.g. the disk prompt (next row) | framed or frameless as 10.1 | DOS listing |
| Disk prompt | R:01A8:02A4 | screen filled with colour 15; "Please insert Disk n." (DGROUP:1A93, 1AA7: "Press Return to continue.") in a frameless menu box at (100, 81); filled with 15 again afterwards | DOS listing |
| Advisor and report boxes | (play scenes) | SCENES-PLAY.md | – |

### 10.4 Text entry (O23:0414)

Arguments (x, y, max): DGROUP:BA06 holds the pre-filled text. **DOS listing**

* **Look**: field (x, y, 7·max, 11) filled with colour 15; outline (x, y − 1, 8·max + 8, 13) in
  colour 0; characters drawn one by one from (x + 2, y + 2) in colour 0 over 8 × 8 cells of
  colour 15 (O23:06C1). Cursor: the cell under it (character width × 10) recoloured 15 → 11,
  `wait(10)`, back, `wait(10)` while no key (O23:04B9..0518). **DOS listing**
* **Keys**: printable 20h..7Fh types at the cursor (the first key clears the pre-filled text);
  Left/Right move; Ins inserts a space; Del deletes; Backspace deletes left; Return or a mouse
  click accepts; Escape returns 0 (cancel flag). Trailing spaces are trimmed; keys flushed at
  the end. **DOS listing**
* **Callers and boxes**:

  | Use | Routine | Box | Prompt | Field, max | Label |
  |---|---|---|---|---|---|
  | Leader name | O23:00D6 | (158, 88, 160, 32) white, outline 11 | "Your Name..." at (166, 90) | (166, 104), 13 | DOS listing |
  | Tribe name | O23:0173 | the same | "Name of your Tribe..." | (166, 104), 11 | DOS listing |
  | City name | O23:0000 | (80, 80, 160, 32) white, outline 11; screen saved and restored | "City Name..." (DGROUP:539E) at (88, 82): the listing pushes y 82 (O23:0049), then x 88 (O23:004D) (corrected 2026-10-18 by unit D7f, `../ext-D7f-record.md`; this table read (82, 88) before) | (88, 96), 12 | DOS listing |
  | Find city | O23:0319 | (64, 78, 224, 24) white, outline 0 | the caller's text at (66, 80) | (66, 89), 16 | DOS listing |

* **Windows**: name entry is part of dialog 144 and the city-name dialogs (WINDOWS-INVENTORY.md
  4.1). **Windows docs**

## 11. Differences from Windows (summary)

| Scene | Windows | DOS | Label |
|---|---|---|---|
| Configuration | none (Windows settings) | text-mode screen O1:0000 choosing drivers and control | DOS listing |
| Intro | movie 13D0:0000, one 1024-wide panorama, 9 credit texts, palette fades | two pictures panned by the music tick, 24 `CREDITS.TXT` lines in a middle band, no fades, logo palette throughout | DOS listing, Windows docs |
| Logo | picture 136, fades | sprite from `LOGO.PIC`, strip reveal, hold, dissolve | DOS listing, Windows docs |
| Title menu | dialog 139, 6 items with Quit | menu box at (100, 140), 5 items | DOS listing, Windows docs |
| Customize | one dialog with Cancel | four menus over `CUSTOM.PIC`, help, no cancel | DOS listing, Windows docs |
| Birth | movie 13D8:0000, 40-step fades over 100 frames, text at (0, 280, 512, 310) colour 224 | 8 pictures and `.PAL` files, 8-step fades via black, text at (160, 160) colours 3/11, palette cycling, music schedule | DOS listing, Windows docs |
| Shapes | cut when the title menu opens | cut after Birth (O5:1455) | DOS listing, Windows docs |
| Setup | dialogs 144 and 151 | menus over `DIFFS.PIC`, name boxes, text screen | DOS listing, Windows docs |
| Load | file dialog | drive letter, then 10 fixed slots | DOS listing, Windows docs |

## Open

1. **`S#5` units.** The intro, title and Birth schedules are in sound ticks; their meaning per
   sound driver is TIMING.md's (3.4) and partly unknown (ASOUND, RSOUND).
2. **Bevel orientation.** R:1D05:0A66 draws the top and right edges in the second colour (8) and
   the bottom and left in the first (15): light from the lower left. Read from the argument order
   of R:0182:000A; not seen on screen.
3. **Colour 22 and y = 139.** Colour 22 is the texture's second colour (10.1); the y = 139 case
   (colour 8) has no identified caller here, and which menus have disabled items reachable by
   keyboard (where the 3 → 22 side effect would show) is not traced.
4. **Frameless bar colour.** The highlight recolours every pixel of the sampled colour inside the
   row rectangle; on pictures (`DIFFS.PIC`, `CUSTOM.PIC`) its look depends on the picture and was
   not checked.
5. **`INTRO.TXT` line 3 patch** (O1:005D..0069): purpose unknown (FORMATS.md Open 8).
6. **Loading messages.** The exact condition under which "One Moment Please..." and the disk-1
   prompt show (O2:0019..00E5) was not traced in full.
7. **EARTH palette change.** `MAP.PIC` is loaded with its palette while the title screen is
   visible (7.3); the visible effect is inferred, not observed.
8. **Ornamental border tiles.** R:0866:260E's tile choice uses R:1DC4:005D; whether that is the
   game's random generator (and so consumes it during presentation) is not established here.
9. **Hall of Fame line layout.** The per-entry line contents (rank text, population, score,
   rating) were read only roughly; exact x of each field beyond 8 and 20 is not listed.
10. **Advisor portrait variant of the menu box** (DGROUP:2F9E) is play-screen territory and only
    outlined.
11. **Text colour codes.** Strings with bytes of 80h or above (DGROUP:41B0, DGROUP:346A) rely on
    `DrawText`'s colour switch (G#21: a byte of 80h or above sets the colour to the byte & 7Fh,
    FORMATS.md 2.3, G:0000:0F9C). Every DOS font ends at code 7Fh or lower (FORMATS.md 2.2), so
    the DOS program has no glyph for those bytes. How the profile treats them (honoured in
    DOS-sourced static text only; core bytes of 80h and above by a recorded substitution) is a
    D1 decision: OPEN.md P5, P13; DOS-PROFILE.md 0.6 rule 8.
12. **Pointer position moves** (R:0000:16AE) in Customize assume the mouse driver accepts them;
    behaviour without a mouse driver not checked.

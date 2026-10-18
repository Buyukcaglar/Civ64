# DOS data formats

Draft of extension phase D0 (prompt section 6 items 1 and 5), written 2026-10-11 by agent D0-C.
It covers the DOS pictures (`*.PIC`), palettes (`*.PAL`), the fonts (`FONTS.CV`), the 13 texts
(`*.TXT`) and the mouse pointer: who reads each one, the byte layout, the decode algorithm, what
the reader does on bad input, and how sure we are. Section 5 checks the prompt's "Observed facts
about the DOS files" (prompt section 3) for these files. Section 6 is the registry of the DOS
data the profile reads at run time (prompt 5.9): true data tables at image offsets, and
constants inside code, kept apart.

Labels: **DOS file** (checked byte by byte on the pinned files in `build/dosdata` with the
viewers below), **DOS listing** (read from the listings in `build/dos/disasm/` or from my own
disassembly of the same files), **inferred** (a conclusion from the evidence, or general PC / MS C
knowledge, said where it carries the conclusion), **unknown**. Addresses use the notation of
`docs/verify/BRIEF-d0.md`: `R:` root, `O<n>:` overlay, `G:` MGRAPHIC.EXE, `DGROUP:` the root's
data segment R:2B01. No DOS bytes are reproduced here; the decoded files are only under
`build/dos/view/`.

## 0. Viewers and checks

| Tool | Writes | Check token |
|---|---|---|
| `gen/dos/pic.py view [--pal NAME.PAL] [--force-pal] [NAME ...]` | `build/dos/view/pic/<NAME>.png`, `index.json` (chunks, size, pixel SHA-256, LZW resets) | `pic.py check`: `PIC_OK` |
| `gen/dos/fontcv.py view` | `build/dos/view/fonts/font<n>.png` (one glyph sheet per font) | `fontcv.py check`: `FONTCV_OK` |
| `gen/dos/texts.py view` | `build/dos/view/texts/<NAME>.json` (parsed records, text included) | `texts.py check`: `TEXTS_OK` |
| `gen/dos/png.py` | (helper: indexed and RGB PNG with `zlib` and `struct`) | - |

Run as `C:/Python314/python -B gen/dos/<tool>.py ...` from `claude/port`. `view --out DIR` is
refused (exit code 2, nothing written) unless DIR resolves under `claude/port/build/` (prompt 6.1;
`png.out_dir`, added 2026-10-11 for review finding R2-18). Each `check` decodes
everything and exits non-zero on any failure. On 2026-10-11 all three printed their OK token:
106 PIC and 38 PAL decoded, 9 fonts parsed, 13 texts parsed. PIL 12.3.0 is importable but not
used. The PNGs were inspected by eye (pictures, sprite sheets, the torch pointer, glyph sheets);
the images are whole and unsheared, which a wrong row length, bit order or RLE count would break.

## 1. Pictures (`*.PIC`) and palettes (`*.PAL`)

### 1.1 Readers

| Address | Role (DOS listing) |
|---|---|
| R:1FA1:01A2 `(page, x, y, name, mode)` | The general loader: opens `name`, starts the word reader, walks the chunks (R:0000:108E with `mode`), then for each row calls R:0000:1208 into the row buffer DGROUP:E17E and driver slot 19 to copy it to `page` at `(x, y + row)`. A negative `page` forces the height to 0 (palette only, R:1FA1:01CD). Closes the file. |
| R:1FA1:0220 `(page, name)` | `01A2(page, 0, 0, name, 1)`: picture and palette. Wrapper R:1FA1:04C0 `(name, page)` swaps the arguments. |
| R:1FA1:0254 `(page, name)` | `01A2(page, 0, 0, name, 0)`: picture, palette not applied. |
| R:1FA1:026C `(name)` | `01A2(-1, 0, 0, name, 1)`: palette only, applied (for example a picture's palette at O2:02BE). |
| R:1FA1:0288 `(name, buffer)` | `01A2(-1, 0, 0, name, buffer)`: palette copied into a caller buffer, not applied. All 15 call sites in the listing: into DGROUP:BDEE O5:16D2 (`sp256.pal`), O6:22C2 (`back<d><a/m>.pal`: the picture name with "pal" copied over its extension at O6:2279), O9:1220 (`slam1.pal`), O19:0EA9 (`hill.pal`) and R:1DC4:0492 (the name passed to R:1DC4:047D, called from O8:076C, 0934, 0A20 and O16:0104); into DGROUP:C1D6 O6:22B2 (`king<NN>.pal`, digits patched at O6:2295..22A7), O9:1210 (`king<NN>.pal`: "pal" copied over the picture name's extension at O9:11F8..1200), O18:01F8 and R:0238:1C52 (`back<d><a/m>.pal`), R:0ADE:1958 (`discovr<n>.pal`, ".pal" copied at R:0ADE:1948); into DGROUP:C5BE O7:1A83 (`birth<n>.pal`: "pal" copied over the picture name's extension at O7:1A6B..1A73), O8:0AFF, O18:0208 and R:0238:1C62 (`sp256.pal`), R:0ADE:1968 (`iconpg1.pal`). Every call names a `.PAL` file. Roles: [PALETTE.md](PALETTE.md) 7. |
| R:1FA1:023A `(page, name, mode)` | `01A2(page, 0, 0, name, mode)` (found by prologue scan only). |
| R:1FA1:044C `(name)` | Loads a picture into the driver's sprite store (slots 35, 34 per row, 33) with mode 0 and returns the sprite's segment; used for the pointer (section 4). |
| R:1FA1:04D2, R:1FA1:0536 | Further row loops over the same decoder (prologue scan only; 0536 reads from memory through R:1FA1:05FE). |
| R:1FA1:000A `(name, mode)` | Open: first looks the name up in an archive (R:1FA1:0728, active only when DGROUP:552A is not -1; see Open), else DOS open (R:2045:30CE). |
| R:1FA1:05E0 / R:1FA1:0644 | Start the word reader on a handle / refill it: 512 bytes (0200h) into DGROUP:D936, read pointer DGROUP:B26E, end DGROUP:5528 = DB36h, refill routine far pointer at DGROUP:D91A. |
| R:0000:108E `(mode)` | Chunk walk and image header. |
| R:0000:1227, R:0000:1270 | LZW start (maximum code width) and dictionary reset. |
| R:0000:1208 `(buffer)` / R:0000:12A6 | One row: RLE stage and, for X1, nibble split. |
| R:0000:1318 | One LZW code (returns the decoded string one byte per call). |
| G:0000:0162 (slot 28) → G:0000:01A1 | Palette chunk to the VGA DAC. |
| G:0000:03DF (slot 19) | Copy one row from the row buffer to a page. |

### 1.2 Layout (DOS file, DOS listing)

A file is a sequence of chunks, read as little-endian words from offset 0.

| Offset in chunk | Width | Field |
|---|---|---|
| +0 | 2 bytes | Tag, two ASCII characters: `E0`, `M0`, `X0` or `X1` in the release |
| +2 | u16 | Length of the data that follows |
| +4 | length | Data |

| Chunk | Data layout |
|---|---|
| `E0` (258) | u8 first index, u8 last index (0 and 255 in all files), then one byte per index first..last. Only the EGA driver uses it (1.5). |
| `M0` (770) | u8 first index, u8 last index (0 and 255 in all files), then (last - first + 1) R, G, B byte triplets for indices first..last. Values are 6-bit (maximum 63 in every file). |
| `X0`, `X1` | u16 width, u16 height, u8 maximum LZW code width (11 in all files), then the code stream to the end of the file. The chunk's length word runs to the end of the file in all 144 files but the reader never uses it for pictures (R:0000:115C stores it in DGROUP:68E6). |

A `*.PAL` file is an `M0` chunk followed by an `X0` chunk of length 4 whose width and height are 0
(782 bytes).

### 1.3 Decode algorithm (DOS listing; verified on all files)

1. **Word reader.** Every read is a 16-bit word from the 512-byte buffer; when the read pointer
   reaches DB36h the buffer is refilled with the next 512 bytes of the file. There is no end-of-file
   test: a refill past the end leaves the old buffer bytes in place.
2. **Chunk walk** (R:0000:109E..1135). Read the tag word. If its first byte is `X` (58h) the walk
   ends; bit 0 of the second byte selects X1 (1) or X0 (0) into DGROUP:68F7. Otherwise read the
   length word and copy tag, length and length/2 data words into DGROUP memory:
   * tag `M0` and mode 0: to DGROUP:BA08 (discarded: the LZW dictionary at BA06 overwrites it);
   * tag `M0` and mode 1: to DGROUP:BA06, then slot 28 is called with BA06 (the palette is set);
   * tag `M0` and mode > 1: to the caller's buffer at DGROUP:mode (kept, not set);
   * any other tag: to DGROUP:BA06, then slot 28 is called with BA06.
   Slot 28 is also called once with a null pointer before the walk (R:0000:1093).
3. **Image header** (R:0000:1138..119F). Read the length word (unused), the width (DGROUP:68E2)
   and the height (DGROUP:68E4). If both are 0, stop (the `*.PAL` case).
4. **LZW start** (R:0000:1227..12A5, falling through into the reset R:0000:1270). Read one word:
   its low byte is the maximum code width, clamped to 11 (R:0000:125F); its high byte is the first
   8 bits of the code stream. Reset the dictionary: 2048 three-byte entries at DGROUP:BA06 (prefix
   word FFFFh = root, byte = the root's value for 0..255), code width 9, mask 1FFh, next code 100h.
   The RLE state is cleared. The dictionary occupies DGROUP:BA06..D205 (2048 x 3 bytes); the reset
   writes the prefix word of every entry (R:0000:1282..1291) and the byte of entries 0..255. It
   runs for every image whose width or height is not 0, before the loader looks at its `page`
   argument, so a palette-only load of a `*.PIC` (R:1FA1:026C, or R:1FA1:0288 with a picture name)
   also overwrites that region; a `*.PAL` load does not (R:0000:1227 returns at 1230). The palette
   buffers inside the region: [PALETTE.md](PALETTE.md) 2.6 (DOS listing).
5. **Codes** (R:0000:1318). Codes are read LSB first: each new word supplies 16 more bits above
   the unread ones. For code `c` with `next` the next free entry:
   * `c < next`: output the string of `c`;
   * `c >= next` (only `c == next` occurs): output the string of the previous code followed by
     that string's first byte.
   Then entry `next` gets prefix = previous code and byte = first byte of this string, `next` is
   incremented, and when `next` exceeds the mask the width grows by one (mask = mask * 2 + 1).
   When the width would exceed the maximum (after entry 2047 is made, with maximum 11), the
   dictionary is reset to step 4's state at once (no clear code, no end code). The first code
   after a start or a reset still makes entry 100h, from a stale previous code; an encoder that
   never emits 100h is compatible: in 1,019,502 codes of the 106 pictures, 100h never occurs and
   `c == next` occurs 15,671 times (DOS file). The previous code lives in DGROUP:68F8, written
   after every code (R:0000:13C1) and never reset (R:0000:1227 and 1270 leave it): it is 0 at
   program start (DGROUP initial value, DOS file) and afterwards the last code of the previous
   decode, possibly of another picture (DOS listing). Because no picture refers to entry 100h of a
   fresh dictionary (below), a decoder that starts each picture from any previous code gives the
   same pixels; one that keeps it across pictures follows the listing exactly. `pic.py` decodes
   each file alone, uses 0 and flags any reference to such an entry.
6. **RLE** (R:0000:12BC..12EB), over the LZW bytes, state kept in DGROUP:68EC (count) and 68ED
   (last byte): a byte other than 90h is output and becomes the last byte; 90h followed by 0
   outputs a literal 90h (which becomes the last byte); 90h followed by n > 1 outputs the last byte
   so that it appears n times in all, counting the earlier byte (n - 1 more copies:
   R:0000:12DF..12E7 stores n - 1, outputs one copy and decrements). n = 1 stores 0, outputs one
   copy and decrements the byte count to FFh, so the pair gives 256 copies after the earlier byte,
   257 in all; it never occurs in the files (DOS file).
7. **Rows.** Each row takes `width` RLE bytes (X0) or `(width + 1) / 2` RLE bytes (X1). An X1
   byte gives two pixels, the low nibble first (left), then the high nibble. Rows run top to
   bottom. The LZW and RLE states run on across rows: a run or a string can span two rows.

Every picture decodes to exactly its width x height and consumes the file to its last byte (to the
last word for odd sizes); no picture refers to a dictionary entry made from a stale code
(`pic.py check`, DOS file).

### 1.4 Palette and drawing (DOS listing)

* **Palette to the DAC.** G:0000:0162 accepts only a chunk tagged `M0` (G:0000:016C..0175) and
  sends `last - first + 1` triplets, starting with the triplet at data offset 2, to DAC entries
  `first` onward (G:0000:01A1: port 3C8h index, three writes to 3C9h). The writes start at the
  next vertical retrace (port 3DAh bit 3): the writer counts the entries it writes while retrace
  lasts (k), then writes 13·k more without testing, then waits for the next retrace
  (G:0000:01B8..01EB; [PALETTE.md](PALETTE.md) 2.1, [TIMING.md](TIMING.md) 3.7; DOS listing:
  since fixer F1's disassembler fix of 2026-10-11 the listing follows the `loop` target at
  G:0000:01DB and decodes the whole writer). Because all files have
  first 0 and last 255, the data is always a full 256-entry palette.
* **6-bit values.** Nothing in the DOS program scales a palette value: the DAC writer above, the
  fade and cycling writers R:0000:0631 and R:0000:044A, and the BIOS call of R:1DC4:0698 all send
  the stored bytes (DOS listing). The VGA DAC takes 6-bit components; full scale is 63 and the
  output level is linear in the value, so a value v shows v/63 of full intensity (PC fact).
  Three 8-bit renderings of that fact are in use or obvious: floor(v·255/63) (the D0 viewers,
  `png.vga6_to_8`), round(v·255/63) (the nearest 8-bit level) and bit replication
  4v + v div 16. Each pair differs by at most 1 in some of the 64 values (floor and round in 30,
  floor and replication in 30, round and replication in 10; DOS-independent arithmetic). Which
  one the profile records as its rule (prompt 5.9) is a D1 decision (OPEN.md, P group); the
  viewers' rule is only the viewers' rendering.
* **Rows.** G:0000:03DF copies `(width + 1) / 2` words from the row buffer and does not clip to
  the width, so an odd width also copies the row buffer's next byte. SLAG2 and SLAM2 are 197 wide
  (X0): R:0000:1208 writes 197 bytes per row into DGROUP:E17E, so the 198th pixel of each row is
  byte 197 of the buffer, whatever an earlier, wider row left there (DOS listing). Whether that
  column shows is unknown (Open 5).
* **X1 pictures** hold indices 0..15 only; they are drawn into the same 256-colour pages.

### 1.5 What `E0` is for

MGRAPHIC ignores every chunk not tagged `M0`. EGRAPHIC (reference only) has at load-module offset
04CAh its slot 28: for an `E0` chunk it stores, for each index first..last, the byte's two
nibbles (high, then low) as a pair of EGA colours in a table at its offset 018Ah + 2 * index and
sets a flag (offset 0189h = FFh); a null pointer clears the flag; an `E1` chunk goes to another
routine (offset 04A3h; no `E1` chunk exists in the release). Inferred: each 256-colour index maps
to two 16-colour EGA values, a dither pair. EGA is out of scope.

### 1.6 Failure behaviour (DOS listing)

| Case | Behaviour |
|---|---|
| Open fails | R:1FA1:066E: video mode 3 (INT 10h through R:1FA1:0696), `perror(name)` (R:2045:200E), exit code 63h (R:2045:019E). Close or archive errors take the same path with a null name. |
| No `X` chunk | The walk reads stale buffer words forever or until a stale word starts with `X` (unknown in practice). |
| Unknown tag | Copied to DGROUP:BA06 without a length check, then given to slot 28 (ignored by MGRAPHIC). A chunk of odd length desynchronises the word reads. |
| Truncated code stream | Decoding continues on stale buffer bytes; no error. |
| Width or height too large | No check: rows larger than the row buffer at DGROUP:E17E overrun it (unknown size limit). |

Confidence: high for the layout and the decode (exact consumption of all 144 files, images
correct by eye); high for the palette path; medium for the E0 meaning (EGA side only).

## 2. Fonts (`FONTS.CV`)

### 2.1 Readers (DOS listing)

* **Load.** O2:011E..0134 loads the graphics driver with `R:0000:0A76("mgraphic.exe",
  "fonts.cv")`. R:0000:0A76 places the data file right after the driver's data segment: header
  word 2Ah (that segment, relocated) plus the paragraphs of word 2Ch (its size), R:0000:0AD9..0AED;
  R:0000:0B1E reads the whole file there in 32 KiB pieces (INT 21h AH=3Fh until a short read). For
  MGRAPHIC, word 2Ah is 013Ch and word 2Ch is 0630h, and the driver loads its data segment
  register from `cs:[1988h]`, which holds the same relocated 013Ch (DOS file: relocation entry at
  load-module offset 1988h). So `FONTS.CV` starts at offset 0630h of the driver's data segment,
  and every font routine addresses it as `ds:0630h + ...`.
* **Use.** The driver functions, given a font number n (the drawing context word +10h, set by
  the C code, for example O2:052C sets 5):

| Slot | Address | Function |
|---|---|---|
| 4 | G:0000:115D `(n, code)` | Advance of one code: 0 if n or the code is out of range or the code is 80h or above; else (fixed advance, or the width table entry) + spacing. |
| 12 | G:0000:11AE `(n)` | Line height: height + extra rows. |
| 21 | G:0000:11D7 `(context, x, y, string)` → G:0000:11F0 | Draw a string: G:0000:1328 (font set-up), 125C and 1208 (horizontal clipping), 12BE (vertical clipping), 0FAC (glyphs). |
| 11 | G:0000:10E8 `(n)` | Meant as a far pointer to font n's bitmap, but it compares n with the word at data:**0020** and returns data segment : (0630h + the word at data:(0020h + 2n)) (G:0000:10F5, 1100..1104), not the table at data:0630 that slots 4, 12 and the text code read (G:0000:1172, 117C, 1358). The file holds copyright text at data:0020 (DOS file). Inferred defect; [DRIVER.md](DRIVER.md) G#11. |
| 16 | G:0000:110D `(n, source)` | Copy a font of the same layout over font n; uses the same data:0020 table (G:0000:111E, 1129), so the same defect ([DRIVER.md](DRIVER.md) G#16). No caller. |

R:1FA1:02E6 `(n, i, file)` (prologue scan only, no reference found) reads font `i` of a file in
the same layout through the pointer slot 11 returns: it reads word 0 (count, `i` must not exceed
it), the word at 2i (offset), the 8 header bytes at offset - 8, and the bitmap, and when the
fixed-advance byte is 0 it starts k bytes earlier to include the width table. Its file reading
matches the layout below, but because slot 11 indexes the word table at data:0020 (the word at
data:(0020h + 2n)) it would not write over resident
font n (DOS listing; inferred). Neither slot 11 nor 16 is reached by the known code; the profile
needs neither.

### 2.2 Layout (DOS file, DOS listing)

All offsets are from the start of the file; words are little-endian.

| Offset | Width | Field |
|---|---|---|
| 0 | u16 | Font count N (9). Valid font numbers are 1..N (G:0000:1172: `n <= N`, `n != 0`). |
| 2n, n = 1..N | u16 | P(n): offset of font n's glyph bitmap. |
| P - 8 - k .. P - 9 | k bytes | Width table, one byte per code first..last, present only when the fixed advance is 0 (k = last - first + 1). |
| P - 8 | u8 | First code |
| P - 7 | u8 | Last code |
| P - 6 | u8 | Bytes per glyph row (1 or 2) |
| P - 5 | u8 | Fixed advance (0 = proportional: use the width table) |
| P - 4 | u8 | Height (rows drawn in the normal case) |
| P - 3 | u8 | Spacing (added to every advance) |
| P - 2 | u8 | Extra rows (stored below the glyph, drawn only in opaque mode) |
| P - 1 | u8 | Not read by any routine found (0 in all fonts) |
| P .. | k x bytes-per-row x (height + extra) | Bitmap, row-major across all glyphs: row r of glyph i is at P + r * k * bytes-per-row + i * bytes-per-row. |

The 9 fonts tile the file with no gap except one padding byte between fonts 4 and 5; font 1
starts right after the offset table and font 9 ends at the end of the file (DOS file,
`fontcv.py check`).

| Font | Codes | Bytes/row | Height + extra | Spacing | Advance |
|---|---|---|---|---|---|
| 1 | 20h..7Fh | 1 | 7 + 1 | 1 | widths 1..9 |
| 2 | 20h..7Fh | 1 | 5 + 1 | 1 | widths 3..7 |
| 3 | 20h..7Fh | 2 | 10 + 1 | 1 | widths 1..14 |
| 4 | 20h..7Ah | 2 | 16 + 1 | 1 | widths 0..16 |
| 5 | 20h..7Dh | 2 | 16 + 1 | 1 | widths 0..16 |
| 6 | 20h..7Fh | 2 | 14 + 1 | 1 | widths 2..16 |
| 7 | 20h..7Fh | 2 | 8 + 1 | 1 | widths 1..7 |
| 8 | 20h..7Fh | 2 | 9 + 1 | 1 | widths 1..12 |
| 9 | 20h..7Eh | 2 | 9 + 1 | 1 | widths 1..12 |

All fonts are proportional (fixed advance 0). The extra row carries no ink in any glyph (DOS file).

### 2.3 Glyph drawing (DOS listing, G:0000:0FAC)

* A glyph row is read as a 16-bit word with its bytes swapped (`xchg bl, bh`): bit 7 of the first
  byte is the leftmost pixel, then the rest of that byte, then the second byte. The routine always
  reads a word, so in a 1-byte-per-row font a glyph wider than 8 takes its 9th column from the next
  glyph's byte (font 1 code 5Fh has width 9; the borrowed column is blank in every row, DOS file).
  Columns past 16 are blank.
* The width drawn is the advance (width + spacing); for every glyph but the last of a string the
  spacing columns are skipped in transparent mode.
* Mode: the low byte of context word +0Ah. The opaque path is taken only when it **equals 1**
  (stored at G:0000:0FC4, tested `cmp [060Eh], 1` at G:0000:103D): 1 bits in the text colour,
  0 bits in the background colour (context +0Eh), plain stores, over width + spacing columns.
  Any other value is transparent: only 1 bits are drawn, with the raster operation below, over
  the width (width + spacing for the last glyph). Separately, bit 0 of the same byte adds the
  extra rows to the drawn height (G:0000:1367..136D), so a value with bit 0 set other than 1
  draws the extra rows transparently. R:0182:005C and R:0182:00B3 clear the byte for their call
  and set it back to 1 afterwards.
* Raster operation (transparent path only): bits 0..1 of the colour word's high byte (context
  +0Dh) select, through G:0000:020C and the four-entry opcode table at G:0000:0208, the store
  instruction patched in at G:0000:105D: store, AND, OR or XOR with the text colour.
* Clipping: right edge context +06h, left edge 0, top 0 and bottom context +08h, in G:0000:125C,
  1208 and 12BE ([DRIVER.md](DRIVER.md) G#21 gives the rules).
* String bytes: 0 ends the string; a byte 80h or above sets the foreground colour to `byte & 7Fh`
  and draws nothing (G:0000:0F9C); a code outside first..last is skipped without advancing. The
  final colour is written back to the context (+0Ch).

### 2.4 Failure behaviour (DOS listing)

| Case | Behaviour |
|---|---|
| `FONTS.CV` cannot be opened, read or closed | R:0000:0BDB: prints a hex digit made from AL (the DOS error code on these paths), the prefix at DGROUP:540E and the message at DGROUP:5463, and exits with code 99h (INT 21h AX=4C99h). |
| File larger than the free block | Message at DGROUP:54B9, exit 99h (R:0000:0AFD..0B0A). |
| Font number 0 or above N | Advance 0, line height 0, nothing drawn. |
| Bad header values | Not checked (bytes per row other than 1 or 2 would mis-stride; unknown). |

Confidence: high (layout tiles the file exactly; glyph sheets look right by eye).

## 3. Texts (`*.TXT`)

Thirteen texts are shipped. All end with a ^Z byte and use CR LF lines (DOS file). The C run time
of `CIV.EXE` is Microsoft C (DOS listing); routines below are named by their call pattern
(inferred): R:2045:0698 `fopen`, 08B6 `fscanf`, 059C `fclose`, 2144 `fseek`, 06C4 `fread`, 08D6
`fwrite`, 23FC `ftell`, 28F0 `strcmp`, 29AC `strstr`, 1E22 `strcat`, 1E62 `strcpy`, 1E94
`strlen`, 17E2 `open`, 1A64 `write`, 1748 `close`.

Line reading everywhere is `fscanf(f, "%[^\n]\n", buffer)` on a stream opened `"rt"`. General MS
C knowledge (inferred): text mode turns CR LF into LF and treats ^Z as the end of the file; the
`\n` directive skips all white space, so blank lines and the next line's leading blanks are
skipped; at the end of file `fscanf` returns -1 and leaves the buffer unchanged.

### 3.1 Roles (DOS listing)

| File | Reader | Role |
|---|---|---|
| `INTRO.TXT` | O1:0000 (opens at O1:0037) | Start-up set-up screen in text mode (video mode 3 set at O1:0008..0017): lines 1..10 (a box drawn with CP437 characters) written by R:0199:00A1, then line 11 above the graphics-driver menu and line 12 above the sound menu. Before display the program writes two bytes into line 3 at columns 54..55 (O1:005D..0069; inferred: a version digit). The file's 13th line is never read. |
| `INTRO3.TXT` | none | Named nowhere in `CIV.EXE`, its overlays or the drivers. Differs from `INTRO.TXT` in one byte of line 3 (DOS file). |
| `CREDITS.TXT` | O2:0000, opened at O2:0329; one line per call to O2:19A3 | The 24 credit lines of the opening, read at fixed scroll positions (11 at O2:0536..05FF, 13 at O2:08AA..0995) and drawn centred with font 5 (set at O2:052C) by R:0182:00B3. Closed at O2:14B5. |
| `STORY.TXT` | O7:17CF (opens at O7:1869, reads at O7:18FF) | The creation story: each line is drawn centred with font 7; a line of 3 characters or fewer (O7:19A6) instead loads the next `birth<n>.pic`, n counting from 1 (DGROUP:3B64); end of file (-1) ends the story (O7:190D). |
| `KING.TXT` | R:1F4D:044F (most callers), O2:0BD7 (at O2:0E70), O2:152A (at O2:1645), O21:0000 (at O21:03BD) | Section file (3.2). |
| `HELP.TXT` | O4:0000 (at O4:003B), O4:02D3 (at O4:02FA) | Section file. |
| `ERROR.TXT` | O4:03AA (at O4:03C9) | Section file. |
| `PRODUCE.TXT` | R:0ADE:0421 (at R:0ADE:1344 and 13E3) | Section file. |
| `BLURB0..4.TXT` | O8:062A (at O8:0855 and O8:08BF) | Section files; the digit of `blurb0.txt` (DGROUP:3FA9) is set to `'0' + ` the second argument of O8:062A (O8:0632..0637). |
| `REPLAY.TXT` | O9:0000 (at O9:004A) | Not read: created and written. O9 opens it with flags 8301h and mode 80h (inferred, MS C: write-only, create, truncate, binary) when its menu (DGROUP:3FB0, four items) returns 3, writes with R:2045:1A64 and closes at O9:088C; a "File Error" box on failure. Not in the release. |

### 3.2 Section files: layout (DOS file, DOS listing)

`KING`, `HELP`, `ERROR`, `PRODUCE` and `BLURB0..4`:

| Offset | Size | Content |
|---|---|---|
| 0 | 528 | Index area: 8 lines of 64 bytes and CR LF. Each line holds 32 little-endian word slots; a slot is ASCII `00` (empty) or a binary file offset written by the game. |
| 528 | 2 | CR LF (a blank line); `BLURB3` has one more. |
| 530 | to ^Z | CR LF lines. A line starting with `*` names a section; the rest of the line (after `*`) is the name, matched with `*` included. Consecutive `*` lines name one shared text. A text is the lines after its name lines up to the next `*` line. Each file ends with a `*` line that has no text (an end marker); `KING` has two. |

Bytes inside the index can take any value (offsets), including CR, LF, bytes 80h and above and
1Ah (`KING` at 425, `BLURB2` at 453). The text part has no bare CR or LF, no 1Ah before the final
^Z and no byte 80h or above (DOS file).

### 3.3 Section lookup (DOS listing, R:1F4D:01AD `(file, name)`)

1. **Hash.** h = sum over i of `name[i] * i` (bytes sign-extended, 16-bit sum, R:1F4D:01C5..01E8),
   then the high byte is cleared (R:1F4D:01EA): h is 0..255.
2. **Probe.** Open the file `"rb"`, seek to `2 * (h + h / 32)` and read one word (R:1F4D:01EF..
   024B). Since h / 32 is the template line number, this is word `h % 32` of line `h / 32`: the
   CR LF word of each line is never probed. Reopen `"rt"`.
3. If the word is above 1FFh and not 3030h (`00`): seek to it, read one line, compare with the
   name (R:1F4D:0266..02B1). Equal: found. Different: h = (h + 1) & FFh and go to step 2
   (R:1F4D:0392..03AC).
4. Otherwise (empty slot): seek to 0200h and read lines, taking `ftell` before each, until a line
   equals the name or the file ends (R:1F4D:02CC..0321).
5. **Text.** Skip further `*` lines; then append each line and one space to the buffer at
   DGROUP:BA06 until a line starts with `*` (R:1F4D:032D..0388). The caller clears BA06 first.
   Returns the number of text lines, or -1 if the name was not found.
6. **Cache write.** If the name was found by step 4, reopen the file `"r+b"`, seek to the probed
   slot and write the `ftell` value there (R:1F4D:03C1..0437). The DOS program writes into these
   text files.

After the lookup, callers may run:

* R:1F4D:0471: replaces every occurrence of five tokens (pointers at DGROUP:30AE: `$US`, `$THEM`,
  `$BUCKS`, `$RPLC1`, `$RPLC2`) with the 22-byte strings at DGROUP:3037, 304D, 3063, 3079, 308F,
  which the game fills. `$BUCKS0` in `KING` is `$BUCKS` followed by a digit.
* R:1F4D:0000 `(columns)`, over the buffer at DGROUP:BA06 with a column count: a `^` becomes a
  space and the following byte a line feed, unconditionally (R:1F4D:001C..0021: a forced line
  break; in practice the byte after `^` is the joining space); a line feed restarts the count;
  otherwise a space becomes a line feed only when the count has passed `columns` **and the next
  byte is not a space** (R:1F4D:0042..0050). At the end it appends a line feed (the one-byte
  string at DGROUP:2FEE) when the last line is not empty (R:1F4D:006E..007C). The callers' line
  counts depend on both rules. R:1F4D:044F uses 80 (50h).
* R:1F4D:0088 `(width in characters, x, y, colour)`: draws the buffer in the current font,
  breaking at `^` or a line feed or before a word that would pass `width * 8` pixels, advancing
  `y` by the line height (slot 12) and stopping below y = C0h. Returns the new `y`.

### 3.4 Section files: contents and index state (DOS file, `texts.py check`)

"Index" counts slots holding the offset of a name line, stale offsets, and empty `00` slots
(the other 7 used slots are the template's CR LF words). "Not cached" counts names that an
unchanged file finds only by the step-4 scan.

| File | Bytes | Name lines | Texts | Shared-name groups | Text lines | `^` | `$` | Index: names / stale / empty | Not cached |
|---|---|---|---|---|---|---|---|---|---|
| KING | 8535 | 62 | 60 | 1 | 243 | 214 | 61 | 58 / 2 / 196 | 4 |
| HELP | 5255 | 19 | 18 | 0 | 117 | 108 | 4 | 18 / 0 / 238 | 1 |
| ERROR | 1823 | 13 | 12 | 0 | 31 | 30 | 0 | 9 / 3 / 244 | 4 |
| PRODUCE | 2199 | 52 | 20 | 11 | 40 | 24 | 20 | 50 / 1 / 205 | 2 |
| BLURB0 | 40701 | 69 | 68 | 0 | 532 | 0 | 0 | 67 / 0 / 189 | 1 |
| BLURB1 | 30036 | 91 | 90 | 0 | 399 | 0 | 0 | 89 / 1 / 166 | 2 |
| BLURB2 | 17847 | 57 | 56 | 0 | 241 | 0 | 0 | 55 / 1 / 200 | 2 |
| BLURB3 | 541 | 1 | 0 | 0 | 0 | 0 | 0 | 0 / 0 / 256 | 1 |
| BLURB4 | 16232 | 43 | 42 | 0 | 229 | 0 | 0 | 41 / 1 / 214 | 2 |

* Every name is found by the simulation of 3.3 at its own name line, except one name that occurs
  twice in `BLURB0`: both paths find the first, so the second text is unreachable.
* The longest text line is 88 bytes (`BLURB4`); the line buffer of R:1F4D:01AD is 256 bytes.
* Every name before the file's last 512-byte block (counted from 0200h, the scan's buffer
  blocks) is cached in the index; no name inside that block is (the end markers and 9 other
  names). Nine stale entries exist, one on the probe path of each of those 9 names, 8 holding the
  name line's offset plus 1 and one (`BLURB4`) minus 1. Inferred: the game cached every looked-up name, and `ftell` in text mode is off by one in the
  last buffer of the file (MS C run time behaviour at the final ^Z; mechanism not proved). Effect
  on the DOS program: those names are always found by the scan, and each such lookup writes one
  more stale entry into the next empty slot (unknown whether this ever fills the index; a full
  index would make step 3 loop forever).

### 3.5 Line files: structure (DOS file)

| File | Bytes | CR LF lines | Records read by `fscanf` | Notes |
|---|---|---|---|---|
| INTRO | 965 | 13 | 13 (12 used) | 172 bytes are CP437 box characters (C9h, CDh, BBh, BAh, C8h, BCh); line 13 is one character. |
| INTRO3 | 965 | 13 | (not read) | One byte differs from INTRO, in line 3. |
| CREDITS | 401 | 24 | 24 | Longest 25 characters. |
| STORY | 1333 | 56 | 52 | 4 blank lines are skipped; 8 records are one character long (the picture changes to BIRTH1..BIRTH8); longest 43. |

`CREDITS.TXT` writes `%` (25h) where a full stop is shown. The credits are drawn unchanged
(O2:19A3 → R:0182:00B3 → slot 21, no translation in between) with font 5, whose glyph for 25h is
a small dot (3 wide; five pixels in a 3 x 3 plus shape on rows 12..14 of the 16), while its
codes 28h..2Eh (widths 16, 16, 16, 4, 16, 16, 14) hold the pieces of two decorative graphics: a
lettered banner (28h..2Bh) and a winged emblem (2Ch..2Eh). So `%` is a full stop in font 5 only
(DOS file, DOS listing; high confidence).

### 3.6 Failure behaviour (DOS listing)

| Case | Behaviour |
|---|---|
| File missing | No reader checks the `fopen` result (O1:003F, O2:0331, O7:1871, R:1F4D:01FE, 025F): the NULL stream is passed on (unknown result). |
| Section not found | R:1F4D:01AD returns -1; callers test it (for example O8:085D). |
| Section text not followed by a `*` line | The text loop never ends (`fscanf` at end of file keeps the last line); every shipped file ends with an end marker. |
| End of file in INTRO or CREDITS | Not tested: the buffer keeps the previous line. STORY tests for -1. |
| Index cache write fails | Not tested (R:1F4D:03D6..0437). |

Confidence: high for roles, layouts and the lookup (the hash reproduces every cached slot); medium
for the stale-entry mechanism (pattern is DOS file, cause inferred).

## 4. Mouse pointer

| Fact | Evidence |
|---|---|
| The pointer is a software sprite drawn by the graphics driver. INT 33h is called with functions 0 (reset), 0Ch (event handler), 3 (position) and 4 (set position); no call with function 1 (show the mouse driver's cursor) was found. R:0000:1766 passes its argument as the function but has no known caller (prologue scan). | DOS listing, R:0000:163E..17CB |
| Its shape is `TORCH.PIC` (X1, 13 x 14), loaded at start-up into the driver's sprite store by R:1FA1:044C (R:01A8:010B); the sprite's segment is kept in DGROUP:6E92. Mode 0 is used, so the picture's own `M0` palette is not applied: the pointer is drawn with the current palette. | DOS listing |
| Hot spot (0, 0): R:01A8:0139 calls R:0000:1697 `(hot x, hot y, shape)` with 0, 0 (DGROUP:5878, 587A, 5876). Every other call of R:0000:1697 also passes 0, 0; the six calls in the listing are R:01A8:0139, R:01A8:0891, R:0403:046B, 095B, 0AEC and 10AB. R:0000:1697 only stores the three values; the new shape appears at the next pointer draw. | DOS listing |
| Colour 0 is transparent: the sprite store drops leading and trailing 0 bytes of each row (G:0000:0AE3) and the blit skips inner 0 bytes (G:0000:0DE1). Row 0 and column 0 of `TORCH.PIC` are all 0, so the first visible pixel is at (1, 1) from the hot spot; the torch uses indices 4, 5, 7, 12, 14 and 15. | DOS listing, DOS file |
| Drawing: slot 30 (G:0000:0270) at (mouse x - hot x, mouse y - hot y), clipped to 320 x 200, saving the area below into a 512-byte buffer (height limited to 512 / width, G:0000:02B4) through G:0000:030E; slot 15 (G:0000:0224) restores it. R:0000:16DB shows, R:0000:170B hides, R:0000:179A moves (through the guard R:0000:0732). | DOS listing |
| Movement: the INT 33h event handler at R:0000:17DB (installed with mask 1Fh at R:0000:1656..1664; own disassembly) stores the buttons and position (x shifted right by DGROUP:587C), calls an optional user hook (DGROUP:587E) and redraws the pointer on movement when it is shown. DGROUP:587C is the high byte of the x position the mouse driver reports right after reset (R:0000:166B..1671). Inferred: 1 when the driver reports x as 0..639 in mode 13h (centre 320), so x becomes 0..319. | DOS listing, inferred |
| The pointer exists only when a mouse driver answers INT 33h function 0 and the set-up screen choice "Mouse and Keyboard" was taken (DGROUP:1A3C, O1:03DA; R:01A8:011B..0145). | DOS listing |
| Only two pointer shapes exist: the torch (`TORCH.PIC`, DGROUP:6E92, copied to D4CE[7] = DGROUP:D4DC at O5:1891..1894) and the "GO" arrow D4CE[2] (a 16 x 16 cell of page 1 at (32, 32), cut by slot 2 in the loop O5:185D..188F; page 1 holds `SP257.PIC` with the VGA driver, [SPRITES.md](SPRITES.md) 6.3). In play (R:0403, the unit loop) the pointer is the torch, except while the local flag [bp-36h] is set: the dispatch case reached from R:0403:1B27 (dispatch value 67h in [bp-44h], tested at R:0403:1AED..1B27) toggles the flag (R:0403:10B3) and, with a mouse (DGROUP:1A3C not 0), sets the arrow when the flag was 0 and the torch when it was 1 (R:0403:108B..10AB, hot spot 0, 0). A mouse click (DGROUP:DB3A = 1) while the flag is set takes the map square in [bp-1Ch]/[bp-26h], stores it into the active unit's record (DGROUP:81DA/81DB + 600h·civ + 0Ch·unit) when the unit's domain allows that square, then clears the flag and restores the torch (R:0403:09D9..0AEC); R:0403:0456..046B and 094A..095B also clear it and restore the torch. Without a mouse the same case instead starts (flag 0: the unit's square copied to [bp-0Eh]/[bp-12h]) or ends (flag 1: that square redrawn by R:1AEA:11D4) a keyboard-driven square selection, also toggling the flag (R:0403:1007..1088; not traced further). The dispatch value is read by R:1D05:0AC9 (the key read, R:0403:0676) or taken from DGROUP:D4CA, R:15FB:0C9D or R:1E31:000E; as a key, 67h is `g`. **DOS listing**; the reading as the GoTo command (key `g`, then a click on the destination) is **inferred**. No other R:0403 code selects a pointer shape: D4CE[0], [1] are empty and [3..6] are map overlays, not pointers. | DOS listing, inferred |

## 5. Prompt facts verified or corrected

| Prompt fact (section 3) | Result |
|---|---|
| A picture is a sequence of chunks, each a 2-byte tag and a 16-bit little-endian length. | Verified (DOS file). The reader ends the walk at the first tag whose first byte is `X`. |
| `E0` has length 258: two bytes, then a 256-byte table (inferred: an EGA mapping). | Verified and refined: the two bytes are first and last index (0, 255); each table byte holds two EGA colours (nibbles) read only by EGRAPHIC's slot 28; MGRAPHIC ignores the chunk. |
| `M0` has length 770: a first index, a last index, then 256 x 3 six-bit RGB values. | Verified (all 144 files: first 0, last 255, maximum 63). Refined: the reader sends last - first + 1 triplets from the start of the data to DAC entries first onward. |
| `X0`/`X1`: a 16-bit width, a 16-bit height, then the byte 11 (inferred: the maximum LZW code width), then compressed data. | Verified with a correction of order: tag, length word, width, height, then the byte. The byte is the maximum code width (R:0000:125F clamps it to 11). Added: X0 = 8-bit pixels, X1 = 4-bit pixels (low nibble first); an RLE stage (90h) follows the LZW stage. |
| Most pictures are 320x200; exceptions CBACKS1..3 320x65, CBRUSH0..5 182x95 or 136x95, SLAG2 and SLAM2 197x67, TORCH 13x14. | Verified (CBRUSH0, 2, 4 are 182x95; 1, 3, 5 are 136x95). |
| `SPRITES.PIC` has only an `X1` chunk; SP257, TER257, KING03, KINK00, KINK03, MAP, SLAG2, SLAM2, TORCH have no `E0`; KINK00, KINK03, MAP, TORCH use `X1`. | Verified. All pictures except `SPRITES.PIC` have an `M0` chunk. |
| 106 `*.PIC` and 38 `*.PAL`. | Verified. |
| `*.PAL`: 782 bytes, an `M0` chunk and an empty `X0` chunk (length 4, 0x0). | Verified. |
| `FONTS.CV` starts with the word 9, then nine words 007Ch, 03E4h, ... (inferred: a font count and offsets). | Verified and refined: count, then the offset of each font's glyph bitmap (fonts numbered 1..9); an 8-byte header and the width table precede each bitmap (2.2). |
| All 13 `*.TXT` end with ^Z; text parts use CR LF lines. | Verified. |
| BLURB0..4, ERROR, HELP, KING, PRODUCE begin with a binary prefix; the first `*` is at 530 in most, at 23 in BLURB4; the prefix has bytes >= 80h, bare CR and LF, an early 1Ah (KING 425, BLURB2 453); inferred: an index. | Corrected: all nine have the same 528-byte index area, a hash-table cache of section offsets that the game itself fills (3.2, 3.3). The first section line is at 530 in eight files and 532 in BLURB3. The `*` at 23 in BLURB4 is the high byte (2Ah) of a cached offset, not text. The listed bytes are bytes of the cached offsets. |
| `INTRO.TXT` uses CP437 box characters. | Verified; it is shown in text mode 3 before the graphics driver loads. |
| `CREDITS.TXT` contains `L%` (inferred: the DOS character set's code for a full stop; the listing decides). | Corrected: it is not a character-set code. `%` is drawn unchanged with font 5, whose 25h glyph is a small dot because `.` (2Eh) and its neighbours 28h..2Dh hold two decorative graphics (3.5). |
| The 13 texts include `INTRO3`. | Verified present; no reader exists (3.1). `REPLAY.TXT`, named in the program, is an output file and is not shipped. |

## 6. Data tables and code constants the profile reads

Added 2026-10-11 for review finding R2-7. Prompt 5.9 requires every DOS data table the profile
needs to be read from the DOS image at recorded offsets. Most of the profile's parameters are not
tables: they are immediates inside code. This section keeps the two apart and names the third
kind, run-time storage, which is never read from the image. Widths and counts are given where a
document or a check establishes them; "not established" means no D0 document records them.

**Where image data can be.** The root's load module ends at R:2B01:6B30 (DOS file), so DGROUP's
initialised data is DGROUP:0000..6B2F; every DGROUP address at 6B30h or above (B886, BA06,
D4CE, E17E, ...) is storage the program fills at run time (inferred: the MS C uninitialised
segment). Far data tables lie in the root image between the code and DGROUP (R:2604..R:2772,
EXECUTABLE.md 4). Driver data is in `MGRAPHIC.EXE` (data segment 013Ch, DRIVER.md 3.5).

### 6.1 Data tables at image offsets

| Item | Address | Width x count | Label | Described in |
|---|---|---|---|---|
| Default palette | MGRAPHIC data:0050..01CF | 128 RGB triples, 6-bit | DOS file | PALETTE 2.1; DRIVER 3.5 |
| Low-16 colour map | DGROUP:19FE | 16 map bytes + 1 border byte (identity except entry 5) | DOS file | PALETTE 2.1; SCENES 4.1 |
| Birth cycling table | R:2710:0000..0082 (segment also in DGROUP:6416, relocated 2710h) | 41 byte triples (lo, hi, speed) in 8 zero-terminated groups, 131 bytes | DOS file | PALETTE 2.6, 4; TIMING 5.5 |
| Birth schedule | R:2710:0083..00DC | 45 words, the last FFFFh | DOS file | TIMING 5.5 |
| Civilization colours | DGROUP:1946 (main), DGROUP:1956 (secondary) | 8 words each, values 0..15 | DOS file | SPRITES 6.4; SCENES-PLAY 2.3 |
| Direction steps | DGROUP:1882 (x), DGROUP:18E4 (y) | 49 words each (1882..18E3, 18E4..1945); entries 0..8 hold −1..1 (centre and the 8 directions, 1 N clockwise to 8 NW), entries 9.. larger steps whose users are not described here | DOS file | SPRITES 6.1 |
| Terrain names | DGROUP:0282 + 13h·t | 19-byte records, t 0..11 used (record 12 also holds a name) | DOS file | SPRITES 4 |
| Unit table | DGROUP:112A + 22h·j | 34-byte records, j 0..27: name at +0, domain word at +0Eh (DGROUP:1138: 0 land, 1 air, 2 sea; 16, 3, 9 types), moves word at +10h (DGROUP:113A); other fields SCENES-PLAY 5.3, 7.19 | DOS file, DOS listing | SPRITES 6.4; SCENES-PLAY 5.3, 7.19 |
| Civilization adjectives | DGROUP:1982 + 2·civ | one word per civilization (R:0238:079B) | DOS listing | SCENES-PLAY 5.3 |
| Page-2 colour to terrain | DGROUP:2BA6 + 2·colour | words (R:1AEA:1363); count not established | DOS listing | SCENES-PLAY 1.1 |
| Text-box header captions | DGROUP:2FA6 + 2·n | 7 words, n 0..6; the cabinet titles DGROUP:2FAC are entries 3..6 of the same table | DOS listing | SCENES-PLAY 0.2, 7.10 |
| ICONPG cell tables | R:271E:0000..0047, 0044..005F, 0061..006C (segment in DGROUP:6420, relocated 271Eh) | 72, 28 and 12 bytes searched (the first two ranges overlap) | DOS file, DOS listing | SPRITES 8; SCENES-PLAY 7.13 |
| Wonder rectangles | far table, segment in DGROUP:6444 (relocated 2767h): R:2767:0000.. | 88 words: 22 entries of 8 bytes (four words), entry 0 unused; O19:1606 converts entries 1..21 from edges to sizes when entry 1's third word is above 300; readers O19:097F, 10E2, 160D (the grid's wonder values 40h..55h bound the index to 21). Established 2026-10-17 by unit D7e (decision 9; `../ext-D7e-record.md`; OFFSETS `WONDER_RECTS`) | DOS file (segment), DOS listing | SCENES-PLAY 7.2, Open 8; OFFSETS `WONDER_RECTS` |
| Throne-room animation table | segment in DGROUP:640A (relocated 26FAh): R:26FA:0000.. | both uses (decision 9's correction): LEADER_FONT, its first 16 bytes (bytes, range 0..2; reader O6:1815; draft B 10.1), and the throne-room tables LEADER_FACE_X (u16 x 28 at 10h; readers O6:249F, 24AA), LEADER_FACE_Y (u16 x 28 at 48h; O6:24B2, 24BD), LEADER_ATTEND_X (u16 x 56 at 80h; O6:240D, 2417) and LEADER_ATTEND_Y (u16 x 56 at F0h; O6:2422, 2433): the expressions' and the attendant frames' places by animation style. Established 2026-10-18 by unit D7k (decision 9; `../ext-D7k-record.md`; OFFSETS `LEADER_*`) | DOS file (segment), DOS listing | SCENES-PLAY 7.9, Open 8; OFFSETS `LEADER_FONT`, `LEADER_FACE_X`, `LEADER_FACE_Y`, `LEADER_ATTEND_X`, `LEADER_ATTEND_Y` |
| Spaceship part records | DGROUP:4BD0 | 10 records of 26 bytes (name, mass, rectangle) | DOS file | SCENES-PLAY 7.16 |
| Riot figure offsets | DGROUP:4F42, DGROUP:4F4A | words (O19:1A2D, 1A5C); count not established | DOS listing | SCENES-PLAY 7.3 |
| City-name table | R:2604:0000.. | not established | DOS file | EXECUTABLE 4 |
| Tune and sound fields | DGROUP:1518, 151A + 3Ah·tribe (fields of 58-byte tribe records) | words; sound is out of scope | DOS listing | TIMING 5.7; SCENES-PLAY Open 11 |
| Section-text tokens | DGROUP:30AE | 5 word pointers to the token names; the line-feed string DGROUP:2FEE | DOS listing | 3.3 |
| Strings the scenes draw | DGROUP, at the addresses the scene documents give: for example the title menu DGROUP:1AE2, the setup headers DGROUP:3526..35CE, the menu-bar titles DGROUP:1D6F..1D8E, the menu-box help line and OK DGROUP:2FBD, 2FCE, and the drop-down menu strings of SCENES 10.2 (the ORDERS item list is built at run time, DGROUP:2D05..2D91) | zero-terminated strings or word pointer tables | DOS file | SCENES 2..10; SCENES-PLAY 5, 7; DOS-PROFILE 3.4 |
| File names | DGROUP (FORMATS 1.1, 3.1; PALETTE 2.5, 7): the `.PIC`, `.PAL` and `.TXT` names, including names patched at run time | strings | DOS listing | 1.1, 3.1 |
| Font file | `FONTS.CV`, loaded at MGRAPHIC data:0630 | count, 9 offsets, 8-byte headers, width tables, bitmaps | DOS file | 2 |
| Raster opcode table | G:0000:0208 | 4 opcode bytes (store, AND, OR, XOR) | DOS listing | 2.3; DRIVER 3.5 |
| Row address table | MGRAPHIC data:0416..05A5 | 200 words | DOS file | DRIVER 3.1, 3.5 |
| Initial values read as parameters | DGROUP:005E (7, the 7-frame divider), 3B62 (0) and 3B64 (1, the Birth digit), 68F8 (0, the LZW previous code), 0000 (0, G#28's null block) | words | DOS file | TIMING 2.5, 5.5; 1.3; DRIVER G#28 |

The texts (`*.TXT`), pictures and palettes are files, not image tables (sections 1..3).

### 6.2 Constants inside code

These are immediates or immediate formulas in instructions; the documents give the formula and
the instruction range, not the offset of each immediate. The prompt's rule ("read from the DOS
image at recorded offsets", 5.9) cannot be met for them without per-immediate offsets, which D0
does not record. How the profile obtains them (per-immediate offsets read from the image, or
another recorded rule) is a D1 decision (OPEN.md, P group).

| Family | Instruction range | Described in |
|---|---|---|
| Sprite rectangles of the cutter O5:1455 (SP299 portraits, terrain T[t][m], coast quarters, river mouths, roads, railroads, rivers, palace strips, unexplored edges, D4CE icons, 7x7 icons, citizens, specials, sparks, markers, newspaper edge, unit cells and recolouring, GOVT portraits) | O5:1484..1AE8, one range per family; GOVT O5:1AF6..1B84 | SPRITES 2..6 |
| Page-2 rectangles copied with G#20 (whole-square coasts, land base, panel textures, border tiles, world-map tiles, building icons, bulbs, discs, advisor portraits) | R:1AEA:03BA, 07B2..07CD; R:0D12:7045, 710D; R:1DC4:03CE; R:0866:260E; O12:0330..0359; R:0238:11F6..1280; R:1D05:05ED..0753 | SPRITES 7 |
| ICONPG grids, file letters and digits | O8:073B..07AF, 09FF..0A5C, 0AD3..0B62; R:0ADE:18EC..1931; O16:0191..01CE | SPRITES 8 |
| Cycling slots, ranges and rates (intro, logo, map, space sequence, spaceship, city view) and the Birth rate rule | O2:02F4..031A, 0AA0..0AAC; R:1DC4:05DD; O2:12B1..1329; O18:00E0..0140; O19:0ED8..0EE4; O7:1AF0..1B27 | PALETTE 4; TIMING 5.6 |
| Fade call sites and step counts | the 13 sites of PALETTE 3 | PALETTE 3; TIMING 5.8 |
| Palette splices, single DAC entries and colours (entries 128..255, 0..84, 64..143, 0..15 from 6B34, entry 45, DAC 253) | R:0238:1C6A..1C86; R:0ADE:1970..198C; O6:22CA..22E4; O9:1228..1242; R:1DC4:049A..04D2; O8:0687..0696, 0B13..0B1D; O19:1694..1698 | PALETTE 2.5, 3 |
| Fade engine and DAC writer constants (6 frames per step, `E` = min(256, `M`/14), groups of 10, 13·k) | R:0000:050C..0631; G:0000:01A1..01EB | PALETTE 2.1, 2.3; TIMING 3.5, 3.7 |
| Scene layouts: positions, sizes, colours, fonts, wait lengths and key handling of the start-up and UI scenes | the ranges per scene in SCENES 2..10 (for example O2:0522..0995 credits, O2:0A19..0B8B logo, R:01A8:0486 title menu, O5:0031..07BD setup, R:1D05:0031..0A66 menu boxes) | SCENES; TIMING 5 |
| Play-screen layouts and animations (map squares, units, cities, minimap, status and unit panels, blink, move animation, menus) and the full-screen scenes | the ranges per item in SCENES-PLAY 1..7 | SCENES-PLAY |
| Timer constants (PIT divisors, 20-frame resync, the 6-of-7 tick) and every `wait(n)` | R:0000:0023..02EA, 0345; the sites of TIMING 5.8 | TIMING 2, 3, 5 |
| Decoder and text constants (512-byte reader, code width 9..11, 90h, the section hash, 80 columns, the stop at y C0h) | R:1FA1:05E0..0644; R:0000:1227..13C5; R:1F4D:0000..0437 | 1.3; 3.3 |
| Glyph mode and raster selection | G:0000:0FAC..10A6, 1328..1390 | 2.3; DRIVER G#21 |
| Pointer hot spot (0, 0), shapes, mouse mask 1Fh, x shift, 512-byte save-under | R:01A8:0139, 0891; R:0403:046B..10B3; R:0000:1656..1671; G:0000:02B4 | 4; DRIVER G#15, G#30 |
| Dissolve constants (8800 / duration, feedback mask B400h) | G:0000:06B7..07A4 | DRIVER G#10; TIMING 3.7 |
| Tables inside code segments (not data segments): the R:0403 report dispatch R:0403:3B7D..3BFF, the replay event table at O9:080C (partly read) | as given | SCENES-PLAY 6.3, Open 8 |

### 6.3 Run-time storage (filled by code; never read from the image)

| Kind | Addresses | Described in |
|---|---|---|
| Shape handles from the cutter | DGROUP:DF62, B886, D294, D2D4, B27A, B29A, B2BA, 6DFE, 6E1E, 7EEC, B880, D21C, D244, D26C, D4CE..D54E + 2(32c + j), 6E92, 6E96, DF0C | SPRITES 3..6 |
| Palette buffers and state | DGROUP:BA06 (also the LZW dictionary BA06..D205 and the text buffer), BD06, C006, BDEE, C1D6, C5BE, 6B34; fade state 0060..006C; cycling records R:25CF (zero in the file); map-cycle state 2FEC | PALETTE 2.3, 2.4, 2.6 |
| Picture reader state | DGROUP:E17E, D936, B26E, 5528, D91A, 68E2..68FA, 552A | 1.1, 1.3 |
| Pointer, mouse and timer state | DGROUP:5402..5406, 586E..5880, DB3A..DB3E, DEEA, 0042..005E | 4; DRIVER 1.5; TIMING 3.1 |
| Text tokens filled by the game | DGROUP:3037, 304D, 3063, 3079, 308F (22 bytes each) | 3.3 |
| Drawing ports and their pointers | DGROUP:0098, 19C2, 19D6, 19EA; 00AA, 19D4, 19E8, 19FC | SCENES 0.1 |
| Driver run-time areas | MGRAPHIC data:01D0..0215, 05B0..05BF (page segments, set by G#25 over the file's initial words), 060C..0625 (text state); the slot table R:0000:076D.. (far pointers zero in the file) | DRIVER 1.4, 3.5 |
| Game state the scenes read (cities, units, labels, viewport, flags) | DGROUP:70EC.., 81D4.., and the variables listed per scene | SCENES-PLAY |

## Open

1. **Archive lookup.** R:1FA1:0728 can serve picture files from an archive (24-byte directory
   entries, 12-byte names compared by R:2045:2932) when DGROUP:552A holds a handle; only
   R:1FA1:06C8 sets it, and no caller of R:1FA1:06C8 was found (prologue scan only). Unknown
   whether any build path uses it; the release has no archive file.
2. **Unreferenced loaders.** R:1FA1:023A, 02A2, 02E6, 04D2, 0536, 05A0 and R:0000:11A6/11EE were
   found only by the prologue scan; they may be reached through pointers the listing does not
   resolve. 02A2/05A0 decode a headerless LZW stream (first word: X1 flag, second word: byte count)
   and depend on the width and height left by the previous picture (R:0000:1227); unknown use.
3. **Stale cache entries in section files.** The off-by-one `ftell` cause (3.4) is inferred; the
   one entry at -1 in `BLURB4` is not explained. Whether the DOS game, run long enough, fills a
   section file's index and then hangs is unknown. The port must never write the DOS files.
4. **DAC pacing.** Closed 2026-10-11 (review finding R2-9): k entries during retrace, then 13·k
   more (1.4; PALETTE.md 2.1; TIMING.md 3.7).
5. **Odd-width rows.** The 198th byte copied per SLAG2/SLAM2 row (1.4) is byte 197 of the row
   buffer DGROUP:E17E, left by an earlier, wider row; where these pictures are drawn and whether
   that column shows is not checked (OPEN.md O7). Drawing only `width` pixels, with a register
   entry, unless the scene shows that column, is a D1 decision (OPEN.md, P group).
6. **Missing files.** Behaviour of the text readers when `fopen` fails (NULL stream) is unknown.
7. **Byte P - 1 of a font header** is read by no routine found; its meaning is unknown (0 in
   all fonts).
8. **INTRO line 3 patch.** The two bytes written at O1:0064..0069 and why `INTRO3.TXT` exists
   (a second edition of the same screen) are not explained.
9. **Pointer selection.** Narrowed 2026-10-11 (review finding R2-1): the only pointer shapes are
   the torch and the GO arrow, and the flag that selects the arrow is toggled by dispatch value
   67h at R:0403:1B27 and cleared by a map click (section 4). Open: the game situation of that
   case, read here as the GoTo command (`g`, then a click), is inferred from the key code and
   the unit-record write, not traced through the callers of R:0403's dispatch.

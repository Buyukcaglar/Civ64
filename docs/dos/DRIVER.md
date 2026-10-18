# DOS drivers: loading, calling and function contracts (D0 draft, task D0-A)

Draft of extension phase D0 (extension prompt 6 item 3 and section 3, "the role of MISC.EXE").
It records how the DOS `CIV.EXE` loads and calls its graphics driver `MGRAPHIC.EXE` and its
input driver `MISC.EXE`, the driver header, and one contract per driver function. Sound is out of
scope; its slots are only labelled (section 6).

Sources: the hash-pinned DOS files in `build/dosdata` (`docs/dos/dos-hashes.txt`), the listings
in `build/dos/disasm` and my own further decoding of the same files (capstone, scratch under
`build/dos/scratch-d0a`). No DOS program was executed. Revised on 2026-10-11 after review R1 and
the cross-document item R2-3 (fixer F1, `docs/verify/ext-d0-fixes-r1.md`); the listing references
are to the corrected tool's output (EXECUTABLE.md 10), which now decodes the mouse handler and the
DAC writer's loop pieces.

Labels: **DOS file** (read from a DOS file, including bytes I decoded myself; these are marked
"decoded here" where the listing has no instruction), **DOS listing** (read from the listings and
`db.json`), **inferred** (a conclusion drawn from the evidence named with it), **unknown**.
**PC fact** marks general knowledge of the PC platform (VGA registers, DOS and BIOS interrupts,
x86 opcodes, the Microsoft C conventions) where it carries a conclusion. Addresses use the
notation of the brief: `R:ssss:oooo` (root load module), `O<n>:oooo` (overlay), `G:0000:oooo`
(`MGRAPHIC.EXE` load module), `M:0000:oooo` (`MISC.EXE`), `DGROUP:oooo` (R:2B01).

Names such as "CopyRect" are **my naming** (D0-A), chosen from the behaviour shown; they are not
from any DOS source. `G#n` is graphics function n (= slot n), `M#n` is misc function n
(= slot 90 + n), `S#n` sound function n (= slot 100 + n).

## 1. Loading and calling

### 1.1 Who loads what

| Step | Address | What the code does | Label |
|---|---|---|---|
| 1 | R:01A8:0010..0023 | `R:0000:0A76("misc.exe", 0)` (name DGROUP:0267, no data file), then `R:0000:0B70(seg)` | DOS listing |
| 2 | R:01A8:0026 | overlay 1 (`INT 3Fh`, O1:0000): text-mode set-up questions, printed with R:0199:00A1 (row, column, text) and R:0199:00EC. Graphics menu (O1:013B..01AA): for entry i = 0..3, numbered n = 1..4, it copies the letter DGROUP:3244 + i into DGROUP:67E0 + n (O1:0167, 016B) and prints the number and the text named by the pointer table DGROUP:322A + 2i (O1:0173; texts DGROUP:30C2, 30D4, 30E7, 30F8) at row 0Eh + n (O1:0199). It reads a typed character c with M#2 (O1:01C1, O1:0327, O1:03BE) and, for "1" ≤ c ≤ the last number, writes the letter at DGROUP:67B0 + c (= 67E0 + n) into the first byte of the graphics driver name at DGROUP:1A22 (O1:01DD, 01E1). The four entries are VGA, MCGA, EGA and Tandy, with the letters M, M, E and T: VGA and MCGA both select `mgraphic.exe` (DOS file). Sound menu (O1:026C..030D): six entries, letters DGROUP:323E + i into DGROUP:67B2 + n (O1:02A4, 02A8), texts through the pointer table DGROUP:3232 (DGROUP:3110..); the letter at DGROUP:6782 + c goes to the sound driver name at DGROUP:1A30 (O1:0343, 0347). DGROUP:67B0.. is zero in the file (DOS file) and no other listing line names these tables | DOS listing |
| 3 | R:01A8:003B | overlay 2 (O2:0000). O2:00EE..011B only tests the letter at DGROUP:1A22: `m`/`M` sets DGROUP:D762 = 1, `e`/`E` sets DGROUP:B20E = 1 | DOS listing |
| 4 | O2:011E..0134 | `R:0000:0A76(DGROUP:1A22 name, "fonts.cv" DGROUP:3281)`, then `R:0000:0B70(seg)` | DOS listing |
| 5 | O2:0137..014C | `R:0000:0A76(DGROUP:1A30 name, 0)` (sound, default `nsound.cvl`), then `R:0000:0B70(seg)` | DOS listing |
| 6 | O2:0163..01BC | G#37(0) (video mode); then for n = 0 .. k-1, k = 3 when DGROUP:D762 is set (the `m` driver) and 4 otherwise: `seg = G#0(n)`, and when non-zero `G#25(n, seg)`; a zero result sets DGROUP:6DFC = 1 | DOS listing |
| 7 | O2:01BE | S#0, then `R:0000:0000` (timer install), then drawing (G#27, G#18, G#2, G#7, ...) | DOS listing |

Correction to the brief: the driver letter is rewritten in overlay 1 (O1:01E1), not in overlay 2;
overlay 2 only reads it. **DOS listing**

### 1.2 The loader R:0000:0A76 (name, data file name)

Both arguments are near pointers into DGROUP; the second may be 0 (no data file). Returns AX =
the segment the driver was loaded at. **DOS listing**

1. R:0000:0A79: INT 21h AH=48h with BX = FFFFh. This request must fail (**PC fact**: 1 MiB cannot
   be free in real mode; the failing call returns the largest free block in BX). If it succeeds,
   error with the message at DGROUP:5412 ("Allocated 1Mb of space...").
2. R:0000:0A89: BX = largest block − 100h paragraphs (4 KiB are left free), stored in
   DGROUP:540C, and allocated (AH=48h). If that fails, error with DGROUP:542D ("MS-DOS lied to
   us...").
3. R:0000:0A9E: the block segment is stored twice at DGROUP:5408 and 540A, the parameter block of
   INT 21h AX=4B03h (load segment and relocation factor, **PC fact**), and the call is made through
   R:0000:0BBA, which saves SS:SP in its own code segment (R:0000:0BB6/0BB8) around the INT 21h
   and restores them. Failure: AX = 2 → DGROUP:5463 ("Filename not found"), AX = 8 → DGROUP:5476
   ("Not enough memory..."), otherwise DGROUP:5495 ("Overlay load failed..."). The conditional
   jump at R:0000:0ACC follows a failed comparison and is never taken.
4. R:0000:0AD5: ES = load segment; BX = header word 002Ah (relocated) + (header word 002Ch + 15) / 16.
   This is the paragraph right after the driver's data segment (section 2).
5. R:0000:0AEF: if the data file name is not 0, R:0000:0B1E opens it (INT 21h AX=3D00h), reads it in
   8000h-byte pieces at DS:0 starting at segment BX (DS advanced by 800h paragraphs after each full
   piece), closes it and returns BX = the paragraph after the last byte read. Every failure of
   open, read or close reports DGROUP:5463 ("Filename not found").
6. R:0000:0AF9: BX = BX − load segment + 8. If BX exceeds DGROUP:540C, error DGROUP:54B9
   ("Overlay has overrun..."). Else INT 21h AH=4Ah shrinks the block to BX paragraphs (failure:
   DGROUP:54DE, "Unable to shrink..."). The block thus keeps 8 paragraphs after the data file
   (purpose **unknown**).
7. Returns AX = ES = load segment (R:0000:0B1A).

Error path R:0000:0BDB: prints one character made from AL by the `cmp al,0Ah / sbb al,69h / das`
idiom (a hexadecimal digit for AL 0..15, **PC fact**; AL is whatever the failing step left, for
example the DOS error code), then the separator at DGROUP:540E (" - "), then the message at SI,
all with INT 21h AH=09h (the messages are `$`-terminated, **DOS file**), and exits with INT 21h
AX=4C99h (exit code 99h). **DOS listing**

The strings "Allocated 1Mb of space" (DGROUP:5412) and "MS-DOS lied to us" (DGROUP:542D) belong to
this loader: they are the messages of its first two allocation checks (R:0000:0A82 and
R:0000:0A97 load SI with them). **DOS listing**, **DOS file** (DGROUP bytes 540E..5527 hold the
separator and the eight messages). The eighth message, DGROUP:5509 ("Error releasing..."), belongs
to R:0000:0BA1 (free a segment with INT 21h AH=49h), a routine found only by the prologue scan;
no reference to it exists in the root or the overlays (my scan of all relocated far calls,
far-pointer words and near calls). **DOS listing**, **DOS file**

### 1.3 The slot patcher R:0000:0B70 (segment)

DS = the driver's load segment; DI = 076Dh + 7·[002Eh]; ES = R:0000 (relocated 0); CX = [0030h];
AX = [0028h]. For each table word at 0032h, 0034h, ...: DI += 3, store the word (function offset)
and then AX (driver code segment) at ES:DI. So slot i receives the far pointer
`[0028h]:table[i − base]` at R:0000:0770+7i (offset) and 0772+7i (segment). **DOS listing**

### 1.4 The slots

The slot area R:0000:076D..0A75 holds 111 slots of 7 bytes (0..110). In the file every far pointer
is zero (filled at run time). **DOS file** (decoded here)

| Kind | Layout | Callers call | Slots |
|---|---|---|---|
| plain | two filler bytes at 076D+7i, then `jmp far` at 076F+7i | 076F+7i | 0..5, 7, 8, 10..14, 16..21, 23..29, 33..51, 90..97, 100..110 |
| guarded | `call 0732` at 076D+7i, the far pointer at 0770+7i | 076D+7i | **6, 9, 15, 22, 30, 31, 32** |
| empty | all zero | none | 52..89, 98, 99 |

**DOS file** (decoded here from the root load module). Every far call to a slot in the root and
the overlays targets the address in the third column: 410 relocated far calls, checked byte by
byte, 408 of them in the decoded listings. The other two lie outside the decoded code:
R:0000:0C7F (G#39, in the unreferenced routine R:0000:0C72) and R:1DC4:0592 (G#1, in the
unreferenced routine R:1DC4:057A). The only other way into a driver is an indirect
far call through a slot's far pointer: R:0000:17A2 (`es:[07D9]`, slot 15) and R:0000:17C0
(`es:[0842]`, slot 30), with ES = R:0000. My byte scan of the root and all overlays finds no other
`call far [...]` or far-pointer word naming a slot. **DOS file**, **DOS listing**

### 1.5 The guard R:0000:0732, R:0000:179A and the mouse handler

Variables (all DGROUP; the guard has no segment override, so DS must be DGROUP; the mouse handler
sets DS = 2B01h): 5402 (byte, deferred-redraw counter), 5403 (byte, pointer drawn), 5404/5406
(far return address of the guarded caller), 586E/5870 (pointer x, y), 5872 (buttons), 5874
(accumulated buttons), 5876 (pointer shape segment), 5878/587A (hot spot x, y), 587C (x shift).
**DOS listing**

Guard R:0000:0732 (entered by `call 0732` from slot i; the pushed near return address is
0770+7i, the slot's pointer):

* [5403] = 0: pop that address into the operand of the `jmp far cs:[...]` at R:0000:0740 and jump
  far through the slot pointer. The stack is as the caller left it.
* [5403] ≠ 0: [5402] = 1; pop the address into the operand of the `call far cs:[...]` at
  R:0000:0759; pop the caller's far return address into [5404]/[5406]; call the driver function
  (it sees the caller's arguments at [bp+6] as usual); then loop: decrement [5402]; while not zero,
  call R:0000:179A; finally `jmp far [5404]` back to the caller. **DOS listing**

The `jmp $+2` before each patched instruction (R:0000:073E, 0757) flushes the prefetch queue after
the self-modification (**PC fact**). The guard is not re-entrant: it has one save area and one
patched operand (**inferred**).

R:0000:179A (near; saves AX, DX, ES): ES = R:0000; call far through slot 15's pointer (G#15,
restore the save-under); push shape [5876], y = [5870] − [587A], x = [586E] − [5878]; call far
through slot 30's pointer (G#30, save and draw at the new position). It bypasses the guard on
purpose (**inferred**). **DOS listing**

Mouse handler R:0000:17DB..1829 (installed with INT 33h AX=0Ch, event mask 1Fh, by R:0000:163E
at R:0000:1664; 26 instructions in the listing). DS = 2B01h; x = CX >> [587C]; [5874] |= BX; [5872] = BX;
[586E] = x; [5870] = DX; if the far pointer DGROUP:587E/5880 is not null, call it (a user hook,
set by R:0000:17CC); then, if the event mask has bit 0 (cursor moved, **PC fact**) and [5403] ≠ 0:
exchange [5402] with 2; if the old value was 0, call R:0000:179A and set [5402] = 0; otherwise (a
guarded driver call is running) leave [5402] = 2, so the guard redraws after the driver function
returns. **DOS listing**

The pointer is shown by R:0000:16DB (if [5876] ≠ 0 and [5403] = 0: G#30(x − hot x, y − hot y,
shape), then [5403] = 1) and hidden by R:0000:170B (if [5876] ≠ 0 and [5403] ≠ 0: [5403] = 0,
then G#15). Both
are called from the counted show/hide pair R:01A8:0250 / R:01A8:0268. R:0000:1725 (prologue scan
only), when a shape is set and the pointer is drawn, clears [5403], keeps its old value in the
code byte R:0000:1724 and calls G#9 with AX = its argument (a page); R:0000:174C (decoded here),
when a shape is set and that byte is not 0, calls R:0000:179A and restores [5403] from it. No
reference to either routine was found. **DOS listing**, **DOS file**

Inferred purpose of the guard: the guarded functions are exactly those that use the pointer state
(9, 15, 30, 31) or the scratch variables G:0000:08B2..08D8 that G#30 itself uses through
G:0000:0C3E (6, 22, 32). A pointer redraw from the mouse interrupt during one of them would
corrupt that state, so the redraw is deferred. **inferred** (from the variable use listed in
section 3.5)

### 1.6 Calling convention and registers on entry

* C callers (the root's C code and the overlays) push the arguments right to left, call far the
  slot, and remove them with `add sp, n` (Microsoft C far cdecl, **PC fact**; matches every call
  site examined). In the driver, after `push bp; mov bp, sp`, the first argument is [bp+6].
  Results are in AX, far pointers in DX:AX. **DOS listing**
* Register-interface functions are called only from the hand-written R:0000 code: G#9 (AX),
  G#38, G#39, G#41, G#42, G#48, G#49 (see the contracts), and the uncalled G#43..47, G#50. G#1,
  G#7, G#15, G#18, G#23, G#24, G#33, G#40, G#51 take no arguments. **DOS listing**
* A plain slot is a `jmp far` and the guard does not touch any register but the flags, so the
  driver runs with the caller's registers. C callers have DS = SS = DGROUP (**inferred**: the
  guard addresses DGROUP through DS; Microsoft C near data, **PC fact**). ES is not set by C
  callers before a driver call; R:0000:179A sets ES = R:0000 only to reach the slot pointers.
  **DOS listing**
* No driver function relies on the incoming ES. A function that needs its own data loads DS or ES
  from the word at G:0000:1988 (= data:05C8, the driver data segment; the only relocated word
  outside the header; it equals load segment + 13Ch) and restores DS before returning
  (push/pop). Variables in the code
  segment are addressed with CS overrides. A video page is reached through the segment table at
  G:0000:1970 + 2·page. **DOS listing**, **DOS file** (relocation table)
* Callers' data is read through DS (ports of G#3, G#20; buffers of G#13, G#19, G#27, G#28, G#34,
  G#16; span table of G#39) or through SS (ports and strings of G#6, G#21, G#22, G#32, G#43..47;
  the 16-entry map of G#27; MISC M#5 reads its argument through DS at SP+4). Both are DGROUP for
  C callers. **DOS listing**
* C-callable functions save and restore BP, SI, DI and DS where they change them; the register
  functions destroy SI, DI and BP (G#39, G#42, G#50) and their R:0000 callers save them.
  **DOS listing**

### 1.7 How the driver finds fonts.cv

The loader puts the data file at paragraph `[002Ah] + ([002Ch] + 15) / 16` of the driver, that is
directly after the driver's data segment. For `MGRAPHIC.EXE` [002Ah] = 013Ch (relocated, the data
segment that G:0000:1988 also holds) and [002Ch] = 0630h, a whole number of paragraphs, so
`fonts.cv` starts at offset 0630h of the driver data segment. The driver uses this fixed offset:
the word at data:0630 is the font count and the word at data:(0630h + 2n) the offset of font n
relative to 0630h (G:0000:1172, 117C, 11BC, 11C6, 134E, 1358). No pointer is passed to the driver.
**DOS file** (header), **DOS listing**

## 2. Driver header (offsets in the load module)

| Offset | Size | Meaning | MGRAPHIC | MISC | Label |
|---|---|---|---|---|---|
| 0000h | 16 | zero bytes, not referenced | zero | zero | DOS file; purpose unknown |
| 0010h | 24 | signature text and zero padding | "MGRAPHIC.EXE" + date 09-19-91 | "MISCOVR.EXE" + date 02-20-89 | DOS file |
| 0028h | word | driver code segment, relocated (value 0 + load segment); the segment of every slot pointer (R:0000:0B92) | 0000h | 0000h | DOS file, DOS listing |
| 002Ah | word | driver data segment, relocated; the loader's base for the data file (R:0000:0AD9) | 013Ch | 0015h | DOS file, DOS listing |
| 002Ch | word | size in bytes of the driver data segment; rounded up to paragraphs by the loader (R:0000:0ADE) | 0630h | 0090h | DOS file, DOS listing |
| 002Eh | word | base slot (R:0000:0B7C) | 0 | 90 | DOS file, DOS listing |
| 0030h | word | number of functions (R:0000:0B8E) | 52 | 8 | DOS file, DOS listing |
| 0032h | 2·count | near offsets of the functions in the code segment (R:0000:0B79) | 0032h..0099h | 0032h..0041h | DOS file, DOS listing |

The first function follows the table (G:0000:009A, M:0000:0042). `EGRAPHIC.EXE` and
`TGRAPHIC.EXE` have the same layout, base 0 and count 52 (data segments 0264h and 0208h, sizes
0500h and 0490h); the sound driver `NSOUND.CVL` has base 100, count 11. **DOS file**

Correction to the brief: 002Ah is not "the segment after the image" but the start of the data
segment inside the image (`MGRAPHIC.EXE` load module 19E6h bytes; data segment at 13C0h), and
002Ch is the data segment size. The MZ stack segment (019Fh) equals 002Ah + 002Ch / 16, the same
place where `fonts.cv` goes. **DOS file**

MZ relocations: `MGRAPHIC.EXE` 0028h, 002Ah and G:0000:1988; `MISC.EXE` 0028h, 002Ah and the
immediates at M:0000:0082 and 00AC (the data segment loaded into DS). The MZ entry point (IP
0010h, the signature) and stack are not used by INT 21h AX=4B03h (**PC fact**), so the files are
not meant to run as programs (**inferred**). **DOS file**

## 3. MGRAPHIC.EXE model

### 3.1 Video memory

* G#37 sets BIOS mode 13h (INT 10h AH=0, AL = 13h or 93h), a linear 320×200 screen with one byte
  per pixel at segment A000h (**PC fact**). **DOS listing**
* Every pixel address is `rowtab[y] + x`, where rowtab is 200 words at G:0000:17D6 (= data:0416),
  holding 320·y. **DOS file** (checked in scratch), **DOS listing**
* Pages: the segment table at G:0000:1970..197F (data:05B0..05BF), eight words initialised to
  A000h. Page 0 is the screen (O2 stores G#0(0) = A000h there); pages 1..k−1 are 64000-byte
  conventional-memory buffers from G#0 with the same layout. There are no plane writes, no latch
  tricks, no map-mask writes. **DOS file**, **DOS listing**
* Port I/O of the driver: 3C8h/3C9h (DAC write index and data, G:0000:01A1), 3C0h (attribute
  controller, overscan register, G:0000:01ED), 3C4h/3C5h (sequencer register 1, G#23/G#24), 3D8h
  (G#23/G#24), 3D4h (CRTC register 0Dh, G#51), 3DAh (retrace status, bit 3). The driver never
  reads the DAC; the root reads it through 3C7h at R:0000:03D1 (cycling set-up) and R:0000:0568
  (the fade's palette snapshot). The full port list is in EXECUTABLE.md 9. **DOS listing**
* Retrace: G:0000:01A1 (every DAC write), G:0000:01ED, G#23, G#24 and the G#10 calibration wait for
  vertical retrace. G#31, G#36 and all drawing do not. **DOS listing**

### 3.2 The view port (my naming) passed by the game

A DGROUP structure; DGROUP:00AA holds the current one, DGROUP:19D4/19E8/19FC hold others
(**DOS listing**). Fields used by the driver:

| Offset | Meaning | Used by |
|---|---|---|
| 00h | page index | G#3, G#6, G#20, G#21, G#22, G#32, G#43..47, G#49 |
| 02h, 04h | origin x, y on the page | the same; added to every coordinate |
| 06h, 08h | largest x, y relative to the origin (width − 1, height − 1) | clipping of G#6, G#22, text; G#49 keeps 06h |
| 0Ah | text style: low byte 1 = opaque; bit 0 adds the line spacing to the text height | text |
| 0Ch | colour word: low byte text colour; bits 0..1 of the high byte raster operation | text (written back, see G#21) |
| 0Eh | text background colour (low byte) | text |
| 10h | font number (1-based) | text, and the game's calls to G#4, G#12 |

**DOS listing** (G:0000:07E4..07F9, 0C92, 0CC0, 1328..13AD, 0FAC..0FC4, 0FA8; the game's
R:0000:0BFA, 100A, 104F read 00h..08h too)

### 3.3 The sprite format (my naming "run sprite")

Built by G#2/G#33..35 and drawn by G#6, G#22, G#32, G#9 and G#30: at offset 0 of its segment the
width (word) and height (word), then for each row: word n (stored bytes), word x0 (first stored
column), n pixel bytes. Leading and trailing zero pixels of a row are not stored (x0 counts the
leading ones; a row of zeros has n = 0, x0 = width); zero pixels inside the run are stored and
are transparent when drawn. A sprite is paragraph-aligned and at most 0FFF0h bytes. **DOS listing**
(G:0000:0AE3..0B84, 0D68..0DFB)

### 3.4 fonts.cv as the driver reads it

At data:0630: word count, then count words; the word for font n (1..count) is the offset P, from
0630h, of the font's glyph data. Before P: the width table (one byte per character from first to
last, the last one at P−9), and eight bytes P−8..P−1: first character, last character, bytes per glyph row
(1 or 2), fixed width (0 = proportional), height, character spacing, line spacing, one byte not
used by the reached code. The glyph data are (height + line spacing) rows; each row holds all
characters in order, bytes-per-row bytes each, most significant bit leftmost (a 16-bit
big-endian read for two-byte rows). Font numbers 0 or above the count are rejected. **DOS listing**
(G:0000:1328..13AD, 0FAC..10A6, 115D, 11AE), **DOS file** (`FONTS.CV` holds nine fonts and its
sizes match this layout: checked in scratch only)

### 3.5 Driver state

| Where | Contents | Label |
|---|---|---|
| data:0000..004F | zero bytes, then a copyright notice | DOS file |
| data:0050..01CF | default palette, 128 RGB triples (6-bit values), loaded by G#37, used by G#26, G#27 | DOS file, DOS listing |
| data:01D0..01FF | scratch triples of G#27 | DOS listing |
| data:0200..0215 | pointer: shape segment, x, y, shape width, height, clipped x, y, width, height, saved flag (0212h), page used by G#9 (0214h) | DOS listing |
| data:0216..0415 | pointer save-under, at most 512 bytes | DOS listing |
| data:0416..05A5 | row table (G:0000:17D6) | DOS file |
| data:05A6..05AF | five info words for G#17 | DOS file |
| data:05B0..05BF | page segment table (G:0000:1970) | DOS file |
| data:05C0..05CC | G:0000:1980 target segment, 1982/1984 origin x/y, 1986 port largest x, 1988 data segment, 198A colour, 198B raster operation, 198C its opcode byte | DOS listing |
| data:05CE, 05DC | `$`-terminated messages "Out of memory" (only the unreached G:0000:04CA uses it) and "MCGA is not supported..." (G#37) | DOS file, DOS listing |
| data:0602..060A | line and pixel state | DOS listing |
| data:060C..0625 | text state: colour, background, mode, glyph columns, glyph pointer, width table pointer, row stride, x, y, fixed width, spacing, row shift, first, last, left skip, right trim, rows, saved character and its address | DOS listing |
| data:0630.. | `fonts.cv` | DOS listing |
| G:0000:089E..08B0 | sprite arena: free offset, current segment, base, end, capacity, run counters, rows left, width | DOS listing |
| G:0000:08B2..08DC | sprite drawing and clipping scratch, returned rectangle at 08C2 (x, y, width, height) | DOS listing |
| G:0000:08DE..0A1D | 320-byte row buffer of G#22 | DOS listing |
| G:0000:06B3, 06B5 | G#10 calibration | DOS listing |
| G:0000:10AC, 10AE | G#51 generator state and shake count | DOS listing |

The driver keeps no global clip rectangle and no current font: both come from the port of each
call (only G#49 copies port 06h into G:0000:1986). **DOS listing**

Self-modified code: the raster opcode at G:0000:0576 (G#38), 0613 and 0632 (G#42), 105D (text);
the direction opcodes at G:0000:0F46 and 0F57 (G#22, from the four bytes at 0F63..0F66). The
raster opcode comes from the four bytes at G:0000:0208: store, AND, OR, XOR for operation 0..3
(opcode meaning: **PC fact**). **DOS listing**, **DOS file**

## 4. Graphics functions G#0..G#51

Slot address = the address callers call (section 1.4). "Sites" counts call instructions, "fns"
the calling functions (`db.json`), both from the decoded code.

| G# | Driver | Slot | Kind | Sites / fns | My name | Conf. |
|---|---|---|---|---|---|---|
| 0 | 04AE | 076F | plain | 1 / 1 | AllocPage | high |
| 1 | 0492 | 0776 | plain | 2 / 2 (+1 undecoded) | LargestFreeBlock | high |
| 2 | 0B85 | 077D | plain | 51 / 16 | GrabSprite | high |
| 3 | 009A | 0784 | plain | 34 / 11 | RecolourRect | high |
| 4 | 115D | 078B | plain | 5 / 4 | CharWidth | high |
| 5 | 0696 | 0792 | plain | none | ClearPage | high |
| 6 | 0C3E | 0797 | guarded | 9 / 7 | DrawSpriteClipped | high |
| 7 | 0A4A | 07A0 | plain | 19 / 17 | CloseSpriteArena | high |
| 8 | 04D1 | 07A7 | plain | none | FreePage | high |
| 9 | 030E | 07AC | guarded | 1 / 1 (unreferenced caller) | PointerIntoPage | high |
| 10 | 06B7 | 07B5 | plain | 4 / 4 | DissolveToScreen | high (timing medium) |
| 11 | 10E8 | 07BC | plain | 1 / 1 (unreferenced caller) | FontAddress | high (defect inferred) |
| 12 | 11AE | 07C3 | plain | 3 / 3 | FontLineHeight | high |
| 13 | 03B1 | 07CA | plain | 1 / 1 | ReadRow | high |
| 14 | 038C | 07D1 | plain | 5 / 5 | GetPixel | high |
| 15 | 0224 | 07D6 | guarded | 2 / 2 (one through the slot pointer) | PointerRestore | high |
| 16 | 110D | 07DF | plain | none | ReplaceFont | high (defect inferred) |
| 17 | 0460 | 07E6 | plain | 1 / 1 (unreferenced caller) | DriverInfo | high (meaning unknown) |
| 18 | 0A1E | 07ED | plain | 19 / 17 | OpenSpriteArena | high |
| 19 | 03DF | 07F4 | plain | 3 / 3 | WriteRow | high |
| 20 | 07D8 | 07FB | plain | 139 / 53 | CopyRect | high |
| 21 | 11D7 | 0802 | plain | 1 / 1 | DrawText | high |
| 22 | 0BE9 | 0807 | guarded | none | DrawSpriteScaled | medium |
| 23 | 051C | 0810 | plain | none | ScreenOff | medium |
| 24 | 0536 | 0817 | plain | none | ScreenOn | medium |
| 25 | 049C | 081E | plain | 1 / 1 | SetPageSegment | high |
| 26 | 00EC | 0825 | plain | none | SetDacFromDefault | high |
| 27 | 010C | 082C | plain | 1 / 1 | MapLow16Colours | high |
| 28 | 0162 | 0833 | plain | 6 / 5 | LoadPaletteBlock | high |
| 29 | 10AF | 083A | plain | none | SetShakeCount | high |
| 30 | 0270 | 083F | guarded | 2 / 2 (one through the slot pointer) | PointerDraw | high |
| 31 | 063C | 0846 | guarded | 14 / 9 | ShowPage | high |
| 32 | 0D47 | 084D | guarded | 52 / 23 | DrawSprite | high |
| 33 | 0AC6 | 0856 | plain | 1 / 1 | EndSprite | high |
| 34 | 0AE3 | 085D | plain | 1 / 1 | AddSpriteRow | high |
| 35 | 0A78 | 0864 | plain | 1 / 1 | BeginSprite | high |
| 36 | 066A | 086B | plain | none | SwapPageWithScreen | high |
| 37 | 04E8 | 0872 | plain | 1 / 1 | SetVideoMode | high |
| 38 | 0550 | 0879 | plain | 1 / 1 | PlotPixelReg | high |
| 39 | 040A | 0880 | plain | 1 / 1 (+1 undecoded) | FillSpansReg | high |
| 40 | 0223 | 0887 | plain | 3 / 3 | EndPrimitive (no-op) | high |
| 41 | 020C | 088E | plain | 3 / 3 | SetColourReg | high |
| 42 | 0599 | 0895 | plain | 1 / 1 | LineReg | high |
| 43 | 11F0 | 089C | plain | none | TextClipAllReg | high |
| 44 | 11FF | 08A3 | plain | none | TextClipLeftReg | high |
| 45 | 12FB | 08AA | plain | none | TextNoClipReg | high |
| 46 | 1253 | 08B1 | plain | none | TextClipRightReg | high |
| 47 | 12B5 | 08B8 | plain | none | TextClipVertReg | high |
| 48 | 0484 | 08BF | plain | 1 / 1 | SetTargetPageReg | high |
| 49 | 046D | 08C6 | plain | 2 / 2 | SetPortReg | high |
| 50 | 084C | 08CD | plain | none | CopySpansReg | high |
| 51 | 10BB | 08D4 | plain | 1 / 1 | ShakeTick | high (visual effect medium) |

Driver addresses are G:0000:xxxx, slot addresses R:0000:xxxx. Driver addresses: **DOS file**
(table at 0032h); slots and kinds: **DOS file** (decoded here); call counts: **DOS listing**.
"None" means no call in the decoded code and none found by my byte scans (1.4): such a function
is either unused or reached only from code nobody has decoded.

Each contract below: arguments as `[bp+n]` in the driver, cross-checked with the pushes of the
named call sites; then return value and effects. Evidence is the DOS listing of the driver range
named, unless another label is given.

**G#0 AllocPage(flag)**, G:0000:04AE..04C9. Callers: O2:01A1 (in the page set-up loop, 1.1 step
6). `[bp+6]` flag. Flag 0: AX = the segment in page slot 0 (G:0000:1970, A000h in the file). Else
INT 21h AH=48h for 0FA0h paragraphs (64000 bytes): AX = the new segment, or 0 on failure. Does
not store into the page table (G#25 does). No video effect.

**G#1 LargestFreeBlock()**, G:0000:0492..049B. Callers: R:01A8:0050, R:0238:1119, and R:1DC4:0592
inside the undecoded routine R:1DC4:057A (decoded here, which prints the number). No arguments.
INT 21h AH=48h with BX = FFFFh; AX = BX = the largest free block in paragraphs (**PC fact** for
the failing call). R:01A8:0050 compares it with 1F40h (the `m` driver) or 0FA0h.

**G#2 GrabSprite(page, x, y, w, h)**, G:0000:0B85..0BE8. Callers: O2:023E (pushes 1, 0, 40h, 140h,
50h for page, x, y, w, h), O19:1152. Args `[bp+6]` page (its absolute value is used; the sign is
kept in BP and never read), `[bp+8]` x, `[bp+0Ah]` y, `[bp+0Ch]` w, `[bp+0Eh]` h, absolute page
coordinates (no port). Calls G#35(w, h); if that gives a segment and w, h ≠ 0, calls G#34 for each
of the h rows starting at offset rowtab[y] + x of the page (DS = the page segment), then G#33.
Returns AX = the sprite's segment, 0 if the arena is full or closed. Reads the page and writes only
the arena (section 3.3). No clipping.

**G#3 RecolourRect(port, x, y, w, h, old, new)**, G:0000:009A..00EB. Callers: O3:04E8, R:1AEA:09DC.
`[bp+6]` port (through DS), `[bp+8]` x, `[bp+0Ah]` y (port coordinates, origin added),
`[bp+0Ch]` w, `[bp+0Eh]` h, `[bp+10h]` old colour, `[bp+12h]` new colour (low bytes). Every pixel
of the rectangle equal to old becomes new; others are untouched. No clipping, no check for
w = 0 or h = 0 (a zero count would loop 65536 times). No return value.

**G#4 CharWidth(font, ch)**, G:0000:115D..11AD. Callers: O23:074E (pushes the character, then
port[10h]), R:0182:011A. `[bp+6]` font, `[bp+8]` character (low byte). AX = (fixed width, or the
width table entry) + character spacing, sign-extended from a byte; AX = 0 for a character of 80h
or above, a character outside first..last, or an invalid font. No effect.

**G#5 ClearPage(page, colour)**, G:0000:0696..06B2. No callers. `[bp+6]` page (0 = screen),
`[bp+8]` colour (low byte). Fills all 64000 bytes of the page. No pointer handling, no retrace
wait.

**G#6 DrawSpriteClipped(port, x, y, seg)**, G:0000:0C3E..0C76 with 0D12, 0C77, 0D68. Guarded.
Callers: O19:0A1A (pushes seg [81C4], y 2, x, port [19D4]), O21:016E. `[bp+6]` port (through
SS), `[bp+8]` x, `[bp+0Ah]` y (port coordinates), `[bp+0Ch]` sprite segment. Draws the run sprite
(3.3) with its top left at (x, y) + origin on the port's page, clipped to x 0..port[06h] and
y 0..port[08h]; pixel value 0 is not drawn (transparent). Returns DX:AX = G:CS:08C2, a rectangle
of four words: x and y of the first drawn pixel (port coordinates), drawn width and height; all
zero when the segment is 0, the sprite has width or height 0, or nothing is visible. Uses the
scratch G:0000:08B2..08D0.

**G#7 CloseSpriteArena()**, G:0000:0A4A..0A77. Callers: O2:0249, R:01A8:0116 (each after a
G#18 ... G#2 sequence). Shrinks the arena block (G#18) to the paragraphs used (INT 21h AH=4Ah) or
frees it when nothing was stored (AH=49h). Returns AX = the arena's base segment, or 0 when the
DOS call failed, the arena was not open, or a G#35 call had failed (that failure sets the current
segment to 0, so the block is then neither shrunk nor freed: **inferred** from G:0000:0A4E..0A55
and 0ABA..0AC0). Clears the arena variables. The sprites stay in the block.

**G#8 FreePage(page)**, G:0000:04D1..04E7. No callers. `[bp+6]` page; for page ≠ 0, INT 21h AH=49h
on the page's segment. The table entry is not cleared.

**G#9 PointerIntoPage**, register AX = page, G:0000:030E..038A (far return). Guarded. Caller:
R:0000:1745 in R:0000:1725 (no reference found). Also called inside the driver by G#30 (AX = 0)
and G#31. Stores AX in data:0214. If a pointer rectangle is saved (data:0212 ≠ 0): copies the
clipped pointer rectangle of page AX into the save-under, then draws the pointer shape into page
AX at (data:0202, data:0204) through G:0000:0C3E with a port built on the stack {page AX, origin
0, 0, largest 319, 199} (transparent colour 0).

**G#10 DissolveToScreen(page, duration)**, G:0000:06B7..0775 with 0776, 07A4. Callers: O2:0B8B
(pushes 14h, 1), O9:1518 (1Eh, 1). `[bp+6]` page, `[bp+8]` duration. First sets the BIOS byte
0040:0040 (diskette motor time-out, **PC fact**) to 1 and waits until it changes (one BIOS timer
tick; the BIOS also stops a running diskette motor, **PC fact**). Page 0: return. On the first
call it calibrates (G:0000:0776): with interrupts disabled it counts, between two vertical
retraces, the steps of the copy loop with delay 1 and with delay 17 (writing a dummy byte to
offset FFFFh of the screen). Then it copies all 64000 pixels from the page to the same offsets of
page 0, in the order of a 16-bit Galois shift register (feedback mask B400h, start 1, values above
FA00h skipped, offset = value − 1; each offset visited once). Duration 0: no delay. Otherwise
the target is 8800 / duration pixels per frame (at least 1); the per-pixel delay loop count is
computed from the calibration so that about that many pixels are copied per frame (**inferred**
from the arithmetic at G:0000:06EF..0730; the run time on a real machine is **unknown**).
Opaque copy, no pointer handling, no return value.

**G#11 FontAddress(font)**, G:0000:10E8..110C. Caller: R:1FA1:03D9 in R:1FA1:02E6 (a font loader
found only by the prologue scan, no reference found), which subtracts 8 and writes a font read
from a file there. `[bp+6]` font n. ES = the data segment (G:0000:1988). If n is not above the
word at data:0020 (unsigned compare, G:0000:10F5..10FA) and n ≠ 0 (G:0000:10FC..10FE): AX = 0630h
+ the word at data:(0020h + 2n) (G:0000:1100..1104), DX = the data segment (G:0000:1109); else
AX = 0 and DX is not set. Note: G#4, G#12 and the text code take the count from the word at
data:0630 and the offset of font n from the word at data:(0630h + 2n) (G:0000:1172, 117C, 11BC,
11C6, 134E, 1358, section 1.7); this function uses data:0020 for both, where the file holds
characters of the copyright notice (which begins at data:0010) and no decoded code writes. EGRAPHIC's equivalent (E:0000:236A) has the same 0020h read with its
own base 0500h. **DOS listing**, **DOS file**; that the result is not the font address is
**inferred** (a defect); it has no effect on the reached code.

**G#12 FontLineHeight(font)**, G:0000:11AE..11D6. Callers: R:1D05:0094 (pushes port[10h]),
R:1F4D:00A0. `[bp+6]` font. AX = height + line spacing (AH = 0), 0 for an invalid font.

**G#13 ReadRow(dest, page, x, y, count)**, G:0000:03B1..03DE. Caller: R:202A:00A5 (pushes count,
y, x, page, DGROUP:E17E). Copies count bytes from the page at rowtab[y] + x to DS:dest. Absolute
page coordinates, no clipping.

**G#14 GetPixel(page, x, y)**, G:0000:038C..03B0. Five call sites, each pushing y, x, page:
O18:0C9C (page 0, x and y the bytes DGROUP:683E + i and 6852 + i), R:0403:29AE (page 2, x + 50h,
y from locals), R:15FB:359F (page 2, x + 50h, y from locals; the result is compared with
DGROUP:D7EE), R:1D05:00E1 in R:1D05:0031 (page 0, x and y its own arguments [bp+8], [bp+0Ah],
called only when the y argument is odd and not 8Bh), and R:0866:2604 in the wrapper
R:0866:25F8(page, x, y), which passes its three arguments unchanged and is called from 27
functions (`db.json`). AX = the pixel byte (AH = 0). Absolute page coordinates. These are the
DOS sites that read pixels back as data (extension prompt 8); the scene and map documents give
their meaning.

**G#15 PointerRestore()**, G:0000:0224..022E with 022F. Guarded. Callers: R:0000:171E (through
the guarded entry) and R:0000:17A2 (through the slot pointer). If data:0212 ≠ 0, copies the
save-under back to page 0 (the screen segment in page slot 0) at the clipped pointer rectangle.
Then data:0212 = 0 (written as G:CS:15D2, the same byte).

**G#16 ReplaceFont(font, src)**, G:0000:110D..115C. No callers. `[bp+6]` font n, `[bp+8]` near
pointer (through DS) to the glyph data P of a font record laid out as in 3.4. Copies the width
table, the eight header bytes and the glyph data (size computed as the low byte of
bytes-per-row × (height + line spacing), times the character count) as words (an odd total
drops its last byte) over the record of font n.
Like G#11 it finds the record through the word at data:(0020h + 2n), plus 0630h, after the same
checks of n against the word at data:0020 and n ≠ 0 (G:0000:111E..112E) (**inferred** defect); no
size check.

**G#17 DriverInfo(k)**, G:0000:0460..046C. Caller: R:01A8:01C9 in R:01A8:01C2 (prologue scan only,
no reference found), which pushes 0 and does nothing more when the result is 0. AX = the word at
data:05A6 + k (k is a byte offset, not scaled). The file holds 0, 1, 0, 0, 0 there; k = 10 and
above reads the page table. Meaning of the words: **unknown**.

**G#18 OpenSpriteArena()**, G:0000:0A1E..0A49. Callers: O2:0216, R:01A8:0102. Allocates the
largest free DOS block (G#1, then INT 21h AH=48h). Sets the free offset to 0, the current and base
segments to the block, the end to block + size; all zero on failure. AX = the block segment or 0.
While the arena is open, almost no DOS memory is free (**inferred**).

**G#19 WriteRow(src, page, x, y, count)**, G:0000:03DF..0409. Callers: R:1FA1:01FE (pushes
DGROUP:68E2 count, y, x, page, DGROUP:E17E), R:1FA1:051D. Copies (count + 1) / 2 words from DS:src
to the page at rowtab[y] + x, so an odd count writes one byte more. Absolute coordinates, opaque.

**G#20 CopyRect(src port, sx, sy, w, h, dst port, dx, dy)**, G:0000:07D8..084A. Callers: O2:027C
(pushes B0h, 0, [19D4], 18h, 140h, 4Ch, 0, [19D4]), R:01A8:01F3. `[bp+6]` source port (through
DS), `[bp+8]`, `[bp+0Ah]` source x, y, `[bp+0Ch]`, `[bp+0Eh]` w, h, `[bp+10h]` destination port,
`[bp+12h]`, `[bp+14h]` destination x, y (each port's origin added). Copies h rows of w bytes,
top to bottom, left to right (words, then an odd byte), stride 320. Nothing for w = 0 or h = 0.
Opaque, no clipping, no overlap handling.

**G#21 DrawText(port, x, y, string)**, G:0000:11D7..11EF, then 11F0 (= G#43). Caller: R:0182:0053
in R:0182:002A (port = DGROUP:00AA after setting its colour word; x doubled when DGROUP:6B8C ≠ 0).
`[bp+6]` port (SS), `[bp+8]` x, `[bp+0Ah]` y (port coordinates), `[bp+0Ch]` near pointer (SS) to
a zero-terminated string. Font = port[10h] (1..count, else nothing is drawn). Clipping: right
edge port[06h] (the last visible character is shortened; the string is cut by writing a 0 after
it, restored before return, so the string must be writable), left edge 0 (whole characters
skipped, the first visible one cut), top 0 and bottom port[08h] (rows cut). Characters outside
first..last are skipped without advance. A byte of 80h or above sets the text colour to that byte
AND 7Fh for the rest of the string; at the terminator the current colour is stored back into the
low byte of port[0Ch]. Style (port[0Ah] low byte) 1: opaque, set bits in the text colour, clear
bits in port[0Eh], over width + spacing columns; height includes the line spacing when port[0Ah]
bit 0 is set. Other styles: only set bits are drawn, with the raster operation of port[0Dh]
bits 0..1 (G#41), over width columns (width + spacing for the last character). Each character
advances x by its width + spacing (fixed width + spacing for a fixed font). Returns AX = x after
the text in port coordinates; on an early exit (empty string, bad font, fully clipped) AX = x −
port[02h]. The text state lives in data:060C..0625.

**G#22 DrawSpriteScaled(port, x, y, w, h, seg, b)**, G:0000:0BE9..0C3D with 0D12, 0C77, 0E00.
Guarded. No callers. `[bp+6]` port (SS), `[bp+8]` x, `[bp+0Ah]` y, `[bp+0Ch]` destination width
(negative: mirrored left-right), `[bp+0Eh]` destination height (negative: flipped top-bottom),
`[bp+10h]` sprite segment, `[bp+12h]` a byte stored at G:0000:08DC and never read. Scales the run
sprite to |w| × |h| with integer error terms (each source row is expanded into the row buffer
G:0000:08DE first), clipped like G#6, colour 0 transparent. Returns DX:AX = G:CS:08C2 as G#6.

**G#23 ScreenOff()**, G:0000:051C..0535. No callers. After vertical retrace: port 3D8h = 2, and
sets bit 5 of sequencer register 1 (screen off on VGA, **PC fact**). **G#24 ScreenOn()**,
G:0000:0536..054F, no callers: port 3D8h = 0Ah and clears that bit. Port 3D8h is the CGA-compatible
mode register (**PC fact**); its effect on MCGA or VGA in mode 13h is **unknown**.

**G#25 SetPageSegment(page, seg)**, G:0000:049C..04AD. Caller: O2:01B4 (pushes seg, n). Page table
entry `page` = seg. No check of the index.

**G#26 SetDacFromDefault(index, entry)**, G:0000:00EC..010B. No callers. `[bp+6]` DAC index,
`[bp+8]` default-palette entry. Writes the default triple data:0050 + 3·entry to that DAC
register (retrace-paced writer, below). Entries above 127 read past the default palette.

**G#27 MapLow16Colours(map)**, G:0000:010C..0161 with 01ED. Caller: O2:020E (pushes DGROUP:19FE).
`[bp+6]` near pointer to 17 bytes. The first position k (0..15) whose byte equals byte 16 is
written to the attribute controller overscan register 11h (border colour) after a retrace wait;
no write if none matches. Then DAC 0..15 receive the default-palette triples named by the 16 map
bytes.

**G#28 LoadPaletteBlock(block)**, G:0000:0162..018D. Callers: O8:0B0B (DGROUP:C5BE after reading
a `.pal` file), R:0000:112D (in the picture reader R:0000:108E). `[bp+6]` near pointer (DS). If
the block starts with the two bytes "M0": DAC registers block[4]..block[5] receive the RGB
triples from block + 6 (bytes 2..3 not read). Otherwise nothing. R:0000:1096 calls it with a null
pointer; DGROUP:0000 is zero in the file, so `MGRAPHIC.EXE` does nothing (**DOS file**), while
EGRAPHIC's G#28 (E:0000:04CA) treats a null pointer specially (**DOS file**); a per-driver hook
(**inferred**).

DAC writer G:0000:01A1 (BL = first index, CX = count, ES:DX = triples), used by G#26..28 and G#37:
waits for vertical retrace; writes each entry (index to 3C8h, three bytes to 3C9h, interrupts off
per entry); while retrace lasts it keeps writing; when retrace has ended after k entries it writes
13·k more (low byte of k times 13) without checking, then waits for the next retrace. The pacing
rule is **DOS listing** (G:0000:01B2..01EB: the `loop` at G:0000:01DB returns to 01B8, which counts
k in BP; G:0000:01E1..01EB sets BP = −13·k; G:0000:01B7 is a NOP byte); its purpose is
**unknown**.

**G#29 SetShakeCount(n)**, G:0000:10AF..10BA. No callers. G:0000:10AE = low byte of `[bp+6]`.

**G#30 PointerDraw(x, y, shape)**, G:0000:0270..030C. Guarded. Callers: R:0000:16FD (pushes shape
[5876], y − hot y, x − hot x), R:0000:17C0 (the same, through the slot pointer). `[bp+6]` x,
`[bp+8]` y (screen coordinates of the shape's top left), `[bp+0Ah]` shape segment (a run sprite).
Clips the shape rectangle to 320 × 200 and limits its height to 512 / visible width rows (the
save-under size); if nothing remains, data:0212 = 0 and returns. Else stores the clipped
rectangle, data:0212 = 1, and runs G#9 with AX = 0: save the screen under the rectangle and draw
the whole shape (transparent 0, clipped to the screen). A shape taller than the save limit is
drawn but only partly saved (**inferred**).

**G#31 ShowPage(page)**, G:0000:063C..0669. Guarded. Callers: O2:046E, R:01A8:01FE (each pushes a
page). `[bp+6]` page; page 0: nothing. Else runs G#9 with AX = page (the pointer, if shown, is
saved from and drawn into that page) and copies the 64000 bytes of the page to page 0. No retrace
wait. The page keeps the drawn pointer (**inferred** consequence).

**G#32 DrawSprite(port, x, y, seg)**, G:0000:0D47..0D67 with 0D12, 0D68. Guarded. Callers: O2:0A81
(pushes seg, 40h, 0, [19D4]), R:1AEA:05F4. As G#6 without clipping: draws the whole run sprite at
(x, y) + origin, colour 0 transparent; nothing for segment 0 or a zero width or height. No
defined return value.

**G#33 EndSprite()**, G:0000:0AC6..0AE2. Caller: R:1FA1:04B6. Rounds the sprite under construction
up to paragraphs, advances the current arena segment past it and returns AX = the sprite's segment
(0 after a failed G#35).

**G#34 AddSpriteRow(row)**, G:0000:0AE3..0B84. Caller: R:1FA1:049A (pushes DGROUP:E17E). `[bp+6]`
near pointer (DS) to `width` pixel bytes. Appends one encoded row (3.3). When the row does not
fit, the sprite's height word is decremented, the arena end is set to 0 (later G#35 calls fail)
and AX = 0; else AX = the sprite's segment (0 when no sprite is open).

**G#35 BeginSprite(w, h)**, G:0000:0A78..0AC5. Caller: R:1FA1:047E (pushes DGROUP:68E4 height,
68E2 width). Capacity = min(free arena paragraphs, 0FFFh) × 16 bytes; writes the two header words
at the current arena segment, offset 0. AX = that segment; when the arena has no room, AX = 0 and
the free offset and current segment are set to 0.

**G#36 SwapPageWithScreen(page)**, G:0000:066A..0695. No callers. Page ≠ 0: exchanges its 64000
bytes with page 0, word by word. No pointer handling.

**G#37 SetVideoMode(flags)**, G:0000:04E8..051B. Caller: O2:0166 (pushes 0). INT 10h with AH = 0,
AL = 13h | (flags AND 80h) (bit 7: keep video memory, **PC fact**). Then INT 10h AH=0Fh; if the
reported mode equals the request, DAC 0..127 = the default palette (writer above) and return.
Else: INT 10h mode 3, print the data:05DC message ("MCGA is not supported...") with INT 21h AH=09h
and exit with INT 21h AX=4C00h. The game sets no other mode through the driver.

**G#38 PlotPixelReg**: AX = x, BX = y (port coordinates), G:0000:0550..057A. Caller: R:0000:1080
in the root's clipped PutPixel(port, x, y, colour) R:0000:104F, after G#49 and G#41. Writes the
colour G:0000:198A to the target segment G:0000:1980 at rowtab[y + origin y] + x + origin x with
the raster operation of G#41. No clipping in the driver.

**G#39 FillSpansReg**: AX = first row, CX = last row, BX = near pointer (DS) to two word arrays
indexed by row: left x at BX + 2r, right x at BX + 190h + 2r; G:0000:040A..045F. Callers:
R:0000:0C63 in the root's FillRect(port, x, y, w, h, colour) R:0000:0BFA (arrays DGROUP:5534 and
56C4, origin already added), and R:0000:0C7F in the unreferenced R:0000:0C72 (decoded here).
Nothing if AX < 0 or AX > CX. For each row, stores the colour G:0000:198A (always a plain store;
the raster operation is ignored) from left to right inclusive into the target segment; a row is
skipped when right < left, or when right = left and left is 0 or equals G:0000:1986 (port largest
x from G#49; purpose **unknown**). Rows are absolute (no origin).

**G#40 EndPrimitive()**, G:0000:0223: a far return only. Callers: R:0000:0C68, 1046, 1085 (after
each root fill, line and pixel). In EGRAPHIC the same slot (E:0000:05B9) writes EGA sequencer and
graphics-controller registers (**DOS file**, first instructions only), so it is a per-driver
end-of-primitive hook (**inferred**).

**G#41 SetColourReg**: AL = colour, AH bits 0..1 = raster operation (0 store, 1 AND, 2 OR, 3 XOR);
G:0000:020C..0222. Callers: R:0000:0C4E, 103E, 1077 (each loads the caller's colour word). Sets
G:0000:198A, 198B and the opcode byte 198C; AL = the opcode on return.

**G#42 LineReg**: AX = x1, BX = y1, CX = x2, DX = y2 (port coordinates), G:0000:0599..063A. Caller:
R:0000:0E7D in R:0000:0E3C, the clipping part of the root's DrawLine(port, x1, y1, x2, y2,
colour) R:0000:100A, after G#49 and G#41. Orders the end points by y; equal points plot one
pixel; otherwise a Bresenham line of max(|dx|, |dy|) + 1 pixels (error starts at −(major + 1) / 2;
straight runs for dx = 0, dy = 0 or |dx| = |dy|), each written with the raster operation into
the target segment. No clipping in the driver.

**G#43..G#47 text, register interface**: BP = port (SS), BX = string (SS), CX = x, DX = y;
G:0000:11F0, 11FF, 12FB, 1253, 12B5. No callers. Common set-up G:0000:1328 (it pops its own
return address into SI, pushes DS and ES and returns with `jmp si`; this is the indirect jump at
G:0000:13B0), drawing G:0000:12FE/0FAC and exit 1311 as in G#21. G#43: right, left and vertical
clipping (G#21 uses it); G#44: left only; G#45: none; G#46: right only; G#47: vertical only.
Return AX as G#21.

**G#48 SetTargetPageReg**: AX = page, G:0000:0484..0491. Caller: R:0000:0C13 (in FillRect).
G:0000:1980 = the page's segment.

**G#49 SetPortReg**: BX = near pointer (DS) to a port, G:0000:046D..0491. Callers: R:0000:101E,
106F. G:0000:1982/1984 = port origin x/y, G:0000:1986 = port[06h], then as G#48 with AX = port[00h].

**G#50 CopySpansReg**: AX = first row, CX = last row, BX = span arrays as G#39 (read through SS),
SI = source page, DI = destination page; G:0000:084C..089C. No callers. Copies the span pixels from
the source page to the same offsets of the destination page. No check of AX > CX.

**G#51 ShakeTick()**, G:0000:10BB..10E7. Caller: R:0000:0353 in R:0000:0345, which the timer
interrupt handler R:0000:01A7 calls when its divider expires. Steps the generator G:0000:10AC to
5x + 1 (mod 65536; 1234 in the file) on every call. If the count G:0000:10AE ≠ 0: decrements it
and writes CRTC register 0Dh (start address low, **PC fact**) = bits 0..1 of the generator's high
byte, or 0 when the count reaches 0. A short random shift of the displayed image (**inferred**);
G#29 is the only writer of the count and has no callers, so the effect never starts in the
reached code.

## 5. MISC.EXE (M#0..M#7, slots 90..97)

| M# | Slot | Driver | Callers | Contract | My name |
|---|---|---|---|---|---|
| 0 | 09E5 | M:0000:004C | none | INT 16h AH=01h; AX = 0 when a key is waiting, FFFFh when none (ZF meaning: **PC fact**) | KeyNotWaiting |
| 1 | 09EC | M:0000:0047 | R:1D05:0ACF | INT 16h AH=00h; AX = the BIOS key word (scan code, character) | ReadKey |
| 2 | 09F3 | M:0000:0042 | O1:01C1, O1:0327, O1:03BE | INT 21h AH=01h (read a character with echo); AL = character, AH = 1 | ReadCharEcho |
| 3, 4 | 09FA, 0A01 | M:0000:005A | none | the BIOS keyboard flag byte at 0040:0017 AND F0h (M:0000:005F..0065): clears bits 0..3, the right shift, left shift, Ctrl and Alt held states, and keeps bits 4..7, the Scroll, Num, Caps Lock and Insert toggles (bit meanings **PC fact**) | ClearShiftStates |
| 5 | 0A08 | M:0000:006C | none | reads port 201h, inverts it, AX = bit (4 + n), n = the first argument (read through DS at SP+4): 1 when joystick button n is pressed (**PC fact**: buttons are bits 4..7, active low) | JoystickButton |
| 6 | 0A0F | M:0000:0080 | none | measures axes X1, Y1 (write 201h, count loop passes while bits 0 and 1 stay set, interrupts off, at most 65535 passes) and stores the counts as centre, minimum and maximum | JoystickCentre |
| 7 | 0A16 | M:0000:00AA | none | measures as M#6; for each axis a signed byte: 0 at the centre, −127/+127 at a new minimum/maximum (which is stored), otherwise −(d·128 / range) or +(d·128 / range); AX = the two bytes at MISC data:0080 (AL = X, AH = Y) | JoystickRead |

All slots are plain. **DOS file** (header, slots), **DOS listing** (`misc.lst`), joystick port
meaning **PC fact**. MISC keeps its variables in its data segment (header 002Ah = 0015h, loaded
into DS by M#6 and M#7); it has no data file.

Role: `MISC.EXE` ("MISCOVR.EXE", dated 02-20-89) is an input driver: BIOS keyboard (INT 16h),
DOS console input (INT 21h AH=01h), a reset of the shift, Ctrl and Alt held states (BIOS data
byte) and the analogue
joystick on the game port (201h). The reached code uses only M#1 (the game's key reader
R:1D05:0AC9 dispatches on its result) and M#2 (the digit answers of the text-mode set-up in
overlay 1, which also choose the graphics and sound drivers, 1.1). The joystick functions and
M#0 are never called. INT 16h occurs nowhere else in the listings, so every BIOS key read of the
reached code goes through M#1. **DOS listing**, **inferred** (role)

## 6. Sound slots 100..110 (labelled only)

| S# | Slot | Call sites |
|---|---|---|
| 0 | 0A2B | O2:01BE |
| 1 | 0A32 | R:01A8:047C |
| 2 | 0A39 | R:01A8:0197 |
| 3 | 0A40 | R:0000:036C (timer tick routine R:0000:0345) |
| 4 | 0A47 | R:0000:01E7 (timer interrupt handler R:0000:01A7) |
| 5 | 0A4E | O2:0476, O2:04A0, O2:07D0, O2:0806, O2:0A19, O7:18A8, R:01A8:04C2 |
| 6..10 | 0A55..0A71 | none |

All plain. **DOS listing**, **DOS file** (slots)

## 7. Coverage notes

* `MGRAPHIC.EXE`: the listing decodes 4,460 of 6,630 bytes (the corrected tool follows the DAC
  writer's `loop`, EXECUTABLE.md 10). The rest is the header and table (154 bytes), the data
  segment 13C0h..19E5h (1,574 bytes), code-segment data (G:0000:0208..020B, 06B3..06B6,
  089D..0A1D, 0F63..0F66, 10A8..10AE), NOP and zero padding bytes, and the unreached "Out of
  memory" exit at G:0000:04CA..04D0 (no reference; it would print data:05CE and exit). The `jmp si`
  at G:0000:13B0 is resolved (G#43..47). With these, every code byte of `MGRAPHIC.EXE` is
  accounted for. **DOS file**, **DOS listing**
* Root code decoded here: R:0000:174C..1765, 0C72..0C8D (two
  entries: refill the last FillRect spans with G#39; clear them with R:0000:0C8E) and
  R:1DC4:057A..05DC (prints G#1). R:0000:00A1..01A0 is the timer handler's private stack
  (SS = R:0000, SP = 01A1h at R:0000:01B3). R:0000:0CC4..0E3B was not examined; my scans show no
  driver call in it. **DOS file**

## Open

1. G#11 and G#16 take the font count from the word at data:0020 and font n's offset from the
   word at data:(0020h + 2n) (copyright text in the file), where every other font reader uses
   data:0630 and data:(0630h + 2n); EGRAPHIC does the same with its base 0500h. A defect is inferred; whether anything
   writes data:0020 at run time is unknown. Their only caller (R:1FA1:02E6) has no known
   reference.
2. Meaning of the five info words of G#17 (0, 1, 0, 0, 0) and of R:01A8:01C2, the routine that
   uses G#17(0).
3. G#22's seventh argument (stored at G:0000:08DC, never read) and the sign of G#2's page argument
   (kept in BP, never read).
4. Why G#39 skips one-pixel spans at x = 0 and at x = G:0000:1986.
5. The DAC writer's pacing (13·k entries outside retrace): purpose and visible effect (the rule
   itself is in the listing, G#26..28 above).
6. G#10: actual dissolve duration on the original hardware, and whether the two calibration
   windows with interrupts disabled lose timer ticks. Not observable without a DOS run.
7. G#23/G#24 (port 3D8h on MCGA/VGA) and G#51 (pixel shift per start-address unit in mode 13h):
   hardware effect not verified. G#29 is never called in the reached code, so the shake never
   runs there.
8. Functions with no calls in the decoded code: G#5, 8, 16, 22, 23, 24, 26, 29, 36, 43..47, 50,
   M#0, M#3..M#7, S#6..10. Functions whose only callers have no known reference: G#9
   (R:0000:1725), G#11 (R:1FA1:02E6), G#17 (R:01A8:01C2). Unreferenced routines that call the
   driver: R:0000:1725/174C, R:0000:0C72, R:1DC4:057A. Dead code or computed calls: unknown.
9. The 16 zero bytes at header offset 0000h..000Fh and the 4 unreferenced bytes at
   G:0000:10A8..10AB.
10. The loader's 8 spare paragraphs and the 100h paragraphs left free.
11. G#30's 512-byte save limit against the shapes the game uses (whether any shape exceeds it).
12. G#31 leaves the pointer image in the shown page; whether the game relies on or repairs it.
13. R:0000:108E's G#28 call with a null pointer: no effect in `MGRAPHIC.EXE`; its purpose for
    the other drivers is inferred only.
14. The mouse x shift (DGROUP:587C) is the high byte of the cursor x read with INT 33h AX=3 just
    after the reset and handler installation (R:0000:1666..1671), apparently to map a 640-wide
    mouse range to 320 pixels; inferred, not verified.
15. EGRAPHIC and TGRAPHIC function contracts are not covered (only their headers and the
    EGRAPHIC functions named above were compared).
16. Sound driver contracts are out of scope.

<!-- Independent adversarial review of the D0 drafts claude/port/docs/dos/FORMATS.md, PALETTE.md,
     SPRITES.md and the viewers claude/port/gen/dos/pic.py, fontcv.py, texts.py, png.py (extension
     phase D0 gate, scope R2 of docs/verify/BRIEF-d0-review.md), by a separate read-only reviewer
     agent (R2), 2026-10-11. Stored verbatim; the orchestrator records the resolutions. The scratch
     scripts it names are in claude/port/build/dos/scratch-r2/ and are not part of the repository. -->

# D0 review R2: formats, palette, sprites and the viewers

**How I worked.** I read [BRIEF-d0-review.md](BRIEF-d0-review.md), BRIEF-d0.md
and sections 2.3, 3, 5.3, 5.9, 5.10, 6, 7.6, 8 and 9 of the extension prompt. I read
`FORMATS.md`, `PALETTE.md` and `SPRITES.md` in full, twice, and the four tools in full. For
consistency I also read `DRIVER.md` 3.2..3.5 and its G#11, G#16 and G#21 entries, `OPEN.md` in
full, and the passages of `TIMING.md`, `SCENES.md`, `SCENES-PLAY.md`, `CORRESPONDENCE.md` and
`DOS-PROFILE.md` that the three drafts cite.

DOS facts come only from the files in `claude/port/build/dosdata/` and from the listings in
`claude/port/build/dos/disasm/`. I read these listing ranges:
- `root.lst`: R:0000:108E..13C5, 0345, 0382..0667, 0A76..0BF7 and 163E..17DB; all of R:1FA1;
  all of R:1F4D; R:0182:002A..0133; R:1DC4:047D, 05DD..0698; R:0238:1B44..1C97;
  R:0ADE:1940..19BC; R:01A8:00E2..0145 and 0822..0899; R:0403:0FC5..10C9.
- `mgraphic.lst`: G:0000:009A, 010C, 0162..0207, 0224..038A, 03DF, 0AE3, 0DD0 and 0F9C..13B0.
- Overlays: O1:0037..03F9; O2:02E4..0334, 0485..05DA, 0A45..0AD7, 0B32..0B7B and 19A3;
  O5:1455..1AF5 and 1AF6; O7:1861..1B4E; O8:062A, 0701..07D9, 09D8..0B8C, 16C4..17F5;
  O9:11BE..1266; O16:002C..010C; O19:0E86..0ECF.

Where the listing has gaps, I decoded the bytes myself with capstone 5.0.7.

My own scripts, all under `claude/port/build/dos/scratch-r2/`, run as `C:/Python314/python -B`:

| Script | What it does |
|---|---|
| `r2lib.py` | MZ, root, DGROUP, overlay and MGRAPHIC access; capstone helper |
| `mypic.py` | An independent PIC/PAL decoder written from R:0000:108E..1318 (not from `pic.py`) |
| `cmp_pic.py` | Compares `mypic.py` with `pic.py` on all 144 files (sizes, chunks, pixel SHA-256) |
| `chunkfacts.py` | Chunk lengths, first/last index, maximum palette value, maximum code width |
| `palcmp.py` | Counts of equal palette entries between files (no values printed) |
| `used.py` | The pixel index ranges each picture uses |
| `egacmp.py` | Each palette's entries 0..15 compared with the driver's default table |
| `rects.py` | Draws every cut rectangle of SP257, TER257, SP299, SPRITES, ICONPG1, ICONPGA and ICONPGT1 over the decoded picture, plus `TORCH.png`, into `view/`; I looked at all of them |
| `myfont.py` | An independent `FONTS.CV` parse from G:0000:1328/115D/11AE/0FAC |
| `mytexts.py` | An independent section-file parse and lookup simulation (counts only) |
| `misc2.py` | The line files, and the cycling records at R:25CF |
| `birthtab.py` | The Birth cycling table |
| `iconidx.py`, `iconidx2.py` | The ICONPG index tables (counts only) |
| `unittab.py` | The unit table |
| `str4126.py`, `str2fee.py` | Short DGROUP strings; the low-16 map at DGROUP:19FE |
| `cbwtest.py` | How capstone prints CBW and CWD in 16-bit mode |

I ran the tools' own checks: `pic.py check` (PIC_OK), `fontcv.py check` (FONTCV_OK) and
`texts.py check` (TEXTS_OK). `fontcv.py view --out` went into my scratch folder only. I deleted
the older contents of `scratch-r2` (unreviewed, from the cut-off first attempt) before starting.

Nothing else was written. No DOS program was executed, nothing was installed, Ghidra was not
used, and there was no git staging or commit.

Evidence labels below: **DOS file** (my scripts on `build/dosdata`), **DOS listing** (the
listings or my own capstone decode of the same bytes), **inferred**, **unknown**, **PC fact**
(general VGA knowledge, said where it carries a conclusion).

## 1. Claims checked

### 1.1 FORMATS.md (31 claims)

| # | Claim | Section | Result | Method |
|---|---|---|---|---|
| F1 | 106 PIC and 38 PAL; a PAL is 782 bytes: `M0` plus an `X0` of length 4 with width = height = 0 | 1.2, 5 | Confirmed | DOS file: `mypic.py`, `cmp_pic.py` |
| F2 | `E0` length 258, `M0` length 770; first/last 0/255 in every file; maximum value 63 | 1.2, 5 | Confirmed (every palette's maximum is exactly 63) | DOS file: `chunkfacts.py` |
| F3 | X header order: length, width, height, then the code-width byte (11 in all files), clamped to 11 at R:0000:125F | 1.2, 1.3, 5 | Confirmed | DOS listing R:0000:1138..119F, 1227..1268; DOS file |
| F4 | The chunk walk: mode 0 → BA08, mode 1 → BA06 and slot 28, mode > 1 → DGROUP:mode, any other tag → BA06 and slot 28; slot 28 called with null first | 1.3 step 2 | Confirmed | DOS listing R:0000:108E..1135 |
| F5 | The X1 flag is bit 0 of the tag's second byte, stored in DGROUP:68F7; the length goes to 68E6 | 1.2, 1.3 | Confirmed | DOS listing |
| F6 | The word reader: 512 bytes at D936, end DB36h, no EOF test | 1.1, 1.3 step 1 | Confirmed | DOS listing R:1FA1:05E0/0644, R:0000:1242..125B; DOS file (DGROUP:5528) |
| F7 | Dictionary: 2048 three-byte entries at BA06; width 9, mask 1FFh, next 100h; RLE state cleared | 1.3 step 4 | Confirmed (R:0000:1270..1291; RLE at 1231..1236). Extent not drawn out: R2-17 | DOS listing |
| F8 | Codes LSB first; `c == next` case; width growth; immediate reset past the maximum; no clear or end code | 1.3 step 5 | Confirmed | DOS listing R:0000:1318; `mypic.py` |
| F9 | 1,019,502 codes; 100h never occurs; `c == next` 15,671 times | 1.3 step 5 | Confirmed exactly | DOS file: `mypic.py` |
| F10 | RLE: 90h 0 is a literal; 90h n gives n in all; n = 1 wraps; never occurs | 1.3 step 6 | Confirmed (n = 1 gives 256 more copies) | DOS listing R:0000:12BC..12EB; DOS file |
| F11 | X1 rows take (w + 1) / 2 bytes, low nibble first; the LZW and RLE states run across rows | 1.3 step 7 | Confirmed | DOS listing R:0000:12A6..12FE; DOS file |
| F12 | Every picture decodes exactly and consumes the file to its last byte or word; no stale dictionary references | 1.3 | Confirmed: pixel SHA-256 equal to `pic.py` for all 144 files | DOS file: `cmp_pic.py` |
| F13 | The prompt's size exceptions, the no-`E0` list and the X1 list | 5 | Confirmed | DOS file |
| F14 | G:0000:0162 accepts only `M0` and sends first..last to the DAC | 1.4 | Confirmed | DOS listing |
| F15 | "The exact pacing is not analysed" | 1.4, Open 4 | Stale: R2-9 | DOS listing (own decode of G:0000:01B8..01EC) |
| F16 | G:0000:03DF copies (w + 1) / 2 words; odd widths copy one extra byte | 1.4 | Confirmed, with no clip to the width (note R2-21) | DOS listing |
| F17 | `FONTS.CV` is loaded at data:0630 of MGRAPHIC: header words 2Ah = 013Ch and 2Ch = 0630h; segment from cs:[1988h] | 2.1 | Confirmed | DOS listing R:0000:0A76..0B1E; DOS file (MZ header, relocation) |
| F18 | Slots 4, 12 and 21: advance, line height, string draw | 2.1 | Confirmed | DOS listing G:0000:115D..11AE, 11D7 |
| F19 | Slots 11 and 16 address data:0630 + offset; R:1FA1:02E6 "agrees with the layout" | 2.1 | Wrong: R2-3 | DOS listing G:0000:10E8..115C |
| F20 | Header at P - 8 .. P - 1; width table at P - 8 - k .. P - 9 | 2.2 | Confirmed | DOS listing G:0000:1358..1380; DOS file: `myfont.py` |
| F21 | The 9-font metrics table; the fonts tile the file with one padding byte between fonts 4 and 5 | 2.2 | Confirmed in every cell | DOS file: `myfont.py` |
| F22 | No ink in the extra rows; font 1 code 5Fh has width 9 and its borrowed column is blank | 2.2, 2.3 | Confirmed (5Fh is the only glyph wider than 8 x bytes-per-row) | DOS file |
| F23 | Glyph rows are byte-swapped words; codes out of range are skipped; bytes 80h and above set the colour | 2.3 | Confirmed | DOS listing G:0000:0F9C..0FF7 |
| F24 | "Bit 0 set = opaque" | 2.3 | Imprecise: R2-10 | DOS listing G:0000:0FC4, 103D, 1364..1371 |
| F25 | The section files: 528-byte index; first `*` at 530 (532 in BLURB3); every number in the 3.4 table | 3.2, 3.4 | Confirmed, all 9 rows | DOS file: `mytexts.py` |
| F26 | The hash, probe, scan and cache write of R:1F4D:01AD | 3.3 | Confirmed: the simulation finds every name at its first name line | DOS listing; DOS file |
| F27 | The line files: INTRO 965 bytes, 13 lines, line 13 one character; CREDITS 24 lines, longest 25; STORY 56 lines, 52 records, 8 one-character records, longest 43 | 3.5 | Confirmed | DOS file: `misc2.py` |
| F28 | `%` in CREDITS is drawn with font 5, whose 25h glyph is a dot; 28h..2Eh hold "a wide decorative graphic (widths 14 to 16)" | 3.5, 5 | The conclusion is confirmed; the details are imprecise: R2-11 | DOS listing O2:19A3 → R:0182:00B3 → G#21; DOS file |
| F29 | Pointer: TORCH.PIC (X1, 13x14) loaded by R:1FA1:044C in mode 0 into DGROUP:6E92; hot spot 0, 0; colour 0 transparent | 4 | Confirmed | DOS listing R:01A8:00E2..0145, R:0000:1697; DOS file (`TORCH.png`) |
| F30 | INT 33h functions 0, 0Ch (handler R:0000:17DB, mask 1Fh) and 3; the x shift DGROUP:587C | 4 | Confirmed | DOS listing R:0000:163E..17DB |
| F31 | "In play, R:0403:10AB picks one of 8 shapes from DGROUP:D4CE" | 4 | Wrong: R2-1 | DOS listing R:0403:0FFD..10B8 |

### 1.2 PALETTE.md (25 claims)

| # | Claim | Section | Result | Method |
|---|---|---|---|---|
| P1 | The default table at data:0050: 0..15 are the standard EGA colours; 16..31 are greys in 7 levels | 2.1 | Confirmed (the EGA set is a PC fact) | DOS file: `egacmp.py` |
| P2 | MapLow16Colours is called with an "identity map, border 0" at DGROUP:19FE | 2.1 | Wrong: R2-6 | DOS file: `str4126.py` |
| P3 | LoadPaletteBlock acts only on `M0` | 2.1 | Confirmed | DOS listing G:0000:0162..0175 |
| P4 | The DAC writer writes k entries during retrace, then 13·k more | 2.1 | Confirmed | DOS listing (own decode of the unlisted G:0000:01B8..01C3, 01E1..01EC) |
| P5 | Outputs of R:0000:108E: "DGROUP:68E6 (X0/X1 flag)" | 2.2 | Wrong address: R2-8 | DOS listing |
| P6 | Fade set-up: F = 6·steps; E = min(256, M/14); p = floor(E·F/256); weight step 65,536/(p − 1) | 2.3 | Confirmed | DOS listing R:0000:04AA..0554, 050C |
| P7 | R:0000:05B7: interpolation with rounding; weight saturates | 2.3 | Confirmed | DOS listing |
| P8 | R:0000:0382: count = min(hi − lo + 1, 16); colours captured at set-up; R:0000:03FA steps ±3; R:0000:042B does no restore | 2.4 | Confirmed | DOS listing R:0000:0382..0467 |
| P9 | R:25CF: CPU word at 0000, eight record pointers at 0002 ending FFFFh, records 66h long at 0014 + 66h·i, all zero in the file | 2.4 | Confirmed | DOS file: `misc2.py` |
| P10 | Intro slot 1 (rate 14, entries 146..152); logo slot 4 (rate 14, entries 224..239) | 4 | Confirmed | DOS listing O2:02E4..0334, 0A45..0AD7 |
| P11 | Map slots 1..3 (rate 15): 96..103, 104..111, 112..127; call sites R:01A8:086F, O2:1520, O18:024B | 2.4, 4 | Confirmed for R:1DC4:05DD and R:01A8:086F; the other two sites not opened | DOS listing |
| P12 | Birth table R:2710:0000: 131 bytes, 41 triples in 8 groups (3, 7, 5, 8, 5, 4, 4, 5); reached through DGROUP:6416 | 2.6, 4 | Confirmed (6416 is a relocated word equal to 2710h) | DOS file: `birthtab.py` |
| P13 | One range spans 23 entries; one triple has speed 1, so its rate byte is 44 | 4 | Confirmed | DOS file, DOS listing |
| P14 | R:1DC4:047D: BDEE; entries 0..15 from 6B34; entry 45 set by R:1DC4:0698 | 2.5 | Confirmed | DOS listing |
| P15 | O5:16CA..16F3: `sp256.pal` into BDEE; 48 bytes to 6B34 | 2.5 | Confirmed | DOS listing |
| P16 | R:0238:1BEB copies entries 128..255 from C1D6 to C5BE and fades in 5 steps | 2.5 | Confirmed (384 bytes) | DOS listing R:0238:1B44..1C97 |
| P17 | R:0ADE: 85 entries copied, fade in 30 steps | 2.5 | Confirmed (255 bytes) | DOS listing R:0ADE:1940..19BC |
| P18 | Fade call sites R:01A8:0840 (5), O7:1A39 (8), O7:1A93 (8), R:0238:1B66 (5), R:0238:1C86 (5), R:0ADE:198C (30), O9:124C (8), O19:0EB9 (15) | 3 | Confirmed (8 of the 13 rows); O9:124C's target is incomplete: R2-16 | DOS listing |
| P19 | The picture index ranges of section 5 (BIRTH0, BIRTH1, LOGO, CUSTOM, DIFFS, MAP, sheets) | 5 | Confirmed | DOS file: `used.py` |
| P20 | LOGO differs from BIRTH0/1 only in 5, 7, 8, 11, 15 and 224..254; BIRTH1 uses entry 8; BIRTH0 uses none of them | 5 | Confirmed | DOS file: `palcmp.py`, `used.py` |
| P21 | SP257.PIC, SP257.PAL and SP256.PAL are equal; the SP299 and TER257 differences; DIFFS vs CUSTOM in 5 and 48..79 | 5 | Confirmed | DOS file: `palcmp.py` |
| P22 | Every row of the section 6 table (entries 0..15 against EGA) | 6 | Confirmed, all rows | DOS file: `egacmp.py` |
| P23 | The BACK `.PAL` vs picture differences | 7 | Confirmed | DOS file: `palcmp.py` |
| P24 | BIRTH0.PAL is unused (the Birth digit starts at 1) | 7 | Confirmed (DGROUP:3B64 = 1) | DOS file; DOS listing O7 |
| P25 | Cycling direction labelled **inferred** | 2.4 | The listing settles it: note R2-19 | DOS listing R:0000:044A |

### 1.3 SPRITES.md (25 claims)

| # | Claim | Section | Result | Method |
|---|---|---|---|---|
| S1 | The order of O5:1455: SP299 to page 1 without its palette; G#20 copy to page 2; cuts; G#7 | 2 | Confirmed | DOS listing O5:1455..1AF5 |
| S2 | DF62[i] = (160 + 42i, 142, 41, 58) | 3 | Confirmed; lands on the art | DOS listing; DOS file (`SP299-rects.png`) |
| S3 | T[t][m] = (16m, 16t, 16, 16) at B886 + 32t + 2m | 4 | Confirmed | DOS listing O5:14FF..1577; DOS file (`TER257-rects.png`) |
| S4 | The DGROUP:1A3E rule: rows 0..5 cut in all 16 masks only when 1A3E is 0; otherwise only m = 0 | 4 | Confirmed | DOS listing O5:151C..1563 |
| S5 | Coast quarters D294 + 8i + 2k at y 176/184 | 4 | Confirmed | DOS listing; DOS file |
| S6 | River mouths D2D4[d] = (128 + 16d, 176, 16, 16) | 4 | Confirmed | DOS listing; DOS file |
| S7 | EGA: T[i][0] and T[i][1] from SPRITES.PIC rows 0 and 16 | 5 | Rectangles confirmed; see note R2-20 | DOS listing O5:1667..16B1; DOS file (`SPRITES-rects.png`) |
| S8 | Step 7: SP257 to page 1; SP256.PAL M0 to BDEE; 48 bytes from BDF4 to 6B34 | 2 | Confirmed | DOS listing O5:16B3..16F3 |
| S9 | Roads B27A, railroads B29A, B2BA | 6.1 | Confirmed | DOS listing; DOS file (`SP257-rects.png`) |
| S10 | Rivers 6DFE[i] (row 64) and 6E1E[i] (row 80), i 1..15 | 6.1 | Confirmed | DOS listing; DOS file |
| S11 | Unexplored edges 7EEC; Grassland marker B880 = (153, 41, 7, 7) | 6.1 | Confirmed | DOS listing; DOS file |
| S12 | Palace strips D21C/D244/D26C = (160 + 7i, 0/16/32, 7, 15) | 6.2 | Confirmed | DOS listing; DOS file |
| S13 | D4CE[0..6] = (16i, 32, 16, 16); [0] and [1] empty; [2] the "GO" arrow | 6.3 | Confirmed | DOS listing; DOS file |
| S14 | D4DE[i] = (129 + 8(i & 3), 33 + 2(i & 4), 7, 7) | 6.3 | Confirmed | DOS listing O5:1897..18D7; DOS file |
| S15 | D4EE[t] = (16t + 1, 113, 15, 15) for t 0..15; D50E[i] = (16i + 1, 97, 15, 15) | 6.3 | Confirmed | DOS listing; DOS file |
| S16 | Units: copy (0, 160, 320x32) → (0, 128); the recolour rules; cuts (16(j mod 20) + 1, 16(j div 20) + 129, 15, 15) for j 0..27 | 6.4 | Confirmed | DOS listing O5:19B5..1AE8 |
| S17 | Unit table at DGROUP:1138, stride 22h; byte 0 is the domain (0, 1, 2) | 6.4 | Confirmed (16 land, 3 air, 9 sea; the record's name is at 112Ah, 0Eh earlier) | DOS file: `unittab.py` |
| S18 | Citizens 6E96[i] = (8i, 128, 8, 16); newspaper edge DF0C = (176, 128, 20, 9) | 6.5 | Confirmed | DOS listing; DOS file |
| S19 | The play palette applied at R:01A8:0863 | 2 | The call is at R:01A8:0867 (0863 is the string push): R2-12 | DOS listing |
| S20 | R:0000:1697(shape, 0, 0) at R:01A8:0889, R:0403:045F, 094F, 0AE0 | 6.5 | Argument order and sites imprecise: R2-12 | DOS listing |
| S21 | ICONPG1..8 grid: (1 + 111c, 1 + 69r), 110x68, centred on (62, 42) | 8 | Confirmed | DOS listing O8:0774..07AF; DOS file (`ICONPG1-rects.png`) |
| S22 | Every ICONPG picture has "its own palette file"; the civilopedia "applies `iconpg<n>.pal`" | 8 | Wrong: R2-2 | DOS file; DOS listing O8:0768, 0A1C, 0AFB, O16:0100 |
| S23 | "Entry n of a 72-entry byte table at segment [6420]:0000 (O8:16C4)" | 8 | Inverted; there are three tables, and their location is settled: R2-5 | DOS listing O8:16C4..16F6, 1790..17F5; DOS file: `iconidx.py`, `iconidx2.py` |
| S24 | Only the ICONPG1..8 grid is given | 8 | Incomplete: R2-5 | DOS listing O8:0A28..0A5C, 0B25..0B62 |
| S25 | D4DC holds the TORCH shape; "[2] users not traced" | 6.3, Open 2 | D4CE[2] is the alternate in-play pointer: R2-1 | DOS listing R:0403:108B..10B8 |

### 1.4 Tools

| Item | Result | Method |
|---|---|---|
| Embedded DOS bytes in `pic.py`, `fontcv.py`, `texts.py`, `png.py` | None. They hold only format constants (512, 11, 90h and so on) and names. | Read in full |
| `pic.py` decode | Matches my independent decoder on all 144 files: sizes, chunk lists and the pixel SHA-256 of every picture | DOS file: `cmp_pic.py` |
| `pic.py` paths the files never exercise | Differ from the listing in one point that does not matter for these files: note R2-22 | DOS listing |
| `fontcv.py` metrics | Agree with `myfont.py` | DOS file |
| `texts.py` section records | Agree with `mytexts.py` (all numbers of FORMATS 3.4) | DOS file |
| Output locations | Defaults are under `build/dos/view/`, but `--out` is unrestricted: R2-18 | Read |

## 2. Findings

### Blockers

**R2-1. Blocker. FORMATS.md 4 (last row), also Open 9, SPRITES.md 6.3 rows 0..6 and 7 and Open 2, OPEN.md L5 and L10.**

*Claim.* "In play, R:0403:10AB picks one of 8 shapes from DGROUP:D4CE"; which situation selects
each shape is left open. SPRITES lists the user of D4CE[2] (the "GO" arrow) as untraced.

*Found (DOS listing).* The site uses only two shapes.
- R:0403:108B tests the local flag [bp-36h]. When it is non-zero the shape is D4CE[7] = D4DC,
  the torch (R:0403:1094); otherwise it is D4CE[2], the "GO" arrow (R:0403:109A).
- The site pushes the word at `[bx - 2B32h]` (DGROUP:D4CE + 2·index), then 0, 0, and calls
  R:0000:1697. The argument order is (hot x, hot y, shape), with a hot spot of 0, 0.
- R:0403:10B3 then flips the flag (`xor [bp-36h], 1`), so successive passes alternate torch and
  arrow.
- The branch is taken at R:0403:0FFD..1004 when DGROUP:1A3C (the set-up's mouse choice) is
  non-zero. It is reached from R:0403:1B27. The game situation of that case is not traced.

No other pointer shape is selected anywhere in the R:0403 code I read. D4CE[0..1] are empty and
[4..6] are map overlays, so "8 pointer shapes" would send D1 toward mapping cursors onto
irrigation, mine and pollution sprites.

*Correction.* Replace the row with: "in play, at R:0403:108B..10B8 (mouse active), the pointer
alternates between the torch (D4CE[7]) and the GO arrow (D4CE[2]) on every pass; the situation
of the case reached from R:0403:1B27 is open". Narrow Open 9, SPRITES Open 2 and OPEN L5/L10 to
that situation.

**R2-2. Blocker. SPRITES.md 8 (first paragraph).**

*Claim.* ICONPG1..8, ICONPGA..E and ICONPGT1..2 each have "their own palette file (`.PAL`)", and
the civilopedia "applies `iconpg<n>.pal` with R:1DC4:047D".

*Found.*
- **DOS file.** Of the 17 ICONPG* files, only `ICONPG1.PAL` and `ICONPGA.PAL` exist. The
  palettes of ICONPG2..8.PIC equal ICONPG1.PAL, and those of ICONPGB..E.PIC equal ICONPGA.PAL.
- **DOS listing, the advance path.** The picture name is built in DGROUP:BA06 with its digit
  patched (O8:073B..0754). The palette name, however, is the constant `iconpg1.pal` at
  DGROUP:3CE6 (O8:0768 → R:1DC4:047D at 076C). No write to that string exists.
  - O16 uses its own constant `iconpg1.pal` (DGROUP:4A36, O16:0100..0104).
  - R:0ADE uses `iconpg1.pal` into C5BE.
- **The ICONPGA path** uses the constant `iconpga.pal` (DGROUP:3D4E, O8:0A1C..0A20).
- **The ICONPGT path** does not use R:1DC4:047D. It loads `sp256.pal` into C5BE (O8:0AFB..0AFF),
  applies it with G#28 (O8:0B0B), and then sets DAC 253 to a fixed grey through R:1DC4:0698
  (O8:0B13..0B1D). The ICONPGT pictures' own palettes differ from SP256 in entries 17..31,
  96..97, 109..110 and 224..255 (DOS file). So the ICONPGT cells are shown with colours other
  than their own in those entries, and without the 6B34/entry-45 step.

A D1 loader built on the text would ask for 13 files that do not exist (prompt 5.9 makes a
missing file fatal under `--graphics dos`). It would also give ICONPGT the wrong palette.

*Correction.* State the three palette rules exactly as above, with their addresses, and say that
only ICONPG1.PAL and ICONPGA.PAL exist. The same correction applies to the "ICONPG palettes" row
of SCENES-PLAY.md 7.13 and to DOS-PROFILE.md E11 (R3 scope).

### Majors

**R2-3. Major. FORMATS.md 2.1, the slot 11 and 16 rows and the R:1FA1:02E6 paragraph.**

*Claim.* Slot 11 returns a "far pointer to font n's bitmap (data segment, 0630h + offset)".
R:1FA1:02E6 reads through it and "agrees with the layout below".

*Found (DOS listing).*
- G:0000:10E8 compares n with the word at **data:0020** (G:0000:10F5) and returns 0630h + the
  word at data:0020 + 2n (G:0000:1100..1104).
- G:0000:110D does the same (G:0000:111E, 1129).
- Slots 4 and 12 and the set-up read the table at data:0630 (G:0000:1172, 117C, 1358).

DRIVER.md (G#11, G#16 and Open 1) and OPEN.md X3 already record this as an inferred defect. The
two documents conflict. There are no live callers: R:1FA1:02E6 is reached only by the prologue
scan, and slot 16 has no caller.

*Correction.* Say that slots 11 and 16 index a table at data:0020 (copyright text in the file),
not data:0630. Say that R:1FA1:02E6 would therefore not agree with the layout. Cross-reference
DRIVER.md G#11/G#16.

**R2-4. Major. FORMATS.md 1.4; PALETTE.md 1 and 2; OPEN.md (no entry). The 6-to-8-bit rule
required by prompt 5.9.**

*Claim.* FORMATS 1.4 says the values go to the DAC unchanged as 6-bit DAC values (inferred) and
that the viewer's `v * 255 / 63` is "a viewer choice".

*Found.*
- The prompt requires "one recorded rule, a platform fact (inferred)" for the profile. No
  document records a rule for the profile, and OPEN.md has no P item for it.
- The viewers use `v * 255 // 63` (floor).
- Nothing in the listing scales the values: the DAC writer G:0000:01A1 and R:0000:0631/044A
  output the 6-bit bytes as they are (DOS listing). So the rule can only be a platform fact.

*Correction.*
- In FORMATS 1.4 (or PALETTE 1), record: "the DAC holds 6-bit values (PC fact); the profile
  converts each value v by one rule, `<rule>`, **inferred**", choosing the rule (for example the
  viewers' floor(v·255/63)).
- Relabel the viewer's formula as an application of that rule.
- Add a P item in OPEN.md if D1 is to choose it.

**R2-5. Major. SPRITES.md 8 and Open 8; OPEN.md L10.**

*Claim.*
- 8 gives only the ICONPG1..8 grid.
- "Advance pictures: entry n of a 72-entry byte table at segment [6420]:0000".
- Open 8: "ICONPG cell tables (segment [6420]) come from a file not identified here".

*Found (DOS listing).*
- **The ICONPGA..E grid** (O8:0A28..0A5C) is cell n at (1 + 160(n & 1), 61((n mod 6) div 2)),
  158x61, centred on (88, 42). The file letter is 'a' + n div 6 (O8:09FF..0A08).
- **The ICONPGT1..2 grid** (O8:0B25..0B62) is (1 + 107(n mod 3), 5 + 87((n mod 6) div 3)),
  106x77, centred on (76, 46). The file digit is '1' + n div 6 (O8:0AD3..0ADC).
- Both grids appear in SCENES-PLAY.md 7.13. SPRITES.md, the document prompt 6.5 names for ICONPG*
  rectangles, does not have them.
- **Each lookup is an inverse search.** O8:16C4 scans the advance bytes for the first entry equal
  to the advance number. It returns that index (the cell), or −1 (O8:16CA..16F0). Each byte is
  sign-extended (98h, shown as `cwde`, is CBW).
- **There are three tables, not one.** DGROUP:6420 is a relocated word equal to 271Eh, so the
  tables lie in the root image at R:271E (DOS file: `iconidx.py`, `iconidx2.py`).

| Table | Searched by | Bytes | Used for |
|---|---|---|---|
| Advances | O8:16C4 | R:271E:0000..0047 (72) | ICONPG1..8, 9 cells each |
| Units | O8:1790 | R:271E:0044..005F (28) | ICONPGA..E, 6 cells each |
| Third table | O8:17C3 | R:271E:0061..006C (12) | ICONPGT1..2, 6 cells each |

  - The advance search range overlaps the unit table at 0044..0047.
  - Those four bytes repeat values found earlier in 0000..0043, so the first match always lies
    before them. That is why the 72 bytes hold only 68 distinct values.
  - One advance byte is FFh, an unused cell. Byte 0060 is FFh.
  - SPRITES 8 names only the first table and none of the three search routines' ranges.

*Correction.*
- Add the two grids with their addresses.
- Reword the lookups as "cell = the first index whose byte equals the number, −1 if none".
- Record the three tables with their offsets and the overlap, and close Open 8 and that part of
  L10.

**R2-6. Major. PALETTE.md 2.1 (MapLow16Colours row); also SCENES.md 3 (R3 scope).**

*Claim.* O2:020E calls MapLow16Colours with DGROUP:19FE, "identity map, border 0".

*Found (DOS file).* The 16 map bytes at DGROUP:19FE are the identity except byte 5, which is 0.
The border byte is 0. So DAC 5 receives default entry 0 (black), not EGA colour 5. PALETTE 5's
first row ("0..15 = EGA") inherits the error.

There is no visible effect, because the screen is black and LOGO.PIC's palette replaces the
entries.

*Correction.* Write "identity except entry 5 → default entry 0; border 0". Adjust PALETTE 5 row 1
and SCENES.md 3.

**R2-7. Major. Prompt 5.9 "every DOS data table the profile needs … read from the DOS image at
recorded offsets": SPRITES.md 3..7, PALETTE.md 4.**

*Found.* Most of the profile's "tables" are code immediates inside loops, not data tables:
- the cut rectangles of O5:1455 (for example (16m, 16t, 16, 16) in O5:1538..154F);
- the cycling ranges and rates at O2:02F4, O2:0AA0 and R:1DC4:05DD;
- the ICONPG grids (R2-5).

The drafts give them as formulas with the address range of the code. They give no image offset
of each immediate, and no document says which items are true data tables at image offsets. True
data tables with recorded offsets do exist:
- the Birth table R:2710:0000;
- civilization colours DGROUP:1946/1956;
- direction steps DGROUP:1882/18E4;
- terrain names DGROUP:0282;
- the unit table DGROUP:1138;
- the three ICONPG tables at R:271E:0000, 0044 and 0061 (R2-5).

D1 cannot meet "read from the DOS image" for the immediates without this classification
(**inferred**: a decision for D1, but D0 must supply the facts).

*Correction.* Add a short table to SPRITES.md (and a line to PALETTE.md 4) with these columns:
- the item;
- **data table** (with its image offset) or **code immediate** (with its instruction range, plus
  per-immediate offsets where D1 is to read them);
- the label.

### Minors

**R2-8. Minor. PALETTE.md 2.2 "Outputs".** "DGROUP:68E6 (X0/X1 flag)" is wrong. 68E6 is the X
chunk's length word (R:0000:115C, as FORMATS 1.2 says), and the flag is the byte DGROUP:68F7
(FORMATS 1.3). *Correction.* Write "DGROUP:68F7 (X1 flag, byte), 68E6 (length, unused)".

**R2-9. Minor. FORMATS.md 1.4 and Open 4.** "The exact pacing is not analysed" is stale.
PALETTE.md 2.1 gives it from the bytes: k entries during retrace, then 13·k more without
waiting. I confirmed it with my own decode. The listing omits G:0000:01B8..01C3 and 01E1..01EC
because `disasm.py` does not follow the `loop` target at G:0000:01DB. *Correction.* Cite
PALETTE.md 2.1 and TIMING.md 3.7 and close Open 4. Note the listing gap for R1.

**R2-10. Minor. FORMATS.md 2.3 "Mode" (prompt 5.10 glyph semantics).** The draft says "bit 0
set = opaque".
- The opaque path is taken only when the low byte of context +0Ah **equals 1**
  (G:0000:0FC4 → [60E], `cmp [60E], 1` at G:0000:103D).
- Bit 0 alone adds the extra rows (G:0000:1364..1371).
- Not mentioned: the raster operation. The high byte of the colour word (+0Dh) goes through
  G:0000:020C (table at G:0000:0208: store, AND, OR, XOR) into the opcode at G:0000:105D.
- Not mentioned: the clipping (G:0000:125C, 1208, 12BE). It is only named.

*Correction.* Correct the mode rule, add the raster operation, and refer to DRIVER.md G#21 for
the clipping.

**R2-11. Minor. FORMATS.md 3.5 and 5 (font 5 around `%`).** DOS file (`myfont.py`):
- Glyph 25h is 3 wide with 5 inked pixels in a 3x3 box (a small plus shape) at rows 12..14.
- Codes 28h..2Eh have widths 16, 16, 16, 4, 16, 16, 14 (2Bh is 4 wide, so not "14 to 16").
- They form two graphics, a banner at 28h..2Bh and an emblem at 2Ch..2Eh, not one.

The conclusion (`%` shows a full stop in font 5 only) stands. *Correction.* Give the widths and
the two graphics, and say "a small dot" instead of "3 x 3 dot".

**R2-12. Minor. SPRITES.md 6.5 (DGROUP:6E92 row) and 2; consistency with FORMATS.md 4 and
PALETTE.md 5.**
- SPRITES gives R:0000:1697 as "(shape, 0, 0)", which is the push order. The C argument order is
  (hot x, hot y, shape), as FORMATS 4 says.
- The cited sites R:01A8:0889, R:0403:045F, 094F and 0AE0 are the first pushes. The calls are at
  R:01A8:0891 and R:0403:046B, 095B and 0AEC.
- R:01A8:0139 and R:0403:10AB are missing from the list.
- SPRITES 2 cites R:01A8:0863 (the string push) for the play-palette load, while PALETTE 5 cites
  the call at R:01A8:0867.

*Correction.* Use the call addresses and the argument order of FORMATS 4.

**R2-13. Minor. SPRITES.md Open 5.** "The 48 bytes copied to DGROUP:6B34: users not traced" is
answered by PALETTE.md 2.5/2.6: R:1DC4:047D restores entries 0..15 from 6B34. *Correction.*
Close it with a cross-reference (and the matching part of OPEN.md L10).

**R2-14. Minor. FORMATS.md 1.1, the R:1FA1:0288 row.** The list of `.PAL` loads is incomplete.
It omits:
- O7:1A83 (`BIRTHn.PAL` → C5BE);
- O9:1210 (`KING<NN>.PAL` → C1D6; the name is the picture name with "pal" copied over the
  extension at O9:11F8..1200).

It also leaves R:0238:1C52 and R:0ADE:1958 "not followed", although PALETTE.md 2.5/7 follows
them. *Correction.* Complete the list, or point to PALETTE.md 7 as the full list.

**R2-15. Minor. FORMATS.md 3.3, the R:1F4D:0000 bullet.** Two details from the DOS listing are
missing:
- the width break turns a space into a line feed only when the column count has passed
  `columns` **and the next byte is not a space** (R:1F4D:0042..0050). A `^` turns the next byte
  into a line feed unconditionally (R:1F4D:001C..0021), as the draft says;
- the routine appends a line feed (the string at DGROUP:2FEE) when the last line is not empty
  (R:1F4D:006E..007C).

The callers' line counts depend on both. *Correction.* Add both details.

**R2-16. Minor. PALETTE.md 3 (O9:124C row), 2.6 (C1D6 row) and 7 (`SLAM1.PAL` row).** The O9
fade target is not plain `SLAM1.PAL`.
- O9:1210 loads `KING<NN>.PAL` into C1D6.
- O9:1220 loads `SLAM1.PAL` into BDEE.
- O9:1228..1242 copies bytes C0h..1AFh (entries 64..143) from C1D6's triples into BDEE's.
- O9:124C fades in 8 steps.

This is all DOS listing. SCENES-PLAY.md and DOS-PROFILE.md P37 already say "SLAM1.PAL with KING
64..143". *Correction.* Add the splice to the three rows.

**R2-17. Minor. FORMATS.md 1.3 step 4 and PALETTE.md 2.6: the dictionary's extent.** The reset
clears 0x800 three-byte entries from BA06, so the region is BA06..D205 (DOS listing
R:0000:1282..1291). It covers every palette buffer of PALETTE 2.6 except 6B34: BA06, BD06, C006,
BDEE, C1D6 and C5BE.
- Every decode of a `.PIC` clears them. That includes a palette-only load of a picture
  (R:1FA1:026C), because R:0000:108E calls R:0000:1227 at R:0000:119F before R:1FA1:01D3 zeroes
  the height.
- A `.PAL` load does not (R:0000:1227 returns at 1230 when width and height are 0).
- The O8 advance path even builds the picture's name in BA06 (O8:073F).

Every order I checked loads the `.PAL` after the last picture decode and fades before the next:
O7 Birth, R:0238:1BEB, R:0ADE, O9:1210..124C and O19:0EA9..0EB9. So nothing is broken, but the
safe order is a constraint D1 must keep if it shares buffers. *Correction.* Add the extent and
the "a picture decode clears these buffers" rule to PALETTE.md 2.6.

**R2-18. Minor. `gen/dos/pic.py:364`, `fontcv.py:175`, `texts.py:348`.** The `--out` option
accepts any directory. Prompt 6.1 says viewer output goes to `build/dos/` only. The defaults
comply. *Correction.* Refuse an `--out` that does not resolve under `claude/port/build/`, or
state the rule in the usage text.

### Notes

**R2-19. Note. PALETTE.md 2.4 "Direction".** The direction is labelled **inferred**, but it
follows directly from the position update in R:0000:044A, so it can be labelled **DOS listing**.

**R2-20. Note. SPRITES.md 5 (EGA, out of scope).** In the EGA path, page 1 holds the SPRITES.PIC
copy, and SPRITES.PIC row 64 holds the ocean cells (the draft's own words). So section 6.1 cuts
the river table 6DFE from ocean cells: the EGA sheet is not exactly "SP257's layout".
T[10]/T[11] at (160..191, 0/16) fall on non-terrain art (DOS file, `SPRITES-rects.png`).
Harmless while EGA stays out of scope.

**R2-21. Note. FORMATS.md 1.4 and Open 5 (odd widths).** G:0000:03DF does not clip to the
picture's width. So for SLAG2/SLAM2 (197 wide) a 198th pixel per row comes from the row buffer
DGROUP:E17E at byte 197, which still holds an earlier, wider picture's row (DOS listing). The
profile should draw only `width` pixels, with a register entry, unless the scene shows that
column.

**R2-22. Note. `pic.py` (Decoder `__init__`, `lzw_byte`).** The tool starts each picture with
`prev = None`, uses 0 as the first entry's prefix, and raises an error if the first code is not
a literal. In the listing, [68F8] is never reset (R:0000:1227 and 1270 leave it): it is 0 at
program start (DGROUP initial value) and afterwards it holds the previous picture's last code.
No shipped file depends on this (no entry 100h is ever referenced, `mypic.py`). A D1 decoder
that keeps "prev" across pictures would follow the listing exactly. The tool's comment already
says "unknown value".

**R2-23. Note (R3 scope). CORRESPONDENCE.md line 315.** "A 1-pixel shadow in colour 0 on both
sides" is ambiguous. R:0182:0086 draws colour 0 at (x, y + 1) transparent, then the text at
(x, y), both through R:0182:005C (DOS listing). The DOS shadow is below only.

**R2-24. Note (R1 scope).** Capstone 5.0.7 prints 98h/99h as `cwde`/`cdq` in 16-bit mode
(`cbwtest.py`). In the listings these are CBW/CWD (for example O8:16E6, O8:0A3B). The loop-target
gap of R2-9 is the other listing artefact I met.

## 3. Completeness

### FORMATS.md

| Required item (prompt) | Status |
|---|---|
| PIC/PAL layout, decode, readers, failure behaviour (6.5, 5.9) | Present |
| Section 3 facts on `*.PIC`/`*.PAL` verified | Present (5) |
| `M0` palette range handling, `X0` vs `X1`, LZW, RLE, odd widths | Present (odd-width effect left open; note R2-21) |
| 6-to-8-bit rule as a recorded platform fact (5.9) | Partial (R2-4) |
| `FONTS.CV` loading, header, width table, bitmap, metrics (5.9, 6.5) | Present (slots 11/16 wrong: R2-3) |
| Glyph semantics: spacing, colours, shadow, clipping (5.10) | Partial (R2-10; shadow only in SCENES/CORRESPONDENCE) |
| Character handling: out-of-range codes, bytes 80h and above, the DOS program's own substitution (5.10) | Present (2.3, 3.5) |
| Text files: prefixes, CP437 text, lookup, roles (3, 5.9) | Present |
| Mouse pointer (5.9) | Partial (in-play selection wrong: R2-1) |
| EGA out of scope recorded (5.9) | Present (1.5) |
| Viewers write under `build/dos/` only (6.1) | Partial (R2-18) |
| Address, inputs, outputs, effects, failure, confidence, label per contract (6.5) | Present |

### PALETTE.md

| Required item (prompt) | Status |
|---|---|
| Palette set: driver and root writers, contracts (6.5) | Present (identity-map error: R2-6) |
| Fades: routines, steps, frames, call sites | Present |
| Cycling: slots, ranges, rates, direction, start/stop | Present |
| Colour bases per scene (start-up and UI; play delegated) | Present |
| `.PAL` file roles | Present (O9 splice missing: R2-16) |
| Palette buffers and their interaction with the decoder | Partial (R2-17) |
| 6-to-8-bit rule (5.9) | Absent (R2-4) |
| Cycle ranges and timings "at recorded offsets" (5.9) | Partial (Birth table yes; immediates unclassified: R2-7) |
| EGA out of scope | Present |

### SPRITES.md

| Required item (prompt 6.5) | Status |
|---|---|
| SP257 rectangles → shapes | Present |
| TER257 rectangles → shapes | Present |
| SP299 rectangles → shapes | Present |
| SPRITES (EGA) rectangles | Present (out of scope; note R2-20) |
| TORCH shape | Present |
| ICONPG1..8 grid | Present (palette wrong: R2-2) |
| ICONPGA..E and ICONPGT1..2 grids | Absent here; present in SCENES-PLAY.md 7.13 (R2-5) |
| ICONPG index tables (three), their locations and lookups | Partial: one table named, location open (R2-5) |
| Pointer shapes in play (D4CE[2], [7]) | Partial (R2-1) |
| Data tables vs code immediates, image offsets (5.9) | Partial (R2-7) |
| Windows counterparts | Present (inferred, not re-checked by me) |

## 4. Verdict

The three drafts are careful, well labelled and largely right. About 81 claims were checked
against the bytes and the listing:
- The decoder descriptions are exact. An independent decoder written from the listing reproduces
  every picture bit for bit.
- The font layout and all text-file statistics are exact.
- Almost every palette, cycling and rectangle fact is exact.

I found no DOS bytes in the drafts or the tools, and no claim that looks filled from memory.

Two corrections must come first, because D1 would build on them:
- R2-1: the in-play pointer is a torch/GO-arrow alternation, not one of 8 shapes.
- R2-2: the ICONPG palettes are three fixed rules, and 13 of the named `.PAL` files do not exist.

Five majors should also be applied before D1:
- R2-3: the font slots;
- R2-4: the 6-to-8-bit rule;
- R2-5: the ICONPG grids and the three index tables;
- R2-6: the "identity" map;
- R2-7: the data-table classification.

With those corrections, FORMATS.md, PALETTE.md and SPRITES.md are a sound base for D1. The
minors and notes can follow in the same pass.

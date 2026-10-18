<!-- Resolution record of the D0 review R2 (docs/verify/ext-d0-review-r2.md), extension phase D0,
     written by fixer F2 (an agent; brief docs/verify/BRIEF-d0-fixes.md) on 2026-10-11. Owned and
     edited: docs/dos/FORMATS.md, PALETTE.md, SPRITES.md and the viewers gen/dos/pic.py, fontcv.py,
     texts.py, png.py. Every finding was re-derived from the DOS listings in
     claude/port/build/dos/disasm/ and the DOS files in claude/port/build/dosdata/ before it was
     applied; the scratch scripts are in claude/port/build/dos/scratch-fr2/ (not part of the
     repository). No DOS program was executed; no DOS bytes are quoted. Two further items from the
     design agent D1-E, passed on by the orchestrator, are recorded under "From D1-E". -->

# D0 fixes for review R2 (F2)

Counts: **fixed 19**, **fixed and registered 3** (R2-4, R2-7, R2-21: the facts are corrected in
my files and the design question goes to OPEN.md's P group through F3, below), **rejected 0**,
**outside my files 2** (R2-23 already applied by F3; R2-24 forwarded to F1). Both D1-E items are
fixed.

Kinds: **fixed** (what changed, where); **registered** (a real question for a decision or later
phase, sent for OPEN.md, which F3 owns); **rejected** (the finding is wrong). Evidence column:
how I verified the finding, then what changed.

| Id | Severity | Kind | Verification, then what changed (file, section) |
|---|---|---|---|
| R2-1 | Blocker | fixed | Confirmed (DOS listing R:0403:0FFD..10B8, 09D9..0AEC, 0456..046B, 094A..095B, 1AED..1B27; O5:185D..188F, 1891..1894). Only two pointer shapes exist: the torch (6E92, copied to D4DC = D4CE[7]) and the GO arrow D4CE[2]. Dispatch value 67h in [bp-44h] reaches the case at R:0403:0FFD, which toggles the local flag [bp-36h] once per dispatch (xor at 10B3). With a mouse it sets the arrow when the flag was 0 and the torch when it was 1 (108B..10AB). A click (DB3A = 1) while the flag is set stores the square into the unit record bytes 81DA/81DB (when the unit's domain allows it), clears the flag and restores the torch. Without a mouse the same case starts or ends a keyboard square selection (1007..1088). Changes: FORMATS.md 4 (the "8 shapes" row is replaced; the hot-spot row lists the six R:0000:1697 calls) and Open 9 (narrowed to the inferred game situation, GoTo); SPRITES.md 6.3 rows 0..6 ([2]) and 7 (D4DC), and Open 2 (narrowed). |
| R2-2 | Blocker | fixed | Confirmed (DOS listing O8:0687..0696, 0768, 0A1C, 0AF0..0B1D; O16:0100; R:1DC4:047D; DOS files: only `ICONPG1.PAL` and `ICONPGA.PAL` exist among the ICONPG palettes). Advances use the fixed `iconpg1.pal` and units the fixed `iconpga.pal`, both through R:1DC4:047D. The terrain page uses `sp256.pal` into C5BE, applied by G#28 at O8:0B0B, then DAC 253 := grey (0B13..0B1D). The pictures' own palettes are never applied. DAC 253 is grey before any picture (O8:0687..0696). The advance, improvement and unit pages then get their file's entry 253. Changes: SPRITES.md 8 (palette rules table); PALETTE.md 2.5 (new rows O8:0AF0..0B1D and O8:0687..0696), 6 (ICONPG row) and 7 (`SP256`, `ICONPG*` rows). |
| R2-3 | Major | fixed | Confirmed (DOS listing G:0000:10E8..115C). Slots 11 and 16 index the table at data:0020, which holds copyright text in `MGRAPHIC.EXE` (DOS file), not data:0630. This is an inferred defect. R:1FA1:02E6 therefore would not overwrite the resident font as described. The profile needs neither slot. Changes: FORMATS.md 2.1 (both rows and the R:1FA1:02E6 paragraph; cross-reference DRIVER.md G#11/G#16, which already agrees). |
| R2-4 | Major | fixed and registered | Confirmed. The draft gave the viewers' `v*255//63` as if it were the profile rule. The DAC is linear with full scale 63 (PC fact). Floor, round-to-nearest and bit replication differ pairwise by at most 1, in 30 (floor/round), 30 (floor/replication) and 10 (round/replication) of the 64 values (recomputed). Changes: FORMATS.md 1.4 has a new "6-bit values" bullet with the PC fact, the three candidates and their difference counts; it labels the viewer formula as the viewers' rendering only. PALETTE.md 1 has a new "6-bit values" row. The `png.py` docstring for `vga6_to_8` says the same. The choice goes to OPEN.md P (below). |
| R2-5 | Major | fixed | Confirmed (DOS listing O8:16C4..16F6, 1790..17F5, 17C3; O8:0A28..0A5C, 0B25..0B62; DOS file: R:271E bytes, scratch `tables.py`). The lookup is a first-match search of a byte table for the number, not "entry n". There are three tables: advances R:271E:0000..0047, units 0044..005F and terrain 0061..006C; byte 0060 is FFh. DGROUP:6420 holds the relocated segment 271Eh. Grids: ICONPGA..E cells are 158x61 at (1 + 160 (n & 1), 61 ((n mod 6) div 2)), centred at (88, 42); ICONPGT cells are 106x77 at (1 + 107 (n mod 3), 5 + 87 ((n mod 6) div 3)), centred at (76, 46). Changes: SPRITES.md 8 (cell grids table, the inverse search with the CBW note, the three tables, discovery and quiz reuse) and Open 8 (closed). |
| R2-6 | Major | fixed | Confirmed (DOS file: the 17 bytes at DGROUP:19FE; DOS listing G:0000:010C..0161). The map is the identity except entry 5, which takes default entry 0 (black); the border is 0. Changes: PALETTE.md 2.1 (MapLow16Colours row, relabelled DOS listing and DOS file) and 5 row 1 ("EGA except 5, which is black"). SCENES.md 3 is R3 scope and is already corrected by F3. |
| R2-7 | Major | fixed and registered | Confirmed. Prompt 5.9's "read from the DOS image at recorded offsets" fits true data tables only; many D0 values are instruction immediates. Changes: FORMATS.md has a new section 6, "Data tables and code constants the profile reads". 6.1 lists the data tables at image offsets, each with address, width, count and the describing document; DGROUP's initialised data ends at 6B2Fh. 6.2 lists the constant families inside code by instruction range and states that per-immediate offsets are not recorded. 6.3 lists run-time storage that is never read from the image. Pointers to the registry were added in PALETTE.md 4 and SPRITES.md 1 ("Data or code"). How the profile obtains code immediates goes to OPEN.md P (below). |
| R2-8 | Minor | fixed | Confirmed (DOS listing R:0000:108E..). DGROUP:68F7 is the X0/X1 flag; 68E6 is the X chunk's length, which is not used. Changes: PALETTE.md 2.2 "Outputs". |
| R2-9 | Minor | fixed | Confirmed (own decoding of G:0000:01B8..01EC, whose loop target the listing does not follow). Pacing: k entries during retrace, then 13·k more without testing. Changes: FORMATS.md 1.4 (DAC pacing, citing PALETTE.md 2.1 and TIMING.md 3.7, with the listing gap noted) and Open 4 (closed). |
| R2-10 | Minor | fixed | Confirmed (DOS listing G:0000:0FC4, 103D, 1364..1371, 0208, 020C, 105D). Glyph drawing is opaque only when the style byte's low byte equals 1. Bit 0 adds the extra rows. +0Dh bits 0..1 select store, AND, OR or XOR by patching the opcode at 105D from the table at 0208. Changes: FORMATS.md 2.3 (Mode, a new raster-operation bullet, and a clipping bullet referring to DRIVER.md G#21). |
| R2-11 | Minor | fixed | Confirmed (DOS file, scratch `font5strip.py`). Font 5 glyph 25h is a small dot: 3 wide, a 5-pixel plus shape on rows 12..14. Codes 28h..2Eh have widths 16, 16, 16, 4, 16, 16, 14 and form a lettered banner (28h..2Bh) and a winged emblem (2Ch..2Eh). Changes: FORMATS.md 3.5 and the CREDITS row of section 5. |
| R2-12 | Minor | fixed | Confirmed (DOS listing R:01A8:0863 is the string push, 0867 the call; R:0000:1697 takes (hot x, hot y, shape)). The 6E92 calls are at R:01A8:0139, 0891 and R:0403:046B, 095B, 0AEC; the arrow/torch call is at R:0403:10AB. Changes: SPRITES.md 2 and 6.6 (R:01A8:0867), 6.5 (6E92 row: argument order and call sites); FORMATS.md 4 (hot-spot row). |
| R2-13 | Minor | fixed | Confirmed (DOS listing R:1DC4:047D). The 48 bytes at DGROUP:6B34 are written over entries 0..15 of each palette it applies. Changes: SPRITES.md 2 (user named) and Open 5 (closed); PALETTE.md 2.5 (the callers with constant names and addresses 3CE6, 3D14, 3D4E, 4A36; no code writes those strings). |
| R2-14 | Minor | fixed | Confirmed (DOS listing of all callers of R:1FA1:0288). Changes: FORMATS.md 1.1 (R:1FA1:0288 row: all 15 call sites with buffers and names, including the extension rewrites at O6:2279, O7:1A6B..1A73, O9:11F8..1200 and R:0ADE:1948; every call names a `.PAL`; roles are in PALETTE.md 7). |
| R2-15 | Minor | fixed | Confirmed (DOS listing R:1F4D:001C..0021, 0042..0050, 006E..007C). `^` forces a break unconditionally. The width break happens only when the column count has passed `columns` and the next byte is not a space. A line feed (DGROUP:2FEE) is appended when the last line is non-empty. Changes: FORMATS.md 3.3 (R:1F4D:0000 bullet). |
| R2-16 | Minor | fixed | Confirmed (DOS listing O9:11F8..1200, 1210, 1220, 1228..1242, 124C). O9 loads `SLAM1.PAL` into C1D6 and splices KING colours 64..143 in before the fade. Changes: PALETTE.md 3 (O9:124C row), 2.6 (C1D6 row) and 7 (`SLAM1`, `KING` rows; the O6 splice into `BACK.PAL` with G#28 at O6:230A). |
| R2-17 | Minor | fixed | Confirmed (DOS listing R:0000:1227..1230, 1270..1291). The dictionary spans DGROUP:BA06..D205 (2048 × 3 bytes). 1227 falls through into the reset at 1270 for every image with width or height ≠ 0, so a palette-only load of a `.PIC` also clears the region. A `.PAL` load does not (it returns at 1230). I checked every palette order that writes BDEE, C1D6 or C5BE: none loads a `.PIC` palette there before using the buffer (for example O6:2279 rewrites the extension to `pal`). Changes: FORMATS.md 1.3 item 4; PALETTE.md 2.2 (outputs) and 2.6 (completed BDEE, C1D6, C5BE rows and the new paragraph "The decoder shares this region"). |
| R2-18 | Minor | fixed | Confirmed (the three viewers accepted any `--out`). Changes: `png.py` has a new `out_dir(path)`, which exits with code 2 and writes nothing unless the resolved path is `claude/port/build/` or lies under it; every PNG write in `_write` goes through it. `pic.py` `cmd_view`, `fontcv.py` view and `texts.py` view (which now imports `png`) resolve `--out` through it first. Usage texts are updated, and FORMATS.md 0 states the rule. Checked: all three `check` commands still pass (PIC_OK, FONTCV_OK, TEXTS_OK); an `--out` outside build/ is refused with exit 2 and creates nothing; output under `build/dos/scratch-fr2/` is written. |
| R2-19 | Note | fixed | Confirmed (DOS listing R:0000:0471..0484, 0487..04A1, the offset update in R:0000:044A). Changes: PALETTE.md 2.4 "Direction" is relabelled DOS listing. TIMING.md 3.6 (F1) still says inferred (below). |
| R2-20 | Note | fixed | Confirmed (DOS file, SPRITES.PIC rows 64/80; DOS listing O5:1667..16B1). Changes: SPRITES.md 5 has a note that the EGA sheet is not exactly SP257's layout and that T[10]/T[11] fall on non-terrain art. EGA stays out of scope. |
| R2-21 | Note | fixed and registered | Confirmed (DOS listing G:0000:03DF: (w + 1) / 2 words, no clip to the width). The 198th byte of each SLAG2/SLAM2 row comes from the row buffer DGROUP:E17E. Changes: FORMATS.md 1.4 ("Rows") and Open 5 (refined; visibility stays OPEN.md O7). Drawing only `width` pixels with a register entry is a D1 decision, sent for OPEN.md P (below). |
| R2-22 | Note | fixed | Confirmed (DOS listing R:0000:1227, 1270: [68F8] is never reset; its initial DGROUP value is 0, DOS file). In the 1,019,502 codes of the 106 pictures, code 100h never occurs (DOS file, `pic.py`). Changes: FORMATS.md 1.3 item 5 (the [68F8] lifetime); `pic.py` decoder docstring and comments (the tool's per-file isolation versus the listing). Decoder behaviour is unchanged: all files decode identically either way. |
| R2-23 | Note (R3 scope) | outside my files (fixed by F3) | Confirmed (DOS listing R:0182:0086 draws colour 0 at (x, y + 1), then the text at (x, y), both through R:0182:005C; the shadow is below only). CORRESPONDENCE.md 13 (row R:0182:0086) already says so with "review R2-23". FORMATS.md, PALETTE.md and SPRITES.md contain no shadow statement; no change. |
| R2-24 | Note (R1 scope) | outside my files (forwarded to F1) | Confirmed (98h/99h without a 66h prefix are CBW/CWD in 16-bit code; for example O8:16E6, O8:0A3B, R:0403:1065). SPRITES.md 8 already carries a CBW note at O8:16CA..16F0. The `disasm.py` fix is F1's (below). |

## From D1-E

Two items from design agent D1-E, passed on by the orchestrator on 2026-10-11. Both were verified
against the listing and fixed.

| Id | Kind | Verification, then what changed |
|---|---|---|
| D1-E-1 | fixed | FORMATS.md 4 gave the pointer cells as O5:1862..188F; SPRITES.md 6.3 gave O5:185D..188F. The cutting loop starts at O5:185D (DOS listing), and R2-1 changes how the pointer is selected. FORMATS.md 4 now says O5:185D..188F, with the torch copy at O5:1891..1894 and the R2-1 selection; SPRITES.md 6.3 agrees. |
| D1-E-2 | fixed | The listing R:0000:12DF..12E7 confirms it: a run byte with count n > 1 gives n copies in all, and n = 1 gives 256 copies after the earlier byte, 257 in all. FORMATS.md 1.3 item 6 now states both cases explicitly. |

## For other documents

These are changes that keep other documents consistent with the corrections above. I have not
edited them. Line numbers are as of 2026-10-11 and may move.

**OPEN.md (F3)**

1. **L5** (line ~55) still says "each of the 8 pointer shapes (R:0403:1094..10AB)". Narrow it to
   the game situation of dispatch value 67h: whether it is the GoTo command (`g`, then a click),
   with only the torch and the GO arrow (FORMATS.md 4, Open 9).
2. **L10** (line ~60): D4CE[2] (SPRITES Open 2), the 48 bytes at 6B34 (Open 5) and the ICONPG cell
   tables (Open 8) are closed. Keep D4CE[3], the D50E table and the other page-2 cells.
3. **New P item: the 6-to-8-bit rule.**
   * Facts: the DAC is linear with full scale 63 (PC fact). The candidates are floor `v*255//63`,
     round-to-nearest and bit replication `(v<<2)|(v>>4)`; they differ pairwise by at most 1, in
     30 (floor/round), 30 (floor/replication) and 10 (round/replication) of the 64 values.
   * The viewers' floor rendering is not a decision.
   * Sources: FORMATS.md 1.4, PALETTE.md 1. Phase: D1 (5.9).
4. **New P item: odd-width SLAG2/SLAM2 rows.**
   * Facts: the DOS draw copies a 198th byte per row from the row buffer DGROUP:E17E.
   * Question: draw only `width` pixels (with a register entry) or reproduce the extra column;
     this depends on O7.
   * Sources: FORMATS.md 1.4, Open 5. Phase: D1 (D4/D7 for the scenes).
5. **New P item: how the profile obtains code-immediate parameters.**
   * Facts: prompt 5.9 asks for values "read from the DOS image at recorded offsets". The values
     listed in FORMATS.md 6.2 are immediates inside instructions (cutter rectangles, page-2
     rectangles, ICONPG grids, cycling/fade/splice ranges, scene layouts, timer and pointer
     values), whose per-immediate offsets are not recorded.
   * Question: read them from the image at instruction offsets still to be recorded, or keep them
     as port constants with recorded provenance.
   * Source: FORMATS.md 6.2. Phase: D1.
6. (Optional) Under the palette or decoder items, note PALETTE.md 2.6's constraint. The picture
   decoder overwrites DGROUP:BA06..D205, which includes the palette buffers BDEE, C1D6 and C5BE,
   whenever a `.PIC` is loaded, so a buffer must be filled after the last `.PIC` load that
   precedes its use. Every DOS order checked complies.

**DOS-PROFILE.md (F3)**

7. **The pointer wording is wrong in four places:**
   * 0.6 rule 6 (line ~104..108)
   * 2.5 intro (line ~559..563)
   * C6 (line ~572)
   * SCENES-PLAY.md Open 3 (item 8)

   Each says the pointer "alternates on every pass" with "a flag flipped at R:0403:10B3". The
   listing shows the xor at 10B3 runs once per dispatch of value 67h, not on every loop pass.
   * The first `g` sets the GO arrow and the second `g` restores the torch.
   * A map click while the flag is set stores the destination square in the unit record
     (DGROUP:81DA/81DB + 600h·civ + 0Ch·unit) when the unit's domain allows it. It then clears the
     flag and restores the torch (R:0403:09D9..0AEC). R:0403:0456..046B and 094A..095B also clear
     the flag.
   * Without a mouse, the case starts or ends a keyboard square selection (R:0403:1007..1088), not
     a blink.
   * C6's "how often the pass repeats is not traced" no longer applies.

   Source: FORMATS.md 4.
8. **E9** (line ~598) and any other "R:01A8:0863" call reference should read R:01A8:0867 (the
   call; 0863 pushes the string).
9. **E23** (line ~612): "`SLAM1.PAL` 8-step fade-in (O9:124C)". Add "with KING 64..143 spliced
   in (O9:1228..1242)" to match E17 and PALETTE.md 3.
10. **E11** (line ~600) lists the Civilopedia palettes as `iconpg1.pal`, `iconpga.pal` and
    `hill.pal` through R:1DC4:047D. Add the terrain page's exception: `sp256.pal` to C5BE through
    G#28 at O8:0B0B, without the 6B34/entry-45 step. Add DAC 253: grey before any picture, after
    which the advance, improvement and unit pages get their file's entry 253 (SPRITES.md 8;
    PALETTE.md 2.5). P13..P15 (lines ~442..444) already agree.

**SCENES-PLAY.md (F3)**

11. **1.2** (line ~112): "(R:1FA1:026C at R:01A8:0863)" → R:01A8:0867.
12. **Open 3** (lines ~636..642): the same pointer correction as item 7.
13. **7.13** (lines ~502..504): already corrected for R2-2 and R2-5; no further change.

**CORRESPONDENCE.md (F3)**

14. The row for R:0403:0FFD..10B8 (line ~348) and the Open list's item 2 (line ~420..421) say "flipped on every
    pass" and "alternating on each pass of the order case 67h". Reword as item 7: the flag toggles
    once per `g` dispatch; arrow while set, torch otherwise; a map click stores the destination
    and restores the torch. The Windows counterpart (UpdateMapMoveCursor 1208:121A, cursor 133)
    and the inferred GoTo role stay.
15. The R:1DC4:047D row (line ~312) gives the ICONPG palette for every Civilopedia page. Add that
    the terrain page does not use R:1DC4:047D (`SP256.PAL` through G#28 at O8:0B0B; PALETTE.md
    2.5).

**TIMING.md (F1)**

16. **3.6**, the cycling direction sentence: relabel "With s > 0 each colour moves to the next
    higher DAC index" from **inferred** to **DOS listing** (R:0000:0471..0484, 0487..04A1; review
    R2-19; PALETTE.md 2.4).
17. (Optional) **3.5** remark (line ~305): DGROUP:BA06 is also the start of the picture decoder's
    dictionary BA06..D205, cleared on every `.PIC` load (FORMATS.md 1.3 item 4). So a picture
    load also destroys the text buffer and the three palette buffers.

**DRIVER.md (F1)**

18. No change: G#11/G#16 (data:0020, inferred defect) and G#21 already agree with FORMATS.md 2.1
    and 2.3 after R2-3 and R2-10.

**disasm.py (F1)**

19. R2-24 and the R2-9 gap:
    * Follow the targets of `loop`, `loope`/`loopz`, `loopne`/`loopnz` and `jcxz` as branch
      targets. The gaps met are G:0000:01B8..01C3 and 01E1..01EC in `mgraphic.lst`.
    * In 16-bit code, print 98h/99h without a 66h prefix as `cbw`/`cwd`; Capstone 5.0.7 prints
      them as `cwde`/`cdq`.

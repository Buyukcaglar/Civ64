# The DOS executable map (extension D0, prompt 6.1 to 6.3)

Draft of 2026-10-11, revised the same day after review R1 (fixer F1,
[ext-d0-fixes-r1.md](../verify/ext-d0-fixes-r1.md)). This file describes the DOS release's program
files, their layout, the overlay and driver mechanisms, the address notation used by every
`docs/dos` file, and the disassembler that produced the listings. Contracts of the driver functions are in
[DRIVER.md](DRIVER.md); the clock is in [TIMING.md](TIMING.md); file formats in
[FORMATS.md](FORMATS.md).

Evidence labels: **DOS file** (read from the files), **DOS listing** (our disassembly),
**inferred**, **unknown**. General platform knowledge (DOS, MS LINK, Microsoft C) is named as
such where it carries a conclusion. No DOS bytes are reproduced here; strings are identified by
their DGROUP offset and a few words at most.

Tools (all read-only on `build/dosdata/`, writing only under `build/dos/`):

| Tool | Does | Output |
|---|---|---|
| `gen/dos/dosexe.py check` | MZ parser with relocations; EXEPACK decoder; comparison with `CIV_UNP.EXE`; overlay directory | `build/dos/exe-map.json`, token `EXEPACK_OK` |
| `gen/dos/disasm.py` | relocation-aware recursive-descent disassembler (section 10) | `build/dos/disasm/{root,ovl01..23,mgraphic,misc}.lst`, `db.json`, token `DISASM_OK` |
| `gen/dos/ovlsummary.py [--dir D]` | per segment and overlay: functions, external entries, driver calls, the file names its code names (with the naming instructions) and strings | `D/summary.txt` (default `build/dos/disasm`) |

capstone: `capstone.__version__` 5.0.7 (pip reports 5.0.9), Python 3.14 at `C:/Python314`.

The listings cited here are those of the tools as corrected after review R1 (string candidates,
program exits, entries owning their code, `loop` targets, `cbw`/`cwd`, port tracking, jump-table
guards; section 10). They were generated into `build/dos/disasm-next/`, which replaces
`build/dos/disasm/` when the orchestrator swaps the directories. Against the earlier listing only
these lines differ: 511 lines lose a false `str?` annotation, 1,155 `cwde`/`cdq` are now
`cbw`/`cwd`, 41 `loop` lines now show their target (one of them in place of a false `str?`), 16
function headers, 16 instruction lines added
(G:0000:01B8..01EB, R:2045:00DA..00DE) and 2 removed (R:2045:00D9, 00DD); the other 89,561
instruction lines and 679 headers are identical (comparison in
[ext-d0-fixes-r1.md](../verify/ext-d0-fixes-r1.md)).

## 1. Files

| File | Size | SHA-256 (first 8) | Role | Label |
|---|---|---|---|---|
| `CIV.EXE` | 305,030 | `22de2748` | The program: an EXEPACK-packed root and 23 overlays | DOS file |
| `CIV_UNP.EXE` | 340,791 | `aa63aa39` | The user's unpacked copy; the disassembly input | DOS file |
| `MGRAPHIC.EXE` | 7,142 | `bf8907e9` | VGA/MCGA graphics driver, loaded at run time | DOS file, DOS listing |
| `EGRAPHIC.EXE`, `TGRAPHIC.EXE` | 11,584, 9,990 | `fd129cbd`, `7da36315` | EGA and Tandy drivers (out of scope) | DOS file |
| `MISC.EXE` | 980 | `95b18daf` | A third driver (section 8; DRIVER.md 5), always loaded | DOS file, DOS listing |
| `*SOUND.CVL` (5) | 720..37,923 | dos-hashes.txt | Sound drivers (out of scope) | DOS file |
| `FONTS.CV` | 19,123 | `c07a501f` | The fonts; loaded behind the graphics driver | DOS file, DOS listing |

Full hashes: [dos-hashes.txt](dos-hashes.txt).

## 2. EXEPACK and the two copies of the program

`gen/dos/dosexe.py check` (DOS file, verified 2026-10-10 and on every run):

* `CIV.EXE`'s MZ header is 512 bytes with no relocations; its load module (172,064 packed bytes
  plus the 5,375-byte EXEPACK stub and relocation table) ends at file offset 177,951. The EXEPACK
  header sits at load-module offset 0x2A020: real CS:IP 2045:2E7F, SS:SP 398D:0800, 12,724
  destination paragraphs, 437 commands. The stub's "Packed file is corrupt" message confirms the
  packer (the prompt's observation, verified).
* Decoding gives 203,584 bytes that equal `CIV_UNP.EXE`'s load module byte for byte (0 differing
  bytes), with the same 2,525 relocations in the same order and the same entry.
* `CIV_UNP.EXE`: header 10,128 bytes (633 paragraphs), load module end 213,712, CS:IP 2045:2E7F,
  SS:SP 398D:0800, minimum allocation 2,137 paragraphs, maximum 65,535.
* The 127,079 bytes after each load module are identical: the 23 overlays (section 6). Only the
  root is packed.

So every address in the root means the same byte in both files; the listings use
`CIV_UNP.EXE`'s load module. The program at run time opens `CIV.EXE` itself to read overlays
(the name at DGROUP 63CC, DOS listing R:2045:2ED8).

## 3. Address notation

| Form | Meaning |
|---|---|
| `R:ssss:oooo` | The root. `ssss` is a segment relative to the load module, exactly as the relocated words hold it before relocation; the linear load-module offset is ssss·16 + oooo. Code in one segment is always named with that segment, even where another base would reach the same byte. |
| `O<n>:oooo` | Overlay n (1..23). The overlay manager loads it at segment R:2374 (the overlay area); `oooo` is the offset within the overlay's load module, which is also the offset from R:2374 at run time. |
| `G:0000:oooo` | `MGRAPHIC.EXE`, offset in its load module (one segment). |
| `M:0000:oooo` | `MISC.EXE`, offset in its load module. |
| `DGROUP:oooo` | An offset in the root's data group, segment R:2B01 (DS in C code). A bare `[oooo]` in a C-code listing line is DGROUP. |
| `G#n`, `M#n`, `S#n` | Driver function n of the graphics, misc or sound driver: slot n, 90+n or 100+n of the root's slot table (section 8). |

Windows addresses in these files are always the NE `ssss:oooo` of the Windows CIV.EXE without a
prefix and are never mixed with DOS addresses.

## 4. The root's segments

The relocated words of the root name 32 distinct segment values (DOS file). Two more code
segments, R:0199 and R:202A, are named only by relocated words in overlays (far calls from O1 and
O2 to R:0199, from O11:0913 to R:202A:000C) (DOS listing). So the root has 22 code segments.

**Code segments.** "Code" is the linear range from the first to the last byte the listing decodes
under that segment name; "Base" is the segment value times 16. MS LINK starts each segment's code
a few bytes after its paragraph base and the previous segment's code can run past that base (for
example R:0000's last bytes, 1820..1829, lie above R:0182's base), so the decoded bytes, not the
gaps between bases, measure each segment. Functions marked "(n by scan)" include n found only by
the prologue scan. **DOS listing**

| Segment | Base | Code (linear) | Decoded bytes | Functions | Role |
|---|---|---|---|---|---|
| R:0000 | 00000 | 00000..01829 | 4,690 | 65 (6 by scan) | Hand-written assembly (below) |
| R:0182 | 01820 | 0182A..01A2F | 518 | 14 (6 by scan) | Text drawing helpers around G#21 (DRIVER.md 4), `wait(n)` R:0182:0134 (TIMING.md 3.3) |
| R:0199 | 01990 | 01A31..01A87 | 87 | 2 | Text-mode output for the set-up questions, called only from O1 and O2 (below) |
| R:01A8 | 01A80 | 01A88..02386 | 2,303 | 16 (1 by scan) | `main` R:01A8:0008 (section 5) and start-up and title helpers |
| R:0238 | 02380 | 02388..0403D | 7,350 | 17 | Game C code |
| R:0403 | 04030 | 0403E..08664 | 17,861 | 10 | Game C code |
| R:0866 | 08660 | 08666..0ADE4 | 10,111 | 38 | Game C code |
| R:0ADE | 0ADE0 | 0ADE6..0D128 | 8,927 | 11 | Game C code |
| R:0D12 | 0D120 | 0D12A..1458F | 29,786 | 19 | Game C code |
| R:1459 | 14590 | 14590..15172 | 3,043 | 7 | Game C code |
| R:1517 | 15170 | 15174..15FB3 | 3,648 | 11 | Game C code |
| R:15FB | 15FB0 | 15FB4..19F3C | 16,265 | 16 (1 by scan) | Game C code |
| R:19F3 | 19F30 | 19F3E..1AEA7 | 3,946 | 6 | Game C code |
| R:1AEA | 1AEA0 | 1AEA8..1C83F | 6,552 | 31 (2 by scan) | Game C code |
| R:1C84 | 1C840 | 1C840..1D04F | 2,044 | 6 | Game C code |
| R:1D05 | 1D050 | 1D050..1DC49 | 3,066 | 8 | Game C code (menus, the key reader R:1D05:0AC9) |
| R:1DC4 | 1DC40 | 1DC82..1E31C | 1,592 | 21 | Game C code |
| R:1E31 | 1E310 | 1E31E..1F4CE | 4,529 | 6 | Game C code |
| R:1F4D | 1F4D0 | 1F4D0..1FA19 | 1,354 | 6 | Game C code |
| R:1FA1 | 1FA10 | 1FA1A..202AA | 2,126 | 28 (12 by scan) | Game C code (the picture reader R:1FA1:01A2, sprite building) |
| R:202A | 202A0 | 202AC..20452 | 419 | 3 | Called only from overlay 11 (save and load) at O11:0913: R:202A:000C → 002A reads page rows with G#13 ReadRow and passes them to R:0000:13C8, 1414 and 148F |
| R:2045 | 20450 | 20464..2373C | 12,779 | 118 (4 by scan) | The Microsoft C run time and the MS LINK overlay manager (sections 5, 6.2, 7; general knowledge for the names) |

All 22 together: 142,996 decoded bytes, 459 functions (32 by scan). "Game C code" is Microsoft C (far calls,
DS = DGROUP); per-segment entries, driver calls and named files are in `summary.txt`
(`gen/dos/ovlsummary.py`), roles in the scene files.

* **R:0000**: the timer (INT 08h handler R:0000:01A7, install R:0000:0000, restore R:0000:0051;
  TIMING.md), the driver slot table R:0000:076D..0A75, the driver loader R:0000:0A76 and slot
  patcher R:0000:0B70, the slot guard R:0000:0732 and pointer redraw R:0000:179A (DRIVER.md), the
  mouse handler R:0000:17DB, a disk check with an INT 24h handler (R:0000:066A, R:0000:0718), palette
  fade and cycling, primitives (FillRect R:0000:0BFA, DrawLine R:0000:100A, PutPixel R:0000:104F),
  the picture reader R:0000:108E and block copies through the far pointer [D91A]. It keeps data in
  the code segment (for example the saved INT 08h vector at R:0000:0211, the timer's private stack
  R:0000:00A1..01A0) and in segment 25CF. **DOS listing**
* **R:0199**: R:0199:00A1(row, column, text) sets the cursor with INT 10h AH=02h (not when row
  and column are both FFh), then draws each character in the current colour (INT 10h AH=09h writes
  a blank with the colour, AH=0Eh the character); a byte FFh followed by a colour byte changes the
  colour, which is kept in the code byte R:0199:00A0. R:0199:00EC(text) prints a `$`-terminated
  string with INT 21h AH=09h. O1 prints the set-up screen and the driver menu lines with them
  (DRIVER.md 1.1). **DOS listing**; the BIOS and DOS function meanings are PC facts.

**Other segments.**

| Segment | Span (bytes, to the next base) | Role | Label |
|---|---|---|---|
| R:2374 | 9,648 (0x25B paragraphs) | The overlay area: zero in the file; every overlay is loaded here | DOS listing |
| R:25CF | 848 | Data of R:0000's routines (loaded as DS by R:0000:0388, 03FE, 042F, 044D) | DOS listing |
| R:2604, 26FA, 2710, 271E, 2725, 2755, 275A, 2767 | 80 .. 3,936 | Far data: initialised tables (2604 starts with the city-name table) and one zero block (2725) | DOS file |
| R:2772 | 14,576 | Far data, zero in the file (uninitialised far arrays) | DOS file |
| R:2B01 | 27,440 in the file, more at run time | DGROUP: near data, strings, the C run time's data; the stack segment 398D lies above it | DOS file, DOS listing |

Code ends at linear 0x2373C, just below the overlay area (0x23740). The 32 segment values are
the targets of 2,525 relocations; the most referenced are R:2045 (664), R:1AEA (379), R:0000 (247),
R:1DC4 (226) and R:0866 (166) (DOS file).

## 5. Start-up

* **Entry R:2045:2E7F** (DOS listing): sets DS to DGROUP, checks the DOS version (INT 21h AH=30h,
  version 2 or later, else "Incorrect DOS version", DGROUP 61A6), saves and replaces the
  interrupt whose number is the byte at DGROUP 63DB, which is 3Fh (DOS file), with the overlay
  handler R:2045:2D5A, runs the overlay manager's initialisation R:2045:2ED2 (which opens
  `CIV.EXE`, DGROUP 63CC), then jumps to the C start-up R:2045:0014. That entry layout is the
  MS LINK overlay start-up (general knowledge), here confirmed by the listing.
* **C start-up R:2045:0014** calls `main` R:01A8:0008. The run-time identification string is at
  DGROUP 0008 ("MS Run-Time Library", 1988); run-time error messages R6000 .. R6009 are in DGROUP
  645E .. 6507 (DOS file). Installed by the run time: INT 00h (divide error) R:2045:00B6 (DOS
  listing).
* **`main` R:01A8:0008** (DOS listing): loads `misc.exe` with `R:0000:0A76` and patches its slots
  (`R:0000:0B70`), calls overlay 1 (`O1:0000`: the text-mode set-up questions; the typed digits,
  read with M#2, choose the graphics and sound drivers by rewriting the first letter of their
  names at DGROUP 1A22 and 1A30, O1:01E1 and O1:0347, from menus built at run time; it also reads
  `intro.txt`), clears bit 5 of the BIOS keyboard flag byte 0040:0017 (`and` with DFh at
  R:01A8:0033; bit 5 is the Num Lock state, PC fact), calls `R:01A8:03F4` (replaces the Ctrl-Break
  and Ctrl-C vectors, section 9), then overlay 2 (`O2:0000`: loads the chosen graphics driver with
  `fonts.cv` and the sound driver, sets the video mode, allocates the pages, installs the timer,
  then the start-up screens), checks the free memory (G#1), loads `torch.pic` as the pointer shape
  (R:01A8:0107, between G#18 and G#7), then the title menu and the game. DRIVER.md 1.1 has the
  driver steps.

## 6. Overlays

### 6.1 The overlay directory (DOS file, `exe-map.json`)

23 MZ-headed overlays follow the root's load module and end exactly at the end of the file. Each
header's overlay-number field holds its number 1..23, and each repeats the root's CS:IP.
"Offset" is the file offset in `CIV.EXE`; in `CIV_UNP.EXE` add 35,761 (first at 213,937).

The "Files named" column lists only real references in the corrected listing: a file name's
DGROUP offset loaded by `mov r16, imm16` (in practice the argument pushed to the loader) or a
direct access to the name's bytes, with the instruction that names it (`summary.txt` lists them
all). An earlier version of this table took names from `str?` false positives (review R1-1):
`king00.pic` is not named by O5, `diffs.pic` not by O6 and `torch.pic` not by O19; the root loads
`diffs.pic` (R:01A8:08A0) and `torch.pic` (R:01A8:0107). Roles are inferred from these files, the
strings and the callers; the scene files refine them.

| n | Offset | Header | Image bytes | Relocations | Functions | Files named (naming instruction) | Role (inferred) |
|---|---|---|---|---|---|---|---|
| 1 | 178,176 | 512 | 1,018 | 38 | 1 | `intro.txt` (O1:0033); the first letters of `mgraphic.exe` (O1:01E1) and `nsound.cvl` (O1:0347) are rewritten | Text-mode set-up questions choosing the graphics and sound drivers and the input (DOS listing, DRIVER.md 1.1) |
| 2 | 179,712 | 1,024 | 6,588 | 220 | 6 | O2:0000: `mgraphic.exe` (letter tests O2:00EE..010D, load O2:0122), `fonts.cv` (O2:011E), `nsound.cvl` (O2:013A), `logo.pic` (O2:021B, 02BA), `birth0.pic` (O2:024E), `birth1.pic` (O2:0284), `credits.txt` (O2:0325). O2:0BD7: `planet2.pic` (O2:0BF1), `planet1.pic` (O2:0C8B), `king.txt` (O2:0E6C), `spacest.pic` (O2:11FF, 124E), `sprites.pic` (O2:14DF). O2:152A: `arch.pic` (O2:156E), `king.txt` (O2:1641) | O2:0000 (called by `main`): driver loading, video pages, timer, intro, credits and logo (DOS listing; TIMING.md 5.2, 5.3). O2:0BD7, O2:152A and O2:17D9: sequences called from the game loop R:0238:0092, not part of start-up (TIMING.md 5.7) |
| 3 | 187,392 | 512 | 3,192 | 119 | 7 | `fame.dta` (O3:0091) | Hall of Fame (SCENES.md 7.5) |
| 4 | 191,488 | 512 | 1,146 | 43 | 4 | `help.txt` (O4:0037, 02F6), `error.txt` (O4:03C5) | Help notes and error texts (SCENES-PLAY.md 7.18) |
| 5 | 193,536 | 1,024 | 7,534 | 177 | 8 | O5:1455: `sp299.pic` (O5:1474), `ter257.pic` (O5:14EF), `sprites.pic` (O5:163B), `sp257.pic` (O5:16BA), `sp256.pal` (O5:16CE); O5:1AF6: `govt0a.pic` (O5:1B0F); the sound driver letter is tested (O5:02FD) | Setup questions O5:0000 (called from R:01A8:087C; SCENES.md 9), the game's shapes cut by O5:1455 (SPRITES.md), government portraits O5:1AF6 and New Cabinet O5:1BA2 (SCENES-PLAY.md 7.10) |
| 6 | 202,240 | 1,024 | 9,642 | 246 | 12 | O6:1D2B: `govt0a.pic` (O6:1E43, 2076), `king00.pic` (O6:1F08); O6:21AC: `back0a.pic` (O6:21C2), `king00.pal` (O6:2285) | Throne room and leader audience (SCENES-PLAY.md 7.9): emissary O6:16CD, leader screen O6:1D2B, throne-room background O6:21AC, idle animation O6:1B33, text strip O6:251D; the largest routine, O6:0000 (1,952 instructions, called from O22:0000 and R:1517:0737), is not named there |
| 7 | 212,992 | 1,024 | 7,512 | 145 | 15 | `map.pic` (O7:0041), `story.txt` (O7:1865), `birth0.pic` (O7:19DB) | World creation and its story (TIMING.md 5.5) |
| 8 | 221,696 | 1,024 | 6,134 | 203 | 7 | `iconpg1.pic`, `.pal` (O8:073B, 0768), `citypix2.pic` (O8:0920), `hill.pal` (O8:0930), `iconpga.pic`, `.pal` (O8:09EF, 0A1C), `iconpgt1.pic` (O8:0AC3), `sp256.pal` (O8:0AFB), `blurb0.txt` (O8:0851, 08BB) | The civilopedia (SCENES-PLAY.md 7.13) |
| 9 | 228,864 | 1,024 | 5,468 | 156 | 11 | `replay.txt` (O9:0046); O9:0F79: `king00.pic` (O9:0F96), `slam1.pic` (O9:1059, 12A3), `slam2.pic` (O9:10A1), `slam1.pal` (O9:121C) | Replay and end screens (SCENES-PLAY.md 7.17) |
| 10 | 235,520 | 512 | 1,702 | 65 | 3 | none | "Which army?" prompt and army map, a debug screen (SCENES-PLAY.md 7.18) |
| 11 | 238,080 | 512 | 3,994 | 117 | 12 | `a:CIVIL0.SVE` (O11:0052, 00C7, 03B4, 041C; its drive letter written at O11:07CC) | Save and load |
| 12 | 242,688 | 1,024 | 7,000 | 207 | 8 | none | World map O12:0000, POWERGraph O12:0573, historian O12:09E2, debug tables O12:03AC (SCENES-PLAY.md 7.14, 7.15, 7.17, 7.18) |
| 13 | 250,880 | 512 | 2,472 | 90 | 3 | none | Debug screens O13:0000 and O13:0554 (SCENES-PLAY.md 7.18; string "Government:") |
| 14 | 253,952 | 1,024 | 7,026 | 240 | 12 | none | Advisor reports (SCENES-PLAY.md 7.14) |
| 15 | 262,144 | 512 | 2,426 | 34 | 3 | none | Schism (help keys `*SCHISM`, `*ESCHISM`; SCENES-PLAY.md 7.18) |
| 16 | 265,216 | 512 | 1,372 | 48 | 2 | `iconpg1.pic`, `.pal` (O16:0085, 0100) | The quiz ("CIVILIZATION QUIZ"; SCENES-PLAY.md 7.15) |
| 17 | 267,264 | 512 | 4,246 | 80 | 5 | `cback.pic` (O17:0099, 0897), `sad.pic` (O17:0892, 0CDC), `cbacks0.pic` (O17:08AE), `cbrush0.pic` (O17:0BE6), `castle0.pic` (O17:1061) | Palace (SCENES-PLAY.md 7.8) |
| 18 | 272,384 | 1,024 | 5,842 | 150 | 12 | `docker.pic` (O18:0044), `back0a.pal` (O18:01B4), `sp256.pal` (O18:0204) | The spaceship (SCENES-PLAY.md 7.16) |
| 19 | 279,552 | 1,024 | 7,332 | 157 | 10 | `hill.pic` (O19:0913, 0E68), `hill.pal` (O19:0EA5), `pop.pic` (O19:112B), `citypix1..3.pic` (O19:138C, 14B1, 14AC), `wonders.pic`, `wonders2.pic` (O19:156E, 15CA), `invaders.pic`, `invader2.pic`, `invader3.pic` (O19:16D3, 16D8, 1743), `riot.pic`, `riot2.pic` (O19:18EB, 1955), `love1.pic`, `love2.pic` (O19:1B06, 1B0B) | City view, new wonder, riot, celebration and invaders (SCENES-PLAY.md 7.2, 7.3) |
| 20 | 288,256 | 1,024 | 5,188 | 128 | 4 | none | Disasters and city events O20:0540, the score O20:0CA9 (SCENES-PLAY.md 7.6, 7.14) |
| 21 | 294,912 | 512 | 1,066 | 43 | 1 | `king.txt` (O21:03B9) | Newspaper (SCENES-PLAY.md 7.7) |
| 22 | 296,960 | 1,024 | 4,434 | 138 | 5 | `nuke1.pic` (O22:0985), `settlers.pic` (O22:0EDC), `hill.pic` (O22:0F25, 0F50) | Diplomat and bribe events O22:0000, 0639, 0AF5, nuclear explosion O22:0967, city founded O22:0EAF (SCENES-PLAY.md 7.4, 7.5, 7.18) |
| 23 | 302,592 | 512 | 1,926 | 64 | 7 | none | Name entry ("City Name...", "Your Name...", "Name of your Tribe..."), find city (SCENES.md 9.4, 9.5, 10.4) |

Files the root names (same rule): `misc.exe` (R:01A8:0011), `torch.pic` (R:01A8:0107), `sp299.pic`
(R:01A8:0546, 07B7), `custom.pic` (R:01A8:05D9), `sp257.pic` (R:01A8:0863), `diffs.pic`
(R:01A8:08A0), `adscreen.pic` (R:0238:091E, 094E), `back0a.pal` (R:0238:1C01), `sp256.pal`
(R:0238:1C5E), `cback.pic` (R:0403:07D4), `produce.txt` (R:0ADE:1340, 13DF), `discovr1.pic`
(R:0ADE:16FF), `iconpg1.pic` and `iconpg1.pal` (R:0ADE:189C, 1964), the extension `.pal`
(R:0ADE:1940), `king.txt` (R:1F4D:0455) and the program file `CIV.EXE` (overlay manager,
R:2045:2C33, 2ED8, 2F1D, 2F98, 2FCA, 3026). **DOS listing**

"Image bytes" is the overlay's load module (from the end-of-image field minus the header). The
largest, overlay 6 (9,642 bytes), fits the 9,648-byte area (DOS file).

### 6.2 The overlay call (DOS listing)

* A call into an overlay is the 5-byte sequence `INT 3Fh`, overlay number (byte), entry offset
  (word), in place of a far call. The root has 149 such sites from load-module 0x1AA6 to 0x1D1A4;
  overlays call each other the same way. MS LINK's overlay convention (general knowledge),
  confirmed by the handler below.
* Handler R:2045:2D5A: saves the registers, takes the caller's return address from the interrupt
  frame and reads the overlay number n and the offset from the bytes after `INT 3Fh`; pushes a
  5-byte record (caller segment, caller offset, the overlay last requested, DGROUP 5DD2) on the
  overlay manager's stack at DGROUP 5DD4 (depth DGROUP 5DBE, at most 128 entries, else "Overlay
  Manager stack overflow", DGROUP 6277); takes the overlay's segment from the relocated word
  table DGROUP 6324 (entries 1..23: the overlay area R:2374; entry 0: segment 0, that is the load
  segment, DOS file) and the overlay to load from the byte table DGROUP 6354 (n itself for
  n = 1..23, DOS file); calls the debugger notification R:2045:2E1D, the loader
  R:2045:2BEB (on failure "Overlay not found", DGROUP 6254) and the notification R:2045:2E01;
  restores the registers and far-returns into the overlay at segment:offset, with R:2045:2D18
  pushed as the far return address. **DOS listing**
* Loader R:2045:2BEB(AL = overlay): stores AL in DGROUP 5DD2 and returns at once when AL is 0 or
  equals DGROUP 5DD3, the overlay in the area. Otherwise it sets DGROUP 5DD3, opens the program
  file (name at DGROUP 6156; on failure it asks for the diskette and retries), seeks to the dword
  file position kept for that overlay at DGROUP 636C + 4n (zero in the file), reads the 32-byte MZ
  header and, while the header's overlay-number word (offset 1Ah) is not n, advances that
  position by the header's page count times 512 and reads again. So the first load walks the MZ
  headers from the start of the file and later loads find the overlay at once. It then reads the
  image into R:2374 in pieces of at most 400h paragraphs (R:2045:2B44), reads the relocation
  table in pieces of 64 entries into DGROUP 6056 and adds the load segment (DGROUP 6324, entry 0)
  to each relocated word (R:2045:2B83), and closes the file. When the file could not be opened it
  prints a "Please insert diskette" message (DGROUP 61BE, with the name at 63CC) and waits for a
  key before retrying, and after such a load "Please restore original diskette" (DGROUP 6212);
  DOS error 4 (too many open files) ends the program (DGROUP 62BC). **DOS listing** (seek and read
  helpers R:2045:2B39, R:2045:2B28)
* Debugger notifications R:2045:2E1D (code 7, before the load) and R:2045:2E01 (code 6, after it):
  on first use R:2045:2E39 compares the 8 bytes at offset 80h of the INT 03h handler's segment
  with "CVDEBUG" (DGROUP 62F4); when they match it calls the far pointer DGROUP 62FC (that segment,
  offset 7Bh) with the code and the overlay number; otherwise nothing. **DOS listing**; that this
  is the CodeView debugger's hook is inferred from the string.
* Return thunk R:2045:2D18..2D59 (not in the listing, which does not follow the pushed return
  address; own decoding of the DOS file): pops the record (depth − 1), calls R:2045:2E1D and
  R:2045:2BEB with the overlay byte of the record (a reload only when that overlay is no longer in
  the area; "Overlay not found" on failure), then R:2045:2E01, and far-returns to the caller's
  segment:offset with AX and BX as the overlay function left them. **DOS file** (own decoding)
* Each overlay's relocations are against segment 2374 (DOS file: every relocation's segment field
  is 2374); a relocated value 2374 inside an overlay means the overlay itself.
* Only one overlay is resident at a time: there is one area, R:2374, and one "overlay in the area"
  byte, DGROUP 5DD3. A return into an overlay that another call has replaced reloads it through
  the thunk. **DOS listing**, **DOS file** (thunk)

## 7. Calling convention and memory model

DOS listing, with Microsoft C knowledge for the names: code is far (every C call is a far call
with `push bp; mov bp, sp`, arguments at [bp+6] upwards, pushed right to left, the caller removes
them with `add sp, n`); data is near in DGROUP (DS = R:2B01 in C code), with far data segments
2604..2772 reached through explicit segment loads. That is the Microsoft C medium model
(inferred). Return values in AX (DX:AX for 32-bit).

## 8. Drivers (summary; contracts in DRIVER.md)

DOS listing unless marked:

* **Loader `R:0000:0A76(name, data file)`**: asks DOS for FFFFh paragraphs, which must fail and
  report the largest free block, allocates that block less 100h paragraphs, loads the driver with
  INT 21h AX=4B03 (load overlay) at that segment (DGROUP 5408), loads the data file, when one is
  named, at the paragraph after the driver's data segment (header word 002Ah, the data segment
  inside the image, relocated, plus header word 002Ch, its size, rounded up; `R:0000:0B1E`), and
  shrinks the block to the end of the data plus 8 paragraphs (AH=4Ah). Header word 0028h is the
  driver's code segment (relocated). Its messages are `$`-terminated DOS strings at DGROUP
  5412..54DE, printed after a hexadecimal digit and the separator at DGROUP 540E, followed by exit
  code 99h: the prompt's "Allocated 1Mb of space" (DGROUP 5412) is the first check (the FFFFh
  request succeeded) and "MS-DOS lied to us" (DGROUP 542D) the second (the reported block could
  not be allocated); then file-not-found (also every data-file failure), not-enough-memory,
  load-failed, overrun and shrink-failed. DRIVER.md 1.2 has every branch.
* **Slot patcher `R:0000:0B70(segment)`**: copies the driver's table of `count` (header word
  0030h) word offsets at 0032h into the root's slot table starting at slot `base` (header word
  002Eh), each slot getting the offset and the driver's segment. Slot i occupies R:0000:076D+7i
  .. 0773+7i; its far pointer is at 0770+7i. Plain slots have `jmp far` at 076F+7i; guarded slots
  begin with `call 0732` at 076D+7i (DOS file: the slot bytes before patching). The table has 111
  slots (0..110); the guarded ones are 6, 9, 15, 22, 30, 31 and 32; 52..89, 98 and 99 are empty
  (DRIVER.md 1.4).
* **Guard `R:0000:0732`**: with byte [5403] clear, jumps through the slot's pointer; otherwise sets
  [5402], calls the driver through it, and while [5402] is not exhausted calls `R:0000:179A`
  (G#15 restores the pointer's save-under, G#30 saves and draws the pointer at the mouse
  position), then returns to the caller through [5404]. The mouse driver's user handler
  R:0000:17DB (installed by R:0000:163E with INT 33h AX=000Ch) redraws the pointer at once when
  no guarded call runs, and otherwise leaves the redraw to the guard (DRIVER.md 1.5).
* **Three drivers** (DOS file headers, DOS listing loads):

| Driver | Loaded by | Data file | Base slot | Count | Signature (a few words) |
|---|---|---|---|---|---|
| `MISC.EXE` | R:01A8:0015 (`main`) | none | 90 | 8 | "MISCOVR.EXE 02-20-89" |
| `MGRAPHIC.EXE` (or E/T by the first letter at DGROUP 1A22) | O2:0126 | `fonts.cv` | 0 | 52 | "MGRAPHIC.EXE09-19-91" |
| `NSOUND.CVL` (default; name at DGROUP 1A30) | O2:013E | none | 100 | 11 | "CVLZTN NoSnd10-16-91" |

  `EGRAPHIC.EXE` and `TGRAPHIC.EXE` have the same base and count as `MGRAPHIC.EXE`; the sound
  drivers all have base 100 and count 11 (DOS file).
* Calls: C code pushes the arguments and far-calls the slot (`lcall 0000:076F+7i`), or for a
  guarded slot `lcall 0000:076D+7i`; assembly in R:0000 also calls through the slot's pointer with
  ES = the root's segment 0 (`lcall es:[0770+7i]`). 45 slots are called from the reached code: 37
  graphics, 2 misc and 6 sound (`db.json` `driver_slots`).

## 9. Interrupt vectors the program installs (DOS listing)

| Vector | Handler | Installed by | Removed by | Note |
|---|---|---|---|---|
| 08h (timer) | R:0000:01A7, through the far pointer at R:0000:01A3 | R:0000:0000 (also programs PIT channel 0) | R:0000:0051 | The old vector is saved at R:0000:0211 and chained by the `jmp far` at R:0000:0210, whose operand those bytes are. TIMING.md |
| 24h (critical error) | R:0000:0718 | R:0000:066A at R:0000:0688, around a file search (INT 21h AH=11h) | R:0000:066A before it returns | Inferred: a "disk in drive" check |
| 00h (divide error) | R:2045:00B6 | R:2045:00DA (called from the C start-up at R:2045:008C; set at R:2045:00F6; old vector at DGROUP 58EF) | R:2045:01FC (called by the exit routine R:2045:019E), at R:2045:020A..0211 | Microsoft C run time (general knowledge); the handler sets run-time error 3, prints it (R:2045:023C) and exits with code 255 |
| 1Bh (Ctrl-Break) and 23h (Ctrl-C) | R:01A8:03D9 (saves and restores the registers and returns with `iret`: the keys do nothing, inferred) | R:01A8:03F4, called by `main`, through R:2045:310A (INT 21h AH=25h; old vectors read with R:2045:30BC, INT 21h AH=35h, and kept at DGROUP B270 and E2BE) | R:01A8:0443, called by `main` | The handler is reached as a far-constant seed (R:01A8:041D, 0431); the tool's vector rule (AH=25h with DS = CS) cannot see installs through the run-time function. The names `_dos_getvect`/`_dos_setvect` for R:2045:30BC/310A are Microsoft C knowledge |
| mouse user handler (INT 33h AX=000Ch, event mask 1Fh) | R:0000:17DB | R:0000:163E, after a mouse-driver check (INT 33h AX=0) | R:0000:1687 (INT 33h AX=0, reset) | DRIVER.md 1.5 |
| 3Fh (overlay call) | R:2045:2D5A | entry R:2045:2E7F (number from DGROUP 63DB, kept at DGROUP 592D; old vector at DGROUP 592E) | R:2045:01FC at R:2045:021B (when the flag DGROUP 592C is set) | Section 6.2 |

Interrupt calls in the reached code: 10h (6 sites: 3 in G#37, 3 in R:0199:00A1), 11h (1), 13h (1),
16h (2, in `MISC.EXE`), 20h (1), 21h (125), 33h (6, the mouse driver).

Ports (`db.json` "ports", 60 sites; meanings of the port numbers are PC facts):

| Port | Sites | Use |
|---|---|---|
| 20h | R:0000:01F6 | interrupt controller: end of interrupt (TIMING.md 2.3) |
| 40h | R:0000:002B, 002F, 0064, 0068, 0260, 0266 (divisor), 032A, 0330 (latched count) | PIT channel 0 |
| 43h | R:0000:0025, 005E, 025A, 0326 | PIT mode and latch |
| 201h | M:0000:0071, 00D0, 00D5 | game port (joystick) |
| 3C0h | G:0000:01FA, 01FF, 0205 | attribute controller: overscan colour (G#27) |
| 3C4h, 3C5h | G:0000:052F, 0549; 0531, 0534, 054B, 054E | sequencer index and data, register 1 (G#23, G#24) |
| 3C7h | R:0000:03D1 (cycling set-up), R:0000:0568 (the fade's palette snapshot) | DAC read index |
| 3C8h | G:0000:01CA, R:0000:0492, 0592, 064D | DAC write index |
| 3C9h | G:0000:01D1, R:0000:03D6, 049B, 04A0, 056D, 05A0, 0656, 065C (049B, 05A0 and 0656 are `rep outsb`) | DAC data |
| 3D4h | G:0000:10E6 | CRTC index and data, register 0Dh (G#51) |
| 3D8h | G:0000:0529, 0543 | CGA mode control register (G#23, G#24) |
| 3DAh | G:0000:01AD, 01F0, 051F, 0539, 07AD, 07B2, R:0000:022F, 0315, 031F, 0558, 0584, 0589 | input status: vertical retrace (bit 3), display enable (bit 0) |
| `dx?` | G:0000:01BF, 07D0, R:0000:05AE (3DAh); G:0000:01D5, 01D9, R:0000:05A6 (3C9h) | DX set more than 15 instructions earlier on the path; the port given here is read from the listing by hand |

No other port is used by the reached code of the root, the overlays, `MGRAPHIC.EXE` and
`MISC.EXE`. **DOS listing**

## 10. The disassembler (`gen/dos/disasm.py`)

Recursive descent from proven entries, each rule stated in the tool's docstring:

* the root's entry; far calls and jumps whose segment word is relocated; INT 3Fh overlay calls;
  `jmp cs:[reg+table]` when, within the preceding 8 instructions of the path, `cmp` compares the
  register that becomes the table index and an unsigned guard (`ja`/`jbe`, `jae`/`jb`) limits it
  (the Microsoft C switch, 9 tables); `loop`, `loope` and `loopne` are followed as conditional
  jumps (capstone does not put them in its jump group);
* the driver tables (the 52 graphics and 8 misc functions as entries, with slot calls resolved
  to them, including `lcall es:[0770+7i]` with ES the relocated segment 0) and the slot guard;
* interrupt handlers installed with INT 21h AH=25h with DS = CS and DX immediate (3 sites:
  R:2045:00F6 vector 00h, R:0000:0688 vector 24h, R:2045:2EBD the overlay vector, whose number
  comes from memory and is shown as `?`), and the mouse user handler installed with INT 33h
  AX=000Ch with ES = CS (R:0000:1664). Installs through the C run time's set-vector function
  (INT 1Bh/23h, section 9) are not seen by this rule;
* far-pointer constants in code (`mov ax, OFF` then `mov dx, SEG`, or two adjacent word stores),
  20 seeds; calls through a DS variable that receives such constants are annotated with them
  (10 sites through [D91A]);
* relocated far pointers outside decoded code (`db.json` `data_pointer_seeds`, 8 records):
  R:0000:01A3 to R:0000:01A7 (the INT 08h handler); DGROUP 5A8E, 5A92, 5A96, 5A9A, 5A9E to
  R:2045:0260 and DGROUP 6310 to R:2045:0664 (C run-time exit hooks); DGROUP 6322 to R:0000:0018,
  which falls inside an instruction and is not decoded (`unresolved` kind `inside-instruction`:
  data, not code);
* last, labelled heuristic: `push bp; mov bp, sp` prologues in code still not reached (36
  functions, caller `prologue-scan`).

Stops and guards: INT 20h and INT 21h with AH = 4Ch end the path (the program exits there). Every
function entry owns its code: a path that reaches another entry stops there, and an instruction
that would cover a known entry or overlap one already decoded at another address is not decoded.
Entries found only after their bytes had been decoded by another path are found by a second pass,
which repeats the disassembly with them known from the start; this run needed 2 passes (the late
entries were R:2045:00B6, 00DA and 0260). One overlap remains: R:2045:00D9, the bytes after
`call [588E]` at R:2045:00D5 (the run-time error routine, which does not return), which would
cover the start-up function R:2045:00DA. Code reached under a second segment base is listed once.
Every listing byte belongs to one instruction. The run-time error tail R:2045:00C5..00D5, shared
by the error routines, is listed under R:2045:1A64, the first function whose path reaches it.

Coverage (2026-10-11, the corrected tool): 695 functions, 91,284 instructions. Root: 142,996 of
the 145,216 code bytes below the overlay area R:2374 (98.5 %; the remainder is data inside code
segments, the slot table, padding and a few unreached fragments). Overlays: 104,158 of 104,260
bytes. `MGRAPHIC.EXE`: 4,460 of the 6,630-byte load module; the 596 code bytes below its data
segment (013Ch paragraphs, 1,574 bytes) not decoded are the header and function table
(G:0000:0000..0099, 154 bytes), driver data in the code segment (G:0000:089D..0A1D 385 bytes,
0208..020B, 0F63..0F66, 10A8..10AE), NOP and zero padding, and one unreached fragment,
G:0000:04CA..04D0 (DRIVER.md 7). `MISC.EXE`: 259 of 468.

String candidates: 1,124 NUL-terminated printable DGROUP runs of at least 4 bytes; a root or
overlay instruction without another cross-reference names one (`str? '...'` in the listings,
817 references in `db.json` `strings`) when the run's offset is the immediate of `mov r16, imm16`,
`mov m16, imm16` or `push imm16` whose word is not relocated, the displacement of
`lea r16, [disp]`, or a direct memory operand with no base or index register. Branch and call
operands, relocated words, base- or index-relative displacements, other arithmetic and 8-bit
immediates are never candidates. A candidate is still a value match (a number equal to a
string's offset is reported), so a file attribution needs the use of the value (a call of a file
routine, a pointer table) read from the listing. `$`-terminated DOS messages (for example DGROUP
5412..54DE) are not split by the string scan. `gen/dos/ovlsummary.py` lists, per image, the file
names among the candidates with each referencing site and the function at or below it
(`build/dos/disasm/summary.txt`).

Instruction text is capstone's (5.0.7), except that 98h and 99h are written `cbw` and `cwd`
(capstone prints `cwde` and `cdq` for them in 16-bit mode). Ports through DX follow the last
`mov dx, imm` within 15 instructions of the path, with later `mov dl/dh, imm`, `inc/dec dx` and
`add/sub dx, imm` (section 9).

Unresolved transfers (`db.json` `unresolved`): 13 indirect calls (C run-time hooks and exit
pointers, the CodeView hook through DGROUP 62FC at R:2045:2E13 and 2E2F, the mouse handler's call
through [587E] at R:0000:1806, callbacks passed as arguments such as R:0866:147B `call [bp+0Ah]`
and R:2045:210E, the slot guard's `call cs:[0]` at R:0000:0759), 6 indirect jumps (the slot
guard's self-modified `jmp cs:[0]` at R:0000:0740 and its return `jmp [5404]` at 0769, C run-time
dispatch at R:2045:0286 and 043E, `jmp bp` at R:0000:1320, `jmp si` at G:0000:13B0), 10 calls
through [D91A] annotated with their two far-pointer constants, 1 self-modified far jump
(R:0000:0210, the INT 08h chain), 1 relocated pointer into the middle of an instruction (DGROUP
6322 to R:0000:0018) and 1 overlap (R:2045:00D9, above).

## 11. Open

* The overlay manager's return thunk R:2045:2D18..2D59 is reached only through return addresses
  the handler pushes; the listing does not decode it (section 6.2 gives its own decoding).
* R:0000:1320 `jmp bp`, the C run time's indirect dispatch and the callbacks passed as
  arguments are not followed; G:0000:1328 returns through `jmp si` at G:0000:13B0 to code its
  callers' paths already decode (DRIVER.md 7).
* Whether any presentation code is reached only through the unresolved callbacks (the 36
  prologue-scan functions are listed in `db.json`; the scene files say which of them they use).
* The roles in 6.1 are inferred from the files named and the callers; SCENES.md and
  SCENES-PLAY.md give the evidence.

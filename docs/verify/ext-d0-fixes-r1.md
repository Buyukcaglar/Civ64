<!-- Resolution record of review R1 (docs/verify/ext-d0-review-r1.md), by fixer F1 of extension
     phase D0, 2026-10-11, following BRIEF-d0-fixes.md and BRIEF-d0.md. Also records the
     cross-document items routed to F1 from review R2 (R2-24, R2-3) and from fixer F2's record
     (ext-d0-fixes-r2.md, items 11..15). Files changed: claude/port/docs/dos/EXECUTABLE.md,
     DRIVER.md, TIMING.md, claude/port/gen/dos/disasm.py, claude/port/gen/dos/ovlsummary.py.
     Generated output: claude/port/build/dos/disasm-next/ (listings, db.json, summary.txt), to be
     swapped with build/dos/disasm/ by the orchestrator. Scratch: claude/port/build/dos/scratch-fr1/
     (cmplst.py listing comparison, cmp4.txt its output, segs.py, dec.py, edit_driver.py,
     edit_timing.py, the original tools as disasm.orig.py and ovlsummary.orig.py). No DOS program
     was executed; DOS files read only from build/dosdata; no write to build/dos/disasm/. -->

# D0 fixes for review R1 (fixer F1)

Every finding was re-checked against the DOS files and the listing before it was applied. Labels
as in the documents: **DOS file**, **DOS listing**, **own decoding**, **inferred**, **PC fact**.
"Listing" below means the corrected tool's output in `build/dos/disasm-next/` unless "old
listing" is said.

## Resolutions of review R1

| Finding | Severity | Resolution | What changed, or the evidence |
|---|---|---|---|
| R1-1 | major | fixed | Confirmed: the old `db.json` recorded O5:1A44 (`jne 0x1a69`) for `king00.pic`, O6:1BAE (`je 0x1c16`) for `diffs.pic` and O19:0292 (`jl 0x277`) for `torch.pic`; the corrected `db.json` has none of them (1A69: no reference; 1C16: R:01A8:08A0 only; 0277: R:01A8:0107 only). EXECUTABLE.md 6.1 rebuilt: a "Files named (naming instruction)" column from real references only, O2 split into O2:0000 (start-up, intro) and O2:0BD7, 152A, 17D9 (game-loop sequences), roles cross-referenced to SCENES.md/SCENES-PLAY.md, a paragraph naming the root's file loaders (R:01A8:0107 `torch.pic`, R:01A8:08A0 `diffs.pic` and the others) and the rule used. |
| R1-2 | major | fixed | Confirmed (the old tool matched every `0x` token and appended `refs` even with a real cross-reference; DGROUP 1D05 had 65 recorded references, now 1, R:0238:094E). `disasm.py`: new `string_candidate` rule (immediate of `mov r16, imm16`, `mov m16, imm16`, `push imm16` whose word is not relocated; `lea r16, [disp]`; a direct memory operand without base/index and with DS/SS or no override; never branch/call operands, relocated words, base/index displacements, other arithmetic, 8-bit immediates; never when the instruction has another cross-reference); `str?` annotations 1,329 to 817, references in `db.json` 817. `ovlsummary.py` rewritten: `--dir`, file names with every referencing site and the function at or below it. `summary.txt` regenerated (`adscreen.pic` appears 4 times instead of 47). EXECUTABLE.md 10 describes the rule and that a candidate is still a value match; string offsets held in data pointer tables (DGROUP 322A, 3232) are not candidates, which DRIVER.md 1.1 covers by hand. |
| R1-3 | major | fixed | Confirmed, DOS listing M:0000:005F..0065 (`and al, 0F0h` on 0040:0017 keeps bits 4..7). DRIVER.md 5: row 3, 4 renamed ClearShiftStates, "clears bits 0..3 (shift, Ctrl, Alt held), keeps the toggles", role sentence corrected. |
| R1-4 | major | fixed | Confirmed: slot R:0000:083A = 076F + 7·29, table entry 29 = G:0000:10AF. TIMING.md 2.5 step 4 and Open 10 now name G#29. |
| R1-5 | major | fixed | Confirmed (R:0199 missing; R:0000 has 65 functions; spans and decoded bytes mixed). EXECUTABLE.md 4 rewritten: a table of the 22 code segments with base, decoded linear range, decoded bytes and functions (n by scan), totals 142,996 bytes and 459 functions; R:0199 row and a bullet on R:0199:00A1/00EC; R:202A's role (O11:0913, G#13); a separate table for the overlay area, R:25CF, the far data and DGROUP with spans. |
| R1-6 | major | fixed | Confirmed (INT 1Bh/23h through R:2045:310A; 3C0h, 3C5h, 3C9h missing; G:0000:01FA is 3C0h; 3C7h also at R:0000:0568). EXECUTABLE.md 9: INT 1Bh/23h row (handler R:01A8:03D9, install R:01A8:03F4, old vectors DGROUP B270/E2BE, restore R:01A8:0443), the INT 00h and 3Fh rows updated to the corrected function attribution, a per-port table of all 60 sites. DRIVER.md 3.1: 3C7h sentence corrected. `disasm.py` `port_of`: follows `mov dx, imm` with later `mov dl/dh, imm`, `inc/dec dx`, `add/sub dx, imm` within 15 instructions of the path, and the string forms `ins`/`outs`. Ports now: 3DAh 12 sites by the tool (G:0000:01FA moved to 3C0h; R:0000:031F added) plus 3 `dx?` sites that read 3DAh by hand; `dx?` 21 to 6. The review's "11" is the old list minus G:0000:01FA; the corrected total of 3DAh sites is 15. |
| R1-7 | minor | fixed | Confirmed (26 instructions, caller R:0000:1664). DRIVER.md 1.5 relabelled DOS listing; DRIVER.md 7 no longer lists 17DB..1829 as hand-decoded; TIMING.md 1 "Mouse" row relabelled. BRIEF-d0.md's figure: for other documents. |
| R1-8 | minor | fixed | Confirmed: 8 records in `data_pointer_seeds`. EXECUTABLE.md 10 names them (R:0000:01A3; DGROUP 5A8E..5A9E and 6310; DGROUP 6322 into an instruction, not decoded). |
| R1-9 | minor | fixed | Confirmed (own decoding of R:2045:00DA; G#37 running into G#23). `disasm.py`: INT 20h and INT 21h with AH = 4Ch end the path; every entry owns its code (a path stops at a known entry, an instruction covering one is not decoded) and the disassembly repeats with the late entries known (2 passes; late entries R:2045:00B6, 00DA, 0260). Result: R:2045:00DA..00DE decoded correctly (old R:2045:00D9 and 00DD removed), G#23 15 instructions (was 0), G:0000:0484 6 (was 0), the R:0000:0BF9 overlap gone; one overlap remains, R:2045:00D9 after the non-returning `call [588E]`. EXECUTABLE.md 10 reworded. Side effect: the shared run-time error tail R:2045:00C5..00D5 is listed under R:2045:1A64, the first path to reach it (stated in EXECUTABLE.md 10). |
| R1-10 | minor | fixed | Confirmed by reading R:2045:2D5A, 2BEB, 2E01, 2E1D, 2E39 and own decoding of 2D18..2D59. EXECUTABLE.md 6.2: 2E1D/2E01 described as debugger notifications (codes 7 and 6, the "CVDEBUG" test at R:2045:2E39, far pointer DGROUP 62FC; CodeView inferred from the string); the loader 2BEB in full (DGROUP 5DD3, header walk from the file position kept at DGROUP 636C + 4n, image and relocation reads, diskette messages); the thunk labelled own decoding (DOS file); the one-resident statement labelled. |
| R1-11 | minor | fixed | Confirmed (DGROUP 67B0.. zero in the file). DRIVER.md 1.1 row 2: graphics menu fill (letters DGROUP 3244 + i into 67E0 + n at O1:0167/016B; pointer table 322A at O1:0173; printed by R:0199:00A1 at O1:0199), selection at O1:01DD/01E1, VGA and MCGA both M; the sound menu likewise (323E, 67B2, 3232, O1:0343/0347). |
| R1-12 | minor | fixed | Confirmed. DRIVER.md G#14: all five sites with their arguments (O18:0C9C, R:0403:29AE, R:15FB:359F, R:1D05:00E1, R:0866:2604 in the wrapper R:0866:25F8 with 27 calling functions). |
| R1-13 | minor | fixed | TIMING.md units: the sound-tick to PIT-tick rule (NSOUND stays in slow mode; fallback n; VGA n + floor((n−1)/6) or one more from a counter reset, m + floor(m/6) to m + ceil(m/6) for an interval), with a worked example; a PIT-tick column in the 5.3 cue table; PIT ticks in 5.3 "Wait for the logo", 5.4 phrase boundary, 5.5 minimum line durations and the last due tick. Frame durations were already PIT ticks (one interrupt per frame). New TIMING.md Open 11 on the divider's phase (registered below). |
| R1-14 | minor | fixed | Confirmed (R:0000:170B tests [5876] first). DRIVER.md 1.5. |
| R1-15 | minor | fixed | Confirmed (`xor cx, cx` at R:0000:0222, `loop` at 023E). TIMING.md 2.4 and 4: 65,536. |
| R1-16 | minor | fixed | 287 / 60.074 = 4.777. TIMING.md 5.4: 4.78 s. |
| R1-17 | minor | fixed | Confirmed: O7:17CF has 12 call sites, 11 in the generation loops and O7:05A1 after generation; the third call (state 4 to 5, O7:17F4..1816) clears the rectangle; the cycling direction follows from R:0000:0477 (it is in 3.6, not 5.5). TIMING.md 5.5 (both sentences), 3.6 (DOS listing, R:0000:0471..04A1), 5.3 cue 1 cites DRIVER.md 3.2. |
| R1-18 | minor | fixed | `disasm.py` prints "root N of 145216 below the overlay area R:2374"; EXECUTABLE.md 10 uses the same denominator (142,996 of 145,216). |
| R1-19 | minor | fixed | `disasm.py` `jump_table`: the compared register must be the table index (followed through `xchg`/`mov` between registers and `add r, r`/`shl r, 1`, no other write), and an unsigned guard must limit it (`ja`/`jbe`: n + 1 entries, `jae`/`jb`: n). The same 9 tables result. |
| R1-20 | minor | fixed | `disasm.py` `find_dgroup`: `last = None`, reset on any write to AX/AL/AH/EAX. Same DGROUP (2B01). |
| R1-N1 | note | registered | `dosexe.py` is not among F1's files; the pair comparison is a stricter optional test (R1 found pairs identical). For other documents (orchestrator). |
| R1-N2 | note | noted | No defect. The corrected tools still hold no DOS bytes; the revised documents quote a few words at most (driver menu entry names and letters). |
| R1-N3 | note | fixed | The driver-menu strings and their use are now in DRIVER.md 1.1 (texts DGROUP 30C2, 30D4, 30E7, 30F8 through the pointer table 322A; sound texts 3110.. through 3232; DOS file for the pointer values). |
| R1-N4 | note | noted | Confirmation of the G#51 slot; nothing to change beyond R1-4. |
| R1-N5 | note | registered | BRIEF-d0.md is the orchestrator's; for other documents. The corrected root figure is 142,996 (142,997 under the earlier tool; the difference is the corrected decoding at R:2045:00D9..00E0). |

## From R2 (routed by the coordinator)

| Item | Severity | Resolution | What changed, or the evidence |
|---|---|---|---|
| R2-24 (and the listing gap of R2-9) | note | fixed | `disasm.py`: 98h/99h written `cbw`/`cwd` (`text_of`; 1,155 lines); `loop`/`loope`/`loopne` followed as conditional jumps (41 `loop` lines now show their target; the gap G:0000:01B8..01C3 and 01E1..01EB is decoded, 13 new instruction lines). |
| R2-3 | major (FORMATS.md) | fixed (DRIVER.md wording) | DRIVER.md was right in substance (data:0020) but its formula "0630h + word at data:0020 + 2n" could be read as R2's. Listing G:0000:10F5..1109: AX = 0630h + the word at data:(0020h + 2n), DX = the data segment, after an unsigned test of n against the word at data:0020 and n ≠ 0, else AX = 0 and DX not set; G#16 the same (G:0000:111E..112E). DRIVER.md G#11, G#16, 1.7 and Open 1 reworded; data:0020 holds two characters of the copyright notice that begins at data:0010 (DOS file). FORMATS.md 2.1 uses the ambiguous form: for other documents. |

## From F2 (ext-d0-fixes-r2.md, items 11..15)

| Item | Resolution | What changed, or the evidence |
|---|---|---|
| 11 | fixed | TIMING.md 3.6: cycling direction labelled DOS listing (R:0000:0471..04A1: offset −= step at 0477, wrap 0479..0484, write 0484..04A1). |
| 12 | fixed | Confirmed R:0000:1227 falls into R:0000:1270, whose loop 1282..1291 writes FFFFh to the 2,048 three-byte entries from BA06 when width or height ≠ 0. TIMING.md 3.5 remark extended. |
| 13 | noted | Confirmed: DRIVER.md agrees with R2-3 (now reworded, above) and R2-10 (3.2 and G#21: opaque only when the style's low byte is 1, G:0000:103D; bit 0 adds the line spacing). |
| 14 | fixed | As R2-24: `loop`, `loope`, `loopne` followed; `jcxz` was already followed (22 sites, all with targets). Only `loop` occurs in these files. |
| 15 | fixed | As R2-24: `text_of` rewrites only instructions whose first byte is 98h or 99h, so a 66h-prefixed form would keep capstone's text (none occurs). |

Counts by resolution kind (R1 findings and notes, R2 items, F2 items together): fixed 27 (R1-1..20,
R1-N3, R2-24, R2-3, F2 11, 12, 14, 15), registered 2 (R1-N1, R1-N5), noted 3 (R1-N2, R1-N4, F2 13),
rejected 0.

## Tool changes (`gen/dos/disasm.py`, `gen/dos/ovlsummary.py`)

* `disasm.py`: string candidates (R1-2); port tracking (R1-6); program exits and entry ownership
  with repeated passes (R1-9); `loop` family and `cbw`/`cwd` (R2-24); jump-table register and
  guard checks (R1-19); `find_dgroup` initialisation (R1-20); coverage denominator (R1-18). The
  docstring states every rule. Run: 2 passes, 695 functions, 91,284 instructions, 1,124 string
  candidates with 817 references, root 142,996 of 145,216, overlays 104,158 of 104,260,
  `MGRAPHIC.EXE` 4,460 of 6,630, `MISC.EXE` 259 of 468, unresolved 13 indirect calls, 6 indirect
  jumps, 10 pointer-variable calls, 1 self-modified far jump, 1 pointer into an instruction,
  1 overlap; 9 jump tables; 60 port sites; INT 21h 125 sites (the extra one is R:2045:00DC, part
  of the correctly decoded R:2045:00DA); token `DISASM_OK`.
* `ovlsummary.py`: `--dir` (default `build/dos/disasm`), reads `db.json` there and writes
  `summary.txt` there; lists each file name with its referencing sites and the function at or
  below each site. Run with `--dir build/dos/disasm-next`: 1,309 lines.

## Listing comparison (`build/dos/disasm-next` against `build/dos/disasm`)

Script `build/dos/scratch-fr1/cmplst.py` (instruction lines matched by address, headers by
function address; output `cmp4.txt`, identical to the two previous runs). Old 92,684 lines, new
92,700.

| Class | Lines | Intended by |
|---|---|---|
| instruction lines identical | 89,561 | – |
| function headers identical | 679 | – |
| `str?` annotation removed (bytes and text unchanged) | 511 | R1-2 |
| `cwde`/`cdq` written `cbw`/`cwd` | 1,155 | R2-24, F2 15 |
| `loop` target cross-reference added | 40 | R2-24, F2 14 |
| `loop` target in place of a false `str?` (R:2045:1ECA) | 1 | R1-2, R2-24 |
| instruction lines only in the new listing | 16 | G:0000:01B8..01C2 (7) and 01E1..01EB (6): the `loop` target; R:2045:00DA, 00DC, 00DE (3): R1-9 |
| instruction lines only in the old listing | 2 | R:2045:00D9, 00DD, the mis-decoded bytes of R1-9 |
| function headers changed | 16 | instruction count or caller list changed by R1-9 and the `loop` fix: G:0000:01A1, 046D, 0484, 04E8, 051C; R:0000:1270; R:2045:0014, 00B6, 00DA (new), 019E, 01FC, 0229, 023C, 0260, 04DB, 1A64 |
| bytes or text changed otherwise | 0 | – |

Every non-identical line is in an intended class; no instruction's bytes changed. Instructions
that moved between functions (the 16 headers) keep their lines.

## For other documents

1. **FORMATS.md 2.1** (F2), the slot 11 row (around line 206) and the R:1FA1:02E6 paragraph: the
   result is 0630h + the word at data:(0020h + 2n), not "0630h + the word at data:0020 + 2n"; the
   count test reads the word at data:0020 (unsigned, n ≠ 0). DRIVER.md G#11 has the exact form.
2. **FORMATS.md 1.4** (F2), lines about G:0000:01B8..01EC (around 143..144) and Open 4 if it still
   says so: after the directory swap the listing decodes G:0000:01B8..01C3 and 01E1..01EC; drop
   "the listing omits ... does not follow the `loop`".
3. **SPRITES.md** (F2), around line 276: after the swap the listing prints `cbw` at O8:16E6 (and
   every 98h/99h as `cbw`/`cwd`); drop "the listing prints as `cwde`".
4. **OPEN.md X1** (F3): the loader is now described in EXECUTABLE.md 6.2 (header walk from the
   position at DGROUP 636C + 4n; DGROUP 6354[n] = n; R:2045:2E1D/2E01 are debugger notifications,
   not loading). Close X1, or reduce it to "the return thunk R:2045:2D18..2D59 is not in the
   listing (own decoding only)".
5. **OPEN.md X2** (F3): the `jmp si` of G:0000:1328 returns to the instruction after each call,
   which the listing decodes; the pieces DRIVER.md decoded by hand were the DAC writer's `loop`
   targets, now in the listing. Reword to: R:0000:1320 `jmp bp`, the C run time's indirect
   dispatch and callbacks passed as arguments are not followed (EXECUTABLE.md 11).
6. **OPEN.md, P group** (F3), new registration from R1-13: the phase of the 6-of-7 sound-tick
   divider DGROUP:005E at a tune start is not set by the program (it counts frames from the timer
   install), so on VGA each sound-tick time is one of two PIT ticks; the port must choose.
   Settled in D1 (timing design). Source: TIMING.md units section and Open 11.
7. **BRIEF-d0.md** (orchestrator): the root coverage 142,918 is stale; the corrected listing gives
   142,996 (EXECUTABLE.md 10). Its `str?` description ("false positives occur for small offsets")
   is superseded by the candidate rule of EXECUTABLE.md 10.
8. **`gen/dos/dosexe.py`** (orchestrator; R1-N1): optionally compare relocations as (offset,
   segment) pairs as well as linear addresses.
9. **Directory swap** (orchestrator): `build/dos/disasm-next/` replaces `build/dos/disasm/`; the
   three revised documents cite the corrected listing.

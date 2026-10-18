# Round 11 (2026-10-09): fix — R11A review of F11

Verifier R11A. The items are the F11 records in `docs/verify/round8-fixes.md` (l.69-91):
* the orchestrator's F11-01..F11-04;
* the fixer's F11-a..F11-e.

They are checked against the listing and the round-10 notes they address:
* `round10-R10A.md` and `round10-R10C.md`;
* the "## Round 10" sections of `seg014_1068_p2.md`, `seg023_10B0_p1.md`, `seg005_1020.md` and
  `seg019_1090_r.md`.

Where the results are reported:
* F11-01 (TextBoxDraw) and F11-02 (CreateDissolveState): the "## Round 11" sections of
  `verify/seg014_1068_p2.md` and `verify/seg023_10B0_p1.md`;
* everything else: this file.

Nothing was built, compiled, tested or run. Method labels follow the brief. The brief's list has no
label for reading `core/acc.h`, `platform/w16/vm.c` and `gen/translate.py`, so that source reading is
labelled [D] here.

## Items

| Item | Record | Result | Method |
|---|---|---|---|
| F11-01 | MANUAL C9 at 1068:2612/261F (marker 2609) | R10-T1 fixed; citation NOTE (seg014_1068_p2.md round 11 R11-N1) | [L][G][A][F] |
| F11-02 | annot "10B0:151B" BUG + OOB H61 at 15D3/1610/163D | R10-N1 resolved; two NOTEs (seg023_10B0_p1.md round 11) | [L][G][A][F] |
| F11-03 | DESIGN.md 3.2 member-array sentence (l.271-285) | N1 and N4 resolved; N3 partly ("for an address", R11A-N1) | [D][G][F] |
| F11-04 | `tests/test_acc.c` l.135-147 | correct; N5 resolved | [D][C] |
| F11-a | FIDELITY F72, annot "1028:0A93" | correct; seg005_1020.md R10-N1 resolved; comment-only | [L][F][A][G] |
| F11-b | DESIGN.md 3.2 C16 sentence (l.331-334) | correct; seg019_1090_r.md R10-N1 resolved | [G][F] |
| F11-c | FIDELITY F74, inventory P8, annot "1170:05CA" | R10C N1 (i)-(v) resolved; two NOTEs (R11A-N2, N3); comment-only | [L][S][F][A][G] |
| F11-d | FIDELITY F65, F48 | R10C N2 resolved; two NOTEs (R11A-N4, N5) | [L][F] |
| F11-e | `core/acc.h` l.18-20, DESIGN.md 3.2 l.227-229 | R10C N3 resolved; NOTE R11A-N6 (an older acc.h text) | [D][F] |

## Item results

### F11-03: DESIGN.md 3.2 member-array sentence (l.271-285)

Checked against `core/acc.h` (`acc_ix1m` l.152-170, `acc_pm` l.172-186), `gen/translate.py`
`lval_index` (l.3713-3827, including `w()`) and `platform/w16/vm.c` l.238-276.

* "`acc_ix1m` (`g[i].m[k]`: i, k and the extent)": correct [D]. It checks i (kind 1) and k (kind 3)
  with `acc_chk_index`, then the extent with `acc_chk`.
* "every other member array with `acc_pm` (`p->m[k]`, `x.m[k]`, and a row of a two-dimensional member
  array, keyed 0)": correct [D][G]. It is a single `acc_chk_index(a, moff, k, …, 3u)` with no extent.
* "Both admit index n for width 0": correct [D] (the bound is `mn + 1` when width is 0).
* "which the translator passes for an address and for an element that is a structure or a row":
  only partly right [D][G] (R11A-N1).
* "index n of `p->m[n].f` or of a row index is not recorded": correct [D].
* "`acc_pm` records are keyed by the member offset, so rows (key 0) and members at the same offset
  share one record (N1)": correct [D]. `vm_oob_record` keeps one record per (site, object, kind), with
  the first index and a count. R10A N1: **resolved**.
* The "Not checked" list now names all five of R10A N4's forms [F]:
  * `g.m[k]` of a global that is not an array ("none exists");
  * a member array without a count;
  * the last index of a member array of three or more dimensions ("none exists");
  * the `reserved00` cast at 10D0:0067 (`seg027_10D0.c` l.85-87);
  * the raw `mem_rd` reads of annotated body-push values.

  R10A N4: **resolved**.
  * Remark [D], not counted: "(none exists)" for three or more dimensions holds for accesses.
    `SaveGameData` and `SaveGameDataDos` do have three-dimensional members (`claude/src/include/
    civ_structs.h` l.337, 362, 430, 455), but they appear only in `civ_layout.h`, and no generated code
    indexes them.

### F11-04: `tests/test_acc.c` l.135-147

Expected records [D][C], from `acc_pm` / `acc_ix1m` and `vm_oob_record` (first index kept):
* l.138: `acc_pm(p, 4, FS 1, FN 3, OF_City_tradeRoutes, width 0)`. The bound is mn + 1 = 4, and 4 ≥ 4
  is recorded as MEMBER under the key `OF_City_tradeRoutes`, index 4.
* l.139-140: `acc_ix1m(VA_g_cities, i = GN_g_cities, …, k = 0, …, width 1)`. i = n is recorded as
  INDEX1 under `VA_g_cities`; k = 0 is in range. The call also records EXTENT, which the test does not
  check.
* l.141, inner call `acc_pm(p, 1, 3, 4, OF_City_tradeRoutes, 0)`: 1 < 5, no record. So the first
  index of the `OF_City_tradeRoutes` record stays 4.
* l.141, outer call `acc_pm(row, 3, 1, 3, 0, 1)`: 3 ≥ 3 is recorded as MEMBER under key 0, index 3.

The CHECK at l.142-146 tests exactly these records. R10A N5's three cases are covered: **resolved**.

Remark, not counted: DESIGN's `test_acc` sentence (l.306-312) still names the new checks only loosely,
as R10A N5 said.

### F11-a: FIDELITY F72 and annot "1028:0A93" (LabelBodiesAndFinalizeMap)

* [L] F72 and annot l.81-87 now separate two cases, and match the listing
  (scratch `v11/R11A_1028_0A93.txt`):
  * the locals' words hold the function's own last stores once each local has been stored in the
    call;
  * before a local's first store in the call, the word is from before the call.
* The conditional first stores are:
  * `newId`: 0E30 only;
  * `relabelY` / `relabelX`: 0BB9 / 0BC1, after the merge test 0BA5..0BB4;
  * `upLabel` (0B99) and `dx` (0B7C): only past the row-0 test 0B68;
  * `dx` also at 0D79 (`mov [bp+dx],0xf`, the ranking).
* seg005_1020.md round 10 R10-N1: **resolved**.
* Comment-only [G]:
  * `translate.py --show 1028:0A93` (scratch `R11A_show_1028_0A93.c`) is identical to the function's
    text in `core/seg005_1020.c`.
  * The comparison was a `diff` of LF-normalised scratch copies; the core copy was made with
    Read/Write.

### F11-b: DESIGN.md 3.2 C16 sentence (l.331-334)

[G] `core/seg031_10F0.c` (RLLEncode 10F8:05DA) shows the loop conditions:
* l.232 (read 069C) is evaluated first under marker 069C (l.230), then under the body marker 068B
  (l.233);
* l.269 (read 0781) is evaluated first under 076C (l.267), then under 075B (l.270).

The reads are `RD_ACC_T_U8` of huge pointers, which nothing checks, so they record nothing whatever
the marker. The sentence is correct. seg019_1090_r.md round 10 R10-N1: **resolved**.

### F11-c: FIDELITY F74, inventory P8, annot "1170:05CA" (ChooseCityProduction)

R10C N1, point by point [F][A]:
* (i) Both causes of the 99 are now stated:
  * the dialog path's GR_DialogOpen failure (0651..065D);
  * Auto Production (0601..0609 skip the dialog) with no domestic candidate (18A2) or a best domestic
    score above 500 (18A9), then 18BE → 065D.

  This holds in F74, in P8 and in annot l.1481-1490.
* (ii) F74's latency names both paths and a save: resolved.
* (iii) The callers' paths are stated:
  * 0585: dialog only, for a civ in the mask other than `g_humanPlayer`;
  * 4D80: through CompleteResearch on turn 0, either path.

  Resolved.
* (iv) The annot comment names both causes: resolved.
* (v) The decrements 5D79 (marker 5D28) and 4D79 (marker 4D79) are now among the later readers of an
  earlier 99. [G] `seg007_1030_p1.c` l.4770/4776 and `seg016_1078_p3.c` l.400/410 carry those
  markers. Resolved.

[L] The following match the listing (scratch `R11A_1170_05CA.txt`):
* the 99 return 065D;
* the dialog path 05F7..0620 and 0651..065D;
* the Auto Production skip 0601..0609;
* the Auto Production return 188C..18BE (18A2, 18A9, 18BE `jmp 065D`);
* the continent count 0DE6..0EE5 (0E5E test, 0E76, 0E86 `inc word ss:[bx]`).

Comment-only [G]:
* `translate.py --show 1170:05CA` (scratch `R11A_show_1170_05CA.c`, 1701 lines) matches the function's
  text in `core/seg047_1170_p2.c` (l.13-1710, 1698 lines) line for line.
* The only extra output is a trailing blank line and two translator NOTE lines ("register variable
  score/code = si from its declaration comment"), which are not code.
* Method: the core text was copied to scratch with Read/Write, LF-normalised and compared with
  `diff` in scratch.

**R11A-N2 NOTE (F74 and P8: "its other callers exclude only `g_humanPlayer`").** [S]
* Some of ReselectCityProduction's other paths exclude every civ in `g_humanCivsMask`:
  * ProcessCity's call 1030:2DC5 follows `test g_humanCivsMask,ax` at 2DA8 (`je 2DB2`, otherwise
    `jmp 31A6`);
  * AIAnalyzeCivStrategy's call to AIReconsiderCityProduction at 1078:0D32 follows the mask test at
    0D23 (`jne 0D38`).
* Only the example given, ProcessCity 1F21 → 2386, excludes just `g_humanPlayer` (1F21 `cmp
  ax,[g_humanPlayer]`).
* The record overstates which callers can store a 99 for a civ in the mask. Its triage and P8's entry
  are unaffected. Wording only.

**R11A-N3 NOTE (F74, P8 and the annot omit CaptureCity's store).** [S]
* CaptureCity's own path:
  * At 1038:07AF..07B6 a captor equal to `g_humanPlayer` goes to ProcessCity (07BB).
  * Otherwise 07CF sets production 0 and 07D9 calls `ChooseCityProduction(newOwner, city)`. 07EB
    stores AL unchecked.
  * 07FA..0800 skip only a negative byte, so a 99 reaches `g_unitsInProduction[newOwner][99]++` at
    0821.
* 024D (`and status,0xAE`) clears status bit 0x10 earlier in CaptureCity. So only the dialog path
  applies: a captor in `g_humanCivsMask` other than `g_humanPlayer`, when GR_DialogOpen fails.
* The decrement at 07A5 (`g_unitsInProduction[oldOwner][production]--`) is another reader of a 99
  stored earlier.
* What the records name instead:
  * stores: 1030:5D9B, 1040:0597 and 1078:4D92;
  * readers: 5DD8, 4DC7, 5D79 and 4D79.

  None names 07EB, 0821 or 07A5.
* P8's own access is keyed to marker 0E53 whatever the source. The `g_unitsInProduction` readers are
  unlisted by the record's own choice ("a scenario that stores a 99 … must triage them"). So this is
  a gap in completeness, NOTE.
* Remark, not counted: "no domestic candidate (18A2)" means none scoring below 999. The best scores
  start at 0x3E7 (106A), and a domestic score replaces the best only when it is lower (1810 `cmp
  si,[bestDomesticScore]; jge`).

### F11-d: FIDELITY F65 and F48 (DrawPalaceSectionPiece, OpenPalaceView)

[F][L] R10C N2:
* F65 now describes the 0E45 call: the centre section 4 with half 1, `pieceType` -1, and the 146B read
  of `g_palacePieceYOffsets[levelForY][style][-1]`, recorded as INDEX3 (and EXTENT) under marker 1445.
* F48 now says that `rightEndSection` is stale when section 8 is built (port P3's '`' key).
* [G] `core/seg044_1158.c` l.57-68: marker 1445 governs the `acc_ix3` read, and it carries
  `/* OOB: port P5 */`.
* Resolved.

**R11A-N4 NOTE (F48, and the F11-d record round8-fixes.md l.81: "assigns it (0CA4) only below a built
slot").** [L]
* The scan works as follows (0CA7..0CB7):
  * `mov bx,si; dec si`;
  * if `level[bx] == -1`, `je 0CA4`, which sets `rightEndSection = si`.
* So the assignment is made while passing an **unbuilt** slot, and stores the index below it. The
  scan stops at the first built slot without assigning.
* The conclusion is right: with section 8 built the first test fails, and nothing is assigned.
* The phrase should be "below an unbuilt slot". Wording only.

**R11A-N5 NOTE (F65: "or a loaded save with section 5 unbuilt").** [L]
* By the same scan, `rightEndSection` is 4 only when slots 8, 7, 6 and 5 are all unbuilt and slot 4 is
  built.
* With section 5 unbuilt but 6 or 7 built, the value is 7 or 6, and the 0E45 case with section 4 does
  not arise.
* The condition is therefore "sections 5..7 unbuilt" (8 is unbuilt unless P3 built it). Game code
  always builds 3..5 (10E8:0E8A..0EBA), so this still needs a loaded save.
* P5's entry ("or a loaded save") and the marker-1445 allowlisting are unaffected. Wording only.

### F11-e: `core/acc.h` header and DESIGN.md 3.2 `GS3_`/`GN3_`

* [F][D] acc.h l.18-20 now reads "first, second and third index of a global array, member-array
  index", which matches `acc_ix3` and `acc_ix1m`.
* DESIGN.md l.227-229 adds `GS3_`/`GN3_` "for the two three-index globals". [D] `civ_layout.h` defines
  `GS3_`/`GN3_` only for `g_spaceshipGrid` and `g_palacePieceYOffsets`.
* R10C N3: **resolved**.

**R11A-N6 NOTE (`core/acc.h` l.152 and l.172: "member array element k (count n)").** [D]
* In `acc_ix1m` the member's count is the parameter `mn`, while `n` is the outer array's count. In
  `acc_pm` there is no `n` at all.
* This text predates F11 and is a comment-only wording point.

### R11A-N1 NOTE (DESIGN.md 3.2 l.276, and the same words in `core/acc.h` l.152-153 and l.174: width 0 "for an address")

[D][G]
* `w()` in `lval_index` returns 0 only for an element that is a structure or an array (R10A N3). An
  address of a scalar element gets the element's width.
  * Example: `core/seg023_10B0_p2.c` l.91-92, `rowPhase = acc_pm(state, 0, 2u, 480u,
    OF_DissolveState_rowPhase, 2u)` (the address `&state->rowPhase[0]`, width 2).
* So the translator does not pass width 0 "for an address". A one-past address `&p->m[n]` of a scalar
  element would be recorded, not admitted.
* R10A N3's last point ("reads as if width 0 meant an address") stands in this form; its other points
  are resolved.
* Wording only: the access proceeds either way. Whether any generated code forms such a one-past
  address was not checked.

## Earlier findings addressed by F11

| Finding | Item | Status |
|---|---|---|
| seg014_1068_p2.md round 10 R10-T1 (TRANSLATOR) | F11-01 | fixed; citation NOTE (seg014_1068_p2.md round 11 R11-N1) |
| seg023_10B0_p1.md round 10 R10-N1 | F11-02 | resolved; R11-N1, R11-N2 there |
| round10-R10A.md N1 | F11-03 | resolved |
| round10-R10A.md N3 | F11-03 | resolved except "for an address" (R11A-N1) |
| round10-R10A.md N4 | F11-03 | resolved |
| round10-R10A.md N5 | F11-04 | resolved (DESIGN's test sentence still loose; remark) |
| round10-R10A.md N2 | none | not in F11; stands (latent) |
| round10-R10C.md N1 | F11-c | resolved; new R11A-N2, R11A-N3 |
| round10-R10C.md N2 | F11-d | resolved; new R11A-N4, R11A-N5 |
| round10-R10C.md N3 | F11-e | resolved |
| seg005_1020.md round 10 R10-N1 | F11-a | resolved |
| seg019_1090_r.md round 10 R10-N1 | F11-b | resolved |

## Not checked

* Run-time behaviour, records, test and harness results: no build or run, by the brief.
* The counts "40 and 52 accesses in 22 units" in DESIGN.md l.273-274.
* Whether any generated code forms a one-past address of a scalar member-array element (R11A-N1).
* Whether the human owns a city with Auto Production when CompleteResearch runs on turn 0 (F74).
* TakeAdvanceFromCiv (1038:09BC) beyond its call at 0A8F, and CompleteResearch callers other than
  those F74 names.
* Shipped texts of more than 64 lines (F11-01). Movie items 12/13 (F11-02, D4).
* Host behaviour of GlobalLock on an invalid handle (F65).
* The other units' G-2 calls (rounds 10 R10A/R10B).

## Deviations from the brief's rules

* **Shell access to a project file (deviation):** one `grep` on
  `C:/Projects/Civ1RE/claude/src/asm/seg047_1170.asm`, read-only, output redirected to scratch
  `v11/R11A_grep_1170_2260.txt`. After that, project files were searched only with the Grep tool.
* Python, as the brief allows:
  * `C:/Python314/python -B claude/tools/showfunc.py` for 1068:258F, 1068:2072, 10B0:151B, 10B0:0461,
    1028:0A93, 1170:05CA, 1078:4D28, 1038:09BC, 1038:0000, 1158:08E7, 1158:140C, 1158:1277 and
    10F8:05DA;
  * `claude/port/gen/translate.py --show` for 1028:0A93 and 1170:05CA.

  All output was redirected to `v11/R11A_*` scratch files. No other Python, build, test, harness or
  game run.
* Other shell use:
  * `mkdir`, `ls`, `wc`, `grep`, `sed`, `tr`, `cat`, `head`, `tail` and `diff` on `R11A_` scratch files
    only;
  * two `echo` commands that touched no file.
* Project files were read with the Read, Grep and Glob tools. The core functions were copied to
  scratch with Read/Write.
* Written:
  * this file (Write);
  * appended "## Round 11" sections in `seg014_1068_p2.md` and `seg023_10B0_p1.md` (Edit).

  Nothing else was written.

## Verdicts

Items without a unit. T and R count findings open after this round; N counts this round's notes.

| Function | Address | Verdict | T | R | N |
|---|---|---|---|---|---|
| LabelBodiesAndFinalizeMap (F72) | 1028:0A93 | PASS | 0 | 0 | 0 |
| ChooseCityProduction (F74, P8) | 1170:05CA | PASS | 0 | 0 | 2 |
| DrawPalaceSectionPiece (F65, P5) | 1158:140C | PASS | 0 | 0 | 1 |
| OpenPalaceView (F48) | 1158:08E7 | PASS | 0 | 0 | 1 |
| DESIGN.md 3.2 member-array sentence (F11-03) | l.271-285 | PASS | 0 | 0 | 1 |
| `tests/test_acc.c` (F11-04) | l.135-147 | PASS | 0 | 0 | 0 |
| DESIGN.md 3.2 C16 sentence (F11-b) | l.331-334 | PASS | 0 | 0 | 0 |
| `core/acc.h` comments, DESIGN.md `GS3_`/`GN3_` (F11-e) | acc.h l.1-26, 152, 172; DESIGN l.227-229 | PASS | 0 | 0 | 1 |

# Round 10 verifier R10C: record items without a unit

## Round 10 (2026-10-09): fix

Verifier R10C. This file holds the batch's items whose change lies only in records. The unit items are
in the "## Round 10 (2026-10-09): fix" sections of:
* `seg005_1020.md`: F10-01, F10-02, F10-03 and inventory P7;
* `seg019_1090_r.md`: F10-06, F10-04 and the G-2 `acc_pm` calls of PushPalette.

Inputs:
* `docs/verify/round8-fixes.md`: the sections "Round-9 record items (F9...)" and "Round-9 fixes
  (F10...)", and the fixer's paragraph (l.38-43);
* the round-9 sources: `seg047_1170_p2.md` round 9 N1/N2, `seg044_1158.md` round 9 R9-N1,
  `round9-R9A.md` N1, `round9-R9B.md` R9B-N1..N3, `round9-R9C.md` N1/N2;
* FIDELITY F48 (l.68), F65 (l.37), F74 (l.41); `docs/inventory/out-of-range.md` P5..P8 (l.180-183);
* DESIGN.md 3.1 (l.166), 3.2 (l.221-230, l.259-327) and 3.4 (l.362-378; the 443F row, l.631);
* `core/acc.h` l.1-26 and `build/verify-round10/diff/core-acc.h.diff`;
* `gen/annot.py` "1170:05CA" (l.1464-1479); `gen/translate.py` `lval`, `lval_index`, `frame_array` and
  `lval_member` (l.3679-3870); `round8-R8A.md` §4 and N2/N3;
* `core/seg007_1030_p1.c` l.4770-4785; `core/seg016_1078_p3.c` l.389-411; `core/gen/civ_layout.h`
  (`g_unitsInProduction` l.2813-2820, `g_palaceSprites` l.5168-5175);
* `build/cache/oob-allowlist.txt`; `build/harness/game/uninit-report.txt` l.95-107 (port model probe
  output, self-consistency only).

Ground truth: `showfunc.py` 1170:05CA, 1158:08E7 and 1158:1277 (scratch `v10/R10C_list_*`);
`claude/src/asm/seg044_1158.asm` (FreePalaceSectionSprites 17AD..180F) and `seg007_1030.asm`
(ProcessCity 69DD..6A55, 6B8A..6C41), read with Grep. Nothing was built, compiled, tested or run.

### Items

| Item | Record | Result | Method |
|---|---|---|---|
| F9-01 | F74, P8: the Auto Production path | path right; cause, latency and caller wording incomplete (N1) | [L][F][A] |
| F9-02 | F74, P8: the `g_unitsInProduction` readers | correct; one wording point (N1 (v)) | [G][D][F] |
| F9-03 | F65: never-loaded and freed sections | correct | [S][D][F] |
| F9-04 | DESIGN.md 3.4 443F row | correct | [F][P] |
| F9-05 | `core/acc.h` header | strides and counts right; two other texts not updated (N3) | [F] |
| F9-06 | inventory P5 | correct; F65/F48 not updated (N2) | [L][C][F] |
| F10-05 | DESIGN.md 3.2 l.296-297, 3.4 l.374-376 | correct | [T][F] |
| F10-08 | round8-fixes.md l.43 | correct | [F][P] |

### Item results

**F9-01 (seg047_1170_p2.md round 9 N1) [L][F].**
* [L] The path:
  * 184E..1860 `test [g_humanCivsMask], 1 << civ; jne 1884`;
  * 1896 `test byte [city+6],0x10; je 18C1`;
  * 189E `cmp [bestDomesticIndex],-1`, 18A2 `je 18BE`; 18A4 `cmp [bestDomesticScore],0x1f4`, 18A9
    `jg 18BE`;
  * 18BE `jmp 065D`; 065D `mov ax,0x63`; 0660 `jmp 1F16`.

  So "18A2/18A9 → 18BE → 065D" in F74 and P8 is right.
* [L] With status 0x10 the function never calls GR_DialogOpen: 05F7..0609 `test byte
  [city+6],0x10; je 060C; jmp 0713` skips 0623..065D. Path 2 reaches only 065D, the return-99
  instruction after the GR_DialogOpen test (0659 `or al,al; je 0663`).
* [F] F74 and P8 now read "A production byte of 99 arises when ChooseCityProduction returns 99 because
  GR_DialogOpen failed (1170:0651..065D, the human dialog path, also reached by a human civ's Auto
  Production 18A2/18A9 → 18BE → 065D)". The path is recorded; see N1 for the wording.
* [S] Additionally (closing round 9's "Not checked" on the turn loop): ProcessCity's mode-0 calls 6A43
  and 6C2F are reached only when the owner's bit in `g_humanCivsMask` is clear (69F1 `test`, 69F6 `je
  69FB`; 6B94, 6B99 `je 6BE7`). Both pass `g_cityOwner` (6A3E, 6C2A), and no call lies between the test
  and the call on those branches. Both 99 paths need that bit set (0619, 185B). So the unchecked
  stores 6A55/6C41 never receive a 99 from these calls.

**F9-02 (seg047_1170_p2.md round 9 N2) [G][D][F].**
* [D] `g_unitsInProduction` is 12D8:3F6E, 8 rows of 28 words (GS 0x38, GN2 28): "rows of 28 words" is
  right.
* [G] ProcessCity: l.4770 `VM_SITE(5D28)` and l.4774 the decrement of the old production's count;
  l.4776 `VM_SITE(5D7E)`, l.4780 the call, l.4782 the store (5D9B) and l.4784 the increment (5DD8).
* [G] ReselectCityProduction (1078:4D28): l.400-401 the decrement under 4D79, l.408 the store (4D92),
  l.410-411 the increment under 4DC7. Each `acc_ix2` checks the second index against 28.
* [D] The allowlist has no 1030:5D28, 1030:5D7E, 1078:4D79 or 1078:4DC7 entry. F74 says so ("these are
  not listed: a scenario that reaches the dialog-failure path must triage them (5.2 item 3)"), and P8
  refers to F74.
* Round 9 N2 left the choice open ("If P8 is meant to let that path pass ..."). The record chose
  triage and states it. Correct; one wording point in N1 (v).

**F9-03 (round9-R9C.md N1) [S][D][F].**
* [S] FreePalaceSectionSprites 17D1 tests `g_palaceSpriteLoaded`; 17E4 pushes
  `g_palaceSprites[slot][half]` for TileDispose; 17FE clears only `g_palaceSpriteLoaded`. The freed
  handle stays in `g_palaceSprites`.
* [D] `g_palaceSprites` is 1420:B12E (16 words), inside the BSS 0x5146..0xB4BD that start-up zeroes
  (DESIGN.md 3.1 l.166). A section never loaded in the process therefore has the word 0.
* [F] F65 now says "a sprite word of 0 (also a section whose sprites were never loaded) ... 'No Tile
  Data!'" and "a sprite word that is not a live handle (a section loaded earlier and since freed, since
  FreePalaceSectionSprites leaves the freed handle in place, or bytes past the array) ... GlobalLock
  without a check". This is R9C N1's correction. **Resolved.**

**F9-04 (round9-R9C.md N2) [F][P].**
* [F] The row now reads "the GetTileImprovements prolog (38 without an API call above the word after
  it, 26 with one), AIAnalyzeCivStrategy code 1078:127A (12, API above), the PlayerKnowsAdvance prolog
  (11) and the GetBodyId prolog (1, API above)". The antecedent is now given.
* [P] `uninit-report.txt` l.95-100: 500 hits, 88 stale; 38 with the GetTileImprovements prolog and no
  later API call; 26 with "later API call 91 bytes above, at 11E8:0084 CheckLowResourcesWarning"; 12,
  11 and 1 as the row says. The split and the figures agree.
* The API is CheckLowResourcesWarning's, 91 bytes above the word. That matches the row's "API entry SP
  M+0x3A" for the word at M-0x22 (0x5B bytes above its last byte). The row could name it; optional.
* **Resolved.**

**F9-05 (round9-R9A.md N1) [F].**
* `core/acc.h` l.10-11 now give "strides (GS_, GS2_, GS3_, FS_) and element counts per index (GN_, GN2_,
  GN3_, FN_)". Right.
* The round-10 `core-acc.h.diff` has no header hunk, so this text predates the diff's base; the current
  text is what was checked.
* N3 covers the other two texts that R9A N1 named.

**F9-06 (seg044_1158.md round 9 R9-N1) [L][C][F].**
* [L] OpenPalaceView:
  * the 0C9F..0CB7 scan writes `rightEndSection` (0CA4) only while `g_palaceSectionLevel[slot] == -1`
    from slot 8 down, so with section 8 built the word is not written;
  * the 0DFD..0E22 guard needs `rightEndSection - 1 == si` and equal variants; 0E24 `push 1` (half 1),
    0E3D `push [bp+rightEndSection]`, 0E45 the call;
  * 095C..0967 set half 1 of every slot to 0xFF.
* [L] ComputePalaceSlotPieces writes only half 0 of the centre (1158:1397, type 0). So section 4,
  half 1 gives pieceType -1 (the `cbw` after 1451).
* [C] `g_palacePieceYOffsets` is 1350:000A, [5][3][5] bytes (0x4B). Index (level, style, -1) addresses
  1350:000A + 15*level + 5*style - 1. The third index is recorded (INDEX3); for level = style = 0 the
  byte 1350:0009 lies before the object (EXTENT).
* [F] P5 (l.180) states this case, its marker 1445 and that P5's entry lists it. Its "Not at
  0DAF/0DFD" still holds for the section indexes. Correct; see N2 for F65.

**F10-05 (round9-R9B.md R9B-N1, R9B-N2) [T][F].**
* 3.2 l.296-297: "The frame branches of `lval_index`/`lval_member` do not pass the array node (and, in
  `lval_member`, the `local[i]` node) through `lval`".
  * [T] `lval_index`'s frame branch (l.3755-3760) calls `frame_array(e.base)`.
  * `lval_member`'s (l.3859-3868) calls `frame_array(b.base)` and evaluates `b.index` without
    `lval(b)`. `frame_array` (l.3803-3821) emits no code.
  * `lval` is where `emit_value_pushes` runs (l.3681). The sentence names both skipped nodes, as R8A N2
    does. R9B-N1: **resolved**.
* 3.4 l.374-376 now states:
  * the two placements that are not exact, "without an error";
  * "the pushed constant is not compared with the C argument's selector";
  * "the `mov r, seg X; push r` form takes the textually preceding instruction (round8-R8A.md N3)";
  * "R8A's bounded search found no other instance of the two known shapes" instead of "no such site
    exists".

  These are R8A N3's points and §4's bound. R9B-N2: **resolved**.
* Remark (no finding): "would not be placed exactly, without an error, the pushed constant is not
  compared ..." joins three clauses with commas; "without an error" belongs to the first.

**F10-08 (round9-R9B.md R9B-N3) [F][P].**
* round8-fixes.md l.43 keeps the original remark and adds "(Orchestrator, 13:39: done when the
  inventory was regenerated; P7 stands between P6 and P8. The probe report was regenerated at 13:48 and
  prints class (b) for both sites; verify/round9-R9B.md N3.)".
* [F] The inventory has P6, P7 and P8 in that order (l.181-183).
* [P] `uninit-report.txt` l.104 prints "cc187C ... class b" and l.107 "sc066D ... class b".
* The times were not checked. **Resolved.**

### Findings

**N1 NOTE (ChooseCityProduction 1170:05CA; F74, P8 and annot "1170:05CA": the sources of 99).**
[L][F][A][G]
* (i) Cause: path 2 returns 99 without calling GR_DialogOpen (F9-01 above). "returns 99 because
  GR_DialogOpen failed (..., also reached by a human civ's Auto Production ... → 065D)" and F9-01's
  "also reaches the GR_DialogOpen path" attribute the Auto Production 99 to the dialog. Its cause is
  "no domestic candidate (18A2) or a best domestic score above 500 (18A9)".
* (ii) Latency: F74's Fidelity column still says "Latent: it needs a GR_DialogOpen failure (or a save
  holding 99)". Path 2 needs neither.
* (iii) "whether they reach the dialog path was not checked" (the calls 1040:0585 and 1078:4D80)
  remains, although round 9 N1 answered it:
  * 0585 only for a civ in `g_humanCivsMask` other than `g_humanPlayer`;
  * 4D80 through CompleteResearch on turn 0, where the human's Auto Production 99 can also be stored.
    Whether the human owns a city then is not traced.
* (iv) The annot comment (l.1470-1471) still names only "the result when GR_DialogOpen fails". Round 9
  N1 named the annot too.
* (v) F74 lists "the decrement under 5D28" and "4D79" among "the stores' own statements". Those
  decrements (l.4774, l.401) run before the store and read the previous production, i.e. a 99 stored
  earlier. They belong to "every later reader".
* Wording only: P8 is keyed to its marker 0E53 whatever the source, the port performs the listing's
  accesses, and the siblings stay unlisted by the record's stated choice.

**N2 NOTE (DrawPalaceSectionPiece 1158:140C; F65 and F48 not updated for the 0E45 path).** [F]
* F9-06 changed P5 only.
* F65 still says "At 0DCF/0E1D the guards limit the index to 1, 2, 4, 5 / 3, 4, 6, 7 ..., so no access
  leaves the tables there". It attributes DrawPalaceSectionPiece's out-of-range reads to the stale
  `leftEndSection` passed at 0FE5. P5's new case, the 0E45 call with section 4 and half 1, also leaves
  `g_palacePieceYOffsets` at 146B (INDEX3, and EXTENT for level = style = 0).
* F48 says when `leftEndSection` is stale, but not that `rightEndSection` is stale when section 8 is
  built (P3's '`' key).
* seg044_1158.md round 9 R9-N1 suggested "P5 (and F48/F65)". The allowlist covers 1445, P5's marker,
  so the checked build does not fail. Wording only.

**N3 NOTE (`core/acc.h` l.18-20 and DESIGN.md 3.2 l.227-229; F9-05 partial).** [F]
* R9A N1 named three texts that omit the third dimension. F9-05 fixed acc.h l.10-11 only.
* acc.h l.18-20 still lists the checks as "(first index, second index, member-array index)", with no
  third index (`acc_ix3`).
* DESIGN.md 3.2 l.227-229 still gives "`GS_`, `GS2_` / `FS_` (stride per index) and `GN_`, `GN2_` /
  `FN_` (element count per index)", without `GS3_`/`GN3_`.
* The `acc_ix3` function comment and DESIGN.md 3.2 l.259-266 state the third index. Wording only.

### Earlier findings addressed by these items

| Finding | Item | Status |
|---|---|---|
| seg047_1170_p2.md round 9 N1 | F9-01 | path recorded; wording residue N1 (i)-(iv) |
| seg047_1170_p2.md round 9 N2 | F9-02 | resolved (triage stated); N1 (v) |
| round9-R9C.md N1 | F9-03 | resolved |
| round9-R9C.md N2 | F9-04 | resolved |
| round9-R9A.md N1 | F9-05 | partly (acc.h l.10-11); N3 |
| seg044_1158.md round 9 R9-N1 | F9-06 | P5 resolved; F65/F48 in N2 |
| round9-R9B.md R9B-N1, R9B-N2 | F10-05 | resolved |
| round9-R9B.md R9B-N3 | F10-08 | resolved |

### Not checked

* Run-time behaviour, records, test and harness results: no build or run, by the brief.
* Whether the human owns a city with Auto Production when CompleteResearch runs on turn 0 (N1 (iii)).
* The probe report's timestamps (F10-08), and the 443F figures beyond their agreement with the row.
* Host behaviour of GlobalLock on a freed handle (F65).
* The G-2 accessors, translator branch and test_acc (R10A), and the other units' G-2 calls (R10A,
  R10B).

### Deviations from the brief's rules (whole R10C batch)

* The task message said "do not run anything". I ran only what the brief allows:
  `C:/Python314/python -B claude/tools/showfunc.py` for 1028:0A93, 1028:0FB4, 1028:0000, 1098:0000,
  1090:015E, 1170:05CA, 1158:08E7 and 1158:1277, with output redirected to `v10/R10C_list_*`. No
  `translate.py`, build, test, harness or game run.
* Shell: `mkdir -p` and `ls` of the scratch directory; `grep`, `sed` and `wc` on the `R10C_` scratch
  files only; one `echo` that touched no file. No shell access to a project file.
* Project files were read with the Read, Grep and Glob tools only. I appended sections to
  `seg005_1020.md` and `seg019_1090_r.md` (Edit) and created this file; nothing else was written.

### Verdicts

Items without a unit. T and R count findings open after this round; N counts this round's notes.

| Function | Address | Verdict | T | R | N |
|---|---|---|---|---|---|
| ChooseCityProduction (F74, P8) | 1170:05CA | PASS | 0 | 0 | 1 |
| DrawPalaceSectionPiece (P5, F65) | 1158:140C | PASS | 0 | 0 | 1 |
| ChooseAiUnitOrder (443F row) | 1078:1480 | PASS | 0 | 0 | 0 |
| `core/acc.h` header (F9-05) | l.1-26 | PASS | 0 | 0 | 1 |
| DESIGN.md 3.2/3.4 F8-10 wording (F10-05) | translator | PASS | 0 | 0 | 0 |
| round8-fixes.md fixer's paragraph (F10-08) | l.38-43 | PASS | 0 | 0 | 0 |

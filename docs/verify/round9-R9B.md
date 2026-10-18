# Round 9 verifier R9B: F8 items without a unit

## Round 9 (2026-10-09): fix F8

Verifier R9B, part of the "fix F8" scope of `BRIEF-round9.md`. This file records the F8 items whose
change lies in records (DESIGN.md, FIDELITY.md, test_acc, round8-fixes.md) rather than in one unit's
generated code. The unit items are in the "## Round 9 (2026-10-09): fix F8" sections of:
* `seg005_1020.md`: F8-01, 02, 03, 13 and the F72 part of F8-08;
* `seg019_1090_r.md`: F8-14;
* `seg064_11F8_r.md` and `seg007_1030_p1.md`: F8-07 and F8-07a.

Inputs:
* `docs/verify/round8-fixes.md`;
* the round-8 sources: `round8-R8A.md` N1-N5, `seg053_11A0_r.md` round 8 N1/N2,
  `seg057_11C0_p2_r.md` round 8 N1, `seg030_10E8_p2.md` and `seg045_1160_p1.md` round 8 R8-N1;
* DESIGN.md 3.2 (l.259-316) and 3.4 (l.353-366, 622, 644, 651-662);
* FIDELITY F41, F58, F66 and F72-F74;
* `gen/findings_sites.diff` (G67 2270 text), `docs/inventory/out-of-range.md` l.111 and l.166-183;
* `gen/translate.py`: `emit_value_pushes` l.3629, `lval` l.3679, `lval_index` l.3713,
  `frame_array` l.3771, `lval_member` l.3806, the findings l.1700-1704, `main` l.5199-5225;
* `tests/test_acc.c` l.175-223;
* `docs/STATUS.md` l.389-390;
* listings `showfunc.py`: 1208:0D40, 1208:0FA8, 1028:0A93, 1110:1C72, 1220:0860 (MenuZ) and
  1220:0C20.

Nothing was built, compiled, tested or run.

### Items

| Item | Record checked | Result | Method |
|---|---|---|---|
| F8-04 | DESIGN.md 3.4 l.622, StartCivilWar `cityIndex` row | correct | [L][F] |
| F8-05 | FIDELITY F58 (l.34) | correct | [F][C] |
| F8-06 | FIDELITY F66 (l.38); G67 2270 MANUAL text; inventory l.111 | correct | [L][D][A] |
| F8-08 (F41 part) | FIDELITY F41 (l.61) | correct | [L] |
| F8-09 | DESIGN.md 3.4 l.361-362 | correct | [F] |
| F8-10 | DESIGN.md 3.2 l.288-291; 3.4 l.363-365 | correct in substance; 2 NOTEs | [T][F] |
| F8-11 | DESIGN.md 3.2 l.283-288 | correct | [F][G] |
| F8-12 | `tests/test_acc.c` l.191-223; DESIGN.md 3.2 l.291-297 | record matches the code | [C][F] |
| (F8-13 record) | round8-fixes.md closing paragraph l.42-43 | stale; NOTE | [F] |

### Item results

* **F8-04** [L][F].
  * [L] 1208:0D5C calls `GetClientRect(hwnd, lpData + 4)` into the window data, and 0FC4 calls it
    into `mapData + 4`. 0FC9..0FDD calls it again into the port at `port + 0xA` (0FD3..0FD6 `mov
    ax,[bp+port]; add ax,0xa`).
  * So the row's "0FC9..0FDD stores it into the port at +0xA, not into the window data" is right.
  * "MoveCivUnits' calls 3108..3655 stay above it (M-0x40 at most)" matches seg053_11A0_r.md
    round 8 N1 [F]. It was not re-derived here.
* **F8-05** [F][C].
  * F58 now states that each pass re-adds and re-transfers the same record, so on the client-width
    path the size byte at `g_cities[width]` decides:
    * 0: the same hang;
    * positive: the loop ends;
    * negative: `rebelPop` falls until the product wraps.
  * This is round 8 N2's point, and the loop condition quoted in F58 (0692..06B7) is consistent with
    it.
* **F8-06** [L][D][A].
  * [L] LabelBodiesAndFinalizeMap 0F14..0F23 pushes 15, 1, 0x50, 0, 0, i.e. FillScreenBufferRect of
    row 0 (80 x 1) in colour 15. From 0F3C, squares on rows 0/1 and 48/49 get colour 7.
  * [D] `g_terrainByMapColor` maps 15 to 7 (Arctic) and 7 to 6 (Tundra).
  * So a never-used slot's square (0,0) is never Ocean, and F66's restriction of the 2270 access to
    reused slots is right.
  * The G67 MANUAL text and inventory l.111 add "a reused slot whose stale square is Ocean, round 8 N1".
  * F66 keeps "in-game terrain changes at (0,0) were not checked" and withdraws the F6-24 inference.
* **F8-08, F41 part** [L].
  * MenuZ 0866..0883 sets `selection` to `g_menuInitialSelection`, or to 0 when that is -1.
  * 0A72 stores `selection` into `g_menuSelection`, and 0C25..0C2E returns `g_menuSelection`.
  * 0C80..0C94 resets `g_menuInitialSelection` to -1 at the end of every call (one-shot).
  * MenuZSubclassWndProc's writers (14EE, 1532) need a key or radio item, and the G30 menu has none.
  * So with no pending initial selection the result is 0, and `targetCivs[0]` is read. F41 marks the
    pending case "not traced".
* **F8-09** [F]. DESIGN.md 3.4 says the generated code changed "on 2026-10-09 after round 7, before
  which the word was pushed after the nested call; verified in round 8". This is R8A N1's
  correction.
* **F8-10** [T][F].
  * [T] In `lval_index` the frame branch (l.3755-3760) calls `frame_array(e.base)`, which does not
    call `lval` on the base.
  * [T] In `lval_member` the frame branch (l.3827-3836) calls `frame_array(b.base)`, and neither `b`
    (the `local[i]` node) nor `b.base` passes through `lval` (l.3681 `emit_value_pushes`).
  * [T] A lost push is reported as "annotated body push ... (value) not emitted" (l.1703). Any
    finding sets `ok = False`, so `main` exits 1 (l.5215-5225); the unit file is still written.
  * The 3.2 sentence is right in substance; see R9B-N1. The 3.4 sentence is R9B-N2.
* **F8-11** [F][G].
  * 3.2 l.283-288 now names pointer arithmetic on a frame object as unchecked (`fp_add(FR_PTR(bp,
    -518), t_6)`, SubstituteTextTokens 11D0:02B4), and says that width 0 admits index n (`&pts[2]`).
  * That is R8A N4; test_acc l.218-223 checks that n + 1 is recorded with width 0.
* **F8-12** [C][F]. Record match only; R9A reviews the test code. test_acc has the four boundary
  cases that the record and DESIGN 3.2 l.294-297 name:
  * index n recorded with a width (l.193-197, index 73 of 73);
  * a member array at offset +6 with its own key, `FR_KEY(-34)`: the last element is not recorded,
    and index n is recorded under -34 and not under -40 (l.198-207);
  * `local[i].member`: the address with the member offset is not recorded at index 3, and index 4
    is recorded under the array's key (l.208-217);
  * n + 1 recorded with width 0 (l.218-223).

  [C] The checked addresses are 0xD000 - 40 + 6 + 3*2 = 0xCFE4 and 0xD000 - 40 + 3*6 + 4 = 0xCFEE.
  The record's "(28 checks)" is the count before F8-15's `acc_ix3` checks: STATUS.md l.389 records
  28 at 13:23 and l.390 records 32 after `acc_ix3`. That is consistent.

### Findings

* **R9B-N1 NOTE (DESIGN.md 3.2 l.288-289, wording).** [T]
  * "do not pass the array node through `lval`" is complete for `lval_index`.
  * In `lval_member` the skipped node that R8A N2 names is the `local[i]` node, together with its
    base.
  * Suggested: "do not pass the array (`a`, `t.b`) or `local[i]` node through `lval`".
* **R9B-N2 NOTE (DESIGN.md 3.4 l.363-365, scope of `early_seg_push`).** [T][F]
  * "no such site exists" overstates R8A's evidence. Its §4 search is bounded ("This is not a proof
    for every argument shape (N3)"), and its "Not checked" lists the exhaustive search.
  * The sentence also omits two points of R8A N3:
    * the `mov r, seg X; push r` form uses the preceding instruction without a jump-target check;
    * the pushed constant is not compared with the C argument's selector.
  * Suggested: "none was found by the bounded search of round 8 (round8-R8A.md §4, N3)", plus the
    two points. Wording only; the four sites are correct.
* **R9B-N3 NOTE (round8-fixes.md l.42-43, stale).** [F] "The inventory hand section has no P7 row
  ... P7 should be appended again" no longer holds. The regenerated inventory (13:39 UTC) has P7 at
  l.182, between P6 and P8 (seg005_1020.md round 9).

### Earlier findings addressed by these items

* seg053_11A0_r.md round 8 N1 (F8-04) and N2 (F8-05): addressed.
* seg057_11C0_p2_r.md round 8 N1 (F8-06): addressed.
* seg045_1160_p1.md round 8 R8-N1 (F8-08, F41): addressed.
* seg030_10E8_p2.md round 8 R8-N1 (F8-08, F72): addressed.
* round8-R8A.md N1, N4 and N5: addressed.
* round8-R8A.md N2 and N3: addressed, with the wording notes R9B-N1 and R9B-N2.
* round3-findings-sites.md N3 (F8-07/07a): addressed; see `seg064_11F8_r.md` and
  `seg007_1030_p1.md` round 9.

### Not checked

* Run-time behaviour, harness records and test results: no build or run, by the brief. The
  orchestrator runs them.
* MoveCivUnits' stack depths 3108..3655 (F8-04): taken from seg053_11A0_r.md round 8 N1.
* Whether `build.cmd` stops when `translate.py` exits 1 (F8-10).
* An exhaustive search for `early_seg_push` argument shapes (R9B-N2).
* In-game terrain changes at square (0,0) (F8-06); F66 leaves them open.
* Whether a selection set for an earlier MenuZ can still be pending (F41 leaves it open).
* The test code's correctness beyond the record match (F8-12): R9A's scope.

### Verdicts

Items without a unit; T and R count findings open after this round, N this round's notes.

| Function | Address | Verdict | T | R | N |
|---|---|---|---|---|---|
| F8-04 StartCivilWar `cityIndex` row (DESIGN 3.4) | 11A0:066D | PASS | 0 | 0 | 0 |
| F8-05 FIDELITY F58 | 11A0:066D | PASS | 0 | 0 | 0 |
| F8-06 FIDELITY F66, G67 2270 text | 11C0:2270 | PASS | 0 | 0 | 0 |
| F8-08 FIDELITY F41 | 1160:1CB6 | PASS | 0 | 0 | 0 |
| F8-09 `early_seg_push` history (DESIGN 3.4) | translator | PASS | 0 | 0 | 0 |
| F8-10 frame branches / `early_seg_push` scope (DESIGN 3.2, 3.4) | translator | PASS | 0 | 0 | 2 |
| F8-11 frame-object coverage (DESIGN 3.2) | translator | PASS | 0 | 0 | 0 |
| F8-12 test_acc boundary cases | tests/test_acc.c | PASS | 0 | 0 | 0 |
| round8-fixes.md closing remark (P7) | 1028:119F | PASS | 0 | 0 | 1 |

### Deviations from the brief's rules

None. Shell use in this round:
* `C:/Python314/python -B` ran only `claude/tools/showfunc.py` and `claude/port/gen/translate.py
  --show`, with output redirected to `R9B_` files in the scratch `v9` directory;
* `mkdir -p` of that directory;
* `wc -l` and `grep` on those scratch files only;
* one `echo` that touched no file.

Project files were read only with the Read and Grep tools. Only the five report files named above
were edited (Edit) or created (Write).

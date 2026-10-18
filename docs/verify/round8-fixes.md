# Round 8 fixes (F8)

Applied by the orchestrator on 2026-10-09 (by hand, no fixer agent) from the round-8 reports
(`docs/verify/round8-R8A.md`, `round8-R8E.md` and the "## Round 8 (2026-10-09)" sections of the unit
reports). Round 8 verified the frame-object checks (`acc_fx1`, 439 sites in 80 objects), the
early segment pushes and every F7 item. One TRANSLATOR finding (record): seg005_1020 R8-T1. All
other items are notes. The generated code changes only in comments (and so in the OOB allowlist);
round 9 verifies them.

| Id | Source | Change |
|---|---|---|
| F8-01 | verify/seg005_1020.md round 8 R8-T1 | `gen/annot.py` 1028:0A93: `/* OOB: findings C13 */` at 1028:0E2D (`labelRemap[label]`, marker 0E0F); FIDELITY F72 |
| F8-02 | same, "Related" | `/* OOB: findings C13 */` at 1028:0BF8 (with the existing BUG H39) and 1028:0CA9 (`g_bodySizes[kind][label]`, INDEX2) |
| F8-03 | verify/seg005_1020.md round 8 R8-N1 | 1028:0B42 `BUG: findings H39` → `OOB: findings H39` (`terrainHistogram[-1]`, marker 0B0D); FIDELITY F73 |
| F8-04 | verify/seg053_11A0_r.md round 8 N1 | DESIGN.md 3.4 StartCivilWar row: 0FC9..0FDD writes the port's rectangle; MoveCivUnits' calls 3108..3655 stay above the word |
| F8-05 | verify/seg053_11A0_r.md round 8 N2 | FIDELITY F58: the hang holds for every stale record whose size byte is 0 |
| F8-06 | verify/seg057_11C0_p2_r.md round 8 N1 | FIDELITY F66 and the G67 2270 MANUAL text: a never-used slot cannot reach 2270 on a generated map; the entry covers reused slots |
| F8-07 | verify/round3-findings-sites.md N3 (orchestrator decision 13:13) | EXCLUDE ("L14", "1208:08C2") and ("L14", "1030:56F7"): context, not the defect |
| F8-08 | verify/seg030_10E8_p2.md round 8 R8-N1; verify/seg045_1160_p1.md round 8 R8-N1 | FIDELITY F72 (body ids 1..15 hold while at most 63 labels are live) and F41 (MenuZ's selection stays 0 on the empty menu: `targetCivs[0]`) |
| F8-09 | verify/round8-R8A.md N1 | DESIGN.md 3.4: the early segment push changed the generated code after round 7 |
| F8-10 | verify/round8-R8A.md N2, N3 | DESIGN.md 3.2 / 3.4: the frame branches skip `emit_value_pushes` (a lost push fails generation); the scope of `early_seg_push` |
| F8-11 | verify/round8-R8A.md N4 | DESIGN.md 3.2: pointer arithmetic on a frame object is not checked; width 0 admits index n |
| F8-12 | verify/round8-R8A.md N5 | `tests/test_acc.c`: index n with a width, n + 1 with width 0, a member array at an offset, `local[i].member` (28 checks) |
| F8-13 | verify/seg005_1020.md round 8 R8-N2 | port P7: `/* OOB: port P7 */` at 1028:119F (`terrainWeights[-1]`, marker 1195); inventory hand section; FIDELITY F73 |
| F8-14 | verify/seg019_1090_r.md round 8 R8-N1 | MANUAL ("H29", "OOB", "1098:0087") and ("H29", "OOB", "1098:006F"): `pstr[len]` with a Pascal length >= 0x80, in the loop condition (first evaluation under marker 0073, later ones under the body's 006F); DESIGN.md 3.2 states the loop-condition rule |
| F8-15 | verify/round8-R8D.md G-1 (TRANSLATOR, generic) | `core/acc.h` `acc_ix3` (each of the three indexes against its dimension, the last as `acc_ix1` does, then the extent; the address as `va_ix(va_ix2(...), k, s3, 0)`); `VM_OOB_INDEX3` (`platform/w16/vm.h`); `gen/translate.py` `lval_index` three-index global branch, evaluating k, j, i as the former form did. The 18 accesses in seg015_1070_p1 (2), seg015_1070_p1_r (1), seg015_1070_p2_r (6), seg030_10E8_p3_r (1), seg041_1140_r2 (7) and seg044_1158 (1) map back to the round-8 text exactly (scratch `check_ix3.py`: 0 other lines); DESIGN.md 3.2; `test_acc` (address of the last byte; third index recorded; third index and extent) |
| F8-07a | verify/round3-findings-sites.md N3 | also EXCLUDE ("L14", "1208:08C7"), ScrollMapVertical's jump target: with 08C2 excluded the comment moved to 08C7 |
| F8-16 | verify/seg047_1170_p2.md round 8 N1 | FIDELITY F70 and inventory P6: the address (BP - 0xE6 + 2*index) mod 0x10000 leaves `items` for every index except 0x0000..0x0048 and 0x8000..0x8048, which wrap back to `items[index & 0x7FFF]` (whether Windows assigns segment 1030 such a selector: not checked) |
| F8-17 | verify/seg047_1170_p2.md round 8 N2 | DESIGN.md 3.4 187C row: ProcessCity 6A43/6C2F named as untraced turn-loop calls ([L] 6869 mode 0 only; 69DD..69F8 / 6BE7 AI owner only; AL stored unchecked at 6A55/6C41), separate from the city-screen calls 599D/5D89; FIDELITY F70 names them among the untraced callers |
| F8-18 | verify/seg047_1170_p2.md round 8 N3 | port P8: [L] 0E53..0E86 `buildersOnContinent[production]++` (28 words, production >= 0, no upper bound); a production byte of 99 (GR_DialogOpen failure 0651..065D; stored unchecked at 1030:5D9B, 1040:0597, 1078:4D92) increments bp-0x58 = `items[71]`, outside its object. `/* OOB: port P8 */` keyed to 0E86 in annot "1170:05CA" (`--show`: lands under marker 0E53 as `/* OOB: port P8 */  /* 1170:0E86 */`; the only change to the unit's text); inventory hand section P8; FIDELITY F74 (latent) |
| F8-19 | verify/seg044_1158_r.md round 8 N1 | round7-fixes.md "Later corrections (round 8)": of the nine other DrawPalaceSectionPiece calls seven pass `si`, 0DF7 and 0E45 the neighbouring end sections (si-1, si+1); the conclusion holds. FIDELITY, DESIGN and annot do not repeat the sentence |
| F8-20 | verify/seg044_1158.md round 8 N2 | FIDELITY F65 outcomes: a sprite word of 0 ('No Tile Data!', DrawTileToPortPixels 11A8:15F4) and a word that is not a handle (passed to GlobalLock unchecked, 11A8:161A; host behaviour not checked) |
| F8-21 | verify/round8-R8D.md N1 | FIDELITY F55 and the DESIGN.md 3.4 1495 row: the GetFreeSpace/GetFreeSystemResources frame can be the last writer; it is when it reaches the word (depth unknown, F3), otherwise the earlier ported writers remain |
| F8-22 | verify/round8-R8D.md N2, N3 | DESIGN.md 3.4 probe figures from `build/harness/game/uninit-report.txt` (the S2-S5 run): 443F 500 hits, 88 stale (38/26/12/11/1); 0F57 23 hits, all stale; the old figures kept as "an earlier run" |
| F8-23 | verify/round8-R8D.md N4 | round7-fixes.md "Later corrections (round 8)": the round6-fixes.md round-7 sentence on column 79 / row 49 holds on random worlds only (EARTH and save files not checked). FIDELITY and DESIGN do not state it |
| F8-24 | verify/round8-R8D.md N5 | DESIGN.md 3.4 bullet "Ported last writers kept as C variables": class (b) through an API frame on other paths (1495, 443F) or on the same path (13BF, where `squareY` is the last writer only where the API frames do not reach the word) |

Skipped in the F8-16..F8-24 pass: round8-R8D.md G-1 (already F8-15) and seg044_1158.md round 8 N1 (its
DrawPalaceSectionPiece instance, no effect; covered by F8-15); R8D's remark on the cost of keeping
the locals as C variables (no finding); the "Not checked" note of seg047_1170_p2.md round 8 on
`uninit-report.txt` printing class a for cc187C (a report regeneration, not a record; the current
file still prints class a for cc187C and sc066D). The inventory hand section has no P7 row,
although F8-13 and FIDELITY F73 cite one; P8 follows P6 there, and P7 should be appended again. (Orchestrator, 13:39: done when the inventory was regenerated; P7 stands between P6 and P8. The probe report was regenerated at 13:48 and prints class (b) for both sites; verify/round9-R9B.md N3.)

## Round-9 record items (F9, wording only; applied by the orchestrator on 2026-10-09)

| Id | Source | Change |
|---|---|---|
| F9-01 | verify/seg047_1170_p2.md round 9 N1 | FIDELITY F74 and inventory P8: a human civ's Auto Production also reaches the GR_DialogOpen path (1170:18A2/18A9 → 18BE → 065D) |
| F9-02 | verify/seg047_1170_p2.md round 9 N2 | FIDELITY F74 and inventory P8: a stored 99 also indexes `g_unitsInProduction[owner][99]` (ProcessCity 1030:5DD8 under marker 5D7E, the decrement under 5D28; ReselectCityProduction 1078:4DC7 and 4D79) and every later reader of the city's production; not listed: a scenario that reaches the dialog-failure path must triage them (a partial allowlist would not let such a run pass) |
| F9-03 | round9-R9C.md (F65) | FIDELITY F65: a never-loaded section's sprite word is 0 ('No Tile Data!'); only a section loaded earlier and since freed leaves a stale handle for GlobalLock |
| F9-04 | round9-R9C.md (443F row) | DESIGN.md 3.4 443F row: "with that API above" given its antecedent |
| F9-05 | verify/round9-R9A.md NOTE (acc.h header) | `core/acc.h` header: the strides and counts include GS3_/GN3_ |
| F9-06 | verify/seg044_1158.md round 9 R9-N1 | inventory P5: the 0E45 call can pass the centre section 4 with half 1 (piece type -1): INDEX3/EXTENT at marker 1445, already listed |

## Round-9 fixes (F10; applied by the orchestrator on 2026-10-09, verified in round 10)

| Id | Source | Change |
|---|---|---|
| F10-01 | verify/seg005_1020.md round 9 R9-T1 (TRANSLATOR) | `gen/annot.py` "1028:0A93": the scalar locals bp-0x18..bp-0x4 (`terrain` .. `newLabel`) stack-resident (5.2 item 2(e)), so labels 80..90 read their words as the original does; `ah` for 1028:0E3C (the colour byte's high byte, newId's word); FIDELITY F72 states the slot classes 64..79, 80..90, 91..94, 95 and up |
| F10-02 | verify/seg005_1020.md round 9 R9-N1 | FIDELITY F72: ComputeCitySiteValues 1028:1277 (`g_bodyCitySiteCounts[id]++`, marker 125C) among the unlisted readers of an id >= 16 |
| F10-03 | verify/seg005_1020.md round 9 R9-N2 | FIDELITY F73, inventory P7, annot: the condition "HasSpecialResource returns 0" (1191) and the outcomes (the caller's SI, a stack offset, added to `squareValue`; H39's saved-SI increment dropped) |
| F10-04 | verify/round9-R9B.md (loop-condition rule) | DESIGN.md 3.2: hits in a re-evaluated condition or a `for` step are charged to the last marker executed; listed at every such marker |
| F10-05 | verify/round9-R9B.md (F8-10 wording) | DESIGN.md 3.2 names `lval_member`'s `local[i]` node; 3.4 states R8A N3's points and its bounded search instead of "no such site exists" |
| F10-06 | verify/seg019_1090_r.md round 9 (H29) | MANUAL H29 at 1098:0091 and 009F (the `str[len]` stores, BUG comments: pointer stores, not object-checked) |
| F10-07 | verify/round9-R9A.md G-2 (TRANSLATOR, generic) | `acc_ix1m` / `acc_pm` emitted for member arrays (40 and 52 accesses in 22 units; scratch `check_g2.py`: every call maps back to the round-9 text, 0 other lines), both width-aware (an address admits index n), `F_AX` passes the element width; DESIGN.md 3.2; `test_acc` (two checks) |
| F10-08 | verify/round9-R9B.md N3 | the fixer's paragraph above: P7 restored at 13:39 |

## Round-10 fixes (F11; fixer)

Applied by fixer F11 on 2026-10-09 (by hand, records and comments only; the generated code and the
port's behaviour do not change). Each item was checked against `showfunc.py` listings of 1028:0A93,
10F8:05DA, 1170:05CA, 1170:21B3, 1040:0000, 1078:4D28, 1030:0000, 1158:08E7, 1158:140C and
1158:1277 (scratch only).

| Id | Source | Change |
|---|---|---|
| F11-a | verify/seg005_1020.md round 10 R10-N1 | FIDELITY F72 and the annot "1028:0A93" comment: labels 80..90 read the function's own last stores only after each local's first store in the call; before it (`newId` at the first projected cell, only store 0E30; `relabelY`/`relabelX` before the first merge, 0BB9/0BC1; `upLabel` before the first square of the current kind on row 1 or later, 0B99; `dx` likewise, 0B7C, unless the ranking's 0D79 stored it before the projection) the word is from before the call (not traced, as for labels 95 and up). F72's "since round 9" now reads "since the round-9 fix F10-01" |
| F11-b | verify/seg019_1090_r.md round 10 R10-N1 | DESIGN.md 3.2: C16 RLLEncode's unchecked reads are named as the loop-condition reads at 069C and 0781, evaluated first under markers 069C/076C and then under the body markers 068B/075B |
| F11-c | round10-R10C.md N1 (i)-(v), F9-01 | FIDELITY F74, inventory P8 and the annot "1170:05CA" comment: two causes of the return 99 (065D) for a civ in `g_humanCivsMask`: GR_DialogOpen failure on the dialog path (0651..065D), and Auto Production (status 0x10: 0601..0609 skip the dialog) with no domestic candidate (18A2) or a best domestic score above 500 (18A9), 18BE → 065D. The callers (verify/seg047_1170_p2.md round 9 N1): 5D89 dialog path only (5D3B clears Auto Production); 1040:0585 dialog path only, a civ in the mask other than `g_humanPlayer`; 1078:4D80 reaches `g_humanPlayer`'s city only through CompleteResearch on turn 0, either path. F74 adds that 4D80's other callers exclude only `g_humanPlayer` (listing: ProcessCity 1F21 → 2386), and that ProcessCity 6A43/6C2F serve only owners outside the mask (R10C F9-01). F74's latency names both causes; the decrements 5D79 (marker 5D28) and 4D79 run before the store and are listed among the later readers, the increments 5DD8/4DC7 as following the stores |
| F11-d | round10-R10C.md N2; verify/seg044_1158.md round 9 R9-N1 | FIDELITY F65: the 0DCF/0E1D guards bound the section index only; the 0E45 call can pass the centre section 4 with half 1 (`rightEndSection` 4 with si = 3: a stale word after section 8 is built through port P3's '`' key, or a loaded save with section 5 unbuilt), whose piece type is never written (1158:1397; reset 095C..0967), so 146B reads `g_palacePieceYOffsets[levelForY][style][-1]` (INDEX3, and EXTENT at 1350:0009 for level and style 0) under marker 1445; latency and refs updated. FIDELITY F48: `rightEndSection` (0DFD, 0E13, 0E3D) is stale when section 8 is built (the 0C9F..0CB7 scan assigns it at 0CA4 only below a built slot) |
| F11-e | round10-R10C.md N3 | `core/acc.h` header comment: the checked indexes are the first, second and third index of a global array and the member-array index (comment only). DESIGN.md 3.2: the layout macros include `GS3_`/`GN3_` (the two three-index globals) |

## Round-10 fixes (F11; orchestrator, 2026-10-09)

| Id | Source | Change |
|---|---|---|
| F11-01 | verify/seg014_1068_p2.md round 10 R10-T1 (TRANSLATOR) | MANUAL ("C9", "OOB", "1068:2612") and ("C9", "OOB", "1068:261F"): TextBoxDraw's `lineLength[SI]`/`lineOffset[SI]` for a text of more than 64 lines (the entries TextBoxSetup wrote past its tables, C9's 2215/2237), marker 2609 |
| F11-02 | verify/seg023_10B0_p1.md round 10 (NOTE) | CreateDissolveState: `gen/annot.py` "10B0:151B" writes both `BUG: findings H61` and `OOB: findings H61` at markers 15D3, 1610 and 163D (`order[]`/`rowPhase[]` past their members for a duration or height above 480; latent); the BUG comments now carry the marker address instead of the site addresses 15E9, 1600 and 1665 |
| F11-03 | verify/round10-R10A.md N1, N3, N4 | DESIGN.md 3.2 member-array sentence: width 0 for structure and row elements, `acc_pm` key sharing, the list of unchecked forms |
| F11-04 | verify/round10-R10A.md N5 | `tests/test_acc.c`: k = mn + 1 at width 0, `acc_ix1m`'s i = n, a row's column index |

## Round-11 fixes (F12; orchestrator, 2026-10-09)

Record wording only: no generated statement changes (the regeneration's diff is empty; the C9
reasons appear only in the generated inventory rows).

| Id | Source | Change |
|---|---|---|
| F12-01 | verify/seg014_1068_p2.md round 11 R11-N1 | inventory/out-of-range.md hand section: new port P9 (a text of more than 64 lines without C9's hang: TextBoxSetup's stores 2232/224F, TextBoxDraw's reads 2612/261F); the MANUAL C9 reasons at 2232, 224F, 2612, 261F cite P9 |
| F12-02 | verify/seg023_10B0_p1.md round 11 R11-N1, R11-N2 | `gen/annot.py`: the CreateDissolveState comment and entry moved above AdvanceMovie's comment; condition wording (the duration's low word or the height, negative or above 480) |
| F12-03 | verify/round11-R11A.md N1, N6; round10-R10A.md N3's last point | `core/acc.h` comments (width 0: an element that is a structure or an array, and G_IX; the member count is mn) and DESIGN.md 3.2 (an address of a scalar element gets its width; a one-past `&p->m[n]` would be recorded) |
| F12-04 | verify/round10-R10A.md N2 | DESIGN.md 3.2: the member-array forms do not pass the member node through `lval` either (an annotated body push on it would not be written; none exists) |
| F12-05 | verify/round11-R11A.md N2, N3 | FIDELITY F74, inventory P8, the annot "1170:05CA" comment: ReselectCityProduction's other paths (1F21 excludes `g_humanPlayer` only; 2DC5 and 1078:0D32 the whole mask); CaptureCity's store 1038:07D9 → 07EB (dialog path only) and its readers 0821 (marker 07C5) and 07A5 (marker 0774), unlisted like the others |
| F12-06 | verify/round11-R11A.md N4 | FIDELITY F48: the scan assigns `rightEndSection` while passing an unbuilt slot (F11-d's "below a built slot" is superseded) |
| F12-07 | verify/round11-R11A.md N5 | FIDELITY F65: the 0E45 case from a save needs sections 5..7 unbuilt and section 4 built |

## Round-12 fixes (F13; orchestrator, 2026-10-09)

Record wording only (comments and documents); no generated statement changes.

| Id | Source | Change |
|---|---|---|
| F13-01 | verify/round12-R12A.md N1 | inventory P9: what the overlapping stores do (lineOffset, text), TextBoxDraw's wrong offsets, the bare-CR example, where the tables leave the block |
| F13-02 | verify/round12-R12A.md N2 | the hand section's preamble: P9 carries `/* OOB: findings C9 */` |
| F13-03 | verify/round12-R12A.md N3 | `core/acc.h` acc_ix1 and acc_fx1 comments: width 0 when the accessed object (the element, or the member of `g[i].m` / `local[i].m`) is a structure or an array |
| F13-04 | verify/round12-R12A.md N5 | FIDELITY F74 and inventory P8: TakeAdvanceFromCiv 1038:0BA9, MoveCivUnits 11F0:28AB and CompleteResearch's AI path 22F9 exclude only `g_humanPlayer` |
| F13-05 | verify/round12-R12A.md N4 | DESIGN.md 3.2: the body-push rule stated generally, with the global-array branches |

## Phase-4 review-1 fixes (F14; orchestrator, 2026-10-09)

Fixes for `verify/phase4-review-1.md` (RV1, of P4-1 mouse routing, P4-2 non-client drawing and
F13). Code in `platform/w16/queue.c`, `queue.h` and `user_wnd.c`; tests in `test_queue`
(`test_mouse_review1`) and `test_user` (`test_raise_review1`). All three variants build and
pass, the harness gate passes and start-up g-41 equals g-40 (STATUS results, 17:31–17:39).
Not re-reviewed yet.

| Id | Source | Change |
|---|---|---|
| F14-01 | RV1 D1 | raise_top exposes what raising uncovers of each raised window and of its children (`expose_tree_rgn`: WM_NCPAINT, the synchronous erase, WM_PAINT later, as when a window is hidden); test |
| F14-02 | RV1 D2 | raising keeps the windows owned through chains of owners above the raised window, in their order (`owned_by`); test |
| F14-03 | RV1 D3 | a raw WM_MOUSEMOVE replaces a trailing move that came from raw input, routed or not, and is routed afresh (`queue.h` rule, `queue.c`); test |
| F14-04 | RV1 R1 | a point in a disabled top-level window goes to that window with HTERROR; HTERROR takes no part in double clicks; test |
| F14-05 | RV1 R2 | not modelled: HTTRANSPARENT, recorded in FIDELITY F75 (no procedure of the program returns it) |
| F14-06 | RV1 R3 | the routed entry is marked W16_MOUSE_ROUTING: a nested PeekMessage skips it, input posted meanwhile is kept, a hook that removes the entry faults; test |
| F14-07 | RV1 R4 | the double-click rectangle is half-open (offsets -2..1), recorded in DESIGN 5 and 10 and F75 as a choice of the edge |
| F14-08 | RV1 R5 | the pre-check admits a button down whose double-click numbers match the filter (`raw_admitted`); test |
| F14-09 | RV1 R6 | PeekMessage and DispatchMessage zero their message locals |
| F14-10 | RV1 N1 | class_brush's comment moved back to its function |
| F14-11 | RV1 N2 | records: WM_MOUSEACTIVATE only without the capture, the HTERROR check first, the client message number in the high word for non-client clicks too |
| F14-12 | RV1 N3 | "a disabled child passes the point to its parent" labelled **inferred** in both F75 and the header |
| F14-13 | RV1 N4 | DESIGN 10 "Double click" row: 4 x 4 centred, offsets -2..1 |
| F14-14 | RV1 N5 | `test_user`: HTMENU on a window with a menu bar |
| F14-15 | RV1 N6 | tests added: the eaten-message restart, raw-after-routed moves, MK_CONTROL, the serialised RAW/ROUTED flags (corrected by F15-12: no test serialises an entry while it is ROUTING), MA_ACTIVATEANDEAT, owner chains and children on raise, a disabled top-level window. Not added: the fault for a routed entry that leaves the queue, the WM_SETCURSOR parent chain, the per-window double-click reset with a CS_DBLCLKS class |
| F14-16 | RV1 N7 | `harness.c` comment rewrapped; `input.script` sends one raw `hwnd 0` move again (`at 20 move 300 300`); the gate's exit code stays 3 |
| F14-17 | RV1 N8 | resolved by F14-01: raising exposes the way hiding does |
| F14-18 | RV1 N9 | acknowledged, no change: two's-complement truncation on every target compiler, as elsewhere in the port |
| F14-19 | RV1 P2-R1 | the scroll bars' parts (separator lines included) are clipped to the bar's rectangle and the triangles to their boxes (corrected by F15-12; in a bar shorter than 30 pixels the two arrows still overlap each other). **Open:** the system-menu box's bar still assumes a box at least 8 pixels wide |
| F14-20 | RV1 P2-N1, P2-N2 | F26 and the `user_wnd.c` header: the thumb at the track's start for an empty or reversed range; a caption wider than its space is left-aligned and clipped |
| F14-21 | RV1 P2-N3 | menu_display: an '&' directly before the tab is no mnemonic |
| F14-22 | RV1 P2-N4 | acknowledged, no change (theoretical: 48 items of 63 wide characters) |
| F14-23 | RV1 P2-N5 | `user_menu.c` header and FEATURES.md line 65 brought up to date; F26's thumb formula names the track's start and its length separately |
| F14-24 | RV1 P2-N6 | **open:** no new drawing tests (SetScrollRange with redraw, hidden window, overlap clipping, WM_SETTEXT caption redraw, down/right triangles, reversed range). P4-4's test checks the down arrow's pressed and raised corner pixel only |
| F14-25 | RV1 F13-N1..N4 | inventory P9: `text` is 0x400 bytes; the hand section's heading is "## Sites found by the port"; P8 cites verify/round12-R12A.md N5; DESIGN 3.2 names `g[i]` of `g[i][j][k]` and `table` of `table.b[i]`, rewrapped |

## Phase-4 review-2 fixes (F15; orchestrator, 2026-10-09)

Fixes for `verify/phase4-review-2.md` (RV2, of P4-3 menu tracking, F14 and P4-4 scroll-bar
tracking), applied together with P4-5 (system commands). Code in `platform/w16/queue.c`,
`queue.h`, `user_wnd.c`, `user_menutrack.c`, `user_scrolltrack.c`, `user_syscmd.c` and
`w16_int.h`; tests in `test_queue` (`test_mouse_review2`) and `test_user` (`test_scroll_track`,
`test_bar_command`). Results: STATUS results row of start-up g-42. Not re-reviewed yet.

| Id | Source | Change |
|---|---|---|
| F15-01 | RV2 P44-D1 | DefWindowProc: WM_NCLBUTTONDBLCLK on HTVSCROLL / HTHSCROLL acts as WM_NCLBUTTONDOWN (a quick second click on an arrow scrolls again); F75/F77 and `user_wnd.c` header; test |
| F15-02 | RV2 P44-R1(a) | the scroll loop also ends, as at a release, when no message waits and the posted input's left button is up (its release taken by another PeekMessage) or the window lost the capture (`w16_wnd_track_lost`, `w16_queue_buttons`); the same for the P4-5 move/size and box loops; test (a filtered PeekMessage takes the client release) |
| F15-03 | RV2 P44-R1(b), P4-3 R2 | one system modal loop at a time (`w16_sys_loop_begin` / `_end`, reset with the window manager): a menu, scroll-bar, move/size or box loop asked for while another runs does not start; the menu loop ends when its window loses the capture; test (Alt during a held arrow: SC_KEYMENU without WM_INITMENU). Not changed: a dialog opened by a procedure during a loop still runs under the open popups (latent, no game procedure does) |
| F15-04 | RV2 P4-3 R1 | Return on a command item of the menu bar, and the release of a click on it, choose it (`act`); header; test (MENU 128's Edit made a command item with ModifyMenu) |
| F15-05 | RV2 F14-R1 | the entry being routed carries its nesting level (`hit` while ROUTING) and the routed message goes back into the entry of its own level; after routing the search starts again from the front, so a message posted during the hook comes first; `queue.c`/`queue.h` rule; test |
| F15-06 | RV2 F14-R2 | expose_tree_rgn and expose read the next sibling before the recursive call and stop when the parent or the next sibling is gone (no NULL dereference when a procedure destroys a window during WM_NCPAINT / WM_ERASEBKGND). Not tested |
| F15-07 | RV2 P44-N1 | records: the repeat delays are measured with the tick count (54.925 ms steps: the first repeat 7 or 8 ticks after the click, then every 2 ticks); header, DESIGN 5, F77 |
| F15-08 | RV2 P44-N2 | the dragged thumb stays where it is dragged while SB_THUMBPOSITION is sent and is redrawn at the bar's position after it (no snap back before the program's SetScrollPos); F77 |
| F15-09 | RV2 P44-N3 | records: the range read when the drag started and no pressed drawing of a held track are choices (header, F77) |
| F15-10 | RV2 N1, N2 | `user_menutrack.c` header: the bar's first mnemonic match acts (a command on the bar is chosen), the middle button is ignored, a release outside also ends a keyboard-opened menu, the posted WM_COMMAND reaches an unfiltered PeekMessage, a full queue drops it (choice) |
| F15-11 | RV2 N3, N4 | acknowledged, no change: harness mouse lines addressed to a window pass client coordinates (test path only; P4-8 revisits the harness's mouse lines); the `w16_int.h` "(tests; ...)" wording of `w16_menu_item_text` / `_flags` stays (they also serve the window manager) |
| F15-12 | RV2 F14-N1, F14-N2 | F14-15 and F14-19 corrected above (ROUTING not serialised by a test; parts clipped to the bar's rectangle) |
| F15-13 | RV2 N5, F14-N3, P44-N4 | **open:** the remaining test gaps listed by RV2 (F10 entry, Left/Right with a popup open, Home/End, cascades, WM_QUIT and window destruction in the loops, the page repeat stopping at the thumb, the thumb's drawing and clamping, routed-move coalescing) |

## Phase-4 review-3 fixes (F16; orchestrator, 2026-10-09)

Fixes for `verify/phase4-review-3.md` (RV3, of P4-5 system commands, F15 and P4-6 MessageBox).
Code in `platform/w16/user_wnd.c`, `user_msgbox.c` and `user_misc.c`; tests in `test_user`
(`test_review3`). Checked build and `test_user` pass (241 checks); all variants with the next
start-up run (STATUS). Not re-reviewed yet.

| Id | Source | Change |
|---|---|---|
| F16-01 | RV3 P45-D1 | activate: an activated minimized window takes the focus away from any other window (an active icon receives system keys, as recorded); test (a click on an icon while another window has the focus) |
| F16-02 | RV3 P46-D1 | MessageBox: the desktop window as hwndParent is no owner; MB_SYSTEMMODAL / MB_TASKMODAL disable every enabled visible top-level window while the box is open (the game's `_ErrorMessage` passes GetDesktopWindow and 0x1010); without an earlier focus the earlier active window (not an icon) is activated again; header; test |
| F16-03 | RV3 P45-R1 | set_rect, hide_sequence and invalidate_tree no longer touch a window destroyed during their sends (NULL checks; invalidate_tree reads the next sibling first). destroy_tree already reads the next sibling first and its windows live until free_tree (no change) |
| F16-04 | RV3 P46-R1 | MessageBox releases a capture before the box opens (choice, as Windows' WM_CANCELMODE). A running system loop is not cancelled (latent: no game path opens a box from inside one) |
| F16-05 | RV3 P4-5 notes | `user_misc.c` accelerator note: the minimized map still receives its commands; DESIGN Q12's example corrected (the status window's MoveWindow at 1218:050A comes before its window data). **Open:** the hidden menu bar of a minimized window reachable from the keyboard, the box loop's command after a lost capture, the keyboard move's unbounded offset, the map drawing over its own icon, the icon title after WM_SETTEXT, RV3's test gaps |
| F16-06 | RV3 P4-6 notes | header: MessageBeep's argument stated as the code passes it. **Open:** more than 24 lines, a trailing line break, the allocation leaked by a fault inside the box, Close/Alt+F4 on YESNO boxes, Alt+mnemonics, RV3's test gaps |
| F16-07 | RV3 F15 notes | acknowledged: F15-06's iteration fix now also covers invalidate_tree (F16-03); the "release taken elsewhere" ending relies on the back end posting every release (not yet checked for the win64 back end; open) |

## Phase-4 review-4 fixes (F17; orchestrator, 2026-10-09 and 2026-10-10)

Fixes for `verify/phase4-review-4.md` (RV4, of F16 and P4-7 list boxes, statics and DIBs). Code in
`platform/w16/user_listbox.c`, `user_wnd.c` and `gdi_obj.c` (2026-10-09, 19:35..20:30); tests in
`test_user`; checked build first, all three variants with the P4-8 run of 2026-10-10 (STATUS).
Records F17-06..08 written 2026-10-10. Not re-reviewed yet.

| Id | Source | Change |
|---|---|---|
| F17-01 | RV4 P47-D1 | `item_at`: the column under a point is limited by the drawn columns, a partly visible last column included (`(cw + colw - 1) / colw`), so a click or drag in the Civilopedia's third column (157 of 159 pixels visible) selects its own item. `visible`, `ensure_visible`, the page (PgUp / PgDn) and the horizontal bar still count the wholly visible columns (choice, F80): Right into the partial column scrolls by a column. Header; test (a click on the partly visible fourth column of a 198-pixel client) |
| F17-02 | RV4 P47-R1 | lifetime: `layout` returns at once, without touching the control's state, when a send of its SetScrollRange / SetScrollPos destroyed the control (`lb_of(hwnd) != b`); LB_DELETESTRING keeps the count in a local before `layout`; header "Lifetime"; test (the parent destroys the list in WM_CTLCOLOR during LB_DELETESTRING) |
| F17-03 | RV4 F16-R1 | `destroy_tree`: after WM_DESTROY and after each child, the window is looked up again (return when it is gone) and the next child not yet being destroyed is found again, so a handler that destroys a sibling or an ancestor leaves no freed handle in use and a window being destroyed is not destroyed twice. F16-03's "no change" for destroy_tree was wrong (it rested on reading the next sibling first). Test (a WM_DESTROY handler destroys the next sibling) |
| F17-04 | RV4 P47-N1 | header wording aligned with the code: PgUp / PgDn of a one-column list move by the rows less one; LB_INSERTSTRING below -1 or past the end returns LB_ERR (the code now does so); the mouse rule as in F17-01 |
| F17-05 | RV4 P47-N2 | CreateDIBitmap: a height outside -32767..32767 is rejected before any negation (no INT32_MIN overflow); biPlanes other than 1 faults; the header records the top-down rows of a negative biHeight and the entry 0 for pixel values past biClrUsed as choices. The 1 GiB host request of a 32767 x 32767 bitmap stays (as CreateBitmap; unreachable in the game) |
| F17-06 | RV4 F16-N1 | records: DESIGN 5 "MessageBox" (the desktop or no window as no owner; MB_SYSTEMMODAL / MB_TASKMODAL disable every enabled visible top-level window of the program, at most 32; the capture release; the earlier active window, not an icon, when the earlier focus is gone; the tests); FIDELITY F79 (task-modal semantics, the capture release, the 32-window limit). In the code headers (2026-10-10, after the P4-8 builds): `user_msgbox.c`'s last sentence (the icon exception) and the limit; `user_misc.c`'s cross-reference for the minimized map's accelerators corrected from F78 to F76. STATUS: the progress row of 19:30 says RV3 left "three notes open"; F16-05..07 leave about thirteen RV3 notes open (the row is kept as written; this is the correction) |
| F17-07 | RV4 F16-N2 | SetFocus into a minimized top-level window decided and recorded as a choice (`user_wnd.c` header, FIDELITY F78): the window is activated (the icon branch clears the focus, also one that a WM_ACTIVATE handler set) and then takes the focus, so keys reach it as WM_KEYDOWN; **(inference)** Windows 3.1 allows SetFocus to an iconic window. No game effect: no game procedure handles WM_ACTIVATE and the game's five SetFocus calls never target a minimized window |
| F17-08 | RV4 P47-R2, P47-N3, P47-N4, F16-N3 | **Open:** P47-R2 (the game's list dialogs repaint their client snapshot over the list's scroll bars and border until a scroll; whether Windows 3.1 showed the same is not known) goes to the user with the phase-7 visual checks and is listed in F80; P47-N3's int16 item rectangles beyond about 2,047 rows are noted beside LB_MAX (the game asks for item 0 only); the test gaps of P47-N4 and F16-N3 stay open for P4-9 |

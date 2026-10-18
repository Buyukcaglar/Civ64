# Round 12 (2026-10-09): fix — R12A review of F12

## Round 12 (2026-10-09): fix

Verifier R12A. The items are the F12 records in `docs/verify/round8-fixes.md` (l.93-106,
"Round-11 fixes (F12; orchestrator, 2026-10-09)"), F12-01..F12-07, all of kind "fix". They are
checked against the listing and the notes they address:
* `round11-R11A.md` N1..N6;
* the "## Round 11" sections of `seg014_1068_p2.md` (R11-N1) and `seg023_10B0_p1.md` (R11-N1,
  R11-N2);
* `round10-R10A.md` N2 and N3.

Where the results are reported:
* F12-01 (TextBoxSetup/TextBoxDraw, P9) and F12-02 (CreateDissolveState): short "## Round 12"
  sections in `verify/seg014_1068_p2.md` and `verify/seg023_10B0_p1.md`; the details and the
  findings are here;
* everything else: this file.

Inputs: the seven diffs and old copies in `build/verify-round12/` (`diff/*.diff`, `old/*`); the
current `gen/findings_sites.py`, `gen/annot.py`, `gen/inventory.py`, `gen/translate.py`,
`core/acc.h`, `docs/DESIGN.md`, `docs/FIDELITY.md`, `docs/inventory/out-of-range.md`,
`build/cache/oob-allowlist.txt`; generated `core/seg014_1068_p2.c`, `seg023_10B0_p1.c`,
`seg008_1038.c`, `seg047_1170_p2.c`, `seg017_1080.c`, `seg026_10C8.c`, `seg011_1050_t.c`;
findings C9 (`claude/docs/findings.md` l.686-693); the listings `showfunc.py` 1068:2072, 1068:258F,
10B0:151B, 1158:08E7, 1038:0000 (scratch `v12/R12A_*.txt`) and `claude/src/asm` seg007_1030,
seg008_1038, seg016_1078, seg030_10E8, seg047_1170, seg063_11F0 (read-only).

Nothing was built, compiled, tested or run. Method labels follow the brief; reading `core/acc.h` and
`gen/translate.py` is labelled [D], as in round 11.

### Items

| Item | Record | Result | Method |
|---|---|---|---|
| F12-01 | inventory P9; MANUAL C9 reasons 2232/224F/2612/261F | R11-N1 resolved; two NOTEs (R12A-N1, N2) | [L][G][A][F][C] |
| F12-02 | annot "10B0:151B" position and condition wording | R11-N1, R11-N2 resolved; remarks only | [L][G][A] |
| F12-03 | `core/acc.h` width-0/count comments; DESIGN 3.2 width-0 sentence | R11A-N1, N6, R10A N3 resolved; NOTE R12A-N3 | [D][G] |
| F12-04 | DESIGN 3.2 body-push sentence | R10A N2 resolved; NOTE R12A-N4 (latent) | [D] |
| F12-05 | FIDELITY F74, inventory P8, annot "1170:05CA" comment | R11A-N2, N3 resolved; NOTE R12A-N5 | [L][S][G][F][A] |
| F12-06 | FIDELITY F48 | R11A-N4 resolved | [L] |
| F12-07 | FIDELITY F65 | R11A-N5 resolved; remark | [L][S] |

### F12-01: inventory P9 and the MANUAL C9 reasons (TextBoxSetup 1068:2072, TextBoxDraw 1068:258F)

**What changed** [A][F]. `gen/findings_sites.py` l.254-256 and l.507-511 change only the fourth
field (the source text) of the four C9 MANUAL entries. `load()` ignores that field (`_src`,
l.578 and l.618); only `inventory.generator_oob_sites` (inventory.py l.433-436) writes it, so the
generated comments are unchanged and only the inventory rows l.55-58 change. The hand section adds
P9 (l.189).

**P9 against the listing** [L][G][F].

| P9 claim | Listing / generated C | Result |
|---|---|---|
| store 2232 `lineOffset[lineIndex]`, marker 2215 | 2232 `mov es:[bx+0x9a],dx`, bx = lpBox + 2·DI (2229..2230); `seg014_1068_p2.c` l.231-238 | correct |
| store 224F `lineLength[lineIndex]`, marker 2237 | 224F `mov es:[bx+0x1a],ax` (2246..224D); l.239-246 | correct |
| `lineIndex` not checked, 2253 | 2130 `xor di,di`; 2253 `inc di`; 2257 stores it as lineCount; no compare with 64 | correct |
| reads 2612 `lineLength[SI]`, 261F `lineOffset[SI]`, marker 2609 | 2612 `mov di,es:[bx+0x1a]`, 261F `mov ax,es:[bx+0x9a]`; loop 2604/26C7..26CE while SI < lineCount; l.345-349 | correct |
| reads for SI >= 64 | lineCount = number of lines (2253/2257) | correct |
| statements carry `/* OOB: findings C9 */` | l.232, 240, 347; allowlist l.64-66 (2215, 2237, 2609 C9) | correct |
| C9 describes only the hang | findings.md l.686-693 | correct |

**Condition** [L]. The hang needs the first word of a line, measured with its trailing space
(2187..21C1: the extent of lineStart..cursor), to reach the box width: then lastBreak stays at the
line start (21E6..21EF, 2215..2257) and the next line restarts on the same word. A word that
reaches the width anywhere becomes the first word of a later line, so "no word reaches the box
width" is the non-hanging case. Remark, not counted: "(no word reaches the box width)" omits C9's
"measured with its trailing space".

**Placement** [G]. The four sites lie in the statements governed by 2215, 2237 and 2609; the
2612/261F reads are charged to 2609 on every iteration (the loop condition reads only the scalar
lineCount). Unchanged since round 11.

seg014_1068_p2.md round 11 R11-N1: **resolved** (P9 describes the case; the reasons cite it).

New: R12A-N1 (P9 gives no outcome) and R12A-N2 (the hand section's preamble), below.

### F12-02: annot "10B0:151B" (CreateDissolveState)

* **Position** [A]. The comment and entry (annot.py l.317-327) now stand after DrawTilesToPort's
  entry (l.311-316). AdvanceMovie's comment (l.328-334) directly precedes its entry "10B0:0461"
  (l.335). Each key occurs once (Grep: "10B0:151B" only at l.323, "10B0:0461" only at l.335).
  seg023 round 11 R11-N2: **resolved**.
* **No output change** [A][G]. `ANNOT` is read by key (translate.py l.5160, 5191, 5207) and by
  `inventory.generator_oob_sites`, whose rows are sorted by finding and site (inventory.py
  l.437-443), so the dict order is not visible. `translate.py --show 10B0:151B` (scratch
  `R12A_show_10B0_151B.c`, 98 lines, no FINDING line) matches `core/seg023_10B0_p1.c` l.1460-1557
  line for line (visual comparison), including the BUG/OOB pairs at l.1516-1517, 1529-1530 and
  1550-1551.
* **Condition** [L]. 15D3..15DC: DI = SI = the word at +8, the duration's low word. Fill loop
  15E0..15F3 (`ax = si; dec si; or ax,ax; jne`) stores `order[d-1]` .. `order[0]`: a low word above
  480 starts at index >= 480, a negative one at d-1 < 0 (for -32768 at 32767) and runs through the
  16-bit values. Row loop 15F7..1618 stores `rowPhase[h-1]` .. `rowPhase[0]` the same way. The swap
  loop 1621..167F (`jl`) runs only for d > 0, with indexes 0..d-1. The wording "for a duration
  whose low word (the only word used) or a height that is negative or above 480" covers these
  cases. seg023 round 11 R11-N1: **resolved**.
* Remarks, not counted: the clause is elliptical ("whose low word ... or a height that is"); and for
  a negative start the first accesses lie before the member (`order[d-1]` in `rowPhase` or the
  header, `rowPhase[h-1]` in the header) before the loop wraps past it, so "outside" would be more
  exact than "past the members".

### F12-03: `core/acc.h` comments and DESIGN.md 3.2's width-0 sentence

Checked against `w()` (translate.py l.3823-3827: `0u` only for a structure or an array), the
callers of each accessor, `rv_Unary`'s `&` (l.4278-4281: `addr_of` → `lval`) and `G_IX`
(acc.h l.233, width `0u`).

| Comment (acc.h) | Code | Callers and width | Result |
|---|---|---|---|
| `acc_ix1` l.95-97: width 0 admits i = n: `G_IX` and an element that is a structure or an array; an address of a scalar element gets its width | l.103 bound n + 1 at width 0 | `G_IX` 0; `lval_index` l.3733 `w(elem)`; also `lval_member` l.3857 `w(f.ctype)` | right for `G_IX`/`lval_index`; R12A-N3 for `lval_member` |
| `acc_ix3` l.130-132: width 0 admits n3 | l.141 | `lval_index` l.3752-3754 `w(elem)` | correct |
| `acc_ix1m` l.153-155: k (count mn) of element i (count n); width 0 (structure or array element) admits k = mn | l.162 (i against n at every width), l.163 | only `lval_index` l.3784-3786 `w(elem)`; `GF_RDX/GF_WRX` pass `ACC_W(FE_)` | correct |
| `acc_pm` l.174-176: count mn; width 0 (structure or array element) admits k = mn | l.182 | `lval_index` l.3774-3776, 3788-3789, 3791-3792 `w(elem)`; `F_AX` passes `FS_` (l.273) | correct |
| `acc_fx1` l.209-212: width 0 (structure or array element) admits i = n | l.218 | `lval_index` l.3759 `w(elem)`; `lval_member` l.3867-3868 `w(f.ctype)` | right for `lval_index`; R12A-N3 for `lval_member` |

DESIGN.md l.276-281 [D]: "Both admit index n for width 0, which the translator passes for an
element that is a structure or an array (a row)" is exact for `acc_ix1m`/`acc_pm` (both are called
only from `lval_index`, with the member element's `w()`). Index n of `p->m[n].f` (the
`lval_member` of `.f` takes `addr_of(p->m[n])`, width 0, then `fp_add`) and of a row index (the
recursive `lval_index(m[j])` with an array element) is admitted. An address of a scalar element
(`&p->m[n]` → `addr_of` → `lval_index` → `acc_pm(..., size)`) is recorded. Correct, and "whether
generated code forms one was not checked" is stated.

R11A-N1: **resolved** in DESIGN and in the `acc_ix1m`/`acc_pm` comments. R11A-N6 ("count n"):
**resolved** (both now say mn; `acc_ix1m` names n as the outer count). R10A N3's last point ("for
an address (width 0)"): **resolved**; the remaining "address" wording (DESIGN l.267-268 `G_IX`,
l.304 "the address of a structure element, `&pts[2]`"; acc.h l.232) is correct.

### F12-04: DESIGN.md 3.2's body-push sentence (l.305-310)

[D] `emit_value_pushes` (l.3629) is called only by `lval` (l.3681) and `rv` (l.3893). In
`lval_index`'s member-array forms:
* `p->m[k]` (l.3769-3776): `rv(m.base)`, the member node `m` is not passed;
* `g[i].m[k]` (l.3777-3786): `rv(b.index)`; neither `m` nor `b` (= `g[i]`) is passed;
* `x.m[k]` (l.3787-3789): `addr_of(b)` passes `x`, not `m`;
* the row form (l.3790-3792): `addr_of(m[j])` passes the `m[j]` node, whose member node is then
  handled by one of the forms above.

The frame branches (l.3756-3760, `frame_array` builds the address without code; l.3859-3868)
pass neither the array node nor `local[i]`. A value push left on a node is reported (l.1702-1704)
and generation exits 1 (l.5215-5225). The sentence is correct. round10-R10A.md N2: **resolved**.
New: R12A-N4 (the list is not exhaustive; latent), below.

### F12-05: FIDELITY F74, inventory P8, annot "1170:05CA" (ChooseCityProduction 1170:05CA)

**ReselectCityProduction's paths** [S]. Every path to the call 1078:4D80:

| Path | Test before it | Excludes | In the record |
|---|---|---|---|
| CompleteResearch 1170:22F9 → AIReconsiderCityProduction → 4D17 | 2280..228C `cmp g_humanPlayer,player`, 2293 turn 0 | `g_humanPlayer` after turn 0 | for `g_humanPlayer` on turn 0 only |
| ProcessCity 1030:2386 | 1F21 `cmp ax,[g_humanPlayer]`, `jne 1F2B`; every label in 1F2B..2385 is reached only from inside (seg007_1030.asm l.3339-3750) | `g_humanPlayer` | yes, correct |
| ProcessCity 1030:2DC5 | 2DA8 `test g_humanCivsMask,1<<owner`, `je 2DB2` (2DB2 only from 2DAD), else `jmp 31A6` | the mask | yes, correct |
| AIAnalyzeCivStrategy 1078:0D32 → 4D17 | 0D23 `test g_humanCivsMask,1<<civ`, `jne 0D38` | the mask | yes, correct |
| TakeAdvanceFromCiv 1038:0BA9 → 4D17 | 0A8F `cmp g_humanPlayer,di` (taker), `jne 0AF9` → 0B97..0BA9 | `g_humanPlayer` | **no** |
| MoveCivUnits 11F0:28AB → 4D17 | 2882..2890 `cmp g_foundUnitCiv2,g_humanPlayer`, `je 28B3` | `g_humanPlayer` | **no** |

(AIReconsiderCityProduction's callers: `seg016_1078.asm` l.8322-8328 and Grep of
`claude/src/asm`; ReselectCityProduction's: 2386, 2DC5, 4D17.) The new wording is right for the
three paths it names; R11A-N2's point (2DC5 and 0D32 exclude the whole mask) is **resolved**. The
enumeration is incomplete: R12A-N5.

**CaptureCity 1038:0000** [L][G] (scratch `R12A_1038_0000.txt`; `core/seg008_1038.c` l.397-421).

| Record | Listing | Result |
|---|---|---|
| 07AF..07B6: a human captor goes to ProcessCity at 07BB | 07AF `mov ax,[g_humanPlayer]`, 07B3 `cmp ax,[bp+newOwner]`, 07B6 `jne 07C5`; 07BB `call ProcessCity(city,1)` | correct |
| 07CF production 0, call 07D9, store 07EB | 07CF `mov byte [g_cities+9],0`; 07D9 `ChooseCityProduction(newOwner, city)`; 07EB `mov [g_cities+9],al` | correct |
| dialog path only: 024D cleared status bit 0x10 | 024D `and byte [g_cities+6],0xAE` on the surviving-city path (0232; the razing path 01CA..022F sets size 0 and 0769 skips to 0826); CaptureCity's later status stores are 0360 `and 0x9B` and 0759 `or 1` | correct (callees not traced) |
| 0821 after 07FA..0800 skip only a negative byte, charged to marker 07C5 | 07FA `cmp [g_cities+9],0`, 0800 `jl 0826`; 0821 `inc [g_unitsInProduction + newOwner*0x38 + 2*prod]`; generated l.410 `VM_SITE(0x103807C5u)`, call l.414 (the callee's `fr_leave` restores the site), increment l.418 | correct |
| 07A5, the old owner's row, under marker 0774 | 077E `cmp [g_cities+9],0; jl 07AA`; 07A5 `dec [g_unitsInProduction + oldOwner*0x38 + 2*prod]`; generated l.399-401 | correct |
| unlisted, like the others | no OOB comment at 0774/07C5; the `acc_ix2` second index 99 against GN2 (28) would record INDEX2 there | correct |

R11A-N3: **resolved** (F74 l.41, P8 l.188, annot l.1489 now name 07EB; F74 and P8 name 0821 and
07A5). The annot change is a `#` comment (l.1483-1492): no output. Spot check: in
`translate.py --show 1170:05CA` (scratch, 1701 lines) the P8, UNINIT and P6 comment lines stand at
l.770 and l.1137-1138, `core/seg047_1170_p2.c` l.782 and l.1149-1150 (offset 12, the function
starts at core l.13).

### F12-06: FIDELITY F48 (OpenPalaceView 1158:08E7)

[L] 0C9F `mov si,8`; 0CA7 `mov bx,si; dec si`; 0CB1 `cmp level[bx],-1`; 0CB7 `je 0CA4`; 0CA4
`mov [bp+rightEndSection],si`. Passing unbuilt slot k assigns k-1; the scan stops at the first
built slot without assigning; with slot 8 built nothing is assigned. F48 (l.68) now says exactly
this ("assigns it (0CA4, the index below the slot) only while it passes an unbuilt slot and stops
at the first built slot without assigning"). R11A-N4: **resolved**.

### F12-07: FIDELITY F65 (DrawPalaceSectionPiece 1158:140C)

[L] By the scan, `rightEndSection` is 4 only with slots 8, 7, 6, 5 unbuilt and 4 built. The 0E45
call needs `rightEndSection - 1 == si` (0DFD..0E03), so si = 3, the shape-1 case (left wing, section
2 built: 0CF3..0D07) and equal variants (0E05..0E22). [S] 10E8:0E8A..0EBA set
`g_palaceSectionLevel[3..5]` (and 9..11) to 0 (`seg030_10E8.asm` l.1585-1604), so section 5 is
unbuilt only in a loaded save. F65 (l.37) now says "a loaded save with sections 5..7 unbuilt and
section 4 built, which needs a save because game code always builds sections 3..5". R11A-N5:
**resolved**. Remark, not counted: slot 8 unbuilt is left implicit (with slot 8 built the value is
the stale word of F65's other case).

### The rest of the seven diffs

* `gen/findings_sites.py`: the four C9 source strings only (F12-01).
* `gen/annot.py`: the moved CreateDissolveState block (entry lines identical) and two `#`
  comments (F12-02, F12-05).
* `core/acc.h`: comment lines only (all five hunks lie inside `/* */`).
* `docs/DESIGN.md`: the two sentences of F12-03 and F12-04.
* `docs/FIDELITY.md`: F65, F74 and F48 only; their references columns gain round 11/F12 citations
  for F74 only (F48 and F65 cite R11A inline).
* `docs/verify/round8-fixes.md`: the F12 section. Its F12-05 row repeats the three-path
  enumeration (R12A-N5); the other rows match the changes.
* `docs/inventory/out-of-range.md`: the four generated C9 rows, P8 and P9.

No generated statement depends on any changed text; nothing else changes behaviour or misstates
the listing apart from the notes below.

### Findings

No TRANSLATOR or RECOVERY finding.

**R12A-N1 NOTE (P9 states no outcome; inventory l.189).** [L][C]
* TextBox layout (`core/gen/civ_layout.h`, round 10): `lineLength` +0x1A, `lineOffset` +0x9A (64
  words each), `text` +0x11A, block 0x51A.
* For line 64 + k, TextBoxSetup's 224F store `lineLength[64+k]` (+0x1A + 0x80 + 2k) overwrites
  `lineOffset[k]`, and its 2232 store `lineOffset[64+k]` (+0x11A + 2k) overwrites text bytes 2k and
  2k+1.
* So TextBoxDraw draws line j < lineCount - 64 from text offset `lineLength[j+64]` (2627..2631),
  through a text whose first bytes hold offset words. Both tables leave the block from SI = 576
  (`lineOffset`) and 640 (`lineLength`).
* Once a store lands at or past the cursor, TextBoxSetup's own scan reads it. Example: a run of
  bare CRs (one character per line) ends after 130 lines, because line 128's store puts the word
  0x0080 at text offsets 128..129, and the NUL ends the text.
* Round 10 R10-T1 described the overlaps; P9 gives only the sites and the condition, while the
  other P entries state what the access does.
* Behaviour and the allowlist are unaffected. Wording/completeness only.

**R12A-N2 NOTE (the hand section's preamble, inventory l.173-177).** [F][G]
* The preamble says each entry's statement carries `/* OOB: port Pn */` (gen/annot.py), and the
  heading says "not in findings.md".
* P9's statements carry `/* OOB: findings C9 */` from the findings-sites MANUAL entries (P9 says
  so itself). Grep `OOB: port P` over `core/` finds P1..P8 only.
* Wording only (the allowlist is keyed by marker).

**R12A-N3 NOTE (`core/acc.h` l.95-97 and l.209-212: width 0 described by the element).** [D][G]
* `lval_member` passes the accessed member's width, `w(f.ctype)`, to `acc_ix1` (l.3857) and
  `acc_fx1` (l.3867-3868), not the element's.
* `g[i].m` with an array or structure member gets width 0 and admits i = n. Examples:
  * `g_hallOfFame[DI].leaderName` / `.civPluralName`: `seg017_1080.c` l.366, 401;
    `seg017_1080_r.c` l.79, 88;
  * `g_ditherKernels[kernelIdx].taps`: `seg026_10C8.c` l.217, 454.
* A scalar member gets its width although the element is a structure. Example: `pts[0].x`,
  `acc_fx1(..., OF_POINT_x, 2u, ...)`, `seg011_1050_t.c` l.229, where an index n would be recorded.
* "an element that is a structure or an array" therefore describes `lval_index`'s calls only.
  Precise wording: "the accessed object (the element, or for `g[i].m` / `local[i].m` the member) is
  a structure or an array".
* The `acc_ix1m`/`acc_pm` comments and DESIGN l.276-281 are exact. The access proceeds either way.
  Wording only.

**R12A-N4 NOTE (latent, as R10A N2; DESIGN l.305-310).** [D]
* The sentence names the frame branches and the member-array forms. The global-array branches
  also build their address without passing the inner nodes through `lval` or `rv`:
  * `lval_index` l.3731-3754: the identifier `g`, `g[i]` of `g[i][j]`, `g[i][j]` of `g[i][j][k]`;
  * `lval_member` l.3849-3858: `g` of `g.f`, `g[i]` of `g[i].f`;
  * `lval_index` l.3780-3786: `g[i]` of `g[i].m[k]`.
* An annotated value push on such a node would not be written either. None exists, and generation
  would fail (l.1702-1704, l.5215-5225).
* Suggestion: state the rule generally ("only the nodes a form evaluates through `lval`/`rv` emit
  their value pushes"). Wording only.

**R12A-N5 NOTE (F74 l.41, P8 l.188, round8-fixes.md F12-05: "of its other paths").** [S]
* The record lists three of ReselectCityProduction's other paths: 1F21 → 2386 (excludes only
  `g_humanPlayer`), and 2DC5 and 1078:0D32 (exclude the mask).
* Two more callers of AIReconsiderCityProduction (→ 4D17 → 4D80) exclude only `g_humanPlayer`:
  * TakeAdvanceFromCiv 1038:0BA9 (taker test 0A8F; called from CaptureCity 0655 and the
    diplomatic exchange);
  * MoveCivUnits 11F0:28AB (test 2882..2890).
* CompleteResearch's own AI path (22F9; 2280..228C) also serves every civ other than
  `g_humanPlayer`. The record names it only for `g_humanPlayer` on turn 0.
* So another civ in `g_humanCivsMask` reaches the store 4D92 through four paths, not one.
* Example in CaptureCity: the call 0655 → 0BA9 runs ReselectCityProduction on the captured city
  itself (owner set at 03C2), for a captor other than `g_humanPlayer`, on the dialog path (024D).
  It does so before 07A5 reads that production in the old owner's row.
* F74's claim that `g_humanPlayer`'s cities are reached only through CompleteResearch on turn 0
  still holds: all six paths exclude `g_humanPlayer` otherwise.
* P8's marker, its latency and the triage rule are unaffected. Wording/completeness only.

### Earlier findings addressed by F12

| Finding | Item | Status |
|---|---|---|
| seg014_1068_p2.md round 11 R11-N1 | F12-01 | resolved; R12A-N1, N2 |
| seg023_10B0_p1.md round 11 R11-N1 | F12-02 | resolved |
| seg023_10B0_p1.md round 11 R11-N2 | F12-02 | resolved |
| round11-R11A.md N1 | F12-03 | resolved (DESIGN, `acc_ix1m`, `acc_pm`); R12A-N3 for `acc_ix1`/`acc_fx1` |
| round11-R11A.md N6 | F12-03 | resolved |
| round10-R10A.md N3 (last point) | F12-03 | resolved |
| round10-R10A.md N2 | F12-04 | resolved; R12A-N4 |
| round11-R11A.md N2 | F12-05 | resolved; R12A-N5 |
| round11-R11A.md N3 | F12-05 | resolved |
| round11-R11A.md N4 | F12-06 | resolved |
| round11-R11A.md N5 | F12-07 | resolved |

### Not checked

* Run-time behaviour, checked-build records, tests and the harness: no build or run, by the brief.
* Whether a shipped text breaks into more than 64 lines (needs the texts, fonts and box widths).
* Whether a callee between CaptureCity's 024D and 07D9 (TakeAdvanceFromCiv, ShowCityView,
  DeleteUnit, ...) sets the city's status bit 0x10: only CaptureCity's own stores were read.
* The conditions under which MoveCivUnits reaches 28AB, and HoldDiplomaticAudience's calls of
  TakeAdvanceFromCiv, beyond the tests in the table.
* Whether generated code forms a one-past `&p->m[n]` of a scalar element (DESIGN says so too).
* Whether any value push can be planned on an array or structure node (`plan_body_pushes`).
* `translate.py --show 1170:05CA` was compared at the comment lines only; 10B0:151B line by line.
* Whether game code can unbuild a section (level -1) after setup (F48's premise, not part of F12).

### Deviations from the brief's rules

* No shell access to a project file.
* Python, as the brief allows, with output redirected to `v12/R12A_*` scratch files:
  * `C:/Python314/python -B C:/Projects/Civ1RE/claude/tools/showfunc.py` for 1068:2072, 1068:258F,
    10B0:151B, 1158:08E7 and 1038:0000;
  * `claude/port/gen/translate.py --show` for 10B0:151B and 1170:05CA.
* Other shell use: `mkdir -p` and `ls` of the scratch directory, `wc -l` on `R12A_` scratch files,
  and one `echo` that touched no file.
* Project files were read with the Read, Grep and Glob tools, including `claude/src/asm`
  (read-only).
* Written: this file (Write) and the appended "## Round 12" sections in `seg014_1068_p2.md` and
  `seg023_10B0_p1.md` (Edit). Nothing else.

### Verdicts

Items without a unit carry the record's location. T and R count findings open after this round;
N counts this round's notes.

| Function | Address | Verdict | T | R | N |
|---|---|---|---|---|---|
| TextBoxSetup; TextBoxDraw (P9, MANUAL C9; F12-01) | 1068:2072; 1068:258F | PASS | 0 | 0 | 2 |
| CreateDissolveState (annot; F12-02) | 10B0:151B | PASS | 0 | 0 | 0 |
| `core/acc.h` comments, DESIGN.md 3.2 width 0 (F12-03) | acc.h l.95-97, 130-132, 153-155, 174-176, 209-212; DESIGN l.276-281 | PASS | 0 | 0 | 1 |
| DESIGN.md 3.2 body-push sentence (F12-04) | DESIGN l.305-310 | PASS | 0 | 0 | 1 |
| ChooseCityProduction (F74, P8, annot; F12-05) | 1170:05CA | PASS | 0 | 0 | 1 |
| CaptureCity (F74's store 07EB, readers 0821/07A5; F12-05) | 1038:0000 | PASS | 0 | 0 | 0 |
| OpenPalaceView (F48; F12-06) | 1158:08E7 | PASS | 0 | 0 | 0 |
| DrawPalaceSectionPiece (F65; F12-07) | 1158:140C | PASS | 0 | 0 | 0 |

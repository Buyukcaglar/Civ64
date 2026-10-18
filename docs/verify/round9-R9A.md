# Round 9, batch R9A: ix3 (F8-15, round8-R8D.md G-1)

Verifier R9A, 2026-10-09.

**Scope.** Item F8-15:
* `acc_ix3` (`core/acc.h`);
* `VM_OOB_INDEX3` (`platform/w16/vm.h`);
* the three-index branch of `gen/translate.py` `lval_index`;
* the 18 generated accesses;
* `tests/test_acc.c`: the acc_ix3 cases, and the frame-object boundary cases that F8-12 added for
  round8-R8A.md N5;
* DESIGN.md 3.2 "Checked build": the acc_ix3 sentence and the test_acc sentence.

The per-function verdicts for the 18 accesses are in the unit reports, each in a section "## Round 9
(2026-10-09): ix3": `seg015_1070_p1.md`, `seg015_1070_p1_r.md`, `seg015_1070_p2_r.md`,
`seg030_10E8_p3_r.md`, `seg041_1140_r2.md` and `seg044_1158.md`.

**Inputs.**
* Diffs: `build/verify-round9/diff/core-acc.h.diff`, `platform-vm.h.diff`, `gen-translate.diff`, and the
  six unit diffs.
* Accessor and VM: the current `core/acc.h`; `platform/w16/vm.h`; `platform/w16/vm.c` (`acc_chk`,
  `acc_chk_index`, `vm_oob_record`).
* Generator: `gen/translate.py` l.1695-1709, 3629-3860 and 5148-5193; `gen/layout.py` (`array_tags`);
  `gen/oob_allowlist.py`; `core/gen/civ_layout.h`.
* Tests and harness: `tests/test_acc.c`; `tests/headless/harness.c` and `harness_main.c` (the
  consumers of the records).
* Records: `docs/DESIGN.md` l.225-310, `docs/inventory/out-of-range.md`, `docs/FIDELITY.md` F48,
  `round8-fixes.md`, `round8-R8D.md`, `round8-R8A.md`.

**Methods.**
* [T]: port source, meaning the accessor, VM, translator, layout generator and test. The brief's label
  list has no label for it; R8A used [T].
* [G] generated C, [L] listing (`showfunc.py`), [C] computation, [F] docs, [S] call sites in
  `claude/src/asm`.
* `translate.py --show` was run for the seven functions that contain the accesses (scratch
  `v9/R9A_show_*.txt`).

Nothing was built, compiled, tested or run. The headless results quoted here (BUILD_OK, test_acc 32
checks, GATE3B_OK) are the orchestrator's.

## 1. `acc_ix3` (core/acc.h l.129-150) [T][C]

**(a) Address.**
* The release address is `va_ix(va_ix2(obj, i, s1, j, s2, disp), k, s3, 0u)`.
* The former code was `va_ix(acc_ix2(obj, i, s1, n1, j, s2, n2, 0u, size, 0u), k, 1u, 0u)`. `acc_ix2`
  returns `va_ix2(obj, i, s1, j, s2, 0u)`, which its checks do not modify (l.112-127).
* The translator always passes disp = 0u.
* s3 = `GS3_g` = 1u equals the former literal stride. `layout.py` `array_tags` takes it from the
  element size of the third dimension, and both globals have one-byte elements.
* So the two forms are the same calls on the same arguments.
* `VM_PTR` keeps the low 16 bits at each step, and addition commutes modulo 0x10000. Even a non-zero
  disp would give `(off + i*s1 + j*s2 + disp + k*s3) mod 0x10000`, with the selector unchanged.
* In the checked build the checks do not change `a`. The address is therefore the same in both
  builds.

**(b) Checks (CIV_CHECKED).**
* i < n1 (kind 1), j < n2 (kind 2), and k < n3 (`VM_OOB_INDEX3`). For width 0 the test is k <= n3,
  as in `acc_ix1` l.102.
* Then `acc_chk(a, obj, size, width)` on the accessed address. It records a different selector,
  `off < base`, or `off + width > base + size` (vm.c l.261-269).
* A negative index arrives as a uint32 of 2^31 or more and is recorded.
* The release build has `(void)` for n1, n2, n3, size and width. The other parameters are used in the
  address.

**(c) Compared with the round-8 checks.**
* acc_ix2 ran `acc_chk` on the row address with width 0. acc_ix3 runs it on the accessed byte, with
  its width.
* A row address outside the object needs i or j outside its dimension, and both forms record that.
* So the change only adds records at a site (INDEX3, and EXTENT for the accessed byte). It never
  removes one. Only the record kind can differ, when the row address is already outside the object.
* The allowlist and its check are keyed by marker (`gen/oob_allowlist.py`; `harness_main.c`
  `oob_unlisted`).

**Remark (no finding).** acc_ix3 relaxes its last index for width 0, as acc_ix1 does. acc_ix2 does
not relax its j. All 18 acc_ix3 calls pass width 1u, so the relaxation is never used.

**N1 NOTE (wording).** [T][F] Two descriptions were not updated for the third dimension:
* the acc.h header: l.10-11 list the strides `GS_, GS2_` and counts `GN_, GN2_`, and l.18-20 list the
  checks as "first index, second index, member-array index";
* DESIGN.md 3.2 l.227-229 (`GS_`, `GS2_` ... `GN_`, `GN2_`).

Neither mentions `GS3_`/`GN3_` or the third-index check. The function comment (l.129-131) and DESIGN
l.259-266 do.

## 2. `VM_OOB_INDEX3` (platform/w16/vm.h l.150-165) [T]

* The value is 4, after `VM_OOB_MEMBER` = 3. The `index` comment of `VmOobHit` now names INDEX3.
* `VmOobHit` is unchanged: six uint32 fields, 24 bytes. `harness.c` l.234 divides the record payload
  by 24.
* Consumers of `what`:
  * `vm_oob_record` keys records by (site, obj, what);
  * `harness_main.c` prints `what` as a number and triages by site only;
  * `test_acc` compares by value.
* Nothing indexes a table by `what`.

No finding.

## 3. Translator branch (gen/translate.py l.3741-3754) [T][G]

**When it applies.**
* It applies to `e = b[k]` with `b = a[j]` and `a = g[i]`, where g is a global identifier and a and b
  have array type.
* It follows the one-index global branch (`g[i]`) and the two-index branch (`g[i][j]`). Their
  conditions exclude this case, because `e.base.base` is an Index.
* It precedes the frame-object branch.
* Before the change, a three-index access fell through to `is_array(e.base.ctype)`. That called
  `addr_of(e.base)` and then `lval(e.base)`, which took the two-index branch with width `w(array)` =
  0u, and the result was `va_ix(base, icode, stride, 0u)`. `frame_array(e.base)` returned None and had
  no effect.
* Only two globals have three dimensions. `GS3_` exists only for `g_spaceshipGrid` and
  `g_palacePieceYOffsets` (`signed char [8][15][12]` and `[5][3][5]`, civ_globals.h l.67/277).

**Evaluation order.**
* k: l.3717 (`self.rv(e.index, T.INT if ...)`) runs before every branch, as before.
* j: the former code evaluated it in the inner `lval_index(g[i][j])` at l.3717. The new l.3749-3750
  use the identical expression and conversion.
* i: the former code used l.3738 `self.rv(e.base.index)`, without a conversion. The new l.3751
  `self.rv(e.base.base.index)` has no conversion either.
* The text is the same: `(uint32_t)({j})` equals the inner call's former `icode`, and k keeps
  `{icode}`.
* The element width is `self.w(elem)` = "1u" for the signed-char element.
* The `rv` calls happen in the same order, so temporaries and pushes come out in the same order. Only
  the access expression changes.
* Evidence:
  * the six unit diffs change 17 lines (18 accesses) and nothing else;
  * the `--show` outputs contain 1+2+2+4+1+7+1 = 18 `acc_ix3` and no `va_ix(acc_ix2(`;
  * `--show 1070:11F2` equals core `seg015_1070_p1.c` l.455-476, and the `acc_ix3` lines of `--show
    1158:140C` and `10E8:3368` equal core l.66 and l.443.

**N2 NOTE (latent; same class as round8-R8A.md N2).** [T]
* The new branch does not pass the `g[i][j]` node through `lval`. So `emit_value_pushes` is no longer
  called for that node; the former path called it via `addr_of(e.base)`.
* A body "value" push annotated on that node would therefore not be written.
* None exists: the diffs lose no `stk_push` line.
* Such a push would be reported at l.1702-1704 ("annotated body push ... (value) not emitted"), and a
  finding makes the generator exit non-zero (l.5183-5185, 5193).
* DESIGN 3.2 l.288-291 states this limit for the frame branches only. For the current units, the
  comment at l.3741-3743 ("so only the checks change") holds.

**N3 NOTE (latent; the compiler catches it).** [T]
* Neither this branch nor the two-index branch tests that g itself is an array. A global pointer to a
  two-dimensional array would match, and the code would use `VA_g`, the address of the pointer
  variable.
* `layout.py` emits strides and counts only for array globals (`array_tags` under `tag(ct) == "A"`).
  Such a global would have no `GS3_`/`GN3_`, so the generated C would not compile.
* No such global exists (BUILD_OK).

## 4. The 18 accesses [G][L][C][S]

**Dimensions.**
* g_spaceshipGrid: VA 1290:01B2, SZ 0x5A0, GS 0xB4/0xC/1, GN 8/15/12.
* g_palacePieceYOffsets: VA 1350:000A, SZ 0x4B, GS 0xF/5/1, GN 5/3/5.
* Both have GE ACC_T_I8. The listings read a signed byte (`cbw` and signed compares), and every site
  has width 1u.
* The listing strides (`imul 0xb4`, `imul 0xc`; `imul 0xf`, `imul 5`) and displacements (+0x1B2; +0xA,
  or +5..+9 together with `k*5`) match.

| # | Unit l. | Function | Listing | Index ranges | Marker | New record kinds | Allowlist / record |
|---|---|---|---|---|---|---|---|
| 1-2 | seg015_1070_p1 l.466 | IsSpaceshipStructureAt | 121A, 1236 | x 2..15, y -1..12 (caller's neighbours) | 1206 | INDEX3 (y -1/12); EXTENT (civ 7: x 15, or (14,12)) | U5, function level |
| 3 | seg015_1070_p1_r l.275 | EvaluateAndShowSpaceship | 051B | layout records 0..66 | 04DE | none | - |
| 4 | seg015_1070_p2_r l.38 | AiPlaceSpaceshipPart | 1798 | records 0..66 | 1765 and later | none | - |
| 5 | l.117 | AiPlaceSpaceshipPart | 190A | records 0..66 | 18C8 | none | - |
| 6 | l.217 | HumanPlaceSpaceshipPart | 1A5A | records 0..32 | 1A19 and later | none | - |
| 7 | l.235 | HumanPlaceSpaceshipPart | 1ADA | records 33..66 | 1A9A and later | none | - |
| 8 | l.260 | HumanPlaceSpaceshipPart | 1B76 | records 0..66 | 1B41 and later | none | - |
| 9 | l.273 | HumanPlaceSpaceshipPart | 1BF1 | records 0..66, 67, 99 | 1BAF | INDEX3 (67: y -1; 99: y = star byte); EXTENT (civ 0) | C4 at 1BAF |
| 10 | seg030_10E8_p3_r l.443 | ResetSpaceship | 33A2 | x 0..14, y 0..11, civ 0..7 | 3386 | none | - |
| 11-17 | seg041_1140_r2 l.413/429/446/460/475/491/507 | RunPalaceImprovement | 0562/05B6/060D/0661/068C/06D6/072A | newLevel 1..4, k-1 0..2, c 1/3/1/2/0/1/4 | 0548/05A1/05F8/0642/0677/06BC/0715 | none | - |
| 18 | seg044_1158 l.66 | DrawPalaceSectionPiece | 146B | 0..4 / 0..2 / 0..4 on OpenPalaceView's game paths | 1445 | INDEX3, EXTENT only on stale or loaded-save paths | P5 at 1445 (see seg044_1158.md R9-N1) |

**Conclusion.**
* At these sites no listing index range produces an unlisted record.
* New records arise only at markers 1206 (U5), 1BAF (C4) and 1445 (P5). All three are allowlisted, and
  the out-of-range reads are documented.
* One exception in the documentation: the 1445 record via OpenPalaceView 0E45 (a stale or
  loaded-save `rightEndSection` of 4) is allowlisted, but the inventory P5 row does not describe it
  (seg044_1158.md R9-N1, NOTE).
* The 1206 records occur on ordinary spaceship-screen evaluations (parts on rows 0 and 11).
* The orchestrator's S2..S5 scenarios reach none of these functions.

## 5. tests/test_acc.c [T][C]

**acc_ix3 cases.**
* l.92-95 (both builds): (7, 14, 11) gives 0x1B2 + 7*0xB4 + 14*0xC + 11 = 0x1B2 + 0x4EC + 0xA8 + 0xB =
  0x751, so 0x12900751. That is the last byte, 0x1B2 + 0x5A0 - 1. Right.
  * The test defines only the DGROUP and 12D8 segments, not 1290. That is fine, because acc_ix3 does
    not access memory.
* l.124-133: (7, 14, 11) with width 1, and (0, 0, 12) with width 0 (k = n3 is admitted; the address
  0x1BE is inside). Neither INDEX3 nor EXTENT is recorded at site 0x1000000A. Right.
* l.134-141: (0, 0, 12) with width 1 records INDEX3 with index 12. The address is 0x1BE, and 0x1BE + 1
  <= 0x752, so no EXTENT. Right. This is the G-1 case: a third index that stays inside the object.
* l.142-148: (7, 14, 12) with width 1 records INDEX3, and 0x752 + 1 > 0x752 records EXTENT. Right.

**F8-12 frame-object cases (round8-R8A.md N5).**
* l.176-182: index 73 of 73 with width 2 records INDEX1 with index 73 (N5's "index n with width >
  0"). Right.
* l.183-192: a member at offset 6 of the structure local -40, 4 words.
  * The address is 0xD000 - 40 + 6 + 3*2 = 0xCFE4, so 1420:CFE4.
  * Index 3 is not recorded.
  * Index 4 is recorded under FR_KEY(-34) and not under FR_KEY(-40). FR_KEY(-34) is the translator's
    key, `sym.loc + field.offset` (translate.py l.3786). Right.
* l.193-202: `local[i].member` with 4 structures of 6 bytes at -40 and the member at +4. The address
  is 0xCFD8 + 3*6 + 4 = 0xCFEE. Index 3 is not recorded; index 4 is recorded with index 4 (N5's
  "disp != 0"). Right.
* l.203-208: index 5 of 4 with width 0 is recorded (n + 1 = 5). With l.162 (index n, width 0, not
  recorded), this covers N5's "n + 1 with width 0". Right.

**Count.** 10 checks run in both builds and 22 in the checked build only, 32 in all (the orchestrator
reports 32 passing). F8-12's 28 = 22 earlier checks + 6 new ones; acc_ix3 adds 4. The counts are
consistent.

**Not covered (no finding).** INDEX1/INDEX2 through acc_ix3, and a negative third index. They use the
same `acc_chk_index` path as acc_ix1/acc_ix2.

## 6. DESIGN.md 3.2 "Checked build" [F]

* **l.259-263:** "the first, second and third index of a global array (`VM_OOB_INDEX1`,
  `VM_OOB_INDEX2`, `VM_OOB_INDEX3`)". This is true of the global forms the translator emits (acc_ix1,
  acc_ix2, acc_ix3).
* **l.263-266, the acc_ix3 sentence:** two globals, 18 accesses in 6 units; the round-8 form
  `va_ix(acc_ix2(...), k)`, with the third index and the extent unchecked; the address and the
  evaluation order of the indexes unchanged. Correct (sections 1, 3 and 4).
  * The round-8 form did check the row address with width 0 (R8D G-1). "The extent unchecked" means the
    extent of the accessed byte, which is right.
* **l.291-297, the test_acc sentence:**
  * "a three-index global (`g_spaceshipGrid`'s last byte; the third index alone, and with the extent)"
    matches l.92-148;
  * the frame-object list ("index n recorded with a width, n + 1 with width 0; a member array at an
    offset keeps its own key; `local[i].member`") matches l.176-208.

  Correct. It does not mention the width-0 case k = n3 (l.128-133), which is not required.
* The same paragraph also states that member-array indexes are checked. That claim does not hold in
  translated code: see G-2.

## Generic finding for the orchestrator (found while checking section 6)

**G-2 TRANSLATOR (generic; translator coverage against DESIGN.md 3.2 "Checked build" and prompt 5.2
item 3): member-array indexes are not checked in translated code.**

**What the records say.** [F] DESIGN 3.2 l.259-263: "Every indexed access checks each index against
its own dimension: ... and the index of an array member (`VM_OOB_MEMBER`). It also checks the whole
access against the object's extent". l.267-268: "Pointer accesses check member-array indexes (`F_AX`,
...)".

**What the generator does.** [T]
* `translate.py` never emits `acc_ix1m`, `acc_pm`, `GF_RDX`/`GF_WRX` or `F_AX`. They appear in no file
  under `gen/`, and in `core/` only in `acc.h` and the macro compile check `civ_headers.c` l.62/67.
* `lval_index` reaches an array member of a global element, or of a structure addressed through a
  pointer, through its generic tail (l.3761-3769): `va_ix(addr_of(base), k, stride, 0u)`.
  * For `g[i].m`, `addr_of` gives `acc_ix1(VA_g, i, ..., OF_S_m, SZ_g, 0u)`: width 0, an address-only
    check of where the member starts.
  * For `p->m` it gives `fp_add(p, OF_S_m)`.

**Extent.** [G]
* 40 accesses on 37 lines in 11 units have the form `va_ix(acc_ix1(VA_g, i, GS, GN, OF_S_m, SZ_g, 0u),
  k, ...)`. These are the g_cities `storedUnits`/`tradeRoutes` members, and the g_ditherKernels `taps`
  member at seg026_10C8.c l.516. Example: seg009_1040_p1.c l.218, `g_cities[SI].tradeRoutes[DI] =
  0xFF`.
* 51 lines in 12 units have the form `va_ix(fp_add(p, OF_S_m), k, ...)`. Examples: seg019_1090_r.c
  l.86-91, `lpGodLogPalette->palPalEntry[SI]`; seg023_10B0_p1, the DissolveState `order`/`rowPhase`
  members.
* In all of them neither the member index k nor the extent of the accessed bytes is checked. For
  `g[i].m[k]`, a large or negative k can even leave g without a record.
* Only members of frame structures are checked (`acc_fx1` with `VM_OOB_MEMBER`).

**Earlier reports.** seg023_10B0_p1.md N2 recorded the pointer form as a translator-wide NOTE. The
global-element form and the DESIGN claim were not reported.

**Classification.** As R8D G-1 (the same gap for the third index of a global), this is a generic
TRANSLATOR finding, not attributed to a function of this batch.
* The index ranges of these 91 lines were not analysed.
* A search of findings.md for `tradeRoutes[`, `storedUnits[`, `taps[` and `palPalEntry[` finds only
  C6's `g_cities[127].tradeRoutes[2]`, which is written through g_units, and g_units is checked.

**Fix options.**
* Emit `GF_RDX`/`GF_WRX` (`acc_ix1m`) for `g[i].m[k]` and `F_AX` (`acc_pm`) for `p->m[k]` in
  `lval_index`.
* Or state in DESIGN 3.2 that member-array indexes of global and pointer-addressed structures are not
  checked.

This finding predates F8-15, which did not introduce it.

## Status of round-8 G-1

**Fixed.**
* `acc_ix3` checks the third index and the extent of the accessed byte.
* All 18 accesses use it.
* `GN3_g_palacePieceYOffsets` and `GN3_g_spaceshipGrid` are now used.
* DESIGN 3.2 states the coverage, and test_acc covers it.
* The one effect site R8D had analysed (DrawPalaceSectionPiece l.66, `seg044_1158.md` round 8 N1) is
  covered: its N1 is fixed.

## Not checked

* Run-time behaviour. Nothing was built, compiled or run; the headless results are the
  orchestrator's.
* The full `--show` output against core for the functions other than IsSpaceshipStructureAt. For them
  only the `acc_ix3` counts and the 1158:140C / 10E8:3368 lines were compared; the unit diffs are the
  evidence that nothing else changed.
* The index ranges of the 91 member-array lines of G-2.
* The DESIGN 3.2 sentences changed for other items in round 9 (frame-object coverage, the
  loop-condition rule).
* The run-time values of g_starColors (HumanPlaceSpaceshipPart record 99), and the stale stack word
  `rightEndSection` (seg044_1158.md R9-N1).

## Deviations from the brief's rules

None.
* Shell commands only ran `showfunc.py`, `dumptables.py --table` (stdout to scratch, no `--json`) and
  `translate.py --show` into `v9/R9A_*`.
* `grep`, `sed`, `wc`, `cut`, `md5sum` and `cat` were used only on those scratch files.
* Project files were read only with the Read and Grep tools.

## Summary

| Function | Address | Verdict | T | R | N |
|---|---|---|---|---|---|
| acc_ix3 (core/acc.h) | l.129-150 | PASS | 0 | 0 | 1 |
| VM_OOB_INDEX3 (platform/w16/vm.h) | l.156 | PASS | 0 | 0 | 0 |
| lval_index three-index branch (gen/translate.py) | l.3741-3754 | PASS | 0 | 0 | 2 |
| test_acc: acc_ix3 and round8-R8A N5 cases (tests/test_acc.c) | l.91-95, 123-148, 176-208 | PASS | 0 | 0 | 0 |
| DESIGN.md 3.2 Checked build: the acc_ix3 and test_acc sentences | l.259-266, 291-297 | PASS | 0 | 0 | 0 |

The 18 accesses (unit reports, round 9):

| Function | Address | Verdict | T | R | N |
|---|---|---|---|---|---|
| IsSpaceshipStructureAt | 1070:11F2 | PASS | 0 | 0 | 0 |
| EvaluateAndShowSpaceship | 1070:0327 | PASS | 0 | 0 | 0 |
| AiPlaceSpaceshipPart | 1070:16C3 | PASS | 0 | 0 | 0 |
| HumanPlaceSpaceshipPart | 1070:1952 | PASS | 0 | 0 | 0 |
| ResetSpaceship | 10E8:3368 | PASS | 0 | 0 | 0 |
| RunPalaceImprovement | 1158:0000 | PASS | 0 | 0 | 0 |
| DrawPalaceSectionPiece | 1158:140C | PASS | 0 | 0 | 1 |

The generic finding G-2 (TRANSLATOR: translator and DESIGN 3.2) is not counted in these tables.

# Round 10, batch R10B: member (F10-07, round9-R9A.md G-2)

Verifier R10B, 2026-10-09.

**Scope.** Kind "member": every `acc_ix1m` and `acc_pm` call of eleven units, checked against the
listing for (a) the member's count, stride, offset and element width, (b) the address against the
round-9 form, (c) the index ranges, the governing statement marker and the allowlist. The accessors,
the translator branch and `test_acc` are reviewed by R10A.

| Unit | Lines | acc_ix1m | acc_pm | Functions |
|---|---|---|---|---|
| seg026_10C8 | 1 | 1 | 0 | AllocDitherWeightTables |
| seg035_1110_p1_s | 1 | 1 | 0 | DrawMapTile |
| seg045_1160_p2 | 6 | 0 | 8 (2 rows) | DrawLeaderAnimationFrame |
| seg047_1170_p1_r | 2 | 2 | 0 | DestroyCity |
| seg047_1170_p2 | 5 | 5 | 0 | ChooseCityProduction |
| seg051_1190_p1 | 6 | 0 | 6 | OpenResFile, OpenResFileStdio |
| seg051_1190_p2 | 4 | 0 | 4 | AddType |
| seg054_11A8_p1 | 1 | 0 | 1 | DrawTileImpl |
| seg057_11C0_p1 | 10 | 12 | 0 | RestoreCityStoredUnits, StoreCityFortifiedUnits |
| seg063_11F0_p2_r | 2 | 2 | 0 | DrawUnitInfoPanel |
| seg066_1208_p2_r | 5 | 0 | 5 | CyclePaletteColors |
| **Total** | **43** | **23** | **24** | 14 functions |

The per-function verdicts are in the unit reports, each in a section "## Round 10 (2026-10-09):
member".

**Inputs.**
* `build/verify-round10/diff/<unit>.diff` for the eleven units, `diff/core-acc.h.diff`,
  `diff/gen-translate.diff`; `build/verify-round10/old` was not needed beyond the diffs.
* `core/acc.h` (`acc_ix1`, `acc_ix1m` l.152-170, `acc_pm` l.172-186, `F_AX` l.271);
  `core/gen/civ_layout.h`; the current units.
* `docs/DESIGN.md` 3.2 l.259-310; `gen/oob_allowlist.py`; `build/cache/oob-allowlist.txt` (as read
  during this round); `docs/inventory/out-of-range.md`; `claude/docs/findings.md` U1, U3, W10;
  `round8-fixes.md` F10-07; `round9-R9A.md` G-2; `round8-R8A.md` N4; the earlier unit reports.

**Methods.** [L] `showfunc.py` for the 13 functions (and 11C0:0395, the caller of one of them),
scratch `v10/R10B_*.txt`; [C] `dumptables.py --table` for the dither-kernel and leader-face tables
(scratch `v10/R10B_dither.txt`, `v10/R10B_faceframes.txt`); [G] generated C; [T] port source
(accessors, translator diff); [D] layout constants; [S] `claude/src/asm` call sites and stores;
[F] docs. `translate.py --show` was run for 1160:2EE0 and 11C0:0000; their `acc_pm`/`acc_ix1m`
lines equal the core lines (seg045 l.271-272, 353-354, 415-416; seg057 l.37, 45, 59, 63).
Nothing was built, compiled, tested or run.

## 1. Address and check identities [T][C]

* `acc_ix1m(obj, i, s, n, moff, k, ms, mn, size, w)` returns `va_ix2(obj, i, s, k, ms, moff)` =
  sel:(off + i*s + k*ms + moff) mod 0x10000. The round-9 form `va_ix(acc_ix1(obj, i, s, n, moff,
  size, 0u), k, ms, 0u)` gives sel:(((off + i*s + moff) mod 0x10000) + k*ms) mod 0x10000. The two
  are equal, and the checks do not change the address.
* `acc_pm(p, k, ms, mn, moff, w)` returns `va_ix(p, k, ms, moff)` = sel:(off(p) + k*ms + moff) mod
  0x10000. The round-9 form `va_ix(fp_add(p, moff), k, ms, 0u)` is the same, since `fp_add` changes
  only the offset modulo 0x10000.
* The nested row form `acc_pm(acc_pm(p, r, rs, rn, OF, 0u), c, 1u, cn, 0u, 1u)` is
  `va_ix(va_ix(p, r, rs, OF), c, 1, 0)`, the round-9 `va_ix(va_ix(fp_add(p, OF), r, rs, 0u), c, 1u,
  0u)`.
* Checks: `acc_ix1m` tests i < n (kind 1, no width relaxation), k < mn, or k ≤ mn for width 0
  (kind 3, `VM_OOB_MEMBER`), then the extent with the access width. `acc_pm` tests k against mn the
  same way, keyed by the member offset (0 for a row). The former `acc_ix1(.., 0u)` tested i ≤ n
  and only the member's start address.
* In all 47 calls the index expressions are variables, register globals, constants or frame-word
  reads, with no side effect, so the unspecified order of argument evaluation cannot change a value.
* Each of the 43 changed lines replaces exactly one round-9 line, the arguments map one to one onto
  the former ones (base, i, GS/GN/SZ, OF, k, member stride), and no other line of the eleven units
  changed [G].

## 2. Index ranges: summary [L][C][S]

No member index (k) of the 47 calls can leave its dimension on any path found: they are constants,
loop variables with constant bounds, or values clamped or bounded by the listing (`nameLength` ≤ 31;
tap < tap count ≤ 12; attendant frame 0..2; face frames 0..13; variant & 3). The G-2 change
therefore adds no record at any site of this batch.

First indexes (i) of the `acc_ix1m` calls that can leave their dimension, with the same records as
before round 10:

| Unit l. | Function | i | Governing marker | Allowlist | Documented |
|---|---|---|---|---|---|
| seg035 l.659 | DrawMapTile | cityIndex = -1 (FindCityAt, U1) | 1110:0C06 | not listed | findings U1 (DrawMapTile, 1110:0745); 0C06 is a pending key of seg035 round-2 N1 |
| seg057 l.37, 45, 59, 63 | RestoreCityStoredUnits | cityIndex = -1 (UpdateUnitSightAndContacts 11C0:0558) | 11C0:0042, 0059, 00DE, 011B | not listed | no (seg057 round-10 N1) |
| seg057 l.116-132 | StoreCityFortifiedUnits | cityIndex = -1 (MoveCivUnits 11F0:0451, homeless unit) | 11C0:0267, 0283, 02F4 | not listed | no (seg057 round-10 N2) |
| seg063 l.482, 485 | DrawUnitInfoPanel | cityIndex = -1 (FindCityAt, U1) | 11F0:4CBB, 4CD1 | listed (U1) | findings U1, inventory U1 11F0:4CC9/4CE9 |

## 3. Items without a unit

**N1 NOTE (coverage of width-0 member elements and rows; the round8-R8A.md N4 class, now in the
G-2 forms).** [T][G][C]
* The translator's width argument `self.w(elem)` is 0u when the indexed element is a structure (FE
  `ACC_T_S`: observed at seg026 l.516 and seg066 l.43-67), and the row of a two-dimensional member
  array is formed by `addr_of(m)` with width 0u (seg045 l.271-272). The accessor then admits k = n, as
  for an address.
* In this batch the element's bytes are then accessed through that address at these sites:
  * seg026 l.516: `fp_add(acc_ix1m(.., tap, 6u, 12u, .., 0u), OF_DitherKernelTap_weight)`, a 2-byte
    read: tap = 12 would not be recorded (it reads the next kernel's first tap, inside
    `g_ditherKernels`);
  * seg045 l.271-272: the row `acc_pm(lpGdat, variant, 3u, 4u, OF, 0u)` admits variant = 4, which
    would read `poseX[4][c]` = `poseY[0][c]`, or for poseY the bytes 0x18..0x1A past the 0x18-byte
    CourtGdat, unrecorded; the column index is checked with width 1;
  * seg066 l.43, 50, 52, 58: `mem_rd32`/`mem_wr32` of a 4-byte PALETTEENTRY through
    `acc_pm(.., 236u, .., 0u)`: entry 236 would not be recorded. (l.67 is a real address, passed to
    AnimatePalette.)
* All these indexes are in range here (tap ≤ 11, variant ≤ 3, entries 0x40..0x47), so no hit is
  missed in this batch. DESIGN.md 3.2 states "Both admit index n for an address (width 0)" and, for
  frame objects, that width 0 for "the address of a structure element" admits n; it does not say that
  a structure element read or copied through `fp_add`/`mem_rd32` counts as an address. A width equal
  to the element size (or 1) for these reads would make the test strict. Coverage note for R10A, not
  a defect of the change.
* Related, by design: a record is keyed (site, key, kind). For poseX (offset 0) the row and the column
  checks of l.271 both use key 0 and kind `VM_OOB_MEMBER`, and l.272's column check also uses key 0,
  so hits on different indexes at marker 1160:2F6F would merge into one record (first address and
  index kept, count summed). The harness triages by site, so no hit would be lost.

## 4. Status of earlier findings

| Finding | Status |
|---|---|
| round9-R9A.md G-2 (member-array indexes unchecked), for the 47 calls of this batch | fixed: each member index is checked, the addresses are unchanged (section 1) |
| seg047_1170_p2.md round 9 N1, N2 (records F74/P8) | applied as F9-01/F9-02 (`round8-fixes.md`); records are R10C's, not re-checked here |
| Other earlier notes of the 14 functions | unchanged (see the unit reports) |

## 5. Not checked

* Run-time behaviour; nothing was built, compiled, tested or run (the headless results are the
  orchestrator's).
* The accessors' and translator's general behaviour, `test_acc`, and DESIGN.md 3.2's counts (40 and
  52 accesses in 22 units): R10A.
* Reachability of a real city-improvement bit without an in-use city (seg057 N1/N2): only DestroyCity
  (1170:02DC/02F4) was read; no exhaustive search.
* Pointer indexing that is not a member array in these units (`kernel[tap]` in
  ErrorDiffuseDitherImage, seg026 l.391-393; `typeCode[k]` in AddType, seg051_1190_p2 l.121-124):
  unchecked by design (DESIGN.md 3.2), no `acc_*` call, outside this round's scope.
* The resource contents read through `lpGdat`/`lpKdat`/`lpLogPalette`/`lpEntry` (only offsets and
  index ranges matter here).

## 6. Deviations from the brief's rules

None.
* Shell commands: `mkdir -p` of the scratch directory; `showfunc.py` (14 addresses), `dumptables.py
  --help` and `--table` (stdout to scratch, no `--json`), `translate.py --show` (two functions,
  stdout to scratch); `wc`, `grep`, `head`, `cat` and `tr` on those scratch files only; one no-op
  `echo`.
* Project files were read only with the Read and Grep tools; the reports were written with the
  Write (this file) and Edit tools.

## 7. Summary

| Function | Address | Verdict | T | R | N |
|---|---|---|---|---|---|
| G-2 width-0 member elements and rows (batch sites; translator coverage) | seg026 l.516, seg045 l.271-272, seg066 l.43-58 | PASS | 0 | 0 | 1 |

The functions (unit reports, round 10):

| Function | Address | Verdict | T | R | N |
|---|---|---|---|---|---|
| AllocDitherWeightTables | 10C8:09A1 | PASS | 0 | 0 | 0 |
| DrawMapTile | 1110:04D0 | PASS | 0 | 0 | 0 |
| DrawLeaderAnimationFrame | 1160:2EE0 | PASS | 0 | 0 | 0 |
| DestroyCity | 1170:0241 | PASS | 0 | 0 | 0 |
| ChooseCityProduction | 1170:05CA | PASS | 0 | 0 | 0 |
| OpenResFile | 1190:0000 | PASS | 0 | 0 | 0 |
| OpenResFileStdio | 1190:0501 | PASS | 0 | 0 | 0 |
| AddType | 1190:13A8 | PASS | 0 | 0 | 0 |
| DrawTileImpl | 11A8:0F56 | PASS | 0 | 0 | 0 |
| RestoreCityStoredUnits | 11C0:0000 | PASS | 0 | 0 | 1 |
| StoreCityFortifiedUnits | 11C0:0159 | PASS | 0 | 0 | 1 |
| DrawUnitInfoPanel | 11F0:468C | PASS | 0 | 0 | 0 |
| CyclePaletteColors | 1208:22B7 | PASS | 0 | 0 | 0 |

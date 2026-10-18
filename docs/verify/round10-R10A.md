# Round 10 (2026-10-09): member — R10A review of the G-2 change (F10-07)

Verifier R10A. Item: F10-07 (`docs/verify/round8-fixes.md` l.66; finding `verify/round9-R9A.md`
G-2). This file reviews the change once: the accessors, the translator branch and the test cases.
The 41 calls of the ten R10A units are checked in the unit reports (section "Round 10
(2026-10-09): member"); their results are collected at the end.

Inputs:
* `build/verify-round10/diff/core-acc.h.diff`, `gen-translate.diff` and the ten unit diffs;
* current `core/acc.h` (l.83-92 `va_ix`/`va_ix2`, l.152-186 `acc_ix1m`/`acc_pm`, l.259-273
  `GF_RDX`/`F_AX`), `platform/w16/vm.h` (l.18-20, 150-171), `platform/w16/vm.c` (l.238-276);
* `gen/translate.py` l.1697-1704, 3629-3704, 3713-3870 and 5180-5225;
* `tests/test_acc.c`;
* `docs/DESIGN.md` 3.2 (l.259-327); `core/gen/civ_layout.h`;
* `verify/round9-R9A.md` (G-2), `verify/round8-R8A.md` (N2, N4, N5).

Method labels: [T] translator or accessor source read; [G] generated C; [C] computation; [F] docs;
[L] listing (`showfunc.py`); [M] Grep over `core/*.c`. `translate.py --show 10B0:168A` was run once
into scratch: its `acc_pm` line equals `core/seg023_10B0_p1_r.c` l.32. Nothing was built, compiled,
tested or run.

## 1. Accessors (`core/acc.h`)

**`acc_ix1m`** (l.152-170) [T][C].
* Address: `va_ix2(obj, i, stride, k, mstride, moff)` = `VM_PTR(sel, off + i*stride + k*mstride +
  moff)`. `VM_PTR` keeps the low 16 bits (vm.h l.20), and 2^16 divides 2^32.
* It therefore equals the round-9 form `va_ix(acc_ix1(VA_g, i, GS, GN, OF, SZ, 0u), k, mstride, 0u)` =
  `VM_PTR(sel, ((off + i*GS + OF) mod 2^16) + k*mstride)`. The selector comes from `obj` in both.
* Checks:
  * `i` against `n` with kind 1 (INDEX1);
  * `k` against `mn`, or `mn + 1` for width 0, with kind 3 (MEMBER);
  * the extent `[obj, obj+size)` with the element width.
* The round-9 form checked `i` against `n + 1` (width 0) and only the member's start address. The new
  form therefore also records `i = n`. That is right, because `g[n].m[k]` lies outside g. The
  round-9 form recorded the EXTENT there anyway.
* Release build: `(void)n, mn, size, width`. Each argument is evaluated once (an inline function).

**`acc_pm`** (l.172-186) [T][C].
* `va_ix(p, k, mstride, moff)` equals the round-9 `va_ix(fp_add(p, moff), k, mstride, 0u)` by the same
  mod-2^16 argument (`fp_add`, vm.h l.239-242).
* It checks `k` against `mn` (`mn + 1` for width 0) under the key `moff` (`VmOobHit.obj`, vm.h
  l.154-155).
* There is no extent check, because the object is unknown. Release: `(void)mn, width`.

**`F_AX`** (l.271) [T][M].
* The width argument is `FS_S_m`, the element stride. For scalar elements this equals
  `ACC_W(FE_S_m)`, e.g. `City.tradeRoutes`: FS 1, FE U8.
* `F_AX` is used only by `F_RDX`/`F_WRX` and `civ_headers.c` l.64/67 (element reads and writes), so an
  element access never admits `mn`. Correct.

`acc_chk_index` records `i >= n` as unsigned (vm.c l.273), so a negative int16 index (a large
uint32) is recorded [T].

## 2. Translator branch (`gen/translate.py` `lval_index` l.3761-3792)

**When it applies** [T]. The branch runs after the global (`g[i]`, `g[i][j]`, `g[i][j][k]`) and
frame (`frame_array`) branches, for a base `e.base` of array type with a declared count n. It has
three forms.

1. **`p->m[k]`** (an arrow Member) → `acc_pm(p, k, stride, n, OF_S_m, w(elem))`.
   * `p` is `rv(m.base)`, near pointers wrapped in `VM_PTR(VM_SEL_DGROUP, ·)`, exactly as
     `lval_member`'s arrow branch (l.3840-3846) forms it.
2. **`x.m[k]`** (a dot Member):
   * with `x = g[i]` (an element of a one-index global array) → `acc_ix1m(VA_g, i, GS, GN, OF, k,
     stride, n, SZ, w)`;
   * with `x` anything but a scalar global identifier → `acc_pm(addr_of(x), …, OF, w)`.
3. **A row of a two-dimensional member array** (`e.base` = `m[j]`, an Index of a Member) →
   `acc_pm(addr_of(m[j]), k, stride, n2, 0u, w)`. The row index `j` is then checked by the
   recursive `lval_index(m[j])`, in one of the forms above, with width 0.

It does not apply to:
* `g.m[k]` of a non-array global structure (the condition at l.3787);
* member arrays without a count;
* the last index of a member array of three or more dimensions.

These fall through to the unchecked tail (l.3793-3801); see N4.

**Order of evaluation** [T]. The index `icode` is computed first (l.3717-3723), unchanged. The member
address follows:

| Form | Round 9 (`addr_of(e.base)` → `lval` → `lval_member`) | Round 10 |
|---|---|---|
| `p->m[k]` | `emit_value_pushes(m)`, `rv(m.base)` | `rv(m.base)` |
| `g[i].m[k]` | `emit_value_pushes(m)`, `rv(b.index)`, no INT conversion (l.3856) | `rv(b.index)`, no INT conversion (l.3783) |
| `x.m[k]` | `emit_value_pushes(m)`, `addr_of(x)` (or the `local[i]` frame branch l.3859-3868) | `addr_of(x)` |
| row | `addr_of(m[j])` | `addr_of(m[j])` (unchanged) |

* Calls, helpers, temporaries and body pushes are emitted in the same order. The only difference is
  the value-push hook on the member node (N2).
* Struct names and offsets come from the same `struct_name`/`self.of` calls.
* For `local[i].m[k]`:
  * the round-9 form was `va_ix(acc_fx1(obj, key, i, s, n, OF, 0, what), k)`;
  * the new form is `acc_pm(acc_fx1(obj, key, i, s, n, 0, 0, what), k, …, OF, w)`.

  Both have the same key, the same width-0 test of `i` and the same address mod 2^16 [C].

**Unit diffs** [G][C]. In all ten R10A diffs each hunk replaces only call text:
* `va_ix(acc_ix1(VA_g, i, GS, GN, OF, SZ, 0u), k, s, 0u)` → `acc_ix1m(VA_g, i, GS, GN, OF, k, s, n,
  SZ, w)`;
* `va_ix(fp_add(p, OF), k, s, 0u)` → `acc_pm(p, k, s, n, OF, w)`.

Values, temporaries and markers are unchanged, which agrees with F10-07's "0 other lines".

**Counts** [M].
* `acc_ix1m(`: 40 occurrences in 11 units.
* `acc_pm(`: 52 occurrences on 49 lines in 11 units (two nested row forms in `seg045_1160_p2.c`
  l.271-272).
* Total 22 units, as DESIGN 3.2 states.
* R9A counted "51 lines in 12 units" for the pointer form. The two extra lines are
  `seg027_10D0.c` l.86-87, `va_ix(fp_add(port, OF_GrPort_reserved00), 0/1, 2u, 0u)`. The recovered C
  writes `((WORD far *)&port->reserved00)[0]` (`claude/src/c/seg027_10D0.c` l.64-65), and
  `reserved00` is a U32 scalar (civ_layout.h l.368-369). This is a cast, not a member array, so the
  translator rightly leaves it (N4).

## 3. Tests (`tests/test_acc.c` l.120-134) [C]

* **l.122-128** (site 0x1000000D).
  * `acc_ix1m(VA_g_cities, 0, 0x1C, 128, 0x17, 3, 1, 3, 0xE00, 0)`: a = 1420:5516. i 0 < 128; k 3 <
    3+1. Extent: 0x5516 + 0 <= 0x54FC + 0xE00. No record.
  * `acc_pm(p = 1420:5550, 3, 1, 3, 0x17, 0)`: 3 < 4, no record.
  * The two `hit(…) == NULL` checks are right.
* **l.129-134** (site 0x1000000E). `acc_pm(p, 3, 1, 3, 0x17, 1)` = 1420:5550 + 0x17 + 3 = 1420:556A =
  `va_ix(fp_add(p, 0x17), 3, 1, 0)`. The test 3 >= 3 records MEMBER under the key 0x17. Right.
* With l.80-81 (the `GF_WRX` address) and l.113-119 (`GF_RDX` k = 3 and `F_RDX` k = 5 recorded), the
  new width argument is covered for both accessors. See N5 for the gaps.

## 4. DESIGN.md 3.2 (l.270-278)

The sentence states the forms, the counts, the date, the unchanged addresses and order, and "Both
admit index n for an address (width 0)". These agree with sections 1-2, apart from N3 and N4.

## Findings

No TRANSLATOR or RECOVERY finding in the reviewed change.

* **N1 NOTE (record keys)** [T]. `acc_pm` keys its record by the member offset. The following share a
  key:
  * member arrays at the same offset in different structures;
  * every row (key 0);
  * a member array at offset 0.

  Within one statement they give one record (the first index, a combined count). The allowlist is
  keyed by marker only, so triage is unaffected. Wording for DESIGN 3.2 ("keyed 0") at most.
* **N2 NOTE (latent, as round8-R8A N2)** [T]. The `p->m[k]`, `g[i].m[k]` and `x.m[k]` forms no longer
  pass the member node `m` through `lval`, so `emit_value_pushes(m)` is not called for it. The row
  form and the round-9 path call it.
  * An annotated body "value" push on `m` would be reported ("annotated body push … (value) not
    emitted", l.1702-1704), and the run would exit 1 (l.5215-5217, 5225).
  * None exists: the diffs change only call text.
  * DESIGN 3.2 l.296-299 names this only for the frame branches.
  * Conversely, `local[i].m[k]` now passes `local[i]` through `lval`. That is harmless.
* **N3 NOTE (coverage, as round8-R8A N4)** [T][G].
  * The translator passes width 0 when the element is a structure or an array (`w()`, l.3823-3827),
    not when the result is only an address.
  * So for `p->m[k].f` / `g[i].m[k].f` (the field is then reached through `fp_add`, l.3869-3870), and
    for the row index `j` of `x.m[j][k]`, index n is admitted and the access out of the member is
    not recorded.
  * By contrast, `g[i].f` (l.3857) and `local[i].f` (l.3864-3868) are checked with the field's width.
  * Example: `lpGodLogPalette->palPalEntry[SI].peRed`, `seg019_1090_s.c` l.79-87 and 151-159 (width
    0, then `fp_add(…, OF_PALETTEENTRY_peRed)`). In this batch every such index stays <= 235 < 236, so
    no hit is missed.
  * DESIGN's "for an address (width 0)" reads as if width 0 meant an address only.
* **N4 NOTE (DESIGN 3.2 wording: unchecked forms not named)** [T][M][G]. "every other member array
  with `acc_pm`" and the "Not checked" list omit five forms:
  * (i) `g.m[k]` of a non-array global structure: `va_ix(acc_po(…), k)`. No such access exists:
    Grep `va_ix(acc_po(` over `core/` gives 0.
  * (ii) member arrays without a count.
  * (iii) the last index of a member array of three or more dimensions.
  * (iv) the cast at 10D0:0067 (`seg027_10D0.c` l.86-87, indexes 0/1 inside the 4-byte member). It
    is not named beside the 1078 and 1030 casts.
  * (v) the listing-evaluated body-push values read raw memory (`t_N = … mem_rd8(VM_PTR(…))`, e.g.
    `seg016_1078_p1.c` l.272, `g_cities[DI].storedUnits[garrisonSlot]` and `g_unitTypes[…]`). They
    are unchecked. At that site the next statement (l.275) reads the same element through
    `acc_ix1m`.

  Also, `acc_pm` checks no extent, so an element of a row is checked only against the row.
* **N5 NOTE (test coverage, as round8-R8A N5)** [C]. Not covered:
  * width 0 with k = mn + 1 (recorded);
  * `acc_ix1m`'s first index i = n, now recorded at any width;
  * the row form (key 0).

  What is checked is right. DESIGN's test_acc sentence (l.299-305) does not name the two new
  checks; "member and pointer-member indexes" covers them loosely.

## Index ranges of the 41 R10A calls (detail in the unit reports)

| Unit | Function | Calls | Range | Out of the dimension? |
|---|---|---|---|---|
| seg007_1030_p1 | ProcessCity 1030:0000 | 6 | storedUnits 0..1, tradeRoutes 0..2 | no |
| seg007_1030_p2 | DrawCityWorldMapPanel 1030:8586 | 1 | 0..2 | no |
| seg008_1038 | EstablishTradeRoute 1038:0D09 | 2 | 0..2 | no |
| seg009_1040_p1 | FoundCity 1040:0000 | 3 | 1, 0; 0..2 | no |
| seg014_1068_p2 | TextBoxSetup 1068:2072 | 2 | lineIndex unbounded | yes: markers 2215, 2237, listed (C9) |
| seg014_1068_p2 | TextBoxDraw 1068:258F | 2 | 0..lineCount-1, unbounded | yes: marker **2609, not listed, undocumented (TRANSLATOR, seg014_1068_p2.md R10-T1)** |
| seg016_1078_p1 | AIAnalyzeCivStrategy 1078:0000 | 5 | 0..1; 0 | no |
| seg019_1090_s | SetGodPaletteEntries 1090:0376 | 5 | dstStart..235 | only for dstStart < 0, which no code path passes (H62); markers 03B7/040A/0428 not listed (NOTE) |
| seg019_1090_s | InitGodPalette 1090:0488 | 5 | 0..235 | no |
| seg019_1090_s | GetColorIndexRGB 1098:01B0 | 1 | 1..235 | no |
| seg023_10B0_p1 | CreateDissolveState 10B0:151B | 6 | 0..duration-1, 0..height-1 | yes: markers 15D3, 1610, 163D, not listed; documented by H61 (BUG comments); latent, item types 12/13 (NOTE) |
| seg023_10B0_p1_r | FindGodPaletteIndexForRGB 10B0:168A | 1 | 0..235 | no |
| seg023_10B0_p2 | DissolveStep 10B0:17E5 | 2 | 0 | no |

Status of round-9 G-2 for this batch: **fixed**. All 41 calls check the member index.
* seg023_10B0_p1.md CreateDissolveState round-3 N2 ("member-array indexing is unchecked") is
  resolved.
* The new records expose one undocumented out-of-range read: TextBoxDraw, marker 2609.

## Not checked

* The 51 calls of the other G-2 units (R10B) and the generated code beyond the calls.
* `check_g2.py` (scratch, not in the repository). Its result was confirmed only through the ten R10A
  diffs.
* Run-time records (nothing run).
* Whether the shipped movie scripts or fade records ever pass a negative `dstStart`
  (seg019_1090_s.md round 10).
* Whether a shipped text reaches more than 64 wrapped lines (seg014_1068_p2.md round 10).

## Deviations from the brief's rules

None.
* The shell ran only `showfunc.py` and `translate.py --show 10B0:168A`, with output into `v10/R10A_*`.
* `grep`, `sed`, `awk`, `wc` and `cut` were used only on those scratch files.
* Project files were read with Read/Grep/Glob only.

## Summary

| Function | Address | Verdict | T | R | N |
|---|---|---|---|---|---|
| acc_ix1m, acc_pm, F_AX (core/acc.h) | l.152-186, 271 | PASS | 0 | 0 | 1 |
| lval_index member-array branch (gen/translate.py) | l.3761-3792 | PASS | 0 | 0 | 2 |
| DESIGN.md 3.2 member-array sentence | l.270-278 | PASS | 0 | 0 | 1 |
| test_acc member-array cases (tests/test_acc.c) | l.120-134 | PASS | 0 | 0 | 1 |

# Round 8 (2026-10-09): translator review, batch R8A

Verifier R8A. This file holds the one-time review of the round-8 translator changes (frame-object
checks and the early segment push) and the batch overview. The per-function results are in the
unit reports (section "Round 8 (2026-10-09)"): `seg039_1130_r.md`, `seg047_1170_p3_r2.md`,
`seg057_11C0_p4_r.md` (segpush) and `seg051_1190_p1.md`, `seg055_11B0_p1_r.md`, `seg055_11B0_p2.md`,
`seg055_11B0_p2_r.md`, `seg056_11B8_p1.md`, `seg056_11B8_p2.md`, `seg057_11C0_p3.md`,
`seg060_11D8.md`, `seg066_1208_p2_r.md`, `seg069_1220_p1.md`, `seg069_1220_p2.md` (frame; the first
two reports also hold their frame objects).

* **Inputs.** `build/verify-round8/diff/gen-translate.diff`, `diff/core-acc.h.diff`, the current
  `gen/translate.py` (l.3679-3824 lvalues, l.4768-4923 `call()`, l.4981-5019 `early_seg_push`,
  l.2334-2346 `after_arg_push`, l.1697-1711 and 5152-5179 findings handling), `old/gen/translate.py`
  (grep only), `core/acc.h`, `platform/w16/vm.h` (VM_PTR/VM_SEL/VM_OFF l.18-20, VmOobHit l.146-170,
  `fp_add` l.238, FR_PTR l.332, DSTR l.335), `platform/w16/vm.c` l.238-276 (`vm_oob_record`,
  `acc_chk_index`), `tests/test_acc.c`, `build/verify-round8/check_fx.py`, `check_fx-output.txt`,
  `frame-objects.txt`, DESIGN.md 3.2 "Checked build" (l.259-299) and 3.4 "The caller pushes the
  argument words" (l.332-347), `diff/DESIGN.diff`.
* **Ground truth.** `showfunc.py` of 1138:0000, 1170:21B3, 11D0:022D and of the 18 frame-object
  functions (scratch only). `translate.py --show 1138:0000`, `1170:21B3` and `11D0:022D` reproduce
  every round-8 hunk of the three segpush units (early pushes and `acc_fx1` sites).
* **Labels.** [L] listing, [G] generated C, [A] annotation, [D] descriptors/headers, [F] docs,
  [C] computation, [S] call sites, [T] translator source.
* Nothing was built, compiled, tested or run.

## 1. Frame-object checks: `frame_array`, `lval_index`, `lval_member` [T][G][C]

**Address equals the old `va_ix` form in every emitted case.** `acc_fx1(obj, key, i, stride, n,
disp, width, what)` returns `va_ix(obj, i, stride, disp)` in both builds (acc.h l.187); the checked
build only adds `acc_chk_index`, which records and never changes the access.
* *One-index array local* `a[i]` (lval_index l.3742-3746): `obj` = `FR_PTR(bp, loc)`, the string the
  old path produced through `addr_of(e.base)` → `lval` (l.3691-3692); the old return was
  `va_ix(FR_PTR(bp, loc), icode, stride, 0u)` (l.3755). New = `va_ix(FR_PTR(bp, loc), icode,
  stride, 0u)`. Identical.
* *Array member of a structure local* `t.b[i]` (frame_array l.3768-3774): `obj` =
  `fp_add(FR_PTR(bp, loc), of(st, field))`, the string the old `lval_member` produced for
  `local.member` (l.3801-3802, 3823-3824, with `st = struct_name(local's type)`). Identical base,
  `disp` 0u.
* *`local[i].member`* (lval_member l.3813-3822): old `fp_add(va_ix(FR_PTR(bp, loc), (uint32_t)(i),
  stride, 0u), OF)`; new `va_ix(FR_PTR(bp, loc), (uint32_t)(i), stride, OF)`. [C] Both are
  `VM_PTR(0x1420, off + i*stride + OF)` with the offset taken mod 0x10000, because
  `((x mod 2^16) + OF) mod 2^16 = (x + OF) mod 2^16` and the uint32 wrap of `i*stride` is
  compatible (2^16 divides 2^32). The selector comes from `obj` in both.
* *Nested forms*: `t.b[i].m` takes the member branch of `frame_array` with `disp` = OF_m (same
  argument as above); `a[i][j]` (none among the 80 objects) checks the row index with width 0 and
  leaves `[j]` to the old `va_ix` around it.
* Non-resident array locals: `frame_array` raises "not stack-resident"; the old `addr_of` raised
  "address of a non-memory lvalue" for the same case. Same outcome (no unit).

**Index computed once, in the same order.** In `lval_index` the index `i`/`icode` is computed at
l.3717-3723 before the frame test, exactly as before; `frame_array` emits no code. In `lval_member`
the new branch computes `i` with the same `rv(b.index, T.INT if signed <= 2 bytes else None)` that
`lval_index` uses for `local[i]`, and the stride from the same decayed element type. The index text
appears once as an argument of an inline function, so it is evaluated once. Read-modify-write
statements keep the address in a temporary as before (e.g. seg039_1130_r.c l.592-593).
`check_fx-output.txt` confirms textually that no line other than the segment pushes changed.

**Record key** `FR_KEY(disp)` = `0xFFFF0000 | (uint32_t)(int32_t)disp & 0xFFFF` [C]: -230 →
0xFFFFFF1A, -18 → 0xFFFFFFEE. It depends only on the declared displacement (array local:
`sym.loc`; member: `sym.loc + field.offset`), so it is the same at every BP and every call. Records
are per (site, key, kind); sites are unique statement markers, so equal displacements in different
functions cannot merge, and selector 0xFFFF cannot equal a global's VA (selectors 0x12xx-0x14xx) or
the small member-offset keys of `acc_pm`.

**Count and width.** `n` is the declared element count (`S(b.ctype).count`); `width` is the element
(or member) size, 0 for structure/array elements, and `acc_chk_index` is given `n + 1` for width 0
(one-past-the-end address admitted), `n` otherwise. Negative int16 indexes convert to large uint32
values and are recorded. For the 130 sites of this batch the width equals the stride (1/2/4).

## 2. `acc_fx1` / `FR_KEY` (core/acc.h l.174-197) [T][D][C]

Correct as stated above. In release builds `(void)key/n/width/what` and the plain `va_ix` result;
`what` is passed through to `acc_chk_index` and stored in `VmOobHit.what` (INDEX1 = 1, MEMBER = 3).
The header comment and DESIGN.md 3.2 (l.273-284) describe the same behaviour (439 sites / 80
objects agree with `check_fx-output.txt` l.39).

## 3. `tests/test_acc.c` frame-object checks [C]

* l.88-89 (both builds): `FR_PTR(0xD58A, -230)` = 1420:D4A4; + 0x1030*2 = 0x2060 → 1420:F504. Right.
* l.90: FR_KEY(-230) = 0xFFFFFF1A, FR_KEY(0x10) = 0xFFFF0010. Right.
* l.130-133 (checked): index 72 width 2 (72 < 73) and index 73 width 0 (73 < 74, one past the end)
  record nothing. Right.
* l.134-140: index 0x1030 at BP D58A and index -1 (0xFFFFFFFF) at BP D400 give one record (same site
  0x1170187C, key, kind) with count 2 and the first index 0x1030 (`vm_oob_record` keeps the first
  index and counts later hits). Right; it shows the key does not depend on BP.
* l.141-144: MEMBER index 16 of 16, width 1 → recorded. Right.
* See N5 for the boundary cases it does not cover.

## 4. `early_seg_push` and its use in `call()` [T][L][G]

* Trigger: a two-word argument (`got` = two 2-byte pushes) whose first (segment) push address is
  not above the lowest listing address of the calls nested in the argument expression
  (`P.walk(arg)`, the same `match`/`used_matches` selection that `call()` itself uses).
* Value: `push ds`/`push ss` → `VM_SEL_DGROUP` (cpu.ds is 0x1420 in game code, DESIGN.md 3.4 l.321;
  stack and data share DGROUP, as `FR_PTR` assumes); `push seg data_X/code_X` → 0xXu; `mov r, seg
  X` directly before `push r` → 0xXu; anything else raises `XlatError` (no silent guess).
* Emission: `stk_push16(value)` with the segment push's address, then `after_arg_push` for that
  address, all before `rv(args[ai])` evaluates the argument (so before the nested call's own
  argument pushes); in the two-push branch (l.4853-4859) the high word is then skipped (`early is
  not None`) and only the offset is pushed at its listing address. The C argument value is
  unchanged (the callee still receives `t_N`).
* The four hunks of this round (1170:2352, 1170:2899, 1138:049E, 11D0:029E) were checked against the
  listing in the unit reports: each listing pushes `ds`/`ss` before the nested call's argument pushes
  (2353/235A, 289A/28A1, 049F, 02A4/02A8) and the generated value `VM_SEL_DGROUP` equals the C
  argument's selector (`DSTR` and `FR_PTR` are DGROUP pointers, vm.h l.332/335).
* [G] Bounded search over `core/*.c`: no `?:` of DGROUP strings computed from a call result
  (`t_N = ((t_M != 0) ? DSTR…`) and no `fp_add(FR_PTR(bp, …), call result)` is followed by a late
  high-word push any more; the 23 remaining `t_N = ((…) ? DSTR(…)` arguments followed by a high-word
  push have conditions without a call or call temporary (memory, register or local reads). This is
  not a proof for every argument shape (N3).

## 5. `check_fx.py` and its output [T][C]

**The method is sound for what it claims.** For every `acc_fx1(...)` of the current units it
rewrites the call into the exact text the round-7 translator emitted for the same lvalue
(`va_ix(obj, i, stride, 0u)` when `disp` is `0u`, else `fp_add(va_ix(obj, i, stride, 0u), disp)`),
asserting 8 arguments, that the key's displacement equals the `FR_PTR` displacement (INDEX1) or
`FR_PTR` displacement + hex member offset (MEMBER), and then compares each whole unit line by line
with the round-7 copy. Textual identity after this inverse mapping plus `acc_fx1 ≡ va_ix(obj, i,
stride, disp)` and the `fp_add` identity of §1 proves that every address is unchanged in release
builds and that nothing else (temporaries, evaluation order, pushes, value pushes) changed. The 38
printed diff lines are exactly the four early segment pushes (3 units), which belong to the other
change. The script does not check counts, strides or widths against the listing; that is the
per-object work in the unit reports. See N6 for two limits that affect no current site.

## 6. Batch overview

All 18 frame objects of the batch (the task names 19; `frame-objects.txt` lists 18 for these 13
units, N7) have the listing's displacement, a stride equal to the element size, no member offset,
and an element count that ends at the listing's next slot, except the three PlayCityCapture/
CivilDisorder/Celebration `frameTiles` and ShowSpaceshipArrival's `frameTiles`, whose 10 entries end
where the listing's accesses end (indexes bounded by `cmp si,0xa` / `% 10` / `animFrame <= 9`), with
12 resp. 28 never-addressed bytes before the next named slot; no access reaches them, so no record
changes either way. No listing access of these functions leaves its frame object (ShowCityView's
grid: verify/seg055_11B0_p1_r.md round 5 N1; DrawUnitStackList's C12 overflow: allowlisted at
marker 11C0:3427 and unreachable in the port, 14 rows); the checked build records nothing for them
on reachable paths. All three segment-push TRANSLATOR findings (CompleteResearch round-5 T1,
ShowNewspaper round-5 T1, SubstituteTextTokens round-5 T2) are fixed.

| Function | Address | Verdict | T | R | N |
|---|---|---|---|---|---|
| ShowNewspaper | 1138:0000 | PASS | 0 | 0 | 0 |
| CompleteResearch | 1170:21B3 | PASS | 0 | 0 | 0 |
| SubstituteTextTokens | 11D0:022D | PASS | 0 | 0 | 0 |
| OpenResFile | 1190:0000 | PASS | 0 | 0 | 0 |
| OpenResFileStdio | 1190:0501 | PASS | 0 | 0 | 0 |
| ShowCityView | 11B0:0000 | PASS | 0 | 0 | 0 |
| PlayCityCaptureAnimation | 11B0:1B63 | PASS | 0 | 0 | 0 |
| PlayCivilDisorderAnimation | 11B0:1FAC | PASS | 0 | 0 | 0 |
| PlayCelebrationAnimation | 11B0:237C | PASS | 0 | 0 | 0 |
| DrawCityViewCitizens | 11B0:1316 | PASS | 0 | 0 | 0 |
| AnimateNuclearExplosion | 11B8:0C3D | PASS | 0 | 0 | 0 |
| ShowCityFoundedAnimation | 11B8:14E5 | PASS | 0 | 0 | 0 |
| DrawUnitStackList | 11C0:3407 | PASS | 0 | 0 | 0 |
| ShowSpaceshipArrival | 11D8:0000 | PASS | 0 | 0 | 0 |
| PlotSmMapSquare | 1210:07AE | PASS | 0 | 0 | 0 |
| MenuZ | 1220:0156 | PASS | 0 | 0 | 0 |
| MenuZSubclassWndProc | 1220:1289 | PASS | 0 | 0 | 0 |

## 7. Findings of the review

No TRANSLATOR or RECOVERY finding.

* **N1 NOTE (records).** [F][T] DESIGN.md 3.4 (l.344) says `early_seg_push` was "added 2026-10-09
  after round 6". The round-7 units in `build/verify-round8/old` still push the word after the nested
  call (check_fx-output.txt), and the round-7 reports keep the findings deferred
  (verify/seg057_11C0_p4_r.md round 7). The generated code changed after round 7. Relatedly,
  `old/gen/translate.py` already contains `early_seg_push` (its l.4790/4945), so
  `gen-translate.diff` does not show it; I reviewed it in the current file. Wording only.
* **N2 NOTE (latent).** [T] The frame branches skip `emit_value_pushes` for nodes the old path
  passed through `lval`: the array base (`a` or `t.b`) in `lval_index`, and the `local[i]` node in
  `lval_member`. An annotated body "value" push attached to one of those nodes would no longer be
  written. None exists (check_fx shows no lost line), and such a push would be reported by l.1702-1704
  ("annotated body push … (value) not emitted"), which makes generation exit non-zero (l.5169-5171).
* **N3 NOTE (scope of `early_seg_push`).** [T] It compares the segment push only with the nested
  calls' `call` addresses. A segment word pushed after the first of two nested calls takes the late
  path, and one pushed between a nested call's own argument pushes and its call would be emitted
  before those pushes; neither case raises an error. The `mov r, seg X; push r` form uses the
  textually preceding instruction without a jump-target check. The function does not compare the
  pushed constant with the C argument's selector. None of this affects the four sites (all `push
  ds`/`ss`, before every nested push; DGROUP pointers); the bounded search of §4 found no remaining
  instance of the two known shapes.
* **N4 NOTE (coverage, by design).** [T][G] The index test covers accesses made through the
  indexed lvalue. Width 0 for structure elements admits index n even when the element's bytes are
  then read through the address (e.g. `&pts[2]` to Polyline, seg011_1050_t.c l.269; palette entries
  to RgbDistanceSquared, seg030_10E8_p3_r.c l.187; both in range), and `&a[n]` of a scalar element is
  recorded with the element width, as the translator's global forms do. Pointer arithmetic on a
  frame object (`tail + strlen(token)`, 11D0:02B4, `fp_add(FR_PTR(bp, -518), t_6)`) is not checked;
  DESIGN.md 3.2 names only copies as unchecked. Not a defect of the change.
* **N5 NOTE (test coverage).** [C] test_acc has no boundary record for index n with width > 0
  (it uses 0x1030 and -1), none for index n+1 with width 0, and no case with `disp` ≠ 0
  (`local[i].member`). What it checks is right.
* **N6 NOTE (check_fx details).** [T] Its diff header labels the round-7 file `core/` and the mapped
  current file `mapped/`. For MEMBER sites whose offset is an `OF_` macro it does not check the key
  against `FR_PTR` + offset; all four MEMBER sites (InitGameColorTables bp-0x26/-0x66, OpenPalaceView
  bp-0x2E/-0x36) use hex constants (`0x0u /* … */`), which it does check.
* **N7 NOTE (batch scope).** The task message names 19 frame objects for this batch;
  `frame-objects.txt` lists 18 for the 13 units (seg055_11B0_p1_r 2, seg055_11B0_p2 3, seg051_1190_p1
  2, seg069_1220_p1 2, the other nine 1 each). All 18 were checked.

## Not checked

* Run-time behaviour, the harness records and the allowlist mechanics (brief: no build or run).
* Frame objects outside this batch (62 objects, other verifiers), except the four MEMBER sites read
  for N6 and the width-0 sites read for N4.
* An exhaustive search for every argument shape where a segment word precedes a nested call (N3).

## Deviations from the brief's rules

* Two shell reads of project paths: `ls -la` of `build/verify-round8/`, `diff/` and `old/` (directory
  listings), and `wc -l` of the 14 report files of this batch (line counts). No other shell read of a
  project file; all other reads used Read/Grep, `showfunc.py` or `translate.py --show`.

## Summary (translator review)

| Function | Address | Verdict | T | R | N |
|---|---|---|---|---|---|
| frame_array / lval_index / lval_member | gen/translate.py l.3713-3824 | PASS | 0 | 0 | 2 |
| acc_fx1 / FR_KEY | core/acc.h l.174-197 | PASS | 0 | 0 | 0 |
| test_acc frame-object checks | tests/test_acc.c l.86-90, 128-144 | PASS | 0 | 0 | 1 |
| early_seg_push in call() | gen/translate.py l.4826, 4853-4859, 4981-5019 | PASS | 0 | 0 | 1 |
| check_fx.py method and output | build/verify-round8/check_fx.py | PASS (sound) | 0 | 0 | 1 |
| DESIGN.md 3.4 record / batch scope | DESIGN.md l.344; frame-objects.txt | PASS | 0 | 0 | 2 |

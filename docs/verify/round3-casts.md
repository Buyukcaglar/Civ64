# Round 3 (2026-10-09): listing-value casts (W3, parts A and C)

Verifier W3 of round 3 (`BRIEF-round3.md`). Part B (the unit diffs) is appended to the six unit
reports: `seg005_1020.md`, `seg023_10B0_p2.md`, `seg025_10C0.md`, `seg026_10C8.md`,
`seg066_1208_p2.md`, `seg069_1220_p2.md`.

Method labels: [L] listing (`showfunc.py`, and `claude/src/asm/*.asm` read with grep);
[G] generated C (`claude/port/core/*.c`); [D] the generator (`claude/port/gen/lsteval.py`, current
and `build/verify-round3/gen-old/lsteval.py` through `diff/gen-lsteval.diff`); [F] rules
(`claude/docs/x64-port-prompt.md` 6.2 and 6.3, lines 1076-1104); [C] computation and proof by
reasoning (no code was run). The scans of part C used awk scripts in the verifier's scratch
directory (`w3_casts.awk`, `w3_vartypes.awk`, `w3_shr2.awk`, `w3_assign.awk`, `w3_regassign.awk`,
`w3_idiv.awk`), which extract each cast's balanced operand, the declared type of a bare identifier
operand in its enclosing function, and the left operand of each `>>`.

## Part A: `gen/lsteval.py` emitters

### Helpers used [D][C]

* `vm_s8(x)` / `vm_s16(x)` (`platform/w16/vm.h` 187-196): mask to 8/16 bits in `uint32_t`, then
  `u < 0x80 ? (int32_t)u : (int32_t)u - 0x100` (resp. `0x8000`/`0x10000`). The `int32_t` value
  lies in -128..127 (resp. -32768..32767), so the final `(int8_t)`/`(int16_t)` conversion is of an
  in-range value (C17 6.3.1.3p1). Defined for every `uint32_t` input; the result is the
  two's-complement reading of the low 8/16 bits.
* `vm_s32(u)` (vm.h 197-200): `u < 0x80000000 ? (int32_t)u : -(int32_t)(0xFFFFFFFF - u) - 1`.
  The cast operand is at most 0x7FFFFFFF; the negation and the `- 1` stay in range
  (u = 0x80000000 gives INT32_MIN without overflow). Defined for every input.
* `cx_sar16(v, n)` (`core/cx.h` 207-218): `u = v & 0xFFFF`; `n &= 31`; `n > 15` becomes 15; bit 15
  set ORs 0xFFFF0000 (sign extension done in unsigned arithmetic); returns `vm_s16(u >> n)`, i.e.
  bits n..n+15 of the sign-extended value. The only C shift is `uint32_t >> n` with n <= 15:
  defined, and below the operand width (rule 6.3).
* `cx_sar8(v, n)` (cx.h 229-233): `cx_sar16((uint32_t)(uint16_t)vm_s8(v), min(n & 31, 7))`, then
  `vm_s8((uint32_t)(uint16_t)w)`. `(uint16_t)` of a negative `int8_t`/`int16_t` is the modular
  conversion (6.3.1.3p2), defined. The 16-bit pattern is the 8-bit value sign-extended; shifting
  it arithmetically by k <= 7 and keeping the low byte is the 8-bit `sar` by k.

### Emitters

| Emitter (current lsteval.py line) | New C expression | 386 semantics | Equal for all inputs [C] | Conversions [F] |
|---|---|---|---|---|
| `movsx` (561) | `(uint32_t)(int32_t)vm_s8(v)` / `...vm_s16(v)`; written with the destination width | sign-extend the 8/16-bit source | yes: vm_sN gives the signed source value; `(int32_t)` widens; `(uint32_t)` of a negative int is mod 2^32 (0xFFFFFF80.., 0xFFFF8000..). `write()` keeps the low 16 bits for an r16 destination (`u16`) or splits low/high words for r32 (`set32`) = `movsx r16` / `movsx r32`. Source width `sw` comes from `value()`: 1 for an 8-bit register or `byte ptr`, 2 for a 16-bit register or `word ptr`. | none implementation-defined; the old `(int8_t)(v)`/`(int16_t)(v)` of a value >= 0x80/0x8000 was |
| `sar r/m8`, `sar r/m16` (635-638) | `((uint32_t)(uint8_t)cx_sar8((uint32_t)(a), n))`, `((uint32_t)(uint16_t)cx_sar16((uint32_t)(a), n))`; n = `imm & 31` or `((uint32_t)(cl) & 31u)` | count masked to 5 bits; arithmetic shift; a count of 8..31 (byte) or 16..31 (word) gives the sign fill; count 0 leaves the operand | yes, for all 256/65536 operands and all 32 counts: clamping to 7/15 changes nothing because a shift by 7/15 already yields the full sign fill; count 0 returns the operand unchanged (`u >> 0`); `(uint8_t)`/`(uint16_t)` of the signed result is its bit pattern, zero-extended by `(uint32_t)`, which is what `write()` stores for width w. The old form `((uint32_t)((int32_t)(intN_t)(a) >> n) & mask)` gave the same value only under an arithmetic right shift and modular signed conversions. | none: no signed conversion of an out-of-range value, no right shift of a negative value, no shift count >= width |
| `cbw` (643) | `(uint16_t)vm_s8(AL)` | AX = sign-extended AL | yes: -128..127 converted mod 65536 gives 0xFF80..0xFFFF / 0x0000..0x007F | none (old `(int16_t)(int8_t)(AL)`: `(int8_t)` of AL >= 0x80 was implementation-defined) |
| `cwd` (646) | `(uint16_t)((vm_s16(AX) < 0) ? 0xFFFFu : 0u)` | DX = 0xFFFF if AX bit 15 set, else 0 | yes: `vm_s16(AX) < 0` iff `(AX & 0xFFFF) >= 0x8000` | none (old `(int16_t)(AX) < 0`) |
| `imul r16, r/m16, imm` (654) and `imul r16, r/m16` (662) | `(uint32_t)((int32_t)vm_s16(a) * (int32_t)vm_s16(b))`, written with width 2 | low 16 bits of the signed 16x16 product | yes: the product lies in -32768*32767 .. 2^30, so no `int32_t` overflow (rule 6.2: signed overflow is a translation error); `(uint32_t)` is mod 2^32; `write()` keeps the low 16 bits, which equal the 386 result. A signed imm8 is printed signed in the listing (e.g. [L] 1040:1825 `imul ax, ax, -0xa`); `imm()` gives `h16(-10)` = 0xFFF6u and `vm_s16` gives -10. | none |
| `imul r32, r/m32` (664) | `(uint32_t)((int64_t)vm_s32(a) * (int64_t)vm_s32(b))` | low 32 bits of the signed 32x32 product | yes: \|product\| <= 2^62 fits `int64_t`; `(uint32_t)` of the `int64_t` is mod 2^32 | none (old `(int32_t)(a)` of a uint32 >= 2^31) |

Unchanged around them [D]: `st.cf = None` after `sar` and `imul` (CF/OF not modelled; a later
`adc`/`sbb` raises Unknown); the 3-operand `imul` still accepts only a 16-bit destination (a 32-bit
one raises Unknown, so the annotation path is used). `cbw` and `cwd` go through `set16`, which also
forgets the 32-bit register's high word; the 386 leaves EAX/EDX bits 16..31 unchanged, so this is
only conservative (a later read of the high word raises Unknown), never a wrong value.

### Instances in the current generated code [G]

| Form | Count | Units |
|---|---|---|
| `(uint32_t)(uint16_t)cx_sar16(` | 1 | seg005_1020 (line 1509) |
| `(uint32_t)(uint8_t)cx_sar8(` | 0 | - |
| `(uint16_t)vm_s8(` (cbw) | 1 | seg069_1220_p2 (line 213) |
| `((vm_s16(` (cwd) | 30 | seg005_1020, seg024_10B8, seg025_10C0, seg026_10C8 |
| `(int32_t)vm_s16(` (imul r16) | 16 | seg005_1020, seg023_10B0_p2, seg054_11A8_p1, seg066_1208_p2 |
| `(int64_t)vm_s32(` (imul r32) | 4 | seg054_11A8_p1 (line 626) |
| `(uint32_t)(int32_t)vm_s16(` (movsx from a word) | 12 | seg023_10B0_p2, seg054_11A8_p1 |
| `(uint32_t)(int32_t)vm_s8(` (movsx from a byte) | 0 | - |

The instances in my six units are checked against the listing in their reports (part B).

### Findings

* **NOTE A1 (generator, pre-existing; not introduced by this change; no instance).** [D] `imm()`
  returns `h16(value)`, a 16-bit mask, for every immediate whatever the operand width, and
  `value()` passes it on for a 32-bit operand. A 32-bit ALU, `mov` or 2-operand `imul` with an
  immediate outside 0..0xFFFF would therefore get a wrong value (e.g. `imul eax, -1` would multiply
  by 65535). [L] Such immediates exist in the listing (10B8:0C7A `add eax, 0xf4240`, 1098:1A7B
  `mov eax, 0x40800002`), but [G] no current listing-value expression contains one: there are no
  `(uint64_t)(0x...u)` terms (the 32-bit add/sub/and/or/xor form) and no `(uint32_t)(0x...u) >> 16`
  high words in `core/*.c`, and the four `(int64_t)vm_s32(` operands are registers. A future run
  through such an instruction would need `imm()` to honour the width (or raise Unknown for w == 4).
* No TRANSLATOR finding: every changed emitter gives the 386 value for every input and has no
  implementation-defined conversion or undefined/implementation-defined shift.

## Part C: remaining implementation-defined conversions in `core/*.c`

Scope [G]: the 56 files `claude/port/core/*.c` (not `core/gen`).

### Casts to signed types

* `(int8_t)`: 0 occurrences. No `(short)`, `(int)`, `(long)`, `(char)` or `(signed ...)` casts.
* `(int16_t)`: 379 occurrences, operands:
  * 157 `RD_ACC_T_U8(...)` (`uint8_t`, acc.h 35) and 59 `RD_ACC_T_I8(...)` (`int8_t`);
  * 131 bare identifiers, all declared `int8_t` (37) or `uint8_t` (94) in their function
    (declaration or parameter);
  * 22 `(uint8_t)(...)` and 6 `W8(...)` (`vm_s8`, `int8_t`);
  * 4 in `civ_headers.c` lines 66-67: `(int16_t)RD_ACC_T_I8(...)`, `(int16_t)RD_ACC_T_U8(...)`
    (narrower types) and `(int16_t)(r + ...)`, whose operand is an `int` sum (see "Remaining
    sites").
  * No `(int16_t)` of a `uint16_t`/`uint32_t` expression remains: 0 matches each for
    `(int16_t)((uint16_t)`, `(int16_t)((uint32_t)`, `(int16_t)(U16(`, `(int16_t)(RD_ACC_T_U16(`,
    `(int16_t)(mem_rd`, `(int16_t)(cpu.` and `(int16_t)(VM_OFF`. (Round-2's OverlayTile
    `(int16_t)cpu.ax` is gone.)
* `(int32_t)`: 2,924 occurrences, operands:
  * 917 integer constants, none with more than seven hex digits (all <= 0x7FFFFFFF);
  * 597 `RD_ACC_T_I16/I8/U16/U8/I32` reads; 453 `REG_SI_I16`/`REG_DI_I16`; 229 `W8/W16/W32`;
    73 groups cast to `(uint16_t)`, `(uint8_t)`, `(int16_t)`, `(int8_t)` or `(int32_t)`;
    43 `IDIV16/IMOD16/DIV16/UMOD16`; 17 `vm_s8/16/32`; 5 `cx_sar16/shl16/shr16`;
  * 575 bare identifiers: `int16_t` 559, `int32_t` 9, `int8_t` 3, `uint16_t` 3
    (seg021_10A0_s.c 59, 73, 155 `rowStride`), `uint8_t` 1;
  * 15 others, each read: `(int32_t)rt___LongMul(...)` x2 (seg026_10C8.c 235, 248),
    `(int32_t)rt_F_LXLSH(...)` x6 (seg026_10C8.c 295-405) and `(int32_t)rt___ftol(...)`
    (seg051_1190_p1.c 725), whose prototypes return `int32_t` (`rt/rt_api.h` 32, 45, 52);
    `(int32_t)((uint32_t)(height))`, `(int32_t)((uint32_t)(width))` (seg024_10B8.c 641), where
    `height` and `width` are `uint16_t` parameters of PicDecompress (line 529), so the operand is at
    most 0xFFFF; four conditional expressions of `int16_t`/`int` constants (seg005_1020.c 392,
    seg026_10C8.c 454, seg054_11A8_p1.c 342, seg061_11E0.c 709).
  * No `(int32_t)` of a `uint32_t` value that can exceed INT32_MAX remains: 0 matches each for
    `(int32_t)(U32(`, `(int32_t)(RD_ACC_T_U32(`, `(int32_t)(mem_rd32`, `(int32_t)(cpu.` and
    `(int32_t)(VM_OFF`; the two `(int32_t)((uint32_t)` are the PicDecompress `uint16_t` operands.
* `(int64_t)`: 19 occurrences, all of `int32_t` operands (`W32`, `RD_ACC_T_I32`, `vm_s32`).
* `REG_SI_I16` / `REG_DI_I16` (`*(int16_t *)&cpu.si`, vm.h 223-225) reinterpret the `uint16_t`
  register object as the exact-width two's-complement `int16_t` (aliasing permitted by C17 6.5p7);
  this is no conversion.

### Right shifts

1,512 `>>` sites ([G], `w3_shr2.awk`; there is no `>>=`). The left operand of each one is:
1,431 a `(uint32_t)` cast, 73 a `(uint16_t)` cast (promoted to a non-negative `int`), 7 a sum of
`(uint32_t)` terms (seg026_10C8.c 260, 414; seg051_1190_p1.c 290, 360, 367 (x2); seg051_1190_p2.c
396), and 1 `(uint16_t)W16(...)` (seg020_1098_p1.c 260). Every operand is preceded by `(`, so no
additive or multiplicative term to its left widens it. No right shift of a signed operand remains;
the sign-propagating shifts go through `cx_sar16` (28 uses in 8 units, one of them the lsteval form
above) and `cx_sar32` (17 uses in 3 units).

### Additional scans (beyond explicit casts)

* Implicit conversion in assignments: 92 statements `NAME = RHS;` where NAME is declared
  `int8_t`/`int16_t`/`int32_t` and RHS starts with an unsigned-looking form (`(uintN_t)`,
  `RD_ACC_T_U16/U32`, `U16/U32`, `DIV16/UMOD16`, `cx_shl/shr`, `mem_rd16/32`, `VM_OFF`, `cpu.`,
  `API_`, `rt_`). All 92 are `API_*`/`rt_*` calls whose prototypes return `int16_t` or `int32_t`.
* Assignments `REG_SI_I16 = NAME;` / `REG_DI_I16 = NAME;`: 89 of `int16_t` variables, 1 of
  `REG_DI_I16` itself (seg023_10B0_p1.c 1518). The parenthesised right-hand sides (14) are
  constants, `int16_t` conditionals, or `(int16_t)` of byte values.
* `IDIV16`/`IMOD16` (cx.h 165-166 apply `(int32_t)(a)` and `(int16_t)(b)`): 81 uses; the
  dividends are `W16`, `RD_ACC_T_I16`, `REG_*_I16` or `int16_t` variables, the divisors constants
  2..0x20, `RD_ACC_T_I16`, `REG_*_I16` or the `int16_t` variable `cols`.

### Remaining sites

| File:line | Expression | Operand can be out of range? |
|---|---|---|
| `civ_headers.c`:66 | `r = (int16_t)(r + (int16_t)RD_ACC_T_I8(...))` | No. `civ_headers_probe` is an accessor-expansion probe "Never called by the game" (file comment, lines 50-51). r is 0 before line 66, so the `int` sum is -128..127. |
| `civ_headers.c`:67 | `r = (int16_t)(r + (int16_t)RD_ACC_T_U8(...))` | No: r is -128..127 and the byte 0..255, so the sum is -128..382. |

No other cast to `int8_t`/`int16_t`/`int32_t` of a possibly out-of-range value, and no right shift
of a negative signed value, remains in `core/*.c`.

### Not checked

* Implicit conversions in function arguments (an unsigned expression passed to an `int16_t`
  parameter) and inside larger expressions: the assignment scans above cover only whole-statement
  assignments with the listed right-hand-side forms.
* Left shifts of negative values and signed overflow in general (not the round-2 kinds).
* `core/gen/*.c` and the platform/rt layers (out of scope by the task).
* The awk scans classify by text; an identifier declared in a nested block with a different type
  than an outer declaration of the same name would be misattributed. I saw no such shadowing in the
  units read for part B.
* Nothing was compiled or run.

## Summary

| Item | Verdict | T | R | N |
|---|---|---|---|---|
| Part A: lsteval.py `movsx`, `sar`, `cbw`, `cwd`, `imul` (16 and 32 bit) | PASS | 0 | 0 | 1 (A1, pre-existing `imm()` 16-bit mask, no instance) |
| Part C: core/*.c casts and right shifts | PASS (no out-of-range site) | 0 | 0 | 0 |

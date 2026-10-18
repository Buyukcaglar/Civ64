# Round 8 verification, batch R8E

Verifier R8E. Scope (task message):
1. "fix F7-13" .. "fix F7-25" of `docs/verify/round7-fixes.md`, against the listing and the round-7 findings they
   address;
2. the orchestrator's `tests/harness/uninit.py` changes: the classes of 1170:187C and 11A0:066D, and
   `check_advance_weights` (the TakeAdvanceFromCiv 1038:0B36 table check);
3. "frame" for StartCivilWar's frame object (bp-0x42).

Items with a unit report are recorded there:

| Item | Report | Result |
|---|---|---|
| F7-13 (OOB comment keys 11F0:13CB, 11A0:0678) | `seg063_11F0_p1.md`, `seg053_11A0_r.md` round 8 | confirmed |
| F7-14 (0E64 "y read") | `seg053_11A0.md` round 8 | confirmed |
| F7-16 (11A0:066D class (b)), F7-17 (F58), F7-23 (TransferCityByRevolt) | `seg053_11A0_r.md` round 8 | confirmed; NOTE N1 (row wording), N2 (F58 outcome completeness) |
| F7-18 (F66), F7-19 (G67 11C0:2270) | `seg057_11C0_p2_r.md` round 8 | confirmed; NOTE N1 (2270 reachability) |
| frame: StartCivilWar bp-0x42 | `seg053_11A0_r.md` round 8 | PASS |
| uninit.py class of 11A0:066D | `seg053_11A0_r.md` round 8 and below | PASS |

This file records F7-15, F7-20, F7-21, F7-22, F7-24, F7-25 and the uninit.py item.

Inputs: `build/verify-round8/diff/` (`DESIGN.diff`, `FIDELITY.diff`, `RECOVERY-ERRATA.diff`, `gen-annot.diff`,
`gen-findings_sites.diff`, `inventory-out-of-range.diff`, the unit diffs), the current `docs/DESIGN.md`,
`docs/FIDELITY.md`, `docs/RECOVERY-ERRATA.md`, `gen/annot.py`, `tests/harness/uninit.py`,
`tests/headless/harness.c` (snapshot format), `core/gen/civ_layout.h`, the round-7 sections of the reports the
items cite (seg031_10F0_r, seg007_1030_p3, seg014_1068_p2_r, seg034_1108_r, seg018_1088_p1, seg018_1088_p2,
seg006_1028, seg057_11C0_p4_r, seg008_1038), `claude/docs/data-structures.md`. Ground truth: `showfunc.py`
dumps in the scratch directory (`v8/R8E_*`) and Grep over `claude/src/asm`; tables with `dumptables.py
--table` (markdown, stdout to scratch). Labels as in the brief. Nothing was built, compiled, tested or run;
the headless and checked-build results cited are the orchestrator's.

## Round 8 (2026-10-09): fix F7-15, F7-20, F7-21, F7-22, F7-24, F7-25

### F7-15: FIDELITY F71 (DX of four window procedures), E18 closed: confirmed
* [F] New F71 (FIDELITY.md l.25, "Memory, handles and the emulated stack", after the register-model entries
  F7..F9): the handled returns NameDialogWndProc 02F7/02FB/0326, CityScreenWndProc 9C59/9CC8,
  PediaDialogSubclassProc 28D2/2919, CustomizeWorldWndProc 074D match the round-7 "dx" tables; the port's DX 0 is
  recorded as a **choice**, class (c), reason "no reader".
* [L] Grep of `call far USER.DispatchMessage`: exactly 15 sites (1008:0F6C, 1030:9B77, 1038:0CFC, 1068:27A6,
  1070:1094, 1098:0359/0395/05F7/06AF, 10B8:073F, 1140:0032, 11E0:09AA/0B32, 11E8:02E5, 1220:18B1); the next
  instruction jumps, loads AX/ES, pushes, or returns (1140:0032: PeekTranslateDispatchMessage, void, no static
  caller; 1098:039A `mov al,1`, a char return). No `call far USER.CallWindowProc` exists (the three mentions are
  comments). SetWindowLong installs at 10F0:0137, 1030:0134, 1068:275C, 1108:033E.
* [L] Every `SendMessage`/`SendDlgItemMessage` result use: only 1098:1B2F, 1B5C, 1C4D, 1C62, 1CDA and 1170:1C35
  store AX (list boxes); SelIText 1100:093E (EM_SETSEL to an edit control) returns void; the senders to these
  windows (10F0:01AB, 1030:9C7D, 1068:27D4/28E6, 1108:0855/086C, 1058:07D1/07E5/08FD/0AAD/0AE1) discard it.
* [F] RECOVERY-ERRATA E18 now says "Closed in round 7 ... FIDELITY.md F71"; DESIGN.md l.616 (CityScreenWndProc)
  and l.627 (CustomizeWorldWndProc) say "closed: no reader of that DX, FIDELITY F71" (the only E18 mentions in
  DESIGN.md); annot.py l.1557 and l.1695 point to F71. No generated text changed (Python comments). The four
  round-7 "dx" NOTE N1s are fixed. The USER behaviour stays a platform fact (inferred), labelled so.

### F7-20 / F7-21: F67..F69 moved, DESIGN Port columns: confirmed
* [F] FIDELITY.diff: F67 and F68 are removed from "Faults and out-of-range accesses" and re-added after F63 in
  "Uninitialised values, class (b)" (FIDELITY.md l.79, 80) with unchanged text except a Ref "moved here from ..."
  (F67 citing seg018_1088_p1 round 7 R7-N2, F68 citing seg018_1088_p2 round 7 R7-N1); F69 likewise (l.81),
  rewritten by F7-22; F70 follows.
* [F] DESIGN.md l.612 (ProcessBarbarianUprisings 0E14): class "(b) by value origin (FIDELITY F67)", Port "FIDELITY
  F67 (no headless test: rule 6.6 requires one only for class (a); ...)". l.624 (DrawMiniPalace): Port "FIDELITY
  F51 (variants[8]) and F68 (the pen word)". Nothing else in the two rows changed (word diff).
* Fixed: seg018_1088_p1 R7-N1 and R7-N2, seg018_1088_p2 R7-N1, seg006_1028 R7-N2.

### F7-22: BuildSeaZoneLinks 1028:1899 row and F69: confirmed
* [L][C] Re-derived: CivLoadGame (BP b, `push ds`, `sub sp,0x10`, SI: SP b-0x14) 01BF..01D7 pushes the count
  dword, the screen buffer and `var_10:mapPageSrc` (b-0x16..b-0x20), far call 01DA; BlockMove BP b-0x26, `sub
  sp,8`; 1100:0247/024A push hpDst (b-0x32, b-0x34), 024D `push [bp+8]` (the source selector) at b-0x36, 0250,
  0253, hmemcpy 0257. After 01DF SP is b-0x14; EmptyStub (01E4) and `push 0`, far call 01E9 give
  BuildSeaZoneLinks BP b-0x1C, so its bp-0x1A is b-0x36, hmemcpy's source-selector argument slot. [L] The
  selector is `g_saveBuffer`'s from GlobalLock 10F8:0057 (01AE..01B9; the version -1 path adjusts it by the
  huge-pointer borrow).
* [F] DESIGN.md l.583: the load path's "last ported writer is BlockMove's push ... the word is that push's slot
  ... which KERNEL code may rewrite (not modelled, unknown)", class "(a) on world generation; (b) on the load path
  (by value origin ..., or a KERNEL frame if hmemcpy rewrites its argument slot; FIDELITY F69)"; "(a), or (b)" and
  "to be confirmed" are gone. F69 adds the caveat: "no observable difference" only if KERNEL leaves the slot,
  otherwise unknown. seg006_1028 R7-N1 is fixed.

### F7-24: FIDELITY F62 (GetAirUnitReturnDirection 11C0:3ABB/3BA8): confirmed
* [L] 3ABB `bestDirection = 0`; 3AC0..3B04 `bestDistance = DWD(x - targetX, y - targetY)` (cdecl: dx pushed
  last); 3B07..3BDA directions 1..8: neighbour (x + DX, y + DY), rejected for another civ's units (3B75..3B80) or
  a foreign city square (3B8E..3BA3); 3BA5..3BC3 `distance = DWD(nx - targetX, ny - targetY)`, taken when
  `cmp ax,[bestDistance]; jge` does not jump (signed, strict). DoubledWrappedDistance 11C8:02A4: `cwd; xor; sub`
  (0x8000 stays 0x8000), |dx| > 40 -> 80 - |dx|, `cmp bx,cx; jle` (signed), 2*major + minor in 16 bits.
* [C] With `targetX` = x, a = |dx| is 0 or 1, and a row offset k (-1, 0, +1) gives c = abs16(D - k), D = targetY - y:
  * D 2..0x3FFE: scores 2c + a below 0x8000, least at k = +1: y+1 (D = 1: the k = +1, a = 0 neighbour scores 0);
  * D 0x3FFF: k = -1 gives c = 0x4000, score 0x8000 + a (-32768/-32767): y-1;
  * D 0x4000: the current square scores 0x8000 (-32768); the neighbours score 0x7FFE + a, 0x8001, 0x8002 + a:
    none lower, result 0;
  * D 0x4001..0x7FFE: every score wraps negative (2c + a - 0x10000), least at k = +1: y+1;
  * D 0x7FFF: k = -1 gives c = abs16(0x8000) = -32768 (signed), `a > c`, score 2a + c = -32768: y-1;
  * D 0x8000: the current square has c = -32768, score 0x8000 (-32768): result 0;
  * D 0x8001..0xFFFF mirror these with E = -D: y-1, except 0xC001 (E 0x3FFF) y+1, 0xC000 result 0, 0x8001
    (E 0x7FFF) y+1.
  F62's cases, its caller effect ([L] 11F0:1071..10E6: status bit 1 and move; else human `and 0xFD`, AI
  DeleteUnit 10DE) and the port's D = 0x11C8 - y = 0x1197..0x11C8 (y+1) are all right. The exceptions assume the
  named neighbour is allowed (F62's "an allowed neighbour"). seg057_11C0_p4_r R7-N1 is fixed.

### F7-25: TakeAdvanceFromCiv 1038:0B36/0B9A row: confirmed
* [D] `dumptables.py --table g_advanceAIWeights` (12B8:0090, 72 x 2): advances 0..66 base 2..8, factor -2..2;
  67..71 base 0, factor 0. `g_civAttributes` (1420:1CA0, 16 x 10): `civilized` (+4) is -1, 0 or 1 in all 16
  records. Minimum weight 0 (advance 59: base 2, factor 2, trait -1; and 67..71).
* [L] GetAIAdvanceWeight 1170:31EC: `cbw` of the factor byte (+1), `imul word [g_playerCivId[player]*10 +
  g_civAttributes + 4]` (low word), plus `cbw` of the base byte (+0), 16-bit add. TakeAdvanceFromCiv 09CF..09D7
  excludes taker or giver 0; 0A5C..0A76 `cmp ax,[bestWeight]; jle` with bestWeight -1, so weights >= 0 write
  `bestAdvance` at the first candidate. [L] The only run-time writer of +4 is 11F0:3F75 (`RandomBelow(3)`, `dec
  ax`); [F] the table is not saved (data-structures.md). DESIGN.md l.619 states exactly this; seg008_1038 R7-N1
  is fixed. The conclusion and class "(a), vacuously" are unchanged.

## Round 8 (2026-10-09): uninit.py (orchestrator)

### Classes of 1170:187C and 11A0:066D
* [F] `PROBES` (uninit.py l.52-66): "cc187C" (marker 1170:187C, -0xE) and "sc066D" (marker 11A0:066D, -0x1A) now
  have class "b", as DESIGN.md l.605 ("(b) by value origin", FIDELITY F70) and l.602 ("(b)", F58) say. For a class
  (b) probe uninit.py only prints the hits and writers (l.264-272), which is what rule 6.6 asks (a FIDELITY entry,
  no headless test). The docstring's "the one class (a) site left after round 7, TakeAdvanceFromCiv 1038:0B36" is
  right: it is the only probe with class "a", and DESIGN.md has no other pure (a) row (BuildSeaZoneLinks' site is
  (b)).
* [P] `build/harness/game/uninit-report.txt` (14:29) predates the uninit.py change (15:26) and still prints
  "class a" for both; the runs uninit-s2..s5 of 15:44 each hold one snapshot (`watchdog.snap`). The table check's
  output line was not seen (the orchestrator reports UNINIT_OK with it).

### check_advance_weights (1038:0B36): tests the right condition
* Condition of the class (a) record [L]: TakeAdvanceFromCiv writes `bestAdvance` at its first candidate iff that
  candidate's GetAIAdvanceWeight is > -1 (signed `jle` at 0A67), i.e. every weight must be >= 0 for every advance
  0..71 (0A7A..0A7E: si 0x47 down to 0) and every trait the taker can have.
* Arithmetic [L][G]: l.141-145 take the base byte at +0 and the factor byte at +1 as int8 (`cbw`), each
  `civilized` word at +4 as int16 (`s16`), the product's low 16 bits as signed (`s16(trait * c)`, the one-operand
  `imul word` keeps AX), then the 16-bit sum as signed (`s16(... + base)`, `add ax,dx`), and flag w < 0. Signedness
  and wrap match 31F6..3235.
* Tables/offsets [D]: civ_layout.h `VA_g_advanceAIWeights` 0x12B80090, GS 2, GN 72, `OF_AdvanceAIWeight_baseWeight`
  0, `..._traitFactor` 1; `VA_g_civAttributes` 0x14201CA0, GS 0xA, GN 16, `OF_CivAttributes_civilized` 4: the
  listing's 12B8:0090/0091, 1420:1CA4 and strides. The snapshot parser (l.102-116) follows harness.c l.203-215
  and 281-298 (five u32 words, data from segment offset 0, size limit+1, padding to 4; kind 1 = data segment);
  the uninit-s2 index shows `segment 12B8 bytes 120` (0x90 + 72*2 = 0x120) and `segment 1420`.
* The trait set is every record's `civilized` plus -1..1 (l.144), a superset of the values of records 0..15.

## Findings

* **N1 NOTE (TakeAdvanceFromCiv 1038:09BC; check_advance_weights and DESIGN.md l.619).** Both rest on the
  taker's `g_playerCivId[taker]` (taker 1..7) being a tribe id 0..15, so that the trait comes from one of the 16
  records; [L] GetAIAdvanceWeight indexes `g_civAttributes` by that word without a bound (3212..321F). The check
  does not test it, although the snapshots hold `g_playerCivId`; the writers (10E8:088A, 08DE, 09BE, 15E1, 164C,
  1989; 11A0:023E, 0273; 1180:03D0, 0D78, 0E20) were not traced here. Premise only; no defect found.

No TRANSLATOR or RECOVERY finding in this file's items.

## Not checked

* Windows 3.1 USER internals for F71 (inferred platform facts, as F71 labels them).
* KERNEL hmemcpy's use of its argument slots (F69 states it as unknown).
* The neighbour filters' results near the map edge for F62 (y-1 = -1 or y+1 = 50); run-time.
* The writers of `g_playerCivId` (N1); the table check's run output (orchestrator).
* F7-01..F7-12 (other batches) and the other hunks of the regenerated units.

## Deviations from the rules

1. Shell reads of project files: one Bash `cp` copied `build/verify-round8/diff/DESIGN.diff` and
   `FIDELITY.diff` into the scratch directory (`R8E_DESIGN.diff`, `R8E_FIDELITY.diff`) to word-diff long rows;
   one Bash `grep -rn 'g_civAttributes' claude/src/asm/*.asm` (a shell search of the listing files); `wc -l`
   of the four owned reports, of `tests/harness/uninit.py` and of `claude/work/AGENT_GUIDE_VERIFY.md`; `ls` of
   `build/verify-round8`, `docs/verify`, `tests/harness`, `build/harness/game` and the uninit-s2..s5 run
   directories (names, sizes and timestamps).
2. One Read of `claude/tools/showfunc.py` (its source, to learn the address-range form); `claude/tools` is not
   among the brief's allowed read paths (only running the script is).
3. `showfunc.py` was run once with `--help` (it printed a Python traceback) and once with 1008:02D0, which is not
   a function start ("function header not found"); `dumptables.py --help` once. `showfunc.py` and
   `dumptables.py --table` outputs (listing dumps with code bytes, table dumps) were written only to the scratch
   directory `v8/` with prefix `R8E_`; `translate.py --show` (11A0:0000, 11C0:223C) output likewise.
4. Shell `grep`/`sed`/`awk`/`cut`/`tr`/`diff`/`fold` ran on those scratch files only.

No `cd`, git, build, test, harness or game run, no other Python, and no file written outside the scratch
directory and this batch's report files.

## Summary

ChooseCityProduction and StartCivilWar rows cover only the uninit.py class item here (StartCivilWar's round-8
verdict with its notes is in `seg053_11A0_r.md`; ChooseCityProduction's F7-01 is another batch's item).

| Function | Address | Verdict | T | R | N |
|---|---|---|---|---|---|
| NameDialogWndProc | 10F0:0266 | PASS | 0 | 0 | 0 |
| CityScreenWndProc | 1030:9C17 | PASS | 0 | 0 | 0 |
| PediaDialogSubclassProc | 1068:282D | PASS | 0 | 0 | 0 |
| CustomizeWorldWndProc | 1108:0705 | PASS | 0 | 0 | 0 |
| ProcessBarbarianUprisings | 1088:0BE9 | PASS | 0 | 0 | 0 |
| DrawMiniPalace | 1088:1A82 | PASS | 0 | 0 | 0 |
| BuildSeaZoneLinks | 1028:162C | PASS | 0 | 0 | 0 |
| GetAirUnitReturnDirection | 11C0:3882 | PASS | 0 | 0 | 0 |
| TakeAdvanceFromCiv | 1038:09BC | PASS | 0 | 0 | 1 |
| ChooseCityProduction | 1170:05CA | PASS | 0 | 0 | 0 |
| StartCivilWar | 11A0:0000 | PASS | 0 | 0 | 0 |

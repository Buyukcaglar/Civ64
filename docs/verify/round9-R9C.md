# Round 9 verification, batch R9C: fix F8-16..F8-24

This batch checks the fixer F8's record items F8-16..F8-24 (`docs/verify/round8-fixes.md`) and the
fixer's skipped-items paragraph. Two reports hold the results:

| Report | Items |
|---|---|
| `seg047_1170_p2.md`, "Round 9 (2026-10-09): fix F8" | F8-18 (port P8). It also gives ChooseCityProduction's verdict, which counts the F8-16 and F8-17 results recorded below. |
| This file | F8-16, F8-17, F8-19..F8-24, the skipped-items paragraph |

## Round 9 (2026-10-09): fix F8-16, F8-17, F8-19, F8-20, F8-21, F8-22, F8-23, F8-24

Verifier R9C. Nothing was built, compiled, tested or run.

**Inputs.**

| Source | What was read |
|---|---|
| `round8-fixes.md` | F8-16..F8-24 and the skipped-items paragraph |
| `round8-R8D.md` | N1..N5 and G-1 |
| `seg047_1170_p2.md` | round 8, N1 and N2 |
| `seg044_1158_r.md` | round 8, N1 |
| `seg044_1158.md` | round 8, N1 and N2 |
| `round7-fixes.md` | the F7-09 and F7-12 rows, "For the orchestrator" item 2, and "Later corrections (round 8)" (l.161-171) |
| `round6-fixes.md` | "Later corrections (round 7)" (l.61-68) |
| `round7-R7D.md` | the F6-23 section |
| `DESIGN.md` 3.4 | the 1495 row (l.616), 443F (l.620), 13BF (l.623), 187C (l.625) and 0F57 (l.630) rows, and the bullet "Ported last writers kept as C variables" (l.651-660) |
| `FIDELITY.md` | F55, F56, F57 (l.75-77), F65 (l.37), F70 (l.85) |
| `inventory/out-of-range.md` | P6 (l.181) |
| `gen/annot.py` | the "1030:0000", "1158:08E7" and "1158:140C" entries |
| `build/verify-round9/diff/seg044_1158.diff` | the whole diff |
| `build/harness/game/uninit-report.txt` | empty when read: the orchestrator is regenerating it |

**Ground truth.**
* [L] `showfunc.py` was run on these functions (scratch `v9/R9C_*`):

  | Address | Function |
  |---|---|
  | 1158:08E7 | OpenPalaceView |
  | 1158:140C | DrawPalaceSectionPiece |
  | 11A8:15CE | DrawTileToPortPixels |
  | 1170:05CA | ChooseCityProduction (see `seg047_1170_p2.md`) |

* [S] `claude/src/asm`, read with Read and Grep:

  | File | What was read |
  |---|---|
  | seg007_1030 | ProcessCity 6862..6CCA, and every label in it with its "from" list |
  | seg044_1158 | FreePalaceSectionSprites 17AD..180F |
  | seg018_1088 | 010A, 01B1 and 01C6 |

* [G][D] `core/gen/civ_layout.h` (`g_palaceSprites`) and the DESIGN.md 3.1 DGROUP layout (BSS
  0x5146..0xB4BD).

### F8-16: FIDELITY F70 and inventory P6, the wrapping index ranges (seg047_1170_p2.md round 8 N1)

* [L] The read is 187C `mov bx,[bp-0xE]`, then 18AE `shl bx,1`, 18B0 `lea ax,[bp-0xE6]`, 18B4
  `add bx,ax`, 18B6 `mov ax,ss:[bx]`. `items` is 73 words: bytes 0..0x91 from bp-0xE6.
* [C] Let r = (2*index) mod 0x10000. r is even, so the word lies wholly inside `items` exactly when
  r <= 0x90, that is r < 0x92.
  * r = 2*(index mod 0x8000), so the condition is index mod 0x8000 <= 0x48.
  * That gives index 0x0000..0x0048 or 0x8000..0x8048, element `index & 0x7FFF`.
  * The arithmetic needs bp-0xE6 .. bp-0xE6+0x92 not to cross 0x10000. That holds, because the stack
    lies inside DGROUP's limit.
  * The port's selector 0x1030 gives r = 0x2060, which is outside `items`. With BP 0xD58A this is
    1420:F504, beyond 0xE4BF.
* [F] F70 and P6 state the two ranges and `items[index & 0x7FFF]` ("a candidate below itemCount or an
  unwritten slot"). The host question (does Windows assign segment 1030 such a selector?) is marked
  not checked. F70's Ref column cites round-8 N1/N2 and F8-16/F8-17.

**Fixed.** Remark, not counted: F70 says the ranges "wrap it back" into `items`. Only the
0x8000..0x8048 range wraps; 0x0000..0x0048 lies inside `items` directly. The stated condition and
result are right.

### F8-17: the DESIGN.md 3.4 187C row and F70, ProcessCity 6A43/6C2F (seg047_1170_p2.md round 8 N2)

* [L] 6869 `cmp [bp+mode],0`; 686D `je 6872`; 686F `jmp 7780`.
  * Every label in 6872..6CCA has its "from" list inside 686D..6CA8 (Grep of the label lines).
  * So 6872..6CCA is entered only from 686D, which means mode 0 only.
* [L] The first call, at 6A43:
  * 69DD..69F6 tests `g_humanCivsMask` for the owner; 69F8 `jmp 6A97` skips the call for a human
    owner;
  * the AI owner reaches 69FB, then 6A38..6A43 `call far ChooseCityProduction`;
  * 6A4B..6A55 store AL into `City+9` with no test.
* [L] The second call, at 6C2F:
  * 6B94..6B99 tests the mask; a human owner gets the message box (6B9B..6BE4);
  * the AI owner reaches 6BE7, then 6C24..6C2F calls ChooseCityProduction;
  * 6C37..6C41 store AL with no test.
* [F] The 187C row now names both calls as "further turn-loop calls that can reach 187C". It gives
  the reasons: the 6872..6CCA fragment, 6869 mode 0, 69DD..69F8 / 6BE7 AI owner, AL stored
  unchecked, last writers at S-0x18 not traced. It keeps them apart from the city-screen calls
  599D/5D89.
* [F] F70 names "ProcessCity's mode-0 AI calls 1030:6A43/6C2F" among the untraced callers.

**Fixed.**

### F8-19: round7-fixes.md "Later corrections (round 8)", the DrawPalaceSectionPiece callers (seg044_1158_r.md round 8 N1)

[L] OpenPalaceView makes ten calls of DrawPalaceSectionPiece:

| Call | `section` pushed | `levelForY` pushed |
|---|---|---|
| 0D62, 0D8A, 0E57, 0E73, 0EA5, 0ED7, 0F6A | `push si` (0D5C, 0D84, 0E51, 0E6D, 0E9F, 0ED1, 0F64) | `[bp+level]`, written at 0CE1 in the loop |
| 0DF7 | 0DEF `push [bp+leftEndSection]` | `[bp+level]` (0DF2) |
| 0E45 | 0E3D `push [bp+rightEndSection]` | `[bp+level]` (0E40) |
| 0FE5 | 0FD1 `push [bp+leftEndSection]` (stale) | 0FDE `g_palaceSectionLevel[leftEnd]` |

* The 0DF7 call runs only under the guard 0DAF..0DB5, `leftEndSection + 1 == si`. The 0E45 call runs
  only under 0DFD..0E03, `rightEndSection - 1 == si`.
* The shape-1 case (0DAF) runs only for si in {2, 3, 5, 6} (round-8 frame check of
  `seg044_1158_r.md`).
* So the pushed values are si-1 in {1, 2, 4, 5} and si+1 in {3, 4, 6, 7}, all within 1..7, and only
  0FE5 can pass a stale `section`.
* The correction states exactly this: seven `push si`; 0DF7/0E45 the neighbouring end sections with
  the loop section's `level`; the conclusion holds. It covers both places the sentence occurs:
  F7-09 (l.44) and "For the orchestrator" item 2 (l.134).
* A Grep of `claude/port` (outside `build/`) finds the sentence only in `round7-fixes.md` and
  `seg044_1158_r.md`. FIDELITY, DESIGN and the annot (the "1158:08E7" and "1158:140C" comments) do not
  repeat it.

**Fixed.**

### F8-20: FIDELITY F65 outcomes (seg044_1158.md round 8 N2)

* [L] DrawPalaceSectionPiece reads the sprite word at 1497..14A3 `push word [bx+g_palaceSprites]`,
  the last push and therefore the first argument `hTile`, then calls DrawTileToPortPixels at 14A7.
* [L] DrawTileToPortPixels:
  * 15F4 `cmp [bp+hTile],0; jne 161A`;
  * 15FA..1601 push 'No Tile Data!' and call ShowErrorMessage;
  * 1609..1617 is a dead unlock, then `jmp 1A82` (return), so nothing is drawn;
  * 161A `push [bp+hTile]`, 161D `call far KERNEL.GlobalLock`, with the result not checked (the port
    test at 1628 concerns the port, not the tile).
* [F] F65 now lists both outcomes:
  * the 0 word, with the error box, ShowErrorMessage 11A8:1601, and nothing drawn;
  * the non-handle word passed to GlobalLock unchecked (11A8:161A), with the invalid-handle result
    marked host behaviour, not checked.

  The Ref column cites round-8 N2 and F8-20.

**Fixed**, with a wording point (N1 below).

### F8-21: FIDELITY F55 and the DESIGN.md 3.4 1495 row (round8-R8D.md N1)

* [F] The 1495 row says "a Windows API frame can be the last writer: it is when the KERNEL/USER frames
  of GetFreeSpace/GetFreeSystemResources reach the word (their depth is unknown, FIDELITY F3), and
  otherwise these ported writers remain".
* [F] F55 says "otherwise it can be the frame of GetFreeSpace/GetFreeSystemResources ... : it is when
  that KERNEL/USER frame reaches the word (its depth is unknown, F3), and otherwise the earlier ported
  writers listed in DESIGN.md 3.4 remain".
* F55's outcome column keeps "When the API frame reaches the word ... (**not modelled**, F3)".
* [L] The order in a turn is ProcessCivCitiesAndAiRates 1088:010D, CheckLowResourcesWarning 01B1,
  then MoveCivUnits 01C6. So the earlier ported writers precede the API calls, as the row says.
* The 0xE-byte distance comes from R8D [L]; it was not re-derived.
* The "is"/"can be" overclaim is gone. The class (b) stays, by the rule's definition. The annot entry
  "1030:0000" says only "calls GetFreeSpace/GetFreeSystemResources with SP 0xE bytes above the word";
  it makes no "is" claim.

**Fixed.**

### F8-22: the 443F and 0F57 probe figures (round8-R8D.md N2, N3): wording and method only

As the task says, the numbers are not checked: `uninit-report.txt` is being regenerated, and it was
empty when read.

* **Method.** Both rows label the figures as port model probe data:
  * "self-consistency";
  * "the later S2-S5 run, `build/harness/game/uninit-report.txt`".

  Both keep the earlier run's figures, labelled as such:
  * 443F: "an earlier run had 312 hits, 85 stale";
  * 0F57: "an earlier run had 8 stale hits".

  Both cite round8-R8D.md N2/N3. That matches F8-22 and the earlier rows' labelling (1495 and 7BB5,
  "a later run (S2-S5)").
* **443F wording.** The stale split 38 + 26 + 12 + 11 + 1 adds up to the stated 88. The writers named
  are:
  * the GetTileImprovements prolog;
  * AIAnalyzeCivStrategy code 1078:127A;
  * the PlayerKnowsAdvance prolog;
  * the GetBodyId prolog.

  They are consistent with the row's traced writer. The port keeps `improvementsHere` as a C
  variable, so the probe sees the word of the GetTileImprovements frame that 11C0:04AF calls just
  before the 04B7 store (R8D's [L], round8-R8D.md F7-03; not re-read here). One phrase is unclear:
  N2 below.
* **0F57 wording.** "23 hits, all stale, writer the UpdateCivPowerRanking prolog, no API above"
  matches the row's last path, "otherwise the saved DI of UpdateCivPowerRanking (1088:02AD)".
* When the orchestrator refreshes the figures, it should also update the "the later S2-S5 run" label
  if the new report comes from a different run.

**Fixed** (wording and method), with N2.

### F8-23: round7-fixes.md "Later corrections (round 8)", F7-12 (round8-R8D.md N4)

* [F] The correction says:
  * "F7-12: the closure is established for random worlds only";
  * the round6-fixes.md round-7 sentence (round6-fixes.md l.63-66, quoted correctly: column 79
    always ocean, row 49 always Arctic or Tundra "on the maps the game builds") "holds on random
    worlds; the EARTH map and save files were not checked, as F7-12's row says".
* That is R8D N4's suggested wording.
* It is recorded in round7-fixes.md because round6-fixes.md is not the fixer's file. round6-fixes.md
  is unchanged.
* A Grep of `claude/port` (outside `build/`) finds the column-79 / row-49 statement in no FIDELITY,
  DESIGN or annot text.

**Fixed.** Remark, not counted: on random worlds the closure still rests on two inferences that
round7-R7D.md records:
* GenerateRivers was not traced. F7-12's row repeats this.
* Later in-game terrain changes are not traced. This one is in round7-R7D.md only.

"Established" is R7D's own "confirmed for random worlds", and the two inferences are not lost.

### F8-24: DESIGN.md 3.4 bullet "Ported last writers kept as C variables" (round8-R8D.md N5)

* [F] The bullet now says "these sites are class (b) in any case, through an API frame on other paths
  (1030:1495, 1078:443F) or on the same path (11F0:13BF: the CheckLowResourcesWarning API calls follow
  the `squareY` store, so `squareY` is the last writer only where their frames do not reach the
  word)". It cites round8-R8D.md N5.
* [L] For 13BF: ProcessCivCitiesAndAiRates (1088:010D, whose ProcessCity frames store `squareY`)
  precedes CheckLowResourcesWarning (01B1) on the same path, and both precede MoveCivUnits (01C6).
  "Only where" is a necessary condition, so it stays true even where the 1088:0137..01AC callees (not
  checked, F57) write the word later.
* The other two sites:
  * 1495: the API path is the one where the previous MoveCivUnits stored no `unitX` (row l.616);
  * 443F: the API path is the re-entry after a visible move, through the DelayTimerTicks pump
    (row l.620).

  Both are other paths, as the bullet says.

**Fixed.**

### The skipped-items paragraph of round8-fixes.md

| Skipped item | Check |
|---|---|
| round8-R8D.md G-1 | F8-15 is the fix. Its accessor and translator are the "ix3" item, outside this batch. |
| seg044_1158.md round 8 N1 | Covered. [G] `diff/seg044_1158.diff`: l.66 is now `acc_ix3(VA_g_palacePieceYOffsets, DI, ..., style, ..., pieceType, GS3_, GN3_, 0u, SZ_, 1u)` under marker 1445 (l.63), which already carries `/* OOB: port P5 */` (l.64). The accessor itself is verified under "ix3", not here. |
| R8D's remark on the cost of the C-variable locals | It was a remark, not a finding: a choice for the orchestrator (DESIGN.md 3.4 bullet: "**choice**"). Skipping it is right. |
| The "Not checked" note of `seg047_1170_p2.md` round 8 on `uninit-report.txt` printing class a for cc187C | A report regeneration, not a record. The report is being regenerated now and was empty when read, so the class it will print was not checked. |
| "The inventory hand section has no P7 row" | Resolved after the paragraph was written: P7 is at `inventory/out-of-range.md` l.182, between P6 and P8. Its content belongs to F8-13, which is not checked here. |

### Findings (round 9)

**N1 NOTE (DrawPalaceSectionPiece, F65 wording: "a section whose sprites are not loaded").**
* F65 classes a section whose sprites are not loaded under "a sprite word that is not a handle".
* [L] FreePalaceSectionSprites (1158:17AD) does not clear the handle:
  * for a loaded slot, 17E4 calls `TileDispose(g_palaceSprites[slot][half])`;
  * 17FE clears only `g_palaceSpriteLoaded[slot][half]`;
  * the handle word in `g_palaceSprites` is left as it was.
* [D] `g_palaceSprites` is 1420:B12E (`civ_layout.h`), inside the zeroed BSS 0x5146..0xB4BD
  (DESIGN.md 3.1).
* So a section never loaded in the process has the word 0, which gives the 'No Tile Data!' outcome. A
  section loaded and freed earlier keeps the freed handle, which gives the GlobalLock outcome.
* Both outcomes are listed in F65; only the attribution in the parenthesis is imprecise. Wording only.
  The port performs the listing's read and call.

**N2 NOTE (ChooseAiUnitOrder, 443F row: "that API").**
* The row says "the GetTileImprovements prolog (38 without, 26 with that API above)".
* "That API" has no antecedent in the sentence. GetTileImprovements is a game function, and the
  nearest API mention is the DelayTimerTicks pump earlier in the row. The reader cannot tell
  whether the probe means that pump or any API frame.
* The other two splits say "API above".
* Suggested: "with an API frame above", or name the API if the probe identifies it.
* Labelled self-consistency data; no effect on the port.

No TRANSLATOR or RECOVERY finding.

### Earlier findings addressed by these items

| Finding | Item | Status |
|---|---|---|
| round8-R8D.md N1 (ProcessCity, API last-writer overclaim) | F8-21 | fixed |
| round8-R8D.md N2 (ChooseAiUnitOrder, outdated 443F figures) | F8-22 | fixed in wording and method; the refreshed numbers are the orchestrator's (not checked); N2 above |
| round8-R8D.md N3 (ShowHistorianReport, outdated 0F57 figure) | F8-22 | fixed in wording and method; numbers not checked |
| round8-R8D.md N4 (ApplyGlobalWarming, record overgeneralizes) | F8-23 | fixed |
| round8-R8D.md N5 (MoveCivUnits, bullet wording) | F8-24 | fixed |
| round8-R8D.md G-1 (generic, three-index globals) | F8-15 | not this batch ("ix3") |
| seg044_1158_r.md round 8 N1 (OpenPalaceView, F7 record wording) | F8-19 | fixed |
| seg044_1158.md round 8 N1 (DrawPalaceSectionPiece, third index unchecked) | F8-15 | covered (l.66 is `acc_ix3` under marker 1445); accessor not this batch |
| seg044_1158.md round 8 N2 (DrawPalaceSectionPiece, F65 outcomes) | F8-20 | fixed; wording point N1 above |
| seg047_1170_p2.md round 8 N1, N2 (ChooseCityProduction) | F8-16, F8-17 | fixed; counted in `seg047_1170_p2.md` round 9 |

### Not checked

* The probe numbers of the 443F and 0F57 rows: `uninit-report.txt` was empty when read (being
  regenerated).
* The depth of the KERNEL/USER frames (F3; host code).
* The distances 0xE and 0x16 bytes and the frame offsets T-0x24 and T-0x2C. They come from R8D's
  [L], and only the call order was re-read.
* F8-13's P7 row content; the ix3 accessor and translator (F8-15).
* DrawTileToPortPixels with an invalid non-zero handle (host behaviour).
* The EARTH map and save files (F8-23).
* Runtime behaviour; unchanged generated code.

### Rule deviations (whole R9C batch)

* **Shell reads of a project file.** At the start I ran a shell `wc -l` and `grep -n "^## "` on
  `docs/verify/seg047_1170_p2.md` (read only) to list its sections. Every later read of a project file
  used the Read and Grep tools.
* **Scratch files.** The listing dumps and the `translate.py --show 1170:05CA` output went to the
  scratch directory `v9/R9C_*` only. They contain original code bytes and were not deleted. Shell
  `grep`/`sed`/`cut`/`wc`/`head` ran only on those dumps.
* `mkdir -p` and `ls` were run on the scratch directory, which already existed.
* Two shell `echo` no-op commands touched no file.
* No other Python than `showfunc.py` and `translate.py --show`. No `cd`, git, build, test, harness or
  game run. No file was written outside this report and the round-9 section of
  `seg047_1170_p2.md`.

### Summary (round 9, R9C items in this file)

Counts: this round's findings plus earlier findings still open. Earlier notes confirmed fixed are not
counted, nor are round-5 notes, as in rounds 6-8. ChooseCityProduction's verdict, which includes F8-16
and F8-17, is in `seg047_1170_p2.md` round 9.

| Function | Address | Verdict | T | R | N |
|---|---|---|---|---|---|
| ProcessCity | 1030:0000 | PASS | 0 | 0 | 0 |
| MoveCivUnits | 11F0:0000 | PASS | 0 | 0 | 0 |
| ChooseAiUnitOrder | 1078:1480 | PASS | 0 | 0 | 1 |
| ShowHistorianReport | 1188:0DB8 | PASS | 0 | 0 | 0 |
| OpenPalaceView | 1158:08E7 | PASS | 0 | 0 | 0 |
| DrawPalaceSectionPiece | 1158:140C | PASS | 0 | 0 | 1 |
| ApplyGlobalWarming | 1028:1AFD | PASS | 0 | 0 | 0 |

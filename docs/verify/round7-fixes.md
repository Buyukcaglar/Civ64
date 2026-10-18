# Round 7 fixes (fixer F7)

Fix list: the orchestrator's round-7 plan (items F7-01..F7-25), taken from the "Round 7 (2026-10-09)"
sections of the verifier reports R7A..R7D (seg047_1170_p2, seg007_1030_p1, seg007_1030_p2,
seg063_11F0_p1, seg016_1078_p2, seg041_1140_r2, seg050_1188_p1_r, seg044_1158_r, seg069_1220_p1_r,
seg055_11B0_p1_r, round7-R7D, seg053_11A0_r, seg053_11A0, seg008_1038, seg057_11C0_p4_r,
seg057_11C0_p2_r, seg018_1088_p1, seg018_1088_p2, seg006_1028 and the four "dx" sections
seg031_10F0_r, seg007_1030_p3, seg014_1068_p2_r, seg034_1108_r). Each item was checked against the
listing (`claude/src/asm` through `showfunc.py` and the Read/Grep tools, 2026-10-09) before
writing; where a statement rests only on the verifier's reading it says so.

Changed files: the generator inputs `gen/annot.py` (comments only; `SOURCE_ERRATA` untouched) and
`gen/findings_sites.py` (MANUAL), and `docs/DESIGN.md` (3.4 "UNINIT last writers" rows and the
E18 mentions only), `docs/FIDELITY.md`, `docs/RECOVERY-ERRATA.md` (E18) and
`docs/inventory/out-of-range.md` (the hand section and two hand-kept MANUAL rows). Not changed:
`gen/translate.py`, `docs/verify/round6-fixes.md` (outside this fixer's files; see F7-12, F7-18,
F7-23), the 3.2 "Checked build" and 3.4 "The caller pushes the argument words" paragraphs of
DESIGN.md. Nothing was built, tested or run apart from `gen/translate.py --show` / `--check`,
`claude/tools/showfunc.py` and `claude/tools/dumptables.py` (stdout only).

Labels: [L] listing, [V] the verifier's reading cited without re-tracing it, [P] port model probe
data (self-consistency: observations of the port, not of the original), "inference" and
"platform fact (inferred)" as in the reports. Classes are rule 6.6's (DESIGN.md 3.4): (a) every
last writer is ported game code and the emulated stack reproduces the value; (b) a Windows API
frame can be the last writer, a writer is not modelled, or the ported writer stores a value
Windows assigns ("by value origin"); (c) register leftovers.

## Items

Files: A = gen/annot.py, S = gen/findings_sites.py, D = DESIGN.md 3.4, F = FIDELITY.md,
R = RECOVERY-ERRATA.md, O = inventory/out-of-range.md. "Units" are the `core/` units whose
generated text changes (the orchestrator regenerates them; `--show` diffs below).

| Item | Function | Address | Change | Files | Units | Status |
|---|---|---|---|---|---|---|
| F7-01 | ChooseCityProduction | 1170:187C (read 18B6) | Class (a) -> (b) by value origin. [L] 17FE is the only store of bp-0xE; 187C `mov bx,[bp-0xE]; jmp 18AE`, 18AE..18B6 `shl bx,1; lea ax,[bp-0xE6]; add bx,ax; mov ax,ss:[bx]`. [L] ProcessCity 2732..273D calls ChooseCityProduction (BP S-0xA, `bestIndex` S-0x18); CivHasActiveWonder (call 1030:1AC8, BP S-0xA, DS, `sub sp,2`, SI, DI) always calls PlayerKnowsAdvance (7E69 `mov si,1`, loop to 8), whose far call 7E7D pushes CS at S-0x18; 274F stores AL as the city's production. Without the Hoover Dam only ClampInt 1B7E follows [V: R7A step 4]; with it GetBodyId 1AF9 and 1B36 both run [L 1AD5..1B41] and GetScreenBufferPixel's saved BP+1 remains [V]. annot comment `class b` plus `/* OOB: port P6 */` in the 187C list (a comment keyed at 18B6 would land at marker 18AB: `governing_marker` takes the nearest preceding marker, and 18AE..18B6 is shared with the 18AB path). DESIGN row rewritten with the per-path writers, the untraced ReselectCityProduction path (S-0x26) and other AI callers, class (b), "UNINIT and OOB port P6 at 187C; FIDELITY F70". FIDELITY F70 (class (b) table): outcome SS:(BP-0xE6+2*index) mod 0x10000 outside `items`; port 0x1030 at BP D58A gives 1420:F504 > 0xE4BF (fault policy); original selector-dependent; Hoover path a stack offset (address not computed per path; inference); [P] 230 S4/S5 hits, all after 17FE. Inventory P6 row | A, D, F, O | seg047_1170_p2 | done |
| F7-02 | ProcessCity; MoveCivUnits; AddWorkedSquareYields | 1030:1495; 11F0:13BF; 1030:7BB5 | 1495 row: "with no PlayerKnowsAdvance in between (human civ)" removed (PlayerKnowsAdvance 1170:01FD runs inside 1088:010D, before CheckLowResourcesWarning 01B1 [V R7A N1]); writers listed latest first, including the ported frames of 1088:0137..01AC (AIAnalyzeCivStrategy bp-0x1C, DrawStatusCivPanels bp-0x1E, RebuildAiObjectives'/ProcessCivGovernmentAndDiplomacy's callees) and the untraced first-city-of-a-turn path (1088:0222..0B64); "city-screen APIs 5..853 bytes above" and the 190/182 figures moved into one sentence labelled "port model probe data ... 2026-10-09 11:2x run"; the later S2-S5 figure (523) cited. 13BF row: the frames between two MoveCivUnits calls now include ProcessCivCitiesAndAiRates (1088:010A..0112) with ProcessCity's `squareY` store 1030:0FA6 at T-0x2C [V R7A N1], all before the API calls. 7BB5 row: probe figures labelled as the 11:2x run, the later 6823-hit run cited. F55/F57: the paths where the original's last writer is a local the port keeps as a C variable (`unitX`, `squareY`) added, with the port's differing word (F55: the previous civ's last `bestIndex` can be -1, inference) | D, F | none | done |
| F7-03 | ChooseAiUnitOrder | 1078:443F | [L] 11F0:0259 calls UpdateUnitSightAndContacts (`x`..`redraw`, 10 argument bytes; BP M-0x10), which stores `improvementsHere` (bp-0x12 = M-0x22) unconditionally at 11C0:04B7 (both 03C1 branches reach 04A9); DelayTimerTicks calls at 11F0:3864/3881. The 0261..0703 path and the "every AI unit" condition (adviceShown) are [V R7B]. Records corrected: last writer at a unit's first decision = the 04B7 store, not modelled (the port keeps `improvementsHere` as a C variable); after a visible move the DelayTimerTicks pump 6 bytes above; CheckLowResourcesWarning never last. Class and outcome unchanged | A, D, F | none (Python comment only) | done |
| F7-04 | ChooseAiUnitOrder | 1078:26BE | DelayTimerTicks pump (11F0:3864/3881, PeekMessage entry SP M-0x1C, 0x34 above `temp`) added to the DESIGN row, F56 and the annot comment | A, D, F | none (Python comment only) | done |
| F7-05 | RunPalaceImprovement / OpenPalaceView | 1158:088F; 0F94 | F60 "never drawn" qualified: [L] 0F8A..0F94 reads `g_palaceSectionVariant[leftEndSection]` after the loop with no range test; a stale 9..11 reads the garden words (and, if the word is 1, DrawPalaceSectionPiece reads `variant[section]` at 143B); latent (F48) | F | none | done |
| F7-06 | ShowHistorianReport | 1188:0F57/0F8D | [L] 1220:00F5..00FD: ShowTextDialog (BP T-0xE; DS T-0x10, `sub sp,6`, SI T-0x18) pushes four words (T-0x1A..T-0x20) and calls GR_DialogOpen far: return CS at T-0x22 = `values[0]`; 0105..0107 `jne 0149` skips MenuZ, GR_DialogClose and RepaintMainWindows. F61 and the DESIGN row: the GR_DialogOpen-failure writer (return CS of 1220:00FD) and the "status window when it exists, otherwise ..." qualifier [V R7B R7-N1] added | D, F | none | done |
| F7-07 | OpenPalaceView | 1158:0DAF | [L] loop si = 1..7 (0CB9, 0F82); shape (0CE4..0D2E): 2 for si = 4, case 1 only for si 2, 3 (left neighbour built) and 5, 6 (right neighbour built); guards 0DAF..0DB5 / 0DFD..0E03 give 0DCF index 1, 2, 4, 5 and 0E1D index 3, 4, 6, 7. `/* OOB: port P5 */` removed from 0DAF (annot "1158:08E7"; UNINIT kept); annot comment, P5 row, F65 and the DESIGN row list 0F8A only for OpenPalaceView | A, D, F, O | seg044_1158_r | done |
| F7-08 | OpenPalaceView | 1158:0DAF, 0F8A | [L] 10E8:0E58..0E88 sets levels 0..11 to -1, 0E8A..0EBA sets 3..5 (and 9..11 via +0xC) to 0; the only other direct store is 1158:0883 (`newLevel`; Grep found no other mov/arith store to `g_palaceSectionLevel`). The stale 0DAF/0F8A reads need levels 1..3 all -1: latent (loaded save or a call before setup) stated in F48, F65, P5, the DESIGN row and the annot comment | A, D, F, O | none beyond F7-07 | done |
| F7-09 | DrawPalaceSectionPiece | 1158:142A, 143B, 1451, 146B, 14A3 | [L] 140C..14B6: reads indexed by `section` (SI) / levelForY (DI) / style / pieceType / half with no range test; the only caller with a stale `section` is 0FE5 (the other nine calls pass the loop's built section and its own `level`). `translate.py --show 1158:140C`: markers 1421, 1432, 1445 (1451 and 146B), 1472 (14A3). New annot entry "1158:140C" with `/* OOB: port P5 */` keyed at 142A, 143B, 1451, 14A3 (146B shares 1451's marker; one comment). P5 row and F65 extended | A, D, F, O | seg044_1158 | done |
| F7-10 | FrameRectLogical | 1220:10B6 | [L] 1018:0BA8..0BC1 and 1080:0C67..0C87 push 0xF in monochrome mode; 1188:0D14..0D1A and 11BB..11C0 push 16 + civ unconditionally; seg050_1188's last `g_monochromeMode` test is 0A08, inside ShowPowerGraph (07AD..0B3E). F64 and P4 corrected; annot comment refined | A, F, O | none (Python comment only) | done |
| F7-11 | ShowCityView | 11B0:1029 | [L] frame: `savedMessage` bp-0x190, `grid` bp-0x110; 108A..10A7 draw `ss:bp-0x190` with font 8. F43: a caption with no zero byte runs into `grid`; from 256 bytes it reaches the C12 overruns (GetScreenTextWidth 10D8:05C2/05D2, DrawScreenTextWithShadow 10D8:036D), F33's outcomes; reachability not shown | F | none | done |
| F7-12 | ApplyGlobalWarming | 1028:1B99 | F6-23's description of the column-80 / (80, 50) bytes ("territory owner 0..7, city-site values 8..15", "the second site-value copy") is withdrawn: [L] ComputeCitySiteValues (1028:0FB4 summary) writes only map x 2..77, y 2..47, so the layer bytes at column 80 are not site values. [L] 1B4D..1B53 run the neighbour loop only for terrain <= 3; [V R7D] random worlds keep column 79 ocean (two-square water border, step-2 growth; GenerateRivers not traced: inference) and rows 0/49 Arctic or Tundra, so the column-80 and row-50 neighbours are never read there and the 1B99 index is 0 or a terrain colour 0..15. EARTH and save files not checked. F6-23's text lives only in round6-fixes.md, which this fixer does not own: the correction is recorded here | none | none | done (record only) |
| F7-13 | MoveCivUnits; StartCivilWar | 11F0:13BF -> 13CB; 11A0:066D -> 0678 | The annot OOB comments are keyed to the accesses: "11F0:13CB": `/* OOB: findings G48 */` and "11A0:0678": `/* OOB: findings G35 */`, split from the 13BF / 066D lists (UNINIT and BUG stay there). `--show`: both land at the same markers (138C, 066D) and print `/* 11F0:13CB */` / `/* 11A0:0678 */`; the MANUAL entries for 13CB/0678 stay deduplicated (the statements already name G48/G35). DESIGN rows, F59 wording | A, D, F | seg063_11F0_p1, seg053_11A0_r | done |
| F7-14 | TransferCityToCiv | 11A0:0E64 | [L] 0E64 `mov al,es:[bx+g_cities+5]` is the y read (x is 0E76). MANUAL reason and its hand-kept inventory row: "y read" | S, O | none (MANUAL reasons are not emitted) | done |
| F7-15 | NameDialogWndProc, CityScreenWndProc, PediaDialogSubclassProc, CustomizeWorldWndProc | 10F0:0266, 1030:9C17, 1068:282D, 1108:0705 | New FIDELITY F71 ("Memory, handles and the emulated stack" table, next to the register-model entries; it is a class (c) DX leftover, not class (b)): no reader. [L] checked by F7: 15 `call far USER.DispatchMessage` sites (the instruction after each overwrites AX, pushes, jumps back into a loop or returns); SetWindowLong installs at 10F0:0137, 1030:0134, 1068:275C, 1108:033E; no CallWindowProc call in the listing (only comments). The SendMessage result uses and the per-message DX values are [V R7D]; the USER behaviour is a platform fact (inferred). RECOVERY-ERRATA E18 closed with a pointer to F71; DESIGN 3.4 E18 mentions (CityScreenWndProc, CustomizeWorldWndProc rows) point to F71; annot comments too | A, D, F, R | none (Python comments only) | done |
| F7-16 | StartCivilWar | 11A0:066D | Class (a) -> (b). [L] RestoreBlockXY 1110:0448..04CF has no on-screen test and always calls DrawMapTile (04AB); DrawMapTile copies `visibleRect` (bp-0x22, `right` = bp-0x1E) with SCOPY@ at 1110:0D32 only when `g_autoFlushToWindow` != 0 (0CF6..0CFE); 1208:0D5C/0FC4/0FDD are GetClientRect calls into the window data. [L] 11F0:3083..30B6 -> 310B is the hidden-move path, 30FD..3103 the Enemy Moves off path. The DESIGN row rewritten (condition, writer, client-width value, hidden path, the R7-N1 initial-SP caveat); annot `class b`; Port column without the headless test; F58 | A, D, F | seg053_11A0_r | done |
| F7-17 | StartCivilWar; TransferCityToCiv | 11A0:05F0..06BC; 0E3A..0EAC | [L] 05E8 `rebelPop = 0`; the loop 05F0..06B9 adds the record's size (0678) and transfers it (068C) on every pass with no farther city, and tests `rebelPop*9/(setting+3) < g_civTotalCitySize[civ]` (0692..06B7); the victim's total is reduced only at 06BC. [L] WinMain 1008:02E1..02E6: `keyState` at bp-0x116, GetKeyboardState once. [C] 0x54FC + W16(0x1C*0xD6F7) = 0xD800 and 0xD8AE - 0x116 = 0xD798, so the record is keyState[0x68..0x83] (size [0x6F], x/y [0x6C]/[0x6D], owner store [0x73]); the frame chain giving V = 0xD6F7 and WinMain's BP 0xD8AE is [V R7C] under DESIGN 3.1's inferred SP. [L] SetTileOwner 1110:171F reaches the map only through Get/SetScreenBufferPixel, whose 11E8:0DDF..0DF1 / 0E2A..0E3C tests ignore coordinates outside 320x200: bounded ("not traced" closed; in-buffer byte effects not traced); 0EA3 adds the size to `g_civTotalCitySize[newCiv]`. F58 rewritten (hang with key-state 0, toggle bit ends it, down bit until the 16-bit product wraps); the class (a) headless test withdrawn | F | none | done |
| F7-18 | DeleteNonLandUnitCallback; DeleteUnit; DeleteLandUnitCallback | 11C0:22BB; 16A4; 2270 | [L] `g_unitTypes` at 1420:1A38, record size 0x16, so type -1 is 1420:1A22; `seg133_1420.asm` gives the words 1A24 = 43 and 1A32 = 60 (inside `g_improvementTypes`). [L] DeleteUnit 1710 `cmp capacity,0`, 172A link test, 1766 GetTerrainType, 177D ForEachUnitInStack(.., DeleteLandUnitCallback); ForEachUnitInStack 1F10 fetches the link before the callback, stops at -1, the start unit or after 10 callbacks; DeleteLandUnitCallback 2270 tests `domain` and deletes only land units; DeleteNonLandUnitCallback 22BB deletes when `domain` != 0. The BSS zeroing and InitCivilization leaving the link (never-used slot link 0) are [V R7C]. F66 rewritten (always DeleteUnit; the continued walks; the nested land walk; RemoveUnitFromTile on a slot in no ring not traced) and F6-24's "link 0xFF" inference withdrawn there and here | F | none | done |
| F7-19 | DeleteLandUnitCallback | 11C0:2270 | MANUAL ("G67", "OOB", "11C0:2270") and the hand-kept inventory row; `--show 11C0:223C`: `/* OOB: findings G67 */ /* 11C0:2270 */` at marker 2270 | S, O | seg057_11C0_p2_r | done |
| F7-20 | ProcessBarbarianUprisings; DrawMiniPalace; BuildSeaZoneLinks | F67, F68, F69 | Moved from "Faults and out-of-range accesses" to "Uninitialised values, class (b)" (after F63); each Ref notes the move | F | none | done |
| F7-21 | ProcessBarbarianUprisings; DrawMiniPalace | 1088:0E14; 1088:1D00 | 0E14 Port column: "headless test" replaced by FIDELITY F67 (no headless test for class (b)); DrawMiniPalace Port column cites F51 (variants[8]) and F68 (the pen word) | D | none | done |
| F7-22 | BuildSeaZoneLinks | 1028:1899 | DESIGN row: load path described as class (b) only (by value origin, or a KERNEL frame if hmemcpy rewrites its argument slot); "(a), or (b)" and "to be confirmed" removed; world generation stays (a). F69: the hmemcpy caveat added (the "no observable difference" holds only if KERNEL leaves the slot; otherwise unknown). Per R7C [L] (re-derived frame chain), not re-traced by F7 | D, F | none | done |
| F7-23 | StartCivilWar | 11A0:066D row | [L] 11B8:148A lies in TransferCityByRevolt (11B8:0F26..14E5), called by DiplomatEntersCity 11B8:0702 and 1040:0FC4. DESIGN row corrected (with F7-16). round6-fixes.md F6-09 keeps the old wording (not owned) | D | none | done |
| F7-24 | GetAirUnitReturnDirection | 11C0:3ABB, 3BA8 | [L] DoubledWrappedDistance 11C8:02A4: `cwd; xor; sub` abs (0x8000 stays 0x8000), `cmp bx,cx; jle` signed, 2*major + minor; 3ABB..3BC0: current square scored first, `distance < bestDistance` signed; caller 11F0:1071..10E6 (0: AI DeleteUnit 10DE, human flag cleared). Worked case by case: D = selector - y; y+1 for D 1..0x7FFF, y-1 for 0x8001..0xFFFF, except D = 0x4000/0x8000/0xC000 (no direction), 0x3FFF/0x7FFF (y-1), 0xC001/0x8001 (y+1). R7C lists y - selector = 0x3FFF; F7 found the symmetric 0x7FFF case too (0x8001). F62 rewritten | F | none | done |
| F7-25 | TakeAdvanceFromCiv | 1038:0B36/0B9A row | `dumptables.py --table g_advanceAIWeights`: advances 0..66 base 2..8, factor -2..2; 67..71 base 0, factor 0 (minimum weight 0). The `civilized` range and its writer 11F0:3F75 are [V R7C]. DESIGN row corrected; the conclusion (>= 0, class (a) vacuously) unchanged | D | none | done |

Counts: 25 items; 24 applied, 1 recorded here only (F7-12, because the text it corrects is in
round6-fixes.md). Nothing is deferred.

### Classifications changed

| Site | Before | After | Basis |
|---|---|---|---|
| ChooseCityProduction 1170:187C | (a) | (b) | value origin: a code selector (far-call CS) on the traced turn-loop path (uninit.py already b) |
| StartCivilWar 11A0:066D | (a) | (b) | value origin: the map window's client width (GetClientRect) on the Enemy Moves off path; the visible path's writer is a modelled game frame |
| BuildSeaZoneLinks 1028:1899 | site (b), row text "(a), or (b)" on the load path | site (b); load path (b) | wording made consistent with F69 |

### Withdrawn statements

* round6-fixes.md F6-23: the description of the column-80 and (80, 50) bytes (F7-12).
* round6-fixes.md F6-24: "a free slot's link byte is 0xFF, so the walk visits only that slot"
  (F7-18; F66).
* round6-fixes.md F6-09 and the old DESIGN row: "DiplomatEntersCity 11B8:148A" (F7-23) and "when the
  origin square is on screen" (F7-16).
* The round-6 class (a) headless tests for 11A0:066D (F7-17) and 1170:187C (F7-01).
* The round-6 records naming CheckLowResourcesWarning as a possible last writer of
  ChooseAiUnitOrder `bestIsAttack` (F7-03).

## Generated-text effect (`translate.py --show`, compared with the same command before the edits)

| Unit | Function | Hunk |
|---|---|---|
| seg047_1170_p2 | ChooseCityProduction | 187C `class a` -> `class b`; `/* OOB: port P6 */  /* 1170:187C */` added |
| seg053_11A0_r | StartCivilWar | 066D `class a` -> `class b`; the G35 OOB comment's address `/* 11A0:066D */` -> `/* 11A0:0678 */` (same marker) |
| seg063_11F0_p1 | MoveCivUnits | the G48 OOB comment's address `/* 11F0:13BF */` -> `/* 11F0:13CB */` (same marker 138C) |
| seg044_1158_r | OpenPalaceView | `/* OOB: port P5 */  /* 1158:0DAF */` removed |
| seg044_1158 | DrawPalaceSectionPiece | `/* OOB: port P5 */` added under markers 1421, 1432, 1445, 1472 (sites 142A, 143B, 1451, 14A3) |
| seg057_11C0_p2_r | DeleteLandUnitCallback | `/* OOB: findings G67 */  /* 11C0:2270 */` added at marker 2270 |

Every hunk is a comment; no generated code changes. ChooseAiUnitOrder (seg016_1078_p2),
FrameRectLogical (seg069_1220_p1_r) and TransferCityToCiv (seg053_11A0) produce identical text
(only Python comments or a MANUAL reason changed). `translate.py --check` over all units: exit 0,
no output (no error, no finding).

## translate.py observations

* A comment keyed at an address goes to the nearest preceding statement marker
  (`governing_marker`). For F7-01 the access 18B6 lies in 18AE..18B6, shared by the 187C and 18AB
  paths, so a key at 18B6 would have put P6 at marker 18AB; the P6 comment is therefore in the
  187C list and prints `/* 1170:187C */`. For F7-13 the access addresses 13CB and 0678 have the
  same governing markers as 13BF and 066D, so the keys could move.
* `gen/oob_allowlist.py` matches only `/* OOB: (findings|port) Xn */` exactly, so the cited access
  address cannot be added inside the comment text.

## Rule deviations

* Shell reads of project files: one `cp` copied the six edited files (`gen/annot.py`,
  `gen/findings_sites.py`, `docs/DESIGN.md`, `docs/FIDELITY.md`, `docs/RECOVERY-ERRATA.md`,
  `docs/inventory/out-of-range.md`) into the scratch `f7/backup/` before editing, as the task
  required; one later `cp` copied the edited `docs/FIDELITY.md` into scratch (`fid_now.md`) to list
  its entry ids with `grep`.
* Listing dumps (`showfunc.py` output with the instruction-byte column, i.e. original code bytes)
  and a `dumptables.py --table g_advanceAIWeights` dump were written to the scratch directory `f7/`
  only; they were not deleted and can be removed. A Grep of `claude/src/data/seg133_1420.asm`
  displayed two lines of original data bytes (1420:1A18, 1A28); only the two word values 43 and
  60 are quoted in the records.
* `dumptables.py --help` was run once (stdout only).
* Shell `grep`/`awk`/`cut`/`sed`/`diff`/`wc` ran only on scratch files. No `cd`, no git, no build,
  test, harness or game run, no Python other than the allowed scripts; no file outside the
  writable list was written.

## For the orchestrator

1. Regenerate the six units of the table above (comment-only hunks); build (default and checked)
   and test as usual.
2. Regenerate the OOB allowlist: new markers 1170:187C (P6), 1158:1421, 1158:1432, 1158:1445,
   1158:1472 (P5, DrawPalaceSectionPiece), 11C0:2270 (G67); removed 1158:0DAF (P5); 11A0:066D and
   11F0:138C unchanged. The DrawPalaceSectionPiece entries also cover any other out-of-range
   access at those markers; the other nine call sites pass the loop's built section and its own
   level (listing), so none is expected.
3. Regenerate the inventories: the generated part will move the annot rows G48 11F0:13BF -> 13CB
   and G35 11A0:066D -> 0678 (each then sits next to the MANUAL row of the same site: two sources
   for one site) and emit the hand-kept G67 11C0:2270 and G35 0E64 ("y read") rows as edited here;
   append the hand section ("Sites found by the port", now P1..P6) again.
4. `tests/harness/uninit.py`: 11A0:066D a -> b (the class (a) headless test for it is withdrawn;
   a test of the visible path would hang under the default key state unless it sets
   keyState[0x6F] or bounds the loop, F58). 1170:187C is already b. `docs/inventory/uninit.md`
   (not this fixer's file) lists both sites (its rows for 1170:187C and 11A0:066D); regenerate or
   update it with the new classes.
5. round6-fixes.md is not edited (outside this fixer's files): F6-09's "DiplomatEntersCity
   11B8:148A", F6-23's column-80 description and F6-24's "link 0xFF" inference are superseded by
   F7-23, F7-12 and F7-18; add a pointer there if the record should say so.
6. Open decision (extends round 6 item 6): the original's last writers at 1030:1495 (`unitX`,
   MoveCivUnits bp-0x1C), 1078:443F (`improvementsHere`, UpdateUnitSightAndContacts bp-0x12) and
   11F0:13BF (`squareY`, ProcessCity bp-0x10) are locals the port keeps as C variables; making them
   stack-resident (5.2 item 2(e)) would reproduce those writers (the sites stay class (b) because
   of their API paths).
7. Not traced, recorded as such: the 1495 first-city-of-a-turn and city-screen paths; the 187C
   ReselectCityProduction path and other AI callers; the 066D writers with `g_autoFlushToWindow`
   0 and on hidden moves; the Hoover-path address at 18B6; the in-buffer effects of SetTileOwner
   with keyState x/y; UnlinkUnitFromStack on a slot in no ring; the terrain of square (0,0).
8. The probe figures in DESIGN 3.4 (1495, 7BB5, 443F, 26BE, 0F57) and FIDELITY (F55, F66, F70)
   are the port model's (self-consistency); the "11:2x run" label for the 1495 and 7BB5 figures is
   taken from the item list.

Later corrections (round 8; the rows above are kept as written): F7-09 and "For the orchestrator"
item 2 say that the other nine calls of DrawPalaceSectionPiece pass the loop's built section and
its own `level`. Seven of them do (`push si`); 0DF7 and 0E45 pass the neighbouring end sections
`leftEndSection` (si-1) and `rightEndSection` (si+1) under the guards 0DAF..0DB5 / 0DFD..0E03, with
the loop section's `level` (OpenPalaceView 0DEF..0DF7, 0E3D..0E45). Both values stay in 1..7, so
the conclusion holds: only 0FE5 can pass a stale `section` (verify/seg044_1158_r.md round 8 N1;
round8-fixes.md F8-19). F7-12: the closure is established for random worlds only. The sentence of
round6-fixes.md "Later corrections (round 7)" that column 79 always stays ocean and row 49 is
always Arctic or Tundra "on the maps the game builds" holds on random worlds; the EARTH map and
save files were not checked, as F7-12's row says (verify/round8-R8D.md N4; round8-fixes.md F8-23,
recorded here because round6-fixes.md is not the round-8 fixer's file).

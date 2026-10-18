# Round 5 fixes (fixer F5)

Fix list: the consolidated round-5 plan (waves 1-2 and verifiers V16..V40, including the V37 and
V38 sections), applied to the generator inputs `gen/annot.py` (annotations and `SOURCE_ERRATA`
E8..E17) and `gen/findings_sites.py` (EXCLUDE, STATEMENT, MANUAL), and to the documents
`docs/DESIGN.md`, `docs/FIDELITY.md`, `docs/RECOVERY-ERRATA.md` and
`docs/inventory/out-of-range.md`. `gen/translate.py` was not changed. Nothing was built or run
apart from `gen/translate.py` (`--check`, `--show`, generation) and the print mode of
`gen/findings_sites.py`. Each regenerated unit was compared with a copy taken before the round
(`diff -u`, and a second diff with the temporaries `t_N` renumbered away); every hunk was read.

Classes are rule 6.6's: (a) every last writer is ported game code (needs a headless test),
(b) a Windows API frame can be the last writer (FIDELITY entry), (c) a register left by the
caller. "class open" means the trace did not settle the class; the row says what was traced.

## Items

Verifier ids are the plan's; "W" is the waves 1-2 summary. Files: A = gen/annot.py,
S = gen/findings_sites.py, D = DESIGN.md 3.4, F = FIDELITY.md, R = RECOVERY-ERRATA.md,
O = inventory/out-of-range.md. Units are the regenerated `core/` units.

| Verifier | Function | Address | Change | Files | Units | Status |
|---|---|---|---|---|---|---|
| W, V06 | ProcessCity | 1030:1495 | `bestIndex` (bp-0x8) stack-resident; `/* UNINIT: findings 8.2 1030:1495, class a */` | A, D | seg007_1030_p1 | applied (behaviour: the first food-first test reads the stack word) |
| W, V06 | ProcessCity | 1030:576B | `key` (bp-0x64) stack-resident; UNINIT class b at 576B | A, D, F | seg007_1030_p1 | applied (behaviour: prevKey from the stack word) |
| W, V06 | ProcessCity | 1030:5848 | `blinkColor` (bp-0x90) stack-resident; UNINIT class b | A, D, F | seg007_1030_p1 | applied (behaviour, cosmetic) |
| W, V06 | ProcessCity | 1030:6196 | `listRowSlots` (already resident): UNINIT class b at marker 6160 | A, D, F | seg007_1030_p1 | applied (comment only) |
| W | ProcessCity | 1030:0954, 0FC4, 176D, 6609 | MANUAL U4 | S | seg007_1030_p1 | applied |
| W | ProcessCity | 1030:1B14, 1B2E | MANUAL G1 (wonder 15 reads of g_cities[0x80]) | S | seg007_1030_p1 | applied |
| W | ProcessCity | 1030:273D, 2CC6, 2DC5 | MANUAL G11 | S | seg007_1030_p1 | applied |
| W | ProcessCity | 1030:19D8, 1E47 | EXCLUDE H58, G19 (context citations) | S | seg007_1030_p1 | applied |
| W | ProcessCity | (annot comments) | stale CAVEAT/NOTE text ("still stops at 1557", hoisting) corrected | A | none (Python comments) | applied |
| W | ProcessBarbarianUprisings | 1088:0E14 | `uninitCiv` stack-resident; UNINIT class a; CheckLowResourcesWarning 11E8:0075 `freeMem` stack-resident (last writer on the quit path, 5.2 item 2(e)) | A, D | seg018_1088_p1, seg062_11E8_r | applied (behaviour) |
| W | UpdateCivPowerRanking | 1088:128F | UNINIT findings 8.2 1088:1267, class c | A, D | seg018_1088_p1 | applied (comment only) |
| W | MoveCivUnits | 11F0:13BF | `terrainType` (bp-0x24) stack-resident; UNINIT G48 class a, BUG G48 kept | A, D | seg063_11F0_p1 | applied (behaviour) |
| W | MoveCivUnits | 11F0:1A3C, 0DD5..20C9, 2F4F, 3789, 26E1..2847, 406C..4242, 2331, 23AA | MANUAL G52, U1, G50, H18 | S | seg063_11F0_p1 | applied |
| W | MoveCivUnits | 11F0:0CAD, 2C24, 3A28 | EXCLUDE H46, H55 | S | seg063_11F0_p1 | applied |
| W | ChooseAiUnitOrder | 1078:443F, 26BE | `bestIsAttack` (bp-0x18), `temp` (bp-0x46) stack-resident; UNINIT class open | A, D | seg016_1078_p2 | applied (behaviour: emulated stack words only; outcomes masked) |
| W | ChooseAiUnitOrder | 1078:1D9A, 351E, 3562 | MANUAL U4 | S | seg016_1078_p2 | applied |
| W | AIAnalyzeCivStrategy | 1078:0B18 | MANUAL G25 (optional N1); stale annot note removed | A, S | seg016_1078_p1 | applied |
| W | ChooseCityProduction | 1170:187C | `bestIndex` (bp-0xE) stack-resident; UNINIT class a | A, D | seg047_1170_p2 | applied (behaviour) |
| W | ChooseCityProduction | 1170:1A3C, 1B06, 1D66, 1E30; 1DE6, 1EB5 | MANUAL C12 OOB; H25 | S | seg047_1170_p2 | applied |
| W | ShowConqueredCivLeader | 1180:1BAA, 1ECD | overlayAX/AY/BX/BY stack-resident; UNINIT findings 8.2 1180:1A9F, class b | A, D, F | seg049_1180_p2_r | applied (behaviour) |
| W, V38 | HoldDiplomaticAudience | 1160:0397/039A, 0685/0688, 1F9D/1FA2 | three `regs` entries: the listing's `SI = civ*2` / `human*2` loads the C omits (bind_param_regs skips them) | A | seg045_1160_p1 | applied (behaviour: emulated SI, saved-SI words) |
| W | HoldDiplomaticAudience | 1160:1CB6 | UNINIT findings 8.2 1160:1CB6, G30, class b | A, D, F | seg045_1160_p1 | applied (comment only) |
| W | ProcessGameTurn | 1088:02F8..032C | SOURCE_ERRATA E17: `(long)` keeps the 17-bit sum of the bankruptcy test | A, R | seg018_1088_p1 | applied (behaviour) |
| W | ProcessGameTurn, RunEndGameSequence | 1088:00B2, 0709, 0388, 0437, 0A56, 0B01, 0B11, 0B6D | EXCLUDE G27, G1, V14, V28 (context citations) | S | seg018_1088_p1 | applied |
| W | HandleMenuCommand, BuildShowHideMenuLabel | 1048:01A9, 01BD, 0101, 02EE | EXCLUDE H57, H55 | S | seg010_1048 | applied |
| W | ShutdownGame | 1008:0391, 0477 | EXCLUDE C1, L10 (V16 T1/T2) | S | seg002_1008_r | applied |
| W | CivLoadGame | 10F8:002E, 0093, 00D2, 00F5 | C19 kind OOB -> BUG (MANUAL) | S | seg031_10F0_r | applied |
| W | CivLoadGame, ChooseFileToOpen | 10F8:004D, 0129, 0194; 1130:00F2 | EXCLUDE L11, H64 | S | seg031_10F0_r, seg039_1130 | applied |
| W | WriteFileSpec | 1140:0270, 027B | C16 kind OOB -> BUG (MANUAL) | S | seg041_1140_r | applied |
| W | RunNewGameSetup | 10E8:0CE2, 0D20, 0FCD, 0FE1; 0D3A | MANUAL C11 OOB at the strcpy sites; EXCLUDE the old 0D3A | S | seg030_10E8_p1 | applied |
| W | RunNewGameSetup | 10E8:1201; 0743, 09C3 | MANUAL V24 BUG; EXCLUDE G30, V24 context sites | S | seg030_10E8_p1 | applied |
| W | InitGameColorTables | 10E8:2DE3, 2E5C, 2FC5 | MANUAL H13 + STATEMENT to 2D8C, 2E04, 2F59 | S | seg030_10E8_p3_r | applied |
| W | ResetSpaceship | 10E8:3376 | MANUAL H43 | S | seg030_10E8_p3_r | applied |
| W | NameDialogWndProc | 10F0:0266 | DX of the handled-message returns | R (E18) | none | deferred: `ret_dx` refuses 4-byte results; no mechanism for a 32-bit result's high word |
| W | ProcessCity, MoveCivUnits, ChooseAiUnitOrder | - | merge the part reports with summary tables | - | - | deferred: outside the fixer's writable files (orchestrator) |
| V16 R1 | ShowPediaEntry | 1068:11A1..11C4 | SOURCE_ERRATA E8 (destination GetPortColorTable nested) | A, R | seg014_1068_p1 | applied (behaviour: push order) |
| V16 R2 | ShowPediaEntry | 1068:15EE..1624 | SOURCE_ERRATA E9 (both Scale calls in DrawTile's arguments) | A, R | seg014_1068_p1 | applied (behaviour: push order) |
| V16 T1 | PostOrderMenuKey | 1008:0AF8 | MANUAL C12 OOB | S | seg002_1008_r | applied |
| V18 T1 | ShowIntelligenceAdvisor | 1018:16C2 | UNINIT findings 8.2 1018:12E0, class b | A, D, F | seg004_1018_r | applied (comment; slot already resident) |
| V18 opt. | WdwMapOpen | 1208:0C52 | MANUAL H41 | S | seg064_11F8_r | applied |
| V21 R1 | ShowCityView | 11B0:01E4..0222 | SOURCE_ERRATA E10 (RandomBelow(2) in place) | A, R | seg055_11B0_p1_r | applied (behaviour: stack depth of the draw; RNG order unchanged) |
| V21 T1 | ShowCityView | 11B0:1019 | UNINIT findings 8.2 11B0:0105, V10, class b | A, D, F | seg055_11B0_p1_r | applied (comment) |
| V21 T2 | ShowCityView | 11B0:1153 | EXCLUDE C20 | S | seg055_11B0_p1_r | applied |
| V21 T3 | ShowCityView | 11B0:0BE4, 0EAF, 0EF4, 0F7C | MANUAL V10 | S | seg055_11B0_p1_r | applied |
| V21 note | BarbarianUnitAI | (annot comment) | stale "translation stops at 1078:5997" removed | A | none | applied |
| V19 R1 | Superimpose | 1030:92CB..9306 | SOURCE_ERRATA E11 | A, R | seg007_1030_p3 | applied (behaviour: push order) |
| V19 R1 | CityScreenWndProc | 1030:9C59, 9CC8 | DX of the handled-message returns | R (E18) | none | deferred: as NameDialogWndProc |
| V19 T1 | CityScreenWndProc | 1030:9C59, 9CC8 | UNINIT findings 8.2 1030:9C59, class c | A, D | seg007_1030_p3 | applied (comment) |
| V19 T1 | DiplomatEntersCity, DiplomatBribeUnit | 11B8:0407, 086F; 0564 | MANUAL G5, G34 BUG; G34 0564 kind OOB -> BUG | S | seg056_11B8_p1_r | applied |
| V19 opt. | DiplomatBribeUnit | 11B8:0B90 | MANUAL G33 at 0B90 (the optional 0BC7 not added) | S | seg056_11B8_p1_r | applied |
| V19 check | ProcessCityDisaster | 1040:07C0, 0B78 | G5 range ends located (the `and` clear-mask stores under markers 07A8 and 0B60); MANUAL G5 | S | seg009_1040_p1 | applied |
| V17 T | HandleCivContact | 1168:0A07 | `strings` " and ": ["1420:3585", "1420:3569"] | A | seg046_1168 | applied (behaviour: the two literals swap) |
| V17 T | SetMutualDiplomacyFlag | 1168:0E6C (+0E82) | EXCLUDE H52 at 0E6C; the regeneration then put the same context comment on the second site 0E82 of the statement, so 0E82 is excluded too | S | seg046_1168 | applied |
| V17 N | ShowUnitStackDialog | 11C0:30C3 | UNINIT DESIGN.md 3.4 dlgPort, class b | A, D, F | seg057_11C0_p3 | applied (comment) |
| V23 T | ApplyGlobalWarming | 1028:1B86 | MANUAL U4 OOB (the inventory row follows from MANUAL on regeneration) | S | seg006_1028_r | applied |
| V23 T | ShowAboutBox | 1010:004F, 00B4; 0074, 00A6 | UNINIT aboutWindow, movie, class b | A, D, F | seg003_1010 | applied (comment) |
| V23 T | DrawCasualtyReport | 1018:0B9B | STATEMENT to 1018:09F3 | S | seg003_1010 | applied |
| V23 T | ResolveCombat | 1050:0BA4, 0D87 | EXCLUDE H52 | S | seg011_1050_p1_r | applied |
| V23 N | ApplyGlobalWarming | 1028:1B99 | g_terrainByMapColor index >= 17 | - | - | deferred: an investigation note without a fix; not traced in this round |
| V24 T | TakeAdvanceFromCiv | 1038:0B36, 0B9A | `bestAdvance` (bp-0x8) stack-resident; UNINIT class open | A, D | seg008_1038 | applied (behaviour; unreachable with the shipped tables per V24) |
| V24 T | EstablishTradeRoute | 1038:0D55, 0D9B, 0DD1, 0E3C, 0E5C, 0E86, 0F97 | MANUAL U1 (the access addresses under markers 0D37..0F8C) | S | seg008_1038 | applied |
| V24 N | GetCityPlunderGold | 1038:0937 | MANUAL U3 BUG (replaces the function-level OOB comment) | S | seg008_1038 | applied |
| V20 T1 | CompleteResearch | 1170:2352, 2899 | `push ds` emitted after PlayerKnowsAdvance | - | - | deferred: neither `hold` nor `body` expresses a segment push that precedes the argument pushes of a call inside the argument list; no observable effect (V20) |
| V20 T2 | CompleteResearch | 1170:297D | UNINIT menuAdvances, class b | A, D, F | seg047_1170_p3_r2 | applied (comment; array resident) |
| V20 T3 | CompleteResearch | 1170:2521 | MANUAL V24 BUG | S | seg047_1170_p3_r2 | applied |
| V20 | GiveAdvance | 1170:2EA8, 2EB7 | STATEMENT G29 (and G1) to 2E31 | S | seg047_1170_p3_r2 | applied |
| V20 | GiveAdvance | 1170:3113, 2AD0, 2B01, 2B27, 2B35, 2B65, 2D9D, 2EA8; 30FC | MANUAL G1 OOB; G1 at 30FC as BUG | S | seg047_1170_p3_r2 | applied |
| V20 N | GiveAdvance | 1170:2D8D | G28 kind OOB -> BUG | S | seg047_1170_p3_r2 | applied |
| V20 | ShowHallOfFame | 1080:0384 | `uninitXOffset` (bp-4) stack-resident; UNINIT class b | A, D, F | seg017_1080 | applied (behaviour) |
| W | ProcessCivGovernmentAndDiplomacy, HoldDiplomaticAudience | 1168:03E5, 0583; 1160:205E | G28 kind OOB -> BUG | S | seg046_1168_r, seg045_1160_p1 | applied |
| V29 T1 | StartCivilWar | 11A0:066D, 0687 | `cityIndex` (bp-0x1A) stack-resident; UNINIT G35 class a; BUG G35 kept | A, D | seg053_11A0_r | applied (behaviour; headless test needed) |
| V29 T2 | StartCivilWar | 11A0:0C70, 0CFF | MANUAL U1 | S | seg053_11A0_r | applied |
| V29 N | StartCivilWar | (annot comment) | stale "still stops at 11A0:01F3" replaced | A | none | applied |
| V28 T1 | OpenPalaceView | 1158:0DAF, 0DFD, 0F8A | `rightEndSection` bp-0xE, `leftEndSection` bp-0xC stack-resident; UNINIT class b | A, D, F | seg044_1158_r | applied (behaviour) |
| V28 R1 | OpenPalaceView | 1158:0A89, 0B56, 0BEA, 103F, 111B | SOURCE_ERRATA E12 | A, R | seg044_1158_r | applied (behaviour: push order) |
| V32 T | AskCivilizationQuizQuestion | 1178:05D4, 07F6 | `correctOption` (bp-0xE) stack-resident; UNINIT class b | A, D, F | seg048_1178_r | applied (behaviour) |
| V32 T | RunReplayMenu, SaveGameAsDialog | 1180:0073, 1180:0000; 1198:00E2, 00A3 | EXCLUDE H54 | S | seg048_1178_r, seg051_1190_p2_r | applied |
| V32 N | ShowCivilizationScore | 1040:1280, 16DF, 17F5, 1869, 18F3 | MANUAL H42 | S | seg009_1040_p2_r | applied |
| V25 T1 | GetAirUnitReturnDirection | 11C0:3ABB, 3BA8 | `targetX`/`targetY` (bp-0x12/-0x14) stack-resident; UNINIT class open | A, D | seg057_11C0_p4_r | applied (behaviour) |
| V25 T2 | SubstituteTextTokens | 11D0:029E | `push ss` before the strlen call | - | - | deferred: no annotation for a segment push ahead of a nested call's arguments; no effect (V25) |
| V25 N | FoundCity | 1040:0000 | EXCLUDE G3 (function-level) | S | seg009_1040_p1 | applied |
| V30 | WdwMapProc | 1208:01AA | `hdcPaint` (bp-4) stack-resident; UNINIT class b | A, D, F | seg064_11F8_r2 | applied (behaviour: emulated stack word) |
| V30 | ShowWorldMap | 1188:06A2, 06CE | `/* OOB: port P2 */` at the statement 069A | A, O | seg050_1188_p1 | applied |
| V30 | ShowWondersOfTheWorld | 1188:0C38 | MANUAL U1 | S | seg050_1188_p1 | applied |
| V31 | ResizeMapWindow | 1208:0FB0 | MANUAL V23 | S | seg066_1208_p1_r | applied |
| V31 | PlotSmMapSquare | 1210:07EF..0827 | SOURCE_ERRATA E13 | A, R | seg066_1208_p2_r | applied (behaviour: push order) |
| V31 | PlanZoneWaypoint | 1128:0A1F, 0A9A, 0AC3, 0B4A, 0B65; 09BC | MANUAL C8 OOB at the accesses; 09BC to BUG (the report's suggestion) | S | seg038_1128_r | applied |
| V31 | FindAccessibleZone | 1128:0F72, 0F8F; 0F4E | MANUAL U5 OOB; 0F4E to BUG (the report's suggestion) | S | seg038_1128_r | applied |
| V26 T1 | CreateUnit | 11C0:1617, 1635 | `calls` pairs the two ShowInstantAdvice calls with their listing call addresses (ra 161C / 163A) | A | seg057_11C0_p2_r | applied (behaviour: return addresses and pushes) |
| V26 T2 | CreateUnit | 11C0:1360 | MANUAL H21, G52 | S | seg057_11C0_p2_r | applied |
| V26 T1 | DeleteUnit | 11C0:181A; 16E9, 1710 | STATEMENT C3 to 182E; MANUAL C3 OOB | S | seg057_11C0_p2_r | applied |
| V26 N | WakeUnitClearOrders | 11C0:2151 | EXCLUDE G56 | S | seg057_11C0_p2_r | applied |
| V26 N | EvaluateAndShowSpaceship | (annot comment) | stale "stops at 0E29" removed | A | none | applied |
| V27 T1 | AddWorkedSquareYields | 1030:7BB5 | `totalYield` (bp-8) stack-resident; UNINIT class open | A, D | seg007_1030_p2 | applied (behaviour; outcome unchanged per V27) |
| V27 R1 | DrawImprovementIconLogical | 1030:84E1..84FD | SOURCE_ERRATA E14 | A, R | seg007_1030_p2 | applied (behaviour: push order) |
| V27 N1 | SignPeaceTreaty | 1160:26B5 | MANUAL U1 | S | seg045_1160_p2_r | applied |
| V40 T1 | ShowCivilopediaEntry | 1020:0092 | UNINIT DI, class c | A, D | seg005_1020_r | applied (comment) |
| V40 T2 | ShowCivilopediaEntry, OnCivilopediaListSelect | 1020:006E, 00F2; 1068:058F, 060E | EXCLUDE H56 | S | seg005_1020_r, seg013_1060 | applied |
| V40 N | InsertHallOfFameEntry | 1080:05AE | G46 kind OOB -> BUG | S | seg017_1080_r | applied |
| V35 T1 | ShowPowerGraph | 1188:0962, 097B | MANUAL U5 OOB | S | seg050_1188_p1_r | applied |
| V35 T1 | DrawUnitInfoPanel | 11F0:4CC9, 4CE9 | MANUAL U1 | S | seg063_11F0_p2_r | applied |
| V35 T1 | ShowHistorianReport | 1188:0F57, 0F8D | UNINIT values[0], class open (already resident) | A, D | seg050_1188_p1_r | applied (comment) |
| V34 T1 | RunPalaceImprovement | 1158:088F/0894 | `shapeOrChoice` (bp-8) stack-resident; UNINIT findings 8.2 1158:0886, H44, class open | A, D | seg041_1140_r2 | applied (behaviour: saved data on the garden path) |
| V34 N2 | RunPalaceImprovement | 1158:03D3, 03F0 | `/* OOB: port P3 */` | A, O | seg041_1140_r2 | applied |
| V34 N1 | RunPalaceImprovement | 1158:0886 | citation inside 0883 (read 088F) | - | - | noted: the comment names the finding's address and stands at marker 086E, which governs 088F |
| V36 T1 | RunListBoxDialog | 1098:1D47 | `result` (bp-8) stack-resident; UNINIT class b | A, D, F | seg020_1098_p1_r | applied (behaviour: Cancel result) |
| V36 T2 | RunListBoxDialog | 1098:1B0F, 1C62 | resident itemCount, pSelection, onSelect, lpfnOldWndProc, lpfnSubclass, keepRunning, index | A, D, F (F33) | seg020_1098_p1_r | applied (latent) |
| V36 T1 | ListDialogSubclassProc | 1098:1D56 | `ret_dx` 0x1420 at the WM_LBUTTONDOWN/UP returns | A | seg020_1098_p1_r | applied (behaviour: DX) |
| V36 T1 | UpdateOrdersMenu, FoundCity | 1120:03A2; 1040:01C4 | EXCLUDE G69 | S | seg037_1120, seg009_1040_p1 | applied |
| V36 R1 | AnimateTileZoomInRect | 1068:1C8B..1CB1 | SOURCE_ERRATA E15 | A, R | seg014_1068_p2_r | applied (behaviour: push order) |
| V36 R1 | PediaDialogSubclassProc | 1068:28D2, 2919 | DX of the handled-message returns | R (E18) | none | deferred: as NameDialogWndProc |
| V33 R1 | CustomizeWorldWndProc | 1108:074D | DX of the handled-message returns | R (E18) | none | deferred: as NameDialogWndProc |
| V33 T1 | CustomizeWorldWndProc | 1108:074D | UNINIT class c | A, D | seg034_1108_r | applied (comment) |
| V33 | DrawTextAtPen, DrawTextAtPortXY | 10D8:00A2/00D0, 016E/01A0 | `hOldFont` (bp-4) stack-resident; MANUAL C12 OOB | A, S, D, F (F33) | seg028_10D8_r | applied (latent) |
| V33 | GetScreenTextWidth | 10D8:05D2 | MANUAL C12 OOB | S, D, F (F33) | seg028_10D8_r | applied |
| V33 | DrawMiniPalace | 1088:1AB9/1B0C, 1CE2, 1D00 | `hOldPen` (bp-0x12) stack-resident (5.2 item 2(e)); UNINIT variants[8] class b, pen word class a | A, D, F | seg018_1088_p2 | applied (behaviour) |
| V33 N | ShowInstantAdvice, ProcessGlobalWarmingAndAiWonders, DrawMiniPalace | 10E0:077F, 1088:1E32, 1088:1A82 | EXCLUDE V25, H59, R5 (function-level context cites) | S | seg028_10D8_r, seg018_1088_p2 | applied |
| V39 | ApplyNuclearBlast | 1050:15AC | EXCLUDE G60 | S | seg011_1050_p2_r | applied |
| V39 | DestroyCity | 1170:0396 | G1 as BUG (in-range store) | S | seg047_1170_p1_r | applied |
| V39 | CheckAdjacentForeignUnits | 11C0:250D, 2548 | MANUAL U3 OOB (U3's mechanism, as ShowWorldMap 1188:05DA) instead of a `port Pn` entry | S | seg057_11C0_p2_r2 | applied (deviation, see below) |
| V39 R1 | AnimateNuclearExplosion | 11B8:0C93..0CBC | SOURCE_ERRATA E16 | A, R | seg056_11B8_p1 | applied (behaviour: push order) |
| V37 T1 | OnCivilopediaListSelect | 1068:058F, 060E | EXCLUDE H56 | S | seg013_1060 | applied |
| V37 T1 | ShowNewspaper | 1138:049E | `push ds` after RandomBelow(2) | - | - | deferred: as CompleteResearch T1 (no annotation for a segment push ahead of a nested call) |
| V37 T2 | ShowNewspaper | 1138:01B8, 01C8, 04A1, 058B; 053E | MANUAL R2, V15 | S | seg039_1130_r | applied |
| V37 N | ShowNewspaper | 1138:00EB | U2 kind OOB -> BUG | S | seg039_1130_r | applied |
| V37 T1/T2 | TruncateStringToWidth | 1098:001E | MANUAL C12 OOB; `str` (bp+6) stack-resident | A, S, D, F (F33) | seg019_1090_r | applied (latent) |
| V37 T1 | PumpOneMessage | 1098:063E | MANUAL V20 | S | seg019_1090_r | applied |
| V37 N | HumanPlaceSpaceshipPart | 1070:1A9A, 1BAA | C4 kind OOB -> BUG | S | seg015_1070_p2_r | applied |
| V37 N | GetPortPixelIndex | 1070:127A | EXCLUDE L1 | S | seg015_1070_p1 | applied |
| V38 | DrawCityPeopleRowToOverlay, DrawCityPeopleRow | 1030:820D, 83A4 | `uninitGapFlag` (bp-6) stack-resident; UNINIT V11 class b | A, D, F | seg007_1030_p2_r | applied (behaviour) |
| V38 | FindNearestReplayCity | 1180:1100 | `bestSlot` (bp-4) stack-resident; UNINIT findings 8.2 1180:1096, class b | A, D, F | seg049_1180_p1 | applied (behaviour; the caller masks it) |
| V38 | Button | 1100:0A94 | MANUAL V20 | S | seg033_1100_r | applied |
| V38 | HasAdjacentIrrigationWater | 11F0:463B, 464C | MANUAL U4 OOB | S | seg063_11F0_p2 | applied |
| V38 | FindNextNonShipUnitInStack | 11F0:4F90, 4FE4 | MANUAL U3 OOB | S | seg063_11F0_p2 | applied |
| V38 | BlinkActiveUnitUntilInput | 11C0:0ED4 | `regs` {"covers": ["11C0:0ED4"], "before": "11C0:0ED7", "line": "REG_SI_I16 = unit;"} | A | seg057_11C0_p1_r | applied (behaviour; on the gate scenario's turn loop, see below) |
| V38 N | BlinkActiveUnitUntilInput | 11C0:0EE9, 0F0B | MANUAL U3 OOB (unit 128, the End-of-Turn pseudo unit) | S | seg057_11C0_p1_r | applied |
| V38 N | RawPortFillColor | 10D0:0307, 032E | MANUAL V9 (optional) | S | seg027_10D0_r | applied |
| V38 N | StringWidth | 1100:00B5 | MANUAL H29 (optional) | S | seg033_1100_r | applied |

Counts: 138 rows; 128 applied, 1 noted without a change (V34 N1), 9 deferred
(NameDialogWndProc, CityScreenWndProc, PediaDialogSubclassProc and CustomizeWorldWndProc DX;
CompleteResearch, SubstituteTextTokens and ShowNewspaper segment pushes; the ApplyGlobalWarming
1B99 investigation; merging the part reports).

Not in the plan and not applied (optional notes in the reports): ProcessCity part 2 N1 kind
corrections (1EBE/1FA7/1FE4/3130), H50 1030:5593, V12 1030:7205, ChooseCityProduction N1
panelRect, H29 1098:007E/0091/009F, and an OOB or FIDELITY decision for a stale MoveCivUnits
`terrainType` >= 24 (G48 is a BUG, so its marker is not on the allowlist; the headless test will
show whether the checked build records it).

## Regenerated units (73)

seg002_1008_r, seg003_1010, seg004_1018_r, seg005_1020_r, seg006_1028_r, seg007_1030_p1,
seg007_1030_p2, seg007_1030_p2_r, seg007_1030_p3, seg008_1038, seg009_1040_p1, seg009_1040_p2_r,
seg010_1048, seg011_1050_p1_r, seg011_1050_p2_r, seg013_1060, seg014_1068_p1, seg014_1068_p2_r,
seg015_1070_p1, seg015_1070_p2_r, seg016_1078_p1, seg016_1078_p2, seg017_1080, seg017_1080_r,
seg018_1088_p1, seg018_1088_p2, seg019_1090_r, seg020_1098_p1_r, seg027_10D0_r, seg028_10D8_r,
seg030_10E8_p1, seg030_10E8_p3_r, seg031_10F0_r, seg033_1100_r, seg034_1108_r, seg037_1120,
seg038_1128_r, seg039_1130, seg039_1130_r, seg041_1140_r, seg041_1140_r2, seg044_1158,
seg044_1158_r, seg045_1160_p1, seg045_1160_p2_r, seg046_1168, seg046_1168_r, seg047_1170_p1_r,
seg047_1170_p2, seg047_1170_p3_r2, seg048_1178_r, seg049_1180_p1, seg049_1180_p2_r,
seg050_1188_p1, seg050_1188_p1_r, seg051_1190_p2_r, seg053_11A0_r, seg055_11B0_p1_r,
seg056_11B8_p1, seg056_11B8_p1_r, seg057_11C0_p1_r, seg057_11C0_p2_r, seg057_11C0_p2_r2,
seg057_11C0_p3, seg057_11C0_p4_r, seg062_11E8_r, seg063_11F0_p1, seg063_11F0_p2,
seg063_11F0_p2_r, seg064_11F8_r, seg064_11F8_r2, seg066_1208_p1_r, seg066_1208_p2_r.

Exactly these 73 of the 170 `core/seg*.c` files differ from the pre-round copies. Three other
units are translated from a source file that an erratum patches (seg014_1068_p2, seg055_11B0_p1,
seg066_1208_p2); they hold none of the patched functions and were not regenerated: every new
erratum keeps the line count (below), so their translation is unaffected.

Every string literal (`DSTR`) of the 73 units is the same as before in the same order, except the
intended HandleCivContact swap (seg046_1168: 0x3569 <-> 0x3585).

## translate.py failures and their resolution

* `--check` over the 73 units: no error and no finding, on each of the three passes.
* No translate.py error occurred. One silent defect of the first generation was found in the
  review: errata E8, E9, E11..E16 originally changed the number of source lines, and
  `line_string_addr` (which reads the literal's line from the unpatched recovered file at the
  patched line number) then resolved two later literals wrongly: DrawCityScreenTitle 1030:8BD0
  DSTR(0x06C0) became DSTR(0x06B9) (after E14), and two ShowPediaEntry literals (0x1135, 0x113F)
  became 0x112D and 0x1137 (after E8/E9). Fix: every new erratum now keeps the line count (blank
  lines pad a shorter replacement; E9, E11 and E13 join two argument lines). After regeneration all
  `DSTR` values match the pre-round units. The older errata E2..E6 also change the line count; a
  `--show` translation of their ten units (seg039_1130, seg039_1130_r, seg047_1170_p3,
  seg047_1170_p3_r, seg047_1170_p3_r2, seg054_11A8_p1, seg054_11A8_p1_r, seg066_1208_p2,
  seg066_1208_p2_r, seg007_1030_p1) with temporary line-count padding gave the same `DSTR`
  sequence as the current files, so E2..E6 were restored unchanged (`gen/annot.py` copied back
  byte for byte). Recorded in RECOVERY-ERRATA.md. The translator hazard remains for any future
  erratum that changes the line count.

## Rule deviations

* `cd` was used in four shell commands (three early in the round, one later inside a `$(cd / &&
  ls ...)` subshell of a comparison loop); all paths were absolute and nothing was written by them.
* `gen/annot.py` was temporarily edited for the E2..E6 `--show` check above and restored from a
  scratch copy (`cmp` identical); no unit was written with that state.
* CheckAdjacentForeignUnits 11C0:250D/2548 (V39) and BlinkActiveUnitUntilInput 11C0:0EE9/0F0B
  (V38): the accesses are U3's documented mechanism (a stale -1 link / unit 128), so they are
  MANUAL U3 OOB sites rather than `port Pn` entries; the effect on the allowlist is the same.
* SetMutualDiplomacyFlag: EXCLUDE H52 1168:0E82 added beyond the plan's single entry (the
  report's premise that 0E82 is not marked separately no longer held once 0E6C was excluded).
* PlanZoneWaypoint 09BC and FindAccessibleZone 0F4E: kind changed to BUG, which the reports
  suggest ("can stay/become a BUG comment") but the plan does not list; this removes the
  allowlist entries for markers 0954 and 0F4E, where no table is accessed.
* BlinkActiveUnitUntilInput SI (11C0:0ED4): applied, because `regs` expresses it cleanly: SI is
  loaded from `unit` in the entry block (0ED4), no call precedes 0ED7, SI is not written again
  before 11C0:123B and the C reads of `unit` give the same value. It changes the emulated SI and
  therefore the saved-SI words its callees push, on the turn loop the gate scenario exercises.
  It can be reverted by removing the one `regs` entry of `"11C0:0EC2"`.

## For the orchestrator

1. Build (default and checked) and run the full tests; the regenerated units change behaviour at
   the class (a) sites and at the push-order errata.
2. Headless tests (rule 6.6) for the class (a) sites: ProcessCity 1030:1495, StartCivilWar
   11A0:066D, MoveCivUnits 11F0:13BF, ChooseCityProduction 1170:187C, ProcessBarbarianUprisings
   1088:0E14, DrawMiniPalace pen word 1088:1D00; the class open sites (ChooseAiUnitOrder
   1078:26BE/443F, TakeAdvanceFromCiv 1038:0B36, GetAirUnitReturnDirection 11C0:3ABB,
   AddWorkedSquareYields 1030:7BB5, ShowHistorianReport 1188:0F57, RunPalaceImprovement
   1158:088F) need their last writers traced before a test or a FIDELITY entry.
3. Re-run the gate scenario: BlinkActiveUnitUntilInput's SI binding, HoldDiplomaticAudience's SI
   loads, CreateUnit's ShowInstantAdvice return addresses and the E17 bankruptcy test lie on the
   turn loop.
4. Regenerate the OOB allowlist (`gen/oob_allowlist.py`): new OOB sites (MANUAL U1, U3, U4, U5,
   G1, G50, C3, C8, C11, C12; `port P2`, `port P3`) and removed ones (C4, C16, C19, G1 1170:0396
   and 30FC, G28, G34 0564, G46, U2, U3 1038 function-level, C8 09BC, U5 0F4E, C1 1008:0391,
   G1 1088:0709, C11 10E8:0D3A).
5. Regenerate the inventories (`gen/inventory.py`). It does not emit the hand-written
   "Sites found by the port" section of `inventory/out-of-range.md` (now P1..P3): append it again.
6. Merge the ProcessCity, MoveCivUnits and ChooseAiUnitOrder part reports (wave item, outside the
   fixer's files).

# Verification: gen/findings_sites.py round-5 entries

## Round 6 (2026-10-09): comments

Verifier R6G. This report reviews the generator change
`build/verify-round6/diff/gen-findings_sites.diff`. The change adds 49 EXCLUDE, 8 STATEMENT and 146 MANUAL
entries; no existing entry was changed or removed.

* **Inputs.**
  * `gen/findings_sites.py`: its docstring rule, CATS, OOB_WORDS and dedup.
  * `claude/docs/findings.md`, sections 4-10, read for every cited finding.
  * The listing, via `showfunc.py` for each site's function range.
  * The generated units, for the emitted comment and its marker.
  * `build/verify-round6/diff/inventory-out-of-range.diff`, round5-fixes.md and the cited round-5 reports.
* **Not done.** Nothing was built or run, and the allowlist file `build/cache/oob-allowlist.txt` was not
  read.
* **Method labels.** [L] listing; [G] generated C; [F] findings.md, the rule and the reports; [C]
  computation.

**Rule applied.**
* A finding's kind is OOB for U findings. It is also OOB for C/G findings whose text contains an
  OOB_WORDS term ("outside", "beyond", "overflow", "stray byte", "[-1", "fixed-size buffer", ...). Every
  other finding is BUG.
  * OOB by text: G1, G28, G34, G46, G50, C1, C3, C4, C8, C11, C12, C16, C19 and all U.
  * BUG by text: G3, G5, G11, G19, G25, G27, G29, G30, G33, G52, G56, G60, G69, C20, and every H, V, L
    and R.
* A MANUAL kind overrides the text, and OOB is used only for an access (5.2 item 3).
* EXCLUDE removes context citations. An excluded function entry is no longer a citation.
* STATEMENT moves a site to the marker of the statement that contains it at run time.
* Comments are deduplicated per finding per statement.
* The allowlist is keyed by the last executed `VM_SITE` marker.

### EXCLUDE (49): each address must be a context citation, not a defect site

| # | Finding | Site | Function | Check [L][F] | Result |
|---|---|---|---|---|---|
| E1 | H58 | 1030:19D8 | ProcessCity | SetCitySpecialistType(3) call named in H58's harmlessness column | correct |
| E2 | G19 | 1030:1E47 | ProcessCity | the guard that makes G19 harmless | correct |
| E3 | G27 | 1088:00B2 | ProcessGameTurn | evidence for G27's confidence; the defect is in ProcessCivGovernmentAndDiplomacy | correct |
| E4 | G1 | 1088:0709 | ProcessGameTurn | a reader that does test 0x80 | correct |
| E5 | V14 | 1088:0388 | ProcessGameTurn | year schedule (reachability of the overflow) | correct |
| E6 | V14 | 1088:0A56 | ProcessGameTurn | final-year test | correct |
| E7 | V14 | 1088:0B01 | ProcessGameTurn | call on the route | correct |
| E8 | V14 | 1088:0B11 | ProcessGameTurn | choice on the route | correct |
| E9 | V14 | 1088:0B6D | RunEndGameSequence | function entry, route to the power graph; the function-level comment is removed | correct |
| E10 | V28 | 1088:0437 | ProcessGameTurn | correct year-0 rule cited in contrast | correct |
| E11 | H57 | 1048:01A9 | BuildShowHideMenuLabel | PStrCat call, harmlessness column | correct |
| E12 | H57 | 1048:01BD | BuildShowHideMenuLabel | PStrCat call, harmlessness column | correct |
| E13 | H57 | 1048:0101 | BuildShowHideMenuLabel | entry named as the only PStrCat caller; prevents a function-level comment | correct |
| E14 | H55 | 1048:02EE | HandleMenuCommand | ShowMilitaryReport(human) call, harmlessness column | correct |
| E15 | H55 | 11F0:3A28 | MoveCivUnits | ShowMilitaryReport(human) call, harmlessness column | correct |
| E16 | H46 | 11F0:0CAD | MoveCivUnits | correct reset, harmlessness column | correct |
| E17 | H46 | 11F0:2C24 | MoveCivUnits | correct store of the step | correct |
| E18 | C1 | 1008:0391 | ShutdownGame | KillTimer call; 038C reads the victim g_messageTimerId in range | correct |
| E19 | L10 | 1008:0477 | ShutdownGame | FreeGodPalette call, harmlessness column | correct |
| E20 | L11 | 1130:00F2 | ChooseFileToOpen | `Flags = 0x180C` store, cited as why the open rarely fails | correct |
| E21 | L11 | 10F8:0129 | CivLoadGame | decode-failure frees (context of the leak) | correct |
| E22 | L11 | 10F8:004D | CivLoadGame | GlobalAlloc-failure common return -1 | correct |
| E23 | H64 | 10F8:0194 | CivLoadGame | version -1 reset of g_altCivSetMask | correct |
| E24 | H54 | 1198:00E2 | SaveGameAsDialog | truncation to 3 characters, harmlessness column | correct |
| E25 | H54 | 1198:00A3 | SaveGameAsDialog | entry named as a caller | correct |
| E26 | H54 | 1180:0073 | RunReplayMenu | truncation, harmlessness column | correct |
| E27 | H54 | 1180:0000 | RunReplayMenu | entry named as a caller | correct |
| E28 | C11 | 10E8:0D3A | RunNewGameSetup | in-range store of the byte-31 terminator; the overrun is the strcpy 0D20 (M66) | correct |
| E29 | G30 | 10E8:0743 | RunNewGameSetup | correct alive-mask store | correct |
| E30 | V24 | 10E8:09C3 | RunNewGameSetup | context address; see N1 | correct (N1) |
| E31 | L15 | 1158:17AD | FreePalaceSectionSprites | named as the call OpenPalaceView skips | correct |
| E32 | C20 | 11B0:1153 | ShowCityView | epilogue, jump target of the 0A46 return | correct |
| E33 | H52 | 1168:0E6C | SetMutualDiplomacyFlag | clear of bit 0x20, harmlessness column | correct |
| E34 | H52 | 1168:0E82 | SetMutualDiplomacyFlag | second clear in the same statement | correct |
| E35 | H52 | 1050:0BA4 | ResolveCombat | store of bit 0x20, harmlessness column | correct |
| E36 | H52 | 1050:0D87 | ResolveCombat | treaty-cancel call, harmlessness column | correct |
| E37 | G69 | 1120:03A2 | UpdateOrdersMenu | `cmp [bx+4],-2; jg`, correct reader cited for contrast | correct |
| E38 | G69 | 1040:01C4 | FoundCity | `cmp [bx],-1; jge`, correct reader cited for contrast | correct |
| E39 | G3 | 1040:0000 | FoundCity | entry named for its painted range; the defect is 1038:03B0 | correct |
| E40 | H56 | 1020:006E | ShowCivilopediaEntry | SetRect of a fresh rect, harmlessness column | correct |
| E41 | H56 | 1020:00F2 | ShowCivilopediaEntry | ShowPediaEntry call, harmlessness column | correct |
| E42 | H56 | 1068:058F | OnCivilopediaListSelect | SetRect, harmlessness column | correct |
| E43 | H56 | 1068:060E | OnCivilopediaListSelect | ShowPediaEntry call, harmlessness column | correct |
| E44 | G60 | 1050:15AC | ApplyNuclearBlast | wrapped neighbour x (WrapMapX at 15BE), contrast | correct |
| E45 | G56 | 11C0:2151 | WakeUnitClearOrders | entry cited for contrast; the defect is DrawUnitStackList 3493..351E | correct |
| E46 | V25 | 10E0:077F | ShowInstantAdvice | entry named as context | correct |
| E47 | H59 | 1088:1E32 | ProcessGlobalWarmingAndAiWonders | entry named as where a wonder completes; the defect is in ProcessCity | correct |
| E48 | R5 | 1088:1A82 | DrawMiniPalace | R5 documents the function's own LCG (a property) | correct |
| E49 | L1 | 1070:127A | GetPortPixelIndex | entry named as the caller of the leaking 10B0:16F7 | correct |

### STATEMENT (8): the target must be the marker of the statement that contains the site

| # | Finding | Site -> marker | Function | Check [L][G] | Result |
|---|---|---|---|---|---|
| S1 | V12 | 1018:0B9B -> 1018:09F3 | DrawCasualtyReport | 0B9B is the unit-type loop bound test; the `for` statement is marker 09F3 (seg003_1010.c l.812-813) | correct |
| S2 | C3 | 11C0:181A -> 11C0:182E | DeleteUnit | the statement 1808..182E carries marker 182E; by address the preceding marker would be 1802 | correct |
| S3 | G29 | 1170:2EA8 -> 1170:2E31 | GiveAdvance | the else-if condition 2E78..2EC2 has no marker (its then-branch is 2EC4); the if/else statement is 2E31 | correct |
| S4 | G29 | 1170:2EB7 -> 1170:2E31 | GiveAdvance | 2EB7 is still in the same condition | correct |
| S5 | G1 | 1170:2EA8 -> 1170:2E31 | GiveAdvance | same condition read | correct |
| S6 | H13 | 10E8:2DE3 -> 10E8:2D8C | InitGameColorTables | `cmp si,0x40` after body 2DA1; the inner loop has no marker | correct |
| S7 | H13 | 10E8:2E5C -> 10E8:2E04 | InitGameColorTables | likewise, body 2E1A | correct |
| S8 | H13 | 10E8:2FC5 -> 10E8:2F59 | InitGameColorTables | 2F59 holds GlobalLock and the third loop, which has no marker | correct |

### MANUAL (146): the site must be a real site of the finding, and the kind must follow the rule

"Kind" shows the given kind and, after the arrow, the effective kind.

| # | Finding | Site | Kind | Function | Check [L][F] | Result |
|---|---|---|---|---|---|---|
| M1 | U4 | 1030:0954 | -/OOB | ProcessCity | g_tileVisibility read of an unwrapped radius square (U4: "never wrapped ... x in -2..81") | correct |
| M2 | U4 | 1030:0FC4 | -/OOB | ProcessCity | same | correct |
| M3 | U4 | 1030:176D | -/OOB | ProcessCity | same | correct |
| M4 | U4 | 1030:6609 | -/OOB | ProcessCity | clicked radius square | correct |
| M5 | G1 | 1030:1B14 | -/OOB | ProcessCity | wonder 15: `g_cities[0x80].y` (1420:6301) | correct |
| M6 | G1 | 1030:1B2E | -/OOB | ProcessCity | wonder 15: `.x` (1420:6300); same statement as M5 (one comment) | correct |
| M7 | G11 | 1030:273D | -/BUG | ProcessCity | re-entrant ChooseCityProduction call | correct |
| M8 | G11 | 1030:2CC6 | -/BUG | ProcessCity | same | correct |
| M9 | G11 | 1030:2DC5 | -/BUG | ProcessCity | ReselectCityProduction call | correct |
| M10 | U4 | 1078:1D9A | -/OOB | ChooseAiUnitOrder | teleport scan (U4 lists ", 1D9A", which the parser misses) | correct |
| M11 | U4 | 1078:351E | -/OOB | ChooseAiUnitOrder | Settlers road neighbours | correct |
| M12 | U4 | 1078:3562 | -/OOB | ChooseAiUnitOrder | same | correct |
| M13 | G25 | 1078:0B18 | -/BUG | AIAnalyzeCivStrategy | othersDefense/othersCities statement (", 0B18" in G25) | correct |
| M14 | C12 | 1170:1A3C | OOB | ChooseCityProduction | strcpy into the 16-byte itemName | correct |
| M15 | C12 | 1170:1B06 | OOB | ChooseCityProduction | same | correct |
| M16 | C12 | 1170:1D66 | OOB | ChooseCityProduction | same | correct |
| M17 | C12 | 1170:1E30 | OOB | ChooseCityProduction | same | correct |
| M18 | H25 | 1170:1DE6 | -/BUG | ChooseCityProduction | TextBoxSetup call with &dialogResult as delta | correct |
| M19 | H25 | 1170:1EB5 | -/BUG | ChooseCityProduction | same | correct |
| M20 | V24 | 1170:2521 | BUG | CompleteResearch | TextBoxSetup without the Civ font | correct |
| M21 | G1 | 1170:3113 | OOB | GiveAdvance | `libraryOwner = g_cities[0x80].owner` | correct |
| M22 | G1 | 1170:30FC | BUG | GiveAdvance | the -1-only test (not an access) | correct |
| M23 | G1 | 1170:2AD0 | OOB | GiveAdvance | GiveAdvance(-1): statement 2AD0 governs the g_civKnownAdvances[-1] store at 2AFC | correct |
| M24 | G1 | 1170:2B01 | OOB | GiveAdvance | g_advanceSource[-1] | correct |
| M25 | G1 | 1170:2B27 | OOB | GiveAdvance | g_civTechCount[-1] | correct |
| M26 | G1 | 1170:2B35 | OOB | GiveAdvance | g_diplomacyStatus[human][-1] | correct |
| M27 | G1 | 1170:2B65 | OOB | GiveAdvance | g_civPluralNames[-1] | correct |
| M28 | G1 | 1170:2D9D | OOB | GiveAdvance | g_civPluralNames[-1] | correct |
| M29 | G1 | 1170:2EA8 | OOB | GiveAdvance | else-if read; STATEMENT S5 moves it to 2E31 | correct |
| M30 | G1 | 1170:0396 | BUG | DestroyCity | in-range store of 0x80 | correct |
| M31 | G28 | 1170:2D8D | BUG | GiveAdvance | RequestLeaderAudience call (not an access) | correct |
| M32 | G28 | 1168:03E5 | BUG | ProcessCivGovernmentAndDiplomacy | RequestLeaderAudience call | correct |
| M33 | G28 | 1168:0583 | BUG | ProcessCivGovernmentAndDiplomacy | same | correct |
| M34 | G28 | 1160:205E | BUG | HoldDiplomaticAudience | in-range reset of g_audienceResponse | correct |
| M35 | G52 | 11F0:1A3C | -/BUG | MoveCivUnits | mine conversion's hut-gone store | correct |
| M36 | U1 | 11F0:1D04 | -/OOB | MoveCivUnits | FindNearestCity call (findings' own address); the access is 1D16 in the same statement (marker 1CAE) | correct (N2) |
| M37 | U1 | 11F0:0DD5 | -/OOB | MoveCivUnits | pillage-victim owner read | correct |
| M38 | U1 | 11F0:0E40 | -/OOB | MoveCivUnits | same record | correct |
| M39 | U1 | 11F0:0E7B | -/OOB | MoveCivUnits | same record | correct |
| M40 | U1 | 11F0:0E9F | -/OOB | MoveCivUnits | same record | correct |
| M41 | U1 | 11F0:20C9 | -/OOB | MoveCivUnits | homeCity read; the accesses are 20D9/2104 in the same statement | correct (N2) |
| M42 | U1 | 11F0:2F4F | -/OOB | MoveCivUnits | FindNearestCity result -1 | correct |
| M43 | U1 | 11F0:3789 | -/OOB | MoveCivUnits | same | correct |
| M44 | U1 | 11F0:26E1 | -/OOB | MoveCivUnits | FindCityAt -1: owner read / status OR | correct |
| M45 | U1 | 11F0:272A | -/OOB | MoveCivUnits | buildings | correct |
| M46 | U1 | 11F0:2769 | -/OOB | MoveCivUnits | size | correct |
| M47 | U1 | 11F0:2847 | -/OOB | MoveCivUnits | knownSize/size | correct |
| M48 | G50 | 11F0:406C | -/OOB | MoveCivUnits | g_units[civ][DI = -1] access | correct |
| M49 | G50 | 11F0:40A6 | -/OOB | MoveCivUnits | same | correct |
| M50 | G50 | 11F0:40E7 | -/OOB | MoveCivUnits | same | correct |
| M51 | G50 | 11F0:4115 | -/OOB | MoveCivUnits | same | correct |
| M52 | G50 | 11F0:416A | -/OOB | MoveCivUnits | same | correct |
| M53 | G50 | 11F0:41AA | -/OOB | MoveCivUnits | same | correct |
| M54 | G50 | 11F0:41F8 | -/OOB | MoveCivUnits | same | correct |
| M55 | G50 | 11F0:4242 | -/OOB | MoveCivUnits | same | correct |
| M56 | H18 | 11F0:2331 | -/BUG | MoveCivUnits | boarding refusal keeps the GoTo | correct |
| M57 | H18 | 11F0:23AA | -/BUG | MoveCivUnits | Submarine onto land | correct |
| M58 | U1 | 11F0:4CC9 | -/OOB | DrawUnitInfoPanel | FindCityAt -1, garrison test | correct |
| M59 | U1 | 11F0:4CE9 | -/OOB | DrawUnitInfoPanel | garrison byte read | correct |
| M60 | U4 | 11F0:463B | -/OOB | HasAdjacentIrrigationWater | GetTerrainType call on an unwrapped neighbour | correct (N3) |
| M61 | U4 | 11F0:464C | -/OOB | HasAdjacentIrrigationWater | GetTileImprovements call | correct (N3) |
| M62 | U3 | 11F0:4F90 | OOB | FindNextNonShipUnitInStack | -1 link: type | correct |
| M63 | U3 | 11F0:4FE4 | OOB | FindNextNonShipUnitInStack | -1 link: nextInStack | correct |
| M64 | C12 | 1008:0AF8 | OOB | PostOrderMenuKey | GetIndString into the 26-byte keyString | correct |
| M65 | C11 | 10E8:0CE2 | OOB | RunNewGameSetup | strcpy (plural) into a 32-byte slot | correct |
| M66 | C11 | 10E8:0D20 | OOB | RunNewGameSetup | strcpy (adjective) | correct |
| M67 | C11 | 10E8:0FCD | OOB | RunNewGameSetup | strcpy (leader) | correct |
| M68 | C11 | 10E8:0FE1 | OOB | RunNewGameSetup | strcpy ($RPLC1) | correct |
| M69 | V24 | 10E8:1201 | BUG | RunNewGameSetup | TextBoxSetup without the Civ font | correct |
| M70 | H13 | 10E8:2DE3 | -/BUG | InitGameColorTables | `cmp si,0x40` (STATEMENT S6) | correct |
| M71 | H13 | 10E8:2E5C | -/BUG | InitGameColorTables | same (S7) | correct |
| M72 | H13 | 10E8:2FC5 | -/BUG | InitGameColorTables | same (S8) | correct |
| M73 | H43 | 10E8:3376 | -/BUG | ResetSpaceship | the reset statement | correct |
| M74 | C19 | 10F8:002E | BUG | CivLoadGame | GlobalAlloc (not an access) | correct |
| M75 | C19 | 10F8:0093 | BUG | CivLoadGame | GetFileSpecEOF call | correct |
| M76 | C19 | 10F8:00D2 | BUG | CivLoadGame | `je` of the size test | correct |
| M77 | C19 | 10F8:00F5 | BUG | CivLoadGame | `mov si,...` | correct |
| M78 | C16 | 1140:0270 | BUG | WriteFileSpec | truncating `movsx` store | correct |
| M79 | C16 | 1140:027B | BUG | WriteFileSpec | 32-bit compare | correct |
| M80 | H41 | 1208:0C52 | -/BUG | WdwMapOpen | CheckMapGrowLimit call, result discarded | correct |
| M81 | V10 | 11B0:0BE4 | -/BUG | ShowCityView | dead "exclude the new building" mode test | correct |
| M82 | V10 | 11B0:0EAF | -/BUG | ShowCityView | same; shares marker 0EA4 | correct |
| M83 | V10 | 11B0:0EF4 | -/BUG | ShowCityView | same | correct |
| M84 | V10 | 11B0:0F7C | -/BUG | ShowCityView | same | correct |
| M85 | G5 | 11B8:0407 | -/BUG | DiplomatEntersCity | sabotage clear mask (G5: 11B8:03E3..0407) | correct |
| M86 | G5 | 1040:07C0 | -/BUG | ProcessCityDisaster | earthquake range end (`and` clear store) | correct |
| M87 | G5 | 1040:0B78 | -/BUG | ProcessCityDisaster | fire range end | correct |
| M88 | G34 | 11B8:086F | BUG | DiplomatBribeUnit | bribe-price `imul` (arithmetic overflow) | correct |
| M89 | G34 | 11B8:0564 | BUG | DiplomatEntersCity | arithmetic overflow, not an access | correct |
| M90 | G33 | 11B8:0B90 | -/BUG | DiplomatBribeUnit | `je 0BC7`: payment when CreateUnit fails | correct |
| M91 | U4 | 1028:1B86 | OOB | ApplyGlobalWarming | GetScreenBufferPixel neighbour sample | correct (N3) |
| M92 | U1 | 1038:0D55 | -/OOB | EstablishTradeRoute | destCity -1: dest.y/x | correct |
| M93 | U1 | 1038:0D9B | -/OOB | EstablishTradeRoute | dest.baseTrade | correct |
| M94 | U1 | 1038:0DD1 | -/OOB | EstablishTradeRoute | dest.y/x | correct |
| M95 | U1 | 1038:0E3C | -/OOB | EstablishTradeRoute | dest.owner | correct |
| M96 | U1 | 1038:0E5C | -/OOB | EstablishTradeRoute | same record | correct |
| M97 | U1 | 1038:0E86 | -/OOB | EstablishTradeRoute | same record | correct |
| M98 | U1 | 1038:0F97 | -/OOB | EstablishTradeRoute | dest.baseTrade/owner | correct |
| M99 | U3 | 1038:0937 | BUG | GetCityPlunderGold | `idiv` by size 0 (U3: "divides by zero for size 0"), not an access | correct |
| M100 | V23 | 1208:0FB0 | -/BUG | ResizeMapWindow | only clientRect refreshed | correct |
| M101 | C8 | 1128:0A1F | OOB | PlanZoneWaypoint | g_zoneLevels store | correct |
| M102 | C8 | 1128:0A9A | OOB | PlanZoneWaypoint | BFS access (g_zoneLevels/g_seaZoneLinks) | correct |
| M103 | C8 | 1128:0AC3 | OOB | PlanZoneWaypoint | same | correct |
| M104 | C8 | 1128:0B4A | OOB | PlanZoneWaypoint | same | correct |
| M105 | C8 | 1128:0B65 | OOB | PlanZoneWaypoint | same | correct |
| M106 | C8 | 1128:09BC | BUG | PlanZoneWaypoint | the cause: a call that accesses no table | correct |
| M107 | U5 | 1128:0F4E | BUG | FindAccessibleZone | missing upper check; the compare accesses nothing | correct |
| M108 | U5 | 1128:0F72 | OOB | FindAccessibleZone | link read | correct |
| M109 | U5 | 1128:0F8F | OOB | FindAccessibleZone | link read | correct |
| M110 | U5 | 1188:0962 | OOB | ShowPowerGraph | g_powerHistory past turn 604 | correct |
| M111 | U5 | 1188:097B | OOB | ShowPowerGraph | same; same statement 0951 | correct |
| M112 | U1 | 1188:0C38 | -/OOB | ShowWondersOfTheWorld | g_cities[0x80].owner of a destroyed wonder | correct |
| M113 | U1 | 1160:26B5 | -/OOB | SignPeaceTreaty | g_cities[-1].owner when no city exists | correct (N4) |
| M114 | U1 | 11A0:0C70 | -/OOB | StartCivilWar | homeless unit: g_cities[-1].owner (07DF/099F are covered by statements 07BC/097C) | correct |
| M115 | U1 | 11A0:0CFF | -/OOB | StartCivilWar | same | correct |
| M116 | U3 | 11C0:250D | OOB | CheckAdjacentForeignUnits | stale occupancy: g_units[otherCiv][-1].visibleTo read | correct (N4) |
| M117 | U3 | 11C0:2548 | OOB | CheckAdjacentForeignUnits | the OR-write | correct (N4) |
| M118 | U3 | 11C0:0EE9 | OOB | BlinkActiveUnitUntilInput | g_units[civ][128].x (End-of-Turn pseudo unit) | correct (N4) |
| M119 | U3 | 11C0:0F0B | OOB | BlinkActiveUnitUntilInput | `.y`; same statement 0ED7 | correct (N4) |
| M120 | H21 | 11C0:1360 | -/BUG | CreateUnit | tileVisibility OR | correct |
| M121 | G52 | 11C0:1360 | -/BUG | CreateUnit | same statement, a separate finding | correct |
| M122 | C3 | 11C0:16E9 | OOB | DeleteUnit | g_unitsLost[civ][-1]++ | correct |
| M123 | C3 | 11C0:1710 | OOB | DeleteUnit | g_unitTypes[-1].capacity | correct |
| M124 | H42 | 1040:1280 | -/BUG | ShowCivilizationScore | human/global score term | correct |
| M125 | H42 | 1040:16DF | -/BUG | ShowCivilizationScore | same | correct |
| M126 | H42 | 1040:17F5 | -/BUG | ShowCivilizationScore | same | correct |
| M127 | H42 | 1040:1869 | -/BUG | ShowCivilizationScore | same | correct |
| M128 | H42 | 1040:18F3 | -/BUG | ShowCivilizationScore | same | correct |
| M129 | G46 | 1080:05AE | BUG | InsertHallOfFameEntry | 16-bit `imul` overflow, not an access | correct |
| M130 | R2 | 1138:01B8 | -/BUG | ShowNewspaper | RandomBelow(3) page noise | correct |
| M131 | R2 | 1138:01C8 | -/BUG | ShowNewspaper | RandomBelow(0xD) | correct |
| M132 | R2 | 1138:04A1 | -/BUG | ShowNewspaper | headline style | correct |
| M133 | R2 | 1138:058B | -/BUG | ShowNewspaper | tagline | correct |
| M134 | V15 | 1138:053E | -/BUG | ShowNewspaper | constant date "January 1, " | correct |
| M135 | U2 | 1138:00EB | BUG | ShowNewspaper | `paperCity = -2` set here; the access is AppendCityName's | correct |
| M136 | C4 | 1070:1A9A | BUG | HumanPlaceSpaceshipPart | the 99 sentinel store | correct |
| M137 | C4 | 1070:1BAA | BUG | HumanPlaceSpaceshipPart | `cmp di,-1` | correct |
| M138 | C12 | 1098:001E | OOB | TruncateStringToWidth | strcpy into the 256-byte pstr | correct |
| M139 | V20 | 1098:063E | -/BUG | PumpOneMessage | g_pendingCommand cleared before peeking | correct |
| M140 | V20 | 1100:0A94 | -/BUG | Button | PeekMessage PM_REMOVE drops WM_LBUTTONUP | correct |
| M141 | H29 | 1100:00B5 | -/BUG | StringWidth | `cbw` of the length byte | correct |
| M142 | V9 | 10D0:0307 | -/BUG | RawPortFillColor | right clamped into the caller's RECT | correct |
| M143 | V9 | 10D0:032E | -/BUG | RawPortFillColor | bottom | correct |
| M144 | C12 | 10D8:00A2 | OOB | DrawTextAtPen | strcpy into the 256-byte pstrBuf | correct |
| M145 | C12 | 10D8:016E | OOB | DrawTextAtPortXY | same | correct |
| M146 | C12 | 10D8:05D2 | OOB | GetScreenTextWidth | same | correct |

Every explicit kind matches the rule. The OOB overrides are on accesses, and the BUG overrides are on
non-accesses whose text would otherwise give OOB. Every None entry derives the kind its finding's text
gives.

### Findings

* **TRANSLATOR T1 (ProcessCity, 1030:3E6E/3E88, seg007_1030_p1.c l.3252-3262; comment only, checked
  build).**
  * [F] G1 says that, for a lost wonder, "wonders 13 and 15 then even take `GetBodyId` of the bytes at
    1420:6300/6301". The round-5 entries M5/M6 cover only wonder 15 in ProcessCity.
  * [L] 3E52 CivHasActiveWonder(cityOwner, 13). On success, 3E61/3E7B load `g_wonderCities[13]`
    (`+0x1a`), and 3E6E/3E88 read `g_cities[bx].y/.x`. For 0x80 these reads are 1420:6301/6300, one
    record past the table.
  * [G] Marker 3E44 governs the call and both reads. It has no `/* OOB: findings G1 */`, so the checked
    build would report these original accesses as unlisted.
  * Fix: MANUAL ("G1", None, "1030:3E6E"), plus ("G1", None, "1030:3E88") for the record, and a G1 row
    in `inventory/out-of-range.md`.
  * A listing search for `[g_wonderCities+0x1a]` / `+0x1e]` loads followed by `g_cities` reads finds
    exactly three statement pairs: 1030:1B07/1B21 (covered), 1030:3E61/3E7B and 1170:0957/0971.
* **TRANSLATOR T2 (ChooseCityProduction, 1170:0964/097E, seg047_1170_p2.c l.527-544; comment only,
  checked build).**
  * [L] 0919 CivHasActiveWonder(civ, 15). On success, 0957/0971 load `g_wonderCities[15]` (`+0x1e`), and
    0964/097E read `g_cities[bx].y/.x` for GetBodyId. This is the same G1 mechanism.
  * [G] Marker 090F governs these reads and has no G1 comment.
  * Fix: MANUAL ("G1", None, "1170:0964") (and "1170:097E") and the inventory row.
* **NOTE N1 (E30, V24 10E8:09C3).**
  * [L] 09C3 starts the STR#140 leader-name statement. The STR#148 adjective store that the EXCLUDE
    reason calls "the correct adjective store" begins at 0A01.
  * Both are correct stores, so excluding 09C3 as context is right. The address in V24's text and the
    reason wording are inaccurate.
* **NOTE N2 (M36 11F0:1D04, M41 11F0:20C9).**
  * [L] Neither address is itself the out-of-object access. The access is 1D16 (resp. 20D9/2104) in the
    same statement.
  * The marker and so the allowlist entry are the same. Only the inventory's site column points to a
    neighbouring instruction.
* **NOTE N3 (M60, M61, M91: call sites).** [L] The out-of-range map reads occur inside the callees
  GetTerrainType, GetTileImprovements and GetScreenBufferPixel. The entries are on the callers' call
  statements, as is the accepted U4 precedent 1110:1822. If the checked build attributes a callee's hit
  to the callee's last marker, these entries do not allowlist it. Not re-derived.
* **NOTE N4 (M113, M116-M119: sites that the cited text does not list).**
  * U1 does not name SignPeaceTreaty 1160:26B5.
  * U3 describes the stale-occupancy mechanism only for ShowWorldMap 1188:05DA, and the pseudo-unit read
    only at 11F0:08DA. It names neither CheckAdjacentForeignUnits nor BlinkActiveUnitUntilInput.
  * The comments cite the right mechanism, and the inventory rows record the sites. findings.md lacks
    them. round5-fixes.md records this as a deviation from the round-5 requests ("add to U3 or `port Pn`").
* **Cosmetic.** E35 is written `("H52", "1050:0BA4"):_C` (no space before `_C`). No effect.

### Pre-existing observations

These are outside the reviewed entries and are not counted in the table.

* **O1. G1 OOB comments on DestroyCity call sites.** These are at 1030:0B2E, 1030:1EBE, 1038:0217,
  1038:02D3 and 11F0:279C. G1 names these calls as triggers. They are calls, not accesses, so by the
  rule applied to M30 (1170:0396) they would be BUG or excluded. They only add allowlist markers that
  hold no G1 access.
* **O2. C19 comments on ChooseFileToOpen.** The function-level OOB comment on ChooseFileToOpen is a
  trigger citation (seg039_1130.c l.65; verify/seg039_1130.md N1).
* **O3. G3 BUG comments at reader sites.** The comments at 1078:4DD2 and 11F0:2D23 are on G3's effect
  readers, which are context.
* **O4. C3 OOB comments on calls.** The C3 OOB comments at DeleteUnit 11C0:177D/1802 are on the nested
  ForEachUnitInStack calls, not on the accesses. Not re-derived.

### Not checked

* The regenerated allowlist file and the regenerated units outside the 35 diff units, except the
  marker and comment reads quoted above.
* Reachability of each site.
* Pre-existing entries (before round 5), beyond O1-O4.
* Runtime (brief).

### Summary

| Function | Address | Verdict | T | R | N |
|---|---|---|---|---|---|
| ProcessCity | 1030:0000 | DEFECTS | 1 | 0 | 0 |
| ProcessGameTurn | 1088:0000 | PASS | 0 | 0 | 0 |
| RunEndGameSequence | 1088:0B6D | PASS | 0 | 0 | 0 |
| BuildShowHideMenuLabel | 1048:0101 | PASS | 0 | 0 | 0 |
| HandleMenuCommand | 1048:01CD | PASS | 0 | 0 | 0 |
| MoveCivUnits | 11F0:0000 | PASS | 0 | 0 | 1 |
| ShutdownGame | 1008:0329 | PASS | 0 | 0 | 0 |
| ChooseFileToOpen | 1130:0075 | PASS | 0 | 0 | 0 |
| CivLoadGame | 10F8:0000 | PASS | 0 | 0 | 0 |
| SaveGameAsDialog | 1198:00A3 | PASS | 0 | 0 | 0 |
| RunReplayMenu | 1180:0000 | PASS | 0 | 0 | 0 |
| RunNewGameSetup | 10E8:0000 | PASS | 0 | 0 | 1 |
| FreePalaceSectionSprites | 1158:17AD | PASS | 0 | 0 | 0 |
| ShowCityView | 11B0:0000 | PASS | 0 | 0 | 0 |
| SetMutualDiplomacyFlag | 1168:0DDA | PASS | 0 | 0 | 0 |
| ResolveCombat | 1050:0000 | PASS | 0 | 0 | 0 |
| UpdateOrdersMenu | 1120:0000 | PASS | 0 | 0 | 0 |
| FoundCity | 1040:0000 | PASS | 0 | 0 | 0 |
| ShowCivilopediaEntry | 1020:0000 | PASS | 0 | 0 | 0 |
| OnCivilopediaListSelect | 1068:056E | PASS | 0 | 0 | 0 |
| ApplyNuclearBlast | 1050:158A | PASS | 0 | 0 | 0 |
| WakeUnitClearOrders | 11C0:2151 | PASS | 0 | 0 | 0 |
| ShowInstantAdvice | 10E0:077F | PASS | 0 | 0 | 0 |
| ProcessGlobalWarmingAndAiWonders | 1088:1E32 | PASS | 0 | 0 | 0 |
| DrawMiniPalace | 1088:1A82 | PASS | 0 | 0 | 0 |
| GetPortPixelIndex | 1070:127A | PASS | 0 | 0 | 0 |
| DrawCasualtyReport | 1018:09CC | PASS | 0 | 0 | 0 |
| DeleteUnit | 11C0:16A4 | PASS | 0 | 0 | 0 |
| GiveAdvance | 1170:2AAA | PASS | 0 | 0 | 0 |
| InitGameColorTables | 10E8:2D46 | PASS | 0 | 0 | 0 |
| ChooseAiUnitOrder | 1078:1480 | PASS | 0 | 0 | 0 |
| AIAnalyzeCivStrategy | 1078:0000 | PASS | 0 | 0 | 0 |
| ChooseCityProduction | 1170:05CA | DEFECTS | 1 | 0 | 0 |
| CompleteResearch | 1170:21B3 | PASS | 0 | 0 | 0 |
| DestroyCity | 1170:0241 | PASS | 0 | 0 | 0 |
| ProcessCivGovernmentAndDiplomacy | 1168:0000 | PASS | 0 | 0 | 0 |
| HoldDiplomaticAudience | 1160:0000 | PASS | 0 | 0 | 0 |
| DrawUnitInfoPanel | 11F0:468C | PASS | 0 | 0 | 0 |
| HasAdjacentIrrigationWater | 11F0:45DB | PASS | 0 | 0 | 1 |
| FindNextNonShipUnitInStack | 11F0:4F38 | PASS | 0 | 0 | 0 |
| PostOrderMenuKey | 1008:0ADD | PASS | 0 | 0 | 0 |
| ResetSpaceship | 10E8:3368 | PASS | 0 | 0 | 0 |
| WriteFileSpec | 1140:0245 | PASS | 0 | 0 | 0 |
| WdwMapOpen | 1208:0AF1 | PASS | 0 | 0 | 0 |
| DiplomatEntersCity | 11B8:0000 | PASS | 0 | 0 | 0 |
| ProcessCityDisaster | 1040:068E | PASS | 0 | 0 | 0 |
| DiplomatBribeUnit | 11B8:07C2 | PASS | 0 | 0 | 0 |
| ApplyGlobalWarming | 1028:1AFD | PASS | 0 | 0 | 1 |
| EstablishTradeRoute | 1038:0D09 | PASS | 0 | 0 | 0 |
| GetCityPlunderGold | 1038:0901 | PASS | 0 | 0 | 0 |
| ResizeMapWindow | 1208:0F62 | PASS | 0 | 0 | 0 |
| PlanZoneWaypoint | 1128:081C | PASS | 0 | 0 | 0 |
| FindAccessibleZone | 1128:0EA3 | PASS | 0 | 0 | 0 |
| ShowPowerGraph | 1188:07AD | PASS | 0 | 0 | 0 |
| ShowWondersOfTheWorld | 1188:0B3E | PASS | 0 | 0 | 0 |
| SignPeaceTreaty | 1160:25FA | PASS | 0 | 0 | 1 |
| StartCivilWar | 11A0:0000 | PASS | 0 | 0 | 0 |
| CheckAdjacentForeignUnits | 11C0:2437 | PASS | 0 | 0 | 1 |
| BlinkActiveUnitUntilInput | 11C0:0EC2 | PASS | 0 | 0 | 1 |
| CreateUnit | 11C0:12C8 | PASS | 0 | 0 | 0 |
| ShowCivilizationScore | 1040:1137 | PASS | 0 | 0 | 0 |
| InsertHallOfFameEntry | 1080:0595 | PASS | 0 | 0 | 0 |
| ShowNewspaper | 1138:0000 | PASS | 0 | 0 | 0 |
| HumanPlaceSpaceshipPart | 1070:1952 | PASS | 0 | 0 | 0 |
| TruncateStringToWidth | 1098:0000 | PASS | 0 | 0 | 0 |
| PumpOneMessage | 1098:062F | PASS | 0 | 0 | 0 |
| Button | 1100:0A5D | PASS | 0 | 0 | 0 |
| StringWidth | 1100:00A1 | PASS | 0 | 0 | 0 |
| RawPortFillColor | 10D0:02BA | PASS | 0 | 0 | 0 |
| DrawTextAtPen | 10D8:002D | PASS | 0 | 0 | 0 |
| DrawTextAtPortXY | 10D8:00E0 | PASS | 0 | 0 | 0 |
| GetScreenTextWidth | 10D8:05B8 | PASS | 0 | 0 | 0 |

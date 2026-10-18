# Round 7 verification, batch R7D

Verifier R7D. Scope (task message): the "doc" items F6-12..F6-21 and F6-23 of
`docs/verify/round6-fixes.md`; every changed entry of `gen/findings_sites.py`
(`build/verify-round7/diff/gen-findings_sites.diff`); "dx" for NameDialogWndProc,
CityScreenWndProc, PediaDialogSubclassProc and CustomizeWorldWndProc. The dx results are in the
unit reports `seg031_10F0_r.md`, `seg007_1030_p3.md`, `seg014_1068_p2_r.md` and `seg034_1108_r.md`,
and ShowCityView's final row is in `seg055_11B0_p1_r.md`.

Ground truth: `showfunc.py` dumps saved under the scratch directory with prefix `R7D_`, and Grep over
`claude/src/asm`. Other inputs: `round6-fixes.md`; the round-7 diffs (gen-annot, gen-findings_sites,
DESIGN, FIDELITY, RECOVERY-ERRATA, inventory-out-of-range and the unit diffs); the current `core/*.c`;
`gen/translate.py` l.442-466 and 1665-1693; `gen/findings_sites.py` (docstring and `classify`);
`gen/oob_allowlist.py`; `claude/docs/findings.md`; the round-6 reports.

Nothing was built, compiled, run or tested.

## Round 7 (2026-10-09): doc

### F6-12 ShowCityView, E10 line count: confirmed
* [A][C] translate.py l.455 joins `old` with newlines, and l.459 replaces it with the newline-joined
  `new`. E10's first `old` is the single declaration line (recovered `seg055_11B0_p1.c` l.65), without
  its line break.
  * `"\n".join([])` and `"\n".join([""])` are both the empty string, so either form leaves an empty
    line and keeps the file's line count.
  * The round-7 change from `[]` to `[""]` (gen-annot.diff l.271-272) is cosmetic.
* [F] There is no `seg055_11B0_p1_r.diff` in `build/verify-round7/diff`, which is consistent with
  "regenerated, identical".
* My round-6 NOTE N3 in `seg055_11B0_p1_r.md` ("E10 deletes one line") was wrong and is withdrawn.

### F6-13 ShowPediaEntry, E8: confirmed
* [L] The pushes before the two GetPortColorTable calls:
  * 11A1/11A4 push 0xA0 and 0x48, then 11AA calls GetPortColorTable(&g_pediaPort). Two words are
    pending.
  * 11B2/11B3 push its result and 0x48, then 11BB calls GetPortColorTable(&picturePort). Four words
    are pending.
* [R][C] The pre-fix recovered C (the RECOVERY-ERRATA "Recovered" column) did this:
  * It ran the first call as a statement of its own, with nothing pending. That is 4 bytes higher
    than the listing.
  * Inside `CopyPaletteEntries(GetPortColorTable(&picturePort), 0x48, hDstTable, 0x48, 0xa0)`,
    Borland's right-to-left evaluation pushes 0xA0, 0x48, hDstTable and 0x48 before the second call.
    That is the listing's depth.
* The corrected text (RECOVERY-ERRATA.diff l.8) is right. The old "2 and 4 bytes higher" was wrong.

### F6-14 OpenPalaceView, findings 8.2 row: confirmed
* [F] findings.md l.1361 is the row `OpenPalaceView (1158:08E7)` ("`rightEndSection` when section 8 is
  built, `leftEndSection` without a left end").
* The DESIGN.md 3.4 row (l.604) and FIDELITY F48 now cite "findings 8.2 row 1158:08E7" in place of
  "verifier's find". The row is keyed by the function address, so the citation is exact.

### F6-15 E13 / E15 call addresses: confirmed
* [L] `call far CreatePortBitmap` is at 1210:0820 (`add sp,0x10` at 0825) and at 1068:1CAB
  (`add sp,0x10` at 1CB0).
* RECOVERY-ERRATA.diff l.14 and l.17 now give 1210:0820 and 1068:1CAB. This also closes round-6 NOTE
  N1 of `seg014_1068_p2_r.md`, which reported E15's 1CB1.

### F6-16 FIDELITY F43 (ShowCityView): confirmed, with a completeness NOTE
* [L] The listing:
  * 0105..0129 is the only copy: `strlen(g_messageText) < 0x78` copies g_messageText into
    `savedMessage` (bp-0x190).
  * Nothing copies `savedMessage` back.
  * 1029 tests `savedMessage[0]`:
    * if it is non-zero, 108A..10A7 set the font index to 8 (1094) and call
      DrawCenteredShadowedScreenText(ss:bp-0x190, 0xA0, 0xF, 0xE);
    * if it is zero, 1032..1088 rebuild g_messageText from AppendCityName / AppendGameYearText and
      draw them (font 5).
* [F] The new F43 text (FIDELITY.md l.62) says exactly this. Round-6 T4 in `seg055_11B0_p1_r.md` is
  fixed.
* **NOTE N1** (F43 completeness; [L][C], reachability is an inference):
  * [L] Frame layout: `savedMessage` is the 0x80 bytes bp-0x190..bp-0x111, and `grid` (bp-0x110)
    follows it directly.
  * If the stale bytes have no zero byte in those 0x80 bytes, "up to the first zero byte" runs on
    into the grid cells, which this function writes before 1029.
  * [L] The draw path calls GetScreenTextWidth:
    * DrawCenteredShadowedScreenText calls DrawCenteredScreenTextWithShadow (10D8:048B);
    * that function calls GetScreenTextWidth (10D8:04E8) and DrawScreenTextWithShadow (10D8:0506);
    * GetScreenTextWidth copies the string into a 0x100-byte local (`sub sp,0x100` at 10D8:05C2,
      strcpy at 05D2).
  * So a caption of 256 bytes or more overruns that buffer: findings C12, FIDELITY F33 (which lists
    GetScreenTextWidth 10D8:05D2 and DrawScreenTextWithShadow 10D8:036D).
  * Not shown: whether 256 or more non-zero bytes can occur. That needs all 0x80 stale bytes and at
    least 0x80 grid bytes to be non-zero.
  * Those sites are already listed out-of-range sites, so the port's required behaviour is unchanged.
    Suggested F43 addition: "a caption without a zero byte runs into `grid`; 256 bytes or more give
    F33's outcomes".

### F6-17 CompleteResearch marker: confirmed
* [L] 2939 starts the option test (`cmp [bp+repromptAfterHelp],0`). The re-prompt branch 296E..2980
  reads `menuAdvances[n]` with `cmp ss:[bx],si` at 297D.
* [G] `core/seg047_1170_p3_r2.c` l.820 has `VM_SITE(0x11702939u)`, and l.821 has
  `/* UNINIT: DESIGN.md 3.4 CompleteResearch menuAdvances, class b */  /* 1170:297D */`.
* [F] The DESIGN row (DESIGN.diff l.33) says "statement marker 2939, comment keyed to the `cmp` at 297D"
  and "`/* UNINIT */` at marker 2939 (site 297D)". This matches.

### F6-18 ShowHallOfFame, findings 8.2 row: confirmed
* [F] findings.md l.1348 is the row "`ShowHallOfFame` 1080:0384 | `[bp-4]` in `width + [bp-4] >= 320`".
* The DESIGN row (DESIGN.diff l.54) and F47 (FIDELITY.diff l.29) now cite "findings 8.2 row 1080:0384".

### F6-19 ShowWorldMap, P2 wording: confirmed
* [L] Unit dots are drawn this way:
  * 0608 tests the human player's visibility bit and 0614 skips monochrome mode;
  * 061F..0625 compute `unitCiv += 0x10`;
  * 069A..06A2 call SetForeColor(`g_egaToSystemColor[unitCiv]`);
  * 06C6..06CE call CreateBrushForColorIndex(`g_egaToSystemColor[unitCiv]`).
* The two reads at 06A2 and 06CE are unit-dot colour reads with index 16+civ, and they run for every
  unit dot drawn in colour mode.
* [F] The new P2 row (inventory-out-of-range.diff l.54) says this. The old "city square" was wrong.

### F6-20 EXCLUDE V24 reason: confirmed
* [L] The two statements:
  * 09C3 starts `g_leaderNames[slot] = STR# 140[civ id]` (`push 0x8c` at 09D9, GetIndCString 09DC,
    strcpy 09F9);
  * 0A01 starts the STR# 148 (`push 0x94` at 0A17) adjective copy.
* The new reason (gen-findings_sites.diff l.9-12) is accurate.
* [F] findings_sites.py's docstring says EXCLUDE reasons are not emitted, so no generated C changes.

### F6-21 U1 sites of MoveCivUnits: confirmed
* [L] The three sites:
  * 1D04 is the FindNearestCity call. The access is 1D16
    `mov al,es:[bx+g_cities+0xB]` (owner), with bx = result*0x1C (1D0C).
  * 20C9 reads `g_units[..]+7` (the home-city byte; in range). The accesses are 20D9
    `[bx+g_cities+5]` (y) and, after the second home-city read 20F4, 2104 `[bx+g_cities+4]` (x).
* [G] Comments:
  * `/* OOB: findings U1 */ /* 11F0:1D16 */` is at l.1687 under marker 1CAE (l.1686);
  * `/* 11F0:20D9 */` is at l.1866 under marker 20B6 (l.1865);
  * 2104 shares marker 20B6. translate.py l.1687-1688 drops a second comment that names the same
    finding, so one comment is right.
* The inventory rows (inventory-out-of-range.diff l.43-45) match.

### F6-23 ApplyGlobalWarming 1B99 closure: confirmed for random worlds, with a NOTE

The question was whether an index of 17 or more is really impossible at 1B99 for maps the game builds.

* [L] The read at 1B99:
  * it is `cmp word es:[bx],0xa` with `bx = 2*pixel(x+dx, y+dy)` (GetScreenBufferPixel at 1B86);
  * the neighbour loop runs only when the square's own terrain is 3 or less (1B4D..1B53: Desert,
    Plains, Grassland or Forest);
  * x is 0..79 and y is 0..49, so the neighbours are x' = -1..80 and y' = -1..50;
  * GetScreenBufferPixel returns 0 outside the 320x200 buffer (its summary), which covers x' and
    y' = -1.
* [L] Random worlds (GenerateWorldMap 1028:0000 summary and code):
  * step (1) forces a two-square water border, x 0, 1, 78 and 79;
  * step (2) only adds land at (x+1, y), (x, y+1) and (x+1, y+1) of a 2x2 block that already holds
    diagonal land, so column 78 never becomes land and column 79 stays ocean;
  * the climate and erosion conversions convert only land types;
  * GenerateRivers was not traced. That it creates no terrain 0..3 square at x = 79 is an inference.
* [L] LabelBodiesAndFinalizeMap 1028:0A93 fills rows 0 and 49 with Arctic (15), with random Tundra
  squares on rows 0, 1, 48 and 49.
* So no square at x = 79 or y = 49 passes the terrain test, and the column-80 and row-50 neighbours are
  never read on a random world. The index is then 0 (outside the buffer) or a map-layer pixel of 0..15
  (a terrain colour), below 17. The fixer's conclusion holds, and it holds more strongly than stated.
* **NOTE N2** (F6-23 wording; [L] and inference):
  * "Column 80 reads the territory owner 0..7 / city-site values 8..15" and "(80, 50) the second
    site-value copy (8..15)" do not describe these bytes precisely. ComputeCitySiteValues writes only
    map x 2..77, so the layer bytes at column 80 (map x 0) are not site values.
  * The description matters only where those squares are read, and on random worlds they are not.
  * findings C13's label overflow does not reach row 50 on random worlds.
* Not checked:
  * The EARTH map. Its every layer is picture 137 minus 10, an asset outside the allowed paths, and
    whether column 79 holds land of terrain 0..3 there is unknown.
  * Save files, as the fixer's caveat says.
  * Later in-game terrain changes are inferred not to create land at column 79 (settlers act on
    land; global warming and pollution convert land only).

## Round 7 (2026-10-09): findings-sites

The changed entries are those of `gen-findings_sites.diff`. The rules applied:

* `classify` (findings_sites.py l.514): U findings are OOB; C/G findings are OOB when their text has
  an OOB word, otherwise BUG; a MANUAL kind overrides the text.
* Attribution: translate.py l.1680-1689 put each site comment at its governing marker, unless that
  statement already names the finding. `gen/oob_allowlist.py` keys every OOB comment to the last
  `VM_SITE` before it.
* Runtime: `vm_site` is restored by `fr_leave` (platform/w16/vm.c), so an access after a ported callee
  returns is attributed to the caller's marker.

| Entry | Kind | Access [L] | Marker / comment [G] | Callee notes | Result |
|---|---|---|---|---|---|
| U1 1D16 (was 1D04) | OOB (U) | owner read `[bx+g_cities+0xB]`; FindNearestCity -1 reads 1420:54EB | 1CAE l.1686, comment l.1687, access l.1694 | FindNearestCity (1D04) returns before the read and makes no out-of-range access of its own | correct |
| U1 20D9 (was 20C9) | OOB (U) | home-city y `[bx+g_cities+5]` | 20B6 l.1865, comment l.1866, accesses l.1868/1870 | GetBodyId (210C) runs after both reads; its map reads go through the clipped GetScreenBufferPixel | correct |
| U1 2104 (new) | OOB (U) | home-city x `[bx+g_cities+4]` | 20B6; deduplicated | as above | correct |
| G1 1030:3E6E (new) | OOB (text "outside", "stray byte") | `[bx+g_cities+5]`, bx = g_wonderCity[13]*0x1C | 3E44 l.3252, comment l.3253, reads l.3261/3263 | CivHasActiveWonder (3E52, l.3257) returns first; its own G1 read has the comment at 7EA4 (seg007_1030_p2.c l.174) | correct |
| G1 1030:3E88 (new) | OOB | `[bx+g_cities+4]` | 3E44; deduplicated | - | correct |
| G1 1170:0964 (new) | OOB | `[bx+g_cities+5]`, bx = [395C]*0x1C (wonder 15) | 090F l.527, comment l.528, reads l.543/545 | GetBodyId (0949, l.539) returns first; its reads are clipped | correct |
| G1 1170:097E (new) | OOB | `[bx+g_cities+4]` | 090F; deduplicated | - | correct |
| G48 OOB 11F0:13CB (new) | MANUAL OOB over text BUG; it is an access | `mov al,es:[bx+g_terrainTypes]`, bx = terrainType<<3 | 138C l.1147; deduplicated, because the annot comments at 13BF (l.1148-1150) already name G48; access l.1156 | no call between 138C and 13CB | correct; NOTE N3 |
| G35 OOB 11A0:0678 (new) | MANUAL OOB; access | size `[bx+g_cities+7]` with the stale cityIndex | 066D (seg053_11A0_r.c l.409); deduplicated against the annot comments l.410-412; access l.413 | TransferCityToCiv (068C) runs later under its own markers | correct; NOTE N3 |
| G35 OOB 11A0:0E55 (new) | MANUAL OOB; access | owner store `[bx+g_cities+0xB]` | 0E4D (seg053_11A0.c l.24), comment l.25 | - | correct |
| G35 OOB 11A0:0E64 (new) | MANUAL OOB; access | y read `[bx+g_cities+5]` | 0E5A l.27, comment l.28; the reads precede SetTileOwner (l.34) | SetTileOwner with garbage x/y writes through the clipped SetScreenBufferPixel, so no out-of-range record. In-range writes to other layer bytes were not traced | correct; NOTE N4 |
| G35 OOB 11A0:0E76 (new) | MANUAL OOB; access | x read `[bx+g_cities+4]` | 0E5A; deduplicated | - | correct |
| G35 OOB 11A0:0E93 (new) | MANUAL OOB; access | size `[bx+g_cities+7]` | 0E89 l.36, comment l.37 | the 0EA3 store indexes by newOwner (in range) | correct |
| G67 OOB 11C0:22BB (new) | MANUAL OOB; access | `cmp word es:[bx+g_unitTypes+2],0`, bx = cbw(type)*0x16; type 0xFF gives 1420:1A24 | 22BB (seg057_11C0_p2_r.c l.579), comment l.580 | DeleteUnit (22C6) on the free slot: its type -1 accesses carry the C3 comments at 16E9/1710 (l.191/195; not re-derived) | correct |
| EXCLUDE V24 10E8:09C3 | not emitted | see F6-20 | - | - | reason accurate |

### Notes
* **NOTE N3** (comment address of the annot-carried OOB; [A][G]):
  * For G48, the visible OOB comment is the annot's `/* OOB: findings G48 */ /* 11F0:13BF */` (l.1150).
    13BF `mov bx,[bp+terrainType]` is the UNINIT stack read, and the out-of-range access is 13CB.
  * StartCivilWar has the same pattern: `/* 11A0:066D */` (l.412), where the access is 0678.
  * Both inventory rows also list 13BF and 066D as out-of-range sites (inventory-out-of-range.diff
    l.18, l.24).
  * gen-annot.diff l.139-144 explains the choice. The allowlist keys on the marker (138C / 066D), so
    there is no effect.
  * Prompt 5.2 item 3 uses OOB for accesses, so this is wording only.
* **NOTE N4** (comment wording): the MANUAL comment and inventory row for 11A0:0E64 say "y/x reads".
  0E64 is the y read only; the x read 0E76 has its own entry.

## Not checked
* Runtime behaviour: no build, run, test or harness (brief).
* EARTH and save-file maps for F6-23 (asset outside the allowed paths / file contents).
* Whether a caption of 256 or more bytes is reachable in ShowCityView (N1).
* The internals of DeleteUnit, SetTileOwner, FindNearestCity and GetBodyId, beyond their
  clipped-pixel use and the existing C3 comments.
* The other hunks of the regenerated units, and the gen-annot classification changes (other batches).

## Deviations from the rules
1. One Bash `cp` copied `claude/docs/db/names.json` into the scratch directory (`R7D_names.json`).
   This is a shell read of a project file in an allowed path.
2. One Bash `grep -n "FUNCTION ..."` ran over `claude/src/asm/*.asm` (a shell read of project files).
3. One Bash `grep -n "FUNCTION" .../seg062_11E8.asm | head -0` ran (a shell read; output suppressed).
4. One Bash `head -60 claude/tools/worldsim.py` and `ls claude/tools/` ran (a shell read of a project
   file).
5. Two Grep-tool outputs were too large and the harness saved them to tool-result files. Neither file
   was opened; narrower searches were used instead.

No other deviation: no `cd`, no other Python, and no edits outside the scratch directory and this
batch's report files.

## Summary (doc and findings-sites)

These verdicts cover only the items of this batch. NameDialogWndProc, CityScreenWndProc,
PediaDialogSubclassProc and CustomizeWorldWndProc ("dx") are all PASS, with T0 R0 N1 each; see their
unit reports.

| Function | Address | Verdict | T | R | N |
|---|---|---|---|---|---|
| ShowCityView | 11B0:0000 | PASS | 0 | 0 | 1 |
| ShowPediaEntry | 1068:06AF | PASS | 0 | 0 | 0 |
| OpenPalaceView | 1158:08E7 | PASS | 0 | 0 | 0 |
| PlotSmMapSquare | 1210:07AE | PASS | 0 | 0 | 0 |
| AnimateTileZoomInRect | 1068:1C13 | PASS | 0 | 0 | 0 |
| CompleteResearch | 1170:21B3 | PASS | 0 | 0 | 0 |
| ShowHallOfFame | 1080:0119 | PASS | 0 | 0 | 0 |
| ShowWorldMap | 1188:013F | PASS | 0 | 0 | 0 |
| RunNewGameSetup | 10E8:0000 | PASS | 0 | 0 | 0 |
| ApplyGlobalWarming | 1028:1AFD | PASS | 0 | 0 | 1 |
| MoveCivUnits | 11F0:0000 | PASS | 0 | 0 | 1 |
| ProcessCity | 1030:0000 | PASS | 0 | 0 | 0 |
| ChooseCityProduction | 1170:05CA | PASS | 0 | 0 | 0 |
| StartCivilWar | 11A0:0000 | PASS | 0 | 0 | 1 |
| TransferCityToCiv | 11A0:0E3A | PASS | 0 | 0 | 1 |
| DeleteNonLandUnitCallback | 11C0:2287 | PASS | 0 | 0 | 0 |

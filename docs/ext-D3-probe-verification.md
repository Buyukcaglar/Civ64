# Extension D3: probe verification (O5)

Prompt: `claude/docs/x64-port-scaling-dos-prompt.md`, phase D3 (section 9), gate item "probe verification
recorded". Design: [verify/ext-d1-draft-A.md](verify/ext-d1-draft-A.md) (revision 3) 4.1..4.3 (the probe
table, hooks and list), 5 (the read-only queries) and 6.3 (unit-by-unit verification). Unit D3a,
2026-10-11; record: [ext-D3a-record.md](ext-D3a-record.md).

This record holds, for each observer probe, the address verified against the listing `claude/src/asm`
and against `claude/tools/showfunc.py`, its phases, the port function that enters it and its hit counts
in the harness runs; for each call-site row, the call instruction and return address; and for each
`w16q_*` query and each module accessor it calls, what it reads, that it writes nothing in the
emulation and the verdict. D3a has no probe handlers: the handlers of areas B, C and D (D4 onwards) and
M's A-3 queries add their rows here when they are written.

## 1. Method

**The tables are generated.** `gen/obs_tables.py` writes `present/obs_tables.h` and
`present/obs_tables.c` (Open A1, settled: generated). Its inputs are the base list of
`docs/dos/WINDOWS-INVENTORY.md` section 10 (182 rows naming 175 functions), the 26 additions of draft A
4.3 and area C's two new keys (`IsKeyPending` 11E8:02FB, `DrawUnitStackList` 11C0:3407): **203 keys**.
The phases are WI's "Kind" column, widened as draft A 4.3 states (every 10.1 row, the nine 10.2
functions, `TileCacheLookup`, `DrawUnit` and the nine RV2-1 functions get entry and exit). The
generator refuses a key unless

1. the listing `claude/src/asm` has a `; FUNCTION Name (SSSS:OOOO ..` header at exactly that address,
2. `core/gen/civ_frames.c` has a `FrameDesc` of that name at that address that is not a tail-jump stub,
3. a port function in `core/` or `rt/` enters it (`fr_enter(&FR_Name,`), named in the column
   "Entered in".

The **98 call-site rows** come from every Windows code address named in `docs/DOS-PROFILE.md`, WI
sections 9.5 and 10 and draft A 4.3: where the listing shows a call of a key there (`call far Name`, or
`push cs` + `call Name`), the row is (callee, return address = the next instruction's address); other
addresses are not rows. `--check` regenerates both files in memory and compares (`test.cmd`:
`OBS_TABLES_OK probes 203 sites 98`); `tests/harness/obs_lint.py` checks every row against
`civ_frames.c` (name, address, `far_ret`) and the order (`OBS_LINT_OK files 27 probes 203 callsites 98`).

**Independent re-check with showfunc.** A session script ran `claude/tools/showfunc.py` on every row of
the generated `present/obs_tables.c` (not on the generator's inputs):

* for each key: showfunc's function header for the address names that function and starts at exactly
  that address (column "showfunc");
* for each call-site row: showfunc over the call address shows a `call` of the callee there, and the
  call address plus the instruction's length is the row's return address in the same segment.

Result: `SHOWFUNC probes 203 sites 98 mismatches 0` (2026-10-11, 11:02 UTC, on the tables of the final
Checked build).

**Frame kinds and far returns.** 202 keys are `FR_WIN_FAR` and one (`_ErrorMessage` 1000:4124, an rt
function) is `FR_FAR_BP`; every key has `far_ret 1`, so every call-site row compares the full
SSSS:OOOO return address (draft A 4.2, RV1-19). No key is `FR_NONE` or near (Open A6, settled): the
near (offset-only) and `FR_NONE` paths of the hooks are exercised by `tests/test_observer.c` on
synthetic frame descriptors.

**Reads only.** The hook (vm.c `probe_find`, `probe_call`) reads the open-addressing slot table and
passes the `FrameDesc`, the return address as `fr_enter` stored it, BP and SP; the entry hook runs
after the frame is complete, the exit hook as the first statement of `fr_leave`, before `vm_site` and
the control stack are restored and before any pop. It counts nothing in the emulation and runs inside
the observer's guard (`W16_OBS_GUARD_BEGIN(W16_OBS_IN_PROBE, id)` .. `W16_OBS_GUARD_END()`). In
Checked builds a listener that steps, posts, advances the clock, marks the screen dirty, writes
emulated memory, allocates a handle or selector, enters a frame, changes a register, emits an event or
installs a new probe table inside the guard faults with an `O4` message, as does a probe handler that
steps (`test_observer`: eleven trap cases); the sentinel compares `vm_steps`, `vm_site`, the CPU
registers, the clock, the queued input and the write and allocation counters before and after every
observer call. The `w16q_*` queries are reviewed in section 4.

**Hits.** The harness writes `observer-probes.log` (each key's entry and exit hits, the event counts
by type) and `presentation-diag.log` (the query diagnostics) at the end of every run. The column
"Hits" sums the 81 logs of the final Checked `test.cmd checked` run (2026-10-11 11:25..11:31 UTC; G-1
compared the same outputs: 11 runs under `build/harness/Checked`, 70 under `build/harness/game`; every
log newer than the build; the earlier Checked run of 11:03..11:09 UTC gave the same counts). The runs
install all 203 keys with no listener, so the counts are the hook's own: 192 keys hit, 39,161,306
entries and 36,898,206 exits in all. The P0 matrix of draft A 13.1 (`ext_p0.py`) is D3b's; its runs
will add hits. The diagnostics of all 81 runs: `bad_reads 0 bad_handles 0 forbidden 0 dropped 0
rgn_overflows 0 records 0`.

## 2. Probes

Columns: the key; the function; the phases (E entry, X exit); the frame kind and `far_ret` of its
`FrameDesc`; the port file whose function enters it; the showfunc check; the source of the key (WI
section, "widened" for phases widened by draft A 4.3, "A 4.3 addition" for draft A's additions and
area C's two keys); the hits, entry / exit, summed over the 81 runs (a phase the key does not have is
counted by the log as 0; entries exceed exits where a run ends inside the function, at its watchdog
or the game's exit).

| Key | Function | Phases | Kind, far_ret | Entered in | showfunc | Source | Hits E / X |
|---|---|---|---|---|---|---|---|
| 1000:4124 | _ErrorMessage | E | FR_FAR_BP 1 | `rt_exit.c` | OK | WI 10.7 | 0 / 0 |
| 1008:0ADD | PostOrderMenuKey | E | FR_WIN_FAR 1 | `seg002_1008_r.c` | OK | WI 10.7 | 19 / 0 |
| 1008:0E99 | CreateCivFonts | E, X | FR_WIN_FAR 1 | `seg002_1008_s.c` | OK | A 4.3 addition | 70 / 70 |
| 1010:0000 | ShowAboutBox | E, X | FR_WIN_FAR 1 | `seg003_1010.c` | OK | WI 10.7 | 1 / 1 |
| 1010:00D6 | AboutMovieCallback | E, X | FR_WIN_FAR 1 | `seg003_1010.c` | OK | A 4.3 addition | 152 / 152 |
| 1018:0000 | OpenReportScreenWithHeader | E | FR_WIN_FAR 1 | `seg003_1010.c` | OK | WI 10.7 | 10 / 0 |
| 1018:0380 | CloseReportScreen | E | FR_WIN_FAR 1 | `seg003_1010.c` | OK | WI 10.7 | 19 / 0 |
| 1018:03F0 | ShowScienceReport | E, X | FR_WIN_FAR 1 | `seg003_1010_r.c` | OK | WI 10.7 | 1 / 1 |
| 1018:067B | ShowMilitaryReport | E, X | FR_WIN_FAR 1 | `seg003_1010.c` | OK | WI 10.7 | 1 / 1 |
| 1018:09CC | DrawCasualtyReport | E | FR_WIN_FAR 1 | `seg003_1010.c` | OK | WI 10.7 | 1 / 0 |
| 1018:0BE0 | ShowTradeReport | E, X | FR_WIN_FAR 1 | `seg003_1010_r.c` | OK | WI 10.7 | 1 / 1 |
| 1018:1221 | ShowIntelligenceAdvisor | E, X | FR_WIN_FAR 1 | `seg004_1018_r.c` | OK | WI 10.7 | 1 / 1 |
| 1018:17DB | DrawCivDossier | E | FR_WIN_FAR 1 | `seg004_1018_r.c` | OK | WI 10.7 | 0 / 0 |
| 1018:1D5B | ShowAttitudeAdvisor | E, X | FR_WIN_FAR 1 | `seg004_1018_r.c` | OK | WI 10.7 | 1 / 1 |
| 1018:208F | ShowCityStatus | E, X | FR_WIN_FAR 1 | `seg004_1018_r.c` | OK | WI 10.7 | 1 / 1 |
| 1020:0000 | ShowCivilopediaEntry | E, X | FR_WIN_FAR 1 | `seg005_1020_r.c` | OK | WI 10.7 | 8 / 7 |
| 1028:0000 | GenerateWorldMap | E | FR_WIN_FAR 1 | `seg005_1020.c` | OK | WI 10.7 | 9 / 0 |
| 1030:0000 | ProcessCity | E, X | FR_WIN_FAR 1 | `seg007_1030_p1.c` | OK | WI 10.7 | 4167 / 4166 |
| 1030:84BE | DrawImprovementIconLogical | E, X | FR_WIN_FAR 1 | `seg007_1030_p2.c` | OK | WI 10.1 | 14 / 14 |
| 1030:8C11 | DrawBeveledLabelBox | E, X | FR_WIN_FAR 1 | `seg007_1030_p2.c` | OK | WI 10.1 | 0 / 0 |
| 1030:9C17 | CityScreenWndProc | E | FR_WIN_FAR 1 | `seg007_1030_p3.c` | OK | WI 10.7 | 206 / 0 |
| 1038:0C1D | WaitForKeyOrClick | E, X | FR_WIN_FAR 1 | `seg008_1038.c` | OK | WI 10.7 | 60 / 60 |
| 1040:068E | ProcessCityDisaster | E | FR_WIN_FAR 1 | `seg009_1040_p1.c` | OK | WI 10.7 | 3 / 0 |
| 1040:1137 | ShowCivilizationScore | E, X | FR_WIN_FAR 1 | `seg009_1040_p2_r.c` | OK | WI 10.7 | 249 / 249 |
| 1048:01CD | HandleMenuCommand | E | FR_WIN_FAR 1 | `seg010_1048.c` | OK | WI 10.7 | 147 / 0 |
| 1048:04E8 | OpenGameHelp | E, X | FR_WIN_FAR 1 | `seg010_1048.c` | OK | WI 10.7 | 1 / 1 |
| 1050:0000 | ResolveCombat | E, X | FR_WIN_FAR 1 | `seg011_1050_p1_r.c` | OK | WI 10.7 | 85 / 85 |
| 1058:0000 | PaintRandomRadio | E, X | FR_WIN_FAR 1 | `seg011_1050_t.c` | OK | WI 10.2; widened (A 4.3) | 1752 / 1752 |
| 1058:04F6 | PaintRandomStatic | E, X | FR_WIN_FAR 1 | `seg011_1050_t.c` | OK | WI 10.2; widened (A 4.3) | 375 / 375 |
| 1068:004C | ShowFindCityDialog | E, X | FR_WIN_FAR 1 | `seg013_1060.c` | OK | WI 10.7 | 2 / 1 |
| 1068:0295 | ShowCivilopediaSection | E, X | FR_WIN_FAR 1 | `seg013_1060.c` | OK | WI 10.7 | 6 / 6 |
| 1068:06AF | ShowPediaEntry | E, X | FR_WIN_FAR 1 | `seg014_1068_p1.c` | OK | WI 10.7 | 9 / 8 |
| 1068:1F7E | SetTextFontSizeColor | E | FR_WIN_FAR 1 | `seg014_1068_p2.c` | OK | WI 10.2 | 833 / 0 |
| 1068:2072 | TextBoxSetup | E, X | FR_WIN_FAR 1 | `seg014_1068_p2.c` | OK | WI 10.2 | 433 / 433 |
| 1068:255A | TextBoxDrawAndClose | E, X | FR_WIN_FAR 1 | `seg014_1068_p2_r.c` | OK | WI 10.2; widened (A 4.3) | 65 / 65 |
| 1068:258F | TextBoxDraw | E, X | FR_WIN_FAR 1 | `seg014_1068_p2.c` | OK | WI 10.2; widened (A 4.3) | 2207 / 2207 |
| 1070:0000 | OpenSpaceshipScreen | E | FR_WIN_FAR 1 | `seg015_1070_p1.c` | OK | WI 10.7 | 6 / 0 |
| 1070:0327 | EvaluateAndShowSpaceship | E, X | FR_WIN_FAR 1 | `seg015_1070_p1_r.c` | OK | WI 10.7 | 7 / 7 |
| 1070:12B5 | AnimateSpaceshipStarfield | E | FR_WIN_FAR 1 | `seg015_1070_p2.c` | OK | WI 10.7 | 996 / 0 |
| 1070:1952 | HumanPlaceSpaceshipPart | E, X | FR_WIN_FAR 1 | `seg015_1070_p2_r.c` | OK | WI 10.7 | 1 / 1 |
| 1070:1F58 | ShowSpaceshipOfChosenNation | E, X | FR_WIN_FAR 1 | `seg015_1070_p2.c` | OK | WI 10.7 | 1 / 1 |
| 1070:2015 | LaunchSpaceship | E | FR_WIN_FAR 1 | `seg015_1070_p2.c` | OK | WI 10.7 | 1 / 0 |
| 1080:0023 | LoadHallOfFame | E | FR_WIN_FAR 1 | `seg017_1080.c` | OK | WI 10.7 | 5 / 0 |
| 1080:0119 | ShowHallOfFame | E, X | FR_WIN_FAR 1 | `seg017_1080.c` | OK | WI 10.7 | 5 / 5 |
| 1080:0595 | InsertHallOfFameEntry | E, X | FR_WIN_FAR 1 | `seg017_1080_r.c` | OK | WI 10.7 | 3 / 3 |
| 1080:06FF | ShowCivilizationRatingRanking | E, X | FR_WIN_FAR 1 | `seg017_1080.c` | OK | WI 10.7 | 3 / 3 |
| 1080:099B | ShowTopFiveCities | E, X | FR_WIN_FAR 1 | `seg017_1080.c` | OK | WI 10.7 | 1 / 1 |
| 1088:0000 | ProcessGameTurn | E | FR_WIN_FAR 1 | `seg018_1088_p1.c` | OK | A 4.3 addition | 303 / 0 |
| 1088:0B6D | RunEndGameSequence | E, X | FR_WIN_FAR 1 | `seg018_1088_p1.c` | OK | WI 10.7 | 3 / 3 |
| 1088:13D5 | DrawStatusCivPanels | E, X | FR_WIN_FAR 1 | `seg018_1088_p2_r.c` | OK | WI 10.7; widened (A 4.3) | 773 / 773 |
| 1088:1A82 | DrawMiniPalace | E, X | FR_WIN_FAR 1 | `seg018_1088_p2.c` | OK | A 4.3 addition | 781 / 781 |
| 1090:015E | PushPalette | E | FR_WIN_FAR 1 | `seg019_1090_r.c` | OK | WI 10.7 | 9 / 0 |
| 1090:02D2 | PopPalette | E | FR_WIN_FAR 1 | `seg019_1090_r.c` | OK | WI 10.7 | 8 / 0 |
| 1090:0376 | SetGodPaletteEntries | E | FR_WIN_FAR 1 | `seg019_1090_s.c` | OK | WI 10.7 | 12969 / 0 |
| 1098:0157 | UpdateActiveAnimation | E | FR_WIN_FAR 1 | `seg019_1090.c` | OK | WI 10.5; WI 10.7 | 437101 / 0 |
| 1098:096C | SetGameCursor | E | FR_WIN_FAR 1 | `seg019_1090.c` | OK | WI 10.5 | 3556 / 0 |
| 1098:0ED1 | DrawTextInRect | E, X | FR_WIN_FAR 1 | `seg020_1098_p1.c` | OK | WI 10.2; widened (A 4.3) | 61387 / 61387 |
| 1098:124F | GR_DialogOpen | E, X | FR_WIN_FAR 1 | `seg020_1098_p1.c` | OK | WI 10.7 | 490 / 490 |
| 1098:1612 | GR_DialogClose | E | FR_WIN_FAR 1 | `seg020_1098_p1.c` | OK | WI 10.7 | 463 / 0 |
| 1098:1909 | RunListBoxDialog | E, X | FR_WIN_FAR 1 | `seg020_1098_p1_r.c` | OK | WI 10.7 | 8 / 7 |
| 1098:26D4 | ShowSaveFileDialog | E, X | FR_WIN_FAR 1 | `seg020_1098_p2_r.c` | OK | WI 10.7 | 32 / 32 |
| 1098:28E4 | ShowErrorMessage | E, X | FR_WIN_FAR 1 | `seg020_1098_p2.c` | OK | WI 10.7 | 0 / 0 |
| 10A8:0000 | CreatePaletteFade | E | FR_WIN_FAR 1 | `seg021_10A0_s.c` | OK | A 4.3 addition | 427 / 0 |
| 10A8:00B4 | DestroyPaletteFade | E | FR_WIN_FAR 1 | `seg021_10A0_s.c` | OK | A 4.3 addition | 422 / 0 |
| 10A8:00FC | StepPaletteFadeIn | E | FR_WIN_FAR 1 | `seg021_10A0_s.c` | OK | A 4.3 addition | 4419 / 0 |
| 10A8:018E | StepPaletteFadeOut | E | FR_WIN_FAR 1 | `seg021_10A0_s.c` | OK | A 4.3 addition | 7180 / 0 |
| 10A8:0228 | ApplyPaletteFadeLevel | E | FR_WIN_FAR 1 | `seg021_10A0_s.c` | OK | A 4.3 addition | 11251 / 0 |
| 10B0:0000 | StepActiveSequence | E, X | FR_WIN_FAR 1 | `seg021_10A0.c` | OK | A 4.3 addition | 437101 / 437101 |
| 10B0:005B | SeekSequence | E | FR_WIN_FAR 1 | `seg021_10A0_s.c` | OK | WI 10.5; WI 10.7 | 66 / 0 |
| 10B0:008A | CreateSequencePlayer | E | FR_WIN_FAR 1 | `seg021_10A0_s.c` | OK | WI 10.5; WI 10.7 | 80 / 0 |
| 10B0:0287 | DestroySequencePlayer | E | FR_WIN_FAR 1 | `seg021_10A0_s.c` | OK | WI 10.5 | 69 / 0 |
| 10B0:03B0 | RedrawSequenceWindow | E, X | FR_WIN_FAR 1 | `seg021_10A0_s.c` | OK | A 4.3 addition | 236 / 236 |
| 10B0:0461 | AdvanceMovie | E, X | FR_WIN_FAR 1 | `seg023_10B0_p1.c` | OK | WI 10.5 | 35039334 / 35039321 |
| 10B8:0000 | ConvertArtworkFor16ColorDisplay | E | FR_WIN_FAR 1 | `seg023_10B0_p2.c` | OK | WI 10.7 | 70 / 0 |
| 10B8:079D | GR_PicRead | E, X | FR_WIN_FAR 1 | `seg023_10B0_p2.c` | OK | WI 10.3 | 900 / 900 |
| 10B8:0E00 | LoadPictureToPortBitmap | E, X | FR_WIN_FAR 1 | `seg023_10B0_p2.c` | OK | WI 10.3 | 101 / 101 |
| 10B8:0E36 | GR_PortDataToBitmap | E, X | FR_WIN_FAR 1 | `seg024_10B8.c` | OK | A 4.3 addition | 535 / 535 |
| 10D0:0000 | GR_PortOpen | E, X | FR_WIN_FAR 1 | `seg027_10D0.c` | OK | A 4.3 addition | 2396 / 2396 |
| 10D0:03FA | CopyPortBits | E, X | FR_WIN_FAR 1 | `seg027_10D0.c` | OK | A 4.3 addition | 36631 / 36631 |
| 10D0:0854 | CopyPortToWindow | E, X | FR_WIN_FAR 1 | `seg027_10D0.c` | OK | A 4.3 addition | 105976 / 105976 |
| 10D0:0956 | SetGrPort | E, X | FR_WIN_FAR 1 | `seg027_10D0_t.c` | OK | A 4.3 addition | 176082 / 176082 |
| 10D8:0000 | DrawScreenLine | E, X | FR_WIN_FAR 1 | `seg028_10D8_r.c` | OK | WI 10.1 | 40 / 40 |
| 10D8:00E0 | DrawTextAtPortXY | E, X | FR_WIN_FAR 1 | `seg028_10D8_r.c` | OK | WI 10.2; widened (A 4.3) | 18714 / 18714 |
| 10D8:01B0 | DrawScreenText | E, X | FR_WIN_FAR 1 | `seg028_10D8_r.c` | OK | WI 10.1 | 544 / 544 |
| 10D8:01FA | DrawShadowedScreenText | E, X | FR_WIN_FAR 1 | `seg028_10D8.c` | OK | WI 10.1 | 91 / 91 |
| 10D8:02DF | DrawScreenTextWithShadow | E, X | FR_WIN_FAR 1 | `seg028_10D8.c` | OK | WI 10.1 | 125 / 125 |
| 10D8:046E | DrawCenteredShadowedScreenText | E, X | FR_WIN_FAR 1 | `seg028_10D8_r.c` | OK | WI 10.1 | 34 / 34 |
| 10D8:0495 | DrawCenteredScreenTextWithShadow | E, X | FR_WIN_FAR 1 | `seg028_10D8_r.c` | OK | WI 10.1 | 34 / 34 |
| 10D8:0528 | DrawCenteredScreenText | E, X | FR_WIN_FAR 1 | `seg028_10D8_r.c` | OK | WI 10.1 | 259 / 259 |
| 10D8:05B8 | GetScreenTextWidth | E, X | FR_WIN_FAR 1 | `seg028_10D8_r.c` | OK | WI 10.1 | 302 / 302 |
| 10E0:0000 | ShowHelpNote | E | FR_WIN_FAR 1 | `seg028_10D8_r.c` | OK | WI 10.7 | 0 / 0 |
| 10E0:03A2 | ShowTextNoteDialog | E, X | FR_WIN_FAR 1 | `seg028_10D8_r2.c` | OK | WI 10.7 | 24 / 22 |
| 10E0:077F | ShowInstantAdvice | E | FR_WIN_FAR 1 | `seg028_10D8_r.c` | OK | WI 10.7 | 31 / 0 |
| 10E0:07E8 | ShowErrorNote | E | FR_WIN_FAR 1 | `seg028_10D8_r.c` | OK | WI 10.7 | 5 / 0 |
| 10E8:0000 | RunNewGameSetup | E, X | FR_WIN_FAR 1 | `seg030_10E8_p1.c` | OK | WI 10.7 | 9 / 8 |
| 10E8:231F | ExtractGameSpriteShapes | E, X | FR_WIN_FAR 1 | `seg030_10E8_p3.c` | OK | A 4.3 addition | 68 / 68 |
| 10E8:2D46 | InitGameColorTables | E, X | FR_WIN_FAR 1 | `seg030_10E8_p3_r.c` | OK | A 4.3 addition | 65 / 65 |
| 10E8:32C1 | AnnounceGovernmentChange | E | FR_WIN_FAR 1 | `seg030_10E8_p3_r.c` | OK | WI 10.7 | 0 / 0 |
| 10E8:33B9 | ExtractPictureTile1x | E, X | FR_WIN_FAR 1 | `seg030_10E8_p3.c` | OK | WI 10.3 | 544 / 544 |
| 10F0:0000 | PromptCityName | E, X | FR_WIN_FAR 1 | `seg031_10F0_r.c` | OK | WI 10.7 | 7 / 7 |
| 10F0:0066 | RunTextEntryDialog | E, X | FR_WIN_FAR 1 | `seg031_10F0_r.c` | OK | WI 10.7 | 7 / 7 |
| 1108:0000 | PollMouseClick | E, X | FR_WIN_FAR 1 | `seg034_1108_r.c` | OK | WI 10.7 | 533453 / 533446 |
| 1108:01BC | BeginWorldCreation | E, X | FR_WIN_FAR 1 | `seg034_1108_s.c` | OK | WI 10.7 | 9 / 9 |
| 1108:0243 | CustomizeWorldDialog | E, X | FR_WIN_FAR 1 | `seg034_1108_r.c` | OK | WI 10.7 | 1 / 1 |
| 1108:0705 | CustomizeWorldWndProc | E | FR_WIN_FAR 1 | `seg034_1108_r.c` | OK | WI 10.7 | 5 / 0 |
| 1110:0127 | FlushTileCache | E, X | FR_WIN_FAR 1 | `seg034_1108_r.c` | OK | A 4.3 addition | 10 / 10 |
| 1110:01A3 | TileCacheInsert | E, X | FR_WIN_FAR 1 | `seg034_1108.c` | OK | WI 10.4 | 3198 / 3198 |
| 1110:030C | TileCacheLookup | E, X | FR_WIN_FAR 1 | `seg034_1108.c` | OK | WI 10.4; widened (A 4.3) | 14672 / 14672 |
| 1110:03E9 | SetMapViewAndRedraw | E | FR_WIN_FAR 1 | `seg034_1108_r.c` | OK | WI 10.7 | 161 / 0 |
| 1110:04D0 | DrawMapTile | E, X | FR_WIN_FAR 1 | `seg035_1110_p1_s.c` | OK | WI 10.6; widened (A 4.3) | 14822 / 14822 |
| 1110:0DBA | DrawUnit | E, X | FR_WIN_FAR 1 | `seg035_1110_p1_s.c` | OK | WI 10.6; widened (A 4.3) | 4204 / 4204 |
| 1110:0FF6 | DrawUnitAt | E, X | FR_WIN_FAR 1 | `seg035_1110_p1_s.c` | OK | WI 10.6; widened (A 4.3) | 12015 / 12015 |
| 1110:1461 | RedrawMapSquare | E | FR_WIN_FAR 1 | `seg035_1110_p1_s.c` | OK | WI 10.6 | 11769 / 0 |
| 1118:04B4 | ComputeTileAppearanceKey | X | FR_WIN_FAR 1 | `seg035_1110_p2_s.c` | OK | WI 10.6 | 0 / 14672 |
| 1130:000E | LoadGameFromFileDialog | E, X | FR_WIN_FAR 1 | `seg039_1130.c` | OK | WI 10.7 | 48 / 48 |
| 1138:0000 | ShowNewspaper | E, X | FR_WIN_FAR 1 | `seg039_1130_r.c` | OK | WI 10.7 | 5 / 5 |
| 1150:00C9 | PlaySoundEffect | E | FR_WIN_FAR 1 | `seg041_1140.c` | OK | WI 10.7 | 651 / 0 |
| 1158:0000 | RunPalaceImprovement | E, X | FR_WIN_FAR 1 | `seg041_1140_r2.c` | OK | WI 10.7 | 1 / 1 |
| 1158:08E7 | OpenPalaceView | E, X | FR_WIN_FAR 1 | `seg044_1158_r.c` | OK | WI 10.7 | 3 / 3 |
| 1160:0000 | HoldDiplomaticAudience | E, X | FR_WIN_FAR 1 | `seg045_1160_p1.c` | OK | WI 10.7 | 43 / 42 |
| 1160:20C0 | RequestLeaderAudience | E, X | FR_WIN_FAR 1 | `seg045_1160_p2_r.c` | OK | WI 10.7 | 92 / 91 |
| 1160:2A38 | LoadLeaderScreen | E | FR_WIN_FAR 1 | `seg045_1160_p2_r.c` | OK | WI 10.7 | 40 / 0 |
| 1160:33FC | ExtractScaledTile | E, X | FR_WIN_FAR 1 | `seg045_1160_p2_r.c` | OK | WI 10.1 | 147 / 147 |
| 1168:06C1 | SetGovernment | E | FR_WIN_FAR 1 | `seg046_1168.c` | OK | WI 10.7 | 43 / 0 |
| 1170:05CA | ChooseCityProduction | E, X | FR_WIN_FAR 1 | `seg047_1170_p2.c` | OK | WI 10.7 | 1453 / 1453 |
| 1170:21B3 | CompleteResearch | E, X | FR_WIN_FAR 1 | `seg047_1170_p3_r2.c` | OK | WI 10.7 | 154 / 154 |
| 1178:0022 | AskCivilizationQuizQuestion | E, X | FR_WIN_FAR 1 | `seg048_1178_r.c` | OK | WI 10.7 | 7 / 7 |
| 1180:0000 | RunReplayMenu | E, X | FR_WIN_FAR 1 | `seg048_1178_r.c` | OK | WI 10.7 | 2 / 2 |
| 1180:017A | ChooseReplayModeAndOpenWindow | E | FR_WIN_FAR 1 | `seg048_1178.c` | OK | WI 10.7 | 4 / 0 |
| 1180:02D3 | PlayReplay | E, X | FR_WIN_FAR 1 | `seg049_1180_p1_r.c` | OK | WI 10.7 | 3 / 3 |
| 1180:0E78 | ShowReplayLine | E | FR_WIN_FAR 1 | `seg049_1180_p1.c` | OK | WI 10.7 | 49 / 0 |
| 1180:152F | ShowConquerorEnding | E, X | FR_WIN_FAR 1 | `seg049_1180_p2.c` | OK | WI 10.7 | 1 / 1 |
| 1180:17E9 | ShowConqueredCivLeader | E | FR_WIN_FAR 1 | `seg049_1180_p2_r.c` | OK | WI 10.7 | 0 / 0 |
| 1188:0000 | OpenBlankReportScreen | E | FR_WIN_FAR 1 | `seg050_1188_p1.c` | OK | WI 10.7 | 9 / 0 |
| 1188:013F | ShowWorldMap | E, X | FR_WIN_FAR 1 | `seg050_1188_p1.c` | OK | WI 10.7 | 1 / 1 |
| 1188:07AD | ShowPowerGraph | E, X | FR_WIN_FAR 1 | `seg050_1188_p1_r.c` | OK | WI 10.7 | 3 / 3 |
| 1188:0B3E | ShowWondersOfTheWorld | E, X | FR_WIN_FAR 1 | `seg050_1188_p1.c` | OK | WI 10.7 | 1 / 1 |
| 1188:0DB8 | ShowHistorianReport | E, X | FR_WIN_FAR 1 | `seg050_1188_p1_r.c` | OK | WI 10.7 | 2 / 2 |
| 1188:123A | ShowDemographicsReport | E, X | FR_WIN_FAR 1 | `seg050_1188_p2_r.c` | OK | WI 10.7 | 1 / 1 |
| 11A0:0000 | StartCivilWar | E | FR_WIN_FAR 1 | `seg053_11A0_r.c` | OK | WI 10.7 | 1 / 0 |
| 11A8:002C | SetTileScale | E | FR_WIN_FAR 1 | `seg054_11A8_p1_r.c` | OK | WI 10.6 | 1212 / 0 |
| 11A8:00FE | GetTileOpaqueBounds | X | FR_WIN_FAR 1 | `seg054_11A8_p1.c` | OK | WI 10.3 | 0 / 12018 |
| 11A8:022F | ReplaceTileColor | E | FR_WIN_FAR 1 | `seg054_11A8_p1.c` | OK | WI 10.4 | 30666 / 0 |
| 11A8:05C7 | TileExtract | E, X | FR_WIN_FAR 1 | `seg054_11A8_p1.c` | OK | WI 10.3 | 47950 / 47950 |
| 11A8:0CB1 | DrawTile | E | FR_WIN_FAR 1 | `seg054_11A8_p1.c` | OK | WI 10.3 | 31187 / 0 |
| 11B0:0000 | ShowCityView | E, X | FR_WIN_FAR 1 | `seg055_11B0_p1_r.c` | OK | WI 10.7 | 6 / 6 |
| 11B0:1B63 | PlayCityCaptureAnimation | E, X | FR_WIN_FAR 1 | `seg055_11B0_p2.c` | OK | WI 10.7 | 4 / 4 |
| 11B0:1FAC | PlayCivilDisorderAnimation | E, X | FR_WIN_FAR 1 | `seg055_11B0_p2.c` | OK | WI 10.7 | 1 / 1 |
| 11B0:237C | PlayCelebrationAnimation | E, X | FR_WIN_FAR 1 | `seg055_11B0_p2.c` | OK | WI 10.7 | 0 / 0 |
| 11B8:0000 | DiplomatEntersCity | E | FR_WIN_FAR 1 | `seg056_11B8_p1_r.c` | OK | WI 10.7 | 3 / 0 |
| 11B8:0C3D | AnimateNuclearExplosion | E, X | FR_WIN_FAR 1 | `seg056_11B8_p1.c` | OK | WI 10.7 | 0 / 0 |
| 11B8:0F26 | TransferCityByRevolt | E | FR_WIN_FAR 1 | `seg056_11B8_p2.c` | OK | WI 10.7 | 1 / 0 |
| 11B8:14E5 | ShowCityFoundedAnimation | E, X | FR_WIN_FAR 1 | `seg056_11B8_p2.c` | OK | WI 10.7 | 6 / 6 |
| 11C0:0395 | UpdateUnitSightAndContacts | X | FR_WIN_FAR 1 | `seg057_11C0_p1.c` | OK | A 4.3 addition | 0 / 7867 |
| 11C0:0EC2 | BlinkActiveUnitUntilInput | E, X | FR_WIN_FAR 1 | `seg057_11C0_p1_r.c` | OK | WI 10.7 | 1868 / 1824 |
| 11C0:16A4 | DeleteUnit | X | FR_WIN_FAR 1 | `seg057_11C0_p2_r.c` | OK | A 4.3 addition | 0 / 259 |
| 11C0:2C32 | AnimateUnitMove | E, X | FR_WIN_FAR 1 | `seg057_11C0_p3.c` | OK | WI 10.7 | 71 / 71 |
| 11C0:3023 | ShowUnitStackDialog | E, X | FR_WIN_FAR 1 | `seg057_11C0_p3.c` | OK | WI 10.7 | 2 / 2 |
| 11C0:3407 | DrawUnitStackList | E | FR_WIN_FAR 1 | `seg057_11C0_p3.c` | OK | A 4.3 addition | 3 / 0 |
| 11C8:003D | RandomBelow | X | FR_WIN_FAR 1 | `seg057_11C0_p4.c` | OK | A 4.3 addition | 0 / 155475 |
| 11C8:008A | DrawMapSprite | E, X | FR_WIN_FAR 1 | `seg057_11C0_p4_s.c` | OK | WI 10.1 | 12072 / 12072 |
| 11D0:00E4 | LoadTextResource | E | FR_WIN_FAR 1 | `seg057_11C0_p4_r.c` | OK | WI 10.2 | 211 / 0 |
| 11D0:01F7 | LoadKingText | E | FR_WIN_FAR 1 | `seg057_11C0_p4_r.c` | OK | WI 10.2 | 182 / 0 |
| 11D0:022D | SubstituteTextTokens | X | FR_WIN_FAR 1 | `seg057_11C0_p4_r.c` | OK | WI 10.2 | 0 / 237 |
| 11D0:02E4 | TruncateStringToLogicalWidth | E, X | FR_WIN_FAR 1 | `seg057_11C0_p4_r.c` | OK | WI 10.1 | 101 / 101 |
| 11D8:0000 | ShowSpaceshipArrival | E, X | FR_WIN_FAR 1 | `seg060_11D8.c` | OK | WI 10.7 | 1 / 1 |
| 11D8:087F | ShowCivilizationDestroyed | E, X | FR_WIN_FAR 1 | `seg060_11D8.c` | OK | WI 10.7 | 2 / 2 |
| 11D8:0BD2 | WaitTicksOrInput | E, X | FR_WIN_FAR 1 | `seg060_11D8.c` | OK | WI 10.7 | 24 / 24 |
| 11E0:0000 | RunIntroAndTitleMenu | E, X | FR_WIN_FAR 1 | `seg061_11E0.c` | OK | WI 10.7 | 70 / 56 |
| 11E0:0221 | IntroMovieCallback | E | FR_WIN_FAR 1 | `seg061_11E0.c` | OK | WI 10.5; WI 10.7 | 89019 / 0 |
| 11E0:091E | BirthMovieCallback | E | FR_WIN_FAR 1 | `seg061_11E0_r.c` | OK | WI 10.5; WI 10.7 | 11432 / 0 |
| 11E0:095F | PumpMessagesCheckSkipInput | E, X | FR_WIN_FAR 1 | `seg061_11E0.c` | OK | A 4.3 addition | 5067 / 5067 |
| 11E0:09D0 | LoadGameSpriteSheet | E, X | FR_WIN_FAR 1 | `seg061_11E0.c` | OK | A 4.3 addition | 68 / 68 |
| 11E8:02FB | IsKeyPending | E | FR_WIN_FAR 1 | `seg062_11E8_s.c` | OK | A 4.3 addition | 1771481 / 0 |
| 11E8:0504 | FillRectLogical | E, X | FR_WIN_FAR 1 | `seg062_11E8_r.c` | OK | WI 10.1 | 137 / 137 |
| 11E8:0674 | DrawShapeAndFlush | E, X | FR_WIN_FAR 1 | `seg062_11E8_s.c` | OK | WI 10.1 | 12084 / 12084 |
| 11E8:07C3 | FlushSquareToWindow | E, X | FR_WIN_FAR 1 | `seg062_11E8_s.c` | OK | WI 10.1 | 11965 / 11965 |
| 11E8:097C | ExtractPictureTile2x | E, X | FR_WIN_FAR 1 | `seg062_11E8_s.c` | OK | WI 10.3 | 39372 / 39372 |
| 11E8:0B40 | SetCivFont | E | FR_WIN_FAR 1 | `seg062_11E8_s.c` | OK | WI 10.2 | 12016 / 0 |
| 11E8:0D81 | ScaleLogicalX | E, X | FR_WIN_FAR 1 | `seg062_11E8_s.c` | OK | WI 10.1 | 1023 / 1023 |
| 11E8:0DA8 | ScaleLogicalY | E, X | FR_WIN_FAR 1 | `seg062_11E8_s.c` | OK | WI 10.1 | 1042 / 1042 |
| 11F0:468C | DrawUnitInfoPanel | E, X | FR_WIN_FAR 1 | `seg063_11F0_p2_r.c` | OK | WI 10.7; widened (A 4.3) | 3164 / 3164 |
| 1200:0116 | AnimatePaletteFromGrPort | E | FR_WIN_FAR 1 | `seg064_11F8.c` | OK | WI 10.7 | 524 / 0 |
| 1208:0AF1 | WdwMapOpen | E, X | FR_WIN_FAR 1 | `seg064_11F8_r.c` | OK | WI 10.7; widened (A 4.3) | 56 / 56 |
| 1208:14D5 | RestoreMapAfterDialog | E | FR_WIN_FAR 1 | `seg066_1208_p1.c` | OK | WI 10.7 | 323 / 0 |
| 1208:1534 | RedrawMapRect | E, X | FR_WIN_FAR 1 | `seg066_1208_p1_r.c` | OK | A 4.3 addition | 0 / 0 |
| 1208:17DA | RedrawMapWindow | E | FR_WIN_FAR 1 | `seg066_1208_p1.c` | OK | WI 10.7 | 497 / 0 |
| 1208:1866 | DrawTilesToPort | E, X | FR_WIN_FAR 1 | `seg066_1208_p1.c` | OK | WI 10.6 | 497 / 497 |
| 1208:1DD7 | CollectVisibleCityLabels | E | FR_WIN_FAR 1 | `seg066_1208_p1.c` | OK | WI 10.6 | 174 / 0 |
| 1208:1F64 | DrawCityLabels | E, X | FR_WIN_FAR 1 | `seg066_1208_p1.c` | OK | WI 10.6; widened (A 4.3) | 48907 / 48907 |
| 1208:22B7 | CyclePaletteColors | E | FR_WIN_FAR 1 | `seg066_1208_p2_r.c` | OK | WI 10.7 | 8938 / 0 |
| 1210:073F | RedrawSmMap | E, X | FR_WIN_FAR 1 | `seg066_1208_p2_r.c` | OK | WI 10.7; widened (A 4.3) | 268 / 268 |
| 1210:07AE | PlotSmMapSquare | E, X | FR_WIN_FAR 1 | `seg066_1208_p2_r.c` | OK | A 4.3 addition | 5843 / 5843 |
| 1210:09B4 | DrawSmTiles | E, X | FR_WIN_FAR 1 | `seg066_1208_p2.c` | OK | WI 10.7; widened (A 4.3) | 442 / 442 |
| 1218:0000 | WdwStatusProc | E | FR_WIN_FAR 1 | `seg068_1218.c` | OK | WI 10.7 | 2679 / 0 |
| 1218:0801 | RedrawStatusWindow | E, X | FR_WIN_FAR 1 | `seg068_1218.c` | OK | WI 10.7; widened (A 4.3) | 56 / 56 |
| 1220:0000 | SplitMenuText | X | FR_WIN_FAR 1 | `seg069_1220_p1.c` | OK | WI 10.2 | 0 / 438 |
| 1220:00D2 | ShowTextDialog | E, X | FR_WIN_FAR 1 | `seg069_1220_p1.c` | OK | WI 10.2; WI 10.7 | 156 / 154 |
| 1220:0156 | MenuZ | E, X | FR_WIN_FAR 1 | `seg069_1220_p1.c` | OK | WI 10.2; WI 10.7 | 438 / 426 |
| 1220:0F2F | MapLogicalPointToPort | E, X | FR_WIN_FAR 1 | `seg069_1220_p1.c` | OK | WI 10.1 | 36887 / 36887 |
| 1220:1086 | FrameRectLogical | E, X | FR_WIN_FAR 1 | `seg069_1220_p1_r.c` | OK | WI 10.1 | 17 / 17 |
| 1220:114B | FrameRectDoubleDevice | E, X | FR_WIN_FAR 1 | `seg069_1220_p1_r.c` | OK | WI 10.1 | 0 / 0 |
| 1220:16FD | RunTextInputDialog | E, X | FR_WIN_FAR 1 | `seg069_1220_p2_r.c` | OK | WI 10.7 | 8 / 8 |

### Keys the runs never hit

11 of the 203 keys had no hit in any of the 81 runs (draft A 6.3: "The record lists probes the P0
matrix never hit"). Each is entered by its port function (generation check 3) and passed showfunc;
the base scenarios do not reach these screens or paths:

| Key | Function | Path |
|---|---|---|
| 1000:4124 | `_ErrorMessage` | the C run-time error box (no base run fails) |
| 1018:17DB | `DrawCivDossier` | a civilization's dossier |
| 1030:8C11 | `DrawBeveledLabelBox` | only `ShowIntelligenceAdvisor`'s labels (WI 7.2, 10.1) |
| 1098:28E4 | `ShowErrorMessage` | the game's error box (`DOS-PROFILE.md` 4.1) |
| 10E0:0000 | `ShowHelpNote` | a help note |
| 10E8:32C1 | `AnnounceGovernmentChange` | a change of government |
| 1180:17E9 | `ShowConqueredCivLeader` | a conquered civilization's leader |
| 11B0:237C | `PlayCelebrationAnimation` | the celebrants' animation |
| 11B8:0C3D | `AnimateNuclearExplosion` | a nuclear explosion |
| 1208:1534 | `RedrawMapRect` | area D's map key (draft A 4.3, A-7); no run's path calls it |
| 1220:114B | `FrameRectDoubleDevice` | only `EvaluateAndShowSpaceship`'s device-pixel outline (WI 7.2, 10.1) |

D3b's P0 matrix (`ext_p0.py`, draft A 13.1) and the probe handlers' own tests (D4 onwards) reach
further screens; the list is re-derived from their `observer-probes.log` files.

## 3. Call-site rows

Columns: the callee (a key); the call instruction's address; the return address (the next
instruction); the showfunc check; the document that names the address. Every callee has `far_ret 1`,
so `obs_callsite` compares the full return address.

| Callee | Call | Return address | showfunc | Source |
|---|---|---|---|---|
| 1028:0000 GenerateWorldMap | 1108:0211 | 1108:0216 | OK | DOS-PROFILE.md |
| 1080:0119 ShowHallOfFame | 1080:06E2 | 1080:06E5 | OK | WI 10 |
| 1080:0119 ShowHallOfFame | 11E0:0842 | 11E0:0847 | OK | DOS-PROFILE.md |
| 1090:0376 SetGodPaletteEntries | 1068:0763 | 1068:0768 | OK | DOS-PROFILE.md |
| 1090:0376 SetGodPaletteEntries | 11D8:0325 | 11D8:032A | OK | DOS-PROFILE.md |
| 1090:0376 SetGodPaletteEntries | 11D8:0A82 | 11D8:0A87 | OK | DOS-PROFILE.md |
| 1090:0376 SetGodPaletteEntries | 11E0:0065 | 11E0:006A | OK | DOS-PROFILE.md |
| 1098:096C SetGameCursor | 11E0:08D2 | 11E0:08D7 | OK | A 4.3 |
| 1098:096C SetGameCursor | 11E0:0949 | 11E0:094E | OK | A 4.3 |
| 1098:124F GR_DialogOpen | 1010:0024 | 1010:0029 | OK | DOS-PROFILE.md |
| 1098:124F GR_DialogOpen | 1020:0040 | 1020:0045 | OK | DOS-PROFILE.md |
| 1098:124F GR_DialogOpen | 1030:00F3 | 1030:00F8 | OK | DOS-PROFILE.md |
| 1098:124F GR_DialogOpen | 1098:1931 | 1098:1934 | OK | DOS-PROFILE.md |
| 1098:124F GR_DialogOpen | 10B8:0115 | 10B8:011A | OK | DOS-PROFILE.md |
| 1098:124F GR_DialogOpen | 10E0:03C2 | 10E0:03C7 | OK | DOS-PROFILE.md |
| 1098:124F GR_DialogOpen | 10E8:0062 | 10E8:0067 | OK | DOS-PROFILE.md |
| 1098:124F GR_DialogOpen | 10E8:10B9 | 10E8:10BE | OK | DOS-PROFILE.md |
| 1098:124F GR_DialogOpen | 10F0:007E | 10F0:0083 | OK | DOS-PROFILE.md |
| 1098:124F GR_DialogOpen | 1108:028B | 1108:0290 | OK | DOS-PROFILE.md |
| 1098:124F GR_DialogOpen | 1160:2251 | 1160:2256 | OK | DOS-PROFILE.md |
| 1098:124F GR_DialogOpen | 1170:0651 | 1170:0656 | OK | DOS-PROFILE.md |
| 1098:124F GR_DialogOpen | 1170:246D | 1170:2472 | OK | DOS-PROFILE.md |
| 1098:124F GR_DialogOpen | 1178:003C | 1178:0041 | OK | DOS-PROFILE.md |
| 1098:124F GR_DialogOpen | 11C0:30BB | 11C0:30C0 | OK | DOS-PROFILE.md |
| 1098:124F GR_DialogOpen | 11E0:003F | 11E0:0044 | OK | A 4.3 |
| 1098:124F GR_DialogOpen | 11E0:06C0 | 11E0:06C5 | OK | DOS-PROFILE.md |
| 1098:124F GR_DialogOpen | 1220:00FD | 1220:0102 | OK | DOS-PROFILE.md |
| 1098:1612 GR_DialogClose | 11E0:0212 | 11E0:0217 | OK | A 4.3 |
| 1098:1909 RunListBoxDialog | 1068:0183 | 1068:0188 | OK | DOS-PROFILE.md |
| 1098:1909 RunListBoxDialog | 1068:0544 | 1068:0549 | OK | DOS-PROFILE.md |
| 1098:26D4 ShowSaveFileDialog | 1180:00A7 | 1180:00AC | OK | DOS-PROFILE.md |
| 1098:26D4 ShowSaveFileDialog | 1198:0178 | 1198:017D | OK | WI 10 |
| 1098:28E4 ShowErrorMessage | 1220:0225 | 1220:022A | OK | DOS-PROFILE.md |
| 10B0:005B SeekSequence | 11E0:01A5 | 11E0:01AA | OK | DOS-PROFILE.md |
| 10B0:005B SeekSequence | 11E0:0884 | 11E0:0889 | OK | DOS-PROFILE.md |
| 10B0:005B SeekSequence | 11E0:090D | 11E0:0912 | OK | WI 10 |
| 10B0:008A CreateSequencePlayer | 11E0:00A0 | 11E0:00A5 | OK | WI 10 |
| 10B0:0287 DestroySequencePlayer | 11E0:010F | 11E0:0114 | OK | A 4.3 |
| 10B0:0287 DestroySequencePlayer | 11E0:01E3 | 11E0:01E8 | OK | A 4.3 |
| 10B8:079D GR_PicRead | 1028:0096 | 1028:009B | OK | DOS-PROFILE.md |
| 10E8:0000 RunNewGameSetup | 11E0:0205 | 11E0:020A | OK | A 4.3 |
| 10F0:0000 PromptCityName | 1030:5F7F | 1030:5F84 | OK | DOS-PROFILE.md |
| 10F0:0000 PromptCityName | 1040:00FF | 1040:0104 | OK | DOS-PROFILE.md |
| 1108:0000 PollMouseClick | 1018:1641 | 1018:1646 | OK | DOS-PROFILE.md |
| 1108:0000 PollMouseClick | 1180:0DC8 | 1180:0DCD | OK | DOS-PROFILE.md |
| 1108:0000 PollMouseClick | 11C0:11A2 | 11C0:11A7 | OK | DOS-PROFILE.md |
| 1108:0000 PollMouseClick | 11D8:07DB | 11D8:07E0 | OK | DOS-PROFILE.md |
| 1108:0000 PollMouseClick | 11D8:0BFC | 11D8:0C01 | OK | DOS-PROFILE.md |
| 1108:01BC BeginWorldCreation | 11E0:01AD | 11E0:01B2 | OK | DOS-PROFILE.md |
| 1108:0243 CustomizeWorldDialog | 11E0:0821 | 11E0:0826 | OK | A 4.3 |
| 1110:04D0 DrawMapTile | 1110:04AB | 1110:04AE | OK | WI 10 |
| 1110:04D0 DrawMapTile | 1188:047A | 1188:047F | OK | WI 10 |
| 1110:1461 RedrawMapSquare | 1208:1B40 | 1208:1B45 | OK | WI 10 |
| 1110:1461 RedrawMapSquare | 1208:1C5F | 1208:1C64 | OK | WI 10 |
| 1130:000E LoadGameFromFileDialog | 11E0:0802 | 11E0:0807 | OK | DOS-PROFILE.md |
| 1138:0000 ShowNewspaper | 10E8:335E | 10E8:3363 | OK | WI 10 |
| 11A8:0CB1 DrawTile | 1050:0AEA | 1050:0AEF | OK | DOS-PROFILE.md |
| 11C0:3023 ShowUnitStackDialog | 11F0:0BFA | 11F0:0BFF | OK | DOS-PROFILE.md |
| 11C0:3407 DrawUnitStackList | 11C0:334C | 11C0:334F | OK | A 4.3 |
| 11C8:003D RandomBelow | 1138:01B8 | 1138:01BD | OK | A 4.3 |
| 11C8:003D RandomBelow | 1138:03C2 | 1138:03C7 | OK | A 4.3 |
| 11D8:087F ShowCivilizationDestroyed | 1088:0189 | 1088:018E | OK | DOS-PROFILE.md |
| 11E8:02FB IsKeyPending | 1220:0AA0 | 1220:0AA5 | OK | A 4.3 |
| 1200:0116 AnimatePaletteFromGrPort | 1018:2514 | 1018:2519 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 1068:0674 | 1068:0679 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 1068:1199 | 1068:119E | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 1070:0122 | 1070:0127 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 1080:018D | 1080:0192 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 10E8:0154 | 10E8:0159 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 1108:0302 | 1108:0307 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 1158:0A81 | 1158:0A86 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 1158:0B4E | 1158:0B53 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 1160:2C58 | 1160:2C5D | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 1170:24A2 | 1170:24A7 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 1170:25BB | 1170:25C0 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 1178:0208 | 1178:020D | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 1180:165E | 1180:1663 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 1180:184B | 1180:1850 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 11B0:0ACA | 11B0:0ACF | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 11B0:134D | 11B0:1352 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 11B0:1D5F | 11B0:1D64 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 11B0:2114 | 11B0:2119 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 11B0:243D | 11B0:2442 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 11B8:0C8B | 11B8:0C90 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 11B8:15A2 | 11B8:15A7 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 11D8:010F | 11D8:0114 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 11D8:0644 | 11D8:0649 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 11D8:0910 | 11D8:0915 | OK | WI 9.5 |
| 1200:0116 AnimatePaletteFromGrPort | 1220:0B3F | 1220:0B44 | OK | WI 9.5 |
| 1208:14D5 RestoreMapAfterDialog | 1098:16D6 | 1098:16DB | OK | WI 10 |
| 1208:1F64 DrawCityLabels | 1208:1B66 | 1208:1B69 | OK | WI 10 |
| 1208:1F64 DrawCityLabels | 1208:1CA8 | 1208:1CAB | OK | WI 10 |
| 1220:00D2 ShowTextDialog | 1088:19FB | 1088:1A00 | OK | DOS-PROFILE.md |
| 1220:00D2 ShowTextDialog | 11F0:3CFC | 11F0:3D01 | OK | DOS-PROFILE.md |
| 1220:00D2 ShowTextDialog | 11F0:3E4A | 11F0:3E4F | OK | DOS-PROFILE.md |
| 1220:0156 MenuZ | 10E8:0523 | 10E8:0528 | OK | A 4.3 |
| 1220:0156 MenuZ | 11E0:0724 | 11E0:0729 | OK | A 4.3 |
| 1220:16FD RunTextInputDialog | 10E8:056A | 10E8:056F | OK | DOS-PROFILE.md |

## 4. Queries, accessors and the hook (draft A 5, 6.3)

D3a has no probe handlers; the units read here are the `w16q_*` queries of draft A 5.1 that D3a
implements, every function they reach down to plain field reads, and the hook. The five queries of
draft A 5.2 that belong to M and D4 (`w16q_sys_track`, `w16q_draw_on`, `w16q_msgbox`,
`w16q_menu_item`, `w16q_menu_bar`) do not exist yet; their rows are added with them.

**Reviewer.** An independent reviewer (a separate read-only agent session, 2026-10-11; it did not edit,
build or run anything) read `platform/w16/w16_obs.c`, `w16_obs.h`, `rgn.c` and `handles.c` in full, the
relevant parts of `vm.c`, `vm.h`, `w16_int.h`, `user_wnd.c`, `user_ctl.c`, `user_listbox.c`,
`user_menutrack.c`, `user_cursor.c`, `gdi_dc.c`, `gdi_obj.c`, `gdi_font.c`, `gdi_pal.c`, `clock.c`,
`queue.c`, `gdi_draw.c` and `present/observe.c`, against draft A 4..6. For each function: what it
reads; whether it can write emulation state (emulated memory, registers, `vm_steps`, `vm_site`, the
frame and control stacks, any window, control, GDI, menu or cursor record, a handle or selector, the
queue or key state, the clock, timers, the checked-build records, `g_randSeed`; a lazily initialised
cache counts as a write); whether it can fault on bad input; the verdict. The implementer applied the
three findings below and re-ran the three variants (see the record).

| Unit (file) | Reads | Writes emulation state | Can fault | Verdict |
|---|---|---|---|---|
| `w16q_now_us` → `w16_clock_us` | the virtual time | no | no | OK |
| `w16q_rd8/16/32` → `checked_bytes`, `forbidden`, `host_bytes` (w16_obs.c) | `vm_seg(sel)`: kind, base, limit; the segment's host bytes | no (no `mem_rd*`, `vm_resolve`, `note_write`, `acc_chk`; only the observer's `W16qDiag`) | no: selector 0, no segment, FREE, FREED, CODE, no base and an offset beyond the limit give 0 with `*ok = 0`; `g_randSeed` is tested before the bytes are read | OK |
| `forbidden` (w16_obs.c) | `VA_g_randSeed`, `SZ_g_randSeed` | no | no | OK: every width; no other selector aliases DGROUP's host bytes |
| `w16q_read` | as the readers, per tile; `forbidden` per byte (read as 0) | no (`W16qDiag` only) | no: each chunk is bounded by `limit + 1 - off`; the next tile only for a block of 64 KB tiles while `(sel - first_sel) / VM_AHINCR + 1 < ntiles`, checked again through `vm_seg` | OK |
| `w16q_strn` | through `w16q_rd8` | no | no: at most `max - 1` bytes and the NUL; `max` 0 gives 0 | OK |
| `w16q_arg_base`, `w16q_arg16/32`, `w16q_argptr` | `ObsProbe.arg_base`; SS words through the readers (`vm_s16`, `fp_add` are pure) | no | no | OK |
| `w16q_ret_ax`, `w16q_ret_dxax` | `cpu.ax`, `cpu.dx` | no (reads) | no | OK |
| `w16q_block` → `vm_handle_to_sel`, `vm_seg` | the block's selector and size; not its lock count | no | no: `vm_seg(0)` is the FREE entry 0 | OK |
| `w16q_wnd` → `w16_wnd_info`, `W`, `hpool_live`, `shown` | the window record; class name (39 bytes at most), text (127 at most) | no; allocates and sends nothing | no: a freed or foreign handle gives 0 | OK |
| `w16q_wnd_first`, `w16q_wnd_next` → `w16_wnd_first_child`, `w16_wnd_next` | `child`, `next` | no | no (inside `free_tree` they may name a freed child, which every query rejects) | OK |
| `w16q_active`, `w16q_focus`, `w16q_capture`, `w16q_desktop` | the four statics | no | no | OK |
| `w16q_wnd_vis` → `w16_wnd_vis` → `vis_region` → `rgn_set`, `rgn_and_rect`, `rgn_sub_rect`, `rgn_clear` | the window chain, the overlays, `is_top`, `shown` | no emulation state: the caller's region and `rgn_sub_rect`'s function-static scratch, reset on every call; no `w16_scratch_*`, no cache | see findings 1 and 2 | OK after the fixes |
| `w16q_wnd_client_vis` → `w16_wnd_client_vis_obs` → `w16_wnd_client_vis` → `vis_region` | as above, and the client rectangle and `WS_CLIPCHILDREN` | as above | see findings 1 and 2 | OK after the fixes |
| `w16q_btn` → `w16_btn_info`, `btn`, `w16_wnd_is_window`, `w16_wnd_class_is`, `w16_wnd_style` | the button state (index checked), the window | no (`btn` only indexes) | no | OK |
| `w16q_edit` → `w16_edit_info`, `btn`, `w16_wnd_text` | the EDIT state, the window text (255 at most) | no: it does not call `edit()` (which would set `ready`); an EDIT not yet set up is reported with the values `edit()` would give it; `w16_wnd_text` allocates nothing | no | OK |
| `w16q_lb_count`, `w16q_lb_sel`, `w16q_lb_top` → `w16_lb_info`, `lb_of` | `n`, `sel`, `top` | no (`lb_of` creates nothing) | no | OK |
| `w16q_lb_item` → `w16_lb_text` | `item[i]` for `0 <= i < n` | no (the caller's buffer only) | no | OK |
| `w16q_menu_state` → `w16_menu_track_info` | `g_obs_mt` (set when the loop's state is complete, cleared before it is freed); levels up to the depth, `sel < MT_ITEMS` | no | no | OK |
| `w16q_dc` → `w16_dc` | the DC record of a live handle | no | no: an invalid handle gives NULL | OK |
| `w16q_bitmap`, `w16q_palette` → `w16_obj_kind`, `w16_obj` | the object record; `const` host pointers (not emulated memory) | no | no | OK |
| `w16q_font` → `w16_obj_kind`, `w16_font_face_of`, `face`, `w16_font_height/ascent/res_id` | the font object, the face table | no: no lazy font loading (`face` falls back to the system face) | no | OK |
| `w16q_screen`, `w16q_system_rgb` → `w16_screen`, `w16_system_rgb` | the virtual screen, the system palette | no | no | OK |
| `w16q_cursor` → `w16_current_cursor`, `w16_cursor_info` | the current cursor, the cursor table | no | no | OK |
| `w16q_diag` | `W16qDiag` | no | no | OK |
| `w16q_obs_start` → `w16_obs_reset`, `vm_probe_install` | the caller's keys | observer state only (depth, the current probe, `W16qDiag`, the probe table) | no | OK after finding 3's fix |
| `diag_note` (w16_obs.c) | the current probe | `W16qDiag` only | no | OK |
| `probe_find` (vm.c) | the slot table (at most 256 keys in 2,048 slots: an empty slot is always reached) | no | no | OK |
| `probe_call` (vm.c), `probe_hook`, `obs_arg_base` (w16_obs.c), `obs_probe` (present/observe.c) | the slot's id; the `FrameDesc`; the clock | observer state only (the current probe, the host `ObsProbe`, the hit counts, the listeners) | Checked: re-entry faults, by design | OK; `obs_arg_base` ignores `push_ds` for `FR_NONE` as `fr_leave` does, and no `FR_NONE` descriptor has it |
| the `fr_enter` hook block (vm.c) | `g_nprobes`, `fd->addr`, `ra`, BP, SP | no: after `cover()`, the pushes and `g_prolog_fn = 0`; `vm_steps`, `vm_site`, the depth, the control stack, the stack and the registers unchanged | no | OK |
| the `fr_leave` hook block (vm.c) | the control stack's `ra` (the bounds of `fr_enter`'s store), BP, SP | no: before the depth decrement, the `vm_site` restore and the pops, none of which it changes | no | OK |
| `w16_obs_begin`, `w16_obs_end`, the sentinel, `o4_fault`, `w16_obs_reset` | `vm_steps`, `vm_site`, `cpu`, the clock, the queued input count, the allocation and write counters | observer state only (depth, sentinel, `dropped`, the fault message) | Checked only, by design: re-entry or a sentinel difference calls `vm_fault`; `VmCpu` is all `uint16_t`, so `memcmp` has no padding | OK |

### Findings and fixes

1. **A query could log** (draft A 5.3 forbids `host_log`): `w16q_wnd_vis` / `w16q_wnd_client_vis` →
   `vis_region` → `rgn_sub_rect` → `push` → `overflow`, which logs "w16: region exceeds 256
   rectangles" when a region would exceed `W16_RGN_MAX`. A run with the observer could then print
   lines a run without it does not. **Fixed:** `rgn.c` `overflow` counts the replacement in
   `W16qDiag.rgn_overflows` instead of logging while the observer's guard is held (`w16_obs_depth !=
   0`); the emulation's own overflows are logged as before.
2. **`vis_region` could follow a freed child.** `free_tree` frees a window's children before the window
   and emits `OBS_FOCUS` and `OBS_WND_DESTROY` in between, so the window's child list may name freed
   records, and `vis_region`'s sibling and child loops read `W(s)->next` and `->visible` without a NULL
   test. A listener querying a window of the dying subtree would crash; only `vis_region`'s `!shown`
   early return (the root is hidden first) prevented it, and a core `WM_DESTROY` handler that shows the
   window again would defeat that. **Fixed:** the observer's accessors (`w16_wnd_vis` and the new
   `w16_wnd_client_vis_obs`, user_wnd.c, under `CIV_OBSERVER`) give an empty region (0) for a window
   being destroyed; the emulation's `w16_wnd_client_vis` is unchanged (no core code runs inside
   `free_tree`). `test_observer` queries both regions at every `OBS_WND_DESTROY`.
3. **`w16q_obs_start` inside the observer** would reset the guard depth (ending the Checked re-entry
   check for the rest of the handler) and replace the table during a run (draft A 4.1: it never
   changes). **Fixed:** it returns -1 inside the guard, and in Checked faults "O4: w16q_obs_start";
   `test_observer` covers both builds.

Notes (not findings): `rgn_sub_rect`'s function-static scratch is rewritten by every call and fully
consumed before it returns, so nothing carries over to the emulation. The Checked sentinel compares the
queued input count, not the queue's content; window, GDI, menu and cursor records, the key state and
timers are outside the sentinel and rely on the forbid points and this review. `w16_wnd_info` and
`w16_wnd_class_is` index the class table without testing for -1, which cannot occur (the desktop's
class is added at initialisation).

## 5. Module accessors (draft A 5.3, Open A7)

Open A7 asked whether the queries can reuse w16's getters unchanged. The existing getters
(`w16_dc`, `w16_obj`, `w16_obj_kind`, `w16_wnd_first_child`, `w16_wnd_next`, `w16_wnd_active`,
`w16_wnd_focus`, `w16_wnd_capture`, `w16_wnd_client_vis`, `w16_current_cursor`, `w16_font_*`,
`w16_screen`, `w16_system_rgb`, `w16_clock_us`, `vm_seg`, `vm_handle_to_sel`) are non-faulting and
reused unchanged. The state below is file-static with no getter, so D3a adds read-only accessors under
`#if CIV_OBSERVER` (the pattern of draft A 5.2's `w16_msgbox_info`); `obs_lint.py` allows `w16_obs.c`
to call only these and the getters above.

| Accessor (file) | Reads | Writes | Verdict |
|---|---|---|---|
| `w16_wnd_info` (user_wnd.c) | the window record, its class name and text | the caller's `W16qWnd` | OK |
| `w16_wnd_vis` (user_wnd.c) | `vis_region` of the window rectangle; empty while the window is being destroyed | the caller's region | OK |
| `w16_wnd_client_vis_obs` (user_wnd.c) | `w16_wnd_client_vis`; empty (origin set) while the window is being destroyed | the caller's region and origin | OK |
| `w16_wnd_desktop` (user_wnd.c) | `g_desktop` | nothing | OK |
| `w16_btn_info` (user_ctl.c) | the button state and window style | the caller's `W16qBtn` | OK |
| `w16_edit_info` (user_ctl.c) | the EDIT state (defaults before `ready`), the window text | the caller's `W16qEdit` | OK |
| `w16_lb_info`, `w16_lb_text` (user_listbox.c) | count, selection, top; an item's text | the caller's integers; a `const` pointer | OK |
| `w16_menu_track_info` (user_menutrack.c) | the running menu loop through `g_obs_mt` (observer-only pointer, set and cleared by `track`) | the caller's `W16qMenu` | OK |
| `w16_cursor_info` (user_cursor.c) | the cursor table | the caller's two words | OK |

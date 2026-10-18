# Phase 3a acceptance record

Phase 3a (prompt section 9) covers translating and verifying the start-up and world slice: the
units reachable from WinMain to GenerateWorldMap (1028), the resource manager (1190) and the
picture codec. Gate: "Headless start-up reaches the title menu (with the `w16` parts it needs).
Both worldsim vectors are reproduced."

| Gate item | Method | Result |
|---|---|---|
| Headless start-up reaches the title menu, with the `w16` parts it needs | headless: scenario S1, `tests/harness/run-startup.cmd Checked g-26` (`civ_harness.exe` with the translated game core, fresh run directory, `--datetime "1992-01-01 12:00:00"`, boot offset 0, no input, virtual-time watchdog 40,000 ms, out-of-range allowlist check) | **PASS**, 2026-10-09 01:51 UTC. The core runs from WinMain through the intro and presents the title menu (dialog 139 over the picture dialog 148) as frame 445 at 21,219,300 µs of virtual time, then idles in MenuZ's message loop until the watchdog stops it at site 1220:0AC0: 8,754,809 steps, 40,000,850 µs, 445 frames, 0 dropped events, 0 faults, 0 out-of-range records (allowlist of 44 sites, 0 unlisted). Every frame hash, `final.bmp` (9e3f9d5a…) and the watchdog snapshot (85666ce7…) equal run g-25's |
| Both worldsim vectors are reproduced | headless: `test_worldsim` (Release, Checked, Asan) runs the translated GenerateWorldMap from a fresh DGROUP image with the vector state injected at 1028:0100 (prompt 7) | **PASS** in all three variants, 2026-10-09 01:49–01:51 UTC: 0x89ABCDEF with (0,2,0,2) ends at **3428805747** after 5,996 draws, and 0xFFFFFFFF with (2,0,2,0) ends at **3527905266** after 5,555 draws. These agree with an original-process observation (quoted in `claude/docs/crosscheck/world-generation.md`). The model-only third case 0x0000EA0D with (1,1,1,1) gives 3320891781 after 5,544 draws, as `worldsim.py` models it. A repeat of the first vector gives the same map and DGROUP hashes (port determinism only). 33 checks |

## Translation and verification

* **Translated:** 272 functions in 56 generated units (`gen/units.json`, `core/seg*.c`), produced
  by `gen/translate.py` from the recovered C with the annotations of `gen/annot.py`, the comment
  sites of `gen/findings_sites.py` and the recovery errata E1–E3 (`RECOVERY-ERRATA.md`). They
  cover 33,057 of the 137,887 live listing instructions. The slice is complete: the 1190
  resource manager, the picture codec, every function the start-up run executes, BeginWorldCreation
  (1108:01BC, the only caller of GenerateWorldMap) and GenerateWorldMap's whole call closure. The
  remaining 427 of the 699 live game functions are phases 3b and 3c; the start-up run
  reaches none of their fault stubs.
* **Verified:** all 272 functions **PASS** against the listing (checks 1–5 of
  `claude/work/AGENT_GUIDE_VERIFY.md`, prompt section 6, 5.2 items 2, 3 and 7), by independent
  read-only verifier subagents in four rounds: round 1 (first verification, 2026-10-08), round 2
  (re-verification of the units with defects, first verification of 8 new units, comment checks),
  round 3 (the fixes, mostly as diffs, and reviews of the comment generator and the cast forms)
  and round 4 (the last fixes and BeginWorldCreation's first verification). Each unit's report,
  with every round appended, is `docs/verify/<unit>.md`; the generator reviews are
  `verify/round3-casts.md` and `verify/round3-findings-sites.md`; the briefs are
  `verify/BRIEF-round2.md` to `BRIEF-round4.md`. Recovery defects found by verifiers are
  `RECOVERY-ERRATA.md` E1–E3; the port follows the listing.
* **Verifier process deviations** (recorded per verifier; none changed a file outside the
  verifier's own reports): several read-only shell commands began with `cd` (absolute paths
  otherwise); three verifiers read their own saved tool output from the session's tool-results
  folder; one wrote and at once deleted a scratch file under `/tmp`; one overwrote another
  verifier's scratch file in the shared session scratchpad; one ran `gen/findings_sites.py`
  (print-only). The orchestrating agent also slipped twice: commands with `cd`, and Bash
  heredocs that mangled backslashes (each caught and redone through files).

## What was compiled

`build.cmd` in all three variants, 2026-10-09 01:48–01:51 UTC, each **BUILD_OK**: Release
(`/MT /O2`), Checked (`CIV_CHECKED=1`: image bounds, argument-slot checks, statement markers,
out-of-range records) and Asan (Checked plus `/fsanitize=address`). All 104 portable sources
(`platform/w16`, `rt`, `core`, `core/gen`) compile under MSVC `/std:c11` and `/std:c17` (`/W4 /WX
/permissive- /fp:precise`) and the C99 parse of Visual Studio's clang front end; the headless back
end, the 18 test programs and `civ_harness.exe` (Checked, Asan) link. The generators run by
`build.cmd` (dispatch, interfaces, out-of-range allowlist) succeed.

## What was tested headless

`test.cmd` in Release, Checked and Asan, 2026-10-09 01:49–01:51 UTC, each **TESTS_OK**
(`build/test-3a-<variant>.log`):

* `test_worldsim` 33 checks (above); `test_vm` 51 (frames, faults including F33's overwritten
  saved DS, BP and return address); `test_acc` 17 (Checked); `test_gdi` 95; `test_user` 54;
  `test_queue` 59; `test_sha` 5; `test_ne` with `check_ne.py`;
* the rt tests as in phase 2: `test_rt` 321, `test_printf` 62, `test_io` 133, `test_dir` 103,
  `test_time` 140, `test_heap` 99, `test_stdio` 400, `test_start` 110, `test_math` 174,
  `test_float` 53;
* the harness scenarios of phase 2 with the stub core (Checked, Asan), plus two for the
  out-of-range allowlist: `oob` (a listed record passes) and `oob2` (an unlisted record fails the
  run, as expected);
* scenario S1 above (Checked), and the rule 6.6 class (a) UNINIT check inside `test_worldsim`
  (BuildSeaZoneLinks reads BuildLandZoneLinks' last `dstTileY` from the emulated stack).

**Deepest emulated stack** (5.2 item 7): 2,194 bytes below the initial SP 0xD8BE, reached in S1
(SP 0xD02C), 7,022 bytes above the stack-overflow limit 0xB4BE; `test_worldsim` reaches SP 0xD6E0
(478 bytes).

The labels are "model (self-consistency)" for results derived from the recovered C and listing,
"agrees with an original-process observation" for the two worldsim final states only, and
"platform fact (inferred)" or "choice" for the Windows 3.1 rules the `w16` parts implement
(`DESIGN.md`, `FIDELITY.md`).

## The `w16` parts the start-up needs

Implemented and exercised by S1 and the unit tests: KERNEL memory, task, file and misc entries;
USER windows, dialogs (CreateDialog/DialogBox with CIVDIALOG), the BUTTON/STATIC controls, cursors,
rectangles, the message queue, timers and focus/activation; GDI device contexts, objects,
drawing, fonts, palettes and regions; the virtual DOS services; the NE resources the game loads.
Their Windows 3.1 behaviour is recorded as choices or inferred platform facts in `FIDELITY.md`
(F1–F33).

## Agent-observed, oracle-compared, user-confirmed

* **Agent-observed:** the agent viewed the frame dump of S1's final frame
  (`build/frames/g-26/final.png`, converted from `final.bmp`): the title menu's six options
  (Start a New Game, Load a Saved Game, Play on EARTH, Customize World, View Hall of Fame, Quit)
  and the OK push button over the CIVILIZATION picture. This is a headless frame dump, not a
  window, and not a comparison with the original.
* **Oracle-compared:** nothing. No original was run in this phase.
* **User-confirmed:** nothing.

## Unverified / open

* **B2 deviation, pending the user's confirmation** (unchanged): selectors and handles are reused
  after the never-used ones run out.
* **M1 decision (a)** (unchanged): C2 masks 0xEF..0xFF fault under the 32-byte granularity.
* **Not compared with the original:** the intro's frames, timing and palette steps and the
  title menu's appearance are port output; frame hashes are not original fixtures. The worldsim
  match covers only the random path's final state (the map page and DGROUP hashes are port
  results). Same-seed fidelity is not claimed.
* **Out-of-range candidates without a finding** (round-2 reports, e.g. HasHut 1110:1CF4,
  DrawTilesToPort 1208:1E6D and 1208:1FEB): not triaged; they become allowlist entries only
  after triage (`DESIGN.md` 3.2). S1 records none.
* **NOTEs carried forward** (verifier reports): N10 (the G61 corridor reads past the 17-entry
  table on the load/EARTH paths, to triage when those paths run); CX/DX at returns not modelled
  where no reader exists; the L14/H12 context addresses of unported functions in
  `verify/round3-findings-sites.md` N3/N6; the GetDeviceCaps hoisting (errata E2/E3) to be
  checked again when PlotSmMapSquare and the other unported callers are translated.
* **Untranslated outside the slice:** 427 live game functions (phases 3b, 3c). The translator's survey
  (`build/cache/translate-survey.txt`, 2026-10-09 01:47) translates 641 of the 698 live
  functions without an error; the other 57 need annotations or translator work.
* **Phase 3c:** `TRACE.md` is not started.

**Gate: met** (2026-10-09 01:51 UTC). Phase 3b follows (section 11): load/save and the new-game
slice.

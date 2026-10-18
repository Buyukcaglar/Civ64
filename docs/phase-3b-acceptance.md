# Phase 3b acceptance record

Phase 3b (prompt section 9) covers load/save and the new-game slice: SerializeGameData (10F8)
and its callers, setup to the first turn. Gate: "`CAE3540B.SAV` loads; save tests pass; the first
scripted turns pass under the checked build." Required checkpoints: after GenerateWorldMap, after
new-game setup, after each scripted turn, after load and before save.

**State, 2026-10-09 15:35 UTC: the gate is met.** The three scenario items pass headless under the
checked build, and every phase-3b function passes verification, as do all 699 translated
functions (rounds 5 to 11, below): phase 3a's standard holds here as well. The labels of
prompt section 10 are kept apart at the end of this record.

| Gate item | Method | Result |
|---|---|---|
| `CAE3540B.SAV` loads | headless: scenario S2, `tests/harness/load-save.script` (title menu → Load a Saved Game → the Open dialog answered `CAE3540B.SAV` through `--file-answer`), checkpoint after-load 10F8:02AF | **PASS** (agent-observed), run `gate3b-s2`, 2026-10-09 08:00 UTC: loaded at 22,501,850 µs of virtual time; the map, World Map and Status windows open and turn 23 begins (1088:000F at 23,234,550 µs) |
| Save tests pass | headless: S2 saves with Ctrl+S (SAVE1.SAV on turn 23, SAVE2.SAV on turn 24), checkpoint before-save 10F8:0370; `tests/harness/savecheck.py`; S2b `save-stale.script` (save over CAE3540B.SAV); S2c `load-stale.script` (load that file, re-save RESAVE.SAV) | **PASS**: both saves equal the RLLEncode model of the serialized image and decode back to it (**model, self-consistency**: the models are independent implementations of the recovered RLLDecode/RLLEncode, not the generated code); the 14,281-byte image saved over the 14,283-byte file keeps the old last 2 bytes (no O_TRUNC, 10F8:0393); RESAVE.SAV is byte-identical to SAVE1.SAV. Not compared with saves written by the original |
| The first scripted turns pass under the checked build | headless: S2 plays turn 23 of the loaded game (unit orders, the AI civilizations, a diplomatic audience with a peace treaty) into turns 24 and 25; S3 `tests/harness/new-game.script` starts a new game: world generation (after-worldgen 11E0:01B2), the Birth movie skipped by a key, Chieftain, 7 civilizations, the Romans, leader name typed (after-setup 10E8:1290), the introduction, turn 1 (Rome founded: city-name dialog, founding animation, city screen), then turns 2–5 each after one Space for the last unit (11F0:0EEA) | **PASS** (agent-observed): `gate3b-s3` reaches 1088:000F five times with g_gameTurn 0..4 and g_gameYear −4000, −3980, −3960, −3940, −3920; every run ends at its virtual-time watchdog with no fault and no out-of-range record outside the allowlist (S3: 6 records, all listed). A repeat S3 run gives identical snapshots and frame hashes (port determinism only). The Asan build runs S3 with the same steps and final frame and no AddressSanitizer report |

The gate runs as `tests/harness/gate3b.py` (12 checks, `GATE3B_OK`), part of `test.cmd checked`.

## Verification, tests and records

* **Verification** (rounds 5 to 7, 2026-10-09; reports in `docs/verify/`). Round 5 (V01–V40,
  02:00–08:15 UTC) found the behaviour-changing translator defects (stack words read before any
  write kept as C locals, copies overrunning frame objects, DX at returns, a swapped string offset,
  swapped return addresses) and the comment/marker defects; fixer F5 applied 128 of 138 items
  (`round5-fixes.md`). Round 6 (R6A–R6G, 09:40–10:15) re-verified the 73 changed units: 687 of 699
  functions PASS. Fixer F6 applied the 24 round-6 items (`round6-fixes.md`): UNINIT
  reclassifications with traced last writers, new out-of-range entries, documentation corrections.
  Round 7 (R7A–R7D, 11:33–12:14) re-verified them: 692 of 699 functions PASS; the open records
  (1170:187C and 11A0:066D are class (b); F58's possible hang; F66 and an out-of-range entry at
  11C0:2270) go to fixer F7, and R7D closed E18 ("no reader" of the four window procedures' DX).
  The segment-push order in CompleteResearch, SubstituteTextTokens and ShowNewspaper is now a
  translator feature (regenerated 12:12). Round 8 (R8A–R8E, 12:52–13:27) re-verified it, the
  frame-object checks (80 array locals) and F7's items: 698 of 699 PASS; the open record
  (findings C13's `labelRemap[label]` read at 1028:0E2D had no allowlist entry) and R8D's
  generic finding (three-index globals checked only two indexes) went to F8
  (`round8-fixes.md`: out-of-range entries C13, H39, H29, P7 and P8, `acc_ix3`, record
  wording). Round 9 (R9A–R9C, 13:37–14:08) passed `acc_ix3` and F8's items and found LabelBodiesAndFinalizeMap R9-T1 (its labels 80..90 read scalar locals that were C variables) and the generic G-2 (member-array indexes not range-checked); F9/F10 fixed both (11 locals made stack-resident; `acc_ix1m`/`acc_pm` for 92 accesses). Round 10 (R10A–R10C, 14:20–14:39) passed them and found TextBoxDraw R10-T1 (reads past its 64-line tables with no allowlist entry); F11 listed it (findings C9 at marker 2609) with CreateDissolveState's H61 sites and record wording. Round 11 (R11A, 14:57–15:32) passed every F11 item: 699 of 699 functions PASS, with no TRANSLATOR or RECOVERY finding and nine NOTEs on record wording (`verify/round11-R11A.md`), which are open record items (F12).
* **Rule 6.6 headless tests** (`tests/harness/uninit.py` in `test.cmd checked`; model,
  self-consistency). A checked-build record of every emulated-stack byte's last writer
  (`DESIGN.md` 9) is probed at each UNINIT read in S2, S3 and two soak scenarios (S4: the saved game
  played with Space/Enter for 92 turns; S5: a new game for 111 turns; each ends when the human civ
  is destroyed and the game exits). Every stale read of a class (a) site must have a ported writer
  and no API call above it since. After round 7 one class (a) site is left, TakeAdvanceFromCiv
  1038:0B36, and it is vacuous (the first candidate always writes the word); uninit.py's table
  check tests the condition from every run's snapshot: GetAIAdvanceWeight >= 0 for all 72 advances
  with every civ entry's `civilized` value and with -1..1 (base weights 0..8, trait factors -2..2,
  minimum 0), and that `g_playerCivId[1..7]` lies in 0..15 (verify/round8-R8E.md N1). Rounds 6 and 7 moved the other sites that prompt 6.6's example list or the first
  records put in class (a) to class (b) by the rule's own definition: ProcessCity 1030:1495 and
  MoveCivUnits 11F0:13BF (a Windows API call, CheckLowResourcesWarning's GetFreeSpace /
  GetFreeSystemResources, runs between the last ported write and the read with its stack pointer
  0xE and 0x16 bytes above the word; FIDELITY F55, F57), ChooseCityProduction 1170:187C (a far
  call's code selector) and StartCivilWar 11A0:066D (the map window's client width on one path),
  so the class (a) tests planned for 187C and 066D are withdrawn.
* **Out-of-range reads found by the soak scenarios** (checked build) and allowlisted after triage
  against the listing: FrameRectLogical 1220:10B6 (port P4: the 16+civ colours of four report
  screens) and DeleteNonLandUnitCallback 11C0:22BB (findings G67). Since 12:12 the checked build
  also range-checks indexes into array locals (frame objects, 439 sites; `DESIGN.md` 3.2): S2, S2b,
  S2c, S3, S4 and S5 record nothing there, nor at the 18 three-index accesses (`acc_ix3`, since
  13:33), nor at the 92 member-array accesses (`acc_ix1m`/`acc_pm`, since 14:13).
  Latent out-of-range accesses that the scenarios do not reach are listed in advance where the
  record identifies them: findings C13 (more than
  63 live labels; FIDELITY F72), H39 and port P7 (terrain -1 on a map with colours 0, 4, 5 or 8,
  the unchecked EARTH picture; F73), H29 (a Pascal string of 128 or more characters) and port P8
  (production 99 after a GR_DialogOpen failure; F74). Their downstream readers (a body id
  of 16 or more, a stored production of 99) are not listed: a scenario that reaches them
  triages them (F72, F74). The start-up run's allowlist has 347 sites.
* **Platform items found by the scenarios** and implemented in this phase (headless-tested by
  `test_user` 105 and `test_queue` 73 checks): EDIT and STATIC controls (FIDELITY F34),
  BS_OWNERDRAW buttons with WM_CTLCOLOR first (F35, user direction on the Exit caption),
  the synchronous erase of a shown window (F36), TranslateMessage posting the key down's own
  character (F32 revised), COMMDLG file dialogs with headless answers, menus and accelerators,
  scroll-bar state, MessageBeep, WinHelp (logged only), MoveWindow's tracking sizes.
* **Known presentation gaps** (no gameplay effect observed): the menu bar and scroll bars are
  drawn as plain grey; the Status window lies off the 640x480 screen with civ.prf's rectangles
  (the open screen-size question); WinHelp shows nothing.

Final tests (2026-10-09 14:58–15:03, after F11): `build.cmd` and `test.cmd` for Release, Asan and
Checked give BUILD_OK and TESTS_OK (GATE3B_OK, UNINIT_OK, TRACE_OK); `run-startup.cmd Checked
g-37` ends at the watchdog with 0 out-of-range records and a snapshot equal to g-36's.

## Not done (labels as in prompt section 4)

* **Oracle-compared:** nothing in phase 3b; no original run was compared with these scenarios.
* **User-confirmed:** the Exit caption on the button face is pending the user's visual
  confirmation; no other phase-3b visual has been confirmed.
* **Unverified:** same-seed fidelity is not claimed; the scenario hashes are port hashes only.

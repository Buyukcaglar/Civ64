# Extension BS, unit BS4 (the Windows end and the records) - record

Unit BS4 of the Birth synchronisation BS (the user's direction of 2026-10-15, session E3). Brief:
[verify/BRIEF-bs.md](verify/BRIEF-bs.md) D7 with the orchestrator's Rulings ("D7 the auto-continue extended to
'DOS visible or BS active' (the same I1/T3 exception, P0 against the recorded input, a pending user check)"),
4.1, 5.2 test 8, 6 (BS4 row and "What the user checks after BS4"). Staged in `build/bs34-stage` with BS3
(record [ext-BS3-record.md](ext-BS3-record.md)); the build slot landed both and ran the BS gate.

## Status

Done. Landed in the tree on 2026-10-15 at 23:35 UTC, BS1..BS4 at once (the BS implementer's build slot;
one landing for BS12 and BS34, no separate three-step cycles, Rulings 19:20) and verified by the BS phase
gate's eight-step cycle: ALL_GREEN (status `build/bs-status.txt`, logs `build/bs-<n>-<step>.log`; the gate
and its tables: [ext-BS-acceptance.md](ext-BS-acceptance.md)).
Visible change: with the Birth synchronisation active the game continues to the setup at the DOS Birth's
hand-over whichever graphics are visible (no black wait with the Windows graphics shown). D4-22 (accepted) is
superseded by BS-4 when the DOS data are found (the user's direction of 14:03; Rulings 19:20); it still holds
without them (BS-6). The user's check (BS-1..BS-6) is pending. Landing: `pdos_seq.c/.h` merged three-way onto
D4cF's files (no conflict; BS4's blocks unchanged), see the BS3 record's "Landing".

## What was built

### D7 (`present/dos/pdos_seq.h/.c`, `pdos_profile.c`)

* `pdos_seq_autocontinue_release`: the condition "the DOS profile is visible" becomes "the DOS profile is
  visible **or the Birth synchronisation follows this Birth**". Every other condition is D4b4's,
  unchanged: the setting on, nothing produced yet in this Birth, room for both events, the core in its
  skip-able Birth with the world done (neither its skip SetGameCursor ra 11E0:094E nor its Birth end
  DestroySequencePlayer ra 11E0:01E8 seen), no press of the player's since Birth's start, DOS Birth at its
  hand-over R:01A8:087C. The events (one Escape press and release, posted at the next input-taking sync)
  and their proof (D4b4's record, "The produced input") are unchanged.
* `pdos_profile_bs_active()` (`pdos_profile.c`, the profile's bridge to the present layer, beside
  `pdos_profile_visible`): `present_birth_sync_active()` (BS3: a Birth being synchronised, started and not
  ended; 0 without the DOS profile, under CIV_OBSERVER 0, when BS is off or went off for this Birth).
* `pdos_seq_set_bs_query(fn)` (tests; NULL: `pdos_profile_bs_active`; kept across resets). A separate
  setter, not a third `PdosSeqQ` field: `test_pdos_adapt.c` and `test_pdos_pend.c` fill a `PdosSeqQ` on the
  stack field by field, so a new field would be uninitialised there.
* obs_lint's I1 rule is unchanged: `HOST_EV_` still appears only in the filter stage and in
  `pdos_seq_autocontinue_release`.

### Tests

* **`tests/test_pdos_seq.c`** (`test_autocontinue` case 7, 11 checks): the default query is 0 with no Birth
  synchronised; with the query on and the Windows profile visible: nothing during the story, the same Escape
  pair at the hand-over (counted, the hook told), only once, a switch to DOS afterwards adds nothing; the DOS
  profile visible: as D4b4; switched to DOS and back during the story: the skip all the same; the core's
  own skip first: nothing; no room: held; the query off with Windows visible: nothing (D4b4); the setting
  off: nothing. 114 -> 125 checks.
* **`tests/harness/ext_continue.py`** (test 8): runs `bs_win` (`win` with `--birth-sync 1`), `bs_win_replay`
  (the Windows profile alone with `bs_win`'s skip as host lines at its sync) and `nodos` (`--birth-sync 1`
  and `--birth-continue 1` without `--dos-data`); `win` is test 8's `bs_off_win`. Checks 6..8 (docstring):
  `bs_win` synchronised and shown, never off or failed; one skip at the first sync after the DOS hand-over,
  at `dos`'s sync, its two posts only; the core's skip, Birth end and setup within one second; the view's
  `bs end` at the core's Birth end and `bs native` at the tick after it, within one second of the skip;
  autocontinue 1; core outputs and posts equal `dos`'s. `bs_win_replay` equals `bs_win` (P0 against the
  recorded input). `nodos`: no Birth synchronised (`bs enabled 1 starts 0 ... shows 0`), nothing produced,
  core outputs equal `ref`'s. CheckedNoObs: `--birth-sync 1` exits 2 naming the option (beside
  `--birth-continue`). `--exe`, `--root`, `--port` for private runs.

## Results (private, staging; `build/bs34-stage/obj`: the overlay of the tree, BS12, UX1 and this stage)

The gate's results are in [ext-BS-acceptance.md](ext-BS-acceptance.md); these are the staging's.

* Compile: CC_ALL_OK Checked, CheckedNoObs, Release; CC_STRICT_OK for `pdos_seq.c`, `pdos_profile.c`,
  `test_pdos_seq.c` (with BS3's files). OBS_LINT_OK (97 files); the registry include rules all ok.
* `test_pdos_seq` 125 checks PASS in Checked, CheckedNoObs and Release (the tree's build: 114).
* `ext_continue.py Checked`: EXT_CONTINUE_OK, 31 checks. `dos` and `bs_win`: the skip at 172,398,650 µs
  (sync 3,425,801), the core's skip, Birth end and setup at 172,411,900 µs; `bs_win`'s view ended and
  handed back at 172,411,900 µs (instead of holding black until 198.2 s); `bs_win`, `replay` and
  `bs_win_replay` have equal core outputs (1,670 lines, 42 events, 2 posts); `win`, `off`, `to_win`,
  `nodos` nothing produced, equal to `ref` (1,678 lines); `to_dos` unchanged (skip at 180,000,050 µs).
* `ext_continue.py CheckedNoObs`: EXT_CONTINUE_OK (both refusals).
* With the final harness (BS3 + BS4): `ext_timeline.py Checked --group bs` EXT_TIMELINE_OK (11 checks,
  the recorded `bsgolden` reproduced); the base group EXT_TIMELINE_OK (the DOS intro, title box and Birth
  unchanged by the marks: its `golden` and `bgolden` equal); `ext_p0.py Checked --vars V0,V8,V8s --only
  birth,new,earth,custom,settlers` P0_OK (30 checks; the V0 runs equal ext-g1-baseline); `ext_bs.py mirror`
  (BS12's runner) EXT_BS_OK (1436 of 1436, EARTH 84 of 84).

## Decisions within the brief

* The bridge `pdos_profile_bs_active` sits beside `pdos_profile_visible` in `pdos_profile.c` (the only DOS
  file allowed to include the present layer's headers); `pdos_seq.c` stays free of present-layer includes.
* The test query is a separate setter (above), so D4c2's tests stay untouched.
* `bs_off_win` is the existing `win` run (BS off, Windows visible), not a duplicate run.

## For the records (BS3 and BS4 together; for a docs agent: the build slot did not apply them, [ext-BS-acceptance.md](ext-BS-acceptance.md) gathers them)

* **DESIGN.md 12.8 "Added in BS".** A new paragraph after "Added in D4c2" (area C): BS1 (`host_data_read`,
  `present/bs/pbs_assets`), BS2 (`pbs_movie`, `pbs_check`), BS3 (`pdos_bsync.h` and the marks,
  `pbs_core`, `pbs_view`, present.c step 2b, profile_win.c's frame switch, `present_birth_sync`,
  `present_birth_sync_active`, the include rule D11), BS4 (D7's condition, `pdos_profile_bs_active`,
  `pdos_seq_set_bs_query`). Records ext-BS1..BS4-record.md.
* **DESIGN.md 12.10.** Row `host_data_read` (BS1, D2: read-only, both back ends, never on a core path).
  Note under the table: `OBS_LISTENERS_MAX` 4 -> 6 (BS3).
* **DESIGN.md 12.11.** (a) The 5.1 relation exception (D9): inside the BS interval (`bs show` ..
  `bs native`) the Windows presented frame is the view's, not `g_win`'s conversion; `g_win` is unchanged.
  (b) The D4b4 exception extended (D7): the produced skip also with the Windows profile visible while BS
  is active; P0 against the recorded input (`ext_continue.py` `bs_win_replay`).
* **FIDELITY.md.** F155 updated: "With the Windows profile visible the movie plays to its end as before"
  becomes "... as before unless the Birth synchronisation is active (with the DOS files found, civ64): then
  the Windows view ends with the DOS Birth and the skip is given at the DOS hand-over whichever profile is
  visible (BS4, D7)"; "Screen-by-screen Birth synchronisation stays in the backlog" is replaced by a pointer
  to the new row. New row (BS3, see ext-BS3-record.md "For the records"): the Windows Birth's pace.
* **RUNNING.md.** Options: `--birth-sync 0|1` (BS3), `--bs-check 0|1` (BS1), `--bs-mirror 0|1` (BS2), each
  refused under CIV_OBSERVER 0. Tests: `test_pbs_assets` (58), `test_pbs_movie` (44), `test_pbs_view` (45),
  `test_pdos_seq` 114 -> 125; `ext_bs.py assets|mirror`; `ext_timeline.py --group bs`; `ext_p0.py` V8, V8s;
  `ext_continue.py` 31 checks (Checked), 2 refusals (CheckedNoObs). Logs: timeline.log `bs ...`/`bswatch`,
  presentation-diag.log `bs enabled ...`. civ64 section: "Since BS, with the DOS files found, the Windows
  Birth follows the DOS Birth's pictures and captions (there is no option) and, with the Birth
  auto-continue, the setup follows the DOS Birth's end whichever graphics are shown."
* **FEATURES.md.** The D4b4 row's "with the Windows graphics visible the Windows movie plays as before"
  gains "(without the DOS files; with them, BS)"; a new row "Birth synchronisation (BS3, BS4)" with
  `ext_timeline.py --group bs`, `ext_continue.py` `bs_win`, the figures above; user checks BS-1..BS-6
  pending.
* **manual-checklist-ext.md.** A BS section with BS-1..BS-6 (below), "pending". D4-22 ("With the Windows
  graphics visible, the Windows Birth movie plays to its end as before", passed 2026-10-15) is superseded
  by BS-4 when the DOS files are found (the user's later direction); it still holds without them (BS-6).
* **STATUS.md.** BS3 and BS4 done (after the cycle and the BS gate); the user's check pending.

## What the user checks after BS4

A Checked or Release civ64 with the DOS data located (`Run-Civilization.cmd` / civ64.exe; the DOS files found):

* **BS-1** Start a New Game and let the Birth play. In the Windows graphics the Birth pictures change at the
  same moments as in the DOS graphics (compare by switching with Ctrl+Shift+Backspace or the menu), and each
  Windows caption appears and goes with the corresponding DOS text line.
* **BS-2** Switch at any moment during the Birth: the other graphics show the same picture and line at once,
  without restarting anything.
* **BS-3** The Windows fades are short, like the DOS ones (about 0.7 s); the Windows pictures and captions
  themselves look as in the native Windows Birth.
* **BS-4** With the Windows graphics shown, the setup screens follow the Birth's end (about 150 s after the
  Birth starts, after the final fade to black) without a black wait; the same with the DOS graphics shown
  (D4b4).
* **BS-5** A key during the Birth (after the world is built, a second or so in) goes to the setup in both
  graphics.
* **BS-6** Without the DOS data (or with the DOS files moved away) the Windows Birth plays as before, at its
  native timing (about 175 s), and the game waits for its end.

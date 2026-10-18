# Extension phase D6, unit D6g (the sweep, the agent check and the gate) - record

Prepared 2026-10-17 from about 01:30 UTC while TLD held the build slot (BRIEF-d6.md "Units" D6g, "The gate record";
decisions 6, 7 and 8 with the orchestrator's rulings), staged in `build/d6g-stage/`; landed and run in the build slot
after D6f's and FCE's landings.  The gate record itself is [ext-D6-acceptance.md](ext-D6-acceptance.md).

## Status

**LANDED; the D6 phase gate is met.**  The build slot was given 2026-10-17 05:13:30 UTC (after the docs pass for FCE
and D6f); copy-in 05:14:08 UTC (`tests/harness/ext_p0.py` and this record's draft; `build/d6g-prep/landed.sha256`);
the eight-step cycle ALL_GREEN 05:14:16..06:02:50 UTC (`build/d6-gate-status.txt`, every step at its first run); the
user build `build/user-builds/d6g/` about 06:03 UTC; the agent UI check 06:03:13..06:09:05 UTC; the full ext_zoom
matrix 06:09:26..06:49:31 UTC (ZOOM_OK, GOLDEN_CMP_OK).  This copy (with the results) and `ext-D6-acceptance.md`
replaced the draft after the cycle (`land.py --docs --write`).

## What D6g does

1. **The counters by scene row (decision 8 of BRIEF-d5, extended to D6).**  `tests/harness/ext_p0.py`'s GATE_ROWS (D4's
   and D5's rows, D5f) gains D6's rows, so that every V1 and V2 run of `test.cmd checked` fails when `unexplained`,
   `w_over_n`, `font_unmapped`, `colour_nearest` or `prov_unknown` is counted for a D6 row (a recorded `ROW_ALLOW`
   entry with its reason being the only exception).  D6's rows (`D6_ROWS`, 52): the map, world-map and status windows
   (96), the palette cycling (107), the menu bar (121), the play rows 132..140 (BlinkActiveUnitUntilInput,
   AnimateUnitMove, ResolveCombat, the view's redraw, DrawStatusCivPanels, the population message, DrawUnitInfoPanel,
   DrawSmTiles, DrawCityLabels); the boxes D6f places on the A canvas in play (decision 1, ruling 1; D6f's landed
   record "The A placement of D5b's re-skins"): the MenuZ boxes of dialogs 136 and 145 (rows 14, 22) and the message
   boxes, `#MsgBox` (Help > Game Help 94, the system MessageBox 141); and the menu rows of play: 30, 31 (the rates),
   33..43 (Options, Revolution, Retire, Quit), 44..48 (Edit), 49..66 (Edit > Small Map and Status, Orders).  Not D6's:
   the scene-specific boxes 12, 13, 15, 17, 18 (and 115, 117, 118, 126..128) and the Find City, Advisors, World,
   Civilopedia and City menu rows (32, 67..93): D7's; the other class W rows (95, 10, 28, 108, 125, 131).  Rows 96, 107,
   121, 135 and most menu rows have no probe of their own and are never on top of the stack; they are listed for
   completeness.  The list is prepared by `obj/mk_extp0.py` (which writes the
   staged file from the tree's newest copy, so it is re-derived at the landing) and checked against D6f's landed record
   and the last landed cycle's counts before the gate (`obj/rowcheck.py`: the staged file's own decision-8 code over
   the tree's V1 and V2 outputs); rows with a count that is not D6's are listed with their owner (D7) as at D5.
   ROW_ALLOW's entries may name the runs they cover (D6g's form: `(reason, runs or None)`; `row_allowed()`), so that
   a recorded count does not excuse the same row in another run.
2. **The full runs of decision 6** (the full matrix once, its result in the gate record):
   * `ext_zoom.py`'s whole product (`obj/sweep_zoom.py`: win a/b, dos a/b and sw at every host size of the three
     scenarios and the soak at 1920x1440; test.cmd keeps dos b and sw at 1920x1440 only and no DOS soak), with
     ext_zoom.py's own checks; its goldens written to a private file and compared with the tree's line by line
     (`obj/golden_cmp.py`: every tree line equal; the new lines only the DOS soak's);
   * `ext_mirror.py` (`--mirror 2`, present and dos-settled checks, 29 runs), `ext_p0.py` V1, V2 and V4d (V4 with the
     DOS profile and switching) and `ext_frames.py`: these are `test.cmd checked`'s sections already (D6a, D6c, D6d),
     so the gate cycle's step 2 is their full run; nothing is narrowed there.
3. **The Z-1..Z-3 table for the DOS profile** (`obj/ztable.py`: the evidence lines from the gate's outputs).
4. **The agent UI check** (decision 7, ruling 7; section "The agent UI check").
5. **The gate**: the eight-step cycle (BRIEF-cy.md, the phase-gate version) at D6g's landing, the comparison per
   variant, `ext-D6-acceptance.md`.

## Files

* Staged (lands): `tests/harness/ext_p0.py` (D6_ROWS added to GATE_ROWS, ROW_ALLOW with its per-run form and
  `row_allowed()`, the docstring's decision 8 sentence and the P0 line's wording "D4's, D5's and D6's scene rows"),
  this record, and after the gate `docs/ext-D6-acceptance.md`.  No source, no build.cmd or test.cmd change (no
  BUILD-TEST-ADDITIONS).
* Private tools (`build/d6g-stage/obj/`, never land): `mk_extp0.py`, `rowcheck.py`, `rowsum_d6.py`, `sweep_zoom.py`,
  `golden_cmp.py`, `ztable.py`, `ui/agentui.py`; the diagnostic `diagpatch.py` and `diagsum.py` (a private build only);
  the landing's `land/d6-gate-cycle.ps1`, `land/markers.py`, `land/variants.py`, `land/pending.py` (from the D5 gate's
  and D6e's).

## Tests

* The gate cycle: `build.cmd checked`, `test.cmd checked` (ext_p0's V1 and V2 with D6's GATE_ROWS; every section),
  `ext_g1.py check`, `build.cmd checked noobs`, `test.cmd checked noobs`, `ext_g1.py check --variant CheckedNoObs`,
  `build.cmd`, `test.cmd`.
* The full ext_zoom matrix (private root, a copy of the landed Checked harness, after the cycle's step 2, at `-j 4`).
* The agent UI check (the landed Release civ64.exe, after the cycle).

## Results

The full tables are in [ext-D6-acceptance.md](ext-D6-acceptance.md) ("The final cycle", "Decision 8", "Z-1..Z-3",
"Decision 6", "The agent UI check"); in short:

* **The cycle** (`build/d6-gate-status.txt`): 1 `build.cmd checked` 191 s (05:14:16..05:17:27), 2 `test.cmd checked`
  1575 s (..05:43:42; 29 sections, wall 1573.1 s, failed 0), 3 `ext_g1.py check` EXT_G1_OK runs 77 (amended 1),
  4 `build.cmd checked noobs` 210 s, 5 `test.cmd checked noobs` 382 s, 6 `ext_g1.py check --variant CheckedNoObs`
  EXT_G1_OK runs 77, 7 `build.cmd` 205 s, 8 `test.cmd` 351 s (..06:02:50); ALL_GREEN, no rerun.  55 test programs per
  variant, 0 failures; P0_OK checks 476 (CheckedNoObs 62), MIRROR_OK runs 29, ZOOM_OK combinations 32 runs 108
  samples 628, EXT_ADAPT_OK checks 189, EXT_FCE_OK runs 8.
* **Against the predictions** (`build/d6g-prep/predictions.txt`, `comparison.txt`): 57 of `build/test/Checked`'s 63
  files equal to D6f's cycle; the differences are the 66 decision-8 lines' wording (predicted), coverage 664 -> 663
  (X9; predicted), nodos 1751 -> 1752 files (this record, new in `docs/`: not predicted, explained), the OBS_COST line
  and `times.txt`.  `variants.py`: no CheckedNoObs or Release change without its Checked change.
* **Decision 8** (`obj/rowsum-gate.txt`): every gate row 0 in the 33 V1 and 33 V2 runs, beyond row 14's recorded
  `unexplained` 2 in `city` (ROW_ALLOW, city only); the counts that remain are row 0's (D7k) and D7's rows, the same
  table as on D6f's cycle.
* **The full ext_zoom matrix** (`obj/sweep.txt`, 06:09:26..06:49:31 UTC, `-j 4`, a copy of step 1's Checked harness):
  SWEEP_ZOOM runs 160 (win 64, dos 64, sw 32) exit 0, every one of the 32 combinations "ZOOM ok", the centre, MZI and
  MZS runs ok; ZOOM_OK combinations 32 runs 160 samples 776 map comparisons 32 centre runs 4 mzi runs 12 mzs runs 4
  not zoomed 64/796.  `obj/golden_cmp.py`: the tree's 628 golden lines all present and equal (missing 0, differing
  0); the 148 new lines are the DOS soak's (74 at -1, 74 at +1); GOLDEN_CMP_OK.
* **The agent UI check**: done, one attempt, 33 shots; as expected, with the main row's Ctrl+Shift+0 not reaching
  civ64 on this PC (known: M-3); section "The agent UI check".

## The counters by scene row

Read-only on the tree's last Checked cycles before the gate (`obj/rowsum_d6.py`: D6e's, 2026-10-17 00:58..01:23 UTC,
`obj/rowsum-now.txt`; TLD's, 01:35..02:05 UTC; FCE's, 03:08..03:41 UTC; D6f's, 04:27..04:51 UTC,
`obj/rowsum-d6f.txt`; the same table in all four, and again in the gate's own cycle, 05:17..05:43 UTC,
`obj/rowsum-gate.txt`): of D6's 52 rows only row 14 has a count, `unexplained` 2 in `city`
(V1 and V2); no play row (96, 107, 121, 132..140) has one in any of the 33 V1 or 33 V2 runs.  The other counts are
rows D5 already attributed to D6 / D7 (ext-D5-acceptance.md "Decision 8"), unchanged since the D5 gate, V2 equal to
V1:

* row 14 (dialog 136, MenuZ) `unexplained` 2 in `city`: read with the diagnostic build below (`obj/diagrun2`, V1 city):
  two FILLRECTs 0,0,512,320 with no probe open on the city screen's window 0x2038 (key 8248; the window at 60,76..580,404
  that row 97, the city screen, draws on before and after), rule set 0, between dialog 136's creation (its box 0x205A
  at 203,193..437,287) and the city window's return to active.  It is the city screen's own fill under the box, counted
  to row 14 because the box's row is on top: D7's screen, not D6's box.  The staged ext_p0.py records it as
  `ROW_ALLOW[(14, "unexplained")]` for the run `city` only (D6f's landing places dialog 136's box on A and leaves
  the city window's fill: the count is the same on D6f's outputs).  With it the staged decision-8 code passes on D6f's
  outputs (`obj/rowcheck.py`: ROWCHECK_OK runs 66); without it, or with the allowance for another run, V1 and V2
  `city` fail (ROWCHECK_FAILED=2: the check is not vacuous).

* row 0 (an empty stack) `unexplained` 258, `font_unmapped` 72 in the six runs from a save (arrival, load, quiz,
  research, research2, s2).  D5's table gave it to "D6's play renderer" (the play's first drawing after a Load
  before the play row is on the stack); D6g's read of the events (section "Row 0 after a Load") shows that it is the
  leader audience's later speeches on dialog 142, drawn after the stack has lost rows 100 and 19: D7's (D7k).
* rows 11, 15, 17, 19, 23, 24, 26, 67..79, 88, 97, 98, 101..104, 109, 114, 120, 122, 124, 130: play dialogs, the city
  screen, reports and endings: D7's, not D6 rows.

### Row 0 after a Load

Read 2026-10-17 about 02:10 UTC with a private diagnostic build that never lands: `obj/diagpatch.py` patches a copy of
the landed sources (D6e's tree; the overlay `obj/src`) so that, with the environment variable `D6G_DIAG` set, every
counted `unexplained` or `font_unmapped` event writes one stderr line: the row on top of the stack, the event's own
ring entry (shadow kind and key, the draw op, its rectangle, the innermost open probe, the rule set), the font id and
the return address.  Built as `checked` (`obj/diag-b-checked.log`, BUILD_OK), run with `ext_p0.py` V1 over the six
runs from a save into the private root `obj/diagrun` (P0's verdict there is not a result: the private root has no V0
references), summed by `obj/diagsum.py`.

* **The events.**  Each of the six runs has the same 55 row-0 events (6 x 55 = 330 = V1's 258 + 72): 35 TEXTOUTs under
  TextBoxDraw 1068:258F and 8 BITBLTs with no open probe (rectangles 0,0,939,320 and 52,220,460,314), all on the
  shadow of window 0x2040 (key 8256), rule set 0; and 12 `font_unmapped`, font id 201, at the return addresses
  1160:333F (in ShowLeaderMessage 1160:328E), 1220:03DF (in MenuZ 1220:0156) and 1068:2045 (in SetTextFontSizeColor
  1068:1F7E), one each per page.  Window 0x2040 is dialog 142, the leader audience: in every run's console the
  dialog's creation (`CreateDialog 142`, line 183) and its deactivation (line 256) enclose every row-0 event, and the
  13 events just before them are row 19's (the same kind: the first speech; font 201 also at 1160:22D0 in
  RequestLeaderAudience).
* **Why the stack is empty.**  HoldDiplomaticAudience 1160:0000 calls RequestLeaderAudience 1160:20C0 before every
  speech (`claude/docs/subsystems/diplomacy-science.md` 4.4.1, 4.4.2): the first call opens dialog 142 (GR_DialogOpen,
  call site 1160:2251) and returns with the dialog open; the later calls return the stored answer (each run: 3 entries
  of RequestLeaderAudience, 1 of HoldDiplomaticAudience).  On the scene stack, RequestLeaderAudience's entry pushes row
  100 (Diplomacy screens; no exit key) and the GR_DialogOpen pushes row 19 above it, bound to dialog 142.  The return of
  RequestLeaderAudience is row 100's own exit, and an exit pops its row with every row above it
  (`pdos_scene_on_probe`), so row 19 goes while its window stays; the audience's later speeches (ShowLeaderMessage ->
  MenuZ -> TextBoxDraw on dialog 142) are drawn with nothing on the stack.
* **Whose.**  D7's: rows 19 and 100 and the leader font are D7k's (BRIEF-d7.md D7k).  Font id 201 is a tribe font (ids
  200..215), which `pdos_fontmap` maps only through the leader table that no product code sets yet
  (`pdos_fontmap_set_leader_table`: the tests only; D7k keys it by `g_playerCivId`).  It is not D6's play renderer:
  no play drawing (map, small map, status, unit panel) is among the 330 events.  Row 0 is not a gate row, and D6g
  changes nothing in the scene engine; the stack's handling of the audience (row 100 spanning HoldDiplomaticAudience,
  or a window-bound row kept while its window exists when a row beneath it pops) is listed for D7k under "For the
  records".

## Z-1..Z-3 for the DOS profile

(`obj/ztable.py` over the gate's Checked and CheckedNoObs outputs and the sweep; the table in `ext-D6-acceptance.md`.)
Z-1: test_map 338 checks (CheckedNoObs 1), test_host_win32 410, ext_adapt zoomkeys-dos (79 chord and wheel lines
`events 0`, one switch, the DOS layer drawn in 72 shows).  Z-2: ZOOM_OK combinations 32 runs 108 samples 628 (dos a at
every size against the 240 DOS golden lines, dos a = dos b and sw at 1920x1440, the layer samples across win b, dos
a/b and sw, not zoomed 38/448) and the full matrix (ZOOM_OK combinations 32 runs 160 samples 776, not zoomed 64/796;
dos a = dos b at every size and in the soak; the tree's goldens equal).  Z-3: ring-dos = ringref (ring_press 1,
refused 0), zoomkeys-dos = plain, V4d's 27 runs equal to V0 (the DOS layer drawn in 22 runs, the Windows layer in 22),
P0_OK checks 476, CheckedNoObs P0_OK checks 62 with V5's zoom refusals.  All PASS.

## The agent UI check (decision 7, ruling 7)

One attempt, after the gate cycle, with the landed Release `civ64.exe`; civ64 windows only; shots under
`claude/port/build/ext-d6-ui/`; an agent observation, not user acceptance.  If the attempt is interrupted ("user
interrupt") the agent stops, ends civ64, does not retry, and the gate counts on headless evidence with the visible
checks listed for the user (as at M).  If the desktop is not usable (locked, no capture, the foreground refused) that
is recorded once and the gate counts on headless evidence.

**Method** (`obj/ui/agentui.py`): civ64 from a private copy of the exe, a private copy of `build/gamedata` without the
`.wav` files (no sound; `CAE3540B.SAV` in it), a private copy of `user-builds/d4/civdos.zip` and a private home
(USERPROFILE and LOCALAPPDATA of the child: the user's `%LOCALAPPDATA%\civ64\civ64.cfg` is never read or written, as
TLD's GUI check did), `--multi-instance` (a civ64 of the user's is not disturbed); `--graphics dos --window 1920x1440
--scale-mode integer --zoom 0 --aspect 4:3`.  Input is real (SendInput) and is sent only while civ64 is the foreground
window; shots are PrintWindow images of civ64's client (an open popup menu of civ64: its screen rectangle).  The agent
looks at every shot before the next step and records what it sees.

**Steps** (each with a shot; coordinates read from the previous shot):
1. `desk` (the input desktop usable, the session active); `start`; the DOS intro: any key skips to the DOS title menu.
2. Load a Saved Game (Down, Return) -> the DOS load slot screen -> Return on `CAE3540B.SAV` -> play.
3. Play at level 0 in the DOS graphics: the DOS map (D6c), the World Map's DOS small map with its white frame, the
   Status window's DOS column and the unit panel (D6e); the DOS menu bar (D6f).
4. The menu bar and one drop-down: a click on a DOS title (GAME); the drop-down shot (`menushot` if it is a popup);
   Escape.
5. Zoom by chord: Ctrl+Shift+Minus (-1: the DOS ring, the World Map's rectangle larger), Ctrl+Shift+0 (0),
   Ctrl+Shift+Plus (+1), Ctrl+Shift+0.
6. Zoom by wheel over the map: one notch back (-1), one forward (0), one forward (+1), one back (0).
7. A ring click at -1: a left click on a ring square outside the core's view: the map recentres there (and the World
   Map's frame follows).
8. A profile switch at -1: Ctrl+Shift+Backspace: the Windows map at -1 at the same place; M's Windows-profile checks
   there (ruling 7): chords, wheel, the system menu's three zoom items (Alt+Space and the menu's items by keyboard;
   the mark follows the level), a ring click; Ctrl+Shift+Backspace back to the DOS graphics at -1.
9. `stop` (WM_CLOSE, the exit warning's Exit Anyway; else taskkill), the private `civ64.cfg` read, the data copy
   removed; no civ64 left running.

**Result** (2026-10-17 06:03:13..06:09:05 UTC; `build/ext-d6-ui/log.txt`, 112 lines, and shots 01..33): done in one
attempt, not interrupted.  `desk`: the input desktop usable, session 1 the active console session.  civ64 pid 35972
(a copy of the gate's Release `civ64.exe`, the user build's), its window at 312,36..2248,1515 with a 1920x1440 client.
The user's own civ64 from build d6f was running and was not touched; the user's `%LOCALAPPDATA%\civ64\civ64.cfg`
(last written 2026-10-10) was not read or written.

| Shots | Step | Seen |
| --- | --- | --- |
| 01, 02 | the intro, a key | the DOS intro ("A MICROPROSE PRESENTATION"); the DOS title menu, no Go Back row |
| 03, 04 | Load (Down, Return), Return on the slot | the DOS "Select Load File..." slot screen (Emperor Caesar, Romans, 3540 BC and nine EMPTY slots); play: the DOS map at twice the size, the World Map's DOS small map with its white frame, the DOS status panel (30,000, 3540 BC) and unit panel (Roman Militia, Rome, Grassland), the DOS menu bar GAME .. HELP |
| 05, 06 | a click on GAME; Escape | GAME's DOS drop-down (Save Game, Tax Rate, Luxuries Rate, FindCity, Options, REVOLUTION!, Retire, QUIT to DOS), the title highlighted, no Cancel row; closed, the map whole |
| 07..13 | Ctrl+Shift+Minus, +0, +Plus, +0, +Plus, +0, +Home | -1 (the DOS ring, the World Map's rectangle larger); Ctrl+Shift+0 no effect (08 at -1, 12 at +1); Plus to 0 and to +1; Home to 0 |
| 14..17 | the wheel over the map: back, forward, forward, back | -1, 0, +1, 0 |
| 18, 19 | Ctrl+Shift+Minus; a left click on a ring square | -1; the map recentred there, the World Map's frame followed |
| 20 | Ctrl+Shift+Backspace | the Windows map at -1 at the same place |
| 21..24 | Ctrl+Shift+Home, +Plus; the wheel back twice | 0, +1, 0, -1 in the Windows graphics |
| 25..31 | the window menu (a click on civ64's window icon), Down, Return | the menu's three zoom items with the mark on "Zoom out (half)"; "Normal map zoom" chosen: 0 (28), the mark moved to it (29); "Zoom out (half)" chosen: -1 (31) |
| 32 | a left click on a ring square | the Windows map recentred there |
| 33 | Ctrl+Shift+Backspace | the DOS map at -1 at the same place |

`stop`: the exit warning's Exit Anyway; civ64 ended; the private `civ64.cfg`: zoom=-1, graphics=dos, scale_mode=integer,
the window as placed; the private data, exe and `civdos.zip` copies removed.

Departures from the plan, each recorded as it happened:
* **The main row's Ctrl+Shift+0 does not reach civ64 on this PC** (no effect at -1 and at +1).  This is the known
  condition of the checklist's M-3 ("a running keyboard tool takes it first"; the user chose Ctrl+Shift+Home, unit
  UX4b); Ctrl+Shift+Home and the window menu's "Normal map zoom" were used instead.  The chord's command is covered
  headless (`test_host_win32`; ext_adapt zoomkeys-dos with `cmd zoom` lines).
* **Alt+Space** (step 8's way into the window menu) opened a launcher tool of the user's desktop that holds that
  hotkey, not civ64's window menu; the tool stayed open about 20 s, nothing was typed into it, and it closed when the
  driver brought civ64 to the front again.  A posted `WM_SYSCOMMAND SC_KEYMENU` does nothing (civ64's host keeps Alt
  and F10 for the game's menus, as designed).  The window menu was then opened by a click on civ64's window icon, and
  its items were chosen by keyboard as planned.
* No Go Back / Cancel row was seen on a DOS screen (the title menu, the slot screen, GAME's drop-down).

## Build-slot steps (the gate)

After D6f's and FCE's landings, when the orchestrator gives the slot:
1. Bases: the tree's last cycle's V1 and V2 outputs read with `obj/rowsum_d6.py` (the counts after D6f and FCE);
   `obj/mk_extp0.py` with the allowances those counts need (`--allow 14:unexplained@city=...` while the city
   screen's fill stays; none if it went), `obj/rowcheck.py` ROWCHECK_OK on those outputs; `obj/land/land.py --base`,
   then the dry run.
2. `land.py --write`: the snapshot of `build/test/Checked` (into `build/d6g-prep/before`), `tests/harness/ext_p0.py`
   and this record copied in, `build/d6g-prep/landed.sha256`.
3. The cycle: `obj/land/d6-gate-cycle.ps1` (eight steps, `build/d6-gate-status.txt`, logs
   `build/d6-gate-<n>-<step>.log`); the known w32_test_host_win32 GetKeyState flake: that test alone, then the step
   again as `-RunSuffix -r2 -FirstStep n`.
4. The sweep after the cycle's ALL_GREEN (a heavy job; it does not run beside the cycle): the landed Checked harness
   copied to `build/d6g-stage/obj/exe/gate/civ_harness.exe` (step 1's build: its time within step 1, no later step
   builds Checked); then `obj/sweep_zoom.py --exe that --root build/d6g-stage/obj/run/sweep -j 4` and
   `obj/golden_cmp.py`.
5. `obj/land/markers.py`, `obj/land/variants.py`, `obj/rowsum_d6.py --md`, `obj/ztable.py`; the comparison of the
   step-2 sections against the snapshot.
6. The agent UI check (`obj/ui/agentui.py`, the landed Release `civ64.exe`; section "The agent UI check").
7. `obj/land/pending.py` (the checklist's pending rows by build), `ext-D6-acceptance.md` filled, this record's
   Results; `land.py --docs --write` (the two documents into `docs/`); the report.

As run: 1, 2 (05:13:54, 05:14:08), 3 (05:14:16..06:02:50), 5 (after step 2 and after the cycle), the user build
(about 06:03, `build/d6g-prep/mk_userbuild.py`), 6 (06:03:13..06:09:05), 4 (06:09:26..06:49:31; the copy of
step 1's Checked harness, built 05:17:21, SHA-256 60610d62.., equal to `build/x64/Checked`'s), 7.

## Decisions within the brief

* **The full matrix as a private run** (decision 6: "the full matrix runs once at D6g"): `sweep_zoom.py` imports the
  tree's ext_zoom.py and replaces only its matrix rule (`copies`), so every check is the tree's; no runner option is
  added to ext_zoom.py (test.cmd's matrix is unchanged, and no other unit's goldens move).  Its goldens go to a
  private file and are compared with the tree's afterwards, so the DOS soak (which has no golden in the tree) is
  checked by determinism (dos a = dos b) and by the layer samples against win b and sw, as D6d specified.
* **ext_mirror, ext_p0 and ext_frames** run in full in `test.cmd checked` already (D6a's 29 mirror runs with `--mirror
  2` and dos-settled; V1, V2 and V4d over every scenario; ext_frames' S1, S3 and Birth); the gate cycle's run is their
  full run.
* **The agent check's driver** is a script (real input, PrintWindow shots), not the computer-use tools: those need a
  per-application approval prompt, their screenshots are downscaled and cannot be saved 1:1, and a script closes civ64
  promptly in every case; the agent still drives it step by step and looks at every shot.

## Deviations from the design

* ROW_ALLOW's entries name the runs they cover (`(reason, runs or None)`, `row_allowed()`), a form D5f's plain
  `(row, counter) -> reason` did not have: a recorded count in one run does not excuse the same row and counter in
  another.  (Prepared: row 14 `unexplained` in `city` only, while the counts after D6f and FCE keep it.)
* The menu rows without a probe of their own (and rows 96, 107, 121, 135) are in GATE_ROWS although they are never on
  top of the stack: they name D6's rows completely; they cannot fail.
* The full ext_zoom matrix is a private run with the tree's runner (`sweep_zoom.py`), not a test.cmd section; its
  goldens are written to a private file and compared with the tree's (`golden_cmp.py`), so no golden moves in the
  tree.
* The agent check opened the window menu with a click on the window icon instead of Alt+Space (above).

## User direction 2026-10-16 (no added Go Back / Cancel rows)

D6g adds no row, box or screen.  The agent check saw no Go Back / Cancel row on a DOS screen (the title menu, the
slot screen, GAME's drop-down; D6f recorded none).

## What the user checks

Nothing new from D6g.  The gate's user build `build/user-builds/d6g/` (the gate's Release `civ64.exe`, SHA-256
7256863d9c7e13c3bd48bec7b89a412acfa12424bd0c7b75c2ae5feade0b9353; `CIVWIN.zip` and `civdos.zip` as in build d4) has a
`WHAT-TO-CHECK.txt` with no new items: the D6 phase gate's build, all pending items checkable there, the list grouped
by the build that brought them.  The checklist at the gate: 223 items, 162 passed, 58 pending (all checkable), 3
superseded; the D6 items among the pending: D6-1, D5-7, D6e-1..D6e-7 and D6f-1..D6f-8 (`ext-D6-acceptance.md` "User
checks left pending").

## Landing

* Bases (`land.py --base`, 05:13:54 UTC): the tree's `tests/harness/ext_p0.py` a28c811b.. (LF), build.cmd 40de571d..,
  test.cmd 77c7bb11.. (unchanged by D6g).  `obj/mk_extp0.py --allow 14:unexplained@city=...` re-derived the staged
  file from that copy; `obj/rowcheck.py` ROWCHECK_OK on D6f's cycle's outputs (and ROWCHECK_FAILED without the
  allowance or with it for another run).
* Copy-in (`land.py --write`, 05:14:08 UTC): `tests/harness/ext_p0.py` da186fd5.. and this record's draft 2b866dcb..;
  the snapshot of `build/test/Checked` into `build/d6g-prep/before/` (63 files); predictions written before
  (`build/d6g-prep/predictions.txt`).  After the cycle and the sweep both files and build.cmd / test.cmd still had
  their landed hashes.
* Predictions against the results: as predicted, except nodos' file count 1751 -> 1752 (this record is a new file
  under `docs/`, which nodos scans; 0 hits).
* Documents (`land.py --docs --write`): this record (final) and `ext-D6-acceptance.md`.

## For the records

* For D7k (and the D5 acceptance record's decision-8 table, if it is annotated): row 0's counts in the six runs from a
  save are the leader audience's later speeches on dialog 142 (section "Row 0 after a Load"), not D6's play renderer.
  When RequestLeaderAudience returns, the scene stack pops row 100 and row 19 with it although dialog 142 stays open;
  D7k's renderer for row 19 needs the audience's whole span on the stack (row 100 entered at HoldDiplomaticAudience
  1160:0000, or a window-bound row kept until its window goes when a row beneath it pops), and the leader font table
  (`pdos_fontmap_set_leader_table`) set in the product.
* For D7 (the city screen): row 14's ROW_ALLOW entry (`city` only) goes when the city screen's fill under a MenuZ box
  is D7's renderer's.
* For STATUS: the D6 phase gate met; the known differences R1 and R2 (no owner unit); the X9 coverage torn-lines
  item; the agent check's result (agent-observed, not user acceptance; the main row's Ctrl+Shift+0 does not reach
  civ64 on the user's PC, as M-3 says).
* For DOS-PROFILE.md: D6's rows as gate rows (decision 8), row 14's recorded count, row 0's owner (D7k).
* The rest is gathered in `ext-D6-acceptance.md` "For the records".

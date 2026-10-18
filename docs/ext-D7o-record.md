# Extension phase D7, unit D7o (the sweep, the reach and the gate) - record

Draft for the build slot (BRIEF-d7.md unit D7o; decisions 8, 12, 13, 14, 16, 17 with the orchestrator's rulings;
extension session E4, track A).  Staged in `build/d7o-stage/` on the tree after D7n's landing (RELEASE_OK 06:28:33 UTC;
bases copied 06:41:38 UTC, `obj/base-at-copy.txt`), rebased onto D7g's landing (copy-in 06:55:22 UTC, `obj/rebase-d7g/`)
D7h's (copy-in 09:15:07 UTC, `obj/rebase-d7h/`) and D7i's (copy-in 10:25:44 UTC, `obj/rebase-d7i/`) and D7h2's (copy-in 11:53:43 UTC,
`obj/rebase-d7h2/`) and D7g2's (copy-in 14:28:22 UTC, `obj/rebase-d7g2/`).  Private builds and runs in `build/d7o-stage/obj/` only (the overlay `obj/src` = the
tree + the stage; the tree's build/gamedata, dosdata and cache read only).

## Result

Decision 8's gate holds at 0 for every D7 row (no ROW_ALLOW entry); every FEATURES row is reached in the DOS profile
with its frame the DOS form or class W (FEATURES_REACH_OK rows 108 dos 104 w 4); the full runs on the final overlay
(16:05..16:45 UTC) are all green: P0_OK checks 521 (Checked V0..V8s with `--g1`), P0_OK checks 62 (CheckedNoObs V5),
EXT_FRAMES_OK, EXT_TIMELINE_OK (every entry), EXT_ADAPT_OK checks 421 (every entry), ZOOM_OK, pdos_scene_check PASS
(1086 checks, 141 scene rows, 11 font rows), ADAPT_OK rows 166 steps 27, REGISTRY_OK, NODOS_OK.  The scene ledger's 80
D7 rows: 27 ready, 4 spanning their function (their screens' rows ready), 1 class A reached, 40 covered by their unit
tests and pairs (never innermost in a shown state of these runs), 8 class W with their section-4 reasons.  The
counterpart ledger: 140 numbered rows and 7 effects closed, none pending.  The agent check: one attempt, completed.

## Status

Landed 2026-10-18: copy-in 17:03:05 UTC (`build/d7o-prep/land.py`, 22 files, `landed.sha256`; the tree's previous
files in `build/d7o-prep/tree-before/`).  First cycle: 1-build-checked BUILD_OK (17:03:10..17:06:25), 2-test-checked
TESTS_FAILED=1 (17:06:25..17:33:24): test_pdos_scene's font map count (10 rows; the row-79 row makes 11), a unit test
the staging had not run.  `tests/test_pdos_scene.c` staged on the tree's file and copied in at 17:35:00 UTC (11 rows
and the row's check; 147 -> 148; Checked, CheckedNoObs and Release built and run on the overlay first; recorded in
`landed.sha256`).  Second cycle (suffix b): 1-build-checked BUILD_OK 17:35:05..17:38:19 (194 s), 2-test-checked
TESTS_OK 17:38:19..18:05:09 (1610 s), 3-g1-checked EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) 18:05:09:
**ALL_GREEN**; 4-build-release BUILD_OK 18:05:22..18:08:29: **RELEASE_OK** (`build/d7o-status.txt`).
`build/d7o-prep/compare.py` against the snapshot before the landing: 52 of 66 outputs equal; the others as predicted
(test_input 689 -> 698, test_pdos_pedia 73 -> 79, test_pdos_profile 59 -> 63, test_pdos_scene 147 -> 148; ext_p0
P0_OK checks 476 -> 477 with the counters' lines naming D4..D7; EXT_ADAPT_OK checks 420 -> 389 under
`--representative` with d7h3-help; ext_timeline without palace_view; pdos_scene_check 1084 -> 1086 checks, 11 font
rows; ext_replay's V1 quiz, research and research2 draws 22, 1, 1 -> 0; d7d-city's `city` copies 209 -> 133 (the
declined DrawTile buffers); D7i's `news` absorbed counts higher; coverage, nodos' file count and times).  After the
landing, the tree's ext_p0 `--g1 --vars V0 --only p49-c2` on a fresh `--root` (`build/d7o-prep/g1check`): P0_OK checks
2 (the run folder fix).  User build `build/user-builds/d7o/` (18:12 UTC; WHAT-TO-CHECK.txt with D7o-1..D7o-4 and the
checklist's 175 open items of 18:08 UTC).  D7 is complete: `ext-D7-acceptance.md`.

## What was built

* **The scene log (decision 16's "run's scene log"; `tests/headless/harness.c`).**  No run wrote one: the harness now
  writes `scenes.log` beside presented.log when `--presented` is on and the DOS profile is registered.  At each show
  whose scene state changed, one `show` line: the innermost scene row (`top`: row, class, ready, and `rs` for an R row
  drawn as a re-skin element), the innermost row of a class other than R (`topn`: row, class, ready, and `win`: a
  window row) and the visible profile.  Each increase of one of decision 8's counters (checked after each observer
  event by a listener after the profiles', and at each show) gives one `count` line: the counter, the event, the stack
  with readiness, and for an unexplained event the shadow's last kept event (kind, key, operation, rectangle, the
  innermost open probe).  run.log, events.log and presented.log are unchanged (P0).
* **The reach check (decision 16; `tests/harness/features.py`).**  `--scenes` gives each reached FEATURES row the
  verdict of its frame: `dos` (an innermost R row ready or re-skinned, and the innermost non-R row none, A, a ready N
  row, or an N row of its function only whose screen is not open), `W`, or the failures `R-windows` and `A-fallback`;
  the hold of the reaching event's stable present (or, animated, the event to the run's end), only while the first
  innermost rows stay innermost.  `--require-all`: every row reached and every verdict `dos` or `W` (FEATURES_REACH_OK
  rows N dos D w W).
* **`tests/harness/ext_p0.py`.**  Decision 8 for every row: GATE_ROWS gains D7_ROWS (every N, R and A row; the class W
  rows 10, 28, 95, 108, 125 and 131 are not gate rows: shown in the Windows form; D6's 94 and 141 stay).  Decision
  12: `--g1` runs the G-1 runs that reach a D7 key the scenarios miss in V0 and V1 (below).  Decision 16: with V1 and
  no `--only`, features.py `--scenes --require-all` over every V1 output (`features-V1.txt`).
* **Decision 13 (`ext_adapt.py`, `ext_timeline.py`, `test.cmd`).**  `--representative`, which test.cmd checked passes:
  one D7 entry per scene family (a unit's first pair unless named: d7e-found; d7f-buy, which D7g's runs read; D7g's
  pairs as one parallel entry; D7h's d7h-pedia; D7i's five pairs as one entry (four scene families sharing one run
  set); d7n-conq; ext_timeline without palace_view, with D7i's discovery); D7h2's two pairs (d7h2-help, d7h2-research)
  as one entry, D7g2's runs (the notes, the government menu, the sale question) likewise.  Without it every entry runs:
  D7o's full runs.
* **Recorded D7d follow-ups for row 97** (the orchestrator's rulings of 07:55 and 08:05 UTC; detail under decision 8
  below): `present/dos/pdos_scn_city.c` declines the shadows of DrawTile's buffers on the screen's ports (D7b's
  pattern); `present/dos/pdos_adapt.c` decides Alt+letter on the DOS city screen as DOS reads it (I-city/key's text in
  `pdos_adapt_tab.c` and the generated DOS-PROFILE 1.7.2 say so); `tests/test_input.c`
  nine checks; scenes.log's w_over_n origin fields and ext_p0's cause class "scripted w16 input".
* **A recorded D7h follow-up, d7h3** (the orchestrator's message of 12:50 UTC; D7i's agent's patch
  `build/d7h3-patch/`, applied by its `obj/apply.py` on the tree after D7h2, carried in D7o's landing): a 9..10 ms flash
  of the Windows city dialog when a Civilopedia entry opens over the city screen (D7h2's finding 1).
  `present/dos/pdos_scn_pedia.c/.h`: when the topmost non-R row under the entry's rows 99 and 11 is a ready N row with
  no window over it, the entry's rows are ready from ShowCivilopediaEntry's entry on (`hold_n`), so the N frame
  continues until the page draws; presentation-diag's `pedia` line gains `holds`.  `tests/test_pdos_pedia.c` +6 (73 ->
  79 in Checked, run on D7o's overlay); `tests/harness/ext_adapt.py` d7h2-help's new check `d7h3-help` (only N shows
  from Alt+H to the entry's end, `holds` 1).  The three pedia files and ext_adapt.py's hunk are taken as the patch has
  them (ext_adapt.py merged three-way with D7o's edits, clean).  After it: ext_p0 V0..V2 of city, new and menus
  P0_OK checks 21.
* **A recorded D7d follow-up, d7d2** (the orchestrator's message after 13:10 UTC; the patch `build/d7d2-patch/`,
  bases the tree after D7h2, carried in D7o's landing): after Load a Saved Game in the DOS graphics page 2 still held
  the intro's BIRTH1.PIC (O2:028C), since only Birth (R:01A8:054E..0576) restored it: the city screen's panel texture
  and building icons came out magenta, and the Civilopedia, save-screen and end-screen borders wrong.
  `present/dos/pdos_profile.c`: at WdwMapOpen's exit (R:01A8:0810's O5:1455, every branch that reaches play) page 2 of
  both machines gets SP299.PIC's (160, 50, 160 x 150) again, and the box texture flag DGROUP:2F98 := 1 (R:01A8:0815).
  `tests/test_pdos_profile.c` +4 (59 -> 63 in Checked, run on D7o's overlay).  After it: ext_p0 V0..V2 of city, new and
  menus P0_OK checks 21; V1 `new` (through Birth) shows the same frames as before, V1 `city` (a loaded save) 41 shown
  frames differ (the city screen's texture and icons now SP299's).
* **A recorded D7h follow-up for row 79** (found at the rebase onto D7h: `menus` V1 and V2, r79.font_unmapped 1 at
  98.0 s, both attributions): ShowPediaEntry's TextFont(0) at 1068:1B98 after page B, the core's only TextFont(0)
  (its SetCivFont at TextFont 1100:0A40), had no font map row; `present/dos/pdos_fontmap.c` maps it to DOS font 1
  (DOS restores font 1 after a page, O8:1655; inferred, as D7h's index font).  The unmapped fallback was font 1
  too, so nothing drawn changes: r79 0, presented.log of V1 and V2 `menus` equal to the run before.
  `tests/harness/pdos_scene_check.py`'s font map check counts 11 rows, and takes a site row whose core call is the
  TextFont wrapper's `SetCivFont(0x11000A45u, fontId)` (an id of the caller's) when the row is inferred;
  `tests/test_pdos_scene.c` counts 11 rows and checks the row (id 0 at 1100:0A40 -> font 1, mapped; +1 check).  The
  test was missed before the landing: the first cycle stopped at step 2 on it (below).
* **A recorded D7i follow-up for rows 23, 24 and 26** (found by the full runs, 15:27 UTC: `research`, `research2`,
  `quiz`, uninit-s4 and -s5 in V1 and V2, colour_nearest 1, 1, 22, 13 and 56 by row): the discovery and the quiz draw
  DOS's whole screen on page 0 (pdos_scn_news.c) and their window's copies are absorbed, but the core's TextBoxDraw
  frames were still replayed into the logical port's shadow, each taking the DC's RGB text colour by the nearest
  search.  `present/dos/pdos_replay.c` decide(): while pdos_news_kind() is the discovery or the quiz, a frame is the
  scene's (presentation-diag's `replay` line gains `news`; `pdos_replay.h`).  Nothing shown changes: presented.log of
  V1 and V2 `quiz`, `research`, `research2` and V1 uninit-s4 and -s5 equal to the runs before (the replayed boxes were
  never copied out); the rows' colour_nearest 0.
* **Tooling fixes (the ruling's class (a))** found by the full runs: decision 16's verdict read D7i's newspaper over
  the play screen (the A canvas, its own elements; the picture dialog's row 25 stays not ready) as `A-fallback`
  (`arrival` V1 at 87.0 s): scenes.log's `show` lines end with `aown O` (pdos_news_on_a) and features.py takes `aown`
  1 as `dos`.  ext_p0's p49-c2 layout run made its run directory under a fresh `--root` whose `run` folder did not
  exist yet (the harness makes one level), so p49-c2 was missing from the first full run: ext_p0 makes `run` first.

## Decision 12: the G-1 runs that reach a D7 key the scenarios miss

The probe logs of the 77 G-1 runs (`build/harness/game`, the D7n cycle's) against ext_p0's V0 outputs (the 27 scenarios,
gate3b and D5f's runs): no D7 dialog template is missed; 19 D7 keys are (decision 12's list), of which 11 G-1 runs reach
12: p49-c2 (LaunchSpaceship), p49-find-capture (PlayCityCaptureAnimation), p49-find-civilwar (the capture,
StartCivilWar), p49-find-diplomat, -mercenary, -sabotage (DiplomatEntersCity), p49-find-riot (ProcessCityDisaster),
p49-find-space (HumanPlaceSpaceshipPart), p49-find-unrest (ProcessCityDisaster, TransferCityByRevolt), uninit-s4 and
uninit-s5 (the capture and disorder animations, ShowHistorianReport, SetGovernment, ShowCivilizationDestroyed,
WaitTicksOrInput).  Never reached by any run: DrawCivDossier, DrawBeveledLabelBox, AnnounceGovernmentChange,
ShowConqueredCivLeader, PlayCelebrationAnimation, AnimateNuclearExplosion, FrameRectDoubleDevice (unit-tested; D7n's
edited saves reach ShowConqueredCivLeader and AnimateNuclearExplosion in ext_adapt).  The runs use p4tests.py's and
uninit.py's own scripts, edited saves, times and options; private result (07:00 UTC): V0 equals ext-g1-baseline for the
nine p49 runs, V1 equals V0 for all eleven.  Full runs (16:05..16:15 UTC): the same, "decision 12's G-1 runs (11)" PASS
in V0 and V1, every V1 run's counters 0.

## Decision 8: the counters by scene row; row 97 (the orchestrator's ruling of 2026-10-18 07:15 UTC)

D7d's record left row 97 (ProcessCity's city screen) at 2116 counts, then 331 after its own fixes.  On the tree after
D7g, scenes.log's attribution gave 1034 counts in V1 and V2 (07:43..07:47 UTC, `obj/cls97.txt`), all with the city
screen open (rows 97 and 25 ready): 1024 unexplained raw bits (OBS_BMP_BITS) on core bitmaps, under DrawMapTile (600),
no open probe (396) and DrawShapeAndFlush (28), and 10 w_over_n (the City menu's drop-down over the screen).  No class
(a) or (c) count; both are D7d follow-ups staged here by the orchestrator's ruling of 07:55 and 08:05 UTC.

* **The unexplained raw bits: D7b's `tile_made` pattern, not D7j's device-resolution ports.**  The condition first: the
  buffers are never shown after the screen.  A private observer log (overlay only, not staged) of every bitmap made
  while row 97 was open, in V1 and V2 of `city` and `new`: the bitmaps given raw bits while the screen showed are
  exactly the counted ones (city 331: 14x14 44, 16x32 88, 18x10 44, 20x19 15, 22x22 15, 24x24 125; new 23, with two
  30x30), each deleted at the virtual time it was made, none copied after the screen closed and none copied into a
  bitmap made before the screen opened (so nothing of them reaches the A map, a map tile's redraw or a next city
  screen); V1 and V2 the same.  The core agrees: DrawTileImpl 11A8:0F56 deletes its mask (11A8:1216), image (1249) and
  back buffer (138E, the raw bits at 135A) before it returns.  By contrast a 32x32 bitmap that `new` makes while the
  screen shows, with no raw bits and no shadow, is kept and copied 23 times after the screen: so the decline is
  limited to DrawTile's own bitmaps, not every bitmap made while the screen shows.  `pdos_scn_city.c`: a DrawTile
  11A8:0CB1 entered on the screen's or the overlay's port (its bitmap `bmp_scr` or `bmp_ovl`) while the screen shows
  opens a window that the next probe closes; the bitmaps made inside it are declined (`own_claim` -1: no shadow).  The
  owner's copies into its ports already take any source.  Result: row 97's unexplained 0 in V1 and V2 of `city` and
  `new` and in V1 of `s3` and `settlers`; presented.log (every shown frame's hash, both graphics) and run.log equal to
  the runs before the change; P0 equal; the full runs' P0_OK, EXT_FRAMES_OK and ZOOM_OK hold with it.
* **The City menu over the DOS city screen: the cause class "scripted w16 input".**  The 701..709 mapping (the core's
  menu dispatch 1048:038D..03AD queues one character each; the DOS screen's keys and buttons give the same character):
  701 Auto Production 'a' = DOS 'A' or the right button on CHANGE; 702 'c' = c or CHANGE; 703 'b' = b or BUY; 704 'v'
  = v or the VIEW tab; 705 'r' = r or RENAME; 706 'i' = i or the INFO tab; 707 'h' = h or the HAPPY tab; 708 'm' = m or
  the MAP tab; 709 'q' = q (passed itself; Escape, Return and any other key DOS does not use leave too) or EXIT.  None
  is Windows-only; for a foreign city the core disables the group (1030:005F).  No host input opens the drop-down over
  the N city screen: Alt alone is consumed (I-city/mod), F10 is decided as a key (the screen's exit), a press at the
  Windows bar's place is the DOS screen's press (I-city/press), and Alt+letter is now decided as DOS reads it (below).
  The 10 counts come from `sc_city`'s w16-level script (a click on the bar at (549, 30), then the item's letter),
  which no host input can produce in the DOS graphics.  scenes.log's w_over_n lines now end with `in script S host H
  clean C` (S: the script's w16-level input events posted since the last clean show, nothing over an N scene and the
  w16 input queue empty; H: host-form lines since the previous w_over_n line); ext_p0.py lists S > 0 with H 0 apart
  ("scripted w16 input (excluded)") with test_input.c's D7o vectors as the evidence; any other w_over_n stays a
  failure.  sc_city keeps its Windows-form script in V1 and V2: those intervals show the A fallback, which real play
  cannot reach.
* **Alt+letter on the DOS city screen** (`pdos_adapt.c` city_out): a key with Alt held reads as its scan code with AL
  0 (R:1D05:03E3), which ProcessCity's DOS key test does not take as a letter, so the screen leaves (R:0D12:56C8): the
  decision now gets no character, and such a key is never passed itself (Escape's pair).  Before, the host's character
  was decided, so Alt+C changed the production and Alt+Q went to the core as Alt+Q.  test_input.c: nine checks (689 ->
  698 in Checked on the tree after D7g2), failing on the base.

## The scene ledger (D7's rows)

Generated by `obj/ledger.py` (private) from the full runs' outputs (ext_p0's, ext_adapt's and ext_timeline's
scenes.log and V1/V2 presentation-diag.log, the counters attributed as ext_p0's gate does) and copied into
`ext-D7-acceptance.md`: 80 rows, 27 ready, 4 spanning their function (97, 100, 78, 103: ProcessCity's, the diplomacy
span, the spaceship span and the replay's; their screens' rows ready), 1 class A reached (110), 40 covered by their unit
tests and ext_adapt pairs but never innermost in a shown state of these runs (their scene shows through an inner row such
as 25 or 98, or the run set does not open them: the FEATURES reach of decision 16 is the headless reach evidence), 8
class W.  Rows 4 and 29 are N and ready by extension SL (the brief's W listing is outdated).

## The counterpart ledger (decision 17)

`obj/counterparts-closures.md` (private), copied into `ext-D7-acceptance.md`: every row of DOS-PROFILE 2.1..2.7 closed
(140 numbered rows and 7 effects): implemented by its unit, not drawn / not used with the row's own reason, or W; none
pending; D7g2 and D7h2 add none; D7o adds the row-79 font map row under F1/F2.

## Decision 13: the full runs

On the private overlay (`obj/src`, its own Checked, CheckedNoObs and Release builds; the tree's build/gamedata,
dosdata, cache and dos read through junctions removed afterwards), `obj/full.sh`, logs under `obj/full/`:

* First pass (15:17..15:45 UTC, `obj/full/run1/`): P0_FAILED=11 (rows 23, 24, 26 colour_nearest in V1 and V2 of
  `research`, `research2`, `quiz` and the soaks; p49-c2 missing; decision 16's newspaper `A-fallback`),
  EXT_FRAMES_FAILED=16 and EXT_ADAPT_FAILED=294 (the overlay's `build/run` did not exist yet: no run started),
  pdos_scene_check 2 failures (the row-79 font map row), REGISTRY_FAIL (no `build/dos/disasm` under the overlay).  Each
  cause is fixed above (the D7i follow-up, the tooling fixes, the scene check's font rows) or in `full.sh` (the run
  folder, the dos junction).
* Final pass (16:05..16:45 UTC): ext_p0 Checked V0..V8s `--g1` P0_OK checks 521 (decision 12's G-1 runs (11) in V0
  and V1; decision 16 FEATURES_REACH_OK rows 108 dos 104 w 4; every V1 and V2 counter 0 but the run `city`'s r97
  w_over_n 5, scripted w16 input (excluded)); CheckedNoObs V5 P0_OK checks 62; ext_frames EXT_FRAMES_OK (16 checks);
  every ext_timeline entry EXT_TIMELINE_OK (65 checks); every ext_adapt entry EXT_ADAPT_OK checks 421, among them
  d7f-buy (5 checks) and d7h-pedia (5) passing inside the whole suite, and d7h3-help; ext_zoom ZOOM_OK combinations 32
  runs 108 samples 628 (d7d2 changes no zoom golden); pdos_scene_check PASS 1086 checks, 141 scene rows, 11 font rows;
  `adapters.py check` ADAPT_OK rows 166 steps 27; `registry.py check` REGISTRY_OK; `nodos.py check` NODOS_OK.

## Decision 14: the agent check

One attempt, 16:45..16:47 UTC, after the full runs, under D6 ruling 7's rules: `obj/ui/agentui.py` (D6g's script),
a private copy of the overlay's Release civ64.exe with private gamedata, DOS data and home, `--multi-instance`
(the user's civ64 untouched), `--graphics dos --window 1920x1440 --scale-mode integer`; real input only while civ64 was
the foreground window; shots of civ64's own client under `build/ext-d7-ui/` (01..11 with log.txt).  Sampled: the DOS
intro and title menu, Load a Saved Game (the SL chooser), the play screen, the DOS city screen after the load (the
panels' blue SP299 texture and the building and unit icons drawn correctly: d7d2), CHANGE's DOS production list with
"(HELP AVAILABLE)", Alt+H to the Civilopedia entry (pages A and B with the ornamental DOS border after a load: d7d2,
d7h3; a flash of 9..10 ms is below the shots' rate), Escape back to the list, EXIT, F1's City Status (the O14 frame).
civ64 ended by the exit warning's Exit Anyway; no fault.  Completed; an agent observation, not user acceptance.

## User checks (proposed for the user build)

* d7d2: in the DOS graphics, Load a Saved Game, then open a city: the city screen's panel has the dark blue texture
  and the building icons are drawn correctly (no magenta).
* d7d2: after the same load, open a Civilopedia entry: its border is the ornamental DOS border (not magenta or the
  intro's picture).
* d7h3: in the DOS graphics, on the city screen's production list, Alt+H: the Civilopedia entry opens with no flash
  of the Windows city dialog.

## Deviations

* The full runs ran on the private overlay before the landing (its own builds of the staged tree), not on the tree;
  the tree's three-step cycle after the landing runs test.cmd's representative set.
* The cause class "scripted w16 input" (ruling of 08:05 UTC) keeps sc_city's w16-level script and lists its five
  w_over_n counts apart instead of counting them; any other w_over_n stays a failure.
* A D7i follow-up (rows 23, 24, 26) and three tooling fixes found by the full runs are carried in D7o's landing, as the
  rulings' precedent for D7 residuals (rows 97 and 79).

## For the records

* RUNNING: scenes.log (harness.c, with `--presented` while the DOS profile is registered: `show` and `count` lines);
  features.py's `--scenes` and `--require-all`; ext_p0's `--g1` (decision 12's runs, D7o's full runs only); ext_adapt's
  and ext_timeline's `--representative` (test.cmd checked; without it every entry runs).
* Checklist (the orchestrator's): D7o's user checks D7o-1..D7o-4 (d7d2 twice, d7h3, the Alt rule) pending.

* DOS-PROFILE 4.1 (the D7d follow-up's case; the user's rule "in DOS graphics never show a Go Back or Cancel row the
  DOS game doesn't have, on any screen; where DOS has a key for it, that key does it, otherwise that choice is only in
  the Windows graphics"): the City menu is unreachable from host input over the DOS city screen; its commands map to
  the DOS keys and buttons in the table of "Decision 8 ... row 97" above.
* FIDELITY F-new: Alt+letter on the DOS city screen is decided as DOS reads it (scan code, AL 0: the screen leaves,
  the letter not acted on), never passed itself (`pdos_adapt.c` city_out; test_input.c's D7o vectors).
* DOS-PROFILE 1.7.2 / `pdos_adapt_tab.c` I-city/key's text: done here (D8's note: 1.7.2 is generated): the row's
  DOS and translation texts name the Alt case, and `gen/dos/adapters.py gen` regenerated 1.7.2 (one line; ADAPT_OK
  rows 166 steps 27 on the overlay).
* DOS-PROFILE 2.4 (the font map) and FIDELITY F-new (D7h's F-new-4 extended): id 0 at TextFont 1100:0A40 (ShowPediaEntry
  1068:1B98) -> DOS font 1, inferred.
* RUNNING: scenes.log's w_over_n fields `in script S host H clean C`; ext_p0's "scripted w16 input (excluded)";
  scenes.log's `aown` field and features.py's `aown` in its scene verdict; presentation-diag's `replay ... news N`.
* DOS-PROFILE rows 23, 24 and 26 (D7i's follow-up): the core's TextBoxDraw frames of the discovery and the quiz are not
  replayed (page 0 holds DOS's screen); DESIGN 12.8's replay paragraph may name it with D7h's and D7k's owners.

## Expected changes

Predictions against the tree before D7o's landing (Checked; the other variants as their programs count):
* test_input +9 (Checked 689 -> 698: D7o's Alt, F10 and bar vectors); test_pdos_pedia +6 (73 -> 79: d7h3);
  test_pdos_profile +4 (59 -> 63: d7d2); test_pdos_scene +1 (147 -> 148: the row-79 font row); test_pdos_replay
  unchanged (86); all measured on the overlay's Checked build;
* test.cmd's ext_adapt (now `--representative`): EXT_ADAPT_OK checks 420 -> 389 (every entry: 421, d7h3-help's one
  more check); ext_timeline (now `--representative`): 65 -> 62 checks;
* ext_p0 Checked (test.cmd, no `--g1`): P0_OK checks 476 -> 477 (decision 16's line); the gate rows grow by D7_ROWS
  (the V1 and V2 `counters` lines unchanged in number); the `scripted w16 input (excluded)` note on the city lines;
* pdos_scene_check: 1084 -> 1086 checks, 10 -> 11 font rows;
* presentation-diag's `replay` line gains `news`; scenes.log's `show` lines gain `aown`;
* presented.log: V1 `city` (a loaded save) changes by d7d2 (41 shown frames); every other run's frames unchanged by
  D7o's own changes (the replay muting and the font row change nothing shown).

## Rebase notes

* D7g (copy-in 06:55:22 UTC): of D7o's files only `tests/harness/ext_adapt.py` changed (D7g's runs); merged three-way
  (`git merge-file -p` on `build/d7g-prep/tree-before/`'s base): one adjacency conflict in the docstring, both kept
  (D7g's paragraph first); D7g's pairs kept whole under `--representative`, and D7f's representative made d7f-buy, whose
  DOS run D7g's check reads.
* D7h (copy-in 09:15:07 UTC): `present/dos/pdos_adapt.c` and `tests/test_input.c` merged clean; `tests/harness/ext_adapt.py`
  (the docstring) and `tests/headless/harness.c` (the includes) had one adjacency conflict each, both kept, D7h's first
  (`obj/resolve_both.py`); d7h-pedia, D7h's only pair, runs under `--representative`.
* D7i (copy-in 10:25:44 UTC): `present/dos/pdos_adapt.c` and `tests/headless/harness.c` merged clean;
  `tests/harness/ext_adapt.py` (the docstring) one and `tests/harness/ext_timeline.py` (the docstring, main) two adjacency
  conflicts, both kept, D7i's first; the representative paragraphs name D7i's entries.  After the rebase: Checked build,
  test_input 682, ext_p0 V0..V2 of city, new, menus and s3: P0_OK checks 28.
* D7h2 (copy-in 11:53:43 UTC): `tests/harness/ext_adapt.py` merged clean (D7h2's d7h2-help and d7h2-research, run
  as one entry under `--representative`); d7h2-help's Alt+H is on the production list (the DOS list's scene, not
  I-city), so D7o's Alt rule of the city screen does not apply to it.
* D7g2 (copy-in 14:28:22 UTC): `present/dos/pdos_adapt.c` and `tests/test_input.c` merged clean;
  `tests/harness/ext_adapt.py` one adjacency conflict in the docstring, both kept, D7g2's first (D7g2's fix of D7h2's
  `rrows` aliasing and its centred A boxes taken as they are); `tests/harness/ext_p0.py`: D7g2 had copied D7o's `--g1`
  hunk for its rows 115 and 126..128, so the identical code merged as one and the docstring keeps D7g2's copy of the
  `--g1` paragraph, D7o's own paragraph reduced to decisions 8 and 16.  d7h3 and d7d2 touch none of D7g2's files.

## Landing

See "Status" above (the copy-in, both cycles, RELEASE_OK, the comparison and the user build).

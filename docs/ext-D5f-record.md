# Extension phase D5, unit D5f (the Hall of Fame, the Load's fill, EARTH and Quit; decision 7's runs, decision 8's counters by row; with D5cR and D5eR) - record

Staged in `build/d5f-stage/` on the tree after the D5e landing (`build/d5e-status.txt` ALL_GREEN 04:58:43 UTC;
BRIEF-d5.md "Units" D5f), rebased onto the D6b landing (`build/d6b-status.txt` ALL_GREEN 07:09:05 UTC, fix 1;
`build/docs-d6b-done.txt` 07:23:17 UTC): the five files both units change (`pdos_common.h`, `pdos_assets.c`,
`pdos_profile.c`, `tests/headless/harness.c`, `gen/dos/registry.py`) 3-way merged onto D6b's landed versions
(`git merge-file -p`, `obj/merge_d6b.py`: MERGE_D6B_OK; harness.c's one conflict, two #include lines at one place,
and registry.py's, both extending OBSERVER_FILES' last line, keep both sides) and DOS-PROFILE.md onto the docs pass's
version (clean: this stage's edits are 1.7.2 only).  The user's reworks D5cR (`ext-D5c-record.md` "User rework
(D5cR)") and D5eR (`ext-D5e-record.md` "User rework (D5eR)") and the general direction of 2026-10-16 (no added Go
Back / Cancel row on any DOS screen) are staged and landed with D5f, in one cycle.  `BASE-SHA256.txt` lists every
base.  Private builds and runs in `build/d5f-stage/obj/` only.  The gate record is `ext-D5-acceptance.md`.

## Status

Landed (2026-10-16 07:49:42 UTC, with D5cR and D5eR) in the build slot (the orchestrator's grant of 07:25 UTC);
the D5 gate's eight-step cycle `build/d5-gate-status.txt` ALL_GREEN 08:37:49 UTC (step 7 restarted after a session
restart): section "Landing" and `ext-D5-acceptance.md` "The final cycle".  **D5 phase gate met 2026-10-16 08:37:49
UTC.**

With `--graphics dos`:

* **View Hall of Fame** (row 7) and the Hall of Fame at the end of a game (row 105) are the DOS program's O3:00D7
  screen (SCENES 7.5), drawn from the core's Hall of Fame entries; any key or a mouse press ends it (I-wait, as
  the core's WaitForKeyOrClick); from the title the title box is drawn over it again (R:01A8:0807).
* **Load a Saved Game** (row 4, class W): the host's file chooser is outside the virtual screen (DOS-PROFILE 4 W3);
  cancelled, the title box again (R:01A8:07C0); a game read, SCENES 7.2's fill in colour 7 (R:01A8:07D0..07E4),
  the pointer hidden, until the play frame.
* **EARTH** (row 5) and **Quit** (row 8): recorded, nothing new drawn (below).
* Decision 8: every unexplained, w_over_n, font_unmapped, colour_nearest and prov_unknown count is also counted for
  the scene row on top of the stack (presentation-diag.log `pdos_rows`); every D4 and D5 row is 0 in every P0 run
  of the DOS variations.
* The core and its inputs are unchanged (P0, G-1).

## What was built

### `present/dos/pdos_scn_fame.h/.c` (new; SCENES 7.5, SCENES-PLAY 7.17; DOS-PROFILE rows 7, 105; ruling 6)

* At ShowHallOfFame 1080:0119's entry (the probe; from the title the call 11E0:0842 with argument -1, row 7; at
  the end of a game the call 1080:06E2 with the new entry's slot, row 105) the view reads the core's entries
  (g_hallOfFame, six records of 4Eh bytes that LoadHallOfFame 1080:0023 has read; w16q_read at the probe step only)
  and draws O3:00D7(slot) on page 0: the screen in colour 15 (O3:00DF), "CIVILIZATION" and "HALL OF FAME"
  (FAME_TEXT, DGROUP:33BE, 33CB) centred at (160, 16), (160, 24) in colour 0, the rule (80, 32)..(240, 32) in
  colour 14, then entries 0..4 from y 40 (entry 5 only for slot 5, in entry 4's place: O3:0151..0172).  OPEN L7
  settled from the listing: an empty entry (score 0 or less) is " ---" at (8, y), 26 rows on; a full one is three
  lines 8 rows apart: rank, the leader, the title FAME_RANKS[difficulty] (DGROUP:33A2), the civilization and
  |year| BC/AD at (8, y) in colour 0, cut after the civilization's name where the line reaches x 320
  (O3:0220..037C); "Population: " in R:1DC4:0337's form (FAME_POP, DGROUP:2FD2), the score and the level at (20,
  y) in colour 7; the rating (difficulty + 1) * score / 50 with the listing's 16-bit product (O3:0468..0477) at
  (20, y) in colour 12; the new entry recoloured 15 -> 14 over (4, y - 2, 296, 26) (O3:04C6, G#3).  Names are the
  DOS records' 16 bytes.  The slot's "Clear" button (O3:0174..01AA, ruling P18) is omitted: the Windows program
  has none (no row is added).
* The pointer is hidden while the title's Hall of Fame shows (R:01A8:07EF .. 0804); the screen stays on page 0 at
  ShowHallOfFame's exit and the title box is drawn over it again (`pdos_seq.c`, R:01A8:0807).
* Dialog 148 of ShowHallOfFame is the view's window; the core's drawing into it (the Windows Hall of Fame's text)
  is the owner's (below).  No emulation write, no clock, no generator, never g_randSeed.

### The sequencer, the owner, the counters (`pdos_seq.c/.h`, `pdos_scn_setup.c`, `pdos_profile.c`, `pdos_assets.c`, `pdos_common.h`, `present.c`)

* `pdos_seq.c`: the probe rows of ShowHallOfFame (the title's call, `SR_HOF_END` 1080:06E5 for row 105), the
  view's open and close, the pointer rule (`pdos_fame_pointer_hidden`); the Load's fill (`load_fill`, SCENES 7.2)
  after a Load that read a game, held until the play scene; a cancelled Load gives the title box again
  (R:01A8:07C0, as before); `pdos_seq_movie_opening()` (inside the intro movie dialog's GR_DialogOpen, ra
  11E0:0044).
* **The picture windows' owner**: the setup owner of `pdos_scn_setup.c` also claims template 148 while it is the
  DOS view's window (the intro movie's, the Hall of Fame's): the core's drawing into it (the movie's frames, the
  title's backdrop, Birth's frames and captions, the clears of the title branches, the Hall of Fame's text) is the
  DOS screens' until the core's play; in play a movie window is the engine's again, except the Hall of Fame's
  while its screen shows.  This removes the 520 unexplained draws every DOS run counted in the intro.
* **Decision 8** (ruling 8): `pdos_diag_set_row_fn` (`pdos_common.h`): with a row function set, each counted event
  of the five gate counters is also counted for the row it returns (`pdos_assets.c` `row_note`;
  `PDOS_DR_UNEXPLAINED`, `_W_OVER_N`, `_FONT_UNMAPPED`, `_COLOUR_NEAREST`, `_PROV_UNKNOWN`: the last two D6b's
  counters, routed since the rebase); `pdos_profile.c` `diag_row`: the scene row on top of the stack, and above
  another row the picture dialog's row 25 counts for that row (the function that opened it); 0 with an empty
  stack.  presentation-diag.log gains `pdos_rows r<row>.<counter> <n> ...` (`present.c`; nonzero entries only).
  `pdos_profile.c`: a hidden scene window (the title dialog at its creation, dialog 143 at its close) has nothing
  over it, so the w_over_n fallback no longer counts those two moments (D5e's record left this to D5f).

### The input side (`pdos_adapt.c/.h`, `pdos_adapt_tab.c`, `gen/dos/adapters.py`; C.12.7, C.14.3)

* `PDOS_AS_FAME` and four I-wait rows: `I-wait/fame-key` (any key passes: ShowHallOfFame's WaitForKeyOrClick ends,
  O3:01AD, R:1459:0918..0947), `I-wait/fame-press` (a left press and its release at the I5 point in dialog 148,
  else its centre: class X), `I-wait/fame-right` (consumed: C.12.7 passes the left press only; DOS's any button
  noted), `I-wait/fame-mod` (a modifier alone: no key for kbhit, consumed).  The Load has no DOS row: the title's
  Return passes as before and the host's chooser takes the host's input (I-pass).
* With D5cR and D5eR: 98 rows (95 at the D5e landing: -3 D5cR/D5eR, +2 D5cR, +4 D5f); DOS-PROFILE.md 1.7.2
  regenerated by `adapters.py gen`.

### Decision 7's runs (`tests/harness/ext_p0.py`, `ext_adapt.py`)

* `ext_p0.py` `d5_runs()`: d5-goback (Go Back on the competition page), d5-tribe (the Custom tribe and its name
  pages), d5-custom-cancel (Customize World's Cancel), d5-custom-help (its help request), d5-load-cancel (a cancelled
  Load), d5-fame-new (a new game after the Hall of Fame), in V0, V1, V2 and V5 only; not in ext-g1-baseline.txt (G-1's
  77 runs unchanged), not in `runs()` (ext_frames, ext_mirror, ext_zoom unchanged).  The scripts are core-form
  input, so d5-goback and d5-custom-cancel reach the core's Go Back and Cancel although no DOS row shows them
  (Windows-only since D5cR / D5eR).  Decision 8's assertion on V1 and V2: no count for a D4 or D5 row
  (`GATE_ROWS` 1..9, 16, 20, 21, 25, 27, 105, 116; `ROW_ALLOW` empty).
* `ext_adapt.py`: d-fame-key (X on the Hall of Fame <-> X), d-fame-click (a press <-> a click in dialog 148),
  d-load-cancel (l, Return; the harness's chooser cancelled), with D5cR's d-setup-nogoback, d-setup-bar,
  d-switch-custom and D5eR's d-custom-nocancel, d-custom-sync (the user rework records).

### The general rule in D5b's re-skin (`pdos_reskin.c/.h`; the user's direction of 2026-10-16)

"In DOS graphics never show a Go Back or Cancel row the DOS game doesn't have, on any screen; where DOS has a key
for it (e.g. Escape), that key does it, otherwise that choice is only in the Windows graphics."

* **The MenuZ box** (ShowTextDialog's dialogs 136 and 145, rows 14 and 22, and every later MenuZ re-skin): no row
  for the dialog's Go Back (id 102) or Cancel (id 2); D5b's extra last row (OPEN P17, draft B 11.2) is gone.
  Escape passes to the core's MenuZ (`I-menu/return-escape`: DOS's MenuZ gives -1, R:1D05:0200 -> 0392, and the
  core's MenuZ treats Escape as its dialog's cancel where it has one).  This key form is **provisional per screen**
  (the orchestrator's condition): when a D6 or D7 renderer shows such a dialog over a DOS screen it must check the
  listing; where DOS's own Escape on that screen does something else (e.g. asks again), Escape takes the DOS
  meaning there and the core's button becomes Windows-only (gate record, "Obligations").
* **The message box**: one row per button except IDCANCEL (2); the default highlighted, none when the default is
  the Cancel button.  Escape reaches the core's message box (its IDCANCEL), provisional per screen as above.
* Tests: `test_pdos_reskin.c` (67 checks): an OK / Cancel box draws the OK row only, a Cancel-default box no
  highlighted row, a Yes / No / Cancel box two rows; the MenuZ re-skin adds no Go Back or Cancel row.
* D5f adds no row the DOS screen lacks (the Hall of Fame's "Clear" is omitted, the Load has no row), so nothing
  needed the orchestrator's prior approval under the rule's last sentence.

## F2 / F5 per call site (BRIEF-d5.md)

* **Hall of Fame** (O3:00DF fill R:0000:0BFA, O3:00FB / 0112 text R:0182:00B3, O3:0129 line R:0182:000A, the entries'
  text, O3:04C6 G#3 recolour): F2 not applicable (no G#18).  F5 none: everything is drawn on the screen page, no
  page copy.
* **The Load's fill** (R:01A8:07D0..07E4): F2 not applicable, F5 none.

## OFFSETS.md rows (ruling 2)

FAME_TEXT DGROUP:33BE (strs 18; readers O3:0106, 01F3, 0388, 0444), FAME_RANKS DGROUP:33A2 (ptrs 5; O3:029F),
FAME_POP DGROUP:2FD2 (strs 3; R:1DC4:0367, 03BC); no writer found.  Regenerated: `present/dos/pdos_registry.h/.c`,
`tests/dos-decoded.txt` (1354 -> 1357 lines: three table rows; REGISTRY_OK; nodos OK).

## Tests

* `test_pdos_setup.c` (164 checks, was 126 at the D6b landing): D5f's Hall of Fame on a synthetic store (FAME_TEXT,
  FAME_RANKS, FAME_POP in the store; the three lines of a full entry: rank, leader, title, civilization, |year| and
  BC / AD, the population in R:1DC4:0337's form including 105 -> "1,050,000" and below 100, the score, the level,
  the rating with its 16-bit product; an empty entry " ---"; a difficulty outside 0..4: no title, no level; the cut
  after the civilization's name at x 320 with 16-character names; the screen in colour 15, the rule in colour 14,
  five entries, slot 0's and slot 5's highlight; ShowHallOfFame from the title: entries read, page 0 drawn, the
  pointer hidden, dialog 148 the view's window, forgotten at its destruction, the screen kept at the exit; at the end
  of a game the slot highlighted; entries unread: five empty rows, counted); decision 8's row counters (the five
  counters per row through `pdos_diag_note`); D5cR's and D5eR's vectors (their records).
* `test_pdos_seq.c` (190, was 179): ShowHallOfFame from the title (O3:00D7(-1), rows 7 and 25 ready, the pointer
  hidden, the title box again at its exit), at the end of a game (row 105, the slot, the pointer left as it is); a
  cancelled Load (no fill, the title box again, the pointer shown); a game loaded (SCENES 7.2's fill in colour 7, the
  pointer hidden, then the play's); `pdos_seq_movie_opening` inside the movie's GR_DialogOpen only.
* `test_input.c` (397 / 370 / 397, was 377 / 350 / 377): the four I-wait fame rows (`adapt_fame`: keys and a left
  press pass, the right button and a lone modifier consumed); D5cR's bar-move / bar-choose and D5eR's no-Cancel
  vectors; the row-count check 98.
* `test_pdos_reskin.c` (67 / 56 / 67, was 63 in Checked): the general rule (an OK / Cancel box draws OK only, a
  Cancel-default box no highlight, Yes / No / Cancel two rows; the MenuZ re-skin adds no Go Back or Cancel row).
* `tests/harness/ext_p0.py`: decision 7's six runs and decision 8's assertion (above).
* `tests/harness/ext_adapt.py`: d-fame-key, d-fame-click, d-load-cancel; D5cR's and D5eR's pairs (their records).
* `tests/harness/ext-timeline-golden.txt`: D5cR's bgolden frame 12000 (the T4 difficulty page without the grey
  Go Back row): d67d465f... -> dd778d0b...
* `tests/dos-decoded.txt`: the three new registry rows.

## Results (private, `build/d5f-stage/obj/`)

On the tree after the D6b landing and the docs-d6b pass (`obj/src-base` the tree's sources, `obj/src` with this
stage's; every output under `obj/`; -j 2):

* **Compilation**: the strict c11 + c17 /W4 /WX compile and the clang C99 parse of every changed and new source in
  Checked, CheckedNoObs and Release: CC_STRICT_OK (3); every portable source (290) with the tests, the harness (not
  Release) and civ64.exe: CC_ALL_OK in the three variants.
* **Unit tests** (test.cmd's unit loop over the private binaries, 46 programs): all pass in the three variants
  except test_dos, which reads the tree's `tests/dos-decoded.txt`: its output equals this stage's golden (23,227
  checks; "decoded content differs" only for the three new rows).
* **Generators and checks**: OBS_LINT_OK files 114 probes 203 callsites 98; REGISTRY_OK (dos-decoded 1357 lines);
  ADAPT_OK rows 98 steps 22; OBS_TABLES_OK probes 203 sites 98; pdos_scene_check PASS 1075 checks; NODOS_OK
  (182 files: this stage's and the private binaries of the three variants, 0 hits); MERGE_D6B_OK.
* **ext_adapt** (this stage's runner, `obj/adapt`): 29 DOS-form pairs, 87 checks, every DOS-form run equal to its
  Windows-form pair in `coreinput.log` and checkpoints (with D5f's d-fame-key coreinput 6, d-fame-click 7,
  d-load-cancel 4; D5cR's d-setup-nogoback 6, d-setup-bar, d-switch-custom 13; D5eR's d-custom-nocancel 4,
  d-custom-sync 28).  d-custom-sync's first run found a slip in the test, not the code: its group-1 Windows click
  chose the item Down had already selected, so no selection changed (`D_SYNC_WIN` now clicks item 1; rerun:
  all five checks PASS; custom_sel 6@28.001 (Down), 0@29.501 and 5@30.001 (the Windows clicks on groups 0 and 1, 1 ms after each), 4@32.001 (Up)).  Its `custom_sync` lines: DOS-form shows_dos 7 stale_dos 0 shows_windows 5 stale_windows 0;
  Windows-form shows_windows 8 stale 0.
* **ext_p0** (this stage's runner, -j 2, `obj/p0r`): Checked V0, V1, V2: P0_OK checks 225 (with decision 7's
  runs and decision 8's 66 row assertions); CheckedNoObs V5: P0_OK checks 62.  Decision 8: no count for a D4 or D5
  row in any V1 or V2 run (`ext-D5-acceptance.md` gives the rows that keep counts).  `ext_replay.py` (D6b's, read
  only) over these V1 runs: REPLAY_OK checks 70 (33 runs).
* **ext_timeline**: group bs EXT_TIMELINE_OK; group base with the tree's golden fails only `birth` 4 at frame
  12000 (D5cR), and with this stage's golden (the mirror `obj/p0m`): EXT_TIMELINE_OK, 41 PASS lines.  **ext_frames** EXT_FRAMES_OK;
  **ext_continue** EXT_CONTINUE_OK; **ext_bs** assets and mirror EXT_BS_OK.
* **Base against D5f** (`obj/hpriv.py`: both private builds, the 24 P0 scenarios and decision 7's six runs with
  `--graphics dos` and samples): the core traces equal in all 30; the 14 model golden frames equal except Birth's
  frame 12000 (D5cR, above).  The DOS samples differ where D5f, D5cR and D5eR draw: from the Load (7 samples, the
  fill until the play frame) in every run from a save, the setup pages (60 in `new`, `earth`, `settlers`, `s3`;
  326 in `birth`; d5-goback 100, d5-tribe 85), Customize (97 in `custom`; d5-custom-cancel 56, d5-custom-help 96),
  the Hall of Fame (60 in `fame-quit`, `fame-reload`; 37 at the end of a game in `retire`, `conquest`, `arrival`;
  d5-fame-new 136); `start`, `display16` and d5-load-cancel equal.  presentation-diag.log: `pdos.unexplained` falls
  to 0 in every run without play-screen drawing (the intro's 520 and the title branches' draws are the picture
  windows' owner's now), `pdos.w_over_n` 1..3 -> 0 in every run; new lines `pdos_rows` and `custom_sync`.

## Expected changes at the build slot

Against the D6b landing's outputs (`build/d6b-2-test-checked-r2.log`):

* `test.cmd checked`: test_pdos_setup 126 -> 164, test_pdos_seq 179 -> 190, test_input 377 -> 397, test_pdos_reskin
  63 -> 67, test_dos 23,224 -> 23,227 (with the landed golden); every other unit test unchanged.
* REGISTRY_OK (dos-decoded.txt 1354 -> 1357 lines; three tables more); ADAPT_OK rows 95 -> 98, steps 24 -> 22;
  OBS_LINT_OK files 112 -> 114; OBS_TABLES_OK (203 / 98) and pdos_scene_check (1075) unchanged; NODOS_OK (two files
  more); portable sources 289 -> 290.
* `ext_p0.py` Checked: P0_OK checks 304 -> 394 (decision 7's runs in V1 and V2: 24 lines; decision 8's row
  assertion in every V1 and V2 run: 66); CheckedNoObs: six more lines (decision 7's runs in V5).  `ext_g1.py
  check`: EXT_G1_OK runs 77 on both Checked variants (V0 unchanged).  presentation-diag.log of the DOS variations:
  `pdos.unexplained` lower (0 in most runs), `pdos.w_over_n` 0, the new `pdos_rows` and `custom_sync` lines;
  profiles.log equal.
* `ext_replay.py`: REPLAY_OK checks 58 -> 70 (two per V1 run: decision 7's six).
* `ext_adapt.py`: EXT_ADAPT_OK checks 86 -> 107 (D-form pairs 23 -> 29: d-setup-goback and d-custom-cancel
  replaced, eight new; 66 -> 87 checks; the D3 / M checks 20 unchanged).
* `ext_timeline.py`: EXT_TIMELINE_OK with the staged golden (bgolden 12000); its counts unchanged.
* `ext_frames.py` EXT_FRAMES_OK (the presented.log lengths of `birth` and `s3` may change: the setup pages' frames);
  `ext_continue`, `ext_bs`, `ext_mirror`, `ext_zoom` unchanged.
* The DOS frames: the setup pages without Go Back / Custom. rows, the Customize boxes without Cancel, the DOS Hall of
  Fame (rows 7, 105), the Load's fill (hpriv, above); the Windows profile's frames unchanged.
* coverage.log's informational "other functions entered" may vary (it varies run to run).

## Build-slot steps

1. Copy the staged files onto the tree (`BASE-SHA256.txt`: every base is the tree's file at the copy-in, after D6b
   and docs-d6b), with the record copies `ext-D5c-record.md`, `ext-D5e-record.md` (their "User rework" sections),
   this record and `ext-D5-acceptance.md`.  Then `gen/dos/registry.py gen` + `check` (no change expected),
   `gen/dos/adapters.py check`, `gen/obs_tables.py --check`, `gen/dos/nodos.py check`.
2. The D5 gate's eight-step cycle (`build/d5-gate-status.txt`): `build.cmd checked`, `test.cmd checked`,
   `ext_g1.py check`, `build.cmd checked noobs`, `test.cmd checked noobs`, `ext_g1.py check --variant
   CheckedNoObs`, `build.cmd`, `test.cmd` (no build.cmd / test.cmd change: BUILD-TEST-ADDITIONS.md).
3. Compare with "Expected changes"; the gate record's table and cycle; then the user build (the coordinator).

## Decisions and deviations

* **EARTH** (row 5): nothing new.  Play on EARTH goes through D4's title box and D4b3's Birth; what DOS shows of
  MAP.PIC's palette at Birth's start (O7:0049; `ext-D4b3-record.md` "Discrepancies" 5) stays as D4b3 left it, and
  the visible effect is OPEN O3's inference (not verified).  The DOS samples of `earth` change only where every
  Birth run's do (the setup pages, D5cR).
* **Quit** (row 8): nothing beyond D4's title box and D4c's Q hotkey; recorded.
* **The Hall of Fame's "Clear"** (O3:0174..01AA) is omitted (P18: the Windows program has none); no row is added.
* **The Load's host chooser** is class W (DOS-PROFILE 4 W3): drawn by the host outside the virtual screen; the DOS
  view keeps the title screen under it.
* **Decision 8's attribution** is by the scene row on top of the stack with the picture dialog's row 25 counted for
  the row beneath it (the opener); row 0 (an empty stack: after a Load, before the play scene's row) and the play
  rows (D6, D7) are not gate rows and keep their counts (the gate record's per-row table gives the reasons).
* **The fame's text with a difficulty outside 0..4** has no title or level (DOS indexes past its tables; counted as
  PDOS_DIAG_TABLE); the core never stores one.
* The rating's 16-bit product is the listing's (5 * 10000 wraps; O3:0468..0477), as DOS shows it.

## What the user checks (DOS graphics, after landing)

1. **View Hall of Fame** from the DOS title (V, Return): a white screen, "CIVILIZATION" / "HALL OF FAME" at the top,
   a yellow rule, then the entries (" ---" for an empty one; three lines each for a recorded game, the rating in
   red); no "Clear" buttons.  Any key or a left click returns: the title box over the Hall of Fame screen.
2. **Load a Saved Game**, then Cancel in the file chooser: the DOS title box again.  Load a game: the screen goes
   grey (colour 7) until the game's first frame.
3. **End of a game** (retire, conquest, space arrival): the Hall of Fame with the new entry in yellow.
4. **EARTH / Quit**: as before (D4, D5b).

## For the records

* FIDELITY: the Hall of Fame transcribed from O3:00D7 (OPEN L7 settled from the listing: the line layout above);
  "Clear" omitted (P18); the Load's fill (SCENES 7.2); EARTH's palette effect still inferred (OPEN O3).
* DESIGN 12.7 / 12.8 "As implemented (D5)": pdos_scn_fame; the picture windows' owner (template 148 while it is the
  view's window); decision 8's row attribution (`pdos_rows`, row 25 counted for its opener).
* DOS-PROFILE.md rows 4, 5, 7, 8, 105: as implemented (rows 7 and 105 `PDOS_RD_SCRIPT`, pdos_scn_fame; row 4's fill;
  rows 5 and 8 nothing new); 1.7.2 regenerated (98 rows).
* RUNNING / FEATURES: the DOS Hall of Fame; presentation-diag.log's `pdos_rows` and `custom_sync` lines.
* The manual checklist: the user checks above (new D5 items).

## Landing (build slot, 2026-10-16)

D5 stager, in the build slot granted by the orchestrator at 07:25 UTC, after the D6b landing (`build/d6b-status.txt`
ALL_GREEN 07:09:05 UTC) and the docs D6b pass (`build/docs-d6b-done.txt` 07:23:17 UTC).  D5f, D5cR and D5eR land
together in one cycle, which is also the D5 phase gate's (`ext-D5-acceptance.md` "The final cycle").

* **The merges onto D6b** were made in the stage before the copy (see the header): the five files both units change
  (`pdos_common.h`, `pdos_assets.c`, `pdos_profile.c`, `tests/headless/harness.c`, `gen/dos/registry.py`) three-way
  merged onto D6b's landed files (`obj/merge_d6b.py`: MERGE_D6B_OK; harness.c's and registry.py's one conflict each
  keep both sides) and DOS-PROFILE.md onto the docs pass's file (clean).  So every base in
  `build/d5f-stage/BASE-SHA256.txt` is the tree's file after D6b and the docs pass, and nothing was rebased at the
  slot.
* **Copy** (07:49:42 UTC, `build/d5f-prep/land.py --write`, after its dry run DRY_RUN_OK): the 37 files of
  BASE-SHA256.txt, each only while the tree's file still had its listed base SHA-256 and the staged copy its own (a
  new file had to be absent): 33 replaced, 4 new (`pdos_scn_fame.c/.h`, this record, `ext-D5-acceptance.md`);
  LANDED 37.  Before writing it took the snapshots the comparisons below use: the three variants' test outputs
  (`build/test/<variant>/*.txt` and `sections/*`, 144 files) into `build/d5f-prep/before/` and the 27 Checked V1
  presentation-diag.log files of ext_p0 into `before-diag/`; the tree's previous files are in `tree-before/`, the
  manifest is `build/d5f-prep/landed.sha256`.  build.cmd (40de571d...) and test.cmd (1f9610eb...) unchanged
  (BUILD-TEST-ADDITIONS.md: no change).
* **Generators and checks** before the cycle (07:49:49..07:49:57 UTC): `gen/dos/registry.py gen` (159 files, 38
  tables, unchanged: `pdos_registry.h/.c` and `tests/dos-decoded.txt` hash as before, `reg-before.txt`) and `check`
  REGISTRY_OK (`registry-check.txt`); `gen/dos/adapters.py check` ADAPT_OK rows 98 steps 22; `gen/obs_tables.py
  --check` OBS_TABLES_OK probes 203 sites 98.  `nodos.py check` and `pdos_scene_check.py` ran inside each test.cmd
  (NODOS_OK, PASS 1075 checks, in all three variants).
* **The cycle** (`build/d5f-prep/d5-gate-cycle.ps1`: each step waits on its own cmd.exe process only; status
  `build/d5-gate-status.txt`, logs `build/d5-gate-<n>-<step>[-r2].log`):

| Step | Command | Exit | Seconds | UTC | Last line |
| --- | --- | --- | --- | --- | --- |
| 1 | `build.cmd checked` | 0 | 190 | 07:50:31..07:53:41 | BUILD_OK variant=Checked (290 portable sources) |
| 2 | `test.cmd checked` | 0 | 1029 | 07:53:41..08:10:50 | TESTS_OK variant=Checked |
| 3 | `ext_g1.py check` | 0 | 0 | 08:10:50 | EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) |
| 4 | `build.cmd checked noobs` | 0 | 204 | 08:10:50..08:14:13 | BUILD_OK variant=CheckedNoObs (290 portable sources) |
| 5 | `test.cmd checked noobs` | 0 | 374 | 08:14:13..08:20:27 | TESTS_OK variant=CheckedNoObs |
| 6 | `ext_g1.py check --variant CheckedNoObs` | 0 | 0 | 08:20:27 | EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) |
| 7 | `build.cmd` (`-r2`) | 0 | 220 | 08:26:51..08:30:31 | BUILD_OK variant=Release (290 portable sources) |
| 8 | `test.cmd` (`-r2`) | 0 | 438 | 08:30:31..08:37:49 | TESTS_OK variant=Release |

ALL_GREEN at 08:37:49 UTC.

* **The restart at step 7.**  The session restart killed the cycle's driver at 08:22:33 UTC during step 7's first
  run (started 08:20:27 UTC; no status line; `build/d5-gate-7-build-release.log` holds only the environment
  script's "'vswhere.exe' is not recognized" notice, which heads every build log of this cycle, step 1's as well,
  and is not an error).  The orchestrator re-verified the 37 landed files against `landed.sha256` (unchanged) and
  resumed the driver at 08:26:28 UTC from step 7 (`-FirstStep 7 -RunSuffix '-r2'`; the status file's RESUMED
  line).  Steps 1..6 stand: no source or test input changed between them and the restart.  After the cycle
  (08:39:05 UTC) the 37 files still matched `landed.sha256` and build.cmd / test.cmd their hashes, so the three
  variants were built and tested from the same landed tree.  (This record, `ext-D5-acceptance.md` and the two
  rework sections were then completed by the landing agent; those four tree copies now differ from the manifest.)
* **Markers.**  Checked: REGISTRY_OK, NODOS_OK, GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK, P4_TESTS_OK, OBS_TABLES_OK
  probes 203 sites 98, OBS_LINT_OK files 114 probes 203 callsites 98, pdos_scene_check 1075, ADAPT_OK rows 98
  steps 22, P0_OK checks 394, EXT_FRAMES_OK, EXT_TIMELINE_OK (base and bs), EXT_CONTINUE_OK, EXT_BS_OK (assets,
  mirror), EXT_ADAPT_OK checks 107, MIRROR_OK runs 29, ZOOM_OK combinations 32 runs 64 samples 388, REPLAY_OK
  checks 70, TRACE_OK.  CheckedNoObs: the same without the Checked-only sections (ext_frames, ext_timeline,
  ext_adapt, ext_mirror, ext_zoom, ext_replay), P0_OK checks 62.  Release: REGISTRY_OK, NODOS_OK, OBS_TABLES_OK,
  OBS_LINT_OK files 114, pdos_scene_check 1075, ADAPT_OK rows 98 steps 22, TRACE_OK.  49 test programs in each
  variant (46 at the BS gate, + test_pdos_reskin, test_pdos_setup, test_pdos_replay), 0 failures; D5f's:
  test_pdos_setup 164 / 164 / 164, test_pdos_seq 190 / 190 / 190, test_input 397 / 370 / 397, test_pdos_reskin
  67 / 56 / 67, test_dos 23,227 in all three (Checked / CheckedNoObs / Release).
* **Checked against the D6b landing's outputs** (`build/d5f-prep/compare.py Checked` -> `compare-checked.txt`, 36
  of 55 files equal; `diag_cmp.py` -> `diag-cmp.txt`, the 27 V1 presentation-diag.log files), item by item against
  "Expected changes at the build slot":
  1. Unit tests: test_pdos_setup 126 -> 164, test_pdos_seq 179 -> 190, test_input 377 -> 397, test_pdos_reskin 63 ->
     67, test_dos 23,224 -> 23,227 (registry 35 -> 38 tables, decoded content 1354 -> 1357 lines); every other count
     unchanged; as predicted.  test_pdos_setup's printed geometry shows D5cR's rows: the difficulty box 7 -> 6
     lines (bottom 97 -> 89), the tribe box 15 -> 13 lines with five rivals and 17 -> 15 with six.
  2. REGISTRY_OK (dos-decoded.txt and registry-check.txt: FAME_TEXT, FAME_RANKS, FAME_POP and pdos_scn_fame's
     include rule), ADAPT_OK rows 95 -> 98 steps 24 -> 22, OBS_LINT_OK files 112 -> 114, OBS_TABLES_OK and
     pdos_scene_check unchanged, portable sources 289 -> 290: as predicted.  NODOS_OK, 0 hits, with 1701 -> 1705
     files scanned: four more, not the two predicted; nodos scans every file of claude/port outside build/, so this
     record and `ext-D5-acceptance.md` count as well as `pdos_scn_fame.c/.h`.
  3. ext_p0: P0_OK checks 304 -> 394 (24 lines of decision 7's runs in V1 and V2, 66 of decision 8's assertion),
     CheckedNoObs 56 -> 62, EXT_G1_OK runs 77 on both: as predicted.  presentation-diag.log: the new `pdos_rows`
     and `custom_sync` lines in all 27 runs; `pdos.w_over_n` 1 -> 0 in 22 runs and 2 -> 0 in custom, fame-quit and
     fame-reload; `pdos.unexplained` 0 in 12 runs (start 520, display16 529, orders, pollution, s2b, s2c and unload
     531, earth 533, custom 534, fame-quit and fame-reload 542, birth 670 -> 0) and 531 or 533 lower in the other
     15 (revolution 533 -> 2, spaceship 534 -> 3, retire 539 -> 6, load and s2 583 -> 52, settlers 602 -> 71, new
     and s3 607 -> 76, quiz 610 -> 79, research and research2 636 -> 105, menus 666 -> 135, arrival 760 -> 227,
     conquest 1581 -> 1048, city 2658 -> 2127); what remains is the decision-8 table's rows (`ext-D5-acceptance.md`),
     none a gate row.  Not predicted, explained: `replay.no_shadow` 7 lower and `replay.scripted` 7 higher in
     arrival (152 -> 145, 830 -> 837), conquest (267 -> 260) and retire (63 -> 56), the three runs that end in the
     Hall of Fame: row 105 is now `PDOS_RD_SCRIPT` (pdos_scn_fame), so D6b's replay counts those events as scripted
     instead of without a shadow; each run's sum is unchanged.  profiles.log was not compared file by file at the
     slot (no snapshot): every V1 and V2 run's switch assertions pass, and the stage found all equal.
  4. ext_replay: REPLAY_OK checks 58 -> 70 (33 V1 runs; the arrival, conquest and retire figures of item 3): as
     predicted.
  5. ext_adapt: EXT_ADAPT_OK checks 86 -> 107: d-setup-goback and d-custom-cancel replaced by d-setup-nogoback
     (coreinput 6) and d-custom-nocancel (4); new d-setup-bar (15), d-switch-custom (13; the DOS name box at 42.102
     s, the switch to DOS at 43.021 s), d-custom-sync (28; stale_dos 0 and stale_windows 0 in both runs, the
     Windows clicks shown 1 ms later), d-fame-key (6), d-fame-click (7), d-load-cancel (4): as predicted.  Not
     predicted, explained: D5d's pairs d-wait-key and d-wait-click coreinput 16 -> 17 and 17 -> 18, frames 603 -> 601,
     in both forms.  Their shared accept path `D_ACCEPT` now chooses the tribe page's bar row by
     `I-setup/bar-choose/core-ready` (D5cR): the core preselects Custom., which has no DOS row, so the adapter clicks
     the bar row's item before Return, one core input more; the Windows-form pair has the same click, and each pair
     stays equal.
  6. ext_timeline: EXT_TIMELINE_OK with the landed golden (bgolden frame 12000 dd778d0b..., was d67d465f...: D5cR),
     group bs unchanged.  Not predicted ("its counts unchanged"), explained: `custom` shows 188 -> 187 after the
     title choice.  The frame hashes of D5e's private run (`build/d5e-stage/obj/tlr`) and this cycle's differ from
     5.956 s on (the boxes without the Cancel row).  D5e's frame at 11.0011 s (custom_end: the fourth box redrawn
     without its Cancel row, a frame of its own) has the SHA-256 of this run's frame at 10.0011 s (the fourth box
     drawn, 211e301c...); at 11.0011 s nothing changes any more, so that show is gone (D5eR item 1: the redraw went
     with the row).
  7. ext_frames: EXT_FRAMES_OK; `s3`'s presented.log 689 -> 688 lines, 656 -> 655 tick shows (the setup pages'
     frames, D5cR); `birth`'s unchanged: as predicted.  EXT_CONTINUE_OK, EXT_BS_OK, MIRROR_OK runs 29, ZOOM_OK
     unchanged.
  8. coverage.txt's informational "other functions entered" 663 -> 662 (it varies run to run).
  Nothing else differs (times.txt and OBS_COST are host times).
* **CheckedNoObs and Release against the BS gate's outputs.**  The snapshot's CheckedNoObs and Release outputs are
  the BS gate's (`build/bs-status.txt`, 00:04:35 and 00:10:04 UTC): the landings since (UX1b with D5a..D5c, D5d,
  D6a, D5e, D6b) ran the three-step Checked cycle only.  These comparisons therefore span all of those units;
  every difference is a per-variant figure their records give (`compare.py CheckedNoObs` -> `compare-noobs.txt`, 34
  of 48 files equal; `compare.py Release` -> `compare-release.txt`, 33 of 43; `variants.py` -> `variants-out.txt`:
  the BS gate's three test.cmd logs against this cycle's, 52 of 70 counts and markers unchanged, every change in
  CheckedNoObs and Release the change Checked shows over the same span, apart from each variant's own counts):

| Item | Checked | CheckedNoObs | Release | Unit (its record's figure, Checked / CheckedNoObs / Release) |
| --- | --- | --- | --- | --- |
| test_present | 997 -> 925 | 997 -> 925 | 997 -> 925 | UX1b |
| test_input | 234 -> 397 | 207 -> 370 | 234 -> 397 | D5b..D5f (D5f: 397 / 370 / 397) |
| test_observer | 103 -> 108 | 1 (compiled out) | 92 -> 97 | D5b (108 / 1 / 97; its MessageBox test prints w16's activate lines and a beep) |
| test_pdos_reskin | new, 67 | new, 56 | new, 67 | D5b, D5f (67 / 56 / 67) |
| test_pdos_scene | 126 -> 136 | 127 -> 137 | 126 -> 136 | D5a (136 / 137 / 136) |
| test_pdos_seq | 125 -> 190 | 125 -> 190 | 125 -> 190 | D5a 170, D5d 172, D5e 179, D5f 190 |
| test_pdos_setup | new, 164 | new, 164 | new, 164 | D5c..D5f (with the printed geometry lines) |
| test_timeline | 148 -> 158 | 148 -> 158 | 148 -> 158 | D5d |
| test_map | 127 -> 146 | 1 | 127 -> 146 | D6a (146 / 1 / 146) |
| test_pdos_shadow | 135 -> 174 | 133 -> 172 | 135 -> 174 | D5a, D6a, D6b (174 / 172 / 174) |
| test_pdos_profile | 38 -> 40 | 36 | 38 -> 40 | D5c's two checks (D6b: 40 / 36 / 40) |
| test_pdos_replay | new, 84 | new, 84 | new, 84 | D6b (84 / 84 / 84) |
| test_dos; registry; dos-decoded.txt | 23,200 -> 23,227; 11 -> 38 tables; 1330 -> 1357 lines | the same | the same | 27 table rows: D5c 8, D5d 7, D5e 9, D5f 3 (registry-check.txt: their ok lines) |
| ADAPT_OK | rows 38 steps 12 -> rows 98 steps 22 | the same | the same | D5b..D5f |
| OBS_LINT_OK files | 97 -> 114 | 97 -> 114 | 97 -> 114 | each landing's new files: 101 (D5a..D5c), 105 (D5d), 106 (D6a), 108 (D5e), 112 (D6b), 114 (D5f) |
| NODOS_OK, files scanned | 1701 -> 1705 since D6b | 1671 -> 1705 | 1670 -> 1704 | 34 more: the new files of claude/port since BS and the three new test programs' binaries; 0 hits |
| P0_OK | 304 -> 394 | 56 -> 62 | (not run) | D5f (decision 7's runs; decision 8 in V1 and V2) |
| ext_replay section | new, REPLAY_OK 70 | new, empty | new, empty | D6b (Checked only) |
| coverage "other functions entered" | 663 -> 662 since D6b | 654 -> 655 | (none) | informational |

* **Decision 8 over the cycle's runs**: `build/d5f-prep/rowsum_gate.py` (the stage's `obj/rowsum.py` over
  `build/harness/Checked/p0`) -> `rowsum-gate.txt`, equal line for line to the stage's private table
  (`rowsum-stage.txt`): 33 V1 and 33 V2 runs with a `pdos_rows` line, no count on a gate row; the rows that keep
  counts are the table in `ext-D5-acceptance.md`.
* Not run in this landing: Asan (deferred), the DOS-oracle comparisons (optional, not run in D5), any UI check or
  DOS program.  "What the user checks" (above) applies to the landed tree's build; the user build is the
  coordinator's (`build/user-builds/d5`).

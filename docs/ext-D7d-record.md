# Extension phase D7, unit D7d (the DOS city screen) - record

Draft for the build slot (BRIEF-d7.md "Units" D7d, extension session E4, track B).  Staged in `build/d7d-stage/` on the
tree after D7a's and D7b's landing (copy-in at 08:07:35 UTC on 2026-10-17, ALL_GREEN at 08:45 and RELEASE_OK at 08:50
UTC, `build/d7ab-prep/`), then rebased onto the D7a/D7b docs pass (09:13 UTC), UX5b's landing (09:35 UTC), D7c's (10:57
UTC), DBL's (11:50 UTC), D7j's (12:54 UTC), D6fS-a's (13:36 UTC) and the D7j/D6fS-a docs pass (docs-e4c, 14:55 UTC):
every base in `obj/base/` is the tree's file after that docs pass, rechecked equal to the tree before this record
(`BASE-SHA256.txt`; section "Rebase notes").  Private
builds and runs in `build/d7d-stage/obj/` only: an overlay `obj/src` = the tree + the stage (`obj/mkoverlay.py`), built
with the tree's build.cmd and flags (`obj/b.cmd`, `--nogen`), cc.cmd's stricter checks per file (`obj/cc.cmd`), the unit
programs and the harness runs from the overlay's binaries with every output under `obj/`; the tree's build/gamedata,
dosdata and cache read only.

## Result

D7d is staged and READY_TO_BUILD.  With the DOS graphics, the interactive city screen (a city opened from the map, the
city screen after a founding) is the DOS city screen R:0D12:0045 on the N canvas, 320 x 200:
the title with the population, the 5x5 map with the worked squares' yield icons and the outlines of squares other cities
work, the resources panel (food, shields, trade with their deficits, the luxury, tax and science row), the citizens row,
the lower panel with its INFO, HAPPY, MAP and VIEW tabs (the present units, the happiness rows, the world map), the
supported units, the improvement list with MORE, the food and production boxes with BUY and CHANGE, EXIT and RENAME
(human cities), the CHANGE blink while the production must change.  It is drawn by a DOS-layout renderer from the core's
state (ruling 4's alternative, accepted with three conditions): read only, the core's totals shown, and the
transcription's totals checked against the core's at every render (every check run: 0 differences).  Keys and presses
are decided as R:0D12:4A4E..5CCF does (I-city): the DOS keys and tabs, the DOS cursors 'a', 's' and 'p', MORE, a sale by
the list, a map square, the citizens; EXIT, Escape and every key DOS does not handle leave the screen; no Go Back or
Cancel row.  The return names the DOS exit kind (the fade-in from black after VIEW, RENAME, the map cursor and the sale
of City Walls).  Privately: the three variants build, every unit program passes in each, the d7d pair passes 5 of 5,
ext_adapt (every case) EXT_ADAPT_OK, ext_p0 V0/V1/V2 on every run P0_OK (row 14's allowance removed), and every check
script passes.

## Status

READY_TO_BUILD.  Built: rows 97 (ProcessCity in mode 1: the session) and 25 (its dialog 148, bound to the city window)
made ready by the renderer while the city screen's level is the topmost non-R level; the shadow owner `city` (the city
window and the two port bitmaps at the logical resolution, every drawing absorbed, every copy into the window renders
the DOS screen again); the renderer `pdos_scn_city` with its self-check; the CHANGE blink and the DOS cursors' blinks
(TX); the exit kinds for the return (D7a's `pdos_fx`); the adapter rows I-city (`PDOS_AS_CITY` 0x08000000,
`PDOS_DEC_CITY`); seven DOS table rows (`docs/dos/OFFSETS.md`); the map module's hooks for the city's squares and units
(`pmap_dos.c`); the `city` diag line and timeline steps.  Not in the unit (until their units the city view and the
founding scene show the A frame, and the boxes over the city screen the A frame counted `w_over_n` on row 97): the city
view and the founding scene (D7e), the production list, the rename and the sale and Buy questions (D7f, D7g).

## What was built

### Why a renderer and not the logical replay (ruling 4's alternative; deviation 1)

The core composes its city screen in two ports, `g_cityScreenPort` (1260:0070) and `g_cityOverlayPort` (1260:0032),
mostly with DrawTileToPortPixels 11A8:15CE, which writes the bitmap's bits directly: no probe, no GDI event.  The
logical replay sees almost none of the screen.  The renderer draws R:0D12:0045's layout (DOS listing) from the core's
state read through `w16q_read` (the cities, the human's units, the unit and improvement types, the civilisations'
advances, wonders and governments, the city's scratch totals 1260:00AE..00E3, the panel mode, the list's scroll) and the
map module's hooks (terrain, improvements, specials, the body, units, visibility, the square and unit drawers at k = 1).
The coordinator's conditions:

1. **Read only.**  No core call, no core random number, no emulation write (`w16q_read` only; obs_lint clean).
2. **Self-check.**  At every render of the session's city the transcription's totals are compared with the core's:
   food (the worked squares' yields, R:0D12:692D / 6ABC = the core's GetSquareYield) against g_cityYields, shields
   with the factory and power-plant bonuses (R:0D12:1357..14D0) against g_cityShieldTotal, trade with the routes
   (R:0D12:283B..28D6) against g_cityTrade, happy and unhappy after every HAPPY stage (R:0D12:2AF2..32DD, the core's
   1030:3694..3F4D) against g_cityHappyCount and g_cityUnhappyCount.  A difference is counted (`mismatch_*`); the
   counters must be 0 in every run that shows the city screen (`test_pdos_city`, ext_adapt's d7d pair; and they are 0
   in every ext_p0 run).
3. **The core's totals win.**  Every total the screen shows (the resources rows, the deficits, the luxury, tax and
   science row, the citizens, the boxes, the pollution) is the core's value; the transcription only places the
   per-square icons and the intermediate HAPPY rows.

### The session

* **Start** (DOS listing R:0D12:0045; the core's ProcessCity 1030:0000): ProcessCity's entry with mode 1.  The
  dialog-148 window created before GR_DialogOpen's exit at ra 1030:00F8 is the city window; the bitmaps of the two
  GR_PortOpen calls (1030:019B, 1030:01C3; +1Ah at their exits, or named at their creation inside the call) are the
  ports.  The N machine keeps the play palette (R:0D12:0045 changes no DAC entry) and page 0 is filled black
  (R:0D12:04A2..04BA).  Rows 97 and 25 are made ready, their earlier readiness saved.
* **Renders**: every copy into the city window with SRCCOPY (CopyPortToWindow 10D0:0854: the core's screen complete)
  renders the whole DOS screen again from the live state (R:0D12:045F's full redisplay).  A nested ProcessCity(city,
  -1) (a recomputation) keeps the session.
* **Dynamic readiness** (`pdos_city_sync` after every event and probe): rows 97 and 25 are ready only while the
  topmost non-R level of the scene stack is the session's.  A scene the core opens over it (the city view's dialog 148,
  rows 88 and 25) shows its own frame; a box over it leaves it shown (the W window over N shows the A frame until the
  box's unit).
* **End**: the window's destruction or ProcessCity's exit: the rows restored, the exit kind named for D7a's return
  trigger (`pdos_fx_exit_set`): R:0238:1B44 when DOS writes [6B64] = 1 (R:0D12:4FE3 VIEW, R:0D12:56BF RENAME,
  R:0D12:54A1 the map cursor 'p', R:0D12:589B the sale of the City Walls: building bit 7 seen lost between two
  renders), else none (R:0ADE:040B..0419 restores the saved screen); the step `city_end` logged.

### The layout (DOS listing R:0D12:0483..4851)

The header and the 5x5 map (0483..0700: the title, the city's name upper-cased with its population sum R:1DC4:0337,
the squares by R:1AEA:03BA / 11D4, unseen squares skipped for the human, the colour-12 outlines of the squares the
other cities within distance 5 work, R:0D12:014F..02F7 with R:1DC4:0289); the yield icons (692D: the step by the total
R:0D12:692D, icon 0Dh for a zero); the tabs and lower panel (2687..277B); the HAPPY rows (2AF2..32DD with R:0D12:6ED4's
citizens, the building icons R:0D12:7045, the martial-law units, WONDERS); the MAP tab's world map (R:0D12:72B7, 2 x 2
dots R:0D12:73EA); the supported and present units (32E0..39E7, R:1AEA:0FB3); the improvement list and MORE
(3A86..3D01, R:0D12:70CB); the production box (3D09..3F5D: K = clamp((cost - 1) / 10 + 1, (stored - 1) / 100 + 1,
99)); the food box (3F60..40AF); the resources panel and the luxury, tax and science row (40B7..4596); the citizens
row, routes, the city's dot and pollution (45A0..4851); the buttons and the must-change flag (4852..498E).  The DOS
strings come from seven new table rows read from the user's CIV.EXE at run time (`docs/dos/OFFSETS.md`: CITY_POP,
CITY_TABS, CITY_PANEL, CITY_MAP_DX/DY, CITY_NONE R:1459:08CF, IMPR_RECORDS R:0D12:3B01 and 3C0A; DOS listing).

### The CHANGE blink and the DOS cursors (TX, C.9)

While the production must change (R:0D12:489E..498E), CHANGE's face is recoloured 9 -> 14 for 10 frames and back for 10
(R:0D12:49EF / 4A16, R:0182:0134(10); DOS listing), on its own grid from the render that found the condition (M1;
deviation 2).  The cursors 'a' (the present units, R:0D12:4FFF..), 's' (the improvement list, 522A..) and 'p' (the map
square, 53D2..) blink the same way and hide the pointer (R:0D12:5000, 522B, 53D3); they are the DOS screen's own (no
core state changes until their Return or Space).

### Input (I-city; C.12.7, C.14.2 class W; DOS listing R:0D12:4A4E..5CCF)

* **Keys** (`pdos_city_key`): 'A' Auto Production (the core's 'a'), b c i h m v r and '1'..'9' their actions, 'a' 's'
  'p' the cursors (arrows, Return, Space, Esc), 'M' the next list page; any other key leaves (R:0D12:56C8); a foreign
  city leaves on any key (R:0D12:5CBD).  The core gets the action's **character message alone** (WM_CHAR): the core's
  ProcessKeyboardMessage 1098:02D1 queues it for ProcessCity's key loop, while a key down would meet ACCELERATORS 128
  first (H, D, J, K, N and P without a modifier are commands), so H would never reach the city screen (found by the
  d7d pair; deviation 7).
* **Presses** (`pdos_city_press`, [DB3A]): the right button on CHANGE is Auto, elsewhere it leaves; the left one on
  BUY, CHANGE, a tab, RENAME, MORE, a building (its sale through the core's list, refused while the core's list is
  scrolled; deviation 4), the citizens (the core's message below size 5), a present unit, a map square (a square
  outside the radius or unseen: DOS only redisplays, the core's '#', deviation 3); elsewhere it leaves (R:0D12:5CBA).
  A click is a complete click at the class-W point of the core's logical point in the city window
  (CityScreenWndProc 1030:9C17 stores (d * 10) >> 4).
* **Leaving**: Escape's complete pair; but a key DOS leaves on that the core's loop leaves on too (its character
  lowered, 1030:58D4: Escape, Return, e, q; 1030:6847..685D) is passed itself with its own release, as the Windows
  profile gives it (deviation 8: S3's Return on the city screen reaches the core unchanged in every DOS-form run).
* Modifiers alone and characters alone are consumed; a key's repeats are decided again while a DOS cursor runs (the
  BIOS typematic).  DOS shows no Go Back or Cancel there (the user's DOS rule); EXIT is DOS's own button.

## Files

New: `present/dos/pdos_scn_city.c/.h`, `tests/test_pdos_city.c`, this record.  Changed (`BASE-SHA256.txt`):
`present/dos/pdos_profile.c` (reset, events, probes, sync, advance, the cursor rule), `pdos_seq.c` (the timeline.log
sink), `pdos_replay.c` (muted on the owner's shadows: the `city` counter), `pdos_adapt.c/.h`, `pdos_adapt_tab.c`
(I-city), `pdos_registry.c/.h` (generated: the seven table ids), `present/map/pmap_dos.c` (the map hooks),
`gen/dos/adapters.py` (the scene and decision), `gen/dos/registry.py` (`pdos_scn_city.c` in `OBSERVER_FILES`),
`docs/dos/OFFSETS.md` (seven rows), `docs/DOS-PROFILE.md` (rows 14 and 97, 1.7.2 generated), `tests/dos-decoded.txt`
(the goldens of the seven tables), `tests/test_input.c` (the I-city vectors), `tests/headless/harness.c` (the `city`
diag line), `tests/harness/ext_adapt.py` (the d7d pair; the d7a, d7b and d7c return counts), `tests/harness/ext_p0.py`
(ROW_ALLOW emptied), `tests/harness/ext-zoom-golden.txt` (the ten reviewed `dos new ... 55000` lines). `pdos_shadow.h`
is no longer staged: D7j's landing set `PDOS_OWNER_MAX` to 8, the combined value for its owner `palace` and D7d's
`city`.  build.cmd and test.cmd unchanged (`test_pdos_city.c` is picked up by the `tests\test_*.c` rule; no
BUILD-TEST-ADDITIONS.md).  Every `extension D7d` block is delimited where it adds more than a line; one-line hunks carry
an `extension D7d` comment.

## Tests

* **`tests/test_pdos_city.c` (new, 78 checks in every variant):** the pure parts (the production box's K, the yield
  icons' spacing, the citizens' pitch, the core's logical points of the 5x5 map, the units' cells and the list rows
  against the core's own formulas); a session from a synthetic stream through the scene engine, the shadow engine and
  the module in the profile's order (ProcessCity(city, 1), the window and the two port bitmaps named at their creation
  inside GR_PortOpen, every drawing absorbed, row 14's case of the window's fill under dialog 136, the copy into the
  window rendering the header, the 5x5 map at R:1AEA:03BA's places with an unseen square skipped and the colour-12
  outlines, the panel texture, EXIT's colours; the replay muted on the owner's shadows); condition 2 (the counters 0
  when the core's totals equal the transcription's, a counted mismatch when one differs); the CHANGE blink (9 -> 14 at
  once, back 10 frames later); the readiness (ShowCityView's row 88 over it hides it, its pop renders again; a nested
  ProcessCity(city, -1) keeps it); input (the keys, 'A' as 'a', Escape for the others, the keypad digits; the presses:
  tabs, BUY, CHANGE with either button, RENAME, the citizens' message, a map square or '#', a sale as the core's list
  click and its refusal while the list is scrolled; the cursors 's' and 'p' with their Return and Escape; the pointer
  hidden in a cursor; a foreign city); the end (rows back, the exit kind none and R:0238:1B44 after the city view, the
  steps, the diag line).  The emulated memory is a table of the test's own; no emulation, no DOS byte (synthetic texts).
* **`tests/test_input.c`** (522 -> 552 in Checked): the I-city vectors on a synthetic city hook (class-W window): a
  key as its character message alone (a letter, a digit, '#'), Escape's pair for an unhandled key, Return, Escape and
  Q passed with their releases, a click at the class-W point, the right button's exit, a click without the window
  consumed, a DOS cursor's nothing with its repeats decided again, Shift alone and a character alone consumed; the
  table's decision bound and class-W rule; the row count 123 -> 127.
* **`tests/test_dos.c`** (unchanged; 23239 -> 23246 checks): the store's decoded tables against `tests/dos-decoded.txt`,
  which `gen/dos/registry.py goldens` regenerated with the seven new tables (7 lines).
* **`tests/harness/ext_adapt.py`, the d7d pair** (2 runs, 5 checks): S3's lines to 56,500 ms with the DOS profile from
  40,000 ms; on Rome's city screen (52,183 .. 55,002 ms) a press on a corner square (the core's '#'), h, a press on the
  map square east of the city (the class-W click), a press on the INFO tab (i), S3's Return (passed with its own
  release); the rows decided (I-city/press, key, press, press, key), one produced click, Return's release at its own
  time; the DOS-form run equals its Windows-form pair (coreinput, frames, state, events, exit); timeline.log's `city`
  (R:0D12:0045) before the first action and `city_end` (R:0D12:5CC2) after S3's Return; 320 x 200 N shows while the
  screen is open; the `city` diag line (one session and end, keys 2, presses 3, renders >= 5 each checked, every
  mismatch, no_state, stale and refused 0).  It fails on the base (no I-city rows, no `city` line).  The d7a and d7b
  blocks (S3 runs that pass Rome's city screen in the DOS profile) count the return steps from the report's start and
  `return_none` as 1 + the `city` line's ends (two one-line hunks each, `extension D7d`).
* **`tests/harness/ext_p0.py`:** ROW_ALLOW's (14, unexplained) entry for the run `city` removed (the gate's decision-8
  rows must be 0 there now).

## Results (private, `build/d7d-stage/obj/`)

* **Builds:** Checked, CheckedNoObs and Release BUILD_OK (build.cmd's own flags on the overlay; portable sources 298,
  the tree's 297 + `pdos_scn_city.c`).
* **cc.cmd** (c11 and c17 at /W4 /WX, the clang C99 parse) in Checked, CheckedNoObs and Release: CC_OK for
  `pdos_scn_city.c`, `pdos_adapt.c`, `pdos_adapt_tab.c`, `pdos_profile.c`, `pdos_seq.c`, `pdos_replay.c`,
  `pdos_registry.c`, `pmap_dos.c`, `harness.c` and `test_pdos_city.c`.
* **Unit programs** (`obj/unit.py`, the overlay's binaries, 56 programs per variant): every program passes in each
  variant (test_dos against the staged goldens, below).  Checked against the tree's last cycle then
  (`build/d7ab-2-test-checked.log`): test_input 522 -> 552, test_dos 23239 -> 23246, test_pdos_city new 78, every
  other count equal.  CheckedNoObs: test_pdos_city 78, test_input 496,
  test_dos 23246.  Release: test_pdos_city 78, test_input 552, test_dos 23246.  test_dos reads its goldens beside the
  data folder it is given, so in the overlay it ran against the staged `tests/dos-decoded.txt` through `obj/fk/`
  (junctions to the tree's build/gamedata and build/dosdata, read only: "nothing written: 176 DOS files with equal
  size, SHA-256 and modification time"), PASS 23246 checks in each variant; the C store's decoded content equals the
  staged goldens line for line.  (Run with the tree's goldens, as unit.py does, it reports the one expected failure.)
* **Checks** (on the overlay): `registry.py check --dosdata <tree>\build\dosdata --disasm <tree>\build\dos\disasm`
  REGISTRY_OK 0 failures; `obs_lint.py` OBS_LINT_OK files 128 probes 203 callsites 101; `obs_tables.py --check`
  (`obj/obstab.py`, the tree's listing claude/src/asm read only) OBS_TABLES_OK probes 203 sites 101;
  `pdos_scene_check.py` PASS 1084 checks, 141 scene rows, 10 font rows; `adapters.py check` ADAPT_OK rows 127 steps 25
  (`adapters.py gen` leaves the staged DOS-PROFILE.md unchanged); `nodos.py check --variant Checked` NODOS_OK, 0 hits.
* **ext_adapt** (`obj/runadapt.py all`: the staged runner, the overlay harness, every run under `obj/adaptroot`):
  EXT_ADAPT_OK checks 203 (the d7d pair 5 of 5).  The first full run had found the d7a and d7b return checks counting
  the city screen's own return (S3's city screen, now an N scene, ends with the return kind none at 55,002 ms; 3
  failures, 200 passing); their blocks now count the report's return after the report's start and `return_none` as
  1 + the city's ends, and the second full run passed every check.
* **ext_p0** (the tree's runner with `--exe` and `--root` under `obj/`): V0, V1, V2 on every run P0_OK checks 225 (the
  three variations of the 7.3 runner's runs); the `city` run's `pdos_rows` without r14 (and r15, r17); every `city`
  diag line of every run with a session (city, new, s3, settlers) has every mismatch 0.
* **ext_replay** on those outputs: REPLAY_OK checks 70.  **ext_fce**: EXT_FCE_OK runs 8.
* **ext_zoom** `--only new` (every profile mode, the overlay harness): every check passes but the ten golden lines
  `dos new ... 55000` (section "Expected changes"; the layer samples of win b, dos a and sw equal).

## Deviations from the brief

1. **A DOS-layout renderer instead of the logical replay** (ruling 4's adopted proposal): the core's city screen is
   drawn with DrawTileToPortPixels 11A8:15CE (raw bits, no probe, no GDI event), so the replay cannot see it.  Ruling
   4's alternative, accepted by the E4 orchestrator with the three conditions above.
2. **The CHANGE blink's grid** starts at the render that found the must-change condition and runs on across later
   renders; DOS restarts its 10-frame count at each redisplay (inferred from R:0D12:49EF's loop: the redisplay
   re-enters it).  The phase may differ by up to 10 frames after a redisplay.
3. **'#' for DOS's redisplay-only presses**: a press on a map square outside the radius or unseen makes DOS redisplay
   (R:0D12:5AA6 FULL); the core gets '#' (1030:5F88: its full recompute), which changes no state.  The same for the
   map cursor's Escape (R:0D12:5636).
4. **A sale while the core's list is scrolled is refused** (counted `refused`): the Windows list's row of a building is
   known only at the list's top; DOS's list has no scroll.  The user's scroll is Windows-only.
5. **The DOS cursors are the renderer's** (presentation state; their Return or Space gives the core the click of the
   unit, the list row or the map square).
6. **R:0D12:6ED4's [bp-2]** is never written by the routine; it is taken as non-zero at every call (inferred: the
   citizens' gap after the content ones is drawn).
7. **Keys as character messages** (WM_CHAR without a key down): see "Input".  The Windows player cannot type H in
   the city screen (the accelerator takes it; the City menu's Happy is the Windows way); the DOS key H shows HAPPY.
8. **Escape, Return, e and q passed as typed** where both screens leave; every other leaving key becomes Escape.
9. **Boxes and scenes over the city screen** (the production list 140, the rename 137, the Buy and sale questions, the
   city view) show the A frame (`w_over_n` on row 97) until D7e, D7f and D7g.
10. **`tests/dos-decoded.txt`**: the registry's goldens gain the seven tables' lines (test_dos compares the store's
    decoded tables with them).

## What the user checks

On the user build (D7d landed; `civ64.exe`, DOS files present), in play with at least one city of your own, with the
DOS graphics (Ctrl+Shift+Backspace or the host menu):

* **D7d-1** Open one of your cities (click it on the map): the whole window shows a
  320 x 200 DOS city screen (4:3 or square as the "4:3 aspect ratio for 320 x 200 screens" option says): the city's
  name in capitals with its population at the top, the 5x5 map in the middle with the worked squares' food, shield and
  trade icons, the resources panel at the left, the citizens across the top, the lower panel with INFO, HAPPY, MAP and
  VIEW, the improvement list at the right, the food box and the production box with BUY and CHANGE, EXIT and RENAME at
  the bottom.  No Go Back or Cancel row anywhere.
* **D7d-2** I, H and M (or a click on the tab) switch the lower panel: the units in the city, the happiness rows, the
  world map.  V or the VIEW tab shows the city view (still the Windows-style picture until D7e) and back.
* **D7d-3** A click on a map square of the city's radius takes a worker off it or puts one on it, as the Windows city
  screen does (the icons and the totals follow); a click on a corner square changes nothing.  In a city of size 5 or
  more, a click on a specialist at the right end of the citizens row (or 1..9) changes its kind; below size 5 a click
  on the citizens gives the game's message.
* **D7d-4** A, S and P start DOS's own cursors (a blinking frame on a present unit, on an improvement, on a map square;
  the pointer hidden): the arrows move it, Return or Space acts (wakes the unit, offers the sale, moves the worker),
  Escape leaves it.
* **D7d-5** When the production must change (a building already built), CHANGE blinks.  C or CHANGE opens the
  production list, B or BUY the Buy question (both still in the Windows style until D7f/D7g); the boxes update after.
* **D7d-6** Escape, Return, a click on EXIT or any key DOS does not use closes the screen; the map returns at once, or
  with a short fade-in from black after VIEW, RENAME or the P cursor.
* **D7d-7** The same with the Windows graphics: the Windows city screen, unchanged.

Not part of this check: the city view and the founding picture (D7e), the production list, the rename and the
questions in the DOS style (D7f, D7g), switching the graphics while the city screen shows.

## For the records

* **DESIGN 12.x "As implemented (D7d; area B and C)":** the DOS city renderer (`pdos_scn_city`; ruling 4's
  alternative with its three conditions); the shadow owner `city` (window and ports at the logical resolution, every
  drawing absorbed, the copy into the window renders); rows 97 and 25's dynamic readiness; the exit kinds named from
  DOS's [6B64] writes; I-city (the DOS decisions, the character messages, the class-W clicks, the keys both screens
  leave on); the `city` diag line.
* **FIDELITY** (new entries, numbers to be assigned): F-new-1 the city screen is a transcription of R:0D12:0483..4851
  from the core's state, its totals the core's, its per-square icons and HAPPY rows the transcription's (checked against
  the core's totals at every render); F-new-2 the CHANGE blink's grid runs from the render that found the condition
  (deviation 2); F-new-3 a redisplay-only press gives the core '#' (deviation 3); F-new-4 a sale is refused while the
  Windows list is scrolled (deviation 4); F-new-5 R:0D12:6ED4's unwritten [bp-2] taken as non-zero (inferred); F-new-6
  keys reach the core as character messages, so the Windows accelerators do not take H, D, J, K, N or P in the DOS
  city screen (deviation 7); F-new-7 the boxes and scenes over the city screen keep the A frame until D7e..D7g.
* **DOS-PROFILE.md prose** (as staged): row 97 "extension D7d" (the renderer, the readiness, the check), row 14's
  allowance removed; the generated section 1.7.2 with I-city's four rows; the decision-8 gate unchanged (row 97 is not a
  gate row; its `unexplained` counts drop from 2116 to 331 in ext_p0's `city` run: the owner explains the city window's
  and ports' events).
* **RUNNING.md:** presentation-diag.log's `city` line (sessions, ends, renders, draws, copies, blinks, checks,
  mismatch_food, mismatch_shields, mismatch_trade, mismatch_happy, mismatch_unhappy, no_state, stale, keys, presses,
  views, refused); the replay line's `city` counter (draws muted on the owner's shadows); timeline.log's steps `city`
  (R:0D12:0045), `city_draw` (R:0D12:0483, the renders so far), `city_end` (R:0D12:5CC2, the exit kind), sequence 1;
  ext_adapt's d7d-city-dos and d7d-city-win runs; test_pdos_city.
* **FEATURES.md:** the DOS city screen in play (D7d), with the runners above.
* **STATUS.md:** D7d landed (rows 97 and 25 for the city screen; `PDOS_AS_CITY` 0x08000000; owner `city`, the shadow
  owners 7 of `PDOS_OWNER_MAX` 8 with D7j's `palace`; row 14's allowance gone).
* **manual-checklist-ext.md:** new items D7d-1..D7d-7 (above).
* User direction (no added Go Back / Cancel rows; DOS keys do it): the city screen shows none; EXIT and Escape leave.
* Not edited by this unit: DESIGN.md, FIDELITY.md, STATUS.md, RUNNING.md, FEATURES.md, DOS-PROFILE.md outside rows
  14, 97 and the generated 1.7.2, manual-checklist-ext.md, the D1 drafts and the D0 documents.

## Expected changes at the build slot

* **Unit** (Checked; the tree after D6fS-a, `build/d6fsa-2-test-checked.log`): test_input 529 -> 559, test_dos
  23243 -> 23250 (the seven tables' goldens), a new program test_pdos_city (78); every other count unchanged
  (CheckedNoObs and Release: test_input + 30 likewise, test_pdos_city 78).  Portable sources 300 -> 301; obs_lint files
  132 -> 134, probes 203 and call sites 101 unchanged; `obs-tables.txt` unchanged.
* `registry-check.txt`: REGISTRY_OK, 0 failures (the include-rule lines of `pdos_scn_city.c/.h` and the seven table
  rows added).  `pdos-scene-check.txt`: unchanged (PASS 1084 checks, 141 scene rows, 10 font rows).
  `adapters-check.txt`: ADAPT_OK rows 130 -> 134 steps 25.  `nodos.txt`: NODOS_OK, 0 hits (byte counts grow).
* `ext-adapt.txt`: EXT_ADAPT_OK checks 237 -> 242 (the five d7d lines; two more runs, d7d-city-dos and d7d-city-win,
  56.5 s of virtual time each); the d7a, d7b and d7c diag lines read `return_none 2` (the city screen's return, then
  the report's); every other line equal (S3's Return on Rome's city screen reaches the core unchanged in the DOS-form
  runs: passed).
* `ext-p0.txt`: P0_OK with unchanged counts (476).  The `city` run's `pdos_rows` no longer holds r14.unexplained (row
  14's allowance removed), r15 and r17's single counts are gone, r97.unexplained drops (2116 -> 331) and r97.w_over_n
  5 appears (the boxes over the city screen; row 97 is not a gate row); the `new`, `s3` and `settlers` runs show one
  city session each (their `city` lines, every mismatch 0).
* `ext-replay.txt`: REPLAY_OK; its informational V1 counter lines change in `city`, `new`, `s3` and `settlers` (the
  new `city` counter: drawings on the owner's shadows not replayed; `no_shadow` lower).
* `ext-zoom.txt`: ZOOM_OK against the staged golden file `tests/harness/ext-zoom-golden.txt` (base: the tree's, DBL's
  40 `dos` lines included), in which exactly ten lines change, reviewed one by one: `dos new <size> <policy> <level>
  55000` for 640x480 integer, 1280x960 integer, 1920x1440 integer, 2560x1600 fit-sharp and 1366x768 fit-nearest,
  each at levels -1 and +1 (`obj/zoomgold.py`: the private run's samples by ext_zoom.py's own `zoom_shows` and
  `samples`, compared with every `dos new` line: 70 samples, 10 changed, none missing or new; the other 60, the
  40,000..50,000 and 60,000..70,000 ms samples, are equal).  Why each changes, the same reason for all ten: S3's city
  screen (52,183 .. 55,002 ms) is now the 320x200 N frame, whose shows carry no zoom fields; a sample is the last
  zoomed show at or before its time, so the 55,000 ms sample is now the map's last zoomed show before the city screen
  (52,180 ms; for 640x480 -1 `fff8a56a...`) instead of the A frame's show of the Windows city window at 52,197 ms
  (the base run of D6fS-a's cycle: `fa5adaf0...`, the tree's line).  The first zoomed show after the screen is at
  55,002 ms, so 60,000 ms and later are unchanged.  Presentation hashes, never core fixtures.  Every other zoom check
  as before (the private run of `new`; "shows dos 289").
* `ext-fce.txt`: EXT_FCE_OK runs 8 unchanged (the production list and the name over the DOS city screen show the A
  frame; their Escape as before).
* presentation-diag.log (harness): a new `city ...` line after `report`'s; the replay line gains `city N`.
  timeline.log: `city`, `city_draw`, `city_end` (sequence 1) in runs that open a city screen; ext_timeline's runs (the
  intro, Birth) have none: no golden changes.
* Core outputs, G-1 fields and `ext_g1.py check`: unchanged (presentation only; the d7d pair and ext_p0 V1/V2 equal
  their references).

## Rebase notes

* **Bases:** the tree after D7a's and D7b's landing (copy-in 08:07:35 UTC); the E3 drafts had been staged on D7a's
  stage and were rebased onto the landed files (D7b's `pdos_replay.c`, `pdos_adapt.c/.h`, `pdos_adapt_tab.c`,
  `adapters.py`, `test_input.c`, `harness.c`, `ext_adapt.py` and DOS-PROFILE.md as the bases); `obj/mkoverlay.py`
  no longer layers the D7a stage.  Every base equal to the tree in `BASE-SHA256.txt` at the record's time.
* **Rebased since** (three-way, `git merge-file`; the inputs, results and resolution scripts in `obj/rebase-ux5b/`,
  `obj/rebase-d7c/`, `obj/rebase-dbl/`, `obj/rebase-d7j/` and `obj/rebase-d6fsa/`, the earlier bases in
  `obj/base-pre-*/`):
  * the D7a/D7b docs pass (09:13 UTC) changed `docs/DOS-PROFILE.md`: one conflict only, D7d's row 97 beside the pass's
    new row 98 text; resolved as D7d's row 97 and the pass's row 98;
  * UX5b's landing (09:35 UTC) changed `present/dos/pdos_seq.c`: merged cleanly;
  * D7c's landing (10:57 UTC) changed `pdos_adapt.c` and `pdos_profile.c` (`pdos_report_active`): merged cleanly, the
    report's test still before the city's in `pdos_adapt.c`; `tests/harness/ext_adapt.py`: three conflicts where both
    units appended (the docstring paragraph, the block, the call in `main`), resolved D7c's first, then D7d's; D7c's
    block gains D7d's two hunks (its `return` steps counted from the map's `report` step on, its `report` diag line's
    `return_none` = 1 + the city screen's ends), as D7a's and D7b's had;
  * DBL's landing (11:50 UTC) changed `pdos_profile.c` (`pdos_aplay_advance`) and `pmap_dos.c` (the blink block): one
    adjacent-line conflict in each place both appended, resolved DBL's first (the forward declarations `blink_reset`
    and `city_hooks`; DBL's blink block, then D7d's map hooks block).  DBL's unit blink and D7d's CHANGE and cursor
    blinks are independent (each on its own 10-frame grid);
  * D7j's landing (12:54 UTC) changed 16 of the staged files' bases: 30 conflicts, every one two units appending at
    the same place, resolved D7j's first, then D7d's (`obj/rebase-d7j/resolve.py`), with these specifics: the
    `pdos_adapt.c` scene test and `test_input.c`'s scene set-up each needed the closing lines of D7j's block before
    D7d's; `PDOS_AS_CITY` stays before `PDOS_AS_PALACE` (value order); the cursor rule reads `... ||
    pdos_palace_pointer_hidden() || pdos_city_pointer_hidden()`; adapters.py's SCENES list ends with D7d's row,
    its docstring and 1.7.2 paragraph name both units; `test_input.c`'s row count 130 + 4 = 134; DOS-PROFILE.md row 97
    D7d's, row 98 the tree's (D7c's text).  `pdos_shadow.h` is no longer staged (D7j set `PDOS_OWNER_MAX` 8, the
    combined value).  Regenerated on the overlay, not merged: `pdos_registry.c/.h` (`registry.py gen`: unchanged
    against the merge, 159 files, 61 tables), `tests/dos-decoded.txt` (`registry.py goldens`: unchanged against the
    merge, 1380 lines), DOS-PROFILE.md 1.7.2 (`adapters.py gen`: rows 134);
  * D6fS-a's landing (13:36 UTC) changed `pdos_profile.c` (`pdos_compose_set_core`), `pmap_dos.c` (the A canvas's
    region, the covers), `harness.c` (`--tick-period-us`) and `ext_adapt.py`: merged cleanly;
  * the D7j/D6fS-a docs pass (docs-e4c, marker 14:55:11 UTC) changed `docs/DOS-PROFILE.md` (the "As implemented in
    D6fS-a" sentences after the row-29 menu-command paragraph, row 121's Differences): merged cleanly with D7d's rows 14
    and 97, section 1.7.2 and the I-city adapter paragraph (`obj/rebase-e4c/`); on the overlay of 14:57 UTC
    `adapters.py gen` leaves the merged file and `pdos_adapt_tab.c` unchanged (ADAPT_OK rows 134 steps 25), OBS_TABLES_OK
    probes 203 sites 101, REGISTRY_OK, pdos_scene_check PASS 1084, OBS_LINT_OK files 134.  No other staged file's
    base moved.
* **Results after the rebases** (the "Results" section's runs were on the tree of 08:57 UTC):
  * on the tree after D7j (overlay of 13:17 UTC): Checked BUILD_OK (portable sources 301); the Checked unit programs
    against D7j's cycle `build/d7j-2-test-checked.log`: only test_input 529 -> 559, test_dos 23243 -> 23250 and
    test_pdos_city new (78) differ (test_dos PASS 23250 against the staged goldens through `obj/fk/`); REGISTRY_OK,
    OBS_LINT_OK files 134, OBS_TABLES_OK, pdos_scene_check PASS 1084, ADAPT_OK rows 134, NODOS_OK; ext_adapt every
    case EXT_ADAPT_OK 213 (D7j's tree 208 + the five d7d lines); ext_p0 V0/V1/V2 P0_OK 225; ext_replay REPLAY_OK 70;
    ext_fce EXT_FCE_OK 8; ext_zoom `--only new`: the same ten golden lines only ("shows dos 289", DBL's goldens);
  * on the tree after D6fS-a (overlay of 14:06 UTC, the record's base): Checked, CheckedNoObs and Release BUILD_OK
    (portable sources 301); cc.cmd CC_OK in the three variants for `pdos_adapt.c`, `pdos_adapt_tab.c`,
    `pdos_profile.c`, `pmap_dos.c`, `pdos_seq.c`, `pdos_registry.c`, `pdos_scn_city.c`, `harness.c` and
    `test_pdos_city.c` (`test_input.c` is not a portable source; its clang parse reports the tree's own missing
    `square_only` initializer of D6fS-a's `PresentProfile`, line 176 in the tree, not a D7d line); the unit programs
    of the three variants, against D6fS-a's cycle `build/d6fsa-2-test-checked.log`: only test_input 529 -> 559,
    test_dos 23243 -> 23250 and test_pdos_city new (78) differ (CheckedNoObs test_input 503; test_dos PASS 23250
    against the staged goldens in each variant); REGISTRY_OK, OBS_LINT_OK files 134, OBS_TABLES_OK, pdos_scene_check
    PASS 1084, ADAPT_OK rows 134 (`adapters.py gen` leaves the staged DOS-PROFILE.md unchanged), NODOS_OK; ext_adapt
    every case EXT_ADAPT_OK 242 (D6fS-a's tree 237 + the five d7d lines); ext_p0 V0/V1/V2 P0_OK 225; ext_replay
    REPLAY_OK 70; ext_fce EXT_FCE_OK 8; ext_zoom `--only new`: the same ten golden lines only;
  * earlier, on the tree after DBL: also CheckedNoObs and Release BUILD_OK and cc.cmd CC_OK for `pdos_adapt.c`,
    `pdos_profile.c`, `pmap_dos.c` and `pdos_seq.c` in the three variants, the CheckedNoObs and Release unit programs
    (test_input 496 and 552 then, test_pdos_city 78, test_dos 23246 against the staged goldens).
* **Generated files** (regenerate on the merged tree, never merge by hand): `present/dos/pdos_registry.c/.h`
  (`gen/dos/registry.py gen`, from `docs/dos/OFFSETS.md`), `tests/dos-decoded.txt` (`registry.py goldens --dosdata
  build\dosdata`), DOS-PROFILE.md section 1.7.2 (`gen/dos/adapters.py gen`).
* **Shared tables with the other tracks** (each D7d edit is its own delimited block or a one-line hunk with an
  `extension D7d` comment), as staged now:
  * `pdos_adapt.h`: `PDOS_AS_CITY` 0x08000000 (the orchestrator's allocation) before D7j's `PDOS_AS_PALACE`,
    `PDOS_DEC_CITY` after `PDOS_DEC_DRAG`, the hook member `city` after `esc_item`, the doc paragraph after D7j's.
  * `pdos_adapt.c`: the city screen's scene test after D7j's palace test; `pdos_adapt_tab.c`: the four I-city rows
    after D7j's I-palace rows; `test_input.c`: the I-city vectors after D7j's, the row count 134.
    `gen/dos/adapters.py`: the SCENES row after D7j's, one DECISIONS entry, the class-W rule after D7j's W_SCENES rule.
  * `docs/dos/OFFSETS.md`: seven rows after D7j's PALACE_* rows, and a Notes bullet.
  * `gen/dos/registry.py`: `pdos_scn_city.c` in `OBSERVER_FILES` after D7a's `pdos_scn_report.c` (D7j's
    `pdos_scn_palace.c` at the set's end).
  * `pdos_profile.c`, `pdos_seq.c`, `pdos_replay.c`, `harness.c`, `pmap_dos.c`: one-line hooks after D7j's palace
    hooks (or D7a's report hooks); the cursor rule's last term.
  * `tests/harness/ext_adapt.py`: the d7d block after D7c's and its call in `main` after D7j's, the docstring
    paragraph after D7j's, and two hunks each in the d7a, d7b and d7c blocks (the city screen's return);
    `ext_p0.py`: ROW_ALLOW emptied (keep any entry another unit adds).  A unit whose ext_adapt pair runs S3's lines
    past 55,000 ms and counts `return` steps or `return_none` needs the same counting.
* **Still to land before D7d:** D6fS-b and any later unit: rebase on them at the slot as above.  D7d uses none of
  the menu box code (D6fS).
* **ext_zoom's ten lines** (above, staged in `tests/harness/ext-zoom-golden.txt`) are the only golden changes; the other
  changes above are counters and line texts.  At a rebase onto a unit that changes the `dos new` goldens, recompute
  the ten lines from a run (`obj/zoomgold.py --write`) rather than merging hashes.

## Landing

D7d landed alone at the build slot of session E4, 2026-10-17, after D6fS-a's landing (its RELEASE_OK 14:25:51 UTC and
`build/user-builds/d6fsa/`) and the D7j/D6fS-a docs pass (marker `build/docs-e4c-done.txt`, 14:55:11 UTC), as the
orchestrator ordered (D7d accepted as staged; the ten ext_zoom golden lines reviewed and staged first, the docs pass's
edits merged into the staged DOS-PROFILE.md).  The user checks D7d-1..D7d-7 are in the user build `d7d`.

* **Bases:** the docs pass changed `docs/DOS-PROFILE.md` only among the staged files (a clean three-way merge,
  Rebase notes, `obj/rebase-e4c/`); `obj/mkbase.py` wrote `BASE-SHA256.txt` again (23 files, bad 0).
  `build/d7d-prep/land.py` rechecked every base (DRY_RUN_OK 23; build.cmd and test.cmd unchanged), took the snapshot
  `build/d7d-prep/before` (the tree's `build/test/Checked` outputs of D6fS-a's cycle, 65 files) and `tree-before`
  (the replaced files), and copied in at 14:57:21 UTC (`landed.sha256`: the 19 changed and 4 new files with this
  record; `landed-at.txt` "unit d7d").  Predictions `build/d7d-prep/predictions.txt`, written before the copy-in.
* **The three-step cycle** (`build/d7d-prep/d7d-cycle.ps1`, status `build/d7d-status.txt`): 1 `build.cmd checked`
  BUILD_OK 14:57:27..15:01:03 (216 s; portable sources checked 301); 2 `test.cmd checked` TESTS_OK 15:01:03..15:29:05
  (1681 s; wall 1679.6 s: ext_zoom 1679.2, ext_adapt 1217.0, ext_p0 1191.1, d2_nodos 1048.5 s; no flake rerun); 3
  `ext_g1.py check` EXT_G1_OK runs 77 (amended 1) unchanged: **ALL_GREEN** 15:29:05.  4 `build.cmd` (Release)
  BUILD_OK 15:29:15..15:32:56 (220 s): **RELEASE_OK**.
* **Against the predictions** (`build/d7d-prep/compare.py` against the snapshot, `build/d7d-prep/compare.txt`: 48 of
  65 files equal, host times left out): as predicted, unit.log test_input 529 -> 559, test_dos 23243 -> 23250 (decoded
  content 1373 -> 1380 lines, registry 54 -> 61 tables), test_pdos_city new (PASS 78), every other count equal;
  EXT_ADAPT_OK checks 237 -> 242 (the five d7d lines: d7d-city equals its Windows-form pair, coreinput 36, frames 662;
  the N frame in 5 shows; the `city` line with every mismatch 0, checks 5, renders and copies counted) and the d7a,
  d7b and d7c diag lines `return_none 1 -> 2`; OBS_LINT_OK files 132 -> 134 (probes 203, callsites 101); ADAPT_OK rows
  130 -> 134 steps 25; REGISTRY_OK (the seven tables' ok lines); dos-decoded.txt the seven table lines; OBS_TABLES_OK
  and pdos-scene-check (1084) unchanged; NODOS_OK 0 hits (files 1780 -> 1785); P0_OK checks 476; REPLAY_OK checks 70
  with V1 `no_shadow` lower and the new `city` counter in `city` (437), `new` and `s3` (15) and `settlers` (17);
  ZOOM_OK against the landed golden (exactly the ten reviewed lines), `new` runs "shows dos 290 -> 289"; EXT_FCE_OK
  runs 8, EXT_DBL_OK, EXT_TIMELINE_OK, MIRROR_OK and the other sections unchanged.  Not named by the predictions,
  informational counts only, every criterion PASS as before, all from the same cause (S3's city screen at 52,183 ..
  55,002 ms, and the city screens of the `city` run and of s4, are now the 320x200 N frame, on which the map layer is
  not drawn): ext_adapt's zoomkeys-dos "the DOS layer drawn in 126 -> 125 shows", ring-dos 257 -> 256, f6-zcover-m1,
  -p1 and -menu one view fewer and one tick more (73 views, 69 ticks -> 72, 70; 72, 68 -> 71, 69; 80, 76 -> 79, 77);
  ext_p0's "V4d city zoom: 163 -> 158 shows with the layer"; ext_frames' s3 "presented.log of A equals A'" 815 -> 821
  lines and "782 -> 781 tick shows"; ext_zoom's s4 1920x1440 sw shows 4699 -> 4696 and 4609 -> 4607.  Also
  informational: coverage.txt "other functions entered" 664 -> 666 (the known jitter of the merged coverage files);
  unit.log's OBS_COST line (host timing).
* **User build** `build/user-builds/d7d/` (15:33 UTC): `civ64.exe` (the Release build, SHA-256 e5c2b24d...),
  `CIVWIN.zip` and `civdos.zip` from `build/user-builds/d4/`, `WHAT-TO-CHECK.txt` (D7d-1..D7d-7, the earlier builds up
  to "d6fsa", and the 90 items still pending in the checklist at 15:29 UTC).
* Not done at this slot: the checklist rows and sections and STATUS rows (the orchestrator's) and the docs pass for
  this record's "For the records"; the tree's CheckedNoObs build is not part of the three-step cycle (the private
  overlay builds and units of the three variants are in "Results").

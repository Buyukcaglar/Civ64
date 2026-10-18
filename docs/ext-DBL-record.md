# Extension DBL, presentation unit (the DOS blinks at the DOS game's own pace) - record

Extension session E4, staging implementer.  Staged under `build/dbl-stage/` only; nothing in the tree or in a shared
output was written for DBL.  Base: the tree at the D6 gate's state (base hashes taken 2026-10-17 07:46:58 UTC); D7a+D7b
landed at 08:07:35 UTC and changed two bases, `present/dos/pdos_aplay.c` (an include and the return's fade-in call at
RestoreMapAfterDialog) and `present/dos/pdos_profile.c` (D7a's report and fade-in wiring): both staged copies were
rebased mechanically with a three-way merge (`git merge-file` on copies under `obj/rebase/`; one adjacent-line conflict
in `dos_advance`, resolved by keeping both lines, D7a's `pdos_fx_return_run` first), their base lines updated, and the
overlays rebuilt and every check and test below re-run on the D7a+D7b tree.  The bases (`BASE-SHA256.txt`, ten with the
ext_zoom golden) verified against the tree after each rebase.  UX5b landed at 09:35 UTC and changed one base,
`test.cmd` (its `ux3_aspect` comment and echo): the staged copy was rebased the same way (clean), the overlay refreshed
with UX5b's files and rebuilt, and the checks named in "Tests" re-run.  D7c landed at 10:57 UTC and changed one base,
`present/dos/pdos_profile.c` (the report's input rule while a quiet report runs): rebased the same way (clean), the
overlay refreshed with D7c's files and rebuilt, and the checks named in "Tests" re-run again.

## Result

In the DOS graphics the active unit now blinks at the DOS game's own pace: its square on the main map and its square on
the World Map change every 10 VGA frames (142.68 ms; a whole blink, shown and hidden, 285.35 ms, about 3.5 blinks a
second), and "End of Turn" in the unit panel blinks at the same pace.  Before, all three followed the Windows game's
blink (TickCount() % 60: a whole blink a second, half shown), about 3.5 times slower than the DOS game.  Measured in the
harness (`ext_dbl.py`, the DOS frames the player sees): the unit's square and its World Map square change together
every 142.66 ms on average (30 changes, every interval 129..156 ms, a show waits for the next tick), "End of Turn" every
142.66 ms (21 changes); on the base the same measurement gives 503 ms and 494 ms.

The game still decides what blinks and when: the blink starts when the game starts waiting for the unit's orders (or
shows "End of Turn") and stops when it stops waiting; the DOS clock decides only which of the two pictures shows.  While
a menu is open (or the map window is moved or sized) the unit stays shown and "End of Turn" hidden, as the DOS game,
which opens its menus only after its blink loop ended on that picture; when the menu closes the blink starts again
with the hidden picture.  The Windows graphics are unchanged (the same frames, byte for byte, as the base in the
harness), and the game runs the same in both graphics: no core change, no random number, no timer the core sees (P0).

## Status

**LANDED** (2026-10-17 11:50:46 UTC; cycle ALL_GREEN 12:28:57 UTC, RELEASE_OK 12:35:29 UTC; user build
`build/user-builds/dbl/`; section "Landing").  Before: READY_TO_BUILD, implemented, compiled warnings-as-errors in
Checked, CheckedNoObs, Release and the cc.cmd strict variants in the private overlay, unit- and harness-tested in the
overlay; the new timing test fails on the base and passes with the change (section "Tests").  The user's checks
DBL-1..DBL-5 and the rewritten D6e-2 are pending (section "What the user checks").

Staged (full copies at their tree paths under `build/dbl-stage/`; base = the tree's file, `BASE-SHA256.txt`, verified
again 2026-10-17 11:43 UTC; copies of the ten bases under `obj/rebase/base/` for a later three-way merge):

| File | Base sha256 | Staged sha256 | Change |
|---|---|---|---|
| `present/dos/pdos_ublink.h` | (new) | 9ebd4650a6bd3fc0... | the blink clock's interface, evidence, the user's words (65 lines) |
| `present/dos/pdos_ublink.c` | (new) | da6a14a120d0cbc8... | the clock: 10-frame phases on its own M1 grid, the hold (87 lines) |
| `present/dos/pdos_aplay.c` | c8691dd9a219b410... | 6abeebabfd3886dd... | +154: "End of Turn" and the small-map square on the clock, `pdos_aplay_advance`, the start and end hooks, the core's blink drawing ignored, `def_modal`, counters |
| `present/dos/pdos_aplay.h` | 3109c2e8c3e3910a... | dfd8e3b5bc708119... | +14 -1: `PdosAplayQ.modal`, `pdos_aplay_advance`, the counters |
| `present/dos/pdos_profile.c` | 877fe454747b3ac8... (D7c's) | b9a288cac6f2731a... | +3 -1: `pdos_aplay_advance(now_us)` in `dos_advance`, the header comment |
| `present/map/pmap_dos.c` | 4cf44b2b7aeee0f2... | 4b4fe53484580592... | +128: `pmap_dos_blink_begin/stale/apply/diag`, the pictures written over Wn_dos |
| `present/map/pmap_model.c` | 91e48c7404bcfe39... | d43524d1a8d18be4... | +96 -3: `map_tile_dos_surf` split out, `pmap_model_blink_pics` |
| `present/map/pmap_inview.c` | 504803d2e64918e7... | c9ae4efbef243cba... | +11: the begin at BlinkActive's entry, the stale marks, the writes at core present and tick |
| `present/map/pmap_int.h` | 362cd818685eb3bd... | 899be231a5d22113... | +32: `PmapBlinkPics`, `PmapDosBlinkDiag`, the prototypes |
| `tests/test_pdos_play.c` | ad497a32e7a0fa06... | 21c5ba53ed2aabcf... | +192 -1: `test_ub_clock`, `test_blink_eot`, `test_blink_unit` (46 -> 78 checks) |
| `tests/harness/ext_dbl.py` | (new) | 90fc24d8f4de7dae... | the timing test (311 lines) |
| `test.cmd` (CRLF) | 6be85d66e755c43c... (UX5b's) | 95e6abc87b20c35d... | +19: section `ext_dbl` (DBL begin/end markers) |
| `tests/harness/ext-zoom-golden.txt` (CRLF) | dd6f7d76210b5e5f... | 3389051f4fdc4995... | 40 of 240 `dos` lines (samples during a blink); the Windows lines unchanged |

Full hashes: `BASE-SHA256.txt` (bases); `sha256sum` of the staged files gives the staged column.  Also staged:
`BUILD-TEST-ADDITIONS.md`, this record, `STATE.md` (a pointer here).  `obj/` is private and not to be landed.

`test.cmd` gains one section, `ext_dbl` (`BUILD-TEST-ADDITIONS.md`); `build.cmd` is unchanged (its glob compiles the new
`present/dos/pdos_ublink.c`).  `tests/harness/testpar.py check` on the staged `test.cmd`: exit 0.

## The user's report and the clarification

The user's revision list, 2026-10-17 about 07:00 UTC, items 1 and 2 (verbatim): "DOS units blinks at slightly faster
rate" and "End of turn blinks at slightly faster rate".  The DOS listing gives a DOS period about 3.5 times shorter than
the one the DOS graphics showed, so the items could be read either way; the user settled it, 2026-10-17 about 07:50 UTC
(verbatim): "I meant 'the real DOS game blinks faster'".  So both items ask for the faster DOS pace.  Checklist D6e-5
failed on item 2 (2026-10-17 about 07:00 UTC); D6e-2 ("the active unit blinks white on the World Map as in the Windows
graphics") is rewritten below.

## Design and listing evidence

### The DOS game's blink (DOS listing, R:0866:0AD6..0CF4, read instruction by instruction)

Caller: the main loop R:0403:0655 (`lcall R:0866:0AD6` with civ [bp+6], unit [bp-32h], cx [bp-0Eh], cy [bp-12h]),
before its key read (R:0403:066C tests DGROUP:DB3A next).  SCENES-PLAY.md 6.1 agrees.

| Address | What it does | Label |
|---|---|---|
| R:0866:0ADD..0B2D | [bp-6] = -1; when cx is not -1: the cursor square's DOS position ((cx - view left) wrapped, x 16 + 50h; (cy - view top) x 16 + 8), -1 when off the map view | DOS listing |
| R:0866:0B2D..0B72 | the small map's column (x - DGROUP:6ED6, wrapped by R:1E31:119B) and row (y - DGROUP:70EA) of the unit | DOS listing |
| R:0866:0B75 | the loop's top: R:01A8:0268 (the pointer hidden) | DOS listing |
| R:0866:0B7A..0BC7 | phase A, unit below 80h: R:1AEA:03BA(x, y), the square without the unit; when the row is 0..49, R:1AEA:17FF(column, row + 8, 15): the small-map pixel in colour 15 | DOS listing |
| R:0866:0BC9..0BDE | phase A, unit 80h: R:0182:005C("End of Turn" DGROUP:20F6, 4, 7Ch, colour 7) | DOS listing |
| R:0866:0BE1..0BF8 | phase A, a cursor square: R:1D05:0A05(px, py, 15, 15, colour 15) | DOS listing |
| R:0866:0BFB | R:01A8:0250 (the pointer shown) | DOS listing |
| R:0866:0C00..0C12 | wait(n), n = 1 when a key is waiting (kbhit R:2045:2098), else 0Ah | DOS listing |
| R:0866:0C1A..0C84 | phase B, unit below 80h: R:1AEA:0E29(civ, unit), the unit; the small-map pixel in colour 1 when R:1AEA:134A(x, y) is 0Ah (ocean), else 2 | DOS listing |
| R:0866:0C86..0C9A | phase B, unit 80h: "End of Turn" (DGROUP:2102) at (4, 7Ch) in colour 0 | DOS listing |
| R:0866:0C9D..0CB6 | phase B, a cursor square: R:1D05:0A05(px, py, 15, 15, colour 0) | DOS listing |
| R:0866:0CB9..0CD0 | the pointer shown; the same wait (1 or 0Ah) | DOS listing |
| R:0866:0CD8..0CED | R:01A8:0223 (the mouse polled); leave when a key is waiting or DGROUP:DB3A (a button) is not 0, else `jmp R:0866:0B75` | DOS listing |

wait(n) = R:0182:0134: R:0000:033E clears the frame counter DGROUP:005C, then R:0000:033A is polled until it is not
below n (TIMING.md 3.3; DOS listing).  The counter is raised by the frame routine R:0000:0345, once per VGA frame of
17,024 PIT clocks with retrace locking (TIMING.md 1, 2.5: 70.086 Hz).  On the DOS clock model (pdos_clock.h: M1 the
frame grid, M2 the drawing takes no time) each phase is 10 frames: 142.68 ms (142,677.3 us), the cycle 20 frames,
285.35 ms.  The period is shorter than the 1 s that the DOS graphics showed, so the ruling's stop condition (a longer
DOS period) does not apply.  The loop always ends after a phase B (the leave test is only at R:0866:0CD8).

### Today's period in the DOS graphics (harness, the base build, before DBL)

The base harness (`obj/fast/base-src`) on CAE3540B.SAV loaded from the title menu, no input (`obj/scripts/idle.script`),
`--graphics dos --dump-presented`: the unit's square changed at 25.05..29.55 s every 440..547 ms, mean 500.3 ms (nine
intervals): a 1 s blink.  "End of Turn" (EOT.SAV = CAE3540B.SAV with gameOptions |= 4, `obj/scripts/eotw.script`):
33.56..37.57 s, mean 501.05 ms.  That is the core's blink, BlinkActiveUnitUntilInput 11C0:0EC2 (port listing; core
`seg057_11C0_p1_r.c`): blinkPhase = TickCount() % 60 (11C0:0F42), hidden above 30 (11C0:0F5A), shown below 30
(11C0:107D), TickCount from GetTickCount's 55 ms steps.  The DOS graphics drew the core's hide and show
(RestoreBlockXY 11C0:0FC3 and DrawUnit 11C0:10AE through the map model; PlotSmMapSquare 11C0:100F and 11C0:1140; "End of
Turn" TEXTOUTs 11C0:1049 and 117A).  DOS is 3.5 times faster.

### The design (presentation clock; the core decides what and when)

* **The clock** (`present/dos/pdos_ublink.h/.c`, new, portable, pure): `PdosUb` on its own M1 grid; phase A for frames
  0..9, B for 10..19 of every 20 from the grid's start (`pdos_ub_phase_at`, `pdos_ub_next`), `PDOS_UB_PHASE_FRAMES` 10
  (R:0866:0C0E, 0CCC).  Started at BlinkActiveUnitUntilInput's entry with the core's civ and unit (phase A at once,
  R:0866:0B75), stopped at the core's end of the loop.  `pdos_ub_update(t, held)`: held (a modal loop of the host)
  shows phase B; at the hold's end the grid starts again with phase A (inferred: the DOS main loop calls R:0866:0AD6
  again after a menu).  No emulation read, no random number.
* **"End of Turn" and the small-map square** (`pdos_aplay.c`): at BlinkActiveUnitUntilInput's entry (unit 0..80h)
  `blink_start` reads the unit's square (+1 x, +2 y, as 11C0:0ED7) and shows phase A; `pdos_aplay_advance(now)`, called
  by the DOS profile's advance at every presentation tick (visible or not, `pdos_profile.c`), shows each change of
  phase: "End of Turn" in DOS colour 7 (A, R:0866:0BC9) or 0 (B, R:0866:0C86), the Status column drawn again; the
  small-map square in 15 (A, R:0866:0BB1) or 1/2 (B: ocean by the core's terrain of the square, read as GetTerrainType
  reads it, g_lpScreenBuffer's row y through g_terrainByMapColor, R:0866:0C5C..0C6E).  Meanwhile the core's own blink
  drawing is ignored (PlotSmMapSquare from 11C0:100F and 11C0:1140, the "End of Turn" TEXTOUTs outside the panel
  functions; `blink_core` counts them); the panel drawn again during the blink keeps the DOS phase.  The end: DrawUnit
  from 11C0:11DA (return address 11C0:11DF, the loop has ended) or the function's exit shows phase B and stops the
  clock; the core's end plots (11C0:1271 a city's colour, 11C0:12A9 the terrain) and its later drawing apply as before.
* **The main map's square** (`pmap_dos.c`, `pmap_model.c`, `pmap_inview.c`, `pmap_int.h`): BlinkActiveUnitUntilInput's
  entry begins the map's blink for a unit below 80h (`pmap_dos_blink_begin`).  At the first write the two pictures are
  drawn by the DOS rules (`pmap_model_blink_pics`): a scratch surface of P_dos's size holding P_dos's square and a
  2-pixel margin, the square drawn over it as the model draws DrawMapTile (the core's hide, RestoreBlockXY 1110:0448 ->
  DrawMapTile 1110:04AB, with the flush's labels when g_autoFlushToWindow is set, 1110:0CF1) -> picture A; then the unit
  as the model draws DrawUnit (the core's show, IsRectOnMapScreen 1110:0E62, R:1AEA:0E29 with the stack shadow) ->
  picture B; 32 x 32 each, at the square's position (RestoreBlockXY 1110:045D, 0480), clipped to the flushes'
  rectangle (the square within the window data's client: 1110:0D23..0D32, FlushSquareToWindow 11E8:084C..087E).  At
  every core present (before the map element is set) and every tick the picture of the DOS clock's phase is written
  over that square of Wn_dos, compare-first, with its damage; at a tick M_dos (the zoom layer's source) follows
  (`pmap_dos_inview_present`).  P_dos keeps the core's own drawing (the dos-settled check reads it).  The map drawn
  again during the blink (DrawTilesToPort's or RedrawMapRect's exit) has the pictures drawn again at the next write.
  The counters and the test seam's trace are kept as they were (`PmapDosBlinkDiag` counts begins, renders, writes,
  stops).  Nothing when g_autoFlushToWindow is 0 (neither the core's hide nor its show reaches the window, 1110:0CF6,
  11E8:07FE), at a scaled port or with a dialog port (the model draws neither, `t_map_tile`, `t_unit`).
* **Windows graphics**: unchanged; the DOS shadows and M_dos are DOS-only (M_dos damages the layer only while it shows
  the DOS profile).  Switching keeps each profile's pace: the DOS clock runs while the Windows graphics show.
* **P0**: every read is a w16q_* query (or the model's PmapSrc), written are only this module's memory, the DOS shadows
  and M_dos; no random number, no event, nothing the core reads.

## Deviations

* The 1-frame phases when a key is waiting (R:0866:0C00..0C12, 0CBE..0CD0) are not modelled: the core ends its loop at
  the key at once (IsKeyPending 11C0:1071, 11A7) and the end shows phase B, as the DOS loop ends after a phase B.
  (inferred)
* The first phase lasts exactly 10 frames from the core's entry: the DOS wait's first frame is a fraction of a frame
  (TIMING.md 3.3, more than 9 and at most 10 frames), which depends on where the call falls in the DOS frame; the grid
  starts at the entry (pdos_clock.h M1).  At most one frame (14.3 ms) on the first phase only.  (inferred)
* The cursor square (cx, cy; R:0866:0BE1..0BF8, 0C9D..0CB6: the DOS main loop's square cursor, R:0403:1034/103D and
  1C60/1C7B) has no counterpart: the core's BlinkActiveUnitUntilInput(civ, unit) has no cursor, and the core decides
  what blinks.  Not drawn.  (DOS listing; choice)
* The small-map square is drawn in every row the World Map shows; the DOS program plots it only when its small-map row
  is 0..49 (R:0866:0BA5..0BAF, 0C34..0C3E), which the Windows World Map's full map always is.  (DOS listing)
* The hold during a menu or a move/size of a window (phase B, then a new grid from phase A) is a choice: the DOS game
  opens its menus only from its main loop after the blink loop has ended (on phase B) and calls the blink again after
  the menu.  The core's own loop is suspended by the host's modal loop then (the menu's tracking, `w16q_menu_state`;
  the move or size, `w16q_sys_track`).  (inferred; choice)
* A blink started while a dialog port is current, or with g_autoFlushToWindow 0, leaves the main map square to the
  core's drawing (as before DBL); the small map and "End of Turn" still follow the DOS clock.  Not seen in play.

## Tests

All in the private overlay (`obj/src`: the tree with the staged files, after D7a+D7b and, refreshed, after UX5b and
D7c; `obj/fast/base-src`: the D7a+D7b tree without them, the base), never in the tree.  Nothing was run against the
tree or its `build/` outputs.

**The new timing test, `tests/harness/ext_dbl.py` (section `ext_dbl`, Checked).**  Three harness runs from
CAE3540B.SAV loaded from the title menu: `unit-dos` (the DOS graphics, no input, `--dump-presented`, to 29 s),
`unit-win` (the Windows graphics, `--dump-frames --dump-from 490`), `eot-dos` (EOT.SAV, made by saveedit from
CAE3540B.SAV with gameOptions |= 4, a space per unit from 27 s to "End of Turn", the DOS graphics, to 36 s).  It
measures the DOS frames the player sees (the k-th dump is the k-th presented frame of `presented.log`, its virtual
time from there): the unit's square (448..512 x 224..288), its World Map square (64..96 x 64..96) and "End of Turn"
(0..160 x 256..288).

| Run | Base (the tree, D7a+D7b) | With DBL |
|---|---|---|
| unit-dos | FAIL: 10 changes from 24,881.5 ms, mean 503.43 ms (492.40..547.35) | PASS: 30 changes, mean 142.663 ms (129.15..155.70), the World Map square changing with the unit at every show |
| eot-dos | FAIL: 6 changes from 33,019.2 ms, mean 493.93 ms (492.40..495.45) | PASS: 21 changes, mean 142.656 ms (140.35..145.50) |
| unit-win | PASS: 8 core-frame changes, intervals 492.4..547.3 ms | PASS: the same intervals; `presented.log` byte-identical to the base's (540 lines) |
| P0 | PASS: unit-dos and unit-win core frames (530) and final snapshot equal | PASS: the same, and the same hashes as the base (the frame and snapshot lines of `run.log` equal across all four unit runs; eot-dos equal to its base) |
| Result | `EXT_DBL_FAILED=2` | `EXT_DBL_OK checks 4` |

The checks: two pictures only; at least 20 (unit) or 16 (End of Turn) changes; from the first whole cycle every interval
within 22 ms of 142.68 ms (a show waits for the next presentation tick, at most about 16.7 ms, plus the frame grid) and
every two intervals within 22 ms of 285.35 ms; the mean within 2 ms of 142.677 ms; in the Windows run the core frames
change every 440..560 ms (the core's TickCount() % 60) after the last gap below 300 ms.  `obj/ext-dbl-base.txt`,
`obj/ext-dbl-src.txt`.

**Unit tests, `tests/test_pdos_play.c` (section `unit`):** 46 -> 78 checks.  `test_ub_clock` (7: the 10- and 20-frame
boundaries +142,678 and +285,355 us of `pdos_frame_us`, the phase at and either side of each, the next change, start,
the hold and the new grid at its end, stop), `test_blink_eot` (13: the entry's phase A in colour 7, the core's two
TEXTOUTs ignored, phase B in colour 0 at +142,678 us, A again at +285,355 us with the same picture, the panel drawn again
keeps the phase, the hold, the new grid, the exit with phase B, the core's TEXTOUTs applying again after it),
`test_blink_unit` (12: the small-map square in 15 at the entry, the core's show and hide plots ignored, land 2 and ocean 1
in phase B, the end at DrawUnit from 11C0:11DF, the core's later plot applying, the exit, the hold on an ocean square).
The whole `unit` section in the overlay (Checked): every test as in the tree's last run except `test_pdos_play` 46 -> 78
(`obj/unit-pass.txt` against `obj/unit-pass-tree.txt`); `test_ne`'s `check_ne.py` reads a path outside the overlay and
fails there only (as in every staging overlay).

**Builds and checks (overlay):**

* `b.cmd` (Setup-Msvc, then the overlay's `build.cmd VARIANT --nogen`): Checked, `checked noobs`, Release: `BUILD_OK`
  (c11, c17 /W4 /WX, the clang C99 parse of every source, the new `pdos_ublink.c` by the glob).
* `obj/cc.cmd` (build.cmd's strict commands on the changed sources: c11, c17 /W4 /WX, clang-tidy C99 pedantic with
  warnings as errors) on `pdos_ublink.c`, `pdos_aplay.c`, `pdos_profile.c`, `pmap_dos.c`, `pmap_model.c`,
  `pmap_inview.c`, `test_pdos_play.c`: `CC_OK` in Checked, CheckedNoObs and Release.
* The checks the staging protocol names (Checked overlay, after the rebase): `gen/dos/registry.py check`
  `REGISTRY_OK`; `gen/dos/nodos.py check` `NODOS_OK` (Checked, `checked noobs` and Release, the `d2_nodos` section);
  obs_lint `OBS_LINT_OK files 128 probes 203 callsites 101` (the tree: 126 files, the two new sources); `gen/obs_tables.py
  --check` `OBS_TABLES_OK probes 203 sites 101`; pdos_scene_check `PASS 1084 checks`; adapters `ADAPT_OK rows 123 steps
  25`.  No probe, call site, registry or adapter row is added: DBL uses the existing probes (BlinkActiveUnitUntilInput,
  DrawUnit, PlotSmMapSquare, TEXTOUT, DrawTilesToPort, RedrawMapRect).

**The sections in the overlay** (`tests/harness/testpar.py sections` on the overlay's staged `test.cmd`; every result
as in the tree's last run, 2026-10-17 08:22..08:45 UTC, except the two DBL changes):

| Section | Checked (overlay) | Notes |
|---|---|---|
| unit | as the tree, `test_pdos_play` 78 | also Release: `test_pdos_play` 78, the rest as Checked's counts |
| d2_registry, d2_nodos, d3a_obs_tables, d3a_obs_lint, d4a_pdos_scene, d4c1_adapters | OK | above |
| harness_stub, gate3b, uninit, scenarios, p4tests | `HARNESS_EXPECT MET`, `GATE3B_OK`, `UNINIT_OK`, `P4_SCENARIOS_OK`, `P4_TESTS_OK` | the core's runs |
| ext_p0 | `P0_OK checks 476` | as the tree; `checked noobs` (V5 against the Checked V0 outputs) `P0_OK checks 62` |
| ext_frames, ext_timeline, ext_continue, ux3_aspect | `EXT_FRAMES_OK`, `EXT_TIMELINE_OK`, `EXT_CONTINUE_OK`, `EXT_ASPECT_OK` | |
| bs1_assets, bs2_mirror, bs3_timeline | `EXT_BS_OK`, `EXT_BS_OK`, `EXT_TIMELINE_OK` | |
| ext_adapt, ext_slots, ext_tld, ext_fce | `EXT_ADAPT_OK checks 198`, `EXT_SLOTS_OK`, `EXT_TLD_OK`, `EXT_FCE_OK runs 8` | |
| ext_mirror, ext_replay | `MIRROR_OK runs 29`, `REPLAY_OK checks 70` | |
| ext_dbl (new) | `EXT_DBL_OK checks 4` | the base: `EXT_DBL_FAILED=2` |
| ext_zoom | with the tree's golden `ZOOM_FAILED=30` (one `golden dos` sample per combination, the first that differs); with the staged golden (a second, independent run) `ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32 centre runs 4 mzi runs 12 mzs runs 4 not zoomed 38/448`, the tree's line | 40 `dos` golden lines, above |
| G-1 (`ext_g1.py check`) | `EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)` | as the tree's `d7ab-3-g1-checked.log` |
| `checked noobs` (every section) | `test_pdos_play` 78; `REGISTRY_OK`, `NODOS_OK`, `GATE3B_OK`, `UNINIT_OK`, `P4_SCENARIOS_OK`, `P4_TESTS_OK`, the obs and adapters checks, `P0_OK checks 62`, `EXT_CONTINUE_OK`, `EXT_BS_OK` (two); G-1 `--variant CheckedNoObs` `EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)` | the unit counts as the tree's last `checked noobs` run plus D7a+D7b's, `test_pdos_play` 46 -> 78 |
| Release (every section) | `test_pdos_play` 78; `REGISTRY_OK`, `NODOS_OK`, the obs, scene and adapters checks | |

**After UX5b landed** (the overlay refreshed, 0 differences from the tree plus the staged files): `b.cmd` Checked,
`checked noobs`, Release `BUILD_OK`, 298 portable sources each; Checked sections unit (every count as before except
UX5b's own `test_pdos_aspect` 93 -> 140 and `test_pdos_seq` 214 -> 215; `test_pdos_play` 78), d2_registry, d2_nodos,
d3a_obs_tables, d3a_obs_lint, d4a_pdos_scene, d4c1_adapters (the same OK lines), ux3_aspect `EXT_ASPECT_OK` and
ext_dbl `EXT_DBL_OK checks 4` (the same measurements); the `unit` section in Release and `checked noobs`
`test_pdos_play` 78, every other count as before but UX5b's two (the only failure `check_ne.py`'s overlay path).

**After D7c landed** (the overlay refreshed again, 0 differences, the bases verified 11:43 UTC): `b.cmd` Checked,
`checked noobs`, Release `BUILD_OK`, 299 portable sources each; Checked sections unit (as after UX5b except D7c's own
`test_pdos_report` 169 -> 229; `test_pdos_play` 78), d2_registry, d2_nodos, d3a_obs_tables, d3a_obs_lint (`files 130`:
the tree's 128 since D7c and DBL's two), d4a_pdos_scene, d4c1_adapters, ux3_aspect `EXT_ASPECT_OK`, ext_adapt
`EXT_ADAPT_OK checks 203` (the tree's D7c run: 203) and ext_dbl `EXT_DBL_OK checks 4` (the same measurements); the
`unit` section in Release and `checked noobs`: `test_pdos_play` 78, D7c's `test_pdos_report` 229, the rest unchanged.

The long sections (ext_p0, ext_zoom, ext_mirror, G-1 and the rest of the table) were run on the D7a+D7b tree only: UX5b
changes Birth's start and the setup page, D7c the reports' screens, neither the map, the World Map, the unit panel or
the blink; the build slot's full run covers the combination.

Overlay-only failures, not DBL's and not in the tree: `test_ne`'s `check_ne.py` and the `trace` section read
`claude/docs/db` two levels above the port (outside the overlay); `run-scenario.cmd` calls Setup-Msvc four levels up
(the overlay's copy was pointed at `C:\Projects\Civ1RE\scripts\Setup-Msvc.cmd` for gate3b and uninit, then restored).

## For the records

* **manual-checklist-ext.md** (the orchestrator): a new section DBL with DBL-1..DBL-5 (above); D6e-2 rewritten as above
  (pending in the DBL build); D6e-5's status: the blink part reworked by DBL (DBL-3); D6c-5's note: the active unit's
  blink is at the DOS game's pace since DBL.
* **FIDELITY.md** F133 (the DOS map's animation and redraw order): the sentence "the blink at the core's phase ... not the
  DOS 17 one-pixel move frames or 10/10 blink" becomes "... the move in the core's 9 frames ... not the DOS 17 one-pixel
  move frames; **changed by DBL** (2026-10-17, the user's revision items 'DOS units blinks at slightly faster rate' and
  'End of turn blinks at slightly faster rate', clarified 'I meant "the real DOS game blinks faster"'; `ext-DBL-record.md`):
  the blink at the DOS game's own pace, R:0866:0AD6's 10 VGA frames a phase (142.68 ms, a cycle 285.35 ms, the DOS clock
  model M1/M2), on a presentation clock started at BlinkActiveUnitUntilInput's entry and stopped at the core's end of the
  loop (the core decides what blinks and when; P0); the main map's square, the World Map's square and 'End of Turn' alike;
  the Windows graphics keep the core's TickCount() % 60".  Status line: "implemented in DBL; tests `test_pdos_play`
  (46 -> 78), `ext_dbl.py` (EXT_DBL_OK checks 4); user checks DBL-1..DBL-5 pending".
  **F-new-1** (the DOS blink clock's rules, `present/dos/pdos_ublink.c`, `pdos_aplay.c`, `present/map/pmap_dos.c`): DOS
  original: R:0866:0AD6's phases of 10 frames, or 1 frame while a key is waiting; its first wait a fraction of a frame
  shorter; a square cursor (cx, cy) outlined in colour 15/0; the small-map pixel only in its rows 0..49; the blink loop
  ends before any menu.  Port: the phases are 10 frames on a grid from the core's entry (the 1-frame phases not modelled:
  the core leaves at the key, and the end shows phase B as DOS does); no cursor (the core's blink has none); every World
  Map row; while a host modal loop holds the core's loop (a menu tracked, a window moved or sized) phase B, then a new
  grid from phase A (**inferred**/**choice**, section "Deviations").
  F191's "The 'End of Turn' blink: the core's EGA 14 or 0 ... DOS 7 or 0" gains "(since DBL at the DOS clock's phase:
  7 in phase A, 0 in phase B; the core's TEXTOUTs ignored during the blink)".
* **DESIGN.md** 12.7 "As implemented (D6e; area B)": the small-map bullet's "(EGA 15, the blink, 15)" and the Status
  bullet's "The 'End of Turn' blink: ..." get "since DBL on the DOS clock (`pdos_ublink.h`; 12.9 DBL)"; a new paragraph
  "**As implemented (DBL; areas B and D)**" after 12.9's D6d/D6f text, from this record's "The design" (the clock
  `pdos_ublink.h/.c`; `pdos_aplay_advance` from the DOS profile's advance; `pmap_model_blink_pics`,
  `pmap_dos_blink_begin/stale/apply`, `PmapDosBlinkDiag`; P_dos untouched, Wn_dos and M_dos written; the hold; the end)
  with the tests line "`test_pdos_play` 78 (32 DBL checks: the clock, End of Turn, the small-map square), `ext_dbl.py`
  (three runs: the DOS unit and End of Turn at 142.68 ms, the Windows blink at the core's half second, P0)".  12.9's
  "the core's redraw order, moves and blink drive the animations (P3, P6)" -> "... moves drive the animations, the
  blink's phases are the DOS clock's since DBL (P3, P6)".  The 12.7 Tests line: `test_pdos_play` 78.
* **verify/ext-d1-draft-D.md** 14.6's Blink row (line about 1160; the design draft, if the docs pass keeps drafts
  current): "the core's phase ... the DOS 10/10 frames are not used" -> "since DBL the DOS 10/10 frames from the core's
  entry to its end (the core's start and stop)".
* **DOS-PROFILE.md** row 132 (prose only, no new call address): the timing cell "TC (the core's phase)" -> "TC (start
  and end) + TX (10-frame phases, DBL)"; the notes cell gains "; since DBL (2026-10-17) the blink's phases on the DOS
  clock: 10 frames each, the main map's square, the small-map square and 'End of Turn' alike, the core deciding what
  blinks and when".  Run `gen/obs_tables.py --check` after the edit.
* **RUNNING.md**: the `test_pdos_play` text (about line 175): "and the play palette's return at
  RestoreMapAfterDialog; 46 checks" -> "the play palette's return at RestoreMapAfterDialog and, since DBL, the blink's
  own clock (10 frames a phase, the hold and the new grid), 'End of Turn' and the small-map square on it; 78 checks in
  Checked, `checked noobs` and Release (46 before DBL)"; the section count (line 80: "29 since FCE") gains "30 since DBL
  (2026-10-17), with its Checked-only `ext_dbl` between 'extension DBL (begin)' and '(end)', after FCE's (299 portable
  sources since DBL, with `present\dos\pdos_ublink.c`)" (the tree has 298 since D7c; the count as the landing's
  build log prints it); a row for
  `[DBL: ext_dbl.py]` (section `ext_dbl`, cpu 3; checked only) after FCE's: "CAE3540B.SAV loaded, then no input (the
  first unit blinks), in the DOS graphics (`--dump-presented`) and the Windows graphics (`--dump-frames --dump-from
  490`), and EOT.SAV (CAE3540B.SAV with gameOptions |= 4, written by saveedit) with a space per unit to "End of Turn"
  in the DOS graphics: the unit's square (448..512 x 224..288 of the DOS frame) and its small-map square (64..96 x
  64..96) show two pictures that change together, 'End of Turn' (0..160 x 256..288) likewise, every interval 142.68 ms
  within 22 ms after the first cycle, every two 285.35 ms within 22 ms, the mean within 2 ms; the Windows core frames
  change every 440..560 ms; the two unit runs' core frames and final snapshot equal (P0); `EXT_DBL_OK checks 4`
  (`ext-dbl.txt`; about 15 s; the frame dumps are deleted after the checks)".
* **FEATURES.md** the D6e row (about line 231): "the active unit's blink in white" -> "the active unit's blink in white
  at the DOS game's pace (DBL: 10 VGA frames a phase)"; "'End of Turn' blinking" -> "'End of Turn' blinking at the DOS
  pace (DBL)"; tests "`test_pdos_play` (78 checks since DBL ...)" and "`ext_dbl.py` (since DBL: the DOS blinks' period,
  the Windows blink unchanged, P0)".  The D6c row (main map), if it names the blink at the core's pace, likewise.
* **STATUS.md** (the orchestrator): unit DBL staged/landed; the revision list's items 1 and 2 addressed.

## What the user checks

Use the DBL user build with the DOS graphics (Ctrl+Shift+Backspace switches between the two).  "Before" means the
build you had: the DOS graphics then blinked at the Windows game's pace, about once a second.

* **DBL-1** Load a saved game (or start one) and let the game wait for orders: the active unit on the main map blinks
  about three and a half times a second, each half (shown, hidden) about a seventh of a second, clearly faster than
  before and like the real DOS game.  It starts hidden the moment the game starts waiting for the unit, and shows again
  as soon as you press a key or click.
* **DBL-2** At the same time the unit's square on the World Map window blinks white at the same pace, in step with the
  main map: hidden on the main map while white on the World Map, and back.
* **DBL-3** Let a turn end with "End of Turn" waiting (the game option "End of Turn"): "End of Turn" in the unit panel
  of the Status window blinks at the same fast pace (about three and a half times a second).  Pressing Enter goes on
  as before.
* **DBL-4** While a unit blinks, open a menu from the menu bar and keep it open for a few seconds, or move or size the
  map window: the unit stays shown (the World Map square in its land or sea colour, "End of Turn" hidden) while the
  menu is open; when it closes the blink goes on at the fast pace.  Nothing else in the menu or the windows changes.
* **DBL-5** Ctrl+Shift+Backspace to the Windows graphics while a unit blinks: the Windows map, World Map and "End of
  Turn" blink as before, about once a second; back to the DOS graphics: the fast DOS blink again, on the main map at
  map zoom -1, 0 and +1 alike.

The rewritten **D6e-2** (replaces the pending one): It follows the game.  Move a unit, let the game go to the next
unit, scroll the map, found a city: the white frame and the squares follow; the active unit's square blinks white on
the World Map at the DOS game's pace (about three and a half times a second), in step with the unit on the main map.

**D6e-5** (failed on the blink's pace, rework in this unit): its blink part is now DBL-3; the rest of D6e-5 as written.
**D6c-5** (passed 2026-10-16) named "the blinking of the active unit" at the game's pace; since DBL that blink is at the
DOS game's pace (DBL-1); the rest of D6c-5 is unchanged.

## Expected changes at the build slot

On the tree after D7a+D7b, UX5b and D7c (later landings add their own changes):

* **Build**: `build.cmd` unchanged; 299 portable sources (the tree's 298 since D7c + `present\dos\pdos_ublink.c`;
  the overlay's build log prints 299 in all three variants).  `BUILD_OK` in Checked, `checked noobs`, Release.
* **Test counts**: `test_pdos_play` 46 -> 78 checks in Checked, `checked noobs` and Release (the overlay's `unit`
  section in all three variants: every other test's count unchanged).  No other unit test changes.
* **Sections**: 29 -> 30; the new `ext_dbl` (Checked only) prints `EXT_DBL_OK checks 4` (about 15 s; three harness
  runs, cpu 3).  `testpar.py check` passes.
* **Golden changes**: `tests/harness/ext-zoom-golden.txt`, 40 `dos` lines (samples while a unit blinks; staged).  The
  DOS shows in ext_zoom's runs increase (the blink's phase changes are shown between core presents: e.g. `new` 163 ->
  290, `load` 260 -> 458, `orders` 244 -> 383 per run at each size; the `sw` runs 199..318 -> 264..416); the Windows
  shows are unchanged (164, 264, 248) and the `win a`/`win b` sequences still equal (the hidden DOS profile changes
  nothing shown); ext_zoom checks no show count.  No other golden, fixture or reference file changes
  (`present-goldens`, ext_frames, ext_adapt, ext_slots, ext_tld, ext_fce, ext_p0, ext_mirror, ext_replay, ext_timeline,
  ext_continue, ux3_aspect and bs1..bs3 pass unchanged in the overlay; section "Tests").
* **P0**: unchanged.  No core, rt, platform or generated file changes; the core frames and final snapshots of the DOS
  and Windows runs equal each other and the base's (ext_dbl); ext_p0 `P0_OK` in the overlay (Checked 476 checks,
  `checked noobs` 62); G-1 `EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)` in the overlay in Checked and
  `checked noobs`, the baseline and amendment list unchanged (ext_dbl's runs are under `dbl/`, not among G-1's run
  folders).
* **Coverage**: informational; no core or rt function is added or changed.  `checked noobs` in the overlay: `COVERAGE
  files 13; rt entries entered 145 of 155; other functions entered 655`, the tree's line; Checked expected as the
  tree's `COVERAGE files 14; rt entries entered 145 of 155; other functions entered 662` (the overlay's Checked
  sections ran in several batches, so its coverage line was not taken).
* **Docs** (the docs pass; section "For the records"): FIDELITY F133 amended and F-new-1, F191's note, DESIGN 12.7/12.9,
  draft-D 14.6, DOS-PROFILE row 132 (prose; `gen/obs_tables.py --check` after), RUNNING (`test_pdos_play` 78, the
  section count 30, the `ext_dbl` row, 299 portable sources), FEATURES, STATUS and the checklist (the orchestrator).

## Rebase notes

The bases are the tree after D7a+D7b (landed 08:07:35 UTC), UX5b (09:35 UTC) and D7c (10:57 UTC); the files they
changed (`pdos_aplay.c`, `pdos_profile.c` twice, `test.cmd`) were rebased already (the header of this record and
below).  If a base has moved at the build slot, merge per file with
`git merge-file -p <staged> obj/rebase/base/<path> <tree's file>`; every DBL change is an addition in its own block
marked "extension DBL", so a conflict is two units adding at the same place: keep both.  Units landed or staged
meanwhile (the staged ones: trial merges 2026-10-17 about 09:05 UTC under `obj/rebase/trial/` against those units'
staged copies at that time, nothing written outside `dbl-stage`):

* **D7c** landed meanwhile (2026-10-17 10:57 UTC: `pdos_profile.c`'s report rule, `pdos_adapt.c`, `pdos_scn_report`,
  the new `pdos_scn_world.c/.h`, `ext_adapt.py`, `test_pdos_report.c`).  The staged `pdos_profile.c` is rebased onto
  it (`git merge-file`, clean: D7c's change is in the report's input rule, DBL's in `dos_advance` and the header; base
  line and `obj/rebase/base/` updated), the overlay refreshed (0 differences) and rebuilt; the checks after it are in
  "Tests".
* **UX5b** landed meanwhile (2026-10-17 09:35 UTC: `test.cmd`'s `ux3_aspect` comment and echo, `pdos_birth`,
  `pdos_seq`, `pdos_tl.h`, `ext_aspect.py`, `test_pdos_aspect.c`, `test_pdos_seq.c`).  The staged `test.cmd` is
  rebased onto it (`git merge-file`, clean; base line and `obj/rebase/base/test.cmd` updated; `testpar.py check`
  exit 0), the overlay refreshed with UX5b's files (`obj/ovcheck.py`: the overlay equals the tree plus the staged
  files, 0 differences) and rebuilt; the checks after it are in "Tests".
* **D6fS-a** (`pdos_aplay.c`, `pmap_dos.c`, `pmap_inview.c`, `pmap_int.h`): all clean.  D6fS-a removes `def_wnd`'s
  `W16qMenu mn` (its menu popups come from `pdos_reskin_popups_shown`); DBL's `def_modal` has its own `W16qMenu` and
  still asks `w16q_menu_state` (the host's menu tracking, which holds the core's loop), so no change is needed.  If
  D6fS changes how a menu suspends the core's loop, `def_modal` is the one place to follow it.
* **D7d** (`pdos_profile.c`, `pmap_dos.c`): adjacent additions conflict, keep both: `dos_advance` gets D7d's
  `pdos_city_advance(now_us)` and DBL's `pdos_aplay_advance(now_us)` (either order; they touch different state);
  `pmap_dos.c` gets D7d's `city_hooks` prototype and block and DBL's `blink_reset` prototype and blink block.
* **D7j** (`pdos_profile.c`): the same in `dos_advance` with `pdos_palace_advance(now_us)`: keep both.
* `test_pdos_play.c`: if another unit adds checks, the count is 78 plus theirs.

After a merge: build Checked, `checked noobs` and Release, the `unit` section (`test_pdos_play`), `ext_dbl`, and the
sections in "Expected changes at the build slot".  `pmap_dos_blink_apply` must stay before `pmap_dos_present` in
`core_present` and before `pmap_world_update` in `pmap_tick`; `pdos_aplay_advance` must run in `dos_advance` at every
tick whether or not the DOS graphics show (the profile's pace kept across switches, DBL-5).

## Landing (2026-10-17, build slot)

**Landed 2026-10-17 11:50:46 UTC; cycle ALL_GREEN 12:28:57 UTC (first attempt); RELEASE_OK 12:35:29 UTC; user build
`build/user-builds/dbl/` (about 12:36 UTC).**  The orchestrator accepted DBL as staged and gave the build slot on
condition that the copy-in waits for D7c's landing (`build/d7c-status.txt` RELEASE_OK and
`build/user-builds/d7c/WHAT-TO-CHECK.txt`; both present at 11:50:30 UTC, polled every minute, no overlay build
meanwhile).  Scripts and outputs in `build/dbl-prep/` (`mk_prep.py` derived `dbl-cycle.ps1`, `compare.py` and
`mk_userbuild.py` from `build/d7c-prep/`, the cycle with the OK-marker guard per step; `mk_fill.py` derived
`fill_stillopen.py`; `land.py` after D7c's, reading this unit's `BASE-SHA256.txt` and the frozen `staged.sha256`).

1. **Bases and preparation** (11:43..11:50 UTC).  All ten bases were the tree's files (D7c's `pdos_profile.c` already
   in the rebase, section "Rebase notes"); the staged copies frozen in `build/dbl-prep/staged.sha256` (13 files);
   `land.py` dry run DRY_RUN_OK 14; `predictions.txt` written; no build or cycle process of another unit running.
2. **Copy-in** (11:50:46 UTC, `land.py --write`, `land-write.txt`).  Snapshot of the tree's Checked outputs (63 files)
   in `build/dbl-prep/before`, the ten previous tree files in `tree-before`; the fourteen files byte for byte (ten
   changed, three new sources and tests, this record new in its version without this section); `landed.sha256` (15
   lines, with `build.cmd` unchanged `40de571d...`), `landed-at.txt`.  After the cycle the landed files were
   re-verified (14 of 14 equal to `landed.sha256`).
3. **The cycle** (`dbl-cycle.ps1`).  Step 1 `build.cmd checked` 11:50:54..11:56:07 UTC BUILD_OK (313 s; 299 portable
   sources); step 2 `test.cmd checked` 11:56:07..12:28:56 UTC TESTS_OK (1,969 s; TEST_SECTIONS 30, wall 1,967.0 s,
   failed 0; `ext_dbl` 37.0 s); step 3 `ext_g1.py check` EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events):
   **ALL_GREEN**.  Step 4 `build.cmd` (Release) 12:29:10..12:35:29 UTC BUILD_OK (299 portable sources): **RELEASE_OK**.
   Logs `build/dbl-1..4-*.log`, status `build/dbl-status.txt`.
4. **Outputs against the predictions** (`compare.py` against the D7c cycle's outputs, host times left out;
   `compare.txt`): 51 of 65 files equal.  Changed as predicted: `sections/unit.log` (`test_pdos_play` 46 -> 78, 0
   failed; besides, the host-timed OBS_COST line); `ext-dbl.txt` and `sections/ext_dbl.log` new, `EXT_DBL_OK checks 4`
   with the four PASS lines equal to the private run (unit-dos 30 changes, mean 142.663 ms; eot-dos 21, mean 142.656
   ms; unit-win intervals 494.5 .. 547.3 ms; P0 core frames 530 and 530, the same final snapshot);
   `registry-check.txt` (two "ok include rule" lines, `pdos_ublink.c/.h`); `obs-lint.txt` and its section log (files
   128 -> 130); `nodos.txt` (1,770 -> 1,774 files, 0 hits, NODOS_OK); `ext-zoom.txt` (`ZOOM_OK`, the same summary line,
   with the landed golden; the informational show counts of the dos and sw runs, the two s4 lines and the two `mzs
   ... dos` lines grow; the Windows counts unchanged); `ext-p0.txt` (`P0_OK checks 476`; the 19 `V4d ... shows with
   the layer` counts grow); `ext-adapt.txt` (`EXT_ADAPT_OK checks 203`; the seven informational lines named in the
   predictions: zoomkeys-dos 72 -> 126 and ring-dos 151 -> 257 shows, the three f6-zcover views and ticks, the
   f6-zcover-menu layer pixels 7594 -> 7622, d7a-report and d7c-world 21 -> 41 A shows); `ext-frames.txt`
   (`EXT_FRAMES_OK`; s3 688 -> 815 presented lines, 655 -> 782 tick shows); `sections/times.txt` (host times).
   `ext-mirror.txt` unchanged (`MIRROR_OK runs 29`, "p0 equal" as predicted; the private run's "n/a" was the overlay's).
   Not as predicted, explained: `coverage.txt` (and `sections/coverage.log`) "other functions entered" 672 -> 667: an
   informational count (it does not fail) merged from `build/x64/Checked/coverage-*.txt`, to which the parallel
   harness runs append through buffered `fopen(..., "a")` (`tests/headless/host_headless.c` host_coverage); the
   merged `coverage-civ_harness.txt` has interleaved lines (6 of 232,094 not of the form `SSSS:OOOO name`, e.g.
   `T18:0956`), so the count varies between runs (UX5b's landing saw 662 -> 663); P0 and G-1 unchanged.  All other
   outputs equal, including ext-timeline (both groups), ext-continue, ext-slots, ext-tld, ext-fce, ext-aspect, ext-bs,
   ext-replay, scenarios, p4tests, gate3b, uninit, present-goldens, dos-decoded.
5. **User build** `build/user-builds/dbl/` (`fill_stillopen.py dbl`: 76 items still open from the checklist at 12:35
   UTC, D6e-2 left out as this build's own and D7c's seven rows included; `mk_userbuild.py dbl 2026-10-17 12:36
   12:35`): `civ64.exe` (the Release build, 4,469,760 bytes, `2353dea9...`), `CIVWIN.zip` (`058d4e00...`) and
   `civdos.zip` (`0eac32c9...`) from `build/user-builds/d4`, `WHAT-TO-CHECK.txt` (CRLF: DBL-1..DBL-5, the rewritten
   D6e-2, the D6e-5 and D6c-5 notes, the still-open list by build).
6. **This record** copied to `docs/ext-DBL-record.md` with this section (the copy-in's version had none).  No docs pass
   ran between the copy-in and this copy; the joint docs pass for UX5b, D7c and DBL follows ("For the records").  The
   checklist and STATUS.md were not edited.

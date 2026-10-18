# Extension phase M, unit Mb2 (mirror checks, ext_mirror.py, ext_zoom.py, agent UI check, gate) — record

Session Mb2, 2026-10-11 (19:45 to 21:35 UTC). Brief: [verify/BRIEF-m.md](verify/BRIEF-m.md) ("Mb", second
half, as the orchestrator split it after Mb1). Design: [verify/ext-d1-draft-D.md](verify/ext-d1-draft-D.md)
(Revision 3) sections 10, 16.2, 16.3, 19, 21. Earlier units: [ext-Ma-record.md](ext-Ma-record.md),
[ext-Mb1-record.md](ext-Mb1-record.md). The gate record is [ext-M-acceptance.md](ext-M-acceptance.md).

Labels: **compiled** (the three language checks and `/W4 /WX`), **headless** (test programs and the
harness on `build/gamedata`), **Win32-headless** (hidden windows), **agent-observed** (a visible civ64
window driven and looked at by this agent; not user acceptance). No DOS program was executed; nothing
was written to `C:\Projects\Civ1RE\dos` or `build/dosdata`. Asan was not built or run (deferred by the
user).

## What was built

* **`present/map/pmap_check.c`** (new, draft D 3's table, 10.1): the mirror checks of `--mirror 1`,
  run from the map listener (`pmap_on_probe` calls `pmap_check_probe` first; nothing while off):
  * **key** at `TileCacheLookup` 1110:030C entry when its return address is DrawMapTile's call
    (1110:0579) inside a DrawMapTile entry..exit: the key argument against `mw_key(pmap_src_live(),
    x, y)` of the enclosing DrawMapTile's square (its entry arguments);
  * **render** at `TileCacheInsert` 1110:01A3 entry from DrawMapTile (1110:05B8): the shape block the
    core rendered (`TileNew(32, 32)`: width, height and 1,024 pixels through `w16q_block`/`w16q_read`)
    against `mw_render_key(key, terrain)`, the rules' shapes loaded first (`mw_res_load`);
  * **settled** at the exits of `DrawTilesToPort` 1208:1866 (the map window into the map port, modes 0
    and 1) and `RedrawMapRect` 1208:1534 (the map window): the port bitmap (12D8:455C) at the entry is
    copied; at the exit it is redrawn by the rules in the core's own order and compared, pixel for
    pixel, with the bitmap the core left. Mode 0: the squares of `GetVisibleTileRange` 1208:1D21
    column-major, clipped by the window data's `clientRect`, each `RedrawMapSquare` at
    `RestoreBlockXY` 1110:0448's position (unclipped but by the bitmap) or `FillRect BLACK_BRUSH`,
    then `DrawCityLabels(&window->rect)`. RedrawMapRect: its first/end columns and rows, the update
    rectangle grown and clipped as compiled, `EraseRect` with `g_hEraseBrush` 1420:995E (the
    squares' rectangles without the scroll, as compiled), then `DrawCityLabels(&updateRect)`. Mode 1
    (the dissolve): the order of the call's own `RedrawMapSquare`, `DrawUnit` and `DrawCityLabels`
    entries (below), so no random number is read or drawn. The labels by the core's policy
    (`CollectVisibleCityLabels` 1208:1DD7: the 32-label cap, column-major order, the top row clamped
    without moving the pixel origin; `DrawCityLabels` 1208:1F64: whole labels whose box meets the
    rectangle). Mode 2 and other modes draw nothing into the port and are not checked.
  * `mirror.log` lines as draft D 10.2, the coverage in the end line (distinct key and terrain pairs,
    unit marks and city states the settled checks drew).
* **`pmap_win.c`**: `mw_square_clip(src, x, y, dst, ox, oy, clip, parts)` (the core's unclipped square:
  the stack shadow's 2-pixel overhang; `MW_PART_TILE` DrawMapTile's part, `MW_PART_UNIT` the unit);
  `mw_square` is `mw_square_clip` with the cell and both parts (the ring unchanged); the fog edges
  test `city_mode` (DrawMapTile 1110:065B `g_cityScreenMapMode == 0`).
* **`pmap.h`**: `PmapSrc.city_mode` (live: `g_cityScreenMapMode` 1330:0000; a snapshot takes 0, Mb1's
  rule), `pmap_mirror_start`, `pmap_mirror_end` (stubs under `CIV_OBSERVER 0`).
* **`pmap_world.c`**: the canvas notices a shape reload made by another caller (`pmap_g.n_world_res`),
  since the render and settled checks load the shapes at level 0 too.
* **The harness**: `--mirror 1` (`--mirror 2` refused: D6's; `--mirror` refused under `CIV_OBSERVER
  0`), `mirror.log` in the output directory, the end line at the run's end.
* **`tests/harness/ext_mirror.py`** (16.2) and **`tests/harness/ext_zoom.py`** (16.3) with the goldens
  **`tests/harness/ext-zoom-golden.txt`**; both in `test.cmd checked` after `ext_adapt.py`.

## Mirror findings

Every mismatch is recorded with its cause (brief: a mismatch is a real finding; no check was weakened).

| # | Run, check | What | Cause | Fix |
|---|---|---|---|---|
| 1 | gate3b S3 (development run), the first settled check (DrawTilesToPort mode 1 at 37.6 s, the dissolve at the game's start) | 9,216 pixels: the nine seen squares around the first settler were black in the replay, the core's tiles in the port | **the check**, not the rules: with `g_autoFlushToWindow` 1 (mode 1) DrawMapTile's flush 1110:0CF1 calls `DrawCityLabels(&rc)` for its square; the first replay took every DrawCityLabels entry for an erased square (EraseRect first), so it erased the squares just drawn | `pmap_check.c` records the dissolve's operations by kind: `DrawCityLabels` from 1208:1B66 (return address 1208:1B69) erases then labels, from DrawMapTile's flush only labels, and the unit (DrawUnit's entry) follows those labels, as RedrawMapSquare draws it after RestoreBlockXY. `mw_square_clip` gained the `parts` argument for that split |

After the fix, **no mismatch** in any run: the rules of `pmap_win.c` (Mb1) equal the core's own
drawing for every checked key, rendered tile and settled port. **No renderer fix was needed** in
`pmap_win.c` or `pmap_world.c`.

Development run (2026-10-11, about 20:13 UTC, Checked, `ext_mirror.py -j 8`, 29 runs): MIRROR_OK,
**8,240 checks: key 6,925, render 1,229, settled 86, mismatches 0**; every run's core trace equal to
its reference (ext_p0's V0 output; for S4 and S5 uninit.py's runs: frame lines and `events.log`).
The settled checks: 78 at DrawTilesToPort mode 1 (the dissolve of a new map view: 3,858 squares
drawn by RedrawMapSquare in the core's shuffled order, erased squares, labels), 8 at mode 0; 61 of
the 86 drew a city label (at most one label per view in these scenarios); RedrawMapRect was reached
by no run (as in Ma: no scenario scrolls the map window by a strip). Coverage over the runs: at
most 65 distinct key and terrain pairs per run (S4; the tile cache's misses), 7 unit-mark
combinations and 2 city-state combinations (S4). The S4 soak: 1,887 checks (key 1,807, render 65,
settled 15); S5: 1,359 (1,337, 11, 11). Runs without the map (start, birth, fame-quit): no check, as
10.2 allows.

## Builds and tests

Final cycle, 2026-10-11 (UTC), every step green, once, in this order (logs `build/mb2-*.log`, times
`build/mb2-cycle-times.txt`; the runners' outputs `build/test/<variant>/ext-mirror.txt`,
`ext-zoom.txt`, `ext-p0.txt`):

| Step | Time (UTC) | Result |
|---|---|---|
| `build.cmd checked` | 20:31:13..20:34:21 | compiled: BUILD_OK (portable sources 254, c11/c17/c99 parse) |
| `test.cmd checked` | 20:34:21..21:03:17 | TESTS_OK: test_map PASS 127 checks, test_host_win32 196, test_input 140, test_observer 103, NODOS_OK, REGISTRY_OK, GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK, P4_TESTS_OK, OBS_TABLES_OK probes 203 sites 98, OBS_LINT_OK files 44, **P0_OK checks 279**, EXT_FRAMES_OK, EXT_ADAPT_OK checks 20, **MIRROR_OK runs 29**, **ZOOM_OK combinations 32 runs 64 samples 388**, TRACE_OK |
| `ext_g1.py check` | 21:03:17 | **EXT_G1_OK runs 77** |
| `build.cmd checked noobs` | 21:03:17..21:06:21 | BUILD_OK variant=CheckedNoObs |
| `test.cmd checked noobs` | 21:06:21..21:18:26 | TESTS_OK: test_map PASS 1 check (the refusal), test_host_win32 194, test_input 122, test_observer 1, P0_OK checks 56, the rest as Checked's base tests |
| `ext_g1.py check --variant CheckedNoObs` | 21:18:27 | **EXT_G1_OK runs 77** |
| (informational) the CheckedNoObs harness with `--mirror 1` | 21:18:27 | exit 2, `harness: --mirror: not in this build (CIV_OBSERVER 0)` |
| `build.cmd` (Release) | 21:18:27..21:21:26 | BUILD_OK variant=Release |
| `test.cmd` (Release) | 21:21:26..21:27:11 | TESTS_OK: test_map PASS 127 checks, test_host_win32 196, test_input 140, test_observer 92, NODOS_OK, OBS_LINT_OK files 44, TRACE_OK |

`ext_mirror.py` in the final Checked run: 29 runs (the 23 rows of scenarios.py, gate3b's S2, S2b, S2c,
S3, the soaks S4 and S5), **8,240 checks (key 6,925, render 1,229, settled 86), mismatches 0**, every
run's core trace equal to its reference (29 of 29: V0 for the 27 P0 runs, uninit.py's runs for S4 and
S5) — the same counts as the development run (the checks are deterministic).

`ext_zoom.py` in the final Checked run: 32 combinations (new, load and orders at 640x480, 1280x960,
1920x1440 `integer`, 2560x1600 `fit` sharp and 1366x768 `fit` nearest; S4 at 1920x1440; levels -1
and +1), each run twice: the two runs' zoomed shows equal in every combination (determinism, Z-2 and
7.4), the layer drawn in every run (164 to 3,686 zoomed shows per run), no `zoom refused` line, and
all **388 samples equal to the goldens** `tests/harness/ext-zoom-golden.txt` (written by
`ext_zoom.py --update` in the development run of 20:21..20:30 UTC after the same determinism check;
354 distinct hashes). The full zoom run takes about 9 minutes of wall time with 8 jobs.

`test_map`'s cost lines (Release, informational): 1920x1440 `integer` full render 10.8 / 9.9 ms at
-1 / +1, palette reconversion 1.1 / 1.2 ms; 3840x2160 20.1 / 15.7 ms; 2560x1600 `fit` sharp 39.2 /
23.1 ms with reconversion 39.3 / 24.1 ms (Ma's figures; machine load varies).

## The agent UI check

**Not done** beyond the start: on 2026-10-11 at about 21:23 UTC civ64.exe (the final Release build) was
started visibly with `--data build\ext-m-ui\data` (a copy of `build/gamedata` without the `.wav`
files, so that it made no sound), `--dos-data none --window 1920x1440 --scale-mode integer`, and the
computer-use access to that civ64.exe was granted. The first screenshot shows the window with the
title menu (saved, cropped to the civ64 window: `build/ext-m-ui/01-title-menu-civ64-window.png`). The
first input batch (selecting "Load a Saved Game") was stopped by a **user interrupt** before any action
ran ("Batch aborted after 0 of 5 actions (user interrupt)"). Taking that as the user's stop, the check
was not retried: civ64 was ended at once (taskkill of the process this unit had started; its close
button is disabled by design) and `%LOCALAPPDATA%\civ64\civ64.cfg` was compared with the copy made
before the start: unchanged. So zoom -1/0/+1 by chord and by wheel, the system-menu zoom items and the
ring click at -1 were **not exercised in a visible window** by this unit; they are covered headless and
Win32-headless only (Ma's `test_host_win32` zoom items and `--zoom` parse, `ext_adapt.py`'s zoomkeys
and ring runs, `ext_p0.py` V4, `ext_zoom.py`). The visible check moves to the user's pending checks
(M-1, M-2 and Ma's added items).

## Deviations from the design

| Design | What | Why |
|---|---|---|
| D 10.1 settled ("the port bitmap over the redrawn rectangle with the world-canvas rules applied to that view") | the port bitmap is copied at the call's entry and redrawn by the rules in the core's own order (squares unclipped but by the bitmap, black or EraseRect fills, labels by the core's policy); the whole bitmap is compared, so a pixel the core changed that the replay does not, or the reverse, is a mismatch | the core's squares overlap (the stack shadow's 2-pixel overhang into the next squares; whole labels over earlier squares), so the final pixels depend on the order; comparing the whole bitmap also proves the core drew nothing else into the port during the call |
| D 10.1 settled at DrawTilesToPort "any mode" | modes 0 and 1 are checked; mode 2 (a blit) and other modes draw nothing into the port and are not counted; only the map window into the map port | nothing to compare in mode 2; the map port is the ring's source |
| D 10.1 settled, mode 1 (the dissolve) | the order of the call's operations is taken from its own RedrawMapSquare, DrawUnit and DrawCityLabels entries (the erased squares' labels by the return address 1208:1B69, DrawMapTile's flush labels before the unit) | the shuffled table comes from the shared RNG, which the presentation must never read or draw (P0) |
| D 10.2 (`mirror.log` lines for every check) | settled checks always write a line (with ` call NAME mode M ops N squares S labels L` appended); key and render checks only on a mismatch (counted always); at most 2,000 mismatch lines; the end line adds `key K render R settled S mismatched k r s keys D units U cities C` after `unexplained 0` | key checks run at every DrawMapTile (hundreds of thousands in a long run); the end line carries the coverage ext_mirror.py prints |
| D 10.2 (`--mirror 2`) | refused with exit 2 (D6's, with the present check and the model shadows) | M's gate is `--mirror 1` (C2) |
| D 7.2 (`PmapSrc`) | `city_mode` (`g_cityScreenMapMode`, live only; a snapshot takes 0) | the settled check reproduces DrawMapTile's fog-edge rule and DrawTilesToPort's visibility test exactly in the city-screen mode; the ring keeps Mb1's rule |
| D 7.3 (`mw_square`) | `mw_square_clip(..., clip, parts)`: the core's unclipped square and the split into DrawMapTile's part and the unit; `mw_square` is the cell-clipped call of both | the settled check draws as the core does; the ring's canvas is unchanged |
| D 7.4 (the canvas reloads the shapes) | the canvas also re-renders when another caller loaded changed shapes (`n_world_res`) | the render and settled checks load the shapes at level 0 too |
| D 16.3 (scenario "input") | `orders` (scenarios.py has no row named input; orders moves units by keyboard input over the map) | the nearest row with moves on the map |
| D 16.3 (S4 at every named size) | S4 at 1920x1440 (the user's case) only, both levels; new, load and orders at all five sizes | a zoomed S4 run takes about 9 minutes of wall time; the full matrix would add about 40 minutes to `test.cmd checked` |
| D 16.3 ("view_sha256 at listed virtual times") | every 5,000 ms of virtual time to the run's last zoomed show, the hash of the last zoomed show at or before it; determinism over every zoomed show of the two runs | a fixed rule instead of a hand-made list |
| D 19 ("5.8 not zoomed": the small map's pixels equal level 0's) | not built in `ext_zoom.py` | budget; the small map is outside the layer by construction (5.2), and V4 shows the core frames unchanged |
| -- (`ext_mirror.py`) | also compares every run's core trace with ext_p0.py's V0 output and the soaks' with uninit.py's runs | P0: the checks change no frame, checkpoint or event |

## For the records

The orchestrator applies these; Mb2 did not edit the files.

* **DESIGN.md 12.9** ("As implemented (M)", Mb2's part): `pmap_check.c` (the three checks, their call
  points and return addresses, the settled replay from the entry copy in the core's order, mode 1's
  recorded order, modes not checked), `mirror.log`, `mw_square_clip`/`parts`, `PmapSrc.city_mode`, the
  canvas noticing reloads; the findings (one check fix, no renderer fix); the deviations above.
* **DESIGN.md 12.5** ("Tests"): `ext_mirror.py` and `ext_zoom.py` in `test.cmd checked`.
* **DESIGN.md 12.10**: no w16 change in Mb2.
* **DESIGN.md 12.11** (P0): the mirror checks run in the map listener, read through `w16q_*` and draw
  only on their own memory; `ext_mirror.py`'s core-trace equality in all 29 runs; G-1 and V4 results
  of the final cycle.
* **FIDELITY.md**: F132: the ring's Windows rules (squares, units, the label drawing) equal the core's
  own drawing wherever the settled check ran (all scenarios and S2..S5, no mismatch); no new
  difference. The label policy differences recorded by Mb1 (no 32-label cap, world order) stay.
* **RUNNING.md**: the harness's `--mirror 1` (`--mirror 2` refused: D6; refused under `CIV_OBSERVER
  0`), `mirror.log`'s lines; `ext_mirror.py` (MIRROR_OK, `build/test/Checked/ext-mirror.txt`) and
  `ext_zoom.py` (`--update`, ZOOM_OK, `build/test/Checked/ext-zoom.txt`, the goldens
  `tests/harness/ext-zoom-golden.txt`) in `test.cmd checked`; the runner tables.
* **FEATURES.md**: none.
* **STATUS.md** (extension track): Mb2 and phase M complete (gate record `ext-M-acceptance.md`);
  Asan deferred; next: unit M+W (BRIEF-m.md), then the queue.
* **manual-checklist-ext.md** M: M-1 and M-2 stay pending (user); the agent UI check's result is in
  the gate record (not user acceptance).
* **The D1 drafts (draft D)**: 10.1's settled method and modes, 10.2's line rules and end-line fields,
  7.2's `city_mode`, 16.3's `orders`, the soak size and the sample rule, 19's "not zoomed" check not
  built; Open D5 (M2) and D2 stay open for D6.

## Not verified

* **The visible civ64 window** with the zoom: the agent UI check stopped at the title menu (above);
  the chords, the wheel, the menu items and the ring click in a real window are the user's pending
  checks.
* **RedrawMapRect's settled check** ran in no run: no scenario scrolls the map window by a strip (Ma's
  note: no run's path calls RedrawMapRect). Its replay (the update rectangle, EraseRect with the erase
  brush, the unscrolled square rectangles) is unexercised.
* **Label policy depth**: the settled checks drew at most one city label per view; the 32-label cap,
  the duplicate test and the row quirk (a view above the north pole) were not reached. The city-screen
  map mode (`city_mode` 1) was not reached by a checked DrawTilesToPort either.
* **Coverage** is what the scenarios reach: at most 65 distinct key and terrain pairs per run, 7 unit
  mark and 2 city-state combinations; rare keys (rivers into every coast pattern, every road link, all
  improvements), rare unit marks and city states (disorder, walls) were not all seen by a check. The
  rules tests of `test_map` (Mb1) cover the key bits on synthetic snapshots.
* **The ring itself** is proven only through the rules it shares with the checked squares; the
  canvas's update logic (dirty squares, label spans, wrap) has no pixel check against a fresh full
  render (`ext_zoom.py`'s goldens pin it, they do not prove it).
* **`--mirror 2`** (the present check, the model shadows) and the dos-settled check: D6.
* **19's "not zoomed"** (the small map's pixels at a zoom level equal level 0's): not built.
* **ext_zoom's profile-switch half** (16.3): D6.
* **Asan**: deferred by the user; not built or run.

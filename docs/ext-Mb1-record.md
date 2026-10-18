# Extension phase M, unit Mb1 (snapshots, the Windows rules, the world canvas, the ring) — record

Session Mb1, 2026-10-11 (18:08 to 19:45 UTC). Brief: [verify/BRIEF-m.md](verify/BRIEF-m.md)
("Mb"), split by the orchestrator into **Mb1** (this unit: draft D 7.1..7.4 and 8, the ring at level
-1 replacing Ma's black interim, the rules tests of 16.1, Open D4) and **Mb2** (the mirror checks of 10,
`pmap_check.c`, `ext_mirror.py`, `ext_zoom.py`, the agent UI check, the gate record). Design:
[verify/ext-d1-draft-D.md](verify/ext-d1-draft-D.md) (Revision 3) sections 7, 8, 16.1, 17 (A-7) and
18; Ma's record: [ext-Ma-record.md](ext-Ma-record.md) ("Seams for Mb"). The rules come from the port's
reviewed translation in `claude/src/c` (segmented addresses cited in the code).

Labels: **compiled** (the three language checks and `/W4 /WX`), **headless** (test programs and the
harness on `build/gamedata`), **Win32-headless** (hidden windows). No DOS program was executed;
nothing was written to `C:\Projects\Civ1RE\dos` or `build/dosdata`; no visible window was shown;
civ64.exe was not started. Asan was not built or run (deferred by the user).

## What was built

Four new files in `present/map/` (draft D 3's table), the hookup in three of Ma's files and one line
in `present.c`:

* **`pmap_snap.c`** — the state snapshot (7.1). One presentation-owned `PmapSnap` (about 98 KB): the
  320x200 layered map through `g_lpScreenBuffer`'s far pointer (1420:B394), `g_tileVisibility` with the
  byte before and after (13E8:0009..13E8:0FAA), `g_units`, `g_cities`, `g_cityNames`, `g_humanPlayer`,
  `g_revealAll`, `g_mapDrawMode`, `g_mapViewerCivMask`, the map seed `g_randomSeed` 13C0:0000 (not the
  generator's `g_randSeed` 1420:4EE0, which is never read), and the rule tables (deviation 1). Copied
  with `w16q_read` at every trigger, whatever the level (7.1 "Choice"); `gen` increments. The triggers
  (dispatched by `pmap_on_probe`, `pmap_inview.c`): DrawTilesToPort 1208:1866 X (the map port,
  `g_cityScreenMapMode` 0; also the view), RedrawMapRect 1208:1534 X (the map window port; also the
  view), UpdateUnitSightAndContacts 11C0:0395 X, DeleteUnit 11C0:16A4 X, ProcessGameTurn 1088:0000 E,
  BlinkActiveUnitUntilInput 11C0:0EC2 E. Counters for Open D4 (below).
* **`pmap_state.c`** — `PmapSrc` (7.2): `pmap_src_snap` over a snapshot and `pmap_src_live` over the
  emulation through `w16q_*` (inside the guard only; for Mb2's key check). `px` outside 320x200 is 0
  as GetScreenBufferPixel 11E8:0DCF returns it; other out-of-range reads give 0 or a zero record and
  count `map_bad_read`. `pmap_src_current()` (exported in `pmap.h`, RV2-6) reads the latest snapshot,
  never NULL (all zero before the first trigger).
* **`pmap_win.c`** — the Windows rules (7.3), pure functions of a `PmapSrc` and of the shapes:
  `mw_terrain`/`mw_known`/`mw_real` (1110:16C0, 1110:19E0, 1110:199B), `mw_special` (1110:1C72),
  `mw_hut` (1110:1CD9), `mw_key` (ComputeTileAppearanceKey 1118:04B4, every bit, the scans' wrap and row
  rules as the translation states them), `mw_render_key` (RenderTileFromKey 1118:0000 with CopyTile
  11A8:0328 and OverlayTile 11A8:076F, including its fast path that never processes the last pixel and
  colour 0 = the source's top-left pixel), `mw_city_at` (FindCityAt 11C8:00C4), `mw_unit_at`
  (FindUnitAtTile 1110:180E without its repair write), `mw_best_defender` (FindBestDefenderInStack
  11C0:1A2C / RateDefenderCallback 11C0:1A81 with 16-bit products and the 10-member cap of
  ForEachUnitInStack 11C0:1EE8), `mw_top_unit` (RedrawMapSquare 1110:1461, DrawUnitStack 1110:1516,
  DrawUnit's carried-unit rule 1110:0ECE), `mw_square` (DrawMapTile 1110:04D0 without the flush: the
  tile, the fog edges with the unchecked row, the city marker — frame, light fill, the 2-pixel white and
  dark pens through `w16q_draw_on`, sprite 28, the size in the CIV font of id 8 or the disorder shape,
  the inner frame, walls — then the unit: stack shadow, the grey sentry copy, sprite 29, "F", "G", the
  work letters through DrawScreenTextWithShadow 10D8:02DF's rule, the grey frame of the opaque bounds
  11A8:00FE) and `mw_label` (DrawCityLabels 1208:1F64 / DrawTextInRect 1098:0ED1: box (x-134, y+32,
  x+166, y+52), centred, black shadow). `mw_res_load` copies the 638 shapes of the nine handle tables
  through `w16q_block`/`w16q_read` and maps the colours (GetColorIndexRGB 1098:01B0 through the map port
  DC's palette, `W16Q_OP_COLOR`) inside the guard; it reloads only when a handle, a block size, a
  colour table, the font or a text colour's physical index changed.
* **`pmap_world.c`** — the world canvas `G_win` (7.4): 2560x1600 indices, `calloc` at first need
  (failure: the ring black, `map_no_memory`). `pmap_world_update` (inside the guard: the tick and every
  core present; level -1 only) recomputes the 4000 `MapSqDesc` descriptors when the snapshot's `gen`
  changed (unseen: black as DrawTilesToPort mode 0; key, terrain, fog bits, the city marker's inputs
  with the bevel pen's physical index, the top unit's inputs), renders the changed squares into their
  cells, then the labels over them clipped to them, and damages the layer at every copy of each changed
  square (`pmap_layer_damage_world`, or `_all` above 512 squares). Labels: every city the core would
  label, no 32-label cap, world column-major order, east-west wrap, each label's span measured with its
  text (a changed, added or removed label re-renders the squares under its old and new spans).
  `pmap_ring_px` (moved here from `pmap_layer.c`) reads the canvas: **the ring at -1 replaces Ma's
  black interim**.
* **The view snapshot (8)** stays where Ma put it (`take_view` in `pmap_inview.c`), now taken together
  with the state snapshot; `pmap_view_current` is unchanged.
* **Hookup**: `pmap_on_probe` (the triggers), `pmap_on_core_present` (the canvas update first),
  `pmap_tick` (new, `pmap.h`; called by `present_tick` as step 3a, inside the tick's guard, before the
  sample hook and step 5), `pmap_pending` (also 1 while the canvas is behind the snapshot at -1, so the
  tick shows), `pmap_reset` (frees the canvas and the shapes, zeroes the snapshot), `pmap_diag` (new
  fields, below; its buffer 1024 bytes). `CIV_OBSERVER 0` stubs: `pmap_tick`, `pmap_src_current`.

`pmap_diag`'s new fields: `map_no_memory`, `snaps`, `snap_us`, `turns`, `sight_turn_max`,
`snap_turn_max`, `snap_turn_max_us`, `world_updates`, `world_squares`, `world_res`, `world_us`,
`world_max_us` (the `_us` fields are host wall-clock time from C11 `timespec_get`, informational;
`presentation-diag.log` is parsed, never compared).

## Builds and tests

Final cycle, 2026-10-11 (UTC), every step green, once, in this order (logs `build/mb1-*.log`):

| Step | Start | Result |
|---|---|---|
| `build.cmd checked` | 18:56:52 | BUILD_OK (portable sources 253, c11/c17/c99 parse) |
| `test.cmd checked` | 19:00:34 .. 19:20:51 | TESTS_OK: test_map PASS **127 checks** (Ma's 96 + 31 rules checks), NODOS_OK, GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK, P4_TESTS_OK, OBS_TABLES_OK probes 203 sites 98, OBS_LINT_OK files 43, **P0_OK checks 279**, EXT_FRAMES_OK, EXT_ADAPT_OK checks 20, TRACE_OK |
| `ext_g1.py check` | 19:21:15 | EXT_G1_OK runs 77 |
| `build.cmd checked noobs` | 19:21:28 | BUILD_OK variant=CheckedNoObs |
| `test.cmd checked noobs` | 19:24:23 .. 19:35:49 | TESTS_OK: test_map PASS (1 check, the refusal), P0_OK checks 56, the rest as Checked |
| `ext_g1.py check --variant CheckedNoObs` | 19:35:49 | EXT_G1_OK runs 77 |
| `build.cmd` (Release) | 19:35:59 | BUILD_OK variant=Release |
| `test.cmd` (Release) | 19:38:56 .. 19:44:43 | TESTS_OK: test_map PASS 127 checks, NODOS_OK, OBS_LINT_OK, TRACE_OK |

`test_map`'s new `rules()` (16.1, the last items), on synthetic snapshots (`PmapSnap` +
`pmap_src_snap`): the key bits — open ocean (bit 30 only), the whole-tile coast pattern (mask 0x1C ->
pattern 1), the 9-bit circular coast mask, a river mouth with the land bit, the row beyond the pole
not counted as land, the river index with the 0x10 variant bit, the grassland mask and shield, road
and railroad links (rail link and road-only link), mine/pollution/fortress and irrigation, draw mode 1
dropping mine and irrigation, the special resource and the hut by the seed (rows 2..47, an entered
hut, no hut at sea); the visibility reads at -1 and 4000 (the bytes around the array) and the fog
edges drawn at both poles from them (`mw_square` with synthetic edge shapes in `pmap_res`); the top
unit — rating ties to the first of the ring, veteran and fortified wins, the 10-member cap, the ship of
a stack at sea, an unseen foreign unit, a city hiding units; the ring black before the canvas.

Development runs (Checked, not part of the record's gate): the S3 ring scenario of `ext_adapt.py` at
`--zoom -1` with `--dump-presented` (1920x1440), and the S4 save at -1 (1280x960, frame 144): the ring
shows the explored world; a full-resolution crop across the view's bottom edge showed no seam.

## P0

* **V4 still equal to V0, now with the ring drawn**: `ext_p0.py` (P0_OK checks 279, Checked) runs V4's
  27 runs (zoom +1, -1, reset, 0 every 1,301 ms at 1920x1440) against V0; all 27 V4 runs updated the
  world canvas (242 canvas updates, 264,076 squares rendered in all, from their `presentation-diag.log`),
  so the ring's snapshots, rules and canvas ran under the comparison.
* **G-1**: EXT_G1_OK runs 77 on Checked and on CheckedNoObs (the snapshot copies run at every trigger
  in every Checked run, whatever the level).
* **The sentinel** (Checked): every snapshot copy and every canvas update ran inside the guard
  (probe, tick, core present) with no O4 fault in any run of the cycle.
* **Reads only**: `present/map` reads the emulation only through `w16q_rd*`, `w16q_read`, `w16q_strn`,
  `w16q_block`, `w16q_dc`, `w16q_font` and draws only on presentation memory with `w16q_draw_on`
  (COLOR, LINE, TEXTOUT); no w16 API, no handle, no write, no random number; `g_randSeed` (1420:4EE0)
  is never read (OBS_LINT_OK; the map seed `g_randomSeed` 13C0:0000 is a different variable).
* **CheckedNoObs**: the new files compile to nothing; `pmap_tick` and `pmap_src_current` are stubs;
  P0_OK checks 56 (the refusals).

## Measured costs against draft D 18 and Open D4

Soak S4 (`soak.script`, CAE3540B.SAV, Space/Enter every 500 ms until the human civ is destroyed at
392.5 s virtual, 92 turns), `--host-size 1920x1440 --zoom -1`, the **Checked** harness (`/O2` with the
checks; the Release variant builds no `civ_harness.exe`), 2026-10-11 about 19:00 UTC:

| Item | Draft D 18 | Measured |
|---|---|---|
| Snapshot copy | ~92 KB, 5 to 8 µs | ~98 KB; 4,433 copies in 323.9 ms: **73 µs** each (`w16q_read` per tile, not `memcpy`) |
| Snapshots per AI turn (Open D4) | "up to a few thousand" UpdateUnitSightAndContacts (estimate), ≤ ~16 ms | at most **62** sight updates and **67** copies in one turn; at most **5.0 ms** of copying per turn (4.9 to 5.5 ms over three runs) |
| World canvas, first render | 5 to 10 ms | at most **2.0 ms** per update (the first, 4,000 squares, most unseen) |
| World canvas, later | changed squares | 1,611 updates re-rendered 12,228 squares in total (4,000 of them the first); 162 ms in all, 0.1 ms per update on average; the shapes loaded 3 times |
| Canvas memory | 4 MB (+ 1 MB DOS, D6) | 4,096,000 bytes, at the first update at -1; shapes about 0.6 MB |

**Open D4 answered**: in S4 the AI turns call UpdateUnitSightAndContacts at most 62 times per turn (not
thousands), so copying at every trigger costs at most about 5 ms per turn on this machine although
each copy costs about ten times the estimate. The choice of 7.1 (copy at every trigger in every run)
stands. A cheaper copy (the screen buffer's map rows only, or a `memcpy` path in `w16q_read`) is
possible but not needed.

## Deviations from the design

| Design | What | Why |
|---|---|---|
| D 7.1 / 7.2 (`PmapSnap`, `PmapSrc` fields) | the snapshot and the reader also carry the rule tables `g_terrainByMapColor` (as 256 words: GetTerrainType indexes it by the pixel), `g_dirDX`/`g_dirDY`, `g_unitTypes`, `g_terrainTypes`, and `PmapSrc` carries `gen` | the rules need them; the design says "read once", but a load replaces the unit types, and copying them with the state keeps the ring a function of one snapshot |
| D 7.3 (shapes read through handles at drawing) | the shapes are copied into presentation memory by `mw_res_load` inside the guard (at the canvas update), keyed by the handle tables and block sizes | the layer's show can run outside the guard (Ma's rule: the entries reachable from the window procedure read only the module's state); a shape whose bytes change under the same handle and size would not be seen (none known) |
| D 7.4 ("update at a show that needs ring pixels") | the update runs at the tick (`pmap_tick`, new, step 3a of `present_tick`) and at every core present, at level -1 only; `pmap_pending` asks for a tick while the canvas is behind | both are inside the guard and precede the overlay; a show from the window procedure (a resize, a switch) uses the canvas as it is, and the next tick brings it up to date |
| D 7.4 (`MapSqDesc`) | the city marker's descriptor also holds the bevel pen's physical index; the resources' key holds the text colours' physical indices, not their RGB | the dark civ colours can be animated god-palette entries: keying on their RGB reloaded everything at every update (measured: 15 of 30 updates in the S3 ring run before the change, 4 of 19 after) |
| D 7.3 (DrawMapTile's FindCityAt -1, DrawUnitStack's broken ring) | a known city bit without a city draws no marker; a ring walk that reaches -1 draws no unit | the core reads `g_cities[-1]` / `g_units[civ][-1]` there; recorded, not reproduced |
| D 7.3 (GetColorIndexRGB index 10) | index 10 maps as RGB 0 | the core returns an uninitialised local; no rule uses index 10 unless a table holds it |
| D 7.3 (the city-screen map) | the ring takes `g_cityScreenMapMode` as 0 (the main map's rules: unseen squares black, fog edges) | the ring is the main map's surroundings; ProcessCity's temporary mode is excluded from the view triggers already |
| D 7.3 (text alignment and colour) | TextOut is taken as TA_LEFT \| TA_TOP (DrawTextInRect sets 0 on the port DC); `g_monochromeMode` is read and its three effects (city sprite, both text shadows) applied | the port DC's alignment is not read per draw |
| D 7.4 (labels) | a label's span includes its measured text and shadow when wider than the 300-pixel box | a name wider than the box would otherwise leave stale pixels |
| D 8 (the view snapshot in `pmap_snap.c`) | `take_view` stays in `pmap_inview.c` (Ma) and is called with the state snapshot | no behaviour change; avoids moving reviewed code |
| D 18 (snapshot ~5 to 8 µs) | ~73 µs per copy | `w16q_read`'s per-tile path; the per-turn total stays under the estimate (Open D4 above) |

## Seams for Mb2

* **Key check (10.1)**: `pmap_src_live()` (inside the guard, at a probe) and `mw_key(src, x, y)`;
  compare with the core's key at `TileCacheLookup`'s entry (A-7's probe 1110:030C, arguments
  `appearanceKey`, `terrainType`), which `pmap_on_probe` receives and ignores today.
* **Render check (10.1)**: `mw_square(src, x, y, &surf, ox, oy)` draws one square (tile, fog, marker,
  unit) into any 8-bit `W16Surf`; `mw_render_key` the tile alone; `mw_label` one label. The world canvas
  (`pmap_ring_px`, `pmap_world_update`) and `M` (`pmap_m_px`, Ma) are the two sides of the settled
  check; the canvas is valid at -1 only (`pmap_world_update` returns at other levels: Mb2's checks may
  need a variant that updates at every level, or run at -1).
* **Snapshot generation**: `pmap_snap_latest()->gen`, `pmap_src_current()->gen`, and the counters in
  `pmap_diag` (`snaps`, `world_updates`, `world_squares`, `world_res`).
* **For `ext_zoom.py`**: the view hashes at -1 now include the ring (the goldens can be made now);
  `profiles.log`'s `map windows` hash still lags one render (Ma's review finding 11).
* **Test seams**: `PmapSnap` + `pmap_src_snap` for synthetic states; `pmap_res` (extern) can be set by
  a test with synthetic shapes (`test_map.c` does for the fog edges).

## For the records

The orchestrator applies these; Mb1 did not edit the files.

* **DESIGN.md 12.9** ("As implemented (M)", Mb1's part): the snapshot (fields, triggers, every run),
  `PmapSrc` (snapshot and live), the rules in `pmap_win.c` with their sources, the world canvas
  (descriptors, labels without the cap, wrap, cell clipping, damage), the ring at -1, the update at the
  tick (step 3a) and the core presents, `pmap_pending`'s stale canvas, the measured costs and Open D4's
  answer; the deviations above.
* **DESIGN.md 12.5** (the tick): step 3a `pmap_tick()` before the sample hook.
* **DESIGN.md 12.10**: no w16 change in Mb1.
* **DESIGN.md 12.11** (P0): the snapshot copies and the canvas update are reads through `w16q_*` and
  `w16q_draw_on` on presentation memory inside the guard; V4 and G-1 results (below).
* **FIDELITY.md**: F132 (what the zoom covers): the ring at -1 now shows the main map's Windows rules
  from the latest snapshot; recorded differences: labels without the 32-label cap in world order (and
  the core's row quirk of CollectVisibleCityLabels), no marker for a city bit without a city, no unit
  for a broken stack ring, the city-screen map mode not reproduced in the ring. F130: the ring is no
  longer black at -1, so a ring click recentres on a square the player can see.
* **RUNNING.md**: the `pmap` line's new fields in `presentation-diag.log` and civ64's debug log.
* **FEATURES.md**: none.
* **STATUS.md** (extension track): Mb1 complete in Checked, CheckedNoObs and Release (this record);
  next Mb2 (mirror checks, `ext_mirror.py`, `ext_zoom.py`, the agent UI check, the M gate); Asan
  deferred.
* **manual-checklist-ext.md** M: M-2 can now be checked with the ring drawn (no longer black).
* **The D1 drafts (draft D)**: 7.1/7.2's added table fields and `gen`; 7.3's shape copies; 7.4's
  update points and the descriptor's pen colour; 18's measured snapshot cost; Open D4 answered.

## Not verified

* **Pixel equality with the core** (7.5): the rules were checked by reading the translation and by the
  unit tests on synthetic snapshots; a by-eye comparison of one S4 frame at -1 showed no seam at the
  view's edge. The mirror checks (`key`, `render`, `settled`) are Mb2's.
* **Text and pens**: the size digits, unit letters and labels use w16's rasterisers with the colours
  mapped through the map port DC's palette; untested against the core's pixels until Mb2.
* **RedrawMapRect's exit** (a trigger) is still never reached by any run (Ma's note).
* **Shapes changed in place** under the same handle and size would not be seen by the canvas.
* **Open D4** was measured on the Checked harness (no Release harness exists), one machine, varying
  load.
* **Asan**: deferred by the user; not built or run.

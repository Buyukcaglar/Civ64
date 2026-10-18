# Extension phase M (map renderer and zoom, Windows profile) — acceptance record

Prompt: `claude/docs/x64-port-scaling-dos-prompt.md`, phase M (section 9): "The map renderer (Windows
rules) and zoom (Z) in the Windows profile." Gate: "7.5 passes; Z-1..Z-3 for the Windows profile; agent
UI check." By decision C2 (`verify/ext-d1-decisions.md`, area D) M's 7.5 is the M1 checks (key, render,
settled); the per-present comparison M2 is built and gated with D6. Under the user's direction of
2026-10-10 21:20 Asan runs are deferred to the end of the queue, so the gate is met in Checked,
CheckedNoObs and Release with the Asan run recorded as deferred. Brief:
[verify/BRIEF-m.md](verify/BRIEF-m.md). Design: [verify/ext-d1-draft-D.md](verify/ext-d1-draft-D.md)
(Revision 3) with [verify/ext-d1-decisions.md](verify/ext-d1-decisions.md) area D and DESIGN.md
12.9..12.11.

M was done in three sequential units, each with its own record:

* **Ma, zoom, layer, in-view source, input, commands:** [ext-Ma-record.md](ext-Ma-record.md) (the
  levels and geometry, the layer after the scaler, the mirror `M`, the anchors and the follow rule,
  the input mapping and the ring click, the chords and the wheel, the system-menu items, `--zoom`, the
  settings key, A-1..A-6 and A-8, `test_map.c`, V4, the 7.8 runs, Open D8).
* **Mb1, snapshots, the Windows rules, the world canvas, the ring:** [ext-Mb1-record.md](ext-Mb1-record.md)
  (`pmap_snap.c`, `pmap_state.c`, `pmap_win.c`, `pmap_world.c`, the ring at -1, the rules tests, Open
  D4).
* **Mb2, the mirror checks, the zoomed-frame goldens, the agent UI check, this gate:**
  [ext-Mb2-record.md](ext-Mb2-record.md) (`pmap_check.c`, `--mirror 1`, `ext_mirror.py`,
  `ext_zoom.py` and its goldens).

Labels: **compiled** (the three language checks and `/W4 /WX`), **headless** (test programs and the
harness on `build/gamedata`), **Win32-headless** (the Win32 back end with a hidden window),
**agent-observed** (a visible civ64 window driven and looked at by an agent; not user acceptance). No
DOS program was executed; nothing was written to `C:\Projects\Civ1RE\dos` or `build/dosdata`.

## Gate

The gate's items as run in Mb2's final cycle, 2026-10-11, after all three units' changes (times UTC;
details in [ext-Mb2-record.md](ext-Mb2-record.md#builds-and-tests)):

| Gate item | Method | Result |
|---|---|---|
| **7.5, M1 check `key`** (D 10.1) | headless: `ext_mirror.py Checked` in `test.cmd checked`, `--mirror 1` on every scenario row, gate3b's S2, S2b, S2c, S3 and the soaks S4, S5 (29 runs) | **6,925 checks, 0 mismatches**: every DrawMapTile's appearance key (at TileCacheLookup from 1110:0579) equals `mw_key` over live memory |
| **7.5, M1 check `render`** | the same runs | **1,229 checks, 0 mismatches**: every tile the core rendered (TileCacheInsert from 1110:05B8) equals `mw_render_key` pixel for pixel |
| **7.5, M1 check `settled`** | the same runs | **86 checks, 0 mismatches**: the map port after every checked DrawTilesToPort (78 dissolves, mode 1, in the core's shuffled order; 8 mode 0) equals the rules' replay in the core's order, the whole bitmap (squares, units, fog edges, city markers, labels); RedrawMapRect reached by no run |
| 7.5, P0 of the checks | `ext_mirror.py`: each run's frame, snapshot and result lines and `events.log` against ext_p0's V0 (27 runs) and uninit.py's soak runs (S4, S5) | equal in 29 of 29: **MIRROR_OK runs 29** |
| **Z-1** (levels -1, 0, +1; wheel, chords, reset, menu) | compiled; headless `test_map` (geometry, anchors, limits, wheel; 127 checks Checked and Release, 1 CheckedNoObs); Win32-headless `test_host_win32` (the zoom items, `--zoom`; 196 / 194); headless 7.8 `ext_adapt.py` (zoomkeys: 8 chords and 3 wheel lines; ring); `ext_zoom.py` at five host sizes and both levels | all pass: TESTS_OK in the three variants, EXT_ADAPT_OK checks 20, ZOOM_OK combinations 32 |
| **Z-2** (the renderer: level 0 no layer, in view the core's pixels, the ring by the Windows rules; deterministic frames) | by construction (Ma: no layer at 0, `M` in view); the settled check (above) for the rules; `ext_zoom.py`: every combination run twice, zoomed shows equal, 388 samples equal to the goldens | **ZOOM_OK combinations 32 runs 64 samples 388**; mirror 0 mismatches |
| **Z-3** (input in the layer and P0) | headless 7.8 `ext_adapt.py` (the ring click equals the equivalent small-map click: ring = ringref; in-view clicks at -1 and +1); `test_map` input and `pmap_filter_ring` sections; P0: `ext_p0.py` V4 (27 runs with the zoom cycling at 1920x1440 equal to V0), `ext_p0.py CheckedNoObs` (V5 and the zoom refusals), `ext_g1.py` on Checked and CheckedNoObs | **EXT_ADAPT_OK checks 20**, **P0_OK checks 279** (Checked) and **56** (CheckedNoObs), **EXT_G1_OK runs 77** twice |
| **Agent UI check** (visible civ64 at 1920x1440: zoom by chord and wheel, menu items, a ring click, screenshots) | agent-observed: civ64.exe (final Release) started visibly, computer-use access granted | **not done**: the first input batch was stopped by a user interrupt; the check was not retried, civ64 was ended and its settings file found unchanged; one screenshot of the title menu (`build/ext-m-ui/01-title-menu-civ64-window.png`). Moved to the user's pending checks (below) |
| Builds | compiled: `build.cmd checked`, `checked noobs`, Release (254 portable sources, `/std:c11`, `/std:c17`, clang-tidy C99 parse) | BUILD_OK in all three (20:31..20:34, 21:03..21:06, 21:18..21:21 UTC) |
| No DOS bytes | `nodos.py check` in every `test.cmd` | NODOS_OK in all three variants |
| Asan | — | **deferred** (the user's direction 2026-10-10 21:20) |

**Gate result: met in Checked, CheckedNoObs and Release for 7.5 (M1) and Z-1..Z-3 of the Windows
profile; the agent UI check was not completed** (stopped by the user's interrupt at its first input;
recorded, not retried) and is left with the user's pending checks; Asan deferred. The orchestrator
decides whether the incomplete agent UI check holds the gate open.

The final cycle (Mb2, logs `build/mb2-*.log`):

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

## Deviations (summary)

Each unit's record has the full table with the design section, what and why.

* **Ma** ([deviations](ext-Ma-record.md#deviations-from-the-design)): `PiOut` gains `cmd_steps` and
  `cmd_at` (several wheel notches per message, the anchor); `pmap.h` gains the zoom command, the
  menu's gray, the give-back, the layer image and test seams; `PI_LAYER_GONE` for a press whose layer
  went; the capture-loss release per button; the zoom chords are not chords under `CIV_OBSERVER 0`;
  the system-menu items request their level and are grayed without the observer; the harness's
  `zoom 1` and `zoom reset` spellings; `profiles.log`'s `map windows` hash (one render late);
  `presentation-diag.log`'s `pmap` line; V4 over the 27 P0 runs (not the soaks); the 7.8 reference in
  host form and the covered click as a unit test; the sharp layer's palette reconversion costs a full
  render; `w16q_draw_on`'s bounds; `w16_syscmd_reset`; B-3 delivered in Ma.
* **Mb1** ([deviations](ext-Mb1-record.md#deviations-from-the-design)): the snapshot and reader carry the
  rule tables and `gen`; the shapes are copied into presentation memory at the canvas update; the
  canvas updates at the tick (step 3a) and at core presents, level -1 only; the descriptor holds the
  bevel pen's physical index (animated palette entries); a city bit without a city draws no marker and
  a broken stack ring no unit (the core reads index -1); GetColorIndexRGB index 10 maps as 0; the ring
  takes the city-screen map mode as 0; TextOut taken as TA_LEFT | TA_TOP; a label's span includes its
  measured text; `take_view` stays in `pmap_inview.c`; the snapshot copy costs ~73 µs (per turn under
  the estimate).
* **Mb2** ([deviations](ext-Mb2-record.md#deviations-from-the-design)): the settled check replays the
  core's own drawing order onto the port bitmap copied at the call's entry and compares the whole
  bitmap; DrawTilesToPort modes 0 and 1 are checked (mode 2 draws nothing); mode 1's order comes from
  the call's own RedrawMapSquare, DrawUnit and DrawCityLabels entries (no RNG read); key and render
  checks write a line only on a mismatch; `--mirror 2` refused (D6); `PmapSrc.city_mode`;
  `mw_square_clip` with `parts`; the canvas notices shape reloads by other callers; `ext_zoom.py`
  takes `orders` for "input", runs S4 at 1920x1440 only and samples every 5,000 ms; 19's "not zoomed"
  small-map check not built.

## Asan

**Deferred** (the user's direction of 2026-10-10 21:20, decision K8): no Asan build or run in Ma, Mb1 or
Mb2. The Asan run of `test_map` and the harness with the zoom, the snapshots and the checks remains
pending at the end of the queue.

## For the records

Gathered from the three records; the orchestrator applies them (no unit edited these files).

* **DESIGN.md 12.2** (Ma; S2's window): the system menu gains, after "Locate DOS files...", a
  separator, "Zoom &out (half)\tCtrl+Shift+Minus" (0x10C0), "&Normal map zoom\tCtrl+Shift+0" (0x10D0),
  "Zoom &in (double)\tCtrl+Shift+Plus" (0x10E0) as radio items marking the level (Zoom in grayed while
  +1 is refused; all three grayed without the observer), then the separator and About; the chords
  Ctrl+Shift+Plus/Minus/0 (main row and keypad, audited in Ma, not chords under `CIV_OBSERVER 0`);
  the wheel over the map client; `--zoom default|-1|0|+1` and the settings key `zoom`;
  `test_host_win32`'s zoom items.
* **DESIGN.md 12.5** (the tick and the stages): A-1's step 5 with `pmap_pending()`; `layer()` after
  every scaling (A-2); `pmap_on_core_present` in every profile; the map listener; `PiOut.cmd_steps` /
  `cmd_at`; `PI_LAYER_GONE`; the latch's per-button capture-loss release; frame 4 to
  `pmap_filter_ring` (Ma). Step 3a `pmap_tick()` before the sample hook (Mb1). "Tests": `test_map`,
  `ext_p0.py` V4 and the CheckedNoObs zoom refusals, `ext_adapt.py`'s zoomkeys, ring and ringref
  (Ma); `ext_mirror.py` and `ext_zoom.py` in `test.cmd checked` (Mb2).
* **DESIGN.md 12.9** ("As implemented (M)"): Ma's files, geometry, clamps, anchors and follow, the
  activity rules and counters, the composition with the give-back, `M`, the input rules, the ring
  click, D8 answered, the sharp reconversion cost; Mb1's snapshot (fields, triggers, every run),
  `PmapSrc` (snapshot and live), the rules in `pmap_win.c` with their sources, the world canvas
  (descriptors, labels without the cap, wrap, cell clipping, damage), the ring at -1, the canvas
  update points, `pmap_pending`'s stale canvas, the measured costs and Open D4's answer; Mb2's
  `pmap_check.c` (key, render, settled; the replay from the entry copy in the core's order; mode 1's
  recorded order), `mirror.log`, `mw_square_clip`/`parts`, `PmapSrc.city_mode`, the canvas noticing
  reloads, the findings (one check fix, no renderer fix); each unit's deviations.
* **DESIGN.md 12.10** (w16 changes): Ma's `user_syscmd.c` (A-3a: `g_outline`, `g_outline_on`,
  `w16_sys_track_info`, `w16_syscmd_reset` from `w16_user_reset`), `gdi_draw.c` and `gdi_font.c`
  (A-3b: `w16_paint_brush`, `w16_rast_fill`, `w16_rast_frame`, `w16_rast_line`, `w16_text_draw`,
  `w16_text_box`), `w16_obs.c` (`w16q_sys_track`, `w16q_draw_on` with its bounds), `scale.c` (B-3);
  G-1 equal after each. No w16 change in Mb1 or Mb2.
* **DESIGN.md 12.11** (P0): V4 (27 runs) and the CheckedNoObs refusals (Ma); the snapshot copies and
  the canvas update are `w16q_*` reads and `w16q_draw_on` drawing on presentation memory inside the
  guard (Mb1); the mirror checks in the listener, reads only, and `ext_mirror.py`'s core-trace
  equality in all 29 runs (Mb2); G-1 EXT_G1_OK runs 77 on Checked and CheckedNoObs in each unit's
  final cycle.
* **FIDELITY.md**: F129 (level -1 uneven at odd k), F130 (the ring press) and F132 (what the zoom
  covers) implemented (Ma). F130 gains: the press's move clears only the left button's bit; the small
  map's visibility includes its data block's flag (+0x2C); the ring is drawn since Mb1, so a ring click
  recentres on a square the player can see. F114 (the hold rule) covers the zoom chords; with Num Lock
  on the keypad reset may not arrive. D8's answer for the small-map path. F132 (Mb1): the ring at -1
  shows the main map's Windows rules from the latest snapshot; recorded differences: labels without
  the 32-label cap in world order (and the core's row quirk of CollectVisibleCityLabels), no marker for
  a city bit without a city, no unit for a broken stack ring, the city-screen map mode not reproduced
  in the ring. F132 (Mb2): those rules equal the core's own drawing wherever the settled check ran
  (all scenarios and S2..S5, no mismatch).
* **RUNNING.md**: civ64's zoom items, the chords, the wheel over the map, `--zoom` (refused in a
  `CIV_OBSERVER 0` build), the settings key `zoom`; the harness's `at <ms> zoom -1|0|+1|reset`,
  `--zoom`, `presented.log`'s `zoom L view CWxCH view_sha256 SHA` and `zoom refused <reason>`,
  `view-NNNNN.bmp` with `--dump-presented`, `profiles.log`'s `map windows SHA`, the `pmap ...` line of
  `presentation-diag.log` and civ64's debug log with Mb1's new fields; `ext_p0.py` V4 and
  `ext_adapt.py`'s M runs (Ma); the harness's `--mirror 1` (`--mirror 2` refused), `mirror.log`'s
  lines, `ext_mirror.py` and `ext_zoom.py` (`--update`, the goldens `tests/harness/ext-zoom-golden.txt`)
  in `test.cmd checked` and their outputs `build/test/Checked/ext-mirror.txt`, `ext-zoom.txt` (Mb2).
* **FEATURES.md**: none (no game feature changed; the zoom is presentation).
* **STATUS.md** (extension track): phase M complete in Checked, CheckedNoObs and Release (this gate
  record; Ma, Mb1, Mb2 records); the agent UI check's result; Asan deferred; next: unit M+W
  (BRIEF-m.md, low priority, after the M gate), then the queue.
* **manual-checklist-ext.md**, M: M-1 and M-2 stay pending (user). Add (Ma): Ctrl+Shift+Plus, Minus
  and 0 and the wheel over the map change the zoom (the wheel keeps the point under the pointer); the
  system menu's zoom items mark the level and "Zoom in" is grayed when the map window is too small;
  plain `=`, `-` and `0` still reach the game; the zoom is remembered at the next start (the `zoom`
  key) unless `--zoom` is given; at +1 the zoomed map follows the active unit. M-2 can now be checked
  with the ring drawn (Mb1).
* **The D1 drafts (draft D)**: 3's interface additions; A-4's `cmd_steps`/`cmd_at`; A-6's `map
  windows` and the `pmap` diag line; 12.1's `PI_LAYER_GONE`; 13's chords under `CIV_OBSERVER 0`, the
  grayed items and the harness spellings; 16.4's 27 runs; 16.5's host-form reference and the covered
  click as a unit test; 18's sharp reconversion cost; Open D8 answered; B-3 delivered in Ma; draft A
  10.1's capture-loss release per button (Ma). 7.1/7.2's added table fields and `gen`; 7.3's shape
  copies; 7.4's update points and the descriptor's pen colour; 18's measured snapshot cost; Open D4
  answered (Mb1). 10.1's settled method and modes, 10.2's line rules and end-line fields, 7.2's
  `city_mode`, 16.3's `orders`, the soak size and the sample rule, 19's "not zoomed" check not built;
  Open D5 and D2 stay open for D6 (Mb2).

## User checks left pending

`manual-checklist-ext.md`, section M (both pending; the agent UI check below does not close them):

* **M-1** (C1, F129): at 1920x1440 on the 2560x1600 display (factor 3) level -1 lines the squares up
  exactly with uneven pixels inside a square (a 2:1 reduction); at an even factor pixel-perfect; DOS -1
  pixel-perfect at every factor (with D6).
* **M-2** (C6, F130): at level -1 a left click on a ring square recentres the core's map on that square
  as a small-map click would; a right click there or a click beyond the poles does nothing; a drag from
  a ring square released anywhere leaves no button stuck.

Ma's and Mb1's records add for the checklist (see "For the records"): the chords, the wheel (keeping
the point under the pointer), the menu's level marks and the grayed "Zoom in", plain `=`, `-`, `0`
reaching the game, the remembered `zoom` key, the follow at +1, and the ring now drawn (not black).

## Not verified

* **The visible zoom** (agent UI check not completed; see the gate table): chords, wheel, menu items
  and the ring click were verified headless and Win32-headless only.
* **RedrawMapRect's settled check** never ran (no scenario reaches RedrawMapRect); the label cap, the
  duplicate test, the row quirk and the city-screen mode were not reached by a settled check; the
  coverage (65 key and terrain pairs at most per run, 7 unit-mark and 2 city-state combinations) is
  what the scenarios reach (Mb2 record).
* **The world canvas's update logic** (dirty squares, label spans, wrap) has no pixel proof against a
  fresh full render; `ext_zoom.py`'s goldens pin the zoomed frames, they do not prove them.
* **M2** (`--mirror 2`: the present check and the Windows model shadows), the dos-settled check, the DOS
  map (D6), ext_zoom's profile-switch half, Open D2 and D5: D6.
* **19's "not zoomed"** small-map check: not built.
* **Snapshot-based staleness**: the ring shows the latest snapshot; shapes changed in place under the
  same handle and size would not be seen (Mb1); RedrawMapRect's exit as a snapshot trigger is never
  reached (Ma, Mb1).
* **Costs** measured on one machine under varying load (Ma, Mb1); the sharp layer's palette
  reconversion is a full render (Ma).
* **Exact fidelity beyond the checks**: level -1 at odd factors is the recorded 2:1 reduction (F129);
  the ring's label policy differs from the core's by design (no cap, world order; Mb1).
* **User acceptance**: none yet; M-1 and M-2 and the added items are pending.
* **Asan**: deferred; not built or run in Ma, Mb1 or Mb2.

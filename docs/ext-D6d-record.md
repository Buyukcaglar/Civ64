# Extension phase D6, unit D6d (the DOS ring, the zoom in the DOS profile and the map palette animation) - record

Draft for the build slot (BRIEF-d6.md "Units" D6d), with the D6c review's follow-ups folded in as D6cF (the
orchestrator, about 11:00 UTC).  Staged in `build/d6d-stage/` on the tree after the D6c landing
(build/d6c-status.txt ALL_GREEN 10:15 UTC) and its docs pass (build/docs-d6c-done.txt 10:34:05 UTC); the bases were
copied at 10:36:42 UTC, the D6cF bases (`pdos_replay.c`, `test_pdos_replay.c`, `test_pdos_profile.c`,
`docs/ext-D6c-record.md`) at 10:55:16 UTC, and `tests/harness/ext_adapt.py` again at 11:17:16 UTC after D5K's
files reached the tree (its build step ended 11:11 UTC, ALL_GREEN 11:34:48 UTC).  UX3, D5K2 and SL landed during
the staging (build/ux3-status.txt ALL_GREEN 12:04:47 UTC; D5K2's files in the tree by 12:09:47 UTC; SL's by about
12:40 UTC, build/sl-status.txt ALL_GREEN 13:34:58 UTC): the stage's `tests/headless/harness.c` and
`tests/harness/ext_adapt.py` were rebased onto the UX3 and D5K2 copies (disjoint hunks; section "Rebase notes"),
test.cmd's base was copied again after each, and every private result below was produced on the overlay of the
tree with all three landed.  Every base is rechecked equal to the tree in `BASE-SHA256.txt`.  Private builds and
runs in `build/d6d-stage/obj/` only (an overlay `obj/src` = tree + stage, built with build.cmd's own flags; the
private runs use a copy of the overlay's Checked harness, `obj/exe`, never the tree's executables).

## Status

LANDED 2026-10-16 (ALL_GREEN 14:34:38 UTC, RELEASE_OK 14:39:06 UTC; section "Landing").  Draft D 14.9, 6.2 (the DOS in-view source), 4.1/4.2 and 5.3..5.5 with the
DOS source and 14.7 are built: at levels -1 and +1 the map layer now also shows the DOS profile, with the same
geometry, anchors, clamps, refusals, follow rule and input as the Windows profile's (one geometry for both,
evaluated whichever profile is visible), M_dos in view, G_dos (the DOS ring) beyond it and the A machine's play
palette, converted again at each step of the map palette.  `profiles.log` samples each profile's layer at every
sample time (A-6).  ext_zoom gains the DOS runs (their goldens) and the switching run, ext_p0 the variation V4d,
ext_adapt the DOS zoom pairs.  OPEN L12 is read from the listing (no cycling over faded entries in the play
path).  D6cF: the nearest-colour fix (R2) and the cycling vectors (G2) are in; R1, G1, G3 and R3 are recorded.
Privately: the three variants build (293 portable sources with the landed SL), cc.cmd's stricter checks pass on every changed source and test, all 47 unit programs pass in Checked, CheckedNoObs and
Release (test_map 248, test_pdos_replay 86, test_pdos_profile 51 / 47 in CheckedNoObs); ext_zoom ZOOM_OK over 108
runs with the Windows golden lines identical to the tree's and the 240 new DOS lines reproduced by a second run;
ext_p0 V4d P0_OK in all 27 runs (the layer drawn in both profiles in 22); ext_adapt's D6d checks 5 of 5;
obs_lint, testpar, registry.py and nodos.py checks OK.

## What was built

### The layer for both profiles (`present/map/pmap_layer.c`; draft D 5.1..5.5 with the DOS source, 7.4)

* **Live and drawn.**  The layer's geometry and clip ("live": the view, the level, the anchors, the clip in host
  pixels) are computed from the layout of a frame of the core's size in the view (`pmap_core_layout`: the view's
  client and options, the core frame's size), not from the frame the visible profile shows, so they are the same
  in every profile.  The image is drawn ("active") for the visible profile (`pmap_layer_profile`) only when the
  view is laid out for that frame (`present_layout_equal(present_view_layout(), L)`; otherwise `layout_wait`)
  and, in the DOS profile, while it presents its A frame (`pmap_dos_frame_ok`; otherwise `dos_frame`: an N frame,
  e.g. a DOS screen in play, is another picture) and M_dos is filled (`pmap_dos_inview_ready`; otherwise
  `dos_wait`).  When it cannot be drawn the client goes back to the base frame (`undraw`) and the geometry stays
  live.  A change of the drawn profile renders the whole clip.
* **Sources.**  `sample(prof, x, y)`: the Windows profile M / black / G_win as before; the DOS profile M_dos in
  view, DOS 0 beyond the poles, G_dos on the ring.  The palette of the drawn profile (`palette_of`): the core's
  for Windows, the play palette as XRGB for DOS (`pmap_dos_xrgb`).
* **14.7.**  A new play-palette generation while the DOS layer is drawn makes the layer pending (`pmap_pending`)
  and the overlay converts the image again (`dos_palette`, `n_dos_reconverts`): under nearest the indices are
  kept and converted (5.3), under `fit` sharp the XRGB image is rendered again (M's deviation, measured below).
* **A-6.**  `pmap_layer_sample(prof, &w, &h)` (pmap.h): the layer of either profile rendered whole over the
  clip's bounding box, now, from that profile's sources and as XRGB in that profile's current palette,
  whichever profile is visible; at -1 that profile's world canvas is brought up to date first.  NULL when the
  level is 0, the layer is not live or that profile's in-view source is missing.

### G_dos, the DOS ring (`present/map/pmap_world.c`, `pmap_dos.c`; draft D 14.9, 14.5 "In the DOS ring")

* 1280 x 800 DOS indices (1,024,000 bytes, allocated on the first -1 update with the DOS profile registered):
  one per DOS art pixel, which covers world pixels (2i..2i+1, 2j..2j+1) (14.1); square (x, y) is the 16 x 16
  cell at (16x, 16y).  As G_win: one `PmapDosKey` per square (the inputs the DOS rules read: `pmap_dos_key`,
  the core's decisions through the Windows readers of the snapshot), recomputed when the snapshot's gen
  changes; a square whose key changed is cleared to DOS 0 and drawn again by `pmap_dos_ring_square`
  (RedrawMapSquare's two calls: R:1AEA:03BA's layers, then the top unit through R:1AEA:0E29 with the stack
  shadow; black when unseen), then every label whose pixels meet the cell, clipped to it.
* Labels: G_win's list (the core's label policy, column-major, east-west wrap) drawn at 14.5's ring position
  (R:1AEA:0174..0180 px - 8, R:1AEA:0168..016C py + 10h, in DOS pixels) without R:1DC4:007C's clamp and
  R:1F4D:04F7's truncation (those belong to the DOS screen's edges), colour 0Bh with its shadow
  (R:1AEA:0164..018D, R:0182:0086); a label past the east edge wraps to the west.  A changed, added or removed
  label draws the squares under its old and new pixels again.
* The DOS rules draw G_dos through a k = 1 pen (`g_pk`, `pen_at`): one DOS pixel per G_dos pixel; the layer's
  `m = 2 s_l` then gives each DOS pixel k x k host pixels at -1 (4.1/4.2).
* `pmap_world_update` brings the canvas of the layer's profile up to date at each tick and core present (as
  before for G_win); the other canvas follows when `pmap_layer_sample` samples it.  Each canvas damages the layer
  only while the layer shows it.  Diagnostics: `world_dos_updates`, `world_dos_squares`, `world_dos_us`.

### M_dos, the DOS in-view source (`present/map/pmap_dos.c`, `pmap_inview.c`; draft D 6.2)

* The map client's DOS pixels at map pixels: Wn_dos where the client is visible (the map window's visible
  region), P_dos where it is covered (6.2), DOS 0 where a shadow is missing or of another size
  (`dos_port_size`).  Filled at every core present in every profile (`pmap_dos_inview_present`, after D6c's
  `pmap_dos_present`), only the rows that changed (`dos_fills`); their damage reaches the layer only while it is
  drawn for the DOS profile.  Freed at level 0 and taken whole when the level leaves 0.

### Evaluation at profile-independent instants (`present/map/pmap_inview.c`, `pmap_zoom.c`; 7.4)

* At every core present and every tick, whichever profile is visible, the layer is evaluated
  (`pmap_layer_update`) with the show's request (`recheck`) left as it was, so that the shows are D6c's; M's
  changes and the core's palette damage the layer only while it is drawn for the Windows profile.
* The active-unit follow rule (+1) and the wheel's anchor use the live geometry, drawn or not; the +1 refusal
  (below 3 x 3 squares) uses the core layout.  So the layer's level, origin and clip evolve alike in every
  profile and with switching.
* `presentation-diag.log`'s `pmap` line gains `live drawn_dos dos_frame dos_wait layout_wait dos_port_size
  dos_fills dos_reconverts world_dos_updates world_dos_squares world_dos_us` (its buffer 1024 -> 2048 bytes; the
  longest line seen privately 623 bytes).  CIV_OBSERVER 0: `pmap_layer_sample` is a stub (NULL).

### Harness (`tests/headless/harness.c`)

* `profiles.log`'s `sample` lines: ` map <profile> <sha256>` for each registered profile whose layer sample
  exists (`pmap_layer_sample`, XRGB bytes 4 w x h), replacing D6c's single ` map <sha>` of the drawn image.

### Runners (`tests/harness/ext_zoom.py`, `ext_p0.py`, `ext_adapt.py`; draft D 16.3..16.5)

* **ext_zoom.py** (16.3, Z-1, Z-2, 7.4, A-6, RV1-5).  Per combination (scenario `new`, `load`, `orders` at the
  five host sizes and policies, the soak S4 at 1920x1440; levels -1 and +1):
  * `win a` (no DOS profile: the Windows goldens' run, unchanged) and `win b` (`--dos-data`, the DOS profile
    registered and hidden): their zoomed shows equal (the hidden DOS profile changes nothing shown);
  * `dos a` (`--dos-data --graphics dos`) at every size of the three scenarios: the DOS goldens (`dos` lines);
    `dos b` as well at 1920x1440: its shows equal dos a's (Z-2 for the DOS layer);
  * `sw a` (`--dos-data --switch-every 997`) at 1920x1440, the scenarios and the soak: at least one switch;
  * every DOS run: no refused switch (profiles.log), the dos runs start in the DOS profile;
  * the layer samples: profiles.log's `map windows` and `map dos` hashes at each sample time equal in win b,
    dos a, dos b and sw a (and `map windows` in win a), with the same sample times; sw a has a sample with both.
  * `--profiles`, `--sizes`, `--exe`, `--root`, `--port` (private runs); `--update` writes both profiles'
    goldens (only with every size and scenario).  The golden file gains a third header line and the `dos` lines
    after the Windows lines, which are unchanged.
* **ext_p0.py** (16.4, 7.3).  V4d: V4 (`--host-size 1920x1440`, the zoom commands every 1,301 ms cycling +1,
  -1, reset, 0) with `--dos-data build\dosdata --switch-every 997`, every V4 run; P0 against V0 as every
  variation, the switch assertions (switches >= 1, refused 0), no `zoom refused`, and over all V4d runs the
  layer drawn in at least one show of each profile (presented.log `profile dos` / `profile windows` lines with
  the zoom fields).  In the default Checked list.
* **ext_adapt.py** (16.5, 7.8).  `zoomkeys-dos`: zoomkeys' host lines plus the profile chord at 40,000 ms (turn 1,
  in play) equals `plain`; every zoom chord and wheel line `events 0` with its command, the chord `cmd profile`;
  one switch, refused 0; the layer drawn in DOS shows.  `ring-dos`: ring's lines plus the chord at `--zoom -1`
  equals `ringref` (the ring click at 59,400 ms on the DOS layer's ring gives the small-map click); ring_press 1,
  ring_refused 0, one switch, the DOS layer drawn.

### D6cF (the D6c review's follow-ups; section "D6cF" below)

* `present/dos/pdos_replay.c` `nearest_rgb`: on the A machine's DAC the play slots 60h..7Fh are skipped (R2).
* `tests/test_pdos_replay.c` and `tests/test_pdos_profile.c`: the R2 vector and the cycling vectors (G2);
  `tests/test_map.c`: the map element composed again on a step (G2).

## OPEN L12 (from the listing; draft D 14.7, B 5.5)

L12 asks whether the map's cycling runs over faded entries.  In the play return path R:0238:1BEB the DOS program
stops the map slots (R:0238:1B48 calls R:1DC4:065F) before the fade-out (R:0000:04D4, at R:0238:1B66), stops them
again (R:0238:1BFC) before the fade-in (R:0000:04AA, at R:0238:1C86, which busy-waits until the fade completes)
and restarts them only after it (R:0238:1C8E, R:1DC4:0626), without capturing the colours again.  So the slots
never cycle over faded entries in that path, and the A machine has no fade in play in D6d: nothing to model
here.  The restart without a capture is R3 (D6e's, section "D6cF").  L11 (entry 45, the BACK*.PAL entries) is
not D6d's (the play palette's life cycle, D6e).

## Tests

* `tests/test_map.c` (Checked and Release; CheckedNoObs keeps its 1 check), 40 new checks (208 -> 248):
  * D6cF (in `dos_model`): the map element composed again on a play-palette step (its DAC slot cycled, the
    element's colour after `pdos_play_cycle`, its damage covering the element);
  * 4.1/4.2 (`dos_geometry`): at k = 1..4 and levels -1/+1 the DOS layer drawn with the Windows layer's
    geometry and origin; at -1 every DOS pixel k x k host pixels (an even origin), M_dos in view, DOS 0 beyond
    the poles, the play palette's colours; under `fit` sharp and nearest the drawn image equals its sample;
  * anchors and limits (`dos_anchors_limits`): the wheel anchor keeps the world pixel under the mouse, the pole
    clamp and a wrapped ring square at -1, the same point in the Windows layer, +1 refused below 3 x 3 squares;
  * 14.7 (`dos_palette_steps`): nothing pending before a step, pending after it, one conversion again
    (nearest: converted, not rendered; sharp: rendered), the stepped colour on the host pixel;
  * A-6 / 7.4 (`dos_independence`): both profiles sampled from their own sources whichever is drawn, the view
    shows the drawn profile's sample, no M_dos: live but not drawn (`dos_wait`), the DOS sample absent, the
    Windows layer then takes the same origin;
  * 14.9 / 14.5 (`dos_ring`, `dos_layer`): G_dos's squares are the k = 2 model's pixels halved, ROME's ring
    label at (16 x 13 - 8, 16 x 10 + 16) DOS pixels, a label past the east edge wraps; the ring in the layer;
  * costs (printed, not checked): a DOS play-palette step at 1920x1440 and 3840x2160 (integer, nearest) and at
    2560x1600 `fit` sharp, levels -1 and +1.
* `tests/test_pdos_replay.c`: 84 -> 86 (R2: on the A DAC a colour equal to slot 61h's maps to the static entry
  33 rather than 61h; on the N DAC to 61h).  Fails before the fix (33: 0, 61h: 144), passes after.
* `tests/test_pdos_profile.c`: 40 -> 51, CheckedNoObs 36 -> 47 (G2: phase 0 at WdwMapOpen's exit; one step at each CyclePaletteColors
  entry probe (positions 7, 7, 15 and a new generation), none at its exit; five entries five steps; phase 0 and
  SP257.PIC's colours at the next WdwMapOpen exit; steps while the Windows profile is visible; after the switch
  to DOS the phase stepped while hidden, and the next step continues from it).
* Runners: `ext_zoom.py`, `ext_p0.py` V4d, `ext_adapt.py` zoomkeys-dos and ring-dos (above).

## Results (private, `build/d6d-stage/obj/`)

All on the overlay of the tree with UX3, D5K2 and SL landed (`obj/src`, rebuilt 13:16 UTC; the private runs use the
Checked harness built from the same sources at 13:04 UTC, copied to `obj/exe`, SHA-256 39a54b2b...).  The machine
carried other agents' build slots and runs throughout: every time below is under that load.

* **Builds** (`obj/final.sh`): build.cmd's three variants of the overlay (`--nogen`): BUILD_OK each, portable
  sources 293 (c11, c17, the C99 parse).  cc.cmd's stricter checks (c11 and c17 /W4 /WX, the clang C99 parse
  with -Wextra) on `pmap_dos.c`, `pmap_layer.c`, `pmap_world.c`, `pmap_inview.c`, `pmap_zoom.c`, `pdos_replay.c`,
  `tests/test_map.c`, `tests/test_pdos_replay.c` and `tests/test_pdos_profile.c` in the three variants: CC_OK
  each.  (The tree's `test_pdos_profile.c` fails that C99 parse since D5a added the fourth shadow query:
  `{q_dc, q_wnd, q_read}` misses `wnd_place`; build.cmd does not parse tests that way.  The staged copy names it,
  NULL, one line marked `extension D6d`.)
* **Unit tests** (`<gamedata> <outdir>` under the stage): all 47 programs pass in Checked, CheckedNoObs and
  Release; test_map 248 / 1 / 248 (the tree's 208 / 1 / 208), test_pdos_replay 86 in each (84), test_pdos_profile
  51 / 47 / 51 (40 / 36 / 40); every other count equal to the tree's last unit log.
* **Checks:** `obs_lint.py` OBS_LINT_OK files 119 probes 203 callsites 98 (the tree's); `testpar.py check` on the
  overlay's test.cmd with BUILD-TEST-ADDITIONS.md applied: exit 0, `list`: `ext_p0 cpu=8 est=760`, `ext_adapt
  est=120`, `ext_zoom cpu=8 est=1250`; `gen/dos/registry.py check` (the tree's build/dosdata and listings read):
  REGISTRY_OK; `gen/dos/nodos.py check --variant Checked --root obj/src`: NODOS_OK (612 files, 264,308,119
  bytes, 0 hits).
* **ext_zoom** (the staged runner through `obj/runzoom.py`, `--update -j 4`, the tree's gamedata, dosdata and
  cache read, every run and output under `obj/run/zf`): `ZOOM_OK combinations 32 runs 108 samples 628 map
  comparisons 32` in 44.6 minutes.  Every combination: win a = win b shows, dos a = dos b shows at 1920x1440, no
  `zoom refused`, no refused switch, the dos runs started in the DOS profile, sw switched (the soak: 393 times),
  and the layer samples of both profiles equal in win b, dos a, dos b and sw (and the Windows ones in win a) at
  every common sample time.  The rewritten golden file's 388 Windows lines are byte-identical to the tree's
  (`ext-zoom-golden.txt`, CRLF); 240 `dos` lines were added.  A second run with `--profiles dos` (`obj/run/zv`,
  without `--update`) reproduced all 240 DOS samples: `ZOOM_OK combinations 32 runs 36 samples 240 map comparisons 6`.  Run wall times summed by kind: win 60 scenario runs 2,805 s and 4 soak runs
  4,086 s; dos 36 runs 1,317 s; sw 6 scenario runs 359 s and 2 soak runs 2,088 s (10,655 s in all, against
  6,891 s for the 64 runs D6c had).
* **P0** (`ext_p0.py`, the staged runner through `obj/runp0.py`, `--vars V0,V4d -j 2`, `obj/run/p0`): P0_OK
  checks 109: V0 27, and V4d in all 27 runs equal to V0 (frames, snapshots, results, events), its switch
  assertions (profiles.log: switches, refused 0), no `zoom refused`, and "the map layer was drawn in the DOS
  profile in 22 runs, in the Windows profile in 22" (the other five reach no map).  The other variations (V1..V3,
  V4, V6.., the CheckedNoObs V5) were not rerun: at level 0 D6d's paths return at once (the evaluation and
  M_dos need a level other than 0), and V4's Windows zoomed shows are covered by ext_zoom's unchanged Windows
  goldens.
* **ext_adapt** (`obj/runadapt.py`: `plain` and extension M's runs with D6d's two, `obj/run/ad`): 14 checks, 0
  failed: M's nine as before and zoomkeys-dos (equals plain; 54 chord and wheel lines `events 0` with their
  commands, the chord `cmd profile`; one switch, refused 0; the DOS layer drawn in 74 shows), ring-dos (equals
  ringref; ring_press [1] ring_refused [0]; one switch; the DOS layer drawn in 155 shows).  The D4c2..D5K2 cases
  were not run (D6d changes none of them).
* **The soak in the DOS profile** (a measurement before the matrix decision, D6d's harness before the rebases:
  `--only s4 --profiles dos,sw`): dos a and dos b at -1 had equal shows and equal per-profile samples (78 sample
  times, 74 with both maps), and those samples equal the switching soak's (393 switches) at every sample time.
  A DOS soak run took about 12.5 minutes, a switching one about 14 (under load).
* **Costs** (test_map, printed): a DOS play-palette step under nearest (integer) costs 1.0..1.4 ms at 1920x1440
  and 2.0..3.0 ms at 3840x2160 (converted again); under `fit` sharp at 2560x1600 it renders the image again:
  54.2 / 33.5 ms (Checked, -1 / +1) and 68.8 / 47.4 ms (Release, under load), 47.3 / 31.6 ms in a quieter
  earlier run, the same order as the Windows profile's palette reconversion under sharp (48.6 / 34.4 ms Checked).
  `presentation-diag.log`'s longest `pmap` line in the private runs: 623 bytes.
* **Not run privately:** `ext_frames`, `ext_timeline`, `ext_continue`, `ext_mirror`, `ext_replay`, `ext_slots`,
  `ux3_aspect`, `bs*`, `ext_g1`, the Asan variant (deferred): at level 0 (every one of them) the layer stays
  inactive and D6d's evaluation, M_dos and canvases are not reached; the core is untouched.

## Expected changes at the build slot

* Unit: test_map 208 -> 248 (Checked, Release; CheckedNoObs 1 unchanged), test_pdos_replay 84 -> 86 (every
  variant), test_pdos_profile 40 -> 51 (Checked, Release; CheckedNoObs 36 -> 47); every other unit count
  unchanged.  obs_lint files and portable sources unchanged (no new source).
* `ext-p0.txt`: `P0_OK checks` 394 -> 476 (V4d: 27 runs x 3 and the drawn line); the echo names V4d.  The
  section's work grows by about a quarter (V4d's runs are about 3.5 times as long as V0's: 1920x1440, presented,
  switching every 997 ms); `est=760`.
* `ext-adapt.txt`: `EXT_ADAPT_OK checks` 123 -> 128 (five D6d lines); two more runs (about 106 s); `est=120`.
* `ext-zoom.txt`: `ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32` (was `combinations 32 runs 64
  samples 388`); each `ZOOM` line's `shows` lists `dos`, `sw` (1920x1440) and `win`.  About 1.55 times the work;
  `est=1250`.
* `tests/harness/ext-zoom-golden.txt`: a third header line and 240 `dos` lines after the 388 Windows lines, which
  are unchanged.  The goldens are presentation hashes (base prompt 2.3).
* `profiles.log` (runs with `--profile-samples` at level -1 or +1): ` map <profile> <sha>` for each registered
  profile whose layer sample exists, hashing XRGB (4 bytes a pixel) in that profile's palette: the `map windows`
  hash values differ from D6c's (which hashed the drawn index image) and `map dos` is new.  At level 0 no `map`
  field, as before.
* `presentation-diag.log`'s `pmap` line: the eleven new fields (above); at level 0 `live 0`, `drawn_dos 0` and every
  new counter 0 (`world_dos_us` is a host-time field, masked by `cy_equiv` as the others).
* presented.log: DOS-visible zoomed runs show the DOS layer (new picture: `profile dos` shows with the zoom
  fields); Windows-visible shows, every level-0 run, every core output, G-1 fields and `ext_g1.py check`:
  unchanged.
* `nodos.txt`: byte counts grow with the binaries; NODOS_OK.
* Coverage ("other functions entered"): informational, not measured privately.

## Rebase notes

* All bases equal the tree at writing (`BASE-SHA256.txt`).  The `extension D6d` and `extension D6cF` blocks are
  delimited where they add more than a line; one-line hunks carry an `extension D6d` comment.
* **UX3** (landed during the staging, ALL_GREEN 12:04:47 UTC): shared `tests/headless/harness.c` and `test.cmd`.
  harness.c: UX3's hunks (the presented line's layout fields under `--presented 2`, the zoom buffer 160 -> 240, the
  cursor line's factors, `g_presented_level`) and D6d's (`profile_sample`'s `map` loop) are disjoint; the staged
  copy is now the tree's UX3 copy with D6d's hunk applied (`obj/merge`).  ext_zoom runs `--presented 1`, so UX3's
  fields do not reach its goldens.  test.cmd is not staged: `obj/patch_testcmd.py` applies to the tree's UX3 copy
  (UX3's `ux3_aspect` list line and label block untouched; `testpar.py check` exit 0).  UX3's aspect predicate
  (`frame_aspect`) concerns 320 x 200 frames only and `present_layout_compute` lays out 640 x 480 frames with square
  pixels whatever the option (scale.h), so `pmap_core_layout` (the core frame's layout) is unchanged by it.  UX3's
  `pdos_profile.c` is in the overlay: the D6cF vectors in test_pdos_profile pass on it.
* **D5K2** (its files in the tree by 12:09:47 UTC, equal to `build/d5k2-stage`): shared
  `tests/harness/ext_adapt.py`.  D5K2's hunks (the docstring's d-goback lines, `d_press_off` removed, the D-cases
  list, the `lups` field) and D6d's three (the docstring paragraph after "comes from zoomkeys'
  presentation-diag.log", the call at the end of `m_runs`, the D6d functions before "# ---- extension D4c2") are
  disjoint; the staged copy is the tree's D5K2 copy with D6d's hunks applied (`obj/merge`, `obj/patch_adapt.py`
  re-applies them to any later copy).
* **SL** (landed during the staging, ALL_GREEN 13:34:58 UTC): none of D6d's files.  test.cmd: SL's `ext_slots` list
  line and section are disjoint from D6d's replacements (`obj/patch_testcmd.py` applies to the tree's copy with
  them).  SL's `pdos_profile.c` is in the overlay: the D6cF vectors in test_pdos_profile pass on it; ext_zoom's
  DOS goldens were written on the overlay with SL (a DOS screen of SL's in a zoomed DOS run would show unzoomed:
  the layer is drawn only over the A frame, `dos_frame`).
* **D6e** shares `pmap_dos.c`, `pmap_inview.c`, `test_map.c` (the small map and status elements) and the play
  palette's life cycle (R3 below).
* Shared counts: none (no new source file; obs_lint files unchanged, 119 on the tree at writing; portable sources unchanged).

## Build-slot steps

1. Copy the staged files (`BASE-SHA256.txt`'s list) and this record into the tree; apply BUILD-TEST-ADDITIONS.md
   to test.cmd (`obj/patch_testcmd.py SRC DST` does exactly that); build.cmd unchanged.
2. The three-step cycle: `build.cmd checked`, `test.cmd checked` (unit: test_map 248, test_pdos_replay 86,
   test_pdos_profile 51; `ext_p0`: P0_OK with V4d; `ext_adapt`: EXT_ADAPT_OK with the D6d checks; `ext_zoom`:
   ZOOM_OK with the new matrix; every other section as before), `ext_g1.py check` (EXT_G1_OK unchanged: the
   core is untouched).
3. The user build for the visual check (section "What the user checks"): the coordinator's, from the landed tree
   (Release).

## Decisions within the brief

* **One geometry for both profiles, from the core frame's layout.**  The layer's geometry used the visible
  frame's layout; the DOS profile shows N frames (setup, DOS screens) and the A frame of the core's size, and
  the view is laid out per frame, so a geometry from the visible frame would differ by profile and by moment.
  The geometry and clip now come from the layout of a frame of the core's size in the view (the same
  `present_layout_compute` with the view's options): equal in both profiles, and equal to D6c's whenever the
  Windows profile is visible (the Windows goldens are unchanged).  The image is drawn only when the view is laid
  out for that frame.
* **Live versus drawn, evaluation at core presents and ticks.**  7.4 asks for equal layer samples with and
  without switching; the anchors, the follow rule and the wheel need the layer's geometry while the other
  profile is visible.  The layer is therefore evaluated at every core present and tick whatever is shown,
  without taking the show's own evaluation (recheck), so the Windows profile's shows are D6c's.
* **Per-profile samples, fresh, as XRGB.**  `profiles.log` hashes each profile's layer rendered at the sample time
  from that profile's sources and palette (XRGB): an index image would hide palette steps and differ between
  nearest and sharp; the drawn image would exist only for the visible profile.
* **The hidden profile's ring is brought up to date lazily** (at its samples) rather than at every tick: G_dos
  costs `world_dos_us` per update; only the shown canvas is needed for the picture.  Known limit: after a switch
  at -1 the newly shown ring is brought up to date at the next tick or core present (at most one tick, 1/60 s,
  old), recorded.
* **G_dos's cells.**  Each changed square's 16 x 16 cell is cleared and drawn whole, clipped to the cell, with the
  labels meeting it redrawn clipped to it (the labels overlap neighbouring cells): equal to a whole redraw at
  every update (the test compares the k = 2 model's pixels halved).
* **M_dos** is a copy (client-sized) rather than reads through the shadows at render time: Wn_dos and P_dos
  change at the core's draws, the layer renders at shows; a copy at the core present keeps the in-view source
  consistent with the ring's snapshot instant, as M is for the Windows profile.
* **One combined variation V4d** (16.4 "combined with the DOS profile and with --switch-every 997"): V4 with
  `--dos-data` and `--switch-every 997` shows each profile half of the time, so every V4 run checks P0 with the
  DOS layer drawn and with switching in one variation; the DOS-only zoom determinism is ext_zoom's.
* **ext_zoom's matrix** (cost): the full product (win a/b, dos a/b, sw at every size, soak included) would be
  about 2.5 times D6c's section time.  Kept: win a/b everywhere (the Windows goldens, as D6c), dos a at every size
  of the scenarios (the DOS goldens), dos b and sw at 1920x1440 (Z-2 for the DOS layer, switching), the soak as
  win a/b and sw; the soak's DOS layer is checked through sw's `map dos` samples against win b's.  Measured
  privately: a DOS soak run takes about 12.5 minutes and a switching soak run about 14 minutes under the
  machine's other load; dos a and b of the soak at -1 had equal shows and equal per-profile samples, and those
  samples equal the switching soak's (393 switches) at all 78 sample times.  Run count 64 -> 108 (soak runs 4 ->
  6).
* **The profile chord at 40,000 ms** in ext_adapt's DOS pairs: the S3 lines up to then are Windows host forms
  (intro, menus, setup); switching after the setup keeps them valid and puts every zoom chord, wheel line and
  the ring click in the DOS profile.

## Deviations from the design

* **The DOS layer's palette step under `fit` sharp renders the whole image again** (M's deviation for the core's
  palette, now also for the play palette, which steps about every 220 ms): 54.2 / 33.5 ms per step at 2560x1600 (Checked, -1 / +1; 68.8 / 47.4 ms in
  Release under load, 47.3 / 31.6 ms in a quieter run), about every 220 ms, so up to a fifth or a quarter of one
  core while the DOS profile is zoomed under `fit` sharp; under nearest (integer and `fit` nearest) a step is a
  conversion of 1..3 ms.  The Windows profile's palette changes cost the same under sharp (M's existing deviation);
  they are rarer.
* **The DOS layer is not drawn while the DOS profile shows an N frame in play** (`dos_frame`): the zoom then
  shows that screen unzoomed; the geometry stays live.
* Files beyond the brief's list: `present/map/pmap.h` (the sample entry), `pmap_int.h`, `tests/headless/harness.c`
  (A-6's per-profile hashes), and D6cF's `pdos_replay.c`, `test_pdos_replay.c`, `test_pdos_profile.c`,
  `docs/ext-D6c-record.md` (its Review note).

## User direction 2026-10-16 (no added Go Back / Cancel rows) and checklist item D5-7

* D6d adds no row, box, dialog or menu and draws nothing over a dialog: the layer is clipped to the map client's
  visible region as before (a dialog is a window over it).  No DOS screen gains a dialog, so no Escape case
  arises; none is recorded.
* Checklist item D5-7 (the first D6 unit that makes a re-skinned DOS menu or message box visible in play names
  the screen, steps, dialog and user build) is **not D6d's**: D6d shows no re-skinned box; it stays D6f's.

## What the user checks

On the coordinator's user build of the landed tree (`civ64.exe`, DOS files present), in play (load a saved game or
start a new one) with the DOS graphics (`--graphics dos` or Ctrl+Shift+Backspace):

1. **Zoom out (-1) in DOS graphics.**  Ctrl+Shift+Minus (or the system menu's "Zoom out (half)"): the DOS map at
   half size around the core's view, and the explored world beyond it in DOS art (the DOS ring): terrain, coasts,
   rivers, roads, improvements, cities with their DOS outline and size, units in their colours, black where
   unexplored; at every window size and display factor the DOS pixels are square and even (pixel-perfect).
2. **City names on the ring.**  Cyan with their shadow at the DOS position below each city, not cut at the
   view's edge; a name past the map's east edge continues at the west edge.
3. **Zoom in (+1) in DOS graphics.**  Ctrl+Shift+Plus: the DOS map at double size following the active unit
   with a one-square margin; Ctrl+Shift+0 back to normal; the mouse wheel over the map zooms with the point under
   the pointer kept.
4. **A ring click.**  At -1 a left click on a ring square recentres the map there, as a click in the World Map
   would; a click beyond the poles does nothing.
5. **The cycling colours when zoomed.**  At -1 and +1 the DOS map's cycling water colours keep stepping at the
   game's pace, in view and on the ring.
6. **Switching while zoomed.**  Ctrl+Shift+Backspace at -1 and at +1: the other profile's map at the same level,
   centre and window; back again: the DOS map, at the same place.

Not part of this check: the World Map, the Status window and the unit panel (D6e); the menu bar, drop-downs and
message boxes in play (D6f); the city screen and other in-game screens (D7).

## D6cF (the D6c review, folded in; the orchestrator, about 11:00 UTC)

The user's other chat verified D6c's palette cycling read-only against the listing: as designed and matching
the listing, no defect.  Its follow-ups:

* **R2 (fixed).**  `pdos_replay.c` `nearest_rgb` (lines 587..612 of the staged copy; the base's 499 and 587..603)
  searched the whole DAC: on the A machine's DAC a replayed colour could map to a play slot 60h..7Fh and then
  cycle with the slots.  The search now skips 60h..7Fh on the A DAC (`dac == &pdos_ma()->dac`); the N machine's
  DAC has no play slots and is searched whole.  Vector: test_pdos_replay `test_nearest_play` (above).
* **G2 (tests).**  test_pdos_profile `test_play_cycle` and the test_map element check (above).  The existing feed
  near the base's line 515 (case 5 of the visibility test: a cycle probe without an assertion) stays as it is;
  the new test asserts what that probe does.
* **R1 (recorded as intended).**  The step is taken at CyclePaletteColors' entry probe, before the core's
  `g_noPaletteDevice` early return (seg066_1208_p2_r.c:33..36): under the 16-colour switch the DOS slots step
  while Windows' do not.  DOS-faithful: the DOS program cycles its slots regardless of a Windows palette device.
* **G1 (for the records):** FIDELITY F133's clause, under "For the records".
* **G3 (for the records):** draft D 14.7's "inferred" direction and checklist D6c-5's wording, under "For the
  records".
* **R3 (for D6e).**  The DOS return path R:0238:1BEB restarts the slots through R:1DC4:0626 / 03FA without
  capturing again (the position is kept); draft B 5.5 item 2's `pdos_play_back` captures again and resets to
  position 0.  D6e keeps the position or records a deviation.

## For the records

* **DESIGN 12.9 "As implemented (D6d; area D)":** the layer for both profiles (live and drawn; the core frame's
  layout; evaluation at core presents and ticks; `layout_wait`, `dos_frame`, `dos_wait`), G_dos (1280 x 800 DOS
  indices by square keys, labels at 14.5's ring position without clamp or truncation, the k = 1 pen), M_dos
  (Wn_dos over P_dos at each core present), the play palette's conversion (`pmap_dos_xrgb`, `dos_reconverts`),
  `pmap_layer_sample` and profiles.log's per-profile `map` hashes; the decisions and the known limit above.
* **Draft D:** 14.7 "positive direction (each entry takes its lower neighbour's colour, **inferred**)" is proven
  by the listing (R:0000:0471..04A1, the slot rotation; G3): drop "inferred".  14.7 "Open for D6: L12": read,
  no cycling over faded entries in the play return path (section "OPEN L12").  14.9 and 6.2: as built.  16.3:
  the matrix and checks above (`win a/b`, `dos a/b`, `sw`; the goldens' `dos` lines).  16.4: V4d.  16.5: the
  DOS pairs.  17 A-6: `map <profile> <sha>` per profile, XRGB.
* **Draft B 5.5 item 2:** R3 (`pdos_play_back` and the DOS return path's kept position) for D6e.
* **FIDELITY F133** (G1), a clause: the DOS map's cycling steps once per core `CyclePaletteColors` entry, about
  every 220 ms (the core's timer), against the DOS program's 15 frames (about 214 ms at 70 Hz); it pauses while
  the core does not pump messages or while `g_mapWindowLocked` is set; its direction is the reverse of the
  Windows palette's 64..71 rotation; under the 16-colour switch the DOS slots step and Windows' do not (R1).
* **manual-checklist-ext.md:** D6c-5's "palette slots 96..127" should say that only 96..111 visibly cycle on the
  map (PALETTE.md 5: map sprites use indices within 0..111 and 255; G3).  D6d's six checks above (new items
  D6d-1..D6d-6).  Item D5-7 stays open for D6f.  Item M-1's DOS sentence ("In DOS graphics level -1 is
  pixel-perfect at every factor") becomes checkable with D6d.
* **DOS-PROFILE.md:** row 96 (the map, class A): the zoom and the ring done (D6d); row 107 (T7, the palette
  cycling): the DOS layer converted at each step; OPEN L12 read (above).
* **RUNNING.md:** `profiles.log`'s `map <profile> <sha>` fields (one per profile with a layer sample; XRGB);
  `presentation-diag.log`'s new `pmap` fields; ext_zoom's options (`--profiles`, `--sizes`, `--exe`, `--root`,
  `--port`) and its matrix and checks; ext_p0's V4d; ext_adapt's zoomkeys-dos and ring-dos.
* **FEATURES.md:** the zoom levels and the ring in the DOS profile (D6d), with the runners above.
* **STATUS.md:** D6d done (with D6cF); D6e next.
* User direction 2026-10-16 (no added Go Back / Cancel rows): nothing added by D6d, nothing to record.
* Not edited by this unit (as the brief says): DESIGN.md, FIDELITY.md, STATUS.md, RUNNING.md, FEATURES.md,
  DOS-PROFILE.md, manual-checklist-ext.md, the D1 drafts and the D0 documents.

## Landing (2026-10-16, build slot)

**Landed 2026-10-16 14:04:09 UTC; cycle ALL_GREEN 14:34:38 UTC; RELEASE_OK 14:39:06 UTC; user build
`build/user-builds/d6d/`.**  Done by the build slot on the orchestrator's instruction (about 13:58 UTC), after the
docs pass for D5K, UX3, D5K2 and SL (`build/docs-sl-done.txt`, 14:03:46 UTC, not BLOCKED).

1. **Bases.** `build/d6d-prep/land.py`: all 17 tree files still had their bases (`BASE-SHA256.txt`, written
   13:56 UTC; the docs pass touched none of them), this record was absent, test.cmd still had its base
   (c92811a3..., with UX3's and SL's sections), and the 18 staged copies had the SHA-256 frozen in
   `build/d6d-prep/staged.sha256`.  No rebase was needed.
2. **Snapshot, copy and test.cmd.**  Before writing: the tree's Checked test outputs (59 files of
   `build/test/Checked`, SL's -r2 cycle) in `build/d6d-prep/before`, the tree's previous files and test.cmd in
   `build/d6d-prep/tree-before`.  The 18 files byte for byte (17 changed, this record new); test.cmd patched by
   `obj/patch_testcmd.py` (the seven replacements of BUILD-TEST-ADDITIONS.md, CRLF kept; SHA-256 5f6ddf6c...,
   558 lines); `testpar.py check test.cmd` exit 0; manifest `build/d6d-prep/landed.sha256`.
3. **Cycle** (`build/d6d-prep/d6d-cycle.ps1`, SL's script with the D6d names; status `build/d6d-status.txt`, logs
   `build/d6d-<n>-<step>.log`):
   - 1 build-checked: exit 0, 241 s, BUILD_OK.
   - 2 test-checked: exit 0, 1580 s, TESTS_OK (no w32 flake this time).
   - 3 g1-checked: exit 0, EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events): **ALL_GREEN**.
   - 4 build-release: exit 0, 261 s, BUILD_OK, portable sources 293: **RELEASE_OK**.
4. **Comparison** (`build/d6d-prep/compare.py`, output `compare.txt`; the predictions in
   `build/d6d-prep/predictions.txt` were written about 14:00 UTC, before the landing): 50 of 59 files equal (lines
   with times left out).  The differences:
   - `ext-p0.txt` and `sections/ext_p0.log`: the 81 `PASS V4d ...` lines and "V4d: the map layer was drawn in the
     DOS profile in 22 runs, in the Windows profile in 22"; `P0_OK checks 394 -> 476`. Predicted.
   - `ext-adapt.txt` and `sections/ext_adapt.log`: the five D6d PASS lines (DOS shows 74 and 155), the new echo;
     `EXT_ADAPT_OK checks 123 -> 128`. Predicted.
   - `ext-zoom.txt` and `sections/ext_zoom.log`: every ZOOM line with `dos` (and `sw` at 1920x1440) shows, the new
     echo; `ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32` (was runs 64 samples 388). Predicted.
   - `sections/unit.log`: test_map 208 -> 248, test_pdos_profile 40 -> 51, test_pdos_replay 84 -> 86, as predicted;
     the OBS_COST line's nanoseconds (a timing line the filter keeps).
   - `nodos.txt`: 1724 -> 1725 files, more bytes, 0 hits. Predicted "the same file count": the new file is this
     record (`docs/`), which nodos scans like every file of claude/port outside `build/`.
   - `sections/times.txt`: section times.  ext_zoom 1353 -> 1562 s (its soak stays the critical path), ext_p0
     1485 -> 1166 s and ext_adapt 600 -> 512 s (both on a less loaded machine than SL's cycle), wall 1748 -> 1578 s.
   Every other output equal, as predicted: ext_frames, ext_timeline (both groups), ext_continue, ux3_aspect,
   bs1..bs3, ext_mirror, ext_replay, ext_slots, gate3b, uninit, scenarios, p4tests, harness_stub, d2_registry
   (dos-decoded.txt), d3a_obs_tables, d3a_obs_lint (files 119), d4a_pdos_scene, d4c1_adapters, coverage.
5. **User build** `build/user-builds/d6d/`: `civ64.exe` (the Release build, SHA-256 ff45845d...fd17040),
   `CIVWIN.zip` and `civdos.zip` (byte-identical copies from `user-builds/d4`) and `WHAT-TO-CHECK.txt` (D6d-1..D6d-6
   and checklist M-1's DOS sentence in plain words; Ctrl+Shift+0 still does nothing, M-3's open report, UX4's, so
   the system menu's "Normal map zoom" is named instead; the builds it contains: sl, d5k2, ux3, d5k, d6c, ux2, d5).
6. **Not done here**: the entries of "For the records" (DESIGN, draft D 14.7/16.3/16.4/16.5/17 A-6, draft B 5.5,
   FIDELITY F133, the checklist's D6c-5 wording and D6d-1..D6d-6, DOS-PROFILE rows 96 and 107, RUNNING, FEATURES,
   STATUS) are the docs pass's.

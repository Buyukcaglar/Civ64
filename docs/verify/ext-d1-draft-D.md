# D1 draft D: the map renderer and zoom (phase M, backlog) and the DOS map (D6)

Draft of 2026-10-11 by design agent D1-D, for merging into `DESIGN.md` 12.5 onwards. It covers
extension 5.8 with the user's decisions, Z-1..Z-3, 7.5, the zoom part of 7.3, 7.4 and 7.8, and
the DOS map rules of phase D6. It uses area A's interfaces ([ext-d1-draft-A.md](ext-d1-draft-A.md))
and names every change it needs from them (section 17). Windows facts come from `claude/docs`,
`claude/src` and `showfunc.py`; DOS facts only from `docs/dos/SCENES-PLAY.md`, `SPRITES.md`,
`PALETTE.md`, `FORMATS.md`, `DRIVER.md`, `OPEN.md` and `DOS-PROFILE.md`, cited by section (they
are under correction), and the DOS listing `build/dos/disasm/root.lst` where noted.

**Revision 3 (after RV2)**, applying [ext-d1-review-rv2.md](ext-d1-review-rv2.md) as
[ext-d1-decisions.md](ext-d1-decisions.md) "Design review RV2" resolves it, and decision X5:

* **RV2-1 (blocker).** 17 A-7 is corrected: DrawMapTile, DrawUnitAt, DrawCityLabels and WdwMapOpen
  were in A's list with WI's entry phase only, so 9.3's DROP brackets never closed. A 4.3 now gives
  them E and X; 9.3 says every macro key needs the exit.
* **RV2-3 (major).** 12.1 separates a press from the parts of a held press: a ring press's moves and
  release are frame 4 wherever they happen, a view press's moves and release stay frame 3 at the
  clamped point, a press off the layer never becomes frame 3 or 4 (A 10.1's press latch). 12.2 relies
  on it; 16.1 and 17 A-5 say so; Choice 20.
* **RV2-6.** `pmap.h` declares `pmap_filter_ring` and the exported read interface
  `pmap_src_current()`, `pmap_view_current()` (3, 7.2, 12.2). The types take the prefix: `PmapSrc`,
  `PmapSnap`, `PmapView` (were `MapSrc`, `MapSnap`, `MapView`), with `pmap_src_snap` and
  `pmap_src_live`.
* **RV2-7.** 9.3 and 9.4 use B's interface: `PdosMacro` with `PDOS_MAC_DROP` on DrawMapTile, DrawUnit,
  DrawUnitAt, DrawCityLabels and `PDOS_MAC_CONTEXT` on AnimateUnitMove and ResolveCombat; `target`
  returns 0 for "not ours"; registration with `pdos_shadow_macros("pmap", ...)` and
  `pdos_shadow_hooks("pmap", ...)` from `pmap_reset`. The proposed `PsMacro`/`ps_register_macros` are
  withdrawn; Open D10 is closed.
* **RV2-8.** 14.0 adopts E.9.2's form for the page-2 rectangles (`pdos_pic(PDOS_F_SP299_PIC)` inside
  `PDOS_PAGE2_ART_*`, the map's own constants citing R:1AEA:03BA and 07B2..07CD); 14.0's family table
  uses E's `PDOS_SH_*` names. Choice 18 changes; Open D9 is closed; 17 E-1 is answered.
* **X5.** L17 → L23 in 14.3, 14.5, 17 B-4 and Open D6 (B 10.1 answers font 1, inferred).
* Revision 2's 9.3/9.4 text is kept in scratch (`build/d1/scratch-int/d_sec9_rev2.md`).

**Revision 2 (after RV1)**, applying [ext-d1-review-rv1.md](ext-d1-review-rv1.md) and the
orchestrator's resolutions in [ext-d1-decisions.md](ext-d1-decisions.md) ("Area D" C1..C7,
"Design review RV1"):

* **RV1-1 (blocker).** The DOS map and icon shapes come from area E's shape-cut module
  `pdos_shapes`, which reproduces the start-up cut O5:1455. Section 14 asks for shapes by family
  and index (14.0); only tables below DGROUP:6B30h (1946, 1956) go through `OFFSETS.md`. The false
  claim "the tables D4CE, ... through the offset registry" is gone (14, 17 "Area E").
* **RV1-16.** Row 4' of 14.2 cites E's TER257 row rule (SPRITES.md 4, DGROUP:1A3E taken as 0):
  Tundra, Arctic, Swamp and Jungle show one shape for every mask.
* **RV1-2.** `present_map_point` (a name `scale.c` already uses) becomes `pmap_layer_point`; every
  public function of the module takes the `pmap_` prefix (3, 5.3, 12, 13, 17).
* **RV1-3.** Files are `present/map/pmap_*.c` and `pmap.h`; build.cmd's portable loop (line 68),
  `INCS` (35) and the clang-tidy include list (83) gain `present\map` (3).
* **RV1-4.** The section-17 requests to A are accepted (A-1..A-8, marked so); `w16q_sys_track`
  needs new w16 state (the outline rectangle is only `movesize`'s local `cur`), and `w16q_draw_on`
  a rasteriser refactor; both are in A's K2 list under G-1 (17). Requests to B stay B's (RV2).
* **RV1-5.** Every DOS run of 16.3 and 16.4 passes `--dos-data build\dosdata`; the runner checks
  in `profiles.log` that the switches happened and none was refused.
* **RV1-20.** 450x350 is the window's minimum; at +1 the smallest layer holds about 6x4 whole
  squares (4.3).
* **C1..C7 as resolved** (22): C1 the user's halving and doubling, odd-k level -1 is the recorded
  2:1 reduction, `--zoom default|-1|0|+1`; C2 M's gate is the M1 checks, M2 is built and gated
  with D6; C3 recorded; C4 B designs the A canvas at the screen's current size; C5 one shadow
  engine in B, the map handlers register there (9); C6 the recentring small-map click is kept and
  listed for the user's check; C7 B owns the DOS small map, status window and unit panel (14.8).
* **Checked against the listing:** the sentry and city recolour rectangles of 14.3 and 14.4
  (R:1AEA:1191..11CC, R:1AEA:0CB4..0CEA); the move/size loop's outline calls (user_syscmd.c 160..298);
  w16's frame and scroll-bar metrics (user_misc.c 50..78).

Notation used throughout:

* **Map pixel**: one pixel of the core's map client (a Windows device pixel; 32 per square).
* **World pixel** `(X, Y)`: the map pixel of the whole 80x50 world, `X = 32·col + dx`,
  `Y = 32·row + dy`. The world is 2560x1600 world pixels; X wraps modulo 2560, Y does not.
* **DOS art pixel**: one pixel of the DOS map art, 16 per square, so 2x2 map pixels.
* **Client**: the map window's client, `Cw x Ch` map pixels; its screen origin `(cx, cy)`.
* **View**: `Xv = 32·g_mapViewLeft + g_mapScrollX`, `Yv = 32·g_mapViewTop + g_mapScrollY`
  (1330:4010, 1330:400E, 1408:00C6, 1408:00C4). The client shows world pixels
  `[Xv, Xv + Cw) x [Yv, Yv + Ch)`, X taken modulo 2560.
* **Layout** `L` (`present_view_layout()`): logical frame `W x H` (the virtual screen during play),
  image `SW x SH` at `(ox, oy)` in the host client.

## 0. Authority points relied on

| Point | Source | Effect on this design |
|---|---|---|
| M is a backlog item; it resumes after D3 | STATUS "Extension track" M row; user 2026-10-10 22:50 | Phase M follows D3 (its probes and queries). D6 adds the DOS rules. |
| Three levels -1, 0, +1: "every step halves or doubles with respect to default resolution" | user 2026-10-10 21:00; M row | Replaces 5.8's integer steps `m+1`, `m-1` and the 3x3 maximum search (section 4). |
| The 5.8 design, not the resolution-based alternative | user 2026-10-10 22:45 | A map layer in the presented picture; a renderer in `present/map/`. |
| Planned shape: in view the core's own map-client pixels; out of view (level -1 only) a read-only renderer, proven by mirror equality on in-view squares | M row | Section 6 (Windows in-view source), 7 (ring), 10 (proofs). |
| `stretch` is removed | DESIGN.md 12.2, phase G | Policies are `integer` and `fit` only. |
| The virtual screen follows the host client during play (F105, F110); max 2726x1600 | DESIGN.md 12.4 | The map client can change size at any time; the layer re-anchors (section 11.3). |
| C1..C7 and RV1-1..RV1-20 | ext-d1-decisions.md | Applied as listed under Revision 2. |
| K1 resolution: scoped P0; the zoom never feeds `present_game_screen_follow` | ext-d1-decisions.md | Section 1 item 4. |
| Asan deferred to the end of the queue | user 2026-10-10 21:20; K8 | `test_map` and the zoom runs are recorded in Checked and Release; Asan at the final pass. |
| Area A's observer, probes, `w16q_*`, tick, input stages, harness commands | draft A sections 3..12 | Used as written; changes in section 17. |
| DOS-PROFILE.md rows 96, 107, 132..135, 139, 140: the map is class A, the core's decisions drive it | DOS-PROFILE.md; its 0.6 rule 1 | Section 14. |

## 1. P0 in one page

P0: nothing in the zoom, the layer or the map renderer can change a checkpoint, the virtual screen
or the base event trace (`run.log` frame, snapshot and result lines, and `events.log`).

1. **Reads only.** `present/map/` reads the emulation only through `w16q_*` (area A section 5) and
   its own copies. It never calls a `w16_<Api>`, never writes emulated memory, never allocates
   in the emulation. `obs_lint.py` (A 6.2) covers `present/map/*.c` like the rest of `present/`.
2. **Probe callbacks copy and return.** Every map probe handler (section 7.1, 9) reads arguments
   and globals and copies bytes into presentation memory. The Checked guard `W16_OBS_GUARD`
   (A 6.1) traps any emulated write or `w16_` call inside them.
3. **No RNG.** The renderer never draws random numbers. `HasSpecialResource` (1110:1C72) and
   `HasHut` (1110:1CD9) read `g_randomSeed` (13C0:0000), the stored world seed, as a value. That
   is not `g_randSeed` (1420:4EE0), which `w16q` refuses (A 5). The dissolve order is taken from
   the core's own `DrawMapTile` sequence, never recomputed.
4. **The zoom is not a core input.** The zoom state lives in `present/map/`. It never reaches
   `present_game_screen` or `present_game_screen_follow` (K1): those use only the 640x480 layout
   and the host client, as DESIGN.md 12.4 delivered them. The layer is drawn in host pixels
   after the scaler; `g_win`, the S1 relation check and `host_present` are unchanged.
5. **Commands post nothing.** The zoom chords are consumed under A's modifier hold rule (A 10.2),
   the wheel never becomes an event (I8), the system-menu items run in the host's menu loop, and
   the harness `zoom` command calls only `pmap_request_zoom` (A 12.1). None posts an event.
6. **Input mapping changes only host-produced input.** The layer decides which core input a
   host action produces (5.8). P0 runs inject core input after the filter (7.3), so the mapping
   is outside what P0 compares. It is tested by 7.8 (section 16.5).
7. **No virtual time.** All work runs inside probes, `present_core` and the tick; it reads the
   clock only through `w16q_now_us()` (free). In the harness (virtual clock) host time spent in
   the layer cannot move any virtual time. Under `--timing host` the base trace is not
   deterministic in any case (user timing).

**Tests that catch a breach.**
* `ext_p0.py` variation V4 (A 13.1): scripted `zoom` commands in every scenario, with a host size
  given so that the layer is active, in the Windows profile at M and in both profiles from D6.
  Every checkpoint, core frame hash and `events.log` must equal the plain run.
* The `CIV_OBSERVER=0` build (A 9) refuses `zoom` and `--zoom`; its plain matrix equals the
  frozen baseline (G-1).
* The Checked guard during every V4 and mirror run (section 10).

## 2. Phases and scope

| Part | Phase | Contents |
|---|---|---|
| M1 | M (after D3) | zoom state and commands; the layer (clip, composition, damage, palette); the Windows in-view source `M`; the state snapshot and the Windows ring renderer; layer input; the settled mirror checks (key, render, square equality); V4; zoomed-frame tests |
| M2 | D6 | the map display model: handlers in area B's shadow engine that follow the core's map drawing, with two rule sets, Windows (the 7.5 per-present oracle) and DOS (the D6 map) |
| D6 | D6 | DOS rule set: squares, units, cities, labels, edges, animations, the map palette; the DOS ring; zoom in the DOS profile |

**Split M1 and M2 (resolved, C2).** M's gate is the M1 checks: key, render and settled
port-bitmap equality (10.1). The per-present comparison (M2) is built and gated with D6, which
needs the same model to follow each core drawing event with DOS art. 7.5's "at every present" is
therefore met at the D6 gate. **Met at the D6 phase gate** (D6g, 2026-10-17; 16.2).

**Not zoomed** (5.8): the small map (`WdwSmMapProc`, 1210), the status window (1218) and the
World Map report (`ShowWorldMap` 1188:013F, scale 6/32). The layer covers only the client of the
map window of class `CIV` (`WdwMapProc` 1208:0054). Recorded in RUNNING.md and FIDELITY.md.

**As built (MZW, 2026-10-16; the user's request on D6d-6).** The World Map's image is still not zoomed, but its view
rectangle follows the level: at -1 and +1 the small map outlines the layer's world area instead of the core's view
(5.6 below; FIDELITY F185, F132). The status window and the World Map report are unchanged ([MZW
record](../ext-MZW-record.md)).

## 3. Files and modules

Base names are unique across the build (build.cmd names objects by base name, `%%~nf.obj`,
lines 71, 77, 89; A has `present/input.c`), so every file takes the `pmap_` prefix, as E's take
`pdos_` (RV1-3).

| File | Contents |
|---|---|
| `present/map/pmap.h` | the interface to the rest of `present/` (below) |
| `present/map/pmap_zoom.c` | zoom state, levels, geometry (section 4), anchoring and the active-unit rule (11), requests and refusals |
| `present/map/pmap_layer.c` | the clip region, the layer index image, composition into the view, damage, palette conversion (5) |
| `present/map/pmap_inview.c` | the Windows in-view source `M` (6.1); the DOS one comes from `pmap_model.c` (6.2) |
| `present/map/pmap_snap.c` | the state snapshot, its triggers and the view snapshot (7.1) |
| `present/map/pmap_state.c` | `PmapSrc`, the read interface over a snapshot or over live memory (7.2) |
| `present/map/pmap_win.c` | the Windows rules: key, render-from-key, square, fog edges, city marker, units, labels (7.3) |
| `present/map/pmap_dos.c` | the DOS rules (D6, section 14) |
| `present/map/pmap_world.c` | the world canvases (the ring source) per rule set (7.4) |
| `present/map/pmap_model.c` | the map display model: handlers registered in B's shadow engine (M2, section 9) |
| `present/map/pmap_check.c` | the mirror checks of the harness (10) |
| `present/map/pmap_input.c` | layer input mapping and the out-of-view press (12) |
| `tests/test_map.c` | unit tests (16.1) |
| `tests/harness/ext_mirror.py`, `ext_zoom.py` | 7.5 runs and zoomed-frame goldens (16.2, 16.3) |

**Build.** build.cmd's portable loop (line 68) gains `"%PORT%\present\map\*.c"`, `INCS` (line 35)
gains `/I"%PORT%\present\map"`, and the clang-tidy include list (line 83) gains
`-I"%PORT%\present\map"`, as E adds `present\dos`. Every file gets the same c11, c17 and C99-parse
checks as the rest.

> **C passage condensed for the public copy.** The original record has here a block of 19 lines of C declarations: functions `pmap_reset`, `pmap_on_event`, `pmap_on_probe`, `pmap_on_core_present`, `pmap_request_zoom`, `pmap_level`, `pmap_pending`, `pmap_overlay` and 6 more. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

`present_map_point` (scale.h:96, scale.c:424, a layout's client-to-logical mapping) keeps its name
and meaning.

The map module is shared by both profiles. Each profile supplies its in-view source and its rule
set; the zoom state and the geometry are common, so a profile switch keeps the zoom and the
layer's position (**Choice**; alternative: a zoom per profile, which would jump at a switch).

## 4. Zoom levels and geometry

### 4.1 Levels

The level `l` is -1, 0 or +1. Level 0 is the default: no layer, the base frame shows the map as
it is (5.8 "Default"). The scale of level `l`, in host pixels per map pixel, is the frame's own
factor times `2^l`:

* horizontally `s_l = (SW / W) · 2^l`, vertically `t_l = (SH / H) · 2^l` (rational, exact);
* under `integer` `SW = k·W`, so `s_l = k · 2^l`;
* a DOS art pixel is 2 map pixels, so the DOS profile shows `m = 2·s_l` host pixels per DOS art
  pixel: `2k` at level 0 (5.8 "2·kx"), `k` at -1, `4k` at +1.

The squares are therefore the same host size in both profiles: `32·s_l`.

**Under `fit` the levels halve and double the frame's own factor** (resolved, C1: the user's
direction "halves or doubles with respect to default resolution" wins over 5.8's "integer
nearest to the factor", which would not double the default: for SW/W = 2.4, +1 would be 1.67x).

| Policy, factor | Level -1 (Windows / DOS) | Level +1 | Pixel-perfect |
|---|---|---|---|
| integer k = 1 | 1/2 map pixel per host pixel: the 2:1 reduction (5.8's half level) / DOS m = 1 | 2 | Windows -1 no (the recorded half level); DOS -1 yes; +1 yes |
| integer k = 2 | 1 / m = 2 | 4 | all yes |
| integer k = 3 | 1.5 / m = 3 | 6 | Windows -1 no (see below); DOS -1 yes; +1 yes |
| integer k = 4 | 2 / m = 4 | 8 | all yes |
| fit, factor f | f/2 | 2f | as level 0: the frame's filter (nearest or sharp) |

* **Odd k (resolved, C1).** At k = 3, level -1 gives each pair of map pixels 3 host pixels (2 and
  1). The square grid stays exact (a square is 48 host pixels, since 32 is even), but the pixels
  inside it are uneven. With the user's halving, Windows level -1 is pixel-perfect only for even
  k; at odd k (the user's own window: 1920x1440 on 2560x1600 gives k = 3, STATUS phase G) and at
  k = 1 it is the recorded 2:1 reduction of 5.8's half level, not pixel-perfect, labelled so in
  RUNNING.md and FIDELITY.md. In the DOS profile level -1 is pixel-perfect for every k (4.2).
* **Filter.** Under `integer` the layer samples nearest. Under `fit` it uses the frame's filter:
  nearest, or sharp area weights over map pixels (section 5.4).

### 4.2 Layer coordinates

* `Rc` is the client's host rectangle: `present_host_rect_inner(L, client)` (section 17, B-3, a
  scale.c helper; under `integer` and under `fit` with nearest it equals `present_host_rect`).
* The layer origin `(Xo, Yo)` is the linear world pixel shown at host `(Rc.l, Rc.t)`.
* Host column `hx` shows world column

  ```
  l = +1: X(hx) = Xo + floor((hx - Rc.l) · W / (2 · SW))
  l = -1: X(hx) = Xo + floor(2 · (hx - Rc.l) · W / SW)
  ```

  in 64-bit integers, and the same for rows with `H`, `SH`, `Yo`. Under `integer` this is
  `floor((hx - Rc.l) / (2k))` and `floor(2 (hx - Rc.l) / k)`.
* **Even origin at -1.** `Xo` and `Yo` are even at level -1. Then every aligned pair of world
  pixels `(2i, 2i+1)` covers exactly k host pixels under `integer`, so DOS art pixels, which
  always start at even world pixels (section 14.1), are k x k blocks: DOS -1 is pixel-perfect for
  every k. At k = 1 Windows -1 shows the even world pixels (the half level).
* The layer's world extent is `Wl = ceil((Rc.r - Rc.l) / s_l)` by `Hl = ceil((Rc.b - Rc.t) / t_l)`.
* A world pixel `X` (linear) is in view when `Xv <= X < Xv + Cw` and `Yv <= Y < Yv + Ch`; its
  client pixel is `(X - Xv, Y - Yv)`. Other copies of the same square (after wrap) are ring.

### 4.3 Limits

* **+1** needs at least 3x3 squares in the layer (5.8's maximum rule): `Wl >= 96` and `Hl >= 96`
  world pixels, that is a client of at least 192x192 map pixels.
* **The smallest map window (RV1-20).** `WdwMapProc`'s WM_GETMINMAXINFO sets the minimum *window*
  size to the track limits 450x350 plus `SM_CXFRAME`/`SM_CYFRAME` (showfunc 1208:0054), 453x353
  under w16's metrics (user_misc.c 77..78). The window is `WS_OVERLAPPEDWINDOW | WS_HSCROLL |
  WS_VSCROLL` with the game's menu (`WdwMapOpen` 1208:0AF1), so its client is smaller by the
  frames, the caption, the menu bar and the scroll bars (user_wnd.c 26..29, 247..254): about
  431x294 map pixels with a one-line menu bar. At +1 that layer holds about 6x4 whole squares
  (6.7 x 4.6), so the 3x3 rule holds at every size the player can reach by sizing and bites only
  for smaller clients (none known). A request that fails it is refused with the reason "map
  window too small"; a resize below it while at +1 sets level 0.
* **-1** is always possible while a map window exists.
* **No map window** (title, setup, before `WdwMapOpen` 1208:0AF1): requests change the level, the
  menu shows it, nothing is drawn until the map window exists (**Choice**; alternative: refuse,
  which loses a remembered zoom).
* Coordinates are 64-bit in the mapping; host sizes are at most 32767.

### 4.4 East-west wrap and poles

* X wraps modulo 2560, as `WrapMapX` does for the core. At level -1 a client wider than 1280
  map pixels gives `Wl > 2560`: the world appears more than once. The repeated copies of the
  core's view are ring pixels, drawn by the ring renderer.
* Rows with `Y < 0` or `Y >= 1600` are black (the rule-set's black: Windows physical index of
  `BLACK_BRUSH`, DOS 0). The layer never wraps north-south.
* The core can itself show rows beyond the poles (without advance 8 `SetMapViewOrigin`
  1208:213B allows rows -25..75); those are in-view pixels and shown as the core shows them.

## 5. The layer

### 5.1 When it is active

The layer is active when all hold, checked at each show:
* level is not 0;
* the map window exists (`g_mapWindowPort` 12B0:0004 has a window), is visible and not iconic;
* its client's visible region is not empty and has at most 64 rectangles (`w16q_wnd_client_vis`,
  section 17);
* the view snapshot's client size equals the window's current client size (section 7.1; between
  a host resize and the core's WM_SIZE handling, `ResizeMapWindow` 1208:0F62, they differ);
* the host view is attached (Win32 always; headless with `--host-size`).

Otherwise the base frame shows the map unzoomed. Each inactive reason is a diagnostic counter
(`map_rgn_overflow`, `map_size_wait`, `map_no_view`), never an error.

### 5.2 Clip

* The client's visible region from `w16q_wnd_client_vis(hwnd, &cx, &cy, &rgn)`, in screen
  coordinates. w16 already subtracts overlapping windows, dialogs and the open popup menus
  (`user_wnd.c` `vis_region`, the overlays of `w16_wnd_set_overlays`).
* Minus the move or size outline when one is shown (`w16q_sys_track`, section 17): the XOR band
  of `user_syscmd.c` `outline()` (3 pixels) is drawn straight on the screen; excluding it lets the
  dragged outline show through (**Choice**; alternatives: suspend the layer during the loop,
  which jumps to level 0; redraw the outline in host space, more code for the same picture).
* Each rectangle goes to host pixels through `present_host_rect_inner`: for the `sharp` filter
  this keeps out host pixels that blend map and non-map logical pixels, so a dialog border keeps
  its filtered edge (**Choice**; alternative: the outer rectangle, which paints map pixels over
  half-blended border pixels).
* The clip is recomputed at every core present and every tick show (the window tree only changes
  inside the core, so a comparison with the last clip is enough). A changed clip damages the union
  of the old and new clip.

### 5.3 Composition

* `LayerImg`: one byte per host pixel over the bounding box of the clip, holding the profile's
  palette index (Windows physical indices; DOS profile indices).
* For each host row in the clip: `Y = Y(hy)`; for each host column, through a column table
  `X(hx)` cached per geometry: black beyond the poles; else in view: the in-view source at the
  client pixel (section 6); else the ring source at `(X mod 2560, Y)` (section 7.4).
* The index image is converted to XRGB through the profile's current palette and written into
  the view buffer inside the clip only. Palette changes reconvert without re-rendering.
* **Where it runs.** `pmap_overlay(view, cw, ch, &host_damage)` is called after every write
  of the base frame into the view (A 8.3 CORE shows, A 7.2 tick shows, A 8.2 VIEW redraws) and
  before `host_show`. It (1) re-overlays layer pixels that the scaler just overwrote inside the
  clip, (2) renders its own pending damage, (3) unites what it wrote into `host_damage`.
* **Tick.** A layer change without a core present (zoom command, pan, palette, ring update) is
  shown at the next tick: A's tick step 4 becomes "if the visible profile shows the core frame
  and `pmap_pending()` is 0: return" (section 17, A-1, accepted by RV1-4).

### 5.4 Sampling

* Nearest: the column and row tables above.
* Sharp (only under `fit` with the sharp filter): area weights over map pixels from a scale.c
  helper `present_axis_taps(PresentTaps *t, int64_t num, int64_t den, int32_t first, int32_t n)`
  (section 17, B-3), applied to the XRGB values of the in-view source and the ring source. The
  layer then keeps an XRGB image instead of `LayerImg` (palette changes re-render).

### 5.5 Damage

| Cause | Layer damage (host) |
|---|---|
| core present with damage D (screen) | `D ∩ client`, through the in-view mapping, where in view |
| `M` refilled from the port (6.1) | the refilled client rectangle, mapped |
| ring update (a new snapshot shown) | the host spans of the re-rendered world squares and labels |
| zoom, pan, view snapshot, client move or size, layout change | the whole clip |
| clip change | old clip ∪ new clip |
| palette change | the whole clip, reconversion only |
| base-frame write inside the clip | re-overlay of those pixels from `LayerImg` |

### 5.6 The World Map's zoom rectangle (MZW)

**Implemented in MZW (2026-10-16; the user's request on D6d-6; [MZW record](../ext-MZW-record.md)).** The layer above
draws only into the map window's client; MZW adds a second presentation-only drawing, into the World Map's client of
the Windows profile's frame `g_win` (which the DOS profile's A frame copies), at -1 and +1 while the layer's geometry
is live (`present/map/pmap_smrect.c`, observer builds only). From the one geometry (7.4) the layer's world area
`[Xo, Xo + Wl) x [Yo, Yo + Hl)` becomes the rectangle `[ox + floor(Xo s / 32), ox + ceil((Xo + Wl) s / 32))` on the World
Map's image (origin `ox`, `oy` and scale `s` as DrawSmTiles 1210:09B4 lays it out), likewise for the rows, clipped to
the world's 50 rows (the layer shows black beyond the poles), the whole width when wider than 80 columns, framed as
the core frames its view (`(l, t, r + 2, b + 2)`), each border pixel also at x +- 80 s (the image's wrap); at level 0
the formula gives the core's own frame. The border is drawn in the index the core's white brush drew; the core's own
frame is hidden by the pixels the core's own drawing left under it, kept in a client-sized image rebuilt from the
observer's OBS_DRAW events on the World Map's window (a framed pixel never seen without the frame is kept as drawn and
counted, `smrect_unknown`); every other pixel stays the screen's. The patch runs at every core present over the World
Map's client and at the layer's update when the rectangle, the level or the World Map's place changed; leaving -1 or
+1 writes the screen's pixels back once. Nothing is written to the emulation and no random number is drawn (P0). S1's
relation check admits exactly the pixels the patch owns (`pmap_smrect_owns`); every other pixel is compared as before.
Tested by `test_map` `world_map_rect` and `ext_zoom.py`'s centring runs (FIDELITY F185).

**Since D6e (2026-10-17; [D6e record](../ext-D6e-record.md)).** The DOS profile's play view shows its own small map
(`pdos_aplay`, draft B 12.2) in place of the Windows World Map; `pmap_smrect.c` calls `pdos_aplay_set_zoom_area` at
each evaluation of the patch, so at -1 and +1 the DOS small map's outline (colour 15, one DOS pixel outside the area)
surrounds the same area, with its two east-west wrap copies; at level 0 the core's frame. The squares are not changed
by it (19, row 5.8).

## 6. In view: the core's own pixels

### 6.1 Windows profile: the mirror `M`

`M` is a client-sized index image (`Cw x Ch`) of the core's map client, kept in every profile at
every core present (O6), whether the layer is active or not, so that a zoom change at any time
finds it current (7.4).

* **Visible part.** For each core present with damage `D`: client pixels inside `D` and inside
  the client's visible region are copied from the virtual screen (`w16q_screen`). These are the
  core's map pixels at that present, animations included (the planned shape).
* **Covered or off-screen part.** Client pixels outside the visible region (under a dialog, or
  outside the screen) come from the map back port's bitmap: `g_mapOffscreenPort` (12D8:4542),
  bitmap handle at 12D8:455C, read with `w16q_bitmap`. `WdwMapProc` repaints the client with
  `BitBlt` from that port at the same coordinates (WM_PAINT, 1208:0054), and `ResizeMapWindow`
  (1208:0F62) recreates the port at the client size, so the port is what the client would show
  when uncovered.
* **Port changes.** `OBS_BITMAP` damage on that bitmap marks the rectangle pending; it is applied
  at the next core present, so `M` changes only at core presents and agrees with the presented
  frame in time (T-rules, 7.4).
* **Animation frames under a dialog.** The move and combat frames go from the scratch port to the
  window (`AnimateUnitMove` 11C0:2C32, `ResolveCombat` 1050), not to the map port. Where the
  client is covered, `M` shows the port, which lacks the moving sprite. Only visible when a dialog
  covers part of the client while a unit moves under it (**recorded**).
* **Sizes.** `M` is reallocated when the client size changes (black where it never had a pixel)
  and refilled whole at the next present. A port bitmap of another size than the client gives the
  covered pixels it has, the overlap at the same client coordinates (as WdwMapProc's WM_PAINT
  1208:0332 copies it; BitBlt copies no pixel outside the bitmap); a covered pixel it does not
  have, or every one without a bitmap, keeps M's previous pixel (`map_port_size` counts those
  presents). With civ64's layout the bitmap is 454 x 421 for a 453 x 421 client (extension MZS;
  before, those pixels were black and the layer drew a black block beside open menus and dialogs
  at -1 and +1, the user's MZW-8; [MZS record](../ext-MZS-record.md), FIDELITY F190).
* **Move outline.** The move or size outline's XOR band (`user_syscmd.c` `outline()`, 3 pixels)
  is drawn on the screen and is not among the visible region's exclusions; M takes its pixels as
  covered ones (the port's), so the layer shows no ghost of the outline (MZS); the layer's clip
  leaves the band itself out (5.2).
* **Cost.** One copy of `D ∩ client` per present; at most a client (4 MB at 2560x1600) per full
  redraw, about 1 ms.

### 6.2 DOS profile (D6)

The DOS in-view source is the DOS map display model of section 9: its window shadow `Wn_dos`
where the client is visible, its port shadow `P_dos` where covered. Both are shadows of area B's
engine (C5), at map-pixel resolution in the client's coordinates, with DOS art at 2x (the A
canvas's resolution). The A canvas has the virtual screen's current size and the Windows layout
during play (C4, area B), so its map client region is `Wn_dos` (B composes it, section 17 B-2).

**Implemented in D6d (2026-10-16).** `M_dos` is a client-sized copy of the map client's DOS pixels at
map pixels: `Wn_dos` where the client is visible (the map window's visible region), `P_dos` where it
is covered: each shadow's pixels where it has them (the overlap at the same client coordinates),
M_dos's previous pixel where neither has one, DOS 0 only where M_dos never had one (`dos_port_size`
counts the presents with a size that differs; MZS); Wn_dos never holds the outline's XOR band. It is filled at
every core present in every profile (`pmap_dos_inview_present`, after D6c's `pmap_dos_present`),
only the rows that changed (`dos_fills`), freed at level 0 and taken whole when the level leaves 0;
a copy at the core present keeps it consistent with the ring's snapshot instant, as `M` is for the
Windows profile. The layer draws the DOS profile only while it presents its A frame (`dos_frame`
otherwise: a DOS screen in play shows unzoomed) and `M_dos` is filled (`dos_wait` otherwise)
([D6d record](../ext-D6d-record.md); DESIGN.md 12.9 "As implemented (D6d; area D)").

## 7. Out of view: snapshot, rules and the world canvas

The ring is needed at level -1 only. Its pixels are drawn from game state "after each completed
core redraw, each unit move and each turn" (5.8), never from the live state at an arbitrary poll,
which can be the middle of a move.

### 7.1 The snapshot

> **C passage condensed for the public copy.** The original record has here a block of 17 lines of C declarations: types `PmapSnap`, `PmapView`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* `vis` copies 13E8:0009..13E8:0FAA: `DrawMapTile`'s fog test does not check the row
  (graphics.md 4.10.4 step 5, 6.1), so at the poles it reads index -1 or 4000. The renderer reads
  the same bytes.
* **Triggers** (probes; the handler copies with `w16q_read` and bumps `gen`):

| Probe | Phase | Filter | Takes |
|---|---|---|---|
| DrawTilesToPort 1208:1866 | X | `port` argument is `&g_mapOffscreenPort`, `g_cityScreenMapMode` (1330:0000) is 0 | snapshot and view |
| RedrawMapRect 1208:1534 | X | `window` is `&g_mapWindowPort` | snapshot and view |
| UpdateUnitSightAndContacts 11C0:0395 | X | none (a unit appeared or moved and its sight is applied) | snapshot |
| DeleteUnit 11C0:16A4 | X | none | snapshot |
| ProcessGameTurn 1088:0000 | E | none (each turn) | snapshot |
| BlinkActiveUnitUntilInput 11C0:0EC2 | E | none (the human's settled input wait) | snapshot |

* The view part is not taken while `g_mapWindowLocked` (12B0:0000) is set or
  `g_cityScreenMapMode` is non-zero: `ProcessCity` (1030) writes the view origin and zeroes the
  scroll temporarily, then restores them and redraws (mode 0), which takes the view again.
* **Why these.** `UpdateUnitSightAndContacts` runs after a unit has its new square and before its
  sight is used ("after a unit appears/moves to (x, y)", functions.md), so a move is complete;
  `RemoveUnitFromTile` / `AddUnitToTile` (1110:17BC / 1110:1767) would give mid-move states.
* **Cost.** About 92 KB per trigger: 5 to 8 µs. AI turns call `UpdateUnitSightAndContacts` up to
  a few thousand times (estimate), so at most about 16 ms per turn. Measured at M on soak S4 in
  Release, informational, as A 4.2 does for probes. **Choice: copy at every trigger in every run.**
  Alternatives: copy only while the layer is at -1 (breaks 7.4: a zoom at time t would see a
  snapshot from another time); copy at the next tick after a trigger (can catch a mid-move state);
  skip AI moves the human cannot see (needs a proof that nothing else visible changed).
* The snapshot is a pure copy; the ring is a pure function of the latest snapshot. The ring is
  rendered lazily (7.4), which does not change its content.

### 7.2 The read interface

> **C passage condensed for the public copy.** The original record has here a block of 9 lines of C declarations: types `PmapSrc`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* `pmap_src_snap(const PmapSnap *)` reads the copy. `pmap_src_live()` reads through `w16q_rd8`
  and small `w16q_read`s; the model (section 9) and the key check (10.1) use it at a probe, when
  the core reads the same bytes.
* **Exported (RV2-6).** `pmap.h` declares the read interface for the rest of `present/`:
  `const PmapSrc *pmap_src_current(void)` reads the latest snapshot (7.1), never NULL (before the
  first trigger it reads an all-zero snapshot), and `const PmapView *pmap_view_current(void)` the
  latest view snapshot. B's small map (B 12.2, Choice B17) uses them. The pointers stay valid
  until the next trigger; a caller reads them inside one callback. The types were `MapSrc`,
  `MapSnap` and `MapView` before Revision 3.
* Out-of-range reads return 0 and count `map_bad_read` (O3 style), never fault.

### 7.3 The Windows rules (`pmap_win.c`)

A presentation reimplementation of the drawing rules named by 5.8, from graphics.md 4.10 and
`claude/src`. It writes physical palette indices (w16 colour bitmaps hold system-palette indices;
`w16_BitBlt` copies them, gdi_draw.c 497) into a caller buffer. Shapes are read through their
handles (O3): shape blocks (`w*h + 6` bytes: width, height, pixels; graphics.md 2.4) with
`w16q_block` and `w16q_read`; cached bitmaps with `w16q_bitmap`.

| Core function | Reimplementation | Notes |
|---|---|---|
| `GetTerrainType` 1110:16C0, `GetKnownTileImprovements` 1110:19E0, `HasSpecialResource` 1110:1C72, `HasHut` 1110:1CD9, `IsOnMap`, `WrapMapX` | `mw_terrain`, `mw_known`, `mw_special`, `mw_hut`, ... on `PmapSrc` | terrain via `g_terrainByMapColor` (12D8:0000, read once); known improvements `px(x+80, y+100) + (px(x+80, y+150) << 4)` |
| `ComputeTileAppearanceKey` 1118:04B4 | `uint32_t mw_key(const PmapSrc *, int x, int y)` | graphics.md 4.10.1, every bit; the cache compares key and terrain |
| `RenderTileFromKey` 1118:0000 | `void mw_render_key(uint32_t key, int terrain, uint8_t out[32*32])` | graphics.md 4.10.2, with `OverlayTile`'s fast path that skips the bottom-right pixel of 32x32 overlays, key 0 = top-left pixel, `g_shapeTransparentColor` |
| `TileCacheLookup` 1110:030C, `TileCacheInsert` 1110:01A3 | none | the cache is a memo of (key, terrain); the world canvas is the ring's own cache |
| `DrawMapTile` 1110:04D0 | `mw_square(src, x, y, out, ox, oy)` | the 1:1 palette-device path only (w16 is a palette device; the map port is never scaled); fog edges (step 5, no row check); city marker (step 7: frame, light fill inset 3, white and dark 2-pixel pens, `g_mapSprites[28]`, size in CIV font 8 centred on x+16 at y+9 or the disorder shape at (+10, +4), inner black frame when a unit or a stored unit is there, walls); the flush is not part of the ring |
| `RedrawMapSquare` 1110:1461, `DrawUnitStack` 1110:1516, `FindBestDefenderInStack` 11C0:1A2C, `RateDefenderCallback` 11C0:1A81 | `mw_top_unit` | the core's choice, with no RNG: land defence by terrain halves x defence x 8 x (fortified ? 3 : 2), sea and air defence x 16, veteran +50 %, strictly highest, at most 10 stack members; at sea the stack's ship; foreign units only with their `visibleTo` bit; no units on city squares |
| `FindUnitAtTile` 1110:180E | `mw_unit_at` | read-only: the core repairs a stale occupancy byte and sets `g_foundUnitCiv`; the reimplementation computes the same answer without writing |
| `DrawUnit` 1110:0DBA, `DrawUnitAt` 1110:0FF6 | `mw_unit` | not drawn: a sentried non-sea unit on Ocean; stack shadow `g_mapSprites[64 + 32 civ + type]` at (+2, +2) when `nextInStack != 0xFF`; the sprite or its grey copy (sentry: dark to `egaNearest[8]`, light to `[7]`); fortified sprite 29; "F" (fortifying), "G" (goto) and the work letters R, I, ?, M, F, P at logical (vx+4, vy+7), colour 0x0B for civ 1 else 0x0F, font id 3, shadowed (`DrawShadowedScreenText` 10D8:01FA); the grey frame of the opaque bounds |
| `CollectVisibleCityLabels` 1208:1DD7, `DrawCityLabels` 1208:1F64, `DrawTextInRect` 1098:0ED1 | `mw_labels` | box (x-134, y+32, x+166, y+52), font 8 (`g_civFonts` 1420:5484 index 17), format 0x21 (centred, black shadow), colour `g_egaToSystemColor[14]` (12D8:45BE); whole labels (the core does not clip them to the update rectangle) |

* **Text and lines use w16's own rasterisers** through a pure query `w16q_draw_on` (section 17,
  A-3): `TextOut`, `DrawText` with an HFONT, `LineTo` with a pen width, `FillRect`, `FrameRect`,
  on a caller surface. One rasteriser for the core and the renderer; the mirror checks prove the
  rest.
* **Coordinates of units.** `DrawUnitAt` maps logical `(vx, vy)` with `MapLogicalPointToPort`
  (1220:0F2F): `x = (vx - 200)·2 - g_mapScrollX`, `y = (vy - 8)·2 - g_mapScrollY` on the map port
  when no dialog is open. In the world canvas the square origin replaces this.

### 7.4 The world canvas

* `G_win`: 2560x1600 indices (4 MB), `G_dos`: 1280x800 DOS indices (1 MB), allocated at first
  need. One `MapSqDesc` per world square holds the rule inputs last drawn: key, terrain, fog mask,
  city marker inputs (owner colours, shown size or disorder, unit flag, walls), the top unit's
  civ, type, status, goto and stack flags.
* **Update** at a show that needs ring pixels, or at a sample (16.3): if the snapshot `gen`
  changed, recompute every descriptor from the snapshot (4000 squares, about 20 µs) and re-render
  the changed squares; then the labels whose boxes meet a re-rendered square, clipped to it.
* **Unseen squares** (viewer mask bit clear, `g_mapViewerCivMask` 1408:00CC) are black, as
  `DrawTilesToPort` mode 0 fills them (1208:1866).
* **Labels in the ring.** Every city the core would label (own, or `knownSize != 0`) gets its
  label, without the core's 32-label cap, in world column-major order (**Choice**; alternative:
  apply the cap, which drops labels for no visible reason outside the view). Labels wrap east-west.
  * A ring city's label is cut at the view's edge: in view the core's pixels rule, and the core
    never draws labels of cities outside its tile range (`GetVisibleTileRange` 1208:1D21). This
    is the same cut the core's own view shows at its edge.
  * An in-view city's label continues into the ring at the rule position. Two edge cases can
    differ from the core's in-view part: the `CollectVisibleCityLabels` row quirk (it clamps the
    top row without moving the y origin, 1208:1DD7) and the 32-label cap. Recorded.
* **Cost.** First render about 4000 squares (5 to 10 ms); later only changed squares.

**MZW (2026-10-16).** The World Map's zoom rectangle (5.6) derives from the layer's one geometry, the same in both
profiles, so the two profiles show the same rectangle (`ext_zoom.py`'s centring runs compare them).

## 8. The view snapshot and in-view rectangle

* `PmapView` is taken with the snapshot at the view triggers of 7.1. The layer's in-view rectangle
  is `[xv, xv + cw) x [yv, yv + ch)` from it.
* During a dissolve (`SetMapViewAndRedraw` 1110:03E9 then `DrawTilesToPort` mode 1) the client
  shows a mixture of old and new squares; the ring keeps the old surroundings until the redraw
  completes, then jumps. The scroll functions (`ScrollMapVertical` 1208:068C,
  `ScrollMapHorizontal` 1208:08D8) call only `BlitDCRect`, `FillRect`, `SetMapViewOrigin`,
  `RedrawMapRect` and `DrawSmTiles` (listing), with no poll in between, so their result is
  consistent at the next present.
* `g_mapScrollX` is 0 outside the dead `SetMapViewPixelOrigin` and `ProcessCity`'s save and
  restore, so `Xv` is always a multiple of 32; `Yv` can be odd after the bottom clamp of
  `SetMapViewOrigin` (1208:213B). Content stays aligned to world pixels either way.

## 9. The map display model (M2; D6)

### 9.1 Purpose

* For D6: the DOS view must follow each core map drawing event with DOS art (5.8 "Following the
  core": each square, unit, label, animation step, the dissolve order, blinks, explosions).
* For 7.5: the same model with the Windows rule set rebuilds the core's map client from events;
  equality with the virtual screen at every present is the literal 7.5 proof (10.3).

### 9.2 Shadows

| Shadow | Emulated surface | Identified by |
|---|---|---|
| `P` | the map back port `g_mapOffscreenPort` (12D8:4542) | its DC 12D8:455A and bitmap 12D8:455C |
| `S` | the scratch port `g_offscreenPort` (12D8:44A4), used by the move and combat frames | its DC and bitmap at +0x18, +0x1A (12D8:44BC, 12D8:44BE; **inferred** from the map port's offsets, confirmed at M2 from `GR_PortOpen`) |
| `Wn` | the map window's client | any DC of the map window (`g_mapWindowPort` +0 hwnd, +2 hdc; the WM_PAINT DC) |

The shadows belong to area B's shadow engine, the one engine of the DOS profile (C5). Each rule set
has its own three: Windows (physical indices, map pixels) and DOS (DOS indices, map pixels with
DOS art at 2x). The Windows set runs only under `--mirror 2` (harness); the DOS set runs always
from D6 (O6) (**Choice**: no cost in play for an oracle).

**Implemented in D6a (2026-10-16).** S's offsets confirmed (Open D1: GR_PortOpen stores the bitmap
at +0x1A, 10D0:0141, and the DC at +0x18, 10D0:0160). `P` and `S` are claimed as their bitmap
while its DC has it selected, `Wn` as the window `g_mapWindowPort` 12B0:0004 +0; the macros carry
both rule-set bits from `pmap_reset`, the hooks the DOS bit from `pmap_reset` and both under
`--mirror 2` ([D6a record](../ext-D6a-record.md); DESIGN.md 12.9 "As implemented (D6a; area D)").

### 9.3 Macros

A macro is a core drawing function whose effect the model draws itself from state at its entry.
It is a `PdosMacro` of B's shadow engine (B 7.3; RV2-7). Inside a `PDOS_MAC_DROP` bracket (entry
to exit) B's engine drops `OBS_DRAW` events whose destination is `P` or `S` and applies those
whose destination is `Wn` (the flushes). A `PDOS_MAC_CONTEXT` bracket drops nothing; D's
`DrawTile` handling asks `pdos_shadow_context` whether one is open. Macros nest; the outermost
DROP bracket on a surface owns it (B 7.3, Choice B20).

Every key below has the exit phase in A's probe table (A 4.3; RV2-1: DrawMapTile, DrawUnitAt and
DrawCityLabels gained it in Revision 3, DrawUnit, AnimateUnitMove and ResolveCombat had it), since
B's engine closes a bracket only at its key's exit.

| Macro (probe) | B's flags | Target filter (`target`: 1 with the target, 0 not ours) | Model action at entry (`enter`) |
|---|---|---|---|
| `DrawMapTile` 1110:04D0 (x, y, sx, sy) | `PDOS_MAC_DROP` | `g_currentGrPort` (1420:17CC) is the map port, `g_tileScaleNum/Den` (13A0:0000/0002) 1/1, `g_cityScreenMapMode` 0 | the square (x, y) at (sx, sy) in `P`, rule set's composition from live state |
| `DrawUnit` 1110:0DBA (civ, unit) | `PDOS_MAC_DROP` | target port as `MapLogicalPointToPort` decides: map port when `g_currentDialogPort` (1420:9948) is null | the unit with its stack shadow (Windows) or DOS 0E29 rules, at the core's position |
| `DrawUnitAt` 1110:0FF6 (civ, unit, vx, vy) outside `DrawUnit` | `PDOS_MAC_DROP` | as above | the unit's sprite and marks |
| `DrawCityLabels` 1208:1F64 (rect) | `PDOS_MAC_DROP` | current port is the map port | the label list (`g_cityLabelCount` 1408:0000, ids 1408:0004, y 1408:0044, x 1408:0084) per rule set |
| `AnimateUnitMove` 11C0:2C32 (civ, unit, dir) | `PDOS_MAC_CONTEXT` | context only | `DrawTile` (11A8:0CB1) of a unit sprite on `S` inside it: that unit's art at the `DrawTile` position |
| `ResolveCombat` 1050:0000 | `PDOS_MAC_CONTEXT` | context only | the lunge's `DrawTile` on `S`: the attacker's art; the explosion frames `g_mapSprites[32 + f]`: rule set's spark frame f |

`leave` is NULL for the DROP macros (they draw from state at entry) and for the contexts. Every
macro carries the rule-set bits of both sets (DOS always; Windows under `--mirror 2`), and `enter`
receives the rule set of the shadow it draws into.

Shape identity for a `DrawTile` inside a context: the handle is looked up in `g_mapSprites`
(1420:9350, 320 handles, read once per run); a temporary shape (a grey copy) takes the unit of
the context.

**Implemented in D6a (2026-10-16).** DrawMapTile has a Windows-set `leave` (`l_map_tile`): a city
square's dark bevel in the undefined colour of index 10 is taken from the core's map port at the
exit (the record's deviation; FIDELITY F165). DrawMapTile's target does not test
`g_cityScreenMapMode` (M's rules read it live, 1110:065B). D2's call sites: the lunge 1050:093A,
the explosion 1050:0AEA; AnimateUnitMove's frames 11C0:2F03. The Windows set draws a context
`DrawTile` from the shape's own TileBlock (no shape identity; the `g_mapSprites` lookup above is
the DOS set's, D6c) ([D6a record](../ext-D6a-record.md)).

### 9.4 Non-macro events

| Event | Condition | Action |
|---|---|---|
| `OBS_DRAW` BITBLT | source `P` or `S`, destination `Wn` (`CopyPortToWindow` 10D0:0854, WM_PAINT, nuclear frames) | copy the rectangle into `Wn` |
| `OBS_DRAW` BITBLT | `Wn` to `Wn` (`BlitDCRect` in the scroll functions) | shift `Wn` |
| `OBS_DRAW` BITBLT, `CopyPortBits` 10D0:03FA | between `P` and `S`, or `P` to `P` | copy or shift |
| `OBS_DRAW` FILLRECT | destination `P` or `Wn` (unseen squares, scroll strips: `BLACK_BRUSH`) | fill with the rule set's colour for that brush (black: Windows `BLACK_BRUSH` index, DOS 0) |
| any other `OBS_DRAW` to `P`, `S` or `Wn` outside a macro | | Windows set: replay it with `w16q_draw_on` semantics; DOS set: area B's logical replay; both count `map_unexplained` with the rectangle |
| `OBS_BITMAP` create or delete of the port bitmaps | `ResizeMapWindow` | reallocate the shadow at the new size, black |

**Registration in area B's engine (resolved, C5; B's final names, RV2-7).** The shadows, the port
identification and the replay of copies and fills are B's shadow-surface engine (B 7.3..7.5).
`pmap_model.c` keeps no shadows of its own. From `pmap_reset` it registers:

> **C passage condensed for the public copy.** The original record has here a block of 7 lines of C statements: calls to `pdos_shadow_macros`, `pdos_shadow_hooks`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* While a DROP macro is open on a shadow, the engine drops drawing events whose destination is
  that shadow (the macro has drawn them from state) and still applies copies to other shadows
  (the flushes to `Wn`).
* The engine gives `enter` and every hook the rule set (Windows or DOS) of the shadow concerned,
  so one table serves both.
* The ports the engine does not know as shadows (the city screen port, dialog ports) are not the
  map's: `target` returns 0 there ("not ours", no bracket). Revision 2's `-1` is B's 0.
* The table above (9.4's events) maps onto the engine as B 7.5's table "D's 9.4 table in this
  engine" gives: copies by B's rule 7.4 or D's `on_copy`, fills by D's `on_draw`, other drawing
  outside D's macros by B's replay (DOS set) or D's `on_draw` with `w16q_draw_on` (Windows set),
  bitmap delete by `on_free`, client resize by `on_resize`.
* Revision 2's proposed `PsMacro`, `PsShadow` and `ps_register_macros` are withdrawn.

**Implemented in D6a (2026-10-16).** Window draws and copies change only `ObsDraw.changed` (the
changed pixels' bounding box, clipped by the visible region and, inside BeginPaint, the update
region); map-to-map SRCCOPYs are copied by the owner itself through a buffer (the record's
deviation). The DOS set's events are absorbed and counted (`dos_deferred`) until D6b (B's replay)
and D6c (the DOS drawing) ([D6a record](../ext-D6a-record.md)).

**Implemented in D6c (2026-10-16).** The DOS rule set's events: a window draw into a DOS map shadow
is DOS colour 0 where a black brush's fill reached the surface (the model's `black_brush` rule,
`dos_fills`), else nothing and unexplained (`dos-draw`); a copy into a DOS map shadow is explained
for DrawTileImpl's last copy (11A8:135F) of a frame drawn at its entry, copied where it reached the
destination for a SRCCOPY between DOS map shadows (`dos_copies`), else unexplained (`dos-copy`);
raw bits outside the macros are unexplained (`dos-bits`); nothing is ever pasted (B7).
`dos_deferred` is 0; in the 29 `ext_mirror.py` runs `dos_unexplained 0` ([D6c
record](../ext-D6c-record.md); DESIGN.md 12.9 "As implemented (D6c; area D)").

## 10. Proofs: mirror equality and the rule checks (7.5, Z-2)

### 10.1 Checks

| Check | When | Compares | Phase |
|---|---|---|---|
| **key** | `TileCacheLookup` 1110:030C entry with `ra` inside `DrawMapTile` | its key argument with `mw_key(pmap_src_live(), x, y)` of the enclosing `DrawMapTile` | M1 |
| **render** | `TileCacheInsert` 1110:01A3 entry (key, terrain, hShape) | the shape block's pixels with `mw_render_key(key, terrain)` | M1 |
| **settled** | `DrawTilesToPort` exit (map port, any mode) and `RedrawMapRect` exit | the port bitmap (`w16q_bitmap` 12D8:455C) over the redrawn rectangle with the world-canvas rules applied to that view: squares of `GetVisibleTileRange`, units, the core's label policy (cap, collection order, the row quirk) | M1 (the planned shape's "mirror equality on in-view squares") |
| **present** | every core present | `Wn_win` with the virtual screen over the client's visible region | M2, built and gated with D6 (7.5 literal; C2) |
| **dos-settled** | `DrawTilesToPort` exit | the DOS world-canvas rules for the view with `P_dos` | D6 |

* The settled check renders with the same code as the ring (only the label policy differs), so
  it proves the ring's squares, units and labels against the core's own drawing at the default
  zoom. The present check proves the model's event coverage, which the DOS view relies on.
* A mismatch never stops the run. It writes a line and counts.

**Implemented in D6a (2026-10-16).** The present check runs at every core present
(`pmap_on_core_present`): `Wn_win` against the virtual screen over the client's visible region,
less an open menu's popups and the move/size outline; the whole client when the window, its
region, the exclusions or the shadow changed shape since the last check, else the present's
rectangle and the shadow's own damage. 13,380 present checks, 0 mismatched, in the 29
`ext_mirror.py` runs. `dos-settled` is not built ([D6a record](../ext-D6a-record.md)).

**Implemented in D6c (2026-10-16).** `dos-settled` runs at the same calls as **settled**
(DrawTilesToPort modes 0 and 1, and also RedrawMapRect), so the two checks cover the same states:
`P_dos` copied at the entry (black when it does not exist yet; another size than the bitmap skips
the check, `dos_skipped`), redrawn at the exit by the DOS rules in the core's order of the same
calls (`replay_ops`, shared with the settled replay) and compared with `P_dos`. 86 dos-settled
checks, 0 mismatched, 0 skipped in the 29 runs ([D6c record](../ext-D6c-record.md)).

### 10.2 Harness

* `--mirror 1` (key, render, settled) or `--mirror 2` (also present; the Windows model shadows
  run). Checked only; Release refuses it (exit 2).
* `mirror.log`: `mirror N virtual_us US kind key|render|settled|present|dos-settled rect l t r b
  ok|MISMATCH pixels P first x y core C ours O` and `end mirror checks N mismatches M unexplained U`.
* **`ext_mirror.py`**: every row of `scenarios.py`, gate3b's S2, S2b, S2c, S3 and the soaks S4,
  S5. Pass: `mismatches 0` (and, with `--mirror 2`, `unexplained 0`) in every run, and at least
  one check of each kind in each run that reaches the map. It also prints coverage: distinct keys
  checked, unit marks seen, city states seen.
* **Gates (C2).** M: `--mirror 1` (key, render, settled). D6: `--mirror 2` and the dos-settled
  check, with `--dos-data build\dosdata`. The Windows checks do not depend on the visible profile
  or the zoom.

**Implemented in D6a (2026-10-16).** `--mirror 2` needs `--dos-data` (the harness exits 2 without
it). Ok present lines are counted only; the model's unexplained events write `unexplained
draw|copy|bits|tile ...` lines; mode 2's end line adds, after M's fields, `present ..
present_mismatched .. present_pixels .. present_skipped .. present_noshadow ..` and the model's
counts (`squares` .. `bevels`). `ext_mirror.py` runs `--mirror 2 --dos-data build\dosdata
--graphics windows` and also requires `present_mismatched 0`, a present check in every run that
reaches the map and `profiles.log`'s `refused 0` ([D6a record](../ext-D6a-record.md)).

**Implemented in D6c (2026-10-16).** Mode 2's end line adds `dos_settled .. dos_mismatched ..
dos_skipped .. dos_unexplained ..` and the DOS rule set's counters (`dos_squares` .. `dos_clip_over`);
a mismatch writes `kind dos-settled`. `ext_mirror.py` also requires `dos_mismatched 0` and
`dos_unexplained 0` in every run and a dos-settled check in every run that reaches the map;
`MIRROR_TOTAL ... checks 21706 ... dos_settled 86 dos_mismatched 0 dos_skipped 0 dos_unexplained 0`
([D6c record](../ext-D6c-record.md)).

### 10.3 How each part is proven

| Property | Proof |
|---|---|
| level 0 is the core's map | no layer (5.1) |
| in view at +1 and -1 is the core's map | by construction from `M` (6.1); `test_map` checks the copy rules on synthetic regions |
| ring squares, units, cities, labels | settled check (10.1) over all scenarios |
| ring follows state | snapshot triggers (7.1); `ext_zoom.py` samples after moves and turns |
| DOS model follows the core | the Windows-rule model's present check (same handlers, other art) |
| deterministic zoomed frames | `ext_zoom.py` repeated runs (16.3) |

## 11. Anchoring and the active-unit rule

### 11.1 Entering a level

* **Non-wheel** (chord, menu, `--zoom`, harness `zoom`): the world pixel at the client centre,
  `(Xv + Cw/2, Yv + Ch/2)`, stays at the host centre of `Rc`:
  `Xo = Xv + Cw/2 - floor((Rc.r - Rc.l)/2 / s_l)`, then clamped.
* **Wheel** at host `(hx, hy)`: the world pixel under the mouse stays under it (5.8):
  `Xo = X_m - floor((hx - Rc.l) / s_l)` with `X_m` the world pixel at `(hx, hy)` before the step,
  then clamped. A step from +1 or -1 back to 0 removes the layer.
* **Reset** (Ctrl+Shift+0, menu, `zoom reset`): level 0.

### 11.2 Clamps

* **+1** (part of the view): `Xo` in `[Xv, Xv + Cw - Wl]`, `Yo` in `[Yv, Yv + Ch - Hl]`. The
  layer never shows a ring at +1; every pixel is the core's.
* **-1** (the view and its surroundings): the whole view stays visible,
  `Xo` in `[Xv + Cw - Wl, Xv]`; vertically the same, and among those positions the one with the
  fewest rows beyond the poles; when `Hl > 1600` the world is centred. Then `Xo` and `Yo` are
  rounded down to even.
* Clamps apply after every anchor, pan, view change and resize.

### 11.3 Following the core

* **Active unit (+1).** At `BlinkActiveUnitUntilInput` 11C0:0EC2 entry with `unit < 128`
  (unit 128 is "End of Turn"): the unit's square from `g_units[civ][unit]` (+1 x, +2 y). At
  `AnimateUnitMove` 11C0:2C32 entry for a unit of the human: the origin and the destination
  squares. The layer pans by the smallest amount that puts the square, with a one-square margin
  where the clamp allows, inside the layer. It never scrolls the core (5.8).
  **Changed by MZI (2026-10-16; [MZI record](../ext-MZI-record.md); FIDELITY F185).** A different
  active unit is centred where the layer would have to pan (`pmap_centre_unit`; the game's own rule
  for its view, EnsureSquareInMapView 11C0:231D, at the layer's size); the same unit's moves keep
  the least pan with the one-square margin.
* Only the human's units are followed (5.8 "the core's active unit"; **Choice**; alternative:
  follow every animated move, which jumps around during AI turns).
* **View changes.** When the view snapshot changes, the layer keeps its offset relative to the
  client (`Xo - Xv`), then clamps (**Choice**: a magnifier at a fixed place on the client;
  alternative: keep the world position, which drifts off the view after a recentre).
  **Changed by MZ (2026-10-16; the user's report of about 15:30 UTC and the choice "Keep the pole limit"; [MZ
  record](../ext-MZ-record.md); FIDELITY F185).** At -1 a new view centres the layer on it (`pmap_geo_centre`: the
  client's centre at the layer's host centre, then 11.2), whatever moved the view (the game's C, its automatic
  centring, its scrolling, a ring or small-map click); at +1 as written. The kept offset had ratcheted: 11.2 moved
  `Yo` near a pole and the next view change kept the clamped offset. 11.2's "fewest rows beyond the poles" stays (the
  user's choice): the centring is exact for a view's centre at rows Hl/2 .. 50 - Hl/2, and nearer a pole the view stays
  off-centre toward it. 11.1's anchors hold until the next view change.
  **Changed by MZI (2026-10-16; the user's report of about 19:24 UTC, the Cavalry of MZTEST.SAV
  not centred at +1, and of about 19:45 UTC; [MZI record](../ext-MZI-record.md); FIDELITY F185).**
  At +1 the game's setting of its view (SetMapViewAndRedraw 1110:03E9: CenterMapViewOn's centring on
  a unit or a city, a World Map click, the scroll keys) centres the layer on the middle square of
  the request (`(left + cols/2, top + rows/2)`, the unit's; `pmap_centre_square`, the copy nearest
  the view's centre), then 11.2, whether or not the view moved; other view changes (the scroll
  bars, ProcessCity's restore) keep the layer's place on the client. So the edge limit at +1 is the
  game's view (with Map Making it stops at the north and south edges: a unit within about 3 rows
  of them stays off-centre toward that edge). 11.1's anchors hold until the next request or the
  next new active unit; -1 as MZ wrote it.
* **Resize, layout change, full screen, DPI.** The world pixel at the layer's host centre is kept,
  then clamped.
* The unit's linear world position is the copy of `32 x` nearest to the view
  (`[Xv - 1280, Xv + 1280)`).

## 12. Input in the layer (Z-3)

### 12.1 Mapping at arrival

A's arrival stage (A 10.1, `pi_arrive_mouse`) asks `pmap_layer_point(hx, hy, &pt)` first (RV1-2:
not `present_map_point`, which scale.c already defines for the layout). When the host point lies
in the layer's clip:

> **C passage condensed for the public copy.** The original record has here a block of 5 lines of C declarations: types `PmapPt`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

The table classifies a **press**, and a move or release while **no** button is held. A press
fixes the class of its whole action until its release (A 10.1's press latch; RV2-3); the next
paragraph gives the parts of a held press.

| Host point | Move (no button held) | Left or right press | Release (no press of this button delivered or latched) |
|---|---|---|---|
| in view, client pixel visible | delivered at `(cx + X - Xv, cy + Y - Yv)`: proportional within the square, exact integers (4.2) | delivered there (frame 3; latched as a view press) | as the press |
| in view, client pixel covered by a window (possible at ±1) | clamped to the nearest point of the client's visible region | not delivered (F100's rule: its release neither) | |
| ring (level -1) | clamped to the nearest point of the view (5.8), then to the nearest visible client point, so the direction cursors 0x88..0x8F (`UpdateMapMoveCursor` 1208:121A) behave | left: frame 4 (12.2; latched as a ring press); right: not delivered | consumed |
| beyond the poles | as ring | not delivered | consumed |

**Parts of a held press (RV2-3, decision "Design review RV2").** The arrival stage keeps the
press's class until the release, wherever the pointer goes:
* **ring press (frame 4):** every move while held is frame 4 and `pmap_filter_ring` consumes it;
  the release is frame 4 with the press's square (`x = col`, `y = row`), over the view, the ring,
  beyond the poles or outside the layer, and becomes the small-map release (12.2);
* **view press (frame 3):** every move while held and the release are frame 3 at the clamped
  point (the nearest point of the view, then the nearest visible client point), also over the
  ring and beyond the poles; the core gets the release of the press it got (F100: "a release
  outside after a delivered press is delivered at the clamped point");
* **press off the layer:** its moves and release never become frame 3 or 4; A's mapping
  (`present_view_point`) applies, clamped as F100.

* Events produced by the layer carry `HostEvent.frame = 3` with virtual-screen coordinates; the
  filter passes them like frame 0. The button-state and capture rules of F100 apply unchanged.
* Over the base frame outside the layer, A's mapping (`present_view_point`) applies.
* Tests (16.1, with A's `test_input.c`): a ring press released over the view, on the ring, beyond
  the poles and outside the layer; a view press released on the ring and beyond the poles; moves
  across the view edge during each.

### 12.2 A press outside the view (5.8 "proven equivalent")

Rule: a left press on a ring square recentres the core's map on that square, by a small-map click
the user could have made. Otherwise it is not delivered. Recorded in FIDELITY.

* **Evidence.** A click in the small map reaches `WdwSmMapProc` (1210), which publishes it;
  `PollMouseClick` (1108:0000) then calls `CenterMapOnSmMapClick` (1210:056E) and
  `FlushInputEvents`. That function ignores a hidden small map and computes
  `deltaX = ((frame.left + frame.right)/2 - clickX) / g_smMapScale` (signed, truncating; frame
  `g_smMapViewFrame` 1420:B3CC, scale 1410:0000 is 1 or 2), the same for y, and calls
  `SetMapViewAndRedraw(human, viewLeft - deltaX, viewTop - deltaY)`.
* **Translation at the sync point** (A's filter stage, `present_input_filter`): the ring press
  arrives as `HostEvent.frame = 4` with `x = col`, `y = row`. At the sync the filter reads the
  small map's window (`g_worldMapWindowPort` 12B0:001C, +0 hwnd), its client origin and visible
  region, the frame, the scale, `g_mapViewLeft/Top` and `g_mapViewCols/Rows`. Target view
  `left' = col - cols/2`, `top' = row - rows/2` (as `CenterMapViewOn` 1110:03AE), so
  `deltaX = viewLeft - left'` taken modulo 80 into the representative that puts the click inside
  the small map's client, `clickX = centreX - deltaX · scale`, which the core's division maps
  back exactly; the same for y without wrap. The filter emits a move to the small-map point and
  the press there; the later frame-4 release becomes the release at the same point; moves while
  held are consumed. The press latch (12.1, A 10.1; RV2-3) guarantees that every move while held
  and the release reach `pmap_filter_ring` as frame 4, so the core always gets the release of the
  press it was given (I7's consistency).
* **Interface (RV2-6).** `int pmap_filter_ring(const HostEvent *ev, HostEvent *out, int max)` in
  `pmap.h`, called by A's `present_input_filter` for frame 4 inside the guard: a press gives 2
  events (the move and the press) or 0 (not delivered); a move gives 0; a release gives 1 (the
  release at the press's small-map point) or 0 when its press was not delivered. It keeps one
  pending press per button and reads only through `w16q_*`.
* **Not delivered** when the small map window is hidden, iconic or disabled (`w16q_wnd`'s visible
  and enabled bits), or the point is not in its visible client region for any representative:
  the press and its release are consumed. A right press in the ring is never delivered (no
  equivalent).
* The effect equals the user's own small-map click, including `FlushInputEvents` and the
  game state in which `PollMouseClick` runs (I1: a kind of input a user can produce).
* **Kept (resolved, C6).** It is 5.8's own example of a proven equivalent original input. The rule
  is recorded in FIDELITY and listed for the user's check (`manual-checklist-ext.md`).

### 12.3 The wheel (I8)

* `pi_arrive_wheel(hx, hy, delta)` (A 10.1): over the layer or the map client's visible host
  region (`pmap_hit`), deltas accumulate; each full 120 is one step, forward zooms in,
  clamped to -1..+1; the command carries the anchor (`PiOut.cmd_hx`, `cmd_hy`, section 17 A-4).
  Elsewhere the wheel is ignored and the accumulator clears.
* Win32: `WM_MOUSEWHEEL` gives screen coordinates; the back end converts with `ScreenToClient`
  before the call. The wheel never reaches the emulated queue.

### 12.4 The cursor

The cursor is not zoomed: it keeps DESIGN.md 12.2's scaled size (**Choice**; alternative: scale
it with the layer, which would change size when crossing the map's edge).

## 13. Commands, options and settings

* **Chords** (5.11, I7), through A's arrival stage with the modifier hold rule (A 10.2):
  * Ctrl+Shift+`VK_OEM_PLUS` or `VK_ADD`: zoom in;
  * Ctrl+Shift+`VK_OEM_MINUS` or `VK_SUBTRACT`: zoom out;
  * Ctrl+Shift+`'0'` or `VK_NUMPAD0`: reset. With Num Lock on, Shift turns the keypad 0 into
    `VK_INSERT` on usual layouts, so the keypad reset may not arrive; the main-row 0 always does
    (recorded). (As built: since UX4 the keypad's 0 as `VK_INSERT` with scan 0x52 also resets, with Num Lock on
    and off; since UX4b Ctrl+Shift+`VK_HOME`, the gray Home and the keypad's 7 with Num Lock off, is one more reset
    key, and the menu item reads "&Normal map zoom\tCtrl+Shift+0, Ctrl+Shift+Home" (FIDELITY F114; its effect on the
    Windows controls that read Home is F188).)
  * Only presses without the repeat bit act. The chord's key-down, repeats, release and the held
    modifiers' releases do not reach the game.
  * **Audit** (redone at M as A 10.2 does for Backspace): ACCELERATOR 128 has no Ctrl+Shift entry
    (DESIGN.md 12.2: plain D H J K N P, Ctrl+R, Ctrl+0..9, Ctrl+D P F L Q S T; Ctrl+0 matches only
    without Shift); no core handler reads `GetKeyState`; `GetKeyboardState` only for Num Lock. The
    plain keys `=`, `-`, `0` and the keypad keys still reach the game unchanged.
* **System menu** (`add_menu`, host_win32.c 1758), after A's profile items and before About:
  separator; "Zoom &out (half)\tCtrl+Shift+Minus" `SC_CIV_ZOOM_OUT 0x10C0`; "&Normal map
  zoom\tCtrl+Shift+0" `SC_CIV_ZOOM_DEF 0x10D0`; "Zoom &in (double)\tCtrl+Shift+Plus"
  `SC_CIV_ZOOM_IN 0x10E0`, as radio items checked by `hw_update_menu` (1736). "Zoom in" is grayed
  while +1 is refused (4.3). Menu commands use the centre anchor.
* **`--zoom default|-1|0|+1`** (resolved, C1; `default` and `0` are the same level; anything else
  exits with code 2). The level applies when the map window exists. The prompt's
  `--zoom default|<m>` is replaced by the user's levels.
* **Settings key `zoom`** (`-1|0|1`, anything else reads as absent): written when the player
  changes the zoom by chord, wheel or menu; the command line wins for the run and is not written
  (DESIGN.md 12.2's rule; 2.1 "Settings file" lists "the map zoom"). **Choice: remember it.**
  Alternative: always start at 0.
* **Harness** (A 12.1): `at <ms> zoom -1|0|+1|reset` (calls `pmap_request_zoom`), and `--zoom`. With `--host-size` the layer
  is active; without it the command still sets the level (the layer has no view to draw).
  A refused request writes `zoom refused <reason>` in `presented.log`.
* **`presented.log`** (A 7.3): when the layer is active a show line adds
  `zoom L view CWxCH view_sha256 SHA`, the hash of the whole host view buffer (`present_set_view`
  bits). The logical-frame hash and the S1 relation check stay as they are. `--dump-presented`
  writes `view-NNNNN.bmp` (24-bit) for those shows. This is how hashes "name the host size and the
  zoom" (5.8).

## 14. The DOS map rules (D6)

The DOS view of the map window is class A (DOS-PROFILE.md row 96): DOS art at the Windows
positions, the Windows layout kept (resizable windows, scroll bars, logical map origin x 200 for
DOS 80). The core's decisions drive what is drawn and when (DOS-PROFILE.md 0.6 rule 1); the DOS
rules decide how it looks.

### 14.0 Where the DOS art and tables come from (RV1-1)

The words B886, D294, D2D4, B27A, B29A, 6DFE, 7EEC, B880, D4CE and 6E96 lie at or above
DGROUP:6B30h, the end of DGROUP's initialised data: they are run-time shape handles that O5:1455
fills at start-up, not image tables (FORMATS.md 6 "Where image data can be"; SPRITES.md 1 "Data or
code"). The first draft's claim that they come "through the offset registry" was false.

* **Shapes** come from area E's shape-cut module `pdos_shapes`, which reproduces O5:1455 from the
  decoded pictures at activation: the rectangles as constants citing their O5 addresses (the
  user's X0 decision D6), the recolouring of the eight unit copies (SPRITES.md 6.4), the TER257 row
  rule (SPRITES.md 4, DGROUP:1A3E taken as 0) and copies such as D4DC from 6E92. The map asks for
  shapes by family and index with E's names (E.9.2: `pdos_shape(PDOS_SH_<family>, i)`, the index
  being the DOS index); the families it needs (request E-1, section 17):

| Family (E.9.2) | DOS receiver | Index | Cut from (SPRITES.md) | O5 range |
|---|---|---|---|---|
| terrain `PDOS_SH_TERRAIN` | B886, `T[t][m]` | t 0..9, m 0..15 (row rule: t 6..9 give the m = 0 shape for every m) | TER257 (16m, 16t, 16, 16), 4 | O5:14FF..1577 (variants 151C..1567) |
| coast quarter `PDOS_SH_COAST` | D294 | pattern i 0..7, quarter k 0..3 | TER257, 4 | O5:1579..15F7 |
| river mouth `PDOS_SH_MOUTH` | D2D4 | d 0..3 (N, E, S, W) | TER257 (128 + 16d, 176), 4 | O5:15F9..1635 |
| road, railroad `PDOS_SH_ROAD`, `PDOS_SH_RAIL` | B27A, B29A | direction 0..7 | SP257 (16i, 48), (128 + 16i, 96), 6.1 | O5:16F5..1745 |
| river `PDOS_SH_RIVER` | 6DFE (6E1E = 6DFE[16 + i]) | 1..15 and 17..31 | SP257 (16i, 64), (16i, 80), 6.1 | O5:1763..17AF |
| unexplored edge `PDOS_SH_EDGE` | 7EEC | 0..3 (N, E, S, W) | SP257 (80 + 16i, 128), 6.1 | O5:1826..185B |
| grassland marker `PDOS_SH_GRASS` | B880 | one | SP257 (153, 41, 7, 7), 6.1 | O5:197A..1993 |
| icon `PDOS_SH_ICON` | D4CE | 4..6, 16..39 | SP257, 6.3 | O5:185D..188F, 1910..1978 |
| unit `PDOS_SH_ICON` | D4CE[64 + 32c + j] | civ c 0..7, type j 0..27, recoloured per c | SP257 unit rows, 6.4 | O5:19B5..1AE8 |
| citizen `PDOS_SH_CITIZEN` | 6E96 | 0..8 (the map uses 4) | SP257 (8i, 128, 8, 16), 6.5 | O5:18D9..190E |

* Shapes are run sprites whose colour 0 is transparent (SPRITES.md 1, DRIVER.md G#32).
* **Page-2 rectangles (RV2-8; E.9.2's form adopted).** They are not cut by O5:1455 but copied from
  the page-2 art it composes (O5:1484..14A4 copies `SP299.PIC` (160, 50, 160 x 150) opaquely to
  the same coordinates of page 2). The map reads them from `pdos_pic(PDOS_F_SP299_PIC)` at the same
  coordinates, inside `PDOS_PAGE2_ART_X/Y/W/H`, and copies them opaquely (G#20 "Opaque",
  DRIVER.md) with its own constants citing the DOS addresses:

  | Rectangle | Page-2 position | Index | DOS address |
  |---|---|---|---|
  | whole-square coast | (224 + 16j, 100, 16, 16) | j 0..5 | R:1AEA:03BA |
  | land base | (256, 120, 16, 16) | one | R:1AEA:07B2..07CD |

  Both lie inside the page-2 art and above the government portraits that later overwrite
  (160, 140, 160 x 60) of page 2 (O5:1AF6, run-time state, area B), so the picture's pixels are
  the ones DOS shows there.
* **Tables** below DGROUP:6B30h come through `OFFSETS.md` (E's registry): the civilization colours
  DGROUP:1946 (main) and 1956 (secondary) (FORMATS.md 6.1).
* **Constants inside the drawing code** (offsets such as (+4, +7), colours 0, 7, 9, 11, 15, the
  label offsets) are immediates of R:1AEA, R:1F4D and R:1DC4 and become C constants citing their
  addresses (the user's X0 decision D6, ext-d1-decisions.md E.18-5).
* **Drawing** uses area B's model of the DOS driver (G#32 DrawSprite, G#20 CopyRect, G#3
  RecolourRect, fills, outlines, DOS text), so the map and the other class-A areas draw alike.
* Terrain numbers: the core's and the DOS program's agree (0 Desert .. 9 Jungle, 10 Ocean, 11
  River; SPRITES.md 4 and graphics.md 4.10.1).

### 14.1 Positions

* A DOS square at map position `(sx, sy)` (the core's `DrawMapTile` screen position) is drawn at
  DOS art scale 2: DOS art pixel `(i, j)` covers map pixels `(sx + 2i, sy + 2j)` and the next.
* Every DOS offset below (in DOS pixels) doubles. Squares start at world multiples of 32, and the
  core's units, labels and animation steps move by even map pixels (`AnimateUnitMove` 4 per
  frame, the combat lunge 2), so DOS art pixels always start at even world pixels (4.2).

### 14.2 One square (SCENES-PLAY.md 2.1, VGA rows)

At each `DrawMapTile` macro (9.3) and in the DOS ring, in the listing's layer order:

| # | Layer | Inputs (the core's state) | DOS art |
|---|---|---|---|
| 1 | Ocean quarters | land mask of the 8 neighbours, x wrapped; `m9 = (mask << 2) + ((mask >> 6) & 3)`; quarter k pattern `(m9 >> 2k) & 7` | D294 quarters at (0,0), (8,0), (8,8), (0,8) |
| 1a | Whole-square coasts | masks 1Ch, C1h, 07h, 70h, 8Fh, F8h | page 2 (224 + 16j, 100) (SPRITES.md 7) |
| 1b | River mouths | N, E, S, W neighbour River | D2D4[d/2] |
| 2 | Land base | every non-ocean square | page 2 (256, 120) |
| 3 | Irrigation | known `I & 2`, not ocean, not a city, DOS "DCFC clear" | D4CE[4] |
| 4 | River | N/E/S/W River-or-Ocean mask (no x wrap); +16 unless page-2 `(x, y+150) & 8` | 6DFE[index] |
| 4' | Other land | N/E/S/W same-terrain mask | T[T][mask] (B886) from `pdos_shapes`, with E's TER257 row rule (RV1-16): Tundra, Arctic, Swamp and Jungle (T 6..9) show their m = 0 shape for every mask |
| 5 | Grassland marker | T = 2 and `((7x + 11y) & 2) == 0` | B880 at (4, 4) |
| 6 | Pollution | `I & 40h` | D4CE[6] |
| 7 | Road, railroad | `I & 8`: per direction railroad B29A[d-1] if both squares have city or railroad bits, else road B27A[d-1]; none: 2x2 dot at (7, 7), colour 0 (railroad) or 6 | |
| 8 | Mine | `I & 4`, DCFC clear | D4CE[5] |
| 9 | Special | the core's `HasSpecialResource` decision | D4CE[16 + T] |
| 10 | Hut | the core's `HasHut` decision | D4CE[31] |
| 11 | Fortress | `I & 20h` | D4CE[30] |
| 12 | Unexplored edges | the core's fog decision (Windows step 5 rule, 4.10.4) for N, E, S, W | 7EEC[d/2] |
| 13 | City | 14.4 | |

* **Core decisions over DOS formulas.** Specials and huts use the core's functions (their
  formula matches SCENES-PLAY.md 2.1's with `g_randomSeed` for DGROUP:6E80, which the draft
  itself calls the Windows counterpart). Fog edges use the core's visibility test, including its
  pole quirk. "Not seen" uses `g_mapViewerCivMask`. "D806" (reveal all) is the core's
  `g_revealAll` (12D8:4302) (**inferred** counterpart; L2). "DCFC clear" is taken as
  `g_mapDrawMode == 0` (**inferred**: the same three layers depend on it in `ComputeTileAppearanceKey`
  and `DrawMapTile`; Open D3).
* **River set.** DOS adds 16 when the page-2 bit is clear; Windows adds 0x10 when it is set
  (graphics.md 4.10.1). The DOS view follows the DOS rule (its own art sets for the same state
  bit). Recorded as a DOS/Windows difference.
* **TER257 row rule (RV1-16).** E's module owns it (SPRITES.md 4: with DGROUP:1A3E = 0, rows 0..5
  are cut in all 16 mask variants, rows 6..9 only at m = 0 and every mask receives that handle).
  DGROUP:1A3E is set only on low-memory VGA machines (R:01A8:00FC); the port takes it as 0,
  recorded by E. Windows cuts all 16 variants for every row (SPRITES.md 4, graphics.md 4.9), so
  Tundra, Arctic, Swamp and Jungle ignore their neighbours in the DOS view only; recorded as a
  DOS/Windows difference.
* EGA rows (1', 4'', EGA pollution recolouring) are out of scope (PALETTE.md 1: EGA path out of
  scope).

**Implemented in D6c (2026-10-16).** Open D3 settled from the listing: DCFC is written only at
R:0403:37AB (1) and R:0403:37C9 (0), around one full map redraw reached from the 't' key
(R:0403:3B47..3B4C); the core's 11F0:3E87 't' (Hide Units) sets `g_mapDrawMode = 1`. So "DCFC
clear" is `g_mapDrawMode == 0` (layers 3, 8, 13), no longer inferred. D806 has no writer in the
listing (every instruction naming it compares with 0; it lies above DGROUP:6B30h): taken as 0, not
`g_revealAll` (the record's deviation; FIDELITY F179). Layer 4 reads the page-2 bit as the core's
`g_lpScreenBuffer` (x, y + 150) ([D6c record](../ext-D6c-record.md); DESIGN.md 12.9 "As implemented
(D6c; area D)").

### 14.3 Units (SCENES-PLAY.md 2.2)

* **Which unit.** The core's choice (`DrawUnitStack`, best defender, the ship at sea, foreign units
  only when seen, none on own city squares), not R:1AEA:1458's (0.6 rule 1). Recorded.
* **Drawing** (R:1AEA:0E29, 0FB3), at the core's position: stack shadow D4CE[64 + 32 civ + type]
  at (+1, +1) when `nextInStack != 0xFF`; the shape at (0, 0); then by the unit's status:
  fortified (flags & 8) D4CE[29]; else fortifying (flags & 4) shadowed "F" at (4, 7), colour 9
  for civ 1 else 15; own unit with goto shadowed "G"; work letters for flags & C2h on non-air
  units at (4, 7) with the outline (-1, -1, 15, 15) colour 7 (I, ?, M, F, P, R as the table);
  sentry: G#3 recolours 5 to 7, then 8 to 7, over the 16x16 rectangle at the unit's position
  (DOS listing R:1AEA:1191..11CC: w = h = 10h, x, y the arguments), so pixels 5 and 8 of the
  terrain under the unit are dimmed too. The letter font is area B's (L23; decision X5; B 10.1: font 1, inferred).
* The DOS rules for marks apply in the DOS view (they read the same status bits; the Windows
  colour 0x0B for civ 1 becomes DOS colour 9).

**Implemented in D6c (2026-10-16).** The listing sets no font in R:1AEA:0008, 03BA or 0FB3 (the
font is whatever play last set), so Open D6 / OB4 / L23 is not settled; the letters and size
digits use font 1 (inferred, FIDELITY F180). DrawUnit's carried rule is R:1AEA:0F3C..0F55, the
same decision as the core's 1110:0ECE ([D6c record](../ext-D6c-record.md)).

### 14.4 Cities (SCENES-PLAY.md 2.3)

Outline (1, 1, 13, 13) colour 15; outline (2, 1, 12, 12) in the secondary colour (1956[owner]);
fill (2, 2, 12, 12) in the main colour (1946[owner]); D4CE[28] at (1, 1); then G#3 recolours 5 to
the secondary colour over (2, 2, 12, 12) (DOS listing R:1AEA:0CB4..0CEA: w = h = 0Ch at the fill's
origin, both computed as the square position + 2 at R:1AEA:0C5F..0C8A); the size (own: real, else known) at (6, 5), or (3, 5) for two digits, colour 0,
or the disorder shape 6E96[4] at (5, 2); outline (0, 0, 15, 15) colour 0 when a unit or a stored
unit is present (the core's `FindUnitAtTile` answer, computed read-only); walls D4CE[29] at (1, 1).
A foreign city with known size 0 is skipped (unless reveal all).

### 14.5 Labels (SCENES-PLAY.md 2.4 step 4; DOS-PROFILE.md row 140)

* **When.** At each core `DrawCityLabels` (the core's decision), for the core's label list. The
  DOS program draws labels only at its full redraw; recorded.
* **Where** (in map pixels, square at `(sx, sy)`): x = `max(sx - 16, 0)` (DOS clamps to the map's
  left edge 80), y = `sy + 32`. The name is truncated to `Cw + 14 - sx` map pixels with the DOS
  truncation rule (R:1F4D:04F7; DOS `327 - px` with the DOS map's right edge replaced by the
  client's). Drawn only when `sy + 32 < Ch` (DOS `py < B8h`: the label's top inside the map).
* Shadowed text, colour 11, the DOS label font (area B; OPEN L23, which decision X5 corrects from L17; B 10.1: font 1, inferred).
* **In the DOS ring** labels sit at `(sx - 16, sy + 32)` without clamp or truncation (those belong
  to the DOS screen's edges, which the ring does not have) (**Choice**; alternative: clamp to the
  layer's edges, which moves labels as the layer pans).

**Implemented in D6c (2026-10-16).** Labels are drawn at each core DrawCityLabels and at
DrawMapTile's flushes (with `g_autoFlushToWindow`), and redrawn whole by their DOS box: every label
whose DOS box (`pmap_dos_label_box`: the text width and the font's line height plus the shadow row,
at 2x) meets the rectangle (the Windows box is the Windows label's). The truncation is
`floor((Cw + 14 - sx) / 2)` DOS pixels. The listing sets no font here either; font 1 stays
inferred (Open D6) ([D6c record](../ext-D6c-record.md)). The DOS ring's labels are D6d's.

### 14.6 Animations and order (P3, P6)

| Effect | Rule | Source |
|---|---|---|
| Dissolve | the core's `DrawMapTile` order in `DrawTilesToPort` mode 1; DOS `p = (5p + 1) & FFh` order not used | DOS-PROFILE.md row 135; P3 resolved for the map |
| Blink | the core's start and end (BlinkActiveUnitUntilInput's entry and the end of its loop); since DBL (2026-10-17, `ext-DBL-record.md`) the DOS 10/10 frames from the core's entry to its end on a presentation clock (`pdos_ublink`), the main map's square from pictures drawn as the core's hide (`RestoreBlockXY`) and show (`DrawUnit`) and the small-map square and "End of Turn" alike; before DBL the core's phase (TickCount % 60, 30/30 ticks) and the DOS 10/10 frames not used; the Windows graphics keep the core's phase | row 132; P6 resolved; FIDELITY F133, F220 |
| Move | the core's 9 frames of 4 map pixels (2 DOS pixels), DOS unit art; the DOS 17 one-pixel frames are not used | row 133; P6 resolved |
| Combat | the core's lunge frames and 8 explosion frames, DOS art D4CE[32 + f] | row 134; the DOS drawing routine is not traced (SPRITES.md Open 3) |
| Scroll | the core's shifts and strip redraws (`ScrollMap*`) | 9.4 |

The DOS timing of these effects is not used anywhere: no presentation-local generator or clock is
needed for the map (T7: the core's pace). **Since DBL** (2026-10-17, the user's revision items 1 and 2) the blink is
the exception: its phases follow a presentation clock of R:0866:0AD6's 10 VGA frames (`pdos_ublink`, the DOS clock
model M1), started and stopped by the core (no generator; the core's decisions and pace otherwise unchanged; DESIGN.md
12.9 "As implemented (DBL; areas B and D)").

**Implemented in D6c (2026-10-16).** The move and combat frames are `pmap_dos_sprite(index)`,
D4CE[index] for the handle's index in `g_mapSprites`, read at each DrawTile frame (a loaded game
cuts new handles, so 9.3's once-per-run read would go stale). A temporary DrawTile shape (a handle
not in the table) inside AnimateUnitMove or ResolveCombat is the context's unit, D4CE[64 + 32 civ +
type] (for ResolveCombat the attacker); no such frame occurred in the 29 mirror runs
(`dos_tile_ctx 0`), so that rule is exercised by the unit test only ([D6c
record](../ext-D6c-record.md)).

### 14.7 The map palette

* Play palette: `SP256.PAL` entries 0..127 and `back<g><a|m>.pal` entries 128..255
  (SCENES-PLAY.md 1.2, PALETTE.md 2.5 R:0238:1BEB). Map sprites use indices within 0..111 and 255
  (PALETTE.md 5).
* Cycling: slots 96..103, 104..111, 112..127, colours captured from the palette at set-up
  (R:1DC4:05DD), positive direction (each entry takes its lower neighbour's colour, PALETTE.md 2.4;
  proven by the listing, R:0000:0471..04A1, the slot rotation: the D6c review's G3, D6d). Each core `CyclePaletteColors` (1208:22B7) event advances all three by one
  step (DOS-PROFILE.md row 107, T7): every 200 ms, not every 15 DOS frames.
* The palette state is the A canvas's (area B); the layer converts with it and reconverts on
  each step (5.3).
* Open for D6: L11 (entry 45, the differing `BACK*.PAL` entries) and L12 (cycling over faded
  entries).

**Implemented in D6c (2026-10-16).** The map element's `rgb8` is NULL: it follows the A machine's
play palette, which D4a's wiring steps at each `CyclePaletteColors` and B reconverts on a new
palette generation; the DOS ring's part stays D6d's ([D6c record](../ext-D6c-record.md)
"Decisions within the brief").

**Implemented in D6d (2026-10-16).** A new play-palette generation while the DOS layer is drawn
makes the layer pending and the overlay converts the image again (`dos_reconverts`): under nearest
the indices are kept and converted (5.3), under `fit` sharp the XRGB image is rendered again (M's
deviation, now also for the play palette: 54.2 / 33.5 ms per step at 2560x1600 in Checked, -1 / +1).
The step comes once per core `CyclePaletteColors` entry, about every 220 ms of the core's timer,
against the DOS program's 15 frames (about 214 ms at 70 Hz) (FIDELITY F133). **L12 read** from the
listing: in the play return path R:0238:1BEB the DOS program stops the map slots (R:0238:1B48 calls
R:1DC4:065F) before the fade-out (R:0000:04D4, at R:0238:1B66), stops them again (R:0238:1BFC)
before the fade-in (R:0000:04AA, at R:0238:1C86, which busy-waits until the fade completes) and
restarts them only after it (R:0238:1C8E, R:1DC4:0626), without capturing the colours again: the
slots never cycle over faded entries in that path, and the A machine has no fade in play in D6d,
so nothing is modelled. The restart without a capture keeps the position (the D6c review's R3, for
D6e; B 5.5). L11 stays open for D6e (the play palette's life cycle) ([D6d record](../ext-D6d-record.md)
"OPEN L12", "D6cF").

### 14.8 Small map (P9), world mode

* **P9 resolved: correct it.** The A small map draws the core's whole world and the core's view
  frame (DOS-PROFILE.md row 139), so its rectangle covers the core's `g_mapViewRows` rows. The
  DOS 9-row rectangle (SCENES-PLAY.md 4) is not reproduced: it is a frame of a 12-row view that the
  Windows layout does not have, and the core's frame is the core's decision. Recorded.
* **Owner (resolved, C7).** Area B draws the DOS small map, the status window and the unit panel
  (DOS-PROFILE.md rows 136, 138, 139; class A art substitution in the Windows layout) and applies
  this P9 rule. They are not zoomed (section 2).
* **World mode** (DGROUP B278, SCENES-PLAY.md 2.2): no writer found (L2) and no Windows map-window
  counterpart; not reproduced.

### 14.9 The DOS ring

At level -1 the DOS profile's ring uses `G_dos` with 14.2..14.5 from the snapshot, the core's
decisions computed by the Windows readers (top unit, specials, huts, fog), and DOS art. Its
settled check is "dos-settled" (10.1).

**Implemented in D6d (2026-10-16).** `G_dos` holds 1280 x 800 DOS indices (1,024,000 bytes,
allocated at the first -1 update with the DOS profile registered), one per DOS art pixel, which
covers world pixels (2i..2i+1, 2j..2j+1) (14.1), drawn through a k = 1 pen; the layer's `m = 2 s_l`
gives each DOS pixel k x k host pixels at -1. As `G_win`: one `PmapDosKey` per square, recomputed
when the snapshot's gen changes; a square whose key changed is cleared to DOS 0 and drawn again by
RedrawMapSquare's two calls (R:1AEA:03BA's layers, then the top unit through R:1AEA:0E29 with the
stack shadow; black when unseen), then every label whose pixels meet its 16 x 16 cell, clipped to
it. The labels: `G_win`'s list (the core's label policy, column-major, east-west wrap) at 14.5's ring
position (R:1AEA:0174..0180 px - 8, R:1AEA:0168..016C py + 10h, in DOS pixels) without R:1DC4:007C's
clamp and R:1F4D:04F7's truncation, colour 0Bh with its shadow; a label past the east edge wraps to
the west. The canvas of the layer's profile is brought up to date at each tick and core present, the
other one when `pmap_layer_sample` samples it (after a switch at -1 the newly shown ring is at most
one tick old). Tested by `test_map` (`G_dos`'s squares equal the k = 2 model's pixels halved; a ring
label and its wrap) and by `ext_zoom.py`'s DOS goldens and per-profile layer samples ([D6d
record](../ext-D6d-record.md); DESIGN.md 12.9 "As implemented (D6d; area D)").

## 15. Phase G: the screen follows the host

* Under `integer` the factor stays k (the title-screen factor) while the virtual screen grows with
  the host client (F110); the map client grows, the squares keep `32 k 2^l` host pixels.
* A resize arrives at the core as WM_SIZE (`ResizeMapWindow` recreates the port and redraws,
  mode 0). Until the view snapshot has the new client size the layer is inactive (5.1); then it
  re-anchors (11.3). Zoom never feeds `present_game_screen_follow` (K1).
* Window placement and the map window's own size are the core's; the zoom never moves or sizes an
  emulated window.

## 16. Tests

### 16.1 Unit tests (`tests/test_map.c`, Checked and Release)

* Geometry: `X(hx)` for k = 1..4 and fit factors (hand-computed tables); every host pixel maps
  into `[Xo, Xo + Wl)`; under `integer` +1 blocks are 2k wide and -1 pairs are k wide with an even
  origin; the half level picks even world pixels at k = 1; DOS art pixels are k x k at -1.
* Anchors: centre anchor; the wheel anchor keeps the world pixel under the mouse within one host
  pixel; clamps at +1 (no ring), at -1 (whole view visible), poles, `Hl > 1600`, wrap with
  `Wl > 2560`.
* Limits: +1 refused below 192x192; a resize below it drops to 0.
* Input: in-view mapping exactness at square edges; covered points clamp to a hand-made visible
  region; ring moves clamp to the view; presses not delivered; frame-4 translation: `clickX`
  divides back to `deltaX` for scales 1 and 2, both wrap representatives, the hidden or covered
  small map, odd frame widths.
* `pmap_filter_ring` (RV2-3, RV2-6): a ring press gives the move and the press, its frame-4 moves
  give nothing, its frame-4 release (from anywhere: view, ring, beyond the poles, outside the
  layer) gives the release at the press's small-map point; a release whose press was not
  delivered gives nothing. A's `test_input.c` covers the arrival latch that stamps those parts.
* Wheel accumulation (40, 80, 120, -240, mixed) and the forward-in rule.
* Rules on synthetic snapshots: key bits per graphics.md 4.10.1 table (ocean patterns, coast mask,
  river index with the 0x10 bit, roads and links, mine, pollution, special, hut, fortress); the
  fog index at the poles reads the bytes before and after the array; the top-unit rating ties.
* DOS composition order on a synthetic square set (D6).

### 16.2 7.5 (`ext_mirror.py`)

Section 10.2. The M gate needs `--mirror 1` clean; the D6 gate needs `--mirror 2` clean
(Windows model) and dos-settled clean, the D6 runs with `--dos-data build\dosdata` (RV1-5).

**Met at the D6 phase gate** (D6g, 2026-10-17; the eight-step cycle's `test.cmd checked`,
[ext-D6-acceptance.md](../ext-D6-acceptance.md) "Gate"): `MIRROR_OK runs 29`, MIRROR_TOTAL checks 21712, present
13386, `present_mismatched 0`, `unexplained 0`, dos_settled 86, `dos_mismatched 0`, `dos_skipped 0`,
`dos_unexplained 0`.

### 16.3 Zoomed frames (`ext_zoom.py`)

* Host sizes named with the zoom: 640x480 (k = 1), 1280x960 (k = 2), 1920x1440 (k = 3, the
  user's case), 2560x1600 under `fit` sharp, 1366x768 under `fit` nearest; levels -1 and +1;
  scenarios new-game, load-save, input (scenarios.py) and soak S4.
* `presented.log` `view_sha256` at listed virtual times go to
  `tests/harness/ext-zoom-golden.txt` (scenario, host size, policy, level, time, hash). The
  goldens are presentation hashes, never core fixtures (base 2.3).
* Determinism (Z-2, 7.4): two runs equal; a run that switches profiles every 997 ms (from D6) has
  the same Windows-layer and DOS-layer samples at equal times as runs that show one profile
  (`profiles.log` gains `map` hashes per profile, section 17 A-6).
* **DOS runs (RV1-5).** Every run with the DOS profile (shown or switched to) passes
  `--dos-data build\dosdata`. The runner asserts from `profiles.log` and `presented.log` that the
  switches happened and none was refused (a refused switch fails the check, not silently the
  comparison).

**Implemented in D6d (2026-10-16).** Per combination: `win a` (no DOS profile: the Windows goldens'
run, unchanged) and `win b` (`--dos-data`, the DOS profile registered and hidden) with equal zoomed
shows; `dos a` (`--dos-data --graphics dos`) at every size of the three scenarios (the DOS goldens:
a third header line and 240 `dos` lines after the 388 unchanged Windows lines) and `dos b` at
1920x1440 with shows equal to dos a's; `sw a` (`--dos-data --switch-every 997`) at 1920x1440, the
scenarios and the soak, with at least one switch; no refused switch, the dos runs starting in the
DOS profile; `profiles.log`'s `map windows` and `map dos` equal in win b, dos a, dos b and sw (and
`map windows` in win a) at every common sample time. For cost the soak runs as win a/b and sw only,
its DOS layer checked through sw's `map dos` samples. `ZOOM_OK combinations 32 runs 108 samples 628
map comparisons 32` ([D6d record](../ext-D6d-record.md) "Decisions within the brief").

**The full matrix at the D6 phase gate** (D6g, 2026-10-17, decision 6; [ext-D6-acceptance.md](../ext-D6-acceptance.md)
"Decision 6"): once, after the gate's cycle, as D6g's private run (`sweep_zoom.py`: the tree's `ext_zoom.py` with
only its matrix rule replaced; win a/b, dos a/b and sw at every host size of the three scenarios and the soak at
1920x1440, the DOS soak included; goldens to a private file): `ZOOM_OK combinations 32 runs 160 samples 776 map
comparisons 32 centre runs 4 mzi runs 12 mzs runs 4 not zoomed 64/796`; the tree's 628 golden lines all equal, the
148 new lines the DOS soak's (dos a = dos b; the layer samples against win b and sw). test.cmd's matrix is unchanged.

### 16.4 P0 (7.3)

`ext_p0.py` V4: every scenario and S1..S5 with `--host-size 1920x1440` and `zoom` commands at
1301 ms intervals cycling +1, -1, reset, 0. At M in the Windows profile; from D6 also combined
with the DOS profile and with `--switch-every 997`, those runs with `--dos-data build\dosdata`
and the switch assertion of RV1-5. Plus the `CIV_OBSERVER=0` refusal. Every checkpoint, core
frame hash and `events.log` equal the plain run.

**Implemented in D6d (2026-10-16).** One combined variation V4d: V4 with `--dos-data build\dosdata
--switch-every 997` in every V4 run; P0 against V0, the switch assertions (switches >= 1, refused
0), no `zoom refused`, and over all V4d runs the layer drawn in at least one show of each profile
(22 runs each); `P0_OK checks 476` ([D6d record](../ext-D6d-record.md)). The same at the D6 phase gate (D6g,
2026-10-17): `P0_OK checks 476` in Checked, 62 in CheckedNoObs (V5 and the zoom refusals).

### 16.5 7.8 input

Host-form scripts (A 12.4) at `--host-size 1920x1440`:
* `hwheel` over the map and elsewhere; chords pressed with and without repeat; plain `=`, `-`,
  `0` reaching the game unchanged (coreinput.log).
* A click on a ring square at -1 gives the same `coreinput.log` and checkpoints as the
  equivalent hwnd-form small-map click script; a click on a covered in-view point posts nothing.
* In-view clicks at ±1 post the same core input as unzoomed clicks on the same square points.

**Implemented in D6d (2026-10-16).** The DOS pairs: `zoomkeys-dos` (zoomkeys' host lines plus the
profile chord at 40,000 ms, in play) equals `plain`, every zoom chord and wheel line `events 0` with
its command, one switch, refused 0, the DOS layer drawn; `ring-dos` (ring's lines plus the chord,
at `--zoom -1`) equals `ringref`, ring_press 1, ring_refused 0, one switch, the DOS layer drawn;
`EXT_ADAPT_OK checks 128` ([D6d record](../ext-D6d-record.md)).

## 17. Changes needed in other areas

**Area A** (all accepted, RV1-4; A adds them to its sections 2, 5, 7.2, 8.3 and 10.1, and K2's
list of w16 changes gains the two w16 items of A-3 with G-1 and the base tests as their guard)

| Id | Change | Reason |
|---|---|---|
| A-1 | Tick step 4: return only when the visible profile shows the core frame **and** `pmap_pending()` is 0; steps 6..7 then show the layer's damage | layer changes without core presents (5.3) |
| A-2 | `present_core` and the VIEW redraw call `pmap_overlay` after scaling, before `host_show`; `pmap_on_core_present` is called for every profile | 5.3, 6.1 |
| A-3 | Queries: `w16q_wnd_client_vis(hwnd, &cx, &cy, W16qRgn *)` (the client part of the visible region over w16's `w16_wnd_client_vis`, user_wnd.c 754..763, which fills the caller's region and allocates nothing); `w16q_sys_track(W16Rect *band_outer, int *width)` (the move or size outline while shown); `w16q_draw_on(W16Surf *dst, const W16qOp *op)` (TextOut, DrawText with an HFONT and format, LineTo with a pen width, FillRect, FrameRect, colour-to-physical mapping, on a caller surface, no DC, no handle) | 5.2, 7.3 |
| A-3a | **New w16 state for `w16q_sys_track`.** user_syscmd.c keeps the outline rectangle only as `movesize`'s local `cur` (160..298). `outline()` (94) gains two file statics, `g_outline` and `g_outline_on`, toggled at each call: every call XORs the same band on or off (calls at 208, 276/282, 291/293, 298), so the toggle tracks what the screen shows. Behaviour of the loop is unchanged | 5.2 |
| A-3b | **Rasteriser refactor for `w16q_draw_on`.** The gdi_draw.c and gdi_font.c rasterisers (FillRect, FrameRect, LineTo with pens, `w16_font_text`, DrawText layout) are split into a DC-free part that draws on a `W16Target` over caller memory and the existing API wrappers that prepare the DC; the virtual screen's drawing goes through the same code | 7.3 |
| A-4 | `PiOut` gains `cmd_hx`, `cmd_hy` (the wheel's anchor); `pi_arrive_mouse` consults `pmap_layer_point` (RV1-2) | 11.1, 12 |
| A-5 | `HostEvent.frame` values: 3 (the layer, a virtual-screen point; the filter passes it as 0), 4 (a ring square press, its moves while held and its release, translated or consumed at the sync); the arrival stage latches a press's class until its release (RV2-3; A 10.1) | 12.1, 12.2 |
| A-6 | `presented.log` `zoom ... view_sha256`; `view-NNNNN.bmp`; `profiles.log` `map` hash per profile when the level is not 0 (as implemented in D6d: ` map <profile> <sha256>` for each registered profile whose layer sample exists, `pmap_layer_sample`, the layer rendered whole over the clip's bounding box at the sample time, hashed as XRGB in that profile's current palette) | 13, 16.3 |
| A-7 | Probes added: TileCacheLookup 1110:030C (E); DrawUnit 1110:0DBA (E, X); UpdateUnitSightAndContacts 11C0:0395 (X); DeleteUnit 11C0:16A4 (X); ProcessGameTurn 1088:0000 (E); BlinkActiveUnitUntilInput 11C0:0EC2 (E); AnimateUnitMove 11C0:2C32 (E, X); ResolveCombat 1050:0000 (E, X); RedrawMapRect 1208:1534 (E, X); DrawTile 11A8:0CB1 (E). All are live `fr_enter` functions (RV1 claim 34). Already in A's list and used: DrawTilesToPort (E, X), TileCacheInsert, CopyPortBits, CopyPortToWindow, SetGrPort, CyclePaletteColors. **Corrected in Revision 3 (RV2-1):** DrawMapTile, DrawUnitAt, DrawCityLabels and WdwMapOpen were in A's list with WI's entry phase only, so 9.3's DROP brackets never closed; A 4.3 now gives them E and X | 7.1, 9, 10 |
| A-8 | System-menu ids 0x10C0, 0x10D0, 0x10E0; `--zoom default\|-1\|0\|+1`; settings key `zoom`; the harness `zoom` command calls `pmap_request_zoom` | 13 |

**Area B** (B's to adopt; RV2 checks them)

| Id | Change |
|---|---|
| B-1 | The shadow engine offers handler hooks and the map model registers its macro table there (resolved, C5; 9.3, 9.4): inside a bracket, drawing events to the bracketed shadow are dropped; copies to the window shadow apply; the rule set (Windows or DOS) is passed to the handler. **Adopted by B** (B 7.3, 7.5) with the names `PdosMacro`, `pdos_shadow_macros`, `PdosShadowHooks`, `pdos_shadow_hooks`, `pdos_shadow_context`, `PDOS_MAC_DROP`, `PDOS_MAC_CONTEXT`; D 9.3 and 9.4 use them (RV2-7). |
| B-2 | During play the A canvas has the virtual screen's current size and the Windows layout (resolved, C4; DOS-PROFILE.md row 96), so its map client region is `Wn_dos` at map-pixel resolution. |
| B-3 | `present_host_rect_inner` and `present_axis_taps` in scale.c (5.2, 5.4). |
| B-4 | The DOS label and size-digit font (L23; decision X5 corrects Revision 2's L17); the DOS play palette state with the map cycling (14.7); the DOS driver model used for drawing (G#32, G#20, G#3, fills, outlines, text; 14.0). |
| B-5 | The DOS small map (with the P9 rule of 14.8), the status window and the unit panel (resolved, C7). |

**Area C**: none for timing (the map has no presentation-local clock or generator). The filter's
frame-4 translation sits in the filter stage next to C's adapters; it needs no pending queue.

**Area E** (RV1-1)

| Id | Change |
|---|---|
| E-1 | `pdos_shapes` serves the families of 14.0 by family and index: terrain (with the TER257 row rule, DGROUP:1A3E taken as 0), coast quarters, river mouths, roads, railroads, rivers, unexplored edges, the grassland marker, D4CE icons 4..6 and 16..39, the 8 x 28 recoloured unit copies and citizens. Shape: width, height, pixels with 0 transparent (run sprites). **Answered by E.9.2** (`PdosShape`, `pdos_shape(PDOS_SH_*, i)` with DOS indices). The two page-2 rectangles are read from E's page-2 picture (`pdos_pic(PDOS_F_SP299_PIC)` inside `PDOS_PAGE2_ART_*`), not asked as shape families (RV2-8; 14.0). |
| E-2 | `OFFSETS.md` rows for DGROUP:1946 and 1956 (8 words each, FORMATS.md 6.1). |
| E-3 | The play palette files `SP256.PAL` and `BACK*.PAL` for B's palette state (14.7). |


## 18. Costs and limits

| Item | Cost | Limit and failure |
|---|---|---|
| Snapshot | ~92 KB copy, 5 to 8 µs per trigger; ≤ ~16 ms per AI turn (estimate) | bad pointer: that part zero, `map_bad_read` |
| `M` | copy of `D ∩ client` per present; ≤ 4 MB | port size mismatch: the overlap's covered pixels, the others kept (black only where never seen; MZS; before MZS covered pixels black), `map_port_size` |
| World canvas | 4 MB + 1 MB; first render 5 to 10 ms; then changed squares | allocation at first need; failure: ring black, `map_no_memory` |
| Layer | one index per host pixel of the clip's box (≤ 8 MB at 3840x2160); full re-render 8 to 15 ms (zoom, pan); palette reconversion ~4 ms at 4 M pixels, 5 per second while the map palette cycles | region > 64 rectangles: inactive for that show |
| Model (DOS, D6) | per macro: one square, unit or label set; its three shadows (≤ 3 x 4 MB) live in B's engine | unexplained events counted |
| `pdos_shapes` (E) | cut once at activation; the map holds no copies | an unavailable shape makes the DOS profile unavailable at activation (E's rule), never a run-time fault |
| Mirror checks (test only) | a client compare per full redraw | |

## 19. Rule coverage

| Rule | How the design meets it | Test |
|---|---|---|
| Z-1 levels | -1, 0, +1 (user, C1); wheel and chords; reset; Windows -1 pixel-perfect for even k, the recorded 2:1 reduction at k = 1 and odd k; DOS -1 pixel-perfect for every k | test_map; 7.8 chord and wheel; ext_zoom; PASS for the DOS profile at the D6 phase gate (D6g, 2026-10-17; [ext-D6-acceptance.md](../ext-D6-acceptance.md) "Z-1..Z-3 for the DOS profile") |
| Z-2 renderer | met by construction (C3): level 0 has no layer, in view the core's pixels; the ring proven by the settled check (M gate); the M2 present check at D6 (C2) | ext_mirror; ext_zoom determinism; PASS for the DOS profile at the D6 phase gate, with the full ext_zoom matrix (16.2, 16.3) |
| Z-3 input and P0 | section 12; section 1 | 7.8 runs; V4; PASS for the DOS profile at the D6 phase gate (ring-dos, zoomkeys-dos, V4d; 16.4) |
| 5.8 map window, art pixel | class `CIV`, `WdwMapProc` 1208:0054; DOS 16 per square (SCENES-PLAY.md 1) | test_map |
| 5.8 default, steps, half level | 4.1 (user's levels replace steps) | test_map |
| 5.8 layer clipped to the visible client region | 5.2 | test_map (regions); ext_zoom with a dialog open (input, load-save) |
| 5.8 anchoring (wheel, centre, active unit, whole view) | 11 | test_map; ext_zoom samples after moves |
| 5.8 wrap and poles | 4.4 | test_map |
| 5.8 renderer reimplements the named functions, reads shapes through handles | 7.3 | ext_mirror key, render, settled |
| 5.8 no ported functions on a checkpoint | pure reimplementation; no core function is called | obs_lint; guard |
| 5.8 following the core in view | Windows: `M` from the presented screen; DOS: the model's handlers in B's engine (9) | ext_mirror present (M2, D6 gate) |
| 5.8 out of view after redraws, moves, turns | 7.1 triggers | ext_zoom |
| 5.8 never draws random numbers | section 1 item 3 | obs guard (`g_randSeed` forbidden reads counted 0) |
| 5.8 mirror equality | 10 | ext_mirror |
| 5.8 hashes name host size and zoom | 13 `presented.log` | ext_zoom goldens |
| 5.8 input (in view, outside moves, outside press) | 12 | test_map; 7.8 |
| 5.8 not zoomed | 2 | ext_zoom (small map pixels equal level 0's); since MZW the World Map's image only: its view rectangle follows the level (5.6), so D6e's planned check compares the small map with level 0's outside the zoom rectangle and the core's frame. As built in D6e: ext_zoom's `smmap` check, the DOS small map's model (the squares' DOS colours, profiles.log's `smmap`) at -1 equal to +1 in the same scenario, size, policy, profile and copy, and equal whichever profile is shown (`ZOOM_OK ... not zoomed 38/448`); ext_zoom runs no level 0, and level 0's model is the same function of the core's state (P0) |
| 7.3 V4 | 16.4 | ext_p0 |
| 7.4 | layer = pure function of `M`, snapshot, model shadows, zoom state; all kept in every profile | ext_zoom with switches |
| O3 | `w16q_*` only, `PmapSrc` never faults | obs_lint; test_map out-of-range |
| O4 | no writes, no `w16_` calls, no posts | guard; obs_lint; spin test |
| O6 | `M`, snapshot and DOS model updated in every profile | ext_zoom switch run |
| O7 | layer shows through the tick when it has damage (A-1) | presented.log tick lines with `zoom` |
| I1 | ring press becomes a small-map click only on the user's press | 7.8 |
| I2 | at level 0 the filter passes everything but chords | test_input (A) |
| I7 | zoom chords consumed, key state consistent | 7.8 chord runs |
| I8 | wheel never an event; zooms over the map only | 7.8 hwheel runs |
| T7 | map effects at the core's pace (14.6, 14.7) | D6 timelines |
| 5.9 (DOS assets) | shapes by family and index from E's `pdos_shapes`; only tables below DGROUP:6B30h through `OFFSETS.md`; drawing constants as cited immediates (14.0) | E's 7.6 tests; dos-settled |
| D-5 (class A map) | 14; the small map, status window and unit panel are B's (C7) | D6 tests; dos-settled |
| P3, P6, P9 | 14.6, 14.8 (P9 applied by B) | D6 tests |

## 20. Choices (summary)

1. Phases M1 (planned shape) and M2 (event model, with D6). Resolved by C2: M's gate is M1.
2. One zoom state for both profiles. Alt: per profile.
3. Under `fit` the levels halve and double the frame's own factor. Resolved by C1.
4. Levels set before a map window exists are kept. Alt: refuse.
5. Clip excludes the move/size outline band. Alt: suspend the layer; redraw the outline.
6. Inner host rectangles for the clip under `sharp`. Alt: outer rectangles.
7. In view under a dialog: the map port's bitmap. Alt: black (loses the map under dialogs at ±1).
8. Snapshot copied at every trigger in every run. Alt: only at -1; next tick; skip unseen AI moves.
9. Ring labels without the 32 cap, column-major order. Alt: apply the cap.
10. Windows model shadows only under `--mirror 2`. Alt: always (cost in play).
11. Active-unit pan for the human's units only. Alt: follow every animated move.
12. Keep the client-relative offset across view changes. Alt: keep the world position.
13. A ring press becomes a small-map click that recentres. Kept by C6; listed for the user's check.
14. The cursor is not zoomed. Alt: zoom it with the layer.
15. Remember the zoom in `zoom`. Alt: start at 0.
16. DOS ring labels unclamped. Alt: clamp to the layer's edges.
17. P9: follow the core's frame (correct), applied by B (C7). Alt: reproduce the 9-row rectangle.
18. Read the two page-2 rectangles from E's page-2 picture (`pdos_pic(PDOS_F_SP299_PIC)` inside
    `PDOS_PAGE2_ART_*`) with the map's own cited constants (RV2-8, E.9.2's form). Alt (Revision
    2's choice, withdrawn): ask `pdos_shapes` for them as two more shape families.
19. Public names take the `pmap_` prefix throughout (RV1-2, RV1-3), types included (`PmapSrc`,
    `PmapSnap`, `PmapView`; RV2-6). Alt: rename only the clashing function.
20. A press latches its class (ring, view, off the layer) until its release (RV2-3, with A 10.1).
    Alt: classify every move and release by its own position (splits presses from releases).

## 21. Open items

| Id | Question | Resolved by |
|---|---|---|
| D1 | The scratch port's DC and bitmap offsets (12D8:44BC, 44BE) | `GR_PortOpen` 10D0:0000 listing at M2 |
| D2 | Which DrawTile calls inside `ResolveCombat` draw the lunge and the explosion (the sparks DOS-PROFILE.md row 134 places at 1050:0A9C..0AEA) | listing at M2; ext_mirror present check |
| D3 | DGROUP DCFC's meaning (taken as `g_mapDrawMode == 0`) and D806 as `g_revealAll` | DOS listing (L2) at D6 |
| D4 | The number of `UpdateUnitSightAndContacts` calls per AI turn (cost estimate) | S4 measurement at M |
| D5 | Whether any core path draws into the map port outside the macros and copies (`map_unexplained` > 0) | ext_mirror at M2 |
| D6 | The DOS label and digit fonts | area B, L23 (X5): B 10.1 answers font 1 (inferred); B's OB4 confirms per path at D6/D7 |
| D7 | L11, L12 (DOS play palette details) | D6 listing work |
| D8 | Whether w16 keeps the posted button state when `FlushInputEvents` removes a queued release (the small-map path); the same holds for a real small-map click | 7.8 run at M |
| D9 | **Closed (Revision 3, RV2-8).** E.9.2 gives the families (`PDOS_SH_*`, DOS indices) and the record (`PdosShape`); the page-2 rectangles come from E's page-2 picture (Choice 18, 14.0) | E.9.2 |
| D10 | **Closed (Revision 3, RV2-7).** B 7.3 and 7.5 give the final interface (`PdosMacro`, `pdos_shadow_macros`, `PdosShadowHooks`, `pdos_shadow_hooks`, `pdos_shadow_context`); 9.3 and 9.4 use it | B 7.3, 7.5 |

**Implemented in D6a (2026-10-16).** D1, D2 and D5 are answered ([D6a record](../ext-D6a-record.md)
"Open D1, D2, D5"): D1 as inferred (12D8:44BE, 12D8:44BC); D2 the lunge at 1050:093A and the
explosion at 1050:0AEA; D5: in all 29 runs everything outside the macros was a black fill, a copy
between map shadows, a context DrawTile or a window draw that reached nothing (`replays 0`, `bits
0`, `tiles_outside 0`).

**Implemented in D6c (2026-10-16).** D3: DCFC settled from the listing ("DCFC clear" is
`g_mapDrawMode == 0`, 14.2); D806 has no writer in the listing and is taken as 0, not
`g_revealAll` (the record's deviation). D6 stays open: the listing sets no font in R:1AEA:0008,
03BA, 0FB3; font 1 stays inferred. D5 for the DOS rule set: `dos_tiles_outside 0` and `dos_bits 0`
in the 29 runs ([D6c record](../ext-D6c-record.md) "Open D3, D806, D6 / OB4 / L23").

## 22. Conflicts and their resolutions

All seven were resolved by the orchestrator (ext-d1-decisions.md, "Area D") and are applied in
this revision.

| Id | Conflict | Resolution | Applied in |
|---|---|---|---|
| C1 | The user's -1/0/+1 replace 5.8's integer steps and `--zoom <m>`; Windows -1 is not pixel-perfect at odd k; under `fit` the real factor is doubled | The user's direction wins: odd-k (and k = 1) level -1 is the recorded 2:1 reduction of the half level, not pixel-perfect, labelled in RUNNING.md and FIDELITY; pixel-perfect at even k and in the DOS profile; `fit` halves and doubles the actual factor; `--zoom default\|-1\|0\|+1` | 4.1, 13, 19 |
| C2 | 7.5 "at every present" against the planned shape's "mirror equality on in-view squares" | M's gate is the M1 checks (key, render, settled); M2 is built and gated with D6 | 2, 10.1, 10.2, 16.2 |
| C3 | Z-2's pixel-identical default renderer | Met by construction (no layer at level 0; the core's pixels in view); recorded | 19 |
| C4 | The A canvas size during play | Area B designs the A canvas at the screen's current size | 6.2, 17 B-2 |
| C5 | Map-specific shadow handlers | One engine in B with handler hooks; the map model registers there | 9.2, 9.4, 17 B-1 |
| C6 | A press outside the view becomes a recentring small-map click | Kept (5.8's own example); recorded in FIDELITY and listed for the user's check | 12.2 |
| C7 | Owner of the DOS small map, status window and unit panel | Area B | 14.8, 17 B-5 |

**Left open for RV2** (not conflicts): the names of E's `pdos_shapes` families and of B's engine
hook (D9, D10), since neither revised draft was available; this draft states the shapes and the
hook behaviour it needs.

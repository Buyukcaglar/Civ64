# D1 draft B: composition, shadow surfaces, logical replay, classes, palette rule, text and fonts

Design agent D1-B, 2026-10-11. Brief: [BRIEF-d1.md](BRIEF-d1.md), area B. This draft builds on
[ext-d1-draft-A.md](ext-d1-draft-A.md) (observer, probes, `w16q_*`, tick, profile interface),
[ext-d1-draft-D.md](ext-d1-draft-D.md) (map model; its section 17 requests B-1..B-5),
[ext-d1-draft-E.md](ext-d1-draft-E.md) (asset store, `pdos_` prefix),
[ext-d1-draft-C.md](ext-d1-draft-C.md) (timelines, sequencing, adapters; its C.21 requests
B-1..B-8) and the binding resolutions in [ext-d1-decisions.md](ext-d1-decisions.md) (K1..K9,
E.18-*, C1..C7, RV1-*, X1..X6, C.20-*).

## Revision 3 (after RV2)

This revision applies [ext-d1-review-rv2.md](ext-d1-review-rv2.md) as
[ext-d1-decisions.md](ext-d1-decisions.md) "Design review RV2" resolves it. The listing facts were
read again (root.lst R:1D05:0494..05B7, R:1DC4:007C..0099; ovl06.lst writes of DGROUP:3936).

* **RV2-1 (blocker).** The status, small-map and play-palette consumers now have exit probes: A 4.3
  gives E and X to DrawSmTiles, RedrawSmMap, RedrawStatusWindow, DrawStatusCivPanels,
  DrawUnitInfoPanel and WdwMapOpen (and D's three map macros). 7.3 states that every macro key
  needs the exit; `pdos_shadow_macros` checks each macro at registration with A's
  `obs_probe_phases` and refuses and counts (`macro_config`) one without it (7.3); 5.5, 12.2 and
  12.3 cite the exits; 9.1 notes that an exit-0 scene row needs its key's exit. A's obs_lint checks
  all three forms (A 6.2).
* **RV2-4.** `PdosMacro.ra` and `PdosSceneRow.ra` are resolved with A's `obs_callsite` at
  registration and reset; an unresolved pair is a configuration error (7.3, 9.1).
* **RV2-6.** 12.2 reads D's exported `pmap_src_current()` and `pmap_view_current()`.
* **RV2-11.** 4.4's `PdosMenuBox` gains the input `h8` (DGROUP:3936 ≠ −1 makes h = 8,
  R:1D05:04A8..04AF) and the row clamp to (192 − y)/h (R:1D05:057D..059A); `test_pdos_ui` gains
  vectors for both (15.1).
* **RV2-12.** 2.1's `on_probe` order at an exit runs C's timelines to the probe's time, then the
  shadow engine's `leave`, and pops the scene after it (Choice B24; 9.2).
* **RV2-15.** 8.2's `ScaleLogical` is `(int16_t)((long)v * 160 / 100)`, the core's 16-bit AX.
* **RV2-16.** 8.2: R:0182:00B3 leaves the port's style word at 1 (opaque) after its transparent
  draw.
* **RV2-17.** 10.1 records that the segment at DGROUP:640A is both the leader-font table and E's
  "throne-room table" (E-B2).
* **RV2-18.** 9.3 states that B11's instance ordinal changes only in `on_event`, `on_probe` and
  `advance`, never in `frame()`, `peek()` or a switch, with a test.
* Section 20 records A's and D's Revision 3 adoptions (A-B10, A-B11, D-B1, D-B4, D-B6); 21 marks X8
  and X9 applied.

## Revision 2 (before RV2)

This revision applies the orchestrator's resolutions "Area B" X1..X6, "Area C" C.20-10 and
"Design review RV1" (RV1-4, RV1-17, RV1-18) of [ext-d1-decisions.md](ext-d1-decisions.md), adopts
the requests of [ext-d1-draft-C.md](ext-d1-draft-C.md) C.21 (B-1..B-8) and of
[ext-d1-draft-D.md](ext-d1-draft-D.md) Revision 2 section 17 (B-1..B-5, with its 9.4 hook
proposal), and aligns with drafts A and E Revision 2. The revision-1 text is kept in scratch
(`build/d1/scratch-B/draft-B-rev1.md`).

* **X1..X6 (decisions).**
  * X1: the P4 per-scene report is part of the D4..D7 records (5.4).
  * X2: the inherited-font rows stay **inferred** with OB4 open (10.1).
  * X3: the `--aspect` default is 4:3 for 320x200 frames (A 11); 6.6 and section 0 follow it.
  * X4: Choice B15 kept, for the user's visual check at D6 (11.2).
  * X5: the label font is L23 (D's "L17" citations are corrected at the merge). 10.1 now names the
    label, city-size and unit-letter text (D's B-4).
  * X6: units are cut at DOS's rectangle (13, E.9.3 row 22).
* **C's requests (C.21 B-1..B-8, C.20-10), all adopted.**
  * B-1, B-2, B-5: the machine, glyph, UI, DAC, fade, cycling and dissolve primitives that C's
    programs call. 5.3's cycling record now holds the count and position, and C gets a multi-step
    entry for its shortcut.
  * B-3: a pure menu-box model with a row query, `pdos_menubox_row` (new 4.4). It is taken from the
    listing R:1D05:018A..0233, and `pdos_r_hit` uses it too (11.4).
  * B-4: `pdos_cursor_current()` consults C's `pdos_seq_pointer_hidden()` (6.7).
  * B-6: the T4 setup page is drawn from DOS static content before dialog 144 exists, and taken
    over without a redraw (new 11.5, Choice B21).
  * B-7: the scene stack and its listener (9.2).
  * B-8: `pdos_profile.c` forwards every event and probe to C, after the scene-stack update and
    before B's own drawing, and calls `pdos_seq_advance` from `advance`, visible or not (new 2.1,
    Choice B22).
  * C's note: the DOS `srand` takes a 16-bit seed. `pdos_srand` now takes `uint16_t`, B11's seed is
    folded to 16 bits, and `pdos_random` is signed with the listing's arithmetic shift (9.3).
* **D's requests (D 17 B-1..B-5, D 9.4; decision C5).**
  * B-1: **the final shadow-engine interface** (7.3, 7.5). It has one engine, two rule sets (DOS,
    and Windows for D's `--mirror 2` oracle), macros that draw at entry (D) or at exit (B's
    replay), a `target` callback, an ownership rule for nested brackets, and the hooks `claim`,
    `on_draw`, `on_copy`, `on_resize`, `on_free`. D's proposed `PsMacro` and
    `ps_register_macros` become `PdosMacro` and `pdos_shadow_macros`.
  * B-2: the A canvas has the screen's size, with `Wn_dos` composed as the map element (6.2).
  * B-3: `present_host_rect_inner` and `present_axis_taps` (20), unchanged.
  * B-4: the label, size-digit and unit-letter font is 1 (inferred, L23), and the play palette
    (5.5). For the driver model at map-pixel resolution, `PdosPort` gains a scale `k`: D's
    shadows draw DOS art at 2x with the same functions (3, 4.1; Choice B23).
  * B-5: the small map, status window and unit panel (12), unchanged.
* **A's Revision 2.**
  * 6.7 is rewritten. The pointer image is in logical pixels of the presented frame (1x on N, 2x on
    A); the back end applies the layout factor (A's Choice 26), and `gen` ignores the window size.
    `pdos_cursor_current()` returns NULL for "use the game's cursor" (the scroll arrows 136..143),
    which answers A's Open A11.
  * 6.5 follows A 7.3's dumps: `tick-NNNNN.bmp`, 8-bit for N frames through the profile's
    `indexed` callback.
  * 11.2 reads `w16q_msgbox` from the box's `OBS_WND_SHOW` until its destroy, and the menu bar
    through `w16q_menu_bar` and `w16q_menu_item`.
  * 8.2: B computes ScaleLogical itself, so A's exit probe on ScaleLogicalX/Y is not needed by B.
  * `present_core_xrgb()` is the one accessor for the Windows frame (6.2).
  * The profile's `input_frame` callback is defined (2.1).
  * `ObsProbe.site` is used for call-site filters (7.3).
* **E's Revision 2.**
  * `PdosShape` is `w, h, px` (no hot spot).
  * The pointer is `pdos_shape(PDOS_SH_ICON, 7)` (the torch, the same pixels as TORCH 0) or ICON 2
    (the GO arrow), with hot spot `PDOS_POINTER_HOT_X/Y`. E delivers palette indices; B converts
    them inside the DOS profile's cursor callback (6.7).
  * Pictures come from `pdos_pic`/`pdos_pal_dac` and fonts from `pdos_font*`.
  * B's palette module (`pdos_pal.c`) exports `pdos_dac_*`, `pdos_fade_*`, `pdos_cycle_*` and
    `pdos_play_*`, never `pdos_pal_*`, so E's `pdos_pal_dac` keeps its name.
* **Naming (RV1-18, E.2.1).** Every public name in `present/dos` takes the `pdos_` prefix: the
  machines `g_mn`/`g_ma` become `pdos_mn`/`pdos_ma`. The table checker is renamed
  `tests/harness/pdos_scene_check.py`, apart from E's `pdos_tables.c`.
* **Listing checks made for this revision (read-only).**
  * The menu-box mouse row is R:1D05:018A..0233.
  * `random(n)` is R:1DC4:005D..007B: signed 32-bit product, then `sar` by 15 (R:2045:32C0).
  * `srand` is R:2045:2AD8..2AE8: a 16-bit seed, high word cleared.
  * The leader-font input DGROUP:D7F4 is the per-slot tribe id. It is written at O5:0A01 and
    O15:018A and saved at O11:0BC1, and its counterpart is the core's `g_playerCivId` (12D8:4454).
    OB8 is resolved, and the corrected 10.1 row no longer asks E for D7F4, which is run-time
    storage.
* **I5 correction (16).** B's device-to-logical rule L(d) (8.3) is a drawing rule only. Area C
  inverts the core's input conversion (C.14), not L(d).

Notation. Windows addresses are `SSSS:OOOO`. DOS addresses carry `R:`, `O<n>:`, `G#n`/`G:` or
`DGROUP:`. DOS documents are cited by file and section: DRIVER, FORMATS, PALETTE, SPRITES, SCENES
(start-up and UI), SCENES-PLAY (SP), CORRESPONDENCE (CORR), WINDOWS-INVENTORY (WI), OPEN, and
`DOS-PROFILE.md` (PROF). No DOS bytes are reproduced; strings are named by their DGROUP offset.

Scratch: `claude/port/build/d1/scratch-B/` holds the read-only P11 scripts and their outputs
(section 13) and `barwidth.py` (DOS font 1 widths for P24, 11.2). Nothing else was written.

## 0. Authority points relied on

| Point | Source | Effect here |
|---|---|---|
| A canvas at the virtual screen's current size, not 640x480 | decisions C4 over prompt 5.3; user directions 2026-10-10 21:00 and 22:05 (F105, F110) | 6.2 |
| Scoped P0: profile, switch history and zoom always; host size and policy only with a fixed game screen | decisions K1 | 1, 6.5 (D-7) |
| One shadow engine with handler hooks; the map model registers there | decisions C5 | 7.5 |
| Area B owns the DOS small map, status window and unit panel | decisions C7 | 12 |
| DOS instruction immediates may be C constants with their DOS address; data-segment tables are read at run time | user decision D6 (2026-10-10 17:45), decisions E.18-5 | 3, 4, 12 |
| Area E owns `pdos_shapes`: the DOS start-up cut O5:1455 by family and index | decisions RV1-1 | 8.5 |
| The cursor route `present_cursor` and `host_set_cursor_pixels` are A's; the visible profile supplies the pixels | decisions RV1-7 | 6.7 |
| The DOS profile file is `pdos_profile.c` | decisions RV1-18 | 2 |
| `HostEvent.frame` tags the frame of a host point | decisions K5 | 6.6 |
| Default layout: map 165,0..W,H; World Map 0,0..166,127; Status 0,126..166,458 | F103 (user 2026-10-10 20:05); DESIGN 12.4 | 12 |
| The presented-frame hash (SHA-256 of W, H as LE words, then B, G, R, X) and the scaler policies (`integer`, `fit`; `nearest`, `sharp`; `stretch` removed) | DESIGN 12.1..12.4 | 6.5 |
| Start-up screens "shall stay 4:3": the `--aspect` default is 4:3 for 320x200 frames | user 2026-10-10 21:00; decisions X3; A 11 | 6.6 |
| P4 report per scene, no correction; inherited fonts inferred; menu bar 1x for the user's check; units at DOS's rectangle | decisions X1, X2, X4, X6 | 5.4, 10.1, 11.2, 13 |
| C's requests B-1..B-8 accepted; D's B-1..B-5 are B's to adopt; RV2 checks B and C | decisions C.20-10, RV1-4, RV1-17 | Revision 2, 2.1, 4.4, 7, 11.5 |
| A's Revision 2: `PresentProfile` with `cursor`, `indexed`, `input_frame`; `ObsProbe` with `site`; `present_core_xrgb`; the back end scales the pointer (A Choice 26) | draft A 4.2, 8.1, 8.3, 8.5 | 2.1, 6 |
| E's Revision 2: `pdos_shape(family, index)`, `PdosShape` without hot spot, pointer as ICON 7 / ICON 2 indices | draft E E.9.2, E.9.5 | 4, 6.7, 8.5 |
| No DOS bytes in the repository or binary | prompt 2.3 | everywhere |

Where these differ from prompt 5.3/5.4 (A canvas size, shapes owned by E), the later direction is
followed and named in the row.

## 1. P0 in one page

P0: presentation never changes checkpoints, the virtual screen or the base trace. Scoped as K1.

How area B keeps it:
* **Reads only.** Every read of emulated state goes through `w16q_*` (A 5). No `w16_<Api>`, no
  `mem_rd`/`mem_wr`, no `VM_SITE`, no `g_randSeed`. A's `obs_lint.py` covers `present/dos/**`.
* **Runs only in presentation callbacks.** The `PresentProfile` callbacks of 2.1 (`on_event`,
  `on_probe`, `on_core_present`, `advance`, `frame`, `peek`, `cursor`, `indexed`, `input_frame`),
  area C's calls into B made from inside them, and the pure queries of 4.4, 11.4 and 6.7 that C's
  filter stage calls under A's guard. All are under A's Checked guard and sentinel (A 6.1).
* **Writes only presentation memory.** Pages, shadows, surfaces and frames are `host_alloc`
  blocks owned by `present/dos`. An allocation failure degrades the picture and bumps a counter
  (14); it never reaches the core.
* **Produces no input.** Area B never posts or translates input. Its hit queries (11.4) are
  pure functions used by area C's adapters on user actions.
* **No core random numbers.** DOS-only effects use the driver's LFSR (G#10) or `pdos_rand`
  (9.3), seeded from presentation state. Core decisions are read from the core's events.
* **Follows the screen size, never sets it.** The A canvas is resized on `OBS_SCREEN_SIZE`. Area
  B never calls `present_game_screen*` (RV1-12).
* **Same output in Checked and Release.** No code path depends on `CIV_CHECKED`; diagnostics are
  counters only.

Proof:
* A's 7.3 runner with the DOS profile visible, with switch histories, and with every D4..D7
  renderer enabled: checkpoints, `events.log`, the base frame trace and `run.log` equal the
  Windows-profile run (K1 conditions).
* `test_pdos_*` (15) run the renderers on synthetic event streams with no emulation at all.
* The Checked sentinel faults on any emulated write or step inside a B callback.

## 2. Files and modules

All files are portable C17 under `present/dos/` with E's `pdos_` prefix. E's module names
(`pdos_assets`, `pdos_exe`, `pdos_pic`, `pdos_font`, `pdos_text`, `pdos_tables`,
`pdos_registry`, `pdos_shapes`) are not reused.

| File | Content | Phase |
|---|---|---|
| `pdos_mach.h/.c` | the DOS machine model: pages 0..3, view ports, DAC (3) | D3 |
| `pdos_draw.h/.c` | driver functions G#2/3/6/10/14/19/20/31/32/39/41/42 and root FillRect/DrawLine (4.2) | D3 |
| `pdos_glyph.h/.c` | G#21 DrawText, G#4/G#12 through E, root text helpers R:0182:*, truncation R:1F4D:04F7, wrapping R:1F4D:0000/0088, `$` tokens R:1F4D:0471 (10.2) | D3 |
| `pdos_ui.h/.c` | outline, bevel, box, texture, panel, ornamental border, the menu box model R:1D05:0031/0475 with its row query (4.4), text entry (4.3, 11) | D4 |
| `pdos_pal.h/.c` | the 6-to-8 rule, DAC loads and splices, fade arithmetic, cycling slots, scene palette recipes, the play palette (5) | D3 |
| `pdos_compose.h/.c` | N and A canvases, frame choice, W over N, damage, conversion, dumps (6) | D3 |
| `pdos_cursor.h/.c` | the DOS pointer image for A's cursor route (6.7) | D4 |
| `pdos_shadow.h/.c` | shadow surfaces, brackets, copies, handler hooks (7) | D3 |
| `pdos_replay.h/.c` | logical replay of the graphics.md 4.7 primitives and the text probes (8) | D4 |
| `pdos_prov.h/.c` | shape and picture provenance: handle to DOS counterpart (8.5) | D4 |
| `pdos_scene.h/.c`, `pdos_scene_tab.c` | the scene table in code and the scene stack (9) | D3 |
| `pdos_rand.h/.c` | presentation-local DOS generator (9.3) | D4 |
| `pdos_fontmap.h/.c` | Windows font id and call site to DOS font (10.1) | D4 |
| `pdos_charmap.h/.c` | the Windows-1252 fold (10.4) | D4 |
| `pdos_reskin.h/.c` | class R elements from the `w16` control tree (11) | D4..D6 |
| `pdos_play.h/.c` (built in D6e as `pdos_aplay.h/.c`: `pdos_pal.h` uses the `pdos_play_*` names for the play palette) | class A small map, status window, unit panel (12) | D6 (D6e) |
| `pdos_scn_<scene>.c` | the scene renderers of D5..D7 (for example `pdos_scn_setup.c`, 11.5): DOS positions, static DOS content, macros of their scenes | D5..D7 |
| `pdos_profile.c` | the `PresentProfile` of the DOS profile (A 8.1; RV1-18), the callback order of 2.1 | D3 (A's D3 form, A 8.4), B's from D4 |
| `present/scale.h/.c` | `present_host_rect_inner`, `present_axis_taps` (D's B-3) | M |
| `tests/harness/pdos_scene_check.py` | read-only check of the scene table and font map against `DOS-PROFILE.md` (9.1, 10.1) | D3 |

Dependencies: `pdos_profile` → compose → (shadow, replay, reskin, play, scene, scn_*) → (draw,
glyph, ui, pal) → mach. Only the event and probe handlers (in `pdos_profile`, `pdos_shadow`,
`pdos_replay`, `pdos_prov`, `pdos_scene`, `pdos_reskin`, `pdos_play`, `pdos_scn_*`) call `w16q_*`;
`pdos_mach`, `pdos_draw`, `pdos_glyph`, `pdos_ui`, `pdos_pal`, `pdos_rand`, `pdos_fontmap` and
`pdos_charmap` are pure and testable without `w16` (area C's timelines link against these only,
C.15.1).

### 2.1 `pdos_profile.c`: the callbacks and their order (C's B-8, A 8.1)

| `PresentProfile` callback | What it does, in this order |
|---|---|
| `available` | E's `pdos_assets_status() == PDOS_OK` (A 8.1) |
| `reset` | every B module's reset (machines black, shadows, stack, palettes, pointer), then C's `pdos_seq_reset()` (request to C, 20) |
| `on_event(e)` | 1. `pdos_scene_on_event` (window-bound rows pop; C's listener runs inside, 9.2); 2. C's `pdos_seq_on_event(e)` (C runs its timelines to `e->t_us` before applying, C.5.3); 3. `pdos_shadow_on_event` (copies, hooks, unexplained; D's handlers run here, 7.5); 4. `pdos_reskin_on_event`, `pdos_play_on_event`, `pdos_compose_on_event` (screen size, z-order, clips) |
| `on_probe(p)`, entry | 1. `pdos_scene_on_probe` (push); 2. C's `pdos_seq_on_probe(p)`; 3. `pdos_fontmap_on_probe` (SetCivFont, SetTextFontSizeColor); 4. `pdos_shadow_on_probe` (macros and brackets: entry reads; B's replay and D's macros); 5. `pdos_prov_on_probe`; 6. the scene renderers' probes |
| `on_probe(p)`, exit (RV2-12) | 1. C's `pdos_seq_advance(p->t_us)` (C's timelines reach the probe's time first, as Choice B22 requires); 2. `pdos_shadow_on_probe` (exit draws: `leave` sees the returning function's row on top, 9.2); 3. the scene renderers' probes; 4. `pdos_prov_on_probe`; 5. `pdos_fontmap_on_probe`; 6. `pdos_scene_on_probe` (pop; C's listener runs inside); 7. C's `pdos_seq_on_probe(p)` |
| `on_core_present` | `pdos_compose_on_core_present`: the A base layer's damage (6.2) |
| `advance(now)` | 1. C's `pdos_seq_advance(now)` (the timelines draw up to `now` on `pdos_mn`); 2. `pdos_cursor_update()` (6.7: `gen` when C's hidden rule or a used DAC entry changed). Visible or not (O6) |
| `shows_core_frame` | 0 |
| `frame`, `peek` | `pdos_compose_frame`, `pdos_compose_peek` (6.3, 6.5) |
| `cursor` | from `pdos_cursor_current()` (6.7) |
| `indexed` | `pdos_compose_indexed` for an N frame, 0 for an A frame (6.5) |
| `input_frame` | 1 while the N frame is presented, 2 for the A frame (6.3, 6.6) |

* **Choice B22: area C's sequencing before B's drawing for the same event.** A DOS step and a core
  event at the same microsecond: C's step comes first (C.5.3), so C runs to the event's time
  before B applies the event to the shadows. The scene stack is updated before both, so C and B
  read the same top row. Alternative: B first, then C (a scripted step due at that instant would
  draw over the event's effect).
* **Choice B24: the scene pops after the exit draws (RV2-12).** RedrawStatusWindow,
  DrawStatusCivPanels, DrawUnitInfoPanel, DrawSmTiles and WdwMapOpen are both scene rows (WI 10.7
  rows 96, 136..139) and macro keys (12.2, 12.3). Popping first would give their `leave` the
  parent's row (its colours, palette and renderer). The exit order is the reverse nesting of the
  entry order, with C's timelines brought to the probe's time first so B22 still holds.
  Alternative: keep one order and require that no `leave` reads the scene stack (RV2's other
  option), which would forbid the colour maps of 8.4 at exit.
* `pdos_seq_*` are C's functions, called only from here: C has no profile of its own.

## 3. The DOS machine model (`pdos_mach`)

One machine per canvas kind keeps DOS semantics exact while the A canvas has its own palette.

> **C passage condensed for the public copy.** The original record has here a block of 30 lines of C declarations: types `PdosSurf`, `PdosPort`, `PdosDac`, `PdosMach`; functions `pdos_mach_init`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* `pdos_mn` is the N machine: page 0 is the N canvas (6.1). Area C's programs draw on it
  (C.5.4).
* `pdos_ma` is the A machine: its DAC is the play palette (5.5); its pages hold the resident play
  art that DOS keeps in page 2 (SP 1.1): E's `pdos_shapes` and the page-2 area of `SP299.PIC`
  (`PDOS_PAGE2_ART_*`, E.9.2), copied into page 2 at activation as O5:1484 does.
* **Scale `k` (Choice B23, D's B-4).** With `k = 1` every function is the DOS function. With
  `k = 2` a DOS coordinate (x, y) of the port is surface pixel `(ox + 2x, oy + 2y)`, every DOS
  pixel is a 2x2 block, sizes and clip limits stay in DOS pixels, and the origin is in surface
  pixels (so it may be odd: D's map squares start where the core's `DrawMapTile` puts them, D
  14.1). D's map shadows (map pixels, DOS art at 2x) are drawn with the same driver, glyph and UI
  functions. Alternative: separate 2x functions in D (two drivers to keep equal).
* Port defaults follow DOS: the start-up sets font 1 (O2:015E) and the text helpers leave the
  style at 1 (R:0182:005C/00B3 set 0, draw, set 1).
* DGROUP:6B8C (x doubled in R:0182:002A) is only read (R:0182:0040) and lies past the
  27,440 initialised DGROUP bytes (EXECUTABLE 2), so it is 0: the model never doubles x
  (**inferred**: the C start-up clears that area).

## 4. Drawing primitives: the driver in portable C (`pdos_draw`)

### 4.1 Rules for every function

* Each function mirrors one DRIVER.md entry or root routine. Its comment cites the entry. The
  contract text is not repeated here; the tests (15.1) encode DRIVER's statements as vectors.
* Coordinates are `int16_t` as on DOS. Products and sums that DOS forms in 16 bits wrap in 16
  bits in the model too.
* **Memory safety.** DOS writes outside a page for some inputs (RecolourRect with w or h of 0
  loops 65536 times; CopyRect does not clip). The model computes each DOS offset as DOS does
  (16-bit wrap inside the page's segment) and drops any write whose offset is not below
  `stride * h`, counting it in `pdos_diag.oob`. **Choice:** drop and count. Alternative: a 64 KB
  segment per page, which reproduces writes into the bytes 64000..65535 that DOS keeps elsewhere
  (unknowable content).
* Every function adds what it changed to `s->damage` and bumps `s->gen`.

### 4.2 Driver functions

> **C passage condensed for the public copy.** The original record has here a block of 25 lines of C declarations: functions `pdos_grab`, `pdos_recolour`, `pdos_sprite_clipped`, `pdos_sprite`, `pdos_dissolve_start`, `pdos_dissolve_frame`, `pdos_get_pixel`, `pdos_write_row` and 4 more. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* G#30/G#15/G#9 (pointer draw, restore, into page) are not modelled: the pointer is a host
  cursor (6.7). **Choice.** Alternative: a software pointer in page 0, which makes every
  presented frame depend on the mouse position and redraws at every mouse move.
* G#27 MapLow16Colours, G#28 LoadPaletteBlock and the DAC writer are in `pdos_pal` (5.2).
* G#22 (scaled sprite), G#16, G#17, G#23..G#26 have no callers that the profile reproduces and are
  not modelled (DRIVER 4 marks them uncalled or unused).
* `PdosShape` is E's (E.9.2): `w, h, px` with 0 transparent, fetched with `pdos_shape(family,
  index)` by DOS index; NULL (an entry DOS never cut) draws nothing (E counts `dos_shape_uncut`).
  Run-sprite storage draws the same pixels as "0 is transparent", so the model draws plain arrays
  (E.9.1's argument). `PdosShapeBuf` (G#2's output) is B's own: a grabbed copy of a page
  rectangle, used for DOS save-unders of scene renderers.
* `pdos_dissolve_*` are area C's B-5: C calls `pdos_dissolve_frame` once per DOS frame of its
  timeline and, on abandon, until it returns 1 (C.5.2); with duration 20 that is 146 frames of
  440 offsets.
* With a port of `k = 2` (3) each function scales its writes; vectors at `k = 2` are in
  `test_pdos_draw` (15.1).

**As implemented (D4a).** The span-skip column G:0000:1986 is one value per machine
(`PdosMach.span_x`), shared by its four pages: lines and pixels on any page write it and a fill on
any page reads it. Only a surface outside a machine (a shadow, an element) keeps its own value.
This supersedes "per surface" for the pages of a machine (review-1 F3,
[D4a record](../ext-D4a-record.md#review-fixes-2026-10-12)).

### 4.3 Root helpers (`pdos_ui`, `pdos_glyph`)

| Function | DOS routine | Note |
|---|---|---|
| `pdos_outline(p, x, y, w, h, c)` | R:1D05:0A05 | (x, y)..(x + w, y + h) inclusive |
| `pdos_bevel(p, x, y, w, h, c1, c2)` | R:1D05:0A66 | top and right c2, bottom and left c1 |
| `pdos_texture(p, x, y, w, h)` | R:1DC4:03CE | tiles the 32x16 stone tile at page 2 (288, 120): the page-2 copy of `SP299.PIC` (E.9.2 `PDOS_PAGE2_ART_*`) |
| `pdos_panel(p, x, y, w, h)` | R:0238:1BB2 | texture, then bevel (x, y, w - 1, h - 1, 15, 8) |
| `pdos_box(p, x, y, w, h, c)` | R:1D05:096C | fill (texture when c is 7 and DGROUP:2F98 is not 0), bevel 15/8, black outline |
| `pdos_border(p, ...)` | R:0866:260E | ornamental border; the tile choice uses `pdos_rand` (9.3) |
| `pdos_menubox_*` | R:1D05:0031, 0475 | 4.4, 11.2 |
| `pdos_entry_*` | SCENES 10.4 | 11.2 |
| text helpers | R:0182:002A/005C/0086/00B3/00EF | 10.2 |
| `pdos_truncate(font, s, maxw)` | R:1F4D:04F7 | 10.3 |
| `pdos_wrap(...)` | R:1F4D:0000, 0088 | 10.3 |
| `pdos_tokens(...)` | R:1F4D:0471 | the five `$` tokens, values from the core (rule 4) |

DGROUP:2F98 is read at run time through E's registry (a data-segment word).

### 4.4 The menu box model and its row query (C's B-3)

One pure model serves every DOS menu box: the R re-skins of core MenuZ, list and message boxes
(11.2), and the boxes a C program draws with no core control behind it (the title box in T4,
C.7.1; the T4 setup page, 11.5).

> **C passage condensed for the public copy.** The original record has here a block of 23 lines of C declarations: types `PdosMenuBox`; functions `pdos_menubox_layout`, `pdos_menubox_draw`, `pdos_menubox_select`, `pdos_menubox_row`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* **`pdos_menubox_row`** follows the listing:
  * The item is `trunc((my - y - 4) / h) - first_item`: a signed `idiv` that truncates toward zero
    (R:1D05:018A..019E).
  * The result is -1 when `mx < x` or `mx > right` (R:1D05:01A1..01B2).
  * The result is also -1 when the item is below 0 or at least `nitems`, or the box is in its OK
    form, or DGROUP:D206 is set (R:1D05:0217..0233). The port has no D206 state, so it takes D206
    as 0 (**Open OB10**).
  * `*disabled` reports the item's bit (R:1D05:01BF). The caller keeps the previous row for a
    disabled item, as DOS does.
  * Because the division truncates, points up to `h - 1` pixels above the first item give item 0
    when there are no header lines. Kept, as DOS.
* **Two layout rules of R:1D05:0475 (RV2-11; SCENES 10.1 records both).**
  * **Row height 8 under DGROUP:3936.** After `h` = FontLineHeight with 9 → 8 (R:1D05:0494..04A4),
    `h` is set to 8 whenever DGROUP:3936 ≠ −1 (R:1D05:04A8..04AF). The word is FFFFh in the file;
    the leader and diplomacy overlay sets it to 0, 1 or 2 and back to FFFFh (ovl06.lst, for example
    O6:0762, O6:07BC and O6:183C in the leader routine). The port has no DOS DGROUP, so the state is a
    layout input: the scene that draws the box sets `h8` (D7's leader and diplomacy rows, B 9.1).
    C's title box (T4, C.7.1) and the T4 setup page (11.5) leave it 0.
  * **Row clamp.** The line counter DGROUP:658E is clamped to 0..(192 − y)/h with a signed `idiv`
    through the clamp helper R:1DC4:007C (R:1D05:057D..059A), before `right` (R:1D05:059D..05A7) and
    `bottom` = y + rows · h + 6 (R:1D05:05AA..05B7) are computed. A box low on the screen therefore
    draws fewer lines and is shorter. `pdos_menubox_row` keeps the listing's bounds (`nitems`, x
    against `right`): the clamp limits what is drawn, and `h8` moves the rows the query answers
    through `h`.
* `pdos_menubox_row` is pure: it reads only the box. Area C calls it with frame-1 coordinates (N
  points) for C-drawn boxes. `pdos_r_hit` (11.4) calls it for re-skinned boxes.
* The layout is computed with DOS metrics (E's `pdos_font_advance`, `pdos_font_line_height`), never
  from the core's sizes.

## 5. Palette (`pdos_pal`)

### 5.1 The 6-to-8-bit rule (OPEN P23, settled)

**Choice B1: round to nearest.** `v8 = (v * 255 + 31) / 63` in integers, for 6-bit `v` 0..63.

* Why: the DAC output is linear with full scale 63 (PC fact, PALETTE 1). The nearest 8-bit level
  to `v / 63` of full scale is `round(v * 255 / 63)`. Because 63 is odd, `v * 255 mod 63` is never
  31.5, so there are no ties and `+31` rounds every value correctly.
* Alternatives: floor (`v * 255 / 63`, the D0 viewers' `png.vga6_to_8`); bit replication
  (`(v << 2) | (v >> 4)`). They differ from round in 30 and 10 of the 64 values (OPEN P23).
* One table `uint8_t pdos_v8[64]`, built once. Every conversion uses it: N frame, A elements,
  pointer, the 768-byte table of the 8-bit `tick-NNNNN.bmp` dumps (6.5).
* **Relabel** (OPEN P23): the D0 viewers' floor rendering is a viewer choice. D2 changes
  `gen/dos/png.py vga6_to_8` to this rule so viewer PNGs and presented frames agree (listed in
  20, area E/D2).
* Test: `test_pdos_pal` checks all 64 entries against `floor(v * 255 / 63 + 1/2)` computed in
  exact rationals, and that `|v8 - v * 255 / 63| <= 1/2` for each.
* Recorded in DESIGN (Extension) and FIDELITY as "platform fact (inferred), rounding chosen".

### 5.2 DAC state, loads and splices

> **C passage condensed for the public copy.** The original record has here a block of 5 lines of C declarations: functions `pdos_dac_load_m0`, `pdos_dac_load_raw`, `pdos_dac_copy_range`, `pdos_dac_map_low16`, `pdos_dac_to_rgb8`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* Values stay 6-bit everywhere (E.6); conversion happens only at composition.
* `pdos_dac_load_m0` places a picture's palette with E's `pdos_pal_dac` (G#28's placement,
  E.6.1); a fade target takes E's `m0` as the fade routine does (768 bytes, PALETTE 2.3). The
  `pdos_pal` module's own names are `pdos_dac_*`, `pdos_fade_*`, `pdos_cycle_*`, `pdos_play_*` and
  `pdos_v8`; `pdos_pal_dac` stays E's.
* Every M0 chunk is a full 0..255 palette (PALETTE 5), so a picture load replaces the palette.
* Splice recipes (for example `SP256.PAL` 0..127 with `back<g><a|m>.pal` 128..255, R:0238:1BEB;
  `SLAM1.PAL` with entries 64..143 from `king<NN>.pal`, O9:1228..1242) are small named functions
  in `pdos_pal.c`, one per PALETTE 3 and 5 row, each citing its DOS routine.

### 5.3 Fade arithmetic and cycling slots

* **Fade step** (PALETTE 3, R:0000:04AA/04D4): component = `round((start * (65535 - w) + target *
  w) / 65536)`, computed in 64-bit integers, over all 256 entries. `pdos_fade_step(PdosDac *out,
  const PdosDac *start, const PdosDac *target, uint16_t w)`. The step clock (6 frames per step) and
  the batch size E (OPEN P7) are area C's: C calls the arithmetic with its `w`.
* **Cycling** (R:0000:0382/03FA/042B/044A, PALETTE 4): up to 8 slots of at most 16 entries.

  > **C passage condensed for the public copy.** The original record has here a block of 10 lines of C declarations: types `PdosCycle`; functions `pdos_cycle_setup`, `pdos_cycle_step`, `pdos_cycle_advance`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

  The rate, the countdown and the running flag are C's (`PdosCycleSlot`, C.5.2): B holds the
  colours and the position, C decides when a step happens. A stopped slot keeps its rotated
  colours. Map cycling steps at each core `CyclePaletteColors` event (T7, 5.5).
  `pdos_cycle_advance` is C's shortcut of C.5.4 (n steps applied as n mod count).

### 5.4 Per-scene palettes and interface colours (OPEN P4, settled)

**Settlement.** EGA colour c used by the core's logical layer is DOS index c, drawn into the DOS
surface, and it shows the scene's DAC entry c. This is exactly what the DOS program does
(PALETTE 6: "the interface code uses indices 0..15 ... index n is DAC entry n of the palette in
effect"). No translation table is applied.

* Prompt 5.4 says "verify per scene that the DOS palette's entries 0..15 are the EGA colours".
  PALETTE 6 shows they often are not (LOGO 5, 7, 8, 11, 15; SP256 all but 0, 3, 13; HILL 5..11,
  14). The DOS look is the scene's entry c, so the verification is a recorded report, not a
  correction. **Resolved (decisions X1):** the per-scene report is part of each D4..D7 gate
  record.
* **Test `test_pdos_pal.p4_report`** (needs `--dos-data`): for every palette recipe of 5.2 it
  lists the entries 0..15 that differ from the 16 standard EGA colours and compares the list with
  PALETTE 6's table. A difference fails the test (a fact changed or a recipe is wrong).
* The 16 standard EGA colours in the test are PC-fact constants. MGRAPHIC's default table
  (`DRV_DEFAULT_PALETTE`, G:0000:1410) is not used at run time: after the mode set the screen is
  black (PALETTE 5, first row), so its colours are never visible. **This answers E3: area B does
  not need `MGRAPHIC.EXE`**; E may drop it from the required set and the registry.
* Windows colour bases and the +10 god-palette shift (palette-pictures 2.1, 2.4) never reach a
  DOS surface: Windows pictures are replaced wholesale by DOS pictures with their own M0 palettes
  (8.5). Only Windows colour *indices* used for drawing (text colours, brush colours) need a map;
  8.4 gives it.

### 5.5 The play palette (D's B-4)

* `pdos_ma.dac` holds the play palette. Its life cycle follows SP 1.2 and 0.3:
  1. at the first play state (`WdwMapOpen` 1208:0AF1 exit; A 4.3 gives it the exit phase, RV2-1,
     and the consumer carries A's `OBS_AT_EXIT` marker): `SP257.PIC`'s palette (R:01A8:0867),
     then the three map slots set up (R:1DC4:05DD: 96..103, 104..111, 112..127, direction +1);
  2. after a full-screen scene returns to the map (the core's return path; the DOS counterpart is
     R:0238:1B44): `SP256.PAL` 0..127 with `back<g><a|m>.pal` 128..255 (R:0238:1BEB), slots set up
     again from the new colours. The DOS fade-out and fade-in around it are TX (area C).
* **Map cycling:** each core `CyclePaletteColors` probe (1208:22B7) steps all three slots once
  (PROF E1, T7). So the DOS map cycles every 200 ms of the core's timer, not every 15 DOS frames.
* **Selection of `back<g><a|m>`:** the DOS selection rule of R:0238:1BEB with the core's state
  mapped through the proved court-style correspondence (GetCourtStyle 1160:3487 and O5:1B0F..1B58,
  PROF P11). **Open OB1** (D6): the exact inputs of R:0238:1BEB; resolved by reading it. **Settled in
  D6e** (R:0238:1C11..1C46): the government as GetCourtStyle 1160:3487 selects it (government / 2, toward 0), 'm'
  after advance 14h, government 3 alone '3' without 'm'.
* L11 (entry 45, differing BACK entries) and L12 (cycling over faded entries) stay D6's (OPEN).
* D's layer converts its indices through `pdos_play_rgb8()` (a 768-byte table and a generation
  number); a step damages D's whole clip for reconversion (D 5.5).

**Recorded in D6d (2026-10-16; the D6c review's R3, for D6e).** Item 2: the DOS return path
R:0238:1BEB restarts the slots through R:1DC4:0626 / 03FA without capturing again (the cycling
position is kept), while `pdos_play_back` as designed here captures again and resets to position 0;
D6e keeps the position or records a deviation. L12 is read (D 14.7): the DOS program stops the slots
before both fades of that path and restarts them only after the fade-in, so they never cycle over
faded entries; L11 stays D6e's ([D6d record](../ext-D6d-record.md) "D6cF", "OPEN L12").

**As built in D6e (2026-10-17; [D6e record](../ext-D6e-record.md); DESIGN.md 12.7 "As implemented (D6e; area B)").**
Item 2 is applied at RestoreMapAfterDialog 1208:14D5's entry: `SP256.PAL` with entries 128..255 from the `BACK*.PAL`
file OB1's rule selects (a style without a DOS file, back3m, or a missing file leaves the palette, `pal_none`), only
when that recipe differs from the DAC outside the play slots 60h..7Fh (`pal_same` otherwise), because the core calls
RestoreMapAfterDialog after every dialog and the DOS program R:0238:1BEB only after full-screen scenes (FIDELITY
F191; the TX fades stay D7's). R3: `pdos_play_back` keeps the position, as R:1DC4:0626 / R:0000:03FA (no capture,
direction +, the countdown reloaded), so the next cycle writes the captured colours one step on over the recipe's
96..127; a slot never set up is set up from the new DAC (a guard). L11 is read (OPEN.md): R:0238:1BEB writes no
entry 45, and the differing `BACK*.PAL` entries are applied as 128..255 by the recipe.

## 6. Canvases and composition (`pdos_compose`)

### 6.1 The N canvas

* Page 0 of `pdos_mn`: 320x200 DOS indices, with `pdos_mn.dac`.
* It holds one of:
  * a **scripted N scene** drawn by area C's timeline through B's primitives (credits, intro,
    title, Birth; D4) on pages 0..3 like the DOS code;
  * a **replayed N scene**: page 0 is the shadow of the scene window's client (7.2), drawn by
    logical replay (8) and by the scene's D5/D7 renderer;
  * black (before the first scene, after the mode set).
* **R overlays.** R elements over an N scene (11) are separate small surfaces, each with an
  anchor and a z-order, composed over page 0 at frame time. **Choice B2.** Alternative: draw
  them into page 0 with a save-under as DOS does (R:0238:001E), which breaks when the scene
  underneath is redrawn while the box is open. A frameless DOS box that reads the colour beneath
  (SCENES 10.1: GetPixel(x, y)) reads the composed page 0 at layout time.
* **Damage:** union of page-0 damage and overlay damages; any DAC change damages the whole frame
  (64,000 pixels).

### 6.2 The A canvas

Size: the virtual screen's current size (C4), from `OBS_SCREEN_SIZE` and `w16q_screen`. Layout:
Windows.

| Layer | Source | Palette | Scale |
|---|---|---|---|
| base | the core's frame: the virtual screen converted through the system palette | Windows physical | 1 |
| map client | D's `Wn_dos` (D 6.2) | play | map pixels (DOS art 2x) |
| small map, status window, unit panel (A) | `pdos_play` element surfaces at DOS resolution (12) | play | 2 (the small map: the core's `g_smMapScale`) |
| R elements | `pdos_reskin` surfaces at DOS resolution (11) | the canvas's DOS palette | 2 (the menu bar 1: 11.2) |
| W elements | the base, unchanged | Windows physical | 1 |

* **Base.** The core's XRGB frame is kept by `present.c` for every profile. **Choice B3:** read
  it through `present_core_xrgb()` (A 8.3, A-B5 adopted), the one accessor of the Windows frame
  (it also serves the harness relation check), instead of a private copy. `present_core` updates
  it before any profile's `on_core_present`, so B's base damage reads the new pixels.
  Alternative: a DOS-profile copy, about 17 MB more at 2726x1600 and one more conversion per
  present.
* **Elements.**

  > **C passage condensed for the public copy.** The original record has here a block of 9 lines of C declarations: types `PdosElem`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* A elements are clipped to their window's visible client region (D's `w16q_wnd_client_vis`,
  D A-3). R elements are clipped to the canvas minus the windows above them in z-order, not to
  their own window: a DOS box at 2x can be larger than the Windows dialog (11.3).
* **Palettes before composition** (prompt 5.3): each layer is converted with its own table; the
  result is copied. A palette change re-composes only the layers that use it.
* **Damage:** union of the core's present rectangles where the base shows, element damages
  scaled by k, clip changes (old ∪ new), and the whole of every layer whose palette changed.

**Implemented in D6c (2026-10-16).** The map client layer is D's `Wn_dos`, the A canvas's map
element: compose scale 1 (k 1, at map pixels, the DOS art already at 2x), opaque, `rgb8` NULL (the
play palette), clipped to the client's visible region less the screen exclusions. `PdosElem` gains
`nexcl` and `excl[PDOS_EXCL_MAX]` (12: an open menu's popups and the move or size outline's strips):
canvas pixels inside an exclusion are left to the canvas below; a zeroed element has none
([D6c record](../ext-D6c-record.md); DESIGN.md 12.7 and 12.9 "As implemented (D6c)").

**Since D6f (2026-10-17; [D6f record](../ext-D6f-record.md); DESIGN.md 12.9 "As implemented (D6f; areas B and C)").**
The R elements on A are built (11.2, 11.3): the menu bar, the drop-downs, the MenuZ boxes of dialogs 136 and 145 and
the message boxes. A DOS box lies at its DOS extent, not its Windows window's, so the zoom layer (put into the host view
after the scaled A frame, D6c-6's clip) covered every part of it outside its Windows window at -1 and +1. The layer's
put step now leaves their rectangles out while it draws the DOS profile (`pmap_dos_cover` -> `pdos_reskin_a_rects`,
in host pixels through `present_host_rect`; `pmap_layer.c` `put_open`); the layer's clip from the map client's
visible region, its popup exclusions (D6c-6) and the Windows profile are unchanged (FIDELITY F203).

### 6.3 Which frame is presented

At `frame()` (A 8.1), in order:

1. Nothing has been drawn yet: the N canvas (black).
2. The topmost scene of the stack (9.2) that is not class R is an **N** scene (R elements over
   it stay on the N canvas): the N frame, unless "W over N" (6.4) holds, then the A frame.
3. Otherwise (play, R over A, W, unclassified windows): the A frame.

* The Windows frame is never the DOS profile's frame: `shows_core_frame()` is 0 and the DOS
  profile always presents through the tick (A 8.4).
* A change of kind changes the frame's size; A's tick step 5a (A-B6 adopted) re-lays out, redraws
  the whole client and re-issues the pointer. `input_frame()` (2.1) follows the presented kind, so
  the arrival stage stamps host points with the frame the user sees.

**As built in D7a and D7b (2026-10-17; [D7a record](../ext-D7a-record.md) "The N scene in play over A";
DESIGN.md 12.7 "As implemented (D7a; areas B and C)").** An N scene in play over A: while a report of the DOS
report renderer's table shows, its row (67 for City Status; 68..72 for the advisors since D7b), the frame's row
98 and the picture dialog's row 25 are made ready by the renderer, so rule 2 turns the frame to N (320 x 200)
for the report and back to A at its end. Row 97, which ProcessCity(city, -1) pushes inside City Status and Trade
(a computation without a screen, DOS R:0D12:0045), is held while it runs, so the frame never turns to A inside
the report.

### 6.4 W over N (OPEN P12, settled)

* **The two cases** (PROF 4.1): the MessageBox of ShowErrorMessage 1098:28E4 and of
  _ErrorMessage 1000:4124. Both are `w16`'s `#MsgBox` windows (user_msgbox.c).
* **Choice B4: re-skin every `#MsgBox` as R** (11.2): a DOS menu box with the message lines and
  one row per button, drawn on the N canvas over N scenes and at the Windows position over A.
  Alternative: show the A frame while it is open (prompt 5.3's fallback).
* With B4 no reachable case remains. CheckLowResourcesWarning, Game Help and About open only
  over A frames (PROF 4.1); About stays W (P31).
* **Generic fallback, kept and counted:** any visible top-level window above the N scene window
  that intersects its client and is not an R element of the scene table presents the A frame
  while it is visible; `pdos_diag.w_over_n` counts the cases with the window class and dialog id
  in `presentation-diag.log`. The D4..D7 scenario tests require 0.

### 6.5 Damage, conversion, dumps and hashes

* `frame(&damage)` returns the current frame (N: 320x200; A: the screen size) with the damage since
  the last take; `peek()` returns it without taking damage (A 8.1).
* Conversion: N frame pixel = `rgb8[page0 or overlay index]` as XRGB `0x00RRGGBB`.
* **Dumps** (A 7.3, A-B8 adopted). `--dump-presented` existed only in civ64; A adds it to the
  harness and writes the dumps in both back ends. While the DOS profile is visible its shows are
  TICK or VIEW shows, written as `tick-NNNNN.bmp`. For an N frame the back end asks the profile's
  `indexed` callback, which is `pdos_compose_indexed(&px, &w, &h, rgb768)` (page 0 with the
  overlays and the 768-byte table through `pdos_v8`), and writes an 8-bit BMP. For an A frame
  `indexed` returns 0 and the frame is written 24-bit.
* **Hash** (DESIGN 12.1): SHA-256 of W and H as LE words, then XRGB as B, G, R, X, for both kinds.
* **D-7** ("first stable presented-frame hash at the default zoom, independent of the host
  size"): holds for N frames always. A frames have the virtual screen's size, which follows the
  host under F110, so their D-7 hashes are taken with a fixed game screen (`--game-screen WxH`),
  as K1 scopes P0. Not a new conflict; recorded with D-7.

### 6.6 The 640x480 (screen-size) and 320x200 frames

* Frame changes never resize or move the host window (prompt 5.7, 8). The layout is recomputed
  for the new frame size; the client is redrawn whole.
* The mouse maps into the shown frame (`present_view_point`); `HostEvent.frame` is 1 for the N
  frame and 2 for the A frame (K5), given by the profile's `input_frame` (A 8.1, 10.1). A point
  on the A frame is a virtual-screen point; a point on the N frame is a DOS logical point
  (0..319, 0..199), which area C's I5 adapters convert by the core's own input rule (C.14).
* **Aspect (decisions X3).** The `--aspect` default is 4:3 (A 11: civ64 and the harness), which
  lays out 320x200 frames with pixel aspect 6/5 (scale.h); `--aspect square` and the system-menu
  item remain the player's override, remembered as before. 640x480 and A frames always have square
  pixels. So the DOS start-up screens (N frames) show at 4:3 by default, as the user's direction
  says; the Windows profile is unaffected (it shows no 320x200 frame).
* Test (`test_pdos_compose.switch`): N → A → N while the layout's client stays fixed; the host
  size is unchanged and a fixed client point maps to the right point of each frame.

### 6.7 The pointer (C2..C6, OPEN P21 settled)

A's cursor route (RV1-7, A 8.5) asks the visible profile for the host cursor. Area B supplies it:

> **C passage condensed for the public copy.** The original record has here a block of 8 lines of C declarations: types `PdosCursorImg`; functions `pdos_cursor_current`, `pdos_cursor_update`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

| Windows cursor (WI 5) | DOS pointer |
|---|---|
| 129 normal, 130 small map (C3), 134 Customize help (C7) | the torch: `pdos_shape(PDOS_SH_ICON, 7)` (D4DC, the same pixels as TORCH 0, E.9.2), hot spot (`PDOS_POINTER_HOT_X`, `_Y`) = (0, 0) |
| 133 GoTo (C6) | the GO arrow `pdos_shape(PDOS_SH_ICON, 2)`, hot spot (0, 0) |
| 131 movie and world creation (C4) | hidden |
| 132 busy (C5) | **hidden** (P21: the DOS program hides the pointer while it draws, SP 0.1; it has no busy pointer). **Choice B5**; alternative: keep the torch |
| 136..143 scroll arrows (C9..C16) | **NULL**: no pointer of its own; A's callback returns 0 and the host shows the game's RT_CURSOR (class W; answers A's Open A11) |
| any id, while C's `pdos_seq_pointer_hidden()` is 1 (a DOS intro or Birth timeline is live, C.11.5) | hidden (C's B-4) |

* **Order of the rules:** C's hidden rule first (it overrides every row, NULL included), then the
  id table.
* **Colours:** E delivers palette indices with 0 transparent (E.9.5). B converts them inside the
  DOS profile's cursor callback: the presented canvas's DAC (N: `pdos_mn.dac`; A: the play
  palette) through `pdos_v8`, alpha 255 for every non-zero index. (E.9.5 says "area A converts";
  in A 8.5 that conversion is this callback.) The torch uses 4, 5, 7, 12, 14, 15 (PALETTE 5), so
  its colours change with the scene as on DOS.
* **Scale (A's Choice 26):** the image is at frame scale: the DOS shape at 1x on the N frame and
  2x on the A frame (DOS art at 2x, 6.2); the hot spot likewise. The back end multiplies by its
  `cursor_factors` as for the game's cursor and remakes the cursor when the factors change. So
  the window size, the scaling policy and full screen never change `gen`.
* **`gen`** changes when the cursor id, C's hidden state, the frame kind (1x or 2x), or a DAC entry
  the shape uses changes. `pdos_cursor_update()` checks them after each event and at `advance`; A's
  tick re-issues the cursor when its callback reports `changed` (A 7.2 step 3). Map cycling
  (96..127) never touches the pointer's entries.
* Explicit hide and show during DOS drawing (R:01A8:0250/0268) are not reproduced inside a frame:
  a host cursor needs no hiding to draw under it.

## 7. Shadow surfaces (`pdos_shadow`)

### 7.1 Identity and lifetime

A shadow is the DOS-style counterpart of one emulated drawing surface.

| Surface | Key | Created | Freed |
|---|---|---|---|
| memory bitmap (GrPort bitmaps, tile bitmaps, offscreen ports) | the bitmap handle | `OBS_BITMAP` create, when its first logical draw or copy into it arrives (lazy) | `OBS_BITMAP` delete |
| window client | the window handle | `OBS_WND_CREATE` of a window that 7.2 gives a resolution | `OBS_WND_DESTROY` |

* **Choice B6: key by bitmap and window, not by GrPort address.** Logical drawing reaches a port
  through `g_graf` (1420:9960) and the port's DC; events (A 3.2) name `hdc`, `hbmp` and `screen`.
  Keying by the bitmap makes the movie's 62-byte front/back port swap (graphics.md 4.14, type 9)
  and `g_currentGrPort = g_lastNonMainGrPort` (4.7) transparent. Alternative: key by port
  address, which needs every swap and alias modelled.
* **GR_PortDataToBitmap** (10B8:0E36, E and X, in A's 4.3 list by A-B2) replaces a port's
  bitmap: inside its bracket the shadows of the old bitmap (each rule set) are moved to the new
  handle; a different size calls the owner's `on_resize` (7.5).
* **Lazy creation and claiming.** A shadow is created when the engine first needs one for a
  surface: the destination or source of a drawing event or copy, or a macro's target. Before B's
  own resolution table (7.2) is consulted, the registered owners are asked in registration order
  (`claim`, 7.5); the first that claims it owns it. Lazy claiming lets an owner identify a surface
  by a global the core stores only after `CreateBitmap` returns (D's map port, 12D8:455C).
* **Rule sets.** Each shadow belongs to one rule set: `PDOS_RS_DOS` (every B shadow; D's DOS map
  shadows) or `PDOS_RS_WIN` (D's Windows-rule shadows of its `--mirror 2` oracle, D 9.2). A
  surface can have one shadow per rule set.
* Records: an opaque `PdosShadow` (kind, key, rule set, `PdosSurf`, resolution and `k`, device
  size, owner, owner context) in a hash table of at most 256 shadows; overflow counts
  `pdos_diag.shadow_full` and the surface stays unshadowed (its draws are unexplained).

  > **C passage condensed for the public copy.** The original record has here a block of 8 lines of C declarations: types `PdosShadow`; functions `pdos_shadow_find`, `pdos_shadow_surf`, `pdos_shadow_port`, `pdos_shadow_rule_set`, `pdos_shadow_ctx`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

**Implemented in D6a (2026-10-16).** GR_PortDataToBitmap's rebind: between its entry and exit the
engine keeps the port's hdc (+0x18) and old bitmap (+0x1A) read at the entry; the old bitmap's
delete (10B8:113F) rebinds its shadows to the DC's current bitmap instead of freeing them
(`pdos_shadow_rebinds`); any other delete frees as before. S8 (D4a second review) done:
`pdos_shadow_rebind` takes the new bitmap's device size when its create gave one; a different size
reallocates the shadow black and calls the owner's `on_resize`; open brackets on the old handle
follow it, brackets on the new handle are detached and counted ([D6a record](../ext-D6a-record.md)).

### 7.2 Resolution

| Surface | Resolution | Size |
|---|---|---|
| dialogs 130, 142, 143, 144, 146, 147, 148, 149, 151 (WI 4.2) and memory bitmaps that logical drawing reaches in N scenes (report, city, palace, newspaper, spaceship ports) | **logical**: one DOS pixel per logical pixel; device to logical by 8.3 | `ceil(dev * 10 / 16)` |
| the map port `P`, scratch `S`, map client `Wn` | map pixels with DOS art at 2x; claimed by D's hooks (7.5) | device |
| status back port 12D8:4580 and the Status window client; the small-map client | DOS resolution of the A element (12) | `ceil(dev / 2)` |
| anything else | none: drawn as W | – |

* The N canvas is the shadow of the current N scene window's client: for a 512x320 client the
  logical shadow is exactly 320x200 and **is** page 0 of `pdos_mn` (no copy). A smaller client sits
  at its logical position inside page 0; a larger one is clipped (counted).
* Which window is the scene window: the window that GR_DialogOpen creates at the scene row's call
  site (A's `OBS_CALLSITES`), else the topmost visible window of the logical-layer templates above.

**Open for D5 (D4a second review S4).** D4a decides once, when a window's shadow is created,
whether it is page 0, so two nested N windows both alias page 0, a window that becomes the N
window later keeps a private surface, and a smaller client is not placed at its logical position.
D5 must replace this binding: at most one shadow attached to page 0, detached and attached on each
change of the N window ([D4a record](../ext-D4a-record.md#second-review-2026-10-12) S4).

### 7.3 Brackets: macros and primitives

A **bracket** is the time between a probe's entry and exit. Inside it, the core's own drawing
events for what the bracketed function draws are not replayed: the macro draws the DOS version
itself, either from state at entry (D's map macros) or from what the core did, at exit (B's
logical replay). This is the one engine of decision C5; D's proposed `PsMacro` and
`ps_register_macros` (D 9.4) are this `PdosMacro` and `pdos_shadow_macros`.

> **C passage condensed for the public copy.** The original record has here a block of 34 lines of C declarations: types `PdosBracket`, `PdosMacro`; functions `pdos_shadow_macros`, `pdos_shadow_context`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* **Opening.** At a probe's entry the engine finds the macros of that key whose `ra` matches. For
  each, `target` names the surface (or 0: no bracket). `enter` is called once per rule set in
  `rule_sets` for which the target has (or now gets, 7.1) a shadow; with a `target` of NULL,
  `enter` gets `dst` NULL and the target is fixed by the first suppressed event.
* **Dropping (D's rule).** While a `PDOS_MAC_DROP` bracket is open on a target, the core's drawing
  events whose destination is that surface are dropped and recorded in its `PdosBracket`. Copies
  from it to another surface (the flushes to the window, `CopyPortToWindow`, `DrawShapeAndFlush`
  with `g_autoFlushToWindow`) are applied (7.4). So the **content** (whether and where something
  was drawn) is the core's, the **presentation** is DOS (8.1).
* **Ownership when nesting.** The outermost open `DROP` bracket on a surface owns it. An inner
  bracket on the same surface records its events, but its `enter` and `leave` are not called
  (muted). So a macro that draws from state is not drawn over by B's replay of the primitives it
  calls, for example a logical fill inside a map macro. Brackets on other surfaces are
  independent. **Choice B20**; alternative: innermost wins (the outer macro would have to undo
  inner drawing).
* **Contexts.** A `PDOS_MAC_CONTEXT` bracket drops nothing. Its saved entry probe is readable with
  `pdos_shadow_context` while it is open: D's `DrawTile` macro asks whether `AnimateUnitMove` or
  `ResolveCombat` is open, and with which arguments (D 9.3).
* **Exit.** `leave` is called per rule set, then the bracket closes. A probe exit without an open
  bracket (a probe added mid-run cannot happen: the table is fixed, A 4.1) is counted.
* **Every macro key has an exit probe (RV2-1).** A bracket closes only at its key's exit, so every
  `PdosMacro.key` must have the X phase in A's `OBS_PROBES[]`. A 4.3 gives it to the nine functions
  WI lists entry only (DrawMapTile, DrawUnitAt, DrawCityLabels, WdwMapOpen, RedrawSmMap, DrawSmTiles,
  RedrawStatusWindow, DrawStatusCivPanels, DrawUnitInfoPanel). A's obs_lint checks it at build time
  (A 6.2 "exit phases"), and `pdos_shadow_macros` refuses and counts a macro without it.
* **Registration.** Leaf primitives (8.2) are registered by `pdos_replay`. B's status and
  small-map macros (12) are registered by `pdos_play`, the scene-level macros by the D5..D7
  renderers, and D's map macros by `pmap_model` (owner `"pmap"`, from `pmap_reset`). Each module
  registers its static table when it is reset (`obs_init`, `hh_run`), in any order.
  `pdos_shadow_reset` clears the shadows and open brackets but keeps the registrations; a second
  registration by the same owner replaces its table.

**As implemented (D4a).**

* `PdosMacro.key` and the key of `pdos_shadow_context` are `OBS_P_*` probe row numbers
  (`uint16_t`), not `uint32_t` function starts; `PDOS_NO_KEY` (0xFFFF) is the absent key
  ([D4a record](../ext-D4a-record.md#deviations) Deviations 1, 7).
* `PdosBracket.changed` holds the target's DC coordinates (client for a window, bitmap for a
  bitmap), unclipped: the union of `ObsDraw.rect`, never `ObsDraw.changed`
  ([D4a record](../ext-D4a-record.md#second-review-2026-10-12) S2).

**Open for D4b2 (D4a second review S3).** A copy from a DROP target (a flush to the window) is
applied when its BITBLT arrives, so inside a bracket whose macro draws at `leave` (8.2) the flush
comes before `leave` has drawn the DOS version. D4b2 must resolve this before the first macro with
a drawing `leave` is registered: (a) queue such copies in the bracket and apply them after
`leave`, or (b) state that 8.2's leave-drawers redo their own function's flushes
([D4a record](../ext-D4a-record.md#second-review-2026-10-12) S3).

**Implemented in D6b (2026-10-16).** S3 resolved by option (a), as an opt-in flag of the macro,
`PDOS_MAC_LEAVE_DRAWS` (only with `PDOS_MAC_DROP`, else `macro_config`): while such a bracket owns its
target, a copy from the target (DrawShapeAndFlush's flush, CopyPortToWindow) is queued in the bracket
for the macro's rule sets (at most 8, `PDOS_S3_QUEUE`; a further one is applied at once and counted)
and applied in arrival order after the leave, also when the bracket closes without its leave; it is
dropped and counted when the bracket was detached (S7) or closed by a registration (S9)
(`s3_deferred`, `s3_full`, `s3_dropped`). Only the replay's 16 macros set the flag, so D's map macros
(whose DOS leave draws nothing before D6c) keep their copy timing. `PdosBracket.text_rgb` keeps the
DC's text colour of its last TEXTOUT / DRAWTEXT (TextBoxDraw's colour). The D4a second review's S3 is
closed ([D6b record](../ext-D6b-record.md); DESIGN.md 12.7 "As implemented (D6b; area B)").

### 7.4 Copies between shadows

| Event | Replay |
|---|---|
| `OBS_DRAW` BITBLT SRCCOPY between two shadowed surfaces (CopyPortBits 10D0:03FA, CopyPortToWindow 10D0:0854, BlitDCRect 10D0:08F1, WM_PAINT blits) | copy the mapped source rectangle into the mapped destination; if the resolutions differ, nearest by the destination's mapping (counted `res_mismatch`, expected 0) |
| BITBLT from an unshadowed source into a shadow | unexplained (7.6) unless the source has a provenance rule (8.5) |
| BITBLT with other ROPs (Superimpose SRCINVERT/SRCAND, DrawTile's mask path) inside a bracket | suppressed (the bracket draws) |
| the same outside a bracket | unexplained |
| `OBS_BITMAP` bits (raw buffer to bitmap: palace, leader, city view) | the port's scene renderer (D7) through its macros; otherwise unexplained |

Device rectangles map to a logical shadow with 8.3; to a 2x A element with `floor(x / 2)`,
`ceil(r / 2)`; to a map-pixel shadow unchanged.

* A shadow copy mirrors `BitBlt`, not G#20: a copy within one surface (the scroll functions'
  `BlitDCRect` on the map window, D 9.4) is overlap-safe, as the core's own blit is.
* An owner's `on_copy` (7.5) is asked first for any copy that touches a shadow it owns; 0 lets
  the engine apply the rule above.

**Implemented in D6a (2026-10-16).** The owner of both shadows of a copy is asked once; a copy
makes its destination bitmap's logical shadow only when the source shadow is logical (a map
shadow's copy into DrawTile's buffer makes none); `OBS_BMP_DAMAGE` alone is no longer unexplained
(it precedes the same drawing's `OBS_DRAW`, which is judged), raw bits (`OBS_BMP_BITS`) still are
([D6a record](../ext-D6a-record.md) deviation "B 7.4/7.5").

### 7.5 Handler hooks for the map model (C5, D's B-1)

**The final interface (decision C5, D's B-1 and 9.4).** One engine owns the shadow table and the
bracket stack; D's map model registers an owner with hooks and a macro table and keeps no shadows
of its own.

> **C passage condensed for the public copy.** The original record has here a block of 26 lines of C declarations: types `PdosShadowRes`, `PdosShadowHooks`; functions `pdos_shadow_hooks`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* **D's 9.4 table in this engine.**

  | D's event | Engine path |
  |---|---|
  | BITBLT `P` or `S` → `Wn` (flush, WM_PAINT, nuclear frames) | copy rule 7.4 (or D's `on_copy`); applied also inside D's DROP brackets |
  | BITBLT `Wn` → `Wn` (`BlitDCRect` scroll) | overlap-safe copy within the shadow (7.4) |
  | `CopyPortBits` between `P` and `S`, or `P` → `P` | copy rule 7.4 |
  | FILLRECT to `P` or `Wn` outside a macro | D's `on_draw` (BLACK_BRUSH: the rule set's black) |
  | other drawing to `P`, `S`, `Wn` outside D's macros | inside a B replay bracket (a logical primitive of kind 2): B's `leave` draws the DOS primitive at the map rule's position (8.3) on the DOS shadow; the Windows shadow gets nothing from B and goes to D's `on_draw` (D's `w16q_draw_on` replay); otherwise `on_draw`, and if 0 the event is unexplained (D's `map_unexplained`, B's `unexplained`) |
  | `OBS_BITMAP` create or delete of the port bitmaps (`ResizeMapWindow`) | delete: `on_free`; the new bitmap is claimed lazily at its first use and starts black (7.1) |
  | the map window's client resized | `on_resize` |

* **Rule sets.** B's own macros and shadows are DOS only. A Windows-rule shadow is drawn only by
  its owner (D's macros with the WIN bit, `on_draw`, `on_copy`), so B's replay never touches it.
  The engine gives each `enter`, `leave` and hook the rule set of the shadow concerned, so D's one
  macro table serves both sets (D 9.4).
* **Choice B19: the engine runs inside the DOS profile.** `pdos_profile` feeds it (2.1), so it
  exists when the DOS profile is registered. The Windows rule set therefore needs the DOS profile:
  D's `--mirror 2` runs pass `--dos-data` (as D's D6 runs already do, RV1-5), and without it
  `--mirror 2` is refused with E's message. Alternative: `observe.c` feeds the engine
  independently of the profiles (one more consumer with its own call-order cases).
* **Order.** In a callback the engine runs after the scene stack and C (2.1). `pmap_on_event` and
  `pmap_on_probe` (D 3) run after every profile (A 3.1), so D's own snapshot code sees an event
  after its handlers in the engine have. D's handlers must not depend on its later callback for
  the same event.
* The A canvas's map client region is D's `Wn_dos` (D's B-2): `pdos_compose` takes it as the map
  element with compose scale 1 (it is already at map pixels).
  *(Implemented in D6c, 2026-10-16: `pmap_dos_present` sets it at every core present after the map
  window is read, with the play palette and the client's visible region less the screen
  exclusions; removed when the window is hidden, iconic, empty or has no visible region, past
  `PDOS_CLIP_MAX` rectangles and before its surface is freed; [D6c record](../ext-D6c-record.md).)*

**As implemented (D4a).** A DROP bracket drops an event only for its own rule sets. The other
rule sets' shadows on the target still get it (the copy rule, the owner's `on_draw` or the
unexplained count), and a DROP macro with no rule set is refused as `macro_config`
([D4a record](../ext-D4a-record.md#second-review-2026-10-12) S5).

**Implemented in D6a (2026-10-16).** D's owner "pmap" registers the table above (DESIGN.md 12.9 "As
implemented (D6a; area D)"); the engine keeps the unexplained count per rule set
(`pdos_shadow_unexplained_rs`, `PdosUnexplained.rule_set`) and adds `pdos_shadow_dropping`; S8 is
done (7.1); `--mirror 2` needs `--dos-data` (B19) ([D6a record](../ext-D6a-record.md)).

**Since D7a and D7b (2026-10-17; DESIGN.md 12.7 "As implemented (D7a; areas B and C)" and "(D7b; areas B and
C)").** The DOS report renderer registers the fifth owner, "report" (`PDOS_OWNER_MAX` 6): the report window
(dialog 148) and the report port's bitmap at the logical resolution, filled in the DOS background, with the
replay drawing the core's texts into the port's shadow. D7b adds the negative claim: a `claim` below 0 makes no
shadow for that surface, neither a later owner's nor the engine's own, and is asked again at the next get. The
report declines the bitmaps DrawTileImpl makes inside a DrawTile on the report port, whose raw bits
(SetBitmapBits) no DROP bracket can hold (DrawTile is an entry-only probe); existing owners return 0 or 1 and
are unaffected.

### 7.6 Unexplained events

* An event to a shadow that no bracket, hook or copy rule explains changes nothing in the shadow;
  `pdos_diag.unexplained` counts it with the destination, operation, rectangle and the innermost
  open probe.
* **Choice B7: no pasting.** The Windows pixels are never converted into a DOS surface.
  Alternative: nearest-colour paste of the Windows pixels, rejected by prompt 5.3 ("never pasted
  in from the virtual screen"; "everything on it is drawn in the DOS style").
* The D4..D7 scenario tests require `unexplained == 0` for every covered scene; the log names
  what is missing.

## 8. Logical replay (`pdos_replay`)

### 8.1 The rule: content from the core, presentation from DOS

* Prompt 5.4: replay the logical-layer events at 1x; follow the DOS program for presentation
  (layout, colours, decorations) and the core for content.
* Each logical primitive is a bracket (7.3). At entry its arguments are read (logical
  coordinates, EGA colour, text pointer, shape handle) together with the target kind. At exit
  the DOS primitive is drawn into the shadow of the destination the core's events used, only if
  the core drew something (`nevents > 0`).
* So Windows quirks that change *whether* something is drawn are followed (the y-swap bug of
  DrawAxisAlignedLine, graphics.md 6.1; kind 0 points; diagonal lines that Windows skips). Quirks
  that change only *how* (the 511 clamp of FillRectLogical) are not.

**Target kind.** Computed at entry from the same globals MapLogicalPointToPort 1220:0F2F reads:
`g_currentDialogPort` 1420:9948, `g_cityTileDrawMode` 1260:002C, the point, `g_mapScrollX/Y`
1408:00C6/00C4. **Choice B8:** compute, do not probe 1220:0F2F. Alternative: an exit probe on
MapLogicalPointToPort per primitive (nine sites, more probe traffic). Test: a Checked-only harness
check compares the computed kind with 1220:0F2F's result in one scenario per screen family.

**Implemented in D6b (2026-10-16).** The owner "replay" registers 16 DROP macros on 8.2's
primitives (the DOS rule set, any call site). Gating (the record's deviation from "every logical
primitive of every scene"): nothing is replayed while a scripted row (`PDOS_RD_SCRIPT`: intro, title,
Birth, setup, names, Customize) is on the scene stack, also under a ready replay row above it; a
logical shadow is drawn, and made lazily, only while the topmost non-R row is an N row whose replay
renderer is ready (D7's renderers set it); kinds 1 and 2 are drawn only into shadows that exist or
that their owner claims (`scripted`, `no_shadow`, `no_scene`). A replay primitive inside another DROP
bracket on the same surface is muted by the engine (7.3's ownership, B20) and draws nothing (`muted`):
inside D's DrawMapTile, DrawUnit, DrawUnitAt and DrawCityLabels the DOS rule set is D's (D6c). Choice
B8 as designed: the check compares the computed kind and point with MapLogicalPointToPort's own at its
exit inside every frame of a primitive that calls it, a superset of one scenario per screen family
(`ext_replay.py`: `kind_mismatch 0` and `point_mismatch 0` in every V1 run, kinds 1, 2 and 3 each
checked) ([D6b record](../ext-D6b-record.md); DESIGN.md 12.7 "As implemented (D6b; area B)").

### 8.2 Per-primitive table

| Probe (A's list, E and X) | DOS drawing at exit | Notes |
|---|---|---|
| FillRectLogical 11E8:0504 (port, x, y, w, h, c) | `pdos_fill_rect(x, y, w, h, c)` | no 511 clamp (a Windows device detail) |
| FrameRectLogical 1220:1086 (x, y, w, h, c) | the frame of `[x, x + w) x [y, y + h)`: `pdos_outline(x, y, w - 1, h - 1, c)` | |
| FrameRectDoubleDevice 1220:114B (x, y, w, h device, c) | two outlines at the 8.3 mapping of the device rectangle and its inset | spaceship only |
| DrawScreenLine 10D8:0000 (x1, y1, x2, y2, c) | `pdos_line` | only when the core drew (8.1) |
| DrawScreenText 10D8:01B0 (text, x, y, c) | R:0182:002A model at (x, y) with the port's style | font: 10.1 |
| DrawShadowedScreenText 10D8:01FA | R:0182:0086: colour 0 at (x, y + 1), then c at (x, y) | DOS shadow below only (CORR 13) |
| DrawScreenTextWithShadow 10D8:02DF (…, shadowC) | as above with the shadow in `shadowC` | |
| DrawCenteredScreenText 10D8:0528 (text, cx, y, c) | R:0182:00B3: `x = cx - (W / 2)`, W = R:0182:00EF width (sum of G#4 advances, trailing spacing included), transparent | listing R:0182:00B3..00EE. R:0182:00B3 sets the port's style word +0Ah to 0 for the draw and to 1 afterwards, whatever it was (R:0182:00C8..00E8; RV2-16): a `PdosPort` that keeps its style across calls (11, D7 scenes) is left opaque (style 1) after this primitive |
| DrawCenteredShadowedScreenText 10D8:046E, DrawCenteredScreenTextWithShadow 10D8:0495 | centred as above, shadow as above | |
| GetScreenTextWidth 10D8:05B8 (exit) | none: the core's layout result is content | the DOS width is used only where B lays out (10.3) |
| DrawShapeAndFlush 11E8:0674 (port, x, y, hShape) | the provenance shape (8.5) with G#6 at (x, y) | kind 2: muted inside D's macros (7.3); elsewhere drawn on D's DOS map shadow at the map rule (8.3) |
| FlushSquareToWindow 11E8:07C3 | copy only (7.4) | |
| DrawMapSprite 11C8:008A (index, x, y) | `g_mapSprites[index]` provenance: `pdos_shape(PDOS_SH_ICON, index)` (D4CE[index]) at (x, y) | |
| DrawImprovementIconLogical 1030:84BE (id, x, y) | page-2 icon `[5c + r]` (PROF S18) at (x, y) | |
| DrawBeveledLabelBox 1030:8C11 (x1, y1, x2, y2, label, c) | fill, bevel and centred label with the Windows colour rule taken as DOS indices | **Open OB2** (D7): the DOS counterpart's drawing at O14. **Settled in D7b** (2026-10-17): R:0D12:71BF (O14:0FBE..0FE3), the same geometry in the DOS colours of c = [1946h + 2 civ]: fill c, top and left lines c < 8 ? c + 8 : 7, bottom and right lines c < 8 ? 8 : c - 8, the centred label c ^ 8 |
| ExtractScaledTile 1160:33FC (exit) | provenance only (8.5) | |
| ScaleLogicalX/Y 11E8:0D81/0DA8 (entry) | none; records `(v, ScaleLogical(v))` pairs for 8.3 | B computes `ScaleLogical(v) = (int16_t)((long)v * 160 / 100)` itself (graphics.md 4.7, a pure function of the entry argument). The cast matches the core, which returns the 16-bit AX after `idiv` (showfunc 11E8:0D81; RV2-15); without it the two can differ for \|v\| > 20,479. So the exit probe A added (A 4.3) is not needed by B; A may drop it |
| DrawTextAtPortXY 10D8:00E0 (text, x, y, c), device coordinates | R:0182:002A model at the 8.3 mapping of (x, y) | |
| DrawTextInRect 1098:0ED1 (text, rect, flags, colorIndex) | text in the mapped rectangle: flags & 0xF alignment (1 centre, 2 left, 3 right), 0x10 shadow in colour + 1, 0x20 black shadow, each as a DOS one-pixel shadow below | vertical rule: **Open OB3** (D4): read DrawTextInRect's vertical placement (graphics/text docs, showfunc 1098:0ED1) |
| TextBoxSetup 1068:2072 (E, X), TextBoxDraw 1068:258F, TextBoxDrawAndClose 1068:255A | the text wrapped by R:1F4D:0000/0088 in the mapped box, justification from the argument | the handle ties setup to draw |
| TruncateStringToLogicalWidth 11D0:02E4 (E, X) | none at once: the original string and width are kept by buffer address; the next draw of that buffer uses `pdos_truncate` on the original (10.3) | |

Movie text items are not replayed: the intro and Birth are scripted N scenes (D4), About is W.

**Open for D4b2.** A flush made inside one of these brackets copies the target before this
table's `leave` has drawn on it; see the S3 item at the end of 7.3.

**Implemented in D6b (2026-10-16).** The flush above is settled by 7.3's option (a). FlushSquareToWindow
11E8:07C3 is a frame only (a copy), kept for the kind check. DrawImprovementIconLogical's kind is
"scaled" (ScaleLogical without the MapLogicalPointToPort call, 1030:84E1); DrawTextAtPortXY,
DrawTextInRect and TextBoxDraw are device primitives (kind "device"). Replayed text is transparent:
the core draws its report and play text with a TRANSPARENT background (OpenReportScreenWithHeader
1018:0130, ShowCivilizationScore 1040:1172), so a replayed text cell paints no background; a scene
whose DOS text is opaque gets that from its D7 renderer (inferred). Fonts (10.1): logical text by the
font map at its call site, asked only once a target is decided (`font_unmapped` counts drawn text
only); device text and shapes by the DOS font last set on the graf, font 1 when none is known
(inferred) ([D6b record](../ext-D6b-record.md); DESIGN.md 12.7 "As implemented (D6b; area B)").

### 8.3 Coordinates

* Kind 3 (dialog) without city mode: logical (x, y) are DOS coordinates in the logical shadow.
* Kind 2: the map rule `((x - 200) * 2 - scrollX, (y - 8) * 2 - scrollY)` into D's map shadows
  (D owns them), through a port with `k = 2` whose origin is the transformed point (3).
* Kind 3 with `g_cityTileDrawMode` (the city screen's map squares): the core applies the map rule
  but draws into the dialog's port. The DOS view draws DOS squares (D's square renderer) at their
  logical positions in the dialog's logical shadow (prompt 5.4). **Open OB9** (D7): the DOS city
  screen's square positions (R:0D12) against the core's transformed points.
* Kind 1 (status window): unscaled device coordinates into the status element's DOS surface at
  `floor(x / 2)`, `floor(y / 2)`.
* **Device to logical** (DrawTextAtPortXY, DrawTextInRect rectangles, device events): logical
  pixel L covers device `[floor(16L / 10), floor(16(L + 1) / 10))` (ScaleLogical truncates,
  graphics.md 4.7). The logical pixel of device d is `L(d) = floor((10d + 9) / 16)` (floor
  division; a negative d occurs only for points the core clips); a device rectangle `[l, r)` maps
  to `[L(l), L(r - 1) + 1)`. **Choice B9.** Alternative: `floor(d * 10 / 16)`, which maps
  `ScaleLogical(1) = 1` back to 0.
* **Exact preimages first.** When a device value equals a `ScaleLogical(v)` recorded within the
  current bracket or its caller's (ScaleLogicalX/Y probes, 8.2), v is used.
* Test (`test_pdos_replay.coords`): `L(ScaleLogical(L)) == L` for L in 0..639 (for negative L
  ScaleLogical rounds toward zero and the identity does not hold, for example L = -3; such points
  are outside every port and the core clips them); the rectangle rule covers every device pixel of
  a logical rectangle exactly once.

**Implemented in D6b (2026-10-16).** MAP (k 2): the kind's device point goes through a k = 2 port
whose origin carries the point's parity, so DOS 2 x 2 pixels start at the device pixel (both
parities, odd and even scrolls); HALF: floor(d / 2), the right and bottom edges rounded up;
LOGICAL: kind 3 and the scaled icon at their logical point, device values through an exact preimage
first (`preimages`), else L(d) ([D6b record](../ext-D6b-record.md); DESIGN.md 12.7 "As implemented (D6b; area B)").

### 8.4 Colours in replay

| Source of the colour | DOS index |
|---|---|
| an EGA colour argument (logical primitives, DrawTextAtPortXY's egaColor) | c itself (5.4) |
| a system index equal to `g_egaToSystemColor[c]` (12D8:45BE: 0..7, F8h..FFh) in a device event or brush | c (the inverse of the fixed table, palette-pictures 4.9) |
| a Windows game index (god + 10) given to DrawTextInRect, movie text, brush indices | the scene row's colour table (9.1 `colours`), for example Birth text 3 then 11, credits 248/250/252 (PROF E5) |
| none of these | nearest colour of the Windows RGB in the current DOS DAC (squared distance, lowest index on ties); `pdos_diag.colour_nearest` counts it; the D4..D7 tests require 0 for covered scenes |

**Implemented in D6b (2026-10-16).** The nearest colour (the last row) is taken in the DAC the shadow
is shown with: the N machine's for a logical shadow, the A machine's (the play palette) for map and
half shadows; TextBoxDraw's COLORREF is PALETTEINDEX by the same rules, or its RGB's nearest;
`colour_nearest` is the `pdos` line's field of `presentation-diag.log` ([D6b record](../ext-D6b-record.md); DESIGN.md 12.7 "As implemented (D6b; area B)").

### 8.5 Shapes and pictures by provenance (`pdos_prov`)

* **Sheet shapes.** At the exit of ExtractGameSpriteShapes 10E8:231F, `pdos_prov` reads the
  handle tables once (`g_mapSprites` 1420:9350, `g_terrainShapes` 1420:972E, `g_coastShapes`
  1420:95E2, `g_roadRailShapes` 1420:96EC, `g_riverShapes` 1420:96AC, `g_miniPalaceShapes`
  1420:9632, `g_unexploredEdgeShapes` 1420:962A, `g_cityIconShapes` 1420:933A, `g_citizenShapes`
  1420:95D0, `g_grasslandShieldShape` 1420:96AA, `g_improvementIcons` 1420:98F4,
  `g_statusIconShapes` 1420:98E4, `g_wholeTileShapes` 1420:98AE, `g_windowFrameShapes`
  1420:98C4) and maps each handle to a DOS counterpart by PROF 2.2 rows S1..S23: either a
  `(family, index)` of E's `pdos_shapes` (RV1-1, E.9.2; for example `g_mapSprites[i]` →
  `PDOS_SH_ICON, i`), or a page-2 rectangle of `pdos_ma` (the SP299 page-2 art that E does not cut,
  E.9.2: whole-square coasts, building icons, bulbs, border tiles, textures; S18..S23), drawn with
  `pdos_copy_rect` or as a sprite by the scene's rule. Unit copies `g_mapSprites[64 + 32c + j]` map
  to `pdos_shape(PDOS_SH_ICON, 64 + 32c + j)`, E's civ-c copy of unit j (recoloured per SPRITES
  6.4), cut at DOS's own rectangle (P11, section 13; E.9.3 row 22).
* **Other cut shapes.** TileExtract 11A8:05C7 and ExtractScaledTile exits give (handle, source
  port, rectangle); GR_PicRead 10B8:079D entries give (port, picture id). A rule table maps
  `(picture id, rectangle)` to a DOS picture and rectangle:

  > **C passage condensed for the public copy.** The original record has here a block of 2 lines of C declarations: functions `pdos_prov_rule`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

  The rules are the PROF 2.3 rows T1..T20, written by the D5..D7 scene renderers (cell grids are
  explicit, not a uniform 1.6 scale: for example `CITYPIX2/3` cells (50(i div 4) + 1, ...) against
  Windows (80(i/4) + 1, ...)).
* **Whole pictures.** A picture shown whole in an N scene (the 2.1 rows P5..P38) is drawn as the
  DOS picture at the DOS position with its M0 palette (prompt 5.4); the scene renderer names the
  position and palette recipe (9.1).
* A recoloured shape (ReplaceTileColor 11A8:022F) keeps its provenance; the DOS recolouring of
  the counterpart is the DOS rule (SPRITES 6.4), not the Windows key colours.
* Handles are recycled by w16 (STATUS "selector and handle reuse"): a TileDispose (or the
  bitmap delete) removes the entry; a new cut overwrites it.
* An unknown handle drawn in a bracket: nothing drawn, `pdos_diag.prov_unknown` counted.

**Implemented in D6b (2026-10-16).** `PdosProvFn` takes `const PresentRect *` (the presentation's
rectangle: the same l, t, r, b words read at TileExtract's entry, the device rectangle of the cut)
instead of `const W16Rect *`. ExtractScaledTile 1160:33FC returns TileExtract's handle (1160:3469),
so TileExtract's entry and exit alone cover it and ExtractPictureTile2x (its DOS-coordinate arguments
are left to the D7 rules). The two-table rule: a handle in two tables takes the last row that names
one; a table entry no row names removes only a cut's entry left under a recycled handle. TileDispose
11A8:00D1 has no probe (A's list), so a disposed handle keeps its entry until a new cut or a sheet read
reuses the handle (handles are HGLOBALs; the core never draws a disposed handle; a probe on TileDispose
would make it exact). PROF 2.2 gives no size for S19..S22: S19 takes S18's 18 x 10, S20 8 x 8, S21
and S22 16 x 16 (their pitches; inferred), all in page 2's resident SP299 art (DOS-PROFILE.md 2.2)
([D6b record](../ext-D6b-record.md); DESIGN.md 12.7 "As implemented (D6b; area B)").

### 8.6 Pixels read as data (prompt 8)

* The core always loads and reads its Windows pictures (PROF 0.5). Area B substitutes only in
  its own surfaces; emulated memory is never changed.
* Positions the core derives from Windows pixels are content and are taken from the core's
  events: GetTileOpaqueBounds 11A8:00FE results (DrawUnitAt 1110:11CC, ShowPediaEntry), the
  starfield (GetPortPixelIndex 1070:127A: the core's SETPIXEL positions; DOS star colours), the
  key colours of row 399, picture 200 entries 1..64 for InitGameColorTables, the leader's first
  pixel, the shape top-left key. The DOS shape is drawn at the core's position; where the DOS
  art's own opaque bounds differ, the offset is recorded, not corrected.
* Picture 137 (EARTH) is never drawn in either profile.
* `g_lpScreenBuffer` 1420:B394 is game state: D's snapshot and B's small map read it through
  `w16q_read` (12.2).

**Implemented in D6b (2026-10-16).** Picture 137 (EARTH) is never mapped by the provenance
(`pdos_prov`) ([D6b record](../ext-D6b-record.md); DESIGN.md 12.7 "As implemented (D6b; area B)").

## 9. Scenes at run time (`pdos_scene`)

### 9.1 The scene table in code

> **C passage condensed for the public copy.** The original record has here a block of 17 lines of C declarations: types `PdosSceneRow`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* **Choice B10:** a hand-written table checked against `DOS-PROFILE.md` by
  `tests/harness/pdos_scene_check.py` (rows, classes, probe keys, call sites, adapters), as A's
  `obs_lint.py` checks the probe list. Alternative: generate the C file from the Markdown,
  which ties the build to the document's table syntax.

**As implemented (D4a).** The row's `entry` and `exit` keys are `OBS_P_*` probe row numbers
(`uint16_t`), not `uint32_t` function starts, because a static initialiser cannot read
`OBS_PROBES[]`; `PDOS_NO_KEY` (0xFFFF) is the absent key, since row 0 is a real probe
([D4a record](../ext-D4a-record.md#deviations) Deviation 1).

### 9.2 The scene stack

* An entry probe that matches a row (key and `ra`) pushes the row; the matching exit pops it
  (and everything pushed above it, which a correct core never leaves). Window-bound rows (`dlg`)
  also pop when their window is destroyed.
* **Pop after the bracket's `leave` (RV2-12).** At an exit probe the profile runs the shadow
  engine before the scene stack (2.1), so a `leave` that reads the top row (its `colours`, `pal`,
  `renderer`; 8.4, 9.1) sees the row of the function that is returning, not its parent. At an
  entry the push still comes first, so `enter` sees the new row. This is nesting order: the scene
  of a function opens before its bracket and closes after it.
* At most 16 levels; deeper pushes are counted and ignored.
* The top decides the frame kind (6.3); area C reads the stack for timelines and adapters:

  > **C passage condensed for the public copy.** The original record has here a block of 4 lines of C declarations: functions `pdos_scene_top`, `pdos_scene_depth`, `pdos_scene_at`, `pdos_scene_listen`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* **Area C's use (C's B-7).** `pdos_seq` registers one listener and reads the top row's
  `renderer`, `timeline` and `adapter` fields. C writes no row. A listener runs inside
  `pdos_scene_on_event`/`_on_probe`, before C's own `pdos_seq_on_*` call for the same event
  (2.1), with the event's virtual time.
* Unclassified windows (no row) are W: they show on the A frame and, over N, count as 6.4's
  fallback.

**As implemented (D4a).**

* One probe can end several rows: the return of BeginWorldCreation ends row 5 (a configured exit)
  and row 3 (its own), so the scan continues below a popped slot; a return pairs with one entry
  only, so a recursive entry pops one level per return
  ([D4a record](../ext-D4a-record.md#deviations) Deviation 3).
* In the shadow engine's bracket stack, the marks above the matched one at an exit are lost exits,
  each counted in `exit_orphan`. The matched group's brackets get their `leave`; brackets of a
  higher group close without `leave`, because their function never returned
  ([D4a record](../ext-D4a-record.md#second-review-2026-10-12) S1).

**Since D7a (2026-10-17):** a renderer may hold a pushed row's readiness: the report renderer makes its rows
ready and holds row 97 while ProcessCity(city, -1) runs inside a report (6.3, "As built in D7a and D7b").

### 9.3 The core's decisions and presentation-local generators

* **Core decisions** (prompt 5.4; PROF 0.6 rule 1): the map redraw order, blink phase, unit
  move frames (D's); the leader idle frame, the newspaper's name form, tag and slogan (the core's
  `RandomBelow` results at 1138:01BD and 1138:03C7, A's probe list), the starfield, the city
  disaster case: the DOS renderer draws what the core chose and draws no random number.
* **OPEN P20 (city view layout), settled: follow the core's placements.** The core places houses
  and buildings with its own generator; the DOS view draws DOS art at the core's positions
  (logical mapping 8.3). The DOS 19x12 grid on `HILL.PIC` is not reproduced; recorded.
* **Presentation-local generator** for DOS-only effects with no core decision (PROF 0.6 rule 2;
  OPEN P3's non-map part):

  > **C passage condensed for the public copy.** The original record has here a block of 7 lines of C declarations: types `PdosRand`; functions `pdos_srand`, `pdos_rand`, `pdos_random`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

  The constants are DOS instruction immediates (E.18-5), cited by address. The arithmetic shift
  is written as floor division by 32768 in C (a right shift of a negative value is
  implementation-defined). For DOS's callers `n > 0`, so the result is in `0..n-1`.
* **Seeds (Choice B11):** each effect instance gets its own generator. Its seed is FNV-1a-32 of
  the effect name and the instance ordinal in the run (the number of times that effect started),
  folded to the 16 bits DOS `srand` takes (`h ^ (h >> 16)`, low word; C's note, C.10.1). It is
  never `g_randSeed` and never time. A test that replays a DOS sequence from a DOS seed passes
  that 16-bit seed unchanged. Users: the newspaper's torn edge (SP 7.7) and the ornamental border
  tile choice (R:0866:260E through R:1DC4:005D). Alternative: one shared generator for all
  effects, whose state would depend on how many effects ran (still deterministic, less local).
* **The instance ordinal is independent of visibility (RV2-18).** A's 7.4 compares every
  registered profile's frames across switch histories, so the ordinal must not depend on when the
  DOS profile was shown. Rule: an effect instance starts, and its ordinal is incremented, only in
  `on_event`, `on_probe` or `advance` (2.1), which run whether the profile is visible or not (O6).
  `frame()`, `peek()`, `cursor`, `indexed` and a profile switch never start an effect and never
  draw a number; they only compose what those callbacks drew. Test (`test_pdos_rand.c`, with
  `test_pdos_profile.c`'s stubs): an effect started from a probe, then `frame()` and `peek()`
  called 0, 1 and 5 times and a switch made between them; the ordinal and the generator's next
  values are the same in every case.
* G#10 dissolves use the driver LFSR (no seed).

## 10. Fonts and text

### 10.1 Font map (OPEN P14, settled)

The map is a table of rows `(Windows font id, call-site range or probe) → DOS font`, derived from
corresponding call sites (prompt 5.10; CORR finding 5).

| Windows | DOS font | Where | Label |
|---|---|---|---|
| ids 1..8 at shared sites | the same number | newspaper and New Cabinet sites (PROF F1..F6), the rating ladder (F7) | proved (F1..F6), inferred (F7) |
| id 8 at DrawCityLabels 1208:1F64; the city size digits and the unit status letters of the map (D 14.3, 14.4) | 1 | R:1AEA draws labels, size digits and letters in the font in effect (no font write in R:1AEA); OPEN L23 (D's "L17" is L23, decisions X5); D's B-4 | inferred, below |
| id 7 at the report header sites (O14 frame counterparts) | 1 | DOS draws report titles in the font in effect (SP 7.14, L14) | inferred, below |
| ids 4, 3, 7 in ShowPediaEntry 1068:0A07..0A96 | 6 (name), 7 (category) | SP 7.13 | proved (sites) |
| per-civ faces 200..215 (and 207, 213) at the leader screen | `8 + b`, with 10 replaced by 3. b = the byte `[DGROUP:640A]:t`, the far data segment named by DGROUP:640A at offset t; t = DGROUP:D7F4[n], n the leader routine's slot argument (O6:17EA..181E). The result is stored in DGROUP:67EC and set into port +10h at O6:07DE, 0802, 0DD7, 101E and 1833. D7F4 is run-time storage holding each slot's tribe id: written at O5:0A01 (`random(16)` with `& 7 == slot`) and O15:018A (slot or slot + 8), and saved at O11:0BC1. Its core counterpart is `g_playerCivId[n]` (12D8:4454, tribe 0..15, `(id & 7) == slot`). So the port computes `t = g_playerCivId[n]` (read with `w16q_rd16`) and `b` from E's table `LEADER_FONT` = `[DGROUP:640A]:0000`, 16 bytes (20) | the DOS leader text font | **DOS listing** (new here; settles F10 and F17: font 9 is the leader font when b = 1); the D7F4 ↔ `g_playerCivId` correspondence **inferred** (same writers' semantics); OB8 resolved |
| id 333 | not drawn | the N intro shows the DOS credits | inferred (F11) |
| family 216 (About) | W | | F12 |
| controls (WM_SETFONT, PaintRandomStatic, family 216 other sizes) | the DOS popup's font: 1 (title, most menus), 7 (setup), 2 (production); text entry in 8x8 cells | per R element (11) | inferred (F13, F14) |
| the intro credits, Birth text | 5, 7 | drawn by the scripted scenes from DOS texts, not through the map | proved (scene facts) |

* **The font in effect during play is 1 (inferred).** The start-up sets font 1 (O2:015E). The
  listing has 66 writes of the port's font word; each routine that sets another font sets 1
  again later (for example R:0ADE:12E4 → 1430, R:1D05:076C → 0796, O21:0098..03E0). Paths are not
  traced one by one: **Open OB4** (D6/D7) confirms per path. This settles L23's label font and
  L14's report font provisionally. Decisions X2 accepts these two rows as **inferred** (no
  corresponding site pair) while OB4 is open.
* **The segment at DGROUP:640A has two uses (RV2-17).** Its first 16 bytes are the leader-font
  table above (file bytes R:26FA:0000..000F = 00 00 01 02 01 02 00 01 00 02 00 02 01 00 02 01,
  values 0..2, so fonts 8, 9 and 3); other data follows from offset 0010. E.10.3 names the same
  segment "the throne-room table" and waits for its length (FORMATS 6.1, L1). E's D7 registry
  row `LEADER_FONT` (offset 0, 16 bytes, range 0..2) and a FORMATS 6.1 correction (D7) record both
  uses; neither changes E's interface.
* **Tracking the Windows id.** Logical text reads the id from word +10h of `g_pScreenPort`
  (DS:2990; showfunc 10D8:01D2) at entry. Other text uses the last SetCivFont 11E8:0B40 id set on
  the current graf (`g_graf` 1420:9960, read at the SetCivFont probe) or SetTextFontSizeColor
  1068:1F7E's (id, size).
* **Coverage log:** every (id, site) pair seen is counted in `presentation-diag.log`; an unmapped
  pair uses `id → id` for 1..8 and font 1 otherwise, and counts `font_unmapped`. D4..D7 tests
  require it to be 0 for covered scenes.
* The table lives in `pdos_fontmap.c` with a provenance string per row; `pdos_scene_check.py` checks
  it against PROF 2.4.

### 10.2 Glyph semantics: G#21 (OPEN P5, settled)

> **C passage condensed for the public copy.** The original record has here a block of 3 lines of C declarations: functions `pdos_draw_text`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* Font = `p->font` (1..N through E's `pdos_font`; anything else draws nothing).
* Each code: outside first..last skipped without advance; a byte of 80h or above sets the colour
  to `byte & 7Fh` for the rest of the string; otherwise the glyph rows from E's `pdos_font_row`
  (bit 15 leftmost; a one-byte font's second byte is the next glyph's, columns past 16 blank).
* Opaque only when the style's low byte is 1: set bits in the text colour, clear bits in `bg`,
  over width + spacing columns; height + extra rows when style bit 0 is set. Otherwise only set
  bits, with the raster op (G#41), over width columns (width + spacing for the last glyph).
* Clipping: right at `maxx` (the last visible character shortened), left at 0 (whole characters
  skipped, the first visible one cut), top 0, bottom `maxy`.
* DOS cuts the string by writing a 0 and restores it; the model works on a copy, so the caller's
  string is never written.
* **P5 settlement.** The model honours colour bytes in every string it is given, exactly as G#21.
  Which strings may contain them is the caller's: **DOS-sourced static text** passes raw (for
  example DGROUP:41B0, 346A, and the menu-bar titles DGROUP:1D6F..1D8E, whose 87h after the first
  letter switches the rest of the title to colour 7: the first letter in 15, the rest in 7, by
  G#21's semantics); **core text** passes through the 10.4 fold first, which leaves no byte of 80h
  or above. So core text never switches colour.
* Test: "G\x87AME" in a synthetic font: the first glyph in 15, the others in 7, `colour & 0xFF ==
  7` after the call; clipping vectors at both edges; opaque and transparent; style bit 0.

### 10.3 Alignment from the captured intent

| Intent captured at | DOS rule |
|---|---|
| DrawScreenText family (x) | left edge at x (R:0182:002A) |
| DrawCentered* (centerX) | `x = cx - W / 2` with W the R:0182:00EF width (sum of advances; trailing spacing included); W ≥ 0 so the division is a floor (cwd/sub/sar at R:0182:00C0..00C3) |
| DrawTextInRect (rect, flags) | left, centre (as above, around the mapped rectangle's centre `(l + r) / 2`), right (`r - W`) |
| TextBoxSetup/Draw | R:1F4D:0000/0088 wrapping: break at `^`, LF, or before a word passing `columns * 8`; the box width in DOS columns = mapped width / 8 |
| TruncateStringToLogicalWidth (str, w) | R:1F4D:04F7 on the original string: while width > w: if the third-from-last byte is not a space, the second-from-last becomes '.'; drop the last byte |
| MenuZ, ShowTextDialog, list dialogs | the menu box layout R:1D05:0475 (11.2) |

* R:1F4D:04F7 reads the byte before a string shorter than 3; the model treats bytes before the
  string as non-space and stops at the empty string (DOS would loop for a negative width).
  **Choice B12**, recorded.
* Widths always come from DOS metrics (E's `pdos_font_advance`), never from the core's results;
  the core's results are used only for content (what is drawn).

### 10.4 Windows-1252 (OPEN P13, settled)

**Choice B13: a fixed fold of core text to DOS-drawable bytes** (`pdos_charmap.c`):

| Core byte | Shown as |
|---|---|
| 20h..7Eh | unchanged (a code outside the font's range is then skipped as G#21 skips it: fonts 4, 5, 9 end at 7Ah, 7Dh, 7Eh) |
| 09h | space |
| other bytes below 20h, 7Fh | `?` |
| accented Latin letters C0h..FFh, 8Ah, 8Ch, 8Eh, 9Ah, 9Ch, 9Eh, 9Fh | the base letter (À..Å → A, Ç → C, È..Ë → E, Ì..Ï → I, Ñ → N, Ò..Ö and Ø → O, Ù..Ü → U, Ý, Ÿ → Y, Š → S, Ž → Z; lower case likewise) |
| Æ æ Œ œ ß Þ þ Ð ð | AE ae OE oe ss Th th D d |
| 91h 92h 82h | `'` |
| 93h 94h 84h AB BB | `"` |
| 96h 97h | `-` |
| 85h | `...` |
| A0h (no-break space) | space |
| A1h, BFh | `!`, `?` |
| D7h, F7h | `x`, `/` |
| A9h, AEh, 99h | `(C)`, `(R)`, `TM` |
| every other byte 80h..FFh | `?` |

* The DOS program has no substitution of its own (PROF 0.6 rule 8), so the rule is a port
  choice: port-written Windows-1252 knowledge, recorded in DESIGN and FIDELITY. Alternatives: a
  placeholder glyph (DOS fonts have none to borrow), or `?` for every byte of 80h and above.
* The fold may lengthen a string (at most 3 bytes per byte). It runs before measuring, wrapping
  and truncating, so all three see what is drawn.
* Applies to core (dynamic) text only. DOS static text is raw (10.2).
* Name entry accepts whatever the core accepts (prompt 5.10): the R text entry shows the EDIT
  control's text folded; input passes to the core unchanged (area C).
* Test: every byte 00h..FFh through the fold; the output is within 20h..7Eh; the table matches
  the documented rows.

## 11. Class R: re-skins from the control tree (`pdos_reskin`)

### 11.1 Common model

* An R element is rebuilt from `w16`'s state whenever an event names its window or a child:
  `OBS_DLG_CREATE`, `OBS_WND_*`, `OBS_CTL_*`, `OBS_LB`, `OBS_EDIT`, `OBS_FOCUS`, `OBS_WND_TEXT`,
  `OBS_WND_ENABLE`, `OBS_MENU_*`, read with `w16q_wnd`, `w16q_btn`, `w16q_edit`, `w16q_lb_*`,
  `w16q_menu_state`, `w16q_menu_bar`, `w16q_menu_item` and `w16q_msgbox` (A 5.1, 5.2).
* Every DOS menu box is a `PdosMenuBox` (4.4): one layout, drawing and row query for re-skins and
  for C-drawn boxes.
* Static text comes from the DOS program where the DOS box has the same element (PROF 3.4); the
  core's text otherwise, folded (10.4).
* Each element renders at DOS resolution into its own `PdosSurf` (11.3 places it).
* It draws only. Input goes to the core through area C's adapters, using 11.4.

### 11.2 Elements

| Element | Windows source | DOS form | Notes |
|---|---|---|---|
| **Menu box** | MenuZ 1220:0156 (dlg, text, x, y, colorIndex, autoSize, backdrop), SplitMenuText exit, the `RanDoMRadio` children (ids 500 + i): text, enabled, checked | R:1D05:0031/0475 (SCENES 10.1): header lines and item rows of height `FontLineHeight` (9 becomes 8), lines at (x + 5, y + 5 + r h), framed or frameless by y, headers colour 15 (3 on a 15 bar) with a colour-0 copy below when h > 9, items 0, disabled 3, highlight by RecolourRect (bar → 11, 22 → 3) | the highlighted row = the checked or focused child |
| **Text box with header** | ShowTextDialog 1220:00D2 (dialogs 136, 145), `g_messagePicture` 1418:0006 | R:0238:001E with the header of DGROUP:2F9E (SP 0.2): title at (x + 5, y - 4) in 15 with an 11 line; icon DF62[n] for 0..2 (`pdos_shape(PDOS_SH_REPORT, n)`, PROF P10), GOVT portrait for 3..6 | `g_messagePicture` is the DOS header number (CORR finding 4) |
| **Text entry** | RunTextEntryDialog 10F0:0066 (dialog 137), its EDIT control | SCENES 10.4: field (x, y, 7 max, 11) colour 15, outline (x, y - 1, 8 max + 8, 13) colour 0, characters at (x + 2, y + 2) in 8x8 cells, the cursor cell recoloured 15 → 11 | max = the EDIT limit; characters folded (10.4) |
| **List** | RunListBoxDialog 1098:1909 (dialogs 130, 131), the LISTBOX | a menu box whose rows are the visible list items (top index, page size by the box's DOS height) | **OPEN P16 settled:** Find City renders the core's list (dialog 131) as a DOS menu box; the DOS typed-name box is not shown |
| **Message box** | `#MsgBox` (user_msgbox.c): `w16q_msgbox` read at the box's `OBS_WND_SHOW` and kept until its `OBS_WND_DESTROY` (the query answers from the show; at create and at destroy it returns 0, A 5.2); text lines, buttons, default button | a menu box: the message wrapped by R:1F4D:0088 as header lines, one row per button (OK alone uses the menu box's "OK in an outline" form), the default button highlighted | 6.4; the caption is not drawn (DOS boxes have none). Between create and show nothing is drawn for it (the window is not visible yet) |
| **Production list** | ChooseCityProduction (dialog 140) | menu box in font 2 (SP 7.12) | **OPEN P19 settled: omit** the DOS advisor boxes: they depend on a DOS-only option bit with no core state behind it; recorded |
| **Go Back / Cancel** | dialogs 143 Cancel, 144 Go Back (id 102; `OBS_WND_ENABLE` gives its state) | **OPEN P17 settled (form):** one extra last row in the DOS menu box with the core's button text, coloured as an item (disabled: colour 3, as a disabled item); Escape's mapping is area C's adapter | before dialog 144 exists, 11.5 |
| **Hall of Fame Clear** | none | **OPEN P18 settled: omit** "Clear" (a DOS-only choice the core lacks, prompt 5.4 Flow) | |
| **Unit stack popup** | dialog 141 | the DOS popup of SP 7.19 drawn from the dialog's rows | the input form is P26 (area C) |
| **Static text and buttons inside N dialogs** (setup 144, Customize 143) | STATIC, BUTTON, Region controls | DOS text in the scene's font and colours at the scene renderer's DOS positions | positions from the D5 renderers |
| **Menu bar** (row 121) | the map window's `w16` menu bar: `w16q_menu_bar` (the bar rectangle and each title's rectangle) and `w16q_menu_item` (display text, mnemonic index, flags) (A 5.1, 5.2); `w16q_menu_state` for the highlighted title | see below (P24) | |
| **Drop-down menus** | `OBS_MENU_OPEN/HILITE/CLOSE`, the popup's items from `w16q_menu_item` (display text, mnemonic, MF_GRAYED, MF_CHECKED, MF_SEPARATOR) | DOS menu box (SCENES 10.2) in font 1: items colour 0, grayed 3, the highlighted item as the menu box highlight, a separator as an empty row, a checked item with the DOS check mark if SCENES 10.2 has one, else a leading `*` (**Open OB5**, D6; settled in D6f: the DOS mark '^', R:1D05:0939..0951) | |

**Withdrawn by the user's direction of 2026-10-16 (D5f, D5cR, D5eR).** The **Go Back / Cancel** row
above (OPEN P17's extra last row) is withdrawn: no DOS screen draws or hit-tests a Go Back or Cancel
row the DOS game lacks; where DOS has a key with the same effect (e.g. Escape), that key does it,
otherwise the choice is only in the Windows graphics. D5f removed D5b's extra row from the re-skinned
MenuZ box (Escape passes to the core's MenuZ, provisional per screen: a D6 or D7 renderer checks the
listing), and the **message box** draws one row per button except IDCANCEL (the default highlighted,
none when the default is the Cancel button); D5cR removed the setup pages' Go Back rows and D5eR
Customize's Cancel row, both now Windows-only (FIDELITY F168, F170, F172). The **Hall of Fame Clear**
is omitted as implemented in D5f (FIDELITY F173) ([D5f record](../ext-D5f-record.md);
[D5 gate record](../ext-D5-acceptance.md)).

**Menu bar (OPEN P24, settled).**
* Geometry: the Windows bar rectangle and title rectangles (row 121; the DOS positions 8, 64,
  128, 192, 240 and the x / 60 hit test are not used).
* Fill colour 0; text in DOS font 1 (the font in effect in play, 10.1).
* Titles: the five DOS titles where the core has the menu (File → GAME, Orders → ORDERS,
  Advisors → ADVISORS, World → WORLD, Civilopedia → CIVILOPEDIA; DGROUP:1D6F..1D8E, raw, so the
  87h colour switch gives the first letter 15 and the rest 7). The Windows-only titles Edit, City
  and Help: `w16q_menu_item`'s display text (no `&`), in capitals, with the letter at its mnemonic
  index in 15 and the rest in 7, matching the DOS pattern. **Choice B14** (capitals and colours).
  Alternative: the core's text unchanged.
* **User check (decisions X4):** the 1x bar text beside 2x art is listed for the user's visual
  check at D6.
* Each title starts where `w16` draws the Windows title text: the title rectangle's left edge
  plus the 8-pixel item margin (`user_wnd.c` `MENU_PAD`, FIDELITY F26), vertically centred.
* **Scale 1 (Choice B15).** Measured with `FONTS.CV` font 1 (scratch `barwidth.py`): the eight
  titles are 314 pixels of text at 1x and 628 at 2x, while the map window's bar in the 640x480
  layout is about 475 pixels wide (F103: map 165..640). A `w16` title rectangle is the system-font
  text width plus 16 (`menu_bar_rects`), so at 2x even GAME (58) is wider than File's rectangle.
  At 1x every DOS title fits inside its Windows title rectangle, so a click maps unchanged: no
  translation is needed (P24's hit question). Alternative: 2x when everything fits (only very
  wide virtual screens), which changes the bar's scale with the window size and still needs a
  title remap.
* The highlighted title (menu tracking) is shown as the DOS menu box highlight (RecolourRect 0 →
  11 over the title's rectangle).

**As built in D6f (2026-10-17; [D6f record](../ext-D6f-record.md) "The menu bar", "The drop-downs"; DESIGN.md 12.9
"As implemented (D6f; areas B and C)").** The bar as above (Choices B14, B15; the titles from the registry's
MENU_TITLES, DGROUP:1D6F; a title paired by its popup's commands; id `PDOS_R_BAR_ID`). The drop-downs: each popup of
the w16 menu loop but the system menu is a DOS menu box in font 1 at 2x anchored at the Windows popup's top-left
(`w16_menu_track_item`). **Choice D6f-2:** the box is at least the Windows popup's size with w16's 2-pixel shadow, and
every row covers its Windows item (so I-menubar maps a row to the item it shows). Rows follow `w16q_menu_item`
(ruling 2): separators as empty disabled rows, grayed items in colour 3, checked items with the DOS mark '^' (OB5,
OPEN L19), the loop's highlight. An item paired by role takes the DOS row's text (GAME, Options with its header,
ADVISORS, WORLD, CIVILOPEDIA: the registry's MENU_* rows; OPEN L25). **Choice D6f-3:** an unpaired item (ORDERS, built
per square; Edit, City, Help) shows the core's display text in DOS font 1 and its accelerator in colour 15, as DOS's
ORDERS rows show their keys. The Edit, City and Help drop-downs (report item R1) and the separators and grayed ORDERS
rows (R2) are known DOS/Windows differences with no owner unit (FIDELITY F196, F197).

**Choice D6f-2 reversed in D6fS-a (2026-10-17; [D6fS-a record](../ext-D6fS-a-record.md) "The DOS sizes", "The
covers"; DESIGN.md 12.9 "As implemented (D6fS-a)").** A drop-down is as large as its content, as DOS's menu box sizes
itself (R:1D05:059D..05B7; `pdos_menubox_layout`; `min_size` removed); the rest of its Windows popup is hidden from the
drop-down's first drawing until the screen beneath is repainted (the popup's saved pixels under it, the DOS art of the
windows beneath drawn over them), and a press or move there goes to a neutral point off the bar and every popup, so
the menu closes with no choice (Choice D6fS-a-3). The drop-downs' contents stay as above until D6fS-b (FIDELITY F226,
F227, F229).

**Changed by D6fS-b (2026-10-17; [D6fS-b record](../ext-D6fS-b-record.md) "The bar", "The menus", "H2: the DOS
highlight"; DESIGN.md 12.9 "As implemented (D6fS-b)").** The menu bar is the DOS bar at 2x (Choice B15 reversed by the
user's answer to D6-1): fill 0, the five DOS titles at their DOS x 8, 64, 128, 192, 240 (P24's "not used" superseded),
no Edit, City or Help title (Choice B14's capitals withdrawn: those menus are in the Windows graphics only), no title
highlight (ruling H2); a press goes to the Windows title of its DOS zone, x / 60 with the ADVISORS / WORLD boundary at
184 (Choice D6fS-b-1). The drop-downs are the DOS menus' own boxes at their DOS places with their DOS rows, ORDERS built
per unit and square (R:1C84:01D8), each row mapped to the Windows command that does its job (the item map); ruling 2's
one row per Windows item, the rest of Choice D6f-2 (the anchor at the popup's top-left, every row covering its item)
and Choice D6f-3 are reversed, R1 and R2 settled; a grayed command's row does nothing and View Replay ends the menu
(Choices D6fS-b-2, D6fS-b-3); the highlight is the DOS one, never the w16 loop's selection (FIDELITY F251, F252,
F254).

### 11.3 Placement on the N and A canvases

| Canvas | Anchor | Scale |
|---|---|---|
| N | MenuZ and ShowTextDialog: their logical (x, y) arguments; RunListBoxDialog, RunTextEntryDialog, `#MsgBox` and others: `L(d)` of the window's top-left relative to the scene window's client (8.3); a scene renderer may set a DOS position (`pdos_reskin_anchor(hwnd, x, y)`, for example the title menu's DOS place, SCENES 6) | 1 |
| A | the Windows window's top-left (device) | 2 (menu bar 1) |

* The DOS box is clamped inside the canvas (moved left or up as needed).
* On the A canvas the 2x box may extend beyond the Windows dialog (the DOS box is about 2/1.6 of
  its size). It is drawn above everything below the dialog in z-order and clipped by windows above
  it (6.2). **Choice B16:** anchor at the top-left. Alternatives: centre on the Windows dialog;
  scale the DOS box by 1.6 (non-integer, not DOS-looking).

**As built in D6f (2026-10-17; [D6f record](../ext-D6f-record.md) "The A placement").** While the frame presented is A
(`pdos_compose_kind`), the generic boxes of the MenuZ dialogs 136 and 145 (rows 14 and 22) and every `#MsgBox` are A
elements at 2x anchored at their Windows window's top-left (B16), clamped inside the canvas, the windows above them
excluded (6.2); framed, textured as DOS draws in play, on the play palette; a change of the frame kind moves a box at
the next core present (`pdos_r_place`; C1: one canvas at a time). **Choice D6f-6:** an A box is at least its Windows
window's size at 2x (`PdosRPlace.win`, `min_size_win`), so nothing of the Windows dialog shows beside it; the added
part is the box's own textured background with no row and no hit (FIDELITY F202). The other MenuZ dialogs bound to
class R rows stay on the N canvas (ruling 1: their scene forms are D7's).

**Choice D6f-6 reversed in D6fS-a (2026-10-17; [D6fS-a record](../ext-D6fS-a-record.md) "The DOS sizes", "The
covers", "The MenuZ box's close"; DESIGN.md 12.9 "As implemented (D6fS-a)").** An A box is as large as its content
(`min_size_win` removed; `PdosRPlace.win` kept for the diagnostics and the hidden window's rectangle), anchored as
above (B16). Its Windows window is hidden from the window's show until the screen beneath is repainted (the underlay of
the screen at its show, below every other A element, with the DOS art of the windows beneath drawn over it); at the
close the box goes at once and the A frame holds the DOS picture of that moment over the window's rectangle until no
window there has an update pending (`pdos_compose_hold`); a MenuZ box goes at its first item control's destruction
(Choices D6fS-a-1, -2, -4; FIDELITY F226..F228, F230).

**Changed by D6fS-b (2026-10-17; [D6fS-b record](../ext-D6fS-b-record.md) "The drop-downs").** The menu bar is drawn
at scale 2, and a DOS drop-down stands at its DOS place, the bar's top-left + 2 x the DOS position (GAME (16, 8),
Options (24, 16), ORDERS (72, 8), ADVISORS (112, 8), WORLD (144, 8), CIVILOPEDIA (182, 8)), no longer at the Windows
popup's top-left; the MenuZ boxes and message boxes keep the anchor above (B16) (FIDELITY F251, F252).

### 11.4 Hit geometry for area C

> **C passage condensed for the public copy.** The original record has here a block of 9 lines of C declarations: types `PdosRHit`; functions `pdos_r_hit`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* `frame_kind` is `HostEvent.frame` (1: N points; 2: A points, mapped back to the element's DOS
  resolution by its anchor and scale, 11.3).
* Pure: it reads B's last layout (the boxes' `PdosMenuBox` records), never `w16`.
* Area C's adapters turn a hit into the control-rectangle input of PROF 0.6 rule 7 (a point
  inside `ctl_rect`). So a DOS box larger than its dialog still maps exactly.
* For a box with no core control behind it, C calls `pdos_menubox_row` on that box directly
  (4.4). The title box is laid out by C's program with `pdos_menubox_layout`, so C holds its
  record. The T4 setup page's box is laid out by B's renderer, and `pdos_ui_box(PDOS_BOX_SETUP)`
  returns it (11.5).

### 11.5 N pages drawn before the core's dialog exists (C's B-6)

When the DOS sequence's next screen is fully known before the core shows its counterpart (T4),
area C asks B to draw it from DOS static content. Two cases exist:

1. the title box at the end of the DOS intro (C.7.1), drawn by C's program with the menu-box model
   (4.4) from `TITLE_MENU` (E's registry, DGROUP:1AE2) plus the added Quit row;
2. the first setup page after DOS Birth (C.8.7).

> **C passage condensed for the public copy.** The original record has here a block of 3 lines of C declarations: functions `pdos_setup_page`, `pdos_ui_box`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* **Content of step 0** (SCENES 9, 9.1):
  * `DIFFS.PIC` with its palette into page 1, copied to page 0;
  * font 7;
  * the frameless menu box at (160, 35) with the header and five levels of DGROUP:3526 (registry
    row `SETUP_DIFFICULTY`, 20);
  * the highlight on `row`;
  * P17's extra last row, disabled (colour 3), as the core's step 0 has it (`g_dialogMenuMode =
    -1`). Its text is the Go Back button text (id 102) of the Windows dialog template 144, a
    Windows fact (claude/docs: RunNewGameSetup's dialog 144 has OK 101 and "Go Back" 102), kept as
    a constant in `pdos_scene_tab.c` with that citation.
* **Takeover without a redraw.** The setup scene renderer keeps `(step, row, extra-row text)` of
  what page 0 shows. When the core's dialog 144 and its step-0 MenuZ arrive, it compares:
  * equal step: no redraw;
  * the core's selection: only the highlight moves (`pdos_menubox_select`);
  * the core's Go Back text differs from the constant: only that row is redrawn, counted as
    `setup_text_diff`.

  Any other difference (a later step) draws the page normally.
* **Choice B21.** Alternatives: omit the extra row until the core's dialog exists (the box grows
  by one row when the core arrives); read the template text from the core's resources through a
  new query (an A change for one string).
* The DOS mouse quirk of 9.1 (a click left of x 135 picks clamp((y - 12)/35, 0, 4)) is area C's
  adapter; B's box gives only its own rows.

**Withdrawn in D5cR (2026-10-16, the user's direction).** The setup page has DOS's rows only: P17's
extra last row on step 0 and Choice B21 (its text from a cited Windows template constant, the
row-only redraw, `setup_text_diff`) no longer apply; the core's Go Back is Windows-only (FIDELITY
F168), and `setup_text_diff` stays 0 ([D5c record](../ext-D5c-record.md) "User rework (D5cR)").

## 12. Class A: art in the Windows layout (`pdos_play`)

All three elements are class A (PROF rows 132, 136, 138, 139): Windows windows and positions, DOS
art, fonts and the play palette. Each has a DOS-resolution surface composed at 2x (12.2: the
core's small-map scale).

**As built (D6e, 2026-10-17; [D6e record](../ext-D6e-record.md); DESIGN.md 12.7 "As implemented (D6e;
area B)").** The module is `pdos_aplay` (`present/dos/pdos_aplay.h/.c`, the shadow engine's owner "aplay"): the
`pdos_play_*` names are the play palette's. It claims no shadow: each element is drawn whole from the module's
model at the exit of the function that changed it, into the module's own surface, which the A canvas composes at
the window's client clipped to its visible region and to what is drawn over the windows.

### 12.1 Map client

D's `Wn_dos` (D 6.2, 14); composed as the map element (7.5). Not B's drawing.

### 12.2 Small map (row 139)

* **Owner (decisions C7; D's B-5).** B draws the small map with D's P9 rule (D 14.8): the core's
  view frame and rows, not DOS's nine.
* **Macros** (`PdosMacro`, DROP, DOS rule set; 7.3): DrawSmTiles 1210:09B4, RedrawSmMap
  1210:073F, PlotSmMapSquare 1210:07AE (in A's 4.3 list by A-B2). Inside them the core's events to
  the small-map client are dropped. Each has the exit phase that closes its bracket: A 4.3 gives
  DrawSmTiles and RedrawSmMap E and X in Revision 3 (RV2-1; WI 10.7 lists them entry only), and
  PlotSmMapSquare had both by A-B2.
* **State** from D's snapshot read interface where it has the data: `pmap_src_current()` and
  `pmap_view_current()` in `pmap.h` (D 3, 7.2; RV2-6), read inside the callback that uses them
  (visibility,
  `g_mapViewerCivMask` 1408:00CC, terrain, cities); `g_smMapScale` 1410:0000, `g_mapViewCols/Rows`
  1408:00CA/00C8, `g_mapViewLeft/Top` 1330:4010/400E and the client rectangle by `w16q_rd16` and
  `w16q_wnd`. **Choice B17:** reuse D's snapshot. Alternative: B's own reads of the same blocks.
* **DOS drawing** (SP 4) with the core's geometry (DrawSmTiles step 6: frame centred, the core's
  frame top rule, wrap copy):
  * a square: never seen colour 0, ocean colour 1, land colour 2. The DOS minimap image's colours
    are inferred from the blink's restore (SP 6.1 row B: "minimap pixel colour 1 (ocean) or 2
    (land)"); **Open OB6** (D6): confirm with the image writer R:1AEA:17CF; settled in D6e
    (R:0866:034C..0376: colour 1 when the square's page-2 terrain colour is 1, else 2; never seen 0);
  * a city: the owner's main colour DGROUP:1946[owner] (R:1AEA:17FF) at the square, for the
    core's set of cities (status not FFh; known size or the human's);
  * bevel `(0, 0, w - 1, h - 1, 15, 8)` around the image area; the view frame as a colour-15
    outline around the core's frame (D's P9: the core's rows, not DOS's nine);
  * outside the image: colour 0.
* One DOS pixel per square, composed at the core's scale (2 in the default layout: exactly the
  DOS minimap at 2x).
* `PlotSmMapSquare` (blink) plots one square with the core's colour choice mapped: the core's
  EGA 6 land and 1 ocean become DOS 2 and 1 (PROF row 132 "land colour 2 versus 6").
* **As built (D6e).** Choice B17's alternative is taken: the module reads the same globals DrawSmTiles reads, at
  its exit, through the query (the include rule keeps `present/dos` from `present/map`'s headers, and D's snapshot
  holds the main map's view, not the whole world's visibility, terrain classes and city set). The small map is
  drawn at the core's scale (element factor 1: each square `g_smMapScale` device pixels, on a surface of the
  client's size), which is the same picture at scale 2 and also covers scale 1 and odd client sizes; the bevel at
  the client's edges and the outline one DOS pixel outside the core's frame rectangle (FIDELITY F191, F131); at map
  zoom -1 and +1 the outline surrounds the area the main map window shows, as MZW's World Map rectangle (D 5.6).

### 12.3 Status window (row 136)

* **Macros** (DROP, DOS rule set): RedrawStatusWindow 1218:0801, DrawStatusCivPanels 1088:13D5,
  DrawMiniPalace 1088:1A82 (in A's 4.3 list by A-B2). RedrawStatusWindow and DrawStatusCivPanels,
  and DrawUnitInfoPanel whose exit draws the unit panel (below), gain the exit phase in A 4.3
  (RV2-1; WI 10.7 lists them entry only); the panels drawn "at exit" carry A's `OBS_AT_EXIT`
  marker. Their draws to `g_statusBackPort` 12D8:4580 are dropped; the final
  CopyPortToWindow to the Status window (`g_statusWindowPort` 12B0:0034) becomes the element's
  update.
* **Surface:** DOS resolution `ceil(cw / 2) x ceil(ch / 2)` of the Status client (about 80 x 165
  in the default layout, whose background is 160 x 329, STATUS 2026-10-10 20:05), composed at 2x
  from the client's top-left.
* **Layout (Choice B18):** the DOS left column below the minimap, at 2x from the client's top:
  the status panel DOS (0, 58, 80, 39) at surface (0, 0); the unit panel DOS (0, 97, 80, 103) at
  surface (0, 39), its box extended to the surface's bottom; columns beyond 80 and rows below the
  unit panel's content filled with `pdos_texture`. Alternative: centre the DOS column in the
  client (the Windows panels are centred, F103 note), which moves the DOS layout off its left edge.
* **Status panel content** (SP 5.2), drawn at exit of DrawStatusCivPanels:

  | DOS line | Value from the core |
  |---|---|
  | panel, sky fill colour 11 | – |
  | peace bar `(3, 60, clamp(2 n, 0, 60), 2)` colour 15 when n > 1 | n = `g_peaceTurns` 12D8:38F0 |
  | mini palace: nine 7x15 strips at x 8 + 7i, ground line colour 2 | each DrawTile of a `g_miniPalaceShapes[v][i]` handle inside DrawMiniPalace: the slot from its device x, the variant from the handle (8.5); the core's choice of variants (rule 1) |
  | population "…#", year, treasury and rates lines at y 73, 81, 89, x 2, colour 0, font 1 | the core's strings, captured from the bracket's TEXTOUT events in order (line 1 population, line 2 year, line 3 treasury and rates), folded; the DOS order luxury, tax, science matches the core's (SP 5.2) |
  | research icon at (48, 80), warming icon at (56, 80) | the `g_statusIconShapes[k]` handles the core drew (k from provenance, 8.5); DOS page-2 art (160 + 8k, 120) and (160 + 8 (k - 4), 128) |

  The core's population message (row 137) is an R text box (11.2).
* **Unit panel** (row 138), drawn at exit of DrawUnitInfoPanel 11F0:468C (`g_unitPanelCiv/Unit`
  13F0:0000/0002):
  * DOS lines at x 4, colour 0 (SP 5.3): civilization adjective, unit type name, "Veteran"
    (DGROUP:20A3) when flag 20h, "Moves: " with the DOS fraction rule, home city, "(" terrain ")",
    the improvement lines, stack shapes 4 per row at x 8, 24, 40, 56 down to the panel's bottom
    minus 16, "+" when more did not fit; end of turn: "End of Turn", "Press Enter", "to continue"
    (DGROUP:207F, 208B, 2097).
  * Names (adjective, unit type, city, terrain) and numbers come from the core's state (unit and
    city records, name tables; read with `w16q_*`; structures from claude/src `civ_structs.h`),
    folded. The DOS static words come from DGROUP. **Open OB7** (D6): the exact core globals for
    each name table (from showfunc 11F0:468C). **Not needed since D6e:** the unit panel's lines are the core's
    strings, captured in order (adjective, type, moves, home city, terrain, improvements) and folded; only the
    third line is replaced by the DOS word "Veteran" when flag 20h is set, so the "Moves" fraction and wording and
    the "(n)" rule follow the core's text (FIDELITY F191; OPEN L4 stays open).
  * The stack order and membership are the core's (`nextInStack`), not DOS's walk (rule 1).
    The DOS "(n)" suffix for types with table word +4 set (SP 5.3, meaning unknown) is drawn when
    the DOS table says so (E's registry), recorded.
* Text "Press Enter" (DOS) versus the core's "Press Return": the DOS words (PROF row 138).

### 12.4 Window frames

The A windows' captions, frames and scroll bars stay Windows (class W within the A layout): DOS
has no windows. Recorded.

## 13. The P11 pixel check (done read-only, OPEN P11 settled)

**Method** (scratch `build/d1/scratch-B/`):
* `p11.py`: Windows picture 200 from `build/gamedata/civdata*.rsc` (the CvPc resource as
  OpenResFile 1190:0000 reads the map; the last file defining id 200 wins, as GetResource does):
  found in `civdata4.rsc`, 1472 x 400, minimum code size 7, 128 colours. Decoded with a GIF-style
  LZW decoder written from graphics.md 4.12 and palette-pictures 2.5 (588,800 pixels, the full
  image). The DOS pictures `SP257.PIC`, `TER257.PIC`, `SP299.PIC` decoded with `gen/dos/pic.py`'s
  `decode` (imported, nothing written outside scratch).
* Measures per region: 2x2 block uniformity, index-mapping consistency, RGB agreement;
  `p11view.py` wrote side-by-side PNG views; `p11units.py` measured each unit cell's opaque
  bounds; `p11mask.py` measured opaque-mask agreement under shifted mappings.

**Findings:**
1. **The Windows sheet is redrawn art, not a 2x copy.** 2x2 block uniformity is 0.82 (SP257
   part), 0.19 (TER257 part) and 0.67 (x ≥ 1152); colour agreement within 12 per channel is under
   2 % in every part; the Windows palette (128 entries) is ordered differently.
2. **The layout matches.** In the SP257 part the opaque-mask agreement peaks at offset (0, 0)
   (0.815 against at most 0.802 at one pixel off). The x ≥ 1152 part shows the same subjects at
   the positions of CORR finding 2's rule (2x + 832, 2y − 100): building icons, bulbs and discs,
   the border tiles, the whole-square coasts, then grass and stone textures (visual comparison of
   the decoded views). The mask measure does not discriminate there because the DOS page-2 cells
   have no transparent background.
3. **Unit band.** In each of the 28 cells the Windows unit art fills device columns 0..29 of the
   32-column cell at 32 (j mod 20); columns 30 and 31 hold the key colour. That is exactly the
   cut T2(16 (j % 20), 161 + 16 (j / 20), 15, 15) without +1. The DOS cell has a separator line
   (colour 3) in column 16k and the art in 16k + 1 .. 16k + 15, which DOS's +1 cut takes. Each
   sheet matches its own cut: the Windows art sits one logical column left of the DOS art, and
   both cuts take the whole unit.
4. `g_wholeTileShapes[7..10]`: Windows device 1344..1407 is one continuous grass texture
   ([7], [8]) and 1408..1471 one stone texture ([9], [10]); DOS page-2 (256..287, 120..135) is
   grass and (288..319, 120..135) stone. So [8] (Windows river base) falls on the right half of
   the DOS grass texture, (272, 120); how the DOS map uses it is D's (CORR Open 1).

**Decision:**
* The profile draws DOS art by provenance for every picture-200 shape: the SP257 and TER257
  rectangles of PROF 2.2, the SP299 page-2 art for the x ≥ 1152 shapes (S18..S23), and the units
  at DOS's own rectangle (16 (j mod 20) + 1, 161 + 16 (j div 20), 15, 15) of `SP257.PIC`, drawn
  at the core's unit position with no offset correction. E's `pdos_shapes` cuts exactly this art:
  O5:1455 copies rows 160..191 to 128..159, recolours them per civilisation, then cuts (16 (j mod
  20) + 1, 129 + 16 (j div 20), 15, 15) (E.9.3 row 22, E.9.4; decisions X6).
* WI 2.1's "Windows-only" region is relabelled "Windows-redrawn SP299 page-2 art": layout
  checked here, subject identity by visual comparison (inferred). CORR Open 1 and PROF Open 10
  close with this record.

## 14. Costs and limits

| Item | Cost | Limit and failure |
|---|---|---|
| N canvas and its frame | 64 KB page 0, three more pages (192 KB); conversion of 64,000 pixels about 0.1 ms | – |
| A frame | XRGB at the screen size: 17.4 MB at 2726 x 1600 | allocation failure: the A frame shows the base only, `no_memory` |
| A recomposition | per damage; a play-palette step reconverts the map, small-map and status regions, about 4 ms at 4 Mpixel | – |
| Shadows | logical shadows 64 KB each (512x320 ports); D's map-pixel shadows at the client or port size (up to 4 MB each, D 18), a second set only under `--mirror 2`; at most 256 | full: counted, unshadowed |
| Brackets | one record per open probe; depth at most 32 | deeper: counted, events unexplained |
| Macro and hook tables | at most 128 macros (B's leaf primitives about 30, status and small map 6, D's 7, scene renderers the rest), 4 owners (5 since D6e: setup, pmap, replay, aplay and the tests' own) | registration beyond: -1 at reset, the owner's macros inactive, counted |
| Element surfaces | status about 80 x 165, small map 80 x 50, R boxes at most 320 x 200 each, at most 16 open | more: counted, not drawn |
| Provenance map | about 1,200 sheet handles plus cut shapes, hash of 4,096 slots | full: counted, `prov_unknown` on draw |
| Probe handlers | read a few words each; text copies at most 512 bytes | – |
| Event handlers when hidden | the same work (O6); measured at D3 with A's soak timing | – |

Performance target of prompt 8 (a 4K frame in 8 ms) concerns the scaler (S2). Composition adds
damage-limited conversion only; D3 records the A frame's full recomposition time at 2726 x 1600 in
Release (expected under 6 ms).

## 15. Tests

### 15.1 Unit tests (no emulation; Checked and Release; Asan in the final pass, K8)

| Test file | Properties |
|---|---|
| `tests/test_pdos_draw.c` | each driver function against vectors written from DRIVER 4: FillRect's row-skip rule; CopyRect order without clip; sprites: transparency, clipping and the returned rectangle; RecolourRect with w = 0 (65536 iterations, writes past the page dropped and counted); DrawLine end-point order and Bresenham error start; WriteRow's odd count; Dissolve: the LFSR visits every offset 0..63999 exactly once, 8800 / duration per frame; every function again on a `k = 2` port with an odd origin equals the `k = 1` result scaled 2x and shifted |
| `tests/test_pdos_glyph.c` | G#21 on a synthetic font built in the test (no DOS bytes): colour switch, skip without advance, opaque and transparent widths, style bit 0, left and right clipping, the return value and early exit; R:0182:00B3 centring; R:1F4D:04F7 truncation vectors; wrapping at `^`, LF and `columns * 8`; the Windows-1252 fold of all 256 bytes |
| `tests/test_pdos_ui.c` | menu box layout vectors from SCENES 10.1; `pdos_menubox_row` from R:1D05:018A..0233: rows at the truncating division's edges (points above the first item, the last pixel row), x outside `[x, right]`, out-of-range items, the OK form, disabled items reported; RV2-11: `h8` set with a 9- and a 10-pixel font (h = 8, rows and the row query move), and the clamp for boxes at y = 150, 185 and 192 (rows = (192 − y)/h, 0 at 192; `bottom` follows) |
| `tests/test_pdos_rand.c` | `pdos_srand` with 16-bit seeds and `pdos_rand` against sequences computed in the test from the stated formula; `pdos_random` for n = 1, 16, 7FFFh and a negative n (arithmetic shift); B11's seed fold |
| `tests/test_pdos_pal.c` | the 6-to-8 table (5.1); fade arithmetic at w = 0, 65535 and midpoints; cycling capture (count capped at 16), direction, `pdos_cycle_advance(n)` equal to n single steps, stopped slots; with `--dos-data`: the P4 report against PALETTE 6 (5.4) |
| `tests/test_pdos_shadow.c` | synthetic `ObsEvent`/`ObsProbe` streams: lazy claim with the first owner winning, bitmap create, logical draws in brackets, dropping, copies to windows applied inside DROP brackets, overlap-safe copy within one surface, GR_PortDataToBitmap rebinding with `on_resize`, movie port swap (two bitmaps exchanged), the outermost-owner rule (a replay bracket inside a D-style macro is muted), contexts (`pdos_shadow_context`), two rule sets on one surface (B's replay touches only DOS), hooks receiving events outside brackets, re-registration replacing an owner's table, unexplained counting; RV2-1/RV2-4: a macro whose key has no exit phase, or whose `ra` has no call-site row, is refused and counted in `macro_config`; at an exit, `leave` reads the returning function's scene row before the pop (RV2-12) |
| `tests/test_pdos_profile.c` | the callback order of 2.1 with stub `pdos_seq_*` that log calls: scene listener, then C, then the engine, for events and probes; `advance` calls C visible or not; `input_frame` follows the presented kind; `reset` calls `pdos_seq_reset` |
| `tests/test_pdos_cursor.c` | the id table of 6.7, C's hidden rule overriding every row, NULL for 136..143, alpha 0/255, 1x on N and 2x on A, `gen` unchanged by layout changes and changed by a used DAC entry |
| `tests/test_pdos_setup.c` | the T4 setup page of 11.5 on a synthetic store (no DOS bytes: a test picture and test strings), then a synthetic dialog 144 step 0: no page-0 change except the highlight; a different Go Back text redraws only its row |
| `tests/test_pdos_replay.c` | each 8.2 primitive draws the DOS form at the logical position; nothing when the bracket saw no event; the coordinate rules of 8.3 including the exact-preimage case; colour rules of 8.4 |
| `tests/test_pdos_compose.c` | frame choice (N, A, W over N fallback, unclassified window), damage unions, palette changes re-compose only their layers, frame-kind switch with fixed host size and exact mouse mapping, the 8-bit dump |
| `tests/test_pdos_reskin.c` | menu box re-skins (row height, framed versus frameless, colours, highlight), the message box from a synthetic `W16qMsgBox` read at show, menu bar title colours and positions from synthetic `w16q_menu_bar`/`w16q_menu_item` results, `pdos_r_hit` rows and controls |
| `tests/test_pdos_play.c` | small-map colours and frame from a synthetic snapshot; status lines from captured strings; unit-panel lines and the stack overflow "+" |

### 15.2 Harness and checks

* `tests/harness/pdos_scene_check.py` (read-only): the scene table, font map and probe needs agree
  with `DOS-PROFILE.md` 1 and 2.4 and with A's probe list.
* A's 7.3 P0 runner and 7.4 frame determinism with the DOS profile (RV1-5: `--dos-data
  build\dosdata`): P0 unchanged; the presented frames identical in repeated runs and independent
  of when the DOS profile was visible (O6).
* D4..D7 scenarios: `pdos_diag` counters `unexplained`, `w_over_n`, `colour_nearest`,
  `font_unmapped`, `prov_unknown` are 0 for covered scenes (from `presentation-diag.log`).
* D-7 hashes: N frames at the default zoom; A frames with a fixed game screen (6.5).
* The P11 check is recorded (13); its scratch scripts can be rerun read-only.

## 16. Rule coverage

| Rule | How the design meets it | Test |
|---|---|---|
| O1 events | consumed as A delivers them; no new event types except the queries in 20 | `test_pdos_shadow`, A's tests |
| O2 probes | brackets on the 4.7 primitives and text probes (E, X), status and small-map macros; additions listed in 20; every macro key and exit-0 scene row has the exit phase (RV2-1) and every call-site filter is a generated row (RV2-4) | `pdos_scene_check.py`, A's probe verification, A's obs_lint "exit phases" and "call-site rows", `pdos_shadow_macros`' `macro_config` counter |
| O3 reading | only `w16q_*`, through `pdos_profile` and the handlers | `obs_lint.py` over `present/dos` |
| O4 forbidden | no `w16_` calls, writes, steps, input, `g_randSeed`; Checked sentinel | lint; P0 runner |
| O5 records | B's probe needs and macros go into DESIGN and TRACE through A's table | `pdos_scene_check.py` |
| O6 concurrency | both canvases, shadows, scene stack and palettes update on every event whether visible or not | 7.4 runner (switch at random times, frames equal) |
| O7 tick | the DOS profile shows through `frame()` at ticks only (`shows_core_frame` 0) | A's tick tests with the DOS profile |
| T1 native pace | B draws what area C's timelines ask; no clock in B | C's tests |
| T2 concurrency | renderers current when hidden (O6) | 7.4 |
| T3 core not held | B never blocks or delays a callback beyond its drawing | P0 runner timing equality |
| T4, T5 | the scene stack exposes the core's state to C; B holds the last frame when C stops drawing | C's tests |
| T6 clock | frame content is a function of events and the virtual time C passes; B reads no clock | 7.4 |
| T7 core timing in play | map cycling steps per core event (5.5); unit moves, combat, blink and city animations from the core's events (D, D7) | `test_pdos_pal`, D's tests |
| I1..I4, I6, I7 | B produces no input; `pdos_r_hit` is pure | P0 runner, lint |
| I5 mouse in N | N frame coordinates are DOS logical points (`input_frame` 1); area C converts them by the core's own input rule per consumer (C.14). 8.3's L(d) is a drawing rule only and is not used for input (corrected in Revision 2) | C's I5 tests |
| I8 wheel | not B's | – |
| 5.3 frames and composition | N canvas, A canvas at the screen size (C4), palettes before composition, damage, W over N (6) | `test_pdos_compose` |
| 5.4 classes, replay, core decisions, scene table | sections 7..9, 11, 12 | `test_pdos_replay`, `test_pdos_shadow`, scenarios |
| 5.8 map renderer support | one shadow engine with D's owner hooks and macros (7.3, 7.5; C5), A canvas map element, DOS art at 2x through `k = 2` ports (3), `present_host_rect_inner`, `present_axis_taps`; the small map and status not zoomed (12) | `test_pdos_shadow`, `test_pdos_draw`, D's tests; `test_scale` additions (20) |
| 5.9 palette rule | round-to-nearest 6-to-8 (5.1) | `test_pdos_pal` |
| 5.10 fonts and text | font map (10.1), G#21 model (10.2), alignment from intent (10.3), Windows-1252 fold (10.4) | `test_pdos_glyph`, `pdos_scene_check.py` |

## 17. Choices (summary)

| Id | Choice | Alternatives (one line) |
|---|---|---|
| B1 | 6-to-8 by rounding: `(v * 255 + 31) / 63` | floor; bit replication |
| B2 | R elements over N as overlays composed at frame time | draw into page 0 with a DOS save-under |
| B3 | read the core's XRGB frame through `present_core_xrgb()` | a private copy in the DOS profile |
| B4 | every `#MsgBox` re-skinned as R | show the A frame while it is open |
| B5 | busy cursor 132: pointer hidden | keep the torch |
| B6 | shadows keyed by bitmap handle and window handle | keyed by GrPort address |
| B7 | unexplained events change nothing and are counted | nearest-colour paste of Windows pixels |
| B8 | target kind computed from the globals at entry | exit probe on MapLogicalPointToPort |
| B9 | device to logical `L(d) = floor((10d + 9) / 16)` | `floor(10d / 16)` |
| B10 | hand-written scene table checked against the document | generated from the Markdown |
| B11 | per-effect generators seeded from the effect name and instance ordinal, folded to DOS's 16-bit seed | one shared generator |
| B12 | R:1F4D:04F7 model: bytes before the string are non-space; stop at the empty string | reproduce reads before the string |
| B13 | fixed Windows-1252 fold to 7-bit text | placeholder glyph; `?` for all bytes ≥ 80h |
| B14 | Windows-only menu titles in capitals, mnemonic in 15, rest in 7 | the core's text unchanged |
| B15 | menu bar text at scale 1 | 2x when it fits |
| B16 | R boxes on the A canvas anchored at the dialog's top-left at 2x | centred; scaled by 1.6 |
| B17 | small map from D's snapshot | B's own reads |
| B18 | status window: DOS column at 2x from the client's top-left, unit box extended down | centred column |
| B19 | the shadow engine runs inside the DOS profile; D's `--mirror 2` needs `--dos-data` | `observe.c` feeds the engine on its own |
| B20 | nested brackets: the outermost DROP bracket on a surface owns it, inner ones are muted there | innermost wins |
| B21 | T4 setup page: P17's Go Back row from a cited Windows template constant, replaced by the core's text when it differs (withdrawn in D5cR, 2026-10-16: no Go Back row, 11.5) | no extra row until the core's dialog; a resource query in A |
| B22 | `pdos_profile` order: scene stack, then C, then B's drawing | B first, then C |
| B23 | `PdosPort.k`: one driver for DOS pages (k 1) and D's map-pixel shadows (k 2) | separate 2x drawing functions in D |
| B24 | at an exit probe the shadow engine's `leave` runs before the scene pop, after C's timelines reach the probe's time (RV2-12) | one order; no `leave` reads the scene stack |
| also | driver writes outside a page dropped and counted (4.1); the pointer is a host cursor (4.2, 6.7); `SLAG2`/`SLAM2` drawn `width` columns only (P27, 18) | 64 KB segments; software pointer; modelled G#19 row buffer |

## 18. OPEN.md P items

**Settled by area B here:**

| Item | Settlement | Section |
|---|---|---|
| P4 | EGA c is DOS index c in the scene's DAC; PALETTE 6's differences are the DOS look; a report test, no correction; MGRAPHIC's table not needed (E3) | 5.4 |
| P5 | G#21 honours colour bytes; DOS static text raw, core text folded first | 10.2 |
| P11 | pixel check done: Windows sheet redrawn with the same layout; x ≥ 1152 is SP299 page-2 art; each sheet matches its own unit cut; DOS art by provenance, units at DOS's rectangle | 13 |
| P12 | `#MsgBox` re-skinned as R; generic fallback counted | 6.4 |
| P13 | the fold of 10.4 | 10.4 |
| P14 | the font map of 10.1, including the leader font `8 + b` with b = `LEADER_FONT[g_playerCivId[n]]` (O6:17EA..1833; D7F4 = the slot's tribe id) and the inherited font 1 for labels, size digits, unit letters and report titles (inferred, X2) | 10.1 |
| P16 | Find City as a DOS menu box of the core's list | 11.2 |
| P17 | form: an extra row in the DOS menu box (input: area C); on the T4 setup page before dialog 144 exists, the row from a cited Windows template constant (11.5); **withdrawn** by the user's direction of 2026-10-16 (11.2) | 11.2, 11.5 |
| P18 | omit "Clear" | 11.2 |
| P19 | omit the advisor boxes | 11.2 |
| P20 | follow the core's placements | 9.3 |
| P21 | busy: hidden; small map: torch; scroll arrows: the game's cursor (NULL); hidden whatever the id while a DOS intro or Birth timeline is live (C's rule, C.11.5) | 6.7 |
| P23 | round to nearest; viewers relabelled | 5.1 |
| P24 | Windows geometry, DOS font 1 at scale 1, DOS titles with their colour switch, clicks unchanged | 11.2 |
| P27 | draw `width` pixels only; the 198th byte comes from stale DOS memory (DGROUP:E17E) and is not reproduced; registered for D7 (SLAG2/SLAM2) | 4.2, below |
| P3 (part) | the generator model and seeding rule for DOS-only effects | 9.3 |

P27 detail: the profile decodes `SLAG2`/`SLAM2` with E's decoder (exact `width` pixels) and
draws them with `pdos_sprite`/`pdos_copy_rect` of `width` columns. **Choice**; alternative:
reproduce G#19's extra byte with a modelled row buffer (its content depends on earlier, wider
rows of other pictures: decode order). Recorded in FIDELITY.

**Belonging to other areas:**

| Area | Items |
|---|---|
| C (timelines, input) | P1, P2, P7, P10, P15, P22, P25, P26, P29; P17's Escape mapping; P3's timing aspects |
| D (map) | P9 (settled by D), P3's map order and P6 (settled by D) |
| E (assets) | P8 (settled by E), P28 (resolved by E.18-5) |

## 19. Open items

| Id | Open | Resolved by |
|---|---|---|
| OB1 | inputs of the `back<g><a\|m>.pal` selection (R:0238:1BEB) mapped to the core's state | **settled in D6e**: R:0238:1C11..1C46, the government as GetCourtStyle 1160:3487 selects it, 'm' after advance 14h, government 3 alone '3' |
| OB2 | the DOS drawing of ShowIntelligenceAdvisor's labels (DrawBeveledLabelBox counterpart) | **settled in D7b**: R:0D12:71BF (O14:0FBE..0FE3), the DOS colours of [1946h + 2 civ] (DESIGN.md 12.7 "As implemented (D7b; areas B and C)") |
| OB3 | DrawTextInRect's vertical placement | D4: showfunc 1098:0ED1 |
| OB4 | the font in effect during play is 1 on every path | D6/D7: trace the 66 font writes per path; still open after D7a, whose two report-title sites map id 7 to font 1 as an inference (DOS-PROFILE 2.4 F18; FIDELITY F206) |
| OB5 | the DOS drop-down's check mark | **settled in D6f**: '^' (R:1D05:0939..0951 for the bits of DGROUP:D7F2, as the GAME menu's Options marks its settings; OPEN L19) |
| OB6 | the DOS minimap image colours (0, 1, 2) | **settled in D6e**: R:0866:034C..0376, colour 1 when the square's page-2 terrain colour is 1, else 2; never seen 0 |
| OB7 | the core globals for the unit panel's name tables | **not needed** (D6e: the unit panel's lines are the core's strings) |
| OB8 | **resolved in Revision 2** (10.1): D7F4 is the per-slot tribe id (writers O5:0A01, O15:018A; saved at O11:0BC1), counterpart `g_playerCivId`. Left: the length and identity of the table `[DGROUP:640A]:0000` (16 bytes read by tribe id) in E's registry, with OPEN L1 | E at D7 (OFFSETS.md row `LEADER_FONT`) |
| OB9 | the DOS city screen's map-square positions (R:0D12:0045) against the core's transformed points in city mode (8.3) | D7: R:0D12 listing and SCENES-PLAY 7.1 |
| OB10 | DGROUP:D206 in the menu-box row test (R:1D05:022C): taken as 0 in the port; its writer and meaning | D4: the listing's writers of D206 |
| OB11 | DGROUP:B1EC and D208 read as "header lines before the items" and "item count" (4.4, inferred from their use) | D4: R:1D05:0475's writers |

## 20. Changes needed from other areas

**Area A** (A-B1..A-B8 accepted by the orchestrator and adopted in A's Revision 2; listed for the
record, with what B now relies on)

| Id | Change | Status in A Revision 2 |
|---|---|---|
| A-B1 | Exit probes on every logical primitive and text probe of 8.2 (brackets) | adopted (A 4.3) |
| A-B2 | Probes GR_PortDataToBitmap 10B8:0E36, PlotSmMapSquare 1210:07AE, DrawMiniPalace 1088:1A82 (E, X) and all of WI 10.2's text probes | adopted (A 4.3 takes all of WI 10; revision 1's "where A's list does not name them" is moot) |
| A-B3 | `w16q_msgbox` | adopted; answers from the box's show to its destroy (A 5.2); B reads it at `OBS_WND_SHOW` (11.2) |
| A-B4 | `w16q_menu_item` (and `w16q_menu_bar`) | adopted (A 5.1, 5.2) |
| A-B5 | `present_core_xrgb()` | adopted (A 8.3), the one accessor of the Windows frame |
| A-B6 | re-layout and whole-client redraw on a frame-size change | adopted (A 7.2 step 5a) |
| A-B7 | the cursor route takes `pdos_cursor_current()` | adopted (A 8.5) with A's Choice 26 (the back end scales); NULL = the game's cursor answers A11 (6.7) |
| A-B8 | 8-bit N-frame dumps | adopted through the profile's `indexed` callback and `tick-NNNNN.bmp` in both back ends (A 7.3) |
| A-B9 (note) | ScaleLogicalX/Y's exit probe is not needed by B (8.2); A may drop it | for A's merge; A 17 records it with RV2-15 (D3 decides) |
| A-B10 (RV2-1) | Exit phases on the nine functions whose brackets or exit-time drawing B relies on (12.2, 12.3, 5.5) and D's macros; a build-time check of exit phases; `obs_probe_phases` for `pdos_shadow_macros`' check | adopted in A Revision 3 (A 4.2, 4.3, 6.2) |
| A-B11 (RV2-4) | `obs_callsite(callee, ra)` to resolve `PdosMacro.ra` and `PdosSceneRow.ra` at reset | adopted in A Revision 3 (A 4.2) |

**Area C** (C's B-1..B-8 adopted; changes asked of C)

| Id | Change | Why |
|---|---|---|
| C-B1 | `pdos_seq_reset()`, called from `pdos_profile`'s `reset` (C's state per run, `hh_run` and `obs_init`) | 2.1 |
| C-B2 | Use `pdos_mn` (was `g_mn` in B revision 1, C.5.4, C.21 B-1) and the cycling split of 5.3 (`PdosCycle` holds colours and position; C's `PdosCycleSlot` holds rate and timing; `pdos_cycle_step(c, d, dir)`, `pdos_cycle_advance`) | 3, 5.3 |
| C-B3 | `pdos_srand` takes `uint16_t`; `pdos_random` is `int16_t` with a signed `n` (C's note, C.10.1) | 9.3 |
| C-B4 | The setup page entry `pdos_setup_page(m, step, row)` and `pdos_ui_box(PDOS_BOX_SETUP)` for C.8.7; the title box laid out by C's program with `pdos_menubox_layout`, rows with `pdos_menubox_row` | 4.4, 11.5 |
| C-B5 | C's listener runs before `pdos_seq_on_*` for the same event (2.1, 9.2) | 2.1 |

**Area D** (D's B-1..B-5 adopted; changes asked of D)

| Id | Change | Why |
|---|---|---|
| D-B1 | Register with `pdos_shadow_hooks("pmap", ...)` and `pdos_shadow_macros("pmap", ...)` from `pmap_reset` (replacing the proposed `PsMacro`/`ps_register_macros`); `target` returns 1 and the surface, or 0 for "not ours" (D's -1); `enter` draws from state per rule set; context macros (AnimateUnitMove, ResolveCombat) use `PDOS_MAC_CONTEXT` and `pdos_shadow_context`. **Adopted in D Revision 3** (D 9.3, 9.4; RV2-7) | 7.3, 7.5 |
| D-B2 | Claim `P`, `S`, `Wn` lazily (the port bitmap global is stored after `CreateBitmap` returns) with `PDOS_RES_MAP`; draw DOS art through `k = 2` ports (`pdos_shadow_port`) with B's driver | 3, 7.1, 7.5 |
| D-B3 | `--mirror 2` needs the DOS profile registered (`--dos-data`, Choice B19); D's D6 runs already pass it | 7.5 |
| D-B4 | Cite L23 (not L17) in 14.3, 14.5 and B-4 (decisions X5); the label, size-digit and unit-letter font is 1 (10.1, inferred). **Applied in D Revision 3** | 10.1 |
| D-B6 (RV2-6) | Export the snapshot read interface with the `pmap_` prefix (`pmap_src_current`, `pmap_view_current` in `pmap.h`) for 12.2. **Applied in D Revision 3** (D 3, 7.2) | 12.2 |
| D-B5 | Handlers must not depend on `pmap_on_event` having seen the same event first (2.1 order) | 7.5 |

**Area E** (changes asked of E)

| Id | Change | Why |
|---|---|---|
| E-B1 | OFFSETS.md rows for the strings B draws, added at their phases: `MENU_TITLES` DGROUP:1D6F..1D8E (D6), `SETUP_DIFFICULTY` DGROUP:3526 (D5, 11.5), DGROUP:20A3, 207F, 208B, 2097 (unit panel, D6), 41B0, 346A (D7); words DGROUP:2F98 (D4) and the report captions 2FA6 (already `REPORT_CAPTIONS`) | 4.3, 10.2, 11, 12 |
| E-B2 | `LEADER_FONT` = `[DGROUP:640A]:0000`, 16 bytes indexed by tribe id (O6:1811..1815), with the length check of OPEN L1 (OB8). The segment is also E.10.3's "throne-room table"; the D7 row and a FORMATS 6.1 correction record both uses (RV2-17; 10.1) | 10.1 |
| E-B3 | The unit table word +4 of SP 5.3 when D6 adds the unit panel's "(n)" rule | 12.3 |
| E-B4 | E.9.5 wording: the pointer's index-to-ARGB conversion is the DOS profile's cursor callback (B, A 8.5), not A's route itself | 6.7 |
| E-B5 | `MGRAPHIC.EXE` and `DRV_DEFAULT_PALETTE` may leave the required set (E3, 5.4); `gen/dos/png.py vga6_to_8` changes to the rounding rule at D2 (5.1) | 5.1, 5.4 |

D7F4 is run-time storage (≥ DGROUP:6B30h). Revision 1 listed it as a table for E, which was
wrong; the port reads the core's `g_playerCivId` instead (10.1).

**scale.c (B owns, phase M, D's B-3):**

> **C passage condensed for the public copy.** The original record has here a block of 7 lines of C declarations: functions `present_host_rect_inner`, `present_axis_taps`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

The existing per-axis tap builder of `present_scaler_set` becomes a call of `present_axis_taps`
with `num = SW`, `den = W`, `first = 0`, `n = SW`; `test_scale` checks the taps are unchanged
(goldens of 7.1 unchanged) and that `present_host_rect_inner` is inside `present_host_rect`.

## 21. Conflicts and points for the orchestrator or the user

**Revision 1's conflicts, as resolved (decisions "Area B"):**

| Id | Point | Resolution applied |
|---|---|---|
| X1 | 5.4's "verify per scene ... EGA colours" against PALETTE 6 | a per-scene report in the D4..D7 records, no correction (5.4) |
| X2 | two font rows on the inherited font 1 | accepted as inferred while OB4 is open (10.1) |
| X3 | start-up screens "shall stay 4:3" against `--aspect square` | the `--aspect` default is 4:3 for 320x200 frames; `square` stays the player's override (6.6; A 11). For the user's check |
| X4 | menu bar text at 1x beside 2x art | B15 kept; for the user's visual check at D6 (11.2) |
| X5 | D's L17 for the label font | L23, corrected at the merge (10.1; D-B4) |
| X6 | units cut at DOS's rectangle | as SPRITES 6.4 and E.9.3 row 22 (13) |

**Points from this revision (none needs the user; for RV2 or the merge):**

| Id | Point | Proposal |
|---|---|---|
| X7 | D's Windows-rule shadows (`--mirror 2`) live in B's engine, which the DOS profile feeds (B19), so the oracle needs `--dos-data` even for Windows-rule checks | Accept (D's D6 runs pass it, RV1-5); alternative B19's |
| X8 | E.9.5 says area A converts the pointer's indices; A 8.5 gives the conversion to the DOS profile's callback, which B implements (6.7) | wording at the merge (E-B4). **Applied in Revision 3** (A 8.5 and an E.9.5 wording note; no interface change) |
| X9 | A gave ScaleLogicalX/Y an exit probe for B; B computes the value itself | A may drop the exit (A-B9 note); no behaviour change either way. **Revision 3:** with the `int16_t` cast of 8.2 (RV2-15) B's value equals the core's AX for every argument |
| X10 | The T4 setup page needs the Go Back text before the core's dialog 144 exists; B uses a Windows-template constant cited from claude/docs (B21) | Accept; a mismatch with the core's text is counted and redrawn (11.5) |
| X11 | Revision 1's 16 row tied C's I5 conversion to B's L(d); C converts by the core's own rule (C.14) | corrected (16) |

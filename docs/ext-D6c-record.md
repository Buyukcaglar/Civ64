# Extension phase D6, unit D6c (the DOS map rules in view: `pmap_dos`; the dos-settled check) - record

Draft for the build slot (BRIEF-d6.md "Units" D6c).  Staged in `build/d6c-stage/` on the tree after the D6b
landing (build/d6b-status.txt ALL_GREEN, 07:09 UTC); the bases were copied 07:27 UTC.  The D5 gate's files
(D5f + D5cR + D5eR, copied in about 07:49 UTC, build/d5-gate-status.txt ALL_GREEN 08:37 UTC) and UX2's
(ALL_GREEN 09:34 UTC) touch none of them; every base is rechecked equal to the tree in `BASE-SHA256.txt`.  A
first staging agent was stopped at 08:22:33 UTC with the code staged; this session reviewed its stage hunk by
hunk against the bases and the listing, corrected the tests, finished the harness and ran every private check
below.  Private builds and runs
in `build/d6c-stage/obj/` only (an overlay `obj/src` = tree + stage, built with build.cmd's own flags).

## Status

LANDED 2026-10-16 (ALL_GREEN 10:15 UTC, section "Landing").  Draft D 14.0..14.6 is built as the DOS rule
set of the map display model
(`present/map/pmap_dos.c`, new): the square's layers of 14.2 in the listing's order (R:1AEA:03BA), units (14.3,
R:1AEA:0E29 / 0FB3 with the sentry recolour), cities (14.4), labels (14.5), the move and combat frames at the
core's pace (14.6), DOS art at scale 2 through k = 2 ports (14.1); P_dos, S_dos and Wn_dos drawn, and Wn_dos
composed on the A canvas as the map element (draft B 6.2, 7.5's last bullet; D 17 B-2); draft D 10.1's
dos-settled check under `--mirror 2`.  Open D3 is settled from the listing; D6 / OB4 / L23 (the label and digit
font) are not settled by it (font 1 kept, inferred).  Privately: test_map passes in the three variants (208
checks in Checked and Release), ext_mirror MIRROR_OK in 29 runs with dos-settled 86 checks, 0 mismatched, 0
DOS unexplained and every Windows-rule total unchanged; P0 holds (core frames, snapshots, results and events
identical) in the 27-run DOS comparison and in ext_p0's DOS variations; the Windows profile's samples are
unchanged; the DOS profile's frames change from the first map show on (the map is now DOS art: user-visible,
section "What the user checks").

## What was built

### The DOS rule set (`present/map/pmap_dos.c`, new; draft D 14.0..14.6)

* **Art (14.0).** Shapes from area E's `pdos_shape(PDOS_SH_<family>, DOS index)`: terrain B886 (`16 T + mask`,
  E's TER257 row rule inside `pdos_shapes`), coast quarters D294, river mouths D2D4, roads B27A and railroads
  B29A, rivers 6DFE, unexplored edges 7EEC, the grassland marker B880, icons and units D4CE, citizens 6E96.  The
  page-2 rectangles from `pdos_pic(PDOS_F_SP299_PIC)` at their page-2 coordinates (O5:1484..14A4 copies SP299.PIC
  (160, 50, 160 x 150) opaquely to page 2): the whole-square coasts (E0h + 10h j, 64h) j 0..5 (R:1AEA:0635..072B)
  and the land base (100h, 78h) (R:1AEA:07B2..07CD), copied opaquely (G#20).  The civilisation colours
  DGROUP:1946 (main) and 1956 (secondary) through the registry (`PDOS_T_CIV_MAIN_COLOUR`,
  `PDOS_T_CIV_SECOND_COLOUR`), their low byte (G#3 and the fill take the low byte).  Every drawing constant
  cites its R:1AEA address in the source.  A missing shape or picture draws nothing and counts `no_art` (0 in
  every run).
* **Positions (14.1, Choice B23).** A k = 2 `PdosPort` on the shadow's surface whose origin carries the map
  position's parity (`pen_at`): DOS pixel (i, j) of a square at map pixel (sx, sy) covers map pixels
  (sx + 2i, sy + 2j) and the next.  An odd map position is drawn with its parity and counted `odd` (0 in every
  run: the core's positions are even).
* **One square (14.2; R:1AEA:03BA).** Layers 1 (ocean quarters from the 8-neighbour land mask, x wrapped, rows
  on the map; `m9 = (mask << 2) + ((mask >> 6) & 3)`), 1a (whole-square coasts for masks 1Ch, C1h, 07h, 70h,
  8Fh, F8h), 1b (river mouths N, E, S, W, x wrapped, no row check), 2 (land base), 3 (irrigation: I & 2, not
  ocean, DCFC clear, not a city), 4 (river: the N/E/S/W River-or-Ocean mask, no wrap, + 16 unless the page-2
  byte (x, y + 96h) has bit 8, read as the core's `g_lpScreenBuffer` (x, y + 150); masks 0 and 16 are not cut
  and draw nothing), 4' (other land: B886[16 T + mask], x wrapped, rows on the map), 5 (the grassland marker at
  (4, 4) for `((7x + 11y) & 2) == 0`), 6 (pollution D4CE[6]), 7 (roads/railroads: per direction B29A[d - 1]
  when both squares have the city or railroad bits (11h), else B27A[d - 1]; none: the 2 x 2 dot at (7, 7),
  colour 0 with a railroad, else 6), 8 (mine, DCFC clear), 9 (special D4CE[16 + T] by the core's
  `HasSpecialResource`), 10 (hut D4CE[31] by the core's `HasHut`), 11 (fortress D4CE[30]), 12 (unexplored edges
  7EEC[d / 2] by the core's fog decision 1110:065B: not in the city-screen map, draw mode not 2, the human
  player's bit), 13 (the city, DCFC clear).
* **Cities (14.4; R:1AEA:0C38..0DE7).** Outline (1, 1, 13, 13) colour 15; outline (2, 1, 12, 12) in 1956[owner];
  fill (2, 2, 12, 12) in 1946[owner]; D4CE[1Ch] at (1, 1); G#3 5 -> 1956[owner] over (2, 2, 12, 12); the size
  (the real one for the player's city, else the known one, signed) at (6, 5), or (3, 5) from 10, colour 0, or
  the disorder shape 6E96[4] at (5, 2); outline (0, 0, 15, 15) colour 0 when a unit (the core's
  `FindUnitAtTile`, read-only) or a stored unit (record + 1Ah not FFh) is there; walls D4CE[1Dh] at (1, 1).  A
  foreign city with known size 0 is skipped (R:1AEA:0C1C..0C35, D806 0).
* **Units (14.3; R:1AEA:0E29, 0FB3).** The core's unit (the macro's argument).  For DrawUnit (`MW_UNIT_STACK`):
  on ocean a sentried unit whose domain is not 2 is carried and not drawn (R:1AEA:0F3C..0F55, the same decision
  as the core's DrawUnit 1110:0ECE); another unit in the stack draws D4CE[40h + 20h civ + type] at (1, 1)
  first.  Then the shape at (0, 0); fortified D4CE[1Dh]; fortifying "F" shadowed at (4, 7); the player's unit
  with a goto target "G"; working non-air units their letter (R, I/?, M, F, P as R:1AEA:109D..1172) with the
  outline (-1, -1, 15, 15) colour 7; ink colour 9 for civ 1, else 15; sentry: G#3 5 -> 7 then 8 -> 7 over
  (0, 0, 16, 16) (R:1AEA:1191..11CC).  DrawUnitAt (`MW_UNIT_AT`) draws R:1AEA:0FB3's part only.
* **Labels (14.5; R:1AEA:0008 step 4, R:1AEA:0132..0195).** For each label of the core's list: drawn only when
  `sy + 32` is inside the client (DOS `py < B8h`); at x = `max(sx - 16, 0)` from the client's left edge,
  y = `sy + 32`; the folded name (Choice B13) truncated by R:1F4D:04F7 to `floor((Cw + 14 - sx) / 2)` DOS pixels
  (DOS `147h - px`, the DOS map's right edge replaced by the client's); shadowed text in colour 11.
  `pmap_dos_label_box` gives the label's own box (the text width and the font's line height plus the shadow
  row, at 2x) for the redraw rule below.
* **Move and combat frames (14.6).** `pmap_dos_sprite(index, ...)`: D4CE[index], the DOS counterpart of
  `g_mapSprites[index]`, at the DrawTile position.
* **Clipping.** Every primitive is clipped to the shadow (G#6 for G#32's sprites; G#20's copy, G#3 and the fill
  limited to the port); the fill is a plain fill of its rectangle (R:0000:0BFA's one-row skips at the DOS
  screen's column 0 and span column are DOS-screen effects the map never reaches).
* **The map element (draft B 6.2; D 6.2, 17 B-2).** `pmap_dos_present`, at every core present after the map
  window is read (`pmap_on_core_present`, after the present check): Wn_dos (the DOS rule set's shadow of the
  map window's client) on the A canvas at the client's position, id the map window's handle, compose scale 1
  (Wn_dos is at map pixels, the DOS art already at 2x), opaque, `rgb8` NULL (the play palette of the A machine,
  so it is reconverted at each step of D4a's `CyclePaletteColors` wiring), clipped to the client's visible
  region and excluding what is drawn on the screen over the windows (an open menu's popups and the move or
  size outline:
  `pmap_screen_exclusions`, shared with the present check).  Set only when something of it changed; removed
  when the window is hidden, iconic, empty or has no visible region, when its region has more than
  `PDOS_CLIP_MAX` rectangles (`clip_over`), and before the shadow's surface is freed.
* **CIV_OBSERVER 0**: `pmap_dos_present`, `pmap_dos_reset` and `pmap_dos_diag` are stubs.

### The model (`present/map/pmap_model.c`; draft D 9.3, 9.4)

* **Macros (9.3).** In the DOS rule set the four DROP macros now draw by pmap_dos.c from live state at the
  entry: DrawMapTile 1110:04D0 (the square; with `g_autoFlushToWindow`, the labels whose DOS box meets the
  flush's rectangle, the game's SectRect 1110:0CF1 of the square and the window data's client rectangle),
  DrawUnit 1110:0DBA (R:1AEA:0E29 at `unit_square`'s position), DrawUnitAt 1110:0FF6 (R:1AEA:0FB3 at
  MapLogicalPointToPort 1220:101E's position), DrawCityLabels 1208:1F64 (the core's list, `g_cityLabelCount`
  1408:0000, every label whose DOS box meets the update rectangle, whole).
* **Non-macro events (9.4).** A window draw into a DOS map shadow: a black brush's fill (the model's
  `black_brush` rule, D6a) is DOS colour 0 where it reached the surface (`dos_fills`); anything else draws
  nothing and is unexplained (`dos_unexplained`, the engine's DOS count too, a `unexplained dos-draw` line under
  `--mirror 2`).  A copy into a DOS map shadow: DrawTileImpl's last copy (11A8:135F) of a frame drawn at its
  entry is explained; a SRCCOPY between DOS map shadows is copied where it reached the destination
  (`dos_copies`); anything else is unexplained (`dos-copy`; B7: never pasted).  Raw bits into a DOS map shadow
  outside the macros: unexplained (`dos-bits`), never pasted.
* **DrawTile 11A8:0CB1 (entry probe) into P or S outside a DOS DROP bracket.** The handle's index in
  `g_mapSprites` (1420:9350, 320 handles, read at each frame) gives D4CE[index]; a handle not in the table (a
  temporary copy) inside AnimateUnitMove 11C0:2C32 or ResolveCombat 1050:0000 gives the context's unit,
  D4CE[64 + 32 civ + type] (`dos_tile_ctx`); drawn at the DrawTile position, its last copy explained.  Outside
  those contexts the frame is unexplained (`dos-tile`, Open D5); on the scaled port nothing is drawn
  (`dos_scaled`).
* **Free hook.** A DOS map shadow about to be freed forgets its pending DrawTile copy and removes the map
  element that shows it first (`pmap_dos_surface_freed`).
* `dos_deferred` is no longer counted (0); its field stays in the end line.  `pmap_model_black_brush` exports
  the fill rule for the dos-settled replay; `pmap_dos_reset` runs in the model's registration.

### The dos-settled check (`present/map/pmap_check.c`; draft D 10.1)

Under `--mirror 2`, at every settled call (DrawTilesToPort 1208:1866 modes 0 and 1, and RedrawMapRect: the
D6c decision, the same calls as M's settled check) P_dos (the DOS shadow of the map port's bitmap) is copied
at the entry (black when the shadow does not exist yet; a P_dos of another size than the bitmap skips the
check, `dos_skipped`).  At the exit the copy is redrawn by the DOS rules in the core's order of the same calls
(`replay_ops`, now shared by the settled and dos-settled replays): the squares (DOS layers and DrawUnit's
rules), the black of an unseen square or an erase (DOS colour 0, the model's brush rule), the labels of the
core's list by the DOS label rule and box; then compared with P_dos.  A mismatch writes `mirror N virtual_us
US kind dos-settled rect l t r b MISMATCH pixels P first x y core C ours O`; ok checks are counted.  The end
line adds `dos_settled D dos_mismatched X dos_skipped K dos_unexplained U` and the DOS rule set's counters
(`dos_squares dos_unit_draws dos_label_calls dos_fills dos_copies dos_tiles dos_tile_ctx dos_tile_unknown
dos_tiles_outside dos_bits dos_nothing dos_scaled dos_drawn_squares dos_drawn_units dos_labels dos_sprites
dos_no_art dos_odd dos_elem_sets dos_elem_removes dos_clip_over`; the `dos_drawn_*`, `dos_labels` and
`dos_sprites` counters are pmap_dos.c's and include the replay's drawing).  The present check's screen
exclusions moved into `pmap_screen_exclusions` (unchanged behaviour), shared with the map element.

### The A canvas (`present/dos/pdos_compose.c/.h`) and the wiring

* `PdosElem` gains `nexcl` and `excl[PDOS_EXCL_MAX]` (12: the 7 popups of 8 menu levels and an outline's 4
  strips): canvas pixels inside an exclusion are left to the canvas below.  A zeroed element has none, so every
  existing element (all are memset before use) is unchanged.
* `pmap_inview.c`: one call, `pmap_dos_present()` after `pmap_check_present` in `pmap_on_core_present`.
* `pmap_int.h`: the DOS rule set's API, `PmapDosDiag`, the D6c counters of `PmapModelDiag`, the `PMAP_DL_*`
  trace steps and the test seam `PmapDosRes` (art, colours and a trace of every drawing step).

### Harness (`tests/harness/ext_mirror.py`)

Also requires `dos_mismatched 0` and `dos_unexplained 0` in every run and, in every run that reaches the map,
at least one dos-settled check; the per-run line and `MIRROR_TOTAL` add `dos_settled dos_mismatched
dos_skipped dos_unexplained dos_squares dos_unit_draws dos_tiles` (and `dos_label_calls` in the total).

## Open D3, D806, D6 / OB4 / L23 (from the listing)

* **Open D3 (DGROUP:DCFC) settled.** The listing writes DCFC at two places only: R:0403:37AB (1) and R:0403:37C9
  (0), around one full map redraw, reached from the key dispatch at R:0403:3B47..3B4C (`cmp ax, 74h`, the 't'
  key).  The core's counterpart is the same key: 11F0:3E87 't' (Hide Units) sets `g_mapDrawMode = 1`, redraws
  the map and waits for a key or click.  So "DCFC clear" is `g_mapDrawMode == 0` (layers 3, 8, 13), now from
  the listing, no longer inferred.
* **D806 (reveal all).** Every instruction of the listing that names DGROUP:D806 is a compare with 0 (34, e.g.
  O10:0184, O12:007B, O13:0792, R:0238:1112, R:0403:099B); none writes it, and it lies above DGROUP:6B30h,
  the end of the initialised data (start-up zeroed, inferred): in the DOS program it is 0 (an indirect write is
  not excluded by this search; none is known).  The DOS rules take it as 0 (the foreign known-size-0 city skip,
  the edges by the core's fog decision); the draft's inferred counterpart `g_revealAll` (12D8:4302) is not used
  (section "Deviations").
* **D6 / OB4 / L23 (the label and digit font).** Not settled: R:1AEA:0008, 03BA and 0FB3 set no font; the font
  is whatever play last set.  Area B's font 1 in play (draft B 10.1, decision X5) is kept, inferred
  (`LABEL_FONT 1`).

## Tests

* `tests/test_map.c` (the brief's 16.1 "DOS composition order on a synthetic square set"; the test's own art
  and font, no DOS byte; `dos_rules()` after `model()`), 62 new checks:
  * through the trace seam, each layer of 14.2 in its order with its family and DOS index: an ocean square
    with its N neighbour land (mask 01h, m9 4: quarters D294[16], [5], [2], [3] at (0, 0), (8, 0), (8, 8),
    (0, 8)), row 0 (no land bit off the map), E/SE land with a S river (mask 1Ch: the quarters, the whole-square
    coast, the mouth); a land square with every layer but the river, the hut and the city (2..12 in order);
    road and railroad (rail to the E with both 11h, a road to the N; a lone road's dot in colour 6, a lone
    railroad's in 0); the land base's pixels at 2x from page 2 (100h, 78h); the river (mask 3 + 16 without the
    page-2 bit: 6DFE[19], with it [3]; a lone river draws nothing); a hut; cities (the player's size 12 with
    walls and a stored unit, a foreign city of known size 0 skipped, disorder, the colours); units (the stack
    shadow, the carried rule, fortified, F, G, the work letters with the outline, the sentry recolour); labels
    (the clamp, the bottom rule, the truncation to `147h - px`, the box); the move and combat shapes, an odd
    position, the left clip, nothing for an empty clip;
  * through the model and the engine: DrawMapTile with and without the flush (the flush's P -> Wn copy between
    DOS shadows), DrawUnit, DrawUnitAt, DrawCityLabels, a black fill (DOS 0), an unexplained pixel, DrawTile
    frames inside AnimateUnitMove by `g_mapSprites` and by the context's unit, outside the contexts
    (unexplained), the scaled port, raw bits (unexplained, never pasted); the map element (set once for an
    unchanged present, the A frame with Wn_dos over the client and the core frame elsewhere, the move outline's
    four strips excluded, removed for a hidden window, refused past `PDOS_CLIP_MAX`, removed before its surface
    is freed).
  * One D6a check changed: "a pixel outside the macros" is now also unexplained by the DOS rule set
    (`pdos_shadow_unexplained_rs(PDOS_RS_DOS)` + 1, `dos_unexplained 1`, an `unexplained dos-draw` line) and
    `dos_deferred` is 0 (D6a absorbed it).
* `tests/harness/ext_mirror.py`: 7.5's dos-settled check and DOS unexplained 0 (above).

## Results (private, `build/d6c-stage/obj/`)

* Builds (final, from the normalised stage, `obj/final.sh`): build.cmd's three variants of the overlay
  (`--nogen`), strict C17/x64 and the c11/c17/C99 parse of the 291 portable sources: BUILD_OK each.  cc.cmd's
  stricter checks (c11 and c17 /W4 /WX, the clang C99 parse with -Wextra; tests included) on `pmap_dos.c`,
  `pmap_model.c`, `pmap_check.c`, `pmap_inview.c`, `pdos_compose.c`, `tests/test_map.c` and
  `tests/test_pdos_compose.c` in the three variants: CC_OK each.
* Unit tests (`<gamedata> <outdir>` under the stage): all 45 programs pass in Checked, CheckedNoObs and Release;
  test_map 208 / 1 / 208 checks (the tree's 146 / 1 / 146), test_pdos_compose 68 in each (unchanged); every
  other count compared with the tree's last Checked unit log is unchanged.
* `obs_lint.py` over the overlay: OBS_LINT_OK files 115 probes 203 callsites 98 (tree: 114).  `testpar.py check`
  on the overlay's test.cmd with BUILD-TEST-ADDITIONS.md applied: exit 0; `list`: `ext_mirror
  after=ext_p0,uninit cpu=4 est=140` (unchanged).  `gen/dos/registry.py check` on the overlay (the tree's
  build/dosdata and listings read): REGISTRY_OK, 0 failures.  `gen/dos/nodos.py check --variant Checked --root
  obj/src`: NODOS_OK (599 files, 242,686,494 bytes, 0 hits).
* `ext_mirror.py Checked` (the staged runner with the overlay's harness, `--root` under obj, the tree's
  build/gamedata, build/dosdata and V0 references read; `obj/runmirror.py`, -j 3): MIRROR_OK runs 29;
  MIRROR_TOTAL checks 21706 key 6925 render 1229 settled 86 present 13380 present_mismatched 0 unexplained 0
  squares 6601 unit_draws 3148 tiles 660 tiles_outside 0 dos_settled 86 dos_mismatched 0 dos_skipped 0
  dos_unexplained 0 dos_squares 6601 dos_unit_draws 3148 dos_label_calls 17990 dos_tiles 660; p0 equal in all
  29.  Every Windows-rule total equals the tree's (checks 21620 + the 86 dos-settled checks).  Over the 29
  end lines: dos_fills 20179, dos_copies 23753, dos_tiles 660 (dos_tile_ctx 0, dos_tile_unknown 0,
  dos_tiles_outside 0), dos_bits 0, dos_nothing 6147, dos_scaled 0, dos_no_art 0, dos_odd 0, dos_drawn_squares
  10756 (6601 by the macros + the dos-settled replays), dos_drawn_units 3380, dos_labels 392, dos_sprites 660,
  dos_elem_sets 690, dos_elem_removes 5, dos_clip_over 0; `dos_deferred 0` (the tree's end lines: 50,739 over
  the 29 runs).  Rerun on the final build (`--ref` the private V0 outputs, so the two soaks' p0 is n/a):
  MIRROR_OK runs 29 with the same totals, p0 equal in the other 27.  Harness CPU over the 29 runs on a quiet
  machine (`obj/cputime.py`, GetProcessTimes of every harness process, -j 3): 225.6 s with D6c (105.1 s wall)
  against 222.3 s (104.0 s) with a private copy of the tree's harness, about 1.5 % more; on s4, s5, load and
  menus with and without `--mirror 2` likewise within 1 to 2 %.
* P0 (`ext_p0.py Checked`, the tree's runner with `--exe` the overlay's harness, `--root obj/run/p0root`,
  `--port` the tree, -j 2; variations V0, V1, V2, V6, V6r, V6w, V7, V8, V8s, every DOS variation, with D5f's six
  runs in V0..V2): P0_OK checks 312 (V0 equal to ext-g1-baseline where listed; every DOS variation's core trace
  equal to V0 with the DOS map drawn; switch, chord, Birth-synchronisation and `pdos_rows` assertions held).
  V3/V4 (Windows-only, no `--dos-data`: the DOS rule set is not registered) not rerun.  `ext_replay.py --root
  obj/run/p0root`: REPLAY_OK checks 70 (the tree's count).
* 7.4 (`ext_frames.py`, the tree's runner with the overlay's harness and every output under obj,
  `obj/runframes.py`, -j 3): EXT_FRAMES_OK: on start, s3 (reaches play: the DOS map drawn) and birth the sample
  lines of A, A', B (`--switch-every 997`) and C (`--graphics windows`) are identical (299, 719, 2049 lines),
  presented.log of A equals A', the switch assertions hold, A shows the DOS profile through the tick only; the
  dump check holds (496 tick BMPs of 8 and 24 bits).
* The DOS profile before/after (`obj/dos_cmp.py`: the tree's Checked harness (D5 gate build) against the
  overlay's on the 27 ext_p0 runs with V1's options `--dos-data build\dosdata --graphics dos --presented 1` plus
  `--profile-samples 100`, -j 3): DOSCMP_OK 27.  In every run run.log's frame lines, snapshots and result and the
  whole events.log are equal (P0), every Windows sample hash is equal (`windows_diff 0`), and the
  presentation-diag.log lines `pdos`, `pmap`, `replay` and `bs` are equal (host-time fields aside; `unexplained`
  unchanged, 52 in `load`).  The DOS samples and presented.log differ from the first map show on: 24.90 s in the
  runs from a saved game (load, menus, revolution, retire, orders, research, research2, quiz, spaceship,
  conquest, arrival, pollution, unload, city, s2, s2b, s2c), 37.70 s in new, settlers, s3, 39.70 s in earth,
  43.70 s in custom; no difference in start, birth, fame-quit, fame-reload and display16 (no map shown).  This
  comparison ran on the harness before the final one-line change (`memcpy` for the element copy in
  `pmap_dos_present`, the same code on MSVC); P0, ext_frames, the unit tests and the rerun of ext_mirror ran on
  the final build.
* A visual sanity check (not a user check): the DOS-visible frames of `load` dumped by the overlay's harness
  (ticks 400 and 634, 640 x 480) show the map client in DOS art at 2x: terrain, coasts, units in their colours with
  marks, the city with its size and "Rome" in cyan with its shadow; the World Map and Status windows stay
  Windows-style (D6e).
* Not run privately: `ext_timeline`, `ext_continue`, `ext_adapt`, `ext_zoom`, `bs*`, `ext_g1` (the core and the
  intro, Birth and setup frames are unchanged above), the Asan variant (deferred).  The private runs after
  09:30 UTC used a private copy of the tree's harness (`obj/treeexe`) so as not to hold the tree's executable
  during a build slot.

## Expected changes at the build slot

* Unit: test_map 146 -> 208 checks (Checked, Release; CheckedNoObs 1 unchanged); every other unit count
  unchanged.
* obs_lint `files` 114 -> 115; portable sources 290 -> 291 (relative to the tree at writing).
* `ext-mirror.txt` (section `ext_mirror`): each `MIRROR` line gains `dos_settled dos_mismatched dos_skipped
  dos_unexplained dos_squares dos_unit_draws dos_tiles` before `p0`, and its `checks` count adds the run's
  dos-settled checks (e.g. s2c 206 -> 208); `MIRROR_TOTAL ... checks 21620 -> 21706` with the same key, render,
  settled, present, unexplained, squares, unit_draws and tiles totals and the new fields `dos_settled 86
  dos_mismatched 0 dos_skipped 0 dos_unexplained 0 dos_squares 6601 dos_unit_draws 3148 dos_label_calls 17990
  dos_tiles 660`; `MIRROR_OK runs 29` unchanged.  Its time grows by about 1.5 % (above); the list line's
  `est=140` is kept.
* Each run's `mirror.log` end line: the new fields after `bevels` (above); `dos_deferred` 0 (was 50,739 in all);
  the `mirror N` numbers of mismatch lines count the dos-settled checks too (no mismatch line is written in the
  29 runs).
* The DOS profile's frames in play (the map client): `profiles.log` DOS `sample` hashes and presented.log of
  DOS-visible runs differ from the first map show (times above); no golden holds them (ext_timeline's goldens
  are the DOS intro and Birth, unchanged; ext_zoom's are the Windows profile's; ext_frames compares within a
  run).  Windows samples, the intro, Birth and setup frames, presented.log of Windows-visible runs, every core
  output, G-1 fields and `ext_g1.py check`: unchanged.
* `nodos.txt`: the scanned file and byte counts grow by the new source and the larger binaries; NODOS_OK.
* Coverage ("other functions entered"): informational, not measured privately.

## Rebase notes

* All bases equal the tree at writing (`BASE-SHA256.txt`; the D5 gate's copy-in changed none of them).  The
  `extension D6c` blocks are delimited where they add more than a line; one-line hunks carry an `extension D6c`
  comment.
* No other stage in `build/` holds any of D6c's files.  UX2 (landed during this staging, ALL_GREEN 09:34 UTC)
  changed `platform/win32/host_win32.c/.h` only: disjoint, not a portable source; the bases were rechecked after
  it and the counts below hold.
* Later D6 units share files: D6d (`pmap_dos.c`, `pmap_inview.c`, `test_map.c`: the DOS ring takes
  `pmap_dos_square` / `pmap_dos_unit` / `pmap_dos_label` with its own edge rules, 14.5 "In the DOS ring"); D6e
  and D6f (`pdos_compose.c/.h`: the status and small-map elements and D5b's re-skins on the A canvas).  The
  `PdosElem` exclusions are zero for every element that does not set them.
* Shared counts: obs_lint files (114 -> 115), portable sources (290 -> 291).

## Build-slot steps

1. Copy the staged files (`BASE-SHA256.txt`'s list; `present/map/pmap_dos.c` new) and this record into the
   tree; apply BUILD-TEST-ADDITIONS.md to test.cmd (the `ext_mirror` section's comment block and echo; its list
   line and build.cmd unchanged).
2. The three-step cycle: `build.cmd checked` (portable sources 291), `test.cmd checked` (`unit`: test_map 208;
   `ext_mirror`: MIRROR_OK runs 29 with the new totals; every other section as before), `ext_g1.py check`
   (EXT_G1_OK unchanged: the core is untouched).
3. The user build for the visual check (section "What the user checks"): the coordinator's, from the landed
   tree (Release).

## Decisions within the brief

* **Clipping to the shadow** (above): G#32 draws the DOS map unclipped inside the DOS screen; here every
  primitive is clipped to the surface, which is G#32's result wherever the surface has the pixel.
* **Labels redraw whole by their DOS box.** DrawMapTile's flush and DrawCityLabels draw every label whose DOS
  box (the DOS text's own pixels) meets the rectangle, whole: a square drawn over part of a DOS label redraws it
  (the Windows box `(x, y + 32, x + 166, y + 52)` is the Windows label's, not the DOS one's).
* **Labels at the core's DrawCityLabels and flush** (draft 14.5 "When"): the DOS program draws labels only at
  its full redraw; recorded under "For the records".
* **dos-settled also at RedrawMapRect**: the same calls as M's settled check, so the two checks cover the same
  states.
* **`g_mapSprites` read at each DrawTile frame** (640 bytes): a loaded game cuts new handles, so a table read
  once per run would go stale.
* **A temporary shape is the context's unit** (D4CE[64 + 32 civ + type]; for ResolveCombat the attacker, its
  arguments 0 and 1): the core draws grey copies of the moving unit; no such frame occurred in the 29 mirror
  runs (`dos_tile_ctx 0`), so the rule is exercised by the unit test only.
* **The exclusions live in `PdosElem`** (an element field rather than a map-only clip): the move outline and
  the menu popups are drawn on the screen over every window, so any later A element over a window needs them.
* **Palette.** The map element's `rgb8` is NULL, so it follows the A machine's play palette: D4a's wiring steps
  the play palette's slots at each `CyclePaletteColors` 1208:22B7 (`pdos_profile.c`) and pdos_compose
  reconverts every such A element on a new palette generation, so the DOS map's cycling colours move at the
  core's pace from D6c on with no new hook (14.7's part for the DOS ring layer stays D6d's).
* **Element changes only**: the element is given to pdos_compose only when its rectangle, clip, exclusions or
  surface size changed (compared bytewise, the element memset and copied whole); 690 sets over the 29 mirror
  runs.

## Deviations from the design

* **D806** (draft 14.2: "the core's `g_revealAll` (12D8:4302), inferred counterpart"): taken as 0 from the
  listing (no writer).  Effect: if the core ever sets `g_revealAll`, the DOS view still skips foreign cities of
  known size 0 (the core's own city marker rule 1110:072B does the same) and draws the edges by the core's fog
  decision.
* **No Wn_dos reference check.** Draft D 10.1's dos-settled check is on P_dos only (as specified); Wn_dos has no
  core counterpart to compare with, so the map element's content is covered by the copies from P_dos (each
  `dos_copies` copy is a SRCCOPY between DOS shadows, `dos_unexplained 0`) and by the user's visual check.
* Files beyond the brief's list: `present/dos/pdos_compose.h` (the element's exclusions), `pmap_inview.c` (the
  one call).

## User direction 2026-10-16 (no added Go Back / Cancel rows) and checklist item D5-7

* D6c adds no row, box, dialog or menu and draws nothing over any dialog: the map element is clipped to the map
  client's visible region, which excludes every window over it (a dialog is a window), and to the screen
  exclusions.  No Escape mapping is needed and none is recorded.
* Checklist item D5-7 (the first D6 unit that makes a re-skinned DOS menu or message box visible in play names
  the screen, steps, dialog and user build) is **not D6c's**: D6c shows no re-skinned box; D5b's re-skins reach
  the A canvas in play with D6f (BRIEF-d6 decision 1).  Note for D6f: elements on the A canvas compose in
  insertion order and a re-set keeps an element's place, but the map element never covers another window's
  area (its clip is the client's visible region), so a box's element over a dialog is not hidden by it.

## What the user checks

The first user-visible D6 change: in the DOS profile the main map window's client shows the DOS map.  On the
coordinator's user build of the landed tree (`civ64.exe`, DOS files present): start with `--graphics dos` (or
switch with Ctrl+Shift+Backspace), then load a saved game or start a new one (the checks hold for both).

1. **Terrain.** Every square in DOS art at twice its size: the land base and the terrain shapes (grassland with
   its small marker on alternate squares, forests, hills, mountains; tundra, arctic, swamp and jungle without
   neighbour joins, the DOS rule), oceans with their coast quarters and whole-square coasts, rivers and river
   mouths, roads and railroads, irrigation, mines, specials, huts, fortresses, pollution, and the
   DOS unexplored edges along black unexplored squares.
2. **Cities.** A white outline, the civilization's colours, the size digits (black), walls, a black frame when a
   unit is inside; a city in disorder shows the disorder figure instead of the size.
3. **Units.** DOS unit shapes in their civilization's colours; a stack shadow when several units share a square;
   the marks: fortified, "F" (fortifying), "G" (going to), work letters with a grey frame; a sentried unit and
   the terrain under it greyed.
4. **City names.** Cyan with a dark shadow below each city, cut at the map's right edge, not past its left edge.
5. **Motion.** Moving a unit and a combat (the attacker's lunge and the explosion) in DOS art at the game's pace;
   scrolling and centring the map; the blinking of the active unit; the DOS art's cycling colours
   (palette slots 96..127) stepping at the game's pace.
6. **Over the map.** Open a menu over the map and move or size the map window: the menu and the outline are
   drawn over the DOS map (not hidden under it); a dialog over the map covers it as before.
7. **Switching.** Ctrl+Shift+Backspace during play: the Windows map unchanged; back again: the DOS map.

Not yet DOS (later units, not part of this check): the World Map (small map) and the Status window and unit
panel (D6e); the zoom levels -1 / +1 and the ring in the DOS profile (D6d); the menu bar and drop-downs and the
message boxes in play (D6f); the city screen and the other in-game screens (D7).

## For the records

* DESIGN 12.9 "As implemented (D6c; area D)": `pmap_dos.c`, the DOS rule set of the model (above), its events
  outside the macros (black fills, copies between DOS shadows, DrawTile frames by `g_mapSprites` and the
  context's unit, unexplained otherwise, never pasted), the dos-settled check, the map element on the A canvas;
  12.7 (area B's compose): `PdosElem.nexcl/excl` (the screen exclusions of an A element).
* Draft D 14.2: Open D3 settled from the listing (DCFC written only at R:0403:37AB / 37C9 around the 't' key's
  redraw, R:0403:3B47..3B4C; the core's 11F0:3E87 't' sets `g_mapDrawMode = 1`): "DCFC clear" is
  `g_mapDrawMode == 0`, no longer inferred.  D806 has no writer in the listing: taken as 0, not `g_revealAll`
  (deviation above).  14.3 / 14.5 and Open D6 / OB4 / L23: the listing sets no font in R:1AEA:0008, 03BA,
  0FB3; font 1 stays inferred.  14.5: labels redraw whole by their DOS box.  14.6: a temporary DrawTile shape
  is the context's unit.  9.4: the DOS rule set's event rules (above).  10.1: dos-settled also at RedrawMapRect;
  a P_dos missing at the entry is black, one of another size is skipped; the end-line fields.  Open D5 for the
  DOS rule set: `dos_tiles_outside 0`, `dos_bits 0` in the 29 runs.
* Draft B 6.2 / 7.5 last bullet: Wn_dos is the A canvas's map element (k 1, the play palette, the client's
  visible region less the screen exclusions).
* DOS-PROFILE.md row 96 (the map, class A): the map client done; the small map and status window D6e, the ring
  D6d.  OPEN L2 (D806): never written in the listing, taken as 0; Open D3's DCFC part settled as above.
* FIDELITY (DOS/Windows and DOS-view differences, all inherited from draft D 14 and now visible): the core's
  decisions over DOS formulas (which unit, specials, huts, fog, the carried rule); the river's + 16 by the DOS
  rule on the core's page-2 bit; the TER257 row rule (tundra, arctic, swamp and jungle ignore their neighbours in
  the DOS view only); labels drawn at the core's DrawCityLabels and flushes (the DOS program draws them only at
  its full redraw); the dissolve, blink, move (9 frames of 4 map pixels) and combat at the core's pace and order,
  not the DOS 17 one-pixel move frames or 10/10 blink; D806 0; the label and letter font 1 (inferred); every
  primitive clipped to the map shadow.
* RUNNING: `mirror.log`'s end line gains `dos_settled dos_mismatched dos_skipped dos_unexplained` and the DOS
  rule set's counters (above), `kind dos-settled` mismatch lines; `ext_mirror.py`'s requirements and
  `MIRROR_TOTAL` fields (above; time about 1.5 % more, `est=140` kept); the `--graphics` text ("the DOS profile shows
  the DOS intro and title box and otherwise the Windows picture"): the main map window's client is DOS now.
* STATUS: D6c done; the DOS map is visible in play; user check pending ("What the user checks"); D6d next.
* manual-checklist-ext.md: D6c's seven checks above.  Item D5-7 stays open for D6f (section above).
* User direction 2026-10-16 (no added Go Back / Cancel rows): nothing added by D6c, nothing to record.

## Landing (2026-10-16, build slot)

Landed after the UX2 docs pass (build/docs-ux2-done.txt, 09:49:53 UTC, not BLOCKED), by the orchestrator's
acceptance of about 09:55 UTC (the decisions: Open D3 from the listing, D806 as 0 recorded as a deviation, L23 /
OB4 left open, D5-7 to D6f).

* **Bases.** Every base re-verified against the tree at 09:50:56 UTC by `build/d6c-prep/land.py` (each tree file
  still had its listed base SHA-256, `present/map/pmap_dos.c` and this record were absent, each staged copy had
  its listed hash; test.cmd 1f9610eb..., build.cmd 40de571d...).  Before writing it snapshotted the Checked test
  outputs (`build/d6c-prep/before`, 30 files of build/test/Checked and sections), the 29 Checked mirror.log end
  lines (`before-mirror`), the 33 Checked V1 presentation-diag.log files (`before-diag`) and the tree's previous
  files (`tree-before`).  The 9 staged files and this record were copied byte for byte; manifest
  `build/d6c-prep/landed.sha256` (this record's hash there is the copy before this section was added; the
  record was then also normalised to LF like the other records).
* **test.cmd.** BUILD-TEST-ADDITIONS.md's change applied by `build/d6c-prep/patch_testcmd.py` (base 1f9610eb...,
  CRLF kept; now d924f55c..., the stage's result): the ext_mirror comment block and echo line; its list line
  (`est=140`) unchanged.  `testpar.py check test.cmd`: exit 0; `list` shows `ext_mirror after=ext_p0,uninit cpu=4
  est=140`.
* **The three-step cycle** (`build/d6c-prep/d6c-cycle.ps1`, detached, each step waiting on its own cmd.exe;
  status `build/d6c-status.txt`):
  1. `build.cmd checked`: exit 0, 203 s (09:51:05..09:54:28), BUILD_OK, portable sources 291
     (`build/d6c-1-build-checked.log`).
  2. `test.cmd checked`: exit 0, 1241 s (09:54:28..10:15:10), TESTS_OK, TEST_SECTIONS 25, failed 0, wall 1239.4 s
     (`build/d6c-2-test-checked.log`).
  3. `ext_g1.py check`: EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events), unchanged
     (`build/d6c-3-g1-checked.log`).
  ALL_GREEN.
* **Against the snapshot** (`build/d6c-prep/compare.py` -> `compare.txt`, host-time lines left out; 46 of 55
  files equal; `compare_mirror.py` -> `compare-mirror.txt`): every difference is a predicted one ("Expected
  changes") or host timing:
  * `ext-mirror.txt` / `sections/ext_mirror.log`: each MIRROR line gains the `dos_*` fields and its checks the
    run's dos-settled checks; `MIRROR_TOTAL runs 29 checks 21620 -> 21706`, every Windows-rule total equal,
    `dos_settled 86 dos_mismatched 0 dos_skipped 0 dos_unexplained 0 dos_squares 6601 dos_unit_draws 3148
    dos_label_calls 17990 dos_tiles 660`, p0 equal in all 29; the new echo text.  The 29 mirror.log end lines:
    only `checks` (+ the dos-settled checks) and `dos_deferred` (50,739 -> 0) changed among the old fields
    (MIRROR_COMPARE_OK); the new fields' sums equal the private run's (dos_fills 20179, dos_copies 23753,
    dos_nothing 6147, dos_drawn_squares 10756, dos_elem_sets 690, dos_elem_removes 5, the rest as above).
  * `sections/unit.log`: test_map 146 -> 208 checks; the OBS_COST line (host nanoseconds, informational).
  * `obs-lint.txt` / `sections/d3a_obs_lint.log`: files 114 -> 115.
  * `nodos.txt`: 1706 -> 1708 files, 1,521,083,692 -> 1,522,637,805 bytes scanned, 0 hits, NODOS_OK.
  * `coverage.txt` / `sections/coverage.log`: other functions entered 663 -> 662 (informational; the same
    one-function movement D5f's landing recorded between runs).
  * `sections/times.txt`: host times (ext_mirror 245.3 s in the UX2 run, 204.3 s here; wall 1362.5 -> 1239.4 s).
  * Unchanged: P0_OK checks 394, REPLAY_OK 70, EXT_FRAMES_OK, ZOOM_OK 32 / 64 / 388, EXT_TIMELINE_OK,
    EXT_CONTINUE_OK, EXT_ADAPT_OK 107, REGISTRY_OK and every other section output.
* **User build.** `build.cmd` (Release) after the cycle: exit 0, BUILD_OK, portable sources 291
  (`build/d6c-4-build-release.log`, 10:15:20..10:19 UTC).  `build/user-builds/d6c/`: civ64.exe from
  build/x64/Release (b4d8cce1...), CIVWIN.zip and civdos.zip copied from build/user-builds/d4/, and
  WHAT-TO-CHECK.txt (the seven checks of "What the user checks" in plain words, D6c-1..D6c-7; what is still the
  Windows picture in play, for D6d..D7; the open items of "ux2" and "d5").
* Not run in this landing: the CheckedNoObs, Release and Asan test variants (the three-step cycle), any UI check,
  any DOS program.  The user check is pending.

## Review (2026-10-16, after the landing; folded into D6d as D6cF)

The user's other chat verified D6c's palette cycling read-only against the listing (slots, direction, step, rate
against CyclePaletteColors 1208:22B7, cycles off, switching): as designed and matching the listing, no defect.
D6cR, a headless check of the same cycling, was cancelled before any fix was staged; its note
(`build/d6cr-stage/NOTE.txt`) found the cycling running in play (30 steps in 30 s, three blue colours rotating in
the map client).  The review's follow-ups are D6d's section "D6cF" (`docs/ext-D6d-record.md`):
* R2 (latent, fixed in D6d): `pdos_replay.c`'s nearest colour on the A machine's DAC no longer picks the cycled play
  slots 60h..7Fh; a test_pdos_replay vector fails before the fix and passes after.
* G2 (tests, in D6d): test_pdos_profile now asserts one step per CyclePaletteColors entry probe and none at its exit,
  phase 0 at WdwMapOpen's exit, stepping while the Windows profile is visible and the phase kept across switches;
  test_map asserts the map element composed again on a step.
* R1 (recorded as intended): the probe is at CyclePaletteColors' entry, before the core's g_noPaletteDevice early
  return (seg066_1208_p2_r.c:33-36), so under the 16-colour switch the DOS slots step while Windows' do not
  (DOS-faithful: the DOS program cycles regardless of the Windows palette device).
* G1, G3: clauses for FIDELITY F133, draft D 14.7 and checklist D6c-5 under D6d's "For the records".
* R3 (for D6e): the DOS return path R:0238:1BEB restarts the slots through 0626/03FA without capturing again (the
  position is kept); draft B 5.5 item 2's `pdos_play_back` captures again and resets to position 0.  D6e keeps the
  position or records a deviation.

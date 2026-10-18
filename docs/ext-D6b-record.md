# Extension phase D6, unit D6b (logical replay and provenance for play: `pdos_replay`, `pdos_prov`; S3) - record

Draft for the build slot (BRIEF-d6.md "Units" D6b, decisions 3 and 4).  Staged in `build/d6b-stage/` on the tree
after the D6a landing (build/d6a-status.txt ALL_GREEN, 04:10 UTC) and the D5e landing (its files 04:37 UTC,
ALL_GREEN 04:58 UTC); the bases were copied 04:43 UTC and are rechecked equal to the tree in `BASE-SHA256.txt`.
Private builds and runs in `build/d6b-stage/obj/` only (an overlay `obj/src` = tree + stage, built with
build.cmd's own flags).

## Status

LANDED 2026-10-16 (ALL_GREEN 07:09 UTC after one landing fix, section "Landing").  Draft B 8.1..8.6 is built
whole: the 16 replay brackets of 8.2 (owner "replay", DOS rule set),
the target kind at entry (B8) with its check against MapLogicalPointToPort 1220:0F2F, 8.3's coordinates for the
logical, map and half resolutions with exact preimages first (B9), 8.4's colours, 8.5's provenance (the sheet at
ExtractGameSpriteShapes 10E8:231F's exit, TileExtract cuts, the rule mechanism, recycling, `prov_unknown`), 8.6's
picture 137, and S3 by option (a).  Privately: `test_pdos_replay` passes in the three variants, the kind check has
no mismatch in any V1 run and covers kinds 1, 2 and 3, P0 holds, and in 27 DOS comparison runs every frame hash,
show, core output and DOS diagnostic is unchanged (results below).  Nothing is user-visible yet (the replay's
logical shadows wait for D7's ready rows; in play every kind-2 primitive met so far lies inside D's map macros);
no user check.

## What was built

### The logical replay (`present/dos/pdos_replay.h/.c`, new; draft B 8.1..8.4)

* **Registration** (7.3 "Registration"): `pdos_replay_reset` (called by `pdos_profile.c`'s reset after the
  shadow engine's and the setup owner's) registers 16 `PdosMacro`s for owner "replay": DROP with the new
  `PDOS_MAC_LEAVE_DRAWS`, the DOS rule-set bit, any call site (`ra` 0), target `t_prim`, leave `l_prim`, on
  FillRectLogical 11E8:0504, FrameRectLogical 1220:1086, FrameRectDoubleDevice 1220:114B, DrawScreenLine
  10D8:0000, DrawTextAtPortXY 10D8:00E0, DrawScreenText 10D8:01B0, DrawShadowedScreenText 10D8:01FA,
  DrawScreenTextWithShadow 10D8:02DF, DrawCenteredScreenText 10D8:0528, DrawCenteredShadowedScreenText
  10D8:046E, DrawCenteredScreenTextWithShadow 10D8:0495, DrawShapeAndFlush 11E8:0674, DrawMapSprite 11C8:008A,
  DrawImprovementIconLogical 1030:84BE, DrawTextInRect 1098:0ED1 and TextBoxDraw 1068:258F (every key EN|EX;
  obs_lint reads the positional initialisers).  FlushSquareToWindow 11E8:07C3 is a frame only (copy, 8.2), for
  the kind check.
* **Frames** (`pdos_replay_on_probe`, draft B 2.1: at an entry before `pdos_shadow_on_probe`, whose macro
  targets read the frame; at an exit after it, whose leaves draw from it).  A frame keeps the primitive's
  argument words by its signature in claude/src (the module header lists them), the text (w16q_strn, 256 bytes),
  g_monochromeMode 12D8:28FC, g_mapScrollX/Y 1408:00C6/00C4, the shape handle (DrawShapeAndFlush's argument,
  `g_mapSprites[index]` 1420:9350, `g_improvementIcons[id - 1, less 3 from 24]` 1420:98F4 with ids 22..24 none,
  1030:84C9..84D8), the (v, ScaleLogical(v)) pairs of every ScaleLogicalX/Y 11E8:0D81/0DA8 entry inside it
  (8.2's preimage source) and its MapLogicalPointToPort call.  TruncateStringToLogicalWidth 11D0:02E4 entries
  record (buffer, original text, width) for the next draw of that buffer (10.3); TextBoxSetup 1068:2072's
  (text, device rectangle) are tied to the handle it returns, freed at TextBoxDrawAndClose 1068:255A's exit.
* **Target kind** (B8): at the entry from the globals MapLogicalPointToPort reads, `pdos_replay_kind`:
  3 when g_currentDialogPort 1420:9948 is set (1220:0F39; city mode g_cityTileDrawMode 1260:002C the map
  transform, 1220:0F57, else ScaleLogical, 1220:0F89), 1 for 0 <= x < 200 (1220:0FDE), 2 for y >= 8 and
  x >= 200 ((x - 200) * 2 - scrollX, (y - 8) * 2 - scrollY, 1220:100B), else 0.  DrawScreenLine's point is
  (min x, y1) (DrawAxisAlignedLine 11E8:0933); DrawImprovementIconLogical is ScaleLogical without the call
  (kind "scaled", 1030:84E1); DrawTextAtPortXY, DrawTextInRect and TextBoxDraw are device primitives (kind
  "device").  Under the observer, at MapLogicalPointToPort's exit inside a frame that calls it, its AX and the
  point it wrote through its far pointers are compared with the computed kind and point (`kind_checks0..3`,
  `kind_mismatch`, `point_mismatch`).
* **Target surface**: the DC the primitive draws with, read at the entry: the map port's hdc 12D8:455A for kind
  2 (MapLogicalPointToPort's SetGrPort, 1220:1054); DrawShapeAndFlush and DrawMapSprite through
  `g_currentGrPort` 1420:17CC (DrawTile 11E8:06B3), `g_lastNonMainGrPort` 1420:17AE for kind 3 (1220:0FAD);
  DrawImprovementIconLogical through `g_currentGrPort`; the others `g_graf` 1420:9960's hdc.  The DC's surface
  (w16q_dc: its bitmap, else its window) names the bracket's target; its shadow is an owner's claim (D's P, S,
  Wn; the setup pages' owner) or, under the gating below, a logical bitmap shadow made lazily (7.1).
* **Which scenes replay** (the gating; deviation below): nothing while a scripted row (`PDOS_RD_SCRIPT`: intro,
  title, Birth, setup, names, Customize) is anywhere on the scene stack, also under a ready replay row above it
  (the intro's picture dialog 148, row 25, and Play on EARTH, row 5, are ready while area C's timelines draw
  them, pdos_seq.c); kinds 1 and 2 into shadows that exist or that their owner claims (`pdos_shadow_get(..., 0)`);
  a logical shadow (kind 3, the device primitives in a dialog, the scaled icon) is drawn, and made lazily, only
  while the topmost non-R row is an N row with the replay renderer that is ready (D7's renderers set it); kind 3
  or the scaled icon on a non-logical shadow: none; kind 3 in city mode: counted (`city`), nothing drawn (OB9,
  D7); a call site whose DOS font is not drawn (10.1): counted (`font_none`).
* **Drawing** at the exit, only when the bracket saw an event (`PdosBracket.nevents > 0`, 8.1; `nothing`
  otherwise), so the core's quirks that change whether something is drawn stay the core's (the y-swap of
  DrawAxisAlignedLine 11E8:0944, diagonal lines ignored, kind-0 points) and those that change only how do not
  (the 511 clamp of FillRectLogical 11E8:05D4).  Fills by R:0000:0BFA (`pdos_fill_rect`), frames by R:1D05:0A05
  (`pdos_outline`; FrameRectDoubleDevice the rectangle and its one-pixel inset, 1220:11AF/11D1), lines by
  R:0000:100A, text transparent in the DOS font of the call site (R:0182:005C, centred R:0182:00B3, the
  one-pixel shadow of R:0182:0086 with the primitive's shadow colour, none in monochrome mode, 10D8:038D),
  through the Windows-1252 fold (10.4) and, for a truncated buffer, R:1F4D:04F7 on the original; DrawTextInRect
  centred vertically (1098:0F67) with flags & 0xF alignment (1: centre, 2: left, 3: right, else nothing,
  1098:0FD6) and the 0x30 shadow (0x20 black, else colour index + 1); TextBoxDraw wrapped by R:1F4D:0000/0088
  (left) or line by line (1 centre, 3 right, 1068:2659) in the DC's text colour; shapes by provenance (8.5) as
  G#6 sprites (`pdos_prov_draw`).  A primitive inside another on the same surface is muted by the engine (7.3)
  and draws nothing itself (`muted`).
* **Coordinates** (8.3, B9) by the target shadow's resolution: LOGICAL: kind 3 and the scaled icon draw at their
  logical point; device values map through an exact preimage first (a ScaleLogical pair of this frame or its
  caller's: `preimages`), else L(d) = floor((10 d + 9) / 16); a device rectangle [l, r) maps to [L(l), L(r - 1)
  + 1).  MAP (k 2): the device point of the kind through a k = 2 port whose origin carries the point's parity, so
  DOS 2 x 2 pixels start at the device pixel (both parities, scrolls odd and even).  HALF: floor(d / 2), the
  right and bottom edges rounded up.
* **Colours** (8.4): an EGA argument is the DOS index (FillRectLogical's `g_egaToSystemColor[color]`,
  11E8:052F); a system index equal to `g_egaToSystemColor[c]` 12D8:45BE is c; then the scene row's colour table
  (`struct PdosColourMap`, defined here for pdos_scene.h's forward typedef); then the nearest colour of the
  core palette's RGB (`g_hGodPalette` 1420:9966, w16q_palette) in the DAC the shadow is shown with (the N
  machine's for a logical shadow, the A machine's otherwise), counted `colour_nearest`.  A COLORREF of the DC
  (TextBoxDraw) is PALETTEINDEX (01h in the top byte) through the same rules, or its RGB's nearest.
* **Diagnostics**: `pdos_replay_diag_line()`, a `replay ...` line in presentation-diag.log (after `pmap`):
  frames, brackets by kind (0..3, scaled, device), draws, nothing, muted, scripted, no_shadow, no_scene, city,
  kind_checks0..3, kind_mismatch, point_mismatch, preimages, truncations, text_boxes, font_none, lost, and the
  engine's `s3_deferred`, the provenance's `prov_handles` and `prov_sheets`.

### Shapes and pictures by provenance (`present/dos/pdos_prov.h/.c`, new; draft B 8.5, 8.6; PROF 2.2, 2.3)

* **Sheet** (2.2): at ExtractGameSpriteShapes 10E8:231F's exit the 14 handle tables of 8.5 (775 handles,
  claude/src's sizes) are read once through w16q_read; the previous sheet's entries are removed first.  Each
  handle maps by PROF 2.2's rows: S1 terrain (i < 160), S2/S3 coasts and mouths, S4 roads and rails, S5 the
  city tile (g_roadRailShapes[32], = g_mapSprites[3]), S6 rivers (not 0, 16), S7 the mini palace, S8 the edges,
  S9/S10/S14/S15/S17 `g_mapSprites[i]` -> `PDOS_SH_ICON, i` (units 64 + 32c + j, E's civ-c copies), S13
  citizens, S16 the grassland shield as E shapes; S18/S19 the building icons, S20 bulbs and discs, S21/S22 the
  whole-square tiles, S23 the border tiles as page-2 rectangles of `pdos_ma` (`pdos_prov_sheet`, pure).  S11/S12
  (city icons) have no counterpart (PROF Open 15); `g_mapSprites[0..3, 7, 40..63]` no row.  A handle in two
  tables takes the last row that names one; a table entry no row names removes only a cut's entry left under a
  recycled handle.
* **Cuts** (2.3): GR_PicRead 10B8:079D's entry notes (port, picture id) (16 ports, the most recent kept);
  TileExtract 11A8:05C7 (the cut of ExtractScaledTile 1160:33FC and ExtractPictureTile2x 11E8:097C) gives at its
  entry the port and device rectangle and at its exit the handle (AX); a rule registered for the port's
  picture (`pdos_prov_rule(lo, hi, fn)`, at most 16, the D7 renderers' T1..T20) maps (picture, rectangle) to its
  counterpart; without one the handle's entry is removed (a new cut overwrites, recycling).  Picture 137 (EARTH)
  is never mapped (8.6).  Nested cuts close by return address.  A recoloured shape keeps its entry.
* **Drawing** (`pdos_prov_draw`): SHAPE through `pdos_shape` and G#6 (`pdos_sprite_clipped`, colour 0
  transparent), PAGE2 and FILE as a sprite of the rectangle of page 2 of `pdos_ma` or of `pdos_pic(file)`; an
  unknown handle draws nothing and counts `prov_unknown`.
* Storage: 4,096 entries and a 65,536-word handle index (host_alloc, 128 KiB); a full pool counts `no_memory`.

### S3, option (a) (`present/dos/pdos_shadow.c/.h`; draft B 7.3, D4a second review S3)

* `PDOS_MAC_LEAVE_DRAWS` (with `PDOS_MAC_DROP`; without it a configuration error, `macro_config`): while such a
  bracket owns its target (the outermost unmuted DROP bracket on the surface), a copy FROM the target (the flush
  of DrawShapeAndFlush 11E8:0776 with g_autoFlushToWindow, CopyPortToWindow 10D0:0854) is queued in the bracket
  for the macro's rule sets (at most 8, `PDOS_S3_QUEUE`; a further one is applied at once and counted) and
  applied in arrival order after the leave, also when the bracket closes without its leave; dropped and counted
  when the bracket was detached (S7) or closed by a re-registration (S9).  Copies of other rule sets, and the
  copies of macros without the flag (D's map macros), are applied when they arrive, as before.
  `pdos_shadow_s3_deferred/_full/_dropped`.  `PdosBracket` also records the DC's text colour of its last
  TEXTOUT / DRAWTEXT (`text_rgb`, TextBoxDraw's colour).

### Wiring and diagnostics

* `pdos_profile.c`: the reset calls `pdos_replay_reset()` and `pdos_prov_reset()` after `pdos_setup_reset()`;
  an entry probe goes to `pdos_replay_on_probe`, `pdos_shadow_on_probe`, `pdos_prov_on_probe` (B 2.1 steps 4
  and 5), an exit to `pdos_shadow_on_probe`, `pdos_replay_on_probe`, `pdos_reskin_on_probe`,
  `pdos_prov_on_probe` (steps 2..4).
* `pdos_common.h` / `pdos_assets.c`: `PDOS_DIAG_COLOUR_NEAREST`, `PDOS_DIAG_PROV_UNKNOWN` (`colour_nearest`,
  `prov_unknown`), appended to the `pdos ...` line.
* `tests/headless/harness.c`: the `replay ...` line in presentation-diag.log.

## Tests

* `tests/test_pdos_replay.c` (new; B 15.1; synthetic ObsProbe/ObsEvent streams, a table of emulated memory, the
  three modules' queries injected, a hand-written four-glyph font, no DOS byte): ScaleLogical (with the 16-bit
  wrap), L(d), `L(ScaleLogical(L)) == L` for L in 0..639, the kinds of 1220:0F2F; on a dialog's lazily made
  logical shadow each 8.2 primitive at its logical position (fill, frame, double frame, line, the text forms with
  their shadows and centring, monochrome, DrawTextAtPortXY through L(d) and through the exact preimage of
  ScaleLogicalX(-3) = -4, where the two differ), a primitive nested in another (muted, drawn once); every
  primitive of the table with no event draws nothing; on a MAP shadow FillRectLogical at both origin parities and
  a line in 2 x 2 pixels, on a HALF shadow the status fill; the kind check with a wrong result and a wrong point;
  city mode; 8.4 (EGA, system index, the row's table, the nearest counted, DrawTextInRect's alignments and black
  shadow, TextBoxDraw left and centred in the DC's PALETTEINDEX colour, a closed box, truncation on the original
  by R:1F4D:04F7, a font not drawn); the gating (not ready, no row, a scripted row, a ready row over a scripted
  one, a DC of no surface); S3 (the flush waits for the leave and then shows the DOS shape in the window's
  shadow; eight queued, the ninth applied at once); DrawMapSprite and DrawImprovementIconLogical by provenance
  (page 2), `prov_unknown`; PROF 2.2's rows S1..S23 at their edges, the sheet read (a handle in two tables, a
  recycled cut handle, the second read), TileExtract with a rule, picture 137, a recycled handle without a rule,
  nested cuts, the 16-rule limit, the reset; the diagnostic line and names.  84 checks in each variant.
* `tests/test_pdos_profile.c`: `clear_registrations` also clears owner "replay" (its `macro_count == 1` vectors
  count only their own macros; the owner table keeps its 4 slots for setup, replay, B and D).
* `tests/harness/ext_replay.py` (new, Checked only, the brief's harness check): over ext_p0's Checked V1 outputs
  (`--dos-data build\dosdata --graphics dos`), in every run `kind_mismatch 0` and `point_mismatch 0` and
  profiles.log `refused 0` (ext_p0's V1 switch assertions), and over all runs at least one checked
  MapLogicalPointToPort exit of kind 1 (status panel), 2 (map) and 3 (dialog).  REPLAY_OK / REPLAY_FAILED=n.

## Results (private, `build/d6b-stage/obj/`)

* Builds: build.cmd's three variants of the overlay (`--nogen`), strict C17/x64 and the c11/c17/C99 parse of the
  289 portable sources: BUILD_OK each; cc.cmd's strict checks (c11, c17 /W4 /WX, the clang C99 parse; stricter
  than build.cmd for tests, which it compiles with c17 only) in the three variants: the five changed and new
  sources and `test_pdos_replay.c` pass all three; `test_pdos_profile.c` passes c11/c17 but its C99 parse stops at
  line 69, `PdosShadowQ g_queries = {q_dc, q_wnd, q_read}` (missing `wnd_place`, -Wextra), a line of the base
  (D6a), not D6b's (its one change is line 170), and not checked by build.cmd (see "For the records").
* Unit tests (`<gamedata> <outdir>` under the stage): every test program passes in Checked, CheckedNoObs and
  Release; test_pdos_replay 84 / 84 / 84 checks, test_pdos_profile 40 / 36 / 40, test_pdos_shadow 174 / 172 /
  174 (unchanged).
* `obs_lint.py` over the overlay: OBS_LINT_OK files 112 probes 203 callsites 98 (tree: 108).  `testpar.py check`
  on the overlay's test.cmd with BUILD-TEST-ADDITIONS.md applied: exit 0.  `gen/dos/nodos.py check --variant
  Checked --root obj/src`: NODOS_OK (583 files, 0 hits).
* P0 (`ext_p0.py Checked`, the tree's runner with `--exe` the overlay's harness, `--root obj/run/p0root`,
  `--port` the tree, `-j 3`; variations V0, V1, V2, V6, V6r, V6w, V7, V8, V8s, every DOS variation): P0_OK checks
  222 (V0 equal to ext-g1-baseline in its 27 runs; every DOS variation's core trace equal to V0, its switch,
  chord and Birth-synchronisation assertions held).  V3/V4 (Windows-only policies and zoom, no `--dos-data`: the
  DOS profile and so the replay are not registered) not rerun.
* `ext_replay.py --root obj/run/p0root`: REPLAY_OK checks 58: kind_mismatch 0 and point_mismatch 0 in all 27 V1
  runs, profiles.log refused 0; kind 1 first in arrival (10 checked exits), kind 2 arrival (52), kind 3 arrival
  (28); over the runs e.g. menus 10 / 314 / 157 and city 0 / 42 / 139 exits of kinds 1 / 2 / 3.  Every bracket in
  play was muted (inside D's map macros: `muted` equals the kind-2 plus device brackets in every run), `draws 0`,
  `nothing 0`; `scripted` 830..898 frames a run (intro, title, Birth, setup), `prov_handles 653`,
  `prov_sheets 1` after ExtractGameSpriteShapes; `lost 0`, `s3_deferred 0` (no replay bracket owned a flushed
  surface in these runs).
* The DOS profile before/after (`obj/dos_cmp.py`: the tree's Checked harness against the overlay's on all 27
  ext_p0 runs with V1's options `--dos-data build\dosdata --graphics dos --presented 1` plus
  `--profile-samples 100`, `-j 3`): DOSCMP_OK 27: profiles.log samples (both profiles' frame hashes),
  presented.log, run.log frames/snapshots/result, events.log, timeline.log, fonts.txt, dos-assets.log,
  observer-probes.log, watchdog.txt and every presentation-diag.log line equal, except the new `replay` line, the
  `pdos` line's two appended counters (0) and the `pmap` line's host-time fields (snap_us, snap_turn_max_us,
  different between any two runs).  `unexplained` 520..2658 per run, unchanged.  (This comparison ran before the
  `muted` field was added; the harness differed from the final one by that diagnostic field only.)
* `ext_mirror.py Checked` (the tree's runner, `--exe` the overlay's harness, `--root obj/run/mroot`, `--ref` the
  tree's build, `-j 3`): MIRROR_OK runs 29, MIRROR_TOTAL checks 21620 key 6925 render 1229 settled 86 present
  13380 present_mismatched 0 unexplained 0, p0 equal in all 29; every run's `mirror.log` end line equal to the
  tree's own (D5e landing, 04:56 UTC), dos_deferred 50,739 included (`obj/mirror_cmp.py`).
* Not run privately: `ext_frames`, `ext_timeline`, `ext_continue`, `ext_adapt`, `ext_zoom`, `bs*`, `ext_g1`
  (the core and every DOS output are unchanged above), the Asan variant.

## Expected changes at the build slot

* Unit: `test_pdos_replay.exe` new (84 checks in each variant); every other unit count unchanged
  (test_pdos_profile 40, test_pdos_shadow 174 in Checked).
* obs_lint `files` 108 -> 112; portable sources 287 -> 289.
* presentation-diag.log: a new `replay ...` line after the `pmap` line; the `pdos ...` line ends with
  `colour_nearest 0 prov_unknown 0` (0 in all 27 comparison runs).  No other diagnostic value changes
  (`unexplained`, `font_unmapped`, `bad_reads` and every other field equal in the 27 runs).
* test.cmd: the new `ext_replay` section (REPLAY_OK checks 58 with the 27 V1 runs: 1 + 2 per run + 3).
* No frame, golden, G-1 field, profiles.log sample, presented.log, timeline, font or core-trace change (P0 and
  the 27-run comparison below); `ext_g1.py check` unchanged.

## Rebase notes

* All bases equal the tree at writing (BASE-SHA256.txt; D5e had landed before the copy, D6a's records are
  docs-only).  None of D6b's files is in D5e's list.  The `extension D6b` blocks are delimited where they add
  more than a line; one-line hunks carry an `extension D6b` comment.
* build/d5f-stage (staging now) shares four files, all with independent hunks:
  * `pdos_common.h`: D6b appends `PDOS_DIAG_COLOUR_NEAREST` and `PDOS_DIAG_PROV_UNKNOWN` before `PDOS_DIAG_COUNT`
    (delimited); D5f adds its row-counter API after the enum (not in `PdosDiag`).  The two counters are not gate
    counters (D5f's `PDOS_DR_*`).
  * `pdos_assets.c`: D6b changes only the names table's last line (`"setup_text_diff"};` becomes two lines);
    D5f inserts its row counters right after the table: adjacent, so a textual merge may need the two joined by
    hand (D6b's names stay the table's last two entries, in the enum's order).
  * `pdos_profile.c`: D6b changes the header comment (lines 15..16), adds two includes (`pdos_prov.h`,
    `pdos_replay.h`), two reset lines right after `pdos_setup_reset()`, and the probe order in `on_probe` (the
    entry's steps 4..5, the exit's steps 2..4); D5f changes line 119, adds `diag_row` before the reset and
    `pdos_diag_set_row_fn(diag_row)` in it (a few lines above D6b's two).
  * `tests/headless/harness.c`: D6b adds one include and the `replay` line after the `pmap` line; D5f adds its
    `pdos_rows` line after the `pdos` line: adjacent, final order `pdos`, `pdos_rows`, `pmap`, `replay`, `bs`.
* `gen/dos/registry.py` (landing fix 1): D6b appends `"pdos_replay.c", "pdos_prov.c"` and a comment to
  `OBSERVER_FILES` after `"pdos_scn_custom.c"`; D5f's `pdos_scn_fame.c` joins the same set (adjacent lines).
* Shared counts: obs_lint files (108 -> 112 with D6b alone), portable sources (287 -> 289), the shadow engine's
  owner table (setup, pmap, replay: one slot left).

## Build-slot steps

1. Copy the staged files (BASE-SHA256.txt's list; `present/dos/pdos_replay.h/.c`, `pdos_prov.h/.c`,
   `tests/test_pdos_replay.c`, `tests/harness/ext_replay.py` new) and this record into the tree; apply
   BUILD-TEST-ADDITIONS.md to test.cmd (the `ext_replay` list line and block; build.cmd unchanged).
2. The cycle: `build.cmd checked`, `test.cmd checked` (`unit` with test_pdos_replay; `ext_replay`: REPLAY_OK),
   `ext_g1.py check` (EXT_G1_OK unchanged: the core is untouched).

## Landing (2026-10-16, build slot)

* 06:20 UTC: the 13 staged files and this record copied into the tree after every base was rechecked
  (`build/d6b-prep/land.py`, manifest `build/d6b-prep/landed.sha256`, previous copies in
  `build/d6b-prep/tree-before`); test.cmd patched (`build/d6b-prep/patch_testcmd.py`, CRLF, the overlay's checked
  copy byte for byte); `testpar.py check` exit 0.
* First cycle (`build/d6b-status.txt`): build.cmd checked BUILD_OK (289 portable sources); test.cmd checked
  TESTS_FAILED=1 in `d2_registry` alone: `gen/dos/registry.py check`'s include rule for present/dos rejected
  `pdos_prov.c` ("observe.h", "w16_obs.h") and `pdos_replay.c` (<stdio.h>, "observe.h", "w16_obs.h"),
  REGISTRY_FAIL.  Staging miss: the registry check was not among the private runs, and both modules are observer
  readers like `pdos_shadow.c` that `OBSERVER_FILES` did not name.
* Fix 1 (06:45 UTC, `build/d6b-prep/land_fix.py`, staged first and the tree's files hash-checked): `pdos_replay.c`
  no longer includes <stdio.h> (its diagnostic line is built by a local `line_field` helper instead of
  `snprintf`; the rule is not widened); `gen/dos/registry.py` adds `pdos_replay.c` and `pdos_prov.c` to
  `OBSERVER_FILES` with an `extension D6b` comment naming their w16q_* reads (w16q_read, w16q_strn,
  w16q_ret_ax, w16q_dc, w16q_rd16, w16q_palette; obs_lint keeps them to the queries).  Privately on the overlay:
  the include rule ok for all four files, cc.cmd CC_OK for both modules in the three variants.  In the tree:
  `registry.py check` REGISTRY_OK, its output equal to the pre-landing one plus the four `ok include rule` lines.
* Second cycle from step 1 (logs `build/d6b-<n>-<step>-r2.log`): BUILD_OK (289), TESTS_OK, EXT_G1_OK runs 77
  (amended 1, unchanged): ALL_GREEN 07:09 UTC.
* Against the pre-landing snapshot (`build/d6b-prep/compare.py`, `diag_cmp.py`): 45 of 55 test outputs equal
  (ext-p0 P0_OK checks 304, ext-mirror, ext-frames, ext-timeline, ext-continue, ext-adapt, ext-zoom, bs, goldens
  and the others); the differences are those predicted: `ext-replay.txt` new (REPLAY_OK checks 58), unit's
  `test_pdos_replay` 84 checks (profile 40, shadow 174 unchanged), obs_lint files 108 -> 112, registry's four new
  `ok` lines, and host times (times.txt, OBS_COST).  Two informational counts not predicted: coverage's "other
  functions entered" 662 -> 663 (it varies between runs of the same tree: 661..666 over the last cycles, 666 and
  663 in D6b's two cycles, D5l's two 662 and 665) and nodos's scanned files 1692 -> 1701 (D6b's seven tree
  files, test_pdos_replay.exe, and docs/ext-D5e-record.md written after D5e's nodos run; 0 hits).  In the 27 V1
  presentation-diag.log files the only differences are the new `replay` line and `pdos`'s `colour_nearest 0` and
  `prov_unknown 0`; every `replay` line equals the private runs' (made with the `snprintf` form) byte for byte.
* Not D6b's: `tests/test_pdos_profile.c` line 69's implicit `wnd_place` (For the records).

## Decisions within the brief

* S3 (decision 4) by option (a), as an opt-in flag of the macro: only the replay's 16 macros set it, so D's map
  macros (whose DOS leave draws nothing before D6c) keep their copy timing; the queue holds 8 copies a bracket.
* Replayed text is transparent (R:0182:005C and the shadow and centring helpers built on it): the core draws its
  report and play text with a TRANSPARENT background (OpenReportScreenWithHeader 1018:0130, ShowCivilizationScore
  1040:1172), so a replayed text cell paints no background; a scene whose DOS text is opaque gets that from its D7
  renderer (inferred).
* Fonts (10.1): logical text by the font map at its call site (`pdos_fontmap_logical`, asked only once a target
  is decided, so `font_unmapped` counts only drawn text: unchanged in the 27 runs); device text and shapes by the
  DOS font last set on the graf (`pdos_fontmap_current_on`), font 1 when none is known (inferred: play's font).
* The nearest colour (8.4's last row) is taken in the DAC the shadow is shown with: the N machine's for a logical
  shadow, the A machine's (the play palette) for map and half shadows.
* `PdosProvFn` receives `const PresentRect *` (the presentation's rectangle, the same l, t, r, b words read at
  TileExtract's entry) instead of draft B's `const W16Rect *`; the rectangle is the device rectangle of the cut.
* ExtractScaledTile 1160:33FC returns TileExtract's handle (1160:3469), so TileExtract's entry and exit cover it
  and ExtractPictureTile2x; its DOS-coordinate arguments are left to the D7 rules (they can invert the device
  rectangle).
* PROF 2.2 gives no size for S19..S22: S19 takes S18's 18 x 10, S20 8 x 8 (the bulbs' and discs' 8-pixel pitch),
  S21 and S22 16 x 16 (their 16-pixel pitch); S23's 8 x 8 is the row's.  All lie in page 2's resident SP299 art
  (160..319, 50..139; O5:1484..14A4, SPRITES 4), above the advisor portraits' band (y >= 140).  Page 2 of
  `pdos_ma` holds that art from the profile's reset (`pdos_page2_from_store`).
* The kind check runs at every MapLogicalPointToPort exit inside a frame of a primitive that calls it (a
  superset of "one scenario per screen family"); `ext_replay.py` requires each family in at least one V1 run.
* A replay primitive inside another DROP bracket on the same surface is muted by the engine (7.3's ownership)
  and draws nothing: inside D's DrawMapTile, DrawUnit, DrawUnitAt and DrawCityLabels the DOS rule set is D's
  (D6c).  Counted `muted`.
* The replay registers macros only (no hooks): the owner table holds setup, pmap and replay (3 of
  `PDOS_OWNER_MAX` 4).

## Deviations from the design

* Draft B 8.1 replays every logical primitive of every scene.  D6b replays nothing while a scripted row is on the
  scene stack, draws a logical shadow (and makes one) only in a ready N replay row, and draws kinds 1 and 2 only
  into existing or owner-claimed shadows.  Why: area C's timelines draw the scripted scenes' page 0 (the intro's
  picture dialog 148, row 25, and Play on EARTH, row 5, are marked ready by pdos_seq.c while those timelines run:
  without the scripted-stack rule the intro's credit text would be replayed over the DOS intro); the brief's
  decision 3 keeps the D7 rows not ready until their renderers exist; a shadow for every Windows surface would
  only add memory and unexplained counts.  Recorded counters: `scripted`, `no_scene`, `no_shadow`.
* Draft B 8.5: "a TileDispose (or the bitmap delete) removes the entry".  TileDispose 11A8:00D1 has no probe
  (A's list), so a disposed handle keeps its entry until a new cut or a sheet read reuses the handle (handles are
  HGLOBALs, not bitmaps; the core never draws a disposed handle, so nothing wrong is drawn).  A probe on
  TileDispose would make it exact (A's list, D7 if a rule needs it).
* Files beyond the brief's list: `pdos_shadow.h` (the flag, the S3 getters, `PdosBracket.text_rgb`),
  `pdos_common.h` / `pdos_assets.c` (the two counters), `tests/headless/harness.c` (the `replay` line),
  `tests/test_pdos_profile.c` (clearing the replay's registration), `tests/harness/ext_replay.py` (the brief's
  Checked-only harness check), `gen/dos/registry.py` (the include rule's `OBSERVER_FILES`, at the landing).

## User direction 2026-10-16 (no added Go Back / Cancel rows)

D6b adds no row, box or menu of its own and does not rely on D5b's added last row (it neither reads nor calls
pdos_reskin's menu-box model; `pdos_profile.c` keeps the existing `pdos_reskin_on_probe` call unchanged), so the
D5f removal lands independently of D6b in either order.  The replay draws only what the core itself draws with
the 8.2 primitives, and in no scene before D7 makes an N replay row ready; the core's Go Back / Cancel choices are
dialog controls, not 8.2 primitives (inferred from 8.2's table), so they are never replayed.  A D7 renderer that
makes an N row ready applies the rule to that screen (Escape by listing address, or Windows-only).

## What the user checks

Nothing yet: in the 27 comparison runs the DOS profile's frames are unchanged (the replay draws only on surfaces
nothing shows before D6c/D6e/D7).  The first visible replay comes with D7's ready N rows and D6e's status
element.

## For the records

* DESIGN 12.7: D6b done (`pdos_replay`, `pdos_prov`, S3 by option (a)); the replay's gating (scripted rows,
  ready N replay rows, owner-claimed shadows); the owner table's use (setup, pmap, replay: 3 of 4; D6e's class-A
  module takes the last slot or raises `PDOS_OWNER_MAX`).
* Draft B 7.3: S3 resolved, option (a) with `PDOS_MAC_LEAVE_DRAWS` (queue 8, applied after the leave, dropped
  when detached; `s3_deferred`, `s3_full`, `s3_dropped`); `PdosBracket.text_rgb`.  D4a second review S3 closed.
* Draft B 8.1: the gating above; muted inside an outer DROP bracket.  8.2: FlushSquareToWindow a frame only;
  DrawImprovementIconLogical's "scaled" kind (no MapLogicalPointToPort, 1030:84E1); DrawTextAtPortXY,
  DrawTextInRect and TextBoxDraw device primitives; text transparent.  8.3: the MAP port's parity origin and the
  HALF rounding.  8.4: the nearest in the shown DAC.  8.5: `PresentRect` in `PdosProvFn`; TileExtract alone for
  ExtractScaledTile; the two-table rule; TileDispose without a probe; S19..S22's sizes.  8.6: picture 137 never
  mapped.
* DOS-PROFILE.md 2.2: S19..S22's sizes as above (inferred); `g_mapSprites[0..3]`, `[7]` and `[40..63]` have no
  row (S5 maps `g_roadRailShapes[32]` = D4CE[3]).
* RUNNING: presentation-diag.log's new `replay ...` line (fields above) and the `pdos` line's `colour_nearest`
  and `prov_unknown`; `ext_replay.py [Checked] [--only ...] [--root DIR]` reads ext_p0's Checked V1 outputs.
* STATUS: D6b done; nothing visible changes yet.  D6c: D's DOS rule set draws inside its map macros, where the
  replay is muted; D's DrawMapTile could set `PDOS_MAC_LEAVE_DRAWS` once its DOS leave draws (its flush, 1110:0CF1,
  would then follow the DOS drawing).  D6e: the status element (kind 1, HALF) needs its owner's claim for the
  replay to draw there.  D7: ready N rows enable the logical replay; the T1..T20 rules use `pdos_prov_rule`.
* FIDELITY: none new (no visible change); the replayed text's transparency is inferred (above).
* User direction 2026-10-16 (no added Go Back / Cancel row on a DOS screen): D6b adds none and does not depend on
  D5b's added last row (section above); D7's renderers that make N replay rows ready apply the rule per screen and
  record each Escape mapping with its listing address, or the choice as Windows-only.
* Tests (not D6b's change): `tests/test_pdos_profile.c` line 69 (D6a) leaves `PdosShadowQ.wnd_place` implicit,
  which a clang `-std=c99 -Wextra` parse rejects; build.cmd compiles tests with c17 /W4 only, so nothing fails.
  A `NULL` fourth initializer would make it clean if tests ever join the C99 parse.

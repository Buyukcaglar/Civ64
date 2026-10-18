# Extension phase D6, unit D6a (the map display model with the Windows rule set, M2, and the present check) - record

Draft for the build slot (BRIEF-d6.md "Units" D6a).  Staged in `build/d6a-stage/` on the tree of the
UX1b+D5a+D5b+D5c landing (2026-10-16 01:20 UTC; the D5d landing of about 02:15 UTC changed none of the bases,
rechecked 03:37 UTC; `BASE-SHA256.txt`).  Private builds and runs in `build/d6a-stage/obj/` only (an overlay
`obj/src` = tree + stage, built with build.cmd's own flags).

## Status

READY_TO_BUILD.  `--mirror 2 --dos-data build\dosdata` runs the map display model's Windows rule set in the DOS
profile's shadow engine and checks the map window's shadow `Wn_win` against the virtual screen at every core
present.  Privately, in all 29 ext_mirror runs: present mismatches 0, `unexplained 0`, key/render/settled
mismatches 0, profiles.log `refused 0`, and the core trace equal to ext_p0's Checked V0 (P0, 7.3).  The DOS
profile's display, its diagnostics and the core are unchanged in the 9 comparison runs (below).  Nothing is
user-visible; no user check.

## What was built

### The map display model (`present/map/pmap_model.c`, new; draft D 9.1..9.4, B 7.5's table)

* The owner "pmap" of area B's shadow engine; it keeps no shadows of its own.  `pmap_reset` (pmap_zoom.c) calls
  `pmap_model_register(0)`: the six `PdosMacro`s of 9.3 (both rule-set bits) and the `PdosShadowHooks` with the
  DOS bit; `pmap_mirror_start(2, ...)` calls `pmap_model_register(1)`, which re-registers the hooks with both
  bits (9.2: "The Windows set runs only under `--mirror 2`; the DOS set runs always from D6").
* **Claim** (9.2): `P` = the bitmap 12D8:455C while the DC 12D8:455A has it selected; `S` = the bitmap
  12D8:44BE while the DC 12D8:44BC has it selected (Open D1); `Wn` = the window `g_mapWindowPort` 12B0:0004 +0.
  Every map shadow is `PDOS_RES_MAP` (device pixels), black at its claim; a surface of unknown size is 1 x 1
  until resized (`unsized`).
* **Macros** (9.3): DROP on DrawMapTile 1110:04D0 (target: row 0..49, the map window open, `g_currentGrPort`
  null or the map port, scale 1:1), DrawUnit 1110:0DBA (no dialog port, the map port current), DrawUnitAt
  1110:0FF6 (no dialog port, a map point: vy >= 8, vx >= 200, 1220:100B), DrawCityLabels 1208:1F64 (the current
  graf's DC shows P's bitmap); CONTEXT on AnimateUnitMove 11C0:2C32 and ResolveCombat 1050:0000.  The Windows
  rule set's `enter` draws the function's whole effect from live state with M's rules (`pmap_win.c`:
  `mw_square_clip`, the new `mw_unit`, `mw_label`; `pmap_src_live`): the square, then at
  `g_autoFlushToWindow` the flush's labels over the square's part of the client (1110:0CF1); the unit at its
  square (1110:0DEB, IsRectOnMapScreen 1208:2061) with its stack shadow for DrawUnit and without it for
  DrawUnitAt alone; every collected label whose box meets the update rectangle (1208:1FC9).  The DOS rule set's
  `enter` draws nothing yet (D6c).
* **Hooks** (9.4, B 7.5's table): `on_draw` explains black fills (an 8 x 8 probe of the brush in the DC's
  palette) and replays other drawing with `w16q_draw_on` (fills, frames, TextOut, DrawText; logged and counted
  by the engine); `on_copy` copies between map shadows (P -> Wn flushes and WM_PAINT, Wn -> Wn scrolls,
  P/S copies) and replays copies from an unshadowed 8-bit source (counted); `on_resize` counts (the shadow is
  black at its new size, the core repaints it); `on_free` drops a pending DrawTile.  The DOS rule set's events
  are absorbed and counted (`dos_deferred`) for D6b/D6c.
* **Clipping by what reached the surface**: a window draw or copy changes only the pixels of
  `ObsDraw.changed` (the bounding box of the changed pixels, clipped by the visible region and, inside
  BeginPaint, the update region; screen coordinates less the client origin from `w16q_wnd`).  Draws that
  changed nothing are explained (`nothing`); partly reaching draws are counted (`clipped`).
* **DrawTile 11A8:0CB1** (an entry-only probe, so not a macro): into P or S while no Windows-rule DROP bracket
  drops there, it is drawn at its entry from the shape's own TileBlock with DrawTile's transparency
  (11A8:0CC9: 0x1A on a 16-colour display; 11A8:0F80, 11A8:1453: 0 is the top-left pixel; 11A8:1462: 0xFF is
  opaque only for an even width); its last copy back -> port (11A8:135F) is then explained.  Inside the two
  contexts these are the move and combat frames (`tiles`); outside them `tiles_outside` and unexplained.
* **The undefined bevel colour.**  GetColorIndexRGB 1098:01B0 returns its uninitialised local for index 10
  (claude/src seg019, ORIGINAL BUG); a city square's dark bevel (DrawMapTile 1110:0985) of a civ whose dark
  colour is 10 has no defined colour.  The model marks those pixels (the square rendered twice with two
  values for index 10) and takes exactly them from the core's own map port bitmap (`w16q_bitmap`, read only)
  before the square's first copy out of P and at DrawMapTile's exit (`bevels`).
* The game's SectRect 1100:0685 (touching rectangles meet; an inverted extent is zeroed) decides the label
  test, the flush rectangle and the unit's on-screen test, as in the core.

### The present check (`pmap_check.c`; draft D 10.1, 10.2)

* At every core present (`pmap_on_core_present`, pmap_inview.c, after the map window is read): `Wn_win` against
  the virtual screen over the client's visible region, less an open menu's popups and the move/size outline
  (both drawn on the screen over the windows).  The whole client when the window, its region, the exclusions
  or the shadow changed shape since the last check, else the present's rectangle and the shadow's own damage.
  A mismatch writes `mirror N ... kind present rect ... MISMATCH pixels P first x y core C ours O`; ok present
  checks are counted only (as key and render).
* `--mirror 2` needs the DOS profile: `pmap_mirror_start` refuses mode 2 without it, the harness exits 2
  without `--dos-data` (B19).  The model's unexplained events write `unexplained draw|copy|bits|tile ...`
  lines (2000 at most).  Mode 2's end line: `end mirror checks .. mismatches .. unexplained U ..` (U: the
  engine's Windows-rule count since the start plus the model's own) followed by M's fields and `present ..
  present_mismatched .. present_pixels .. present_skipped .. present_noshadow .. squares .. unit_draws ..
  label_calls .. fills .. copies .. tiles .. tiles_outside .. replays .. bits .. dos_deferred .. scaled ..
  unsized .. resizes .. clipped .. nothing .. bevels ..`.  Mode 1's end line is unchanged.

### Area B's engine (`present/dos/pdos_shadow.c/.h`)

* **S8** (ext-D4a second review): `pdos_shadow_rebind` takes the new bitmap's device size when its create gave
  one; a different size reallocates the shadow black and calls the owner's `on_resize`; open brackets on the
  old handle follow it (target and `PdosBracket.target_key`); brackets on the new handle are detached and
  counted (S7's recycled-handle rule).
* **GR_PortDataToBitmap 10B8:0E36** (B 7.1): between its entry and exit the engine keeps the port's hdc
  (+0x18) and old bitmap (+0x1A) read at the entry; the old bitmap's delete (10B8:113F) rebinds its shadows to
  the DC's current bitmap instead of freeing them (`pdos_shadow_rebinds`); any other delete frees as before.
* `pdos_shadow_unexplained_rs` (per rule set; `PdosUnexplained.rule_set`), `pdos_shadow_dropping`.
* Copies: the owner of both shadows is asked once; a copy makes its destination bitmap's logical shadow only
  when the source shadow is logical (a map shadow's copy into DrawTile's buffer makes none).
* `OBS_BMP_DAMAGE` alone is no longer unexplained (it precedes the same drawing's `OBS_DRAW`, which is judged);
  raw bits (`OBS_BMP_BITS`) still are.

### Harness and runner

* `harness_main.c`: `--mirror 1|2`; mode 2 without `--dos-data` exits 2.  `harness.h`: the option's comment.
* `pmap_inview.c`: the listener calls `pmap_model_probe` / `pmap_model_event` and the present check.
* `tests/harness/ext_mirror.py`: the 29 runs with `--mirror 2 --dos-data build\dosdata --graphics windows`;
  pass adds `unexplained 0`, `present_mismatched 0`, a present check in every run that reaches the map and
  profiles.log `registered windows,dos` / `refused 0`; `--exe`, `--root`, `--port`, `--ref` for private runs
  (defaults unchanged); MIRROR lines and MIRROR_TOTAL extended.

## Open D1, D2, D5

* **D1** (S's DC and bitmap): GR_PortOpen stores the bitmap at GrPort +0x1A (10D0:0141) and the DC at +0x18
  (10D0:0160): for `g_offscreenPort` 12D8:44A4 they are 12D8:44BE and 12D8:44BC, as 9.2 inferred.
* **D2** (DrawTile calls inside ResolveCombat): the lunge's call at 1050:093A (returns to 1050:093F) draws the
  attacker's sprite `g_mapSprites[64 + civ * 32 + type]` at (2, 2) of S, 11 frames; the explosion's call at
  1050:0AEA (returns to 1050:0AEF) draws `g_mapSprites[32 + frame]` at (0, 0) of S, frames 0..7.
  AnimateUnitMove's frames: 11C0:2F03.
* **D5** (drawing outside the macros): in all 29 runs `replays 0`, `bits 0`, `tiles_outside 0`; everything
  outside the macros was a black fill (20,179), a copy between map shadows (23,753), a context DrawTile (660)
  or a window draw that reached nothing (6,147).  No other core drawing reaches P, S or Wn in these runs.

## Tests

* `tests/test_map.c` (`model`, synthetic event streams with a fake emulation: sparse memory, DCs, bitmaps,
  blocks, the client origin): registration; DrawMapTile drawn by M's rules at entry; the flush P -> Wn; a
  window fill reaching only part of the client; a black fill; an unexplained SetPixel; DrawUnit with
  DrawUnitAt muted; DrawUnitAt alone; a move frame's DrawTile into S; a DrawTile outside the contexts; a
  scaled DrawTile; DrawUnitAt into a dialog; the undefined bevel colour (and the flush after it);
  `pmap_present_compare` vectors (equal, one mismatch, under an exclusion, a smaller shadow, two visible
  rectangles).  Checked / Release 127 -> 146; CheckedNoObs 1 -> 1.
* `tests/test_pdos_shadow.c` (`test_d6a`): S8 (size update, on_resize, same size kept, bracket retarget,
  recycled-handle detach), per-rule-set unexplained, GR_PortDataToBitmap's rebind (and the frees outside it),
  the logical-source rule, the DAMAGE rule.  Checked / Release 157 -> 174; CheckedNoObs 133 -> 172.
* 7.5 literal and 7.3: `ext_mirror.py` as above.

## Results (private, `build/d6a-stage/obj/`)

* Fresh full builds of the overlay with build.cmd (`--nogen`), Checked, CheckedNoObs, Release: BUILD_OK, 286
  portable sources (c11, c17, C99 parse); then `pmap_check.c` (a 64-bit pixel total) and the harness
  (harness.h comment) recompiled and relinked with build.cmd's flags; the per-file strict checks (c11, c17
  /W4 /WX, clang C99 parse) of pdos_shadow.c and the five pmap files in all three variants: CC_OK.
* Unit tests (every `test_*.exe` but test_ne, argv[1] = build\gamedata, argv[2] under the stage): all pass in
  the three variants (44 programs each; test_ne and the w32_test_* programs, unaffected, not rerun).
* `obs_lint.py` over the overlay: OBS_LINT_OK files 106 probes 203 callsites 98 (tree: 105, 203, 98).
* `ext_mirror.py` (staged, Checked, `-j 2`, 132 s): MIRROR_OK runs 29; MIRROR_TOTAL checks 21620 key 6925
  render 1229 settled 86 (the tree's `--mirror 1` totals: 8240 = 6925 + 1229 + 86) present 13380
  present_mismatched 0 unexplained 0 squares 6601 unit_draws 3148 tiles 660 tiles_outside 0; p0 equal in all
  29.  End-line sums: present_pixels 1,913,685,040, fills 20,179, copies 23,753, label_calls 17,990, replays 0,
  bits 0, dos_deferred 50,739, scaled 0, unsized 0, resizes 0, clipped 1,638, nothing 6,147, bevels 1 (s4).
* DOS profile before/after (the tree's Checked harness against the overlay's, ext_p0's V1 options
  `--dos-data build\dosdata --graphics dos --presented 1` plus `--profile-samples 100`; start, load, birth,
  new, orders, conquest, city, s2, s3): profiles.log samples (both profiles' frame hashes), presented.log,
  run.log frames/snapshots/result, events.log, timeline, fonts, dos-assets, observer-probes and the `pdos`
  diagnostics line all equal; only the `pmap` line's host-time fields (snap_us, snap_turn_max_us) differ, as
  between any two runs.
* Not run privately: `gen/dos/nodos.py check` (no DOS bytes added: the new code holds addresses and hand
  values only), `gen/dos/registry.py check` (no include of present/dos changed), ext_p0/ext_frames/
  ext_timeline/ext_adapt/ext_zoom/ext_g1 (core unchanged by construction and by the mirror runs' P0; the DOS
  outputs equal above).

## Expected changes at the build slot

* `ext-mirror.txt`: the MIRROR run lines and MIRROR_TOTAL carry the new fields (above); `mirror.log`'s end line
  in mode 2 carries the new fields, and present checks take numbers in the `mirror N` sequence.
* Unit counts: test_map 146 / 1 / 146, test_pdos_shadow 174 / 172 / 174 (Checked / CheckedNoObs / Release).
* obs_lint `files` +1 and portable sources +1 (pmap_model.c); D5e adds 2 lint files and 1 portable source of
  its own.
* No frame, golden, G-1 field or DOS diagnostic changes; ext_mirror's time grows (est 125 -> 140 s).

## Rebase notes

* None of the bases changed in the D5d landing.  build/d5e-stage (pdos_adapt*, pdos_registry*, pdos_scene_tab,
  pdos_scn_custom*, pdos_scn_setup, pdos_seq, registry.py, adapters.py, DOS-PROFILE.md, OFFSETS.md,
  dos-decoded.txt, test_input, test_pdos_seq, test_pdos_setup, ext_adapt, ext_timeline) shares no file with this
  stage.  Shared counts only: portable sources (285 -> 287 with both) and obs_lint files (105 -> 108 with both).
* `pdos_shadow.c/.h` (D5a's landed copies + D6a): the D6a blocks are marked `extension D6a`; the unmarked
  one-line hunks are `note_unexplained`'s new rule-set argument at its three calls and S8's rebind body below
  its marked comment.

## Build-slot steps

1. Copy the staged files (BASE-SHA256.txt's list, `present/map/pmap_model.c` new) and this record into the tree;
   apply BUILD-TEST-ADDITIONS.md to test.cmd (the ext_mirror section; build.cmd unchanged).
2. The cycle: `build.cmd checked`, `test.cmd checked` (ext_mirror: MIRROR_OK runs 29 with present_mismatched 0
   and unexplained 0; the unit counts above), `ext_g1.py check` (EXT_G1_OK unchanged); the full eight steps at
   the D6 gate.

## Decisions within the brief

* Registration as 9.2 says: the macros carry both rule-set bits from `pmap_reset`; the hooks the DOS bit from
  `pmap_reset` and both under `--mirror 2` (the Windows set costs nothing in play).  Without `--mirror 2` the
  engine makes no Windows-rule shadow of P, S or Wn (no owner claims them).
* The Windows rule set draws a context DrawTile from the shape's own TileBlock: it needs no shape identity;
  9.3's `g_mapSprites` lookup is the DOS set's (D6c).  The two ResolveCombat call sites are recorded (D2), not
  filtered on: any DrawTile into P or S inside a context is drawn.
* The DOS rule set's shadows exist and its events are absorbed (`dos_deferred`), not drawn or replayed: its
  drawing is D6c's and B's replay D6b's (the brief's "Not in the unit").
* The present check runs in `pmap_on_core_present` (M's present hook); ok present lines are counted only; the
  move/size outline and the menu popups are excluded.
* The DrawMapTile target does not test `g_cityScreenMapMode`: M's rules read it live as DrawMapTile does
  (1110:065B), and the port test leaves out the city screen's own port.

## Deviations from the design

* D 9.3 "`leave` is NULL for the DROP macros": DrawMapTile has a leave for the Windows set (`l_map_tile`), the
  undefined bevel colour taken from the core's port at its exit.  Why: the original gives that colour no
  value (GetColorIndexRGB 1098:01B0's uninitialised local for index 10); no state determines it.
* D 9.4 (copies and replays "copy the rectangle", "replay it"): window draws and copies change only
  `ObsDraw.changed` (clipped by the visible and update regions as the core's GDI clips them); map-to-map
  SRCCOPYs are copied by the owner itself through a buffer.  Why: whole-client erases and flushes inside
  BeginPaint reach only the update region; drawing the whole rectangle made present mismatches.  Limit: a
  bounding box, so a two-rectangle region could be over-drawn between its rectangles (no present mismatch
  shows it in the 29 runs).
* B 7.4/7.5 (engine): the DAMAGE rule, the logical-source rule and "the owner of both shadows is asked once",
  with the per-rule-set unexplained count.  Why: with map shadows in place every DAMAGE event of P would have
  counted (the DOS count is unchanged with the rule); a map shadow's copy into DrawTile's buffer must not make
  a logical shadow there; the map's own copies were otherwise counted twice.
* The game's SectRect 1100:0685 for labels, the flush and the unit test (M's settled check keeps its strict
  intersection, unchanged).  Why: touching rectangles meet in the core (labels drawn for a touching box).
* `ext_mirror.py` passes `--graphics windows` beyond the brief's `--mirror 2 --dos-data build\dosdata`: the
  harness writes profiles.log only with `--graphics`, and RV1-5's `refused 0` assertion reads it.
* Files beyond the brief's list: `pmap_win.c` (`mw_unit`, DrawUnitAt without the stack shadow),
  `pmap_zoom.c` (the registration in `pmap_reset`), `pmap_inview.c` (the listener and present hooks),
  `harness.h` (comment).

## What the user checks

Nothing: the change is the harness's `--mirror 2` oracle and invisible shadows; the Windows and DOS displays
are unchanged (P0 and the DOS comparison above).

## For the records

* DESIGN 12.7: D6a done (pmap_model.c, the present check, S8, the GR_PortDataToBitmap wiring); 12.9 (or the
  engine section): the DAMAGE, logical-source and owner-once rules, the per-rule-set unexplained count.
* Draft D 9.2: S's offsets confirmed (Open D1).  9.3: DrawMapTile's leave (bevel), the target without
  `g_cityScreenMapMode`, D2's call sites, the Windows set's TileBlock drawing.  9.4: the changed-box clipping,
  the owner's map copies, the DOS set absorbed until D6b/D6c.  10.1/10.2: the present check's region,
  exclusions and rectangle policy; mode 2's end-line fields; ok present lines counted only.  Open D5 answered.
* Draft B 7.1: GR_PortDataToBitmap's rebind.  7.4/7.5: the rules above; S8 done (ext-D4a second review).
* RUNNING: `--mirror 2` needs `--dos-data`; ext_mirror.py's `--exe/--root/--port/--ref`; the end-line fields.
* FIDELITY: a city square's dark bevel for a civ whose dark colour is 10 is undefined in the original
  (GetColorIndexRGB 1098:01B0 ORIGINAL BUG); the port shows the emulation's value; M's `mw_res_load`
  `color_rgb` maps index 10 to black, so the zoom ring's bevel for such a civ is black (inferred: no settled
  check covered such a square in the 29 runs, since none mismatched; s4 drew one, which D6a's bevel fix met).
* STATUS: M2's present check passes in the 29 mirror runs (13,380 checks); D6b, D6c next.

## Landing (build slot, 2026-10-16)

Landed ahead of the D5 gate by the orchestrator's ruling (nothing visible changes, no D5 file overlaps; the D5
gate's eight-step cycle covers D6a too).  D5e was still staging, on disjoint files.

* **Bases.** Every base re-verified against the tree at 03:47 UTC by `build/d6a-prep/land.py` (each tree file
  still had its listed base SHA-256, the two new files were absent, each staged copy had its listed hash); the
  D5d landing had changed none.  The 13 staged files, `present/map/pmap_model.c` and this record copied byte for
  byte at 03:47:34 UTC; manifest `build/d6a-prep/landed.sha256`, previous files in `build/d6a-prep/tree-before`,
  the previous Checked test outputs in `build/d6a-prep/before`.
* **test.cmd.** BUILD-TEST-ADDITIONS.md's change applied by `build/d6a-prep/patch_testcmd.py` (base
  655761f8..., CRLF kept; now 73181a8b...): the ext_mirror header `est=140`, the comment block above
  `:sec_ext_mirror`, the echo text.  `testpar.py check test.cmd`: no problems (exit 0); `list` shows
  `ext_mirror after=ext_p0,uninit cpu=4 est=140`.
* **The three-step cycle** (`build/d6a-prep/d6a-cycle.ps1`, detached, each step waiting on its own cmd.exe;
  status `build/d6a-status.txt`):
  1. `build.cmd checked`: exit 0, 219 s (03:48:09..03:51:48), BUILD_OK, portable sources 286
     (`build/d6a-1-build-checked.log`).
  2. `test.cmd checked`: exit 0, 1107 s (03:51:48..04:10:15), TESTS_OK, TEST_SECTIONS 24, failed 0, wall 1104.8 s
     (`build/d6a-2-test-checked.log`).
  3. `ext_g1.py check`: EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events), unchanged
     (`build/d6a-3-g1-checked.log`).
  `ALL_GREEN`.
* **Against the expected changes** (`build/d6a-prep/compare.py`: the Checked test outputs before and after, lines
  with host times left out; 46 of 53 files identical):
  * ext-mirror.txt and the ext_mirror section log: the new echo text, the extended run lines and
    `MIRROR_TOTAL runs 29 checks 21620 key 6925 render 1229 settled 86 present 13380 present_mismatched 0
    unexplained 0 squares 6601 unit_draws 3148 tiles 660 tiles_outside 0`, MIRROR_OK runs 29, every run
    `p0 equal`: the private totals exactly, as expected.
  * unit.log: test_map 127 -> 146, test_pdos_shadow 157 -> 174 (expected); its OBS_COST line differs only in
    host-time nanoseconds.
  * obs-lint.txt and its section log: files 105 -> 106 (expected; probes 203, callsites 98).
  * nodos.txt: 0 hits; files 1687 -> 1690 and bytes +1,963,294.  Not in the expected list, explained: the three
    files new to the port tree since the previous scan (docs/ext-D5d-record.md, written after D5d's test run at
    02:38 UTC; pmap_model.c; this record) and the Checked executables, each about 35 KB larger with
    pmap_model.c's code (civ_harness.exe 4,462,592 -> 4,497,408 bytes; 50 executables scanned).
  * times.txt: section times only.  ext_mirror took 175.8 s (152.5 s before; the section's est 140 is a
    scheduling hint and stays).
  * Everything else (ext_p0 P0_OK checks 304, ext_frames, ext_timeline both groups, ext_continue, ext_bs assets
    and mirror, ext_adapt checks 77, ext_zoom ZOOM_OK combinations 32 runs 64 samples 388, registry, adapters,
    obs_tables, the scene check, trace, coverage): identical.
* CheckedNoObs and Release were not built at the slot (the three-step cycle); the stage's private builds of
  both passed (test_map 1 / 146, test_pdos_shadow 172 / 174), and the D5 gate's eight steps cover them.

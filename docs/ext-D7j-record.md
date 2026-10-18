# Extension phase D7, unit D7j (the palace) - record

Draft for the build slot (BRIEF-d7.md "Units" D7j).  Staged by session E3 in `build/d7j-stage/` stacked on D7a's staged
copies, continued and finished in session E4 (track C, 2026-10-17), and rebased onto the tree after the D7a + D7b
landing (copy-in 08:07:35 UTC, cycle ALL_GREEN 08:45 UTC, RELEASE_OK 08:50 UTC; `build/d7ab-prep/LANDED.txt`) and UX5b's
copy-in (09:35 UTC; its cycle ALL_GREEN 10:49 UTC): the base of every staged file is now the tree's file ("tree" in
`BASE-SHA256.txt`).  D7j's edits to the shared tables follow D7a's and D7b's in separate blocks (section "Rebase
notes").  Private builds and runs in `build/d7j-stage/obj/` only: an overlay `obj/src` = the tree + D7j's staged files
(`obj/mkoverlay.py`), built with the tree's build.cmd and flags (`obj/b.cmd`, `--nogen`), cc.cmd's stricter checks per
file (`obj/cc.cmd`), the unit programs (`obj/unit.py`) and the harness runs from the overlay's binaries with every
output under `obj/`; the tree's build/gamedata, dosdata and cache read only.

## Result

D7j is staged and READY_TO_BUILD.  With the DOS graphics, the palace shows as the DOS palace on the N frame: the palace
view (a click on the palace at the top of the Status window) composes the DOS palace from the core's palace state
(CASTLE0..4 pieces over CBACK, the strip and the gardens), shows it on black with the palace palette and waits for a key
or click; the return to the map fades in from black (R:0238:1B44).  The palace improvement (when the score passes the
palace threshold at a turn's end) shows the DOS palace, the KING text in its box at DOS's place (20, 16), the DOS
prompt box, the yellow section digits and garden letters at the core's positions, the DOS preview (the blue panel, the
heading, three boxes with the new level's pieces in the three styles) after a section is chosen by key or click, the
palace again after the style, and the DOS reveal (DissolveToScreen G#10(1, 20), 146 frames) of the new palace, then a
key or click returns with the fade from black.  No Go Back or Cancel row is shown (DOS has none).  With the Windows
graphics nothing changes.  Privately, on the tree after the D7a + D7b landing with D7j's staged files: the three
variants build, every unit program passes in each (test_pdos_palace new, 118 checks), the d7j adapter pair passes
(a section chosen by a click at WaitForKeyOrClick's own point, class W, equals its Windows-form pair), ext_timeline's
palace and palace_view runs pass (the reveal's frames, the return's fade, the N frame), ext_p0 V0/V1/V2 on `conquest`
and `city` P0_OK with no counter on rows 104 and 124, and every check script passes.

## Status

READY_TO_BUILD.  Built: rows 124 (RunPalaceImprovement, O17:0000) and 104 (the palace view, R:0403:0796; its exit now
GR_DialogClose's entry), with row 25 (dialog 148) made ready by the renderer; the composer O17:07EC(sad) callable for
D7l's sad palace (O2:1356), with the sad tail's helpers (the fade's condition O17:0CA2..0CAE, page 0 black and SAD.PIC's
palette); the prompt, labels, previews and the reveal G#10(1, 20) as TX on its own timeline (PDOS_SEQ_FX_DISSOLVE); the
view's and the improvement's return (decision 3, exit kind 1B44); the KING box anchored at DOS's (20, 16); the shadow
owner "palace" (the palace window logical, the palace port at the device resolution, followed when OpenPalaceView
replaces its bitmap); pdos_prov's T7 rule (PROF row 107); the I-palace adapter rows (class W in the selection waits,
class X in the any-key waits); the registry tables PALACE_WIDTHS, PALACE_YOFS, PALACE_PROMPT and PALACE_SELECT.  Not in
the unit: the arrival's palace and the sad palace's fade O17:0CB9 as TX (D7l, deviation 3).

## What was built

### The composer O17:07EC(sad) (SCENES-PLAY 7.8; P26, P28..P30; decision 8)

`pdos_palace_compose(m, st, sad)` (present/dos/pdos_scn_palace.c) draws on page 1 of the N machine what O17:07EC draws
(DOS listing): the background CBACK.PIC, or SAD.PIC for the sad palace (O17:089F; DOS file), the strip CBACKS<n>.PIC at
(0, 135) for the level of section 10 (O17:08BE, 08D8), the gardens CBRUSH<n>.PIC at (0 or 184, 94 or 105) for sections 9
and 11 (O17:0C00..0C6F), then the sections 1..7 by the listing's x walk from 16 (24 less without section 2, O17:08E0..
08EC) at y 36 (O17:091B..0B09: an unbuilt section steps 48), each piece of O17:0CFE's types for its shape
(O17:0B1E..0B5D, 0D11..0D50) cut by O17:0E95 from CASTLE<L>.PIC (quadrant (style & 1) * 160, (style & 2) * 50; widths
52, 24, 24, 28, 27, height 99; the 35-wide pieces at (160, 101) and (196, 101), O17:0F55..0FDC) and placed by DrawPiece
O17:0E2F with the DOS widths (DGROUP:4B2C, registry PALACE_WIDTHS) and y offsets (DGROUP:4B36, PALACE_YOFS: 15 per
level, 5 per variant, one per type).  Pieces and gardens are G#32 sprites (colour 0 transparent).  The state is the
core's g_palaceSectionLevel 1350:00DC and g_palaceSectionVariant 1350:00C4 (the DOS words DGROUP:D91E and DGROUP:B222,
12 each), read through w16q_read at use.  Not drawn (ruling 8): picture 4446 (P27, no DOS counterpart).

### The improvement O17:0000 (row 124)

At RunPalaceImprovement's entry (1158:0000) the renderer composes the palace, fills page 0 black, loads CBACK's palette
over the play palette and copies page 1 to page 0 (O17:004F..00BD, G#20; DOS listing), and makes rows 124, 104 and 25
ready (the N frame).  The core's steps then drive the DOS steps:

| Core (Windows) | DOS (listing) | The renderer |
|---|---|---|
| ShowTextDialog(KING, 20, 16) 1158:0045 | O17:00C5..00D2: R:1D05:0018 at (14h, 10h), then page 1 back over the box (O17:00DA..00FF) | the core's MenuZ box (dialog 136 or 145) re-skinned (row 14) and anchored at DOS's (20, 16) (`pdos_reskin_anchor`); the pointer shown (R:1D05:0135) |
| OpenPalaceView(0) 1158:0051 | (the palace already on page 0) | row 104 over 124; dialog 148 the palace window; every core drawing on it and on the palace port absorbed |
| DrawCenteredShadowedScreenText(prompt) 1158:009D | O17:0122..0134: R:1D05:0018 at (40, 16) with DGROUP:DB38 set (drawn only) | the DOS prompt box (DGROUP:4AF0, PALACE_PROMPT) at (40, 16), as tall as its lines, no highlight |
| DrawShadowedScreenText(digit / letter) 1158:0165, 01E6 | O17:019E..01AE, 01F2..0209: R:0182:0086 colour 14 | the label at the core's position in colour 14, its shadow at y + 1 (CORR 11: the positions are shared) |
| WaitForKeyOrClick 1158:0261 (the section) | O17:022C..02EA (the pointer shown), the rule O17:0231..030C | at the wait's exit the core's choice is computed by the listing's rule from AX and g_clickX/Y 1328:0010/000E (`pdos_palace_choose_section`, the snapping included); a valid one draws the preview |
| (its preview) | O17:030E..06AE: page 1 on page 0, the panel (16, 2, 288 x 102) colour 9, "Select new section." (DGROUP:4B13, PALACE_SELECT) centred at (160, 3) colour 15, three boxes (100k - 80, 10, 80 x 92) colour 1 with the new level's pieces in styles 0..2 and their digits at (100k - 44, 12) colour 15 | the same on page 0 (`pdos_palace_preview`); a garden (sections 9..11) has none (O17:0353 -> 0747) |
| WaitForKeyOrClick 1158:0833 (the style) | O17:06C3..0708 | the style by key 1..3 or x / 6Bh (`pdos_palace_choose_style`); the palace as it was on page 0 (O17:070A..073F) |
| GR_DialogClose (the first window) | - | rows 104 and 25 end at its entry; row 124 holds the N frame |
| OpenPalaceView(0) 1158:08A2 (the state committed) | O17:075D..0780: the new palace on page 1, G#10 DissolveToScreen(1, 20) | the new palace composed, the dissolve on its own timeline (PDOS_SEQ_FX_DISSOLVE, frame 0 at the probe's instant, 146 frames: ceil(64000 / floor(8800 / 20)), M10) |
| WaitForKeyOrClick (the last wait) | O17:0788: R:0403:4545 (flush), R:1459:0918 | the pointer stays hidden; keys during the dissolve consumed (I-palace/busy) |
| ClosePalaceView (called at 1158:08B6; the window destroyed) | O17:07DC: R:0238:1B44 | the rows not ready (the A frame), the exit kind 1B44 named for the return (D7a's trigger: the fade from black, 30 frames, M5); a dissolve still running is finished at once (its tail) |

The pointer (R:01A8:0268 hide, 0250 show; DOS listing): hidden from the entry (O17:0009) to the KING box, shown through
the first wait, hidden from the first choice (O17:030E) to the second wait (O17:06C3), hidden from the second choice
(O17:070A) through the reveal and the last wait to the end (O17:07E1).

### The palace view R:0403:0796 (row 104)

OpenPalaceView 1158:08E7 outside the improvement and the arrival (WdwStatusProc 1218:0225, a click in the Status
window's palace rectangle GetStatusPalaceRect 1218:0956): compose, page 0 black, CBACK's palette, page 1 to page 0
(R:0403:079F..0800; DOS listing), the pointer shown for the wait (R:0403:0808), any key or click ends it (I-palace/
wait-key, wait-press).  Row 104's exit is GR_DialogClose's entry (in ClosePalaceView 1158:123B) instead of
OpenPalaceView's return, so the N frame holds through the core's wait after OpenPalaceView (deviation 1); the end is the
palace window's destruction with the exit kind 1B44 (R:0403:0826).

### The KING box at DOS's place (E4)

The core's ShowTextDialog places its MenuZ box at (0, 0) of the window; DOS draws the KING box at (20, 16) (O17:00C5..
00D2: R:1D05:0018 with 14h, 10h; DOS listing).  While the KING ShowTextDialog runs (its call at 1158:0045, from its
entry to its exit) the renderer anchors the dialog 136 or 145 created then at (20, 16) (`pdos_reskin_anchor`, D6f's hook
for a renderer's DOS position; the box itself is the re-skinned row-14 box).  The first run of E3's renderer showed it
at (0, 0).

### The shadow owner "palace" (B 7.5; E4's fix of the counters)

The palace window (dialog 148 of GR_DialogOpen 1158:09B4) is claimed at the logical resolution; the palace port's bitmap
(GR_PortOpen 1158:0A27, g_palacePort 1350:0056 + 1Ah) at the device resolution, and followed when OpenPalaceView
replaces it (GR_PortDataToBitmap 10B8:0E36 after its raw bits): the claim takes the bitmap that is the port's at the
time.  Every core drawing on both is absorbed (page 0 is never the core's).  At the device resolution a copy from the
port makes no logical shadow of its destination (pdos_shadow_get), so the buffers of the improvement preview's DrawTile
calls (11A8:0CB1 -> DrawTileImpl: the port's square copied in, the tile composed as raw bits, copied back) get none and
their raw bits are not counted.  E3's renderer kept the first bitmap only: ext_p0's V1 `conquest` counted
`r104.unexplained` 10 (the replaced bitmap's raw bits and the DrawTile buffers); now 0.  (D7b's negative claim, the
report's way for its DrawTile buffers, is not needed here: the port itself must stay claimed.)

### T7 (PROF 2.3; pdos_prov)

`pdos_prov_t7`: g_palaceSprites, cut by LoadPalaceSectionSprites 1158:14C6 from picture 4457 (0x1169, level 0) or 4458 +
3 (L - 1) + p (levels 1..4, p the Windows picture of the variant, 1158:152B..1568) at device (l, 2) - (r, 160), map to
O17:0E95's cut of that type from CASTLE<L>.PIC in quadrant v (row 107; the wide pieces for variant 1); level 0 in
quadrant 0 (inferred: one Windows picture serves every variant).

### The adapter rows I-palace (C.12.7; class W, BRIEF-d7 D7j)

While the renderer shows the palace the scene is PDOS_AS_PALACE (0x40000000) with the palace window: the core READY
in the two selection waits, INTRO while a choice is drawn or the reveal runs, WAIT in the any-key waits.  Rows:
I-palace/mod (a modifier alone: consumed), busy (keys and buttons while DOS reads none: consumed, R:0403:4545 flushes
them), key (pass: 1..7, a..c, 1..3; Escape and others choose nothing and the wait goes on, O17:02A9..02C9,
06FA..0708), press (a left press in a selection wait: pass at class W, WaitForKeyOrClick's own logical point in the
palace window, from which the core computes the section or style as DOS does, O17:024F..0292, 06E6..06EF), right
(consumed), wait-key (pass) and wait-press (pass, class X).  No row shows a Go Back or Cancel choice: DOS has none.

### Registry tables (OFFSETS.md; DOS file, DOS listing)

PALACE_WIDTHS DGROUP:4B2C (u16 x 5; readers O17:04F1, 05E4, 0933, 0979, 0A61, 0AF6), PALACE_YOFS DGROUP:4B36 (75
bytes, range 0..3; reader O17:0E74), PALACE_PROMPT DGROUP:4AF0 (one string, max 48; O17:0130), PALACE_SELECT
DGROUP:4B13 (one string, max 32; O17:0411); no writer.  The preview reads the y offsets through DGROUP:4B31..4B35 with
an index of at least 5, below the table; not listed as a reader (OFFSETS.md note).

### Evidence labels

* DOS listing: every O17 and R: address above (build/dos/disasm/ovl17.lst, root.lst, read only); DOS file: the
  pictures CASTLE0..4, CBACK, CBACKS1..3, CBRUSH*, SAD and the tables of the registry; the Windows side from the
  port's reconstruction (claude/src, the core's call sites).
* Inferred: the font of the labels and the prompt (font 1, P14, OB4: PDOS_R_FONT); the prompt box's h8 0 (DGROUP:3936
  taken as FFFFh, as the other boxes of play); T7's level 0 in quadrant 0.
* DOS oracle: none (no DOS program run); unknown: none left open by the unit.

## Files

Changed (`BASE-SHA256.txt`; every base "tree", the tree after the D7a + D7b landing):
`present/dos/pdos_adapt.c/.h`, `pdos_adapt_tab.c`, `pdos_profile.c`, `pdos_prov.c/.h`, `pdos_registry.c/.h`
(generated by `registry.py gen` from OFFSETS.md), `pdos_scene_tab.c`, `pdos_seq.c`, `pdos_shadow.h` (PDOS_OWNER_MAX 6 ->
8), `gen/dos/adapters.py`, `gen/dos/registry.py` (OBSERVER_FILES += `pdos_scn_palace.c`), `docs/DOS-PROFILE.md` (rows
104 and 124, 1.7.2 regenerated), `docs/dos/OFFSETS.md`, `tests/test_input.c`, `tests/dos-decoded.txt` (registry
goldens), `tests/headless/harness.c` (the `palace` diag line), `tests/harness/ext_adapt.py` (the d7j pair),
`tests/harness/ext_timeline.py` (the palace and palace_view runs).  New: `present/dos/pdos_scn_palace.c/.h`,
`tests/test_pdos_palace.c`, this record.  Unchanged, though the brief lists it: `present/dos/pdos_fx.c` (deviation 4).
build.cmd and test.cmd unchanged (new files are found by their globs); no BUILD-TEST-ADDITIONS.md.  Every `extension
D7j` block is delimited where it adds more than a line, after D7a's and D7b's blocks in the shared files; one-line hunks
carry an `extension D7j` comment.

## Tests

* **`tests/test_pdos_palace.c`** (new, 118 checks in Checked): the listing's rules (shapes, piece types for the
  palace and the preview, the cuts and quadrants, the wide pieces, the y offset index, the digit and letter conditions,
  the two choices by key and by click with the snapping, the garden and strip files); the composer on synthetic
  pictures and tables (the x walk, cuts, places and offsets, colour 0 transparent, CBACK or SAD, the strip and gardens,
  a missing picture counted); the preview, the prompt box and a label; T7; the improvement and the view from a
  synthetic stream through the scene and shadow engines (rows 124, 104, 25 and the N frame, the palette, the window
  and port claimed with every core drawing absorbed, the port's replaced bitmap followed at the device resolution, a
  DrawTile buffer with no shadow and nothing unexplained, the KING box's dialog anchored (a dialog 136 after it not),
  the prompt and labels at the core's positions, the choices at the waits' exits, the preview, row 104 ending at
  GR_DialogClose's entry, the reveal's 146 frames on PDOS_SEQ_FX_DISSOLVE, the end with the exit kind 1B44, the pointer
  rule, a garden without a preview, a refused choice, the arrival left to D7l, an unreadable state); the sad helpers.
  On the base the program does not exist (the module is new): every check fails there.
* **`tests/test_input.c`** (522 -> 529 checks in Checked): the seven I-palace vectors (modifier consumed, busy key
  consumed, Escape passed, a left press at class W in the palace window, the right button consumed, an any key and a
  left press at class X in the waits); the row count 123 -> 130; class W allowed for the palace's press only.
* **`tests/test_dos`** (23239 -> 23243): the registry goldens' four new tables (`tests/dos-decoded.txt` 1369 -> 1373
  lines).
* **`tests/harness/ext_adapt.py`, the d7j pair** (2 runs, 5 checks; `d7j_runs` after D7b's `d7b_runs`): CAE3540B.SAV
  edited to aliveCivsMask 3 (scenarios.py's CONQUEST.SAV route) as PALACE.SAV, loaded through the DOS title box (X, l,
  Return), turn 23 ended by Space (the palace improvement follows), Return on the KING box, a press at the N point (112,
  120) in the first selection wait (section 3), the key 1 (style 0), a press at (20, 190) in the last wait <-> the
  Windows form (the Windows title's Load, the same keys, the clicks where the DOS run gave them): the decisions
  I-palace/press, I-palace/key and I-palace/wait-press with two produced clicks; the core outputs equal; timeline.log's
  `palace` (O17:0000, row 124), `palace_choice` 3, `palace_style` 0, the reveal (frame 0 at the style's instant,
  `palace_reveal_end` 146 frames later), `palace_end` (O17:07DC, kind 1) and the return's fade (R:0238:1B44, 30
  frames); the 320 x 200 N frame from the palace's start to its end and the A frame after it; presentation-diag's
  `palace` line.
* **`tests/harness/ext_timeline.py`, the palace and palace_view runs** (8 checks; `palace_prepare`, `check_palace`,
  `check_palace_view`): palace (41 s, keys only: the section by the key 1, snapped to 3 by the core's rule; a Space
  during the reveal consumed and the reveal not cut short; the last Space by I-palace/wait-key; `palace_end` and
  `return` at the same instant, `return_fade_end` at frame 30; the N frame then the A frame) and palace_view (31 s: a
  click on the Status window's palace at host (80, 162) opens the view, `palace` R:0403:0796 row 104, no improvement
  step; the Space by I-palace/wait-key ends it within 50 ms (the window's destruction), the fade from black; the N
  frame then the A frame).
* `ext_p0.py`: unchanged; its `conquest` and `city` runs pass through the palace improvement and assert the counters.

## Results (private, `build/d7j-stage/obj/`)

Run in session E4 (2026-10-17, 09:30..10:55 UTC) after the rebase, on the overlay `obj/src` = the tree (after the D7a +
D7b landing and UX5b's copy-in; UX5b's cycle -r2 went ALL_GREEN at 10:49 UTC) + D7j's staged files, the bases of
`BASE-SHA256.txt` rechecked (BASES_OK):

* **Builds** (`obj/b.cmd`, the tree's build.cmd and flags with `--nogen`): Checked, CheckedNoObs and Release BUILD_OK
  (portable sources 298).
* **cc.cmd** (`obj/cc.cmd`: c11 and c17 /W4 /WX and the clang C99 parse, each variant) on `pdos_scn_palace.c`,
  `pdos_adapt.c`, `pdos_adapt_tab.c`, `pdos_profile.c`, `pdos_prov.c`, `pdos_registry.c`, `pdos_scene_tab.c`,
  `pdos_seq.c`, `test_pdos_palace.c`, `harness.c`: CC_OK in Checked, CheckedNoObs and Release.  `test_input.c`: its c11
  and c17 compiles pass; the clang parse reports only the base's own missing `square_only` initializer (line 176, as
  D6f, D7a and D7b recorded; build.cmd does not tidy the tests).
* **Unit** (`obj/unit.py`, the tree's build/gamedata read only): all 56 programs (test_ne aside) pass in Checked,
  CheckedNoObs and Release.  Against the D7a + D7b cycle (`build/d7ab-2-test-checked.log`): test_input 522 -> 529
  (CheckedNoObs 466 -> 473), test_dos 23239 -> 23243, test_pdos_palace new 118 (each variant); every other count
  equal (test_pdos_aspect 140 and test_pdos_seq 215 are UX5b's).  A first Checked run on an overlay that had UX5b's
  test files but D7j's pre-UX5b `pdos_seq.c` failed 21 of UX5b's checks; after the merge of `pdos_seq.c` (Rebase notes)
  all pass.
* **Checks** on the overlay: `registry.py check` (`--dosdata`, `--disasm` of the tree's build, read only) REGISTRY_OK, 0
  failures (336 `ok` lines, the tree's 317: the four tables and the include rule of `pdos_scn_palace.c` and `.h`);
  `obs_lint.py` OBS_LINT_OK files 128 probes 203 callsites 101; `obs_tables.py --check` (`obj/obstab.py`, the tree's
  listing) OBS_TABLES_OK probes 203 sites 101; `pdos_scene_check.py` PASS 1084 checks, 141 scene rows, 10 font rows;
  `adapters.py check` ADAPT_OK rows 130 steps 25 (`adapters.py gen` leaves the staged DOS-PROFILE.md unchanged);
  `nodos.py check --root obj/src` (the tree's dosdata and gamedata; the three variants' binaries) NODOS_OK, 1133 files,
  0 hits.
* **ext_adapt, every pair** (`obj/runadapt.py ... all`, the staged ext_adapt.py with the private Checked harness):
  EXT_ADAPT_OK checks 203 (the tree's 198 + the d7j pair's 5).  d7j: the decisions I-palace/press, I-palace/key,
  I-palace/wait-press, the clicks at (244, 272) (class W: the palace window's client origin + the logical point (112,
  120) at the device scale) and (320, 240) (class X: the client's centre); the DOS-form run equals its Windows-form pair
  (coreinput 22 lines, frames 578; exit 0, 0); timeline.log `palace` (O17:0000, row 124) at 30,503,750 us, choice 3,
  style 0, the reveal from 36,501,750 us to frame 146 at 38,584,839 us, `palace_end` (kind 1) at 39,501,750 us, the
  return's fade ending at frame 30; the N frame from the palace's start to its end (129 shows), the A frame after it
  (31 shows); the `palace` line: improvements 1, composed 3, pieces 21, king_boxes 1, prompts 1, labels 6, previews 1,
  reveals 1, reveal_frames 146, ends 1, absorbed 38, pic_missing 0, piece_none 0, yofs_out 0, unread 0.
* **ext_timeline** (the staged file in the overlay, `--exe` the private Checked harness, `--root obj/tl`, `--port` the
  tree): EXT_TIMELINE_OK, 49 PASS lines (the tree's 41 + 8): palace at 30,503,750 us, the reveal from the style's
  instant 36,501,750 us to frame 146 at 38,584,839 us with the Space during it consumed, `palace_end` (kind 1) at
  39,501,750 us and the fade's end at frame 30 (39,929,782 us); palace_view opened by the click at 27,101,200 us and
  ended by the Space at 29,503,200 us (R:0403:0826, kind 1), the fade to frame 30.  The `bs` group was not run (D7j
  changes nothing of Birth).
* **ext_p0** (the tree's runner, `--exe` the private Checked harness, `--root obj/p0root`, `--only conquest,city`):
  P0_OK checks 32 (V0..V7; V1 and V2 equal V0, the gate rows' counters 0).  `pdos_rows` of V1 and V2: no count on rows
  104, 124 and 25 (E3's renderer left `r104.unexplained` 10 in `conquest`); the `palace` line of `conquest`:
  improvements 1, king_boxes 1, previews 1, reveals 1, reveal_frames 140 (the scenario's script posts its keys to the
  core, not through the adapters, and one ends the last wait during the dissolve: its tail at once, F-new-2), ends 1,
  absorbed 38, unread 0; of `city`: views 1, ends 1.
* **The KING box's place** (private: `obj/explore.py king dos 32400 ... --dump-presented`, the palace route stopped
  before the Return on the box): the N frame's last dump (tick 530, 320 x 200) has the box's top-left corner (its
  black frame) at (20, 16), the sky at (19, 16) and (20, 15).

## Deviations from the brief

1. **Row 104's exit is GR_DialogClose's entry** (`pdos_scene_tab.c`; the brief's row keeps OpenPalaceView's return):
   the core waits for its key or click after OpenPalaceView returns (WdwStatusProc 1218:0225, RunPalaceImprovement's
   last wait), and DOS shows the palace through that wait (R:0403:080D, O17:078D); ending the row at the return would
   show the A frame during the wait.  The end itself is the palace window's destruction.
2. **Class W for I-palace/press** (as the brief says), with `adapters.py`'s rule for a passed frame-1 press extended by
   `W_SCENES` (the palace only) beside D7b's `P_SCENES`, and `test_input.c`'s table check the same.
3. **The sad palace's fade O17:0CB9 (30 frames) as TX is not run by D7j:** the sad palace is the arrival's (O2:1356 ->
   O17:07EC(1), ShowSpaceshipArrival 11D8:06B6), which is D7l's scene.  D7j provides the composer with sad = 1 and the
   tail's helpers (`pdos_palace_sad_fades`: DGROUP:D762 set and DGROUP:DEBA above 7, O17:0CA2..0CAE;
   `pdos_palace_sad_finish`: page 0 black and SAD.PIC's palette, O17:0CD4..0CE0); the arrival's call (RA 11D8:06BB)
   is left to D7l (`test_pdos_palace` checks it is not taken here).
4. **`pdos_fx.c` unchanged** (in the brief's list): the reveal uses the timeline engine's existing dissolve
   (`pdos_tl_dissolve`, G#10's frames per M10) on the palace's own timeline, and the return uses D7a's exit kind 1B44.
5. **The KING box anchored at DOS's (20, 16)** (not in the brief): found in E4's first look at the improvement (the
   re-skinned box at the core's (0, 0)).
6. **The palace port claimed at the device resolution and followed** (not in the brief): see "The shadow owner".
7. **`PDOS_OWNER_MAX` 8**, the combined value of the stacked tracks (D7a's report 6, D7d's city 7, D7j's palace 8), as
   the orchestrator set; `test_pdos_shadow`'s owner-limit test follows PDOS_OWNER_MAX by itself (no change).

## What the user checks

On the coordinator's user build (D7j landed; `civ64.exe`, DOS files present), in play with the DOS graphics
(Ctrl+Shift+Backspace or the host menu).  No Go Back or Cancel row appears anywhere in the palace:

* **D7j-1** The palace view: click the small palace (the sky and the castle) at the top of the Status window.  The
  window shows a 320 x 200 DOS screen (4:3 when "4:3 aspect ratio for 320 x 200 screens" is checked): your palace drawn
  the DOS way (the castle pieces of each built section over the blue sky and grass background, with the strip and the
  gardens where built) on black, the mouse pointer visible.  Any key or click closes it, and the map fades in from
  black.
* **D7j-2** The palace improvement (it comes at the end of a turn when your civilization's score has passed the next
  palace threshold, with the Palace game option on and a city of yours with a Palace): the DOS palace on black, the KING
  message in its box at the top left (20 pixels in, 16 down, not in the corner); after Return or a click, the DOS prompt
  box near the top and yellow digits 1..7 under the sections and letters A..C under the gardens.  Choose a section with
  its key or by clicking it: a blue panel at the top with a heading and three boxes showing the new section in its three
  styles, numbered 1..3; choose a style by key or click.  The palace shows again, then the new palace appears by a
  dissolve of about two seconds; any key or click returns to the map with the fade from black.  Keys pressed during the
  dissolve do nothing.
* **D7j-3** The same two with the Windows graphics: the Windows palace windows, unchanged.

Not part of this check: the spaceship arrival's palace and the sad palace (D7l), switching the graphics while the palace
shows.

## For the records

* **DESIGN 12.x "As implemented (D7j; area B and C)":** the palace renderer (composer O17:07EC(sad) from the core's
  palace state, the improvement's steps driven by the core's probes, the view); rows 124, 104 (its exit at
  GR_DialogClose's entry) and 25; the reveal G#10(1, 20) as TX on the palace's own timeline (PDOS_SEQ_FX_DISSOLVE) and
  its tail at the core's end; the return (exit kind 1B44); the KING box's anchor; the shadow owner "palace" (the window
  logical, the port at the device resolution and followed when replaced); T7 (row 107); I-palace (class W, X); the
  sad helpers for D7l; the `palace` diag line; PDOS_OWNER_MAX 8.
* **FIDELITY** (new entries, numbers to be assigned): F-new-1: the section and style are chosen by the core's rule from
  WaitForKeyOrClick's own point (class W), which equals the listing's (O17:024F..0292, 06E6..06EF), and its key reading
  (the core lowers the key at 1158:02AF; DOS reads it through R:1D05:0AC9 and takes no tolower: an upper-case A..C
  chooses no garden in DOS but one in the core); F-new-2: when the core ends the palace before the reveal's 146 frames
  (a key reaching its last wait some other way), the rest of the dissolve is shown at once (the tail); F-new-3: the KING
  box is the re-skinned core MenuZ box (row 14) placed at DOS's (20, 16); it closes as the core's box does (Return or a
  click); F-new-4: T7's level-0 pieces in quadrant 0 (inferred); F-new-5: the palace view's and the improvement's end
  wait for the core's key or click while the N frame holds (row 104's exit, deviation 1).
* **DOS-PROFILE.md prose:** rows 104 and 124 as staged ("as implemented in D7j"); 1.7.2 as generated.
* **RUNNING.md:** presentation-diag.log's `palace` line (improvements, views, composed, pieces, piece_none, yofs_out,
  pic_missing, king_boxes, prompts, labels, previews, reveals, reveal_frames, ends, absorbed, unread); timeline.log's
  steps `palace`, `palace_prompt`, `palace_choice`, `palace_preview`, `palace_style`, `palace_end` (sequence 1) and
  `palace_reveal`, `palace_reveal_end` (sequence 4, PDOS_SEQ_FX_DISSOLVE); ext_adapt's d7j-palace-dos and
  d7j-palace-win runs; ext_timeline's palace and palace_view runs; test_pdos_palace.
* **FEATURES.md:** the DOS palace (view and improvement) in play (D7j), with the runners above.
* **STATUS.md:** D7j landed (rows 104, 124; T7 row 107; the composer ready for D7l); the shadow owners 7 of
  `PDOS_OWNER_MAX` 8 until D7d lands.
* **manual-checklist-ext.md:** new items D7j-1..D7j-3 (above).
* User direction 2026-10-16 (no added Go Back / Cancel rows) and 2026-10-17 (boxes as tall as their content, no
  highlight where DOS draws none, 2x): the palace shows no Go Back or Cancel row; the prompt box is laid out for its
  line(s) with no highlight (drawn only, DGROUP:DB38); the KING box is the re-skinned row-14 box; everything on the N
  canvas at 2x.  Report items: none.
* Not edited by this unit: DESIGN.md, FIDELITY.md, STATUS.md, RUNNING.md, FEATURES.md, DOS-PROFILE.md outside rows 104
  and 124 and the generated section 1.7.2, manual-checklist-ext.md, the D1 drafts and the D0 documents.

## Expected changes at the build slot

Relative to the tree after the DBL landing (`build/dbl-2-test-checked.log`, ALL_GREEN 12:28:57 UTC; D7c's and DBL's
changes included; the detailed list is `build/d7j-prep/predictions.txt`):

* **Unit** (Checked and Release): a new program test_pdos_palace (118); test_input 522 -> 529, test_dos 23239 -> 23243;
  CheckedNoObs test_input 466 -> 473, test_pdos_palace 118, test_dos 23243; every other count unchanged.  Portable
  sources 299 -> 300; obs_lint files 130 -> 132; probes 203 and call sites 101 unchanged.
* `registry-check.txt`: REGISTRY_OK, 0 failures, 321 -> 340 `ok` lines.  `dos-decoded` goldens: 1369 -> 1373 lines
  (test_dos's "decoded content").  `pdos-scene-check.txt`: unchanged (PASS 1084 checks, 141 scene rows: row 104's exit
  changes, not the count).  `adapters-check.txt`: ADAPT_OK rows 123 -> 130, steps 25.  `obs-tables.txt`: unchanged.
  `nodos.txt`: byte counts grow with the binaries, the sources and the record; NODOS_OK.
* `ext-adapt.txt`: EXT_ADAPT_OK checks 203 -> 208; two more runs (d7j-palace-dos, d7j-palace-win; 41 s of virtual time
  each).
* `ext-timeline.txt` (base group): EXT_TIMELINE_OK with 8 more check lines (41 -> 49: palace 5, palace_view 3) and the
  runs line naming palace and palace_view; two more runs (41 s and 31 s of virtual time).  The `bs` group unchanged.  No
  golden file changes (the palace checks are computed from the listing's constants).
* presentation-diag.log (harness): a new `palace ...` line after the report line.  timeline.log: the `palace...` steps
  and the return's in runs that reach the palace (ext_p0's `conquest` and `city`, the new runs); no golden holds them.
* ext_p0: P0_OK with unchanged counts (476); `conquest`'s and `city`'s `pdos_rows` without counts on rows 104, 124 and
  25.  ext_dbl, ext_zoom, ext_frames, ext_mirror, ext_aspect: unchanged (none of their runs reaches the palace).
* Core outputs, G-1 fields and `ext_g1.py check`: unchanged (presentation only; the d7j pair and ext_p0 V1/V2 equal
  their references).
* Coverage: the new module is covered by test_pdos_palace and the harness runs above.

## Rebase notes

* **Rebased in E4 (2026-10-17, about 09:05..10:00 UTC) onto the tree after the D7a + D7b landing** (copy-in 08:07:35
  UTC, `build/d7ab-prep/landed.sha256`; ALL_GREEN 08:45 UTC) **and UX5b's copy-in** (09:35:23 UTC,
  `build/ux5b-prep/landed.sha256`; its cycle -r2 from 09:52 UTC).  D7j had been stacked on D7a's staged copies; every
  base is now the tree's file (`BASE-SHA256.txt`, written by `obj/mkbase.py`; `mkbase.py check` prints BASES_OK or
  BASES_MOVED), the overlay is the tree + D7j (`obj/mkoverlay.py` without a lower stage), and the staged copies before
  the rebase are kept in `obj/pre-rebase/`.  Each file both D7j and a landed unit change was merged three ways (base:
  D7j's earlier base, D7a's staged copy or the tree before UX5b; theirs: the tree now; mine: D7j's copy; scratch
  results checked by diff before staging):
  * `pdos_adapt.c`: one conflict, the frame-1 press's class check: D7b's class P and D7j's class W both allowed with a
    scene window, as one condition (`(r->i5 != PDOS_I5_P && r->i5 != PDOS_I5_W) || sc->x_hwnd == 0u`); D7j's palace
    scene block (after D7b's REPORT_INFO and D7a's REPORT blocks) merged without a conflict.
  * `pdos_adapt.h`: `PDOS_AS_REPORT_INFO` 0x04000000 (D7b) then `PDOS_AS_PALACE` 0x40000000; a paragraph for the palace
    added to the header's scene notes after D7b's.
  * `pdos_adapt_tab.c`: the I-palace block after D7b's I-report/info block.
  * `gen/dos/adapters.py`: four conflicts, all where both add lines: the docstring's class sentence, SCENES (D7b's row,
    then D7j's), `P_SCENES` and `W_SCENES` both kept, the 1.7.2 preamble sentence (D7b's clause, then D7j's), and the
    passed-press rule (class P only in `P_SCENES`, class W only in `W_SCENES`).
  * `tests/harness/ext_adapt.py`: the docstring (D7b's paragraph, then D7j's), `d7b_runs` then `d7j_runs`, main's calls
    in that order.  The tree's docstring had the line "Prints one line per check and EXT_ADAPT_OK ..." joined onto
    D7b's last line ("... no nest). and EXT_ADAPT_OK or ..."); D7j's copy restores it as its own line after D7j's
    paragraph (a one-line, separable correction of D7b's text).
  * `tests/test_input.c`: the scene window (REPORT_INFO's 0x2F8, then PALACE's 0x3F8), the vectors (D7b's, then D7j's),
    the table's class check (A, P for REPORT_INFO, else X; W for the palace's press), the row count 123 + 7 = 130.
  * `present/dos/pdos_shadow.h`: D7b's comment on the negative claim and D7j's `PDOS_OWNER_MAX` 8, without a conflict.
  * `present/dos/pdos_seq.c`: onto UX5b's copy (4b8369d4) without a conflict; D7j's three lines unchanged.
  * `docs/DOS-PROFILE.md`: D7j's earlier copy predated D7a's (the D6 docs pass of 07:33 UTC was missing); it was rebuilt
    from the tree's file (d90185b4, after the D7a/D7b docs pass of 09:13 UTC) with D7j's rows 104 and 124 only, and
    1.7.2 regenerated by `adapters.py gen` on the overlay (130 rows).
  * Unchanged by the landings (tree = D7j's base): `OFFSETS.md`, `registry.py` (D7a's `pdos_scn_report.c` entry is in
    the tree now, so D7j's hunk adds `pdos_scn_palace.c` only), `pdos_profile.c`, `pdos_prov.c/.h`,
    `pdos_registry.c/.h`, `pdos_scene_tab.c`, `dos-decoded.txt`, `ext_timeline.py`, `harness.c`.
* **Rebased onto D7c's copy-in** (10:57 UTC 2026-10-17, `build/d7c-prep/landed.sha256`).  The bases recorded at
  10:58 UTC were the tree's files after that copy-in, while the staged `pdos_adapt.c`, `pdos_profile.c` and
  `ext_adapt.py` still carried the tree before it: a base check alone would have passed and the copy would have
  removed D7c's hunks.  A diff of the tree against the stage before the landing found it (11:12 UTC); the three files
  were merged three ways (`git merge-file -p`, files only; base: `build/d7c-prep/tree-before`, theirs: the tree, mine:
  D7j's copy; the earlier copies kept in the scratch folder):
  * `pdos_adapt.c` and `pdos_profile.c`: no conflict.  D7c's `pdos_report_active()` (a quiet report too) is kept in
    the scene and pointer rules, D7j's palace block follows it, D7j's pointer rule adds `pdos_palace_pointer_hidden()`
    to D7c's line.
  * `ext_adapt.py`: two conflicts where both add lines: the docstring (D7c's paragraph, then D7j's, then D7c's closing
    line "Prints PASS/FAIL lines and EXT_ADAPT_OK ...", which replaces D7j's earlier restoration of that line) and
    main's calls (`d7c_runs`, then `d7j_runs`).  No line of the tree's copy is removed.
  The private checks were run again on the tree after D7c's landing with the merged copies (Results).
* **Rebased onto DBL's copy-in** (11:50:46 UTC 2026-10-17, `build/dbl-prep/landed.sha256`; the orchestrator's order:
  the user's rework DBL before D7j).  Of DBL's 15 files only `pdos_profile.c` is also D7j's: merged three ways
  (`git merge-file -p`, files only; base: D7j's base 877fe454 = DBL's tree-before, theirs: the tree's b9a288ca, mine:
  D7j's copy 790ed85d, kept in `obj/pre-dbl/`): one conflict in `dos_advance`, where both add a line after the map's
  advance; both kept, D7j's `pdos_palace_advance(now_us)` then DBL's `pdos_aplay_advance(now_us)` (the blink on its own
  clock at every tick; DBL's `pmap_dos_blink_apply` before `pmap_dos_present` / `pmap_world_update` untouched).  The
  merged copy (f44068d3) is the tree's file plus D7j's seven hunks (the include, the pointer rule, reset, on_event, the
  two on_probe calls, the advance), checked by diff against both sides.  DBL's `test.cmd` (a read-only reference here:
  the new `ext_dbl` section) changes nothing staged.
* **Rebased onto the docs pass docs-e4b** (UX5b + D7c + DBL; applied 12:37:56..12:38:04 UTC, `build/docs-e4b-done.txt`
  12:52:30 UTC).  Of its files only `docs/DOS-PROFILE.md` is D7j's: merged three ways (base: the tree after DBL's
  copy-in, d90185b4, snapshot `obj/bases-dbl/`; theirs: the tree's 3ea5300a; mine: D7j's copy, kept in
  `obj/pre-docs/`): one conflict where rows 123 and 124 are adjacent: the tree's row 123 (D7c's "as implemented"
  text) and D7j's row 124 kept; every other hunk (row 104's I-palace, 1.7.2's preamble clause and its seven I-palace
  rows) merged cleanly.  On the overlay (the tree + D7j, 12:53 UTC): `adapters.py gen` leaves the merged copy unchanged
  (ADAPT_GEN rows 130), `adapters.py check` ADAPT_OK rows 130 steps 25, `pdos_scene_check.py` PASS 1084; the merged
  `pdos_profile.c` CC_OK (c11, c17 /W4 /WX, the clang C99 parse) in Checked, CheckedNoObs and Release.  The bases were
  written again (`obj/mkbase.py`, 12:53 UTC, BASES_OK); a diff of every staged file against the tree removes only
  lines D7j replaces (the D7b-era class check, row 104's I-wait, `PDOS_OWNER_MAX` 6, the row count 123, registry.py's
  list end, adapters.py's class-P rule and preamble).
* **Shared tables at a later landing** (D7d, D6fS, DBL or another D7 unit first): `pdos_adapt.h`'s scene bits (D7a
  0x02000000, D7b 0x04000000, D7d 0x08000000, D7j 0x40000000; 0x20000000 reserved for D7l); `pdos_shadow.h`'s
  `PDOS_OWNER_MAX`: 8 is the combined value with D7d's city (if D7d lands first with 7, keep 8 and both comments);
  `pdos_adapt_tab.c` and `test_input.c` (the I-palace block and vectors after the other units' blocks; the row count
  adds 7 to whatever the tree has); `adapters.py` (`W_SCENES` beside `P_SCENES`; another unit's scene rows before
  D7j's in SCENES); `ext_adapt.py` (`d7j_runs` after the other units' runs); `registry.py` (one entry);
  `pdos_profile.c`, `pdos_seq.c`, `harness.c`, `pdos_prov.c/.h` (one-line hooks and a delimited block each);
  DOS-PROFILE.md 1.7.2 regenerated by `adapters.py gen` on the merged tree, never by hand; PROF row 107 (T7).
* Shared counts: one new source file (`pdos_scn_palace.c`, portable sources +1), one new test program, obs_lint files
  +2; the obs tables unchanged (probes 203, call sites 101).
* **The tree read during the slot's build:** `obj/mkoverlay.py` copies the tree's source folders, docs included.  A copy
  ran at about the time of UX5b's first step 1 (09:35 UTC), whose gen/interfaces.py could not write docs/API-MAP.md (a
  transient lock); the overlay's copy may have held the file open then.  Later copies were made only after the slot's
  generators had run.

## Landing

D7j landed alone at the build slot of session E4 (track C), 2026-10-17, after DBL's landing (its RELEASE_OK 12:35:29 UTC
and `build/user-builds/dbl/`) and the docs pass docs-e4b (UX5b + D7c + DBL; `build/docs-e4b-done.txt` 12:52:30 UTC), as
the orchestrator ordered (D7c, then the user's rework DBL, then the docs pass, then D7j).  The user checks D7j-1..D7j-3
are in the user build `d7j`.

* **Bases:** rebased onto DBL's copy-in and the docs pass (Rebase notes: `pdos_profile.c` and `docs/DOS-PROFILE.md`
  merged three ways), the bases written again at 12:53 UTC (`obj/mkbase.py`, BASES_OK) and rechecked by
  `build/d7j-prep/land.py` (every base of `BASE-SHA256.txt` equal, the four new files absent, the eleven read-only
  references unchanged; DRY_RUN_OK 24).  Scripts in `build/d7j-prep/` (from `build/d7c-prep/` by `mk_prep.py`;
  `land.py` and `fill_stillopen.py` adapted).  Snapshot `build/d7j-prep/before` (the tree's `build/test/Checked`
  outputs of DBL's cycle, 65 files) and `tree-before` (the twenty replaced files); copy-in at 12:54:30 UTC
  (`landed.sha256`: the twenty-four files, build.cmd and test.cmd unchanged; `landed-at.txt` "unit d7j").  Predictions
  `build/d7j-prep/predictions.txt`, written before the copy-in.
* **The three-step cycle** (`build/d7j-status.txt`): 1 `build.cmd checked` BUILD_OK 12:54:37..12:59:07 (271 s; portable
  sources checked 300); 2 `test.cmd checked` TESTS_OK 12:59:07..13:29:28 (1821 s; TEST_SECTIONS 30 failed 0; no flake
  rerun); 3 `ext_g1.py check` EXT_G1_OK runs 77 (amended 1) unchanged: **ALL_GREEN**.  4 `build.cmd` (Release) BUILD_OK
  13:30:09..13:34:07 (239 s; portable sources 300): **RELEASE_OK**.
* **Against the predictions** (`build/d7j-prep/compare.py` against the snapshot; `compare.txt`: 49 of 65 files equal,
  host times left out): as predicted, unit.log test_pdos_palace new 118, test_input 522 -> 529, test_dos 23239 -> 23243
  ("decoded content" 1369 -> 1373 lines; registry 50 -> 54 tables), every other count equal; registry-check REGISTRY_OK
  with 19 more `ok` lines (the four palace tables, their readers, the include rule of `pdos_scn_palace.c/.h`; 321 ->
  340); OBS_LINT_OK files 130 -> 132, probes 203, call sites 101; adapters-check ADAPT_OK rows 123 -> 130 steps 25;
  obs-tables and pdos-scene-check (1084) unchanged; EXT_ADAPT_OK checks 203 -> 208 (the five d7j-palace lines equal to
  the private run: I-palace/press, I-palace/key, I-palace/wait-press, clicks at (244, 272) and (320, 240), coreinput
  22, frames 578, the palace's timeline and the `palace` line); EXT_TIMELINE_OK with 49 PASS lines (41 + 8: palace
  5, palace_view 3; the runs line names palace and palace_view); P0_OK checks 476; REPLAY_OK checks 70; EXT_DBL_OK
  and every other harness section unchanged.  Not predicted in detail, explained (each "may change" in the
  predictions): (a) ext-p0's V4d zoom lines: conquest 112 -> 103 shows with the layer (the palace improvement shows the
  N frame instead of the zoomed A frame), city 153 -> 163 (the palace view's return fades from black over 30 frames,
  each a presented A frame with the layer); (b) ext-replay's informational V1 lines of city (brackets 0/46/0 -> 0/46/1,
  draws 0 -> 1, no_scene 2 -> 1) and conquest (brackets 0/22/17 -> 0/22/19, draws 10 -> 12, no_scene 73 -> 71): rows
  104 and 124 (with row 25's KING box) are scenes now, so the replay draws their texts on the palace owner's shadows;
  (c) coverage.txt "other functions entered" 667 -> 671 (informational); (d) nodos files 1774 -> 1779, 0 hits; (e)
  unit.log's OBS_COST line (host timing).
* **User build** `build/user-builds/d7j/`: `civ64.exe` (the Release build, SHA-256 e98ce201...), `CIVWIN.zip` and
  `civdos.zip` from `build/user-builds/d4/`, `WHAT-TO-CHECK.txt` (D7j-1..D7j-3, the earlier builds up to "dbl", and the
  83 items still pending in the checklist at 13:29 UTC, DBL's five with D6e-2 and D6e-5 among them).
* Not done at this slot: the checklist sections and STATUS rows (the orchestrator's) and the docs pass for D7j; the
  tree's CheckedNoObs build is not part of the three-step cycle (the private overlay builds and units of the three
  variants are in "Results").

# Extension phase D6, unit D6e (the small map, the Status window and the unit panel; the play palette's return) - record

Draft for the build slot (BRIEF-d6.md "Units" D6e).  Staged in `build/d6e-stage/` on the tree after the D6d landing
(ALL_GREEN 14:34:38 UTC, RELEASE_OK 14:39:06 UTC) and its docs pass (build/docs-d6d-done.txt 14:58:19 UTC): the bases
were copied to `obj/base` at 15:00:48 UTC.  The staging paused for the priority units MZ and MZW (the user's zoom
reports) and was rebased on both after they landed (MZ ALL_GREEN 18:12:28 UTC; MZW LANDED 18:37:25 UTC, ALL_GREEN
19:04:41 UTC, RELEASE_OK 19:12:04 UTC): the bases of `present/map/pmap_smrect.c`, `tests/headless/harness.c`,
`tests/harness/ext_zoom.py` and `tests/harness/ext-zoom-golden.txt` were copied again at 18:39 UTC (the MZW tree),
`tests/test_pdos_profile.c` at about 19:20 UTC, `present/dos/pdos_shadow.h` and `tests/test_pdos_shadow.c` at about
19:41 UTC.  UX5 landed during the staging (its cycle from 20:28:11 UTC, ALL_GREEN 21:17:06 UTC, RELEASE_OK 21:23:22
UTC): the staged `present/dos/pdos_profile.c` was rebased on its copy and the bases of `pdos_profile.c` and
`test.cmd` copied again at 20:48 UTC.  MZI landed after it (its files in the tree at 21:29:09 UTC, ALL_GREEN
22:08:45 UTC): the staged `tests/harness/ext_zoom.py` was rebased on MZI's copy and the golden written again on the
overlay with MZI; their bases copied again at 22:24 UTC.  MZS landed last (its files in the tree at 23:47:40 UTC,
ALL_GREEN 00:25:05 UTC, RELEASE_OK 00:30:32 UTC): the staged `tests/harness/ext_zoom.py` was rebased on MZS's copy
(its base copied again at 23:51 UTC; MZS does not change the golden) and the Checked variant built, unit-tested and
checked again on the overlay with MZS (section "Rebase notes").  Every base is rechecked equal to the tree in
`BASE-SHA256.txt`.  Private builds and runs in `build/d6e-stage/obj/` only (an overlay `obj/src` = tree + stage,
built with build.cmd's own flags; the private runs use copies of the overlay's Checked harness in `obj/exe`, never
the tree's executables).

## Status

LANDED 2026-10-17 00:55:23 UTC; cycle ALL_GREEN 01:23:53 UTC, RELEASE_OK 01:28:06 UTC; user build
`build/user-builds/d6e/` (see Landing).  READY_TO_BUILD was reported at 00:51 UTC, staged on the tree with MZ, MZW,
UX5, MZI and MZS (every base equal to the tree: `BASE-SHA256.txt`).  Implemented: draft B 12.1..12.4 (the DOS small
map, the Status window and the unit panel as class-A elements of the new module `pdos_aplay`), B 5.5 item 2 (the
play palette's return at RestoreMapAfterDialog), R3 (the play palette's life cycle across a profile switch) and
draft D 19 (the DOS small map is not zoomed: ext_zoom's "not zoomed" check).  Private builds, unit tests, the four
checks, the DOS goldens of ext_zoom and the P0 variations that reach the module pass (section "Results"); P0 holds
(the Windows profile's frames, every core output and every G-1 field unchanged).  The user's visual checks
D6e-1..D6e-7 are pending (section "What the user checks").

## What was built

### The module `pdos_aplay` (`present/dos/pdos_aplay.h/.c`, new; draft B 12.1..12.4, B 2's `pdos_play.c`)

* **The name.**  Draft B 2 names the class-A play module `pdos_play.c`, but `pdos_pal.h` already uses the
  `pdos_play_*` names for the play palette (D6c; the brief says to pick non-colliding names and record them): the
  module is `pdos_aplay` ("A-canvas play"), its public names `pdos_aplay_*`, its owner name in the shadow engine
  `"aplay"`, its size macros `PDOS_APLAY_SM_W` / `PDOS_APLAY_SM_H` (80 x 50).
* **Macros** (owner "aplay", `PDOS_MAC_DROP`, the DOS rule set only; B 7.3): DrawSmTiles 1210:09B4, RedrawSmMap
  1210:073F, PlotSmMapSquare 1210:07AE (the small map, B 12.2), RedrawStatusWindow 1218:0801, DrawStatusCivPanels
  1088:13D5, DrawMiniPalace 1088:1A82 and DrawUnitInfoPanel 11F0:468C (the Status window, B 12.3).  Their targets
  are the World Map's and the Status window's hwnds (`g_worldMapWindowPort` 12B0:001C, `g_statusWindowPort`
  12B0:0034, +0 hwnd); DrawMiniPalace's only inside DrawStatusCivPanels.  The leaves draw nothing.
* **Drawing at the exits.**  Each element is drawn whole from this module's model at the exit of the function that
  changed it (`pdos_aplay_on_probe` from the profile's exit step 3, after the engine's leaves), into a surface of
  the module that the A canvas composes at the window's client, clipped to its visible region and to what is drawn
  over the windows (open menus' popups, the move/size outline: the map element's rule; `pdos_aplay_present` at
  every core present).  A hidden or minimised window, or one without a visible region, removes its element.
* **The small map (12.2, PROF row 139).**  At DrawSmTiles' exit the module reads the core's state that DrawSmTiles
  itself just read: `g_tileVisibility` 13E8:000A with `g_mapViewerCivMask` 1408:00CC, the terrain through
  `g_lpScreenBuffer` 1420:B394 and `g_terrainByMapColor` 12D8:0000 (GetTerrainType 1110:16C0's rule; the 16-bit
  offset wraps as 11E8:0DF3's), `g_cities` 1420:54FC, `g_humanPlayer` 12D8:4300, `g_smMapScale` 1410:0000,
  `g_smMapViewFrame` 1420:B3CC, `g_mapViewLeft/Top` 1330:4010/400E, and the World Map data block's visible flag
  (+2Ch, 1210:0A00: a hidden World Map draws nothing).  The model is one DOS colour per square: never seen 0,
  ocean 1, land 2 (OB6: R:0866:034C..0376), a city of the core's set (status not FFh, a known size or the
  human's) in its owner's main colour DGROUP:1946 (R:1AEA:17FF; OFFSETS.md `CIV_MAIN_COLOUR`).  It is drawn at
  the core's scale and geometry (one square = `g_smMapScale` device pixels; the view origin at the frame origin,
  1210:0EBD, and its east-west wrap copy, 1210:0F03), colour 0 outside the image, the bevel R:1D05:0A66(0, 0,
  w - 1, h - 1, 15, 8) at the client's edges and the view frame (D's P9: the core's columns and rows) as a
  colour-15 outline R:1D05:0A05 one DOS pixel outside the core's frame.  PlotSmMapSquare's exit plots one square
  (1210:0856..08CA's position and wrap rules) in the DOS colour of the core's: its system colour mapped back to
  the EGA index (EGA 6 land -> DOS 2, PROF row 132; EGA 1 ocean 1; EGA 15, the blink, 15), a city square plotted
  by MoveUnit (call site 11C0:1271) in the owner's DOS main colour; the model follows the plot.
* **The zoom area (rebase on MZW).**  `pdos_aplay_set_zoom_area`, called by `pmap_smrect.c` at each evaluation
  of the World Map's patch: at map zoom -1 and +1 the DOS small map's outline surrounds the area the main map
  window shows (the same area as the Windows World Map's rectangle, `zoom_rect`, with FrameRect's r - 2, b - 2),
  with its two east-west wrap copies; at level 0 (or no World Map drawn) the core's frame.  A change redraws the
  element; the model's squares are not changed by it.
* **The Status window (12.3, PROF rows 136, 138).**  Inside the three panel functions the TEXTOUTs into the Status
  back port (the bitmap of `g_statusBackPort` 12D8:4580 when the function began; others ignored) are captured in
  order (`pdos_aplay_on_event`, the profile's on_event step 4): the status panel's population (when not zero),
  year and treasury/rates lines, the unit panel's lines.  DrawTile 11A8:0CB1 entries give the mini palace's
  handles by slot (inside DrawMiniPalace: slot = (x - DrawMiniPalace's x) / 14, 1088:1D1A) and the research and
  warming icons' handles (`g_statusIconShapes`, the provenance table `PDOS_PT_STATUS`).  At DrawStatusCivPanels'
  exit `g_peaceTurns` 12D8:38F0 is read and the status model committed; at DrawUnitInfoPanel's exit the unit model
  (DrawUnitInfoPanel(civ, unit)'s arguments; the unit's record: veteran flag 20h, 11F0:4874; the square's city's
  two stored units as fortified dummies, 11F0:4C28..4D3F; the stack ring in the core's order, 11F0:4D9B, at most
  128).  The column is drawn in Choice B18's layout at 2x from the client's top-left on a DOS-resolution surface
  `max(80, ceil(cw / 2)) x max(40, ceil(ch / 2))`: the texture (`pdos_texture`) everywhere, the status panel DOS
  (0, 58, 80, 39) at (0, 0) (R:0238:107E: the panel, the sky colour 11, the peace bar (3, 60, clamp(2n, 0, 60), 2)
  colour 15 when n > 1 (OPEN L4: D808 as the peace turns, inferred), the ground line (3, 71)..(76, 71) colour 2,
  the nine palace strips at (8 + 7i, 57) by provenance, the lines at y 73, 81, 89, x 2, colour 0, font 1, the
  research icon at (48, 80) and the warming icon at (56, 80) by provenance), the unit panel DOS (0, 97, 80, 103)
  at (0, 39) extended to the bottom (R:0403:407C; one line every 8 rows from y 99, x 4, colour 0; "Veteran"
  DGROUP:20A3 at x 8; 4 rows lower the garrison and the stack ring, four to a row at x 8, 24, 40, 56 while the row
  is above the bottom - 16, the icons as the D6c map draws units (R:1AEA:0FB3); "+" DGROUP:20F1 at (74, bottom - 8)
  when units are left (R:0403:43D2..44F4); for the end of turn (unit 80h) the DOS words "End of Turn", "Press
  Enter", "to continue" DGROUP:207F, 208B, 2097 at (4, 124), (4, 136), (4, 144), R:0403:408B..40C7).  The
  "End of Turn" blink: BlinkActiveUnitUntilInput's TEXTOUTs outside the panel functions (11C0:1019, 114A; the core's
  EGA 14 or 0) set the word's colour, DOS 7 or 0 (R:0866:0AD6; PROF row 132).
* **The play palette's return (draft B 5.5 item 2, decision 5).**  At RestoreMapAfterDialog 1208:14D5's entry the
  A machine's DAC becomes SP256.PAL with entries 128..255 from `back<g><a|m>.pal` (R:0238:1BEB): g from the human's
  `g_government` 12D8:3B8A as GetCourtStyle 1160:3487 selects it (R:0238:1C1B..1C30: government / 2, toward 0;
  government 3 alone gives '3' without 'm'), 'm' after advance 14h (`g_civKnownAdvances` 12D8:3F0E;
  PlayerKnowsAdvance 1170:3196: never for player 0) (OB1).  A style without a DOS file (back3m) and a missing
  file leave the palette (`pal_none`).  Applied only when the recipe differs from the DAC outside the play slots
  60h..7Fh (`pal_same` otherwise; decision below).
* **R3 (the D6c review's, `present/dos/pdos_pal.c/.h` `pdos_play_back`).**  The DOS return path restarts the
  stopped slots through R:1DC4:0626 / R:0000:03FA (direction +, the countdown reloaded) without R:0000:0382's
  capture: each slot keeps its captured colours and position, and the next cycle writes them one step on over the
  recipe's entries 96..127.  `pdos_play_back` now does that (it captured again and reset to position 0); a slot
  never set up (no WdwMapOpen exit yet; DOS has no such state) is set up from the new DAC (a guard).
* **The owner table** (`present/dos/pdos_shadow.h`): `PDOS_OWNER_MAX` 4 -> 5.  The product now registers four
  owners (setup, pmap, replay, aplay; DESIGN 12.7 "takes the last slot or raises PDOS_OWNER_MAX"), and the test
  programs register one more of their own (test_pdos_profile's "D" after the profile's reset).
* **Wiring** (`present/dos/pdos_profile.c`, single marked `extension D6e` lines): the include, `pdos_aplay_reset()`
  in the profile's reset (after the shadow engine's and the composition's), `pdos_aplay_on_event` at on_event's
  step 4 (after the re-skins), `pdos_aplay_on_probe` at entry step 6 (after the shadow engine) and at exit step 3
  (after the engine's leaves), `pdos_aplay_present()` at every core present; the header comment's renderer note.
  `pdos_compose.c` is unchanged (the elements use the composition's existing `pdos_compose_elem_set` with clip and
  exclusion lists).
* **DOS words** (decision 8; `docs/dos/OFFSETS.md`, `gen/dos/registry.py`, regenerated `pdos_registry.h/.c` and
  `tests/dos-decoded.txt`): `UNIT_END_TURN` DGROUP:207F (3 strings, R:0403:4096, 40AD, 40C4), `UNIT_VETERAN`
  DGROUP:20A3 (R:0403:4150), `UNIT_MORE` DGROUP:20F1 (R:0403:44F1); registry.py's OBSERVER_FILES gains
  `pdos_aplay.c` (it reads through `w16q_read`, `w16q_wnd`, `w16q_wnd_client_vis`, `w16q_menu_state`,
  `w16q_sys_track`, `w16q_block`).  No DOS byte is held: the words and pictures are read at run time.
* **P0.**  Every read goes through the query (`w16q_*` under the observer; nothing under CIV_OBSERVER 0, where the
  default queries return nothing), only this module's memory and the A machine's DAC are written, no random number
  is drawn, no event is posted.

### Harness and runner

* `tests/headless/harness.c` (`profile_sample`, an `extension D6e` block in the level != 0 branch): profiles.log's
  sample lines gain ` smmap SHA` (the SHA-256 of the DOS small map's model, 80 x 50 DOS colours, without the
  outline or the zoom area) whenever the DOS profile has drawn one, whichever profile is visible.
* `tests/harness/ext_zoom.py` (draft D 2 and 5.8 "not zoomed", 19's rule coverage): `smmap` joins the per-run
  layer-sample comparison (equal in win b, dos a and b and sw at every common sample time), and a new check: the
  same scenario, size, policy, profile and copy have equal `smmap` at -1 and at +1 at every common sample time (the
  small map is not zoomed; the core's run does not depend on the level, P0).  `ZOOM not zoomed FAIL ...` when a
  pair differs, or when no pair exists in a run with the DOS profile; the ZOOM_OK line gains `not zoomed
  PAIRS/SAMPLES`.  The goldens' `dos` lines change (the DOS profile's play view now shows the DOS small map and
  Status window).

## Tests

* `tests/test_pdos_play.c` (new; B 15.1; Checked, CheckedNoObs and Release: 46 checks each): a synthetic segment
  memory, every query injected (`PdosAplayQ`, the DOS words and main colours), synthetic ObsEvent/ObsProbe streams;
  the DOS data opened at run time from build\dosdata for the fonts, palette files and textures:
  * the small map from a model: the image at the core's geometry (scale 2), its wrap copy 160 to the right, colour 0
    outside, the bevel, the view frame's outline; MZW: the outline around the zoom area (and its wrap copies), the
    squares unchanged, an empty area or level 0 the core's frame again, the same area again nothing; PlotSmMapSquare's
    square and wraps (1210:0856..08CA); the colour mapping (EGA 6 -> 2);
  * the small map from the core's state at DrawSmTiles' exit: seen ocean 1, seen land 2, never seen 0, cities in their
    owner's main colour (known size or the human's), the screen buffer's 16-bit offset wrap, a hidden World Map
    drawing nothing; PlotSmMapSquare's exit from the core's system colour and MoveUnit's city plot; the zoom area kept
    across DrawSmTiles; the element placed, unchanged presents setting nothing, removed when the World Map hides;
  * the Status window: the status lines captured from the TEXTOUTs into the Status back port (another bitmap's
    ignored), the palace handles by slot, the peace turns, the sky 11, peace bar 15 and ground line 2; the unit panel's
    lines, Veteran, the city's stored units and the stack ring in the core's order (a ring that never returns: at most
    128), "End of Turn" and the blink's colours 7 and 0, a blank panel for civ -1; both elements on the A canvas;
  * the palette's return at RestoreMapAfterDialog: the back file by government and the modern variant (SP256.PAL
    with back1m.pal), applied once, then `pal_same`; style 7 (government 6, modern): no file, nothing; the elements
    removed at the reset; no host allocation left.
* `tests/test_pdos_pal.c` (R3): the return after three cycles keeps the slots' captured colours and positions,
  direction + (no capture); the next cycle writes the captured colours one step on over the recipe's 96..127; slots
  never set up are set up from the recipe palette (the guard).  236 -> 239 checks.
* `tests/test_pdos_shadow.c`: the owner-limit check fills the slots beyond the test's four owners first (one
  `extension D6e` block; a new check "the free owner slots accept an owner each"), then a further owner is refused:
  174 -> 175 checks (Checked, Release).
* `tests/test_pdos_profile.c`: `clear_registrations` also clears the owner "aplay"'s macros (one marked line; the
  profile's reset registers them again).  51 checks, unchanged.
* `tests/dos-decoded.txt`: the three table lines (1360 -> 1363 lines); test_dos 23230 -> 23233 checks.
* ext_zoom's "not zoomed" check and the rewritten `dos` goldens (above); P0 (ext_p0) and the other DOS-profile
  sections privately (section "Results").

## Results (private, `build/d6e-stage/obj/`)

All on overlays `obj/src` = tree + stage, built with build.cmd's own flags (`obj/b.cmd`, `--nogen`); the private runs
use copies of the overlay's Checked harness in `obj/exe`.  The tree moved three times during the staging, so the
evidence comes from three harnesses (the machine carried other units' build slots throughout; times are under load):

| harness | overlay | used for |
|---|---|---|
| H1 `d6e-harness-final.exe` (89f81ef1...) | the MZW tree (about 19:25 UTC) | `final.sh` (three variants); the first ext_zoom matrix; every DOS-profile section |
| H3 `d6e-harness-f3.exe` (0893518d...) | the tree with UX5 and MZI (22:25 UTC) | `final3.sh` (three variants); the golden written (`--update`), DOS determinism; ext_frames, ext_adapt, P0 V1 and V4d, ext_replay again |
| H4 `d6e-harness-f4.exe` (7939794b...) | the tree with MZS (00:31 UTC) | `final4.sh` (Checked): build, unit tests, checks, the DOS goldens again |

* **Builds and stricter checks** (`final.sh` with H1, `final3.sh` with H3): build.cmd's three variants: BUILD_OK each,
  portable sources 295 (c11, c17, the C99 parse); cc.cmd's checks (c11 and c17 /W4 /WX, the clang C99 parse with
  -Wextra) on `pdos_aplay.c`, `pdos_profile.c`, `pdos_pal.c`, `pdos_registry.c`, `pmap_smrect.c`,
  `tests/test_pdos_play.c`, `test_pdos_pal.c`, `test_pdos_shadow.c`, `test_pdos_profile.c` and
  `tests/headless/harness.c`: CC_OK in each variant.  `final4.sh` (H4, Checked, with MZS, 00:31..00:49:40 UTC):
  BUILD_OK (portable sources 295), CC_OK, the unit tests and the checks as below.
* **Unit tests** (`obj/ut.sh`, 48 programs, `<gamedata> <outdir>` under the stage): all pass in Checked, CheckedNoObs
  and Release (H1 and H3 overlays; Checked again on H4's), test_dos included when it reads the staged golden: it reads
  `<gamedata>\..\..\tests\dos-decoded.txt`, so it also ran with argv[1] a private copy of build\gamedata inside the
  overlay (deleted afterwards): PASS 23233 checks, `decoded content: 1363 lines, 0 differing` in each variant; with
  the tree's gamedata it compares the tree's 1360-line golden and fails by design.  Counts: test_pdos_play 46 / 46 /
  46 (new), test_pdos_pal 239 in each (236), test_pdos_shadow 175 / 173 / 175 (174 / 172 / 174), test_dos 23233
  (23230), test_pdos_profile 51 / 47 / 51 (unchanged), test_map as the tree's (285; 305 with MZI; 338 with MZS);
  every other count equal to the tree's unit log.  The side outputs (pdos-p4-report.txt, present-goldens.txt,
  timeline-intro-steps.txt and the others) equal the tree's (timeline-partitions.txt: host times only).
* **Checks** (each final run): `obs_lint.py` OBS_LINT_OK files 122 probes 203 callsites 98 (the tree's 120:
  `pdos_aplay.c/.h`); `testpar.py check` on the overlay's test.cmd (unchanged): exit 0; `gen/dos/registry.py check`:
  REGISTRY_OK with 13 lines more than the tree's registry-check.txt (the include rule for `pdos_aplay.c` and `.h`;
  `UNIT_END_TURN`, `UNIT_VETERAN`, `UNIT_MORE` with their readers R:0403:4096, 40AD, 40C4, 4150, 44F1 and no writer)
  and `tests/dos-decoded.txt equals the Python models' output (1363 lines)`; `gen/dos/nodos.py check --variant
  Checked --root obj/src`: NODOS_OK, 0 hits (616 files of the overlay with MZI, 618 with MZS).
* **ext_zoom with `--update`, the whole matrix** (the staged runner through `obj/runzoom.py`, the tree's gamedata,
  dosdata and cache read, every run and output under the stage).  H1 on the MZW tree (`obj/zr`, `-j 4`,
  19:48:10..20:32:27 UTC): `ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32 centre runs 4 not zoomed
  38/448`, every other line equal to the tree's ext-zoom.txt, the golden's 388 Windows lines byte-identical and all
  240 `dos` lines new.  Then again with H3 on the tree with MZI (`obj/zr3`, `-j 3`, 22:42:55..23:49:46 UTC), which
  wrote the staged golden: `ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32 centre runs 4 mzi runs 12
  not zoomed 38/448`; every `ZOOM`, `ZOOM centre` and `ZOOM mzi` line equal to the MZI cycle's ext-zoom.txt (the same
  shows per profile and sample counts); the golden (CRLF, 631 lines): the header and 388 Windows lines byte-identical
  to MZI's golden, all 240 `dos` lines new hashes for the same keys (the DOS profile's zoomed views now show the DOS
  small map and Status window, from the first zoomed sample: 25,000 ms in `load` and `orders`, 40,000 ms in `new`).
  "Not zoomed": 38 pairs of -1/+1 runs with the DOS small map's model (win b in the 16 combinations, dos a in 15,
  dos b in 3, sw in 4), 448 common sample times, all equal.
* **ext_zoom DOS determinism** (`--profiles dos`, no `--update`): H1 (`obj/zv`, 20:33:04..20:43:57 UTC) and H3
  (`obj/zv3`, ..00:02:30 UTC): `ZOOM_OK combinations 32 runs 36 samples 240 map comparisons 6 centre runs 2 [mzi runs
  6] not zoomed 18/150`: every staged DOS sample reproduced, dos a = dos b at 1920x1440.  H4 with MZS (`obj/zv4`,
  `-j 3`, 00:40:33..00:49:40 UTC): `ZOOM_OK combinations 32 runs 36 samples 240 map comparisons 6 centre runs 2 mzi
  runs 6 mzs runs 2 not zoomed 18/150`: every staged DOS sample reproduced again, and the `ZOOM mzi` and `ZOOM mzs`
  lines of the DOS profile equal to MZS's cycle's ext-zoom.txt (MZS's menu and dialog checks pass with the DOS small
  map and Status window composed; MZS's runs are not part of the "not zoomed" pairs).  The per-combination lines
  differ from the tree's only by `--profiles dos` (`shows dos N` without the Windows count), as in H1's and H3's.
* **P0** (the tree's `ext_p0.py` with `--exe`, `--root obj/p0r`, `--port`).  H1: `--vars V0,V1,V2,V4d,V6,V7,V8,V8s`
  (`-j 4`, 20:44:42..21:19:05 UTC) `P0_OK checks 390`, then `--vars V6r,V6w` `P0_OK checks 4`; every line equal to
  the tree's ext-p0.txt for those variations (V1's scene-row counters 0; V4d: the map layer drawn in the DOS profile
  in 22 runs and in the Windows profile in 22; the switch assertions).  H3: `--vars V1,V4d` `P0_OK checks 181`, every
  line equal to the MZI cycle's.  Not run: V3, V4 (no DOS profile registered: the module is not reached) and
  CheckedNoObs V5 (CIV_OBSERVER 0: the module's queries return nothing).
* **ext_replay** (over the private V1 outputs, `--root obj/p0r`; H1 and H3): `REPLAY_OK checks 70`, every line equal
  to the tree's ext-replay.txt but the outputs' path (the same kind checks, brackets, muted, scripted and `no_shadow`
  counts: the status element claims no shadow).
* **ext_frames** (`obj/runframes.py`; H1 `-j 3`, H3 `-j 2`): EXT_FRAMES_OK, ext-frames.txt identical to the tree's
  (MZW's and MZI's cycles): the sample lines of A, A', B and C identical in start, s3 and birth (the DOS elements do
  not depend on which profile is shown), the same show counts.
* **ext_adapt** (`obj/runadapt.py`: the tree's ext_adapt.py, every case; H1, H3): EXT_ADAPT_OK checks 154, identical
  to the tree's ext-adapt.txt.
* **ext_mirror** (the tree's ext_mirror.py with `--exe`, `--root obj/mr`, `--port`, `--ref` the tree's build (its V0
  and uninit references read), `-j 3`; H1): MIRROR_OK runs 29, identical to the tree's ext-mirror.txt
  (`unexplained 0`, `dos_mismatched 0`, `dos_unexplained 0`: the module's DOS-rule DROP brackets change nothing in
  the DOS map shadow).
* **A private look** (`obj/rundump.py`, H1: p0's `load` scenario in the DOS profile at 640x480 with
  `--dump-presented`, 30,000 virtual ms, levels 0 and -1; the dumps converted to PNG in the session's scratch
  directory and deleted): the World Map's client in DOS art (black, ocean 1, land 2, the white cities of the Romans,
  the colour-15 frame, the bevel: top 8 (77, 77, 77), left 15 (235, 235, 235)); the Status window's DOS column (the
  sky 11 with the ground line, the population, year and treasury lines in font 1 with the research icon, the unit
  panel's five lines and the stacked unit's icon, the texture below); at -1 the larger outline around the main map's
  area.
* **Not run privately:** `ext_timeline`, `ext_continue`, `ux3_aspect`, `bs1..bs3`, `ext_slots`, `gate3b`, `uninit`,
  `scenarios`, `p4tests`, `harness_stub`, `d3a_obs_tables`, `d4a_pdos_scene`, `d4c1_adapters`, `ext_g1`, the Asan
  variant (deferred): none reaches the play screen in the DOS profile with a changed output (the intro, title, Birth
  and setup flows; core-output comparisons; no DOS profile), or none of D6e's files is read (the tables, the scene
  table and the adapters are unchanged).

## Expected changes at the build slot

* `sections/unit.log`: test_pdos_play (new) 46 checks; test_pdos_pal 236 -> 239; test_pdos_shadow 174 -> 175;
  test_dos 23230 -> 23233; every other program unchanged (test_map 338, MZS's); the OBS_COST line and test_map's
  cost lines (host time).  Portable sources 294 -> 295 (`pdos_aplay.c`; MZS's cycle: 294).
* `obs-lint.txt`, `sections/d3a_obs_lint.log`: OBS_LINT_OK files 120 -> 122 (probes 203, callsites 98).
* `registry-check.txt`, `sections/d2_registry.log`: the 13 lines above; `(1363 lines)`; REGISTRY_OK.
* `nodos.txt` (`--variant Checked`): files + 5 (`pdos_aplay.c`, `pdos_aplay.h`, `tests/test_pdos_play.c`, this
  record and `build/x64/Checked/test_pdos_play.exe`; 1737 -> 1742 on the tree after MZS), byte totals; 0 hits,
  NODOS_OK.
* `ext-zoom.txt`: the ZOOM_OK line gains ` not zoomed 38/448` (`ZOOM_OK combinations 32 runs 108 samples 628 map
  comparisons 32 centre runs 4 mzi runs 12 mzs runs 4 not zoomed 38/448`); every other line unchanged.  `sections/ext_zoom.log`
  unchanged.  `tests/harness/ext-zoom-golden.txt`: the 240 `dos` lines (staged).
* `profiles.log` (runs with `--profile-samples` at level -1 or +1 and the DOS profile registered): ` smmap SHA` after
  `map dos` once the DOS small map has been drawn.  At level 0, as before.
* Unchanged (privately identical): ext-p0.txt (P0_OK checks 476), ext-replay.txt (REPLAY_OK checks 70),
  ext-frames.txt, ext-adapt.txt (EXT_ADAPT_OK checks 154), ext-mirror.txt (MIRROR_OK runs 29).  Expected unchanged
  (not run privately, above): ext_timeline, ext_continue, ux3_aspect, bs1..bs3, ext_slots, gate3b, uninit,
  scenarios, p4tests, harness_stub, d3a_obs_tables, d4a_pdos_scene, d4c1_adapters; `ext_g1.py check` EXT_G1_OK
  runs 77 (amended 1).
* `coverage.txt`, `sections/coverage.log`: informational.  `sections/times.txt`: section times (ext_zoom's work is
  unchanged; the harness draws two more elements in the DOS profile's play).
* presented.log of DOS-visible runs in play: new pictures (the DOS small map and Status window); the Windows profile's
  frames, every core output and every G-1 field: unchanged.

## Rebase notes

* All bases equal the tree at writing (`BASE-SHA256.txt`).  The `extension D6e` blocks are delimited (`---- extension
  D6e ... ----` / `---- end of extension D6e ----`) where they add more than a line; one-line hunks carry an
  `extension D6e` comment.
* **MZ** (landed during the staging): none of D6e's files; its `ext_zoom.py` and golden changes are in the bases
  copied at 18:39 UTC.
* **MZW** (landed during the staging): shared `present/map/pmap_smrect.c` (new in MZW), `tests/headless/harness.c`,
  `tests/harness/ext_zoom.py` and `ext-zoom-golden.txt`.  pmap_smrect.c: D6e adds the include and the `zoom_dos`
  block before `evaluate_patch`, and its call as the first statement there.  harness.c: MZW's hunk (`shown()`'s
  relation exemption) and D6e's (`profile_sample`'s `smmap` block, the include) are disjoint.  ext_zoom.py: MZW's
  `mzw_check` and docstring paragraph and D6e's (the docstring paragraph after MZW's, `profiles()`'s `smmap`
  parse, `compare_maps`' key list, the `smm` dict and the "not zoomed" block, the ZOOM_OK format) are disjoint.
  The golden was rewritten on the overlay with MZ and MZW: its 388 Windows lines are the tree's (section
  "Results").
* **UX5** (landed during the staging, ALL_GREEN 21:17:06 UTC): shared `present/dos/pdos_profile.c` (UX5: two comment
  lines in the UX3 block above `dos_square_only`, the tree's lines 330..331) and `test.cmd` (UX5: section
  `ux3_aspect`'s comment and echo; not staged by D6e).  The staged `pdos_profile.c` is UX5's copy with D6e's 14
  changed lines applied (`obj/merge`: base -> D6e patch applied to UX5's copy, no fuzz); test.cmd's base copied again.
  UX5's other files (`pdos_seq.c/.h`, `present.c`, `profile.h`, `harness_main.c`, `civ64_main.c`, its tests and
  `ext_aspect.py`) are not D6e's.  The H3 and H4 builds and unit tests ran on overlays with UX5.
* **D6f** (staging in parallel, lands after D6e; the orchestrator: it rebases on D6e's `pdos_compose.c` and
  `pdos_profile.c` changes): D6e does not change `pdos_compose.c`.  `pdos_profile.c`: D6e's changes are single
  marked lines (the include after `observe.h`'s; `pdos_aplay_reset()` in the reset; `pdos_aplay_on_event(e)` after
  `pdos_reskin_on_event(e)`, whose comment loses its "pdos_play_on_event (D6)" placeholder; `pdos_aplay_on_probe(p)`
  at entry step 6 and exit step 3; `pdos_aplay_present()` after `pdos_compose_core_present(r)` in `dos_on_core_present`, the same place where D6f's
  stage adds `pdos_reskin_present()` (keep both; the composition's element order, not the call order, decides what
  is on top) and the header comment's renderer note.  Also shared with D6f's stage: `docs/dos/OFFSETS.md` (D6e's
  three rows after the tree's line 90), the generated `pdos_registry.h/.c` and `tests/dos-decoded.txt` (merge the
  OFFSETS.md rows, then regenerate all three with `gen/dos/registry.py`; D6e's registry.py change is the
  OBSERVER_FILES entry `pdos_aplay.c`), and `tests/headless/harness.c` (D6e's include at line 48 and the
  `profile_sample` block).  The owner table: D6f's stage registers no new owner; one more product owner would need
  `PDOS_OWNER_MAX` 6 (test_pdos_shadow's limit check fills the free slots whatever the define).
* **MZI** (landed during the staging: its files in the tree at 21:29:09 UTC, ALL_GREEN 22:08:45 UTC, RELEASE_OK
  22:18:42 UTC): shared `tests/harness/ext_zoom.py` and `ext-zoom-golden.txt` (MZI's other files, `pmap_int.h`,
  `pmap_zoom.c`, `pmap_layer.c`, `pmap_inview.c`, `tests/test_map.c`, are not D6e's).  ext_zoom.py: the staged copy
  is MZI's with D6e's hunks applied (`obj/merge`: five hunks applied by patch, at offsets; two by hand: D6e's
  docstring paragraph now follows MZI's, and the ZOOM_OK line carries both, `... centre runs %d mzi runs %d not
  zoomed %d/%d`; D6e's "not zoomed" block follows MZI's `ZOOM mzi` checks).  The golden: MZI's (244 +1 samples
  re-recorded) is the base; D6e's copy was written again on the overlay with MZI (`--update`, all profiles), its
  Windows lines checked equal to MZI's, and reproduced by a `--profiles dos` run (section "Results").  MZI's record
  asks the later unit to re-apply and re-record: done here.
* **MZS** (landed during the staging: its files in the tree at 23:47:40 UTC, ALL_GREEN 00:25:05 UTC, RELEASE_OK
  00:30:32 UTC): shared `tests/harness/ext_zoom.py`
  only (MZS's `pmap_dos.c`, `pmap_int.h`, `pmap_inview.c`, `tests/test_map.c` are not D6e's; MZS does not change the
  golden).  The staged ext_zoom.py is MZS's copy with D6e's hunks (`obj/merge`: four by patch at offsets; by hand
  D6e's docstring paragraph after MZS's, the "not zoomed" block after MZS's `ZOOM mzs` checks and before the golden's
  write, and the ZOOM_OK line `... mzi runs %d mzs runs %d not zoomed %d/%d`); the base copied again at 23:51 UTC.
  Built, unit-tested and checked again on the overlay with MZS (H4), and its `--profiles dos` run reproduces every
  staged DOS golden line with MZS's `ZOOM mzs` checks passing (section "Results").  The whole matrix was not run
  again with MZS: MZS changes neither the golden nor the Windows profile's zoomed pictures, and its own runs are
  outside the "not zoomed" pairs (they are collected from the matrix's runs only).

## Build-slot steps

1. Copy the staged files (`BASE-SHA256.txt`'s list) and this record into the tree; build.cmd and test.cmd are
   unchanged (the new `tests/test_pdos_play.c` is built and run by their `test_*.c` / `test_*.exe` globs; no
   BUILD-TEST-ADDITIONS).  If a unit landed after this record that changes a staged file (the bases recheck in
   `BASE-SHA256.txt`; ext_zoom.py and its golden in particular), rebase first.
2. The three-step cycle: `build.cmd checked` (295 portable sources), `test.cmd checked` (unit: test_pdos_play 46,
   test_pdos_pal 239, test_pdos_shadow 175, test_dos 23233; ext_zoom ZOOM_OK with the rewritten `dos` goldens and
   `not zoomed`; every other section per "Expected changes"), `ext_g1.py check` (EXT_G1_OK unchanged: the core is
   untouched).
3. The user build for the visual check (section "What the user checks"): the coordinator's, from the landed tree
   (Release).

## Decisions within the brief

* **The module's name `pdos_aplay`** (above): `pdos_play_*` is taken by the play palette (`pdos_pal.h`).
* **The small map's state from the module's own reads (Choice B17's alternative).**  B17 reuses D's snapshot through
  `pmap_src_current()` / `pmap_view_current()` (`pmap.h`); the include rule that registry.py checks keeps
  `present/dos` from including `present/map` headers, and D's snapshot holds the main map's view, not the whole
  world's visibility, terrain classes and city set at DrawSmTiles' exit.  The module reads the same globals
  DrawSmTiles reads, at its exit, through the query (B17's recorded alternative).  The other direction (map ->
  dos) is allowed: `pmap_smrect.c` calls `pdos_aplay_set_zoom_area`.
* **No shadows and no claims; private element surfaces.**  Claiming the two windows as shadows (HALF) would let the
  logical replay's kind 1 (the status panel) draw the core's Windows-layout primitives into the DOS column at the
  Windows positions.  The module claims nothing: the core's drawing to the two windows reaches no DOS shadow, so
  nothing is counted unexplained, and the elements are the module's own surfaces composed on the A canvas.  DESIGN
  12.7's "the status element (kind 1, HALF) needs its owner's claim for the replay to draw there" is therefore not
  taken (section "Deviations").
* **Drawing at the module's exit handler, not in the macros' leaves.**  The panel functions nest (DrawMiniPalace in
  DrawStatusCivPanels; RedrawStatusWindow around both panels); a leave inside an enclosing DROP bracket is muted by
  the engine, so the outermost leave alone would draw.  Drawing at each function's own exit (after the engine's
  leaves, exit step 3) draws every change once, whatever encloses it.
* **Choice B18 as designed** (the DOS column at 2x from the client's top-left, the unit box extended down, the
  texture elsewhere): the Status client of the default layout (160 x 329) is the DOS column's 80 pixels wide at 2x;
  below the unit panel's content and beyond 80 columns the texture shows.
* **The small map at the core's scale** (element factor 1, the surface the client's size): B 12.2 composes a DOS
  surface at the core's small-map scale; drawing each square as `g_smMapScale` device pixels is the same picture at
  scale 2 (the default) and also covers scale 1 and the client's odd sizes exactly.
* **The palette return's filter.**  The core calls RestoreMapAfterDialog after every dialog, the DOS program
  R:0238:1BEB only after full-screen scenes.  The return is applied only when SP256.PAL with the selected back file
  differs from the DAC outside the play slots 60h..7Fh (a government or advance change since the last one); else
  nothing happens (`pal_same`), so an ordinary dialog does not restart the slots.
* **R3 kept the DOS position** (DESIGN 12.7 "D6e keeps the position or records a deviation"): `pdos_play_back`
  follows R:1DC4:0626 / 03FA.
* **"Not zoomed" through the model's hash at -1 and +1.**  Draft D 19's rule (the small map's pixels at a zoom
  level equal level 0's) is checked on the model (the squares' DOS colours), which the zoom cannot change by
  construction; the picture differs by design at -1 and +1 in the outline (MZW, the user's request), so the
  picture's hash cannot be the criterion.  ext_zoom runs no level 0, so the comparison is -1 against +1 in the same
  scenario, size, policy, profile and copy; level 0's model is the same function of the core's state (P0).
* **MZW's zoom outline on the DOS small map** (the user's request of 2026-10-16 for the World Map, applied to the
  DOS profile's small map as well; MZW-7 said the DOS World Map would follow with D6e): the same area as the Windows
  rectangle, drawn as the DOS view frame (colour 15, one DOS pixel outside), with the wrap copies.
* **The owner table raised to 5**, not shared: an owner's macros replace that owner's whole table, so the module
  cannot share pmap's or replay's owner without coupling their registrations.
* **DrawMiniPalace's target only inside DrawStatusCivPanels**: only the mini palace of the Status window's panel is
  the element's; a call outside the panel function has no target (its bracket drops nothing).
* **The blink's colours**: the core's "End of Turn" blink alternates its text between EGA 14 and EGA 0; the DOS
  word alternates 7 and 0 (SP 6.1, PROF row 132); a TEXTOUT outside the panel functions while the panel shows the
  end of turn sets the colour (black or the system colour of EGA 0 -> 0, else 7).

## Deviations from the design

* **The status element is not a claimed shadow** (DESIGN 12.7's D6e note; above): the logical replay's kind 1 finds
  no status shadow and counts it (`no_shadow`), as before D6e.
* **The unit panel's lines are the core's strings** (as the status panel's in B 12.3): draft B 12.3 builds the
  unit panel's names and numbers from the core's state with DOS rules (OB7: the name tables' globals); the module
  captures the core's own lines in order (adjective, type, moves, home city, terrain, improvements), folded, and
  replaces only the third line by the DOS word "Veteran" when the unit's flag 20h is set.  So the "Moves" fraction
  and wording follow the Windows game; the DOS "(n)" rule (OPEN L4) is not drawn separately: the core's own line
  carries Windows' text.  OB7 is thereby not needed.
* **The view frame's outline encloses the core's frame**: the core's FrameRect draws on the frame rectangle's own
  edge pixels; the DOS rectangle R:1D05:0A05 encloses its view's squares, so the outline is drawn one DOS pixel
  outside the core's frame rectangle (D's P9: the core's columns and rows, not DOS's 15 x 9, PROF row 139): one DOS
  pixel larger on each side than the Windows frame.
* **The bevel at the client's edges** rather than around a 160 x 100 image area: the core's World Map client is the
  image area at the default size; a larger client shows colour 0 beyond the image and the bevel at its edges.
* **The palace strips by provenance from the DrawTile handles**: a strip at y 57 lies one DOS row above the column
  (DOS y 58), so its top row is clipped by the surface, as the column cuts DOS's panel box.
* **The play palette's return at RestoreMapAfterDialog** with the filter above (the brief's trigger); the TX fades
  around it stay D7's (decision 5).
* Files beyond the brief's list: `present/dos/pdos_pal.c/.h` and `tests/test_pdos_pal.c` (R3), `present/dos/
  pdos_shadow.h` and `tests/test_pdos_shadow.c` (the owner table), `tests/test_pdos_profile.c` (the owner's
  macros cleared), `present/map/pmap_smrect.c` (the zoom area; the rebase on MZW), `tests/headless/harness.c`
  (the `smmap` sample), `gen/dos/registry.py`, `present/dos/pdos_registry.h/.c` and `tests/dos-decoded.txt` (the
  DOS words).  `pdos_compose.c` is not changed.

## User direction 2026-10-16 (no added Go Back / Cancel rows) and checklist item D5-7

* D6e adds no row, box, dialog or menu: it redraws the World Map's and the Status window's clients in DOS art,
  clipped to their visible regions (a dialog or menu over them stays on top).  No DOS screen gains a row, so no
  Escape case arises; none is recorded.
* The population message (row 137) is an R text box: D6f's placement draws it.  Checklist item D5-7 (the first D6
  unit that makes a re-skinned DOS menu or message box visible in play) is **not D6e's**: D6e shows no re-skinned
  box; it stays D6f's.

## What the user checks

On the coordinator's user build of the landed tree (`civ64.exe`, DOS files present), in play (load a saved game, for
example MZTEST.SAV, or start a new one) with the DOS graphics (`--graphics dos` or Ctrl+Shift+Backspace) and the
World Map and Status windows open:

* **D6e-1  The World Map in DOS art.**  Black where never seen, DOS blue ocean, DOS green land, cities as single
  squares in their civilization's colour, a white frame around the main map's view, a light/dark bevel at the
  window's edges; the picture as large as the Windows World Map's and at the same place.
* **D6e-2  It follows the game.**  Move a unit, let the game go to the next unit, scroll the map, found a city: the
  white frame and the squares follow; the active unit blinks white on the World Map as in the Windows graphics.
* **D6e-3  Zoomed (-1, +1).**  The white frame outlines the area the main map window shows (larger at -1, smaller
  at +1, wrapping at the world's east and west edges), as the Windows World Map's rectangle (MZW); the squares
  themselves do not change with the zoom; back at 0 the game's frame returns.
* **D6e-4  The Status window in DOS art.**  At the top the DOS status panel: sky blue, the white peace bar when at
  peace, the small palace on the green ground line, the population (when shown), year and treasury/rates in the DOS
  font, the research and warming icons; below it the DOS unit panel, and the DOS stone texture filling the rest.
* **D6e-5  The unit panel.**  The active unit's lines (civilization, type, moves, home city, terrain), "Veteran"
  for a veteran, the units in the same square as small icons four to a row with "+" when more do not fit; at the
  end of a turn "End of Turn" blinking, "Press Enter", "to continue".
* **D6e-6  Windows over them.**  Open a menu, a dialog or the city screen over the World Map or the Status window,
  move or resize them, minimise and restore: the DOS pictures stay inside their windows, under whatever is on top,
  and come back whole.
* **D6e-7  Switching.**  Ctrl+Shift+Backspace: the Windows World Map and Status window as before; back: the DOS
  ones with the same content.

Not part of this check: the population message box, the menu bar, drop-downs and message boxes in play (D6f); the
city screen and other in-game screens (D7); the palette return's colours (entries 128..255 show only in full-screen
pictures, D7's).

## For the records

* DESIGN.md line numbers below are those after the docs pass of 2026-10-17 00:53:30 UTC (docs-mzs).
* **DESIGN 12.7** (area B): a new "As implemented (D6e; area B)" paragraph: the module `pdos_aplay` (the name; B 2's
  `pdos_play.c`), the seven DROP macros of the owner "aplay", drawing at the functions' exits, the element surfaces
  (the small map at the core's scale, factor 1; the Status column at 2x, Choice B18), the zoom area from
  `pmap_smrect.c`, the palette return with its filter, R3 in `pdos_play_back`, the decisions and deviations above.
  "The owner table" (lines 3489..3490): setup, pmap, replay and aplay hold 4 of `PDOS_OWNER_MAX` 5 (raised by D6e;
  the fifth slot for the tests' own owner).  "Left to later units" (line 3502): D6e does not claim the status
  element (no shadow; the replay's kind 1 keeps counting `no_shadow`).  The module lists (lines 2871, 3043): read
  `pdos_aplay` (D6e) for `pdos_play` (D6); "OB1 (`pdos_play_back`, the BACK palette selection)" is settled.
* **DESIGN 12.9** (area D): R3 (lines 5120..5122) is resolved by keeping the position (`pdos_play_back`); L11 (5106)
  read (below); MZW's World Map rectangle: the DOS profile's small map outlines the same area (D6e).
* **Draft B:** 2 and 12: the module is `pdos_aplay`; 12.2: Choice B17's alternative taken (the module's own reads);
  the drawing at the core's scale (factor 1); 12.3: the unit panel's lines are the core's strings (OB7 not needed);
  5.5 item 2: R3 as built; 7.5 "at most 4 owners" -> 5; the Open table: OB1 settled (R:0238:1C11..1C46: the
  government as GetCourtStyle 1160:3487 selects it, 'm' after advance 14h, government 3 alone '3'), OB6 settled
  (R:0866:034C..0376: colour 1 when the square's page-2 terrain colour is 1, else 2; never seen 0), OB7 not needed
  (above).
* **Draft D:** 19 "not zoomed" (row 5.8) as built: ext_zoom's `smmap` check (the model at -1 equals +1, and equal
  whichever profile is shown); 5.6 (MZW's World Map rectangle): the DOS small map outlines the same area since D6e.
* **OPEN.md:** L4 stays open (the peace bar as D808 = the peace turns, inferred; the "(n)" suffix is the core's
  text); L11 read: R:0238:1BEB writes no entry 45 (the forced colour belongs to R:1DC4:047D's recipe, not the play
  return), and the differing `BACK*.PAL` entries are applied as 128..255 by the recipe; phase D6e done for it.
* **DOS-PROFILE.md:** rows 132 (the small map's land colour 2, "End of Turn" 7/0: done in D6e), 136 (the status
  panel: done), 138 (the unit panel with the DOS words "End of Turn", "Press Enter", "to continue", "Veteran", "+":
  done), 139 (the small map with the core's frame, the zoom area at -1/+1: done).
* **FIDELITY:** F131's file is `present/dos/pdos_aplay.c` (status: implemented in D6e); F132 gains the "not zoomed"
  check (the DOS small map's model, ext_zoom); a new entry for D6e's recorded deviations: the unit panel's lines
  are the core's (Windows) strings with the DOS static words, the DOS outline one DOS pixel outside the core's
  frame, the palace strips' top row clipped by the column, the palette return applied at RestoreMapAfterDialog
  only when the palette changes (the TX fades D7's).
* **RUNNING.md:** `test_pdos_play` (46 checks), `test_pdos_pal` 239, `test_pdos_shadow` 175, `test_dos` 23233;
  profiles.log's ` smmap SHA` (level != 0 samples, the DOS small map's model); ext_zoom's "not zoomed" check and
  the ZOOM_OK line's `not zoomed PAIRS/SAMPLES`; 295 portable sources; obs_lint files 122.
* **FEATURES.md:** a new DOS-section row "DOS World Map and Status window in play (D6e)", and the D6c row's "the
  other windows ... still the Windows picture (D6e..D7)" narrowed to the boxes and other screens.
* **STATUS.md:** D6e done; D6f next (it rebases on D6e's `pdos_profile.c`, registry and harness hunks).
* **manual-checklist-ext.md:** a new section D6e with D6e-1..D6e-7 (above); MZW-7's DOS sentence ("In the DOS
  graphics the World Map is still the Windows game's World Map until unit D6e draws the DOS one") is answered by
  D6e-3; item D5-7 stays open for D6f.
* User direction 2026-10-16 (no added Go Back / Cancel rows): nothing added by D6e, nothing to record.
* Not edited by this unit (as the brief says): DESIGN.md, FIDELITY.md, STATUS.md, RUNNING.md, FEATURES.md,
  DOS-PROFILE.md, manual-checklist-ext.md, the D1 drafts and the D0 documents; `docs/dos/OFFSETS.md` gains its
  three rows (decision 8).

## Landing (2026-10-17, build slot)

**Landed 2026-10-17 00:55:23 UTC; cycle ALL_GREEN 01:23:53 UTC; RELEASE_OK 01:28:06 UTC; user build
`build/user-builds/d6e/` (about 01:29 UTC).**  Done by this unit's agent in the build slot on the orchestrator's
instruction, after the docs pass docs-mzs (UX5, MZI, SI, MZS; `build/docs-mzs-done.txt` 00:53:30 UTC; the start
waited for that file, checked every minute).

1. **Bases.** Before the freeze, `obj/mkbase.py` printed BASE_OK on the tree after the docs pass (the docs pass
   edited DESIGN, FIDELITY, RUNNING, FEATURES, STATUS and DOS-PROFILE prose, draft D and the checklist's header;
   none of D6e's files, `docs/dos/OFFSETS.md` included).  Only this record changed then: its DESIGN.md line
   references in "For the records" follow the docs pass's line numbers.  `build/d6e-prep/land.py` (20 rows): the
   16 tree files still had their bases (`build/d6e-stage/BASE-SHA256.txt`), the 4 new files (`pdos_aplay.c`,
   `pdos_aplay.h`, `tests/test_pdos_play.c`, this record) were absent, each staged copy had the SHA-256 frozen in
   `build/d6e-prep/staged.sha256` and its base's line endings (CRLF: `pdos_profile.c`, `ext-zoom-golden.txt`,
   `harness.c`, `test_pdos_pal.c`, `test_pdos_shadow.c`); build.cmd (40de571d...), test.cmd (e7c5015c...) and
   `present/dos/pdos_compose.c` (49f867ef...) unchanged.  Dry run `DRY_RUN_OK 20`.  No rebase was needed.
2. **Snapshot and copy.** Before writing: the tree's Checked test outputs (59 files of `build/test/Checked`, MZS's
   cycle) in `build/d6e-prep/before`, the tree's previous 16 files in `build/d6e-prep/tree-before`.  The 20 files
   byte for byte (16 changed, 4 new): `LANDED 20`; manifest `build/d6e-prep/landed.sha256` (with build.cmd's,
   test.cmd's and pdos_compose.c's unchanged SHA-256); `landed-at.txt`.  No build.cmd or test.cmd change.
3. **Cycle** (`build/d6e-prep/d6e-cycle.ps1`; status `build/d6e-status.txt`, logs `build/d6e-<n>-<step>.log`):
   - 1 build-checked: exit 0, 191 s, BUILD_OK; portable sources checked 295; no warning.  The generators ran
     (`gen-registry.log`: "pdos_registry: 159 files, 44 tables (unchanged)"); every landed file still had its
     landed SHA-256 after the build.
   - 2 test-checked: exit 0, 1512 s, TESTS_OK, 27 sections, failed 0 (wall 1510.3 s).  `w32_test_host_win32` passed
     at the first run (395 checks): no GetKeyState rerun and no -r2 test step were needed.
   - 3 g1-checked: exit 0, EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events): **ALL_GREEN**.
   - 4 build-release: exit 0, 230 s, BUILD_OK, portable sources checked 295: **RELEASE_OK**.
4. **Comparison** (`build/d6e-prep/compare.py`, output `compare.txt`; the predictions in
   `build/d6e-prep/predictions.txt` were written before the copy-in; prediction against output in
   `build/d6e-prep/comparison.txt`): 48 of 59 files equal (lines with times left out).  The differences, all as
   predicted:
   - `sections/unit.log`: `test_pdos_play` new, 46 checks; `test_pdos_pal` 236 -> 239; `test_pdos_shadow` 174 ->
     175; `test_dos` 23230 -> 23233 ("decoded content: 1363 lines", "registry: 44 tables valid"); the OBS_COST line
     (host time).  `test_map` 338 and every other program unchanged.
   - `dos-decoded.txt`: the three table lines UNIT_END_TURN, UNIT_VETERAN and UNIT_MORE.
   - `registry-check.txt`: the 13 added lines (the three tables' strings, readers R:0403:4096, 40AD, 40C4, 4150,
     44F1 and no writer; the include rule for `pdos_aplay.c` and `.h`) and `(1363 lines)`; REGISTRY_OK.
     (`sections/d2_registry.log` holds only REGISTRY_OK: unchanged.)
   - `obs-lint.txt`, `sections/d3a_obs_lint.log`: OBS_LINT_OK files 120 -> 122 (probes 203, callsites 98).
   - `nodos.txt`: 1737 -> 1742 files (the four new files and `build/x64/Checked/test_pdos_play.exe`), 0 hits.
   - `ext-zoom.txt`, `sections/ext_zoom.log`: `ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32
     centre runs 4 mzi runs 12 mzs runs 4 not zoomed 38/448`; every other line equal (the combination lines' show
     counts, MZ's, MZI's and MZS's lines; the staged golden's 628 samples, its 240 `dos` lines reproduced).
   - `coverage.txt` and `sections/coverage.log`: "other functions entered" 667 -> 666 (informational).
   - `sections/times.txt`: section times.
   Every other output equal: P0_OK checks 476, REPLAY_OK checks 70, EXT_FRAMES_OK, EXT_ADAPT_OK checks 154,
   MIRROR_OK runs 29, OBS_TABLES_OK, the scene check, ADAPT_OK, EXT_ASPECT_OK, EXT_TIMELINE_OK, EXT_CONTINUE_OK,
   EXT_SLOTS_OK, EXT_BS_OK, TRACE_OK and the other sections.  P0 holds.
5. **User build** `build/user-builds/d6e/` (`build/d6e-prep/mk_userbuild.py`, `USER_BUILD_OK 4`): `civ64.exe` (the
   Release build, SHA-256 6e763b7d...345ba3d4, 4,368,384 bytes), `CIVWIN.zip` and `civdos.zip` (byte-identical
   copies from `user-builds/d4`, SHA-256 058d4e00... and 0eac32c9... checked) and `WHAT-TO-CHECK.txt` (SHA-256
   f7aaaa5b..., CRLF, ASCII): D6e-1..D6e-7 in plain words as in "What the user checks", where MZTEST.SAV is
   (%LOCALAPPDATA%\civ64\CivWin, ready to load), the zoom keys, the builds it contains (mzs, si, mzi, ux5, mzw, mz,
   ux4b, d5p, ux4, d6d, sl and the earlier ones), the note that it runs only once at a time (SI), and the items
   still open from the checklist's pending rows at about 00:56 UTC, grouped by build: mzs (MZS-1..MZS-6, MZW-8; MZW-8
   to be checked in the DOS graphics now that the World Map is the DOS small map there), si (SI-1..SI-6), mzi
   (MZI-1..MZI-7), ux5 (UX5-1..UX5-7), d5p (D5P-7) and P47-1 (any build): 29 checkable; D6-1 and D5-7 with unit
   D6f.
6. **Not done here**: the checklist's D6e section (the orchestrator), the FIDELITY entry (unnumbered) and the other
   entries of "For the records" (the next joint docs pass).

# Brief for the D6 implementers (extension phase D6: play in the DOS profile, class A, menus, zoom)

> **Cycle rule changed 2026-10-15 about 14:09 UTC (the user's decision, STATUS "User directions"; `verify/BRIEF-cy.md`):** wherever this brief says "the eight-step cycle", a unit now ends with the **three-step cycle** (`build.cmd checked`, `test.cmd checked`, `ext_g1.py check`); the full eight-step cycle runs only at phase gates (D4, BS, D5, D6, D7, X9, WL and before the final Asan pass).

Written 2026-10-15 for the orchestrator by a read-only planning agent (session E3); adopted by the
orchestrator 2026-10-15 with the rulings below "Decisions for the orchestrator". Phase D6 of the extension prompt
`claude/docs/x64-port-scaling-dos-prompt.md` (section 9): "Play, class A: DOS map rules in the renderer,
small map, status window, map palette animation, menus (R); zoom in the DOS profile." Gate: "Tests; P0;
Z-1..Z-3 for the DOS profile; agent check." It delivers the class-A and menu parts of D-5 (prompt 4: the
map with the DOS terrain composition, units, cities, labels, unexplored edges and the DOS palette
animation; the small map and the status window in the DOS style) and Z-1..Z-3 for the DOS profile, with
7.5's per-present mirror check (M2, decision C2). Every other in-game N and R scene is D7's. Asan runs stay
deferred to the end of the queue (the user's direction of 2026-10-10 21:20).

D6 starts after the D5 gate (`ext-D5-acceptance.md`; brief `verify/BRIEF-d5.md`), in the prompt's order.
D6f extends D5b's `pdos_reskin`; the input rows extend D4c's `pdos_adapt` table and filter stage.

## Decisions for the orchestrator

Design gaps and choices found while planning; no DOS fact is decided here. Each has a proposal.

1. **Scope of "menus (R)".** **Proposal:** D6 does the menu bar (row 121) and its drop-downs (the menu
   items of rows 29..95 as drop-down rows), plus the A-canvas placement of D5b's generic re-skins (draft B
   11.3 at 2x, B16), so MenuZ boxes (dialogs 136, 145), text boxes and `#MsgBox` boxes in play are DOS
   from D6 on. The scene-specific R rows (12 Find City, 17 production list, 18 unit stack, 115 government,
   117, 118, 126..128 and the menu items whose screens are N) stay D7. Alternative: only the bar and the
   drop-downs in D6.
2. **Drop-down item text.** Draft B 11.2 draws the drop-down rows from `w16q_menu_item` (the core's display
   text, mnemonic, grayed, checked, separator) in the DOS menu-box style, and uses DOS strings only for the
   five DOS titles (DGROUP:1D6F..1D8E). DOS-PROFILE.md 3.4 lists DOS sources for the items too (GAME
   DGROUP:2BD4, Options 2C3E, Advisors 2DD6/2E32, World 2E5D/2EA5, Civilopedia 2ED1/2F25, ORDERS
   2D05..2D91 built at run time, paired by role only: OPEN L25), and prompt 5.4 "Text" takes static text
   from the DOS program where the DOS element is the same. **Decide:** the core's item texts (draft B
   11.2) or DOS item texts where a row pairs (with the core's text for unpaired and Windows-only rows).
3. **Logical replay and provenance (`pdos_replay`, `pdos_prov`, draft B 8).** DESIGN 12.7 tags them D4,
   but no D4 unit built them. D6 needs them: kind-2 primitives drawing on the map shadows outside D's
   macros (B 7.5's table, D's Open D5), kind 1 for the status window (8.3), and the sheet-shape provenance
   for the mini palace and the status icons (12.3). **Proposal:** D6b builds 8.1..8.6 whole and tests it
   whole; the D7 scene rows stay not ready (their frames stay A) until their renderers exist; the cut-shape
   rules of DOS-PROFILE 2.3 (T1..T20) and city mode (OB9) stay D7.
4. **S3** (draft B 7.3: a flush applied before a drawing `leave`). B 8.2's replay brackets and B 12.3's
   status panels "drawn at exit" are the first macros with a drawing `leave`, unless D5 registered one
   earlier. **Proposal:** D6b resolves it with option (a) or (b) of the D4a record and its vector, if it is
   still open.
5. **Return to the map.** B 5.5 item 2 switches to `SP256.PAL` with `back<g><a|m>.pal` (R:0238:1BEB; OPEN
   OB1, L11) after a full-screen scene returns; the DOS fade-out and fade-in around it (R:0238:1B44,
   DOS-PROFILE 3.1 "Return to the map") are TX. **Proposal:** the palette switch in D6e (RestoreMapAfterDialog
   1208:14D5 as the trigger), the TX fades with the D7 scenes they surround.
6. **Test time.** `ext_zoom.py` took about 9 minutes with 8 jobs for its 64 runs at M; D6 adds the DOS
   runs and the profile-switch half (draft D 16.3), and `ext_mirror.py` gains `--mirror 2` with
   dos-settled. **Proposal:** `test.cmd checked` keeps one host size per policy for the DOS half; the full
   matrix runs once at D6g and its result goes into the gate record.
7. **The agent check.** M's agent UI check was interrupted and the M gate was counted on headless evidence
   with the check moved to the user. **Decide:** whether D6's gate needs a completed agent check, and
   whether it should also cover M's visible zoom checks (chords, wheel, menu items, ring click in the
   Windows profile; `ext-M-acceptance.md` "Not verified").
8. **OFFSETS.md rows** as BRIEF-d5 decision 2: D6 needs at least the menu titles DGROUP:1D6F..1D8E
   (`MENU_TITLES`), the unit-panel words DGROUP:20A3, 207F, 208B, 2097 and the population message
   DGROUP:1DA5 (draft B 20 E-B1; DOS-PROFILE 3.4), and the unit table word +4 of E-B3 if the "(n)" rule is
   drawn. The colour tables DGROUP:1946 and 1956 already have rows (`CIV_MAIN_COLOUR`,
   `CIV_SECOND_COLOUR`). **Proposal:** the same exception as D5.
9. **Class-A rows outside the phase's list.** DOS-PROFILE.md row 110 (AnimateNuclearExplosion 11B8:0C3D,
   class A, O22:0967 with `NUKE1.PIC`) and row 93 (Close City Display, the A map after the DOS return
   R:0238:1B44, TC + TX) are class A but are not named by D6's phase line, and D7's line names only N and
   R scenes. **Proposal:** both in D7 with the scenes around them (93 with the city screen; 110 needs its
   own DOS picture sequence, which draft D does not design); D6's gate lists them as D7's.

### Rulings (orchestrator, session E3, 2026-10-15; these bind the D6 units)

1. Adopted (bar, drop-downs and the 2x A-canvas placement of D5's generic re-skins; scene-specific R rows
   stay D7).
2. **DOS item texts where a row pairs**, the core's text (drawn in the DOS font and style) for unpaired
   and Windows-only rows. Extension prompt 5.4 "Text": static UI text comes from the DOS program where
   the DOS screen has the same element. The core's state (grayed, checked, separators, which items exist)
   always follows `w16q_menu_item`. Each pairing is by role (OPEN L25), listed per item in DOS-PROFILE.md
   with its evidence label; an unsure pairing stays unpaired (core text).
3. Adopted: D6b builds draft B 8.1..8.6 whole and tests it.
4. Adopted: D6b resolves S3 (option (a) or (b) with its vector) if D5 did not.
5. Adopted.
6. Adopted.
7. The gate needs one attempt at the agent check (civ64 windows only, screenshots under
   `claude/port/build/ext-d6-ui/`), covering the DOS-profile play screens and zoom and also M's visible
   Windows-profile zoom checks. If the attempt is interrupted ("user interrupt") the agent stops, ends
   civ64, does not retry, and the gate counts on headless evidence with the visible checks listed for the
   user, as at M.
8. Adopted, as BRIEF-d5 ruling 2.
9. Adopted: rows 93 and 110 go to D7.

### User direction 2026-10-16: no added Go Back / Cancel rows (binds this phase and every later unit)

The user, 2026-10-16 about 06:10 UTC (STATUS "User directions"): "Yes: in DOS graphics never show a Go Back or
Cancel row the DOS game doesn't have, on any screen; where DOS has a key for it (e.g. Escape), that key does it,
otherwise that choice is only in the Windows graphics."

* OPEN P17's "extra row in the DOS menu box" (draft B 11.2 and 11.5; C.12.7's added Go Back / Cancel rows) is
  withdrawn for every DOS screen, and so is extension prompt 5.4 "Flow" for these rows. No DOS screen draws or
  hit-tests a Go Back, Cancel or similar dismiss row that the DOS screen lacks.
* A core Go Back / Cancel button has a DOS form only where the DOS listing gives that screen a key or action with
  the same effect (e.g. Escape), cited by listing address in the record. Otherwise no DOS form reaches it: it is
  recorded as Windows-only, reachable by switching to the Windows graphics.
* Before adding any other row that the DOS screen lacks (as "Custom." was), report it to the orchestrator; do not
  add it on the 5.4 "Flow" rule alone.
* The user's specific directions of 05:43..06:00 UTC (units D5cR and D5eR): no Go Back row on the DOS difficulty,
  competition and tribe pages; no "Custom." row on the tribe page (Escape chooses Custom, as in DOS); no Cancel
  row on the Customize boxes; the Customize choices in sync between the graphics while answering. They reverse
  BRIEF-d5 rulings 4 and 5.

## Authority and design

* The design is DESIGN.md 12.9 (area D, with "As implemented (M)" and its "Not verified"), 12.7 (area B,
  with "As implemented (D4a)" and "Added in D4b2b2", and D5's additions), 12.8 (area C), 12.10 (w16
  changes: D6 adds none without recording why), 12.11 (P0), and the detailed designs
  `verify/ext-d1-draft-D.md`, `verify/ext-d1-draft-B.md` and `verify/ext-d1-draft-C.md` (Revision 3), with
  `verify/ext-d1-decisions.md` (area D: C1..C7; area B: X3, X4). M's code is the base: read
  `ext-M-acceptance.md` and the records `ext-Ma-record.md`, `ext-Mb1-record.md`, `ext-Mb2-record.md`
  ("Deviations from the design"); `ext-D4a-record.md` ("Second review (2026-10-12)": S8 and C1 are D6's);
  the D5 records. Do not redo what exists.
* Sections of draft D: 2 (M2 and D6 parts), 3 (files; `pmap_dos.c`, `pmap_model.c`), 4.1 and 4.2 (the DOS
  profile's `m = 2·s_l`, even origin at -1), 5 (the layer), 6.2 (the DOS in-view source), 9.1..9.4 (the map
  display model), 10.1..10.3 (the present and dos-settled checks; `--mirror 2`), 14.0..14.9 (the DOS map
  rules), 16.1..16.5, 17 (B-2, B-4, B-5, E-1..E-3), 18, 19, 21 (Open D1, D2, D3, D5, D6, D7).
* Sections of draft B: 5.5 (the play palette; `pdos_play_rgb8`), 6.2 and 6.3 (the A canvas and its
  layers), 7.1, 7.3, 7.4, 7.5 (with "As implemented (D4a)"), 8.1..8.6, 10.1 (font 1 in play, inferred),
  11.1..11.4 (menu bar P24, B14, B15; drop-downs; placement on A, B16; `pdos_r_hit` on frame 2), 12.1..12.4,
  15.1 (`test_pdos_replay`, `_reskin`, `_play`), 15.2, 19 (OB1, OB4, OB5, OB6, OB7), 20 (E-B1, E-B3).
* Sections of draft C: C.9 (TC; P6: the core's moves and blink), C.12.8 (I-menu, I-play, I-menubar),
  C.12.9, C.14.3 (I-play, I-menubar), C.15.4 (case 13).
* DOS-PROFILE.md: 1.3 rows 29..66 (the menu items; Orders as A), 1.4 rows 96, 107, 1.5 rows 110, 121,
  132..140, 1.7 (I-play, I-menubar, I-menu), 3.2 (Edit and Help menus), 3.4 (menu bar, status and unit
  panels), 4 (W7, W8). DOS facts: `docs/dos/SCENES-PLAY.md` 0.3, 1.1, 1.2, 2.1..2.4, 3, 4, 5.1..5.3,
  6.1..6.3; `SCENES.md` 10.1, 10.2; `SPRITES.md` (the families of draft D 14.0); `PALETTE.md` 2.4, 2.5, 5;
  `docs/dos/OPEN.md` P6, P9, L2, L3, L4, L10, L11, L12, L19, L23, L25, L27, L28.
* Implement as written; where the code shows the design is wrong or incomplete, make the smallest correct
  fix and record it as a deviation (design section, what and why) in your record.
* DOS facts come only from `claude/port/docs/dos/*.md`, the listing in `claude/port/build/dos/disasm/`
  and the files in `claude/port/build/dosdata/` (read at run time through E's API; never copied into the
  repository). Never from memory. Cite the listing address for every constant. Game facts for the
  Windows rules and the core's globals come from the port's own sources (`claude/src`, `core/`) and the
  listing tools the base prompt allows (showfunc); never from memory.
* The extension prompt (1 P0, 2.3, 4 D-2, D-5, Z-1..Z-3, 5.3..5.8, 5.10, 7.3, 7.4, 7.5, 7.8, 8) and the base
  prompt `claude/docs/x64-port-prompt.md` sections 1, 5.0, 7 and 9 govern.
* The user's directions (STATUS.md "User directions") that touch D6: the zoom levels are -1, 0, +1 halving
  or doubling the default (decision C1); the game's screen follows the host window during the game (phase
  G, F110), so the A canvas has the virtual screen's current size (C4); the menu bar text at 1x beside 2x
  art is the user's check (X4, `manual-checklist-ext.md` D6-1); M-1's DOS part (DOS -1 pixel-perfect at
  every factor) is the user's check; every agent runs on the session's own model.

## Rules

* **P0 above all.** The DOS profile and the map module read only through `w16q_*`, write only
  presentation memory, post nothing except through the filter stage's documented translations (I1) and
  `pmap_filter_ring`, never read `g_randSeed`, and draw no random number. The zoom never feeds
  `present_game_screen` (V4). After every build: `test.cmd checked` (all base tests, gate3b references,
  scenarios, `ext_p0.py`, `ext_frames.py`, `ext_timeline.py`, `ext_adapt.py`, `ext_mirror.py`,
  `ext_zoom.py`, the M, D4 and D5 tests) and `ext_g1.py check` on Checked and CheckedNoObs stay green. A
  failure is fixed before anything else.
* **Each unit ends with the eight-step cycle green:** Checked build and tests, G-1, CheckedNoObs build,
  tests and G-1, Release build and tests; no Asan. **Builds are yours alone** during your unit. Timeout
  600000 ms; logs under `claude/port/build/`, named after your unit.
* **Files.** Edit the code, tests and build files your unit needs and write your record. Do not edit
  `DESIGN.md`, `FIDELITY.md`, `STATUS.md`, `RUNNING.md`, `FEATURES.md`, `DOS-PROFILE.md` (except the
  generated 1.7 section as BRIEF-d5 decision 3 allows), `manual-checklist-ext.md`, the D1 drafts or the D0
  documents (except OFFSETS.md rows, decision 8): list the entries under "For the records".
* **No DOS bytes** in the repository or a binary (`gen/dos/nodos.py check`); tests and goldens store only
  hashes, offsets, sizes and hand-written vectors. Never write `C:\Projects\Civ1RE\dos` or
  `claude/port/build/dosdata`; never execute a DOS program on the host.
* **Code rules** (obs_lint over `present/`): no `w16_` identifier except `w16q_`, no `g_randSeed`, no core
  `RandomBelow`, no `post_event`/`host_poll_event`/`vm_`, no `#if CIV_CHECKED`; under `CIV_OBSERVER 0`
  every new map entry is a stub as M's are. The core's decisions drive the map (DOS-PROFILE 0.6 rule 1;
  P3, P6, P9 settled): never a DOS formula where the core decides.
* **Runs with the DOS profile** (shown or switched to) pass `--dos-data build\dosdata` and assert from
  `profiles.log` that no switch was refused (draft D 16.3, RV1-5).
* **Independence**: never read the main project's excluded paths (`verify/BRIEF-d0.md` lists them);
  ignore AGENTS.md's GFX/DOS/Modern/Mac/SNES sections.
* **UI.** Headless and Win32-headless tests use hidden windows. D6g's agent check: a visible civ64 window
  (civ64 windows only, the UI-launch grant), screenshots under `claude/port/build/ext-d6-ui/`, closed
  promptly; an agent observation is not user acceptance.
* No git writes. Absolute paths; no `cd` chaining. Python only as `C:/Python314/python -B`. Files with
  backslashes only through the Write or Edit tool.
* Keep your context lean: read the sections you implement.

## Units

Seven sequential units, each by one implementer on the session's own model with exclusive ownership of
the files it changes, each ending with the eight-step cycle green and its record
`claude/port/docs/ext-<unit>-record.md`. Each implementer's final message: result, files changed, test
counts, deviations and the "For the records" list. If the orchestrator sends "wrap up", stop adding, make
the build and tests green, and write the record with what is done and what remains.

* **D6a: the map display model with the Windows rule set (M2) and the present check** (about 2 h).
  * Implements: draft D 9.1..9.4 as `pmap_model.c`: the six `PdosMacro`s (DROP on DrawMapTile 1110:04D0,
    DrawUnit 1110:0DBA, DrawUnitAt 1110:0FF6, DrawCityLabels 1208:1F64; CONTEXT on AnimateUnitMove
    11C0:2C32 and ResolveCombat 1050:0000) and the `PdosShadowHooks` for `P`, `S`, `Wn` (claim by the
    globals of 9.2, `on_draw` for the black fills, `on_copy`, `on_resize`, `on_free`), registered from
    `pmap_reset`, both rule-set bits, the Windows set drawing with M's `pmap_win.c` rules and
    `w16q_draw_on`; draft B 7.5's table "D's 9.4 table in this engine"; ext-D4a S8 (`pdos_shadow_rebind`
    with the size update, `on_resize` and the retargeting of open brackets) and the GR_PortDataToBitmap
    10B8:0E36 wiring (B 7.1); draft D 10.1's present check (`Wn_win` against the virtual screen over the
    client's visible region at every core present) and 10.2's `--mirror 2` (needs the DOS profile, B19);
    Open D1 (the scratch port's DC and bitmap offsets, from GR_PortOpen 10D0:0000), D2 (which DrawTile
    calls inside ResolveCombat draw the lunge and the explosion), D5 (drawing outside the macros:
    `map_unexplained`).
  * Files: `present/map/pmap_model.c` (new), `pmap.h`, `pmap_int.h`, `pmap_check.c`; `present/dos/
    pdos_shadow.c/.h` (S8); the harness's `--mirror` handling; `tests/test_map.c` (model vectors on
    synthetic event streams), `tests/test_pdos_shadow.c` (S8 vector), `tests/harness/ext_mirror.py`
    (`--mirror 2 --dos-data build\dosdata` on its 29 runs).
  * Tests (prompt 7): 7.5 literal (present mismatches 0 and `unexplained 0` in every run), 7.3 (the
    mirror runs' core outputs equal ext_p0's V0, as at M).
  * Record `ext-D6a-record.md`. Depends on the D5 gate.
  * Not in the unit: the DOS rule set's drawing (D6c); B's replay (D6b).
* **D6b: logical replay and provenance for play (`pdos_replay`, `pdos_prov`)** (about 2 h).
  * Implements: draft B 8.1..8.6 per decision 3: the brackets on the logical primitives and text probes
    of 8.2 (registered by `pdos_replay` at reset, draft B 7.3 "Registration"), the target kind from the
    globals at entry (B8; the Checked-only harness check against MapLogicalPointToPort 1220:0F2F in one
    scenario per screen family), 8.3's coordinates for kinds 1, 2 and 3 without city mode (B9, exact
    preimages of ScaleLogical first), 8.4's colour rules (`colour_nearest` counted), 8.5's sheet-shape
    provenance read at ExtractGameSpriteShapes 10E8:231F's exit and the cut-shape rule mechanism
    (`pdos_prov_rule`, rules themselves D7), handle recycling, `prov_unknown`; 8.6; S3 (decision 4).
  * Files: `present/dos/pdos_replay.h/.c`, `pdos_prov.h/.c` (new), `pdos_profile.c` (B 2.1 steps for
    `pdos_prov_on_probe`), `pdos_shadow.c` (S3), `build.cmd`/`test.cmd`; `tests/test_pdos_replay.c` (new;
    B 15.1: each 8.2 primitive at the logical position, nothing when the bracket saw no event, 8.3 with
    the exact-preimage case and `L(ScaleLogical(L)) == L` for L in 0..639, 8.4), provenance vectors.
  * Record `ext-D6b-record.md`. Depends on D6a (the map shadows that kind 2 draws into).
  * Not in the unit: any D7 scene renderer; OB9; PROF 2.3's T1..T20 rules; OB2 (DrawBeveledLabelBox, D7).
* **D6c: the DOS map rules in view (`pmap_dos.c`) and the dos-settled check** (about 2 h).
  * Implements: draft D 14.0..14.6 as the DOS rule set of the model: shapes from E's `pdos_shape` by
    family and DOS index (14.0), the page-2 coast and land-base rectangles from
    `pdos_pic(PDOS_F_SP299_PIC)` with cited constants, the colour tables through the registry, the square
    layers of 14.2 (SCENES-PLAY 2.1, R:1AEA:03BA) with the core's decisions over DOS formulas, units
    (14.3, R:1AEA:0E29/0FB3, the sentry recolour), cities (14.4), labels (14.5), animations at the core's
    pace (14.6; P3, P6), all at DOS art scale 2 through `k = 2` ports (14.1, B23); `P_dos`, `S_dos`,
    `Wn_dos` (6.2) and `Wn_dos` as the A canvas's map element (draft B 6.2, 7.5 last bullet; D 17 B-2);
    Open D3 (DGROUP DCFC and D806, OPEN L2) and D6 / OB4 / L23 (the label and digit font) read from the
    listing where it settles them; draft D 10.1's dos-settled check (the DOS world-canvas rules for the
    view against `P_dos` at DrawTilesToPort's exit).
  * Files: `present/map/pmap_dos.c` (new), `pmap_model.c`, `pmap_check.c`, `pmap_int.h`;
    `present/dos/pdos_compose.c` (the map element); `tests/test_map.c` (16.1 "DOS composition order on a
    synthetic square set"; the layer order of 14.2 per layer), `ext_mirror.py` (dos-settled).
  * Tests (prompt 7): 7.5 (dos-settled mismatches 0 with `--mirror 2`), 7.3 V1/V2 with the DOS map drawn,
    7.4 (`ext_frames.py` on play scenarios), `unexplained` 0 on the map shadows.
  * Record `ext-D6c-record.md`. Depends on D6b.
  * Not in the unit: the ring and zoom (D6d); the small map and status window (D6e).
* **D6d: the DOS ring, zoom in the DOS profile and the map palette animation** (about 2 h).
  * Implements: draft D 14.9 (`G_dos`, the DOS world canvas, about 1 MB more, from the snapshot with the
    core's decisions computed by the Windows readers), 6.2 as the layer's in-view source in the DOS
    profile, 4.1/4.2 (`m = 2·s_l`; DOS art pixels k x k at -1 with the even origin; pixel-perfect at every
    k), 5.3..5.5 with the DOS source; 14.7 (the play palette's three slots stepped at each
    CyclePaletteColors 1208:22B7, already wired by D4a in `pdos_profile.c`; the layer and the A elements
    reconverted through `pdos_play_rgb8()` on each step; OPEN L12 read); draft D 16.3's DOS runs and the
    profile-switch half of `ext_zoom.py` (equal Windows-layer and DOS-layer samples at equal times with and
    without switching; `profiles.log` `map` hashes per profile, A-6), 16.4 (V4 with the DOS profile and
    `--switch-every 997`), 16.5 in the DOS profile (wheel, chords, a ring click against its small-map
    reference). Measure the DOS layer's palette reconversion under `fit` sharp (M's deviation: a full
    render) and record it.
  * Files: `present/map/pmap_world.c`, `pmap_layer.c`, `pmap_inview.c`, `pmap_zoom.c` (if needed),
    `pmap_dos.c`; `tests/test_map.c` (DOS geometry tables), `tests/harness/ext_zoom.py` and
    `ext-zoom-golden.txt` (new DOS samples, `--update` after the determinism check), `ext_p0.py` (V4 with
    DOS and switching), `ext_adapt.py` (the DOS zoom pairs).
  * Tests (prompt 7): Z-1, Z-2 (determinism), Z-3 for the DOS profile; 7.3 V4; 7.4; 7.8.
  * Record `ext-D6d-record.md`. Depends on D6c.
* **D6e: the small map, the status window and the unit panel (class A elements); the play palette's life
  cycle** (about 2 h).
  * Implements: draft B 12.1..12.4 in a new module (B 2's `pdos_play.c`; note that `pdos_pal.h` already
    uses the `pdos_play_*` names for the play palette, so pick non-colliding names and record them): the
    small map (12.2: the macros DrawSmTiles 1210:09B4, RedrawSmMap 1210:073F, PlotSmMapSquare 1210:07AE;
    state from `pmap_src_current()` and `pmap_view_current()`, B17; the core's view frame, P9; OPEN OB6
    from R:1AEA:17CF), the status window (12.3: RedrawStatusWindow 1218:0801, DrawStatusCivPanels
    1088:13D5, DrawMiniPalace 1088:1A82, DrawUnitInfoPanel 11F0:468C; the DOS column of B18; the lines
    and icons by provenance; OB7 from 11F0:468C; OPEN L4), the window frames as W (12.4, DOS-PROFILE 4
    W7); draft B 5.5 item 2 (`pdos_play_back` with OB1's inputs read from R:0238:1BEB; OPEN L11) per
    decision 5; draft D 19 "not zoomed" (the small map's pixels at a zoom level equal level 0's; not built
    at M).
  * Files: the new class-A module `.h/.c`, `pdos_profile.c` (B 2.1 step 4 of `on_event`), `pdos_compose.c`
    (the elements at 2x, clipped to their window's visible client region), OFFSETS.md rows (decision 8);
    `tests/test_pdos_play.c` (new; B 15.1: small-map colours and frame from a synthetic snapshot, status
    lines from captured strings, unit-panel lines and the stack overflow "+"), `ext_zoom.py` (the "not
    zoomed" check).
  * Record `ext-D6e-record.md`. Depends on D6b (provenance, S3) and D6d.
  * Not in the unit: the population message box (row 137) as R (D6f's placement draws it); the full-screen
    scenes' TX fades (D7).
* **D6f: menus (R) on the A canvas; adapters I-play and I-menubar** (about 2 h).
  * Implements: draft B 11.2's menu bar (P24 settled: the Windows geometry, DOS titles with the 87h colour
    switch for the five DOS menus, Edit, City and Help in capitals with the mnemonic in 15 and the rest in
    7, B14; font 1 at scale 1, B15; the highlighted title as the menu-box highlight) and drop-downs
    (OBS_MENU_OPEN/HILITE/CLOSE, `w16q_menu_bar`, `w16q_menu_item`; DOS menu box in font 1; OB5 the check
    mark, OPEN L19 the Options state, L25; decision 2's text source); 11.3's A placement at 2x (B16,
    clipped by the windows above, B 6.2) for D5b's re-skins per decision 1; ext-D4a C1 (one surface per
    element, or a per-element `gen`, before boxes go on both canvases); draft C C.12.8's I-play (F1..F10 to
    complete Ctrl+digit pairs for commands 401..406, 501..504; Alt+V to command 109 through its menu path;
    everything else passes, recorded as Windows-only per C.12.9) and I-menubar (clicks pass by identity),
    I-menu on frame-2 points through `pdos_r_hit`; C.15.4 case 13 (a drag from a DOS menu-box row onto the
    map layer posts no click); OPEN L3 and L27 read (right button on the map, the Civilopedia caller) and
    recorded, extending I-play only if the listing shows a DOS-only key with a core counterpart.
  * Files: `present/dos/pdos_reskin.c/.h`, `pdos_compose.c/.h`, `pdos_adapt_tab.c`, `pdos_adapt.c`,
    OFFSETS.md rows (`MENU_TITLES`); `tests/test_pdos_reskin.c` (B 15.1's A parts: menu bar title colours
    and positions from synthetic `w16q_menu_bar`/`w16q_menu_item` results, drop-down rows, 2x placement and
    clipping), `tests/test_input.c` (I-play pairs, I-menubar), `ext_adapt.py` (F-keys against Ctrl+digit
    pairs, Alt+V against the Sound command, a menu-bar click and a drop-down choice against the same input
    in the Windows profile, case 13).
  * Tests (prompt 7): 7.8 (EXT_ADAPT_OK), 7.3, 7.4; the chord audit of C.12.9 still holds.
  * Record `ext-D6f-record.md`. Depends on D6e and D5b.
* **D6g: the sweep, the agent check and the gate** (about 1.5 h).
  * Implements: the full runs of decision 6 (`ext_zoom.py` matrix with the DOS half, `ext_mirror.py`
    `--mirror 2` with dos-settled, `ext_p0.py` V1, V2, V4 with DOS and switching, `ext_frames.py`), the
    counters (`unexplained`, `w_over_n`, `colour_nearest`, `font_unmapped`, `prov_unknown`) 0 for the D6
    rows by the attribution of BRIEF-d5 decision 8, the Z-1..Z-3 table for the DOS profile, the agent UI
    check (decision 7: a visible civ64 window, `--graphics dos` with `--dos-data`, a loaded save at
    1920x1440 or the nearest the desktop allows; the DOS map, small map, status window and unit panel;
    the menu bar and one drop-down; zoom -1/0/+1 by chord and wheel; a ring click; a profile switch at -1;
    screenshots under `claude/port/build/ext-d6-ui/`), then `ext-D6-acceptance.md`.
  * Record `ext-D6g-record.md`, then `ext-D6-acceptance.md`. Depends on D6a..D6f.

## The gate record `claude/port/docs/ext-D6-acceptance.md`

* The gate table with methods (compiled; headless; Win32-headless; agent-observed; DOS listing (model))
  and results: the DOS map (squares, units, cities, labels, unexplored edges, animations at the core's
  pace), the map palette animation, the small map, the status window and unit panel, the menu bar and
  drop-downs, the A-canvas re-skins of decision 1, I-play and I-menubar; Z-1..Z-3 for the DOS profile (the
  levels and `m = 2·s_l`, pixel-perfect at -1 for every k; determinism of zoomed DOS frames and the
  profile-switch half; input in the zoomed DOS map and P0 under zoom changes); 7.5 (`--mirror 2` present
  and dos-settled: checks, mismatches 0, `unexplained 0`, per run); 7.3 (P0_OK with V1, V2, V4 and the
  DOS profile, CheckedNoObs), EXT_G1_OK on both Checked variants; 7.4 (EXT_FRAMES_OK, ZOOM_OK); 7.8
  (EXT_ADAPT_OK); the counters; MIRROR_OK, ZOOM_OK, REGISTRY_OK, NODOS_OK, `pdos_scene_check` counts.
* The agent check's result and screenshots, or why it was not completed (decision 7).
* The seven unit records linked; every deviation, one line each; DOS-oracle comparisons "not run in D6
  (optional; see STATUS)"; Asan deferred; "For the records" gathered from all seven records (DESIGN 12.7
  and 12.9 "As implemented (D6)", FIDELITY entries for every DOS/Windows difference of draft D 14 and B 12,
  DOS-PROFILE.md rows 96, 107, 121, 132..140 and the menu rows, RUNNING (`--mirror 2`), FEATURES, new
  checklist items).
* User checks left pending: D6-1 (X4), M-1's DOS part, M-2 in the DOS profile and the new D6 items;
  "not verified" (at least: coverage limited to what the scenarios reach, as at M; the combat sparks'
  DOS routine, OPEN L10 / DOS-PROFILE Open 8; costs from one machine).

## Size

About 13 to 14 hours of implementation in seven units (D6a..D6f about 2 h each, D6g about 1.5 h), each
followed by its eight-step cycle (about an hour of build and test time at D4's figures, more once the DOS
halves of `ext_zoom.py` and `ext_mirror.py` run; decision 6).

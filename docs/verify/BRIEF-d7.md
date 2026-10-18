# Brief for the D7 implementers (extension phase D7: every remaining N and R scene)

> **Cycle rule changed 2026-10-15 about 14:09 UTC (the user's decision, STATUS "User directions"; `verify/BRIEF-cy.md`):** wherever this brief says "the eight-step cycle", a unit now ends with the **three-step cycle** (`build.cmd checked`, `test.cmd checked`, `ext_g1.py check`); the full eight-step cycle runs only at phase gates (D4, BS, D5, D6, D7, X9, WL and before the final Asan pass).

Written 2026-10-15 for the orchestrator by a read-only planning agent; adopted by the orchestrator
2026-10-15 with the rulings at the end of "Decisions for the orchestrator". Phase D7 of the extension
prompt `claude/docs/x64-port-scaling-dos-prompt.md` (section 9): "Every remaining N and R scene of the
scene table." Gate: "Every row implemented or class W with a reason." D7 completes the third and fourth
bullets of D-5 (prompt 4: every in-game N and R scene of the scene table is implemented; every row of the
counterpart table is implemented, or is class W with a reason) and reaches every `FEATURES.md` row
headless in the DOS profile (prompt 7.10). The FEATURES DOS columns (class, hash, status; D-7) and the
completion of DOS-PROFILE.md (D-6) are D8's. Asan runs stay deferred to the end of the queue (the user's
direction of 2026-10-10 21:20).

D7 starts after the D6 gate (`ext-D6-acceptance.md`; brief `verify/BRIEF-d6.md`). It builds on D4c's
adapter table and filter stage, D5b's `pdos_reskin`, the `pdos_fx` module that D5d or D5e creates, D5f's
`pdos_scn_fame.c`, D6b's `pdos_replay` and `pdos_prov`, D6c's DOS square layers, D6e's class-A module
(the small map, the status window, `pdos_play_back`) and D6f's A-canvas placement of re-skins.

Earlier rulings that bind D7: BRIEF-d5 rulings 2 (OFFSETS.md rows may be added, never changed), 3
(generated DOS-PROFILE.md sections and mirrored scene-table rows may be updated, then
`C:/Python314/python -B gen/obs_tables.py --check`), 6 (rows 129 and L26 are D7's), 7 (new coverage only
in `ext_adapt.py` pairs and `ext_p0.py` runs), 8 (counters attributed to the innermost scene row) and 9
(rows 117 and 118 are D7's); BRIEF-d6 rulings 1 (the scene-specific R rows 12, 17, 18, 115, 117, 118,
126..128 and the menu items whose screens are N are D7's), 2 (DOS texts where a row pairs, by role, with
the evidence label; an unsure pairing stays the core's text), 3 (B 8 built by D6b; the cut-shape rules
T1..T20 and city mode OB9 are D7's), 5 (the TX fades around the return to the map are D7's), 7 (the
agent-check rules) and 9 (rows 93 and 110 are D7's).

## Decisions for the orchestrator

Design gaps and choices found while planning; no DOS fact is decided here. Each has a proposal.

1. **Unit cut.** **Proposal:** fifteen sequential vertical slices by scene family (D7a..D7n about 1.5 to
   2 h each, D7o the sweep and the gate): each unit owns the renderer, the `pdos_prov` rules, the
   scene-table readiness, the adapter rows, the 7.7 timeline entries and the 7.8 pairs of its scenes, as
   BRIEF-d5 ruling 1 did for D5. Alternative: cut by layer (all renderers, then adapters, then
   timelines), which leaves scenes half-done between units.
2. **Entry-only probes of R rows.** Rows 115 (SetGovernment 1168:06C1), 117 (ShowInstantAdvice
   10E0:077F), 118 (ShowErrorNote 10E0:07E8), 126 (ProcessCityDisaster 1040:068E), 127 (StartCivilWar
   11A0:0000) and 128 (DiplomatEntersCity 11B8:0000, TransferCityByRevolt 11B8:0F26) have entry-only keys
   in `present/obs_tables.c` and `PDOS_NO_KEY` in `pdos_scene_tab.c`. A scene row needs the exit phase of
   its entry key unless it names an exit (draft B 7.3 "Registration"; RV2-1). Their DOS forms differ from
   the generic boxes only in position, header and colours (SCENES-PLAY 7.6, 7.10, 7.18), and the boxes
   come from functions with both phases (ShowTextNoteDialog 10E0:03A2, ShowTextDialog 1220:00D2, MenuZ
   1220:0156). **Proposal:** context rows: the entry probe hands `pdos_reskin` a pending DOS form (anchor;
   header number or box colour and outline) that applies to the next generic box opened under it and is
   dropped at that box's exit. Row 116 (ShowHelpNote 10E0:0000) is entry-only too: reuse D5e's mechanism
   if `ext-D5e-record.md` shows one. The header number of rows 126 and 127 already comes from
   `g_messagePicture` (CORRESPONDENCE finding 4) through the box re-skin, so only the position is
   context there. Alternative: exit phases for these functions in the observer tables (an observer
   change: a DESIGN 12.10 entry, G-1 and P0 again, the probe verification extended).
3. **Return to the map (D6 ruling 5).** DOS: R:0238:1B44 ends most full-screen scenes: fade to black
   (R:0000:04D4(5, 0, 0, 0)), map redraw, then R:0238:1BEB loads the play palette and fades it in
   (R:0000:04AA(5, C5BE)) (SCENES-PLAY 0.3; TIMING 5.8 lists R:0238:1B66 and R:0238:1C86, 30 frames
   each). The city view leaves through R:0238:1BEB alone (7.2); the spaceship screen restores the map
   palette without a fade (7.16). In civ64 the core has already left the scene when the frame returns to
   A (D6e's trigger, RestoreMapAfterDialog 1208:14D5). **Proposal (b):** the fade-in only (C.9's
   duration rule) on the A canvas's play-palette layers from that trigger, with an exit kind per renderer
   (R:0238:1B44, R:0238:1BEB alone, none); the fade-out is abandoned because the core left first (C.9,
   C.5.2); input passes (no DOS flush is documented for R:0238:1B44). Alternatives: (a) hold the last N
   frame and fade it out over 30 frames before showing A (a presentation delay the core does not wait
   for); (c) no fades.
4. **City screen layout (OB9; OPEN L20, L22).** The DOS city screen R:0D12:0045 is one routine of about
   27 KB (SCENES-PLAY 7.1); the core's ProcessCity 1030:0000 draws its own layout in logical coordinates.
   **Proposal:** logical replay of the core's city screen (B 8, city mode `g_cityTileDrawMode`, B 8.3)
   with DOS art, fonts and colours; R:0D12:0045 read for OB9 (the map-square positions); an element is
   moved to its SCENES-PLAY 7.1 position only where the documents or the listing show the DOS layout
   differs, each move recorded with its input translation. I-city as DOS-PROFILE 1.7 (shared keys pass;
   DOS region clicks map to the key of the same function or a device point of the core's region; L20's
   keys read and translated or recorded). Alternative: a DOS-layout renderer drawing the whole DOS screen
   from the core's city record through `w16q_read` (larger; every layout difference becomes an input
   translation).
5. **Newspaper over the play screen (row 101).** DOS O21:0000 fills only (0, 0, 320, 100) and leaves the
   play screen below, with its "Press any key" box at (80, 128) (SCENES-PLAY 7.7); the Windows
   ShowNewspaper clears its whole page white (`claude/docs/subsystems/advisors.md`); in the DOS profile
   the play screen is the A frame. **Proposal (c):** the newspaper's DOS form on the A canvas at 2x,
   anchored and clamped as B 11.3 places R boxes on A (B16), so the play screen shows beneath as on DOS
   (recorded deviation from "N on the N canvas"). Alternative (b): an N frame with the lower half filled
   (colour recorded). Row 119 (New Cabinet, O5:1BA2 fills the lower half) is a full N frame either way.
6. **Newspaper tag and slogan.** The core decides the name form, tag and slogan with RandomBelow at
   1138:03C2, 04A1 and 058B (DOS-PROFILE 0.6 rule 1), but the observer's call-site table has rows only for
   1138:01B8 and 1138:03C2 (`present/obs_tables.c`), so the tag and slogan choices are not observed.
   **Proposal:** draw the strings the core draws (B 8.2's text probes) in the DOS fonts, positions and
   colours; the name form comes from the observed 1138:03C2 exit. Alternative: name the two call sites
   in DOS-PROFILE row 101 so that `gen/obs_tables.py` adds their call-site rows, and draw the DOS
   `KING.TXT` NEWS sections (an observer-table change: DESIGN 12.10 entry, G-1, P0, probe verification).
7. **Spaceship arrival (row 130; P32..P34, T17, E12's arrival part; OPEN L1; DOS-PROFILE Open 5).**
   O2:0BD7 is only partly read (SCENES-PLAY 7.16; TIMING 5.7). **Proposal:** D7l reads the listing for
   at most about 45 minutes of its time box; if pictures, positions, waits and cycling slots are
   established it implements row 130; otherwise the orchestrator marks row 130 W provisionally ("DOS
   sequence not established in the listing, OPEN L1; reopen with the oracle"), with P32..P34, T17 and
   E12's arrival part following it. A DOS counterpart exists, so this W is a stopgap and says so.
   Alternative: the gate passes "with open items" with row 130 shown as the A frame (not ready).
8. **Palace art gaps (counterpart P27, DOS-PROFILE Open 12, OPEN L17).** **Proposal:** picture 4446 is
   not drawn in the N palace (no DOS source; recorded as T21 and F11 are); the composer O17:07EC draws the
   core's palace state with the DOS pieces by P28..P30's pairings; where a Windows state has no DOS file
   (the fourth ground level, a style without a DOS quadrant, the gardens of P29), D7j reads O17:07EC for
   the DOS selection and, if the listing does not settle it, uses the nearest DOS level or style with the
   pairing recorded as a difference. Alternative: the Windows piece converted into the N frame (a new
   W-over-N case in DOS-PROFILE 4.1).
9. **The far tables of OPEN L1 and LEADER_FONT.** The wonder rectangles `[DGROUP:6444]` (P17, T11) and the
   throne-room animation table `[DGROUP:640A]` (T5) wait for their lengths (OFFSETS.md note; FORMATS 6.1;
   draft E E.10.3). The first 16 bytes of `[DGROUP:640A]` are B 10.1's leader-font table (OB8, E-B2), a
   D7 row `LEADER_FONT` by name. **Proposal:** D7e and D7k read the tables' readers in the listing for
   the lengths and add the rows under BRIEF-d5 ruling 2 (`LEADER_FONT` in any case), with the FORMATS 6.1
   correction (both uses of `[DGROUP:640A]`) "For the records"; a table whose length is not established is
   not registered, its art is not drawn (wonders absent from the DOS city view, attendants without their
   animation frames), counted, and listed at the gate. Alternative: register with a length bounded by the
   next relocated segment, labelled inferred.
10. **Civilopedia bodies (rows 11, 99).** DOS bodies come from `BLURB0..4.TXT` (DOS-PROFILE 3.4;
    SCENES-PLAY 7.13); 3.4 proves name pairing only for the `KNG_`, `HLP_` and `ERR_` sections.
    **Proposal:** the core's body text (folded, B13; in the DOS font, colours and positions) unless D7h
    shows from O8:062A and the core's lookup how a core entry pairs with a BLURB section (then the DOS
    text, labelled with that evidence); OPEN L24's fallback rule. Alternative: DOS text by matching the
    entry name to a BLURB section name (inferred, unproved).
11. **NUKE1's palette on the A canvas (row 110; P8, T16, E16).** DOS loads `NUKE1.PIC` with its palette
    (R:1FA1:0220) and restores the map palette with R:0238:1BEB (SCENES-PLAY 7.5). **Proposal:** the
    core's frames, pace and position (TC) drawn with NUKE1 cells at 2x, with NUKE1's palette applied to
    the A canvas's play-palette layers for the scene (the whole frame changes colour as the DAC does),
    then `pdos_play_back` with decision 3's fade-in. Alternative: NUKE1's palette for the explosion cells
    only.
12. **Coverage of scenes the scenarios do not reach.** `ext-D3-probe-verification.md` "Keys the runs
    never hit" lists, among D7's, DrawCivDossier 1018:17DB, DrawBeveledLabelBox 1030:8C11,
    AnnounceGovernmentChange 10E8:32C1, ShowConqueredCivLeader 1180:17E9, PlayCelebrationAnimation
    11B0:237C, AnimateNuclearExplosion 11B8:0C3D and FrameRectDoubleDevice 1220:114B;
    `ext-D3-acceptance.md` lists keys that the G-1 runs hit but the 27 P0 scenarios do not reach
    (1040:068E, 1070:1952, 1070:2015, 1168:06C1, 1188:0DB8, 11A0:0000, 11B0:1B63, 11B0:1FAC,
    11B8:0000, 11B8:0F26, 11D8:087F, 11D8:0BD2 among them). **Proposal:** within BRIEF-d5 ruling 7:
    renderer unit vectors on synthetic event streams for every such row; one `ext_p0.py` V1 run in the DOS
    profile of each G-1 run that reaches a D7 key the scenarios miss (at D7o at the latest); edited-save
    runs (test input, labelled as FEATURES.md does) or `ext_adapt.py` pairs where cheap; rows never
    reached headless listed at the gate as "unit-tested, not reached headless".
13. **Test time.** Fifteen cycles on top of D6's suite. **Proposal:** `test.cmd checked` gains one
    representative `ext_timeline.py` and one `ext_adapt.py` entry per scene family; the full set of D7
    timelines, pairs and V1/V2 runs (including decision 12's G-1 runs) runs once at D7o and goes into the
    gate record.
14. **The agent check.** D7's gate line names none. **Proposal:** one optional attempt at D7o under D6
    ruling 7's rules (civ64 windows only, `--graphics dos --dos-data build\dosdata`, screenshots under
    `claude/port/build/ext-d7-ui/`, stop on "user interrupt" without retry), covering a sample of the
    new scenes; not blocking. The visible checks go to the user through D8's checklist.
15. **DOS static text in play's R boxes.** **Proposal:** extend D6 ruling 2 to box headers, captions and
    menu texts of D7's R rows (for example the replay question DGROUP:3FB0, the government menu, the
    production question, the text-entry prompts of DOS-PROFILE 3.4), each pairing listed with its label;
    an unsure pairing stays the core's text.
16. **7.10 reach.** **Proposal:** D7o runs `tests/harness/features.py` with `features.map` over the
    `ext_p0.py` V1 (DOS profile) output folders and requires every row reached; for each row it also
    checks from the run's scene log that the innermost scene row at the reaching event is ready or W
    (reached in its DOS form, not the A fallback). The frames are not recorded as FEATURES hashes (D8).
17. **Counterpart rows still open in the documents.** **Proposal:** each closes as "implemented", "not
    drawn/not used, with reason" (precedent T21, F11, E2) or W: T5 per decision 9; T17, P32..P34 and
    E12 (arrival) per decision 7; P27 per decision 8; S11 and S12 by D7d (S12's rule "the N city screen
    draws the DOS yields"; S11 after reading OPEN L22); F10 (the leader text font) and F17 (DOS font 9,
    no Windows id) by D7k reading O6:251D (L23); F15 (the EXIT font) by D7d. D7o lists every 2.1..2.7 row
    with its closure.
18. **OFFSETS.md rows.** **Proposal:** BRIEF-d5 ruling 2's exception for D7: at least `LEADER_FONT`, the
    spaceship part records DGROUP:4BD0 (FORMATS 6.1: 10 records of 26 bytes), the tables of decision 9
    if established, and the strings D7 draws from DGROUP (DOS-PROFILE 3.4; for example DGROUP:43F0,
    3FB0, 2FAC, 24EC). `REPORT_CAPTIONS` and the three `ICONPG_*` rows already exist (phase D7).

### Rulings (orchestrator, session E3, 2026-10-15; these bind the D7 units)

1. Adopted (fifteen sequential vertical slices D7a..D7o).
2. Adopted (context rows reusing D5e's row-116 mechanism); an observer-table change only if that
   mechanism cannot serve a row, recorded with its DESIGN 12.10 entry, G-1 and P0 evidence.
3. Adopted, proposal (b): fade-in only from the return trigger, an exit kind per renderer, the abandoned
   fade-out recorded as a difference; input passes.
4. Adopted (logical replay with DOS art; moves only where documented, each with its input translation).
5. Adopted, proposal (c), recorded as a deviation from "N on the N canvas".
6. Adopted: draw the strings the core draws (the core's decision, dynamic text); no observer-table change.
7. **Alternative adopted, not the provisional W:** a row with a DOS counterpart is never class W. If D7l's
   time-boxed listing work does not establish row 130, it stays "not ready" (shown as the A frame) and
   D7's gate passes "with open items" naming row 130, P32..P34, T17 and E12's arrival part; X9 reports
   them.
8. Adopted (4446 not drawn, recorded; nearest DOS level or style only where the listing does not settle
   it, each pairing recorded).
9. Adopted; the "length bounded by the next relocated segment" alternative is rejected (no inferred table
   lengths in the registry).
10. Adopted (the core's body text unless a pairing is shown from the listing).
11. Adopted (NUKE1's palette on the play-palette layers for the scene, then `pdos_play_back` with ruling
    3's fade-in).
12. Adopted, within BRIEF-d5 ruling 7 (`scenarios.py`, gate3b and the G-1 baseline with its amendment list
    unchanged by D7).
13. Adopted.
14. Adopted (one optional attempt at D7o, not blocking, D6 ruling 7's rules).
15. Adopted.
16. Adopted.
17. Adopted; D7o lists every counterpart row 2.1..2.7 with its closure.
18. Adopted, as BRIEF-d5 ruling 2.

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

* The design is DESIGN.md 12.7 (area B, with "As implemented (D4a)", "Added in D4b2b2", "Added in D4b3",
  the F2 limitation and the D5 and D6 additions), 12.8 (area C), 12.9 (only the parts D7 reuses: the map
  snapshot and the DOS square layers), 12.10 (w16 changes: D7 adds none without recording why) and 12.11
  (P0); the detailed designs `verify/ext-d1-draft-B.md`, `verify/ext-d1-draft-C.md`,
  `verify/ext-d1-draft-E.md` (Revision 3) and `verify/ext-d1-decisions.md`. Read `ext-D4a-record.md`
  ("Second review (2026-10-12)": F1 and F2 are D7's), `ext-D4b3-record.md` (the leader-face part), the
  D5 and D6 records and acceptance files. Do not redo what exists.
* Sections of draft B: 5.3 (fade arithmetic and cycling slots), 5.4 (per-scene palettes), 5.5 (the play
  palette), 6.1..6.4 (the canvases, which frame is presented, W over N), 7.3 ("Registration"), 8.1..8.6
  (replay, city mode, colours, provenance), 9.2 (the scene stack), 9.3 (the core's decisions and
  `pdos_rand`, B11), 10.1..10.4 (font map with LEADER_FONT, glyphs, alignment, Windows-1252), 11.1..11.4
  (class R: the Text box with header, Text entry, List, Production list and Unit stack popup elements;
  placement on N and A; hit geometry), 15.1, 15.2, 19 (OB2, OB4, OB8, OB9), 20 (E-B1, E-B2).
* Sections of draft C: C.9 (TS, TC, TX in the other scenes), C.10.2 (who decides), C.12.2, C.12.5,
  C.12.8 (I-menu, I-stack, I-city, I-report, I-pedia, I-palace, I-space; Find City; Hall of Fame
  "Clear"), C.12.9, C.14.2, C.14.3, C.15.1, C.15.3, C.15.4. Draft E: E.6.1 (OPEN P27, the odd-width
  rows), E.9.2 (page-2 art), E.10.1..E.10.3 (the registry and its seed rows).
* DOS-PROFILE.md: 0.5, 0.6; 1.2 rows 11..19, 22..26; 1.3 rows 41, 42, 67..93; 1.4 rows 97..106; 1.5 rows
  109..131; 1.6; 1.7 and 1.7.1; 2.1 P7, P8, P10..P30, P32..P37; 2.2 S5, S7, S10..S13, S17..S19, S21,
  S23; 2.3 T1..T20; 2.4 F7, F9, F10, F15, F17; 2.6 E11, E12, E15..E21, E23; 2.7; 3.1, 3.4; 4 and 4.1;
  Open 2, 3, 5, 6, 9, 11..16, 19..21, 24, 26.
* DOS facts: `docs/dos/SCENES-PLAY.md` 0.1..0.3, 1.2, 7.1..7.20 and Open; `SCENES.md` 7.5, 10.1, 10.3,
  10.4; `SPRITES.md` 6.2..6.5, 7, 8; `PALETTE.md` 3, 4, 5; `TIMING.md` 5.6..5.8; `FORMATS.md` 3.1..3.3,
  6.1; `CORRESPONDENCE.md` 3 (the O5:1AF6 row), 5, 7, 8, 10, 11, 13, 15, 16 and Open; `OPEN.md` L1, L6,
  L8, L14, L15, L17, L18, L20..L24, L26, P16, P18, P19, P20, P26, P27, O7, O8. The listing in
  `claude/port/build/dos/disasm/` where a unit reads routines the documents mark partly read.
* Implement as written; where the code shows the design is wrong or incomplete, make the smallest correct
  fix and record it as a deviation (design section, what and why) in your record.
* DOS facts come only from `claude/port/docs/dos/*.md`, the listing in `claude/port/build/dos/disasm/`
  and the files in `claude/port/build/dosdata/` (read at run time through E's API; never copied into the
  repository). Never from memory. Cite the listing address for every constant. Game facts for the
  Windows side and the core's globals come from the port's own sources (`claude/src`, `core/`) and the
  listing tools the base prompt allows (showfunc); never from memory.
* The extension prompt (1 P0, 2.3, 4 D-5, D-6, 5.3..5.6, 5.9, 5.10, 7.3, 7.4, 7.7, 7.8, 7.10, 8) and the
  base prompt `claude/docs/x64-port-prompt.md` sections 1, 5.0, 7 and 9 govern.
* The user's directions (STATUS.md "User directions") that touch D7: 320x200 frames are 4:3 (decision
  X3); every agent runs on the session's own model; Asan deferred.

## Rules

* **P0 above all.** The DOS profile reads only through `w16q_*`, writes only presentation memory, posts
  nothing except through the filter stage's documented translations (I1), never reads `g_randSeed` and
  draws no core random number. The core decides content (DOS-PROFILE 0.6 rule 1; C.10.2): leader idle
  frames, newspaper choices, star positions, the disaster case, the city view placements (P20). After
  every build: `test.cmd checked` (all base tests, gate3b references, scenarios, `ext_p0.py`,
  `ext_frames.py`, `ext_timeline.py`, `ext_adapt.py`, `ext_mirror.py`, `ext_zoom.py`, the M, D4, D5 and
  D6 tests) and `ext_g1.py check` on Checked and CheckedNoObs stay green. A failure is fixed before
  anything else.
* **Each unit ends with the eight-step cycle green:** Checked build and tests, G-1, CheckedNoObs build,
  tests and G-1, Release build and tests; no Asan. **Builds are yours alone** during your unit. Timeout
  600000 ms; logs under `claude/port/build/`, named after your unit.
* **Files.** Edit the code, tests and build files your unit needs and write your record. Do not edit
  `DESIGN.md`, `FIDELITY.md`, `STATUS.md`, `RUNNING.md`, `FEATURES.md`, `manual-checklist-ext.md`, the D1
  drafts or the D0 documents, except: OFFSETS.md rows may be **added** (decision 18; then `registry.py`
  generate and check and `nodos.py check`); in DOS-PROFILE.md the generated 1.7 section and the rows the
  code tables mirror (scene-table rows 1.1..1.5, font rows of 2.4) may be updated so that
  `pdos_scene_check.py` and the adapter-table check pass. After **any** DOS-PROFILE.md edit run
  `C:/Python314/python -B gen/obs_tables.py --check`: `gen/obs_tables.py` turns `SSSS:OOOO` call
  addresses in DOS-PROFILE.md into call-site rows (D4b1 met `OBS_TABLES_ERROR` that way; 2.4's F8 note),
  so name functions, not new call addresses, unless the observer tables are meant to change. List every
  other entry under "For the records".
* **No DOS bytes** in the repository or a binary (`gen/dos/nodos.py check`); tests and goldens store only
  hashes, offsets, sizes and hand-written vectors. Never write `C:\Projects\Civ1RE\dos` or
  `claude/port/build/dosdata`; never execute a DOS program on the host.
* **Code rules** (obs_lint over `present/`): no `w16_` identifier except `w16q_`, no `g_randSeed`, no core
  `RandomBelow`, no `post_event`/`host_poll_event`/`vm_`, no `#if CIV_CHECKED`. DOS-only effects with no
  core decision (the newspaper's torn edge, the rating ladder's border tiles) use `pdos_rand` seeded per
  effect instance (B11), started only in `on_event`, `on_probe` or `advance` (RV2-18).
* **Renderers that transcribe DOS drawing** check D4a's F2 (the sprite arena of each G#18 against the
  grabs before the next G#18) and F5 (G#31's ghost pointer before a copy from that page) per call site
  and record the result.
* **Scene macros and rows.** A DROP or CONTEXT macro key needs the X phase (B 7.3 "Registration",
  `macro_config`); a scene row needs the exit phase of its entry key unless it names an exit. Mark a row
  ready (`pdos_scene_set_ready`) only when its renderer, provenance rules and adapter rows are complete;
  a row that is not ready shows the A frame. Counters (`unexplained`, `w_over_n`, `colour_nearest`,
  `font_unmapped`, `prov_unknown`) must be 0 for your rows (BRIEF-d5 ruling 8's attribution).
* **Runs with the DOS profile** (shown or switched to) pass `--dos-data build\dosdata` and assert from
  `profiles.log` that no switch was refused (draft D 16.3, RV1-5).
* **Independence**: never read the main project's excluded paths (`verify/BRIEF-d0.md` lists them);
  ignore AGENTS.md's GFX/DOS/Modern/Mac/SNES sections.
* **UI.** Headless and Win32-headless tests use hidden windows; the optional agent check is D7o's only
  (decision 14). An agent observation is not user acceptance.
* No git writes. Absolute paths; no `cd` chaining. Python only as `C:/Python314/python -B`. Files with
  backslashes only through the Write or Edit tool.
* Keep your context lean: read the sections you implement.

## Units

Fifteen sequential units, each by one implementer on the session's own model with exclusive ownership of
the files it changes, each ending with the eight-step cycle green and its record
`claude/port/docs/ext-<unit>-record.md`. Each implementer's final message: result, files changed, test
counts, deviations and the "For the records" list. If the orchestrator sends "wrap up", stop adding,
make the build and tests green, and write the record with what is done and what remains. Every unit
updates `present/dos/pdos_scene_tab.c` (keys, renderer, recipe, timeline, adapter, readiness of its
rows), `pdos_adapt_tab.c` and `build.cmd`/`test.cmd` for new sources and tests; these shared files pass
from unit to unit. Adapter names and mouse classes are DOS-PROFILE 1.7 and 1.7.1's.

* **D7a: N scenes in play, the return to the map, the report frame and City Status** (about 2 h).
  * Rows: 98 (Advisors and reports: the O14 frame and its close), 67 (Advisors > City Status), 25
    (dialog 148: the report window's opener of WI 4.2).
  * Implements: the N scene in play over A (B 6.3, 9.2) with the exit kind of decision 3 and its TX
    fade-in in `pdos_fx` from D6e's trigger, abandoned per C.9; the page-2 advisor portraits as
    presentation state: the four GOVT portraits at (160 + 40n, 140) (SPRITES 7; O5:1AF6), the picture
    chosen by the rule CORRESPONDENCE 3 proves for GetCourtStyle 1160:3487 (government 3 alone,
    otherwise government / 2; modern variant after advance 14h) from the core's state read through
    `w16q_read` at use, with T1's rule (advisor n ↔ header 3 + n) in `pdos_prov`; the report frame
    O14:0000/001C and close O14:013B (SCENES-PLAY 7.14: fill, title centred at (160, 2) colour 15 in the
    current font without shadow, realm line, leader and year line, portrait at (278, 2)) against
    OpenReportScreenWithHeader 1018:0000, DrawReportHeader 1018:015D, OpenBlankReportScreen 1188:0000
    and CloseReportScreen 1018:0380; ext-D4a F1: enumerate the report-header SetCivFont(7) sites with
    showfunc (DOS-PROFILE Open 16, OPEN L14, OB4 traced on the report paths), one
    `{7, 7, ra, 1, PDOS_FM_INFERRED, ...}` row per site in `pdos_fontmap.c`, the 2.4 row (functions
    named, no call addresses), the font-row count in `pdos_scene_check.py`; City Status O14:186F
    (background 8, rows from y 32, 8 apart, 20 per page) against ShowCityStatus 1018:208F.
  * Files: `present/dos/pdos_scn_report.h/.c` (new), `pdos_fx.c/.h`, `pdos_fontmap.c`, `pdos_prov.c`,
    `pdos_scene_tab.c`, `pdos_adapt_tab.c`, D6e's class-A module (the fade hook only); DOS-PROFILE 2.4;
    `tests/test_pdos_report.c` (new: frame lines from a synthetic stream, the GOVT name rule for every
    government and both variants, the portrait copy), `tests/test_pdos_scene.c` (the F1 font rows),
    `tests/harness/pdos_scene_check.py`, `ext_timeline.py` (the fade-in and its abandonment),
    `ext_adapt.py`.
  * Adapters and 7.8: I-report close (position irrelevant): a DOS-form close of City Status against the
    Windows form.
  * Record `ext-D7a-record.md`. Depends on the D6 gate.
  * Not in the unit: the other reports (D7b, D7c); the text-box headers that use the portraits (D7g).
* **D7b: the advisors' reports** (about 2 h).
  * Rows: 68 (Military: O14:03AD, O14:061F, backgrounds 1 then 4, Defense Minister portrait, unit icons),
    69 (Intelligence: O14:0D43, dossier O14:1164, INFO buttons; OB2: the DOS drawing of the labels that
    DrawBeveledLabelBox 1030:8C11 draws on Windows, read from the O14 listing), 70 (Attitude: O14:15F4,
    background 9, citizens rows, building icons), 71 (Trade: O14:07F1, background 2, Domestic Advisor
    portrait, two columns, paging), 72 (Science: O14:014B, background 1, Science Advisor portrait, bulb
    bar, icon D4CE[12]) (SCENES-PLAY 7.14). Windows: ShowMilitaryReport 1018:067B, DrawCasualtyReport
    1018:09CC, ShowIntelligenceAdvisor 1018:1221, DrawCivDossier 1018:17DB, ShowAttitudeAdvisor
    1018:1D5B, ShowTradeReport 1018:0BE0, ShowScienceReport 1018:03F0.
  * Implements: the five report bodies on D7a's frame; the sheet and page-2 shapes they use by
    provenance (S10, S13, S17's N column, S18, S19); the DOS background colours where they differ
    (SCENES-PLAY 7.14's note), recorded.
  * Files: `pdos_scn_report.c`, `pdos_prov.c`, `pdos_scene_tab.c`, `pdos_adapt_tab.c`;
    `tests/test_pdos_report.c`, `tests/test_input.c`, `ext_adapt.py`.
  * Adapters and 7.8: I-report INFO buttons, class P (d = ⌈16L/10⌉ for PollMouseClick 1108:0000 at
    1018:1641; DOS-PROFILE 0.6 rule 7): a DOS-point click against the Windows device click.
  * Record `ext-D7b-record.md`. Depends on D7a.
  * Not in the unit: the World reports (D7c).
* **D7c: the World reports and the historian** (about 2 h).
  * Rows: 73 (Wonders of the World: O12:080D, DGROUP:43F0, wonder icons R:0D12:7045), 74 (Top 5 Cities:
    O3:09AC), 75 (Civilization Score: O20:0CA9, icons O20:13F8), 76 (World Map: O12:0000, 4x4 tiles from
    page 2, cities and units in civilization colours; world mode not used, OPEN L2), 77 (Demographics:
    O12:0D6D), 123 (Historian: O12:09E2, background 3, rows with the mini palace R:0238:14A3; the row
    waits at the core's pace, TC). Windows: ShowWondersOfTheWorld 1188:0B3E, ShowTopFiveCities 1080:099B,
    ShowCivilizationScore 1040:1137, ShowWorldMap 1188:013F, ShowDemographicsReport 1188:123A,
    ShowHistorianReport 1188:0DB8.
  * Implements: the six screens (SCENES-PLAY 7.14, 7.15); the World Map's content from the core's world
    state as D6e's small map reads it (B 12.2, B17), drawn in the DOS 4x4 form; the mini palace with
    D6e's drawing (S7); shapes S13, S18, S19 by provenance.
  * Files: `present/dos/pdos_scn_world.h/.c` (new), `pdos_prov.c`, `pdos_scene_tab.c`,
    `pdos_adapt_tab.c`; `tests/test_pdos_report.c` (the 4x4 tile rule, the historian rows),
    `ext_adapt.py`.
  * Adapters and 7.8: I-wait and I-report (class X): one pair on the World Map's key wait.
  * Record `ext-D7c-record.md`. Depends on D7a.
  * Not in the unit: the power graph (D7m); wonders in the city view (D7e).
* **D7d: the city screen** (about 2 h).
  * Rows: 97 (the city screen part: ProcessCity 1030:0000 with dialog 148 at 1030:00F3,
    CityScreenWndProc 1030:9C17), 85 (Auto Production), 90 (INFO), 91 (HAPPY), 92 (MAP), 93 (Close City
    Display: the return of decision 3, D6 ruling 9).
  * Implements: decision 4 over SCENES-PLAY 7.1 (header and title DGROUP:24EC in font 2, resources,
    map panel with D6c's square layers at the city-mode origin, supported units, food box (OPEN L1's
    height rule read if needed), tabs, improvements list with MORE, production box, RENAME, EXIT; the
    panel texture page 2 (208, 100) (S21[0]); building icons R:0D12:7045 (S18, S19); the pollution icon
    (S5); D4CE icons (S10); citizens (S13); units (S17); the G#3 recolours); OB9; S11/S12 (L22) and F15
    (decision 17); the blinking CHANGE button and cursors as TX, 10 frames per phase (R:0D12:4A43,
    TIMING 5.8).
  * Files: `present/dos/pdos_scn_city.h/.c` (new), `pdos_prov.c`, `pdos_fontmap.c` (F15),
    `pdos_scene_tab.c`, `pdos_adapt.c`, `pdos_adapt_tab.c`; `tests/test_pdos_city.c` (new: element
    positions, icon rules, recolours, the OB9 square positions), `tests/test_input.c` (I-city),
    `ext_timeline.py` (the blink), `ext_adapt.py`.
  * Adapters and 7.8: I-city (classes W and C, 1.7.1): DOS tab clicks and DOS keys against the Windows
    keys or clicks of the same function; the close (row 93).
  * Record `ext-D7d-record.md`. Depends on D7a.
  * Not in the unit: dialogs 140 and 137 and the buy box (D7f); the city view (D7e).
* **D7e: the city view, the founding scene and the city animations** (about 2 h).
  * Rows: 88 (Aerial View), 97 (the city view part: ShowCityView 11B0:0000), 109
    (ShowCityFoundedAnimation 11B8:14E5; O22:0EAF), 111 (capture 11B0:1B63; O19:167B), 112 (disorder
    11B0:1FAC; O19:18C1), 113 (celebration 11B0:237C; O19:1AE1).
  * Implements: O19:0000(city, mode) (SCENES-PLAY 7.2): `HILL.PIC` (P16), houses and roads (P19, P20,
    T8, T9), buildings (P18, T10), wonders (P17, T11; decision 9), citizens (P21, T12), the name and year
    in font 6, the core's placements (P20 settled; C.10.2); TX: the new wonder's 60 frames then
    `G#10` DissolveToScreen(1, 10), the mode −3 fade-in O19:0EB9 (90 frames), cycling slot 4
    (O19:0ED8); the exit through R:0238:1BEB (decision 3). The animations (7.3): pictures by the core's
    picture id (P22..P24; OPEN L6 not needed), the core's frames and pace (TC), DAC 0FDh for the
    invaders (E20); the founding scene (7.4): `SETTLERS.PIC` cells over `HILL.PIC` (P25, T15), the
    caption at (160, 4) in font 6, the closing fade O22:10FC (60 frames, TX). Recipe `PDOS_PAL_HILL`
    (E19, E21).
  * Files: `present/dos/pdos_scn_cityview.h/.c` (new), `pdos_fx.c`, `pdos_prov.c`, `pdos_pal.c` (if a
    recipe is missing), `pdos_scene_tab.c`, `pdos_adapt_tab.c`; OFFSETS.md (decision 9);
    `tests/test_pdos_city.c` (cell rules, recipe, dissolve parameters), `ext_timeline.py` (the founding
    fade and the view's fade-in), `ext_adapt.py`.
  * Adapters and 7.8: I-wait (class X): a key abort of the founding scene in both forms.
  * Record `ext-D7e-record.md`. Depends on D7d.
  * Not in the unit: the nuclear explosion (D7n).
* **D7f: the list, entry, production and stack dialogs (R)** (about 2 h).
  * Rows: 12 (dialog 131 Find City, also row 32's screen), 15 (dialog 137 text entry, also row 89 and
    the founding prompt; OPEN L18), 17 (dialog 140 production list, also row 86), 87 (the buy prompt's
    DOS menu box R:1D05:0031), 18 (dialog 141 unit stack).
  * Implements: B 11.2's List (P16 settled: the core's list as a DOS menu box), Text entry (SCENES 10.4;
    the DOS box O23:0000 inferred for dialog 137, anchored on N over the city screen), Production list
    (SCENES-PLAY 7.12: font 2 at (80, 8) over the N city screen through `pdos_reskin_anchor`; the
    header icon and "(HELP AVAILABLE)" of R:1D05:0475; P19 settled: the advisor boxes omitted) and Unit
    stack popup (SCENES-PLAY 7.19: box, rows, highlight); the texts of decision 15.
  * Files: `present/dos/pdos_reskin.c/.h`, `pdos_adapt.c`, `pdos_adapt_tab.c`, `pdos_scene_tab.c`;
    `tests/test_pdos_reskin.c` (list paging, entry cursor, production rows, stack rows),
    `tests/test_input.c`, `ext_adapt.py`.
  * Adapters and 7.8: I-menu for dialogs 131 and 140 through `pdos_r_hit` (help: dialog 140's help
    control if its template has one, else recorded DOS-only); I-text (D5d's rows); I-stack (P26 settled:
    row then OK; row = (y − 5) / 33): a pair for each dialog.
  * Record `ext-D7f-record.md`. Depends on D7d.
  * Not in the unit: the Civilopedia index (D7h reuses the List); text boxes with headers (D7g).
* **D7g: text boxes with headers, notes and event boxes (R)** (about 1.5 to 2 h).
  * Rows: 13 (dialog 135 one-line note, the forms of its three callers), 14 and 22 (dialogs 136 and 145:
    the advisor-portrait header variant DGROUP:2F9E, OPEN L8, and the help line DGROUP:2FBD, if D5b or
    D6f left them), 41 (Revolution's message boxes), 115 (SetGovernment: R:1517:04A1, the menu at
    (100, 64)), 117 (O4:02D3 box, colour 2, outline 10), 118 (O4:03AA, colour 4, outline 12), 126
    (O20:0540: header 4 at (100, 80), header 2 at (100, 64)), 127 (O15:0000: box at (80, 80), header 5),
    128 (O22:0000, 0639, 0AF5 boxes), 137 (a check of D6's placement only).
  * Implements: B 11.2's Text box with header if not built (`g_messagePicture` as the header number;
    SCENES-PLAY 0.2: captions `REPORT_CAPTIONS`, icons DF62[n] for 0..2 (P10), page-2 portraits for 3..6
    from D7a's state (T1)); decision 2's context rows; `KING.TXT` sections D1..D6, SCHISM, ESCHISM
    (3.4); boxes over the map on A at 2x (D6f), over N scenes on N.
  * Files: `pdos_reskin.c/.h`, `pdos_scene_tab.c`, `pdos_adapt_tab.c`, `pdos_profile.c` (the context
    hand-over, if D5e did not add it); `tests/test_pdos_reskin.c`, `ext_adapt.py`, `ext_p0.py` (decision
    12 runs for rows 115, 126..128).
  * Adapters and 7.8: I-menu (the government menu: a DOS row against the Windows choice), I-wait (notes).
  * Record `ext-D7g-record.md`. Depends on D7a and D7f.
  * Not in the unit: the help screen O4:0000 (D5e); New Cabinet (D7i).
  * **The user's report of 2026-10-17 about 15:37 UTC (acceptance items; STATUS "User directions").** With
    screenshots of user build "d7d" and of the DOS game in DOSBox, on the science advisor's research choice
    ("Which discovery should our wise men be pursuing, sire? Pick one...", dialog 145, row 22; SCENES-PLAY
    7.11's choice box at (80, 64)), verbatim: "1. Dialog itself is too wide 2. missing 'Science Advisor:'
    title 3. missing advisor portrait 4. missing green help available text on the lower right corner of the
    dialog box". D7g's boxes with headers therefore: (1) have DOS's width: the text wrapped as DOS wraps it
    beside the portrait (DOS shows "Which discovery should our / wise men be pursuing, sire? / Pick one..."
    with the four advances below), not the Windows dialog's line breaks; (2) the title (DGROUP:2FA6 table,
    "Science Advisor:" for header 6) at (x + 5, y − 4) in colour 15 with its colour-11 line; (3) the GOVT
    portrait (page 2, SCENES-PLAY 0.2) at the box's left inside its own frame; (4) "(HELP AVAILABLE)"
    (DGROUP:2FBD) in colour 10, font 2, at the lower right where the box has help (R:1D05:0475). This applies
    to every advisor header use (the four advisors and the three report headers), not only this box. The
    research choice's place: DOS's (80, 64) if the DOS listing gives it for this call (SCENES-PLAY 7.11),
    else the shared A anchor (F202) recorded. The user: "ALT+H is ok" (it opens the highlighted advance's
    help; that stays as it is). Each of the four is a user check in the record (D7g-n), with the research
    choice named as the place to look.
  * **The user's report of 2026-10-17 about 15:41 UTC (acceptance item; STATUS "User directions").** With a
    DOSBox screenshot of the research choice plus a second box at the lower left ("SCIENCE ADVISOR: I
    RECOMMEND WE DEVELOP POTTERY. SO WE CAN BUILD: -GRANARY", in capitals, under the choice box), verbatim:
    "One more thing, does not recommend next development when Instant Advice is turned on, uploaded
    screenshot belongs to DOS game under Dos Box." The core has this box: CompleteResearch 1170:26EF..2874
    (DGROUP:367F "I recommend we develop ", 3697 " so we can build:", 36A9/36B0 the unit and improvement
    entries, 36B7 the empty case) shows it through ShowTextDialog(text, 8, 168 − 8n) (1170:286F) with
    `g_messagePicture` 6, font 2 and `g_adviceBoxFlag` 1, when option bit 1 (Instant Advice) is on, an advance
    is recommended and `g_difficultyLevel` is 0 (Chieftain); the choice follows at (80, 64) (1170:29EC).
    D7g: (a) draw that box as DOS draws its advice box (place, font, capitals, frame, colours, the "SCIENCE
    ADVISOR:" line, no portrait), staying on screen under the choice box as in DOS, if the core's flow allows
    it read-only (the Windows box may be modal: then the DOS box shows while the core's box is up, and its
    picture is held under the choice box as DOS's screen keeps it, recorded); (b) find DOS's condition in the
    listing and compare it with the core's; a difference (for example DOS showing it above Chieftain) is
    recorded and reported to the orchestrator, not implemented: no core change, no core RNG draw, no
    presentation-side recommendation algorithm without the orchestrator's ruling; (c) check whether the
    production menu's advisor boxes (SCENES-PLAY 7.12, OPEN P19 "omitted: a DOS-only option bit with no core
    state behind it", F136) have a core counterpart after all; report it, D7f keeps P19 unless ruled. The
    user check: with Instant Advice on at Chieftain, the recommendation box appears as in DOS when the
    research choice comes (and the level it needs, stated).
  * **The user's direction of 2026-10-17 about 15:46 UTC and the orchestrator's ruling (supersedes item (a)
    above where they differ).** With a civ64 screenshot at Chieftain (the recommendation alone, in a wide DOS
    box over the map: "I recommend we develop Bronze Working so we can build:?  - Phalanx"), verbatim: "Your
    implementation does indeed display next advance advisor, but in Windows version logic, this should be
    adapted to DOS version logic." Ruling: in the DOS graphics the recommendation follows DOS's flow. DOS
    draws its advice box without a wait (R:1D05:0018 with DGROUP:DB38 set only draws and returns; confirm the
    call in the listing) and the research choice comes at once over it. So the core's recommendation box
    (ShowTextDialog at 1170:286F, `g_adviceBoxFlag` 1) is drawn as DOS's advice box: DOS's place, font,
    capitals and line breaks as DOS words them, the "SCIENCE ADVISOR:" line, no stray glyph (the "?" after
    "build:" is a Windows control character the DOS font lacks). The presentation then closes it at once with
    the input a Windows player would use to dismiss it, and holds its DOS picture under the research choice
    until the choice closes. One user choice ends both, as in DOS. This presentation-posted dismissal is an
    exception, ruled under the user's direction, to the rule that the presentation only translates the user's
    own input. Its limits:
    - the core receives only the Windows dismissal (no core change, no core RNG draw, no timing dependence);
    - it fires only for this box, identified by its call site or flag rather than by text, and only in the
      DOS graphics;
    - the Windows graphics are unchanged;
    - a graphics switch while the box is up behaves sanely and is recorded;
    - an adapter row and a FIDELITY entry quote the direction.
    Tests: the dismissal posted once, not in the Windows graphics, not for other dialog 136 boxes; the held
    picture's lifetime. User check: at Chieftain with Instant Advice on, the recommendation box and the
    research choice appear together as in DOS, and one choice closes both. Items (b) and (c) above stand. If
    the production advisor boxes of (c) do exist in the core, report them with the same DOS-flow reading;
    the orchestrator rules before D7f changes P19.
* **D7h: the Civilopedia** (about 2 h).
  * Rows: 11 (dialog 130: the entry page N, the list use R), 79..84 (the O8:0000 index re-skinned over
    the core's dialog 130 list), 99 (ShowCivilopediaSection 1068:0295, ShowCivilopediaEntry 1020:0000,
    ShowPediaEntry 1068:06AF).
  * Implements: SCENES-PLAY 7.13: the index (title, EXIT, MORE, cursor, rows of 7 pixels) as a List in
    the index style; the entry O8:062A (name font 6, category font 7 by the existing proved font rows;
    pictures by kind from the cell lookups `ICONPG_ADVANCE`, `ICONPG_UNIT`, `ICONPG_TERRAIN` (P13..P15),
    improvements from `CITYPIX2/3` (T19: one cell, copied, no zoom: AnimateTileZoomInRect 1068:1C13's
    zoom is not shown), the unit shape of civilization 1; the −1 case per SPRITES 8); the palettes per
    kind (E11; `pdos_recipe_pedia`, `pdos_recipe_grey253`, `pdos_recipe_terrain_page`); the body per
    decision 10.
  * Files: `present/dos/pdos_scn_pedia.h/.c` (new), `pdos_reskin.c`, `pdos_prov.c`, `pdos_scene_tab.c`,
    `pdos_adapt.c`, `pdos_adapt_tab.c`; `tests/test_pdos_pedia.c` (new: the first-match cell search
    through registry hashes, cell rectangles per kind, the recipe per kind), `tests/test_input.c`,
    `ext_adapt.py`.
  * Adapters and 7.8: I-pedia (class C): an index row and a page key in both forms.
  * Record `ext-D7h-record.md`. Depends on D7f.
  * The user's report of 2026-10-17 about 15:37 UTC (STATUS "User directions"): Alt+H on the science
    advisor's research choice opens the highlighted advance's Civilopedia entry "(albeit in Windows
    graphics)". D7h's entry page covers this path too (SCENES-PLAY 7.11: KING help via O8:062A on request;
    7.12: "the civilopedia entry without pictures" from a menu box's help): name it as a user check.
* **D7i: the newspaper, New Cabinet, discoveries and the quiz** (about 2 h).
  * Rows: 101 (ShowNewspaper 1138:0000; O21:0000), 119 (AnnounceGovernmentChange 10E8:32C1 →
    ShowNewspaper(−2); O5:1BA2), 23 and 24 (dialogs 146, 147; R:0ADE:1584), 26 (dialog 149;
    AskCivilizationQuizQuestion 1178:0022; O16:0000).
  * Implements: the newspaper (SCENES-PLAY 7.7; fonts F1..F5 proved there; the torn edge with
    `pdos_rand` (B11; 0.6 rule 2); decisions 5 and 6); New Cabinet (7.10: the DOS title position, the
    page-2 portraits after the change, the titles DGROUP:2FAC in font 2); the discoveries (7.11: P7,
    `pdos_recipe_discovery` (E18), the ICONPG cell from D7h's lookup, the 180-frame fade-in R:0ADE:198C as
    TX, the sentence words from DOS and the names from the core, the advisor's choice box at its DOS
    anchor); the quiz (7.15: T20, `iconpg1.pal`, the title, `KING.TXT` QUIZ, QUIZ2, CORRECT, INCORRECT,
    the answers menu).
  * Files: `present/dos/pdos_scn_news.h/.c` (new), `pdos_fx.c`, `pdos_compose.c` (decision 5's A
    placement), `pdos_prov.c`, `pdos_scene_tab.c`, `pdos_adapt_tab.c`; `tests/test_pdos_news.c` (new:
    masthead forms, the torn edge's determinism per seed, the cabinet layout, the discovery recipe),
    `ext_timeline.py` (the discovery fade-in), `ext_adapt.py`.
  * Adapters and 7.8: I-wait (newspaper, cabinet, discovery), I-menu (quiz answers): a quiz answer pair.
  * Record `ext-D7i-record.md`. Depends on D7a and D7h.
* **D7j: the palace** (about 1.5 to 2 h).
  * Rows: 104 (OpenPalaceView 1158:08E7; the view R:0403:0796), 124 (RunPalaceImprovement 1158:0000;
    O17:0000).
  * Implements: SCENES-PLAY 7.8: the composer O17:07EC(sad) from the core's palace state (P26, P28..P30,
    T7; decision 8 with P27), the texts and labels, the previews, the final `G#10` DissolveToScreen(1, 20)
    and the sad palace's fade O17:0CB9 (30 frames) as TX; the view's return (decision 3). The composer
    is callable for D7l's sad palace (O2:1356).
  * Files: `present/dos/pdos_scn_palace.h/.c` (new), `pdos_fx.c`, `pdos_prov.c`, `pdos_scene_tab.c`,
    `pdos_adapt_tab.c`; `tests/test_pdos_palace.c` (new: piece rectangles, level and style selection,
    label positions), `ext_timeline.py` (the dissolve), `ext_adapt.py`.
  * Adapters and 7.8: I-palace (class W: WaitForKeyOrClick, then g_clickX/Y at 1158:027A..029D and
    1158:084D): a section chosen by key and by click.
  * Record `ext-D7j-record.md`. Depends on D7a.
* **D7k: diplomacy and leaders** (about 2 h).
  * Rows: 19 (dialog 142: RequestLeaderAudience 1160:20C0, LoadLeaderScreen 1160:2A38,
    HoldDiplomaticAudience 1160:0000), 100 (Diplomacy screens).
  * Implements: SCENES-PLAY 7.9 (O6:16CD, O6:1D2B, O6:21AC, O6:1B33 at the core's idle frames, O6:251D's
    text strip): P11, P12, T2..T5 (T3's cells with OPEN L21; T5 per decision 9), `pdos_recipe_king`
    (E21, E15); the leader font: `LEADER_FONT` (decision 9) and `pdos_fontmap_set_leader_table` keyed by
    `g_playerCivId[n]` instead of `id − 200` (B 10.1, OB8; ext-D4a F2, `ext-D4b3-record.md`); F9, F10
    and F17 from O6:251D (OPEN L23; decision 17).
  * Files: `present/dos/pdos_scn_leader.h/.c` (new), `pdos_fontmap.c/.h`, `pdos_prov.c`,
    `pdos_scene_tab.c`, `pdos_adapt_tab.c`; OFFSETS.md (decision 9); `tests/test_pdos_leader.c` (new:
    face cells with the skipped ones, the body rectangle, the recipe, the font by tribe id),
    `tests/test_pdos_scene.c` (font vectors), `ext_adapt.py`.
  * Adapters and 7.8: I-menu (the audience's choice boxes): one choice in both forms.
  * Record `ext-D7k-record.md`. Depends on D7g (the boxes over the leader screen).
  * Not in the unit: the conquered leader (D7n).
* **D7l: the spaceship screens and the arrival** (about 2 h).
  * Rows: 78 (ShowSpaceshipOfChosenNation 1070:1F58; O18:1527 "Which nation?"), 102 (OpenSpaceshipScreen
    1070:0000, EvaluateAndShowSpaceship 1070:0327, AnimateSpaceshipStarfield 1070:12B5, the part
    placement and LaunchSpaceship 1070:2015), 130 (ShowSpaceshipArrival 11D8:0000; O2:0BD7; decision 7).
  * Implements: SCENES-PLAY 7.16: `DOCKER.PIC` (P35) with the part records DGROUP:4BD0 (T18; OFFSETS
    row; OPEN L15 compared and recorded), the layout and panel, the five cycling slots of O18 as TX
    (2.7), the close without a fade (decision 3), the core's star positions with the DOS star colours by
    class (inferred pairing, recorded), the launch confirmation box at (80, 100); FrameRectDoubleDevice
    1220:114B's outline mapped or not drawn, recorded; the arrival per decision 7 (P32..P34, T17, E12,
    fade O2:122B, slots O2:12B1..1329, the sad palace through D7j's composer).
  * Files: `present/dos/pdos_scn_space.h/.c` (new), `pdos_fx.c`, `pdos_prov.c`, `pdos_scene_tab.c`,
    `pdos_adapt_tab.c`; OFFSETS.md; `tests/test_pdos_space.c` (new: part rectangles through registry
    hashes, the grid, the slot table, the star classes), `ext_timeline.py` (one slot's rate),
    `ext_adapt.py`.
  * Adapters and 7.8: I-space (C for MenuZ, X, P in the arrival at 11D8:07DB): "Which nation?" and the
    launch confirmation in both forms.
  * Record `ext-D7l-record.md`. Depends on D7j.
* **D7m: the end of the game: order, power graph, replay, rating and the Hall of Fame entry** (about 2 h).
  * Rows: 106 (RunEndGameSequence 1088:0B6D; the core's order of the end scenes, DOS-PROFILE 3.1), 42
    (Retire: the end scenes after it), 122 (ShowPowerGraph 1188:07AD; O12:0573), 103 (RunReplayMenu
    1180:0000, ChooseReplayModeAndOpenWindow 1180:017A, PlayReplay 1180:02D3; O9:0000 with DGROUP:3FB0;
    the event lines are the core's text, so O9:080C (OPEN L1) is read only if the DOS line layout needs
    it), 120 (ShowCivilizationRatingRanking 1080:06FF; O3:065D: border tiles S23 chosen by R:0866:260E
    through R:1DC4:005D with `pdos_rand`, the two portraits from D7a's page-2 state, font 7), 129
    (InsertHallOfFameEntry 1080:0595; O3:0513 and O3:00D7(highlight) with D5f's renderer; "Clear"
    omitted, P18 settled), L26 (read R:0238:08A0 to confirm the Hall of Fame palette after the game).
  * Implements: SCENES-PLAY 7.17 for these scenes; the replay map with D7c's 4x4 tiles; the replay's
    pace from the core (TC; PlayReplay's PollMouseClick at 1180:0DC8 is class P).
  * Files: `present/dos/pdos_scn_end.h/.c` (new), `pdos_scn_fame.c`, `pdos_prov.c`, `pdos_scene_tab.c`,
    `pdos_adapt_tab.c`; OFFSETS.md (DGROUP:3FB0); `tests/test_pdos_end.c` (new: the graph frame, the
    ladder, the border-tile determinism per seed, the replay bar), `ext_adapt.py`.
  * Adapters and 7.8: I-menu ("See Replay?"), I-wait: the replay question in both forms.
  * Record `ext-D7m-record.md`. Depends on D7c and D7a.
  * Not in the unit: the conqueror ending (D7n); the arrival (D7l); row 125 (W3, recorded at D7o).
* **D7n: the conqueror ending and the nuclear explosion** (about 1.5 to 2 h).
  * Rows: 114 (ShowConquerorEnding 1180:152F, ShowConqueredCivLeader 1180:17E9; O9:0DDE, O9:0F79), 110
    (AnimateNuclearExplosion 11B8:0C3D; class A; O22:0967).
  * Implements: row 114 per SCENES-PLAY 7.17 (T6, P12, P37 with OPEN P27's odd-width rows per E.6.1,
    E17, E23; the fade-out O9:1079 (30 frames), the fade-in O9:124C (48 frames) and `G#10`
    DissolveToScreen(1, 1Eh) as TX; the waits at the core's pace; the mouth rectangles of OPEN L1 read
    or recorded); row 110 per decision 11 (P8 never substituted: DOS art only in the A element; T16,
    E16).
  * Files: `pdos_scn_end.c`, `pdos_fx.c`, `pdos_prov.c`, D6e's class-A module (row 110's element),
    `pdos_scene_tab.c`; `tests/test_pdos_end.c`, `ext_timeline.py` (O9:1079, O9:124C, the dissolve),
    `ext_adapt.py`.
  * Adapters and 7.8: I-wait for row 114; none for row 110 (`PDOS_AD_NONE`).
  * Record `ext-D7n-record.md`. Depends on D7k and D7m.
* **D7o: the sweep, the reach and the gate** (about 1.5 h).
  * Implements: decision 16's reach check over the V1 outputs; the ledger of every scene row of 1.1..1.5
    (ready with its unit and tests, or W with DOS-PROFILE 4's reason: rows 4, 10, 28, 29, 94, 95, 108,
    125, 131, 141 and D6's W7/W8), row 25 as the union of its openers; decision 17's counterpart
    closures; the counters 0 for every D7 row; decision 13's full runs (`ext_p0.py` V1, V2, V4 with the
    DOS profile and switching; decision 12's G-1 runs; `ext_frames.py`; all D7 `ext_timeline.py` and
    `ext_adapt.py` entries); `pdos_scene_check.py` and the adapter-table check; decision 14's optional
    agent check; then `ext-D7-acceptance.md`.
  * Files: `tests/harness/features.py` (a required-reach option, if needed), `ext_p0.py` (the runs of
    decision 12), `test.cmd` (the representative entries).
  * Record `ext-D7o-record.md`, then `ext-D7-acceptance.md`. Depends on D7a..D7n.

## The gate record `claude/port/docs/ext-D7-acceptance.md`

* The scene ledger: every row of DOS-PROFILE 1.1..1.5 with its class, unit, renderer, adapter, tests and
  result (ready, or W with its DOS-PROFILE 4 reason; any provisional W of decision 7 marked as such);
  the 1.6 omitted DOS-only scenes listed; row 25's openers.
* The counterpart ledger: every row of 2.1..2.7 with its closure (decision 17).
* Methods and results (compiled; headless; Win32-headless; agent-observed; DOS listing (model)): 7.10
  (every FEATURES row reached in the DOS profile, with the scene row ready or W at the reaching event;
  hashes left to D8); 7.7 (each D7 TX effect: durations in ticks against the listing, abandonment,
  switch); 7.8 (EXT_ADAPT_OK, the pairs per adapter); 7.3 (P0_OK with V1, V2, V4 and the DOS profile,
  CheckedNoObs), EXT_G1_OK on both Checked variants; 7.4 (EXT_FRAMES_OK); the counters per row;
  REGISTRY_OK, NODOS_OK, the `pdos_scene_check` and adapter-table counts; the OFFSETS rows added.
* Coverage: rows reached only by unit vectors, by G-1-run V1 replays or by edited saves (decision 12),
  each labelled.
* The agent check's result and screenshots, or why it was not attempted (decision 14).
* The fifteen unit records linked; every deviation, one line each; DOS-oracle comparisons "not run in D7
  (optional; see STATUS)"; Asan deferred; "For the records" gathered from all records (DESIGN 12.7 and
  12.8 "As implemented (D7)", FIDELITY entries for every DOS/Windows difference and every deviation of
  decisions 3..11, DOS-PROFILE text beyond the mirrored rows, FORMATS 6.1's `[DGROUP:640A]` correction,
  new checklist items for D8).
* Open items carried forward: OPEN L1 parts not read, decision 7's outcome, OPEN O7 and O8, the
  pairings left unsure (decisions 10 and 15), costs from one machine.

## Size

About 27 to 29 hours of implementation in fifteen units (D7a..D7f, D7h, D7i and D7k..D7m about 2 h
each; D7g, D7j and D7n 1.5 to 2 h; D7o about 1.5 h), each followed by its eight-step cycle (about an hour
of build and test time at D4's figures, more as D6's suite grows; decision 13), so roughly 42 to 45 hours
end to end.

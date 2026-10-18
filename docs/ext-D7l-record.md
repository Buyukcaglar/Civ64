# Extension phase D7, unit D7l (the spaceship screens and the arrival) - record

Draft for the build slot (BRIEF-d7.md "Units" D7l).  Staged in session E4 (track C, 2026-10-17) in `build/d7l-stage/`,
stacked on D7j's staged copies until D7j's landing (copy-in 12:54:30 UTC, RELEASE_OK 13:34:07 UTC), then rebased onto
the tree after it, and rebased again at its build slot (15:05..15:45 UTC) onto the tree after D6fS-a's landing, the docs
pass docs-e4c and D7d's landing (copy-in 14:57:21 UTC, RELEASE_OK 15:32:56 UTC): the base of every staged file is now
the tree's file ("tree" in `BASE-SHA256.txt`; section "Rebase notes").  Private builds and runs in
`build/d7l-stage/obj/` only: an overlay `obj/src` = the tree + D7l's staged files (`obj/mkoverlay.py`), built with the
tree's build.cmd and flags (`obj/b.cmd`, `--nogen`), cc.cmd's stricter checks per file (`obj/cc.cmd`), the unit
programs (`obj/unit.py`) and the harness runs from the overlay's binaries with every output under `obj/`; the tree's
build/gamedata, dosdata and cache read only.

## Result

With the DOS graphics, the spaceship screen shows as the DOS game's (O18:0259): World > Spaceships ("Which nation?" as
the core's re-skinned MenuZ box, then the chosen nation's ship) and the screens of the turn (a part placed, the launch)
draw on the N frame: page 0 in colour 0 (DOCKER's palette makes it a dark blue), the title bar and the right panel in
the civilization's DOS colour, DOCKER.PIC's part shapes on DOS's 16-pixel grid, an unconnected part's frame in colour
12, the mass shape, the stats at the core's (= DOS's) positions, the LAUNCH label at (256, 190) when the core offers its
Launch button, the core's stars in DOS's colours, and DOCKER's palette with its five cycling slots.  'l' and a click in
the LAUNCH corner ask the launch question as in DOS; any other key or button ends the screen; the map returns with the
fade from black.  The arrival (row 130) stays "not ready" (ruling 7: the time-boxed reading of O2:0BD7 did not establish
its animation; open items below).  The Windows graphics are unchanged.

## Status

READY_TO_BUILD, rebased at the build slot onto the tree after D7d's landing (the private build, units and runs
repeated there, "Results"; PDOS_OWNER_MAX 8 -> 9 for the profile's eighth owner, "Rebase notes").  Built:
rows 102 (EvaluateAndShowSpaceship, O18:0259) and 78 (World > Spaceships, its opener) with dialog 148's row 25 made
ready and a ProcessCity row 97 held ready while the screen is open; the shadow owner "space" (the window and the port at
the logical resolution; the DrawTile bitmaps declined); the replay's place hook chained after the report's (civ colour,
the frame at DOS's grid); the part and mass shapes (T18, DOCKER.PIC records DGROUP:4BD0); the stars; the LAUNCH label;
the five slots as TX on the screen's own timeline; the end with the exit kind 1B44; pdos_prov's T18 rule (PROF row
118); the adapter rows I-space (DOS's launch actions and the other keys and buttons as clicks); the registry tables
SPACE_PARTS and SPACE_LAUNCH.  Not built: row 130 (the arrival, O2:0BD7; ruling 7), the launch's black screen O18:15C3
(the core shows its text box; difference 2).

## What was built

### The screen O18:0259 over the core's (row 102; SCENES-PLAY 7.16)

| Core (Windows) | DOS (listing) | The renderer |
|---|---|---|
| OpenSpaceshipScreen 1070:0000: GR_DialogOpen(0x94) 1070:0047 (dialog 148), GR_PortOpen 1070:00C7 | O18:0000: the pointer hidden, page 0 black (O18:0025..0038), DOCKER.PIC to page 1 with its palette (R:1FA1:04C0, M0 0..255), the ten shapes cut (O18:0055..0089), 20 stars set up, the slots (O18:00D0..0166) | at GR_DialogOpen's return with dialog 148 created: the play palette with DOCKER's 256 entries over it, page 0 black, the stars' visible flags cleared, rows 102, 78 and 25 ready (the N frame), the five slots set up from that DAC and started (`pdos_tl_cycle_setup`, `_start`) on the screen's own timeline (PDOS_SEQ_FX_FADE, frame 0 at the instant; TX); the window and the port's bitmap (g_spaceshipPort 1290:00D2 + 1Ah) claimed by "space" at the logical resolution |
| EvaluateAndShowSpaceship 1070:0327: FillRectLogical (0, 0, 320, 200) and the title bar (0, 0, 320, 8) in civ + 10h, the title, the parts (DrawTile 1070:0559 at (24 col - 24, 24 row + 20)), the frames (FrameRectDoubleDevice 1070:0685), the mass (DrawTile 1070:0711 at (E4h, 8Ch)), the panel (F0h, 8, 50h, C0h) and two lines in civ + 10h, the stats | O18:0259: black, the bar in [1946h + 2 civ] (O18:02A6), the title centred at (160, 1) colour 0, G#32 of shape k at (16 col - 16, 16 row + 8) (O18:038F..03AF), R:1D05:0A05(16 col - 16, 16 row + 8, 16 w - 1, 16 h - 1, 12) for an unconnected part (O18:0480..04A6), shape 5 at (98h, 58h) for a mass of 80 or more (O18:051C..052C), the panel and lines (O18:053A..058A), the stats at x F2h, y 16..128 | the replay (D6b) draws the logical primitives in DOS form (their positions are DOS's); the place hook gives the bar, the panel and the lines [1946h + 2 civ] (DGROUP:1946, CIV_MAIN_COLOUR); a part's DrawTile draws DOS shape k at its cell (the core's tile k is g_spaceshipPartTiles[k] 1420:5246), its bitmaps declined and its copies into the port dropped; the frame is DOS's outline at the cell (the replay's frame not drawn); the mass's DrawTile is shape 5 at (152, 88) |
| CreateWindow("Launch", 999) 1070:0D6F (the human's ship, displayTicks < 0, the launch allowed) | O18:0A94..0AD2: "LAUNCH" (DGROUP:4D8E) at (256, 190) colour 0, R:1D05:0A05(242, 188, 76, 9, 0) under the same conditions | the label and the box drawn into the port's shadow at the button's creation; the core's erase of the button's place after the wait (FillRect 1070:0EE7) dropped |
| AnimateSpaceshipStarfield 1070:12B5, CopyPortToWindow 1070:0DBD (and 1070:0E88 in the wait after a launch) | O18:0C49: 20 stars by class i mod 4 (+2 colour 7, +1 colour 3, +1 on odd frames colour 8), drawn on black pixels only, the visible ones put back to 0 | at the copy's entry: the stars drawn before put back to 0, each of the core's 20 at (L(x), L(y)) (L(d) = floor((10 d + 9) / 16): the core's 384 x 320 field to DOS's 240 x 200) in DOS's colour of its class where that pixel is 0 (the class pairing by i mod 4 is inferred); the core's SetPortPixelIndex 1070:124E dropped; then the copy shows the port on page 0 |
| the wait 1070:0E38..0E59 (PumpSpaceshipWindowMessage) | O18:0AF3..0B4C: kbhit or a button | I-space (below) |
| CloseSpaceshipScreen (the window destroyed) | O18:016D: the slots stopped (O18:018A..01A1), the map palette back, R:0238:1B44 | the slots stopped at the window's destruction, the rows not ready (the A frame), row 97 back as it was, the exit kind 1B44 (decision 3: the fade from black only) |

World > Spaceships (row 78): ShowSpaceshipOfChosenNation 1070:1F58 asks "Which nation?" with a MenuZ (the re-skinned
box, I-menu; DOS O18:1527's R:0238:001E menu at (100, 80)) and shows the chosen nation's ship; the step `space` names
row 78 as its opener.  The turn's screens (HumanPlaceSpaceshipPart 1070:1952, LaunchSpaceship 1070:2015) run inside
ProcessCity 1030:0000, so row 97 is on the scene stack below: it is held ready while the screen is open, so the core's
"Type?" and "No further" boxes between two EvaluateAndShowSpaceship calls show over the spaceship (O18:0FDE..1036,
1223..1275).

### The stars (TC; inferred pairing)

The core moves its stars itself (+6, +5, +4 on odd, +3 on odd frames, wrap at 180h; its own RandomBelow for new rows):
the renderer never draws a star of its own (P0: no random number) and maps each core star to DOS's point and colour.
The core moves them once per showing (1070:0DA4, before the first copy) and in its wait only while that civilization's
ship has been launched (1070:0E59..0E6F: `g_spaceshipFlags & (1 << civ)`), while DOS moves them every frame of its wait
(O18:0C49 in the loop O18:0AF3..0B4C).  So on the screen of a ship not yet launched the DOS stars stand still where DOS
lets them drift (seen in the private space run: `star_frames 1` over the 3-second wait); a visible difference from DOS
that follows from the TC rule (FIDELITY candidate, open item for D7's gate: a presentation-only star clock would need
the core's star state to advance without the core).

### The adapter rows I-space (C.12.7; ruling 4)

While the screen shows the scene is PDOS_AS_SPACE (0x20000000) with the spaceship window (x_hwnd) and, in the core's
wait for a key or a click, its Launch button (PdosAdaptSc.l_hwnd, new): the core READY in that wait (from its first copy
of the port, 1070:0DBD, with displayTicks < 0, to EvaluateAndShowSpaceship's return or LaunchSpaceship), else WAIT.  DOS
ends the screen at any key or either button and, with the LAUNCH label, asks the launch question at 'l' (6Ch only) or a
button at x > F2h, y >= BEh (O18:0B6C..0B83); the core ends its wait at a character (WM_CHAR) or a left click in the
window and asks the question at its Launch button (WM_COMMAND 999).  Rows: I-space/mod (consumed), launch (a click on
the Launch button; decided by `pdos_space_launch_key` / `pdos_space_launch_hit`, the screen's own sub-decision, and
marked with the existing PDOS_AA_HOTKEY, which the screen sets for nothing else: it has no box), end (any other key or
button: a click in the window; a key without a character, an Alt key and the right button reach no end in the core, so
all become the click), busy (WAIT: consumed; the core flushes input there).  The launch question itself is the core's
ShowTextDialog box at (80, 100) (DOS R:0238:001E(.., 50h, 64h)), re-skinned (I-menu).  No row shows a Go Back or Cancel
choice: DOS has none.

### T18 (PROF 2.3; pdos_prov; OPEN L15 compared)

`pdos_prov_t18`: g_spaceshipPartTiles[k], cut by OpenSpaceshipScreen from picture 5581 (15CDh, P35) at
g_spaceshipPartSprites[k] 1420:12AA (device (0, top) - (width, top + height)), map to DOS record k's rectangle in
DOCKER.PIC (row 118).  OPEN L15: the Windows records (NE segment 133) and DOS's DGROUP:4BD0 have the same ten masses in
the same order; the Windows cuts are 1.5 times DOS's (24 or 48 against 16 or 32), stacked from y 0 in one column where
DOS's lie over the picture; the pairing is by index.

### Registry tables (OFFSETS.md; DOS file, DOS listing)

SPACE_PARTS DGROUP:4BD0 (260 bytes: ten 26-byte records, the name, the mass at +16 and the rectangle x, y, w, h at
+18..+25; readers O18:005D..0069, 04F7, 1241, 13E3, 142F, 14AE, 14DE, 150E, 1515), SPACE_LAUNCH DGROUP:4D8E (one
string, max 8; O18:0AB3); no writer.

### The arrival (row 130; decision 7, ruling 7): not established

The time-boxed reading of O2:0BD7 (2,387 bytes): established are PLANET2.PIC's 24 shapes cut at 50-pixel steps
(O2:0C0C..0C54, G#2 49 x 49), PLANET1.PIC with its palette (O2:0C8B), its copies to pages 0 and 2 (G#20, O2:0CB6,
0CDC), the arrival text built from the civilization's and the year's strings (O2:0D52..0E3E), SPACEST.PIC with six
cycling slots (O2:12A1..1329: R:0000:0382 six times) and the sad palace's call (O2:1356).  Not established within the
time box: the animation loop O2:0ED8..119F (the ship's G#32 positions per frame, the panning copies, the text's
printing R:0182:00B3) and its pace (the tick waits R:0000:033A at O2:10A9..10C6).  Row 130 stays "not ready" (the A
frame); open items for D7's gate: row 130, P32..P34, T17 and E12's arrival part.

### Evidence labels

* DOS listing: every O18, O2 and R: address above (build/dos/disasm/ovl18.lst, ovl02.lst, read only); DOS file:
  DOCKER.PIC and the registry's tables; the Windows side from the port's reconstruction (core/seg015_1070_*.c).
* Inferred: the star class pairing by i mod 4; the label's font (font 1, P14, OB4: PDOS_R_FONT).
* DOS oracle: none (no DOS program run).

## Files

Changed (bases in `BASE-SHA256.txt`, written at the rebase): `present/dos/pdos_adapt.c/.h`, `pdos_adapt_tab.c`,
`pdos_profile.c`, `pdos_prov.c/.h`, `pdos_registry.c/.h` (generated by `registry.py gen` from OFFSETS.md), `pdos_seq.c`,
`pdos_shadow.h` (PDOS_OWNER_MAX 8 -> 9, at the build slot),
`gen/dos/adapters.py`, `gen/dos/registry.py` (OBSERVER_FILES += `pdos_scn_space.c`), `docs/DOS-PROFILE.md` (rows 78,
102, P35, T18; 1.7.2 regenerated), `docs/dos/OFFSETS.md`, `tests/test_input.c`, `tests/dos-decoded.txt` (registry
goldens), `tests/headless/harness.c` (the `space` diag line), `tests/harness/ext_timeline.py` (the space run),
`tests/harness/ext_adapt.py` (the D7l pair).  New: `present/dos/pdos_scn_space.c/.h`, `tests/test_pdos_space.c`, this
record.  Unchanged, though the brief lists them: `present/dos/pdos_fx.c` (the exit kind exists), `pdos_scene_tab.c`
(rows 78, 102 and 130 exist).  build.cmd and test.cmd unchanged (new files are found by their globs).

## Tests

* **`tests/test_pdos_space.c`** (new): the listing's rules (the records through the registry's table, the grids, the
  sizes in cells, L, the star colours, the civ colour, the slots, the launch actions); the drawing helpers (a shape with
  colour 0 transparent and clipped, the frame, the LAUNCH label); T18; a screen from a synthetic stream through the
  scene and shadow engines (the open with the rows and the palette, the slots set up, started and cycling, the claims
  at the logical resolution, parts and the mass at DOS's grid, the DrawTile bitmaps declined, the place hook, the
  stars and their erasure, a star over a part not drawn, the copy to page 0, the Launch button's label, the wait and
  the erase dropped, a timed showing without a wait, the end with the slots stopped and the exit kind); the opener's
  row 78, row 97 held, an unreadable state.
* **`tests/test_input.c`**: the I-space vectors (mod, launch by 'l' and by a press in the corner, end by a key, a press
  outside the corner and the right button, busy) and `adapt_space` ('l' and 'L', F1, the corner's first pixel, the
  right button there, a press above the corner on the Windows button's place, no Launch button, no window, outside the
  wait); the row count + 4.
* **`tests/harness/ext_timeline.py`**, the space run (base group): the open's step with row 78, the five slots' rates
  and their setup and start at the open's instant, the end by I-space/end with the slots stopped and the return's fade,
  the N frame.
* **`tests/harness/ext_adapt.py`**, the D7l pair (`d7l-space-dos` against `d7l-space-win`): World > Spaceships from
  the edited save, Return on "Which nation?", Space on the screen decided by I-space/end (one produced click in the
  spaceship window) against the Windows form clicking there at the Space's instant: the core outputs equal; the
  open (row 78) and the end (exit kind 1) with the return's fade, the N frame, presentation-diag's `space` line.

## Results (private, `build/d7l-stage/obj/`)

**At the build slot** (2026-10-17, 15:30..15:45 UTC), after the rebase onto the tree after D7d's landing, on the
overlay `obj/src` = the tree (copied after D7d's RELEASE_OK) + D7l's 23 staged files; `obj/mkbase.py check
tree` BASES_OK:

* **Build** Checked (clean object cache) BUILD_OK, no warning, portable sources 302 (the tree's 301 +
  `pdos_scn_space.c`).
* **Unit** Checked: all 58 programs (test_ne aside) pass.  Against D7d's cycle (`build/d7d-2-test-checked.log`):
  test_pdos_space new 73; test_input 559 -> 579; test_dos 23250 -> 23252; every other count equal (test_pdos_city 78,
  test_pdos_profile 59, test_pdos_shadow 181 among them).  The first run, before PDOS_OWNER_MAX 9, failed three checks
  of test_pdos_profile ("an owner that claims window 5" and the two after it): with D7d's "city" and D7l's "space" the
  profile registers eight owners, and the test's own ninth was refused (section "Rebase notes").
* **Checks** on the overlay: `adapters.py gen` and `registry.py gen` / `goldens` (`--dosdata`, `--disasm` of the
  tree's build) leave the merged DOS-PROFILE.md, `pdos_registry.c/.h` and `tests/dos-decoded.txt` (1382 lines)
  unchanged; `adapters.py check` ADAPT_OK rows 138 steps 25; `registry.py check` REGISTRY_OK, 0 failures, 397 `ok`
  lines (D7d's 378 + 19); `obs_lint.py` OBS_LINT_OK files 136 probes 203 callsites 101; `obs_tables.py --check`
  (`obj/obstab.py`) OBS_TABLES_OK probes 203 sites 101; `pdos_scene_check.py` PASS 1084 checks, 141 scene rows.
* **ext_adapt, the d7l pair** (`obj/runadapt.py`): RUNADAPT checks 5 failed 0, as before the slot (I-space/end, one
  click at (320, 240), the pair equal with coreinput 15 and frames 556, `space` and `space_end` at 31,001,100 and
  34,001,100 us, the fade to frame 30, the N frame 52 shows and the A frame 73, the `space` line unchanged).
* **"Which nation?" against D6fS-a's DOS sizes** (`obj/explore.py space1 dos 30900 ...` with `--dump-presented`, the
  route stopped before the Return; the dumps deleted after reading): the box is now as tall as its rows: the title and
  the seven nations at 8 logical pixels each, its frame from logical y 69.5 to 140.5 (71 pixels: 64 for the eight rows
  and the frame's own margins), the last row's text ending about 3 pixels above the bottom edge; no empty row as
  before D6fS-a's landing.  The highlight on the first row is the menu's own (I-menu), not D7l's.
* Not repeated at the slot: CheckedNoObs and Release (the cycle builds them), cc.cmd, ext_timeline, ext_p0 and the
  other pairs (the cycle runs them).

**Before the slot.** Run in session E4 (2026-10-17, 13:38..14:45 UTC) after the rebase onto the tree after D7j's
landing, on the overlay `obj/src` = that tree (D7j's overlay `build/d7j-stage/obj/src`, written at 12:53 UTC; its D7j
files equal `build/d7j-prep/landed.sha256`, the record aside) + D7l's staged files; `obj/mkbase.py check` BASES_OK
against it:

* **Builds** (`obj/b.cmd`, the tree's build.cmd and flags with `--nogen`): Checked, CheckedNoObs and Release BUILD_OK
  (portable sources 301: the tree's 300 + `pdos_scn_space.c`).
* **cc.cmd** (c11 and c17 /W4 /WX and the clang C99 parse, each variant) on `pdos_scn_space.c`, `pdos_adapt.c`,
  `pdos_adapt_tab.c`, `pdos_profile.c`, `pdos_prov.c`, `pdos_registry.c`, `pdos_seq.c`, `test_pdos_space.c`,
  `harness.c`: CC_OK in Checked, CheckedNoObs and Release.  `test_input.c`: its c11 and c17 compiles pass; the clang
  parse reports only the base's own missing `square_only` initializer (line 176, as D6f, D7a, D7b and D7j recorded).
* **Unit** (`obj/unit.py`, the tree's build/gamedata read only): all 57 programs (test_ne aside) pass in Checked,
  CheckedNoObs and Release.  Against D7j's cycle (`build/d7j-2-test-checked.log`): test_pdos_space new 73 (each
  variant); test_input 529 -> 549 (CheckedNoObs 473 -> 493); test_dos 23243 -> 23245 (the two registry goldens); every
  other count equal (test_pdos_palace 118, test_pdos_play 78, test_pdos_report 229 among them).
* **Checks** on the overlay: `registry.py gen` leaves the staged `pdos_registry.c/.h` unchanged (56 tables);
  `registry.py check` (`--dosdata`, `--disasm` of the tree's build, read only) REGISTRY_OK, 0 failures, 359 `ok` lines
  (the tree's 340: SPACE_PARTS, SPACE_LAUNCH, their readers, the include rule of `pdos_scn_space.c` and `.h`);
  `obs_lint.py` OBS_LINT_OK files 134 probes 203 callsites 101; `obs_tables.py --check` (`obj/obstab.py`) OBS_TABLES_OK
  probes 203 sites 101; `pdos_scene_check.py` PASS 1084 checks, 141 scene rows, 10 font rows; `adapters.py check`
  ADAPT_OK rows 134 steps 25 (`adapters.py gen` leaves the staged DOS-PROFILE.md unchanged); `nodos.py check --root
  obj/src` (the tree's dosdata and gamedata) NODOS_OK in Checked (1028 files) and Release (1027 files), 0 hits.
* **ext_timeline** (`obj/runtl.py`: the staged file in the overlay, the private Checked harness, outputs under
  `obj/tl`): the space run ends without a fault; `space` (O18:0000, row 78) at 31,001,100 us with the five slots'
  rates 30, 11, 20, 8, 150 and their setup and start at that instant; the Space decided by I-space/end, `space_end`
  (O18:016D, kind 1) at 34,001,100 us with the five slots stopped, the return from black there and its fade's end at
  frame 30; the N frame after the open's instant to the end (52 shows), the A frame after it (73 shows).  A first run
  failed the N-frame check on one tick at the open's own instant (31,001,100 us), which still showed the A frame
  before the scene's view (`view 31001100 320x200` follows it): the check now starts after the open's instant (both
  in ext_timeline and in the d7l pair).
* **ext_adapt, the d7l pair** (`obj/runadapt.py`, the staged ext_adapt.py with the private Checked harness): the Space
  decided by I-space/end, one click produced at (320, 240) (the spaceship window's I5 point); the DOS-form run equals
  its Windows-form pair (coreinput 15 lines, frames 556; exit 0, 0); timeline.log `space` (row 78) at 31,001,100 us,
  `space_end` (kind 1) at 34,001,100 us, the fade to frame 30; the N frame (52 shows) and the A frame after (73); the
  `space` line opens 1 ends 1 star_frames 1 stars 20 copies 1 absorbed 50, labels 0, erases 0, holds97 0, pic_missing
  0, unread 0.  **Every pair** (`runadapt.py ... all`): EXT_ADAPT_OK checks 213 (the tree's 208 + the d7l pair's 5).
* **ext_p0** (`obj/runp0.py`: the overlay's runner with scenarios.SAVE at the tree's save, `--exe` the private Checked
  harness, `--root obj/p0root`, `--only spaceship,arrival`): P0_OK checks 32 (V0..V8s; V1, V2 and V4d equal V0, the
  gate rows' counters 0); the `space` line of `spaceship` (V1, V2, V4d): opens 1 ends 1 star_frames 1 stars 20 copies
  1 absorbed 50 unread 0; `arrival` never opens the screen (row 130, not ready, shows the core's picture); V4d's shows
  with the layer: spaceship 61, arrival 236.
* **The screen as drawn** (private: `obj/explore.py space1 dos 33800 ...` with `--dump-presented`, the route stopped
  before the Space; the dumps deleted after reading): the N frame's last dump (320 x 200, 8-bit) has colour 0 on 46,788
  pixels with DOCKER's entry 0, a dark blue (0, 0, 49), so DOS's "black" page shows dark blue as in DOS; the title bar
  and the panel in the Roman colour 15 with the title and the stats; 20 stars in colours 7, 3 and 8.  The panel's
  "Prob. of Success" (O18:09BC at x F2h) runs past the right edge in font 1, the font in effect (90 pixels from x 242;
  font 2 would fit with 77): the same in DOS if draft B's OB4 (the font in effect is 1) holds, so the observation bears
  on OB4 (open item for D7's gate).  The "Which nation?" box (the re-skinned MenuZ, I-menu, before D6fSa's landing)
  lists the seven nations (Roman chosen, the others disabled) and is taller than its rows (the re-skin's own geometry,
  not D7l's); one tick after the Return shows the box emptied before the screen opens.

## Deviations from the brief

1. **The arrival (row 130) not implemented** (ruling 7): the time-boxed reading did not establish the animation; the
   row stays "not ready" and its open items go to D7's gate.
2. **The launch's black screen O18:15C3** ("<civ> LAUNCH space ship!", the arrival estimate, centred, colour 15) is not
   drawn: the core shows its own text box there (LaunchSpaceship 1070:2015's ShowTextDialog), re-skinned as an R box.
3. **Input translated into clicks** (I-space): every key ends the DOS screen, while the core ends only at a character
   or a left click; a key or button therefore becomes a click in the spaceship window, and DOS's launch actions a click
   on the Launch button.  A timed showing (another nation's ship, displayTicks > 0) is not cut short by a key as in DOS
   (the core's DelayTimerTicks reads none).
4. **No new action bit; a new PdosAdaptSc field `l_hwnd`** (the core's Launch button).  The staged draft's
   PDOS_AA_LAUNCH 0x80000000 clashed with D6fS's allocation (D6fSb's PDOS_AA_DEAD, the orchestrator's message of
   2026-10-17 13:05 UTC); as the orchestrator asked first, the launch actions moved behind an existing action:
   pdos_scn_space decides them (`pdos_space_launch_key`: 'l' only; `pdos_space_launch_hit`: x > F2h, y >= BEh) and
   `key_act` / `button_down` mark them with PDOS_AA_HOTKEY, which is otherwise set only with a box's hotkey search
   (the spaceship screen has none); `row_k` then clicks the Launch button for I-space/launch.  PDOS_AA and PDOS_AS
   stay 32 bits; PDOS_AS_SPACE 0x20000000 is D7l's allocation.  Accepted by the orchestrator (2026-10-17, after D7j's
   landing).
5. `pdos_fx.c` and `pdos_scene_tab.c` unchanged although listed.
6. **The stars move at the core's pace** (section "The stars"): on the screen of a ship not yet launched they stand
   still (the core moves them once per showing), where DOS moves them every frame of its wait.  Not a choice of this
   unit's: the TC rule (the core's positions, no presentation random numbers) leaves no DOS star clock; for D7's gate.

## What the user checks

On the coordinator's user build (D7l landed), in play with the DOS graphics.  No Go Back or Cancel row appears:

* **D7l-1** World > Spaceships (when a civilization has started a spaceship): "Which nation?" as a DOS menu box (as
  tall as its rows), then
  the chosen ship as the DOS screen: dark blue with small stars in three colours (standing still until that ship is
  launched, moving after it, as the Windows screen's stars do; they never cover the parts or the panel), the title
  bar at the top and the panel at the right in the
  civilization's colour, the parts in DOS art on the 16-pixel grid, the statistics in the panel, colours cycling in
  the parts.  Any key or click returns to the map with the fade from black.
* **D7l-2** Building spaceship parts in your capital: after a part is built, the DOS screen with the new part in place
  (unconnected parts framed in red), "LAUNCH" in a box at the lower right once the ship can fly; 'l' or a click on
  LAUNCH asks the launch question in a DOS box; Yes launches (the core's text box follows), No returns.
* **D7l-3** The same with the Windows graphics: the Windows spaceship window, unchanged.

Not part of this check: the arrival (still the Windows picture), switching the graphics while the screen shows.

## For the records

* **DESIGN 12.x "As implemented (D7l; areas B and C)":** the spaceship renderer (O18:0259 drawn over the core's
  EvaluateAndShowSpaceship 1070:0327 from its probes): rows 102 and 78 (the opener), 25 ready and 97 held while the
  screen is open; the shadow owner "space" (the window and the port at the logical resolution; the part DrawTile
  bitmaps declined); the replay's place hook chained after the report's (the civilization's DOS colour, the frame at
  DOS's grid); T18 (row 118, pdos_prov); the stars mapped from the core's (L(d) = floor((10 d + 9) / 16), DOS's colour
  of the class i mod 4, on colour-0 pixels only); the LAUNCH label at the core's Launch button; the five slots as TX on
  the screen's own timeline (PDOS_SEQ_FX_FADE); the end with the exit kind 1B44; I-space (keys and buttons as clicks,
  the launch actions behind PDOS_AA_HOTKEY, the new PdosAdaptSc.l_hwnd); the registry tables SPACE_PARTS and
  SPACE_LAUNCH; the `space` diag line; the shadow owners now 8 of PDOS_OWNER_MAX 9 (raised from 8 at the
  build slot: test_pdos_profile registers one owner after the profile's).
* **FIDELITY** (new entries, numbers to be assigned): F-new-1: the stars move at the core's pace, so on the screen of
  a ship not yet launched they stand still where DOS moves them every frame of its wait (TC; deviation 6); F-new-2:
  every key or button becomes a click in the spaceship window (the core ends its wait only at a character or a left
  click), DOS's launch actions a click on the core's Launch button, and a timed showing of another nation's ship is not
  cut short by a key (deviation 3); F-new-3: the launch's black screen O18:15C3 is not drawn, the core's text box shows
  there, re-skinned (deviation 2); F-new-4: the star classes paired with DOS's by i mod 4 (inferred); F-new-5: the
  panel's "Prob. of Success" runs past the right edge in font 1, the font in effect (bears on OB4); F-new-6: the arrival
  (row 130) is not implemented and shows the core's picture on the A frame (deviation 1).
* **DOS-PROFILE.md prose:** rows 78 and 102, P35 and T18 as staged ("as implemented in D7l"); 1.7.2 as generated.
* **RUNNING.md:** presentation-diag.log's `space` line (opens, ends, parts, masses, frames, tile_unknown, labels,
  erases, star_frames, stars, stars_hidden, copies, holds97, absorbed, pic_missing, unread); timeline.log's steps
  `space`, `space_launch_label`, `space_end` and the slots' `space_slot` steps with their setups and starts
  (PDOS_SEQ_FX_FADE); ext_adapt's d7l-space-dos and d7l-space-win runs; ext_timeline's space run; test_pdos_space.
* **FEATURES.md:** the DOS spaceship screen in play (World > Spaceships, the screens of a turn: a part placed, the
  launch) (D7l), with the runners above; the arrival unchanged.
* **STATUS.md:** D7l landed (rows 102 and 78; T18 row 118); row 130 (the arrival) not ready, its open items for D7's
  gate; the shadow owners 8 of `PDOS_OWNER_MAX` 9.
* **manual-checklist-ext.md:** new items D7l-1..D7l-3 (above).
* User direction 2026-10-16 (no added Go Back / Cancel rows) and 2026-10-17 (boxes as tall as their content, no
  highlight where DOS draws none, 2x): the spaceship screen shows no Go Back or Cancel row (DOS and the core have
  none); "Which nation?" and the launch question are the re-skinned core boxes (I-menu) at D6fS-a's DOS sizes;
  everything on the N canvas at 2x.  Report items: none.
* Not edited by this unit: DESIGN.md, FIDELITY.md, STATUS.md, RUNNING.md, FEATURES.md, DOS-PROFILE.md outside rows 78
  and 102, P35, T18 and the generated section 1.7.2, manual-checklist-ext.md, the D1 drafts and the D0 documents.

## Expected changes at the build slot

Relative to the tree after D7d's landing (`build/d7d-2-test-checked.log`, ALL_GREEN 15:29:05 UTC; outputs snapshot by
`build/d7l-prep/land.py --write`):

* **Unit** (Checked and Release): a new program test_pdos_space (73); test_input 559 -> 579, test_dos 23250 -> 23252
  ("decoded content" 1380 -> 1382 lines); CheckedNoObs test_input + 20 and test_pdos_space 73; every other count
  unchanged (test_pdos_profile 59 and test_pdos_shadow 181 with PDOS_OWNER_MAX 9).  Portable sources 301 -> 302;
  obs_lint files 134 -> 136; probes 203 and call sites 101 unchanged.
* `registry-check.txt`: REGISTRY_OK, 0 failures, `ok` lines 378 -> 397.  `adapters-check.txt`: ADAPT_OK rows 134 ->
  138, steps 25.  `pdos-scene-check.txt` (PASS 1084, 141 scene rows) and `obs-tables.txt`: unchanged (rows 78, 102
  and 130 exist; row 130 stays not ready).  `nodos.txt`: NODOS_OK, files about +4 (the two sources, the test, the
  record).
* `ext-adapt.txt`: EXT_ADAPT_OK checks 242 -> 247; two more runs (d7l-space-dos, d7l-space-win; 38 s of virtual time
  each).
* `ext-timeline.txt` (base group): EXT_TIMELINE_OK with 4 more PASS lines (space: written, the open with the slots, the
  end, the N frame; 49 -> 53) and the runs line naming space; one more run (38 s).  No golden file changes.
* ext_p0: P0_OK checks 476 unchanged; `spaceship`'s `pdos_rows` without counts on rows 102, 78 and 25; V4d's
  informational show counts of `spaceship` may change (the N frame while the screen shows).  ext-replay: its pass
  conditions hold; informational V1 counters of the runs that show the screen may change (the replay draws the
  screen's primitives on the "space" shadows).
* presentation-diag.log (harness): a new `space ...` line after the city line.  timeline.log: the `space` steps, the
  slots' steps and the return's in runs that open the screen.
* Core outputs, G-1 fields and `ext_g1.py check`: unchanged (EXT_G1_OK runs 77; presentation only; the d7l pair and
  ext_p0 V1/V2/V4d equal their references).

## Rebase notes

* **Stacked on D7j's staged copies until D7j's landing** (copy-in 12:54:30 UTC, ALL_GREEN 13:29:28 UTC, RELEASE_OK
  13:34:07 UTC; `build/d7j-prep/landed.sha256`).  Rebased in E4 (13:36..13:40 UTC): every staged file was compared with
  the tree after D7j's landing as D7j's overlay holds it (the live tree already had D6fSa's copy-in of 13:36:26 UTC).
  Each copy adds only D7l's lines, except `docs/DOS-PROFILE.md`, staged from D7j's copy before the docs pass docs-e4b:
  merged three ways (`git merge-file -p`, files only; base: D7j's pre-docs copy `build/d7j-stage/obj/pre-docs/`,
  theirs: the landed file, mine: D7l's copy kept in `obj/pre-d7j/`): one conflict where rows 73..77 meet row 78: the
  tree's rows 73..77 (D7c's text from the docs pass) and D7l's row 78 kept; `adapters.py gen` leaves the result
  unchanged (134 rows).  `pdos_profile.c` had already been merged onto DBL's (D7j's merged copy plus D7l's hunks: the
  include, reset, on_event, the two on_probe calls and `pdos_space_advance` before DBL's `pdos_aplay_advance`).
  `pdos_scene_tab.c`, equal to the landed file (D7l changes none of its rows), is no longer staged (`obj/unstaged/`).
* **The action bit** (deviation 4): PDOS_AA_LAUNCH removed before the private runs; the launch actions are behind
  PDOS_AA_HOTKEY.
* **Bases** (`obj/mkbase.py`, `BASE-SHA256.txt`): origin "tree-d7j", the tree after D7j's landing (D7j's overlay).
  `mkbase.py check` compares with that snapshot, `mkbase.py check tree` with the live tree.
* **At the build slot** (15:05..15:45 UTC, after D6fS-a's landing, the docs pass docs-e4c (marker 14:55:11 UTC) and
  D7d's landing (copy-in 14:57:21 UTC, RELEASE_OK 15:32:56 UTC)): `obj/rebase_slot.py snap` copied the tree's copies of
  every staged file and reference (about 15:05 UTC, during D7d's test step, no build step running); 15 staged files had
  moved (OFFSETS.md, DOS-PROFILE.md, adapters.py, registry.py, pdos_adapt.c/.h, pdos_adapt_tab.c, pdos_profile.c,
  pdos_registry.c/.h, pdos_seq.c, dos-decoded.txt, ext_adapt.py, harness.c, test_input.c); `pdos_prov.c/.h` and
  `ext_timeline.py` had not.  `obj/rebase_slot.py merge`: `git merge-file -p` (stdout, files only) with the D7j
  snapshot as the base, D7l's copy as mine and the tree's as theirs: registry.py and pdos_adapt_tab.c clean (D7d's
  I-city rows, then D7l's I-space rows); 25 conflicts in the other 13, each D7d's and D7l's additions at the same place,
  resolved by `obj/resolve_slot.py`: D7d's lines first, then D7l's, with four adjustments (the scene list of
  adapters.py: D7d's entry gets the comma, D7l's closes the list; the 1.7.2 paragraph joins "...class W; extension D7l:
  ..." rewrapped; pdos_adapt.c: D7d's city block gets its own `return; }` before D7l's space block; test_input.c: the
  row count 134 -> 138 and its message naming both units).  Every line either side added is in the result except
  those four rewrites (checked line by line).  On the overlay, `adapters.py gen`, `registry.py gen` and `registry.py
  goldens` reproduce the merged DOS-PROFILE.md 1.7.2, `pdos_registry.c/.h` (63 tables) and `tests/dos-decoded.txt`
  byte for byte.  D7l's own lines over 120 columns (the I-space paragraph of pdos_adapt.h, four section rulers of
  pdos_scn_space.c/.h, two CHECK lines of test_pdos_space.c) rewrapped (`obj/fix_long.py`).
* **PDOS_OWNER_MAX 8 -> 9** (`present/dos/pdos_shadow.h`, staged at the slot; its base the tree's file): with D7d's
  "city" and D7l's "space" the profile registers eight owners (aplay, replay, report, setup, pmap, palace, city, space),
  so test_pdos_profile's own owner "D" (registered after `pdos_profile.reset`) was refused and three checks failed in
  the first unit run on the rebased overlay.  9 is the profile's eight owners and the test's one; test_pdos_shadow's
  fill loop handles any value up to 10.  A capacity change only (no new owner; D7l's "space" was part of the accepted
  unit); later units that add an owner raise it again.  Shared tables: `pdos_adapt.h`'s scene bit PDOS_AS_SPACE
  0x20000000 (D7l's), no new action bit; `PdosAdaptSc.l_hwnd` at the end of the struct; `pdos_shadow.h`'s PDOS_OWNER_MAX
  9 (raised from 8 at the slot, above); `pdos_adapt_tab.c` and `test_input.c` (the I-space block and vectors after the
  other units'; the row count adds 4 to whatever the tree has); `adapters.py` (D7l's SCENES row after D7d's);
  `ext_adapt.py` (`d7l_runs` after the other units' runs); `ext_timeline.py` (the space run after palace_view);
  `registry.py` (one entry); `pdos_profile.c`, `pdos_seq.c`, `harness.c`, `pdos_prov.c/.h` (one-line hooks and a
  delimited block each).  Shared counts: one new source file (portable sources +1), one new test program, obs_lint files
  +2.

## Landing

D7l landed alone at the build slot of session E4 (track C), 2026-10-17, after D7d's landing (its RELEASE_OK 15:32:56
UTC and `build/user-builds/d7d/`), which followed D6fS-a's landing and the docs pass docs-e4c
(`build/docs-e4c-done.txt` 14:55:11 UTC), as the orchestrator ordered.  The user checks D7l-1..D7l-3 are in the user
build `d7l`.

* **Bases:** rebased at the slot onto the tree after D7d's landing (Rebase notes: 15 staged files merged three ways,
  25 conflicts of adjacent additions resolved D7d's lines first, the generated files reproduced by their generators;
  PDOS_OWNER_MAX 8 -> 9 staged in `present/dos/pdos_shadow.h`), the bases written again (`obj/mkbase.py`, origin
  "tree", BASES_OK) and rechecked by `build/d7l-prep/land.py` (every base of `BASE-SHA256.txt` equal, the four new
  files absent, build.cmd and test.cmd unchanged, the other read-only references printed; DRY_RUN_OK 23).  Scripts in
  `build/d7l-prep/` (`mk_prep.py`, `mk_prep2.py`: `land.py` from `build/d7j-prep/` for D7l's BASE-SHA256.txt format,
  `compare.py`, `mk_userbuild.py`, `fill_stillopen.py` (a new group "d7d") and `d7l-cycle.ps1` from `build/d7d-prep/`).
  Snapshot `build/d7l-prep/before` (the tree's `build/test/Checked` outputs of D7d's cycle, 65 files) and `tree-before`
  (the nineteen replaced files); copy-in at 15:44:06 UTC (`landed.sha256`: the twenty-three files, build.cmd and
  test.cmd unchanged; `landed-at.txt` "unit d7l").  Predictions `build/d7l-prep/predictions.txt`, written before the
  copy-in.
* **The three-step cycle** (`build/d7l-status.txt`): a first start at 15:44:10 UTC with the four steps in one run
  (which would not have written ALL_GREEN after step 3) was stopped about 30 s into step 1's build.cmd, its partial
  log kept as `build/d7l-prep/aborted-d7l-1-build-checked.log` (`cycle-started.txt`); then 1 `build.cmd checked`
  BUILD_OK 15:44:48..15:48:47 (239 s; portable sources checked 302); 2 `test.cmd checked` TESTS_OK 15:48:47..16:21:11
  (1944 s; TEST_SECTIONS 30 failed 0; no flake rerun); 3 `ext_g1.py check` EXT_G1_OK runs 77 (amended 1) unchanged:
  **ALL_GREEN**.  4 `build.cmd` (Release) BUILD_OK 16:21:19..16:24:33 (194 s; portable sources 302): **RELEASE_OK**.
* **Against the predictions** (`build/d7l-prep/compare.py` against the snapshot; `compare.txt`: 49 of 65 files equal,
  host times left out): as predicted, unit.log test_pdos_space new 73, test_input 559 -> 579, test_dos 23250 -> 23252
  ("decoded content" 1380 -> 1382 lines; registry 61 -> 63 tables), every other count equal (test_pdos_profile 59,
  test_pdos_shadow 181); registry-check REGISTRY_OK with 19 more `ok` lines (SPACE_PARTS, SPACE_LAUNCH, their readers,
  the include rule of `pdos_scn_space.c/.h`; 378 -> 397); OBS_LINT_OK files 134 -> 136, probes 203, call sites 101;
  adapters-check ADAPT_OK rows 134 -> 138 steps 25; obs-tables and pdos-scene-check (1084) unchanged; EXT_ADAPT_OK
  checks 242 -> 247 (the five d7l-space lines equal to the private run: I-space/end, one click at (320, 240), the pair
  equal with coreinput 15 and frames 556, the N frame 52 shows and the A frame 73, the `space` line);
  EXT_TIMELINE_OK with 53 PASS lines (49 + 4: space; the runs line names space); P0_OK checks 476; REPLAY_OK checks
  70; every other harness section unchanged.  Not predicted in detail, explained (each "may change" in the
  predictions): (a) ext-p0's V4d zoom line of spaceship: 74 -> 61 shows with the layer (the spaceship screen shows the
  N frame instead of the zoomed A frame); (b) ext-replay's informational V1 line of spaceship (brackets 0/26/0 ->
  0/26/22, device 27 -> 39, draws 0 -> 19, muted 53 -> 68, no_shadow 60 -> 27, no_scene 1 -> 0): rows 102 and 78 are
  scenes now and the window and port have the "space" owner's shadows, so the replay draws the screen's primitives
  there; (c) coverage.txt "other functions entered" 666 -> 668 (informational); (d) nodos files 1785 -> 1790, 0 hits;
  (e) unit.log's OBS_COST line (host timing).
* **User build** `build/user-builds/d7l/`: `civ64.exe` (the Release build, SHA-256 d653545b...), `CIVWIN.zip` and
  `civdos.zip` from `build/user-builds/d4/`, `WHAT-TO-CHECK.txt` (D7l-1..D7l-3, the earlier builds up to "d7d", and the
  97 items still pending in the checklist at 16:21 UTC, D7d's seven among them).
* Not done at this slot: the checklist sections and STATUS rows (the orchestrator's) and the docs pass for D7l
  ("For the records"); the tree's CheckedNoObs build is not part of the three-step cycle (the private overlay builds and
  units of the three variants are in "Results", before the slot; at the slot the Checked variant).

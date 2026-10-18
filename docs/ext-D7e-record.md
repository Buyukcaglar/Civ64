# Extension phase D7, unit D7e (the city view, the founding scene, the city animations) - record

Draft for the build slot (BRIEF-d7.md "Units" D7e, extension session E4, track B).  Staged in `build/d7e-stage/` on the
tree after D7d's landing (RELEASE_OK 15:32:56 UTC), then rebased onto D7l's and D7m's landings (RELEASE_OK 16:24:33 and
17:08:34 UTC), the docs pass docs-e4d, D6fS-b's landing (RELEASE_OK 18:20:37 UTC), HM's (RELEASE_OK 19:26:37 UTC), the
docs pass e4e (19:28:57 UTC), D7l2's landing (RELEASE_OK 20:45:49 UTC) and D6fSc's (RELEASE_OK 22:30:10 UTC): the base
of every staged file is the tree's file after D6fSc's landing (`BASE-SHA256.txt`, checked against the live tree before
this record; section "Rebase notes").  Private builds and runs in `build/d7e-stage/obj/` only: an overlay `obj/src` =
the tree + the stage (`obj/mkoverlay.py`), built with the tree's build.cmd and flags (`obj/b.cmd`, `--nogen`), cc.cmd's
stricter checks per file (`obj/cc.cmd`), the unit programs (`obj/unit.py`) and the harness runs from the overlay's
binaries with every output under `obj/`; the tree's build/gamedata, dosdata and cache read only.

## Result

D7e is staged and READY_TO_BUILD.  With the DOS graphics, three scenes of play are the DOS game's, drawn on the N
canvas (320 x 200) from the core's state while the core runs its Windows counterparts:

* **The city view** (O19:0000; City > View, V or the VIEW tab of the DOS city screen, a wonder or improvement
  completed, the view after a founding): HILL.PIC with the city's houses, roads, buildings, wonders, walls, coast and
  the 1000h improvement in DOS's cells and places, from the core's own layout grid; the city's name and the year (or
  the pending message's box) in font 6 with the core's strings; HILL.PIC's palette (after a founding the HILL.PAL
  fade-in), the cycling slot 4; the citizens for the city screen's view; for a new wonder or improvement the first
  pass without it, 60 frames, then the second pass dissolved in.
* **The founding scene** (O22:0EAF): HILL.PIC, the core's caption "<city> founded: <year>." centred at the top in
  font 6, the four SETTLERS.PIC wagons crossing the lower strip at the core's pace, the pointer hidden; at its end the
  fade to black (60 frames) and the city view (-3) fading in; a key during the wagons ends it at once.
* **The city animations** (O19:167B invaders, O19:18C1 riot, O19:1AE1 celebration) over the city view the core
  showed before them: the lower half redrawn at every core frame with the DOS figures at the DOS places and cells.

Any key or a left press ends a scene where the core's wait or Button() takes it (I-wait, class X); no Go Back or
Cancel row exists (DOS has none).  The end follows DOS: page 0 black, then R:0238:1BEB (to the map: the fade-in of the
play palette from the view's colours, decision 3; back to the DOS city screen: the play palette at once) or, after an
animation, R:0238:1B44's fade from black.  The Windows graphics are unchanged.  Privately: the three variants build,
every unit program passes in each (a new test_pdos_cityview, 95 checks), the three d7e pairs pass 15 of 15, ext_adapt
(every case) EXT_ADAPT_OK checks 283, ext_p0 P0_OK checks 476, and every check script passes.

## Status

READY_TO_BUILD.  Built: the renderer `pdos_scn_cityview` (rows 88, 109, 111, 112 and 113 made ready while their DOS
scene is drawn, row 25 for the scenes' dialog-148 window, each restored at the end); the shadow owner `cityview` (the
scenes' windows at the logical resolution, their ports' bitmaps at the device resolution, every core drawing and copy
on them absorbed; the replay muted there); the TX effects on the module's own timeline (the founding's fade to black,
the view's HILL.PAL fade-in, the cycling slot 4, the 60 frames and the dissolve); the exit kinds for D7a's return
(`pdos_fx`); the pointer hidden through the founding and the animations; the I-wait scene shared with dialog 151
(`PDOS_AS_WAIT`, the scene's window as the class-X window; no new scene or action bit); five registry tables
(`docs/dos/OFFSETS.md`: WONDER_RECTS, decision 9; DIR_DX, DIR_DY; CITY_ANIM_DX, CITY_ANIM_DY); the `cityview` diag line
and timeline steps; `PDOS_OWNER_MAX` 9 -> 10.  Not built (deviations): the DOS layout generator's own draws (the
core's grid is drawn), DOS's animation frame counts (the core's pace), the nuclear explosion (D7n).

## What was built

### The city view (row 88; SCENES-PLAY 7.2; DOS listing O19:0000..0FEE)

* **The grid.**  O19:0000 lays the city out on a 19 x 12 grid (index 12 gx + gy) seeded by the sum of the name's
  letters; the core's ShowCityView 11B0:0000 does the same with its own generator (Open 21: the generators differ, the
  DOS one reseeds the shared C stream).  The module never generates: it reads the core's grid from ShowCityView's frame
  (`[bp-110h]`, BP = the entry probe's arg_base - 6) at the core's copy into the view's window (CopyPortToWindow
  11B0:10F9), with the city record, the wonders' cities, the owner's and the human's advances, the happy, unhappy and
  specialist counts (w16q_read only).
* **The drawing** (page 1, then to page 0; DOS listing): HILL.PIC (O19:0913); the big wonders 1, 3, 7 and 15 from
  WONDERS2.PIC at their places (O19:0923..09DC, the far table WONDER_RECTS, decision 9); the walls (O19:09DF..0A2D, from
  2Dh when wonder 7 is the city's); every grid cell in the listing's order (O19:0AFA..0C9A): the roads with the DOS road
  mask (O19:0B0D..0B88: the direction steps DIR_DX / DIR_DY, the neighbour's linear index 12 column + row, unbounded as
  DOS's) and the stub roads (O19:0BC1..0BEC), the houses of CITYPIX1.PIC (O19:102E), the buildings of CITYPIX2 or
  CITYPIX3.PIC (when the owner knows advance 25h; O19:106C), the wonders of WONDERS / WONDERS2.PIC at their heights
  (O19:10B9..10FA); the coast and its pier (O19:0CAA..0D0C); the 1000h improvement (O19:0D0F..0D64); the name and the
  year in font 6, colour 15 over the colour-0 shadow (O19:0D7A..0DEC), or the pending message's box at (80, 8)
  (O19:0DF1..0E0B), with the core's strings (ruling 6).  The cuts are O19:137F's (CITYPIX1 house and road slots with
  the alternative roads when the owner knows advance 3Ah, the building slots 0..22), drawn with colour 0 transparent.
* **The modes** (O19:0E47..0FD4): page 0 black, HILL.PIC's palette (not for -3), page 1 to page 0; -3 (after a
  founding): the HILL.PAL fade-in R:0000:04AA(15) (90 frames, TX); the cycling slot 4 (40h..4Fh, rate 15,
  R:0000:0382, TX); -1 (the city screen's view): the citizens O19:111F(city, 18h, 8Ch, 100h) of POP.PIC (the second row
  when the human knows advance 23h); a value >= 0 (a new wonder or improvement): the first pass without it, 60 frames
  (O19:0F3D), the second with it and G#10 DissolveToScreen(1, 10) (TX); -2 (before an animation): the cycling stopped,
  no wait.
* **Readiness.**  Row 88 is ready from the view's entry when an N scene shows below it (the DOS city screen, the
  founding: page 0 keeps what it shows until the view is drawn, as DOS's screen does), else from its first draw; row 25
  with the view's window.
* **The end** (decision 3): the view's window destroyed (GR_DialogClose 11B0:114B after the core's wait): page 0 black
  (O19:0FC7), then R:0238:1BEB (O19:0FCF).  To the map: the exit kind 1BEB (D7a's trigger fades the play palette in
  from the DAC the view left).  Back to the DOS city screen (the view entered over it: row 97 ready below row 88, past
  the city window's row 25): the fade's end at once, the play palette in the N DAC, no exit kind (inferred: DOS's fade
  runs over the black page 0 before the city screen is drawn again; the city screen's own end names the return).

### The founding scene (row 109; SCENES-PLAY 7.4; DOS listing O22:0EAF..1143)

At the core's first copy (11B8:16D7): page 0 black, HILL.PIC on page 1 and its palette, page 1 to page 0, the core's
caption centred at (160, 4) in font 6 colour 0 (O22:0FC9), the strip (0, 120, 320 x 40) saved at the top of page 1
(O22:0FF5); row 109 and row 25 ready, the pointer hidden.  At the core's n-th step copy (11B8:1818) the step x = 50h +
n - 1 (the core's DI, the DOS x): the strip restored, the four SETTLERS.PIC figures (k + x) & 3 at (x + 13k, 120 +
(10k & 15)) (O22:1042..107F), the strip to page 0.  The core's window closed (11B8:18A2): the fade to black
R:0000:04D4(10) (O22:10FC, 60 frames, TX); then either the city view (-3), drawn when the fade has ended (O22:1119,
one timeline), or, when the core shows no view (a key was pending, O22:1109), the founding's end at once: the fade's
end (black), page 0 black and the exit kind 1BEB (O22:1123..113E).  The founding ends at ShowCityFoundedAnimation's
exit (with the view: no exit kind of its own, O22:1143).

### The animations (rows 111..113; SCENES-PLAY 7.3; DOS listing O19:167B, 18C1, 1AE1)

Over the view (-2) the core showed before them (row 88): the lower half of page 0 saved at the top of page 1 (O19:17C7,
19D9, 1B94), DAC FDh = (3, 3, 3) for the invaders (O19:1698, E20), row 111, 112 or 113 ready, the pointer hidden.  At
each core frame (its CopyPortToWindow 11B0:1EEF, 22BF or 2615: TC, the core's pace) the half restored, the figures drawn
from the core's picture (its GR_PicRead id, P22..P24: INVADERS / INVADER2 / INVADER3, RIOT / RIOT2, LOVE1 / LOVE2) at
the DOS places and cells (invaders k 7..0 at (c - 48k, 84h), cell f % 10; rioters at (c + dx, dy + 84h), cell (f +
3k) % 10; celebrants at (c + 3 dx / 2, dy + 84h); drawn for -48 < x < 320), the half to page 0.  The DOS counter c
follows the core's position (the core's DI * 10 / 16).  The end: the core's exit, the exit kind R:0238:1B44.

### The shadow owner `cityview` and the replay

The scenes' dialog-148 windows (claimed at the logical resolution) and their ports' bitmaps (the view port, the
founding's and the animations' work ports; at the device resolution, so that the tiles cut from them get no shadow;
named at their creation inside GR_PicRead / LoadPictureToPortBitmap / GR_PortOpen / GR_PortDataToBitmap, or read from
[port + 1Ah] at the claim) are the owner's; every core drawing and copy on them is absorbed (counted `absorbed`), and
`pdos_replay` draws nothing there (`pdos_cityview_owns`, counted in the replay line's `city`).  The profile registers
nine owners now (aplay, replay, report, setup, pmap, palace, city, space, cityview); `PDOS_OWNER_MAX` 10 leaves room
for test_pdos_profile's own.

### Input (I-wait; C.12.7, C.14.3 class X)

While a scene of the module runs, the adapter's scene is `PDOS_AS_WAIT` (dialog 151's rows I-wait/mod, key, press,
right) with the scene's window as the class-X window: a key passes (the core's Button() or WaitForKeyOrClick takes
it), a left press passes at its I5 point in that window, a modifier alone and the right button are consumed.  The
founding's key abort and the view's end are therefore the same key or click in both graphics (the d7e pairs).

### Registry tables (OFFSETS.md; DOS file, DOS listing; decision 9)

WONDER_RECTS `[DGROUP:6444]:0000` u16 x 88 (22 entries of 8 bytes, entry 0 unused; O19:1606 converts entries 1..21
from edges to sizes when entry 1's third word is above 300; readers O19:097F, 10E2, 160D, the grid's wonder values
40h..55h bound the index to 21); DIR_DX DGROUP:1882 and DIR_DY DGROUP:18E4 u16 x 9 (the road mask's readers);
CITY_ANIM_DX DGROUP:4F42 and CITY_ANIM_DY DGROUP:4F4A u16 x 4 (the riot's and the celebration's offsets).  The FORMATS
6.1 entry for `[DGROUP:6444]` ("not established") is settled by these readers (For the records).

### Evidence labels

* DOS listing: every O19, O22 and R: address above (build/dos/disasm, read only).  DOS file: the pictures (HILL.PIC,
  HILL.PAL, CITYPIX1..3, WONDERS, WONDERS2, POP, SETTLERS, INVADERS..3, RIOT, RIOT2, LOVE1, LOVE2) and the five tables,
  read from the user's files at run time.  The core's side: the port's reconstruction (claude/src, core) for the call
  sites (11B0:0A3B .. 2679, 11B8:150D .. 18A7) and the frame's grid.
* Inferred: the return to the city screen in the play palette at once; an out-of-grid neighbour of the road mask taken
  as -1; the DOS counter of an animation at the core's position.
* DOS oracle: none (no DOS program run).

## Files

New: `present/dos/pdos_scn_cityview.c/.h`, `tests/test_pdos_cityview.c`, this record.  Changed (`BASE-SHA256.txt`):
`present/dos/pdos_profile.c` (include, reset, on_event, the probe entries and exits, advance, the cursor rule),
`pdos_seq.c` (the timeline.log sink), `pdos_replay.c` (muted on the owner's shadows), `pdos_adapt.c` (the I-wait scene
while a scene runs), `pdos_shadow.h` (`PDOS_OWNER_MAX` 10), `pdos_registry.c/.h` (generated: the five table ids),
`gen/dos/registry.py` (`pdos_scn_cityview.c` in `OBSERVER_FILES`), `docs/dos/OFFSETS.md` (five rows, the intro note and
a notes bullet), `docs/DOS-PROFILE.md` (rows 25, 88, 97, 109, 111, 112, 113), `tests/dos-decoded.txt` (the goldens of
the five tables), `tests/headless/harness.c` (the `cityview` diag line), `tests/harness/ext_adapt.py` (the d7e pairs).
Unchanged, though the brief lists them: `pdos_fx.c` (the exit kinds exist), `pdos_prov.c` (the module draws its cells
itself, no T rule is consulted), `pdos_pal.c` (HILL.PIC's palette and HILL.PAL are loaded by the module),
`pdos_scene_tab.c` (rows 25, 88, 97, 109, 111..113 exist), `pdos_adapt_tab.c` (I-wait's rows serve),
`tests/test_input.c` (no new row; the scene choice is the profile's, which test_input replaces by its hooks),
`ext_timeline.py` (the founding's fade and the view's fade-in are asserted on timeline.log by the d7e-view pair).
build.cmd and test.cmd unchanged (the new files are found by their globs).  Every `extension D7e` block is delimited
where it adds more than a line; one-line hunks carry an `extension D7e` comment.

## Tests

* **`tests/test_pdos_cityview.c`** (new, 95 checks in every variant): the listing's rules (the far table's rectangles
  and their conversion, the wonders' pictures and the big wonders' places, the house, building and road cuts, the road
  mask with its linear neighbour index, one cell's drawing with the stub roads and the improvement left out, the
  citizens, the founding's figures, the animations' cuts, counters and figures); the scenes from a synthetic stream
  through the scene and shadow engines and the module: the view from the city screen (rows 97 and 25 below it, row 88
  ready at its entry, the composition on page 1 and page 0 pixel for pixel against a reference painter, the HILL
  palette, the citizens, the cycling slot 4, the window and the port's bitmaps claimed and every core drawing absorbed,
  the end: page 0 black, the play palette at once, no exit kind, the city screen's rows back on top); a new wonder (pass
  1 without it, 60 frames, pass 2 and the dissolve; its end the exit kind 1BEB from the view's DAC); walls, coast and
  the 1000h improvement; an unreadable state; the founding (rows 109 and 25, HILL.PIC and the caption, the strip, the
  steps' figures, the pointer hidden, the fade to black at the window's end, then the view -3 after the fade with the
  HILL.PAL fade-in, one end); a founding cut short (no view: black, page 0 black and the exit kind 1BEB at once); the
  civil disorder and the invaders over a view -2 (rows 112 and 111, the lower half and the figures per core frame, DAC
  FDh, the exit kind 1B44); a celebration without a view (the A frame); the diag line.  The emulated memory, the
  pictures, the tables, the texts and the font are the test's own (synthetic): no emulation, no DOS byte.  It cannot
  build on the base (`pdos_scn_cityview.h` does not exist there).
* **`tests/harness/ext_adapt.py`, the d7e pairs** (6 runs, 15 checks; S3's lines with the DOS profile from 40,000 ms
  against the same lines without it):
  * `d7e-found` (53,000 ms): S3's Return at 52,000 ms in the founding scene (from 48,002 ms) decided by I-wait/key;
    the core outputs equal; timeline.log's `found` (O22:0EAF), `found_fade` (O22:10FC) at the window's close,
    `found_end` (no view: the exit kind 1BEB, O22:113E) and the city screen at the same instant, no return between;
    the 320 x 200 N frame from the founding's start to the run's end; the `cityview` line (one founding, its steps,
    no view, one end, one fade, every caption taken, nothing missing or unread).
  * `d7e-view` (61,000 ms; S3's lines before 52,000 ms and a Return at 60,000 ms): the founding's 40 steps, the fade
    from 55,971 ms, the view -3 (O19:0000) drawn exactly 60 frames later with the HILL.PAL fade-in (O19:0EB9, 15), the
    cycling slot 4 exactly 90 frames after that, the Return decided by I-wait/key ending the view (exit kind 1BEB,
    O19:0FCF), the founding's end (O22:1143) and the city screen; the core outputs equal; the N frame throughout; the
    `cityview` line (40 steps, one view and render with houses and roads, no bad cell, no citizens for -3, three
    texts, two fades, two ends).
  * `d7e-city` (56,000 ms; d7e-found's lines, then v at 53,000 ms on the DOS city screen, a Return at 54,000 ms, S3's
    Return at 55,000 ms): the rows I-wait/key, I-city/key (v: the core's 'v' as its character message), I-wait/key,
    I-city/key; the core outputs equal (the Windows form types v as its character message, as d7d's pair); the view
    -1 (O19:0000) drawn and cycling at its entry (no fade-in), its end (O19:0FCF) at the Return, the city screen drawn
    again, the city's end with the exit kind 1B44 (R:0D12:4FE3's VIEW, D7d) and its return; the N frame from the
    view's start to the city screen's end; the `cityview` line (one view and render, the citizens drawn, three texts,
    back_to_city 1).
  All three fail on the base (no I-wait row, the scenes on the A frame, no `cityview` line).

## Results (private, `build/d7e-stage/obj/`)

The builds, cc.cmd, the unit programs, the checks, ext_adapt and ext_zoom `--only new` below are on the overlay of
the tree after D6fSc's landing (copy-in 21:46:57 UTC, RELEASE_OK 22:30:10 UTC) and its own Checked, CheckedNoObs and
Release builds (22:31 .. 22:46 UTC).  ext_p0, ext_replay and ext_fce are on the overlay of D7l2's tree (20:56 ..
21:31 UTC, no landing running); D6fSc's cycle left their outputs unchanged (its `ext-p0.txt` and `ext-replay.txt`
equal D7l2's), so their D7e changes stand.  The earlier runs on the overlays of D6fS-b's, HM's and D7l2's trees gave
the same counts (with the tree's counts of then).

* **Builds:** Checked, CheckedNoObs and Release BUILD_OK (build.cmd's own flags on the overlay; portable sources 306,
  the tree's 305 + `pdos_scn_cityview.c`).
* **cc.cmd** (c11 and c17 at /W4 /WX, the clang C99 parse) in Checked, CheckedNoObs and Release: CC_OK for
  `pdos_scn_cityview.c`, `test_pdos_cityview.c`, `pdos_profile.c`, `pdos_replay.c`, `pdos_seq.c`, `pdos_adapt.c`,
  `pdos_registry.c` and `harness.c` (`pdos_profile.c`, `pdos_adapt.c`, `pdos_registry.c` and the new files again after
  the rebases onto D7l2 and D6fSc).
* **Unit programs** (`obj/unit.py`, the overlay's binaries, 62 programs per variant): every program passes in each
  variant (test_dos against the staged goldens, below).  Checked against D6fSc's cycle
  (`build/d6fsc-2-test-checked.log`, `obj/cmpunit.py`): test_dos 23262 -> 23267, test_pdos_cityview new 95, every other
  count equal (test_input 612, test_pdos_shadow 181, test_pdos_profile 59, test_pdos_reskin 171, test_pdos_space 96,
  test_pdos_arrive 64).  CheckedNoObs: test_pdos_cityview 95, test_dos 23267, test_input 555, test_pdos_shadow 179,
  test_pdos_profile 55.  Release: test_pdos_cityview 95, test_dos 23267, test_input 612, test_pdos_shadow 181,
  test_pdos_profile 59.  test_dos reads its goldens beside the data folder it is given, so it ran against the staged
  `tests/dos-decoded.txt` through `obj/fk/` (junctions to the tree's build/gamedata and build/dosdata, read only:
  "nothing written: 176 DOS files with equal size, SHA-256 and modification time"), PASS 23267 in each variant; with the
  tree's goldens (as unit.py runs it) it reports the one expected failure (the five new tables).
* **Checks** (on the overlay): `registry.py check --dosdata <tree>/build/dosdata --disasm <tree>/build/dos/disasm`
  REGISTRY_OK 0 failures (470 ok lines; the tree's 443); `obs_lint.py` OBS_LINT_OK files 144 probes 203 callsites 101;
  `obs_tables.py --check` (`obj/obstab.py`) OBS_TABLES_OK probes 203 sites 101; `pdos_scene_check.py` PASS 1084 checks,
  141 scene rows, 10 font rows; `adapters.py check` ADAPT_OK rows 147 steps 27 (`adapters.py gen` leaves the staged
  DOS-PROFILE.md unchanged); `nodos.py check` (Checked and Release) NODOS_OK, 0 hits.
* **ext_adapt** (`obj/runadapt.py all`: the staged runner on the overlay harness, every run under `obj/adaptroot5`):
  EXT_ADAPT_OK checks 292 (the tree's 277 + the 15 d7e lines); the d7a, d7b, d7c and d7d pairs pass unchanged (S3's
  founding now shows the DOS founding scene in their DOS-form runs; the founding's exit kind 1BEB is never taken there:
  the city screen follows in the same instant and names its own).  Before the rebase, on the tree after D7m:
  EXT_ADAPT_OK checks 263 (D7m's 253 + the first two pairs' 10).
* **ext_p0** (`obj/runp0.py`: the overlay's runner with the tree's save, `--exe` the private Checked harness, `--root
  obj/p0root4`, `--port` the tree for its inputs, read only; D7l2's overlay): P0_OK checks 476 (V0..V8s: V1, V2, V4d,
  V6, V7 and V8 equal V0, the gate rows' counters 0).  The `cityview` lines: `new`, `s3` (and V6, V6w) one founding of
  21 steps each, `settlers` one of 16, one end, one fade, nothing missing or unread; `city` (its view from the DOS city
  screen) one view and render (12 houses, 14 roads, 2 citizens), back_to_city 1.  `pdos_rows`: `new`, `s3` and
  `settlers` lose r109.unexplained (24, 24, 19 on the tree) and `city` loses r88.unexplained 3; r97's counts unchanged.
  V4d's shows with the layer: new 130, s3 130, settlers 246, city 158.
* **ext_fce** (`--harness` the overlay's, `--root obj/fceroot4`, D7l2's overlay): EXT_FCE_OK runs 8.
* **ext_zoom** (`obj/runzoom.py`: the tree's save, every profile and size, against the staged golden file): `--only new`
  ZOOM_OK combinations 10 runs 34 samples 140 not zoomed 12/84 (on D6fSc's overlay; with the tree's golden file the ten
  lines `dos new <size> <policy> <level> 50000` differ, section "Expected changes"); the other groups (`--only
  load,orders,s4,centre,mzi,mzs`, on HM's overlay: D7l2 and D6fSc change only the spaceship's scenes and the boxes' text
  lines, and D6fSc's cycle left every golden line unchanged) ZOOM_OK combinations 22 runs 74 samples 488, map
  comparisons 22, centre runs 4, mzi runs 12, mzs runs 4, not zoomed 26/364, none of their golden lines changed;
  together the tree's totals (combinations 32, runs 108, samples 628, not zoomed 38/448).
* **The scenes as drawn** (private: `obj/explore.py` with `--dump-presented`; the dumps deleted after reading): the
  founding (Rome founded: the caption in black at the top, the wagons in the lower strip), the fade to black half way,
  the view -3 (houses and roads, the name and year), the view -1 from the city screen with its citizen at (18h, 8Ch),
  and the city screen after it in the play palette.

## Deviations from the brief

1. **The core's layout, DOS's cells.**  The view draws the core's grid (read from ShowCityView's frame) with DOS's
   cells and places; DOS's own generator (O19:0000, seeded by the name's sum, reseeding the shared C stream) is not run
   (P0: no random number; Open 21: the generators differ).  The layout is therefore the Windows game's, its look DOS's.
2. **The animations at the core's pace** (TC): the DOS counter follows the core's frames (DI * 10 / 16), so the figures
   move in the core's 142, 94 and 98 frames where DOS takes 220, 156 and 156; their places, cells and spacing are DOS's.
3. **The founding's fade cut short** when the core leaves without a view: the core closes the window and opens the
   city screen in the same instant, so the fade ends at once (black); DOS completes its 60 frames before the key test.
4. **The view's second pass** (a new wonder or improvement): the 60 frames and the dissolve run while the core already
   waits for the key (the core draws once); a key during them ends the view at once.
5. **The view after a founding** is drawn when the founding's fade has ended (DOS's order); the core draws its view at
   once after closing the founding's window.
6. **An A-frame show at a scene change's instant**: when the founding ends and the city screen begins in the same
   instant, one show of the A frame precedes the city screen's first show at that instant (d7e pairs: superseded
   within the instant).  After ShowCityView(-2)'s return, rows 88 and 25 pop before the animation's entry; any show
   between them shows the A frame.
7. **The return to the city screen** takes the play palette at once (inferred: DOS's R:0238:1BEB fades it in over the
   black page 0 before the city screen redraws).
8. **G#32's cells are clipped** to the page; an out-of-grid neighbour of the road mask is taken as -1 (DOS reads the
   frame's neighbouring bytes there; no layout puts a road on the edge); every DOS slot is cut from its picture when
   drawn (DOS grabs the slots once at O19:0000's start: the same rectangles).
9. **Files** (see "Files"): the test is `tests/test_pdos_cityview.c` (D7d owns `test_pdos_city.c`); ext_timeline is not
   changed (the d7e-view pair asserts the fades' frames on timeline.log); `pdos_fx.c`, `pdos_prov.c`, `pdos_pal.c`,
   `pdos_scene_tab.c` and `pdos_adapt_tab.c` unchanged.
10. **`PDOS_OWNER_MAX` 9 -> 10** (orchestrator, 2026-10-17 16:25 UTC): the ninth profile owner `cityview`.

## What the user checks

On the user build (D7e landed; `civ64.exe`, DOS files present), in play with the DOS graphics (Ctrl+Shift+Backspace or
the host menu).  No Go Back or Cancel row appears anywhere:

* **D7e-1** Found a city (B on Settlers, accept the name): the whole window shows the DOS founding picture (320 x 200):
  the hills, "<city> founded: <year>." in black at the top, four settlers' wagons crossing the lower part; the pointer
  hidden.  Let it run: when the wagons have crossed, it fades to black and the city view fades in (the new city's
  houses and roads on the hills, its name and the year at the top, some colours cycling).  Any key or click closes it;
  the city screen follows.  A key or click while the wagons cross ends the picture at once and the city screen
  follows.
* **D7e-2** On the DOS city screen, V or a click on VIEW: the city view at once (no fade), with the city's buildings and
  wonders as DOS draws them and the citizens' faces at the bottom.  Any key or click returns to the city screen in its
  normal colours.
* **D7e-3** When one of your cities completes a wonder (or an improvement the game shows): the city view first without
  it, about a second later with it dissolving in.  Any key or click returns to the map, which fades in from the view's
  colours.
* **D7e-4** Civil disorder in one of your cities, a celebration ("We love the King" day) or a city captured: the
  animation runs over the lower half of the city view (rioters, celebrants or invaders crossing), the pointer hidden;
  at its end the map returns with the fade from black.
* **D7e-5** The same with the Windows graphics: the Windows founding picture, city view and animations, unchanged.

Not part of this check: the nuclear explosion (D7n), the production list, the rename and the questions over the city
screen (D7f, D7g), switching the graphics while a scene shows.

## For the records

* **DESIGN 12.x "As implemented (D7e; areas B and C)":** the city-view renderer `pdos_scn_cityview` (O19:0000's view
  from the core's grid and state with DOS's cells; the founding O22:0EAF at the core's steps; the animations O19:167B,
  18C1, 1AE1 at the core's frames with DOS's figures); rows 88, 109, 111..113 and 25 made ready while their DOS scene is
  drawn (88 from the entry over an N scene); the shadow owner `cityview` (windows logical, ports at the device
  resolution, everything absorbed; the replay muted); the TX effects on the module's timeline; the exit kinds (1BEB to
  the map, the play palette at once back to the city screen, 1B44 after an animation); I-wait shared (`PDOS_AS_WAIT`,
  the scene's window as class X's); the registry tables WONDER_RECTS, DIR_DX, DIR_DY, CITY_ANIM_DX, CITY_ANIM_DY; the
  `cityview` diag line; the shadow owners 9 of `PDOS_OWNER_MAX` 10.
* **FIDELITY** (new entries, numbers to be assigned from F259): F-new-1 the city view's layout is the core's grid drawn
  with DOS's cells (the DOS generator is not run; deviation 1); F-new-2 the animations run at the core's pace with the
  DOS counter at the core's position (deviation 2); F-new-3 the founding's fade ends at once when the core shows no view
  (deviation 3); F-new-4 a new wonder's 60 frames and dissolve run during the core's wait (deviation 4); F-new-5 the
  view after a founding is drawn after the fade (deviation 5); F-new-6 an A-frame show at the instant a scene hands over
  to the next N scene (deviation 6); F-new-7 the return to the city screen in the play palette at once (inferred,
  deviation 7); F-new-8 G#32 clipped, out-of-grid neighbours -1, slots cut when drawn (deviation 8).
* **FORMATS 6.1:** `[DGROUP:6444]` established: 22 entries of 8 bytes (88 words), entry 0 unused, edges converted to
  sizes by O19:1606 when entry 1's third word is above 300 (decision 9; OFFSETS.md WONDER_RECTS).  `[DGROUP:640A]`
  unchanged (D7k).
* **DOS-PROFILE.md prose** (as staged): rows 25, 88, 97, 109, 111, 112 and 113 "as implemented in D7e".
* **RUNNING.md:** presentation-diag.log's `cityview` line (views, renders, houses, roads, buildings, wonders, cell_bad,
  citizens, texts, founds, found_steps, anims, anim_frames, fades, dissolves, ends, back_to_city, absorbed,
  pic_missing, unread); the replay line's `city` counter now also counts the `cityview` owner's shadows; timeline.log's
  steps `cityview` (O19:0000, the mode), `cityview_draw` (O19:0E47, the pass), `cityview_end` (the exit kind),
  `found` (O22:0EAF, the city), `found_end` (the exit kind), `anim` (the kind), `anim_end` (the frames) in sequence 1,
  and `found_fade`, `cityview_fade_in`, `cityview_cycle`, `cityview_built`, `cityview_dissolve` in sequence 3;
  ext_adapt's d7e-found and d7e-view pairs; test_pdos_cityview.
* **FEATURES.md:** the DOS city view, founding scene and city animations in play (D7e), with the runners above.
* **STATUS.md:** D7e landed (rows 88, 109, 111..113; row 97's city-view part); the shadow owners 9 of
  `PDOS_OWNER_MAX` 10.
* **manual-checklist-ext.md:** new items D7e-1..D7e-5 (above).
* User direction 2026-10-16 (no added Go Back / Cancel rows) and 2026-10-17 (boxes as tall as their content, no
  highlight where DOS draws none, 2x): the scenes have no box, no row and no highlight of their own; everything on the
  N canvas at 2x.  Report items: none.
* Not edited by this unit: DESIGN.md, FIDELITY.md, FORMATS.md, STATUS.md, RUNNING.md, FEATURES.md, DOS-PROFILE.md
  outside rows 25, 88, 97, 109, 111..113, manual-checklist-ext.md, the D1 drafts and the D0 documents.

## Expected changes at the build slot

Relative to the tree after D6fSc's landing (`build/d6fsc-2-test-checked.log`, ALL_GREEN 22:25:59 UTC, RELEASE_OK
22:30:10 UTC):

* **Unit** (Checked and Release): a new program test_pdos_cityview (95); test_dos + 5 (23262 -> 23267; "decoded content"
  + 5 lines, the five tables); CheckedNoObs test_pdos_cityview 95 and test_dos + 5; every other count unchanged
  (test_input as the tree's: D7e adds no row and no vector; test_pdos_shadow 181 and test_pdos_profile 59 with
  `PDOS_OWNER_MAX` 10).  Portable sources + 1 (305 -> 306); obs_lint files + 2 (142 -> 144); probes 203 and call sites
  101 unchanged; `obs-tables.txt` unchanged.
* `registry-check.txt`: REGISTRY_OK, 0 failures, `ok` lines + 27 (the five tables' lines and the include-rule lines of
  `pdos_scn_cityview.c/.h`; 443 -> 470).  `pdos-scene-check.txt` (PASS 1084, 141 scene rows) and
  `adapters-check.txt` (ADAPT_OK rows 147 steps 27): unchanged.  `nodos.txt`: NODOS_OK, 0 hits (files about + 4).
* `ext-adapt.txt`: EXT_ADAPT_OK checks + 15 (277 -> 292); six more runs (d7e-found-dos/win 53 s,
  d7e-view-dos/win 61 s, d7e-city-dos/win 56 s of virtual time).  Every other line equal except where a DOS-form run
  passes S3's founding, which now shows the DOS scene on the N frame: the d7a, d7b, d7c and d7d pairs (their checks and
  counts as before); the informational counts of zoomkeys-dos (the DOS layer drawn in 125 -> 117 shows) and ring-dos
  (256 -> 235); f6-zcover-m1, -p1 and -menu (views 72 -> 51, 71 -> 50, 79 -> 58; ticks 70 -> 72, 69 -> 71, 77 -> 79);
  f6b-tax, f6b-hover and f6b-drag (the decisions' second entry I-pass/key -> I-wait/key: the key at the founding goes
  to the I-wait scene).  Each still passes.
* `ext-zoom.txt`: ZOOM_OK against the staged golden file `tests/harness/ext-zoom-golden.txt` (base: the tree's after
  D6fS-b), in which exactly ten lines change, reviewed one by one (`obj/zoomgold.py`: 70 samples, 10 changed, none
  missing or new): `dos new <size> <policy> <level> 50000` for 640x480 integer, 1280x960 integer, 1920x1440 integer,
  2560x1600 fit-sharp and 1366x768 fit-nearest, each at levels -1 and +1.  The same reason for all ten: S3's founding
  scene (48,002 .. 52,183 ms) is now the 320x200 N frame, whose shows carry no zoom fields; a sample is the last zoomed
  show at or before its time, so the 50,000 ms sample is now the map's last zoomed show before the founding (48,000.6
  ms; for 640x480 -1 `fdceec0c...`) instead of the A frame's show of the Windows founding window (the tree's
  `e8ff1d15...`).  The next zoomed show is at 52,183.2 ms (the instant the city screen opens), so 55,000 ms and later
  are unchanged, as are 40,000 and 45,000.  Presentation hashes, never core fixtures.  Every other line
  (the groups `load`, `orders`, the soak `s4`, `centre`, `mzi` and `mzs`) unchanged; the totals as the tree's
  (combinations 32, runs 108, samples 628, not zoomed 38/448).
* `ext-p0.txt`: P0_OK checks 476 unchanged.  `pdos_rows`: `new`, `s3` and `settlers` without r109.unexplained (24, 24,
  19 on the tree), `city` without r88.unexplained (3); r97's counts unchanged.  V4d's informational show counts of `new`
  and `s3` 137 -> 130 and `settlers` 256 -> 246 (the founding's N frame); `city` 158 unchanged.  Their `cityview` lines
  as in "Results".
* `ext-replay.txt`: REPLAY_OK checks 70; informational V1 counters change in `city` (city 437 -> 444, no_shadow 30 ->
  24, no_scene 1 -> 0), `new` and `s3` (city 15 -> 19, no_shadow 91 -> 88, no_scene 1 -> 0) and `settlers` (city 17 ->
  21, no_shadow 179 -> 176, no_scene 1 -> 0): the replay's `city` counter also counts the drawings muted on the
  `cityview` shadows (private run on the overlay's ext_p0 outputs, against the tree's
  `build/test/Checked/ext-replay.txt` of D7l2's cycle, equal to D6fSc's).
* `ext-fce.txt`: EXT_FCE_OK runs 8 unchanged.  `ext_timeline`, `ext_frames`, `ext_mirror`, `ext_slots`, `ext_tld`,
  `ext_dbl`: unchanged (no founding or city view in their runs, or the Windows profile).
* presentation-diag.log (harness): a new `cityview ...` line after the `space` line; the replay line's `city` counter
  as above.  timeline.log: the `found`, `cityview` and `anim` steps (sequence 1) and the scenes' TX steps (sequence 3)
  in runs that show them.
* Core outputs, G-1 fields and `ext_g1.py check`: unchanged (presentation only; the d7e pairs and ext_p0 V1/V2/V4d
  equal their references).

## Rebase notes

* **Bases.**  Staged on the tree after D7d's landing (RELEASE_OK 15:32:56 UTC); rebased onto D7l's landing (copy-in
  15:44:06 UTC, RELEASE_OK 16:24:33 UTC) and D7m's (copy-in 16:34:07 UTC, RELEASE_OK 17:08:34 UTC): the files both
  touched (OFFSETS.md, DOS-PROFILE.md, pdos_adapt.c, pdos_profile.c, pdos_seq.c, pdos_registry.c/.h, harness.c,
  dos-decoded.txt, ext_adapt.py) carry D7e's hunks after theirs; then onto the docs pass docs-e4d (17:13 UTC:
  DOS-PROFILE.md's D7m rows) and D6fS-b's landing (copy-in 17:44:37 UTC; `build/d6fsb-prep/land-write.log`):
  `obj/rebase.py d6fsb` merged the seven staged files whose tree copy had moved three ways (`git merge-file -p`, stdout
  only, files only; base: the previous base in `obj/base-pre-d6fsb/`, mine: the stage, theirs: the tree): OFFSETS.md,
  DOS-PROFILE.md, pdos_adapt.c and ext_adapt.py clean (D6fS-b's MENU_ORDERS, MENU_REPLAY, TERRAIN_BY_COLOUR and
  TERRAIN_NAMES rows before D7e's five; its adapter and ext_adapt additions beside D7e's); `pdos_registry.c/.h` (73
  tables) and `tests/dos-decoded.txt` regenerated on the overlay by `registry.py gen` and `registry.py goldens` (each
  the tree's file plus D7e's lines only); `adapters.py gen` leaves the merged DOS-PROFILE.md unchanged (ADAPT_GEN rows
  147).  Then HM's landing (copy-in 18:30:46 UTC, RELEASE_OK 19:26:37 UTC; its files host_win32.c/.h, present.c,
  profile.h, test_input.c, test_host_win32.c and civ64_main.c are disjoint from the stage: nothing to merge), the
  docs pass e4e (19:28:57 UTC; `obj/rebase.py e4e`: DOS-PROFILE.md merged clean, its 4:3-option and D6fS-b prose
  apart from D7e's rows; the previous base in `obj/base-pre-e4e/`) and D7l2's landing (copy-in 20:01:47 UTC, RELEASE_OK
  20:45:49 UTC; `build/d7l2-prep/land-write.log`): `obj/rebase.py d7l2` (the previous base in `obj/base-pre-d7l2/`):
  DOS-PROFILE.md and pdos_adapt.c clean (D7l2's arrival I-wait block after D7l's space block; D7e's before D7d's city
  block); OFFSETS.md's two conflicts (both appended at the same places) resolved with D7l2's SPACE_SECTION and
  SPACE2_SECTION rows and notes bullet first, D7e's five rows and bullet after them; pdos_profile.c's cursor rule (both
  added a term) resolved to one rule with both terms, `pdos_space_pointer_hidden() || pdos_cityview_pointer_hidden()`,
  D7l2's comment line before D7e's; `pdos_registry.c/.h` and `tests/dos-decoded.txt` regenerated (75 tables, the
  tree's 70 + D7e's 5; each the tree's file plus D7e's lines only).  `adapters.py gen` leaves the merged DOS-PROFILE.md
  unchanged.  Then D6fSc's landing (copy-in 21:46:57 UTC, RELEASE_OK 22:30:10 UTC): `obj/rebase.py d6fsc` (the previous
  base in `obj/base-pre-d6fsc/`): ext_adapt.py clean (D6fSc's additions beside D7e's d7e block); OFFSETS.md's two
  conflicts (both appended at the same places again) resolved by `obj/resolve_append.py` with D6fSc's BOX_RATES,
  BOX_QUIT and BOX_REV_SECTION rows and notes bullet first, D7e's after them; the registry's files regenerated (78
  tables, the tree's 73 + D7e's 5); D6fSc left `ext-zoom-golden.txt` as it was, so D7e's ten lines stand.  D7e's diff
  against each merged file's base is the same before and after the merge (OFFSETS.md - 3 + 18, ext_adapt.py + 180).
  Every base in `obj/base/` is the tree's file after D6fSc's landing (`BASE-SHA256.txt`, written by
  `obj/mkbase.py` and checked against the live tree before this record).
* **Unstaged:** `pdos_adapt_tab.c`, `tests/test_input.c` and `ext_timeline.py` had been copied for possible changes and
  are equal to the tree: not staged.
* **Shared tables.**  `pdos_shadow.h`'s `PDOS_OWNER_MAX` 9 -> 10 (orchestrator, 16:25 UTC: D7l raised it to 9 at its
  slot for eight profile owners and test_pdos_profile's own; `cityview` is the ninth profile owner).  test_pdos_shadow's
  fill loop (`k < PDOS_OWNER_MAX && k < 10`) fills all ten and test_pdos_profile registers its owner after the
  profile's nine: both pass unchanged (181 and 59 checks) in every variant.  No scene or action bit: the I-wait scene
  `PDOS_AS_WAIT` is shared (orchestrator's allocation).  `pdos_adapt.c` (one block before D7d's city block),
  `pdos_profile.c` (one-line hooks: include, the cursor rule, reset, on_event, the two on_probe calls, advance; each
  after `space`'s), `pdos_seq.c` (two sink lines), `pdos_replay.c` (one block after the city owner's), `harness.c` (the
  `cityview` line after the `space` line), `registry.py` (one entry), OFFSETS.md (five rows after REPLAY_MENU, one
  notes bullet, the intro note), DOS-PROFILE.md (rows 25, 88, 97, 109, 111..113), `ext_adapt.py` (`d7e_runs` after
  `d7d_runs`, its docstring paragraph after D7d's).
* **Shared counts.**  One new portable source (`pdos_scn_cityview.c`), one new test program, obs_lint files +2,
  registry tables +5 (73 -> 78) and `ok` lines +27, test_dos +5.  FIDELITY's next free number is F259 (orchestrator,
  after e4e); the F-new entries are numbered at the slot.

## Landing

D7e landed alone at the build slot of session E4, 2026-10-17, right after D6fSc's landing (its RELEASE_OK 22:30:10 UTC
and `build/user-builds/d6fsc/`), as the orchestrator ordered (D7e accepted as READY, `PDOS_OWNER_MAX` 10 for
"cityview" approved; no docs pass between D6fSc and D7e: their docs go in one joint pass after D7e).  The user checks
D7e-1..D7e-5 are in the user build `d7e`.

* **Bases:** D6fSc's landing changed four staged files' bases (OFFSETS.md, ext_adapt.py, `pdos_registry.c/.h`,
  `tests/dos-decoded.txt`): merged and regenerated as in "Rebase notes", then the overlay runs of "Results" on D6fSc's
  tree; `obj/mkbase.py` wrote `BASE-SHA256.txt` again (18 files, bad 0).  `build/d7e-prep/land.py` (from D7d's)
  rechecked every base (DRY_RUN_OK 18; build.cmd and test.cmd unchanged), took the snapshot `build/d7e-prep/before`
  (the tree's `build/test/Checked` outputs of D6fSc's cycle, 66 files) and `tree-before` (the 14 replaced files), and
  copied in at 22:59:02 UTC (`landed.sha256`: the 14 changed and 4 new files with this record; `landed-at.txt` "unit
  d7e"; `land-write.log`).  Predictions `build/d7e-prep/predictions.txt`, written before the copy-in.
* **The three-step cycle** (`build/d7e-prep/d7e-cycle.ps1`, status `build/d7e-status.txt`, each step guarded by its
  log's OK marker): 1 `build.cmd checked` BUILD_OK 22:59:12..23:05:32 (380 s; portable sources checked 306; no
  warning); 2 `test.cmd checked` TESTS_OK 23:05:32..23:42:19 (2206 s; wall 2204.2 s: ext_zoom 2181.5, ext_adapt
  1917.6, d2_nodos 1802.9, ext_p0 1546.1 s; no flake rerun); 3 `ext_g1.py check` EXT_G1_OK runs 77 (amended 1)
  unchanged: **ALL_GREEN** 23:42:19.  4 `build.cmd` (Release) BUILD_OK 23:42:33..23:46:36 (243 s): **RELEASE_OK**.
* **Against the predictions** (`build/d7e-prep/compare.py` against the snapshot, `build/d7e-prep/compare.txt`: 51 of
  66 files equal, host times left out): as predicted, unit.log test_dos 23262 -> 23267 (decoded content 1392 -> 1397
  lines, registry 73 -> 78 tables), test_pdos_cityview new (PASS 95), every other count equal; REGISTRY_OK with `ok`
  lines 443 -> 470; OBS_LINT_OK files 142 -> 144 (probes 203, callsites 101); OBS_TABLES_OK, pdos-scene-check (1084)
  and ADAPT_OK rows 147 steps 27 unchanged; NODOS_OK 0 hits (files 1808 -> 1814); EXT_ADAPT_OK checks 277 -> 292 (the
  15 d7e lines) with exactly the predicted informational changes (zoomkeys-dos 125 -> 117 shows, ring-dos 256 -> 235,
  f6-zcover-m1/-p1/-menu views 72/71/79 -> 51/50/58 and ticks 70/69/77 -> 72/71/79, f6b-tax/-hover/-drag I-pass/key
  -> I-wait/key); P0_OK checks 476 with V4d new 137 -> 130, s3 137 -> 130, settlers 256 -> 246; REPLAY_OK checks 70
  with the predicted V1 lines of `city`, `new`, `s3` and `settlers`; ZOOM_OK combinations 32 runs 108 samples 628 not
  zoomed 38/448 against the landed golden (the ten reviewed `dos new ... 50000` lines), its `new` runs' informational
  "shows dos" counts lower; EXT_FCE_OK runs 8 and the other sections unchanged.  Not named by the predictions,
  informational counts only, every criterion PASS as before, from the same cause (S3's founding at 48,002 .. 52,183
  ms is now the 320x200 N frame): ext_frames' s3 "presented.log of A equals A'" 821 -> 825 lines and "781 -> 780 tick
  shows".  Also informational: coverage.txt "other functions entered" 665 -> 671 (the merged coverage files' known
  jitter and the new module's callers); unit.log's OBS_COST line (host timing).
* **User build** `build/user-builds/d7e/` (23:47 UTC; `build/d7e-prep/mk_userbuild.py`): `civ64.exe` (the Release
  build, SHA-256 99e10328...), `CIVWIN.zip` and `civdos.zip` from `build/user-builds/d4/`, `WHAT-TO-CHECK.txt`
  (D7e-1..D7e-5, the earlier builds up to "d6fsc", and the 120 items still pending in the checklist at 23:47 UTC,
  `build/d7e-prep/fill_stillopen.py`, written by `mk_fill.py` from D6fSc's with the group "d6fsc").  No saved game is
  added: a new game's first Settlers found a city at once (D7e-1) and the city screen's VIEW shows the city view
  (D7e-2); D7e-3 and D7e-4 need a wonder, a disorder, a celebration or a capture in the user's own play.
* **Lessons:** my own private runs overlapped two landings' test steps (HM's about 18:30 UTC; D7l2's 20:06..20:27 UTC,
  whose status file appears only after its build step, so my busy check missed the copy-in); since then
  `obj/watchdog.py` stops a private rerun at any new copy-in or status file.

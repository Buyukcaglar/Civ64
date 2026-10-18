# Extension phase D7, unit D7l2 (the spaceship arrival) - record

Draft for the build slot (the orchestrator's D7l2 ruling of 2026-10-17: row 130; P32..P34, T17, E12's arrival part;
OPEN L1; DOS-PROFILE Open 5; extension session E4, track A).  Staged in `build/d7l2-stage/` on the tree after D7m's
landing (RELEASE_OK 17:08:34 UTC; bases copied 17:39:10 UTC, `obj/base-at-copy-pre-d6fsb.txt`), rebased onto D6fS-b's
landing (RELEASE_OK 18:20:37 UTC) by three-way merges without conflict (18:24 UTC, `obj/rebase-d6fsb/`) and onto the
docs pass e4e's `docs/DOS-PROFILE.md` (19:28:57 UTC, `obj/rebase-e4e/`), the overlay made again after HM's landing
(RELEASE_OK 19:26:37 UTC; HM changed none of D7l2's files).  The base of every changed file is the tree's file now
(`obj/base-at-copy.txt`), rechecked in `BASE-SHA256.txt` (section "Rebase notes").  Private builds and runs in
`build/d7l2-stage/obj/` only: an overlay `obj/src` = the tree + the stage (`obj/mkoverlay.py`; `obj/sync.py` lays later
stage edits over it), built with the tree's build.cmd and flags (`obj/b.cmd`, `obj/ball.py`, `--nogen`), cc.cmd's
stricter checks per file (`obj/cc.cmd`, `obj/ccall.py`), the unit programs and the harness runs from the overlay's
binaries with every output under `obj/`; the tree's build/gamedata, dosdata, dos/disasm and cache read only.

## Result

D7l2 is staged, rebased and privately verified.  With the DOS graphics the spaceship's arrival (row 130) is the DOS
game's O2:0BD7 drawn over the core's ShowSpaceshipArrival 11D8:0000, at the core's decisions and pace: the pan of
`PLANET1.PIC` with `PLANET2.PIC`'s turning planet, the ship's dot and the text band, column by column over the core's
first loop (TC: its 153 steps of 12 ticks share DOS's 320 columns); then for the human's ship DOS's fade to black and
`SPACEST.PIC` with six cycling slots (TX), for another civilization's ship the sad palace O17:07EC(1) after its fade
(TX; D7j's composer); the rest of the KING.TXT text one chunk per core caption with the blinking dot (TC), DOS's key
wait after the last; the end with the return's fade from black (exit kind 1).  On the spaceship screen (row 102)
DOS's star motion O18:0C49 now runs where the core's stars stand (the wait before the launch, a timed showing), its
new rows from `pdos_rand` (effect "space_stars"), never the core's generator.  No core change, no core random draw,
no new PDOS_AS bit (I-wait), no new shadow owner ("space" extended; 8 of PDOS_OWNER_MAX 9).  Two registry rows
(`SPACE_SECTION` DGROUP:32F2, `SPACE2_SECTION` DGROUP:32F9) name the text's sections.  Privately: the three variants
build (portable sources 305), every unit program passes in each (test_pdos_arrive new, 64 checks; test_pdos_space 73
-> 96; test_dos 23,257 -> 23,259 with the staged goldens), the registry, obs_lint, obs_tables, scene, adapters and nodos
checks pass, ext_p0's `arrival` and `spaceship` runs are P0_OK in V0, V1 and V2 with no scene-row count left on row
130, the other civilization's branch (a private edited save) has V1's base trace equal to V0's, ext_timeline is
EXT_TIMELINE_OK and ext_adapt's d7j and d7l pairs pass (section "Results").

## Status

**LANDED 2026-10-17** (copy-in 20:01:47 UTC, ALL_GREEN 20:41:04 UTC, RELEASE_OK 20:45:49 UTC; user build
`build/user-builds/d7l2/`; section "Landing").  The user's checks D7l2-1..D7l2-4 are pending on build "d7l2".

At staging: READY_TO_BUILD.  Built: row 130 (the arrival, O2:0BD7 over ShowSpaceshipArrival 11D8:0000) and, inside row
102, DOS's star motion O18:0AF3..0B38 where the core's stars stand (the ruling's "If DOS's stars move while the ship
stands"); the drawing in a new pure module `present/dos/pdos_scn_arrive.c/.h`, the run glue in
`present/dos/pdos_scn_space.c/.h` (the owner "space"); DOS-PROFILE row 130, P32..P34, T17, E12's arrival part, 2.8's
counts and Open 5 (resolved), row 102 (the orchestrator's correction of its end, and the star motion); I-wait extended
to the arrival (no new row: the rows' texts and 1.7.2 regenerated).  OPEN L1's arrival part is resolved (O2:0BD7..1529
read whole, DOS listing).  OB4 stays an inference (F242).  Not in the unit: D7n (the conqueror ending, the civilization
destroyed), row 125.

## What was built

### The core's arrival and DOS's (DOS listing; the core's reconstruction)

The core (core/seg060_11D8.c): ShowSpaceshipArrival(arrivingCiv) opens dialog 148 (GR_DialogOpen(0x94) 11D8:0092),
clears the screen port (FillRectLogical 11D8:00C9), loads picture 0x15B3 into a picture port (LoadPictureToPortBitmap
11D8:00F6; 0x15B4 only in the dead monochrome branch, WI 1.2) with its palette, fills g_textSubstParams 13C8:0000
(11D8:0125..0294), plays sound 3, copies the picture to the window (11D8:02EF) and opens a 512 x 30 caption port
(GR_PortOpen 11D8:035E).  Its first loop takes 153 steps of 12 ticks (11D8:03A8..0542; captions by CopyPortBits
11D8:0431 and CopyPortToWindow 11D8:04B0; each step ends with CopyPortToWindow 11D8:0517); SetGameCursor 11D8:0546
ends it.  The human's ship: PlaySoundEffect(1) 11D8:05A8, picture 0x15B4 (11D8:05C8), its palette and copy (11D8:0678);
another civilization's: GR_DialogClose 11D8:06AC and OpenPalaceView(1) 11D8:06B6.  The second loop takes up to 480
steps of 5 ticks, a caption every 40 (11D8:06FC), PollMouseClick 11D8:07DB and IsKeyPending each step, ending at a key
or a click; then WaitForKeyOrClick 11D8:081C, and GR_DialogClose 11D8:085D or ClosePalaceView.

DOS (build/dos/disasm/ovl02.lst, O2:0BD7..1529, with DGROUP:D762 set, the VGA path): the set-up (PLANET2.PIC's 24 cuts
49 x 49 at (50 (i mod 6) + 1, 50 (i div 6) + 1), page 0 in ECh, PLANET1.PIC with its palette into page 1 and its two
moves, font 6, the dot at x -10); the text (KING.TXT's section `*SPACE` for the human's ship, `*SPACE2` for another's,
its five tokens replaced, its length taken, then its first byte set to 0 at O2:0ECA); the pan, 320 columns of 8
frames with a catch-up skip (O2:10A9..10C6), each column: page 1's band refilled with the next '^'-chunk every 22
columns centred at (160, 184) in 38h and (160, 183) in 3Ch, the planet's next cut (k mod 23) at (135, 51), page 0's top
band, text band and planet scene shifted in from the right, the ship's dot on odd columns; the rest of the text after
the pan (O2:119F..11DC); the human's ship (SPACEST.PIC into page 1, the fade to black in 5 steps, page 0 black,
SPACEST's palette, page 1 to page 0, six cycling slots O2:12A1..134C) or another's (O17:07EC(1) at O2:1356, page 1 to
page 0); the rest's chunks (O2:137E..145C: the top band from page 1, the chunk centred at (160, 5) in 11 and (160, 4) in
15, the dot (280, 32) on, wait(80), off, wait(80); no key test in this loop), the last chunk (no '^' after it) not
drawn; the key wait R:1459:0918 (O2:146C), the slots stopped, page 0 black, R:0238:1BEB and the caller's R:0238:1B44
(R:0238:0792).  The pointer is hidden before O2:0BD7 (R:0238:073B) and nothing shows it there.

### The drawing (`pdos_scn_arrive.c/.h`, pure)

The listing's drawing as functions of the N machine (pages 0 and 1, the DAC), the pictures and the text, with no
emulation, clock or random number: `pdos_arrive_text`, `_begin`, `_step` (one pan column), `_rest`, `_next`, `_chunk`,
`_dot`, `_page1`, `_show`, `_copy1`, `_clear`, and the six slots' table (1: 15 10h..1Fh, 2: 100 20h..22h, 3: 42
23h..28h, 4: 300 29h..2Fh, 5: 60 30h..35h, 6: 37 36h..3Fh).  The tokens' values are the core's five strings ($US,
$THEM, $BUCKS, $RPLC1, $RPLC2 = g_textSubstParams[0..4], read through w16q_read at the first step, after the core has
filled them), folded (B 10.4); the bytes past the text are zero (DOS's stale bytes there are never drawn).

### The pace (TC, TX) and the flow (`pdos_scn_space.c`)

| DOS | drawn at (the core) | timeline |
|---|---|---|
| set-up O2:0BD7..0ED5 | GR_DialogOpen's return (11D8:0097): the play palette with PLANET1's over it, rows 130 and 25 ready (the N frame) | TS |
| text O2:0D52..0ECA | the first step's copy (11D8:0517) | - |
| pan columns O2:10D7..10C8 | the core's step s (its copy 11D8:0517) covers columns floor(320 s / 153) .. floor(320 (s + 1) / 153) - 1, spread evenly over its 12 ticks (200 ms) from the copy and never past them | TC |
| the pan's end O2:119F..11DC | SetGameCursor 11D8:0546: the remaining columns at once | TC |
| the human's ship O2:11ED..134E | PlaySoundEffect(1) 11D8:05A8: SPACEST into page 1, the fade (5 steps, 30 frames), then the picture and the six slots | TX (the arrival's own timeline, PDOS_SEQ_FX_FADE) |
| another's ship O2:1350..137B | OpenPalaceView(1) 11D8:06B6: the sad palace composed from the core's palace state, its fade (DGROUP:DEBA 8 inferred), then SAD's palette and page 1 to page 0; row 104 ready | TX |
| the rest's chunks O2:137E..145C | the core's second-loop step n (PollMouseClick 11D8:07DB): chunk n / 40, the dot on for the first 20 steps of the 40, off for the last 20 | TC |
| the key wait O2:146C | no further chunk, or the core's WaitForKeyOrClick 11D8:081C (the dot off) | - |
| the end O2:1480..1520 | ShowSpaceshipArrival's return: the slots stopped, page 0 black, the rows back, exit kind R:0238:1B44 | exit kind 1 |

The TX timelines (the arrival's and the stars') reach each probe's time before it is handled (`run_tl`); the core's
end inside a fade completes it at once (`pdos_tl_tail`, the abandon at the end).

### The windows, the ports, the rows and the input

The arrival's window (dialog 148 of 11D8:0092) and, for another civilization's ship, the palace window of
OpenPalaceView(1) are claimed by "space" at the logical resolution: every core drawing and copy on them is absorbed
(`arrive_absorbed`) and the replay's place hook draws nothing there.  The bitmaps the arrival's own ports make
(LoadPictureToPortBitmap 11D8:00F6 and 05C8, GR_PortOpen 11D8:035E, and inside OpenPalaceView(1)) are declined while
the arrival runs (no shadow: the claim's negative return, D7b's mechanism; `arrive_bitmaps`), so the core's picture,
caption strip and palace port are not followed and nothing of them is unexplained (before: 8 copies into the caption
strip and 18 nearest colours on row 130, 1 and 2 on row 104).  Row 130 is pushed at ShowSpaceshipArrival's entry
(the A frame until its dialog opens), row 25 (dialog 148) and, for the palace window, row 104 are held ready while the
arrival shows and put back as they were at its end.  The DOS pointer is hidden from the set-up to the end
(`pdos_space_pointer_hidden`, `pdos_profile.c`'s cursor rule).  Input: `pdos_adapt.c` makes the arrival the scene
PDOS_AS_WAIT with its window (or the palace window) as the class-X window, so the I-wait rows decide: a key passes (the
core's IsKeyPending in its second loop, then its WaitForKeyOrClick), a left press passes at that window, the right
button and a lone modifier are consumed.  No new PDOS_AS bit (0x10000000 stays free), no new owner.

### DOS's star motion on the spaceship screen (row 102)

DOS's wait loop O18:0AF3..0B38 moves its 20 stars (O18:0C49) after waiting 4 frames before the launch and 2 after it
(O18:0B01..0B18: the civilization's bit of DGROUP:4CD8), in the wait for a key and in a timed showing alike.  The core
moves its stars once per showing and, in the wait, only after the launch (1070:0E59..0E88); in the wait before the
launch and in a timed showing they stand.  There DOS's motion now runs on its own timeline (TX, PDOS_SEQ_FX_FADE)
from the showing's first copy (1070:0DBD): per star its erase, its class's step (+2, +1, +1 on an odd count), the wrap
at x F0h to x 1 with a new row `pdos_random(C0h) + 8` (R:1DC4:005D at O18:0C77, effect "space_stars", one instance per
start: `pdos_fx_rand`), its point where page 0 is 0, drawn into the port's shadow and mirrored to the window's and page
0.  It stops at the core's next star frame (whose stars, at the core's own positions, replace the moved ones), the
launch, EvaluateAndShowSpaceship's entry or return and the screen's end.  The presentation's generator is a local
state seeded from the effect's name and instance; it never reads, writes or advances the core's g_randSeed and reads no
clock (P0: ext_p0's `spaceship` run equals V0 in V1 and V2 with 52 moves).

### Registry tables (OFFSETS.md; DOS file, DOS listing)

`SPACE_SECTION` DGROUP:32F2 (str, 7 bytes, reader O2:0E63) and `SPACE2_SECTION` DGROUP:32F9 (str, 8 bytes, reader
O2:0E68): the KING.TXT section names O2:0E5B..0E6B passes to R:1F4D:01AD for the human's and another civilization's
ship.  `registry.py check`: the rows, their readers, no writer.

### Counters

presentation-diag.log's `space` line gains `star_moves`, `arrivals`, `arrive_ends`, `pan_steps`, `core_steps`,
`chunks`, `polls`, `arrive_absorbed`, `arrive_missing`, `arrive_bitmaps`; timeline.log gains `space_stars`
(O18:0AF3, the period), `arrive` (O2:0BD7, the civilization), `arrive_pan` (O2:10D7), `arrive_rest` (O2:119F, the
columns drawn), `arrive_spacest` (O2:11FF) or `arrive_sad` (O2:1356), the fade (O2:122B or O17:0CB5), `arrive_shown`
(O2:1277 or O2:1376), the six `cycle_setup` (O2:12B1..1329) and `cycle_start` (O2:133B), `arrive_chunk` (O2:13BE, its
index), `arrive_wait` (O2:146C), `cycle_stop` (O2:148A) and `arrive_end` (R:0238:0792, exit kind 1).

### Evidence labels

* DOS listing: every O2, O17, O18 and R: address above (ovl02.lst, ovl17.lst, ovl18.lst, read only).
* DOS file: PLANET1.PIC, PLANET2.PIC, SPACEST.PIC, SAD.PIC (D7j's), KING.TXT's two sections, DGROUP:32F2 and 32F9.
* Inferred: the first pan chunk's visible effect (O2:0ECA clears the text's first byte, so the pan's first chunk is
  drawn as an empty string); DGROUP:DEBA 8 (every disk's file present: the sad palace's fade runs, O17:0CA2..0CAE);
  the roles of P32..P34 and T17 (DOS's pictures as the counterparts of the Windows pictures 5555..5566); the star
  classes' pairing by i mod 4 (D7l's, F241); OB4: the font of row 102's "Prob. of Success" (font 1, P14; F242), kept an
  inference as the ruling says.
* Unknown: the planet's first cut (the listing's [bp-208h] is an unset stack word; the renderer starts at cut 0); the
  start of the star count DGROUP:687A (O18 never sets it; each motion counts from 0).
* DOS oracle: none (no DOS program run).

## Files

Changed (`BASE-SHA256.txt`): `present/dos/pdos_scn_space.c/.h` (the arrival's glue, the star motion, the declined
bitmaps, the counters; the query's `text` member), `present/dos/pdos_adapt.c` (the arrival as PDOS_AS_WAIT, one
block), `present/dos/pdos_adapt_tab.c` (the I-wait rows' texts), `present/dos/pdos_profile.c` (the pointer, one
condition), `present/dos/pdos_registry.c/.h` and `tests/dos-decoded.txt` (generated by `registry.py gen` and `goldens`
from the two new rows), `docs/dos/OFFSETS.md` (the two rows), `gen/dos/adapters.py` (the I-wait scene text and the
preamble), `docs/DOS-PROFILE.md` (rows 102 and 130, P32..P34, T17, E12, 2.8, Open 5; 1.7.2 regenerated),
`tests/test_pdos_space.c` (the motion).  New: `present/dos/pdos_scn_arrive.c/.h`, `tests/test_pdos_arrive.c`, this
record.  build.cmd and test.cmd unchanged (`present\dos\*.c`, every `test_*.exe`); `pdos_scn_arrive.c` includes no
`w16_obs.h`, `input.h` or `<stdio.h>` (registry.py's include rule passes; OBSERVER_FILES unchanged).  Not staged, though
they name the arrival's palace as D7l's: the comments of `present/dos/pdos_scn_palace.h` (line 48) and
`pdos_scn_palace.c` (lines 41, 1096) (section "For the records").  The D7l2 parts of shared files are `extension
D7l2` blocks or one-line hunks with an `extension D7l2` comment.

## Tests

* **`tests/test_pdos_arrive.c`** (new, 64 checks in every variant; synthetic memory, font, pictures (PLANET1, PLANET2,
  SPACEST, SAD with their palettes) and texts, no DOS byte): the text (tokens, length, the first byte, zero past it, no
  section), the six slots; the pan's set-up, its columns (the bands, the chunk text in 38h and 3Ch, the planet's cuts,
  the dot on odd columns, column 22's chunk), the rest; through the module (synthetic ObsEvent / ObsProbe streams): the
  human's arrival from its dialog's opening (rows 130 and 25, the N frame, the pointer, the palette), the window's
  drawing absorbed and the replay's place hook, the port bitmaps declined (a bitmap made elsewhere is the engine's),
  the 153 steps' columns at their times (never past a step), the pan's end, SPACEST's fade and the six slots, the
  rest's chunks at the 40th polls with the dot's 20 on and 20 off, DOS's key wait after the last chunk, the core's
  WaitForKeyOrClick, the end (slots stopped, page 0 black, the rows back, exit kind 1B44, no generator call, nothing
  unexplained, the bitmaps no longer declined), the diag line; another civilization's ship (`*SPACE2`, the palace
  window, the sad palace after its fade with SAD's palette, the palace port declined, the rest's chunk over it, the
  I-wait window the palace window, the end with row 104 back); the edges (missing pictures and text counted, the
  core's end inside the fade, an arrival without its return).  On the base it does not build
  (`pdos_scn_arrive.h` absent), and the module's checks need row 130's drawing, which the base leaves to the A frame.
* **`tests/test_pdos_space.c`** (73 -> 96): the star rule O18:0C49 (pure: the erase, the three classes' steps with the
  count's parity, the wrap with its row from the generator, a star over a non-zero pixel not drawn), and the motion
  through the module: it starts at the showing's first copy in the wait before the launch (period 4, logged
  `space_stars`), nothing before the 4th frame, star 0 wrapped to (1, row) from effect "space_stars"'s first draw on
  the port's shadow and page 0, star 1 one pixel right, star 2 at the 8th frame (the count odd), one generator seed and
  one draw, the core's next star frame (1070:0E88) putting its own stars back and stopping the motion, no motion in the
  wait after the launch, a timed showing every 2 frames after the launch and every 4 before it, the end.  On the base
  the motion checks fail (no motion: `star_moves` absent, the stars stand).
* `tests/test_dos`: the two registry rows (23,257 -> 23,259 with the staged goldens).
* Harness runners unchanged (ext_p0, ext_timeline, ext_adapt, ext_mirror); their `arrival` and `spaceship` runs and
  the d7l pair pass through the new drawing (section "Results").

## Results (private, `build/d7l2-stage/obj/`)

Session E4 (2026-10-17), on the overlay `obj/src` = the tree after D6fS-b's and HM's landings and the docs passes e4d
and e4e + the stage (made 19:31 UTC; at 19:52 UTC it differs from the tree only in D7l2's files and in STATUS.md and
the checklist, the orchestrator's), the bases of `BASE-SHA256.txt` rechecked:

* **Builds** (`obj/ball.py`, the tree's build.cmd and flags with `--nogen`): Checked, CheckedNoObs and Release
  BUILD_OK, portable sources 305 (`pdos_scn_arrive.c` added; 331, 319 and 388 s, 19:31..19:49 UTC,
  `obj/ball-all.log`).  Before (on D6fS-b's tree, 18:32..19:27 UTC): the same.
* **cc.cmd** (`obj/ccall.py`: c11 and c17 /W4 /WX and the clang C99 parse, every variant) on `pdos_scn_arrive.c`,
  `pdos_scn_space.c`, `pdos_adapt.c`, `pdos_adapt_tab.c`, `pdos_profile.c`, `pdos_registry.c`, `test_pdos_arrive.c` and
  `test_pdos_space.c`: CCALL failed 0 (24 CC_OK).
* **Unit** (`obj/unit.py`, the tree's build/gamedata read only): all 61 programs (test_ne aside) pass in Checked,
  CheckedNoObs and Release, w32_test_host_win32 included, but test_dos's golden comparison (below).  test_pdos_arrive
  64 and test_pdos_space
  96 in each variant; test_dos 23,259, its one failure the golden comparison only (test_dos reads the goldens beside
  the gamedata it is given: the tree's `tests/dos-decoded.txt`, without the two rows); its decoded output equals the
  staged `tests/dos-decoded.txt` line for line (1,389 decoded lines) in each variant, so at the build slot it
  passes.  Against HM's
  cycle log (`build/hm-2-test-checked.log`; `obj/cmpunit.py`) every other Checked count is equal.
* **Checks** on the overlay: `registry.py check` (`--dosdata` and `--disasm` of the tree's build, read only)
  REGISTRY_OK, 0 failures, 429 `ok` lines (the tree's 421: the two rows' three each, the include rule for
  `pdos_scn_arrive.c` and `.h`; dos-decoded 1,387 -> 1,389 lines); `registry.py gen` and `goldens` in the overlay
  reproduce the staged files byte for byte; `obs_lint.py` OBS_LINT_OK files 142 probes 203 callsites 101 (the tree's
  140); `obs_tables.py --check` (`obj/obstab.py`, the tree's listing) OBS_TABLES_OK probes 203 sites 101;
  `pdos_scene_check.py` PASS 1084 checks, 141 scene rows, 10 font rows; `adapters.py check` ADAPT_OK rows 147 steps 27
  (`adapters.py gen` reproduces the staged DOS-PROFILE.md); `nodos.py check --root obj/src` (the three variants'
  binaries; the tree's build/dosdata and build/gamedata read) NODOS_OK, 1,177 files, 0 hits.
* **ext_p0** (the tree's runner, `--exe` the private Checked harness, `--root obj/p0root`, `--only arrival,spaceship`,
  V0, V1, V2): P0_OK checks 14 (V0 equals the G-1 baseline; V1 and V2 equal V0; the switch assertions; no count on a
  D4, D5 or D6 row).  V1 `arrival`: `pdos_rows` without row 130 (the tree: `r130.unexplained 167`), the `space` line
  `arrivals 1 arrive_ends 1 pan_steps 320 core_steps 153 chunks 15 polls 33 arrive_absorbed 166 arrive_missing 0
  arrive_bitmaps 5`; timeline.log `arrive` (civ 1) at 50,751,250 us, `arrive_pan` 50,751,300, `arrive_rest` (320) and
  `arrive_spacest` and the fade (5) at 81,399,500, `arrive_shown`, the six slots' setups and starts and the first
  `arrive_chunk` at 81,827,532 (frame 30), `arrive_wait` 84,036,950 (the core's wait after the script's Space ended its
  second loop at poll 33), the six `cycle_stop` and `arrive_end` (exit kind 1) at 87,000,950, the return R:0238:1B44 at
  the next A frame (90,000,950).  V1 `spaceship`: `star_moves 52` (its 3-second wait before a launch), no row count.
* **Another civilization's ship** (`obj/sadrun.py`: scenarios.py's `arrival` script on build/gamedata's CAE3540B.SAV
  edited for civilization 2's ship, spaceshipFlags |= 4, spaceshipLaunchYear[2] -3560, spaceshipArrivalYear[2] -3539,
  as `obj/sad/SADARR.SAV`; V0 and V1 with the private harness): SADRUN_OK, the base traces equal (1,534 lines: frames,
  snapshots and result, events) and both exit 0; V1: `arrive` (civ 2), `arrive_sad` (O2:1356) at the pan's end, its
  fade, `arrive_shown` (O2:1376) at frame 30, one chunk, DOS's key wait, the end; `pdos_rows` without rows 130 and 104
  (before the declined bitmaps: r130 7 + 16, r104 1 + 2); `arrive_bitmaps 11` (the ports and the palace's buffers).
* **ext_timeline** (the tree's runner, `--exe` the private harness, `--root obj/tlroot`): EXT_TIMELINE_OK, 53 checks
  (the tree's 53); the space run's N frame shown 71 times from the open to the end (the tree: 52; the motion's frames).
* **ext_adapt's d7j and d7l pairs** (`obj/runadapt.py`, the tree's ext_adapt.py with the private Checked harness): 10
  of 10; the d7l pair's `space` line with the D7l2 fields (`star_moves 52`, the arrival's at 0).
* **ext_mirror** (the tree's runner, `--only arrival,spaceship`, `--root obj/p0root`): MIRROR_OK runs 2
  (unexplained 0, present_mismatched 0, dos_mismatched 0, dos_unexplained 0, P0 equal).
* The final ext_p0 (P0_OK checks 14) and the other civilization's runs (SADRUN_OK) were repeated on the final Checked
  harness (19:37 UTC build); the figures above are theirs.

## Deviations from DOS and the ruling

1. **The pace is the core's (TC).**  The pan's 320 columns take the core's 153 steps of 12 ticks (30.6 s; DOS 2,560
   frames, 36.53 s, with a catch-up skip of an odd column when late, O2:10A9..10C6, not modelled: the columns are
   spread evenly); the rest's chunks come one per core caption (40 steps of 5 ticks, 3.33 s; DOS 160 frames, 2.28 s),
   the dot on and off for 20 steps each (DOS 80 frames each).
2. **A key or click ends the rest early.**  DOS's chunk loop O2:137E..1469 has no key test: it shows every chunk, then
   waits (O2:146C).  The core's second loop ends at a key or click (IsKeyPending, PollMouseClick); the renderer then
   waits as DOS does at its key wait, without the chunks the core skipped.
3. **The first pan chunk is not drawn** (DOS's own effect of O2:0ECA, inferred visible): kept.
4. **The right button is consumed** (I-wait/right, C.12.7 passes the left press only); DOS's key wait R:1459:0918 ends
   at any button.
5. **DOS's star motion is presentation-side** (row 102): where the core's stars stand, DOS's motion runs with
   `pdos_rand`; at the core's next star frame its own stars replace the moved ones (the stars may jump there).
6. **The arrival's port bitmaps are declined** (no shadow): the core's picture, caption strip and palace port have no
   DOS counterpart; page 0 is DOS's arrival.
7. **No new PDOS_AS bit and no new owner** (the ruling's default): I-wait and the owner "space" cover the arrival.

## Reach plan for row 130

* **The human's ship:** ext_p0's `arrival` run (ARRIVAL.SAV: civilization 1, the human, launched in 3560 BC, arriving
  in 3539 BC; turn 24's start shows the arrival at about 50.8 s) reaches row 130 in V1 and V2 (and the switching V2,
  V4d, V6...), so test.cmd's P0_OK covers it at the build slot (no matrix change).
* **Another civilization's ship:** no matrix run reaches it.  The private `obj/sadrun.py` (above) is the scenario: the
  same script on the same save edited for civilization 2 (saveedit's spaceshipFlags, spaceshipLaunchYear[2],
  spaceshipArrivalYear[2]).  Proposal for a later harness unit: scenarios.py `EDITS["ARRIVAL2.SAV"]` with these three
  fields and an `arrival2` row (the `arrival` builder and options) for ext_p0 V0/V1/V2 (not in ext-g1-baseline.txt, as
  D5f's runs; G-1's 77 runs unchanged).  Not done here: no harness change in this unit.
* For the user: the edited saves `ARRIVAL.SAV` (build/p0/saves, written by ext_p0) and `SADARR.SAV`
  (build/d7l2-stage/obj/sad) as test input in the user build, as D7m's `ENDGAME.SAV`.

## What the user checks

On the coordinator's user build (D7l2 landed; `civ64.exe`, DOS files present), in a game with the DOS graphics.  The
screens fill the window as 320 x 200 DOS screens (4:3 when "Correct 320 × 200 to 4:3" is checked); none has a Go Back
or Cancel row; the pointer is hidden during the arrival:

* **D7l2-1** The arrival of your own ship (load `ARRIVAL.SAV`, end the turn: the next turn starts with it): a dark
  scene scrolls in from the right edge, column by column, for about half a minute: a planet turning in the middle, a
  small white dot (your ship) moving across, and below them a band of text lines appearing one after another (the
  very first line is blank, as in DOS).  Then the screen fades to black and shows your landed ship with colours
  cycling in its lights; at the top the remaining text lines appear one by one with a small blinking dot at the right.
  After the last line (or after a key or click), a key or a left click goes on; the map returns with the fade from
  black (the newspaper and the end of the game follow).
* **D7l2-2** Another civilization's ship (load `SADARR.SAV`, end the turn): the same scroll with that civilization's
  text, then a fade and your palace in its sad form, with the remaining lines at the top over it; a key or a left
  click goes on.
* **D7l2-3** The spaceship screen's stars (World > Spaceships for a ship not yet launched, or the screen after a part is
  built): the small stars drift slowly to the right and come back at the left edge at new heights; after the launch
  they move as before (the game's own motion).
* **D7l2-4** The same with the Windows graphics: the Windows arrival and spaceship window, unchanged.

Not part of this check: switching the graphics while the arrival shows; the conqueror ending and the destroyed
civilization's screen (D7n).

## For the records

* **DOS-PROFILE** (staged): row 102's Differences corrected (the orchestrator's docs pass e4d item 1: "the end without
  a fade (exit kind 1)" was wrong; the end is the return's fade from black R:0238:1B44, exit kind 1, 30 frames, as
  D7l's record, ext_timeline's space run and the d7l pair show; row 104 calls the same "exit kind 1"), and extended by
  D7l2's star motion (its timeline "TS + TC (stars) + TX (cycling; DOS's star motion, D7l2)"); row 130 "as implemented
  in D7l2"; P32 (`PLANET1.PIC`, the pan), P33 (`SPACEST.PIC`, the human's ship), P34 (`PLANET2.PIC`'s cuts) and T17
  (cut k mod 23 at column k) "inferred (role), medium, as implemented in D7l2"; E12's arrival part "none: DOS's fixed
  text colours (38h and 3Ch, 11 and 15); not used; proved (DOS listing), high"; 2.8's open counts (P27; T5; E12's
  none); Open 5 resolved; 1.7.2 regenerated (the I-wait rows name the arrival).
* **FEATURES.md** (the next docs pass; the orchestrator's item 2): D7j's row ends "the spaceship arrival's palace and
  the sad palace are D7l's" -> "the spaceship arrival's palace (O17:07EC(1), the sad palace) is D7l2's (row 130)"; D7l's
  row "the arrival unchanged" -> "the arrival since D7l2"; a new D7l2 row: the DOS spaceship arrival (the pan, the
  landing or the sad palace, the rest's lines) and the stars' DOS motion, with the runners of "Results".
* **FIDELITY.md** (the next docs pass, next free F259; item 2): D7j's paragraph "Not in the unit: the spaceship
  arrival's palace and the sad palace's fade (D7l; the composer and the sad helpers are ready for it)" -> "(D7l2: row
  130 composes the sad palace with them)"; D7l's paragraph "Not in the unit: the arrival (row 130, O2:0BD7, with its sad
  palace; F243) ... the stars' DOS clock (F238) and OB4 (F242) go to D7's gate" -> the arrival and the stars' DOS motion
  done in D7l2, OB4 still an inference; F243 superseded (row 130 implemented, O2:0BD7 read whole); F238 superseded in
  part (the stars stand only where DOS's would too: the wait after the launch moves the core's); new entries, numbers by
  the docs pass:
  * F-new-1: DOS's star motion where the core's stars stand (the wait before the launch, a timed showing): O18:0C49
    every 4 frames (2 after the launch) from the stars shown, its new rows from `pdos_rand` (effect "space_stars"),
    drawn presentation-side; the core's still stars are the core's (P0); at the core's next star frame its stars
    replace the moved ones (**choice**: a DOS-faithful presentation difference, the ruling's).
  * F-new-2: the arrival's pace is the core's (deviation 1).
  * F-new-3: a key or click ends the rest's chunks early (deviation 2).
  * F-new-4: the pan's first chunk is not drawn (O2:0ECA; DOS's own effect, kept; inferred visible effect).
  * F-new-5: the right button does not end the arrival's waits (deviation 4).
  * F-new-6: the sad palace's fade assumes DGROUP:DEBA 8 (every disk's file present; inferred); the planet's first
    cut ([bp-208h] unset in the listing) and the star count's start (DGROUP:687A) are unknown: cut 0 and 0.
  * F-new-7: the arrival's port bitmaps are declined (deviation 6).
* **DESIGN.md** 12.x "As implemented (D7l2; areas B and C)": `pdos_scn_arrive` (pure) and the arrival's glue in
  `pdos_scn_space` (the owner "space": the arrival's window and the palace window claimed, the port bitmaps declined;
  rows 130, 25, 104; TC for the pan and the chunks, TX for the transition, the fade and the slots on the arrival's own
  timeline; I-wait with PDOS_AS_WAIT; the pointer hidden); the star motion on the screen's own timeline with
  `pdos_rand`; the owners still 8 of PDOS_OWNER_MAX 9, PDOS_AS 0x10000000 still free.
* **OFFSETS** (staged): `SPACE_SECTION` DGROUP:32F2 and `SPACE2_SECTION` DGROUP:32F9.
* **OPEN.md** L1: the arrival part resolved (O2:0BD7..1529 read whole, DOS listing; D7l2); the other parts stay.
* **SCENES-PLAY.md** 7.16's last sentence ("only partly read") and Open 8's arrival: read whole in D7l2 (the pan,
  SPACEST or the sad palace, the rest, the key wait; this record); **TIMING.md** 5.7: O2:0BD7 is the spaceship arrival
  (no longer "unknown"), its waits as listed, the core's pace used (deviation 1).
* **RUNNING.md**: the `space` line's new fields and timeline.log's new steps (section "Counters"); test_pdos_arrive.
* **Code comments for a later touch of D7j's files** (not staged): `pdos_scn_palace.h` line 48 ("is extension D7l's")
  and `pdos_scn_palace.c` lines 41 and 1096 ("extension D7l") name the arrival's palace as D7l's; it is D7l2's.
* **STATUS / checklist** (the orchestrator's): D7l2 done (the user checks D7l2-1..4 pending); OPEN L1's arrival part and
  DOS-PROFILE Open 5 closed; row 130, P32..P34, T17 and E12's arrival part no longer D7 gate items.

## Expected changes at the build slot

Against HM's cycle (`build/hm-status.txt`, ALL_GREEN 19:22:16 UTC, RELEASE_OK 19:26:37 UTC):

* build.cmd: portable sources 304 -> 305 (`pdos_scn_arrive.c`); one more test program (`test_pdos_arrive.exe`).
* test.cmd checked: test_pdos_arrive new, 64 checks; test_pdos_space 73 -> 96; test_dos 23,257 -> 23,259 ("registry:
  68 -> 70 tables valid"; decoded 1,387 -> 1,389 lines); every other unit count unchanged.  `registry.py check`
  REGISTRY_OK, `ok` lines 421 -> 429; the golden `tests/dos-decoded.txt` 1,387 -> 1,389 decoded lines (file 1,392 ->
  1,394; `table SPACE_SECTION 7 ...` and `table SPACE2_SECTION 8 ...`, staged); OBS_LINT_OK files 140 -> 142 (probes
  203, callsites 101 unchanged); OBS_TABLES_OK 203 / 101, pdos_scene_check 1084, ADAPT_OK rows 147 steps 27 unchanged;
  EXT_ADAPT_OK checks 268 unchanged (the d7l pair's `space` line gains the D7l2 fields, `star_moves` > 0);
  EXT_TIMELINE_OK unchanged; P0_OK checks 476 unchanged; MIRROR_OK runs 29, REPLAY_OK 70, ZOOM_OK, EXT_FRAMES_OK and
  the other suites unchanged; NODOS_OK (0 hits).
* ext_g1: EXT_G1_OK runs 77 unchanged (the Windows profile's frames do not change).
* Informational, may change (not predicted to the count): ext-p0's V1 `pdos_rows` of `arrival` (row 130's counts gone);
  ext-p0's V4d zoom lines of `arrival` and `spaceship` (the arrival now shows the N frame); ext-replay's informational
  V1 lines of `arrival` and `spaceship` (the arrival's primitives absorbed or not followed); ext-timeline's space run's
  N-frame show count (52 -> 71); coverage.txt's "other functions entered"; nodos's file count (+3); OBS_COST.

## Rebase notes

* **Bases:** the tree's files after HM's landing and the docs pass e4e, their hashes in `obj/base-at-copy.txt`
  (`sha *file`) and rechecked equal to the tree by `obj/basesha.py` (`BASE-SHA256.txt`, its second line gives the
  time).  The first bases (the tree after D7m's landing, 17:39:10 UTC) are in `obj/base-at-copy-pre-d6fsb.txt`.
* **D6fS-b** (RELEASE_OK 18:20:37 UTC): `present/dos/pdos_adapt.c` (CRLF), `pdos_adapt_tab.c`, `gen/dos/adapters.py`,
  `docs/DOS-PROFILE.md` and `docs/dos/OFFSETS.md` merged three ways at 18:24 UTC (`git merge-file -p` to stdout, read
  only to the repository; `obj/rebase-d6fsb/` base, theirs, mine, merged): no conflict (D6fS-b's menu constants and
  rows, its I-menubar and I-play rows and its four OFFSETS rows beside D7l2's hunks).  `pdos_registry.c/.h` and
  `tests/dos-decoded.txt` regenerated, not merged, by the tree's `registry.py` (`gen`, then `goldens --dosdata
  build/dosdata`) on the merged OFFSETS.md; DOS-PROFILE 1.7.2 by `adapters.py gen` (equal to the merge).
* **Docs pass e4e** (19:28:57 UTC; DOS-PROFILE.md's HM and D6fS-b prose): `docs/DOS-PROFILE.md` merged three ways again
  (`obj/rebase-e4e/`), no conflict; `adapters.py gen` reproduces it.  HM's landing changed none of D7l2's files.
* **Another landing** that changes `pdos_scn_space.c/.h`, `pdos_adapt.c`, `pdos_adapt_tab.c`, `pdos_profile.c` or the
  docs: merge three ways (D7l2's parts are `extension D7l2` blocks and one-line hunks); OFFSETS.md and the generated
  files as above; DOS-PROFILE's 1.7.2 by `adapters.py gen`.  `present/dos/pdos_shadow.h` (PDOS_OWNER_MAX 9) and
  `pdos_scn_palace.c/.h` are the tree's (D7l2 adds no owner and reads D7j's composer through its header).
* **After the copy-in:** the base check, then build.cmd checked, test.cmd checked and ext_g1, guarded by each log's OK
  marker; the release build; the user build with `ARRIVAL.SAV` and `SADARR.SAV` as test input.

## Landing

D7l2 landed alone at the build slot of session E4 (track A), 2026-10-17, after HM's landing (ALL_GREEN 19:22:16,
RELEASE_OK 19:26:37 UTC, `build/user-builds/hm/`) and the docs pass e4e, by its implementer as the orchestrator
directed (its message of about 19:58 UTC: "D7l2 accepted. The slot is yours, so land now"; the slot free since 19:40
UTC, no cycle running).  The rework D6fSc lands after this RELEASE_OK; a joint docs pass for D7l2 and D6fSc follows
D6fSc.  The user checks D7l2-1..D7l2-4 are in the user build `d7l2` ("What the user checks").

* **Bases:** the bases of "Rebase notes" (the tree after HM's landing and e4e), rechecked right before the copy-in by
  `build/d7l2-prep/land.py` (every one of the twelve changed files' base equal, the four new files absent, the eleven
  read-only references the same, build.cmd and test.cmd among them: DRY_RUN_OK 16).  Scripts in `build/d7l2-prep/`
  (`mk_prep.py`: `land.py`, `d7l2-cycle.ps1` and `compare.py` from `build/d7m-prep/`; `mk_userbuild.py` from D7m's with
  ARRIVAL.SAV, SADARR.SAV and SHIP.SAV in place of ENDGAME.SAV; `fill_stillopen.py` from HM's, D7l2's own rows left out,
  no group "hm" (HM-1..HM-9 passed at about 19:41 UTC), the group "d7l" noting D7l2-3).  Predictions
  `build/d7l2-prep/predictions.txt`, written before the copy-in.  Snapshot `build/d7l2-prep/before` (the tree's
  `build/test/Checked` outputs of HM's cycle, 66 files) and `tree-before` (the twelve replaced files); copy-in at
  20:01:47 UTC (`landed.sha256`: the sixteen files, build.cmd and test.cmd unchanged; `landed-at.txt` "unit d7l2").
* **The three-step cycle** (`build/d7l2-status.txt`, each step guarded by its log's OK marker): 1 `build.cmd checked`
  BUILD_OK 20:01:56..20:07:23 (327 s; portable sources checked 305); 2 `test.cmd checked` TESTS_OK 20:07:23..20:41:04
  (2021 s; TEST_SECTIONS 30 failed 0; no flake rerun); 3 `ext_g1.py check` EXT_G1_OK runs 77 (amended 1) unchanged:
  **ALL_GREEN** (20:41:04 UTC).  4 `build.cmd` (Release) BUILD_OK 20:41:14..20:45:49 (275 s; portable sources 305):
  **RELEASE_OK**.
* **Against the predictions** (`build/d7l2-prep/compare.py` against the snapshot; `compare.txt`: 53 of 66 files equal,
  host times left out): as predicted, unit.log test_pdos_arrive new 64, test_pdos_space 73 -> 96, test_dos 23257 ->
  23259 (registry 68 -> 70 tables; decoded content 1387 -> 1389 lines), every other count equal (test_input 612,
  test_host_win32 453); registry-check REGISTRY_OK with 8 more `ok` lines (the two rows' three each and the include
  rule of `pdos_scn_arrive.c/.h`; 421 -> 429) and the goldens line 1387 -> 1389; dos-decoded.txt the two `table
  SPACE_SECTION 7 ...` and `table SPACE2_SECTION 8 ...` lines; OBS_LINT_OK files 140 -> 142, probes 203, call sites
  101; ADAPT_OK rows 147 steps 27, OBS_TABLES_OK 203 / 101 and pdos_scene_check 1084 unchanged; EXT_ADAPT_OK checks
  268 with the d7l pair's N-frame shows 52 -> 71 and its `space` line gaining the D7l2 fields (`star_moves 52`, the
  arrival's at 0); ext-timeline's space N-frame shows 52 -> 71 (EXT_TIMELINE_OK); P0_OK checks 476, MIRROR_OK runs
  29, REPLAY_OK checks 70, ZOOM_OK, EXT_FRAMES_OK, NODOS_OK (0 hits) and every other harness section as before.  The
  informational "may change" items: (a) ext-p0's V4d zoom line of arrival 230 -> 172 shows with the layer (the arrival
  now shows the N frame; V4's arrival and the spaceship lines unchanged); (b) ext-replay's informational V1 arrival
  line, brackets 0/52/31 -> 0/52/32 and no_scene 23 -> 22 (the spaceship line unchanged); (c) coverage.txt "other
  functions entered" 668 -> 670; (d) nodos files 1802 -> 1807, 0 hits; (e) unit.log's OBS_COST line (host timing).
* **User build** `build/user-builds/d7l2/`: `civ64.exe` (the Release build, SHA-256 85460ac2...), `CIVWIN.zip` and
  `civdos.zip` from `build/user-builds/d4/`, test input `ARRIVAL.SAV` (`build/p0/saves`, ee6acadc...: your own ship
  arrives, D7l2-1), `SADARR.SAV` (`build/d7l2-stage/obj/sad`, d210a18c...: another civilization's ship arrives, the
  sad palace, D7l2-2) and `SHIP.SAV` (`build/p0/saves`, 71473687...: your ship started, not launched, for D7l2-3's
  stars), `WHAT-TO-CHECK.txt` (D7l2-1..D7l2-4 with which save shows which branch, the earlier builds up to "hm", and
  the 115 items still pending in the checklist at 20:45 UTC).
* Not done at this slot: the checklist rows D7l2-1..D7l2-4 and STATUS (the orchestrator's) and the docs pass ("For the
  records"; the joint D7l2/D6fSc pass after D6fSc); the tree's CheckedNoObs build is not part of the three-step cycle
  (the private overlay's three variants are in "Results").

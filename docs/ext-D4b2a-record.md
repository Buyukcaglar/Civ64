# Extension phase D4, unit D4b2a (the DOS intro, credits and logo program) - record

Unit D4b2a of the "civ64" extension: the DOS intro, credits and logo of the DOS graphics profile as a
pure program (`present/dos/pdos_intro.c`) driven by the timeline engine of D4b1, tested in
`tests/test_timeline.c` on the real DOS files of `build/dosdata` read through E's store. Design:
[verify/ext-d1-draft-C.md](verify/ext-d1-draft-C.md) (revision 3) C.6 (C.6.1..C.6.6), C.5.4, C.5.5 and
C.15.1 items 2, 3 and 7 (intro part). Brief: [verify/BRIEF-d4.md](verify/BRIEF-d4.md), "D4b split"
(the D4b2a bullet). Engine: [ext-D4b1-record.md](ext-D4b1-record.md). Session D4b2a, 2026-10-12.

Labels: **compiled** (the three language checks and `/W4 /WX`), **headless** (the unit test program on
`build/dosdata`), **DOS listing (model)** for the timing claims (the clock model of C.4; no DOS-oracle
comparison). No DOS program was executed; nothing was written to `C:\Projects\Civ1RE\dos`,
`build/dosdata` or `C:\Projects\Civ1RE\original`; no UI was shown; no DOS byte is in the repository or a
binary (the test holds frame numbers, listing constants and hand-written vectors; it compares pixels
with the store's pictures at run time). No git command that writes was run. Asan was not built or run.
Every constant was read from the listing `build/dos/disasm/ovl02.lst` (O2:01CD..0BD6, O2:19A3) and
checked against `docs/dos/TIMING.md` 5.2, 5.3, 5.6 and `SCENES.md` 4, 5.

## Status

DONE. The program is not wired into the DOS profile: `pdos_profile.c` is unchanged and there is no
`pdos_seq` yet (D4b2b), so the DOS profile's output is unchanged; no frame expectation or golden
changed. The final cycle is in "Results".

## What was built

| File | Contents |
|---|---|
| `present/dos/pdos_intro.h/.c` (new) | the program `pdos_intro_prog` (O2:01CD..0BD6 at the level of its waits), `pdos_intro_bind`, `pdos_intro_start` (C.6.1, T1), `pdos_intro_at_title`, `pdos_intro_preselect`, the context `PdosIntroCtx` (the logo sprite), the resume labels `PdosIntroPc`, the code immediates as `PDOS_INTRO_*` constants with their listing addresses |
| `present/dos/pdos_tl.h` (changed) | `PdosIntroVars` replaces D4b1's placeholder (8 words, as before: `PdosTl` stays 1,248 bytes) |
| `present/dos/pdos_rand.h/.c` (changed) | `pdos_rand_calls()`: a counter of `pdos_srand`/`pdos_rand` calls for C.15.1 item 7 (Deviation 7); the generator is unchanged |
| `tests/test_timeline.c` (extended) | the "D4b2a" section: items 2, 3 and 7 (intro part), and items 4 and 6 run on the intro; it opens the store from `<gamedata>\..\dosdata` as `test_pdos_ui` does and writes `timeline-intro-steps.txt` (the no-key run's steps) into the output directory |

### The program and its resume labels

`pdos_intro_prog` is a `switch (tl->pc)` with one label per wait of the listing, named after the address
the program resumes at (C.5.2). Within a resume the DOS steps run in listing order on `tl->m` with area B's
primitives (`pdos_fill_rect` for R:0000:0BFA, `pdos_copy_rect` for G#20, `pdos_sprite` for G#32,
`pdos_grab` for G#2, `pdos_text_centred` for R:0182:00B3, `pdos_show_page` for G#31, `pdos_dac_load_m0`
for the palettes) and the engine's helpers (tune, kbhit, getkey, flush, cycling, waits, dissolve), and
are logged with `pdos_tl_step`.

| Label (`PdosIntroPc`) | Resumes at | Runs (listing) | Ends with the wait |
|---|---|---|---|
| `PDOS_INTRO_PC_START` (0) | t0 (C.6.1) | O2:01CD..0345 the preparation (below), O2:034A x := 0, loop A's columns 0 and 1 | O2:04A0..04BF tick >= floor(21x/4) (`pdos_tl_wait_tick`) |
| `PDOS_INTRO_PC_O2_04C1` | after loop A's tick wait | O2:04C1 kbhit: x := 999; O2:04CF x++; O2:04D2 test; column x (O2:04DC..0442: strip O2:04F7/051A, cues O2:0522..0602, credit O2:0605/0352..03B9, screen O2:03D4..043A), catch-up O2:0476..049D; or loop B (O2:0635) | the same, or loop B's |
| `PDOS_INTRO_PC_O2_082A` | after loop B's wait | O2:082A kbhit: x := 999; O2:0838 x++; O2:083B test; column x (strip O2:0847..0897, cues O2:089F..09A2, credit O2:09A7/063D..06A4, screen O2:06BF..0794), catch-up O2:07D0..07FA; or O2:09D7..0A51 (the shortcut read) | O2:07FD..0828 kbhit or tick >= floor((21x + 6720)/4) (`pdos_tl_wait_tick_or_key`); after the pan O2:0A19..0A23 tick >= 3,463 (`pdos_tl_wait_tick`), or with a key read the jump O2:0A16 to the cycles off O2:0B26..0B90 and the dissolve |
| `PDOS_INTRO_PC_O2_0A53` | after the logo wait | O2:0A53..0A81 the screen to page 1, the logo sprite at (0, 64); O2:0A90..0AAC slot 4 (224..239, rate 14) set up and started; O2:0AB4 x := 0; strip 0 (O2:0AB9..0AD7) | O2:0AE3 wait(1) (`pdos_tl_wait_frames`) |
| `PDOS_INTRO_PC_O2_0AE8` | after a reveal wait(1) | O2:0AEB x += 4; O2:0AEF strip x/4; after strip 79 O2:0AF6 the hold | wait(1); after the strips O2:0AF6..0B19 up to 100 x (kbhit, wait(5)) (`pdos_tl_wait_key_step(5, 100)`) |
| `PDOS_INTRO_PC_O2_0B1B` | after the hold | O2:0B1B flush (R:0403:4545), O2:0B20 DGROUP:6B32 := -1, O2:0B26..0B48 slots 1..4 stopped, O2:0B52..0B7B page 1 cleared and the logo drawn on it | O2:0B8B G#10(1, 20) (`pdos_tl_dissolve`), marked as the tail (`pdos_tl_tail`) |
| `PDOS_INTRO_PC_O2_0B90` | after the dissolve (or at once by finish) | O2:0B93..0BCA page 1 to the screen, G#31(0), font 1, the sprite freed; the hand-over | none: returns 0 (`PDOS_TL_DONE`) with `tl->pc = PDOS_INTRO_PC_TITLE` |

The preparation O2:01CD..0345 at t0: the screen black (O2:01E0); `LOGO.PIC` into page 1 with its palette
(O2:0223); the sprite grabbed G#2(1, 0, 64, 320, 80) (O2:023E); `BIRTH0.PIC` into page 1 with palette
(O2:0256) and its rows 76..99 copied to rows 176..199 (O2:027C); `BIRTH1.PIC` into page 2 (O2:028C) and
the same copy (O2:02B2); the `LOGO.PIC` palette (O2:02BE); rows 12..187 black (O2:02DC); slot 1 (146..152,
rate 14) set up (O2:02F4) and slots 1..3 started (O2:030B; 2 and 3 have rate 0 and stay stopped); the
CREDITS.TXT stream at record 0 (O2:0329); the tune S#1(3) (O2:0339: the tick and the 7-frame divider
restart, M7); DGROUP:BA06 emptied (O2:0345).

### Constants (C.5.5) and their listing addresses

| Constant | Value | Listing |
|---|---|---|
| `PDOS_INTRO_COLS` | 320 columns a loop | O2:04D2, O2:083B (cmp [bp-48h], 140h) |
| `PDOS_INTRO_RATE_MUL`, `_RATE_SHIFT` | 21, /4 (toward zero, 16-bit) | O2:047D..0491, O2:04A7..04BB, O2:07D7..07EE, O2:080D..0824 |
| `PDOS_INTRO_B_BASE` | 1A40h = 6,720 | O2:07DD, O2:0813 |
| `PDOS_INTRO_KEY_END` | 3E7h = 999 | O2:04CA, O2:0833 |
| cue columns and kinds | A: 10 (font 5 + line), 50 clear, 70, 120, 160 clear, 170..310 by 20; B: 10, 30, 50 clear, 64, 84, 116 clear, 130..290 by 20, 310 clear | O2:0522..05F3, O2:089F..099B (`g_cue_a`, `g_cue_b`, each row with its cmp's address) |
| credit font | 5 | O2:052C |
| credit layers | x 160; y 184 colour 252, y 182 colour 248, y 183 colour 250 (VGA) | O2:0352..03AF (O2:062F, 0371, 0395), O2:063D..069A (O2:09D1, 065C, 0680) |
| pan rectangles | strip page rows 176..199 from picture rows 64..87; screen 12..75 from rows 0..63; 76..99 the strip; 100..187 from rows 88..175 | O2:04E4..051A, 03DC..043A, 0847..0897, 06C6..0794 |
| `PDOS_INTRO_LOGO_TICK` | 0D87h = 3,463 | O2:0A1E |
| `PDOS_INTRO_LOGO_Y`, `_W`, `_H` | sprite rows 64..143, 320 x 80 | O2:022B..023E (grab), O2:0A76, 0B70 (draw at y 40h) |
| `PDOS_INTRO_STRIP_W` | 4 | O2:0AC8, O2:0AEB |
| `PDOS_INTRO_HOLD_PERIOD`, `_COUNT` | wait(5), 100 tests | O2:0AFD, O2:0B0C |
| `PDOS_INTRO_DISSOLVE_SRC`, `_C` | G#10(1, 20) | O2:0B83..0B8B |
| `PDOS_INTRO_TUNE` | 3 | O2:0339 |
| slots | 1: 146..152 rate 14 (O2:02E4..02F4); 4: 224..239 rate 14 (O2:0A90..0AA0); started O2:030B, O2:0AAC; stopped O2:0B40 | TIMING 5.6 |
| shortcut keys | 'N'/'n' 0, 'L'/'l' 1, 'E'/'e' 2, 'C'/'c' 3 into DGROUP:6B32 | O2:09F1..0A4F, O2:0A09..0A35 |
| `PDOS_INTRO_PRE_NONE`, `_PRE_KEY` | -2 (O2:09D7), -1 (O2:09E6, O2:0B20) | |

Data at run time through E's store: `pdos_pic(PDOS_F_LOGO_PIC / _BIRTH0_PIC / _BIRTH1_PIC)` (pixels and
the M0 palette) and `pdos_text_line(PDOS_F_CREDITS_TXT, i, &len)` with `pdos_text_count` (24 records;
past the end the buffer keeps what it holds, FORMATS 3.6). A missing or wrongly sized picture leaves the
page as it is and counts `PDOS_DIAG_FILE`; nothing faults.

### The hand-over point (C.6 to C.7)

The program ends where O2:0000 returns (O2:0BD6, after the show O2:0B93..0BCA): `pdos_intro_prog` returns
0, the timeline is `PDOS_TL_DONE` with `tl->pc == PDOS_INTRO_PC_TITLE`, `pdos_intro_at_title(tl)` is 1,
`tl->v.intro.f_title` is the frame (4,766 without a key; 146 frames after the cycles off otherwise) and
the step log ends with `show` (O2:0B93) and `title` (R:01A8:0486, arg = DGROUP:6B32). The next DOS step
is R:01A8:0008's call of the title menu R:01A8:0486 (the memory check between them is untimed, M2): the
box R:01A8:0494 unless a shortcut was taken (`pdos_intro_preselect(tl)` is 0..3), C.7, D4b2b's. At the
hand-over the screen is the logo on black (page 0 = page 1), the screen port's font is 1, slots 1..4 are
stopped, the DAC holds the rotated colours (C.6.5), and any key that arrived after the last read is still
pending in the timeline's queue (C.6.4 "Dissolve": the title box's R:1D05:0031 flushes it).

## Tests

`tests/test_timeline.c`, one program (`PASS|FAIL test_timeline: N checks, M failed`); the intro section
opens the store from `<gamedata>\..\dosdata` (`hh_set_dos_source`, `pdos_assets_open`), uses the store's
fonts, and closes it at the end. 49 checks were added to D4b1's 74.

* **Item 2, no key** (C.6.3; the listing's column formula): the start (tune at frame 0, columns 0 and 1
  at t0, slot 1 started, slots 2, 3 stopped); the 24 lines on frames 54, 422, 727, 1,034, ..., 3,729 with
  args 1..24 and the 5 clears on 299, 972, 2,259, 2,663, 3,852; font 5 with line 1; loop A ends on 1,952,
  loop B on 3,912; every one of the 640 columns on tick floor((21(x - 1) + b)/4); C.6.3's "column shown
  at tick S" rule; no catch-up (M9); no key read at O2:09D7 (-2); the logo wait from 3,912 to 4,040; the
  80 strips on 4,040..4,119; the hold from 4,120 to 4,620; flush, -1, cycles off (slots 1..4) and the
  dissolve on 4,620; show, hand-over and end on 4,766 (68.000007 s from t0; line 1 at 0.770458 s);
  723 waits in all (C.5.7's bound 724). Slot steps through the DAC: slot 1's 329th step by 4,613, its
  330th on 4,620, slot 4's 41st on 4,614, and no step after the stop (DAC ranges 146..152 and 224..239
  against the `LOGO.PIC` palette rotated by B's `pdos_cycle_advance`). Pixels against the store's
  pictures: the screen after 40 sample columns of both loops (the panned `BIRTH0`/`BIRTH1` rows and the
  black bands), the strip after each sample column equal to one built independently on a scratch page
  (the line in font 5 three times at y 184/182/183 in 252/248/250, or none between the lines), page 1
  with the sprite at 4,040, the reveal at 4,060 (strips 0..20 only), complete at 4,120, page 1 = logo on
  black at 4,620, the dissolve half-way (every pixel old or new), and the end (screen = page 1 = logo on
  black, font 1).
* **Item 3, skips** (C.6.4): 47 runs over the five phases, each with a random key code ('N', 'n', 'L',
  'l', 'E', 'e', 'C', 'c', `PDOS_KEY_ANY`, 'X', 'q') at 6 random instants a phase plus the boundaries
  (each phase's first and last microsecond, exactly at a test instant and one microsecond before it, the
  hold's last test): the column counts, the frame of the cycles off (loop A: the first column test after
  the key, with loop B's column 0 at that instant; loop B: the key's own instant; logo wait and reveal:
  4,120; hold: the next 5-frame test, or 4,620 after the last test; dissolve: 4,620), the four slot
  stops, the dissolve and the hand-over 146 frames later, the getkey and flush counts, DGROUP:6B32 (the
  shortcut only in the pan), both slots' DAC steps and the final screen. Also: 'L' one microsecond before
  frame 3,912 preselects item 1, at 3,912 itself it only ends the hold; two keys in the pan: the first is
  read, the second stays pending for the title box.
* **Item 6 on the intro** (C.6.6): finish in the dissolve completes it at once, the show and the
  hand-over run at the finish instant, nothing changes afterwards; abandon there leaves it half-way
  with no show; finish in the pan is a plain stop (pan and slot 1 frozen, no tail).
* **Item 4 on the intro**: 12 random tick partitions (ticks of 1 us .. 1 s) of 0..72 s in three
  scenarios (no key, a key in loop A, a key in the hold) against a reference ticked only at the inputs
  and 400 samples: identical step logs and identical machines (pages 0..3 and DAC hashed).
* **Item 7, intro part**: `pdos_rand_calls()` is unchanged over every intro run above (and counts one
  call of `pdos_srand` afterwards).

The intro section takes about 30 s (each full intro run draws about 27 million pixels through B's
primitives); the partitions about 6 s of it.

| Test | Checked | CheckedNoObs | Release |
|---|---|---|---|
| `test_timeline` | 123 | 123 | 123 |

## Results

The eight steps of the brief, 2026-10-12; logs `build/d4b2a-<n>-<step>.log`, status
`build/d4b2a-status.txt`; no Asan.

| Step | Result |
|---|---|
| 1 `build.cmd checked` | BUILD_OK, 211 s (270 portable sources: C11 + C17 `/W4 /WX` + clang C99 parse) |
| 2 `test.cmd checked` | TESTS_OK, 2046 s: `test_timeline` 123, REGISTRY_OK, NODOS_OK, P4_TESTS_OK, OBS_TABLES_OK, OBS_LINT_OK, `pdos_scene_check` 1075, P0_OK 279, EXT_FRAMES_OK, EXT_ADAPT_OK 20, MIRROR_OK 29, ZOOM_OK 32 |
| 3 `ext_g1.py check` | EXT_G1_OK runs 77 |
| 4 `build.cmd checked noobs` | BUILD_OK, 226 s |
| 5 `test.cmd checked noobs` | TESTS_OK, 837 s: `test_timeline` 123, NODOS_OK, OBS_TABLES_OK, OBS_LINT_OK, `pdos_scene_check` 1075, P0_OK 56 |
| 6 `ext_g1.py check --variant CheckedNoObs` | EXT_G1_OK runs 77 |
| 7 `build.cmd` (Release) | BUILD_OK, 201 s |
| 8 `test.cmd` (Release) | TESTS_OK, 365 s: `test_timeline` 123, NODOS_OK, OBS_TABLES_OK, OBS_LINT_OK, `pdos_scene_check` 1075 |

All eight green in one run (`build/d4b2a-status.txt` ends `ALL_GREEN`).

**P0.** No core value changed: P0_OK 279 (Checked) and 56 (CheckedNoObs), EXT_G1_OK on both observer
variants, EXT_FRAMES_OK. The new module
is not called by the profile; it includes no emulation header and reads nothing of the emulation
(OBS_LINT_OK; the include rule of `registry.py check` covers `pdos_intro.*`).

## Deviations from draft C

Format: section; what; why. The listing and the draft agree on every frame of C.6.3 and every reaction
of C.6.4 (no listing-over-draft correction was needed).

1. **C.6.1 (start).** The transcription starts at O2:01CD, after O2:01C8 (R:1DC4:0042, the C run time's
   srand, not presentation). Not modelled: G#27 MapLow16Colours at O2:020E (no B primitive; its DAC
   entries 0..15 are replaced at O2:02BE, `LOGO.PIC`'s M0 chunk covering 0..255, FORMATS 5), the sprite
   arena calls G#18/G#7 (O2:0216, 0249; D4a review F2), the sound bit O2:031C and the frame-counter clear
   O2:0334 (every wait(n) clears it, R:0182:0134). Why: no visible or timed effect on the model.
2. **C.6.2 (the EGA path).** Only the VGA path is transcribed (DGROUP:D762 != 0, `PdosMach.vga` 1): the
   EGA branches O2:0202, 03BB..03D2, 0442..0473, 06A6..06BD, 079C..07CD and 0B4A (page 3 and G#31 page
   flips, colours 7/15) are not. Why: the DOS profile models the VGA machine (draft B 3).
3. **C.5.2 (the listing's locals).** The logo sprite [bp-4Eh] (320 x 80, 25,600 bytes) lives in a
   caller-owned `PdosIntroCtx` (bound as the timeline's context; a module default when NULL), not in
   `PdosIntroVars`, which C.5.7 bounds at 32 words. DOS keeps it in the driver's sprite arena from the grab
   to R:1DC4:0523. B's `pdos_grab` builds it; the program copies it into the context and frees the grab
   at once.
4. **C.6.2 (the credit buffer).** DGROUP:BA06 is kept as the index of the record it holds (`text`, -1 when
   O2:0345/053C/... zeroed its first byte), and the record is read from the store at each drawing; the
   stream position DGROUP:D768 is `line`. Equivalent for strlen (O2:0605, 09A7) and the drawing; a
   record whose first byte is 0 counts as empty, as strlen does.
5. **C.6.4 (ties).** "The first key test at or after the key" follows D4b1's Deviation 5: a key arriving
   at the very microsecond of a frame-instant test (O2:04C1, the hold's tests, O2:09D7 at frame 3,912)
   is seen by the next test. So a shortcut counts when it arrives before the instant of frame 3,912; one
   at that instant only ends the hold. The tests assert both sides.
6. **C.6.6 (finish in the pan).** Finish outside the dissolve is a plain stop (the pan and slot 1
   freeze, no hand-over), as C.5.2 names the dissolve as the only tail. Showing the title box with the
   core's choice when the core leaves the title while the DOS pan still runs (C.6.6 bullet 2) is the
   sequencer's (D4b2b).
7. **C.15.1 item 7.** An equivalent counter (`pdos_rand_calls`, added to D4a's `pdos_rand.c`) instead of a
   link-time stub: `build.cmd` links every portable object, `pdos_rand.obj` included, into each test, so
   a stub would be a duplicate symbol.
8. **C.15.1 item 4 on the intro.** 12 partitions of 0..72 s with 400 samples each, not 200 with 1,000:
   a full intro run costs about 0.35 s. D4b1's 200 partitions on its test program remain.
9. **Step log names.** The intro logs `prepare`, `column_a`, `column_b`, `font`, `line` (arg: the record
   number, 1-based; 0 at the end of the file), `clear`, `catch_up`, `loop_a_end`, `loop_b_end`,
   `preselect` (arg DGROUP:6B32), `logo`, `strip` (arg 0..79), `logo_page`, `show`, `title`, with the
   engine's own (`tune`, `cycle_*`, `wait*`, `getkey`, `flush`, `dissolve`, `tail`, `end`). C.15.3's
   `timeline.log` writer and its golden are D4b2b's.

## What D4b2b must know

* **Starting the intro.** One `PdosIntroCtx` (static, about 25 KB) and the profile's `PdosTlSession`:
  `pdos_intro_bind(&tl, pdos_mn(), &ses, &ctx)`, `pdos_tl_set_log(&tl, sink, sink_ctx)`, then
  `pdos_intro_start(&tl, t0)` at the probe CreateSequencePlayer 10B0:008A entry with ra 11E0:00A5
  (C.6.1). The program draws on the machine as it finds it (DOS's mode set and port initialisation are
  `pdos_mach_reset`); it loads pages 1 and 2 and the DAC itself. `pdos_tl_run(&tl, t)` before every event
  or probe and at every tick; keys with `pdos_tl_key(&tl, t, PDOS_KEY_ANY or 'N'/'L'/'E'/'C')` (C.6.4's
  two sources; the filter decides what reaches it); `pdos_tl_finish` when the core leaves the title or
  starts Birth while the intro runs (C.6.6).
* **Taking over at the title box.** At `pdos_intro_at_title(&tl)` (state DONE, pc `PDOS_INTRO_PC_TITLE`,
  frame `tl.v.intro.f_title`) the title menu R:01A8:0486 is next, at the same instant. Its phrase
  boundary R:01A8:04C2..04DA polls the same tune's tick (TIMING 5.4: the counter keeps counting from
  O2:0339), so continue in this timeline: replace the `return 0` after the `title` step in
  `pdos_intro_prog` with the title box's labels (or start a title timeline with `tune_frame` and `tune`
  copied from this one). `pdos_intro_preselect`: 0..3 skips the box (R:01A8:0494), -1 shows it. Pending
  keys are in `tl.keyq_*` (the box flushes them, R:1D05:0031 with flag 1). Without a key the hand-over is
  at frame 4,766, the tick then `pdos_ticks_after(4766)` = 4,086.
* **C.6.5.** `tl.v.intro.f_off` (cycles off) and `f_logo` (slot 4's start, `PDOS_NONE` when skipped) give
  the title palette's step counts floor(F_off / 14) and floor((F_off - F_logo) / 14); the DAC already
  holds them.
* **D4a's S3/S6/S7/S9** are untouched by this unit (no macro, no shadow, no profile wiring).

## For the records

Entries for the documents this unit does not edit.

* **DESIGN.md 12.8 (area C)**: D4b2a delivered `pdos_intro.h/.c`: the DOS intro, credits and logo
  (O2:01CD..0BD6) as a timeline program with seven resume labels named after the listing addresses
  (`PDOS_INTRO_PC_*`), `PdosIntroVars` in `pdos_tl.h`, the logo sprite in a caller-owned `PdosIntroCtx`
  (Deviation 3), VGA path only (Deviation 2); the hand-over to the title menu R:01A8:0486 is the
  program's end (`PDOS_INTRO_PC_TITLE`); only the dissolve is a finish tail. `pdos_rand_calls()` counts
  the DOS generator's calls for tests. Not wired into the profile until D4b2b.
* **FIDELITY.md**: the DOS intro's timing is "DOS listing (model)": on the clock model of D4b1 the 24
  credit lines fall on frames 54 .. 3,729, the logo wait ends on 4,040, the strips on 4,040..4,119, the
  hold ends on 4,620, the title on 4,766 (68.000 s), slot 1 makes 330 steps and slot 4 41 (C.6.3); keys
  end the pan at the next column test (loop A) or at once (loop B), the logo phase at the hold's next
  5-frame test, and do nothing in the dissolve; a shortcut letter counts only before frame 3,912 (C.6.4;
  a key at the very instant of a test is seen by the next one). Not modelled: the EGA path, G#27's low-16
  map (no lasting effect), the sprite arena. The credits are drawn from CREDITS.TXT with font 5 as
  three centred layers (252, 248, 250). No original timing or pixel comparison was made (the DOS
  oracle is optional and not run).
* **STATUS.md**: D4b2a done: `pdos_intro` with `test_timeline` items 2, 3, 7 (intro part) and items 4 and
  6 on the intro (123 checks in Checked, CheckedNoObs and Release); the DOS profile's output is unchanged
  (not wired yet); the 8-step cycle green (see Results).
* **RUNNING.md**: `test_timeline.exe <gamedata> <outdir>` now reads the DOS copy `<gamedata>\..\dosdata`
  through the store (it fails when the copy does not open), takes about 30 s more, and writes
  `timeline-intro-steps.txt` (the intro's no-key steps) and an intro line in `timeline-partitions.txt`.
* **FEATURES.md, DOS-PROFILE.md, manual-checklist-ext.md**: nothing (no visible change).

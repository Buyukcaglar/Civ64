# Extension phase D4, unit D4b3 (DOS Birth) - record

Unit D4b3 of the "civ64" extension covers four things:

* the DOS Birth program of draft C C.8, with C.8.3's step function O7:17CF..1BB8 transcribed exactly
  (Open C-5);
* the post-Birth transition;
* the wiring of both into the sequencer, with the Birth view and the pointer rule;
* the logical-text part of the D4a second review's F2.

Tests: C.15.1 items 5 and 7 (Birth part) and item 4 on Birth, and the `ext_timeline.py` `birth` runs of
C.15.3.

Design: [verify/ext-d1-draft-C.md](verify/ext-d1-draft-C.md) C.8.1..C.8.8, C.11.3, C.11.5, C.11.6,
C.15.1, C.15.3; [verify/ext-d1-draft-B.md](verify/ext-d1-draft-B.md) 10.1 (F2). Brief:
[verify/BRIEF-d4.md](verify/BRIEF-d4.md), "D4b split" (the D4b3 bullet). Preceding units:
[ext-D4b2b2-record.md](ext-D4b2b2-record.md), [ext-D4b2b1-record.md](ext-D4b2b1-record.md),
[ext-D4b2a-record.md](ext-D4b2a-record.md), [ext-D4b1-record.md](ext-D4b1-record.md),
[ext-D4a-record.md](ext-D4a-record.md) ("Second review").

This record replaces the restart notes of 2026-10-12. Their listing reading is kept under "Listing facts".
Session D4b3, 2026-10-15.

Labels:

* **compiled**: the three language checks and `/W4 /WX`.
* **headless**: unit tests and harness runs.
* **DOS listing (model)**: the Birth frames, from the clock model of C.4 and the listing's control flow. No
  DOS-oracle comparison was made.

Sources and scope:

* Every constant cites its listing address (`build/dos/disasm/ovl07.lst`, `root.lst`).
* STORY.TXT, the pictures, the palettes, BIRTH_CYCLE, BIRTH_SCHEDULE and the two DGROUP ranges named below
  are read from the store at run time. They are in no source or test.
* No DOS program was executed. Nothing was written to `C:\Projects\Civ1RE\dos`, `build/dosdata` or
  `C:\Projects\Civ1RE\original`. No UI was shown by this unit. No DOS byte is in the repository or a binary
  (NODOS_OK). No git command that writes was run. Asan was not built or run.
* Not edited: `platform/w16/*`, `core/`, `rt/`, the generated tables, `tests/test_user.c`, `p4tests.py`,
  `ext_g1.py`/`ext-g1-*.txt` and every document other than this record. Every probe and call site used was
  already in `OBS_CALLSITES` (SetGameCursor ra 11E0:094E; BeginWorldCreation ra 11E0:01B2).

## Status

DONE. The DOS view shows DOS Birth from the core's Birth start, at its own pace on the game's virtual time:

* the story of STORY.TXT (44 text lines and 8 pictures with their colour cycling);
* then the post-Birth fade and the cleared screen of R:01A8:087C, held until the core reaches its setup
  (T4);
* when the core leaves Birth first (its skip), DOS Birth is abandoned and the post-Birth fade runs from that
  instant.

The pointer is hidden throughout, up to R:01A8:0875. The user visually accepted the DOS Birth scenes on a
build that contained this unit's code ("For the records"). The final cycle, which also covers P47-R2's
changes, is in "Results".

## What was built

### The Birth program (`present/dos/pdos_birth.h/.c`)

The program is C.8 run by D4b1's engine on `pdos_mn()`. It transcribes the following at the level of their
waits:

* O7:0012..0055 (the caller's preparation);
* the step function O7:17CF..1BE2;
* O7:05A0..05D3 (the caller's loop end);
* the post-Birth transition R:01A8:0533..0875.

The VGA path only (DGROUP:D762 != 0); the EGA branches O7:19FA, 1A2E, 1A66 and 1B99 are not.

Resume labels (`PdosBirthPc`), each named after the address the program resumes at:

| Label | Resumes |
|---|---|
| `START` | O7:0012 at t0 (or the post-Birth start for a `PDOS_SEQ_FX_FADE` timeline) |
| `O7_17CF` | the next call that does anything: at the due tick |
| `O7_17E4` | the next BUILDING call |
| `O7_18F3` | after the dim's wait(5) |
| `O7_195E` | after wait(10) |
| `O7_197F` | after the text's wait(5) |
| `O7_1A41` | after the fade to black |
| `O7_1A9B` | after the fade to BIRTHn.PAL |
| `O7_1B7C` | after the end's wait(180) |
| `R_01A8_0848` | after the post-Birth fade |
| `SETUP` | the program ended at R:01A8:087C |

The step function's words are in `PdosBirthVars` (`pdos_tl.h`):

* DGROUP:3B62 state, 3B64 next picture, 3B66 cycle offset, 3B68 slots;
* DGROUP:6800 "now", 6802 lines, 6804 stream, 6806 due;
* BA06 as a record index or `PDOS_BIRTH_TEXT_EMPTY`/`_FADE`;
* fscanf's result, the frame of the last frame-counter clear, AX of the last return, the BUILDING flag, the
  post flag, and the frames of the story's end and of the hand-over.

M12, "called at every instant", is modelled as waits:

* **Between events.** A call returns at O7:18B9 before the kbhit test while `now < due`, so it changes
  nothing. The program waits `PDOS_W_DUE` for the due tick: not key-sensitive and not wakeable, exactly as
  the listing.
* **After the story, with the world running (states 2..5).** The calls that change the screen are those at
  the BUILDING blink's quotient changes, at a key (the event path) or at the world flag. This is the new
  engine wait `PDOS_W_FRAMES_OR_KEY` (`pdos_tl_wait_frame_or_key`), marked wakeable.
* **Returns of 0 with the world done.** They end the O7:05A0 loop, and the post-Birth steps follow at the
  same instant.
* **A return of 1 before the first text line with due > 0.** "now" stays 0 and would never become due, so
  this is a hold (`pdos_tl_hold`). It is not reached with the store's STORY.TXT.

Constants (C.5.5), each in `pdos_birth.h` with its listing address:

| Constant | Value | Listing |
|---|---|---|
| text centre | (160, 160) | O7:183E, 18D6, 1962, 1983 |
| font | 7 | O7:1896 |
| dim colour | 3 | O7:18D2, 195E |
| bright colour | 0Bh | O7:197F |
| dim while fewer lines than | 28h | O7:18CB |
| waits | 5 / 0Ah / 5 / 0B4h | O7:18E7, 1952, 1973, 1B70 |
| marker length max | 3 | O7:19A6 |
| long line | > 13h | O7:1B35 |
| w per text line | 2 | O7:19CF |
| due multiplier | 2Dh | O7:1B42 |
| due upper bound | 7FFFh | O7:1B3E, R:1DC4:007C |
| tunes | 1 and 4 | O7:19B7, 19C3, 1B88 |
| fades | 8 steps | O7:1A35, 1A8F |
| cycle rate | 12Ch / speed | O7:1AD8 |
| strip | (0, 160, 320, 8) | O7:193F, 1937 |
| last state | 5 | O7:17ED |
| BUILDING clear | (40, 160, 240, 8) | O7:1806, 180E |
| blink divisor and colours | 3Ch; 0Fh else 3 | O7:1826, 1835 |
| post-Birth font | 1 | O7:05AC |
| post-Birth fade | 5 steps | R:01A8:083C |
| map slots | 15, 60h..67h, 68h..6Fh, 70h..7Fh | R:1DC4:05DD..0619 |

Data at run time:

* `pdos_text_line(PDOS_F_STORY_TXT)`, `BIRTH1..8.PIC/.PAL` (ids consecutive from `PDOS_F_BIRTH0_*`),
  `SP299.PIC`, `SP257.PIC` and `MAP.PIC`, the tables `BIRTH_CYCLE` and `BIRTH_SCHEDULE`.
* Two DGROUP ranges that have no registry row, read with local `PdosTableDesc` descriptors through
  `pdos_table_resolve`: the initial words DGROUP:3B62..3B69 and the string DGROUP:3B28 ("BUILDING NEW
  WORLD...", O7:1843).
* A failed read counts `PDOS_DIAG_FILE` / `PDOS_DIAG_TABLE` and leaves the page or the value as it is.

Pure presentation: no emulation and no clock source. `pdos_rand` is never called (item 7).

### The post-Birth transition (C.8.7, C.8.8)

In order:

1. O7:05A8: font 1.
2. O7:05C6: the current port's page (page 1, the generation's) copied to page 2.
3. R:01A8:0533: the port back on page 0.
4. G#31(0).
5. `SP299.PIC` into page 1, and its part (160, 50, 160, 150) into page 2.
6. DGROUP:2F98 := 1.
7. The 5-step fade to black (30 frames).
8. R:01A8:085B: page 0 cleared.
9. `SP257.PIC`'s palette.
10. The map's slots 1..3 prepared (not started).
11. The pointer step R:01A8:0875.
12. The hand-over R:01A8:087C (`pdos_birth_at_setup`).

After an abandoned Birth, `pdos_birth_post_start` runs these steps alone on a second timeline (sequence
`PDOS_SEQ_FX_FADE`). The abandoned call is taken as having returned at O7:1BC9, with the port on page 1.

### The sequencer (`pdos_seq.h/.c`, C.11.3, C.11.5, C.11.6)

| Core probe | DOS Birth |
|---|---|
| SeekSequence 10B0:005B entry, ra 11E0:01AA | the intro finished (C.6.6), its view off; Birth bound to `pdos_mn()` and the DOS run's session, started at the probe's time (t0, T1); DGROUP:67FC := 0 (O7:0034), D76A := the core's title choice == 2 (EARTH); the Birth view on |
| BeginWorldCreation exit (any site; ra 11E0:01B2) | 67FC := 1 and `pdos_tl_wake` (C.8.1, C.8.6) |
| SetGameCursor entry, ra 11E0:094E (new row `SR_SKIP_BIRTH`) | the core's Birth skip: `pdos_tl_key(birth, ANY)` while the story runs; consumed during the post-Birth steps; `PDOS_DIAG_SEQ` with no Birth started |
| DestroySequencePlayer entry, ra 11E0:01E8 | a Birth still in its story: abandoned, and the post-Birth steps start on the second timeline at that instant; a Birth already past O7:05A0, or abandoned: nothing (C.8.8, T4) |
| RunNewGameSetup entry, ra 11E0:020A, or play | the Birth view ends once the hand-over is reached (else when it is reached); a Birth still in its story there is C.11.6 (abandoned, `PDOS_DIAG_SEQ`) |

Other changes:

* **The Birth view.** From Birth's start, scene rows 9 (Birth), 3 and 5 (the world creation above it),
  1, 25 and 2 (below it) and 21 (dialog 144) are ready N rows. The intro view keeps 1, 25 and 2; a row is
  ready when either view needs it (`rows_apply`).
* **C.11.6.** A MenuZ of unknown kind during Birth's story abandons it. `unexpected()` now abandons every
  DOS timeline.
* **Pointer.** `pdos_seq_pointer_hidden()` is 1 while the intro, Birth or the post-Birth timeline runs.
  R:01A8:0511 hides the pointer before O7:0012; Birth's program shows it at R:01A8:0875 and ends.
* **View keys.** `pdos_seq_view_key` (source 2, D4c) goes to Birth's story.
* **Frame watch.** `pdos_seq_set_birth_watch` is Birth's frame watch, on Birth's grid. The two watches are
  served in time order.
* **Accessors.** `pdos_seq_birth()`, `pdos_seq_birth_post()`, `pdos_seq_birth_view()`.

### F2: the font tracker per graf and logical text (`pdos_fontmap.h/.c`)

* **Tracker per graf.** SetCivFont and SetTextFontSizeColor are now noted on the graf they set the font on.
  The graf is g_graf 1420:9960, a far pointer read with `w16q_rd32` at the probe. SetTextFontSizeColor's
  size is recorded too. `pdos_fontmap_current_on(graf, &id, &size)` answers per graf, and the tracker keeps
  the 8 grafs noted last. The old `pdos_fontmap_note`/`current` API is kept (graf unknown).
* **Logical text.** `pdos_fontmap_logical(ra, &id)` reads the logical text's font: word +10h of
  *g_pScreenPort (g_pScreenPort 1420:2990, a far pointer to g_screenPort 1420:297E;
  `OF_ScreenPort_fontId`). The read is through `w16q_*` under `CIV_OBSERVER`, and the result is mapped by
  the pure `pdos_fontmap_port_font`.
* **Leader faces.** The leader-face part (`g_playerCivId[n]` rather than `id - 200`) is not done. It is
  D7's, with the leader table.

### The harness (`tests/headless`)

* `--dos-birth-watch F,F,..` (at most 16 frames of Birth's grid) writes `bwatch frame F us U sha256 SHA`
  to `timeline.log`.
* `timeline.log`'s probe lines now include BeginWorldCreation.
* Birth's steps are sequence 2 and the post-Birth timeline's are sequence 3.

## Listing facts (the listing wins over draft C)

1. **C.8.3, the dim step.** It is skipped only when the state is exactly 2 or at least 40 lines were shown
   (O7:18C4..18D0). The first event (a marker; BA06 is "" from O7:188A) has the dim step, so the first
   picture event takes 5 + 10 + 5 + 49 + 48 = 117 frames.
2. **C.8.6, the blink phase.** The frame counter is cleared at the *start* of every wait()
   (R:0182:0134 calls R:0000:033E first) and at O7:19B2. The BUILDING quotient therefore counts from
   wait(180)'s start: the first BUILDING draw is colour 15 (quotient 3), then 3, 15... every 60 frames.
3. **A key pending in state >= 2 takes the event path.** O7:17DD..17EB tests kbhit before the BUILDING
   branch, re-reads S#5 (restarted by the end's S#1(1)) and, at the old due tick, reads the closed stream
   and waits 180 frames again. So a key with the world running stops the BUILDING blink.
4. **DGROUP:BA06 is also the fade target** (TIMING 3.5). After a picture, the dim step and the O7:1B29
   length test read the palette bytes (first entry black, so length 0 and w = 0, as C.8.2 says).
5. **EARTH.** O7:0034 sets 67FC = 0 for every branch. SCENES 7.3's and DOS-PROFILE row 5's "already
   skippable" is not what the listing shows during O7:0A33; the draft's "the flag follows the core" stands.
6. **Strings.** "BUILDING NEW WORLD..." (DGROUP:3B28) and the setup text (DGROUP:3526) have no E registry
   row. 3B28 is read with a local descriptor; 3526 is D5's.
7. **The schedule.** O7:19D4 increments the line count before O7:1B4E reads T[lines]. A picture line keeps
   the count. "now" is DGROUP:6800, refreshed from S#5 only once a text line was shown (O7:18A1).

## Tests

* **`tests/test_timeline.c`.** 148 checks; the Birth section is new (D4b3 part about 25). It drives
  `pdos_birth.c` directly on the store's files. It reads the step log back:
  * the story with the world done: one event per STORY.TXT record and the end of the file (53 events: 44
    text lines, 8 pictures);
  * each event's duration from its waits: 20 or 15 frames for a text line (15 from the 40th line), a
    picture 96 more and +1 for the session's first fade;
  * the due value against C.8.2's formula on the store's `BIRTH_SCHEDULE` and the line lengths (both
    clamp sides occur);
  * each next event at the tune frame + `pdos_tick_frame(due)`;
  * the tune restart at the first text line;
  * the end's wait(180);
  * the post-Birth steps and their screen: page 0 black, SP257's palette, SP299 in page 1 and its part in
    page 2, the box texture, font 1, the map slots prepared but not running;
  * BUILDING with the world running: states 3..5 and the clear at once, seven blinks with the colours of
    O7:1820..1847, then the world's wake, one more draw and the post-Birth steps;
  * a key during the blink: the event path, no more BUILDING;
  * the skip only with the world done: at the next event's read, no wait(180), the same log up to it;
    with the world running the key changes nothing in the story;
  * EARTH's MAP.PIC with palette at t0;
  * the post-Birth steps alone (FX_FADE);
  * item 4 on Birth: 12 random tick partitions of the whole story in three scenarios give identical logs
    and machines at 400 samples;
  * item 7: `pdos_rand_calls` unchanged.
* **`tests/test_pdos_seq.c`.** 97 checks. `test_birth_start` now expects the N frame and DOS Birth's start,
  and finds "finish" as the intro's last step (Birth's steps follow in the same log). The new
  `test_birth_seq` compares the sequencer's Birth with DOS Birth driven directly on a copy of the screen the
  intro left: equal steps and machines. It covers:
  * t0 at the probe;
  * the world's end;
  * the core's skip as a pending key;
  * the core's Birth end: abandon and the post-Birth timeline, or DOS's own skip;
  * the setup during the fade (the view stays);
  * a view key consumed;
  * the view's end, and the pointer hidden then shown;
  * T4: the story first and the hand-over held in Birth; the core's Birth end then starts nothing; the
    setup ends the view (A frame);
  * EARTH from title choice 2;
  * C.11.6: setup during the story; a skip or Birth end without Birth.
* **`tests/test_pdos_scene.c`.** 126 checks, with new F2 vectors:
  * text on graf A after a note on graf B answers A's font;
  * the size;
  * a later note replaces only its graf's;
  * eviction after 8 grafs;
  * the port word mapped at its site;
  * the noobs build reads nothing.
* **`tests/harness/ext_timeline.py`.** Three new runs: `birth`, `birth_switch` and `birth_skip`. The
  checks are as in its docstring. `ext-timeline-golden.txt` gains 8 `bgolden` lines, the Birth model
  goldens at Birth frames 20, 69, 117, 1500, 4000, 7000, 10000 and 12000, recorded with `--record` by this
  unit. Frames 69 (the end of the first fade to black) and 12000 (after the hand-over) are the black frame.

Figures from the `birth` run (p4-birth):

| Item | Value |
|---|---|
| Birth t0 | 22,687,300 us (the probe) |
| world done | 23,755,050 us |
| events | 53 |
| tune restart | frame 137 |
| story end | frame 10,463 (149.283 s) |
| hand-over | frame 10,493 (149.711 s) |
| the core's Birth end | 198,225,850 us (175.539 s after t0) |
| shows during Birth | 2,669 of 2,669 are the 320x200 N frame |
| after the core's setup | the A frame (640x480) |

`birth_switch`: 2,049 equal DOS samples and equal core outputs (1,928 lines).

`birth_skip`: the core's skip, its Birth end and its setup all at 24,113,350 us. DOS Birth was abandoned
there at frame 99, in picture 1's fade-in. The post-Birth timeline handed over 30 frames later
(24,541,382 us). The 25 shows during it are the N frame; the next show is the A frame.

## Results

The eight steps of the brief ran on 2026-10-15, in one run after the last source change. Logs are
`build/d4b3-<n>-<step>.log`, and the status file `build/d4b3-status.txt` ends `ALL_GREEN`. No Asan.

**This cycle covers P47-R2's changes too** (orchestrator, 2026-10-15). Those are `platform/w16/user_wnd.c`,
`tests/test_user.c`, `p4tests.py` with the new runs `p49-findcity-bar`, `p49-pedia` and
`p49-pedia-units`, `ext_g1.py` with `ext-g1-amend.txt`, and `ext_p0.py`, which were in the tree for all
eight steps:

* `test_user` 331 checks, 0 failed (steps 2, 5, 8);
* all 17 `PASS` lines of the three new `p49-*` runs in steps 2 and 5;
* P4_TESTS_OK;
* `EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)` on both observer variants;
* P0_OK.

No failure appeared in P47-R2's area.

| Step | Result |
|---|---|
| 1 `build.cmd checked` | BUILD_OK, 199 s (272 portable sources: C11 + C17 `/W4 /WX` + clang C99 parse) |
| 2 `test.cmd checked` | TESTS_OK, 2099 s: `test_pdos_seq` 97, `test_pdos_scene` 126, `test_pdos_shadow` 135, `test_pdos_ui` 34, `test_pdos_profile` 38, `test_pdos_cursor` 62, `test_timeline` 148, `test_user` 331, REGISTRY_OK, NODOS_OK, GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK, P4_TESTS_OK, OBS_TABLES_OK (probes 203, sites 98), OBS_LINT_OK, `pdos_scene_check` 1075, P0_OK 279, EXT_FRAMES_OK, EXT_TIMELINE_OK, EXT_ADAPT_OK 20, MIRROR_OK 29, ZOOM_OK 32, TRACE_OK |
| 3 `ext_g1.py check` | EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) |
| 4 `build.cmd checked noobs` | BUILD_OK, 216 s |
| 5 `test.cmd checked noobs` | TESTS_OK, 796 s: `test_pdos_seq` 97, `test_pdos_scene` 127 (with the no-observer F2 check), `test_pdos_shadow` 133, `test_pdos_ui` 34, `test_pdos_profile` 36, `test_pdos_cursor` 62, `test_timeline` 148, `test_user` 331, NODOS_OK, P4_TESTS_OK, OBS_TABLES_OK, OBS_LINT_OK, `pdos_scene_check` 1075, P0_OK 56, TRACE_OK |
| 6 `ext_g1.py check --variant CheckedNoObs` | EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) |
| 7 `build.cmd` (Release) | BUILD_OK, 209 s |
| 8 `test.cmd` (Release) | TESTS_OK, 429 s: `test_pdos_seq` 97, `test_pdos_scene` 126, `test_pdos_shadow` 135, `test_pdos_ui` 34, `test_pdos_profile` 38, `test_pdos_cursor` 62, `test_timeline` 148, `test_user` 331, NODOS_OK, OBS_TABLES_OK, OBS_LINT_OK, `pdos_scene_check` 1075, TRACE_OK |

**`ext_timeline.py` in step 2 (without `--record`).** All 29 checks pass (the figures under "Tests"), so
the Birth model goldens recorded during development are confirmed. The `bgolden` lines were recorded with
`--record` in the development run (`build/d4b3-dev-timeline-record.log`, EXT_TIMELINE_OK) before the cycle,
and step 2 compared against them.

**P0.** No core value changed:

* P0_OK 279 (Checked) and 56 (CheckedNoObs);
* EXT_G1_OK on both observer variants, EXT_FRAMES_OK, EXT_ADAPT_OK;
* `birth_switch`'s equal core outputs (1,928 lines) between the DOS-visible and the switching run.

What this unit's code does:

* `pdos_birth.c` reads only the store and `pdos_mn`.
* `pdos_seq.c` reads the emulation only through the probe arguments, `w16q_ret_ax` and `w16q_rd16`.
* `pdos_fontmap.c` reads through `w16q_arg16`, `w16q_rd32` and `w16q_rd16`, under `CIV_OBSERVER` inside
  the observer's guard.
* None of them posts anything, reads `g_randSeed` or draws a random number (OBS_LINT_OK, `registry.py
  check`'s include rule, item 7 in `test_timeline`).

## Deviations from draft C

Format: section; what; why.

1. **C.8.7, C.15.1 item 5 (the T4 next screen).** When the DOS story ends first, the view holds the
   cleared screen of R:01A8:087C, which is black with SP257's palette. It does not show
   `SETUP_PAGE(0, row 0)`, and "a choice on that page = Birth skip + choice" (C.13.6 example 4) is not
   implemented. Why: the setup page is D5's renderer (B 11.5), and its text DGROUP:3526 has no registry
   row; the brief gives D4b3 no setup page. The hold lasts about 26 s in p4-birth (DOS 149.7 s, the core
   175.5 s). The user noticed it, and D4b4 will give the core its skip there.
2. **C.8.5 / M12 (the calls at every instant).** These are modelled by the waits described under "What was
   built", including the new engine wait `PDOS_W_FRAMES_OR_KEY`. Why: no timer-driven polling; the state
   at any time still depends only on the inputs (item 4 on Birth).
3. **C.8.6 (blink phase).** The phase counts from wait(180)'s start, not its end (listing fact 2). With a
   key pending, the blink stops (listing fact 3).
4. **C.8.1 (EARTH).** D76A comes from the core's title choice 2 (its MenuZ result), and 67FC = 0 at every
   Birth start (listing fact 5).
5. **C.8.8 (the post-Birth steps after an abandon).** They run on a second timeline (sequence
   `PDOS_SEQ_FX_FADE`), with the abandoned call taken as returned (port on page 1). The whole
   R:01A8:0533..087C runs, not only the fade (the page copies, SP299, the clear, SP257). Why: those are the
   DOS steps between the fade and the setup, and they set the screen and palette the setup starts from.
6. **The Birth view's rows** are 9, 3, 5, 1, 25, 2 and 21 (draft C names only Birth's). Why: the core's
   world creation pushes 3 or 5 above 9, and after its Birth end the stack's top is 1, 25 or 21 while the
   post-Birth steps still show.
7. **A closed stream** (a read after the end, listing fact 3's path) is taken as fscanf's -1. This is
   inferred: fscanf on a closed `FILE` is undefined in C, and the listing gives no other path.
8. **Not modelled:**
   * the EGA branches;
   * the DOS world generation's own drawing into page 1 (O7:006B, O7:058E; C.8.1 replaces it with the
     core's);
   * R:01A8:02A4 (O7:0024, R:01A8:0588) and O5:1455, which have no visible output;
   * the sound (S#1's tunes only restart the tick, M7).
9. **C.11.6.** A Birth skip probe with no Birth started counts `PDOS_DIAG_SEQ`. This includes the probe at
   ra 11E0:094E during the intro in `test_skip_and_title_exit`. `unexpected()` abandons Birth and the
   post-Birth timeline as well as the intro.
10. **F2.** The tracker keeps 8 grafs (least recently noted dropped). The leader-face part of F2 stays
    open for D7.
11. **S3** (D4a second review) is still open. This unit registers no macro; Birth draws on `pdos_mn` from
    the sequencer.

## What D4b4 must know (Birth auto-continue)

**Where DOS Birth's end is detected**

* In `pdos_birth.c`, `story_close()` runs at O7:1BB8, after the end of the file and its wait(180), or at
  the DOS skip. It sets `v.birth.state = 2` and `v.birth.f_end = frame`, and logs the step `story_end`.
* With the world done, the same instant continues:
  * `calls()` logs `birth_end` (O7:05A4);
  * `post_begin()` sets `v.birth.post = 1` (`pdos_birth_in_post`) and starts the 5-step fade;
  * `post_end()` runs at f_end + 30 frames: label `PDOS_BIRTH_PC_SETUP`, `v.birth.f_setup = frame`, step
    `setup` (R:01A8:087C), state `PDOS_TL_DONE` (`pdos_birth_at_setup`).
* The instant of the hand-over is `g_birth.grid.t0_us + pdos_frame_us(&g_birth.grid, f_setup)`. In
  p4-birth: story end at frame 10,463, hand-over at frame 10,493 (149.711 s after t0).
* In `pdos_seq.c`, the natural hook is `birth_check()`. It is called from `run_to()` after every timeline
  run, at every tick, event and probe, with time already advanced. There,
  `pdos_birth_at_setup(&g_birth) && g_core.scene == PDOS_CS_BIRTH` means "the DOS Birth's visible end came
  first, the core is still in Birth".
* With the world still running at the story's end, DOS shows BUILDING. There is no hand-over until
  BeginWorldCreation's exit; this never happens in practice (the world is done about 1.07 s into Birth).
* The DOS skip path (O7:1912) gives the same `story_end` / `setup` steps without the wait(180).

**How the core's state is observed**

* `g_core.scene == PDOS_CS_BIRTH` from SeekSequence entry ra 11E0:01AA until RunNewGameSetup entry ra
  11E0:020A.
* `g_core.world_done` from BeginWorldCreation's exit (ra 11E0:01B2).
* Scene row 9 is on the stack until DestroySequencePlayer entry ra 11E0:01E8, the core's Birth end.
* "Birth movie still playing, world done" is: scene BIRTH, world_done, and no DestroySequencePlayer
  ra 11E0:01E8 yet. While in it, the core loops at 11E0:01BD..01DB on `AdvanceMovie` until
  `g_movieSkipRequested` or the movie's end.
* The flag is set only in BirthMovieCallback 11E0:091E. On movie frames with `frame % 30 == 0` it calls
  `PumpMessagesCheckSkipInput` (11E0:093F); on skip input it calls SetGameCursor(84h) (the probe ra
  11E0:094E) and sets the flag.

**What would make posting the core's skip unsafe**

* **P0.** The DOS profile posts nothing, and reads only through `w16q_*`. A posted skip changes the core's
  run: its virtual time, events, `run.log` frames, and the G-1 baselines (`ext_g1`, `ext_p0` V0 `birth`).
  If the skip depends on the visible profile, the core's outputs differ between profiles. That breaks T2/P0
  as checked by `ext_timeline.py`'s `birth_switch` (equal core outputs) and `ext_p0`'s switch runs. It needs
  an explicit user exception and a decision: only when the DOS view is visible, or whenever the DOS profile
  is registered. Either way, the affected baselines change.
* **Delivery.** Posting must happen through area A's input path at a host sync (as I4's translations do),
  never inside an observer callback. The probes run inside the emulation, where `w16q_*` only reads. It
  must also happen at a deterministic virtual time, for example the first sync at or after the hand-over's
  instant.
* **Latency and which input counts.** The core sees skip input only at movie frames divisible by 30. The
  input must be one `PumpMessagesCheckSkipInput` accepts, and its release and any WM_CHAR must not leak
  into RunNewGameSetup's first MenuZ (dialog 144 step 0). A stray Enter or character there chooses a
  difficulty. Check the core's flush: MenuZ flushes at 1220:0248 at entry, so a release arriving after it
  still reaches MenuZ.
* **Guards.** Do not post:
  * when the core already left Birth (DestroySequencePlayer ra 11E0:01E8 seen, or scene != BIRTH);
  * before `world_done` (the callback would set the flag and the core would leave right at world done);
  * twice;
  * when the user's own key arrives at about the same time, since the second key then reaches the setup.
* **Hidden profile.** The DOS Birth timeline also runs while the Windows profile is visible (C.5.6).
  Decide whether the auto-continue applies then; see P0 above.

## What D4c must know

* `pdos_seq_view_key` routes DOS-form keys to Birth's story. They take effect only at the next due event,
  and only with the world done (O7:1912). D4c's translation of a T4 choice into "Birth skip + choice" has no
  setup page to point at until D5 (deviation 1).
* `pdos_fontmap_logical(ra, &id)` is the logical-text font read for a replay at a text probe, inside the
  observer's guard. `pdos_fontmap_current_on(graf, ..)` is the per-graf font.

## For the records

Entries for the documents this unit does not edit.

* **User acceptance (2026-10-15, about 10:00 UTC).** The user ran `build/x64/Checked/civ64.exe`, built
  09:22:45 UTC 2026-10-15, which compiled this unit's in-progress Birth files. The user visually accepted
  the DOS Birth scenes. The user also noticed that the DOS Birth is shorter than the Windows one, so the
  view waits on black at its end (deviation 1). The separate unit D4b4 (Birth auto-continue) will give the
  core its Birth skip when the visible DOS Birth ends first. Record this acceptance in STATUS.md and
  manual-checklist-ext.md (D4 section: the DOS Birth items accepted).
* **DESIGN.md 12.8 (area C).** D4b3 delivered:
  * `pdos_birth.h/.c`, C.8's program with 11 resume labels after the listing addresses, and
    `PdosBirthVars`;
  * the post-Birth transition, alone after an abandon on a `PDOS_SEQ_FX_FADE` timeline;
  * the engine wait `PDOS_W_FRAMES_OR_KEY`;
  * in `pdos_seq`: Birth's start, world flag, skip, end and abandon; the Birth view (rows 9, 3, 5, 1,
    25, 2, 21 ready); the pointer rule over Birth and the post-Birth timeline; `pdos_seq_set_birth_watch`.
* **DESIGN.md 12.7 (area B).** F2's tracker per graf with SetTextFontSizeColor's size, and the
  logical-text read `pdos_fontmap_logical` / `pdos_fontmap_port_font`.
* **FIDELITY.md.** DOS Birth's timing is "DOS listing (model)":
  * STORY.TXT's 44 text lines and 8 pictures over 10,463 frames (149.3 s) from the core's Birth start;
  * then the 30-frame post-Birth fade, and the black screen of R:01A8:087C held until the core reaches its
    setup (about 26 s in p4-birth);
  * the core's skip ends Birth at the core's Birth end, with the post-Birth fade from that instant;
  * DOS's own skip acts only at the next due event with the world done;
  * BUILDING NEW WORLD... appears only if the core's world creation outlasts the story (practically
    never);
  * 8 Birth model goldens;
  * not modelled: the EGA path, the DOS generation's drawing, the sound;
  * no DOS-oracle comparison.
* **STATUS.md.** D4b3 done: DOS Birth, the post-Birth transition, F2's logical-text part. S3 still open.
  The leader-face part of F2 is D7's. `test_timeline` 148, `test_pdos_seq` 97, `test_pdos_scene` 126.
  `ext_timeline.py` has the `birth`, `birth_switch` and `birth_skip` runs and the Birth goldens. The final
  eight-step cycle covers P47-R2's changes too (see Results).
* **RUNNING.md.**
  * The harness takes `--dos-birth-watch F,F,..` (each writes `bwatch frame F us U sha256 SHA` to
    `timeline.log`).
  * `timeline.log` adds the BeginWorldCreation probe lines and Birth's steps: sequence 2, and 3 for the
    post-Birth timeline.
  * `ext_timeline.py Checked [--record]` now runs seven runs, two of them 205 s virtual. `--record`
    rewrites the `golden` and `bgolden` lines.
  * `test_timeline.exe` adds a Birth section, about 1 s.
* **FEATURES.md.** With `--graphics dos` (or after a switch), the DOS profile shows the DOS Birth story
  (text lines and colour-cycled pictures). After it comes the DOS fade to black, which holds until the
  game's setup. Skipping the game's Birth ends the DOS Birth with its fade. The pointer is hidden during
  the DOS Birth.
* **DOS-PROFILE.md.**
  * Row 9 and 3.1: the T4 hold after the DOS story is the cleared black screen of R:01A8:087C. It is not
    "BUILDING NEW WORLD..." (shown only with the world still running) and not yet the setup page (D5).
  * Row 5 (EARTH): O7:0034 sets 67FC = 0 for EARTH too (listing fact 5).
* **manual-checklist-ext.md** (D4 section). With `--graphics dos`:
  1. after Start a New Game the DOS Birth story runs (text lines at the bottom, pictures fading in with
     colour cycling);
  2. at its end the screen fades to black and stays black until the game's setup appears;
  3. pressing a key during Birth ends both Births, with the DOS fade;
  4. switching profiles during Birth shows each Birth at the same moment;
  5. no pointer during the DOS Birth;
  6. Play on EARTH shows the same story over the earth map first.

  Items 1, 4 and 5 are covered by the user's acceptance above.

### Gathered D4b "For the records" (for D4c's gate record)

Copied unchanged from the preceding D4b records, in unit order.

#### From [ext-D4b1-record.md](ext-D4b1-record.md)

Entries for the documents this unit does not edit.

* **DESIGN.md 12.8 (area C)**: D4b1 delivered `pdos_clock` (C.4, M1..M12 as functions and constants)
  and `pdos_tl` (C.5 without the programs): a timeline is bound to its program, machine (`pdos_mn`),
  session and context; the session (`PdosTlSession`) holds the fade colours and the first-fade flag of
  the DOS run; added waits `PDOS_W_FADE`, `PDOS_W_KEY`, wakes and tails (Deviations 1..4, 6);
  `PDOS_DIAG_SEQ` (`seq`) counts the engine's misuse and runaway programs (Deviation 9). Not wired
  into the profile until D4b2.
* **FIDELITY.md**: the DOS clock is a model ("DOS listing (model)"): VGA frames of 17,024 PIT clocks
  (P1; the 17,024 is TIMING 2.2's inferred VGA value), DOS code, retrace waits, loads and the key flush
  take no time (M2, M3, M11), fades write the whole palette each frame (E = 256, P7), the session's
  first fade takes one more frame (M4), the dissolve copies floor(8,800 / c) pixels a frame (M10; c = 0
  instant), the sound-tick divider restarts at each tune start (P29). A key that arrives at the very
  microsecond of a frame-instant key test is seen by the next test (Deviation 5). The timelines'
  state at a time depends only on the inputs up to it: `test_timeline` shows equal step logs and
  machines over 200 random tick partitions and between 16,667 us and 1 ms ticks (T2). No original
  timing comparison was made (the DOS oracle is optional and not run).
* **STATUS.md**: D4b1 done: `pdos_clock`, `pdos_tl`, `test_timeline` (74 checks in Checked,
  CheckedNoObs and Release); the DOS profile's output is unchanged (not wired yet); the 8-step cycle
  green (see Results; steps 2, 3, 5, 6 re-run after an external OBS_TABLES failure caused by a
  DOS-PROFILE.md 2.4 note, since reworded).
* **RUNNING.md**: `test_timeline.exe <gamedata> <outdir>` runs in test.cmd's generic loop and writes
  `timeline-partitions.txt` and `timeline-test-steps.txt` into the test output directory;
  `presentation-diag.log`'s `pdos` line has a new counter `seq`.
* **FEATURES.md, DOS-PROFILE.md, manual-checklist-ext.md**: nothing (no visible change).

#### From [ext-D4b2a-record.md](ext-D4b2a-record.md)

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

#### From [ext-D4b2b1-record.md](ext-D4b2b1-record.md)

Entries for the documents this unit does not edit.

* **DESIGN.md 12.8 (area C)**: D4b2b1 delivered `pdos_seq.h/.c`: the flow state of C.11.1 kept from the
  probes of C.11.2 (call-site rows resolved at reset; unresolved ones counted, never matched), the intro
  timeline on `pdos_mn()` started at CreateSequencePlayer ra 11E0:00A5 (t0), the core's intro skip
  (SetGameCursor ra 11E0:08D7) as the DOS key, `pdos_seq_view_key` as source 2's entry point for D4c, abandon
  with finish at the MenuZ exit ra 11E0:0729 and at Birth's SeekSequence ra 11E0:01AA, C.11.6 with
  `PDOS_DIAG_SEQ`; wired into `pdos_profile.c` at draft B 2.1's places (reset; event step 2; entry step 2;
  exit steps 1 and 7; advance step 1, every tick, visible or not). While the intro view is on, scene rows
  1, 25 (dialog 148) and 2 are ready N rows, so the N frame is the intro; after its hand-over the last
  screen is held until the core's next scene (the title box is D4b2b2's).
* **FIDELITY.md**: the DOS profile's intro runs on the game's virtual time from the core's intro start
  (t0, the creation of the intro movie; 50 us after the start in the headless runs), at the DOS model's
  native pace (no time scaling between the DOS and Windows intros), whether the DOS profile is visible or
  not; a switch shows it at the same virtual time (T2, `ext_timeline.py`: equal DOS samples with switching
  every 997 ms). The core's intro skip is the DOS key (T5); a title choice made while the DOS intro runs
  ends it with finish (the dissolve completes at once; in the pan it freezes). Known gap until D4b2b2: after
  the intro (or a finish) the DOS view holds the last DOS screen; DOS shows the title box there. Labels:
  "DOS listing (model)" for the intro's frames (C.6.3, checked in the harness); no DOS-oracle comparison.
* **STATUS.md**: D4b2b1 done: `pdos_seq` and its wiring; the DOS view shows the DOS intro (`--graphics dos`
  or after a switch during the intro) and then holds its last screen until the core's next scene;
  `test_pdos_seq` (43 checks in Checked, CheckedNoObs and Release) and `ext_timeline.py` (EXT_TIMELINE_OK, in
  `test.cmd checked`); no core value changed (P0_OK, EXT_G1_OK); the 8-step cycle green (see Results).
* **RUNNING.md**: the headless harness writes `<outdir>/timeline.log` whenever the DOS profile is registered
  (`--dos-data` with a working store): `step <seq> <op> frame F us U dos ADDR arg A` per DOS step and `probe
  <name> enter|exit ra SSSS:OOOO us U` per hit of the sequencer's probes (no option). `test.cmd checked` runs
  `tests/harness/ext_timeline.py` (two 75 s runs, about 15 s; outputs `build/harness/Checked/timeline/`).
  `test_pdos_seq.exe <gamedata> <outdir>` reads the DOS copy `<gamedata>\..\dosdata` (it fails when the copy
  does not open). `presentation-diag.log`'s `seq` counter now also counts the sequencer's unexpected orders
  (C.11.6) and unresolved call-site rows.
* **FEATURES.md**: the DOS graphics profile shows the DOS intro (credits over the panorama, the logo
  reveal and its dissolve) at the game's pace with `--graphics dos`, or from the moment the player switches
  with Ctrl+Shift+Backspace during the intro; afterwards its last screen stays until the game moves on (the
  DOS title box comes later).
* **manual-checklist-ext.md** (D4 section, left pending for the user): the DOS intro is now visible with
  `--graphics dos` or after Ctrl+Shift+Backspace during the intro: (1) credits and pan from the start,
  the logo, the reveal and the dissolve to the logo on black at about 68 s; (2) switching back and forth
  during the intro shows each intro at the same moment, neither restarts nor speeds up; (3) a key during
  the intro ends both intros (the DOS one through its dissolve); (4) choosing a title item in the Windows
  view while the DOS intro still runs ends the DOS intro (at once in the dissolve); (5) after the intro the
  DOS view keeps the logo on black until the game moves on (no DOS title box yet: D4b2b2).
* **DOS-PROFILE.md**: nothing (no row, adapter or call site changed).

#### From [ext-D4b2b2-record.md](ext-D4b2b2-record.md)

Entries for the documents this unit does not edit.

* **DESIGN.md 12.7 (area B)**: D4b2b2 delivered the menu-box model in `pdos_ui.h/.c` (`PdosMenuBox`,
  `pdos_menubox_layout`, `_draw`, `_select`, `_row`, `_hotkey`; the layout, colours, highlight and hotkeys
  of R:1D05:0031..0475), and the shadow engine's S6 (late-bound DROP brackets mute the inner ones on their
  surface), S7 (brackets on a freed surface are detached) and S9 (a registration closes open brackets), with
  the counter `detached`. S3 remains open until the first macro with a drawing `leave`.
* **DESIGN.md 12.8 (area C)**: D4b2b2 delivered the DOS title box in `pdos_seq` (C.7: shown at the
  hand-over without a preselection, held logo with one; the row from the core's `g_menuSelection` at
  MenuZ's key poll, else the view's; the chosen row kept; redrawn at dialog 139's reopening; C.6.6's choice
  during the intro), the pointer rule `pdos_seq_pointer_hidden` (C.11.5), and the frame watch for C-9.
* **FIDELITY.md**: the DOS view shows the DOS title box (the five DOS items of the store and the added
  Quit row) at the intro's hand-over, positioned and coloured as R:1D05:0475 draws it at (100, 140); it
  follows the core's selection while the core's title menu waits; after a choice it stays with the chosen
  row (the DOS confirmation and phrase-boundary waits are omitted). The pointer is hidden while the DOS
  intro runs. Model goldens of six intro frames, labelled "DOS listing (model)" (no DOS-oracle comparison).
  Known gaps: the box takes no DOS-form input yet (D4c); hotkeys per the listing only select.
* **STATUS.md**: D4b2b2 done: the DOS title box, the menu-box model, the pointer rule, S6/S7/S9; S3 open
  (no drawing-`leave` macro yet), F2 for D4b3; `test_pdos_seq` 83 checks; `ext_timeline.py` with the `key`
  and `burn` runs and the C-9 goldens (EXT_TIMELINE_OK); no core value changed (P0_OK, EXT_G1_OK); the
  8-step cycle green (see Results).
* **RUNNING.md**: the headless harness takes `--dos-watch F,F,..` (at most 16 DOS intro frames; each writes
  `watch frame F us U sha256 SHA` to `timeline.log`) and the script line `at <ms> burn <d>` (advances the
  virtual clock by d ms with no tick; logged `burn virtual_us A to B` in run.log). `ext_timeline.py
  Checked [--record]` runs four runs (about 16 s); `--record` rewrites `tests/harness/ext-timeline-golden.txt`.
  `test_pdos_seq.exe <gamedata> <outdir>` writes `<outdir>\title-box.bmp`.
* **FEATURES.md**: the DOS graphics profile now shows the DOS title box after the intro (or after a key, or
  when the player picks a title item in the Windows view during the DOS intro), with the highlighted item
  following the game's; the mouse pointer is hidden during the DOS intro.
* **manual-checklist-ext.md** (D4 section, pending for the user): with `--graphics dos`: (1) after the
  intro the DOS title box appears below the logo with six items (the five DOS ones and Quit), the first
  highlighted; (2) moving the selection in the game's title menu moves the DOS highlight; (3) after a
  choice the box stays with that item highlighted until the next scene; (4) cancelling Load, closing the
  Hall of Fame or cancelling Customize shows the box again; (5) a key during the intro ends it and the box
  appears after the dissolve; (6) no pointer during the DOS intro; (7) a shortcut (preselection) start shows
  the logo on black, no box.
* **DOS-PROFILE.md**: nothing (no row, adapter or call site changed).

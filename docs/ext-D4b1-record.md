# Extension phase D4, unit D4b1 (the DOS clock and the timeline engine) - record

Unit D4b1 of the "civ64" extension: area C's clock model (`pdos_clock`) and timeline engine
(`pdos_tl`), exercised by test programs in `tests/test_timeline.c`. Design:
[verify/ext-d1-draft-C.md](verify/ext-d1-draft-C.md) (revision 3) C.3, C.4, C.5 and C.15.1 items 1, 4, 6
and 8. Brief: [verify/BRIEF-d4.md](verify/BRIEF-d4.md), "D4b split". Session D4b1, 2026-10-12.

Labels: **compiled** (the three language checks and `/W4 /WX`), **headless** (the unit test program).
No DOS program was executed; nothing was written to `C:\Projects\Civ1RE\dos`, `build/dosdata` or
`C:\Projects\Civ1RE\original`; no UI was shown; no DOS byte is in the repository or a binary (the tests
hold hand-written vectors and hashes only). No git command that writes was run. Asan was not built or
run. Every DOS constant was read from `docs/dos/TIMING.md` and checked against the listing in
`build/dos/disasm/` (root.lst R:0000:0345..0667, R:0182:0134, R:1D05:043D..0441; mgraphic.lst
G:0000:06D3..06FD; ovl23.lst O23:04B9..0518).

## Status

DONE. The engine is not wired into the DOS profile: `pdos_profile.c` is unchanged (there is no
`pdos_seq` yet, D4b2), so the DOS profile's output is unchanged; no frame expectation or golden
changed. The final cycle is in "Results".

## What was built

| File | Contents |
|---|---|
| `present/dos/pdos_clock.h/.c` (new) | C.4 complete: the grid of C.4.2 (`PDOS_PIT_HZ`, `PDOS_FRAME_CLK`, `PDOS_SPAN_MAX`, `PdosGrid`, `pdos_frames_done`, `pdos_frame_us`, saturation at `PDOS_FRAME_MAX`), `pdos_tick_frame`, `pdos_ticks_after`, `pdos_wait_end`, `pdos_tick_wait_end`, `pdos_fade_frames`, `pdos_fade_weight`, `pdos_fade_duration`, `pdos_cycle_rate`, `pdos_cycle_steps`, `pdos_dissolve_rate`, `pdos_dissolve_frames`, `pdos_catchup_fires` (M9's check), the C.4.3 durations as constants. Pure functions. |
| `present/dos/pdos_tl.h/.c` (new) | C.5 except the sequence programs: `PdosTl` (with placeholder `PdosIntroVars`, `PdosBirthVars`, `PdosFxVars` in the locals union), `PdosTlSession`, `PdosCycleSlot`, `PdosFade`, `PdosLogStep` and the sink `PdosLogFn`; `pdos_tl_bind`, `pdos_tl_set_log`, `pdos_tl_start`, `pdos_tl_run`, `pdos_tl_key`, `pdos_tl_wake`, `pdos_tl_abandon`, `pdos_tl_finish`, `pdos_tl_frame_at`, `pdos_tl_running`; the program helpers (steps, tune, tick, kbhit, getkey, flush, cycling set-up/start/stop, the waits, fade, dissolve, tail and wakeable flags). |
| `present/dos/pdos_common.h`, `pdos_assets.c` (changed) | the diagnostic `PDOS_DIAG_SEQ`, named `seq`, added after `elem_full` the way D4a added its counters (it reaches `presentation-diag.log` through the existing loops). |
| `tests/test_timeline.c` (new) | C.15.1 items 1, 4, 6, 8 on test programs; registered by test.cmd's generic loop (every `tests/test_*.c` is built by build.cmd and run by test.cmd). |

### The model rules (C.4.1) and their listing addresses

| Rule | Where | Listing |
|---|---|---|
| M1 frame grid, P = 17,024 clocks | `PdosGrid`, `pdos_frames_done`, `pdos_frame_us` | P from the calibration R:0000:0276 (sum halved R:0000:02B5..02BC, DGROUP:0050), programmed at R:0000:0258 from DGROUP:0046; 17,024 on VGA is TIMING 2.2's inferred value |
| M2 DOS code takes no time | `PDOS_DUR_CODE` 0; steps run at the instant the wait ends | Choice |
| M3 retrace waits and palette loads 0 | `PDOS_DUR_PAL_LOAD` 0; the fade's R:0000:0554 retrace wait is 0 | G:0000:01A1, R:0000:0554 |
| M4 the session's first fade +1 frame | `pdos_fade_duration(steps, first)`; `PdosTlSession.fade_measured`; the engine's first weight frame is a + 2 | R:0000:0512..051C (DGROUP:0066), R:0000:0580..05B3 (cli..sti), R:0000:054F (F stored after) |
| M5 fades, E = 256 | `pdos_fade_frames` (6 x the low byte, R:0000:050C..050E), `pdos_fade_weight` = min(65,535, j floor(65,536 / (F - 1))) | R:0000:051F..052D (E), 0537..0546 (p, step), 0549 (first weight), 061B..0624 (pass advance, saturation), 0631 (one batch a frame) |
| M6 cycling | `pdos_cycle_rate` (low byte), `pdos_cycle_steps`; the engine's slots | R:0000:0382 (set-up, 03E6..03EC: rate byte, stopped), 03FA (start: 0419..0425), 042B (stop: 0443), 044A (per frame: 0466..046E countdown, records in order) |
| M7 sound tick | `pdos_tick_frame` n + (n - 1) / 6, `pdos_ticks_after` f - f / 7; the divider restarts at each `pdos_tl_tune` (P29) | R:0000:035F..036B (DGROUP:005E, 7), R:0000:036C (S#3) |
| M8 waits | `pdos_wait_end` (n <= 0 at once), `pdos_tick_wait_end`; the engine's key tests | R:0182:0134..0144 (signed `jl`), R:0000:0A4E (S#5), R:2045:2098 (kbhit) |
| M9 no catch-up | `pdos_catchup_fires` (test: 0 for every column of both loops) | O2:0476, O2:07D0 |
| M10 dissolve | `pdos_dissolve_rate` max(1, floor(8,800 / c)), `pdos_dissolve_frames` ceil(64,000 / n); c = 0 and page 0: 0 frames | G:0000:06EF..06FD (2260h / c), 06ED (jcxz), 06D3 (page 0) |
| M11 key flush 0 | `PDOS_DUR_KEY_FLUSH` 0; `pdos_tl_flush` | R:0403:4545 |
| M12 Birth's step function at every instant | `PDOS_W_DUE` (a tick wait; the program resumes on the due tick's frame) | O7:17CF, O7:18B0 |
| C.4.3 | `PDOS_DUR_MENU_CONFIRM` 20, `PDOS_DUR_TEXT_CURSOR` 10 | R:1D05:043D..0441, O23:04DE..04E2 and O23:0514..0518 |

### The engine (C.5)

* **Closed-form waits.** Each wait stores its end frame (`wait_until`, `PDOS_NONE` for never) and, for
  key waits, takes the earliest pending key's microsecond. `pdos_tl_run(t)` loops over waits whose end
  is <= t, never over frames. Wait kinds: `PDOS_W_FRAMES` (wait(n), or an absolute frame),
  `PDOS_W_TICK`, `PDOS_W_TICK_OR_KEY`, `PDOS_W_KEY_STEP` (up to count x (kbhit, wait(period)), the
  logo hold), `PDOS_W_DUE`, `PDOS_W_DISSOLVE`, `PDOS_W_FADE`, `PDOS_W_KEY`, `PDOS_W_HOLD`.
* **Per-frame effects, in frame order** (TIMING 2.5 steps 2 and 3): for the frames passed before a
  step, the fade's last weight in the range, each running slot's n steps (`pdos_cycle_advance`: n mod
  count, one DAC write) and the dissolve's frames (`pdos_dissolve_frame` once a frame). What stays
  visible is the last write of each DAC entry, so the writes are ordered by the frame of their last
  write, the fade before the slots and slot 1 before slot 8 in one frame (a cycling range overrides the
  fade's write in the same frame).
* **Event-time ordering.** `pdos_tl_key`, `pdos_tl_wake`, `pdos_tl_abandon` and `pdos_tl_finish`
  first run to their time (a step at the same microsecond comes first). An older time is ignored (a
  key is then taken at the timeline's current time).
* **Keys.** `pdos_tl_kbhit` tests without consuming; `pdos_tl_getkey` reads the earliest;
  `pdos_tl_flush` reads all. Up to 8 keys are pending (`key_us`/`key_code` mirror the earliest).
* **Abandon** stops at the last step <= t: slots stop (the DAC keeps its colours), the fade and the
  dissolve stay where they are, pending keys are dropped. **Finish** first completes the waits marked
  with `pdos_tl_tail` at once (a dissolve with `pdos_dissolve_finish`, a fade with its last weight),
  resumes the program with `why` = `PDOS_WHY_FINISH` (and `finishing` = 1) until it reaches an
  unmarked wait or ends, then abandons.
* **Log.** Every program step and helper writes a `PdosLogStep` (op, DOS address, sequence, frame,
  instant, argument) to the bound sink; the engine adds `start`, `end`, `abandon`, `finish`, `tail`.
* **Limits (C.5.7).** `PdosTl` is 1,248 bytes, `PdosTlSession` 1,548 (both static memory). More than
  65,536 resumes in one call is a runaway: `PDOS_DIAG_SEQ` and abandon. A program that returns 1
  without a wait (counted, the timeline ends), two waits in one resume (counted, the last kept) and a
  helper called outside a program (counted, refused) also count `PDOS_DIAG_SEQ`. Nothing faults.

## Tests

`tests/test_timeline.c`, one program, prints `PASS|FAIL test_timeline: N checks, M failed`. It writes
`timeline-partitions.txt` (partition count, run time, structure sizes) and `timeline-test-steps.txt`
(the no-key run's steps in the form of C.15.3's `timeline.log` lines) into the test output directory.

* **Item 1, the clock** (27 checks; the program timing 21, abandon and finish 7, tick independence 3,
  T2 2, limits 14): `pdos_frames_done`/`pdos_frame_us` inverse for k <= 10^7 with
  t0 = 1,234,567; frame 4,040 at 57,641,634 us, 4,766 at 68,000,007; saturation;
  `pdos_tick_frame`/`pdos_ticks_after` inverse for n <= 20,000; tick 3,463 -> frame 4,040; the 19
  cue ticks of C.6.3 on its frames; `pdos_fade_weight(j, 48)` = min(65,535, 1,394 j); fade frames
  and M4; cycling steps 330 and 41 (C.6.3); waits; dissolve 146 frames; M9 for all 640 columns; C.4.3.
* **The test program** (a miniature intro on hand-written numbers: loop A of 32 columns with tick waits
  and a key test, loop B with key-or-tick waits, a shortcut read, a logo tick wait, 10 strips by
  wait(1), two fades, a 20 x 5-frame key-test hold, a flush, slots off, a dissolve marked as a tail, a
  show step starting slot 3, a 30-frame wait): exact frames of every column, strip, fade (the
  session's first one 13 frames, the second 6; 12 without M4), hold (100 frames), dissolve (146),
  end (771); the fade weight t_3 at frame 480; slot 1's step overriding the fade's write at frame 490;
  slots stopped after 42 and 13 steps; slot 3 cycling on after the end; keys in loop A (only tested
  there, read once by the shortcut), loop B (read at its own microsecond), the logo wait (seen by the
  hold's first test), the hold (next 5-frame test) and exactly at a test instant (the next test), two
  keys (the first read, the second pending). Mutations of the engine (a key enqueued before the
  steps at its time, the first fade weight of a range instead of the last, a slot's steps counted as
  1, the slots before the fade in one frame) each fail the test (checked during development).
* **Item 4, tick independence**: 200 random tick partitions (8 scenarios x 25: no key, a key in each
  of four phases, finish and abandon in the dissolve, abandon in loop B) of 0..15 s with ticks of
  1 us .. 1 s (log-uniform), against a reference run ticked only at the samples and inputs: identical
  step logs and identical machines (`pdos_mn` pages 0..3, so the shown page, and the DAC, hashed) at
  1,000 sample times each (random, on and one microsecond before frame instants, at and after the
  inputs). Run time 0.7 s, so the 200 partitions were not scaled down; the span is 0..15 s instead of
  0..70 s because the test program ends at 12.2 s (the intro's 70 s is D4b2's).
* **Item 6, abandon and finish**: finish in the dissolve completes it at once (page 0 = page 1, 64,000
  pixels), the show step runs in the tail, slot 3 started there never steps; nothing runs afterwards
  (no step, no DAC change, the frame stays); abandon at the same instant leaves 50 x 440 pixels
  copied and no tail; abandon in loop B freezes slots 1 and 2 (DAC equal to 21 steps of slot 1); finish
  outside a tail is a plain stop.
* **Item 8, T2**: instance a on `pdos_mn` ticked every 16,667 us and instance b on a machine of its own
  ticked every 1 ms, the same start and key, compared at 1,504 samples (every 9,973 us): equal
  machines, frames, states and logs, with and without a key.
* **Limits and other waits**: no wait, runaway, helpers outside a program, two waits; a hold (time and
  keys do not end it, `pdos_tl_wake` does); an older time; a wakeable due wait without a tune (never)
  and after a tune (tick 90 on frame + 104); a key wait; `sizeof(PdosTl)` < 2 KB; the name `seq`.

| Test | Checked | CheckedNoObs | Release |
|---|---|---|---|
| `test_timeline` | 74 | 74 | 74 |

## Results

The eight steps of the brief, 2026-10-12; logs `build/d4b1-<n>-<step>.log`, status
`build/d4b1-status.txt` (ends `ALL_GREEN`); no Asan.

| Step | Result |
|---|---|
| 1 `build.cmd checked` | BUILD_OK, 188 s (269 portable sources: C11 + C17 `/W4 /WX` + clang C99 parse) |
| 2 `test.cmd checked` | first run exit 1, 1899 s: **external cause**, see below (`test_timeline` passed, 74 checks). Re-run (2r): TESTS_OK, 1894 s: `test_timeline` 74, REGISTRY_OK, NODOS_OK, P4_TESTS_OK, OBS_TABLES_OK, OBS_LINT_OK, `pdos_scene_check` 1075, P0_OK 279, EXT_FRAMES_OK, EXT_ADAPT_OK 20, MIRROR_OK 29, ZOOM_OK 32 |
| 3 `ext_g1.py check` | EXT_G1_OK runs 77 (first run, and again after 2r: 3r) |
| 4 `build.cmd checked noobs` | BUILD_OK, 190 s |
| 5 `test.cmd checked noobs` | first run exit 1, 724 s, the same external cause. Re-run (5r): TESTS_OK, 745 s: `test_timeline` 74, OBS_TABLES_OK, `pdos_scene_check` 1075, P0_OK 56 |
| 6 `ext_g1.py check --variant CheckedNoObs` | EXT_G1_OK runs 77 (first run, and again after 5r: 6r) |
| 7 `build.cmd` (Release) | BUILD_OK, 198 s |
| 8 `test.cmd` (Release) | TESTS_OK, 351 s: `test_timeline` 74, OBS_TABLES_OK, `pdos_scene_check` 1075, NODOS_OK |

**External cause of the first runs of steps 2 and 5.** Both failed only on `OBS_TABLES_ERROR
present/obs_tables.h/.c differ from the generated text`: a docs agent had added a note naming two
SetCivFont call sites to `docs/DOS-PROFILE.md` 2.4 (row F8), and `gen/obs_tables.py` collects every
Windows address named there. The orchestrator reworded the note (about 06:12 UTC) so that it names no
address; the generated tables then matched the files again. No source of this unit changed and nothing
was rebuilt: steps 2, 3, 5 and 6 were re-run (2r, 3r, 5r, 6r) and are green; step 8 ran after the fix
(OBS_TABLES_OK). `obs_tables` was neither regenerated nor edited by this unit.

**P0.** No core value changed: P0_OK 279 (Checked) and 56 (CheckedNoObs), EXT_G1_OK runs 77 on both
observer variants, EXT_FRAMES_OK. The new modules are not called by the profile; they include no
emulation header and read nothing of the emulation (OBS_LINT_OK and the include rule of
`registry.py check` cover `pdos_clock.*` and `pdos_tl.*`).

## Deviations from draft C

Format: section; what; why.

1. **C.5.2 (start).** A timeline is bound first: `pdos_tl_bind(tl, prog, m, ses, ctx)` names the
   program, the machine (`pdos_mn()` in the profile), the session and the program's context;
   `pdos_tl_set_log` the step log sink. `pdos_tl_start(tl, seq, t0)` keeps the binding and runs the
   program's first steps at t0. Why: the draft does not say how the program or the machine is chosen;
   a binding keeps pdos_tl free of a sequence table that D4b2/D4b3 would edit, and T2 needs two
   instances on two machines.
2. **C.5.2 (PdosFade), M4.** The fade's start and target colours and the "measured" flag DGROUP:0066
   are in a `PdosTlSession` (one per DOS run), not in `PdosTl`; `PdosFade` keeps the start frame and F.
   Why: DOS keeps them once per run (DGROUP:BD06, BA06, 0066), the session's first fade is a property of
   the run across sequences (title, Customize, Birth), and two 768-byte DACs per timeline would break
   C.5.7's "PdosTl under 2 KB". Consequence: two timelines of one session must not fade at the same
   time (DOS cannot either: the fade busy-waits).
3. **C.5.2 (keys).** `key_us`/`key_code` are the earliest of up to 8 pending keys
   (`PDOS_TL_KEYS`, a model choice; more are dropped), not a single key. Why: O2:09D7 reads one key
   while others can be pending, and R:0403:4545 reads them all.
4. **C.5.2 (waits).** Added: `PDOS_W_FADE` (the busy-wait of R:0000:04AA/04D4), `PDOS_W_KEY`,
   `pdos_tl_wake` (ends `PDOS_W_HOLD` and any wait made wakeable with `pdos_tl_wakeable`),
   `pdos_tl_tail` (names the non-interactive tail of C.5.2's finish), `PdosTl.why` and `finishing`.
   Why: the draft leaves open how a T4 hold ends and how a tail is named; D4b2 (T4 holds, C.6.6) and
   D4b3 (the BUILDING blink with the world flag, C.8.6) need them.
5. **C.5.3 and M8 at one microsecond.** A key test at a frame instant inside a wait
   (`PDOS_W_KEY_STEP`) does not see a key that arrives at that very microsecond: C.5.3 puts the step
   first, so M8's "arrival <= u" becomes "arrival < u" there; a continuous poll (`PDOS_W_TICK_OR_KEY`,
   `PDOS_W_KEY`) ends at the key's own microsecond. The program steps after a key-ended wait run at
   that microsecond, on the frame of the last boundary before it (M2 says "at the instant of the last
   frame boundary"). Why: the tie rule must give the same result in every tick partition, and the
   instants in the step log never decrease.
6. **C.5.2 (finish).** After its tail waits complete, the program continues at the finish instant (so
   the intro's Show step O2:0B93..0BCF can run) until an unmarked wait or its end; a fade in a tail
   completes with its last weight. The draft names only the dissolve.
7. **M10.** c = 0 (G:0000:06ED `jcxz`, no delay) and a dissolve of page 0 (G:0000:06D3) take 0 frames:
   the copy is done at the call (M2). The draft's n = max(1, floor(8,800 / c)) is undefined for c = 0.
8. **C.5.4 (PdosLogStep).** The record has an `arg` field (a column, a key, a count). The line format of
   `timeline.log` is D4b2's.
9. **C.5.7 (PDOS_DIAG_SEQ).** Besides pdos_seq's unexpected core order, the engine counts a runaway
   program (more than 65,536 resumes in one call, then abandoned), a resume without a wait, two waits
   in one resume and a helper called outside a program.
10. **The end of a program.** A timeline whose program returned 0 (`PDOS_TL_DONE`) keeps stepping its
    running slots until it is abandoned, as DOS's frame routine runs on; the draft does not say.
11. **C.15.1 item 4.** The partitions cover 0..15 s, not 0..70 s: the test program ends at 12.2 s;
    the intro's span is D4b2's (item 2/3 runs). 200 partitions (0.7 s), not scaled down.

## What D4b2 and D4b3 need to know

* **Set-up.** One `PdosTlSession` for the DOS profile (`pdos_tl_session_init`); each timeline
  `pdos_tl_bind(tl, prog, pdos_mn(), &ses, ctx)`, `pdos_tl_set_log(tl, sink, ctx)` (the headless
  `timeline.log` writer), then `pdos_tl_start(tl, PDOS_SEQ_INTRO, t0)` at the probe's time. Abandon (or
  finish) a timeline before starting another on the same machine: a done timeline keeps cycling.
* **pdos_seq's calls.** `pdos_tl_run(tl, e->t_us)` before applying an event or probe, at every tick
  and in the filter; `pdos_tl_key(tl, t, PDOS_KEY_ANY or 'N'/'L'/'E'/'C')` for C.6.4's two sources;
  `pdos_tl_wake(tl, t)` when an input of the program's context changes (world flags, T4); 
  `pdos_tl_abandon` / `pdos_tl_finish` (C.6.6, C.8.7); `pdos_tl_frame_at` for a tick's frame.
  `PDOS_DIAG_SEQ` (`pdos_diag_note`) for an unexpected core order (C.11.6).
* **Writing a program** (`PdosProgFn`): `switch (tl->pc)` with one label per wait of the listing (name
  them after the DOS address they resume at); at each resume do the DOS steps in listing order with
  area B's primitives on `tl->m` and log them with `pdos_tl_step(tl, op, "O2:xxxx", arg)` (static
  strings); set `tl->pc`, call exactly one wait helper and return 1; return 0 at the end. Steps between
  two waits run at one instant (M2). Replace the placeholder `PdosIntroVars` / `PdosBirthVars` /
  `PdosFxVars` in `pdos_tl.h` with the listing's locals (keep the union under `raw[32]` words, or
  raise `PDOS_TL_VARS_WORDS` and re-check `sizeof(PdosTl)` < 2 KB in `test_timeline`).
* **The intro's primitives.** S#1(3) at O2:0339: `pdos_tl_tune(tl, 3, ...)` (the tick and the divider
  restart there). Loop A: `pdos_tl_wait_tick(tl, 21 x / 4)` then `pdos_tl_kbhit` (O2:04C1). Loop B:
  `pdos_tl_wait_tick_or_key(tl, (21 x + 6720) / 4)` then `pdos_tl_kbhit` (O2:082A). O2:09D7:
  `pdos_tl_getkey`. Logo: `pdos_tl_wait_tick(tl, 3463)`. Reveal: `pdos_tl_wait_frames(tl, 1)`. Hold:
  `pdos_tl_wait_key_step(tl, 5, 100)`. Flush: `pdos_tl_flush`. Slots: `pdos_tl_cycle_setup(tl, slot,
  rate, lo, hi)`, `pdos_tl_cycle_start(tl, +-slot)`, `pdos_tl_cycle_stop`. Dissolve:
  `pdos_tl_dissolve(tl, 1, 20)` followed by `pdos_tl_tail(tl)`; the Show step then runs also during a
  finish (`tl->finishing` is 1: end there if the title box is pdos_seq's).
* **Birth.** `pdos_tl_wait_due(tl, due)` for the step function (the tick is 0 until a `pdos_tl_tune`;
  tune 1 then 4 at the first text line, tune 1 at End); waits 5/10/180 with `pdos_tl_wait_frames`;
  fades with `pdos_tl_fade(tl, &target, 8)` (the first fade of the session takes one frame more);
  cycling groups with the slots; the world flag in the context with `pdos_tl_wakeable` waits and
  `pdos_tl_wake`; the BUILDING blink's phase from frame waits (C.8.6).
* **Not done here:** `pdos_intro.c`, `pdos_birth.c`, `pdos_fx.c`, `pdos_seq.c`, the wiring into
  `pdos_profile.c`, `timeline.log`, `ext_timeline.py`, C.15.1 items 2, 3, 5, 7, and D4a's S3, S6, S7,
  S9 (D4b2) and F2 (D4b3).

## For the records

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

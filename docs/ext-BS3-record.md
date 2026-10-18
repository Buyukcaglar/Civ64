# Extension BS, unit BS3 (the warp and the Windows view) - record

Unit BS3 of the Birth synchronisation BS (the user's direction of 2026-10-15, session E3: "Perform Windows &
DOS Birth-* sync task ... adapt Windows scenes to DOS counterparts in terms of timing"). Brief:
[verify/BRIEF-bs.md](verify/BRIEF-bs.md) D1, D3, D5, D6, D8, D9, D11 with the orchestrator's Rulings (14:40
and 18:10 UTC), 3.2 items 4..6, 3.6, 4, 5.2 tests 3..7, 6 (BS3 row). Rules: BRIEF-d4.md "Rules". Staged in
`build/bs34-stage` on top of the tree, BS12 (`build/bs-stage`) and UX1 (`build/ux1-stage`), without the
build slot; the build slot landed it (below, "Landing").

## Status

Done. Landed in the tree on 2026-10-15 at 23:35 UTC, BS1..BS4 at once (the BS implementer's build slot;
one landing for BS12 and BS34, no separate three-step cycles, Rulings 19:20) and verified by the BS phase
gate's eight-step cycle: ALL_GREEN (status `build/bs-status.txt`, logs `build/bs-<n>-<step>.log`; the gate
and its tables: [ext-BS-acceptance.md](ext-BS-acceptance.md)).
Visible change: with the DOS profile registered (civ64 with the DOS files; the harness with `--dos-data` and
`--birth-sync 1`) the Windows profile shows the Windows Birth at the DOS Birth's pace. The user's check
(BS-1..BS-3, BS-6) is pending.

## Landing (the build slot, 2026-10-15 23:00..23:35 UTC)

* **Bases.** Every staged file's recorded base was still the tree's file except `pdos_seq.c/.h` (D4cF, BS4's
  files) and `tests/harness/ext_p0.py` (CY). Those three were merged three-way (`git merge-file -p`, files
  only, no repository write): the staged file, its base (D4cF's recorded base `build/d4cf-stage/obj/base`
  for `pdos_seq.c/.h`, the file BS3 was staged on for `ext_p0.py`) and the tree's file; no conflict, no
  overlap with BS's blocks (CY's CIV_TESTPAR plumbing and D4cF's changes untouched; the staged copies before
  the merge in `build/bs34-stage/obj/pre-merge`, the results in `obj/merge`). UX1's `present.c` and
  `profile.h` in the tree were UX1's staged copies, the base of BS3's; `host_win32.c` the base of BS1's block.
  45 files copied in (`obj/copyin.py`; the tree's files they replaced kept in `obj/tree-before`).
* **Note 4 (Rulings 19:20): the view's cost.** `present_tick_at` runs at every sync (p4-birth: 3,504,824
  calls); the view composed at each. Measured on p4-birth (205 s virtual, `--dos-data`, Windows visible,
  the Checked harness), 4 interleaved rounds each, medians of the process CPU time (wall time in brackets;
  the machine was shared, so CPU time is the steadier figure): without `--birth-sync` 12.23 s (12.35 s),
  with it 14.88 s (14.92 s): +2.65 s, +22 %. Added an early-out in `compose`: nothing to do when no input
  of the composition changed since the last one (no core present: its damage covers the screen and with it
  any change of the movie window's place or cover; the same replica frame; the same system palette and
  screen size). Then 12.39 s (12.46 s) against 13.25 s (13.34 s): +0.86 s, +7 %; 1,287 full compositions
  of 3,504,824 calls. The frames are unchanged: the recorded `bsgolden`, `bs_switch`'s sample equality and
  every other check pass with it (the BS gate's cycle, [ext-BS-acceptance.md](ext-BS-acceptance.md)). (A first attempt,
  composing only when a frame is taken, saved nothing: the tick's step 5a peeks at every call; reverted.)
  Also: `compose` clears `frame_ready` when it frees the frame (a refused reallocation no longer leaves a
  freed frame marked ready).
* **The parallel runner (CY).** test.cmd's sections `bs1_assets` (cpu 2), `bs2_mirror` (after `bs1_assets`,
  cpu 4) and `bs3_timeline` (cpu 5; ext_timeline's `bs` group) inside "extension BS (begin)..(end)"
  comments; `ext_p0` est 600, `ext_continue` cpu 8 est 90 (V8/V8s and BS4's runs). The `bs` group's
  scripts got their own names (`bs_birth`, `bs_skip`, written only by the `bs` group): the base group
  rewrites `birth.script` at its start, which the `bs` group's runs would otherwise read at the same time.
* **build.cmd.** `"%PORT%\present\bs\*.c"` in the portable loop: 281 portable sources (276 before).

## What was built

### DOS Birth's sync marks (`present/dos/pdos_bsync.h`, `pdos_birth.c`, `pdos_tl.h`; 3.2 item 4)

`PdosBirthVars` gains `bs_phase`, `bs_k`, `bs_start`, `bs_len` (presentation memory, 21 of the union's 32
words). `pdos_birth.c` sets the mark at the program's own points, after the step it belongs to: PRE in
`prepare` (O7:0012); FADE_OUT(n) after the fade O7:1A39 of picture n >= 2 (picture 1's keeps PRE); FADE_IN(k)
after the fade O7:1A93 (show_picture O7:1A59); PIC(k) at O7:1A9B (the fade's end); TEXT(j) at O7:195E after
the draw O7:196B when the line is text (BA06 longer than a marker); CLEAR(j) at the strip O7:194A while
TEXT(j); BUILDING in the step function's state >= 2 branch (O7:17DD); POST_FADE after R:01A8:0840; SETUP
at R:01A8:087C. A fade's length N is the wait the program set (`wait_until - frame`, the session's first
fade one more, M4). `pdos_bsync(&s)` (the sequencer's Birth and post-Birth timelines) gives NONE unless
DOS Birth's program runs in sequence 2; ABANDONED once the core's skip abandoned it (the post-Birth
timeline running); else the mark, the timeline's frame and t0. No mark changes a DOS frame, a step, a
clock or a draw: the DOS Birth's outputs are unchanged (`ext_timeline.py` base group, `test_timeline`).

### The core of the replica (`present/bs/pbs_core.h/.c`)

BS2's start of the replica (the movie read from the core's image at SeekSequence ra 11E0:01AA, the god
palette's map, the window and its client) moved out of `pbs_check.c` into `pbs_core` so that the mirror
and the view share it; `pbs_check.c` uses it unchanged in behaviour (`ext_bs.py mirror` equal as before).

### The warp and the view (`present/bs/pbs_view.h/.c`; D5, 3.6, D8, D9)

* **The table** (`pbs_warp_table`, D3): from the script read at the start: item types within {2, 3, 4,
  5, 6, 7, 9}; 8 SwapAndShow frames, increasing, each with its FadeIn; 8 FadeOuts in order, FO[k] after
  SW[k] and ending by SW[k+1]; 44 texts (STR# 139, index j in order), increasing, end after start; every
  fade reaching its full level. Any failure: BS off for that Birth with a log line (the Windows Birth
  plays natively). p4-birth's script: SW 1000, 1800, 2600, 4400, 5600, 7000, 8800, 11000; FO 1700, 2500,
  4300, 5500, 6900, 8700, 10900, 11400; 44 texts from TS[1] 1100; the end 11501.
* **W** (`pbs_warp_frame`): BRIEF-bs.md 3.6's table exactly (pbs_view.h lists it); f never decreases.
* **The view** (`pbs_view_*`): started at the core's Birth start with the setting on and the store open;
  at every presentation tick (present.c step 2b, after the profiles advanced) W, the replica run forward
  to f (every frame in between in item order), the frame composed: the live screen's indices with the movie
  window's visible client replaced by the replica's client, through the live system palette with the god
  entries 0..223 (224..225 once f reached TS[1]) taken from the replica; damage tracking (core rectangles,
  the client on a replica change, the whole frame on a palette or region change). The first composed frame
  makes the view shown; the core's skip (SetGameCursor ra 11E0:094E) holds f (D8); the core's Birth end
  (DestroySequencePlayer ra 11E0:01E8) hands back to the virtual screen at the next tick; a replica error
  hands back at once. `g_win` is never touched (D9). Log lines (timeline.log): `bs start` (the table),
  `bs show`, `bs f` (on each change: the DOS frame, phase, k, n, N, f, the replica's front picture and
  caption), `bs hold`, `bs end`, `bs native`, `bs off` / `bs failed` with the reason; presentation-diag.log
  `bs enabled E starts S offs O shows N advances A fails F state ST f F`.

### The present layer and the Windows profile (`present/present.c`, `profile.h`, `profile_win.c`, `observe.h`)

* `present.c` (UX1's copy as the base): step 2b after the profiles advanced (`pbs_view_advance`, then a
  whole-client redraw when the view became shown or stopped being shown and the Windows profile is
  visible); the view's probe listener registered after the profiles when the DOS profile is registered;
  `pbs_view_core_damage` at every core present; `pbs_view_reset` with the run's reset;
  `present_birth_sync(on, &reason)` (the setting; with on, the store opened when the DOS profile is
  registered: 0, or -1 with the reason) and `present_birth_sync_active()` (D7's query, used by BS4).
* `profile_win.c`: `shows_core_frame` is 0 while the view is shown, `frame`/`peek` return the view's frame.
* `observe.h`: `OBS_LISTENERS_MAX` 4 -> 6 (the view's listener; BS2's check listener in the harness).

### civ64 and the harness

* `win64/civ64_start.c` `civ64_present_defaults`: `present_birth_sync(1, NULL)` (D6: on in civ64; after
  obs_init, before the core; without the DOS files the Windows Birth plays natively).
* Harness `--birth-sync 0|1` (default 0, so every existing expectation stays; CIV_OBSERVER 0: exit 2):
  `present_birth_sync` after the timeline log opens (a refusal is logged as `bs off: <reason>`), the `bs`
  lines in timeline.log, `bswatch frame F us U sha256 SHA` lines for `--dos-birth-watch` frames (the view
  advanced to that instant), presentation-diag.log's `bs` line.
* `gen/dos/registry.py` (D11): `check_bs_includes`: a `present/bs` file includes from `present/dos` only
  `"dos/pdos_bsync.h"` (run by `registry.py check`).

### Tests

* **3. `tests/test_pbs_view.c`** (portable, `test_pbs_view <gamedata> <outdir>`; the game data is not
  read; the synthetic store in `<outdir>\pbs-view`): a Birth-shaped 78-item synthetic script; the table;
  every row of 3.6 (fade levels at n = 0, 1, N/2, N, the end, the hold after ABANDONED, NONE and out-of-
  table marks); 10 validation mutations each refused; `pdos_bsync_of` from synthetic timelines; monotony;
  jumps run the frames in between; 12 random tick partitions give equal replicas at equal times; no leak.
  45 checks.
* **4..6. `tests/harness/ext_timeline.py --group bs`** (the base group unchanged): runs `bs_ref`, `bs`
  (with `--dos-birth-watch` of BS_GOLD), `bs_switch`, `bs_skip` (a player's Enter at 30 s) and
  `bs_skip_off`; checks: the start at t0 with the table, show at t0, end at the core's Birth end, native at
  the next tick; DOS Birth's marks rebuilt from the step log equal every `bs f` line's and every f equals W
  computed in Python from the logged table; 8 shows, 44 draws, 43 clears, the post fade and the hand-over
  each reached within 0.1 s; caption j exactly from line j's draw to its clear; P0 (core outputs, DOS
  samples, Windows samples outside the BS interval); the model goldens `bsgolden` (10 frames, label
  "Windows data + DOS listing (model)"); `bs_switch`'s Windows samples equal `bs`'s, its DOS samples
  `bs_ref`'s; `bs_skip`'s hold at the core's skip, the replica held, the virtual screen after the end
  equal `bs_skip_off`'s. `--exe`, `--root`, `--port` for private runs.
* **7. `tests/harness/ext_p0.py` V8 and V8s** (`--dos-data --birth-sync 1`, with V8s also
  `--switch-every 997`) on birth, new, earth, custom and settlers: every core output equal to V0; V8s's
  switch assertions; presentation-diag.log `bs enabled 1 ... fails 0`. `--exe`, `--root`, `--port` for
  private runs.

## Results (private, staging; `build/bs34-stage/obj`: the overlay of the tree, BS12, UX1 and this stage)

The gate's results (the same tests on the landed tree, all three variants) are in
[ext-BS-acceptance.md](ext-BS-acceptance.md); these are the staging's.

* Compile: `cc.cmd all` CC_ALL_OK in Checked, CheckedNoObs and Release (portable sources, the tests, the
  harness, civ64.exe); `cc.cmd strict` CC_STRICT_OK for every changed C file (c11, c17 /W4 /WX, the clang
  C99 parse). `obs_lint.py` on the overlay: OBS_LINT_OK (97 files). The registry include rules on the
  overlay: all ok (61 pdos files, 10 bs files), the BS rule refusing a mutated file.
* Unit tests (Checked, CheckedNoObs, Release): `test_pbs_view` 45, `test_pbs_movie` 44, `test_pbs_assets` 58,
  `test_present` 997, `test_pdos_seq` 125 (with BS4's vectors), all PASS.
* `ext_timeline.py Checked --group bs --record`: EXT_TIMELINE_OK, 11 checks (727 `bs f` lines, every mark
  reached within 49 µs of its instant, P0 over 1,928 core lines, 2,049 equal Windows samples in
  `bs_switch` with 205 switches, `bs_skip` hold/end/native at 30,100,200 µs). The view started at
  22,687,300 µs (t0), reached f 11501 at the DOS hand-over (DOS frame 10,493) and handed back at the core's
  Birth end (198,225,850 µs). `bsgolden` recorded into the staged `ext-timeline-golden.txt` (the existing
  `golden` and `bgolden` lines unchanged).
* `ext_p0.py Checked --vars V0,V8,V8s --only birth,new,earth,custom,settlers`: P0_OK, 30 checks (the V0
  runs equal ext-g1-baseline; V8 and V8s equal V0; the view started and never failed in each). A first
  private run used display16 in place of settlers (P0_OK too); display16 stops at the title menu and never
  reaches Birth (`bs ... starts 0`), so the list uses settlers (Birth skipped, then two turns of play).
* `ext_bs.py mirror` with the BS3 overlay (pbs_core extraction): EXT_BS_OK (1436 of 1436, EARTH 84 of 84).

## Decisions within the brief

* The store is opened by `present_birth_sync(1)` (civ64 through `civ64_present_defaults`, after obs_init;
  the harness after the timeline log opens), not by `present_profiles_init`: one place for both.
* `pbs_core` extracted from BS2's mirror so that the view and the mirror start the replica identically.
* The view composes whether the Windows profile is visible or not (T2): a switch shows the current frame
  at once; `bs_switch` proves the Windows samples equal.
* The hold (D8) keeps composing (the live screen around the movie window may change); f is frozen.
* `bswatch` advances the view to the watch instant (a frame watch between ticks), as `bwatch` does for DOS.
* `OBS_LISTENERS_MAX` 6 (the view's listener added to the existing ones; BS2's check listener in the harness).

## For the records

* **DESIGN.md 12.8 "Added in BS".** `pdos_bsync.h` (the marks, their points in the Birth program, the
  accessor), `present/bs/pbs_core` (the replica's start shared by the mirror and the view), `present/bs/
  pbs_view` (the table, W, the view's states, composition, damage, hold, hand-back), `present.c` step 2b,
  `profile_win.c`'s frame switch, `present_birth_sync` / `present_birth_sync_active`, the include rule D11.
* **DESIGN.md 12.10.** `OBS_LISTENERS_MAX` 4 -> 6 (`present/observe.h`; not a w16 change; listed with the
  observer's limits).
* **DESIGN.md 12.11.** The 5.1 relation exception (D9): the Windows presented frame differs from `g_win`'s
  conversion only inside the BS interval (`bs show` .. `bs native`); `g_win` itself is unchanged.
* **FIDELITY.md** (a new row after F155, "the Windows Birth's pace with the DOS profile registered"):
  the Windows Birth's pictures, fades and captions follow the DOS Birth's sync points (a **choice** by the
  user's direction; the replica is the core's own movie, BS2): the Windows fades are compressed to the DOS
  fades' length (8 steps of the DOS palette ramp, about 0.7 s), the captions take the DOS lines' durations,
  caption 44 goes at the final fade's start, the end holds black (f 11501) until the core leaves Birth (BS4:
  the auto-continue). 16-colour and monochrome stay native (3.5). Status: implemented in BS3; tests 3..7.
* **RUNNING.md.** Harness `--birth-sync 0|1` (default 0; CIV_OBSERVER 0: exit 2; timeline.log `bs` and
  `bswatch` lines; presentation-diag.log `bs` line); `ext_timeline.py [variant] --group bs`; `ext_p0.py`
  V8/V8s; civ64: the Birth synchronisation on (no option) when the DOS files are found. `test_pbs_view`
  row (45 checks).
* **FEATURES.md.** "Birth synchronisation (BS3): with the DOS files found, the Windows Birth movie follows
  the DOS Birth's pictures and captions" with `ext_timeline.py --group bs`; user checks BS-1..BS-3, BS-6
  (manual-checklist-ext.md, the BS section; the full list is in the BS4 record).
* **STATUS.md.** BS3 done (after the cycle).
* **G-1.** Unchanged runs: no base harness run takes `--birth-sync`.

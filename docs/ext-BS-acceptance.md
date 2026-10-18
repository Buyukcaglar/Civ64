# Extension unit BS (the Birth screen-by-screen synchronisation) — acceptance record

The user's direction of 2026-10-15 (session E3): "Perform Windows & DOS Birth-* sync task ... adapt Windows
scenes to DOS counterparts in terms of timing". Brief: [verify/BRIEF-bs.md](verify/BRIEF-bs.md) D1..D12 with the
orchestrator's Rulings (14:40, 18:10 and 19:20 UTC); the gate is the brief's 5.2 tests 1..8 and, by the cycle
rule of about 14:09 UTC ([verify/BRIEF-cy.md](verify/BRIEF-cy.md)), the full eight-step cycle at the BS phase
gate (D12). Under the user's direction of 2026-10-10 21:20 Asan runs are deferred to the end of the queue, so
the gate is met in Checked, CheckedNoObs and Release with the Asan run recorded as deferred (test 1's "ASan in
the final pass" included). Design: DESIGN.md 12.8, 12.10, 12.11 (entries to apply, "For the records").

BS was done in four units, staged as two pairs and landed together in one build slot (Rulings 18:10 and 19:20:
no separate three-step cycles for BS12 and BS34; this gate's cycle is the only one):

* **BS1, the Windows Birth assets:** [ext-BS1-record.md](ext-BS1-record.md) (`host_data_read` in both back ends,
  `present/bs/pbs_assets`: the .rsc parser, the STR# reader, the CvPc decoder; `pbs_check`'s asset part;
  `--bs-check`; `ext_bs.py assets`; test 1).
* **BS2, the replica and its shadow mirror:** [ext-BS2-record.md](ext-BS2-record.md) (`present/bs/pbs_movie`,
  `pbs_check`'s mirror part, `--bs-mirror`, `ext_bs.py mirror`; test 2).
* **BS3, the warp and the Windows view:** [ext-BS3-record.md](ext-BS3-record.md) (`present/dos/pdos_bsync.h`
  and DOS Birth's marks, `present/bs/pbs_core`, `pbs_view`, present.c step 2b, profile_win.c's frame switch,
  `--birth-sync`, civ64 on by default; tests 3..7; the landing, note 4 and the runner's sections).
* **BS4, the Windows end and the records:** [ext-BS4-record.md](ext-BS4-record.md) (D7 in
  `pdos_seq_autocontinue_release` through `pdos_profile_bs_active`; test 8; the "For the records" of BS3 and
  BS4; the user's checks BS-1..BS-6).

Labels: **compiled** (the three language checks and `/W4 /WX`), **headless** (test programs and the harness on
`build/gamedata`, the DOS copy `build/dosdata` read at run time), **Windows data** (the Windows Birth's pictures,
captions and script read from the game data at run time; the replica's pixels proved against the core's own
screen, test 2), **DOS listing (model)** (the DOS Birth's timing, area C's model; no DOS oracle),
**agent-observed** (none in BS), **DOS-oracle-compared** (not run), **user-confirmed** (none yet: BS-1..BS-6
pending), **unverified**. No DOS program was executed; nothing was written to `C:\Projects\Civ1RE\dos`,
`C:\Projects\Civ1RE\original`, `build/dosdata` or `build/gamedata`; no game or DOS bytes are in the repository
or the binaries (the synthetic vectors of `tests/pbs_testdata.h` only).

## Landing (2026-10-15 23:00..23:35 UTC)

* Started after `build/docs-ux1-done.txt` (23:04:26 UTC). 45 files copied in by
  `build/bs34-stage/obj/copyin.py` (the tree's files they replaced kept in `build/bs34-stage/obj/tree-before`).
  Every staged file's recorded base still equalled the tree's file except three: `present/dos/pdos_seq.c/.h`
  (D4cF, 22:14 UTC) and `tests/harness/ext_p0.py` (CY, 21:22 UTC), merged three-way (`git merge-file -p`, files
  only, no repository write) without a conflict or an overlap with BS's blocks. UX1's `present.c`, `profile.h`
  and `host_win32.c` in the tree were the bases of BS's (BS1's block, BS3's step 2b): no re-application needed.
* CY's runner: three `rem @section` blocks between "extension BS (begin)" and "(end)" comments in `test.cmd`
  (`bs1_assets` cpu 2, `bs2_mirror` after `bs1_assets` cpu 4, `bs3_timeline` cpu 5) and their `:sec_` labels;
  `ext_p0` est 600 (V8, V8s), `ext_continue` cpu 8 est 90 (BS4's runs); CRLF kept; `testpar.py check test.cmd`
  exit 0. `build.cmd`: `present\bs\*.c` in the portable loop (281 portable sources, 276 before).
* Two races found under the parallel runner and removed before the cycle: ext_timeline's base group rewrites
  `birth.script` at its start while the `bs` group read it (the `bs` group now writes its own `bs_birth` and
  `bs_skip`); `bs1_assets` and `bs2_mirror` both write `build\bs\scripts` (`bs2_mirror` runs after `bs1_assets`).

### Note 4 (Rulings 19:20): the view's cost

`present_tick_at` runs at every sync (p4-birth: 3,504,824 calls) and the view composed at each. Measured on
p4-birth (205 s virtual, `--dos-data`, the Windows profile visible, the Checked harness), 4 interleaved rounds per
binary, medians (the machine was shared, so process CPU time is the steadier figure):

| Harness | without `--birth-sync`: CPU (wall) | with `--birth-sync 1`: CPU (wall) | Cost |
| --- | --- | --- | --- |
| before the early-out | 12.23 s (12.35 s) | 14.88 s (14.92 s) | +2.65 s, +22 % |
| with the early-out (landed) | 12.39 s (12.46 s) | 13.25 s (13.34 s) | +0.86 s, +7 % |

The cost was visible, so `pbs_view.c`'s `compose` returns at once when none of its inputs changed since the last
composition (no core present, whose damage covers any change of the movie window's place or cover; the same
replica frame; the same system palette and screen size): 1,287 full compositions of 3,504,824 calls. The frames
are unchanged (the recorded `bsgolden`, `bs_switch`'s sample equality and every other check below pass). A first
attempt, composing only when a frame is taken, saved nothing (the tick's step 5a peeks every call) and was
reverted. Private tools: `build/bs34-stage/obj/measure_bs.py`, `measure_ab.py`.

## Gate

Every row ran in this gate's `test.cmd checked` (step 2; `build/bs-2-test-checked.log`, outputs
`build/test/Checked`) unless it says otherwise; the unit tests and the CheckedNoObs refusals also ran in steps 5
and 8 (CheckedNoObs, Release).

| Test (5.2) | Unit | Method | Evidence | Result |
| --- | --- | --- | --- | --- |
| 1. decoder and asset equality | BS1 | headless; Windows data | `test_pbs_assets` (synthetic .rsc and CvPc vectors: precedence across files, clear codes, KwKwK, width growth to 12, sub-block boundaries; truncation and corruption refused); `ext_bs.py assets` (runs `ref`, `assets` with `--bs-check 1`, p4-birth 200 s; test.cmd `bs1_assets`) | pass: `test_pbs_assets` 58 checks in all three variants; EXT_BS_OK (10 checks): pictures 128..135 each read and equal to the core's port (9 reads, 128 twice), 9 of 9 port bitmaps equal, the 44 captions drawn equal the store's, `mismatches 0` (830 other texts not attributed to the movie); P0: 1930 frames and the summary line equal `ref`'s. CheckedNoObs: `--bs-check 1` exits 2 naming it |
| 2. shadow mirror | BS2 | headless; Windows data | `test_pbs_movie`; `ext_bs.py mirror` (p4-birth and an EARTH start, each with and without `--bs-mirror 1`; test.cmd `bs2_mirror`) | pass: `test_pbs_movie` 44 checks in all three variants; EXT_BS_OK (16 checks): p4-birth `presents 1436 compared 1436 equal 1436 mismatches 0` (client, palette and RGB against `g_win` 1436), 0 unattributed, coverage pictures 8 of 8, texts 44 of 44, fades 16 of 16 with every level (656 of 656); EARTH 84 of 84 (1 picture, 1 text, 1 fade, 41 levels); P0: 1930 and 581 frames equal. CheckedNoObs: `--bs-mirror 1` exits 2 |
| 3. warp | BS3 | headless (portable, synthetic DOS sync states) | `test_pbs_view`: a Birth-shaped 78-item synthetic script, every row of 3.6, fade levels at n = 0, 1, N/2, N, the end, the hold after an abandon, NONE and out-of-table marks, 10 validation mutations each turning BS off, `pdos_bsync_of` on synthetic timelines, monotony, jumps running the frames in between, 12 random tick partitions, no leak | pass: 45 checks in all three variants |
| 4. timing | BS3 | headless; Windows data + DOS listing (model) | `ext_timeline.py --group bs` run `bs` against `bs_ref` (p4-birth, Windows visible, `--birth-sync 1`; test.cmd `bs3_timeline`) | pass: EXT_TIMELINE_OK (11 checks): `bs start` at t0 = 22,687,300 µs with the table (SW 1000..11000, FO 1700..11400, 44 texts, end 11501), `bs end` and `bs native` at the core's Birth end 198,225,850 µs; DOS Birth's marks rebuilt from its step log equal all 727 `bs f` lines' and each f equals W (3.6), non-decreasing; every mark reached (8 shows, 44 draws, 43 clears, the post fade, the hand-over) within 49 µs; caption j shown exactly from line j's draw to its clear; P0 (1928 core lines; DOS samples equal; Windows samples equal outside the view, 293, and differ inside it, 1650 of 1756); the model goldens `bsgolden` (k = 20, 69, 93, 200, 1500, 4000, 7000, 10000, 10480, 12000) equal |
| 5. switching (T2) | BS3 | headless | run `bs_switch` (`--switch-every 997`) | pass: its 2049 Windows samples equal `bs`'s, its DOS samples `bs_ref`'s, 205 switches, its core outputs equal `bs_ref`'s |
| 6. skip | BS3 | headless | runs `bs_skip` and `bs_skip_off` (a player's Enter at 30 s) | pass: `bs hold` at the core's skip (SetGameCursor ra 11E0:094E, 30,100,200 µs), `bs end` at its Birth end and `bs native` at the next tick (all 30,100,200 µs); the replica held at f 1300 (no `bs f` line from the hold to the hand-back); then the 98 Windows samples equal `bs_skip_off`'s (the virtual screen); the core outputs equal (579 lines) |
| 7. P0 with BS | BS3 | headless | `ext_p0.py` V8 (`--dos-data --birth-sync 1`) and V8s (also `--switch-every 997`) on birth, new, earth, custom, settlers | pass: P0_OK checks 304 (25 of them V8, V8s): every core frame, snapshot/result line and events.log equal V0 (e.g. birth 1926 frames, 477 events), V8s's switch assertions, presentation-diag `bs enabled 1 ... fails 0` in each |
| 8. the Windows end (D7) | BS4 | headless | `test_pdos_seq` (BS-active vectors); `ext_continue.py` runs `bs_win`, `bs_win_replay`, `win` (test 8's `bs_off_win`), `nodos` | pass: `test_pdos_seq` 125 checks in all three variants; EXT_CONTINUE_OK (31 checks): `bs_win` synchronised and shown, never off (`advances 2989416 fails 0`), one skip (Escape press and release, 2 posts) at 172,398,650 µs, the first sync after DOS Birth's hand-over (172,398,604 µs), at `dos`'s sync 3,425,801; the core's skip, Birth end and setup at 172,411,900 µs; the view's end there (no black wait to 198.2 s); core outputs and posts equal `dos`'s; `bs_win_replay` (the Windows profile alone given the recorded posts) equal: P0 against the recorded input (1670 lines, 42 events, 2 posts); `win` nothing produced, equal `ref` (1678 lines); `nodos` no Birth synchronised, nothing produced, equal `ref`. CheckedNoObs: `--birth-sync 1` and `--birth-continue 1` exit 2 |
| G-1, I1, P0, NODOS, include rules | all | headless | `ext_g1.py check` (steps 3, 6), obs_lint's I1 rule, `nodos.py`, `registry.py check` (D11's rule for `present/bs`), `ext_p0.py` V0..V7 | pass: EXT_G1_OK runs 77 (amended 1) in Checked and CheckedNoObs; OBS_LINT_OK files 97 probes 203 callsites 98; NODOS_OK and REGISTRY_OK in all three variants; P0_OK (Checked 304, CheckedNoObs 56) |
| 7.9 DOS-oracle comparisons | - | not run (optional) | - | not run |
| agent UI check | - | none in BS | - | not done |
| user checks | the Windows Birth's pace, switching, fades, the end, the skip, without DOS data | user | `manual-checklist-ext.md` BS-1..BS-6 (to add, "For the records") | pending |

Verdict: **the BS gate is met**: tests 1..8 pass headless in Checked (the refusals and unit tests in CheckedNoObs
and Release too), with G-1, P0 and every existing expectation unchanged (BS is off by default in the harness).
Not part of the verdict: the DOS-oracle comparisons (none), the agent UI check (none), Asan (deferred), the
user's checks BS-1..BS-6 (pending) and the items under "Not verified".

**D4-22** ("With the Windows graphics visible, the Windows Birth movie plays to its end as before", passed
2026-10-15 about 13:51 UTC) is superseded by **BS-4** when the DOS data are found (the user's direction of 14:03
UTC; Rulings 19:20): the setup follows the DOS Birth's end with either graphics shown. It still holds without
the DOS data (**BS-6**; `ext_continue.py`'s `nodos` and, with BS off, `win`).

## The final cycle

The BS phase gate ran the eight-step cycle with CY's runner (`build/bs34-stage/bs-cycle.ps1`, detached). Status
`build/bs-status.txt` (ends ALL_GREEN), logs `build/bs-<n>-<step>.log`. Step 1, `build.cmd all`, builds
Checked, CheckedNoObs and Release at the same time, so it is also steps 4 and 7:

| Step | Command | Exit | Seconds | UTC | Last line |
| --- | --- | --- | --- | --- | --- |
| 1 (with 4 and 7) | `build.cmd all` | 0 | 233 | 23:35:27..23:39:19 | BUILD_ALL_OK variants=Checked,CheckedNoObs,Release |
| 2 | `test.cmd checked` | 0 | 1128 | 23:39:19..23:58:08 | TESTS_OK variant=Checked |
| 3 | `ext_g1.py check` | 0 | 0 | 23:58:08 | EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) |
| 5 | `test.cmd checked noobs` | 0 | 387 | 23:58:08..00:04:35 | TESTS_OK variant=CheckedNoObs |
| 6 | `ext_g1.py check --variant CheckedNoObs` | 0 | 0 | 00:04:35 | EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) |
| 8 | `test.cmd` | 0 | 329 | 00:04:35..00:10:04 | TESTS_OK variant=Release |

Steps 5..8 ran on 2026-10-16 UTC.

* **Step 1.** BUILD_ALL: Checked 226.7 s, CheckedNoObs 226.7 s, Release 215.7 s (concurrently); 281 portable
  sources.
* **Markers, Checked** (step 2): TEST_SECTIONS 24 parallel, budget 20, wall 1126.5 s, failed 0; 46 test
  programs, 0 failures (`test_pbs_assets` 58, `test_pbs_movie` 44, `test_pbs_view` 45, `test_pdos_seq` 125,
  `test_present` 997, `test_input` 234); REGISTRY_OK, NODOS_OK, GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK,
  P4_TESTS_OK, OBS_TABLES_OK probes 203 sites 98, OBS_LINT_OK files 97 probes 203 callsites 98, ADAPT_OK rows 38
  steps 12, P0_OK checks 304, EXT_FRAMES_OK, EXT_TIMELINE_OK (the base group and the `bs` group), EXT_CONTINUE_OK
  (31 checks), EXT_BS_OK (assets 10, mirror 16 checks), EXT_ADAPT_OK checks 56, MIRROR_OK runs 29, ZOOM_OK
  combinations 32 runs 64 samples 388, TRACE_OK; COVERAGE other functions entered 661. Sections (start, end,
  seconds): `ext_p0` 0.0..936.2 (936.2, the longest), `bs1_assets` 38.5, `bs2_mirror` 23.4,
  `bs3_timeline` 79.4, `ext_timeline` 73.9, `ext_continue` 56.9.
* **Markers, CheckedNoObs** (step 5): TEST_SECTIONS 24 parallel, budget 20, wall 384.6 s, failed 0; 46 test
  programs (`test_pbs_assets` 58, `test_pbs_movie` 44, `test_pbs_view` 45, `test_pdos_seq` 125, `test_present`
  997, `test_input` 207); REGISTRY_OK, NODOS_OK, GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK, P4_TESTS_OK,
  OBS_TABLES_OK, OBS_LINT_OK, ADAPT_OK rows 38 steps 12, P0_OK checks 56, EXT_CONTINUE_OK (`--birth-continue`
  and `--birth-sync` refused), EXT_BS_OK twice (`--bs-check`, `--bs-mirror` refused), TRACE_OK.
* **Markers, Release** (step 8): TEST_SECTIONS 24 parallel, budget 20, wall 327.3 s, failed 0; 46 test
  programs (`test_pbs_assets` 58, `test_pbs_movie` 44, `test_pbs_view` 45, `test_pdos_seq` 125, `test_present`
  997, `test_input` 234); REGISTRY_OK, NODOS_OK, OBS_TABLES_OK probes 203 sites 98, OBS_LINT_OK files 97 probes
  203 callsites 98, ADAPT_OK rows 38 steps 12, TRACE_OK.
* **Deferred variants covered.** The binaries are the tree at 23:35 UTC, so this cycle is also the first
  CheckedNoObs and Release test run of the units landed since the D4 gate with three-step cycles (Checked tests
  only): D4cF (`build/d4cf-status.txt`; its record: "CheckedNoObs and Release tests run at the next phase gate
  (BS)") and UX1 (`build/ux1-status.txt`), and the first phase gate on CY's parallel runner.

## User checks left pending

`manual-checklist-ext.md`, a new BS section (BS4 record, "What the user checks after BS4"; a Checked or Release
civ64 with the DOS data located): **BS-1** the Windows Birth's pictures change and its captions come and go with
the DOS Birth's; **BS-2** a switch at any moment shows the same picture and line, without restart; **BS-3** the
Windows fades short like the DOS ones, the pictures and captions as in the native Windows Birth; **BS-4** with the
Windows graphics shown, the setup follows the Birth's end without a black wait (with DOS shown as D4b4);
**BS-5** a key during the Birth (after the world is built) goes to the setup in both graphics; **BS-6** without
the DOS data the Windows Birth plays as before, native timing. All pending; no user build was made in the build
slot (the orchestrator's choice).

## Deviations (summary)

Each record lists its decisions within the brief; in brief:

* **BS1** (4): test 1 under the check-only `--bs-check 1`, not `--birth-sync 1` (Ruling 18:10); civ64 opens the
  store only from BS3 (Ruling 18:10); all eight pictures decoded at the open (about 1.5 MB); the text check
  attributes captions by the movie's own text items, not call order.
* **BS2** (4): the comparison point is the harness's frame hook (no new probe, D10); fonts and colours through
  the core (`w16q_draw_on`, `W16Q_OP_COLOR`; no new w16 query: the mirror's equality left no width mismatch); throttled presents after a fade's
  start compared only when the frame's other items are inert; the mirror only observes.
* **BS3** (6 within the brief, 3 at the landing): the store opened by `present_birth_sync(1)` in both civ64 and
  the harness; `pbs_core` extracted so the mirror and the view start the replica identically; the view composes
  whether the Windows profile is visible or not (T2); the hold keeps composing with f frozen; `bswatch` advances
  the view to the watch instant; `OBS_LISTENERS_MAX` 4 -> 6. At the landing: the note-4 early-out in `compose`
  (and `frame_ready` cleared when the frame is freed); the `bs` group's own scripts `bs_birth`, `bs_skip`;
  `bs2_mirror` after `bs1_assets`.
* **BS4** (3): the bridge `pdos_profile_bs_active` beside `pdos_profile_visible` in `pdos_profile.c`; the test
  query a separate setter `pdos_seq_set_bs_query`, not a third `PdosSeqQ` field (D4c2's tests fill that struct
  field by field); test 8's `bs_off_win` is the existing `win` run.
* **The tests against 5.2's wording.** Test 4's "the Windows presented frame equals the shadow replica's frame
  for the table's f" is shown by its parts, not by a second replica in the harness: every `bs f` line's f equals
  W (check 2), the view's frame is its replica's client composed into the live screen (`test_pbs_view`), the
  replica equals the core at every present (test 2), and ten model goldens of the presented frame. Test 4's
  partition independence (12 random tick partitions) is in `test_pbs_view`, not a harness run. Test 6's hold has
  zero length in `bs_skip` (the core's skip, Birth end and setup fall on one instant, 30,100,200 µs, as D8
  expected), so the harness's "held" check covers an empty interval; the hold itself is unit-tested (test 3).
  Test 7's scenario list has `settlers` where a first private run had `display16` (it stops at the title menu and
  never reaches Birth). `ext_bs.py`, `ext_timeline.py`, `ext_p0.py` and `ext_continue.py` gained `--exe`,
  `--root`, `--port` for private runs (defaults: the tree's build).

## Asan

**Deferred** (the user's direction of 2026-10-10 21:20): no Asan build or run in BS. Due at the end of the queue:
`test_pbs_assets` (the truncation and corruption vectors, test 1's "ASan in the final pass"), `test_pbs_movie`,
`test_pbs_view` and the harness runs with `--bs-check`, `--bs-mirror`, `--birth-sync`.

## For the records

Gathered from the four records for a docs agent (none applied yet; the build slot changed only BS's files and
the listed merges):

| Unit | Its "For the records" | Applied |
| --- | --- | --- |
| BS1 | [ext-BS1-record.md](ext-BS1-record.md): DESIGN 12.10 (`host_data_read`, a host.h addition beyond 5.1's two), 12.8; RUNNING (`--bs-check`, `ext_bs.py assets`); STATUS | **to apply** |
| BS2 | [ext-BS2-record.md](ext-BS2-record.md): DESIGN 12.8; RUNNING (`--bs-mirror`, `ext_bs.py mirror`); STATUS; FIDELITY (the replica equals the core's screen, the 256-colour path) | **to apply** |
| BS3, BS4 | [ext-BS3-record.md](ext-BS3-record.md) and [ext-BS4-record.md](ext-BS4-record.md) (BS4's list covers both): DESIGN 12.8 "Added in BS" (after "Added in D4c2"), 12.10 (`host_data_read` row; `OBS_LISTENERS_MAX` 4 -> 6), 12.11 (the 5.1 relation exception D9; the D4b4 exception extended, D7); FIDELITY F155 updated and a new row (the Windows Birth's pace with the DOS profile registered, a **choice**); RUNNING (`--birth-sync`, `ext_timeline.py --group bs`, V8/V8s, `ext_continue.py` 31 checks, the logs, civ64's behaviour); FEATURES (the D4b4 row, a new BS row); manual-checklist-ext BS section BS-1..BS-6 and D4-22's note; STATUS | **to apply** |

The BS gate's own entries (to apply):

* **STATUS.md**: unit BS **complete** (this record, 2026-10-16): BS1..BS4 landed together at 23:35 UTC, the gate's
  eight-step cycle ALL_GREEN (`build/bs-status.txt`, 2026-10-15 23:35:27 UTC .. 2026-10-16 00:10:04 UTC), which is
  also D4cF's and UX1's deferred CheckedNoObs and Release run. "Last build and test results": a BS-gate row with
  the markers of "The final cycle". Session log: the landing (bases, the three merges, the two runner races
  removed) and note 4's measurement. User checks BS-1..BS-6 pending; D4-22 superseded by BS-4 with the DOS data.
* **DESIGN.md 12.8**: "Added in BS" also names the landing's changes: `compose`'s early-out (note 4).
* **RUNNING.md** and **ext-CY-record.md**: test.cmd now has 24 sections (21 + `bs1_assets`, `bs2_mirror`,
  `bs3_timeline`), so the "21 sections" and `TEST_SECTIONS 21 parallel` wording becomes 24; the extension's
  sections sit between "extension BS (begin)" and "(end)" comments; `ext_p0` est 600, `ext_continue` cpu 8 est 90.
  The portable source count is 281 (`present\bs\*.c` in build.cmd's loop).
* **FIDELITY.md**: no gate entry beyond the units'; the DOS timings stay **DOS listing (model)**, the Windows
  pictures and captions **Windows data**.
* **manual-checklist-ext.md**: the BS section (pending) and D4-22's note, as BS4's entry says.

## Not verified

* **DOS-oracle comparisons (7.9)**: none. The DOS Birth's instants that BS follows are area C's model (DOS listing
  (model)); BS's goldens pin the composed output, they do not prove it against DOS.
* **The 16-colour and monochrome paths** (3.5): BS stays off there by design; no run exercises them.
* **Agent UI check**: none; civ64's visible Birth with the DOS files (BS on by default, `civ64_present_defaults`)
  is compiled and shares `present_birth_sync` with the harness, but was not watched. The visible behaviour rests
  on the user's checks.
* **User checks** BS-1..BS-6: pending.
* **Asan**: deferred.

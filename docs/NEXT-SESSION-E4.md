# Hand-off prompt for session E4 (civ64 extension: scaling, zoom, DOS profile)

Written 2026-10-17 about 07:15 UTC by session E3's orchestrator, when the user said "stop and provide a full
hand-off prompt for the next session". `docs/STATUS.md` stays the authority for the current state;
`docs/EXT-HANDOFF.md` holds the full history of E1..E3.

## Prompt for the new session (paste this)

> Open, read and continue where session E3 stopped: `C:\Projects\Civ1RE\claude\docs\x64-port-scaling-dos-prompt.md`
> (the extension prompt, over the base prompt `claude/docs/x64-port-prompt.md`). Read first
> `C:\Projects\Civ1RE\claude\port\docs\NEXT-SESSION-E4.md` (this file), then `docs/EXT-HANDOFF.md` (its E3
> bullets and "Session E3 ended"), then `docs/STATUS.md`: "User directions" (all rows), "Extension track",
> "Test open items" and the last rows of "Session log" and "Last build and test results". Run the session-start
> hash check. Then continue autonomously through the whole queue below as the orchestrator, providing a user
> build per user-visible unit and never waiting for the user's checks (the user's direction of 2026-10-16 about
> 21:40 UTC), with a hand-off at 1 % usage left of any limit.

## 0. E3's unfinished wrap-up: do this first

The user's stop came before E3 finished these. Scripts are ready in `claude/port/build/e3-orchestrator/`.
1. **STATUS.md**: run `C:/Python314/python -B build/e3-orchestrator/status_e3end.py` from `claude/port`. It adds:
   * to the phase line, "D6 complete; D6 phase gate met 06:02:50" and "D7 staged only";
   * the D6 and D7 table rows;
   * two session-log rows: the D6 gate, and E3's stop with the back-out.
   Re-read STATUS first, because the checks chat edits it. If an assert fails, apply the same content by hand. The
   D6 gate was never entered there: its docs pass was planned to run together with D7a's.
2. **EXT-HANDOFF.md**: run `build/e3-orchestrator/handoff_e3end.py`. It adds the "Session E3 ended" section before
   "Session E2 ended" and points the paste prompt to this file.
3. **The docs pass for the D6 gate**: apply `docs/ext-D6g-record.md` and `docs/ext-D6-acceptance.md` "For the records"
   (DESIGN, FIDELITY from F204, RUNNING, FEATURES, DOS-PROFILE; marker `build/docs-d6g-done.txt`). Add D7a's records
   to this pass once D7a lands.
4. **Rebuild Checked** (`build.cmd checked`). `build/x64/Checked` still holds D7a's backed-out build of 06:58 UTC
   (`build/d7a-prep/BACKED-OUT.txt`). The sources are verified back at the D6 gate's state: 20 files restored, 4
   removed, 5 references equal. The D7a agent was force-stopped before its rebuild.
5. Tell the checks chat (see 5. below) that E4 has started, and where this file is.

## 1. State at the end of E3 (2026-10-17 about 07:15 UTC)

* **The tree** is the **D6 phase gate's** state: eight-step cycle ALL_GREEN 2026-10-17 06:02:50 UTC
  (`build/d6-gate-status.txt`), the full zoom matrix GOLDEN_CMP_OK, Z-1..Z-3 PASS, the agent UI check
  (`build/ext-d6-ui/`); records `docs/ext-D6g-record.md` and `docs/ext-D6-acceptance.md`. D7a's copy-in (06:54)
  was **backed out** at the stop (BACKOUT_OK for the sources; Checked binaries stale, see section 0; `build/d7a-prep/BACKED-OUT.txt`; verify the tree against the D6 gate's
  manifests before anything else: `build/d6f-prep/landed.sha256`, `build/d6g-prep/landed.sha256` and
  `build/d6g-prep/docs-landed.sha256`, plus the docs passes' markers listed below). If the back-out record is
  missing or not OK, restore the files listed in `build/d7a-prep/landed.sha256` from `build/d7a-prep/tree-before`,
  delete the files D7a added, and rebuild Checked.
* **Landed in E3** (each with a three-step cycle ALL_GREEN, a Release build and a user build under
  `claude/port/build/user-builds/<unit>/`): SL, D6d (+D6cF), UX4, D5P, UX4b, MZ, MZW, UX5, MZI, SI, MZS, D6e, TLD,
  FCE (first cycle failed on registry.py's include rule, fixed, -r2 green), D6f; the D6 gate (D6g). Docs passes:
  docs-mzw, docs-mzs, docs-tld, docs-d6f (markers `build/docs-*-done.txt`). **FIDELITY's next free number: F204.**
* **The newest user build** is `build/user-builds/d6g/` (the gate's Release; every pending item can be checked
  there). Each build holds the Release `civ64.exe`, `CIVWIN.zip` and `civdos.zip` copied from `user-builds/d4`, and
  `WHAT-TO-CHECK.txt` whose "Still open" part is built from the checklist's pending rows at landing time.
* **Checklist** `docs/manual-checklist-ext.md` (CRLF), as the checks chat left it at about 07:08 UTC (doc version 38
  of the results page): 223 items, 162 passed, 58 pending (53 checkable; 5 not yet implemented: D6-1, D5-7, D6f-1,
  D6e-5, UX5-5), 3 superseded. The user's results of about 06:50..07:00 UTC are entered as **failed** rows with
  their rework unit named:
  * D6-1: failed (the 06:53 answer, the 06:58 reversal to 2x, items 4 and 5); rework D6fS.
  * D5-7: failed on items 4 and 6 (highlight, box height); rework D6fS.
  * D6f-1: failed on items 4 and 5 (highlight, Windows menu contents); rework D6fS.
  * D6e-5: failed on item 2 (End of Turn blink); rework DBL.
  * UX5-5: failed on item 3 (squashed title before Birth); rework UX5b.
  * D6c-5 (passed 2026-10-16) stays passed with a note: item 1, unit DBL. DBL's new items check the blink.
  
  These pending rows will be out of date after the reworks; rewrite them at those landings:
  * D6f-4 (Alt+C and Alt+H open the CITY and HELP menus): D6fS.
  * D6f-5 (the Game Help box height): D6fS.
  * D6e-2 (the active unit's blink on the World Map): DBL.
  
  STATUS "User directions" has a row at about 07:05 with the six items verbatim and the D6-1 answer and reversal.
  The checks chat corrected the times: the list arrived about 07:00 UTC and the reversal about 06:58. Re-read the
  checklist and STATUS before planning; the user may have entered more since.
* **Hash checks** at E3's end: HASH_AFTER_OK (38 files) and DOS_HASH_AFTER_OK (176 files),
  `docs/hashes/20261017T070311Z-*.txt`.

## 2. The user's latest feedback (2026-10-17, via the checks chat), not yet implemented

* **D6-1** (build d6f), 06:53 UTC: "1x is acceptable but menu items are looks like 2x, they have to be scaled
  effectively." Then, asked whether boxes should go to 1x too (about 06:58): "Changed my mind draw top menu at 2x,
  they all have to be consistent." -> the DOS menu bar's titles at **2x**, consistent with the 2x drop-downs,
  boxes and map.
* **Revision list** (about 07:00 UTC), verbatim:
  1. "DOS units blinks at slightly faster rate"
  2. "End of turn blinks at slightly faster rate"
  3. "After DOS intro when switching to Birth scenes, momentarily title screen is squashed to square aspect and
     then switches to Birth scenes, this transition shall be seemless."
  4. "In game DOS Menus highlights selection, in real DOS game there is no highlighting present."
  5. "DOS Menus still uses windows menu contents, DOS graphics shall exactly reflect DOS game menu and its contents"
  6. "Implemented DOS graphics popup menus' height (such that Tax and Luxuries Rate but not limited to them) is
     higher than their content, this is not the case original DOS game."
* Rework units created (staged, not landed; each stage dir has a `STATE.md` written at the stop):
  * **D6fS** (`build/d6fs-stage/`): items 4, 5, 6 and the 2x bar. Rulings given: in the DOS graphics the menu bar
    and drop-downs are the DOS game's own (titles GAME, ORDERS, ADVISORS, WORLD, CIVILOPEDIA; DOS items and texts
    from the listing's menu tables; ORDERS built per square as DOS does, L25 R:1C84:01D8, from the core's state
    via `w16q_read`; each DOS item mapped to the core's equivalent command; Windows-only items (Edit, City, Help)
    only in the Windows graphics); no highlight where the DOS listing draws none (verify R:1D05 and callers; the
    user's observation is the target); every DOS box and drop-down exactly as tall as its content, the Windows
    dialog hidden by filling its rectangle from the A canvas beneath (reverses Choice D6f-6, F202); supersedes
    R1/R2, Choice D6f-3 (F196/F197 to rewrite). Only the menus (not the "DOS play-screen layout" add-on). An
    interim plan was requested before staging.
    **At the stop:** research only, nothing staged and no bases taken. The interim plan was never sent, so the
    next session should get it from the new agent before staging. Findings so far (`STATE.md`):
    * The 2x DOS bar (16 rows) fits the Windows bar strip (18 rows, y 22..40) with no host change.
    * Laying the five DOS titles at the DOS game's x positions times 2 fits the 640-pixel strip.
    * The menus run from R:1C84:0000, and the chosen item reaches the main loop as a key in DGROUP:D4CA.
    * The GAME menu's items are read; its jump table is not.
    * ORDERS (R:1C84:01D8) and the input loop R:1D05:0475 (the highlight question) are not read yet.
    * Drop-downs can be hidden using w16's saved pixels under the popup.
    * Dialogs have no saved copy of what lies beneath them, so hiding them that way is still open.
  * **DBL** (`build/dbl-stage/`): items 1 and 2: in the DOS graphics each blink (the active unit on the map and
    small map, "End of Turn" in the unit panel) at the DOS game's own period (TIMING.md, the listing) as a
    presentation clock; the core still decides what blinks; Windows unchanged; timing tests.
    **At the stop:** research only, nothing staged. All three DOS-profile blinks currently follow the core's
    Windows blink, BlinkActiveUnitUntilInput 11C0:0EC2, which takes TickCount % 60: a 1 s period, half shown.
    The documented DOS blink, R:0866:0AD6 called from R:0403:0655, shows each phase for 10 frames (20 frames in
    all), about 0.285 s at 70.086 Hz. That is 3.5 times faster than the profile now, yet the user sees the
    profile as slightly faster. **Settle this contradiction first.** Read the listing R:0866:0AD6..0CF4 and its
    caller instruction by instruction: the wait argument, the loops, any extra waits. Measure the profile's real
    period in the harness. Only then pick the clock. `pdos_fx.c`'s PdosBlink helper exists, but its 10/10
    constants belong to the text cursor.
  * **UX5b** (`build/ux5b-stage/`): item 3: no frame of the title at Birth's square shape (and no Birth picture at
    4:3); the shape changes exactly at Birth's first picture or on a black frame; also Birth -> the first setup
    page and switching at those moments; a test that fails on the squashed frame.
    **At the stop:** the cause is found from the source; it is not yet reproduced and nothing is staged.
    `pdos_seq_square_scene` (pdos_seq.c:1538) turns square at `set_bview(1)` (pdos_seq.c:460, the core's Birth
    probe). DOS Birth, however, first fades the shown title to black (pdos_birth.c:402, O7:1A39). Only then does
    it copy the first picture under a black palette (about pdos_birth.c:608, O7:1A59) and fade it in. So the
    fading title is shown square.
    Planned fix: go square only from O7:1A59, using the BS3 sync phase `PDOS_BS_FADE_IN` or a new flag in
    PdosBirthVars. Also check the Birth -> setup end, switching at both moments, the core-ends-first path and
    EARTH's map.pic load.
    Test: in `ext_aspect.py`, check every presented frame around both transitions, and prove the test fails on
    the base.
* **D7c's private preparation** under `build/d7c-stage/obj/` holds about 5.2 GB of copied build cache. It can be
  deleted. Keep `notes.txt` there: it has the DOS findings for Wonders, Historian, World Map and Top 5.
  * In the checklist these are the rework notes on the rows the checks chat marks failed; add the new sections
    (D6fS-.., DBL-.., UX5b-..) at each landing.

## 3. Staged D7 work (not landed; stage dirs with records or `STATE.md`)

D7 (`docs/verify/BRIEF-d7.md`, units D7a..D7o, each ending with the **three-step cycle**; the gate D7o with the
eight-step cycle) runs on **stacked tracks**: each unit stages on D7a's staged copies (bases recorded as
"d7a-stage" or "tree"), keeps its edits to the shared tables in separable blocks (pdos_scene_tab.c,
pdos_adapt_tab.c, pdos_adapt.c/.h bits, pdos_fontmap.c, pdos_prov.c, adapters.py, ext_adapt.py, test_input.c,
pdos_scene_check.py, DOS-PROFILE 1.7.2 regenerated, harness.c), and rebases mechanically at its landing. Joint
landings of stacked units in one three-step cycle are allowed (one user build, one Landing section per record).
Dependencies: a -> b, c, d, j; d -> e, f; a+f -> g; f -> h; a+h -> i; g -> k; j -> l; a+c -> m; k+m -> n;
all -> o.

* **D7a** READY (`build/d7a-stage/`, record `docs/ext-D7a-record.md` there; rebased on D6f 05:17 UTC): City
  Status as the DOS O14 report, the return's exit kinds and fade, page-2 portraits, T1, F1 fonts, I-report.
  **Fix before landing**: `pdos_scn_report.c` includes `<stdio.h>` and is missing from `gen/dos/registry.py`'s
  OBSERVER_FILES; `registry.py check` (test section d2_registry) fails on both (FCE failed the same way). Run
  `C:/Python314/python -B gen/dos/registry.py check` in the overlay before any landing. Its copy-in of 06:54 was
  backed out.
* **D7b** READY_TO_BUILD (`build/d7b-stage/`, on d7a-stage, record and `STATE.md` there): the advisors' reports (Military, Intelligence, Attitude, Trade, Science). PDOS_AS bit 0x04000000. Its own copy of `pdos_scn_report.c` needs D7a's registry fix too. Planned as a joint landing with D7a (user build "d7b").
* **D7c** not started (the World reports and the historian; then D7m). Only notes exist (`build/d7c-stage/obj/notes.txt`:
  Wonders, Historian, World Map, Top 5); Score O20:0CA9 and Demographics O12:0D6D are unread.
* **D7d** research and design complete, nothing staged (`build/d7d-stage/STATE.md` holds the whole design: module
  `pdos_scn_city.c/.h`, the session rules, the shadow owner, the map hooks in `pmap_dos.c`, the layout verified
  against the listing R:0D12:0045): the city screen as a **DOS-layout renderer from the core's state**
  (DrawTileToPortPixels 11A8:15CE writes raw bits with no probe; ruling 4's alternative) **accepted with
  conditions**: read-only via `w16q_read`, no core call, no RNG, self-check counters against the core's totals
  that must be 0 in every test run (a failing check), the core's totals win at run time, recorded as a deviation.
  Owner "city" and PDOS_AS_CITY 0x08000000. Gate notes: row 14's ROW_ALLOW ("unexplained 2" in `city`, the fill
  under dialog 136's box) goes with D7d; row 0 (the leader audience's span: row 100 from HoldDiplomaticAudience
  1160:0000, the leader font table `pdos_fontmap_set_leader_table`) goes with D7k. Then D7e, D7f, D7g on this
  track (later D7h, D7i, D7k).
* **D7j** staging (`build/d7j-stage/`): the palace renderer `pdos_scn_palace.c`, test_pdos_palace (114), T7 = row
  107, 7 I-palace rows, PDOS_AS_PALACE 0x40000000. Its staged `registry.py` adds `pdos_scn_report.c` to
  OBSERVER_FILES. Then D7l (the spaceship screens; 0x20000000 was planned for its scene bit).
  Remaining (its `STATE.md`): fix and run `obj/runadapt.py` (the d7j-palace pair), the `palace` entry in
  ext_timeline.py, BASE-SHA256.txt, CheckedNoObs and Release, cc.cmd, unit.py in all three variants, nodos, the
  registry check, the record `ext-D7j-record.md`, then READY_TO_BUILD.
* **Allocation clash to settle at landing**: D7d and D7j each raised PDOS_OWNER_MAX to 7 for their own owner
  ("city", "palace"); with D7a's 6 the combined value is 8 (and test_pdos_shadow's owner-limit check follows).
  Scene bits in use: D7a 0x02000000, D7b 0x04000000, D7d 0x08000000, D7j 0x40000000.

## 4. The queue (in order)

1. Session-start hash check (`build/e3-orchestrator/hashcheck.ps1 -Phase before`, copied there from E3's
   scratchpad: it checks `original/CIVWIN` and `dos/` against the references, writes `docs/hashes/`).
2. Verify the tree is the D6 gate's state (section 1).
3. The user's reworks first: D6fS, DBL, UX5b (staged as above; finish, land, user builds, checklist sections).
4. D7a (after its registry fix), then the D7 tracks (A: D7b, D7c, D7m; B: D7d, D7e, D7f, D7g, D7h, D7i, D7k; C:
   D7j, D7l), D7n, then D7o: the sweep, the reach and the **D7 phase gate** (eight-step cycle).
5. Docs passes after landings (they apply the records' "For the records"; landings wait for their marker
   `build/docs-<x>-done.txt`, because DESIGN.md and DOS-PROFILE.md are test inputs).
6. D8 (completion: FEATURES DOS columns, DOS-PROFILE, FIDELITY, RUNNING, checklist; D-6, D-7).
7. **WL**, the windowless play mode (queued; before X9, the user's direction of 2026-10-16 about 07:05 UTC; see
   EXT-HANDOFF's "Queued after the DOS profile"), with its gate.
8. **X9**, the final audit (an independent adversarial check of every section-4 item; the base suite unchanged;
   hashes; the final report) with its gate. Owner items for X9: the win64/civ64_main.c comments (UX4's
   remembered_placement); the coverage append race and torn lines in `coverage-civ_harness.txt` ("other
   functions entered" jitters 661..670); the GetKeyState flake in w32_test_host_win32 (lines ~1206/1240);
   DESIGN's cfg gap; the host.h, harness.c and cursor-factor comments; CY follow-ups; F195 (Escape in Windows
   Customize World writes -1 to worldParams[-200], 12D8:3764, harmless, original behaviour); the stale comments
   in `p49-findcity` and `ext_zoom.py` about Escape closing Find City; the old directory `claude/port/1/` of
   presented BMPs (2026-10-11; check before deleting).
9. The **one Asan pass** of the whole queue (build and test), only at the end.
10. Session-end hash check, a STATUS session-log row, the hand-off.

## 5. How E3 ran the work (keep doing it this way)

* **Orchestrator plus agents**, all on the session's own model (Opus; never lower it). One agent per unit or
  track, with exclusive files. Agents stage under `build/<unit>-stage/` only: full copies of changed files plus
  new files, `BASE-SHA256.txt`, `BUILD-TEST-ADDITIONS.md` (only if build.cmd/test.cmd change), private `obj/`
  overlay builds (Checked, CheckedNoObs, Release, the cc.cmd strict variants), the record
  `docs/ext-<unit>-record.md` with "For the records", "What the user checks" (`* **<UNIT>-1** text` in user
  words), "Expected changes at the build slot" and "Rebase notes". They report READY_TO_BUILD; the orchestrator
  gives **the build slot** (serialized).
* **A landing**: base re-check and rebase; snapshot to `build/<unit>-prep/before` (and `tree-before`); copy-in;
  `landed.sha256`; predictions written before the cycle; the **three-step cycle** (`build.cmd checked`,
  `test.cmd checked`, `tests/harness/ext_g1.py check`) with `build/<unit>-status.txt`; the comparison;
  `build.cmd release` (RELEASE_OK); the user build; a "Landing" section in the record. Known flake:
  w32_test_host_win32's GetKeyState checks (rerun that test alone, then the test step as -r2).
* **Before READY**, an agent runs in its overlay: `registry.py check`, obs_lint, `gen/obs_tables.py --check`
  (after any DOS-PROFILE.md edit; never add SSSS:OOOO call addresses there), pdos_scene_check, adapters, nodos.
  New present/dos files that include `w16_obs.h` go into registry.py's OBSERVER_FILES; no present/dos file may
  include `input.h` or `<stdio.h>`.
* **Checklist sections** are added by the orchestrator at each landing, from the record's "What the user checks":
  `build/e3-orchestrator/chk_lib.py` (`add_section(unit, heading, intro, src, build, when, extra_reps, rows)`;
  it inserts the section before the Count, updates the Count's totals, pending and checkable lists and the
  by-section list; examples `chk_tld.py`, `chk_mzs.py`, `chk_d6f.py`). Conventions: new items "pending (user build
  `build/user-builds/<unit>/`)"; reworked items keep their history after the new status; superseded items
  "superseded (not to be checked: ...)"; passes stand with "superseded in part" notes. The file is CRLF; edit it
  only through Python with explicit CRLF handling (never sed -i).
* **The checks chat** "x64 port scaling DOS prompt tasks" (session `local_219ea2fd-8160-431c-85cf-04f9b2c8bc60`,
  it runs the user's results page `https://claude.ai/artifact/39FD743uyWmkYesBTEkD3u`) records the user's answers
  in the checklist and STATUS, and asks to be told after every checklist change so it reloads the page. Check
  with ListAgents whether it is still alive; if it is, tell it E4 has started.
* **STATUS.md and the checklist are edited by other chats**: always read-modify-write fresh.
* E3's agents cannot be resumed from a new session; start fresh agents, pointing them at the stage dir, its
  record or `STATE.md`, and the brief.

## 6. Standing user directions (all still in force)

* Work autonomously; ask only real questions. Never stop for visual checks: provide user test builds in
  `claude/port/build/user-builds/<unit>/` and continue without waiting.
* The DOS rule (verbatim): "Yes: in DOS graphics never show a Go Back or Cancel row the DOS game doesn't have, on
  any screen; where DOS has a key for it (e.g. Escape), that key does it, otherwise that choice is only in the
  Windows graphics." Since 2026-10-17 also: the DOS graphics' menus shall exactly reflect the DOS game's menus and
  contents, with no highlight where DOS has none, and boxes as tall as their content; everything at 2x
  consistently.
* 4:3 for 320x200 DOS screens when "4:3 aspect ratio for 320 x 200 screens" is checked; only DOS Birth square.
* Never modify `C:\Projects\Civ1RE\original\CIVWIN` or `C:\Projects\Civ1RE\dos` (no files, attributes,
  timestamps); never run any DOS program on the host; no DOS bytes in the repository or a binary; never write
  `build/dosdata` or `build/gamedata`; never write the user's `%LOCALAPPDATA%\civ64` files (copy saves read-only;
  the user's test save is `MZTEST.SAV` there).
* No git writes or commits without a user request. Never read the main project's excluded paths
  (`verify/BRIEF-d0.md`); ignore AGENTS.md's GFX/DOS/Modern/Mac/SNES sections.
* Never lower the agents' model. Asan only once, at the end of the whole queue. No periodic progress reports.
  Hand-off at 1 % usage left. Hash checks at session start and end.
* Python only as `C:/Python314/python -B` (never `-I`). Bash heredocs drop backslashes: write scripts with the
  Write tool. Screenshots only of civ64 windows, under `claude/port/build/`.
* civ64 is single-instance since SI: start any civ64 of an agent's own with `--multi-instance`, and never touch a
  civ64 the user has open (one from `user-builds/d6f` was running at 06:13 UTC).

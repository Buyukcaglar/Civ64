# Extension phase D5, unit D5c (the DOS setup pages 0..2 and the T4 setup page, `pdos_scn_setup`; adapter I-setup) - record

Draft for the build slot (BRIEF-d5.md "Units" D5c).  Staged in `build/d5c-stage/` on D5b's stage (D5ab), D5b's
`obj/merge` pdos_seq.c/.h, D5a's and BS34's copies where D5b did not change a file, else the tree
(`BASE-SHA256.txt`).  Private builds and runs in `build/d5c-stage/obj/` only.

## Status

READY_TO_BUILD.  D5c is the first visible D5 unit: with `--graphics dos` the core's RunNewGameSetup (dialog 144,
DOS-PROFILE row 21) is shown as the DOS program's own setup screens, drawn from the DOS listing R:01A8:087C ->
O5:0000..0645 on page 0 of the N machine.  The core and its inputs are unchanged (P0 holds in all 24 ext_p0
scenarios privately).  The name pages (O23, RunTextInputDialog) stay D5d's: while the core's text page runs the
setup view is not shown (the A frame, as before D5c).

**Needed already by D5ab:** D5b's staged `pdos_reskin.c/.h` fail `gen/dos/registry.py`'s include rule
(REGISTRY_FAIL in test.cmd).  The fix is this stage's `gen/dos/registry.py`: OBSERVER_FILES gains
`"pdos_reskin.c", "pdos_reskin.h"` (and D5c's `"pdos_scn_setup.c"`).  Land those two names with D5ab, or land
D5c's registry.py, which carries all three.

## What was built

### The setup view (`present/dos/pdos_scn_setup.h/.c`, new; SCENES 9, 9.1..9.3; B 11.5; C.8.7, C.8.8, C.12.7)

* **Preparation** (R:01A8:087C..08A8): `DIFFS.PIC` with its palette into page 1 (R:1FA1:0220(1, "diffs.pic")),
  then O5:0000: page 1 copied to the screen (G#20, O5:0024) with the pointer hidden around it, font 7 (O5:0035).
* **The pages**: the frameless menu box R:0238:0008(text, 160, 35) (y odd: no frame; DGROUP:3936 taken as FFFFh,
  so no 8-pixel rows forced; font 7's line height is 9, which the box turns into 8-pixel rows, measured by
  test_pdos_setup), laid out and drawn by D4a's `pdos_menubox_*`:
  * step 0, difficulty: SETUP_DIFFICULTY (3526);
  * step 1, competition: SETUP_COMPETITION (357B) + for k = 7..3: itoa(k) + SETUP_CIVS (3595);
  * step 2, tribe: SETUP_TRIBE (35A6) + for i = 1..comp+1 the record i name + SETUP_TRIBE_SEP1 (35BB), then the
    record i+8 name + SETUP_TRIBE_SEP2 (35BE) (TRIBE_RECORDS 14E2, 3Ah bytes a record);
  * added rows (DOS has none): " Custom." on the tribe page below the tribes (orchestrator ruling 4: the core's
    item 0) and " Go Back" on every page (P17, B21; disabled on the difficulty page as the core's is, colour 3).
    Their texts are the core's control texts (radio 500, button 102) read under CIV_OBSERVER through
    `w16q_wnd_first/next`, '&' marks removed, folded to DOS bytes; the constants "Custom." / "Go Back" otherwise.
    The longest page (7 civilizations: 1 header + 14 tribes + 2) has 17 lines; at most (192 - 35) / 8 = 19 fit.
* **The results**: difficulty: FillRect(0, 0, 150, 200, 0) (O5:00C0), the level's portrait from page 1
  (x = 80 for an odd level, else 21; y = 35d + 6; 53 x 47) to (20, 100) (O5:00FB), page 1's (150, 0, 160, 200)
  restored (O5:0121); competition: comp = clamp(6 - r, 2, 6) (O5:0198..01B0) and the stack of portraits at
  (20 + 2k, 100 + 3k), k = comp..0 (O5:01C6..021B); tribe: the plural (+10h; empty: the name + SETUP_PLURAL,
  O5:052E..0558) centred at (46, 92) in colour 15 (O5:0587), then FillRect(150, 0, 170, 200, 0) (O5:0645).
  Each page is drawn as a replay of everything before it (the left part keeps the previous results, as DOS does).
* **Following the core** (`pdos_setup_sync` at every tick and core point): the core's setup MenuZ at step s gives
  the page s with the highlight on the row of the core's selection; each setup MenuZ exit (ra 10E8:0528,
  `PdosCore.setup_mz_exits`, new) with a choice gives that result (Go Back / Escape: -1, none; "Custom.": none);
  the tribe page's civilization count follows the core's item count ((items - 3) / 2).  A change of only the Go
  Back row's text or state redraws that row alone from a snapshot of page 0 under the box (B 11.5;
  `setup_text_diff` counts a differing text).  The view ends at play (RunNewGameSetup's exit) and at C.11.6.
* **T4** (C.8.7): DOS Birth reaches its setup step while the core still plays its Birth: the sequencer
  (`setup_check`) hands over once, at the frame of Birth's or the post-Birth timeline's setup step: the
  difficulty page, row 0, from that instant; the box's own row moves with the user's keys and drag (C.12.7
  T4 mode) until the core's MenuZ is ready and takes over.
* **The shadow owner "setup"** (B 7.5): the core's own drawing into dialog 144 (its backdrop, texts, the clears
  between its steps) is claimed for the DOS rule set and handled (nothing drawn, nothing unexplained); such a
  shadow is never attached to page 0.
* Step log (`pdos_seq_set_log`, as the Birth program's, seq 2): `setup_page` (arg step*256 + row), `setup_row`
  (R:1D05:0238), `setup_result` (arg step*256 + level / comp / row), `setup_goback` (R:1D05:0475).

### The sequencer, the profile, the scene table

* `pdos_seq.c/.h`: the hand-over (`setup_check`, before the Birth view's end in `run_to` and at the end of
  `on_event` / `on_probe`); the sequencer's scene rows (intro, movie, title, Birth, new game, EARTH, setup) kept
  ready while the setup view shows (`rows_apply`); `pdos_setup_abandon`
  at `unexpected()`, Birth's start and the reset; `pdos_seq_setup_fade()` (the post-Birth fade before the setup)
  and `pdos_seq_setup_view_row()` for the adapters; `PdosCore.setup_mz_exits`.
* `pdos_profile.c`: `pdos_setup_reset()` after `pdos_shadow_reset()`; `pdos_setup_on_event()` between the
  sequencer's and the shadow engine's on_event.
* `pdos_scene_tab.c`: row 21 PDOS_RD_REPLAY -> PDOS_RD_SCRIPT (drawn by the sequencer's setup view);
  `pdos_setup_goback_text[] = "Go Back"` (B21's constant, Windows text).
* `pdos_common.h`, `pdos_assets.c`: diag counter `PDOS_DIAG_SETUP_TEXT` ("setup_text_diff").

### The input side (`pdos_adapt.c/.h`, `pdos_adapt_tab.c`, `gen/dos/adapters.py`; C.12.7, C.13.6 example 4)

* Scenes PDOS_AS_SETUP0/1/2 (the page with its box and row map), PDOS_AS_SRESULT, PDOS_AS_SFADE; actions
  PDOS_AA_GOBACK, PDOS_AA_PORTRAIT, PDOS_AA_LREL_DIS; action PDOS_A_BUTTON (a click on the setup dialog's button
  102); `PdosAdaptSc.rmap/nrmap/ncore`; hooks `setup_view_row`, `goback` (appended to PdosAdaptHooks).
* 26 I-setup rows (75 rows in all): fade, result, alt-right, edge, up-down (core ready / T4), goback,
  return, space, escape (difficulty: level 0 "Chieftain" as C + Return; competition: consumed, asked again;
  tribe: the core's "Custom."), hotkey (core ready / T4), choose (T4 / core wait), key, press,
  release-disabled, release (core ready / T4 / core wait), portrait (x < 135: clamp((y - 12) / 35, 0, 4)),
  outside (difficulty: level 0; tribe: Custom.), release-other.  Row k of the tribe page is the core's item
  k + 1; the Custom. row is item 0.
* Up / Down pass only when the core's wrapping move over its items lands on the item of the box's next row;
  otherwise an edge (consumed).  The Go Back row is reached by the mouse only.
* `DOS-PROFILE.md` 1.7.2 regenerated (`adapters.py gen`: rows 75); nothing else in DOS-PROFILE.md changes.

## F2 / F5 per call site (BRIEF-d5.md)

* F2 (the sprite arena of each G#18 against the grabs before the next G#18): not applicable: O5:0000..0645 has no
  G#18.  Its drawing calls are G#20 copies (O5:0024 page 1 -> screen; O5:00FB, O5:01FE..0216 portraits; O5:0121,
  O5:03BA restores), R:0000:0BFA fills (O5:00C0, O5:0645), the menu box R:0238:0008 (its y and x pushed at
  O5:004A/004E, 017C/0180, 03C8/03CC; the tribe page's call O5:03D3) and the centred text (O5:0587).
* F5 (G#31's ghost pointer before a copy from that page): none.  Every copy reads page 1, where G#31 never draws
  the pointer (it draws on the screen page); the one full copy to the screen (O5:0024) runs with the pointer
  hidden (R:01A8:0268 .. R:01A8:0250).

## OFFSETS.md rows (ruling 2)

SETUP_DIFFICULTY 3526, SETUP_COMPETITION 357B, SETUP_CIVS 3595, SETUP_TRIBE 35A6, SETUP_TRIBE_SEP1 35BB,
SETUP_TRIBE_SEP2 35BE, SETUP_PLURAL 35C1 (strings), TRIBE_RECORDS 14E2 (928 bytes; writers R:0403:380E, 381F,
3830 store only the words +30h..34h in play, which the setup does not read) and a Notes bullet.  Regenerated:
`present/dos/pdos_registry.h/.c`, `tests/dos-decoded.txt` (REGISTRY_OK; nodos OK).

## Tests

* `tests/test_pdos_setup.c` (new, real store, structure only): the T4 page (page 1 = DIFFS.PIC and its palette,
  page 0 = page 1 outside the box, box at (160, 35) frameless, 6 rows, Go Back disabled, row map), the
  takeover (only the highlight moves), a new Go Back text (only its row band, setup_text_diff 1), Go Back enabled,
  the three results (portrait, stack, plural in colour 15 with x >= 150 black), the competition and tribe pages
  (row maps, the stack kept, the right part restored), Custom. (no result), the text page, play, abandon, the
  7-civilization page (all 17 lines drawn) and the shadow owner (claimed, explained, not page 0).
* `tests/test_input.c`: 26 I-setup vectors on the synthetic box as a setup page, `adapt_setup` (T4 row move,
  the tribe page's Up/Down rule, the Go Back hotkey, the Go Back release clicking button 102, the drag
  highlight), the row count 75.
* `tests/test_pdos_seq.c`: the three post-Birth checks now expect the setup page (the Birth steps still equal
  the reference; the setup steps are skipped in that comparison).
* `tests/test_pdos_profile.c`: the engine's N-window checks use row 19 (dialog 142, which no D5 owner claims);
  a new check: dialog 144's window is the setup owner's.
* `tests/harness/ext_timeline.py`: `birth` check 3 and `birth_skip` expect the setup page (step `setup_page` at
  the hand-over, the N frame after the core's setup); golden `bgolden frame 12000` updated.
* `tests/harness/ext_adapt.py`: C.15.4 case 9, four DOS-form pairs (below).

## Results (private, `build/d5c-stage/obj/`)

* Strict c11 / c17 / clang C99 of every changed product source, Checked, CheckedNoObs, Release: CC_STRICT_OK.
  `cc all` (every portable source, all 35 tests, the harness, civ64.exe) in the three variants: CC_ALL_OK.
* Unit tests, three variants: all pass except two private-only failures with known causes: `test_dos` (reads the
  tree's tests/dos-decoded.txt; its output equals the staged golden) and `test_pdos_profile`'s UX1 cursor check
  (the overlay is D5b's src-base snapshot, taken before UX1 landed; the tree has UX1's pdos_cursor.c).
* lint (D5b's obs_lint.py over the overlay): OBS_LINT_OK files 101.  registry check: REGISTRY_OK.
  adapters check: ADAPT_OK rows 75 steps 19.  obs_tables --check: OBS_TABLES_OK probes 203 sites 98.
  pdos_scene_check: PASS 1075 checks.  nodos over the staged files and the private binaries of three variants:
  NODOS_OK (166 files, 0 hits).
* ext_p0 matrix, base (D5b src-base) against D5c, Checked: **P0 PASS in all 24 scenarios** (core trace, events,
  exit status).  DOS samples differ only as listed below; Windows samples equal everywhere.
* ext_timeline (staged copy, private root): base group: every check passes but `birth` 4 at frame 12000 against
  the unstaged golden (the new hash is the staged golden's); bs group: EXT_TIMELINE_OK.
* ext_adapt case 9 (staged copy through `obj/adapt_case9.py`, every output under the stage): ADAPT_CASE9_OK, the
  four pairs equal (coreinput, frames, snapshot/result, events, exit) and decided by the expected rows.

## Expected changes at the build slot (DOS frames)

1. **ext_p0 `profiles.log` DOS samples** (only the `dos` field; P0 and the Windows field unchanged):
   * `birth`: 326 samples from 172.4 s to the end: the T4 difficulty page (row 0) from the hand-over (DOS
     Birth's setup step, frame 10493) instead of R:01A8:087C's black screen, and after the core's setup
     (198.3 s) instead of the A frame;
   * `new`, `s3`, `settlers` (24.6..30.5 s), `earth` (26.6..32.5 s), `custom` (30.6..36.5 s): 60 samples each,
     the difficulty page, the competition page with the portrait, the tribe page with the stack, the tribe
     result, instead of the A frame (the core's Windows setup dialog); equal again from the name page (D5d).
   * The other 18 scenarios: no difference.
2. **presentation-diag.log**: a new line `pdos.setup_text_diff 0` in every run; `pdos.unexplained` lower where the
   setup runs (birth 680 -> 670, new / s3 675 -> 615, earth 602 -> 541, custom 640 -> 580, settlers 670 -> 610):
   the core's dialog-144 drawing is the setup owner's.  (pmap timing lines vary run to run, not D5c.)
3. **ext-timeline-golden.txt**: `bgolden frame 12000` a74dd7dc... (black, = frame 69) -> d67d465f3620f1c6...
   (the T4 difficulty page); `bsgolden` unchanged.
4. **ext_timeline** `birth` 3 and `birth_skip`: the first show after the core's setup was 640x480 (A frame); now
   the 320x200 N frame (the setup page), with a `setup_page` step at the hand-over.
5. **dos-decoded.txt**: 8 rows more (the OFFSETS rows above).

## Build-slot steps (after the BS gate, after D5ab)

1. Land the staged files on the tree after D5ab (rebase notes in BASE-SHA256.txt: DOS-PROFILE.md takes the
   landed text with 1.7.2 regenerated by the staged adapters.py; test_pdos_profile.c is already the landed UX1
   copy plus D5c's hunks).  Run `gen/dos/registry.py gen` + `check`, `gen/dos/adapters.py gen` + `check`,
   `gen/obs_tables.py --check`, `gen/dos/nodos.py check`.
2. `build.cmd` (every variant) and `test.cmd` (unit, registry, adapters, lint, scene check): all pass, with the
   counts in BUILD-TEST-ADDITIONS.md (test_pdos_profile and test_dos then pass).
3. Harness: ext_p0 (P0 PASS; the DOS sample differences of "Expected changes" 1-2), ext_timeline (both groups OK
   with the staged golden), ext_adapt (all pairs, including d-setup-escape, d-setup-portrait, d-setup-tribe,
   d-setup-goback).  Then the user build.

## Decisions and deviations

* Dialog 144's core drawing is handled by a shadow **owner** ("setup", claim + on_draw + on_copy) rather than
  DROP macros: the core draws into the dialog inside MenuZ and outside any probed function, so no bracket
  covers it.
* The setup box is drawn on **page 0** by the DOS code path (a class-N scene), not as a D5b re-skin element;
  `pdos_ui_box(PDOS_BOX_SETUP)` (B's name) is declared in pdos_scn_setup.h, not pdos_ui.h.
* Go Back's row-only redraw uses a **snapshot** of page 0 taken just before the page's box was drawn.
* **Up / Down**: passed only where the core's wrapping move lands on the box's next row (MenuZ wraps over its
  items; the box does not): the tribe page's first row, the Custom. row and the Go Back row are edges.  The Go
  Back row is reached by the mouse only.
* The drag highlight and the T4 row move change the box's own row only while the core's MenuZ is not ready;
  once ready, the highlight follows the core's selection.
* **Ruling 4**: the added "Custom." row below the tribe rows (item 0); Escape and a release outside the box on the
  tribe page also choose it (the DOS -1).
* The fade (PDOS_AS_SFADE) consumes all input while DOS Birth's or the post-Birth timeline's fade runs before
  the setup (also in T4); keys on the competition and tribe pages while the core's MenuZ is not ready are
  consumed (I-setup/key, release-other).
* DGROUP:3936 assumed FFFFh (h8 = 0) on the setup pages, as at the title (not read from a DOS run).
* O5:05B6..0629 (O5:07C7, O5:0FE6: the civilizations' initialisation after the tribe choice) is not modelled:
  it draws nothing the setup view shows.
* Row 21 is PDOS_RD_SCRIPT (the sequencer's view), no longer PDOS_RD_REPLAY.
* New diagnostic counter `setup_text_diff`: every diag listing gains one line.
* Found by test_pdos_setup and fixed before staging: the takeover's row lookup used an unlaid box (`row_of_item`
  now walks the built rows).

## What the user checks (DOS graphics, after landing)

Start a new game with `--graphics dos` (or the DOS graphics chosen in civ64), and:

1. **Difficulty page**: after Birth (also when Birth is skipped) the DOS screen DIFFS.PIC with the five
   portraits at the left and the frameless menu at the right (Chieftain .. Emperor) plus a greyed "Go Back" row.
   If Birth's story ends before the movie, the page appears while the Birth movie would still run, and the
   arrows / mouse move the bar there already.
2. **Choosing**: arrows + Return, Space, a hotkey, a mouse click on a row, a click on a portrait (that level),
   Escape (Chieftain).  The left part then shows only the chosen level's portrait.
3. **Competition page**: "7 .. 3 Civilizations" plus "Go Back"; the chosen portrait stays at the left; after the
   choice the stacked portraits (one more than the rivals).  Escape does nothing here (DOS asks again).
4. **Tribe page**: the tribe names as one list (the first group's, then the second's), then "Custom." and
   "Go Back"; the portrait stack stays
   at the left.  After a choice: the right part goes black and the tribe's plural name appears in white above
   the portraits, then the (still Windows) name page follows.  Escape or a click outside the box = Custom.
5. **Go Back**: a click on the Go Back row on the competition or tribe page returns to the previous page; the
   difficulty page's Go Back is grey and does nothing.
6. **The menu-box look** (D5b, in the same build): the re-skinned DOS menu boxes of the other Windows dialogs.

## For the records

* FIDELITY: the setup pages are transcribed from the DOS listing (O5:0000..0645, R:01A8:087C..08A8), with the
  added Go Back / Custom. rows, the Up/Down edge rule and the mouse-only Go Back as deviations (above); font 7
  rows are 8 pixels (FontLineHeight 9); DGROUP:3936 assumed; O5:05B6..0629 not modelled.
* FEATURES / STATUS: DOS setup pages (difficulty, competition, tribe, the result screens, T4) under
  `--graphics dos`; the name pages remain Windows until D5d.
* The manual checklist: the six user checks above.
* DESIGN (B 11.5, B 7.5): dialog 144 is an owned shadow (no DROP brackets); pdos_ui_box lives in pdos_scn_setup.h.
* DOS-PROFILE: 1.7.2 regenerated only; the scene-table text of row 21 is unchanged (it names no render kind).
* The private overlay predates UX1's landing (pdos_cursor.c); the slot's tree build is the authority for
  test_pdos_profile's UX1 check.

## Landing (build slot, 2026-10-16)

D5 stager, in the build slot after the BS phase gate (`build/bs-status.txt` ALL_GREEN 00:10:04 UTC) and the
BS docs pass (`build/docs-bs-done.txt` 00:24:28 UTC).  One landing in the planned order: UX1b, then D5a + D5b,
then D5c (the latest copy of every file the three D5 stages changed).

* **Copy** (00:24:40 UTC, `build/d5l-prep/land.py`): 46 files, each only while the tree's file still had the
  expected SHA-256 (the base its copy or merge was made on; a new file had to be absent).  Manifest
  `build/d5l-prep/landed.sha256`; the tree's previous files in `build/d5l-prep/tree-before/`.
* **Rebase.** BS34 landed its staged copies unchanged for every file the D5 chain had based on them
  (`pdos_profile.c`, `test_pdos_seq.c`, `registry.py`, `ext-timeline-golden.txt`, ...), so 40 of the 46 files
  landed as staged.  `pdos_seq.c` / `pdos_seq.h`: the tree's (BS's merge of BS34 with D4cF, 918254a5... /
  199f161a...) is contained in D5c's copies: the change from the tree to D5b's merge (471a14fa... /
  7b0fdd69..., D5c's base) is D5a's own change (BS34's pre-merge to D5a) line for line, apart from one blank
  line (`build/d5l-prep/cmpdiff.py`), so D5c's copies landed as staged.  Three clean three-way merges
  (`git merge-file -p`, output to `build/d5l-prep/merge/` only, no conflict): `present/profile.h` (UX1b's
  comment on BS's file), `docs/DOS-PROFILE.md` (D5c's on the tree's UX1 paragraph and C2 row; base D4cF's
  staged copy) and `tests/harness/ext_timeline.py` (D5c's checks on BS's `bs_birth` / `bs_skip` scripts).
* **Regenerated / checked on the tree:** `gen/dos/registry.py gen` (159 files, 19 tables, unchanged) and
  `check` REGISTRY_OK; `gen/dos/adapters.py gen` (DOS-PROFILE.md unchanged by it: 1.7.2 with 75 rows) and
  `check` ADAPT_OK rows 75 steps 19; `gen/obs_tables.py --check` OBS_TABLES_OK probes 203 sites 98;
  `gen/dos/nodos.py check` NODOS_OK; `tests/harness/pdos_scene_check.py` PASS 1075 checks;
  `tests/harness/testpar.py check test.cmd` exit 0.  build.cmd and test.cmd are unchanged (the new sources and
  tests are found by their wildcards).
* **One fix at the slot** (the only failure): the first `test.cmd checked` failed one of its 24 sections,
  ext_continue: `FAIL dos: the DOS view follows the core into its setup: the 640x480 A frame shown at None
  us`.  BS4's check expected the A frame after Birth's hand-over; since D5c the DOS view shows the DOS setup
  page there (the same change as ext_timeline's `birth` 3 / `birth_skip`).  D5c's private harness did not run
  ext_continue, so its prediction did not list it.  `tests/harness/ext_continue.py` check 1 now requires
  timeline.log's `setup_page` step at the hand-over, the first DOS show within one second of it and every DOS
  show from the hand-over on the 320x200 N frame (re-evaluated over the failed run's outputs first: PASS, the
  setup page shown at 172402350 us).  No compiled source changed, so the cycle was rerun from step 2.
* **The cycle** (`build/d5l-status.txt`, logs `build/d5l-<n>-<step>[-r2].log`):

| step | result |
|---|---|
| 1 `build.cmd checked` | exit 0, BUILD_OK, 283 portable sources (c11, c17, c99 parse).  The build ended at 00:34:39; the step's 727 s include the wait for the compiler's telemetry helper (vctip.exe), which the build left running and the cycle's process wait included, until it was stopped at 00:43 |
| 2 `test.cmd checked` | first run exit 1 (ext_continue, above); rerun `-r2` exit 0, TESTS_OK, 24 sections, 0 failed, 1043 s |
| 3 `ext_g1.py check` | `-r2` exit 0, EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) |

ALL_GREEN at 01:20:28 UTC.  Only the Checked variant ran (the slot's three steps); CheckedNoObs and Release
were built and tested privately in the stages only.

* **Differences from the BS gate's Checked outputs** (`build/d5l-prep/compare.py` against the snapshot
  `build/d5l-prep/before/`, taken before the cycle):
  * presentation-diag.log (178 runs): `pdos unexplained` lower exactly as D5c predicted (V1, V2, ... runs of
    birth 680 -> 670, new and s3 675 -> 615, earth 602 -> 541, custom 640 -> 580, settlers 670 -> 610; 30
    runs); the new fields `setup_text_diff 0` (D5c) and `n_clip 0` (D5a, S4) in every run; nothing else but
    the pmap timing fields, which vary run to run.
  * profiles.log: all 90 equal.  ext_p0: P0 PASS in every scenario (TESTS_OK).
  * ext_timeline: `birth` 3 and `birth_skip` with the DOS setup page at the hand-over, `birth` 4 (the Birth
    goldens, including frame 12000 = d67d465f..., the T4 difficulty page) equal the landed golden;
    EXT_TIMELINE_OK, the bs group (bs3_timeline) EXT_TIMELINE_OK unchanged.
  * ext_adapt: EXT_ADAPT_OK checks 56 -> 68: D5c's four pairs d-setup-escape, d-setup-portrait,
    d-setup-tribe and d-setup-goback, three PASS lines each.
  * ext_frames: `s3` and `birth` presented.log lengths (s3 671 -> 672 lines, 645 -> 643 tick shows; birth
    3054 -> 3050, 3032 -> 3031): the DOS frames after the hand-over are now the setup page; every A against A'
    comparison still passes.
  * adapters-check rows 38 -> 75, steps 12 -> 19 (D5b's I-menu and D5c's I-setup rows); dos-decoded.txt and
    registry-check: D5c's 8 rows; obs-lint files 97 -> 101 (the four new files); nodos files scanned
    1671 -> 1680; coverage's informational "other functions entered" 661 -> 662 and 665 in the two runs of
    the same landed build (it varies run to run).
  * Nothing else differs.
* D5c's tests in the slot's run: test_pdos_setup 50, test_input 293, test_pdos_seq 170, test_pdos_profile 40
  (UX1's cursor check now passes on the tree), test_dos 23208 checks (with the landed dos-decoded.txt), all
  PASS.  "Expected changes at the build slot" 2..5 appeared as listed.  Item 1 (the DOS samples) comes from
  the private matrix's `--profile-samples 100`; test.cmd's ext_p0 writes no sample lines (all 90 profiles.log
  equal), so the slot's run neither shows nor contradicts it.  The one unlisted change, ext_continue's dos
  check, is fixed above (`tests/harness/ext_continue.py`, a D5c consequence).
* "What the user checks" (above) applies to the landed tree's build.

## User rework (D5cR, staged with D5f, 2026-10-16)

The user, about 05:43..06:00 UTC, on the landed D5c pages (manual checklist D5-2, D5-4, D5-5; the coordinator
marks them failed): (1) no Go Back row on the DOS difficulty, competition and tribe pages; (2) no "Custom." row
on the tribe page; Escape and the release outside the box are the only DOS paths to Custom (the core's Custom.,
then D5d's DOS tribe-name box); (3) withdrawn: Escape keeps choosing Custom.  The general direction of 06:10 UTC
(BRIEF-d5.md "User direction 2026-10-16") binds it: no DOS screen draws or hit-tests a Go Back or Cancel row the
DOS screen lacks.  This reverses ruling 4 ("Custom." as an added row) and P17's Go Back row for the setup pages.
The Windows profile, the core, P0, G-1 and the core's frames, state and events are unchanged.

### What changed (`present/dos/pdos_scn_setup.c/.h`, `pdos_adapt.c/.h`, `pdos_adapt_tab.c`)

* **The box holds DOS's rows only** (`Page.nrows`): the difficulty page's five levels, the competition page's
  five counts, the tribe page's tribe rows.  Tribe row k is the core's item k + 1 (the core's item 0 is
  "Custom."; `ncore` = rows + 1 there), so `row_of_item(0)` is -1.  No row maps to `PDOS_SETUP_GOBACK`
  (`gb_row` -1); the disabled Go Back row of the difficulty page, the Go Back row-only redraw and its page-0
  snapshot are removed.  The core's Go Back and Custom. texts are still read (the state compare) but not drawn,
  so `setup_text_diff` stays 0.
* **The bar when the core's selection has no DOS row** (the core's Custom. selected: the core preselects it on
  the tribe page, or a Windows-profile click chose it): the bar stays where it was on the same page, and starts on row 0
  on a new page, where MenuZ starts it (R:1D05:0031).  The name pages' background draws the tribe page with the
  bar where the DOS -1 left it (`cbar`; row 0 when unknown).
* **Go Back is Windows-only on all three pages** (the rule's "otherwise that choice is only in the Windows
  graphics").  The DOS listing gives no key with Go Back's effect on these pages: Escape (MenuZ's -1,
  R:1D05:0200 -> 0392) is level 0, Chieftain, on the difficulty page (O5:009B..00A2), asks the question again on
  the competition page (O5:0190..0196) and is the random tribe with its name entry on the tribe page
  (O5:05BA..05CE, O23:0173: the core's Custom.).  The core's Go Back (button 102) stays reachable by switching
  to the Windows graphics.
* **Adapter (I-setup)**: `I-setup/goback` is removed and `I-setup/release-disabled` folded into
  `I-setup/release-other` (`PDOS_AA_LREL_DIS`: no setup row is disabled).  New `I-setup/bar-move/core-ready` and
  `I-setup/bar-choose/core-ready` (`PDOS_AA_BAR_MOVE`, `PDOS_AA_BAR_CHOOSE`, `PdosAdaptSc.bar_off`): while the
  core's selection has no DOS row, Up / Down select the bar's next row's item (a click on its control at once),
  and Return / Space choose the bar's row (a click on its item, then Return once the core's selection is that
  item).  Escape and the release outside the box on the tribe page are the core's Custom. as before (D5d's name
  box follows).  `PDOS_A_BUTTON`, `PDOS_AA_GOBACK` stay declared and are in no row.
* **Tests**: `test_pdos_setup.c` (no Go Back / Custom. row drawn or hit; the tribe page's 12 rows for item 1..12,
  14 with six rivals; the bar stays on its row when the core selects item 0; a fresh page starts on row 0; the
  Go Back text changes draw nothing), `test_input.c` (the bar-move and bar-choose vectors; the Go Back,
  release-disabled vectors and D5c's "post nothing" vectors dropped), `ext_adapt.py` (`d-setup-goback` replaced
  by `d-setup-nogoback`: a click where the Go Back row was posts nothing the core sees and the page stays;
  new `d-setup-bar`: on the tribe page, where the core preselects Custom., Down moves the bar by a click on the
  next row's item, then Up and Return pass; `D_ACCEPT` (the shared accept path of the D5d pairs) chooses the tribe
  page's bar row by `I-setup/bar-choose/core-ready`; new `d-switch-custom`: the Windows profile's Custom. click,
  then the switch to DOS shows D5d's DOS tribe-name box).
* DOS-PROFILE.md 1.7.2 regenerated by `adapters.py gen` (the rows above; with D5eR and D5f: 98 rows).

The results are in `ext-D5f-record.md` ("Results") and the gate record `ext-D5-acceptance.md`.

**Landed** with D5f and D5eR (copy-in 2026-10-16 07:49:42 UTC; the D5 gate's eight-step cycle ALL_GREEN 08:37:49 UTC,
`build/d5-gate-status.txt`; `ext-D5f-record.md` "Landing").  D5cR's results in the cycle (Checked; the unit tests in
all three variants): test_pdos_setup 164 (its geometry lines: the difficulty box 6 lines, the tribe box 13 lines
with five rivals, 15 with six); test_input 397 / 370 / 397; ext_adapt d-setup-nogoback (coreinput 6), d-setup-bar
(15), d-switch-custom (13; the DOS name box at 42.102 s, the switch to DOS at 43.021 s), all equal to their
Windows-form pairs; D5d's d-wait-key and d-wait-click one core input more in both forms (`D_ACCEPT`'s bar-choose on
the tribe page); ext_timeline `birth` 4 with bgolden frame 12000 dd778d0b... (was d67d465f...); ext_frames `s3`
655 tick shows (was 656).  P0 and G-1 unchanged.

### For the records (D5cR)

* Manual checklist (the coordinator): D5-1 "(difficulty, Go Back greyed)" becomes "(difficulty)"; D5-2 the
  difficulty page shows Chieftain .. Emperor without a Go Back row; D5-4 the competition page "7 .. 3
  Civilizations" without Go Back; D5-5 the tribe page the tribe names only (no "Custom.", no "Go Back"), Escape or
  a click outside the box = Custom (the DOS tribe-name box follows); D5-6 becomes "no Go Back row in DOS; Go Back
  exists only in the Windows graphics (Ctrl+Shift+Backspace): there it returns to the previous page, and the DOS
  view follows after switching back".  New: on the tribe page the DOS bar starts on the first tribe although the
  core preselects Custom.; Down / Up / Return work from there.
* FIDELITY (F162 and ruling 4's entry): the setup pages' added Go Back / Custom. rows and the mouse-only Go Back
  are no longer deviations;
  new entries: the core's Go Back is Windows-only on the DOS setup pages (the user's direction of 2026-10-16;
  O5:009B, O5:0190, O5:05BA cited above); the bar where the core's selection has no DOS row (above).
* DESIGN 12.7 "As implemented (D5)": the setup box has DOS's rows only (tribe row k = core item k + 1); the
  bar-move / bar-choose adapter rule.  DOS-PROFILE 3.x "Go Back in setup": Windows-only (no DOS form); 3.3's
  "Custom." row text: Escape / the outside release only.

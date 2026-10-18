# Extension unit SL: the DOS Save/Load slot screens

## Status

**Landed** 2026-10-16 12:40:58 UTC, cycle ALL_GREEN 13:34:58 UTC, RELEASE_OK 13:41:24 UTC, user build
`build/user-builds/sl/` (section "Landing"). Staged in session E3 (staging folder `build/sl-stage`, rebased about
12:00 UTC onto UX3's landing). Implemented, compiled privately in Checked, CheckedNoObs and Release
with build.cmd's flags, tested headless and Win32-headless, every check of the brief run privately
(section "Results"). The
user checks D5-20 (rewritten) and SL-1..SL-7 are pending (section "What the user checks"). The tree's
ext_adapt.py, changed at 12:09 UTC by another unit, fails its three `d-goback` checks with the tree's
own build exactly as with SL's (not SL's; "Results"); after D5K2's landing they pass ("Landing").

## The user's direction

STATUS.md "User directions":

- 2026-10-16 about 10:10, checklist D5-20 **failed**: "Failed, Load a Saved Game shall display DOS
  Save/Load screen."
- 2026-10-16 about 10:20, the user's three answers: the ten DOS slots show the **ten newest saves**
  (the ten most recently written `.SAV` files of the data folder, whatever their names; the order
  changes as you save); DOS's drive prompt ("Which drive contains your saved game files?") is
  **skipped** (straight to the ten-slot list; Escape there returns to the title); **Save Game during
  play** with the DOS graphics also uses the DOS save screen with the same slots, instead of the
  Windows file chooser.

This supersedes DOS-PROFILE section 4 W3 and the extension prompt's D-4 rule (the file choice is a
host dialog of class W) for Load a Saved Game (row 4, LoadGameFromFileDialog 1130:000E) and Save
Game (row 29, SaveGameAsDialog 1198:00A3) only. The replay file's chooser (row 125) and every chooser
of the Windows graphics are unchanged. The user's rule of 2026-10-16 (no Go Back or Cancel row the
DOS game lacks) holds: the slot screens add none.

## Design and decisions

The DOS program's screens (the DOS listing; SCENES 7.2): O11:05F8 asks for the drive; O11:0000 lists
the ten load slots `CIVIL0..9.SVE`, each line made by O11:0103 from the file's header; O11:036A lists
four save slots; both use the menu box R:1D05:0031. The contract is the header comment of
`present/dos/pdos_scn_slots.h`; the decisions:

1. **Where.** With the DOS graphics visible, the core's two game choosers show the slot screen
   instead of the host's chooser, inside the same `host_choose_file` call: Load (the probe
   LoadGameFromFileDialog with the call site 11E0:0802, row 4) as O11:0000 and Save Game
   (ShowSaveFileDialog 1098:26D4 with the call site 1198:0178 in SaveGameAsDialog, row 29) as
   O11:036A. The probes give the chooser's kind (`pdos_slots_on_probe`, a probe step in
   `pdos_profile.c`: after the re-skins at the entry, before the pop at the exit); the back end's
   modal loop asks for the screen (`present_slots_begin`, `present/slots.h`), only while the DOS
   profile is visible and one of the two choosers is pending. The replay's chooser (call site
   1180:00A7) never matches. The core receives exactly what the host's chooser gives it: an 8.3
   name and 1, or 0 (P0); rows 4 and 29 become class N (`PDOS_RD_SCRIPT`, `PDOS_PAL_KEEP`, TS,
   I-pass), ready from the draw to the chooser's exit, so the N frame shows the screen.
2. **The ten slots** are the ten newest `.SAV` files of the data folder: last write time descending,
   ties by the name ignoring ASCII case, then by the name as written; fewer files leave empty slots
   at the end (`pdos_slots_order`). Files are listed by a new read-only host call
   `host_data_list(ext, out, max)` (`platform/w16/host.h`): Win32 the file system's
   `ftLastWriteTime` of top-level files whose long name is a plain 8.3 name (the names
   `host_data_read` finds); headless a logical time (`hh_data_set_time`, else the order of the run's
   own opens for writing, 1 for the first, else 0), so runs stay deterministic. At most 1024 files
   are listed (`PDOS_SLOTS_FILES`).
3. **The lines** are O11:0103's descriptions (O11:0191..02D1): " " + FAME_RANKS[difficulty] + " " +
   leader + ", " + civilization plural + "/" + |year| + " BC" or " AD"; " (EMPTY)" for an empty slot
   (the strings are DGROUP's: SL_TEXT DGROUP:41D7, FAME_RANKS DGROUP:33A2; `|year|` as itoa of the
   16-bit negation, so -32768 stays negative). The header is read as the core reads a file
   (CivLoadGame 10F8:0000: a raw DOS image of 18DE0h bytes, or the RLL decode, RLLDecode 10F8:040A,
   giving 1A2BAh, 1A2B8h or 18DE0h bytes; the Windows layout's human +4, year +0Ah, difficulty +0Ch,
   leaders +12h and plurals +112h; the DOS layout's +2, +8, +0Ah, +10h, +80h). Names to their NUL, at
   most 13 and 11 characters (the DOS fields less their NUL), folded to DOS-drawable bytes (0.6 rule
   8). A file that cannot be read, that the core would reject, or with a human player or difficulty
   out of range shows " " + its name (no DOS counterpart: DOS shows only its own files).
4. **The screens.** Load: O11:05F8's fill (0, 0, 320, 200) in colour 15 (O11:0615..062E), no border
   (DGROUP:681A = 1, O11:0006); Save: the same fill, the ornamental border R:0866:260E (O11:0631..0638)
   and the fill (8, 8, 304, 184) in colour 15 (O11:0754..076E). Then the menu R:0238:0008 at (48, y)
   of the header (Load SL_LOAD_HEAD DGROUP:41B0, O11:0029, y 65, O11:007B..0087; Save SL_SAVE_HEAD
   DGROUP:41F4, O11:0391, y 33, O11:03E9..03F5) and the ten lines: odd y, so frameless; the header's
   colour byte gives it colour 12. The drive prompt is skipped (the user's direction). Font 1, the DOS
   program's port font (O11 sets none; inferred), the port's font restored after the draw.
5. **Save shows ten slots**, not DOS's four (O11:03A1..03C6, `cmp 4` at O11:03C2): the user's "the
   same slots". The highlight starts on item 0 (Load: DGROUP:2F9A is -1) or, for Save, on the slot of
   the file last chosen on a slot screen in this run (O11:03C8..03DB: DGROUP:E168, which Load sets to
   -1 when cancelled or on an empty slot, O11:009A..00A6, and Save keeps when cancelled).
6. **Input** is R:1D05:0031's: Up and Down without wrap (R:1D05:0368..0374, 020B..0214); Return and
   Space choose (R:1D05:01EB..01FD, 0377); Escape returns -1 (R:1D05:0200, 0392); Alt+H chooses
   (R:1D05:0386; the help flag DGROUP:2F9C, unread by O11); Alt+V, DOS's sound flag (R:1D05:039A), is
   consumed (the core is inside its chooser, so DOS-PROFILE 3.3's translation to command 109 cannot
   apply); every other key searches the items' hotkeys from the next item and only selects
   (R:1D05:03FD..03E0, 01C8). A button press starts tracking (R:1D05:0177..0187), the highlight
   follows the row under the pointer (R:1D05:018A..01BF), the release chooses that row or returns -1
   with none (R:1D05:01CD..01D9, 0337..0346); a release while another button is held goes on; a
   release without a press on the screen is ignored (R:1D05:003E). The VGA confirmation wait
   (R:1D05:043D) is omitted, as for the title box. The host events are converted in
   `present/slots.c` (outside `present/dos`, obs_lint's HOST_EV_ rule): modifiers ignored, Alt from
   VK_MENU, the mouse only at points of the N frame.
7. **Results.** Load: a used slot returns its file; an empty slot or Escape cancels (O11:009A..00A6):
   the core returns to the title and the DOS title box is drawn again (D5f, R:01A8:07C0); a game read
   gets D5f's fill in colour 7 (FIDELITY F174), unchanged. Save: Escape cancels (the game again); a
   used slot returns its file, which is **overwritten without a question** (DOS asks none,
   O11:036A..04E6; Win32 `host_confirm_overwrite` answers 1 without its box for exactly the name the
   slot screen returned; the headless back end always replaces); an empty slot returns the first
   `CIVILn.SAV` (n from 0) that no `.SAV` file of the folder has and that `host_data_read` does not
   find (so an empty slot never replaces a file, even one the 1024-file list left out); with
   CIVIL0..999 all taken it cancels (diagnostic `file`). O11:04EF's "save in progress" box and
   O11:042E..04CD's result box with its key wait are not shown: the core saves and shows its own
   messages (DOS-PROFILE 1.6).
8. **Save's screen and palette.** The N machine shows the play palette while the screen shows (the A
   machine's DAC copied: O11:036A loads no palette), and page 0 and the N DAC are restored at
   ShowSaveFileDialog's exit, as R:0866:25B6 and 25D7 save and restore the screen around O11:036A
   (a private copy instead of page 1). The border's tile set comes from the effect "border"'s
   generator (B 9.3), one instance per Save entry whether the screen is shown or not, so its ordinal
   never depends on visibility; its tiles are page 2's resident SP299 art (DOS-PROFILE 2.2) under the
   play palette (inferred: the colours are those the play palette gives SP299's indices).
9. **The pointer** is shown while the screen takes input (O11:0076, O11:03E4): the sequencer's hidden
   rule is lifted (`pdos_profile.c` `cursor_update`).
10. **A graphics switch on the slot screen** (the profile chord or the system menu) ends the slot
    screen at the next tick and the host's chooser answers the same call: on Win32 the Windows file
    dialog opens, in the headless harness the next `--file-answer` applies. Files beyond the ten, or
    a name of the player's own, are reached this way. The reverse cannot happen: the host's chooser is
    modal (its owner is disabled, so no chord or system menu reaches civ64 while it is open). Proved
    headless by ext_slots.py `l-dos-switch` (profiles.log: one switch from dos to windows, refused 0;
    the core trace equals the Windows run's).
11. **The modal loops.** Win32 (`host_win32.c` `slot_screen`): as when the host's dialog takes the
    focus, the keys the game holds are released to it first (`pi_arrive_focus_lost`), the events
    queued for the game wait and are queued again afterwards, the screen's own input never reaches
    the game, a close request is ignored (UX1's `g_host_box`), WM_QUIT cancels and stays queued for the
    game; the loop polls every 16 ms and ticks the presentation without the throttle
    (`present_tick_flush`, new in `present.c`). Headless (`host_headless.c`): the screen is shown only
    while `--slot-input` tokens are queued (else the file answers, as before SL: existing runs
    unchanged, proved by the base comparison in "Results"); tokens up, down, return, space, escape,
    alth, altv, char:C, press/release/move/rpress/rrelease:X:Y (N points), switch; the console gets
    `[slot screen] open|save: shown / chosen NAME / cancelled / no input left, cancelled / switched
    to the Windows graphics`.
12. **CheckedNoObs**: `present/slots.c` has no observer, so `present_slots_begin` is 0 and the host's
    chooser is used (the DOS graphics need the observer anyway).
13. **No DOS byte** in the port: the strings are registry tables (DGROUP offsets, `docs/dos/OFFSETS.md`
    SL_LOAD_HEAD, SL_TEXT, SL_SAVE_HEAD; FAME_RANKS' readers gain O11:01D0), read from the DOS copy
    at run time; `gen/dos/registry.py`'s OBSERVER_FILES gains `pdos_scn_slots.c` (it includes
    `observe.h` for the probes). FIDELITY row F182 (next free number at staging).

## What was built

New:

- `present/dos/pdos_scn_slots.h`, `.c`: the model (order, free name, RLL decode, header, line; pure)
  and the view (probes, screen, input, results, Save's restore), with test seams for the folder.
- `present/slots.h`, `.c`: the bridge for the back ends' modal loops (`present_slots_begin`,
  `_event`, `_tick`, `_end`), host events to the slot screen's input, inside the observer's guard.
- `tests/test_pdos_slots.c`: unit test on the real DOS store (structural checks; no DOS byte).
- `tests/win32/test_slots_host.c`: Win32-headless test of `host_data_list` (`w32_test_slots_host`).
- `tests/harness/ext_slots.py`: the harness pairs (section "Tests").

Changed (delimited "extension SL" blocks or single marked lines; "Rebase notes"):
`platform/w16/host.h`, `platform/win32/host_win32.c`, `tests/headless/host_headless.c`, `.h`,
`tests/headless/harness_main.c`, `present/present.c`, `present/profile.h`,
`present/dos/pdos_profile.c`, `present/dos/pdos_scene_tab.c` (rows 4 and 29),
`gen/dos/registry.py`, `docs/dos/OFFSETS.md`, the generated `present/dos/pdos_registry.h`, `.c` and
`tests/dos-decoded.txt`, `docs/DOS-PROFILE.md` (rows 4, 29, 1.6, 1.8, 3.2, 3.3, 4 W3) and
`tests/test_pdos_scene.c` (its class counts 59 N, 8 W).

## Tests

- **test_pdos_slots** (unit; 121 checks Checked and Release, 104 CheckedNoObs): the order (time,
  case-ignoring name, as written; 14 files to ten); the free name (case, gaps, all 1000 taken, a gap at
  17); the RLL decode (runs, a zero run, literals, 80h, the capacity, an input ending in a run); the
  header (Windows -2 and -1, raw and RLL DOS images, a length the core rejects, human 8, difficulty 5
  and -1, long names capped at 13 and 11); the data folder's real `CAE3540B.SAV` described (read
  only); the lines built from the store's own strings (BC, AD, year 0, -1, -32768, the empty slot, the
  name fallback, the capacity); Load's view (the replay chooser's probe ignored; colour 15, no border;
  the frameless box at (48, 65), ten items, the header's colour 12, item 0 highlighted in 11; the slots
  newest first, described or not; Up and Down without wrap; the hotkey selects only and does not wrap;
  Alt+V consumed; the mouse: release or move without a press ignored, press, follow, off the box, a
  release with a button held, the choosing release; no input after a result; shown again on the
  chooser's next request; Return on a used and an empty slot; a release off the rows; Escape; Alt+H;
  the exit ends the view); Save's view (the border's effect instance per entry, the play palette, the
  box at (48, 33), the inner fill, the border, the first free name, page 0 and the DAC restored, the
  highlight on the last file, a used slot's own name, Escape keeping the last file and Load's Escape
  clearing it); an unlisted existing `CIVILn.SAV` never taken as free; the bridge (CIV_OBSERVER: the
  keys, Shift and Ctrl ignored, a scan-code key, Alt+V, Alt+H, H after Alt's release, presses at N and
  other frames, the right button held, Return without its character, Space, Escape, a quit, closed);
  the headless `host_data_list` (four files of seven names, unwritten 0, the run's writes in order,
  `hh_data_set_time` set and removed, max and the arguments, the screen over the real back end); no
  host allocation left. Rerun-safe (it removes its own earlier files).
- **w32_test_slots_host** (Win32-headless, 19 checks): `host_data_list` before a data directory, the
  two listed of six names (a directory, a long name, other extensions, a space), the 100 ns times, the
  extension's case, max and the arguments, fourteen files to the ten newest, the newest readable by
  `host_data_read`.
- **ext_slots.py** (harness, 45 checks, 15 runs; section in BUILD-TEST-ADDITIONS.md): Load through
  ext_adapt.py's DOS title path (X, l, Return) with the slot screen chosen by Return, by a press and
  release, and switched to the Windows graphics, and the DOS path with a file answer, each equal to the
  Windows title's L, Return with the answer CAE3540B.SAV (coreinput.log, run.log's frame, snapshot
  and result lines, events.log, exit status; both reach after-load 10F8:02AF); Escape and an empty
  slot equal to the cancelled Windows chooser (no after-load); gate3b's S2 (load-save.script) with its
  two Saves on the DOS save screen (new CIVIL0.SAV and CIVIL1.SAV; CIVIL0.SAV overwritten; the first
  cancelled) equal to the same answers given to the host's chooser in the DOS and in the Windows
  graphics, with equal saved files; the console's slot-screen lines and the answers used asserted per
  run.
- Existing tests that read the changed data: test_dos (the regenerated `tests/dos-decoded.txt`),
  test_pdos_scene (the class counts), pdos_scene_check.py, obs_tables.py --check, obs_lint.py,
  registry.py check, adapters.py check, nodos.py check, ext_adapt.py (its d-load-cancel pair runs
  through row 4).

## Results

All private, outputs only under `build/sl-stage/obj`; reads of `build/gamedata`, `build/dosdata`,
`build/cache` and the tree's scripts only. The results below are of the rebased stage (about 12:00
UTC) unless marked "before the rebase".

- **Strict compiles** (build.cmd's flags: /W4 /WX, /std:c11 and /std:c17, the clang C99 parse) of
  `pdos_scn_slots.c`, `slots.c`, `present.c`, `pdos_profile.c`, `pdos_scene_tab.c`, `pdos_registry.c`,
  `test_pdos_slots.c`, `test_pdos_scene.c`, `tests/win32/test_slots_host.c`, `host_headless.c`,
  `harness_main.c`, `host_win32.c`: `CC_STRICT_OK` in Checked, CheckedNoObs and Release.
- **Full private builds** over the tree with the stage's files (every portable source, the headless
  tests, the harness, `host_win32.c`, civ64.exe, the Win32-headless tests): `CC_ALL_OK` Checked (48
  tests, 156 s), CheckedNoObs (111 s), Release (81 s); the base build (the tree alone) Checked
  `CC_ALL_OK` (47 tests, 82 s).
- **Unit tests** (test.cmd's unit loop, `obj/runtests.py`): every `test_*.exe` passes in Checked,
  CheckedNoObs and Release (47 per variant, 141 ok) except test_dos, which reads the tree's
  `tests/dos-decoded.txt` (1357 lines, without the three SL tables): with the stage's goldens through a
  read-only mirror (`obj/m`: junctions to build/gamedata and build/dosdata, the stage's
  `dos-decoded.txt`) `PASS test_dos: 23230 checks, 0 failed` in all three variants.
  `PASS test_pdos_slots: 121 checks` (Checked, Release), 104 (CheckedNoObs), also on a second run in
  the same output folder; `PASS test_pdos_scene` 136 / 137 / 136 checks (the stage's counts).
- **Win32-headless tests**: `w32_test_slots_host` 19 checks, `w32_test_host_win32` 329 (CheckedNoObs
  314), `w32_test_dos_host` 56, `w32_test_locate` 36, all `PASS` in the three variants.
- **ext_slots.py** (the stage's Checked harness): `EXT_SLOTS_OK`, 45 checks, 15 runs in 15 s (42 s
  before the rebase, with builds running alongside).
- **ext_adapt.py** (the tree's script, read only, with the stage's Checked harness in the mirror):
  120 PASS, 3 FAIL (`d-goback-keys` twice, `d-goback-winkeys`), `EXT_ADAPT_FAILED=3`. The base build
  (the tree without SL) gives exactly the same check lines (identical `PASS`/`FAIL` output): the three
  failures are the tree's own at 12:10 UTC (ext_adapt.py changed at 12:09 UTC by another unit's
  landing, D5K's Go Back keyboard cases), not SL's. Before the rebase and that change: `EXT_ADAPT_OK
  checks 119`. `d-load-cancel` (row 4's DOS path without a slot screen) passes in both.
- **Decision 8 / base comparison** (`obj/slots_priv.py base`; the base and the stage Checked
  harnesses, `--presented 1`, no `--slot-input`): the DOS Load with the answer CAE3540B.SAV, the DOS
  Load cancelled, S2 with its two saves, S2 with the first save cancelled: every output file equal
  (run.log, events.log, coreinput.log, presented.log, profiles.log, timeline.log, presentation-diag.log,
  the snapshots, observer-probes.log and the rest; the saved files; the console's lines), after
  removing the run folder's path from run.log's first line and the wall-clock `*_us` fields of
  presentation-diag.log's `pmap` line: `BASECMP_SAME`.
- **Generators and checks**: `registry.py check` (the stage's registry.py over the overlay, the
  stage's OFFSETS.md and goldens) `REGISTRY_OK`; `obs_lint.py` over the overlay `OBS_LINT_OK files 119
  probes 203 callsites 98`; `obs_tables.py --check` with the stage's DOS-PROFILE `OBS_TABLES_OK probes
  203 sites 98`; `pdos_scene_check.py` over a mirror of the stage's DOS-PROFILE and scene table `PASS
  1078 checks, 141 scene rows`; `adapters.py check` with the stage's DOS-PROFILE `ADAPT_OK rows 98
  steps 22` (1.7.2 unchanged: rows 4 and 29 keep I-pass, which has no adapter row; no `gen`);
  `nodos.py check --root` (the stage's files and the private binaries) `NODOS_OK` Checked (80 files) and
  Release (79 files), 0 hits; `testpar.py check` on a private test.cmd with BUILD-TEST-ADDITIONS.md's
  blocks: exit 0 (`ext_slots after=- cpu=8 est=45`).
- **Presented frames looked at** (my own check, not the user's; `--dump-presented`, before the rebase):
  the Load screen: the light screen, "Select Load File..." in red, " Emperor Caesar, Romans/3540 BC"
  highlighted for the data folder's CAE3540B.SAV, nine " (EMPTY)" lines; Down and Up moved the
  highlight and back (equal frame hashes). The Save screen in play: the ornamental border (magenta
  and yellow under the play palette, decision 8), "Select Save File...", the same lines, the
  highlight on slot 2 after Down, Down; after the chooser's exit the play frame again.
- Not run: test.cmd, build.cmd, ext_p0, ext_frames, ext_timeline, ext_continue, ext_mirror, ext_zoom,
  uninit, scenarios, gate3b (shared outputs); civ64.exe with a window (the Win32 modal loop is compiled
  and reviewed, its `host_data_list` tested Win32-headless; the loop itself is the user's SL checks);
  Asan; any DOS program.

## Expected expectation changes

- `tests/dos-decoded.txt`: regenerated (`registry.py goldens`): the three new tables SL_LOAD_HEAD,
  SL_TEXT and SL_SAVE_HEAD (1357 -> 1360 lines). test_dos fails with the old file and passes with the
  new one.
- `tests/test_pdos_scene.c`: the class counts 57 N, 10 W -> 59 N, 8 W (DOS-PROFILE 1.8).
  `tests/harness/pdos_scene_check.py`'s docstring still names 57 and 10 (it reads 1.8; informational,
  not changed).
- `present/dos/pdos_registry.h`, `.c`: regenerated; the three table ids follow FAME_POP.
- Harness runs without `--slot-input` (every existing suite): no change. The base comparison proves
  it for the DOS Load with an answer and cancelled, and S2 with saves and a cancelled save, every output
  file including presented.log equal. One difference exists by design: with the DOS profile registered,
  each Save Game chooser entry starts one instance of the effect "border" (decision 8), so a DOS border
  drawn later in the same run picks its tile set from the next instance; no private run drew one, and
  no golden of the suites depends on a border after a Save (ext_frames compares two runs of one build).
  ext_p0, ext_frames, ext_timeline, ext_continue, ext_mirror, ext_zoom, uninit, scenarios and gate3b
  were not run privately (they read or write shared outputs); the comparison above is the evidence.

## Rebase notes

Every base hash is in `BASE-SHA256.txt` (taken 10:43 and 11:36 UTC; the five files UX3 landed were
rebased onto their new versions about 12:00 UTC). If a base changed again, take the tree's file and
apply SL's parts:

- `platform/w16/host.h`: the `host_data_read` comment's added clause; the block "extension SL
  (begin)..(end)" (`HostDataFile`, `host_data_list`) after `host_data_read`; the added sentences of
  the `host_choose_file` and `host_confirm_overwrite` comments.
- `platform/win32/host_win32.c` (UX3 also changes it): `#include "../../present/slots.h"`; the block
  `host_data_list` after `host_data_read`; the block `slot_screen` before `host_choose_file`; in
  `host_choose_file` the `g_slot_name` reset and the `slot_screen` call after the `g_quiet` test; in
  `host_confirm_overwrite` the four lines after the `g_quiet` test.
- `tests/headless/host_headless.c`: the includes of `present/input.h` and `present/slots.h`; the block
  of `host_data_list`'s times and the `sl_stamp` call in `host_file_open`; the block `host_data_list`;
  the block of the slot input and `slot_screen`; the `slot_screen` call at `host_choose_file`'s start.
- `tests/headless/host_headless.h`: the block (`hh_data_set_time`, `hh_push_slot_input`).
- `tests/headless/harness_main.c` (UX3 also): the usage line's `[--slot-input TOKENS]...`, the
  paragraph after `--file-answer`'s, the option's branch after `--file-answer`'s.
- `present/present.c` (UX3 also): the block `present_tick_flush` at the end.
- `present/profile.h` (UX3 also): the block declaring `present_tick_flush` after
  `present_set_tick_clock`.
- `present/dos/pdos_profile.c` (UX3 also): the include; `&& !pdos_slots_live()` in `cursor_update`'s
  hidden rule (with its comment); `pdos_slots_reset()` after `pdos_prov_reset`; `pdos_slots_on_probe(p)`
  after the entry's re-skin step and after the exit's step-3 re-skin (before the pop).
- `present/dos/pdos_scene_tab.c`: rows 4 and 29 (whole lines).
- `gen/dos/registry.py`: the OBSERVER_FILES entry `pdos_scn_slots.c` with its comment.
- `docs/dos/OFFSETS.md`: FAME_RANKS' readers and source, the rows SL_LOAD_HEAD, SL_TEXT, SL_SAVE_HEAD;
  then **regenerate** (`gen/dos/registry.py gen`, then `goldens`) instead of merging
  `pdos_registry.h`, `.c` and `tests/dos-decoded.txt` by hand.
- `docs/DOS-PROFILE.md`: rows 4 and 29; 1.6's drive-prompt row (replaced) and the new "Save progress
  and result boxes" row; 1.8's rows 1.1, 1.3, FEATURES total and Scene table total and "11 omitted";
  3.2's "Load from any file"; 3.3's "drive letter and slot number"; 4 W3. 1.7.2 is unchanged
  (`adapters.py check` passes; no `gen` needed).
- `tests/test_pdos_scene.c`: the counts check (block).
- FIDELITY F182: the D5K2 stage's record also proposes F182 ("next free number, F182 if none was
  taken meanwhile"); the unit landing second takes the next free number. For SL the number appears in
  `pdos_scn_slots.h`'s first comment line, DOS-PROFILE rows 4 and 29, the FIDELITY row and this record.
- The other staged units: D5K (pdos_adapt, pdos_pend, pdos_scn_setup) and D6d share no file with SL
  as far as known; D6c's landing files (present/map, pdos_compose, test_map.c, ext_mirror.py) are not
  touched.

## Build-slot steps

1. Check the tree against `BASE-SHA256.txt`; for a changed base, apply the rebase notes to the tree's
   file.
2. Copy the stage's files (not `obj/`, `BASE-SHA256.txt` or `BUILD-TEST-ADDITIONS.md`) into
   `claude/port`; new files: `present/dos/pdos_scn_slots.[ch]`, `present/slots.[ch]`,
   `tests/test_pdos_slots.c`, `tests/win32/test_slots_host.c`, `tests/harness/ext_slots.py`,
   `docs/ext-SL-record.md`.
3. If OFFSETS.md or the registry changed in the tree since the base: `registry.py gen` and `goldens`.
4. Apply BUILD-TEST-ADDITIONS.md to test.cmd (CRLF); `testpar.py check test.cmd`.
5. `build.cmd` (all variants), then `test.cmd checked`, `test.cmd checked noobs`, `test.cmd` (Release);
   expect `EXT_SLOTS_OK`.
6. Records (section "For the records"); a user build with the DOS graphics for D5-20 and SL-1..SL-7.

## What the user checks

With the DOS graphics (Ctrl+Shift+Backspace or the system menu), in a data folder with a few saves:

- **D5-20 (rewritten)**: Load a Saved Game from the DOS title: the DOS load screen (no drive
  question): a light screen, "Select Load File..." in red, then ten lines: the newest saves first,
  each "<difficulty> <leader>, <civilization>/<year> BC|AD", then "(EMPTY)". Escape: the DOS title box
  again. Choose a save: the screen goes grey (colour 7) until the game's first frame; the game is the
  one chosen.
- **SL-1**: on the load screen, Up/Down move the highlight (no wrap), a letter jumps to the next line
  starting with it, Return or Space chooses; the mouse pointer is visible; pressing a button and moving
  makes the highlight follow, releasing on a line chooses it, releasing off the lines cancels.
- **SL-2**: choosing an "(EMPTY)" line on the load screen returns to the DOS title box.
- **SL-3**: in play, Save Game (the GAME menu or Ctrl+S): the DOS save screen with an ornamental
  border, "Select Save File...", the same ten lines, the highlight on the game last loaded or saved.
  Escape returns to the game with the map as it was.
- **SL-4**: saving on an "(EMPTY)" line writes `CIVILn.SAV` (the first free number from 0), which is
  then the first line of both screens; saving on a used line replaces that file without a question.
  The game saved loads again with the same position.
- **SL-5**: Ctrl+Shift+Backspace on a slot screen: the Windows file chooser opens for the same Load or
  Save (other files, other names); with the Windows graphics, Load and Save use the Windows chooser as
  before.
- **SL-6**: the save screen's colours: the border's colours come from the play palette (inferred from
  the DOS listing); say whether they look right.
- **SL-7**: with more than ten saves, only the ten newest are listed; a save made in Windows graphics
  (any 8.3 name ending .SAV) appears on the DOS screens by its time.

## For the records

- **DOS-PROFILE.md** (changed in the stage copy): row 4 W -> N (O11:0000's list; differences: drive
  prompt skipped, the ten newest `.SAV` files, Escape and empty slots cancel, the chord to the host's
  chooser, F174 kept, F182); row 29 W -> N (O11:036A's screen; ten slots for DOS's four, overwrite
  without a question, the first free `CIVILn.SAV`, the boxes omitted, F182); 1.6: the drive prompt
  "skipped by the user's direction" and the new row "Save progress and result boxes"; 1.8: 1.1
  9/9/0/0/0, 1.3 67/18/28/19/2, FEATURES 108/47/35/21/5, Scene table 141/59/44/30/8, "11 omitted";
  3.2 "Load from any file"; 3.3 "drive letter and slot number" (Alt+V consumed); 4 W3: row 125 only,
  "Superseded for Load and Save Game in the DOS graphics ... (extension SL)".
- **FIDELITY.md**: new row
  `| F182 | the DOS Save/Load slot screens (present/dos/pdos_scn_slots.c, present/slots.c; DOS-PROFILE rows 4 and 29; the DOS listing O11:0000, O11:0103, O11:036A, R:1D05:0031; SCENES 7.2) | The DOS program asks for a drive, then lists ten fixed slots CIVIL0..9.SVE for Load and four for Save; the Windows program uses the common file dialogs | With the DOS graphics visible the core's Load and Save Game choosers show the DOS slot screens (the user's direction of 2026-10-16): no drive prompt; ten slots for both, the ten newest .SAV files of the data folder (last write time, ties by name), each described from its header as DOS describes its files; Escape cancels (Load: the title box again; Save: the game); an empty slot cancels a Load and writes the first free CIVILn.SAV on a Save; a used slot is overwritten without a question (as DOS); the save progress and result boxes omitted; the highlight on the last file chosen (E168); font 1 and, for Save, the play palette (inferred); other files through the Windows graphics' chooser, which also answers the same call after a switch on the slot screen. Status: implemented in SL (staged 2026-10-16); tests test_pdos_slots, w32_test_slots_host, ext_slots.py; user checks D5-20, SL-1..SL-7. Label: **DOS listing (model)**; the user's direction | ext-SL-record.md; SCENES 7.2 |`.
  F174: "DOS-PROFILE row 4, class W, section 4 W3" -> "row 4 (class N since SL)", and "The DOS view
  keeps the title screen under the host's chooser" -> "with the DOS graphics the chooser is the DOS
  slot screen (F182); the fill after a game read is unchanged".
- **DESIGN.md** (the host.h / w16 change table): a row "`host.h`: `host_data_list(ext, out, max)`,
  `HostDataFile`: the data directory's top-level files of an extension with their last write times,
  read only; back ends in `host_win32.c` (after `host_data_read`) and `host_headless.c`
  (`hh_data_set_time`, the run's writes) | the DOS slot screens (`present/dos/pdos_scn_slots.c`), while
  the core waits in its chooser | SL | G-1 (never called on a core path); `test_pdos_slots`,
  `w32_test_slots_host`"; and a note: SL changes `host_choose_file`'s back ends (the DOS slot screen's
  modal loop, `present/slots.h`, before the host's chooser; headless only with `--slot-input`) and
  Win32 `host_confirm_overwrite` (no box for the name the slot screen returned), and adds
  `present_tick_flush` (`present.c`, `profile.h`). No w16 change.
- **RUNNING.md**: "Files written": the saved games row -> "saved games (`*.SAV`: the names you choose
  in the Windows chooser; `CIVILn.SAV` from an empty line of the DOS save screen)"; the last paragraph
  -> "...The file dialogs, and the DOS graphics' Load and Save screens, list the data directory
  only."; "The graphics profiles": a paragraph "With the DOS graphics, Load a Saved Game and Save Game
  show the DOS game's own slot screens (since SL): the ten newest saves of the data folder, Escape to
  go back, a used line overwritten without a question, an empty line saving as CIVILn.SAV. For other
  files switch to the Windows graphics there (Ctrl+Shift+Backspace): the Windows file chooser opens
  for the same Load or Save."; "Harness options for presentation and input": `--slot-input
  TOKEN[,TOKEN]...` (host_headless.h; tokens up, down, return, space, escape, alth, altv, char:C,
  press/release/move/rpress/rrelease:X:Y in N points, switch; the slot screen only while tokens are
  queued; console lines `[slot screen] ...`); "Tests": ext_slots.py.
- **FEATURES.md**: the row "DOS Load a Saved Game (D5f)" -> "DOS Load a Saved Game and Save Game
  (D5f, SL): with the DOS graphics the DOS slot screens (the ten newest saves; F182); a Load
  cancelled, the DOS title box again; a game read, the grey fill (F174)" with tests `test_pdos_slots`,
  `w32_test_slots_host`, `ext_slots.py`, `ext_adapt.py` d-load-cancel, and the user checks D5-20,
  SL-1..SL-7.
- **manual-checklist-ext.md**: D5-20 rewritten as above (its failed result kept as history, the new
  item pending); new items SL-1..SL-7 (sources: SCENES 7.2; DOS-PROFILE rows 4 and 29; F182), pending,
  with the user build named when made.
- **STATUS.md**: unit SL (the DOS Save/Load slot screens) staged/landed; DOS-PROFILE W3 superseded for
  rows 4 and 29 by the user's direction of 2026-10-16.

## Landing

**Landed 2026-10-16 12:40:58 UTC; cycle ALL_GREEN 13:34:58 UTC; RELEASE_OK 13:41:24 UTC; user build
`build/user-builds/sl/`.** Done by the build slot after D5K2 (the orchestrator's instruction of about 12:25 UTC):
`build/d5k2-status.txt` showed ALL_GREEN and `build/user-builds/d5k2/WHAT-TO-CHECK.txt` existed at 12:40:46 UTC.

1. **Bases.** `build/sl-prep/land.py`: all 16 tree files still had their bases (`BASE-SHA256.txt`; D5K2's six
   files are none of them), the eight new files were absent, the 24 staged copies had the SHA-256 frozen in
   `build/sl-prep/staged.sha256`. No rebase was needed; `gen/dos/registry.py`'s base was unchanged, so the
   regenerated `pdos_registry.h`, `.c` and `tests/dos-decoded.txt` were copied as staged.
2. **Copy.** The 24 files byte for byte (16 changed, 8 new); the tree's previous files in
   `build/sl-prep/tree-before`; the manifest `build/sl-prep/landed.sha256`.
3. **Snapshot and test.cmd.** Before writing: the tree's Checked test outputs (57 files of `build/test/Checked`,
   D5K2's cycle) in `build/sl-prep/before`, and test.cmd in `tree-before`. BUILD-TEST-ADDITIONS.md's two blocks
   applied to test.cmd (CRLF kept; SHA-256 c92811a3...caacc2); `testpar.py check test.cmd` exit 0.
4. **Cycle** (`build/sl-prep/sl-cycle.ps1`: Windows PowerShell, each step waits on its own cmd.exe; status
   `build/sl-status.txt`, logs `build/sl-<n>-<step>[-r2].log`):
   - 1 build-checked: exit 0, 280 s, BUILD_OK.
   - 2 test-checked: exit 1, 1182 s, TESTS_FAILED=1, STOPPED at step 2. The only failure: `w32_test_host_win32`,
     2 of 329 checks, its lines 1206 ("Ctrl+Backspace: Ctrl, Backspace and their releases") and 1240 ("later
     refusals ...: a beep each"). That test feeds window messages, while `host_win32.c`'s `key_down` reads Ctrl
     and Shift with GetKeyState, the thread's keyboard state; a Shift held on the machine's keyboard then makes
     the test's Ctrl+Backspace the profile chord (consumed, and one more refusal), which gives exactly these two
     failures. SL changes neither `key_down` nor the chord's path. The same Checked binary passed 3 times right
     after (329 checks, 0 failures, 13:01 UTC), as it did in D5K2's cycle and in SL's private runs.
   - Steps 2 and 3 run again (`-r2`): 2 test-checked exit 0, 1750 s, TESTS_OK; 3 g1-checked exit 0, EXT_G1_OK
     runs 77 (amended 1: game/p4-menus frames events): **ALL_GREEN**.
   - 4 build-release: exit 0, 330 s, BUILD_OK: **RELEASE_OK**.
5. **Comparison** (`build/sl-prep/compare.py`, `compare.txt`; predictions written at 12:45 UTC before any output
   was looked at, `build/sl-prep/predictions.txt`): 46 of 59 files equal (lines with times left out); every harness
   suite unchanged: ext_p0, ext_frames, ext_timeline, ext_continue, ux3_aspect, bs1..bs3, ext_adapt, ext_mirror,
   ext_replay, ext_zoom, gate3b, uninit, scenarios, p4tests, harness_stub, d3a_obs_tables, d4c1_adapters. The
   differences:
   - `ext-slots.txt`, `sections/ext_slots.log`: new, EXT_SLOTS_OK (42.2 s in the parallel run). Predicted.
   - `dos-decoded.txt`: the three tables SL_LOAD_HEAD, SL_TEXT, SL_SAVE_HEAD added. Predicted.
   - `registry-check.txt`: FAME_RANKS' new reader O11:01D0, the three tables' sizes, readers and "no writer", the
     include rule for `pdos_scn_slots.c`, `.h`, the goldens 1357 -> 1360 lines. Predicted.
   - `obs-lint.txt`, `sections/d3a_obs_lint.log`: files 115 -> 119 (`present/slots.[ch]`,
     `present/dos/pdos_scn_slots.[ch]`); probes 203 and call sites 98 unchanged. Predicted (+4).
   - `pdos-scene-check.txt`, `sections/d4a_pdos_scene.log`: 1075 -> 1078 checks (row 29 now has an entry key and
     a call site, checked against the document). Predicted (+2..4).
   - `nodos.txt`: 1714 -> 1724 files (the 8 new files and the 2 new test programs), more bytes, 0 hits.
     Predicted.
   - `sections/unit.log`: test_pdos_slots (121 checks) and w32_test_slots_host (19) added, as predicted; test_dos
     23227 -> 23230 checks and "registry: 38 -> 41 tables valid", "decoded content: 1357 -> 1360 lines" (not
     predicted for the count: test_dos checks each registry table once); the OBS_COST line's nanoseconds (a
     timing line the filter keeps).
   - `coverage.txt`, `sections/coverage.log`: "other functions entered" 666 -> 665 (informational, not
     predicted). The harness processes of the parallel sections append to one `coverage-civ_harness.txt`
     (`host_coverage`, append mode, no locking), so the merged count varies from run to run without a change: the
     earlier landings' snapshots show 661, 662, 662, 663, 664 and 666.
   - `sections/times.txt`: section times.
   ext_adapt is EXT_ADAPT_OK with 123 checks: the three `d-goback` checks that failed before D5K2's build (record,
   "Results") pass after D5K2's landing, as the orchestrator expected.
6. **User build** `build/user-builds/sl/`: `civ64.exe` (the Release build, SHA-256 bc1046ab...dc40c6),
   `CIVWIN.zip` and `civdos.zip` (byte-identical copies from `user-builds/d4`) and `WHAT-TO-CHECK.txt` (D5-20
   rewritten and SL-1..SL-7 in plain words, how to get saves to test with, and the builds it contains: d5k2, ux3,
   d5k, d6c, ux2, d5).
7. **Not done here**: the records of "For the records" (FIDELITY F182, DESIGN, RUNNING, FEATURES, the checklist,
   STATUS) are left to the joint docs pass for D5K, UX3, D5K2 and SL (the orchestrator's instruction), which also
   assigns the FIDELITY numbers.

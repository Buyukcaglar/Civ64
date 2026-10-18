# Extension D5, bug-fix unit D5K (the keyboard lost after the Windows-only Go Back; checklist D5-6) - record

Extension session E3, staging implementer.  Staged under `build/d5k-stage/` only; nothing in the tree, `build/x64`,
`build/harness` or any other shared output was written.  Base snapshot of the tree: 2026-10-16 10:32:01 UTC (after
the D5 gate, UX2 and the D6c copy-in; `BASE-SHA256.txt`).

## Status

**LANDED** 2026-10-16 (the three-step cycle ALL_GREEN 11:34:48 UTC; see "Landing").  Staged as
**READY_TO_BUILD.**  The root cause is in the core's keyboard focus, not in the DOS filter stage: after the
Windows-only Go Back from the competition page, MenuZ disables the Go Back button that holds the focus, so the core
has no focus window and ignores every key, in both graphics.  The fix is in the DOS filter stage only
(`present/dos/pdos_adapt.c/.h`): while the core's setup MenuZ is waiting without a focus, a DOS key reaches it in
its Windows mouse form, and the first DOS key also gives the focus back.  The core, the Windows profile (I2) and
the adapter rows are unchanged; P0 holds.  The private results are all green.

| Staged file | Base sha256 (tree, 10:32:01 UTC) | Staged sha256 |
|---|---|---|
| `present/dos/pdos_adapt.h` | `42fb8d5604cda2ce2bdee76af97e64f3b99c2ce8f1e45371f1f782294d9ab240` | `5ec34eacbcdaca2709c3e19315f707f9869a3e492a89391fe6029f39aff88620` |
| `present/dos/pdos_adapt.c` | `c835e6e296bd4687cbdcb65b6366e92a39d2a47a9043cffa593c34a55eeb7307` | `101e4e8fe5cd8748f942703173eb8c2d226bf654a87cb02db8de90c0fb896459` |
| `tests/test_input.c` | `64c6cd09c0db2450710477b593ce7d5d71cc2544726d78ff2764fcee6345c537` | `6aeeb70f63bb8bc5b2d392e6be3c7f87fbd29dda92993bd0f26f50b989f8bbcd` |
| `tests/harness/ext_adapt.py` | `fdb0d74aebf772d992f1bfb8eb93723cd45acfa4609b6501136b4ebe7f9a6872` | `a2e67757f989ff8cf62e9b65a3be1e5f4549c5fef6530a51afdbb9859ed466e3` |
| `docs/ext-D5K-record.md` | new | (this file) |

`test.cmd`, `build.cmd`, the adapter table `pdos_adapt_tab.c` and `DOS-PROFILE.md` are unchanged (no
`BUILD-TEST-ADDITIONS.md`; no `adapters.py gen`).  The line endings follow the bases (CRLF for the C files, LF for
`ext_adapt.py`).

## The user's report

STATUS.md "User directions", 2026-10-16 about 10:10, checklist D5-6, on the D5 gate's user build
(`build/user-builds/d5/`, Release, with D5cR): "Item's definition passes validation but the following use case
prevents further keyboard interaction. 1. Start with DOS 2. Advance to Level of Competition 3. Switch to Windows
4. Go Back to Difficulty Level 5. Switch to DOS From now own keyboard interaction is unavailable on both sides but
mouse responds and selects/advances menus."

## Reproduction

A private Checked harness built from an overlay of the tree (`obj/src-base`, the bases above) with build.cmd's
flags; every output under `build/d5k-stage/obj/`.  The script `obj/repro.py` drives the user's sequence in DOS
form (the DOS intro ended by X, Return on the title box, X in Birth, then from 38 s):

| Run | Input | Base result |
|---|---|---|
| `user` | DOS Return (difficulty), chord, Windows Go Back click (469, 319), chord, DOS Down, Down, Return, chord, Windows Down, Return | the DOS view follows back (`setup_page` arg 0 at 40.006650 s); the filter passes the three DOS keys (adapt.log `I-setup/up-down/core-ready pass`, `.../return/core-ready pass`; no pending translation started) and coreinput.log shows them posted; then **no** `setup_row`, `setup_result` or MenuZ exit after 40.006 s: neither the DOS nor the Windows keys have any effect |
| `noback` | the same without the Go Back | DOS Down, Return choose the count; Windows Down, Return choose the tribe (control) |
| `winonly` | `--graphics windows`, no chord: Return, Go Back click, Down, Down, Return, Down, Return | **the same loss without any DOS involvement** |
| `userclick` | `user`, then a DOS press and release on difficulty row 1 | the produced click selects item 1, the queued Return is ignored: the DOS mouse does not advance either |
| `mirror` | Return, Return (tribe page), chord, Go Back (competition page), chord, DOS Down, Return | the keys work (Go Back stays enabled and keeps the focus) |

A debug overlay (`obj/src-dbg`: focus and EnableWindow traces on stderr, never staged) shows in `winonly`:
focus 201A (control 65h, OK, CreateDialog's saved focus) from 34.166650 s; the Go Back click moves it to 201C
(control 66h, Go Back) at 40.003650 s; at 40.006650 s `EnableWindow(201C, FALSE)` and the focus becomes 0.

## Root cause

1. The Windows Go Back click gives the focus to the button: the w16 BUTTON takes the focus on WM_LBUTTONDOWN
   (`platform/w16/user_ctl.c` 1215..1221).
2. Back on the difficulty page MenuZ disables Go Back: `core/seg069_1220_p1.c`, 1220:07DC GetDItem(66h) and
   1220:07FC `EnableWindow(goback, 0)` when `g_dialogMenuMode == -1` (the first page).
3. EnableWindow on the focus window takes the focus away (`platform/w16/user_wnd.c` 3545..3546; the Windows 3.1
   rule: a disabled window cannot hold the focus).
4. With no focus window the queue gives keys to the active window as WM_SYSKEYDOWN / WM_SYSKEYUP
   (`platform/w16/queue.c` 50..53, 543..545).  MenuZ's input loop (1220:0AA0..0AE6: IsKeyPending / GetQueuedKey,
   PeekMessage, IsDialogMessage) and MenuZSubclassWndProc (1220:1289: WM_KEYDOWN 100h and WM_CHAR 102h only) never
   act on them.  Nothing in MenuZ sets the focus again; the item controls do not take it on a click (the
   `userclick` trace shows no focus change), only OK does (a BUTTON).
5. So every key is lost in both graphics until a Windows click on OK; the mouse keeps working because clicks do not
   depend on the focus.

Not the cause: no pending translation (adapt.log: starts 0, no cancellation), the DOS filter's decisions are the
right rows and pass, the DOS setup view follows the backward page change, and the host delivers the keys
(hostinput.log, coreinput.log).  The Windows-profile part is the original's behaviour under the emulation's
Windows 3.1 focus model (`winonly` reproduces it with no switch); only the backward move onto the difficulty page
loses the focus (there Go Back is disabled), the mirror case keeps it.

A same-sync focus restoration does not work: a press on OK released off it and Down posted at one sync
(`obj/repro.py` `winpo0`) lose the Down, because the core reads the key before it dispatches the press (the focus
changes 2 ms after the key was read); with the Down at the next sync (`winpo1`) both work.  Hence the fix below
gives the core no key while it has no focus.

## Fix

`present/dos/pdos_adapt.c/.h` (extension D5K; the rule is written in pdos_adapt.h's header):

* **New hook** `PdosAdaptHooks.unfocused(x, y, off_x)` (appended last; NULL = the default `def_unfocused`): 1 when
  the core's setup MenuZ is in its input loop (`PdosCore.mz_active`, `mz_ready`, `mz_kind == PDOS_MZ_SETUP`,
  `mz_dlg`) and `w16q_focus() == 0`, and its dialog's OK (control 65h) is enabled and shown, with OK's I5 class-C
  point and an x outside OK's window (left of it).  Reads only `w16q_*` and the sequencer (P0, obs_lint).
* **The keys' mouse form** while it answers 1, on a setup page whose core state is READY (`key_mouse`, called from
  `decide` for the PASS and MAP decisions of a key press):
  * Return passed, or Space mapped to Return: a click on OK (MenuZSubclassWndProc's own Return sends WM_COMMAND
    65h, 1220:13BC..13CC; OK's BUTTON takes the focus, so the next keys reach the core again);
  * Up or Down passed: a click on the item the core's move selects (`setup_move` has checked it is the box's next
    row; the item's WM_COMMAND selects exactly as the arrow does, 1220:14C8..14E3 and 1516..1525), then a left
    press on OK, a move off it with the button down and the release there (the BUTTON takes the focus and,
    released outside, notifies nothing), so the first DOS arrow gives the keyboard back in both graphics;
  * the key's release and repeats are consumed (`FD_PAIRS`: complete clicks were posted at the press).
* **In a step** (`pdos_adapt_resolve`, also for the pending translations' later steps): a RETURN act is OK's click,
  a LETTER act the click on the item it would select (item_letter's validity first).  This covers Escape on the
  difficulty page (C, Return), the portrait release (letter, Return), the release in an item row and the tribe
  page's bar-choose and Escape (their queued Return).
* Unchanged: every adapter row (98 rows, 22 steps; DOS-PROFILE 1.7.2 not regenerated), frames 0 and 3 (I2: the
  Windows profile keeps the original's focus rule), the core, the sequencer, the pending translations, the setup
  view.  With the focus present nothing differs (the condition is never met in any existing run: 290 compared output
  files of the 29 existing DOS-form pairs are byte-identical between base and fix).

**Deviations / decisions.**  (1) The mouse form replaces a DOS key only while the core cannot take keys; the
Windows-form pair is input a Windows user can make (clicks; OK pressed and dragged off), so P0 holds.  (2) While the
focus is lost a held arrow moves one row (its repeats are consumed); after the first DOS key the focus is back and
keys and repeats pass as before.  (3) **Open for the user:** after a Windows Go Back to the difficulty page the
Windows graphics alone still has no keyboard until a Windows click on OK or the first DOS key after a switch: this
is the original Windows game's focus behaviour (`winonly`).  Making the Windows graphics take keys at once would
need the same mouse form for frame-0 keys, a deviation from I2 and from the original; not done without the user's
direction.

**The siblings (same defect class), checked privately and listed:**

| Transition (Windows-only or backward) | Focus after it | Keys afterwards |
|---|---|---|
| Go Back competition -> difficulty (the report) | lost (Go Back disabled, 1220:07FC) | **fixed** (D5K) |
| Go Back tribe -> competition (mirror) | Go Back keeps it (enabled) | work (`d-goback-mirror`) |
| Go Back on a name page -> tribe page (`nameback`, `leaderback`) | Go Back keeps it | work |
| Customize World's Cancel (dialog 143) -> title menu | the new title MenuZ dialog takes it at its activation (OK) | work (`d-custom-cancel-keys`) |
| Escape on a name page (DOS key, passed) | the EDIT keeps it; the core stays on the page | work (`nameesc`, `winnameesc`) |

## Tests

* `tests/test_input.c` (`adapt_unfocused`, 20 checks; hook `a_unfocused`, flag `g_aunfocus`): Down and Up without
  the focus give the item's click and OK pressed and released off it (7 events), the repeat and the release are
  consumed and every posted press is released; Return and Space give OK's click, their releases consumed; Escape on
  the difficulty page gives item 0's click and OK's click; a release in an item row gives the item's click and a
  queued Return for that selection, which resolves to OK's click without the focus and to Return with it; with the
  focus Down passes; in T4, on an edge and on the title box nothing changes; a frame-0 key and its release are the
  identity (I2).
* `tests/harness/ext_adapt.py` (C.15.4 pairs; `d_press_off`, `steps_check`, `d_info` gains `lups`; the docstring):
  * `d-goback-keys` - the user's exact sequence: DOS Return, the chord, the Windows Go Back click, the chord, DOS
    Down, Down, Return, the chord, Windows Down, Return <-> the Windows form (no chords; the first Down as the DOS
    run's clicks: item 1, then OK pressed and released off it with `buttons 1`).  Asserted besides: the DOS view
    shows the difficulty page after the Go Back (40..41 s), the DOS keys choose difficulty 2 and the competition page
    follows (43..44 s), the Windows keys choose a count and the tribe page follows (45.5..47 s); 3 switches.
  * `d-goback-mirror` - Go Back from the tribe page to the competition page, then DOS Down, Return and Windows Down,
    Return <-> the same without the chords (keys pass); asserted: competition page after the Go Back, tribe page
    after the DOS Return, the leader name page after the Windows Return.
  * `d-custom-cancel-keys` - Customize World, the chord, dialog 143's Windows-only Cancel, the chord, DOS Down, Down,
    Return <-> the same without the chords; asserted: `title_chosen` 2 (Play on EARTH) from the DOS keys.

## Results (private, `build/d5k-stage/obj/`, 2026-10-16 10:32..11:05 UTC)

* **Compilation** over the overlay `obj/src` with build.cmd's flags (cc.cmd from d5f's, paths to d5k): `cc all`
  Checked, CheckedNoObs, Release: CC_ALL_OK (all portable sources c17, host, the harness where built, civ64.exe);
  `cc strict` (c11 + c17 /W4 /WX and the clang C99 parse) of `pdos_adapt.c` and `input.c` in all three variants:
  CC_STRICT_OK.
* **Unit tests** (argv[1] build/gamedata read only, argv[2] under obj/ut*):

  | Test | Checked | CheckedNoObs | Release | Base (D5 gate / D6c logs) |
  |---|---|---|---|---|
  | test_input | 417 PASS | 390 PASS | 417 PASS | 397 / 370 / 397 |
  | test_pdos_adapt | 145 PASS | 145 PASS | 145 PASS | 145 |
  | test_pdos_pend | 104 PASS | 104 PASS | 104 PASS | 104 |
  | test_pdos_setup | 164 PASS | 164 PASS | 164 PASS | 164 |
  | test_pdos_seq | 190 PASS | - | - | 190 |
  | test_timeline | 158 PASS | - | - | 158 |
  | test_present | 925 PASS | - | - | 925 |

  test_pdos_seq's first private run failed once on "title-box.bmp written" (the BMP write into the fresh output
  directory); three reruns of the same binary (two from bash, one from cmd) and the base binary pass 190/0.  Not
  related to D5K (the check writes a file; pdos_adapt is not on its path).
* **Harness pairs** (`obj/adapt_priv.py`: the staged ext_adapt.py's `d4c2_runs` with the private harness, outputs
  under `obj/adapt-*`): fix: 32 cases, 99 checks, 0 failed (the three new pairs 12 checks, rerun after the final
  line-ending fix of ext_adapt.py: 3 cases, 12 checks, 0 failed); base harness with the
  tree's script: 29 cases, 87 checks, 0 failed; the 29 existing cases' coreinput.log, events.log, adapt.log,
  timeline.log and run.log frame/snapshot/result lines: 290 files compared, 0 differ.  The staged script with the
  **base** harness: `d-goback-keys` fails (the DOS run posts no click: the keys are passed and ignored, nothing to
  pair), `d-goback-mirror` and `d-custom-cancel-keys` pass (not defects).
* **Repro on the fix** (`obj/repro.py src`): `user` - DOS Down posts item 1's click and OK pressed and released off
  it (focus back), the second Down and Return pass as keys and choose difficulty 2, the Windows Down and Return
  choose the count; `userclick` - the DOS release in row 1 posts item 1's click and its queued Return as OK's click:
  the DOS mouse advances again.
* **Static checks** (`obj/chk_priv.py`, the tree's scripts over the overlay, read only): `adapters.py check` with the
  staged header: ADAPT_OK rows 98 steps 22; `obs_lint.py`: OBS_LINT_OK files 115 probes 203 callsites 98;
  `registry.py check` (the include rule over the overlay): REGISTRY_OK, 0 failures; `nodos.py check` over the staged
  files with this record and the private Checked binaries (15 files): NODOS_OK, 0 hits.  `testpar.py` not needed (test.cmd unchanged).

## Expected expectation changes (at the build slot)

* test_input: 397 -> 417 (Checked, Release), 370 -> 390 (CheckedNoObs).
* ext_adapt.py: EXT_ADAPT_OK checks 107 -> 119 (Checked); six more harness runs (about 10 s more; test.cmd's
  `est=95` left as is).
* Unchanged: P0_OK checks 394, G-1, ext_frames, ext_timeline, ext_mirror, ext_zoom, the other unit tests' counts,
  DOS-PROFILE.md 1.7.2, ADAPT_OK rows 98 steps 22 (the condition is never met in an existing run: see Results).

## Rebase notes

* Before the copy-in compare the tree's four files with `BASE-SHA256.txt`; no other stage (d6b, d6c, ux2) touches
  them.  If one changed, merge the D5K hunks, all marked "extension D5K": in pdos_adapt.h the header paragraph and
  the hook member (keep it the last member); in pdos_adapt.c `ID_OK_`, `def_unfocused` / `h_unfocused` after
  `h_point`, the RETURN and LETTER cases of `pdos_adapt_resolve` (and its `ox` local), `key_mouse` before `decide`,
  and the two `key_mouse` calls in `decide`'s PASS and MAP cases; in test_input.c the header paragraph, `g_aunfocus`,
  `a_unfocused` and its place as the 14th initializer of `g_ahooks`, the reset in `ad_setup`, `a_ok_click`,
  `a_ok_off`, `adapt_unfocused` and its call after `adapt_setup()`; in ext_adapt.py the docstring block, `GOBACK`,
  `CUSTOM_CANCEL`, `d_press_off`, `steps_check`, the three `D_CASES` entries before the D5f block and `d_info`'s
  `"lups"`.
* A later unit adding a hook member must append it after `unfocused` (test_input's positional initializer).

## Build-slot steps

1. Check the four bases against `BASE-SHA256.txt` (merge per the rebase notes otherwise).
2. Copy `build/d5k-stage/present/dos/pdos_adapt.h`, `pdos_adapt.c`, `tests/test_input.c`,
   `tests/harness/ext_adapt.py` into the tree, and this record to `docs/ext-D5K-record.md`.
3. The usual cycle: `build.cmd all` Checked, `test.cmd` Checked, G-1 Checked; CheckedNoObs build, test, G-1;
   Release build and test.  Expect the counts above (test_input 417 / 390 / 417, EXT_ADAPT_OK checks 119, the rest
   unchanged).
4. A user build (Release) for the user's check of D5-6.

## What the user checks (after landing)

1. Start with DOS, Return on the difficulty page (the competition page), Ctrl+Shift+Backspace (Windows), Go Back,
   Ctrl+Shift+Backspace (DOS): Up / Down move the bar on the difficulty page, Return chooses it; the competition
   page follows.  Then switching to Windows: the keyboard works there too.
2. The same, but after the switch back to DOS press only Down, then switch to Windows: Windows Up / Down / Return
   work (the first DOS key gave the keyboard back).
3. After the DOS switch-back, the mouse in DOS: a click on a difficulty row chooses it (the page advances).
4. Go Back from the tribe page to the competition page in Windows, then DOS keys: as before, they work.
5. Known and left as the original's behaviour (decision pending): after a Windows Go Back to the difficulty page,
   staying in Windows, the keyboard does nothing until OK is clicked (or a DOS key is pressed after a switch).

## For the records

* STATUS / checklist D5-6: the report's cause (the core's focus after the Windows Go Back, MenuZ 1220:07FC) and fix
  (D5K); the user re-checks D5-6 with items 1..4 above.
* FIDELITY: new entry "the setup MenuZ without the keyboard focus: the DOS keys' mouse form" (the Windows 3.1 rule,
  user_wnd.c EnableWindow, queue.c's system keys; the original loses the keyboard after a Go Back onto the difficulty
  page); the Windows profile keeps the original's behaviour (I2).
* DESIGN 12.7 "As implemented (D5)": add D5K (the unfocused hook, `key_mouse`, the RETURN / LETTER resolution, the
  press on OK released off it).  DOS-PROFILE 3.x "Go Back in setup": after it the DOS keys still work (D5K); the
  rows are unchanged.
* Decision for the user / orchestrator: whether the Windows graphics should also take keys at once after its own Go
  Back to the difficulty page (would apply the mouse form to frame-0 keys: a deviation from I2 and the original).
* Private tools of this unit (`build/d5k-stage/obj/`, not for landing): mkoverlay.py, cc.cmd, ccall.py, repro.py,
  dbgpatch.py (the debug overlay), adapt_priv.py, chk_priv.py, patch_test_input.py, patch_ext_adapt.py, eol.py.

## Landing (2026-10-16, build slot)

Landed by the orchestrator's acceptance of about 11:10 UTC (the build slot given after the D6c docs marker of
10:34:05 UTC; nothing else landing).  The three-step cycle rule applies (CheckedNoObs and Release tests at the D6
phase gate).

* **Bases.** Every base re-verified against the tree at 11:07:30 UTC by `build/d5k-prep/land.py` (each of the four
  tree files still had its base SHA-256 of `build/d5k-stage/BASE-SHA256.txt`, this record was absent, each staged
  copy had its staged hash; test.cmd d924f55c..., build.cmd 40de571d..., both unchanged by D5K).  Before writing it
  snapshotted the Checked test outputs (`build/d5k-prep/before`, 55 files of build/test/Checked and sections) and
  the tree's previous files (`build/d5k-prep/tree-before`).  The four staged files and this record were copied
  byte for byte; manifest `build/d5k-prep/landed.sha256` (this record's hash there is the copy before this section
  was added).
* **The three-step cycle** (`build/d5k-prep/d5k-cycle.ps1`, detached, each step waiting on its own cmd.exe; status
  `build/d5k-status.txt`):
  1. `build.cmd checked`: exit 0, 246 s (11:07:47..11:11:52), BUILD_OK, portable sources 291
     (`build/d5k-1-build-checked.log`).
  2. `test.cmd checked`: exit 0, 1375 s (11:11:53..11:34:48), TESTS_OK, TEST_SECTIONS 25, failed 0, wall 1373.2 s
     (`build/d5k-2-test-checked.log`).  test_pdos_seq 190 checks, 0 failed: the transient "title-box.bmp written"
     failure of the private run did not recur.
  3. `ext_g1.py check`: EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events), unchanged
     (`build/d5k-3-g1-checked.log`).
  ALL_GREEN.
* **Against the snapshot** (`build/d5k-prep/compare.py` -> `compare.txt`, host-time lines left out; 48 of 55 files
  equal).  Every difference is a predicted one or host timing, except the informational coverage count:
  * `ext-adapt.txt` / `sections/ext_adapt.log`: the three new pairs' lines (d-goback-keys, d-goback-mirror,
    d-custom-cancel-keys; their timeline lines carry times and are left out of the comparison), `EXT_ADAPT_OK checks
    107 -> 119` (predicted).
  * `sections/unit.log`: `test_input` 397 -> 417 checks (predicted); the OBS_COST line (host nanoseconds).
  * `coverage.txt` / `sections/coverage.log`: "other functions entered" 662 -> 665 (not predicted; coverage.py is
    informational and does not fail: the new pairs reach three core functions no earlier run entered; the earlier
    per-function lists were not snapshotted, so the three are not named).
  * `nodos.txt`: 1708 -> 1709 files (this record), 0 hits, NODOS_OK.
  * `sections/times.txt`: host times.
  Unchanged as predicted: P0_OK checks 394, test_user 343, test_pdos_adapt 145, test_pdos_pend 104, test_pdos_setup
  164, test_pdos_seq 190, test_timeline 158, test_present 925, ext_frames, ext_timeline, ext_mirror, ext_zoom,
  adapters ADAPT_OK rows 98 steps 22, obs_lint, registry.
* **Release** (`build.cmd`, the same script with -FirstStep 4): exit 0, 255 s (11:36:18..11:40:34), BUILD_OK
  variant=Release (`build/d5k-4-build-release.log`); RELEASE_OK.
* **User build** `build/user-builds/d5k/`: civ64.exe from build/x64/Release (8c837c7f...), CIVWIN.zip and civdos.zip
  copied from `build/user-builds/d4/`, WHAT-TO-CHECK.txt (D5K-1..D5K-4: the user's exact D5-6 sequence and what now
  happens; the Windows-only remainder named as the original's behaviour, being fixed next as D5K2; the build
  contains everything in d6c, ux2 and d5).
* **Follow-up.** The user's answer of 11:12 UTC ("Fix Windows too") is staged as unit D5K2 (`build/d5k2-stage/`,
  the platform's dialog focus rule; this unit's hook stays as a defence).

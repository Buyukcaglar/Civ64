# Extension D5, bug-fix unit D5K2 (a dialog keeps the keyboard focus when its focused control is disabled) - record

Extension session E3, staging implementer.  Staged under `build/d5k2-stage/` only; nothing in the tree or in a shared
output was written for D5K2.  Base snapshot of the tree: 2026-10-16 11:13:54 UTC, the tree after D5K's copy-in
(`BASE-SHA256.txt`); D5K's landing cycle ended ALL_GREEN at 11:34:48 UTC with these files unchanged.

## Status

**LANDED** 2026-10-16 (the three-step cycle ALL_GREEN 12:35:19 UTC; see "Landing").  Staged as
**READY_TO_BUILD.**  The user chose to have the Windows-only remainder of D5-6 fixed too: after a Windows Go Back to
the difficulty page the Windows graphics take keys at once.  The fix is one platform rule in the Win16 dialog
manager (base-track code shared by both profiles, so P0 holds): when EnableWindow(FALSE) disables the control that
has the focus inside a visible, enabled dialog, the focus goes to the dialog's default push button, else its first
usable tab stop, else the dialog, where Windows 3.1 left no focus.  The core is untouched.  No base output changes
(G-1's runs do not reach the rule).  The private results are all green.

| Staged file | Base sha256 (tree, 11:13:54 UTC) | Staged sha256 |
|---|---|---|
| `platform/w16/user_wnd.c` | `d44128cff1ffda81096967c1dade51cbdd10a739ae2d3f4ca62e94a023234b26` | `42324e0aa2b261b33e57b52db132de4e0db7222b7b01d06b02938b0514fd4527` |
| `platform/w16/user_dlg.c` | `264ffeb25d4ed34f5267b9eeca2cb0cf763c550db5aa98d32c9d95a107eb5368` | `e4e9d08088944c85ac90c2692f3f22767158d10941de7e164d15f194b8c6cd6a` |
| `platform/w16/w16_int.h` | `6398a03952d307e1b62d334a4e6a9771d38e0679163f9e4842054ff956a48e98` | `c415b19b3abab87728f13a7267235c905c73ab68f68700bde02316c6e5a49fb4` |
| `tests/test_user.c` | `f5f1c9a1e7305d522fc2d19477b0aa3aac1e38adcf365f247f0d9367bfd9c352` | `2d52043940c1ba487d7702b9e20e369340b7d0d46620ca006e472e4b4fa17180` |
| `tests/harness/ext_adapt.py` | `a2e67757f989ff8cf62e9b65a3be1e5f4549c5fef6530a51afdbb9859ed466e3` | `dd3e6af7cb2379fc9ffa906ac045e37713bde799f67becc27cac4f65c05f9c62` |
| `present/dos/pdos_adapt.h` | `5ec34eacbcdaca2709c3e19315f707f9869a3e492a89391fe6029f39aff88620` | `e3304ebd44e2f88d7f7ba763ead3b677155b4d8b1ed5a5a25dbd4b448cb674f4` |
| `docs/ext-D5K2-record.md` | new | (this file) |

`test.cmd`, `build.cmd`, the core, the adapter table and `DOS-PROFILE.md` are unchanged (no `BUILD-TEST-ADDITIONS.md`,
no `adapters.py gen`, no G-1 amendment).  Line endings follow the bases (LF for the platform files, `test_user.c` and
`ext_adapt.py`; CRLF for `pdos_adapt.h`).

## The user's direction

STATUS.md "User directions", 2026-10-16 11:12 (relayed by the orchestrator at about 11:13 UTC), answering D5K's open
decision with "Fix Windows too (Recommended)": "When a dialog's focused button gets disabled, civ64 gives the keyboard
focus back to the dialog (e.g. its OK), so keys keep working in the Windows graphics. A small, recorded deviation from
the original Windows 3.1 behaviour."  Background: D5-6 (`ext-D5K-record.md`); D5K made the DOS keys work after the
Windows Go Back, and left the Windows-only case (no switch back) as the original's behaviour.

## The rule and its scope

`platform/w16/user_wnd.c` `w16_EnableWindow`: when it disables the focus window, the focus goes to
`w16_dlg_focus_successor(hwnd)` instead of 0 (one line; the window is already marked disabled).
`platform/w16/user_dlg.c` `w16_dlg_focus_successor(lost)` (new; prototype in `w16_int.h`):

1. The nearest dialog of this dialog manager (`DlgInfo.used`, CreateDialog) that holds `lost` through WS_CHILD
   parents; none, or the dialog hidden or disabled: 0, Windows 3.1's rule (unchanged behaviour).
2. Its default push button: the defid that DM_GETDEFID reports (the template's first BS_DEFPUSHBUTTON, or one set by
   DM_SETDEFID), read from `DlgInfo` without sending DM_GETDEFID (no new message to the program's dialog procedure),
   when it exists, is not `lost` and is usable (visible, enabled).
3. Else the first usable WS_TABSTOP control (`next_tab`, IsDialogMessage's Tab order).
4. Else the dialog itself (its WM_SETFOCUS goes to the dialog procedure; DefDlgProc restores a saved or first
   tab-stop control as before).

The focus change is the usual one (`set_focus_raw`): WM_KILLFOCUS to the disabled control (wParam the successor
instead of 0), WM_SETFOCUS to the successor, then WM_ENABLE as before.

**Decisions.**
* **All dialogs of the dialog manager, not only MenuZ's** (the brief's choice): the platform does not know the
  program's dialogs, and a MenuZ-only rule would tie the Win16 layer to template 144 or class CIVDIALOG.  In this
  program the difference is nil: the core's only EnableWindow(FALSE) calls are MenuZ's 1220:07FC (Go Back on the
  first setup page) and 1220:09E9 (an item window created a moment before, which cannot have the focus); the
  platform's own callers (`user_msgbox.c`) disable top-level windows, which are not inside a dialog.  So the rule
  acts only where D5-6 found the defect.  Top-level windows, children of windows that are no dialog, and hidden or
  disabled dialogs keep Windows 3.1's rule (no focus).
* **Hiding is unchanged.**  ShowWindow(SW_HIDE) of a focused child already gives the focus to its top-level window
  (`user_wnd.c`, the hide path: `set_focus_raw(is_top(w) ? 0 : top_of(h))`), i.e. the dialog, whose DefDlgProc
  restores a control; it never leaves a dialog without focus, so it needs no change (narrowest).  Destroying the
  focus window (focus 0) and minimizing are also unchanged; no D5-6-like report concerns them.
* **D5K's DOS-side hook stays as a defence.**  `PdosAdaptHooks.unfocused` answers 0 whenever a focus exists, so with
  D5K2 it no longer acts after the Go Back (the DOS keys pass as keys); it changes nothing while focused (D5K showed
  290 compared output files identical) and would still give the DOS keys a way in should the setup MenuZ ever be
  without focus by another path.  Removing it would churn code that landed an hour earlier and drop 20 unit checks
  for no gain.  Its comment in `pdos_adapt.h` now says so; `ext_adapt.py`'s `d_press_off` (used only by D5K's
  Windows form of `d-goback-keys`) and `d_info`'s `"lups"` entry are removed as unused.

**Deviation (recorded for FIDELITY).**  Windows 3.1 left no focus after disabling the focus window (the Windows 3.1
SDK; `user_wnd.c`'s rule since phase 3a).  civ64 now keeps a dialog's focus as above.  Visible effect in the Windows
graphics: after a Go Back to the difficulty page OK shows the focus (as on the first visit of that page) and the keys
work.  Core state, frames of the DOS view, timing and the random stream are unaffected (P0: the rule is in the
shared platform, identical for both profiles).

## Tests

* `tests/test_user.c` `test_d5k2_focus` (12 checks; DIALOG 144, the setup dialog of the report, and DIALOG 145 from
  the game's resources, with CIVDIALOG's messages routed to DefDlgProc as CivDialogProc does, `g_defdlg`; the test
  dialog procedure now pops its 10 argument bytes, which no earlier test needed because none called it):
  the shown dialog's controls and no default button; disabling the focused Go Back gives the focus to OK (first
  usable tab stop); re-enabling and disabling a control without the focus move nothing; a default button set by
  DM_SETDEFID (RandomUser 103, no tab stop) is preferred to the first tab stop; the disabled control itself as the
  default button, and a disabled default button, fall back to the first usable tab stop; no usable control: the
  dialog itself; inside a disabled dialog no focus; DIALOG 145's BS_DEFPUSHBUTTON OK (DM_GETDEFID reports 101)
  takes the focus from the disabled Help; a focused child of a window that is no dialog (WM_KILLFOCUS(0)) and a
  focused top-level window keep Windows 3.1's rule.  With the base platform code 8 of the 12 fail (the 4 "does not
  move" cases pass), so the vectors detect the rule.
* `tests/harness/ext_adapt.py`:
  * `d-goback-winkeys` (new) - the report's Windows-only run: DOS Return, the chord, the Windows Go Back click, then
    Windows Down, Down, Return, Down, Return without a switch back <-> the pure Windows run (`--graphics windows`,
    D5K's `winonly` reproduction); asserted: the difficulty page after the Go Back, difficulty 2 chosen by the
    Windows keys and the competition page, then the tribe page; 1 switch.
  * `d-goback-keys` - its Windows form is now the keys (the focus is on OK, so the DOS run posts its keys as keys:
    `nclicks` 3 -> 1); the DOS form and the assertions are unchanged.

## Results (private, `build/d5k2-stage/obj/`, 2026-10-16 11:14..11:47 UTC)

* **Compilation** over the overlay `obj/src` (the tree after D5K's landing plus this stage) with build.cmd's flags
  (`obj/cc.cmd`): `cc all` Checked, CheckedNoObs, Release: CC_ALL_OK (all portable sources c17, the harness where
  built, host_win32.c and civ64.exe, the tests named); `cc strict` (c11 + c17 /W4 /WX and the clang C99 parse) of
  `user_wnd.c` and `user_dlg.c` in all three variants and of `pdos_adapt.c` (Checked, the header comment): CC_STRICT_OK.
* **Unit tests** (argv[1] build/gamedata read only, argv[2] under obj/ut*):

  | Test | Checked | CheckedNoObs | Release | Tree (D5K landing cycle / D5 gate) |
  |---|---|---|---|---|
  | test_user | 355 PASS | 355 PASS | 355 PASS | 343 / 343 / 343 |
  | test_input | 417 PASS | 390 PASS | 417 PASS | 417 / 390 / 417 |
  | test_commdlg, test_observer, test_queue, test_start | 18, 108, 129, 110 PASS | - | - | the same |
  | test_present, test_pdos_seq, test_pdos_adapt, test_timeline | 925, 190, 145, 158 PASS | - | - | the same |

  `test_user` with the new vectors on the base platform code (overlay `src-t`): 8 of the 12 D5K2 checks fail (all
  successor cases), the 4 "does not move" checks pass.
* **ext_adapt pairs** (`obj/adapt_priv.py`: the staged ext_adapt.py's `d4c2_runs` with the private D5K2 harness,
  outputs `obj/adapt-src/`): 33 cases, 103 checks, 0 failed (D5K's landed script: 32 cases, 99 checks).
  `obj/cmp_adapt.py` against the tree's Checked outputs of D5K's landing cycle (`build/harness/Checked/adapt`, read
  only; coreinput.log, events.log, adapt.log, timeline.log, run.log's frame/snapshot/result lines): 313 files equal,
  7 differ, all of `d-goback-keys` (its DOS keys now pass as keys, so coreinput and adapt.log differ from the 10th /
  5th line; run.log's frames from the frame after the Go Back, where OK shows the focus; events.log equal), plus the
  new `d-goback-winkeys` pair.  With the base harness (`base-new`, overlay `src-t`): `d-goback-winkeys` fails (no
  setup_result 2, setup_page 256 or 512: the Windows keys are lost, D5-6's remainder) and `d-goback-keys` fails
  (D5K's hook posts its clicks, so the pair differs).
* **G-1 / base runs.**  `ext_p0.py Checked --vars V0` with the private harness (`--root obj/p0root`): P0_OK checks 27:
  every V0 run that is a G-1 run (the 23 scenario runs p4-* and gate3b-s2, s2b, s2c, s3) equals
  ext-g1-baseline.txt (as amended).  Of the 77 G-1 runs only 9 enter RunNewGameSetup (observer-probes.log of the
  tree's runs: 10E8:0000 entered once in gate3b-s3, gate3b-s3-r, p4-birth, p4-custom, p4-earth, p4-new,
  p4-settlers, uninit-s3, uninit-s5); the six of them checked above are equal, gate3b-s3-r repeats s3's input, and
  uninit-s3 / s5 (new-game.script, soak-new.script) send only Return, Space and B (plus WM_CHAR), no Tab, arrow or
  mouse input, so Go Back never has the focus there.  The rule acts only inside EnableWindow(FALSE) on the focus
  window: the core's 1220:07FC with Go Back focused (a press on it, or IsDialogMessage's Tab or group navigation),
  never in these runs.  **No base output change**; no G-1 amendment.
* **P0** (`ext_p0.py --vars V0,V1,V2 --only d5-goback,d5-custom-cancel`, private): P0_OK checks 12 (V1 and V2 equal
  V0, switch assertions, decision 8's counters).  `d5-goback` (an extension run, not in G-1) itself changes against
  the tree's D5K outputs: frames 576..583 (after its Go Back click at 28 s: OK shows the focus), 16 more core steps
  (18421516 -> 18421532: the core's procedures receive the messages of OK's focus change) and so its watchdog
  snapshot hash and result line; events.log equal.  P0 compares it across presentations only, so its checks are
  unchanged.  `d5-custom-cancel` is equal in all fields.
* **Static checks** (`obj/chk_priv.py`, the tree's scripts over the overlay, read only): ADAPT_OK rows 98 steps 22;
  OBS_LINT_OK files 115 probes 203 callsites 98; REGISTRY_OK; `nodos.py check` over the staged files, this record
  and the private Checked binaries (20 files): NODOS_OK, 0 hits.  `testpar.py` not needed (test.cmd unchanged).

## Expected expectation changes (at the build slot)

* test_user: 343 -> 355 (Checked, CheckedNoObs, Release).
* ext_adapt.py: EXT_ADAPT_OK checks 119 -> 123 (Checked; one more pair, two more harness runs, about 3 s).
* Unchanged: test_input 417 / 390 / 417 and every other unit test's count; P0_OK checks 394 (Checked) and 62
  (CheckedNoObs; d5-goback's outputs change alike in every presentation); G-1 EXT_G1_OK runs 77 (amended 1) with no
  new amendment; ext_frames, ext_timeline (and its goldens), ext_continue, the bs sections, ext_mirror, ext_zoom;
  ADAPT_OK rows 98 steps 22; DOS-PROFILE 1.7.2; obs_lint files 115.
* Possible informational change: coverage.py's "other functions entered" (it does not fail).
* nodos: files + 1 (this record), 0 hits.

## Rebase notes

* Before the copy-in compare the six files with `BASE-SHA256.txt` (the tree after D5K's landing).  All hunks are
  marked "extension D5K2" / "D5K2": `user_wnd.c` the header bullet "Disabling the focus window" and the one-line
  change in `w16_EnableWindow`; `user_dlg.c` the header bullet and `w16_dlg_focus_successor` after
  `w16_dlg_saved_focus`; `w16_int.h` the prototype after `w16_dlg_saved_focus`; `test_user.c` the header bullet,
  `g_defdlg`, its branch at the end of `test_wndproc`, the pop in `test_dlgproc`, `test_d5k2_focus` after
  `test_about_template` and its call in `main`; `ext_adapt.py` the docstring (d-goback-keys and the D5K2 block),
  d-goback-keys' `win` form and `nclicks`, the D5K2 case after `d-custom-cancel-keys`, `d_press_off` and `"lups"`
  removed; `pdos_adapt.h` the last sentences of the D5K paragraph.
* No other stage known to the implementer touches these files; a concurrent platform change to `w16_EnableWindow`
  or to `user_dlg.c`'s focus helpers needs a merge.

## Build-slot steps

1. Check the six bases against `build/d5k2-stage/BASE-SHA256.txt` (merge per the rebase notes otherwise).
2. Copy the six staged files into the tree and this record to `docs/ext-D5K2-record.md`.
3. The three-step cycle: `build.cmd checked`, `test.cmd checked`, `ext_g1.py check`.  Expect the counts above.
4. A Release build and a user build for the Windows-only check (and D5-6 again).

## What the user checks (after landing)

1. Windows graphics (or DOS, then switch to Windows): Return on the difficulty page, click Go Back on the competition
   page: the difficulty page again with OK showing the focus; Up / Down move the selection and Return chooses it,
   the competition page follows; keys keep working on the next pages.
2. The D5-6 sequence (DOS, competition page, switch to Windows, Go Back, switch to DOS): DOS keys work at once, and
   after switching to Windows the Windows keys too (as with D5K).
3. Go Back from the tribe page and from the name pages, Customize World's Cancel: the keys work as before.

## For the records

* FIDELITY, new entry (next free number, F182 if none was taken meanwhile): "a disabled focused control in a dialog
  (`platform/w16/user_wnd.c` `w16_EnableWindow`, `user_dlg.c` `w16_dlg_focus_successor`; MenuZ 1220:07FC) | Windows
  3.1: EnableWindow(FALSE) on the focus window leaves no focus, and keys then reach the active window as
  WM_SYSKEYDOWN, which MenuZ ignores: after a click on Go Back that returns to the first setup page the dialog takes
  no keys until OK is clicked (D5-6) | civ64 gives the focus to the dialog's default push button, else its first
  usable tab stop, else the dialog, when the disabled window is inside a visible, enabled dialog of the dialog
  manager; every other window keeps Windows 3.1's rule; hiding and destroying are unchanged.  In this program only
  MenuZ's Go Back on the difficulty page meets it; there OK shows the focus and the keys work in both graphics
  (**the user's direction of 2026-10-16 11:12**, an accepted deviation; P0 unaffected: shared platform).  Status:
  implemented in D5K2; tests `test_user` 355 (`test_d5k2_focus`), `ext_adapt.py` d-goback-winkeys and d-goback-keys;
  user check pending | `ext-D5K2-record.md`; `ext-D5K-record.md`".
* `user_wnd.c`'s and `user_dlg.c`'s headers carry the rule (recorded rules of the platform).
* STATUS / checklist D5-6: the Windows-only remainder fixed by D5K2 (user check above).
* DESIGN 12.7 "As implemented (D5)": D5K's hook now a defence (no harness pair exercises it; `test_input`'s 20 checks
  do).
* Private tools (`build/d5k2-stage/obj/`, not for landing): mkoverlay.py, cc.cmd, eol.py, adapt_priv.py, chk_priv.py,
  cmp_adapt.py; overlays `src`, `src-base`, `src-t` (the base platform with the new `test_user.c`).

## Landing (2026-10-16, build slot)

Landed by the orchestrator's acceptance of about 11:50 UTC (decisions accepted: all dialogs of the dialog manager,
D5K's DOS hook kept as a defence, no G-1 amendment), in the slot after UX3: UX3's status showed ALL_GREEN and its
Release / `build/user-builds/ux3/WHAT-TO-CHECK.txt` existed at 12:09:19 UTC (no docs pass between).

* **Bases.** All six re-verified against the tree after UX3's landing (each still had its base SHA-256 of
  `build/d5k2-stage/BASE-SHA256.txt`; UX3 touched none of them; no merge).  `build/d5k2-prep/land.py --write` at
  12:09:47 UTC: this record absent, each staged copy had its staged hash; test.cmd bd73aba1... (UX3's) and build.cmd
  40de571d..., both unchanged by D5K2.  Before writing it snapshotted the Checked test outputs
  (`build/d5k2-prep/before`, 57 files of build/test/Checked and sections) and the tree's previous files
  (`build/d5k2-prep/tree-before`).  The six staged files and this record were copied byte for byte; manifest
  `build/d5k2-prep/landed.sha256` (this record's hash there is the copy before this section was added).
* **The three-step cycle** (`build/d5k2-prep/d5k2-cycle.ps1`, detached, each step waiting on its own cmd.exe; status
  `build/d5k2-status.txt`):
  1. `build.cmd checked`: exit 0, 241 s (12:09:55..12:13:56), BUILD_OK, portable sources 291
     (`build/d5k2-1-build-checked.log`).
  2. `test.cmd checked`: exit 0, 1283 s (12:13:56..12:35:19), TESTS_OK, TEST_SECTIONS 26 (UX3 added one), failed 0,
     wall 1280.8 s (`build/d5k2-2-test-checked.log`).
  3. `ext_g1.py check`: EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events), unchanged: no base output
     change, as predicted (`build/d5k2-3-g1-checked.log`).
  ALL_GREEN.
* **Against the snapshot** (`build/d5k2-prep/compare.py` -> `compare.txt`, host-time lines left out; 50 of 57 files
  equal).  Every difference is a predicted one, host timing or informational:
  * `ext-adapt.txt` / `sections/ext_adapt.log`: d-goback-keys' pair now coreinput 19 (was 24: its DOS keys pass as
    keys, no hook clicks); the new d-goback-winkeys pair (decisions, equal to its Windows-form pair with coreinput
    19, both reached birth-end; its timeline line carries times and is left out of the comparison);
    `EXT_ADAPT_OK checks 119 -> 123` (predicted).
  * `sections/unit.log`: `test_user` 343 -> 355 (predicted); the new test's host trace lines (CreateDialog 144 and
    145, their activations); the OBS_COST line (host nanoseconds).
  * `coverage.txt` / `sections/coverage.log`: "other functions entered" 664 -> 666 (informational, named as a
    possible change: the paths of OK's focus change after the Go Back and the Windows-only pair).
  * `nodos.txt`: 1713 -> 1714 files (this record), 0 hits, NODOS_OK.
  * `sections/times.txt`: host times.
  Unchanged as predicted: P0_OK checks 394, test_input 417, every other unit test, ext_frames, ext_timeline,
  ext_continue, the bs sections, ext_mirror, ext_zoom, ADAPT_OK rows 98 steps 22, obs_lint, registry.  The
  transient test_pdos_seq failure of D5K's private run did not recur.
* **Release** (`build.cmd`, the cycle script with -FirstStep 4): exit 0, 301 s (12:35:30..12:40:31), BUILD_OK
  variant=Release (`build/d5k2-4-build-release.log`); RELEASE_OK.
* **User build** `build/user-builds/d5k2/`: civ64.exe from build/x64/Release (18dd5397...), CIVWIN.zip and civdos.zip
  copied from `build/user-builds/d4/`, WHAT-TO-CHECK.txt (D5K2-1: the Windows-only Go Back to the difficulty page,
  OK showing the focus, the keys at once; D5K2-2 the D5-6 sequence again; D5K2-3 the other backward transitions;
  the build contains everything in ux3, d5k, d6c, ux2 and d5).

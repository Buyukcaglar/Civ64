# Extension unit FCE (Escape on the game's list, modal and name dialogs) - record

Draft for the build slot.  The orchestrator's assignment (2026-10-17): "Escape on the game's list and modal dialogs",
settled from the code first: does the original's dialog loop call IsDialogMessage, which window do the subclass
procedures subclass, what WM_GETDLGCODE do the focused controls return under Windows 3.1 and does w16 match, and was
the game's WM_CHAR 1Bh handler reachable.  (a) If the original under Windows 3.1 cancels on Escape, fix the platform;
(b) if it ignores Escape, keep the Windows graphics and make Escape cancel in the DOS graphics only, per the user's
rule (2026-10-16, verbatim): "Yes: in DOS graphics never show a Go Back or Cancel row the DOS game doesn't have, on any
screen; where DOS has a key for it (e.g. Escape), that key does it, otherwise that choice is only in the Windows
graphics."  The interim report found (b); the orchestrator accepted it (2026-10-17, verbatim): "The Windows graphics
stay unchanged. A platform helper posts WM_CHAR 1Bh to a dialog that has no IDCANCEL control. The DOS adapter calls it
only while the DOS graphics are shown, and only for the dialogs whose DOS screen cancels on Escape. Check each one
against the DOS listing. Record it as a DOS-profile adapter rule. No G-1 amendment. Keep your adapter hunk minimal and
separate, so D6f can rebase onto it."  Also: Customize World's Escape write out of bounds (below), recorded as an
original defect reproduced faithfully, with an open item for X9.

Staged in `build/fce-stage/` (bases = the tree's files, copied 2026-10-17 00:55:57 UTC, re-checked 02:03 UTC;
`BASE-SHA256.txt`; test.cmd additions in `BUILD-TEST-ADDITIONS.md`).  Private builds and runs only in
`build/fce-stage/obj/` (an overlay `obj/src` = tree + stage, built with build.cmd's own flags through `obj/b.cmd`;
harness copies in `obj/exe`: `tree-harness.exe` = the tree's Checked harness after TLD's build, without FCE;
`fce-harness.exe` = the overlay's).  Labels: **DOS listing** (`build/dos/disasm`), **binary** (the Windows game's
listing and recovered source, `claude/src`), **platform** (Windows 3.1 behaviour as the SDK describes it; w16 follows
it, Q10/F29), **inferred**.

## Status

LANDED: copy-in 2026-10-17 02:32:11 UTC, the fix 03:02:26 UTC, cycle -r2 ALL_GREEN 03:41:10 UTC, RELEASE_OK
03:45:49 UTC, user build `build/user-builds/fce/` (section "Landing").  In the DOS graphics Escape now closes Find
City, the Civilopedia lists, the production list (City > Change Production) and the city name (a new city, City >
Rename City), as Cancel, Exit or Go Back does; in the Windows graphics Escape does nothing there, as in the original
under Windows 3.1.  The user's checks FCE-1..FCE-5 are pending (user build `build/user-builds/fce/`).

## Findings (settled from the code)

1. **The loops call IsDialogMessage only** (binary).  RunListBoxDialog 1098:1909 polls PeekMessage(PM_REMOVE) and
   hands every message to IsDialogMessage (1098:1BEE..1C1A; IsDialogMessage at 1098:1C11), with no TranslateMessage
   or DispatchMessage; RunModalDialogLoop 1170:1F84 the same (1170:1FDA..200A; 1170:2001); RunTextEntryDialog 10F0:0066
   (dialog 137) polls PeekMessage with the dialog as the window filter and calls IsDialogMessage (10F0:014B..0175),
   then tests the removed message itself (10F0:017F..01BD, below).
2. **The subclass procedures are on the dialog windows themselves** (binary): SetWindowLong(GWL_WNDPROC) on the
   dialog's hwnd, ListDialogSubclassProc 1098:1BB0..1BBC, ModalDialogSubclassProc 1170:1FAC..1FB8, NameDialogWndProc
   10F0:012B..0137.  None is on a control.
3. **Escape never becomes a character there** (platform; w16 the same).  Under Windows 3.1 IsDialogMessage asks the
   focused control for WM_GETDLGCODE: a list box answers DLGC_WANTARROWS | DLGC_WANTCHARS, a single-line edit
   DLGC_WANTCHARS | DLGC_HASSETSEL | DLGC_WANTARROWS; neither wants all keys, so IsDialogMessage handles VK_ESCAPE
   itself: WM_COMMAND IDCANCEL (2) to the dialog, TRUE, without TranslateMessage, so no WM_CHAR 1Bh is made.  w16
   does the same (`user_dlg.c` w16_IsDialogMessage's VK_ESCAPE case; `user_listbox.c` WM_GETDLGCODE 0x81;
   `user_ctl.c` EDIT 0x89; Q10, F29).
4. **No game dialog has a control 2** (binary): the templates' ids are 101..108, -1 (statics), 803..818 (dialog
   143's regions) and 300..851 (2000's, which no code opens; `claude/docs/resources.md`); the controls made at run
   time (every USER.CreateWindow call) are RunListBoxDialog's LISTBOX 103 (1098:1AB5), MenuZ's title 400 and items
   500.. (1220:08D5, 09B0), RunTextInputDialog's 400 and 450 (1220:17AB, 1813), the city screen's buttons 150..152
   (1030:94AA) and the spaceship's 999 (1070:0D6F).  So IDCANCEL reaches: ListDialogSubclassProc's WM_COMMAND (101,
   102, 103's double click only) and DefDlgProc, whose DlgProc 1098:16E2 handles 101 and 102 only: nothing;
   ModalDialogSubclassProc's (101..104): nothing; NameDialogWndProc records 2 as the command, which the loop ignores
   (10F0:01BF, 01F9): nothing; CustomizeWorldWndProc records 2 as the command: the defect below.
5. **The game's WM_CHAR 1Bh handlers were unreachable from the keyboard** under Windows 3.1 (findings 1..4):
   ListDialogSubclassProc 1098:1DA8 (Escape -> -1, as Cancel/Exit 102 at 1098:1E60), ModalDialogSubclassProc
   1170:206F..20B6 (Escape -> 102, Cancel), RunTextEntryDialog's loop 10F0:0196..01BD (Escape -> WM_COMMAND 102, Go
   Back) and CustomizeWorldDialog's subclass 1108:0845 (Escape -> 102).  They are reached only by a WM_CHAR 1Bh that
   is put in the queue for the dialog itself, which is what FCE does in the DOS graphics.
6. **Observed in civ64** (harness, `tree-harness.exe`, the 7.8 host-input mode: arrival, filter, host_sync): Escape
   on Find City, a Civilopedia list, the production list and the city name posts WM_KEYDOWN 1Bh and WM_KEYUP 1Bh to
   the core and the dialog stays open to the run's end, in both graphics (`obj/ext-fce-tree.txt`: the four Windows
   runs pass, the four DOS runs fail).  So **(b)**: the Windows graphics are faithful; no platform fix.
7. **The DOS screens** (DOS listing): Find City's typed-name box returns 0 on Escape, no city (O23:0319, O23:0414;
   SCENES 10.4); the Civilopedia index O8:0000 leaves with Esc or x (SCENES-PLAY 7.13); the production menu box returns
   -1 on Escape (R:1D05:0392) with the help flag 0 (R:1D05:0340 -> 0450), and R:0ADE:0421 returns its table[0]
   (R:0ADE:1468..146C, 1495 -> 14E3), the city record's +9 byte (R:0ADE:0447..0459; the production, its name inferred
   from the Windows counterpart): the production unchanged, as dialog 140's Cancel returns ChooseCityProduction's
   first entry, g_cities[].production (1170:1F02..1F0E; binary); the city name box O23:0414 returns 0 on Escape
   (O23:0565..056B) and O23:0000 skips the copy (O23:0096..009A): a new city is not founded (O20:00EC..00FB returns
   -1), a renamed city keeps its name (R:0D12:0045's call), as Go Back's 0 in the Windows graphics (PromptCityName
   10F0:002F..0033 copies only on 1; FoundCity's call 1040:00FF..0107; the city screen's Rename 1030:5F63).  One
   difference: DOS asks for the name again when the text is empty (O23:008F..0093), also after Escape; Go Back does
   not ask again.

## The rule (a DOS-profile adapter rule, area C)

In the DOS graphics, a new Escape press without Alt or Ctrl held, while the active window is one of these dialogs,
becomes that dialog's own cancel character: the filter stage (pdos_adapt.c key_down, rule I1) emits one host
character 1Bh marked `PI_CHAR_TO_DIALOG` (input.h; `PDOS_CHAR_TO_DIALOG` in pdos_fce.h, which input.c checks equal)
with the dialog's window in `x`; host_sync.c posts it as input for
that dialog (`w16_dlg_post_char`: WM_CHAR 1Bh with the dialog's hwnd, lParam repeat 1 and the press's scan code), and
the game's own handler (finding 5) cancels.  The press's repeats are consumed on every frame (as an OWN press's,
D4cF R6); its release passes to the core as WM_KEYUP 1Bh, as the release of a key whose press closed a dialog does
(Return's after OK).  RunTextEntryDialog's loop needs that next message: it acts on the Go Back it sent at the next
message it removes for the dialog (10F0:01F9..020B), so dialog 137 closes at the release (the harness: 50 ms later).
The dialogs, by their controls (`pdos_fce_dialog`, read through w16q only, O4; Win16 class names without case):

| Dialog | Controls that name it | Opened by | Escape becomes |
|---|---|---|---|
| 131 Find City | BUTTON 101, BUTTON 102, a shown LISTBOX 103, STATIC 106, no EDIT | RunListBoxDialog (ShowFindCityDialog 1068:004C, call 1068:0183) | ListDialogSubclassProc's -1 (Cancel) |
| 130 with its list (the Civilopedia lists) | BUTTON 101, BUTTON 102, a shown LISTBOX 103 (RunListBoxDialog's CreateWindow 1098:1AB5) | RunListBoxDialog (ShowCivilopediaSection 1068:0295, call 1068:0544) | -1 (Exit) |
| 140 production | BUTTON 101, 102, 103, a shown LISTBOX 104, STATIC 106 | RunModalDialogLoop (ChooseCityProduction 1170:05CA) | 102 (Cancel): the production unchanged |
| 137 city name | BUTTON 101, BUTTON 102, a shown EDIT 103, STATIC 104 | RunTextEntryDialog (PromptCityName 10F0:0000) | WM_COMMAND 102 (Go Back): no city, or the name kept |

In every case the dialog must be the active top-level window, shown and enabled, with at most 64 children, no
control 2, no other LISTBOX or EDIT (a hidden one counts as other).  So: a Civilopedia list showing an entry (the list
hidden, 1098:1C75) is not named and Escape passes as before; DIALOG 144 with the setup name page's EDIT 450 is not
named (D5d's I-text keeps it); DIALOG 143 (Customize World) is not named (D5e's I-custom keeps it).
`w16_dlg_post_char` refuses a window that is not a dialog of the manager, a control, a hidden or disabled dialog, one
with a control 2, and an invalid or destroyed handle: nothing is posted (silently; only a dialog closed between the
decision and the post can meet it).  Without the observer (CheckedNoObs) nothing is named.  The Windows graphics never
see the rule (their keys have frame 0, which the DOS adapter does not decide).

## The audit: every dialog loop's and procedure's Escape

Every IsDialogMessage caller and every other message loop of the game (binary; `claude/src/asm`, all
`USER.PeekMessage`, `GetMessage`, `IsDialogMessage` calls).  "Windows" = the original under Windows 3.1 and civ64's
Windows graphics (unchanged by FCE).

| Loop (procedure on the dialog) | Dialogs | Keyboard path | Escape in Windows | DOS's Escape (DOS listing) | DOS graphics |
|---|---|---|---|---|---|
| RunListBoxDialog 1098:1909 (ListDialogSubclassProc 1098:1D56) | 131 Find City, 130 Civilopedia lists | IsDialogMessage only | nothing (IDCANCEL ignored) | typed-name box 0 (O23:0414); index Esc or x (O8:0000) | **FCE**: cancel |
| RunModalDialogLoop 1170:1F84 (ModalDialogSubclassProc 1170:204F) | 140 production (one caller, ChooseCityProduction) | IsDialogMessage only | nothing | menu box -1, production kept (R:1D05:0392, R:0ADE:1468..14E3) | **FCE**: Cancel |
| RunTextEntryDialog 10F0:0066 (NameDialogWndProc 10F0:0266; the loop tests WM_CHAR) | 137 city name | IsDialogMessage, then its own WM_CHAR test | nothing (command 2 ignored) | name box 0, name kept or no city (O23:0565, O23:0096, O20:00EC) | **FCE**: Go Back |
| CustomizeWorldDialog 1108:0243 (CustomizeWorldWndProc 1108:0705, WM_CHAR 1108:0845) | 143 | IsDialogMessage only | the out-of-range write below; the dialog stays | the question again, -1 | D5e's I-custom consumes Escape (F166, F171); not FCE's |
| ShowTextNoteDialog 10E0:03A2 (loop 10E0:0666..06C1, WM_CHAR Enter only) | 135 help notes | IsDialogMessage | nothing | any key leaves | D7 (I-wait); no cancel character exists |
| RunUnitStackDialogLoop 11C0:3644 (UnitStackDialogSubclassProc 11C0:3702, Enter only) | 141 unit stack | IsDialogMessage | nothing | not settled here | D7 (I-stack, OPEN P26) |
| MenuZ 1220:0156 (MenuZSubclassWndProc 1220:1289: Enter 1220:13BC, letters; WM_COMMAND 101/102) | 136/145 (ShowTextDialog), 139 (the title menu), 142 (the leader), 144 (the setup), 149 (the quiz) | IsDialogMessage | nothing | the menu box's -1 (R:1D05:0392) | D5c/D5e setup rows; D6f's O1 Escape row in play; not FCE's |
| PumpArtworkConversionMessages 10B8:06A0 | 666 | IsDialogMessage | - | - | never shown in civ64 (256 colours) |
| RunPediaModalLoop 1068:2728 (PediaDialogSubclassProc 1068:282D, Enter only) | 130 entry page | TranslateMessage: WM_CHAR 1Bh to the focus | nothing | not settled here | D7 (I-pedia, DOS-PROFILE row 11) |
| PumpSpaceshipWindowMessage 1070:1018 (SpaceshipWndProc 1070:10CB: any character -> 1) | the spaceship window | TranslateMessage | closes | - | unchanged (already closes) |
| PumpCityScreenMessage 1030:9AED (CityScreenWndProc 1030:9C17: other characters -> EnqueueKey) | the city screen (148) | TranslateMessage | the city screen's own key handling | - | unchanged |
| RunTextInputDialog 1220:16FD (TextInputSubclassWndProc 1220:1936) | 144's name pages | TranslateMessage | as the game | the DOS name page | D5d's I-text; not FCE's |
| RunRadioMenuDialog 11E0:0A2A | - | - | dead | - | - |
| the key queue: ProcessKeyboardMessage 1098:02D1, PumpOneMessage 1098:062F, WaitForKeyOrClick 1038:0C1D, PeekTranslateDispatchMessage 1140:0000, PumpMessagesCheckSkipInput 11E0:095F, DelayTimerTicks 11E8:02A4 | 129 About, 146/147 discovery, 148 reports | TranslateMessage; WM_CHAR -> EnqueueKey | the screen's own key test (the waits take any key) | - | unchanged |

Templates no code opens (no GR_DialogOpen with their id): 133, 138, 150, 999, 2000.  DlgProc 1098:16E2 (every
dialog's DLGPROC): WM_COMMAND 101 and 102; another id falls into its WM_CHAR code, which tests Enter only; CivDialogProc
1098:1838 (the class procedure): the mouse, then DefDlgProc.  test_pdos_fce checks that no template but 130 (with its
list), 131, 137 and 140 is named (the templates the game opens, and 133 and 138).

## Customize World's Escape (original defect, reproduced; for X9)

Under Windows 3.1, Escape in Customize World (dialog 143) gives WM_COMMAND IDCANCEL (2) (finding 3), which the
dialog's subclass CustomizeWorldWndProc stores as the command (1108:087D).  The loop (1108:0557..0598) ends; 2 is not
OK or Cancel (1108:059A); 1108:05B1 takes it as a region: 2 - 0x320 - 3 = -801, row = -801 / 4 = -200, col = -801 % 4
= -1 (signed IDIV truncates toward zero).  col < 3, so it erases the frame of item (-800 + worldParams[-200] + 0x323)
at its rectangle (GetDItem 1108:05D7) and at 1108:0638 writes -1 to worldParams[-200]: the int16 at 12D8:3764, 400
bytes before worldParams, which is g_advanceSource[2][36] and [37] (both bytes := FFh); then it redraws row -200 (a
yellow frame at a stale rectangle; the dialog stays open).  Each further Escape does the same.  Binary.

civ64 reproduces it in the Windows graphics: the write lands in the emulated DGROUP (12D8:3764 is inside the segment),
the harness reports no out-of-range access or fault (HARNESS_OOB 0, fault_kind 0; `obj/cw`, both a single and a
repeated Escape), the frame is drawn as above and the dialog stays.  Host memory is never at risk (the emulated
segment's bounds hold).  In the DOS graphics D5e's I-custom consumes Escape before the core sees it (DOS asks the
question again; F166, F171), and FCE does not name dialog 143, so this code is not reached there.

The value has no effect on the game (binary): Customize World runs before RunNewGameSetup, whose InitCivilization
for civs 0..7 (10E8:0EBC..0EC8) sets g_advanceSource[civ][0..71] := -1 (10E8:1417..1434), the same value; a loaded game
replaces all 0x240 bytes (SerializeGameData 10F8:0D77); the only readers are ShowPediaEntry's "learned from" lines
(1068, for the human civ, after the game began) and GiveAdvance writes it.  The base prompt's rule (x64-port-prompt.md
line 39): "Keep the original's bugs: this is a faithful port, not a remake."; its fault policy (5.3): "Never let such
an access corrupt host memory."  Followed: reproduced, recorded (below), no behaviour change in FCE.

## What was built

* `platform/w16/user_dlg.c` (LF): `w16_dlg_post_char(hdlg, ch, lparam)` at the end, and a header rule after D5K2's:
  posts WM_CHAR ch for a dialog of the manager (`w16_queue_post_input` with the dialog's hwnd) when it is a top-level
  window, shown and enabled and has no control 2; else 1, nothing posted.  `w16_int.h` (LF): its declaration.
* `platform/w16/host_sync.c` (CRLF): in post_event's HOST_EV_CHAR case a block: a character marked
  `PI_CHAR_TO_DIALOG` goes to `w16_dlg_post_char` with the window in x (a post is logged like the others, the core
  input log's `post` line; a full queue counts as dropped; a refusal posts nothing); three header lines.
* `present/input.h` (CRLF): `#define PI_CHAR_TO_DIALOG 0x0001u` with its comment (HostEvent.buttons of a HOST_EV_CHAR).
* `present/dos/pdos_fce.c`, `pdos_fce.h` (new, LF): `pdos_fce_dialog()`, the dialog by its controls (above), and the
  evidence.  No host event is named there (rule I1).  Since the landing's fix (section "Landing") `pdos_fce.h`
  defines `PDOS_CHAR_TO_DIALOG` 0x0001u, the mark the adapter uses, instead of including input.h (a present/dos
  file may not include it: `gen/dos/registry.py`'s include rule).
* Since the landing's fix: `present/input.c` (CRLF) includes `dos/pdos_fce.h` and checks `PDOS_CHAR_TO_DIALOG ==
  PI_CHAR_TO_DIALOG` (`typedef pi_adapt_dialog_ok`, after `pi_adapt_lost_ok`, as for `PDOS_CH_LOST`);
  `gen/dos/registry.py` (LF) names `pdos_fce.c` among `OBSERVER_FILES` (it reads the emulation through w16q_*
  queries: w16q_active, w16q_desktop, w16q_wnd, w16q_wnd_first, w16q_wnd_next).
* `present/dos/pdos_adapt.c` (CRLF), **the adapter hunk** (two places, nothing else): `#include "pdos_fce.h"` after
  `#include "pdos_common.h"`; in `key_down`, right after `f->frame = ev->frame;` (before the frame test), the block
  between `/* extension FCE (begin)` and `/* extension FCE (end) */` (15 lines; the mark `PDOS_CHAR_TO_DIALOG` since
  the landing's fix).
* Tests: `tests/test_user.c` (LF) `test_fce` (10 checks); `tests/test_pdos_fce.c` (new, LF); `tests/harness/ext_fce.py`
  (new, LF); test.cmd's section `ext_fce` (`BUILD-TEST-ADDITIONS.md`).  build.cmd unchanged (its globs take the new
  sources and the new test).

## Tests

* **test_user** `test_fce` (w16, the real dialog manager with civ.exe's DIALOG 131): Windows 3.1's path: a
  WM_KEYDOWN 1Bh through IsDialogMessage gives WM_COMMAND 2 and no WM_CHAR; `w16_dlg_post_char` posts WM_CHAR 1Bh with
  the dialog's hwnd and lParam 00010001, which IsDialogMessage dispatches to the dialog; refused with a control 2, for
  a disabled or hidden dialog, a control, a top-level window that is no dialog, 0, an invalid handle and a destroyed
  dialog; an inactive shown dialog is posted (the caller chooses).  355 -> 365 checks.
* **test_pdos_fce** (new): the filter stage over the real dialog manager and civ.exe's templates: DIALOG 131 with its
  list focused is named; Escape on frame 2 and on frame 1 gives one marked HOST_EV_CHAR 1Bh (the dialog in x, the
  press's scan, frame 0); its repeats on both frames give nothing; its release gives HOST_EV_KEYUP 1Bh on frame 0;
  Return passes; Ctrl+Escape and Alt+Escape pass as keys; the list hidden, a control 2, the dialog disabled, another
  window active, the dialog destroyed: not named.  DIALOG 130 without a list: no; with RunListBoxDialog's LISTBOX 103:
  named; 140: named; 137 with its EDIT 103 focused: named, Escape marked, release passed; with the EDIT hidden: no;
  every other template the game opens (129, 135, 136, 139, 141..143, 145..149, 151, 666), 133, 138, and 144 with an
  EDIT 450: no (150, 999 and 2000, which no code opens, have controls neither w16 nor the test makes).  Without the
  observer: nothing named, Escape on 131 passes.
* **ext_fce.py** (new, the three-step cycle's test.cmd section `ext_fce`): CAE3540B.SAV loaded, then Find City
  (Ctrl+F), Civilopedia > Military Units, City > Change Production and City > Rename City (scenarios.py p4-city's
  clicks to Rome's city screen), each in the Windows and the DOS graphics; Escape as a real key press in host form
  (`hkey down 1B 01`, `hkey up` 50 ms later: arrival, filter, host_sync).  Windows: the core gets WM_KEYDOWN and
  WM_KEYUP 1Bh only and the dialog is open at the end; DOS: the core gets WM_CHAR 1Bh at the press, then WM_KEYUP 1Bh,
  no WM_KEYDOWN 1Bh, and the dialog closes.  **Fails on the defect** (`tree-harness.exe`: the four DOS runs fail, the
  Windows runs pass) **and passes with the fix** (`fce-harness.exe`: EXT_FCE_OK runs 8).

## Results (private, `build/fce-stage/obj/`)

* **Builds** (`obj/b.cmd`, build.cmd's own flags on the overlay; 2026-10-17): Checked, CheckedNoObs and Release
  BUILD_OK (`obj/b-checked.log`, `b-noobs.log`, `b-release.log`; portable sources checked: 296).  `obj/cc.cmd`
  (c11 and c17 /W4 /WX, the clang C99 parse) on `user_dlg.c`, `host_sync.c`, `pdos_adapt.c`, `pdos_fce.c` and
  `test_pdos_fce.c` in the three variants: CC_OK.  (`test_user.c`'s C99 parse reports the base's own unused
  `edit_r`, line 2007, which build.cmd does not parse: tests are not portable sources.)
* **Unit tests, Checked**: every `test_*.exe` (49, test_ne aside) and `w32_test_*.exe` (5) pass; their PASS lines
  equal the tree's `build/test/Checked/sections/unit.log` except `test_user: PASS (365 checks, 0 failures)` (355) and
  the new `PASS test_pdos_fce: 43 checks, 0 failed`.  Release: test_pdos_fce 43, test_user 365, test_input 449,
  test_pdos_adapt 155.  CheckedNoObs: test_pdos_fce 1, test_user 365, test_input 393, test_pdos_adapt 155.
* **ext_fce.py** (`obj/ext-fce-run2.txt`, `fce-harness.exe`): eight PASS lines, `EXT_FCE_OK runs 8` (8.4 s).  Against
  `tree-harness.exe` (`obj/ext-fce-tree.txt`): the four Windows runs pass, the four DOS runs fail (`EXT_FCE_FAILED=4`:
  WM_KEYDOWN and WM_KEYUP 1Bh reach the core, the dialog stays open): the check catches the defect.
* **Real keys, Ctrl+F** (`obj/hostkeys`, host form for Ctrl+F too): Find City opens in both graphics; Escape: the
  Windows run ends in RunListBoxDialog's loop (1098:1BEE, the dialog open), the DOS run back in play (1098:0645).
* **Static checks** on the overlay: `obs_lint.py`: OBS_LINT_OK files 124 probes 203 callsites 98 (the tree 122: the
  two new files); `pdos_scene_check.py` PASS 1078 checks; `adapters.py check` ADAPT_OK rows 98 steps 22 (both as the
  tree's); `nodos.py check --variant Checked --root obj/src` (with this record and the stage's two notes copied in):
  NODOS_OK, 628 files, 0 hits.  `obs_tables.py --check` and `registry.py check` need the claude/src listing and
  build/dosdata beside the port and do not run in the overlay; FCE changes no probe, call site, DOS-PROFILE.md table or
  DOS file, so their outputs stay as the tree's.
* **Customize World** (`obj/cw`, the tree's harness and FCE's, Escape twice): Windows graphics: no fault,
  HARNESS_OOB 0, the two Escapes reach the core as WM_KEYDOWN and WM_KEYUP, the stray frame drawn, the dialog stays
  (the same steps with both harnesses: 9363786); the DOS graphics: no Escape reaches the core (consumed by I-custom),
  the code not reached (steps 9363526 with both).

## Expected changes at the build slot

Predictions for the cycle (the tree after TLD; "before" = `build/test/Checked` of TLD's cycle, ALL_GREEN 02:05:31 UTC):

* `sections/unit.log` (Checked): `test_user: PASS (365 checks, 0 failures)` (355 before); a new program
  `[test_pdos_fce]` with `PASS test_pdos_fce: 43 checks, 0 failed` (55 program lines, 54 before); every other line
  unchanged (cost lines in host time may vary).
* A new section `ext_fce` and file `ext-fce.txt`: eight PASS lines (findcity, pedia, prod, name; win and dos), then
  `EXT_FCE_OK runs 8`; new run folders `build/run/fce-*` and `build/harness/Checked/fce/*`.
* `obs-lint.txt`: `OBS_LINT_OK files 124 probes 203 callsites 98` (122 before).
* `nodos.txt` and `sections/nodos.log`: six files more (pdos_fce.c, pdos_fce.h, test_pdos_fce.c, ext_fce.py, this
  record, test_pdos_fce.exe), 0 hits, NODOS_OK.
* Every other output unchanged: ext_p0, ext_frames, ext_timeline, ext_continue, ux3_aspect, bs1..bs3, ext_adapt,
  ext_slots, ext_tld, ext_mirror, ext_replay, ext_zoom (its Find City run closes the dialog with a click, its menus'
  Escape is core form), scenarios, p4tests, gate3b, uninit, obs-tables, pdos_scene_check, adapters, registry, trace;
  coverage's informational lines may move (eight more runs); `ext_g1.py check`: EXT_G1_OK runs 77 (amended 1)
  unchanged, no amendment.  Why: FCE acts only on a host-form Escape key-down decided by the DOS adapter while one of
  the four dialogs is active; no other cycle run presses Escape in host form on them (core-form script lines bypass the
  adapter; ext_adapt's and ext_tld's host-form Escapes are on the setup pages, Customize World and the slot screens,
  which FCE does not name; ext_continue's on the Birth).
* Release: BUILD_OK.  test.cmd gains the section of `BUILD-TEST-ADDITIONS.md`; build.cmd unchanged; G-1 unamended.

## Rebase notes

* **D6f** (staged, `build/d6f-stage`; it rebases onto FCE, the orchestrator's order): `pdos_adapt.c` was the only
  common file of the staging; the landing's fix added two small hunks D6f rebases onto: `gen/dos/registry.py`
  (OBSERVER_FILES: D6e's `"pdos_aplay.c"}` becomes `"pdos_aplay.c",`, then a two-line FCE comment and
  `"pdos_fce.c"}`: a D6f entry goes after it) and `present/input.c` (`#include "dos/pdos_fce.h"` after
  `dos/pdos_adapt.h`; a comment and `typedef pi_adapt_dialog_ok` after `pi_adapt_lost_ok`).  FCE's hunk is two
  insertions into the tree's file (base 9da5f0bd...): the include line
  `#include "pdos_fce.h"                  /* extension FCE */` after `#include "pdos_common.h"`, and in `key_down`
  the 15-line block from `/* extension FCE (begin)` to `/* extension FCE (end) */` right after the anchor
  `    f->frame = ev->frame;` and before `    if (ev->frame != PDOS_EVF_N) {` (D6f's own frame branch follows the same
  anchor: keep FCE's block first, then D6f's code).  FCE adds no row, step, action bit or scene to the adapter table,
  so `adapters.py check` and D6f's I-menu rows are unaffected; FCE's block only takes Escape while a core dialog of
  the table above is active, when no DOS menu is open.  `pdos_adapt_tab.c`, `pdos_adapt.h`, harness.c, test_input.c,
  ext_adapt.py, test.cmd and build.cmd: FCE does not touch them, except test.cmd's two insertions (whoever lands
  second applies the other's test.cmd insertions after re-reading the file).
* **A later unit that draws one of these dialogs as a DOS screen with its own Escape row** (D7: the Find City or
  production list as a DOS box) must take that dialog out of `pdos_fce_dialog` or keep FCE's block first: it decides
  Escape before the D4 rows.
* **TLD** (landed; test.cmd's `ext_tld`): the bases were taken after TLD's copy-in; FCE's test.cmd insertions follow
  TLD's block.

## Build-slot steps

1. Base re-check: each tree file equals its `BASE-SHA256.txt` hash.  A changed base (D6f landed first): rebase as in
   "Rebase notes", rebuild privately, re-run test_pdos_fce, test_user and ext_fce.py.
2. Snapshot `build/test/Checked` to `build/fce-prep/before`; copy in the 10 staged source and test files, the staged
   test.cmd (the tree's with `BUILD-TEST-ADDITIONS.md` applied, CRLF; `obj/mk_testcmd.py`) and this record: 12
   files (7 changed, 5 new); `build/fce-prep/landed.sha256`.
3. Predictions (this record's "Expected changes") written before the cycle; build.cmd checked, test.cmd checked,
   `tests/harness/ext_g1.py check`, status in `build/fce-status.txt`; comparison after.
4. Release build (RELEASE_OK); user build `build/user-builds/fce/` (civ64.exe, CIVWIN.zip and civdos.zip from
   `user-builds/d4`, WHAT-TO-CHECK.txt with "Still open" from the checklist's pending rows at landing time).
5. A "Landing" section here.

## What the user checks

Load a game (File, Load; for example your MZTEST.SAV).  Switch the graphics with Ctrl+Shift+Backspace or the system
menu.

* **FCE-1** (Find City, DOS graphics) Open Find City (Ctrl+F) and press Escape: the list closes at once and no city is
  chosen (the map stays where it was), as with Cancel.
* **FCE-2** (Civilopedia, DOS graphics) Open a Civilopedia list (for example Military Units) and press Escape: the list
  closes, as with Exit.  (The entry page you reach from a list is not part of FCE: close it as before.)
* **FCE-3** (production, DOS graphics) Open a city, choose Change Production in the City menu (or press C) and press
  Escape: the list closes and the city keeps what it was building, as with Cancel.
* **FCE-4** (city name, DOS graphics) In the city screen choose Rename City in the City menu (or press R) and press
  Escape: the box closes when you release the key and the name is unchanged.  With Settlers, found a new city (B) and
  press Escape at its name box: the box closes and no city is founded, as with Go Back.
* **FCE-5** (Windows graphics unchanged) FCE-1..FCE-4 in the Windows graphics: Escape does nothing in those dialogs, as
  in the original (close them with Cancel, Exit or Go Back).  Hold Escape for a second in the DOS graphics on Find City:
  it closes once, and the map behind it does not react to the held key.

## For the records

* **DESIGN.md** (the DOS profile's input, area C, beside D4c's filter-stage rules): "Escape on the core's dialogs
  (extension FCE): in the DOS graphics a new Escape press without Alt or Ctrl on Find City (131), a Civilopedia list
  (130 with its list), the production list (140) or the city name (137), recognised by their controls
  (`present/dos/pdos_fce.c`), becomes the dialog's own cancel character: the filter stage emits a host character 1Bh
  marked `PI_CHAR_TO_DIALOG` (input.h; the adapter's `PDOS_CHAR_TO_DIALOG`, pdos_fce.h, checked equal by input.c)
  with the dialog's window, host_sync.c posts it for that dialog
  (`w16_dlg_post_char`, `user_dlg.c`), and the game's WM_CHAR 1Bh handler cancels (ListDialogSubclassProc 1098:1DA8,
  ModalDialogSubclassProc 1170:206F, RunTextEntryDialog's loop 10F0:0196).  The press's repeats are consumed, its
  release passes.  Under Windows 3.1 those handlers are unreachable (IsDialogMessage turns Escape into IDCANCEL, which
  no game dialog has), so the Windows graphics keep the original's: Escape does nothing there."  And in the platform
  section (user_dlg.c): "`w16_dlg_post_char` (extension FCE): WM_CHAR for a shown, enabled top-level dialog of the
  manager without a control 2, posted as input with the dialog's hwnd; the DOS adapter's only caller."
* **FIDELITY.md**, two entries (the orchestrator numbers them):
  * in the D6 section (or a new section "Extension FCE"): | F? | Escape on the core's list, modal and name dialogs in
    the DOS graphics (`present/dos/pdos_fce.c`, `pdos_adapt.c` key_down's FCE block, `platform/w16/user_dlg.c`
    `w16_dlg_post_char`, `host_sync.c`) | The original under Windows 3.1 ignores Escape in Find City (131), the
    Civilopedia lists (130), the production list (140) and the city name (137): their loops call IsDialogMessage only
    (1098:1BEE..1C1A, 1170:1FDA..200A, 10F0:014B..020D), which turns Escape into WM_COMMAND IDCANCEL (2), which no game
    dialog has, so the game's own WM_CHAR 1Bh cancel handlers (1098:1DA8, 1170:206F, 10F0:0196) are unreachable
    (platform, Q10/F29; binary).  The DOS screens leave with Escape: Find City's name box (O23:0414, 0), the
    Civilopedia index (O8:0000, Esc or x), the production menu box (R:1D05:0392, -1: the production kept,
    R:0ADE:1468..14E3), the city name box (O23:0565: 0, the name kept or no city) (DOS listing) | In the DOS graphics
    Escape (without Alt or Ctrl) on those dialogs posts WM_CHAR 1Bh to the dialog itself, so the game's handler does
    Cancel, Exit or Go Back; its repeats are consumed, its release passes; the city name box closes at the release
    (its loop acts at the next message).  The Windows graphics unchanged (faithful).  DOS asks for a city name again
    when the text is empty, also after Escape; here Escape is Go Back, which ends the box (**DOS-profile adapter
    rule**, the user's rule of 2026-10-16 "where DOS has a key for it (e.g. Escape), that key does it", the
    orchestrator's ruling on FCE (b), 2026-10-17).  Status: implemented in FCE; tests `test_user` `test_fce` (355 ->
    365), `test_pdos_fce`, `ext_fce.py` (EXT_FCE_OK runs 8); user checks FCE-1..FCE-5 pending (build
    `build/user-builds/fce/`) | `ext-FCE-record.md`; Q10; F29; F166 |
  * in "Faults and out-of-range accesses": | F? | CustomizeWorldDialog 1108:05B1..0638 (Escape in the Windows
    graphics) | Escape gives IDCANCEL (2), which the dialog's subclass stores as the command (1108:087D); 1108:05B1
    takes it as region -801: row -200, col -1, and 1108:0638 writes -1 to worldParams[-200], the int16 at 12D8:3764
    (g_advanceSource[2][36..37]), after erasing and redrawing a frame at a stale rectangle; the dialog stays (binary) |
    Reproduced: the write lands in the emulated DGROUP inside the segment (no out-of-range access, no fault; host
    memory untouched); the stray frame is drawn.  No effect on the game: RunNewGameSetup's InitCivilization sets
    g_advanceSource to -1 for every civ (10E8:1417..1434) after Customize World, and a load replaces it
    (SerializeGameData 10F8:0D77).  In the DOS graphics D5e's I-custom consumes Escape (F166, F171), so the code is
    not reached there.  Open item for X9: confirm the write's target and its harmlessness in the final audit (the
    original's defect, kept: "Keep the original's bugs") | `ext-FCE-record.md`; EXT-HANDOFF (FCE's X9 side finding) |
* **RUNNING.md**: the unit tests' list: `test_pdos_fce` (extension FCE; 43 checks in Checked and Release, 1 in
  `checked noobs`) and `test_user` 365; the test.cmd sections: `ext_fce` (Checked: `ext_fce.py`, eight harness runs,
  `EXT_FCE_OK runs 8`, about 8 to 30 s); the number of test programs (one more, 55); the sections 28 -> 29
  (TEST_SECTIONS 29); portable sources 295 -> 296 (`present/dos/pdos_fce.c`).
* **FEATURES.md** (the DOS section): "Escape closes Find City, the Civilopedia lists, the production list and the city
  name box in the DOS graphics, as the DOS game's screens do (FCE)".
* **manual-checklist-ext.md**: a new section FCE with FCE-1..FCE-5 (above, in the user's words), build
  `build/user-builds/fce/`; the pending counts.  P47-2's text says "Enter and Escape still work and the dialog closes"
  (passed 2026-10-15): in the Windows graphics Escape never closed Find City (the original's behaviour, finding 6);
  only Cancel or Enter did.  A wording note for the docs pass, not a new check.
* **STATUS.md**: unit FCE READY (staged 2026-10-17), then landed by the build slot: Escape on the core's list, modal
  and name dialogs in the DOS graphics (a DOS-profile adapter rule; outcome (b), the Windows graphics faithful); the
  base-track observation of MZS ("Escape does not close Find City" in the harness; `p49-findcity`'s comment) is
  answered: the original ignores Escape there; the comment in `p49-findcity` ("Escape closes it") and ext_zoom.py's
  MZS note are about the Windows graphics, where it does not (a comment fix for the docs pass); open item for X9: the
  Customize World write (above).
* **DOS-PROFILE.md**: no change needed (no new call address; prose only if the docs pass wants a note at rows 12 and
  15: "Escape: FCE").

## Landing (2026-10-17, build slot)

**Copy-in 2026-10-17 02:32:11 UTC; the first cycle failed at d2_registry (02:59:21 UTC); the fix copied in 03:02:26
UTC; cycle -r2 ALL_GREEN 03:41:10 UTC; RELEASE_OK 03:45:49 UTC; user build `build/user-builds/fce/` (03:46 UTC).**
Done by the build slot on the orchestrator's instruction, after TLD's landing (ALL_GREEN 02:05:31 UTC, RELEASE_OK
02:09:36 UTC) and the docs pass for D6e and TLD (`build/docs-tld-done.txt`, 02:28:30 UTC; waited for in a bounded
one-minute loop).

1. **Bases** (02:29:48 UTC): the 7 tree files of `build/fce-stage/BASE-SHA256.txt` still had their hashes, test.cmd
   (8b70bbf7..., TLD's) among them, so the staged test.cmd (the tree's with `BUILD-TEST-ADDITIONS.md` applied,
   `obj/mk_testcmd.py`, 77c7bb11...) needed no re-apply; the 5 new files were absent; build.cmd (40de571d...)
   unchanged.  `build/fce-prep/land.py --freeze` (`staged.sha256`, 12 files), dry run `DRY_RUN_OK 12`.
2. **Predictions** (`build/fce-prep/predictions.txt`, written 02:31:39 UTC, before the copy-in) on TLD's cycle:
   portable sources 295 -> 296, TEST_SECTIONS 28 -> 29, test_user 355 -> 365, test_pdos_fce 43, `EXT_FCE_OK runs 8`,
   OBS_LINT_OK files 122 -> 124, nodos 1744 -> 1750, every other output unchanged, EXT_G1_OK runs 77 unchanged.
3. **Snapshot and copy** (02:32:11 UTC): the tree's Checked test outputs (61 files of `build/test/Checked`, TLD's
   cycle) in `build/fce-prep/before`, the tree's previous 7 files in `build/fce-prep/tree-before`; the 12 files byte
   for byte (7 changed, 5 new): `LANDED 12`; manifest `landed.sha256` (kept as `landed-r1.sha256`), `landed-at.txt`.
4. **The first cycle** (`build/fce-prep/fce-cycle.ps1`, from TLD's; status `build/fce-status.txt` lines 1..3, logs
   `build/fce-1-build-checked.log`, `fce-2-test-checked.log`):
   - 1 build-checked: exit 0, 189 s, BUILD_OK, portable sources checked 296, no warning.
   - 2 test-checked: exit 1, 1406 s, `TESTS_FAILED=1`: `TEST_SECTIONS 29 ... failed 1: d2_registry(1)`; `STOPPED at
     step 2`.  registry.py's include rule of present/dos (`registry-check.txt`):
     `FAIL include rule pdos_fce.c: 10 "w16_obs.h"` and `FAIL include rule pdos_fce.h: 56 "input.h"`.
     **Cause**: pdos_fce.c reads the emulation through w16q_* queries (w16_obs.h) but was not among registry.py's
     `OBSERVER_FILES`, and pdos_fce.h included input.h, which no present/dos file may include.  The staging overlay
     could not run `registry.py check` (it needs the claude/src listing and build/dosdata beside the port; "Results"
     above), so staging did not see it.  Every other section passed (EXT_FCE_OK runs 8, test_pdos_fce 43, test_user
     365, w32_test_host_win32 at the first run, OBS_LINT_OK files 124, nodos 1750 files 0 hits; the other outputs
     as predicted), except one unpredicted, informational difference: test_pdos_fce prints w16's dialog trace into
     `sections/unit.log` (below).  Its outputs: `build/fce-prep/compare-run1.txt`, `unit-r1.log`, `run1/`.
5. **The fix** (the orchestrator approved it, 2026-10-17): pdos_fce.h defines `PDOS_CHAR_TO_DIALOG 0x0001u` instead
   of including input.h; the adapter hunk uses it (same 15 lines, its comment rewrapped); `present/input.c` checks it
   equals `PI_CHAR_TO_DIALOG` (one include, one typedef, as for `PDOS_CH_LOST`); `gen/dos/registry.py` names
   `pdos_fce.c` among `OBSERVER_FILES` (the D5b..D6e pattern).  Staged (`obj/fix_registry_rule.py`; input.c's and
   registry.py's tree hashes 72f2a0dd... and 079e7296... added to `BASE-SHA256.txt`), then copied in by
   `build/fce-prep/land_fix.py` (03:02:26 UTC, `FIX_LANDED 14`; the previous four files in `tree-before-fix`):
   the new manifest `landed.sha256` holds all 14 files (pdos_adapt.c 5e331ac8..., pdos_fce.h b9a4053e..., input.c
   5a863747..., registry.py c70ad3d2...) and build.cmd's unchanged hash; `staged-r2.sha256`, `landed-fix-at.txt`.
   On the tree then: `registry.py gen` "pdos_registry: 159 files, 44 tables (unchanged)" (pdos_registry.h/.c
   byte-equal); `registry.py check` REGISTRY_OK, 0 failures (`ok include rule pdos_fce.c`, `ok include rule
   pdos_fce.h`); `obs_lint.py` OBS_LINT_OK files 124 probes 203 callsites 98.  Predictions for the rerun appended
   to `predictions.txt` before it (03:03 UTC): the two registry lines, the w16 trace lines in unit.log.
6. **The cycle -r2** (status lines 4..7 and 8..9, logs `build/fce-<n>-<step>-r2.log`):
   - 1 build-checked: exit 0, 292 s, BUILD_OK, portable sources checked 296, no warning.
   - 2 test-checked: exit 0, 1969 s, TESTS_OK, `TEST_SECTIONS 29 parallel, budget 20, wall 1966.3 s, failed 0`
     (ext_fce 17.6 s).  `w32_test_host_win32` passed at the first run: no GetKeyState rerun and no -r2 test step
     for the flake were needed.
   - 3 g1-checked: exit 0, `EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)`: **ALL_GREEN** 03:41:10 UTC.
     No G-1 amendment.
   - 4 build-release: exit 0, 268 s, BUILD_OK, portable sources checked 296, no warning: **RELEASE_OK** 03:45:49 UTC.
7. **Comparison** (`build/fce-prep/compare.py`, output `compare.txt`): 53 of 63 files equal (61 before, 2 new; lines
   with times left out).  The differences:
   - `ext-fce.txt` and `sections/ext_fce.log` (new): eight PASS lines (findcity, pedia, prod, name; win: posts
     0100 and 0101, the dialog shown at the end; dos: posts 0102 and 0101, the dialog closed), `EXT_FCE_OK runs 8`.
   - `sections/unit.log`: `test_user: PASS (365 checks, 0 failures)` (355); the new program `[test_pdos_fce]`
     (68 lines: the system font line, 65 lines of w16's dialog trace, `w16: CreateDialog <id> CIVDIALOG <n>` and
     `w16: activate ...` for templates 131, 130, 140, 137, 129, 133, 135, 136, 138, 139, 141..143, 145..149, 151, 666
     and 144, then `PASS test_pdos_fce: 43 checks, 0 failed`); test_user's seven more trace lines; host-time lines.
     The same lines as the first cycle's (`unit-r1.log`) apart from host times.  The trace lines were not
     predicted at first: w16 prints them for every dialog a test creates, as for test_user's dialogs before.
   - `registry-check.txt`: `ok include rule pdos_fce.c`, `ok include rule pdos_fce.h`; REGISTRY_OK.
   - `obs-lint.txt` and `sections/d3a_obs_lint.log`: OBS_LINT_OK files 122 -> 124 probes 203 callsites 98.
   - `nodos.txt`: 1744 -> 1750 files, 0 hits, NODOS_OK.
   - `coverage.txt` and `sections/coverage.log`: "other functions entered" 668 -> 666 (informational; the first
     cycle had 668).  Not FCE's: `build/x64/Checked/coverage-civ_harness.txt` gets torn lines from concurrent
     appends of the parallel harness runs (this cycle: 4 malformed keys, such as `11E0:01110:1767` and `368`), which
     coverage.py counts as functions, so the count moves from run to run.  A note for the docs pass (coverage.py or
     host_coverage), not changed here.
   - `sections/times.txt`: section times and the new `ext_fce` line.

   Every other output equal: EXT_ADAPT_OK checks 154, ZOOM_OK (`combinations 32 runs 108 samples 628 map
   comparisons 32 centre runs 4 mzi runs 12 mzs runs 4 not zoomed 38/448`, every golden sample equal), MIRROR_TOTAL
   checks 21712 present 13386 present_mismatched 0, P0_OK checks 476, REPLAY_OK checks 70, EXT_TLD_OK,
   EXT_SLOTS_OK, EXT_FRAMES_OK, EXT_TIMELINE_OK, EXT_CONTINUE_OK, EXT_ASPECT_OK, EXT_BS_OK, P4_TESTS_OK,
   P4_SCENARIOS_OK, GATE3B_OK, UNINIT_OK, OBS_TABLES_OK probes 203 sites 98, ADAPT_OK rows 98 steps 22,
   pdos_scene_check PASS 1078, TRACE_OK.  No golden changed.
8. **User build** `build/user-builds/fce/` (`build/fce-prep/mk_userbuild.py`, `USER_BUILD_OK 4`): `civ64.exe` (the
   Release build, SHA-256 7c0f2331...c5a1766b, 4,370,432 bytes), `CIVWIN.zip` and `civdos.zip` (byte-identical copies
   from `user-builds/d4`, SHA-256 058d4e00... and 0eac32c9... checked) and `WHAT-TO-CHECK.txt` (SHA-256
   4009a51d..., CRLF, ASCII): FCE-1..FCE-5 as in "What the user checks", saying plainly that the Windows graphics
   are unchanged (as the original under Windows 3.1), the city name's empty-text difference (recorded deviation:
   DOS asks again, Go Back does not) and Customize World's stray frame in the Windows graphics (the original's,
   harmless); the builds it contains (tld, d6e, mzs, si, mzi, ux5, mzw, mz, ux4b, d5p, ux4, d6d, sl and the earlier
   ones); the note that it runs only once at a time (SI); and the items still open from the checklist's pending rows
   at 03:45 UTC (`build/fce-prep/fill_stillopen.py`, the checklist read only): TLD-1..TLD-7, D6e-1..D6e-7,
   MZS-1..MZS-6 and MZW-8, SI-1..SI-6, MZI-1..MZI-7, UX5-1..UX5-7, D5P-7 and P47-1 checkable (43); D6-1 and D5-7
   with unit D6f.
9. **Not done here**: the checklist's FCE section, the FIDELITY entries' numbers and the other entries of "For the
   records" (the orchestrator and the next docs pass).  The stage `build/fce-stage` equals the tree for the 14
   files; this record differs from its staged copy by the landing's edits.

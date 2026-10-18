# Phase 7: bring-up in civ64 windows and oracle comparisons

Agent checks under the UI and oracle grants (prompt 2.1). Nothing here is user acceptance: the
user's visual confirmation is pending (`phase-7-acceptance.md`). Oracle results are labelled
"original under OTVDM on Windows 11"; they are not Windows 3.1 evidence.

## 1. civ64 runs (`tests/win32/drive_civ64.py`)

Method. Each run replays one headless scenario (`tests/harness/scenarios.py`) into a visible
civ64.exe window (Release, `--scale 1 --timing classic --dump-frames`), on a copy of
`build/gamedata` without the `.wav` files (silent), with the scenario's edited save seeded. Input
goes only to civ64's own window and its own file dialog (posted messages; the file name is sent to
the dialog's edit control with WM_SETTEXT). Differences from the headless input, by design:

* the script clock starts at civ64's first title-menu frame (the headless frame time 21,219 ms),
  and the title option is chosen with the mouse (a click on the option, then on OK);
* a character the headless script posted to window 0 is posted as WM_CHAR (both go to the focus
  window); a character it addressed to a window (the active one, a dialog) is pressed as the key a
  player would press (key down, the host's character, key up), because civ64 has no other way to
  address an emulated window; characters that need Shift stay WM_CHAR;
* civ64's clock follows the real clock where the game waits (classic timing), so animation phases
  (palette cycling) differ by a few frames.

Every present is hashed as the harness hashes it (indexes, then the 768-byte palette) and compared
with the first stable frame of each row the scenario reaches (`build/harness/features.txt`). A
differing row gets civ64's present at the same script time beside the headless frame
(`build/frames/c7-NAME/differs.png`) with its pixel and palette differences.

Results: section 3.

## 2. Oracle runs (`tests/win32/oracle_civ.py`)

Each run uses a copy made by `scripts/Prepare-OriginalOracle.ps1 -Label port-<topic>` (the `.wav`
files removed from the copy so that it is silent), starts only that copy's civ.exe through the
manifest's launcher (`tools/otvdm-v0.9.0/otvdmw.exe`) with the copy's folder as working
directory, posts input only to the run's windows (the focus window from GetGUIThreadInfo; the file
dialog's edit by WM_SETTEXT, then OK; a menu command as WM_COMMAND to the game's main window, which
is what choosing the item sends), captures only those windows (PrintWindow) and ends the
launcher's process tree. Outputs: `build/oracle/<label>/`.

| Run | Steps | Result (original under OTVDM on Windows 11) | Port |
|---|---|---|---|
| port-title (2026-10-10 13:2x) | at the title menu: focus query, Down, Down, 'l' | Focus on OK throughout; Down moved the highlight Start → Load → Play on EARTH; 'l' selected Load a Saved Game | Before F86 civ64 sent a key to IsDialogMessage about half the time (Down moved the focus off OK, letters did nothing). After F86: Down, Down, 'l', Enter opened Load in 2 of 2 runs (FIDELITY F86) |
| port-save (13:47) | 'l', Enter at the title; Open: CAE3540B.SAV; File > Save Game (WM_COMMAND 101); Save As: SAVE1.SAV | SAVE1.SAV, 14,281 bytes, SHA-256 6b38a6740c05d4c59c308135038c56d74dba9ea5521315c7d914305f4b77eb31 (`build/oracle/port-save/SAVE1-original.SAV`) | Headless p4-load's SAVE1.SAV (load, then Ctrl+S at once) has the same SHA-256: **byte-identical** (oracle-compared; no random draw lies between the load and the save) |
| port-pedia (14:0x) | load CAE3540B.SAV; Civilopedia > Complete (WM_COMMAND 601); Escape; Enter; Enter; Escape | The list's focus is its list box; Escape left the list open; Enter showed Advanced Flight page 1; Enter showed page 2 (Requires / Allows), which stayed; Escape on page 2 did nothing | civ64: Escape likewise leaves the list open (IsDialogMessage turns it into IDCANCEL, which ListDialogSubclassProc 1098:1D56 ignores; only WM_CHAR 27 or Exit, id 102, closes). The page-1 Enter showed page 2 and closed it at once (findings 6.5, RunPediaModalLoop 1068:27AB; FIDELITY F87) |
| port-port2 (14:4x) | 'l', Enter; Open: PORT2.SAV (the port's p4-load SAVE2.SAV, written after turns 23..25, copied into the oracle copy); File > Save Game; Save As: ORIG2.SAV | The original loaded the port's save (the map and the Save As dialog followed); ORIG2.SAV 14,299 bytes, SHA-256 aaa142a7fc6e70b5cf4b631873fa8490cf154d917a45c89c8db849393f1cd76e (`build/oracle/port-port2/`). A load and save does not reproduce its input (PORT2.SAV is 14,301 bytes; the original's own CAE3540B.SAV, 14,283 bytes, came back as 14,281) | civ64 (run c7-t-port2) loaded the same PORT2.SAV and saved at once: RESAVE2.SAV has the same SHA-256: **byte-identical** (oracle-compared) |

Note on RV4 P47-R2 (the list dialogs' snapshot over the list's scroll bars). In the port-pedia capture (`build/oracle/port-pedia/p0-list-0.png`) the original's Civilopedia list shows its horizontal scroll bar under 13 rows; in civ64 (run c7-menus-c64, frame 986) the list shows 15 rows and a gray strip where the bar would be. OTVDM builds the dialog as a host window with the host's fonts and paint order (the dialog is 518x326 there), so this is not Windows 3.1 evidence; the question stays with the user's check (`phase-7-acceptance.md`) and is not changed.

Notes. Under OTVDM the title menu appears about 27 s after the launch, and a key in roughly the
first second after it still ends the intro (the menu is built again), as the user described for
the original; the oracle steps therefore wait for the title window and four seconds more.

## 3. Scenario results

Batch 2026-10-10 14:01..14:26 UTC (Release; scratch `p7/allrun.sh`), then c7-menus-c64 and c7-start (14:31..14:36). Per run: rows matched byte for byte / rows differing (`build/frames/c7-NAME/result.txt`).

| Run | Equal | Differ | Notes |
|---|---|---|---|
| c7-start | 5 | 0 | intro, title menu (after F85), sound call |
| c7-load | 7 | 0 | SAVE1.SAV equal to p4-load's and to the original's (6b38a674…); SAVE2.SAV (after AI turns) differs: the seed |
| c7-birth | 3 | 0 | the Birth sequence to its end, dialog 144 at 198 s |
| c7-new | 0 | 4 | the same screens with another world and other starting advances (seen) |
| c7-fame-quit | 2 | 0 | civ64 exited with code 0 |
| c7-earth, c7-custom, c7-orders, c7-research, c7-research2, c7-pollution, c7-unload | 1, 2, 7, 1, 1, 1, 1 | 0, 0, 0, 1, 0, 0, 0 | |
| c7-revolution, c7-quiz, c7-spaceship | 0 | 2, 1, 2 | newspaper and quiz frames differ (not viewed) |
| c7-retire, c7-conquest | 1, 1 | 1, 1 | civ64 exited with code 32 (the end-game quit) |
| c7-settlers | 0 | 7 | a new game: another world (not viewed) |
| c7-city | 1 | 10 | mostly animation phase |
| c7-menus | 19 | 24 | stopped in the Civilopedia list (a player's Escape; section 2) |
| c7-menus-c64 | 22 | 21 | Civilopedia closed with Exit: all rows reached; 17 differ only by phase, 5 by the map's scroll position (seen) |

Rows over all runs except c7-menus, which c7-menus-c64 superseded (best result per row; FEATURES.md statuses; phase 8: cmd.503 is equal in c7-menus, and cmd.801's status became "not re-run" after the Help message box changed its headless frame, so 8 rows are now "cause seen" and 10 not viewed): 106 compared, 56 equal, 32 the same screen in another animation phase (at most 16 pixels: a 2x2 blinking marker on the world-map window, and the palette-cycling entries), 9 differing for a cause seen on a contact sheet, 9 reached but not viewed. Not run in civ64: p4-display16 (the harness's 16-colour test switch), and fame-reload/arrival reach no row first.

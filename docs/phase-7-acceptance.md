# Phase 7 acceptance record

Phase 7 (prompt section 9): bring-up from intro to end game, every menu command and opened
dialog (UI grant), plus oracle comparisons (oracle grant). Gate: "`FEATURES.md` statuses recorded
honestly; `FIDELITY.md` complete; user confirmation listed as pending until given."

**State, 2026-10-10 15:05 UTC: the gate items are met; the user's
visual confirmation is pending and has been asked for.** Method and every run:
[verify/phase7-bringup.md](verify/phase7-bringup.md).

| Gate item | Method | Result |
|---|---|---|
| Bring-up in civ64 windows (UI grant) | `tests/win32/drive_civ64.py`: 21 runs of the p4 scenarios in visible civ64.exe windows (Release, scale 1, classic timing, silent data copies, input only to civ64's own window and file dialog), every present hashed as the harness hashes it and compared with the headless first stable frames | Intro, title menu, all six title branches, the Birth sequence to its end, new game, load, every MENU 128 command and accelerator the scenarios use, 18 of the 19 dialogs (666 needs the harness's 16-colour switch), advisors, Civilopedia, city screen and view, diplomacy, newspaper, spaceship, replay, palace, Hall of Fame, the end games (civ64 exited with codes 0 and 32 where the game quits). 106 FEATURES rows compared: 56 frames byte-equal, 32 the same screen in another animation phase, 9 differing for a cause seen on a contact sheet (another world: civ64's seed is the start time; the map scrolled elsewhere), 9 reached but not viewed |
| Oracle comparisons (oracle grant) | `tests/win32/oracle_civ.py`, copies from `Prepare-OriginalOracle.ps1` (port-title, port-save; the `.wav` files removed from the copies), launcher OTVDM; original under OTVDM on Windows 11 | Files, byte for byte: load CAE3540B.SAV and save at once (SAVE1.SAV, 6b38a674…, equal in the original, the headless port and civ64); load the port's mid-game save and save at once (ORIG2.SAV equals civ64's RESAVE2.SAV, aaa142a7…; the original loads a port save; the port loads original saves: CAE3540B.SAV throughout). Behaviour: title-menu keys (led to F86), Civilopedia keys (Escape does not close the list in either program; F87 page 2). No appearance is claimed: OTVDM draws dialog text with the host's fonts. Prompt 4 item 5's "files written after a synchronized scenario" is met only for load-then-save at once: no turns were played in step and no original-written `famehall.civ`, `civ.prf` or `.rep` was compared (audit B9; open item) |
| Fix found by the bring-up | F86 (`platform/w16/queue.c`, `host_sync.c`): which poll takes a key in Win32 mode | civ64's title menu and MenuZ menus take keys as the original under OTVDM; Win32-headless test 101 checks |
| `FEATURES.md` statuses | regenerated from `build/harness/features.txt` (current hashes, after F85) with the civ64 results (scratch `p7/features_md7.py`, `p7/c7status.py`) | each row: "agent-observed: civ64 run …" (equal frame, same screen in another phase, or the cause seen) or "reached in civ64 …, not viewed", then its headless status; "looks the same" is claimed for no row (no row is oracle-compared for appearance or user-confirmed) |
| `FIDELITY.md` complete | entries F1..F87; new: F86 (input rule), F87 (Civilopedia page 2, CPU-speed dependent); categories of prompt 4 item 9 present (timing, window and pixel model, fonts, help, handles, class (b) sites, CPU-speed-dependent draws, faults) | met as stated then; the phase-8 audit found the fonts entry missing and timing, fault-site and open-question coverage thin (audit B12..B16), added as F88..F95 |
| User confirmation | asked in chat (EV-080), 2026-10-10 about 15:10 UTC, with a data copy for the check (`build/userdata`) and the open question RV4 P47-R2 (FIDELITY F80: does the Civilopedia and Find City list show its scroll bar when the dialog opens? civ64 shows a gray strip; the original under OTVDM shows the bar, see `verify/phase7-bringup.md` section 2) | **passed** (the user, 2026-10-11 about 08:00 UTC: "Visual confirmation of civ64 (base track) passed"). P47-R2 decided by the user: the bar is shown when the dialog opens if and only if the list holds more items than fit on one page; the fix is queued (`STATUS.md`) |
| Builds and tests after F86 | `build.cmd` and `test.cmd` in Release (13:37..13:41 UTC; the final 15:04 Release build of the same sources was not tested again, audit A2), Checked and Asan (14:4x..15:04 UTC); all superseded by the phase-8 builds and tests (`phase-8-acceptance.md`) | BUILD_OK and TESTS_OK in all three; `test_host_win32` 101 checks; Checked: GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK, P4_TESTS_OK, TRACE_OK; Asan: P4_SCENARIOS_OK, P4_TESTS_OK, TRACE_OK, no AddressSanitizer report |

## Labels (prompt section 10)

* **Compiled:** civ64.exe (Release, Checked, Asan) with F86.
* **Headless-tested / Win32-headless:** the suites; `test_host_win32` 101 checks (F86 included).
* **Agent-observed:** the civ64 runs above (frames, contact sheets); civ64 exit codes; the agent
  viewed the contact sheets named in `verify/phase7-bringup.md`.
* **Oracle-compared:** SAVE1.SAV (load, save) and the re-save of a port save, byte-identical;
  title-menu and Civilopedia key behaviour (original under OTVDM on Windows 11).
* **User-confirmed:** civ64's visual check passed (the user, 2026-10-11 about 08:00 UTC); before
  that, none.
* **Unverified:** appearance against the original (no pixel comparison: OTVDM's fonts differ);
  the 9 rows reached but not viewed; sound output; DPI changes; a long game under both timings;
  same-seed behaviour (civ64 seeds from the start time; nothing rand-dependent was compared).

# civ64: final report

**Outcome (2026-10-10): delivered with open items.** `claude/port/build/x64/Release/civ64.exe`
is a native Windows x64 port of the pinned Win16 `CIV.EXE` (SHA-256 a66ec640…1788), translated
from the recovered C (`claude/src`) with a Win16 emulation layer (`platform/w16`) and a Win32
back end. It runs the whole game from the intro to the end games on the user's own data files
(`RUNNING.md`). It is not "done" in the sense of prompt section 4: the items below that are not
fully met are listed in section 3. The user's visual confirmation of civ64 passed on
2026-10-11 (section 3, item 1).

Each claim is labelled by its method (prompt section 10): **compiled**, **headless-tested**
(the headless harness or Win32-headless tests), **agent-observed** (frames or windows the agent
looked at), **oracle-compared** (the original under OTVDM on Windows 11, not Windows 3.1),
**user-confirmed**, **unverified**. A passing build is not a passing game; tests derived from the
recovered C are "model (self-consistency)"; no same-seed equality with the original is claimed.

## 1. Phases

| Phase | Gate record | Gate met (UTC) |
|---|---|---|
| 0 inventories | [phase-0-acceptance.md](phase-0-acceptance.md) | 2026-10-08 |
| 1 design, generators, NE loader | [phase-1-acceptance.md](phase-1-acceptance.md), [phase-1-review.md](phase-1-review.md) | 2026-10-08 |
| 2 `rt`, `w16` skeleton, harness | [phase-2-acceptance.md](phase-2-acceptance.md) | 2026-10-08 17:28 |
| 3a start-up and world | [phase-3a-acceptance.md](phase-3a-acceptance.md) | 2026-10-09 01:51 |
| 3b load/save, new game | [phase-3b-acceptance.md](phase-3b-acceptance.md) | 2026-10-09 15:35 |
| 3c all units | [phase-3c-acceptance.md](phase-3c-acceptance.md) | 2026-10-09 15:35 |
| 4 portable `w16`, every feature headless | [phase-4-acceptance.md](phase-4-acceptance.md) | 2026-10-10 08:55 |
| 5 Win32 back end | [phase-5-acceptance.md](phase-5-acceptance.md) | 2026-10-10 11:45 |
| 6 `civ64.exe` | [phase-6-acceptance.md](phase-6-acceptance.md) | 2026-10-10 12:25 |
| 7 bring-up and oracle runs | [phase-7-acceptance.md](phase-7-acceptance.md) | 2026-10-10 15:06 (user confirmation pending) |
| 8 final audit | [phase-8-acceptance.md](phase-8-acceptance.md) | 2026-10-10: delivered with open items |

## 2. Section 4 items

Verdicts after phase 8's independent adversarial audits (`verify/phase8-audit-A.md`, `-B.md`,
`-C.md`) and the fixes recorded in `phase-8-acceptance.md`.

| Item | Verdict | Evidence and method |
|---|---|---|
| 1 Build | met, with a caveat | `build.cmd`: MSVC x64 Release `/MT`, `/W4 /WX`, one recorded `/wd` (4702), linker `/WX`; the three language checks (c11, c17, c99 parse) over 226 portable files of `core`, `rt`, `platform/w16` (**compiled**). Caveat: the strength of the clang c99 parse (header warnings, MS extensions) was not re-examined (audit A3) |
| 2 Assets | met | `civ64_open_data` checks size and SHA-256 of the data directory's `civ.exe`, refuses `original\CIVWIN` by name and, since phase 8, by the directory's final path (links, substituted drives); the exe imports only KERNEL32, USER32, GDI32, WINMM, SHELL32 and contains no original bytes (auditor A's byte scan against the 38 data files) (**Win32-headless**, static) |
| 3 Features | met, with caveats | `FEATURES.md`: 108 rows (MENU 128 and ACCELERATOR 128, the 19 dialogs, title branches, intro and Birth, windows, advisors, Civilopedia, diplomacy, newspaper, spaceship, replay, palace, Hall of Fame, end games, palette cycling, sound), each with its scenario, first-stable-frame hash and status: 108 of 108 reached **headless**; civ64 runs: 56 frames byte-equal, 32 the same screen in another animation phase, 8 different for a cause the agent saw, 10 reached but not viewed or not re-run (**agent-observed**); "looks the same" is claimed for no row. Caveats: 22 of 24 accelerators were never pressed as keys (their commands were chosen through the menus); sound output was never heard (silent copies) |
| 4 Rules | met (model, self-consistency) | `gate3b.py` (in `test.cmd`, Checked and Asan): 24 checkpoint snapshots (after load, before each save, each turn, after world generation, after setup) equal the recorded reference `gate3b-golden.txt`, and S2 and S3 repeated give byte-identical snapshots; the worldsim vectors 3428805747 (5996 draws) and 3527905266 (5555) are reproduced and equal `worldsim.py` (the third, 3320891781, is labelled model-only). The reference is the port's own run, not the original; the mask's handle part is open but no comparison needs it (**headless-tested**) |
| 5 Files | met, with caveats | `CAE3540B.SAV` loads and plays on; saves are `RLLEncode(SerializeGameData image)` with the stale tail (S2b); `famehall.civ`, `civ.prf`, `.rep` layouts (**headless-tested**). **Oracle-compared**: the original's load-and-save of CAE3540B.SAV equals the port's byte for byte; the original loads a port save, and its re-save equals civ64's re-save of the same file byte for byte. Caveats: no turns were played in step with the original; no original-written `famehall.civ`, `civ.prf` or `.rep` was compared; no stale-tail test for famehall or replay files |
| 6 Original bugs | met, with caveats | 93 of the 94 reachable G, C and R findings have a cited statement executed (`findcov.py`); effects are asserted for 14 (G2, G6, G10, G12, G13, G16, G19, G31, G33, G44, G53, C1, C2, C6); the rest rest on the verified translation; R5 (a private drawing generator) is uncited; faults follow 5.3 and are registered (F10, F33, F91, F92) (**headless-tested**, static) |
| 7 No undefined behaviour | **partly met** | All tests pass in the checked "image bounds" build with every out-of-range record allowlisted and no emulated stack overflow (lowest SP 0xCB08, 5,706 bytes of margin, auditor C); the ASan builds of the tests are clean (**headless-tested**). Open: no record shows that the phase-3 verifier checked every 32-bit arithmetic site (audit C10) |
| 8 Traceability | met | `TRACE.md`: 1,065 functions, the same set as `functions.json` (699 ported with `SSSS:OOOO  Name` headers, 155 replaced by `rt`/`w16`, 211 dead with reasons), checked by script in `test.cmd` (TRACE_OK) and recounted by auditor C; both call adapters listed |
| 9 Fidelity register | met, with a caveat | `FIDELITY.md` F1..F95: timing (F12, F89), window and pixel model, fonts (F88), help (F84), handles (F1, F2), class (b) sites, CPU-speed-dependent draws (F87 and others), faults (F10, F33, F91, F92), the open questions (F90). Caveat: the open questions not cited were not re-checked one by one |
| 10 Usage | met, with caveats | `RUNNING.md` (requirements, command line, files written, deviations); port-level failures show a message box and exit non-zero. Caveat: the DIB, window, load and out-of-memory failure paths are implemented but not exercised |

## 3. Open items

1. **User visual confirmation of civ64** (EV-080): **passed** (the user, 2026-10-11 about 08:00
   UTC); asked 2026-10-10 about 15:07 UTC with a data copy (`build/userdata`). It included RV4
   P47-R2: whether the Civilopedia and Find City lists show their scroll bar when they open
   (civ64 shows a gray strip until a scroll; the original under OTVDM shows the bar, which is no
   Windows 3.1 evidence). The user decided: the bar is shown when the dialog opens if and only if
   the list holds more items than fit on one page. **Open:** that fix is queued (`STATUS.md`).
2. Item 7: a recorded check of every 32-bit arithmetic site (audit C10).
3. Item 5: a synchronized oracle scenario with turns, and original-written `famehall.civ`,
   `civ.prf` and `.rep` files compared; stale-tail tests for famehall and replay files.
4. Item 3: key presses of the 22 accelerators other than Ctrl+S and Ctrl+F; sound output; the 10
   civ64 rows not viewed or not re-run; no own hash for Quit and some screens (audit B6).
5. Item 6: effect checks for the findings that are only reached (most G, all R); the C9 hang test.
6. Item 9 and prompt 5.5: the per-question review of the uncited open questions; the one-time
   pixel comparison of the font engine with GDI (`AddFontResourceEx(FR_PRIVATE)`).
7. Item 1: an examination of the c99 parse's strength (audit A3).
8. Decisions awaiting the user (`STATUS.md`): the selector reuse policy (review B2, F1):
   **closed**, confirmed as implemented by the user, 2026-10-11 about 08:00 UTC.

## 4. What was checked how

* **Static review:** the phase-1 design review, the phase-3 verifier rounds 1..11 (699 of 699
  functions), the phase-4 and phase-5 reviews, the phase-8 audits.
* **Headless tests:** `test.cmd` in Release, Checked and Asan (unit tests of `rt` and `w16`, the
  Win32-headless test with 104 checks, the scenario gates GATE3B, UNINIT, P4_SCENARIOS (108 of
  108 rows), P4_TESTS, TRACE).
* **Original runtime comparisons** (oracle grant; copies from `Prepare-OriginalOracle.ps1`, the
  original under OTVDM on Windows 11): title-menu keys (F86), Civilopedia keys (F87), two save
  files byte-identical (`verify/phase7-bringup.md` section 2).
* **Agent-observed:** 21 civ64 runs with every present hashed (`verify/phase7-bringup.md`); the
  Help message box frame (phase 8).
* **User-confirmed:** civ64's visual check passed, 2026-10-11 about 08:00 UTC (before that,
  nothing: the earlier user directions in `STATUS.md` shaped scenarios and fixes; they were not
  acceptance of civ64).
* **Unverified:** appearance against the original (no pixel comparison), sound output, DPI
  changes, long play under both timings, same-seed behaviour (civ64 seeds from its start time).

## 5. Hash check of the originals

Session start: `hashes/20261008T115412Z-before.txt` (38 files). Session end: 2026-10-10 16:03:23 UTC (`hashes/20261010T160323Z-after.txt`, the inline snippet of prompt section 10, no project scripts): 38 of 38 files present, every SHA-256 equal to `claude/docs/original-hashes-before.txt`, attributes and LastWriteTimeUtc unchanged since the session-start record `hashes/20261008T115412Z-before.txt`: **pass**.

## 6. Constraints kept

No original bytes in the repository or in `civ64.exe` (auditor A; `inventory/strings.md` lists
the original string literals as the phase-0 inventory requires, with texts that are also in the
recovered inputs, and nothing of it is compiled in); `original/CIVWIN` never modified (hash
checks); no registry, WIN.INI or clipboard use; no commits, installs or host-wide changes; the
port and its sources stay local and unpublished and need the user's own copy of the game.

## 7. After the final audit (2026-10-10, the user's reports from running civ64)

* The host window is resizable and maximizable; the 640x480 screen keeps its proportions (F98).
* The Status window was below the screen: the user's `civ.prf` was written by the original on a
  2560x1600 desktop. A top-level window placed wholly off the screen is now moved inside it (F96).
* Level of Competition and Pick your tribe showed no Go Back and OK buttons: InvalidateRect now
  also invalidates the children of a window without WS_CLIPCHILDREN (F97, platform fact
  (inferred)); agent-observed headless.
* civ64.exe carries the icon the user chose (F95).
* The checkpoint references were re-recorded (the Status window's position is game state); the
  civ64 statuses in `FEATURES.md` are labelled as observed before these changes. Builds and tests:
  `STATUS.md` "Last build and test results".

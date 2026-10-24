# Sid Meier's Civilization 64bit: the work from start to finish

This folder documents how **Sid Meier's Civilization 64bit** (`civ64.exe`, "civ64") was made: a
native 64-bit Windows port of the 1992 Win16 *Sid Meier's Civilization for Windows*, recovered from
its machine code, with added scaling, map zoom and a switchable DOS graphics profile. It gives the
phases in order, the methods, the tests and their measured results, the findings, and an index of
every published document. The players' manual is the [User Guide](USER-GUIDE.md).

All of the work was done with the assistance of Anthropic's Claude AI, under the direction of the
project's author, who also checked the results on screen. The software and the documentation are
provided "as is", without warranty of any kind, and no liability is accepted (see the
[repository README](../README.md)).

Contents: [1 Overview](#1-overview) · [2 Rules the work followed](#2-rules-the-work-followed) ·
[3 Stage 1: recovering civ.exe](#3-stage-1-recovering-civexe) ·
[4 Stage 2: the port, phases 0 to 8](#4-stage-2-the-port-phases-0-to-8) ·
[5 Stage 3: the extension](#5-stage-3-the-extension-scaling-zoom-and-the-dos-graphics) ·
[6 Tests and measured data](#6-tests-and-measured-data) · [7 Findings](#7-findings) ·
[8 What is open](#8-what-is-open) ·
[9 How the public copy was prepared](#9-how-the-public-copy-was-prepared) ·
[10 Index of documents](#10-index-of-documents)

## 1. Overview

| | |
|---|---|
| The original | `civ.exe` of *Sid Meier's Civilization for Windows*: 832,512 bytes, SHA-256 `a66ec640…1788`, a 16-bit Win16 New Executable built with Borland C++ 3.x (large model), 133 segments (69 code, 64 data), 1,065 functions in 416,385 code bytes |
| The result | `civ64.exe` 1.2.4 (first released as 1.0), a native Windows x64 program (MSVC, C17, warnings as errors) that runs the original game on the player's own copy of its files and contains none of its bytes; since 1.2.2 also `Civ64.app`, a native macOS application (Apple clang, C17, universal arm64 and x86_64, macOS 13 or later) of the same portable layers |
| Recovery | every one of the 1,065 functions recovered as readable C (89 files, about 67,000 lines); 99.93% of the code bytes decoded as instructions or jump tables |
| Port | the 699 live functions translated into portable C (about 124,000 lines including generated tables), each compared instruction by instruction with the listing: 137,887 of 137,887 instructions, 11 verifier rounds; the 155 Borland run-time functions replaced; 211 dead functions recorded and left out ([TRACE.md](TRACE.md)) |
| Coverage | 91.5% of the executable's code bytes ported; 100% of the code that can run either ported or replaced ([recovery-coverage.md](recovery-coverage.md)) |
| Additions | resizable window and full screen, integer or fitted scaling, a game screen that fills the window, a three-level map zoom, light and dark mode, the DOS graphics profile of *Civilization for DOS* 475.01 switchable at any moment |
| Time line | recovery and port base track 2026-10-08 to 2026-10-10; extension sessions E1 to E4 2026-10-10 to 2026-10-22; the macOS session M1 2026-10-22 to 2026-10-23 |

## 2. Rules the work followed

* **Faithful, not a remake.** The rules, the computer players, the map generator, the
  random-number generator, the save formats and the screens are the original's, its bugs included.
  Nothing was taken from other Civilization versions, manuals or remembered rules: every fact comes
  from the binary, and documents say whether a statement is proven from the code or inferred.
* **No original bytes.** The repository and the program hold no byte of the original games. civ64
  reads the player's copy at run time and checks the exact release by size and SHA-256. A scanner
  (`nodos`) checks the tree and the built programs for any run of 47 bytes or more copied from the DOS
  files, and the phase-8 audit scanned `civ64.exe` against the Windows game's 38 data files.
* **The originals are never changed.** Every session hashed the original installation before and
  after the work ([hashes/](hashes/)); every check passed.
* **Invariant P0 for the additions.** The presentation layer (scaling, zoom, the DOS graphics) only
  reads the emulated game and turns the player's actions into input the player could have given in
  the Windows graphics. It never adds, removes or delays a frame of the game, draws no random number
  and calls no game function. The P0 tests run whole scripted games with and without zooms and
  graphics switches and require identical game states.
* **Evidence labels.** Every claim carries how it was established: **compiled**, **headless-tested**
  (the scripted harness or the Win32-headless tests), **agent-observed**, **oracle-compared** (the
  original program run under OTVDM on Windows 11), **DOS listing (model)** for DOS pixel and timing
  claims taken from the DOS program's code, **user-confirmed**, or **unverified**. A passing build is
  never presented as a passing game.
* **Independent review.** Each phase and most units were checked by a separate agent that had not
  written the work, often adversarially, and the findings were fixed or recorded.

## 3. Stage 1: recovering civ.exe

A fresh toolchain (a New Executable parser, a Win16 API database and a Capstone-based recursive
disassembler with Borland prolog, switch-table and x87 handling) decoded the whole executable. The
work then ran in five phases:

| Phase | Work |
|---|---|
| 0 | Toolchain and the complete disassembly: 1,065 functions, about 153,000 distinct instructions, 68 jump tables recovered, 806 named globals |
| 1 | Annotation in 101 work units of about 4 KB of code each (the 4 largest functions split into 16 fragments): every function, parameter, local and global named and described, structure layouts proposed, findings recorded; names consolidated by confidence-weighted voting |
| 1b | Reconciliation of the structure families (city, unit, unit type, civilization arrays, map layers), contested names and the run-time library entry points |
| 2 | Recovered C for every unit, written instruction by instruction with 16-bit semantics and syntax-checked against a Win16 shim header |
| 3 | Adversarial verification: an independent agent per unit re-compared the C with the machine code and fixed the defects it found |
| 4 | Documentation of every subsystem, each independently re-verified against the C and the listing |

The recovered C is a faithful reading aid, not a buildable program: it keeps the original's quirks
and bugs and expresses register-level run-time helpers and x87 code as documented
pseudo-intrinsics. It is not published here; [recovery-coverage.md](recovery-coverage.md) gives its
coverage figures, and [RECOVERY-ERRATA.md](RECOVERY-ERRATA.md) lists the corrections the port later
made to it.

## 4. Stage 2: the port, phases 0 to 8

The port turned the recovered C into a program that runs on 64-bit Windows. Its design
([DESIGN.md](DESIGN.md)) keeps the original's 16-bit memory image: the game's data lives in
emulated selectors and segments at their original offsets, the translated functions use typed
accessors on those offsets and an emulated stack with frame descriptors generated from the listing,
and a Win16 emulation layer (`w16`: KERNEL, USER, GDI, COMMDLG, MMSYSTEM; 141 functions for the 156
imports, [API-MAP.md](API-MAP.md)) re-creates Windows 3.1's windows, dialogs, controls, palette
graphics, fonts, timers and memory on a thin Win32 back end.

| Phase | Gate met (UTC) | Work | Record |
|---|---|---|---|
| 0 | 2026-10-08 | Inventories of every construct that needs care: imported APIs, divisions and shifts, evaluation order, floating point, liveness, out-of-range sites, pointer and handle data, pseudo-intrinsics, run-time calls, stack locals, uninitialised values | [phase-0-acceptance.md](phase-0-acceptance.md), [inventory/](inventory/) |
| 1 | 2026-10-08 14:35 | Design, generators (layout, frames, dispatch, interfaces) and the NE loader; independent design review with two blockers fixed before phase 2 | [phase-1-acceptance.md](phase-1-acceptance.md), [phase-1-review.md](phase-1-review.md) |
| 2 | 2026-10-08 17:28 | The `rt` run-time replacement, the `w16` skeleton and the headless harness | [phase-2-acceptance.md](phase-2-acceptance.md) |
| 3a | 2026-10-09 01:51 | Translation of the start-up and world generation; headless start-up reaches the title menu | [phase-3a-acceptance.md](phase-3a-acceptance.md) |
| 3b | 2026-10-09 15:35 | Load and save, the new game | [phase-3b-acceptance.md](phase-3b-acceptance.md) |
| 3c | 2026-10-09 15:35 | All units translated; 699 of 699 functions PASS the instruction-by-instruction verification (rounds 1 to 11, [verify/](verify/)) | [phase-3c-acceptance.md](phase-3c-acceptance.md) |
| 4 | 2026-10-10 08:55 | The portable `w16` complete; all 108 features reached headless; every finding cited in the core executed | [phase-4-acceptance.md](phase-4-acceptance.md) |
| 5 | 2026-10-10 11:45 | The Win32 back end with every host service under the Win32-headless test | [phase-5-acceptance.md](phase-5-acceptance.md) |
| 6 | 2026-10-10 12:25 | `civ64.exe`: clean Release build, data-directory verification | [phase-6-acceptance.md](phase-6-acceptance.md) |
| 7 | 2026-10-10 15:06 | Bring-up in real windows (21 runs, every frame hashed) and comparisons with the original under OTVDM: save files byte-identical | [phase-7-acceptance.md](phase-7-acceptance.md), [verify/phase7-bringup.md](verify/phase7-bringup.md) |
| 8 | 2026-10-10 | Three independent adversarial audits and their fixes: delivered with open items | [phase-8-acceptance.md](phase-8-acceptance.md), [final-report.md](final-report.md) |

The author's visual check of civ64 passed on 2026-10-11.

## 5. Stage 3: the extension (scaling, zoom and the DOS graphics)

The extension added everything a modern player expects without touching the game: a portable
presentation layer between the emulated screen and the window, an observer that reads the emulated
game's state and drawing calls, a map renderer for the zoom, and a complete second set of graphics
taken at run time from the DOS release. The DOS program was studied from its own files and listings
only ([dos/](dos/)): its executable and overlays, data formats, palettes and cycling, sprites,
timing, scenes, and the correspondence of every DOS screen with a Windows screen
([DOS-PROFILE.md](DOS-PROFILE.md), the scene and counterpart tables).

| Phase | Gate | Work | Record |
|---|---|---|---|
| X0 | 2026-10-10 | Hashes of both originals, the DOS reference list, an independent review of the extension's plan | [ext-X0-acceptance.md](ext-X0-acceptance.md) |
| S1, S2 | 2026-10-10 | The presentation frame and scaler (integer and fit, nearest and sharp filters, inverse mouse mapping); the resizable window, full screen, DPI changes | [ext-S1-acceptance.md](ext-S1-acceptance.md), [ext-S2-acceptance.md](ext-S2-acceptance.md) |
| R | 2026-10-10 | Finding the game: ZIP files, folders, the remembered location and the question | [ext-R-acceptance.md](ext-R-acceptance.md) |
| G | 2026-10-11 | The game screen grows with the window | [ext-G-acceptance.md](ext-G-acceptance.md) |
| D0 to D2 | 2026-10-11 | DOS research, the design of the DOS profile (five independent drafts and a decision record), the DOS asset store (EXEPACK, pictures, palettes, fonts, texts, tables, shapes) | [ext-D0-acceptance.md](ext-D0-acceptance.md), [ext-D1-acceptance.md](ext-D1-acceptance.md), [ext-D2-acceptance.md](ext-D2-acceptance.md) |
| D3 | 2026-10-11 | The observer, the presentation tick, live switching and the input stages | [ext-D3-acceptance.md](ext-D3-acceptance.md) |
| M | 2026-10-11 | The map renderer and the zoom for the Windows graphics | [ext-M-acceptance.md](ext-M-acceptance.md) |
| D4, BS | 2026-10-15/16 | The DOS credits, intro, title menu, Birth with colour cycling and the DOS pointer; the Birth synchronisation of both profiles | [ext-D4-acceptance.md](ext-D4-acceptance.md), [ext-BS-acceptance.md](ext-BS-acceptance.md) |
| D5 | 2026-10-16 | The DOS setup screens and title branches | [ext-D5-acceptance.md](ext-D5-acceptance.md) |
| D6 | 2026-10-17 | Play with the DOS graphics: the map, small map, status and unit panels, menus and boxes, the zoom | [ext-D6-acceptance.md](ext-D6-acceptance.md) |
| D7 | 2026-10-18 | Every remaining DOS scene: reports, city screen and view, palace, Civilopedia, diplomacy, spaceship, end games | [ext-D7-acceptance.md](ext-D7-acceptance.md) |
| X9 | 2026-10-18 | Final independent audit and the AddressSanitizer pass: delivered with open items | [ext-X9-audit.md](ext-X9-audit.md) |

Each phase was split into units (`ext-<unit>-record.md`), each staged privately, reviewed, then
landed with a three-step cycle (build, the full test suite, the G-1 equality check) that had to be
all green. The author's checks of every visible change are the manual checklist
([manual-checklist-ext.md](manual-checklist-ext.md)); the UX units record the corrections the
author asked for after looking at each user build. [STATUS.md](STATUS.md) is the ledger of the whole
port, with every direction of the author and every build and test result.

## 6. Tests and measured data

**The suite** (`test.cmd`, run in the Checked, Release, Checked-without-observer and
AddressSanitizer variants):

* 67 unit and integration test programs (run-time library, `w16`, presentation, scaler, input,
  map, every DOS decoder and scene renderer, the Win32 back end with a hidden window, the
  single-instance check).
* **GATE3B**: 24 checkpoint snapshots of scripted games (after load, before each save, each turn,
  after world generation, after setup) equal a recorded reference, and repeated runs are
  byte-identical. The world generator's random path reproduces an independent model for two
  seeds (5,996 and 5,555 draws).
* **P4_SCENARIOS**: all 108 features of [FEATURES.md](FEATURES.md) (every menu command, the 19
  dialogs, the title branches, intro and Birth, advisors, Civilopedia, diplomacy, newspaper,
  spaceship, replay, palace, Hall of Fame, end games, palette cycling, sound) reached by scripted
  games, each with the hash of its first stable frame; since D8 every row also has its DOS column.
* **EXT_G1**: 77 scripted runs whose game events and frames must stay equal to the baseline
  recorded before the extension (the presentation never changes the game).
* **P0**: whole games with zooms every 1.3 s and graphics switches every few seconds equal the
  same games without them.
* **TRACE_OK** (the 1,065-function traceability table rebuilt and compared), **REGISTRY_OK** (the DOS
  data registry against the DOS files), **NODOS_OK** (no DOS byte in the tree or the programs),
  OBS_TABLES_OK and OBS_LINT_OK (the observer's 203 probes at 103 sites), ADAPT_OK (166 input-adapter
  rows), and the scene checker (1,086 checks).

**Measured on the final tree** (2026-10-18, [ext-X9-audit.md](ext-X9-audit.md)): AddressSanitizer
build and suite clean (TESTS_OK in 1,637 s, EXT_G1 77 runs, no sanitizer report); Checked suite
17:38..18:05 UTC; Checked-without-observer TESTS_OK in 343 s; Release TESTS_OK in 304 s. The
Release `civ64.exe` of 18:08:29 UTC is the program of the `v1.0` release.

**Version 1.1** (session E5, 2026-10-18/19) adds windowless play ([ext-WL-record.md](ext-WL-record.md),
[ext-WL2-record.md](ext-WL2-record.md)), 4:3 for the DOS gameplay ([ext-A43-record.md](ext-A43-record.md)),
CRT scanlines ([ext-CRT-record.md](ext-CRT-record.md), [ext-CRT2-record.md](ext-CRT2-record.md)),
alternative music and sound effects from the player's own files ([ext-AMS-record.md](ext-AMS-record.md))
and the DOS science advisor's recommendation on the Status window ([ext-D7g3-record.md](ext-D7g3-record.md));
FIDELITY F322 to F338. Each unit landed with the three-step cycle (build, suite, EXT_G1) ALL_GREEN. The
closing run of 2026-10-19 (`CLOSE5_ALL_GREEN`): AddressSanitizer build and suite TESTS_OK in 1,561 s with
EXT_G1 77 runs, Checked-without-observer TESTS_OK in 337 s, Release TESTS_OK in 309 s; the hash check of
the original game files after the work, 38 of 38 equal ([hashes/20261019T050854Z-after.txt](hashes/20261019T050854Z-after.txt)).
The Release `civ64.exe` of 2026-10-19 04:23 UTC is the program of the `v1.1` release.

**Version 1.2** (2026-10-19): windowless play fills the whole window in both graphics, without the black
border ([ext-WL3-record.md](ext-WL3-record.md); FIDELITY F339), and the version information and About box
say 1.2 (F340). WL3 landed with the three-step cycle ALL_GREEN (`test_wl` 93 checks). The Release
`civ64.exe` of 2026-10-19 07:27:07 UTC is the program of the `v1.2` release.

**Version 1.2.1** (2026-10-20..22): CRT scanlines double-scanned in both graphics and shown at every
size, a window spaced as full screen, the gameplay as the accepted title screens
([ext-WL4CRT3-record.md](ext-WL4CRT3-record.md), [ext-CRT4-record.md](ext-CRT4-record.md),
[ext-CRT5-record.md](ext-CRT5-record.md), [ext-CRT6WL6-record.md](ext-CRT6WL6-record.md); F342, F343,
F345, F346); the windowless Windows menus with the Status gray, the user's stone background (built into
`civ64.exe`) and readable disabled items ([ext-WL5-record.md](ext-WL5-record.md); F341, F344, F347,
F351); the torch cursor over the Windows menus ([ext-CUR1-record.md](ext-CUR1-record.md); F348); the
host pause while the window menu, a move or size or civ64's own boxes are open
([ext-PAU1-record.md](ext-PAU1-record.md); F349); version 1.2.1 and the Civ64 link (F350); and the
title bar's icon after a start in full screen ([ext-ICO1-record.md](ext-ICO1-record.md); F352). Each
unit landed with the three-step cycle ALL_GREEN. The Release `civ64.exe` of 2026-10-22 16:08:36 UTC is the
program of the `v1.2.1` release.

**Version 1.2.2** (2026-10-23): two fixes of the DOS graphics that the macOS work found in the shared
presentation code (unit MACB1, [ext-MACB1-record.md](ext-MACB1-record.md)), built into the Windows
`civ64.exe` by unit V122 ([ext-V122-record.md](ext-V122-record.md)): in windowless play the DOS menu
bar's own titles right of a narrow map window's bar (F353), and the play palette with the government's
BACK palette at the first play state after Load a Saved Game, as DOS's main sets it (F354); version
1.2.2 (F355). V122 landed with the three-step cycle ALL_GREEN. The Release `civ64.exe` of 2026-10-23 06:14:13 UTC
is the program of the `v1.2.2` release.

**Version 1.2.2, macOS** (2026-10-22..23, session M1 on a Mac; [verify/BRIEF-mac.md](verify/BRIEF-mac.md)):
`Civ64.app`, the same portable layers over a native AppKit back end in place of the Win32 one. The headless
build and the whole test suite moved to macOS first: all 31 sections of the Windows suite, G-1's 77 runs with
its one recorded amendment, the Asan pass and the Rosetta 2 run of the x86_64 build
([ext-MAC0-record.md](ext-MAC0-record.md)). The back end and the program, with the macOS differences listed
([ext-MAC1-record.md](ext-MAC1-record.md)), then the game's menus mirrored in the macOS menu bar (unit MAC3, in
the same record). The user's checks found four defects ([ext-MACB1-record.md](ext-MACB1-record.md)): Mac
shortcuts for the graphics switch and the zoom; the two DOS faults of the shared code above; the system arrow
outside the game picture. A Shift released after Shift+Command+Delete ended the intro
([ext-MACB2-record.md](ext-MACB2-record.md)). The release build is universal, signed with a Developer ID,
notarized and stapled ([ext-MAC4-record.md](ext-MAC4-record.md)); `Civ64-1.2.2-macOS.dmg` joins `civ64.exe` in
the `v1.2.2` release.

**Version 1.2.3** (2026-10-23, Windows; unit DV, [ext-DV-record.md](ext-DV-record.md)): a player's report, a
DOS copy with the right `CIV.EXE` and one other file changed accepted at the start and by "Locate DOS files…"
while the DOS asset store refused it, at every start. The lookup now applies the store's own rule (every
required file at its pinned size and SHA-256) wherever it finds or is given the DOS copy, and names the first
wrong file (F117); a wrong `CIV.EXE` says "Version 475.05 is required." (the pinned `CIV.EXE` holds the
CivFanatics FAQ's version-5 bytes); version 1.2.3 (F355). DV landed with the three-step cycle ALL_GREEN. The
Release `civ64.exe` of 2026-10-23 08:12:53 UTC is the program of the `v1.2.3` release. The macOS session ported the
check to the macOS lookup (`ext-DV-record.md`, "The macOS port") and set the macOS application to 1.2.3;
`Civ64-1.2.3-macOS.dmg` joins `civ64.exe` in the `v1.2.3` release.

**Version 1.2.4 (unit ZS, 2026-10-24).** The user asked for one more map zoom step between the levels in both
directions and for the window menu's Zoom out / Zoom in to step, repeatably, as the keys do
([ext-ZS-record.md](ext-ZS-record.md)): five levels (half, three quarters, normal, one and a half, double; F356),
the menu's "Zoom out" and "Zoom in" one level each, "Normal zoom" checked at normal size, the remembered level in the
new key `map_zoom` (an earlier build's `zoom` read with its meaning); version 1.2.4 (F355). The map and Windows host
tests check the geometry, the refusals, the steps and the menu; the user's check passed. The Release `civ64.exe` of
2026-10-24 12:15:10 UTC is the program of the `v1.2.4` release. The macOS session built ZS's macOS source (the Map
Zoom menu's one-step Zoom Out / Zoom In, `--zoom -2..+2`, `map_zoom`) with MACB3 (the DOS "not found" sentence names
`Civ64.app`) and set the macOS application to 1.2.4 (`ext-ZS-record.md`, "The macOS port");
`Civ64-1.2.4-macOS.dmg` joins `civ64.exe` in the `v1.2.4` release.

**Comparisons with the original** (OTVDM on Windows 11): the original's load-and-save of a save
file equals civ64's byte for byte; the original loads a civ64 save and both re-saves are
byte-identical; title-menu and Civilopedia keys behave the same.

**The fidelity register** ([FIDELITY.md](FIDELITY.md), entries F1 to F356) lists every place where
civ64 does not, or cannot, reproduce the original exactly, every accepted design choice and every
unknown, with its evidence.

## 7. Findings

* **The original's bugs are kept.** 93 of the 94 reachable bugs found in the original during recovery
  have an executed citation in the core, and 14 have their effects asserted by tests (final report
  item 6). Faults that would have stopped the original under Windows 3.1 are reported the same way.
* **The recovered C needed corrections** that only translation and testing revealed; they are listed
  in [RECOVERY-ERRATA.md](RECOVERY-ERRATA.md) and in the verifier rounds of [verify/](verify/).
* **Platform facts** that the original relies on (Windows 3.1 invalidation of child windows, input
  polling, palette behaviour, fonts) were established from the code and, where possible, from the
  original under OTVDM; each is a FIDELITY entry with its label.
* **The DOS program** (EXEPACK-packed root and 23 overlays) was mapped far enough to draw every
  scene from the running Windows game's state: [dos/EXECUTABLE.md](dos/EXECUTABLE.md),
  [dos/FORMATS.md](dos/FORMATS.md), [dos/SCENES.md](dos/SCENES.md),
  [dos/SCENES-PLAY.md](dos/SCENES-PLAY.md), [dos/TIMING.md](dos/TIMING.md) and the open questions in
  [dos/OPEN.md](dos/OPEN.md).

## 8. What is open

* Same-seed equality with the original is not claimed: civ64 seeds from its start time, and no
  synchronized turn-by-turn comparison with the original was made.
* Original-written Hall of Fame, preference and replay files were not compared.
* Sound output was never measured; the original Help file cannot be shown on Windows 10 and 11.
* Every DOS pixel and timing claim is "DOS listing (model)": no DOS program was run.
* The remaining user checks and the final audit's open items are listed in
  [ext-X9-audit.md](ext-X9-audit.md), [final-report.md](final-report.md) section 3 and
  [NEXT-SESSION-E5.md](NEXT-SESSION-E5.md).

## 9. How the public copy was prepared

The documents here are the project's working records, published as they are, with these changes
made for the public copy and recorded file by file in an audit:

* **Files left out:** the original string inventory (`inventory/strings.md`), the brief that lists the
  parent project's excluded paths (`verify/BRIEF-d0.md`), the forum post drafts, and every file that
  holds code, listings or original bytes.
* **Links** to files that are not published (the recovered C, the core, the tools, the build tree)
  were turned into plain text naming the file.
* **Code passages.** No document carries code: 53 fenced C blocks (52 design sketches of civ64's own
  presentation interfaces in the five D1 design drafts, and one short passage in a unit record)
  and 19 inline passages of two or more C statements (quotations of the recovered C in
  [RECOVERY-ERRATA.md](RECOVERY-ERRATA.md) and verifier reports) were each condensed into a
  description that keeps the names they mention.
* **Private data:** 13 private folder paths were replaced by placeholders; no e-mail address remains.
* **No DOS bytes:** the published tree was scanned with the project's `nodos` scanner (0 hits). The
  seven screenshots in [screenshots/](screenshots/) are the only images of the original games' art;
  they show civ64 running, by the author's choice.

## 10. Index of documents

### Start here

| Document | Title |
|---|---|
| [DESIGN.md](DESIGN.md) | civ64 — design (phases 1 and 2) |
| [DOS-PROFILE.md](DOS-PROFILE.md) | DOS graphics profile: scene and counterpart tables |
| [FEATURES.md](FEATURES.md) | Features |
| [FIDELITY.md](FIDELITY.md) | Fidelity register |
| [final-report.md](final-report.md) | civ64: final report |
| [recovery-coverage.md](recovery-coverage.md) | Sid Meier's Civilization 64bit: how much of the original was recovered |
| [RUNNING.md](RUNNING.md) | Running civ64 |
| [STATUS.md](STATUS.md) | civ64 port — status ledger |
| [USER-GUIDE.md](USER-GUIDE.md) | Sid Meier's Civilization 64bit: User Guide |

### Reference

| Document | Title |
|---|---|
| [API-MAP.md](API-MAP.md) | Win16 import map |
| [manual-checklist-ext.md](manual-checklist-ext.md) | Extension: manual checks for the user |
| [RECOVERY-ERRATA.md](RECOVERY-ERRATA.md) | Recovery errata |
| [TRACE.md](TRACE.md) | TRACE: original functions to the port |

### Phase acceptance records (the port)

| Document | Title |
|---|---|
| [phase-0-acceptance.md](phase-0-acceptance.md) | Phase 0 acceptance record |
| [phase-1-acceptance.md](phase-1-acceptance.md) | Phase 1 acceptance record |
| [phase-1-review.md](phase-1-review.md) | Phase 1: independent design review (record) |
| [phase-2-acceptance.md](phase-2-acceptance.md) | Phase 2 acceptance record |
| [phase-3a-acceptance.md](phase-3a-acceptance.md) | Phase 3a acceptance record |
| [phase-3b-acceptance.md](phase-3b-acceptance.md) | Phase 3b acceptance record |
| [phase-3c-acceptance.md](phase-3c-acceptance.md) | Phase 3c acceptance record |
| [phase-4-acceptance.md](phase-4-acceptance.md) | Phase 4 acceptance record |
| [phase-5-acceptance.md](phase-5-acceptance.md) | Phase 5 acceptance record |
| [phase-6-acceptance.md](phase-6-acceptance.md) | Phase 6 acceptance record |
| [phase-7-acceptance.md](phase-7-acceptance.md) | Phase 7 acceptance record |
| [phase-8-acceptance.md](phase-8-acceptance.md) | Phase 8 acceptance record: final audit |

### Extension acceptance and audit records

| Document | Title |
|---|---|
| [ext-BS-acceptance.md](ext-BS-acceptance.md) | Extension unit BS (the Birth screen-by-screen synchronisation) — acceptance record |
| [ext-D0-acceptance.md](ext-D0-acceptance.md) | Extension phase D0 — acceptance record |
| [ext-D1-acceptance.md](ext-D1-acceptance.md) | Extension phase D1 — acceptance record |
| [ext-D2-acceptance.md](ext-D2-acceptance.md) | Extension phase D2 (DOS assets) — acceptance record |
| [ext-D3-acceptance.md](ext-D3-acceptance.md) | Extension phase D3 (observer, presentation tick, switching, input stages) — acceptance record |
| [ext-D3-probe-verification.md](ext-D3-probe-verification.md) | Extension D3: probe verification (O5) |
| [ext-D4-acceptance.md](ext-D4-acceptance.md) | Extension phase D4 (credits, intro, title menu, Birth, the DOS pointer) — acceptance record |
| [ext-D5-acceptance.md](ext-D5-acceptance.md) | Extension phase D5 (setup screens, title branches, their R re-skins) — acceptance record |
| [ext-D6-acceptance.md](ext-D6-acceptance.md) | Extension phase D6 (play in the DOS profile: class A, menus, zoom) — acceptance record |
| [ext-D7-acceptance.md](ext-D7-acceptance.md) | Extension phase D7 (every remaining N and R scene of the scene table) - acceptance record |
| [ext-G-acceptance.md](ext-G-acceptance.md) | Extension phase G — acceptance record |
| [ext-M-acceptance.md](ext-M-acceptance.md) | Extension phase M (map renderer and zoom, Windows profile) — acceptance record |
| [ext-R-acceptance.md](ext-R-acceptance.md) | Extension phase R (the user's resource-lookup requirements) — acceptance record |
| [ext-S1-acceptance.md](ext-S1-acceptance.md) | Extension phase S1 — acceptance record |
| [ext-S2-acceptance.md](ext-S2-acceptance.md) | Extension phase S2 — acceptance record |
| [ext-X0-acceptance.md](ext-X0-acceptance.md) | Extension phase X0 — acceptance record |
| [ext-X9-audit.md](ext-X9-audit.md) | Extension phase X9 (final audit and the one Asan pass) - audit record |

### Unit records

| Document | Title |
|---|---|
| [ext-A43-record.md](ext-A43-record.md) | Extension unit A43 (4:3 for DOS gameplay and the rename) - record |
| [ext-AMS-record.md](ext-AMS-record.md) | Extension unit AMS (alternative music and sound effects) - record |
| [ext-BS1-record.md](ext-BS1-record.md) | Extension BS, unit BS1 (Windows Birth assets) - record |
| [ext-BS2-record.md](ext-BS2-record.md) | Extension BS, unit BS2 (the Windows Birth replica and its shadow mirror) - record |
| [ext-BS3-record.md](ext-BS3-record.md) | Extension BS, unit BS3 (the warp and the Windows view) - record |
| [ext-BS4-record.md](ext-BS4-record.md) | Extension BS, unit BS4 (the Windows end and the records) - record |
| [ext-CRT-record.md](ext-CRT-record.md) | Extension unit CRT (the "CRT scanlines" filter) - record |
| [ext-CRT2-record.md](ext-CRT2-record.md) | Extension unit CRT2 (the CRT scanlines follow-up: speed and sharpness) - record |
| [ext-CRT4-record.md](ext-CRT4-record.md) | Extension unit CRT4 (the CRT scanlines double-scanned everywhere) - record |
| [ext-CRT5-record.md](ext-CRT5-record.md) | Extension unit CRT5 (the CRT scanlines at every output scale) - record |
| [ext-CRT6WL6-record.md](ext-CRT6WL6-record.md) | Extension units CRT6 (the gameplay's scanlines on the accepted base) and WL6 (disabled menu items) - record |
| [ext-CUR1-record.md](ext-CUR1-record.md) | Extension unit CUR1 (the torch cursor over the Windows graphics' menus) - record |
| [ext-CY-record.md](ext-CY-record.md) | Extension unit CY (a faster build-and-test cycle without dropping any test) - record |
| [ext-D3a-record.md](ext-D3a-record.md) | Extension phase D3, unit D3a (the observer core) — record |
| [ext-D3b1-record.md](ext-D3b1-record.md) | Extension phase D3, unit D3b1 (presentation, switching and the P0 runners) — record |
| [ext-D3b2-record.md](ext-D3b2-record.md) | Extension phase D3, unit D3b2 (input stages, chord and menu, the 7.8 mode) — record |
| [ext-D4a-record.md](ext-D4a-record.md) | Extension phase D4, unit D4a (area B's base) - record |
| [ext-D4b1-record.md](ext-D4b1-record.md) | Extension phase D4, unit D4b1 (the DOS clock and the timeline engine) - record |
| [ext-D4b2a-record.md](ext-D4b2a-record.md) | Extension phase D4, unit D4b2a (the DOS intro, credits and logo program) - record |
| [ext-D4b2b1-record.md](ext-D4b2b1-record.md) | Extension phase D4, unit D4b2b1 (the DOS scene sequencer and its wiring) - record |
| [ext-D4b2b2-record.md](ext-D4b2b2-record.md) | Extension phase D4, unit D4b2b2 (the DOS title box, the menu-box model, the pointer rule) - record |
| [ext-D4b3-record.md](ext-D4b3-record.md) | Extension phase D4, unit D4b3 (DOS Birth) - record |
| [ext-D4b4-record.md](ext-D4b4-record.md) | Extension phase D4, unit D4b4 (Birth auto-continue) - record |
| [ext-D4c1-record.md](ext-D4c1-record.md) | Extension phase D4, unit D4c1 (the DOS filter stage, adapters, mouse conversion) - record |
| [ext-D4c2-record.md](ext-D4c2-record.md) | Extension phase D4, unit D4c2 (pending translations, the 7.8 DOS-form scripts, the D4 gate) - record |
| [ext-D5a-record.md](ext-D5a-record.md) | Extension phase D5, unit D5a (the N-window binding and the sequencer's title-branch and setup states) - record |
| [ext-D5b-record.md](ext-D5b-record.md) | Extension phase D5, unit D5b (class R re-skins on the N canvas, `pdos_reskin`) - record |
| [ext-D5c-record.md](ext-D5c-record.md) | Extension phase D5, unit D5c (the DOS setup pages 0..2 and the T4 setup page, `pdos_scn_setup`; adapter I-setup) - record |
| [ext-D5d-record.md](ext-D5d-record.md) | Extension phase D5, unit D5d (the name pages, dialog 151's introduction text, `pdos_fx`; adapters I-text and I-wait) - record |
| [ext-D5e-record.md](ext-D5e-record.md) | Extension phase D5, unit D5e (Customize World: dialog 143's transition, its four questions and the DOS help screen; adapters I-custom and the help screen's I-wait) - record |
| [ext-D5f-record.md](ext-D5f-record.md) | Extension phase D5, unit D5f (the Hall of Fame, the Load's fill, EARTH and Quit; decision 7's runs, decision 8's counters by row; with D5cR and D5eR) - record |
| [ext-D5K-record.md](ext-D5K-record.md) | Extension D5, bug-fix unit D5K (the keyboard lost after the Windows-only Go Back; checklist D5-6) - record |
| [ext-D5K2-record.md](ext-D5K2-record.md) | Extension D5, bug-fix unit D5K2 (a dialog keeps the keyboard focus when its focused control is disabled) - record |
| [ext-D5P-record.md](ext-D5P-record.md) | Extension D5, bug-fix unit D5P (screen parity after a Windows-side return to the title menu; the 4:3 shape on DOS-side returns; no Quit in the DOS title) - record |
| [ext-D6a-record.md](ext-D6a-record.md) | Extension phase D6, unit D6a (the map display model with the Windows rule set, M2, and the present check) - record |
| [ext-D6b-record.md](ext-D6b-record.md) | Extension phase D6, unit D6b (logical replay and provenance for play: `pdos_replay`, `pdos_prov`; S3) - record |
| [ext-D6c-record.md](ext-D6c-record.md) | Extension phase D6, unit D6c (the DOS map rules in view: `pmap_dos`; the dos-settled check) - record |
| [ext-D6d-record.md](ext-D6d-record.md) | Extension phase D6, unit D6d (the DOS ring, the zoom in the DOS profile and the map palette animation) - record |
| [ext-D6e-record.md](ext-D6e-record.md) | Extension phase D6, unit D6e (the small map, the Status window and the unit panel; the play palette's return) - record |
| [ext-D6f-record.md](ext-D6f-record.md) | Extension phase D6, unit D6f (the menus on the A canvas; adapters I-play and I-menubar) - record |
| [ext-D6fS-a-record.md](ext-D6fS-a-record.md) | Extension phase D6, unit D6fS-a (the DOS boxes in play: no Windows window while they close, their DOS sizes) - record |
| [ext-D6fS-b-record.md](ext-D6fS-b-record.md) | Extension phase D6, unit D6fS-b (the DOS game's menus in play: the DOS bar, the DOS menus and ORDERS, the DOS keys and highlight) - record |
| [ext-D6fSc-record.md](ext-D6fSc-record.md) | Extension phase D6, unit D6fSc (the DOS boxes' line breaks and widths: DOS's own text for the named boxes, DOS's line rule for the rest) - record |
| [ext-D6fSd-record.md](ext-D6fSd-record.md) | Extension phase D6, unit D6fSd (the DOS game's own section texts and places for the remaining boxes) - record |
| [ext-D6g-record.md](ext-D6g-record.md) | Extension phase D6, unit D6g (the sweep, the agent check and the gate) - record |
| [ext-D7a-record.md](ext-D7a-record.md) | Extension phase D7, unit D7a (N scenes in play, the return to the map, the O14 frame, City Status) - record |
| [ext-D7b-record.md](ext-D7b-record.md) | Extension phase D7, unit D7b (the advisors' reports) - record |
| [ext-D7c-record.md](ext-D7c-record.md) | Extension phase D7, unit D7c (the World reports and the historian) - record |
| [ext-D7d-record.md](ext-D7d-record.md) | Extension phase D7, unit D7d (the DOS city screen) - record |
| [ext-D7e-record.md](ext-D7e-record.md) | Extension phase D7, unit D7e (the city view, the founding scene, the city animations) - record |
| [ext-D7f-record.md](ext-D7f-record.md) | Extension phase D7, unit D7f (the list, entry, production and stack dialogs) - record |
| [ext-D7g-record.md](ext-D7g-record.md) | Extension phase D7, unit D7g (the science advisor's boxes: the header variant, the research choice, the recommendation in DOS's flow) - record |
| [ext-D7g2-record.md](ext-D7g2-record.md) | Extension phase D7, unit D7g2 (the rest of D7g's rows: the notes, the government menu, the event boxes, the sale question; the DOS boxes centred on the A canvas) - record |
| [ext-D7g3-record.md](ext-D7g3-record.md) | Extension unit D7g3: the science advisor's recommendation box (DOS graphics) |
| [ext-D7h-record.md](ext-D7h-record.md) | Extension phase D7, unit D7h (the Civilopedia) - record |
| [ext-D7h2-record.md](ext-D7h2-record.md) | Extension phase D7, unit D7h2 (the DOS entry page above the menu boxes; D7h-6's fix) - record |
| [ext-D7i-record.md](ext-D7i-record.md) | Extension phase D7, unit D7i (the newspaper, New Cabinet, the discoveries and the quiz) - record |
| [ext-D7j-record.md](ext-D7j-record.md) | Extension phase D7, unit D7j (the palace) - record |
| [ext-D7k-record.md](ext-D7k-record.md) | Extension phase D7, unit D7k (diplomacy and leaders) - record |
| [ext-D7l-record.md](ext-D7l-record.md) | Extension phase D7, unit D7l (the spaceship screens and the arrival) - record |
| [ext-D7l2-record.md](ext-D7l2-record.md) | Extension phase D7, unit D7l2 (the spaceship arrival) - record |
| [ext-D7m-record.md](ext-D7m-record.md) | Extension phase D7, unit D7m (the end of the game) - record |
| [ext-D7n-record.md](ext-D7n-record.md) | Extension phase D7, unit D7n (the conqueror ending and the nuclear explosion) - record |
| [ext-D7o-record.md](ext-D7o-record.md) | Extension phase D7, unit D7o (the sweep, the reach and the gate) - record |
| [ext-DBL-record.md](ext-DBL-record.md) | Extension DBL, presentation unit (the DOS blinks at the DOS game's own pace) - record |
| [ext-DV-record.md](ext-DV-record.md) | Unit DV (the DOS files a player located again and again) - record |
| [ext-FCE-record.md](ext-FCE-record.md) | Extension unit FCE (Escape on the game's list, modal and name dialogs) - record |
| [ext-HM-record.md](ext-HM-record.md) | Extension unit HM (the host window menu with submenus) - record |
| [ext-ICO1-record.md](ext-ICO1-record.md) | Extension unit ICO1 (the title bar's icon after a start in full screen) - record |
| [ext-LP-record.md](ext-LP-record.md) | Extension unit LP (the low-priority requests) — record |
| [ext-Ma-record.md](ext-Ma-record.md) | Extension phase M, unit Ma (zoom, layer, in-view source, input, commands) — record |
| [ext-MAC0-record.md](ext-MAC0-record.md) | Unit MAC0 (the toolchain and the headless suite on macOS) - record |
| [ext-MAC1-record.md](ext-MAC1-record.md) | Unit MAC1 (the macOS back end and the program) - record |
| [ext-MAC4-record.md](ext-MAC4-record.md) | Unit MAC4 (the signed, notarized macOS release build) - record |
| [ext-MACB1-record.md](ext-MACB1-record.md) | Unit MACB1 (the user's first macOS bug reports) - record |
| [ext-MACB2-record.md](ext-MACB2-record.md) | Unit MACB2 (the graphics switch ended the intro on macOS) - record |
| [ext-MACB3-record.md](ext-MACB3-record.md) | Unit MACB3 (the DOS "not found" sentence names Civ64.app on macOS) - record |
| [ext-Mb1-record.md](ext-Mb1-record.md) | Extension phase M, unit Mb1 (snapshots, the Windows rules, the world canvas, the ring) — record |
| [ext-Mb2-record.md](ext-Mb2-record.md) | Extension phase M, unit Mb2 (mirror checks, ext_mirror.py, ext_zoom.py, agent UI check, gate) — record |
| [ext-MZ-record.md](ext-MZ-record.md) | Extension unit MZ (the centring at map zoom level -1) - record |
| [ext-MZI-record.md](ext-MZI-record.md) | Extension unit MZI (the centring at map zoom level +1) - record |
| [ext-MZS-record.md](ext-MZS-record.md) | Extension unit MZS (menus, dialogs and moved windows over the zoomed map) - record |
| [ext-MZW-record.md](ext-MZW-record.md) | Extension unit MZW (the World Map's rectangle follows the map zoom level) - record |
| [ext-PAU1-record.md](ext-PAU1-record.md) | Extension unit PAU1 (the window menu pauses the game; version 1.2.1; the Civ64 link; the menu tile inside civ64.exe) - record |
| [ext-SI-record.md](ext-SI-record.md) | Extension unit SI (civ64 runs as a single instance) - record |
| [ext-SL-record.md](ext-SL-record.md) | Extension unit SL: the DOS Save/Load slot screens |
| [ext-TLD-record.md](ext-TLD-record.md) | Extension unit TLD (the title menu behind the Load dialog) - record |
| [ext-UX1-record.md](ext-UX1-record.md) | Extension unit UX1 (the DOS pointer's size; the host close button, Alt+F4 and "Exit Sid Meier's Civilization 64bit" with an in-game warning) - record |
| [ext-UX2-record.md](ext-UX2-record.md) | Extension unit UX2 (the system menu's profile mark at the start; square as the default for 320x200 pictures) - record |
| [ext-UX3-record.md](ext-UX3-record.md) | Extension unit UX3 (the menu texts "Integer scaling" and "4:3 aspect ratio for 320 x 200 screens"; 4:3 the default again, with the DOS intro, title box and Birth square) - record |
| [ext-UX4-record.md](ext-UX4-record.md) | Extension unit UX4 (the keypad's Ctrl+Shift+0, the window placement Windows actually gives, message boxes in dark mode) - record |
| [ext-UX4b-record.md](ext-UX4b-record.md) | Extension unit UX4b (Ctrl+Shift+Home resets the map zoom) - record |
| [ext-UX5-record.md](ext-UX5-record.md) | Extension UX5, presentation unit (the 4:3 option on the DOS intro and the DOS title menu) - record |
| [ext-UX5b-record.md](ext-UX5b-record.md) | Extension UX5b, presentation unit (Birth square from its first picture: no squashed title) - record |
| [ext-V122-record.md](ext-V122-record.md) | Unit V122 (the macOS session's two DOS fixes in the Windows civ64.exe; version 1.2.2) - record |
| [ext-WL-record.md](ext-WL-record.md) | Extension unit WL (windowless play) - record |
| [ext-WL2-record.md](ext-WL2-record.md) | Extension unit WL2: windowless play revisions (both graphics) |
| [ext-WL3-record.md](ext-WL3-record.md) | Extension unit WL3: windowless play on the whole window (both graphics), version 1.2 |
| [ext-WL4CRT3-record.md](ext-WL4CRT3-record.md) | Extension units WL4 and CRT3 (the Windows menu skin in windowless play; the double-scanned CRT scanlines) - record |
| [ext-WL5-record.md](ext-WL5-record.md) | Extension unit WL5 (the user's menu background image in windowless play) - record |
| [ext-ZS-record.md](ext-ZS-record.md) | Unit ZS (two more map zoom steps; Zoom out / Zoom in one step each) - record |
| [p47b-record.md](p47b-record.md) | Record: base-track unit P47b (P47-R2 review fixes; the list-dialog stall on exposure) |
| [p47r2-record.md](p47r2-record.md) | Record: base-track fix RV4 P47-R2 (list dialogs show their border and scroll bar when they open) |

### Hand-offs between sessions

| Document | Title |
|---|---|
| [EXT-HANDOFF.md](EXT-HANDOFF.md) | Hand-off prompt: civ64 extension (scaling, zoom, DOS profile) |
| [NEXT-SESSION-E4.md](NEXT-SESSION-E4.md) | Hand-off prompt for session E4 (civ64 extension: scaling, zoom, DOS profile) |
| [NEXT-SESSION-E5.md](NEXT-SESSION-E5.md) | civ64 extension: hand-off from session E4 to the next session |

### The DOS program (dos/)

| Document | Title |
|---|---|
| [dos/CORRESPONDENCE.md](dos/CORRESPONDENCE.md) | DOS to Windows correspondence (extension D0, prompt 6 item 6) |
| [dos/dos-hashes.txt](dos/dos-hashes.txt) |  |
| [dos/DRIVER.md](dos/DRIVER.md) | DOS drivers: loading, calling and function contracts (D0 draft, task D0-A) |
| [dos/EXECUTABLE.md](dos/EXECUTABLE.md) | The DOS executable map (extension D0, prompt 6.1 to 6.3) |
| [dos/FORMATS.md](dos/FORMATS.md) | DOS data formats |
| [dos/OFFSETS.md](dos/OFFSETS.md) | The offset registry of the DOS data tables (extension D2) |
| [dos/OPEN.md](dos/OPEN.md) | DOS recovery: open questions (extension D0, prompt 6 items 5 and 7) |
| [dos/PALETTE.md](dos/PALETTE.md) | DOS palettes, fades and cycling (extension D0, prompt 6 item 5, task D0-E1) |
| [dos/SCENES-PLAY.md](dos/SCENES-PLAY.md) | DOS play screen and full-screen scenes (extension D0, prompt 6.5, play part) |
| [dos/SCENES.md](dos/SCENES.md) | DOS start-up and UI scenes (extension D0, prompt 6 item 5, task D0-E1) |
| [dos/SPRITES.md](dos/SPRITES.md) | DOS sprites: which picture rectangles become which shapes (extension D0, prompt 6.5) |
| [dos/TIMING.md](dos/TIMING.md) | DOS clock and presentation timing (extension phase D0, task D0-B) |
| [dos/WINDOWS-INVENTORY.md](dos/WINDOWS-INVENTORY.md) | Windows inventory for the DOS profile (D0, draft) |

### Phase-0 inventories (inventory/)

| Document | Title |
|---|---|
| [inventory/apis.md](inventory/apis.md) | Inventory: imported Win16 APIs and call sites |
| [inventory/div-shift.md](inventory/div-shift.md) | Inventory: divisions and shifts |
| [inventory/eval-order.md](inventory/eval-order.md) | Inventory: evaluation-order hazards |
| [inventory/float.md](inventory/float.md) | Inventory: floating-point sites |
| [inventory/liveness.md](inventory/liveness.md) | Inventory: function liveness |
| [inventory/out-of-range.md](inventory/out-of-range.md) | Inventory: out-of-range and out-of-object sites |
| [inventory/pointer-handle.md](inventory/pointer-handle.md) | Inventory: pointer-, code-pointer- and handle-typed data |
| [inventory/pseudo-intrinsics.md](inventory/pseudo-intrinsics.md) | Inventory: pseudo-intrinsics |
| [inventory/runtime-calls.md](inventory/runtime-calls.md) | Inventory: run-time library functions called by the game |
| [inventory/stack-locals.md](inventory/stack-locals.md) | Inventory: stack-resident locals and register variables |
| [inventory/uninit.md](inventory/uninit.md) | Inventory: uninitialised-value sites (findings 8.2) |

### Reviews, verifier reports and briefs (verify/)

| Document | Title |
|---|---|
| [verify/BRIEF-annotate.md](verify/BRIEF-annotate.md) | Inputs |
| [verify/BRIEF-bs.md](verify/BRIEF-bs.md) | Design note: unit BS (Birth screen-by-screen synchronisation) |
| [verify/BRIEF-cy.md](verify/BRIEF-cy.md) | Brief: unit CY (faster build-and-test cycle without dropping any test) |
| [verify/BRIEF-d0-fixes.md](verify/BRIEF-d0-fixes.md) | Brief for the D0 fixers (extension phase D0, after the independent review) |
| [verify/BRIEF-d0-review.md](verify/BRIEF-d0-review.md) | Brief for the D0 independent review (extension phase D0 gate) |
| [verify/BRIEF-d1-review.md](verify/BRIEF-d1-review.md) | Brief for the D1 independent design review |
| [verify/BRIEF-d1.md](verify/BRIEF-d1.md) | Brief for the D1 design agents (extension phase D1) |
| [verify/BRIEF-d2.md](verify/BRIEF-d2.md) | Brief for the D2 implementer (extension phase D2: DOS assets) |
| [verify/BRIEF-d3.md](verify/BRIEF-d3.md) | Brief for the D3 implementers (extension phase D3) |
| [verify/BRIEF-d4.md](verify/BRIEF-d4.md) | Brief for the D4 implementers (extension phase D4: credits, intro, title, Birth, pointer) |
| [verify/BRIEF-d5.md](verify/BRIEF-d5.md) | Brief for the D5 implementers (extension phase D5: setup screens, title branches, their R re-skins) |
| [verify/BRIEF-d6.md](verify/BRIEF-d6.md) | Brief for the D6 implementers (extension phase D6: play in the DOS profile, class A, menus, zoom) |
| [verify/BRIEF-d6fsc.md](verify/BRIEF-d6fsc.md) | Unit D6fSc: the DOS boxes' line breaks and widths (rework) |
| [verify/BRIEF-d6fsd.md](verify/BRIEF-d6fsd.md) | Unit D6fSd: the DOS game's own texts and places for the remaining boxes (follow-up of D6fSc) |
| [verify/BRIEF-d7.md](verify/BRIEF-d7.md) | Brief for the D7 implementers (extension phase D7: every remaining N and R scene) |
| [verify/BRIEF-e5rev.md](verify/BRIEF-e5rev.md) | Brief: units CRT2, D7g3, WL2 and PUB2 (the user's directions of 2026-10-18 about 23:20 UTC) |
| [verify/BRIEF-extras.md](verify/BRIEF-extras.md) | Brief: the user's three extra features (after the final Asan pass) |
| [verify/BRIEF-hm.md](verify/BRIEF-hm.md) | Brief: unit HM, the host window menu with submenus (the user's interim task) |
| [verify/BRIEF-m.md](verify/BRIEF-m.md) | Brief for the M implementers (extension phase M: map renderer and zoom, Windows profile) |
| [verify/BRIEF-mac.md](verify/BRIEF-mac.md) | Brief: the macOS build of civ64 (unit series MAC), from release v1.2.1 |
| [verify/BRIEF-p47b.md](verify/BRIEF-p47b.md) | Brief: base-track unit P47b (P47-R2 review fixes; list-dialog stall on exposure) |
| [verify/BRIEF-p47r2.md](verify/BRIEF-p47r2.md) | Brief: base-track fix RV4 P47-R2 (list dialogs show their scroll bar when they open) |
| [verify/BRIEF-pub.md](verify/BRIEF-pub.md) | Brief: publication (unit PUB), after the session-end hash check, the STATUS row and the hand-off |
| [verify/BRIEF-round10.md](verify/BRIEF-round10.md) | Your units and items |
| [verify/BRIEF-round11.md](verify/BRIEF-round11.md) | Your units and items |
| [verify/BRIEF-round12.md](verify/BRIEF-round12.md) | Your units and items |
| [verify/BRIEF-round2.md](verify/BRIEF-round2.md) | Your units |
| [verify/BRIEF-round3.md](verify/BRIEF-round3.md) | Your units |
| [verify/BRIEF-round4.md](verify/BRIEF-round4.md) | Your units |
| [verify/BRIEF-round5.md](verify/BRIEF-round5.md) | Your work |
| [verify/BRIEF-round6.md](verify/BRIEF-round6.md) | Your units |
| [verify/BRIEF-round7.md](verify/BRIEF-round7.md) | Your units and items |
| [verify/BRIEF-round8.md](verify/BRIEF-round8.md) | Your units and items |
| [verify/BRIEF-round9.md](verify/BRIEF-round9.md) | Your units and items |
| [verify/BRIEF-ux1.md](verify/BRIEF-ux1.md) | Brief: unit UX1 (DOS pointer size; host close, Alt+F4 and Exit with a warning) |
| [verify/BRIEF-wl.md](verify/BRIEF-wl.md) | Brief: unit WL, the windowless play mode (design note, the implementer's proposal) |
| [verify/ext-d0-fixes-r1.md](verify/ext-d0-fixes-r1.md) | D0 fixes for review R1 (fixer F1) |
| [verify/ext-d0-fixes-r2.md](verify/ext-d0-fixes-r2.md) | D0 fixes for review R2 (F2) |
| [verify/ext-d0-fixes-r3.md](verify/ext-d0-fixes-r3.md) | D0 fixes for review R3 (F3) |
| [verify/ext-d0-review-r1.md](verify/ext-d0-review-r1.md) | D0 review R1: executable, driver, timing and the tools |
| [verify/ext-d0-review-r2.md](verify/ext-d0-review-r2.md) | D0 review R2: formats, palette, sprites and the viewers |
| [verify/ext-d0-review-r3.md](verify/ext-d0-review-r3.md) | D0 review R3: scenes, inventory, correspondence, profile tables and open items |
| [verify/ext-d0-review.md](verify/ext-d0-review.md) | D0 independent review: index and resolutions |
| [verify/ext-d1-decisions.md](verify/ext-d1-decisions.md) | D1: the orchestrator's resolutions of the design drafts' conflicts |
| [verify/ext-d1-draft-A.md](verify/ext-d1-draft-A.md) | D1 draft A: observer, probes, read-only queries, presentation tick, profile switching, P0 tests |
| [verify/ext-d1-draft-B.md](verify/ext-d1-draft-B.md) | D1 draft B: composition, shadow surfaces, logical replay, classes, palette rule, text and fonts |
| [verify/ext-d1-draft-C.md](verify/ext-d1-draft-C.md) | D1 draft C: DOS clock, timelines, scene sequencing, adapters and the input filter |
| [verify/ext-d1-draft-D.md](verify/ext-d1-draft-D.md) | D1 draft D: the map renderer and zoom (phase M, backlog) and the DOS map (D6) |
| [verify/ext-d1-draft-E.md](verify/ext-d1-draft-E.md) | D1 draft, area E: DOS assets at run time (phase D2) |
| [verify/ext-d1-review-rv1.md](verify/ext-d1-review-rv1.md) | D1 design review RV1: areas A, D and E |
| [verify/ext-d1-review-rv2.md](verify/ext-d1-review-rv2.md) | D1 design review RV2: areas B and C, and the interfaces between all areas |
| [verify/ext-d1-review.md](verify/ext-d1-review.md) | D1 independent design review: index and resolutions |
| [verify/ext-d4a-review-2.md](verify/ext-d4a-review-2.md) | D4a second review: shadow, compose, scene, font map, profile (independent, read-only) |
| [verify/ext-d4a-review.md](verify/ext-d4a-review.md) | D4a DOS-fidelity review (independent, read-only) |
| [verify/ext-d4c-review.md](verify/ext-d4c-review.md) | D4c review: area C filter, adapter table, DOS mouse conversion, pending translations (independent, read-only) |
| [verify/ext-x0-review.md](verify/ext-x0-review.md) | X0 adversarial review: civ64 extension prompt (`claude/docs/x64-port-scaling-dos-prompt.md`) |
| [verify/p47r2-review.md](verify/p47r2-review.md) | Review: base-track fix RV4 P47-R2 (list dialogs show their border and scroll bar when they open) |
| [verify/phase4-review-1.md](verify/phase4-review-1.md) | Phase-4 review 1: P4-1 (mouse routing), P4-2 (non-client drawing), F13 (record wording) |
| [verify/phase4-review-2.md](verify/phase4-review-2.md) | Phase-4 review 2: P4-3 (menu tracking), F14 (review-1 fixes), P4-4 (scroll-bar tracking) |
| [verify/phase4-review-3.md](verify/phase4-review-3.md) | Phase-4 review 3: P4-5 (system commands, window states), F15 (review-2 fixes), P4-6 (MessageBox) |
| [verify/phase4-review-4.md](verify/phase4-review-4.md) | Phase-4 review 4: F16 (review-3 fixes), P4-7 (list boxes, statics, DIBs) |
| [verify/phase5-message-tables.md](verify/phase5-message-tables.md) | Phase 5 gate review: the message tables (P5-5) |
| [verify/phase7-bringup.md](verify/phase7-bringup.md) | Phase 7: bring-up in civ64 windows and oracle comparisons |
| [verify/phase8-audit-A.md](verify/phase8-audit-A.md) | Phase 8 audit A: items 1 (Build), 2 (Assets), 10 (Usage), no original bytes, host isolation |
| [verify/phase8-audit-B.md](verify/phase8-audit-B.md) | Phase 8 audit B: items 3 (Features), 5 (Files), 9 (Fidelity register) |
| [verify/phase8-audit-C.md](verify/phase8-audit-C.md) | Phase 8 audit C: section 4 items 4 (Rules), 6 (Original bugs), 7 (No UB), 8 (Traceability) |
| [verify/round10-R10A.md](verify/round10-R10A.md) | Round 10 (2026-10-09): member — R10A review of the G-2 change (F10-07) |
| [verify/round10-R10B.md](verify/round10-R10B.md) | Round 10, batch R10B: member (F10-07, round9-R9A.md G-2) |
| [verify/round10-R10C.md](verify/round10-R10C.md) | Round 10 verifier R10C: record items without a unit |
| [verify/round11-R11A.md](verify/round11-R11A.md) | Round 11 (2026-10-09): fix — R11A review of F11 |
| [verify/round12-R12A.md](verify/round12-R12A.md) | Round 12 (2026-10-09): fix — R12A review of F12 |
| [verify/round3-casts.md](verify/round3-casts.md) | Round 3 (2026-10-09): listing-value casts (W3, parts A and C) |
| [verify/round3-findings-sites.md](verify/round3-findings-sites.md) | Round 3 (2026-10-09): review of the findings-site generator change (W4) |
| [verify/round5-fixes.md](verify/round5-fixes.md) | Round 5 fixes (fixer F5) |
| [verify/round6-findings-sites.md](verify/round6-findings-sites.md) | Verification: gen/findings_sites.py round-5 entries |
| [verify/round6-fixes.md](verify/round6-fixes.md) | Round 6 fixes (fixer F6) |
| [verify/round7-fixes.md](verify/round7-fixes.md) | Round 7 fixes (fixer F7) |
| [verify/round7-R7D.md](verify/round7-R7D.md) | Round 7 verification, batch R7D |
| [verify/round8-fixes.md](verify/round8-fixes.md) | Round 8 fixes (F8) |
| [verify/round8-R8A.md](verify/round8-R8A.md) | Round 8 (2026-10-09): translator review, batch R8A |
| [verify/round8-R8D.md](verify/round8-R8D.md) | Round 8 verification, batch R8D: items without a single unit |
| [verify/round8-R8E.md](verify/round8-R8E.md) | Round 8 verification, batch R8E |
| [verify/round9-R9A.md](verify/round9-R9A.md) | Round 9, batch R9A: ix3 (F8-15, round8-R8D.md G-1) |
| [verify/round9-R9B.md](verify/round9-R9B.md) | Round 9 verifier R9B: F8 items without a unit |
| [verify/round9-R9C.md](verify/round9-R9C.md) | Round 9 verification, batch R9C: fix F8-16..F8-24 |
| [verify/seg002_1008.md](verify/seg002_1008.md) | Verification: seg002_1008 (re-verification 2026-10-08, after the translator fixes) |
| [verify/seg002_1008_r.md](verify/seg002_1008_r.md) | Verification: seg002_1008_r (round 5, batch V16) |
| [verify/seg002_1008_s.md](verify/seg002_1008_s.md) | Verification: seg002_1008_s (re-verification 2026-10-08, round 2) |
| [verify/seg003_1010.md](verify/seg003_1010.md) | Verification: seg003_1010 (round 5, first verification; verifier V23) |
| [verify/seg003_1010_r.md](verify/seg003_1010_r.md) | Verification: seg003_1010_r (round 5, first verification; verifier V34) |
| [verify/seg004_1018.md](verify/seg004_1018.md) | Verification: seg004_1018 (2026-10-08, phase 3a start-up slice) |
| [verify/seg004_1018_r.md](verify/seg004_1018_r.md) | Verification: seg004_1018_r (round 5, first verification; verifier V18) |
| [verify/seg004_1018_r2.md](verify/seg004_1018_r2.md) | Verification: seg004_1018_r2 (round 5, verifier V29) |
| [verify/seg005_1020.md](verify/seg005_1020.md) | Verification: seg005_1020 (re-verification 2026-10-08, after the translator fixes) |
| [verify/seg005_1020_r.md](verify/seg005_1020_r.md) | Verification: seg005_1020_r (round 5, verifier V40) |
| [verify/seg006_1028.md](verify/seg006_1028.md) | Verification: seg006_1028 (re-verification 2026-10-08, after the translator fixes) |
| [verify/seg006_1028_r.md](verify/seg006_1028_r.md) | Verification: seg006_1028_r (round 5, first verification; verifier V23) |
| [verify/seg007_1030_p1.md](verify/seg007_1030_p1.md) | seg007_1030_p1 — ProcessCity (1030:0000): unit summary |
| [verify/seg007_1030_p1.part1.md](verify/seg007_1030_p1.part1.md) | Verification: seg007_1030_p1 part 1 — ProcessCity 1030:0000..1030:1E99 (round 5, V06) |
| [verify/seg007_1030_p1.part2.md](verify/seg007_1030_p1.part2.md) | Verification: seg007_1030_p1, ProcessCity range 2 of 4 (round 5, V07, 2026-10-09) |
| [verify/seg007_1030_p1.part3.md](verify/seg007_1030_p1.part3.md) | Verification: seg007_1030_p1 part 3 (round 5, V08; first verification) |
| [verify/seg007_1030_p1.part4.md](verify/seg007_1030_p1.part4.md) | Verification: seg007_1030_p1 part 4 (round 5, V05; first verification) |
| [verify/seg007_1030_p2.md](verify/seg007_1030_p2.md) | Verification: seg007_1030_p2 (round 5, first verification 2026-10-09, V27) |
| [verify/seg007_1030_p2_r.md](verify/seg007_1030_p2_r.md) | Verification: seg007_1030_p2_r (round 5, first verification; verifier V38) |
| [verify/seg007_1030_p3.md](verify/seg007_1030_p3.md) | Verification: seg007_1030_p3 (round 5, verifier V19) |
| [verify/seg008_1038.md](verify/seg008_1038.md) | Verification: seg008_1038 — whole unit 1038:0000..1038:107C (round 5, V24) |
| [verify/seg009_1040_p1.md](verify/seg009_1040_p1.md) | Verification: seg009_1040_p1 (round 5, first verification; verifier V25) |
| [verify/seg009_1040_p2.md](verify/seg009_1040_p2.md) | Verification: seg009_1040_p2 (round 5, verifier V01) |
| [verify/seg009_1040_p2_r.md](verify/seg009_1040_p2_r.md) | Verification: seg009_1040_p2_r (round 5, verifier V32) |
| [verify/seg010_1048.md](verify/seg010_1048.md) | Verification: seg010_1048 (round 5, batch V15) |
| [verify/seg011_1050_p1.md](verify/seg011_1050_p1.md) | Verification: seg011_1050_p1 (round 5, first verification; verifier V36) |
| [verify/seg011_1050_p1_r.md](verify/seg011_1050_p1_r.md) | Verification: seg011_1050_p1_r (round 5, first verification; verifier V23) |
| [verify/seg011_1050_p2.md](verify/seg011_1050_p2.md) | Verification: seg011_1050_p2 (2026-10-08, phase 3a start-up slice) |
| [verify/seg011_1050_p2_r.md](verify/seg011_1050_p2_r.md) | Verification: seg011_1050_p2_r (round 5, first verification; verifier V39) |
| [verify/seg011_1050_t.md](verify/seg011_1050_t.md) | Verification: seg011_1050_t (first verification 2026-10-08) |
| [verify/seg013_1060.md](verify/seg013_1060.md) | Verification: seg013_1060 (round 5, verifier V37, whole unit) |
| [verify/seg014_1068_p1.md](verify/seg014_1068_p1.md) | Verification: seg014_1068_p1 (round 5, batch V16) |
| [verify/seg014_1068_p2.md](verify/seg014_1068_p2.md) | Verification: seg014_1068_p2 (re-verification 2026-10-08, round 2) |
| [verify/seg014_1068_p2_r.md](verify/seg014_1068_p2_r.md) | Verification: seg014_1068_p2_r (round 5, first verification; verifier V36) |
| [verify/seg015_1070_p1.md](verify/seg015_1070_p1.md) | Verification: seg015_1070_p1 (round 5, verifier V37, whole unit) |
| [verify/seg015_1070_p1_r.md](verify/seg015_1070_p1_r.md) | Verification: seg015_1070_p1_r (round 5, verifier V26) |
| [verify/seg015_1070_p2.md](verify/seg015_1070_p2.md) | Verification: seg015_1070_p2 (round 5, verifier V35) |
| [verify/seg015_1070_p2_r.md](verify/seg015_1070_p2_r.md) | Verification: seg015_1070_p2_r (round 5, verifier V37, whole unit) |
| [verify/seg016_1078_p1.md](verify/seg016_1078_p1.md) | Verification: seg016_1078_p1 (round 5, first verification; verifier V11) |
| [verify/seg016_1078_p2.md](verify/seg016_1078_p2.md) | seg016_1078_p2 — ChooseAiUnitOrder (1078:1480): unit summary |
| [verify/seg016_1078_p2.part1.md](verify/seg016_1078_p2.part1.md) | Verification: seg016_1078_p2 part 1 — ChooseAiUnitOrder 1078:1480..1078:2C89 (round 5, V12) |
| [verify/seg016_1078_p2.part2.md](verify/seg016_1078_p2.part2.md) | Verification V13 (round 5): seg016_1078_p2, part 2 of 2 of ChooseAiUnitOrder |
| [verify/seg016_1078_p3.md](verify/seg016_1078_p3.md) | Verification: seg016_1078_p3 — whole unit 1078:448F..1078:4F0E (round 5, V24) |
| [verify/seg016_1078_p4.md](verify/seg016_1078_p4.md) | Verification: seg016_1078_p4 (round 5, first verification; verifier V38) |
| [verify/seg016_1078_p4_r.md](verify/seg016_1078_p4_r.md) | Verification: seg016_1078_p4_r (round 5, batch V21) |
| [verify/seg017_1080.md](verify/seg017_1080.md) | Verification: seg017_1080 (verifier V20, round 5) |
| [verify/seg017_1080_r.md](verify/seg017_1080_r.md) | Verification: seg017_1080_r (round 5, verifier V40) |
| [verify/seg018_1088_p1.md](verify/seg018_1088_p1.md) | Verification: seg018_1088_p1 (round 5, batch V03) |
| [verify/seg018_1088_p2.md](verify/seg018_1088_p2.md) | Verification: seg018_1088_p2 (round 5; verifier V33) |
| [verify/seg018_1088_p2_r.md](verify/seg018_1088_p2_r.md) | Verification: seg018_1088_p2_r (round 5, first verification; verifier V36) |
| [verify/seg019_1090.md](verify/seg019_1090.md) | Verification: seg019_1090 (re-verification 2026-10-08, after the translator fixes) |
| [verify/seg019_1090_r.md](verify/seg019_1090_r.md) | Verification: seg019_1090_r (round 5, verifier V37, whole unit) |
| [verify/seg019_1090_s.md](verify/seg019_1090_s.md) | Verification: seg019_1090_s (re-verification 2026-10-08, round 2) |
| [verify/seg020_1098_p1.md](verify/seg020_1098_p1.md) | Verification: seg020_1098_p1 (re-verification 2026-10-08, round 2) |
| [verify/seg020_1098_p1_r.md](verify/seg020_1098_p1_r.md) | Verification: seg020_1098_p1_r (round 5, first verification; verifier V36) |
| [verify/seg020_1098_p2.md](verify/seg020_1098_p2.md) | Verification: seg020_1098_p2 (re-verification 2026-10-08, round 2) |
| [verify/seg020_1098_p2_r.md](verify/seg020_1098_p2_r.md) | Verification: seg020_1098_p2_r (round 5, first verification; verifier V04) |
| [verify/seg020_1098_p3.md](verify/seg020_1098_p3.md) | Verification: seg020_1098_p3 (first verification 2026-10-08) |
| [verify/seg021_10A0.md](verify/seg021_10A0.md) | Verification: seg021_10A0 (re-verification 2026-10-08, after the translator fixes) |
| [verify/seg021_10A0_r.md](verify/seg021_10A0_r.md) | Verification: seg021_10A0_r (round 5, batch V16) |
| [verify/seg021_10A0_s.md](verify/seg021_10A0_s.md) | Verification: seg021_10A0_s (re-verification 2026-10-08, round 2) |
| [verify/seg023_10B0_p1.md](verify/seg023_10B0_p1.md) | Verification: seg023_10B0_p1 (re-verification 2026-10-08, round 2) |
| [verify/seg023_10B0_p1_r.md](verify/seg023_10B0_p1_r.md) | Verification: seg023_10B0_p1_r (round 5, verifier V02) |
| [verify/seg023_10B0_p2.md](verify/seg023_10B0_p2.md) | Verification: seg023_10B0_p2 (re-verification 2026-10-08, round 2) |
| [verify/seg024_10B8.md](verify/seg024_10B8.md) | Verification: seg024_10B8 (re-verification 2026-10-08, round 2) |
| [verify/seg025_10C0.md](verify/seg025_10C0.md) | Verification: seg025_10C0 (re-verification 2026-10-08, round 2) |
| [verify/seg026_10C8.md](verify/seg026_10C8.md) | Verification: seg026_10C8 (re-verification 2026-10-08, round 2) |
| [verify/seg027_10D0.md](verify/seg027_10D0.md) | Verification: seg027_10D0 (re-verification 2026-10-08, round 2) |
| [verify/seg027_10D0_r.md](verify/seg027_10D0_r.md) | Verification: seg027_10D0_r (round 5, first verification; verifier V38) |
| [verify/seg027_10D0_t.md](verify/seg027_10D0_t.md) | Verification: seg027_10D0_t (first verification 2026-10-08) |
| [verify/seg028_10D8.md](verify/seg028_10D8.md) | Verification: seg028_10D8 (re-verification 2026-10-08, round 2) |
| [verify/seg028_10D8_r.md](verify/seg028_10D8_r.md) | Verification: seg028_10D8_r (round 5; verifier V33) |
| [verify/seg028_10D8_r2.md](verify/seg028_10D8_r2.md) | Verification: seg028_10D8_r2 (round 5, first verification; verifier V39) |
| [verify/seg030_10E8_p1.md](verify/seg030_10E8_p1.md) | Verification: seg030_10E8_p1 (round 5, verifier V02) |
| [verify/seg030_10E8_p2.md](verify/seg030_10E8_p2.md) | Verification: seg030_10E8_p2 (round 5, verifier V02) |
| [verify/seg030_10E8_p2_r.md](verify/seg030_10E8_p2_r.md) | Verification: seg030_10E8_p2_r (round 5, verifier V01) |
| [verify/seg030_10E8_p3.md](verify/seg030_10E8_p3.md) | Verification: seg030_10E8_p3 (2026-10-08, phase 3a start-up slice) |
| [verify/seg030_10E8_p3_r.md](verify/seg030_10E8_p3_r.md) | Verification: seg030_10E8_p3_r (round 5, batch V03) |
| [verify/seg031_10F0.md](verify/seg031_10F0.md) | Verification: seg031_10F0 (re-verification 2026-10-08, round 2) |
| [verify/seg031_10F0_r.md](verify/seg031_10F0_r.md) | Verification: seg031_10F0_r (round 5, verifier V01) |
| [verify/seg031_10F0_r2.md](verify/seg031_10F0_r2.md) | Verification: seg031_10F0_r2 (round 5, verifier V01) |
| [verify/seg033_1100.md](verify/seg033_1100.md) | Verification: seg033_1100 (re-verification 2026-10-08, after the translator fixes) |
| [verify/seg033_1100_r.md](verify/seg033_1100_r.md) | Verification: seg033_1100_r (round 5, first verification; verifier V38) |
| [verify/seg033_1100_s.md](verify/seg033_1100_s.md) | Verification: seg033_1100_s (re-verification 2026-10-08, round 2) |
| [verify/seg034_1108.md](verify/seg034_1108.md) | Verification: seg034_1108 (2026-10-08, phase 3a start-up slice) |
| [verify/seg034_1108_r.md](verify/seg034_1108_r.md) | Verification: seg034_1108_r (round 5; verifier V33) |
| [verify/seg034_1108_s.md](verify/seg034_1108_s.md) | Verification: seg034_1108_s (2026-10-09, round 4, first verification) |
| [verify/seg035_1110_p1.md](verify/seg035_1110_p1.md) | Verification: seg035_1110_p1 (re-verification 2026-10-08, after the translator fixes) |
| [verify/seg035_1110_p1_r.md](verify/seg035_1110_p1_r.md) | Verification: seg035_1110_p1_r (round 5; verifier V33) |
| [verify/seg035_1110_p1_r2.md](verify/seg035_1110_p1_r2.md) | Verification: seg035_1110_p1_r2 (round 5, first verification; verifier V38) |
| [verify/seg035_1110_p1_s.md](verify/seg035_1110_p1_s.md) | Verification: seg035_1110_p1_s (re-verification 2026-10-08, round 2) |
| [verify/seg035_1110_p2.md](verify/seg035_1110_p2.md) | Verification: seg035_1110_p2 (re-verification 2026-10-08, after the translator fixes) |
| [verify/seg035_1110_p2_r.md](verify/seg035_1110_p2_r.md) | Verification: seg035_1110_p2_r (round 5, first verification; verifier V39) |
| [verify/seg035_1110_p2_s.md](verify/seg035_1110_p2_s.md) | Verification: seg035_1110_p2_s (re-verification 2026-10-08, round 2) |
| [verify/seg037_1120.md](verify/seg037_1120.md) | Verification: seg037_1120 (round 5, first verification; verifier V36) |
| [verify/seg037_1120_r.md](verify/seg037_1120_r.md) | Verification: seg037_1120_r (round 5, first verification; verifier V34) |
| [verify/seg038_1128.md](verify/seg038_1128.md) | Verification: seg038_1128 (re-verification 2026-10-08, after the translator fixes) |
| [verify/seg038_1128_r.md](verify/seg038_1128_r.md) | Verification: seg038_1128_r (round 5, verifier V31) |
| [verify/seg039_1130.md](verify/seg039_1130.md) | Verification: seg039_1130 (round 5, verifier V01, functions 1130:000E, 1130:0075, 1130:0194) |
| [verify/seg039_1130_r.md](verify/seg039_1130_r.md) | Verification: seg039_1130_r (round 5, verifier V37, whole unit) |
| [verify/seg041_1140.md](verify/seg041_1140.md) | Verification: seg041_1140 (re-verification 2026-10-08, after the translator fixes) |
| [verify/seg041_1140_r.md](verify/seg041_1140_r.md) | Verification: seg041_1140_r (round 5, first verification; verifier V04) |
| [verify/seg041_1140_r2.md](verify/seg041_1140_r2.md) | Verification: seg041_1140_r2 (round 5, first verification; verifier V34) |
| [verify/seg044_1158.md](verify/seg044_1158.md) | Verification: seg044_1158 (round 5, batch V03) |
| [verify/seg044_1158_r.md](verify/seg044_1158_r.md) | Verification: seg044_1158_r (round 5, first verification; verifier V28) |
| [verify/seg045_1160_p1.md](verify/seg045_1160_p1.md) | Verification: seg045_1160_p1 (round 5, first verification, V14) |
| [verify/seg045_1160_p2.md](verify/seg045_1160_p2.md) | Verification: seg045_1160_p2 (first verification 2026-10-08) |
| [verify/seg045_1160_p2_r.md](verify/seg045_1160_p2_r.md) | Verification: seg045_1160_p2_r (round 5, first verification 2026-10-09, V27) |
| [verify/seg046_1168.md](verify/seg046_1168.md) | Verification seg046_1168 (round 5, V17) |
| [verify/seg046_1168_r.md](verify/seg046_1168_r.md) | Verification: seg046_1168_r (round 5, first verification; verifier V04) |
| [verify/seg047_1170_p1.md](verify/seg047_1170_p1.md) | Verification: seg047_1170_p1 (round 5, verifier V02) |
| [verify/seg047_1170_p1_r.md](verify/seg047_1170_p1_r.md) | Verification: seg047_1170_p1_r (round 5, first verification; verifier V39) |
| [verify/seg047_1170_p2.md](verify/seg047_1170_p2.md) | Verification: seg047_1170_p2 (round 5, batch V15) |
| [verify/seg047_1170_p3.md](verify/seg047_1170_p3.md) | Verification: seg047_1170_p3 (2026-10-08, phase 3a start-up slice) |
| [verify/seg047_1170_p3_r.md](verify/seg047_1170_p3_r.md) | Verification: seg047_1170_p3_r (round 5, verifier V40) |
| [verify/seg047_1170_p3_r2.md](verify/seg047_1170_p3_r2.md) | Verification: seg047_1170_p3_r2 (verifier V20, round 5) |
| [verify/seg048_1178.md](verify/seg048_1178.md) | Verification: seg048_1178 (round 5, verifier V40) |
| [verify/seg048_1178_r.md](verify/seg048_1178_r.md) | Verification: seg048_1178_r (round 5, verifier V32) |
| [verify/seg049_1180_p1.md](verify/seg049_1180_p1.md) | Verification: seg049_1180_p1 (round 5, first verification; verifier V38) |
| [verify/seg049_1180_p1_r.md](verify/seg049_1180_p1_r.md) | Verification: seg049_1180_p1_r (round 5, first verification; verifier V28) |
| [verify/seg049_1180_p2.md](verify/seg049_1180_p2.md) | Verification: seg049_1180_p2 (round 5, first verification; verifier V34) |
| [verify/seg049_1180_p2_r.md](verify/seg049_1180_p2_r.md) | Verification: seg049_1180_p2_r (round 5, first verification; verifier V11) |
| [verify/seg050_1188_p1.md](verify/seg050_1188_p1.md) | Verification: seg050_1188_p1 (round 5; verifier V30) |
| [verify/seg050_1188_p1_r.md](verify/seg050_1188_p1_r.md) | Verification: seg050_1188_p1_r (round 5, verifier V35) |
| [verify/seg050_1188_p2.md](verify/seg050_1188_p2.md) | Verification: seg050_1188_p2 (round 5, first verification; verifier V25) |
| [verify/seg050_1188_p2_r.md](verify/seg050_1188_p2_r.md) | Verification: seg050_1188_p2_r (round 5, first verification; verifier V22) |
| [verify/seg051_1190_p1.md](verify/seg051_1190_p1.md) | Verification: seg051_1190_p1 (re-verification 2026-10-08, round 2) |
| [verify/seg051_1190_p2.md](verify/seg051_1190_p2.md) | Verification: seg051_1190_p2 (2026-10-08, phase 3a start-up slice) |
| [verify/seg051_1190_p2_r.md](verify/seg051_1190_p2_r.md) | Verification: seg051_1190_p2_r (round 5, batch V03) |
| [verify/seg053_11A0.md](verify/seg053_11A0.md) | Verification: seg053_11A0 (round 5, verifier V40) |
| [verify/seg053_11A0_r.md](verify/seg053_11A0_r.md) | Verification: seg053_11A0_r (round 5, verifier V29) |
| [verify/seg054_11A8_p1.md](verify/seg054_11A8_p1.md) | Verification: seg054_11A8_p1 (re-verification 2026-10-08, round 2) |
| [verify/seg054_11A8_p1_r.md](verify/seg054_11A8_p1_r.md) | Verification: seg054_11A8_p1_r (round 5, batch V16) |
| [verify/seg054_11A8_p2.md](verify/seg054_11A8_p2.md) | Verification: seg054_11A8_p2 (re-verification 2026-10-08, round 2) |
| [verify/seg054_11A8_t.md](verify/seg054_11A8_t.md) | Verification: seg054_11A8_t (first verification 2026-10-08) |
| [verify/seg055_11B0_p1.md](verify/seg055_11B0_p1.md) | Verification: seg055_11B0_p1 — DrawCityViewRoadTile .. DrawCityViewBuilding 11B0:115C..11B0:1315 (round 5, V24) |
| [verify/seg055_11B0_p1_r.md](verify/seg055_11B0_p1_r.md) | Verification: seg055_11B0_p1_r (round 5, batch V21) |
| [verify/seg055_11B0_p2.md](verify/seg055_11B0_p2.md) | Verification: seg055_11B0_p2 (round 5; verifier V30) |
| [verify/seg055_11B0_p2_r.md](verify/seg055_11B0_p2_r.md) | Verification: seg055_11B0_p2_r (round 5, verifier V35) |
| [verify/seg056_11B8_p1.md](verify/seg056_11B8_p1.md) | Verification: seg056_11B8_p1 (round 5, first verification; verifier V39) |
| [verify/seg056_11B8_p1_r.md](verify/seg056_11B8_p1_r.md) | Verification: seg056_11B8_p1_r (round 5, verifier V19) |
| [verify/seg056_11B8_p2.md](verify/seg056_11B8_p2.md) | Verification: seg056_11B8_p2 (round 5, verifier V32) |
| [verify/seg057_11C0_p1.md](verify/seg057_11C0_p1.md) | Verification: seg057_11C0_p1 (round 5, verifier V29) |
| [verify/seg057_11C0_p1_r.md](verify/seg057_11C0_p1_r.md) | Verification: seg057_11C0_p1_r (round 5, first verification; verifier V38) |
| [verify/seg057_11C0_p2.md](verify/seg057_11C0_p2.md) | Verification: seg057_11C0_p2 (re-verification 2026-10-08, after the translator fixes) |
| [verify/seg057_11C0_p2_r.md](verify/seg057_11C0_p2_r.md) | Verification: seg057_11C0_p2_r (round 5, verifier V26) |
| [verify/seg057_11C0_p2_r2.md](verify/seg057_11C0_p2_r2.md) | Verification: seg057_11C0_p2_r2 (round 5, first verification; verifier V39) |
| [verify/seg057_11C0_p2_s.md](verify/seg057_11C0_p2_s.md) | Verification: seg057_11C0_p2_s (2026-10-08, phase 3a start-up slice) |
| [verify/seg057_11C0_p3.md](verify/seg057_11C0_p3.md) | Verification seg057_11C0_p3 (round 5, V17) |
| [verify/seg057_11C0_p4.md](verify/seg057_11C0_p4.md) | Verification: seg057_11C0_p4 (re-verification 2026-10-08, after the translator fixes) |
| [verify/seg057_11C0_p4_r.md](verify/seg057_11C0_p4_r.md) | Verification: seg057_11C0_p4_r (round 5, first verification; verifier V25) |
| [verify/seg057_11C0_p4_s.md](verify/seg057_11C0_p4_s.md) | Verification: seg057_11C0_p4_s (2026-10-08, phase 3a start-up slice) |
| [verify/seg060_11D8.md](verify/seg060_11D8.md) | Verification: seg060_11D8 (round 5, first verification; verifier V22) |
| [verify/seg061_11E0.md](verify/seg061_11E0.md) | Verification: seg061_11E0 (re-verification 2026-10-08, round 2) |
| [verify/seg061_11E0_r.md](verify/seg061_11E0_r.md) | Verification: seg061_11E0_r (round 5, verifier V02) |
| [verify/seg062_11E8.md](verify/seg062_11E8.md) | Verification: seg062_11E8 (re-verification 2026-10-08, after the translator fixes) |
| [verify/seg062_11E8_r.md](verify/seg062_11E8_r.md) | Verification: seg062_11E8_r (round 5, first verification; verifier V39) |
| [verify/seg062_11E8_r2.md](verify/seg062_11E8_r2.md) | Verification: seg062_11E8_r2 (round 5, batch V21) |
| [verify/seg062_11E8_s.md](verify/seg062_11E8_s.md) | Verification: seg062_11E8_s (re-verification 2026-10-08, round 2) |
| [verify/seg063_11F0_p1.md](verify/seg063_11F0_p1.md) | seg063_11F0_p1 — MoveCivUnits (11F0:0000): unit summary |
| [verify/seg063_11F0_p1.part1.md](verify/seg063_11F0_p1.part1.md) | Verification: seg063_11F0_p1 part 1 — MoveCivUnits 11F0:0000..11F0:219B (round 5, V09) |
| [verify/seg063_11F0_p1.part2.md](verify/seg063_11F0_p1.part2.md) | Verification: seg063_11F0_p1, MoveCivUnits range 2 of 2 (round 5, V10, 2026-10-09) |
| [verify/seg063_11F0_p2.md](verify/seg063_11F0_p2.md) | Verification: seg063_11F0_p2 (round 5, first verification; verifier V38) |
| [verify/seg063_11F0_p2_r.md](verify/seg063_11F0_p2_r.md) | Verification: seg063_11F0_p2_r (round 5, verifier V35) |
| [verify/seg063_11F0_t.md](verify/seg063_11F0_t.md) | Verification: seg063_11F0_t (first verification 2026-10-08) |
| [verify/seg064_11F8.md](verify/seg064_11F8.md) | Verification: seg064_11F8 (2026-10-08, phase 3a start-up slice) |
| [verify/seg064_11F8_r.md](verify/seg064_11F8_r.md) | Verification: seg064_11F8_r (round 5, first verification; verifier V18) |
| [verify/seg064_11F8_r2.md](verify/seg064_11F8_r2.md) | Verification: seg064_11F8_r2 (round 5; verifier V30) |
| [verify/seg064_11F8_t.md](verify/seg064_11F8_t.md) | Verification: seg064_11F8_t (first verification 2026-10-08) |
| [verify/seg066_1208_p1.md](verify/seg066_1208_p1.md) | Verification: seg066_1208_p1 (re-verification 2026-10-08, round 2) |
| [verify/seg066_1208_p1_r.md](verify/seg066_1208_p1_r.md) | Verification: seg066_1208_p1_r (round 5, verifier V31) |
| [verify/seg066_1208_p2.md](verify/seg066_1208_p2.md) | Verification: seg066_1208_p2 (re-verification 2026-10-08, round 2) |
| [verify/seg066_1208_p2_r.md](verify/seg066_1208_p2_r.md) | Verification: seg066_1208_p2_r (round 5, verifier V31) |
| [verify/seg068_1218.md](verify/seg068_1218.md) | Verification: seg068_1218 (round 5, first verification; verifier V04) |
| [verify/seg069_1220_p1.md](verify/seg069_1220_p1.md) | Verification: seg069_1220_p1 (re-verification 2026-10-08, round 2) |
| [verify/seg069_1220_p1_r.md](verify/seg069_1220_p1_r.md) | Verification: seg069_1220_p1_r (round 5, first verification; verifier V39) |
| [verify/seg069_1220_p2.md](verify/seg069_1220_p2.md) | Verification: seg069_1220_p2 (first verification 2026-10-08) |
| [verify/seg069_1220_p2_r.md](verify/seg069_1220_p2_r.md) | Verification: seg069_1220_p2_r (round 5, first verification; verifier V39) |

### Hash checks of the originals (hashes/)

| Document | Title |
|---|---|
| [hashes/20261008T115412Z-before.txt](hashes/20261008T115412Z-before.txt) |  |
| [hashes/20261010T050021Z-after.txt](hashes/20261010T050021Z-after.txt) |  |
| [hashes/20261010T160323Z-after.txt](hashes/20261010T160323Z-after.txt) |  |
| [hashes/20261010T170031Z-before.txt](hashes/20261010T170031Z-before.txt) |  |
| [hashes/20261010T170101Z-dos-before.txt](hashes/20261010T170101Z-dos-before.txt) |  |
| [hashes/20261011T055556Z-before.txt](hashes/20261011T055556Z-before.txt) |  |
| [hashes/20261011T055556Z-dos-before.txt](hashes/20261011T055556Z-dos-before.txt) |  |
| [hashes/20261011T234307Z-after.txt](hashes/20261011T234307Z-after.txt) |  |
| [hashes/20261011T234307Z-dos-after.txt](hashes/20261011T234307Z-dos-after.txt) |  |
| [hashes/20261012T120301Z-after.txt](hashes/20261012T120301Z-after.txt) |  |
| [hashes/20261012T120301Z-dos-after.txt](hashes/20261012T120301Z-dos-after.txt) |  |
| [hashes/20261012T123144Z-after.txt](hashes/20261012T123144Z-after.txt) |  |
| [hashes/20261012T123144Z-dos-after.txt](hashes/20261012T123144Z-dos-after.txt) |  |
| [hashes/20261015T082010Z-before.txt](hashes/20261015T082010Z-before.txt) |  |
| [hashes/20261015T082010Z-dos-before.txt](hashes/20261015T082010Z-dos-before.txt) |  |
| [hashes/20261017T070311Z-after.txt](hashes/20261017T070311Z-after.txt) |  |
| [hashes/20261017T070311Z-dos-after.txt](hashes/20261017T070311Z-dos-after.txt) |  |
| [hashes/20261017T072114Z-before.txt](hashes/20261017T072114Z-before.txt) |  |
| [hashes/20261017T072114Z-dos-before.txt](hashes/20261017T072114Z-dos-before.txt) |  |
| [hashes/20261018T191151Z-after.txt](hashes/20261018T191151Z-after.txt) |  |
| [hashes/20261018T191151Z-dos-after.txt](hashes/20261018T191151Z-dos-after.txt) |  |
| [hashes/20261019T050854Z-after.txt](hashes/20261019T050854Z-after.txt) |  |
| [hashes/20261019T050854Z-dos-after.txt](hashes/20261019T050854Z-dos-after.txt) |  |
| [hashes/20261022T173443Z-before.txt](hashes/20261022T173443Z-before.txt) |  |
| [hashes/20261022T173443Z-dos-before.txt](hashes/20261022T173443Z-dos-before.txt) |  |
| [hashes/20261022T175154Z-dos-before.txt](hashes/20261022T175154Z-dos-before.txt) |  |
| [hashes/20261023T053431Z-before.txt](hashes/20261023T053431Z-before.txt) |  |
| [hashes/20261023T053431Z-dos-before.txt](hashes/20261023T053431Z-dos-before.txt) |  |
| [hashes/20261023T061622Z-after.txt](hashes/20261023T061622Z-after.txt) |  |
| [hashes/20261023T061622Z-dos-after.txt](hashes/20261023T061622Z-dos-after.txt) |  |
| [hashes/20261023T070929Z-before.txt](hashes/20261023T070929Z-before.txt) |  |
| [hashes/20261023T070929Z-dos-before.txt](hashes/20261023T070929Z-dos-before.txt) |  |
| [hashes/20261023T081355Z-after.txt](hashes/20261023T081355Z-after.txt) |  |
| [hashes/20261023T081355Z-dos-after.txt](hashes/20261023T081355Z-dos-after.txt) |  |

### Screenshots (screenshots/)

| Document | Title |
|---|---|
| [screenshots/Civ64-01-TitleMenu-Windows.png](screenshots/Civ64-01-TitleMenu-Windows.png) |  |
| [screenshots/Civ64-02-TitleMenu-DOS.png](screenshots/Civ64-02-TitleMenu-DOS.png) |  |
| [screenshots/Civ64-03-GameSetup-Windows.png](screenshots/Civ64-03-GameSetup-Windows.png) |  |
| [screenshots/Civ64-04-GameSetup-DOS.png](screenshots/Civ64-04-GameSetup-DOS.png) |  |
| [screenshots/Civ64-05-GamePlay-Windows.png](screenshots/Civ64-05-GamePlay-Windows.png) |  |
| [screenshots/Civ64-06-GamePlay-DOS.png](screenshots/Civ64-06-GamePlay-DOS.png) |  |
| [screenshots/Civ64-07-WindowlessPlay-Windows.png](screenshots/Civ64-07-WindowlessPlay-Windows.png) |  |
| [screenshots/Civ64-08-WindowlessPlay-DOS.png](screenshots/Civ64-08-WindowlessPlay-DOS.png) |  |
| [screenshots/Civ64-09-GamePlay-macOS-Windows.png](screenshots/Civ64-09-GamePlay-macOS-Windows.png) |  |
| [screenshots/Civ64-10-GamePlay-macOS-DOS.png](screenshots/Civ64-10-GamePlay-macOS-DOS.png) |  |
| [screenshots/OnTheFlyGraphicsSwitch.gif](screenshots/OnTheFlyGraphicsSwitch.gif) |  |

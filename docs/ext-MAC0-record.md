# Unit MAC0 (the toolchain and the headless suite on macOS) - record

## Result

The port's portable layers, test programs and harness build on the user's Mac (Mac mini M4, macOS Tahoe 26.6.2,
Apple clang 21.0.0) with the same strictness as on Windows, and the headless suite runs there for both halves of the
planned universal binary. The game state, frame and event traces recorded on Windows are reproduced byte for byte on
Apple silicon (arm64) and on Intel (x86_64, under Rosetta 2):

* gate3b: all 24 checkpoint snapshots of S2, S2b, S2c and S3 equal `gate3b-golden.txt` (GATE3B_OK);
* G-1: `ext_g1.py check` gives `EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)` for arm64 Checked,
  arm64 CheckedNoObs and x86_64 Checked - the same 77 runs, the same single amendment as on Windows;
* every section of `test.cmd` that runs on macOS passes: Checked (arm64 and x86_64), CheckedNoObs and Release (arm64),
  and Asan (arm64; see "Results").

No portable source changed. The changes are new macOS build and test scripts and small, Windows-neutral hooks in
the test tooling (see "Changes").

## The user's words

2026-10-22 (BRIEF-mac.md, "The user's text"): develop and release a macOS binary of civ64 from v1.2.1, signed with
the user's developer account, not over the Mac App Store. Decisions of 2026-10-22 about 17:40 UTC: native AppKit;
universal, macOS 13 or later; the player's own vgasys.fon; gh installed. About 18:00 UTC: "Yes, install capstone and
numpy with pip --user for the system Python."; "Skip the CIV_UNP.EXE checks for now (record them as not run) and start
MAC0." (CIV_UNP.EXE then arrived from the user's Windows project, so nothing was skipped.)

## Changes

New (macOS only):

* `build-mac.sh` - the counterpart of `build.cmd`: the generation steps; the portable layers with `-std=c11` and
  `-std=c17` (`-Wall -Wextra -Werror -pedantic`) and a C99 parse (`-std=c99 -pedantic -Werror`; Apple clang's front end
  in place of Visual Studio's clang-tidy); the 64 test programs; the harness (Checked, CheckedNoObs, Asan); variants
  Release, Checked, `checked noobs`, Asan (`-fsanitize=address`); `--arch arm64|x86_64`; outputs under
  `build/macos/<arch>/<Variant>/`. Compiler options chosen for MSVC's semantics: `-ffp-contract=off` (no fused
  multiply-add, which Apple clang uses on arm64 and `/fp:precise` does not), `-fno-strict-aliasing` and `-fwrapv`
  (MSVC optimizes on neither; the port is meant to need neither, final report item 7). The harness's 16 MiB stack as
  `/STACK:16777216`. (Since MAC1 it also builds `Civ64.app`.)
* `test-mac.sh` - the counterpart of `test.cmd`: the same 31 sections in the same order with the same commands,
  run in parallel through `testpar.py` (serial for Asan), logs under `build/test-mac/<arch>/<Variant>/`. Differences:
  the Win32 back end's `w32_test_*` programs have no macOS counterpart yet (the macOS back end's tests come with it);
  `--arch x86_64` runs the Intel half under Rosetta 2; `WINDIR` points at `build/winfonts` (the user's own
  `vgasys.fon`, git-ignored); the shared output folders `build/run`, `build/harness/game` and `build/frames` are made
  first (a Windows tree has them from earlier runs; the harness makes only the last level); a disk guard stops a run
  below `CIV_TEST_MIN_FREE_MB` (default 2048) of free space.
* `tests/posix/` - the Microsoft C run-time names the test programs use (`_open`, `_stat`, `_findfirst`, `_mkdir`,
  `_fullpath`, `_get_pgmptr`, `_stricmp` ...) over POSIX, force-included into the test programs and the harness only.
  Paths built with '\' are converted to '/'; directory listings come back in NTFS's order (upper-case names);
  `pc_clonefile` makes the harness's per-run copies of the data directory APFS clones (the same bytes, no new space).
* `tests/harness/hostbin.py` - where a variant's programs are: Windows `build/x64/<variant>/<name>.exe` (unchanged),
  macOS `build/macos/<arch>/<variant>/<name>` (`CIV_ARCH`).
* `tests/harness/run-scenario.sh` - the macOS twin of `run-scenario.cmd`.

Changed (Windows behaviour unchanged; not re-run on Windows in this unit):

* 16 harness scripts find the harness through `hostbin.program(BUILD, variant, "civ_harness")` instead of
  `BUILD / "x64" / variant / "civ_harness.exe"` (the same path on Windows).
* `testpar.py`: a `.sh` section list (`# @section` lines, `sec_NAME()` functions, a process group per section, a
  SIGTERM handler on macOS); the `.cmd` path is unchanged.
* `gate3b.py`, `uninit.py`: on macOS `run-scenario.sh` with an argument list; on Windows `run-scenario.cmd` as before.
* `gen/dos/nodos.py`: also scans `build/macos/<arch>/<variant>/` (absent on Windows).
* `tests/headless/host_headless.c`: the coverage file of a program without an extension (on Windows every program has
  `.exe`, so the name is unchanged).
* `tests/headless/harness.c`: `copy_file` tries an APFS clone first under `__APPLE__`.
* `tests/test_crt.c`: `crt6_show`'s `screen` buffer from 1280 x 800 to 2726 x 1600 bytes (the overflow below).

## Setup on this Mac (BRIEF-mac.md "Starting point")

* The user's game files: `CIVWIN.zip` and `civdos.zip` from `~/Downloads`, extracted to the read-only references
  `original/CIVWIN` (38 of 38 pinned) and `dos/` (176 of 176 with `CIV_UNP.EXE` from the user's Windows project);
  working copies `build/gamedata`, `build/dosdata`; records `docs/hashes/20261022T173443Z-*` and
  `20261022T175154Z-dos-before.txt`.
* The user's `VGASYS.FON` (7,280 bytes, SHA-256 `7baefa14...646f8`) as `build/winfonts/Fonts/vgasys.fon`.
* Python: the system's 3.9.6; `capstone` 5.0.9 and `numpy` 2.0.2 with `pip --user`; `gen/dos/disasm.py` made the DOS
  listings (DISASM_OK, 695 functions).

## Findings

* **The system font matters to the goldens.** Without `vgasys.fon`, `test_user` failed 18 of 365 checks (captions,
  menu bar, list rows: SYSTEM_FONT text had no glyphs) and gate3b-s3's `after-setup` and `turn` snapshots differed
  (the setup dialogs' layout is game state). With the user's file both pass. The Windows goldens were recorded with
  Windows 11's `vgasys.fon`; the user's copy reproduces them.
* **Disk.** A full Checked run writes several GB (a first run filled the disk: 4.4 GB of harness outputs, 2.1 GB of
  per-run data copies, 0.6 GB of frame dumps; deleted with the user's consent). APFS clones remove the data copies'
  share; the disk guard prevents a repeat.
* **A test's own buffer overflow, found by clang's AddressSanitizer.** `crt6_show` in `tests/test_crt.c` gave the
  presentation a static `screen` of 1280 x 800 bytes, and its CRT6 case "a windowless canvas 1706x1066" made the
  Windows profile convert 1706 x 1066 bytes of it: 794,596 bytes read past its end. The product is not involved (the
  real virtual screen is w16's, sized for the game screen). MSVC's AddressSanitizer did not report it on Windows
  (evidently no guard zone after that static array); clang's did. The buffer is now 2726 x 1600, the largest game
  screen (host.h); `test_crt` passes (62 checks) under ASan. This is the one change to a test's code.
* **A test-runner start-up race, not a port difference.** In the first full run `uninit`, `scenarios` and `p4tests`
  failed within 4 s: `uninit.py` still called `cmd`, and the two others write into `build/harness/game`, which a fresh
  tree lacks. Both fixed (above); the three sections then passed.

## Results

| Run | Result | Wall |
|---|---|---|
| build-mac.sh Checked, CheckedNoObs, Release, Asan (arm64), Checked (x86_64) | BUILD_OK; 313 portable sources pass c11, c17 and the C99 parse unchanged | 12..19 s each |
| test-mac.sh checked (arm64) | 31 sections; GATE3B_OK; P4_SCENARIOS_OK (108 of 108 rows); P4_TESTS_OK; UNINIT_OK; P0, frames, timeline, continue, aspect, BS, adapt, slots, TLD, FCE, DBL, WL, mirror, replay, zoom OK; TRACE_OK; REGISTRY_OK; NODOS_OK | see the full re-run below |
| ext_g1.py check (arm64 Checked) | EXT_G1_OK runs 77 (amended 1) | |
| test-mac.sh checked noobs (arm64) + ext_g1 | TESTS_OK; EXT_G1_OK runs 77 | 68.6 s |
| test-mac.sh release (arm64) | TESTS_OK | 50.1 s |
| test-mac.sh checked --arch x86_64 (Rosetta 2) + ext_g1 | TESTS_OK (31 sections, 0 failed); EXT_G1_OK runs 77 | 1,324.1 s |
| test-mac.sh asan (arm64, serial), first pass | TESTS_FAILED=1: one AddressSanitizer report, a global-buffer-overflow in `present_frame_from_indexed` reached from `tests/test_crt.c` (below) | 324 s |
| test-mac.sh asan (arm64, serial), after the fix | TESTS_OK; no AddressSanitizer report | 322 s |
| test-mac.sh checked (arm64), the full re-run after the fixes, + ext_g1 | TESTS_OK (31 sections, 0 failed); EXT_G1_OK runs 77 (amended 1) | 993.1 s |

## Not covered

* The Windows build was not rebuilt or re-run with the changed test tooling (no Windows machine in this session);
  every change keeps the Windows path or command as it was, by construction.
* The Win32 back end's tests (`w32_test_*`) have no macOS counterpart yet; the macOS back end's own tests are MAC1's.

# Phase 8 audit A: items 1 (Build), 2 (Assets), 10 (Usage), no original bytes, host isolation

Method: static review of `claude/port` sources, docs and the retained logs; read-only Python (run
from stdin, `-B`) over the Release `civ64.exe` (PE header, imports, resources, byte scans against
the 38 files of `build/gamedata`). Nothing was built, run or launched. `scripts\Setup-Msvc.cmd` is
outside the allowed paths, so toolset facts come from the PE. Disclosure: early on I wrote a
helper `pe_imports.py` into the `p8` scratch folder and deleted it at once; every later script
ran from stdin.

## Verdicts

| Item | Verdict |
|---|---|
| 1 Build | MET WITH CAVEATS |
| 2 Assets | MET WITH CAVEATS |
| 10 Usage | MET WITH CAVEATS |
| Cross-cutting: no original bytes in port sources / built binary | MET (code, tests, Release binary); caveat on docs (A9) |
| Section 2.3 host isolation (win32 / win64 back end) | MET WITH CAVEATS (static only) |

No BLOCKER, no MAJOR. Eleven MINOR findings below.

## Item 1: Build

Evidence checked myself:
* `build.cmd:30` `CFLAGS=/nologo /c /W4 /WX /permissive- /fp:precise /MT /O2 /Zi /wd4702 ...`;
  `:32` `LFLAGS=/nologo /DEBUG /WX`; `:29` the only `/wd` is 4702. DESIGN.md section 1 (line 78) records
  exactly `/wd4702` ("kept by rules 6.7/6.8"). No other `/wd` anywhere in the port
  (`grep "wd[0-9]{4}"`); no `#pragma warning`, `NOLINT`, `-Wno-` in `core rt platform win64`.
  `_CRT_SECURE_NO_WARNINGS` is a command-line define (`:19`). No `/fp:fast`.
* Three checks per portable file: `build.cmd:70` `/std:c11`, `:76` `/std:c17` (same flags),
  `:82` clang-tidy `--checks=-*,clang-diagnostic-*,modernize-use-nullptr --warnings-as-errors=*
  ... -- -std=c99 -pedantic -Wall -Wextra`, preceded by the `--list-checks` guard (`:56`;
  `build/tidy-checks.txt` shows "Enabled checks: modernize-use-nullptr", not "No checks enabled").
  Loop covers `platform\w16\*.c`, `rt\*.c`, `core\*.c`, `core\gen\*.c`; I counted 33 + 17 + 171 + 5 = 226
  files, equal to "portable sources checked: 226" in `p7/b-release.log`, `b-checked.log`, `b-asan.log`.
* Current Release build (`p7/b-release.log`): `BUILD_OK variant=Release`; `build/link-civ64.log` holds only
  the "performing full link" note; `cl-*.log`/`tidy.log` empty apart from the last file name.
* Binary facts from `build/x64/Release/civ64.exe`: Machine 0x8664, GUI subsystem, linker 14.51
  (VS 18 toolset), PE time stamp 2026-10-10 15:04:14 UTC (matches the 15:04 Release build), imports
  only KERNEL32, USER32, GDI32, WINMM, SHELL32 (no VCRUNTIME/UCRT DLLs, so `/MT` is real).
* Forbidden constructs: grep for `_Static_assert`, `_Alignas`, `_Generic`, `__declspec`, `__asm`,
  `__builtin`, `long long`, `alloca` etc. in `core rt platform/w16` finds nothing; `<windows.h>` appears
  only in `platform/win32`, `win64`, `tests/win32` (and a comment in `platform/w16/host_sync.c:49`).

Findings:

* **A1 (MINOR) Include rule broken in portable `platform/w16`.** `platform/w16/user_menutrack.c:102`
  and `platform/w16/user_misc.c:36` include `<stdio.h>` (only for `snprintf`, lines 714 and 460).
  Prompt section 1 and DESIGN.md line 61 allow only `<stdint.h> <stddef.h> <string.h> <limits.h>`
  (`<math.h>` in rt). The three compile checks cannot catch this and no exception is recorded.
  Fix: format by hand (rt has `rt_sprintf`-style code) or record the exception in DESIGN.md.
* **A2 (MINOR) Retained test logs do not evidence the delivered Release binary.**
  `build/test-release.log`, `test-checked.log`, `test-asan.log` are the 2026-10-08 logs (file times
  20:24..20:28 local; 17 test programs, no `w32_`, no harness scenarios), not the "current Release
  build" logs. `p7` has `t-checked.log` and `t-asan.log` (both show `test_host_win32: PASS (101 checks)`,
  `TESTS_OK`) but no `t-release.log`. The only Release test artefacts (`build/test/Release/ne.jsonl`
  16:37, `w32-exit.txt` 16:41 local = 13:37..13:41 UTC) predate the Checked build (14:41 UTC) and the final
  Release link (15:04 UTC). `phase-7-acceptance.md` ("2026-10-10 14:4x..15:04 UTC; Release built again
  last ... TESTS_OK in all three") and the last row of the `STATUS.md` table "Last build and test results" therefore mislabel the
  time of the Release test run, and the 15:04 `civ64.exe` itself was never put through `test.cmd`.
  Mitigation I verified: no hand-written source changed after 16:41 local (only generator outputs
  rewritten by `build.cmd` at 18:01 and two `tests/win32/*.py` drivers). Fix: re-run `test.cmd` on the
  final Release build and keep `t-release.log` (or correct the times).
* **A3 (MINOR) The C99 parse is weaker than its record suggests (hedged: clang behaviour, not run).**
  (a) The command (same as the prompt's) has no `--header-filter`, so clang warnings located in headers
  (`core/acc.h`, generated `civ_layout.h`, `w16_int.h`) are by default not reported; MSVC `/W4 /WX`
  does cover headers. (b) With no `-target`/`-fno-ms-extensions` clang runs in its default
  Windows-MSVC mode, which accepts MS extensions silently. (c) No negative control is recorded in
  `phase-1-acceptance.md` or anywhere (a deliberately non-C99 input that must fail). DESIGN.md
  section 1 says the headers "are covered through the generated .c files". Fix: record a negative
  control; consider `--header-filter=.*`.
* **A4 (MINOR) Log evidence is thin / noisy.** Every build log begins with `'vswhere.exe' is not
  recognized as an internal or external command` (`p7/b-*.log` line 1, `build/test-3a-*.log`); the
  records call the build "clean" and never explain it (the line comes from `scripts\Setup-Msvc.cmd`,
  which I may not read; the PE shows the intended 14.51 toolset was used). `build.cmd` also overwrites
  `cl-c11.log`, `cl-c17.log`, `tidy.log` per file, so the "current logs" only name the last file
  (`civ_unported.c`); per-file cleanliness rests on `/WX` and `BUILD_OK`, not on a log. Fix: state this in
  `phase-6-acceptance.md`, or keep an append-mode log.

## Item 2: Assets

Evidence:
* `win64/civ64_main.c:75-87`: default data dir = folder of the exe (`GetModuleFileNameW`);
  `civ64_open_data` runs before the window exists; any failure -> `fail()` -> MessageBox, `ExitProcess(2)`.
* `win64/civ64_start.c:101-177`: `GetFullPathNameW`, trailing separators trimmed, `hw_refused_dir`
  (`platform/win32/host_win32.c:163-180`: case-insensitive suffix `\original\CIVWIN`, `/` folded),
  directory exists / readable, `civ.exe` opened, size must equal `CIV_EXE_SIZE` 832512, whole file read
  into memory, `sha256_hex` compared with `CIV_EXE_SHA256`
  (`platform/w16/sha256.h:26-27` = `a66ec640...1788`, equal to the prompt and to
  `claude/docs/original-hashes-before.txt:7`). The verified buffer is the one given to `ne_parse`
  (`civ64_main.c:95`), so civ.exe cannot change between check and use.
* Every other original file is read by `host_file_open` through `path_of`/`hw_valid_relpath`
  (relative, no drive, no `..`, no leading separator) rooted at `g_datadir`; the only other host file
  read is `Fonts\vgasys.fon` (`host_win32.c:824-858`), which the prompt allows.
* Tests `tests/win32/test_host_win32.c:558-589`: refused original path (textual, nonexistent
  `C:\x\original\CIVWIN`), missing dir, empty dir, size 8 bytes, one flipped byte (SHA-256 message),
  accepted copy with trailing separator; case/separator variants at lines 59-62. `test_sha.c:53` checks
  the pinned hash on the test copy. `build/test/{Checked,Asan}` contain the `w32-*` side-effect dirs.
  Phase 6 also records an agent-observed run of civ64 on a changed `civ.exe` (message text, exit 2).

Findings:
* **A5 (MINOR) "Canonical path" is only a text suffix.** Prompt 2.3 says "canonical path ends in
  `\original\CIVWIN`". `hw_refused_dir` tests the `GetFullPathNameW` string only, which does not resolve
  junctions, symlinks, hard-linked directories or `subst` drives. `subst X: ...\original\CIVWIN` or a
  junction to it passes the check and civ64 would then write `civ.prf`/saves/`famehall.civ` into the
  original directory. Tests only use a nonexistent text path. Fix: resolve with
  `GetFinalPathNameByHandleW` on an opened directory handle before the suffix test, add a junction
  test, or additionally refuse a directory containing the original's read-only marker files.
* **A6 (MINOR) Sandbox lets DOS device names through.** `hw_valid_relpath` (`host_win32.c:182-200`)
  rejects `..`, drive colons, leading separators and wildcards but not `CON`, `PRN`, `AUX`, `NUL`,
  `COMn`, `LPTn` (also with an extension). The in-memory Save dialog (`choice_proc`, lines 923-941)
  accepts any 1..12 printable ASCII name, so a name such as `COM1` reaches `CreateFileW` and, on Windows,
  names the device even inside a directory. Contradicts "Nothing writes ... outside the run's data
  directory" in spirit (user-chosen, low risk). Test `test_files` covers only `..\ESCAPE.DAT`. Fix: reject
  reserved names in `hw_valid_relpath` and test them.
* Not a defect, for the record: only `civ.exe` is hash-verified (all the prompt asks); the `.rsc`,
  `.fon` and `.wav` files are trusted. DESIGN.md (the "Tests" bullet of "Win32 back end") still says
  "(98 checks)"; the current count is 101 (stale, nit).

## Item 10: Usage (`docs/RUNNING.md`)

Compared with prompt item 10:
* Requirements: present (Windows 10/11 x64, user's own files, pinned civ.exe, hash quoted); extra
  honest requirement: host `Fonts\vgasys.fon`.
* Command line: `civ64.exe [--data <dir>] [--scale auto|1|2|3] [--timing classic|host]
  [--dump-frames <dir>]` is identical to `civ64_parse_args` (`civ64_start.c:56-99`) and to
  `civ64_start.c:4`; defaults (scale auto, timing host, data = exe folder) match the code;
  `--seed-time` etc. are refused (test line 551) as the doc says.
* Port-level failures: the list in "When civ64 stops" matches `civ64_main.c` (exit 2 for option, data
  dir, civ.exe, dump dir, system font, DIB `hw_create_window` -1, window -2, NE load), `host_fault` exit 3
  (`host_win32.c:118-129`), `host_alloc` exit 4 (`:92-100`). Link to FIDELITY.md present. "Files written"
  table present. The statement "contains no original bytes ... local and unpublished" is supported (see below).

Findings:
* **A7 (MINOR) Wrong replay file name in "Files written".** `RUNNING.md:74` lists `REPLAY.REP`. In the
  game the replay name is chosen by the player in "Name your replay file:" with a default of the first
  8 alphanumerics of the leader name + `.rep` (`claude/src/c/seg048_1178.c:318-327`). `REPLAY.REP` is just
  the answer the test scenario injects (`tests/harness/scenarios.py:545,661`). Fix: "`<name>.rep`, named in
  the Save dialog".
* **A8 (MINOR) Font and DIB failure branches are overstated in the gate record.** Prompt item 10 names
  "font or DIB creation failure". (a) The only font check is `civ64_check_fonts`
  (`civ64_start.c:192-202`), which tests that `vgasys.fon` bytes can be read. A readable but unparseable
  file passes, then `w16_font_reset` (`gdi_font.c:225-230`) only calls `host_log` and falls back to "the
  first added face": no message box, no exit. (b) No test can fail it: `test_host_win32.c:325` accepts an
  absent font and `:621` only checks that `civ64_check_fonts` agrees with `host_system_font`. (c) The DIB
  (`hw_create_window` -1), window (-2), "civ.exe could not be loaded" and out-of-memory (exit 4) branches are
  never exercised by any test or recorded run. `phase-6-acceptance.md` row "Command line and port-level
  failures" says "met" and lists these functions as methods; its Labels block does say only the refused
  `civ.exe` was agent-observed, but the row does not say the others are unexercised. Fix: parse-check the
  system font in `civ64_check_fonts`, add a fault-injection seam for the DIB/window branches, or label them
  "reviewed, not exercised".
* **A9 (MINOR) Default `--timing` differs from the prompt and is not in the register.** Prompt 5.5
  "Classic timing mode (the default)"; the port defaults to `host` (`civ64_start.c:60`, RUNNING.md line 43,
  DESIGN.md section 6 item 5). The doc is consistent with the code, but `FIDELITY.md` (F12 covers poll costs
  only) and `STATUS.md` "User directions" do not record this as a deviation from the prompt's default, and
  the user direction cited (generation at full speed) does not decide the default. Fix: add a FIDELITY row
  and mark it pending the user, as was done for selector reuse (DESIGN 3.1).
* **A10 (MINOR) Minimum Windows build and Help behaviour are not stated.** (a) `civ64.exe` imports
  `GetDpiForWindow` and `AdjustWindowRectExForDpi` (USER32, Windows 10 1607+) and its manifest asks for
  PerMonitorV2 (1703+); "Windows 10 or 11" is too broad, older Win10 builds fail at load with an OS error,
  not a civ64 message. (b) The prompt (5.5 "Help") wants the Help menu to show a message box explaining
  that help is unavailable. `w16_WinHelp` (`platform/w16/user_misc.c:446-465`) only writes `host_log` and
  returns 1; FIDELITY F84 records "no help is shown" as a choice and RUNNING.md says only "Help ... is not
  available", so the user will see a dead menu entry. This is a functional deviation (item 3/9 owners:
  MENU 128 Help command), recorded but not flagged as contradicting the prompt.

## Cross-cutting: no original bytes

Checks (all mine):
* Byte scan: 173,656 distinct 32-byte chunks (aligned stride 32, at least 8 distinct byte values)
  from all 38 files of `build/gamedata` against every offset of the Release `civ64.exe`. 204 hits, all in
  one place: a `0x80..0xFF` incrementing ramp in `.rdata` (a code-page table of the CRT). After excluding
  arithmetic-ramp chunks: **0 hits**, i.e. no shared run of 63 or more bytes. (Release binary only; the
  Checked/Asan binaries were not scanned.)
* `civ64.exe` resources: only RT_MANIFEST (1,411 bytes); no icon, cursor, dialog, bitmap, font, wave.
  No `.rc/.ico/.cur/.bin/.dat/.fon/.rsc/.wav/.SAV/.bmp/.png/.hlp` file under `claude/port` outside `build/`.
  File types there: `.c .h .py .md .script .txt .cmd .manifest .json .marks .map .in`.
* Sources: no run of 16 or more numeric literals in `core rt platform win64` except the SHA-256 constants
  (`sha256.c:8,71`); `tests/test_rt.c` has hand-written qsort vectors. Core string literals: 1,419 distinct,
  1,410 are checked-build instrumentation names ("Function param") and 9 are `#include` names; no game
  text. Original strings are read from the image (`DSTR(0xOOOO)`); the RTL message texts appear in
  `rt/rt_exit.c`/`rt_start.c` only in comments next to image addresses. No hex/base64 blob over 66 chars in
  docs, tests or gen. `claude/port` is untracked (`git ls-files claude/port` = 0) and `build/` is ignored
  (`.gitignore:32`, `git check-ignore`).
* The 1,410 instrumentation strings and the 808 global names in `core/gen/civ_gtable.c` are
  reconstruction names and offsets from `names.json`, not original data.

Finding:
* **A11 (MINOR) Docs republish original text.** `docs/inventory/strings.md` (117 KB) lists 1,001 original
  string literals with their full text and image addresses ("Earthquake in ", "Citizens demand GRANARY.",
  "Sorry! Only one game at a time!", ...); `docs/verify/seg009_1040_p1.md:136-161` and others quote game text,
  and `tests/harness/*.script`/`p4tests.py` quote short dialog phrases in comments. Prompt 2.3 lists
  "strings" among original bytes and says the port "and its sources" contain none. The inventory is what
  prompt phase 0 asks for ("string literals with addresses") but the texts are not required. No record
  states an exception. Fix: drop the Text column (keep address and length/hash) or record the exception.

## Section 2.3 host isolation (static)

* Registry / INI / clipboard: no call in `platform/win32`, `win64`, `platform/w16`, `rt`, `core`;
  `civ64.exe` imports no ADVAPI32. The three imports that look risky (`LoadLibraryExW`, `GetProcAddress`,
  `SetEnvironmentVariableW`) are not referenced in port sources; they come from the static CRT (cannot be
  proved statically which CRT routine pulls them). The system file dialog is not used (in-memory
  template, `host_win32.c:954-1043`), avoiding its registry MRU.
* `LoadLibrary("WIN87EM")`: emulated, never loads a host library (`rt/rt_start.c:18,260-271`).
* WM_FONTCHANGE: the game's `SendMessage(HWND_BROADCAST ...)` is handled inside `w16_SendMessage`
  (`platform/w16/user_wnd.c:3435-3449`), walking the emulated desktop's children only; no Win32
  `SendMessage` is imported.
* `SetKeyboardState`/`GetKeyboardState` act on the emulated array (`platform/w16/queue.c:32,603`); no
  `keybd_event`, `SendInput`, `GetKeyState`, `SetCursorPos`, `ClipCursor` in the import table; NumLock
  stays emulated.
* Fonts: `vgasys.fon` and `civfonts.fon` are read into memory; no `AddFontResource*` in the back end.
* Options: only `civ64_parse_args`; no `getenv`/`GetEnvironmentVariable` in port code.
* Files: only `host_file_*` (data dir, `hw_valid_relpath`, see A6) and `dump_frame` (the `--dump-frames`
  dir); `DeleteFileW` only in `host_file_delete`. Sound: `PlaySoundW(... SND_FILENAME|SND_NODEFAULT ...)`
  on a data-dir path (`host_win32.c:793-808`); `host_beep` uses `MessageBeep(MB_OK)` (host sound scheme,
  no state change).
* Gaps: A5 (refused-directory check), A6 (device names). Not verifiable statically: what the static CRT
  and Windows itself touch at run time.

## Other observations (outside my items, for the owners)

* Prompt 5.5 "Verification": the raster-font engine is to be verified pixel-identical to GDI with
  `AddFontResourceEx(FR_PRIVATE)`. `grep AddFontResourceEx|FR_PRIVATE|pixel-identical` over the port finds
  nothing, and `FIDELITY.md` has no font row (host `vgasys.fon`, SHA-256 `7baefa14...` on this machine per
  the Checked harness log, is a host dependency; the comparison with the Win 3.1 VGA system font that
  prompt 5.5 asks to record is not found).
* `win64` ships no icon or resource script (prompt section 5 layout "own icon, resource script"):
  `hw_create_window` calls `LoadIconW(hInstance, 1)` (`host_win32.c:1213`) but `civ64.exe` has no icon
  resource, so the window gets the default icon. Not recorded in DESIGN or FIDELITY (MINOR).
* The hash records in `docs/hashes/` are two files (2026-10-08 11:54Z before, 2026-10-10 05:00Z after);
  the phase-8 re-hash belongs to the final report.

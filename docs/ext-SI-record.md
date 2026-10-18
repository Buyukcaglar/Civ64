# Extension unit SI (civ64 runs as a single instance) - record

Unit SI of the "civ64" extension makes civ64 a single-instance program (STATUS.md "User directions", row
"2026-10-16 about 19:44"). Session E3, 2026-10-16. Host only. Staged in `build/si-stage/` (the orchestrator's
staging protocol); bases taken 19:54 UTC from the tree after MZW's landing (RELEASE_OK 19:12 UTC), before MZI's.
UX5 landed meanwhile (copy-in 20:28:06 UTC) and changed one comment sentence of `win64/civ64_main.c`: SI's blocks
were re-applied onto UX5's copy at 21:22 UTC (that file's base now, `BASE-SHA256.txt`). SI was first reported
READY_TO_BUILD at 21:25 UTC with the original's refusal box left out (Decision 9 as then staged); the orchestrator
then decided Decision 9: follow the original. MZI landed meanwhile (copy-in 21:29:09 UTC, RELEASE_OK 22:18:42 UTC)
and changed no file SI stages or calls. The second staging (this record) shows the original's box; its overlay was
made at 21:37 UTC from the tree after UX5 and MZI (bases re-checked then and at 22:40 UTC: unchanged; the overlay's
folders equal the tree's at 22:40 UTC except SI's five files), so every private build, test and real check of
"Results" ran on it.

Labels:

* **compiled**: `build.cmd checked`, `build.cmd checked noobs` and `build.cmd` (Release) of a private overlay
  (`obj/mkoverlay.py`: the tree's source folders with the staged files on top, `obj/src`), each with `--nogen` by
  `obj/b.cmd` / `obj/ball.cmd`: strict C17/x64 (`/W4 /WX /permissive- /fp:precise`), `/std:c11` and `/std:c17` and
  the clang-tidy C99 parse of every portable source, the test programs, the harness, civ64.exe and the
  Win32-headless tests; every output under the overlay's own `build/`.
* **headless** and **Win32-headless**: the overlay's `test_*.exe` and `w32_test_*.exe` (test.cmd's `unit` loop,
  `obj/ut.cmd`), argv[1] `build/gamedata` (read), argv[2] under the stage; hidden windows, quiet mode.
* **real check**: `obj/rc/si_check.exe` (`obj/rc/si_check.c`) with real civ64.exe processes, each on a desktop of
  its own (never on the user's screen), section "Results".

Scope: no DOS program was executed; nothing was written to `C:\Projects\Civ1RE\dos`, `C:\Projects\Civ1RE\original`,
`build/dosdata`, `build/gamedata`, `build/x64`, `build/harness`, `%LOCALAPPDATA%\civ64` or any other shared output;
build.cmd and test.cmd of the tree were not run; no civ64 window was shown on the user's screen (the real check's
civ64 processes and their boxes ran on their own desktop; the tests' windows are never shown); no git command that
writes was run; no global or low-level hook was installed. Read: only `claude/` (and the MSVC environment set up by
`scripts\Setup-Msvc.cmd` as build.cmd does). Not edited: `core/`, `rt/`, `res/`, `platform/`, `present/`, `build.cmd`,
`test.cmd`, the generated tables and every document other than this record ("For the records").


## Status

At staging: **READY_TO_BUILD** (second report, after the orchestrator's decision on Decision 9). Staged and tested
privately (compiled, headless, Win32-headless, real check; Checked, CheckedNoObs, Release; section "Results");
`civ64_main.c` based on UX5's landed copy; MZI's landing included. Its build slot: the orchestrator's (MZI took the
slot first and landed, RELEASE_OK 22:18:42 UTC). The user's checks SI-1..SI-6 are pending a user build ("si").


## The user's words

STATUS.md "User directions", 2026-10-16 about 19:44 UTC, verbatim:

> "Host application shall only be single instance"

The orchestrator's ruling (its defaults): one civ64 in the user's logon session (a named mutex in `Local\`, a name
unique to civ64); a second ordinary start opens no window, brings the running civ64's main frame to the front
(restored if minimized) and exits with code 0, retrying the window lookup for a short bounded time when the first
has none yet; a running civ64 from another program path: a plain host message box first ("civ64 is already
running from <that folder>", close it before starting this copy), then the activation; an ended or crashed civ64
never blocks the next start; the automated tests' starts never blocked by a civ64 the user has open (an existing
test switch, else one explicit switch the tests pass; never scoped by path); command-line arguments of a second
start ignored by default; the game, both graphics, the saves, the cfg and the window placement unchanged.

The orchestrator's decision on Decision 9 (2026-10-16, after the first READY_TO_BUILD): follow the original. The
same program file shows the original's box: "Sorry! Only one game at a time!", caption "CIVILIZATION Error", the
stop icon, the core's own text from 1008:0070 (taken from the core's data rather than a second copy in host code),
as a plain host message box before civ64.cfg is read; after OK the running civ64 comes forward (restored if
minimized) and the start exits with code 0. The activation after the box is the only deviation from the original,
recorded for FIDELITY with its reason (the user asked for a single instance, and the original's box alone leaves
the running game hidden). Another program file: civ64's box naming the other folder takes the place of the
original's box (one box, never two), then the activation. Everything else as staged.


## Findings

1. **The original game refuses a second game itself.** Civilization for Windows' WinMain (1008:0070..0087), after
   CheckStartupResources and InitApplication: when `hPrevInstance != 0` it shows `MessageBox(NULL, "Sorry! Only one
   game at a time!", "CIVILIZATION Error", MB_ICONHAND)` and returns 0 (InitApplication registers its classes only
   for the first instance, 1098:076C). Under Windows 3.1 a second start of Civilization therefore showed that error
   box and ended; it did not bring the running game forward. In civ64 every process is its own emulated Windows
   3.1: the emulated InitTask gives `hPrevInstance` 0 (`platform/w16/kernel_task.c`, `out->si = 0u`), so that check
   never fires and, before SI, any number of civ64 processes ran side by side. SI does not touch the core: the
   check stays as translated and still never fires; the host shows the same box for it (Decision 9).
2. **Who starts civ64.exe.** Only `tests/win32/drive_civ64.py` (the phase-7 bring-up tool; test.cmd does not run
   it) starts civ64.exe; it passed no test or automation option (`--data`, `--scale 1`, `--timing`,
   `--dump-frames` are ordinary options a player may give too). test.cmd, `tests/harness/ext_g1.py`, `ext_p0.py`,
   `ext_adapt.py` and the other harness scripts, the scenario and smoke runs start `civ_harness.exe` (headless:
   no civ64.exe, no lock); `gen/dos/nodos.py` only reads civ64.exe; the `w32_test_*.exe` programs link
   `civ64_start.obj` but never take civ64's own lock (their own child processes, `test_host_win32`'s
   `--close-*` children, are themselves, not civ64.exe). So SI adds one explicit switch, `--multi-instance`, and
   drive_civ64.py passes it.
3. **civ64's command line** (`civ64_start.c`): `--data <dir>`, `--dos-data <dir|zip|none>`, `--graphics
   windows|dos`, `--zoom default|-1|0|+1`, `--fullscreen`, `--window <W>x<H>`, `--scale auto|1..8`, `--scale-mode
   integer|fit`, `--filter nearest|sharp`, `--aspect square|4:3`, `--timing classic|host`, `--dump-frames <dir>`,
   `--dump-presented <dir>`, and from SI `--multi-instance`. None names a save to load or a file to open (civ64 has
   no file association; saves are loaded through the game's own menu); they choose the data, the graphics, the
   first window and its picture, the clock, and debugging dumps. A second start ignores all of them (Decision 6).
4. **The window to bring forward.** civ64's main frame is the one window of class `Civ64Host`
   (`platform/win32/host_win32.c` `hw_create_window_ex`: created hidden, placed, then shown). Before it exists a
   civ64 may show its own start-up boxes or the Windows file dialog (`civ64_locate.c`: the game's files not found,
   "Civilization for DOS was not found ... Locate it now?"), and while it runs, its own boxes (About, the exit
   warning, "Locate DOS files...") are owned by the frame. The `w32_test_*.exe` programs also make `Civ64Host`
   windows (hidden), so the frame is found by the running civ64's process id, never by its class alone.
5. **Windows' foreground rule.** A process may bring another's window to the front only while it may set the
   foreground itself: a program started by the foreground program (Explorer, when the player double-clicks
   civ64.exe or a shortcut) may; so may a process whose message box the player just answered. The second start
   therefore activates the running civ64 itself, right after its box's OK, and does not ask the running civ64 to
   do it.
6. **Where the original's text is.** The text and the caption are WinMain's DGROUP strings at DS:0056 (31
   characters) and DS:0076 (18 characters) (1008:0077 `push 0056h`, 1008:007B `push 0076h`); nothing else of the
   game uses them. The port's sources hold no text of the original (prompt 2.3, audit A11), and a second start
   never loads civ.exe (it ends before civ64.cfg is read and before the game's files are looked for). So the
   running civ64 reads both strings from its loaded DGROUP image (`mem_rd8`, right after `ne_load`) and publishes
   them beside its process id; the later start shows what it finds there. The test pins their lengths and SHA-256
   (`97a1cb54...c47f80ea` and `b3e67cda...61ce463`, in full in `test_single.c`), not the text.


## Decisions

1. **The lock.** The mutex `Local\civ64.single-instance.{9C2D6E41-7A35-4F08-B1E6-2D84C0F3A957}` (`Local\`: the
   logon session; the name and a fixed GUID unique to civ64). A start creates it (or opens it) and tries to own
   it without waiting: owned (or abandoned by an ended holder: `WAIT_ABANDONED` counts as owned) - this is the
   first civ64, which keeps it to the end of its process; not owned - another civ64 runs. Beside it the holder
   publishes, in the named shared block `...owner` (120 bytes), its process id and its creation time, so a later
   start knows which process to look at, and a process id reused after an ended holder is never taken for it; once
   its civ.exe is loaded it adds the game's refusal text and caption there (Finding 6; each part has its own
   "written" mark, so a reader never takes half-written values). Windows releases the mutex and the block when the
   holder's process ends in any way (normal end, Task Manager, a fault): nothing is ever left behind (the ruling's
   item 4).
2. **The second start ends with code 0** before anything else happens: before civ64.cfg is read, the game's files
   are looked for, a ZIP is extracted, or the window is made (`civ64_main.c`, right after the command line is
   read). It shows one box (Decisions 3 and 9) and after its OK brings the running civ64 forward: restored when
   minimized (`ShowWindowAsync(SW_RESTORE)`, which returns it to its previous state, maximized or full screen
   included), then `SetForegroundWindow` on its last active popup: its open message box or dialog if it has one
   (the exit warning, About), else the frame.
3. **Same or another program file.** The running civ64's program path (`QueryFullProcessImageNameW`) is compared
   with the new start's (`GetModuleFileNameW`): equal ignoring case, or the same file under another name (the same
   volume and file index: a short name, a substituted drive, a link), means the same program: the original's box
   (Decision 9). Otherwise civ64's own box takes its place (one box, never two): `hw_message_box`, caption "Sid
   Meier's Civilization 64bit", the information icon, OK, naming the running program's folder:

   > civ64 is already running from another folder:
   >
   > C:\...\user-builds\mz
   >
   > Close that civ64 before starting this copy. After OK, the running civ64 comes to the front.

   When the running program's path cannot be read, the original's box is shown (no folder to name). One box per
   start.
4. **The bounded wait.** When the holder has not published itself or its texts yet, or has no visible window yet
   (it may be starting), the start looks again every 100 ms for up to 5 s (`CIV64_SI_WAIT_MS`, `CIV64_SI_STEP_MS`).
   The frame is preferred; before the frame exists, another visible top-level window of that process (its start-up
   box or file dialog) is brought forward instead. When 5 s pass without the texts (a holder still at its start-up
   questions: its files not found, its usage box; or still loading), no box is shown and what window there is is
   brought forward. After the box, when 5 s pass without a visible window, the frame found hidden (if any) is
   activated, else nothing. The start ends with code 0 either way.
5. **A running civ64 that ends while the start waits or while its box is open** frees the lock, and the start
   takes it and runs (each step, and the step after the box's OK, tries the lock first). So "Close that civ64",
   then OK, starts this copy; and a start made while the other civ64 is just closing is not lost. (The ruling's
   "After OK, it brings the running one to the front and exits" holds whenever that civ64 still runs after OK.)
6. **The second start's command line is ignored**, including a wrong one (no usage box: its box, then the running
   civ64 comes to the front and the start ends with code 0). A first start with a wrong command line still shows the
   usage box and exits with code 2, as before (it holds the lock until then).
7. **`--multi-instance`**: a start that neither takes nor reads the lock; it runs beside any civ64, and a later
   ordinary start never sees it (it is not the holder and publishes nothing). An option without a value, like
   `--fullscreen`; case matters, as for every civ64 option; it counts only on a command line that is correct as a
   whole. Only the automated tests use it (drive_civ64.py); it is listed in the usage text and RUNNING.md as a test
   option.
8. **No lock possible** (CreateMutex fails, for example a name taken by another kind of object): the start runs.
   A failure never blocks civ64.
9. **The original's box, then the activation** (the orchestrator's decision: follow the original). A second start
   of the same program shows the original's box: the running civ64's published text and caption (Finding 6:
   "Sorry! Only one game at a time!", "CIVILIZATION Error") with the stop icon and an OK button (`MB_OK |
   MB_ICONHAND`, WinMain's `MB_ICONHAND`), through `hw_message_box` - civ64's own host box, as every host message
   (the system's light or dark mode, the icon's sound as MessageBoxW), owned by no window, before civ64.cfg is read.
   After OK it brings the running civ64 forward (Decision 2) and ends with code 0, as the original ends after its
   box. **The one deviation from the original:** the activation after the box. Its reason: the user asked for a
   single instance, and the original's box alone leaves the running game hidden (behind other windows, or
   minimized); "For the records", FIDELITY.

Known limits (deviation candidates, none expected to matter): a civ64 started as another Windows user in the same
session, or a plain start while a civ64 runs elevated ("Run as administrator"), may be refused access to the
other's mutex (the elevated or other user's default security): it then runs as a second civ64 (Decision 8). Another
Windows user's own session has its own `Local\`: each signed-in user can run one civ64. A later start while the
running civ64 has not loaded its civ.exe yet (Decision 4: at its start-up questions) shows no box, since the text
comes from that civ.exe only.


## What was built

* `win64/civ64_start.h`: `Civ64Options.multi_instance`; the block "Extension SI": `CIV64_SI_RUN`/`EXIT`,
  `CIV64_SI_WAIT_MS` 5000, `CIV64_SI_STEP_MS` 100, `CIV64_SI_PATH`, `CIV64_SI_TEXT` 64, `CIV64_SI_CAPTION` 32,
  `CIV64_SI_SWITCH`, the holder `Civ64SiHolder` (process id, program path, text, caption), the operations
  `Civ64SiOps` (acquire, owner, same_program, find, activate, tell with text, caption and box type, sleep),
  `civ64_single_instance` (the decision), `civ64_si_text` (civ64's box's text), `civ64_si_game_texts` (the
  original's text and caption from the loaded DGROUP), `civ64_si_win32` (the Win32 operations, `Civ64SiWin32`) and
  `civ64_si_publish_texts` (the holder adds the texts to its block).
* `win64/civ64_start.c`: `--multi-instance` in `civ64_parse_args` and in the usage text; the block "extension SI":
  the decision, the text, the DGROUP read (DS:0056, DS:0076, by offset: no string of the original in the source),
  and the Win32 operations (mutex, shared block with its two marks, process path and creation time, file identity,
  the window search by process id, the activation, the boxes through `hw_message_box`, `Sleep`).
* `win64/civ64_main.c`: the header paragraph and option; the lock's state `g_si` (file-static: the holder keeps its
  handles to the end); the call right after `civ64_parse_args` (`ExitProcess(0)` on `CIV64_SI_EXIT`); the texts
  published right after `ne_load`; and UX4b's "For the records" comment item (Home among the zoom chords in the
  `--zoom` paragraph), done here since SI stages this file.
* `tests/win32/drive_civ64.py`: `--multi-instance` on its civ64 command line; its docstring.
* `tests/win32/test_single.c` (new): section "Tests".
* This record.

Not changed: `platform/win32/host_win32.c` (`hw_message_box` is used as it is), the core (its WinMain check stays
as translated), the game, both graphics, saves, civ64.cfg and the window placement (a second start reads and writes
none of them), build.cmd and test.cmd (`BUILD-TEST-ADDITIONS.md`: none).


## Tests

`tests/win32/test_single.c` (new; `w32_test_single.exe`, run by test.cmd's `unit` loop in every variant):

* the decision with recorded operations (`test_decision`, 21 checks; the holder's texts there are test strings):
  the first start (the lock, nothing else); the switch (no operation at all, beside a running civ64); no lock
  possible (runs); a second start of the same program (the original's box with the holder's text and caption and
  `MB_OK | MB_ICONHAND`, the lock again, then the window); another program file (civ64's box only, caption and
  information icon, naming the folder, not the program file; then the window); the running civ64 closed while
  either box is open (this start runs, nothing activated); the holder's program unknown (the original's box); the
  texts late (the box when they come); the texts never published (no box; the window after the whole wait); no
  window yet (looked for every 100 ms after the box, activated at the 8th look); never a window (ends after
  5000 ms, 50 waits, nothing activated); a hidden frame only (activated after the whole wait); the holder
  published late; never published (no box, nothing activated); the holder ending during the wait (runs); another
  program file and no window yet (one box only);
* the text (`test_text`, 4): the folder without the program's name, a drive's root, no path, a short buffer;
* the switch (`test_switch`, 10): `--multi-instance` alone and among other options, as `--data`'s value (a value,
  not the switch), with a value (refused), another case (refused); civ64's own lock and block names (only their
  names: the test never takes civ64's lock); every operation set; texts published without the lock: nothing made;
* the original's refusal (`test_game_texts`, 3): `build/gamedata`'s civ.exe loaded (`ne_parse`, `ne_load`);
  `civ64_si_game_texts` gives 31 and 18 characters with WinMain's SHA-256 values;
* the Win32 operations across real processes (`test_processes`, 12): copies of the test program itself as children
  (CREATE_NO_WINDOW; a never shown `Civ64Host` window as the frame; the holders publish test texts as civ64 does
  after `ne_load`) under a lock name of this run only; the activation and the boxes recorded in the children's
  result files (box type, caption, text), not done. A (the first) runs; B, the same program: A's texts as the
  original's box (`MB_ICONHAND`), then A's frame, exit code 0; C, a copy in another folder: civ64's box only
  (`MB_ICONINFORMATION`) naming A's folder, then A's frame; D with `--multi-instance` runs beside A and publishes
  nothing, and a later start still gets A's texts and frame; A killed: the next start (E) runs; E ended normally:
  the next start (F) runs; a start made while F has neither its frame nor its texts yet gets the box and the frame
  when they come; a holder without a frame: the box, then the start ends after the bounded wait with nothing
  activated; no child left.


## Results

Private, 2026-10-16, second staging. The overlay (`obj/mkoverlay.py`, 21:37 UTC) is the tree after UX5's and MZI's
landings with the five staged files on top; the compiled overlay's sources equal the staged files
(`STAGED-SHA256.txt`), and the staged files keep their bases' line endings, LF (`obj/eol.py check`: EOL_OK).

| variant | build (`obj/ball.cmd`: `obj/b.cmd`, build.cmd `--nogen`) | headless + Win32-headless (`obj/ut.cmd`) |
|---|---|---|
| Checked | `BUILD_OK` 21:59:32 UTC; portable sources checked: 294 (c11, c17, c99 parse) | 0 failed (`check_ne.py` errors 0): `w32_test_single` **50** checks; `w32_test_host_win32` 395 |
| CheckedNoObs | `BUILD_OK` 22:12:22 UTC; 294 | 0 failed: `w32_test_single` 50; `w32_test_host_win32` 366 |
| Release | `BUILD_OK` 22:21:24 UTC; 294 | 0 failed: `w32_test_single` 50; `w32_test_host_win32` 395 |

Against the tree's own Checked unit results of MZI's landing cycle (`build/test/Checked/sections/unit.log`,
21:52 UTC) the programs run differ only by the new `w32_test_single`. `w32_test_single` took 17.5..21.8 s alone
(Checked and Release) with the machine at 100% CPU (other units' builds); without its civ.exe part 19.2 s, so the
time is the five bounded 1.5 s waits and the ten child starts under load. Its files under `<outdir>\single` are
removed at its end, and no child of it was left running (checked with tasklist).

`gen/dos/nodos.py check --root <overlay> --variant V --dos <the tree's build/dosdata> --windows <the tree's
build/gamedata>`: `NODOS_OK` for Checked (615 files), CheckedNoObs (615) and Release (614), 0 hits. Not run:
obs_lint, registry, testpar (no observed, registry or test.cmd change), the harness sections, G-1 and P0 (no core,
w16, present or harness change; the build slot's cycle).

**Real check** (`obj/rc/si_check.exe`, `obj/rc/si-check.txt`, 22:37:05..22:37:20 UTC): `SI_CHECK_OK si_check: 17
checks, 0 failed`. Its civ64.exe (`obj/rc/A/civ64.exe`, SHA-256 b5a9ae6c...f174ad90) is the overlay's Release
civ64 relinked with one change, the lock's name (`obj/rc/mkrc.py`, `mkrc.cmd`: "civ64.si-check-private"), so that a
civ64 the user has open was neither seen nor disturbed; `obj/rc/B/civ64.exe` is a copy of it in another folder. Every civ64 ran on a desktop of its own
(CreateDesktop, never the input desktop: nothing appeared on the user's screen) with `--data` a private copy of
`build/gamedata` without the .wav files, `--dos-data none --scale 1`; the check read each later start's box
(caption, and text through its text control) and answered it with OK (BN_CLICKED posted to the box). The five boxes
sounded the system's stop and information sounds (MessageBeep, as MessageBoxW does):
* A1 runs (its `Civ64Host` frame); minimized from the check;
* A2, the same program: no frame, one box: the original's (caption 18 and text 31 characters, WinMain's SHA-256),
  while A1 was still minimized; after OK, exit code 0; A1 restored, its thread's active window A1, A1 still runs;
* A3, the same program with a wrong option (`--scale 99`): the original's box only (no usage box), exit code 0;
* B, the copy in another folder, while A1 runs minimized: one box, civ64's own ("Sid Meier's Civilization 64bit"),
  naming A1's folder; after OK, exit code 0 and A1 restored;
* A4 `--multi-instance`: runs beside A1 with its own frame, above A1;
* A8, the same program while A1 is behind A4, started under the check as its debugger: the original's box, exit
  code 0. Whether A1 comes above A4 cannot be seen on a desktop that is not the input desktop (Windows sets no
  foreground window there at all; the first staging's diagnostics, `si-check-6.txt`; printed as information), so
  "comes to the front" above another program is left to the user's SI-1 (it needs the user's screen);
* A1 killed (TerminateProcess, as a crash): A5 starts and runs (its frame, alive 3 s later); A5 minimized, then
  A6 (debugged): the original's box while A5 was still minimized, exit code 0; A5 restored and its thread's active
  window;
* no civ64 started by the check left running (8 started).
`%LOCALAPPDATA%\civ64` was only read by those civ64 processes (civ64.cfg, as every first start does): its listing
(42 names, sizes and last-write times, `obj/rc/lsla.py`, no file opened) was equal before and after the run
(`lsla-before.txt`, `lsla-after.txt`). The first staging's runs (`si-check-1..6.txt`, `si-check-first.txt`: no box
then) found the same for the lock, the restore and the kill.


## Expected expectation changes

* `w32_test_single`: new, `PASS test_single: 50 checks, 0 failed` in Checked, CheckedNoObs and Release (about
  8..22 s in the `unit` section, by the machine's load).
* Nothing else: no core, w16, present, harness or script change, so every other test program, harness section,
  golden, ext_g1 and P0 stay as at the previous landing's cycle.


## Rebase notes

Shared files and SI's blocks in them (each marked "extension SI"; `civ64_main.c` is based on UX5's landed copy):

* `win64/civ64_start.h`: the header's first paragraph; the member `multi_instance` at the end of `Civ64Options`;
  the block "Extension SI (begin)" .. "(end)" before the final `#endif`.
* `win64/civ64_start.c`: the header's synopsis line and sentence; the usage string's "[--multi-instance]"; the
  `CIV64_SI_SWITCH` case after `--fullscreen` in `civ64_parse_args`; the block at the end of the file.
* `win64/civ64_main.c`: the synopsis line, the "Extension SI" paragraph and the UX4b Home words in the header; the
  file-static `g_si` after `g_aspect_chosen`; the block right after `LocalFree(argv);` in `wWinMain` (it must stay
  before civ64.cfg is read and before any other box or window); the block right after the `ne_load` check (the
  texts published).
* `tests/win32/drive_civ64.py`: the docstring sentence; `"--multi-instance"` at the end of the Popen list.


## Build-slot steps

1. From the port root: check the 4 bases of `build/si-stage/BASE-SHA256.txt` (and that the record and
   `tests/win32/test_single.c` are absent). Any base that changed since: re-apply SI's blocks onto the tree's copy
   ("Rebase notes"), keeping LF (`obj/eol.py check`), and recompile privately (`obj/mkoverlay.py`, `obj/ball.cmd`,
   `obj/ut.cmd src <variant>`) before going on.
2. Copy the 5 staged files into the tree at the same paths (`STAGED-SHA256.txt`); copy this record to
   `docs/ext-SI-record.md`. No build.cmd or test.cmd change.
3. The three-step cycle: `build.cmd checked`, `test.cmd checked`, `C:/Python314/python -B tests/harness/ext_g1.py
   check`; then `build.cmd` (Release).
4. A user build "si" (Release civ64.exe; CIVWIN.zip and civdos.zip as before) with `WHAT-TO-CHECK.txt` from "What
   the user checks"; its "Still open" list from the checklist's pending rows at landing time. The docs pass applies
   "For the records".


## What the user checks

* **SI-1** Start civ64 as usual and, while it runs (on the intro, the title menu or in a game), start it again the
  same way (double-click civ64.exe or its shortcut): the original's message "Sorry! Only one game at a time!"
  appears (title "CIVILIZATION Error", the stop sign, OK); after OK the running civ64 comes to the front, above
  the other windows, no second civ64 opens, and nothing in the running civ64 changes (the game, its graphics, the
  zoom). Try it with civ64 behind another program's window, and with civ64 in full screen (Alt+Enter).
* **SI-2** Minimize civ64 (the title bar's minimize button), then start civ64 again: the original's message "Sorry!
  Only one game at a time!" appears; after OK the running civ64 comes back from the taskbar at its size and place
  (maximized again if it was maximized; full screen if it was) and comes to the front; no second civ64 opens.
* **SI-3** Two folders with this build (copy the whole user-build folder, for example "si" to "si-copy"; a build
  before SI does not check, so an older build beside it still opens a second civ64). With one folder's civ64
  running, start the other folder's civ64.exe: instead of the original's message, one small box "Sid Meier's
  Civilization 64bit" says civ64 is already running from another folder, names the running one's folder, and asks
  to close that civ64 before starting this copy. After OK the running civ64 comes to the front and no second civ64
  opens. Start it again, and this time close the running civ64 while the box is open (its close button, then Exit
  Anyway if a game is in progress), then press OK in the box: now this copy starts.
* **SI-4** Close civ64 (its close button, Alt+F4, or the game's own File > Quit) and start it again at once: it
  starts normally, with no box and no delay.
* **SI-5** While civ64 runs, end it with Task Manager (select "Sid Meier's Civilization 64bit", End task), then
  start civ64 again: it starts normally (a civ64 that ended abnormally never blocks the next start).
* **SI-6** (optional) While civ64 shows one of its own boxes (for example the window menu's About..., or the exit
  warning of a game in progress), start civ64 again: the original's message appears; after OK civ64 comes to the
  front with its box in front of it.


## For the records

For the docs pass (SI edits no document other than this record):

* **RUNNING.md**, "Command line": `[--multi-instance]` in the synopsis; its table row: "A test option: this run
  neither takes nor checks the single-instance lock (below); the automated tests' starts of civ64.exe
  (`tests/win32/drive_civ64.py`) pass it. Players do not need it."; a paragraph **One civ64 at a time** (since SI,
  with the FIDELITY entry below): civ64 runs once per Windows logon session; starting it again shows the original game's
  own message "Sorry! Only one game at a time!" and after OK brings the running civ64 to the front (restored when
  minimized; its open box if it has one); the new start ends with code 0, whatever its command line; when the
  running civ64 is another program file (another folder) civ64's own box says so instead, naming its folder; a civ64
  that has ended, normally or not, never blocks the next start; Decision 5 (closing the other while the box is
  open). "When civ64 stops": a second start ends with code 0. The tests table: a row for `w32_test_single` (the
  decision's cases, the switch, the text, the original's refusal from civ.exe, the processes; the count of
  "Results").
* **FIDELITY.md**, a new entry, unnumbered here (the orchestrator numbers it in the docs pass; F189 was the
  next free number at staging, provisional only: several units are in flight) "one civ64 at a time (`win64/civ64_start.c`
  extension SI; `civ64_main.c`)": what Decisions 1..9 say, **choice**, the user's direction of 2026-10-16 about
  19:44 UTC and the orchestrator's decision on Decision 9; Civilization for Windows refuses a second game itself
  (WinMain 1008:0070: MessageBox(NULL, DS:0056 "Sorry! Only one game at a time!", DS:0076 "CIVILIZATION Error",
  MB_ICONHAND), then it ends; **binary proof**); in civ64 each process is its own emulated Windows 3.1 (InitTask's
  hPrevInstance is 0), so that check never fires, and the host shows the same box with the game's own text and
  caption read from the running civ64's loaded civ.exe (civ64's host box). **Deviation:** only the activation
  after the box (the running civ64 restored and brought to the front); **reason:** the user asked for a single
  instance, and the original's box alone leaves the running game hidden. Also: another program file shows civ64's
  own box naming its folder in place of the original's (one box); a holder that has not loaded civ.exe yet gives
  no box (Decision 4). The known limits (elevated or another user's civ64; `Local\` per session).
* **DESIGN.md** (the host's start-up, section 10 or wherever civ64's start is described): the single-instance
  start before civ64.cfg is read; the holder's published block (process id, creation time, the game's refusal text
  and caption after `ne_load`).
* **manual-checklist-ext.md**: a section "SI: one civ64 at a time" with SI-1..SI-6 ("What the user checks").
* **STATUS.md**: SI's row (the user's 19:44 direction implemented; Decision 9 as the orchestrator decided); the
  D-row or open-items list as the orchestrator keeps it.
* **UX4b's record**, "For the records", item "win64/civ64_main.c comment": done by SI (this unit stages that file).


## Landing (2026-10-16, build slot)

**Landed 2026-10-16 22:42:18 UTC; cycle ALL_GREEN 23:38:15 UTC; RELEASE_OK 23:45:07 UTC; user build
`build/user-builds/si/` (about 23:46 UTC).**  Done by the build slot on the orchestrator's instruction, after MZI's
landing (RELEASE_OK 22:18:42 UTC), with Decision 9 as the orchestrator decided it (the original's box).

1. **Bases.** `build/si-prep/land.py` (6 rows): the 4 tree files still had their bases
   (`build/si-stage/BASE-SHA256.txt`; `civ64_main.c` UX5's landed copy), `tests/win32/test_single.c` and this record
   were absent, and the 6 staged copies had the SHA-256 frozen in `build/si-prep/staged.sha256`; build.cmd and
   test.cmd had their SHA-256 after MZI's landing (40de571d..., e7c5015c...).  Dry run `DRY_RUN_OK 6`.  No rebase was
   needed (MZI shares no file with SI; the private overlay already held MZI's files).
2. **Snapshot and copy.** Before writing: the tree's Checked test outputs (59 files of `build/test/Checked`, MZI's
   cycle) in `build/si-prep/before`, the tree's previous 4 files in `build/si-prep/tree-before`.  The 6 files byte
   for byte (4 changed, the test and this record new): `LANDED 6`; manifest `build/si-prep/landed.sha256` (with
   build.cmd's and test.cmd's unchanged SHA-256); `landed-at.txt`.  No build.cmd or test.cmd change.
3. **Cycle** (`build/si-prep/si-cycle.ps1`; status `build/si-status.txt`, logs `build/si-<n>-<step>.log`):
   - 1 build-checked: exit 0, 696 s, BUILD_OK; portable sources checked 294; no warning.
   - 2 test-checked: exit 0, 2553 s, TESTS_OK, 27 sections, failed 0 (wall 2526.5 s).  `w32_test_host_win32` passed
     at the first run (395 checks): no GetKeyState rerun and no -r2 test step were needed.
   - 3 g1-checked: exit 0, EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events): **ALL_GREEN**.
   - 4 build-release: exit 0, 397 s, BUILD_OK, portable sources 294: **RELEASE_OK**.
4. **Comparison** (`build/si-prep/compare.py`, output `compare.txt`; the predictions in `build/si-prep/predictions.txt`
   were written about 22:41 UTC, before the copy-in; prediction against output in `build/si-prep/comparison.txt`):
   54 of 59 files equal (lines with times left out).  The differences, each as predicted:
   - `sections/unit.log`: `[w32_test_single]` and `PASS test_single: 50 checks, 0 failed`; every other unit result
     equal; the OBS_COST line (host time).
   - `nodos.txt`: 1733 -> 1736 files (the new test, this record, `w32_test_single.exe`), 1546466301 -> 1551282102
     bytes, 0 hits.
   - `coverage.txt` and `sections/coverage.log`: "other functions entered" 670 -> 669 (informational, "may differ"
     in the predictions; SI changes no portable or core code; not identified).
   - `sections/times.txt`: section times (the machine was loaded: wall 2526.5 s against MZI's 2033.0 s).
   Every other output equal: P0_OK checks 476, REGISTRY_OK, NODOS_OK, OBS_TABLES_OK, OBS_LINT_OK files 120 probes 203
   callsites 98, ADAPT_OK, EXT_ASPECT_OK, MIRROR_OK, REPLAY_OK, EXT_FRAMES_OK, EXT_TIMELINE_OK, EXT_CONTINUE_OK,
   EXT_SLOTS_OK, EXT_BS_OK, ext-zoom, ext-adapt, TRACE_OK and the other sections.
5. **User build** `build/user-builds/si/` (`build/si-prep/mk_userbuild.py`, `USER_BUILD_OK 4`): `civ64.exe` (the
   Release build, SHA-256 c3735538...abb9fdb6), `CIVWIN.zip` and `civdos.zip` (byte-identical copies from
   `user-builds/d4`, SHA-256 058d4e00... and 0eac32c9... checked) and `WHAT-TO-CHECK.txt` (SHA-256 a6c14e2c...,
   CRLF, ASCII): SI-1..SI-6 in plain words as in "What the user checks" (the original's message "Sorry! Only one
   game at a time!", then the running civ64 at the front); for SI-3 the plain instruction to copy the whole "si"
   folder (for example to "si-copy") and not to use an older build such as "mzi" (builds before SI have no lock,
   so an older build beside it still opens a second civ64); the start-up moment without a message (Decision 4);
   the builds it contains (mzi, ux5, mzw, mz, ux4b, d5p, ux4, d6d, sl and the earlier ones) and the items still
   open from the checklist's pending rows at 23:45 UTC (184 items, 19 pending): MZI-1..MZI-7, UX5-1..UX5-7, D5P-7
   and P47-1 checkable; D6-1 and D5-7 with unit D6f, MZW-8 with unit MZS.
6. **Not done here**: the checklist's SI section (the orchestrator adds it) and the entries of "For the records"
   (RUNNING.md, FIDELITY (unnumbered: the orchestrator numbers it), DESIGN.md, STATUS.md, UX4b's record item) are the
   next joint docs pass's.

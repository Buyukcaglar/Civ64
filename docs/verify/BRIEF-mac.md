# Brief: the macOS build of civ64 (unit series MAC), from release v1.2.1

Written 2026-10-22 about 17:30 UTC on the user's Mac (macOS Tahoe 26.6.2, build 25G83, Apple M4, arm64), in a
Claude desktop session working in a fresh clone of Civ1RE at `fd2bf7a` ("civ64 1.2.1").

## The user's text (verbatim, 2026-10-22 about 17:20 UTC)

> now analyze repository, read all the documentation. There is a folder named claude you'll see that inside of it
> there is a port folder which some of it published to another public repository name Civ64 on my github account.
> This project's on this computer's aim is to develop and release macOs binary (freely distributable and not over
> the mac app store but signed by my developer account) based on latest release v1.2.1. You'll push everything you
> done in this project to Civ1RE private repository, and only push all documentation, non-copyrighted work and
> releases to the Civ64 public repository.

## What this is, and what it is not

* **What:** a native macOS application of civ64 at the v1.2.1 feature level. It contains the same recovered game
  core (`port/core`), the Borland-exact run-time (`rt`), the Win16 emulation (`platform/w16`) and the presentation
  (`present`, `res`) as `civ64.exe` 1.2.1, over a new macOS back end in place of `platform/win32` and `win64`.
  It is distributed outside the Mac App Store: signed with the user's Developer ID Application certificate,
  hardened runtime, notarized by Apple and stapled.
* **The publication split is the same as civ64.exe's** (BRIEF-pub.md, the user's direction of 2026-10-18 about
  07:35 UTC):
  * Civ1RE (private) gets everything: the macOS back end, the build and test scripts, the records.
  * Civ64 (public) gets the documentation, the user guide, the README and the release binary, with **no code**:
    no `port/core`, no `claude/src`, and none of the independently written code (that remains unit IWC's).
  * No original or DOS bytes in either repository or in the app bundle. The one exception stays the user's
    seamless menu tile `win64/civ-winmenu-bg.png` (the user, 2026-10-22 about 13:30 UTC) and the user's README
    screenshots.
* **Not IWC.** IWC (BRIEF-pub.md, "Unit IWC") is the clean, open implementation on SDL 3 whose binaries are not
  published before parity. This series ports the recovered implementation, as `civ64.exe` is, so its binary is
  published like `civ64.exe`. IWC's plan, its order (Windows first) and its parity gate are unchanged by it. The
  user's IWC answers about macOS (the game's menus in the macOS menu bar, the window-menu items in the app menu,
  the Windows 3.1 dialog and control emulation, the cursors and the sound carried over) are applied here too.

## Starting point (measured 2026-10-22 on this Mac)

* **Public Civ64:** `main` at `866ca9e` = tag `v1.2.1` ("Sid Meier's Civilization 64bit 1.2.1"). It holds the README,
  `docs/` (the audited records, `docs/verify`, `docs/screenshots`) and no code. Releases v1.0, v1.1, v1.2, v1.2.1
  attach `civ64.exe`.
* **The portable layers are ready for clang on arm64.** All 313 portable sources (`platform/w16`, `present` with
  `dos`, `map` and `bs`, `res`, `rt`, `core`, `core/gen`) pass `clang -std=c17 -fsyntax-only -Wall -Wextra` (Apple
  clang 21.0.0, arm64) with no error and no warning. The core uses fixed-width types; `long` appears only in
  `printf` arguments, so LP64 (64-bit `long` on macOS against 32-bit on Windows) does not reach the game state.
* **One host interface.** `platform/w16/host.h` lists every host service the portable layers use: memory, faults,
  the data directory's files, time, the core frame and the presented picture, input events, the cursors, sound,
  the system font, the DOS files, the data files of the presentation, message boxes, the file choosers. A macOS
  back end implements that header. Nothing in the portable layers includes a system header beyond the C library.
* **What is Windows-only** and needs a macOS counterpart:
  * `platform/win32/host_win32.c` (4,961 lines) and `host_win32.h` (the `hw_*` services the program shell uses:
    window and placement, scale, full screen, icons, the window menu with its Display, Map zoom, Graphics and
    other submenus, About, theme, windowless play, CRT, the alternative sounds, cursors, the exit question, the
    pause of PAU1, message and modal boxes, sound through `PlaySoundW` and `waveOut*`);
  * `win64/` (3,266 lines): `civ64_main.c` (the command line and the start), `civ64_cfg.c` (`civ64.cfg`),
    `civ64_locate.c` (phase R: finding `CivWin.zip`, a CivWin folder or the DOS files, and the remembered place),
    `civ64_start.c` (the data-directory check and the single instance), `civ64.rc` (version resource, icon, the
    embedded menu tile);
  * `tests/headless/*.c` use `<io.h>` and `<direct.h>`; `build.cmd` and `test.cmd` are cmd scripts calling MSVC,
    clang-tidy and `C:\Python314\python.exe`.
* **The generators run on this Mac's system Python 3.9.6.** Every script of `gen/`, `gen/dos/` and
  `tests/harness/` parses under it. `gen/inventory.py`, `dispatch.py`, `interfaces.py`, `oob_allowlist.py` and
  `gen/dos/registry.py gen` ran with exit 0, and every generated file of `core/gen` and `present/dos` came out
  byte-identical to the committed one ("pdos_registry: 159 files, 104 tables (unchanged)"). The only difference was
  `docs/inventory/out-of-range.md` losing its hand-written section "Sites found by the port", which the file
  itself says a regeneration drops; it was restored from git.
* **Tools on this Mac:** `/Applications/Xcode.app` is installed, but the active developer directory is the
  Command Line Tools. The build uses `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` per command and never
  switches `xcode-select` (no host-wide change). `notarytool` and `stapler` are present. Signing identities in the
  login keychain include **"Developer ID Application: Onur Buyukcaglar (SZ4F4WP934)"**. Homebrew is installed;
  `gh` was installed with it on 2026-10-22 (decision 4); CMake and pkg-config are not, and are not needed.
* **The game data (set up 2026-10-22 17:34 UTC, from the user's `~/Downloads`):**
  * `CIVWIN.zip` (38 files) extracted to `original/CIVWIN/` and `civdos.zip` (175 files) to `dos/`, both git-ignored
    and made read-only (immutable references, as on Windows);
  * hash-verified working copies in `claude/port/build/gamedata` (38 of 38 equal to
    `claude/docs/original-hashes-before.txt`) and `claude/port/build/dosdata` (175 of 176 equal to
    `docs/dos/dos-hashes.txt`); records `docs/hashes/20261022T173443Z-before.txt` and `-dos-before.txt`;
  * the three archives copied unchanged to `claude/port/build/zips/` (`CIVWIN.zip`, `civdos.zip` and the user's
    alternative music and sound effects `MusicSfx.zip`, 17 WAV files) for the locate and AMS paths;
  * `CIV_UNP.EXE` (pinned `aa63aa39...`, 340,791 bytes, use `opt`), which `civdos.zip` lacks, came separately from
    the user's Windows project (`~/Downloads/CIV_UNP.EXE`, 2026-10-22 about 17:51 UTC): it equals its pin, so `dos/`
    and `build/dosdata` hold all 176 pinned files (record `docs/hashes/20261022T175154Z-dos-before.txt`). No DOS
    program was run to make it.

* **The system font for the tests (2026-10-22 about 18:05 UTC):** the user's `VGASYS.FON` from Windows (7,280 bytes,
  SHA-256 `7baefa14ef8ef2355374d0b5061043dd5f4f8c33ff57680366e4a725f91646f8`) is installed read-only as
  `build/winfonts/Fonts/vgasys.fon` (git-ignored, never published). `test-mac.sh` points `WINDIR` at `build/winfonts`,
  so the headless back end reads it as on Windows. Without it every SYSTEM_FONT text has no glyphs: `test_user` failed
  18 of 365 checks and gate3b-s3's after-setup and turn snapshots differed; with it both pass.
* **Python packages (the user's consent, 2026-10-22 about 18:00 UTC):** `capstone` 5.0.9 and `numpy` 2.0.2, installed
  with `pip --user` for the system Python 3.9, for `gen/dos/disasm.py` (the DOS listings that `registry.py check`
  reads) and `gen/dos/nodos.py`.
* **Disk space:** the user's disk has about 8 GB free. A full Checked run writes several GB (a first run filled the
  disk: 4.4 GB under `build/harness`, 2.1 GB of per-run data copies under `build/run`, 0.6 GB of frame dumps under
  `build/frames`; deleted with the user's consent). Since then the harness clones the data copies on APFS
  (`clonefile`, the same bytes without new space) and `test-mac.sh` stops a run below 2 GB free
  (`CIV_TEST_MIN_FREE_MB`).

## Design of the macOS back end (native AppKit, decision 1 below)

* **Layout:** `platform/macos/` (the back end implementing `host.h`, plus `host_macos.h` with the services the
  shell needs, the counterpart of `host_win32.h`) and `macos/` (the program shell: the counterpart of `win64/`,
  sharing as much of `civ64_cfg.c` and `civ64_locate.c` as is portable). Objective-C only where AppKit requires it;
  everything else stays C17.
* **Threads:** AppKit owns the main thread (window, menus, events, panels, alerts). The emulated program runs on a
  second thread, as it does under `host_sync.c` on Windows. Modal host boxes call `w16_present_view` first (TLD).
* **Picture:** the presented XRGB buffer of `host_show` goes to a layer-backed view (a `CALayer` with the frame as
  its contents, or a Metal texture when measurement shows the need), nearest-neighbour, with the existing scale,
  aspect, filter, CRT and windowless code of `present/` unchanged. Retina: the window's backing scale feeds the
  same scale decision as the Windows DPI.
* **Input:** `NSEvent` key codes are mapped to the Windows virtual keys and scan codes that `HostEvent` carries;
  characters to Windows-1252. The Windows shortcuts keep working (Ctrl+Shift+Backspace switches the graphics).
  Alt+Enter keeps its full-screen meaning; the native full-screen command (Ctrl+Cmd+F, the green button) does the
  same. Mouse coordinates use the same mapping as the Win32 client area.
* **Menus (the user's answer of 2026-10-20 about 00:20 UTC):** the window-menu items of the Windows build
  (Display, Map zoom, Graphics, Alternative music/soundfx, About, ...) go in the app menu "civ64". The game's own
  menu bar (MENU 128) goes in the macOS menu bar in windowed play: built from the emulated menu's state, refreshed
  through the game's WM_INITMENU path so grayed and checked items match, and a choice posted as the same
  WM_COMMAND. The in-canvas menus of windowless play and the DOS graphics' DOS menus stay drawn by `present/`.
* **Sound:** the game's WAV files and the alternative sounds through Core Audio (`AVAudioPlayer` or an audio
  queue), keeping PAU1's full pause and the async/stop semantics of `PlaySoundW`.
* **Cursors:** the RT_CURSOR DIBs and the presentation's ARGB pointers become `NSCursor` images, scaled by the
  existing cursor factors; the torch cursor over the menus (CUR1) as on Windows.
* **Files and settings:** the config and the extracted `CivWin.zip` go to `~/Library/Application Support/civ64/`
  (the counterpart of `%LOCALAPPDATA%\civ64`). The file choosers become `NSOpenPanel`/`NSSavePanel` limited to the
  data directory, as COMMDLG is now; the DOS slot screen is unchanged. The single instance uses the application's
  own activation instead of a second process box where macOS already prevents a second start.
* **The system font (decision 3 below):** `host_system_font` reads the player's `vgasys.fon` from the data folder
  or `CivWin.zip`, else the F88 fallback; Microsoft's file is never shipped.
* **App bundle:** `Civ64.app` (display name "Sid Meier's Civilization 64bit"), version 1.2.1, the user's icon
  converted from `win64/civ64.ico` to `.icns`, the menu tile as a bundle resource, `LSApplicationCategoryType`
  games, no sandbox (Developer ID distribution does not need it), hardened runtime with no exceptions (the port runs
  translated C, not emulated x86 code, so it needs no JIT entitlement).

## Build, tests and the parity measure

* **Build script** `build-mac.sh` (Release, Checked, Asan with ASan and UBSan), the same strictness as `build.cmd`
  (`-std=c17` and `-std=c11`, `-Wall -Wextra -Werror -pedantic`), the generation steps, objects
  and outputs under `build/macos/`, which git ignores. The generators run on the system `python3`. Decision 2:
  `-arch arm64 -arch x86_64 -mmacosx-version-min=13.0`, one universal executable (`lipo`).
* **Tests** `test-mac.sh`: the headless harness and the unit tests on POSIX, running the existing harness scripts.
  The decisive check is that the headless goldens recorded on Windows (`gate3b-golden.txt`, `ext-g1-baseline.txt`,
  the frame and timeline goldens) are reproduced byte for byte on arm64. That proves the core, rt, w16 and present
  behave the same on the second compiler and architecture before any macOS window exists. The suite runs twice: the
  arm64 slice natively and the x86_64 slice under Rosetta 2, so the Intel half of the universal binary is tested too.
* **The macOS back end's own tests**, a counterpart of `tests/win32` for the parts that can run headless (the key
  map, the cursor conversion, the WAV parser, the config and locate logic).
* **User builds** in `build/user-builds/<unit>/` and a macOS section of `docs/manual-checklist-ext.md`, checked by the
  user in bulk, as in E4.

## Signing, notarization and the release

1. `codesign --force --options runtime --timestamp --sign "Developer ID Application: Onur Buyukcaglar (SZ4F4WP934)"`
   on the app (inside out), then `codesign --verify --deep --strict` and `spctl --assess --type execute`.
2. A DMG (or ZIP) of the app, signed the same way.
3. `xcrun notarytool submit ... --keychain-profile <profile> --wait`, then `xcrun stapler staple` and a final
   `spctl --assess` on a fresh download (quarantine attribute set) to prove Gatekeeper accepts it.
4. The release on Civ64: the macOS asset with its SHA-256, release notes for macOS (requirements, first start, the
   data folder, what is not included and why). Whether the asset joins the existing `v1.2.1` release or gets its
   own tag is decided at publication; the default is to join `v1.2.1` when the Windows `civ64.exe` stays
   byte-for-byte unaffected by the shared-code changes, otherwise a new version for both.
5. A scan of the bundle for original and DOS bytes, as auditor A's byte scan of `civ64.exe` (no original string
   or data run inside), before any upload.

## Prerequisites from the user

* **The game data:** done (see "Starting point").
* **Notarization credentials:** the user stores them once with
  `xcrun notarytool store-credentials civ64-notary --apple-id <id> --team-id SZ4F4WP934` (an app-specific
  password) or with an App Store Connect API key. The session never handles the password.
* **GitHub:** pushes to both repositories work over SSH with the key in `~/.ssh` (it authenticates as Buyukcaglar;
  Civ1RE's clone uses it through its local `core.sshCommand`). Creating releases needs `gh` (installed with Homebrew on
  2026-10-22, version 2.103.0; decision 4) and the user's `gh auth login`.

## The user's decisions (2026-10-22 about 17:40 UTC, answers to four questions)

1. **Host technology: native AppKit** (Objective-C and C over AppKit, Core Animation and Core Audio), not SDL 3.
2. **Target: a universal binary (arm64 and x86_64) for macOS 13 Ventura or later.**
3. **The system font: the player's own file.** `host_system_font` returns `vgasys.fon` when it is in the game's data
   folder or in `CivWin.zip`; otherwise the existing fallback applies (the first face of `civfonts.fon`, FIDELITY
   F88, audit A8). Nothing Microsoft-owned is shipped.
4. **`gh` is installed with Homebrew** for the releases; the user signs in with `gh auth login`.

## Units, in order

| Unit | What | Done when |
|---|---|---|
| MAC0 | Toolchain on this Mac: `build-mac.sh` for the portable layers and the headless harness, `test-mac.sh`; the headless suite on arm64 | every headless golden equals the Windows record; the variants build with `-Werror` |
| MAC1 | The back end's core: window, picture, scale, Retina, input, clocks and timing, files, `civ64.cfg`, locating the data, the data-directory check | the intro, title, setup and a game run in a window from the user's data |
| MAC2 | Sound, cursors, message and modal boxes, the file choosers, full screen and Alt+Enter, PAU1's pause, the single instance | each Windows behaviour has its macOS counterpart or a recorded limit (FIDELITY) |
| MAC3 | Menus: the app menu with the window-menu items; the game's menu bar natively in windowed play | every MENU 128 command and every host item reachable; grayed and checked states match |
| MAC4 | Bundle, icon, version 1.2.1, signing, notarization, stapling, DMG, the byte scan | `spctl` accepts the downloaded DMG; the scan is clean |
| MAC5 | Docs: RUNNING, FIDELITY, FEATURES and the user guide's macOS sections; the checklist | records written; the user's bulk check |
| PUBM | Civ1RE pushed; Civ64 docs, README quick start for macOS and the release | the published page and the asset checked in the browser |

Each unit ends with its record `docs/ext-MAC<n>-record.md`, a STATUS row, a Civ1RE commit and a non-force push.

## Constraints carried over

* Never modify the user's original game files or DOS files; work on hash-verified copies only.
* No original or DOS bytes in a repository or a binary, except the user's named exceptions above.
* No host-wide changes: no `xcode-select` switch, no system settings; tools only with the user's consent.
* Civ64 commits use the noreply identity `Buyukcaglar <<e-mail removed>>`; Civ1RE commits
  use the configured identity. Pushes are non-force.
* The user checks in bulk at the end of development; each user-visible unit gets a user build.
* Times shown to the user are Istanbul time (UTC+3); records keep UTC.

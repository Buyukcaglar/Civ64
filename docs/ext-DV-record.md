# Unit DV (the DOS files a player located again and again) - record

## The report (relayed by the user, 2026-10-23 about 06:50 UTC)

A player on Windows 10: CIV.EXE was first refused; they took a fresh copy of the DOS game, patched it to the final
version, and civ64 started. In a game, the switch to the DOS graphics was refused with a message saying to choose
Graphics > "Locate DOS files…" and restart civ64. They located the same folder (the suggested `CivDos` name next to
civ64.exe), civ64 accepted it, they restarted, and the same refusal came again, every time.

The user: "investigate if this is reproducible and if yes, plan a preventing action or fix then apply." Later the
same morning: "Update application version to v1.2.3 (both executable metadata and about dialog box)."; "Executable
mismatch error message shall display "Version 475.05" is required."; told that the pinned copy's `INTRO.TXT` reads
"Version 475.01", "then it shall accept both '.01' and '.05'" and "update displayed message reflect this change";
then, pointing to https://civfanatics.com/civ1/faq/section-a-general-information/: "it looks like there is no 475.01
version of the game, verify and if that is the case 0.5 shall be only accepted version".

## Cause

Two checks with different rules:

* Phase R's lookup (`win64/civ64_locate.c`: `--dos-data`, the ZIPs and the `CivDos` folder next to civ64.exe, the
  remembered location, the start-up question, and "Locate DOS files…") accepted a DOS copy when its CIV.EXE was the
  pinned one (`exe_ok`), and nothing else.
* The DOS asset store (`present/dos/pdos_assets.c` `pdos_assets_open`, once per run) requires every "req" file of
  `tests/dos-files.txt` (159 files) at its pinned size and SHA-256.

A copy whose CIV.EXE is right and one other file is not (a mod, or a file of another release next to a patched
CIV.EXE) passed the lookup and failed the store. The switch was refused with the store's sentence (the file named)
followed by F118's hint to use Locate; Locate checked CIV.EXE only, so it accepted the same copy and said the DOS
graphics would come at the next start; the next start found the same copy and the store refused it again. A
`CivDos` folder or ZIP next to civ64.exe also wins over the remembered location, so even locating a good copy
elsewhere could not help while the bad one stayed there.

## Reproduction (agent-observed, Windows)

* The released 1.2.2 `civ64.exe` in a scratch folder with a `CivDos` copy of `build/dosdata` whose `KING00.PIC` had
  its last byte changed (CIV.EXE untouched), `--graphics dos`: the start went past the lookup and stopped with the
  store's "KING00.PIC in …\CivDos is not the file civ64 knows (its size or SHA-256 differs)." (exit code 2).
* The user's own DOS folder `C:\work\_install` (read only): CIV.EXE is the pinned one, and of the 159 req files only
  `BLURB2.TXT` differs from its pin (same size, 17,847 bytes; 4 bytes changed in two places; written
  2026-10-18). 1.2.2 with `--dos-data C:\work\_install --graphics dos`: "BLURB2.TXT in C:\work\_install is not the
  file civ64 knows (its size or SHA-256 differs)." - the player's situation exactly.
* `w32_test_locate` built against v1.2.2's `civ64_locate.c`: the new cases fail (10 of 56), among them Locate
  recording the changed copy ("The DOS files are recorded…") and a changed `CivDos` folder accepted at the start.

## Fix

* `win64/civ64_locate.c` `dos_files_ok`: a DOS source is valid only with every req file of the pins
  (`present/dos/pdos_registry.h` `pdos_pins`, generated from `tests/dos-files.txt`), each at its pinned size and
  SHA-256, the store's own rule, read from the folder (names ignoring case, `hw_find_name`) or from the ZIP's folder
  of CIV.EXE (`zip_find`, `zip_extract`). Called by `check_dir` and `open_zip` for the DOS version, so every entry
  point applies it: found at the start, civ64 stops with the message (as for a wrong CIV.EXE before); remembered, it
  is skipped; chosen at the start or by Locate, it is refused with the message and asked again. A source accepted
  there opens the store, so the loop cannot form. The first file missing, unreadable or different is named with the
  folder or ZIP:
  * "The folder %s holds no %s. civ64 needs every file of Civilization for DOS 475.05 for the DOS graphics."
  * "In the folder %s, %s is not the file of Civilization for DOS civ64 knows (its size or SHA-256 differs). The DOS
    graphics need the unchanged files of version 475.05."
  * the same for "The ZIP file %s" / "In the ZIP file %s"; "… cannot be read." for a read error.
* The CIV.EXE mismatch messages end with "Version 475.05 is required." (folder: "%s is not the DOS version civ64
  knows (its size or SHA-256 differs). Version 475.05 is required."; ZIP: "… (CIV.EXE differs). Version 475.05 is
  required.").
* Version 1.2.3: `win64/civ64.rc` (FILEVERSION and PRODUCTVERSION 1,2,3,0; FileVersion and ProductVersion "1.2.3"),
  `platform/win32/host_win32.c` `g_about_title` "About Sid Meier's Civilization 64bit v1.2.3"; FIDELITY F355
  amended. The macOS application's version (`macos/Info.plist`) is the macOS units' own and unchanged.
* Tests: `tests/win32/test_locate.c` builds its DOS copies from all of `build/dosdata`'s req files (before: a folder
  or ZIP with CIV.EXE alone, which the new rule refuses) and adds the player's case: a ZIP and a folder with
  KING00.PIC changed or FONTS.CV missing refused at the start naming the file; `--dos-data` likewise; a wrong
  CIV.EXE naming "Version 475.05 is required."; Locate refusing the changed copy and asking again, then recording a
  right one; a remembered copy that changed skipped. `tests/win32/test_host_win32.c` checks 1.2.3.
* Docs: `docs/RUNNING.md` ("Where civ64 finds the game", the About box), FIDELITY F117 and F355, this record.

F118's refusal hint is unchanged: with the store and the lookup on one rule, a refusal after a found source can only
follow a file changed or unreadable between the two reads.

## Which DOS version

The pinned copy's `INTRO.TXT` (1991-12-02) reads "Version 475.01", while its CIV.EXE is dated 1992-10-13. The
CivFanatics Civ1 FAQ, section A, names 474.01 (version 1) and 474.05 (version 5), says "Version numbers may be 475.X
or 474.X, with the only difference being the distribution media", and lists, for its map-editor patch, the bytes of
civ.exe per version: versions 1 and 2 `E9 54 00 B8 32 00`, versions 3 and 4 `02 75 53 B8 32 00`, version 5
`E9 59 00 B8 32 00`. The pinned CIV.EXE holds version 5's bytes once (file offset 0x498F; CIV_UNP.EXE 0x7133) and
neither of the others, so it is version 5, 475.05 on the 475 media; the `INTRO.TXT` line is text the patch did not
replace. By the user's decision the messages name 475.05 only. The FAQ page offers no executables or hashes (only an
FTP path to the version 5 upgrade `civv05.zip`), so nothing of version 1 can be pinned from it; another CIV.EXE would
also be other code, whose tables the DOS graphics locate by offset (`docs/dos/OFFSETS.md`), not only another pin.

## Landing

* Hash check of the originals at the start: HASH_BEFORE_OK 38 of 38, DOS_HASH_BEFORE_OK 176 of 176
  (`hashes/20261023T070929Z-*`).
* Cycle (`build/a43-prep/cycle.ps1 -Unit dv`, `build/dv-status.txt`; times UTC; two earlier starts were stopped in
  their first step for the user's version and message changes): build checked BUILD_OK 07:38:43; test.cmd checked
  TESTS_OK 08:09:17 (1,834 s), among them `w32_test_locate` PASS 56, `test_host_win32` PASS 543 (the 1.2.3 values)
  and ext_zoom `ZOOM_OK combinations 32 runs 108 samples 628`; ext_g1 `EXT_G1_OK runs 77` (its one recorded
  amendment, unchanged) = ALL_GREEN; Release BUILD_OK 08:12:57 = RELEASE_OK.
* Release `civ64.exe` of 2026-10-23 08:12:53 UTC: 5,039,104 bytes, sha256
  31f77e96aab09bb4981730e15b07cad65cc254f20c15500196a889b8eaa1e78b; Explorer's FileVersion and ProductVersion 1.2.3.
* The Release civ64.exe on Windows (agent-observed; each run in a scratch folder with `--data` a copy of
  `build/gamedata`, `--graphics dos --music-sfx none --multi-instance`; the message box's text read and closed):
  `--dos-data C:\work\_install`: "In the folder C:\work\_install, BLURB2.TXT is not the file of Civilization for
  DOS civ64 knows (its size or SHA-256 differs). The DOS graphics need the unchanged files of version 475.05.", exit
  2; a `CivDos` folder with KING00.PIC changed: the same sentence for KING00.PIC, exit 2; a `CivDos` folder with
  CIV.EXE changed: "…\CivDos\CIV.EXE is not the DOS version civ64 knows (its size or SHA-256 differs). Version 475.05
  is required.", exit 2; an unchanged `CivDos` copy of `build/dosdata`: the game window, no message (the store
  opened; the run ended by the agent after 10 s). `%LOCALAPPDATA%\civ64\civ64.cfg` unchanged (last written
  2026-10-10).
* Not exercised live: "Locate DOS files…" in a running game (the file dialog); covered by `w32_test_locate` through
  `civ64_locate_set_ui`, and user check DV-1.
* Hash check of the originals at the end: HASH_AFTER_OK 38 of 38, DOS_HASH_AFTER_OK 176 of 176
  (`hashes/20261023T081355Z-*`).
* User build `build/user-builds/dv/` (civ64.exe; CAE3540B.SAV, CHIEF.SAV, MusicSfx.zip, CIVWIN.zip, civdos.zip as in
  v122; WHAT-TO-CHECK.txt with DV-1..DV-3). Checklist items DV-1..DV-3 pending the user's check.
* The public README and forum post still said "version 475.01" in their requirements; the README and User Guide
  are corrected by the publication below; the forum post drafts (`claude/docs/forum-post.*`) are not changed (the
  bbcode file has the user's own uncommitted edits).

## The macOS application

`macos/mac_locate.c` (the macOS session's lookup, from the same design) checks a DOS copy by CIV.EXE alone
(`check_dir`, `open_zip`), so `Civ64.app` 1.2.2 has the same gap. Not changed here: the macOS build, signing and
notarization run on the Mac. Hand-off in `NEXT-SESSION-E5.md` item 2k. The v1.2.3 release is for Windows; the
public README and User Guide send Mac users to the v1.2.2 release for the DMG.

## Publication (PUB6)

The user, 2026-10-23 about 08:20 UTC: "ok publish as latest version and update relevant documentation and release
notes." Since the commit `a6d182b` the macOS session had pushed three Civ1RE commits (its v1.2.2 publication
records) and Civ64 `3f14ed7` (the macOS text of README, User Guide and docs/README, screenshots 09 and 10, the DMG
added to release v1.2.2). The DV commit was rebased onto them (STATUS: both sides' rows kept) as `98c48b2`. The
hand-written public sources (`build/pub-stage/hand/`, `docs-README.head.md`) were taken from Civ64's published
`3f14ed7` before the 1.2.3 edits (`hand_v123.py`), and the generated docs were staged the macOS session's way
(`stage_mac.py`: new and changed files copied into the clone, nothing deleted), so the macOS text and screenshots
stay. Release notes `build/pub-stage/RELEASE-NOTES-v1.2.3.md`.

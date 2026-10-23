# Unit MAC4 (the signed, notarized macOS release build) - record

## The user's words (2026-10-22, about 20:15 UTC)

> Go ahead with MAC4: build the universal, signed and notarized DMG as a user build for my check.

## Result

`package-mac.sh --out build/user-builds/mac4` (with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` for the
command only, BRIEF-mac.md) ended `PACKAGE_OK` on 2026-10-22 at 20:27 UTC. The code is commit `75f1d92` (unit MACB1);
the script is commit `eb686e4`, made executable in this unit.

| Step | Result |
|---|---|
| `build-mac.sh release`, arm64 and x86_64 | BUILD_OK, both |
| `lipo` | `civ64`: x86_64 arm64 |
| `nodos.py check --variant Release` | NODOS_OK |
| `codesign --options runtime --timestamp` | "Developer ID Application: Onur Buyukcaglar (SZ4F4WP934)", team SZ4F4WP934, hardened runtime, secure timestamp; `--verify --deep --strict` valid |
| Disk image | `Civ64-1.2.1-macOS.dmg` (UDZO, HFS+, volume "Civ64 1.2.1"): Civ64.app, a link to /Applications, READ-FIRST.txt; signed the same way; 4,889,901 bytes |
| `notarytool submit --wait` | submission `49d71b72-945a-4e7e-882a-2860563c3540`: Accepted, "Ready for distribution", no issues |
| `stapler staple` | the disk image and the application next to it |
| `spctl --assess` | the application: accepted, source Notarized Developer ID; the disk image: accepted, source Notarized Developer ID |
| SHA-256 of the disk image | `8da9589356b571cfacd1d07bd1f3d8c64bb9235b62ec26b03e7047bd564663f1` |

Checked afterwards on this Mac (agent-observed):

* The mounted image holds exactly Civ64.app, Applications and READ-FIRST.txt. Its Civ64.app passes
  `codesign --verify --deep --strict` and `spctl --assess --type execute`, and its executable is byte-identical to the
  stapled copy next to the image. Info.plist: `com.buyukcaglar.civ64`, 1.2.1, display name "Sid Meier's Civilization
  64bit", macOS 13.0 or later.
* The universal application started with `arch -arm64` and with `arch -x86_64` (Rosetta 2), in the DOS graphics, to
  the title menu (a snapshot each; a test settings folder, `CIV64_SETTINGS_DIR`).

The user build `build/user-builds/mac4/` holds the disk image, its `.sha256`, the stapled Civ64.app, the notary's
answer and log, and the user's CivWin.zip, CivDos.zip, MusicSfx.zip and vgasys.fon (as the earlier user builds). The
release on the public Civ64 repository (unit PUBM) waits for the user's approval of this build.

## Not covered

* The application inside the disk image carries no stapled ticket of its own: the image's ticket is stapled, and the
  application's notarization (part of the same submission) is checked online by Gatekeeper at its first start after
  it is copied out. A first start with no network, from a copy made from the image, was not tried.
* A download through a browser (the quarantine flag) and a first start on another Mac, an Intel Mac in particular:
  the user's check. The x86_64 slice was run only under Rosetta 2 here.
* Sound, and the remaining items of the user's bulk check (MAC1's "Not yet covered").
* The icon: its largest source image is 128 px, scaled up for the larger sizes.

## Version 1.2.2, the release build (2026-10-23)

The user, on the MACB2 build: "This build is approved, update application version to v1.2.2 in app metadata and
about dialog box, prepare to application to be released on github releases, wait my release approval."

* `macos/Info.plist`: CFBundleShortVersionString and CFBundleVersion 1.2.2; `macos/READ-FIRST.txt` says 1.2.2.
* The About box reads the version from Info.plist (`host_macos.m`; before: the constant 1.2.1): seen on screen as
  "About Sid Meier's Civilization 64bit v1.2.2".
* `civ64.exe` (`win64/civ64.rc`, `platform/win32/host_win32.c`) stays 1.2.1: the Windows build was not rebuilt here.
  The MACB1 fixes in shared code (the DOS load palette, the windowless DOS bar) reach it with its next release.
* `package-mac.sh --out build/user-builds/v1.2.2`: PACKAGE_OK; universal (x86_64 arm64); NODOS_OK; Developer ID
  signature, hardened runtime; `Civ64-1.2.2-macOS.dmg` notarized (submission `bf7dc8dc-8cfe-468b-8ee8-6020ffaea7f1`:
  Accepted, no issues) and stapled; Gatekeeper accepts the application and the image; SHA-256
  `8ac137ab153859263898e05ab953d586f28f62ad15200594d67917314782959a`. The mounted image holds Civ64.app (1.2.2),
  Applications and READ-FIRST.txt; its application passes `spctl --assess --type execute`. A copy of the image
  with a browser's quarantine attribute: `spctl --assess --type open` accepted (Notarized Developer ID),
  `stapler validate` worked.
* The public Civ64 repository, prepared locally and not pushed: README (the macOS quick start, "New in version
  1.2.2", the Windows download pointed at v1.2.1 since `releases/latest` becomes the macOS release), User Guide
  (section 15, civ64 for macOS), docs/README.md (version 1.2.2 and the index), and the published copies of the
  macOS records, BRIEF-mac.md, the three hash records and STATUS.md (`build/pub-stage/stage_mac.py`: build_stage.py's
  rules, which reproduce the 454 published files byte for byte). The release notes:
  `build/pub-stage/RELEASE-NOTES-v1.2.2.md`. Tag `v1.2.2`, the image and its `.sha256` as the assets.
* The push and the release wait for the user's approval; creating the release needs `gh auth login` by the user.

### The macOS gameplay pair (the user's request of 2026-10-23)

The user: "I'll publish Windows version first, you'll pull Civ64 and merge your notes with the Windows One, one thing
I require from you is to prepare and include gameplay pair screenshots of macOS version".

* `docs/screenshots/Civ64-09-GamePlay-macOS-Windows.png` and `Civ64-10-GamePlay-macOS-DOS.png` (1920 x 1472): the
  release application of `build/user-builds/v1.2.2`, at its default window (1920 x 1440 device pixels) in windowless
  play, CAE3540B.SAV loaded through the DOS slot screen, the DOS graphics then the Windows graphics after
  Shift+Command+Delete; each the civ64 window alone (`screencapture -l` with the window's number, no shadow, no
  pointer), the window active. Windowless play, as the README's current pair: in the windowed layout at this size the
  map window's bar is narrower than the DOS titles. The PNGs' EXIF and XMP chunks ("Screenshot", the size) were
  removed; the colour profile is kept. Each was viewed: only civ64's window.
* In the prepared public README a fourth row of the screenshot table ("On macOS, Windows graphics" / "On macOS, DOS
  graphics"), and the two files in docs/README.md's screenshot index. (build_stage.py publishes only the seven
  original screenshots; the later ones are copied as they are.)
* The merge with the user's Windows release text follows the user's Windows publication.

### Merged with the Windows release v1.2.2 (2026-10-23)

The user: "The Windows release is published. Pull Civ64 and merge your macOS notes and screenshots with it."

* The Windows session's unit V122 ([ext-V122-record.md](ext-V122-record.md)) built MACB1's two shared fixes into
  `civ64.exe`, set it to 1.2.2 and published release `v1.2.2` (Civ64 `0d60553`, `civ64.exe` attached). So
  `civ64.exe` no longer stays at 1.2.1 (the bullets above describe the state before that), and the macOS image joins
  the same release instead of a separate macOS release.
* Civ1RE fast-forwarded to `d1862d9`. The local Civ64 commits of the preparation (`93b1683`, `84d1a4f`) are kept on
  the local branch `mac-prep`; `main` was reset to `origin/main` (`0d60553`) and the macOS changes applied again:
  the README (the intro, the Mac shortcut in the switch caption, "Quick start on macOS", a macOS item in "New in
  version 1.2.2", the image in the release list, the fourth screenshot row), the User Guide (the intro and section
  15, without the bullet about fixes civ64.exe lacked), docs/README.md (the overview, the macOS paragraph after
  V122's, the screenshot index) and the documents from `stage_mac.py`.
* The release notes: `build/pub-stage/RELEASE-NOTES-v1.2.2.md` is now the published Windows text with the macOS
  parts added (the intro, Download, New in 1.2.2, Requirements, How to start, Known limits, What is not included).

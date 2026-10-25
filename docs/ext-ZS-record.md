# Unit ZS (two more map zoom steps; Zoom out / Zoom in one step each) - record

## The user's words (2026-10-24, about 11:40 UTC)

> Add one more step between two zoom levels in both directions, and and change context menu Zoom out (half) and Zoom
> in (double) to Zoom out and Zoom in respectively, and action acts as repeating in the intended direction for both
> selected from menu or executed from shortcut.

## Change

* **Five levels** (`present/map/pmap.h`, `pmap_zoom.c`): `PMAP_ZOOM_OUT` -2 and `PMAP_ZOOM_IN` +2. Level l multiplies
  the frame's own scale by z_l = p_l / q_l = 1/2, 3/4, 1, 3/2, 2 for l = -2..+2; `pmap_geo_frame` takes
  nx / dx = q_l W / (p_l SW) (ny / dy alike) from one table, so -2 and +2 are exactly the former -1 and +1 (the same
  geometry, the same pixels). The in-between levels are new: 3/4 shows 4/3 of the view (a ring around it, the even
  origin as at -2), 3/2 two thirds of it.
* **Every level in or out** takes the rules that were written for +1 or -1: the active-unit follow, the game's
  centring (MZI), the centring on a new view (MZ), the world canvas and its ring (`pmap_world.c`, also for the DOS
  profile), `pmap_layer_sample`'s canvas update, the clamps (in: inside the view; out: the whole view).
* **Refusals** (4.3): a level in needs 3 x 3 squares (96 world pixels) in the layer at that level; `pmap_in_refused`
  now answers for one more step in from the current level (1 at +2, where there is none). A window 180 pixels wide
  at k = 1 allows +1 (120 world pixels) but not +2 (90).
* **The window menu** (`platform/win32/host_win32.c`, `host_win32.h`): "Zoom &out\tCtrl+Shift+Minus",
  "&Normal zoom\tCtrl+Shift+0, Home", "Zoom &in\tCtrl+Shift+Plus" (were "Zoom &out (half)", "Zoom &in (double)" in a
  radio group). Zoom out and Zoom in send the chords' own commands (`player_zoom` with `PI_CMD_ZOOM_OUT` /
  `PI_CMD_ZOOM_IN`, one step, the centre anchor), so each choice goes one level further, as each chord press and
  each wheel notch does; Normal zoom sends the reset. Normal zoom is checked at level 0; Zoom out is grayed at -2,
  Zoom in at +2 and while the next level in is refused. The macOS menu (`platform/macos/host_macos.m`): "Zoom Out",
  "Normal Zoom", "Zoom In", the same commands and grays.
* **Remembered level** (`win64/civ64_main.c`, `macos/civ64_mac.m`): the key `map_zoom` (-2..2). Without it the
  earlier builds' key `zoom` is read with its meaning (-1 half, 1 double: levels -2 and +2), so a remembered zoom
  keeps its size. `--zoom default|-2|-1|0|+1|+2` (`win64/civ64_start.c`, `civ64_start.h`, `macos/civ64_mac.m`).
* **Harness** (`tests/headless/harness*.{c,h}`): `--zoom default|-2|-1|0|+1|+2` and `at <ms> zoom -2|-1|0|+1|+2|reset`;
  presentation-diag.log's `level_plus1` is now `level_plus2` (level + 2). `tests/harness/ext_zoom.py` and
  `ext_adapt.py` run the half and double levels as -2 and +2, and `ext-zoom-golden.txt`'s level field is renamed
  (-1 to -2, +1 to +2; the hashes unchanged, the geometry being the same).
* **Tests**: `tests/test_map.c` (the old levels as -2 and +2; the geometry of +1 and -1 at k = 1..4 and under fit;
  the refusals at 180 and 120 pixels; one step a command, repeatable, clamped to -2..+2),
  `tests/win32/test_host_win32.c` (the menu texts, the steps and grays from the menu and the chords, Normal zoom
  checked, `--zoom -2` / `+2`).

## Checks (agent-observed, this PC, 2026-10-24)

* `build.cmd all`: BUILD_ALL_OK (Checked, CheckedNoObs, Release; 313 portable sources checked c11, c17, c99), about
  11:52..11:56 UTC.
* `test_map`: PASS 367 checks (Checked, Release), 1 (CheckedNoObs); `w32_test_host_win32`: PASS 554 (Checked,
  Release), 497 (CheckedNoObs).
* `test.cmd --section unit checked` and `release`: every program PASS except `w32_test_single` check C (a copied
  program's single-instance box: the box's text right, the copy's exit code a garbage value), in every run under
  `test.cmd`. The same program run alone, or the five `w32_test_*` programs in a row from the shell: PASS 50 checks.
  The unchanged HEAD (`a5bbb42`, version 1.2.3) built in a worktree fails the same check the same way under
  `test.cmd --section unit checked`, so it is not ZS's: an environment effect of this session's shell, not
  investigated further.
* User build `build/user-builds/zs/` (the Release civ64.exe, the data archives of build "dv").

## Not covered

* The long harness suites `ext_zoom.py`, `ext_adapt.py` and `ext_p0.py` were not run (their runs take 20 to 40
  minutes each). Their half and double runs are renamed only; `ext_adapt.py`'s zoom chords now step to 3/2 and 3/4
  first, so its zoomkeys pairs can differ from their earlier outputs.
* The macOS build was not built here (Windows session).
* The macOS application: ZS's macOS source (`platform/macos/host_macos.m`, `macos/civ64_mac.m`) is not compiled yet
  and the macOS version stays 1.2.3 (NEXT-SESSION-E5 2l).

## The user's check

ZS-1..ZS-3 passed (the user, 2026-10-24 about 12:05 UTC: "ZS passed user review.").

## Version 1.2.4 and publication (PUB7)

The user, 2026-10-24 about 12:05 UTC: "Update build number to v1.2.4 in relevant locations, commit and push then update
latest release and all relevant documentation."

* Version 1.2.4: `win64/civ64.rc` (`FILEVERSION`/`PRODUCTVERSION` 1,2,4,0, "1.2.4"), the About box
  (`platform/win32/host_win32.c` `g_about_title`), `test_host_win32`'s checks; FIDELITY F355. The macOS version
  (`macos/Info.plist`, `READ-FIRST.txt`) stays 1.2.3.
* Docs: FIDELITY F356 (the five levels), FEATURES (the map zoom row), RUNNING (the window menu, `--zoom`, the harness
  options, "The map zoom", the key `map_zoom`), DESIGN 12.9 "Added in ZS", STATUS, NEXT-SESSION-E5 2l (the macOS
  build of ZS, next free F357), the checklist.
* `build.cmd all` BUILD_ALL_OK (12:11..12:15 UTC); the Release `civ64.exe` of 2026-10-24 12:15:10 UTC, 5,039,104
  bytes, SHA-256 `174ed39bb704215f75d0fe70ebb5e366901bc250e490887cf13242710c81a024`. `test.cmd --section unit` on
  Checked and Release: every program PASS but `w32_test_single` check C (see "Checks", the same at HEAD); `w32_test_host_win32` 497
  checks and `test_map` PASS on CheckedNoObs.
* Public sources (`build/pub-stage/`): `hand/README.md`, `hand/docs/USER-GUIDE.md` and `docs-README.head.md` taken
  from Civ64's published `1e92cc4` (the macOS 1.2.3 text), then `hand_v124.py` (five levels, the menu's steps,
  `--zoom -2..+2`, `map_zoom`; Mac users pointed to the v1.2.3 release for the DMG); release notes
  `RELEASE-NOTES-v1.2.4.md` (Windows only).
* Civ1RE: `ae2cf07` (32 files, NODOS_OK over a copy), pushed non-force `a5bbb42..ae2cf07`.
* Civ64: the stage fast-forwarded to the macOS session's `1e92cc4`; `stage_mac.py Civ1 --apply` (2 new: ext-MACB3-record,
  ext-ZS-record; 8 changed; 468 the same); README.md and docs/USER-GUIDE.md from `hand/`; `finish_stage.py`;
  `build_stage.py --check-links` LINKS_OK; `nodos.py check --root Civ1` NODOS_OK. Commit `aaa9106` (noreply author
  and committer, 13 files), pushed `1e92cc4..aaa9106`.
* Release `v1.2.4` "Sid Meier's Civilization 64bit 1.2.4", Latest, target main (`aaa9106`), published 2026-10-24
  12:39:12 UTC; asset civ64.exe 5,039,104 bytes, GitHub digest
  sha256:174ed39bb704215f75d0fe70ebb5e366901bc250e490887cf13242710c81a024 (equal to the build); `releases/latest` =
  v1.2.4; the body equals `RELEASE-NOTES-v1.2.4.md`. Release v1.2.3 keeps civ64.exe 1.2.3 and the macOS DMG 1.2.3.
* Browser check (the built-in browser): the release page shows Latest, "New since 1.2.3", civ64.exe and its SHA-256;
  the repository page's README shows "New in version 1.2.4", "latest release is v1.2.4" and the macOS download at
  the v1.2.3 release; its 10 images load.
* Not changed: the repository's short description (it fits 1.2.4); the forum post drafts.

## The macOS port (session on the Mac, 2026-10-24)

The user, 2026-10-24 about 12:45 UTC: "pull the latest civ1re repo and apply changes to macOs application, set the
version of application v1.2.4 then update relevant documentation, commit and push both repo and update latest release
on Civ64 repo."

* Civ1RE fast-forwarded `3a0fd6f..b92ec33`, Civ64 `1e92cc4..aaa9106`. ZS's macOS source (`platform/macos/host_macos.m`:
  "Zoom Out" Command+-, "Normal Zoom" Command+0, "Zoom In" Command+=, one step each through `player_zoom`, Normal Zoom
  checked at 0, Zoom Out grayed at -2, Zoom In grayed while `pmap_in_refused`; `macos/civ64_mac.m`: `--zoom -2..+2`,
  the key `map_zoom`, the earlier `zoom` read as half/double) needed no change: it builds as written.
* Version 1.2.4: `macos/Info.plist` (CFBundleShortVersionString and CFBundleVersion), `macos/READ-FIRST.txt`; the About
  box reads Info.plist. FIDELITY F355 notes it. The build includes MACB3 (the DOS "not found" sentence names
  `Civ64.app`), unreleased until now.
* `build-mac.sh checked`: BUILD_OK (313 portable sources, c11, c17, c99; 64 test programs; the Checked application).
  `test-mac.sh --section unit Checked`: the 64 programs PASS (`test_map` 367 checks, as on Windows).
* `package-mac.sh`: `hdiutil create -srcfolder` failed with "Resource busy": the temporary volume's unmount was refused
  while the iOS Simulator service was shutting down ("Simulators are still shutting down"), also for a one-file test
  image. The script now falls back to a blank read-write image, `ditto`, `hdiutil detach` (then `-force`) and
  `hdiutil convert` to UDZO, the same contents. One notarization attempt timed out on the network and one found the
  keychain profile unavailable (the session locked); the user unlocked it.
* `package-mac.sh --out build/user-builds/v1.2.4` (2026-10-24 13:47 UTC): PACKAGE_OK; universal (x86_64 arm64);
  NODOS_OK; Developer ID, hardened runtime; `Civ64-1.2.4-macOS.dmg` notarized (submission
  `d34446a1-f0f7-40fe-bf0d-36d0024b4195`: Accepted) and stapled; Gatekeeper accepts the application and the image;
  SHA-256 `63301b099fec048ad68b05a7902f37b19b09b7b0a2c280953009e92ebf395579`, 4,862,200 bytes. The mounted image (made
  by the fallback) holds Civ64.app 1.2.4 (Info.plist; READ-FIRST says 1.2.4), the Applications link and READ-FIRST;
  the signature verifies; both architectures hold "next to Civ64.app", "--zoom takes default, -2, ...", "Zoom Out" and
  "Zoom In".
* Seen on this Mac (agent-observed): the Release application with `--data` a copy of the game, `--zoom +1`, started and
  ran for 8 seconds, then stopped.

### Not covered (macOS)

* The Map Zoom menu's steps, its grays and the remembered `map_zoom` were not exercised in a running game on the Mac
  (no menu interaction); the portable zoom logic is covered by `test_map`, the menu code is the Windows host's
  pattern. The long harness suites were not run.

### Published, macOS

* Civ64 `README.md` (Quick start on macOS: `Civ64-1.2.4-macOS.dmg` from the latest release; "New in version 1.2.4"
  says the macOS application is 1.2.4), `docs/USER-GUIDE.md` (the opening, section 15: version 1.2.4, the download,
  the Map Zoom items), `docs/README.md` (the result row 1.2.4, the 1.2.4 paragraph; the same in
  `build/pub-stage/docs-README.head.md`); the generated docs by `stage_mac.py`.
* The merged release notes `build/pub-stage/RELEASE-NOTES-v1.2.4.md` (the Windows text as published kept as
  `RELEASE-NOTES-v1.2.4-windows.md`).
* Civ1RE `fd8d0ba` pushed non-force `b92ec33..fd8d0ba`. Civ64 `1edafe8` (noreply author and committer, 8 files;
  NODOS_OK over the clone, 485 files; its relative links resolve) pushed non-force `aaa9106..1edafe8`.
* `gh release upload v1.2.4`: `Civ64-1.2.4-macOS.dmg` 4,862,200 bytes, GitHub digest
  `sha256:63301b099fec048ad68b05a7902f37b19b09b7b0a2c280953009e92ebf395579` (`shasum -c` OK before the upload), and its
  `.sha256`; `civ64.exe` unchanged (`174ed39b...0c81a024`). `gh release edit v1.2.4 --notes-file` the merged notes: the
  body equals the file. `releases/latest` = v1.2.4; `releases/latest/download/Civ64-1.2.4-macOS.dmg` resolves (200).

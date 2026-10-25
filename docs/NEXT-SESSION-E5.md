# civ64 extension: hand-off from session E4 to the next session

Written by the E4 orchestrator on 2026-10-18 (about 18:30 UTC, 21:30 Istanbul time), with D7 and D8 complete and
X9 (the final audit) plus the one Asan pass running. The section "State at hand-off" is completed at the session
end, after the end hash check.

## Rules carried over (unchanged)

* **The session prompt:** `claude/docs/x64-port-scaling-dos-prompt.md`.
* **The agents' rules:** `claude/port/build/e4-orchestrator/AGENT-RULES.md`.
* **The running log:** `claude/port/build/e4-orchestrator/orchestrator-state.md`. Read its tail first.
* **Hard constraints:**
  * never modify `C:\Projects\Civ1RE\original\CIVWIN` or `C:\Projects\Civ1RE\dos`;
  * never run a DOS program on the host;
  * no DOS bytes in the repository or a binary. The one exception is the user's seven README screenshots in
    `claude/port/docs/screenshots/`;
  * never write `build/dosdata`, `build/gamedata` or the user's `%LOCALAPPDATA%\civ64`;
  * no git writes except the publication steps the user asked for (PUB and IWC below);
  * never read the main project's excluded paths (`verify/BRIEF-d0.md`).
* **How to work:**
  * Python only as `C:/Python314/python -B`;
  * Bash heredocs drop backslashes: write scripts with the Write tool;
  * never lower the agents' model. The session effort is High, by the user's choice;
  * Asan only once at the end of a queue;
  * no periodic progress reports;
  * hand off at 1 % weekly usage left;
  * hash checks at the session start and end (`build/e3-orchestrator/hashcheck.ps1`).
* **Talking to the user:** every time shown to the user is in Istanbul time (TRT, UTC+3), by the rule in
  `%USERPROFILE%\.claude\CLAUDE.md`. Records keep UTC.
* **The user's DOS rule, verbatim:** "in DOS graphics never show a Go Back or Cancel row the DOS game doesn't have, on
  any screen; where DOS has a key for it (e.g. Escape), that key does it, otherwise that choice is only in the
  Windows graphics."
* **Box placement:** since 2026-10-18 10:57 UTC, DOS boxes on the play canvas stand where the Windows game shows
  them, which is generally the window's centre (D7g2, F318). N screens keep DOS's places.
* **User checks:** the user checks in bulk at the end of development. Never wait for or ask for checks. Each
  user-visible unit gets a user build in `claude/port/build/user-builds/<unit>/`, and the orchestrator keeps
  `claude/port/docs/manual-checklist-ext.md`.

## The queue, in order (the user's decisions of 2026-10-18; STATUS "User directions")

1. **Whatever of E4's queue is not done** (see "State at hand-off"):
   * X9 (`docs/ext-X9-audit.md`), the Asan pass, and the eight-step completion: test.cmd checked noobs, ext_g1
     CheckedNoObs and test.cmd Release on the final tree;
   * the session-end hash check;
   * the STATUS session-log row.
2. **PUB, publication** (`claude/port/docs/verify/BRIEF-pub.md`, the user's final scope of 07:35 UTC):
   * Civ1RE `main`: one commit of all of `claude/`. No original or DOS bytes, no game zips, saves, frames or
     binaries. `claude/tools` is force-added because the root `.gitignore` ignores `tools/`. Push non-force. The
     other chats' changes outside `claude/` stay untouched.
   * A new public repository `Buyukcaglar/Civ1` (gh is logged in as Buyukcaglar), with:
     * the README, titled "Sid Meier's Civilization x64": the user's six screenshots in Windows/DOS pairs under
       the title, then `OnTheFlyGraphicsSwitch.gif`, then the AI assistance disclaimer tied to a non-liability
       declaration plus a trademark notice, a quick start, and the recovery-coverage figure (regenerate it first);
     * `docs/USER-GUIDE.md`;
     * all docs, audited: no recovered C excerpts, and links to unpublished files turned into plain text;
     * **no code at all**: no `port/core` and no `claude/src`.
   * Release `v1.0` with notes and `civ64.exe` from the last Release build.
   * After the push, check in the built-in browser that the GIF animates.
   * Before the first push, report the git identity's e-mail.
3. **DONE 2026-10-18 21:58 UTC: WL, windowless play** (`docs/verify/BRIEF-wl.md`; state in `build/wl-stage/STATE.md`):
   * The user's direction: no scroll bars in windowless mode, in either graphics.
   * The map moves by a World Map click or a left click on the play map.
   * Rebase onto the tree after D7o and D8; 23 bases.
4. **DONE 2026-10-19 00:16 UTC: the extras AMS, A43 and CRT** (`docs/verify/BRIEF-extras.md`), then the closing all-variant build/test and the
   hash check.
5. **DONE 2026-10-19 04:23 UTC except PUB2: CRT2 (right after AMS; `BRIEF-e5rev.md`: CRT's slowdown and smoothing, CRT-1/CRT-4 failed), D7g3 and WL2, then PUB2** (`docs/verify/BRIEF-e5rev.md`, the user's directions of 2026-10-18 about 23:20 UTC,
   after AMS):
   * D7g3: the science advisor's recommendation box (DOS) at the Status window's left and bottom, as wide as the
     Status window, with no second box underneath it (D7g2-9 failed).
   * WL2: in windowless play, both graphics, the menu bar from the canvas's top left above the World Map, and the
     Status window's bottom on the canvas's bottom (taller, same look).
   * Then the docs pass (WL, A43, CRT, AMS, D7g3, WL2: DESIGN, RUNNING, FIDELITY from F322, FEATURES), the closing
     all-variant build/test and hash check, and PUB2: Civ1RE and Civ1 updated (README, user guide, docs), release
     `v1.1` with `civ64.exe`.
6. **IWC, the last task of all** (`BRIEF-pub.md` section "Unit IWC"): publish the independently written code to
   Civ1, audited per file: `platform`, `rt`, `present`, `win64`, `res`, `gen`, `tests`, the harness,
   `claude/tools` and the build scripts. Never `port/core` or `claude/src`.

## Open items to carry (from D7o, D8 and X9's interim report)

* The comment-only fixes X9 listed:
  * the `civ64_main.c` remembered_placement comment;
  * the `host.h` host_set_cursor_pixels comment;
  * the `host_win32.c` cursor_factors comment;
  * the `harness.c` PI_CMD_CLOSE name;
  * the scenarios.py p4-menus comment.
* OPEN X16: one shared ICONPG cell helper (pdos_pedia_cell / pdos_news_cell).
* The known w32_test_host_win32 GetKeyState flake.
* D7g2-9: the science advisor's recommendation keeps its DOS place beside the centred research choice (deviation 5,
  F319). The user rules on it at the bulk check.
* The checklist: 364 items, 180 pending at D7o's landing. The user checks them in bulk.

## State at hand-off

Completed 2026-10-18 about 19:15 UTC (22:15 Istanbul time).

* **X9, the final audit:** done. `docs/ext-X9-audit.md` gives the verdict "delivered with open items".
  * The one Asan pass is clean: build BUILD_OK, test.cmd asan TESTS_OK in 1637 s, EXT_G1_OK Asan 77, no ASan
    report.
  * The eight-step completion is green (`build/x9-status.txt`): test.cmd checked noobs (P0 62), ext_g1
    CheckedNoObs 77, test.cmd Release.
  * Two items are still open:
    * G-3: TRACE.md lists no observer probes. Fix `gen/trace.py` and the DESIGN text.
    * the comment-only items above.
* **The session-end hash check:** HASH_AFTER_OK 38 of 38 and DOS_HASH_AFTER_OK 176 of 176
  (`docs/hashes/20261018T191151Z-*`).
* **STATUS:** the session-log row "E4 end" is written.
* **Weekly usage:** 92 % at 19:11 UTC. It resets on 2026-10-22 at 06:00 UTC.
* **PUB is done** (about 20:10 UTC):
  * Civ1RE `66729fb` is pushed to `main`: 2,111 files under `claude/`.
  * The public https://github.com/Buyukcaglar/Civ1 has the initial commit `863722f`, with docs, README and user
    guide and no code. Its commits use the noreply e-mail.
  * Release `v1.0` has `civ64.exe`, SHA-256 `adc81441...8e9864`.
  * The browser check passed: the README, all images, and the GIF animating.
  * The audit and the user's answers are in `build/pub-stage/audit.md`:
    * the noreply e-mail for Civ1;
    * the prompt file included in Civ1RE as a one-time exception;
    * `claude/work` and `claude/port/1` left out.
* **The first queue item not done: WL** (queue item 3). Then the extras, then IWC. IWC adds the independently
  written code to Civ1 as a further commit, also with the noreply e-mail.
* **New in E4's last hours:** G-3 joins the open items above.

## State at hand-off, second part (the E4 orchestrator's continuation, 2026-10-19)

Written 2026-10-19 about 04:30 UTC (07:30 Istanbul time), at 98 % weekly usage. The user's request of 2026-10-18 about
19:50 UTC was: "continue implementing rest of the functionality until 99% weekly usage is depleted, then stop your
work, persist everything, provide a full hand-off prompt for the next session."

**Landed since the first part.** Every unit ran the four-step cycle: build checked, test.cmd checked, ext_g1 and
Release. Each has a user build in `build/user-builds/<unit>/`, a record in `docs/ext-<UNIT>-record.md`, and a
checklist section. Times are UTC.

| Unit | What it does | RELEASE_OK | Check items | FIDELITY |
|---|---|---|---|---|
| WL | windowless play | 2026-10-18 21:56:38 | WL-1..9, **all passed** (the user, 23:20) | F322..F325 |
| A43 | 4:3 for the DOS gameplay | 22:37:55 | A43-1..6 | F326..F328 |
| CRT | CRT scanlines | 23:33:30 | CRT-1..5: CRT-1 and CRT-4 **failed** (slowdown, smoothing) | F329..F331 |
| AMS | alternative music/soundfx | 2026-10-19 00:16:07 | AMS-1..5 | F332..F334 |
| CRT2 | CRT fix: 3840x2160 about 400 ms -> 8-9 ms; no blending | 01:08:54 | CRT2-1..3 (+ re-check CRT-1..5) | F335 |
| D7g3 | science advisor's recommendation at the Status window's left/bottom/width; the double DOS box in windowless play fixed | 02:43:38 | D7g3-1..4 | F336 (supersedes F319) |
| WL2 | windowless: menu bar across the top; Status down to the canvas bottom | 03:37:25 | WL2-1..5 | F337, F338 |
| docs-e5 | docs pass: FIDELITY F322..F338, DESIGN 12.12..12.15, RUNNING, FEATURES, DOS-PROFILE | 04:23:31 | none | next free **F339** |

* **The checklist:** 401 items, 190 passed, 208 pending. D7g2-9 failed and was fixed by D7g3; CRT-1 and CRT-4
  failed and were fixed by CRT2. They stay pending until the user's bulk check. The newest user build is
  `build/user-builds/wl2/`, which contains everything earlier.
* **The closing all-variant run: CLOSE5_ALL_GREEN** (`build/close5-status.txt`, script
  `build/close5-prep/close5-cycle.ps1`). Times UTC:
  * Asan: BUILD_OK 04:27:47, TESTS_OK 04:53:48 (1,561 s, no AddressSanitizer report), EXT_G1_OK 77;
  * CheckedNoObs: BUILD_OK 04:57:05, TESTS_OK 05:02:42, EXT_G1_OK 77;
  * Release: TESTS_OK 05:07:52.
* **The session-end hash check:** HASH_AFTER_OK 38 of 38 and DOS_HASH_AFTER_OK 176 of 176
  (`docs/hashes/20261019T050854Z-*`).

* **Agent-reported limits still open:**
  * WL2: the Status panel grows only when it is the column's last piece; the bottom-strip sizes are fixed; an odd
    Status width leaves 1 px at the box's right.
  * AMS: the first-time question flow (message boxes, folder or ZIP dialog) is not tested headless; only the user's
    AMS-2 covers it.
  * CRT2: the timing guard (120 ms) measured 49 ms under a parallel test.cmd load. Make it informational if it ever
    flakes.
  * No agent check ran on a real civ64 window for WL, D7g3 or WL2.
* **Not committed:** everything since Civ1RE `66729fb` (the records and the code of WL..WL2 and docs-e5) is in the
  working tree only. PUB2 commits it.

**The queue now:**

1. If the closing run or the hash check is not green, fix that first.
2. **DONE 2026-10-19 about 05:30 UTC (the user: "perform pub2 now"): PUB2.** Civ1RE `c33c164`; Civ64 `de4229f`;
   release v1.1 (`civ64.exe` 5,004,800 bytes, SHA-256 `dbf3ef9a...abdd50`); browser check OK. Open from PUB2:
   * the exe's version resource and About box still say 1.0 (`win64/civ64.rc`): fix with IWC or a v1.1.1;
   * the new `docs/screenshots/{46AB5B1D-...}.png` (windowless DOS gameplay, 2026-10-19 06:25 UTC): the user,
     2026-10-19 about 05:40 UTC: "Add the new windowless DOS screenshot (docs/screenshots/{46AB5B1D-...}.png) to the README at the next publication; I'll rename it." So at the next publication (IWC), use the user's renamed file
     (look in `claude/port/docs/screenshots/` for it; do not rename it yourself) in the README, and make the PUB scripts
     include it (they currently skip the GUID name). Allow it as a user screenshot in the NODOS rule, like the other
     seven;
   * the edits after `c33c164` are uncommitted (pub-stage STATE/audit, RELEASE-NOTES-v1.1, these records).
   The original PUB2 plan:
   * **The public repository is now `Buyukcaglar/Civ64`**: it was renamed from Civ1 on 2026-10-18, and `gh repo view
     Buyukcaglar/Civ1` redirects to it. Use Civ64 for PUB2 and IWC, and update the README and docs links to it.
   * Civ1RE `main`: one commit of `claude/` (non-force; `claude/tools` force-added; no `claude/work`, no
     `claude/port/1`; no original or DOS bytes; `build/` stays ignored, so the D7g2-9 screenshot never goes in).
   * Civ1: a further commit with the noreply e-mail. The README and `docs/USER-GUIDE.md` cover WL, A43, CRT, AMS,
     D7g3 and WL2; the docs are audited as in PUB (`build/pub-stage/audit.md`, its stage `build/pub-stage/Civ1`).
     Still no `port/core` and no `claude/src`.
   * Release `v1.1` with notes and `civ64.exe` from the latest Release build.
   * Check in the built-in browser.
2b. **DONE 2026-10-20 21:36 UTC (RELEASE_OK; F341, F342; user build `build/user-builds/wl4crt3/`, WL4-1..3 and CRT3-1..2 pending the user): WL4 and CRT3 (the user, 2026-10-20 about 00:45 UTC; STATUS "User directions")**: in windowless play with the
   Windows graphics, the menu bar in the popup/Status gray and its drop-down menus on the Status texture; CRT scanlines
   matched to DOSBox Pure Unleashed's double-scan. One unit "wl4crt3", one user build `build/user-builds/wl4crt3/`.
   If it did not land, resume from `build/wl4crt3-stage/STATE.md`. GitHub is updated only when the user says so.
2c. **DONE 2026-10-20 22:40 UTC (RELEASE_OK; F343, F342 amended; user build `build/user-builds/crt4/`, CRT4-1..3 pending the user; tile in `build/e5rev/status-tile*.png`, 32x32 from 'CvPc' 200 of civdata4.rsc at (1408,140); a later optional `menu-tile.png` next to civ64.exe is sketched in `build/crt4-stage/STATE.md`): CRT4 and the tile export (the user, 2026-10-20 about 22:00 UTC; STATUS "User directions")**: WL4 accepted; export
   the Status stone tile to `build/e5rev/` for the user's seamless rework (later: use the user's reworked tile); with
   CRT scanlines on, double-scan everywhere in both graphics. If it did not land, resume from
   `build/crt4-stage/STATE.md`. GitHub is updated only when the user says so.
2d. **DONE 2026-10-20 23:52 UTC (RELEASE_OK; F344; user build `build/user-builds/wl5/` with the PNG, WL5-1..3 pending; scale 4 image px = 1 game px; new `res/png.c` reader): WL5 (the user, 2026-10-20 about 23:00 UTC; CRT4 passed)**: the user's seamless `civ-winmenu-bg.png` (512x512, copy in
   `build/e5rev/`) behind the Windows graphics' windowless drop-down menus. It is loaded at run time from next to
   civ64.exe, never compiled in or committed (it is derived from the game's art). For a GitHub release, ask the user
   how to ship it. If it did not land, resume from `build/wl5-stage/STATE.md`.
2e. **DONE 2026-10-21 07:28 UTC (CRT5 + CRT5b RELEASE_OK; F345; user build `build/user-builds/crt5/`, CRT5-1..4 pending; WL5 passed): CRT5 (the user, 2026-10-21 about 00:00 UTC: "It seems like 'CRT Scanlines' option does not being applied to Windows graphics properly, check and verify.")**: investigate with measured frames and fix; if it did not land, resume from `build/crt5-stage/STATE.md`.
2f. **DONE 2026-10-22 11:15 UTC (RELEASE_OK; F346, F347; user build `build/user-builds/crt6wl6/`, CRT6-1..5 and WL6-1..2 pending): CRT6 and WL6 (the user, 2026-10-22 about 10:10 UTC; STATUS "User directions")**: gameplay scanlines on the accepted
   intro/title/Birth/setup base; disabled windowless menu items in a patterned dark gray. One unit "crt6wl6", one user
   build. If it did not land, resume from `build/crt6wl6-stage/STATE.md`.
2g. **DONE 2026-10-22 12:51 UTC (RELEASE_OK; F348; user build `build/user-builds/cur1/`, CUR1-1..5 pending; DOS unchanged, DOS map-edge scroll arrows over the DOS bar unverified): CUR1 (the user, 2026-10-22 about 11:40 UTC; crt6wl6 accepted)**: the Windows graphics' menus show the torch cursor, also when
   a drag from the World Map reaches them. If it did not land, resume from `build/cur1-stage/STATE.md`.
2i. **ICO1 and PUB4 DONE 2026-10-22 about 16:12 UTC**: ICO1 (the window carries its icons; F352); Civ1RE `fd2bf7a`, Civ64 `866ca9e`,
   release v1.2.1 Latest (civ64.exe SHA-256 `4293fea4...953a10`); browser check OK. Open: test_crt's 120 ms wall-clock
   guard flaked once under parallel load (352 ms); make it informational or raise it.
2j. **V122 and PUB5 DONE 2026-10-23 (session on Windows)**: the macOS session's two DOS fixes (MACB1: the windowless
   DOS bar, F353; the DOS play palette after a load, F354) built into the Windows civ64.exe, version 1.2.2 (F355);
   cycle ALL_GREEN, RELEASE_OK 06:14:17 UTC; release v1.2.2 ([ext-V122-record.md](ext-V122-record.md); STATUS).
   V122-1..3 pending the user's check. The macOS units continue from F356. Civ1RE `e1f6d10`, Civ64 `0d60553`,
   release v1.2.2 Latest (civ64.exe only): the macOS DMG is to be added to that same release (STATUS, PUB5 row).
2k. **DV and PUB6 2026-10-23 (session on Windows)**: a player's report, a DOS copy with the right CIV.EXE and one
   other file changed accepted by the lookup and by Locate while the DOS asset store refused it, at every start;
   `win64/civ64_locate.c` `dos_files_ok` applies the store's rule at every entry point (F117); "Version 475.05 is
   required." for a wrong CIV.EXE; version 1.2.3 (F355); cycle ALL_GREEN, RELEASE_OK 08:12:57 UTC; release v1.2.3
   for Windows ([ext-DV-record.md](ext-DV-record.md); STATUS). DV-1..3 pending the user's check. **For the macOS
   session:** `macos/mac_locate.c` has the same gap (`check_dir` and `open_zip` check CIV.EXE only); it needs the
   same check of every `pdos_pins` req file (and the 475.05 sentences) and a macOS 1.2.3 build; the public README
   and User Guide point Mac users to the v1.2.2 release for the DMG until then. Published: Civ64 `6f27f97`, release
   v1.2.3 Latest 08:32:44 UTC (civ64.exe only; SHA-256 `31f77e96...eaa1e78b`). A macOS 1.2.3 would add its DMG to
   v1.2.3 (`gh release upload v1.2.3 ...`) and point the README and User Guide's Mac links back to the latest release.
2l. **ZS and PUB7 2026-10-24 (session on Windows)**: the map zoom's five levels (1/2, 3/4, 1, 3/2, 2) and the
   window menu's "Zoom out" / "Zoom in" as one-step, repeatable commands (F356; [ext-ZS-record.md](ext-ZS-record.md));
   the user's check ZS-1..3 passed; version 1.2.4 (F355); Civ1RE `ae2cf07`, Civ64 `aaa9106`, release v1.2.4 Latest
   12:39:12 UTC (civ64.exe only; SHA-256 `174ed39b...0c81a024`; README and User Guide point Mac users to v1.2.3). **For the macOS
   session:** ZS also changed `platform/macos/host_macos.m` (the Map Zoom items "Zoom Out" / "Zoom In", one step
   each through `player_zoom`, Normal Zoom checked, the grays) and `macos/civ64_mac.m` (`--zoom -2..+2`, the key
   `map_zoom` with the old `zoom` read as half/double); neither was compiled on a Mac. A macOS 1.2.4 needs that build
   and `macos/Info.plist` / `READ-FIRST.txt` set to 1.2.4; its DMG would join release v1.2.4. The macOS units
   continue from **F357**. **Done 2026-10-24 (session on the Mac):** built and checked on the Mac, version 1.2.4 with
   MACB3, `Civ64-1.2.4-macOS.dmg` notarized and added to release v1.2.4 ([ext-ZS-record.md](ext-ZS-record.md),
   "The macOS port"); next free F357.
2m. **ONE and PUB8 2026-10-25 (session on Windows)**: Display's "1:1 pixels in gameplay" (F357;
   [ext-ONE-record.md](ext-ONE-record.md)): every frame in play one screen pixel per pixel in both graphics, the game
   screen the client's size, beyond 2726 x 1600 the smallest whole step, no map zoom out beyond normal meanwhile,
   remembered as the key `one_to_one`; the user's check ONE-1..9 passed; version 1.2.5 (F355); release v1.2.5 for
   Windows (civ64.exe and Civ64-Win7.exe). **For the macOS session:** the portable part (`present/present.c`,
   `present.h`, `scale.c`, `scale.h`, `map/pmap_layer.c`, `map/pmap_zoom.c`) builds unchanged; the macOS host has no
   item yet: `platform/macos/host_macos.m` needs a Display item calling `present_set_one_to_one` (the cursor and the
   view refreshed, Zoom Out grayed at normal while `present_one_to_one_active`), and `macos/civ64_mac.m` the key
   `one_to_one` read at the start and written after the choice. The macOS game-screen bounds are the same
   (2726 x 1600). A macOS 1.2.5 would set `macos/Info.plist` / `READ-FIRST.txt` and add its DMG to release v1.2.5.
   The units continue from **F358**.
2h. **PAU1 DONE 2026-10-22 14:19 UTC (RELEASE_OK; user build `build/user-builds/pau1/`, PAU1-1..8; civ64.exe 5,036,032 bytes, SHA-256 17d17cd6...ff219). The user approved it at 2026-10-22 about 14:25 UTC, on condition of the ICO1 fix (the title-bar icon after full screen and Alt+Enter); then PUB4 (state in `build/ico1-stage/STATE.md` and in `build/pub-stage/STATE.md` "PUB4") (the user, 2026-10-22 about 13:10 UTC; CUR1 accepted)**: PAU1 makes the host
   menu pause the game completely, sets version 1.2.1, points the About link at Civ64 and embeds civ-winmenu-bg.png
   in civ64.exe (the user, 13:25 UTC; the no-game-art rule still stands, this tile is its single exception); one user build
   `build/user-builds/pau1/`. Then **wait for the user's approval**. After it, PUB4: update the docs, use the
   user's `Civ64-07-WindowlessPlay-Windows.png` and `Civ64-08-WindowlessPlay-DOS.png` in the README **in place of the
   gameplay pair Civ64-05/06** (the user, 2026-10-22 about 13:20 UTC: "Replace the gameplay pair (Civ64-05 and Civ64-06) in the README with Civ64-07 and Civ64-08."), push both
   repositories, and release v1.2.1 as Latest with notes. If PAU1 did not land, resume from
   `build/pau1-stage/STATE.md`.
3. **DONE 2026-10-19 about 07:35 UTC: WL3 and PUB3** (the user: WL2 accepted; a black border around the windowless
   play area in both graphics; "update Github with the release v1.2"). WL3 landed (RELEASE_OK 07:27:11 UTC; windowless
   play grows the game screen by the removed chrome, so it fills the window; version resource and About box 1.2;
   FIDELITY F339, F340, next free **F341**; user build `build/user-builds/wl3/`, WL3-1..4). Civ1RE `2c72fcc`, Civ64
   `d476d0d`, release v1.2 (civ64.exe 5,005,824 bytes, SHA-256 `92d4c840...2d1a91`), browser check OK. Open: the
   About box link still points to github.com/Buyukcaglar/Civ1 (fix to Civ64 with IWC); two stray GUID screenshots in
   `docs/screenshots` are excluded (the user renames the one for the README).
3. **IWC, the last task of all** **Changed by the user's notes of 2026-10-20 about 00:05 UTC** (verbatim in
   `BRIEF-pub.md`, section "The user's IWC notes"): the code is fully annotated for human reading and is portable C on
   SDL 3; the Windows version comes first, then a native macOS binary for the user's Mac mini M4 (macOS Tahoe 26.6.2,
   Xcode 27.0). That makes IWC a multi-unit project. Split it into briefs, and ask the user the four open points listed
   there first. **The user answered them on 2026-10-20 about 00:20 UTC** (verbatim in `BRIEF-pub.md`, "The user's
   answers"): the Win32 civ64.exe stays, and nothing from IWC is published before parity with the recovered
   implementation; on macOS the menus are native and the window-menu items go in the "civ64" app menu; the Win 3.1
   dialog and control emulation, the cursors and the sound are carried over; the Mac build runs in a Claude desktop
   session on the Mac mini; and **the game core is rewritten as a clean open implementation**, so the public code
   builds a playable game alone. Recommended method: clean room (specifications from the private core, written by
   agents that never show the recovered C to the core's authors). Start IWC by writing its plan of units.
   **Method chosen by the user (2026-10-20 about 00:35 UTC): "Ok, if possible 1, if not 4"**: a "bring your own
   game" recompiler that translates the user's own civ.exe at build time if feasible, otherwise the clean-room
   rewrite. The first unit is the feasibility study IWC-F (`BRIEF-pub.md`, "The user's choice of method").
   (`BRIEF-pub.md` "Unit IWC").
4. The open items of the first part: G-3, the comment-only items, X16, the GetKeyState flake, and the Asan-parallel
   default.

**The user's bulk check (2026-10-22 about 15:20 UTC):** every open checklist item passed. The checklist has 440 items: 437
passed, 3 superseded, 0 pending. Items added later, from ICO1 on, start pending.

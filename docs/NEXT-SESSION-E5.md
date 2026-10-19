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
2. **PUB2** (`docs/verify/BRIEF-e5rev.md` "Unit PUB2"):
   * **The public repository is now `Buyukcaglar/Civ64`**: it was renamed from Civ1 on 2026-10-18, and `gh repo view
     Buyukcaglar/Civ1` redirects to it. Use Civ64 for PUB2 and IWC, and update the README and docs links to it.
   * Civ1RE `main`: one commit of `claude/` (non-force; `claude/tools` force-added; no `claude/work`, no
     `claude/port/1`; no original or DOS bytes; `build/` stays ignored, so the D7g2-9 screenshot never goes in).
   * Civ1: a further commit with the noreply e-mail. The README and `docs/USER-GUIDE.md` cover WL, A43, CRT, AMS,
     D7g3 and WL2; the docs are audited as in PUB (`build/pub-stage/audit.md`, its stage `build/pub-stage/Civ1`).
     Still no `port/core` and no `claude/src`.
   * Release `v1.1` with notes and `civ64.exe` from the latest Release build.
   * Check in the built-in browser.
3. **IWC, the last task of all** (`BRIEF-pub.md` "Unit IWC").
4. The open items of the first part: G-3, the comment-only items, X16, the GetKeyState flake, and the Asan-parallel
   default.

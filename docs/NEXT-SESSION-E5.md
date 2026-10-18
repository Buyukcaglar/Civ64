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
3. **WL, windowless play** (`docs/verify/BRIEF-wl.md`; state in `build/wl-stage/STATE.md`):
   * The user's direction: no scroll bars in windowless mode, in either graphics.
   * The map moves by a World Map click or a left click on the play map.
   * Rebase onto the tree after D7o and D8; 23 bases.
4. **The extras AMS, A43 and CRT** (`docs/verify/BRIEF-extras.md`), then the closing all-variant build/test and the
   hash check.
5. **IWC, the last task of all** (`BRIEF-pub.md` section "Unit IWC"): publish the independently written code to
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
* **The first queue item not done: PUB.** E4's orchestrator starts PUB right after this hand-off if usage allows.
  Check `build/e4-orchestrator/orchestrator-state.md`'s tail for how far it got. If Civ1 and the release exist,
  finish only the remaining PUB steps, then continue with WL.
* **New in E4's last hours:** G-3 joins the open items above.

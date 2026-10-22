# Brief: publication (unit PUB), after the session-end hash check, the STATUS row and the hand-off

Session E4. The user added this task on 2026-10-18 about 06:44 UTC as step 7 of the session's queue, after
"6. the session-end hash check, the STATUS row and the hand-off". The extras (AMS, A43, CRT) and WL stay for the
next session. The publish steps are git writes and public actions that the user asked for explicitly; they run
only after step 6 and only as described here.

## The user's text (verbatim)

> Then add a new publish task after '6. the session-end hash check, the STATUS row and the hand-off.' for the
> following
>
> 1. Create a public GitHub repository named 'Civ1' on my account and commit & push everything related to your
> work, that is not copyrighted to the repository as initial commit. Create and publish initial release and add
> release notes. Publish a detailed repository readme about the project. Include the following screenshots '' in
> the readme, just under the application name as readme title 'Sid Meier's Civilization x64' and put AI
> assistance disclaimer (a non liability declaration must be presented and tied to AI assistance disclaimer)
> beneath. Provide full detailed user guide and put it in the docs folder on github repo, and give link to it
> from the repository readme. Provide a also quick and condensed startup guide on the main repository readme.
> Document everything from start to finish, all of your findings, tests and methodology, tangible data, all in
> full detail and put them under the 'docs' folder on github repository.
> 2. Push everything in here to Civ1RE main branch also, since Civ1RE is a private repo and will never be opened
> to public, push everything regarding to all your work.

The user's answer on the public scope (about 06:48 UTC), verbatim:

> "Everything incl. sources" what is legal status of the recovered C sources? if they are in the grey area then
> publish, if they are openly illegal do not.

## The orchestrator's reading (the user may correct it before the publish step)

**Legal line (the user's rule: grey area publish, openly illegal do not).** The orchestrator's assessment of
about 06:55 UTC, not legal advice. The recovered C (`port/core`, `claude/src`, the listings and pseudocode) is a
translation of the copyrighted `civ.exe`. Distributing it without the rights holder's permission is
infringement on the text of US, EU and Turkish copyright law. The reverse-engineering exceptions (EU Directive
2009/24/EC Art. 6; US fair use as in Sega v. Accolade and Sony v. Connectix) cover making such copies for
interoperability, not publishing them or shipping a product that contains them. The rights holder, Take-Two
Interactive, sued the authors of a comparable decompilation project (re3/reVC) in 2021. The orchestrator
therefore read it as the "do not" case.

**The user's decision (2026-10-18 about 07:00 UTC, verbatim):** "Publish the recovered C sources and civ64.exe to
the public Civ1 repo anyway; I accept the risk." This supersedes the orchestrator's reading above and the port
final report's section 6 sentence "the port and its sources stay local and unpublished". The no-original-bytes
rule stays: the recovered C holds no original bytes or string literals (final report section 6), and the game's
data still comes from the player's own copy.

**The user's revised direction (2026-10-18 about 07:35 UTC, verbatim), superseding the 07:00 decision:** "For
publishing task public repository shall not include 'port/core' and 'claude/src', but the docs, the user guide
and the README shall be published. Also release Civ64.exe as initial v1.0 release as planned. Add a 'independently
written code task' at the end of the all tasks, even after the extra features, which will be published as you
suggested in the Civ1 public repo. Update your records accordingly."

So in this unit the public repository gets no code: no `port/core` and no `claude/src`, and none of the
independently written code yet. That code is published later by unit IWC (below), at the end of all tasks.

**Public repository `Buyukcaglar/Civ1`** (the About box's link). The initial commit is one commit of:
* `README.md`:
  * the title "Sid Meier's Civilization x64", with the screenshots just under it;
  * beneath them, the AI assistance disclaimer tied to a non-liability declaration (as in
    `claude/docs/forum-post.md`), plus a trademark notice: not affiliated with or endorsed by the rights holders,
    and the player's own copy of the game is needed;
  * a quick, condensed startup guide;
  * a link to `docs/USER-GUIDE.md`;
  * the project description, and what the repository holds and does not hold, and why: the docs and the
    `v1.0` release now; the independently written code later (unit IWC); the recovered C not published;
  * the recovery-coverage figure, regenerated, dark, with no comparison with the parent project.
* `docs/USER-GUIDE.md`: the full, detailed user guide (installation, requirements, every menu, key, option,
  graphics profile, zoom, saves, troubleshooting).
* `docs/`: the work from start to finish, in full detail:
  * methodology, findings, tests and measured data;
  * the port's DESIGN, FIDELITY, RUNNING, FEATURES, STATUS, DOS-PROFILE, the unit records, the acceptance
    records, the final report and recovery-coverage;
  * `docs/README.md` as the index and the narrative.
  * Each file is audited, and private paths and the user's e-mail are removed.
  * Links to files that are not published (`port/core`, `claude/src`, the code) become plain text naming the file.
  * The audit lists every passage that reproduces recovered C beyond names, addresses and short identifiers, and
    condenses each into a description, so the docs carry no part of `port/core` or `claude/src`.
* **Screenshots: the user's own.** The user's direction of 2026-10-18 about 08:05 UTC, verbatim: "The screenshot
  that goes with the repository publish is placed under 'C:\Projects\Civ1RE\claude\port\docs\screenshots' folder,
  use them during the for repository publish." This replaces the orchestrator's earlier default of taking civ64
  screenshots; none are taken.
  * The six PNG files, each 1922x1432, in Windows and DOS pairs:
    * `Civ64-01-TitleMenu-Windows.png`, `Civ64-02-TitleMenu-DOS.png`;
    * `Civ64-03-GameSetup-Windows.png`, `Civ64-04-GameSetup-DOS.png`;
    * `Civ64-05-GamePlay-Windows.png`, `Civ64-06-GamePlay-DOS.png`.
  * They are published as `docs/screenshots/` in the public repository.
  * The README shows them just under its title, before the disclaimer: one row per pair, the Windows graphics
    beside the DOS graphics, in the files' order, with short captions.
  * Each file is viewed before publishing, to make sure it shows only civ64 and nothing private. They are
    published unchanged.
  * **The animated GIF.** The user's direction of about 08:10 UTC, verbatim: "A new animated gif file added to
    screenshots folder named 'OnTheFlyGraphicsSwitch.gif' check and verify that whether github displays animated
    gifs as animated or not, if yes, use that animated gif file in the repo publish readme to emphasize/visualize on
    the fly graphics switching feature."
    * The file: `OnTheFlyGraphicsSwitch.gif`, GIF89a, 956,562 bytes, 1924x1434, 162 frames, looping forever
      (NETSCAPE2.0 count 0), 30.05 s per loop, frame delays 0.05..2.34 s.
    * Checked: GitHub renders animated GIFs in a README as animations, and it is far below the 5-10 MB size reported
      to break README images. The one viewer-side exception is GitHub's accessibility setting "Autoplay animated
      images" (Settings > Accessibility > Motion; default "Sync with system", so a viewer with the system's
      reduce-motion preference sees it paused, with a play button). Since 2022-05-19, per GitHub's changelog and docs.
    * Use: in the README directly after the screenshot pairs, before the disclaimer, captioned as the on-the-fly
      graphics switch (Ctrl+Shift+Backspace, or the window menu's Graphics submenu), full width. The README's
      feature section and the user guide's graphics-switch section point to it.
    * Verification after the push: open the published README in the built-in browser and check that the image is
      served as `image/gif` with all 162 frames, and that two views a few seconds apart differ.
  * They show the original game's artwork as quotation, by the user's explicit request. This is the only exception
    to "no DOS bytes in the repository", and it covers these seven files only (six PNGs and the GIF).
* **Excluded, always:**
  * original game files, the DOS files and `CIVWIN.zip`/`civdos.zip`;
  * the listings, pseudocode and disassembly that hold the original's bytes;
  * the original string inventory;
  * saves made from the user's games;
  * captures and frames other than the README screenshots;
  * build outputs and tool binaries;
  * the main project's excluded paths (`verify/BRIEF-d0.md`);
  * private paths and e-mail addresses.
* **Release** `v1.0` (the program's version): a tag and release notes covering the features, the DOS profile,
  the requirements, what is not included and why, and how to start. `civ64.exe` is attached (the user's decision
  of about 07:00 UTC, kept "as planned" at 07:35), built from the final tree (the session's last Release build),
  never the game data.
* **Excluded in this unit, by the 07:35 direction:** all code, meaning `port/core`, `claude/src` and the
  independently written code (unit IWC publishes the last of these later).

**Civ1RE main (private):** one commit of all of `claude/` (the user's "everything regarding all your work"):
* the port with `core`, `claude/src`, `claude/tools` (force-added, since the root `.gitignore` ignores `tools/`),
  the docs;
* the text records of `claude/port/build` (orchestrator states, status files, prep and landing records);
* nothing with original or DOS bytes: no game zips, saves, frames or binaries.
The other chats' uncommitted changes outside `claude/` stay untouched (default; the user may say otherwise).
The push is non-force, to `origin` `main`.

**Order and mechanics.**
* A fresh agent prepares everything in `build/pub-stage/` alongside X9 and the Asan pass: the allowlist export,
  an audit report per file, the README (with the user's screenshots), the user guide, the docs index and the
  release notes.
* After step 6, the orchestrator first commits and pushes Civ1RE.
* Then it runs `gh repo create Buyukcaglar/Civ1 --public`, the initial commit and push, and
  `gh release create v1.0` with the notes.
* Commits use the configured git identity; its e-mail is reported before the first push.
* Commit messages end with the session's co-author line.
* Not in this unit: re-checking and posting the forum post (`claude/docs/forum-post.md`); the user posts it.

## Unit IWC: the independently written code (the last task of all)

Added by the user's direction of 2026-10-18 about 07:35 UTC (quoted above). It comes after every other task:
after this session's PUB, and in the next session after WL, the extras AMS, A43 and CRT, and their closing
build/test and hash check. It is the last item of the hand-off's queue.

* **What:** a further commit to the public repository `Buyukcaglar/Civ1` with the independently written code, as
  the orchestrator suggested at about 06:55 UTC. That is the code written for civ64 rather than translated from
  `civ.exe`:
  * `platform` (the Win16 layer w16 and the Windows host);
  * `rt` (the replacement for the Borland C runtime);
  * `present` (the presentation, the DOS profile and the zoom);
  * `win64`, `res`, `gen`, `tests` and the test harness, `claude/tools`, and the build scripts.
  Each file is audited. Nothing that holds recovered C or original or DOS bytes goes in, and anything derived from
  the original program's code is left out and listed.
* **Never in it:** `port/core` and `claude/src` (the recovered C), the listings, the original string inventory,
  game or DOS files, and saves from the user's games.
* **The README and docs:** they gain a section saying the public code does not build a playable game without the
  recovered core, which is not published, and why. The links to the published code are updated.
* **Mechanics:** as in PUB. The tree is staged and audited per file, then one commit with the session's co-author
  line, pushed non-force to `main`. Civ1RE gets the same state of `claude/` first.

### The user's IWC notes of 2026-10-20 about 00:05 UTC (verbatim)

> Take the following notes for the IWC task;
>
> 1. Code shall be full annotated for human reading
> 2. Shall be portable C and uses SDL-3
> 3. After Windows version native macOs binary will be developed and my mac mini m4 which currently runs on tahoe
> 26.6.2 and having xCode version 27.0 installed

**What these notes change (the orchestrator's reading; settle the open points with the user before coding):**

* IWC is no longer only a publication of the existing files. The published independently written code is:
  * **fully annotated for human reading**: every file, function and non-obvious block gets explanatory comments,
    beyond the current density;
  * **portable C using SDL 3**: the Windows-only host (`win64`, the Win32 host in `platform`, and the Win32 parts of
    `present`) goes behind an SDL 3 host. That covers the window, the menus, input, timers, audio, file dialogs and
    the config path. The C stays portable, with no Win32 or MSVC-only constructs in shared code.
* The user's order: **the Windows version first** (the SDL 3 build on Windows, as good as today's), **then a native
  macOS binary**. The macOS target is the user's Mac mini M4 (Apple silicon, arm64), with macOS Tahoe 26.6.2 and
  Xcode 27.0.
* **Open points to settle with the user (one short question each, at the start):**
  1. Does the SDL 3 build replace the Win32 civ64.exe, or sit beside it until it reaches parity? A sensible default
     is beside it, with the release switching only at parity.
  2. Win32-only features need an SDL equivalent or a stated limit: the window's system-menu items (Display, Map
     zoom, Graphics), the native Windows 3.1 dialogs and controls of the Windows graphics, the cursor files and the
     sound path. Native menus on macOS go in the app menu bar.
  3. Building and testing the macOS binary needs the Mac: how the session reaches it (SSH, or the user runs the
     build), plus signing and notarization, or a local unsigned build.
  4. The recovered core (`port/core`, `claude/src`) stays private. So the public code still does not build a
     playable game alone, and the README says so. The same split applies on macOS.
* **Tests:** the existing suites must stay green on the Win32 build throughout. The SDL host gets its own headless
  tests and its own user builds.
* **Size:** this is a multi-unit project (an SDL 3 host, annotation, the macOS build), not one unit. Split it into
  bounded units with their own briefs before starting.

### The user's answers to the four open points (2026-10-20 about 00:20 UTC, verbatim)

> 1. civ64.exe will not be replaced and SDL version, and IWC binary will not be published until it matches the current
> recovered implementation
> 2. "On macOS, the menus would go in the app's menu bar" - that is accepted and the way it shall be implemented. "the
> window-menu items" - will be merged to app's menu bar's appname (civ64) menu itself. "the native Windows 3.1 dialogs
> and controls of the Windows graphics" - this pseudo emulation (other then Windows 3.1 menus) will be carried over.
> "the cursors and the sound path." - this will be carried over too.
> 3. Session will build on mac mini m4, Claude desktop installed to mac mini m4 also.
> 4. Yes "The recovered game core stays private." but whole aim of IWC task is to provide an open source clean
> implementation so that "the public code will be able to build a playable game on its own, on Windows or macOS".
> So, recovered game core has to be rewritten also.

**What IWC is now (the orchestrator's reading of the answers):**

* **The goal:** an open-source, clean implementation in portable, fully annotated C on SDL 3. It builds a playable
  game on its own, on Windows and on macOS, and needs no private code. The game's data still comes from the user's
  own copy, as civ64 does today; no original or DOS bytes go in the repository.
* **The rewritten core:** the recovered core (`port/core`, `claude/src`) stays private and is not published. The
  public core is a new implementation of the same behaviour. That is the largest part of IWC, far larger than the
  host.
  * **Recommended method: clean room.** The authors of the new core work from written specifications, not from the
    recovered C. The specifications are the behaviour contracts: DESIGN, FIDELITY, the records, the reconstruction
    plan's contracts and the test oracles (the existing harness, the scenarios and the frame or state goldens of
    the private build).
  * Agents that read the recovered C write specifications only. Agents that write the public core never see it.
  * Record the split per unit. This keeps "clean" defensible and matches the user's earlier legal question.
* **Parity gate:** the Win32 `civ64.exe` stays and is not replaced. Neither the SDL build nor any IWC binary is
  published until it matches the current recovered implementation. Parity is shown by differential tests against
  the private build: the same inputs and seeds give the same states and frames. Decide per area how exact it must
  be; the default is exact.
* **macOS UI:**
  * the game's menus go in the macOS menu bar;
  * the window-menu items (Display, Map zoom, Graphics, and so on) merge into the app menu "civ64";
  * the emulated Windows 3.1 dialogs and controls of the Windows graphics are carried over, except the Windows 3.1
    menus, which become the native menu bar;
  * the cursors and the sound path are carried over.
* **The Mac build:** done by a Claude desktop session on the user's Mac mini M4 (macOS Tahoe 26.6.2, Xcode 27.0,
  arm64). The Windows session hands it a brief and a pushed branch, and the Mac session builds, tests and reports.
* **Order:**
  1. the clean-room specifications and the plan of units;
  2. the SDL 3 host and the public core on Windows, until parity;
  3. the macOS build;
  4. publication of code and binaries only after parity.

### The user's choice of method (2026-10-20 about 00:35 UTC, verbatim): "Ok, if possible 1, if not 4"

The options as offered to the user in chat:
1. a "bring your own game" recompiler;
2. a patch against decompiler output (grey);
3. asking the rights holder;
4. a clean-room rewrite.

**IWC's method:** option 1 if it is feasible, otherwise option 4. This supersedes the clean-room-first reading above;
that reading becomes the fallback.

* **Option 1, the "bring your own game" recompiler.** The public repository contains no game code. It holds:
  * a translator that turns the user's own `civ.exe` (from their `CIVWIN.zip`) into C at build time;
  * the independently written layers: w16, rt, present and the DOS profile, the host (on SDL 3);
  * facts as data: function boundaries, names, types and calling conventions, keyed by segmented address.

  The private core's hand changes (the presentation hooks, the 64-bit fixes, the P0 observers) become replacement
  or hook functions written independently, keyed by segmented address, and never copied from the recovered C.
* **First IWC unit: a bounded feasibility study, IWC-F.** It answers:
  * how much of `civ.exe`'s code translates automatically into the same behaviour as `port/core`, measured by the
    existing tests and the differential harness;
  * what cannot translate automatically (computed jumps, self-modifying or overlay code, data mixed with code, FPU
    or emulator calls, segment arithmetic), and how big the hook layer is;
  * the estimated effort, compared with option 4.

  The study writes `docs/ext-IWC-F-record.md` with a recommendation. The user then confirms option 1 or switches to
  option 4.
* **Unchanged:**
  * full annotation;
  * portable C on SDL 3;
  * Windows first, then macOS (on the Mac mini, by a Claude desktop session there);
  * the Win32 civ64.exe stays;
  * nothing published before parity with the recovered implementation;
  * no original or DOS bytes in the repository.

  The facts-as-data (names, types) are written fresh as data and audited, never copied as C text.

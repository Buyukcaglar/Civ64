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

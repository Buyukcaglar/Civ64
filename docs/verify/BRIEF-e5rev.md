# Brief: units CRT2, D7g3, WL2 and PUB2 (the user's directions of 2026-10-18 about 23:20 UTC)

Written by the E4 orchestrator on 2026-10-18 about 23:30 UTC. Order: after AMS lands, D7g3 and WL2 (either order,
one landing cycle at a time), then PUB2, then IWC (`BRIEF-pub.md` "Unit IWC"), which stays the last task of all.

## The user's directions, verbatim (session E4, chat, 2026-10-18 about 23:20 UTC)

> For DOS grphics mode;
> D7g2-9: the science advisor's recommendation has the following bug, relevant screenshot updated. Recommendation
> dialog box has another visible dialog box underneath it. Position and width of it's box shall be; it's left &
> bottom side's shall be aligned with 'Status' window Left and bottom, and it's width shall be same as the 'Status'
> window width.
>
> Aside from that; Note that WL passed all its visual inspection, but there are following revision to be implemented,
> and these revisions are to be scheduled after AMS completed;
>
> In Windowless play mode;
> 1. Both DOS and Windows menu bar/area shall start from the top left of the canvas effectively above the "World Map"
> 2. Again for both graphics mode 'Status' window's bottom shall be aligned with the bottom of the play canvas
> (increase status window height while preserving its visual identity)
>
> After this task, before starting 'IWC', publish the updated project and update the latest build on the github as
> v1.1, update relevant documents, and readme and release information on the github.

The user's follow-up message: "aforementioned D7g2-9 bug screenshot".

## Unit CRT2: CRT scanlines fixes (right after AMS, by the extras agent)

The user, verbatim (2026-10-18 about 23:50 UTC): "Checked 'crt', there is a extreme slowdown problem when CRT
scanlines option enabled from the menu, investigate and fix the implementation. Aside from that this implementation
smoothes display, the choice combinations I specified on DosBoxPure Unleashed has not such effect, re check
implementation for this issue."

* **Slowdown:** find the cause by profiling, and fix it so that CRT on shows no visible slowdown against CRT off. Add
  a guard test or timing check.
* **Smoothing:** re-read DOSBox Pure Unleashed's source for "sharpest" and "Only Scanlines". The picture must be
  as sharp as with CRT off (nearest-neighbour pixels, no blur, no bilinear or halftone stretch, no horizontal
  filtering), only the scanline gaps added. Record what was wrong.
* CRT-1 and CRT-4 failed and stay pending. Checks: CRT2-n rows plus re-checks of CRT-1..CRT-5. User build
  `build/user-builds/crt2/`.

## Unit D7g3: the science advisor's recommendation box (DOS graphics)

* **The screenshot:** `claude/port/build/e5rev/D7g2-9-bug.png`. It was copied from the user's
  `Downloads\DOS Science Advisor Recommendation Bug.png` on 2026-10-18 about 23:40 UTC. `build/` is git-ignored, and
  the screenshot shows DOS graphics, so it is never committed or published.
* **What the screenshot shows:** it is the DOS
  graphics in the normal windowed layout at 1922x1432, with CHIEF.SAV's route (3520 BC) and D7g's research choice
  "Which discovery should our wise men be pursuing, sire?" centred.
  * The recommendation box "SCIENCE ADVISOR: I RECOMMEND WE DEVELOP CURRENCY. SO WE CAN BUILD: -MARKETPLACE" stands
    at its DOS place on the left, at about x 55..425, y 670..820 in the screenshot. That is over the Status window's
    lower part, and it reaches past the Status window's right edge.
  * A second box's frame is visible underneath it, offset to the lower right: an edge at about x 330..415,
    y 825..868, beside the Status window's right edge.
* **What the user wants:**
  * the recommendation box's left side on the Status window's left side;
  * its bottom side on the Status window's bottom side;
  * its width equal to the Status window's width;
  * no second box visible underneath it.
* **The current state:** this is deviation 5 (FIDELITY F319), checklist item D7g2-9 (`ext-D7g2-record.md`). D7g2-9
  failed and stays pending until D7g3's user build.
* **Investigate first:** where the underlying box comes from. It may be a stale earlier draw, a shadow or frame of
  the DOS O4 box, a second element id, or the Windows dialog's DOS counterpart drawn twice. Fix the cause, not just
  the place.
* **Places:** the box's place follows the Status window's current rectangle, also when the windows are moved,
  zoomed or full screen. Text wraps to the new width the way DOS wraps it (the DOS box's font and colours stay).
* **Checks:** D7g3-n rows in the record and the user build. Update FIDELITY F319's wording at the docs pass.

## Unit WL2: windowless play revisions (both graphics)

1. **The menu bar:** in windowless play, the menu bar or area, Windows and DOS, starts at the canvas's top left. So
   it runs across the top above the World Map, not only above the map.
   * The World Map, the Status panel and the map move down below it.
   * WL's F322..F325 and the arrangement topology change accordingly.
2. **The Status window:** in windowless play, in both graphics, the Status window's bottom is on the play canvas's
   bottom.
   * The Status window grows in height to reach it, and keeps its visual identity: the same frame, texture, fonts
     and layout of its contents, with the extra height as more of the same panel background.
   * Its contents are not stretched.
* WL-1..WL-9 passed (the user's "WL passed all its visual inspection", 2026-10-18 about 23:20 UTC). WL2 must keep
  them: on-the-fly switching, no scroll bars, the World Map click and the play-map click, the remembered setting,
  full screen/scaling/zoom, and the unchanged screens before the game.
* **Checks:** WL2-n rows in the record and the user build.

## Unit PUB2: publish v1.1 (before IWC)

* Commit and push the updated project to Civ1RE `main`, non-force, as PUB did:
  * only `claude/` paths;
  * no original or DOS bytes, game zips, saves, frames or binaries;
  * `claude/work` and the frame dumps in `claude/port/1` stay out.
* Update the public `Buyukcaglar/Civ1` with a further commit using the noreply e-mail
  `<e-mail removed>`:
  * the README: features added since v1.0 are WL, A43, CRT, AMS, D7g3 and WL2;
  * `docs/USER-GUIDE.md`;
  * the relevant docs, audited as in PUB.
  * Still no code: no `port/core` and no `claude/src`. IWC adds the independently written code later.
* Create release `v1.1` with release notes and `civ64.exe` from the last Release build. Check in the built-in
  browser that the README and the release show correctly.
* Before PUB2: the docs pass for WL, A43, CRT, AMS, D7g3 and WL2. That covers DESIGN, RUNNING, FIDELITY (F322
  onward), FEATURES and the checklist rows. Then a closing all-variant build/test and the hash check.

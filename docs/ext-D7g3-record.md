# Extension unit D7g3: the science advisor's recommendation box (DOS graphics)

## Result

The second box under the recommendation is gone, and the recommendation now stands on the Status window: its left and
bottom sides on the Status window's left and bottom sides, its width the Status window's width, its lines wrapped to
that width by the DOS wrapping rule.  It follows the Status window's rectangle (moved, zoomed, full screen, windowless
play), while it shows and while it is held under the research choice.

## Status

Implemented, built and tested privately (overlay = tree after CRT2 + this stage); landed (section "Landing").  The user
checks D7g3-1..D7g3-4 (D7g2-9 stays pending until then).

## The user's words

Brief `docs/verify/BRIEF-e5rev.md`, "Unit D7g3" (the user's direction of 2026-10-18 about 23:20 UTC, verbatim there):
"Recommendation dialog box has another visible dialog box underneath it. Position and width of it's box shall be; it's
left & bottom side's shall be aligned with 'Status' window Left and bottom, and it's width shall be same as the 'Status'
window width."  Screenshot `build/e5rev/D7g2-9-bug.png` (git-ignored).

## The cause of the second box

* The screenshot is windowless play (WL; no window chrome, the World Map at the top left, the menu bar beside it),
  1920x1400 client, the game screen following the view (`--game-screen view`).  Reproduced headless with
  `--windowless 1 --host-size 1920x1400 --game-screen view` on D7g's CHIEF.SAV route
  (`obj/run/wl/last-tick-00637.png`): a second, partly hidden box beside the Status piece showing the recommendation's
  line ends ("...R:", "...ET.").  Without windowless play (the same size) there is none (`obj/run/big/`).
* WL's composition (`present/wl.c` compose) copies each piece's visible region from the frame, then draws the floats.
  A DOS graphics box (an A element of `pdos_reskin.c`) is drawn into the A frame over the windows' clients; it is not a
  window, so no piece's visible region excludes it.  The box straddled the Status client (piece S) and the map client
  (piece M): the float was drawn at its anchor's translation (S, which holds its centre), and M's copy of the box's
  right part stayed at M's translation: the second box.  Not a stale draw, not a second element, not the Windows
  dialog (the element list holds one box; the presentation-diag counts are D7g's).
* The fix (the cause): a piece leaves a DOS re-skin float's rectangle black where the float is moved otherwise than the
  piece (`PwlScene.flbox`, `PwlFloat.box`, compose), as WL already leaves black the windows above a piece; the float
  alone shows the box.  pwl_check's relation (every canvas pixel the arranged frame pixel or black) holds.

## Design

* `pdos_reskin.c`: `AT_STATUS` (replaces D7g2's `DOS_KEEP`) for the recommendation (`PDOS_R_PAIR_ADVICE` with its
  call's DOS place); `at_status`: the Status window (g_statusWindowPort 12B0:0034, the same port wl.c reads; shown, not
  iconic): its window rectangle, in windowless play (`pdos_reskin_set_windowless`, which pdos_profile.c sets from `present_windowless_showing` at each present: present/dos may not include wl.h) its client rectangle (what the canvas shows);
  the place's x its left, y its bottom (`PdosRPlace.bottom`: `pdos_r_place_xy` puts the box's bottom there), the box
  width `PdosRSpec.fix_w` = the width / 2 DOS pixels (the A element is 2x; an odd width leaves one pixel at the right).
  The canvas clamp of 11.3 still applies.
* `draw`: with `fix_w` on A, each DOS line (the recommendation's lines as DOS breaks them at its line feeds) is wrapped
  by R:1F4D:0088's rule (`wrap_piece`: before the word that would pass the width, at the last space) at the width the
  frame leaves (the extent less the widest line: 11 DOS pixels for the plain box), then the box's right side is moved
  out so its extent is exactly `fix_w`.  Font 2, colours, frame and texture unchanged; no header (DOS's 2F9E is -1).
* `place_all` (each present): the live recommendation box is re-placed through `a_place_of` (now at the Status window)
  and drawn again when the Status width changed; the held one (`PDOS_R_HELD_ID`, no window) follows by `restatus`.
  Diagnostics: preskin2's `st_l st_t st_r st_b st_moves`.
* No core read beyond the window port and w16q's window rectangles; no core call, no input change (P0).

## Evidence

* DOS listing: the recommendation's text and place (R:0ADE:1A18..1B2C, D7g); the wrap rule R:1F4D:0088 (pdos_glyph.h,
  D5b).  Inferred: the user's place (accepted design change, the user's direction); DOS has no Status window.

## Deviations

1. **The place** is the user's (Status window), not DOS's (8, 168 - 8n): supersedes D7g2's deviation 5 (F319).
2. **Wrapped lines**: DOS breaks the recommendation only at its line feeds (its box is as wide as its widest line); at
   the Status width a line wider than the box is wrapped by DOS's own wrap rule (R:1F4D:0088), so e.g. "SCIENCE
   ADVISOR:" may become two lines on a narrow Status window.
3. **WL**: a DOS box lying over two pieces shows once (at its anchor piece's translation); the other piece shows black
   under its part (before: a second copy of that part).

## Tests

* **test_wl** (+9 checks, 60): `dos_box`: a box float over the Status and map clients, anchored at M: no pixel of S's
  copy of its part (black), the box whole at the float's place, the definition model (which now leaves such parts
  black) and pwl_check, the part recomposed after the box goes (fails on the base: the struct has no `flbox`; with the
  base composition the ghost pixels are counted).
* **ext_adapt** d7g-dos/-flip/-switch/-esc: the held recommendation's left and bottom on preskin2's Status rectangle,
  its width the Status width (even), besides D7g2's checks (fails on the base: no `st_*`, D6fSd's place).  Private run
  (`obj/adrun.py d7g3 d7g_runs`): all d7g checks ok (the held box at (0, 354), 168 x 126 on Status 0,119..168,480);
  the four DOS/Windows pairs equal (P0).
* Frames viewed (private): `obj/run/n-wl/` (windowless, 1920x1400: the box on the Status piece's bottom, no second
  box), `obj/run/n-win/` (windowed: on the Status window's bottom, its width).

## For the records

* FIDELITY: F336 (supersedes F319's place: the recommendation on the Status window's left/bottom at its width, its
  lines wrapped by R:1F4D:0088's rule; WL: a DOS box over two pieces shows once, black under it in the other piece).
* DESIGN: WL section (compose: DOS re-skin floats left black in other pieces); D7g section (AT_STATUS).
* DOS-PROFILE: none.  RUNNING: test_wl 51 -> 60.

## What the user checks

* **D7g3-1** DOS graphics, CHIEF.SAV (D7g's route: load it, play the turn until the science advisor recommends): the
  recommendation box ("SCIENCE ADVISOR: I RECOMMEND WE DEVELOP ...") has no second box or frame underneath or beside
  it, in the normal windows and in windowless play.
* **D7g3-2** Its left side is on the Status window's left side, its bottom side on the Status window's bottom side, and
  it is exactly as wide as the Status window; the DOS letters, colours and grey box stay, the text wraps inside it.
* **D7g3-3** Repeat with the window larger or smaller, the map zoomed (Ctrl+Shift+Plus/Minus), full screen (Alt+Enter)
  and with Windowless play on and off: the box always stands on the Status window's bottom left at its width.
* **D7g3-4** The research choice is still centred and works as before (Return, Escape, a click); choosing ends both
  boxes.

## Expected changes at the build slot

* test_wl 51 -> 60 checks; ext_adapt's d7g checks reworded (count unchanged); every other count and golden unchanged
  (the recommendation appears only on D7g's route; ext_zoom/ext_wl samples hold no DOS box over two pieces).  P0
  unchanged.

## Rebase notes

Bases `BASE-SHA256.txt` (the tree after CRT2: present/wl.c, wl.h, present/dos/pdos_reskin.c, .h, pdos_profile.c, tests/test_wl.c,
tests/harness/ext_adapt.py).  Line endings kept (pdos_profile.c CRLF, the others LF).

## Landing

D7g3 landed at the build slot of session E5 on 2026-10-19 after CRT2 (build/crt2-prep/LANDED.txt).

* **Bases** equal to the tree after CRT2 (`BASE-SHA256.txt`, 7 files).  Private overlay (tree + D7g3) Checked,
  CheckedNoObs and Release BUILD_OK, every unit and Win32-headless test passing in the three variants; REGISTRY_OK,
  OBS_LINT_OK (156 files, 203 probes, 103 call sites), pdos_scene_check PASS 1086, ADAPT_OK 166 rows, NODOS_OK; the
  d7g pairs (`obj/adrun.py d7g3 d7g_runs`) all ok.
* **Copy-in** 02:07:59 UTC (`build/d7g3-prep/land.py d7g3 --write`, 7 files, line endings as the tree).
* **The cycle** (`build/d7g3-status.txt`): 1 `build.cmd checked` BUILD_OK 02:08:02..02:11:20; 2 `test.cmd checked`
  TESTS_OK 02:11:20..02:40:29 (1,748 s; test_wl PASS 60 checks, EXT_ADAPT_OK checks 389, P0_OK checks 577,
  WL_PAIRS_OK checks 15); 3 `ext_g1.py check` EXT_G1_OK runs 77: **ALL_GREEN** 02:40:29 UTC; 4 `build.cmd` (Release)
  BUILD_OK 02:40:29..02:43:38: **RELEASE_OK**.
* **Against the predictions** (`build/d7g3-prep/predictions.txt`): as predicted.
* **User build** `build/user-builds/d7g3/` (D7g3-1..D7g3-4; with CHIEF.SAV from build/user-builds/d7g). FIDELITY F336.

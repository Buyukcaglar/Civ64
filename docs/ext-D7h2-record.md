# Extension phase D7, unit D7h2 (the DOS entry page above the menu boxes; D7h-6's fix) - record

Draft for the build slot (the orchestrator's D7h2 of 2026-10-18 10:52 UTC, from the user's report of about 10:50 UTC:
"d7h all but 'D7h-6' passed. D7h-6 has the 'production menu stays on Civilopedia screen' bug on DOS graphics mode.";
the plan approved at about 11:06 UTC with the private element ids 0xFF58 (N canvas) and 0xFF59 (A canvas) of the
orchestrator's message about 11:12 UTC; extension session E4).  Staged in `build/d7h2-stage/` on the tree after D7i's
landing (copy-in 10:25:44 UTC, ALL_GREEN 11:00:39 UTC, RELEASE_OK 11:04:25 UTC); each base copied at 11:06 UTC
(`obj/base-at-copy.txt`), every base the tree's file now (`BASE-SHA256.txt`).  Private builds and runs in
`build/d7h2-stage/obj/` only: the overlay `obj/src` = the tree + the stage (`obj/mkoverlay.py`, `obj/sync.py`,
`obj/ovcheck.py`), built with the tree's build.cmd and flags (`obj/b.cmd`, `--nogen`), cc.cmd's stricter checks per
file (`obj/cc.cmd`), the unit programs (`obj/unit.py`) and the harness runs from the overlay's binaries with every
output under `obj/`; the tree's build/gamedata, dosdata, dos/disasm and cache read only.

## Result

The bug, reproduced privately first (`obj/explore.py prodhelp`, the tree's own Checked harness, PNGs in
`obj/run/shots/`): with the DOS graphics, the production list's help (Alt+H, or the right button on a row) drew D7h's
DOS entry page on page 0 of the N canvas, but the production list is a DOS box drawn as an element above page 0
(D7f's pdos_rdlg box, a pdos_reskin R element on the N canvas): its 3,617 pixels stayed over both of the page's shows,
page A and page B.  DOS's O8:062A draws the whole screen; the list comes back only after it (R:0866:25D7).

The fix (`present/dos/pdos_scn_pedia.c/.h` only): while an entry page (ShowCivilopediaEntry) shows, the page is also
set as an element above every element of both canvases: on the N canvas the page itself (id `PDOS_PEDIA_COVER_N_ID`
0xFF58), on the A canvas the page at 2x centred on the canvas with index 0 round it in the page's palette (id
`PDOS_PEDIA_COVER_A_ID` 0xFF59; the research choice's box, dialog 145, is an A element).  Both are set at page A's draw
and again at page B's (page B is drawn over page A as the cover shows it, whatever was drawn on page 0 below in the
meantime), and removed at the entry's end before page 0 and its DAC are restored as D7h does.  The boxes under them are
not touched: the production list comes back with the same highlight at the same place (the show after the end equals
the show before Alt+H byte for byte).  The index and the index's own pages (from the CIVILOPEDIA menu) have no box
under them and are unchanged.  No core change, no random draw, no PDOS_AS bit, owner, adapter or scene row; two
private element ids, as agreed.

## Status

LANDED 2026-10-18 (copy-in 11:53:43 UTC, ALL_GREEN 12:36:44 UTC, RELEASE_OK 12:40:13 UTC; section "Landing"), before
D7g2 (the orchestrator's go at about 11:53 UTC).  The user checks D7h2-1..D7h2-3 are pending.

## Files

Changed (`BASE-SHA256.txt`): `present/dos/pdos_scn_pedia.c`, `present/dos/pdos_scn_pedia.h`,
`tests/test_pdos_pedia.c`, `tests/harness/ext_adapt.py` (all LF).  New: this record.  build.cmd and test.cmd
unchanged; no new source file (portable sources 310 as D7i).  The D7h2 parts are blocks marked `extension D7h2`.

* `pdos_scn_pedia.h`: the two ids and the comment on the covers; `PdosPediaQ.a_size` (the A canvas's size,
  w16q_screen by default; a member at the end, NULL keeps the default); `PdosPediaDiag.covers` and the diagnostic
  line's last field `covers`.
* `pdos_scn_pedia.c`: `cover_copy`, `cover_elem`, `cover_put`, `cover_drop` before `entry_begin`; `cover_put` at the
  end of an entry's page A (page_begin) and page B (page_b_now, page A first copied back from the cover); `cover_drop`
  first in `entry_end`; `pdos_pedia_reset` removes the elements and frees the two surfaces.

## Tests

* `tests/test_pdos_pedia.c` (73 checks, D7h's 67 + 6): the production help's run with a box element on each canvas
  (an N box of 60 x 30 in colour 77h and an A box): before the help the box's 1,800 pixels compose; on the page none,
  each canvas two elements, `covers` + 1; after the end the box's 1,800 pixels again and one element a canvas; and the
  two ids differ from each other and from the other private element ids (PDOS_R_BAR_ID, PDOS_R_DROP_ID + 0..7,
  PDOS_R_COVER_ID, PDOS_R_HELD_ID, PDOS_APLAY_NUKE_ID, PDOS_NEWS_STRIP_ID / _EDGE_ID / _BOX_ID).
* `tests/harness/ext_adapt.py`, the d7h2 runs (`d7h2_runs`, 6 checks):
  * d7h2-help (S3 to the city screen, c, Alt+H at 53.5 s, Space at 55 s, Return at 56 s, `--presented 2
    --dump-presented`): the rows I-city/key, I-menu/list-mod, I-menu/list-key, I-pedia/page-key x 2, Alt+H giving the
    core the row's click and the Help button's; timeline.log's pedia_page O8:062A (200) and O8:087D (201), pedia_end;
    the frames: the menu's pixels (where the menu's last show before Alt+H differs from the city screen's before c),
    in each of the page's shows under 5 % equal to the menu's (the bug: 3,541 of 3,617 in both), and the show after
    the end equal to the menu's; presentation-diag `pedia` covers 1, nopic 1, restores 1; the Windows-form pair (the
    same lines, c as its character, the two clicks where the DOS run gave them, Space, Return) with equal core
    outputs.
  * d7h2-research (D7g's CHIEF.SAV; the units, the discovery and the advance's page with D7G_ROWS' keys, Alt+H on the
    research choice at 36 s, Space twice): both entry pages' shows all 320 x 200 (no A frame while a page shows),
    covers 2.
  * On the tree's unfixed harness (`obj/radapt-bug`) the frames, the diag and the research checks fail (3 of 6).

## Results (private, `build/d7h2-stage/obj/`)

Session E4 (2026-10-18), on the overlay = the tree after D7i's landing + the stage (11:06..11:53 UTC):

* **Builds**: Checked, CheckedNoObs and Release BUILD_OK, portable sources 310; test_pdos_pedia relinked in each
  variant after its last edit (`obj/t.cmd`, `obj/tl.cmd`).
* **cc.cmd** on `pdos_scn_pedia.c` and `tests/test_pdos_pedia.c`, each variant: CC_OK.
* **Unit**: 66 programs pass in each variant; test_pdos_pedia 73 in each.
* **Generators** on the overlay: REGISTRY_OK; OBS_LINT_OK files 152 probes 203 callsites 103; OBS_TABLES_OK 203 /
  103; pdos_scene_check PASS 1084 (141 scene rows); ADAPT_OK rows 161 steps 27; NODOS_OK (all as D7i's).
* **ext_adapt, the whole suite** (`obj/runadapt.py ... all`, 11:35..11:48 UTC): EXT_ADAPT_OK checks 399 (D7i's 393 +
  the 6 d7h2 checks).
* **ext_timeline, the base group**: EXT_TIMELINE_OK, 65 PASS lines (as D7i's).
* **ext_p0 and ext_mirror, the subset** (the tree's scripts with the private harness, `--vars V0,V1,V2 --only
  retire,conquest,arrival`): P0_OK checks 21; MIRROR_OK runs 3, checks 1,074, present_mismatched 0, unexplained 0.
* **Frames looked at** (`obj/explore.py`, `obj/shot.py`): the production help's page A (SETTLERS, its unit figure
  beside the name, the text) and page B (Requires, Cost, the strengths) alone, the list back after the end; the right
  button on Militia's row: Militia's page alone; the research choice's help: Alphabet's page alone, the research
  choice back after the return's fade.

## Deviations and observations

1. **The cover on the A canvas** is the page at 2x centred on the canvas with index 0 (the page palette's colour 0)
   round it.  In the runs the A frame is not presented while an entry page shows (the page's scene presents the N
   frame), so it is never seen; it keeps the research choice's box from showing over the page should the A frame be
   presented then.
2. **A show at an entry's opening instant** (seen, not changed): at the page's opening the A frame is presented once
   at the same virtual microsecond, before the page is drawn (the core's present before ShowPediaEntry): over the city
   screen it is the Windows city dialog's picture (`obj/run/shots/prodhelp-53000.png`, the bug run's file 81), after
   the discovery the map.  No virtual time passes before the page replaces it; it is D7h's and D7f's as before, not
   part of D7h-6.  For the orchestrator's queue if the user reports a flicker there.
3. **A unit's entry page without pictures** still has the unit's small figure beside the name (O8:0A8F..0AA4, DOS's;
   D7h's), only the big picture is left out: D7h2-1's wording says so.

## What the user checks

* **D7h2-1** (D7h-6 again, as build "d7h" worded it) In a city, the production menu ('c'), Alt+H or the right mouse
  button on an item: its DOS entry page without the picture (the name, the category and the text), then the
  production menu again.  Now: while the page shows, no part of the production menu is drawn over it (the page alone,
  its border all round; a unit's page has its small figure beside the name, as in the DOS game); a key or a click on
  the first page shows the second, the next key or click returns to the production menu, with the same item
  highlighted at the same place.  Both Alt+H and the right mouse button.
* **D7h2-2** The research choice: load CHIEF.SAV, press Space for each of the four units until the turn ends, Space on
  the discovery's picture and on the advance's pages until the research choice shows.  Alt+H (or the right mouse
  button) on the highlighted advance: that advance's DOS entry page alone, nothing of the research choice's box over
  it; its two pages, then the research choice again, unchanged.
* **D7h2-3** The same with the Windows graphics: the Windows Civilopedia over the production menu and the research
  choice, unchanged.

Not part of this check: switching the graphics while the Civilopedia shows.

## For the records

* **DOS-PROFILE** (for the docs pass; not staged): the entry page's rows 11 and 99 "as implemented": the page above
  every box of both canvases (D7h2), DOS's whole-screen O8:062A.
* **DESIGN** (12.x, D7h's renderer): the entry page's covers `PDOS_PEDIA_COVER_N_ID` 0xFF58 / `_A_ID` 0xFF59, private
  ids outside the handles; D7g2's `PDOS_R_HELD_ID` 0xFF50 (A).  The distinct-id vector is in test_pdos_pedia (D7g2's
  test_pdos_reskin gains its own).
* **RUNNING**: presentation-diag's `pedia` line ends with `covers`; ext_adapt's d7h2 runs (`d7h2-help-dos` /
  `-win`, `d7h2-research-dos`).
* **STATUS / checklist**: D7h-6 superseded by D7h2-1 (D7h2-1..3 pending).

## Expected changes at the build slot

Against D7i's landing (`build/d7i-*.log`): portable sources 310 (equal); test_pdos_pedia 67 -> 73 checks, every other
program equal; EXT_ADAPT_OK 393 -> 399; EXT_TIMELINE_OK, P0_OK 476, MIRROR_OK runs 29, EXT_G1_OK runs 77, REGISTRY_OK,
OBS_LINT_OK files 152, OBS_TABLES 203 / 103, pdos_scene_check 1084, ADAPT_OK rows 161 steps 27, NODOS_OK unchanged.
If D7g2 lands first: its counts plus these.

## Rebase notes

D7g2 (staged on the tree after D7i, `build/d7g2-stage/`) changes `tests/harness/ext_adapt.py` and
`tests/test_pdos_reskin.c`, `present/dos/pdos_reskin.h` among others; of D7h2's files only `ext_adapt.py` is shared.
D7h2's part there is one block after D7i's section and one line in main (after `d7i_runs`): a three-way merge with no
overlap expected.  If D7g2 lands first: the merge, the base rewritten, the overlay rebuilt, the builds, the unit
programs, ext_adapt and ext_timeline rerun privately before the landing's cycle.

## Landing

Landed 2026-10-18 by the build slot, on the tree after D7i's landing (the bases unchanged; no rebase).

* **Copy-in** 11:53:43 UTC (`build/d7h2-prep/land.py --write`): 5 files byte for byte (4 changed, every base equal to
  the tree; 1 new: this record), the tree's previous files in `build/d7h2-prep/tree-before`, the Checked test outputs
  before in `build/d7h2-prep/before`, the list in `build/d7h2-prep/landed.sha256`; build.cmd and test.cmd unchanged.
* **The cycle** (`build/d7h2-prep/d7h2-cycle.ps1 -LastStep 4`, `build/d7h2-status.txt`):
  * 1 build.cmd checked: BUILD_OK, 268 s (11:53:48..11:58:16), portable sources 310;
  * 2 test.cmd checked: TESTS_OK, 2,308 s (11:58:16..12:36:44);
  * 3 ext_g1.py check: EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events), as D7i; ALL_GREEN;
  * 4 build.cmd (Release): BUILD_OK, 209 s (12:36:44..12:40:13); RELEASE_OK.
* **Against D7i's cycle** (`build/d7i-*.log`): test_pdos_pedia 67 -> 73 checks, the other 41 PASS lines equal (42
  in all); EXT_ADAPT_OK 393 -> 399 (+6, the d7h2 runs); EXT_TIMELINE_OK, P0_OK checks 476, MIRROR_OK runs 29,
  REGISTRY_OK, OBS_LINT_OK files 152 probes 203 callsites 103, OBS_TABLES_OK 203 / 103, pdos_scene_check PASS 1084
  (141 scene rows), ADAPT_OK rows 161 steps 27, NODOS_OK and portable sources 310 equal.  As section "Expected
  changes at the build slot" said.
* **User build** `build/user-builds/d7h2/` (12:41 UTC, `build/d7h2-prep/mk_userbuild.py`): the Release civ64.exe,
  CIVWIN.zip and civdos.zip (from build "d4"), CAE3540B.SAV and CHIEF.SAV, WHAT-TO-CHECK.txt (D7h2-1 .. D7h2-3, and
  163 items still open from earlier builds per the checklist at 12:40 UTC).
* **Pending**: the user checks D7h2-1 .. D7h2-3; observation 2 (the A show at an entry's opening) is checked in a
  real civ64 window after the landing (the orchestrator's request).

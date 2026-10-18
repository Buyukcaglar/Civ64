# Extension phase D6, unit D6f (the menus on the A canvas; adapters I-play and I-menubar) - record

Draft for the build slot (BRIEF-d6.md "Units" D6f, extension session E3).  Staged in `build/d6f-stage/` on the tree
after the UX4b landing (build/ux4b-status.txt RELEASE_OK 17:06 UTC; D6d, UX4, D5P and P47b before it); the bases were
copied to `obj/base/` at 17:40:48 UTC, `tests/headless/harness.c` at 19:11 UTC (after the MZ landing, ALL_GREEN 18:12
UTC, and MZW's tests, ALL_GREEN 19:04:41 UTC), and `docs/DOS-PROFILE.md` again at 19:32 UTC after the docs pass of
about 19:20..19:31 UTC changed its prose (lines 155..159; the staged copy is that copy with only the generated section
1.7.2 replaced).  MZ and MZW changed none of the other bases.  Every base is rechecked equal to the tree in
`BASE-SHA256.txt`.  The orchestrator's follow-up of 2026-10-16 added the bases of `gen/obs_tables.py`,
`present/obs_tables.c/.h`, `present/map/pmap_dos.c`, `pmap_int.h` and `pmap_layer.c` (about 20:21 UTC); UX5
(ALL_GREEN 21:17 UTC) and MZI (ALL_GREEN 22:08 UTC) landed during it, so `present/dos/pdos_profile.c`,
`present/present.c` (UX5), `present/map/pmap_int.h` and `pmap_layer.c` (MZI) were re-based at about 22:22 UTC by
three-way merges without a conflict, and `tests/harness/ext-zoom-golden.txt` (MZI's copy) was added (its DOS lines
regenerated, "Expected changes").  MZS's files were copied into the tree at about 23:47 UTC: `present/map/pmap_dos.c`
and `pmap_int.h` re-based onto them the same way (no conflict); `docs/DOS-PROFILE.md` again at about 00:45 UTC after
the docs pass for UX5 (its lines 155..160; the staged copy is that copy with the generated section 1.7.2 replaced).
D6e (its files in the tree at about 00:55 UTC) re-based at about 01:12 UTC: `docs/dos/OFFSETS.md`,
`present/dos/pdos_profile.c`, `tests/headless/harness.c` merged, `present/dos/pdos_registry.c/.h`,
`tests/dos-decoded.txt` regenerated and `tests/harness/ext-zoom-golden.txt`'s DOS lines regenerated (section "Rebase
notes").  Private builds and runs in `build/d6f-stage/obj/` only (an overlay `obj/src` = tree
+ stage, built with build.cmd's own flags; the private runs use a copy of the overlay's Checked harness, `obj/exe`; the
tree's Checked harness of the MZI landing was copied once, read only, to `obj/exe/tree` as the reference of the
ext_zoom comparison).  Landed by the build slot on 2026-10-17 (section "Landing").

## Status

READY_TO_BUILD, re-based onto the tree after D6e's landing (ALL_GREEN 01:23:53 UTC), TLD's (ALL_GREEN 02:05:31
UTC; none of D6f's files, its test.cmd a read-only base here) and FCE's (ALL_GREEN 03:41:10 UTC; `pdos_adapt.c`
merged, FCE's Escape block first).  Draft B 11.2 (the menu bar, P24, and the
drop-downs), 11.3 (the A placement at 2x of D5b's generic re-skins, decision 1, ruling 1), ext-D4a C1 and draft C C.12.8
(I-play, I-menubar; I-menu on frame-2 points), C.12.9 and C.15.4 case 13 are built.  OPEN L3, L19, L25 and L27 are read
from the listing (section "OPEN L3, L19, L25, L27").  The orchestrator's follow-up of 2026-10-16 is built: O1, Escape on
the tax and luxuries rates and the revolution, quit and retire questions, each proven from its DOS and core callers
(section "Escape on the boxes in play (O1)"; every other box keeps the pass); the zoom layer never covers a DOS box,
drop-down, message box or the bar on A, at -1 and +1 (section "The A placement"); Choice D6f-6 (new, for review); the
Cancel / Go Back audit (no such row shown); R1..R4 with their D7 owners; O2 and O3 accepted.  The user's Escape rule is
recorded for every box D6f places in play (section "User direction 2026-10-16"): none is consumed.

Privately (on the tree after FCE's landing): the three variants build (296 portable sources, the tree's), cc.cmd's stricter checks pass on every changed
source and on the changed tests but test_input.c (its clang C99 parse reports only the base's own
missing-field-initializer, `square_only`, as before; build.cmd does not tidy the tests), all 49 unit programs pass in
Checked, CheckedNoObs and Release but test_dos, whose only failure is the goldens path (its output equals the staged
`tests/dos-decoded.txt` exactly; the tree's goldens lack the six new MENU rows); ext_adapt's D6f checks 34 of 34 and the
M/D6d part 15 of 15 (ring-dos against its new reference), the whole runner EXT_ADAPT_OK checks 189; FCE's ext_fce
(the tree's runner, D6f's harness) EXT_FCE_OK runs 8; ext_zoom (the tree's runner with the staged goldens, every
profile) ZOOM_OK; ext_p0 V0/V1/V2 on all 33 of its scenarios P0_OK (225 checks; the menus run in V1 sets 221
drop-downs and 31 A boxes); ext_frames
EXT_FRAMES_OK; obs_lint (callsites 101), adapters.py (ADAPT_OK rows 116 steps 25), pdos_scene_check, obs_tables (sites
101), registry.py and nodos.py checks OK.

## Design and decisions (with the listing)

### The menu bar (draft B 11.2, P24 settled; Choices B14, B15)

* **One A element at scale 1 over the Windows bar rectangle** of the shown top-level window with a menu
  (`w16q_menu_bar`: its menu, the bar and the titles' rectangles as w16 draws them), id `PDOS_R_BAR_ID` (FF01h, outside
  the window and menu handles).  Fill 0 (R:0238:0FEA..0FFD, the DOS bar's fill; colour 0 at R:0000:0BFA); font 1 at
  scale 1 (B15: the DOS font at 1x beside the 2x art); each title at its Windows title rectangle's left + 8 (w16's
  MENU_PAD), vertically centred.  Clipped by the windows above (B 6.2: the element's region is the window's visible
  region, a dialog or an open popup over the bar is not covered).
* **Titles.**  File, Orders, Advisors, World and Civilopedia show the DOS titles GAME, ORDERS, ADVISORS, WORLD,
  CIVILOPEDIA: the registry's new table MENU_TITLES (DGROUP:1D6F, five strings, the five pushes at R:0238:1011,
  1029, 1041, 1059, 1071), drawn raw in colour 15 as R:0238:1005..1075 draws them, the 87h switch in each string giving
  the rest of the title colour 7.  A title is paired by its popup's commands (`pdos_r_menu_title`: the hundreds of the
  first command id, resources.md MENU 128).  Edit, City and Help (Windows-only titles) are drawn in capitals with 8Fh
  before the mnemonic letter and 87h after it: the mnemonic in 15, the rest in 7 (B14).
* **The highlighted title** (the menu loop's selection on the bar, `w16q_menu_state`; not the system-menu box) is
  recoloured 0 -> 11 over its title rectangle (11.2 P24: the menu box's highlight).
* Draws only when the bar's window, its menu, a title, its text or the highlight change (`bar_draws`).

### The drop-downs (11.2; OPEN OB5, L19, L25; ruling 2; Choices D6f-2, D6f-3)

* Each popup of the running w16 menu loop but the system menu (W7) is a DOS menu box in font 1 on the A canvas at 2x,
  anchored at the Windows popup's top-left (`w16_menu_track_item` gives each open popup's item rectangles; new, read
  only).  Ids `PDOS_R_DROP_ID` + level (FF11h..FF17h).
* **Choice D6f-2:** the box is at least as large as the Windows popup with w16's 2-pixel shadow (MT_SHADOW), so the
  Windows popup never shows around it, and every row covers its Windows item (so I-menubar can map a row to the item it
  shows).
* **Rows** follow `w16q_menu_item` (ruling 2: the core's state decides which items exist): one row per Windows item;
  separators as empty disabled rows; grayed or disabled items in colour 3 (the DOS disabled colour; a hit keeps the
  previous row); checked items with the DOS check mark '^' (OPEN OB5 / L19: R:1D05:0939..0951 writes 5Eh as a marked
  line's first byte for the bits of DGROUP:D7F2, as the GAME menu's Options marks its settings, R:1C84:014B..014E;
  `PdosMenuBox.marks`, rows 0..15 as the DOS 16-bit shift); the loop's highlighted item as the box's highlight.
* **Texts (ruling 2, OPEN L25).**  An item paired by role takes the DOS row's text: GAME (DGROUP:2BD4, read by
  R:1C84:00C0) for Tax Rate, Luxuries Rate, Find City, Options, Save Game, Revolution, Retire and Quit; Options
  (DGROUP:2C3E, R:1C84:013B, with its header line as the popup's header) for its eight settings; ADVISORS (DGROUP:2DD6,
  R:1C84:061B / 062B) for 401..406; WORLD (DGROUP:2E5D, R:1C84:06F8 / 0708) for 501..506; CIVILOPEDIA (DGROUP:2ED1,
  R:1C84:07B5 / 07C5) for 601..606.  Five new registry rows (MENU_GAME, MENU_OPTIONS, MENU_ADVISORS, MENU_WORLD,
  MENU_PEDIA; ruling 8) besides MENU_TITLES.  **Choice D6f-3:** an unpaired item (ORDERS: built per square at run time,
  R:1C84:01D8, so no static row pairs; Edit, City, Help) shows the core's display text in DOS font 1 and, after a
  space, its accelerator in colour 15 (8Fh), as DOS's ORDERS rows show their keys.  Retire's View Replay (R:1C84:00D0..
  00E0) has no core item and is not shown.
* A drop-down is redrawn when the loop's selection or the popup's items change; it is removed when its popup closes.

### The A placement of D5b's re-skins (11.3, Choice B16; decision 1, ruling 1; ext-D4a C1)

* While the frame presented is A (`pdos_compose_kind`), the generic boxes of the MenuZ dialogs 136 and 145 (rows 14 and
  22) and every `#MsgBox` are A elements at 2x anchored at their Windows window's top-left (device pixels), clamped
  inside the canvas (moved left or up), the windows above them excluded (6.2); framed (laid out at y 0: no page 0 lies
  under an A box), textured as DOS draws in play (DGROUP:2F98 = 1, set by R:01A8:0815 on New Game and Load before any
  play state), on the play palette.  A box is on one canvas at a time with its own surface (C1); a change of the frame
  kind moves it at the next core present (`pdos_r_place`).  The other MenuZ dialogs bound to class R rows (17 the
  production list, 18 the unit stack, ...) stay on the N canvas: their scene-specific forms are D7's (ruling 1).
* The message box's rows exclude IDCANCEL (D5f's rule, unchanged); dialog 145's DOS "(HELP AVAILABLE)" line
  (DGROUP:2FBD) is not added (a D7 scene matter; report item R4).
* **Choice D6f-6 (found while checking the zoom, 2026-10-16):** an A box is at least its Windows window's size at 2x
  (`PdosRPlace.win`, the window's width and height halved, rounded up, the outline included; `min_size_win`), as
  Choice D6f-2 does for the drop-downs.  Before it, a DOS box smaller than its Windows window left that window's rest
  visible beside or below it: the tax box (231 x 272 Windows pixels against the DOS box's 278 x 205) showed the Windows
  dialog's last radio item and its OK button under the DOS box at every zoom level.  Now the DOS box covers its window;
  the added part is the box's own textured background below or beside the rows (no row, no hit: a release there is
  outside every row).  Alternative (not built): the map under the uncovered rest of the window (the A compositor
  drawing the map element there, the layer drawing over it at -1 and +1), which keeps DOS's tight box but needs a
  compositor rule and a second layer region.
* **The zoom layer's z order (the orchestrator's direction of 2026-10-16).**  The map layer (M, D6d) is put into the
  host view after the scaled A frame, inside the map client's visible region; a DOS box, drop-down or message box
  lies at its DOS extent, not its Windows window's, so the layer covered every part of it outside its Windows window
  (seen at -1 and +1: the tax box's right part and the GAME drop-down's bottom).  `pmap_overlay` now leaves out the
  re-skins' rectangles while it draws the DOS profile (`pmap_dos_cover` -> `pdos_reskin_a_rects`: every A box,
  drop-down and message box and the menu bar, converted with `present_host_rect`, every host pixel they reach;
  `put_open` cuts each piece of the clip around them).  The layer's geometry, clip and image, the per-profile
  samples, the Windows profile and the shared exclusion geometry (popups, the move or size outline: D6c, MZS's
  scope) are unchanged; a box appearing or going damages the A frame, whose scaled rectangle is the layer's re-put
  rectangle, so no stale layer or box pixel remains.

### I-play, I-menubar, I-menu and I-pass on frame 2 (draft C C.12.8, C.12.9, C.15.4 case 13)

* **Frame 2 is decided by rows** (`pdos_adapt.c`; DOS-PROFILE.md 1.7.2 regenerated: 18 new rows with O1's, 116 in
  all, 25 step sequences).  The A scene at the sync (`def_ascene`, after `pdos_seq_advance`): the w16 menu loop running ->
  PDOS_AS_AMENU (I-menubar); a re-skinned MenuZ box on top of the A canvas -> PDOS_AS_RMENU with the frame-2 hit
  geometry (`pdos_r_hit` with PDOS_FRAME_A: D5's I-menu rows unchanged); a re-skinned message box on top ->
  PDOS_AS_AMSG; the menu bar's window active -> PDOS_AS_PLAY (I-play; **Choice D6f-1**: only while that window is
  active, because the menu paths need its menu bar; with the World Map or Status window active, or a Windows-layout
  dialog, frame 2 is PDOS_AS_ANONE and everything passes, I-pass); else PDOS_AS_ANONE.
* **I-play (C.12.8).**  F1..F10 without modifiers (scan codes 3Bh..44h, R:0403:3B8A..3BFF: the reports) become
  Ctrl+1..Ctrl+9, Ctrl+0 as complete pairs (Ctrl down, the digit down and up, Ctrl up; act PDOS_A_CTRL): commands
  401..406 and 501..504 through ACCELERATOR 128; the F key's release and repeats are consumed; with Alt, Ctrl or Shift
  held an F key passes.  Alt+V (2F00h, R:0403:3B9F -> 384E: the sound toggle) reaches command 109 through its menu path
  (act PDOS_A_MENU: the mnemonics read from the menu at the press, File, Options, Sound, the first with Alt, the user's
  held Alt serving when the core holds it; `pdos_reskin_menu_path`; consumed with a diag when the path is missing or a
  mnemonic is ambiguous or grayed).  Everything else passes (C.12.9: Windows-only).
* **OPEN L3 extension** (section "OPEN L3, L19, L25, L27"): Alt+G (the GAME menu) opens the File menu by its mnemonic
  with Alt; Alt+Q (quit, asked first) reaches command 115 through its menu path.  Both are DOS-only keys with a core
  counterpart (no Windows title has G or Q).  **Choice D6f-5:** Alt+C and Alt+H pass with their Windows meaning (the City
  and Help menus); in DOS they open CIVILOPEDIA (R:0403:3B97) and the help screens (R:0403:3ABD -> 389B).
* **I-menubar (C.12.8).**  Keys pass (the menu loop's own: arrows, Return, Escape, Home, End, a mnemonic); a press on the
  bar passes by identity (the bar is drawn at the Windows title extents, never DOS's x / 60, R:1C84:0019..002E; review
  R3-2); a frame-2 press, its moves and its release inside a DOS drop-down go to the centre of the Windows item of the row
  under them (`pdos_reskin_menu_point`), or to the Windows popup's top-left off the rows (no item); elsewhere identity.
  Alt+V while a drop-down is open: command 109's path (the user's Alt ends the loop first).
* **I-menu on frame 2.**  On a re-skinned MenuZ box of the A canvas D5's I-menu rows decide at the A hit geometry
  (`pdos_r_hit`, the box's DOS pixels at 2x).  Dialog 145's Help: Alt+H or the right button on its box click the Help
  button (I-menu/help, act PDOS_A_WND, both canvases); without a Help button they stay consumed (I-menu/alt-right).
  **Choice D6f-4 (a deviation from C.12.8's outline):** Alt+V on a MenuZ box is consumed: MenuZ's loop takes its dialog's
  keys only, so no posted path reaches command 109 while it runs.
* **The message box on A (I-menu/msgbox-*).**  Keys pass (the box's own: Return and Space on the focused button, which
  the DOS highlight follows; Escape its IDCANCEL; Tab; the arrows; a mnemonic); a left press is a drag (the DOS highlight
  follows the row under the pointer, consumed); its release in button row k clicks that button's control (PDOS_A_WND);
  the right button, a release outside the rows or after a press on another frame are consumed.
* **C.15.4 case 13.**  A drag's release decides at the press's frame: a release on another frame (the map layer's frame
  3: arrive.c stamps a press off the layer with the visible frame, its moves and release too, so a release over the
  zoomed map from a press on a DOS row arrives on frame 2, outside every row) posts no click.  ext_adapt `f6-drag`
  checks it (0 button messages).
* I5 class A (new, `PDOS_I5_A`): a frame-2 point is already a virtual-screen point (the A canvas shows the Windows
  layout); `pdos_mouse_point` does not take it.  adapters.py checks that a passed press on frame 2's scenes is class A.
* **The chord audit of C.12.9 still holds:** no D6f act produces a Ctrl+Shift combination or Alt+Enter (Ctrl+digit
  pairs without Shift; Alt with menu letters only), and the host chords are taken at arrival before the filter stage.
* **P0.**  Nothing here draws from the simulation RNG or changes the core: the bar, the drop-downs and the boxes are read
  from w16 (`w16q_menu_item`, `w16q_menu_bar`, `w16_menu_track_item`, read only, obs_lint-listed) and the composed
  frame; the translations post ordinary host input at the sync (ext_p0 V1 / V2 equal V0).

### Choices

* **D6f-1** I-play only while the menu bar's window is active (above).
* **D6f-2** a drop-down covers its Windows popup with its shadow (above).
* **D6f-3** an unpaired drop-down item: the core's text with its accelerator in colour 15 (above).
* **D6f-4** Alt+V on a MenuZ box consumed (above; deviation from C.12.8's outline).
* **D6f-5** Alt+C and Alt+H pass with the Windows meaning (above; accepted by the orchestrator, O3).
* **D6f-6** an A box is at least its Windows window's size (above; new, for the orchestrator's review).

## OPEN L3, L19, L25, L27 (read from the listing)

* **L3 (the right button on the map; the keys).**  R:0403:0846..09CA: with an active unit, the square under the pointer
  ((DB3C - 50h) / 16 + [D4CC], (DB3E - 8) / 16 + [D75E]); when its distance from the unit (R:1DC4:0208) is 1 (and the
  terrain rule at R:2045:2AC2, 4Fh) the unit's goto is set (x, y, FFh) and R:0000:1697 runs; otherwise, for a visible
  square ([D806] reveal), R:0403:09A5..09BD opens the Civilopedia (O8:062A, kind 3) on the square's terrain
  (R:1AEA:134A).  Mouse and state dependent: it passes (C.12.9, recorded Windows-only); no I-play extension.  The DOS
  keys with a core counterpart that no Windows key has: Alt+G (R:0403:3B72 -> 3A3B, the GAME menu R:1C84:0000) and
  Alt+Q (R:0403:3B22 -> 38B6): I-play extended (I-play/game, I-play/quit).  Alt+C (CIVILOPEDIA, R:0403:3B97) and Alt+H
  (R:0403:3ABD -> 389B) collide with the Windows City and Help menus: passed (Choice D6f-5).  Alt+R, Alt+M, S, t, ? and /
  are not compared (they pass).
* **L19 (the Options state).**  The DOS GAME menu's Options box marks its settings with '^' (R:1D05:0939..0951 for the
  bits of DGROUP:D7F2, set at R:1C84:014B..014E; restored at R:1D05:0843): the drop-down's checked items (MF_CHECKED from
  `w16q_menu_item`) get that mark.
* **L25 (the drop-down texts).**  GAME, Options, ADVISORS, WORLD and CIVILOPEDIA read static strings (registry rows
  above); ORDERS is built per square (R:1C84:01D8): no static pairing; its rows are the core's texts with their keys
  (Choice D6f-3).
* **L27 (the Civilopedia caller).**  R:0238:1767 (caller R:0238:0092) calls O8:062A at R:0238:1813 with kind 1 and item
  [bp-8] + 18h after a menu box at (100, 80) (R:0238:17EF..1805): a game-event notice's Civilopedia entry, not the map
  right click.  DOS's map right click is R:0403:09A5 (kind 3, terrain), corroborating the Windows inference (CORR Open 5).
  No I-play extension.

## User direction 2026-10-16 (no added Go Back / Cancel rows): the per-screen Escape check

"In the DOS graphics never show a Go Back or Cancel row that the DOS game doesn't have, on any screen. Where DOS has a key
for it (e.g. Escape), that key does it; otherwise that choice is only in the Windows graphics."  D5f made Escape pass
provisionally; for the boxes D6f places in play:

| Box in play (A canvas) | DOS Escape (listing) | The core | Record |
|---|---|---|---|
| MenuZ, dialog 136 or 145 (rows 14, 22): the tax rate, the luxuries rate, the revolution, quit and retire questions | the menu box returns -1 (R:1D05:0200 -> 0392); each caller's -1 changes nothing (section "Escape on the boxes in play (O1)") | the dialog has no cancel; the choice of the row selected at the opening changes the same nothing (proven per caller, below) | DOS has Escape -> **its job done**: I-menu/escape-row (O1) |
| MenuZ, dialog 136 or 145: every other ShowTextDialog menu in play | -1, R:1D05:0392 | the dialog has no cancel: the passed Escape leaves the box open | DOS has Escape -> **kept as a pass** (I-menu/return-escape): no equivalence proven by D6f; D7's per-scene units (rows 13, 14, 22: D7g) |
| `#MsgBox` on A (W4 Game Help, W6) | a menu box: -1 | the message box's own Escape (IDCANCEL, or IDOK for an OK-only box) | DOS has Escape -> **keep** (I-menu/msgbox-key, pass); no Cancel row (D5f) |
| Drop-downs (the menu loop) | the menu box R:1C84:0806 returns -1 and the menu closes | the w16 loop closes one level | DOS has Escape -> **keep** (I-menubar/key, pass) |

No Escape is consumed by D6f.  Rows a DOS screen lacks that D6f shows, reported to the orchestrator (section "Report
items", with the D7 unit that owns each): the Edit, City and Help menus' rows; Windows separators as empty rows;
ORDERS's grayed items; the message boxes in play, which are Windows dialogs (e.g. W4's Game Help "OK").

Not D6f's (the orchestrator's split of 2026-10-17): Escape on the core's list and modal dialogs is unit **FCE**'s
(`pdos_fce.c`; in the DOS graphics Escape becomes the dialog's own cancel character, WM_CHAR 1Bh posted to it):

| Dialog (DOS graphics) | Escape's owner |
|---|---|
| Find City, dialog 131 | FCE |
| the Civilopedia lists, dialog 130 | FCE |
| the production list, dialog 140 | FCE |
| the city name, dialog 137 (a new city, City > Rename City) | FCE |
| the MenuZ boxes of dialogs 136 and 145 (the five boxes of O1; every other one passes) | D6f |

Neither consumes an Escape the other handles: FCE's `pdos_fce_escape` takes a new Escape press first (its block in
`key_down`, before D6f's rows) and only while the active window is one of its four dialogs, identified by their
controls (a shown LISTBOX or 137's EDIT), which no MenuZ box has; otherwise it leaves the press to the rows, where a
re-skinned MenuZ box on top decides it (I-menu/escape-row, or I-menu/return-escape's pass).  A MenuZ box opened over one
of FCE's dialogs is the active window, so the press is D6f's.

### Escape on the boxes in play (O1, the orchestrator's direction of 2026-10-16)

Box by box: what the DOS caller does with -1, what the core caller does with each row, and the row whose choice is the
same.  The box is identified by ShowTextDialog's call site (its entry probe's `ObsProbe.site`, stacked until its exit;
its own MenuZ call, 1220:012D, takes the kind: `pdos_reskin.c`, resolved at the reset with `obs_callsite`); the row
selected at the opening is the core's selection at the box's first key poll (`MzCall.open_sel`).  The tax and
luxuries sites were rows already (DOS-PROFILE rows 30, 31); revolution's, quit's and retire's are new
OBS_CALLSITES rows (`gen/obs_tables.py` EXTRA_SITES: ShowTextDialog@11F0:3B85, @11F0:401A, @1048:0278; 98 -> 101 rows).

| Box (keys) | DOS caller, -1 | Core caller | Escape's core row | Proof |
|---|---|---|---|---|
| Tax rate (Ctrl+T, `=`, `+`, GAME > Tax Rate; call 11F0:3CFC) | R:0403:368B..36B6: `cmp [bp-3Ah], -1` at R:0403:3696, then `jmp R:0403:36B6`: DF0E (tax) and B210 (science) untouched, no panel redraw | 11F0:3CDA sets g_menuInitialSelection := taxRate[civ] (MenuZ opens on it, 1220:0866..0886); rows t = 0..tax + science (11F0:3C07); t != -1 (11F0:3D07): science += tax - t, tax := t, DrawStatusCivPanels | the opening row: t = tax | science += 0 and tax := tax: the rates unchanged; the status panel is drawn again with the same values (DOS draws nothing; no visible difference) |
| Luxuries rate (Ctrl+L, `-`, `_`; call 11F0:3E4A) | R:0403:3787..: `cmp [bp-3Ah], -1` at R:0403:378A: nothing | 11F0:3E15: initial := 10 - tax - science (the luxury rate); rows t = 0..10 - tax (11F0:3D5A); t != -1: science := 10 - t - tax, panel | the opening row: t = lux | science := 10 - lux - tax = science: unchanged |
| Revolution (Ctrl+R, GAME > Revolution; call 11F0:3B85) | R:0403:355F..: `cmp ax, 1` at R:0403:3567, `jne` -> R:0403:3C40 (the key's handling ends): no revolution | 11F0:3B8A: `if (result != 1) break` | the opening row; item 0 if it were item 1 (`pdos_r_escape_item` NOT1) | every row but 1 ends the case unchanged, as DOS's -1; the call sets no initial selection and 1220:0C80 resets it to -1 after every MenuZ, so the box opens on row 0 |
| Quit (Ctrl+Q, File > Quit and, in the DOS form, Alt+Q's path: command 115; call 1048:0278) | GAME > Quit sets [DC48] := 1 and the key 1000h (R:1C84:01B1 -> 01A9), Alt+Q is that key (R:0403:3B22 -> 38B6); the question at R:0403:38D2, `cmp ax, 1` at R:0403:38DA, `jne` -> R:0403:38E2: `[DC48] := 0` (the game goes on) | 1048:0280: `cmp ax, 1`, `jne` -> 1048:029D: only result 1 queues the key 0x171 and sets g_quitRequested := 1 (1048:0285..029A), on which the message pump that called HandleMenuCommand runs ShutdownGame (1098:03CD..03D5, 1098:06E3..06EB: the game ends at once); any other row ends the command without writing g_quitRequested, which is 0 in play (set to 0 at 1008:02D9; the turn loop at 1008:0309..030E and the human's moves at 1088:01B6..01C6 run only while it is 0) | as revolution (no initial selection: row 0) | every row but 1 leaves the game going on with no quit request, DOS's -1 outcome |
| Retire (File > Retire, command 114: g_quitRequested := 2 and the key 0x171, 1048:023C..024B, which the pumps' `cmp g_quitRequested, 1` leaves running; the key's question, call 11F0:401A) | DOS's Retire sets [DC48] := 2 and the same key 1000h (R:1C84:01A3..01A9): the same question R:0403:38B6..38E8, -1 -> `[DC48] := 0` | 11F0:401F: result != 1 -> g_quitRequested := 0 (11F0:4027); 1 keeps the request (or sets 1, 11F0:4035..404E, as R:0403:38EB..38FB) | as revolution | every row but 1 is DOS's -1: the retire request cleared, the game goes on |

Not included (no equivalence shown by D6f, the pass kept): every other ShowTextDialog box in play (e.g. the
government choice after a revolution, row 115; the advisors' and event boxes of rows 13, 14 and 22): D7g's per-scene
rows, with the help line R4.  DOS's other -1, a left release outside the rows (R:1D05:01A1..01B2), keeps D5b's
I-menu/release-outside (consumed; the box stays): only Escape is mapped (recorded difference).

Built: `PDOS_AA_ESC_ROW` (set with Escape on a re-skinned MenuZ box whose `pdos_reskin_escape_item` is an item; the
new hook `esc_item`) and the row **I-menu/escape-row** (before I-menu/return-escape; STEPS q_click_sel_return, I5
class C: a click on that item's control, then Return once the core's selection is that item, as I-menu/release).
Escape with Alt held stays an Alt key (I-menu/alt-right); while the box's MenuZ is not in its loop the key passes
(I-menu/wait).  DOS-PROFILE.md 1.7.2 regenerated (116 rows, 25 step sequences).

### Cancel / Go Back audit of the re-skinned boxes (the orchestrator's direction of 2026-10-16)

Every box D6f shows in the DOS graphics, checked against its Windows controls (resources.md, DOS-PROFILE.md section 4
W4, W6):

| Re-skinned box (DOS graphics) | Windows controls | DOS form's rows | Cancel, Go Back or similar row | Escape |
|---|---|---|---|---|
| MenuZ, dialog 136 (row 14) | the items (RandomUser 103, 104), OK (101) | the items only (OK is not a row: Return is its DOS form); since Choice D6f-6 nothing of the Windows dialog shows | none | O1 for the five boxes above; else passed |
| MenuZ, dialog 145 (row 22) | the items, OK (101), Help (102) | the items only; Help by Alt+H or the right button (DOS's help flag, R:1D05:0180..0187, 03E3) | none | as dialog 136 |
| `#MsgBox`, OK only: ShowErrorMessage 1098:28E4 (MB_OK with an icon, 1098:2946), _ErrorMessage 1000:4124 (MB_OK, system modal, then exit), WinMain 1008:0080, CheckStartupResources 11E8:0064 and CheckLowResourcesWarning 11E8:00D4, 11E8:0117 (MB_OK; never in civ64, FIDELITY F14), Help > Game Help's message box (W4, MB_OK) | OK | one OK row | none | IDOK (w16: an OK-only box's Escape) |
| `#MsgBox` with Cancel: ConvertArtworkFor16ColorDisplay 10B8:00DD, ConfirmDiskSpaceForArtworkConversion 10B8:0600 (MB_YESNOCANCEL; before play, 16-colour displays only: never in civ64, whose display reports 256 colours, 1008:05F8; the harness's test switch only) | Yes, No, Cancel | Yes and No (the answers: convert, or go on without converting, 10B8:00E5); **Cancel hidden** (D5f's IDCANCEL rule) | none | **IDCANCEL**: Escape does Cancel's job (ShutdownGame, 10B8:00F1), as w16's box gives it |
| Drop-downs (MENU 128's popups, ruling 2) | the menu items | the items (no item is a cancel) | none | the loop's own (one level) |
| The menu bar | the titles | the titles | none | - |

No USER.MessageBox call site of the core (DOS-PROFILE section 4 W6; ShowResourceUsageReport 11E8:028A has no caller)
is MB_YESNO or MB_OKCANCEL: the two boxes above with Cancel are the only ones with more than OK, so no "No" or
"Cancel" equivalent shows anywhere in the DOS form.  Not D6f's boxes (reported, unchanged): the Windows-layout dialogs
not yet re-skinned (class R rows of D7: their Windows buttons, e.g. a Cancel, stay until their unit) and civ64's own
host dialogs over both graphics (UX1's exit warning with Cancel, accepted by the user in UX1's checks; UX4's Save As
overwrite question Yes / No): native windows outside the game's screens.

## What was built

* `platform/w16/w16_obs.h/.c`, `user_menutrack.c`: `w16q_menu_item` (an item by position: flags, id or popup handle, raw
  and display text, the mnemonic index, its rectangle on the bar or in an open popup) and `w16q_menu_bar` (the bar of a
  shown top-level window: its menu, rectangle and titles' rectangles); `w16_menu_track_item` (an open popup's item
  rectangle, read only, as `w16_menu_track_info`).  obs_lint lists the read-only helpers they call.
* `present/dos/pdos_reskin.h/.c`: the A placement (`pdos_r_set_at`, `pdos_r_place`, `pdos_r_canvas`, `pdos_r_top_on`,
  `PdosRPlace`), the bar (`PdosRBar`, `pdos_r_bar_draw`, `pdos_r_bar_title`, `pdos_r_menu_title`), the drop-downs
  (`PDOS_RK_DROP`, `pdos_r_drop_dos_text`, `pdos_r_drop_dos_header`, `pdos_reskin_menu_point`, `pdos_reskin_drops`), the
  menu paths (`pdos_reskin_menu_path`), dialog 145's Help window (`pdos_reskin_help_wnd`), `pdos_reskin_present` (at
  every core present of the DOS profile, after `pdos_compose_core_present`) and `pdos_reskin_diag` (the `preskin` line:
  bar_draws, drop_sets, a_sets, the bar and its titles, the last level-1 drop-down's and the last A box's layout).
* `present/dos/pdos_ui.h/.c`: `PdosMenuBox.marks` (the '^' marks) in the layout and the draw; `pdos_mouse.h/.c`:
  `PDOS_I5_A`.
* `present/dos/pdos_adapt.h/.c`, `pdos_adapt_tab.c`: frame 2's scenes, acts PDOS_A_CTRL / MENU / WND, actions FKEY,
  SOUND, GAME, QUIT, ONBAR, the hooks `ascene`, `menu_point`, `menu_path`, `help_wnd`, `on_bar`; the 17 rows above (O1's row below).
* `present/dos/pdos_profile.c`: `pdos_reskin_present()` after `pdos_compose_core_present(r)`.  `present/present.c`:
  the `presentation-diag preskin ...` host-log line.
* `docs/dos/OFFSETS.md` (six MENU rows), regenerated `present/dos/pdos_registry.c/.h` and `tests/dos-decoded.txt`;
  `gen/dos/adapters.py` (the frame-2 scenes, class A rule, the new acts) and DOS-PROFILE.md 1.7.2 regenerated.
* `tests/headless/harness.c`: presentation-diag.log's `preskin` line (after BS3's).
* The orchestrator's follow-up of 2026-10-16:
  * O1: `pdos_reskin.h/.c`: the ShowTextDialog calls in progress (`g_std`, its entry and exit probes; the innermost
    one binds its own MenuZ call), the proven call sites (`g_esc_site`, five, resolved with `obs_callsite` at the reset),
    `MzCall.esc` and `MzCall.open_sel` (the core's selection at the box's first key poll), the pure rule
    `pdos_r_escape_item` (`PDOS_R_ESC_RATE`, `PDOS_R_ESC_NOT1`) and `pdos_reskin_escape_item`; `pdos_adapt.h/.c`:
    `PDOS_AA_ESC_ROW`, the hook `esc_item`; `pdos_adapt_tab.c`: the row I-menu/escape-row (116 rows);
    `gen/obs_tables.py` EXTRA_SITES: ShowTextDialog@11F0:3B85, @11F0:401A, @1048:0278, and the regenerated
    `present/obs_tables.c/.h` (101 call-site rows).
  * The zoom layer's z order: `pdos_reskin_a_rects` (the A rectangles of the shown boxes, drop-downs, message boxes and
    the bar); `present/map/pmap_int.h` (`PMAP_COVER_MAX`, `pmap_dos_cover`), `pmap_dos.c` (`pmap_dos_cover`: those
    rectangles in host pixels through `present_host_rect`), `pmap_layer.c` (`put_open`, which cuts each put piece
    around them; `pmap_overlay` uses it while the drawn profile is DOS).
  * Choice D6f-6: `PdosRPlace.win` (the Windows window's rectangle) and `min_size_win`; the `preskin` line's new fields
    drop_w, drop_hh, abox_w, abox_hh and abox_win_l, abox_win_t, abox_win_r, abox_win_b.

## Tests

* **test_pdos_reskin** (67 -> 121 in Checked and Release; 56 -> 110 in CheckedNoObs; B 15.1's A parts): the bar titles
  (DOS titles equal the registry's MENU_TITLES strings with colour 15 and the 87h switch; Windows-only titles in capitals
  with 8Fh/87h around the mnemonic, colour 7; the cap); the bar's drawing (title pixels and colours, the highlight 0 ->
  11, the clamp, an empty bar); the drop-down texts (paired 101, 8000h|105, 109, 401, 506, 606; unpaired 201, 301, 999;
  the Options header); the '^' marks on an N box; the A placement (2x, the hit mapping incl. a disabled row and the
  header, outside, top_on, menu_point, the clamp at the canvas's edge and at (0, 0), an exclusion, back to N); a
  drop-down's rows, separator and least size; Choice D6f-6 (`test_awin`: a box replacing a larger Windows window is at
  least its size at 2x, its A rectangle covers the window, row 0 stays, the added part is on no row; a smaller window and
  no window keep the box's own size; `pdos_reskin_a_rects` none on N and after removal).  The program opens
  `<gamedata>\..\dosdata` read only for the registry strings.
* **test_input** (449 -> 502 in Checked and Release; 370 -> 446 in CheckedNoObs): I-play pairs (F1, F10, the modifiers),
  Alt+V with and without the core's Alt (6 events), Alt+Q, a missing path's diag, Alt+C passing, I-menubar mapping
  (moves, press, release in rows, off the rows), the RMENU frame-2 drag/release and case 13 (an N drag released on frame
  2; a frame-2 drag released on frame 3), the AMSG release clicking its button, Alt+H on dialog 145 (with and without its
  Help button), Alt+V on a MenuZ box consumed; 16 new frame-2 vectors and the I-menu/help vector; the table check (116
  rows, frame-2 passed presses class A).  O1: I-menu/escape-row (Escape on a box whose `esc_item` is an item: a click
  on that item's control, Return queued once; item 0; no item: I-menu/return-escape passes), its vector, and
  `pdos_r_escape_item` (RATE: the opening row, -1 unknown; NOT1: the opening row, item 0 for item 1 or unknown; NONE
  -1).
* **test_observer** (108 -> 115 in Checked; 97 -> 104 in Release; CheckedNoObs 1 unchanged; OBS_NCALLSITES 98 ->
  101 in its table check): `w16q_menu_item` and
  `w16q_menu_bar` (the bar's eight titles and rectangles, display and raw text, the mnemonic index, a popup item, a
  command item cut at its tab, a separator, an item out of range, no such menu, a window without a bar, and an open
  popup's item rows at OBS_MENU_OPEN).
* **test_dos** (23233 -> 23239 on the tree after D6e): the six MENU tables decoded (goldens `tests/dos-decoded.txt`).
* **ext_adapt.py** (7.8; BRIEF test list): f6-cal (calibration: the bar, the World drop-down with six rows, the Game Help
  box on A), f6-fkey (F1, F7 against Ctrl+1, Ctrl+7), f6-sound (Alt+V against Alt+F, O, U), f6-menu (a DOS bar click and
  a DOS drop-down row against the same title click and a click on the Windows item), f6-drag (C.15.4 case 13 at
  --zoom -1, no click posted); ring-dos now against `ringref-dos` (below).  O1 (the orchestrator's direction):
  f6-taxesc, f6-luxesc, f6-revesc, f6-quitesc and f6-retesc (Ctrl+T, Ctrl+L, Ctrl+R, Ctrl+Q, File > Retire by Alt+F, E;
  Escape 1,000 ms later): each equals its Windows-form pair (the click on the opening row's control, Return at the same
  sync), decides I-menu/escape-row once, closes the box before S3's Space at 58,000 ms, ends with the game's memory equal
  to the run that chose the opening row with Return (every global but the input's own record, g_lastClickedControl and
  g_msg) and with the box's globals (g_taxRate and g_scienceRate; g_government; g_quitRequested) equal to the run
  without a box (`f6-nobox`): no change.  The zoom layer's z order: f6-zcover-m1, f6-zcover-p1 (the tax box at -1, +1)
  and f6-zcover-menu (the GAME drop-down at -1) with --dump-presented: every pixel of the DOS element inside the map
  client is the A frame's, the layer is drawn elsewhere on the client, and the box covers its Windows dialog (Choice
  D6f-6).  Thirty-four D6f lines and one ring-dos line.

## Results (private, `build/d6f-stage/obj/`)

* On the tree after FCE's landing (its first copy-in, about 02:32 UTC, stopped at d2_registry, FCE's own include rule;
  its second, about 03:03 UTC, ALL_GREEN 03:41:10 UTC), with `pdos_adapt.c` merged again (FCE's block first; its
  second copy changed only its own block, `PDOS_CHAR_TO_DIALOG`): the builds (296 portable sources), cc.cmd as below,
  49 unit programs per variant (FCE's test_pdos_fce 43 and test_user 365 pass; D6f's counts as below), `OBS_LINT_OK
  files 124 probes 203 callsites 101`, ADAPT_OK, pdos_scene_check, OBS_TABLES_OK, REGISTRY_OK, NODOS_OK; ext_adapt
  (`RUNADAPT checks 49 failed 0`, the whole runner `EXT_ADAPT_OK checks 189`); FCE's `ext_fce.py` with D6f's harness
  (`--harness`, `--root` under `obj/run/fce`): `EXT_FCE_OK runs 8` (Escape on dialogs 131, 130, 140 and 137: in the
  DOS graphics WM_CHAR 1Bh and the dialog closed, in the Windows graphics the key and the dialog open; D6f's rows
  behind FCE's block take none of them); ext_p0 V0, V1, V2 on all 33 scenarios (`P0_OK checks 225`; retire,
  revolution, menus and D5's Go Back and Cancel runs among them; the V1 `preskin` counters as below); ext_frames
  EXT_FRAMES_OK; ext_zoom with the staged goldens ZOOM_OK (below).  Also, for the landing's predictions, every other
  test.cmd section that takes a private harness and root (`obj/chain3.sh`, `obj/chain4.sh`, outputs under
  `obj/run/c3` and `obj/run/p0`): ext_replay over the private V1 outputs REPLAY_OK checks 70, ext_tld EXT_TLD_OK,
  ext_slots EXT_SLOTS_OK, ext_aspect EXT_ASPECT_OK, ext_timeline (base and bs) EXT_TIMELINE_OK, ext_continue
  EXT_CONTINUE_OK, ext_bs assets and mirror EXT_BS_OK, ext_mirror MIRROR_OK runs 29, ext_p0 V3, V4, V4d, V6, V6r,
  V6w, V7, V8, V8s P0_OK checks 251 (with chain2's V0, V1, V2, 225: the 476 PASS lines of the tree's ext-p0.txt,
  each equal); each output equals the tree's file of FCE's cycle (`build/test/Checked`) line for line
  apart from root paths (and ext_mirror's soaks' `p0 n/a`, the uninit references being absent from the private
  root); ext_zoom's and ext_frames' outputs equal too.  The earlier results below were on the tree after D6e's and
  TLD's landings.
* On the tree after D6e's landing (D6e's copy-in 00:55:23 UTC, ALL_GREEN 01:23:53 UTC; with UX5, MZI and MZS); the
  builds, cc.cmd, the unit programs, the static checks and ext_adapt's D6f and M sections once more after TLD's landing
  (its files in the tree at about 01:31 UTC), with the same results:
* Builds: Checked, CheckedNoObs, Release `BUILD_OK`, `portable sources checked: 295 (c11, c17, c99 parse)` (the tree's).
* cc.cmd (c11, c17 /W4 /WX, clang C99 parse) on pdos_reskin.c, pdos_adapt.c, pdos_adapt_tab.c, pdos_mouse.c, pdos_ui.c,
  pdos_profile.c, pdos_registry.c, present.c, w16_obs.c, user_menutrack.c, test_pdos_reskin.c, test_observer.c and
  harness.c: CC_OK in the three variants.  test_input.c: c11 and c17 clean; the clang C99 parse reports the base's own
  `square_only` missing-field-initializer only (the tree's copy has it; build.cmd compiles the tests with /std:c17 only).
* Unit programs: 48 per variant, all pass but test_dos (`decoded content differs from the goldens`: the tree's goldens
  path; its output equals the staged `tests/dos-decoded.txt` line for line).  test_input 502 / 446 / 502, test_pdos_reskin
  121 / 110 / 121, test_observer 115 / 1 / 104, test_dos 23239 (Checked / CheckedNoObs / Release); test_pdos_adapt 155 /
  145 / 155 and test_pdos_ui 34 unchanged.
* `OBS_LINT_OK files 122 probes 203 callsites 101`; `ADAPT_OK rows 116 steps 25`; `PASS pdos_scene_check: 1078 checks,
  141 scene rows, 8 font rows, 0 failed`; `OBS_TABLES_OK probes 203 sites 101`; `REGISTRY_OK`; `NODOS_OK` (0 hits).
* ext_adapt, the whole staged runner as test.cmd runs it (`obj/runadapt_full.py`: its main() with the private harness,
  every output under `obj/run/adfull`): `EXT_ADAPT_OK checks 189` (plain and chords, M and D6d, D4c2..D5P's DOS-form
  pairs unchanged, D6f's).  Before it, `obj/runadapt.py` (d6f_runs and m_runs only, `obj/run/ad`): `RUNADAPT checks
  49 failed 0`: the O1 and z-order lines below, f6-cal (the bar 5 draws, the World drop-down 4 sets with 6 rows,
  the message box 1 set; points title (412, 31), drop (341, 88), ok (101, 253)), f6-fkey, f6-sound, f6-menu (the title
  press passed unchanged, the row press posted at the Windows item (501, 85)), f6-drag (0 button messages) equal their
  Windows-form pairs; zoomkeys, ring, ringref, zoomkeys-dos as before; ring-dos equals ringref-dos and its `=` passed
  (I-play/key), dialog 136 opened, `-` and `0` consumed (I-menu/key).  O1: f6-taxesc, f6-luxesc, f6-revesc,
  f6-quitesc and f6-retesc each equal their pair (coreinput 41, frames 680, events 104; f6-retesc 43 / 680 / 106),
  I-menu/escape-row once (the click on the core item control at (322, 233), (321, 188), (322, 224), (322, 224),
  (322, 224); Return at sync 577479, f6-retesc 577480), the box gone at 58,000 ms (S3's Space: I-play/key), the end
  memory equal to the Return run's in 806 globals but g_lastClickedControl and g_msg, the box's globals equal to
  f6-nobox's.  z order: f6-zcover-m1 and -p1, the tax box (A 203,101..485,379; its Windows dialog 203,101..437,378
  inside): 78396 of 78396 client pixels the A frame's, the layer on 2956 (-1) and 12412 (+1) other client pixels;
  f6-zcover-menu, the GAME drop-down (A 171,39..357,233): 35898 of 35898, the layer on 7594 others.
* ext_zoom (the tree's runner through `obj/zoomupd.py`, its goldens file the staged copy; every output under
  `obj/run/zoomall`): `ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32 centre runs 4 mzi runs 12`
  on MZI's tree (every profile and size, the soak, MZ's centring and MZI's runs), and on MZS's copy-in `... mzi runs 12
  mzs runs 4` (MZS's menu and dialog runs at -1 and +1 in both profiles pass with D6f's put step); after D6e's landing,
  with D6e's goldens and their 240 DOS lines regenerated again (`ZOOM_GOLDEN written 628 samples`; the 388 Windows
  lines equal D6e's): `ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32 centre runs 4 mzi runs 12 mzs
  runs 4 not zoomed 38/448`.  Before the goldens were
  regenerated (`--update --profiles dos`, written into the staged copy only), the tree's goldens failed at every DOS
  sample in play; `obj/zoomcmp.py` (the run `new`, 640 x 480, -1, DOS profile, against the tree's MZI harness, both
  with --dump-presented) showed all 163 zoomed shows differing only inside x 171..639, y 22..38: the DOS menu bar on
  A (P24), the layer's pixels identical.
* ext_p0 (tree runner, `--exe` the private harness, `--root obj/run/p0`): V0, V1, V2 on s3, orders, menus, revolution,
  city, unload, research: `P0_OK checks 49`; every V1 run's D4/D5 scene-row counters 0.  The V1 runs' `preskin`
  counters: menus bar_draws 99, drop_sets 221, a_sets 31; city 21 / 22 / 2; orders 27 / 33 / 1; unload 9 / 21 / 0;
  revolution 3 / 3 / 4; research 1 / 0 / 10; s3 1 / 0 / 0; elem_full 0.
* ext_frames (tree runner through `obj/runframes.py`, every output under `obj/run/fr`): EXT_FRAMES_OK (start, s3, birth:
  the sample lines of A, A', B, C identical; the dump check).
* Probes (`obj/probe.py`, S3 with the chord at 40 s and one action at 55,500 ms): Ctrl+T opens dialog 136 (event at
  55,551,650 us; the tax-rate box on A at (203, 101)); Ctrl+R opens dialog 136 (the revolution question); Alt+Q opens
  dialog 136 (the quit question, 20A0h) through I-play/quit; Alt+G opens the File menu (I-play/game, then
  I-menubar/key).  (Before O1 was built, Escape on the tax box passed and the box stayed.)

## Expected changes at the build slot

* Unit: test_input 449 -> 502 (Checked, Release; CheckedNoObs 370 -> 446), test_pdos_reskin 67 -> 121 (CheckedNoObs
  56 -> 110), test_observer 108 -> 115 (Checked; Release 97 -> 104; CheckedNoObs 1), test_dos 23233 -> 23239 (every
  variant); every other unit count unchanged.  Portable sources 296 and obs_lint files 124 (the tree's after FCE)
  unchanged (no new source);
  obs_lint's and obs_tables' call sites 98 -> 101.
* `ext-adapt.txt`: `EXT_ADAPT_OK checks` 154 -> 189 (34 D6f lines and ring-dos's new decisions line; ring-dos's
  comparison line now names `ringref-dos`); 29 more runs (f6-cal, four pairs, ringref-dos; five Escape cases of three
  runs each and f6-nobox; three f6-zcover runs with --dump-presented, whose dumps are deleted after the check; 57.5 to
  72 s of virtual time each).
* **`tests/harness/ext-zoom-golden.txt`: the 240 DOS lines change** (every `dos ...` sample: all lie in play, where D6f
  draws the DOS menu bar on A; the 388 Windows lines unchanged).  The first D6f record's "ext_zoom unchanged" was
  wrong: the goldens hash the whole host view, bar included.  The staged copy is MZI's with those lines regenerated by
  `ext_zoom.py --update --profiles dos` (privately, the staged copy written); `ext-zoom.txt` ZOOM_OK with it.  D6e also
  stages this file: after D6e lands, regenerate the DOS lines on the merged tree (section "Rebase notes").
* **ring-dos's reference (expected change from decision 1).**  In ring-dos `=` at 69,000 ms opens the core's MenuZ of
  dialog 136 (the tax rate), which the DOS profile now shows as the DOS menu box on A; that box has no item key for `-`
  or `0` (R:1D05:03FD..03DC, none: back to its loop at R:1D05:03C1), so the filter consumes both (D5's I-menu/key) and
  ring-dos no longer equals ringref (whose Windows dialog receives them: coreinput's WM_KEYDOWN/UP of 00BDh and 0030h,
  frame 754).  The runner compares ring-dos with `ringref-dos` (ringref without those four key lines) and asserts the
  decisions.
* `adapters.py check`: `ADAPT_OK rows 116 steps 25` (was rows 98 steps 22); DOS-PROFILE.md 1.7.2 regenerated.
* `registry.py check` REGISTRY_OK with the six MENU rows; `tests/dos-decoded.txt` six lines more.
* presentation-diag.log (harness): a new `preskin ...` line after BS3's; civ64's host log: a `presentation-diag preskin
  ...` line.  Presentation only.
* presented.log / frames in DOS-visible play runs: the DOS menu bar, drop-downs and re-skinned boxes on A (new
  pictures).  Windows-visible shows, every core output, G-1 fields and `ext_g1.py check`: unchanged (ext_p0 V1/V2
  equal V0).
* `ext-p0.txt`, `ext-frames.txt`, `ext-mirror.txt`: unchanged counts expected (P0 equality held on the private
  subset); `ext-zoom.txt`: its counts unchanged, ZOOM_OK only with the staged goldens (above).
* `nodos.txt`: byte counts grow with the binaries and the record; NODOS_OK.

## Rebase notes

* All bases equal the tree at writing (`BASE-SHA256.txt`); `docs/DOS-PROFILE.md` was re-based at 19:32 UTC (the docs
  pass's prose at lines 155..159 kept; only the generated section differs).  UX5 and MZI (landed during the follow-up):
  `present/dos/pdos_profile.c`, `present/present.c`, `present/map/pmap_int.h` and `pmap_layer.c` re-based by
  three-way merges (no conflict; D6f's hunks unchanged), `tests/harness/ext-zoom-golden.txt` added from MZI's copy.
  MZS (copied into the tree at about 23:47 UTC): `present/map/pmap_dos.c` and `pmap_int.h` re-based onto it (no
  conflict: D6f's include and `pmap_dos_cover` after `pmap_dos_frame_ok`; MZS's `md_fill` change is elsewhere in the
  file).  The `extension D6f` blocks are delimited
  where they add more than a line; one-line hunks carry an `extension D6f` comment.
* **D6e** (landed before D6f, as the orchestrator decided; its files in the tree at about 00:55 UTC): D6f is re-based
  onto it (bases copied again then; three-way merges, the two conflicts resolved as D6e's record says):
  * `docs/dos/OFFSETS.md`: D6e's three rows after line 90, then D6f's six MENU rows; `present/dos/pdos_registry.c/.h`
    and `tests/dos-decoded.txt` regenerated with the tree's (D6e's) `gen/dos/registry.py gen` and `goldens` on the
    overlay (D6f's additions only: 18, 6 and 6 lines).
  * `present/dos/pdos_profile.c`: D6e's `pdos_aplay_present();` then D6f's `pdos_reskin_present();` after
    `pdos_compose_core_present(r);`.  D6e's elements (the small map, the Status window)
    are clipped to their windows' visible regions and exclude the open menu's popups (D6c's exclusions), so the A boxes
    (dialog windows above them) and the drop-downs stay visible whatever the insertion order; the bar lies outside
    every client window.  Element budget: D6e 2 + D6f up to 1 + 8 + the map layer's, within PDOS_ELEM_MAX 16.
  * `tests/headless/harness.c`: D6e's include and `profile_sample` block, D6f's include after `pdos_replay.h` and one
    `fprintf` after the BS3 line: disjoint hunks (merged without a conflict).
  * `docs/DOS-PROFILE.md`: unchanged by D6e (D6e does not change the adapter table); 1.7.2 as staged.
  * `tests/harness/ext-zoom-golden.txt`: D6e's copy with its DOS lines regenerated on D6e's tree with D6f
    (`ext_zoom.py --update --profiles dos`, privately into the staged copy; ZOOM_OK with it).
  * The owner table: D6f registers no owner (`PDOS_OWNER_MAX` 5 unchanged).
* **MZ, MZW** (landed during the staging): none of D6f's files but harness.c (rebased: the base copy is MZ's).
* **The follow-up's files** (bases copied from the tree at about 20:21 UTC): `gen/obs_tables.py` and
  `present/obs_tables.c/.h` (regenerate the tables with `gen/obs_tables.py` after merging any other unit's
  EXTRA_SITES; D6f adds three rows), `present/map/pmap_int.h`, `pmap_dos.c`, `pmap_layer.c`.
* **MZI** (staged in `build/mzi-stage/`) shares `present/map/pmap_int.h` and `pmap_layer.c`: D6f adds
  `PMAP_COVER_MAX` and `pmap_dos_cover`'s declaration after `pmap_dos_xrgb` (pmap_int.h), `put_open` after `put` and
  one block in `pmap_overlay` (the covers computed while `s->lprof` is the DOS profile, and `put_open` in place of
  `put` for the layer's pieces) (pmap_layer.c); disjoint from a change of the zoom's geometry, re-applied on MZI's
  copies if MZI lands first.
* **MZS** (MZW-8) shares `present/map/pmap_dos.c` and `pmap_int.h`: re-based onto MZS's copy-in (above); if MZS's
  landing changes them again, re-apply D6f's two hunks (the include of `dos/pdos_reskin.h` and `pmap_dos_cover` after
  `pmap_dos_frame_ok`; `PMAP_COVER_MAX` and the declaration after `pmap_dos_xrgb`).  The shared exclusion geometry and
  the layer's fill are MZS's; D6f's change is the put step only.
* **FCE** (landed before D6f: ALL_GREEN 03:41:10 UTC on its second copy-in) shares `present/dos/pdos_adapt.c`: its
  include of `pdos_fce.h` after `pdos_common.h`'s and its 15-line Escape block in `key_down` right after `f->frame =
  ev->frame;`, which D6f's changed frame test (`ev->frame != PDOS_EVF_N && ev->frame != PDOS_EVF_A`) follows: FCE's
  block first, then D6f's lines (a three-way merge; the orchestrator's order).  FCE's second copy changed only its own
  block (`PDOS_CHAR_TO_DIALOG` for `PI_CHAR_TO_DIALOG`, its comment): merged again without a conflict (the base copied
  again then).  D6f's other hunks (`PDOS_AA_ESC_ROW` in `key_act`, `row_k`, the hook `h_esc_item`) are elsewhere.
  FCE's other files (`gen/dos/registry.py`'s OBSERVER_FILES, `present/input.c/.h`, `platform/w16/host_sync.c`,
  `user_dlg.c`, `w16_int.h`, test.cmd's `ext_fce` section) are none of D6f's staged files; `registry.py check` with
  FCE's copy passes on the overlay (REGISTRY_OK: the staged `pdos_registry.c/.h` and `tests/dos-decoded.txt` as its
  `gen` and `goldens` write them).
* Shared counts: OBS_NCALLSITES 98 -> 101 (test_observer; obs_lint `callsites 101`); no new source (obs_lint files 124;
  portable sources 296, the tree's after FCE).

## Build-slot steps

1. Copy the staged files (`BASE-SHA256.txt`'s list) and this record into the tree; test.cmd and build.cmd unchanged
   (no BUILD-TEST-ADDITIONS.md).
2. The three-step cycle: `build.cmd checked`, `test.cmd checked` (unit counts above; `ext_adapt`: EXT_ADAPT_OK 189;
   `ext_zoom` ZOOM_OK with the staged goldens; `ext_p0` P0_OK unchanged; `adapters.py check` ADAPT_OK rows 116 steps
   25; every other section as before),
   `ext_g1.py check` (EXT_G1_OK unchanged: the core is untouched).
3. The user build for the visual check (section "What the user checks"): the coordinator's, from the landed tree
   (Release), e.g. `build/user-builds/d6f/`.

## Decisions for the orchestrator

The orchestrator's decisions of 2026-10-16, as built:

* **O1 (Escape on the dialog-136 boxes in play): built in D6f, box by box** (section "Escape on the boxes in play
  (O1)"): the tax rate, the luxuries rate and the revolution, quit and retire questions, each proven from its
  DOS and core callers; every other ShowTextDialog box keeps the pass (no blanket change; D7g's rows).  Tests:
  test_input's I-menu/escape-row cases and `pdos_r_escape_item`; ext_adapt f6-taxesc, f6-luxesc, f6-revesc,
  f6-quitesc and f6-retesc (Escape closes the box; the game's memory equals the Return-on-the-opening-row run; the
  box's globals equal a run without a box).  Escape is back in D5-7's user steps.
* **O2 (F10):** accepted as recorded (F10 is Ctrl+0 in the DOS graphics; Alt arms the bar).
* **O3 (Alt+C, Alt+H; Choice D6f-5):** accepted: the Windows meanings (the City and Help menus) kept.
* **The zoom layer over DOS boxes: fixed in D6f** (section "The A placement", the z order), limited to the DOS boxes,
  drop-downs, message boxes and bar drawn on A; the shared exclusion geometry is untouched (MZS's).  Checked at -1
  and +1 with a box open over the map (ext_adapt f6-zcover-m1, -p1, -menu).
* **New, for review: Choice D6f-6** (an A box at least its Windows window's size), found while checking the zoom: the
  Windows dialog's rest (the tax menu's OK button and last radio item) showed beside the smaller DOS box.
* **MZW-8 (MZS's unit; "opening a menu at -1 casts a left shifted thick shadow over the play area map", +1 too):** not
  caused or changed by D6f's z-order change, which only leaves the DOS re-skins' rectangles out of the layer's put step
  (`put_open`) while the DOS profile is drawn; the layer's clip, its popup exclusions (D6c-6, `pmap_layer.c`'s clip from
  the map client's visible region) and the Windows profile are as before.  The shared cause was not found here: a
  640 x 480 headless Windows-graphics run at -1 with the GAME menu open showed no band (one run, the harness's 1:1
  view; the user's scaled window not reproduced).  MZS found the cause meanwhile (M_dos's fill when the port bitmap
  is wider than the client, `md_fill`); D6f is re-based onto MZS's copy-in, and both changes compose (the fill decides
  the layer's pixels, D6f's put leaves the re-skins' rectangles to the A frame).

## Report items (rows a DOS screen lacks, shown by D6f), with the D7 unit that removes each

* R1: the drop-downs of the Windows-only menus Edit, City and Help (their titles are P24's settled design).  **Owner:
  none.**  No D7 unit (D7a..D7o, BRIEF-d7.md) takes the menu bar or the drop-downs; they stay by design (P24, ruling 2)
  unless the orchestrator assigns them.
* R2: Windows separators as empty disabled rows; ORDERS shows every Windows item including the grayed ones (colour 3),
  where DOS builds only the orders available on the square (R:1C84:01D8).  **Owner: none** (ruling 2: the core's state
  decides which rows exist; no D7 unit lists the drop-downs).
* R3: message boxes in play are re-skinned Windows dialogs.  Revolution's message boxes (DOS-PROFILE row 41): **D7g**
  (its rows include 41).  Help > Game Help's box (W4, row 94) with its "OK" row and the system message boxes (W6, row
  141): **D7o** records them as W with DOS-PROFILE 4's reason (its ledger's rows 94 and 141); no unit removes their OK
  row (Windows-only boxes with no DOS screen).
* R4: dialog 145's boxes lack DOS's "(HELP AVAILABLE)" line (DGROUP:2FBD): **D7g** (rows 14 and 22: "the help line
  DGROUP:2FBD, if D5b or D6f left them").
* The former known limitation (the zoomed map layer over a DOS box) is fixed (section "The A placement").

## What the user checks

On the coordinator's user build of the landed tree (`civ64.exe`, DOS files present), in play (load a saved game or start
a new one) with the DOS graphics (`--graphics dos` or Ctrl+Shift+Backspace), the main map window active:

1. **D6-1, rewritten (the menu bar).**  At the top of the main window: the DOS titles GAME, ORDERS, ADVISORS, WORLD and
   CIVILOPEDIA (the first letter white, the rest gray, as DOS draws them), and EDIT, CITY and HELP in capitals with the
   Windows menu's underlined letter in white and the rest gray, at the Windows title positions, in the DOS font at 1x on
   black beside the 2x DOS map.  Clicking a title opens its menu; the open title is highlighted in cyan.  Judge whether the 1x
   text beside the 2x art is acceptable.
2. **D6f-1 (the drop-downs).**  Each menu opens as a DOS menu box (gray box, bevel, black items in the DOS font, twice
   the size) at the Windows menu's place, covering it; GAME, Options, ADVISORS, WORLD and CIVILOPEDIA show the DOS item
   texts; unavailable items in the DOS disabled colour (3), separators as empty rows; ORDERS, EDIT, CITY and HELP show
   the Windows texts with their keys in white.  The arrow keys, Return, Escape and the letters work as in the Windows menus; clicking a
   row chooses that item.
3. **D6f-2 (the check marks).**  GAME > Options: the settings that are on carry the DOS mark '^'.
4. **D6f-3 (the F keys).**  F1..F6 open the advisors (City Status, Military, Intelligence, Attitude, Trade, Science),
   F7..F10 the World reports (Wonders of the World, Top Five Cities, Civilization Score, World Map), as DOS's F keys do.
5. **D6f-4 (Alt keys).**  Alt+V switches the sound (the GAME > Options > Sound setting changes); Alt+G opens the GAME
   menu; Alt+Q asks whether to quit.  Alt+C and Alt+H open the CITY and HELP menus (the Windows meaning).
6. **D5-7, rewritten (a re-skinned DOS menu box in play).**  Screen: in play with the DOS graphics press Ctrl+T (or `=`,
   or GAME > Tax Rate): the game's tax-rate menu (Windows dialog 136) appears as a DOS menu box at twice the size at the
   Windows dialog's place (gray box 7, bevel 15 and 8, black rows of 8 pixels in DOS font 1, the bar's highlight on the
   current rate; textured as DOS draws in play).  Up and Down move the bar; Return or Space choose the highlighted rate;
   a press on a row, a drag to another row and the release there choose that row; no Go Back or Cancel row.  A box near
   the screen's edge is moved fully inside.  **Escape closes the box and the tax rate stays as it was** (the status
   panel's rates unchanged), as DOS's Escape does; the same with Ctrl+L (the luxuries rate).  Nothing of the Windows
   dialog (its OK button, a radio item) shows beside or below the DOS box (Choice D6f-6: the box's textured background
   fills its Windows dialog's place).  Build: the coordinator's d6f user build.
7. **D6f-5 (message boxes in play).**  HELP > Game Help: the message box as a DOS menu box at 2x with an OK row and no
   Cancel row; Return or a click on OK closes it; a press on OK dragged off the box and released over the map does
   nothing.
8. **D6f-6 (switching).**  Ctrl+Shift+Backspace with a menu open or a box shown: the Windows menu or dialog unchanged;
   back again: the DOS one.
9. **D6f-7 (Escape on the questions).**  Ctrl+R (or GAME > Revolution), then Escape: the question closes and no
   revolution starts.  Ctrl+Q (or GAME > Quit, or Alt+Q), then Escape: the question closes and the game goes on; again,
   File > Retire (Alt+F, E), then Escape on its question: the game goes on.
10. **D6f-8 (the zoom with DOS menus and boxes).**  Zoom the map to -1 (Ctrl+Shift+Minus) and, separately, +1
   (Ctrl+Shift+Plus); open the GAME menu and, separately, the tax box (Ctrl+T) where they lie over the map: the DOS
   drop-down and box are drawn whole, no part covered by the zoomed map; the zoomed map shows around them; closing them
   leaves no remnant of the box or of the Windows dialog.

Not part of this check: the World Map, the Status window and the unit panel (D6e); the city screen and the other
in-game screens (D7); the menu's shadow at -1 and +1 in the Windows graphics (MZW-8, MZS's).

## For the records

* **DESIGN 12.9 "As implemented (D6f; area B and C)":** the bar (P24 as built: Windows geometry, MENU_TITLES with the
  87h switch, Windows-only titles in capitals with the mnemonic in 15, font 1 at scale 1, the highlight 0 -> 11), the
  drop-downs (Choices D6f-2, D6f-3; the marks; ruling 2's pairs), the A placement of D5b's re-skins (decision 1, ruling
  1), frame 2's rows (Choice D6f-1, the scenes, I5 class A, acts CTRL / MENU / WND), case 13, the `preskin` diag line.
* **FIDELITY** (new entries, numbers to be assigned): (a) the DOS menu bar at scale 1 over the Windows bar geometry, with
  Edit, City and Help, which DOS lacks (P24, B14, B15); (b) drop-down rows follow the Windows menus (which items exist,
  grayed, checked, separators), with DOS texts only where an item pairs by role; ORDERS unpaired (Choice D6f-3); (c) F1..
  F10 as Ctrl+1..Ctrl+0 and Alt+V/G/Q through the Windows menu paths; F10 no longer the Windows menu key in the DOS
  graphics (O2); Alt+C and Alt+H keep the Windows meaning (Choice D6f-5); (d) Alt+V on a MenuZ box does nothing (Choice
  D6f-4); (e) Escape on the tax and luxuries rates, the revolution, quit and retire questions closes them with no
  change, as DOS's -1 (O1: a click on the row selected at the opening, then Return); on every other dialog-136 or 145
  box in play it does nothing where DOS closes the box (until D7g); (f) the re-skinned message boxes in play are Windows
  dialogs shown as DOS boxes (R3); (g) an A box at least its Windows window's size (Choice D6f-6: larger than DOS's box
  where the Windows dialog is larger); (h) the zoomed map layer never covers a DOS box, drop-down, message box or the
  bar on A (the orchestrator's direction).
* **RUNNING.md:** presentation-diag.log's `preskin` line (fields above, with abox_w, abox_hh, abox_win_l/t/r/b and
  drop_w, drop_hh); ext_adapt's f6-* cases (f6-taxesc, f6-luxesc, f6-revesc, f6-quitesc, f6-retesc, f6-nobox,
  f6-zcover-m1, -p1, -menu) and ringref-dos; obs_lint's `callsites 101` (98 before); ext_zoom's DOS goldens
  regenerated by D6f (the DOS menu bar in every in-play view).
* **FEATURES.md:** the DOS menu bar, drop-downs and re-skinned boxes in play (D6f), with the runners above.
* **DOS-PROFILE.md prose:** row 121 onwards (the play screen's menus): the bar and drop-downs done (D6f); 1.3 the I-play
  keys (F1..F10, Alt+V, Alt+G, Alt+Q) and C.12.9's passed keys; OPEN L3, L19, L25 and L27 outcomes (above).
* **Draft C C.12.8:** Choice D6f-4 (Alt+V on a MenuZ box consumed) differs from the outline; the I-play extension for
  Alt+G and Alt+Q (L3).  **Draft B 11.2:** Choice D6f-2 (the drop-down covers its popup), D6f-3.
* **manual-checklist-ext.md:** D6-1 and D5-7 rewritten as above (D5-7 names the screen, the steps, dialog 136, Escape
  and the d6f user build); new items D6f-1..D6f-8.
* User direction 2026-10-16: the per-screen Escape table above (none consumed; O1 built for five boxes), the Cancel /
  Go Back audit; report items R1..R4 with their owners.
* **Draft B 6.2 / D6c-6:** the map layer's put step leaves the DOS re-skins on A uncovered (`pmap_dos_cover`); Choice
  D6f-6 for 11.3.
* Not edited by this unit (as the brief says): DESIGN.md, FIDELITY.md, STATUS.md, RUNNING.md, FEATURES.md,
  DOS-PROFILE.md outside its generated section 1.7.2, manual-checklist-ext.md, the D1 drafts and the D0 documents.

## Landing (2026-10-17, build slot)

**READY_TO_BUILD reported 04:24 UTC; copy-in 04:24:37 UTC; cycle ALL_GREEN 04:51:44 UTC; RELEASE_OK 04:54:56 UTC;
user build `build/user-builds/d6f/` (04:55 UTC).**  Landed by this unit on the orchestrator's instruction of
2026-10-17 (the slot free after FCE's landing, ALL_GREEN 03:41:10 UTC, RELEASE_OK 03:45:49 UTC; no docs pass
running): land directly after reporting READY_TO_BUILD with the file list and predictions, once the full private
rerun on the post-FCE tree was green (section "Results": the first bullet).

1. **Bases** (`build/d6f-prep/land.py`, adapted from FCE's): the 33 tree files of `build/d6f-stage/BASE-SHA256.txt`
   still had their base hashes (pdos_adapt.c FCE's 5e331ac8...), test.cmd (77c7bb11...) and build.cmd (40de571d...)
   unchanged, `docs/ext-D6f-record.md` absent; the staged copies frozen (`staged.sha256`, 34 files) after the last
   staging edit; dry run `DRY_RUN_OK 34`.
2. **Predictions** (`build/d6f-prep/predictions.txt`, written 04:24:19 UTC, before the copy-in) on FCE's cycle -r2
   (its outputs the snapshot): portable sources 296, TEST_SECTIONS 29 failed 0; unit test_input 449 -> 502,
   test_pdos_reskin 67 -> 121, test_observer 108 -> 115, test_dos 23233 -> 23239 (decoded 1363 -> 1369 lines);
   dos-decoded.txt six rows; registry-check.txt 25 MENU lines and 1363 -> 1369; OBS_LINT_OK callsites 98 -> 101;
   OBS_TABLES_OK sites 98 -> 101; ADAPT_OK rows 98 steps 22 -> rows 116 steps 25; EXT_ADAPT_OK 154 -> 189 (as the
   private `obj/run/c2-runadapt_full.txt`); nodos 1750 -> 1751 files, 0 hits; coverage informational; every other
   output unchanged; EXT_G1_OK runs 77 unchanged; Release 296.  Each from a private run of the same section on the
   post-FCE overlay, except the core sections that take no private root (scenarios, p4tests, gate3b, uninit,
   harness_stub, trace).
3. **Snapshot and copy** (04:24:37 UTC): the tree's Checked test outputs (63 files of `build/test/Checked`, FCE's
   cycle -r2) in `build/d6f-prep/before`, the tree's previous 33 files in `build/d6f-prep/tree-before`; the 34 files
   byte for byte (33 changed, 1 new): `LANDED 34`; manifest `build/d6f-prep/landed.sha256` (the 34 files and the
   unchanged test.cmd and build.cmd, every hash rechecked against the tree), `landed-at.txt`.
4. **The cycle** (`build/d6f-prep/d6f-cycle.ps1`, FCE's with the names changed; status `build/d6f-status.txt`, logs
   `build/d6f-<n>-<step>.log`):
   - 1 build-checked: exit 0, 188 s, BUILD_OK, portable sources checked 296, no warning.
   - 2 test-checked: exit 0, 1428 s, TESTS_OK, `TEST_SECTIONS 29 parallel, budget 20, wall 1426.4 s, failed 0`.
   - 3 g1-checked: exit 0, `EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events)`: **ALL_GREEN** 04:51:44 UTC.
     No G-1 amendment.
   - 4 build-release: exit 0, 180 s, BUILD_OK, portable sources checked 296, no warning: **RELEASE_OK** 04:54:56 UTC.
5. **Comparison** (`build/d6f-prep/compare.py`, output `compare.txt`): 48 of 63 files equal (lines with host times
   left out).  The differences, each predicted but one:
   - `sections/unit.log`: test_input 502, test_pdos_reskin 121, test_observer 115, test_dos 23239 checks with
     `decoded content: 1369 lines, 0 differing from the Python models' goldens`, and, not predicted, test_dos's
     `registry: 44 tables valid; 12 negative descriptors refused` -> `50 tables valid` (the six MENU tables, the same
     cause as the predicted lines); OBS_COST host-time lines.
   - `dos-decoded.txt`: the six MENU rows.  `registry-check.txt`: the 25 MENU lines and 1369 lines; REGISTRY_OK.
   - `obs-lint.txt` / `sections/d3a_obs_lint.log`: callsites 101; `obs-tables.txt` / `sections/d3a_obs_tables.log`:
     sites 101; `adapters-check.txt` / `sections/d4c1_adapters.log`: ADAPT_OK rows 116 steps 25.
   - `ext-adapt.txt` / `sections/ext_adapt.log`: EXT_ADAPT_OK checks 189; the file equals the private
     `obj/run/c2-runadapt_full.txt` line for line (ring-dos against ringref-dos, its decisions line, the 34 D6f lines).
   - `nodos.txt`: 1751 files, 0 hits.  `coverage.txt` / `sections/coverage.log`: "other functions entered" 666 -> 664
     (informational: the known torn lines of the parallel appends, X9).  `sections/times.txt`: timing.

   Every other output equal: ZOOM_OK (`combinations 32 runs 108 samples 628 map comparisons 32 centre runs 4 mzi
   runs 12 mzs runs 4 not zoomed 38/448`, every sample equal to the landed goldens with D6f's DOS lines), P0_OK checks
   476, MIRROR_OK runs 29 (present_mismatched 0, dos_mismatched 0), REPLAY_OK checks 70, EXT_FCE_OK runs 8,
   EXT_TLD_OK, EXT_SLOTS_OK, EXT_FRAMES_OK, EXT_TIMELINE_OK, EXT_CONTINUE_OK, EXT_ASPECT_OK, EXT_BS_OK, P4_TESTS_OK,
   P4_SCENARIOS_OK, GATE3B_OK, UNINIT_OK, pdos_scene_check PASS 1078, TRACE_OK.  Goldens changed as recorded
   ("Expected changes"): `tests/harness/ext-zoom-golden.txt` (240 DOS lines) and `tests/dos-decoded.txt` (six rows).
6. **User build** `build/user-builds/d6f/` (`build/d6f-prep/mk_userbuild.py`, from FCE's; `USER_BUILD_OK 4`):
   `civ64.exe` (the Release build, SHA-256 b167a4c2...a4129853, 4,414,464 bytes), `CIVWIN.zip` and `civdos.zip`
   (byte-identical copies from `user-builds/d4`, SHA-256 058d4e00... and 0eac32c9... checked) and `WHAT-TO-CHECK.txt`
   (SHA-256 5a61daeb..., CRLF, ASCII): D6-1 (rewritten), D6f-1..D6f-4, D5-7 (rewritten), D6f-5..D6f-8 as in "What the
   user checks", in plain words; a "Good to know" part naming what the DOS game lacks that this build still shows
   (the EDIT, CITY and HELP menus; separators and grayed ORDERS rows; the Windows message boxes drawn the DOS way;
   the missing "(HELP AVAILABLE)" line) and that Escape on the other small menu boxes still does nothing (a later
   unit); the builds it contains (fce, tld, d6e, mzs, si, mzi, ux5, mzw, mz, ux4b, d5p, ux4, d6d, sl and the earlier
   ones); the note that civ64 runs only once at a time (SI); and the items still open from the checklist's pending
   rows at 04:52 UTC (`build/d6f-prep/fill_stillopen.py`, from FCE's, the checklist read only): FCE-1..FCE-5,
   TLD-1..TLD-7, D6e-1..D6e-7, MZS-1..MZS-6 and MZW-8, SI-1..SI-6, MZI-1..MZI-7, UX5-1..UX5-7, D5P-7 and P47-1 (48);
   D6-1 and D5-7, still pending as "not yet implemented", are this build's own items.
7. **Not done here** (the orchestrator and the next docs pass): the checklist (D6-1 and D5-7 rewritten, D6f-1..D6f-8
   new, each pointing to `build/user-builds/d6f/`), the FIDELITY entries (unnumbered) and the other entries of "For
   the records".  The stage `build/d6f-stage` equals the tree for the 33 changed files; this record differs from its
   staged copy by the landing's edits (this section and the header's last sentence).

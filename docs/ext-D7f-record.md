# Extension phase D7, unit D7f (the list, entry, production and stack dialogs) - record

Draft for the build slot (BRIEF-d7.md "Units" D7f, extension session E4, track C; taken over from track A by the
orchestrator's assignment after D7l's landing).  Staged in `build/d7f-stage/` on the tree after D7l's landing, rebased
by three-way merges onto the tree after the landings of D6fS-b, HM, D7l2, D6fSc, D7e and D7k and the docs pass e4g
(section "Rebase notes"); the base of every staged file is recorded in `BASE-SHA256.txt`.  Private builds and runs in
`build/d7f-stage/obj/` only: an overlay `obj/src` = the tree + the stage (`obj/mkoverlay.py` once, then `obj/treecmp.py
--copy` for the tree's later changes and `obj/sync.py` for the stage's), built with the tree's build.cmd and flags
(`obj/b.cmd`, `--nogen`), cc.cmd's stricter checks per file (`obj/cc.cmd`), the unit programs (`obj/unit.py`) and the
harness runs from the overlay's binaries (`obj/xs3.py`, `obj/explore.py`, `obj/runadapt.py`) with every output under
`obj/`; the tree's build/gamedata, dosdata and cache read only.

## Result

With the DOS graphics, five Windows dialogs of play show as the DOS game's boxes, drawn from the core's own dialogs
(P0: read through w16q_*, no core call):

* **The production list** (dialog 140, City > Change or 'c' on the city screen): the DOS production menu R:0ADE:0421
  at (80, 8) over the N city screen: "What shall we build in <city>?" (DOS's words), one row per core item (the
  core's strings), font 1 or 2 by DOS's rule (font 2 above 20 entries or paged), the green "(HELP AVAILABLE)" line at
  the box's lower right (R:1D05:075B..0796, a shared helper D7g reuses), more than 30 entries paged as DOS pages them
  ("more..." rows); the bar on row 0 at the opening (ruling H2), Up/Down/letters move it, Return or a click chooses,
  Alt+H or the right button opens the item's Civilopedia entry (the dialog's HELP button), Escape cancels (FCE).
* **The buy question** (row 87, 'b' on the city screen): DOS's box R:0D12:4CDF..4E37 at (100, 80): "Cost to complete",
  the production's name and cost, "Treasury: $" and the gold, then " Yes" / " No" (DOS's order; the core's MenuZ items
  1 and 0) or "CIVIL DISORDER".
* **The text entry** (dialog 137: the founding prompt, City > Rename and 'r'): DOS's city-name box O23:0000 (80, 80,
  160, 32) with "City Name..." and the field O23:0414 (88, 96) with the blinking cyan cursor cell; on the N city screen
  at the DOS position, in play on the A canvas at 2x at the Windows dialog's place.  The keys pass to the core's EDIT
  (I-text, D5d's rows).
* **Find City** (dialog 131, '/' or World > Find City): P16 settled: the core's sorted city list as a DOS menu box in
  font 1 with the core's prompt as its header, the rows that fit, the window following the bar; Return or a click
  chooses (the city's item selected in the core's list, then Return), Escape cancels (FCE).
* **The unit stack popup** (dialog 141, a click on a square with own units): DOS's popup R:0866:1F69 (box colour 3,
  per unit its DOS shape, the type name with " (V)" for a veteran in colour 15, the home city in colour 14, 16-pixel
  rows), no highlight (DOS draws its bar only without a mouse); a click on a unit's row wakes it (the core's row
  clicked), the popup stays while more than one unit is listed, any key ends it (the dialog's OK).

No Go Back or Cancel row is drawn (the user's rule of 2026-10-16): Escape cancels where DOS has it (FCE).  The Windows
graphics are unchanged.

## Status

LANDED (2026-10-18: copy-in 02:30:03 UTC, ALL_GREEN 03:10:38 UTC, RELEASE_OK 03:15:33 UTC, user build
`build/user-builds/d7f/`; section "Landing"); the user checks D7f-1..D7f-7 are pending.  Built: rows 12 (dialog 131,
also row 32's screen), 15 (dialog 137, also row 89 and the founding prompt), 17 (dialog 140, also row 86), 87 (the buy
question) and 18 (dialog 141) as R elements of a new module `present/dos/pdos_rdlg.c/.h`; the menu box's help line
(`pdos_menubox_help_line`, `PdosMenuBox.help`); the adapter scene PDOS_AS_RLIST (0x10000000, the free bit the
orchestrator named, confirmed: the last free AS bit) with six I-menu list rows and the decision PDOS_DEC_RLIST; the acts
PDOS_A_LBPICK, PDOS_A_LBHELP and PDOS_A_STACKROW with the predicates PDOS_PR_LB_SEL and PDOS_PR_LB_DONE; the registry
tables PROD_TEXTS, PROD_MORE, HELP_AVAILABLE, BUY_TEXTS, STACK_VETERAN, CITY_NAME_PROMPT and UNIT_RECORDS.  The menu
boxes' text lines take D6fSc's shared line rule (`pdos_r_spec_dos_lines`): DOS's own lines kept whole, the core's text
(Find City's prompt) wrapped at `PDOS_R_DOS_WRAP` columns.  Not built: the production advisor boxes (P19 stands; the
production menu's code leaves room for them, "Deviations" 2), the selection flash (G#3, 20 frames, SCENES-PLAY 7.12) and
the header icon (R:0ADE:0421 sets none; "Deviations" 3).  No AA bit and no shadow owner taken (PDOS_OWNER_MAX unchanged:
10 since D7e).

## What was built

### The module `pdos_rdlg.c/.h` (area B; P0)

One slot per open dialog of the five kinds, found at OBS_DLG_CREATE by template (131, 137, 140, 141; the buy question:
the plain MenuZ dialog created while ShowTextDialog's call from 1030:5CCF is pending, return address PDOS_RL_BUY_RA),
shown at its OBS_WND_SHOW (D6fS-a's cover hides the Windows dialog from that instant; the buy box's MenuZ cover is
pdos_reskin's), built again whenever the dialog's list, edit text, focus or enabled state changes and freed with its
window.  The controls are resolved lazily (the list box, the HELP button, the EDIT, OK), since the core fills a list
after its dialog shows.  pdos_reskin leaves a MenuZ box this module owns (`pdos_rdlg_owns`).  The scene rows (12, 15,
17, 18, 87) are set ready when the DOS form is first built (`pdos_scene_set_ready`).

Placement (draft B 11.3): over the N city screen (D7d's frame) at the DOS position; in play on the A canvas at 2x at
the Windows dialog's top-left (pdos_reskin's `a_place_of`, through the new `pdos_reskin_a_place`), following the frame
at every core present (`pdos_rdlg_present`).  The menu boxes (production, Find City, buy) are pdos_reskin R elements
(PDOS_RK_BUILT, DOS sizes, as tall as their content); the entry and the stack are own surfaces (`own_surface`) whose A
rectangles join the zoom layer's z order (`pdos_rdlg_a_rects` appended by `pdos_reskin_a_rects`).

Text lines (unit D6fSc's rule, `pdos_reskin.h`): a header line made of DOS's strings (the production menu's, the buy
question's) goes through `pdos_r_spec_dos_lines` with its own line feed, so it is DOS's hand-broken line, kept as it is
(R:1D05:0475 wraps nothing; only a line wider than `PDOS_R_WRAP` x 8 pixels would wrap); Find City's prompt is the
core's text, folded and wrapped at `PDOS_R_DOS_WRAP` (25) columns ("Select city to find:" is 20, one line).  The
entry's prompt and the stack's rows are drawn by DOS's own routines on own surfaces (one line each).

### The production menu (row 17; SCENES-PLAY 7.12; R:0ADE:0421)

| Core (Windows) | DOS (listing) | The renderer |
|---|---|---|
| ChooseCityProduction 1170:05CA: GR_DialogOpen(140) 1170:0651, the header (city name + DSTR 35BE) by SetWindowText 1170:06C8, LB_ADDSTRING per unit, improvement and wonder (1170:08FE, 0BAF, 0CC0), the selection (the current production) 1170:1C07, RunModalDialogLoop 1170:1C24 | R:0ADE:0421: DGROUP:222A + the city's name + DGROUP:2242 into BA06, each row's name, turns and ", ADM:" form, improvements from 07E3; 1 + entries above 30 page for the human player's city without status bit 10h (R:0ADE:08DD..0949; "more..." DGROUP:225F / 2268, R:0ADE:1474..1489), font 2 above 20 entries or paged (R:0ADE:1438..1449), DGROUP:2FA0 = 1 (R:0ADE:144E), the menu R:0238:0008(text, 80, 8) | the header in DOS's words with the core's city name; one row per core item with the core's string (decision 15: the core's rows keep their text, the DOS rows' form differs in the turns), DOS's paging and font rule, the help line |
| the HELP button (103) opens the Civilopedia | Alt+H / the right button: the help flag DGROUP:2F9C, O8:062A, then the menu again (R:0ADE:1495..14E0) | PDOS_RDV_HELP: the item selected in the core's list, then the HELP button (PDOS_A_LBHELP) |
| the advisor boxes: none in ChooseCityProduction; the core shows Instant Advice boxes (ShowInstantAdvice, the text boxes D7g owns) before some of its calls: ProcessCity 1030:69AD before 1030:6A43, FoundCity 1040:045E before 1040:0585 | R:0ADE:13CA..1424 draws the advisor boxes before the menu (PRODUCE.TXT, option bit 1) | not drawn (P19 stands); `prod_build` keeps the menu's place and font independent of them, so they can be added before the menu if the orchestrator rules so |

The help line (`pdos_menubox_help_line`, pdos_ui.c; named for D7g): R:1D05:05BA..05C1 makes the box two pixels taller
when DGROUP:2FA0 is set; R:1D05:075B..0796 saves the port's font, selects font 2, draws "(HELP AVAILABLE)" (DGROUP:2FBD,
the registry's HELP_AVAILABLE) at (right - 74, bottom - 4) in colour 10 and restores the font.  `PdosMenuBox.help` is
an input kept by `pdos_menubox_layout`, like D6f's `marks`; `PdosRSpec.help` carries it into an R element.  D7g's
help boxes of dialogs 136 and 145 set the same flag.

### Find City (row 12; P16 settled)

The core's sorted list (RunListBoxDialog 1098:1909, template 131's LISTBOX 103) as a DOS menu box at (64, 8) on N, in
play on A at the Windows dialog's top-left at 2x: the core's prompt "Select city to find:" (DOS has none: its typed-name
box O23:0319 is not shown) as the header, then the cities in font 1; as many rows as R:1D05:057D's clamp leaves (at
most 30), the window following the bar (`pdos_rd_window`) with no "more..." row DOS lacks.  The bar starts on row 0
(H2) and is kept while the core fills the list after the dialog shows.

### The text entry (rows 15 and 89, the founding prompt; SCENES 10.4)

O23:0000's box: R:0000:0BFA(80, 80, 160, 32, 15), R:1D05:0A05 outline in colour 11 (O23:002D), "City Name..."
(DGROUP:539E) at (88, 82) in colour 0, the field O23:0414(88, 96, 12) drawn as D5d's name field (cells of 8 x 8, the
caret's cell recoloured 15 -> 11 over 10 rows, blinking through pdos_fx's blink), in font 1 (R:0D12:56AF sets font 1
before O23:0000 for City > Rename; the founding prompt's font is inferred the same).  The field shows the core's EDIT
text and caret (`pdos_rd_field_layout`, scrolled when the caret leaves the 12 cells; at most 18 cells fit in the box).
SCENES 10.4 gives the prompt at (82, 88): the listing pushes y 82 and x 88 (O23:0049, O23:004D; "For the records").

### The buy question (row 87; R:0D12:4CDF..4E37)

The core builds "Cost to complete <name>: $<cost>\rTreasury: $<gold>\r" + "_No_Yes" (or "CIVIL DISORDER\r") at
1030:5B63..5CAD and shows it with ShowTextDialog at 1030:5CCF (a MenuZ box).  The renderer parses the core's text
(`pdos_rd_buy_parts`) and draws DOS's box R:0238:0008(text, 100, 80) in font 1: DGROUP:266E, the name with ": $"
(DGROUP:2680) and the cost, "Treasury: $" (DGROUP:2684) and the gold, then " Yes" and " No" (DGROUP:26A3; DOS's row
0 buys: the core's item 1) or DGROUP:2693.  A text of another form keeps the generic box.

### The unit stack popup (row 18; SCENES-PLAY 7.19; R:0866:1F69)

DrawUnitStackList 11C0:3407(civ, firstUnit, selectedRow) is probed at entry: its arguments name the ring (unit + 0Ah)
read through w16q_read (at most 12 units, R:0866:1FC0).  The popup: R:1D05:096C(100, 96 - 8n, 120, 16n + 5, 3); per
row r (y0 = top + 5 + 16r) the unit at (106, y0) through the map layer's unit drawing (R:1AEA:0FB3, `pdos_rdlg_set_unit`
from pmap_dos.c: the shape D4CE[64 + 32 civ + type] with its marks), the type's DOS name (UNIT_RECORDS, DGROUP:112A +
22h type) and " (V)" (DGROUP:2224) for a veteran at (128, y0) in colour 15, the home city (DGROUP:2913 "NONE" for
none) at (128, y0 + 8) in colour 14.  No highlight: R:0866:20EE draws the bar only when DGROUP:1A3C (the mouse flag)
is 0, and civ64 always has a pointer (ruling H2).

### The adapter rows (area C; C.12.8 I-menu, I-stack; P26)

While one of these elements is the topmost on the frame's canvas, the scene is PDOS_AS_RLIST (0x10000000) with the
dialog as r_hwnd, READY when the dialog is shown, enabled and active (the buy box: its MenuZ in its input loop).  One
decision PDOS_DEC_RLIST asks `pdos_rdlg_key`, `_press` and `_choose` (hooks for the tests: `rd_decide`, `rd_hit`,
`rd_view_row`, `rd_lb_pick`, `rd_point`).  Rows (pdos_adapt_tab.c, after I-city):

| Row | Actions | Decision |
|---|---|---|
| I-menu/list-mod | Ctrl, Shift, Alt, a lock key | consumed |
| I-menu/list-key | a key (READY) | R:1D05:01DB..03FD: Up/Down move the bar (no wrap), a letter moves it to the next matching row (R:1D05:03FD), Return/Space choose, Alt+H with the help flag, Escape -1; "more..." switches the page; the stack: any key is OK (R:0866:2104..210D) |
| I-menu/list-press | a press (READY) | a menu box: the bar follows the held button (DRAG), the release decides; the stack: the left button on row r clicks the core's row r (y 5 + 33r + 16, UnitStackDialogSubclassProc 11C0:3702), with one unit then Return once the core has woken it (STACK_WOKEN); another button: Return |
| I-menu/list-release | the release on a row or off the box | the row chosen, or -1 (the dialog's cancel; the buy question's "No") |
| I-menu/list-char | WM_CHAR | consumed (the key press decided) |
| I-menu/list-other | anything while the dialog is not active | consumed |

A chosen list item becomes PDOS_A_LBPICK: `pdos_rd_lb_pick` makes item k the core's list selection from the list
box's live state (a click on k when shown; else Home/End when that shows k, Page Down/Up as user_listbox.c moves them,
a click on k once shown; a click on a shown row first when the list lacks the focus) as steps (`PdosRdStep`: a key or a
click), whose Windows events pdos_adapt.c's resolve makes (the filter stage alone makes events: I1, obs_lint), released
one act per sync, then
Return at LB_SEL (k selected) or LB_DONE (the predicted state reached).  Help: the same pick, then a click on the HELP
button (PDOS_A_LBHELP).  The buy question: a click on its MenuZ item, Return at the release (D6fS's MZ path).  -1 is
FCE's Escape (the dialog's own cancel).

### Registry tables (OFFSETS.md; DOS file, DOS listing)

PROD_TEXTS (DGROUP:222A, 3 strings), PROD_MORE (DGROUP:225F, 2), HELP_AVAILABLE (DGROUP:2FBD), BUY_TEXTS (DGROUP:266E,
6), STACK_VETERAN (DGROUP:2224), CITY_NAME_PROMPT (DGROUP:539E), UNIT_RECORDS (DGROUP:112A, 952 bytes); each reader
listed; `registry.py check` verified every row against the DOS copy and the listing.

### Evidence labels

* DOS listing: every R:, O23 and DGROUP address above (build/dos/disasm root.lst and ovl23.lst, read only); DOS file:
  the registry's tables and the fonts; the Windows side from the port's reconstruction (core/seg047_1170_p2.c,
  seg020_1098_p1_r.c, seg031_10F0_r.c, seg057_11C0_p3.c, seg063_11F0_p1.c, seg008_1030_*.c).
* Inferred: the founding prompt's font 1 (only City > Rename's R:0D12:56AF is read); the buy box's font 1 for the
  core's other ShowTextDialog forms; Find City's position (64, 8) on N (a port choice: P16 has no DOS position).
* DOS oracle: none (no DOS program run).

## Files

Changed (bases in `BASE-SHA256.txt`): `present/dos/pdos_adapt.c/.h`, `pdos_adapt_tab.c`, `pdos_pend.c/.h`,
`pdos_profile.c`, `pdos_registry.c/.h` (generated by `registry.py gen` from OFFSETS.md), `pdos_reskin.c/.h`,
`pdos_ui.c/.h`, `present/map/pmap_dos.c` (the unit hook), `gen/dos/adapters.py`, `gen/dos/registry.py`
(OBSERVER_FILES += `pdos_rdlg.c`), `docs/DOS-PROFILE.md` (1.7.2 regenerated), `docs/dos/OFFSETS.md`,
`tests/test_input.c`, `tests/dos-decoded.txt` (registry goldens), `tests/headless/harness.c` (the `rdlg` diag line),
`tests/harness/ext_adapt.py` (the D7f pairs), `tests/harness/ext-zoom-golden.txt` (the ten DOS `new` samples at
45,000 ms: the founding prompt is D7f's entry box).  New: `present/dos/pdos_rdlg.c/.h`, `tests/test_pdos_rdlg.c`, this
record.  Unchanged, though the brief lists them: `pdos_scene_tab.c` (rows 12, 15, 17, 18 and 87 exist),
`tests/test_pdos_reskin.c` (the new module's test is its own program).  build.cmd and test.cmd unchanged (new files
are found by their globs).

## Tests

* **`tests/test_pdos_rdlg.c`** (new; DOS fonts from the copy's store at run time, no DOS byte held): the production
  rules (paging, font, rows of each page), Find City's window, the list pick's steps (a click on a shown item; Page
  Down landing exactly on k; a click after Page Down; the steps that fit the events' room; End; Home; Page Up twice; no
  focus; refusals), the field layout, the
  entry's drawing (box, prompt, field, cursor cell), the stack (top, rows under points, the drawing through the hook,
  colours 15 and 14), the buy text's parts, the help line (the box two pixels taller, colour 10, font 2, the font
  restored).
* **`tests/test_input.c`**: ten I-menu list vectors (mod; key: a pick, Return, Up; press: the stack's row, a press on a
  box; release on a row and off the box; char; another key while the dialog is not active) and `adapt_rlist` (a pick's
  steps as events now: the synthetic pick's Page Down as its press and release, its click as move, press and release;
  four more pick acts until LB_DONE, Return at LB_SEL; with Alt the HELP button at LB_SEL; the buy item's
  MZ click and Return at MZ_SEL; Up as a view action, its repeat decided again; the stack's row with one unit: the
  click and Return at STACK_WOKEN; a right press dragged over row 3, off the rows and released on row 2; a release on
  another frame; the dialog not active: consumed); the row count 147 -> 153.
* **`tests/harness/ext_adapt.py`**, the D7f pairs (each DOS form against its Windows form; the core outputs equal):
  `d7f-prod` (c on Rome's city screen, Return: item 0 clicked, Return at LB_DONE), `d7f-buy` (b, Return: Yes),
  `d7f-name` (r, A, b, Return: passed), `d7f-find` (Escape, '/', Down, Return: Rome), `d7f-stack` (D7j's save: a click
  on the Legion and Cavalry's square, a click on row 0, Return); each also checks presentation-diag's `rdlg` line and
  the frame shown while the box is open.

## Results (private, `build/d7f-stage/obj/`)

On the overlay `obj/src` = the tree after D7e's landing and the docs pass e4g + this stage (2026-10-18, about 00:00 to
01:20 UTC); the tree's suites (read only) run with the overlay's binaries, every output under `obj/run`:

* **Builds** (`obj/b.cmd`, the tree's build.cmd with `--nogen`): Checked, CheckedNoObs and Release BUILD_OK, no
  warning; portable sources checked 307 (the tree's 306 + `pdos_rdlg.c`); one more test program (`test_pdos_rdlg`).
  `obj/cc.cmd` (c11, c17 /W4 /WX, the clang C99 parse) on `pdos_rdlg.c`, `pdos_adapt.c`, `pdos_adapt_tab.c`,
  `pdos_pend.c`, `pdos_profile.c`, `pdos_reskin.c`, `pdos_ui.c`, `pdos_registry.c`, `pmap_dos.c` in the three
  variants: CC_OK.
* **Unit programs** (`obj/unit.py`, test.cmd's unit section): Checked 63 programs, 0 failed; CheckedNoObs 63, 0
  failed; Release 63, 0 failed.  test_pdos_rdlg 41 checks (every variant); test_input 638 (CheckedNoObs 581); test_dos
  23,274 ("registry: 85 tables valid"; decoded content 1,404 lines); test_pdos_reskin 171 (CheckedNoObs 159),
  test_pdos_adapt 155, test_pdos_pend 104, test_pdos_ui 34, test_pdos_cityview 95; `pdos-p4-report.txt` and
  `present-goldens.txt` equal to the tree's.
* **Checks**: `registry.py check` REGISTRY_OK (501 `ok` lines); OBS_LINT_OK files 146 probes 203 callsites 101;
  OBS_TABLES_OK probes 203 sites 101 (`obj/obstab.py`); PASS pdos_scene_check 1084 checks, 141 scene rows, 10 font
  rows; ADAPT_OK rows 153 steps 27; nodos NODOS_OK (Checked and Release, 0 hits).
* **ext_adapt** (the staged script, every pair, `obj/runadapt.py ... all`, `obj/run/adall.txt`): EXT_ADAPT_OK checks
  312 (the tree's 292 + the 20 D7f lines: five pairs, four checks each).  Every other line equal to the tree's except
  informational counts of the DOS-form runs that pass S3's founding prompt (dialog 137, now D7f's entry): f6b-drag and
  f6b-hover (the founding Return decided by I-text/edit/core-ready, was I-pass/key), f6-zcover-m1/-p1/-menu (views
  51/50/58 -> 72/71/79, ticks 72/71/79 -> 93/92/100), f6s-game, -lux-esc, -msgbox, -options, -rev-esc, -tax-esc,
  -tax-ret (covers opened and released + 1: the entry's cover), ring-dos (the DOS layer drawn in 235 -> 256 shows).
* **ext_p0** Checked: P0_OK checks 476, the whole output equal to the tree's; CheckedNoObs (V5): P0_OK checks 62,
  equal.  **ext_mirror**: MIRROR_OK runs 29, equal (`--ref` the tree's build).  **ext_replay**: REPLAY_OK checks 70,
  equal (the outputs' path aside).
* **ext_frames** (`obj/frames_priv.py`): EXT_FRAMES_OK; equal but s3's presented.log of A 825 -> 846 lines and its
  DOS tick shows 780 -> 801 (the founding entry's blinking cursor).
* **ext_timeline** (base and `--group bs`): EXT_TIMELINE_OK, equal.  **ext_dbl**: EXT_DBL_OK checks 4, equal.
  **ext_fce**: EXT_FCE_OK runs 8, equal (Find City, the production list and the name entry still leave by FCE's
  Escape: WM_CHAR 1Bh at the press, the release's WM_KEYUP).
* **ext_zoom** (`obj/zoompriv.py` against a private copy of the tree's golden): ZOOM_FAILED=10 against the tree's
  golden, exactly the ten DOS `new` combinations' sample at 45,000 ms (the founding prompt, now D7f's "City Name..."
  box on the A canvas); every other combination ok.  `--update --profiles dos` rewrote those ten lines only (628
  samples, ZOOM_OK for the DOS runs); the golden is staged (`tests/harness/ext-zoom-golden.txt`, CRLF kept).
* **The D7f pairs on the base**: the tree's binaries have no `rdlg` diag line and no DOS box for these dialogs, so
  each pair's diag and frame checks fail there (the headless test of the visible change); `test_pdos_rdlg` does not
  build on the base (`pdos_rdlg.h` does not exist there).
* **After the rebase on D7k** (2026-10-18 about 02:05 to 02:25 UTC, the overlay = the tree after D7k's landing + this
  stage; the orchestrator's list: the units, ext_adapt and ext_zoom's `new`): Checked BUILD_OK, portable sources 308
  (the tree's 307 + `pdos_rdlg.c`); the unit programs 64, 0 failed (test_pdos_rdlg 41, test_input 638, test_dos
  23,281 with "registry: 92 tables valid" and decoded content 1,411 lines, test_pdos_leader 119, test_pdos_scene 147,
  test_pdos_reskin 171); REGISTRY_OK 529 `ok` lines, OBS_LINT_OK files 148, OBS_TABLES_OK 203 / 101, pdos_scene_check
  1084, ADAPT_OK rows 153 steps 27; ext_adapt EXT_ADAPT_OK checks 319 (D7k's 299 + the 20 D7f lines; the other lines
  as D7k's but the informational ones listed above); ext_zoom `--only new` against the merged golden (D7k's lines and
  D7f's ten): ZOOM_OK combinations 10, runs 34, samples 140; ext_slots EXT_SLOTS_OK and ext_tld EXT_TLD_OK, each
  output equal to D7k's cycle's (`obj/run/slots.txt`, `obj/run/tld.txt`).  The suites run above on the D7e tree (p0,
  mirror, replay, frames, timeline, dbl, fce) were not repeated: D7k's cycle and this landing's run them.
* Not run privately: ext_aspect, ext_continue, ext_bs, uninit and coverage (no D7f dialog in their flows), ext_g1 (the
  Windows profile is unchanged).

## Deviations from the brief

1. **A new module and test program**: the five dialogs live in `pdos_rdlg.c/.h` (about 2,000 lines) and
   `tests/test_pdos_rdlg.c` rather than in pdos_reskin.c and test_pdos_reskin.c; pdos_reskin.c gains only the help
   flag, the A-place wrapper `pdos_reskin_a_place`, the MenuZ hand-over (`pdos_rdlg_owns`) and the A rectangles.
2. **P19 stands, with the place kept**: the production advisor boxes are not drawn.  ChooseCityProduction itself
   draws none; the core's counterpart is ShowInstantAdvice before some of its calls (ProcessCity 1030:69AD before
   1030:6A43; FoundCity 1040:045E before 1040:0585), boxes D7g re-skins.  The DOS menu's place (80, 8) and font do not
   depend on the advisor boxes, so a ruling to add them changes `prod_build`'s caller only.
3. **No header icon**: the brief names "the header icon" of R:1D05:0475; R:0ADE:0421 never sets DGROUP:2F9E (the
   portrait variant, R:1D05:0613), so the DOS production menu has none and none is drawn.  The selection flash (G#3
   for 20 frames after a choice) is not drawn either (TX not built; the core's dialog closes at once).
4. **P26 refined by the listing**: one choice ends DOS's popup only with one unit; with more, R:0866:21C6..2259 wakes
   the unit and keeps the popup.  The adapter follows the core's form: a row click wakes the core's row, Return (OK)
   ends it; with one unit the click is followed by Return once the core has woken the unit.
5. **Find City as a window over the core's list** (P16): no DOS position exists (DOS shows its typed-name box), so the
   box stands at (64, 8) on N and at the Windows dialog's place on A; rows past the box's height scroll with the bar
   instead of a "more..." row DOS lacks.
6. **The production list's rows keep the core's strings** (decision 15: DOS's row text adds the turns differently;
   an unsure pairing stays the core's).  The production menu's second page with more than 29 entries (a DOS quirk in
   R:0ADE:0931's count) is not reproduced: page 2 shows the core's remaining items and "more...".
7. **The rdlg diag line** in `tests/headless/harness.c` (presentation-diag.log, after the space line).

## What the user checks

On the coordinator's user build (D7f landed; `civ64.exe`, DOS files present), in a game with the DOS graphics
(Ctrl+Shift+Backspace or the host menu).  No box shows a Go Back or Cancel row:

* **D7f-1** On a city screen, 'c' (or the production button): the DOS production menu at the top left of the city
  screen: "What shall we build in <city>?", the items in DOS's small font when there are many, a green "(HELP
  AVAILABLE)" at the box's lower right, the bar on the first item.  Up/Down and an item's first letter move the bar,
  Return or a click chooses, Escape keeps the current production.  With more than 30 items, "more..." switches between
  the units and the buildings.
* **D7f-2** In the production menu, Alt+H (or the right button on an item): that item's Civilopedia entry (still in
  the Windows form until D7h), then the menu again.
* **D7f-3** On a city screen, 'b' (Buy): the DOS box "Cost to complete <item>: $<n> / Treasury: $<m>" with " Yes" and
  " No", the bar on Yes; Return buys, Down and Return declines, Escape declines.
* **D7f-4** Founding a city, and 'r' on a city screen: the DOS "City Name..." box with the white field and the blinking
  cyan cursor; typing, Backspace, Left/Right work; Return accepts; Escape cancels (FCE).
* **D7f-5** On the map, '/' (Find City): a DOS box with "Select city to find:" and your cities, the bar on the first;
  Up/Down, a letter or a click, Return centres the map on the city; Escape cancels.
* **D7f-6** A click on a square with two or more of your units (not a city): the DOS popup with each unit's picture,
  name (with " (V)" for veterans) in white and home city in yellow, no highlight; a click on a unit wakes it (the popup
  stays), any key closes it.  With one unit, a click on it wakes it and closes the popup.  (The user build has
  STACK.SAV, the d7f-stack pair's save: the Legion and the Cavalry on one square up and to the left of Rome.)
* **D7f-7** The same with the Windows graphics: the Windows dialogs, unchanged.

Not part of this check: switching the graphics while one of these boxes shows; the production advisor boxes (P19).

## For the records

* **DESIGN 12.x "As implemented (D7f; areas B and C)":** the module `pdos_rdlg.c/.h` (five dialog kinds by template,
  lazily resolved controls, R elements for the menu boxes and own surfaces for the entry and the stack; N over the city
  screen, A at 2x at the Windows dialog's place); the help line `pdos_menubox_help_line` / `PdosMenuBox.help`
  (`PdosRSpec.help`); `pdos_reskin_a_place`; the scene PDOS_AS_RLIST (0x10000000) and the decision PDOS_DEC_RLIST with
  six I-menu list rows; the acts PDOS_A_LBPICK (`pdos_rdlg_lb_pick`'s `PdosRdStep` steps, made events by pdos_adapt.c:
  I1), PDOS_A_LBHELP, PDOS_A_STACKROW and the predicates PDOS_PR_LB_SEL,
  PDOS_PR_LB_DONE (STACK_WOKEN's state now filled by `pdos_rdlg_pend_state`); the hooks rd_decide, rd_hit, rd_view_row,
  rd_lb_pick, rd_point; the registry tables of "Registry tables"; the menu boxes' header lines by D6fSc's line rule
  (`pdos_r_spec_dos_lines`); the `rdlg` diag line.
* **FIDELITY** (new entries, numbers to be assigned): F-new-1: the production menu's rows keep the core's strings
  (deviation 6); F-new-2: the production advisor boxes are not drawn (P19; deviation 2); F-new-3: no selection flash
  after a choice (deviation 3); F-new-4: Find City is the core's list in a DOS menu box at a port position, not DOS's
  typed-name box (P16; deviation 5); F-new-5: the unit stack popup stays after a row click with more than one unit and
  ends at a key, as the listing does, but through the core's OK (deviation 4); F-new-6: the founding prompt's font 1 is
  inferred; F-new-7: the entry field shows at most 18 cells (DOS: 12, then the field grows as D5d's) .
* **DOS-PROFILE.md prose (proposed):** rows 12, 15, 17, 18, 87 and 89 "as implemented in D7f" (the forms above; row
  89: City > Rename opens the same O23:0000 box, inferred, Open 3 unchanged); SCENES 10.4's text-entry prompt at (88,
  82), not (82, 88) (the listing pushes y 82, then x 88: O23:0049, O23:004D); OPEN P16 and P26 settled as above.
* **RUNNING.md:** presentation-diag.log's `rdlg` line (creates, shows, builds, on_a, empty, keys, presses, choices,
  picks, escapes, refused, pages, wakes); ext_adapt's d7f-prod, d7f-buy, d7f-name, d7f-find and d7f-stack runs (DOS and
  Windows forms); test_pdos_rdlg.
* **FEATURES.md:** the DOS production menu, buy question, city-name box, Find City list and unit stack popup (D7f).
* **STATUS.md:** D7f landed (rows 12, 15, 17, 18, 87; 32, 86, 89 through them); P19 stands; D7g may reuse the help line.
* **manual-checklist-ext.md:** new items D7f-1..D7f-7 (above).
* User direction 2026-10-16 (no added Go Back / Cancel rows) and 2026-10-17 (boxes as tall as their content, no
  highlight where DOS draws none, 2x): none of the five boxes has such a row (dialog 131's Go To City / Cancel, 137's
  OK / Go Back, 140's OK / Cancel / HELP and 141's OK are hidden by the covers; Escape cancels through FCE, Alt+H is
  HELP, any key is the stack's OK); every box at its DOS size; the stack popup without its keyboard bar; on A at 2x.
  Report items: none (no row DOS lacks was added).
* Not edited by this unit: DESIGN.md, FIDELITY.md, STATUS.md, RUNNING.md, FEATURES.md, DOS-PROFILE.md outside the
  generated section 1.7.2, manual-checklist-ext.md, the D1 drafts and the D0 documents.

## Expected changes at the build slot

Against D7k's cycle (`build/d7k-status.txt`, ALL_GREEN 02:03:51 UTC, then RELEASE_OK; `build/d7f-prep/predictions.txt`
has the same list):

* build.cmd checked: BUILD_OK; portable sources checked 307 -> 308 (`pdos_rdlg.c`); the new test program
  `test_pdos_rdlg.exe`; no warning.
* test.cmd checked: TESTS_OK.
  * unit.log: new test_pdos_rdlg 41 checks; test_input 612 -> 638; test_dos 23,274 -> 23,281 ("registry: 85 -> 92
    tables valid"; decoded content 1,404 -> 1,411 lines, the seven tables' goldens); every other program unchanged.
  * registry-check: REGISTRY_OK, `ok` lines 498 -> 529; `tests/dos-decoded.txt` gains the seven `table` lines.
  * obs-lint: OBS_LINT_OK files 146 -> 148 (probes 203, callsites 101 unchanged); obs-tables OBS_TABLES_OK 203 / 101
    and pdos-scene-check 1084 unchanged; adapters-check ADAPT_OK rows 147 -> 153, steps 27.
  * ext-adapt: EXT_ADAPT_OK checks 299 -> 319, with the informational changes listed in "Results".
  * ext-zoom: ZOOM_OK combinations 32 runs 108 samples 628, against the staged golden (ten DOS `new` lines at
    45,000 ms changed); the `not zoomed` count and the `new` shows are informational.
  * ext-frames: EXT_FRAMES_OK; s3's presented.log 825 -> 846 lines and 780 -> 801 tick shows (informational).
  * ext-p0 (both variants), ext-mirror, ext-replay, ext-timeline (both groups), ext-dbl, ext-fce, ext-slots, ext-tld:
    unchanged.
  * nodos NODOS_OK, 0 hits (files scanned + the new sources and this record).
  * presentation-diag.log (harness runs) gains the `rdlg` line after D7e's `cityview` line.
* ext_g1.py check: EXT_G1_OK runs 77 (amended 1), unchanged (the Windows profile's frames do not change).
* build.cmd (Release): BUILD_OK.
* Informational, may change (not predicted to the count): coverage.txt's "other functions entered", OBS_COST, the
  ext-p0 V-runs' own presentation-diag files (the `rdlg` line).

## Rebase notes

* **Staged on the tree after D7l's landing** (session E4, 2026-10-17): the first copies of the files D7f changes are
  kept in `obj/base0` (`pdos_adapt.c/.h`, `pdos_adapt_tab.c`, `pdos_pend.c/.h`, `pdos_profile.c`, `pdos_reskin.c/.h`,
  `pdos_ui.c/.h`, `pmap_dos.c`, `adapters.py`, `registry.py`, `DOS-PROFILE.md`, `OFFSETS.md`).
* **D6fS-b's landing** moved `pdos_adapt.c/.h`, `pdos_adapt_tab.c`, `pdos_reskin.c/.h`, `adapters.py`, `OFFSETS.md` and
  `DOS-PROFILE.md` (the landed files kept in `obj/tree1`).  Merged three ways (`git merge-file -p`, files only; base
  `obj/base0`, theirs `obj/tree1`, mine the stage); conflicts resolved by keeping both sides: `h_box_view` asks D7f's
  RLIST first, then D6fS-b's `RMENU || AMSG || AMENU`; `resolve` keeps D7f's LBPICK, LBHELP and STACKROW cases before
  D6fS-b's DCHOOSE and DEND; the acts in the order DCHOOSE, DEND, LBPICK, LBHELP, STACKROW; `PdosRSpec` has D6fS-b's
  `cmd[]` and D7f's `help`; D6fS-b's removal of the bar-model declarations kept.  `adapters.py` and `OFFSETS.md`: the
  landed copy with D7f's lines applied again; `DOS-PROFILE.md`: the landed copy with 1.7.2 regenerated.
* **D7m's landing** came before `ext_adapt.py`, `tests/headless/harness.c`, `tests/dos-decoded.txt` and the registry
  files were copied (their bases are the tree after D7m; D7f's lines only add to them).
* **HM's landing** (RELEASE_OK 19:26 UTC) moved `tests/test_input.c` (the Locate hint's text and the located-DOS-files
  refusal): merged three ways (base HM's `build/hm-prep/tree-before/tests/test_input.c`, theirs the landed file):
  no conflict (`obj/merge2`).  HM's other files (host_win32.c/.h, present.c, profile.h, test_host_win32.c,
  civ64_main.c) are not staged; the overlay took them (`obj/treecmp.py --copy`) before the final private build.
* **D7l2's landing** (RELEASE_OK 20:45 UTC) moved `pdos_adapt.c`, `pdos_adapt_tab.c`, `pdos_profile.c`, `adapters.py`,
  `OFFSETS.md`, `DOS-PROFILE.md` and the registry's outputs: merged three ways (`obj/merge3`; base `obj/tree1`, for
  `pdos_profile.c` `obj/base0`; theirs the landed files, kept in `obj/tree3`; the registry's outputs regenerated). The
  three C files merged cleanly; `adapters.py`'s and `DOS-PROFILE.md`'s intro sentence and `OFFSETS.md`'s rows had D7l2's
  and D7f's lines at the same place: both kept, D7l2's first (`obj/resolve3.py`: "...or the palace window; extension
  D7f: ...").  D7l2's other files (pdos_scn_arrive, pdos_scn_space, their tests, the docs) are not staged; the overlay
  took them.
* **D6fSc's landing** (copied in 21:46:57 UTC, `build/d6fsc-prep/landed-at.txt`) moved `pdos_reskin.c/.h`,
  `OFFSETS.md`, `ext_adapt.py` and the registry's outputs: merged three ways (`obj/merge4`; base the tree after D7l2,
  theirs D6fSc's staged files, each checked equal to the landed file).  `pdos_reskin.c/.h` merged cleanly (D6fSc's
  `pdos_r_dos_wrap`, `pdos_r_spec_dos_lines` and pairing beside D7f's help flag, A place and A rectangles);
  `OFFSETS.md`'s rows and `ext_adapt.py`'s docstring: both kept, D6fSc's first (`obj/resolve4.py`).  D7f then takes
  the new line rule for its header lines (`hdr_raw`, `find_build`).  test_pdos_reskin.c and ext-zoom-golden.txt are
  not staged (the overlay took D6fSc's).  The post-D7l2 stage is kept in `obj/stage-d7l2`.
* **D7e's landing** (copied in 22:59:02 UTC, `build/d7e-prep/landed-at.txt`) moved `DOS-PROFILE.md`, `OFFSETS.md`,
  `registry.py`, `pdos_adapt.c`, `pdos_profile.c`, `ext_adapt.py`, `tests/headless/harness.c` and the registry's
  outputs: merged three ways (`obj/merge5`; base `build/d7e-prep/tree-before`, each equal to this stage's recorded
  base; theirs D7e's staged files, each equal to its `landed.sha256` hash, kept in `obj/tree5`).  `DOS-PROFILE.md`,
  `pdos_adapt.c` and `ext_adapt.py` merged cleanly (D7e's I-wait scene for the city view stands after D7f's
  `rlist_scene`, which is asked first on N and A as before); `OFFSETS.md`'s rows, `registry.py`'s OBSERVER_FILES, the
  three `pdos_profile.c` hooks (reset, probe, advance) and `harness.c`'s include and diag line: both kept, D7e's first
  (`obj/resolve5.py`).  D7e's other files (`pdos_scn_cityview.c/.h`, `pdos_replay.c`, `pdos_seq.c`, `pdos_shadow.h`
  (PDOS_OWNER_MAX 10), `test_pdos_cityview.c`, the zoom golden) are not staged; the overlay took them.  The
  post-D6fSc stage is kept in `obj/stage-d6fsc`.
* **The docs pass e4g** (`build/docs-e4g-done.txt`) changed `DOS-PROFILE.md` (D6fSc's "as implemented" prose): merged
  three ways (`obj/merge6`; base D7e's landed file `obj/tree5`), no conflict; 1.7.2 regenerated equal.  Its other
  files (DESIGN, FEATURES, FIDELITY, RUNNING, STATUS, dos/FORMATS, dos/OPEN, the checklist, D7e's record) are not
  staged.
* **The zoom golden** `tests/harness/ext-zoom-golden.txt` is staged: D7e's landed file (its base then) with the ten DOS
  `new` lines at 45,000 ms rewritten by `ext_zoom.py --update --profiles dos` on the overlay (`obj/zoompriv.py`).
* **D7k's landing** (copied in 01:25:44 UTC, `build/d7k-prep/landed-at.txt`) moved `DOS-PROFILE.md`, `OFFSETS.md`,
  `registry.py`, `pdos_profile.c`, `pdos_reskin.c/.h`, the zoom golden, `ext_adapt.py`, `tests/headless/harness.c` and
  the registry's outputs: merged three ways (`obj/merge7`; base `build/d7k-prep/tree-before`, each equal to this
  stage's recorded base; theirs D7k's staged files, each equal to its `landed.sha256` hash, kept in `obj/tree7`).
  `DOS-PROFILE.md`, `pdos_profile.c`, `harness.c` and the zoom golden merged cleanly (D7k's golden lines and D7f's
  ten are different lines).  Conflicts, both sides kept, D7k's first (`obj/resolve7.py`): `OFFSETS.md`'s rows,
  `registry.py`'s OBSERVER_FILES, `ext_adapt.py`'s docstring and runs, `PdosRSpec`'s fields (D7k's `h8`, `at_place`
  and D7f's `help`) and their copies into the layout; the MenuZ binding of `pdos_reskin_menu` takes both conditions:
  `(bound_to_r(..) || leader_box(..)) && !pdos_rdlg_owns(..)` (D7k's leader message, D7f's buy question hand-over).
  D7k's other files (`pdos_scn_leader.c/.h`, `pdos_fontmap.c/.h`, `pdos_prov.c/.h`, `pdos_replay.c/.h`,
  `pdos_scene_tab.c`, `pdos_scn_palace.c`, `pdos_seq.c`, `test_pdos_scene.c`, `test_pdos_leader.c`) are not staged;
  the overlay took them.  The post-D7e stage is kept in `obj/stage-d7e`.
* The generated files (`pdos_registry.c/.h`, `tests/dos-decoded.txt`, `DOS-PROFILE.md` 1.7.2) were regenerated on the
  overlay after the last merge (`registry.py gen` / `goldens`, `adapters.py gen`).
* At the build slot: `obj/mkbase.py check` against the live tree; a moved base is merged three ways again (base: the
  recorded file, from the landing's `tree-before`), the generated files regenerated.

## Landing

D7f landed alone at the build slot of session E4, 2026-10-18, after D7k (the orchestrator accepted D7f as READY with
PDOS_AS_RLIST = 0x10000000 confirmed and, after D7k's RELEASE_OK and user build, "land straight away"; no word that
D6fSd goes first; no landing active, `obj/landing.py` IDLE; D6fSd's prep folder without a copy-in).  The user checks
D7f-1..D7f-7 are in the user build `d7f`.

* **Rebase on D7k** (section "Rebase notes", `obj/merge7`, `obj/resolve7.py`): the units, ext_adapt (all pairs) and
  ext_zoom's `new` on the overlay as the orchestrator listed, plus ext_slots and ext_tld (equal to D7k's cycle; section
  "Results"); `BASE-SHA256.txt` written again (BASES_OK, 02:26 UTC).
* **Bases:** `build/d7f-prep/land.py` (from D7k's) rechecked every base (DRY_RUN_OK 26; build.cmd and test.cmd
  unchanged), took the snapshot `build/d7f-prep/before` (the tree's `build/test/Checked` outputs of D7k's cycle, 66
  files) and `tree-before` (the 22 replaced files), and copied in at 02:30:03 UTC (`landed.sha256`: the 22 changed and 4
  new files with this record, rechecked equal afterwards; `landed-at.txt` "unit d7f"; `land-write.log`).  Predictions
  `build/d7f-prep/predictions.txt`, written before the copy-in.
* **The three-step cycle** (`build/d7f-prep/d7f-cycle.ps1`, status `build/d7f-status.txt`, each step guarded by its
  log's OK marker; a first start at 02:30:20 from Git Bash ran nothing, `powershell.exe` not on its PATH, no status
  line and no log; started again through Windows PowerShell): 1 `build.cmd checked` BUILD_OK 02:30:31..02:35:42 (311 s;
  portable sources checked 308; `test_pdos_rdlg.exe` built; no warning); 2 `test.cmd checked` TESTS_OK
  02:35:42..03:10:38 (2096 s; wall 2093.7 s: ext_zoom 2056.8, ext_adapt 2012.5, d2_nodos 1623.9, ext_p0 1532.6 s; no
  flake rerun); 3 `ext_g1.py check` EXT_G1_OK runs 77 (amended 1) unchanged: **ALL_GREEN** 03:10:38.  4 `build.cmd`
  (Release) BUILD_OK 03:10:53..03:15:33 (280 s, no warning): **RELEASE_OK**.
* **Against the predictions** (`build/d7f-prep/compare.py` against the snapshot, `build/d7f-prep/compare.txt`: 51 of
  66 files equal, host times left out): as predicted, unit.log test_pdos_rdlg new (PASS 41), test_input 612 -> 638,
  test_dos 23274 -> 23281 (decoded content 1404 -> 1411 lines, registry 85 -> 92 tables), every other count equal;
  REGISTRY_OK with `ok` lines 498 -> 529 (the seven tables' 29 lines and the include rule's 2) and the seven decoded
  `table` lines; OBS_LINT_OK files 146 -> 148 (probes 203, callsites 101); ADAPT_OK rows 147 -> 153 steps 27;
  OBS_TABLES_OK and pdos-scene-check (1084) unchanged; NODOS_OK 0 hits (files 1819 -> 1824); EXT_ADAPT_OK checks 299
  -> 319, the whole output equal to the private run on D7k's tree (`obj/run/adall.txt`): the 20 d7f lines, ring-dos
  235 -> 256 shows, f6-zcover-m1/-p1/-menu (views and ticks + 21, m1 51 -> 72 views, 72 -> 93 ticks) and
  f6b-drag/-hover (the founding Return I-text/edit/core-ready) as predicted; the f6s-* lines, predicted as
  informational from the run on D7e's tree, are equal to D7k's cycle; ZOOM_OK
  combinations 32 runs 108 samples 628 map comparisons 32 centre runs 4 mzi runs 12 mzs runs 4 not zoomed 38/448
  against the landed golden, informational: the ten `new` lines' shows dos 268 -> 289 (sw 251/250 -> 259/258);
  EXT_FRAMES_OK with s3's presented.log 825 -> 846 lines and 780 -> 801 tick shows; P0_OK checks 476, REPLAY_OK checks
  70, MIRROR_OK runs 29, EXT_TIMELINE_OK, EXT_SLOTS_OK, EXT_TLD_OK, EXT_FCE_OK runs 8, EXT_DBL_OK checks 4 and the
  other sections unchanged.  Also informational: coverage.txt "other functions entered" 664 -> 670; unit.log's
  OBS_COST line (host timing).
* **User build** `build/user-builds/d7f/` (03:15 UTC; `build/d7f-prep/mk_userbuild.py`): `civ64.exe` (the Release
  build, SHA-256 8167e8ef...), `CIVWIN.zip` and `civdos.zip` from `build/user-builds/d4/`, `STACK.SAV`
  (`build/d7f-prep/STACK.SAV`: CAE3540B.SAV with aliveCivsMask 3, D7j's edit; the Legion and the Cavalry on one square
  up and to the left of Rome, for D7f-6), `WHAT-TO-CHECK.txt` (D7f-1..D7f-7; the earlier builds up to "d7k"; the 129
  items still pending in the checklist at 03:11 UTC, `build/d7f-prep/fill_stillopen.py`, written by `mk_fill.py` from
  D7k's with the group "d7k").
* **Host load:** other units' private work (d6fsd-stage) during the cycle; no flake, no rerun.

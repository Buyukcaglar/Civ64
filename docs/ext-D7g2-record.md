# Extension phase D7, unit D7g2 (the rest of D7g's rows: the notes, the government menu, the event boxes, the sale question; the DOS boxes centred on the A canvas) - record

Draft for the build slot (BRIEF-d7.md "Units" D7g, the rows D7g's record lists as not built; the orchestrator's
directions of 2026-10-18 07:46, 07:55, 08:00 and 08:25; the user's direction of about 10:57 UTC with the orchestrator's
messages of 10:58 and 11:10; extension session E4, track B).  Staged in `build/d7g2-stage/` on the tree after D7g's
landing (RELEASE_OK 07:41:46 UTC), then rebased onto D7h's landing (copy-in 09:15:07 UTC), D7i's (copy-in 10:25:44
UTC, RELEASE_OK 11:04:25 UTC) and D7h2's (copy-in 11:53:43 UTC, RELEASE_OK 12:40:13 UTC) (section "Rebase notes").  The
stage applies to the tree after D7h2's landing.  Private
builds and runs in `build/d7g2-stage/obj/` only: an overlay `obj/src` = the tree + D7g2's stage (`obj/mkoverlay.py`),
built with the tree's build.cmd and flags (`obj/b.cmd`, `--nogen`; `obj/gen.sh` regenerates the registry's files in
it), cc.cmd's stricter checks per file (`obj/cc.cmd`), the unit programs (`obj/unit.py`), the static checks
(`obj/checks.sh`), the private suites (`obj/suite.sh`) and the harness runs from the overlay's binaries with every
output under `obj/` (`obj/runadapt.py`, `obj/runp0.py`, `obj/runh.py`, `obj/explore.py`, `obj/xs3.py`); the tree's
build/gamedata, dosdata, dos/disasm and cache read only.

## Result

D7g2 is staged and READY_TO_BUILD.  The brief's rows of D7g that D7g did not build, as the orchestrator listed them on
2026-10-18 07:46, with the DOS graphics, and the user's direction of 10:57 on where the DOS boxes stand:

* **Every DOS box on the A canvas centred where the Windows game shows its window** (the user's direction of about
  10:57 UTC, folded into D7g2 by the orchestrator at 10:58; the reading approved at 11:10).  The user, verbatim: "I
  understand that you are trying to put DOS popup/windows and dialog boxes such as but limited to, Tax Rate, Luxuries
  Rate,  Revolution, Retires, Quit to DOS, Advances selection dialog box etc. to their relevant DOS locations but, they
  shall approximately be placed by the location of their Windows counterparts. Which is generally (what I infer from
  the visual inspection) is the center (both horizontally and vertically) of the whole canvas -not just the play map
  area-."  The rule: a DOS box's centre at its Windows window's centre, then 11.3's clamp inside the canvas; its size,
  text, header and colours unchanged.  It covers D6f's and D6fSa..D6fSd's boxes (the MenuZ boxes of dialogs 136 and
  145, the `#MsgBox` boxes), D7f's own boxes on A (Find City, the unit stack popup), D7g's header boxes (the header
  frame inside the centred element: D7g's (-42, -8) offset is moot) and D7g2's notes.  The core's dialogs open centred
  on the canvas, so most boxes now stand at the canvas's centre; the notes' dialog 135 opens centred across the canvas
  near its top (its centre (320, 80)), and the note stands there.  One exception (deviation 5): the science advisor's
  recommendation, which in DOS's flow stays on the screen with the research choice, keeps D6fSd's DOS place at the
  lower left (centred too it lay under the centred research choice, hidden).  Out of scope: the N canvases (the city
  screen, the throne room, the palace, the reports) keep DOS's places (the orchestrator's reading); the menu bar's
  drop-downs stay under the bar.
* **Row 13, 117, 118: the notes** (dialog 135's one-line note in the forms of its three callers; SCENES-PLAY 7.18;
  DOS listing O4:02D3..039B, O4:03AA..046F).  ShowInstantAdvice's note (row 117) is drawn as DOS's O4:02D3 box and
  ShowErrorNote's (row 118) as O4:03AA's: the box (56, 16, 208, 6n + 10) inclusive, n the DOS section's records,
  filled with colour 2 (instant advice) or 4 (error) and outlined with 10 or 12, the title "--- Civilization
  Note ---" (`NOTE_TITLE`, DGROUP:34E7) centred at (160, 19) in colour 0 in font 2, the text of the DOS section that the
  core's note names (the core loads the same name from its own file: R:1F4D:01AD's records with R:1F4D:0471's tokens
  filled with the core's values) wrapped as R:1F4D:0088 wraps it (32 columns from x 64, y 25, colour 15, font 2), on
  the A canvas centred on dialog 135's Windows window.  ShowHelpNote's form (row 116, the help screen over Customize)
  stays D5e's.  A note's input is DOS's (R:1459:0918: any key or button): Return passes as typed, any other key or a
  left press becomes Return, pressed and released at its instant (I-wait/note-*, the new scene bit `PDOS_AS_NOTE`,
  bit 34, ruled 08:25).
* **Row 115: the government menu** (SetGovernment's menu, R:1517:04A1 via R:0238:001E(100, 64)): checked; the core's
  menu (dialog 136, no header) is a generic DOS box (now centred on its Windows window); a click on a DOS row gives the
  core's item and Return (I-menu/press, I-menu/release), as a Windows player's click: ext_adapt's d7g2-gov pair.
* **Row 41: Revolution's boxes**: checked; the core asks its revolution question through ShowTextDialog (11F0:3B85,
  DOS's (64, 80): D6fSc's REV text from KING.TXT), then the newspaper; no `#MsgBox` on this path.
* **Rows 126, 127, 128 and 137: the O20, O15 and O22 boxes and the population message**: checked against the DOS
  listing (places and headers): row 126 (ProcessCityDisaster): the own city's box at (100, 80) with header 4, a seen
  foreign city's at (100, 64) with header 2; row 127 (StartCivilWar): (80, 80) with header 5; row 128 (O22 against
  11B8): (80, 80), (100, 80), (80, 40) and (100, 32); row 137 (the population message, 1088:19FB): (100, 80) with
  header 4.  The core passes DOS's x, y to ShowTextDialog and its `g_messagePicture` is DOS's header in each, so D7g's
  header variant draws them as DOS does and the centring places them; KING.TXT's sections (D1..D6, SCHISM, ESCHISM)
  take D6fSd's section pairing.  Row 126's map recentre is a recorded deviation (deviation 3).
* **The city screen's sale question** (the orchestrator's item of 08:00; a box over row 97's screen; DOS listing
  R:0D12:57A5..5834): DOS's text, "Do you want to sell" / "your <building> for <price>$?" with the rows "No." and
  "Yes." (`SALE_TEXTS`, DGROUP:26AD..26DC, with the core's name and price), font 1, at DOS's (128, 80) on the N
  canvas.  The core's box asked the same question on one line ("... for" / "200$?" by the line rule), with "No" and
  "Yes", at MenuZ's own place.
* **Generic boxes on N at DOS's place** (ruled 08:25): a MenuZ box of a ShowTextDialog call that carries DOS's x, y,
  on the N canvas and without a renderer's anchor, now stands at that x, y (before: MenuZ's own arguments).  Section
  "Moved boxes" lists the N screens and boxes this moves.
* **The A canvas's element ids** (the orchestrator's message on D7i's finding): `PDOS_R_HELD_ID` (D7g) moves from
  0xFF30, which D7n's `PDOS_APLAY_NUKE_ID` also had, to 0xFF50; test_pdos_reskin checks that every private element id
  on that canvas is distinct.

## Status

READY_TO_BUILD (section "Results").  Built: the centring (`PdosRPlace.centre`, `cx`, `cy`, `pdos_r_place_xy`, used by
`elem_put_a` and `pdos_rdlg.c`'s `own_put`; `a_place_of` sets the window's centre; `DOS_KEEP` for the recommendation;
`pdos_reskin_a_place_dos` of the first draft removed); the notes in `pdos_rdlg` (`PDOS_RL_NOTE`; `pdos_rd_note_form`,
`pdos_rd_note_colours`, `pdos_rd_note_h`, `pdos_rd_note_lines`, `pdos_rd_note_draw`; the note's text from
`pdos_r_section_text`); the adapter scene `PDOS_AS_NOTE` (bit 34) and its five rows I-wait/note-mod, note-return,
note-key, note-press, note-other; the sale question's pairing in `pdos_reskin` (`PDOS_R_PAIR_SALE`,
`pdos_r_sale_text`, the ShowTextDialog return address 1030:6291); the N place rule in `menu_build`; `PDOS_R_HELD_ID`
0xFF50; two registry tables (`NOTE_TITLE`, `SALE_TEXTS`); presentation-diag's `rdlg` pairs notes, note_paired,
note_ax, note_ay, note_w, note_h, note_cx, note_cy and `preskin2`'s nbox_id, nbox_x, nbox_y, nbox_dos, nbox_anchor,
nbox_n, held_ax, held_ay, held_w, held_h; ext_adapt's d7g2 pairs, d6fsd_place's centring check and D7g's runs' place
check; D7o's `--g1` hunk of `ext_p0.py` copied unchanged (the decision-12 runs for rows 115 and 126..128); the zoom
golden's 40 DOS `new` lines at 40,000..55,000 ms rewritten (the note at a new game's start, now DOS's, and the
founding's City Name box, both centred now).

Not built: none of the listed rows.  Row 137 is the brief's "a check of D6's placement only": checked, no change
beyond the centring.

## What was built

### The centring on the A canvas (the user's direction of 10:57)

* **The rule** (`pdos_r_place_xy`, `pdos_reskin.h`): an element w2 x h2 (A pixels, 2x the DOS box) at
  (cx - w2 / 2, cy - h2 / 2), (cx, cy) its Windows window's centre (`a_place_of`: the window rectangle's middle on the
  canvas), then 11.3's clamp: moved left or up to fit, then to 0.  `elem_put_a` (every re-skinned box and message box)
  and `own_put` (pdos_rdlg's own elements on A: the notes, Find City, the stack popup, the city-name box when on A)
  place through it.  The window rectangle and the canvas are the ones B16 and D6fSd used; only the point changes.
* **What it replaces** on A: D6fSd's DOS place (the DOS map view's origin at the map window's client origin, 2x;
  `pdos_r_dos_place`, F289) and B16's anchor at the window's top-left (F202) for every box; D7g's header offset
  (F299: the header frame 42 left of and 8 above the caller's place) is moot, the whole element with its header frame
  is centred.  DOS's place stays in the diagnostics (`preskin2`'s abox_dos, abox_dx, abox_dy, abox_mcx, abox_mcy).
* **Measured** (the private runs; the canvas 640 x 480): the quit and Retire questions 212 x 82 at (214, 198) on the
  window 203,182..437,297; the revolution question 454 x 66 at (93, 206) on 184,182..456,297; the tax box 282 x 210 at
  (179, 134) on 203,101..437,378; the luxuries box 338 x 130 at (150, 174) on 192,146..447,333; the government menu
  316 x 50 at (162, 214) on 203,191..437,288; the research choice 408 x 198 at (115, 140) on 142,120..497,359; the
  error note 418 x 46 at (111, 57) on its window's centre (320, 80).  Each window's centre is (319..320, 239..240)
  but the note's.
* **The recommendation** (deviation 5): its box keeps D6fSd's DOS place (`DOS_KEEP`, set in `menu_build` for
  `PDOS_R_PAIR_ADVICE`): A (27, 344), 274 x 78, at the lower left beside the centred research choice, as DOS shows the
  two together (D7g-5, D7g-6).  Centred, it lay wholly under the research choice (seen in the private D7g route's
  frame before the exception).
* **Not changed**: the N canvases (DOS's places; the N place rule below), the drop-downs under the bar, the elements
  of the other renderers (the zoom layer, the palace, the leader screen, the nuclear explosion), the Windows graphics.

### The notes (rows 13, 117, 118)

* **The form.**  ShowTextNoteDialog (10E0:03A2) has three callers: ShowHelpNote (return address 10E0:0048),
  ShowInstantAdvice (10E0:07E1) and ShowErrorNote (10E0:0842).  DOS's counterparts are O4:0000 (the help screen, row
  116, D5e's), O4:02D3 (instant advice: only with option bit 0 and a year before 0, [19C0] & 1 and [B220] < 0, as the
  core's caller) and O4:03AA (an error, [6B90] == [D7EE]).  The renderer takes the form from ShowTextNoteDialog's
  entry probe (its return address) and keeps it for the next dialog 135; ShowHelpNote's form and any note while
  Customize World runs stay D5e's (`pdos_rd_note_form`).
* **The box.**  O4:02D3 and O4:03AA read the section's records (R:1F4D:01AD, n), fill the tokens (R:1F4D:0471), hide
  the pointer and save the screen, then R:0000:0BFA(port, 56, 16, 208, 6n + 10, colour 2 or 4) and R:1D05:0A05(56, 16,
  208, 6n + 10, 10 or 12) (inclusive), the port's font 2 (O4:0359), the title DGROUP:34E7 (the error note's copy at
  350B, the same text) by R:0182:00B3 centred at (160, 19) in colour 0, the text by R:1F4D:0088(32 columns, x 64,
  y 25, colour 15), font 1 again, R:1459:0918's wait (O4:0396, O4:0465), the screen restored (O4:039B, O4:046A).
  `pdos_rd_note_draw` draws the same on an own element (209 x 6n + 11 DOS pixels) centred on dialog 135's Windows
  window (the harness's: A (111, 57), 418 x 46 for a one-record note).
* **The text.**  The core loads its note by name (LoadTextResource 11D0:00E4 from 10E0:03E1: the prefix and the
  name), fills its tokens (SubstituteTextTokens) and gives TextBoxSetup (10E0:0497) `g_messageText` (12D8:24FA).  The
  renderer loads the DOS section of the same name from the DOS file of that prefix (D6fSd's `pdos_r_src_load`), fills
  its tokens with the core's values (read at TextBoxSetup's entry) and wraps it as R:1F4D:0088 does
  (`pdos_rd_note_lines`: n, the box's height); without a DOS section it draws the core's text folded (counted
  `notes` without `note_paired`).  Exit probes are not given to `pdos_rdlg`, so the text is read at TextBoxSetup's
  entry, after SubstituteTextTokens.
* **The input** (C.12.7 I-wait; the ruling of 08:25): `PDOS_AS_NOTE`, bit 34 of D7h's 64-bit scene, while the note's
  element is on top of its canvas (`pdos_rdlg_top`).  I-wait/note-mod: a modifier alone consumed (no key for kbhit,
  R:2045:2098); I-wait/note-return: Return passed as typed with its release (the core's dialog 135 closes on its
  WM_CHAR 0Dh); I-wait/note-key: any other key becomes Return, pressed and released at its instant, its release
  consumed; I-wait/note-press: a left press the same, its release consumed; I-wait/note-other: the right button and a
  character consumed (as D5e's help screen).  Return passes as typed so that the existing S3 runs, whose Return at
  48,000 ms closes the instant advice note that opens at 45,001,550 us, keep their core inputs.

### The sale question (row 97's screen; R:0D12:57A5..5834)

DOS builds "Do you want to sell\nyour " (DGROUP:26AD) + the building's name (its record's name, DGROUP:0BB8 + 30i) +
" for " (26C7) + 10 times its cost (itoa, R:2045:1F6A) + "$?\n No.\n Yes.\n" (26CD), sets the port's font 1 and asks
R:1D05:0018(text, 128, 80) with no header; row 1 (Yes) sells.  The core (1030:61F1..628C) builds "Do you want to sell
your " (DSTR 0520h) + the name + " for " (053Ah) + 10 times the cost + DSTR 0540h with the items No and Yes, font 1, and
calls ShowTextDialog(text, 80h, 50h); its return 1 sells.  The renderer pairs the box of that call (its return address
1030:6291, `PDOS_R_SALE_RA`; no call-site row) with DOS's text from `SALE_TEXTS` and the core's name and price
(`pdos_r_sale_text`; DOS's row k is the core's row k).  The orchestrator's question of 08:00 (place, header, text
pairing, the answers menu): the place (128, 80) and the absent header were equal, the text pairing and the rows were
not (the core's one line and "No"/"Yes"; DOS's two lines and "No."/"Yes."): built here.  Its input is the generic
menu box's (I-menu), unchanged.  The city screen is an N screen: the box stays at DOS's (128, 80).

### The N place rule (`menu_build`)

A generic MenuZ box is laid out at MenuZ's own x, y unless a renderer anchors it (the palace) or it is on the A
canvas.  D7g2: on the N canvas, a box of a ShowTextDialog call with DOS's x, y (D6fSd's `m->dos`) and no anchor stands
at that x, y.  The orchestrator approved it at 08:25 with the list of the boxes it moves (section "Moved boxes").

### The A canvas's element ids

`PDOS_R_HELD_ID` (the held recommendation, D7g) and `PDOS_APLAY_NUKE_ID` (the nuclear explosion, D7n) were both 0xFF30
(found by D7i).  `PDOS_R_HELD_ID` is 0xFF50 now (the orchestrator's message of 11:10: D7h2 takes 0xFF58 and 0xFF59).
test_pdos_reskin's `test_a_ids` lists the private ids (the bar 0xFF01, the drop-downs 0xFF10 + level, the cover
0xFF20, the nuclear explosion 0xFF30, D7i's newspaper 0xFF40..0xFF42, the held recommendation 0xFF50, D7h2's page
covers 0xFF58 (the city layer) and 0xFF59 (the A canvas)) and checks that the 17 are distinct and from FF00h; a later
unit with a private id extends the list.

### Evidence labels

* DOS listing: O4:02D3..039B and O4:03AA..046F (the notes' boxes, colours, title, text, wait); R:0D12:57A5..5839 (the
  sale question); R:1517:04A1 (the government menu's (100, 64)); O20:0540, O15:0000, O22:0000/0639/0AF5 and the
  population message's places and headers (the research of 2026-10-18).
* DOS file: `NOTE_TITLE` (DGROUP:34E7) and `SALE_TEXTS` (DGROUP:26AD, three strings), hash-pinned in OFFSETS.md and read
  through the store; the notes' texts from the DOS files by section name (D6fSd's store).
* core: ShowTextNoteDialog's callers and order (10E0:0000..0842), its close on WM_CHAR 0Dh or OK (10E0:068E..06B7);
  the sale question 1030:61F1..62A0; CenterMapViewOn 1110:03AE from 1040:1112.
* observed (private harness runs): the Windows windows' rectangles on the canvas (section "The centring"), the boxes'
  A places, the frame of the research choice with the recommendation.
* accepted design change: the centring (the user's direction of 10:57); the recommendation's exception (deviation 5,
  this unit's reading, approved by the orchestrator; the user rules by D7g2-9).
* inferred: the note's DOS section is the one of the name the core loads (the same names in both games' files, the
  callers compared); the building's name is the core's (the same words as DOS's for the buildings, as D7f's buy
  question).
* unknown: whether the core's recentre for row 126 puts the map at DOS's origin (x - 10, y - 6) (deviation 3).

## Moved boxes

The N place rule (a generic MenuZ box on the N canvas with its call's DOS x, y and no renderer's anchor) moved one box
in the private suites (presentation-diag's `preskin2` nbox_n of every run; section "Results"): the city screen's sale
question (dialog 136 from ProcessCity's ShowTextDialog 1030:628C, DOS's (128, 80); before: MenuZ's own place),
ext_adapt's d7g2-sale-dos and its Windows form (the renderer builds the N box behind the Windows graphics too).  No
other run built a generic N box with a DOS place: the city screen's other boxes are pdos_rdlg's (D7f: the production
menu, the buy question, the city name) or anchored (D7j's palace box, D7k's leader box), and the other N screens open
no generic MenuZ box in the suites.  D7g2-5 checks the sale question; D7g2-6 asks for any other such box met in play.

## Files

Changed (bases: section "Rebase notes"): `present/dos/pdos_rdlg.c/.h`, `present/dos/pdos_reskin.c/.h`,
`present/dos/pdos_adapt.c/.h`, `present/dos/pdos_adapt_tab.c`, `present/dos/pdos_registry.c/.h` (generated),
`gen/dos/adapters.py`, `docs/dos/OFFSETS.md`, `docs/DOS-PROFILE.md` (rows 13, 41, 97, 115, 117, 118, 126..128, 137;
1.7.2 generated), `tests/dos-decoded.txt` (generated), `tests/test_pdos_rdlg.c`, `tests/test_pdos_reskin.c`,
`tests/test_input.c`, `tests/harness/ext_adapt.py`, `tests/harness/ext_p0.py` (D7o's `--g1` hunk, unchanged),
`tests/harness/ext-zoom-golden.txt` (the 40 DOS `new` lines at 40,000..55,000 ms; CRLF kept).  New: this record.  No new
source or test program, no observer call-site row.

## Tests

* **test_pdos_rdlg** (+ the notes and the sale text): `test_note_form` (the three return addresses, Customize's
  exclusion), `test_note_draw` (the box, outline, title and wrapped text of a two-record note against DOS's
  rectangles and colours), `test_sale` (DOS's three strings with the core's name and price: two lines, rows "No." and
  "Yes."; a core text without " for " or digits refused).
* **test_pdos_reskin**: `test_a_ids` (the 17 private element ids on A and D7h2's city-layer cover: distinct, from
  FF00h; fails on the base: 0xFF30 twice).
* **Existing ext_adapt checks changed by D7g2** (each with an "extension D7g2" comment): d7e-found, d7e-view and
  d7e-city expect I-wait/note-return first (S3's Return at 48 s closes the instant advice note, now a DOS note); the
  d7f cases' `rdlg` counts creates and shows are compared less `notes` (S3's notes are pdos_rdlg dialogs now); the
  D6fS-a cover check at zoom +1 (f6-zcover-p1) accepts a hidden dialog's part around the centred box where the A frame
  and the zoomed layer show the same pixels (both the map's black there: beside_layer 0, every such pixel as the
  views'), its claim that no Windows pixel shows unchanged.
* **test_input** (+ 5 rows, the table's count 166): the five I-wait/note-* rows: Return passed with its release; Shift
  consumed; X posted as Return with its release, its repeat, character and release consumed; a left press posted as
  Return; a right press consumed.
* **ext_adapt**: the d7g2 pairs (each DOS run against its Windows form, the core outputs equal): d7g2-note-ret,
  -key, -press (the rows, rdlg's notes and note_paired, the posted Return, the note's A element centred on its
  Windows window); d7g2-gov-cal (the government menu centred on its window, d6fsd_place) and d7g2-gov-dos / -win (a
  click on its DOS row); d7g2-sale-dos / -win (pairing 18, the box at N (128, 80), DOS place 1, anchor 0).
  `d6fsd_place` rewritten to the centring: the A box at (clamp(wcx - w / 2), clamp(wcy - h / 2)) of its Windows window
  (abox_win_l..b) for f6c-quit-cal, f6c-retire-cal, f6c-rev-cal, f6c-tax-cal, f6c-lux-cal and d7g2-gov-cal (fails on
  the base: D6fSd's places); D7g's d7g-dos, -flip, -switch and -esc: the research choice centred on its window and the
  held recommendation beside it, both whole on the canvas (fails on the base: no held_* pairs, the research choice at
  (87, 136)).
* **ext_p0** (D7o's `--g1` hunk, unchanged: `G1_RUNS`, `G1_VARS`, `WITH_G1`, `G1_SOAKS`, `g1_save`, `g1_c2_layout`,
  `g1_runs`, the `--g1` option and decision 12's report; its docstring's decision-12 sentences): the decision-12 runs
  for rows 115 and 126..128 with `--g1`.  D7o's other ext_p0 hunks (the D7 gate rows, `scene_counts`, decision 16)
  are D7o's and not staged: copied whole at first, they failed the private p0 run (17 gate counters of rows D7o
  addresses), so the stage keeps the `--g1` hunk only, as ruled at 08:25.
* **ext_zoom**: the golden's 40 DOS `new` lines, the ten combinations' samples at 40,000, 45,000, 50,000 and 55,000
  ms (the instant advice note at a new game's start, now DOS's note centred on its window, at 40 s; the founding's
  "City Name..." box, D7f's element on A, now centred on its window, at 45..55 s, as D7f's record names that
  sample), rewritten by `ext_zoom.py --update --profiles dos` on the overlay; every other sample equal (fails on the
  base: the tree's golden).

## Results (private, `build/d7g2-stage/obj/`)

On the overlay `obj/src` = the tree after D7h2's landing (copied 12:40:23 UTC, after its RELEASE_OK) + the stage:

* **Builds** (`obj/gen-run3.log`): the registry's files regenerated (159 files, 104 tables), Checked, CheckedNoObs and
  Release BUILD_OK (12:40..12:51 UTC); cc.cmd's strict checks (c11, c17 /W4 /WX, the clang C99 parse) CC_OK in the
  three variants on `pdos_rdlg.c`, `pdos_reskin.c`, `pdos_adapt.c`, `pdos_adapt_tab.c`, `pdos_registry.c`,
  `test_pdos_rdlg.c`, `test_pdos_reskin.c`, `test_input.c`.
* **Unit programs** (`obj/unit.py`, the three variants): 66 programs, all PASS but test_dos, which reads the tree's
  goldens: its one failure is `tests/dos-decoded.txt` (the tree's 1,426 lines against 1,428), whose content equals the
  staged goldens (the comment lines aside).  test_input 689 checks, test_pdos_rdlg 75, test_pdos_reskin 229, test_dos
  23,293.
* **Static checks** (`obj/checks.sh nodos`): REGISTRY_OK (600 ok lines), OBS_LINT_OK files 152 probes 203 call sites
  103, pdos_scene_check PASS 1084 (141 scene rows), ADAPT_OK rows 166 steps 27, OBS_TABLES_OK 203 / 103, NODOS_OK.
* **Suites** (`obj/suite.sh s2`, 12:57..13:44 UTC, `obj/r-s2/`; then `obj/suite3.sh`, `obj/r-s3/`, after the harness
  fixes of section "Rebase notes"): EXT_ADAPT_OK checks 420 (r-s3; D7h2's 399 + the 17 d7g2 checks + the four D7g
  place checks); P0_OK checks 476 (r-s3, equal), P0_OK V5 checks 62; MIRROR_OK runs 29; REPLAY_OK checks 70;
  EXT_TIMELINE_OK (both groups); EXT_CONTINUE_OK; EXT_FCE_OK runs 8; EXT_DBL_OK checks 4; EXT_SLOTS_OK; EXT_TLD_OK;
  NODOS_OK; ext_zoom: ZOOM_FAILED=10 against the tree's golden (r-s2: exactly the ten DOS `new` combinations, at
  their samples 40,000..55,000 ms), the 40 lines rewritten by `--update --profiles dos` (r-s3: ZOOM_OK, combinations
  32, the DOS runs), then ZOOM_OK combinations 32 runs 108 samples 628 against the staged golden (r-s3, 14:10..14:26
  UTC).
* **The first suite** (`obj/r-s1/`, 11:53..12:35 UTC, on the tree after D7i) was stopped at its p0 step when D7h2's
  test step began (its adapt step's 8 failures were the three changed checks of the Tests section, fixed since).
* **Frames viewed** (private): the D7g route's research choice centred with the recommendation at the lower
  left (`obj/run/rec-last.png`); before the exception the recommendation lay under the research choice.

## Deviations from the brief

1. **The notes' place is the centre of dialog 135's Windows window** (the user's direction of 10:57): centred across
   the canvas near its top, where the Windows game shows its note, not at DOS's upper-left (56, 16) of its screen.
2. **The note's text when the DOS section is missing**: the core's text, folded, in the same box (counted in `notes`
   without `note_paired`); not met in the runs.
3. **Row 126's map recentre** (FIDELITY F-new; ruled 08:00): DOS recentres the map on a seen foreign city before its
   box (R:1AEA:0008(player, x - 10, y - 6)); the core recentres too (CenterMapViewOn 1110:03AE(human, x, y) at
   1040:1112); whether the core's origin matches DOS's x - 10, y - 6 is unknown.  The presentation adds nothing (no
   core change, no view move of its own).
4. **The sale question's building name and price are the core's** (the same words and numbers as DOS's: the cost
   times 10 in both).
5. **The recommendation keeps DOS's place** (this unit's reading of the user's direction, approved by the
   orchestrator; the user rules by D7g2-9): in DOS's flow (D7g, the user's direction of 2026-10-17 15:46) the recommendation stays on the screen with
   the research choice; the Windows game shows them one after the other, both centred.  Centred, the recommendation
   lay wholly under the research choice; at D6fSd's DOS place (A (27, 344), the lower left) both are seen, as in DOS.
6. **The N canvases keep DOS's places** (the orchestrator's reading of the user's direction, 10:58): the user named
   the boxes over the play map; the city screen's boxes (the sale question, the buy question, the production menu),
   the throne room's and the palace's stay where DOS draws them on its 320 x 200 screen.

## What the user checks

On the user build `build/user-builds/d7g2/` (`civ64.exe`, DOS files present), in play with the DOS graphics.  The
saves NOTE.SAV and GOV.SAV are edited copies of the test save CAE3540B.SAV (made by the automatic tests' save editor;
the original stays as it is); CHIEF.SAV is D7g's (Chieftain, Instant Advice on).

* **D7g2-1** The error note (NOTE.SAV; row 118): load it, switch to the DOS graphics, press I (irrigate) for the first
  unit, which is no Settlers: the DOS game's red note appears centred across the window near its top, where the
  Windows game shows its note: a red box with a light-red outline, the title "--- CIVILIZATION NOTE ---" in black and
  the explanation in white small letters below it, as in the DOS game.
* **D7g2-2** Closing a note: Return, any other key or a click closes it (the key or click does nothing else); Shift,
  Ctrl or Alt alone and the right button do not.
* **D7g2-3** The instant advice note (row 117): with Instant Advice on (GAME > Options) before 1 AD, for example after
  the first city of a new game is founded: the advice shows in the DOS game's green box (green with a light-green
  outline, the same title and white text) at the same place as D7g2-1's, closed as in D7g2-2.
* **D7g2-4** The government menu (GOV.SAV; row 115): load it, switch to the DOS graphics, press Space for each of the
  four units until the turn ends: the menu for the new government appears as the DOS game's box at the centre of the
  window, where the Windows game shows it; a click on a row, or Up, Down and Return, chooses the government as in the
  Windows graphics.
* **D7g2-5** The sale question (any save with a city that has a building, e.g. NOTE.SAV's capital and its Palace;
  row 97's screen): open the city, click a building in the list at the upper right: "Do you want to sell / your
  Palace for 200$?" in two lines with the rows "No." and "Yes.", at the DOS game's place in the middle of the city
  screen; No keeps the building.  (FIDELITY F-new: the DOS game draws this box at (128, 80); the box was at another
  place and on one line before.)
* **D7g2-6** (section "Moved boxes") Any other question or message box that appears over a DOS full screen (the city
  screen and the other 320 x 200 screens) in play: it stands where the DOS game shows it.  The private runs met no
  such box besides the sale question (D7g2-5).
* **D7g2-7** Event boxes, when they come up in play: a disaster in a city (the Domestic Advisor's header for your
  city, the Foreign Minister's for a foreign one), a civil war (the Foreign Minister's header), a diplomat's or a
  revolt's boxes and the population message: the DOS boxes with the DOS headers at the centre of the window, where
  the Windows game shows them.  For a disaster in a foreign city the DOS game moves the map to that city first; the
  game here moves it too, perhaps not to the same position (deviation 3).
* **D7g2-8** (the user's direction of 10:57, over the map) GAME > Tax Rate, Luxuries Rate, REVOLUTION!, Retire and
  QUIT to DOS, '/' (Find City), the "City Name..." box when a city is founded, and the science advisor's choice of
  the next discovery (D7g's route): each DOS box stands at the centre of the window, where the Windows game shows it (its middle at the middle
  of the whole window, not of the map area); its size, text, header and colours as before; the menus GAME, ORDERS and
  the others still open under the bar.  Ctrl+Shift+Backspace to the Windows graphics and the same boxes: the Windows
  dialogs at about the same places.
* **D7g2-9** (deviation 5, for the user's ruling) The science advisor's recommendation (CHIEF.SAV, D7g's route): the
  research choice stands at the centre of the window; the recommendation ("SCIENCE ADVISOR: / I RECOMMEND WE ...") does
  NOT follow the centre rule: it keeps the DOS game's place at the lower left, beside the research choice, over the
  Status window, so both are seen at once.  At the centre it would lie wholly hidden under the research choice.  The
  user rules whether to keep this or to want it otherwise.

**Checklist rewrites** (items that describe a DOS place on the A canvas; the orchestrator edits the checklist): the
exact new text of each item's check cell.

* **D6fSd-1**: "(the quit and Retire questions' place; rewritten for unit D7g2). -- Open GAME > QUIT to DOS (or Alt+Q,
  or Ctrl+Q). The box (D6fSc-1's text) stands at the centre of the window, where the Windows game shows it. -- GAME >
  Retire: the same box at the same place. -- Escape or "Keep Playing": the game goes on."
* **D6fSd-2**: "(the tax and luxuries boxes' place; rewritten for unit D7g2). GAME > Tax Rate (Ctrl+T) and GAME >
  Luxuries Rate (Ctrl+L): the boxes (D6fSc-4's texts) stand at the centre of the window, where the Windows game shows
  it. A click on a rate's row sets that rate; Escape keeps the rates."
* **D6fSd-3**: "(the REVOLUTION! question; rewritten for unit D7g2). GAME > REVOLUTION! (Ctrl+R): the same text as
  D6fSc-3 (now read as the DOS game's KING.TXT section of its name). The box stands at the centre of the window, where
  the Windows game shows it. Escape or "No thanks.": nothing happens."
* **D6fSd-5**: "(the other KING messages, if a game or save reaches one; rewritten for unit D7g2). A disaster in one of
  your cities (an earthquake, a fire, a flood, a plague and the others), or another of the game's messages from its
  KING texts (the record's table: 16 in all, among them the Domestic Advisor's notes and a civil war's message): the
  box shows the DOS game's own text with your game's names in it (for example the city's name in a disaster), broken
  into lines as in DOSBox, and stands at the centre of the window, where the Windows game shows it (in your own city
  and in a foreign city alike). When the Windows game adds a sentence of its own to a disaster's message ("Citizens
  demand GRANARY."), it follows on its own line. At a new game's start the Civilization Notes are the DOS game's notes
  (D7g2-1, D7g2-3)."
* **D6fSd-6**: "(the other boxes' places; rewritten for unit D7g2). Every other DOS box over the map (for example the
  science advisor's choice of the next discovery) stands at the centre of the window, where the Windows game shows it;
  so does a message box with only OK, Yes or No buttons."
* **D7g-1**: "Width (item 1, "Dialog itself is too wide"; rewritten for unit D7g2): the research choice ("Which
  discovery should our wise men be pursuing, sire? Pick one...") is as narrow as DOS's, its three lines broken as DOS
  breaks them, the advances below with DOS's names, at the centre of the window, where the Windows game shows it."
* **D6fSa-2**: "(the DOS sizes; rewritten for unit D7g2). The tax and luxuries boxes, the revolution question, the
  Game Help box and the drop-downs are as large as their text, with the DOS margins (no empty band below the last row
  or right of the longest line), as in the DOS game. Around each, where the larger Windows dialog or menu now lies
  hidden, the map (or whatever was there before the box opened) shows - never a part of the Windows window - while the
  box is open and after it closes."
* **D5-7**: the current cell with "(Rewritten for unit D6fS-a.)" made "(Rewritten for units D6fS-a and D7g2.)" and
  "at the Windows dialog's place" made "at the centre of the window, where the Windows game shows it", the rest
  unchanged; in full:

  > (Rewritten for units D6fS-a and D7g2.) Screen: in play with the DOS graphics press Ctrl+T (or `=`, or GAME > Tax Rate): the game's tax-rate menu (Windows dialog 136) appears as a DOS menu box at twice the size at the centre of the window, where the Windows game shows it (gray box 7, bevel 15 and 8, black rows of 8 pixels in DOS font 1; textured as DOS draws in play), as large as its text as in DOS. Up and Down move the bar; Return or Space choose the highlighted rate; a press on a row, a drag to another row and the release there choose that row; no Go Back or Cancel row. A box near the screen's edge is moved fully inside. **Escape closes the box and the tax rate stays as it was** (the status panel's rates unchanged), as DOS's Escape does; the same with Ctrl+L (the luxuries rate). Nothing of the Windows dialog (its frame, its OK button, a radio item) shows beside or below the DOS box, or at any moment while it closes. Build: `build/user-builds/d6fsa/`. (Which row is highlighted and when: D6fS-b's rewrite, ruling H2.) (Highlight part rewritten for unit D6fS-b.) As D6fS-a's text, with the highlight: the tax box (Ctrl+T, `=`, or GAME > Tax Rate) opens with the current rate highlighted; Up and Down move the highlight (no wrap); Return or Space choose the highlighted rate; a press on a row, a drag to another row and the release there choose that row. The rest (no Go Back or Cancel row, the box moved inside near the screen's edge, Escape keeping the rate, the same with Ctrl+L, no Windows dialog beside the box or while it closes) is unchanged.

* Unchanged: D7g-5 (the recommendation at the lower left, deviation 5), D6fSd-4 and D7j-2 (the palace, an N screen),
  D7f-1 and D7f-3 (the city screen, N), D6f-1 and D6fSa-3 (the drop-downs under the bar).

Not part of this check: the help screen over Customize World (D5e's), the Windows graphics (unchanged: the Windows
dialogs).

## For the records

* **DESIGN 12.x "As implemented (D7g2; areas B and C)":** the centring on A (`PdosRPlace.centre`, `cx`, `cy`,
  `pdos_r_place_xy` in `elem_put_a` and `own_put`; `DOS_KEEP` for the recommendation); the notes (`PDOS_RL_NOTE`,
  `pdos_rd_note_*`, the text from `pdos_r_section_text`), I-wait/note-* and `PDOS_AS_NOTE` (bit 34); the sale
  question's pairing (`PDOS_R_PAIR_SALE`, by return address 1030:6291, no call-site row); the N place rule in
  `menu_build`; `preskin2`'s nbox_* and held_* pairs and `rdlg`'s notes, note_paired, note_ax..note_cy.
* **FIDELITY** (new entries, numbers to be assigned by the docs pass):
  * F-new-1 the notes drawn as DOS's O4:02D3 and O4:03AA boxes from the DOS section of the core's name, centred on
    dialog 135's Windows window (deviations 1, 2);
  * F-new-2 the notes' input: Return passed, any other key or a left press posted as Return (the ruling of 08:25);
  * F-new-3 the sale question in DOS's text and rows at DOS's (128, 80) on N, the core's name and price (deviation 4);
  * F-new-4 the N place rule: a generic MenuZ box on N with DOS's x, y stands there (section "Moved boxes");
  * F-new-5 row 126's map recentre: the core recentres, DOS's origin x - 10, y - 6 not proven equal (deviation 3;
    ruled 08:00);
  * F-new-6 the A canvas's private element ids: `PDOS_R_HELD_ID` (D7g) and `PDOS_APLAY_NUKE_ID` (D7n) were both 0xFF30
    (found by D7i; they never coexisted in the runs, but one would have replaced the other): `PDOS_R_HELD_ID` is 0xFF50
    now, D7i's newspaper takes 0xFF40..0xFF42, D7h2 0xFF58 and 0xFF59, and test_pdos_reskin's vector checks that
    every private id on that canvas is distinct and from FF00h;
  * F-new-7 **the DOS boxes on the A canvas centred on their Windows windows**, reversing for A D6fSd's DOS places
    (F289; Choice D6fSd-2) and B16's anchor at the window's top-left (F202), and making D7g's header offset (F299) moot.
    The user (2026-10-18 about 10:57 UTC, in chat, session E4), verbatim: "I understand that you are trying to put
    DOS popup/windows and dialog boxes such as but limited to, Tax Rate, Luxuries Rate,  Revolution, Retires, Quit to
    DOS, Advances selection dialog box etc. to their relevant DOS locations but, they shall approximately be placed by
    the location of their Windows counterparts. Which is generally (what I infer from the visual inspection) is the
    center (both horizontally and vertically) of the whole canvas -not just the play map area-."  The orchestrator's
    rule (10:58, approved reading 11:10): the box's centre at its Windows window's centre, clamped inside the canvas
    (the canvas's centre for the centred dialogs); without a Windows dialog the canvas's centre; size, text, header
    and colours unchanged; the N canvases keep DOS's places (the orchestrator's reading, deviation 6); the drop-downs
    stay under the bar.  DOS's place stays in the diagnostics;
  * F-new-8 the recommendation's exception: it keeps D6fSd's DOS place on A so that it stays seen beside the centred
    research choice (deviation 5; approved by the orchestrator, the user rules by D7g2-9);
  * F-new-9 (test harness) D7h2's `rrows = D_LOAD` in ext_adapt extended the shared `D_LOAD` for every later run: found
    and fixed by D7g2 (`list(D_LOAD)`), approved by the orchestrator.
* **DOS-PROFILE row 41 (`#MsgBox`)** (the orchestrator's item of 08:00): the core's revolution path shows no `#MsgBox`:
  the question is ShowTextDialog 11F0:3B85 (dialog 136; D6fSc's REV text, DOS's (64, 80), now centred on A), then the
  newspaper (D7i).  The row's class and adapter (R, I-menu) stand; D8 can drop any `#MsgBox` wording for it.
* **The sale question** (the orchestrator's item of 08:00; D7d's, D7e's and D7f's records and FIDELITY F237 name it
  for D7g): built here (row 97's screen; the box itself has no row of its own: D8 may name it in row 97 or row 14).
* **OPEN**: none resolved or opened.
* **DOS-PROFILE.md** (as staged): rows 13, 41, 97, 115, 117, 118, 126, 127, 128, 137 "extension D7g2" (the centring
  named in rows 41, 115, 117, 126..128, 137); 1.7.2 generated (the five I-wait/note-* rows).
* **RUNNING.md**: presentation-diag.log's `rdlg` pairs notes, note_paired, note_ax, note_ay, note_w, note_h, note_cx,
  note_cy and `preskin2`'s nbox_id, nbox_x, nbox_y, nbox_dos, nbox_anchor, nbox_n, held_ax, held_ay, held_w, held_h;
  ext_adapt's d7g2 pairs and their saves NOTE.SAV and GOV.SAV.
* **FEATURES.md**: the DOS boxes over the map centred where the Windows game shows them; the DOS notes (instant
  advice, errors), the DOS sale question, the government menu checked.
* **STATUS.md**: D7g2 landed (rows 13, 41, 115, 117, 118, 126..128, 137; the sale question; the centring on A).
* **manual-checklist-ext.md**: new items D7g2-1..D7g2-9 (above); the rewrites of D6fSd-1, -2, -3, -5, -6, D7g-1, D5-7
  and D6fSa-2 (above).
* Not edited by this unit: DESIGN.md, FIDELITY.md, STATUS.md, RUNNING.md, FEATURES.md, OPEN.md, DOS-PROFILE.md
  outside the rows above and 1.7.2, manual-checklist-ext.md.

## Expected changes at the build slot

Against D7h2's cycle (`build/d7h2-*.log`):

* **Build**: portable sources 310 (equal); the three variants BUILD_OK.
* **Unit**: test_input 673 -> 689 (the five I-wait/note-* vectors), test_pdos_rdlg 48 -> 75 (the notes, the sale
  text), test_pdos_reskin 228 -> 229 (`test_a_ids`), test_dos 23,291 -> 23,293 (the two new tables `NOTE_TITLE`,
  `SALE_TEXTS`) and `tests/dos-decoded.txt` 1,426 -> 1,428 lines; every other program's count equal.
* **Generators**: REGISTRY_OK; ADAPT_OK rows 161 -> 166 steps 27; OBS_LINT_OK 152 / 203 / 103, OBS_TABLES_OK 203 /
  103 and pdos_scene_check 1084 equal; NODOS_OK.
* **ext_adapt**: EXT_ADAPT_OK 399 -> 420 (+17 d7g2, +4 D7g place checks).
* **ext_p0 / ext_mirror / ext_g1**: P0_OK 476 equal (the `--g1` runs are not in test.cmd); MIRROR_OK runs 29;
  EXT_G1_OK runs 77 (no core change).
* **ext_zoom**: ZOOM_OK with the staged golden (its 40 DOS `new` lines at 40,000..55,000 ms changed).
* **ext_timeline, ext_continue, ext_fce, ext_dbl, ext_slots, ext_tld**: unchanged.

## Rebase notes

The first stage was made on the tree after D7g's landing (RELEASE_OK 07:41:46 UTC); every base is in
`obj/base/` (equal to the tree at each rebase), the bases before each rebase in `obj/base-pre-<unit>/`.  Merges are
`git merge-file -p` to stdout on LF copies (`obj/rebase.py`, read only; files only), the result keeping the tree's line
endings; the generated files (`pdos_registry.c/.h`, `tests/dos-decoded.txt`, DOS-PROFILE 1.7.2) were regenerated on
the merged sources (`obj/gen.sh`, `adapters.py gen`), not merged.

* **D7h's landing** (copy-in 09:15:07 UTC): nine staged files had D7h's changes: `docs/dos/OFFSETS.md`,
  `docs/DOS-PROFILE.md`, `pdos_adapt.c`, `pdos_adapt_tab.c`, `pdos_rdlg.c`, `pdos_rdlg.h`, `tests/harness/ext_adapt.py`,
  `tests/test_input.c`, `tests/test_pdos_rdlg.c`.  The conflicts were appends at the same place (the tables' rows,
  the adapter rows after D7h's I-pedia rows, the scene bits, the run list, the input vectors): both kept, D7h's first;
  `pdos_rdlg.c` keeps D7h's include of `pdos_scn_pedia.h`; `PDOS_AS_NOTE` takes bit 34 of D7h's 64-bit scene (ruled
  08:25), `pdos_adapt.h` staged from D7h's file.
* **D7i's landing** (copy-in 10:25:44 UTC, RELEASE_OK 11:04:25 UTC): six staged files had D7i's changes:
  `docs/dos/OFFSETS.md`, `docs/DOS-PROFILE.md`, `pdos_adapt.c`, `pdos_reskin.c`, `pdos_reskin.h`,
  `tests/harness/ext_adapt.py`; the conflicts again appends at the same place, both kept, D7i's first; in
  DOS-PROFILE row 119 is D7i's, rows 117 and 118 D7g2's.  `test_pdos_reskin.c` (staged after D7i) includes D7i's
  `pdos_scn_news.h` for its ids.
* **D7h2's landing** (copy-in 11:53:43 UTC, RELEASE_OK 12:40:13 UTC): one staged file had D7h2's change,
  `tests/harness/ext_adapt.py`: one conflict in `main()`'s run list, resolved with `d7h2_runs` first, then `d7g2_runs`
  (the merge output in `obj/rebase-d7h2/`).  `test_pdos_reskin.c` includes D7h2's `pdos_scn_pedia.h` and lists its two
  ids.  D7h2's other files (`pdos_scn_pedia.c/.h`, `tests/test_pdos_pedia.c`) are not D7g2's.
* **D7h2's `rrows = D_LOAD`** (ext_adapt's d7h2-research; found and fixed by D7g2, approved by the orchestrator):
  its `+=` extended the shared `D_LOAD` list itself, so every
  later run built from `D_LOAD` (D7g2's, after `d7h2_runs` in `main()`) got D7h2's keys: the private run's d7g2 note
  and government runs failed (11 checks).  Fixed in the stage as `rrows = list(D_LOAD)` (one line, an "extension D7g2"
  comment); D7h2's own runs are unchanged by it.
* **Dropped from the stage**: `tests/test_pdos_adapt.c` (staged early, never changed: equal to the tree; kept in
  `obj/ex/unstaged/`).
* **The centring and D6fSd's place code**: `pdos_r_dos_place` and `map_client` stay (the diagnostics' DOS place and
  the recommendation's `DOS_KEEP`); `pdos_reskin_a_place_dos` of D7g2's first draft never reached the tree.

## Landing

Landed 2026-10-18 by the build slot, after D7h2's (`build/d7h2-prep/LANDED.txt`), the orchestrator's approval of the
six READY points (deviation 5, the D7h2 `list(D_LOAD)` fix, the ext_p0 `--g1` hunk only, the changed checks, the zoom
golden, the moved boxes).

* **Copy-in** 14:28:22 UTC (`build/d7g2-prep/land.py --write`): 20 files byte for byte (19 changed, every base equal
  to the tree; 1 new: this record), the tree's previous files in `build/d7g2-prep/tree-before`, the Checked test
  outputs before in `build/d7g2-prep/before`, the list in `build/d7g2-prep/landed.sha256`; build.cmd and test.cmd
  unchanged.
* **The cycle** (`build/d7g2-prep/d7g2-cycle.ps1 -LastStep 4`, `build/d7g2-status.txt`):
  * 1 build.cmd checked: BUILD_OK, 204 s (14:28:26..14:31:50), portable sources 310;
  * 2 test.cmd checked: TESTS_OK, 1,720 s (14:31:50..15:00:30);
  * 3 ext_g1.py check: EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events), as D7h2; ALL_GREEN;
  * 4 build.cmd (Release): BUILD_OK, 196 s (15:00:31..15:03:46); RELEASE_OK.
* **Against D7h2's cycle** (`build/d7g2-prep/compare.py`, 55 of 66 output files the same, the others as follows):
  test_input 673 -> 689, test_pdos_rdlg 48 -> 75, test_pdos_reskin 228 -> 229, test_dos 23,291 -> 23,293, the
  registry's tables 102 -> 104, decoded content 1,421 -> 1,423 entries; ADAPT_OK rows 161 -> 166 steps 27;
  EXT_ADAPT_OK 399 -> 420; P0_OK 476, MIRROR_OK runs 29, REPLAY_OK 70, ZOOM_OK 628 samples, EXT_TIMELINE_OK,
  EXT_CONTINUE_OK, EXT_SLOTS_OK, EXT_TLD_OK, EXT_FCE_OK runs 8, EXT_DBL_OK checks 4, OBS_LINT_OK 152 / 203 / 103,
  OBS_TABLES_OK 203 / 103, pdos_scene_check PASS 1084, REGISTRY_OK and NODOS_OK as D7h2's (the rest host times).  As
  section "Expected changes at the build slot" said.
* **User build** `build/user-builds/d7g2/` (15:10 UTC): the Release civ64.exe, CIVWIN.zip, civdos.zip, NOTE.SAV,
  GOV.SAV, CHIEF.SAV and WHAT-TO-CHECK.txt (D7g2-1..D7g2-9, the rewritten items, 166 still-open items).

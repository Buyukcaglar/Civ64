# Extension phase D7, unit D7g (the science advisor's boxes: the header variant, the research choice, the recommendation in DOS's flow) - record

Draft for the build slot (BRIEF-d7.md "Units" D7g, extension session E4, track B).  Staged in `build/d7g-stage/` on the
tree after D7e's landing (RELEASE_OK 23:46:36 UTC) and D7f's stage (`build/d7f-stage`: D7f lands before D7g; D7g reuses
its help line), then rebased onto D7k's landing and D7f's stage rebased on it; D7f then landed as staged; then rebased
onto D6fSd's landing (04:28:49 UTC, RELEASE_OK after ALL_GREEN 05:06:44), whose DOS places D7g's boxes now take, and
onto D7n's (05:35:13 UTC) (section "Rebase notes").  The stage applies to the tree after D7n's landing.  Private builds
and runs in `build/d7g-stage/obj/` only: an overlay `obj/src` = the tree + D7g's stage (`obj/mkoverlay.py`), built with
the tree's build.cmd and flags (`obj/b.cmd`, `--nogen`), cc.cmd's stricter checks per file (`obj/cc.cmd`), the unit
programs (`obj/unit.py`) and the harness runs from the overlay's binaries with every output under `obj/`
(`obj/runadapt.py`, `obj/runp0.py`, `obj/explore.py`); the tree's build/gamedata, dosdata and cache read only.

## Result

D7g is staged and READY_TO_BUILD for the user's three reports of 2026-10-17 on the science advisor (about 15:37, 15:41
and 15:46 UTC) and the orchestrator's ruling of 15:46.  With the DOS graphics:

* **The header variant** (R:1D05:0613..0758; DGROUP:2F9E; OPEN L8): every MenuZ box of dialogs 136 and 145 that the
  core opens with a message picture (`g_messagePicture` 0..6, read at MenuZ's entry) is drawn with DOS's header: the
  box widened to the title, the frame 42 pixels left of and 8 above the text and at least 61 high, the title
  (DGROUP:2FA6's caption, " report:" after captions 0..2) at (x + 5, y - 4) in colour 15 with its colour-11 rule, and
  the advisor's portrait from page 2 (pictures 3..6) or the report icon (0..2) in the frame's left part.
* **The research choice** (R:0ADE:1B3D..1CC2; row 22): DOS's text, in DOS's three lines ("Which discovery should our" /
  the core's word for its wise men "be pursuing, sire?" / "Pick one...") with the advances below by their DOS names,
  font 1, the Science Advisor header (6), D7f's "(HELP AVAILABLE)" line in colour 10 at the lower right while the
  dialog's Help button is enabled, at DOS's place (80, 64) (on the A canvas by D6fSd's rule, the DOS map view's origin
  at the map window's client origin, 2x; the header frame 42 left of and 8 above that place, so its left part lies over
  the Status window as DOS's over its side panel).  Escape chooses the first advance (DOS's -1 becomes 0).  Alt+H and
  the right button stay the Help button (I-menu/help).
* **The recommendation** (R:0ADE:19FB..1B38; Chieftain with Instant Advice on): drawn as DOS's advice box: DOS's text
  ("Science Advisor:" / "I recommend we" / "develop <advance>." / "So we can build:" / "-<unit or improvement>" ...,
  the advance by its DOS name), font 2 (DOS's capitals), no header, at DOS's (8, 168 - 8 n) (D6fSd's rule: over the
  Status window, lower left), without the stray glyph
  (the core's '\r' that the fold made a '?').  DOS's box does not wait, so (the ruling) the presentation gives the
  core's box the dismissal a Windows player gives it, Return pressed and released once, at the first input-taking
  sync at which the box's MenuZ waits, and holds the box's DOS picture under the research choice until the research
  choice's ShowTextDialog returns: one choice ends both, as in DOS.  The core receives only that Windows input.

The Windows graphics are unchanged (no dismissal is posted while they show).  Privately, on the tree after D7f's
landing: the three variants build, every unit program passes in each (test_dos's golden comparison aside: it reads
the tree's goldens; its output equals the staged ones), ext_adapt's d7g pairs pass 17 of 17 (the DOS run's core
inputs, frames, state and events equal its Windows-form run's, in which the player presses Return at the posted
instant; the same for a Windows-start run switched to the DOS graphics while the recommendation waits, for a DOS run
switched to Windows and back during the research choice, and for Escape on the research choice) and fail 15 of 17 on
the base, ext_adapt (every case) EXT_ADAPT_OK checks 336, ext_p0 P0_OK checks 476 (V5 62), and every check script
and every other harness suite run passes with output equal to D7f's cycle's.

## Status

READY_TO_BUILD.  Built: the header variant in `pdos_ui` (`PdosMenuBox.header`, `title_w`, `pdos_menubox_extent`,
`pdos_menubox_header_title`); the science advisor's pairing in `pdos_reskin` (`PDOS_R_PAIR_SCIENCE`,
`PDOS_R_PAIR_ADVICE`: `pdos_r_science_text`, `pdos_r_advice_text`, `pdos_r_dos_advance`), the header box's A place
(`a_place_box`: D6fSd's `a_place_of` at the call's DOS place less the header frame's offset), the header from the core's
`g_messagePicture` (`PdosRSpec.header`), Escape's rule `PDOS_R_ESC_FIRST`, the recommendation's flow (`pdos_r_advice_*`,
`pdos_reskin_advice_release` called by `pdos_pend_release` after D4b4's Birth auto-continue) and the held picture
(`PDOS_R_HELD_ID`); the adapter row I-menu/advice (core state `PDOS_AC_ADVICE`; no scene or action bit); two observer
call-site rows (ShowTextDialog from 1170:286F and 1170:29EC); two registry tables (REPORT_SUFFIX, SCIENCE_TEXTS);
obs_lint's I1 rule with the second exception; the `preskin` diag pairs adv_shown, adv_posted, adv_held, adv_ended.

Not built (the brief's other D7g rows, not in the orchestrator's D7g list of 2026-10-17/18): rows 13, 41, 115, 117,
118, 126..128 and 137 (the one-line notes' three DOS forms, Revolution's boxes, the government menu, the instant
advice and error boxes, the O20, O15 and O22 boxes, the placement check).  Their header boxes take the header
variant already where the core opens a dialog 136 or 145 MenuZ with a message picture; their DOS places are D6fSd's
(the DOS x, y the core passes); the rest is a follow-up unit if the orchestrator wants it.

## What was built

### The header variant (rows 14, 22; DOS listing R:1D05:0613..0758; OPEN L8)

* **Its input.**  DOS's `[2F9E]` is the header number (-1 none), set by the caller before R:0238:0008 and reset after
  every box (R:1D05:0456..0461).  The core's counterpart is `g_messagePicture` (1418:0006), which MenuZ reads at its
  entry (1220:0256) and resets at its end (1220:0C80); the numbering is shared (SCENES-PLAY 0.2; CORR 5).  The
  re-skin reads it at MenuZ's entry probe (w16q_read) and gives it to the box of dialogs 136 and 145
  (`PdosRSpec.header` = picture + 1), except the recommendation's (DOS draws it without a header: R:0ADE:1A18..1B31
  leaves 2F9E at -1).
* **The layout** (`pdos_menubox_layout`, framed boxes only, y even: R:1D05:05E4): the title is DGROUP:2FA6's caption n
  (registry REPORT_CAPTIONS), with " report:" (REPORT_SUFFIX, DGROUP:2FB4) after captions 0..2 (R:1D05:0613..063D);
  its width in the box's font (0644); the box's right edge moved to x + width + 8 when that is further
  (064F..065D).
* **The drawing** (`pdos_menubox_draw` -> header_draw, then D7f's help line, then the lines): the frame R:1D05:096C
  at (x - 42, y - 8), width right - x + 42, height h + 8 clamped to 3Dh..3E7h, colour 7 (0667..0699); pictures 0..2:
  the icon DGROUP:DF62[n] (G#32, the store's SP299 cut PDOS_SH_REPORT) at (x - 40, y - 5) (06AC..06C8); pictures 3..6:
  G#20 from page 2 (D7a's portraits, `pdos_report_portraits`) at (40 n + 40, 140), 40 x 60, to (x - 40, y - 6), lower
  by h - 53 when the box is taller than 52 (06D2..070D); the title R:0182:005C at (x + 5, y - 4) in colour 15
  (0715..072B); the rule R:0182:000A from (x + 5, y + 3) to (x + 5 + width, y + 3) in colour 11 (0733..0753).
* **The element** is the box's extent (`pdos_menubox_extent`: the header frame included), the box laid out at
  (42, 8) inside it; on the N canvas the extent's top-left at (x - 42, y - 8).

### The research choice (row 22; SCENES-PLAY 7.11; DOS listing R:0ADE:1B3D..1CC2)

* **Identified** by its call site: ShowTextDialog's return address 1170:29F1 (the call 1170:29EC in
  CompleteResearch; observer call-site row), recorded at ShowTextDialog's entry and bound to the MenuZ box it opens.
* **Its text** (`pdos_r_science_text`, SCIENCE_TEXTS read through the store): DGROUP:236C + the word the core's title
  holds (2388 "scientists" or 2393 "wise men": R:0ADE:1B4D..1B68 picks it by whether the human knows advance 14h,
  as the core's 1170:28A8 does) + 239C, cut after its last line feed (the trailing space starts the first item,
  R:0ADE:1B75): three header lines; then one row per core item, the advance by its DOS name (ADVANCE_NAMES:
  the same name, or the DOS name the core's ends with after a space: the core's "The Monarchy" for DOS's "Monarchy";
  three names differ so).  Unpaired (another title, no row, no DOS data): D6fSc's line rule on the core's text.
* **Its place**: DOS's (50h, 40h) (R:0ADE:1C64..1C70: R:0238:0008(BA06, 50h, 40h)), which the core's call passes
  too (D6fSd's table).  On the N canvas at (80, 64); on the A canvas (play) by D6fSd's rule (`pdos_r_dos_place`: the
  map window's client origin + 2 x (x - 80, y - 8), then 11.3's clamp) for the header's frame at (80 - 42, 64 - 8)
  (`a_place_box`; deviation 1): in the harness's layout (client origin (171, 40)) at (87, 136).
* **Header and help**: header 6 (R:0ADE:1C52); the help line (DGROUP:2FA0 = 1 when there are items, R:0ADE:1C5E;
  D7f's `pdos_menubox_help_line`) while dialog 145's Help button is enabled and shown.
* **Escape** (O1's rule `pdos_reskin_escape_item`, I-menu/escape-row): DOS's -1 becomes 0 (R:0ADE:1C8A..1C90), so
  Escape chooses the core's item 0, the first advance listed (`PDOS_R_ESC_FIRST`).

### The recommendation (row 14; SCENES-PLAY 7.11; DOS listing R:0ADE:19FB..1B38)

* **The condition** is the same in both programs (finding (b), reported 2026-10-17 23:52): DOS `[19C0] & 1` (Instant
  Advice), the recommended advance not -1, `[6B86] == 0` (Chieftain); the core's 1170:26EF..2840 (option bit 1, the
  best advance not -1, `g_difficultyLevel` 0).  The presentation shows what the core shows; it computes no advice.
* **Identified** by ShowTextDialog's return address 1170:2874 (the call 1170:286F; `g_adviceBoxFlag` 1 is written
  there and never read, so the call site is the identification).
* **Its text** (`pdos_r_advice_text`): the core's text ("I recommend we develop " + advance + " so we can build:" +
  "\r   - " + name per unit and improvement, or + ".") folded with its '\r' kept (`fold_breaks`), parsed by DOS's
  pieces (the opening lines of DGROUP:2327 after its first, joined; 2353's first line, case ignored; 2350), and
  rebuilt as DOS's: 2327 + the advance's DOS name + 2350, then 2353 before the first name, each name + 2366 (a unit)
  or 2369 (an improvement: IMPR_RECORDS' buildings 1..23; units first, as R:0ADE:1A72..1AF8 lists them), cut after the
  last line feed (R:1D05:0475 draws the lines its line feeds end: the last "-" is not drawn, 0569).  Unpaired (another
  form, no DOS data): D6fSc's line rule on the core's text, font 2, the same place.
* **Its place and font**: font 2 (R:0ADE:1B08..1B0C; the core sets font 2 too), (8, 168 - 8 n) for n names
  (R:0ADE:1B17..1B2C: R:0238:0008(BA06, 8, 0A8h - 8 n); the core's call passes the same), no header; on the A canvas
  by D6fSd's rule (with one name: (27, 344) in the harness's layout).
* **DOS's flow**: `[DB38] = 1` before the call; R:1D05:013A draws the box (R:1D05:0475), clears DB38 and returns -1 at
  once: no wait (DOS listing, confirmed).  The research choice follows over it; its end redraws the screen.

### The dismissal and the held picture (the ruling of 2026-10-17 15:46)

* **Shown**: the recommendation's box binds at its MenuZ's first key poll (`pdos_r_advice_shown`: state SHOWN, its
  dialog).
* **Posted** (`pdos_r_advice_post`, called by `pdos_reskin_advice_release` from `pdos_pend_release`, once per
  input-taking sync, after D4b4's Birth auto-continue): only in state SHOWN, with the DOS graphics visible
  (`pdos_profile_visible`), the core's MenuZ in its input loop on that dialog (mz_active, mz_ready, mz_dlg) and room
  for two events: Return down (vk 0Dh, scan 1Ch, its character 0Dh) and up at that sync, the input a Windows player
  gives dialog 136; state POSTED.  Never twice for one box.  No time, timer or random value is read; the core's
  state alone decides (P0).
* **Held** (`pdos_r_advice_closed` at the dialog's hide or destroy): when the dismissal was posted, or the DOS graphics
  show at the close, the box's element becomes `PDOS_R_HELD_ID` (no hit, no menu, no A box for the adapter), drawn as
  before; else (the Windows player closed it with the Windows graphics) it goes.  **Ended**
  (`pdos_r_advice_std_exit`): the first ShowTextDialog return after the hold is the recommendation's own; the next is
  the research choice's: the held picture goes then.
* **Input while it waits** (I-menu/advice, core state `PDOS_AC_ADVICE` for the RMENU scene of that box until its close):
  every key, character, press and release consumed (DOS's box takes none; the research choice takes the next).
* **Graphics switches**: Windows graphics at the opening, a switch to the DOS graphics while the core's box waits:
  posted at the next input-taking sync (d7g-switch); DOS graphics, a switch to Windows during the research choice
  and back: the held picture kept, invisible with the Windows graphics, shown again (d7g-flip); a switch to Windows
  before the post (the few milliseconds the core's MenuZ needs): nothing posted, the Windows player's Return
  dismisses the core's box as before.
* **I1** (C.12.1): this is the second presentation-made input after D4b4's, ruled by the orchestrator under the user's
  direction; obs_lint's I1 rule names `pdos_reskin.c`'s `pdos_r_advice_post` as its second allowed place.

### Evidence labels

* DOS listing: the header variant (R:1D05:0613..0758), the box's reset of 2F9E (R:1D05:0456..0461), the research
  choice (R:0ADE:1B3D..1CC2), the recommendation and its condition (R:0ADE:19FB..1B38), DB38's no-wait return
  (R:1D05:013A), the drawn lines (R:1D05:0569).
* DOS file: the strings REPORT_SUFFIX (DGROUP:2FB4) and SCIENCE_TEXTS (DGROUP:2327..23BE), hash-pinned in OFFSETS.md
  and read through the store; REPORT_CAPTIONS, ADVANCE_NAMES, IMPR_RECORDS as registered before.
* inferred: the header numbering shared by `g_messagePicture` and 2F9E for every caller (SCENES-PLAY 0.2, CORR 5: the
  callers checked share it; not every caller compared); the held picture's lifetime as DOS's screen keeps the box
  (DOS: page 0 until the research choice's end redraws).
* unknown: none for this unit's scope.

## Files

Changed (bases: section "Rebase notes"): `present/dos/pdos_ui.c/.h`, `present/dos/pdos_reskin.c/.h`,
`present/dos/pdos_pend.c/.h`, `present/dos/pdos_adapt.c/.h`, `present/dos/pdos_adapt_tab.c`,
`present/dos/pdos_registry.c/.h` (generated), `present/obs_tables.c/.h` (generated), `gen/obs_tables.py`,
`gen/dos/adapters.py`, `docs/dos/OFFSETS.md`, `docs/DOS-PROFILE.md` (rows 14, 22; 1.7.2 generated),
`tests/dos-decoded.txt` (generated), `tests/test_pdos_ui.c`, `tests/test_pdos_reskin.c`, `tests/test_input.c`,
`tests/test_observer.c` (the call-site count 101 -> 103), `tests/harness/ext_adapt.py`, `tests/harness/obs_lint.py`.
New: this record.  No new source or test program.

## Tests

* **test_pdos_ui** (34 -> 48 checks; synthetic titles, the store's fonts, icons and page-2 art at run time): the
  title (" report:" for 0..2, cut at the buffer, none outside 0..6); a header box widened to its title; the extent
  (x - 42, y - 8, at least 61 high); no header on an odd y; the frame's outline and fill; the portrait from page 2 at
  (x - 40, y - 6) and lower in a taller box; the title in colour 15 and the colour-11 rule's ends; nothing above a box
  without a header; the icon for header 1; the help line under a header; the registry's titles.
* **test_pdos_reskin** (209 -> 228 checks, CheckedNoObs 197 -> 216, on the tree after D6fSd; the store's strings, no DOS
  byte): `pdos_r_dos_advance` ("The " + a DOS name); the research choice's header for "wise men" and "scientists", the
  rows by DOS name, the refusals; the recommendation with a unit and an improvement, the "." form, the refusals; Escape
  FIRST; the flow: idle; shown but not posted before MenuZ waits, on another dialog, without room; posted once (Return
  down and up); held at the close (also when the Windows graphics show by then); the lifetime (the second ShowTextDialog
  return ends it); with the Windows graphics nothing posted and nothing held; a switch to DOS while it waits; closed
  unposted with DOS visible: held.
* **test_input** (638 -> 644 checks: +6 vectors, 154 rows): I-menu/advice consumes Return, Escape, Space, a left
  press and its release, a right press, a character.
* **test_observer**: the generated tables' call-site count 103 (the two ShowTextDialog rows).
* **ext_adapt.py's d7g pairs** (17 checks; edited CAE3540B.SAV `CHIEF.SAV`: civ 2 out of aliveCivsMask, so turn 23
  ends without an audience; civResearchProgress[1] 4000h; Chieftain; Instant Advice): d7g-dos (DOS: one dismissal
  posted after 34 s; adv 1/1/1/1; abox_pair 16; the rows) against d7g-dos-win (Windows: the player's Return at the
  posted instant; adv_posted 0, adv_held 0): equal traces; d7g-flip (chords at 36 and 38 s) against d7g-dos-win:
  equal; d7g-switch (Windows start, chord at 36 s: posted after it) against d7g-switch-win: equal; d7g-esc (Escape on
  the research choice: I-menu/escape-row, one click on the core's item 0, Return at the release sync) against
  d7g-esc-win (the Windows player's click there and Return at that sync): equal, and the game's memory at the end
  equal to d7g-esc-ret's (DOS form, Return alone at that sync: the opening row) in every global but the input's own
  record; d7f-buy's DOS run (the buy question, another dialog-136 box): adv_shown 0, adv_posted 0.
* Each new unit check fails on the base (the API is new: the base does not build them); the d7g pairs fail 15 of
  their 17 checks on the base (no dismissal: the DOS run waits at the recommendation, no Windows-form pair; section
  "Results").

## Results (private, `build/d7g-stage/obj/`)

Three rounds, each on the overlay `obj/src` laid on the tree of its time + D7g's stage (section "Rebase notes").

**Third round: the tree after D7n's landing (05:35:13 UTC, RELEASE_OK 06:28:33) + the stage** (06:20 UTC onwards;
`obj/post-d7n.log`), the bases of `BASE-SHA256.txt` rechecked (24 tree files, 0 differing):

* **Builds**: CheckedNoObs and Release BUILD_OK (`obj/b4-*.log`, 06:20..06:40 UTC); Checked BUILD_OK on the second
  try (`obj/b5-checked.log`; the first was refused at the link, LNK1168, the harness held open by the void suite,
  "Host load" below).
* **Unit** (`obj/unit5-*.log`): every program passes in the three variants but test_dos's golden comparison (the
  golden location, as before): test_pdos_ui 48, test_pdos_reskin 228 (CheckedNoObs 216), test_input 644 (CheckedNoObs
  587), test_observer 126, test_dos 23,283 (94 tables).
* **Checks** (05:51 UTC on the overlay laid after D7n; nodos 06:53): REGISTRY_OK, 0 failures, 548 `ok` lines (the tree's
  533; `obj/r-regcheck.txt`); OBS_LINT_OK files 148 probes 203 callsites 103 (the tree's 101); OBS_TABLES_OK probes 203
  sites 103; `pdos_scene_check.py` PASS 1084; ADAPT_OK rows 154 steps 27 (the tree's 153); NODOS_OK, 0 hits
  (`obj/run-nodos5.log`).
* **cc.cmd** on the nine changed sources in Checked, CheckedNoObs and Release and `test_observer.c` (Checked): CC_OK
  each (`obj/run-cc5-*.log`); `test_input.c` as before (F-new-7).
* **ext_adapt's d7g pairs and d7f-buy** (`obj/runadapt.py ... d7g`, `obj/run-adapt-n.log`, 06:49 UTC): the 16 d7g
  checks PASS, the same values as before (the dismissal at 34,003,850 / 36,020,850 us; adv 1/1/1/1, abox_pair 16;
  coreinput 22, frames 613 / 618; d7g-esc 25, 613, its memory equal to d7g-esc-ret's in 806 globals); the d7f-buy
  check reads d7f-buy's run, which this selection does not make (-9: no record), so it is not a result here (the
  second round's d7f + d7g selection passed it).  The whole ext_adapt is left to the cycle (D7n's 342 + the 17: 359
  expected).

**Second round: the tree after D6fSd's landing (04:28:49 UTC) + the stage** (05:07..05:44 UTC): Checked,
CheckedNoObs and Release BUILD_OK (`obj/b3-*.log`); the d7f and d7g pairs RUNADAPT checks 37 failed 0
(`obj/run-adapt-d7fg2.log`); the whole ext_adapt EXT_ADAPT_OK checks 346 (D6fSd's cycle 329 + the 17;
`obj/r-s3/adapt.log`, 05:30..05:44 UTC).  A DOS frame on D6fSd's place rule (`obj/run/view-dos2`, viewed, not kept):
the research choice's A box at (87, 136), its portrait and frame over the Status window, the help line in green at its
lower right; the recommendation at (27, 344).  The rest of that suite is void ("Host load").

**First round: the tree after D7f's landing + the stage.**  Session E4 (2026-10-18), on the overlay `obj/src` = the tree
after D7k's landing + D7f's stage + D7g's stage, equal to the tree after D7f's landing (02:30:03 UTC, RELEASE_OK) +
D7g's stage (compared at 02:41 UTC: only three docs differ, section "Rebase notes"); the bases of `BASE-SHA256.txt`
rechecked:

* **Builds** (`obj/b.cmd`, the tree's build.cmd and flags with `--nogen`): Checked, CheckedNoObs and Release
  BUILD_OK, portable sources checked 308 (unchanged; no new source), 02:09..02:19 UTC (`obj/b-*.log`); Checked again
  after the test_observer edit (03:11..03:16 UTC), Release and CheckedNoObs again after it (`obj/b-*2.log`).
* **cc.cmd** (`obj/cc.cmd`: c11 and c17 /W4 /WX and the clang C99 parse) on `pdos_ui.c`, `pdos_reskin.c`,
  `pdos_pend.c`, `pdos_adapt.c`, `pdos_adapt_tab.c`, `pdos_registry.c`, `obs_tables.c`, `test_pdos_ui.c` and
  `test_pdos_reskin.c` in Checked, CheckedNoObs and Release, and `test_observer.c` (Checked): CC_OK each.
  `test_input.c` stops at the clang C99 parse on line 189 (`g_tp`'s missing `square_only` initializer), the same
  line in the tree's file (D7f's landed one; not one of build.cmd's portable sources): not D7g's (F-new-7).
* **Unit** (`obj/unit.py`, the tree's build/gamedata read only): all 64 programs (test_ne aside) pass in Checked,
  CheckedNoObs and Release but test_dos's golden comparison: test_pdos_ui 34 -> 48 in each; test_pdos_reskin 171 ->
  190 (CheckedNoObs 159 -> 178); test_input 638 -> 644 (CheckedNoObs 587); test_observer 126 (the call-site count
  103); test_dos 23,281 -> 23,283 ("registry: 92 -> 94 tables valid"), its one failure the golden comparison only
  (test_dos reads the goldens beside the gamedata it is given: the tree's `tests/dos-decoded.txt`, without the two
  rows); its decoded output equals the staged `tests/dos-decoded.txt` line for line (1,413 decoded lines) in each
  variant.  Against D7f's cycle log (`build/d7f-2-test-checked.log`; `obj/cmpunit.py`) every other Checked count is
  equal.
* **Checks** on the overlay: `registry.py check` (`--dosdata` and `--disasm` of the tree's build, read only)
  REGISTRY_OK, 0 failures, 544 `ok` lines (the tree's 529; dos-decoded 1,411 -> 1,413 lines); `obs_lint.py`
  OBS_LINT_OK files 148 probes 203 callsites 103 (the tree's 101); `obs_tables.py --check` (`obj/obstab.py`, the
  tree's listing) OBS_TABLES_OK probes 203 sites 103; `pdos_scene_check.py` PASS 1084 checks, 141 scene rows, 10 font
  rows; `adapters.py check` ADAPT_OK rows 154 steps 27 (the tree's 153); `nodos.py check --root obj/src` (the three
  variants' binaries; the tree's build/dosdata and build/gamedata read) NODOS_OK, 1,202 files, 0 hits.
* **ext_adapt** (`obj/runadapt.py ... all`: the staged ext_adapt.py's whole main with the private Checked harness,
  02:26..02:47 UTC): EXT_ADAPT_OK checks 336 (D7f's cycle 319 + the d7g pairs' 17); every other PASS line equal to
  D7f's cycle's (`build/test/Checked/ext-adapt.txt`).  The d7g pairs: the dismissal posted at 34,003,850 us (d7g-dos,
  d7g-esc) and 36,020,850 us (d7g-switch: at the switch's next input-taking sync); adv 1/1/1/1 and abox_pair 16 in
  the four DOS runs, adv_posted 0 and adv_held 0 in d7g-dos-win; equal core outputs (coreinput 22, frames 613;
  d7g-switch 22, 618; d7g-esc 25, 613); d7g-esc's click on the core's (320, 194), its memory equal to d7g-esc-ret's in
  806 globals but `g_lastClickedControl`, `g_msg`.
* **The d7g pairs fail on the base**: the same staged ext_adapt.py with the tree's Checked harness after D7k
  (`obj/basebin`, before D7f's landing): 15 of the 17 checks fail (no dismissal posted, no `adv_*` pairs, no
  Windows-form pair; the DOS run waits at the recommendation, so Return at 40 s closes it instead of the research
  choice).
* **ext_p0** (the staged runner through `obj/runp0.py`, `--exe` the private Checked harness, `--root obj/p0root`,
  `--port` the tree): P0_OK checks 476, the output equal to D7f's cycle's line for line (paths aside); CheckedNoObs
  `--vars V5`: P0_OK checks 62.  `adv_shown 0` in every run (CAE3540B is not Chieftain); the research choice paired
  (`abox_pair 16`) in research and research2 (V1, V2, V4d, V7): its A box at (232, 134), first row 3 (the tree's
  (142, 149), row 2); `pdos_rows` unchanged.
* **ext_mirror** (`obj/runh.py`, `--ref` the tree's build): MIRROR_OK runs 29, every MIRROR line equal to D7f's
  cycle's; **ext_replay** (`--root obj/p0root`): REPLAY_OK checks 70, equal.
* **ext_zoom** (`--exe` the private harness, `--root obj/p0root`; the tree's golden, not staged): ZOOM_OK
  combinations 32 runs 108 samples 628 map comparisons 32 centre runs 4 mzi runs 12 mzs runs 4 not zoomed 38/448,
  every ZOOM line equal to D7f's cycle's (03:41..04:07 UTC).
* **ext_timeline** (both groups), **ext_continue**, **ext_fce**, **ext_dbl** (`obj/runh.py`, the private harness),
  **ext_slots** and **ext_tld** (the tree's scripts, `--harness` the private harness, `--root` under `obj/`):
  EXT_TIMELINE_OK (53; bs 11), EXT_CONTINUE_OK (31), EXT_FCE_OK runs 8, EXT_DBL_OK checks 4, EXT_SLOTS_OK (45),
  EXT_TLD_OK (20), every PASS line equal to D7f's cycle's.
* **Not run privately**: ext_frames (no private-run option), ext_aspect, ext_bs, ext_g1 (the Windows profile's
  frames do not change), the Asan variant (deferred).
* **A frame** (`obj/run/view-dos`: the d7g-dos input to 39,500 ms with `--dump-presented`; the last show, tick 577,
  viewed, not kept as a fixture): the research choice at (234, 134)..(637, 329) on the A canvas, "Science Advisor:"
  in white with its cyan rule, the portrait at its left, DOS's three lines, the seven advances (the first
  highlighted), "(HELP AVAILABLE)" in green at the lower right; the recommendation at the lower left in DOS's
  capitals ("SCIENCE ADVISOR: / I RECOMMEND WE / DEVELOP CEREMONIAL BURIAL. / SO WE CAN BUILD: / -TEMPLE"), no "?".
  The help line's last glyph ends one column left of the frame's right outline: D7f's place (right - 4Ah in font
  2, R:1D05:077F), as DOS.
* **Host load:** the whole ext_adapt run (02:26..02:47 UTC) overlapped D7f's test step from 02:35:42 UTC (its
  landing was seen at 02:39 UTC); nothing outside `build/d7g-stage/` was written; no other heavy run started until
  D7f's ALL_GREEN (03:10:38 UTC).  The second round's private suite (`obj/suite.sh s3`, started 05:30:11 UTC) ran
  through D7n's copy-in (05:35:13), build step and test step: the stop request ended its waiting shell, not the suite.
  Its ext_adapt step (05:30..05:44) ran on the post-D6fSd binaries (kept above); its later steps ran while the overlay
  was laid again on the tree after D7n (05:49 UTC) and are void (p0 exit 127, p0 V5, replay and timeline failures
  from the mixed sources; none is a D7g result).  It held the overlay's Checked harness open (the LNK1168 above).  Its
  processes (only those with `d7g-stage` in their command line) were ended at about 06:35 UTC.  D7n's cycle stayed
  green (ALL_GREEN 06:20:13; its Landing notes D7g's private runs, no flake, no rerun).  Nothing outside
  `build/d7g-stage/` was written.

## Deviations from the brief

1. **The A places are D6fSd's** (landed before D7g): the DOS map view's origin at the map window's client origin,
   2x, then 11.3's clamp.  D7g adds only the header: a header box's drawing starts at its header frame, 42 left of and
   8 above the DOS place (R:1D05:0667..0699), so the research choice's portrait and frame lie over the Status window
   as DOS's over its side panel.  This also applies to D6fSd's other boxes when the core gives them a message picture
   (the civil war's Foreign Minister, 11A0:0387, picture 5).  D7g's first stage used the menu bar's origin (D6fS-b's
   drop-downs) instead and had to clamp the research choice at the canvas's right edge; that rule is gone.
2. **The research choice appears a few milliseconds after the recommendation** (the core's box must reach its
   MenuZ's input loop and take the posted Return), DOS draws both in one pass; not visible.
3. **The posted Return while the user's own Return is still down** (the key that closed the advance's page) carries
   the previous-state bit, as a Windows player's second press would; the core takes it the same (equal traces).
4. **The advances' names** are DOS's where the core's name is DOS's or ends with it after a space (three core names
   start with "The "); a core name without a DOS name is drawn as the core's.  The recommendation's units and
   improvements are the core's names (the same words as DOS's).
5. **Unpaired texts** (another form of the core's text, no DOS data) keep D6fSc's line rule on the core's text, in
   the same font and place; the header and the help line are drawn all the same.

## What the user checks

On the user build `build/user-builds/d7g/` (`civ64.exe`, DOS files present), in play with the DOS graphics, at
Chieftain with Instant Advice on (GAME > Options; the build's saved game `CHIEF.SAV` has both, research almost
complete: load it, switch to the DOS graphics, press Space for each unit until the turn ends, Space on the discovery
picture, Return on the advance's page).  No Go Back or Cancel row appears in these boxes.  The user's report of
2026-10-17 15:37, one check per item:

* **D7g-1** Width (item 1, "Dialog itself is too wide"): the research choice ("Which discovery should our wise men be
  pursuing, sire? Pick one...") is as narrow as DOS's, its three lines broken as DOS breaks them, the advances below
  with DOS's names, at DOS's place (its left part, with the portrait, over the Status window, as DOS's over its side
  panel).
* **D7g-2** The "Science Advisor:" title (item 2): at the top of the same box in white, with a cyan line under it.
* **D7g-3** The portrait (item 3): the science advisor's portrait at the same box's left, inside its frame.
* **D7g-4** The green "(HELP AVAILABLE)" (item 4): in green at the same box's lower right; Alt+H (or the right
  button) on an advance still opens its help ("ALT+H is ok").

The user's reports of 2026-10-17 15:41 and 15:46 (the DOS-flow recommendation):

* **D7g-5** The recommendation with Instant Advice on (15:41, "does not recommend next development when Instant
  Advice is turned on"): here at Chieftain (DOS, too, recommends only there), the advisor recommends the next
  development: at the lower left, over the Status window, a small box in DOS's capitals ("SCIENCE ADVISOR: / I
  RECOMMEND WE / DEVELOP CEREMONIAL BURIAL. / SO WE CAN BUILD: / -TEMPLE"), without a "?".
* **D7g-6** DOS's order (15:46, "adapted to DOS version logic"): the recommendation needs no key; it stays on the
  screen together with the research choice; choosing an advance (Return, or a click on a row) closes both boxes at
  once, and the game goes on as before.

More:

* **D7g-7** Escape on the research choice chooses the first advance listed (as DOS).
* **D7g-8** Other advisor messages with a portrait or a report icon, when they come up in play (the Defense
  Minister's, the Domestic Advisor's, the Foreign Minister's, a Spies, Diplomats or Travelers report), show the same
  DOS header: the title in white with its cyan line, the portrait or the icon at the left.
* **D7g-9** The Windows graphics: the recommendation waits for its OK as before, then the research choice comes;
  switching to the DOS graphics while the recommendation waits shows both DOS boxes at once.

Not part of this check: the advance's page before the research choice (still the Windows game's page), the
Civilopedia page that help opens (D7h), the production menu (D7f).

## For the records

* **DESIGN 12.x "As implemented (D7g; areas B and C)":** the header variant (`PdosMenuBox.header`, the extent); the
  science advisor's pairing (call sites 1170:29EC and 1170:286F) and the header box's A place on D6fSd's rule
  (`a_place_box`); the header from `g_messagePicture`
  for every dialog 136 and 145 MenuZ box; the recommendation's DOS flow: the posted Windows dismissal (the second I1
  exception, ruled), the held picture, I-menu/advice and `PDOS_AC_ADVICE`; Escape FIRST; the `preskin` pairs.
* **FIDELITY** (new entries, numbers to be assigned by the docs pass): F-new-1 the header variant on every dialog 136
  and 145 MenuZ box with the core's message picture (the shared numbering inferred for the callers not compared);
  F-new-2 the research choice's DOS text and DOS names (deviation 4); F-new-3 the header box's A place: D6fSd's DOS
  place less the header frame's offset (42, 8) (deviation 1); F-new-4 the recommendation in DOS's flow: the
  presentation posts the core's Windows dismissal and holds the DOS picture under the research choice, quoting the
  user's direction of 2026-10-17 15:46 verbatim: "Your implementation does indeed display next advance advisor, but
  in Windows version logic, this should be adapted to DOS version logic." (deviations 2, 3); F-new-5 Escape on the
  research choice chooses the first advance; F-new-6 the fold kept '\r' for the paired texts (the stray "?");
  F-new-7 (an observation, not D7g's) the tree's `tests/test_input.c` fails cc.cmd's clang C99 parse at line 189
  (`g_tp`'s missing `square_only` initializer); build.cmd's portable check does not cover it.
* **OPEN**: L8 (the header variant DGROUP:2F9E) resolved for dialogs 136 and 145.  P19 stands (finding (c)).
* **DOS-PROFILE.md prose** (as staged): rows 14 and 22 "extension D7g"; 1.7.2 generated (I-menu/advice, the
  escape-row's research choice).
* **RUNNING.md**: presentation-diag.log's `preskin` line's pairs adv_shown, adv_posted, adv_held, adv_ended;
  ext_adapt's d7g pairs (d7g-dos, d7g-flip, d7g-switch, d7g-esc, their Windows forms and d7g-esc-ret) and their
  edited save `CHIEF.SAV`.
* **FEATURES.md**: the DOS science advisor's boxes (research choice with header and help line; the recommendation
  in DOS's flow) and the header variant on the advisors' and reports' boxes.
* **STATUS.md**: D7g landed (rows 14, 22; the user's reports of 15:37, 15:41, 15:46); the brief's other D7g rows open.
* **manual-checklist-ext.md**: new items D7g-1..D7g-9 (above; D7g-1..4 the four items of 15:37, D7g-5 the report of
  15:41, D7g-6 the direction of 15:46).
* **Findings for the orchestrator**: (b) DOS's condition is the core's (Chieftain and Instant Advice); (c) the core
  has no counterpart of the production menu's advisor boxes: its 16 ShowInstantAdvice (10E0:077F) call sites, among
  them 1030:69AD (DISORDER) and 1040:045E (FIRSTPRODUCT) before ChooseCityProduction, are DOS's O4:02D3 instant advice
  notes (row 117, "HLP" topics, Instant Advice on and gameYear < 0), not the Military / Domestic advisor boxes that
  DOS computes per menu from PRODUCE.TXT (R:0ADE:12CD..); `g_adviceBoxFlag` is written only at 1170:2840; no PRODUCE.TXT
  use in the core: P19 stands.
* User directions 2026-10-16 (no added Go Back / Cancel rows) and 2026-10-17 (boxes as tall as their content, no
  highlight where DOS draws none, 2x): no row added; the boxes as tall as DOS's (the header frame's 61-row minimum is
  DOS's); the highlight only on the research choice's rows (DOS's bar), none on the recommendation; on A at 2x.
* Not edited by this unit: DESIGN.md, FIDELITY.md, FORMATS.md, STATUS.md, RUNNING.md, FEATURES.md, OPEN.md,
  DOS-PROFILE.md outside rows 14, 22 and 1.7.2, manual-checklist-ext.md.

## Expected changes at the build slot

Against D7n's cycle (`build/d7n-status.txt`, ALL_GREEN 06:20:13 UTC, RELEASE_OK 06:28:33; also
`build/d7g-prep/predictions.txt`):

* build.cmd checked: BUILD_OK; portable sources checked 308 unchanged (no new source); no new test program; no
  warning.
* test.cmd checked: TESTS_OK.
  * unit.log: test_pdos_ui 34 -> 48; test_pdos_reskin 209 -> 228; test_input 638 -> 644; test_dos 23,281 -> 23,283
    ("registry: 92 -> 94 tables valid"; the two tables' goldens); test_observer 126 unchanged (its call-site count
    101 -> 103); every other program unchanged.
  * registry-check: REGISTRY_OK, `ok` lines 533 -> 548; `tests/dos-decoded.txt` gains the two `table` lines
    (REPORT_SUFFIX, SCIENCE_TEXTS).
  * obs-lint: OBS_LINT_OK files 148 unchanged, probes 203, callsites 101 -> 103; obs-tables OBS_TABLES_OK 203 / 103;
    pdos-scene-check 1084 unchanged; adapters-check ADAPT_OK rows 153 -> 154, steps 27.
  * ext-adapt: EXT_ADAPT_OK checks 342 -> 359 (the d7g pairs' 17); every other PASS line unchanged.
  * ext-p0 (476), ext-mirror (runs 29), ext-replay (70), ext-zoom (ZOOM_OK combinations 32 runs 108 samples 628, the
    golden unchanged), ext-timeline (both groups), ext-continue, ext-slots, ext-tld, ext-fce, ext-dbl, ext-frames,
    ext-aspect, ext-bs: unchanged.
  * nodos NODOS_OK, 0 hits.
* ext_g1.py check: EXT_G1_OK unchanged (the Windows profile's frames do not change).
* build.cmd (Release): BUILD_OK.
* Informational, may change (not predicted to the count): presentation-diag.log's `preskin` line gains `adv_shown`,
  `adv_posted`, `adv_held`, `adv_ended` (0 in every run but the d7g pairs); ext-p0's research and research2 V-runs'
  `preskin` line (the research choice paired: `abox_pair` 0 -> 16, its A box's place and first row); coverage.txt's
  "other functions entered"; nodos's file count (this record); OBS_COST.

## Rebase notes

* **Bases.**  Staged on the tree after D7e's landing (RELEASE_OK 23:46:36 UTC) with D7f's stage (`build/d7f-stage`)
  as the base of every file D7f also stages: `pdos_ui.c/.h`, `pdos_reskin.c/.h`, `pdos_pend.c/.h`,
  `pdos_adapt.c/.h`, `pdos_adapt_tab.c`, `pdos_registry.c/.h`, `docs/dos/OFFSETS.md`, `docs/DOS-PROFILE.md`,
  `tests/dos-decoded.txt`, `gen/dos/adapters.py`, `tests/test_input.c`, `tests/harness/ext_adapt.py` (D7g reuses
  D7f's `pdos_menubox_help_line`, `PdosMenuBox.help` and `PdosRSpec.help`, and extends its rows and harness).  The
  tree for the others: `present/obs_tables.c/.h`, `gen/obs_tables.py`, `tests/harness/obs_lint.py`,
  `tests/test_pdos_ui.c`, `tests/test_pdos_reskin.c`.  Copies of the recorded bases: `obj/base`, `obj/base-d7f`.
* **D7k's landing (01:25:44 UTC) and D7f's stage rebased on it.**  Three-way merges (`obj/rebase.py`: `git merge-file
  -p`, stdout only) of every D7f-based file onto D7f's rebased stage.  Conflicts, resolved by script
  (`obj/resolve_d7k.py`, `obj/resolve_profile.py`): `pdos_reskin.c` (the includes: D7k's `pdos_scn_leader.h`, then
  D7g's `pdos_scn_report.h`; the first layout's y: D7k's `at_place` kept, `(y & 1)` otherwise; the extent: D7g's
  offsets dl/dt with D7k's `at_place` rule) and `pdos_reskin.h` (both appended: D7k's first); `DOS-PROFILE.md` rows 14
  and 22 (D7k's row text, D7g's note appended).  Generated again on the merged sources: `pdos_registry.c/.h` (94
  tables), `tests/dos-decoded.txt` (1413 lines), DOS-PROFILE.md 1.7.2 (154 rows), `present/obs_tables.c/.h` (103
  call sites).  Every recorded base was compared with its new source before the checks (all equal).
* **D7f's landing (02:30:03 UTC).**  D7f landed as staged: every recorded base (`obj/base-d7f` for the D7f-based
  files, `obj/base` for the others) equals the tree's file at 02:41 UTC, and the overlay's sources equal the tree's
  but D7g's files (only the docs `ext-D7f-record.md`, `ext-D7k-record.md` and `manual-checklist-ext.md` differ, none
  built or generated from).  The first round of results was made there (02:09..04:13 UTC).
* **D6fSd's landing (04:28:49 UTC; ALL_GREEN 05:06:44, RELEASE_OK).**  It changed four of D7g's bases:
  `present/dos/pdos_reskin.c/.h`, `tests/test_pdos_reskin.c`, `tests/harness/ext_adapt.py`.  Three-way merges
  (`obj/rebase.py d6fsd tree`), the conflicts resolved by script (`obj/resolve_d6fsd.py`), D6fSd's additions before
  D7g's where both added (RBox's fields; the section texts and the science texts; `sect_commit` and `science_spec`;
  the MenuZ probe's source note and message picture; the ShowTextDialog exit and LoadTextResource; the header's and
  the tests' blocks).  Two merges of meaning: (1) `menu_build`'s pairing: D7g's research choice and recommendation
  first (`pairing` = their pairing), else D6fSd's section rule, else D6fSc's `pdos_r_pair_text` (not for D7g's two
  pairings); (2) the A place: D6fSd's `pdos_r_dos_place` from the call's x, y (the same DOS values D7g took from the
  DOS listing) replaces D7g's own (the menu bar's origin, `PdosRSpec.a_dos`, removed); D7g's `a_place_box` passes
  D6fSd's `a_place_of` the place less the header frame's (42, 8) for a header box (deviation 1).  The N canvas keeps
  D7g's DOS place.  `ext_adapt.py` was generated again by D7g's edit script on the tree's file (only the docstring
  conflicted).  The overlay was laid again on the tree alone (D7f's stage no longer a layer) and compared: the
  tree's sources but D7g's 25 files.  A second round of results began there (05:07 UTC) and stopped at D7n's landing.
* **D7n's landing (05:35:13 UTC).**  It changed four of D7g's bases: `docs/dos/OFFSETS.md` (merged cleanly),
  `docs/DOS-PROFILE.md` (rows 14 and 22 again: D7n's row text with D7g's note appended, `obj/resolve_profile2.py`),
  `present/dos/pdos_registry.c` (generated: D7n's readers of LEADER_FACE_X and _Y) and `tests/harness/ext_adapt.py`
  (generated again by D7g's edit script on the tree's file).  Generated again in the overlay laid on the tree after
  D7n: `registry.py gen` and `goldens` (`pdos_registry.c` the stage's + D7n's two reader lists; `pdos_registry.h` and
  `tests/dos-decoded.txt` byte-equal to the stage's), `adapters.py gen` (DOS-PROFILE.md byte-equal), `obs_tables.py`
  (byte-equal).  The private suite started on the overlay after D6fSd (05:30 UTC) was not stopped in time (section
  "Results", host load); its results after the overlay was laid again (05:49 UTC) are void and not used.  The third
  round of results was made on the tree after D7n's landing + the stage (06:20 UTC onwards).  `BASE-SHA256.txt`
  records the bases (24 staged tree files, 0 differing, and this record new).
* **At the build slot**: the staged files apply as they are.  If the tree moves again first: a three-way merge of each
  moved file against the landed one (`obj/rebase.py TAG tree FILE...`), then the generators (`gen/dos/registry.py gen`
  and `goldens`, `gen/dos/adapters.py gen`, `gen/obs_tables.py`) and their checks.

## Landing

D7g landed alone at the build slot of session E4 (track B), 2026-10-18, after D7n's landing (RELEASE_OK 06:28:33 UTC,
user build `build/user-builds/d7n/`), as the orchestrator ordered at 06:30 UTC ("the slot after D7n is yours"; land
once `build/d7n-prep/LANDED.txt` and D7n's Landing section exist: both present at 06:55 UTC; no other cycle or landing
active: `build/d7n-status.txt` the newest status, RELEASE_OK, `build/d7n-prep/landed-at.txt` the newest copy-in).  The
user checks D7g-1..D7g-9 are in the user build `d7g`.

* **Rebases** (section "Rebase notes"): over D7k's and D7f's landings, D6fSd's (`pdos_reskin.c/.h`,
  `test_pdos_reskin.c`, `ext_adapt.py`; the A place on D6fSd's rule with D7g's header offset, deviation 1) and D7n's
  (`OFFSETS.md`, `DOS-PROFILE.md` rows 14 and 22, `pdos_registry.c`, `ext_adapt.py`); the generators run again on the
  overlay after D7n; the third round of private results on it (section "Results"); `BASE-SHA256.txt` written again
  (25 files, 0 differing).
* **Bases:** `build/d7g-prep/land.py` (from D7n's, with D7g's BASE-SHA256.txt format) rechecked every base
  (DRY_RUN_OK 25; build.cmd and test.cmd unchanged), took the snapshot `build/d7g-prep/before` (the tree's
  `build/test/Checked` outputs of D7n's cycle, 66 files) and `tree-before` (the 24 replaced files), and copied in at
  06:55:22 UTC (`landed.sha256`: the 24 changed files and this record; `landed-at.txt` "unit d7g"; `land-write.log`).
  Predictions `build/d7g-prep/predictions.txt`, written before the copy-in.  Scripts in `build/d7g-prep/`: `land.py`,
  `d7g-cycle.ps1`, `compare.py` and `mk_userbuild.py` from D7n's (`mk_userbuild.py` with D7g's save `CHIEF.SAV`),
  `fill_stillopen.py` from D7n's with a new group "d7n" (`mk_fill.py`).
* **The three-step cycle** (`build/d7g-prep/d7g-cycle.ps1` through Windows PowerShell, status `build/d7g-status.txt`,
  each step guarded by its log's OK marker): 1 `build.cmd checked` BUILD_OK 06:55:28..07:00:16 (288 s; portable
  sources checked 308; no warning); 2 `test.cmd checked` TESTS_OK 07:00:16..07:33:58 (2022 s; TEST_SECTIONS 30 failed
  0, wall 2019.6 s; no flake rerun); 3 `ext_g1.py check` EXT_G1_OK runs 77 (amended 1) unchanged: **ALL_GREEN**
  07:33:58.  4 `build.cmd` (Release) BUILD_OK 07:33:59..07:41:46 (467 s, no warning): **RELEASE_OK**.
* **Against the predictions** (`build/d7g-prep/compare.py` against the snapshot, `build/d7g-prep/compare.txt`: 53 of 66
  files equal, host times left out): as predicted, unit.log test_pdos_ui 34 -> 48, test_pdos_reskin 209 -> 228,
  test_input 638 -> 644, test_dos 23,281 -> 23,283 ("registry: 94 tables valid"; decoded content 1,411 -> 1,413
  lines), test_observer 126, every other count equal; registry-check REGISTRY_OK (dos-decoded 1,411 -> 1,413 lines and
  the new tables' `ok` lines); dos-decoded.txt the two `table` lines (REPORT_SUFFIX, SCIENCE_TEXTS); OBS_LINT_OK files
  148 probes 203 callsites 101 -> 103; OBS_TABLES_OK probes 203 sites 101 -> 103; ADAPT_OK rows 153 -> 154 steps 27;
  EXT_ADAPT_OK checks 342 -> 359, the new lines exactly the d7g pairs' 17 (equal to the private runs: the dismissal at
  34,003,850 / 36,020,850 us, adv 1/1/1/1 and abox_pair 16, coreinput 22 / frames 613, d7g-switch 22 / 618, d7g-esc
  25 / 613 and its memory equal to d7g-esc-ret's in 806 globals, d7g-dos-win adv_posted 0, d7f-buy adv_shown 0
  adv_posted 0), every other line unchanged; P0_OK checks 476, MIRROR_OK runs 29, REPLAY_OK checks 70, ZOOM_OK,
  EXT_FRAMES_OK, EXT_TIMELINE_OK (both groups), EXT_CONTINUE_OK, EXT_SLOTS_OK, EXT_TLD_OK, EXT_FCE_OK runs 8,
  EXT_DBL_OK checks 4, pdos-scene-check 1084, coverage.txt and the other sections unchanged.  Informational: ext-p0.txt
  did not change (its lines do not print the research runs' `preskin` pairs); nodos files 1827 -> 1829, 0 hits;
  unit.log's OBS_COST line.
* **User build** `build/user-builds/d7g/` (07:42 UTC; `build/d7g-prep/mk_userbuild.py`): `civ64.exe` (the Release
  build, SHA-256 3f503d1b...), `CIVWIN.zip` and `civdos.zip`, `CHIEF.SAV` (859de592..., 14,282 bytes; the d7g pairs'
  edited save), and `WHAT-TO-CHECK.txt` (D7g-1..D7g-9: the four items of 15:37 one check each, D7g-5 the report of
  15:41, D7g-6 the direction of 15:46; the earlier builds up to "d7n"; the 148 items still pending in the checklist at
  07:42 UTC).
* **Host load:** no private run during the cycle.  Before it, the second round's private suite ran through D7n's
  cycle (section "Results", host load; D7n's cycle stayed green).
* Not done at this slot: the checklist sections and STATUS rows (the orchestrator's) and the docs pass for D7g ("For
  the records"); the tree's CheckedNoObs and Release unit programs are not part of the cycle (the private overlay's are
  in "Results").

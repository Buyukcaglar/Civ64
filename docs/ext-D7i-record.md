# Extension phase D7, unit D7i (the newspaper, New Cabinet, the discoveries and the quiz) - record

Draft for the build slot (docs/verify/BRIEF-d7.md unit D7i: rows 101, 119, 23, 24 and 26; F1..F5, T20, P7, E18 and the
discovery's 180-frame fade-in as TX; decisions 5 and 6, rulings 3, 5, 6 and 15; extension session E4).  Staged in
`build/d7i-stage/` on the tree after D7g's landing (copy-in 06:55:22 UTC, ALL_GREEN 07:33:58 UTC, RELEASE_OK 07:41:46
UTC, 2026-10-18): each base copied as its first edit began (`obj/base-at-copy.txt` with the times, 07:02..08:25 UTC);
`docs/DOS-PROFILE.md` merged three ways onto the docs pass e4i (07:47:23 UTC; section "Rebase notes"); every base is
the tree's file now, rechecked in `BASE-SHA256.txt`.  Stacked on D7h (PDOS_AS 64 bits, PDOS_AS_PEDIA bit 32): D7i
needs no AS bit.  Rebased onto D7h's landing (copy-in 09:15:07 UTC, LANDED 2026-10-18; section "Rebase notes"): the bases are the tree after D7h now.
Private builds and runs in `build/d7i-stage/obj/` only: an overlay `obj/src` = the tree + the stage (`obj/mkoverlay.py`;
`obj/sync.py` lays later stage edits over it; `obj/ovcheck.py` compares it with the tree and the stage), built with the
tree's build.cmd and flags (`obj/b.cmd`, `--nogen`), cc.cmd's stricter checks per file (`obj/cc.cmd`), the unit
programs (`obj/unit.py`) and the harness runs from the overlay's binaries with every output under `obj/`; the tree's
build/gamedata, dosdata, dos/disasm and cache read only.

## Result

D7i is staged and privately verified.  With the DOS graphics:

* **The discovery** (rows 23 and 24, CompleteResearch's dialog 146 / 147) is DOS's R:0ADE:1584: `DISCOVR1.PIC` (or
  `DISCOVR2.PIC`) full screen with its own palette at once, DOS's sentence ("Roman wise men / discover the secret / of
  Masonry!": DOS's words and line breaks, the core's adjective and advance, the advance in DOS's spelling) as a
  frameless box at (96, 1) in font 6 (DISCOVR2: (96, 25) in the font in effect), the advance's ICONPG cell centred at
  (174, 96) (DISCOVR2: (174, 87)), then the 30-step fade (180 frames, TX) from the picture's palette to
  `ICONPG1.PAL` with DISCOVRn's colours 0..84, which brings the cell's colours in.  A key or a click ends it.
* **The newspaper** (row 101, ShowNewspaper with a mode other than -2) is DOS's O21:0000 over the A frame (ruling 5,
  decision 5 (c)): the strip (0, 0, 320, 100) with its rules, the masthead in font 5 with DOS's two ornaments beside a
  name narrower than 200 pixels, the corner tags, price, date and slogan, the headline wrapped by R:1F4D:0088, the torn
  edge (16 shapes at 100 - random(2), `pdos_rand`) and the "Press any key to continue." box at (80, 128), as A elements
  at 2x at DOS's places from the DOS map view's origin, the Windows newspaper hidden by a cover from its show; the map
  shows beneath.  A discovery's newspaper (Instant pictures off) takes DOS's sentence as its headline.  Over an N scene
  the same drawing goes on page 0 (saved and restored).
* **New Cabinet** (row 119, AnnounceGovernmentChange's ShowNewspaper(-2)) is DOS's O5:1BA2: the newspaper without its
  edge and box, the bottom half white, "New Cabinet" in font 6 and the four advisors' portraits of the government now
  with DOS's titles (DEFENSE MINISTER, DOMESTIC ADVISOR, FOREIGN MINISTER, SCIENCE ADVISOR) at alternating heights.
* **The quiz** (row 26, AskCivilizationQuizQuestion's dialog 149) is DOS's O16:002C: the 0FDh background, the title,
  KING.TXT's QUIZ / QUIZ2 in red and DOS's two question lines, the asked advance's cell, the pages line, the answers as
  a frameless DOS box at (100, (Y0 + 32) | 1) without title (the core's MenuZ, re-skinned, its rows in DOS's spelling,
  kept drawn after the answer as DOS's page 0 keeps it), then CORRECT in blue or INCORRECT in red at the top.

No core change, no core random draw (the torn edge's `pdos_rand`, B11), no new owner (the shadow owner "report"
delegates to `pdos_news_claim`; 9 of PDOS_OWNER_MAX 10 stay used), no new PDOS_AS bit, adapter-table row or scene-table
row (the scenes use I-wait, the quiz's answers the re-skinned box's I-menu, the A newspaper the A view's I-pass).  No
Go Back or Cancel row anywhere (the DOS rule): none of these screens has one in DOS or here.

## Status

LANDED 2026-10-18 (copy-in 10:25:44 UTC, ALL_GREEN 11:00:39 UTC, RELEASE_OK 11:04:25 UTC; section "Landing"), after
D7h's landing, with the rebase of section "Rebase notes".  The user checks D7i-1..D7i-6 are pending.

## What was built

### The renderer (`present/dos/pdos_scn_news.c/.h`, new)

* Pure drawers (the machine, the pictures and the texts are the caller's): `pdos_news_draw` (O21:0000's steps, the
  torn edge from a given `PdosRand`), `pdos_news_box` (R:1D05:0018's box), `pdos_news_cabinet` (O5:1BA2's lower half),
  `pdos_news_cell` / `_cell_rect` / `_cell_draw` (O8:16C4's first match, O8:16F7's cell of ICONPG<1 + c / 9>, clipped
  as O8:16F7 clips), `pdos_news_disc_text` (DOS's sentence), `pdos_news_disc_page` (the discovery's page).
* The run (`pdos_news_reset` / `_on_event` / `_on_probe` / `_present` / `_advance`, called from `pdos_profile.c`):
  * row 101 at ShowNewspaper's entry: the headline from g_messageText (a discovery's: DOS's sentence), the core's
    masthead, tag, price and date at their draws, the slogan KING.TXT's section of the core's name (D6fSd's pairing),
    else the core's text; drawn at the core's CopyPortToWindow; over the A frame three A elements (strip 0xFF40, edge
    0xFF41, box 0xFF42) placed at every present, the window covered from its show (D6fS-a's `pdos_r_cover_*`) and the
    elements removed at its hide; over an N scene on page 0 (rows 101 and 25 ready);
  * row 119: an N frame, the play palette, page 0 saved and restored, the portraits by `pdos_report_portraits`;
  * rows 23 and 24 at GR_DialogOpen (1170:246D): the page at once, the fade on a TX timeline (`pdos_tl_fade`, 30 steps,
    the session's first-fade extra frame not applied, M4) bound to the N machine, logged `fade` and `disc_faded`;
  * row 26 at GR_DialogOpen (1178:003C): each part at the core's call that draws its counterpart (title, KING
    section, picture, pages, MenuZ), the answers through `pdos_reskin_rows_only` and the quiz dialog's anchor;
  * each scene's window claimed (logical) and its drawing absorbed, the bitmaps made while it runs declined; the end
    at the window's destruction (the quiz's last screen with the exit kind R:0238:1B44, the others none);
  * `pdos_news_waits` / `pdos_news_wnd` for the adapter, `pdos_news_pointer_hidden` for the pointer (hidden on the
    newspaper and the discovery and while the quiz does not ask, as DOS; shown on New Cabinet's wait).
* Counters (presentation-diag.log's new `news` line): news, news_a, cabinets, discs, disc_fades, quizzes, quiz_texts,
  dos_texts, core_texts, cells, cell_none, pic_missing, ends, absorbed, declined, unread.  Steps (timeline.log,
  sequence 3): `news` (arg the row), `news_shown` (arg 1 on the A canvas), `news_end` (arg the exit kind), `fade`
  (R:0ADE:198C, 30), `disc_faded` (R:0ADE:1991).

### Shared files

* `present/dos/pdos_reskin.c/.h`: `pdos_reskin_rows_only(ra, row)`: the MenuZ call returning to `ra` shows its items
  only (no header lines, no header picture), each row through `row` (the quiz's: "<advance> and <advance>" in DOS's
  spelling), bound to the dialog it runs in (the quiz's own dialog 149, an N row: no class R row binds it), kept
  drawn whole after its items go.  Defined without the observer too (no effect).
* `present/dos/pdos_adapt.c`: the frame-1 scene I-wait (class X, the scene's window) while `pdos_news_waits()`, before
  the re-skinned box's check (the quiz's answers box stays drawn after the answer).
* `present/dos/pdos_scn_report.c`: the owner "report" asks `pdos_news_claim` first and gives the news scene's window
  and bitmaps to it (`pdos_news_owns`, `pdos_news_absorb`).
* `present/dos/pdos_profile.c`: the reset, event, probe (entries and exits), present and advance calls; the pointer
  hidden with `pdos_news_pointer_hidden()`.  `present/dos/pdos_seq.c`: the step log.  `tests/headless/harness.c`: the
  `news` diag line.
* Registry (`docs/dos/OFFSETS.md`, `gen/dos/registry.py`'s OBSERVER_FILES): NEWS_ORNAMENT (DGROUP:5147, 2 strings,
  O21:023E, O21:0255), NEWS_PRESS (DGROUP:5181, O21:03F3), DISCOVERY_TEXTS (DGROUP:22CC, 5 strings, R:0ADE:17B4,
  17B9, 17C9, 17F7, 182C), QUIZ_TEXTS (DGROUP:4A61, 2 strings, O16:0167, O16:0181); `pdos_registry.c/.h` and
  `tests/dos-decoded.txt` regenerated (four `table` lines).
* `docs/DOS-PROFILE.md`: rows 23, 24, 26, 101, 119, P7, T20, E18 and F1..F5 "as implemented in D7i"; no core call
  address of a probe key named (OBS_TABLES_OK sites unchanged).

## Files

Changed (`BASE-SHA256.txt`): `present/dos/pdos_adapt.c` (CRLF), `pdos_profile.c` (CRLF), `pdos_seq.c` (CRLF),
`pdos_reskin.c/.h`, `pdos_scn_report.c`, `pdos_registry.c/.h` (generated), `tests/headless/harness.c` (CRLF),
`tests/harness/ext_adapt.py`, `tests/harness/ext_timeline.py`, `tests/dos-decoded.txt` (generated),
`gen/dos/registry.py`, `docs/dos/OFFSETS.md`, `docs/DOS-PROFILE.md`.  New: `present/dos/pdos_scn_news.c/.h`,
`tests/test_pdos_news.c`, this record.  build.cmd and test.cmd unchanged (build.cmd compiles `present\dos\*.c`: portable
sources 308 -> 309; test.cmd runs every `test_*.exe`: one more program).  Unchanged, though the brief's area: 
`pdos_scene_tab.c` (rows 23, 24, 26, 101, 119 exist), `pdos_adapt_tab.c` (the I-wait, I-menu and I-pass rows exist),
`pdos_shadow.h`, `pdos_fx.c`, `pdos_tl.c`.  The D7i parts of the shared files are one-line hunks or blocks with an
`extension D7i` comment.  No BUILD-TEST-ADDITIONS.md.

## Tests

* `tests/test_pdos_news.c` (new; 74 checks in Checked): a synthetic six-font set, synthetic pictures, palettes, tables
  and texts, every query injected (no DOS data, no emulation): the newspaper's steps (fills, rules, ornaments, masthead,
  tag, price, date, slogan, headline, the edge's 16 draws and its determinism per ordinal, New Cabinet without the edge,
  the ornaments' 200-pixel rule), the box (framed, frameless at an odd y), New Cabinet's portraits and titles, the cell
  lookup and rectangle (clip at x 319, the left edge), the sentence, the discovery page and the recipe, then through the
  module: the A newspaper (claims, absorb, decline, the end at the window's destruction, no exit kind), the newspaper
  over an N scene (page 0 drawn and restored), New Cabinet, the discovery (rows 23 and 24, the fade reaching the recipe
  180 frames later, the end), a discovery's newspaper (DOS's sentence as headline), the quiz (rows, texts, cell, the
  exit kind 1B44 once).
* `tests/harness/ext_adapt.py`, the d7i runs (5 DOS-form runs, 5 Windows-form pairs, 29 checks): edited copies of
  CAE3540B.SAV (D7I_BASE: civ 2 out of aliveCivsMask, Chieftain):
  * d7i-disc (civResearchProgress[1] 4000h): a left press at 36 s ends the discovery (I-wait/press, one click at the
    dialog's point), the pair equal; timeline.log news 23 at the opening, the fade from it, disc_faded 180 frames later
    (t0 + pdos_frame_us(180)), news_end after the press; the 320x200 N frame; the `news` counts;
  * d7i-disc-early: Space at 32 s, during the fade (I-wait/key): the discovery ends, no disc_faded;
  * d7i-news (gameOptions bit 3 cleared: ShowNewspaper(-1)): Space at 34 s (I-pass/key on the A frame); news 101,
    news_shown 1, the A frame, news_a 1, dos_texts 2 (DOS's sentence, DOS's slogan);
  * d7i-cab (byte 714h 0: Anarchy ends at turn 24): Return on the government menu (I-menu/return-escape), Space at 36 s
    (I-wait/key); news 119 (O5:1BA2), the N frame, cabinets 1;
  * d7i-quiz (gameTurn 49): Return on the answers (the re-skinned box: I-menu/return-escape), Space at 35 s on the
    result (I-wait/key); news 26 (O16:002C), news_end exit kind 1, the return R:0238:1B44, the N frame, quizzes 1,
    quiz_texts 2, cells 1;
  * each Windows-form pair: the core outputs equal, and the same `news` counts (the DOS scenes are kept behind the
    Windows graphics for a switch).
  * D7G_ROWS: the discovery's Space at 32 s is now I-wait/key (DOS's discovery); the next two stay D7h's
    I-pedia/page-key (the advance's DOS Civilopedia page).
* `tests/harness/ext_timeline.py`, the discovery run (`--graphics dos`, DISCOVER.SAV, 37 s, 4 checks): the open
  (R:0ADE:1584, row 23, frame 0), the fade (R:0ADE:198C, 30) from frame 0 and `disc_faded` at frame 180 at
  t0 + pdos_frame_us(180), the end at the key, the N frame during it, then the advance's DOS Civilopedia page
  (D7h's `pedia_page` O8:062A at the end).

## Results (private, `build/d7i-stage/obj/`)

Session E4 (2026-10-18), on the overlay `obj/src` = the tree after D7g's landing and the docs pass e4i + the stage
(08:16..09:40 UTC); the bases of `BASE-SHA256.txt` rechecked (BASESHA_OK, 19 staged files).

* **Builds** (`obj/b.cmd`, the tree's build.cmd and flags with `--nogen`): Checked, CheckedNoObs and Release
  BUILD_OK, portable sources 309 (08:41..09:01 UTC); the later one-file edits recompiled by `obj/co.cmd` and the
  Checked harness relinked (`obj/hl.cmd`).
* **cc.cmd** (c11 and c17 /W4 /WX and the clang C99 parse) on `pdos_scn_news.c`, `pdos_reskin.c`, `pdos_adapt.c`,
  `pdos_scn_report.c`, `pdos_profile.c`, `pdos_seq.c`, `tests/test_pdos_news.c` and `tests/headless/harness.c`, each
  variant: CC_OK.
* **Unit** (`obj/unit.py`, the tree's build/gamedata read only): 65 programs (test_ne aside) in Checked,
  CheckedNoObs and Release; all pass but test_dos, whose one failing check compares its decoded content with the tree's
  `tests/dos-decoded.txt` (the program finds the golden beside the tree's gamedata): its output equals the staged,
  regenerated golden exactly in each variant (1,417 lines: the four new `table` lines), every other check passes
  (23,287 checks: the four tables valid).  test_pdos_news 74 in each variant.  Against D7g's cycle (`obj/cmpunit.py`,
  `build/docs-e4i-stage/d7g-out/unit.log`) every other Checked count is equal (52 programs compared; test_pdos_reskin
  228, test_pdos_report 229).
* **Checks** on the overlay: `registry.py check` (`--dosdata`, `--disasm` of the tree's build, read only)
  REGISTRY_OK, 568 `ok` lines (the tree's 548 + the four tables' 18 lines and the two include rules); `registry.py
  gen` and `goldens` in the overlay give the staged `pdos_registry.c/.h` and `tests/dos-decoded.txt`;
  `obs_lint.py` OBS_LINT_OK files 150 (148 + pdos_scn_news.c/.h) probes 203 callsites 103; `obs_tables.py --check`
  (`obj/obstab.py`) OBS_TABLES_OK probes 203 sites 103 (no call address of a probe key in the DOS-PROFILE prose);
  `pdos_scene_check.py` PASS 1084 checks, 141 scene rows; `adapters.py check` ADAPT_OK rows 154 steps 27; `nodos.py
  check` (`--dos` and `--windows` the tree's build/dosdata and build/gamedata) NODOS_OK, 1,084 files, 0 hits.
* **ext_adapt, the whole suite** (`obj/runadapt.py ... all`: the staged ext_adapt.py's main with the private Checked
  harness, 08:25..08:39 UTC): EXT_ADAPT_OK checks 388 (D7g's cycle 359 + the 29 d7i checks; the d7g pairs with the
  discovery's Space as I-wait/key pass).  Then, after the last two source edits (a discovery's newspaper headline, the
  quiz's answers kept), the sets d7i and d7g again (08:48 UTC): the 29 d7i checks and the 16 d7g checks pass (d7f-buy's
  check reads a d7f run, not in the subset).  The d7i lines: d7i-disc decided by I-play/key x 4 and I-wait/press (one
  click at the dialog's point (320, 240)), the pair equal (coreinput 15, frames 569); news 23 at 31,142,850 us, the
  fade (30) there, disc_faded at 33,711,042 us (frame 180), news_end at 36,001,850 us; 152 N-frame shows; discs 1,
  disc_fades 1, cells 1, dos_texts 1, core_texts 0.  d7i-disc-early: news_end at 32,001,850 us, no disc_faded.
  d7i-news: I-pass/key, news 101 and news_shown 1 at 31,142,850 us, news_end at 34,001,850 us, 14 A-frame shows,
  news_a 1, dos_texts 2.  d7i-cab: I-menu/return-escape and I-wait/key, news 119 (O5:1BA2) at 33,002,850 us, news_end
  at 36,001,850 us, cabinets 1.  d7i-quiz: I-menu/return-escape (the answers box) and I-wait/key, news 26 (O16:002C)
  at 31,142,850 us, news_end exit kind 1 at 35,001,850 us and the return R:0238:1B44, quizzes 1, quiz_texts 2,
  cells 1.  Every Windows-form pair equal and with the same `news` counts.
* **ext_timeline, the base group** (the staged ext_timeline.py with the private Checked harness, `--root obj/tlroot`,
  the tree's build read only, 08:49..08:52 UTC): EXT_TIMELINE_OK, 65 PASS lines (60 + the discovery run's 5): the open
  at 31,142,850 us, the fade from frame 0, disc_faded at frame 180 (33,711,042 us), the end at 36,001,850 us, 153
  N-frame shows during it and 6 A-frame shows after it (before D7h's page; after the rebase the page check, below);
  the palace, space and conquest runs unchanged.
* **ext_p0 and ext_mirror, the subset** (the tree's unchanged ext_p0.py / ext_mirror.py with the private Checked harness, `--root obj/p0root`, the tree's build read only, after D7h's test step, 09:42..09:43 UTC; `obj/p0run.sh`): `--vars V0,V1,V2 --only retire,conquest,arrival` P0_OK checks 21 (V0 equal to ext-g1-baseline, V1/V2 equal to V0, the switch assertions and the D4..D6 row counters 0); ext_mirror `--only retire,conquest,arrival` MIRROR_OK runs 3, checks 1,074, present_mismatched 0, unexplained 0, dos_mismatched 0, dos_unexplained 0.
* **After the rebase onto D7h** (the overlay rebuilt on the tree after D7h's copy-in, 09:50 UTC; the tree's build
  read only; outputs under `obj/`):
  * builds: Checked, CheckedNoObs and Release BUILD_OK, portable sources 310 (D7h's 309 + 1), 09:52..10:04 UTC;
  * cc.cmd on the merged `pdos_adapt.c`, `pdos_profile.c`, `pdos_seq.c`, `pdos_registry.c`, `tests/headless/harness.c`,
    each variant: CC_OK;
  * unit, each variant: 66 programs, all pass but test_dos's golden-path check (its output equals the staged
    regenerated golden but the header); test_dos 23,291 (D7h's 23,287 + 4), test_pdos_news 74; against D7h's cycle
    (`build/d7h-2-test-checked.log`, `obj/cmpunit.py`) 53 other programs equal;
  * REGISTRY_OK 592 `ok` lines (the tree after D7h 572 + 20), `tests/dos-decoded.txt` 1,426 lines (1,422 + 4);
    OBS_LINT_OK files 152 (150 + 2) probes 203 callsites 103; OBS_TABLES_OK 203 / 103; pdos_scene_check PASS 1084;
    ADAPT_OK rows 161 steps 27 (as the tree); NODOS_OK;
  * ext_adapt, the whole suite (10:06..10:18 UTC): EXT_ADAPT_OK checks 393 (D7h's cycle 364 + the 29 d7i checks);
  * ext_timeline, the base group: EXT_TIMELINE_OK, 65 PASS lines, after one check changed: the discovery is now
    followed by D7h's DOS Civilopedia page of the advance (`pedia_page` O8:062A at the end, 36,001,850 us, the N
    frame), as DOS (the page follows the discovery), no longer the A frame.
* **Frames looked at** (private dumps with `--dump-presented`, `obj/explore.py`, `obj/shot.py`, PNGs in
  `obj/run/shots/`): the discovery at its opening (the picture with its palette, the blank board, DOS's three lines)
  and after the fade (the Masonry cell on the board); the A newspaper (strip, ornaments, masthead "Rome Today", tags,
  date, price, slogan, DOS's three-line headline, the torn edge, the box over the map); New Cabinet ("Roman government
  changed to Despotism!", "New Cabinet", the four portraits and titles at alternating heights); the quiz (the answers
  box at (100, (Y0 + 32) | 1) frameless with the first row highlighted; after the answer CORRECT's text in blue with the answers
  kept).  A wrong first answer (Down, Return) runs the second question at once (QUIZ2), as O16:04AC.

## Deviations from DOS and the ruling

1. **The texts are the core's** (ruling 6): the newspaper's headline (but a discovery's, DOS's sentence), masthead,
   tag, price and date, New Cabinet's title, the quiz's title, question, answers and pages line; folded to DOS bytes
   and, for the advances, put in DOS's spelling (D7g's `pdos_r_dos_advance`).  The words DOS has of its own are DOS's:
   the ornaments, "Press any key to continue.", the discovery's sentence, the quiz's two question lines, the KING.TXT
   sections (QUIZ, QUIZ2, CORRECT, INCORRECT, the slogans by name, D6fSd).  The core's newspaper headlines keep the
   core's line breaks, wrapped by R:1F4D:0088 at 40 columns.
2. **No R:0238:1B44 before New Cabinet**: DOS fades the play screen out before O5:1BA2; the core goes on at once, so
   the cabinet shows at once (the play palette).
3. **Input during the discovery's fade passes**: a key or click during the 180 frames ends the discovery at once (DOS
   reads it at R:0ADE:1994 after the fade); the fade is abandoned with the scene.
4. **The discovery's research choice** follows over the play screen (D7g's A box), without R:0238:1B44 after it (the
   core's order: the choice box after the page).
5. **The quiz's question and answers are the core's** (its choice of advances and answers); "Pages" is the core's
   text at DOS's place.
6. **DISCOVR2's text font is inferred**: DOS keeps the font in effect (R:0ADE:1861..1869 sets font 6 for DISCOVR1
   only); font 1 is taken.
7. **The slogan is paired by name** (D6fSd): KING.TXT's section of the core's slogan name; else the core's text.
8. **The masthead's width rule**: DOS's " News" width fallback (O21's second masthead form) is not applied: the core's
   choice of name form is kept.
9. **Between the quiz's two questions** (a wrong first answer: no INCORRECT, the second question at once, O16:04AC)
   the A frame may show for one present before the second question's N frame.
10. **The A newspaper's wait is the A view's I-pass** (any key or left press passes; the core's WaitForKeyOrClick
    1038:0C2A ends at any WM_CHAR or WM_LBUTTONDOWN, in any window), not a frame-1 I-wait; DOS-PROFILE row 101's
    I-wait holds over an N scene.
11. **No new PDOS_AS bit, owner, adapter or scene-table row**; `pdos_scene_tab.c`, `pdos_adapt_tab.c`, `pdos_fx.c`
    and `pdos_tl.c` unchanged.

## What the user checks

On the coordinator's user build (D7i landed; `civ64.exe`, DOS files present), with the DOS graphics
(Ctrl+Shift+Backspace or the window menu).  Four save files in the user build's folder (copies of the test save, as the
automatic tests use them): copy them to your saves folder (%LOCALAPPDATA%\civ64\CivWin) yourself, load each with Load a
Saved Game in the title menu, switch to the DOS graphics once the map shows, and press Space for each of the four units
until the turn ends.

* **D7i-1** The discovery: load DISCOVER.SAV.  After the units, a full-screen picture: a man in a white robe at the
  left, a blank board in the middle, and at the top in large white letters on three lines "Roman wise men / discover
  the secret / of Masonry!".  Over about two and a half seconds the colours change and a picture of a red brick wall
  with a trowel appears on the board.  A key or a click goes on (the advance's page and the research choice follow).
* **D7i-2** The newspaper: load NEWSPAPR.SAV (the same game with the discovery pictures turned off).  After the units,
  over the map at the top: the DOS newspaper, "Rome Today" (or "Rome Weekly") in the middle of the masthead with a
  bird ornament on each side, "EXTRA!" (or "FLASH") in both corners, the date at the left and the price at the right,
  a one-line slogan above the masthead, the headline "Roman wise men / discover the secret / of Masonry!" in large
  letters, a torn lower edge, and below it over the map the box "Press any key to continue.".  The map stays visible
  below the paper.  A key closes it; the map comes back as it was.
* **D7i-3** New Cabinet: load CABINET.SAV.  After the units the game asks which government to choose: press Return.
  The screen shows the newspaper with "Roman government changed to Despotism!" at the top and, below it on white,
  "New Cabinet" with four portraits side by side and under them DEFENSE MINISTER, DOMESTIC ADVISOR, FOREIGN MINISTER
  and SCIENCE ADVISOR (the second and fourth a little lower).  A key goes on.
* **D7i-4** The quiz: load QUIZ.SAV.  After the units: "CIVILIZATION QUIZ" at the top, a red paragraph ("A usurper
  claims ..."), two black lines asking which advances lead to the advance pictured, the advance's picture at the left,
  "Pages ..." at the bottom left and, in the middle, a list of answer pairs without a frame or title, the first one
  highlighted, with the mouse pointer.  Choose the first answer (Return): at the top "Congratulations, you have proven
  your worthiness. ..." in blue; the answers stay on the screen; a key goes on.
* **D7i-5** The quiz's wrong answer: load QUIZ.SAV again and choose another answer (Down, then Return): a second
  question follows at once (a different red paragraph); after its answer the result at the top (blue
  "Congratulations ..." or the red INCORRECT text), then a key goes on.
* **D7i-6** The same saves with the Windows graphics: the Windows game's discovery, newspaper, New Cabinet and quiz,
  unchanged.  No Go Back or Cancel row appears on any of the DOS screens of D7i-1..D7i-5.

Not part of this check: switching the graphics while one of these screens shows.

## For the records

* **DESIGN** (12.x, the renderers' "As implemented"): D7i adds `pdos_scn_news` for rows 23, 24, 26, 101 and 119: N
  views from the scenes' dialogs (101 over the A frame as A elements under ruling 5, with a cover), the drawing pure
  and DOS's (O21:0000, O5:1BA2, R:0ADE:1584, O16:002C), the discovery's fade on a TX timeline, the scene's window
  claimed through the owner "report" (no new owner), the quiz's answers the re-skinned MenuZ box of the quiz's own
  dialog (`pdos_reskin_rows_only`), the waits I-wait.  No PDOS_AS bit, owner, adapter or scene-table row.
* **FIDELITY** (new entries; numbers by the docs pass):
  * F-new-1: the newspaper's, New Cabinet's and the quiz's texts are the core's (folded, advances in DOS's spelling);
    DOS's own words where DOS has them (deviation 1); a discovery's newspaper headline is DOS's sentence.
  * F-new-2: no R:0238:1B44 fade before New Cabinet (deviation 2).
  * F-new-3: a key or click during the discovery's fade ends it at once (deviation 3).
  * F-new-4: DISCOVR2's text font inferred (font 1, deviation 6); the masthead's " News" fallback not applied
    (deviation 8).
  * F-new-5: between the quiz's two questions the A frame may show for one present (deviation 9).
* **SCENES-PLAY 7.11** (corrections, DOS listing): the text is in font 6 with DISCOVR1 only (R:0ADE:1861..1869; with
  DISCOVR2 DOS keeps the font in effect); the fade starts from the picture's own palette (R:1FA1:026C at R:0ADE:1764),
  not from black; the wait for a key or click is R:1459:0918 at R:0ADE:1994, after the fade.  The newspaper branch
  (O21(-1)) uses the same DGROUP:BA06 sentence (built at R:0ADE:178C..1834 for both branches).
* **SCENES-PLAY 7.15**: the quiz's first wrong answer goes to the second question without INCORRECT (O16:04AC: only
  the second question shows it); the answers box (R:1D05:0018 at O16:0442) stays on page 0 under the result.
* **DOS-PROFILE** (staged): rows 23, 24, 26, 101, 119, P7, T20, E18, F1..F5 "as implemented in D7i".
* **OFFSETS** (staged): NEWS_ORNAMENT, NEWS_PRESS, DISCOVERY_TEXTS, QUIZ_TEXTS and the note on the D7i rows.
* **An id collision found** (not D7i's): `PDOS_R_HELD_ID` (`pdos_reskin.h`, D7g) and `PDOS_APLAY_NUKE_ID`
  (`pdos_aplay.h`, D7n) are both 0xFF30 on the A canvas; they never coexist in the runs (the recommendation's held
  picture and the nuclear explosion), but one would replace the other.  D7i's A ids are 0xFF40..0xFF42.  For the
  orchestrator's queue.
* **RUNNING**: presentation-diag.log's new `news` line; timeline.log's steps `news`, `news_shown`, `news_end`,
  `disc_faded` and the discovery's `fade` (R:0ADE:198C); ext_adapt's d7i runs (`d7i-disc`, `d7i-disc-early`,
  `d7i-news`, `d7i-cab`, `d7i-quiz`, each `-dos` and `-win`); ext_timeline's `discovery` run.
* **FEATURES**: with the DOS graphics the discoveries, the newspaper, New Cabinet and the quiz are DOS's.
* **STATUS / checklist**: D7i done (the user checks D7i-1..6 pending).

## Expected changes at the build slot

Against D7h's landing (its cycle `build/d7h-*.log`):

* **Build**: portable sources 309 -> 310 (`present/dos/pdos_scn_news.c`); the three variants BUILD_OK.
* **Unit**: one more program (`test_pdos_news`, 74 checks); test_dos 23,287 -> 23,291 (the four new tables:
  NEWS_ORNAMENT, NEWS_PRESS, DISCOVERY_TEXTS, QUIZ_TEXTS) and `tests/dos-decoded.txt` 1,422 -> 1,426 lines; every other
  program's count equal.
* **Generators**: REGISTRY_OK 572 -> 592; OBS_LINT files 150 -> 152, probes 203 and call sites 103 unchanged;
  OBS_TABLES 203 / 103, pdos_scene_check 1084 and ADAPT_OK rows 161 steps 27 unchanged (no scene or adapter row);
  NODOS_OK.
* **ext_adapt**: EXT_ADAPT_OK 364 -> 393 (the d7i runs' 29); `D7G_ROWS`' discovery Space I-pass/key -> I-wait/key.
* **ext_timeline**: + 5 PASS lines (the `discovery` run); the other runs unchanged.
* **ext_p0 / ext_mirror / ext_g1**: unchanged (no core change; the Windows-form outputs equal; the torn edge draws
  `pdos_rand`); EXT_G1_OK runs 77.

## Rebase notes

* **Done: the docs pass e4i.** `docs/DOS-PROFILE.md` changed in the tree after D7i's copy (e4i, applied 07:47:23 UTC):
  merged three ways (`git merge-file -p` to stdout, read only; base `build/docs-e4i-stage/before/docs/DOS-PROFILE.md`,
  3f076529...; `obj/rebase-e4i/`), no conflict; the result checked equal to the stage; the base is the tree's file
  after e4i.
* **Done: D7h's landing** (09:45..09:50 UTC; `obj/rebase_d7h.py`, `obj/resolve_d7h.py`, every input and result in
  `obj/rebase-d7h/`; the stage before it in `obj/stage-before-d7h/`).  D7h changed 11 of D7i's staged files.  Eight
  merged three ways (`git merge-file -p` to stdout, read only): base `build/d7h-prep/tree-before` (each equal to D7i's
  recorded base by SHA-256), theirs the tree after D7h's copy-in, mine the stage.  `docs/DOS-PROFILE.md`,
  `gen/dos/registry.py` and `present/dos/pdos_adapt.c` merged clean; `docs/dos/OFFSETS.md` (1), `pdos_profile.c`
  (4), `pdos_seq.c` (1), `tests/harness/ext_adapt.py` (3) and `tests/headless/harness.c` (1) had conflicts where
  both units appended at the same place: resolved with D7h's lines first, then D7i's (the tables, the reset /
  event / probe calls, the log hook, the diag line, the docstring paragraph, `d7h_runs` then `d7i_runs`), and two by
  hand: the pointer rule's last line (`pdos_pedia_pointer_hidden() || pdos_news_pointer_hidden()`) and `D7G_ROWS`
  (`I-wait/key` for the discovery, D7h's two `I-pedia/page-key`).  `pdos_registry.c/.h` and
  `tests/dos-decoded.txt` regenerated (`registry.py gen` / `goldens` on the merged files), not merged.  In
  `pdos_adapt.c` D7h's I-pedia branch comes before D7i's I-wait branch (the Civilopedia over every box).  D7h's
  other files are read only to D7i; `pdos_reskin.c`'s MenuZ binding keeps `!pdos_rdlg_owns(...)` with D7h's
  `pdos_rdlg.c`.  One D7i test changed with it: ext_timeline's discovery check (the advance's DOS Civilopedia page,
  D7h's, follows the discovery as in DOS, not the A frame).
* **The cell copy.** D7h's `pdos_scn_pedia.c/.h` has `pdos_pedia_cell` / `pdos_pedia_cell_rect` /
  `pdos_pedia_copy_rect` (the ICONPG cells); D7i's `pdos_news_cell` does the same lookup for its own cells and stays
  D7i's own (identical results, its checks in `test_pdos_news`).  A shared helper is a later cleanup (D8's open list).

## Landing

Landed 2026-10-18 by the build slot, after D7h's (`build/d7h-prep/LANDED.txt`), with the rebase of section "Rebase
notes" (D7h's copy-in 09:15:07 UTC, its RELEASE_OK 09:55:27 UTC).

* **Copy-in** 10:25:44 UTC (`build/d7i-prep/land.py --write`): 19 files byte for byte (15 changed, every base equal to
  the tree; 4 new: `pdos_scn_news.c/.h`, `tests/test_pdos_news.c`, this record), the tree's previous files in
  `build/d7i-prep/tree-before`, the Checked test outputs before in `build/d7i-prep/before`, the list in
  `build/d7i-prep/landed.sha256`; build.cmd and test.cmd unchanged.
* **The cycle** (`build/d7i-prep/d7i-cycle.ps1 -LastStep 4`, `build/d7i-status.txt`):
  * 1 build.cmd checked: BUILD_OK, 214 s (10:25:54..10:29:27), portable sources 310 (D7h 309);
  * 2 test.cmd checked: TESTS_OK, 1,871 s (10:29:28..11:00:39);
  * 3 ext_g1.py check: EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events), as D7h; ALL_GREEN;
  * 4 build.cmd (Release): BUILD_OK, 226 s (11:00:39..11:04:25); RELEASE_OK.
* **Against D7h's cycle** (`build/d7h-*.log`): unit programs 41 -> 42 PASS lines (test_pdos_news 74 checks);
  test_dos 23,287 -> 23,291; EXT_ADAPT_OK 364 -> 393 (+29, the d7i runs); OBS_LINT_OK files 150 -> 152, probes 203,
  call sites 103 (equal); OBS_TABLES_OK 203 / 103, pdos_scene_check PASS 1084 (141 scene rows), ADAPT_OK rows 161
  steps 27, P0_OK checks 476, MIRROR_OK runs 29, EXT_TIMELINE_OK, REGISTRY_OK and NODOS_OK as D7h's.  As section
  "Expected changes at the build slot" said.
* **User build** `build/user-builds/d7i/` (11:05 UTC, `build/d7i-prep/mk_userbuild.py`): the Release civ64.exe,
  CIVWIN.zip and civdos.zip (from build "d4"), DISCOVER.SAV, NEWSPAPR.SAV, CABINET.SAV, QUIZ.SAV (the d7i runs' saves)
  and WHAT-TO-CHECK.txt (D7i-1 .. D7i-6, and 157 items still open from earlier builds per the checklist at 11:04 UTC).
* **Pending**: the user checks D7i-1 .. D7i-6.

# Extension phase D6, unit D6fSc (the DOS boxes' line breaks and widths: DOS's own text for the named boxes, DOS's line rule for the rest) - record

This is a rework of units D5b, D6f and D6fS-a in extension session E4, briefed in
`docs/verify/BRIEF-d6fsc.md` (orchestrator, 2026-10-17 about 18:30 UTC).

* **Staged in** `build/d6fsc-stage/`, on the tree after:
  * HM's landing (`build/hm-status.txt` RELEASE_OK 19:26:37 UTC);
  * the docs pass e4e (`build/docs-e4e-done.txt`, 19:40:33 UTC; it changed none of this unit's bases);
  * D7l2's landing (copy-in about 20:01 UTC, manifest `build/d7l2-prep/landed.sha256`).
  * the docs pass e4f (`build/docs-e4f-done.txt`, 21:01:22 UTC; it changed none of this unit's bases).
* **Rebased on D7l2.** D7l2 changed four staged files' bases (`docs/dos/OFFSETS.md` and the registry's outputs). The
  staged copies were rebased on D7l2's landed files ("Rebase notes"). `BASE-SHA256.txt` lists the bases (`obj/base/`)
  and the staged copies.
* **Private builds and runs** are in `build/d6fsc-stage/obj/` only. They are made as D6fS-b's were:
  * the overlay `obj/src` = the tree + the staged files (`obj/mkoverlay.py`);
  * built with the tree's build.cmd and flags (`obj/b.cmd`, `--nogen`);
  * cc.cmd's strict checks (`obj/cc.cmd`);
  * the unit programs (`obj/ut.sh`);
  * the harness runs from copies of the overlay's Checked harness (`obj/exe/`).

  The tree's build/gamedata, dosdata, cache and dos/disasm are only read. The base runs use a copy of the tree's own
  Checked harness (`obj/exe/base/`).

## Result

D6fSc is staged and READY_TO_BUILD.

**The named boxes.** In the DOS graphics, these A boxes show the DOS game's own text, read at run time from the user's
DOS files through the store and the hash-pinned registry (no DOS byte in the repository):

* the quit question (GAME > QUIT to DOS, Alt+Q, Ctrl+Q);
* the Retire question;
* the REVOLUTION! question;
* the tax and luxuries rate boxes.

They get DOS's line breaks, words and capitals; the core's numbers fill DOS's slots in the rate rows. The quit question
reads "Are you sure you / want to Quit?" with the rows "Keep Playing" and "Yes, Quit". Its widest line is 95 DOS
pixels, so the box's right edge is x + 103 (DOS's box in the user's DOSBox screenshot is about 104 wide). Before this
unit it was the core's one line of 173 pixels, x + 181 (362 A pixels): the too-wide box of the user's report.

**Every other A box with text** (the MenuZ boxes of dialogs 136 and 145, the message boxes) uses DOS's line rule:

* the core's text is wrapped at 200 pixels, a width fitted to the DOS game's hand-broken box texts, instead of D5b's
  272;
* the core's '\r' breaks are kept;
* a message box's Windows lines are re-flowed.

The box width still follows D6fS-a's rule (the widest line + 8). **The shared line rule** for unit D7g is
`pdos_r_spec_dos_lines` (the raw breaker `pdos_r_dos_wrap`) in `present/dos/pdos_reskin.h`.

**Results** (private, on the tree after D7l2 and e4f, "Results"):

* Checked, CheckedNoObs and Release: BUILD_OK (portable sources 305).
* cc.cmd: `CC_OK` for the three changed C files in each variant.
* Every unit program passes:
  * test_pdos_reskin: 171 Checked (D6fS-b's 147 + 24), 159 CheckedNoObs;
  * test_dos: 23262 against the staged goldens (the tree's 23259 + the three new tables).
* ext_adapt: `EXT_ADAPT_OK checks 277` (the tree's 268 + the nine D6fSc lines). On the base harness, 7 of the nine
  FAIL (every pairing, header-line and width line); the two pair-equality lines pass there too, which is P0.
* ext_timeline, ext_zoom (against the landed golden, unchanged), ext_frames and ext_dbl: as the tree's.
* `OBS_LINT_OK`, `ADAPT_OK rows 147 steps 27`, `OBS_TABLES_OK`, `PASS pdos_scene_check`, `REGISTRY_OK`, `NODOS_OK`.

## Status

READY_TO_BUILD.

**Built:**

* the shared line rule;
* the fitted width (25 columns = 200 pixels);
* the pairing of the five ShowTextDialog call sites with three new registry rows (`BOX_RATES`, `BOX_QUIT`,
  `BOX_REV_SECTION`);
* the message box re-flow;
* presentation-diag.log's `preskin` field `abox_pair`.

**Tests:**

* unit: the line rule, the re-flow, and the named boxes' texts and DOS-font widths against the store's strings;
* harness: the ext_adapt cases f6c-*.

**Not in this unit** (the brief):

* the box's place: Choice B16 stays; the report is in "The place";
* the header variant: title, portrait and "(HELP AVAILABLE)" are D7g's;
* a general pairing of every KING.TXT text ("Deviations and limits").

## The user's report and the ruling

* **The report**, 2026-10-17 about 18:28 UTC on build "d6fsb" (verbatim in the brief): "QUIT to DOS popup dialog is
  also wide then it should be."
  * civ64's box held the core's one line "Are you sure you want to quit?".
  * DOS's box (DOSBox) holds "Are you sure you / want to Quit?", about 104 DOS pixels wide, at about (100, 80).
  * "also" refers to the research choice's report of about 15:37 UTC (D7g's).
* **The orchestrator's ruling** (the brief):
  * The A boxes' text lines in the DOS graphics follow DOS's line breaks, wording and capitals.
  * Where the listing pairs the box with its DOS string, the DOS game's own string is read at run time,
    hash-pinned.
  * Otherwise the core's text is wrapped by a rule fitted to DOS's boxes, and the rule is recorded.
  * The core's dynamic parts fill DOS's slots.
  * The box width follows D6fS-a's rule, unchanged.
  * The place and the header variant are not in the unit.

## DOS facts (the listing, `build/dos/disasm/root.lst`; the DOS files read only, statistics only)

* **The menu box R:1D05:0475 wraps nothing.**
  * It makes one line of each line feed (the line count DGROUP:658E grows at the line feed, R:1D05:0551..0577).
  * It takes a line starting with ' ' or '_' for an item (R:1D05:04EF..0519).
  * It measures every byte of a line, the item's leading byte included (R:1D05:051C..0535). The widest line [D4C8]
    is taken at the line feed (0556..0561).
  * A text's last bytes after its last line feed (the rate menus' final " ") count as an item but are no line.
  * R:0238:001E(text, x, y) calls it with DGROUP:BA06. A DOS box's lines are therefore exactly its text's breaks.
* **The quit question** R:0403:38B6:
  * Its text: DGROUP:2037, copied to BA06 (R:2045:1E62), two header lines and the rows " Keep Playing" and
    " Yes, Quit".
  * Its place: (100, 80) (R:0403:38C6..38D2).
  * Its result: 1 quits.
  * Reached from:
    * GAME's QUIT (R:1C84:01B1, then 01A9: [D4CA] = 1000h);
    * Retire (R:1C84:01A3: [DC48] = 2 and the same 1000h);
    * Alt+Q (R:0403:3B22..3B27).

  DOS's Retire asks the quit question.
* **The revolution question** R:0403:3542..355F:
  * Its text: KING.TXT's section named by DGROUP:1F6A, read by R:1F4D:044F (R:1F4D:01AD, then R:1F4D:0000(50h): the
    '^' breaks), at (64, 80).
  * Its lines are one header line and two '_' items, with the same words as the core's KING text.
* **The rate menus** R:0403:35CE..368B and R:0403:36B9..377F (SCENES-PLAY 7.20):
  * The header DGROUP:1F9F (1FCC), then one row per rate.
  * Each row is R:2045:1F6A's number, DGROUP:1FB6 (1FE8), the second number and DGROUP:1FBF (1FF6), at (100, 80).
  * The six strings are consecutive (DGROUP:1F9F..2002).
* **The section texts' hand breaks** (KING.TXT 60 texts, ERROR.TXT 12; token-free header paragraphs only):
  * R:1F4D:0000(80) breaks at '^' only, in practice (a space past 80 columns).
  * The DGROUP box strings are broken by hand too. Their 22 two-line texts are mostly fragments around a name's slot
    (best fit 139 pixels), so they do not fit a whole core text.
  * HELP.TXT is drawn by R:1F4D:0088 at 32 characters (full-screen help and the Civilization Note, O4:0000 and
    O4:02D3), not in a menu box.

## Design and decisions

### The line rule (the shared function, `pdos_reskin.h`)

`int pdos_r_spec_dos_lines(PdosRSpec *s, const uint8_t *text, size_t n, int fold)` adds text as header lines of s in s's
font; the raw breaker is `int pdos_r_dos_wrap(const uint8_t *text, size_t n, int font, uint8_t (*lines)[PDOS_R_LINE], int
max)`.  The signatures were given to the orchestrator for D7g at the unit's start.

* **A hand-broken text** holds a line feed or a '^'. It is DOS's own, and its lines are kept as they are:
  * '^' is R:1F4D:0000's forced break; the byte after it becomes the line feed, so a joining space there goes;
  * a line wider than PDOS_R_WRAP x 8 = 272 pixels (D5b's limit; no DOS box line is that wide) is still wrapped.
* **Any other text is the core's.**
  * A '\r' ("\r\n" too) ends a line. This is the core's forced break, as in CompleteResearch's "\r   - " and
    ChooseCityProduction's "Military Advisor:\r\r".
  * Each line wraps by R:1F4D:0088's rule (before the word that would pass the width, at its space; a longer word cut
    where it passes) at **PDOS_R_DOS_WRAP x 8 = 200 pixels** in the box's font.
* **On every line:**
  * leading spaces and '_' go (R:1D05:04EF would take the line for an item);
  * trailing spaces go too;
  * an empty line between two breaks stays a line;
  * a final break adds no line.
* **With `fold`**, the core's Windows-1252 bytes are folded (`pdos_fold_byte`) and '\r' and '\n' are kept as breaks.
  This also fixes D5b's '?' for the core's '\r' (pdos_fold maps control bytes to '?').
* **For D7g's research choice:** pass the DOS string (hand-broken, kept as it is) or, unpaired, the core's text (wrapped
  at 200).
* **Unchanged:** D5b's `pdos_r_spec_header` (272 pixels, line feeds only) stays for its builders (`pdos_menu.c`, whose
  DOS menu rows are DOS's own). Its wrapping is now `wrap_piece` with the width as a parameter, with the same
  behaviour.

### The fitted width (Choice D6fSc-1; the record of the fit)

**The method.** For each width W from 96 to 319 pixels, the script counts DOS's hand breaks that a greedy wrap at W in
DOS font 1 reproduces. A hand break between two lines of a paragraph is reproduced when the line fits in W and the line
plus the next word does not.

**The data.** All header paragraphs without a token, read from the user's DOS files (statistics only, DOS text never
written):

* KING.TXT: 33 paragraphs (27 with a $ token left out), 70 lines, 37 breaks; line widths median 181, p90 220, max 254
  pixels;
* ERROR.TXT: 12 paragraphs, 31 lines, 19 breaks.

These are the texts of the DOS game's questions, advisors' notes and messages: the class of the core's MenuZ and
message boxes.

| W (pixels) | KING breaks | ERROR breaks | sum (of 56) | KING lines within | ERROR lines within |
|---|---|---|---|---|---|
| 184 | 20 | 2 | 22 | 41 | 9 |
| 186 | 21 | 4 | 25 | 42 | 12 |
| 192 | 19 | 6 | 25 | 44 | 14 |
| 196 | 20 | 8 | 28 | 48 | 16 |
| **200** | **20** | **11** | **31** | **51** | **19** |
| 202 | 18 | 12 | 30 | 52 | 21 |
| 208 | 15 | 12 | 27 | 55 | 24 |
| 240 | 9 | 7 | 16 | 68 | 30 |
| 272 (D5b) | 3 | 1 | 4 | 70 | 31 |

**The choice.** W = 200 is the only width with the largest sum (31 of 56). It is also within one break of each file's
own best (KING 21 at 186, ERROR 12 at 202..212). It is 25 columns in R:1F4D:0088's units, so the rule is "R:1F4D:0088's
rule at 25 columns".

**Per box class:**

* the MenuZ boxes (dialogs 136, 145) and the message boxes: 200 pixels;
* the named boxes: DOS's own breaks;
* D5b's builders: 272, unchanged.

**The scripts:** `obj/fit_wrap.py`, `obj/fit_both.py`, `obj/fit_dgroup.py`, `obj/fit_union.py` (statistics only).

### The pairing (the named boxes; Choice D6fSc-2)

The listing pairs five ShowTextDialog call sites with DOS strings. They are D6f's O1 call sites (`g_esc_site`, resolved
at the reset through `obs_callsite`): a MenuZ call made inside one of them takes the call site's pairing
(`MzCall.pair`).

| Core call site | Box | DOS string (registry) | Pairing |
|---|---|---|---|
| 1048:0278 (command 115, Ctrl+Q / File > Quit) | the quit question | R:0403:38B6's DGROUP:2037 (`BOX_QUIT`) | QUIT |
| 11F0:401A (key 0x171, Retire) | the Retire question | the same (DOS's Retire asks it) | QUIT |
| 11F0:3B85 | the revolution question | KING.TXT section `BOX_REV_SECTION` (R:0403:3547) | REV |
| 11F0:3CFC | the tax rate menu | `BOX_RATES` strings 0..2 (R:0403:35CE..366D) | TAX |
| 11F0:3E4A | the luxuries rate menu | `BOX_RATES` strings 3..5 (R:0403:36B9..3758) | LUX |

**The DOS text** (`pdos_r_pair_text`, pure, through the store):

* QUIT: DOS's header lines and rows, row k for the core's row k.
* REV: the section's joined text through R:1F4D:0000(80)'s rule (`dos_breaks`), then its header lines and '_' rows.
* TAX and LUX: DOS's header (up to its line feed). For each core row, DOS's row with the core row's first two runs of
  digits in DOS's two number slots. The numbers are the core's (P0: nothing recomputed).
* **Refusal.** Any refusal keeps the core's text by the line rule: a DOS text missing, DOS's row count not the core's,
  a core row without two numbers, a text too long.
* **The rows** are the core's items, each with DOS's text. The trailing " " of the rate texts is no row (R:1D05:0475:
  no line).
* **The pairing does not change the input map.** The rows keep their item controls, so clicks, keys and Escape (O1)
  work as before.

**The visible differences from D6fS-b:**

* the quit question (DOS's breaks, "Quit?", "Keep Playing");
* the Retire question (DOS's breaks).

The revolution question and the rate menus already had DOS's words and one-line headers, so they look the same. Their
pairing pins them, and keeps the revolution question's 216-pixel DOS line whole, where the 200-pixel fallback would
break it.

### Message boxes (Choice D6fSc-3)

w16's message box lines are Windows's: the text's own breaks, placed for Windows's width, and w16's 400-pixel wrap
(`user_msgbox.c` layout_text).

* `pdos_r_spec_msgbox` re-flows them: consecutive lines join with a space; an empty line, a line after an empty one,
  or a line starting with a space keeps its break (as '\r').
* The paragraphs then take the line rule (200 pixels).
* Example: the Game Help box's text (`user_misc.c` WinHelp) is three lines of up to 33 characters instead of two
  Windows lines re-wrapped at 272.

### The place (not changed; the brief's report)

**DOS's place could be used in play.** ShowTextDialog 1220:00D2 ignores its x and y and calls MenuZ with (0, 0), so
MzCall's x and y are 0. But the core passes DOS's own place at four of the five call sites:

* the revolution question (64, 80) = R:0403:3553..355B;
* tax and luxuries (100, 80) = R:0403:367F..3687, 3773..377B;
* Retire (100, 80) = DOS's quit place R:0403:38C6..38CD.

Command 115's quit (1048:0278) passes (0, 0); its pairing (`BOX_QUIT`) would supply R:0403:38B6's (100, 80).

The presentation can read the ShowTextDialog probe's argument words 2 and 3 at its entry (`OBS_P_ShowTextDialog`,
already handled in `pdos_reskin_on_probe`). Each box could then be placed at 2 x (x, y) from the DOS play screen's
origin on the A canvas (the DOS map element's layout, D6d), in place of Choice B16's Windows dialog top-left. This is
not done (the brief); a later unit can take it with the place rule above.

### Choices

* **D6fSc-1:** the fallback width is 200 pixels (25 columns), fitted as above. This replaces D5b's 272 (Choice D5b-3)
  for the MenuZ and message boxes.
* **D6fSc-2:** five named boxes are paired by call site (the listing's pairs). Every other box keeps the core's wording
  with DOS's line rule.
* **D6fSc-3:** the message boxes' Windows breaks are re-flowed, keeping empty and indented lines.

## Deviations and limits

* **No general KING.TXT pairing.** The core's KING texts (LoadKingText 11D0:01F7, TEXT `KNG_name`) have no observer
  probe, so a box cannot tell which section it shows without a new probe; that would be a change to the observer
  tables, which this unit does not make. A later unit could add one and pair every KING text by its section name
  (about 60 boxes, with R:1F4D:0471's tokens filled from the core's names). Until then those boxes keep the core's words
  with the fitted line rule.
* **'^' followed by a byte other than a space.** The port keeps that byte; R:1F4D:0000 would replace it with the line
  feed. No DOS text has one.
* **An item line's leading marker** is measured as a space (D5b's rows are ' ' + text). DOS measures KING's '_', which
  is 4 pixels wider in font 1. This is not the widest line in the paired boxes.
* **The unpaired boxes keep the core's (Windows) wording and capitals.** Only their breaks are DOS-like.
* **The message box re-flow joins Windows's hand breaks** (for example the 16-colour conversion text) into paragraphs.
  DOS has no such boxes to compare.

## What was built

* **`present/dos/pdos_reskin.h`:**
  * `PDOS_R_DOS_WRAP` (25), `pdos_r_dos_wrap`, `pdos_r_spec_dos_lines`;
  * `PDOS_R_PAIR_*`, `PdosRPair`, `pdos_r_pair_text`;
  * the comments of `pdos_r_spec_msgbox` and the header updated.
* **`present/dos/pdos_reskin.c`:**
  * `put_line` and `wrap_piece` (D5b's `wrap_line` cut into a width-parameter breaker; `wrap_line` keeps D5b's
    behaviour);
  * the line rule; `dos_breaks` (R:1F4D:0000's rule); `split_box_text`, `digits`, `pair_rates`, `pdos_r_pair_text`;
  * the message box re-flow;
  * `g_esc_site[].pair` and `MzCall.pair`, set at the MenuZ entry with `esc`;
  * `menu_build` pairs or uses the line rule;
  * `g_set_pair` and `g_dg.abox_pair`, with presentation-diag.log's `preskin` field `abox_pair` after the abox fields.
* **`docs/dos/OFFSETS.md`:** rows `BOX_RATES` (DGROUP:1F9F, strs 6), `BOX_QUIT` (DGROUP:2037, str), `BOX_REV_SECTION`
  (DGROUP:1F6A, str) with their readers, and a note.
* **Generated from it:** `present/dos/pdos_registry.c/.h` and `tests/dos-decoded.txt` (`registry.py gen`, `goldens`;
  hashes, sizes, offsets only).
* **`tests/test_pdos_reskin.c`:** `test_dos_lines`, `test_pair`, the message box re-flow, and D5b's message box
  expectations updated (the two Windows lines are now one).
* **`tests/harness/ext_adapt.py`:** `d6fsc_runs` (the f6c-* cases) and the docstring paragraph.
* **No change** to build.cmd, test.cmd, the core, rt, w16, the Windows graphics, pdos_adapt (no new PDOS bits or
  owners) or the observer tables.

## Tests

**test_pdos_reskin**, extension D6fSc (`test_dos_lines` on the synthetic font of 6 pixels a character):

* the core's 234-pixel line wraps at the last space before 200 (D5b's rule kept it whole);
* '\r', "\r\n", an empty line, a final break;
* a 40-character word cut at 33 characters;
* a hand-broken 240-pixel line kept whole, a 270-pixel one kept, a 300-pixel one wrapped at 272;
* '^' with and without the joining space; leading '_' and spaces, trailing spaces;
* max; an empty text; a NUL;
* `pdos_r_spec_dos_lines` folding with '\r' kept, the headers before the rows.

**test_pair** (the store's strings, compared with the registry's and KING.TXT's at run time):

* the quit question:
  * DOS's header and rows;
  * the spec's two hand-broken lines;
  * in **DOS font 1** (`pdos_glyph_fonts(NULL)`): widest 95 pixels, right = x + 103;
  * the core's text alone is one line of 173 (x + 181);
  * three core rows: not paired.
* the revolution question: KING.TXT's rows (the core's words); its one line of **216 pixels** kept (x + 224); the same
  line without its line feed would wrap at 200.
* the tax menu: DOS's header; three rows with the core's numbers ("0", "10", "60" and "60", "50", "0") around DOS's
  texts.
* the luxuries menu: the same.
* refusals: a row without numbers, no pairing, an unknown pairing, no rows.

**test_msgbox** (CIV_OBSERVER): the two Windows lines of D5b's case are now one; a four-line box re-flowed into five
lines with the empty and indented lines kept.

**ext_adapt**, extension D6fSc (docstring; S3's lines to 60,000 ms with the profile chord at 40,000 ms):

* **Calibrations**, each box opened at 55,500 ms and closed by Escape at 56,500 ms:

  | Run | Opened by | pairing | header lines | rows | right - x |
  |---|---|---|---|---|---|
  | f6c-quit-cal | Ctrl+Q | 1 | 2 | 2 | 103 |
  | f6c-retire-cal | File > Retire in the Windows graphics, f6_open | 1 | 2 | 2 | 103 |
  | f6c-rev-cal | Ctrl+R | 2 | 1 | 2 | 224 |
  | f6c-tax-cal | Ctrl+T | 3 | 1 | - | - |
  | f6c-lux-cal | Ctrl+L | 4 | 1 | - | - |
* **Click cases:**
  * f6c-quit: Ctrl+Q, a press and release on the DOS row 0 below DOS's two header lines (its point from
    f6c-quit-cal's places): I-menu/press and I-menu/release, a click on the core's item control.
  * f6c-rev: the same on the revolution question.
  * Each equals its Windows-form pair: Ctrl+key, the click where the DOS run gave it at the release, Return at the
    release sync. The game goes on, and no revolution starts.

## Results (private, `build/d6fsc-stage/obj/`)

**First, on the tree after HM and e4e** (`obj/run/final.txt`, `obj/run-c2.txt`):

* **Builds:** Checked, CheckedNoObs, Release `BUILD_OK`, `portable sources checked: 304`, no warning.
* **cc.cmd:** `CC_OK` (pdos_reskin.c, pdos_registry.c, test_pdos_reskin.c) in each variant.
* **Unit programs** (55 each): every one PASS, with these counts:

  | Program | Checked | CheckedNoObs | Release |
  |---|---|---|---|
  | test_pdos_reskin | 171 | 159 | 171 |
  | test_input | 612 | 555 | 612 |
  | test_pdos_menu | 43 | 43 | 43 |
  | test_pdos_adapt | 155 | 155 | 155 |

  test_dos reads the tree's goldens (`<gamedata>\..\..\tests`) and so reports 3 lines differing. Against the staged
  goldens (`obj/tdos`) it passes 23260 checks in each variant.
* **Checks:** `OBS_LINT_OK files 140 probes 203 callsites 101`, `ADAPT_OK rows 147 steps 27`, `PASS pdos_scene_check:
  1084 checks`, `OBS_TABLES_OK probes 203 sites 101`, `REGISTRY_OK`, `NODOS_OK` (0 hits), include rule clean.
* **ext_adapt D6fSc** (`obj/runadapt.py c`, the overlay's harness `obj/exe/c1`): 9 of 9 PASS.
* **The base run** (`obj/run-base.txt`, the tree's Checked harness): 7 FAIL. The base values:

  | Run | pairing | header lines | rows | right - x |
  |---|---|---|---|---|
  | quit | none | 1 | 2 | 181 |
  | Retire | none | 1 | 2 | 182 |
  | revolution | none | 1 | 2 | 224 |
  | tax | none | 1 | 11 | 138 |
  | luxuries | none | 1 | 6 | 166 |

  The click cases' main lines fail; the two pair-equality lines pass (P0).

**Again, on the tree after D7l2's landing (RELEASE_OK 20:45:49 UTC) and the docs pass e4f** (the overlay rebuilt
from the rebased stage; `obj/run/final2.txt`, the overlay's Checked harness copied to `obj/exe/c3`, SHA-256
10ca557e...):

* **Builds:** Checked, CheckedNoObs, Release `BUILD_OK`, `portable sources checked: 305` (D7l2's new source), no
  warning.
* **cc.cmd:** `CC_OK` for the three files in each variant.
* **Unit programs** (56 each, D7l2's test_pdos_arrive included): every one PASS, with the counts of the table above.
  test_dos against the tree's goldens reports 1 failure (the three new tables' decoded lines); against the staged
  goldens (`obj/tdos`) it passes **23262** checks in each variant (the tree's 23259 + 3).
* **Checks:** `OBS_LINT_OK files 142 probes 203 callsites 101`, `ADAPT_OK rows 147 steps 27`, `PASS pdos_scene_check:
  1084 checks, 141 scene rows, 10 font rows`, `OBS_TABLES_OK probes 203 sites 101`, `REGISTRY_OK` (443 `ok` lines;
  the tree's 429 + 14 for the three tables; "equals the Python models' output (1392 lines)", the tree's 1389),
  `NODOS_OK` (0 hits), include rule clean.
* **ext_adapt, the whole staged script** (`obj/runadapt_full.py`, `obj/run-full3.txt`): `EXT_ADAPT_OK checks 277`.
  Against the tree's ext-adapt.txt (268 lines): the nine f6c lines are new; four lines change, all from the message
  box re-flow of the Game Help box (D6fS-a's case):
  * f6-cal: the Game Help box's OK point (101, 253) -> (104, 253);
  * f6s-msgbox "as large as its content": 5 lines of 8, 564 x 98 -> **398 x 98** A pixels (the element the same);
  * f6s-msgbox "while open": the DOS element 76,172..640,270 -> 79,172..477,270, still 0 other pixels (116 in the
    map's animated colours where it animates, informational);
  * f6s-msgbox "every frame of the close": still 0 other pixels (the animated-colour count 292 -> 44, informational).
  Every other line is the tree's.
* **ext_timeline** (the tree's script, `--exe`/`--root`, `obj/run-tl3.txt`): `EXT_TIMELINE_OK`, its 53 PASS lines
  equal to the tree's.
* **ext_zoom** (`obj/zoompriv.py` against a staged copy of the landed golden, `obj/run-zoom3.txt`): `ZOOM_OK
  combinations 32 runs 108 samples 628 map comparisons 32 centre runs 4 mzi runs 12 mzs runs 4 not zoomed 38/448`,
  the tree's line: the golden needs no change, so it is not staged.
* **ext_frames** (`obj/frames_priv.py`, `obj/run-frames3.txt`): `EXT_FRAMES_OK`, the PASS lines equal to the tree's.
* **ext_dbl** (`obj/run-dbl3.txt`): `EXT_DBL_OK checks 4`, equal to the tree's.

## Expected changes at the build slot

Predictions: `build/d6fsc-prep/predictions.txt`, written before the copy-in. In short:

* build.cmd checked: BUILD_OK, portable sources 305 unchanged.
* test.cmd checked: TESTS_OK.
  * unit.log: test_pdos_reskin 147 -> 171; test_dos 23259 -> 23262 ("decoded content" 1389 -> 1392 lines); every
    other program unchanged.
  * registry-check: REGISTRY_OK, 429 -> 443 `ok` lines; dos-decoded.txt: the three new `table` lines.
  * ext-adapt: EXT_ADAPT_OK checks 268 -> 277, with the four changed Game Help lines above.
  * presentation-diag.log: the `preskin` line gains `abox_pair` after the abox fields.
  * obs-lint, adapters-check, obs-tables, pdos-scene-check, ext-timeline, ext-zoom, ext-frames, ext-dbl, ext-p0 and
    every other section unchanged; nodos NODOS_OK, 0 hits (one more file scanned: this record).
* ext_g1.py check: EXT_G1_OK runs 77 (amended 1), unchanged (presentation only).
* build.cmd (Release): BUILD_OK.

## Rebase notes

* **D7l2** (landing copy-in about 20:01 UTC, manifest `build/d7l2-prep/landed.sha256`). It changed four staged files'
  bases: `docs/dos/OFFSETS.md`, `present/dos/pdos_registry.c/.h`, `tests/dos-decoded.txt`.
  * `obj/rebase_on.py d7l2`: `git merge-file -p` of the D6fSc edits onto D7l2's landed OFFSETS.md (read from
    `build/d7l2-stage`, its hash checked equal to the landed one). Two conflicts (the appended rows and the appended
    notes), resolved by keeping both, D7l2's first (`obj/resolve_d7l2.py`).
  * The merged file is D7l2's plus this unit's three rows and its note, nothing else.
  * The registry's outputs were regenerated on D7l2's files in `obj/mini2` (the tree's registry.py; `REGISTRY_OK`).
  * The pre-merge copies are in `obj/premerge-d7l2/`. The new bases are D7l2's landed files (`obj/base/`).
* **The docs pass e4f** (D7l2's record; marker `build/docs-e4f-done.txt` 21:01:22 UTC) changed FIDELITY, DESIGN,
  RUNNING, FEATURES, dos/OPEN, dos/SCENES-PLAY, dos/TIMING, STATUS and the checklist header. None of them is staged
  here; `docs/dos/OFFSETS.md` was rechecked after the marker, unchanged (859218f5...). The new FIDELITY entries are
  F-new-1 .. F-new-4 here; the docs pass numbers them from F266.
* **The zoom golden.** A copy of the landed `tests/harness/ext-zoom-golden.txt` was staged for the private zoom run
  only; the run matched it unchanged, so the copy was removed from the stage before `BASE-SHA256.txt` was written.

## What the user checks

On the user build of this unit, in play with the DOS graphics (`--graphics dos` or Ctrl+Shift+Backspace), the main map
window active.

* **D6fSc-1** (the quit question).
  * Open GAME > QUIT to DOS (or press Alt+Q, or Ctrl+Q). The box shows the DOS game's question on two lines,
    "Are you sure you" and "want to Quit?", then the rows "Keep Playing" and "Yes, Quit".
  * The box is as narrow as the DOS game's (about a third of the screen's width; in DOSBox about 104 of 320 pixels),
    no longer a long single line.
  * Escape, Return on "Keep Playing" or a click on it: the box closes and the game goes on.
* **D6fSc-2** (the Retire question). GAME > Retire asks the same question in the same narrow box as D6fSc-1 (the DOS
  game's Retire asks it too); Escape or "Keep Playing": the game goes on.
* **D6fSc-3** (the REVOLUTION! question).
  * Open GAME > REVOLUTION! (or press Ctrl+R). The box shows "Are you sure you want a REVOLUTION?" on one line, then
    "No thanks." and "Yes, we need a new government.", as the DOS game shows it. Its one long line is the DOS game's
    own, so this box stays wider than the quit question's.
  * Escape or "No thanks.": nothing happens.
* **D6fSc-4** (the tax and luxuries boxes).
  * GAME > Tax Rate (or Ctrl+T, or =): "Select new Tax rate:" above one row per rate, written as in DOS
    ("0% Tax, (60% Science)", "10% Tax, (50% Science)", ...), the current rate highlighted. The box is as wide as its
    widest row.
  * GAME > Luxuries Rate (or Ctrl+L, or -): "Select new Luxuries rate:" with "0% Luxuries, (..% Science)" rows.
  * Escape keeps the rates.
* **D6fSc-5** (the other boxes).
  * Any other message box in play in the DOS graphics keeps the Windows game's words, but its lines break at about
    two thirds of the screen's width at most, like the DOS game's boxes. No box spans the whole screen. Examples: an
    advisor's note, a disaster or celebration message, the Game Help box (Help > Game Help in the Windows graphics,
    then Ctrl+Shift+Backspace while it is open).
  * The boxes' rows and keys work as before.

Not part of this check: the research choice's box (D7g), the boxes' places (unchanged), the Windows graphics
(unchanged).

## For the records

* **F-new-1 (FIDELITY; Choice D6fSc-2).**
  * The quit, Retire, revolution, tax and luxuries boxes show the DOS game's own text. It is read at run time from the
    user's DOS files: `BOX_QUIT` R:0403:38B6, `BOX_REV_SECTION` R:0403:3547 / KING.TXT, `BOX_RATES` R:0403:35CE and
    36B9.
  * They get DOS's breaks, words and capitals; the core's numbers fill the rate rows' slots.
  * They are paired by the core's ShowTextDialog call site (1048:0278, 11F0:401A, 11F0:3B85, 11F0:3CFC, 11F0:3E4A).
* **F-new-2 (FIDELITY; Choice D6fSc-1).**
  * The other MenuZ and message boxes in the DOS graphics keep the core's wording.
  * Their lines follow DOS's line rule: a hand-broken text kept, the core's '\r' a break, the core's lines wrapped at
    200 pixels in font 1 (R:1F4D:0088's rule at 25 columns).
  * The 200 pixels are fitted to KING.TXT's and ERROR.TXT's hand breaks: 31 of 56 reproduced, where D5b's 272
    reproduced 4.
  * This replaces Choice D5b-3's 272 for those boxes.
* **F-new-3 (FIDELITY; Choice D6fSc-3):** the message boxes' Windows breaks are re-flowed, keeping empty and indented
  lines.
* **F-new-4 (OPEN):**
  * the general KING.TXT pairing needs a LoadKingText probe (observer tables);
  * DOS's box place in play is available from ShowTextDialog's ignored x and y ("The place"); Choice B16 stays.
* **DESIGN 12.x "As implemented (D6fSc)":**
  * the line rule, `pdos_r_spec_dos_lines` / `pdos_r_dos_wrap` (shared with D7g), `PDOS_R_DOS_WRAP`;
  * the pairing (`PDOS_R_PAIR_*`, `pdos_r_pair_text`, `g_esc_site[].pair`, `MzCall.pair`);
  * the message box re-flow.
* **RUNNING.md:**
  * presentation-diag.log's `preskin` new field `abox_pair` (0 the core's text, 1 quit, 2 revolution, 3 tax,
    4 luxuries);
  * ext_adapt's f6c-* cases (five calibrations, two click cases with their Windows-form pairs).
* **FEATURES.md:** the DOS boxes' DOS texts (the named boxes) and DOS's line widths, with the runners above.
* **DOS-PROFILE.md** (prose), rows 14 and 22 (MenuZ 136, 145), the #MsgBox rows, 94 and 141: the line rule; the named
  boxes' DOS texts.
* **OFFSETS.md** (staged): `BOX_RATES`, `BOX_QUIT`, `BOX_REV_SECTION`.
* **manual-checklist-ext.md:** the new items D6fSc-1..D6fSc-5 ("What the user checks"). D6f-7 and D5-7 stay; D6fSc-1..4
  add the boxes' texts to them.
* **Not edited by this unit:** DESIGN.md, FIDELITY.md, STATUS.md, RUNNING.md, FEATURES.md, DOS-PROFILE.md,
  manual-checklist-ext.md, the D1 drafts and the D0 documents.

## Landing

D6fSc landed alone at the build slot of session E4, 2026-10-17. It came after D7l2's landing (RELEASE_OK 20:45:49
UTC, `build/user-builds/d7l2/`) and the docs pass e4f (`build/docs-e4f-done.txt`, 21:01:22 UTC). Its implementer
landed it as the orchestrator directed: the slot was reserved for it, and it was to land when READY with the usual
protocol (message of about 21:02 UTC). The user checks are D6fSc-1..D6fSc-5 in the user build `d6fsc` ("What the user
checks").

**Bases**

* The stage was rebased onto the tree after D7l2's landing (about 20:10 UTC) and rechecked after e4f ("Rebase notes").
* The overlay was built and checked again on the tree after D7l2 and e4f ("Results").
* `BASE-SHA256.txt` was written by `obj/mkbases.py`: BASES rows 9, problems 0; every base was equal to the tree at
  21:46 UTC.
* `build/d6fsc-prep/land.py` rechecked it: every base equal, the record absent, build.cmd and test.cmd unchanged
  (DRY_RUN_OK 9).

**Scripts** in `build/d6fsc-prep/`, written by `mk_prep.py` and `mk_fill.py`:

* `land.py`, from D6fS-b's, for this stage's 8 changed rows and no new file;
* `d6fsc-cycle.ps1` and `compare.py`, from D7l2's;
* `mk_userbuild.py`, from D6fS-b's;
* `fill_stillopen.py`, from D7l2's, with the group "d7l2" added. The group had no rows left: D7l2-1..D7l2-4 passed at
  about 21:25 UTC. The group "d7l"'s pointer to D7l2-3 was reworded by hand.

**Copy-in**

* Snapshots: `build/d6fsc-prep/before` (the tree's `build/test/Checked` outputs of D7l2's cycle, 66 files) and
  `tree-before` (the eight replaced files).
* Copy-in at 21:46:57 UTC. `landed.sha256` lists the 9 files; build.cmd and test.cmd are unchanged. `landed-at.txt`
  reads "unit d6fsc".
* The predictions (`build/d6fsc-prep/predictions.txt`) were written before the copy-in.

**The three-step cycle** (`build/d6fsc-status.txt`; each step is guarded by its log's OK marker):

1. `build.cmd checked`: BUILD_OK, 21:47:06..21:51:40 (274 s); portable sources checked 305.
2. `test.cmd checked`: TESTS_OK, 21:51:40..22:25:59 (2059 s); TEST_SECTIONS 30, failed 0; no flake rerun.
3. `ext_g1.py check`: EXT_G1_OK runs 77 (amended 1), unchanged. Result: **ALL_GREEN** (22:25:59 UTC).
4. `build.cmd` (Release): BUILD_OK, 22:26:12..22:30:10 (239 s). Result: **RELEASE_OK**.

**Against the predictions** (`build/d6fsc-prep/compare.py` against the snapshot; `compare.txt`: 57 of 66 files equal,
host times left out). Everything came out as predicted:

* unit.log:
  * test_pdos_reskin 147 -> 171;
  * test_dos 23259 -> 23262 ("decoded content" 1389 -> 1392 lines; registry 70 -> 73 tables);
  * every other count equal.
* registry-check: REGISTRY_OK. The three tables add 15 `ok` lines, and the goldens line goes from 1389 to 1392 lines
  (429 -> 443 `ok` lines). dos-decoded.txt gains the three `table` lines.
* ext-adapt: EXT_ADAPT_OK checks 268 -> 277.
  * The nine f6c lines are new, and f6-cal's OK point moves from (101, 253) to (104, 253).
  * The three f6s-msgbox lines change as predicted (564 x 98 -> 398 x 98 A pixels; the element 79,172..477,270; 0 other
    pixels). compare.py leaves these lines out, because its host-time filter matches "6s" in their name, so they were
    compared directly.
  * Every PASS/FAIL line of ext-adapt.txt equals the private run `obj/run-full3.txt`.
* Unchanged: obs-lint (files 142), adapters-check, obs-tables, pdos-scene-check (1084), ext-timeline, ext-zoom
  (ZOOM_OK, the landed golden), ext-frames, ext-dbl (checks 4), ext-p0 (P0_OK checks 476) and every other section.
* nodos: NODOS_OK, 0 hits; files 1807 -> 1808 (the record).

Not predicted in detail, explained:

* (a) coverage.txt "other functions entered" 670 -> 665. This count is informational; it varies between 662 and 672
  across this session's landings.
* (b) unit.log's OBS_COST line (host timing).

**User build** `build/user-builds/d6fsc/`:

* `civ64.exe`: the Release build, SHA-256 41da2c8a...;
* `CIVWIN.zip` and `civdos.zip` from `build/user-builds/d4/`;
* `WHAT-TO-CHECK.txt`: D6fSc-1..D6fSc-5, the earlier builds up to "d7l2", and the 115 items still pending in the
  checklist at 21:51 UTC.

No save is needed: any game in play shows the boxes.

**Not done at this slot:**

* the checklist rows D6fSc-1..D6fSc-5 and STATUS (the orchestrator's, from "What the user checks");
* the docs pass ("For the records"; a joint pass with D7e's after D7e lands; FIDELITY entries F-new-1..F-new-4, numbered
  from F266).

The tree's CheckedNoObs build is not part of the three-step cycle; the private overlay's three variants are in
"Results".

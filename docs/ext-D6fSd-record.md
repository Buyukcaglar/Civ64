# Extension phase D6, unit D6fSd (the DOS game's own section texts and places for the remaining boxes) - record

This is a follow-up of rework unit D6fSc in extension session E4, briefed in `docs/verify/BRIEF-d6fsd.md`
(orchestrator, 2026-10-17 about 22:35 UTC).

* **Staged in** `build/d6fsd-stage/`, on the tree after:
  * D6fSc's landing (`build/d6fsc-status.txt` RELEASE_OK 22:30:10 UTC);
  * D7e's landing (copy-in 22:59:02 UTC, manifest `build/d7e-prep/landed.sha256`; `build/d7e-status.txt` RELEASE_OK
    23:46:36 UTC). D7e changed one staged file's base, `tests/harness/ext_adapt.py` ("Rebase notes");
  * D7k's landing (copy-in 01:25:44 UTC, manifest `build/d7k-prep/landed.sha256`; RELEASE_OK 02:08:45 UTC). D7k
    changed four staged files' bases ("Rebase notes");
  * D7f's landing (copy-in 02:30:03 UTC, manifest `build/d7f-prep/landed.sha256`; RELEASE_OK 03:15:33 UTC). D7f changed
    the same four bases ("Rebase notes").
* **The orchestrator's later rulings** (2026-10-18, after D7k's landing): the leader messages (D7k's boxes) take the
  section rule too, in the leader font; D7f's buy question takes DOS's place through the same MenuZ-call rule
  ("Design", "D7f's buy question").
* **Private builds and runs** are in `build/d6fsd-stage/obj/` only, made as D6fSc's were:
  * the overlay `obj/src` = the tree + the staged files (`obj/mkoverlay.py`);
  * built with the tree's build.cmd and flags (`obj/b.cmd`, `--nogen`);
  * cc.cmd's strict checks (`obj/cc.cmd`);
  * the unit programs (`obj/ut.sh`);
  * the harness runs from copies of the overlay's Checked harness (`obj/exe/`).

  The tree's build/gamedata, dosdata, cache and dos/disasm are only read.

## Result

D6fSd is staged and READY_TO_BUILD (on the tree after D7f's landing).

**The section texts.** In the DOS graphics, a MenuZ box whose text is a KING text the core loaded by name shows the DOS
game's KING.TXT section of the same name. It is read at run time from the user's DOS files through the store and the
hash-pinned registry (no DOS byte in the repository), with:

* DOS's breaks (R:1F4D:0000(80): its '^' line ends), words and capitals;
* R:1F4D:0471's tokens filled from the core's values (`$US`, `$THEM`, `$BUCKS`, `$RPLC1`, `$RPLC2`);
* DOS's items ('_' lines) as the box's rows, when DOS has as many as the core's box;
* what the core appends after the loaded text (D4's GRANARY sentence) on its own line, as DOS does.

The 16 KING sections the core shows through ShowTextDialog are paired (the table below). So are the leader messages
of D7k's audience (ShowLeaderMessage 1160:328E, template 142), drawn in the leader font: every one of their 22 sections
pairs by name, and every byte of their texts has a glyph in each leader font. In the harness's audience
(CAE3540B.SAV), the treaty offer (PEACE) and the welcome speech (TREATY) are paired. "You respond" (THREAT, with the
core's own answers appended) keeps D7k's text. A section DOS lacks, one whose DOS item count is not the core's, or one
followed by items the core appended keeps the fallback (the core's text by DOS's line rule). The same function pairs
ERROR.TXT, HELP.TXT and PRODUCE.TXT sections by their prefixes, but none of those texts is a MenuZ box (the table).

**The DOS places.** In play, an A box whose ShowTextDialog call carries x, y other than (0, 0) stands at DOS's place:
the DOS map view's origin (80, 8) (R:1AEA:0008) at the map window's client origin, 2x, then the existing clamp inside
the canvas. The quit question (command 115 passes (0, 0)) uses its pairing's (100, 80) (R:0403:38C6..38D2). D7f's buy
question (ShowTextDialog 1030:5CCF's (100, 80), the DOS listing's R:0D12:4E26..4E32) takes its DOS place by the same
rule when it shows over an A frame. Boxes without DOS values (message boxes, the other ShowTextDialog (0, 0) calls,
D7f's other boxes) keep Choice B16's anchor.

**Results** (private): on the tree after D7f's landing ("Results"):

* Checked, CheckedNoObs and Release: BUILD_OK (portable sources 308), no warning; cc.cmd `CC_OK` for the four changed
  C files in each variant.
* Every unit program passes. test_pdos_reskin: 209 Checked and Release, 197 CheckedNoObs (the tree's 171 and 159 +
  38); the other 58 programs' counts are the tree's.
* ext_adapt: `EXT_ADAPT_OK checks 329` (the tree's 319 + D6fSd's 10). Every changed line comes from the DOS places
  or from the leader box's one fewer build ("Results").
* d7k-leader passes with DOS's text: PEACE and TREATY paired, THREAT D7k's text, no byte without a glyph; its pair's
  core outputs are equal (P0).
* ext_timeline, ext_frames, ext_dbl, ext_p0 (Checked `P0_OK checks 476`; CheckedNoObs `P0_OK checks 62`) and
  ext_zoom: the tree's results.
* `OBS_LINT_OK`, `ADAPT_OK rows 153 steps 27`, `OBS_TABLES_OK`, `PASS pdos_scene_check`, `REGISTRY_OK`, `NODOS_OK`.

## Status

READY_TO_BUILD on the tree after D7f's landing (RELEASE_OK 03:15:33 UTC). At the slot, `obj/mkbases.py` rechecks
every base against the tree; a moved base is merged again before the copy-in.

**Built:**

* the section texts by name (KING.TXT, ERROR.TXT, HELP.TXT, PRODUCE.TXT by prefix), 16 ShowTextDialog KING boxes;
* the leader messages' section texts in the leader font (22 sections; THREAT D7k's text), with the glyph check;
* the DOS places of the A boxes (B16 reversed for the boxes with DOS values), D7f's buy question included;
* presentation-diag.log's `preskin2` line;
* the unit tests and ext_adapt checks of "Tests".

## The ruling (the brief)

* **KING pairing.** A read-only observer probe tells a box its KING section; the box draws DOS's KING.TXT section of
  the same name, its tokens filled from the core; the fallback where a section cannot be paired, recorded per section;
  the same for ERROR.TXT and any other pairable text source.
* **DOS places.** A box whose ShowTextDialog call carries DOS's x, y stands at DOS's place, mapped onto the A canvas
  (the map area's origin, 2x, the clamp); the quit question at its pairing's (100, 80); B16 for boxes without DOS
  values; a FIDELITY F-new reversing B16 for those boxes.
* **Not in the unit:** the research choice's and the other header boxes' texts (D7g), the Civilopedia (D7h), the
  Windows graphics (unchanged).
* **Later rulings (the orchestrator, 2026-10-18 after D7k's landing):**
  * the leader messages (template 142) get DOS's KING.TXT text in the leader font, under the user's direction that the
    DOS graphics show the DOS game's own contents. Conditions: the d7k-leader runs pass with DOS's text (their
    core-output equality, P0, holds); the leader font draws every glyph DOS's text uses, the tokens filled from the
    core's names included; an unpairable leader section keeps D7k's text, recorded per section; the D7k checklist
    items whose wording changes are named here (the orchestrator rewrites those rows at the landing);
  * the buy question (D7f, 1030:5CCF): DOS's place (b), because the DOS listing gives it (R:0D12:4E26..4E37 pushes 50h, 64h:
    R:0238:0008(text, 100, 80)). It goes through the MenuZ-call rule, and its A case is recorded as derived.
* **Constraints:** P0 (the core unchanged, the presentation only reads, no core RNG draw); no new PDOS bits or owners.

## The probes (no observer table change)

The probe keys already exist (extension D3, `present/obs_tables.c`; WINDOWS-INVENTORY 10.2;
`ext-D3-probe-verification.md`): `LoadTextResource` 11D0:00E4 (entry), `LoadKingText` 11D0:01F7 (entry) and
`SubstituteTextTokens` 11D0:022D (exit). D6fSc's record ("Deviations and limits") assumed a LoadKingText probe was
missing; the keys are there, so no `obs_tables` regeneration, call-site row or new key is needed (`OBS_TABLES_OK
probes 203 sites 101`, unchanged). The presentation now consumes two of them:

* **LoadTextResource's entry** (words 0..1 the prefix, 2..3 the name; LoadKingText calls it with "KNG"): the prefix
  and the section name (`pdos_r_src_load`). LoadTextResource is the one entry both LoadKingText and ShowTextNoteDialog
  (HLP_, ERR_) go through.
* **SubstituteTextTokens's exit** (no arguments; it works on g_messageText 12D8:24FA): the core's text after the
  substitution (g_messageText, at most 1023 bytes read) and the five values g_textSubstParams 13C8:0000 (char[5][32])
  (`pdos_r_src_tokens`). A second substitution without a load (ChooseCityProduction's, after AppendTextResource) drops
  the noted text.
* **MenuZ's entry** (D6f's): a box whose text starts with the noted text (ShowTextDialog passes g_messageText, or
  RunPalaceImprovement's copy of it) takes that section; the rest of its text is the core's suffix.

Reads only: `w16q_strn`, `w16q_read`, `w16q_rd16`, `w16q_wnd`. No core state is written and no RNG is drawn (P0).

## The sections (per section; the user's DOS files and the core's TEXT resources, statistics only)

The core's TEXT resources (`build/gamedata/civdata*.rsc`, Mac resource format: KNG_ 61, ERR_ 12, HLP_ 18, MAK_ 51)
against the DOS section files (KING.TXT 60 names, ERROR.TXT 12, HELP.TXT 18, PRODUCE.TXT 51), by name
(`obj/survey_texts.py`, `obj/survey2.py`, `obj/survey3.py`: counts and names only). The core's KING callers are the 47
LoadKingText calls at 46 addresses (a survey of `core/*.c`):

| Sections | The core's display | This unit |
|---|---|---|
| PMAX (FoundCity, TD 1040:067A), D1..D6 (ProcessCityDisaster, TD 1040:101F and 10DC), LEADER (ResolveCombat, TD 1050:0E5E), TAXES and FAME (ProcessGameTurn, TD 1088:0376, 0B3F), PALACE (RunPalaceImprovement, TD 1158:0045 on a copy), PROVOKE and RID (HoldDiplomaticAudience's refusals, TD 1160:0FB4, 114D), ESCHISM (StartCivilWar, TD 11A0:0387), UMAX (CreateUnit, TD 11C0:168C), REV (MoveCivUnits, TD 11F0:3B85) | ShowTextDialog, template 136: a MenuZ box | **paired** (16 sections: the same names, the same tokens on both sides, DOS's item counts the core's: FAME and REV two, the others none) |
| SCHISM (StartCivilWar, the human the split civilization) | ShowTextDialog | **fallback**: neither file has the name (the core's text is empty) |
| D4 | ProcessCityDisaster appends its GRANARY sentence without a separator (1040:0ACA) | paired; the sentence on its own line (DOS's text and its LF) |
| D1..D6 of a seen foreign city | cut after the first CR (TD 1040:10DC); the KING texts hold none | paired as the whole text |
| EXCHANGE, CANCEL, TRIBUTE, TAKECIV, PROVOKE, REJECT, RID, PEACE, GIVECIV, GIVECASH, GROVEL, MOBILIZE, ATTITUDE, GIVEMORE, NOCONTACT, ATWAR, MERCENARY, UNFORTUNATE, TREATY, HELPME, CRUSADE, GAPE | ShowLeaderMessage 1160:328E (LoadKingText, then MenuZ with g_messageText on the leader window): D7k's leader message, template 142 | **paired** in the leader font (22 sections: the same names and tokens on both sides; DOS's item k the core's item k, the same words: CANCEL, CRUSADE, EXCHANGE, GIVECASH, GIVECIV, GROVEL, HELPME, MERCENARY, PEACE, TAKECIV, TRIBUTE two items, the others none); every byte drawn in each leader font (fonts 8, 9 and 3); seen in the harness: PEACE, TREATY |
| THREAT1, THREAT2, THREAT | 1160:197E..1A25: THREAT1 and THREAT2 (Windows only, each when its condition holds) loaded and copied, THREAT loaded, the two copies appended as items, ShowLeaderMessage ("You respond") | **fallback** (D7k's text): the core's appended items after the noted text (DOS's THREAT has three fixed items); seen in the harness |
| INIT | RunNewGameSetup: dialog 151's TextBox | not a box (D5d's dialog 151) |
| QUIZ, QUIZ2, CORRECT, INCORRECT | the quiz port's TextBox | not boxes |
| NEWSA..NEWSN | ShowNewspaper's slogan (DrawCenteredScreenText) | not boxes |
| SPACE (DOS only), SPACE2, ARCH, LOMEM | not loaded by LoadKingText | none |
| ERR_ (12, all paired by name), HLP_ (18) | ShowTextNoteDialog 10E0:03A2: LoadTextResource, SubstituteTextTokens, dialog 135's TextBox (rows 13, 116..118) | not MenuZ boxes: D5e's help screen (Customize) and D7g's notes; `pdos_r_pair_section` serves them by prefix |
| MAK_ (51) | ChooseCityProduction's AppendTextResource: the advisor's panel | not a box (no LoadTextResource; the substitution after it drops the noted text) |

## Design and decisions

### The section text (`pdos_r_pair_section`, pure, through the store)

1. The source: `PdosRSrc` (state 0 none, 1 loaded, 2 substituted; the DOS file of the prefix: KNG KING.TXT, ERR
   ERROR.TXT, HLP HELP.TXT, MAK PRODUCE.TXT; the name; the five values, each NUL-cut within its 32 bytes).
2. The section "*" + name read through the store (R:1F4D:01AD: its records, each followed by one space).
3. R:1F4D:0471: the five tokens replaced by the core's values, folded to DOS's characters (`pdos_fold`).
4. R:1F4D:0000(80) (`dos_breaks`, D6fSc's): '^' a space and the byte after it a line feed.
5. The core's suffix (the MenuZ text after the noted text), folded, on its own line: a line feed first unless the text
   ends with one, '\r', '\n' and "\r\n" one break each.
6. Split as R:1D05:0475 takes a box text (D6fSc's `split_box_text`): the header lines, then the '_' items.
7. Refused (0, the fallback): no source in state 2, no DOS file, no section, a text past 1023 bytes or the header's 511,
   DOS's item count not the box's.

The box then shows the pairing's header (DOS's hand breaks kept, D6fSc's rule) and its rows, row k DOS's item k
(`menu_build`, pairing 5 `PDOS_R_PAIR_SECTION`). A section pairing goes before D6fSc's named pairings for a box with no
pairing or the revolution question's (whose text is the same section); the quit, tax and luxuries pairings stay (their
texts are not loaded by name). A suffix with an item ('_') keeps the fallback.

### The DOS places (`pdos_r_dos_place`; Choice D6fSd-2)

* ShowTextDialog 1220:00D2 ignores its x and y (words 2 and 3) and calls MenuZ with (0, 0). The core passes the DOS
  box's place there, verified at these call sites against the DOS listing and SCENES-PLAY:

  | Box | The core's call | x, y | DOS |
  |---|---|---|---|
  | revolution question | 11F0:3B85 | (64, 80) | R:0403:3553..355B |
  | tax, luxuries | 11F0:3CFC, 3E4A | (100, 80) | R:0403:367F..3687, 3773..377B; R:0238:001E (F202) |
  | Retire | 11F0:401A | (100, 80) | DOS's quit place R:0403:38C6..38CD |
  | quit (command 115) | 1048:0278 | (0, 0) | its pairing's (100, 80), R:0403:38C6..38D2 |
  | disasters, own city / seen foreign city | 1040:101F / 10DC | (100, 80) / (100, 64) | SCENES-PLAY 7.6 |
  | palace | 1158:0045 | (20, 16) | SCENES-PLAY (O17's KING box) |
  | civil war | 11A0:0387 | (80, 80) | SCENES-PLAY (O15:0000) |
  | research choice | 1170:29EC | (80, 64) | SCENES-PLAY (the science advisor's choice box) |

  The other call sites' values (91 calls: (100, 80) 43, (80, 80) 15, (0, 0) 8, 25 others) follow the same pattern
  (**inferred**).
* The A place: `pdos_r_dos_place(dx, dy, mcx, mcy)` = (mcx + 2 (dx - 80), mcy + 2 (dy - 8)), where (mcx, mcy) is the
  map window's client origin (g_mapWindowPort 12B0:0004's window of class "CIV", pmap_inview.c's test) and (80, 8) the
  DOS map view's origin (R:1AEA:0008): the brief's mapping, the DOS map area's origin at the A map area's origin, 2x,
  so a box keeps DOS's place relative to the map. Then 11.3's clamp (`elem_put_a`: moved left or up inside the canvas,
  then to 0).
* Without a shown map window (no client) the box keeps B16's anchor; a box on the N canvas (the setup menus, a scene's
  N frame) keeps its N place (D7j's palace anchors its KING box at (20, 16) there already).
* D6fS-b's drop-downs use the bar's origin + 2x DOS (F252), a different origin for a different element; both land on
  the same DOS screen.

### The leader messages (D7k's boxes; the later ruling)

* The leader message (a MenuZ on the leader window, template 142, D7k's `leader_box`) shows a KING text the core
  loaded by name (1160's LoadKingText calls, then ShowLeaderMessage 1160:328E -> MenuZ(g_messageText)). It takes the
  same section rule in `menu_build` with no change to the rule: DOS's section, its tokens filled from the core's
  values, its items as the box's rows.
* D7k's layout is kept: the leader font (8 + LEADER_FONT[tribe], 10 -> 3), 8-pixel lines, DOS's (36, 139), D6fSc's
  line rule wrapping each of DOS's hand-broken lines in that font.
* **The glyphs.** `pdos_r_glyph_missing(text, len, font)` counts the bytes DOS font `font` does not draw (no advance by
  G#4, or no ink in the glyph's own columns; the breaks and the space excepted).
  * test_leader_sections: every byte of the 22 paired leader texts is drawn in every font LEADER_FONT gives the 16
    tribes, with the core's names in the slots and with every letter and digit and the names' punctuation in them.
  * At run time each paired box's count goes to presentation-diag (`mz_miss`); the harness's audience has 0.
  * fontcov (private statistics): fonts 3, 8 and 9 lack only '@' and '`' among the printable codes.
* **The close.** A paired box's items go before MenuZ returns (MenuZ destroys them first), and D7k's leader box stays
  until that return. A build then with no rows keeps DOS's text, so the core's text never shows in between.
* **The fallback**, recorded per section in the table: THREAT ("You respond": the core's answers appended after the
  noted text, so its rows are not DOS's fixed three).

### D7f's buy question (the later ruling; DERIVED for the A frame)

* DOS: R:0D12:4E26..4E37 pushes 50h, 64h and the text BA06h, then calls R:0238:0008(text, 100, 80). The core passes the
  same (0x64, 0x50) to ShowTextDialog at 1030:5CCF, so the MenuZ call carries DOS's place like the other boxes.
* D7f's renderer (pdos_rdlg.c) draws the box and asks `pdos_reskin_a_place(hwnd, pl)` for its A place.
  * D6fSd: the wrapper takes the MenuZ call whose dialog hwnd is (`pdos_seq_core()->mz_dlg`, the innermost call) and
    keeps that call's DOS place for the window until the window is destroyed (`g_rdlg_dos`). So the box does not move
    when MenuZ returns before the dialog goes.
  * A box of no MenuZ call (the production list, Find City, the name entry, the unit stack) keeps B16's anchor.
  * Each box is placed once, by one rule, so there is no double move.
* On the city screen's N frame (d7f-buy's 320 x 200 frame), D7f draws the box at DOS's (100, 80) directly and never asks
  for an A place. The A case (a buy question over an A frame) is reached by no harness run, so it is recorded as
  derived: the box at the map client + 2 x (20, 72), then the clamp.

### Choices

* **D6fSd-1:** a box shows a section by its name when its MenuZ text starts with the text the core loaded by name last
  (LoadTextResource's entry, SubstituteTextTokens's exit). This pairs every KING box without a call-site table, and
  needs no new probe key.
* **D6fSd-2:** an A box with DOS's x, y from its ShowTextDialog call (the quit question with its pairing's) stands at
  DOS's place; B16 stays for the others. This reverses Choice B16 for those boxes.
* **D6fSd-3:** the core's suffix after the loaded text stays the core's words, on its own line.
* **D6fSd-4** (the later ruling): the leader messages take the section rule in the leader font. A paired box keeps
  DOS's text while its items go before MenuZ returns.

## Deviations and limits

* **D4's suffix** is the core's sentence (folded), not DOS's DGROUP string; the words are the same.
* **The token values** are the core's (up to 31 characters); DOS's slots hold 22 bytes (DGROUP:3037..), so a value
  longer than 21 characters is not cut as DOS would.
* **A KING text the core shows outside MenuZ** (dialog 151's, the quiz's, the newspaper's) is not paired here (the
  table); their units draw them. The leader screen's messages are MenuZ boxes since D7k and are paired.
* **THREAT ("You respond")** keeps D7k's text (the core's three answers, two of them Windows-only texts). DOS's
  THREAT has three fixed items. Pairing them would need a reading of DOS's choice order, which this unit does not
  make.
* **ERROR.TXT and HELP.TXT** pair by name but reach no MenuZ box; their DOS screens (O4:0000 help, O4:03AA error note)
  belong to D5e (Customize's help, done) and D7g.
* **A ShowTextDialog box on the N canvas** keeps its N place (B16's N rule); only A boxes take DOS's place.
* **The (x, y) of the call sites not in the table above** are taken as DOS's without a per-site check (inferred).

## What was built

* **`present/dos/pdos_reskin.h`:** `PDOS_R_PAIR_SECTION` (5), `PDOS_R_PAIR_HDR` 192 -> 512, `PdosRSrc`,
  `pdos_r_src_file`, `pdos_r_src_load`, `pdos_r_src_tokens`, `pdos_r_pair_section`; `PDOS_R_MAP_X/_Y`,
  `PDOS_R_QUIT_X/_Y`, `pdos_r_dos_place`; `pdos_r_glyph_missing`; `pdos_reskin_diag2`.
* **`present/dos/pdos_reskin.c`:**
  * the pure functions above;
  * the observer part: `g_src` (the noted text), its LoadTextResource-entry and SubstituteTextTokens-exit branches;
    `MzCall.src`, `src_n`, `dos`, `dx`, `dy`; `g_std[].dx/dy` (ShowTextDialog's words 2, 3); the quit question's
    (100, 80); `menu_build`'s section pairing first (the leader message's too); `map_client`, `a_place_of`'s DOS
    place, `RBox.dos/dx/dy` (kept for `place_all`); the reset;
  * the leader messages' parts: `MzCall.sect_out`, `sect_rows`, `sect_hash`, `sect_miss` (the call's outcome from its
    build with the most rows), `sect_commit` at MenuZ's exit, the close (a paired box with no rows left keeps DOS's
    text);
  * D7f's `pdos_reskin_a_place`: the MenuZ call's DOS place by its dialog, kept per window (`g_rdlg_dos`, cleared at
    the window's destruction and at the reset);
  * presentation-diag's second line `preskin2` (the preskin line is full: 886 of 960 characters): abox_id, abox_src
    (a 31-bit FNV-1a hash of the section name, 0 none), abox_dos, abox_dx, abox_dy, abox_mcx, abox_mcy, abox_cw,
    abox_ch, then mz_id, mz_pair, mz_src (the last MenuZ box on either canvas), then mz_sect, mz_fall, mz_miss,
    mz_s0..mz_s9, mz_f0..mz_f3 (the MenuZ calls ended with a noted section: paired, unpaired, the bytes without a
    glyph; the first ten paired and four unpaired sections' hashes in order).
* **`present/present.c`, `tests/headless/harness.c`:** the `preskin2` line after `preskin` (civ64's log, the harness's
  presentation-diag.log).
* **`tests/test_pdos_reskin.c`:** `test_section`, `test_leader_sections`, `test_dos_place` ("Tests").
* **`tests/harness/ext_adapt.py`:** `preskin2`, `d6fsd_hash`, `d6fsd_place`, `d6fsd_king`; f6c-rev-cal's pairing 5; the
  click case f6d-tax; the place checks in `d6fsc_runs`, the palace's section check in `d7j_runs`; `D6FSD_NAMES`,
  `d6fsd_names`, `d6fsd_sections` and the audience's sections in `d7k_runs` (`D6FSD_LEADER_PAIRED`, `_UNPAIRED`).

## Tests

**test_pdos_reskin**, extension D6fSd (38 new checks; the store's DOS files at run time, no DOS byte in the test):

* **`test_section`:**
  * the store's files are the registry's (`pdos_assets_open` checks each pinned file's SHA-256), the prefixes' files
    (KNG, ERR, HLP, MAK; another prefix, a lower-case one and none: -1);
  * the probes' state: a load notes the name (not paired before the substitution); the substitution the core's values
    (a value without its NUL cut at 31); a second substitution without a load drops it; a substitution without a load
    does nothing; a name of 24 characters and an empty name unpaired; another prefix unpaired;
  * the 16 KING sections of the record's table and ERROR.TXT's 12 sections, each against the test's own reading of the
    DOS file (`ref_section`: the section through the store, the tokens replaced, each '^' a space and the byte after it
    a line feed, split into the header and the '_' items): the header and every row equal, DOS's item counts (FAME and
    REV two, the others none);
  * the tokens: D1's city name in `$RPLC1`, ESCHISM's two names in `$US` and `$THEM`, D5's Windows-1252 value folded;
  * REV by its name equal to D6fSc's `pdos_r_pair_text(PDOS_R_PAIR_REV)` (header and rows);
  * D4 with the core's GRANARY sentence on its own line; a suffix's CR, LF and CR LF one break each; a suffix too long
    and a suffix that adds an item: the fallback;
  * the fallbacks: SCHISM (in neither file), THREAT1 and THREAT2 (Windows only), THREAT (DOS's three items against
    one; with three it pairs), REV with one or three rows, too many rows, a negative count, no output, no source.
* **`test_leader_sections`** (5 checks): the leader fonts LEADER_FONT gives the 16 tribes (each a DOS font); the 22
  leader sections of the table paired twice against the test's reading (the core's names in the slots, then every
  letter and digit and the names' punctuation), DOS's item counts the core's (11 with two, 11 none); every byte of the
  44 paired texts drawn in each leader font (`pdos_r_glyph_missing` 0); the count's own rules (breaks and spaces
  drawn, 80h and above not, no font, the NUL); THREAT with items appended after its text, or with one row: the
  fallback.
* **`test_dos_place`:** `pdos_r_dos_place` for the quit question's (100, 80) at the client origin (171, 40) -> (211,
  184); the tax menu's at (0, 0) -> (40, 144); the revolution question's (64, 80) -> (139, 184); the palace's (20, 16)
  -> (51, 56); 1170:286F's (8, 168 - 8 x 3) -> (27, 312); the map view's origin at the client origin; then a box set at
  the quit question's DOS place on a 640 x 400 canvas (at (211, 184)), at DOS (300, 190) (past the right and bottom
  edges: moved left and up to (570, 334)) and at DOS (20, 0) from (0, 0) (left of and above the canvas: (0, 0)).

**ext_adapt**, extension D6fSd (docstring; S3's lines to 60,000 ms with the profile chord at 40,000 ms; 10 new checks):

* the five D6fSc calibrations (f6c-quit-cal, f6c-retire-cal, f6c-rev-cal, f6c-tax-cal, f6c-lux-cal): `preskin2`'s
  abox_id equal to `preskin`'s, the section (REV's hash for the revolution question, none for the others), abox_dos 1,
  DOS's x, y, the box at origin + 2 (dx - 80, dy - 8) clamped inside the canvas (abox_ax, abox_ay);
* f6c-rev-cal and f6c-rev: pairing 5 (was 2), the same header lines, rows and width;
* **f6d-tax** (new): Ctrl+T, a press and release on the DOS row 0 of the tax box at its DOS place <-> its Windows-form
  pair (a click on the core's item control where the DOS run gave it, Return at the release sync): equal coreinput,
  frames, state and events;
* **d7j-palace-dos**: the palace improvement's KING box (on the N canvas, D7j's anchor) shows the section PALACE by its
  name (mz_pair 5, mz_src PALACE's hash); the d7j-palace pair (D7j's) equal as before;
* **d7k-leader-cal, d7k-leader-dos** (D7k's audience, the later ruling): the MenuZ calls that showed a section by
  name, in their order, PEACE (the treaty offer) and TREATY (the welcome speech) paired, THREAT ("You respond") the
  fallback, no byte without a glyph in the leader font (`mz_miss` 0); D7k's own checks unchanged and passing with
  DOS's text (the d7k-leader pair's coreinput, frames and exit equal, P0; the calibration's row point from the DOS
  box's own layout);
* f6-zcover-m1 and -p1 (D6fS-a's): the hidden dialog's part beside the box may lie on any side of the box now (it
  was right of or below it with B16's anchor).

The KING boxes the harness reaches are the revolution question (S3, Ctrl+R), the palace's (D7j's PALACE.SAV route)
and the audience's (D7k's CAE3540B.SAV): the brief's two KING boxes and two leader messages, each with its pair (f6c-rev,
d7j-palace, d7k-leader). The quit and tax boxes' places: the
calibrations above with the pairs f6c-quit and f6d-tax. The Windows graphics: every pair's Windows-form run and
ext_g1 (unchanged; presentation only).

## Results (private, `build/d6fsd-stage/obj/`)

**First, on the tree after D6fSc and D7e** (`obj/run/final2.txt`, `obj/run-full1.txt`, `obj/run-tl1.txt`,
`obj/run-frames1.txt`, `obj/run-dbl1.txt`, `obj/run-c2.txt`): every build, unit program and check passed, and the
harness runs matched the tree's. The two f6-zcover lines failed until their geometric condition took any side
("Tests"). Superseded by the runs below.

**Then, on the tree after D7k** (`obj/run-k1.txt` .. `obj/run-k4.txt`; harness `obj/exe/c4`): the leader messages'
runs.

* The first run paired TREATY only. PEACE was counted unpaired, because its last build came after its items had gone
  (`obj/dbgpatch.py`, a private diagnostic never staged: suffix 0, rows 0, DOS's count 2).
* The outcome now comes from the call's build with the most rows. A paired box keeps DOS's text when its items go.
  After that: PEACE and TREATY paired, THREAT unpaired; `obj/runadapt.py cjk` 31 of 31 PASS.

**Final, on the tree after D7f's landing** (copy-in 02:30:03 UTC, RELEASE_OK 03:15:33 UTC). The overlay was made
after the copy-in. The harnesses: `obj/exe/c5` (Checked, SHA-256 ffdfb750...) and `obj/exe/n5` (CheckedNoObs,
76c1ae9e...).

* **Builds** (`obj/final-b-*.log`): Checked, CheckedNoObs, Release `BUILD_OK`, `portable sources checked: 308`, no
  warning.
* **cc.cmd** (`obj/run/final3.txt`): `CC_OK` for pdos_reskin.c, present.c, test_pdos_reskin.c and harness.c in each
  variant.
* **Unit programs** (59 each): every one PASS.

  | Program | Checked | CheckedNoObs | Release |
  |---|---|---|---|
  | test_pdos_reskin | 209 | 197 | 209 |
  | test_input | 638 | 581 | 638 |
  | test_pdos_menu | 43 | 43 | 43 |
  | test_pdos_adapt | 155 | 155 | 155 |
  | test_dos | 23281 | 23281 | 23281 |

  `obj/utcmp.py` against D7f's cycle log: 58 programs the same, test_pdos_reskin 171 -> 209.
* **Checks:** `OBS_LINT_OK files 148 probes 203 callsites 101`, `ADAPT_OK rows 153 steps 27`, `PASS pdos_scene_check:
  1084 checks, 141 scene rows, 10 font rows`, `OBS_TABLES_OK probes 203 sites 101`, `REGISTRY_OK`, `NODOS_OK` (0
  hits), the include rule clean. Each is the tree's.
* **ext_adapt, the whole staged script** (`obj/runadapt_full.py`, `obj/run-full4.txt`): `EXT_ADAPT_OK checks 329`.
  Against the tree's ext-adapt.txt (319 checks):
  * **new** (10): f6c-quit-cal, f6c-retire-cal, f6c-rev-cal, f6c-tax-cal and f6c-lux-cal at DOS's places (211, 184)
    and (139, 184) on the 640 x 480 canvas from the map client (171, 40); f6d-tax and its Windows-form pair (coreinput
    41, frames 680, events 104, equal); d7j-palace-dos's PALACE by its name; d7k-leader-cal's and -dos's sections;
  * **changed** (from the DOS places):
    * f6-zcover-m1/-p1: the box at 211,184..493,394 (was 203,101..485,311); the layer's other pixels 2956 -> 2270 and
      14758 -> 14712 (informational);
    * f6s-tax-ret/-esc: the element at 211,184..493,394; f6s-lux-esc at 211,184..549,314; f6s-rev-esc at
      139,184..593,250; each with 0 other pixels, as before;
    * f6c-rev-cal and f6c-rev: pairing 2 -> 5 (the same header, rows and width);
  * **changed** (D7k's leader line, informational): `boxes` 15 -> 14. The treaty offer's build after its items went is
    no longer made (the close). D7k's check needs at least 2;
  * every other line is the tree's.
* **ext_timeline** (the tree's script, `--exe`/`--root`, `obj/run-tl2.txt`): `EXT_TIMELINE_OK`, equal to the tree's
  file. With `--group bs` (`obj/run-tlbs.txt`): `EXT_TIMELINE_OK`, equal to the tree's ext-timeline-bs.txt.
* **ext_frames** (`obj/frames_priv.py`, `obj/run-frames2.txt`): `EXT_FRAMES_OK`, equal to the tree's file.
* **ext_dbl** (`obj/run-dbl2.txt`): `EXT_DBL_OK checks 4`, equal to the tree's file.
* **ext_p0** (`obj/run-p02c.txt`, `obj/run-p02n.txt`): Checked `P0_OK checks 476`, equal to the tree's file;
  CheckedNoObs `P0_OK checks 62` (V5 against the Checked V0 outputs, the zoom refused).
* **ext_zoom** (`obj/zoompriv.py` against a staged copy of the landed golden, `obj/run-zoom2.txt`): `ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32 centre runs 4 mzi runs 12 mzs runs 4 not zoomed 38/448`, equal to the tree's file: the golden needs no change, so the copy was removed from the stage.

## Expected changes at the build slot

Predictions: `build/d6fsd-prep/predictions.txt`, written before the copy-in. In short:

* build.cmd checked: BUILD_OK, portable sources 308 unchanged.
* test.cmd checked: TESTS_OK.
  * unit.log: test_pdos_reskin 171 -> 209; every other program unchanged.
  * ext-adapt: EXT_ADAPT_OK checks 319 -> 329, with the changed lines above (the DOS places, f6c-rev's pairing 5,
    D7k's `boxes` 15 -> 14).
  * presentation-diag.log: the new line `preskin2` after `preskin`.
  * obs-lint, adapters-check, obs-tables, pdos-scene-check, registry-check, ext-timeline, ext-zoom, ext-frames,
    ext-dbl, ext-p0 and every other section unchanged; nodos NODOS_OK, 0 hits (one more file scanned: this record).
* ext_g1.py check: EXT_G1_OK runs 77 (amended 1), unchanged (presentation only).
* build.cmd (Release): BUILD_OK.

## Rebase notes

* **D7e** (copy-in 22:59:02 UTC, manifest `build/d7e-prep/landed.sha256`) changed `tests/harness/ext_adapt.py`
  (4ddb4d4c... -> c0533da8...). The staged copy was unedited then, so it was replaced by D7e's landed file (23:10 UTC)
  before the D6fSd edits; `present/present.c` and `tests/headless/harness.c` were staged after D7e's copy-in. No
  merge was needed.
* **D7k** (copy-in 01:25:44 UTC, manifest `build/d7k-prep/landed.sha256`) changed four staged files' bases:
  `present/dos/pdos_reskin.c` (ae366835... -> 1b31475e...), `pdos_reskin.h` (a2e0a30b... -> ad208331...),
  `tests/harness/ext_adapt.py` (c0533da8... -> c166e1fe...) and `tests/headless/harness.c` (1393456c... ->
  bf3f9303..., CRLF).
  * Merged three ways (`obj/rebase_on.py d7k` into `obj/rebase-d7k`: base the stage's recorded base, theirs D7k's
    landed file, each equal to its manifest hash). `harness.c` merged cleanly.
  * Three conflicts, both sides kept, D7k's first (`obj/resolve_d7k.py`): `menu_build`'s end (D7k's leader note, then
    D6fSd's `mz_d6fsd`), the header's extension blocks, ext_adapt's docstring paragraphs.
  * The bases were then replaced by D7k's landed files (`obj/base/BASES.txt`; the pre-D7k bases kept in
    `obj/base-pre-d7k`, the pre-D7k staged copies in `obj/stage-pre-d7k`).
  * D7k's leader message became a box after D6fSd was built, so the later ruling (the leader messages paired)
    followed: `menu_build` needed no new condition, only the outcome record, the close and the audience's checks.
* **D7f** (copy-in 02:30:03 UTC, manifest `build/d7f-prep/landed.sha256`) changed the same four bases:
  `pdos_reskin.c` (1b31475e... -> 4e526c70...), `pdos_reskin.h` (ad208331... -> 33e1cd78...), `ext_adapt.py`
  (c166e1fe... -> 06c23086...) and `harness.c` (bf3f9303... -> 538cfe74...). Each landed file equals D7f's staged copy,
  and each "tree before" equals this stage's D7k base.
  * Merged three ways (`obj/rebase_on.py d7f` into `obj/rebase-d7f`; a merge against D7f's staged copies before its
    copy-in, `obj/rebase-d7f-pre`, gave the same results). `pdos_reskin.c`, `.h` and `harness.c` merged cleanly.
  * One conflict, ext_adapt's docstring paragraphs: both kept, D7f's first (`obj/resolve_d7f.py`).
  * D7f's wrapper `pdos_reskin_a_place` was rewritten for `a_place_of`'s D6fSd arguments (the buy question's DOS
    place, "Design"). `g_rdlg_dos` was added with its reset and its clearing at the window's destruction.
  * The bases were then replaced by D7f's landed files (`obj/base/BASES.txt`; the D7k bases kept in `obj/base-pre-d7f`,
    the pre-D7f staged copies in `obj/stage-pre-d7f`).
  * The buy box's place after both landings: on the city screen's N frame, D7f's own DOS (100, 80), unchanged
    (d7f-buy's checks). On an A frame, DOS's (100, 80) mapped and clamped, once (derived).

## What the user checks

On the user build of this unit, in play with the DOS graphics (`--graphics dos` or Ctrl+Shift+Backspace), the main map
window active. In DOSBox the DOS game's boxes stand at these places of its 320 x 200 screen; the map area starts at
(80, 8) there, so in civ64 each box keeps the same place relative to the map area (at 2x).

* **D6fSd-1** (the quit and Retire questions' place).
  * Open GAME > QUIT to DOS (or Alt+Q, or Ctrl+Q). The box (D6fSc-1's text) now stands where the DOS game shows it:
    its top-left corner a little right of the map area's left edge (about 20 DOS pixels in) and about two fifths down
    the map area (DOS (100, 80)), no longer where the Windows dialog would open.
  * GAME > Retire: the same box at the same place.
  * Escape or "Keep Playing": the game goes on.
* **D6fSd-2** (the tax and luxuries boxes' place). GAME > Tax Rate (Ctrl+T) and GAME > Luxuries Rate (Ctrl+L): the
  boxes (D6fSc-4's texts) stand at the same place as the quit question, their top-left at DOS (100, 80). A click on a
  rate's row sets that rate; Escape keeps the rates.
* **D6fSd-3** (the REVOLUTION! question). GAME > REVOLUTION! (Ctrl+R): the same text as D6fSc-3 (now read as the DOS
  game's KING.TXT section of its name). The box's left edge is a little left of the map area's left edge (DOS (64,
  80): 16 DOS pixels left of the map), at the quit box's height. Escape or "No thanks.": nothing happens.
* **D6fSd-4** (the palace improvement's message, a celebration of your civilization; D7j-2's way to reach it). The
  first box, at the top left over the palace as before, shows the DOS game's own palace message: its words, capitals
  and line breaks as in DOSBox (no longer the Windows game's words). Return or a click goes on as in D7j-2.
* **D6fSd-5** (the other KING messages, if a game or save reaches one). A disaster in one of your cities (an
  earthquake, a fire, a flood, a plague and the others), or another of the game's messages from its KING texts (the
  record's table: 16 in all, among them the Domestic Advisor's notes and a civil war's message): the box shows the
  DOS game's own text with your game's names in it (for example the city's name in a disaster), broken into lines as
  in DOSBox, and stands at the DOS game's place (a disaster in your own city where the quit box stands; in a foreign
  city you have seen, a little higher). When the Windows game adds a sentence of its own to a disaster's message
  ("Citizens demand GRANARY."), it follows on its own line. At a new game's start the Civilization Notes are other
  boxes (the Windows game's notes, D7g) and do not change here.
* **D6fSd-6** (the other boxes' places). Every other box that the Windows game opens with its place for the DOS game
  (for example the science advisor's choice of the next discovery, at DOS (80, 64)) stands at that DOS place; a
  message box with only OK, Yes or No buttons keeps its place.
* **D6fSd-7** (the Windows graphics unchanged). Ctrl+Shift+Backspace to the Windows graphics while no box is open,
  then open the same boxes: they are the Windows game's dialogs with its own words, at the Windows places.
* **D6fSd-8** (the leader's words in an audience; D7k-1 and D7k-2's way: load `CAE3540B.SAV`, end the turn, answer
  Yes to the Zulu emissary). On the throne room's stone panel, in the leader's decorated font as in D7k:
  * the treaty offer shows the DOS game's own words, with its line breaks and its two rows (Reject, Accept);
  * after Accept, the welcome speech shows the DOS game's words too;
  * the "You respond" box with three answers keeps the Windows game's words (its answers are the Windows game's own);
  * every letter is drawn, the leader's and the civilizations' names included;
  * the emissary's question before the audience and the greeting are not KING texts and do not change.
  Any other audience later in a game: the leader's speeches show the DOS game's words the same way (the record's
  table: 22 kinds of speech).

Not part of this check: the research choice's and the other header boxes' texts (D7g), the Civilopedia (D7h), the
Civilization Notes (D7g).

**D7k's items whose wording changes (the orchestrator rewrites those rows at the landing):** D7k-2 (the treaty offer's
text and the welcome speech are now the DOS game's words; the rows Reject and Accept are DOS's rows, with the same
words, at the same places; "You respond" keeps the Windows game's words). D7k-1 (the emissary's question, the
greeting), D7k-3 and D7k-4 keep their wording.

D7k-2's new wording, for the checklist verbatim:

* **D7k-2** The treaty offer: the DOS game's own words with its line breaks, then two rows (Reject, Accept) under the
  text on the panel, one highlighted; the arrow keys move the highlight, a letter (A, R) or Enter chooses, a click on
  a row chooses it. After Accept a welcome speech in the DOS game's words and a "You respond" box with three answers
  (the Windows game's words) follow in the same place and font; each speech replaces the previous text; after the
  last the map returns with the fade from black.

## For the records

* **F-new-1 (FIDELITY; Choice D6fSd-1; closes OPEN L29).**
  * In the DOS graphics a MenuZ box whose text is a text the core loaded by name (LoadTextResource 11D0:00E4's entry,
    SubstituteTextTokens 11D0:022D's exit; LoadKingText 11D0:01F7's "KNG" prefix) shows the DOS section of the same
    name: KNG_ KING.TXT, ERR_ ERROR.TXT, HLP_ HELP.TXT, MAK_ PRODUCE.TXT (CORR finding 8), read at run time through the
    store (R:1F4D:01AD), R:1F4D:0471's tokens filled from the core's values g_textSubstParams 13C8:0000 (folded),
    R:1F4D:0000(80)'s breaks, its '_' items as the box's rows; the core's suffix after the loaded text on its own line.
  * Paired: the 16 KING sections the core shows through ShowTextDialog (the record's table), the revolution question
    among them (the same text as F266's pairing, now by its name).
  * The fallback (the core's text by F267's line rule): a section neither file has (SCHISM), a section DOS lacks, DOS's
    item count not the box's, items the core appended after the noted text, a text past 1023 bytes. Dialog 151's, the
    quiz's and the newspaper's KING texts and the HLP_/ERR_/MAK_ texts are not MenuZ boxes (their units').
  * No observer table change: the probe keys existed (D3).
* **F-new-2 (FIDELITY; Choice D6fSd-2; reverses Choice B16 for these boxes; closes OPEN L30).**
  * In play an A box (a MenuZ box of dialog 136 or 145) whose ShowTextDialog call carries x, y other than (0, 0)
    stands at DOS's place: the DOS map view's origin (80, 8) (R:1AEA:0008) at the map window's client origin, 2x, then
    the clamp inside the canvas (11.3). The quit question (command 115's (0, 0), 1048:0278) uses its pairing's
    (100, 80) (R:0403:38C6..38D2).
  * Verified call sites: the record's place table (revolution (64, 80), tax, luxuries, Retire, quit (100, 80),
    disasters (100, 80) / (100, 64), palace (20, 16), civil war (80, 80), research choice (80, 64)); the others
    inferred.
  * The other boxes (message boxes, the (0, 0) calls, no shown map window) keep B16's anchor; boxes on the N canvas
    keep their N place.
  * F202: a "Since D6fSd" note (B16 kept only for the boxes without DOS values).
  * D7f's buy question (1030:5CCF's (100, 80) = R:0D12:4E26..4E37's R:0238:0008(text, 100, 80)) takes its DOS place by
    the same rule through `pdos_reskin_a_place`, per window; on the city screen's N frame D7f's own (100, 80). The A
    case is derived (no harness run reaches it).
* **F-new-3 (FIDELITY; Choice D6fSd-3):** the core's suffix after a section text keeps the core's words (D4's
  GRANARY sentence), on its own line as DOS's strcat after R:1F4D:0000's line feed; the token values are not cut to
  DOS's 22-byte slots.
* **F-new-4 (FIDELITY; Choice D6fSd-4; the orchestrator's later ruling of 2026-10-18).**
  * The leader messages (D7k's boxes: ShowLeaderMessage 1160:328E's MenuZ on the leader window, template 142) take
    F-new-1's rule in D7k's leader font (8 + LEADER_FONT[tribe], 10 -> 3) and layout (DOS's (36, 139), 8-pixel lines).
  * 22 sections paired by name (the record's table). Every byte of their texts is drawn in each leader font
    (`pdos_r_glyph_missing`; the tokens from the core's names included).
  * THREAT ("You respond", 1160:197E..1A25: the core's Windows-only answers appended) keeps D7k's text (the fallback).
  * A paired box whose items go before MenuZ returns keeps DOS's text until it goes.
  * D7k's d7k-leader pair (core outputs equal, P0) passes with DOS's text.
* **OPEN:** L29 and L30 closed by D6fSd (F-new-1, F-new-2).
* **DESIGN 12.9 "As implemented (D6fSd)":** `PdosRSrc`, `pdos_r_src_*`, `pdos_r_pair_section`, `PDOS_R_PAIR_SECTION`;
  the probes' branches in `pdos_reskin_on_probe`; `MzCall.src`/`src_n`/`dos`/`dx`/`dy`, `g_std[].dx/dy`;
  `pdos_r_dos_place`, `map_client`, `a_place_of`'s DOS place, `RBox.dos/dx/dy`; `pdos_reskin_diag2`; the leader
  messages (`pdos_r_glyph_missing`, `MzCall.sect_*`, `sect_commit`, the close); D7f's `pdos_reskin_a_place` by the
  MenuZ call (`g_rdlg_dos`).
* **RUNNING.md:** presentation-diag.log's new line `preskin2` (abox_id, abox_src, abox_dos, abox_dx, abox_dy,
  abox_mcx, abox_mcy, abox_cw, abox_ch, mz_id, mz_pair, mz_src, mz_sect, mz_fall, mz_miss, mz_s0..mz_s9,
  mz_f0..mz_f3; abox_src, mz_src and the mz_s/mz_f values a 31-bit FNV-1a hash of the section name); `abox_pair` /
  `mz_pair` 5 = a section by its name; ext_adapt's D6fSd checks (the five calibrations' places, f6d-tax with its
  Windows-form pair, the palace's section in d7j-palace, the audience's sections in d7k-leader-cal and -dos).
* **FEATURES.md:** the DOS boxes' KING.TXT texts by name (the leader's speeches in an audience too) and their DOS
  places, with the runners above.
* **DOS-PROFILE.md** (prose): rows 14 and 22 (MenuZ 136, 145): the section texts by name and the DOS place; row 19
  (the leader message, D7k's): the section texts by name in the leader font; row 87 (D7f's buy question): its DOS
  place on an A frame; the
  consumers of the probe keys LoadTextResource (entry) and SubstituteTextTokens (exit) (no new call-site row: the
  presentation reads them by key, so `obs_tables` is unchanged).
* **manual-checklist-ext.md:** the new items D6fSd-1..D6fSd-8 ("What the user checks"). D6fSc-1..4's places are now
  D6fSd-1..3's. D7k-2's wording changes (the treaty offer's text and the welcome speech: DOS's words): the
  orchestrator rewrites that row at the landing.
* **Not edited by this unit:** DESIGN.md, FIDELITY.md, STATUS.md, RUNNING.md, FEATURES.md, DOS-PROFILE.md, OPEN.md,
  manual-checklist-ext.md, the D1 drafts and the D0 documents.

## Landing

D6fSd landed alone at the build slot of session E4, 2026-10-18, after D7f's landing (RELEASE_OK 03:15:33 UTC,
`build/user-builds/d7f/`). The orchestrator accepted it and said to land at once: the slot had been free since D7f's
RELEASE_OK, and the docs pass e4h (D7k + D7f + D6fSd) applies after this landing. The user checks are D6fSd-1..D6fSd-8
in the user build `d6fsd` ("What the user checks"). D7k-2's new wording is given there for the checklist.

**Bases**

* The stage was rebased onto D7k's landing and then D7f's ("Rebase notes"). The overlay was rebuilt and every check
  run again on the tree after D7f ("Results").
* `BASE-SHA256.txt` was written by `obj/mkbases.py` (BASES rows 7, problems 0). It was rechecked at 04:27 UTC: every
  base equal to the tree.
* `build/d6fsd-prep/land.py` rechecked it: every base equal, the record absent, build.cmd and test.cmd unchanged
  (DRY_RUN_OK 7).

**Scripts** in `build/d6fsd-prep/`:

* `land.py`, `d6fsd-cycle.ps1` and `compare.py`: from D6fSc's (`mk_prep.py`), for this stage's 6 changed rows and no
  new file;
* `mk_userbuild.py`: from D7k's, with its copy of CAE3540B.SAV (`mk_userbuild_gen.py`);
* `fill_stillopen.py`: from D7f's, with the group "d7f" added (`mk_fill.py`).

**Copy-in**

* Snapshots: `build/d6fsd-prep/before` (the tree's `build/test/Checked` outputs of D7f's cycle) and `tree-before` (the
  six replaced files).
* Copy-in at 04:28:49 UTC. `landed.sha256` lists the 7 files (each rechecked equal to the tree after the copy-in);
  build.cmd and test.cmd are unchanged. `landed-at.txt` reads "unit d6fsd".
* The predictions (`build/d6fsd-prep/predictions.txt`) were written before the copy-in.

**The three-step cycle** (`build/d6fsd-status.txt`; each step is guarded by its log's OK marker):

1. `build.cmd checked`: BUILD_OK, 04:29:10..04:33:22 (252 s); portable sources checked 308.
2. `test.cmd checked`: TESTS_OK, 04:33:22..05:06:44 (2002 s).
3. `ext_g1.py check`: EXT_G1_OK runs 77 (amended 1), unchanged. Result: **ALL_GREEN** (05:06:44 UTC).
4. `build.cmd` (Release): BUILD_OK, 05:07:09..05:11:37 (268 s). Result: **RELEASE_OK**.

**Against the predictions** (`build/d6fsd-prep/compare.py` against the snapshot; `compare.txt`: 59 of 66 files equal,
host times left out). Everything came out as predicted:

* unit.log: test_pdos_reskin 171 -> 209; every other count equal.
* ext-adapt: EXT_ADAPT_OK checks 319 -> 329. The ten new lines and the changed lines are the predicted ones (the DOS
  places, f6c-rev's pairing 5, D7k's leader `boxes` 15 -> 14). The whole file equals the private run
  `obj/run/full4-lines.txt`, the f6s lines that compare.py's host-time filter leaves out included.
* Unchanged: obs-lint, adapters-check, obs-tables, pdos-scene-check, registry-check, dos-decoded, ext-timeline (and
  its bs group), ext-zoom (ZOOM_OK, the landed golden), ext-frames, ext-dbl (checks 4), ext-p0 (P0_OK checks 476) and
  every other section.
* nodos: NODOS_OK, 0 hits; files 1824 -> 1825 (the record).

Not predicted in detail, explained:

* (a) coverage.txt "other functions entered" 670 -> 669. This count is informational; it varies between landings.
* (b) unit.log's OBS_COST line and sections/times.txt (host timing).

**User build** `build/user-builds/d6fsd/`:

* `civ64.exe`: the Release build, SHA-256 e8e17e4d...;
* `CIVWIN.zip` and `civdos.zip` from `build/user-builds/d4/`;
* `CAE3540B.SAV` from `build/gamedata` (the audience of D6fSd-8, D7k-1 and D7k-2);
* `WHAT-TO-CHECK.txt`: D6fSd-1..D6fSd-8, the earlier builds up to "d7f", and the 136 items still pending in the
  checklist at 05:12 UTC.

**Not done at this slot:**

* the checklist rows D6fSd-1..D6fSd-8, D7k-2's new wording and STATUS (the orchestrator's, from "What the user
  checks");
* the docs pass e4h ("For the records"; FIDELITY entries F-new-1..F-new-4).

The tree's CheckedNoObs build is not part of the three-step cycle; the private overlay's three variants are in
"Results".

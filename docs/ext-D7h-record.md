# Extension phase D7, unit D7h (the Civilopedia) - record

Draft for the build slot (BRIEF-d7.md "Units" D7h: rows 11, 79..84 and 99; P13..P15, T19, E11; decision 10 and OPEN
L24; extension session E4, track C).  Staged in `build/d7h-stage/` on the tree after D7f's landing, rebased onto the
landings of D6fSd, D7n and D7g and the docs passes e4h and e4i (section "Rebase notes"); the base of every staged file is recorded in
`BASE-SHA256.txt`.  Private builds and runs in `build/d7h-stage/obj/` only: an overlay `obj/src` = the tree + this
unit's edits, built with the tree's build.cmd and flags (`obj/b.cmd`, `--nogen`), cc.cmd's stricter checks per file
(`obj/cc.cmd`), the unit programs (`obj/unit.py`) and the harness runs from the overlay's binaries (`obj/runadapt.py`,
`obj/suites.sh`, `obj/runp0.py`) with every output under `obj/`; the tree's build/gamedata, dosdata, dos/disasm and
cache read only.

## Result

With the DOS graphics the Civilopedia is DOS's overlay O8, drawn on the N canvas (320 x 200 at the integer scale) over
the core's Windows Civilopedia (P0: read through w16q_*, no core call, no core random draw):

* **The index** (rows 79..84: Civilopedia > Complete, Civilization Advances, City Improvements, Military Units,
  Terrain Types, Miscellaneous; the core's ShowCivilopediaSection 1068:0295 and its list dialog 130): DOS's O8:0000 /
  O8:0066: the screen in colour 14, the title bar (60, 2, 200, 9) with the section's title, "EXIT" at the top right,
  "MORE" at the top left of the complete index, the list area in colour 15 and the names in DOS's order (O8:0066's
  case-blind selection sort; a name in two categories once), 26 rows of 7 pixels a column, columns of 100 pixels (150
  for one category) until x 300, the next 78 entries after MORE.  DOS's mouse mode: a click on a name opens its entry,
  MORE pages, EXIT, any key or the right button leaves the index (the list dialog's own cancel); no highlight (DOS
  draws its cursor only without a mouse; ruling H2).
* **The entry page** (rows 11 and 99: from the index, from ShowCivilopediaEntry: Alt+H on the science advisor's
  research choice (dialog 145), the production list's help (D7f-2), the city and map help): DOS's O8:062A: the grey
  screen (colour 253, DAC (61, 61, 61); 255 without pictures), the ornamental border (R:0866:260E, its tiles from
  pdos_fx's "border" stream), the picture of the kind (the first cell of `ICONPG_ADVANCE` / `ICONPG_UNIT` /
  `ICONPG_TERRAIN` equal to the item, P13..P15, centred by O8:16F7; an improvement's cell of `CITYPIX2.PIC`, T19, 49 x
  49, copied, no zoom; a unit's page also civilization 1's unit shape), the palette of the kind (E11:
  `pdos_recipe_pedia` with `ICONPG1.PAL` / `ICONPGA.PAL` / `HILL.PAL`, `pdos_recipe_terrain_page` with `SP256.PAL`,
  `pdos_recipe_grey253`), the category label in font 7 and the name upper-cased in font 6.  With the game option
  "Civilopedia text" (40h) and a "*NAME" section in `BLURB<c>.TXT`: page A, DOS's text (the pointer hidden), then at a
  key or click page B: the second text "*NAME2" and the details (requirements, what the advance allows, cost, upkeep,
  strengths, the terrain's yields and costs, the human player's source of the advance); a key or click ends the page.
  A terrain shows DOS's two pages over the core's single wait.  The production list's help shows the page without
  pictures, as DOS does (R:0ADE:14A6).
* **Decision 10**: the body is DOS's text, by evidence (section "Decision 10"): the core's entry and DOS's O8:062A
  name the same (category, item), and O8:062A looks its texts up by that item's DOS name; OPEN L24's fallback is not
  needed.

No Go Back or Cancel row is drawn (the user's rule of 2026-10-16): EXIT is DOS's own label; Escape and every other key
on the index is DOS's EXIT, the list dialog's own cancel (FCE).  The Windows graphics are unchanged.

## Status

READY_TO_BUILD (staged, rebased onto D7g's landing and the docs pass e4i; the private builds, units and runs in section "Results").  Built:
rows 11, 79..84 and 99 in a new module `present/dos/pdos_scn_pedia.c/.h`; rows 79..84 counted N (were R:
DOS-PROFILE 1.3 and 1.8, the scene table); the adapter scene PDOS_AS_PEDIA = 0x100000000 (the orchestrator: "AS is
full; if you need a bit, widen it to 64 and say so": the scene fields `PdosAdaptSc.scene` and `PdosAdaptRow.scene` are
64 bits now, PEDIA the first bit past 32, 0x80000000 left free) with seven I-pedia rows and the decision
PDOS_DEC_PEDIA; the list pick of `pdos_rdlg.c` widened to the multicolumn list box; the registry tables PEDIA_TEXTS, PEDIA_CONCEPTS, TERRAIN_RECORDS and
TERRAIN_RULES.  No shadow owner taken (the surfaces through the existing owner "palace"; PDOS_OWNER_MAX 10, 9 used,
unchanged), no AA bit, no new core-state value.  Not built: the keyboard mode's G#3 cursor (DOS draws it only without
a mouse; "Deviations" 3).

## What was built

### The module `pdos_scn_pedia.c/.h` (area B; P0)

The run follows the core by probes: ShowCivilopediaSection 1068:0295 (entry: the section, the index drawn; exit: the
index's end, DOS's O8:0053 exit kind R:0238:1B44), ShowCivilopediaEntry 1020:0000 (entry: the N page and its DAC
saved; the return address 1170:1C69 names the production list's help, no pictures; exit: the N page restored when the
entry was drawn over an N screen, else the exit kind R:0238:1B44), ShowPediaEntry 1068:06AF (entry: the page, from
its (category, index) arguments; exit: the index drawn again after an entry of the index), CopyPortToWindow at 1068:1B49
(the core's page B shown: DOS's page B drawn), the dialog 130 creations (GR_DialogOpen 1020:0045 of the entry,
RunListBoxDialog's at 1068:0544 of the section) and their destructions.  The rows (79, 11, 99) are set ready while
their part runs and restored after (`pdos_scene_set_ready`).

* **The index** (`pdos_pedia_index_build`, `_draw`, `_at`, `_hit`, `_next`): O8:0066's selection sort from entry
  `start` over the DOS names of the section's categories (advances 0..66, improvements 1..45, units 0..27, terrain
  0..11, the 21 concepts; R:2045:28F0's comparison with letters folded to lower case; the next name above the last one
  drawn, an equal name once), the frame of O8:0000 (the title twice, "EXIT", "MORE"), the play palette (O8:0000 saves
  and restores the screen's palette; the N DAC is the play palette), font 1 (inferred: O8:1655 sets it back to 1).
* **The entry page** (`pdos_pedia_page_base`, `_page_a`, `_page_b`, `pdos_pedia_details`): O8:062A..1655 as in
  "Result"; the labels and every detail line's words are DOS's strings (PEDIA_TEXTS, DGROUP:3C8E..3FA2), the names
  DOS's records (ADVANCE_NAMES, IMPR_RECORDS, UNIT_RECORDS, TERRAIN_RECORDS, PEDIA_CONCEPTS), the costs and rules
  DOS's tables (TERRAIN_RULES); the advance's source from the core (g_advanceSource of the human player, the
  civilization's plural name folded, B13); the unit shapes and improvement icons on page B from the shape store and
  page 2 (R:0D12:7045).
* **The waits**: the core's RunPediaModalLoop waits once per page it has (1068:1259 for page A with the option or for a
  terrain; 1068:1B6C after page B, which a terrain has not); DOS waits once per page it shows.  A terrain with page A:
  the first key or press draws DOS's page B without the core (the turn, a view action), the next one ends the core's
  wait.  The option without a "*NAME" section: DOS shows page B at once, the core still waits twice (counted
  `skip_a`; "Deviations" 5).
* **The page's key**: DOS's wait takes any key or button (R:1459:0918).  The core continues on WM_CHAR 0Dh
  (RunPediaModalLoop's test) or on the OK's command 65h (dialog 130's OK 101, BS_DEFPUSHBUTTON; Space on the focused
  OK is its BN_CLICKED).  Return, and Space while the keyboard focus is the page dialog's OK (the query `focus_ok`:
  w16q_focus, its id 101, class BUTTON, parent the page's dialog), are that continue already and are passed as the
  Windows graphics take them (PDOS_RDV_PASS, counted `passes`); any other key and both buttons produce Return.
* **The pointer**: hidden while page A shows (O8:063F .. R:1459:0918 shows none), shown with page B (O8:165E) and in
  the index's wait (O8:040C); `pdos_pedia_pointer_hidden` joins the profile's cursor rule.
* **The surfaces**: dialog 130's windows of the section and of ShowCivilopediaEntry (and their controls) and the pedia
  port's bitmap (g_pediaPort +1Ah) are claimed while the Civilopedia runs through the owner "palace"
  (`pdos_scn_palace.c` asks `pdos_pedia_claim` after the leader's; `pdos_pedia_owns`, `pdos_pedia_absorb`): every core
  drawing on them is absorbed, as the leader screen's (D7k).  `pdos_replay.c` counts such shadows (`pedia`) and draws
  nothing for them.

### Decision 10 (the body text)

The brief's proposal: the core's text unless D7h shows from O8:062A and the core's lookup how a core entry pairs with a
BLURB section.  The listing and the core's reconstruction show the pairing:

* O8:062A(item, category) builds its section names from the DOS name of (category, item): "*" + strupr(name) at
  O8:07B5..0830 for page A, the same + "2" at O8:089C..08A4 for page B, looked up in `BLURB<c>.TXT` whose digit is
  '0' + category (DGROUP:3FA9, O8:0632..0637).
* The core's ShowCivilopediaEntry(index, kind) calls ShowPediaEntry(kind + 1, index) (1020:0092..00C3); its kinds are
  DOS's categories (0 advances, 1 improvements, 2 units, 3 terrain, 4 concepts) and its index is DOS's item (an
  improvement's core index is DOS's item - 1: `pdos_pedia_from_core`).  A list choice is OnCivilopediaListSelect
  1068:056E's section and position in the core's original list (g_pediaItemsCopy, the blocks of g_pediaSectionIds /
  g_pediaSectionEnds), the same (category, item).
* So every core entry has exactly one DOS item, and its body is DOS's own text of that item's DOS name: the page shows
  DOS's text (labelled by this evidence in pdos_scn_pedia.h), never the core's.  OPEN L24's fallback rule (answered
  by D6fSd's survey for the KNG_, ERR_, HLP_ and MAK_ sections: the core's text where a DOS section is missing) is not
  needed here: no core entry lacks its DOS item, and a BLURB section DOS lacks is DOS's own page without that text
  (O8:0846 shows no page A, O8:089C no second text), which the port keeps.

The same pairing, inverted, makes an index pick: the DOS entry (category, item) gives the core's section id
category + 1 and the position (item - 1 for an improvement), whose string in g_pediaItemsCopy names the list box's
item (the first equal item; OnCivilopediaListSelect resolves the text to its first position again).

### The adapter rows (area C; C.12.7 I-pedia)

While the Civilopedia shows (`pdos_pedia_state`), the scene is PDOS_AS_PEDIA (0x100000000, asked before every other N
scene in `def_scene`) with the list dialog (or the entry's dialog 130) as r_hwnd; the core state is READY while the
section's list dialog is active (the index), INTRO while an entry page waits, WAIT otherwise (the list dialog's
creation, ShowCivilopediaEntry before its page).  One decision PDOS_DEC_PEDIA asks `pdos_pedia_decide` (a hook
`pedia` for the tests) and makes its answer with D7f's `rlist_out`.  Rows (pdos_adapt_tab.c, before I-space):

| Row | Actions | Decision |
|---|---|---|
| I-pedia/mod | Ctrl, Shift, Alt, a lock key | consumed |
| I-pedia/index-key | a key on the index | EXIT (O8:0474..048F): the list dialog's cancel (FCE's Escape: WM_CHAR 1Bh to the dialog); Escape itself is FCE's before the rows, the same cancel |
| I-pedia/index-press | a press on the index | an entry: the core's list item of the same (category, item) made the list box's selection (`pdos_rd_lb_pick`'s steps, a click when shown), then Return at LB_SEL; MORE: DOS's next page (a view action); EXIT or the right button: the dialog's cancel; another place: nothing |
| I-pedia/page-key | a key on a page | Return, and Space while the page's OK 101 has the focus: passed with their repeats and releases (RunPediaModalLoop's continue already: its WM_CHAR 0Dh, the OK's BN_CLICKED, command 65h; the decision PDOS_RDV_PASS); another key: Return pressed and released; a terrain's first key: DOS's page B (consumed) |
| I-pedia/page-press | a press on a page | as the key; the release consumed |
| I-pedia/char | WM_CHAR | consumed (the key press decided) |
| I-pedia/other | anything in WAIT | consumed |

`pdos_rdlg.c`'s list pick learns the multicolumn list box (LBS_MULTICOLUMN, the Civilopedia's: RunListBoxDialog
1098:1AB5..1AFF makes its columns a third of its width; user_listbox.c's rules: a column of `rows` items, the top a
whole column, Page Down / Up by rows x the shown columns); `PdosRdLb.colw` (0 one column).  The pick finds the
Civilopedia's list box while its dialog is active (`pdos_pedia_list`).

### The scene table and the registry

* Rows 79..84 (`pdos_scene_tab.c`): class R -> N with PDOS_RD_REPLAY (the DOS index is a full screen, not a menu box);
  DOS-PROFILE 1.3's rows, row 11's class cell and note, and 1.8's counts (MENU 128: 24 N, 22 R; the scene table: 141
  rows, 65 N, 38 R, 30 A, 8 W); `tests/test_pdos_scene.c`'s count check.
* OFFSETS.md (and the generated `pdos_registry.c/.h`, `tests/dos-decoded.txt`): PEDIA_TEXTS (DGROUP:3C8E, 72 strings),
  PEDIA_CONCEPTS (DGROUP:3C64, 21 pointers), TERRAIN_RECORDS (DGROUP:0282, 24 records of 19 bytes), TERRAIN_RULES
  (DGROUP:044A, 12 records of 12 bytes), each with its O8 readers; `registry.py`'s OBSERVER_FILES += `pdos_scn_pedia.c`.

### Evidence labels

* DOS listing: every O8:, R: and DGROUP address above (build/dos/disasm ovl08.lst and root.lst, read only); DOS file:
  the registry's tables, the BLURB sections, the pictures and fonts; the Windows side from the port's reconstruction
  (core seg 1068, 1020, 1098, 1170).
* Inferred: the index's font 1 (O8:0000 sets none; O8:1655 restores 1 after a page); the N page restored after
  ShowCivilopediaEntry (DOS fills (8, 8, 304, 184), restores its palette and its caller redraws: the port keeps the
  snapshot); the exit kinds after an entry (none over an N screen, R:0238:1B44 otherwise).
* DOS oracle: none (no DOS program run).

## Files

Changed (bases in `BASE-SHA256.txt`): `present/dos/pdos_adapt.c/.h`, `pdos_adapt_tab.c`, `pdos_profile.c` (reset,
event, probes, the cursor rule), `pdos_rdlg.c/.h` (the multicolumn pick; PDOS_RDV_PASS), `pdos_registry.c/.h` (generated),
`pdos_replay.c/.h` (the `pedia` count), `pdos_scene_tab.c` (rows 79..84), `pdos_scn_palace.c` (the claims),
`pdos_seq.c` (the step log), `gen/dos/adapters.py`, `gen/dos/registry.py`, `docs/DOS-PROFILE.md` (rows 11, 79..84, 1.8,
1.7.2 regenerated), `docs/dos/OFFSETS.md`, `tests/test_input.c`, `tests/test_pdos_rdlg.c`, `tests/test_pdos_scene.c`,
`tests/dos-decoded.txt`, `tests/headless/harness.c` (the `pedia` diag line), `tests/harness/ext_adapt.py` (the D7h
pair; D7g's rows, deviation 10).  New: `present/dos/pdos_scn_pedia.c/.h`, `tests/test_pdos_pedia.c`, this record.  The ICONPG cell lookup is a stable
interface for D7i (the orchestrator, 06:50 UTC: D7i stacks on it): `pdos_pedia_cell(tab, n, item)` (the first cell of
a lookup table equal to the item, -1 none; O8:16C4 / 1790 / 17C3), `pdos_pedia_cell_rect(cat, cell, &PdosPediaCell)`
(the cell's rectangle in its picture for categories 0, 2 and 3, through `pdos_pedia_copy_rect`, O8:16F7) and
`PdosPediaCell` (pdos_scn_pedia.h); the tables are the registry's `ICONPG_ADVANCE`, `ICONPG_UNIT` and
`ICONPG_TERRAIN`.  Unchanged, though the brief
lists them: `pdos_reskin.c` (the index is N, not an R menu box; the list dialog is under the N frame) and `pdos_prov.c`
(the page draws its pictures from the DOS files itself; no core cut needs a T rule).  build.cmd and test.cmd unchanged
(new files are found by their globs).

## Tests

* **`tests/test_pdos_pedia.c`** (new; every query injected: synthetic tables, strings, pictures and sections of its
  own, no DOS byte): the listing's rules (the comparison, the cell lookups, the cells and O8:16F7's clip and centring,
  CITYPIX2's cells, the improvement icons, centres, labels, the core's categories and decision 10's positions); the
  index on synthetic names (the sort, columns, MORE's next start, a press's entry, MORE and EXIT, the frame's pixels);
  the details of an advance, an improvement, a unit and a terrain; a run through the module on a synthetic stream (the
  section, its list dialog, INDEX, a pick paired with the core's list item, MORE, EXIT, a page with its picture,
  background and grey, Return, the index again, a terrain's turn, the option without "*NAME", the section's end,
  ShowCivilopediaEntry from the research choice with the N page restored, the production help without pictures, the
  claims, Return and Space passed on a page (Space only with the page's OK focused), the diag line).
* **`tests/test_pdos_rdlg.c`**: `test_pick_mc` (the multicolumn list box: a shown item; Page Down, then the click; End;
  Home from a top inside a column; without the focus; already selected; no room).
* **`tests/test_input.c`**: thirteen I-pedia vectors (mod; the index's key: a pick and EXIT; the index's press: a pick
  and nothing; the page's key: Return's pair, the turn, Return and Space passed; the page's press, both buttons; char;
  WAIT) and `adapt_pedia` (the pick's events, a repeat and the release consumed, EXIT refused without the FCE dialog,
  MORE, the page's Return pair, the turn, Return and Space passed with a repeat and their releases, the right button,
  the index not ready); the row count 154 -> 161 (D7g's 154).
* **`tests/test_pdos_scene.c`**: the class counts 65 N, 38 R, 30 A, 8 W.
* **`tests/harness/ext_adapt.py`**, the D7h pair `d7h-pedia` (CAE3540B.SAV loaded; Alt+C, m, Return: Military Units; a
  press on the index's first entry; Space on page A and on page B) against its Windows form (the menu input replayed,
  the list box's click where the DOS run gave it, Return at the pick's last release; on each page the user's Space
  where the DOS run passed it, else Return at the key's instant); the core outputs equal; presentation-diag's `pedia`
  line (its `passes` the pages' passed keys), timeline.log's pedia_index / pedia_pick / pedia_page steps, the N frame
  from the index on.  D7g's runs (`d7g_runs`): the advance's page after the discovery is now D7h's DOS page, so its two
  waits are decided by I-pedia/page-key instead of I-pass/key (`D7G_ROWS`, deviation 10).

## Results (private, `build/d7h-stage/obj/`)

On the overlay = the tree after D7g's landing and the docs pass e4i + D7h's 27 files (2026-10-18, 08:27..09:13
UTC; logs `obj/run/`: `all.txt`, `bu.txt`, `build-*.txt`, `unit-*/`, `ad-d7h.txt`, `adall.txt`, `runs.txt`,
`suites.txt`, `s/`, `nodos.txt`).  Every run below is of the final sources (after deviation 9).

* **Builds** (`obj/b.cmd`, the tree's build.cmd with `--nogen`): Checked, CheckedNoObs and Release BUILD_OK; portable
  sources checked 309 (c11, c17, c99 parse; D7g's 308 + `pdos_scn_pedia.c`).  `obj/cc.cmd` CC_OK in Checked,
  CheckedNoObs and Release on every changed C file (`tests/test_input.c` among them: deviation 8).
* **Units** (`obj/unit.py`): 65 programs, 0 failed, in each variant.  test_pdos_pedia 67 (new; all three variants);
  test_input 673 (Checked, Release; CheckedNoObs 616); test_pdos_rdlg 48; test_dos 23,287 ("registry: 98 tables
  valid"); test_pdos_scene 147 (CheckedNoObs 148); test_observer 126.
* **Checks**: registry.py check REGISTRY_OK, 572 `ok` lines (D7g's 548: the four tables PEDIA_TEXTS, PEDIA_CONCEPTS,
  TERRAIN_RECORDS, TERRAIN_RULES), `tests/dos-decoded.txt` 1,417 lines; obs_lint OBS_LINT_OK files 150 probes 203
  callsites 103; obs_tables (`obj/obstab.py`, the tree's listing) OBS_TABLES_OK probes 203 sites 103;
  pdos_scene_check PASS 1,084; adapters.py check ADAPT_OK rows 161 steps 27.
* **ext_adapt** (`obj/runadapt.py`, the overlay's Checked civ_harness): `d7h` 5 PASS (d7h-pedia: the rows
  I-pedia/index-press, I-pedia/page-key twice; equal to its Windows form, coreinput 16, frames 542, exit 0 and 0; the
  `pedia` line indexes 2, pages 1, pages_a 1, pages_b 1, picks 1, passes 2 (Space passed on both pages: the OK had the
  focus), pick_none 0, exits 0, unread 0; the timeline steps; the 320 x 200 N frame); `all` EXT_ADAPT_OK checks 364
  (D7g's cycle 359 + the five d7h-pedia lines).  Against D7g's `ext-adapt.txt` only the three d7g "decided by" lines
  change (two I-pass/key -> I-pedia/page-key, deviation 10); the d7g pairs' equality lines are unchanged (coreinput
  22 / 25, frames 613 / 618).  The first full run, before deviation 9, failed its eight d7g checks.
* **Suites** on the overlay's binaries (`obj/suites.sh`): ext-p0 P0_OK 476, ext-replay REPLAY_OK 70, ext-mirror
  MIRROR_OK runs 29, ext-timeline and ext-timeline-bs EXT_TIMELINE_OK, ext-dbl EXT_DBL_OK 4, ext-fce EXT_FCE_OK runs 8,
  ext-frames EXT_FRAMES_OK, ext-p0 CheckedNoObs P0_OK 62: all as D7g's cycle.
* **nodos** (`gen/dos/nodos.py check` over the overlay): NODOS_OK, 0 hits.
* Not run privately: ext-zoom, ext-continue, ext-slots, ext-tld, ext-aspect, ext-bs and ext_g1 (the build slot's
  cycle runs them; D7h changes no Windows frame and no zoom path).

## Deviations from the brief

1. **Rows 79..84 are N, not R**: the brief names the index "re-skinned over the core's dialog 130 list" (R) and "a
   List in the index style".  DOS's O8:0000 clears the whole screen and draws its own title bar and columns: it is a
   full DOS screen, so the module draws it on the N canvas over the list dialog (class N, PDOS_RD_REPLAY, as the
   entry page of row 11); the class counts change (DOS-PROFILE 1.8, `tests/test_pdos_scene.c`, a file the brief
   does not list).
2. **A new decision and scene, PDOS_AS widened**: PDOS_AS_PEDIA (bit 32: the scene fields widened to 64 bits as the
   orchestrator directed; `tests/test_input.c`'s vector and setup types with them) and PDOS_DEC_PEDIA; the core-state
   values READY / INTRO / WAIT are reused with the meanings of "The adapter rows" (INTRO: an entry page in the core's
   wait).
3. **DOS's mouse mode, no cursor**: O8:0402..0492 takes the mouse path when DGROUP:1A3C says a mouse is present (civ64
   always has a pointer, ruling H2): any key is EXIT, a press names its entry; the keyboard mode's G#3 cursor and its
   arrows / m / x (O8:049A..04F2) are not drawn or decided.  The brief's "cursor" is that keyboard cursor.
4. **Files beyond the brief's list**: `pdos_rdlg.c/.h` (the multicolumn pick D7f's pick lacked), `pdos_scn_palace.c`
   (the claims through its owner, so no owner is taken), `pdos_replay.c/.h` (the shadows counted, not drawn),
   `pdos_seq.c` (the step log), `pdos_profile.c` (the hooks), `pdos_adapt.h`, `tests/headless/harness.c`,
   `tests/test_pdos_rdlg.c`, `tests/test_pdos_scene.c`, the registry's sources and outputs, `gen/dos/adapters.py`, the
   two docs.  `pdos_reskin.c` and `pdos_prov.c` are unchanged (section "Files").
5. **The option without "*NAME"**: the core waits twice (page A, page B), DOS once (page B at once): the first key ends
   the core's page A wait while DOS's page B is already shown; the second ends both (counted `skip_a`).
6. **After ShowCivilopediaEntry** the N page and its DAC are restored from the snapshot taken at its entry (DOS fills
   its page area and its caller redraws the screen); over an A screen nothing is restored and the return is
   R:0238:1B44's fade.
7. **Picture cells of -1** (SPRITES 8): the item has no cell in the lookup table: the page has no picture (counted
   `cell_none`), as DOS's O8:16C4 / 1790 / 17C3 callers skip the copy.
8. **Side fix (F-new, found by D7g; the orchestrator, 07:46 UTC)**: `tests/test_input.c`'s test profile `g_tp` lacked
   the initializer of `PresentProfile.square_only` (UX3's last member), which cc.cmd's strict clang C99 parse refuses
   (build.cmd's portable check does not cover that file); `NULL` added (the same value as before), cc.cmd on
   `tests/test_input.c` CC_OK in Checked, CheckedNoObs and Release.
9. **The page's Return and Space passed**: the brief's page wait is "any key"; producing Return for every key made the
   core's input differ from the Windows graphics' for the keys that already continue the core (D7g's pairs, whose
   Windows form presses Space on the advance's page A: the first full private ext_adapt failed its eight d7g checks).
   Return, and Space while the page's OK 101 has the focus, are passed (PDOS_RDV_PASS, a new value at the end of
   `PdosRdAct`; the query `focus_ok` in `PdosPediaQ`); every other key and both buttons still produce Return.  The
   result is DOS's (the page ends on any key) with the Windows graphics' own core input where they agree.
10. **D7g's test expectation adapted** (`tests/harness/ext_adapt.py`, `D7G_ROWS`): D7g's discovery flow shows the
   advance's ShowCivilopediaEntry page, which D7h draws as DOS's page: its two waits (page A, page B; the save's option
   40h) are decided by I-pedia/page-key, not I-pass/key; the keys (Space, then Return) are passed as before, so D7g's
   Windows forms and their equality are unchanged.

## What the user checks

On the coordinator's user build (D7h landed; `civ64.exe`, DOS files present), in a game with the DOS graphics
(Ctrl+Shift+Backspace or the host menu), e.g. CAE3540B.SAV loaded.  No screen shows a Go Back or Cancel row:

* **D7h-1** The Civilopedia menu's six sections (Complete, Civilization Advances, City Improvements, Military Units,
  Terrain Types, Miscellaneous): DOS's index, a full screen with a title bar at the top, "EXIT" at the top right, the
  names in black in columns on white, no highlight.  The complete index has "MORE" at the
  top left, which shows the next names (and after the last page the first again).
* **D7h-2** A click on a name: DOS's entry page: grey with the ornamental border, the picture of the advance, unit or
  terrain (a unit also with its small map shape; an improvement with its city picture), the name in large capitals and
  the category below it.  With the Civilopedia text option on (the save's), DOS's description first, without the mouse
  pointer; a key or click shows the second page (more text and the details: requirements, cost, strengths, yields), a
  key or click returns to the index.  The colours of each picture as in DOS.
* **D7h-3** A terrain type (Terrain Types): two pages as in D7h-2, then the index.
* **D7h-4** On the index, EXIT, any key or the right button leaves the Civilopedia (the map again).
* **D7h-5** (the user's report of 2026-10-17) When the science advisor's research choice shows (dialog 145, "Which
  advance..."), Alt+H on the highlighted advance: that advance's DOS entry page (D7h-2's form), then a key or click
  returns to the research choice.
* **D7h-6** In the production menu (D7f-2), Alt+H or the right button on an item: its DOS entry page without pictures
  (the name, the category and the text on a plain screen, without the picture), then the production menu again.
* **D7h-7** The same with the Windows graphics: the Windows Civilopedia, unchanged.

Not part of this check: switching the graphics while the Civilopedia shows; the keyboard mode's cursor (DOS shows it
only without a mouse).

## For the records

* **DESIGN 12.x "As implemented (D7h; areas B and C)":** the module `pdos_scn_pedia.c/.h` (the index, the entry pages,
  the waits and the turn, the page's passed keys, the end, the pointer, the claims through the owner "palace"); decision 10's pairing (section
  "Decision 10"); the scene PDOS_AS_PEDIA (0x100000000; PDOS_AS 64 bits) and the decision PDOS_DEC_PEDIA with seven I-pedia rows; the
  multicolumn list pick (`PdosRdLb.colw`); the registry tables of "The scene table and the registry"; the `pedia` diag
  line and the replay's `pedia` count.
* **Side fix** (deviation 8): `tests/test_input.c`'s `g_tp` initializer completed (`square_only`), found by D7g.
* **FIDELITY** (new entries, numbers to be assigned): F-new-1: DOS's mouse mode only, no keyboard cursor
  (deviation 3); F-new-2: the option without "*NAME" waits twice (deviation 5); F-new-3: the N page restored from a
  snapshot after ShowCivilopediaEntry (deviation 6); F-new-4: the index's font 1 is inferred.
* **DOS-PROFILE.md prose (proposed):** rows 11, 79..84 and 99 "as implemented in D7h" (the forms above); OPEN L24:
  not needed (decision 10's pairing); P13..P15, T19 and E11 as implemented.
* **RUNNING.md:** presentation-diag.log's `pedia` line (indexes, pages, pages_a, pages_b, turns, picks, pick_none,
  mores, exits, passes, nopic, cell_none, pic_missing, skip_a, restores, ends, absorbed, unread) and the replay line's `pedia`;
  timeline.log's pedia_index, pedia_pick, pedia_page and pedia_end steps; ext_adapt's d7h-pedia runs (DOS and Windows
  forms); test_pdos_pedia.
* **FEATURES.md:** the DOS Civilopedia: the index and the entry pages (D7h).
* **STATUS.md:** D7h landed (rows 11, 79..84, 99); decision 10 settled (DOS text by the pairing); OPEN L24 not needed;
  the user's Alt+H report of 2026-10-17 covered (D7h-5).
* **manual-checklist-ext.md:** new items D7h-1..D7h-7 (above).
* User direction 2026-10-16 (no added Go Back / Cancel rows) and 2026-10-17 (boxes as tall as their content, no
  highlight where DOS draws none, 2x): no row is added (the core's list dialog with its buttons is under the N frame;
  EXIT is DOS's label), no highlight on the index (DOS's mouse mode), the N frame at the integer scale.  Report items:
  none (no row DOS lacks was added).
* Not edited by this unit: DESIGN.md, FIDELITY.md, STATUS.md, RUNNING.md, FEATURES.md, DOS-PROFILE.md outside rows 11,
  79..84, 1.8 and the generated 1.7.2, manual-checklist-ext.md, the D1 drafts and the D0 documents.

## Expected changes at the build slot

Against D7g's cycle (`build/d7g-status.txt`, ALL_GREEN 07:33:58 UTC, RELEASE_OK 07:41:46; also
`build/d7h-prep/predictions.txt`):

* build.cmd checked: BUILD_OK; portable sources checked 308 -> 309 (`pdos_scn_pedia.c`); one new test program
  (test_pdos_pedia); no warning.
* test.cmd checked: TESTS_OK.
  * unit.log: test_pdos_pedia 67 (new); test_input 644 -> 673; test_pdos_rdlg 41 -> 48; test_dos 23,283 -> 23,287
    ("registry: 94 -> 98 tables valid"); test_pdos_scene 147 unchanged (CheckedNoObs 148); test_observer 126
    unchanged (call sites 103); every other program unchanged.
  * registry-check: REGISTRY_OK, `ok` lines 548 -> 572; `tests/dos-decoded.txt` 1,413 -> 1,417 lines (the four
    `table` lines PEDIA_TEXTS, PEDIA_CONCEPTS, TERRAIN_RECORDS, TERRAIN_RULES).
  * obs-lint: OBS_LINT_OK files 148 -> 150, probes 203, callsites 103 unchanged; obs-tables OBS_TABLES_OK 203 / 103
    unchanged; pdos-scene-check PASS 1084 unchanged; adapters-check ADAPT_OK rows 154 -> 161, steps 27.
  * ext-adapt: EXT_ADAPT_OK checks 359 -> 364 (the five d7h-pedia lines); the d7g-dos, d7g-flip and d7g-esc "decided
    by" lines change (I-pass/key I-pass/key -> I-pedia/page-key I-pedia/page-key); every other PASS line unchanged.
  * ext-p0 (476), ext-mirror (runs 29), ext-replay (70), ext-zoom (ZOOM_OK combinations 32 runs 108 samples 628, the
    golden unchanged), ext-timeline (both groups), ext-continue, ext-slots, ext-tld, ext-fce (runs 8), ext-dbl
    (checks 4), ext-frames, ext-aspect, ext-bs: unchanged.
  * nodos NODOS_OK, 0 hits (the file count: + D7h's four new files, the seven files of `docs/screenshots` and the new
    program's build outputs; not predicted to the count).
* ext_g1.py check: EXT_G1_OK runs 77 (amended 1) unchanged (the Windows profile's frames do not change).
* build.cmd (Release): BUILD_OK.
* Informational, may change (not predicted to the count): presentation-diag.log gains the `pedia` line (zeros in
  every run without the Civilopedia); the replay line's `pedia` count; coverage.txt's "other functions entered";
  OBS_COST.

## Rebase notes

* **Staged on the tree after D7f's landing** (session E4, 2026-10-18; D7f's RELEASE_OK 03:15:33 UTC): the overlay
  `obj/src` made from the tree, every D7h edit made there; the stage folder receives the changed and new files at the
  end (`BASE-SHA256.txt` by `obj/mkbase.py`).
* **D6fSd's landing** (copy-in 04:28:49 UTC, RELEASE_OK 05:11:37 UTC) moved `pdos_reskin.c/.h`, `present.c`,
  `tests/harness/ext_adapt.py`, `tests/headless/harness.c`, `tests/test_pdos_reskin.c` and its record: all copied into
  the overlay before D7h first edited `ext_adapt.py` and `harness.c` (no merge needed; D7h changes neither
  `pdos_reskin.c` nor the KING text pairing).
* **The docs pass e4h** (`build/docs-e4h-done.txt`, 05:28:40 UTC): its eleven docs copied into the overlay before D7h
  edited `DOS-PROFILE.md` (OFFSETS.md was not among them).
* **D7n's landing** (copy-in 05:35:13 UTC, RELEASE_OK 06:28:33 UTC) moved `DOS-PROFILE.md`, `OFFSETS.md`,
  `pdos_profile.c`, `pdos_registry.c`, `ext_adapt.py` and `tests/headless/harness.c` among D7h's files: merged three
  ways (`obj/merge-d7n`, `git merge-file -p`, files only; base `build/d7n-prep/tree-before`, each base-to-mine diff
  checked to be D7h's lines only; theirs the landed files, rechecked equal after D7n's RELEASE_OK).
  `DOS-PROFILE.md`, `OFFSETS.md` and `pdos_profile.c` merged cleanly; `ext_adapt.py` (the docstring's paragraph and the
  runs in `main`) and `harness.c` (the diag line) had both units' lines at one place: both kept, D7n's first
  (`obj/merge-d7n/*.resolved`).  `pdos_registry.c/.h` and `tests/dos-decoded.txt` regenerated (`registry.py gen`,
  `goldens`), `DOS-PROFILE.md` 1.7.2 checked (ADAPT_OK).  D7n's other files (`pdos_aplay.c/.h`, `pdos_scn_end.c/.h`,
  `pdos_scn_report.c/.h`, `test_pdos_end.c`, `test_pdos_play.c`, `ext_timeline.py`, its record) and the later
  orchestrator docs (STATUS.md, manual-checklist-ext.md, BRIEF-wl.md) are not staged; the overlay took them.
* **D7g's landing** (copy-in 06:55:22 UTC) moved `DOS-PROFILE.md`, `OFFSETS.md`, `gen/dos/adapters.py`,
  `pdos_adapt.c/.h`, `pdos_adapt_tab.c`, `ext_adapt.py`, `tests/test_input.c` and the registry's outputs among D7h's
  files: merged three ways (`obj/merge-d7g`; base `build/d7g-prep/tree-before`, theirs the landed files).
  `pdos_adapt.c/.h` and `pdos_adapt_tab.c` merged cleanly (D7g's PDOS_AC_ADVICE and I-menu/advice beside D7h's 64-bit
  scene fields, PDOS_AS_PEDIA, PDOS_DEC_PEDIA and I-pedia).  Conflicts, both sides kept, D7g's first
  (`obj/resolve_d7g.py`, outputs `obj/merge-d7g/*.resolved`): `OFFSETS.md`'s rows, `ext_adapt.py`'s
  docstring, `test_input.c`'s vectors; the adapter preface (`adapters.py`, `DOS-PROFILE.md` 1.7.2) joined ("...does not
  wait; extension D7h: ..."), the row-count check 161 ("D7g: I-menu/advice; D7h: 7 I-pedia rows").  The registry's
  outputs regenerated (98 tables, decoded content 1,417 lines), 1.7.2 regenerated equal to the resolution (ADAPT_OK
  rows 161).  D7g's other files (`pdos_pend.c/.h`, `pdos_reskin.c/.h`, `pdos_ui.c/.h`, `obs_tables.c/.h`,
  `gen/obs_tables.py`, `obs_lint.py`, `test_observer.c`, `test_pdos_reskin.c`, `test_pdos_ui.c`, its record) are not
  staged; the overlay took them.
* **The docs pass e4i** (`build/docs-e4i-done.txt`, 07:55:23 UTC) changed `DOS-PROFILE.md` (the carry-over Open 20 /
  L24 lines): merged three ways (`obj/merge-e4i`; base D7g's landed file), no conflict; ADAPT_OK, pdos_scene_check and
  OBS_TABLES_OK again on the result.  Its other files (DESIGN, FEATURES, FIDELITY, RUNNING, STATUS, the checklist,
  dos/OPEN, dos/SCENES-PLAY, D7g's record, the briefs) and the tree's new `docs/screenshots` are not staged; the
  overlay took them.
* At the build slot: `obj/mkbase.py check` against the live tree; a moved base is merged three ways again (base: the
  recorded file, from the landing's `tree-before`), the generated files regenerated.

## Landing

D7h landed alone at the build slot of session E4 (track C), 2026-10-18, after D7g's landing (RELEASE_OK 07:41:46 UTC,
user build `build/user-builds/d7g/`) and the docs pass e4i (`build/docs-e4i-done.txt`, 07:55:23 UTC), as the
orchestrator ordered (06:50 UTC: D7g, then e4i's marker, then D7h; 07:46 UTC: D7h next after D7g; "you may land as
soon as you are READY").  READY sent at 09:14 UTC; no other cycle or landing active (`obj/landing.py` IDLE).  The user
checks D7h-1..D7h-7 are in the user build `d7h`.

* **Rebases** (section "Rebase notes"): over D6fSd's, D7n's and D7g's landings and the docs passes e4h and e4i; the
  generators run again on the overlay; the private results of section "Results" on the final sources (deviation 9
  made after the first full ext_adapt).  `BASE-SHA256.txt` written at 09:14 UTC (23 changed files and 4 new, 9
  references), `obj/mkbase.py check` BASES_OK.
* **Bases:** `build/d7h-prep/land.py` (from D7n's, D7h's BASE-SHA256.txt format) rechecked every base (DRY_RUN_OK 27;
  build.cmd and test.cmd unchanged), took the snapshot `build/d7h-prep/before` (the tree's `build/test/Checked`
  outputs of D7g's cycle, 66 files) and `tree-before` (the 23 replaced files), and copied in at 09:15:07 UTC
  (`landed.sha256`: the 23 changed files and the 4 new ones; `landed-at.txt` "unit d7h").  Predictions
  `build/d7h-prep/predictions.txt`, written before the copy-in.  Scripts in `build/d7h-prep/` made by `mk_prep.py`:
  `land.py` (from D7n's), `d7h-cycle.ps1`, `compare.py` and `mk_userbuild.py` (from D7g's; saves CAE3540B.SAV and
  D7g's CHIEF.SAV), `fill_stillopen.py` (from D7g's, with a new group "d7g").
* **The cycle** (`build/d7h-prep/d7h-cycle.ps1 -LastStep 4` through Windows PowerShell, status `build/d7h-status.txt`,
  each step guarded by its log's OK marker): 1 `build.cmd checked` BUILD_OK 09:15:18..09:19:23 (245 s; portable
  sources checked 309; no warning); 2 `test.cmd checked` TESTS_OK 09:19:23..09:51:25 (1921 s; TEST_SECTIONS 30
  failed 0, wall 1919.6 s; no flake rerun); 3 `ext_g1.py check` EXT_G1_OK runs 77 (amended 1) unchanged:
  **ALL_GREEN** 09:51:25.  4 `build.cmd` (Release) BUILD_OK 09:51:25..09:55:27 (242 s): **RELEASE_OK**.
* **Against the predictions** (`build/d7h-prep/compare.py` against the snapshot, `build/d7h-prep/compare.txt`: 16 of
  66 files differ, sections/times.txt among them): as predicted, unit.log test_pdos_pedia 67 (new), test_input 644 ->
  673, test_pdos_rdlg 41 -> 48, test_dos 23,283 -> 23,287, every other count equal; registry-check REGISTRY_OK (the
  four tables' 22 `ok` lines and the two include rules of `pdos_scn_pedia.c/.h`; dos-decoded 1,413 -> 1,417 lines);
  dos-decoded.txt the four `table` lines; OBS_LINT_OK files 148 -> 150 probes 203 callsites 103; ADAPT_OK rows 154 ->
  161 steps 27; EXT_ADAPT_OK checks 359 -> 364, the new lines exactly the five d7h-pedia lines of the private run and
  the three d7g "decided by" lines with I-pedia/page-key; P0_OK 476, MIRROR_OK runs 29, REPLAY_OK 70, EXT_FRAMES_OK,
  EXT_TIMELINE_OK (both groups), EXT_CONTINUE_OK, EXT_SLOTS_OK, EXT_TLD_OK, EXT_FCE_OK runs 8, EXT_DBL_OK 4,
  pdos-scene-check 1084 unchanged; nodos NODOS_OK, 0 hits (files 1829 -> 1841: D7h's four, the seven of
  `docs/screenshots`, the new program's output).  Not predicted to the count (informational, every line PASS):
  ext-p0's V4d zoom lines (shows with the layer: menus 1111 -> 1080, research and research2 191 -> 189: the
  Civilopedia's pages are DOS's N frame now); ext-replay's V1 `no_scene` (menus 19 -> 6, research and research2 25 ->
  1: the Civilopedia's draws have a scene now); ext-zoom's two s4 1920x1440 integer lines (sw shows 4716 -> 4753 and
  4629 -> 4666; the windows' counts, the samples and ZOOM_OK unchanged); coverage.txt "other functions entered" 677 ->
  675.
* **User build** `build/user-builds/d7h/` (09:56 UTC; `build/d7h-prep/mk_userbuild.py`): `civ64.exe` (the Release
  build, SHA-256 6f75d937...), `CIVWIN.zip` and `civdos.zip`, `CAE3540B.SAV` (the d7h-pedia pair's save),
  `CHIEF.SAV` (859de592..., D7g's edited save, for D7h-5's research choice) and `WHAT-TO-CHECK.txt` (D7h-1..D7h-7;
  the earlier builds up to "d7g"; the 157 items still pending in the checklist of 07:47 UTC).
* **Host load:** no private run during the cycle (the private chain ended 09:12:57 UTC).
* Not done at this slot: the checklist sections and STATUS rows (the orchestrator's) and the docs pass for D7h ("For
  the records"); the tree's CheckedNoObs and Release unit programs are not part of the cycle (the private overlay's are
  in "Results").

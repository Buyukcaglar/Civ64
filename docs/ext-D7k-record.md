# Extension phase D7, unit D7k (diplomacy and leaders) - record

Draft for the build slot (docs/verify/BRIEF-d7.md unit D7k: rows 19 and 100; P11, P12, T2..T5, `pdos_recipe_king` (E21,
E15), `LEADER_FONT` and the font by `g_playerCivId[n]`, F9, F10, F17; decisions 9 and 17; OPEN L21, L23; extension
session E4, track A; moved from track B by the orchestrator, "stage everything that does not need D7g"). Staged in
`build/d7k-stage/` on the tree after D7l2's landing (RELEASE_OK 20:45:49 UTC) and the docs pass e4f (bases copied
21:14:51 UTC, `obj/base-at-copy-raw.txt`), rebased onto D6fSc's landing (copy-in 21:46:57, RELEASE_OK 22:30:10 UTC;
`obj/rebase-d6fsc/`) and onto D7e's landing (copy-in 22:59:02 UTC; three-way merges, `obj/rebase-d7e/`) and the docs
pass after it (`obj/rebase-docs/`). The base of every changed file is the tree's file now (`obj/base-at-copy.txt`),
rechecked in `BASE-SHA256.txt` (section "Rebase notes"). Private builds and runs in `build/d7k-stage/obj/` only: an
overlay `obj/src` = the tree + the stage (`obj/mkoverlay.py`; `obj/sync.py` lays later stage edits over it), built with
the tree's build.cmd and flags (`obj/b.cmd`, `obj/ball.py`, `--nogen`), cc.cmd's stricter checks per file (`obj/cc.cmd`,
`obj/ccall.py`), the unit programs and the harness runs from the overlay's binaries with every output under `obj/`; the
tree's build/gamedata, dosdata, dos/disasm and cache read only.

## Result

D7k is staged, rebased and privately verified.  With the DOS graphics the diplomatic audience is DOS's leader screen
(rows 19 and 100): O6:1D2B's picture path with O6:21AC's throne room drawn over the core's LoadLeaderScreen 1160:2A38
from the core's state (the court picture's style, DOS's portrait `LEADER_PORTRAIT[tribe]`, the civilization's rank):
`BACK<g><a|m>.PIC` with the attendant figures of `GOVT<g><a|m>.PIC` and the body of `KING<p>.PIC`, the BACK palette
with KING's 64..143 (`pdos_recipe_king`, E21) without a fade, shown at the leader window's show; the pointer hidden
while it loads; DOS's idle frame O6:2362 at each core DrawLeaderAnimationFrame (TC); the leader's messages as DOS's
text strip O6:251D: frameless boxes at DOS's (36, 139) over the screen's own stone panel, in the leader font
8 + `LEADER_FONT[tribe]` (10 -> 3) with 8-pixel lines, every box of the audience (its choices included) in that font,
each message gone at its MenuZ's return; the end at the leader window's destruction with the return's fade from
black (exit kind 1).  The per-civ font ids 200..215 now map by the audience's tribe `g_playerCivId[g_leaderCiv]`
(F9, F10, F17), no longer `id - 200`.  Seven registry rows (`LEADER_FONT`, `LEADER_FACE_X`, `LEADER_FACE_Y`,
`LEADER_ATTEND_X`, `LEADER_ATTEND_Y` of the far segment `[DGROUP:640A]`, `LEADER_PORTRAIT` DGROUP:3938, `LEADER_SLOT_X`
DGROUP:3AFE), every length from the listing's readers (decision 9; ruling 9: no inferred length).  OPEN L21 is
resolved (both skip the same four KING cells: expression i is the same cell), T5 is proved (pdos_prov's T5 rule), F10
and F17 read (O6:180F..1833).  No core change, no core random draw, no new owner (the owner "palace" delegates to the
leader: still 9 of PDOS_OWNER_MAX 10 after D7e) and no new PDOS_AS bit (I-menu; 0x10000000 stays free).

**The boxes over the leader screen need no D7g header variant** (the orchestrator's question): O6:251D draws its text
through R:0238:0008(text, 24h, 8Bh) -> R:1D05:0018 with no header (ovl06.lst has no reference to DGROUP:2F9E, the
advisor-portrait header of R:1D05:0613..0715, the D7g variant, and every box resets it to FFFFh at R:1D05:0456..0459);
at y 8Bh the box is frameless with the bars of y 139 (R:1D05:00BF..00C6) and,
while DGROUP:3936 is not FFFFh, 8-pixel lines (R:1D05:00A8..00AF): both are in `pdos_ui.c`'s model already (MB_Y_139,
MB_BAR2_139, the PdosMenuBox `h8` input).  D6fSc's re-skin gives the MenuZ binding and DOS's line rule
(`pdos_r_spec_dos_lines`, `pdos_r_dos_wrap`); D7k adds the font, `h8` and the place to the spec (two fields).  The
private runs show the boxes at (36, 139) with 8-pixel lines in the leader font, the treaty offer's two rows chosen by a
press (section "Results").  So D7k can land before D7g.

## Status

LANDED (2026-10-18: copy-in 01:25:44 UTC, ALL_GREEN 02:03:51 UTC, RELEASE_OK 02:08:45 UTC, user build
`build/user-builds/d7k/`; section "Landing"); the user checks D7k-1..D7k-4 are pending.  Built: rows 19 and 100
(SCENES-PLAY 7.9: O6:16CD's audience, O6:1D2B, O6:21AC, O6:1B33 / O6:2362 at the core's idle frames, O6:251D's text
strip); P11, P12, T2..T5, E15, E21, F9, F10, F17 closed in DOS-PROFILE ("as implemented in D7k" or proved); OPEN L21
and L23's leader part resolved; DOS-PROFILE Open 11 (the leader cells) and Open 16 (the leader text) read.  Not in the
unit: the conquered leader (D7n); the text-only path without the picture disk (O6:1D49..1E29; not drawn: the store has
the pictures).

## What was built

### The core's audience and DOS's (the core's reconstruction; DOS listing)

The core (claude/src seg 1160): HoldDiplomaticAudience 1160:0000 calls RequestLeaderAudience 1160:20C0, which opens
dialog 142 (GR_DialogOpen 1160:2251, the leader window) and calls LoadLeaderScreen 1160:2A38 (1160:225F): the civ's
KING picture (GR_PicRead 1160:2AA5), the body (ExtractScaledTile 1160:33FC) and the expression tiles (cells 0..13 of a
4Fh x 51h grid, cells 8, 9, 13 and 14 skipped: the loop adds 2 at expressions 8 and 11), the court picture of
GetCourtStyle 1160:3487 (GR_PicRead 1160:2BB0), the attendant frames, ShowWindow; then SetCivFont, g_leaderMood 1, and
ShowLeaderMessage 1160:328E's MenuZ 1220:0156 on the leader window for each speech.  MenuZ sets a 100 ms timer; its
WM_TIMER case (1220:12BB) runs AnimateLeaderPortrait 1160:26EF, which draws DrawLeaderAnimationFrame 1160:2EE0 (three
CopyPortToWindow copies: an attendant frame, the upper and the lower expression).  The end: CloseLeaderScreen
1160:2E03 (GR_DialogClose) and the window's destruction.

DOS (build/dos/disasm/ovl06.lst, read only): O6:16CD's audience hides the pointer (O6:17D1), calls O6:1D2B(civ, 5, 1)
(O6:17E4), sets the port font 8 + `LEADER_FONT[D7F4[civ]]` with 10 -> 3 (O6:17EA..1833; DGROUP:67EC and the port's
font word) and DGROUP:3936 = 1 (O6:183C), `[67E8]` = FFFFh (O6:183F); O6:1D2B's picture path (O6:1D49..1E29 is the
text-only path) composes the throne room O6:21AC on page 1: BACK, the figures of the slots below (rank + 1) / 2 at
(`LEADER_SLOT_X[s]`, 34) with variant (s + civ) & 3 (O6:2214..2256), the body at (90, 0), then page 0 black, the
palette and page 1 to page 0 (O6:2332 shows the pointer); the idle animation O6:1B33 -> O6:2362 draws an attendant
frame and the two expressions at the places of the throne-room tables; the text strip O6:251D(text, 14h, 8Bh) saves
page 0's rows 128..199 to page 1, calls R:0238:0008(text, 24h, 8Bh) (the x 14h -> 24h at O6:254E..2554) and puts the
strip back (O6:2572..259A); the end O6:16AC..16B9 returns through R:0238:1B44.

### The renderer (`pdos_scn_leader.c/.h`)

| DOS | drawn at (the core) | timeline |
|---|---|---|
| O6:17D1 pointer hidden; the civ, tribe, rank and portrait read | LoadLeaderScreen's entry from RequestLeaderAudience (1160:225F) | - |
| the court style (O6:1E53..1E8C) | GR_PicRead of the court picture 400 + s (1160:2BB0's argument; GetCourtStyle 1160:3487, the same rule) | - |
| O6:21AC, O6:1D2B's show, O6:2332 pointer shown | ShowWindow of the leader window (LoadLeaderScreen's end): BACK on page 1, the figures, the body, page 0 black, `pdos_recipe_king`, page 1 to page 0; rows 19 and 100 ready (the N frame) | TS (`leader`, O6:1D2B) |
| O6:2362 (idle frame) | each core DrawLeaderAnimationFrame copy (1160:305C, 317A, 3241): the frame's attendant a, upper and lower expressions read from its arguments | TC |
| O6:251D text strip | each MenuZ on the leader window (ShowLeaderMessage 1160:328E): a re-skinned frameless box at (36, 139) | - |
| O6:16AC..16B9 end | the leader window's destruction (CloseLeaderScreen 1160:2E03) | exit kind 1 (`leader_end`, O6:16B9) |

The pure parts (`pdos_leader_cell`, `_face_rect`, `_body_rect`, `_figure_rect`, `_frame_rect`, `_court_files`,
`_king_files`, `_anim_style`, `_slots`, `_face_pos`, `_compose`, `_frame`) are the listing's rules as functions of the
N machine, the pictures and the registry's tables.  The leader window and the leader port's bitmap (g_leaderPort
1378:0014 + 1Ah, followed as GR_PortDataToBitmap replaces it) are claimed through the shadow owner "palace" (its
hooks delegate to the leader: no owner of its own) from LoadLeaderScreen's entry while the screen loads or shows;
every core drawing and copy on them is absorbed and the replay draws nothing there (`pdos_replay.c` decide: the
`leader` count).  A dialog 142 window outside that span stays the scene engine's (row 19's N window; the tree's
test_pdos_profile uses one).  Row 100 is now HoldDiplomaticAudience's whole span (its entry pushes, its exit pops), so
the audience's later speeches stay on the stack (D6g's row 0 read: before, they counted to row 0).

### The boxes of the audience (`pdos_reskin.c/.h`, extension D7k blocks)

While the core's g_leaderMood 1358:000A is not -1 (DOS: DGROUP:3936 not FFFFh, the port font the leader font from
O6:1833 to O6:16B4) every MenuZ box is laid out in the leader font (`pdos_leader_box_font`) with 8-pixel lines
(`PdosRSpec.h8`), its lines wrapped in that font by DOS's line rule.  A MenuZ on the leader window while the screen
shows (`leader_box`: template 142) is the leader message: laid out at DOS's (36, 139) itself (`PdosRSpec.at_place`:
not moved inside the canvas; DOS's line clamp (192 - y) / h, R:1D05:057D..059A), frameless with the bars of y 139,
and removed at its MenuZ's return (O6:2572..259A), the leader window staying for the next speech.  The message boxes
keep font 1 (none was seen in an audience).

### Fonts (`pdos_fontmap.c/.h`)

A per-civ font id 200..215 maps to DOS font 8 + `LEADER_FONT[t]`, 10 replaced by 3, t the audience's tribe
`g_playerCivId[g_leaderCiv]` (DOS DGROUP:D7F4[n], O6:180F..1815; B 10.1's correspondence inferred), read under the
observer when the id is set or read; each note keeps the tribe it was set with; without a tribe the id is unmapped.
The table is set by the leader's reset from the registry's `LEADER_FONT`.  F17: DOS font 9 is the leader text of the
tribes whose byte is 1.

### Provenance (`pdos_prov.c/.h`, PROF 2.3)

T2: picture 500 + p's ExtractScaledTile device rectangle (each corner x 133 / 100, y 16 / 10) -> `KING<p>.PIC`'s body
(181, 67, 139 x 133).  T3: the expression cells (the same cell k in both) -> `KING<p>.PIC`'s ((k mod 5) 60 + 1,
(k div 5) 50 + 1 or + 21, 59 x 20 or 29).  T5: picture 400 + s's attendant frames (200h + 26h (3 (v / 2) + a),
50h + 28h (v mod 2), 26h x 28h) -> GOVT frames (161 + 29a, 25v + 1, 28 x 24); rows past 1 rejected.  T4's figures are
cut from a copy of the leader port without its own picture read: no rule (the renderer draws the DOS figures).

### Registry tables (OFFSETS.md; DOS file, DOS listing)

| row | place | kind, count | readers |
|---|---|---|---|
| `LEADER_FONT` | [DGROUP:640A]:0000 | bytes 16, range 0..2 | O6:1815 |
| `LEADER_FACE_X` | [DGROUP:640A]:0010 | u16 28 | O6:249F, O6:24AA |
| `LEADER_FACE_Y` | [DGROUP:640A]:0048 | u16 28 | O6:24B2, O6:24BD |
| `LEADER_ATTEND_X` | [DGROUP:640A]:0080 | u16 56 | O6:240D, O6:2417 |
| `LEADER_ATTEND_Y` | [DGROUP:640A]:00F0 | u16 56 | O6:2422, O6:2433 |
| `LEADER_PORTRAIT` | DGROUP:3938 | bytes 16, range 0..13 | O6:1EE5 |
| `LEADER_SLOT_X` | DGROUP:3AFE | u16 4 | O6:2231, O6:23E7 |

The lengths come from the readers' index ranges (the tribes 0..15, the 14 portraits' pairs, the 7 styles x 4 slots'
pairs, the 4 slots); `registry.py check`: each row, its readers, no writer.

### Counters

presentation-diag.log gains the `leader` line (`screens`, `composed`, `figures`, `idle`, `faces`, `attendants`,
`frame_bad`, `pic_missing`, `table_bad`, `portrait_differs`, `ends`, `absorbed`, `unread`, `boxes` and the first choice
box's `box_x`, `box_y`, `box_first`, `box_rows`, `box_h`, `box_font`); the `replay` line gains `leader` (primitives on
the leader's shadows, not replayed); timeline.log gains `leader` (O6:1D2B, the civ) and `leader_end` (O6:16B9, the exit
kind).

### Evidence labels

* DOS listing: every O6 and R: address above (ovl06.lst, read only); the tables' readers.
* DOS file: `GOVT*.PIC`, `BACK*.PIC/.PAL`, `KING*.PIC/.PAL`, the seven tables.
* Inferred: the D7F4 <-> g_playerCivId correspondence (B 10.1); the pictures' likeness of T4/T5 (the indexing proved).
* Core behaviour found: in the harness runs the core's idle animation never runs during the audience (see
  "Deviations" 1).
* DOS oracle: none (no DOS program run).

## Files

Changed (`BASE-SHA256.txt`): `present/dos/pdos_fontmap.c/.h`, `pdos_prov.c/.h`, `pdos_scene_tab.c` (row 100's key),
`pdos_profile.c` (the hooks, the pointer rule; CRLF), `pdos_seq.c` (the step log; CRLF), `pdos_scn_palace.c` (the
owner's delegation), `pdos_replay.c/.h` (the leader's shadows not replayed, the `leader` count), `pdos_reskin.c/.h`
(the audience's boxes), `pdos_registry.c/.h` and `tests/dos-decoded.txt` (generated from the seven rows),
`docs/dos/OFFSETS.md` (the seven rows and a note), `gen/dos/registry.py` (OBSERVER_FILES += `pdos_scn_leader.c`),
`docs/DOS-PROFILE.md` (rows 19, 100, P11, P12, T2..T5, F9, F10, F17, E15, E21, Open 11, Open 16),
`tests/headless/harness.c` (the `leader` diag line; CRLF), `tests/test_pdos_scene.c` (the font vectors by tribe),
`tests/harness/ext_adapt.py` (the d7k pair), `tests/harness/ext-zoom-golden.txt` (its 80 `dos load` lines at 35,000 ..
70,000 ms, staged at the landing: section "Results", ext_zoom).  New: `present/dos/pdos_scn_leader.c/.h`,
`tests/test_pdos_leader.c`, this record.  Unchanged though the brief lists it: `present/dos/pdos_adapt_tab.c` (the
leader message is a MenuZ of the re-skin: the I-menu rows decide; DOS-PROFILE 1.7.2 unchanged, `adapters.py gen`
reproduces it).  build.cmd and test.cmd unchanged.  The D7k parts of shared files are `extension D7k` blocks or
one-line hunks with an `extension D7k` comment.

## Tests

* **`tests/test_pdos_leader.c`** (new, 119 checks in every variant; synthetic memory, pictures (GOVT, BACK, KING with
  their palettes), tables and fonts, no DOS byte): the listing's rules (the cells with 8, 9, 13 and 14 skipped, their
  upper and lower rectangles, the body, the figures and frames, the court style's and the portrait's files, the
  animation style, the slots by rank, the frames' and expressions' places); the composer O6:21AC (BACK on page 1, the
  slots' figures, the body, page 0 the copy, the DAC `pdos_recipe_king`; a missing picture and a style outside 0..6
  counted); the frame O6:2362 (every slot's attendant frame unless it is the last drawn, the expressions; the bad ones
  counted); pdos_prov's T2, T3 (the skipped cells none) and T5 rules (rows past 1 rejected); an audience through the
  scene engine, the shadow engine (the owner "palace") and the module from a synthetic stream: row 100 at
  HoldDiplomaticAudience, the leader window (row 19), LoadLeaderScreen's entry (pointer hidden; civ, tribe, portrait,
  rank), the court and KING reads, the show (the throne room on page 0, rows 19 and 100 ready, the N frame, the pointer
  shown, `leader` logged), the core's drawing absorbed (the replaced port bitmap followed), the idle copies (frames,
  faces), the boxes' font and place, the end (rows back, exit kind 1B44, `leader_end`), the diag line; the edges (the
  core's portrait differing, a box before the show, a missing picture, an unreadable state, the audience outside
  HoldDiplomaticAudience, LoadLeaderScreen from another call site); the leader message's box through the re-skin
  (frameless at (36, 139) with the bars of y 139 and 8-pixel lines, the screen kept under it, DOS's clamp to six lines
  at the place, the place not moved; without `at_place` moved up to y 127; without `h8` the font's 10-pixel lines;
  removed at the return) and the diag's first choice box.  On the base it does not build (`pdos_scn_leader.h` absent).
* **`tests/test_pdos_scene.c`** (141 -> 147): the leader font vectors by tribe (`pdos_fontmap_set_leader_tribe`: no
  tribe unmapped; tribes 0, 1, 5, 13; a note keeps its tribe; 16 none; without the table unmapped) in place of the
  `id - 200` vectors.  On the base it does not build (`pdos_fontmap_set_leader_tribe` absent).
* `tests/test_dos`: the seven registry rows (+7 checks with the staged goldens).
* `tests/test_pdos_profile` unchanged (59): its dialog 142 window without LoadLeaderScreen stays the scene engine's
  (the leader claims only from LoadLeaderScreen's entry).
* **`tests/harness/ext_adapt.py`**: the d7k pair (`d7k_runs`, 7 checks): the audience of CAE3540B.SAV after
  load-save.script's moves (+2.5 s): the emissary's Yes, the greeting, the treaty offer's choice by its letter
  (calibration: the first choice box's place from the `leader` line) and by a press and release on the DOS row of
  Accept against its Windows form (a click where the DOS run gave the core and Return at the release sync); the core
  outputs equal, timeline.log's `leader` and `leader_end` and the return's fade, the N frame during and the A frame
  after, the `leader` and `replay` lines.
* Other harness runners unchanged (ext_p0, ext_timeline, ext_mirror, ext_replay); their runs reaching the audience
  (`load`, `research`, `research2`, `quiz`, `arrival`, `s2`) pass through the new drawing (section "Results").

## Results (private, `build/d7k-stage/obj/`)

Session E4 (2026-10-17/18), on the overlay `obj/src` = the tree after D7e's landing (RELEASE_OK 23:46:36 UTC) + the
stage (made 23:21 UTC; at 23:47 UTC the tree's sources equal the overlay's but D7k's files), the bases of
`BASE-SHA256.txt` rechecked:

* **Builds** (`obj/ball.py`, the tree's build.cmd and flags with `--nogen`): Checked, CheckedNoObs and Release
  BUILD_OK, portable sources 307 (`pdos_scn_leader.c` added; 324, 367 and 336 s, 23:47:12..00:04:18 UTC,
  `obj/ball-all.log`).  Before (on D7l2's and D6fSc's trees): the same.
* **cc.cmd** (`obj/ccall.py`: c11 and c17 /W4 /WX and the clang C99 parse, every variant) on `pdos_scn_leader.c`,
  `pdos_reskin.c`, `pdos_replay.c`, `pdos_scn_palace.c`, `pdos_prov.c`, `pdos_fontmap.c`, `pdos_profile.c`,
  `pdos_seq.c`, `pdos_scene_tab.c`, `pdos_registry.c`, `test_pdos_leader.c` and `test_pdos_scene.c`: CCALL failed 0
  (36 CC_OK; `obj/ccall-final.log`).  The last edits after the builds were comments only (line widths, no line
  moved but the test's header); test_pdos_leader relinked and run again in the three variants (119 each).
* **Unit** (`obj/unit.py`, the tree's build/gamedata read only): all 63 programs (test_ne aside) pass in Checked,
  CheckedNoObs and Release but test_dos's golden comparison: test_pdos_leader 119 in each, test_pdos_scene 147
  (CheckedNoObs 148), test_pdos_profile 59 (CheckedNoObs 55), test_pdos_reskin 171 (159); test_dos 23,274
  ("registry: 85 tables valid"), its one failure the golden comparison only (test_dos reads the goldens beside the
  gamedata it is given: the tree's `tests/dos-decoded.txt`, without the seven rows); its decoded output equals the
  staged `tests/dos-decoded.txt` line for line (1,404 decoded lines) in each variant, so at the build slot it passes.
  Against D7e's cycle log (`build/d7e-2-test-checked.log`; `obj/cmpunit.py`) every other Checked count is equal.
* **Checks** on the overlay: `registry.py check` (`--dosdata` and `--disasm` of the tree's build, read only)
  REGISTRY_OK, 0 failures, 498 `ok` lines (the tree's 470: the seven rows' 26, the include rule for
  `pdos_scn_leader.c` and `.h`; dos-decoded 1,397 -> 1,404 lines); `registry.py gen` and `goldens` in the overlay
  reproduce the staged files byte for byte; `obs_lint.py` OBS_LINT_OK files 146 probes 203 callsites 101 (the tree's
  144); `obs_tables.py --check` (`obj/obstab.py`, the tree's listing) OBS_TABLES_OK probes 203 sites 101;
  `pdos_scene_check.py` PASS 1084 checks, 141 scene rows, 10 font rows; `adapters.py check` ADAPT_OK rows 147 steps 27
  (`adapters.py gen` reproduces the staged DOS-PROFILE.md); `nodos.py check --root obj/src` (the three variants'
  binaries; the tree's build/dosdata and build/gamedata read) NODOS_OK, 1,194 files, 0 hits.
* **ext_p0** (the tree's runner, `--exe` the private Checked harness, `--root obj/p0root`, `--only
  load,research,research2,quiz,arrival,s2`: every run reaching an audience, V0, V1, V2): P0_OK checks 42 (V0 equals
  the G-1 baseline; V1 and V2 equal V0; the switch assertions; no count on a D4, D5 or D6 row).  V1 and V2 `pdos_rows`
  of all six without row 19's and row 0's counts (the tree: `r19.unexplained 9 r19.font_unmapped 4 r0.unexplained 43
  r0.font_unmapped 12` in each; the other rows' counts unchanged); the `leader` line in each: `screens 1 composed 1
  figures 3 idle 0 ... ends 1 absorbed 52 unread 0 boxes 15 box_x 36 box_y 139 box_first 3 box_rows 2 box_h 8
  box_font 8` (the Zulus' tribe: font 8).
* **ext_replay** (`--only` the six, `--root obj/p0root`): REPLAY_OK checks 16; `no_scene` 22 lower in each V1 run
  (load, arrival, s2 22 -> 0; research, research2 47 -> 25; quiz 44 -> 22: the audience's later speeches no longer
  drawn with an empty stack), kind checks and brackets unchanged.
* **ext_mirror** (`--only load,research,research2,quiz,arrival`): MIRROR_OK runs 5 (unexplained 0,
  present_mismatched 0, dos_mismatched 0, dos_unexplained 0, P0 equal).
* **ext_timeline** (`--exe` the private harness, `--root obj/tlroot`): EXT_TIMELINE_OK, 53 checks, every line equal to
  D7e's cycle.
* **ext_adapt** (`obj/runadapt.py ... all`: the staged ext_adapt.py's whole main with the private Checked harness):
  EXT_ADAPT_OK checks 299 (D7e's cycle 292 + the d7k pair's 7); every other line equal to the cycle's.  The d7k pair:
  the calibration's first choice box at (36, 139), first line 3, 2 rows, lines of 8, font 8 (I-menu/hotkey on `a`);
  the press at the N point (46, 179) decided I-menu/press and I-menu/release, one click at the core's (209, 354); the
  core outputs equal its Windows form (coreinput 29, frames 603, exit 0 and 0); `leader` (O6:1D2B, civ 2) at
  33,502,850 us, `leader_end` (O6:16B9, exit kind 1) at 41,501,850 us, the return's fade ending at frame 30; 10 N-frame
  shows during the screen, 103 A-frame shows after; the replay's `leader 21`, `text_boxes 0`.
* **ext_zoom** (2026-10-18, at the landing; `obj/zoompriv.py`: the tree's ext_zoom.py, its golden file pointed at
  `obj/zoom/ext-zoom-golden.txt`, a copy of the tree's; `--exe` the private Checked harness, `--port` the tree):
  `--update --profiles dos` (00:36..00:45 UTC, `obj/zoom/zoom-dos-update.log`; ZOOM_OK combinations 32 runs 36) changed
  exactly the 80 `dos load <size> <policy> <level> <ms>` lines at 35,000 .. 70,000 ms of the 10 combinations, nothing
  else; then the whole run against that golden (00:50..01:23 UTC, `obj/zoom/zoom-full.log`): ZOOM_OK combinations 32
  runs 108 samples 628 map comparisons 32 centre runs 4 mzi runs 12 mzs runs 4 not zoomed 38/448, the cycle's counts;
  its informational lines: `load` shows dos 458 -> 470 (sw 416/412 -> 426/422), `s4` sw 4696/4607 -> 4716/4629.  Why the
  lines change (`dos load 1920x1440 integer -1`, the tree's run against the private one): the core's frames
  (run.log's 752 `frame` lines) and events.log are equal; at 35,000 .. 45,000 ms the sample is the last zoomed show
  before the leader screen (its N frame has no zoomed show; the tree's run showed the audience over the A frame, with
  zoomed shows); from 49.0 s the return's fade from black (30 shows, 17 ms apart, `report ... return_1b44 1
  fade_ended 1`); after it the 343 shows are at the tree's run's virtual times, and the same map frames recur about
  0.57 s later than in the tree's run (41 of the 69 distinct frames after 53 s are the tree's): pdos_profile.c holds
  the map slots' cycling (CyclePaletteColors, 154 calls) while the return's fade-in runs (D7a's rule: R:0238:1BFC
  stops them, R:0238:1C8E restarts them, OPEN L12), so the slots' phase is one step behind the tree's for the rest of
  the run (`pmap dos_reconverts` 155 -> 177).  The golden is staged (`tests/harness/ext-zoom-golden.txt`, base D7e's
  landed file).
* **ext_slots and ext_tld** (`--harness` the private Checked harness, `--root obj/slroot`, `obj/tldroot`; s-dos-slots
  passes the audience in the DOS graphics before its second Save): EXT_SLOTS_OK (45 PASS lines) and EXT_TLD_OK (20),
  every line equal to D7e's cycle (`build/test/Checked/ext-slots.txt`, `ext-tld.txt`).
* **Frames** (`obj/dbgroot/`, the d7k pair's DOS input with `--dump-presented`, viewed, not kept as fixtures): the
  greeting, the treaty offer (Reject, Accept; Accept highlighted at the press), the later speeches and the three-row
  answer box on the stone panel at (36, 139) in the Zulus' decorated font, the throne room (Shaka, three attendant
  figures of the rank's slots) unchanged under them.
* **The idle animation**: `idle 0` in every run (deviation 1).  A private run with probes at 1220:12BB (MenuZ's
  WM_TIMER case) and 1160:26EF hit only outside the audience; during its MenuZ PeekMessage returned the Status
  window's WM_PAINT 293 times (`obj/dbgroot/load*`, before the rebases).
* **Host load:** at 23:02..23:13 UTC this unit's private unit run and a first whole ext_adapt run overlapped D7e's
  build and test steps (its cycle began at 22:59 UTC) until its status file was seen; both were stopped, nothing
  outside `build/d7k-stage/` was written, and every result above was made again after D7e's RELEASE_OK.

## Deviations from DOS and the ruling

1. **The idle animation follows the core (TC), and the core draws none in the runs.**  DOS animates the leader during
   its text waits (O6:1B33); the core draws its frames from MenuZ's WM_TIMER (1220:12BB).  In every harness run
   reaching an audience the Status window's pending WM_PAINT comes before the timer in w16's queue (paint before
   timer, Win3.1's priority) and MenuZ's loop (1220:0AA0, PeekMessage and IsDialogMessage only) never dispatches it,
   so no WM_TIMER is made and AnimateLeaderPortrait never runs (`idle 0`; a probe at 1220:12BB fired only in other
   MenuZs).  Both graphics then show a still leader; the DOS frames are drawn whenever the core draws its own
   (test_pdos_leader's synthetic copies).  Core behaviour (P0), not changed.
2. **The text strip is a box element, not a page copy.**  DOS saves rows 128..199 and puts them back at the return;
   the re-skin's frameless element over page 0 is removed at the MenuZ's return: the same pixels.
3. **The message boxes keep font 1** (DOS's port font would be the leader font); none was seen in an audience.
4. **The text-only path is not drawn** (O6:1D49..1E29: DOS without the picture disk).
5. **The portrait is DOS's** (`LEADER_PORTRAIT[tribe]`); where the core reads another KING picture it is counted
   (`portrait_differs`; 0 in the runs).
6. **No new owner and no new PDOS_AS bit** (the orchestrator's limits): the owner "palace" delegates; I-menu decides.

## What the user checks

On the coordinator's user build (D7k landed; `civ64.exe`, DOS files present), in a game with the DOS graphics.  The
leader screen fills the window as a 320 x 200 DOS screen (4:3 when "Correct 320 x 200 to 4:3" is checked); no box has a
Go Back or Cancel row:

* **D7k-1** The audience (load `CAE3540B.SAV`, the user build's copy; end its own turn, 3540 BC, with Space for each
  unit that asks for orders and Enter at "End of Turn"; while the other civilizations move the Zulu emissary asks to
  speak with you; answer Yes): the throne room of DOS appears at once, Shaka in the middle with attendants on both
  sides and a stone panel with two spears across the bottom; the pointer is hidden while it loads.  The greeting is
  written on the panel in a decorated font, lines 8 pixels apart, without a box frame.  Enter goes on.
* **D7k-2** The treaty offer: two rows (Reject, Accept) under the text on the panel, one highlighted; the arrow keys
  move the highlight, a letter (A, R) or Enter chooses, a click on a row chooses it.  After Accept a welcome speech
  and a "You respond" box with three answers follow in the same place and font; each speech replaces the previous
  text; after the last the map returns with the fade from black.
* **D7k-3** Another audience later in a game (another civilization, another government or rank): the court's
  background and attendants follow that civilization's government and rank as DOS draws them, the leader's face and
  the text's font follow the civilization.
* **D7k-4** The same with the Windows graphics: the Windows leader window, unchanged.

Deviation 1 in the user's words (the orchestrator's ruling at the landing): the leader may stand still while his words
show; the DOS graphics draw DOS's frame at each frame the core draws, so if the Windows graphics animate the leader in
the user's own run, the DOS graphics should too.  WHAT-TO-CHECK asks the user to compare the two graphics in the same
audience (D7k-1 and D7k-4) and to report a Windows leader that moves while the DOS leader stays still; still in both
is the expected result for now.

Not part of this check: switching the graphics during the audience; the conquered leader (D7n).

## For the records

* **DOS-PROFILE** (staged): rows 19 and 100 "as implemented in D7k"; P11, P12, T2..T5, F9, F10, F17, E15, E21 closed;
  Open 11 (the leader cells resolved: DOS skips the same four cells) and Open 16 (the leader text read; F17's user).
* **OFFSETS** (staged): the seven rows and their note.
* **FORMATS.md 6.1** (the next docs pass; decision 9's correction): `[DGROUP:640A]` has both uses: `LEADER_FONT` (its
  first 16 bytes, B 10.1) and the throne-room tables (`LEADER_FACE_X/Y` at 10h and 48h, `LEADER_ATTEND_X/Y` at 80h and
  F0h).
* **SCENES-PLAY.md** 7.9 and Open 8 (the throne-room table read: the frames' places by animation style, O6:2380..23AF,
  2485..24C2); **OPEN.md** L21 (the leader part resolved) and L23 (the leader text's font read, O6:180F..1833).
* **FIDELITY.md** (the next docs pass, numbers by the pass): the idle animation follows the core and the core draws
  none while its Status window's paint is pending (deviation 1); the message boxes' font 1 (deviation 3); the text-only
  path not drawn (deviation 4); the D7F4 <-> g_playerCivId correspondence inferred.
* **FEATURES.md**: a D7k row: the DOS leader screen (rows 19, 100), the leader font by tribe, the runners of
  "Results".
* **DESIGN.md** 12.x "As implemented (D7k)": `pdos_scn_leader` (the claims through "palace" from LoadLeaderScreen's
  entry; TS at the show, TC idle frames, the end exit kind 1; the re-skin's `h8` and `at_place`); owners 9 of
  PDOS_OWNER_MAX 10, PDOS_AS 0x10000000 free.
* **RUNNING.md**: the `leader` diag line, the replay's `leader` field and timeline.log's two steps; test_pdos_leader.
* **STATUS / checklist** (the orchestrator's): D7k done (the user checks D7k-1..4 pending); OPEN L21's leader part and
  DOS-PROFILE Open 11 and 16 closed; rows 19 and 100, P11, P12, T2..T5, F9, F10, F17, E15, E21 no longer D7 gate items.

## Expected changes at the build slot

Against D7e's cycle (`build/d7e-status.txt`, ALL_GREEN 23:42:19 UTC, RELEASE_OK 23:46:36 UTC):

* build.cmd: portable sources 306 -> 307 (`pdos_scn_leader.c`); one more test program (`test_pdos_leader.exe`).
* test.cmd checked: test_pdos_leader new, 119 checks; test_pdos_scene 141 -> 147; test_dos 23,267 -> 23,274
  ("registry: 78 -> 85 tables valid"; decoded 1,397 -> 1,404 lines); every other unit count unchanged.
  `registry.py check` REGISTRY_OK, `ok` lines 470 -> 498; the golden `tests/dos-decoded.txt` 1,397 -> 1,404 decoded
  lines (the seven `table LEADER_* ...` lines, staged); OBS_LINT_OK files 144 -> 146 (probes 203, callsites 101
  unchanged); OBS_TABLES_OK 203 / 101, pdos_scene_check 1084, ADAPT_OK rows 147 steps 27 unchanged; EXT_ADAPT_OK checks
  292 -> 299 (the d7k pair); EXT_TIMELINE_OK unchanged (53); P0_OK checks 476 unchanged; MIRROR_OK runs 29, REPLAY_OK
  70 unchanged; ZOOM_OK against the staged golden (exactly its 80 `dos load` lines changed: section "Results",
  ext_zoom), combinations 32, runs 108, samples 628; EXT_FRAMES_OK and the other suites unchanged; NODOS_OK (0 hits).
* ext_g1: EXT_G1_OK runs 77 unchanged (the Windows profile's frames do not change).
* Informational, may change (not predicted to the count): ext-p0's V1 and V2 `pdos_rows` of load, research, research2,
  quiz, arrival and s2 (row 19's and row 0's counts gone); ext-p0's V4d zoom lines of those runs (the audience now shows
  the N frame); ext-replay's informational V1 lines (`no_scene` 22 lower in each: load 22 -> 0); coverage.txt's "other
  functions entered"; nodos's file count (the three new sources and the new test program's outputs); OBS_COST.

## Rebase notes

* **Bases:** the tree's files after D7e's landing and the docs pass after it, their hashes in `obj/base-at-copy.txt`
  (`sha *file`) and rechecked equal to the tree by `obj/basesha.py` (`BASE-SHA256.txt`, its second line gives the time).
  The first bases (the tree after D7l2's landing and the docs pass e4f, 21:14:51 UTC) are in `obj/base-at-copy-raw.txt`;
  `pdos_replay.c/.h` were added at 22:11:28 UTC and `pdos_reskin.c/.h` and `tests/harness/ext_adapt.py` at 22:27:25 UTC
  (`obj/base-added.txt`, after D6fSc's landing).
* **D6fSc** (copy-in 21:46:57, RELEASE_OK 22:30:10 UTC): `docs/dos/OFFSETS.md` merged by hand (D6fSc's BOX_* rows and
  note, then D7k's; `obj/rebase-d6fsc/`); `pdos_registry.c/.h` and `tests/dos-decoded.txt` regenerated by the tree's
  `registry.py` (`gen`, then `goldens --dosdata build/dosdata`); D6fSc's `pdos_reskin.c/.h` (equal to its stage) and
  `ext_adapt.py` taken as bases, D7k's re-skin edits applied by `obj/edit_reskin.py` (each edit an exact text of the
  base, asserted once) and the d7k pair inserted after D7m's.
* **D7e** (copy-in 22:59:02 UTC): `docs/DOS-PROFILE.md`, `docs/dos/OFFSETS.md`, `gen/dos/registry.py`,
  `present/dos/pdos_profile.c`, `pdos_replay.c`, `pdos_seq.c`, `tests/harness/ext_adapt.py` and
  `tests/headless/harness.c` merged three ways (`git merge-file -p` to stdout, read only to the repository;
  `obj/rebase-d7e/`: base = `build/d7e-prep/tree-before`, equal to D7k's recorded bases; theirs, mine, merged,
  resolved).  Five conflicts, each the two units' additions at the same place, resolved by keeping both: OFFSETS' rows
  and notes (D7e's, then D7k's), registry.py's OBSERVER_FILES (`pdos_scn_cityview.c`, `pdos_scn_leader.c`),
  pdos_profile.c's cursor rule (`pdos_cityview_pointer_hidden() || pdos_leader_pointer_hidden()`), pdos_replay.c's
  include and its decide blocks (the city view's, then the leader's).  D7k's staged `pdos_profile.c` and `pdos_seq.c`
  had lost the base's CRLF; restored before the merge (every staged file now has its base's line ends).
  `pdos_registry.c/.h` and `tests/dos-decoded.txt` regenerated again (85 tables); `adapters.py gen` reproduces the
  merged DOS-PROFILE.md.
* **The docs pass after D7e** (the tree's docs written 23:55:21 UTC): `docs/DOS-PROFILE.md` (rows 14, 22, 94, 141 and
  D6fSc's paragraph) merged three ways again (`obj/rebase-docs/`), no conflict (disjoint rows); `adapters.py gen`
  reproduces it, `obs_tables.py --check` and `pdos_scene_check.py` pass on it.  No other base changed.
* **Another landing** that changes these files: merge three ways (D7k's parts are `extension D7k` blocks and one-line
  hunks); `pdos_reskin.c/.h` by `obj/edit_reskin.py` on the new base; OFFSETS.md by hand and the generated files by
  `registry.py`; DOS-PROFILE's 1.7.2 by `adapters.py gen`.  `present/dos/pdos_shadow.h` (PDOS_OWNER_MAX 10),
  `pdos_scn_palace.h`, `pdos_adapt.c` and `pdos_adapt_tab.c` are the tree's (D7k adds no owner and no adapter row).
* **ext-zoom-golden.txt** (found while writing the landing's predictions, 2026-10-18 about 00:33 UTC): the `dos load`
  goldens sample the DOS frames through the audience, so D7k changes them; the file was staged at the landing with the
  tree's (D7e's landed) file as its base (`obj/base-at-copy.txt`), the 80 lines written by a private `--update
  --profiles dos` (`obj/zoompriv.py`: the tree's ext_zoom.py with the golden pointed at `obj/zoom/`), every other line
  the base's.
* **After the copy-in:** the base check, then build.cmd checked, test.cmd checked and ext_g1, guarded by each log's OK
  marker; the release build; the user build with `CAE3540B.SAV` (build/gamedata) as test input for D7k-1 and D7k-2.

## Landing

D7k landed alone at the build slot of session E4, 2026-10-18, before D7g (the orchestrator accepted D7k as READY and
the landing before D7g on this record's evidence, section "Result"; the slot free since 00:06 UTC, the docs pass
e4g's marker present, no cycle running).  The user checks D7k-1..D7k-4 are in the user build `d7k`.

* **The ext_zoom golden** (found while writing the predictions): `tests/harness/ext-zoom-golden.txt` samples the DOS
  frames of `load` through the audience, so D7k changes 80 of its `dos load` lines.  A private `--update --profiles
  dos` and the whole ext_zoom against that golden (section "Results", ext_zoom), and ext_slots and ext_tld (equal to
  D7e's cycle) ran first, 00:36..01:23 UTC; the golden was staged with D7e's landed file as its base and
  `BASE-SHA256.txt` written again (`obj/basesha.py`, BASESHA OK).
* **Bases:** `build/d7k-prep/land.py` (from D7l2's) rechecked every base (DRY_RUN_OK 26; build.cmd and test.cmd
  unchanged), took the snapshot `build/d7k-prep/before` (the tree's `build/test/Checked` outputs of D7e's cycle, 66
  files) and `tree-before` (the 22 replaced files), and copied in at 01:25:44 UTC (`landed.sha256`: the 22 changed and 4
  new files with this record, rechecked equal afterwards; `landed-at.txt` "unit d7k"; `land-write.log`).  Predictions
  `build/d7k-prep/predictions.txt`, written before the copy-in.
* **The three-step cycle** (`build/d7k-prep/d7k-cycle.ps1`, status `build/d7k-status.txt`, each step guarded by its
  log's OK marker): 1 `build.cmd checked` BUILD_OK 01:26:12..01:32:54 (401 s; portable sources checked 307; no
  warning); 2 `test.cmd checked` TESTS_OK 01:32:54..02:03:50 (1857 s; wall 1854.8 s: ext_zoom 1847.5, ext_adapt
  1643.2, d2_nodos 1417.4, ext_p0 1317.5 s; no flake rerun); 3 `ext_g1.py check` EXT_G1_OK runs 77 (amended 1)
  unchanged: **ALL_GREEN** 02:03:51.  4 `build.cmd` (Release) BUILD_OK 02:04:06..02:08:45 (279 s, no warning):
  **RELEASE_OK**.
* **Against the predictions** (`build/d7k-prep/compare.py` against the snapshot, `build/d7k-prep/compare.txt`: 52 of
  66 files equal, host times left out): as predicted, unit.log test_pdos_leader new (PASS 119), test_pdos_scene 141 ->
  147, test_dos 23267 -> 23274 (decoded content 1397 -> 1404 lines, registry 78 -> 85 tables), every other count equal;
  REGISTRY_OK with `ok` lines 470 -> 498 and the seven decoded `LEADER_*` lines; OBS_LINT_OK files 144 -> 146 (probes
  203, callsites 101); OBS_TABLES_OK, pdos-scene-check (1084) and ADAPT_OK rows 147 steps 27 unchanged; NODOS_OK 0 hits
  (files 1814 -> 1819); EXT_ADAPT_OK checks 292 -> 299 (the seven d7k lines, as in the private run), every other line
  equal; P0_OK checks 476; REPLAY_OK checks 70 with the predicted `no_scene` lines (load, s2, arrival 22 -> 0;
  research, research2 47 -> 25; quiz 44 -> 22); ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32 centre
  runs 4 mzi runs 12 mzs runs 4 not zoomed 38/448 against the landed golden, with exactly the predicted informational
  lines (`load` shows dos 458 -> 470, sw 416/412 -> 426/422; `s4` sw 4696/4607 -> 4716/4629); EXT_TIMELINE_OK,
  MIRROR_OK runs 29, EXT_SLOTS_OK, EXT_TLD_OK, EXT_FCE_OK runs 8, EXT_DBL_OK checks 4, EXT_FRAMES_OK and the other
  sections unchanged.  ext-p0's V4d zoom lines, predicted as informational, changed in the six runs reaching an
  audience: load and s2 216 -> 230, research and research2 177 -> 191, quiz 141 -> 155, arrival 172 -> 186 shows with
  the layer (the return's fade from black after the audience).  Also informational: coverage.txt "other functions
  entered" 671 -> 664 (the merged coverage files' known jitter); unit.log's OBS_COST line (host timing).
* **User build** `build/user-builds/d7k/` (02:08 UTC; `build/d7k-prep/mk_userbuild.py`): `civ64.exe` (the Release
  build, SHA-256 4215cc2e...), `CIVWIN.zip` and `civdos.zip` from `build/user-builds/d4/`, `CAE3540B.SAV` (a copy of
  build/gamedata's, read only: the Zulu emissary asks to speak at the end of its turn, 3540 BC), `WHAT-TO-CHECK.txt`
  (D7k-1..D7k-4 with the turn to end and deviation 1 in the user's words: compare the two graphics, a Windows leader
  that moves while the DOS leader stays still is to be reported; the earlier builds up to "d7e"; the 125 items still
  pending in the checklist at 02:08 UTC, `build/d7k-prep/fill_stillopen.py`, written by `mk_fill.py` from D7e's with
  the group "d7e").
* **Host load:** other units' private runs (d7f-stage's ext_zoom, d6fsd-stage's builds and frame runs) ran during the
  cycle; no flake, no rerun.

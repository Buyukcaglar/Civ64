# Extension phase D4, unit D4a (area B's base) - record

Unit D4a of the "civ64" extension: the DOS machine, the portable-C driver, glyphs and text helpers,
palette, the N and A canvases, the shadow surfaces, the scene table and stack, `pdos_rand`, the font
map and the Windows-1252 fold, and the pointer. After D4a the DOS profile presents its own N frame
(320x200) and its A frame (the Windows layout, with the core frame where no DOS art exists yet).
Design: [verify/ext-d1-draft-B.md](verify/ext-d1-draft-B.md) (revision 3) with
[verify/ext-d1-decisions.md](verify/ext-d1-decisions.md) and DOS-PROFILE.md. Brief:
[verify/BRIEF-d4.md](verify/BRIEF-d4.md). Session D4a, 2026-10-12.

Labels: **compiled** (the three language checks and `/W4 /WX`), **headless** (test programs and the
harness on `build/gamedata` and `build/dosdata`). No DOS program was executed; nothing was written to
`C:\Projects\Civ1RE\dos` or `build/dosdata`; no UI was shown; no DOS byte is in the repository or in a
binary (`gen/dos/nodos.py check`). No git command that writes was run. Asan was not built or run.

## Status

DONE for the three checkpoints of the brief (machine, draw, glyph, palette, compose; shadow, scene, font
map; pointer). The final cycle's results are in "Results" below. The pieces the brief assigns to other
units (D4b: `pdos_seq`, replay, prov, reskin, play, scene renderers; D5..D7: the scenes) are not here;
see "What is left".

## What was built

All modules are in `present/dos/`, portable C17, always compiled (the observer-only parts sit under
`#if CIV_OBSERVER`, so the `checked noobs` build links the same sources). Tests are in `tests/`.

| Module | Lines | Contents (design section) |
|---|---|---|
| `pdos_mach.h/.c` | 232 | indexed surface with damage and gen, DOS view port with the scale `k`, DAC, the machine of four 320x200 pages, `vga`/`box_texture` flags (3) |
| `pdos_draw.h/.c` | 895 | the driver in C: fill, line, pixel, sprite (clipped and unclipped), recolour, copy (G#20: forward, each row words then the odd byte, word read before word write, no overlap handling and no temporary buffer, as G:0000:0835..0844), span skip (one machine-wide column G:0000:1986), dissolve (G#10), the 16-bit offset arithmetic with the 64000-byte wrap rule, `PDOS_DIAG_OOB` / `LOOP_CAP` (4.1, 4.2) |
| `pdos_glyph.h/.c` | 505 | G#21 text with the store's fonts or a test font set, char/line height, the root text helpers R:0182:002A..00EF, truncation R:1F4D:04F7, wrapping R:1F4D:0000/0088, `$` tokens R:1F4D:0471 (10.2, 10.3) |
| `pdos_charmap.h/.c` | 92 | the Windows-1252 fold of core text to 20h..7Eh (10.4, B13) |
| `pdos_rand.h/.c` | 74 | the C run time's srand/rand and `random(n)`, the effect seed (FNV-1a-32) (9.3, B11) |
| `pdos_ui.h/.c` | 173 | clamp, outline, bevel, texture, panel, box, ornamental border, the page-2 art from SP299.PIC (4.3) |
| `pdos_pal.h/.c` | 417 | the 6-to-8 rule, DAC loads/splices/clear, fade arithmetic (32-bit, high word + bit 15), cycling slots, play slots 96..103/104..111/112..127, the scene recipes, the play palette (5) |
| `pdos_scene.h/.c`, `pdos_scene_tab.c` (the table is hand-written, B10) | 605 | the 141-row scene table and the scene stack: push at entry, pop at own exit or a configured exit or window destruction, pending window-bound rows, re-targeting by template, depth 16, listener, ready flags, `pdos_scene_wants_n` (9.1, 9.2) |
| `pdos_fontmap.h/.c` | 248 | the font id and call site to DOS font map, tracker, coverage log, leader-font hook (10.1) |
| `pdos_shadow.h/.c` | 1255 | the shadow engine: keyed shadows (kind, handle, rule set), logical/map/half resolutions, owners with hooks, macros (DROP/CONTEXT), brackets, copies per 7.4, the 7.5 hook interface, unexplained ring (7) |
| `pdos_compose.h/.c` | 619 | the N canvas and the A canvas, elements (1x/2x, transparent index 0, clips), frame kind (6.3), the 8-bit dump form, damage (6) |
| `pdos_cursor.h/.c` | 197 | the DOS pointer for the core's cursor id (torch, GO arrow, none, the game's cursor), the hidden rule of area C (6.7) |
| `pdos_profile.c` | 254 | the profile's callbacks drawing through the modules above; the call order of 2.1; `shows_core_frame` 0 (the DOS profile is shown through the tick); the pointer; the page-2 art; the play palette before the first play state |

Changed modules of earlier units: `pdos_common.h` (the 15 `PdosDiag` counters of D4a and
`pdos_diag_add`), `pdos_assets.c` (the names of the new counters in `g_diag_names` and `pdos_diag_add`, so that the
counters of area B reach `presentation-diag.log` through the existing loops), `gen/dos/registry.py`
(`OBSERVER_FILES`, `ALLOWED_OBSERVER_INCLUDES` for the new observer-reading files),
`tests/harness/obs_lint.py` (`check_b_tables`: the keys, call sites and phases of the `ROW(...)` rows of
`pdos_scene_tab.c` and of the `PdosMacro` initialisers; RV2-1, RV2-4).

Tests (all in `tests/`; each prints `PASS|FAIL test_X: N checks, M failed`; vectors are hand-written,
hashes or live reads of the store; no DOS byte):

| Test | Checked | CheckedNoObs | Covers |
|---|---|---|---|
| `test_pdos_draw.c` | 135 | 135 | every driver function with hand-built vectors, the wrap and drop rules, the 65536-iteration loops (RecolourRect with w = 0: 64000 writes, 1536 dropped reads), dissolve, and every function again on a k = 2 port with an odd origin equal to the k = 1 result at 2x (15.1) |
| `test_pdos_glyph.c` | 182 | 182 | G#21 colour bytes, widths from the metrics, helpers, truncation, wrapping, `$` tokens, the fold |
| `test_pdos_pal.c` | 236 | 236 | the 6-to-8 table, loads, splices, fade arithmetic, cycling, play slots, recipes; **P4**: all ~140 palettes of the store against PALETTE.md 6 (`pdos-p4-report.txt` in the output directory) |
| `test_pdos_rand.c` | 49 | 49 | the generator against an independent model and the Microsoft C sequence for `srand(1)`, `random(n)`, the effect seeds |
| `test_pdos_ui.c` | 34 | 34 | clamp, outline, bevel, texture (fill and tiles), panel, box, border (both tile sets), the page-2 art against the store |
| `test_pdos_scene.c` | 118 | 118 | the table's invariants and its resolution (no configuration error), pushes and pops, call-site rows against wildcard rows, window-bound rows (pending/bound/re-targeted/withdrawn), exits that pop several rows, recursion, depth 16, listener, ready flags, **and the font map** |
| `test_pdos_shadow.c` | 117 | 115 | claim/owners, brackets, macros (outermost owner), copies (7.4), rule sets, unexplained ring, context, configuration errors, the window-shadow rule |
| `test_pdos_compose.c` | 68 | 68 | frame kind, N and A elements, the dump form, 7.4 determinism at compose level (0, 1 and 5 peeks) |
| `test_pdos_cursor.c` | 62 | 62 | every cursor id of DOS-PROFILE 2.5, the hidden rule, the palette and the frame scale |
| `test_pdos_profile.c` | 38 | 36 | the profile through the present layer: registration, visibility, 7.4 (never visible / switched at ticks / visible from the start: identical per-step peek hashes), the frame kind over time |
| **sum** | **1039** | **1035** | |

`tests/harness/pdos_scene_check.py` (new; a step in `test.cmd` after `obs_lint.py`): the scene table
(141 rows, in order) against DOS-PROFILE.md 1.1..1.5 and 1.8 (class, timeline bits, first adapter, entry
function name and address, call site against the document's call instruction, dialog number, class
counts 57/44/30/10) and the font map against 2.4 (F1..F12, the Civilopedia rows, every call-site row
names a `SetCivFont` call of `core/`): 1075 checks. It prints `info:` lines for the facts the document
does not give (rows 6, 24, 119: the call site is the observer table's; row 9: the exit probe). Since the
docs placement of 2026-10-12 (about 05:05 UTC) DOS-PROFILE.md names these call sites and the row-9 exit,
so the check matches them against the document and prints no `info:` line.

`tests/harness/ext_frames.py`: the dump check of the D3 gate now accepts the 8-bit form of the DOS N
frame (see Deviations).

## Results of the final cycle

The 8 steps of the brief, every one green (2026-10-12 04:17..05:12 +03:00; logs
`build/d4a-final-<n>-*.log`, status `build/d4a-final-status.txt`):

| Step | Result |
|---|---|
| 1 `build.cmd checked` | BUILD_OK, 177 s (267 portable sources, C11 + C17 `/W4 /WX` + clang C99 parse) |
| 2 `test.cmd checked` | TESTS_OK, 1806 s: the 10 `test_pdos_*` (1039 checks), REGISTRY_OK, NODOS_OK, P4_TESTS_OK, OBS_LINT_OK, `pdos_scene_check` 1075 checks, P0_OK 279 checks (V0..V7 incl. V1 `--graphics dos` and V2 switching every 997 ms), EXT_FRAMES_OK, EXT_ADAPT_OK 20, MIRROR_OK 29, ZOOM_OK 32 combinations |
| 3 `ext_g1.py check` (Checked) | EXT_G1_OK runs 77 |
| 4 `build.cmd checked noobs` | BUILD_OK, 168 s |
| 5 `test.cmd checked noobs` | TESTS_OK, 681 s: 1035 checks in the 10 `test_pdos_*`, P0_OK 56 (V5: against the Checked V0 outputs) |
| 6 `ext_g1.py check --variant CheckedNoObs` | EXT_G1_OK runs 77 |
| 7 `build.cmd` (Release) | BUILD_OK, 161 s |
| 8 `test.cmd` (Release) | TESTS_OK, 324 s: 1039 checks in the 10 `test_pdos_*`, `pdos_scene_check` 1075 checks, NODOS_OK |

**P0 (the observer must not see the DOS profile).** Every core frame hash, checkpoint and `events.log`
of the harness runs with `--graphics dos` (V1) and with switching (V2) equals the Windows run (V0):
P0_OK 279 checks, EXT_G1_OK on both observer variants, V5 against V0 on CheckedNoObs. The code argument
is in "For the records" (FIDELITY): the profile reads only through `w16q_*` inside the observer guard,
writes only presentation memory, posts nothing, draws no core random number, never reads `g_randSeed`
(`grep g_randSeed present/dos` finds only the comments of `pdos_rand.h`).

**7.4 (frames do not depend on being looked at or on switching).** Unit level: `test_pdos_compose`
(the same frames after 0, 1 and 5 peeks, whenever the profile was visible) and `test_pdos_profile`
(DOS never visible / switched at ticks / visible from the start: identical per-step peek hashes through
the present layer). Harness level: `ext_frames.py` on S1 (`start`, 299 sample lines), S3 (719) and
`birth` (2049): the sample lines of A (`--graphics dos`), A' (again), B (`--switch-every 997`) and C
(`--graphics windows`) are identical, `presented.log` of A equals A', the switch assertions of 13.1
hold, and A shows the DOS profile through the tick only (374, 609, 955 tick shows, 0 core shows). The
dump check shows both forms: 376 `tick-NNNNN.bmp` of 8 and 24 bits (Deviation 10).

## What is left

Everything the brief assigns to the following units, and the parts of D4a that need an emulated run to
be exercised:

* **D4b**: `pdos_seq` (the intro, title and Birth timelines; the first caller of `pdos_scene_listen`
  and of `pdos_cursor_set_hidden_rule`), `pdos_replay`, `pdos_prov`, `pdos_reskin`, `pdos_play`, and the
  `pdos_scn_*` renderers. The calls are marked in `pdos_profile.c` where they will go. Until a renderer
  calls `pdos_scene_set_ready` no N scene is ready and the profile presents the A frame (the core frame
  while no element is set) after its first, black, N frame (6.3).
* **OB1** `pdos_play_back` and the BACK palette selection; the `GR_PortDataToBitmap` rebinding wiring
  (the engine's `on_resize` hook is built and tested; the 7.5 owner D6 is not there); the N-canvas
  window binding of 7.2 beyond `update_n_window` (D5).
* **Not testable without an emulated run** (left to `ext_p0.py` and `ext_frames.py`): the window
  enumeration of `update_wover` (`w16q_*`), `follow_cursor` (OBS_CURSOR), and the real P0 equality of
  the core hashes. The harness runs below exercise them with the profile drawing, but no scene
  renderer is ready yet, so no DOS art is on screen.
* The leader-font table of E (`pdos_fontmap_set_leader_table`; E's D7): until it is set the per-civ ids
  200..215 are unmapped and counted (`font_unmapped`).
* No `test_pdos_*` covers `follow_cursor` and `update_wover` (they read the emulation).
* Entry-only probes (no exit phase) are not used as scene rows: a row needs the X phase of its entry key
  unless it names an exit (RV2-1). Rows 6, 24 and 119 use call sites that the document does not name;
  they come from the observer's call-site table.
* **Not verified (review O1)**: DAC values are stored unmasked by `pdos_dac_load_m0`, `pdos_dac_from_m0`
  and `pdos_dac_load_raw`, where the DOS DAC keeps 6 bits and the cycling capture (R:0000:03CB..03D8)
  and fade start (R:0000:0554) read it back masked; equal while every palette value is <= 63 (PALETTE.md).
* **Not verified (review O2)**: bytes outside the string: `pdos_truncate` with a 2-byte string writes `.`
  where R:1F4D:050D compares the byte before the string with a space, and `pdos_wrap_prepare` with a
  final `^` assumes a 0 after the terminator where DOS reads stale DGROUP:BA06 bytes; fixed C answers.
* **Not verified (review O3)**: on `OBS_DLG_CREATE` only the topmost pending window-bound slot is
  considered and a template matching no row withdraws it (`pdos_scene.c` 237..240); a dialog function that
  first opens a message box of another template would lose its row. To be tested in D4b/D5.

## Deviations

Format: design section; what; why.

1. **9.1, 7.3 (keys).** Probe keys of the scene rows and of the macros are `OBS_P_*` row numbers
   (`uint16_t`), not `uint32_t` addresses. A static initialiser cannot read `OBS_PROBES[]`; the
   constants are always available (also with `CIV_OBSERVER` 0). `PDOS_NO_KEY` (0xFFFF) is the absent key
   (the draft's 0), because row 0 of the table is `_ErrorMessage`. `obs_lint.py` checks the keys.
2. **9.1 (row fields).** `PdosSceneRow` has `exit_ra`, `exit_at` (`PDOS_AT_ENTER` / `PDOS_AT_EXIT`) and
   `dlg` as separate fields. Four rows use a configured exit: 2 (title menu: SeekSequence from
   11E0:0884, entry phase), 5 (Play on EARTH: the return of BeginWorldCreation from 11E0:01AD), 9 (Birth:
   DestroySequencePlayer from 11E0:01E3, entry phase) and 98 (reports: CloseReportScreen, entry phase).
   The exit probes of rows 5 (the call site) and 9 are the table's choice; the document does not name
   them.
3. **9.2 (pops).** The draft says the matching exit pops the row and everything above it. A single probe
   can also be the trigger of a row lower in the stack: the return of BeginWorldCreation ends row 5 (a
   configured exit) and row 3 (its own exit). The scan therefore continues below a popped slot; a return
   pairs with one entry only, so a recursive entry of one function pops one level per return. Found by
   the unit test (the first version stopped at the first hit and left row 3 on the stack).
4. **3 (names).** The page constants are `PDOS_SCR_W` / `PDOS_SCR_H` (`PDOS_W` is the scene class W of
   `pdos_scene.h`); `PdosMach` has `port[4]` (index 0 is the screen, DGROUP:0098; 1..3 are DGROUP:19C2/
   19D6/19EA) and `cur`, instead of `screen` plus `pport[4]`, and the `vga` and `box_texture` flags the
   texture and box routines read (R:1DC4:03DA, R:1D05:096F).
5. **9.1, 7.3 (configuration errors).** A scene row or a macro whose key lacks its phase or whose call
   site has no `OBS_CALLSITES` row is refused and counted (`scene_config`, `macro_config`), not faulted:
   a fault in presentation code would stop the core, which P0 forbids. `pdos_scene_config_errors()` is 0
   for the table as delivered (test) and for the observer's tables (obs_lint).
6. **7.4 (query).** The shadow engine reads the emulation through an injectable `PdosShadowQ`
   (`pdos_shadow_set_query`), default `w16q_*`; the unit tests inject a table so that the engine runs
   without an emulation.
7. **5.3, 7.3 (signatures).** `pdos_cycle_setup` returns `int` (0: the slot was refused: an empty or
   inverted range); `pdos_shadow_context(uint16_t key)` takes the row-number key.
8. **7.3 (exit_orphan).** An EXIT of a function that is a macro key but was entered from a call site the
   macro does not name opened no bracket; the first version counted it as `exit_orphan`. It is now
   ignored (only an exit with no entry of any matching macro is an orphan). Found by the shadow test.
9. **5.5 (A machine).** The A machine's DAC is loaded with SP257.PIC's palette at reset (equal to
   SP256.PAL, PALETTE 5) so that the pointer is visible on A frames before the first play state;
   `WdwMapOpen`'s exit sets the play palette again as in the design.
10. **6.3 / 13.4 (the dump check).** `tests/harness/ext_frames.py`: the check was "all `tick-NNNNN.bmp`
    24-bit". With the DOS profile visible from the start, the first shows are the N frame (nothing has
    been drawn yet, 6.3): a black 320x200 frame, 8-bit through `present_shown_indexed`. The check is now
    "bit counts a subset of {8, 24} with 24 present, no `presented-NNNNN.bmp`". The run shows
    `[8, 24]`. No core value is involved: the sample lines of A, A', B and C remain identical.

## Review fixes (2026-10-12)

The independent review [verify/ext-d4a-review.md](verify/ext-d4a-review.md) found no BLOCKER or MAJOR
and six MINOR findings. Edited: `present/dos/pdos_draw.c/.h`, `pdos_mach.c/.h`, `pdos_pal.c`,
`tests/test_pdos_draw.c` and this record. No other file changed.

| Finding | What was done |
|---|---|
| **F1** G#19 WriteRow with count FFFFh | Fixed. `pdos_write_row` counts the words in `uint16_t` as G:0000:03F4..03F8 (`inc cx; shr cx, 1` in 16 bits), so count FFFFh writes 0 words and reads nothing from `src` (it wrote the whole page and read 64 KiB before). |
| **F2** G#2 GrabSprite ignores the sprite-arena capacity | No code change; recorded limitation (below). |
| **F3** span-skip column G:0000:1986 per surface | Fixed. One value per machine, `PdosMach.span_x` (013Fh at init and reset, as the file holds it). Every page of a machine points at it (`PdosSurf.span`, set by `pdos_mach_init`/`reset`, kept by `pdos_surf_resize`; `pdos_surf_span()` returns the cell): G#49 (G:0000:047E, from `pdos_line` R:0000:100A and `pdos_pixel` R:0000:104F) writes it and G#39 (G:0000:0436, `pdos_fill_rect`) reads it for a fill on any page. A surface outside a machine (a shadow, an element; `span` NULL) keeps its own value, 0FFFFh at init: no DOS counterpart. `pdos_surf_clear` resets only the surface's own value; ClearPage never touched G:0000:1986. Draft B 4.2's "per surface" is superseded for the pages of a machine (for DESIGN/draft owners). |
| **F4** record wording on CopyRect | Corrected in the module table: G#20 is a forward word-then-odd-byte copy with no overlap handling and no temporary buffer (G:0000:0835..0844); the code already did this. |
| **F5** G#31 ShowPage's ghost pointer | No code change; recorded limitation (below). |
| **F6** G#28 LoadPaletteBlock with last < first | Current behaviour kept and documented (comment at the loop of `pdos_dac_load_m0`): DOS counts `last - first + 1` in 16 bits (G:0000:017C..0188) and writes that many triples with an 8-bit index (G:0000:01A1..01DB), so last < first would write about 65536 triples read far past the chunk, from memory DOS does not define; it cannot be reproduced honestly. The C writes nothing. Unreachable with the shipped files (PALETTE 5: every M0 chunk is 0..255). |
| **O1..O3** | One line each in "What is left" as "Not verified". No code change. |

**Recorded limitations.**

* **F2: the sprite arena is not modelled.** DOS builds a grab (G#2 GrabSprite G:0000:0B85) into the
  arena that G#18 opened: BeginSprite G:0000:0A78 returns 0 and nothing is built when the arena is
  closed or full (G:0000:0A7B..0A84, `jbe`), and AddSpriteRow G:0000:0AF9..0B14 decrements the stored
  height (`dec word es:[2]`) and closes the arena when the next row (`rows * (w + 4)`) does not fit, so
  a grab larger than the free arena keeps only the rows that fit. `pdos_grab` allocates `w * h` bytes
  on the host and always grabs every row (design 4.2: `PdosShapeBuf` is B's own save-under). Noted in
  `pdos_draw.h`. **D4b/D5 must check**, for each renderer that transcribes a G#2 call site, the arena
  size its scene opens with G#18 against the sum of `rows * (w + 4)` of the grabs made into it before
  the next G#18; if a grab can exceed it, the renderer must carry an arena budget and drop the rows (or
  the whole sprite) as DOS does.
* **F5: ShowPage's ghost pointer is not modelled.** G#31 ShowPage G:0000:063C first calls G#9
  (G:0000:0649..064D -> G:0000:030E), which saves the pixels under the pointer and draws the pointer
  with G#6 into page n; the copy to the screen follows, and G#15 restores the save-under into page 0
  only (G:0000:0251). Page n keeps the pointer pixels until redrawn, and a later CopyRect from page n
  can carry a ghost pointer. The accepted host-cursor design (draft B 4.2, 6.7) does not draw the
  pointer into pages. Noted in `pdos_draw.h`. **D4b/D5 must check** whether a scene shows the pointer
  (DGROUP:5876 set, DGROUP:5403 clear) across a ShowPage and then copies from that page; such a scene
  would show a ghost in DOS that the C does not draw.

**Test vectors added** (`tests/test_pdos_draw.c`, 135 -> 140 checks in every variant):

* F1: `pdos_write_row(page 2, 60, 3, src, 0xFFFF)` changes no pixel and does not bump `gen` (the loop
  runs 0 times, so nothing is read from `src`).
* F3: a line through port 0 with `maxx = 199` sets `PdosMach.span_x` to 199; then a 1-pixel-wide
  `pdos_fill_rect` on page 1 at x = 199 (3 rows) draws nothing, and one at x = 198 is drawn.
* F3: every page's `span` is the machine's cell, 319 at init; `pdos_mach_reset` restores 319 (set to 7
  before) and the pointers; a plain surface has `span` NULL and its own 0FFFFh.

**Frame expectations.** No DOS-profile frame expectation changed: `ext_frames.py` and the unit-test
goldens were not edited, and the other nine `test_pdos_*` keep their counts and results.

**Cycle after the fixes** (one cycle, every step green, 2026-10-12 05:38..06:34 +03:00; logs
`build/d4afix-<n>-*.log`, status `build/d4afix-status.txt`; no Asan):

| Step | Result |
|---|---|
| 1 `build.cmd checked` | BUILD_OK, 171 s (267 portable sources, C11 + C17 + C99 parse) |
| 2 `test.cmd checked` | TESTS_OK, 1823 s: the 10 `test_pdos_*` 1044 checks (`test_pdos_draw` 140), REGISTRY_OK, NODOS_OK, P4_TESTS_OK, OBS_LINT_OK, `pdos_scene_check` 1075, P0_OK 279, EXT_FRAMES_OK, EXT_ADAPT_OK 20, MIRROR_OK 29, ZOOM_OK 32 |
| 3 `ext_g1.py check` | EXT_G1_OK runs 77 |
| 4 `build.cmd checked noobs` | BUILD_OK, 166 s |
| 5 `test.cmd checked noobs` | TESTS_OK, 675 s: 1040 checks in the 10 `test_pdos_*`, NODOS_OK, P0_OK 56 |
| 6 `ext_g1.py check --variant CheckedNoObs` | EXT_G1_OK runs 77 |
| 7 `build.cmd` (Release) | BUILD_OK, 161 s |
| 8 `test.cmd` (Release) | TESTS_OK, 326 s: 1044 checks in the 10 `test_pdos_*`, `pdos_scene_check` 1075, NODOS_OK |

P0 holds: no core value changed (P0_OK 279 and 56, EXT_G1_OK on both observer variants). For STATUS.md:
the 10 `test_pdos_*` now hold 1044 checks (Checked, Release) and 1040 (CheckedNoObs).

## Second review (2026-10-12)

The second independent review [verify/ext-d4a-review-2.md](verify/ext-d4a-review-2.md) found no
BLOCKER, six MAJOR (S1..S5, F1), seven MINOR (S6..S9, C1, P1, F2) and three observations. Edited:
`present/dos/pdos_shadow.c/.h`, `present/dos/pdos_common.h` (one comment), `tests/test_pdos_shadow.c`
and this record. No other file changed.

| Finding | What was done |
|---|---|
| **S1** a lost inner exit leaves brackets open | Fixed. At an exit the marks above the matched one are lost exits, counted in `exit_orphan` (one per mark; the counter's comment in `pdos_common.h` says so). The bracket loop pops while `group >= group` (groups grow with the stack, 9.2 "and everything pushed above it"). The matched group's brackets get their `leave` as before; brackets of a higher group close **without** `leave`: their function never returned, and the probe in hand is another function's exit. A late exit of the lost function finds no mark and is counted as before. |
| **S2** `PdosBracket.changed` mixes two coordinate spaces | Fixed. `record_event` unions `ObsDraw.rect` only. Draft B 7.3 defines `changed` as "the union of the suppressed device rectangles", which `leave` maps with 8.3 into the target's shadow; the engine's device coordinates are the DC's (client for a window, bitmap for a bitmap), as `engine_copy` and `note_unexplained` use. So `changed` holds the target's DC coordinates, unclipped, never `ObsDraw.changed` (screen); documented at `PdosBracket.changed` in `pdos_shadow.h`. Bitmap targets change only where `changed` was clipped. |
| **S5** DOS-only brackets drop the WIN rule set's events | Fixed (7.5). `drop_event` returns the mask of the rule sets suppressed: the union of `rule_sets` of the DROP brackets on the target (muted ones included). `on_draw` gives only the other rule sets to `do_copy`, to the owner's `on_draw` or to the unexplained count; the raw-bits path (`OBS_BMP_BITS`) likewise. Because a DROP macro with no rule set would now drop nothing, `check_macro` refuses it (`macro_config`; documented at `pdos_shadow_macros`). No registered macro is affected (D4a registers none outside the tests). |
| **F1** the 10.1 row "id 7 at the report header sites -> DOS font 1" | **Not added; gap recorded, open for D7.** The sites are enumerated nowhere: draft B 10.1 says only "the report header sites (O14 frame counterparts)", this record has no font table, and DOS-PROFILE.md 2.4 F7 says "report headers: Windows font 7 shadowed, DOS current font" with no site. `core/` has two constant `SetCivFont(.., 7)` calls: 1068:0A96 (Civilopedia, already a row) and 1108:0442 (not shown to be a report header); the others pass a variable id. Further, `tests/harness/pdos_scene_check.py` (outside this fix's files) requires exactly 8 rows and checks them against 2.4, which lacks the row, so a ninth row fails it. D7 must enumerate the report-header sites (SCENES-PLAY 7.14, DOS-PROFILE Open 10, OB4), add one `{7, 7, ra, 1, PDOS_FM_INFERRED, ..}` row per site, have the DOS-PROFILE.md 2.4 owner add the row and raise the check's row count, and add a `test_pdos_scene` vector (id 7 at such a site gives 1, at a shared site 7). No vector was added now: one that fails until D7 would break the cycle. |
| **S3** flushes inside a `leave`-drawing bracket (design gap) | No code change; design item for D4b below. |
| **S4** the N-canvas binding aliases page 0 (design gap) | No code change; design item for D5 below. |
| MINOR S6..S9, C1, P1, F2 and O1..O3 | No code change; one line each under "Open for D4b..D7" below. |

**Design items.**

* **S3 (D4b, before the first macro with a drawing `leave`).** A copy *from* a DROP target (the flush to
  the window, `CopyPortToWindow`, `DrawShapeAndFlush` with `g_autoFlushToWindow`) is applied when its
  BITBLT arrives (7.3 "Dropping"). Inside a bracket whose macro draws at `leave` (B's replay, 8.2) the
  flush comes before `leave` has drawn the DOS version, so the shown surface misses it until the next
  flush (DrawShapeAndFlush on port P with auto flush: P's shadow is copied to W without the shape, then
  `leave` draws the shape into P only). The D4b implementer must resolve this before registering the
  first macro with a drawing `leave`: either (a) in `on_draw`, when a BITBLT's source is the target of
  an open, unmuted DROP bracket whose macro has a `leave`, queue the copy in that bracket and apply the
  queued copies in order after `leave` at its exit; or (b) write down that 8.2 leave-drawers redo their
  own function's flushes in `leave`. Vector: DrawShapeAndFlush with auto flush on, W's shadow holds the
  shape after the exit. D's `enter`-drawing macros are not affected.
* **S4 (D5, replaces the N-window binding).** Whether a window shadow is page 0 is decided once, at its
  lazy creation (`key == g_nwin`, `pdos_shadow_get`); `pdos_shadow_set_n_window` only stores the handle.
  Two logical N windows open at once (A, then nested B) both get page 0 and alias it; a window that
  becomes the N window after its shadow exists keeps a private surface that nothing composes; a smaller
  client never sits at its logical position in page 0 (7.2). The mechanism cannot be extended; D5 must
  replace it: at most one shadow attached to page 0; on a change of `g_nwin` detach the old one (a
  private surface with a copy of page 0, or freed) and attach the new one (its private content copied
  into page 0 at its logical position, clipped and counted). Vector: two 512 x 320 logical N dialogs,
  a redraw of the lower one while the upper is the N window, then the upper's destruction. Decide O1
  with it. This supersedes "the N-canvas window binding of 7.2 beyond `update_n_window`" in "What is
  left" as an extension.

**Open for D4b..D7** (no code change):

* S6: a pending outer DROP bracket that binds late does not mute an inner named bracket on the same surface (`bind_pending`); mute the brackets above it with the same target, or refuse non-leaf NULL-target macros (D4b).
* S7: `free_surface_shadows` leaves open brackets on the freed (kind, key), so a recycled handle is dropped into and painted by the old bracket; mark them detached and count (D4b).
* S8: `pdos_shadow_rebind` moves only `key`: no size update, no `on_resize`, no retargeting of open brackets; D6 must complete it before wiring GR_PortDataToBitmap.
* S9: re-registering macros while brackets are open shifts `g_br[].mac`; refuse (or close counted) while `g_nbr > 0`, or store owner and macro pointer in `Br` (D4b).
* C1: one surface used by two elements loses damage on the one composed second; state one surface per element in `pdos_compose.h` or keep a per-element `gen` (D5..D7, before R boxes go on both canvases).
* P1: `update_wover` assumes the N scene window is top-level; compare against its top-level ancestor (D5, once the WI 4.2 dialogs' parentage is known).
* F2: the font tracker is global, not per `g_graf`; SetTextFontSizeColor's size is dropped; leader faces use `id - 200` instead of `g_playerCivId[n]` (record as a deviation with evidence or implement; D4b for logical text's word +10h, D7 for leaders).
* O1: page 0 is attached to the N window's shadow without clearing (previous scene's pixels stay); decide with S4 (D5).
* O2: `update_n_window` and `update_wover` run after every event and probe; the profile's largest per-event cost (measure in D5).
* O3: `PdosBracket.text` is read through `q_read` during the callback, as `observe.h` requires; correct, keep it so.

**Test vectors added** (`tests/test_pdos_shadow.c`, 117 -> 129 checks in Checked and Release, 115 -> 127
in CheckedNoObs):

* S1 `test_lost_exit`: outer DROP macro on bitmap 50, inner on 51, no inner exit, outer exit: depth 0,
  outer `leave` once, inner never, `exit_orphan` 1, no context left; a later SRCCOPY into 51 applies and
  a later fill on 50 is unexplained (not dropped); the late inner exit is one more `exit_orphan`.
* S2 `test_window_bracket_changed`: a pending DROP bracket bound to logical dialog window 20; a fill with
  rect (10, 10, 50, 50) and screen `changed` (110, 90, 150, 130), and one with an empty `changed`:
  `changed` is (10, 10, 70, 50), the target is window 20.
* S5 `test_drop_per_rule_set`: a DOS-rule owner and a Windows-rule owner on bitmap 80; a DROP macro with
  no rule set is refused (`macro_config`); inside a DOS-only bracket a fill and a SRCCOPY reach only the
  Windows-rule owner's `on_draw`/`on_copy`, nothing is unexplained, and the bracket records both for its
  DOS `leave`; a bracket of both rule sets drops for both; outside, both owners get the draw.

**Frame expectations.** No DOS-profile frame expectation changed: no golden, `ext_frames.py` expectation
or other `test_pdos_*` vector was edited; no macro or hook owner is registered outside the tests, so the
fixes do not change what the profile draws in D4a.

**Cycle after the fixes** (one cycle, every step green, ended 2026-10-12 07:48 +03:00; logs
`build/d4afix2-<n>-*.log`, status `build/d4afix2-status.txt`; no Asan):

| Step | Result |
|---|---|
| 1 `build.cmd checked` | BUILD_OK (267 portable sources, C11 + C17 + C99 parse) |
| 2 `test.cmd checked` | TESTS_OK, 1818 s: the 10 `test_pdos_*` 1056 checks (`test_pdos_shadow` 129), REGISTRY_OK, NODOS_OK, P4_TESTS_OK, OBS_LINT_OK, `pdos_scene_check` 1075 (8 font rows), P0_OK 279, EXT_FRAMES_OK, EXT_ADAPT_OK 20, MIRROR_OK 29, ZOOM_OK 32 |
| 3 `ext_g1.py check` | EXT_G1_OK runs 77 |
| 4 `build.cmd checked noobs` | BUILD_OK, 175 s |
| 5 `test.cmd checked noobs` | TESTS_OK, 687 s: 1052 checks in the 10 `test_pdos_*`, NODOS_OK, P0_OK 56 |
| 6 `ext_g1.py check --variant CheckedNoObs` | EXT_G1_OK runs 77 |
| 7 `build.cmd` (Release) | BUILD_OK, 175 s |
| 8 `test.cmd` (Release) | TESTS_OK, 351 s: 1056 checks in the 10 `test_pdos_*`, `pdos_scene_check` 1075, NODOS_OK |

P0 holds: no core value changed (P0_OK 279 and 56, EXT_G1_OK on both observer variants). For STATUS.md:
the 10 `test_pdos_*` now hold 1056 checks (Checked, Release) and 1052 (CheckedNoObs).

## For the records

Entries for the documents that this unit does not edit.

* **DESIGN.md**: 12.5/12.7 (the DOS profile): from D4a the profile presents its own N frame and A frame;
  `shows_core_frame` stays 0; the 8-bit dump form (`present_shown_indexed`) is used by the DOS N frame.
  9.2 of the draft: a probe may pop several rows (Deviation 3). 7.3: keys are row numbers (Deviation 1).
* **FIDELITY.md**: the P0 argument of D4a: the DOS profile reads the emulation only through `w16q_*`
  inside the observer guard, writes only presentation memory, posts nothing, draws no core random number
  and never reads `g_randSeed` (`pdos_rand` is its own generator, `test_pdos_rand`); the shadow engine's
  injectable query and the scene stack are pure of the emulation. The harness equalities: core frame
  hashes, checkpoints and `events.log` equal with the DOS profile drawing (`ext_p0.py` V1, V2) and
  `ext_frames.py` samples equal.
* **STATUS.md**: D4a done: the machine, driver, glyph, palette, compose, shadow, scene, font map and
  pointer modules; 10 test programs, 1039 checks (Checked) and 1035 (CheckedNoObs); `pdos_scene_check.py`
  1075 checks; P4 report (all palettes of the store against PALETTE.md 6: no mismatch).
* **RUNNING.md**: `test.cmd` has a step `[D4a: pdos_scene_check.py]`; the DOS profile's
  `--dump-presented` writes 8-bit `tick-NNNNN.bmp` for the N frame and 24-bit for the A frame;
  `test_pdos_pal` writes `pdos-p4-report.txt` into the test output directory.
* **FEATURES.md**: nothing.
* **DOS-PROFILE.md**: 1.1..1.5: rows 6, 24 and 119 name no call site (the observer table's are used);
  the exit probes of rows 5 and 9 are not named; row 98's exit is CloseReportScreen at its entry; the
  font rows F8 (the city labels and size digits are font 1 in DOS: inferred, OPEN L23), F9/F10 (per-civ
  ids use E's leader-font table, 8 + b with 10 replaced by 3: O6:17EA..181E).
* **manual-checklist-ext.md**: with `--graphics dos` (or after Ctrl+Shift+Backspace at the very start)
  the first frames are black until the core's first present, then the Windows layout: expected in D4a
  (the DOS art follows in D4b and D5..D7). The pointer on the A frame is the torch at frame scale 2.

# Extension phase D4, unit D4b2b2 (the DOS title box, the menu-box model, the pointer rule) - record

Unit D4b2b2 of the "civ64" extension: the DOS title box of C.7 on the sequencer of D4b2b1, the shared
menu-box model of draft B 4.4 / C.12.5, the pointer's scene rule (C.11.5), the D4a second review's S6, S7
and S9, and the remaining `ext_timeline.py` runs that need no D4c filter (a base `key`, `burn`) with the
model goldens (C-9). Design: [verify/ext-d1-draft-C.md](verify/ext-d1-draft-C.md) C.7.1..C.7.4, C.11.2,
C.11.5, C.12.5, C.6.6, C.15.3, C-9; [verify/ext-d1-draft-B.md](verify/ext-d1-draft-B.md) 4.4. Brief:
[verify/BRIEF-d4.md](verify/BRIEF-d4.md), "D4b split" (the D4b2b2 bullet). Preceding units:
[ext-D4b2b1-record.md](ext-D4b2b1-record.md), [ext-D4a-record.md](ext-D4a-record.md) ("Second review").
Session D4b2b2, 2026-10-12.

Labels: **compiled** (the three language checks and `/W4 /WX`), **headless** (unit tests and harness runs),
**DOS listing (model)** for the intro and title-box frames (the clock model of C.4 and the layout of
R:1D05:0475; no DOS-oracle comparison). Every constant cites its listing address
(`build/dos/disasm/root.lst`); the menu's strings are read from the store (`TITLE_MENU`) at run time and
are in no source or test. No DOS program was executed; nothing was written to `C:\Projects\Civ1RE\dos`,
`build/dosdata` or `C:\Projects\Civ1RE\original`; no UI was shown; no DOS byte is in the repository or a
binary (NODOS_OK). No git command that writes was run. Asan was not built or run. `present/obs_tables.c/.h`,
`gen/obs_tables.py` and DOS-PROFILE.md were not edited: every probe and call site needed was already in the
generated tables (IsKeyPending ra 1220:0AA5 is an `OBS_CALLSITES` row).

## Status

DONE. With no preselection the DOS view shows the DOS title box at the intro's hand-over (frame 4,766, or
146 frames after a key ends loop A), even while the core is still in its intro (T4); with a preselection it
holds the logo on black. The box follows the core's MenuZ selection when the core's title is ready, keeps
the chosen row after a choice, and is drawn again when the core opens dialog 139 again. The pointer is
hidden while the DOS intro runs. The final cycle is in "Results".

## What was built

| File | Contents |
|---|---|
| `present/dos/pdos_ui.h/.c` (changed) | the menu-box model `PdosMenuBox`, `pdos_menubox_layout`, `_draw`, `_select`, `_row`, `_hotkey` (B 4.4, C.12.5; R:1D05:0031..0475) |
| `present/dos/pdos_seq.h/.c` (changed) | the title box (C.7.1..C.7.4) on the intro's DOS run: `title_box`, `title_row`, `title_chosen`, `title_redraw` steps; the core's selection at MenuZ's key poll (`SR_MZ_READY`); `pdos_seq_title_state`, `_title_box`, `_title_view_row`, `_pointer_hidden`, `_set_query`, `_set_watch` |
| `present/dos/pdos_profile.c` (changed) | the pointer's scene rule before every `pdos_cursor_update` (C.11.5) |
| `present/dos/pdos_shadow.h/.c`, `pdos_common.h`, `pdos_assets.c` (changed) | S6, S7, S9; the diagnostic counter `detached` |
| `tests/headless/harness.h`, `harness.c`, `harness_main.c` (changed) | `--dos-watch F,F,..` (C-9: `watch frame F us U sha256 SHA` lines in `timeline.log`) and the script line `at <ms> burn <d>` (T6) |
| `tests/test_pdos_seq.c` (changed) | the title box and menu-box tests (below); 43 -> 83 checks |
| `tests/test_pdos_shadow.c` (changed) | the S6, S7, S9 vectors |
| `tests/harness/ext_timeline.py` (changed), `tests/harness/ext-timeline-golden.txt` (new), `test.cmd` (label) | the title box checks of `start`, the C-9 goldens, the `key` and `burn` runs |

### The menu-box model (B 4.4, C.12.5)

Layout of R:1D05:0475 on given lines (`const uint8_t *const *lines`, a line starting with ' ' or '_' is an
item, R:1D05:04EF): h = FontLineHeight with 9 -> 8, and 8 when the input `h8` is set (R:1D05:0494..04B5);
W = the widest line (each byte's glyph width, the leading space included); the lines are clamped to
(192 - y) / h (R:1D05:057D..059A); right = x + W + 8, bottom = y + nlines h + 6; framed iff y is even
(R:1D05:05E4). Colours (R:1D05:0031..0109): bar 7, or the screen's pixel at an odd y other than 139; bar2
22, 8 at y 139, -1 when frameless; the header colour 3 on a bar of 15, else 15. Text at (x + 5, y + 5 + i h):
headers in the header colour with a colour-0 shadow when h > 9, items in 0, or 3 when disabled. The
highlight (R:1D05:0238..0332) recolours (x + 3, y + 4 + (row + first_item) h, W + 5, h): bar <-> 11 and
bar2 <-> 3, so a select and a deselect restore the pixels. Hotkey of item k: the byte after its first
(DC4A, 32 entries). `pdos_menubox_row` (the row under a point; disabled per the 16-bit word) and
`pdos_menubox_hotkey` (R:1D05:03BF..03FD: from the current selection + 1 to 31, compared on the low 5
bits, no wrap; -1 for an item >= nitems or the OK form) are the entry points D4c's filter needs. Not
modelled: the advisor variant, the help line, drawing the OK form, the '^' marks, the EGA flash.

### The title box's states and sources (C.7)

| State (`pdos_seq_title_state`) | When | Row shown | Source |
|---|---|---|---|
| `NONE` | before the hand-over, or the intro view ended (the setup, Birth, Load's PLAY) | - | - |
| `SHOWN` | at the hand-over instant (the intro's `title` step, R:01A8:0486) with DGROUP:6B32 == -1 | the core's MenuZ selection when its title is ready (`g_menuSelection` 12B0:009C read with `w16q_rd16` at IsKeyPending ra 1220:0AA5, MenuZ's key poll), else the view's own row (0; `pdos_seq_title_view_row`) | R:01A8:0494: R:0238:0008(BA06 = copy of 1AE2, x 100 [04A8], y 140 [04A4]) |
| `CHOSEN` | the core's title MenuZ exit (ra 11E0:0729) with a result | the chosen row; the box stays (R:1D05:0441's wait(20) and the phrase-boundary wait 04C2..04DA omitted, C.7.4) | R:01A8:04B8 |
| `HOLD` | a preselection (DGROUP:6B32 != -1, R:01A8:04BB) | no box: the logo on black | C.7.1 |
| back to `SHOWN` | the core opens dialog 139 again after a choice or in `HOLD` (Load cancelled, Hall of Fame closed, Customize cancelled) | row 0 / the core's | R:01A8:0807 (`title_redraw`) |

Content: the store's `TITLE_MENU` string (the five DOS items) cut at LF, plus the added Quit row (" Quit":
the Windows title's added item of DOS-PROFILE 3.2, not a DOS string). A Windows title choice made during
the DOS intro finishes the intro (C.6.6): in the dissolve the finish reaches the hand-over and the box shows
with the chosen row; in the pan or the logo phases the finish freezes, and the box with the chosen row is
drawn over the frozen screen. The box is drawn on the intro's DOS machine (`pdos_mn`) in the intro's step
sequence (seq 1: R:01A8:0008 continues). The title box never sends input to the core.

`timeline.log` steps: `title_box` (R:01A8:0494, arg the row), `title_row` (R:1D05:0238), `title_chosen`
(R:01A8:04B8, arg the choice), `title_redraw` (R:01A8:0807).

### The pointer rule (C.11.5)

`pdos_seq_pointer_hidden()` is 1 while the DOS intro timeline runs (`pdos_tl_running`); `pdos_profile.c`
calls `pdos_cursor_set_hidden_rule(pdos_seq_pointer_hidden())` before each of its five
`pdos_cursor_update()` calls. Birth's timeline joins the rule in D4b3.

## S3, S6, S7, S9, F2

| Item | Outcome |
|---|---|
| **S3** | Not resolved, still open: this unit registers no macro (the title box draws on `pdos_mn` from the sequencer, not through a bracket), so no macro with a drawing `leave` exists. The first unit that registers one (D4b3 / D5 replay) must take option (a) or (b) of the D4a record with its vector. |
| **S6** | Fixed (`bind_pending`): when a DROP bracket with a NULL target binds late and is not itself muted, the DROP brackets opened inside it on the same surface are muted. Vector `test_review_s6_s7_s9`: the inner bracket gets no `leave`, the outer one's `leave` sees the event. |
| **S7** | Fixed (`free_surface_shadows`): an open bracket on a freed (kind, key) is detached and counted (`detached`); a detached bracket drops, records and draws nothing (`owned_by_outer`, `drop_event`, the exit loop). Vector: delete and recreate bitmap 50 inside a bracket: detached 1, the new bitmap's drawing is unexplained, no `leave`. |
| **S9** | Fixed (`pdos_shadow_macros`): a registration with brackets open closes them without `leave` and counts them (`detached`), as their stored macro indices no longer name their macros. Vector: re-register "D" while B's bracket is open: depth 0, detached 1, the exit calls no `leave`, no `exit_orphan`. |
| **F2** (logical-text part) | Not needed here: the title box draws with the DOS font on `pdos_mn`, not by logical replay. It stays D4b3's. |

## Tests

* `test_pdos_seq` (43 -> 83): `test_menubox_model` (hand-written lines: layout, keys, the h8 clamp, odd y
  and y 139, the row query, hotkeys without wrap, the box's pixels, select/deselect reversibility);
  `test_title_box` (the box at frame 4,766 equals a reference built from the store; nitems = DOS items + 1;
  Quit's key; the pointer rule; the box stays; the view row; the core's selection at IsKeyPending; the
  choice; the redraw; Birth ends the view; a preselection holds, then a redraw shows the box); `test_watch`
  (watched frames sorted, their hashes equal the reference, the box at 4,766). It writes
  `<outdir>\title-box.bmp` for a look (build output only).
* `test_pdos_shadow`: `test_review_s6_s7_s9` (the vectors above).
* `ext_timeline.py` (Checked, in `test.cmd checked`): runs `start`, `switch`, `key`, `burn`:
  * `start` 3: after the hand-over the DOS samples hold one frame, the title box (= the watched frame 4,766);
    4: one `title_box` at frame 4,766 (68.000007 s after t0), row 0, after the core's title MenuZ entry
    (21.2023 s); 5: the C-9 goldens.
  * `key` (`hwnd 0`, `at 10000 keydown 20 39 20`, `at 10050 keyup 20 39`, 20 s): the core's skip probe
    (SetGameCursor ra 11E0:08D7) at 10,162,250 us; loop A ends at its first key test after it, frame 716
    (tick floor(21 (x - 1) / 4) of column x, M7), the dissolve starts there, the box at frame 862 (+146, M10)
    at its instant, then held.
  * `burn` (`at 20000 burn 3000`, 30 s): the gap 20,000,000..23,000,000 us is logged in run.log; no DOS
    sample and no show inside it; the watched frames 1,450, 1,500, 1,550, 1,600 (inside the gap) hash as in
    `start`; the intro's 713 steps up to the run's end equal `start`'s; the first sample after the gap
    differs from the last before it (T6).

### The goldens (C-9)

`tests/harness/ext-timeline-golden.txt`, label **DOS listing (model)**: the DOS profile's N frame hash
(harness `frame_sha`) at t0 + pdos_frame_us(k) for k = 54, 1,952, 4,040, 4,120, 4,620, 4,766 (t0 = 50 us),
hashes only. Written by `ext_timeline.py Checked --record`; checked on every `test.cmd checked`. The watch
runs the timelines to each exact instant between ticks (`pdos_seq_set_watch`), so the hash does not depend on
the tick partition.

### DOS frame expectations changed

* `test_pdos_seq` (D4b2b1's tests): `test_skip_and_title_exit` (the finish now ends in the title box with
  the chosen row 2 at the hand-over), `test_title_exit_pan` (the box with row 1 over the frozen pan),
  `test_same_us` (the reference ends boxed; one `title_box`), `test_view_key` (a preselection: `HOLD`, no
  box). Reason: C.7 replaces D4b2b1's interim hold of the last intro screen.
* `ext_timeline.py` `start` 3: "holds one frame after the hand-over" now requires that frame to be the
  title box (the watched frame 4,766). Reason: the same.
* No other expectation changed: `ext_frames.py`, `ext_p0.py`, `ext_g1.py`, `ext_adapt.py`, the mirror and
  zoom checks, `test_pdos_profile` and every core frame, checkpoint, events.log and P0 expectation are
  unchanged.

## Results

The eight steps of the brief, 2026-10-12, in one run after the last source change; logs
`build/d4b2b2-<n>-<step>.log`, status `build/d4b2b2-status.txt` (ends `ALL_GREEN`); no Asan.

| Step | Result |
|---|---|
| 1 `build.cmd checked` | BUILD_OK, 191 s (271 portable sources: C11 + C17 `/W4 /WX` + clang C99 parse) |
| 2 `test.cmd checked` | TESTS_OK, 1989 s: `test_pdos_seq` 83, `test_pdos_shadow` 135, `test_pdos_ui` 34, `test_pdos_profile` 38, `test_pdos_cursor` 62, `test_timeline` 123, REGISTRY_OK, NODOS_OK, P4_TESTS_OK, OBS_TABLES_OK, OBS_LINT_OK, `pdos_scene_check` 1075, P0_OK 279, EXT_FRAMES_OK, EXT_TIMELINE_OK, EXT_ADAPT_OK 20, MIRROR_OK 29, ZOOM_OK 32 |
| 3 `ext_g1.py check` | EXT_G1_OK runs 77 |
| 4 `build.cmd checked noobs` | BUILD_OK, 199 s |
| 5 `test.cmd checked noobs` | TESTS_OK, 760 s: `test_pdos_seq` 83, `test_pdos_shadow` 133, `test_pdos_ui` 34, `test_pdos_profile` 36, `test_timeline` 123, NODOS_OK, P4_TESTS_OK, OBS_TABLES_OK, OBS_LINT_OK, `pdos_scene_check` 1075, P0_OK 56 |
| 6 `ext_g1.py check --variant CheckedNoObs` | EXT_G1_OK runs 77 |
| 7 `build.cmd` (Release) | BUILD_OK, 192 s |
| 8 `test.cmd` (Release) | TESTS_OK, 388 s: `test_pdos_seq` 83, `test_pdos_shadow` 135, `test_pdos_ui` 34, `test_pdos_profile` 38, `test_timeline` 123, NODOS_OK, OBS_TABLES_OK, OBS_LINT_OK, `pdos_scene_check` 1075 |

`ext_timeline.py` in step 2: all 19 checks pass (the figures under "Tests"); `timeline.log` of `start`:
1,497 steps, 3 probe lines, 10 watch lines.

**P0.** No core value changed: P0_OK 279 (Checked, with V1 `--graphics dos` and V2 switching now drawing
the box) and 56 (CheckedNoObs), EXT_G1_OK on both observer variants, EXT_FRAMES_OK, EXT_ADAPT_OK, the
switch run's equal core outputs (446 lines). `pdos_seq.c` reads the emulation only through `w16q_ret_ax`
and `w16q_rd16` under `CIV_OBSERVER` inside the observer's guard, posts nothing, never reads `g_randSeed`
and draws no random number (OBS_LINT_OK, `registry.py check`'s include rule).

## Deviations from drafts B and C

Format: section; what; why.

1. **C.7.2, C.11.2 (the core's selection).** Not OBS_CTL_CHECK on ids 500..520 (the core never emits it for
   MenuZ's items in these runs): `g_menuSelection` (12B0:009C) read with `w16q_rd16` at the entry of
   IsKeyPending from MenuZ's loop (ra 1220:0AA5, `mz_ready`), the instant MenuZ polls for a key. A change
   shows at the next poll.
2. **C.7.3, C.12.5, SCENES 10.1 (hotkeys).** The listing (R:1D05:03BF..03FD, 01C8, 0217..0233) only
   selects: the search runs from the current selection + 1 to 31 without wrap, and a hit does not choose.
   `pdos_menubox_hotkey` follows the listing; C.12.5's "select and choose" row and SCENES 10.1's cyclic
   search are not what R:1D05 does. D4c decides the translation.
3. **B 4.4 (the API).** `pdos_menubox_layout(b, m, p, lines, n, x, y)` takes the machine and the port (the
   pixel read at an odd y, the font); `nlines`, `first_item`, `nitems` are `int16_t`; `disabled` is
   `uint32_t` with the listing's 16-bit word (items >= 16 have no bit); added fields `sel`, `bar`, `bar2`,
   `hdr`, `key[32]`. `h8` and `disabled` are inputs the layout keeps.
4. **B 4.4 (`framed`).** Framed iff y is even (R:1D05:05E4 `test [bp+0Ah], 1` jumps over the frame for an
   odd y), not "y even or y == 139": at y 139 the box is frameless with bar 7 and bar2 8 (R:1D05:00BF, 00D1).
5. **C.6.6 (a title choice in the pan or logo phases).** The finish freezes there, so the box with the chosen
   row is drawn over the frozen DOS screen at the choice's instant. Choice.
6. **C.7 (the steps' sequence).** The title steps are logged in the intro's sequence (seq 1), as
   R:01A8:0008 continues into R:01A8:0486 in the same DOS run.
7. **C.7.2 (the view's own row and drag).** Entry point only: `pdos_seq_title_view_row(t, row)` moves the
   view's row while the core's title is not ready (refused otherwise or out of range). Up/Down and the drag
   need D4c's filter.
8. **C.11.5.** The rule covers only the intro's timeline; Birth's is D4b3's.
9. **C.15.3 (`burn`).** The harness script line `at <ms> burn <d>` advances the virtual clock by d ms at the
   API step with no tick (a long CPU-bound gap); it changes the core's clock, so the `burn` run is its own
   scenario and is never in a P0 comparison.
10. **C-9 (the goldens).** Taken through the sequencer's watch (`pdos_seq_set_watch`, the harness option
    `--dos-watch`), not from presented frames: the presented frame exists only at ticks, the golden instants
    lie between them.
11. **S9.** Resolved by closing and counting at registration, not by keying brackets by owner: registration
    belongs to the profile's set-up, between runs. New counter `detached` (S7, S9).

## What D4b3 and D4c must know

* **D4c (input).** The box's model is `pdos_seq_title_box()` (SHOWN or CHOSEN, else NULL): use
  `pdos_menubox_row` on frame-1 points for the press/drag/release rows (the `disabled` out flag),
  `pdos_menubox_hotkey(box, box->sel, key)` (selects only, no wrap; deviation 2) and
  `pdos_seq_title_view_row` for Up/Down and drag while the core's title is not ready (T4). When it is ready,
  the box follows the core's selection at MenuZ's next key poll: D4c's translation (C.13) drives the core,
  never the view. The title box sends nothing to the core. `HOLD` (a preselection) shows no box. The
  host-input `ext_timeline.py` run is D4c's.
* **D4b3 (Birth).** `SR_BIRTH` ends the intro view, so the box disappears (`NONE`); add Birth's timeline to
  `pdos_seq_pointer_hidden()` and to `run_all`; C.7.4's "the box stays until DOS Birth's first fade" is then
  Birth's to draw from `pdos_mn` as it is. The watch (`pdos_seq_set_watch`) counts frames from the intro's
  t0; Birth's goldens need their own base. The `birth` runs of `ext_timeline.py` remain. S3 and F2's
  logical-text part are still open for the first macro with a drawing `leave`.
* **Diagnostics.** `presentation-diag.log` has a new counter `detached`; `seq` also counts a missing
  `TITLE_MENU` string.

## For the records

Entries for the documents this unit does not edit.

* **DESIGN.md 12.7 (area B)**: D4b2b2 delivered the menu-box model in `pdos_ui.h/.c` (`PdosMenuBox`,
  `pdos_menubox_layout`, `_draw`, `_select`, `_row`, `_hotkey`; the layout, colours, highlight and hotkeys
  of R:1D05:0031..0475), and the shadow engine's S6 (late-bound DROP brackets mute the inner ones on their
  surface), S7 (brackets on a freed surface are detached) and S9 (a registration closes open brackets), with
  the counter `detached`. S3 remains open until the first macro with a drawing `leave`.
* **DESIGN.md 12.8 (area C)**: D4b2b2 delivered the DOS title box in `pdos_seq` (C.7: shown at the
  hand-over without a preselection, held logo with one; the row from the core's `g_menuSelection` at
  MenuZ's key poll, else the view's; the chosen row kept; redrawn at dialog 139's reopening; C.6.6's choice
  during the intro), the pointer rule `pdos_seq_pointer_hidden` (C.11.5), and the frame watch for C-9.
* **FIDELITY.md**: the DOS view shows the DOS title box (the five DOS items of the store and the added
  Quit row) at the intro's hand-over, positioned and coloured as R:1D05:0475 draws it at (100, 140); it
  follows the core's selection while the core's title menu waits; after a choice it stays with the chosen
  row (the DOS confirmation and phrase-boundary waits are omitted). The pointer is hidden while the DOS
  intro runs. Model goldens of six intro frames, labelled "DOS listing (model)" (no DOS-oracle comparison).
  Known gaps: the box takes no DOS-form input yet (D4c); hotkeys per the listing only select.
* **STATUS.md**: D4b2b2 done: the DOS title box, the menu-box model, the pointer rule, S6/S7/S9; S3 open
  (no drawing-`leave` macro yet), F2 for D4b3; `test_pdos_seq` 83 checks; `ext_timeline.py` with the `key`
  and `burn` runs and the C-9 goldens (EXT_TIMELINE_OK); no core value changed (P0_OK, EXT_G1_OK); the
  8-step cycle green (see Results).
* **RUNNING.md**: the headless harness takes `--dos-watch F,F,..` (at most 16 DOS intro frames; each writes
  `watch frame F us U sha256 SHA` to `timeline.log`) and the script line `at <ms> burn <d>` (advances the
  virtual clock by d ms with no tick; logged `burn virtual_us A to B` in run.log). `ext_timeline.py
  Checked [--record]` runs four runs (about 16 s); `--record` rewrites `tests/harness/ext-timeline-golden.txt`.
  `test_pdos_seq.exe <gamedata> <outdir>` writes `<outdir>\title-box.bmp`.
* **FEATURES.md**: the DOS graphics profile now shows the DOS title box after the intro (or after a key, or
  when the player picks a title item in the Windows view during the DOS intro), with the highlighted item
  following the game's; the mouse pointer is hidden during the DOS intro.
* **manual-checklist-ext.md** (D4 section, pending for the user): with `--graphics dos`: (1) after the
  intro the DOS title box appears below the logo with six items (the five DOS ones and Quit), the first
  highlighted; (2) moving the selection in the game's title menu moves the DOS highlight; (3) after a
  choice the box stays with that item highlighted until the next scene; (4) cancelling Load, closing the
  Hall of Fame or cancelling Customize shows the box again; (5) a key during the intro ends it and the box
  appears after the dissolve; (6) no pointer during the DOS intro; (7) a shortcut (preselection) start shows
  the logo on black, no box.
* **DOS-PROFILE.md**: nothing (no row, adapter or call site changed).

# D1 independent design review: index and resolutions

Extension phase D1 (`claude/docs/x64-port-scaling-dos-prompt.md` 9, gate: "Independent design
review recorded with resolutions."). 2026-10-11. Five design agents wrote the area drafts
under [BRIEF-d1.md](BRIEF-d1.md); two read-only reviewers who wrote none of them reviewed them under
[BRIEF-d1-review.md](BRIEF-d1-review.md); the orchestrator resolved every finding in
[ext-d1-decisions.md](ext-d1-decisions.md); the drafts' authors applied RV1 (Revision 2) and the
integrator applied RV2 and the merge items (Revision 3). The merged summary is DESIGN.md 12.5..12.11.

| Part | Scope | Report | Findings (blocker / major / minor / note) | Applied in | Resolutions |
|---|---|---|---|---|---|
| RV1 | drafts A (observer, probes, queries, tick, switching, input stages, P0 tests), D (map renderer and zoom, DOS map) and E (DOS assets) at Revision 1, with decisions K1..K9, C1..C7, E.18-1..5 | [ext-d1-review-rv1.md](ext-d1-review-rv1.md) | 1 / 6 / 9 / 4 | Revision 2 of drafts A, D, E (each draft's "Revision 2" list) | 20 resolved in "Design review RV1" of the decisions file: 19 applied as proposed or with the orchestrator's form, RV1-17 (B and C absent) handed to RV2; 0 rejected |
| RV2 | drafts B (composition, shadows, replay, palette, fonts, re-skins) and C (DOS clock, timelines, adapters, I4, I5) at Revision 2, and every interface between any two of A, B, C, D, E | [ext-d1-review-rv2.md](ext-d1-review-rv2.md) | 1 / 2 / 11 / 4 | Revision 3 of drafts A, B, C, D, E (each draft's "Revision 3" list) | 18 resolved in "Design review RV2": all applied as RV2 proposes, RV2-12 by its first option (at an exit the shadow engine draws before the scene pops, Choice B24); 0 rejected |

Totals: **2 blockers, 8 majors, 20 minors, 8 notes**; all resolved and applied in the drafts.

## Blockers and majors, and their resolution

| Id | Finding | Resolution | Where |
|---|---|---|---|
| RV1-1 (blocker) | D 14 and D 17 took the DOS map shapes (D4CE, D294, B886, ...) "through the offset registry", but they are run-time shape handles that O5:1455 fills at start-up, not image tables; no area produced the shapes | Area E owns `pdos_shapes`, which reproduces the cut O5:1455 from the decoded pictures at activation (cut table with cited O5 rectangles, unit recolouring, TER257 row rule with DGROUP:1A3E taken as 0, copies); D asks by family and DOS index; only tables below DGROUP:6B30h go through OFFSETS.md | E.9 (Revision 2); D 14.0, 17 E-1 (Revision 2, names aligned in Revision 3) |
| RV1-2 (major) | `present_map_point` already exists in `scale.c` with another meaning | D's function is `pmap_layer_point` | D 3, 12.1; A 10.1 |
| RV1-3 (major) | D's map modules were outside the build and collided with A's base names | `present/map/pmap_*.c`, build.cmd's loop, `INCS` and clang-tidy list gain `present\map` | D 3 |
| RV1-4 (major) | D's change requests to A were not adopted; two needed w16 changes not in K2 | A adopts A-1..A-8 (layer damage in the tick, `pmap_overlay`, three queries, `PiOut` anchors, frames 3 and 4, zoom logs, D's probes, zoom ids and options); K2 gains the `user_syscmd.c` outline state and the `gdi_draw.c`/`gdi_font.c` rasteriser split, guarded by G-1 | A 2, 5, 7.2, 8.3, 10.1, 17; DESIGN.md 12.10 |
| RV1-5 (major) | A's 7.3 and 7.4 DOS variations ran without DOS files, so the DOS profile was never registered | Every DOS variation passes `--dos-data build\dosdata`; the runner asserts from `profiles.log` that switches happened and none was refused | A 13.1, 13.2; D 16; E.13.6 |
| RV1-6 (major) | "Locate DOS files..." during a run had no design against E's activation before the emulation | Locate only records the choice; it takes effect at the next start; an unavailable profile is absent for the run | A 8.2, 10.2, 11; E.3.6; FIDELITY F117 |
| RV1-7 (major) | The DOS pointer had no working path to the host (D-3) | The cursor route: `w16_SetCursor` calls `present_cursor`; the visible profile gives the game's RT_CURSOR or pixels through the new `host_set_cursor_pixels`; a switch re-issues it | A 8.5; B 6.7; DESIGN.md 12.10 |
| RV2-1 (blocker) | The bracket macros and exit-time renderers of B and D (DrawMapTile, DrawUnitAt, DrawCityLabels, DrawSmTiles, RedrawSmMap, RedrawStatusWindow, DrawStatusCivPanels, DrawUnitInfoPanel, WdwMapOpen) had no exit probes: WI 10.6/10.7 list them entry only and A 4.3 took those sections "as WI", so DROP brackets never closed, the status and unit panels and the play palette were never drawn | A 4.3 gives the nine functions E and X (no new key, 203 keys); `obs_lint.py` checks that every `PdosMacro` key, every exit-0 scene row and every `OBS_AT_EXIT` consumer has the exit phase; `pdos_shadow_macros` refuses and counts a macro without it (via `obs_probe_phases`) | A 4.2, 4.3, 6.2; B 5.5, 7.3, 9.1, 12.2, 12.3; D 9.3, 17 A-7 (Revision 3). Verified against WINDOWS-INVENTORY.md 10.6 lines 762, 764, 767 and 10.7 lines 816, 818..822 |
| RV2-2 (major) | C's SETUP and CUSTOM transitions filtered on call sites (`ra` 11E0:020A, 11E0:0826) that were not `OBS_CALLSITES` rows, so C never entered either state (D-4) | A 4.3's table of C's rows and Open A1's generator input gain RunNewGameSetup `ra` 11E0:020A and CustomizeWorldDialog `ra` 11E0:0826 | A 4.3, 16 A1; C.11.2 (Revision 3). `ra` values checked: calls at 11E0:0205 and 11E0:0821 |
| RV2-3 (major) | The parts of a ring press did not stay on frame 4: neither A's arrival stage nor D 12.1 kept per-press state, so moves and releases split from their press (three cases) | The arrival stage latches each press's class (ring, layer view, neither) until its release: moves while a ring press is held and its release are frame 4 wherever they happen; a view press's parts stay frame 3 at the clamped point; tests for both crossings and the pole edge. C.20.2-2 confirmed | A 10.1, 13.4, 15; D 12.1, 12.2, 16.1, 20; C.12.2, C.20.2 (Revision 3) |

## Minors and notes of RV2, as applied in Revision 3

| Id | Finding | Applied |
|---|---|---|
| RV2-4 | No way to name an `OBS_CALLSITES` row | `obs_callsite(callee, ra)` (A 4.2); B and C resolve their rows at reset (B 7.3, 9.1; C.11.2); an unresolved pair is a Checked fault and a lint failure (A 6.2) |
| RV2-5 | C-11 not in either code block | A 10.1 and C.12.1 route a part of a C-decided action to `pdos_adapt_filter` when `pdos_adapt_note` returns 1; C's fallback withdrawn; `test_input.c` case (A 13.4, C.15.2) |
| RV2-6 | `pmap_filter_ring` and D's read interface undeclared | `pmap.h` declares `pmap_filter_ring`, `pmap_src_current`, `pmap_view_current`; types `PmapSrc`, `PmapSnap`, `PmapView` (D 3, 7.2, 12.2); B 12.2 uses them |
| RV2-7 | D 9.4 kept its own macro interface | D 9.3, 9.4 use B's `PdosMacro`, `PDOS_MAC_DROP`/`_CONTEXT`, `pdos_shadow_macros`, `pdos_shadow_hooks`; D10 closed |
| RV2-8 | D and E answered the page-2 rectangles differently | D 14.0 adopts E.9.2's form (`pdos_pic(PDOS_F_SP299_PIC)` inside `PDOS_PAGE2_ART_*`); Choice 18 changed; D9 closed |
| RV2-9 | C used E's names in a form E does not define | `PDOS_F_CREDITS_TXT`, `PDOS_F_STORY_TXT`, `pdos_text_line(id, i, &len)` (C.5.5, C.8.3, C.21 E-1) |
| RV2-10 | A's cursor text stale | A 8.5 cites `pdos_shape(PDOS_SH_ICON, ...)` and the DOS profile's callback for the conversion; Open A11 closed |
| RV2-11 | B's menu-box layout omitted two rules of R:1D05:0475 | `PdosMenuBox.h8` (h = 8 when DGROUP:3936 ≠ −1, R:1D05:04A8..04AF) and the row clamp to (192 − y)/h (R:1D05:057D..059A); `test_pdos_ui` vectors (B 4.4, 15.1) |
| RV2-12 | B popped the scene before the bracket's `leave` drew | At an exit probe: C's timelines to the probe's time, then the shadow engine, then the pop (B 2.1, 9.2, Choice B24; C.21 B-8) |
| RV2-13 | Citation errors in C | RanDoMRadio items created at 1220:09B0 only (C.14.2); `pdos_menubox_*` is B 4.4 (C.5.4); `pdos_srand` takes `uint16_t` (C.10.1) |
| RV2-14 | K2 omitted E's host.h additions | A 17's K2 and K5 gain `host_dos_read`, `host_dos_where`, `HOST_DOS_*` and their back ends (phase D2, guard E.13.3 and G-1); DESIGN.md 12.10 |
| RV2-15 (note) | ScaleLogical's 16-bit result | B 8.2 casts to `int16_t`; A 17 records that the ScaleLogicalX/Y exit may be dropped at D3 |
| RV2-16 (note) | R:0182:00B3 leaves the port opaque | B 8.2 records style 1 after the draw |
| RV2-17 (note) | Two names for the segment at DGROUP:640A | B 10.1 and E.10.3 record both uses (`LEADER_FONT`, the throne-room table); E's wording only |
| RV2-18 (note) | B11's instance ordinal must not depend on visibility | B 9.3 states the rule (effects start only in `on_event`, `on_probe`, `advance`) with a `test_pdos_rand` case |

RV1's minors and notes (RV1-8..RV1-20) were applied in Revision 2 as "Design review RV1" of the
decisions file resolves them; DESIGN.md 12.5..12.9 reflect them.

## Merge items applied by the integrator

* **C-11** (decisions, "Area C"): `present_input_filter` uses `pdos_adapt_note`'s return value (A
  10.1, C.12.1; with RV2-5).
* **X5** (decisions, "Area B"): D's label-font citation L17 corrected to L23 (D 14.3, 14.5, 17 B-4,
  21 D6).
* **D0 corrections** named by the decisions: OPEN.md P15 (C.20-1: PollMouseClick stores at 1108:017A
  and 1108:018F; checked with `showfunc.py` 1108:0000) and P22 (C.20-5: 237 movie frames);
  DOS-PROFILE.md row 9 and 3.1 (C.20-3) and 1.7 (C.20-4); TIMING.md 5.3's totals (C.20-6: with a
  key, "Cycles off" still runs; O2:0A0F..0A16 jumps to O2:0B26, checked in `ovl02.lst`).
* OPEN.md: every P item marked "Settled in D1" with its draft section.
* E's interfaces are unchanged: Revision 3 of draft E is wording only (E.9.5, E.10.3).

## Process deviations reported by the agents

None changed a result. RV1 chained `cd` before several read-only shell commands (its
procedural note); RV2 reports none. The integrator ran two read-only shell commands starting with
`cd` (a grep and a `showfunc.py` listing) and two Python edits from heredocs whose scripts contained
backslash escapes (against the brief's "write edit scripts containing backslashes with the Write
tool"; both edits were checked and are correct; the second, for this file, ran from the session
scratchpad rather than `build/d1/scratch-int/`), and one read-only `git status` of `claude/port/docs`
against the brief's "no git" (nothing staged or changed). One integrator `sed` substitution containing a
backslash-bar was read by GNU sed as alternation and altered draft B's text on 569 lines; the
integrator reverted it at once with a checked script (every altered line restored, no residue;
scratch `build/d1/scratch-int/revert_b_sed.py`) before any further edit of B.

## Verdicts

* RV1: area E sound (needs RV1-1, RV1-6, RV1-8); area A's P0 argument sound, its D3 gate blocked
  by RV1-5; area D detailed with sound P0 reasoning but not buildable without RV1-1..RV1-4. All
  applied in Revision 2.
* RV2: areas B and C sound and well evidenced (34 claims checked, no P0 path found); D1 should not
  close until RV2-1 is fixed and RV2-2, RV2-3 are applied. All three, and every minor and note, are
  applied in Revision 3.

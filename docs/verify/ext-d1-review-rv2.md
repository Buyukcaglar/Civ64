<!--
  D1 independent design review, part RV2 (areas B and C, and every interface between any two of
  the areas A, B, C, D and E).
  Reviewer: RV2 (an agent that wrote none of the drafts), 2026-10-11.
  Scope: ext-d1-draft-B.md (DOS machine model, palette, canvases and composition, shadow engine,
  logical replay, scenes, fonts and text, R re-skins, A elements), ext-d1-draft-C.md (clock model,
  timelines, intro, title, Birth, sequencing, filter stage and adapters, pending translations, I5),
  both at Revision 2, with the orchestrator's resolutions in ext-d1-decisions.md; drafts A, D and E
  (Revision 2) as far as their interfaces and the shared rules reach. The D2 code under
  claude/port/present/dos/ was not reviewed (only its file names were listed, for the base-name rule).
  Brief: BRIEF-d1-review.md, extended by the orchestrator to all cross-area interfaces.
-->

# D1 design review RV2: areas B and C, and the interfaces between all areas

## How I worked

* **Read.** BRIEF-d1-review.md, BRIEF-d1.md, the extension prompt
  `claude/docs/x64-port-scaling-dos-prompt.md` (all), the base prompt `claude/docs/x64-port-prompt.md`
  sections 1, 5, 7 and 9, DESIGN.md 6, 9 and 12.1..12.4, STATUS.md "Extension track" and "User
  directions", `ext-d1-review-rv1.md` and `ext-d1-decisions.md`. Drafts B and C in full. Drafts A, D
  and E at every section that defines or uses something another area relies on (A 0..2, 3, 4.2, 4.3,
  5, 7, 8, 10, 12, 13, 14, 16, 17; D 1, 3, 6, 7.1, 7.2, 9, 10, 12, 14.0, 14.8, 17; E 2.1, 4.1, 6.1,
  7, 8.1, 9.2, 9.5, 10).
* **Port sources** (line by line where a draft cites them): `platform/w16/queue.c` (441, 445, 552,
  553, 601, 642), `clock.c` (192, 193), `dos.c` (358), `user_cursor.c` (149), `host_sync.c`
  (176..190), `user_wnd.c` (1074, 1095..1115, 3527), `tests/headless/harness.c` (866..890).
  `core/gen/civ_layout.h` holds structures only, so the 34 Windows globals that B, C and D cite
  were checked against `claude/docs/db/names.json` (scratch `globals2.py`).
* **Windows functions** with `C:/Python314/python -B claude/tools/showfunc.py`: 11E0:0000,
  11E0:0221, 11E0:091E, 11E0:095F, 1220:0156, 11E8:02FB, 11E8:0D81, 11C0:3702, 10D8:01B0, 1208:0AF1
  (outputs `build/d1/scratch-rv2/sf_*.txt`), and `claude/src/c/seg002_1008.c` for WinMain's order.
* **DOS facts.** `docs/dos/` TIMING, PALETTE (2.3, 2.4, 3, 4, 6), DRIVER (G#10, G#21), FORMATS 6.1,
  SCENES 10.1, WINDOWS-INVENTORY 10, SPRITES, CORRESPONDENCE; the listing `build/dos/disasm/`
  (root.lst: R:0000:05B7..0630, R:0182:00B3..0133, R:1D05:018A..0238, R:1D05:0475..05AD,
  R:1DC4:005D..0099, R:2045:2AD8..2B11, R:2045:32B4..32CA; ovl02.lst O2:095A..0B59; ovl06.lst
  O6:1797..1851); bytes of `build/dosdata/CIV_UNP.EXE` through my own `dgdump.py`, which imports the
  port's read-only `gen/dos/dosexe.py` loader (DGROUP:1AE0..1B20, 1D60..1DA0, 2FA0..2FC0, 3936,
  640A, and R:26FA:0000..001F). No DOS program was executed.
* **Interfaces.** `xref_names.py` (output `xref_names.txt`) extracts the 558 interface identifiers
  of the five drafts (prefixes `pdos_`, `Pdos`, `PDOS_`, `pmap_`, `w16q_`, `obs_`, `OBS_`, `Obs`,
  `present_`, `pi_`, `Pi`, `host_`, `map_src_`) with the drafts that mention and declare each; I
  followed every name used by one area and owned by another. `v8.py` recomputes B 5.1's numbers.
* **Limits.** I did not redo B's P11 pixel check (B 13), E's decoders, A's key count (203) or RV1's
  FrameDesc classification. Nothing was built, tested or run; no git.
* **Lapses.** Two read-only shell commands began with a `cd` into the project, contrary to the
  instruction to use absolute paths without `cd`. Neither changed anything. Excluded paths of the
  main project were not read.

## Claims checked

| # | Draft claim | Checked against | Result |
|---|---|---|---|
| 1 | C.4.2: one DOS frame = 17,024 PIT clocks (≈ 70.086 Hz); NSOUND tick rule; `pdos_frames_done`/`pdos_frame_us` inverse and overflow bounds | TIMING.md 2, 3; my arithmetic | agrees |
| 2 | C.6.2 steps 3..8: O2:09D7 shortcut N, L, E, C (both cases) → DGROUP:6B32 0..3, other key −1; O2:0A0F/0A16 → O2:0B26; logo wait tick ≥ 3,463 at O2:0A19; slot 4 = DAC 224..239 rate 14 started; 80 strips of 4 pixels with `wait(1)`; hold ≤ 100 × (kbhit, `wait(5)`); flush R:0403:4545 and 6B32 = −1; cycles off O2:0B26..0B48 | ovl02.lst O2:09D7..0B48 (0xD87 = 3,463; R:0000:0382(4, 14, 0E0h, 0EFh); 03FA(4); loop step 4 to 140h; 64h; R:0000:042B for slots 1..4) | agrees, including C.20-6's correction of TIMING 5.3 |
| 3 | C.6.3 reference frames 54..4,766 (68.000 s); C.15.1 tick 3,463 → frame 4,040; dissolve 146 frames | TIMING 5.3; DRIVER G#10 (8,800 / 20 = 440 pixels per frame, 64,000 / 440 → 146) | agrees |
| 4 | C.8 Birth schedule and cycle tables; post-Birth fade R:01A8:0840 (5 steps, 30 frames) before the setup page | E.10.3 rows; PALETTE 3 table; root.lst R:01A8:0840..087C | agrees |
| 5 | C.6.1/C.8.1 T1 starts: CreateSequencePlayer ra 11E0:00A5, SeekSequence ra 11E0:01AA | showfunc 11E0:0000 (calls at 11E0:00A0, 11E0:01A5) | agrees |
| 6 | C.11.2 call sites of C's 19 probe rows | showfunc 11E0:0000, 0221, 091E; WI 10.5, 10.7; A 4.3 | every `ra` = call + 5; two rows are not table rows (RV2-2) |
| 7 | A 4.3 / C.13.2: IsKeyPending's entry probe precedes its ranged PeekMessage, so a release at that sync is seen | showfunc 11E8:02FB; queue.c:441 (`ranged ? W16_SYNC_POLL : ...`) | agrees |
| 8 | A 10.1 input-taking syncs and tick sites | queue.c 441, 553, 601, 642; clock.c 192; ticks queue.c 445, clock.c 193, dos.c 358, user_cursor.c 149 | agrees |
| 9 | A 1 item 2: P0 runs never reach the filter | host_sync.c:181 (returns under `W16_TIMING_NONE`); harness.c 868..889 (scripted input posted with `w16_queue_post_*` at `VM_STEP_API`) | agrees |
| 10 | C.14.2 class P: PollMouseClick stores signed `LOWORD(lParam)·10/16`; class W: `(u16)(10d) >> 4` in WaitForKeyOrClick and CityScreenWndProc; class S: ScaleLogical `(long)v·160/100` | showfunc 1108:0000, 1038:0C1D, 1030:9C17, 11E8:0D81 (`movsx`, `imul 0A0h`, `cdq`, `idiv 64h`, AX returned) | agrees; proofs re-derived (d = ⌈16L/10⌉ for P and W, ⌊1.6L⌋ for S); see RV2-15 |
| 11 | C.14.3 I-stack: row = (y − 5)/33 | showfunc 11C0:3702 (WM_LBUTTONUP when armed: `g_modalInputResult = (y − 5)/33 + 2`) | agrees |
| 12 | C.14.2 class C: MenuZ's RanDoMRadio children "created at 1220:08D5 and 1220:09B0" | showfunc 1220:0156 lines 836..837, 892..922 | 1220:08D5 creates `g_dialogTitleStatic`; only 1220:09B0 creates the items (RV2-13) |
| 13 | B 9.3 / C.10.1 generator: `srand` low word = seed, high 0; `rand` = s·343FDh + 269EC3h, (s >> 16) & 7FFFh; `random(n)` 32-bit signed product, arithmetic shift 15 | root.lst R:2045:2AD8..2B11, R:1DC4:005D..007B, R:2045:32C0 (`sar dx,1; rcr ax,1`) | agrees |
| 14 | B 4.2 G#10 dissolve: LFSR B400h, start 1, values above FA00h skipped, 8,800 / duration per frame | DRIVER G#10; O2:0B8B pushes (14h, 1) | agrees |
| 15 | B 4.4 `pdos_menubox_row` | root.lst R:1D05:018A..0233: `(DB3E − y − 4) idiv [2FA4] − [B1EC]`; −1 when x > mouse x or mouse x > DE0E; a disabled item keeps the previous row (R:1D05:01BF..01CB); −1 when < 0, ≥ D208, 8066 ≠ 0 or D206 ≠ 0 | agrees |
| 16 | B 4.4 layout "h: FontLineHeight, 9 → 8" | R:1D05:0494..04AF, 057D..0588; SCENES 10.1 | incomplete (RV2-11) |
| 17 | B 5.1: `(v·255 + 31)/63` equals round(v·255/63); floor differs in 30 values, bit replication in 10 | scratch `v8.py` | agrees (max error 10/21) |
| 18 | B 5.3 fade component round((s·(65535 − w) + t·w)/65536); C's `pdos_fade_weight(j, 48)` = min(65535, 1394j) | root.lst R:0000:05B7..0630 (`not dx; mul` = 65535 − w; `shl bp,1; adc bx,0` = round half up; w += step after each 768 components, saturating); PALETTE 2.3 (step = 65536/(p − 1), p = 48) | agrees |
| 19 | B 5.3 cycling: count ≤ 16, captured at set-up with a doubled copy minus the last, +1 moves colours up | PALETTE 2.4 | agrees |
| 20 | B 5.4 entries 0..15 differing from EGA: LOGO 5, 7, 8, 11, 15; SP256 all but 0, 3, 13; HILL 5..11, 14 | PALETTE 6 | agrees |
| 21 | B 8.2 DrawCenteredScreenText ↔ R:0182:00B3: x = cx − W/2, W = sum of G#4 advances, transparent | root.lst R:0182:00B3..0133 | agrees; see RV2-16 |
| 22 | B 10.1 logical text font = word +10h of `g_pScreenPort` (DS:2990), read at 10D8:01D2 | showfunc 10D8:01B0; names.json `g_pScreenPort` 1420:2990 | agrees |
| 23 | B 10.1 leader font: b = byte `[DGROUP:640A]:D7F4[n]`, font b + 8 with 10 → 3, stored at 67EC and port +10h | ovl06.lst O6:17EA..1833; file bytes R:26FA:0000..000F = 00 00 01 02 01 02 00 01 00 02 00 02 01 00 02 01 (DGROUP:640A = 26FAh in the file) | agrees; values 0..2 give fonts 8, 9, 3 (RV2-17) |
| 24 | B 10.2 G#21: skip without advance outside first..last; byte ≥ 80h sets colour & 7Fh; final colour stored back; returns x after, or x − port[02h] on early exit | DRIVER G#21 | agrees |
| 25 | B 11.2 menu-bar titles DGROUP:1D6F..1D8E with 87h after the first letter | CIV_UNP.EXE: "G\x87AME" 1D6F, "O\x87RDERS" 1D75, "A\x87DVISORS" 1D7D, "W\x87ORLD" 1D87, "C\x87IVILOPEDIA" 1D8E..1D9A | agrees (the range names the five string starts) |
| 26 | B 11.2 `MENU_PAD` 8; a w16 title rectangle is the text width + 16 | user_wnd.c 1095, 1115 | agrees |
| 27 | C.7 title text TITLE_MENU at DGROUP:1AE2 | CIV_UNP.EXE: " Start a New Game\n Load a Saved Game\n EARTH\n Customize World\n ..." | agrees |
| 28 | B, C, D Windows globals (34: `g_currentDialogPort` 1420:9948 .. `g_cityScreenMapMode` 1330:0000) | names.json | all agree |
| 29 | B 5.5 WdwMapOpen 1208:0AF1 marks the first play state | showfunc 1208:0AF1 (called by WinMain only); seg002_1008.c 178 (RunIntroAndTitleMenu) then 191 (WdwMapOpen) | agrees; its exit is not probed (RV2-1) |
| 30 | B 12.2, 12.3 and D 9.3 macros close their brackets at the probe's exit | WI 10.6 lines 762, 764, 767 and 10.7 lines 816..822: entry only; A 4.3 "as WI" | false (RV2-1) |
| 31 | B 8.2 DrawMapSprite index = D4CE index | CORRESPONDENCE 58, 331; SPRITES 6.3 | agrees (proved) |
| 32 | E.9.2 / B 6.7 pointer: torch = ICON 7 = TORCH 0, GO arrow ICON 2, hot spot (0, 0) | E.9.2, E.9.5; SPRITES 6.3 | B and E agree; A 8.5 is stale (RV2-10) |
| 33 | B 2 / C 2 / E.2.1 file base names unique across the build | the five drafts' file tables; base names of existing `*.c` | no collision |
| 34 | D 7.1 `seed` is `g_randomSeed` 13C0:0000, not `g_randSeed` 1420:4EE0 | names.json | agrees (no P0 path) |

## Interfaces between the areas

Every name used by one area was looked up in the area that owns it (scratch `xref_names.txt`).

| Pair | What was checked | Result |
|---|---|---|
| A ↔ B | `PresentProfile` callbacks (A 8.1) against B 2.1, in name, signature and order; `ObsEvent`, `ObsProbe`, `ObsDraw`; every `w16q_*` B uses (`msgbox`, `menu_item`, `menu_bar`, `menu_state`, `wnd`, `wnd_vis`, `wnd_client_vis`, `rd16`, `read`, `screen`, `btn`, `edit`, `draw_on`); `present_core_xrgb`; the cursor route and `PdosCursorImg`; `indexed` and the dumps; `OBS_SCREEN_SIZE`, `OBS_WND_SHOW` | match, except: exit probes (RV2-1), call-site rows (RV2-4), stale A text on B 6.7 (RV2-10), the ScaleLogical exit (X9, RV2-15) |
| A ↔ C | `present_input_filter`/`release`, `pdos_adapt_note`, `pdos_adapt_filter`, `pdos_pend_release`; `input_frame` and `HostEvent.frame` 0..4; `PI_MAX_OUT` 16 against `PDOS_PEND_EVENTS` 8; probe rows; `w16q_arg16`, `w16q_ret_ax`, `w16q_now_us`, `w16q_wnd_vis`; `present_log`, `adapt.log`, `coreinput.log`, `sync <n>` and `w16_host_input_sync_fn`; obs_lint's RandomBelow rule | match, except: two missing rows (RV2-2), C-11 not yet in either code block (RV2-5) |
| B ↔ C | `pdos_mn`; `pdos_copy_rect`, `pdos_show_page`, `pdos_sprite`, `pdos_fill_rect`; `pdos_dissolve_start/frame`; `pdos_fade_step`, `pdos_cycle_setup/step/advance` and the `PdosCycle`/`PdosCycleSlot` split; `pdos_menubox_layout`, `pdos_menubox_row`, `pdos_r_hit`, `pdos_setup_page`, `pdos_ui_box(PDOS_BOX_SETUP)`; `pdos_scene_listen`; `pdos_seq_on_event/on_probe/advance/reset/pointer_hidden`; `PdosRand` | match in names and signatures; C cites two outdated places (RV2-13) |
| B ↔ D | B's shadow engine (`PdosMacro`, `pdos_shadow_macros`, `PdosShadowHooks`, `pdos_shadow_hooks`, `pdos_shadow_context`) against D 9.3/9.4; macro exits; D's snapshot read interface for B 12.2; `Wn_dos`; `present_host_rect_inner`, `present_axis_taps` (B owns, D uses); `--mirror 2` needing `--dos-data` (B19, D 10.2); the small-map owner (C7, D 14.8); the label font (X5) | exits (RV2-1); D 9.4 not yet on B's names (RV2-7); D's read interface not exported (RV2-6); rest match |
| B ↔ E | `PdosPic`, `pdos_pic`, `pdos_pal_dac`; `pdos_font`, `pdos_font_row`, `pdos_font_advance`, `pdos_font_line_height`; `PdosShape`, `pdos_shape`, `PDOS_SH_ICON`, `PDOS_SH_REPORT`, `PDOS_POINTER_HOT_X/Y`, `PDOS_PAGE2_ART_*`; `pdos_assets_status` and `PDOS_OK`; registry rows TITLE_MENU, REPORT_CAPTIONS (present), SETUP_DIFFICULTY and LEADER_FONT (to be added by D5/D7); B's E3 answer (MGRAPHIC not needed) | match; the 640A segment's two names (RV2-17) |
| C ↔ D | frame 3 passes, frame 4 to `pmap_filter_ring`; the parts of a ring press (C.20.2-2) | not confirmed (RV2-3); `pmap_filter_ring` undeclared by D (RV2-6) |
| C ↔ E | `pdos_text_line`, `pdos_text_count`, `pdos_table`, `pdos_table_u16`; file ids; registry rows BIRTH_SCHEDULE, BIRTH_CYCLE, TITLE_MENU | rows and semantics match (E.8.1 line model, 24 and 52 records); names and arity differ (RV2-9) |
| A ↔ D | `pmap_reset`, `pmap_on_event/on_probe/on_core_present`, `pmap_overlay`, `pmap_pending`, `pmap_layer_point`, `pmap_hit`, `pmap_request_zoom`; `PiOut.cmd_hx/cmd_hy`; frames 3 and 4; D's A-7 probes | match, except the exits D 17 believes are "already in A's list" (RV2-1), `pmap_filter_ring` (RV2-6) and the ring frames (RV2-3) |
| A ↔ E | `available` = `pdos_assets_status() == PDOS_OK`; activation before `vm_init`; `host_dos_read`/`host_dos_where` in host.h; pointer shapes | match, except the K2 list (RV2-14) and A 8.5's withdrawn `pdos_pointer` (RV2-10) |
| D ↔ E | E-1 families by DOS index; E-2 rows DGROUP:1946/1956; page-2 rectangles | match except the page-2 form (RV2-8) |

## Rule coverage for areas B and C

"Met" means the design meets the rule and names its test; "deviation" means met with a recorded
deviation or choice; "not met" means the design as written cannot meet it.

| Rule | Area B | Area C |
|---|---|---|
| P0 | met (B 1; attempts below found no path) | met (C.2; filter off the P0 path, item 9 above) |
| O1 events | met | met (`OBS_WND_*`, `OBS_CTL_CHECK`, `OBS_FOCUS`, `OBS_EDIT`, `OBS_CURSOR` all in A 3) |
| O2 probes | **not met** for the status, small-map and play-palette brackets (RV2-1) | met except two call-site rows (RV2-2) |
| O3 reading | met (`w16q_*` only) | met |
| O4 forbidden | met (no writes, steps, posts; generator presentation-local) | met (no generator; `g_randSeed` never read) |
| O5 records | met through A's table and `pdos_scene_check.py` | met through A 4.3 |
| O6 concurrency | met (B 2.1: every callback, visible or not) | met (C.5.6) |
| O7 tick | met (`shows_core_frame` 0) | n/a (timelines advance at ticks) |
| T1 native pace, starts | n/a | met (item 5) |
| T2 both advance | met | met |
| T3 core not held | met | met (closed-form waits; the filter never waits) |
| T4 hold or continue | met (11.5 pages) | deviation recorded (C.20-3, title box and setup page; user check) |
| T5 skips | n/a | deviation recorded (P25 left click, C.20-2) |
| T6 clock | met (B reads no clock) | met (virtual time; FIDELITY note) |
| T7 core timing in play | met (cycling per CyclePaletteColors probe) | met (TC rows) |
| I1 | met (B produces no input) | met (only user-created translations) |
| I2 | n/a | met (frames 0, 3 identity) |
| I3 | n/a | met (adapter rows) |
| I4 | n/a | met once C-11 is merged (RV2-5) |
| I5 | met (`input_frame` 1 = DOS logical point; L(d) not used for input) | met (proofs re-derived; class C test obligation at D4) |
| I6 | n/a | met |
| I7 | n/a | met (chords never reach the filter) |
| I8 | n/a | met |
| 5.3 frames, composition | met | n/a |
| 5.4 classes, replay, core decisions | met; core decisions read, never recomputed | met (C.10) |
| 5.7 pointer and mapping | met (6.7) | met (C.11.5 hidden rule) |
| 5.8 map support | **not met** until RV2-1 (DROP brackets on D's macros never close) | n/a |
| 5.9 palette | met (round rule, P23 relabel) | n/a |
| 5.10 fonts | met (two rows inferred, X2) | n/a |
| 7.7 goldens | n/a | met (C.15.1, C.15.3) |
| 7.8 DOS-form input | n/a | met for D3..D7; for M see RV2-3 |
| Prompt 8: Birth in world generation; RNG-driven presentation; inverting the logical scale; 640x480 versus 320x200 | met (9.3; 6, with A's X3) | met (C.8.5; C.10; C.14) |
| D-3 before the game | met (pointer) | met (intro, title, Birth cycling) |
| D-4 setup and title branches | met on B's side | **not met** until RV2-2 (SETUP and CUSTOM never entered) |
| D-5 play (small map, status window) | **not met** until RV2-1 | n/a |

**P0 attempts (B and C).** Checkpoints and global blocks: no emulated write exists in B or C, reads
go through `w16q_*`, and the Checked sentinel traps a write. Virtual screen: B draws only on its own
canvases and reads `present_core_xrgb()`. Base event trace and queue: the only route to the core is
the filter's output, which P0 runs never reach (item 9). Emulated clock: C reads `w16q_now_us()` and
never advances the clock. `vm_steps`, `vm_site`: probe hooks run after the frame and outside
`VM_SITE` (A 4.2); B and C call nothing in `vm`. Handle numbers: B and C allocate no w16 object; the
pointer goes to `host_set_cursor_pixels` and `w16_SetCursor` keeps `g_current`. Checked diagnostics:
B's and C's counters go to `presentation-diag.log`; A's readers leave OOB records unchanged.
`g_randSeed`: refused by `w16q`; B's `PdosRand` is separate (item 13), C draws no number. Game screen
size: B never calls `present_game_screen*` (B 1). Key state: only `post_event` writes it; the lone
releases of RV2-3 and RV2-5 are input-consistency defects in Win32 and 7.8 runs, not P0 paths. No
path found.

## Findings

Counts: **1 blocker, 2 major, 11 minor, 4 notes.**

### Blocker

**RV2-1 (blocker). The bracket macros and the exit-time renderers have no exit probes.**
* *Drafts.* B 7.3 ("A bracket is the time between a probe's entry and exit"; "Exit. `leave` is
  called per rule set, then the bracket closes"), B 12.2 (DrawSmTiles 1210:09B4, RedrawSmMap
  1210:073F as DROP macros), B 12.3 (RedrawStatusWindow 1218:0801, DrawStatusCivPanels 1088:13D5 as
  DROP macros; the status panel "drawn at exit of DrawStatusCivPanels", the unit panel "drawn at exit
  of DrawUnitInfoPanel 11F0:468C"), B 5.5 ("at the first play state (`WdwMapOpen` 1208:0AF1 exit)"),
  D 9.3 ("Inside a macro bracket (entry to exit)": DrawMapTile 1110:04D0, DrawUnitAt 1110:0FF6,
  DrawCityLabels 1208:1F64). B 20 records A-B2 as "adopted (A 4.3 takes all of WI 10)"; D 17 A-7 says
  DrawMapTile, DrawUnitAt, DrawCityLabels and WdwMapOpen are "Already in A's list and used".
* *Evidence.* A 4.3 takes WI 10.6 and 10.7 "as WI" (A lines 520..521) and widens only 10.1, 10.2,
  TileCacheLookup, DrawUnit and the additions table. WI gives every one of these nine functions the
  phase **entry** only: 10.6 lines 762, 764, 767; 10.7 lines 816, 818..822. A 4.3's additions add
  E/X only to PlotSmMapSquare and DrawMiniPalace. So the probe table never fires an exit for them.
* *Effect.* The first DrawMapTile, RedrawSmMap, DrawSmTiles or RedrawStatusWindow entry opens a DROP
  bracket that never closes: from then on every core drawing event to the map port, the small map
  and the Status back port is dropped, and every inner primitive bracket on those surfaces is muted
  (B 7.3 "Ownership when nesting"). The status and unit panels are never drawn, the play palette is
  never loaded, the 7.5 present check fails, and D-5 cannot be met. An interface that cannot work as
  written.
* *Resolution.* A 4.3 gives E and X to these nine functions (no new keys; an exit costs one hook
  call). Add a build-time check (obs_lint or `pdos_scene_check.py`) that every key registered as a
  `PdosMacro`, every scene row whose `exit` is 0, and every consumer marked "at exit" has the X phase
  in `OBS_PROBES`; and let `pdos_shadow_macros` count a macro whose key has no exit phase.

### Major

**RV2-2 (major). C's SETUP and CUSTOM transitions filter on call sites that are not `OBS_CALLSITES` rows.**
* *Draft.* C.11.2 lines 799 and 806 mark "CustomizeWorldDialog 1108:0243 entry, exit, ra 11E0:0826"
  and "RunNewGameSetup 10E8:0000 entry, exit, ra 11E0:020A" as present in A 4.3 / WI 10 ("yes").
  C.11.2 also says "A call-site filter is a test of `site` ... C never compares `ra` itself".
* *Evidence.* The `ra` values are right (showfunc 11E0:0221: `call far CustomizeWorldDialog` at
  11E0:0821, next instruction 11E0:0826; showfunc 11E0:0000: `call far RunNewGameSetup` at 11E0:0205,
  next 11E0:020A). But WI 10.7 filters those two rows by the `GR_DialogOpen` calls inside the
  functions (line 787: 1108:028B; line 808: 10E8:0062 and 10E8:10B9), and A 4.3's table of area C's
  rows (accepted as C.20-9) lists neither (A lines 543..551). With no row, `site` is −1 and C's
  filter never matches.
* *Effect.* C never enters CUSTOM (the fade start of C.7.4) or SETUP (the setup adapters, the
  takeover of C.8.7's page). D-4 is not met.
* *Resolution.* Add the rows (CustomizeWorldDialog 1108:0243, `ra` 11E0:0826) and (RunNewGameSetup
  10E8:0000, `ra` 11E0:020A) to A 4.3's table of C's rows and to Open A1's generator input. RV2-4
  makes such an omission fail loudly.

**RV2-3 (major). The parts of a ring press do not stay on frame 4 (C.20.2-2 not confirmed).**
* *Drafts.* A 10.1's frame table (A line 1270): 4 = "a ring square press or release", stamped by the
  coordinates' frame. D 12.1's table (D line 689): over the ring a move is "clamped to the nearest
  point of the view ... then to the nearest visible client point" (delivered, so frame 3); a left
  press is frame 4, its release is frame 4 only when it happens on the ring; beyond the poles the
  release is "consumed". D 12.2 (D lines 715..717): "the later frame-4 release becomes the release at
  the same point; moves while held are consumed". C.12.2 assumes every part of a ring press is frame 4.
* *Evidence.* Neither A's arrival stage (A 10.1 `pi_arrive_mouse` order) nor D 12.1 keeps any
  per-press state: each event is stamped from its own position. Three cases follow.
  1. Moves while a ring press is held arrive as frame-3 moves with the button down and pass to the
     core (filter: frame 3 is identity), although the core's press was posted at the small map.
  2. A ring press released over the view, or outside the layer, gives a frame-3 or frame-0 release
     that passes unchanged; `pmap_filter_ring` never gets the release of the press it translated.
  3. A delivered view press (frame 3) released on the ring or beyond the poles gives a frame-4
     release, which D's table consumes. That contradicts D 12.1's own F100 sentence ("a release
     outside after a delivered press is delivered at the clamped point") and loses the core's release.
  C's pairing cannot repair any of these: the note records a frame-4 press as "decided elsewhere"
  with no point (C.12.2).
* *Resolution.* The arrival stage latches the frame class of each button press (ring or not) until
  its release and stamps every move and the release with it: during a ring press, moves get frame 4
  and are consumed by `pmap_filter_ring`, and the release is frame 4 wherever it happens; during a
  frame-3 press, the release stays frame 3 at the clamped point. A's frame table gains "move while a
  ring press is held". Add `test_input.c` cases for both crossings and for the pole edge.

### Minor

**RV2-4 (minor). No way to name an `OBS_CALLSITES` row.**
* *Drafts.* A 4.2: `ObsProbe.site` is "the matching OBS_CALLSITES row, -1 when none"; the table is
  generated (Open A1). B 7.3 `PdosMacro.ra` and B 9.1 `PdosSceneRow.ra` are return addresses
  "matched through ObsProbe.site"; C compares `site` (C.11.2).
* *Evidence.* No draft defines how a consumer turns (callee, `ra`) into a row index or names the
  generated rows. A consumer `ra` that is not a row silently never matches (the cause of RV2-2).
* *Resolution.* A adds `int obs_callsite(uint32_t callee, uint32_t ra)` (−1 when none). B and C
  resolve their rows once at reset; an unresolved pair is a configuration error (Checked fault and an
  obs_lint check against the generated table).

**RV2-5 (minor). Decision C-11 is not yet in either code block.**
* *Drafts.* A 10.1 (A lines 1325..1326) and C.12.1 (C lines 881..882) both still read
  `if (dos_registered && ev->frame != 1 && ev->frame != 2) pdos_adapt_note(ev);` and discard the
  return value. A 13.4's `test_input.c` list checks only that the note is called. C.12.2 gives the
  agreed one-line form.
* *Evidence.* ext-d1-decisions.md C-11: "present_input_filter uses the note's return value ... A's
  text is amended at the merge".
* *Resolution.* At the merge, replace both blocks with C.12.2's form and add a `test_input.c` case:
  the frame-0 release of a press consumed on frame 1 goes to `pdos_adapt_filter` and is consumed.

**RV2-6 (minor). Two functions other areas call are not declared by area D.**
* *Drafts.* A 10.1 and C.12.1 call `pmap_filter_ring(ev, out, max)` for frame 4; D 3's `pmap.h` and
  D 12.2 never name it. B 12.2 (Choice B17) reads "D's snapshot read interface (D 7.2)", but
  `MapSrc`, `map_src_snap`, `map_src_live` and an accessor of the latest `MapSnap` are not in
  `pmap.h` (D 3: "the interface to the rest of present/") and carry no `pmap_` prefix.
* *Resolution.* D declares `int pmap_filter_ring(const HostEvent *ev, HostEvent *out, int max)` and a
  prefixed read interface (for example `const PmapSrc *pmap_src_current(void)`) in `pmap.h`.

**RV2-7 (minor). D 9.4 still proposes its own macro interface.**
* *Drafts.* D 9.4 keeps `PsMacro`/`ps_register_macros`, `target` returning −1 for "not ours", and an
  `enter` without `leave`, flags or rule-set bits. B 7.3/7.5 give the final interface (`PdosMacro`,
  `pdos_shadow_macros("pmap", ...)`, `target` 0/1, `PDOS_MAC_DROP`, `PDOS_MAC_CONTEXT`,
  `pdos_shadow_context`, `PdosShadowHooks`), and B's D-B1 asks D to adopt it. D's B-4 and 14.3, 14.5
  still cite L17 (decision X5: L23).
* *Resolution.* At the merge D 9.3/9.4 take B's names: DROP on DrawMapTile, DrawUnit, DrawUnitAt,
  DrawCityLabels; CONTEXT on AnimateUnitMove and ResolveCombat; registration from `pmap_reset`.

**RV2-8 (minor). D and E answer the page-2 rectangles differently.**
* *Drafts.* D 14.0 asks `pdos_shapes` for the page-2 coast (224 + 16j, 100, 16, 16) and land base
  (256, 120, 16, 16) "by family and index" (its Choice; the alternative is "the module exposes the
  page-2 area as an image"). E.9.2 implements the alternative: `pdos_pic(PDOS_F_SP299_PIC)` at the
  same coordinates inside `PDOS_PAGE2_ART_*` (160, 50, 160 × 150), no shape family.
* *Evidence.* Both rectangles lie inside the page-2 art and above the government-portrait overwrite
  (160, 140, 160 × 60), so E's form serves them.
* *Resolution.* D 14.0 adopts E.9.2's form and cites R:1AEA:03BA and 07B2..07CD for its rectangles.

**RV2-9 (minor). Area C uses E's names in a form E does not define.**
* *Drafts.* C.5 (C line 420) calls `pdos_text_line(PDOS_F_CREDITS, i)` and
  `pdos_text_line(PDOS_F_STORY, i)`. E.4.1 generates one id per pinned file with its extension
  (`PDOS_F_CIV_EXE`, `PDOS_F_FONTS_CV`, `PDOS_F_SP299_PIC`), so `PDOS_F_CREDITS_TXT` and
  `PDOS_F_STORY_TXT`; E.8.1's function has a third parameter `uint32_t *len`.
* *Resolution.* C uses E's generated names and the three-argument form.

**RV2-10 (minor). Draft A's cursor text is stale.**
* *Draft.* A 8.5 (A line 1150): B builds the pointer "from E's shapes (E.9 `pdos_pointer`)"; A line
  1157 and A 17: "B 6.7's struct has no such state yet" (the game's cursor for 136..143); A16 Open A11.
* *Evidence.* E.9.5 withdraws `pdos_pointer`; B 6.7 uses `pdos_shape(PDOS_SH_ICON, 7 | 2)` and returns
  NULL for "no pointer of its own" (Revision 2), answering A11.
* *Resolution.* A cites E.9.2/B 6.7 and closes A11.

**RV2-11 (minor). B's menu-box layout omits two rules of R:1D05:0475.**
* *Draft.* B 4.4: `h` = FontLineHeight, "9 → 8"; no clamp of the visible rows.
* *Evidence.* R:1D05:04A8..04AF sets h = 8 whenever DGROUP:3936 ≠ −1 (3936 is FFFFh in the file and
  set to 1 at O6:183C in the leader routine, ovl06.lst); R:1D05:057D..0588 clamps the visible rows to
  (192 − y)/h. SCENES 10.1 records both. Both move rows and change `pdos_menubox_row`'s answer in
  D7 scenes (leader and diplomacy boxes, boxes low on the screen).
* *Resolution.* `PdosMenuBox` gains the 3936 state as a layout input from the scene and the row
  clamp, with `test_pdos_ui` vectors for each.

**RV2-12 (minor). At an exit probe B pops the scene before the bracket's `leave` draws.**
* *Draft.* B 2.1 `on_probe`: 1. `pdos_scene_on_probe` (push or pop) ... 4. `pdos_shadow_on_probe`
  (exit draws), the same order for entry and exit.
* *Evidence.* RedrawStatusWindow, DrawStatusCivPanels, DrawUnitInfoPanel, DrawSmTiles and WdwMapOpen
  are both scene-table probes (WI 10.7 rows 96, 136..139) and B macros (12.2, 12.3). At their exit the
  row is popped before `leave` runs, so a `leave` that reads the top row (its `colours`, `pal`,
  `renderer`, 8.4 and 9.1) sees the parent row.
* *Resolution.* At an exit, run `pdos_shadow_on_probe` before `pdos_scene_on_probe` (nesting order),
  or state that `leave` never reads the scene stack.

**RV2-13 (minor). Citation errors in C.**
* C.14.2 (C line 1288): the RanDoMRadio children are "created at 1220:08D5 and 1220:09B0"; 1220:08D5
  creates `g_dialogTitleStatic` (showfunc 1220:0156 lines 836..837); only the loop's 1220:09B0
  creates items 500 + i.
* C.5.4's table (C line 396) cites "B 4.3, 11.2" for `pdos_menubox_*`; the model is B 4.4.
* C.10.1 (C lines 733..735) still says B's `pdos_srand` takes `uint32_t`; B 9.3 Revision 2 takes
  `uint16_t` (C.20.1 says so itself).
* *Resolution.* Correct at the merge.

**RV2-14 (minor). K2's list of w16 changes omits area E's host.h additions.**
* *Drafts.* A 17's K2 table ("the full list below goes into DESIGN.md 12.5") and K5 ("host.h changes:
  `HostEvent.frame` and `host_set_cursor_pixels`"). E.2.1/E.3.1 add `host_dos_read`, `host_dos_where`
  and an enum to `platform/w16/host.h`, with back-end functions in both hosts.
* *Resolution.* Add E's row (phase D2, guard E.13.3 and G-1) to the K2 list and K5.

### Notes

**RV2-15 (note). ScaleLogical's 16-bit result.** B 8.2/8.3 compute `(int)((long)v * 160 / 100)`.
The core returns AX (showfunc 11E8:0D81: `idiv ebx`, then `retf`), a 16-bit value. The two agree
for |v| ≤ 20,479; casting to `int16_t` makes B's preimage matching exact for every argument. A may
drop the exit probe (X9) with no behaviour change.

**RV2-16 (note). R:0182:00B3 leaves the port opaque.** It writes port word +0Ah = 0 for the draw and
then 1 (R:0182:00C8..00E8), whatever the style was. B 8.2 models the transparent draw; if B keeps a
DOS port's style across calls (11, D7 scenes), it should also set style 1 afterwards.

**RV2-17 (note). Two names for the segment at DGROUP:640A.** B 10.1 reads its first 16 bytes as the
leader-font table (`LEADER_FONT`); E.10.3 calls `[DGROUP:640A]` "the throne-room table" waiting for
its length (FORMATS 6.1, L1). The file holds 00 00 01 02 01 02 00 01 00 02 00 02 01 00 02 01 at
R:26FA:0000..000F (values 0..2: fonts 8, 9, 3), which fits B's reading; other data follows at 0010.
E's D7 row `LEADER_FONT` (16 bytes, range 0..2) and a FORMATS 6.1 correction should record both uses.

**RV2-18 (note). B11's instance ordinal must not depend on visibility.** 7.4 compares every
registered profile's frames across switch histories. B11 seeds by "the number of times that effect
started" in the run, which is history-independent only if every effect start comes from events,
probes or `advance`, never from `frame()`, `peek()` or a switch. State that rule next to B11 and test
it (a `test_pdos_*` case that calls `frame()` repeatedly and checks the ordinal).

## Verdict

Areas B and C are a sound and well-evidenced design. The DOS facts they rely on hold against the
listing, the D0 documents and the DOS files (34 claims checked; the clock model, the intro and Birth
programs, the generator, the fade and cycling arithmetic, the menu-box row query, the G#10 and G#21
semantics and the leader-font rule all agree), the Windows facts hold against showfunc and the port's
sources, and I found no path by which B or C can break P0.

D1 should not close on the drafts as written. One blocker must be fixed first: A 4.3 must give exit
probes to the nine functions whose brackets or exit-time drawing B and D depend on (RV2-1), with a
check that keeps the probe phases and the macro tables in step. Before D4 (setup) the two missing
call-site rows of RV2-2 must be added; before M the frame stamping of ring presses must be fixed
(RV2-3). The minor findings are naming, declaration and citation alignments that the merge can apply
(RV2-4..RV2-14); the notes need no design change. The other interfaces between the five areas match
in name, signature, meaning and call order.

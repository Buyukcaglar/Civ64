<!--
  D1 independent design review, part RV1 (areas A, D and E with ext-d1-decisions.md).
  Reviewer: RV1 (an agent that wrote none of the drafts), 2026-10-11.
  Scope: ext-d1-draft-A.md (observer, probes, query API, tick, profiles and switching, input
  stages, chords, command line, harness, tests), ext-d1-draft-D.md (map zoom, map layer, map
  renderer, DOS map rules), ext-d1-draft-E.md (DOS asset store, host service, decoders, offset
  registry), and the orchestrator's resolutions K1..K9, C1..C7, E.18-1..5.
  Brief: BRIEF-d1-review.md. Drafts B and C did not exist in docs/verify at review time.
-->

# D1 design review RV1: areas A, D and E

## How I worked

* Read BRIEF-d1-review.md, BRIEF-d1.md, the extension prompt
  `claude/docs/x64-port-scaling-dos-prompt.md` (all; rules quoted from sections 4, 5.2..5.11, 7, 8,
  9), the base prompt `claude/docs/x64-port-prompt.md` sections 1, 5, 7, 9, DESIGN.md 3.4, 5, 6, 9,
  12.1..12.4, STATUS.md "Extension track" and "User directions", the three drafts in full and the
  decisions file.
* Checked every code fact I could find in the drafts against the port's sources (line by line):
  `platform/w16` (vm.c/.h, host_sync.c, queue.c, clock.c, dos.c, gdi_pal.c, gdi_dc.c, user_cursor.c,
  user_wnd.c, user_syscmd.c, host.h), `present/` (present.c, scale.c/.h), `platform/win32/host_win32.c`,
  `win64/civ64_main.c`, `civ64_game.c`, `civ64_locate.c/.h`, `res/zip.h`, `tests/headless/`
  (harness.c, harness_main.c, host_headless.c), `build.cmd`, `test.cmd`, `core/gen/civ_frames.c`,
  `core/gen/civ_layout.h`, TRACE.md.
* Wrote one read-only script, `build/d1/scratch-rv1/probes.py` (output `probes.txt`), which parses the
  854 FrameDescs of `core/gen/civ_frames.c` and every `fr_enter(&FR_x` use in `core/` and `rt/`, and
  classifies every `SSSS:OOOO` in the probe, call-site, audit, trigger and macro sections of drafts A
  and D (function start entered through `fr_enter`, or an address inside a function). A second file,
  `basenames.txt`, lists the portable C base names for the build's object-name rule.
* DOS facts only from `docs/dos/*.md` (EXECUTABLE, FORMATS, SCENES-PLAY, SPRITES, dos-hashes.txt) and
  the D0 review; no DOS program run. Windows facts from the port's sources and docs only. No excluded
  main-project path was read.
* Then tried to break P0 along the brief's list (checkpoint, virtual screen, base trace, emulated
  clock, `vm_steps`, `vm_site`, handle numbers, checked diagnostics, `g_randSeed`, queue, key state),
  and checked each interface one area uses against the area that owns it.
* Procedural note: several of my read-only shell commands chained a `cd` before `grep`/`cat`/`ls`,
  against the instruction; nothing was written or changed by them. No builds, tests, harness runs or
  git.

## Claims checked against code and documents

| # | Draft, section | Claim | Evidence | Result |
|---|---|---|---|---|
| 1 | A 4.2 | Entry hook after the frame is built, after `cover` and `g_prolog_fn = 0` | vm.c `fr_enter` 701..773: `g_prolog_fn = 0` at 770, return at 772 | true |
| 2 | A 4.2 | Exit hook first in `fr_leave`, before `vm_site` restore and pops; AX already written | vm.c `fr_leave` 775..847; translated code sets AX before `fr_leave` | true |
| 3 | A 4.2 | `ra` gives call-site precision | vm.c `fr_enter`: `g_ctl_stack[].ra = far_ret ? ra : ra & 0xFFFF` (near: offset only); VM_SITE_STACK 4096 (vm.c:16) | true, with RV1-19 |
| 4 | A 1, 6.1 | Release `VM_SITE` is an inline store and increment; Checked calls `vm_step` (vm.c:215) | vm.h:105..115 | true |
| 5 | A 5 | `w16q_rd*` repeats `vm_resolve`'s checks (vm.c:517) | vm.c:517 | true |
| 6 | A 1 | In P0 runs `w16_host_sync` returns at once (host_sync.c:181); scripted input is posted directly (harness.c:868..889) | host_sync.c 176..188; harness.c `step` 868: `w16_queue_post_key`/`_input` at `VM_STEP_API` | true |
| 7 | A 10.1 | Filter replaces host_sync.c 184..188; `post_event` at 113 | host_sync.c | true |
| 8 | A 1 | gdi_pal.c statics are `static`; tick never reaches them; `host_present` unconditional in `present_core` | gdi_pal.c 63..67; present.c 97..129 (`host_present` at 128) | true |
| 9 | A 1 | Core frame lines change only in `host_present` (host_headless.c:294) | host_headless.c:294 | true |
| 10 | A 7.1 | Tick sites: queue.c 445, clock.c 193, dos.c 358, user_cursor.c 149; w16's modal loops pump through `w16_PeekMessage` | queue.c 441..445; clock.c 189..197; dos.c 358; user_cursor.c 149; `w16_PeekMessage` in user_menutrack.c:1065, user_msgbox.c:510, user_scrolltrack.c:154, user_syscmd.c:219/357; no other `w16_host_sync` callers except GetKeyboardState/GetCursorPos polls (queue.c 601, 642) | true |
| 11 | A 3.3 | Forced presents after RealizePalette/AnimatePalette at gdi_pal.c 271, 310 | gdi_pal.c | true |
| 12 | A 3.3 | `OBS_PAL_ANIMATE` "at the trace (285)" with A 3.1 "after the change" | gdi_pal.c: trace 285, entries written 286..307 | inconsistent (RV1-9) |
| 13 | A 3.3 | `OBS_CURSOR` in `w16_SetCursor` before `host_set_cursor` | user_cursor.c 145..158 | true; see RV1-7 |
| 14 | A 3.3 | Draw/text/control/menu/focus emission lines (gdi_draw.c 214/225, `set_focus_raw` 1683, `w16_target_done` gdi_dc.c 414, ...) | sampled in gdi_draw.c, gdi_dc.c, user_wnd.c, user_ctl.c, user_menutrack.c | true for all sampled |
| 15 | A 4.3 | Probe functions | probes.txt: 76 of 79 addresses are live functions entered through `fr_enter`; 1138:01BD/03C7 are `ra` values (as the draft says); 10B0:14F4 is not | RV1-10 |
| 16 | A 4.3 | Call-site rows `(callee, ra)` | 38 addresses, all inside the named callers, `ra` = call + 5 | true |
| 17 | A 4.3 | RandomBelow exit probe by far `ra` | FR_RandomBelow 11C8:003D, FR_WIN_FAR, far_ret 1 (civ_frames.c:746) | true |
| 18 | A 10.2 | PumpMessagesCheckSkipInput 11E0:095F takes any WM_KEYDOWN as skip (11E0:0973) | showfunc 11E0:095F | true (K3 is well founded) |
| 19 | A 10.2 | "MenuZ window procedure 1220:13AA" | 1220:13AA lies inside MenuZSubclassWndProc 1220:1289 | RV1-19 |
| 20 | A 5, 6.2 | `g_randSeed` 1420:4EE0..4EE3 | civ_layout.h:4557..4558 (4 bytes); rt_num.c 113..124 | true |
| 21 | A 4.1 | `obs_init()` in civ64_start.c before `rt_WinStartupEntry` | `rt_WinStartupEntry` is called in civ64_game.c:14 (`civ64_run_game`), called from civ64_main.c:261 | false (RV1-11) |
| 22 | A 10.1 | host_win32.c `key_down` 599, `mouse` 729, `release_keys` 656; `add_menu` 1758; `hw_update_menu` 1736 | host_win32.c | true |
| 23 | A 10.2 | Mouse press flushes held modifiers (as S2's `flush_alt`) | host_win32.c 750..763: press calls `flush_alt`; moves copy MK_SHIFT/MK_CONTROL from the host into `e.buttons` | partly (RV1-15) |
| 24 | A 1, K1 | `present_game_screen(_follow)` independent of profile and zoom | present.c 171..214: only `CORE_W`/`CORE_H`, the client and the policy | true; omitted from A's P0 argument (RV1-12) |
| 25 | A 8.2 | `present_view_point` maps into the visible profile's frame | present.c 146..156 and `present_shown_frame` 165..168 use `shown()` (S1's `g_win`) only | design change not described (RV1-12) |
| 26 | A 11 | System-menu ids 0x1090/0x10A0/0x10B0 free | host_win32.c `add_menu` 1758 | true |
| 27 | A 13.1 | V1/V2/7.4 runs with `--graphics dos` without `--dos-data` | E.4.3 (harness exits 2 for an explicit `--graphics dos` without assets); E.3.4 (no default source); harness_main.c has no DOS option today | RV1-5 |
| 28 | A 9 | CIV_OBSERVER=0 removes `present/input.c` but keeps the S2 arrival rules | A 2 puts `pi_arrive_*` in `present/input.c`; host_win32.c calls them; build.cmd links civ64.exe in every variant (163) | RV1-13 |
| 29 | D 3, 12.1, 17 A-4 | New `present_map_point(int32_t, int32_t, PresentMapPt *)` | scale.h:96 and scale.c:424 already define `int present_map_point(const PresentLayout *, int32_t, int32_t, int32_t *, int32_t *)`, used by present.c:155 and test_present.c:134 | false premise (RV1-2) |
| 30 | D 3 | `present/map/*.c` modules incl. `input.c` | build.cmd 68 compiles `present\*.c` only; objects named by base name (`%%~nf.obj`, 71/77/89); A has `present/input.c` | RV1-3 |
| 31 | D 17 A-3 | `w16q_wnd_client_vis` over `w16_wnd_client_vis` (user_wnd.c 754) | user_wnd.c 754..763: computes into the caller's region, no allocation | true |
| 32 | D 17 A-3 | `w16q_sys_track`: "a static kept by user_syscmd.c" | user_syscmd.c `outline` 94 XORs the screen; the rectangle is the loop-local `cur` of `movesize` (160, 208..291); no static exists | new w16 state (RV1-4) |
| 33 | D 1, 7.3 | `g_randomSeed` 13C0:0000, `g_revealAll` 12D8:4302, `g_mapDrawMode` 1330:400C, `g_mapViewRows` 1408:00C8, `g_mapViewerCivMask` 1408:00CC | civ_layout.h 2862, 3159, 3442, 3543, 3549 | true |
| 34 | D 17 A-7 | Added probes TileCacheLookup, DrawUnit, UpdateUnitSightAndContacts, DeleteUnit, ProcessGameTurn, BlinkActiveUnitUntilInput, AnimateUnitMove, ResolveCombat, RedrawMapRect, DrawTile | probes.txt: all live `fr_enter` functions | true |
| 35 | D 14.2 | Layer table (m9 formula, coast masks, page-2 coasts and land base, river +16 rule, grassland formula, D4CE indices) | SCENES-PLAY.md 2.1 rows 1..13; SPRITES.md 6.3 | true |
| 36 | D 14, 17 (Area E) | D4CE, D294, D2D4, 6DFE, B886, B880, B27A, B29A, 7EEC, 6E96 come "through the offset registry"; "none is copied into source" | FORMATS.md 6 (468..470): every DGROUP address at 6B30h or above is run-time storage; SPRITES.md 1 "Data or code": run-time shape handles cut by O5:1455 from immediates; E.5.4 and E.10.2 reject such addresses | false (RV1-1) |
| 37 | D 14.2 row 4' | Other land: `T[T][mask]` for every terrain | SPRITES.md 4: t 6..9 cut only at m = 0 (all masks share it); all rows when DGROUP:1A3E is set | incomplete (RV1-16) |
| 38 | D 4.3 | WdwMapProc minimum track size 450x350 gives at least 7x5 squares at +1 | showfunc 1208:0054: min track = `data->trackLimits` (450x350) + SM_CXFRAME/SM_CYFRAME, a window size | limits true; square count high (RV1-20) |
| 39 | E.2.2 | build.cmd generator loop 42..49, portable loop 68, base-name objects 71, C99 parse 83, Win32 loop 148 | build.cmd | true |
| 40 | E.2.2 | test.cmd gamedata precheck 20; generic test loop 40 passes `"%B%\gamedata" "%T%"` | test.cmd 20..23, 40..45 | true |
| 41 | E.3.4 | `--host-size` at harness_main.c 432; `vm_init` at harness.c 1061 | harness_main.c 432; harness.c 1061 | true |
| 42 | E.3.2 | headless `host_dir_list` 264..271 | host_headless.c 264..271 (stub returning 0) | true |
| 43 | E.3.3 | civ64_main.c: `civ64_locate` 194, checks 199..207, `fail` 59..63, `vm_init` 240 | civ64_main.c 190..216 and earlier reads | true |
| 44 | E.3.3 | Core cannot see a subfolder: `resolve` depth 2 (dos.c 173..186); `host_dir_list` top-level regular files (host_win32.c 462) | dos.c; host_win32.c 461..466 skips directories | true |
| 45 | E.2.1 | `find_name` 134..158 and `find_exe` 303..320 in civ64_locate.c; `CIV64_DOS_EXE_SHA256` civ64_locate.h 45..47 | civ64_locate.c/.h | true |
| 46 | E.3.2 | `zip_open`, `zip_find`, `zip_extract`, `zip_crc32`; archive borrows the bytes | res/zip.h | true; `zip_find_base` is new |
| 47 | E.4.1 | 106 PIC, 38 PAL, 11 texts, CIV.EXE, MGRAPHIC.EXE, FONTS.CV = 158 required | dos-hashes.txt: 176 lines, 106 .PIC, 38 .PAL, 13 .TXT (minus INTRO, INTRO3) | true |
| 48 | E.4.1, E.5 | Load module 10,128..213,711 (203,584 bytes); 2,525 relocations (10,100 bytes); 437 EXEPACK commands | EXECUTABLE.md 57..61 | true |
| 49 | E.5.4 | DGROUP initialised extent 6B30h (27,440 bytes); 23 overlays, the first at 178,176 | FORMATS.md 468; EXECUTABLE.md 149, 197 | true |
| 50 | E.4.2 | Activation before `vm_init` cannot disturb P0 | host_headless.c `host_alloc` 53: plain zeroed allocation, no counters; activation logs only to `dos-assets.log` | true |

## Rule coverage (areas A, D, E)

"Met with deviation" means a deviation recorded in the drafts or the decisions file.

| Rule | Where | Status | Notes |
|---|---|---|---|
| O1 Events | A 3, 9 | met | `CIV_OBSERVER`, Checked-independent `present/`; RV1-9 (one emission point) |
| O2 Probes | A 4 | met | function-start keys, `(callee, ra)` for call sites (K6); RV1-10 |
| O3 Reading | A 5 | met | D's additions not yet in A (RV1-4) |
| O4 Forbidden | A 6, D 1, E.2.2/E.13.4 | met | Checked guard, sentinel, lint; E includes no w16 internals |
| O5 Records | A 4.1, 6.2, 6.3 | met | three-list lint; RV1-10 would fail it |
| O6 Concurrency | A 8 | met | for D3; mid-run Locate breaks the "always current" premise (RV1-6) |
| O7 Tick | A 7 | met | four sites cover every pump and clock query (claim 10) |
| T1 | A 4.3 (probes for intro creation and `SeekSequence(…,1000)`) | met (infrastructure) | timelines are area C |
| T2 | A 7.2, 8.2 | met | every profile advances at every tick |
| T3 | A 1, 10 | met | no input except from host events |
| T4, T5 | area C | not in A/D/E | A supplies the skip probes |
| T6 | A 7.2, E.4.2 | met | free clock; no decode inside ticks (E) |
| T7 | D 14.6, 14.7 | met | map effects at the core's pace |
| I1 | A 10.1 | met | |
| I2 | A 10.1 | met | identity in Windows at default zoom, tested by `test_input.c` |
| I3..I6 | area C | not in A/D/E | D 12 covers the map's I-rules |
| I7 | A 10.2 | met with deviation | K3 (Ctrl/Shift hold); RV1-15 |
| I8 | A 10.1, D 12.3 | met | |
| 5.3 | A 8, D 5.3 | met with gaps | D's layer needs A-1/A-2 in A (RV1-4) |
| 5.4 | D 14 (map class A) | met for the map | other rows B/C |
| 5.7 | A 8.2 | met | profile-aware view mapping not described (RV1-12) |
| 5.8 | D 4..13 | met with deviation | C1 (levels -1/0/+1, odd k), C2, C6; RV1-2, RV1-3 |
| 5.9 | E | met with deviation | E.18-1..5 (R supersedes `--dos-data` for civ64); the D map shapes conflict with its table rule (RV1-1) |
| 5.10 | E.7 (FONTS.CV model) | met for E's part | rest is area B |
| 5.11 | A 11, D 13 | met with deviation | K7 remembered profile; C1 `--zoom`; RV1-8 |
| 7.1, 7.2 | A 10.1 | met | S2 tests kept |
| 7.3 | A 13.1, D 16.4 | not met as written | the DOS variation never runs DOS (RV1-5) |
| 7.4 | A 13.2 | not met as written | same (RV1-5) |
| 7.5 | D 16.2 | met with deviation | C2 |
| 7.6 | E.13 | met with deviation | Asan deferred (K8, E.18-3) |
| 7.7 | area C | not in A/D/E | |
| 7.8 | A 12.4, D 16.5 | met | |
| 7.9, 7.10 | later phases | not in A/D/E | |
| 8 | A 6, 7; D 14.6; E.5 | met | observer discipline, RNG-driven drawing, EXEPACK; colour spaces partly B |
| D-1 | E | met with deviation | Asan deferred |
| D-2 | A 8, 13 | met in design, tests defective | RV1-5, RV1-6 |
| D-3 | A 8.2, E.9 | not met as designed for the pointer | RV1-7; other D-3 items are B/C |
| D-4 | area B/C | not in A/D/E | |
| D-5 | D 14 | blocked for the map | RV1-1, RV1-16; small map/status are B (C7) |
| D-6, D-7 | D8 | not in A/D/E | |
| Z-1 | D 4 | met with deviation | C1 |
| Z-2 | D 6, 10 | met with deviation | C2, C3 |
| Z-3 | D 1, 12 | met | |
| G-1 | A 9, 13.3 | met with deviation | Asan deferred (K8) |

## Findings

Counts: **1 blocker, 6 major, 9 minor, 4 notes.**

### Blocker

**RV1-1. D 14 and D 17 "Area E": the DOS map shapes are run-time handles, not registry tables, and
no area cuts them.**
* Claim: "All shapes and tables come from area E's DOS asset service (offset registry); none is copied
  into source" (D 14, line 712), and E is asked for "the tables D4CE, D294, D2D4, 6DFE, B886, B880,
  B27A, B29A, 7EEC, 6E96, 1946, 1956 ... through the offset registry" (D 17).
* Found: all of these except 1946/1956 lie at or above DGROUP:6B30h, the end of DGROUP's initialised
  data. FORMATS.md 6 ("Where image data can be", 468..470) calls them storage the program fills at run
  time; SPRITES.md 1 ("Data or code") says they are shape handles that O5:1455 cuts at start-up from
  rectangles that are immediates in its loops, with recolouring (eight unit copies, 6.4), the
  TER257 row rule (4) and copies such as D4DC from 6E92 (6.3). E.5.4 and E.10.2 refuse any DGROUP
  address at or above 6B30h with `PDOS_E_REGISTRY`, which would make the DOS profile unavailable.
  E offers pictures, palettes, fonts, texts, registered tables and the eight pointer shapes (E.9),
  but no map or icon shapes. A, D and E give no owner to the O5:1455 cut step. The interface D builds
  on cannot work, and D6 (and D4/D5 uses of D4CE icons) has no source for its art.
* Resolution: give one area (E, extending E.9, or B) a shape-cut module that reproduces O5:1455 from
  the decoded pictures, with the rectangles as user-D6 immediates citing their O5 addresses, and the
  recolour and copy rules; D then asks for shapes by family and index, and only 1946/1956 (and other
  tables below 6B30h) go through OFFSETS.md.

### Major

**RV1-2. D 3, 12.1, 17 A-4: `present_map_point` already exists with another signature.**
* Claim: D declares `int present_map_point(int32_t hx, int32_t hy, PresentMapPt *out)` in
  `present/map/map.h`, and A's `pi_arrive_mouse` is to call it.
* Found: `present/scale.h:96` and `scale.c:424` define `int present_map_point(const PresentLayout *L,
  int32_t hx, int32_t hy, int32_t *lx, int32_t *ly)`, used by present.c:155 and
  tests/test_present.c:134. As written D's module does not compile against present/.
* Resolution: rename D's function (for example `present_layer_point`) in D 3, 12.1 and the A-4 request.

**RV1-3. D 3: the map modules are outside the build and collide with A's file names.**
* Claim: D adds `present/map/{map.h, zoom.c, layer.c, inview.c, snap.c, state.c, win_rules.c,
  dos_rules.c, world.c, model.c, check.c, input.c}`.
* Found: build.cmd compiles only `present\*.c` in the portable loop (68) and names objects by base name
  (`%%~nf.obj`, 71, 77, 89). D does not extend the loop (E does, for `present\dos`). `present/map/input.c`
  has the same base name as A's `present/input.c` (A 2), so one object overwrites the other and the
  response file lists `input.obj` twice; the link fails under `/WX` or loses A's input stage. E's
  naming Choice (E.2.1: unique base names, a module prefix) asked areas B, C and D to follow it.
* Resolution: add `present\map\*.c` to build.cmd 68 (and the clang-tidy include list if needed) and give
  the map files a prefix (`pmap_*.c`), as E did with `pdos_`.

**RV1-4. D 17 vs A and the decisions file: D's change requests are not adopted, and two need w16
changes that K2 does not list.**
* Claim: D 17 asks A for A-1 (tick step 4 returns only when `present_map_pending()` is 0), A-2
  (`present_map_overlay` in `present_core` and VIEW redraws), A-3 (queries `w16q_wnd_client_vis`,
  `w16q_sys_track`, `w16q_draw_on`), A-4, A-5 (`HostEvent.frame` 3 "passed as 0" and a new value 4),
  A-6..A-8; B-1..B-4; E's shapes.
* Found: A's sections 5, 7.2, 8.3 and 10.1 have none of them; A 10.1 defines frame 3 as "the map layer"
  and has no 4. ext-d1-decisions.md resolves C1..C7 but not section 17. `w16q_sys_track` needs new
  w16 state: user_syscmd.c keeps the outline rectangle only as `movesize`'s loop-local `cur` (160,
  208..291; `outline` 94 XORs the screen). `w16q_draw_on` needs the gdi_draw.c and gdi_font.c
  rasterisers to work on a caller surface, a refactor of the code that draws the virtual screen.
  Neither is in A 2's file table or K2's list of w16 changes (DESIGN.md 12.5); both touch G-1.
* Resolution: the orchestrator records A-1..A-8 (and B-1..B-4, E) as accepted or rejected; A adds the
  accepted ones to sections 2, 5, 7.2, 8.3, 10.1, and K2's list gains the user_syscmd.c state and the
  rasteriser refactor with G-1 as their guard.

**RV1-5. A 13.1 and 13.2: the DOS variations run without DOS files.**
* Claim: V1 `--graphics dos`, V2 `--switch-every 997` and 7.4's runs A, A', B use no `--dos-data`;
  A's authority table (line 20) says "The DOS profile needs no `--dos-data`; phase R locates it".
* Found: the harness has no phase R (harness_main.c knows `--gamedata`, `--host-size`, `--game-screen`;
  no DOS source). E.3.4 adds `--dos-data` with no default, and E.4.3 makes the harness exit 2 with
  `HARNESS_ERROR` for an explicit `--graphics dos` without assets; the runner compares exit status
  (A 13.1), so V1 fails every row. V2's switches are refused without failing the run, so V2 would
  "pass" without ever making DOS visible. Since D2 (E) lands before D3, A 8.4's "test stub" does not
  apply. 7.3 and D-2 ("P0 holds across all scenarios with arbitrary switching") are not tested.
* Resolution: every DOS variation passes `--dos-data build\dosdata`; the runner asserts in
  `profiles.log` that switches happened and none was refused; A line 20 is limited to civ64.

**RV1-6. A 10.2 and 11 vs E.4.2: "Locate DOS files..." during a run has no design.**
* Claim: the refusal message and the system menu offer "&Locate DOS files..." (`SC_CIV_DOS_LOCATE
  0x10B0`, from X0 review B3); the DOS item "stays enabled".
* Found: E.4.2 activates the store only before the emulation ("From here no function of the store
  allocates, frees, reads a file"), accessors return pointers into the immutable image (E.10.2), and
  `pdos_assets_open` "closes a previous store first", which would invalidate renderer pointers. A
  profile that becomes available mid-run has not been built from the run's events (O6, T2: "a hidden
  profile stays current"); A does not say whether an unavailable profile's renderers consume events.
  Neither A nor E defines what Locate does mid-run.
* Resolution: either Locate only records the choice in civ64.cfg (phase R's browse) and the message
  says it takes effect at the next start, or E defines a mid-run activation that never replaces a
  valid store and A requires the DOS profile's state to be asset-independent until activation.

**RV1-7. A 8.2 vs E.9 and host.h: the DOS pointer has no working path (D-3, phase D4).**
* Claim: "D4 adds the DOS pointer through the same path" (`w16q_cursor` → `host_set_cursor`).
* Found: `host_set_cursor(const uint8_t *res, uint32_t len, uint16_t idc)` (host.h:100) takes RT_CURSOR
  resource bytes or a system IDC; E.9 delivers `PdosShape` pixel arrays in DOS palette indices.
  `w16_SetCursor` calls `host_set_cursor` itself at every cursor change (user_cursor.c 152..158), on
  the core's thread, so in the DOS profile every core cursor change would put the Windows cursor back.
  The draft also has the back end "re-issue the cursor" at a switch without naming the function.
* Resolution: A designs the route now: w16 hands the cursor to `present/` (an event plus a present
  call) and the visible profile decides what the host shows, through a host.h entry that takes
  XRGB/alpha pixels and a hot spot; K2/K5 list the host.h and user_cursor.c changes.

### Minor

**RV1-8. A 10.2 vs E.4.3: two different refusal rules and a doubled sentence.** A: the first refusal
in a run shows one message, later ones beep. E.4.3: the message is shown "once per chord press". A's
text "DOS graphics are not available: <reason>." wraps E's full sentence ("Civilization for DOS was
not found: the DOS graphics profile needs ...") into a doubled sentence. Resolution: keep A's cadence
(5.9 says "one port-level message"), correct E.4.3, and show E's message alone plus the Locate hint.

**RV1-9. A 3.3: `OBS_PAL_ANIMATE` is emitted before the change.** The table puts it "at the trace
(285)"; gdi_pal.c writes the entries and `g_sys` at 286..307, so a handler that queries the palette
sees the old values, contrary to A 3.1 ("after the change", line 128). Resolution: emit after the
loop, before `if (moved)`, with the `moved` flag.

**RV1-10. A 4.3: ResyncMovieClock 10B0:14F4 is not a ported function.** It has no FrameDesc (probes.txt:
inside AdvanceMovie's range), and TRACE.md 615 lists it "dead, not ported". `obs_lint.py`'s
three-list agreement (A 6.2) would fail on it. Resolution: drop it from the probe list.

**RV1-11. A 4.1: wrong installation site for `obs_init()`.** civ64_start.c does not call
`rt_WinStartupEntry`; civ64_game.c:14 does, from `civ64_run_game`, which civ64_main.c:261 calls.
Resolution: install in civ64_main.c before `civ64_run_game` (261), after E's activation step.

**RV1-12. A 1 and 8.2: the P0 argument and the view functions miss two existing paths.** (a) Step 2
says the filter's output is the only presentation output the core uses, but `host_game_screen` →
`present_game_screen(_follow)` (host_headless.c 335/350, host_win32.c 1014/1020) returns the virtual
screen's size under `--game-screen view` (K1). Today it reads only `CORE_W`/`CORE_H`, the client and
the policy (present.c 171..214); the argument should name it and require that it stays
profile-independent. (b) `present_view_point`, `present_view_layout` and `present_shown_frame`
(present.c 146..168) use `shown()`, S1's single frame; A must say how they become profile-aware while
the harness's relation check (harness.c 948) keeps reading the Windows frame. Resolution: add both to
A 1 and 8.2.

**RV1-13. A 9 vs A 2: CIV_OBSERVER=0 removes the file that holds the arrival stage.** A 9 removes
`present/input.c` but keeps "the S2 Win32 arrival rules", which A 2 places in `input.c`
(`pi_arrive_*`); host_win32.c calls them, and build.cmd links civ64.exe in every variant (163).
Resolution: put the arrival stage in its own file (always compiled) or keep `input.c` and remove only
the filter under `#if CIV_OBSERVER`.

**RV1-14. A 6.1: the guard depth after a fault.** A forbid check or sentinel faults with
`VM_FAULT_INTERNAL` while `w16_obs_depth != 0`; `vm_fault` (vm.c 226..232) reaches `host_fault`,
which leaves by `longjmp(*hh_fault_jmp)` when a test catches faults (host_headless.c 79..81), so the
depth stays set. In a process that runs several cases (`test_observer.c`, A 13.4) later cases fault
spuriously. Resolution: reset the depth in `obs_init`/`hh_run` and in the test fixture after each
expected fault.

**RV1-15. A 10.2: held modifiers and mouse moves.** Presses flush held keys, but host_win32.c:763
copies MK_SHIFT/MK_CONTROL from the host's wParam into every move's `buttons`, so while a Ctrl or
Shift press is held back the core receives moves that claim the modifier is down before its key-down.
Resolution: the arrival stage masks MK_SHIFT/MK_CONTROL of held (undelivered) keys in moves, recorded
with the K3 FIDELITY entry.

**RV1-16. D 14.2 row 4': the TER257 row rule is missing.** SPRITES.md 4: Tundra, Arctic, Swamp and
Jungle (t 6..9) are cut only at m = 0 and every mask uses that shape; with DGROUP:1A3E set, all rows
are. D indexes `T[T][mask]` for all land terrains, so the DOS view would show neighbour variants the
DOS program never shows. Resolution: state the rule in D 14.2 (and take 1A3E as 0, recorded) or let
the RV1-1 shape-cut module own it.

### Notes

**RV1-17. Drafts B and C were absent.** The interfaces A/D/E use from them (B-1 shadow-engine macro
handlers, B-2 A-canvas size, B-3 `present_host_rect_inner`/`present_axis_taps`, B-4 DOS label font
and palette state, area C's adapters inside A's filter stage, P1 timeline rate, I4/I5) could not be
checked here; RV2 owns them.

**RV1-18. A 2: `present/dos/profile_dos.c` does not follow E's `pdos_` naming Choice.** Not a
collision today; rename for consistency at merge.

**RV1-19. A 4.2 and 10.2: call-site and audit addresses.** Near callees' `ra` are stored as offsets
only (vm.c `fr_enter`), so `OBS_CALLSITES` rows for near callees must compare offsets. "MenuZ window
procedure 1220:13AA" is an address inside MenuZSubclassWndProc 1220:1289; cite the function.

**RV1-20. D 4.3: 450x350 limits the window, not the client.** WdwMapProc's WM_GETMINMAXINFO sets
the minimum track size to 450x350 plus one frame width (showfunc 1208:0054), a window size. The
client is smaller by the frame, caption and scroll bars, so at +1 the smallest layer holds about 6x4
whole squares, not 7x5. The +1 rule (at least 3x3 squares) still holds.

## Verdict

* **Area E** is sound: its code and DOS facts checked out (claims 39..50), P0 holds by activation
  before `vm_init`, and its deviations are recorded (E.18). It needs RV1-1 (a shape owner, or a clear
  "not E"), RV1-6 and RV1-8.
* **Area A** has a sound P0 argument. I found no path by which the observer, probes, query API, tick or
  filter changes a checkpoint, the virtual screen, the base trace, the clock, `vm_steps`, `vm_site`,
  handles, checked diagnostics, `g_randSeed`, the queue or the key state in P0 runs (claims 1..11, 20,
  24). Its D3 gate cannot pass as written (RV1-5); RV1-6, RV1-7 and RV1-12 need design text; the rest
  are local corrections.
* **Area D** is detailed, and its P0 reasoning holds. It cannot be built as written: the DOS map art
  rests on a false DOS fact (RV1-1, blocker for D6), and the Windows-profile part (phase M) needs RV1-2,
  RV1-3 and the adoption of its section-17 requests (RV1-4).
* D2 can start once RV1-6 and RV1-8 are settled. D3 needs RV1-5 and RV1-12. M needs RV1-2..RV1-4. D4
  needs RV1-7. D6 needs RV1-1 and RV1-16.

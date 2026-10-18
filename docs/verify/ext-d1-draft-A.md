# D1 draft A: observer, probes, read-only queries, presentation tick, profile switching, P0 tests

Draft of 2026-10-11 by design agent D1-A, for merging into `DESIGN.md` 12.5 onwards. Scope: extension
5.1 (layers, `host.h`), 5.2 O1..O7, 5.6 I2 and I7, 5.11 (`--graphics`, the system-menu profile item, the
settings key), 7.3, 7.4, 7.8, G-1. Phase D3 implements it.

Line numbers are those of the port's sources on 2026-10-11. Function names and addresses come from
`claude/src` and `showfunc.py`. The scratch checks of probe addresses are in `build/d1/scratch-A/`:
* `probe_sites.py`, output `probe_sites.txt`;
* `check_b_probes.py`, output `check_b_probes.txt` (area B's probes);
* `count_probes.py`, output `count_probes.txt` (the combined list).

## Revision 3 (after RV2)

This revision applies [ext-d1-review-rv2.md](ext-d1-review-rv2.md) as
[ext-d1-decisions.md](ext-d1-decisions.md) "Design review RV2" resolves it, and the merge item C-11.
Each point was checked against the evidence RV2 cites (WINDOWS-INVENTORY.md 10.6, 10.7; `showfunc.py`
11E0:0000 and 11E0:0221).

* **RV2-1 (blocker).** 4.3 gives **E and X** to DrawMapTile 1110:04D0, DrawUnitAt 1110:0FF6,
  DrawCityLabels 1208:1F64, WdwMapOpen 1208:0AF1, RedrawSmMap 1210:073F, DrawSmTiles 1210:09B4,
  RedrawStatusWindow 1218:0801, DrawStatusCivPanels 1088:13D5 and DrawUnitInfoPanel 11F0:468C. WI 10.6
  and 10.7 list them entry only. No key is added (203). 6.2's lint gains the "exit phases" rule over
  `PdosMacro` keys, exit-0 `PdosSceneRow`s and `OBS_AT_EXIT` markers; `observe.h` gains the marker
  and `obs_probe_phases(addr)` (4.2), with which B's `pdos_shadow_macros` refuses and counts a macro
  whose key lacks the exit (B 7.3).
* **RV2-2 (major).** 4.3's table of area C's rows gains CustomizeWorldDialog 1108:0243 `ra` 11E0:0826
  and RunNewGameSetup 10E8:0000 `ra` 11E0:020A. Open A1's generator input names them.
* **RV2-3 (major).** 10.1 gains the press latch: a button press fixes its action's class (ring, layer
  view, or neither) until the release. Moves while a ring press is held and its release are frame 4
  wherever they happen; the parts of a view press stay frame 3 at the clamped point. The frame table
  says so, and `test_input.c` gains the crossings and the pole edge (13.4).
* **RV2-4.** `int obs_callsite(uint32_t callee, uint32_t ra)` (4.2): B and C resolve their rows at
  reset; an unresolved pair is a Checked fault and a lint failure (6.2).
* **RV2-5 and C-11.** `present_input_filter` sends a part of an action C decided to
  `pdos_adapt_filter` when `pdos_adapt_note` returns 1 (10.1 code block); `test_input.c` gains the
  case of the frame-0 release of a press consumed on frame 1 (13.4).
* **RV2-10.** 8.5 cites E.9.2's `pdos_shape(PDOS_SH_ICON, ...)` instead of the withdrawn
  `pdos_pointer`, places the index-to-ARGB conversion in the DOS profile's cursor callback, and closes
  Open A11 (B 6.7 returns NULL for "no pointer of its own").
* **RV2-14.** K2's list and K5 gain area E's `host.h` additions (`host_dos_read`, `host_dos_where`,
  `HOST_DOS_*`), their back ends and `zip_find_base`: phase D2, guard E.13.3 and G-1 (17).
* **RV2-15.** Recorded in 17: B's `int16_t` result matches the core's AX for every argument, so the
  ScaleLogicalX/Y exit may be dropped at D3 with no behaviour change.
* Section 17's "points" record what Revision 3 applied (D's `pmap_*` names in D 17, C's note, B's
  pointer state).

## Revision 2 (after RV1)

This revision applies [ext-d1-review-rv1.md](ext-d1-review-rv1.md) and the orchestrator's resolutions
in [ext-d1-decisions.md](ext-d1-decisions.md):
* "Area A" K1..K9;
* the area-A items of "Design review RV1", with RV1-4's adoption of draft D's section-17 requests
  A-1..A-8;
* "Area B": draft B's section-20 requests A-B1..A-B8 and decision X3;
* "Area C": C.20-9 (C's probe rows) and draft C's interfaces with A (C.21 A-1..A-6).

Each change was checked against the code again.

* **RV1-4 (D's requests A-1..A-8)**
  * Adopted with D's `pmap_*` names (D 3 after RV1-2 and RV1-3):
    * the tick shows layer damage (A-1, 7.2);
    * `present_core` and VIEW redraws call `pmap_overlay` (A-2, 8.3);
    * new queries `w16q_wnd_client_vis`, `w16q_sys_track` and `w16q_draw_on` (A-3, section 5);
    * `PiOut.cmd_hx`/`cmd_hy`, and `pi_arrive_mouse` asks `pmap_layer_point` (A-4, 10.1);
    * `HostEvent.frame` 3 is a layer point and 4 a ring square (A-5, 10.1);
    * zoom fields in `presented.log` and `profiles.log` (A-6, 7.3, 12.2);
    * D's probes (A-7, 4.3);
    * zoom menu ids, `--zoom`, the `zoom` key and the `zoom` command (A-8, 11, 12.1).
  * Section 2 lists the files. K2 gains the outline state in `user_syscmd.c` and the rasteriser
    refactor of `gdi_draw.c` and `gdi_font.c`, both guarded by G-1.
* **RV1-5.** Every DOS variation of 7.3 and 7.4 passes `--dos-data build\dosdata`. The runner asserts
  from `profiles.log` that the switches happened and none was refused (13.1, 13.2). Switch records
  move to `profiles.log` (12.2). "No `--dos-data` needed" now applies to civ64 only (section 0). The D3
  "test stub" is gone (8.4).
* **RV1-6.** "Locate DOS files..." only records the choice in `civ64.cfg`; it takes effect at the next
  start (10.2, 11). An unavailable profile is not registered for the run (8.2).
* **RV1-7.** The cursor goes through `present_cursor`. The visible profile decides between the game's
  RT_CURSOR (`host_set_cursor`) and pixels with a hot spot (new `host_set_cursor_pixels`). A switch
  re-issues the cursor (8.5). `user_cursor.c` and `host.h` are added to K2 and K5.
* **RV1-8.** Cadence is one message per run, then beeps. The text is E's message alone plus the Locate
  hint (10.2).
* **RV1-9.** `OBS_PAL_ANIMATE` is emitted after the entries change, with the `moved` flag (3.3).
* **RV1-10.** ResyncMovieClock 10B0:14F4 is dropped (not ported) (4.3).
* **RV1-11.** `obs_init()` runs in `civ64_main.c` after `w16_host_start` (260) and before
  `civ64_run_game` (261), after E's activation. In the harness it runs in `hh_run` (4.1).
* **RV1-12.**
  * The P0 argument names `present_game_screen(_follow)` (1, item 2).
  * The view functions become profile-aware.
  * The relation check reads the Windows frame through `present_core_xrgb` (8.3). That is B's name
    (A-B5) for the accessor this revision first called `present_windows_frame`. One function serves
    both.
* **RV1-13.** The arrival stage is in its own always-compiled file, `present/arrive.c`.
  `CIV_OBSERVER=0` removes only the filter stage (2, 9, 10.1).
* **RV1-14.** `obs_init`, `hh_run` and the test fixture reset the guard depth (6.1).
* **RV1-15.** The arrival stage masks MK_SHIFT and MK_CONTROL of held keys in mouse events. This goes
  with K3's FIDELITY entry (10.2).
* **RV1-18.** The DOS profile file is `present/dos/pdos_profile.c`.
* **RV1-19.**
  * Call-site rows compare offsets for near callees (4.2).
  * The audit cites MenuZSubclassWndProc 1220:1289 (10.2).
* **K1..K9** are recorded as resolved in section 17. K7 is not a conflict: extension 2.1 "Settings
  file" lists the last graphics profile.
* **Area B (A-B1..A-B8, X3)**, from [ext-d1-draft-B.md](ext-d1-draft-B.md) section 20:
  * **A-B1.** Every logical-layer probe (WI 10.1) and every text-drawing probe of WI 10.2 has an exit
    probe as well as its entry probe (4.3). B's brackets need the exit.
  * **A-B2.** New probes (4.3):
    * GR_PortDataToBitmap 10B8:0E36, PlotSmMapSquare 1210:07AE and DrawMiniPalace 1088:1A82;
    * all of WINDOWS-INVENTORY.md 10.2's text probes.

    4.3 now takes WINDOWS-INVENTORY.md 10 (F3's fixed list, 175 functions) as its base and adds 26.
    Every address was checked as a function entry with a FrameDesc. That gives 201 keys (203 with
    area C's two), under 256. LoadGifPicture, wrongly in revision 1, is dropped (WI 10.3: only GR_PicRead reaches it).
  * **A-B3, A-B4.** New queries `w16q_msgbox` and `w16q_menu_item` (5.1). `w16q_menu_bar` comes with
    them. They need read-only accessors in `user_msgbox.c` and `user_menu.c`/`user_wnd.c` (5.2,
    K2). The message box is queryable from its show, not its create (5.2).
  * **A-B5.** `present_core_xrgb()` (8.3). `present_core` updates the Windows frame before any
    profile's `on_core_present`.
  * **A-B6.** The tick re-lays out the view, redraws the whole client and re-issues the cursor when the
    visible frame's size changes (7.2).
  * **A-B7.** The DOS profile's `cursor` wraps `pdos_cursor_current()` (8.5). **Choice:** the back end
    applies the layout factor, so B's image is at frame scale. B 6.7's scale line changes to match
    (17). B's Windows-class scroll-arrow cursors need a "no pointer of its own" state (Open A11).
  * **A-B8.** 8-bit N-frame dumps through a new profile callback `indexed` (8.1, 7.3). While applying
    this I found that `--dump-presented` exists only in civ64 (host_win32.c 932..1005, civ64_start.c
    94). 7.3 now places the dumps in the back ends, and the harness gains its own `--dump-presented`.
  * **X3.** The `--aspect` default becomes 4:3, at civ64_main.c:223 and in the harness. It affects
    320x200 frames only (scale.h 75..76), which only the DOS profile shows (11).
* **Area C (C.20-9, C.21 A-1..A-6)**, from [ext-d1-draft-C.md](ext-d1-draft-C.md):
  * **Probe rows (C.20-9; 4.3).** All were checked with `showfunc.py`: each callee is a function
    start with a far-return FrameDesc, and each `ra` follows its call instruction.
    * SetGameCursor `ra` 11E0:08D7, plus 11E0:094E;
    * IsKeyPending 11E8:02FB `ra` 1220:0AA5 (new key);
    * MenuZ `ra` 11E0:0729 and 10E8:0528;
    * DestroySequencePlayer `ra` 11E0:0114 and 11E0:01E8;
    * GR_DialogOpen `ra` 11E0:0044;
    * GR_DialogClose 1098:1612 `ra` 11E0:0217;
    * DrawUnitStackList 11C0:3407 `ra` 11C0:334F (new key; a `push cs` call, so far return and
      full comparison).

    The total is 203 keys.
  * **`ObsProbe` defined (4.2; C.21 A-2)** with `ra`, `site`, `t_us` and `arg_base`, and no
    `FrameDesc`.
  * **Frame stamps on every event (10.1; C.21 A-1).** A new profile callback `input_frame` (8.1)
    covers key, character and focus events.
  * **Filter dispatch, release and the I4 queue's place (10.1; C.21 A-3).**
    * `present_input_filter` dispatches by frame; `present_input_release` calls `pdos_pend_release`.
    * `PI_MAX_OUT` is 16.
    * The release runs once per input-taking sync, after that sync's host events. The five kinds of
      input-taking sync are listed.
    * C's claim that MenuZ's IsKeyPending probe precedes the releasing PeekMessage was checked
      (ProcessKeyboardMessage peeks a key range; queue.c:441).
    * A new `pdos_adapt_note` lets C cancel on frames 0, 3 and 4 (a change for C, 17).
  * **Logs (12.2; C.21 A-4).** `timeline.log` and `adapt.log` through `present_log`.
  * **`sync <n>` host-form lines (12.4)** for C's Open C-1.
  * **Lint rules (6.2; C.21 A-6)**, with the `RandomBelow` rule narrowed.
  * **A8 settled** by C.4.2.

## 0. Authority points relied on

| Point | Source | Effect on this design |
|---|---|---|
| The game's virtual screen follows the host client during play (F105, F110) | DESIGN.md 12.4; STATUS user directions; decision K1 | **Scoped P0.** P0 holds for the profile, the switch history and the zoom in every mode. It holds for the host size and the policy only with a fixed game screen: the harness default or `--game-screen WxH` (13.1). |
| `stretch` is removed | DESIGN.md 12.1, 12.4 | Policies are `integer` and `fit` only, in commands and in the menu. |
| M is a backlog item, zoom levels -1, 0, +1 (decision C1: `--zoom default\|-1\|0\|+1`) | STATUS "Extension track"; K9 | The `zoom` harness command, the zoom chords and V4 stay inactive until phase M. The M hooks of this draft (`pmap_*`) are added with M. D3 ignores the wheel. |
| Asan runs are deferred to the end of the queue | STATUS (user, 21:20); K8 | Gate records say "Asan deferred". One Asan pass runs at the end. |
| Default timing is `classic`, not `host` | X0 review B1.13; civ64_start.c:60 | The tick does not rely on `--timing host`. |
| civ64 finds the DOS files through phase R; the harness needs `--dos-data` | X0 D8; DESIGN.md 12.3; E.3.4; RV1-5 | civ64: R's lookup. A remembered DOS location that has gone missing makes the profile unavailable without a dialog. Harness: every DOS run passes `--dos-data build\dosdata`. |
| The extension's 2.1 "Settings file" grant lists the last graphics profile | prompt 2.1; K7 | The profile is remembered (section 11). |
| Tick throttled by virtual time headless, by host refresh in Win32; Windows frame built inside `w16_present` | X0 D13 | Followed (section 7). |
| `CIV_OBSERVER=0` removes events, probes, the tick, the filter hook and the 7.8 mode; it has its own build directory | X0 D5; RV1-13 | Followed. The arrival stage stays (section 9). |
| 5.1's list of w16 changes is widened | X0 review B1.9, D14; K2 | Every w16 change is listed with its reason (K2). |
| The start-up screens "shall stay 4:3" (user, 2026-10-10 21:00) | decision X3 | The `--aspect` default is 4:3. It acts on 320x200 frames only (section 11). |
| Area B's requests to A are accepted | ext-d1-decisions.md "Area B" | A-B1..A-B8 are applied in sections 4.3, 5, 7, 8. |
| Shorter 7.3 matrix at intermediate gates; S4/S5 under every variation only at X9 | X0 D29 | Followed (13.1). |
| 7.4 compares runs with identical core input | X0 D28 | Followed (13.2). |
| DOS assets are activated once, before the emulation | E.4.2; RV1-6 | The DOS profile is available for the whole run or not at all (8.2). |
| Progress reports stopped | STATUS | None are planned. |

## 1. P0 in one page

P0 says: for a fixed core input and virtual time, checkpoints, the Windows virtual screen and the base
event trace do not depend on the profile, policy, size, full screen, zoom or switch history.
For size and policy, P0 is scoped: it holds with a fixed game screen (K1).

Why nothing in this design can break it:

1. **Presentation only reads.**
   * It reads through the `w16q_*` query API (section 5).
   * That API does not use `mem_rd*`, `vm_resolve`, `acc_chk` or `note_write`, and it never faults.
   * It hands out `const` pointers or fills caller buffers.
   * It refuses `g_randSeed` (1420:4EE0..4EE3).
   * `w16q_draw_on` draws only on a caller surface, never on the virtual screen or an emulated
     bitmap (5.2).
   * `w16q_msgbox`, `w16q_menu_item` and `w16q_menu_bar` copy w16's own records and allocate
     nothing (5.2).
2. **Only two presentation outputs reach the core.** Events, probes, the tick and the cursor route
   return nothing the core uses. The two exceptions:
   * **The filter's output** (section 10).
     * It feeds `post_event` only in Win32 mode and in the 7.8 harness mode.
     * In P0 runs (`W16_TIMING_NONE`), `w16_host_sync` returns at once (host_sync.c:181), and the
       harness posts scripted core input directly (harness.c:868-889), as today. So the filter is not
       on the P0 input path.
   * **The game screen's size** (RV1-12).
     * `host_game_screen` and `host_game_screen_follow` call `present_game_screen(_follow)`
       (host_headless.c 335, 350; host_win32.c 1014, 1020).
     * These read only `CORE_W x CORE_H`, the client size and the policy (present.c 172..214). They
       never read the visible profile, the shown frame (`shown()`, which becomes profile-aware, 8.3)
       or the zoom.
     * **Requirement:** they must stay so. `test_present.c` checks equal answers under both profiles
       and every zoom level (13.4). The zoom (phase M) never feeds them (K1).
     * Under `--game-screen view` the host size and the policy are core inputs by the user's
       direction (F110, scoped P0).
3. **The tick cannot reach `w16_present`'s state.**
   * The statics `g_dirty_set`, `g_palette_dirty`, `g_last_present_us` and `g_presented` are `static` in
     gdi_pal.c (63..67).
   * `present/` never calls `w16_present`.
   * The tick calls `host_show` only. `hh_frame_count` and the core frame lines change only in
     `host_present` (host_headless.c:294).
   * `present_core` still calls `host_present` unconditionally, once per `w16_present` that presents,
     whatever the profile (8.3).
4. **Probes do not count as steps.**
   * The hook sits in `fr_enter` after the frame is built and in `fr_leave` before the pops (4.2).
   * It runs no `VM_SITE` and does not change `vm_site` or `vm_steps`.
   * It makes no checked-build record (`cover` has already run; `g_prolog_fn` is already 0).
5. **Checked builds trap any breach at its source.** A depth counter and a state sentinel wrap every
   call into presentation. Forbidden w16 operations fault while the depth is not 0 (section 6).
6. **The cursor route changes no emulated state.**
   * `w16_SetCursor` keeps `g_current` and its return value. Only the host call moves behind
     `present_cursor` (8.5).
   * `host_set_cursor` and the new `host_set_cursor_pixels` are host-side only.
7. **The w16 refactors keep the core's pixels and state.**
   * The outline state of `user_syscmd.c` and the rasteriser split of `gdi_draw.c`/`gdi_font.c` (K2)
     are guarded by G-1. Every core frame hash and checkpoint must be unchanged.
   * The outline state is not part of any snapshot or API result.
   * The message-box and menu accessors (A-B3, A-B4) only read. They are compiled only under
     `CIV_OBSERVER`.
8. **Harness commands are not input.**
   * `profile`, `policy`, `hostsize` and later `zoom` call only `present_*`, `pmap_request_zoom` and
     `hh_set_view` (section 12).
   * They are applied at `VM_STEP_API` inside the same guard.

Tests that catch a breach:

* **7.3 runner `ext_p0.py`.** It compares the frame lines, the snapshot and result lines, and
  `events.log` of every run and variation with the plain run (13.1).
* **`ext_g1.py`.** It checks the frozen baseline on the observer build and on the `CIV_OBSERVER=0`
  build.
* **Checked sentinels.** They fault at the offending hook, naming the event or probe.
* **S1's relation check (HARNESS_PRESENT_MISMATCH).** It catches a screen change without a dirty
  rectangle.

## 2. Layers and files (5.1)

New and changed files (D3, unless marked M or D4). Base names are unique across the build; build.cmd
names objects by base name (71, 77, 89). The names below collide with no existing file (RV1's
`basenames.txt`) and none with D's `pmap_*` or E's `pdos_*`.

| File | Content |
|---|---|
| `present/observe.h`, `observe.c` | `ObsEvent`, `ObsProbe`, `ObsDraw` types; `obs_init`; `obs_event`, `obs_probe` dispatch to every registered profile, and from M on to `pmap_on_event` / `pmap_on_probe`; the probe table `OBS_PROBES[]` and the call-site table `OBS_CALLSITES[]`; `obs_callsite` (RV2-4), `obs_probe_phases` and the `OBS_AT_EXIT` marker (RV2-1); presentation diagnostics. Under `CIV_OBSERVER=0` the file compiles to nothing |
| `present/profile.h` | `PresentProfile` (the renderer interface, 8.1); `present_request_profile`, `present_profile_visible`, `present_tick`, `present_set_tick_clock`, `present_show_reason`, the sample hook |
| `present/profile_win.c` | the Windows profile (S1's `g_win` moves here) |
| `present/dos/pdos_profile.c` | the DOS profile (RV1-18). In D3 it shows the Windows frame through the tick (8.4). From D4 on, area B fills it from its `pdos_compose`, `pdos_cursor` and the other modules (B 2) |
| `present/input.h` | declarations of both input stages |
| `present/arrive.c` | the arrival stage `pi_arrive_*`: chords, the modifier hold rule, mouse arrival, the wheel. **Always compiled** (RV1-13) |
| `present/input.c` | the filter stage `present_input_filter` / `present_input_release` (I2..I6): dispatch by `HostEvent.frame` to C's `pdos_adapt_filter` and D's `pmap_filter_ring`; the release calls C's `pdos_pend_release` (10.1). Its body is under `#if CIV_OBSERVER` |
| `present/present.h` additions | `present_log` for C's `timeline.log` and `adapt.log` (12.2) |
| `present/present.c` | `present_core` calls the profiles and from M on `pmap_*` (8.3); the tick, switching and re-layout on a frame-size change (7.2, A-B6); the cursor route `present_cursor` (8.5); profile-aware view functions, `present_core_xrgb` (A-B5) and `present_shown_indexed` (A-B8) (8.3) |
| `platform/w16/w16_obs.h`, `w16_obs.c` | the read-only query API `w16q_*` (section 5); the emission macros `W16_OBS_*` and `W16_TICK()`; the Checked guard and sentinel (section 6) |
| `platform/w16/vm.h`, `vm.c` | `CIV_OBSERVER` default; the probe table and hooks in `fr_enter` / `fr_leave` (section 4) |
| `platform/w16/*.c` | event emission sites (3.3); `W16_TICK()` at four sites (7.1); Checked forbid checks (6.1) |
| `platform/w16/user_cursor.c` | `w16_SetCursor` calls `present_cursor` instead of `host_set_cursor` (8.5) |
| `platform/w16/user_syscmd.c` (M) | outline state for `w16q_sys_track` (5.2) |
| `platform/w16/gdi_draw.c`, `gdi_font.c` (M) | the rasterisers split from their DC-bound API wrappers, for `w16q_draw_on` (5.2) |
| `platform/w16/user_msgbox.c`, `user_menu.c`, `user_wnd.c` (D4) | read-only accessors under `#if CIV_OBSERVER` for `w16q_msgbox`, `w16q_menu_item`, `w16q_menu_bar` (5.2, A-B3, A-B4) |
| `platform/w16/host_sync.c` | the filter hook; `W16_TIMING_SCRIPT` (the 7.8 mode); a post hook for the core-input log (10.1, 12.4) |
| `platform/w16/host.h` | `HostEvent.frame` (10.1); `host_set_cursor_pixels` (8.5) |
| `platform/win32/host_win32.c` | key and mouse arrival through `pi_arrive_*`; the wheel (M); profile and zoom chords and menu items; Locate; `host_set_cursor_pixels`; tick clock from the monitor's refresh; `--dump-presented` at tick shows and 8-bit N frames (7.3) |
| `tests/headless/host_headless.c` | `host_set_cursor_pixels`; a cursor hook for the trace; the harness's `--dump-presented` files (7.3) |
| `win64/civ64_main.c`, `civ64_start.c`, `civ64_cfg.c`, `civ64_locate.c` | `obs_init` site; `--graphics`, `--zoom` (M); settings keys `graphics`, `zoom` (M); the `--aspect` default 4:3 (X3, section 11); the Locate entry `civ64_locate_dos_choose` (10.2) |
| `tests/headless/harness.[ch]`, `harness_main.c` | commands; options including `--dump-presented` and the 4:3 aspect default; tick lines in `presented.log`; `profiles.log`; the 7.8 mode; `coreinput.log`; `presentation-diag.log` |
| `tests/harness/ext_p0.py`, `ext_frames.py`, `ext_adapt.py`, `obs_lint.py` | the 7.3, 7.4 and 7.8 runners and the O5 static check |
| `tests/test_observer.c`, `tests/test_input.c` | unit tests (13.4) |
| `build.cmd` | variant `checked noobs` → `build\x64\CheckedNoObs`, `/DCIV_OBSERVER=0`. D adds `present\map`, E adds `present\dos` |

**Choice: layering.**
* The query functions live in w16 (`w16_obs.c`) because they need w16's static records.
* `present/` calls only `w16q_*` and nothing else in w16.
* Rejected: implement the queries in `present/` over exported w16 internals. That would spread w16
  internals into portable presentation code.

**host.h changes (area A; K5):**
* `HostEvent` gains `uint8_t frame`. It says which frame the event's x and y belong to (10.1).
* `void host_set_cursor_pixels(const uint32_t *argb, int32_t w, int32_t h, int32_t hot_x,
  int32_t hot_y)` (8.5).
* The composed-frame present is S1's `host_show`. The DOS directory service is area E's.
* The tick clock for Win32 is set by the back end through `present_set_tick_clock` (7.2). It is a
  `present.h` call, not `host.h`.

## 3. Events (O1)

### 3.1 Delivery

* `obs_event(const ObsEvent *e)` is called synchronously at the emission site. It calls, in a fixed
  order, every registered profile's `on_event` (Windows, then DOS), visible or not (O6). From M on it
  then calls `pmap_on_event`.
* `e->t_us` is `w16_clock_us()` at emission. This is the free accessor (clock.c), which costs no
  virtual time.
* An event carries the data a profile needs for it. Profiles may query during the callback through
  `w16q_*`. They keep no handle beyond what the event names.
* Emission points sit where w16's state is consistent for the event: after the change, or for destroy
  before the record is freed.
* Macro `W16_OBS(type, init...)` expands to nothing under `CIV_OBSERVER=0`. The struct is built only
  inside the `#if`.

### 3.2 Types

> **C passage condensed for the public copy.** The original record has here a block of 36 lines of C declarations: types `ObsEvent`, `ObsDraw`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

Event types: `OBS_WND_CREATE`, `OBS_DLG_CREATE`, `OBS_WND_DESTROY`, `OBS_WND_SHOW`, `OBS_WND_HIDE`,
`OBS_WND_RECT`, `OBS_WND_ZORDER`, `OBS_WND_ACTIVATE`, `OBS_FOCUS`, `OBS_WND_TEXT`, `OBS_WND_ENABLE`,
`OBS_CTL_CHECK`, `OBS_CTL_PRESSED`, `OBS_LB`, `OBS_EDIT`, `OBS_MENU_TRACK` (start, end),
`OBS_MENU_OPEN`, `OBS_MENU_HILITE`, `OBS_MENU_CLOSE`, `OBS_SYS_TRACK` (start, end of the move/size
loop; M), `OBS_DRAW`, `OBS_SCREEN_DAMAGE`, `OBS_BITMAP` (create, bits, delete, damage),
`OBS_PAL_ANIMATE`, `OBS_PAL_REALIZE`, `OBS_PAL_SELECT`, `OBS_PAL_SET`, `OBS_CURSOR`, `OBS_SOUND`,
`OBS_BEEP`, `OBS_SCREEN_SIZE`.

### 3.3 Emission sites

**Choice: two layers for drawing.**
* The damage events are emitted inside the two funnels:
  * `OBS_SCREEN_DAMAGE` in `w16_screen_dirty` (gdi_pal.c:316);
  * `OBS_BITMAP` damage in `w16_target_done` for memory targets (gdi_dc.c:414).
* Completeness of damage is therefore structural. S1's relation check already proves that every screen
  change goes through a dirty rectangle.
* The detail events (`OBS_DRAW`) are emitted at each API.
* Rejected: change the `w16_target_done` signature to carry the operation. That is compile-time
  complete, but it builds an `ObsDraw` in the `CIV_OBSERVER=0` build too.

| Event | File and function (line) | Point |
|---|---|---|
| `OBS_SCREEN_DAMAGE` | gdi_pal.c `w16_screen_dirty` (316) | after the dirty set is extended |
| `OBS_BITMAP` damage | gdi_dc.c `w16_target_done` (414) | memory target, non-empty `changed` |
| `OBS_DRAW` FILLRECT | gdi_draw.c `w16_FillRect` (214; `w16_target_done` 225) | after `w16_target_done` |
| `OBS_DRAW` FRAMERECT | `w16_FrameRect` (230; 274) | same |
| `OBS_DRAW` LINE | `w16_LineTo` (279; 295) | same |
| `OBS_DRAW` POLYLINE | `w16_Polyline` (300; 321) | same |
| `OBS_DRAW` POLYGON | `w16_Polygon` (328; 441) | same |
| `OBS_DRAW` SETPIXEL | `w16_SetPixel` (446; 472) | same |
| `OBS_DRAW` BITBLT | `w16_BitBlt` (497; 580) | same, with source DC, bitmap, rectangle and ROP |
| `OBS_DRAW` TEXTOUT | gdi_font.c `w16_TextOut` (673; 723) | same, with text bytes and `SetTextAlign` state |
| `OBS_DRAW` DRAWTEXT | `w16_DrawText` (792; 911) | same, with the `DT_*` format |
| `OBS_DRAW` CTL_PAINT | user_ctl.c button paint (449), `edit_paint` (675) | after `w16_target_done` |
| `OBS_DRAW` MENU_PAINT | user_menutrack.c (621) | after `w16_screen_dirty` |
| `OBS_DRAW` NC_PAINT / EXPOSE | user_syscmd.c (117); user_wnd.c (930, 1065, 1543) | after `w16_screen_dirty` |
| `OBS_BITMAP` create, bits, delete | gdi_obj.c `w16_CreateBitmap` (339), `w16_CreateDIBitmap` (360), `w16_SetBitmapBits` (420), `w16_DeleteObject` (497) for bitmaps, and any `SetDIBits` | after the bits change; delete before the object is freed |
| `OBS_WND_CREATE` | user_wnd.c `w16_create_window` (1915) | record complete, before WM_CREATE is sent |
| `OBS_DLG_CREATE` | user_dlg.c `w16_CreateDialog` (568), at the existing `W16_TRACE("dialog")` (710) | children created; template id or name |
| `OBS_WND_DESTROY` | user_wnd.c `destroy_tree` (2456) | per window, before its record is freed |
| `OBS_WND_SHOW` / `HIDE` | `show_sequence` (2349) | when the visible bit changes |
| `OBS_WND_RECT` | `set_rect` (2681) | after the rectangle changes |
| `OBS_WND_ZORDER` | `link_top` (1662), `link_bottom` (1670) | after relinking |
| `OBS_WND_ACTIVATE` | `activate` (1752), at `log_activate` (1699) | after the change |
| `OBS_FOCUS` | `set_focus_raw` (1683) | after the change |
| `OBS_WND_TEXT` | the internal text setter used by `w16_SetWindowText` (3808) and WM_SETTEXT | after the change |
| `OBS_WND_ENABLE` | `w16_EnableWindow` (3380) | after the change |
| `OBS_CTL_CHECK`, `OBS_CTL_PRESSED` | user_ctl.c BM_SETCHECK handling; `set_pressed` (476) | after the change |
| `OBS_EDIT` | `edit_replace` (701); selection and caret changes in `edit_proc` (802) | after the change |
| `OBS_LB` | user_listbox.c `insert` (632), delete and reset handling, `user_select` (579), LB_SETCURSEL | after the change |
| `OBS_MENU_TRACK` | user_menutrack.c `track` (999) | start and end |
| `OBS_MENU_OPEN`, `HILITE`, `CLOSE` | `open_popup` (672); `select_item` (563), `menu_select` (535), `bar_hilite` (553); `close_to` (651), `close_deepest` (624) | after the change |
| `OBS_SYS_TRACK` (M) | user_syscmd.c `movesize` (160) | after the first `outline` (208); before return, after the last (298) |
| `OBS_PAL_REALIZE` | gdi_pal.c `w16_RealizePalette` (202), at the trace (269) | after the entries changed (255), before `w16_present(1)` |
| `OBS_PAL_ANIMATE` | `w16_AnimatePalette` (277) | **after the loop (286..307), before `if (moved)`**, with `u.pal.moved` (RV1-9) |
| `OBS_PAL_SELECT`, `OBS_PAL_SET` | gdi_obj.c `w16_SelectPalette` (561), `w16_CreatePalette` (476) and SetPaletteEntries | after the change |
| `OBS_CURSOR` | user_cursor.c `w16_SetCursor` (145) | when the cursor changed, before `present_cursor` (8.5) |
| `OBS_SOUND`, `OBS_BEEP` | user_misc.c `w16_sndPlaySound` (428), `w16_MessageBeep` (445) | at entry |
| `OBS_SCREEN_SIZE` | user_wnd.c F105 (2284) and F110 (3091) | after the screen changed |

* The base trace `W16_TRACE` stays as it is.
* **Choice: separate channel.** Observer events are a channel of their own, so `events.log` cannot
  change. Rejected: extend `w16_trace_fn`, which feeds the base trace.

**Cost.** One struct of about 100 bytes and up to three indirect calls per event. Measured at D3, and
expected under 50 ns. Draw events are thousands per frame, so this is negligible beside the drawing
itself.

## 4. Probes (O2)

### 4.1 Table

> **C passage condensed for the public copy.** The original record has here a block of 6 lines of C declarations: functions `vm_probe_install`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* Open addressing in vm.c:
  * `static struct { uint32_t addr; uint16_t id; uint8_t phases; } g_probe[2048];`
  * hash `(addr * 2654435761u) >> 21`, the multiplier of the checked coverage set;
  * linear probing;
  * at most 256 probes, so the load stays at or below 1/8.
* `g_nprobes` is checked first, so a run without probes pays one load and one branch.
* **`obs_init()`** builds the run's state before the core starts:
  1. resets the profiles;
  2. registers the available ones (8.2);
  3. installs the table;
  4. clears the diagnostics;
  5. sets the guard depth to 0 (RV1-14).

  Where it runs (RV1-11):
  * **civ64:** `civ64_main.c`, after `w16_host_start(opt.timing)` (260) and before `civ64_run_game()`
    (261). This is after `vm_init` (240) and after E's activation (E.3.3 step 3, before 208). Note:
    `rt_WinStartupEntry` is called in civ64_game.c:14.
  * **Harness:** `hh_run`, after `present_reset` (harness.c:1096) and E's `pdos_assets_open` (before
    `vm_init` 1061), and before `vm_set_step_fn(step)` (1137).
* The table never changes during a run, so the hook's cost and behaviour cannot depend on the profile.

**Choice: hash table keyed by `fd->addr`.**
* Rejected: a field in `FrameDesc`, which would change `core/gen` for 854 descriptors.
* Rejected: binary search, which is slower.
* Rejected: the harness mark filter, which needs `VM_SITE` and exists only in Checked.

### 4.2 Hooks

> **C passage condensed for the public copy.** The original record has here a block of 13 lines of C statements: calls to `probe_find`, `W16_OBS_GUARD_BEGIN`, `g_probe_fn`, `W16_OBS_GUARD_END`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* **Where the arguments are.** At entry the frame is complete:
  * BP frames: `bp + 2 + (far_ret ? 4 : 2)` (`[bp+6]` for far frames);
  * `FR_NONE`: `sp + 2*nregs + locals + (far_ret ? 4 : 2)`.

  `obs_arg_base(fd, bp, sp)` in `w16_obs.c` computes this.
* **Return values.** At exit, `cpu.ax` and `cpu.dx` hold the return value only where the translator
  writes it, that is where callers read it (DESIGN.md 3.4). Each exit probe that reads AX records why
  that holds. Example: `TileCacheInsert` returns the HBITMAP its callers store.
* **Nothing is counted or recorded.** The hook does not touch `vm_steps` or `vm_site` and makes no
  checked record. `cover(fd)` has already run. The hook writes no emulated memory, so `note_write`
  and `acc_chk` are not reached. The probe function reads only through `w16q_*` (section 5).
* **Pairing.** core, rt and w16 have no Catch, Throw or longjmp (grep of 2026-10-11). Every `fr_enter`
  is matched by one `fr_leave` within a run. The harness's longjmp ends the run.
* **Call sites through `ra`.** `fr_enter` receives the original return address, so a probe on the
  callee plus an `ra` filter gives call-site precision in every build. Example:
  `GR_DialogOpen(0x12200102u, ...)` at core/seg069_1220_p1.c:114 for the call at 1220:00FD.
  * This replaces statement-level probes, which are impossible in Release (`VM_SITE` is an inline
    store, X0 review B1.6).
  * `OBS_CALLSITES[]` lists `(callee, ra, label)`. The probe handler looks up `ra` in it, not in the
    hash.
  * **Naming a row (RV2-4).** `int obs_callsite(uint32_t callee, uint32_t ra)` in `present/observe.h`
    returns the row index of `(callee, ra)` in `OBS_CALLSITES[]`, or -1 when there is none. It
    applies the same near-callee comparison as the handler (below). B and C resolve every row
    they filter on once, in their `reset` callback, and compare `ObsProbe.site` against the stored
    index. An unresolved pair is a configuration error: a Checked fault at reset, and an obs_lint
    check (6.2) that the constant arguments of every `obs_callsite(...)` call in `present/` name a
    generated row.
  * **A key's phases (RV2-1).** `uint8_t obs_probe_phases(uint32_t addr)` returns the `OBS_ENTER` and
    `OBS_EXIT` bits of the key at `addr` in `OBS_PROBES[]`, 0 when it is not a key. B's
    `pdos_shadow_macros` uses it to count a macro whose key lacks the exit (B 7.3). Both functions
    read only the fixed tables, so they may be called at reset and registration.
* **Near callees (RV1-19).** `fr_enter` stores `ra & 0xFFFF` for a near return
  (`g_ctl_stack[].ra = far_ret ? ra : ra & 0xFFFF`), and a near callee is entered only from its own
  segment.
  * Rows keep the full SSSS:OOOO.
  * The handler compares `fd->far_ret ? ra == row.ra : (ra & 0xFFFFu) == (row.ra & 0xFFFFu)`, at
    entry and exit alike.
  * `push cs` + near call frames have `far_ret` 1 and compare in full (1098:1931 below;
    DrawUnitStackList 11C0:3407 from 11C0:334C, whose FrameDesc has `far_ret` 1).

**What a probe handler receives** (`present/observe.h`; C.21 A-2). `obs_probe` builds it from the
hook's arguments. Presentation code sees no `FrameDesc` and needs no `vm.h`:

> **C passage condensed for the public copy.** The original record has here a block of 10 lines of C declarations: types `ObsProbe`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* Arguments are read with `w16q_arg16/32/argptr(p, i)` from `arg_base`. Exit values are read with
  `w16q_ret_ax/dxax()` (5.1).
* `site` saves every handler from repeating the `ra` comparison.
* The struct is valid during the callback only.

**Cost.**
* Per `fr_enter`: one load of `g_nprobes`, one multiply, one shift, about 1.1 slot reads, and one
  compare. That is 1 to 2 ns against `fr_enter`'s pushes and `stk_check`.
* The same applies to `fr_leave`.
* Recorded at D3 as the wall time of soak S4 in Release with and without the table (informational).

### 4.3 Probe list

**Base list.** The base is WINDOWS-INVENTORY.md 10, F3's fixed O2 list (K6): 182 rows naming 175
functions.
* Each row keys on the function start and gives a call site where one caller matters.
* Its rows, arguments and call sites are taken as they stand.
* The phases are WI's, widened where B or D need an exit (below).
* E/X is entry or exit.

| WI 10 section | Phases used here | Change |
|---|---|---|
| 10.1 logical layer (21 functions, MapLogicalPointToPort 1220:0F2F included) | **E and X on every row** (A-B1) | WI lists most of them entry only. B's brackets (B 7.3, 8.2) need the exit to close the bracket. ScaleLogicalX/Y 11E8:0D81/0DA8 get the exit for B's `(v, ScaleLogical(v))` pairs (B 8.3). B computes the port kind itself (B8). MapLogicalPointToPort's probe serves B's Checked comparison only. |
| 10.2 text (15) | **E and X** on DrawTextInRect 1098:0ED1, TextBoxSetup 1068:2072, TextBoxDraw 1068:258F, TextBoxDrawAndClose 1068:255A, DrawTextAtPortXY 10D8:00E0, ShowTextDialog 1220:00D2, MenuZ 1220:0156, PaintRandomStatic 1058:04F6 and PaintRandomRadio 1058:0000 (A-B1, A-B2). SplitMenuText 1220:0000 and SubstituteTextTokens 11D0:022D: X, as WI. SetCivFont 11E8:0B40, SetTextFontSizeColor 1068:1F7E, LoadKingText 11D0:01F7 and LoadTextResource 11D0:00E4: E, as WI | all of WI 10.2 is in (A-B2) |
| 10.3 pictures and shapes (7) | as WI; DrawTile 11A8:0CB1 E (D A-7) | LoadGifPicture 10B8:11BC is not probed: WI 10.3 notes that only GR_PicRead reaches it. Revision 1 listed it, wrongly. |
| 10.4 recolouring, cache (3) | as WI; TileCacheLookup 1110:030C **E and X** (D A-7) | |
| 10.5 movies (8) | as WI | |
| 10.6 map (9) | as WI; DrawUnit 1110:0DBA **E and X** (D A-7); **E and X** on DrawMapTile 1110:04D0, DrawUnitAt 1110:0FF6 and DrawCityLabels 1208:1F64 (RV2-1) | WI lists the last three entry only. D 9.3's DROP brackets close at their exit. |
| 10.7 scene entries and exits (115 rows, 116 functions) and 4 input rows | as WI, with its call-site filters (A1); **E and X** on WdwMapOpen 1208:0AF1, RedrawSmMap 1210:073F, DrawSmTiles 1210:09B4, RedrawStatusWindow 1218:0801, DrawStatusCivPanels 1088:13D5 and DrawUnitInfoPanel 11F0:468C (RV2-1) | BlinkActiveUnitUntilInput 11C0:0EC2, AnimateUnitMove 11C0:2C32 and ResolveCombat 1050:0000 are rows here with entry and exit, which covers D's A-7. WI lists the six RV2-1 functions entry only (WI 10.7 lines 816, 818..822). B 12.2 and 12.3 close DROP brackets at their exits and draw the status and unit panels there; B 5.5 loads the play palette at WdwMapOpen's exit. |

**Additions beyond WI 10** (26 functions). Each is a function entry in the listing with a far
FrameDesc in `core/gen/civ_frames.c` (scratch `check_b_probes.txt`, `count_probes.txt`).

| Group | Function (address) | E/X | Reads; who needs it |
|---|---|---|---|
| Ports | GR_PortOpen 10D0:0000; SetGrPort 10D0:0956; CopyPortBits 10D0:03FA; CopyPortToWindow 10D0:0854 | E, X | port structure; source and destination rectangles. B's shadow copies (B 7.4) |
| Port bitmap swap | GR_PortDataToBitmap 10B8:0E36 (A-B2) | E, X | the old and new bitmap of a port. B moves the shadow inside the bracket (B 7.1) |
| Sheets and colours | LoadGameSpriteSheet 11E0:09D0; ExtractGameSpriteShapes 10E8:231F; InitGameColorTables 10E8:2D46; FlushTileCache 1110:0127 | E, X | sheet handles at ExtractGameSpriteShapes' exit (B 8.5 provenance); colour tables |
| Fonts | CreateCivFonts 1008:0E99 | E, X | the font table (5.10) |
| Movies | StepActiveSequence 10B0:0000; RedrawSequenceWindow 10B0:03B0; AboutMovieCallback 1010:00D6; PumpMessagesCheckSkipInput 11E0:095F | E, X | player structure; the skip result in AL, which callers read (T5, area C). ResyncMovieClock 10B0:14F4 is **not** probed: it is not ported (TRACE.md, "dead, not ported") (RV1-10) |
| Palette fades | CreatePaletteFade 10A8:0000; DestroyPaletteFade 10A8:00B4; StepPaletteFadeIn 10A8:00FC; StepPaletteFadeOut 10A8:018E; ApplyPaletteFadeLevel 10A8:0228 | E | ranges, fade level (area C's fades) |
| Small map, status | PlotSmMapSquare 1210:07AE; DrawMiniPalace 1088:1A82 (A-B2) | E, X | B's macros for the small map and the status window (B 12) |
| Map, for D (A-7) | UpdateUnitSightAndContacts 11C0:0395 (X); DeleteUnit 11C0:16A4 (X); ProcessGameTurn 1088:0000 (E); RedrawMapRect 1208:1534 (E, X) | as listed | D 7.1, 9, 10 (snapshot triggers, macros, mirror checks) |
| Core decisions | RandomBelow 11C8:003D, exits at `ra` 1138:01BD and 1138:03C7 (ShowNewspaper) | X | the chosen value in AX, never `g_randSeed` |

**Area C's rows** (C.11.2, C.20 item 9, accepted as C.20-9). Each was checked with `showfunc.py`:
* the callee is a function start whose FrameDesc is `FR_WIN_FAR` with `far_ret` 1, so every `ra`
  compares in full (RV1-19 offset comparison does not apply);
* the instruction just before each `ra` is the call to that callee.

| Callee (key) | Phases | Call site → `ra` (C's use) | New key? |
|---|---|---|---|
| SetGameCursor 1098:096C | E | 11E0:08D2 → **11E0:08D7** (the core's intro skip, C.6.4); 11E0:0949 → 11E0:094E (Birth skip; WI's row, with its `ra`) | no (WI 10.5) |
| IsKeyPending 11E8:02FB | E | 1220:0AA0 → **1220:0AA5** (MenuZ's key poll: `mz_ready`, C.13.2) | **yes** |
| MenuZ 1220:0156 | E, X (AX: the choice) | 11E0:0724 → **11E0:0729** (title); 10E8:0523 → **10E8:0528** (setup); other callers unfiltered | no (WI 10.2) |
| DestroySequencePlayer 10B0:0287 | E | 11E0:010F → **11E0:0114** (intro movie gone); 11E0:01E3 → **11E0:01E8** (Birth ends) | no (WI 10.5) |
| GR_DialogOpen 1098:124F | E, X | 11E0:003F → **11E0:0044** (dialog 148, `movie_wnd`) | no (WI 10.7) |
| GR_DialogClose 1098:1612 | E | 11E0:0212 → **11E0:0217** (the Load path ends in play) | no (WI 10.7) |
| DrawUnitStackList 11C0:3407 | E | 11C0:334B `push cs`, 11C0:334C `call` → **11C0:334F** (P26 predicate STACK_WOKEN, C.13.3) | **yes** |
| CustomizeWorldDialog 1108:0243 | E, X (as WI) | 11E0:0821 → **11E0:0826** (RunIntroAndTitleMenu's Customize branch: C's CUSTOM state and the fade start, C.7.4, C.11.2) (RV2-2) | no (WI 10.7) |
| RunNewGameSetup 10E8:0000 | E, X (as WI) | 11E0:0205 → **11E0:020A** (RunIntroAndTitleMenu's New Game branch: C's SETUP state, C.8.7, C.11.2) (RV2-2) | no (WI 10.7) |

* **RV2-2.** WI 10.7 filters these two functions only by the GR_DialogOpen calls inside them
  (1108:028B; 10E8:0062 and 10E8:10B9). Those rows stay. The two rows above are the caller-side rows
  C's filter needs; without them `site` is -1 and C never enters SETUP or CUSTOM. The `ra` values
  were checked with `showfunc.py` 11E0:0000 and 11E0:0221 (RV2 claim 6).

* C calls DrawUnitStackList a "near callee". The call instruction is near, but `push cs` makes the
  return far, and its FrameDesc says `far_ret` 1. Its row compares the full 11C0:334F, as for
  1098:1931.
* C's release rule needs IsKeyPending's entry probe to fire before IsKeyPending's PeekMessage takes
  input. That holds: IsKeyPending 11E8:02FB calls ProcessKeyboardMessage, which peeks the
  WM_KEYFIRST..WM_KEYLAST range (showfunc header). A ranged PeekMessage takes host input at its
  start (queue.c:441, F86). So `fr_enter`'s probe sets `mz_ready` first, the sync then releases, and
  the same PeekMessage sees the released keys.

**Exit probes for brackets and exit-time drawing (RV2-1).** Every function whose probe opens a
bracket in another area (B's `PdosMacro`, D's macros), whose scene row closes at exit (`exit` 0 in
B 9.1), or whose exit another area uses ("at exit" in B, C or D) has the X phase. WI's entry-only
phase is widened for the nine functions above. The rule is enforced at build time (6.2, "exit
phases"), and B's `pdos_shadow_macros` refuses and counts a macro whose key has no exit phase as a
configuration error (B 7.3). Widening a phase adds no key; an exit costs one hook call.

**Count.** 175 + 26 + 2 (IsKeyPending, DrawUnitStackList) = **203** distinct keys, under the table's
limit of 256 (4.1). RV2-1's exits and RV2-2's call-site rows add no key. Call-site filters are rows
of `OBS_CALLSITES[]`, not keys, so they do not count. Room is left for the D5..D7 scene renderers.

**Call sites in DOS-PROFILE.md.** The scratch check classified the Windows addresses of DOS-PROFILE.md
and WINDOWS-INVENTORY.md:

* 199 are function entries.
* 140 are call instructions.
* 30 are interior statements.
* 0 are unknown.

RV1 re-checked 38 call sites, all with `ra` = call + 5.

Several of DOS-PROFILE.md's probe values are not function entries. They are `call far GR_DialogOpen`
instructions:

| Address in DOS-PROFILE.md | Function | Return address |
|---|---|---|
| 1010:0024 | ShowAboutBox 1010:0000 | 1010:0029 |
| 1220:00FD | ShowTextDialog 1220:00D2 | 1220:0102 |
| 10E8:0062 | RunNewGameSetup 10E8:0000 | 10E8:0067 |
| 10E8:10B9 | RunNewGameSetup 10E8:0000 | 10E8:10BE |
| 1108:028B | CustomizeWorldDialog 1108:0243 | 1108:0290 |
| 1160:2251 | RequestLeaderAudience 1160:20C0 | 1160:2256 |
| 1170:0651 | ChooseCityProduction 1170:05CA | 1170:0656 |
| 11C0:30BB | ShowUnitStackDialog 11C0:3023 | 11C0:30C0 |
| 10F0:007E | RunTextEntryDialog 10F0:0066 | 10F0:0083 |
| 1098:1931 | RunListBoxDialog 1098:1909, `push cs` + near call | 1098:1934 |
| 11E0:06C0 | IntroMovieCallback (title-menu dialog 139) | 11E0:06C5 |

* These become `OBS_CALLSITES` rows on GR_DialogOpen.
* Other call sites become `(callee, ra)` rows the same way. Examples: SetGodPaletteEntries at
  11E0:0065 → `ra` 11E0:006A; GR_PicRead at 1028:0096 → `ra` 1028:009B.
* Interior statements that are not calls are references, not probes. Examples: the I5 stores 1038:0CB6
  and 1108:0169, and the sparks at 1050:0A9C. Their information reaches the profile through draw
  events and the function's entry probe.
* Fixer F3 restates DOS-PROFILE.md's cells as function start plus call site (K6). A D3 script
  generates `OBS_CALLSITES` from them and the listing (Open A1).

**Records (O5).**
* Each probe is a row of `OBS_PROBES[]` in `present/observe.c`: address, name, phases, handler.
* The same row appears in DESIGN.md 12.x (this table, kept current) and in TRACE.md as
  "observer probe".
* `obs_lint.py` checks that the three lists agree (6.2), and that each address has a FrameDesc in
  `core/gen/civ_frames.c`. That check would have caught 10B0:14F4.

## 5. The read-only query API (O3)

Declared in `platform/w16/w16_obs.h`. These are the only w16 functions `present/` may call.

### 5.1 Functions

| Function | Result |
|---|---|
| `uint64_t w16q_now_us(void)` | `w16_clock_us()` (free) |
| `uint8_t w16q_rd8(vptr_t p, int *ok)`, `w16q_rd16`, `w16q_rd32` | the value, or 0 with `*ok = 0` |
| `uint32_t w16q_read(vptr_t p, void *dst, uint32_t n)` | bytes copied; stops at the tile limit; follows the tiles of one huge block (`first_sel`, `ntiles`, `VM_AHINCR`) |
| `uint32_t w16q_strn(vptr_t p, char *dst, uint32_t max)` | NUL-terminated copy, at most `max - 1` bytes |
| `uint32_t w16q_arg_base(const ObsProbe *c)`, `int16_t w16q_arg16(const ObsProbe *c, unsigned i)`, `uint32_t w16q_arg32(...)`, `vptr_t w16q_argptr(...)` | the i-th argument word, read through the SS reader |
| `uint16_t w16q_ret_ax(void)`, `uint32_t w16q_ret_dxax(void)` | `cpu.ax`, `cpu.dx:ax` (exit probes only) |
| `int w16q_block(uint16_t hglobal, vptr_t *base, uint32_t *size)` | a global block by handle, without GlobalLock (the lock count is core-visible) |
| `int w16q_wnd(uint16_t h, W16qWnd *out)`; `uint16_t w16q_wnd_first(uint16_t parent)`, `w16q_wnd_next(uint16_t h)` (z-order); `w16q_active()`, `w16q_focus()`, `w16q_capture()` | window record copy: class name, style, exstyle, id, parent, owner, window and client rectangles, visible, enabled, text (first 128 bytes) |
| `int w16q_wnd_vis(uint16_t h, W16qRgn *out)` | the window's visible region; `W16qRgn` has the layout of `W16Rgn` (at most `W16_RGN_MAX` 256 rectangles, w16_int.h:30) |
| `int w16q_wnd_client_vis(uint16_t h, int32_t *cx, int32_t *cy, W16qRgn *out)` (A-3) | the client part of the visible region and the client's screen origin. Over `w16_wnd_client_vis` (user_wnd.c:754), which computes into the caller's region and allocates nothing (RV1 claim 31). -1 for an invalid handle |
| `int w16q_sys_track(W16Rect *band_outer, int *width)` (A-3, M) | 1 with the move/size outline rectangle and its width `OUTLINE` (3, user_syscmd.c:79) while the outline is shown; 0 otherwise. 5.2 |
| `int w16q_draw_on(W16Surf *dst, const W16qOp *op)` (A-3, M) | draws one operation on a caller surface; 5.2 |
| `int w16q_btn(uint16_t h, W16qBtn *out)`, `w16q_edit(...)`, `w16q_lb_count(h)`, `w16q_lb_item(h, i, buf, max)`, `w16q_lb_sel(h)`, `w16q_lb_top(h)` | control state |
| `int w16q_menu_state(W16qMenu *out)` | open levels, menus, highlighted items, rectangles |
| `int w16q_menu_item(uint16_t hmenu, int pos, W16qMenuItem *out)` (A-B4, D4) | 1 with the item at position `pos`: flags (MF_GRAYED, MF_DISABLED, MF_CHECKED, MF_POPUP, MF_SEPARATOR), command id or popup handle, raw text (with `&`, at most 64 bytes, user_menu.c:60), display text and mnemonic index as the menu bar draws them; and, when `hmenu` is the bar of a shown top-level window, `has_rect = 1` with the item's screen rectangle. 0 for no such menu or position. 5.2 |
| `int w16q_menu_bar(uint16_t hwnd, uint16_t *hmenu, W16Rect *bar, W16Rect *items, int max)` (A-B4, D4) | the item count of `hwnd`'s menu bar (0: none), its menu, the bar rectangle and each title's rectangle (screen), over `w16_wnd_menu_bar` (user_wnd.c:3527) |
| `int w16q_msgbox(uint16_t hwnd, W16qMsgBox *out)` (A-B3, D4) | 1 when `hwnd` is an open `#MsgBox` whose record is complete: the laid-out lines, the text origin, the icon, each button's id, window and label, and the default button. 0 otherwise. 5.2 |
| `int w16q_dc(uint16_t hdc, W16qDc *out)`, `w16q_bitmap(uint16_t h, W16qBitmap *out)` (`const uint8_t *bits`), `w16q_font(...)`, `w16q_palette(uint16_t h, W16qPal *out)` (`const` entries) | GDI objects |
| `const uint8_t *w16q_screen(int32_t *w, int32_t *h)`, `const uint8_t *w16q_system_rgb(void)` | the virtual screen and system palette |
| `int w16q_cursor(W16qCursor *out)` | current cursor: handle, resource, IDC (`w16_current_cursor` and the cursor table) |
| `const W16qDiag *w16q_diag(void)` | presentation diagnostics |

### 5.2 Queries that need w16 changes (A-3, A-B3, A-B4; K2)

There are two groups. D's two M queries change w16's behaviour-free internals. B's two D4 queries
need read-only accessors only.

**`w16q_sys_track`.**
* No such state exists today. `user_syscmd.c` keeps the outline rectangle only as `movesize`'s
  loop-local `cur` (160, 166). `outline()` (94) XORs the band onto the screen at 208, 276, 282,
  291..293 and 298.
* **Change:**
  * `static W16Rect g_track; static int g_track_on;`
  * `outline(r)` sets `g_track = *r` and toggles `g_track_on`, since each XOR either draws or
    removes the band.
  * `movesize` clears `g_track_on` on every exit.
  * The query reads the two statics.
* They are w16-private, not serialized in any snapshot, and returned by no Win16 API. Core-visible
  behaviour is unchanged (guard: G-1, base tests).

**`w16q_draw_on`.**

> **C passage condensed for the public copy.** The original record has here a block of 10 lines of C declarations: types `W16qOp`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* **Today:** the rasterisers sit inside the DC-bound APIs. `fill_rect` (gdi_draw.c:107) takes a brush
  `W16Obj`; `line` (167) and `plot` (146) are static; `w16_font_text` (gdi_font.c:648) takes a
  `W16Target`; `w16_DrawText` (792) does its layout inline.
* **Refactor:**
  * solid-colour entry points `w16_rast_fill`, `w16_rast_frame`, `w16_rast_line` on a `W16Target`;
  * `w16_rast_drawtext`, DrawText's layout on a `W16Target`;
  * colour-to-physical mapping as a read-only function of the current palette state.
* **Use:** the APIs call these entry points with their DC state. `w16q_draw_on` calls them on a
  `W16Target` built over the caller's `W16Surf` with `screen = 0`.
* `w16q_draw_on` never calls `w16_target_done` or `w16_screen_dirty`. Those are in the Checked
  forbid list (6.1). It allocates nothing and creates no handle.
* **Guard:** G-1. The API paths must give the same pixels, so every core frame hash and checkpoint is
  unchanged. `test_observer.c` also compares `w16q_draw_on` output with the API's on a memory DC.

**`w16q_msgbox`** (A-B3, for B 11.2's message-box re-skin).

> **C passage condensed for the public copy.** The original record has here a block of 8 lines of C declarations: types `W16qMsgBox`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* **State today.**
  * `user_msgbox.c` keeps each open box in a private `MsgBox` record (96..109) on the `g_mb`
    chain (111, linked through `outer`).
  * The labels are `g_label[id]` (113).
* **Accessor.**
  * A new `int w16_msgbox_info(uint16_t hwnd, W16qMsgBox *out)` in `user_msgbox.c`, under
    `#if CIV_OBSERVER`.
  * It walks the chain, finds the record with that `hwnd`, and copies it.
  * It writes nothing in w16 and allocates nothing. `w16q_msgbox` calls it.
* **When it answers.**
  * `w16_MessageBox` creates the `#MsgBox` window (479) **before** it sets `g_mb = b` (484) and
    creates the buttons (486..494). So at the box's `OBS_WND_CREATE` the query returns 0.
  * From the box's `OBS_WND_SHOW` (`w16_ShowWindow`, 497) it returns the complete record.
  * At the end `g_mb = b->outer` (528) comes before `DestroyWindow` (538). So at `OBS_WND_DESTROY`
    it returns 0 again.
  * B reads it at the show and keeps its copy. B 11.2 should say "at `OBS_WND_SHOW`".

**`w16q_menu_item` and `w16q_menu_bar`** (A-B4, for B 11.2's menu bar and drop-down menus).
* **State today.**
  * `user_menu.c` keeps menus in `g_menus[64]` (74), each with up to 48 `MenuItem {flags, id,
    text[64]}` (62..72).
  * The bar's rectangles come from `user_wnd.c`'s `w16_wnd_menu_bar` (3527). It reads `nc_parts` and
    `menu_bar_rects` (1098), which measure with the system font and allocate nothing.
  * The display text and mnemonic come from `menu_display` (1074), which is static.
* **Accessors.**
  * `w16_menu_item_info(hmenu, pos, ...)` in `user_menu.c`, by position, over the private record.
  * `menu_display` is exported unchanged as `w16_menu_display` for the query's display text.
  * A window walk in `user_wnd.c` finds the shown top-level window whose `menu` (Wnd field, 332) is
    `hmenu`, and takes the item rectangle from `w16_wnd_menu_bar`.
  * Under `#if CIV_OBSERVER` except the export.
* **Guard for both groups:** the accessors only read. G-1 and the base tests show no core-visible
  change. `test_observer.c` checks both queries against w16's own MessageBox and menu fixtures.

### 5.3 Guarantees

* **No fault.**
  * `w16q_rd*` repeats `vm_resolve`'s checks (vm.c:517) and returns 0 instead of faulting: selector 0;
    `vm_seg(sel) == NULL`; kinds FREE, FREED and CODE; offset beyond `limit`. SCRATCH is readable.
  * Handle lookups use w16's non-faulting internal getters. `obs_lint.py` checks each against a
    reviewed list.
* **No core diagnostics.**
  * No `acc_chk`, `note_write`, `host_log` or `vm_fault`.
  * Readers do not touch `vm_last_write`, `vm_frame_steps` or the OOB records.
* **No allocation.**
  * Caller buffers or `const` pointers into w16's storage, valid until the next core statement.
  * No `host_alloc`, no handle, no selector.
* **Forbidden addresses.** 1420:4EE0..4EE3 (`g_randSeed`; civ_layout.h:4557) read as 0 with a
  "forbidden" diagnostic (O4).
* **Diagnostics.**
  * `W16qDiag { uint32_t bad_reads, bad_handles, forbidden; struct { vptr_t p; uint16_t probe; } last[16]; }`.
  * The harness writes them to `presentation-diag.log` at the end of the run. Win32 writes them to the
    debug log.
  * They are never in `run.log` or `events.log`.
* **Same behaviour with or without `CIV_CHECKED`** (O1). Nothing depends on Checked-only state.
  `present/` never reads `vm_site` or `vm_steps`.

## 6. Enforcing O4

### 6.1 Checked guard (Checked and Asan builds)

* `int w16_obs_depth;` (w16_obs.c).
* `W16_OBS_GUARD_BEGIN()` and `W16_OBS_GUARD_END()` wrap every call from w16 or the harness into
  presentation:
  * `obs_event`;
  * the probe hook;
  * `present_tick`;
  * `present_input_filter` and `present_input_release`;
  * `present_cursor`;
  * the presentation part of `present_core` (not `host_present`);
  * harness commands.
* **Forbid checks.** `W16_OBS_FORBID(what)` faults with `VM_FAULT_INTERNAL` "O4: what" when
  `w16_obs_depth != 0`. It is placed in:
  * `vm_step` (vm.c:215);
  * `fr_enter` and `fr_leave` entry;
  * `vm_api_enter` (every generated core-to-API adapter);
  * `w16_clock_advance`;
  * `w16_queue_post`, `w16_queue_post_key` and `w16_queue_post_input`;
  * handle and selector allocation (handles.c, vm block allocation);
  * `set_focus_raw`, `w16_SetCapture` and `w16_ReleaseCapture`;
  * key-state and cursor-position writes in queue.c;
  * the Checked write path of `mem_wr*`;
  * `acc_chk`;
  * `w16_present`, `w16_screen_dirty`, `w16_target_done`.
* **Sentinel.** `BEGIN` saves the following, and `END` compares them and faults "O4 sentinel: <field>"
  with the event or probe id:
  * `vm_steps`, `vm_site`, the `cpu` structure, `w16_clock_us()`;
  * the queue's write index;
  * the handle-allocation count;
  * a Checked counter of emulated writes, incremented in `mem_wr*`.
* **Re-entry.** An event emitted while `w16_obs_depth != 0` is a fault in Checked and is dropped in
  Release. Presentation calls no w16 API, so this cannot happen in correct code.
* **Depth after a fault (RV1-14).**
  * `vm_fault` reaches `host_fault`, which may `longjmp` out (host_headless.c 79..81) with the depth
    still set.
  * `obs_init` and `hh_run` set `w16_obs_depth = 0`.
  * `w16_obs_reset()` (a test seam in w16_obs.h) does the same, and the `test_observer.c` fixture calls
    it after each expected fault.
* Release has no guard. The O4 proof for Release rests on identical code paths, the lint and the
  review.

### 6.2 Static check `tests/harness/obs_lint.py` (read-only, Python)

Over `present/**/*.c`, `present/**/*.h` (including `present/map`, `present/dos`) and the probe handlers,
it fails on:

* any `\bw16_[A-Za-z]` that is not `w16q_` (that is, any `w16_<Api>` or internal);
* `VM_SITE`, `VM_API_`, `fr_enter`, `fr_leave`, `vm_step`, `vm_steps`, `vm_site`;
* `mem_rd`, `mem_wr`, `RD_ACC`, `WR_ACC`, `acc_chk`;
* `host_poll_event`, `w16_queue`, `post_event`;
* `g_randSeed`, `0x14204EE0`;
* `cpu.<reg> =`;
* casts that drop `const` from a `w16q_` result.

Area C's rules (C.15.5, C.21 A-6) apply to `present/dos/pdos_*.c` and to the filter part of
`present/input.c`:
* no identifier starting `w16_` other than `w16q_`;
* no `g_randSeed` or `1420:4EE0`;
* no call `RandomBelow(`. Matching the bare name would also forbid probe-row identifiers such as
  `OBS_P_RandomBelow`, which B's or D's handlers of the 4.3 RandomBelow exits may use. The rule is
  narrowed to calls and declarations of the core function.
* no `post_event` or `host_poll_event`;
* no `vm_` symbol (the `ObsProbe` of 4.2 exposes none);
* no `#if CIV_CHECKED`.

It also checks:

* that `OBS_PROBES[]`, the DESIGN.md table and the TRACE.md "observer probe" rows agree, and that every
  probe address has a FrameDesc;
* **exit phases (RV2-1).** Every key that B, C or D needs at exit has the X phase in `OBS_PROBES[]`.
  The lint collects those keys from three forms in `present/` source:
  * the `key` field of every `PdosMacro` initialiser (B 7.3; D's macros through B's names);
  * every `PdosSceneRow` initialiser whose `exit` field is 0, that is a row that closes at the
    entry key's exit (B 9.1);
  * every `OBS_AT_EXIT(OBS_P_<name>)` marker. Each "at exit" consumer (B 5.5's play palette at
    WdwMapOpen's exit, B 12.3's status and unit panels, C's exit transitions, D's exit triggers)
    places this marker, an empty macro in `present/observe.h`, next to its `phase == OBS_EXIT`
    test.

  A key without X fails the lint. At run time `pdos_shadow_macros` also refuses and counts such a
  macro as a configuration error (B 7.3);
* **call-site rows (RV2-4).** The constant arguments of every `obs_callsite(...)` call in
  `present/` name a row of the generated `OBS_CALLSITES[]`;
* that every `w16_target_done(` and `w16_screen_dirty(` call in `platform/w16` lies in a function that
  emits `OBS_DRAW`, or is one of the two funnels;
* that `w16q_draw_on`'s call graph reaches neither funnel.

### 6.3 Unit-by-unit verification (O5)

* An independent reviewer reads each probe handler and each `w16q_*` function.
* One row per unit: what it reads, that it writes nothing in the emulation, and the verdict.
* The record goes to `docs/ext-D3-probe-verification.md`. This is the D3 gate item "probe verification
  recorded". M adds rows for the A-3 queries and D's probes.
* At run end the harness writes `observer-probes.log`, with each probe's enter and exit hit counts. The
  record lists probes the P0 matrix never hit.

### 6.4 The spin test

* `host_sync.c`'s spin test (`vm_steps - g_query_steps <= W16_SPIN_STEPS`, line 191) classifies a
  GetTickCount as a wait or a poll.
* Presentation that counted steps would change Win32 sleeping, and through it the virtual clock under
  `--timing host`.
* Guards:
  * the forbid check in `vm_step`;
  * the sentinel's `vm_steps` comparison;
  * `test_observer.c` case "spin": a GetTickCount loop with probes installed on a callee and an event
    per iteration classifies every query as a wait, exactly as without them.

## 7. The presentation tick (O7)

### 7.1 Call sites

`W16_TICK()` comes right after each `w16_present(0)`:

| Site | Line | Order |
|---|---|---|
| queue.c `w16_PeekMessage` | 445 | `w16_host_sync`, `w16_screen_follow`, `w16_present(0)`, tick |
| clock.c `w16_GetTickCount` | 193 | sync, present, tick, then `w16_clock_advance(W16_COST_POLL_US)`: the tick sees the time before the poll's cost |
| dos.c INT 21h AH=2Ch | 358 | present, tick |
| user_cursor.c `w16_SetCursor` | 149 | present, tick, then the cursor change and `present_cursor` (8.5) |

* This covers every pump and clock query. w16's modal loops pump through `w16_PeekMessage`, and there is
  no GetMessage (RV1 claim 10).
* `GetKeyboardState` and `GetCursorPos` are polls, not pumps. They do not tick.
* The forced presents after RealizePalette and AnimatePalette (gdi_pal.c:271, 310) do not tick. The
  next pump does.
* **Choice: four explicit call sites.** Rejected: tick inside `w16_present`, which would couple it to
  that function's early return and to forced presents.

### 7.2 What a tick does

> **C passage condensed for the public copy.** The original record has here a block of 21 lines of C code (statements or function bodies): functions `present_tick`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* **Frame-size change (A-B6).** The DOS profile changes its frame's size when its kind changes:
  * the 320x200 N frame;
  * the A frame at the virtual screen's size (B 6.3, 6.6), 640x480 before F105 or the screen's
    current size.

  Step 5a handles it like a switch:
  * The host window is never resized (prompt 5.7, 8).
  * The layout is recomputed for the new size. The `--aspect` option applies to 320x200 frames only
    (scale.h 75..76; default 4:3 by X3, section 11).
  * The whole client is redrawn, and the cursor is re-issued. The back end's cursor factors follow
    `present_view_layout()` (host_win32.c `cursor_factors`, 1033), so a re-issue picks up the new
    scale.
  * `present_view_point` maps into the new layout from the next mouse event on.
  * The Windows frame keeps S1's own rule for a game-screen size change (present.c 103..114). That
    code now names `g_win` directly instead of `shown()`, which becomes profile-aware (8.3).
* **Clocks.**
  * Headless: virtual time `w16q_now_us()`, period 16,667 µs.
  * Win32: `host_now_us()` with the period of the window's monitor:
    `EnumDisplaySettingsW(ENUM_CURRENT_SETTINGS).dmDisplayFrequency` of `MonitorFromWindow`, renewed
    on WM_DISPLAYCHANGE and on a monitor change, 60 Hz when it reads 0 or 1. This machine runs 59 Hz.
  * The back end calls `present_set_tick_clock(PRESENT_TICK_HOST, period_us)`.
* The throttle decides only *which* ticks show. Frame content is a function of the event stream and
  the virtual time (T6).
* `g_tick_last` is `present/`'s own state. The tick never reads or writes the gdi_pal statics,
  `hh_frame_count`, the frame lines or `events.log` (1, item 3).
* **Cost when idle.** One clock read, the request check, the profiles' `advance` (which return at once
  when nothing is due), one or two compares. A few ns. PeekMessage runs millions of times in soaks.
* **Tick-history independence.** Ticks happen at the core's polls. Their sequence and virtual times are
  identical in runs with identical core input, whatever the profile. Because every registered profile
  advances at every tick, a profile's state at time t is the same whether it was visible or not. This
  is the basis of 7.4 (13.2).
* **P1** (display rate 70.086 Hz or 60 Hz) is a timeline rate, area C's. The tick is the host display's
  rate, independent of P1. A 70 Hz DOS timeline shown at 60 Hz skips frames as a 60 Hz display would.
* **T6 pause.** During CPU-bound core work without polls, no tick runs and the DOS view pauses. Birth
  inside world generation still ticks at the generator's GetTickCount polls. FIDELITY entry.

### 7.3 Headless presented-frame trace

`presented.log` (with `--presented 1`) keeps S1's lines and adds:

```
presented N tick virtual_us US profile dos w W h H sha256 SHA
presented N view virtual_us US profile P w W h H sha256 SHA        (set_view, options, switch redraw)
   ... [zoom L view CWxCH view_sha256 SHA]    (any show line while the map layer is active; M, A-6)
cursor virtual_us US game LEN sha256 SHA | idc N | pixels WxH hot X,Y sha256 SHA | none   (8.5)
end presents N relation_mismatches M tick_shows T
```

* `N` counts every `host_show` (`hh_show_count`).
* The harness's `shown()` (harness.c:948) tells the lines apart by `present_show_reason()`, which is
  CORE, TICK or VIEW. It replaces the `g_view_attach` flag.
* The S1 relation check applies to CORE shows while the Windows frame is visible, and reads
  `present_core_xrgb()` (8.3).
* `view_sha256` hashes the whole host view buffer (the `present_set_view` bits). It is how hashes name
  the host size and the zoom (D 13, 5.8).
* Switch records are in `profiles.log` (12.2), not here.
* **Choice: same file.** Tick lines go into `presented.log`, which is already outside the base trace.
  Rejected: a separate `ticks.log`, a second file for the same picture stream.
* With the Windows profile visible and the zoom at 0 there are no tick shows. `presented.log` then
  differs from S1's only by the `cursor` lines.
**Frame dumps (`--dump-presented`; A-B8).**
* **Today** the option is civ64's only:
  * `civ64_start.c` 94 parses it, and `civ64_main.c` 201 passes the directory to `hw_set_presented_dir`.
  * `host_win32.c`'s `host_present` (1005) writes `presented-NNNNN.bmp`, 24-bit, of
    `present_shown_frame()`, numbered by core frames (`dump_presented`, 932..).
  * The harness has no such option (`harness_main.c` 50: `--presented 1` only).
  * Revision 1 wrongly called it a harness option; B 6.5 repeats that.
* **After D3, in both back ends:**

  | File | Written at | Content |
  |---|---|---|
  | `presented-NNNNN.bmp` | each `host_present` while the visible profile shows the core frame; NNNNN counts core frames as today | the Windows frame, 24-bit: unchanged from S2 |
  | `tick-NNNNN.bmp` | each TICK or VIEW `host_show` while the visible profile does not show the core frame; NNNNN counts those shows | the shown logical frame: **8-bit** with its 256-entry table when `present_shown_indexed()` gives one (an N frame, from B's `pdos_compose_indexed`, B 6.5), else 24-bit |
  | `view-NNNNN.bmp` (M, A-6) | each show while a map layer is active | the host view buffer, 24-bit |

* The back ends tell the shows apart by `present_show_reason()`.
* Win32 writes the 8-bit form with the writer of `--dump-frames` (`dump_frame`, host_win32.c:869).
* **Harness.** `harness_main.c` gains `--dump-presented DIR`, with the same files written from
  `host_headless.c`'s `host_present` and `host_show`. The 8-bit form uses `hh_write_bmp`
  (host_headless.c:448).
* Dumps are diagnostics. No gate compares them with V0.

## 8. Profiles, switching and the cursor (O6, T2, D-2)

### 8.1 Interface

> **C passage condensed for the public copy.** The original record has here a block of 24 lines of C declarations: types `PresentCursor`, `PresentProfile`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* D4..D7 add renderers *inside* the DOS profile: scenes, N and A canvases, W over N, the DOS pointer.
  The switching code stays as it is.
* A renderer only has to keep its frame current from events, probes, core presents and `advance`, and
  return it from `frame` and `peek`.
* The map module (M, D 3) is shared by both profiles. It is called beside them (8.3, 3.1), not as a
  profile.
* **The DOS profile from D4 on** (`pdos_profile.c`, filled by area B, B 2):

  | Callback | B's function |
  |---|---|
  | `frame`, `peek` | `pdos_compose`'s N or A frame (B 6.3, 6.5) |
  | `indexed` | `pdos_compose_indexed` for an N frame, 0 for an A frame (A-B8) |
  | `cursor` | `pdos_cursor_current()` (A-B7, 8.5) |
  | `shows_core_frame` | 0 always (B 6.3) |
  | `input_frame` | 1 while `pdos_compose` presents the N frame, 2 for the A frame (B 6.6). D3's DOS profile, which shows the Windows frame, gives 2: the frame is the virtual screen, and C's adapters see no N scene |
  | `on_event`, `on_probe`, `advance` | B's handlers, which forward to C's `pdos_seq_on_event/on_probe/advance` (C.21 B-8) |

### 8.2 Registration and switching

* **Registration** (RV1-6).
  * `obs_init` registers the Windows profile always.
  * It registers the DOS profile only when `available()` holds. E's store is activated once, before
    the emulation (E.4.2), and never replaced during the run.
  * An unregistered profile receives no events and is never shown. The DOS profile is therefore
    either current for the whole run (O6, T2) or absent.
  * "Locate DOS files..." does not change this; it acts at the next start (10.2).
* **Requests.**
  * `int present_request_profile(int p, const char **reason)` sets `g_profile_req`.
  * It returns -1 at once with the reason when `p` is not registered: `pdos_assets_message()`, or
    "not in this build" under `CIV_OBSERVER=0`.
  * Callers are the chord, the system menu, `--graphics`, and the harness's `profile` command and
    `--switch-every`.
* **The switch** happens at the next tick (D-2):
  1. `g_visible = g_profile_req`;
  2. the layout is recomputed for the new frame's size;
  3. the whole client is redrawn from the new profile's `peek()` (with `pmap_overlay` from M on),
     reason VIEW, without the throttle;
  4. the cursor is re-issued (8.5);
  5. `g_tick_last = now`;
  6. a `switch` record is written (12.2).
* **The host window is never resized by a switch** (8 "640x480 versus 320x200").
* **Both profiles current** (O6, T2): all registered profiles receive every event, probe and core
  present and advance at every tick. The hidden one keeps its state and its retained frame.

### 8.3 `present_core` and the view functions

> **C passage condensed for the public copy.** The original record has here a block of 16 lines of C code (statements or function bodies): types `GUARD_END`; functions `present_core`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* The core frame trace is therefore the same call sequence in every profile.
* VIEW redraws (`show_all`, switch, options, `present_set_view`) scale the visible frame whole, then
  call `pmap_overlay` (M), then `host_show`.

**Profile-aware view functions (RV1-12).** Today `shown()`, `present_view_point`,
`present_view_layout` and `present_shown_frame` (present.c 27..34, 146..168) use S1's single frame
`g_win`. After D3:

| Function | Reads | Callers |
|---|---|---|
| `shown()` (static) | the visible profile's `peek()`: `g_win` for the Windows profile and for D3's DOS profile, the N or A canvas from D4 on | `relayout`, `show_all` |
| `present_view_layout()` | the layout of the visible frame | host_win32.c `cursor_factors` (1033): the cursor follows the visible frame's scale, as the DOS pointer needs |
| `present_view_point(hx, hy, &lx, &ly)` | maps into the visible frame; `pi_arrive_mouse` stamps the frame kind (10.1) | arrive.c |
| `present_shown_frame()` | the visible frame | host_win32.c `dump_presented` (936) and the new `tick-NNNNN.bmp` dumps (7.3) |
| **new** `present_core_xrgb()` (A-B5) | always `g_win`, the core's XRGB frame, kept current in every profile; read-only; valid until the next core present | harness.c `shown()` (950): the S1 relation check, which compares with `w16_screen()` and the system palette, keeps reading the Windows frame whatever is visible. Area B's A canvas base layer (B 6.2, Choice B3) |
| **new** `present_shown_indexed(&px, &w, &h, rgb768)` (A-B8) | the visible profile's `indexed`, or 0 | the 8-bit dumps of 7.3 |

`present_game_screen(_follow)` keeps computing its own layout from `CORE_W x CORE_H`
(present.c 183..214), not from `shown()`. A switch therefore cannot change the game screen (1, item 2).

### 8.4 The DOS profile in D3 (`present/dos/pdos_profile.c`)

* It is registered when E's store is OK (D2 lands before D3). The harness passes
  `--dos-data build\dosdata` (RV1-5).
* Its `frame` and `peek` return the Windows frame `g_win`, with the damage accumulated since its last
  take. `shows_core_frame()` is 0. Its `cursor` returns 0, which means the game's cursor.
* It therefore shows through the tick path: throttle, tick lines, switch redraws.
* **Choice: show through the tick.** This exercises the tick, the switch and 7.4 before any DOS
  renderer exists. Rejected: show at core presents, which leaves the tick untested until D4.

### 8.5 The cursor route (RV1-7)

* **Today.** `w16_SetCursor` (user_cursor.c 145..158) calls `host_set_cursor(res, len, idc)` at every
  change. `res` is the RT_CURSOR resource inside the module image (user_cursor.c:38), which lives for
  the run. In the DOS profile every core cursor change would put the Windows cursor
  back.
* **Change in user_cursor.c.**
  * The two `host_set_cursor` calls (152..158) become one `present_cursor(res, len, idc)`, with
    `(NULL, 0, 0)` for no cursor.
  * Before it comes `W16_OBS(OBS_CURSOR, ...)`.
  * `g_current` and the return value are unchanged.
  * The header comment (16..20) is updated.
* **`present_cursor`** (present.c, always compiled, inside the guard):
  * it keeps `(res, len, idc)` as the game's current cursor (cleared by `present_reset`);
  * it calls `cursor_issue()`.
* **`cursor_issue()`:**
  * if the visible profile's `cursor(&c, &changed)` returns 1: `host_set_cursor_pixels(c.argb, c.w,
    c.h, c.hx, c.hy)`;
  * otherwise `host_set_cursor(res, len, idc)`, exactly today's call.
* **When the cursor is issued:**
  * at every game cursor change (`present_cursor`);
  * at a switch (8.2 step 4);
  * at a tick when the visible profile reports `changed` (7.2 step 3), for a DOS pointer that changes
    with the scene (OPEN L5, area B/C).
* **New host.h entry (K5).**

  > **C passage condensed for the public copy.** The original record has here a block of 6 lines of C declarations: functions `host_set_cursor_pixels`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

  * **Win32:**
    * keeps a copy, scales it by `cursor_factors` (1031);
    * makes the cursor with `CreateIconIndirect`, a 32-bit DIB colour bitmap plus a 1-bit mask from
      the alpha, hot spot times the factors;
    * remakes it in `refresh_cursor` (1653) as `make_cursor` (1117) does;
    * frees the copy when `host_set_cursor` is called.
  * **Headless:** calls a hook that writes the `cursor ... pixels` line of 7.3.
* **The DOS pointer (A-B7).** The DOS profile's `cursor` wraps B's `pdos_cursor_current()` (B 6.7).
  B builds it from E's shapes (`pdos_shape(PDOS_SH_ICON, 7)` for the torch and
  `pdos_shape(PDOS_SH_ICON, 2)` for the GO arrow, E.9.2; E.9.5 withdrew `pdos_pointer`), the
  cursor-id table and the presented canvas's DAC. The conversion of E's palette indices to ARGB is
  done inside this callback (B 6.7 "Colours"; E.9.5's "area A converts" means this callback)
  (RV2-10).
  * `hidden` → return 1 with `argb = NULL`: the host hides the cursor.
  * Otherwise → return 1 with B's `argb`, `w`, `h`, `hx`, `hy`.
  * `*changed` is 1 when B's `gen` differs from the last one issued. The tick then re-issues the
    cursor (7.2 step 3).
  * The Windows-class cursors of B 6.7 (the scroll arrows 136..143) need the game's RT_CURSOR. For
    them B reports "no pointer of its own": `pdos_cursor_current()` returns NULL (B 6.7, Revision 2),
    and the callback returns 0. This closes Open A11 (RV2-10).
* **Choice: the back end applies the layout factor.**
  * B's image is in logical pixels of the presented frame: the DOS shape at 1x on the N frame, at 2x
    on the A frame (DOS art at 2x, B 6.2).
  * `host_set_cursor_pixels` multiplies by `cursor_factors`, as it does for the game's cursor. That
    is the same rounded layout factor B 6.7 describes.
  * The back end remakes the cursor when the factors change (`refresh_cursor`, after a resize, full
    screen or option change). No tick is needed, and B's `gen` does not change with the window size.
  * Rejected: B scales and the host takes host pixels. B would have to see every layout change,
    which happens outside ticks (WM_SIZE), and the game's cursor and the pointer would be scaled in
    two places.
  * B 6.7's "Scale" bullet changes to match (17).
* **`CIV_OBSERVER=0`:** only the Windows profile exists, so `present_cursor` always calls
  `host_set_cursor`. Behaviour is identical to today.
* **Tests:**
  * `test_present.c`: game cursor, pixel cursor, switch re-issue, `changed` re-issue;
  * 7.2: `host_set_cursor_pixels` scaling and hot spot at 2x2 and 3x3; a game cursor after a pixel
    cursor.

## 9. `CIV_OBSERVER=0`

* Default `#define CIV_OBSERVER 1` in vm.h (included by all w16, rt and core units). `build.cmd checked
  noobs` defines 0 and builds into `build\x64\CheckedNoObs`, `build\obj\CheckedNoObs`. Harness runs go
  to `build\harness\CheckedNoObs\...`.
* **Removed:**
  * events (`W16_OBS*` expand to nothing);
  * the probe table and hooks (vm.c);
  * `W16_TICK()`;
  * the filter stage: `present/input.c`'s body, and the hook in `host_sync.c`, which posts directly as
    before;
  * `W16_TIMING_SCRIPT` and the post hook;
  * `w16_obs.c`, including the A-3 queries;
  * the read-only accessors for `w16q_msgbox` and `w16q_menu_item` (A-B3, A-B4);
  * `present/observe.c`'s body and the DOS profile's registration;
  * the guard.
* **Kept:**
  * S1/S2 `present_core`, scaling, the view; `present_core_xrgb`;
  * `--dump-presented` (only `presented-NNNNN.bmp` occurs, since only the Windows profile exists) and
    the 4:3 aspect default (no 320x200 frame occurs);
  * the cursor route (8.5, Windows only);
  * the arrival stage `present/arrive.c`, always compiled (RV1-13). So host_win32.c links in every
    variant (build.cmd 163), and the S2 rules behave identically;
  * the w16 refactors of K2 (`user_cursor.c`, `user_syscmd.c` state, rasteriser split), which are not
    observer code.
* `--graphics dos`, `--switch-every`, `--host-input`, `--zoom` and the `profile` and `zoom` commands are
  refused with exit code 2 ("not in this build"). The profile chord gets the refusal message (10.2).
* The G-1 comparison (13.3) runs the plain matrix on both builds against the frozen baseline.

## 10. Input placement (I2) and chords (I7)

### 10.1 Two stages in `present/`

**Arrival stage** (`present/arrive.c`, always compiled; `pi_arrive_*`).

It runs when the back end receives a host event, as S2's code does now. It handles:
* chords and the modifier hold rule (10.2);
* mouse mapping into the visible frame and the outside-image press rule (5.7, F100);
* from M on, the map layer (D 12.1);
* focus and capture loss;
* the wheel (I8: never an event; over the map it zooms from M on; ignored in D3).

Its output is 0..8 HostEvents for the ring, at most one host command (`PI_CMD_FULLSCREEN`,
`PI_CMD_PROFILE`, `PI_CMD_ZOOM_IN`, `PI_CMD_ZOOM_OUT`, `PI_CMD_ZOOM_RESET`) with its anchor, and a
capture request. It is portable and pure: state in, events out.

> **C passage condensed for the public copy.** The original record has here a block of 11 lines of C declarations: types `PiKey`, `PiOut`; functions `pi_arrive_key`, `pi_arrive_mouse`, `pi_arrive_wheel`, `pi_arrive_focus_lost`, `pi_arrive_capture_lost`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* **Win32 callers.** host_win32.c's `key_down` (599), WM_KEYUP (2141), `mouse` (729), `release_keys`
  (656), `release_buttons` and, from M on, WM_MOUSEWHEEL call these.
  * They keep the Win32 parts: TranslateMessage and the Windows-1252 character (put in `PiKey.ch`
    before the call), the dead-character loop, `SetCapture`/`ReleaseCapture` on the request,
    `ScreenToClient` for the wheel, and acting on the command.
* **As built (UX4, 2026-10-16; FIDELITY F114; DESIGN.md 12.5).** `PiKey` has a last member `fake` (0 for
  every other source): the Win32 back end sets it when a key message is Windows' own (lParam bit 25,
  `FAKE_KEYSTROKE`, or a Shift release without it followed in the window's queue by a keypad key at the
  same message time). The arrival stage holds such a Shift release back only while it may serve the
  reset chord (observer build, Shift and Ctrl down, Alt up), until the next event: the keypad's 0
  (`VK_INSERT` with scan 0x52, not extended) making the reset drops it, so Shift serves the chord; every
  other next event takes the held release first, so the output is that of before UX4.
* **7.8 mode.** It calls the same functions (12.4).
* **`pi_arrive_mouse` order** (A-4):
  1. From M on, `pmap_layer_point(hx, hy, &pt)` (D 12.1) first. Its kinds are VIEW, COVERED, RING and
     NONE, applied by D's table: a covered press is not delivered (F100), a ring press becomes frame 4.
  2. Otherwise `present_view_point` into the visible frame.
* **The press latch (RV2-3).** A button press fixes the class of its whole action. The arrival
  stage keeps, per button (L, R), the class decided at the press until that button's release:
  * **ring (frame 4).** Every move while the button is held and the release, wherever they happen,
    are stamped frame 4 with the press's square (`x = col`, `y = row`). `pmap_filter_ring` consumes
    the moves and turns the release into the small-map release at the press's point (D 12.2).
  * **layer view (frame 3).** Every move while held and the release are stamped frame 3 at D's
    clamped point (D 12.1: the nearest point of the view, then the nearest visible client point),
    also over the ring and beyond the poles. The core gets the release of the press it got (F100).
  * **not on the layer (frames 0, 1, 2).** Moves while held and the release skip
    `pmap_layer_point` and are mapped by `present_view_point`, clamped to the image as F100 does
    today. They carry the frame visible at their arrival. That is the press's frame unless a profile
    switch came while the button was held; C.12.2's pairing then applies the press's decision (C-11).
  * A move with no button held, or with only a button whose press was not delivered (covered,
    F100), is classified on its own as before. A move while both buttons are held follows the
    button pressed first.
  * Focus and capture loss release the held buttons (as `release_buttons` does today) with their
    latched class and clear the latch.
  * The latch is arrival-stage state, reset by `present_reset`. Under `CIV_OBSERVER=0` there is no
    layer, so only the third class occurs, which is today's behaviour.
* **`pi_arrive_wheel`** (from M on): over `pmap_hit(hx, hy)` it accumulates deltas.
  * Each full 120 is `PI_CMD_ZOOM_IN` or `OUT` with `cmd_hx`, `cmd_hy` = the host point.
  * Elsewhere it does nothing and clears the accumulator.

**`HostEvent.frame`** (K5; A-5). The arrival stage stamps **every** event with the frame its
coordinates belong to. That includes key, character, focus-loss and capture-loss events, which have
no coordinates; they get the frame visible at arrival (C.21 A-1).
* The visible profile names its current frame through a new callback
  `uint8_t (*input_frame)(void)` (8.1). The Windows profile gives 0. The DOS profile gives 1 for an
  N frame and 2 for an A frame (B 6.6).
* From M on, the map layer overrides it for mouse events over the layer (3, 4; D 12.1).
* Frame 1 coordinates are N-canvas pixels 0..319 x 0..199 (`present_view_point` into the 320x200
  frame).
* Frame 2 coordinates are virtual-screen pixels: the A canvas has the screen's size and the Windows
  layout (C4).
* A press outside the image is handled by the arrival stage as today (F100). The filter never sees
  one.

| Value | Meaning | x, y |
|---|---|---|
| 0 | the Windows virtual screen (the Windows frame) | virtual-screen point |
| 1 | the N canvas (320x200) | N point; the filter converts it (I5, area C) |
| 2 | the A canvas | A point; the filter converts it (area B/C) |
| 3 | a map-layer point (M), and every move and the release of a press made on the layer view, wherever they happen (RV2-3) | virtual-screen point (clamped for the parts of a view press); the filter passes it like 0 |
| 4 | a ring square press, every move while a ring press is held and its release, wherever they happen (M, level -1; RV2-3) | `x = col`, `y = row` of the press's square; the filter translates the press and the release at the sync into a small-map click (D 12.2) and consumes the moves |

* The filter converts with the frame stamped at arrival, not the one visible at the sync. A switch
  between arrival and sync therefore cannot misplace a click.
* **Choice.** Rejected: map at the sync from stored host coordinates, which would use a layout the
  user did not see.

**Filter stage** (`present/input.c`, I2..I6; body under `#if CIV_OBSERVER`). It runs at the sync point
in host_sync.c, just before posting:

> **C passage condensed for the public copy.** The original record has here a block of 17 lines of C statements: calls to `w16_host_input_sync_fn`, `host_poll_event`, `GUARD`, `present_input_filter`, `post_event`, `present_input_release`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* The filter only returns events. `post_event` (host_sync.c:113) posts them, so no presentation code
  posts (O4).
* **Which syncs take input** (F86; these are where the filter and the I4 release run):

  | Sync | Site |
  |---|---|
  | a PeekMessage with a message range, at its start | queue.c:441 |
  | a PeekMessage without a range, at its end when nothing was found | queue.c:553 |
  | GetKeyboardState | queue.c:601 |
  | GetCursorPos | queue.c:642 |
  | GetTickCount (`W16_SYNC_CLOCK`) | clock.c:192 |

  A ranged PeekMessage at its end and an unranged one at its start do not take input.
* **The I4 queue's place** (C.13.2). `present_input_release` runs once per input-taking sync, after
  all of that sync's host events have gone through the filter. So:
  * a new user action at the same sync cancels a pending translation before the release is
    considered (C.13.4);
  * the released events are posted after the user's own events of that sync, and before the
    PeekMessage that triggered the sync scans its queue. A ranged PeekMessage therefore sees them at
    once (4.3).
* **Dispatch** (C.12.1, under `#if CIV_OBSERVER`):

  > **C passage condensed for the public copy.** The original record has here a block of 15 lines of C code (statements or function bodies): functions `present_input_filter`, `pdos_adapt_filter`, `present_input_release`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

  * `pdos_adapt_note(ev)` is an addition to C's interface. C.12.1 passes frames 0 and 3 without
    telling C. A user action on the Windows profile, or on D's layer, after a switch would then not
    cancel a DOS translation still pending (C.13.4 "another user action cancels"). Its later release
    could post DOS-derived input after the user's own Windows input. With the note, C applies its
    own action rule (C.12.2) to every frame.
  * **The note's return value (C-11, RV2-5).** The note returns 1 for a later part (a release, a
    repeat, a move while held) of an action whose press C decided on frame 1 or 2 with a decision
    other than "pass". The filter then sends that part to `pdos_adapt_filter`, which applies the
    press's decision: the release of a consumed press is consumed, the release of a 1:1 translation
    becomes the release of the produced key. For every other event the note returns 0 and the event
    takes its frame's path unchanged, so with the Windows profile visible and no DOS action open the
    filter stays the identity (I2). Revision 2's observe-only form and C's fallback are withdrawn.
  * Every call runs inside the guard (6.1). `pdos_adapt_filter` may run the live DOS timelines to the
    sync's time (C.12.1). That is presentation state only; the filter never calls `host_show`.
* Chords and the Alt, Ctrl and Shift hold rule act at arrival (10.2). The filter sees only what the
  arrival stage emits: lone modifiers at their release, with their press first (C.12.3).
* **Windows profile at the default zoom:** the filter returns its input unchanged (I2). Frames 0 and 3
  pass. `test_input.c` checks this for every HostEvent kind.
* **Area C's home.** Adapters, I4..I6, the I5 conversions and D's frame-4 translation live in this
  stage.
* **Choice: two-stage `present/input`, arrival in portable code.** Then the 7.8 mode runs the same
  chord and mouse code as Win32, and I7's chord tests can run headless as 7.8 requires.
  * S2's 7.2 tests through `hw_window_message` stay the regression guard, unchanged in what they
    expect (K4).
  * Rejected: keep the logic in host_win32.c and duplicate it in the harness, which risks divergence.

### 10.2 Chords and the modifier hold rule

**Audit for Ctrl+Shift+Backspace (5.11; DESIGN.md 12.2 audited the rest for S2; D 13 audits the zoom
chords).**

* **Accelerators.** ACCELERATOR 128 has no VK_BACK entry (DESIGN.md 12.2: plain D H J K N P, Ctrl+R,
  Ctrl+0..9, Ctrl+D P F L Q S T).
* **WM_KEYDOWN handlers.**
  * ProcessKeyboardMessage 1098:02D1 queues only TranslateNavKeyToDigit 1208:0000 results (VK
    0x21..0x28).
  * MenuZSubclassWndProc 1220:1289 handles navigation keys only (its WM_KEYDOWN case at 1220:13AA)
    (RV1-19).
  * No handler tests VK_BACK.
* **WM_CHAR.**
  * Backspace's character 08h is a game key. MoveCivUnits 11F0:0000 takes `command = GetQueuedKey()`
    (11F0:0923), and the move switch treats 08h as north-west (11F0:1C40, beside '7').
  * The EDIT control deletes on 08h (user_ctl.c:852).
  * Ctrl+Backspace gives 7Fh on the usual host layouts. Nothing in the core or the EDIT control uses
    7Fh (user_ctl.c:860 ignores it).
  * The chord consumes its key-down with the attached character. The game therefore loses no function:
    plain Backspace, '7' and the keypad still move north-west.
* **WM_SYSKEYDOWN / WM_SYSCHAR.** None in the core (DESIGN.md 12.2).
* **GetKeyboardState.** Only Num Lock (1008:02E6, 033D). GetKeyState is not used by the core (grep of
  `claude/src`).
* **Finding: modifiers skip movies.** PumpMessagesCheckSkipInput 11E0:095F treats *any* WM_KEYDOWN as
  skip input (11E0:0973). It is called by IntroMovieCallback (`frame % 20`), BirthMovieCallback
  (`frame % 30`) and AboutMovieCallback (`frame % 30`).
  * Without a hold, the chord's Ctrl and Shift presses reach the game before Backspace arrives.
    Switching the profile during the intro would then also skip the intro.
  * That contradicts T2, under which a switch shows the other timeline at the same time.
* **Dialog manager and DOS adapters.** w16's IsDialogMessage (user_dlg.c 39..46, 794) handles Tab,
  arrows, Enter and Escape, not Backspace. The DOS adapters (DOS-PROFILE.md 1.7) use no Ctrl+Shift
  combination. Recheck when area C fixes the adapter keys (Open A3).

**Choice: the modifier hold rule (decision K3: accepted).** It extends S2's Alt rule (F101) to Ctrl and
Shift.

* A Ctrl or Shift press, and its repeats, is held back until the next key event.
* **Chord.** Backspace while Ctrl and Shift are down and Alt is not (and, from M on, D 13's zoom keys):
  * the command;
  * neither the held presses, nor the chord key's press, repeats and release, nor the held keys'
    later releases reach the game;
  * only a press without the repeat bit acts.
* **Another key**, including after a chord: the held presses are delivered first, in press order, then
  the key. The game sees Ctrl+S, Shift+letter and accelerators exactly as before.
* **A held key released alone:** its press and release are delivered together. A lone Ctrl or Shift
  still skips the intro, at its release instead of its press. This keeps the user's direction
  (2026-10-10 11:35) "any key during the credits or intro jumps to the title menu".
* **Mouse press:** held keys are delivered first.
* **Mouse events while a key is held (RV1-15).**
  * Today host_win32.c:763 copies MK_SHIFT and MK_CONTROL from the host into every mouse event's
    `buttons`.
  * While a Ctrl or Shift press is held back, `pi_arrive_mouse` clears the bit of each held key in
    moves and releases. The core never sees a modifier flag before its key-down.
  * A press first flushes the held keys and then carries the host's bits.
* **Focus loss:** held keys are dropped, as they were never delivered. Delivered keys are released as
  today, with the Tab rule for a delivered Alt.
* **Key state stays consistent.** Every delivered press has a delivered release.
* **Caveat.** `GetKeyState` between a press and its delivery would read up. The core does not call it.
  w16's own readers of the posted key state see the flushed modifier before the key that follows:
  * IsDialogMessage's Shift+Tab (`w16_queue_key(VK_SHIFT)`, user_dlg.c);
  * TranslateAccelerator's Shift, Ctrl and Alt (`w16_queue_key`, user_misc.c 385..387);
  * host_sync.c's keypad rule (`g_down`).
* **FIDELITY**, next to F101: the late delivery and the masked MK bits. Listed for the user's check:
  the user's S2 check covered Alt+Enter only (K3).
* Alternatives rejected:
  * Deliver modifiers at once: the chord would skip movies.
  * Consume modifier presses in the I2 filter during movies: that changes game input semantics.
  * Choose a chord without Ctrl or Shift: the prompt fixes the chord.
* Alt+Enter keeps S2's behaviour exactly.

**Chord action (RV1-6, RV1-8).**
* `PI_CMD_PROFILE` → the back end calls `present_request_profile(other)`.
* **On refusal:**
  * The first refusal in a run shows one `host_message`. Its text is E's message alone
    (`pdos_assets_message()`, E.4.3), then: " To use them, choose \"Locate DOS files...\" in the window
    menu; the DOS graphics become available the next time civ64 starts."
  * Later refusals in the run only beep (host MessageBeep).
  * Under `CIV_OBSERVER=0` the text is "The DOS graphics are not in this build."
* E.4.3's "once per chord press" is corrected to this cadence.

**Locate DOS files... (RV1-6).**
* `SC_CIV_DOS_LOCATE` calls a civ64 hook (`hw_set_locate_hook`, beside the settings hook) running the
  new `civ64_locate_dos_choose(const Civ64Where *w, Civ64Cfg *cfg)` in civ64_locate.c. It is
  `ask_dos`'s choose-and-validate loop (806..838) without the "not found" question:
  * `pick` (738);
  * `use_path` validation; an invalid choice is refused and asked again;
  * cancel ends it;
  * a valid choice sets `dos_data`, removes `dos_ask=never`, `civ64_cfg_save`, and frees the
    temporary `Civ64Found`.
* Then one message: "The DOS files are recorded. The DOS graphics become available the next time civ64
  starts."
* E's store is not reopened. The running game and its profiles are untouched.
* The system menu's modal loop holds the game thread meanwhile, as recorded at S2 (D22).

## 11. Command line, settings and system menu (5.11)

* **`--graphics windows|dos`** (civ64_start.c).
  * An invalid value exits with code 2.
  * With `dos` and the DOS files unavailable it exits with code 2 and E's message (E.3.3 step 3,
    E.4.3).
  * Without the option, the settings key `graphics` (`windows`|`dos`; anything else reads as absent)
    gives the start profile. With nothing remembered it is `windows`.
  * A remembered `dos` that is unavailable starts `windows` without a message (phase R's rule for a
    missing remembered DOS location).
* **Settings key `graphics`** (K7: prompt 2.1 "Settings file" lists the last graphics profile).
  * The settings hook writes it when the player switches by chord or menu. A refused switch does not
    write it.
  * The command line wins for the run and is not written (DESIGN.md 12.2).
* **`--zoom default|-1|0|+1`** and the settings key `zoom` come from M, as D 13 and decision C1
  define. The harness `zoom` command calls `pmap_request_zoom` (A-8).
* **`--aspect` default 4:3 (decision X3).** The user's direction says the start-up screens "shall
  stay 4:3". The DOS profile shows them as 320x200 N frames.
  * **civ64.** The order stays: the command line, then the remembered `aspect` key (the user's D7),
    then the default. The default at `civ64_main.c:223` becomes `PRESENT_ASPECT_4_3`, and the
    comment at 209 is updated.
  * **Harness.** `harness_main.c` 453..456's default becomes 4:3 as well, so headless DOS runs lay
    out as civ64 does.
  * **Effect.** The 4:3 aspect acts only on 320x200 frames (scale.h 75..76: "640x480 frames always
    have square pixels"; A frames likewise, B 6.6). Only the DOS profile shows 320x200 frames. So the
    Windows profile's layout, `presented.log` lines, S1/S2 outputs and the game screen
    (`present_game_screen`, from `CORE_W x CORE_H`) are unchanged.
  * The system-menu item "4:3 aspect for 320 x 200 pictures" (host_win32.c:1779) shows the setting as
    before.
  * FIDELITY records the change, and it is listed for the user's check (decision X3).
* **System menu** (`add_menu`, host_win32.c:1758). After "Full screen", before the separator and
  About:

  | Id | Item | Type |
  |---|---|---|
  | — | separator | |
  | `SC_CIV_PROF_WIN 0x1090` | "&Windows graphics\tCtrl+Shift+Backspace" | radio |
  | `SC_CIV_PROF_DOS 0x10A0` | "&DOS graphics\tCtrl+Shift+Backspace" | radio |
  | `SC_CIV_DOS_LOCATE 0x10B0` | "&Locate DOS files..." | records the choice for the next start (10.2) |
  | — | separator | M |
  | `SC_CIV_ZOOM_OUT 0x10C0`, `SC_CIV_ZOOM_DEF 0x10D0`, `SC_CIV_ZOOM_IN 0x10E0` | D 13's items | radio, menu anchor the centre (A-8) |

  * `hw_update_menu` (1736) checks the visible profile and the zoom level.
  * The DOS item stays enabled; choosing it when unavailable shows the refusal message (10.2).
  * The ids are the next free multiples of 16 below 0xF000. 0x1030 stays unused, to avoid confusion
    with the removed stretch item.

## 12. Harness (tests/headless)

### 12.1 Commands (not input)

New script lines, applied in `step()` at `VM_STEP_API` when due (harness.c:868, the same scheduling as
events) inside the guard:

```
at <ms> profile windows|dos|toggle
at <ms> policy integer|fit [nearest|sharp] [square|4:3]
at <ms> hostsize <W>x<H>
at <ms> zoom -1|0|+1|reset                (from phase M: pmap_request_zoom; before it: error, exit 2)
```

* They call only `present_request_profile`, `present_set_options`, `hh_set_view` and
  `pmap_request_zoom`.
* A refused profile or zoom request is recorded and does not fail the run: `switch ... refused` in
  `profiles.log`, `zoom refused` in `presented.log`.

### 12.2 Options and logs

| Option | Meaning |
|---|---|
| `--dos-data PATH` | E.3.4: the DOS source for E's store; every DOS run passes `build\dosdata` (RV1-5) |
| `--graphics windows\|dos` | start profile; `dos` without a working store exits 2 (E.4.3) |
| `--switch-every <ms>` | a toggle request at every multiple of `<ms>` virtual time (7.3: 997) |
| `--profile-samples <ms>` | at the first tick at or after every multiple of `<ms>`, every registered profile's `peek()` hash, and from M on each profile's map-layer hash when the level is not 0 (A-6) |
| `--host-input <file>` | the 7.8 mode (12.4) |
| `--core-input-log 1` | `coreinput.log`, every posted core input (12.4) |
| `--dump-presented DIR` | new in the harness (A-B8): the frame dumps of 7.3, as civ64 writes them |
| `--aspect square\|4:3` | existing; the default becomes 4:3 (X3, section 11) |

**`profiles.log`** is written whenever `--graphics`, `--switch-every`, `--profile-samples` or a
`profile` command is used:

```
start virtual_us US profile P registered windows[,dos]
request virtual_us US to P
switch virtual_us US from A to B
switch virtual_us US refused B: <reason>
sample K virtual_us US windows SHA [dos SHA] [map windows SHA dos SHA]
end requests R switches S refused F pending P
```

* `--presented 1` and `--host-size` are kept (S1).
* `presentation-diag.log` and `observer-probes.log` are written when present.
* **Area C's logs** (C.21 A-4): `timeline.log` and `adapt.log`, beside `presented.log`, written only
  under `CIV_OBSERVER` and only when the DOS profile is registered.
  * C fills them through `void present_log(int which, const char *line)` (`PRESENT_LOG_TIMELINE`,
    `PRESENT_LOG_ADAPT`).
  * The harness writes each line to its file. Win32 drops them (no files in civ64).
  * Neither is part of the base trace (12.3).
  * `adapt.log` lines that record a release carry the input-sync ordinal `sync N` as well as the
    virtual time (12.4).
* E writes `dos-assets.log` (E.3.4).

### 12.3 What P0 compares

* The base trace is `run.log`'s `frame ` lines, its `snapshot ` and `result ` lines, and `events.log`
  (`ext_g1.py`'s definition).
* Nothing in 12.1 or 12.2 writes to them.

### 12.4 The 7.8 mode

* `--host-input <file>` sets `w16_host_timing = W16_TIMING_SCRIPT` (CIV_OBSERVER only). In
  `w16_host_sync` that mode takes input (poll, filter, post) and skips the clock part: no host time, no
  sleep, the virtual clock as in the harness.
* Host-form lines:

  ```
  at <ms> hkey down|up <vk> <scan> [ch <hex>] [repeat] [alt] [ctrl] [shift]
  at <ms> hmouse move|ldown|lup|rdown|rup <hx> <hy> [buttons <hex>]   (host client pixels; MK_ bits)
  at <ms> hwheel <delta> <hx> <hy>
  at <ms> hchar <hex>
  at <ms> hfocus lost
  at <ms> hcapture lost
  at <ms> hquit
  ```

  The commands of 12.1 may appear too.
* **Lines at a sync** (Open C-1 of C.15.4). Any host-form line may start with `sync <n>` instead of
  `at <ms>`.
  * Its events go through arrival and into the ring at the start of the n-th input-taking sync of the
    run, just before that sync polls the ring (the `w16_host_input_sync_fn` hook, 10.1).
  * So they are posted at exactly that sync.
  * `g_input_syncs` counts input-taking syncs only. It is w16-private and never core-visible.
  * **Why.** A virtual-time line posts at the first input-taking sync at or after its time. Several
    syncs can share one virtual time. A PeekMessage that finds a message costs no virtual time; only
    a FALSE result is charged (`W16_COST_PEEK_FALSE_US`, queue.c:552). IsKeyPending's loop of ranged
    peeks while messages remain is an example. Then no `at <ms>` line can target the later sync.
  * `ext_adapt.py` therefore writes the Windows-form events of an I4 release as a `sync <n>` line,
    with n from the DOS-form run's `adapt.log`. The ordinals agree in both runs up to that sync,
    because their core input agrees up to there; that is what the test checks.
* **Arrival.** At `VM_STEP_API`, due lines go through `pi_arrive_*`, with the headless view's layout
  (`present_view_point`, and from M on `pmap_layer_point`) as Win32's arrival uses them. The output
  enters the headless ring (`hh_push_event`, host_headless.c:492). Commands go to the same handler as
  Win32's.
* **Posting.** At the game's next sync point that takes input, `host_poll_event` → filter →
  `post_event`, exactly as in Win32 (F86 rule included).
* **Core-input log.**
  * `w16_host_post_fn` (host_sync.c, CIV_OBSERVER only) receives each posted message from `posted()`.
  * The harness writes `post virtual_us US msg MMMM wparam WWWW lparam LLLLLLLL x X y Y ch CC` to
    `coreinput.log`.
* `hwnd`-form scripts cannot be fed in this mode (X0 review B1.8). 7.8 scripts are new, in host
  coordinates.

## 13. Tests

### 13.1 7.3 P0 runner `tests/harness/ext_p0.py`

**Runs.**
* Every row of `scenarios.py`'s `SCENARIOS` (23 on 2026-10-11). Scripts and options are built with
  `scenarios.py`'s own helpers.
* gate3b's S2, S2b, S2c and S3, with their checkpoints.
* S4 and S5 (`mksoak.py`).
* S1 is read as the start-up run (`run-startup.cmd`, also the `start` scenario). Open A4.
* Run ids are `p0-<var>-<name>`, under `build\run` and `build\harness\<variant>\p0\<var>\<name>`, so p4
  and gate3b outputs are not touched.

**Variations (Checked).** Every variation that involves the DOS profile passes `--dos-data
build\dosdata` (RV1-5).

| Var | Options | Notes |
|---|---|---|
| V0 | none | reference; where a run exists in `ext-g1-baseline.txt` it must also equal that |
| V1 | `--dos-data build\dosdata --graphics dos` | |
| V2 | `--dos-data build\dosdata --switch-every 997` | |
| V3 | commands every 1,499 ms cycling `policy fit sharp 4:3`, `policy integer`, `hostsize 1024x768`, `1920x1080`, `641x481`, `800x600` | the run's own `--game-screen WxH` or none, never `view` (K1, scoped P0) |
| V4 | `--host-size 1920x1440` and `zoom` commands every 1,301 ms cycling +1, -1, reset, 0 (D 16.4) | from M on; with the DOS profile from D6 |
| V5 | CheckedNoObs build, V0 options | G-1's observer-free comparison |
| V6 | `--dos-data build\dosdata --game-screen view --switch-every 997` on S3 and `orders` | profile only; shows the game screen does not depend on the profile |

**Comparison.**
* For each run and variation:
  * the `frame ` lines (index, virtual time, hash) in order;
  * the `snapshot ` lines (checkpoint hashes of images, emulated stack and global blocks);
  * the `result ` line;
  * the whole `events.log`;
  * the exit status.
* All must equal V0. The first differing line is printed. P0_OK or P0_FAILED=n.
* **Switch assertions (RV1-5)**, from `profiles.log`:
  * V1: `registered windows,dos`, start profile `dos`, `refused 0`.
  * V2 and V6: `refused 0`, `switches >= 1`, and `switches + pending == requests`: every request
    became a switch at the next tick, or was still pending when the run ended.
  * A run that fails these fails the variation, even with equal base traces.
* Presentation outputs (`presented.log`, `profiles.log` samples, frame dumps) are not compared with V0.
* **Matrix size** (X0 D29):
  * D3 gate: scenarios + S1..S3 × V0, V1, V2, V3, V5, V6;
  * X9: everything including S4/S5 × all variations.
* Runs are independent processes, so the runner may run up to cores/2 in parallel. Builds stay
  serialized by the orchestrator.

### 13.2 7.4 frame determinism `tests/harness/ext_frames.py`

* Runs, all with `--dos-data build\dosdata --profile-samples 100 --presented 1`, on S1, S3 and `birth`:
  * A `--graphics dos`;
  * A' (A again);
  * B `--switch-every 997`;
  * C windows.
* **Checks:**
  1. The `sample` lines of `profiles.log` of A, A', B and C are identical: every registered profile's
     frame at each sample, shown or not.
  2. `presented.log` of A equals A'.
  3. The switch assertions of 13.1 hold for A and B.
  4. The core input is identical by construction: same scripts, direct posting (X0 D28).
* In D3 the DOS frame is the Windows frame, so the checks hold trivially and exercise the mechanism.
  From D4 on they test the DOS timelines. From M on the samples include the map layers (D 16.3).

### 13.3 G-1

* `ext_g1.py check` passes on the D3 Checked build and on CheckedNoObs (V5).
* `test.cmd` passes in Checked and Release.
* The Asan part is deferred to the end of the queue (user, 21:20; K8) and recorded as "Asan deferred".
* For the K2 refactors (cursor route in D3; outline state and rasteriser split in M), G-1 is the guard
  in the phase that makes them.

### 13.4 Unit tests and checks

* **`tests/test_observer.c`** (headless; every variant; observer cases skipped in CheckedNoObs):
  * table install, lookup, collisions, 256 entries, a refused duplicate;
  * hooks with BP and FR_NONE frames: argument base and values; exit with AX where written; `ra`;
    near-callee offset comparison;
  * readers: selector 0, FREE, FREED, CODE, beyond the limit, a huge-block crossing, `g_randSeed`. Each
    gives a defined 0, a diagnostic count and no fault. In Checked, the OOB records and `vm_last_write`
    are unchanged;
  * `w16q_wnd_client_vis` against `w16_wnd_client_vis`;
  * from M on: `w16q_sys_track` during a scripted move loop; `w16q_draw_on` against the API's pixels on
    a memory DC for each operation;
  * from D4 on: `w16q_msgbox` on a MessageBox fixture with one, two and three buttons, and a nested
    box. It returns 0 at the box's `OBS_WND_CREATE` and at its `OBS_WND_DESTROY`, and the complete
    record from its `OBS_WND_SHOW` on;
  * from D4 on: `w16q_menu_item` and `w16q_menu_bar` on a class-menu fixture: flags after
    EnableMenuItem and CheckMenuItem, separators, popups, display text and mnemonic, bar rectangles
    equal to the rectangles `w16_wnd_menu_bar` gives;
  * spin (6.4);
  * O4 traps in Checked: a test probe that calls `vm_step`, posts, advances the clock or calls
    `w16_screen_dirty` faults with "O4". `w16_obs_reset()` runs after each (RV1-14);
  * one event of each type through w16 fixtures: create a window and a dialog, draw, palette (ANIMATE
    after the change, with `moved`), cursor, sound, listbox, edit, menu tracking. The recorded sequence
    matches the expected one;
  * re-entry is dropped or faults.
* **`tests/test_input.c`** (area A's file; C.15.2 adds C's pairing, I4, I5 and adapter-row cases):
  * the filter dispatch by frame (10.1): 0 and 3 identity, 1 and 2 to a stub adapter, 4 to a stub ring
    filter; `pdos_adapt_note` called for frames 0, 3 and 4 when the DOS profile is registered;
  * C-11 (RV2-5): when the stub note returns 1, the event goes to the stub adapter and not to its
    frame's path; with C's real note, the frame-0 release of a press consumed on frame 1 goes to
    `pdos_adapt_filter` and is consumed;
  * the press latch (RV2-3), with a stub `pmap_layer_point`: a ring press then moves over the view and
    a release over the view (all frame 4, the press's square); a ring press released beyond the poles
    and outside the layer (frame 4); a view press released on the ring and beyond the poles (frame 3
    at the clamped point); a press off the layer moved across the layer (never frame 3 or 4); focus
    loss during a ring press (a frame-4 release);
  * key, character and focus events stamped with the visible frame (10.1);
  * `present_input_release` returns 0 with no DOS profile registered;
  * S2's Alt cases moved;
  * Ctrl and Shift hold, the chord (press, repeats, release, then another key flushing the held keys in
    order), Ctrl+S, Shift+letter, a mouse press flushing;
  * moves and releases with masked MK bits while held (RV1-15);
  * focus loss dropping;
  * the wheel produces nothing in D3, and from M on anchored zoom commands;
  * the outside-image press and its release (F100);
  * the filter is the identity for the Windows profile, frames 0 and 3;
  * `HostEvent.frame` stamping.
* **`tests/test_present.c`** additions:
  * the tick throttle (virtual), the switch at the next tick, show reasons;
  * a refused switch and an unregistered profile;
  * samples;
  * `present_core` calling `host_present` exactly once whatever the profile;
  * the view functions under each profile, with `present_core_xrgb` always `g_win` and current before
    any `on_core_present` (A-B5);
  * re-layout on a frame-size change (A-B6): a test profile switches its frame between 320x200 and
    640x480. The host size stays fixed. The client is redrawn whole, a fixed client point maps into
    each frame, and the cursor is re-issued;
  * the 4:3 default applied to a 320x200 frame and not to a 640x480 one (X3);
  * `present_shown_indexed` through a test profile's `indexed` (A-B8);
  * `present_game_screen(_follow)` equal under both profiles and every zoom level (1, item 2);
  * the cursor route (8.5).
* **7.2** (Win32-headless, `test_host_win32.c`):
  * S2's cases unchanged;
  * Ctrl+Shift+Backspace through `hw_window_message` puts nothing in the ring and toggles the request;
  * the menu radio items;
  * the one message, then beeps (test seam for quiet messages);
  * Locate records `dos_data` through a test seam and does not reopen the store;
  * `host_set_cursor_pixels`;
  * `--dump-presented`: `presented-NNNNN.bmp` unchanged under the Windows profile; `tick-NNNNN.bmp`
    8-bit for an indexed test frame and 24-bit otherwise (A-B8).
* **Harness `--dump-presented`** (A-B8): the same files headless.
  * D3 gate: one short run of the `start` scenario with `--dos-data build\dosdata --graphics dos
    --dump-presented DIR` writes `tick-NNNNN.bmp`, 24-bit, since D3's DOS profile has no `indexed`.
  * From D4 on, the same run writes the N frames 8-bit. A check reads the BMP header's bit count.
* **7.8 for I7** (`ext_adapt.py`; area C adds DOS-form scripts; D adds wheel and ring scripts, D 16.5):
  * S3 in host form with chords inserted against the same script without them:
    * Ctrl+Shift+Backspace during the intro, during Birth, in the leader-name EDIT control and in
      play;
    * Alt+Enter;
    * later the zoom chords;
  * `coreinput.log` (message sequence and times) and the checkpoints must be equal;
  * the intro reaches the title menu at the same virtual time (no skip); the name text is unchanged.
* **`obs_lint.py`** (6.2) runs in `test.cmd` (read-only, Python).

## 14. Rule coverage

| Rule | How met | Test |
|---|---|---|
| P0 | section 1, scoped for size and policy (K1) | 13.1 (all variations, with switch assertions), 13.3, Checked sentinels |
| 5.1 layers, host.h | section 2; `HostEvent.frame`; `host_set_cursor_pixels`; `host_show` as the composed-frame present | build; `obs_lint.py` |
| 5.1 two hashes | S1 relation at CORE shows through `present_core_xrgb` | HARNESS_PRESENT_MISMATCH in every 13.1 run with the Windows profile visible |
| 5.3 damage, layer | `frame(&damage)`; the tick shows layer damage (A-1); `pmap_overlay` in CORE, TICK and VIEW shows (A-2) | 13.2; D 16.3 |
| O1 events, virtual time, `CIV_OBSERVER`, Checked independence | section 3; `t_us`; section 9; 5.3 "same behaviour" | `test_observer.c` events; V5 |
| O2 probes | section 4 | `test_observer.c`; `observer-probes.log` coverage |
| O3 reading | section 5 | `test_observer.c` readers, the A-3 queries and B's `w16q_msgbox`, `w16q_menu_item` |
| O4 forbidden | section 6 | Checked traps, sentinel, `obs_lint.py`, spin case |
| O5 records | 4.3 records; 6.3 | `obs_lint.py` list agreement; `ext-D3-probe-verification.md` |
| O6 concurrency | 8.1, 8.2: every registered profile gets every event, probe, core present and tick | 13.2 check 1 |
| O7 tick | section 7 | `test_present.c` tick; `presented.log` tick lines; 13.1 frame lines unchanged |
| T1 start points | probes on RunIntroAndTitleMenu 11E0:0000 and SeekSequence 10B0:005B (frame 1000) deliver them | area C's 7.7 |
| T2 both timelines advance | `advance` at every tick for every registered profile; tick-history independence (7.2) | 13.2 |
| T5 skip ends all, I6 | the filter stage is their home (10.1); probes on the skip functions | area C's 7.7, 7.8 |
| T6 free clock, pure frames, pauses | `w16q_now_us`; frames from (events, ticks); FIDELITY note | 13.2 |
| I1 | only the arrival stage creates events, from host events; the I4 queue releases only user-created translations at syncs | `test_input.c`; area C |
| I2 placement | 10.1 | `test_input.c` identity; 13.4 7.8 |
| I4 release placement, I5 frames | 10.1: the release runs once per input-taking sync, after the filter; frames stamped at arrival | `test_input.c` (A's and C.15.2's cases); C.15.4 with `sync <n>` lines |
| I7 chords | 10.2 | `test_input.c`; 7.2; 7.8 chord pairs |
| I8 wheel | arrival stage: never an event; zoom over the map from M on | `test_input.c` |
| 5.7 cursor and mapping | profile-aware view functions (8.3); re-layout on a frame-size change (7.2, A-B6); the cursor route with B's pointer (8.5, A-B7) | `test_present.c`; 7.2 |
| 5.7 / 8 "640x480 versus 320x200" | frame-size change re-lays out without resizing the window (7.2); 4:3 default for 320x200 frames (11, X3) | `test_present.c` |
| 5.11 | section 11; `--dump-presented` with 8-bit N frames (7.3, A-B8) | `test_start` option cases; 7.2 menu and dump cases; harness dump run |
| D-2 | 8.2; 13.1 switch assertions | 13.1, 13.2 |
| D-3 pointer | 8.5 (route); the pointer itself is D4's | 7.2, `test_present.c` |
| 7.3 | 13.1 | P0_OK |
| 7.4 | 13.2 | equality checks |
| 7.8 | 12.4, 13.4 | `ext_adapt.py` |
| G-1 | 13.3 | EXT_G1_OK on both builds; Asan deferred |

## 15. Choices (summary)

1. **Probe lookup:** a 2048-slot hash keyed by `fd->addr` in vm.c, at most 256 probes. Not a `FrameDesc`
   field, binary search or the mark filter.
2. **Call-site probes:** callee probe plus an `ra` table, offsets only for near callees. Not statement
   probes, which are impossible in Release.
3. **Hook placement:** the end of `fr_enter` after the frame, the start of `fr_leave`. Not before the
   pushes, where arguments are not yet framed.
4. **Damage events in the two funnels, detail events per API.** Not a changed `w16_target_done`
   signature.
5. **A separate observer channel.** Not an extension of `w16_trace_fn`.
6. **Queries implemented in w16 (`w16q_*`), the only w16 calls present/ may make.** Not exported
   internals.
7. **Tick at four explicit sites after `w16_present(0)`.** Not inside `w16_present`.
8. **Tick clock:** virtual 16,667 µs headless, the monitor refresh in Win32 (X0 D13).
9. **Tick lines in `presented.log`** with show reasons; switch records in `profiles.log`. Not a separate
   tick file.
10. **Every registered profile advances at every tick (history independence).** Not lazy advance of the
    visible profile only.
11. **The D3 DOS profile shows the Windows frame through the tick.** Not at core presents.
12. **The switch redraws the whole client at the next tick, without the throttle.**
13. **Two-stage `present/input`:** arrival in the always-compiled `arrive.c`, shared by Win32 and 7.8;
    filter in host_sync.c. Not duplicated arrival code.
14. **`HostEvent.frame` stamped at arrival** (0..4). Not mapping at the sync.
15. **The modifier hold rule for Ctrl and Shift, with MK bits masked while held.** Not immediate
    delivery, and not filter-side consumption.
16. **One message per run for an unavailable profile, then beeps.**
17. **The profile is remembered in `graphics`** (prompt 2.1). Not always `windows`.
18. **Menu ids 0x1090, 0x10A0, 0x10B0** (and D's 0x10C0..0x10E0). Not reuse of 0x1030.
19. **Harness commands at `VM_STEP_API`.** Not at ticks.
20. **7.4 by samples at ticks of every profile's `peek()`.** Not comparison of shown frames only.
21. **The 7.8 mode as `W16_TIMING_SCRIPT`, arrival at `VM_STEP_API`, posting at syncs.**
22. **Checked guard: depth, forbid list and sentinel.** Not lint alone.
23. **Registration once in `obs_init`; an unavailable profile is absent for the run** (RV1-6). Not
    mid-run activation.
24. **Cursor:** the profile decides at every issue; pixels through `host_set_cursor_pixels`, scaled
    like the game's cursor. Not converting the DOS pointer into an RT_CURSOR resource, which is 1-bit
    and cannot hold the pointer's colours.
25. **`w16q_sys_track` from statics toggled in `outline()`.** Not suspending the layer during the move
    loop (D 5.2).
26. **The back end applies the layout factor to the DOS pointer** (8.5). B supplies it at frame scale.
    Not B scaling to host pixels.
27. **Re-layout on a frame-size change in the tick, without the throttle, like a switch** (7.2, A-B6).
    Not waiting for a host resize.
28. **Dumps written by the back ends at the shows** (`presented-` at core presents, `tick-` at tick
    and view shows, 8-bit through `indexed`) (7.3, A-B8). Not one file name for both kinds.
29. **`present_core_xrgb` is the single accessor for the core's XRGB frame**, for the relation check
    and for B's A canvas (8.3, A-B5). Not a second DOS-profile copy (B's Choice B3).
30. **`w16q_msgbox` answers from the box's show, not its create**, matching `w16_MessageBox`'s order
    (5.2). Not a change of that order.
31. **A button press latches its action's class (ring, layer view, neither) until its release**
    (10.1, RV2-3). Not stamping each move and release from its own position, which split ring and
    view presses from their releases.
32. **Exit phases checked at build time against the consumers' tables** (6.2, RV2-1). Not relying on
    WI's phase column, which lists entry only for functions other areas close brackets at.

## 16. Open items

* **A1.** `OBS_CALLSITES` generation from F3's corrected DOS-PROFILE.md cells (K6) and the listing.
  The generator's input also takes the rows other areas filter on that are not in DOS-PROFILE.md:
  4.3's table of area C's rows, including RV2-2's CustomizeWorldDialog `ra` 11E0:0826 and
  RunNewGameSetup `ra` 11E0:020A, and the rows of B's `PdosMacro.ra` and `PdosSceneRow.ra` fields.
  RV2-4's `obs_callsite` and its lint make a missing row fail loudly. Resolves at D3.
* **A2.** Exact emission points inside user_ctl.c (BM_SETCHECK, edit selection and caret) and
  user_listbox.c (delete, reset, LB_SETCURSEL). Their line numbers are not fixed here. Resolves at D3 by
  reading those functions. The rule "after the state change" is fixed.
* **A3.** The chord audit against the DOS adapters' keys, once area C fixes the adapter table. Also
  recheck host layouts where Ctrl+Shift+Backspace gives a character other than 7Fh or none. The chord
  consumes the key-down whatever the character, so this only affects what the game would have seen.
* **A4.** The meaning of "S1" in 7.3. Read as the start-up run. The orchestrator confirms.
* **A5.** Event cost and probe-hook cost. Measure at D3 on soak S4 in Release (informational, as D12's
  scaler timing).
* **A6.** Whether any probed function has an `FR_NONE` frame. The argument-base rule covers it.
  `test_observer.c` checks one if any exists.
* **A7.** Whether `w16_obs.c`'s handle lookups can reuse existing `w16_wnd_*`, `w16_obj` and `w16_dc`
  getters unchanged, or need non-faulting variants. Resolves by reading them at D3. The guarantee
  (5.3) is fixed either way.
* **A8.** P1 (display rate) affects timelines, not the tick (7.2). **Settled by area C** (C.4.2: one
  DOS frame per 17,024 PIT clocks, about 70.086 Hz). C's timelines run to the time of each event,
  probe, tick and filter call (C.5.3), so they do not depend on how ticks partition time. That is the
  tick-history independence of 7.2.
* **A9.** The exact split of `w16_DrawText`'s layout and of `fill_rect`'s brush path for
  `w16q_draw_on` (5.2). Resolves at M by reading gdi_draw.c and gdi_font.c in full. The interface and
  the G-1 guard are fixed.
* **A10.** Areas B and C's interfaces with A are now in this draft (A-B1..A-B8; C.21 A-1..A-6 and
  C.20-9). RV2 checks the whole set (RV1-17). Two of C's points needed a change on C's side; see 17,
  "Points for area C".
* **A11. Closed (RV2-10).** B's pointer state for "use the game's cursor" (the Windows-class scroll
  arrows 136..143) is `pdos_cursor_current()` returning NULL (B 6.7, Revision 2), as 8.5 reads it.

## 17. Conflicts and their resolutions (ext-d1-decisions.md, "Area A")

| Id | Conflict | Resolution applied here |
|---|---|---|
| K1 | P0's window size and policy against F105/F110 | **Scoped P0**: profile, switch history and zoom in every mode; size and policy with a fixed game screen. The zoom never feeds `present_game_screen_follow`. Sections 0, 1, 13.1. Recorded in DESIGN.md 12.5 and FIDELITY |
| K2 | w16 changes beyond 5.1's list | Accepted; the full list below goes into DESIGN.md 12.5 |
| K3 | Ctrl and Shift hold rule | Accepted as a Choice; FIDELITY next to F101, with RV1-15's masked MK bits; the lone Ctrl or Shift timing is listed for the user's check (10.2) |
| K4 | S2 arrival code moves to portable `present/arrive.c` | Accepted; behaviour kept, guarded by 7.2 and 7.8 |
| K5 | `host.h` changes | Accepted: `HostEvent.frame` (0..4, 10.1) and, by RV1-7, `host_set_cursor_pixels` (8.5); by RV2-14, area E's `host_dos_read`, `host_dos_where` and their status enum (E.2.1, E.3.1), phase D2 |
| K6 | DOS-PROFILE.md's probe column holds call instructions | Fixer F3 (D0) gives the function start and the call site separately; A1 generates `OBS_CALLSITES` from them |
| K7 | Remembering the profile | Not a conflict: prompt 2.1 "Settings file" lists the last graphics profile; with nothing remembered, `windows` |
| K8 | Asan deferred | Gate records say "Asan deferred"; one Asan pass at the end of the queue |
| K9 | M in the backlog | The D3 gate is 7.3 without zoom; the zoom command, chords, menu items and V4 stay inactive until M |

**K2's list of w16 changes, each with its reason and guard:**

| Change | Reason | Phase | Guard |
|---|---|---|---|
| `vm.h`/`vm.c`: `CIV_OBSERVER`, probe table, hooks in `fr_enter`/`fr_leave` | O2 | D3 | G-1; V5; `test_observer.c` |
| `host_sync.c`: filter hook, `W16_TIMING_SCRIPT`, post hook, the input-sync counter and `w16_host_input_sync_fn` (C's `sync <n>` lines) | I2, I4, 7.8 | D3 | G-1 (unreached under timing none); V5 |
| `w16_obs.[ch]`: queries, emission macros, guard | O1, O3, O4 | D3 | lint; review 6.3 |
| emission sites in gdi_*, user_* (3.3), `W16_TICK()` in queue.c, clock.c, dos.c, user_cursor.c (7.1) | O1, O7 | D3 | G-1; V5 |
| Checked forbid checks across w16 (6.1) | O4 | D3 | G-1 (they never fire in correct runs) |
| `user_cursor.c`: `present_cursor` replaces the direct `host_set_cursor` calls (RV1-7) | D-3 pointer, 5.7 | D3 | G-1; `test_present.c`; 7.2 |
| `host.h`: `HostEvent.frame`, `host_set_cursor_pixels` (K5) | I5, D-3 | D3 | build; 7.2 |
| `host.h`: `host_dos_read`, `host_dos_where` and the `HOST_DOS_*` status enum, with back ends in `host_win32.c` (`hw_set_dos_source`; `hw_find_name` moved from `civ64_locate.c`) and `host_headless.c` (`hh_set_dos_source`, `hh_dos_inject`) and `zip_find_base` in `res/zip` (moved from `civ64_locate.c`) (area E, E.2.1, E.3.1) (RV2-14) | 5.5 DOS files, read-only access from `present/dos` without file APIs in `present/` | D2 | E.13.3; G-1 (no core path calls them) |
| `user_syscmd.c`: `g_track`/`g_track_on` in `outline()` and `movesize` for `w16q_sys_track` (RV1-4) | D 5.2 layer clip | M | G-1 and the base tests |
| `gdi_draw.c`/`gdi_font.c`: rasterisers split from the DC-bound APIs for `w16q_draw_on` (RV1-4) | D 7.3 out-of-view rules | M | G-1 (every core frame hash unchanged) and the base tests; `test_observer.c` pixel comparison |
| `user_msgbox.c`: `w16_msgbox_info` (A-B3) | B 11.2 message-box re-skin | D4 | read-only, `#if CIV_OBSERVER`; G-1; `test_observer.c` |
| `user_menu.c`: `w16_menu_item_info`; `user_wnd.c`: `w16_menu_display` (the static `menu_display` exported unchanged) and the bar-owner walk (A-B4) | B 11.2 menu bar and drop-down menus | D4 | read-only; G-1; `test_observer.c` |

**Points for the orchestrator after Revision 2** (each is now applied or answered; Revision 3 notes):

* **D's section 17 table still uses the pre-RV1-2 names.** It has `present_map_pending`,
  `present_map_overlay`, `present_map_point`, `present_map_request_zoom` and
  `present_map_on_core_present`, while D 3 now declares `pmap_*`. This draft uses `pmap_*`.
  *Revision 3:* D 17 now uses the `pmap_*` names.
* **The user's checks.** These resolutions change behaviour the user checked or will see:
  * K3, the lone Ctrl or Shift timing and the masked MK bits;
  * Locate taking effect at the next start (RV1-6);
  * the refusal cadence of one message per run, then beeps;
  * X3, the 4:3 default for 320x200 frames.
* **Points for area C** (found while applying C.20-9 and C.21; for RV2 or the merge):
  * **Cancellation across frames.** C.12.1 passes frames 0 and 3 without telling C. A user action on
    the Windows profile after a switch would then not cancel a pending DOS translation (C.13.4). A
    calls a new `pdos_adapt_note(ev)` for frames 0, 3 and 4 (10.1). C adds it and applies C.12.2's
    action rule. **A cannot provide C.13.4's rule as C.12.1 describes it without this addition.**
    *Revision 3:* C added it (C.12.2); by C-11 and RV2-5 the filter now uses the note's return
    value (10.1).
  * **Open C-1 (C.15.4).** A virtual-time line cannot always target a given sync, because syncs can
    share one virtual time (queue.c:552). A adds `sync <n>` host-form lines and the input-sync
    ordinal in `adapt.log` (12.4). C's `ext_adapt.py` uses them instead of writing a line "between"
    two sync times.
  * **DrawUnitStackList** is called as `push cs` + near call (11C0:334B..334C). Its FrameDesc has
    `far_ret` 1, so its row compares the full `ra` 11C0:334F, not the offset (C.11.2 says "near";
    RV1-19's offset rule does not apply).
  * **The lint's `RandomBelow` rule** (C.15.5) is narrowed to calls and declarations of the core
    function (6.2). As C writes it, it would forbid probe-row names B or D may use for the 4.3
    RandomBelow exits.
  * **`input_frame` of D3's DOS profile** is 2 (it shows the Windows frame). C's adapters see no N
    scene before D4, as intended.
* **Points for area B** (found while applying A-B1..A-B8; for RV2 or the merge):
  * **B 6.5** says the harness writes `--dump-presented`. That option exists only in civ64 today
    (civ64_start.c 94, host_win32.c 932..1005). This draft adds it to the harness and puts the 8-bit
    form in both back ends (7.3).
  * **B 6.7 "Scale"** multiplies by the layout factor. Under this draft's Choice 26 the back end
    applies that factor. B's image is at frame scale (1x on N, 2x on A), and `gen` does not change
    with the window size.
  * **B 6.7** has no "no pointer of its own" state for the Windows-class scroll arrows (A11).
    *Revision 3:* B 6.7 returns NULL for it; A11 is closed (RV2-10).
  * **B 11.2's message box** must read `w16q_msgbox` at the box's `OBS_WND_SHOW`, not at
    `OBS_WND_CREATE` (5.2).
  * **B 8.2** lists ScaleLogicalX/Y as entry probes. This draft gives them an exit too, for the
    `(v, ScaleLogical(v))` pairs of B 8.3 (4.3). B may drop the exit if it computes the value itself.
    *Revision 3 (RV2-15; B 21 X9):* B computes `(int16_t)((long)v * 160 / 100)`, which equals the core's
    16-bit AX for every argument, so the ScaleLogicalX/Y exit phase may be dropped at D3 with no
    behaviour change. The exit stays in 4.3 until D3 decides; dropping it changes no key.
  * **B 20 A-B2**'s "where A's 4.3 list does not name them" is now moot: 4.3 takes all of WI 10.

  They belong in `manual-checklist-ext.md`.

## 18. OPEN.md P items and area A

* **P1.** Not area A's. The tick rate is independent (7.2). Area C decides the timeline rate.
* **P3, P6.** Area A supplies the observation of the core's decisions:
  * `DrawTilesToPort` mode and order probes;
  * RandomBelow exit values at the newspaper call sites;
  * the blink and move drawing through draw events and probes (BlinkActiveUnitUntilInput,
    AnimateUnitMove, added by A-7).

  `g_randSeed` is never read (O4). The DOS rules are areas C and D.
* **P2, P4, P5, P7..P11.** Areas B, C, D and E.

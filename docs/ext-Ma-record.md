# Extension phase M, unit Ma (zoom, layer, in-view source, input, commands) — record

Prompt: `claude/docs/x64-port-scaling-dos-prompt.md`, phase M (the map zoom, 5.8; Z-1..Z-3), with the
P0 rule (prompt 1) above all. Phase M is done in two units: this unit Ma (the zoom, the layer, the
Windows in-view source `M`, input over the layer and the commands) and Mb (snapshots, the Windows rules
for the ring, the mirror checks, `ext_zoom.py`, the agent UI check and the gate record). Session Ma,
2026-10-11. Brief: [verify/BRIEF-m.md](verify/BRIEF-m.md) ("Ma"). Design:
[verify/ext-d1-draft-D.md](verify/ext-d1-draft-D.md) (Revision 3) sections 3, 4, 5, 6.1, 11, 12, 13,
16.1, 16.4, 16.5, 17 (the A items) and 18, with [verify/ext-d1-decisions.md](verify/ext-d1-decisions.md)
area D (C1..C7), DESIGN.md 12.9..12.11 and the D3 records ([ext-D3-acceptance.md](ext-D3-acceptance.md),
[ext-D3a-record.md](ext-D3a-record.md), [ext-D3b1-record.md](ext-D3b1-record.md),
[ext-D3b2-record.md](ext-D3b2-record.md)).

Labels: **compiled** (the three language checks and `/W4 /WX`), **headless** (test programs and the
harness on `build/gamedata`), **Win32-headless** (the Win32 back end with a hidden window). No DOS
program was executed; nothing was written to `C:\Projects\Civ1RE\dos` or `build/dosdata`; no visible
window was shown; civ64.exe was not started (the agent UI check is Mb's). No global hotkey, hook,
ClipCursor or clipboard is used. Asan was not built or run (deferred by the user).

## What was built

### `present/map/` (new, draft D 3)

Six files, compiled with the portable sources (`build.cmd`'s loop, the `/I` list and the clang-tidy
`-I` list gain `present\map`; `obs_lint.py` lints them with the rest of `present/`):

* **`pmap.h`** — the public interface: the levels (`PMAP_ZOOM_OUT/DEFAULT/IN`), the listeners
  (`pmap_reset`, `pmap_on_event`, `pmap_on_probe`, `pmap_on_core_present`), the zoom
  (`pmap_request_zoom`, `pmap_zoom_command`, `pmap_level`, `pmap_in_refused`), the layer
  (`pmap_pending`, `pmap_restore`, `pmap_overlay`, `pmap_active`, `pmap_layer_image`), input
  (`pmap_hit`, `pmap_layer_point`, `pmap_filter_ring`), `pmap_view_current`, `pmap_diag` and the test
  seams `pmap_test_map` and `pmap_test_smmap`. Under `CIV_OBSERVER 0` every entry is a stub: no layer,
  every level refused with "not in this build (CIV_OBSERVER 0)".
* **`pmap_int.h`** — the state shared by the files (`PmapState pmap_g`, the geometry `PmapGeo`).
* **`pmap_zoom.c`** — levels, geometry and anchors (4.1, 4.2, 11): for level +1 host column hx shows
  world column `Xo + floor((hx - Rc.l) * W / (2 SW))`, for -1 `Xo + floor((hx - Rc.l) * 2W / SW)`
  (rows likewise), `Rc` the map client's whole inner host rectangle (the formulas of
  `present_host_rect_inner` without the clip), `Wl`, `Hl` the ceilings. Clamps (11.2): +1 inside the
  view (never the ring); -1 the whole view visible, the fewest rows beyond the poles, the world centred
  when `Hl > 1600`, an even origin (down, or up when down would cut the view's far edge). Anchors
  (11.1): the centre for a new level from a chord, the menu, `--zoom` and the harness command; the
  wheel keeps the world pixel under the pointer (at level 0 through `present_map_point`); a resize or a
  layout change keeps the world pixel at the layer's host centre; a new view keeps the layer's place on
  the client (11.3), then the clamps. The active unit (11.3) at +1: at `BlinkActiveUnitUntilInput`'s and
  `AnimateUnitMove`'s entries (the human's units; the move's destination through `g_dirDX/DY`), the
  least pan that shows the square with a one-square margin, nearest copy within ±1280. Limits (4.3):
  +1 is refused with "map window too small" while its layer would be under 96 world pixels (3 x 3
  squares) on either axis; a resize below that drops the level to 0. Requests and commands read only
  the module's state (callable from the Win32 window procedure).
* **`pmap_layer.c`** — activity, clip, composition and damage (5): active when the level is not 0,
  the Windows profile is visible, the view has a layout, the map window exists, is shown, not iconic,
  its client's visible region has 1..64 rectangles, and the view snapshot's size equals the client's;
  each other case is a counter. The clip is the visible region in host pixels less the move or size
  outline's band (`w16q_sys_track`). An index image over the clip's bounding box (XRGB with area weights
  under `fit` + sharp, `present_axis_taps`); each host pixel shows world pixel (X, Y): in view the
  mirror `M`, beyond the poles black, else the ring — **black until Mb** (`pmap_ring_px`, the interim
  state of this unit). `pmap_overlay` writes the image into the view inside the clip only, where the
  scaler just wrote and where the layer changed; a clip that shrinks or a layer that goes gives its
  area back to the base frame (`pmap_restore`). After the review, every overlay and restore evaluates
  the activity again (a profile switch, an options change or a layout change shows through `show_all`
  without a core present, 5.2).
* **`pmap_inview.c`** — the Windows in-view source `M` (6.1): a client-sized index copy of the core's
  map client kept at every core present in every profile (visible pixels from the virtual screen,
  covered or off-screen ones from the map port's bitmap 12D8:455C, black with `port_size` when that
  bitmap's size differs; `OBS_BITMAP` damage on it waits for the next core present); the map window
  read through `w16q_wnd`, `w16q_wnd_client_vis`, `w16q_sys_track`; the view snapshot (8) at the exits
  of `DrawTilesToPort` (port argument `&g_mapOffscreenPort`) and `RedrawMapRect` (window argument
  `&g_mapWindowPort`), skipped while `g_mapWindowLocked` or `g_cityScreenMapMode`; the listeners.
* **`pmap_input.c`** — input (12): `pmap_layer_point` (in view: the client pixel of the world pixel,
  exact; covered: the nearest visible client pixel; the ring and beyond the poles: the nearest view
  point, then the nearest visible client point; a ring square carries its column and row), `pmap_hit`
  (the wheel's region: the layer's clip, or at level 0 the map client's visible host region) and
  `pmap_filter_ring` (12.2, below); its `PiLayerFn` adapter is registered with the arrival stage by
  `pmap_reset`.

### The A items of draft D 17 that D3 left

D3 had delivered A-3's `w16q_wnd_client_vis`, A-5's frames 3 and 4 with the arrival latch (RV2-3),
`PI_CMD_ZOOM_*`, `PiOut.cmd_hx/cmd_hy`, `pi_set_layer` and A-7's probes. Ma added:

* **A-1** (`present.c`, tick step 5): a profile that shows the core frame returns only when
  `pmap_pending()` is 0; otherwise the throttle and step 7, which for such a profile shows only the
  layer's damage (and the base frame's give-back) as a TICK show of the core frame.
* **A-2** (`present.c`): `layer()` after every scaling — the CORE show in `present_core_frame`, the
  VIEW redraw `show_all` and the TICK show; `pmap_on_core_present` is called for every core present,
  whatever profile is visible; the map layer's listener is registered by `present_profiles_init` after
  the profiles' (three of `OBS_LISTENERS_MAX` 4 in a DOS run).
* **A-3a** (`user_syscmd.c`): `g_outline` and `g_outline_on`, toggled at each `outline()` call, set to
  "no band" at a loop's start and end and by `w16_syscmd_reset` (from `w16_user_reset`, after the
  review); `w16_sys_track_info` for `w16q_sys_track`. The loop's behaviour is unchanged.
* **A-3b** (`gdi_draw.c`, `gdi_font.c`, `w16_obs.c`): the DC-free rasterisers `w16_paint_brush`,
  `w16_rast_fill`, `w16_rast_frame`, `w16_rast_line`, `w16_text_draw` and `w16_text_box`; FillRect,
  FrameRect, Polygon, TextOut and DrawText resolve the DC's state and call them, so the virtual screen
  draws through the same code (LineTo and Polyline keep the static `line()`). `w16q_draw_on(W16Surf *,
  W16qOp *)` draws FillRect, FrameRect, LineTo with a pen width, TextOut and DrawText (an HFONT and a
  format) on a caller surface, and maps a COLORREF to a physical index, with no DC and no handle
  allocated. After the review it refuses a surface of more than 2^31 bytes or a coordinate outside the
  16-bit range with its offset, cuts text at 512 bytes as the wrappers do, and counts an unknown font as
  a bad handle (0 is the system font). Every core frame hash stays equal (G-1 and V0, below).
  `obs_lint.py`'s reviewed calls and its draw-on rule follow the split.
* **A-4** (`input.h`, `arrive.c`): `pi_arrive_mouse` consults `pmap_layer_point` (D3's latch);
  `PiOut` gains `cmd_steps` and `cmd_at` beside `cmd_hx`, `cmd_hy` (deviation row).
* **A-5** (`input.c`): frame 4 goes to `pmap_filter_ring` (D3's consuming stub removed;
  `present_input_set_dispatch(NULL)` restores it); frame 3 passes as before.
* **A-6** (harness): `presented.log` show lines gain `zoom L view CWxCH view_sha256 SHA` while the
  layer is drawn (the whole host view buffer's hash, its size first, as `host_show` hashes a frame);
  `--dump-presented` writes `view-NNNNN.bmp` (24-bit) for those shows; `profiles.log` sample lines gain
  `map windows SHA` (the layer image) while the level is not 0; `presentation-diag.log` (harness) and
  `present_diag_log` (civ64's debug log) gain the `pmap ...` line (counters, the map client, the view,
  the layer's host rectangle and origin).
* **A-8**: the system-menu ids, `--zoom`, the settings key and the harness command (next section).
* **B-3** (area B's item, needed by the layer; `scale.c`, `scale.h`): `present_host_rect_inner`
  (the host rectangle of the image pixels that show only a logical rectangle: integer the exact
  blocks, fit the pixels whose source footprint lies inside), `present_axis_taps` (one axis's area
  weights for any rational ratio and a first destination) and `present_taps_free`. The scaler's own
  sharp taps are now made by `present_axis_taps` over the whole axis; `test_present` (521 checks),
  the present goldens and `ext_frames.py` are unchanged.

### Commands, options, settings (13)

* **Chords** (`arrive.c`): Ctrl+Shift+`VK_OEM_PLUS`/`VK_ADD` zoom in, Ctrl+Shift+`VK_OEM_MINUS`/
  `VK_SUBTRACT` out, Ctrl+Shift+`'0'`/`VK_NUMPAD0` reset, taken exactly as D3's Ctrl+Shift+Backspace
  (the hold rule; the chord's press, repeats and release and the held modifiers' releases never reach
  the game; a key already delivered down makes no chord); only a press without the repeat bit gives the
  command. Under `CIV_OBSERVER 0` these keys are not chords (after the review; deviation row).
* **The wheel** (`pi_arrive_wheel`, 12.3): over `pmap_hit` the deltas accumulate, each full 120 is
  one step (towards zero, the remainder kept), forward zooms in, the command carries the steps and the
  wheel's host point (the anchor); elsewhere the wheel is ignored and the sum clears. Win32's
  `WM_MOUSEWHEEL` already converted with `ScreenToClient` (D3).
* **System menu** (`host_win32.c`): after Locate, a separator, "Zoom &out (half)\tCtrl+Shift+Minus"
  `SC_CIV_ZOOM_OUT 0x10C0`, "&Normal map zoom\tCtrl+Shift+0" `SC_CIV_ZOOM_DEF 0x10D0`, "Zoom &in
  (double)\tCtrl+Shift+Plus" `SC_CIV_ZOOM_IN 0x10E0`, then the separator and About. Radio items marking
  the level (`hw_update_menu`, also on WM_INITMENU); "Zoom in" grayed while +1 is refused; a menu item
  requests its level with the centre anchor; all three grayed without the observer. The back end's
  `player_zoom` runs the chords' and the wheel's commands through `pmap_zoom_command`; a change calls
  the new zoom hook (`hw_set_zoom_hook`); a refusal is silent.
* **civ64** (`civ64_start.c`, `civ64_main.c`): `--zoom default|-1|0|+1` (`default` and `0` the same
  level; anything else exits 2 with the usage); without it the settings key `zoom` (`-1|0|1`, anything
  else absent), else 0; the player's change is written to `zoom`, `--zoom` never. A `CIV_OBSERVER 0`
  build refuses `--zoom` (message box, exit 2).
* **Harness**: `at <ms> zoom -1|0|+1|reset` (script and host-input files; `pmap_request_zoom` with the
  centre anchor, `reset` through `pmap_zoom_command`), `--zoom default|-1|0|+1` (requested before the
  core starts); a refused request writes `zoom refused <reason>` in `presented.log`; the 7.8 mode runs
  the chords' and the wheel's commands as civ64 does. Under `CIV_OBSERVER 0` both exit 2.

### The ring click (12.2) and Open D8

`pmap_filter_ring` turns a left press on a ring square (frame 4: column, row) into the small-map click
that `PollMouseClick` (1108:0000) passes to `CenterMapOnSmMapClick` (1210:056E): the target view is
`CenterMapViewOn`'s, left' = col - cols/2, top' = row - rows/2; deltaX = viewLeft - left' taken modulo
80 into the representative (nearest 0, then ±80, ±160) that puts the click inside the small map's
visible client, clickX = (frame.left + frame.right)/2 - deltaX * g_smMapScale, which the core's signed
truncating division maps back exactly (y without the wrap). The press becomes a move (without the left
button's bit) and the press at that point; its frame-4 moves give nothing; its release (from anywhere)
the release at the same point. Not delivered (press and release consumed, `ring_refused`) when the
small map is hidden (window, or the data block's `visible` flag at +0x2C that `CenterMapOnSmMapClick`
tests), iconic, disabled, captured by another window, or the point is covered; a right press on the
ring never is. The small map is read with `w16q_*` inside the filter's guard.

**Open D8** ("whether w16 keeps the posted button state when `FlushInputEvents` removes a queued
release (the small-map path); the same holds for a real small-map click"): **answered.** In w16
(`queue.c`), posting a mouse message records the posted MK_ state (the release clears MK_LBUTTON), and
retrieving a button message with PM_REMOVE updates the key-state array; `FlushInputEvents` (11F0:4EA0)
retrieves the queued input ranges with `PeekMessage(PM_REMOVE)`, so a release it removes still leaves
the button up in both states — nothing stays down. The 7.8 `ring` run posts the ring click's move,
press and release at one sync (so the release is queued when the small-map branch runs), the marks show
the branch ran right after the press (`PollMouseClick` 1108:010B, then `CenterMapOnSmMapClick` and
`FlushInputEvents`), and the run equals `ringref`, the same click made unzoomed on the small map, in
`coreinput.log`, every frame, snapshot, result and event and the exit status, through the rest of S3
(turns 2 to 5).

## The chord audit (draft D 13; as D3b2's for Backspace)

Read only: `build/gamedata/civ.exe`'s NE resource table (a scratchpad script) and the port's sources.
**ACCELERATOR 128** has 24 entries: plain virtual keys D, H, J, K, N, P; Ctrl+R; Ctrl+0..9;
Ctrl+D, P, F, L, Q, S, T — **no Shift entry**. w16's `TranslateAccelerator` (`user_misc.c`) matches the
Shift, Ctrl and Alt flags exactly against the emulated key state, so Ctrl+0 (World Map) needs Shift up
and Ctrl+Shift+0 would not match it even if delivered. **MENU 128**'s shortcut texts are the same keys
(Ctrl+S, T, L, F, R, Q; letters; Ctrl+1..9, Ctrl+0, Ctrl+D, Ctrl+P); none uses Shift. No core handler
reads `GetKeyState`; `GetKeyboardState` only for Num Lock (D3b2's finding, unchanged). The plain keys
`=`, `-`, `0` and the keypad keys reach the game unchanged (`test_map`, and the 7.8 `ring` run: their
lines put events into the ring and `coreinput.log` has their WM_KEYDOWN). With Num Lock on, Shift turns
keypad 0 into `VK_INSERT` on usual layouts, so the keypad reset may not arrive (the main-row 0 does).

## Acceptance items

The final cycle (after the review fixes, see "Review"), 2026-10-11:

| Item | Method | Result |
|---|---|---|
| Builds | `build.cmd checked`, `build.cmd checked noobs`, `build.cmd` (strict C17/x64, `/W4 /WX /permissive-`; the 249 portable sources, four of them new (`present/map/*.c`), also `/std:c11`, `/std:c17` and the clang-tidy C99 parse) | compiled: BUILD_OK Checked (17:11:08..17:14:02 UTC), CheckedNoObs (17:29:42..17:32:41 UTC), Release (17:48:44..17:51:37 UTC) |
| Base tests | `test.cmd checked`, `test.cmd checked noobs`, `test.cmd` (every base test program, `test_map` and the Win32-headless programs included, gate 3b, the stub-core runs, scenarios, UNINIT, phase-4 scenarios and tests, D2's, D3's and M's checks, TRACE) | TESTS_OK Checked (17:14:06..17:29:15 UTC), CheckedNoObs (17:40:55..17:48:28 UTC, the second run; see below), Release (17:51:37..17:52:16 UTC); GATE3B_OK, UNINIT_OK, P4_SCENARIOS_OK and P4_TESTS_OK in Checked and CheckedNoObs, TRACE_OK in every variant |
| G-1 (P0; A-3b's guard) | `ext_g1.py check` after `test.cmd checked`; `ext_g1.py check --variant CheckedNoObs` after `test.cmd checked noobs` | **EXT_G1_OK runs 77** on Checked (17:29 UTC) and on CheckedNoObs (17:48 UTC) |
| 7.3 P0 with the zoom (16.4) | `ext_p0.py Checked` in `test.cmd checked` (V0, V1, V2, V3, **V4**, V6, V6r, V6w, V7); `ext_p0.py CheckedNoObs` in `test.cmd checked noobs` (V5 and the zoom refusals) | **P0_OK checks 279** (Checked: D3b2's 224 and V4's 55), **P0_OK checks 56** (CheckedNoObs: V5's 54 and the two refusals); no FAIL line in the final runs (see "P0 variations and results") |
| 7.4 (13.2) and the dump check | `ext_frames.py Checked` in `test.cmd checked` | **EXT_FRAMES_OK** (the scaler's sharp taps now from `present_axis_taps`) |
| 7.8 (16.5) | `ext_adapt.py Checked` in `test.cmd checked` | **EXT_ADAPT_OK checks 20** (D3b2's 11 and M's 9; see "7.8") |
| 16.1 unit tests | `test_map.exe` in every `test.cmd` | **96 checks, 0 failures** in Checked and Release; under `CIV_OBSERVER 0` **1 check** (every level refused with "not in this build (CIV_OBSERVER 0)", no layer) |
| Menu, chords, `--zoom` (13) | `w32_test_host_win32.exe` in every `test.cmd` | **196 checks, 0 failures** Checked and Release, **194** CheckedNoObs (D3b2: 185) |
| `CIV_OBSERVER 0` refusal (16.4) | `ext_p0.py CheckedNoObs`: the CheckedNoObs harness with `--zoom +1`, then with a script `at 100 zoom +1` | exit 2 with `harness: --zoom: not in this build (CIV_OBSERVER 0)` and `harness: the zoom command: not in this build (CIV_OBSERVER 0)` |
| Probe use | V4's 27 `observer-probes.log` files against V0's | equal in all 27 (informational). The probes M listens to, summed over V4: DrawTilesToPort 154 entries / 154 exits, BlinkActiveUnitUntilInput 113 entries, AnimateUnitMove 6 / 6, RedrawMapRect 0 (on D3's never-hit list: no run's path calls it) |
| Tables and the static check | `obs_tables.py --check`, `obs_lint.py` in `test.cmd` | `OBS_TABLES_OK probes 203 sites 98`, `OBS_LINT_OK files 39 probes 203 callsites 98` in every variant (D3b2: 33 files; the six `present/map` files linted) |
| No DOS bytes; E's include rule | `nodos.py check`, `registry.py check` in `test.cmd` | NODOS_OK and REGISTRY_OK in every variant; `nodos.py check` again at the end: NODOS_OK (17:53 UTC; 848 files scanned, 0 hits). Nothing under `build/dosdata` or `C:\Projects\Civ1RE\dos` is dated 2026-10-11 |
| The chord audit | read-only, `build/gamedata/civ.exe`'s resource table and the port's sources | recorded above ("The chord audit") |
| Open D8 | `queue.c` read; the 7.8 `ring` run's marks and its equality with `ringref` | **answered** (above) |
| Asan | — | **deferred** (the user's direction 2026-10-10 21:20) |

**The CheckedNoObs failure of the final cycle.** The first final `test.cmd checked noobs`
(17:32:50..17:40:07 UTC) gave `TESTS_FAILED=1`: `FAIL V5 CIV_OBSERVER=0 refuses the zoom command (exit
2: ... run directory ...\build\run\p0-V5-zoom exists (each run needs a fresh one))`. The harness
prepares the run directory before it reads the script, so the refused script command of the earlier
cycle had left `build/run/p0-V5-zoom` behind, and the second refusal stopped at the directory check
(still exit 2, without the expected message). `ext_p0.py`'s `refusal_checks` now removes the run and
output directories before each refusal run, as its `execute` does for every other run; the whole
`test.cmd checked noobs` ran again with the leftover directory in place and passed (TESTS_OK, P0_OK
checks 56, both refusals with their messages), then `ext_g1.py check --variant CheckedNoObs`. The
change touches only the CheckedNoObs path of the runner; the Checked suite before it does not call
`refusal_checks`.

Earlier cycle of the session (before the review fixes): Checked builds ended 16:13 and 16:28 UTC
(BUILD_OK; compile checks and smoke runs), then 16:33:47..16:36:47 UTC, TESTS_OK until 16:58 UTC
(`test_map` 85 checks, `test_host_win32` 196, P0_OK checks 279, EXT_FRAMES_OK, EXT_ADAPT_OK checks 20),
EXT_G1_OK runs 77; CheckedNoObs 16:58:34..17:01:31 UTC (BUILD_OK), TESTS_OK 17:01:36..17:08:29 UTC
(P0_OK checks 56, `test_map` 1, `test_host_win32` 194), EXT_G1_OK runs 77. Every build of the session
passed. Logs: `build/ma-build-*.log`, `ma-test-*.log`, `ma-g1-*`, `ma-times-*.txt` (suffix `-1` the
earlier cycle, `-final` the final one, `-noobs-final2` the CheckedNoObs rerun), `ma-adapt-*.txt`
(the 7.8 runner's development runs); the runners' outputs `build/test/<variant>/ext-p0.txt`,
`ext-frames.txt`, `ext-adapt.txt`. Informal harness runs of the session (not gates): `build/ma-smoke`
(load-save at 1920x1440, `zoom +1`) and `build/ma-view-1`, `ma-view0`, `ma-view+1` with
`--dump-presented`: the agent looked at their `view-NNNNN.bmp` files — at +1 the map's squares twice
as large around the view's centre, at -1 the whole view at half size inside a black ring (the interim
state), the rest of the game screen unchanged.

### Test counts

| Program | Checked | CheckedNoObs | Release | D3b2 |
|---|---|---|---|---|
| `test_map` (new, headless) | PASS 96 checks, 0 failures | 1 | 96 | — |
| `test_host_win32` (Win32-headless) | PASS 196 checks, 0 failures | 194 | 196 | 185 |
| `test_input` (headless) | PASS 140 checks, 0 failures | 122 | 140 | 140 / 122 / 140 |

Every other test program gave D3b2's counts in each variant (for example `test_present` 521,
`test_observer` 103 / 1 / 92, `test_user` 319, `test_start` 110, `test_gdi` 95, `test_locate` 36,
`test_dos` 23,200). `test_map`'s sections: geometry (k = 1..4 under `integer`, `X(hx)` and the centred origin against
hand-computed values at +1 and -1, +1 blocks 2k wide, -1 pairs k wide with an even origin, the half
level's even pixels at k = 1; fit factors: every host pixel inside `[Xo, Xo + Wl)`, monotone, the
extent's ends reached), anchors (the wheel's world pixel kept under the pointer at +1, and from +1 to
-1 within one pixel pair; the clamp at the client's corner, the poles, `Hl > 1600` centred, the wrap
into ring squares), limits
(+1 refused below 3 x 3 squares, a resize below it drops to 0), input (in view exact at square
edges, covered points to a hand-made visible region, ring squares and poles, the capture-loss
release per button, a layer gone during a press, the options re-evaluation), the ring translation
(scales 1 and 2, both wrap representatives, an odd frame width, the hidden and covered small map, the
press/move/release sequence, a held right button kept), the wheel (40, 80, 120, -240, mixed, off the
map) and the chords, and the costs (printed, not checked). The CheckedNoObs count is 95 lower: the
module is stubs there and the one check is its refusal. `test_host_win32`'s 11 new checks are the zoom
items (texts, order, the radio mark following the level, Zoom in grayed while refused, the levels;
under `CIV_OBSERVER 0` grayed and refused) and the `--zoom` parse cases (the CheckedNoObs build has 2
fewer: one refusal check in place of the three level checks); the About position check now expects the zoom items above it.
`test_input` kept its count; one message names `pmap_filter_ring` as the default ring translation.

### P0 variations and results

The 27 runs of D3b1/D3b2: the 23 rows of `scenarios.py` and gate3b's S2, S2b, S2c, S3 (S1 is `start`).
"Equal" means `run.log`'s frame, snapshot and result lines, the whole `events.log` and the exit status.

| Variation | Options (beside the scenario's) | Runs | Checks | Result |
|---|---|---|---|---|
| V0, V1, V2, V3, V6, V6r, V6w, V7 | as D3b2 | 27 / 27 / 27 / 27 / 2 / 2 / 2 / 27 | 224 | as D3b2: every run equal to V0 (V6w to V6r); the switch and `hostinput.log` assertions as recorded there |
| **V4** | `--host-size 1920x1440 --presented 1` and a generated script: the scenario's lines plus `zoom +1`, `zoom -1`, `zoom reset`, `zoom 0` in turn every 1,301 ms from 1,301 ms up to the watchdog (1,490 zoom commands over the 27 runs) | 27 | 55 | equal to V0 in all 27; no `zoom refused` line in any `presented.log`; the layer drawn in 22 runs (2,715 shows with the zoom fields); the five runs without a layer (start, birth, fame-quit, fame-reload, display16) never have the map window shown at a zoom level |
| V5 | the V0 options on CheckedNoObs, and the two refusals | 27 | 56 | every run equals its baseline row and the Checked V0 outputs; `--zoom +1` and the script's `zoom +1` exit 2 with the message |

V4 runs every P0 scenario with the zoom changing about every 1.3 s through every state the scenarios
reach (title, setup, play, reports, dialogs over the map, saving and loading), at the user's host size;
that the frames, snapshots, results, events and exit statuses equal V0's shows that the layer, the
in-view source `M`, the snapshot of the view, the listeners and the zoom commands change nothing the
core sees. The scenario's script stays its input; the zoom commands go through `pmap_request_zoom`
and `pmap_zoom_command` as the menu's and the chords' do. S4 and S5 (the soaks) are not in
`ext_p0.py`'s matrix, as for V0..V7 (deviation row).

### 7.8 (`ext_adapt.py`, 16.5)

D3b2's two runs (**plain**, **chords**: unchanged, 11 checks) and three new runs of gate3b's S3 in
host form at `--host-size 1920x1440 --presented 1` (k = 3, the game screen at offset 0). Final
Checked result, 9 new checks:

* **zoomkeys**: the plain run's lines with eight zoom chords (Ctrl+Shift with `VK_OEM_PLUS` with an
  auto-repeat at 6,000 ms, `VK_SUBTRACT` 16,000, `'0'` 24,500, `VK_ADD` with a repeat 50,500,
  `VK_OEM_MINUS` 56,900, `VK_NUMPAD0` 57,200, `VK_OEM_PLUS` 59,300, `'0'` with a repeat 66,000) and
  three wheel lines (+120 and -240 over the map at 56,000 and 56,300 ms, +120 off the map at
  56,600 ms). It equals the plain run (`coreinput.log` 38 messages, 764 frame lines, 13 snapshot and
  result lines, 94 events, exit 0); its `hostinput.log` has the 54 chord and wheel lines, each
  `events 0` with the expected command (zoom_in 4, zoom_out 3, zoom_reset 3, none 44: the repeats,
  the modifiers, the releases and the wheel off the map); the layer was drawn in 76 shows. The plain
  run is at the default host size; the frames and core input are equal (deviation row).
* **ring**: `--zoom -1`, with `--mark smclick=1108:010B --mark smcentre=1210:057C`. At 59,400 ms a
  left press and release (same time, one sync) on a ring square left of the view (the host point
  `(3cx + 3cw/8, 3cy + 3ch/2)` from zoomkeys' map client, 171,40 624x427), in-view clicks at -1
  (59,800/59,900 ms), `zoom +1` at 60,200 ms, in-view clicks at +1 (60,500/60,600 ms), and plain
  `=`, `-`, `0` (69,000..69,650 ms). Posted: `0200(56,77) 0201(56,77) 0202(56,77)` (the ring click's
  move, press and release at the small-map point), `0201(639,274) 0202(639,274)` (the -1 click),
  `0201(522,253) 0202(639,242)`; the two marks at 59,404,350 µs (the small-map branch of
  `PollMouseClick` and `CenterMapOnSmMapClick`'s body, right after the press); `ring_press 1
  ring_refused 0`; the plain keys put their 6 lines' events into the ring and 3 WM_KEYDOWN reached
  `coreinput.log`; the follow rule ran once at +1.
* **ringref**: the same S3 lines with the equivalent unzoomed host clicks at the posted points
  (`3x + 1, 3y + 1`) at the same times, and the same plain keys. **ring equals ringref**:
  `coreinput.log` (51 messages with their virtual times), 757 frame lines, 13 snapshot and result
  lines, 106 events, the exit status. The ringref points are taken from the ring run's posts, so the
  equality shows that the zoomed run is exactly the run of those clicks (nothing extra, nothing
  missing, the same core results), and the marks show the ring click took the small-map path. That a
  ring square's click recentres on that square, and that an in-view host point gives the client
  point of the world pixel under it, are `test_map`'s translation (with `CenterMapOnSmMapClick`'s
  arithmetic applied to the posted point) and input checks. So the ring click equals a small-map
  click, and the in-view clicks at -1 and +1 post what unzoomed clicks on the same points post.

### Measured costs against draft D 18

`test_map`'s `costs()` (a synthetic map client and view, the layer rendered in full ten times and its
palette reconverted ten times, the mean; the clip is the map client's whole host rectangle). Final
runs, Checked (`/O2` with the checks) and Release:

| Host size, policy | Layer pixels | Full render -1 / +1 (Checked; Release) | Palette reconversion -1 / +1 (Checked; Release) |
|---|---|---|---|
| 1920x1440 `integer` (k = 3) | 1,802,367 | 6.4 / 8.5 ms; 8.2 / 9.9 ms | 0.9 / 1.1 ms; 1.0 / 0.9 ms |
| 3840x2160 `integer` | 3,204,208 | 11.6 / 15.6 ms; 13.7 / 20.0 ms | 1.8 / 1.7 ms; 1.9 / 1.9 ms |
| 2560x1600 `fit` sharp | 4,445,172 | 33.2 / 25.7 ms; 35.7 / 25.7 ms | 33.9 / 25.8 ms; 39.2 / 24.8 ms |

Draft D 18 estimates a full re-render of 8 to 15 ms and a palette reconversion of about 4 ms at
4 M pixels. **Nearest** (`integer`, and `fit` nearest) is inside or near the estimate: up to about
20 ms at 3840x2160, and its reconversion is 1 to 2 ms (the index image is kept; only the palette
lookup is redone). **Sharp** is above it: the layer keeps area-weighted XRGB (5.4), so a palette
change must weigh every pixel again, which costs as much as a full render, 25 to 40 ms at 4.4 M
pixels — while the map palette cycles (5 per second) that is about 125 to 200 ms of CPU per second.
An earlier direct run in the session, with the machine busier, measured about twice these values
(1920x1440 13.3 / 14.8 ms, 3840x2160 22.5 / 27.9 ms, 2560x1600 sharp 72.3 / 42.0 ms with reconversion
55.3 / 43.4 ms); the times vary with load and are not checked. The layer's memory: one index (nearest)
or one XRGB (sharp) per host pixel of the clip's box, freed when the layer goes; `M` one index per
client pixel (D 18's "≤ 4 MB"). The world canvas (4 MB + 1 MB) is Mb's.

## Review

A separate read-only agent session reviewed the changes (P0 first; A-3 and A-3b; `present/map`'s
memory safety; the behaviour against draft D) after the first cycle. It found **no P0 violation**:
every `w16q_*` call in `present/map` sits inside the guard (`pmap_on_core_present`, the probe and
event listeners, `pmap_filter_ring` from `host_sync.c`); the entries reachable from the window
procedure (`pmap_request_zoom`, `pmap_zoom_command`, `pmap_hit`, `pmap_layer_point`,
`pmap_in_refused`, `pmap_overlay`, `pmap_restore`, `pmap_pending`) read only the module's and
present.c's state; no w16 API call, no handle, no write to emulated memory, no read of 1420:4EE0..4EE3;
the zoom is absent from `present_game_screen(_follow)`, the pwin frames and the S1 check;
`w16q_draw_on` uses a stack DC and read-only lookups; A-3b's split showed no bit-level difference by
inspection (G-1 and V0 then confirmed every frame hash). Its baseline caveat: `claude/` is untracked,
so A-3b was reviewed as current code, not as a diff. Findings and what was done:

| # | Finding | Done |
|---|---|---|
| 1 | a stale layer after a show that is not a core present (a profile switch, `present_start_profile`, `present_set_options` through `show_all`): the old layer re-put over the redrawn base frame until the next core present, against D 5.2 | `pmap_overlay` and `pmap_restore` evaluate the activity again at every show while a level or a layer is set; `test_map` case (the options re-evaluation) |
| 2 | the zoom chords consumed under `CIV_OBSERVER 0` (arrive.c is always compiled) although the zoom is refused there | `zoom_key` returns no command under `!CIV_OBSERVER`: the keys reach the game (deviation row) |
| 3 | `w16_rast_fill`'s int16 wrap for coordinates beyond the 16-bit range (the API path's pattern, as BitBlt's; reachable through `w16q_draw_on`'s int32 offsets) | `w16q_draw_on` refuses any coordinate that leaves the 16-bit range with its offset; the API path unchanged (pre-existing; recorded) |
| 4 | a stack overflow: `w16q_draw_on`'s DrawText did not bound the text length (`w16_text_box`'s 512-byte line buffer) | text cut at 512 bytes, as the API wrappers cut it |
| 5 | an unbounded surface stride (`y * stride` in int32) | a surface of more than 2^31 bytes refused |
| 6 | an unknown font drew with the system face, against the header's promise of -1 and a bad handle | an unknown non-zero HFONT gives -1 and counts a bad handle; 0 is the system font; `w16_obs.h` updated |
| 7 | A-3a: `g_outline_on` survived a loop aborted by a fault, so `w16q_sys_track` could report a stale band in a later run of the same process | the band cleared at the loop's end and by the new `w16_syscmd_reset` from `w16_user_reset` |
| 8 | a held view press after the layer goes (a zoom during a drag, a switch, the map window gone, the size wait): its moves and release went to virtual (0, 0) with frame 3, against RV2-3 | `PI_LAYER_GONE` from the layer's classification when no layer is drawn; the latched part then takes the visible frame's mapping (deviation row); `test_map` case |
| 9 | the ring click's move cleared both buttons' bits (a right button held under another latch seen released) | only the left button's bit is cleared; `test_map` case |
| 10 | the small map's region cut at 64 rectangles, so a point in a more fragmented region may be refused | kept (conservative: such a press is not delivered); recorded |
| 11 | `profiles.log`'s map hash can lag the picture by one render (the sample, tick step 4, before the overlay, step 7) | kept (deterministic); recorded for `ext_zoom.py` (Mb) |

The geometry, limits, wrap and poles, anchors, clamps, following, wheel, ring translation and the
command line were checked against D 4.2, 4.3, 4.4, 11.1..11.3, 12.2, 12.3 and 13 without finding.
The fixes were not re-reviewed; the final cycle ran on them (`test_map` 85 → 96 checks).

## Deviations from the design

| Design | What | Why |
|---|---|---|
| D 17 A-4 (`PiOut` gains `cmd_hx`, `cmd_hy`) | `PiOut` also gains `cmd_steps` (the wheel's whole steps, 1 for a chord) and `cmd_at` (1 when `cmd_hx`, `cmd_hy` are an anchor); `pmap_zoom_command(cmd, steps, at, hx, hy, &reason)` turns them into a level (0 changed, 1 unchanged, -1 refused) | one `WM_MOUSEWHEEL` may carry several notches (12.3 "each 120 is one step"); the chords and the menu use the centre anchor, the wheel its point (11.1) |
| D 3 (`pmap.h`) | the interface adds `pmap_zoom_command`, `pmap_in_refused` (the menu's gray), `pmap_restore` (the base frame's give-back before the overlay), `pmap_active`, `pmap_layer_image` (A-6's hash) and the test seams `pmap_test_map`, `pmap_test_smmap`; `pmap_src_current` is not in Ma | each serves a caller of this unit; the snapshot reader (7.2) is Mb's |
| A 10.1 / D 12.1 (frame 3 for a latched view press) | `PI_LAYER_GONE` (-1): when no layer is drawn the classification says so and the arrival stage maps the held press's remaining parts by the visible frame | review finding 8: the press's moves and release otherwise went to virtual (0, 0); the visible frame's point is what the picture then shows |
| D3b2's deviation row (capture-loss release "per button from M on") | built: each latch keeps the last point and frame delivered for its button; a capture-loss release uses its own | D3b2 review finding 10; the coordinates and the frame agree per button |
| D 13 (the chords) | under `CIV_OBSERVER 0` Ctrl+Shift+Plus/Minus/0 are not chords: they reach the game | review finding 2; such a build has no zoom, and the G-1 baseline must not depend on swallowed keys |
| D 13 (system menu) | the three items request their level directly (out = -1, normal = 0, in = +1); all three grayed in a `CIV_OBSERVER 0` build | radio items name levels; without the observer every level is refused |
| D 13 (harness) | `zoom 1` is accepted beside `+1`; `zoom 0` goes through `pmap_request_zoom`, `zoom reset` through `pmap_zoom_command` (the chord's path); `presented.log`'s field is `zoom L` with L in -1, 1 (no plus sign) | `--zoom` and civ64 keep the design's spelling (`--zoom 1` refused); V4's cycle exercises both reset paths |
| D 17 A-6 (`profiles.log` "map hash per profile") | ` map windows SHA` (the layer image, indices or XRGB) on each sample line while the level is not 0; the DOS map's hash comes with D6 | Ma has the Windows layer only; the hash may lag one render (review finding 11) |
| D 17 A-6 | `presentation-diag.log` (harness) and `present_diag_log` gain the `pmap ...` line: the counters and the geometry (map client, view, layer rectangle, origin) | 7.8's ring point is computed from the map client; the counters are D 18's failure counts |
| D 16.4 ("every scenario and S1..S5") | V4 runs the P0 matrix's 27 runs; the soaks S4 and S5 are not P0 runs | as V0..V7 in D3b1 and D3b2 |
| D 16.5 ("the equivalent hwnd-form small-map click script") | the reference `ringref` is host-form: unzoomed host clicks at the posted points | the 7.8 mode takes host-form input only (an hwnd-form line inside a host-input file is refused, D3b2); host clicks at `3x + 1, 3y + 1` post exactly the small-map messages |
| D 16.5 ("a click on a covered in-view point posts nothing") | covered points are unit-tested only (`test_map` input and translation sections) | S3 has no window over the map at the click times; a script that opens one would change the scenario's checkpoints |
| D 16.5 (`zoomkeys` vs plain) | the plain reference runs at the default host size, `zoomkeys` at 1920x1440 | the comparison is of core input, frames, snapshots and events, which the host size does not change (V3, V6r) |
| D 18 (palette reconversion ~4 ms) | under `fit` sharp a reconversion costs a full render (25 to 40 ms at 4.4 M pixels) | the sharp layer keeps weighted XRGB (5.4); a cheaper path is a seam for Mb |
| D 17 A-3 (`w16q_draw_on`) | also refuses surfaces over 2^31 bytes and coordinates outside the 16-bit range with their offsets; cuts text at 512 bytes; hfont 0 is the system font | review findings 3..6 |
| D 17 A-3a | `w16_syscmd_reset` (from `w16_user_reset`) and a cleared band at the loop's end | review finding 7 |
| D 17 B-3 (area B's) | delivered by Ma in `scale.c` | the layer needs both functions; B had not added them |
| — (`ext_p0.py`) | `refusal_checks` removes its run and output directories before each refusal | the final cycle's CheckedNoObs failure (above) |

## Seams for Mb

* **The ring** (`pmap_ring_px(x, y)` in `pmap_layer.c`, declared in `pmap_int.h`): black until Mb; Mb
  replaces it with the world canvas's index (Windows rules over the snapshots, 7..9). Every ring
  pixel already goes through it, after the in-view test and the pole test, for nearest and sharp.
* **Damage**: `pmap_layer_damage_world(x0, y0, x1, y1)` (linear world rectangle, wrap handled by the
  caller's copies) marks the host pixels; `pmap_layer_damage_all(reconvert)` for a palette change.
  `pmap_pending()` makes the tick show (A-1).
* **The snapshots' triggers**: `pmap_on_probe` already receives DrawTilesToPort's and
  RedrawMapRect's exits (the view snapshot), BlinkActiveUnitUntilInput's and AnimateUnitMove's
  entries (the follow); A-7's other probes (TileCacheLookup, DrawUnit, UpdateUnitSightAndContacts,
  DeleteUnit, ProcessGameTurn, ResolveCombat, DrawTile) reach it and are ignored. `pmap_on_event`
  receives every observer event (`OBS_BITMAP` damage on the map port is used now).
  `pmap_src_current` (7.2) is to be added.
* **`M`** (`pmap_g.m`, `mw` x `mh`, the client's indices at the last core present; `pmap_m_px`,
  `pmap_in_view`): the mirror checks (`ext_mirror.py`, 10.2) can compare it with the model's view.
* **`w16q_draw_on`** for the world canvas's labels, unit flags and lines (A-3b; bounds above).
* **Counters**: `map_no_memory` and `map_bad_read` exist as names in D 18; `bad_read` counts the
  failed reads of the map window, the view and the small map; the canvas's allocation failure
  (`map_no_memory`) is Mb's to add to `pmap_diag`.
* **Test seams**: `pmap_test_map(map, view, fill)` and `pmap_test_smmap(smmap)` set the map window
  and the small map without an emulation; `test_map.c`'s helpers build layouts and synthetic `M`.
* **For `ext_zoom.py`**: `presented.log`'s `zoom L view CWxCH view_sha256 SHA`, `--dump-presented`'s
  `view-NNNNN.bmp`, `profiles.log`'s `map windows SHA` (one render late, review finding 11), the
  harness `zoom` command and `--zoom`. The goldens must be made after Mb's ring, since the ring
  shows in the view hashes at -1 now as black.
* **Sharp cost**: a reconversion under `fit` sharp is a full render (above). A cheaper path for the
  palette cycling (for example keeping the index taps and re-weighing only pixels whose taps use a
  cycled entry) is open.
* **The agent UI check** (civ64 with a visible window, Mb): the menu items, the chords, the wheel,
  `--zoom` and the settings key `zoom` were tested headless and Win32-headless only.

## For the records

The orchestrator applies these; Ma did not edit the files.

* **DESIGN.md 12.2** (S2's window): the system menu gains, after "Locate DOS files...", a separator,
  "Zoom &out (half)\tCtrl+Shift+Minus" (0x10C0), "&Normal map zoom\tCtrl+Shift+0" (0x10D0), "Zoom &in
  (double)\tCtrl+Shift+Plus" (0x10E0) as radio items marking the level (Zoom in grayed while +1 is
  refused; all three grayed without the observer), then the separator and About. The Chords bullet:
  Ctrl+Shift+Plus/Minus/0 (main row and keypad) audited in Ma (this record), taken by the arrival
  stage's hold rule, not chords under `CIV_OBSERVER 0`. The wheel over the map client zooms (12.3).
  `--zoom default|-1|0|+1` and the settings key `zoom` (written on the player's change only). Tests:
  `test_host_win32`'s zoom items and the About position.
* **DESIGN.md 12.5**: tick step 5 (A-1: a core-frame profile returns only without `pmap_pending()`;
  step 7 then shows the layer's damage as a TICK show); `layer()` after every scaling (A-2; CORE,
  VIEW, TICK); `pmap_on_core_present` in every profile; the map listener (three of the four
  listeners in a DOS run); `PiOut.cmd_steps`/`cmd_at`; `PI_LAYER_GONE`; the latch's per-button point
  and frame for the capture-loss release; frame 4 to `pmap_filter_ring`. "Tests": `test_map`,
  `ext_p0.py` V4 and the CheckedNoObs zoom refusals, `ext_adapt.py`'s zoomkeys, ring and ringref.
* **DESIGN.md 12.9**: Ma as built (this record): the files of `present/map`, the geometry, clamps,
  anchors and follow, the activity rules and counters, the composition with the give-back, `M`, the
  input rules, the ring click; the ring black until Mb; the measured costs (sharp reconversion);
  D8 answered.
* **DESIGN.md 12.10**: `user_syscmd.c` (A-3a: `g_outline`, `g_outline_on`, `w16_sys_track_info`,
  `w16_syscmd_reset` from `w16_user_reset`); `gdi_draw.c` and `gdi_font.c` (A-3b: `w16_paint_brush`,
  `w16_rast_fill`, `w16_rast_frame`, `w16_rast_line`, `w16_text_draw`, `w16_text_box`); `w16_obs.c`
  (`w16q_sys_track`, `w16q_draw_on` with its bounds); `scale.c` (B-3). G-1 equal after each.
* **DESIGN.md 12.11** (P0): the zoom's P0 evidence (V4, the CheckedNoObs refusals, the review).
* **FIDELITY.md**: F129 (level -1 uneven at odd k), F130 (the ring press) and F132 (what the zoom
  covers): implemented in Ma (2026-10-11; this record). F130 gains: the press's move clears only the
  left button's bit; the small map's visibility includes its data block's flag (+0x2C) that
  `CenterMapOnSmMapClick` tests; at level -1 the ring is black until Mb, so a ring click recentres on
  a square the player cannot yet see. F114 (the hold rule) covers the zoom chords too; with Num Lock
  on the keypad reset may not arrive (D 13). The D8 answer (a release removed by `FlushInputEvents`
  leaves the button up in w16) for the small-map path.
* **RUNNING.md**: civ64's zoom items, the chords, the wheel over the map, `--zoom default|-1|0|+1`
  (`0` and `default` the same; refused in a `CIV_OBSERVER 0` build), the settings key `zoom`. The
  harness: `at <ms> zoom -1|0|+1|reset` (also in host-input files), `--zoom`, `presented.log`'s
  `zoom L view CWxCH view_sha256 SHA` and `zoom refused <reason>`, `view-NNNNN.bmp` with
  `--dump-presented`, `profiles.log`'s `map windows SHA`, the `pmap ...` line of
  `presentation-diag.log`; `ext_p0.py` V4 and `ext_adapt.py`'s M runs (in `test.cmd checked`).
* **FEATURES.md**: none (no game feature changed; the zoom is presentation).
* **STATUS.md** (extension track): Ma complete in Checked, CheckedNoObs and Release on 2026-10-11
  (this record); the ring black (interim) until Mb; Asan deferred; next Mb (snapshots, the ring's
  Windows rules, the mirror checks, `ext_zoom.py`, the agent UI check, the M gate).
* **manual-checklist-ext.md** M (pending, user): M-1 can be checked now; M-2's click can be checked
  now but the ring is black until Mb (the click still recentres). Add: Ctrl+Shift+Plus, Minus and 0
  and the wheel over the map change the zoom (the wheel keeps the point under the pointer); the
  system menu's zoom items mark the level and "Zoom in" is grayed when the map window is too small;
  plain `=`, `-` and `0` still reach the game; the zoom is remembered at the next start (the `zoom`
  key) unless `--zoom` is given; at +1 the zoomed map follows the active unit.
* **The D1 drafts (draft D)**: 3's interface additions; A-4's `cmd_steps`/`cmd_at`; A-6's
  `map windows` and the `pmap` diag line; 12.1's `PI_LAYER_GONE`; 13's chords under `CIV_OBSERVER 0`,
  the grayed items and the harness spellings; 16.4's 27 runs; 16.5's host-form reference and the
  covered click as a unit test; 18's sharp reconversion cost; Open D8 answered; B-3 delivered in Ma.
  Draft A 10.1: the capture-loss release per button is built.

## Not verified

* **The ring** is black at -1 (the interim state); the Windows rules for it, the snapshots, the
  world canvas, the mirror checks (7.5), `ext_zoom.py`'s goldens and determinism (16.3) are Mb's.
* **RedrawMapRect's exit** (the second view-snapshot trigger) is never reached by any run (D3's
  never-hit list); its view-snapshot path (the window-port argument test, then the same `take_view` as
  DrawTilesToPort's) is checked by reading only.
* **civ64 with a window**: no visible window was shown; the menu items' drawing, the real keyboard's
  chords, the wheel's delivery, `--zoom`'s message box under `CIV_OBSERVER 0` and the settings key
  `zoom` across starts are tested only headless or Win32-headless (the agent UI check is Mb's; the
  user's M-1, M-2 pending).
* **The move/size outline** (`w16q_sys_track`) is cut from the clip by code reading only: no run
  drives the system move or size loop with the layer active.
* **The recentring in 7.8**: the runner does not read the core's view after the ring click; the
  target square is checked in `test_map` (above) and the marks show the small-map branch ran.
* **Covered clicks and refused ring presses in 7.8** (a window over the map, a hidden small map):
  unit tests only.
* **The costs** are means of ten renders on this machine under varying load; D 18's palette cycling
  load was not measured in a run.
* **Asan**: deferred by the user; not built or run.
* **A-3b's bit equality** is shown by G-1 and V0 (every core frame hash of the 77 G-1 runs and the
  27 P0 runs) for the drawing those runs reach; DrawText formats and pens that no run uses are equal
  by inspection only.

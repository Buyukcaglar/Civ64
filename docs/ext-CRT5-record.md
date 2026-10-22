# Extension unit CRT5 (the CRT scanlines at every output scale) - record

## Result

"CRT scanlines" now shows its gaps in the Windows graphics at every size. Before, at the usual sizes the Windows
graphics had no scanlines at all: in the default 1280 x 960 window, full screen with integer scaling on a 1920 x 1080
or a 3840 x 2160 screen, and the game screen at the same factors, every host row got the same weight (the picture was
evenly dimmed, no gaps); with fit on a 1080-line screen the gaps were faint slow bands. Only 2560 x 1440 (3x) and fit
on a 2160-line screen showed them. The fix keeps CRT4's scanlines wherever they showed (every accepted DOS look, byte
for byte) and elsewhere draws them on the host rows, one every two host rows. CRT5b (the user's addition below): in
a window the scanlines no longer shrink with the picture; they are spaced exactly as full screen on the window's
monitor (the same period, darkness and rule in screen pixels at every window size, both graphics). CRT2's sharpness
and speed are unchanged.

## Status

Landed 2026-10-21 as CRT5 and CRT5b (see "Landing"); user checks CRT5-1..CRT5-4 pending (build
`build/user-builds/crt5/`, which has both).

## The user's words

The user, 2026-10-21 about 00:00 UTC (verbatim, through the orchestrator): "It seems like 'CRT Scanlines' option does
not being applied to Windows graphics properly, check and verify."

The user's addition, 2026-10-21 about 00:30 UTC (verbatim, through the orchestrator): "I think I understand the
underlying perception problem, when I switch to full screen I see the filter clearly and as it should be, but when
windowed mode, I think the filter also scaled down along with the graphics, so that I can not distinguish it. Filter
shall be applied to canvas all at all resolutions in the same manner." The orchestrator's reading: the scanline look
in a window shall equal full screen on that monitor (thickness, spacing, darkness in screen pixels), the period
derived from the full-screen geometry of the window's monitor, in both graphics, at every window size (CRT5b, landed
in the same user build).

## Findings (measured)

* **One path.** Every client drawing goes through `show()` -> `crt_sync` -> `present_crt_apply` (present.c); the
  Win32 back end only BitBlts the filtered DIB (host_win32.c `host_show`); the only native windows are civ64's own
  message boxes (host UI). The game's menus, dialogs, Windows 3.1 controls and the WL canvas with its menu tile are
  pixels of the frame, so they take the filter. Measured: the Windows screen and the game screen sent end to end
  through `present_core` with the option on give exactly the rows of the filter applied directly (`e2e=direct` in all
  48 Windows cases).
* **The fault (inferred from the code, confirmed by measurement).** `present_crt_set` gives image row e the weight
  at its centre, py = (e + 0.5) x lines / sh. With P = sh / lines host rows per scanline equal to 1, every row lies
  on a scanline centre (a = 0); with P = 2, every row a quarter scanline off one (a = 0.25): all rows the same weight,
  no gap. Just above 1 or 2 the rows drift slowly through those phases (bands). CRT4 doubled the Windows screen's
  scanlines to 960, which put its common sizes exactly on P = 1 and 2 (2x and 4x).
* **Measurements** (`build/crt5-stage/obj/measure/measure.c`, the tree's Checked objects; a white picture, the
  centre column; `base.txt`, `stage.txt`; "flat": source rows whose brightness varies under 10 %):

| Windows graphics (640x480 and game screen) | P | base gaps / flat rows | CRT5 gaps / flat rows |
| --- | --- | --- | --- |
| 1920x1080 integer (2x), 1280x960 window, 1904x1001 integer | 1.000 | 0 / all (480, 540) | 479..539 / 0 |
| 1920x1080 fit 1440x1080 | 1.125 | 120 of 960 / 360 of 480, depth 0.03..0.11 | 539 / 0, depth 0.20 |
| 1904x1001 fit 1334x1001 | 1.043 | 41 / 480 | 500 / 0 |
| 2560x1440 integer or fit (3x) | 1.500 | 480 / 0, depth 0.17 | unchanged |
| 2544x1361 fit | 1.418 | 401 / 0, depth 0.11..0.20 | unchanged |
| 3840x2160 / 2560x1920 integer (4x), 3824x2081 integer | 2.000 | 0 / all | 959..1079 / 0, depth 0.20 |
| 3824x2081 fit | 2.168 | 959 / 0, depth 0.10..0.20 | 1040 / 0, depth 0.20 |
| 3840x2160 fit | 2.250 | 959 / 0, depth 0.18..0.20 | unchanged |

  DOS: the N frame (320 x 200, 4:3 or square) at P 2.4..5.4 (every full-screen size measured) 399 gaps, depth 0.19,
  unchanged; at P = 2 (1280 x 960 integer) and DOS A frames at P = 2 (integer on 1080-, 1361- and 960-row clients)
  base 0 gaps, now one per scanline; P 2.085 (A frame, fit 1904 x 1001) base 44 of 240 rows flat, now 0. Of the 144
  measured cases 90 are byte-identical to the base (all with P >= 2.25 or 1.4..1.75) and the 54 changed are exactly
  the failing ones. `compare.png` there: base (left) and CRT5 (right) at 1080p integer, 1080p fit, 1440p, 2160p.
* **The sweep** (`sweep.py`, CRT4's sampling at every P from 1 to 12 for 200-, 480- and 540-row sources): the
  weakest source row's gap (1 - darkest/brightest weight; at most 0.454) is 0 for P < 1.35 and at 1.95..2.0, under
  0.19 at 1.35..1.4 and 1.75..2.2, and at least 0.19 at 1.4..1.75 and from 2.2 (0.32 from 2.25).

## Design (present/crt.c, crt.h)

* `present_crt_grid_rule(sh, lines)`: with P = sh / lines (integers: 4 sh >= 9 lines, or 5 sh >= 7 lines and
  4 sh < 7 lines) CRT4's per-row sampling is kept at P >= 2.25 and 1.4 <= P < 1.75; otherwise 1 (the grid).
* `present_crt_set`: with the grid, image row e gets a = 0 on even rows (weight 1, level 255) and a = 0.5 on odd
  rows (0.546, level 139: the darkest weight the shader gives, a uniform area's gap); `PresentCrt.grid` records it.
  Without it the levels are computed exactly as before (the same expression, now in `level()`).
* Unchanged: `present_crt_scanlines` (two per source row, CRT4), `crt_sync`, the apply loop, the tables, no reach.
  The grid is the "output-space period never below two host rows" rule: at 2x one gap under every source row, at 4x
  exactly two per source row (CRT4's double scan), at fit as many as the host rows allow (1080p fit: 540). Below two
  host rows per source row double scanning cannot be shown on any screen.

## CRT5b: the window's scanlines as full screen (present/crt.c, crt.h, present.c, present.h, host_win32.c)

* **Finding.** The scanlines followed the window's own image: two per source row spread over the window's image rows,
  so a smaller window had proportionally finer (or, through CRT5's rule, differently ruled) scanlines than full screen
  on the same monitor. Measured (`build/crt5b-stage/obj/measure5b.c`; monitors 1920 x 1080, 2560 x 1440,
  3840 x 2160; the Windows screen 640 x 480, a 960 x 540 game screen, DOS 320 x 200 at 4:3; integer and fit; windows
  1280 x 960, 1000 x 700, 1600 x 1000, 1904 x 1001 where they fit: 72 window / full-screen pairs): with CRT5 alone 34
  of the 72 windows had other rows than full screen (`m5b-crt5.txt`), e.g. DOS 320 x 200 in the 1280 x 960 window on
  a 1080-line monitor: a gap every 2.0 rows against 2.5 full screen; in a 1000 x 700 window every 3.0.
* **Rule.** `present_set_screen(w, h)`: the back end gives the full-screen client of the monitor its window is on
  (host_win32.c `screen_sync`: `MonitorFromWindow` nearest, `rcMonitor`'s size, the rectangle full screen covers,
  `hw_set_fullscreen`; read at every client resize, `WM_MOVE` (another monitor) and `WM_DISPLAYCHANGE`).
  `present_crt_period_rows()`: the image rows the shown frame has full screen there - the layout of the same frame
  size, policy, filter and pixel aspect in that client (scale.c) - or the window's own image rows without a monitor
  (the headless host, so every harness run is unchanged). `crt_sync` then makes the tables with
  `present_crt_set_period(c, L, gw, 2 x rows, ph)`: image row e's weight is the one of full-screen row e
  (py = (e + 0.5) x 2 rows / ph) and CRT5's grid rule is decided on (ph, 2 rows), so the window's rows equal the full
  screen's first rows: the same period, darkness and phase in screen pixels at every window size. In full screen
  ph is the image's own rows (nothing changes there). A monitor change while the option is on draws the whole client
  again. Speed: the per-pixel work is unchanged (the tables are per row).
* **Measured with the rule** (`m5b.txt`): ALL_EQUAL - in all 72 pairs every window image row equals the full
  screen's row of the same index; e.g. DOS 320 x 200 on 1080p: full screen 1000 rows, 399 gaps, 2.506 rows a gap,
  depth 0.19; the 1280 x 960 window 800 rows, 319 gaps, 2.508, 0.19; the 1000 x 700 window 600 rows, 239 gaps,
  2.510, 0.19. The Windows screen on 1080p: full screen and every window a gap every 2.0 rows, depth 0.20.
* **Approximation (inferred):** for the game screen and the windowless canvas, whose size follows the client
  (F105/F110), the reference is the same frame size laid out full screen; full screen itself shows a larger frame at
  the game's kept scale. Where both give two or fewer rows per scanline (the usual case) the rule's two-row grid
  makes them equal; otherwise the period can differ from a later full-screen game screen.

## Deviations

* F345 (amends F343's small-picture note): the scanlines lie on the host rows where the source-locked ones would not
  show; the count is then the host rows / 2 rather than exactly two per source row (at 2x one per source row).
* At P 1.4..1.75 (the Windows screen at 3x: 1440 host rows) CRT4's look stays: one gap per source row (two host rows
  per scanline are not available).

## Tests

* `tests/test_crt.c` 36 checks (25 before): `robust()` - a gap (some row of each source row at most 0.85 of its
  brightest level) in every source row of the Windows screen at 2x and 4x, the game screen 960 x 540 at 2x and 4x,
  the Windows screen at fit 1440 x 1080 and 1334 x 1001, DOS 320 x 200 at 1280 x 800 and a DOS A frame at fit
  1334 x 1001 (8 checks); CRT4's levels unchanged at P 1.5, 2.25, 2.5, 2.7, 4 and 5.4; the rule at six P; the Windows
  screen (Windows 3.1 gray) in a 1280 x 960 view through the presentation: every pixel row's lower host row at most
  0.85 of its upper. **Fails on the base**: the base has no `present_crt_grid_rule` (no build); the same checks with
  that part stubbed against the base filter (`obj/measure/test_crt-base.exe`): 8 failures (480, 540, 480, 540, 240,
  480 and 200 source rows without a gap; the 2x view C8C8C8 over C8C8C8). Golden and timing unchanged (8.5 ms).
* CRT5b: `windowed()` (5 checks, 41 in all): through the presentation, a white frame full screen on a monitor and in
  a window on it (`present_set_screen`): 320 x 200 at 4:3 in a 1280 x 960 window on 1080p and in a 1000 x 700 window
  on 1440p, 640 x 480 in a 1280 x 960 window on 1440p and on 1080p - the window's image rows equal the full screen's
  first rows, the period rows equal the full screen's image rows, gaps present; without a monitor the window's own
  rows (CRT5's grid). Fails on CRT5 (no `present_set_screen`: no build; measured 34 of 72 pairs differing).

## For the records

* FIDELITY: F345 added, F343's note amended (applied in this unit).
* DESIGN (CRT section): the grid rule (left to the docs pass). RUNNING / FEATURES: no change of wording needed beyond
  "the gaps show at every size" (left to the docs pass).

## What the user checks

* **CRT5-1** Windows graphics, Display > CRT scanlines on, full screen (Alt+Enter, or Full screen in the window's menu): the
  intro, the title menu, the setup screens and the game show even, regular dark scanline gaps over the whole picture,
  menus, dialogs and buttons included, with integer scaling and with fit; no slow bands, no part without gaps. Before
  (build "crt4") integer scaling on a 1920 x 1080 or 3840 x 2160 screen showed no gaps at all.
* **CRT5-2** Compare windowed with full screen: switch between them on the same screen (and resize the window,
  smaller and larger) while the title menu or the game is shown. The scanlines in the window look exactly as full
  screen: the same thickness, the same spacing and the same darkness on your screen; they do not get finer or fainter
  when the window is smaller (only the picture is smaller). Before, they shrank with the window.
* **CRT5-3** The same comparison in the DOS graphics (intro, Birth scenes, title, map, city screen): full screen as in
  build "crt4" (two gaps per DOS row), and the window the same gaps as full screen.
* **CRT5-4** Windowless play (Windows graphics) with the option on, windowed and full screen: the canvas, the menu bar
  with its background tile and the floating windows show the same even gaps; the picture as sharp and as fast as with
  the option off; with the option off no gaps anywhere.

## Expected changes at the build slot

* CRT5: test_crt 36 checks (25); CRT5b: 41. Golden unchanged; every other count and golden unchanged (the option is off by default; no
  harness run turns it on). P0 unchanged (presentation only). ext_g1 runs 77 unchanged.

## Rebase notes

Bases: `BASE-SHA256.txt` (the tree's present/crt.c, crt.h, tests/test_crt.c and docs/FIDELITY.md on 2026-10-21
about 06:00 UTC, after WL5). present.c unchanged (it includes crt.h: recompiled). Edits: anchored Edit-tool
replacements, LF kept. Private tools under `obj/measure` (mk.cmd, mk-stage.cmd, mk-base-test.cmd, measure.c,
sweep.py, summ.py).

## Landing

CRT5 and CRT5b landed at the build slot on 2026-10-21 (times UTC).

* **CRT5** bases as staged (the tree after WL5). Copy-in 06:09:50 (`build/a43-prep/land.py crt5 --write`: crt.c,
  crt.h, test_crt.c, LF as the tree; `build/crt5-prep/landed.sha256`, `tree-before/`) and docs/FIDELITY.md (F345, F343
  note) after its base check (`FIDELITY.before.md`). Cycle (`build/crt5-status.txt`): 1 `build.cmd checked` BUILD_OK
  06:09:59..06:13:42; 2 `test.cmd checked` TESTS_OK 06:13:42..06:45:05 (test_crt PASS 36); 3 `ext_g1.py check`
  EXT_G1_OK runs 77: **ALL_GREEN** 06:45:06; 4 Release BUILD_OK 06:49:49: **RELEASE_OK**. As predicted.
* **CRT5b** (the user's addition arrived during CRT5's test step; staged in `build/crt5b-stage`, bases the tree after
  CRT5's copy-in; overlay test PASS 41). Copy-in 06:50:00 (6 files: crt.c, crt.h, present.c, present.h,
  host_win32.c, test_crt.c; `build/crt5b-prep/`) and docs/FIDELITY.md (F345 extended). Cycle
  (`build/crt5b-status.txt`): BUILD_OK 06:54:13; TESTS_OK 07:24:55 (test_crt PASS 41, timing 22.5 ms under load,
  bound 120); EXT_G1_OK runs 77: **ALL_GREEN** 07:24:56; Release BUILD_OK 07:28:30: **RELEASE_OK**. As predicted
  (every other count and golden unchanged).
* **User build** `build/user-builds/crt5/` from CRT5b's Release (civ64.exe 5,019,648 bytes, sha256
  85e706b2...38fae9f02), with CIVWIN.zip, civdos.zip, CAE3540B.SAV and, from build "wl5", CHIEF.SAV, MusicSfx.zip and
  civ-winmenu-bg.png. FIDELITY F345.
* **Back-out**: CRT5b `build/crt5b-prep/tree-before/` and `FIDELITY.before.md`; CRT5 `build/crt5-prep/` likewise.

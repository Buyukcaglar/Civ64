# Extension unit CRT4 (the CRT scanlines double-scanned everywhere) - record

## Result

With "CRT scanlines" on, every picture civ64 shows is double-scanned: two scanlines per source pixel row, in the DOS
graphics (as CRT3: 400 over the 320 x 200 picture) and now also in the Windows graphics (the 640 x 480 screen gets 960
scanlines), the intro, the Birth scenes, the title and setup screens and the game, full screen and windowed, windowless
play and every scaling. CRT2's sharpness and speed are unchanged.

## Status

Landed 2026-10-20 (see "Landing"); user checks CRT4-1..CRT4-3 pending (build `build/user-builds/crt4/`).

## The user's words

The user, 2026-10-20 about 22:00 UTC (verbatim, through the orchestrator): "1. Apply double-scan to everywhere when
selected, regardless of graphics mode and resolution, including intro birth scenes and also windows graphics. 2. Your
menu work accepted just export pattern tile I'll rework it me it seamless, current tile when used as background displays
its borders" (item 2 is the tile export in `build/e5rev/`, not part of this unit).

## Design (present/crt.c, crt.h, present.c, present.h)

* `present_crt_scanlines(rows)` now returns `2 * rows` for every frame (CRT3: `mode_lines < 350 ? 2 * rows : rows`,
  with the mode argument removed). `crt_sync` passes the shown frame's source rows (the DOS A frame's DOS rows, any
  other frame's own rows: the Windows screen 480, a larger game screen or the WL canvas its rows).
* There is one filtered path: every client drawing goes through `show()` -> `crt_sync` -> `present_crt_apply`, so the
  intro, Birth, title/setup and game screens of both graphics, full screen, windowed and windowless, all take it.
* Everything else is CRT2's: the per-row weight own + neighbour of the shader at T = 0.65, the tonal curve, the
  256 x 256 factor table, no resampling, no reach; the cost per pixel does not depend on the scanline count.

## Deviations

* F343 (amends F342): the Windows graphics' 480-line screen and every other frame are double-scanned too, against
  VGA's and DOSBox Pure's rule (only modes below 350 lines); the user's direction.
* Small pictures (inferred, not measured): with fewer than about two host rows per scanline - the Windows screen shown
  less than about 1920 host rows high, e.g. 1440 x 1080 at 4:3 on a 1080p screen (1.125 host rows a scanline) - the
  960 scanlines are finer than the host rows; each host row keeps its place's weight, so the gaps can be faint or form
  a slow band pattern (no moire control, as CRT3's note 4 for small DOS windows). At 3x (1920 x 1440) each Windows row
  shows bright-dark-bright host rows: one thin gap per scanline pair.

## Tests

* `tests/test_crt.c` (25 checks, count unchanged): `doublescan()` - the 200- and 240-line modes 400 and 480; now the
  350-, 400- and 480-line modes and a 613-row canvas 700, 800, 960, 1226 (CRT3: single); the DOS gap count 399 against
  199 unchanged; `option()` - the Windows screen's scanlines through the presentation 960 (CRT3: 480). Fails on the
  base: the base's `present_crt_scanlines` takes two arguments (no build) and its Windows screen gives 480. The timing
  check (a whole 3840 x 2160 client, bound 120 ms) and the 5 x 5 golden are unchanged.

## For the records

* FIDELITY: F343 added, F342's Windows wording amended (applied in this unit).
* DESIGN: the CRT section's scanline count: two per source row everywhere (left to the docs pass).
* RUNNING / FEATURES: "CRT scanlines" double-scans every picture (left to the docs pass).

## What the user checks

* **CRT4-1** Display > CRT scanlines on, Windows graphics: the intro, the Birth scenes, the title and the setup
  screens and the game show twice as many, half as thick, dark gaps as in build "wl4crt3" (two per Windows pixel row),
  full screen and windowed; the picture stays as sharp and as fast as with the option off.
* **CRT4-2** The same in windowless play (Windows graphics) and with each scaling (fit, integer, 4:3 / square): the
  gaps follow every pixel row twice; on a smaller window or a 1080-line screen say whether the fine gaps look even or
  show a band pattern (an open point, see the record).
* **CRT4-3** DOS graphics with the option on: as in build "wl4crt3" (two gaps per DOS row: intro, Birth scenes, title,
  map, city screen); the option off: no gaps anywhere.

## Expected changes at the build slot

* test_crt 25 checks (two check texts changed, count unchanged), golden unchanged; every other count and golden
  unchanged (the option is off by default; no harness run turns it on). P0 unchanged (presentation only). ext_g1 runs
  77 unchanged.

## Rebase notes

Bases: `BASE-SHA256.txt` (the tree's present/crt.c, crt.h, present.c, present.h, tests/test_crt.c and docs/FIDELITY.md
on 2026-10-20 about 22:00 UTC, after wl4crt3). Edits: anchored Edit-tool replacements, LF kept.

## Landing

CRT4 landed at the build slot on 2026-10-20.

* **Bases** as staged (the tree unchanged since wl4crt3). No private overlay build was made (the user's usage was
  near its limit; a five-file presentation change): the cycle's build step compiled every variant instead.
* **Copy-in** 22:00:06 UTC (`build/a43-prep/land.py crt4 --write`, 5 files, LF as the tree) and docs/FIDELITY.md
  (F343, F342 note) after its base check (`build/crt4-prep/landed.sha256`, `tree-before/`, `FIDELITY.before.md`).
* **The cycle** (`build/crt4-status.txt`): 1 `build.cmd checked` BUILD_OK 22:00:10..22:04:00; 2 `test.cmd checked`
  TESTS_OK 22:04:00..22:36:33 (test_crt PASS 25 checks, timing 25.2 ms under load, bound 120); 3 `ext_g1.py check`
  EXT_G1_OK runs 77 unchanged (its standing "amended 1" note): **ALL_GREEN** 22:36:33 UTC; 4 `build.cmd` (Release)
  BUILD_OK 22:36:33..22:40:23: **RELEASE_OK**.
* **Against the predictions** (`build/crt4-prep/predictions.txt`): as predicted.
* **User build** `build/user-builds/crt4/` (CRT4-1..CRT4-3). FIDELITY F343. Release civ64.exe 5,007,872 bytes,
  sha256 6a08b851...a951c52f8c.
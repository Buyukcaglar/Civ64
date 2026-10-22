# Extension unit WL5 (the user's menu background image in windowless play) - record

## Result

* **WL5** In windowless play with the Windows graphics, the drop-down menus of the canvas's menu bar have the user's
  seamless stone image `civ-winmenu-bg.png` as their background instead of the game's 32 x 32 Status tile (WL4), when
  that file lies in `civ64.exe`'s folder. civ64 reads the file at run time; it is not compiled into `civ64.exe` and not
  in the repository (it is derived from the game's art). Without the file, or with a file civ64 cannot use, the menus
  show WL4's game tile. Text, gray items, borders, shadows, separators, the highlight and the bar's gray are WL4's.

## Status

Staged in `build/wl5-stage/` and landed at the build slot (see "Landing"); user checks WL5-1..WL5-3 pending (build
`build/user-builds/wl5/`, with the user's `civ-winmenu-bg.png` beside `civ64.exe`).

## The user's words

2026-10-20 about 23:00 UTC (verbatim, through the orchestrator): "Grab and use
'%USERPROFILE%\Downloads\civ-winmenu-bg.png' for the windowless play windows graphics mode menu background."
The orchestrator: the image is the user's seamless rework of the Status stone tile WL4 uses behind the drop-down menus
(`build/e5rev/status-tile.txt`; the "menu-tile.png" sketch in `build/crt4-stage/STATE.md`).

## The image and the scale (DOS file: none; inferred from the file's pixels)

* The user's file (copy `build/e5rev/civ-winmenu-bg.png`, read-only): 512 x 512, 8-bit RGB, non-interlaced, two
  colours, (128, 128, 128) 152,064 pixels and (96, 96, 96) 110,080 pixels: the game tile's mid and dark gray (system
  palette 14 and 13, `status-tile.txt`); the tile's four light-gray (159, 159, 159) pixels are gone.
* It is made of exact 4 x 4 blocks (every pixel equals its block's top-left pixel; not 8 x 8) and repeats with a
  period of 128 file pixels across and down, also across its edges (seamless). Taken at 4 file pixels a game pixel it
  is a 128 x 128 picture whose own period is 32 (0 of 16,384 pixels differ from the 32 x 32 tile repeated), and that
  32 x 32 tile equals the game's Status tile in 919 of 1024 pixels at the same origin (the reworked seams).
  (`build/wl5-prep/analyse.py`; the port's decoder gives the same picture: `build/wl5-prep/tool/pngcheck.c`,
  `compare.py`: `COMPARE_OK`, 0 differ.)
* **The scale chosen: 4 file pixels = 1 game pixel** (each side), so 512 file pixels = 128 game pixels = four repeats
  of a 32-pixel tile; the stones have exactly the game tile's size on screen. The menus are composed at the game's
  resolution (the windowless canvas is the frame's pixels) and scaled to the host with the rest of the canvas, so the
  picture is kept in game pixels: each 4 x 4 block becomes one pixel, the mean of its 16 colours rounded. For this file
  the mean is exact (every block has one colour): nothing is lost, and sampling at the host's resolution would show the
  same blocks. The task's suggested 16x (512 file pixels = 32 game pixels) would shrink the stones fourfold (each game
  pixel the mean of four blocks: a blur of the two grays), unlike the original on screen.

## Design

* `res/png.c`, `res/png.h` (new, portable C, no third-party code): `png_decode` reads a PNG held in memory with the
  port's own `zip_inflate` (RFC 1951) and `zip_crc32` (PNG's CRC is ZIP's): the signature, IHDR first, the chunks' CRCs,
  consecutive IDATs, IEND; non-interlaced; gray/RGB/gray+alpha/RGB+alpha at 8 bits, palette at 1/2/4/8 bits; the zlib
  header and Adler-32; the five row filters; alpha ignored. The size is checked against `max_side` before anything is
  allocated (`PNG_MAX_SIDE` 4096 at most). Every refusal is a sentence (-1), nothing to free.
* `present/wl.c` `pwl_menu_png(data, size)`: decodes with at most 512 per side; sides multiples of `PWL_IMG_SCALE`
  (4); each 4 x 4 block's mean colour (rounded) into a module picture of at most `PWL_IMG_MAX` (128) game pixels a side;
  1 accepted, 0 refused (and any previous picture forgotten: the tile again). The whole canvas is composed again at the
  next frame. `pwl_menu_image` gives the picture's size (tests, logs).
* `skin` (WL4) takes the texture from the picture when there is one, else from the scene's tile (`PwlScene.tex`,
  read by `read_skin` from g_wholeTileShapes[9], 1420:98C0, unchanged); repeat and origin (each popup's top-left) as
  WL4. `PwlScene`, the bar's gray, the white-run and highlight rules, the floats, `pwl_check` (it composes with the
  same picture) and the DOS graphics (no skin) are unchanged.
* `present/present.c` `present_set_menu_png` forwards to `pwl_menu_png` (and redraws while the canvas shows).
* `win64/civ64_main.c` `menu_image(exe_dir)`: once at the start, after the presentation options and before the
  window: `<civ64.exe's folder>\civ-winmenu-bg.png` (CreateFileW: the name in any case), at most 4 MB, read whole and
  given to `present_set_menu_png`; a missing or unreadable file or a refusal leaves the tile, without a message.
  `--windowless` and every other option are unchanged; there is no new option or menu item.
* P0: presentation and host only; core, rt and platform/w16 unchanged; no core call, no RNG draw, no `w16_present`
  added, removed or delayed. The file is never written.

## Deviations

1. **The scale is fixed at 4** (not detected from the file): a 1:1 tile or another block size must be scaled to 4 x 4
   blocks by its author. Chosen from the user's file (exact 4 x 4 blocks); one rule is predictable and documented
   (RUNNING).
2. **Means at game resolution**: a file with detail finer than its 4 x 4 blocks is averaged to game pixels (the menus
   are composed at game resolution like the rest of the canvas); the user's file has none.
3. **No message** for a refused file (as the optional files elsewhere fall back silently): the menus simply keep the
   game's tile.
4. **WIC not used**: the build's own inflate made a small portable reader possible, testable in the headless tests.

## Tests

* `tests/test_wl.c` (101 -> 116 checks): `wl5()` - PNGs written by the test (stored deflate blocks, rows filtered with
  the five filter types, a 1-bit palette image), never the user's file: without an image the popup has the scene's
  tile (the fallback); no bytes, not a PNG, a cut PNG, a damaged CRC, 6 x 8 pixels and 520 pixels wide are refused and
  the tile stays; an 8 x 8 RGB PNG is accepted as a 2 x 2 picture whose block means (one exact, one half-and-half, one
  rounded from a single pixel) appear in the popup's white from its top-left, the highlight's text, the border and the
  bar's gray as WL4 and `pwl_check` 0; a 4 x 4 palette PNG gives the two colours' mean; `present_set_menu_png(NULL)`
  brings the tile back. Fails on the base: `pwl_menu_png`, `pwl_menu_image` and `present_set_menu_png` do not exist
  there (no build).
* Private overlay (tree + this stage, `build/wl5-stage/obj/`): Checked BUILD_OK, all unit tests pass (test_wl 116);
  CheckedNoObs and Release: see `build/wl5-stage/STATE.md`.
* The user's file through the port's decoder (prep tool only): `pngcheck.exe` 128 x 128, equal to Python's decode,
  period 32 (above).
* Not run privately (usage limit): obs_lint, nodos, registry, adapters, pdos_scene_check (no present/dos file
  changed); the landing's `test.cmd checked` runs them.

## For the records

* FIDELITY: F344 (WL5, amending F341) - applied in this unit.
* RUNNING: "Where civ64 finds the game", the paragraph on the optional `civ-winmenu-bg.png` - applied in this unit.
* DESIGN: the WL section (the menu picture and the PNG reader in res/) - left to the docs pass.
* FEATURES: one line for the optional menu image - left to the docs pass.

## What the user checks

* **WL5-1** Windows graphics (Ctrl+Shift+Backspace switches), Display > Windowless play on, in a game, with
  civ-winmenu-bg.png next to civ64.exe (it is in this folder): open each menu of the top bar (File .. Help). The
  menu's background is your image's stone pattern: the same stones and size as the Status panel's texture, but
  without the grid of 32-pixel seams that build "wl4crt3" showed. The letters, the gray (unavailable) items, the
  separator lines, the black border and the shadow are as before, and the highlighted item is still blue with white
  letters as you move over the items; nothing flickers or leaves white bits behind.
* **WL5-2** Unchanged: the top bar is still the Status panel's gray (WL4-1); Windowless play off keeps Windows' white
  menus; the DOS graphics' menus are as before.
* **WL5-3** Without the image: close civ64, rename civ-winmenu-bg.png (for example to civ-winmenu-bg.off) and start
  civ64.exe again: the menus show the game's own tile as in build "wl4crt3" (with its seams), and no message appears.
  Rename the file back to civ-winmenu-bg.png for your image again.

## Expected changes at the build slot

* test_wl 101 -> 116 checks; every other count and golden unchanged (the image applies only with a file beside
  civ64.exe, which no test or harness run has; the harness never calls `present_set_menu_png`). One new portable source
  (`res/png.c`: build.cmd's portable count +1). P0 unchanged; ext_g1 runs 77 unchanged.

## Rebase notes

Bases: `BASE-SHA256.txt` (the tree's present/wl.c, wl.h, present.c, present.h, win64/civ64_main.c, tests/test_wl.c,
docs/FIDELITY.md, docs/RUNNING.md on 2026-10-20 22:55 UTC, after CRT4; res/png.c and res/png.h new). The code edits
were made with the Edit tool in the stage; the docs by `build/wl5-prep/docs_edit.py` (F344 appended; the RUNNING
paragraph after the alternative sounds' paragraph, wrapped at 118).

## Landing

WL5 landed at the build slot on 2026-10-20.

* **Bases** as staged (the tree unchanged since CRT4). Private overlay (tree + the stage) Checked, CheckedNoObs and
  Release BUILD_OK, their unit tests all passing (test_wl 116; CheckedNoObs 29).
* **Copy-in** 23:12:28 UTC (`build/a43-prep/land.py wl5 --write`, 8 files, LF as the tree) and docs/FIDELITY.md (F344),
  docs/RUNNING.md after their base check (`build/wl5-prep/landed.sha256`, `tree-before/`).
* **The cycle** (`build/wl5-status.txt`): 1 `build.cmd checked` BUILD_OK 23:12:43..23:16:47 (portable sources 312 ->
  313); 2 `test.cmd checked` TESTS_OK 23:16:47..23:48:42 (test_wl PASS 116; nodos 0 hits, 1880 files); 3 `ext_g1.py
  check` EXT_G1_OK runs 77 unchanged (its standing "amended 1" note): **ALL_GREEN** 23:48:42 UTC; 4 `build.cmd`
  (Release) BUILD_OK 23:48:42..23:52:24: **RELEASE_OK**.
* **Against the predictions** (`build/wl5-prep/predictions.txt`): as predicted. The informational coverage summary's
  "other functions entered" reads 669 (677 in CRT4's run; it does not fail and varies with the harness runs).
* **Distribution**: the Release civ64.exe holds no 32-byte piece of the user's file (checked); the file is only in
  `build/` (git-ignored) and the user build.
* **User build** `build/user-builds/wl5/` (WL5-1..WL5-3; with `civ-winmenu-bg.png`). FIDELITY F344. Release civ64.exe
  5,017,600 bytes, sha256 f8a52540...a555b6.

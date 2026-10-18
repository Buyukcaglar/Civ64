# Extension UX5, presentation unit (the 4:3 option on the DOS intro and the DOS title menu) - record

Extension session E3, staging implementer.  Staged under `build/ux5-stage/` only; nothing in the tree or in a shared
output was written for UX5, except one stray staging log (`docs/stage-all-Checked.log`, moved out at the landing;
section "Landing", item 4).  Base snapshot of the tree: 2026-10-16 19:47:44 UTC (after D5P's landing and its docs pass,
`build/docs-d5p-done.txt` 16:30:40 UTC; D5P's landed `pdos_seq.c`/`pdos_seq.h`/`test_pdos_seq.c`/`test_pdos_aspect.c`/
`ext_aspect.py` unchanged since); every base hash is in `BASE-SHA256.txt`.

## Status

**LANDED 2026-10-16** (copy-in 20:28:06 UTC, ALL_GREEN 21:17:06 UTC, RELEASE_OK 21:23:22 UTC; user build
`build/user-builds/ux5/`; section "Landing").  At staging: READY_TO_BUILD.
One rule, presentation only: with "4:3 aspect ratio for 320 x 200 screens" checked, every DOS
320x200 screen takes the 4:3 shape except DOS Birth (its story, its end fade and the black before the first setup page),
which stays square.  The DOS start-up (the black, the credits, the panorama, the logo and title reveal) and the DOS title
menu (after the intro, after every return from Customize World, the Hall of Fame or Load in either graphics, its chosen
row through the outro) now follow the option; UX3 kept them square and D5P (b) made the redrawn box's shape follow the
picture behind it, both superseded here.  Unchecked: every DOS screen square, as before.  The Windows graphics are
unchanged.  A switch of the item while the intro or the title menu is shown takes effect at once (present.c's
`present_set_options` already draws the whole client again at the new layout; it had nothing to change while those
screens were square-only).  No core change (P0), no RNG use, no host or harness code change.

| Staged file | Base sha256 (tree) | Staged sha256 |
|---|---|---|
| `present/dos/pdos_seq.c` | `e692f0ce8e11bf1ca2bf082543d09522e2f8ac7ed67430c7179d41ace4f9a2e2` | `4102112f1810fd430141b4719f9ae7367570601d1bcf457f8d70d1b36e81a624` |
| `present/dos/pdos_seq.h` | `3acaeb4047c19f8ae9c9da236eb5b5fead08cc010f390ad62b8b381bec4d64c3` | `af2a15ff511867b6f685684d34d1978f81aed5fb4df8cbd5a81461329f37a867` |
| `present/profile.h` | `f2ca00bcafad3a55fd200432c233582903fdd77b13f974c82cab96e94ce94a27` | `e42e2324e560e42b911ed3f2a0c53d215e47f17f48707a35f975a5929731c2f1` |
| `present/present.c` | `7bf67b6590db92ffeb0f744d8914dbb890b2e3277927536780600b6a6c59b8ac` | `50abf7f0222347ceea36943f0c36a69d7538036c97f7197bab3d50a035430c9a` |
| `present/dos/pdos_profile.c` | `e1be15acf05c62965d3a611d97d8dde29a2522acbcd27b56a1c8d411895e1cc0` | `e82291a8fdfba31b9039a4cb4f14af1c3a9b4f223f6f1b9343cedc59a8a82303` |
| `tests/test_pdos_aspect.c` | `d99703f797cc0a381b3894f5d035a07aeda36cda22db40bc19f72985eb0f1af9` | `d7e1a1bd5d4e0b845b72d4b52649c2eabb57b3d1e115f743ea5ee70e87178299` |
| `tests/test_pdos_seq.c` | `3a646c113e136a924844a359f33af19f7e88e567f5ebd6fa2de146af0479a98e` | `acada6d7efca727ad82c462649dc9d6c599c70ac98ba8fedc6621c799b35bb13` |
| `tests/harness/ext_aspect.py` | `9eed4a0afd70b1467bea504f8bf4f56314fe28c41ae7fd0c716e221262497db6` | `434c18713bb59055f5534db99d78cdc60607c1f9f486c257f7a95bed49dacd48` |
| `tests/headless/harness_main.c` | `dd8ddc04d69eb03d6738af50256c9229f8ef57d4d196f419e7914482937aca2a` | `83443ad9b7ebdb376f068e6d1d50058ac0f712d103497f2b75c164d05d62959f` |
| `win64/civ64_main.c` | `bb438457c6fcc9fb66270a30e0e45f011da08f480b4be15c88537693e329f47f` | `4cb1ff561f22f6ccfd4ec7c72cd9b7e6c89b568a98720494600d335b4ac7ac51` |
| `test.cmd` | `5f6ddf6cebceea41aa9c234af3abc2ff70079a052bd24b4f821854fdee7c869b` | `e7c5015ce6e020c692bbbec2560aee053acffd3685afcab7936018510a584da0` |
| `docs/ext-UX5-record.md` | new | (this file) |

## The user's direction and the ruling

The user, 2026-10-16 about 19:39 UTC (STATUS.md "User directions" row 19:39), verbatim:

> 4:3 shall be applied to DOS intro and DOS title screen also when selected update accordingly

The orchestrator's ruling (this unit's brief, after the direction): with the item checked the DOS start-up takes the 4:3
shape (the black, the credits, the intro panorama, the logo and title reveal); the DOS title menu too, including after
Windows-side returns (D5P (a)'s original title picture) and DOS-side returns, so D5P (b)'s "the shape follows the
picture behind the box" becomes simply 4:3 whenever the item is checked.  Birth is not named, so it stays square (UX3's
exemption kept for Birth only): title 4:3, Birth square from its first picture through its end fade and the black before
the first setup page, then setup and play 4:3.  Unchecked: every DOS screen square, as now.  The Windows graphics
unchanged.  Keep the redraw on a change of shape (UX3-8: no leftover bars or strips) and the pointer mapping.  A switch
of the item while the intro or title is shown takes effect at once.

## The shapes, before and after (the item checked; unchecked every DOS screen is square, before and after)

| DOS screen | UX3 / D5P (base) | UX5 |
|---|---|---|
| the start-up's black (BOOT), the credits, the panorama, the logo and title reveal, a held logo | square | **4:3** |
| the title box after the intro (and the C.6.6 box over the pan or the logo) | square | **4:3** |
| Customize World (from dialog 143's open), the Hall of Fame, Load (its screens) | 4:3 (from the branch's start) | 4:3 (no switch at the start) |
| the box drawn again after a DOS-side return (over the branch's screen) | 4:3 (D5P (b)) | 4:3 |
| the box drawn again after a Windows-side return (the title picture), or a Load that drew nothing | square (D5P (a), (b)) | **4:3** |
| Start a New Game's / Play on EARTH's outro | square from the title, 4:3 after a 4:3 return or Customize OK | **4:3** |
| DOS Birth, its end fade and black hold, to the setup page (R:01A8:087C) | square | square (kept) |
| the setup and name pages, the introduction text, play, the end game's Hall of Fame | 4:3 | 4:3 |
| the 640x480 A frame; the Windows graphics | square (not 320x200) | square (unchanged) |

So under the item there are now exactly two switches in a new game: 4:3 to square at Birth's start (SeekSequence ra
11E0:01AA), square to 4:3 when the setup page is shown at the hand-over; a switch of the item is a third kind, at once.

## Fix

* **`present/dos/pdos_seq.c`** `pdos_seq_square_scene` (the DOS profile's `square_only`, read by present.c
  `frame_aspect` at every layout and tick): `return g_bview && !pdos_setup_shown();` (DOS Birth only).  Removed with it:
  UX3's `g_ux3_branch` (the span from a title branch's start to the box's redraw in which the branches followed the
  option) and its seven assignments (`intro_start`, `birth_start`, `tb_show`, `pdos_seq_reset`, the Load and Hall of
  Fame entries, Customize's dialog 143 open); the BOOT and INTRO/TITLE/CUSTOM/OUTRO scene tests.  D5P (b)'s `g_tb_sq` is
  renamed `g_tb_on_title` and keeps only its log role: the step `title_shape` still precedes each `title_redraw` with arg
  1 (the box on the title picture or the intro's screen) or 0 (over a screen the branch drew: page 0 changed since the
  choice), the observable that tells a DOS-side return from a Windows-side one; it no longer decides the shape (the
  step name is kept because `ext_adapt.py`'s D5P title-return checks and `ext_aspect.py` read it, and D6f stages
  `ext_adapt.py`).  The D5P block's (b) and `title_again`'s comment say so.  A short UX5 comment replaces UX3's block.
* **`present/dos/pdos_seq.h`**: `pdos_seq_square_scene`'s contract (UX3 block, with the UX5 direction quoted): 1 for
  DOS Birth only; 0 for every other scene, the start-up and the title menu included; a change of the option shows at
  once.  D5P's paragraph (b) rewritten: `title_shape` names the picture behind the box; UX5 supersedes D5P's shape rule.
* **Comments only** (each inside its existing UX3 block, one or two lines): `present/profile.h` (`square_only`: the DOS
  profile's Birth), `present/present.c` (`frame_aspect`'s header), `present/dos/pdos_profile.c` (`dos_square_only`),
  `tests/headless/harness_main.c` (the `--aspect` paragraph), `win64/civ64_main.c` (the `--aspect` paragraph).
* **`test.cmd`**: section `ux3_aspect`'s comment and echo line name UX5 (Birth square, the intro and title following the
  option; the intro run); the section name, `cpu=6 est=20` and the commands are unchanged.

The switch of the item needs no new code: the system menu's SC_CIV_ASPECT goes through `hw_set_presentation` ->
`present_set_options` (`show_all`: `relayout` and the whole client scaled again, borders included) -> `refresh_cursor` ->
`InvalidateRect`; the harness's `at <ms> policy integer square|4:3` calls the same `present_set_options`.  Before UX5 that
path ran during the intro and title too, but `square_only` gave 1 there, so the layout stayed square.

## Survey (every caller and reader)

`pdos_seq_square_scene` has one caller, `dos_square_only` (pdos_profile.c), the profile's `square_only`; its only reader
is present.c `frame_aspect` (via `relayout_due` at frames and ticks, and `relayout`).  `test_present` and
`w32_test_host_win32` drive `square_only` through their own test profiles (unchanged).  `g_ux3_branch` had no reader but
the predicate.  `g_tb_sq` had the log and the predicate (through `g_ux3_branch`).  Harness checks that read DOS layouts:
only `ext_aspect.py` (`--presented 2`).  Every other harness run with the DOS profile is at the default 640x480, where
4:3 and square give the same 2x2 image at 0,40 (no relayout, no extra show: `relayout_due`'s same-picture branch), or
compares core outputs only (ext_p0 V4d at 1920x1440, V6w at 1920x1080), or hashes N frames (the timeline goldens'
`watch`/`bwatch` lines, `presented.log`'s `sha256` is the frame's, not the view's), or samples the view only at its
zoomed shows in play (ext_zoom's dos golden, `view_sha256` at each 5,000 ms sample), where both builds lay the frame out
4:3 and the view was last drawn whole at a relayout.  So no golden depends on the square intro or title shape; the
private runs below confirm it.

## Tests

* **`tests/test_pdos_aspect.c`** (80 -> 93 checks), rewritten for UX5: along the flows (new game, EARTH, the branches with
  Windows-side returns, the DOS-side returns of D5P) `square_only` is 0 at the reset (BOOT), at RunIntroAndTitleMenu, at
  the intro's start, at every tick of the credits, panorama, logo and title reveal to the box (4,500 ticks), on the box,
  after every choice, in every branch and every redraw, in the outro, the setup and play; 1 from Birth's start through
  its story, the world, the skip, the core's Birth end and the end fade, with exactly one change, at the hand-over when
  the setup page is shown.  Through the present layer at 1920x1080 integer under 4:3: the start-up black and every tick
  of the intro and title box laid out 4:3 (pixel 6/5, 4x5, 1280x1000 at 320,40); the item switched square and back in
  the credits, the panorama, the logo and on the title box: each switch at once (before any tick) one VIEW show, the
  whole client drawn again (a sentinel in every view pixel before: none left), the new layout, the pointer at 4x4 or 3x4;
  the Hall of Fame and the box drawn again over it 4:3 with no VIEW show; the outro 4:3; Birth square at the next tick
  with one VIEW show, and square under either option (two switches inside Birth); the end fade square and the setup page
  4:3 again; under the square option the start-up, intro, title box and Hall of Fame square at every tick.
* **`tests/test_pdos_seq.c`** (214 checks, unchanged count): D5P's six vectors that expected `pdos_seq_square_scene() ==
  1` on the title picture (the five-item box after the hand-over, the title picture after a Windows-side Hall of Fame,
  Customize's Cancel, Load cancelled in Windows after the slot screen, Load cancelled with nothing drawn, the composed
  title without a hand-over) now expect 0 (the option); the `title_shape`/`title_picture` arguments, the pixels and the
  Birth vector (1) are unchanged; header notes.
* **`tests/harness/ext_aspect.py`** (24 -> 32 checks, seven -> nine runs): the expected shape is now 4:3 from the start
  to Birth's start, square to the setup page, 4:3 after it, and square while the option is square (`markers` from the
  option's switches, Birth's starts and the setup pages; UX3's branch markers and D5P's Load ambiguity are gone).  New
  runs `intro` (the whole DOS intro with no key at 1920x1080 `--presented 2`; the item switched square/4:3 at 10/12 s in
  the credits, 40/42 s in the panorama, 60/62 s on the logo, 70/71 s on the title box; n, Return at 72 s; square/4:3 at
  78/79 s in Birth; X at 83 s; 92,000 virtual ms) and `intro_ref` (its keys without the switches, P0).  New check 8 (each
  switch shown at once: the first show at or after it a VIEW show within one tick at the new layout outside Birth, square
  inside it).  The pointer check needs 3x4 in every flow and 4x4 too in `intro`.  Check 7 (D5P's `title_shape` lists:
  fame 0, 0; fame_win 1, 1 with one `title_picture`; custom and intro none) is kept with its new meaning.
* No golden changes (see Survey).

## Reproduction on the base (the old values)

* The staged `test_pdos_aspect` linked against the base objects (`obj/onebase.cmd`): **58 of 93 fail**, every one a
  start-up, title, redraw, outro or present-layer check, the base giving square there ("the credits, the panorama, the logo
  and title reveal and the title box at every tick: the option (4500 ticks not)"; "present: the title box: the option
  4:3 at once: ... the pointer at 4x4": the base's switch to 4:3 on the title box leaves it square); the Birth, setup,
  play and branch-interior checks pass on the base.  `obj/basestaged-test_pdos_aspect.log`.
* The staged `test_pdos_seq` on the base objects: **6 of 214 fail**, exactly the six changed vectors (square on the
  title picture).  `obj/basestaged-test_pdos_seq.log`.
* The staged `ext_aspect.py` with the base harness: **EXT_ASPECT_FAILED=5**: the shapes of fame, custom and fame_win (145,
  145 and 148 shows square where 4:3 is expected, the first at 0 us), intro's shapes (1,102 shows; the 4:3 spans after
  each switch back to 4:3 have no 4:3 show) and intro's switches (the four switches to 4:3 outside Birth show square).
  `obj/aspect-base-new.log`.
* The other way round, the tree's tests with the staged code: the base `test_pdos_aspect` on the staged objects fails 50
  of 80 (`obj/old-test_pdos_aspect.log`), the base `test_pdos_seq` 6 of 214, the tree's `ext_aspect.py` with the staged
  harness EXT_ASPECT_FAILED=3 (fame, custom, fame_win: the square spans it expects are 4:3).  `obj/aspect-old-src.log`.
* On the base build itself the tree's tests pass: `test_pdos_aspect` 80, `test_pdos_seq` 214 (`obj/ut-base`).

## Results (private, `build/ux5-stage/obj/`, 2026-10-16 19:48..20:23 UTC)

| Check | Base | Staged |
|---|---|---|
| strict c11 + c17 /W4 /WX and the clang C99 parse (`cc.cmd strict`): pdos_seq.c, present.c, pdos_profile.c | - | CC_STRICT_OK |
| `cc.cmd all` Checked, CheckedNoObs, Release (portable sources, the tests named, the harness, civ64.exe) | CC_ALL_OK (Checked) | CC_ALL_OK (all three) |
| `test_pdos_aspect` | PASS 80 | PASS 93 |
| `test_pdos_seq` | PASS 214 | PASS 214 |
| `test_pdos_profile`, `test_present`, `test_pdos_setup` | 51, 951, 164 | 51, 951, 164 (unchanged) |
| `ext_aspect.py` (staged script) | EXT_ASPECT_FAILED=5 | EXT_ASPECT_OK (32 checks; 9 runs, 20 s wall) |
| `ext_timeline.py` base group / `--group bs` (the tree's golden) | - | EXT_TIMELINE_OK / EXT_TIMELINE_OK |
| `ext_continue.py`, `ext_mirror.py`, `ext_bs.py assets`, `ext_bs.py mirror` | - | EXT_CONTINUE_OK, MIRROR_OK runs 29, EXT_BS_OK, EXT_BS_OK |
| `ext_adapt.py`'s DOS-form pairs (the tree's script, `obj/adapt_priv.py src`) | - | 38 cases, 129 checks, 0 failed (as D5P's run of the same pairs) |
| `ext_p0.py --vars V0,V1,V4d,V6r,V6w` | - | P0_OK checks 212 |
| `ext_zoom.py --profiles dos` (the tree's golden, no --update) | - | ZOOM_OK combinations 32 runs 36 samples 240 map comparisons 6 centre runs 2 (every DOS golden sample equal) |
| `adapters.py check`, `obs_lint.py`, `registry.py check`, `pdos_scene_check.py` over the overlay | - | ADAPT_OK rows 98 steps 22, OBS_LINT_OK files 120 probes 203 callsites 98, REGISTRY_OK, PASS 1078 checks |
| `nodos.py check` (the staged files and the private Checked binaries) | - | NODOS_OK (22 files, 0 hits) |
| `testpar.py check` over the staged test.cmd | - | exit 0 |

The intro run's switches show at 10,000,000, 12,000,000, 40,000,850, 42,000,750, 60,000,950, 62,000,850, 70,000,500,
71,000,950 us (each a VIEW show at the new layout, at most 950 us after the command's time) and at 78,000,000 and
79,000,000 us in Birth (square both); its hand-over's box at frame 4766 (68,000,057 us, as ext_timeline's `start`),
Birth's start at 73,273,600 us, the setup page at 83,586,182 us.

## Expected expectation changes (at the build slot)

* `sections/unit.log`: `test_pdos_aspect` 80 -> 93 checks; every other unit test unchanged (`test_pdos_seq` 214).
* `ext-aspect.txt`: 24 -> 32 PASS lines: fame's, custom's and fame_win's shape lines in the new wording with switches
  `ft@0 sq@<Birth> ft@<setup>`; their pointer lines with "need 3x4"; the runs line naming intro and intro_ref; intro's
  six lines (flow, title_shape, layout fields, shapes with its eleven switch points, other shows, pointer) and its
  switch line;
  a third P0 line (intro, intro_ref); EXT_ASPECT_OK.  `sections/ux3_aspect.log`: the new echo line, EXT_ASPECT_OK.
  `sections/times.txt`: ux3_aspect longer (about 20 s instead of 5; the 92 s intro runs).
* `nodos.txt`: one file more (this record), 0 hits.
* Unchanged: ext-timeline (both groups, golden unchanged), ext-continue, ext-mirror, ext-bs, ext-adapt, ext-p0, ext-zoom
  (its golden unchanged), ext-frames, ext-replay, ext-slots, gate3b, uninit, scenarios, p4tests, adapters-check,
  obs-lint, obs-tables, registry-check, pdos-scene-check, dos-decoded, present-goldens, coverage.  EXT_G1_OK runs 77.

## Rebase notes

Twelve files: eleven staged tree files (base SHA-256 in `BASE-SHA256.txt`) and this record (new).  Line endings follow
the bases (CRLF: `pdos_seq.c`, `pdos_seq.h`, `pdos_profile.c`, `harness_main.c`, `test.cmd`; LF: the others).  Each
change is inside a marked extension block:

* `present/dos/pdos_seq.c`: the UX5 comment where UX3's `g_ux3_branch` block was; D5P block's (b) comment and
  `g_tb_on_title`; six deleted `g_ux3_branch` lines and the dialog-143 `if` around one; `title_again`'s comment and
  three renamed uses; `pdos_seq_square_scene`'s body (one line) in its UX3 block.  Nobody else stages it.
* `present/dos/pdos_seq.h`: D5P paragraph (b) and the UX3 block of `pdos_seq_square_scene`.  Nobody else stages it.
* `present/dos/pdos_profile.c` (**D6e and D6f stage it**): two comment lines in the UX3 block above `dos_square_only`.
  If D6e or D6f lands first: take their file and re-apply these two lines (`obj/edit_misc.py`'s replacement).
* `present/present.c` (**D6f stages it**): two comment lines in `frame_aspect`'s UX3 header.  Same rule.
* `present/profile.h`, `tests/headless/harness_main.c` (D6e/D6f stage `harness.c`, not `harness_main.c`),
  `win64/civ64_main.c`: two comment lines each.
* `test.cmd`: section `ux3_aspect`'s comment (six lines instead of four) and echo line; re-apply with
  `obj/edit_testcmd.py` if another unit changed test.cmd first, then `testpar.py check test.cmd`.
* `tests/test_pdos_aspect.c`, `tests/test_pdos_seq.c`, `tests/harness/ext_aspect.py`: whole-file copies (nobody else stages
  them; MZI, D6e and D6f do not touch them).
* MZI (present/map, ext_zoom.py, ext-zoom-golden.txt, test_map.c) has no file in common.

## Build-slot steps

1. Re-check every base against the tree (`BASE-SHA256.txt`); rebase as above where one moved.
2. Snapshot the Checked outputs; copy the twelve files byte for byte; manifest.
3. `build.cmd checked`, `test.cmd checked`, `ext_g1.py check`; then `build.cmd` (Release).  No BUILD-TEST-ADDITIONS
   besides the staged test.cmd (no new test program, no new section).
4. User build with the Release civ64.exe and the user checks UX5-1..UX5-7 below.

## What the user checks

The 4:3 shape only shows where the window has room for it: with "Integer scaling" in a window of the smallest size, 4:3
and square look the same; use full screen (Alt+Enter), a larger window or "Scale to fit".  In 4:3 the DOS picture is a
little narrower with wider black side bars (slightly taller pixels) than with the item unchecked.

- **UX5-1**: In the DOS graphics with "4:3 aspect ratio for 320 x 200 screens" checked (the default), start civ64 and
  watch the whole intro: the black, the credits, the panorama, the logo and the title reveal are all in the 4:3 shape
  (before this build they were square).  Compare once with the item unchecked: square.
- **UX5-2**: The title menu after the intro is 4:3 too, and stays 4:3 while you move the highlight and choose.  The mouse
  points at the rows it shows.
- **UX5-3**: From the title menu in the DOS graphics: View Hall of Fame and leave it, Load a Saved Game and cancel it
  (Escape on the DOS load screen), Customize World and Cancel: the shape is 4:3 the whole time, also when the menu box is
  drawn again; it never turns square in between.
- **UX5-4**: The returns of D5P-1..D5P-4 (Customize's Cancel in Windows, the Hall of Fame or Load left in the Windows
  graphics, then switch to DOS): the original title menu (the logo on black with the menu box), now 4:3.
- **UX5-5**: Start a New Game (or Play on EARTH): 4:3 until Birth's first picture, square through the whole of Birth
  (its end fade and the black before the first setup page included), 4:3 again from the first setup page.
- **UX5-6**: Switch the item in the window menu while the credits, the panorama, the logo or the title menu are shown:
  the shape changes at once, the whole window is redrawn, no black bars or strips of the other shape are left (as
  UX3-8), and on the title menu the mouse still picks the row under it.  Switching it during Birth changes nothing
  visible (Birth stays square).
- **UX5-7**: Uncheck the item: every DOS screen is square (intro, title, Birth, everything), remembered at the next start;
  check it again: 4:3 everywhere except Birth, remembered.  The Windows graphics look exactly as before either way.

## For the records

- **manual-checklist-ext.md** (the docs pass; new section UX5 with UX5-1..UX5-7, user build named when made), notes on the
  rows UX5 supersedes in part:
  - UX3-3 (passed): "the start-up ... the title menu ... have square pixels, exactly as with the item unchecked" holds
    only for Birth since UX5 (UX5-1, UX5-2, UX5-5; Birth unchanged).
  - UX3-9 (passed): "Check it again: 4:3 (with the square intro, title menu and Birth)": since UX5 "(with square Birth
    only)" (UX5-7).
  - UX3-4 (passed): "Cancel: square again when the title menu's box is drawn again": 4:3 since UX5 (UX5-3).
  - UX3-5 (passed; already superseded in part by D5P): "from then on everything is square (the title menu)": 4:3 since
    UX5.
  - UX3-6 (pending, build d5p): "cancelled in the Windows file chooser: the title menu as after the intro, square": 4:3
    since UX5 (check in the UX5 build; the rest of the item unchanged).
  - D5P section's definition "The title menu as after the intro means: the Civilization logo on black with the DOS menu
    box below it, square, the first row highlighted": since UX5 "in the 4:3 shape with the item checked (square
    unchecked)"; D5P-1..D5P-4 then hold as written (UX5-4).
  - D5P-5..D5P-7: still true (4:3 kept over the Hall of Fame and the load screen, 4:3 to Birth, square Birth, 4:3 setup);
    their contrast with a square title menu is gone: the title menu itself is 4:3 now.
  - D4-1 (passed, historical): its "start-up screens ... square whatever the option" is superseded again (UX2, UX3, UX5).
- **FIDELITY.md**: F116 gets a UX5 paragraph (the 4:3 option on the DOS intro and title menu, the user's direction of
  2026-10-16 about 19:39; only DOS Birth square; `pdos_seq_square_scene`); F187's "with the box, square" and "keeps the 4:3
  option there ... (supersedes UX3's square redraw for these returns)" become "with the box (4:3 under the option since
  UX5)"; its tests add `ext_aspect.py` intro.
- **DESIGN.md**: 12.7 "As implemented (UX3)" (about lines 3590..3610: the switch points, `g_tb_sq`, the square intro and
  title) rewritten for UX5 (square_only = DOS Birth until the setup page; `g_tb_on_title` and `title_shape` as the
  picture behind the box); 12.1/12.2 (about lines 1826..1827, 2010, 2293..2295, 2309, 2529) "the DOS intro, title box and
  Birth square" -> "DOS Birth square".
- **DOS-PROFILE.md** (prose only, lines about 155..157): "does not apply to the intro and Birth ... square on the title
  picture" -> the option applies to the intro and the title menu; only Birth keeps square pixels.
- **RUNNING.md**: `test_pdos_aspect` row (93 checks; the text "keep square pixels ... along the intro, title" -> "only
  Birth square"); `[UX3: ext_aspect.py]` rows (lines about 210, 371: nine runs with `intro` and `intro_ref`, check 8, 32
  checks); `--aspect` rows (lines about 283, 471: "not its intro, title box and Birth" -> "not DOS Birth").
- **FEATURES.md**: the UX3 row (about line 232): "the intro, the title menu and Birth keep square pixels" -> "DOS Birth
  keeps square pixels; the intro and the title menu follow the option (UX5)".
- **STATUS.md**: unit UX5 staged/landed; the user's direction of 19:39 addressed.

## Landing (2026-10-16, build slot)

**Landed 2026-10-16 20:28:06 UTC; cycle ALL_GREEN 21:17:06 UTC; RELEASE_OK 21:23:22 UTC; user build
`build/user-builds/ux5/` (about 21:24 UTC).**  Done by the build slot on the orchestrator's instruction after
READY_TO_BUILD.  MZI was not ready and shares no file with UX5; D6e, D6f, SI, TLD and MZS were only staged, so no unit
landed between UX5's base and its landing.

1. **Bases.**  `build/ux5-prep/land.py` (dry run, then `--write`): all 11 tree files still had their bases
   (`BASE-SHA256.txt`, taken 19:47:44 UTC and re-verified 20:24 UTC), this record was absent, and the 12 staged copies had
   the SHA-256 frozen in `build/ux5-prep/staged.sha256` after the last staging edit.  No rebase was needed.
2. **Snapshot and copy.**  Before writing: the tree's Checked test outputs (59 files of `build/test/Checked`, MZW's
   cycle) in `build/ux5-prep/before`, the 11 previous tree files in `build/ux5-prep/tree-before`.  The 12 files byte for
   byte (11 changed, `test.cmd` among them; this record new); `build.cmd` unchanged (SHA-256 `40de571d...` in the
   manifest); manifest `build/ux5-prep/landed.sha256` (13 lines), `landed-at.txt` (20:28:06 UTC).  The predictions
   (`build/ux5-prep/predictions.txt`) were written before the copy-in.  This section, the Status line and the first
   paragraph's stray-log clause were added after the cycle: the tree's record differs from the manifest's `140924d5...`
   by these three edits only (the stage copy carries them too).
3. **Cycle** (`build/ux5-prep/ux5-cycle.ps1`, D5P's script with the UX5 names; status `build/ux5-status.txt`, logs
   `build/ux5-<n>-<step>.log`):
   - 1 build-checked: exit 0, 600 s (20:28:11..20:38:12), BUILD_OK, portable sources 294, no warning.
   - 2 test-checked: exit 0, 2334 s (20:38:12..21:17:05), TESTS_OK.  testpar's wall 2287.9 s against 1432.5 s in MZW's
     cycle: every section ran slower (the host was shared with other units' staging); ext_p0 and ext_mirror were the
     critical path.  No w32 flake: `w32_test_host_win32` passed (395 checks) the first time, so there is no `-r2` run.
   - 3 g1-checked: exit 0, EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events): **ALL_GREEN** 21:17:06 UTC.
   - 4 build-release: exit 0, 362 s (21:17:20..21:23:22), BUILD_OK, portable sources 294, no warning: **RELEASE_OK**.
4. **Comparison** (`build/ux5-prep/compare.py`, output `compare.txt`): 52 of 59 files equal (lines with times left
   out).  The differences:
   - `sections/unit.log`: test_pdos_aspect 80 -> 93 checks; the OBS_COST line's nanoseconds.  Predicted; test_pdos_seq
     214, test_pdos_profile 51, test_present 951, test_pdos_setup 164, test_input 449 and test_host_win32 395 unchanged.
   - `ext-aspect.txt` (25 -> 33 lines, 24 -> 32 PASS lines) equals the private run `build/ux5-stage/obj/aspect-src.log`
     byte for byte; `sections/ux3_aspect.log`: the new echo line, EXT_ASPECT_OK.  Predicted line for line: the runs line
     with intro and intro_ref; fame's, custom's and fame_win's shape lines in the UX5 wording (switches `ft@0 sq@15272400
     ft@24596282`, custom's `ft@0 sq@11757150 ft@21575382`); custom's layout fields 372 -> 371 shows; the pointer lines
     with "need 3x4" (fame 9 and custom 8 pointers as before, fame_win 11 -> 9); intro's seven lines (1403 shows, the
     switch points, 1 other show, 6 pointers needing 3x4 and 4x4, each switch shown at once with 2 in Birth square); the
     third P0 line (intro, intro_ref, 583 frame lines).
   - `nodos.txt`: 1731 -> 1733 files, 0 hits, NODOS_OK.  **Predicted 1732.**  The second new file was a stray log of
     UX5's own staging, `docs/stage-all-Checked.log` (129 bytes: "CC_ALL_OK variant=Checked"), written 2026-10-16 19:53
     UTC by a private build command whose `cd` ran in a background subshell, so its redirect landed in the tree's
     `docs/`.  It was untracked and referenced nowhere, touched no source, test input or other output (nodos scanned it:
     0 hits).  Found at the comparison and moved to `build/ux5-stage/obj/stage-all-Checked.log` (SHA-256 `ae85245e...`
     unchanged) at 21:21:36 UTC, before the Release build's end; the tree now holds the 1732 files predicted.
   - `coverage.txt` and `sections/coverage.log` (informational, never fail): "other functions entered 662 -> 665"; rt
     entries unchanged (145 of 155).  **Not predicted** (the predictions listed coverage as unchanged).  By elimination
     the three core functions come from the two new runs of `ext_aspect.py`, intro and intro_ref, which let the DOS
     start-up play 72 s to the title menu without a key (every other ext_aspect run presses X at 1 s): no other harness
     input changed, and P0, ext-timeline, ext-p0, ext-mirror and ext-frames are equal to MZW's cycle.  They are not
     named here: `coverage.txt` lists only rt entries, and MZW's per-function files were replaced by this run.
   - `sections/times.txt`: section times as in item 3; ux3_aspect 5.2 -> 21.9 s (predicted about 20..30 s).
   Every other output equal, as predicted: ext-timeline and ext-timeline-bs (goldens unchanged), ext-continue,
   ext-mirror, ext-bs-assets, ext-bs-mirror, ext-adapt, ext-p0, ext-zoom (golden unchanged), ext-frames, ext-replay,
   ext-slots, gate3b, uninit, scenarios, p4tests, harness_stub, adapters-check, obs-lint, obs-tables, registry-check,
   pdos-scene-check, dos-decoded, present-goldens, the w32 files.
   - Also not predicted: "portable sources checked: 294", where the predictions said 293 (taken from D5P's cycle; MZW's
     cycle already had 294, so UX5 changed nothing there).
5. **User build** `build/user-builds/ux5/` (`build/ux5-prep/mk_userbuild.py`): `civ64.exe` (the Release build, SHA-256
   `f21ff6ad2037e6234b183ca8a8184895c75970b1d53acad3bed1d79e63f08cd1`), `CIVWIN.zip` and `civdos.zip` (byte-identical
   copies from `user-builds/d4`, `058d4e00...` and `0eac32c9...`) and `WHAT-TO-CHECK.txt` (UX5-1..UX5-7 in plain words,
   CRLF, SHA-256 `d14ba0ce...`; it names the builds it contains: mzw, mz, ux4b, d5p, ux4, d6d, sl and the earlier ones).
   Its "Still open" part comes from the checklist's pending rows at the landing (the checklist of 20:21 UTC, re-read
   21:23 UTC): P47-1 and D5P-7 checkable; D6-1 and D5-7 come with D6f, MZW-8's rework with MZS, none in a build yet.
6. **Not done here**: the checklist (the orchestrator adds section UX5 and the superseded-in-part notes of "For the
   records"; UX3-6 has passed since that list was written, so its note is one more on a passed item) and the other
   entries of "For the records" (FIDELITY, DESIGN, DOS-PROFILE's prose, RUNNING, FEATURES, STATUS) are the docs pass's.

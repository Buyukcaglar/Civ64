# Extension unit MZ (the centring at map zoom level -1) - record

Draft for the build slot.  A priority bug fix before D6e, from the user's report (STATUS "User directions" about
15:30 UTC 2026-10-16), the checks chat's read-only analysis and the orchestrator's ruling (the user keeps the pole
limit, STATUS about 15:35 UTC).  Staged in `build/mz-stage/` on the tree after the D6d landing and with UX4's files
in the tree (UX4 was landing; none of its files is MZ's); the bases were copied at 15:26:59 UTC and are rechecked
equal to the tree in `BASE-SHA256.txt`.  Private builds and runs in `build/mz-stage/obj/` only (an overlay `obj/src`
= tree + stage, built with build.cmd's own flags; the private runs use copies of harnesses in `obj/exe`: the tree's
Checked harness as it was at 15:26:59 UTC, `base-harness.exe`, for the reproduction, and the overlay's,
`mz-harness.exe`, for the fix; never the tree's executables in place).

## Status

READY_TO_BUILD.  At level -1 a new view of the core (the game's centring by C, its automatic centring of the next
unit, its scrolling, a ring click's recentring) now centres the layer on the view, then clamps; the offset that a
visit near a pole left no longer persists (the ratchet is gone).  The pole rule (draft D 11.2) is kept, as the user
chose: near a pole the view, and the unit the game centred in it, stays off the client's centre toward that pole.
+1 is unchanged (the layer keeps its place on the client, then the follow rule).  A wheel's or a menu zoom's anchor
holds until the next view change.  Both profiles share the geometry, so the fix holds in the Windows and the DOS
graphics alike.  Builds, unit tests, ext_zoom (with the centring runs), P0 and ext_adapt's map runs pass
privately (Results).

## The bug, reproduced on the base build (before any change)

`obj/mz_repro.py` (private) runs S3 (`new-game.script`) in host form at 1920x1440 (k = 3) with `--zoom -1` from the
start; in turn 2 ring clicks (press and release at one virtual time, as ext_adapt.py's ring run) at the map
client's bottom (59,400 and 60,100 ms), at its top (60,800 ms), S3's own Space (61,000 ms: the next unit) and the key
C (61,500 ms).  The map client is (171, 40, 624 x 427) on the virtual screen; at -1 the layer is 1248 x 854 world
pixels (Hl 26.7 rows).  The offset is the view's centre less the world pixel at the client's centre (+y: south):

| Run (base build, the tree's Checked harness) | View (xv, yv) | Layer origin | Offset |
|---|---|---|---|
| to 59,300 ms: turn 2 starts near the north pole | 1696, 192 | 1384, 0 | y -21.5 (the pole rule) |
| 59,400 bottom (to 59,700): mid-latitudes | 1696, 640 | 1384, 448 | y -21.5 (kept: the ratchet) |
| 59,400 and 60,100 bottom (to 60,500): near the south pole | 1696, 1088 | 1384, 746 | y +128.5 (4.0 squares, the pole rule) |
| ... 60,800 top, Space, 61,500 C (to 62,000): mid-latitudes | 1696, 544 | 1384, 202 | **y +128.5 (4.0 squares south: the ratchet)** |

The same last run on the MZ build: view (1696, 544), origin (1384, 330), offset y +0.5 (the even origin's half
pixel): centred.  Cause (confirming the checks chat's analysis): at a view change `pmap_layer.c` kept the layer's
offset to the view (draft D 11.3 "keeps its offset relative to the client"), then `pmap_geo_clamp` moved `Yo` into
the fewest rows beyond the poles (11.2); the next view change kept the clamped offset, so once the view had been
within about half a layer height of a pole, the core's view stayed displaced toward that pole for the rest of the
session at -1.  Vertical only: `Xo` has no world clamp (east-west wraps), and +1 follows the unit by its own rule.

**The user's save** (STATUS about 15:35 UTC; not read by this unit: the record uses the facts the checks chat
decoded): Rome at column 21, row 38 of 50, the Romans' only city.  Its centre is world y 1232.  At -1 the layer is
about 25..29 rows high (twice the map client's 12.5..14.5 rows), so exact centring needs the view's centre at most
1600 - Hl/2 (row 37.5 for 25 rows, 35.5 for 29): Rome needs 1..3 rows beyond the south pole, which 11.2 refuses.
That is the pole limit the user chose to keep: Rome is drawn 1..3 rows south of the client's centre, with or without
MZ.  MZ fixes the drift that remained after leaving such a place.

**How far from the poles centring is exact at -1.** Exactly centred when the view's centre is at least half the
layer's height from both poles: rows Hl/2 .. 50 - Hl/2.  The layer is twice the map client's height: for a client
of 12.5..14.5 rows (the usual window sizes) centring is exact from about row 13..15 to row 35..37, i.e. roughly the
middle 40..50% of the map; within about 13..15 rows of a pole (more than half of the 50 rows together) the unit stays
toward that pole.  At 1920x1440 in the harness (client 13.3 rows, Hl 26.7 rows): rows 13.3 .. 36.7.

## What was built

* `present/map/pmap_layer.c` (`pmap_layer_update`, the view-change branch): at level -1 `pmap_geo_centre`; at +1
  the former rule unchanged (the layer keeps its place on the client, 11.3, then the clamps; the follow rule
  `pmap_follow_square` after it as before).
* `present/map/pmap_zoom.c`: `centre_on_view` (the client's centre at the layer's host centre:
  `Xo = Xv + Cw / 2 - floor(hw nx / 2dx)`, the same for `Yo`; the former CENTRE anchor's arithmetic, now shared) and
  `pmap_geo_centre` (centre, then `pmap_geo_clamp`: the whole view visible, the fewest rows beyond the poles, the
  world centred when `Hl > 1600`, the even origin).  `pmap_geo_origin`'s CENTRE anchor calls `centre_on_view`
  (identical values).  The header comment's anchor paragraph says so.
* `present/map/pmap_int.h`: `pmap_geo_centre`'s declaration.
* No core, w16, profile or input file changes; nothing reads or writes the emulation that did not before.

## Tests

* `tests/test_map.c` `view_changes()` (15 checks, after `anchors()`), a 480 x 400 client at k = 2 (Wl 960, Hl 800):
  -1 at the south pole (yo 800: the pole rule, 200 world pixels south); a centring away from the pole (yo 376,
  offset 0; the base code gave 176, offset 200: the ratchet); the key C elsewhere (1360, 504); the north pole (0,
  offset -200); straight to the south pole; pole to pole and back (no ratchet); a 2-pixel scroll; an odd view (the
  even origin within one pixel); across the date line (xo -208); the wheel's anchor at -1 (the world pixel under the
  mouse kept, M-2), held while the view stays, the next view centres; +1 unchanged (a new view keeps the layer's
  place on the client).
* `tests/harness/ext_zoom.py` (extension MZ block): the centring runs above as checks, `centre-pole` (to 60,500 ms:
  the layer's bottom at the south pole, the view's centre south of the client's centre) and `centre-mid` (to
  62,000 ms: the view's centre at the client's centre within one world pixel, in mid-latitudes), each in the
  Windows profile and in the DOS profile (the profile chord at 40,000 ms); the two profiles' geometries equal; one
  `ZOOM centre` line per run; ZOOM_OK gains `centre runs 4`.  On the base build `centre-mid` fails in both profiles
  (+128.5 world pixels; `obj/run/centre-on-base.txt`).

## Results (private, `build/mz-stage/obj/`)

All on the overlay `obj/src` (the tree + the stage) with build.cmd's own flags; private outputs under `obj/`.

* **Builds** (`final.sh`, overlay of 16:05 UTC): Checked, CheckedNoObs and Release BUILD_OK, portable sources 293
  (c11, c17, c99 parse).  `cc.cmd` (c11 and c17 /W4 /WX, the clang C99 parse) on `pmap_zoom.c`, `pmap_layer.c`
  and `test_map.c` in the three variants: CC_OK.  After UX4b landed in the tree (16:30 UTC, `arrive.c`,
  `ext_adapt.py`) the Checked overlay was rebuilt on the current tree (`obj/exe/mz-harness2.exe`, BUILD_OK, 293).
* **Unit tests** (`ut.sh`, every `test_*.exe` but test_ne): 47 programs, failed 0 in Checked, CheckedNoObs and
  Release (and again in the rebuilt Checked); test_map PASS 263 checks (Checked, Release; was 248), CheckedNoObs 1
  (the refusal, unchanged).
* **obs_lint** OBS_LINT_OK files 119 probes 203 callsites 98 (unchanged); **testpar.py check** on the unchanged
  test.cmd exit 0; **registry.py check** REGISTRY_OK; **nodos.py check** (Checked) NODOS_OK, 0 hits.
* **The bug on the base build** (`obj/exe/base-harness.exe`, the tree's Checked harness of 15:26:59 UTC; table
  above): ext_zoom's centring runs on it give `centre-pole` ok (+128.5, the pole rule) and `centre-mid` **FAIL** in
  both profiles (+128.5 world pixels, four squares south; `obj/run/centre-on-base.txt`).
* **ext_zoom.py, the whole matrix** (`obj/runzoom.py --update -j 4`, `obj/exe/mz-harness.exe`): ZOOM_OK
  combinations 32 runs 108 samples 628 map comparisons 32 centre runs 4.  The centring runs: `centre-pole` win and
  dos view (1696, 1056) origin (1384, 746): +96.5 world pixels south (the pole rule: the layer's bottom at the south
  pole); `centre-mid` win and dos view (1696, 544) origin (1384, 330): +0.0, +0.5 (centred within the even origin's
  half pixel); the two profiles' geometries equal.  Rechecked against the staged golden with the rebuilt harness
  (`mz-harness2.exe`, `obj/run/zoomcheck2.txt`): ZOOM_OK, the same 628 samples and four centring
  lines.
* **The golden's change is the fix and nothing else**: of the 628 samples, 37 change, all `s4 1920x1440 integer -1`
  (115,000..155,000, 200,000..210,000 and 270,000..390,000 ms: the soak moves the view at -1 after a visit near a
  pole).  The base build's own s4 run (`obj/s4cmp.py`, `obj/run/s4cmp.txt`) reproduces the tree's golden in all 74
  samples of each level and differs from MZ's at exactly those 37; +1 is identical (74 of 74).
* **P0** (the tree's `ext_p0.py --vars V0,V4,V4d -j 3` with `mz-harness.exe`, private root): P0_OK checks 164 (V0
  against ext-g1-baseline where listed; V4 the zoom at 1920x1440 and V4d with the DOS profile and switching equal
  V0 in every run; the layer drawn in 22 runs, the DOS layer in 22).
* **ext_adapt.py's map runs** (`obj/runadapt.py`: the tree's ext_adapt.py `plain` and m_runs with zoomkeys-dos and
  ring-dos): with the rebuilt harness RUNADAPT checks 14 failed 0 (zoomkeys equals the plain run, 79 chord and
  wheel lines with their commands; ring and ring-dos equal ringref, ring_press 1, refused 0; zoomkeys-dos one
  switch).  The first run, with the harness built before UX4b's `arrive.c`, failed the zoomkeys pairs against the
  newer tree script (its keypad chords): a tree skew, gone with the rebuilt harness, not MZ.

## Expected changes at the build slot

* `test.cmd checked`: test_map PASS 263 checks (was 248; +15, `view_changes()`), CheckedNoObs unchanged (1).
* `ext_zoom` section: ZOOM_OK gains ` centre runs 4` and four `ZOOM centre ok` lines; the golden file changes in 37
  lines (`s4 1920x1440 integer -1` at the times above; staged).  Its time grows by four S3 runs to 62 s of virtual
  time.
* `ext_adapt` section: one line, `PASS ring: posted ...`: the two in-view clicks after the ring click are posted at
  other core points (tree `0201(639,274) 0202(639,274) 0201(522,253) 0202(639,242)`, MZ `0201(639,252)
  0202(639,252) 0201(522,253) 0202(639,253)`): the ring click recentres the game's view, and at -1 the layer is now
  centred on that view, so the same host points map to other squares.  `ring equals ringref` (built from the same
  mapping) still passes; EXT_ADAPT_OK's count is unchanged.
* Nothing else: P0 (the 164 V0/V4/V4d lines equal the tree's), ext_frames, ext_mirror and the other sections are
  unchanged (no core, w16, input or profile file changes; +1 and level 0 unchanged).

## Rebase notes

* All bases equal the tree at writing (`BASE-SHA256.txt`).  One-line hunks carry an `extension MZ` comment; the
  ext_zoom.py block is delimited.
* **UX4** (landing during the staging): none of MZ's files (host_win32, arrive.c, input.h, test_input,
  test_host_win32, civ64_locate.c).
* **D5P** (staging, lands before MZ): shares no file with MZ (its `tests/harness/ext_adapt.py` is not MZ's; MZ's
  harness run is in ext_zoom.py).  test.cmd is not staged by MZ.
* **D6e** (paused, staged after MZ and MZW) changes `tests/harness/ext_zoom.py` too (its "not zoomed" small-map
  check); it is rebased on MZ's copy.
* Shared counts: none (no new source file: obs_lint files and portable sources unchanged).

## Build-slot steps

1. Copy the staged files (`BASE-SHA256.txt`'s list) and this record into the tree; test.cmd and build.cmd unchanged
   (`BUILD-TEST-ADDITIONS.md`: none).
2. The three-step cycle: `build.cmd checked`, `test.cmd checked` (expected changes above), `ext_g1.py check`
   (EXT_G1_OK unchanged: the core is untouched).
3. The user build for the checks below (the coordinator's, Release).

## Decisions

* **(b), re-centring at every view change at -1** (the orchestrator's recommended way), not (a) (keeping the
  unclamped chosen place apart and clamping from it).  No accepted check needs (a): M-2 (the wheel keeps the point
  under the pointer) concerns the moment of zooming, which (b) keeps; D6d-3 and the follow rule are +1's, unchanged;
  D6d-4 (a ring click recentres there) is what (b) gives (the clicked square comes to the client's centre in
  mid-latitudes); D6d-6 (switching at -1 keeps level, centre and window) holds because both profiles share the one
  geometry (ext_zoom's centring runs compare them).
* **Every view change counts**, whatever moved the view: the game's C, its automatic centring of the next unit, its
  scrolling while a unit moves, a ring or small-map click.  The layer cannot tell them apart without reading the
  core's reason, and the ruling names them all.
* **The pole rule is kept** (the user's choice "Keep the pole limit", STATUS about 15:35 UTC): near a pole the unit
  stays off-centre toward it, by the rows beyond the pole that the layer does not show.

## Deviations from the design

* Draft D 11.3 "View changes" (**Choice**: the layer keeps its offset relative to the client, a magnifier at a
  fixed place) now holds at +1 only; at -1 a new view centres the layer on it, then 11.2 clamps (the user's report,
  the orchestrator's ruling).  11.1 (anchors at a new level and at a resize) and 11.2 are unchanged.

## User direction 2026-10-16 (no added Go Back / Cancel rows) and checklist item D5-7

MZ draws no screen and adds no row; no Go Back or Cancel row is added anywhere.  The named screen of D5-7 stays
D6f's.

## What the user checks

In the Windows graphics and in the DOS graphics (switch with Ctrl+Shift+Backspace or the system menu), during play
at zoom level -1 (Ctrl+Shift+Minus, the wheel over the map, or "Zoom out (half)" in the system menu).  Where the
checks say "the middle of the map", that is roughly rows 15 to 35 of the 50 rows, at least about a third of the
map's height away from both the north and the south edge: only there can the zoomed-out map put the unit exactly in
the centre.

* **MZ-1** In the middle of the map, press C: the active unit's square is at the centre of the map window.  Let the
  game move on to the next unit (or move a unit until the map scrolls): it centres the same way.
* **MZ-2** (the report) Go near a pole first (for example click near the top or the bottom of the World Map, or
  load a game whose units are near an edge), then come back to the middle of the map and press C: the unit is at
  the centre again, not shifted toward the pole you visited (before MZ it stayed shifted, up to about four squares).
* **MZ-3** (the pole limit, expected) Near a pole, within about 13 to 15 rows of the north or the south edge, the
  unit stays off the centre toward that edge, because the zoomed-out map shows nothing beyond the poles (your choice
  "Keep the pole limit").  In your save CIVIL1.SAV, Rome (row 38 of 50) is drawn 1 to 3 rows below the centre: that
  is this limit, not a failure.
* **MZ-4** (D6d-4 again) In the middle of the map, left-click a square on the ring outside the game's view: the map
  recentres there, as a click in the World Map would, and the clicked square comes to the centre of the map window.
  Click again elsewhere on the ring: it centres again.  A click beyond the poles does nothing.
* **MZ-5** The wheel: zooming out with the mouse wheel over the map keeps the point under the pointer in place (as
  M-2 accepted); the next time the game moves its view (C, the next unit, a scroll), the view goes to the centre.
* **MZ-6** Zoom in (+1): as before, the map follows the active unit with a one-square margin (D6d-3 unchanged).
* **MZ-7** At -1, switch the graphics with Ctrl+Shift+Backspace: the other graphics show the map at the same place,
  centred the same way; switch back: the same.

## For the records

* **draft D 11.3** (`docs/verify/ext-d1-draft-D.md`): "View changes" at -1: the layer centres on the new view, then
  11.2 (MZ); at +1 as written.  11.2's "fewest rows beyond the poles" stays (the user's choice).
* **DESIGN.md** (the zoom paragraph near 4319, the clamps; and the anchors): a new view at -1 centres the layer on
  the view, the pole rule alone keeps it off-centre; the exact-centring band rows Hl/2 .. 50 - Hl/2.
* **FIDELITY.md** F185 (and F130 for the ring click): at -1 the core's centring is shown centred except within half
  a layer height of a pole (11.2, the user's choice); presentation only, the core untouched (P0); tests test_map
  view_changes, ext_zoom's centring runs; user checks MZ-1..MZ-7.
* **manual-checklist-ext.md**: D6d-4 reworked by MZ (MZ-4 covers it); items MZ-1..MZ-7 (above).
* **STATUS.md**: unit MZ READY (staged), then landed by the build slot.

## Landing (2026-10-16, build slot)

**Landed 2026-10-16 17:41:59 UTC; cycle ALL_GREEN 18:12:28 UTC; RELEASE_OK 18:24:57 UTC; user build
`build/user-builds/mz/`.**  Done by the build slot on the orchestrator's instruction, after UX4b's RELEASE_OK
(17:06:49 UTC) with no docs pass running.

1. **Bases.** `build/mz-prep/land.py` (7 rows): the 6 tree files still had their bases
   (`build/mz-stage/BASE-SHA256.txt`), this record was absent, and the 7 staged copies had the SHA-256 frozen in
   `build/mz-prep/staged.sha256`; test.cmd and build.cmd had their bases. Dry run `DRY_RUN_OK 7`. No rebase was
   needed at the slot (MZ's private adapt run was redone on the tree with UX4b's `arrive.c` and `ext_adapt.py` in
   staging).
2. **Snapshot and copy.** Before writing: the tree's Checked test outputs (59 files of `build/test/Checked`, UX4b's
   cycle) in `build/mz-prep/before`, the tree's previous 6 files in `build/mz-prep/tree-before`. The 7 files byte for
   byte (6 changed, this record new): `LANDED 7`; manifest `build/mz-prep/landed.sha256` (with test.cmd's and
   build.cmd's unchanged SHA-256); `landed-at.txt`. No build.cmd or test.cmd change.
3. **Cycle** (`build/mz-prep/mz-cycle.ps1`; status `build/mz-status.txt`, logs `build/mz-<n>-<step>.log`):
   - 1 build-checked: exit 0, 202 s, BUILD_OK; portable sources checked 293.
   - 2 test-checked: exit 0, 1622 s, TESTS_OK, 27 sections, failed 0. `w32_test_host_win32` passed at the first run
     (395 checks): no GetKeyState rerun and no -r2 test step were needed.
   - 3 g1-checked: exit 0, EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events): **ALL_GREEN**.
   - 4 build-release: exit 0, 181 s, BUILD_OK, portable sources 293: **RELEASE_OK**.
4. **Comparison** (`build/mz-prep/compare.py`, output `compare.txt`; the predictions in `build/mz-prep/predictions.txt`
   were written about 17:45 UTC, before any output of the cycle; prediction against output in
   `build/mz-prep/comparison.txt`): 51 of 59 files equal (lines with times left out). The differences:
   - `sections/unit.log`: `test_map` 248 -> 263 checks; the OBS_COST line (host time).
   - `ext-zoom.txt`: the four centring lines `ZOOM centre ok pole|mid win|dos` (+0.0, +96.5 and +0.0, +0.5 world
     pixels from the client's centre) and `ZOOM_OK combinations 32 runs 108 samples 628 map comparisons 32 centre
     runs 4`; every other ZOOM line equal (the 37 changed -1 samples of s4 matched the landed golden);
     `sections/ext_zoom.log`: that ZOOM_OK line.
   - `ext-adapt.txt`: the one predicted line, "ring: posted ... 0201(639,252) 0202(639,252) 0201(522,253)
     0202(639,253)" (was 0201(639,274) 0202(639,274) 0201(522,253) 0202(639,242)): the in-view clicks after the
     ring click land on the recentred layer; `EXT_ADAPT_OK checks 154` unchanged.
   - `sections/times.txt`: section times (wall 1620.5 s).
   - `coverage.txt` and `sections/coverage.log`: "other functions entered" 662 -> 665 (informational).
   - `nodos.txt`: 1728 -> 1729 files (this record), 0 hits. **Not as predicted**: the prediction said the same file
     count and overlooked that nodos.py scans the repository's docs, so the new record counts; nothing else differs.
   Every other output equal: P0_OK checks 476, REGISTRY_OK, NODOS_OK, OBS_TABLES_OK probes 203 sites 98, OBS_LINT_OK
   files 119 probes 203 callsites 98, ADAPT_OK rows 98 steps 22, EXT_ASPECT_OK, MIRROR_OK runs 29, REPLAY_OK checks
   70, EXT_FRAMES_OK, EXT_TIMELINE_OK, EXT_CONTINUE_OK, EXT_SLOTS_OK, EXT_BS_OK and the other sections.
5. **User build** `build/user-builds/mz/`: `civ64.exe` (the Release build, SHA-256 4219e4c0...5248576c),
   `CIVWIN.zip` and `civdos.zip` (byte-identical copies from `user-builds/d4`, SHA-256 checked) and
   `WHAT-TO-CHECK.txt` (MZ-1..MZ-7 in plain words, MZ-3 the pole limit the user kept with the CIVIL1.SAV Rome case
   as expected, not a failure; the builds it contains: ux4b, d5p, ux4, d6d, sl and the earlier ones; MZW's rectangle
   named as the next unit; the items still open).
6. **Not done here**: the entries of "For the records" (draft D 11.3, DESIGN, FIDELITY F185/F130, the checklist's
   D6d-4 and MZ-1..MZ-7, STATUS) are the next joint docs pass's.

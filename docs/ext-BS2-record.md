# Extension BS, unit BS2 (the Windows Birth replica and its shadow mirror) - record

Unit BS2 of the Birth synchronisation BS (the user's direction of 2026-10-15, session E3). Brief:
[verify/BRIEF-bs.md](verify/BRIEF-bs.md) D1, D3, D4, D10, D11 with the orchestrator's Rulings (14:40 UTC),
sections 3.1, 3.2 items 2 and 3, 3.5, 5.2 test 2, 6 (BS2 row). Rules: BRIEF-d4.md "Rules". Staged in
`build/bs-stage` without the build slot, on BS1 ([ext-BS1-record.md](ext-BS1-record.md)); the build slot
landed it (below).

## Status

Done. Landed in the tree on 2026-10-15 at 23:35 UTC, BS1..BS4 at once (the BS implementer's build slot;
one landing for BS12 and BS34, no separate three-step cycles, Rulings 19:20) and verified by the BS phase
gate's eight-step cycle: ALL_GREEN (status `build/bs-status.txt`, logs `build/bs-<n>-<step>.log`; the gate
and its tables: [ext-BS-acceptance.md](ext-BS-acceptance.md)).
The Rulings' stop condition (a scene the mirror cannot bring to pixel equality) did not occur: every present
of the whole Birth compared equal. The replica's start moved to `present/bs/pbs_core.c` in BS3 (the mirror
and the view share it; the mirror's behaviour is unchanged). In the gate: `test_pbs_movie` 44 checks in all
three variants; `ext_bs.py mirror` EXT_BS_OK (16 checks: p4-birth 1436 of 1436 presents equal, EARTH 84 of
84, full coverage; CheckedNoObs: the refusal), test.cmd section `bs2_mirror` (after `bs1_assets`: both
write `build\bs\scripts`). The results below are the staging's (private).

## What was built

### The replica (`present/bs/pbs_movie.h/.c`, D1, 3.1)

Portable C, no w16 header. The movie's state after frame f is a pure function of f; the replica runs the
same items over the same inputs, forward only, frame by frame and item by item in list order, as
AdvanceMovie's catch-up does. Inputs (`PbsMovieStart`): the 78 items, the frame rectangle, the frame and
display offset, the movie palette, the god palette (log, object, map, realized), the system palette, the
window client, the static colours, the three CLUTs, the font table and index, the window font height and
the text operations (`PbsTextOps`: measure, colour, draw). Items transcribed from the translated core
(read-only): AdvanceMovie 10B0:0461's range test and rectangle; 2 LoadClut; 3, 4 the fades (CreatePalette-
Fade 10A8:0000, StepPaletteFadeIn/Out 10A8:00FC/018E, ApplyPaletteFadeLevel 10A8:0228 with its 16-bit
products, DestroyPaletteFade); 5 SetFont (ids 3 and 8: index 17, height 18, D3's single constant); 6
LoadPicture (the store's picture into the back port); 7 text (0x100 AnimatePortPalette 1200:00A8,
GetIndString, DrawTextInRect 1098:0ED1 with its shadows, the erase at the last frame through
displayOffset); 9 SwapAndShow (CopyPaletteEntries 1098:201D with the 236 limits, p3 == 1 god set,
displayOffset, CopyPortToWindow 10D0:0861's BitBlt). SetGodPaletteEntries 1090:0376 and w16's
AnimatePalette (PC_RESERVED entries through the map) model the palette path; GetColorIndexRGB 1098:0215
and SetForeColor 1098:0E0B the text colours. The 256-colour path only (3.5); anything else is refused at
the start or stops the replica with an error (BS stays off then: D6, 4.4).

Positions (frame, item, phase): phase 1 lies between an item's palette op (a fade level, a text start with
0x100, a SwapAndShow with p3 == 1) and the rest of its work, because the core presents inside each op
(w16's forced present). API: `pbs_movie_init`, `run_to` (0, 1 behind, -1 error), `pos`, `next_op`,
`find`, `inert_rest`, the client/system/god accessors, `front_pic`, `text_shown`, `last_fade`, counters.

### The shadow mirror (`present/bs/pbs_check.c`, the mirror part; 5.2 test 2)

`--bs-mirror 1` (harness; CIV_OBSERVER 0: exit 2), on the same listener and `bs.log` as BS1's checks. At
SeekSequence entry from 11E0:01AA (the Birth's start, D3) the replica is built from the core's state read
through w16q_* (the items, frame rectangle, display offset, the movie's palette block, the god palette's
log and object, the system palette, the statics 12D0:0066, the CLUTs 12B0:005A/0082/006E, the fonts
1420:5484 and index 12D8:0024, the window and its font height, the client from the screen); it refuses
unless g_noPaletteDevice, g_is16ColorDisplay and g_monochromeMode are 0. Attribution (D10: no new probe):
AdvanceMovie EN/EX, BirthMovieCallback EN, CreatePaletteFade EN, ApplyPaletteFadeLevel EN, GR_PicRead EN,
DrawTextInRect EN and the god palette's OBS_PAL_ANIMATE events give the core's position; a present at
AdvanceMovie's entry or outside it is the state after frame movie.frame - 1; a forced present after a
palette animation is the next op's phase 1. At each core present (`pbs_check_frame`, the harness's frame
hook) the replica is stepped there and compared: the window's visible client pixels, the system palette,
and the RGB composition with the replica's client and palette against present_core_xrgb(). A throttled
present after a fade's start is compared only when the rest of the frame is inert; a present it cannot
attribute is counted, not compared. The mirror ends at DestroySequencePlayer.

### Tests

* `tests/test_pbs_movie.c` (44 checks; `test_pbs_movie <gamedata> <outdir>`: the game data is not read,
  the synthetic store in `<outdir>\pbs-movie`): a 10-item script over two synthetic pictures and a STR#;
  fade-in/out levels and the 16-bit products; LoadClut and AnimatePortPalette; text centring, shadows,
  colour and the erase; overlapping fades in one frame; behind = 1; inert_rest; the op count (25); the
  refusals (another item type, a missing picture, a font id, a non-256-colour start); a failure met while
  running; no allocation kept.
* `tests/harness/ext_bs.py mirror` (Checked; CheckedNoObs: the refusal): p4-birth's start to 200 s and an
  EARTH start (Enter at 22 s, 'F' and Enter, the Birth skipped by Enter at 26 s) to 60 s, each without and
  with `--bs-mirror 1`; the start line (frame 1000, 78 items, client 512x320); the end by
  DestroySequencePlayer; every compared present equal (client, palette, RGB), behind 0, no unattributed
  present; for the whole Birth full coverage (pictures 8, texts 44, fades 16 with all 656 levels); P0 for
  both pairs.

## Results (private, `build/bs-stage/obj`, the overlay of the tree and this stage)

* Compilation: as BS1 (CC_STRICT_OK, CC_ALL_OK in Checked, CheckedNoObs and Release; OBS_LINT_OK).
* `test_pbs_movie`: 44 checks, 0 failed (Checked, CheckedNoObs, Release).
* `ext_bs.py mirror Checked` (final run, about 18:00 UTC, harness built from the current stage): EXT_BS_OK.
  p4-birth: `end bs mirror presents 1436 compared 1436 equal 1436 mismatches 0 client 0 palette 0 rgb 0
  rgb_compared 1436 unattributed 0 behind 0 pictures 8 texts 44 fades_complete 16 levels 656`; P0: 1930
  frames and the summary line equal. EARTH: 84 of 84 equal (pictures 1, texts 1, fades 1, levels 41) up to
  the skip's DestroySequencePlayer; P0: 581 frames equal. CheckedNoObs: exit 2 naming `--bs-mirror`.
* Sensitivity: a deliberate private perturbation of the replica (not staged) gave 76 mismatches (client
  44, palette 32, rgb 76), so equality is not vacuous.
* Note: the CheckedNoObs and Release private binaries predate the last two edits (test_pbs_movie.c's
  argument order, a comment in pbs_check.h); the Checked binaries are current. The build slot rebuilt
  all (the BS gate's step 1, `build.cmd all`).

## Decisions within the brief

1. **The comparison point** is the harness's frame hook (the core's own presents), not a timer; no new
   probe (D10). Forced presents inside palette ops are why positions carry a phase.
2. **Fonts and colours through the core** (D4): the replica's text uses w16q_draw_on TEXTOUT with the core's
   HFONT and W16Q_OP_COLOR, so glyphs come from the same font path; the unit test uses a model instead.
3. **Throttled presents** after a fade's start are compared only when the frame's remaining items are
   inert, since the core may present between the fade's creation and its first level.
4. **Scope**: the mirror only observes; BS3 (stepping the replica ahead of the core under `--birth-sync`)
   and BS4 are not in this stage.

## For the records

* **DESIGN.md 12.8 "Added in BS".** `present/bs/pbs_movie` (the replica: positions, items, palette path,
  text operations), `present/bs/pbs_check` (the mirror: attribution, comparison, coverage).
* **RUNNING.md.** Harness `--bs-mirror 0|1` (default 0; CIV_OBSERVER 0: exit 2): `bs.log`'s `bs mirror ...`
  lines (pbs_check.h lists them). `tests/harness/ext_bs.py mirror [Checked|CheckedNoObs] [--exe --root
  --port]`: 4 runs (two of 200 s, two of 60 s virtual), about 13 s, in test.cmd's `bs2_mirror`.
* **STATUS.md.** BS2 done (after the cycle): `test_pbs_movie` 44, `ext_bs.py mirror` (p4-birth 1436 of
  1436 presents equal, EARTH 84 of 84, full coverage).
* **FIDELITY.md.** The Windows Birth's replica equals the core's screen at every present of the recorded
  runs (the 256-colour path); 16-colour and monochrome remain outside BS (3.5).
* **FEATURES.md, the checklist.** Nothing yet (BS3 brings the visible change).
* **G-1.** Unchanged runs: no base harness run takes the new option.

# Extension UX5b, presentation unit (Birth square from its first picture: no squashed title) - record

Extension session E4, staging implementer.  Staged under `build/ux5b-stage/` only; nothing in the tree or in a shared
output was written for UX5b.  Base snapshot of the tree: 2026-10-17 07:32:19 UTC (the D6 gate's state; `obj/base-time.txt`),
every base hash in `BASE-SHA256.txt`.  D7a+D7b landed at 08:07:35 UTC (`build/d7ab-prep/landed-at.txt`) and changed one
base, `present/dos/pdos_seq.c` (two includes and four log-setter lines, disjoint from UX5b's block): the staged copy was
rebased mechanically with `obj/reapply.py write` (the result is exactly the previous staged copy plus D7a's six lines;
the previous copy and `BASE-SHA256.txt` kept in `obj/pre-d7ab/`), its base line updated, and the overlays rebuilt and the
checks re-run on the D7a+D7b tree (section "Tests", "After the rebase").  All nine bases verified against the tree
after the rebase (`sha256sum -c`: OK; `obj/reapply.py verify`: REAPPLY_VERIFY_OK).

## Result

With "4:3 aspect ratio for 320 x 200 screens" checked, the DOS Birth's square shape now starts at Birth's first picture
(O7:1A59, the copy of the picture to the shown page while the palette is black), not at Birth's start (SeekSequence ra
11E0:01AA).  Until then the shown page still holds the title menu (or Customize World's screen), which DOS fades to black
at O7:1A39; that fade now stays in the 4:3 shape, and the shape changes on the black frame.  A Birth that the core ends
before its first picture (Play on EARTH with a key pressed during the title's fade: C.8.8, the post-Birth fade then fades
the title) is never square.  The other end is unchanged: square through Birth's end fade and the black, 4:3 from the
first setup page.  Measured in the harness at 1920x1080 under 4:3 (`ext_aspect.py`, check 9, no tolerance): every
presented 320x200 frame from Birth's start to 1 s after its setup page is the title at 4:3, a Birth picture at square,
the setup page at 4:3, or black (either shape); the two shape changes land on a black frame (into Birth) and on the setup
page (out of it).  The base fails the same check with 41 squashed title frames in each of the fame, custom, fame_win and
intro runs and 59 in the EARTH run.

Unchecked: every DOS screen square, as before.  The Windows graphics are unchanged.  No core change (P0), no RNG use, no
host, harness-program or `present.c` change: one presentation-state word and one predicate in the DOS profile.

## Status

**LANDED 2026-10-17** (copy-in 09:35:23 UTC; the cycle ALL_GREEN 10:49:18 UTC after a void first attempt,
`build/ux5b-status.txt`; RELEASE_OK 10:56:23 UTC; user build `build/user-builds/ux5b/`; section "Landing").  At staging:
READY_TO_BUILD.  Implemented, compiled warnings-as-errors in Checked, CheckedNoObs, Release and the
cc.cmd strict variants in the private overlay, unit- and harness-tested in the overlay; the new and changed tests fail on
the base and pass with the change (section "Tests").  The user's checks UX5b-1..UX5b-7 and the rewritten UX5-5 are
pending (section "What the user checks").

| Staged file | Base sha256 (tree) | Staged sha256 |
|---|---|---|
| `present/dos/pdos_tl.h` | `00d4cf112caebcba015d26c058b7b4e854da3577d6ec0d4853ac9343057ceaa4` | `609f5f576ba8ee144c02b0aa3cca49f9e49ae77b482b8a82bae3cff85a173466` |
| `present/dos/pdos_birth.c` | `1f18b5f7b87101155b0229c536c5644bf6dcd7be63b4e487b4bd5722a3d09d1e` | `73d7a8e5103e63be38f88bf6538dae5a2ef6bc767d9abf6e3b7b3c4ea0360cae` |
| `present/dos/pdos_birth.h` | `e6abfa9cee6eabf2ad24da296ee2dda3ef1214911ca70b87ef1fe7fa978141fc` | `c1f5749c40c2d057048429368e197567bea247e14be542000623256be47f0e04` |
| `present/dos/pdos_seq.c` | `c1b0cef57c0622133f1a388018d379a45dcce63971c9ad27431f75cb34a2bb28` (D7a+D7b's; before them `4102112f...`) | `4b8369d480a07b7612c5ba38f8bbe65e39370abdd6a0d676aeb531267ac8e9fa` (before the rebase `04a17460...`) |
| `present/dos/pdos_seq.h` | `af2a15ff511867b6f685684d34d1978f81aed5fb4df8cbd5a81461329f37a867` | `db05d3358811b1f98f557d790ab0ecf50a13b78920f13236a2e1544dc2414043` |
| `tests/test_pdos_aspect.c` | `d7e1a1bd5d4e0b845b72d4b52649c2eabb57b3d1e115f743ea5ee70e87178299` | `bcab7e1428541aae64b6fce96ad598deee5fe72f2bece911ce70d13852d16c96` |
| `tests/test_pdos_seq.c` | `acada6d7efca727ad82c462649dc9d6c599c70ac98ba8fedc6621c799b35bb13` | `7c71a4d9afd451d22ccd083352910c3a23a38946788d454c18844c9ca2b498f9` |
| `tests/harness/ext_aspect.py` | `434c18713bb59055f5534db99d78cdc60607c1f9f486c257f7a95bed49dacd48` | `9da821a98a8b0c7d0624a7a5ce4d57dcfd90d5967a58f923871df586a1c780cd` |
| `test.cmd` | `77c7bb11e2d36fc770bc1ad6f7fd2747ff9c36fac80d9778e4d79a4146684db9` | `6be85d66e755c43cb067195064543cae117020c8aa72c0430ba86f82788188a3` |
| `docs/ext-UX5b-record.md` | new | (this file) |

`test.cmd` changes only section `ux3_aspect`'s comment (three lines more) and its echo line; its `@section` line is
unchanged (`cpu=6 est=20`), no new section, no new test program, so there is no `BUILD-TEST-ADDITIONS.md`
(`build.cmd` unchanged).  `gen/testpar.py check` on the staged `test.cmd`: exit 0.

## The user's report and the cause

The user's revision list, 2026-10-17 about 07:00 UTC, item 3 (verbatim): "After DOS intro when switching to Birth scenes,
momentarily title screen is squashed to square aspect and then switches to Birth scenes, this transition shall be
seemless."  Checklist UX5-5 failed on it.

Cause (UX5's rule, `pdos_seq_square_scene` = `g_bview && !pdos_setup_shown()`): the Birth view `g_bview` turns on in
`birth_start` (`pdos_seq.c`, `set_bview(1)`) at the core's Birth probe (SeekSequence ra 11E0:01AA, C.8.1 T1), before DOS
Birth has drawn anything.  DOS Birth's first picture comes about 1.0 s later (the fame run: Birth 15,272,400 us, picture
16,256,874 us): the program's prepare (O7:0012..0055) and its first picture line load the picture into page 2 and fade
the shown screen, still the title menu, to black before copying the picture to page 0.  So for about one second (58
present ticks in `test_pdos_aspect`, 41 presented frames in the harness's fame run) the fading title was laid out square
(5x5 at 1920x1080 instead of 4x5): the "momentarily squashed title".  The other end was already seamless: UX5 keeps square through Birth's end fade
(R:01A8:0840, its last frame black) and the cleared screen, and the setup page is drawn in the same step as the
hand-over R:01A8:087C, where `pdos_setup_shown()` turns the shape back.

## Design and listing evidence

DOS Birth's first picture, in the order the port's `pdos_birth.c` follows (`picture_line`, case
`PDOS_BIRTH_PC_O7_1A41`):

| Address | What (label) |
|---|---|
| O7:19DB | the picture line: "birthN.pic" with its digit advanced (DOS listing) |
| O7:1A21 | `lcall R:1FA1:0254`: the picture into page 2; page 0 (shown) untouched (DOS listing) |
| O7:1A29..1A2E | `cmp word ptr [D762], 0` / `je O7:1A41`: the fade is skipped when [D762] is 0 (DOS listing); the port takes the VGA path with the fade (as `pdos_birth.c` before UX5b; inferred, unchanged here) |
| O7:1A30..1A39 | `lcall R:0000:04D4` with (8, 0, 0, 0): the shown screen faded to black in 8 steps (DOS listing) |
| R:0000:05EB..060B | the fade's colour: start x not(w) + target x w with the weight [006A]; at the last step w = FFFFh, so a black target gives exactly black (DOS listing; the port's `pdos_fade_step`) |
| O7:1A41..1A59 | `lcall R:0000:07FB` (driver G#20): page 2 copied to the shown page under the black DAC (DOS listing) |
| O7:1A6B..1A83 | the picture's .PAL into DGROUP:C5BE (DOS listing) |
| O7:1A93 | `lcall R:0000:04AA` (8, C5BEh): fade in to the picture's palette (DOS listing) |

So in DOS the screen goes title (fading) -> black -> Birth picture (fading in), and the only moment where neither the
title nor a Birth picture is visible is the black between O7:1A39's end and O7:1A93's first step.  In the port the
fade's last frames are black (6-bit DAC) and O7:1A59 runs at its end (inferred from the port's timeline; measured: the
harness's change frame is black in every pictured run without a graphics switch, and in `test_pdos_aspect`, whose ticks
fall elsewhere, the first square frame is Birth's picture fading in).  That is where the shape now changes.

Birth's end (unchanged by UX5b, checked again): R:01A8:0840 `lcall R:0000:04D4` (5, 0, 0, 0) fades Birth's picture to
black (its last frame black), R:01A8:085B (`lcall R:0000:0BFA`, the screen cleared), R:01A8:0867 (`lcall R:1FA1:026C`,
SP257's palette), R:01A8:087C (the setup hand-over, where the port draws the setup page in the same run; D5).  Square to
that black, 4:3 from the setup page's first frame: no Birth frame at 4:3 and no setup frame square.

The change (presentation state only):

* `pdos_tl.h` `PdosBirthVars`: one new word `shown` (22 of the union's 32 words used now; `PdosTl`'s size
  unchanged, the union is bounded by `raw[PDOS_TL_VARS_WORDS]`).
* `pdos_birth.c`: `shown = 1` right after the O7:1A59 copy (case `PDOS_BIRTH_PC_O7_1A41`), `shown = 0` in the prepare
  (O7:0012); `pdos_tl_bind`/`pdos_tl_start` already clear the whole timeline, so a new Birth never inherits a previous
  game's value.  New accessor `pdos_birth_pictured(tl)`: 1 when the timeline is Birth's program, started
  (`state != IDLE`, so also after an abandon), its sequence is `PDOS_SEQ_BIRTH` (not the post-Birth `FX_FADE`) and
  `shown` is set.
* `pdos_seq.c` `pdos_seq_square_scene` = `g_bview && pdos_birth_pictured(&g_birth) && !pdos_setup_shown()`.  It reads
  `g_birth`, the story timeline, which keeps its state when the core's Birth end abandons it (C.8.8,
  `pdos_tl_abandon`): a Birth ended after its first picture stays square through `g_post`'s end fade to the setup page,
  as before; one ended before its first picture never goes square.
* `pdos_seq.h`, `pdos_birth.h`: the contracts.  Nothing else reads `pdos_seq_square_scene` besides
  `pdos_profile.c` `dos_square_only` (profile.h `square_only`, read by `present.c` `frame_aspect`/`relayout_due`).

The choice: the planned alternatives were (a) the BS3 synchronisation phase (`pdos_bsync_of`; `PDOS_BS_FADE_IN` is
marked at O7:1A59) and (b) a new flag set at O7:1A59.  (b) is taken.  The phase is a current state, not a history: it
goes on to `PDOS_BS_PIC`, `TEXT`, `CLEAR`, `FADE_OUT`, `BUILDING` and `POST_FADE`, so "square" would have to be "any
phase other than `PRE`", and that is wrong for the EARTH case (the post-Birth fade of an abandoned Birth marks
`POST_FADE` while the title is still on page 0) and would tie this presentation rule to BS's semantics, which BS owns.
The flag is set by the copy itself, states the rule directly and costs one word.

Fidelity: DOS has no aspect option; the shape is civ64's presentation choice (FIDELITY F116).  No DOS step, timing,
palette or picture changes; the timeline's step sequence and every presented frame's pixels are unchanged (only the
layout of some frames).  Labels: the listing rows above "DOS listing"; the black frame at O7:1A59 "inferred" from the
port's timeline and measured in the harness; whether the DOS EARTH title is shown with MAP.PIC's palette during that fade
"unknown" (see "Observations").

## Deviations

None from DOS.  From UX5: Birth's square shape starts at its first picture instead of its start (the user's revision).
Under 4:3, an item switch in the window menu during the title's fade into Birth now changes the shape at once (as on the
title menu); after the first picture it changes nothing visible (Birth square), as UX5 had it for all of Birth.

## Tests

The predicate is checked both as a unit (the DOS flows driven through the observer probes) and through the present layer
and the real harness (presented frames); every new check looks at what each frame shows, not only at the predicate.

* `tests/test_pdos_aspect.c` (93 -> 140 checks).  New: a content checker (`cc_begin`/`cc_frame`/`cc_end`) that
  classifies every presented 320x200 frame from Birth's start by what is on page 0 (black by the shown DAC; the title
  page as it was at Birth's start; a Birth picture once seq BIRTH logged `show_picture`; the setup page once shown) and
  requires its shape to fit (title 4:3, Birth square, setup 4:3, black either), with the number of shape changes and
  the content kinds wanted.  Applied to: Start a New Game's outro, Birth and setup (two changes); Play on EARTH with the
  core's Birth end at 0.6 s during the title's fade (DOS Birth abandoned before its first picture, the post-Birth fade
  of the title, the setup page: no change, no Birth frame); EARTH reaching its picture (one change); DOS Birth's own end
  and post-Birth steps while the core still waits in Birth (D4b4's auto-continue: two changes; then the core's skip and
  Birth end change nothing); Birth after Customize World and over the Hall of Fame's screen.  Through the present layer
  at 1920x1080 under 4:3: Birth's start keeps 4:3 with no VIEW show; the item toggled and the graphics switched to
  Windows and back (`present_request_profile`, the Ctrl+Shift+Backspace path) during the title's fade: 4:3/square at
  once, back in DOS 4:3; square from the first tick at or after O7:1A59 with exactly one VIEW show; toggles and the
  graphics switch in Birth: square; the switch across the hand-over: back in DOS the setup page at 4:3; and the square
  option: every frame square, no change.  The test uses no new API (it links against the base objects).
* `tests/test_pdos_seq.c` (214 -> 215): D5P (b)'s Birth vector now expects 0 at Birth's start and 1 after the ticks to
  its first `show_picture`.
* `tests/harness/ext_aspect.py` (32 -> 52 checks, 9 -> 12 runs): three new runs, `earth_fade` (X at 1 s, Play on EARTH,
  X at 6.7 s: the core's Birth skip and end at 7,086,450 us, during the title's fade, before the first picture which
  would come at 7,194,174 us), `earth_fade_sq` (the same with `--aspect square`) and `fame_sw` (fame's keys with the
  profile chord at 15.6, 15.9, 16.1, 16.5 s around Birth's start and first picture, and at 24.3, 24.8 s around the
  setup page).  Check 2's markers now put Birth's square span from its first `show_picture` (no tolerance at Birth's
  markers); new check 9 (UX5b): for fame, custom, fame_win, intro, earth_fade and fame_sw, every 320x200 show from
  Birth's start to 1 s after its setup page fits its content (by its sha256: black, the setup page from the hand-over,
  a Birth picture from the first `show_picture`, else the title) with no tolerance, and lists the shape changes; check 4
  gains earth_fade_sq; P0 groups gain fame_sw and (earth_fade, earth_fade_sq).

Results (private overlay, `build/ux5b-stage/obj/`, 2026-10-17 07:32..08:10 UTC):

| Check | Base | Staged |
|---|---|---|
| Checked, CheckedNoObs, Release (`obj/stage-all.cmd`, warnings as errors) | CC_ALL_OK (Checked) | CC_ALL_OK all three |
| cc.cmd strict C (`pdos_birth.c`, `pdos_seq.c`, `pdos_tl.c`, `pdos_intro.c`, `pdos_profile.c`) | - | CC_STRICT_OK all three variants |
| `test_pdos_aspect` | 93 checks, 0 failed | 140 checks, 0 failed (all three variants) |
| `test_pdos_seq` | 214, 0 failed | 215, 0 failed (all three) |
| `test_present`, `test_pdos_profile`, `test_pdos_setup`, `test_timeline`, `test_pbs_view`, `test_pdos_adapt` | 951, 51 (47 NoObs), 164, 158, 45, 155 | the same; `present-goldens.txt`, `title-box.bmp`, the timeline step files and `pbs-view` byte-equal to the tree's |
| `ext_aspect.py` (staged script, staged harness) | - | EXT_ASPECT_OK, 52 checks |
| `ext_timeline.py` (base and `--group bs`), `ext_continue.py`, `ext_bs.py` assets and mirror | - | byte-equal to the tree's current outputs (EXT_TIMELINE_OK, EXT_CONTINUE_OK, EXT_BS_OK) |
| `ext_mirror.py` | - | MIRROR_OK runs 29, equal to the tree's except the `p0` field (`n/a`: the private root has no ext_p0 V0 outputs) |
| `ext_adapt.py`'s DOS-form pairs (`obj/adapt_priv.py src`) | - | 38 cases, 129 checks, 0 failed (equal to UX5's run) |
| `ext_p0.py --vars V0,V1,V4d,V6r,V6w` | - | P0_OK checks 212 (as UX5's run) |
| `ext_zoom.py --profiles dos` (the tree's golden, no --update) | - | ZOOM_OK combinations 32 runs 36 samples 240 map comparisons 6 centre runs 2 mzi runs 6 mzs runs 2 (every DOS golden sample equal) |
| registry.py check, obs_lint, obs_tables --check, pdos_scene_check, adapters check | - | REGISTRY_OK; OBS_LINT_OK files 124 probes 203 callsites 101; OBS_TABLES_OK probes 203 sites 101; PASS 1078 checks; ADAPT_OK rows 116 steps 25 |
| `gen/dos/nodos.py check` (`obj/chk_priv.py nodos`: the staged files with this record and the private Checked binaries) | - | NODOS_OK, 23 files, 0 hits |

Key lines of the staged `ext_aspect.py` (check 9): fame "Birth 15272400 picture 16256874 setup 24596282: title 40, Birth
147, black 3, setup 1, changes ft>sq@16256900(black) sq>ft@24597250(setup)"; custom "picture 12727356 ... changes
ft>sq@12727400(black) sq>ft@21576350(setup)"; intro "picture 74258074 ... ft>sq@74258100(black) sq>ft@83587150(setup)";
earth_fade "picture none (abandoned) setup 7514482: title 59, Birth 0, black 1, setup 1, changes none"; fame_sw "title
15, Birth 117, black 0, setup 1, changes ft>sq@16520000(Birth) sq>ft@24820250(setup)" (both changes when returning to
the DOS graphics: Birth's picture square, the setup page 4:3); earth_fade_sq 207 shows square; P0: fame's group (with
fame_sw) 249 frame lines, earth_fade's 195.

### After the rebase onto D7a+D7b (2026-10-17 08:13..08:34 UTC, `obj/rerun_d7ab.sh`, log `obj/r2.txt`)

The table above ran on the 07:32 base.  After D7a+D7b landed, both overlays were rebuilt from the tree's current state
(src-base = the tree, src = the tree with this stage) and UX5b's checks re-run:

* Checked, CheckedNoObs, Release: CC_ALL_OK; strict C (the same five files): CC_STRICT_OK in all three.
* Unit tests, all three variants: `test_pdos_aspect` 140/0, `test_pdos_seq` 215/0, `test_present` 951, `test_pdos_setup`
  164, `test_timeline` 158, `test_pbs_view` 45, `test_pdos_adapt` 155, `test_pdos_profile` 59 (55 CheckedNoObs; D7a's
  count, the same on the new base).  The new base itself: `test_pdos_aspect` 93/0, `test_pdos_seq` 214/0.
* The staged tests on the new base: `test_pdos_aspect` FAIL 20 of 140, `test_pdos_seq` FAIL 1 of 215 (as before).
* `ext_aspect.py` staged: EXT_ASPECT_OK, 52 checks, its output identical to the pre-rebase run (`r2-aspect-src.log`);
  the staged script with the new base's harness: EXT_ASPECT_FAILED=12, the same failure lines.
* obs_lint OBS_LINT_OK files 126 probes 203 callsites 101; REGISTRY_OK; pdos_scene_check PASS 1084 checks (141 scene
  rows, 10 font rows); ADAPT_OK rows 123 steps 25; the tree's `gen/obs_tables.py --check` OBS_TABLES_OK probes 203 sites
  101 (the counts grew with D7a, not with UX5b).
* The heavier harness groups (ext_timeline, ext_continue, ext_mirror, ext_bs, ext_adapt, ext_p0, ext_zoom) were not
  re-run on the rebased overlay: UX5b's only change to `pdos_seq.c` is the predicate, and D7a+D7b's own cycle covers
  their lines; the landing cycle runs them all.

## Reproduction on the base (the new tests fail there)

* The staged `test_pdos_aspect` linked against the base objects (`obj/onebase.cmd`): FAIL 20 of 140, e.g. "new game:
  UX5b: every frame's shape fits its content (... 58 not fitting, the first at 82362352 us: title shown square)", "EARTH,
  the core's Birth end before the first picture: ... 60 not fitting", "present: DOS Birth's start under 4:3: the title
  still 4:3 at the next tick, no VIEW show".  The staged `test_pdos_seq` on the base: FAIL 1 of 215 ("D5P (b), UX5b:
  Birth's start: ... 4:3").
* The staged `ext_aspect.py` with the base harness: EXT_ASPECT_FAILED=12 (checks 2 and 9 for each of fame, custom,
  fame_win, intro, earth_fade, fame_sw), e.g. fame "41 wrong (first (15272400, 'title', 'sq'))", earth_fade "59 wrong",
  fame_sw "16 wrong".
* The other way round, the tree's tests on the staged code: the old `test_pdos_aspect` fails 7 of 93 and the old
  `test_pdos_seq` 1 of 214 (they assert UX5's square at Birth's start); the tree's `ext_aspect.py` with the staged
  harness: EXT_ASPECT_FAILED=4 (its markers put square at Birth's start, e.g. fame "41 wrong (first (15586300, 'ft',
  'sq', 15272400))").  Hence the staged tests replace them.

## Observations for the orchestrator (no change made)

* Play on EARTH: Birth's prepare loads MAP.PIC into page 1 with its palette into the shown DAC (O7:0049,
  `R:1FA1:0220(1, "map.pic")`, flag 1 in the port's `load_pic`).  Page 0 still shows the title, so in the port the EARTH
  title is shown with MAP.PIC's palette while it fades (D4b3's existing behaviour, untouched by UX5b; it has no effect on
  the shape).  Whether DOS sets that palette at once (R:1FA1:0220 -> R:1FA1:01A2, which calls R:1FA1:000A, R:1FA1:05E0,
  R:0000:108E and loops over driver G#19) was not settled here: unknown.  If it matters, a separate unit with the DOS
  oracle.
* The tree's `build/test/Checked` was being rewritten by another unit's cycle while this record was written
  (`ext-adapt.txt`, `ext-p0.txt`, `ext-zoom.txt`, `nodos.txt` empty at 09:58 UTC); the comparisons above use the
  outputs of 08:31..08:43 UTC.

## For the records

* **manual-checklist-ext.md** (the orchestrator): new section UX5b with UX5b-1..UX5b-7 (below); UX5-5 rewritten as
  below (status: failed 2026-10-17 about 07:00 UTC, the old wording; the new wording pending in the UX5b build); UX5-6's
  last sentence "Switching it during Birth changes nothing visible (Birth stays square)" holds from Birth's first
  picture on; during the title's fade into Birth the switch takes effect at once, as on the title menu (UX5b-6).
  UX5-1..UX5-4 and UX5-7 unchanged.  D5P-7 ("4:3 to Birth, square Birth, 4:3 setup") still true, with Birth meaning
  its pictures.
* **FIDELITY.md** F116: a UX5b paragraph: "**Changed again by UX5b** (2026-10-17, the user's revision list of about
  07:00 UTC, item 3: 'momentarily title screen is squashed to square aspect ... this transition shall be seemless';
  `ext-UX5b-record.md`): DOS Birth keeps square pixels from its first picture (O7:1A59, the copy to the shown page under
  the black DAC after the title's fade O7:1A39), no longer from its start (SeekSequence ra 11E0:01AA), so the title's
  fade into Birth follows the option and the shape changes on a black frame; a Birth that the core ends before its
  first picture (C.8.8) is never square; the end (square through the end fade and the black, 4:3 from the setup page)
  unchanged.  `pdos_seq_square_scene` = `g_bview && pdos_birth_pictured(&g_birth) && !pdos_setup_shown()`
  (`PdosBirthVars.shown`, set at O7:1A59).  Presentation only, P0 (**the user's direction**).  Status: implemented in
  UX5b; tests `test_pdos_aspect` (93 -> 140), `test_pdos_seq` 215, `ext_aspect.py` (12 runs, check 9, 52 checks); user
  checks UX5b-1..UX5b-7 and UX5-5 pending."  No new F number is needed (F-new-1 none).
* **DESIGN.md** 12.7 "As implemented (UX3; changed by UX5)" -> "(UX3; changed by UX5 and UX5b)": the first bullet's
  "1 ... only while the Birth view is on and the setup page is not yet shown (`g_bview && !pdos_setup_shown()` ...)"
  becomes "only from DOS Birth's first picture (O7:1A59, `pdos_birth_pictured(&g_birth)`, kept when the core's Birth
  end abandons it) while the Birth view is on and until the setup page is shown"; "The switch points": "4:3 to square
  at Birth's start (SeekSequence ra 11E0:01AA)" -> "4:3 to square at Birth's first picture (O7:1A59, on the black frame
  after the title's fade O7:1A39; none when the core ends Birth before it)"; add "Before UX5b: square from Birth's
  start" to the history; Tests: `test_pdos_aspect` 140 (the content checker), `test_pdos_seq` 215, `ext_aspect.py` 52
  checks in 12 runs.  12.1/12.2's short mentions "DOS Birth is square" stay true.
* **DOS-PROFILE.md** (prose only, lines about 155..157): "applies to every 320x200 DOS screen except Birth (its story,
  its end fade and the black before the first setup page)" -> "... except Birth from its first picture (its story, its
  end fade and the black before the first setup page); the title's fade to black at Birth's start follows the option
  (unit UX5b)".  No call addresses added; run `gen/obs_tables.py --check` after the edit.
* **RUNNING.md**: `test_pdos_aspect` row (line about 238): "1 from Birth's start to the setup page" -> "1 from Birth's
  first picture to the setup page (UX5b; every frame's shape against its content)", "93 since UX5" -> "93 since UX5,
  140 since UX5b"; `[UX3: ext_aspect.py]` rows (about 239, 403): "twelve since UX5b: `earth_fade`, `earth_fade_sq`,
  `fame_sw`", "square from Birth's first picture", "check 9 (UX5b): every show from Birth's start to its setup page fits
  its content", "52 checks since UX5b"; `--aspect` rows (about 315, 503): "not DOS Birth" -> "not DOS Birth from its
  first picture".
* **FEATURES.md**: the UX3 row (about line 250): "with the DOS graphics DOS Birth keeps square pixels" -> "... from its
  first picture (UX5b; the title's fade into Birth follows the option)"; tests "since UX5b `test_pdos_aspect` (140
  checks) and `ext_aspect.py` (12 runs, 52 checks)".
* **STATUS.md** (the orchestrator): unit UX5b staged/landed; the revision list's item 3 addressed.

## What the user checks

As for UX5, the 4:3 shape only shows where the window has room for it: use full screen (Alt+Enter), a larger window or
"Scale to fit".  In 4:3 the DOS picture is a little narrower with wider black side bars than in the square shape; the
easiest thing to watch is the width of the black bars at the sides.

* **UX5b-1** In the DOS graphics with "4:3 aspect ratio for 320 x 200 screens" checked, watch the intro to the title
  menu and choose Start a New Game.  The title menu fades to black in the same 4:3 shape it had; the side bars change
  width only while the screen is completely black, and Birth's first picture fades in already in its square shape.  At
  no moment is the title picture or its menu box shown in the wider square shape (before this build it was, for about
  a second).
* **UX5b-2** The same with Play on EARTH, and with Customize World and OK: the title (or the Customize World screen)
  fades out in 4:3, Birth's first picture comes up square out of black.
* **UX5b-3** At the end of Birth (press a key during Birth, or let it run through BUILDING NEW WORLD): Birth's picture
  fades to black in its square shape and the first setup page appears in 4:3.  No Birth picture is ever shown in 4:3,
  and the setup page is never shown square.
* **UX5b-4** Choose Play on EARTH and press a key at once, while the title is still fading: the title fades out and the
  first setup page appears, all in 4:3, with no Birth picture and no change of shape at all.
* **UX5b-5** Press Ctrl+Shift+Backspace (to the Windows graphics) right after choosing Start a New Game, while the title
  fades, and again to come back: the DOS screen comes back in 4:3 if Birth's first picture has not come yet, square if
  it has.  Do the same on the first setup page: back in the DOS graphics the setup page is 4:3.  The Windows graphics
  look as before.
* **UX5b-6** Uncheck and check the item in the window menu during the title's fade into Birth: the shape follows at once,
  as on the title menu.  After Birth's first picture switching it changes nothing visible (Birth stays square).
* **UX5b-7** With the item unchecked every DOS screen is square, the title's fade and Birth included, and nothing changes
  shape between the title, Birth and the setup page.

The rewritten **UX5-5** (replaces the failed one): Start a New Game (or Play on EARTH, or Customize World and OK): 4:3
through the title's fade to black, square from Birth's first picture (the change happens while the screen is black)
through the whole of Birth (its end fade and the black before the first setup page included), 4:3 again from the first
setup page.

## Expected changes at the build slot

* `sections/unit.log`: `test_pdos_aspect` 93 -> 140 checks; `test_pdos_seq` 214 -> 215; every other unit test unchanged
  from the tree's values at the landing (`test_pdos_profile` 59 since D7a).
* `ext-aspect.txt`: 32 -> 52 PASS lines.  The runs line names 12 runs (with `earth_fade`, `earth_fade_sq`, `fame_sw`);
  check 2's shape lines in the new wording ("square (5x5 at 160,40) from Birth's first picture", switches
  `sq@16256874` instead of `sq@15272400` for fame and fame_win, `sq@12727356` for custom, `sq@74258074` in intro's
  list); for earth_fade and fame_sw their flow, title_shape, layout-fields, shapes, other-shows and pointer lines; six
  check-9 lines; `earth_fade_sq` in check 4; intro's check-8 line unchanged ("2 in Birth stay square"); four P0 lines
  (fame's group with fame_sw; earth_fade with earth_fade_sq); EXT_ASPECT_OK.  The staged run's file is
  `build/ux5b-stage/obj/aspect-src.log` (it differs from the tree's `ext-aspect.txt` only in these lines).  `sections/ux3_aspect.log`: the new echo line, EXT_ASPECT_OK.
  `sections/times.txt`: ux3_aspect about 25 s instead of 18.5 (three more runs of 10..32 s virtual time in parallel).
* `nodos.txt`: one file more (this record), 0 hits.
* No golden changes: `present-goldens.txt`, ext-timeline's golden, ext-zoom's golden unchanged.  P0 unchanged (core
  outputs equal; `EXT_G1_OK runs 77`).  Unchanged outputs: ext-timeline (both groups), ext-continue, ext-mirror, ext-bs,
  ext-adapt, ext-p0, ext-zoom, ext-frames, ext-replay, ext-slots, gate3b, uninit, scenarios, p4tests, adapters-check,
  obs-lint, obs-tables, registry-check, pdos-scene-check, dos-decoded.
* Coverage: `pdos_birth.c` gains one accessor and two assignments, all executed by `test_pdos_aspect`/`ext_aspect.py`;
  line coverage of `present/dos` may move by a few lines, no new uncovered branch expected.

## Rebase notes

Ten files: nine staged tree files (bases in `BASE-SHA256.txt`) and this record (new).  Line endings follow the bases
(CRLF: `pdos_seq.c`, `pdos_seq.h`, `test.cmd`; LF: the others).  If any base moved, `C:/Python314/python -B
build/ux5b-stage/obj/reapply.py write build/ux5b-prep/rebased` re-applies UX5b's anchored replacements to the tree's
current files (each anchor must occur exactly once; CRLF kept) for the seven files it handles; `reapply.py verify`
compares them with the staged copies now (REAPPLY_VERIFY_OK after the D7a+D7b rebase).

* `present/dos/pdos_seq.c`: the UX3 block of `pdos_seq_square_scene` (its comment and one line).  Already rebased onto
  D7a+D7b's landed file (above).  **D7d and D7j stage it too** (their changes: includes and log setters, disjoint from
  this block); `reapply.py`'s anchor was checked on their staged copies.  Whoever lands second re-applies with
  `reapply.py write`.
* `present/dos/pdos_tl.h` (one member at the end of `PdosBirthVars`), `pdos_birth.c` (two assignments and the accessor
  after `pdos_birth_at_setup`), `pdos_birth.h` (the prototype), `pdos_seq.h` (the contract of `pdos_seq_square_scene`),
  `tests/test_pdos_seq.c` (the header line and D5P (b)'s Birth vector): nobody else stages them.
* `test.cmd` (**DBL stages it**, another section; D7a lists it with a "-" base): section `ux3_aspect`'s comment and echo
  line only; `reapply.py` handles it; then `gen/testpar.py check test.cmd`.
* `tests/test_pdos_aspect.c`: a whole-file copy (nobody else stages it).  `tests/harness/ext_aspect.py`: produced from the
  tree's file by `obj/edit_aspect.py` (copy the tree's file, then run it); nobody else stages it.

## Build-slot steps

1. Re-check every base against the tree (`BASE-SHA256.txt`); rebase as above where one moved.
2. Snapshot the Checked outputs and the files to be replaced (`build/ux5b-prep/before/`, `tree-before/`); copy the ten
   files byte for byte; `build/ux5b-prep/landed.sha256`; predictions from "Expected changes" before the cycle.
3. `build.cmd checked`, `test.cmd checked`, `ext_g1.py check`; then `build.cmd release`.  No BUILD-TEST-ADDITIONS.
4. User build `build/user-builds/ux5b/` and the user checks UX5b-1..UX5b-7 and UX5-5 above.

## Landing (2026-10-17, build slot)

**Landed 2026-10-17 09:35:23 UTC; cycle ALL_GREEN 10:49:18 UTC (second attempt, `-r2`); RELEASE_OK 10:56:23 UTC; user
build `build/user-builds/ux5b/` (about 10:57 UTC).**  The orchestrator gave the build slot after accepting UX5b (the
`PdosBirthVars.shown` flag over the BS3 phase), on condition that the copy-in waits for the D7a+D7b docs pass
(`build/docs-d7ab-done.txt`).  Scripts and outputs in `build/ux5b-prep/` (`mk_prep.py` derived `ux5b-cycle.ps1`,
`compare.py` and `mk_userbuild.py` from `build/d7ab-prep/`; `mk_fill.py` derived `fill_stillopen.py`).

1. **Bases and preparation** (08:53..08:56 UTC).  All nine bases were the tree's files (D7a+D7b's `pdos_seq.c` already in
   the rebase); `reapply.py verify` REAPPLY_VERIFY_OK; the staged copies frozen in `build/ux5b-prep/staged.sha256`;
   `land.py` dry run DRY_RUN_OK 10; `predictions.txt` written.  The marker `build/docs-d7ab-done.txt` appeared at
   09:33 UTC (polled every two minutes; no docs file was read or edited while waiting).
2. **Copy-in** (09:35:23 UTC, `land.py --write`, `land-write.txt`).  Snapshot of the tree's Checked outputs (63 files)
   in `build/ux5b-prep/before`, the nine previous tree files in `tree-before`; the ten files byte for byte (nine
   changed, this record new, in its version without this section); `landed.sha256` (11 lines, with `build.cmd`
   unchanged `40de571d...`), `landed-at.txt`.
3. **First cycle attempt, void.**  Step 1 (09:35:29..09:35:53 UTC) ended `BUILD_ERROR=gen\interfaces.py failed`:
   `PermissionError` writing `docs\API-MAP.md` (a generated file; a transient lock by another process, the file was
   writable again at 09:50 UTC, checked by opening it for update without writing).  `cmd /c build.cmd checked`
   nevertheless returned exit 0, so the script recorded step 1 as exit 0 and started step 2 against the previous
   binaries.  The slot stopped that attempt at about 09:46 UTC (only the cycle's own process tree, PowerShell 58620 and
   its `test.cmd` children, was terminated; no tree-binary process was left) and recorded it in `build/ux5b-status.txt`
   as void.  `ux5b-cycle.ps1` then gained a guard: a step is green only when its log's last line also carries its
   marker (`BUILD_OK`, `TESTS_OK`, `EXT_G1_OK`).  The landed files were re-verified (10 of 10 equal to `landed.sha256`).
4. **The cycle, `-r2`.**  Step 1 `build.cmd checked` 09:52:33..10:04:58 UTC BUILD_OK (745 s; the machine shared with
   other units); step 2 `test.cmd checked` 10:04:58..10:49:18 UTC TESTS_OK (2,660 s; TEST_SECTIONS 29, wall 2,639.2 s,
   failed 0); step 3 `ext_g1.py check` EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events): **ALL_GREEN**.
   Step 4 `build.cmd` (Release) 10:49:42..10:56:23 UTC BUILD_OK: **RELEASE_OK**.  Logs `build/ux5b-1..4-*-r2.log`
   (and the void attempt's `build/ux5b-1-build-checked.log`, `build/ux5b-2-test-checked.log`).
5. **Outputs against the predictions** (`compare.py`, host times left out; `compare.txt`): 56 of 63 files equal.
   Changed as predicted: `sections/unit.log` (`test_pdos_aspect` 93 -> 140, `test_pdos_seq` 214 -> 215, both 0
   failed; besides, the host-timed OBS_COST line), `ext-aspect.txt` (52 PASS lines, EXT_ASPECT_OK, byte-identical to
   the private `build/ux5b-stage/obj/r2-aspect-src.log`), `sections/ux3_aspect.log` (the new echo line),
   `sections/times.txt` (host times; ux3_aspect 23.9 s).  Not as predicted, explained: `nodos.txt` 1,766 files (not
   1,765), 0 hits, NODOS_OK: this record and `docs/verify/BRIEF-hm.md`, which another agent created at 10:10 UTC during
   the cycle; `coverage.txt` (and `sections/coverage.log`) "other functions entered" 662 -> 663: an informational
   count of the original's functions entered by the test and harness runs (it does not fail); the new harness runs
   (`earth_fade`'s core Birth skip during the title's fade, `fame_sw`) are the likely source, which function is
   unknown.  All other outputs equal, including ext-timeline (both groups), ext-continue, ext-mirror, ext-bs, ext-adapt,
   ext-p0, ext-zoom, ext-frames, ext-replay, ext-slots, present-goldens; no golden changed; P0 unchanged.
6. **User build** `build/user-builds/ux5b/` (`mk_userbuild.py ux5b 2026-10-17 10:57 10:56`): `civ64.exe`
   `7d5c398cea286822c54dd61809e24a021ce8d38022f5ddc48320a85d72aeeecc` (= `build/x64/Release/civ64.exe`),
   `CIVWIN.zip` `058d4e00...` and `civdos.zip` `0eac32c9...` copied from `build/user-builds/d4/`, `WHAT-TO-CHECK.txt`
   `bf85c11cd91e0409ba6c1262b458bc57e815a0a0fccc970bdbdb8eee03372cdc` (CRLF): UX5b-1..UX5b-7, the reworked UX5-5, the
   note on UX5-6, and "Still open" from the checklist's pending rows at 10:56 UTC (62 items: d7b 9, d6f 7, fce 5, tld 7,
   d6e 6, mzs 7, si 6, mzi 7, ux5 6, d5p 1, any build 1; UX5-5 and UX5b-.. left out as this build's own).
7. **This record** with this section copied to `docs/ext-UX5b-record.md` (it replaces the copy landed at 09:35 UTC,
   whose hash is in `landed.sha256`).  The checklist, STATUS.md and the other docs were not edited (the orchestrator's
   and the docs pass's, "For the records" above).

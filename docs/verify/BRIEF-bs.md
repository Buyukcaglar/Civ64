# Design note: unit BS (Birth screen-by-screen synchronisation)

Written 2026-10-15 by a read-only design agent of extension session E3, for the orchestrator. The
user's direction (2026-10-15 about 14:03 UTC, STATUS.md "User directions", item 3): "Perform Windows &
DOS Birth-* sync task before your game setup screens DOS graphics implementation task, I want to see and
verify them. Since Windows scenes does not have animation and DOS scenes are shorter in total, adapt
Windows scenes to DOS counterparts in terms of timing." Earlier (about 10:00 UTC) the user noticed the
DOS Birth is shorter; D4b4 (accepted 13:51 UTC) gives the core its Birth skip when the visible DOS Birth
ends first.

Nothing was built, run or edited for this note except scratch scripts in the session scratchpad that
parsed `claude/src/data/seg124_13D8.asm` and an existing harness log.

Evidence labels:

* **Windows docs**: `claude/docs` (graphics.md 2.10, 3.4, 4.12, 4.14; palette-pictures.md 2.4, 2.5,
  2.7, 4.5, 4.7; data-structures.md ResFile/ResEntry; platform.md start-up).
* **Windows data**: the Birth script 13D8:0000, parsed from `claude/src/data/seg124_13D8.asm` (78
  items and the terminator), and WINDOWS-INVENTORY 6.2 (`claude/port/docs/dos/`), which agrees.
* **core listing**: the translated core `claude/port/core` (read-only) and `claude/tools/showfunc.py`.
* **DOS docs**: `claude/port/docs/dos/*.md` (TIMING 5.5, CORRESPONDENCE row O7:17CF, FORMATS 3.5).
* **DOS listing (model)**: what `pdos_birth` computes. The DOS times below are read from the step log
  `claude/port/build/continue/dev/out-dos/timeline.log` (p4-birth, DOS visible, D4b4's development run
  of 2026-10-15; its Birth figures equal D4b3's `birth` run: t0 22,687,300 us, story end frame 10,463,
  hand-over frame 10,493). DOS frame = 17,024 PIT clocks = 14.2677 ms (draft C C.4.2).
* **port code**: `claude/port/present`, `claude/port/platform/w16` (read-only).
* **inferred**, **unknown**: as in the other notes.

## Decisions for the orchestrator

Each with a proposal. D1, D5, D6 and D7 shape what the user sees; the others are internal.

| # | Decision | Proposal |
|---|---|---|
| D1 | The approach | **(A): a presentation-side replica of the Windows Birth movie, driven by a time warp taken from the DOS Birth's own state.** The Windows view during Birth shows the replica's frame for the Windows movie frame that corresponds to the DOS scene of the moment. The replica is proved pixel-identical to the core by a "shadow mirror" (the replica stepped to the core's own frame and compared at the core's presents) before anything visible changes. (B) alternatives fail on timing (3.3); (C) is excluded (3.4). |
| D2 | How presentation reads the Windows pictures and strings | **A new read-only host service `host_data_read(name, buf, cap, &size)`** in `host.h`, the twin of `host_dos_read`: plain 8.3 names of the data directory's top level, compared ignoring ASCII case, whole file into presentation memory, called only by `present/bs`, once per file, before the emulation starts; no core path calls it (G-1 guard). Record it in DESIGN 12.10 as a host.h addition beyond prompt 5.1's two. Rejected: the core's `host_file_*` services (they belong to the virtual DOS drive; a shared id table or a logged open could reach the base trace; not worth proving), a w16q file query (a w16 change for no gain), the core's open .rsc handles (O4: w16 API, moves the emulated file position). |
| D3 | Where the Birth script comes from | **Read the 78 items from the core's image at the Birth start probe** (13D8:0000, `w16q_read`, read-only; the static fields never change, only the +1Ah state pointers do) and derive the warp table from them, with a validation (3.6). No transcribed frame table in the port. Picture ids and the STR# id come from the script. The only transcribed constant: SetCivFont 11E8:0B40 maps font id 3 to `g_civFonts` index 17 (CIVTIMES18), line height 18. |
| D4 | Text rendering | **The existing `w16q_draw_on`** (Ma, A-3b: w16's own DC-free `w16_text_draw` on a caller surface, an HFONT, no DC or handle) with the core's HFONT `g_civFonts[17]` (1420:5484 + 34, read with `w16q_read`), `W16Q_OP_COLOR` for the colour mapping and `w16q_font` for tmHeight. No new w16 query, unless the shadow mirror shows a width mismatch with `w16_GetTextExtent` (`w16_font_width`); then one read-only `w16q_text_extent` (a 12.10 row). |
| D5 | The warp (the user-visible timing) | **The table of 3.6**: every Windows scene change is moved to its DOS counterpart's instant. Windows text j appears when DOS line j is first drawn and is erased when DOS clears it; each Windows fade (40 steps) runs over its DOS fade's 48 frames (0.685 s; the last one over the post-Birth fade's 30 frames, 0.428 s); before DOS picture 1 shows, the Windows view holds frame 1000 (black); text #44 goes at the post-Birth fade's start. Resolution: the DOS frame grid. |
| D6 | When BS is active | **Whenever the DOS profile is registered and BS's assets loaded**, whatever profile is visible and whatever the switch history; the Windows Birth is native otherwise (4.4). civ64 default on (`civ64_present_defaults()`, as D4b4); harness `--birth-sync 0\|1`, default 0, so every existing expectation stays; exit 2 under CIV_OBSERVER 0. No menu item or civ64.cfg key now (add one only if the user asks). |
| D7 | The end with the Windows profile visible | **Extend D4b4's auto-continue: with BS active, the skip is produced at the DOS hand-over whichever profile is visible** (both views end then). The user's D4b4 words cover it ("when and if the short one is the current active one ... it automatically continues"): with BS the Windows Birth is the short one too. It is the same exception to I1/T3, checked the same way (P0 against the recorded input). Without it the Windows view would hold black for about 26 s, the quirk the user reported. List it for the user's check. |
| D8 | The player's skip | **T5 as now:** the key goes to the core; the core's skip (SetGameCursor ra 11E0:094E) or Birth end (DestroySequencePlayer ra 11E0:01E8) ends BS. BS holds its last frame until the core's Birth end, then the Windows view is native again (the core's setup). No Windows fade is added. In practice the core's skip, Birth end and setup fall on one instant (D4b3 `birth_skip`: all at 24,113,350 us). |
| D9 | Prompt 5.1 "The two hashes" | **Record an exception:** while BS is active the Windows profile's presented frame is BS's, not the RGB conversion of the virtual screen. `g_win` (`pwin_core`, S1's frame, which the map mirror and S1's relation check use) is not touched: it stays the RGB conversion at every core present. DESIGN 12.11 and FIDELITY get the exception; any check that compares the Windows presented frame with the core frame excludes the BS interval, which the harness logs. |
| D10 | Probes | **No new probe is required.** The shadow mirror uses the existing AdvanceMovie EN/EX, BirthMovieCallback EN, Create/Step/ApplyPaletteFade EN, DrawTextInRect EN/EX, GR_PicRead EN/EX, GR_PortDataToBitmap EN/EX (`present/obs_tables.c`). If BS2 needs BirthMovieCallback EX to attribute presents inside the skip poll, add it with the O5 records (DESIGN, TRACE "observer probe"). |
| D11 | Code placement | **A new directory `present/bs/`** (`pbs_assets`, `pbs_movie`, `pbs_view`), `build.cmd` gains it; BS reads the DOS Birth through one narrow accessor header in `present/dos` (`pdos_bsync.h`), with a registry/include-rule row (`gen/dos/registry.py`); D4b4's decision reads "BS active" through `pdos_profile.c`'s bridge, as it reads the visible profile. |
| D12 | Units, cycles and the user's check | **Four units BS1..BS4 (section 6).** Per the cycle rule of 14:09 UTC (`verify/BRIEF-cy.md`), each unit ends with the three-step cycle and the BS phase gate (after BS4) with the eight-step cycle; this supersedes "eight-step per unit" in this note's task. The user checks once, after BS4: BS3 alone would show the Windows view black for about 26 s at the end. BS1 shares `host_win32.c` with UX1: serialize them or give one owner. |

### Rulings (orchestrator, session E3, 2026-10-15 about 14:40 UTC; these bind BS1..BS4)

All twelve proposals adopted as written. In particular: D1 (A) with the shadow mirror proving the replica
before anything visible changes; D2 the new read-only `host_data_read` (DESIGN 12.10 row; never called on
a core path); D3 the script read from the core's image with validation, no transcribed frame table; D5
the warp as in 3.6; D6 BS active whenever the DOS profile is registered with its assets, civ64 on, the
harness `--birth-sync` default 0 so that every existing expectation stays; D7 the auto-continue extended
to "DOS visible or BS active" (the same I1/T3 exception, P0 against the recorded input, a pending user
check); D9 the 5.1 relation exception recorded, `g_win` untouched; D12 the units in order BS1..BS4, each
with the three-step cycle, the BS phase gate (eight steps) after BS4, then the user's check. BS1 runs after
UX1 (both touch `host_win32.c`): UX1 owns it first. If BS2's shadow mirror cannot reach pixel equality
for a scene, stop and report before BS3 (nothing visible may change on an unproven replica).

Added 18:10 UTC (orchestrator): BS1 and BS2 were staged together (`build/bs-stage/`, READY_TO_BUILD; the
private shadow mirror is equal on p4-birth, 1436 of 1436 presents, and on an EARTH start, 84 of 84), so
they land as one build-slot unit "BS12" with one three-step cycle after UX1. Test 1 runs under the
check-only option `--bs-check 1` (`--birth-sync` stays BS3's). civ64 opens the asset store only from BS3
(with `civ64_start.c` and `present.c`), not in BS12.

Added 19:20 UTC (orchestrator): BS3 and BS4 are staged too (`build/bs34-stage/`, READY_TO_BUILD; private
overlay tree + BS12 + UX1 + BS34 green in all three variants). Landing: UX1 first (its own three-step
cycle), then BS12 and BS34 together by the BS implementer, ending directly with the BS gate's eight-step
cycle (no separate three-step cycles for BS12 and BS34). Before the gate cycle, the implementer looks at
note 4 (the view advancing on every `present_tick_at` call): measure the harness cost with and without
`--birth-sync` on p4-birth and add an early-out if the cost is visible. D4-22 (accepted) is superseded by
BS-4 when the DOS data are found (the user's direction of 14:03); it still holds without them (BS-6).

## 1. The constraints

* **P0** (prompt 1; DESIGN 12.11): the core's rules, timing and state do not depend on presentation. The
  only accepted exception is D4b4's skip input (one Escape press and release). The core's Birth movie
  keeps its own pace: 60 Hz movie frames from TickCount, frames 1000..11500, about 175 s.
* **The Windows profile** normally presents the RGB conversion of the virtual screen (`profile_win.c`,
  `pwin_core`), at the core presents (`shows_core_frame` 1).
* **The DOS Birth is ahead** of the core's Birth for almost all of the 149.7 s (2.2): by 5 s at
  picture 3, 23.5 s at picture 6, up to 31 s at text 38. So the Windows view needs scene k before the
  core has drawn it, often before it has loaded its picture or fetched its text. It cannot replay the
  core's frames.
* **O4**: presentation never calls a w16 API, never runs ported functions (`fr_enter`, `VM_SITE`),
  never writes emulated memory, never posts input (except D4b4's release path), never reads the clock
  through a costly poll.

## 2. Facts

### 2.1 The Windows Birth (Windows data; Windows docs graphics.md 4.14)

RunIntroAndTitleMenu (11E0:0000) creates the Birth movie with BirthMovieCallback (11E0:091E),
calls `SeekSequence(movie, 1000)` (the T1 probe, ra **11E0:01AA**), then BeginWorldCreation (1108:01BC;
exit ra 11E0:01B2). World generation advances the movie through UpdateActiveAnimation 1098:0157 →
StepActiveSequence 10B0:0000. Afterwards the loop 11E0:01BD..01DB runs AdvanceMovie until the movie ends
or `g_movieSkipRequested` (13E0:001E) is set. The movie plays in dialog 148 (512x320, no controls;
WINDOWS-INVENTORY 4.2). endFrame = 11501, so the movie lasts 10,501 frames = 175.02 s nominal; each fade
start re-anchors the clock (graphics.md 4.14.2), and the p4-birth run measured 175.539 s (D4b3 record).

The 78 items (Windows data, parsed):

| Scene k | Picture | LoadPicture | SwapAndShow | FadeIn | Texts (STR# 139) | FadeOut |
|---|---|---|---|---|---|---|
| 1 | 128 (1024x320, source x offset 512: its right half) | 1000 | 1000 (p3 = 512) | 1000..1100 | #1..#3 at 1100, 1300, 1500 | 1700..1800 |
| 2 | 129 | 1100 | 1800 | 1800..1900 | #4..#6 at 1900, 2100, 2300 | 2500..2600 |
| 3 | 130 | 1900 | 2600 | 2600..2700 | #7..#14 at 2700..4100 | 4300..4400 |
| 4 | 131 | 2700 | 4400 | 4400..4500 | #15..#19 at 4500..5300 | 5500..5600 |
| 5 | 132 | 4500 | 5600 | 5600..5700 | #20..#25 at 5700..6700 | 6900..7000 |
| 6 | 133 | 5700 | 7000 | 7000..7100 | #26..#33 at 7100..8500 | 8700..8800 |
| 7 | 134 | 7100 | 8800 | 8800..8900 | #34..#43 at 8900..10700 | 10900..11000 |
| 8 | 135 | 8900 | 11000 | 11000..11100 | #44 at 11100 | 11400..11500 (final) |

* Texts start every 200 frames inside a scene and last 180 frames (#44: 280, 11100..11380). Each is
  item type 7, rect (0,280,512,310) on the **window**, flags 0x111 (centred; shadow in colour+1;
  0x100: on its first frame `AnimatePortPalette(window, hPalette, 224, 2)` loads the two text colours),
  colour p4 = 224, drawn as index 234 with the shadow 235 (`DrawTextInRect(text, &rect, p3, p4 + 10)`).
  On its last frame the text is erased by re-blitting the front port, offset by displayOffset
  (graphics.md 4.14.2 type 7).
* At 1100 also: LoadClut 130 (2 entries at 224, palette copy only) and SetFont 3/18 (TextFont 3 →
  SetCivFont 11E8:0B40 → index 17 = CIVTIMES18, line height 18 ≤ 24, so one shadow at (x+1, y+1);
  TextSize is a stub; core listing showfunc 11E8:0B40, 1098:0ED1).
* Fades: 40 steps, entries 0..223, ticksPerStep = (end − start)/40 = 2; the level is
  ⌊(f − start)/2⌋ (in) or 40 minus it (out), applied by ApplyPaletteFadeLevel (10A8:0228) with 16-bit
  products; full level at start + 80; currentStep > 40 returns "finished" (palette-pictures.md 4.5).
  So a fade is a pure function of the frame. Each scene change: FadeOut start → black at +80 →
  SwapAndShow at +100 (front/back swap, colours 0..223 copied into the palette copy, CopyPortToWindow)
  → FadeIn from black, full at +80.
* Pictures: 'CvPc' resources in `CivData0..4.rsc` (Mac resource files opened by OpenResFile 1190:0000,
  five calls; a later file's resource is found first, data-structures.md). Loaded by GR_PicRead
  (10B8:079D) → LoadGifPicture (10B8:11BC) → PicDecompress (10B8:158C): pixel = LZW literal +
  colorBase + 10, colour table entries base..base+n−1 from the file, others black (palette-pictures.md
  4.7). Picture 128 is 1024x320 with 153 colours; 129..135 are 512x320 with 224 colours
  (WINDOWS-INVENTORY row 93, 94).
* Text: GetIndString(139, j) from 'STR#' 139 (resource).
* No callback item, no dissolve: the script draws no random number (graphics.md 4.14.3). The callback
  polls the skip on frames with `frame % 30 == 0` (D4b4 record).

### 2.2 The DOS Birth (DOS docs TIMING 5.5; DOS listing (model))

O7:17CF, a step function called from world generation and the loop O7:05A0. STORY.TXT is read one line
per event: 8 picture markers and 44 text lines, then the end of file (53 events, D4b3). A text event:
dim the previous line 5 frames (only while fewer than 40 lines were shown), read the line, clear the
strip (after the first picture; at the read), pause 10, draw in colour 3, wait 5, colour 11. A picture
event: the marker line drawn as a text, then fade to black 8 steps (48 frames), show BIRTHn.PIC, fade in
to BIRTHn.PAL 8 steps (48 frames), colour cycling on. Due ticks: clamp(T[m], now + 45·w, 32767) on the
sound tick. End: wait(180), then the post-Birth transition with its 5-step fade (30 frames) and the
hand-over R:01A8:087C. The times are in the table of 2.3.

### 2.3 Correspondence

**It is one-to-one by order** for pictures and text lines: picture k ↔ BIRTHk.PIC (k = 1..8 ↔ CvPc
128..135), text j ↔ STORY.TXT text line j ↔ STR# 139 #j, and the counts per picture are equal on both
sides: 3, 3, 8, 5, 6, 8, 10, 1 (CORRESPONDENCE row O7:17CF, "inferred (counts per picture)";
confirmed against the parsed script and the DOS step log). The other item kinds do not correspond
one-to-one:

| Kind | Windows | DOS | In BS |
|---|---|---|---|
| Picture load | LoadPicture one scene ahead (type 6, back port) | at the picture event (O7:1A19) | none (BS decodes all eight before the run) |
| Picture show | SwapAndShow (type 9) | show_picture O7:1A59 (page 2 to the screen) | anchor |
| Fade in | FadeIn 40 steps / 100 frames, god entries 0..223 | 8 steps / 48 frames to BIRTHn.PAL (O7:1A6B..1A93) | the Windows ramp over the DOS fade |
| Fade out | FadeOut 40 / 100 (7 between scenes, 1 final) | 8 / 48 to black (O7:1A39); final: post-Birth fade 5 steps / 30 frames (R:01A8:0840) | the Windows ramp over the DOS fade |
| Text draw | Text item's first frame | O7:196B (colour 3), O7:198C (colour 11) | anchor at O7:196B |
| Text erase | the item's last frame | strip clear O7:194A at the next event; line 44: none until the post-Birth fade | anchor |
| Colours, font, position | LoadClut 130 at 224, CIVTIMES18, rect (0,280,512,310) centred, shadow | font 7 at (160,160), colours 3 then 11, strip (0,160,320,8) | each profile its own |
| DOS only | - | the dim step, the marker line, colour cycling (BIRTH_CYCLE), tune restart, BUILDING blink, page copies (SP299, SP257) | none (no Windows counterpart) |
| Windows only | the 20-frame gaps, the black hold of 20 frames before each swap, the one-ahead loads, the 512 offset of picture 1 | - | kept inside the replica |
| Clears, Blackout, FillRect, Callback, Scroll | none in the Birth script | - | - |

**Times** (DOS: frames from t0 and seconds after t0, from the step log; Windows: frames and
(f − 1000)/60 s, nominal, before the re-anchoring drift of up to +0.52 s; "ahead" = how much earlier
DOS shows the scene):

| DOS event | DOS frames | DOS s | Windows item | Windows frames | Windows s | DOS ahead s |
|---|---|---|---|---|---|---|
| P1 fade-out / show / fade-in end | 20 / 69 / 117 | 0.29 / 0.98 / 1.67 | SwapAndShow 128, FadeIn | 1000 / 1080 (full) | 0.00 / 1.33 | -0.98 |
| T1 drawn / cleared | 132 / 365 | 1.88 / 5.21 | #1 | 1100..1280 | 1.67..4.67 | -0.22 |
| T2 | 375 / 533 | 5.35 / 7.60 | #2 | 1300..1480 | 5.00..8.00 | -0.35 |
| T3 | 543 / 869 | 7.75 / 12.40 | #3 | 1500..1680 | 8.33..11.33 | 0.59 |
| P2 | 884 / 932 / 980 | 12.61 / 13.30 / 13.98 | FadeOut, SwapAndShow 129, FadeIn | 1700 / 1800 / 1880 | 11.67 / 13.33 / 14.67 | 0.04 |
| T4 | 995 / 1142 | 14.20 / 16.29 | #4 | 1900..2080 | 15.00..18.00 | 0.80 |
| T5 | 1152 / 1300 | 16.44 / 18.55 | #5 | 2100..2280 | 18.33..21.33 | 1.90 |
| T6 | 1310 / 1457 | 18.69 / 20.79 | #6 | 2300..2480 | 21.67..24.67 | 2.98 |
| P3 | 1472 / 1520 / 1568 | 21.00 / 21.69 / 22.37 | FadeOut, SwapAndShow 130, FadeIn | 2500 / 2600 / 2680 | 25.00 / 26.67 / 28.00 | 4.98 |
| T7 | 1583 / 1678 | 22.59 / 23.94 | #7 | 2700..2880 | 28.33..31.33 | 5.75 |
| T8 | 1688 / 1835 | 24.08 / 26.18 | #8 | 2900..3080 | 31.67..34.67 | 7.58 |
| T9 | 1845 / 2045 | 26.32 / 29.18 | #9 | 3100..3280 | 35.00..38.00 | 8.68 |
| T10 | 2055 / 2325 | 29.32 / 33.17 | #10 | 3300..3480 | 38.33..41.33 | 9.01 |
| T11 | 2335 / 2493 | 33.32 / 35.57 | #11 | 3500..3680 | 41.67..44.67 | 8.35 |
| T12 | 2503 / 2773 | 35.71 / 39.56 | #12 | 3700..3880 | 45.00..48.00 | 9.29 |
| T13 | 2783 / 2931 | 39.71 / 41.82 | #13 | 3900..4080 | 48.33..51.33 | 8.63 |
| T14 | 2941 / 3053 | 41.96 / 43.56 | #14 | 4100..4280 | 51.67..54.67 | 9.71 |
| P4 | 3068 / 3116 / 3164 | 43.77 / 44.46 / 45.14 | FadeOut, SwapAndShow 131, FadeIn | 4300 / 4400 / 4480 | 55.00 / 56.67 / 58.00 | 12.21 |
| T15 | 3179 / 3326 | 45.36 / 47.45 | #15 | 4500..4680 | 58.33..61.33 | 12.98 |
| T16 | 3336 / 3501 | 47.60 / 49.95 | #16 | 4700..4880 | 61.67..64.67 | 14.07 |
| T17 | 3511 / 3837 | 50.09 / 54.75 | #17 | 4900..5080 | 65.00..68.00 | 14.91 |
| T18 | 3847 / 4173 | 54.89 / 59.54 | #18 | 5100..5280 | 68.33..71.33 | 13.45 |
| T19 | 4183 / 4397 | 59.68 / 62.74 | #19 | 5300..5480 | 71.67..74.67 | 11.98 |
| P5 | 4412 / 4460 / 4508 | 62.95 / 63.63 / 64.32 | FadeOut, SwapAndShow 132, FadeIn | 5500 / 5600 / 5680 | 75.00 / 76.67 / 78.00 | 13.03 |
| T20 | 4523 / 4670 | 64.53 / 66.63 | #20 | 5700..5880 | 78.33..81.33 | 13.80 |
| T21 | 4680 / 4828 | 66.77 / 68.88 | #21 | 5900..6080 | 81.67..84.67 | 14.89 |
| T22 | 4838 / 4933 | 69.03 / 70.38 | #22 | 6100..6280 | 85.00..88.00 | 15.97 |
| T23 | 4943 / 5038 | 70.53 / 71.88 | #23 | 6300..6480 | 88.33..91.33 | 17.81 |
| T24 | 5048 / 5195 | 72.02 / 74.12 | #24 | 6500..6680 | 91.67..94.67 | 19.64 |
| T25 | 5205 / 5300 | 74.26 / 75.62 | #25 | 6700..6880 | 95.00..98.00 | 20.74 |
| P6 | 5315 / 5363 / 5411 | 75.83 / 76.52 / 77.20 | FadeOut, SwapAndShow 133, FadeIn | 6900 / 7000 / 7080 | 98.33 / 100.00 / 101.33 | 23.48 |
| T26 | 5426 / 5573 | 77.42 / 79.51 | #26 | 7100..7280 | 101.67..104.67 | 24.25 |
| T27 | 5583 / 5741 | 79.66 / 81.91 | #27 | 7300..7480 | 105.00..108.00 | 25.34 |
| T28 | 5751 / 5965 | 82.05 / 85.11 | #28 | 7500..7680 | 108.33..111.33 | 26.28 |
| T29 | 5975 / 6189 | 85.25 / 88.30 | #29 | 7700..7880 | 111.67..114.67 | 26.42 |
| T30 | 6199 / 6413 | 88.45 / 91.50 | #30 | 7900..8080 | 115.00..118.00 | 26.55 |
| T31 | 6423 / 6637 | 91.64 / 94.69 | #31 | 8100..8280 | 118.33..121.33 | 26.69 |
| T32 | 6647 / 6861 | 94.84 / 97.89 | #32 | 8300..8480 | 121.67..124.67 | 26.83 |
| T33 | 6871 / 7141 | 98.03 / 101.89 | #33 | 8500..8680 | 125.00..128.00 | 26.97 |
| P7 | 7156 / 7204 / 7252 | 102.10 / 102.78 / 103.47 | FadeOut, SwapAndShow 134, FadeIn | 8700 / 8800 / 8880 | 128.33 / 130.00 / 131.33 | 27.22 |
| T34 | 7267 / 7414 | 103.68 / 105.78 | #34 | 8900..9080 | 131.67..134.67 | 27.98 |
| T35 | 7424 / 7572 | 105.92 / 108.04 | #35 | 9100..9280 | 135.00..138.00 | 29.08 |
| T36 | 7582 / 7757 | 108.18 / 110.67 | #36 | 9300..9480 | 138.33..141.33 | 30.16 |
| T37 | 7767 / 7981 | 110.82 / 113.87 | #37 | 9500..9680 | 141.67..144.67 | 30.85 |
| T38 | 7991 / 8317 | 114.01 / 118.66 | #38 | 9700..9880 | 145.00..148.00 | 30.99 |
| T39 | 8327 / 8653 | 118.81 / 123.46 | #39 | 9900..10080 | 148.33..151.33 | 29.53 |
| T40 | 8663 / 8984 | 123.60 / 128.18 | #40 | 10100..10280 | 151.67..154.67 | 28.07 |
| T41 | 8994 / 9320 | 128.32 / 132.98 | #41 | 10300..10480 | 155.00..158.00 | 26.68 |
| T42 | 9330 / 9544 | 133.12 / 136.17 | #42 | 10500..10680 | 158.33..161.33 | 25.22 |
| T43 | 9554 / 10067 | 136.31 / 143.63 | #43 | 10700..10880 | 161.67..164.67 | 25.35 |
| P8 | 10082 / 10130 / 10178 | 143.85 / 144.53 / 145.22 | FadeOut, SwapAndShow 135, FadeIn | 10900 / 11000 / 11080 | 165.00 / 166.67 / 168.00 | 22.13 |
| T44 drawn / post fade | 10188 / 10463 | 145.36 / 149.28 | #44 | 11100..11380 | 168.33..173.00 | 22.97 |
| EOF / story end / post fade / hand-over | 10283 / 10463 / 10463..10493 / 10493 | 146.72 / 149.28 / ..149.71 / 149.71 | final FadeOut, end | 11400..11480 / 11501 | 173.33..174.67 / 175.02 | 25.31 |

From line 41 on, DOS skips the dim step, so a line is drawn 10 frames after its event and cleared at the
next event itself (T40..T43). The DOS times depend on STORY.TXT's line lengths and BIRTH_SCHEDULE; BS
must take them from `pdos_birth` at run time, never from this table.

## 3. Approach

### 3.1 What the Windows view needs

At virtual time t during Birth the Windows view must show "the Windows Birth as it looks at the
Windows movie frame f = W(t)", where W maps the DOS Birth's state at t to the corresponding Windows
frame (3.6). Because DOS is ahead, f is usually far beyond the core's own frame: up to about 1,860
frames (31 s) at text 38. The core has then neither loaded the picture (it loads one scene ahead)
nor fetched the string (GetIndString at the draw).

The movie state after frame f, S(f), is a pure function of f: AdvanceMovie runs every frame in order
(catch-up included), fades are frame-based, no item draws a random number, and the items before f leave
no state that depends on timing (the re-anchoring changes only when a frame runs, not what it does;
graphics.md 4.14.2, palette-pictures.md 4.5). So a replica that runs the same items over the same inputs
reproduces S(f) for any f, ahead of the core, and the same replica stepped to the core's own frame must
equal the core's screen. That second fact is the proof (the shadow mirror, 5.2).

### 3.2 (A), chosen: a presentation-side replica on a DOS-derived warp

1. **Assets, before the emulation starts** (`present/bs/pbs_assets`): `host_data_read` reads
   `CivData0..4.rsc` (D2). A Mac resource-file parser (header, map, type list, reference lists; data at
   dataOffset + entry offset + 4, as RestoMem 1190:0FDA reads it) finds STR# 139 and CvPc 128..135,
   searching the files in the core's precedence (the last opened first; validated in BS1's test). A CvPc
   decoder reimplements LoadGifPicture and PicDecompress for valid streams: big-endian width and height,
   min code size, colour count − 1, RGB triplets, colour table with base 0 (entries 0..n−1 from the file,
   the rest black, clamp to 236, flags as on palette devices), GIF LZW (clear, end, width growth to 12,
   KwKwK, sub-blocks LSB first), pixel = literal + 10. Refusals (truncated stream, code > next, output
   past width·height, a table that would overflow without a clear) switch BS off with a presentation
   diagnostic `bs_assets`; they never fault. The eight decoded pictures take about 1.5 MB.
   The ids to load come from the script; the script is read at t0 (D3), so the loader either reads all
   CvPc ids 128..135 named in WINDOWS-INVENTORY 6.2 and validates them against the script at t0, or keeps
   the raw resource bytes and decodes at t0's first tick (the decode is presentation memory only; under
   `--timing host` its host time costs virtual time, T6). Proposal: decode before the run, validate at t0.
2. **The replica** (`present/bs/pbs_movie`): the item semantics of types 2, 3, 4, 5, 6, 7 and 9,
   transcribed from the translated core, not from the docs: AdvanceMovie 10B0:0461 (`core/
   seg023_10B0_p1.c` cases 2, 3, 4, 6, 9, 7), CreatePaletteFade/StepPaletteFadeIn/Out/
   ApplyPaletteFadeLevel (10A8:0000/00FC/018E/0228), SetGodPaletteEntries 1090:0376 (the 236 clamp),
   CopyPaletteEntries 1098:201D, AnimatePortPalette 1200:00A8, CopyPortToWindow (the source rectangle
   offset by displayOffset, as at 10B0:1080..10D7), GR_PortDataToBitmap 10B8:0E36 (what the core's
   bitmap holds for a picture's raw pixels) and DrawTextInRect 1098:0ED1. State: front and back
   "ports" (indexed pixels, bounds, colour table), the movie palette copy, the god palette (236
   entries), the window surface (the 512x320 client, indices), displayOffset, the fade states and the
   last completed frame. `pbs_movie_run_to(f)` runs frames forward only, in item-list order per frame,
   exactly as AdvanceMovie's catch-up does. Inputs other than the assets: the script and the god palette
   at t0 (`w16q_palette` of `g_hGodPalette`), the HFONT, the text colour mapping, the client's screen
   rectangle (from the movie record's window, `w16q_wnd`). An unsupported item type, a picture other than
   those loaded or a validation failure switches BS off.
3. **Text** (D4): x = left + (right − left − width)/2 and y = top + (bottom − top − tmHeight)/2 (signed,
   truncating, 1098:0F67..0FAF); the shadow at (x+1, y+1) in index 235, then the text at (x, y) in 234,
   transparent, TA_LEFT|TA_TOP, clipped to the client; through `w16q_draw_on` (TEXTOUT) on the replica's
   window surface. The colours go through `W16Q_OP_COLOR` with the colorref SetForeColor (1098:0E0B)
   would set and the window DC's palette (`g_hGodPalette`). The font is `g_civFonts[17]`.
4. **The warp and the view** (`present/bs/pbs_view`): at every tick BS reads the DOS Birth's sync state
   (`pdos_bsync.h`, 3.6), computes f = W(t), runs the replica to f and composes the Windows BS frame:
   the live virtual screen's indices (`w16q_screen`) with the movie client replaced by the replica's
   window surface, converted with the live system palette (`w16q_system_rgb`) whose entries 10..233
   (god 0..223) come from the replica, and 234..235 too once the replica has run its first text item
   (before that they are unused on screen). Damage: the client when the replica's pixels changed, the
   whole frame when its palette changed, the core's changed rectangle outside the client. The frame is a
   function of the event stream and the virtual time at the tick (T6).
5. **The Windows profile** keeps `g_win` (`pwin_core`) as now. While BS is active the profile's
   `frame`/`peek` return BS's frame and `shows_core_frame` returns 0, so the tick shows it (present.c
   step 7) and the core presents do not; the transitions in and out redraw the whole client (as a
   switch does, `show_all`). Both 640x480, so no relayout (F105's game screen comes later).
6. **Tick order.** present.c step 2 advances the Windows profile before the DOS profile. BS must read the
   DOS state after DOS advanced at the same tick, so BS runs at a new step 2b after the loop
   (`pbs_view_advance(now)`), visible or not (O6, T2).

### 3.3 (B) cheaper alternatives, evaluated

* **B1: take the pictures the core has already loaded.** The core loads picture k+1 into its back port
  one scene ahead; a probe at GR_PicRead's exit could copy the decoded pixels and table with
  `w16q_block` (read-only, allowed by O3). Against the DOS show times (2.3), at nominal Windows times:
  129 loaded at 1.67 s (needed 13.30 s), 130 at 15.00 (21.69), 131 at 28.33 (44.46), 132 at 58.33
  (63.63), **133 at 78.33 (needed 76.52: 1.8 s late, 2.5 s before its fade-out start)**, 134 at 101.67
  (102.78: 1.1 s margin, less with the re-anchoring drift), 135 at 131.67 (144.53). It fails at
  picture 6 and is marginal at picture 7. **Rejected as the source; kept as the decoder's oracle**
  (5.2 test 1).
* **B2: take the strings from the core.** GetIndString runs only when the core draws text j, and DOS
  shows text 3..44 earlier than the core (up to 31 s). GetResource returns a fresh copy each call
  (palette-pictures.md 4.7), so no resident STR# 139 exists to read early. **Rejected**: a resource
  read path is needed for the text in any case, and then the pictures come with it.
* **B3: read the bytes through the core's resource map** (the ResFile/ResEntry lists in emulated
  memory give each resource's file, offset and length). It saves the map parser but still needs a host
  file read, and OpenResFile frees its whole-file image (data-structures.md g_resFileImage), so no
  bytes are resident. **Rejected as the source; usable as a cross-check** of BS's precedence (BS1).
* **B4: hold each Windows scene until the core has its data.** Scenes would lag DOS by up to 31 s for
  text and 2 s for picture 6: not "adapted to DOS timing". **Rejected.**
* **B5: pre-render from an earlier run or a second core.** Not deterministic on the first run, and a
  second core breaks O4. **Rejected.**

### 3.4 (C) not acceptable

* Changing the core's movie pace or clock (a faster TickCount, SeekSequence calls, skipped frames, a
  changed script in emulated memory): P0.
* Running ported game functions from presentation code (AdvanceMovie, PicDecompress, DrawTextInRect
  translations): O4 (`fr_enter`, `VM_SITE`, emulated memory).
* Writing core state, calling w16 APIs on the emulation's DCs or files, allocating emulated handles.
* Any input beyond D4b4's release path (D7 extends only its visibility condition).
* Slowing the DOS Birth to the Windows pace: the user asked for the opposite.

### 3.5 Windows data and the 16-colour and monochrome paths

BS assumes the 256-colour path. At t0 it reads `g_is16ColorDisplay` (1420:17A8), `g_noPaletteDevice`
and `g_monochromeMode` (12D8:28FC) and stays off unless all three are 0 (in civ64 they are; on a
16-colour display GR_PicRead dithers and the replica would not match).

### 3.6 The warp

**The DOS side.** `pdos_birth` gains a small record of sync marks, set as its program passes the
points below (frames on its own grid from t0), read through `pdos_bsync.h`:

| Phase | Set at | Fields |
|---|---|---|
| PRE | t0 | - |
| FADE_OUT(k) | O7:1A39 (fade to black before BIRTHk; k ≥ 2) | start frame, length 48 |
| FADE_IN(k) | O7:1A59 show_picture, then O7:1A93 | start frame, length 48 |
| PIC(k) | the fade-in's end | - |
| TEXT(j) | O7:196B for a text line (not for a marker) | the line number j |
| CLEAR(j) | O7:194A, the strip clear of the next event | j |
| BUILDING | state ≥ 2 with the world running (C.8.6) | - |
| POST_FADE | R:01A8:0840 after the story (not after an abandon) | start frame, length 30 |
| SETUP | R:01A8:087C (`pdos_birth_at_setup`) | - |
| ABANDONED | the core's skip or Birth end first (`PDOS_SEQ_FX_FADE`) | - |

**The Windows side.** From the script, validated at t0: SW[k] the eight SwapAndShow frames in order;
each SW[k] has a FadeIn starting there; FO[k] (k = 1..7) the FadeOut before SW[k+1], with FO[k] + 100 =
SW[k+1]; FO[8] the final FadeOut; TS[j], TE[j] the 44 Text items with p1 = 139, p2 = j, in start
order; all fades 40 steps over 100 frames (tps 2); item types within {2, 3, 4, 5, 6, 7, 9}. Any
mismatch: BS off (`bs_script`).

**W** (n = DOS frames since the phase's start, N its length):

| DOS phase | Windows frame f |
|---|---|
| PRE | SW[1] = 1000 (picture 128 swapped in, FadeIn level 0: black) |
| FADE_IN(k) | SW[k] + 2·⌊40·n/N⌋ (FadeIn level ⌊40n/N⌋; full at n = N) |
| PIC(k) | SW[k] + 99 (the picture, no text yet) |
| TEXT(j) (includes DOS's dim step and EOF's wait(180) for j = 44) | TS[j] |
| CLEAR(j) | TE[j] |
| FADE_OUT(k) | FO[k−1] + 2·⌊40·n/N⌋ (level 40 − ⌊40n/N⌋; black at n = N) |
| BUILDING (practically never, C.8.6) | TE[44] |
| POST_FADE | FO[8] + 2·⌊40·n/N⌋ (passes TE[44] = 11380 at its first frame) |
| SETUP | 11501: BS's Birth has ended (black) |
| ABANDONED | f unchanged (hold, D8) |

W is non-decreasing (TS[j] < TE[j] < TS[j+1]; TE of a scene's last text < FO; FO + 100 = SW), so the
replica only runs forward. At each jump the replica runs every frame in between, so items without a
visible effect (LoadPicture, LoadClut, SetFont, the palette loads) keep the order of the core. n is the
DOS frame at the tick (the DOS clock of C.4.2), so the Windows view changes only at DOS frame boundaries;
the result is independent of the tick partition.

Effects the user will see in the Windows view (all from the table): each picture fades out and in
within 0.69 s (native 1.33 s plus a 0.33 s black hold); captions last as long as their DOS lines
(1.4 s to 7.3 s; native 3.0 s); the black screen before picture 1 lasts 0.98 s; caption #44 goes when
the final fade starts; the Birth ends at 149.7 s instead of about 175.5 s.

## 4. The end, the skip, pauses and switching

### 4.1 The end

* With BS active, both views reach the end at the DOS hand-over (frame 10,493, 149.71 s after t0 in
  p4-birth). BS then holds black (f = 11501) until the core leaves Birth.
* **Auto-continue (D7).** `pdos_seq_autocontinue_release` produces the Escape pair when its other
  conditions hold (setting on, nothing produced yet, room for two events, the core in its skip-able
  Birth with the world done, no player press since Birth's start, DOS at R:01A8:087C) and **the DOS
  profile is visible or BS is active**. With BS active the visible profile no longer matters. A switch
  at any time changes nothing. The proof that the skip consumes the events and nothing reaches the setup
  is D4b4's (record, "The produced input") and is unchanged.
* After the core's Birth end (DestroySequencePlayer ra 11E0:01E8) the Windows view returns to the
  virtual screen (whole redraw). The core polls every 30 movie frames, so the black hold after the DOS
  hand-over is at most about 0.5 s (D4b4: 13 ms in `dos`, 431 ms in `to_dos`).
* With the harness default (`--birth-continue 0`) BS holds black until the core's movie ends (the
  same as D4b3's T4 hold for DOS).

### 4.2 The player's skip (T5)

Keys and clicks pass to the core as now. The core takes the skip at its next poll once the world is
done. At the core's skip probe or Birth end, BS ends (D8): it holds its frame until the core's Birth end,
then shows the virtual screen. The DOS view is abandoned with its post-Birth fade as in D4b3. D4b4's
rule "nothing added after a player's press" stays. A skip before the world is done waits for the world
(the core's rule); BS keeps playing meanwhile.

### 4.3 World generation (T6)

BS frames are made only at presentation ticks, as DOS frames are; during the CPU-bound world generation
the ticks come from the generator's pumps and clock queries. In p4-birth the world is done 1.07 s after
t0, inside BS's PRE phase (black until 0.98 s) and the first fade, so the pause is hardly visible. Under
`--timing host` BS's per-tick work costs virtual time (FIDELITY, as for DOS).

### 4.4 When BS is not active

BS starts at the core's Birth start probe (SeekSequence ra 11E0:01AA) only when all hold:

* the DOS profile is registered (`present_profiles_init` registers it only when its asset store is open,
  `pdos_assets_status() == PDOS_OK`; profile.h). **No DOS data → no DOS timeline → the Windows Birth is
  native and nothing is produced with Windows visible (D4b4 as now);**
* BS's assets loaded and the script validated;
* the setting is on (civ64 default; harness `--birth-sync 1`);
* the 256-colour path (3.5);
* the DOS Birth started at the same probe (it always does when DOS is registered).

A failure at any point before the first BS frame leaves the Windows Birth native; a failure after it
(none expected; only a bad script or asset could do it, and those are checked at t0) hands back to
native at the next tick with a diagnostic. All three Birth entries (title choices 0, 2 EARTH, 3
Customize) use the same script; BS applies to each.

### 4.5 Switching (T2)

BS advances at every tick whether the Windows profile is visible or not (step 2b). A switch at virtual
time t shows the other view at the same t: DOS shows DOS scene k, line j; Windows shows Windows scene k,
caption j. A switch never resets or restarts either view.

## 5. Effects on tests and expectations

### 5.1 Existing expectations

* **G-1** (core outputs, observer against CIV_OBSERVER=0): unaffected. BS adds no core input and
  `--birth-sync` is refused under CIV_OBSERVER 0 (exit 2, as `--birth-continue`).
* **ext_p0** (V0..V7): unchanged; the harness default is `--birth-sync 0`. P0 with BS is shown by new
  runs (5.2).
* **ext_frames, ext_timeline goldens (`birth`, `birth_switch`, `birth_skip`), ext_continue, ext_adapt,
  ext_mirror, gate3b, the P4 scenarios**: unchanged (BS off by default).
* **Prompt 5.1 "The two hashes"** (D9): `g_win` stays the RGB conversion at every core present, so S1's
  relation check (DESIGN 12.11 "Tests") is unchanged. The Windows presented frame differs only inside
  the BS interval, which the harness logs (`bs start`, `bs end` in presentation-diag or timeline.log).
* **The user's accepted D4b4 behaviour** (DOS visible) is unchanged.

### 5.2 New tests

1. **Decoder and asset equality** (BS1; harness, p4-birth to the core's Birth end, `--birth-sync 1`):
   at each GR_PicRead exit for 128..135 (the LoadPicture items) BS's decoded pixels and colour table equal
   the core's port (`w16q_block` of hRawBits and of the colour table), and after GR_PortDataToBitmap the
   bitmap bits (`w16q_bitmap`); the 44 strings equal the text bytes at the core's DrawTextInRect entries.
   Portable `test_pbs_assets.c`: synthetic .rsc and CvPc vectors (no game bytes in the repository):
   precedence across files, clear codes, KwKwK, width growth to 12, sub-block boundaries; truncation and
   corruption refused cleanly (ASan in the final pass).
2. **Shadow mirror** (BS2; Checked harness `--bs-mirror 1`): the replica, stepped to the core's own
   progress, is compared with the virtual screen's client area and the system palette at every core
   present whose state it can attribute: presents at AdvanceMovie's entry TickCount (state S(frame − 1)),
   at the clock re-anchoring after a fade start, and the forced presents of AnimatePalette inside
   ApplyPaletteFadeLevel on frames whose only active item is that fade. Unattributed presents (for
   example inside the skip poll's PeekMessage) are counted, not compared. Expectation: every compared
   present equal; coverage reported per picture, per text and per fade level (all 8, all 44, levels
   0..40 of each fade the core presents). The full RGB frame is also compared (BS's composition at the
   core's frame against `g_win`).
3. **Warp** (BS3; portable `test_pbs_view.c` on synthetic DOS sync states): every table row of 3.6,
   monotonicity, jumps run the frames in between, fade levels at n = 0, 1, N/2, N, the end, the hold
   after an abandon, BS off on each validation failure.
4. **Timing** (BS3; `ext_timeline.py` run `bs`, p4-birth, Windows visible, `--birth-sync 1`): at each
   DOS sync point of the run (8 shows, 44 draws, 43 clears, the post fade, the hand-over) the Windows
   presented frame equals the shadow replica's frame for the table's f; each caption j is visible in the
   Windows view exactly from DOS line j's draw to its clear; `bgolden`-style model goldens of the Windows
   BS frame at listed times (hashes only, label "Windows data + DOS listing (model)"); partition
   independence (BS at 12 random tick partitions gives equal frames at equal times, as C.15.1 item 4).
5. **Switching** (BS3; run `bs_switch`, `--switch-every 997`): the Windows samples equal `bs`'s, the DOS
   samples equal `birth`'s, the core outputs equal.
6. **Skip** (BS3; run `bs_skip`, a player's key at 30 s): BS holds from the core's skip to its Birth end,
   then the Windows view is the virtual screen; the core outputs equal the same run without BS.
7. **P0 with BS** (BS3; ext_p0 variation V8 on the scenarios that pass Birth, `--birth-sync 1` with and
   without `--switch-every 997`): every checkpoint, core frame hash and events.log equal V0.
8. **The Windows end** (BS4; `ext_continue.py`): `bs_win` (Windows visible, BS on, continue on: one
   autocontinue at the hand-over, the setup follows), `bs_win_replay` (Windows only, the recorded
   events at the same sync: identical in every core output, P0 against the recorded input), `bs_off_win`
   (BS off, Windows visible: nothing, as D4b4's `win`), `nodos` (no DOS data: native Windows Birth, no
   BS frame, nothing produced). `test_pdos_seq` gains the BS-active vectors.

## 6. Units

Each unit: exclusive file ownership, the three-step cycle at its end (D12; the eight-step cycle at the BS
gate after BS4), a record `ext-BSn-record.md`. Sizes are estimates including the cycle.

| Unit | Content | Files (new or changed) | User check |
|---|---|---|---|
| **BS1 Windows Birth assets** (about 1.5 h) | `host_data_read` with both back ends; the .rsc parser, the STR# reader and the CvPc decoder; loading before the emulation when the DOS profile is registered; test 1 | `platform/w16/host.h`, `platform/win32/host_win32.c`, `tests/headless/host_headless.c`, `present/bs/pbs_assets.[ch]`, `tests/test_pbs_assets.c`, `tests/harness/ext_bs.py` (new, `assets`), `build.cmd`, `test.cmd`, `gen/dos/registry.py` rows if needed | none (nothing visible changes) |
| **BS2 Replica and shadow mirror** (about 2 h) | `pbs_movie` (items 2..7, 9; text; palette; CopyPortToWindow and the bitmap rules); `--bs-mirror`; test 2 over p4-birth and one EARTH start | `present/bs/pbs_movie.[ch]`, `tests/test_pbs_movie.c`, `tests/headless` (option, log lines), `tests/harness/ext_bs.py` (`mirror`) | none (shadow only) |
| **BS3 The warp and the Windows view** (about 2 h) | `pdos_bsync.h` and the marks in `pdos_birth`; `pbs_view` (warp, composition, start, end, hold, hand-back); present.c step 2b; profile_win.c frame switching; `--birth-sync`; civ64 default on; tests 3..7 | `present/dos/pdos_birth.[ch]`, `present/dos/pdos_bsync.h`, `present/bs/pbs_view.[ch]`, `present/present.c`, `present/profile_win.c`, `win64/civ64_start.c`, `tests/test_pbs_view.c`, `tests/harness/ext_timeline.py`, `ext-timeline-golden.txt`, `tests/harness/ext_p0.py` | (optional preview only: the end still holds black with Windows visible) |
| **BS4 The Windows end and the records** (about 1.5 h) | D7 in `pdos_seq_autocontinue_release` through `pdos_profile.c`; test 8; DESIGN 12.8 "Added in BS", 12.10 (host_data_read), 12.11 (5.1 exception, D4b4 exception extended), FIDELITY, RUNNING (`--birth-sync`, `--bs-mirror`), FEATURES, checklist BS-1..; then the BS gate (eight steps) | `present/dos/pdos_seq.c`, `present/dos/pdos_profile.c`, `tests/test_pdos_seq.c`, `tests/harness/ext_continue.py`, the docs (or a docs agent) | **yes** (below) |

**What the user checks after BS4** (a Checked or Release copy, DOS data located):

* BS-1: in the Windows graphics the Birth pictures change at the same moments as in the DOS graphics
  (switch with Ctrl+Shift+Backspace or the menu to compare), and each Windows caption appears and goes
  with the corresponding DOS line.
* BS-2: switching at any moment shows the same picture and line in the other graphics, without restart.
* BS-3: the Windows fades are short, like the DOS ones; the pictures and captions themselves look as in
  the native Windows Birth.
* BS-4: with the Windows graphics shown, the setup follows the Birth's end (about 150 s) without a black
  wait; the same with DOS shown (D4b4).
* BS-5: a key during the Birth (after the world is built) goes to the setup in both graphics.
* BS-6: without DOS data the Windows Birth plays as before (native timing).

## 7. Risks

1. **Pixel exactness of the replica**: CopyPortToWindow with picture 128's 512 offset (the source
   rectangle is the port's bounds offset by (512, 0), that is (512,0)-(1536,320), against a 512-wide
   destination; a recorded finding, "V7", is marked at 10B0:1023 in this item's translation),
   GR_PortDataToBitmap's conversion of raw pixels to the window's bits, SetForeColor's colorref, the text
   measure. Mitigation: BS2's shadow mirror before anything is visible; BS ships only when it is equal at
   every compared present.
2. **Presents inside a frame** (AnimatePalette forces a present inside SetGodPaletteEntries,
   `gdi_pal.c` 316): attribution in the mirror needs care; the coverage report shows what was compared.
3. **The tick order** (present.c step 2: Windows before DOS): solved by step 2b; a missed order would
   lag BS one tick and break partition independence (test 4 catches it).
4. **Present-layer transitions**: `shows_core_frame` changing during a run, the whole-client redraw at
   BS's start and end, the cursor (the game's, unchanged).
5. **Data**: the .rsc precedence and the CvPc decoder's edge cases (the 8 shipped pictures decode as the
   core decodes them; test 1 proves it on the user's data). A different or damaged data set switches BS
   off rather than showing a wrong picture.
6. **Harness time**: each p4-birth run is about 36 s wall; BS adds about eight runs (`assets`, `mirror`,
   `bs`, `bs_switch`, `bs_skip`, four `ext_continue` runs, V8). Reuse runs where a run can carry several
   checks (assets and mirror in one run).
7. **The user's perception**: Windows fades compressed to DOS's 0.69 s; captions with DOS durations;
   caption #44 removed at the final fade's start; no Windows counterpart for DOS's dim step and marker
   line. These are by design (D5) and listed for the user's check; FIDELITY records them.
8. **File overlap with UX1** (`host_win32.c`) and with any unit in `present/dos` (D4c1, UX1's pointer
   scaling): serialize or assign owners; a parallel coder's files are globbed into another builder's
   build (STATUS process notes).

## 8. Open

* How the movie record's `window` field (+0, a far pointer) leads to the dialog's HWND for
  `w16q_wnd`; BS2 reads GR_DialogOpen (1098:124F) and the window record to settle it.
* Whether `W16Q_OP_TEXTOUT`'s returned width equals `w16_GetTextExtent`'s (`w16_font_width`) for every
  STR# 139 line, and whether `W16qFont.height` is the tmHeight that GetTextMetrics returns
  (`w16_font_textmetric`); BS2 settles both (D4).
* The exact last-frame behaviour of fade items ("final step and DestroyPaletteFade"); BS2 transcribes it
  from `seg023_10B0_p1.c` cases 3 and 4.
* Whether any pixel outside the movie client changes during Birth (none expected); BS composes with the
  live screen there, so either way it matches.

# Extension D5, bug-fix unit D5P (screen parity after a Windows-side return to the title menu; the 4:3 shape on DOS-side returns; no Quit in the DOS title) - record

Extension session E3, staging implementer.  Staged under `build/d5p-stage/` only; nothing in the tree or in a shared
output was written for D5P.  Base snapshot of the tree: 2026-10-16 14:03:08 UTC (after SL's landing), refreshed
14:35 UTC after D6c/D6d's landing (only `tests/harness/ext_adapt.py` of the bases had changed: re-taken) and 14:58 UTC
for `docs/DOS-PROFILE.md` (the docs pass changed rows 96 and 107 at 14:54 UTC); every base hash in `BASE-SHA256.txt`
matched the tree at 14:58 UTC.

## Status

**LANDED 2026-10-16** (copy-in 15:32:39 UTC, ALL_GREEN 16:05:23 UTC, RELEASE_OK 16:10:16 UTC; user build
`build/user-builds/d5p/`; section "Landing").  At staging: READY_TO_BUILD, accepted by the orchestrator about 15:10 UTC
with (d) folded in.  One unit, four items, all in the DOS title menu (the orchestrator's ruling and scope extension
of 2026-10-16 about 13:56..14:00 UTC, and (d) of about 15:10 UTC):

* **(a) Parity.**  A return to the title menu made while the Windows graphics are visible now shows, in the DOS view,
  the original DOS title menu: the title picture (the logo on black, with the palette of the intro's end) and the menu
  box, exactly as it first appears after the intro, square.  Before D5P the box was drawn over whatever the branch had
  left on the DOS screen (the Customize picture, the Hall of Fame, the DOS load screen).
* **(b) Aspect on returns.**  The DOS title menu's shape follows the picture behind its box: 4:3 when the box is drawn
  over a 4:3 sub-screen (DOS-side returns: the Hall of Fame left with a key or a click, the DOS load screen left with
  Escape or an "(EMPTY)" line), square only on the title picture (after the intro, after D5P's Windows-side returns,
  and after a Load that drew nothing).  After a 4:3 return Start a New Game or Play on EARTH stays 4:3 through the
  outro and turns square at Birth, as UX3 does after Customize World's OK.  Supersedes UX3's "square again when the
  menu box is drawn" for these returns (UX3-5, UX3-6).
* **(c) No Quit row.**  The DOS title box has DOS's five items only (R:01A8:0494 draws DGROUP:1AE2's five lines), laid
  out as the listing lays out a five-item box.  The DOS title has no quit key (R:01A8:04B8..050E dispatches 0..4 only,
  -1 back to the box; R:1D05:0031's keys are Up, Down, Return, Space, Escape, Alt+H, Alt+V and the items' hotkeys),
  so Q is no key there: consumed like any letter without an item.  Quit stays in the Windows graphics (the core's
  sixth MenuZ item), and the host's close button and Alt+F4 stay.  When the core's selection is its Quit (selected in
  the Windows graphics) the DOS box shows no bar; Return and Space are consumed there, Up and Down pass (the core's
  MenuZ moves to item 4 or wraps to item 0) and the bar follows.  Corrects F149's "six rows ... and the added Quit row".
* **(d) The C.6.6 box's font** (folded in by the orchestrator's acceptance of about 15:10 UTC; it was this record's
  separate finding).  When the core's title choice comes while the DOS intro is still in its pan or logo (C.6.6:
  a shortcut N, L, E or C in the pan after the core's title is ready, or any choice made in the Windows graphics), the
  box drawn over the pan used the screen port's font 5, left there by the credits (O2:052C): rows 17 pixels high, the
  box twice as tall.  DOS reaches R:01A8:0486 only after O2:0BBE..0BC2 has set font 1; the box is now laid out in
  font 1, as at the hand-over.

The core is untouched (P0: every DOS-form/Windows-form pair has equal core outputs; `ext_p0.py`'s D5 runs P0_OK).
Presentation timing consumes no RNG (no call to any generator was added; `test_pdos_adapt`'s check that the DOS
generator is never called passes).  UX3 and the accepted DOS checks are kept apart from what (b) and (c) supersede.
All private results are green; the reproduction runs fail on the base build exactly where the user's reports say.

| Staged file | Base sha256 (tree) | Staged sha256 |
|---|---|---|
| `present/dos/pdos_seq.c` | `ada2602a9f038091b3c708ed30d850217ab784170d445ddbee0838e0a9b7aa08` | `e692f0ce8e11bf1ca2bf082543d09522e2f8ac7ed67430c7179d41ace4f9a2e2` |
| `present/dos/pdos_seq.h` | `cb3ebaf374bd794b456e14809f77208f69174d0555dc9f4af6097b7c37f8dd77` | `3acaeb4047c19f8ae9c9da236eb5b5fead08cc010f390ad62b8b381bec4d64c3` |
| `present/dos/pdos_adapt.c` | `101e4e8fe5cd8748f942703173eb8c2d226bf654a87cb02db8de90c0fb896459` | `9da5f0bda847a1ad57382b1df07a6940770fb616b339133b21ff180ec3170737` |
| `present/dos/pdos_adapt_tab.c` | `314ba580822d2afe58aa984df5218137813c9d7604e06eb51c61ef33713ad71e` | `5fab937de627ca1050d37097b6e15edfb87f29d54a0cb6e67ef6c1cd51ef3f05` |
| `tests/test_pdos_seq.c` | `6f5be846612f92630309d4c87ab218b5d76b0ca571b2061b2c0233dbd9d52bed` | `3a646c113e136a924844a359f33af19f7e88e567f5ebd6fa2de146af0479a98e` |
| `tests/test_pdos_aspect.c` | `62d4bb0603ce878feded1cb1abc943f44d20a69cb650abbc4beb9344dab02ab6` | `d99703f797cc0a381b3894f5d035a07aeda36cda22db40bc19f72985eb0f1af9` |
| `tests/test_pdos_adapt.c` | `e4a6aed76e52652d94bf06db49e78bde3f9b63d96cc09606206a7107b0bc4aa5` | `f451fb31904c9175d07800e40b58fe0d604128273126612efbc68d54f46a02c4` |
| `tests/harness/ext_adapt.py` | `ac031524d49eb58f1069ec4ee9c3c812b37ed9d6cd709d7969b3e679c1b36fae` | `bda6b584641fde243cf38a9dc0483b2cf382c742c2c36784003c613f6f446770` |
| `tests/harness/ext_aspect.py` | `419c06feb03b4c424d6d8efcc90a9bb4f9f4686189a90b604bb0e7f5fa38e634` | `9eed4a0afd70b1467bea504f8bf4f56314fe28c41ae7fd0c716e221262497db6` |
| `tests/harness/ext-timeline-golden.txt` | `e1693926850728626020e87a944309b5518b0ddfc4ca86e3b40d73afb541aad9` | `d301bc4b5d6d526497025d32f963e497ea0ee769a832c3f6c0837bc9fcbc2637` |
| `docs/DOS-PROFILE.md` | `7d6cc9e9d079a29cd1cd357b2e0702c1f8e64eee9cb004886b0b171b45d08592` | `c928782fe2142bccf7ed79b1a6c8221135d39e30dd6225db1d6a4cb4b9534788` |
| `docs/ext-D5P-record.md` | new | (this file) |

`docs/DOS-PROFILE.md` is a test input: the staged copy differs from the tree's only in 1.7.2's three generated rows
I-title/up-down/core-title, I-title/hotkey/core-title and I-title/key (`gen/dos/adapters.py gen` over the staged
`pdos_adapt_tab.c`); no SSSS:OOOO call address was added (the new texts cite listing offsets `R:...` only).  The
descriptive rows 2, 8, 3.2 and the 3.x Quit lines are left to the docs pass (see "For the records").  `DESIGN.md`,
`test.cmd`, `build.cmd`, the core, `present/input.c` and the registry are unchanged (no `BUILD-TEST-ADDITIONS.md`).
Line endings follow the bases (CRLF: `pdos_seq.c`, `pdos_seq.h`, `pdos_adapt.c`, `ext-timeline-golden.txt`; LF: the
others).

## The user's report and directions

The user's report (relayed by the orchestrator, verbatim): "Entered Customize World (does not matter on which mode)
switch to Windows, or already Windows, clicked cancel and returned to title menu on the Windows, if I switch to DOS
mode, then DOS customize world screen with title menu drew on top appears. The rule, dos mode and Windows graphics
mode shall be synced in terms of screen parity is broken. So I f return to title menu from customize world from the
Windows mode, Dos mode shall return to original title menu too."

The orchestrator's ruling: when the core returns to the title menu through an action taken while the Windows graphics
are visible, the DOS view shows the original DOS title menu (the title picture with the menu box, exactly as it first
appears after the intro, square); survey every title sub-screen; DOS-side returns keep the DOS listing's behaviour (the
Hall of Fame left with a key: the box over the Hall of Fame; SL's DOS Escape); keep UX3 and the accepted DOS checks;
the core stays untouched (P0); presentation timing must not consume the RNG.

The user's feedback of 2026-10-16 about 13:56 UTC (verbatim): "1. When 4:3 selected and in DOS mode, returning from
Hall of Fame and Load a Save Game switch backs to screen to square and displays Title Menu, in these cases 4:3 shall
be preserved. 2. There is no Quit option on original DOS version of the games in the Title Menu".

## Reproduction

Headless, with the base build (`obj/o-src-base`, the tree at the base) and the staged harness scripts
(`obj/adapt_priv.py base-new`, `obj/aspect-base-new`):

* **The user's exact sequence** (`ext_adapt.py` d-custom-cancel-keys): DOS from the start, X ends the DOS intro, the
  title's c and Return (Customize World), the chord, dialog 143's Cancel clicked in the Windows graphics, the chord
  back.  The DOS frame shown after the switch back is `0b6b8394cbe1...` (the box over CUSTOM.PIC and its first
  question), not the title frame shown before the choice (`24c7a32db637...`, the six-row box on the logo); no
  `title_picture` step.  FAIL on the base, as reported.
* **Already Windows** (d-custom-cancel-winstart: started in the Windows graphics, C, Return, Cancel, the chord to
  DOS): the DOS frame `1c5749c4088c...` (the box over the Customize screen).  FAIL on the base.
* **Hall of Fame left in the Windows graphics** (d-fame-win): `44d325e59ba3...` (the box over the Hall of Fame, the
  same frame as the DOS-side d-fame-key).  FAIL on the base.
* **Load cancelled in the Windows graphics** (d-load-win: the DOS load screen, `--slot-input switch`, the Windows
  chooser cancelled, the chord to DOS): `fb94ae8b7c3e...` (the box over the DOS load screen).  FAIL on the base.
* **4:3 on DOS-side returns** (`ext_aspect.py` `fame`, 1920x1080, the default 4:3): on the base the box drawn again
  over the Hall of Fame turns the screen square at 8.001 s ("3 wrong, first (8001100, 'sq', 'ft')"), as the user
  reports for the Hall of Fame and the Load.  FAIL on the base (5 failures with `fame_win`).
* **Quit in the DOS title** (d-title-noquit: q, Return with the DOS graphics): on the base q is the added Quit row's
  hotkey (I-title/hotkey/core-title: the core's Q) and Return quits; d-title-winquit (Q in the Windows graphics, the
  chord, DOS Return): on the base the DOS Return passes and the core quits.  FAIL on the base.
* **The C.6.6 box's font (d)** (the staged `test_pdos_seq.c` linked against the base build, `obj/onebase.cmd` with the
  no-op `obj/shim_vis.c` for the test seam): the title exit in the pan draws the box in the pan's font 5 ("h 17,
  w 149"), and the C.6.6 reference box (font 1) differs.  FAIL on the base.

## Root cause

* **(a)** `present/dos/pdos_seq.c` `title_again` (base lines 674..683; called at line 1113 when the core opens dialog
  139 again, C.7.4) models R:01A8:0807, DOS's redraw of the box after a branch, and always drew the box over the current
  page 0:

  > **C passage condensed for the public copy.** The original record has here a block of 3 lines of C statements: assignments to `g_core.title_choice`, `g_tb.view_row`; calls to `tb_show`, `tb_row`, `frame_of`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

  That is DOS's behaviour for a return DOS itself performs (its branch screen stays on page 0 and the box is drawn over
  it).  But the DOS view mirrors the core, and the core can return to the title through a Windows-only action
  (Customize's Cancel has no DOS form since D5eR, F170) or through an action taken while the Windows graphics are
  visible (the Load's host chooser, the Hall of Fame left in Windows).  The DOS program never performs those returns,
  so its redraw over the branch screen does not apply; the DOS view kept the branch screen under the box, which is
  what the user saw after switching back.
* **(b)** `tb_show` (base line 606) cleared `g_ux3_branch` on every box drawing (`g_ux3_branch = 0u; /* the title box
  again, square */`), so the box drawn again over the Hall of Fame or the DOS load screen (4:3 pictures) switched the
  shape to square although the picture behind it was still the 4:3 one.
* **(c)** `title_lines` (base lines 546..575) appended `g_quit_line` (" Quit", base line 147) as a sixth row
  (DOS-PROFILE 3.2's addition, F149); the adapter table gave it the hotkey Q (I-title/hotkey/core-title), and Return on
  it passed to the core, which quit.

## Fix

`present/dos/pdos_seq.c` (block "extension D5P" after UX3's, lines 226..240 of the staged file, and the helpers at
641..720):

1. **The title picture (a).**  `tp_capture()` in `title_check` (the intro's hand-over, before the box is drawn) copies
   page 0's 320x200 pixels and the DAC (the logo on black O2:0B65/0B7B/0BAB, the palette as the logo's cycle left it
   O2:0B2D..0B48).  `tp_restore()` puts them back (step `title_picture`, arg 1).  When the intro never reached its
   hand-over (the core's choice ended it in the pan or the logo, C.6.6), it composes the screen O2's program leaves
   for the title: black, LOGO.PIC's rows 64..143 (`PDOS_INTRO_LOGO_Y`, `_H`) and LOGO.PIC's palette (arg 0); a store
   without a 320x200 LOGO.PIC leaves black (`PDOS_DIAG_FILE`).  It also sets the screen port's font to 1 (O2:0BC2):
   the C.6.6 path leaves the credits' font 5 there.  The composed screen equals the hand-over's pixel for pixel and
   in its presented colours (`d-custom-cancel-winstart`'s DOS frame equals `d-custom-cancel-keys`' title frame).
2. **The rule (a).**  `title_again` asks `windows_side()`: the return was made in the Windows graphics when the choice
   was Customize World (`TITLE_CUSTOM` 3, R:01A8:04FE: its Cancel has no DOS form, D5eR; DOS asks the question again,
   R:01A8:065A/06B7/0714/0771) or the DOS graphics are not the visible profile at the core's return
   (`pdos_profile_visible()`, replaceable by `pdos_seq_set_vis_query` in tests).  Then the title picture comes back
   before the box (`title_shape` 1); otherwise R:01A8:0807's redraw over the branch's screen is kept unchanged.
   **Why by the visible profile, and Customize by the action's form:** Customize's Cancel exists only in the Windows
   dialog, so every Cancel is Windows-side whatever is visible when the core sees it (a core-form Cancel in a test or
   a script included); the Load's host chooser is modal and appears only with the Windows graphics visible (SL's slot
   screen hands over to it on the chord), and the Hall of Fame's key or click reaches the core within one present
   tick of its arrival, while a switch needs the three keys of the chord, so the visible profile at the core's return
   is the profile the action was taken in.  `present/input.c` (where the arrival's profile is known) is not touched,
   which keeps D5P off UX4's input files.
3. **The shape (b).**  `title_chosen` remembers page 0's generation (`g_branch_gen`); `title_again` keeps 4:3
   (`g_tb_sq` 0) when a DOS-side return finds page 0 changed since the choice (the branch drew its screen: the Hall of
   Fame, the DOS load screen), keeps the previous shape when nothing was drawn (a Load answered or cancelled by the
   host chooser at once), and turns square on the title picture (Windows-side).  `tb_show` now sets
   `g_ux3_branch = (g_tb_sq == 0)`: UX3's `pdos_seq_square_scene` then gives 4:3 for the title box over the branch's
   screen, through a following choice's outro, until Birth (square, UX3's rule) or a box on the title picture.  The
   step `title_shape` (arg 1 square, 0 4:3) precedes every `title_redraw`.
4. **No Quit row (c).**  `title_lines` cuts DGROUP:1AE2's LF-terminated lines only (`g_quit_line` removed); the box is
   laid out by the same `pdos_menubox_layout` for five rows.  `title_follow`: when the core's selection is past the
   box's rows (its Quit, item 5) no row is highlighted (`pdos_menubox_select(..., -1)`, step `title_row` arg -1);
   `tb_show` already drew such a row as -1.

`present/dos/pdos_adapt.c`: `title_nobar(sc)` (the title box scene with no highlighted row).  In `key_act`, Return and
Space set no RETURN/SPACE action there (so the row I-title/key consumes them: nothing to choose), and Up and Down set
UP/DOWN there (row I-title/up-down/core-title passes them: MenuZ moves from Quit to item 4 or wraps to 0, and the bar
follows the next poll).  Q matches no box hotkey any more, so it falls to I-title/key (consumed), in T4 and with the
core's MenuZ ready alike.  `present/dos/pdos_adapt_tab.c`: texts of I-title/up-down/core-title, I-title/hotkey/core-title
and I-title/key only (no row added or moved; the DOS-PROFILE 1.7.2 rows regenerated).  `present/dos/pdos_seq.h`: the
title box's documentation, the D5P paragraph, `pdos_seq_set_vis_query`, and `pdos_seq_square_scene`'s note for (b).

**Recorded deviation.**  The DOS view at a title return now depends on which graphics were visible at the core's
return: by the user's ruling the DOS view follows the action the user took.  This is a presentation-only exception to
draft A 13.2's "every profile's frame does not depend on which profile is shown"; no run of `ext_frames.py` or of
`ext_timeline.py`'s `start`/`switch` reaches a title return (their runs are the intro, S3 and Birth), and P0 holds.
Limitation: a chord pressed within the same present tick as the Hall of Fame's key would classify by the switched
profile (the chord takes three key presses; not reachable by hand in practice).

**The C.6.6 box's font (d).**  `title_chosen`'s C.6.6 branch (the box with the chosen row over the current DOS screen
when the finish stopped the intro before its hand-over) sets the screen port's font to `TITLE_FONT` (1) before
`tb_show`, as O2's program leaves the port for R:01A8:0486 (O2:0BBE..0BC2); before D5P the box took the pan's font 5
(the credits', O2:052C; FontLineHeight 17), so its rows were 17 pixels high (w 149 for the five items).  A box drawn
at the hand-over (font 1 already) and the DOS-side redraws (the branch's own port state, R:01A8:0807) are unchanged.

## Survey (every title sub-screen)

The core's title loop (core/seg061_11E0.c: GR_DialogOpen(139) 11E0:06C5, MenuZ 11E0:0729; 5 -> ShutdownGame; 1 Load
(-1 -> again), 3 Customize (non-zero -> again), 4 ShowHallOfFame; `while (choice < 0 || choice > 3)`):

| Branch | Return to the title | Windows-side (D5P (a)) | DOS-side |
|---|---|---|---|
| Start a New Game (0) | none (Birth, setup) | - | - |
| Load a Saved Game (1) | cancelled / -1 | Windows chooser cancelled (Windows visible, or SL's chord on the slot screen): **the title picture, square** (was: the box over the slot screen) | Escape or an "(EMPTY)" line on the DOS load screen: the box over it (R:01A8:0807, unchanged), **4:3 kept** (was square); a Load the host answered or cancelled at once with nothing drawn: the box over the same screen, its shape kept |
| Play on EARTH (2) | none | - | - |
| Customize World (3) | Cancel | always (no DOS Cancel since D5eR): **the title picture, square** (was: the box over CUSTOM.PIC) | - (Escape and clicks outside ask again, D5eR) |
| View Hall of Fame (4) | after its key or click | left in the Windows graphics: **the title picture, square** (was: the box over the Hall of Fame) | left in the DOS graphics: the box over the Hall of Fame (unchanged), **4:3 kept** (was square) |
| Quit (5, Windows only) | none (ShutdownGame) | Quit stays (Windows MenuZ, host close, Alt+F4) | **no DOS row, no Q** (was: the sixth row, Q) |

Not title returns: the end-of-game Hall of Fame (1080:06E2, DOS-PROFILE row 105) and a MenuZ -1 at the title
(`title_again` does nothing without a choice; unchanged).  RunIntroAndTitleMenu runs once (1008:01A8).

## Tests

* **`tests/test_pdos_seq.c`** (190 -> 214 checks): (d) `test_title_exit_pan` (the title exit in the pan, C.6.6):
  the reference now draws its box in font 1 (O2:0BC2) and a new check asserts the box's font 1, the port's font 1
  and the hand-over layout (h, w, right, bottom) where the pan's font was 5; the reference box from the store's TITLE_MENU without a Quit row (the
  five DOS items, the reference model at (100, 140)); `test_d5p` with the visible-profile seam (`q_vis`): (c) five
  items, no Q hotkey, square; the core's selection 5 -> no row (`title_row` -1), 4 -> row 4, 0 -> row 0 and the screen
  as at the hand-over; (a) the Hall of Fame left in Windows -> `title_picture` 1, `title_shape` 1, page 0 and the DAC
  equal to the hand-over's copy, square; (a)/(b) left in DOS -> no picture, the box over the Hall of Fame, 4:3; a Load
  with nothing drawn keeps 4:3; Start a New Game 4:3 through the outro, Birth square; Customize cancelled with DOS
  visible (a core-form Cancel) -> the title picture, square; Load: the slot screen stand-in then Windows-side ->
  the picture, square; DOS-side -> 4:3; nothing drawn -> square; C.6.6 (the choice at 10 s in the pan) then the Hall
  of Fame left in Windows -> `title_picture` 0, pixels equal to the hand-over's, the DAC LOGO.PIC's palette.
* **`tests/test_pdos_aspect.c`** (61 -> 80): `test_dos_returns` (the Hall of Fame left in DOS keeps 4:3; a Load with
  nothing drawn still 4:3; New Game 4:3 through the outro, Birth square; a Load from the title picture with nothing
  drawn square; a Load whose screen was drawn, DOS-side 4:3, Windows-side square); `test_branches` runs Windows-side
  (square, as before); `test_present`'s box over the Hall of Fame left in DOS: 4:3, 4x5 (was square).
* **`tests/test_pdos_adapt.c`** (145 -> 155): the hand-over box has five items, the last V, no Q; T4 q: I-title/key,
  consumed, the row stays; the last row reached with v; `test_d5p_quit`: the core's selection 5 -> no bar; Return
  (and its repeat, release), Space and q consumed (I-title/key); Up passed (I-title/up-down/core-title), the bar on row
  4 after the poll, Return passed there; Down from 5 passed, the bar on row 0.
* **`tests/harness/ext_adapt.py`** (the D4c2 pairs; `--presented 1` for the cases with a check; a case's `dos_opts`
  for `--slot-input`): d-title-quit replaced by **d-title-noquit** (q consumed, Return: Start a New Game <-> Return);
  **d-custom-cancel-keys** (the user's exact sequence) asserts `title_picture` 1 and `title_shape` 1 at the Cancel and
  every DOS frame from the chord back to the next DOS key equal to the DOS title frame before the choice
  (presented.log); new **d-custom-cancel-winstart** (already Windows; the frame equal to d-custom-cancel-keys' title
  frame, `title_picture` 0), **d-fame-win**, **d-load-win** (Windows-side: the same frame assertions), **d-load-escape**
  (SL's DOS Escape: no `title_picture`, `title_shape` 0, the last DOS frame not the title frame), **d-title-winquit**
  (Q in Windows, the chord, DOS Return consumed, Up, Return: View Hall of Fame; `title_row` -1); **d-fame-key** asserts
  the DOS-side return (no `title_picture`, `title_shape` 0, not the title frame).  Each pair also asserts equal core
  outputs (P0).
* **`tests/harness/ext_aspect.py`** (16 -> 24 checks): markers from `title_shape` (1 square, 0 4:3) instead of
  `title_redraw`; a seventh run **fame_win** (the Hall of Fame left in Windows between two chords, then Load cancelled
  and Start a New Game: square from the return, 4:3 at the setup page); per flow the `title_shape`/`title_picture`
  sequence (fame 0, 0; fame_win 1, 1 with one picture; custom none); P0 now includes fame_win.
* **`tests/harness/ext-timeline-golden.txt`**: `golden frame 4766` (the title box at the hand-over) re-recorded for the
  five-row box (`43a56f67...` -> `5d23af2a...`), and (d) `bgolden frame 20` (the `birth` run: the core's Start a New
  Game at 22 s comes while the DOS intro is in its pan, C.6.6, so the box is drawn over the pan, and Birth's first
  marker at frame 20 is drawn over that screen) for the box in font 1 (`f9cf1114...` -> `6a678419...`, taken from the
  run's `bwatch frame 20` line), each with a header note; the other goldens are unchanged.

## Results (private, `build/d5p-stage/obj/`, 2026-10-16 14:05..15:00 UTC; (d) 15:12..15:40 UTC)

Builds over the overlay (`mkoverlay.py`: the tree's sources + the stage; build.cmd's compiler, flags and include order,
`cc.cmd`): `obj/o-src-base` (the base, Checked) and `obj/o-src` (Checked, CheckedNoObs, Release): CC_ALL_OK each.
Strict c11 + c17 /W4 /WX and the clang-tidy C99 parse of the six changed `.c` files: CC_STRICT_OK (again for
`pdos_seq.c` and `test_pdos_seq.c` after (d); `obj/o-src` Checked rebuilt, CC_ALL_OK).  After (d) the seven unit
tests, `ext_adapt.py`'s pairs, `ext_aspect.py` and `ext_timeline.py`'s base group were run again on the rebuilt
Checked harness (the rows below give the final counts).

| Check | Base | Staged |
|---|---|---|
| test_pdos_seq (Checked; CheckedNoObs and Release before (d)) | PASS 190 | PASS 214 (213 / 213 / 213 before (d)) |
| the staged test_pdos_seq.c linked against the base build (`obj/onebase.cmd`, `shim_vis.c`) | FAIL 26 of 214: every D5P vector, among them (d)'s "the C.6.6 box in the title font 1 ... not in the pan's font 5: h 17, w 149" and the C.6.6 reference box | - |
| test_pdos_aspect | PASS 61 | PASS 80 / 80 / 80 |
| test_pdos_adapt | PASS 145 | PASS 155 / 155 / 155 |
| test_pdos_pend, test_pdos_slots, test_pdos_scene, test_pdos_setup | PASS 104, 121, 136, 164 | unchanged (Checked; CheckedNoObs and Release pass too) |
| `adapters.py check` (staged DOS-PROFILE 1.7.2) | - | ADAPT_OK rows 98 steps 22 (after `gen`) |
| `obs_lint.py`, `registry.py check`, `nodos.py check`, `pdos_scene_check.py` | - | OBS_LINT_OK files 119; REGISTRY_OK; NODOS_OK (0 hits); PASS 1078 checks |
| `ext_adapt.py` D4c2 pairs (`adapt_priv.py`) | tree script + base: 33 cases, 103 checks, 0 failed | 38 cases, 129 checks, 0 failed |
| the same, staged script + base harness (reproduction) | 8 D5P cases: 12 failed (above) | - |
| `ext_aspect.py` | tree script + base: EXT_ASPECT_OK (16) | EXT_ASPECT_OK (24); staged script + base: 5 failed |
| `ext_timeline.py` (base group; golden redirected to the stage copy) | EXT_TIMELINE_OK (41) | before re-recording: only `golden 4766` differs; after: EXT_TIMELINE_OK (41); after (d) only `bgolden 20` differed, updated: EXT_TIMELINE_OK (41) |
| `ext_timeline.py --group bs` | - | EXT_TIMELINE_OK (11) |
| `ext_slots.py` (staged harness) | - | EXT_SLOTS_OK (45) |
| `ext_p0.py` V0, V1, V2: d5-goback, d5-tribe, d5-custom-cancel, d5-custom-help, d5-load-cancel, d5-fame-new, start, birth | - | P0_OK checks 50 (pdos_rows counters 0) |

DOS-side returns unchanged apart from (c) (`obj/dump_cmp.py`, `--dump-presented`, the last DOS frame of each run,
base against staged, RGB through each frame's palette): the title box alone differs in x 101..220, y 185..195 (the
removed Quit row); the box over the Hall of Fame (d-fame-key) and over the DOS load screen after Escape
(d-load-escape) differ in x 100..221, y 185..196 only (the old sixth row and its frame line, now the picture
behind); every other pixel is equal.

Not run privately (they write shared outputs or have no private-root option): `ext_frames.py`, `ext_mirror.py`,
`ext_zoom.py`, `ext_continue.py`, `ext_replay.py`, `ext_g1.py`, `gate3b.py`, `scenarios.py`, `uninit.py`,
`p4tests.py`, the Win32-headless tests and the full `ext_p0.py` matrix.  The core is untouched and their runs reach no
title return except `scenarios.py`'s fame-quit/fame-reload (Windows graphics; core outputs compared only), so no
change is expected; the build slot's cycle is the evidence.

## Expected expectation changes (at the build slot)

* `test_pdos_seq` 190 -> 214, `test_pdos_aspect` 61 -> 80, `test_pdos_adapt` 145 -> 155 checks (all variants).
* (d): DOS frames that show a C.6.6 box (a DOS-visible shortcut in the pan after the core's title is ready:
  `ext_adapt.py` d-pan-n-title's DOS run; any hidden DOS view whose core chose in the Windows graphics before the DOS
  hand-over) change; one golden holds such a frame: `ext_timeline.py`'s `bgolden frame 20` (the `birth` run, whose
  core chooses Start a New Game at 22 s in the pan; Birth's first marker is drawn over that screen), re-recorded below.
* `EXT_ADAPT_OK checks` +26 (the tree's last cycle printed 128 with D6d: expect **154**); the run count +10 (five new
  pairs); d-title-quit's result EXIT no longer exists (d-title-noquit reaches title-choice).
* `EXT_ASPECT_OK`: 16 -> 24 checks, seven runs (fame_win added).
* `ext_timeline.py`: `golden frame 4766` and (d) `bgolden frame 20` changed (staged golden); the check count is
  unchanged (41; bs group 11).
* `DOS-PROFILE.md` 1.7.2: three rows' texts (generated).
* Every DOS frame showing the title box loses the Quit row (presented.log hashes of DOS-profile runs that show the
  box change; no other golden holds such a frame).  A DOS-side box over the Hall of Fame or a DOS load screen keeps
  4:3 at 1920x1080 where it was square (`ext_aspect` only; at 640x480 both shapes give the same 2x2 image).
* Base outputs (G-1, P0, gate3b): none (presentation only).

## Rebase notes

Every base hash is in `BASE-SHA256.txt`.  If a base changed again, take the tree's file and apply D5P's parts:

* `present/dos/pdos_seq.c`: `#include "pdos_pal.h"`; `g_quit_line` removed and `title_lines`' bound and return (no
  Quit append; `g_tb.nlines >= TITLE_LINES`); the block "extension D5P (begin)..(end)" after UX3's; in `title_reset`
  [3 C statements condensed: setting `g_tp_valid`, `g_tb_sq`, `g_branch_gen`]; `tb_show`'s `g_ux3_branch` line; the
  helper block after `tb_select` (`tp_capture`, `tp_restore`, `vis_dos`, `windows_side`, `pdos_seq_set_vis_query`);
  `tp_capture()` in `title_check`; `title_follow`'s no-row branch; the `g_branch_gen` line at `title_chosen`'s end;
  `title_again`'s D5P lines.  CRLF.
* `present/dos/pdos_seq.h`: the title-box paragraph, the D5P paragraph, the `pdos_seq_set_vis_query` declaration,
  `pdos_seq_square_scene`'s note.  CRLF.
* `present/dos/pdos_adapt.c`: `title_nobar` (before `key_act`'s helpers) and `key_act`'s Return, Space and Up/Down
  lines.  CRLF.  (UX4 touches host/input files, not these, as far as known.)
* `present/dos/pdos_adapt_tab.c`: the three I-title rows' texts; then **regenerate** DOS-PROFILE 1.7.2
  (`gen/dos/adapters.py gen`) on the tree's `DOS-PROFILE.md` instead of merging it: the docs agent edits
  `docs/*.md` concurrently.
* `tests/test_pdos_seq.c`, `test_pdos_aspect.c`, `test_pdos_adapt.c`: the D5P blocks and the changed expectations
  named under "Tests".
* `tests/harness/ext_adapt.py`: the docstring lines (d-title-noquit; the D5P paragraph; d-custom-cancel-keys' note);
  `checks`, `dos_frames`, `title_return` before `d_clicks`; the D_CASES changes (d-title-noquit, d-custom-cancel-keys'
  check, d-fame-key's check, the five new cases at the end); `run_one`'s `dos_opts`.  d-custom-cancel-winstart reads
  d-custom-cancel-keys' DOS output (a sibling directory of the same run): keep both cases in one run.
* `tests/harness/ext_aspect.py`: the docstring, `CHORD` and `keys`' chord, `HOST_TEXT["fame_win"]`, `runs()`,
  `markers`' `title_shape`, `check_flow`'s D5P check, `main`'s loops and P0 list.
* `tests/harness/ext-timeline-golden.txt`: keep the tree's header, add the two D5P notes, replace the `golden frame
  4766` and `bgolden frame 20` lines (or re-record with `--record` and restore the header's D5cR/D5P notes, which
  `--record` drops).

## Build-slot steps

1. Check the tree against `BASE-SHA256.txt`; apply the rebase notes for any changed base.
2. Copy the stage's files (not `obj/` or `BASE-SHA256.txt`) into `claude/port`: the eleven staged files and the new
   `docs/ext-D5P-record.md`.
3. If `pdos_adapt_tab.c` or `DOS-PROFILE.md` were merged by hand: `gen/dos/adapters.py gen`, then `check`.
4. `build.cmd` (all variants), then `test.cmd checked`, `test.cmd checked noobs`, `test.cmd` (Release); expect the
   counts above (`EXT_ADAPT_OK checks 154`, `EXT_ASPECT_OK`, `EXT_TIMELINE_OK`).  No `test.cmd` change.
5. Records ("For the records"); a user build with the DOS graphics and the 4:3 option (the default) for D5P-1..D5P-10.

## What the user checks

With the 4:3 option (the default) unless an item says otherwise.  "The title menu as after the intro" means: the
Civilization logo on black with the DOS menu box below it, square, the first row highlighted.

- **D5P-1**: Your exact sequence: start with the DOS graphics, choose Customize World, switch to Windows
  (Ctrl+Shift+Backspace), click Cancel, switch back to DOS.  The DOS screen is the title menu as after the intro, not
  the Customize picture with the menu drawn on it.  Up, Down and Return work there.
- **D5P-2**: The same when you are already in the Windows graphics: choose Customize World in Windows, click Cancel,
  then switch to DOS: the title menu as after the intro.
- **D5P-3**: View Hall of Fame, leave it with a key or a click while the Windows graphics are shown (switch to Windows
  on the Hall of Fame first, or choose it in Windows), then switch to DOS: the title menu as after the intro.
- **D5P-4**: Load a Saved Game, cancel it in the Windows file chooser (in Windows, or switch to Windows on the DOS
  load screen), then switch to DOS: the title menu as after the intro.
- **D5P-5**: In the DOS graphics, View Hall of Fame and leave it with a key: the menu box is drawn over the Hall of
  Fame and the screen stays 4:3 (it no longer turns square).
- **D5P-6**: In the DOS graphics, Load a Saved Game and press Escape on the DOS load screen (or choose an "(EMPTY)"
  line): the menu box over the load screen, still 4:3.
- **D5P-7**: After D5P-5 or D5P-6, choose Start a New Game (or Play on EARTH): the screen stays 4:3 until the first
  Birth picture, then square through Birth, then 4:3 again from the first setup page, as before.
- **D5P-8**: The DOS title menu has five items (Start a New Game, Load a Saved Game, Play on EARTH, Customize World,
  View Hall of Fame) and no Quit; Q does nothing there; the other letters, Up, Down, Return, Space and the mouse
  work as before.
- **D5P-9**: Quit is still in the Windows graphics: switch to Windows on the title and Quit works there.  Select Quit
  in Windows (for example with Q) and switch to DOS: no DOS row is highlighted, Return does nothing, Up highlights View
  Hall of Fame and Down Start a New Game.  The window's close button and Alt+F4 still end the program.
- **D5P-10**: In the DOS graphics, let the intro run for about 30 seconds after civ64.exe starts, while the panorama
  with the credits is still on (the game's own title menu is ready in the background by then; `ext_adapt.py`
  d-pan-n-title presses N at 25 s), then press N (Start a New Game), or E or C.  For a moment, before the next screen,
  the menu box appears over the panorama with your choice highlighted: its letters are the normal small title-menu
  letters, the box the same size as the title menu's (it used to be drawn in the large credits letters, twice as tall).

## For the records

- **FIDELITY.md**: a new row (number by the docs pass):
  `| F? | the DOS title menu after a return made in the Windows graphics, its shape on DOS-side returns, and no Quit row (present/dos/pdos_seq.c tp_capture, tp_restore, windows_side, title_again, title_lines, title_follow, title_chosen; present/dos/pdos_adapt.c title_nobar; the DOS listing R:01A8:0494..050E, R:01A8:0807, O2:0B65, O2:0B7B, O2:0BAB, O2:0BC2; SCENES 6) | The DOS program returns to its title menu only from its own branches (R:01A8:0807: the box drawn over the branch's screen); its title has five items and no quit key | A return to the title menu made in the Windows graphics (Customize World's Cancel, which has no DOS form; otherwise the DOS graphics not visible when the core opens dialog 139 again: the Load's host chooser, the Hall of Fame left in Windows) shows in the DOS view the title picture of the intro's hand-over (page 0 and the DAC; composed from LOGO.PIC when the intro never reached it, C.6.6) with the box, square: the DOS view follows the user's action (the user's report of 2026-10-16 and the orchestrator's ruling); a DOS-side return keeps R:01A8:0807's redraw over the branch's screen and keeps the 4:3 option there, through a following choice's outro, until Birth (the user's direction of 2026-10-16 13:56; supersedes UX3's square redraw for these returns); the box has DOS's five items, no Quit row and no Q (the user's direction of 13:56; the listing has no quit key); while the core's selection is its Quit (selected in the Windows graphics) the DOS box shows no row, Return and Space are consumed, Up and Down pass. The DOS view at a title return depends on the profile visible at the core's return (presentation only, P0). Status: implemented in D5P (staged 2026-10-16); tests test_pdos_seq, test_pdos_aspect, test_pdos_adapt, ext_adapt.py (d-custom-cancel-keys, d-custom-cancel-winstart, d-fame-win, d-load-win, d-load-escape, d-fame-key, d-title-noquit, d-title-winquit), ext_aspect.py (fame, fame_win), ext_timeline.py golden 4766 and bgolden 20; user checks D5P-1..D5P-10. The C.6.6 box (the core's choice before the DOS hand-over) is laid out in the title font 1 (O2:0BC2), not the credits' font 5 the pan leaves. Label: **the user's direction**, with **DOS listing (model)** for the title picture | ext-D5P-record.md |`.
  **F149** corrections: "with six rows: the five DOS items, read from the store at run time, and the added Quit row
  of the Windows title" -> "with DOS's five items, read from the store at run time (since D5P no added Quit row)";
  "it is drawn again when the core reopens dialog 139 (Load cancelled, Hall of Fame closed, Customize cancelled)" ->
  "... ; since D5P on the title picture after a return made in the Windows graphics (F?)".  **F173**: "from the title
  to the title box drawn over the Hall of Fame screen" add "when left in the DOS graphics (4:3 kept since D5P; left in
  the Windows graphics: the title picture, F?)".  **F175**: "Quit is D4's title box and D4c's Q hotkey, recorded" ->
  "Quit is Windows-only since D5P (no DOS row, no Q: F?)".  **F170**: "the title box is drawn over the Customize screen
  (R:01A8:0807), as before" -> "the DOS view shows the title picture with the box (the Cancel is Windows-side, F?)".
- **DOS-PROFILE.md** (the docs pass; the staged copy changes 1.7.2 only): row 2's last cell "five DOS items, no Quit
  (Quit added, 3.2)" -> "five DOS items, no Quit (D5P: Quit only in the Windows graphics)"; row 8's "the DOS title box
  with the added Quit item (R:1D05:0031)" -> "none: Quit is a Windows-only item (D5P; the DOS title has no quit key,
  R:01A8:04BB..050E)" and its last cell "(as implemented: D4's title box and D4c's Q hotkey...)" -> "the added item
  withdrawn by the user's direction of 2026-10-16 (D5P; F?)"; 0.3 (line 367) "I-title | the added Quit row (3.2) |
  selection of the core's Quit item | translate" -> "I-title | the core's Quit selected in the Windows graphics | no
  DOS row: no bar, Return and Space consumed, Up and Down passed | consume (D5P)"; 3.2 (line 834) "Quit on the title
  menu ... a sixth row in the DOS box at (100, 140); hotkey Q (proposal)" -> "... withdrawn (D5P): Quit only in the
  Windows graphics"; 3.x (line 873) "Title menu | DGROUP:1AE2 (five items) | the added Quit item" -> "... | none since
  D5P".  Rows 1.2's title returns (rows 3, 4, 7): "the box drawn again over the branch's screen when the return is made
  in the DOS graphics; the title picture after a return made in the Windows graphics (D5P)".
- **DESIGN.md**: the D5e paragraph (line ~3267) "After Cancel the title box is drawn over the Customize screen (D5a's
  `title_again`, R:01A8:0807), as DOS does" -> "After Cancel (a Windows-only action) the DOS view shows the title picture
  of the hand-over with the box (D5P)"; the D5f paragraph (line ~3468) add "(left in the DOS graphics; left in the
  Windows graphics: the title picture, D5P)"; UX3's switch points (lines ~3539..3547): "cleared when the title box is
  drawn (`tb_show` ...)" -> "cleared when the title box is drawn on the title picture; kept when it is drawn again over
  the branch's own screen (D5P (b), `g_tb_sq`, step `title_shape`)", and "after it 4:3 until the box's redraw, then
  square" -> "left in the DOS graphics 4:3 through the box's redraw and a following choice's outro until Birth; left
  in the Windows graphics square from the return", the same for Load ("cancelled in the DOS load screen 4:3 kept;
  cancelled in the Windows chooser square") and Customize ("after Cancel square from the redraw on the title
  picture"); C.18's choices (line ~3633) "the title box drawn again over the current DOS screen on return; title
  hotkeys from the DOS text and Q for Quit" -> "the title box drawn again over the current DOS screen on a DOS-side
  return, on the title picture on a Windows-side return (D5P); title hotkeys from the DOS text (no Q since D5P)".
  A note in 13.2's area: the D5P exception (the DOS view at a title return depends on the visible profile).
- **RUNNING.md**: the `ext_adapt.py` row: d-title-quit -> d-title-noquit; "since D5P d-custom-cancel-winstart, d-fame-win,
  d-load-win, d-load-escape and d-title-winquit (the DOS view after a return to the title menu: the title picture after
  a Windows-side return, the box over the branch's screen and 4:3 after a DOS-side one; no Quit in the DOS title),
  with presented.log"; `EXT_ADAPT_OK checks 154`.  The `[UX3: ext_aspect.py]` row: seven runs (fame_win), `title_shape`
  switch points, 24 checks.  The `ext_timeline.py` row: golden 4766 re-recorded for the five-row box (D5P).  "The
  graphics profiles": "The DOS title menu has DOS's five items; Quit is in the Windows graphics (Ctrl+Shift+Backspace)
  or the window's close button."
- **FEATURES.md**: row "DOS title box after the DOS intro (six rows, ...)" -> "(five rows: DOS's items, no Quit since
  D5P, ...)"; the Customize, Hall of Fame and Load rows: the return's DOS screen by the graphics the user acted in
  (D5P), tests the ext_adapt D5P pairs and ext_aspect fame_win; user checks D5P-1..D5P-10.
- **manual-checklist-ext.md**: D4-8 (six items): "superseded by D5P (c): five items, no Quit row" (its pass kept as
  history); D5-22 ("EARTH and Quit"): its Quit part superseded by D5P (c) (Quit only in the Windows graphics; D5P-8,
  D5P-9); UX3-5: superseded by D5P (b) (leaving the Hall of Fame in the DOS graphics keeps 4:3; re-checked as D5P-5);
  UX3-6: its failure of 13:56 reworked by D5P (b) (a Load cancelled on the DOS load screen keeps 4:3; cancelled in the
  Windows chooser: the title picture, square; re-checked as D5P-4 and D5P-6); D5-14 and D5-16: unchanged in what they
  test, but D5-16's "after it the DOS title box shows over the Customize screen" -> "after it, switching back to DOS
  shows the title menu as after the intro (D5P, D5P-1, D5P-2)"; UX3-4's "Cancel: square again when the title menu's
  box is drawn again" stays true (now on the title picture, D5P-1).  New items D5P-1..D5P-10 (section D5P, sources: the
  user's report and direction of 2026-10-16; F?), pending, with the user build named when made.
- **STATUS.md**: unit D5P (screen parity after a Windows-side return to the title menu; 4:3 kept on DOS-side returns;
  no Quit in the DOS title) staged/landed; the user's report and the 13:56 direction items 1 and 2 addressed.

## Landing (2026-10-16, build slot)

**Landed 2026-10-16 15:32:39 UTC; cycle ALL_GREEN 16:05:23 UTC; RELEASE_OK 16:10:16 UTC; user build
`build/user-builds/d5p/`.**  Done by the build slot on the orchestrator's instruction (about 15:10 UTC), after UX4's
landing (`build/ux4-status.txt`: ALL_GREEN 15:27:18 UTC, RELEASE_OK 15:32:03 UTC;
`build/user-builds/ux4/WHAT-TO-CHECK.txt` present at 15:32 UTC).  No docs pass ran between UX4 and D5P; one joint
docs pass follows D5P.

1. **Bases.**  `build/d5p-prep/land.py`: all 11 tree files still had their bases (`BASE-SHA256.txt`; UX4 changed none
   of them: its files are `host_win32.*`, `input.h`, `arrive.c`, `civ64_locate.c`, `test_input.c`,
   `test_host_win32.c`), this record was absent, and the 12 staged copies had the SHA-256 frozen in
   `build/d5p-prep/staged.sha256` after the last staging edit.  No rebase was needed; `docs/DOS-PROFILE.md`'s base is
   the tree's `7d6cc9e9...` (after the docs pass of 14:54 UTC), on which 1.7.2 had been regenerated with
   `gen/dos/adapters.py gen` at staging.
2. **Snapshot and copy.**  Before writing: the tree's Checked test outputs (59 files of `build/test/Checked`, UX4's
   cycle) in `build/d5p-prep/before`, the 11 previous tree files in `build/d5p-prep/tree-before`.  The 12 files byte
   for byte (11 changed, this record new); `build.cmd` and `test.cmd` unchanged (D5P has no BUILD-TEST-ADDITIONS;
   SHA-256 `40de571d...` and `5f6ddf6c...` in the manifest); manifest `build/d5p-prep/landed.sha256` (14 lines),
   `landed-at.txt`.  This section and the Status line were added after the cycle: the tree's record differs from the
   manifest's `76814ecc...` by these two edits only (the stage copy carries them too).
3. **Cycle** (`build/d5p-prep/d5p-cycle.ps1`, UX4's script with the D5P names; status `build/d5p-status.txt`, logs
   `build/d5p-<n>-<step>.log`):
   - 1 build-checked: exit 0, 260 s, BUILD_OK, portable sources 293, no warning.
   - 2 test-checked: exit 0, 1698 s, TESTS_OK.  No w32 flake: `w32_test_host_win32` passed (387 checks) the first
     time, so there is no `-r2` run.
   - 3 g1-checked: exit 0, EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events): **ALL_GREEN**.
   - 4 build-release: exit 0, 283 s, BUILD_OK, portable sources 293: **RELEASE_OK**.
4. **Comparison** (`build/d5p-prep/compare.py`, output `compare.txt`; the predictions in
   `build/d5p-prep/predictions.txt` were written before the copy-in, about 15:00 UTC, amended 15:31 UTC for (d)):
   53 of 59 files equal (lines with times left out).  The differences:
   - `sections/unit.log`: test_pdos_seq 190 -> 214, test_pdos_aspect 61 -> 80, test_pdos_adapt 145 -> 155 checks; the
     OBS_COST line's nanoseconds (a timing line the filter keeps).  Predicted; test_pdos_pend 104, test_pdos_slots
     121, test_pdos_scene 136, test_pdos_setup 164, test_input 435 and test_host_win32 387 unchanged.
   - `ext-adapt.txt` (129 -> 155 lines) and `sections/ext_adapt.log`: `EXT_ADAPT_OK checks 128 -> 154`.
     d-title-quit's three lines replaced by d-title-noquit's four; d-custom-cancel-keys 4 -> 5 and d-fame-key 3 -> 4
     lines; the five new cases d-custom-cancel-winstart, d-fame-win, d-load-win, d-load-escape, d-title-winquit with
     5, 5, 5, 4 and 4 lines.  Predicted line for line.  `compare.py`'s time filter hides the lines that carry seconds
     (the title_chosen/title_row and title-return checks); they were read in `ext-adapt.txt` directly, for example
     d-custom-cancel-keys "a Windows-side return in 28.0..29.0 s: title_picture [1], title_shape [1]; the DOS frames
     shown in 29.0..30.0 s: 2ce2608a1d2e; the title frame ... 2ce2608a1d2e" and d-fame-key's DOS-side return
     (title_picture none, title_shape [0], frames `393b3c67eb7f`, not the title frame).
   - `ext-aspect.txt`: 16 -> 24 PASS lines: fame's switch list now `sq@0 ft@5502100 load@11501700 ft@11501700
     sq@15272400 ft@24596282` (4:3 kept from the Hall of Fame through the Load to Birth), the runs and P0 lines
     naming fame_win, fame_win's six lines, fame's and custom's title_shape lines.  Predicted.  Not stated in the
     predictions: fame's pointer line "12 pointers" -> "9 pointers" (fewer layout switches, so fewer pointers made;
     0 wrong; the same as the private run).  `sections/ux3_aspect.log`: EXT_ASPECT_OK unchanged.
   - `nodos.txt`: 1726 -> 1727 files (this record), 0 hits.  Predicted.
   - `sections/times.txt`: section times; wall 1483.9 -> 1695.5 s (ext_zoom's soak stays the critical path,
     1540 s).
   Every other output equal, as predicted: ext-timeline (41 checks; the staged golden's new `golden 4766` and
   `bgolden 20` hashes, the line texts unchanged) and ext-timeline-bs, ext-p0 (P0_OK checks 476), ext-frames,
   ext-continue, ext-mirror, ext-zoom, ext-replay, ext-slots (EXT_SLOTS_OK), bs1..bs3, gate3b, uninit, scenarios,
   p4tests, harness_stub, adapters-check (ADAPT_OK rows 98 steps 22), obs-lint, obs-tables, registry-check,
   pdos-scene-check, dos-decoded, present-goldens, coverage.
5. **User build** `build/user-builds/d5p/`: `civ64.exe` (the Release build, SHA-256 `b64a0140...2c8a86`),
   `CIVWIN.zip` and `civdos.zip` (byte-identical copies from `user-builds/d4`, `058d4e00...` and `0eac32c9...`) and
   `WHAT-TO-CHECK.txt` (D5P-1..D5P-10 in plain words, CRLF; it names the builds it contains: ux4 (M-3, LP-8, LP-5;
   the user's Ctrl+Shift+Home is UX4b's, not in this build), d6d, sl and the earlier ones).
6. **Not done here**: the entries of "For the records" (FIDELITY's new row, DOS-PROFILE's descriptive rows 2, 8, 3.2
   and the 3.x Quit lines, DESIGN, RUNNING, FEATURES, the checklist's D4-8, D5-22, UX3-5, UX3-6, D5-14, D5-16 and
   UX3-4 wording and the new D5P-1..D5P-10, STATUS) are the joint docs pass's, after D5P.

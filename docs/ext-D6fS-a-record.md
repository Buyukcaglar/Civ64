# Extension phase D6, unit D6fS-a (the DOS boxes in play: no Windows window while they close, their DOS sizes) - record

Draft for the build slot (unit D6fS, extension session E4; the orchestrator's rulings of 2026-10-17 about 08:20 UTC split
D6fS into D6fS-a, this record, and D6fS-b, `ext-D6fS-b-record.md`, staged on top of this one).  Staged in
`build/d6fsa-stage/` on the tree after the D7a and D7b landing (`build/d7ab-status.txt` ALL_GREEN 08:45:17 UTC): the
bases were copied to `obj/base/` at 08:23:36 UTC (20 files D7a and D7b did not change), 08:33:14 UTC
(`present/map/pmap.h`), 08:48:59 and 08:49:50 UTC (the files of `build/d7ab-prep/landed.sha256` this unit changes and
the headless harness's header and main, after ALL_GREEN), 09:19:34 UTC (`tests/test_map.c`), 10:38:05 UTC
(`tests/harness/obs_lint.py`) and 10:40:55 UTC (`present/dos/pdos_profile.c`).  D7c's landing (`build/d7c-prep/
landed.sha256`) changed two of the staged files' bases, `present/dos/pdos_profile.c` and `tests/harness/ext_adapt.py`:
both were rebased at 11:19:53 UTC (a three-way merge of the D6fS-a edits onto D7c's landed files, without conflict).
DBL's landing (`build/dbl-prep/landed.sha256`, copy-in 11:50:46 UTC) changed five more: `present/dos/pdos_aplay.c`,
`present/dos/pdos_profile.c`, `present/map/pmap_dos.c`, `present/map/pmap_int.h` and `present/map/pmap_inview.c`,
rebased the same way at 12:07:30 UTC (no conflict; DBL's blocks and D6fS-a's are separate).  D7j's landing
(`build/d7j-prep/landed.sha256`, copy-in 12:54:30 UTC, RELEASE_OK 13:34:07 UTC) changed three: `present/dos/
pdos_profile.c`, `tests/harness/ext_adapt.py` and `tests/headless/harness.c`, rebased at 13:35:17 UTC (pure unions,
Rebase notes).  Every result below is of the tree with D7c and DBL unless it says otherwise; every base is rechecked
equal to the tree in `BASE-SHA256.txt`.  Private builds and runs in `build/d6fsa-stage/obj/` only: an overlay `obj/src` = the tree +
the staged files (`obj/mkoverlay.py`), built with the tree's build.cmd and flags (`obj/b.cmd`, `--nogen`), cc.cmd's
stricter checks per file (`obj/cc.cmd`), the unit programs (`obj/ut.sh`) and the harness runs from copies of the
overlay's Checked harness (`obj/exe/`), every output under `obj/`; the tree's build/gamedata, dosdata, cache and
dos/disasm read only.  A second overlay, `obj/src-infra` (the tree + only the test infrastructure: `present/profile.h`,
`present/present.c` and the headless harness's three files), is the base of the new test (its harness `obj/exe/infra`).

## Result

D6fS-a is staged and READY_TO_BUILD.  In the DOS graphics in play, the DOS boxes that replace Windows windows (the tax
and luxuries rates and the other MenuZ boxes of dialogs 136 and 145, the message boxes) and the DOS drop-downs that
replace the Windows menus no longer let any pixel of the Windows window or popup show: not beside the box while it is
open (the boxes and drop-downs are now as large as their content, as DOS draws them) and not at any moment while it
closes (the user's report of 2026-10-17).  The box goes at once when it closes; until the Windows windows beneath have
repainted the screen where the box was, the A frame keeps the DOS picture of that moment there.  Privately (the tree
with D7c and DBL + the stage): three variants built without a warning, every unit program passes, the headless test over
every presented A frame (seven f6s cases with every damaged tick presented) passes with 0 Windows pixels in any frame
and fails on the base (the tax box's close: up to 58,197 pixels of dialog 136 in one frame), `EXT_ADAPT_OK checks
232`, EXT_FRAMES_OK, ZOOM_OK, and the AGENT-RULES checks as the tree's.

## Status

READY_TO_BUILD.  Built: the covers (the hidden set of Windows windows and popups, their underlay at the bottom of the
A canvas and their lifetime), the held A rectangles of the closing covers, the A consumers' regions without the hidden
windows (the DOS map element, the zoom layer, D6e's elements, the bar), the zoom layer's M_dos under a closing cover,
the MenuZ box's close at its first item control's destruction, the DOS sizes (Choices D6f-2 and D6f-6 reversed), the
neutral point for a press in a hidden popup outside its drop-down, the read-only w16 queries they need, and the test
infrastructure (`PRESENT_TICK_EVERY`, the harness's `--tick-period-us`).  Not in this unit (D6fS-b): the 2x bar, the
DOS menu contents and ORDERS, the item map and its gaps, the keys, H2's highlight, M2's mouse model, the 184 boundary,
Options open after a toggle.  No `PDOS_AS` / `PDOS_AA` bit is used or widened by D6fS-a (`PDOS_AA` 0x80000000 is kept
for D6fS-b).  None of UX5b's files (`pdos_tl.h`, `pdos_birth.c/.h`, `pdos_seq.c/.h`, `test_pdos_aspect.c`,
`test_pdos_seq.c`, `ext_aspect.py`, test.cmd) is touched; build.cmd and test.cmd are unchanged (no
`BUILD-TEST-ADDITIONS.md`).

## The user's report and its cause

The user (2026-10-17): "DOS game popup windows such as but not limited to 'Tax Rate' displays Windows counterparts
while closing themselves momentarily behind them."  Required: every box kind fixed; a headless test over every
presented A frame around the close that fails on the base; the user check "closing the tax box and other DOS boxes
shows no Windows dialog at any moment".

**Cause (DOS oracle: none; the port's own frames, a private research build with a tick dump per presented frame,
`build/d6fs-stage/obj/diag`, runs `close-ret-t1` and `close-esc-t1`).**  Ctrl+T, then Return (or Escape), in S3 at
55,500 ms: frame 663 shows the DOS box with its header only (MenuZ destroys its item controls 500.. before it hides its
dialog, and D6f redrew the box from the controls left: none); frames 664 and 665 show the Windows dialog 136 whole (D6f
dropped the A box at the dialog's OBS_WND_HIDE, but the core frame still held the dialog's pixels until the windows
beneath had repainted the area, and nothing covered them any more: under Choice D6f-6 only the box, as large as the
dialog, had hidden them).  The same for the luxuries rate, the revolution question and the message boxes (#MsgBox,
the Game Help box), and for the drop-downs in a smaller way (a drop-down at least its popup's size hid the popup while
it was open; when the loop closed, the popup's saved pixels came back at once, so no frame showed it there; with the DOS
sizes, the popup would show beside the drop-down: hidden by the covers below).

## Design and decisions

### The DOS sizes (the user's revision item 6; Choices D6f-2 and D6f-6 reversed)

* **DOS listing.**  The menu box R:1D05:0000 sizes itself from its content: R:1D05:059D..05A7 sets its right edge
  [DE0E] = x + [D4C8] + 8 ([D4C8] the widest line's width), R:1D05:05AA..05B7 its bottom = y + lines x [2FA4] + 6 (the
  line height [2FA4]); the outline is drawn around that rectangle (R:1D05:09F0..09FD and its callee R:1D05:0A05).  D5b's
  `pdos_menubox_layout` (unchanged) computes the same rectangle; the drawn box is right - x + 3 wide and lines x h + 9
  high with its outline (D5b).  The tax box: R:0403:35CE.. writes "Select new Tax rate" and one line per rate the
  government allows into DGROUP:BA06, R:0403:367C sets [2F9A] to the current rate, R:0403:368B calls R:0238:001E
  (BA06, x 100, y 80), which calls R:1D05; a result of -1 (Escape) leaves the rates (R:0403:3696..369C).  No DOS box is
  larger than its lines.
* **Built.**  `pdos_reskin.c`'s `min_size` (Choice D6f-2: a drop-down at least its popup's size with the 2-pixel shadow)
  and `min_size_win` (Choice D6f-6: an A box at least its Windows window's size at 2x) are removed, with `PdosRSpec`'s
  `min_w` / `min_h` and the redraw when the Windows window's size changed.  `PdosRPlace.win` stays (the diagnostics and
  the hidden window's rectangle).  Every box and drop-down is as large as its content, as before D6f.
* What showed beside the smaller box (the rest of the Windows window or popup) is hidden by the covers below.

### The covers (the hidden set; inferred design under the user's rule)

* **Members.**  A Windows popup whose DOS drop-down is shown (the menu loop's levels 1.. that `drops_update` replaces;
  the system menu, which has no drop-down, is not a member), and a Windows window whose DOS box replaces it on the A
  canvas: a message box (#MsgBox) and the dialog of a MenuZ box of dialogs 136 and 145 bound to a re-skin row (plain
  and help templates).  A window joins at its OBS_WND_SHOW, which w16 sends before the window's first drawing
  (`user_wnd.c` show_sequence), a popup when its drop-down is first drawn.
* **The underlay.**  For each member, the screen pixels that lay under it when it appeared: a popup's are the pixels the
  menu loop saved under it (`save_under`, read through the new `w16q_menu_saved`; the popup with its shadow), a
  window's are the virtual screen under its window rectangle at its OBS_WND_SHOW (`w16q_screen`).  They are kept as w16
  indices in one screen-sized surface; a pixel already under an earlier member keeps that member's value (what lay
  under both).  The underlay is one A element, `PDOS_R_COVER_ID` (0xFF20), composed with the core's palette (a copy of
  `w16q_system_rgb`, updated at each core present) directly over the A frame's base and below every other A element
  (`pdos_compose_elem_set_under`, new: a new element inserted first), clipped to the members' rectangles (at most
  `PDOS_R_COVERS` = 12: seven popup levels, four boxes' windows and a spare; an open beyond refused, counted).
* **The A consumers draw under it.**  The DOS art that lies on A where a hidden window is (the DOS map element, the zoom
  layer, D6e's World Map, Status and unit panel elements, the bar) is clipped by the visible regions of their Windows
  windows; those regions now leave the hidden windows and every popup out of the computation
  (`w16q_wnd_vis_skip` / `w16q_wnd_client_vis_skip`, new), so the DOS art is drawn over the underlay there, as the screen
  beneath would show it.  A popup that is not hidden (the system menu) is excluded from each of those elements as before,
  now by its exact three rectangles (the frame and the two 2-pixel shadow strips, as `user_menutrack.c` takes them out of
  every window's visible region): `pdos_reskin_popups_shown`.  The DOS shadows (Wn_dos, P_dos) already hold the beneath
  picture under a popup (w16 clips window output away from popups); under a window, they hold what the windows beneath
  drew before the window covered them.  The mirror check (`pmap_check.c`) keeps the real regions.
* **Closing.**  A window hidden (OBS_WND_HIDE) or destroyed (OBS_WND_DESTROY), a popup closed: its DOS box goes at once
  (DOS closes its box at once; the box's drop happens before the cover is marked) and its cover becomes closing.  A
  closing cover stays until a core present at which no shown window meeting its rectangle has an update region pending
  (`w16q_upd_pending`, new): then the windows beneath have repainted the area and the core frame shows the screen
  beneath again.  A closing window's handle is no longer skipped (it may be reused).
* **The hold.**  While a cover is closing, the A frame holds its rectangle (`pdos_compose_hold`, new): a held pixel keeps
  what the A composition showed at the moment the hold was set; what changes beneath (the core frame, an element) is
  composed when the hold ends.  Setting a new set first composes everything pending, so the held picture is the DOS
  picture of the moment of the close with the box removed.  Without the hold, the frames between the close and the
  release showed the repainting in progress through the DOS shadows (the private stage run before the hold: the Game
  Help box's close showed an erased map square, then the unit, then the squares, at 56,301,650, 56,303,700 and
  56,305,750 us, between two core frames).  A new box opening inside a held rectangle shows at the release (within a
  core present).
* **The hold with the DOS graphics hidden (7.4).**  The covers live whether the DOS graphics are shown or not (the
  observer events and core presents reach every registered profile), and so does the hold: setting it composes the
  private A frame then, with the core frame of the last frame composed or, before any, with the one the profile names
  at each core present (`pdos_compose_set_core(present_core_xrgb())` in `pdos_profile.c`'s core-present hook; the
  include rule lets only `pdos_profile.c` include `present.h`).  So a profile sample or a switch during a hold shows
  the same held picture as the shown DOS graphics would.  A private A frame made anew (its first composition, a new
  size) composes its held rectangles too (no earlier picture to keep; before, they would have stayed black).
* **The zoom layer's M_dos.**  M_dos (the layer's source, `pmap_dos.c` md_fill) takes P_dos's pixels instead of Wn_dos's
  under a closing cover (Wn_dos there is the map window's repaint in progress); `pdos_r_cover_gen` changes whenever the
  closing covers may have changed, and M_dos is filled again then.
* **Not hidden.**  Every other Windows window or dialog (the file dialogs, Find City's list, the city screen, ...) and
  the system menu.  A new screen size drops every cover (F105).  `pdos_reskin_reset` drops them all.

### The MenuZ box's close (inferred)

MenuZ destroys its item controls (ids 500..520) before it hides its dialog.  The DOS box of a MenuZ dialog of 136 or 145
on A now goes at the first OBS_WND_DESTROY of one of its item controls (`item_gone`), so no frame shows the box without
its rows (the research run's frame 663).  DOS closes its box at once on the choice (R:1D05's loop returns; the caller
redraws the screen beneath, R:0238:1B44 / R:0866:25D7 for the menus): the same picture.

### A press in a hidden popup outside its drop-down

The drop-down is now smaller than its popup.  A press or move at a point of a hidden popup outside every DOS drop-down
is passed to the menu loop as a press at a screen corner off the bar and every popup (`pdos_reskin_menu_point` returns
3): the Windows menu loop ends at a press outside its popups and eats it (`user_menutrack.c`), and a move there selects
nothing.  In DOS the box's row is -1 when the mouse is outside the box's x range (DOS listing R:1D05:01A1..01B2); the
press-outside behaviour of the whole DOS box loop is D6fS-b's (ruling 2, M2, keeps the w16 loop's click model).
Inferred.

### Test infrastructure

* `present/profile.h`: `PRESENT_TICK_EVERY` (a tick clock mode: no throttle, every damaged tick presented);
  `present.c` handles it and `present_set_tick_clock` now also restarts the throttle (`g_tick_last = 0`).
* The headless harness's `--tick-period-us N` (0..1000000; 0: `PRESENT_TICK_EVERY`), set after `present_reset`: with
  `--presented 2` (tick dumps) every presented A frame of the close is dumped.  Not given: the 16,667 us virtual
  throttle as before (P0: the core's input, frames and events equal with and without it, below).

### Choices

* **D6fS-a-1** the hidden set: the replaced popups and the windows of the A boxes (#MsgBox, MenuZ 136/145); every other
  Windows window shows as before.
* **D6fS-a-2** a closing cover holds the A picture of the close until the core's screen beneath is repainted (no
  stage of the repainting shows); a box opening inside a held area appears at the release.
* **D6fS-a-3** a press in a hidden popup outside its drop-down ends the menu loop (the neutral point).
* **D6fS-a-4** the MenuZ box goes with its first item control.

## Deviations and limits

* Choices D6f-2 and D6f-6 reversed (above): the boxes and drop-downs are DOS-sized; the rest of their Windows window
  or popup shows what lay beneath (the underlay and the A consumers' DOS art), not the box's texture.
* The underlay of a window is the virtual screen at its OBS_WND_SHOW: Windows-graphics pixels where no DOS art is drawn
  over them (in play the map, the World Map, the Status window and the unit panel have DOS art; a Windows-only area
  beneath a box, such as a part of the desktop, shows its Windows pixels as before the box opened).
* A closing cover is released at the first core present with no update region pending over it; a core present made
  inside the repainting window's WM_PAINT after BeginPaint (the region already validated, the drawing not finished)
  would release it early (inferred; not seen in the runs).
* At most four non-hidden popups' exclusions per element (`PDOS_EXCL_MAX` 12, three rectangles each); a deeper system
  menu leaves its fifth level's exclusion out.
* `pdos_reskin_menu_point`'s neutral point is a screen corner (0, h - 1 first) off the bar and every popup.

## What was built

* `platform/w16` (read-only queries; core, rt and w16 behaviour unchanged, P0): `w16q_wnd_vis_skip`,
  `w16q_wnd_client_vis_skip` (`user_wnd.c` `w16_wnd_vis_skip`: the visible region computed without the overlays and
  the skipped top-level windows with their descendants; -1 for an invalid handle), `w16q_upd_pending`
  (`w16_wnd_upd_pending`: a shown window meeting a rectangle with a non-empty update region), `w16q_menu_saved`
  (`user_menutrack.c` `w16_menu_track_saved`: a level's saved pixels).
* `present/profile.h`, `present/present.c`: `PRESENT_TICK_EVERY`.
* `present/dos/pdos_compose.c/.h`: `pdos_compose_elem_set_under`; `pdos_compose_hold` (`PDOS_HOLD_MAX` 12; held rects
  in the private A composition, the deferred damage recomposed at the release; a composition made anew holds nothing);
  `pdos_compose_set_core`.
* `present/dos/pdos_profile.c`: one line in the core-present hook (`pdos_compose_set_core(present_core_xrgb())`).
* `tests/harness/obs_lint.py`: the three new internal getters (`w16_wnd_vis_skip`, `w16_wnd_upd_pending`,
  `w16_menu_track_saved`) in `REVIEWED_CALLS`, with their review note (read only, no allocation, no side effect).
* `present/dos/pdos_reskin.c/.h`: the covers (`pdos_r_cover_open/close/release/palette`, `pdos_r_covers`,
  `pdos_r_cover_gen`, `pdos_reskin_hidden_wnds`, `pdos_reskin_popup_hidden`, `pdos_reskin_popups_shown`), their
  observer side (`wnd_cover` at OBS_WND_SHOW, `popup_cover` in `drops_update`, `item_gone`, the close before the cover
  in HIDE / DESTROY, the release at each core present), the removed least sizes, the neutral point, the bar's region
  without the hidden windows; the `preskin` diag line's new fields `drop2_ax`, `drop2_ay`, `drop2_w`, `drop2_hh`,
  `popup_l/t/r/b`, `popup2_l/t/r/b` (the last level-1 and level-2 hidden popups with their shadow), `cover_opens`,
  `cover_closes`, `cover_releases`, `cover_kept` (core presents at which a closing cover stayed) and `cover_full`.
* `present/dos/pdos_aplay.c`: D6e's elements' regions without the hidden windows, the non-hidden popups excluded.
* `present/map`: `pmap.h` (`PmapMap` `a_set`, `navis`, `avis`: the map window's region without the hidden windows),
  `pmap_inview.c` (filled), `pmap_int.h` / `pmap_check.c` (`pmap_a_vis`, `pmap_screen_exclusions_a`), `pmap_dos.c` (the
  element's clip, M_dos under a closing cover, `cgen`), `pmap_layer.c` (the layer's clip in the DOS profile).
* `tests/headless/harness.c/.h`, `harness_main.c`: `--tick-period-us`.
* Tests: `test_pdos_reskin.c`, `test_pdos_compose.c`, `test_observer.c`, `test_present.c`, `test_map.c`,
  `tests/harness/ext_adapt.py` (below).

## Tests

* **The user's report: every presented A frame around the close (`tests/harness/ext_adapt.py`, `d6fs_runs`, after
  `d6f_runs`).**  Seven cases in play in the DOS graphics (S3's lines in host form, the profile chord at 40,000 ms,
  `--tick-period-us 0 --presented 2 --dump-presented`: every tick with damage is presented and dumped, so no frame the
  16,667 us throttle would skip is lost), each opening a box at 55,500 ms and closing it before S3's Space at 58,000
  ms: f6s-tax-ret (Ctrl+T, Return), f6s-tax-esc (Ctrl+T, Escape), f6s-lux-esc (Ctrl+L, Escape), f6s-rev-esc (Ctrl+R,
  Escape; dialog 145), f6s-msgbox (Alt+H, g: the Game Help #MsgBox; Return), f6s-game (Alt+G; Escape twice) and
  f6s-options (Alt+F, O: levels 1 and 2; Escape three times).  Per case, four checks:
  1. the run ends (exit 0, one switch) and the covers opened and were released (`preskin` `cover_opens`,
     `cover_releases`, `cover_kept`);
  2. **every frame of the transitions** (250 ms after each step, 700 ms after the last; the opening's not for the two
     cases whose opening passes through another menu) shows over the hidden Windows window or popups (`abox_win_*`,
     `popup*`, `popup2*`) at every pixel a value that some settled state shows there (before the first step, between
     the steps, after the close) or, where the map animates, one of its animated colours: a pixel within 4 A pixels
     (2 DOS pixels) of one that the input-free settled frames (before the opening, after the close) show changing, in
     a colour they show changing (the blinking unit and the cycling colours can show, at a pixel the box covered, a
     phase no settled frame caught there; counted apart).  The Windows window or popup covers far more than those
     places: on the base the message box's close shows 12,280 other pixels (2,116 accepted there); a colour-only rule
     (any animated colour anywhere) was too lax - the map's ten animated colours include black, white and grays, and
     it let the base's message box pass;
  3. while the box is open, the hidden window's or popups' pixels beside the DOS element(s) are those of the screen
     before and after (the same rule for the animated places);
  4. the DOS box or drop-down is as large as its content (`preskin` `*_w`, `*_hh` against right - x + 3 and lines x
     h + 9, at 2x).
  Plus P0: f6s-tax-esc's run without `--tick-period-us` and `--dump-presented` (the 16,667 us throttle) has the same
  core input, frames and events (`trace` comparison) as with it.
* **f6-zcover (D6f's z-order check, rewritten for D6fS-a):** for the tax box at -1 and +1, the hidden dialog's part
  beside the smaller box: the last view shows there each pixel as one of the six views before the box opened (the
  zoomed map as before; none of the dialog), and at +1 the layer is what shows where the A frame differs from those
  views (1290 pixels in the run; at -1 in this layout the layer and the A frame agree there).  The drop-down case
  states the content size.
* **Unit tests.**
  - `test_pdos_reskin.c`: `test_drop` (the drop-down 47 x 33, its content's size; the row-2 point; the neutral point:
    a point of a hidden popup outside the drop-down returns 3 with a screen corner off the bar and the popups),
    `test_awin` (the A box 35 x 33, its content's size, its A rectangles), `test_covers` (the underlay's values, an
    earlier cover's pixel kept, an element above the underlay, the palette change, close / kept / release with the
    held core pixel, the screen clip, no source, a new screen size, `PDOS_R_COVERS` in use, the reset).
  - `test_pdos_compose.c`: `test_a_under` (an element below the others, its z position kept when set again),
    `test_a_hold` (held pixels kept, those outside composed, a core change inside not composed, given back with the
    damage, a new hold composing what changed first, a new size composing its held rectangles, the hold before any
    composed frame composing with the core frame `pdos_compose_set_core` named).
  - `test_observer.c`: `w16q_menu_saved` at OBS_MENU_OPEN (the popup's frame with its shadow, the screen's pixels from
    before the loop; nothing for level 0, depth + 1 or without a loop), the popup's centre out of `w16q_wnd_vis` and
    in `w16q_wnd_vis_skip` (no overlay), `w16q_wnd_vis_skip` (nothing skipped: `w16q_wnd_vis`'s region; a window
    skipped: the child beneath it visible there), `w16q_wnd_client_vis_skip` (the same, with the same origin), an
    invalid handle (-1, the region cleared), `w16q_upd_pending` (none after the pump; over an invalidated window and
    not off it; none once painted).
  - `test_present.c`: `PRESENT_TICK_EVERY` (every damaged tick presented, none without damage; back to the virtual
    throttle).
  - `test_map.c`: M_dos under a closing cover (P_dos's pixels there, Wn_dos's elsewhere; released: Wn_dos's).
* **On the base** (the tree with only the test infrastructure, `obj/src-infra`, harness `obj/exe/infra`; the same
  staged ext_adapt.py): every f6s case fails (below), as the report requires.

## Results (private, `build/d6fsa-stage/obj/`)

On the overlay of the tree after UX5b's landing (`build/ux5b-status.txt` ALL_GREEN, RELEASE_OK 10:56 UTC; UX5b changed
none of the staged files' bases), D7c's (`build/d7c-status.txt`) and DBL's (`build/dbl-status.txt` ALL_GREEN 12:28:57
UTC, RELEASE_OK 12:35:29 UTC; the rebased files above) + the staged files, built with build.cmd's flags:

* **Builds** (`obj/final3.sh`, `obj/run/final4.txt`, logs `obj/final-b-*.log`): Checked, CheckedNoObs and Release
  BUILD_OK, `portable sources checked: 299` (the tree's with DBL; unchanged by D6fS-a), no warning, no error.
* **Unit programs**, every program of each variant (`obj/ut.sh`, `obj/run/final-ut-*.txt`): `UT Checked failed=0`,
  `UT CheckedNoObs failed=0`, `UT Release failed=0` (50 programs each).  Changed counts (Checked; the tree's from
  `build/dbl-2-test-checked.log`, the same as after D7c): test_map 338 -> 342, test_observer 115 -> 126, test_pdos_compose 68 -> 90,
  test_pdos_reskin 121 -> 147, test_present 951 -> 956; every other program as the tree's.  CheckedNoObs: test_map 1,
  test_observer 1 (compiled out, as the tree's), test_pdos_compose 90, test_pdos_reskin 136 (the observer-only covers
  checks compiled out), test_present 956.  Release: test_map 342, test_observer 115, test_pdos_compose 90,
  test_pdos_reskin 147, test_present 956 (the slot runs no Release unit programs, so the tree's Release counts are not
  recorded for comparison).
* **The f6s cases** (the full staged ext_adapt.py, `obj/runadapt_full.py`, harness `obj/exe/s6` = the overlay's
  Checked harness with D7c and DBL, root `obj/full3`, `obj/run-full3.txt`): `EXT_ADAPT_OK checks 232` (the tree's 203
  after DBL + 29: seven cases of four checks and the P0 line; every earlier line passes, D7c's d7c-world five included,
  f6-zcover's three with their D6fS-a texts).  Per case: the covers opened and released (the message box twice: its
  Help drop-down's popup and its window; one core present kept the window's cover while a repaint was pending); every
  transition frame 0 other pixels over the hidden windows (17 or 18 frames per rate or question box, 13 for the message
  box's close: DBL's blink phases add presented frames; f6s-msgbox: 164 pixels in the map's animated colours where it
  animates (752 pixels change in the settled frames), at the blinking unit's square under the box: the phases its
  close and the repaint after it show there; the other cases 0); while open 0 other pixels beside the elements; the
  sizes: the tax box 12 lines (282 x 210 A pixels, its Windows dialog 234 x 277), the luxuries box 7 lines (338 x 130;
  dialog 255 x 187), the revolution question 3 lines (454 x 66; dialog 272 x 115), the Game Help box 5 lines (564 x
  98; window 482 x 135), the GAME drop-down 11 lines (186 x 194; popup with shadow 183 x 172), Options (level 2)
  shown; P0: the tax case with and without `--tick-period-us 0` has the same core input (39), frames (667) and events (104).  (Before
  DBL, harness `obj/exe/s5`, `obj/run-full2.txt`: the same 29 results with 13 or 14 transition frames per box and 108
  message-box pixels in the animated colours; before D7c, harness `obj/exe/s4`, `obj/run-full.txt`, the colour-only
  animation rule: the same 29 results, `EXT_ADAPT_OK checks 227`.)
* **On the base** (`obj/exe/infra3`: the tree with D7c and DBL + `present/profile.h`, `present/present.c` and the
  harness's three files only, overlay `obj/src-infra`; the same staged ext_adapt.py's D6fS-a and D6f runs,
  `obj/runadapt.py ... sf`, root `obj/base5`, `obj/run-base5.txt`): `RUNADAPT checks 59 failed 21` (as before DBL,
  `obj/base4`).  Every f6s case fails: its first
  line (no `cover_*` fields: no covers); the boxes' transitions show the Windows window - the tax box's close 69,965
  other pixels (58,197 in one frame, 204,102..437,377: the whole dialog 136), the luxuries box 50,982, the revolution
  question 33,378, the Game Help box 12,280 (6,140 in one frame; 2,116 accepted where the map animates); the sizes
  (the base's boxes at their Windows windows' sizes: 246 x 278, 302 x 188, 454 x 116, 564 x 136); the two drop-down
  cases cannot measure (the base has no `popup*` fields; D6f's drop-down covered its popup at least, so the base
  shows no popup pixel there: these cases guard D6fS-a's smaller drop-downs); f6-zcover-m1 and -p1 fail (D6f's box
  as large as its dialog, 282 x 278 at A 203,101..485,379, leaves nothing of the dialog beside it to check: the
  criterion needs the DOS size); f6-zcover-menu passes on the base (the GAME drop-down's content is larger than its
  popup).  Before D7c (`obj/exe/infra`, `obj/run-base3.txt`, the colour-only animation rule): 20 failures, the Game
  Help box's transition passing with 14,396 pixels accepted in the map's animated colours anywhere - the reason for
  the rule's restriction to the places where the map animates.
* **ext_frames** (the tree's script with the stage's harness `obj/exe/s6`, `obj/frames_priv.py`, root `obj/frames3`,
  `obj/run-frames3.txt`): EXT_FRAMES_OK, 16 PASS lines (start 299, s3 719, birth 2049 sample lines identical in A, A', B
  and C: the covers and the hold do not depend on the profile shown).
* **ext_zoom** (the tree's script, `--profiles dos,sw -j 4 --exe obj/exe/s6/civ_harness.exe --root obj/zoom3`,
  `obj/run-zoom3.txt`): `ZOOM_OK combinations 32 runs 44 samples 240 map comparisons 6 centre runs 2 mzi runs 6 mzs
  runs 2 not zoomed 22/249`, 0 FAIL lines: the DOS and Windows profiles' golden lines (the DOS ones DBL's) unchanged;
  the MZS runs (the menu and the dialog over the zoomed map) pass with the covers (64 views each).  The other three
  profiles' runs are not affected by D6fS-a (the covers and holds are the DOS profile's) and were not run privately.
  (Before DBL, harness `obj/exe/s4`, `obj/run-zoom.txt`: the same result.)
* **ext_dbl** (the tree's script with `obj/exe/s6`, root `obj/dbl3`, `obj/run-dbl3.txt`): `EXT_DBL_OK checks 4`, as the
  tree's.
* **Checks** on the overlay (`obj/run/final4.txt`): `OBS_LINT_OK files 130 probes 203 callsites 101` (the three new
  getters reviewed), `ADAPT_OK rows 123 steps 25`, `PASS pdos_scene_check: 1084 checks, 141 scene rows, 10 font rows,
  0 failed`, `OBS_TABLES_OK probes 203 sites 101`, `REGISTRY_OK` (the include rule: only `pdos_profile.c` includes
  `present.h`), `NODOS_OK` (635 files scanned, 0 hits), all as the tree's after DBL
  (`build/dbl-2-test-checked.log`); no present/dos file includes `input.h` or `<stdio.h>`.
* **Strict compiles** (`obj/cc.cmd`: c11 and c17 /W4 /WX and the clang C99 parse with warnings as errors) of every
  changed C file, the 19 of `obj/final3.sh` (pdos_profile.c included), in Checked, CheckedNoObs and Release: `CC_OK`
  in each (`obj/run/final-cc-*.txt`).
* Not run privately: ext_p0 (no core, rt or w16 behaviour changed; the P0 line above), ext_mirror (`pmap_check.c`
  keeps the real regions), ext_g1, the Win32-headless sections.

## Expected changes at the build slot

Copy-in: the 28 staged files at their tree paths and this record as `docs/ext-D6fS-a-record.md` (`BASE-SHA256.txt`
lists the bases and the staged copies' hashes; CRLF kept for `present/dos/pdos_profile.c`, the headless harness's
three files and `tests/test_pdos_compose.c`).  No build.cmd or test.cmd change.  Against the tree after D7j
(`build/d7j-2-test-checked.log`; the counts below were D7c's and DBL's too: D7j changed none of them but ext-adapt's
203 -> 208), test.cmd Checked (the predictions: `build/d6fsa-prep/predictions.txt`):

* build: `BUILD_OK`, `portable sources checked: 300` (D7j's; unchanged by D6fS-a), no warning;
* unit programs: test_map 338 -> 342, test_observer 115 -> 126, test_pdos_compose 68 -> 90, test_pdos_reskin 121 ->
  147, test_present 951 -> 956; every other program unchanged;
* `EXT_ADAPT_OK checks 208` -> `237` (after DBL privately: 203 -> 232): 29 new lines (f6s-tax-ret, f6s-tax-esc, f6s-lux-esc, f6s-rev-esc, f6s-msgbox,
  f6s-game, f6s-options: four each; the P0 line `f6s-tax-esc with --tick-period-us 0 equals its run with the 16,667 us
  throttle`); f6-zcover-m1, -p1 and -menu still PASS with their new texts ("its hidden Windows dialog ... beside the
  box: of its N client pixels 0 not as in the 6 views before the box, ...", "the drop-down as large as its content");
  eight more harness runs (the seven f6s cases with `--tick-period-us 0 --dump-presented`, and the P0 run);
* `EXT_FRAMES_OK`, `ZOOM_OK` (no golden changes), `EXT_DBL_OK checks 4`, `OBS_LINT_OK files 132 probes 203
  callsites 101` (D7j's 132; 130 after DBL), `OBS_TABLES_OK probes 203 sites 101`, `ADAPT_OK rows 130 steps 25`
  (D7j's 130; 123 after DBL), `PASS pdos_scene_check: 1084 checks`, `REGISTRY_OK`, `NODOS_OK`: unchanged;
* presentation-diag.log's `preskin` line: the new fields (`drop2_*`, `popup_*`, `popup2_*`, `cover_opens`,
  `cover_closes`, `cover_releases`, `cover_kept`, `cover_full`) after the existing ones;
* ext_p0, ext_mirror, ext_g1 and the Win32-headless sections: unchanged results expected (no core, rt or w16
  behaviour changed; `pmap_check.c` keeps the real visible regions; the Win32 host never uses `PRESENT_TICK_EVERY`);
  not run privately.

Release build: `BUILD_OK` (built privately with the same flags).

## Rebase notes

* Every staged file's base is in `BASE-SHA256.txt` and was equal to the tree when it was written.  If a file changes in
  the tree before the copy-in, its D6fS-a edits are blocks marked "extension D6fS-a" (three-way merge on the base):
  - `platform/w16`: appended functions (`user_wnd.c` `w16_wnd_vis_skip`, `w16_wnd_upd_pending`; `user_menutrack.c`
    `w16_menu_track_saved`) and one block in each header (`w16_obs.h`: the public queries before the internal
    section, the internal prototypes after it); `w16_obs.c`: the four query wrappers appended.
  - `present/dos/pdos_reskin.c/.h`: one D6fS-a section each (the covers) plus the marked edits in `on_event`,
    `drops_update`, `bar_update`, `pdos_reskin_present`, `pdos_reskin_menu_point`, the diag line and the removed
    `min_size` / `min_size_win`; `pdos_compose.c/.h`: `elem_set_at` (shared by `elem_set` and `elem_set_under`), the
    hold statics, `compose_a` / `compose_a_held` split out of `refresh_a`, `pdos_compose_hold`, `frame_of`'s
    `g_last_core`.
  - `present/map`: marked lines in `pmap.h`, `pmap_int.h`, `pmap_inview.c`, `pmap_check.c`, `pmap_dos.c` (`ws_run`,
    `cgen`), `pmap_layer.c` (`layer_vis`, `make_clip`'s profile argument).
  - `present/dos/pdos_aplay.c`: the include and `def_wnd`'s region (D7 tracks may edit other parts of the file).
  - `present/dos/pdos_profile.c`: one line in `dos_on_core_present` (CRLF kept).
  - `tests/harness/obs_lint.py`: one block of three names in `REVIEWED_CALLS`.
  - `tests/harness/ext_adapt.py`: the D6fS-a block after "# ---- end of extension D6f ----", one call line in `main()`
    after `d6f_runs`, and f6_zcover's marked lines inside D6f's block; the comment in the calibration helper (line
    about 712).  A D7 track's block elsewhere in the file merges without conflict (separable blocks).
  - `tests/headless/harness.c/.h`, `harness_main.c`: the `tick_period_us` field, its option and its one call after
    `present_set_options` (CRLF kept).
  - Tests: appended functions and their calls (`test_pdos_reskin.c` `test_covers`, `test_pdos_compose.c`
    `test_a_under` / `test_a_hold`, `test_observer.c`'s D6fS-a section, `test_present.c`'s EVERY block, `test_map.c`'s
    block in the MZS test).
* UX5b touched none of these files.  D7c changed `present/dos/pdos_profile.c` and `tests/harness/ext_adapt.py`, DBL
  `present/dos/pdos_aplay.c`, `present/dos/pdos_profile.c`, `present/map/pmap_dos.c`, `present/map/pmap_int.h` and
  `present/map/pmap_inview.c`: the staged copies are already rebased on their landed files (above).  DBL writes the
  active unit's blink phase into Wn_dos at every core present and tick; under a closing cover M_dos takes P_dos (the
  core's own drawing, D6fS-a), so for the moment a cover is closing over the blinking square that square shows the
  core's last picture, then DBL's phase again.  D6fS-b stacks on this stage: its bases are these
  staged copies; a rebase of D6fS-a carries over to D6fS-b mechanically.
* D7j's landing (copy-in 12:54:30 UTC, `build/d7j-prep/landed.sha256`; ALL_GREEN 13:29:28 UTC, RELEASE_OK 13:34:07
  UTC) changed three staged files' bases: `present/dos/pdos_profile.c`, `tests/harness/ext_adapt.py` and
  `tests/headless/harness.c`.  The three-way merge of the D6fS-a edits (base: the tree before D7j, equal to
  `build/d7j-prep/tree-before/` and to this stage's bases) onto D7j's landed copies is clean, prepared in
  `obj/rebase-d7j/` while D7j's cycle ran: each is a pure union (D6fS-a's 1, 328 and 5 changed lines and D7j's 11,
  135 and 2, line endings kept: CRLF, LF, CRLF).  After D7j's RELEASE_OK, `build/d6fsa-prep/rebase_d7j.py --write`
  (13:35:17 UTC) checked the tree's three files equal to D7j's landed hashes and the staged copies equal to the
  pre-merge ones, kept those in `obj/premerge-d7j/`, put the merged files into the stage and their bases (D7j's
  landed files) into `obj/base/`; `BASE-SHA256.txt` was written again (29 rows, every base equal to the tree).
  `EXT_ADAPT_OK` is the tree's count after D7j (208) + 29.
* `PDOS_AA` 0x80000000 stays free for D6fS-b (the orchestrator's allocation); D6fS-a widens no `PDOS_AS` / `PDOS_AA`
  type.  D7l's stage (`build/d7l-stage/present/dos/pdos_adapt.h`) defines `PDOS_AA_LAUNCH 0x80000000u` too: the same
  bit; one of the two must move (D6fS-b reports it).

## What the user checks

On the coordinator's user build `build/user-builds/d6fsa/` (`civ64.exe`, DOS files present), in play (load a saved game
or start a new one) with the DOS graphics (`--graphics dos` or Ctrl+Shift+Backspace), the main map window active.  The
menu bar and the drop-downs' contents are still D6f's in this build (D6fS-b changes them):

* **D6fSa-1** (the user's report of 2026-10-17: no Windows dialog while a DOS box closes).  Press Ctrl+T (the tax rate
  box) and close it with Return; open it again and close it with Escape; Ctrl+L (the luxuries rate), then Escape;
  Ctrl+R (the revolution question), then Escape; HELP > Game Help (the message box), then Return; GAME (Alt+G), then
  Escape twice; GAME > Options, then Escape three times.  Watch the place of each box and menu while it closes:
  **closing the tax box and other DOS boxes shows no Windows dialog at any moment** - no Windows dialog, message box
  or menu (its gray face, title bar, OK button, radio buttons, Windows text or menu shadow) appears there, not even
  for an instant, and no DOS box without its rows; the box goes at once and the map beneath is there.
* **D6fSa-2** (the DOS sizes).  The tax and luxuries boxes, the revolution question, the Game Help box and the
  drop-downs are as large as their text, with the DOS margins (no empty band below the last row or right of the
  longest line), as in the DOS game.  Beside and below each, where the larger Windows dialog or menu now lies hidden,
  the map (or whatever was there before the box opened) shows - never a part of the Windows window - while the box
  is open and after it closes.
* **D6fSa-3** (a click beside a smaller drop-down).  Open GAME, then click on the map just right of the DOS drop-down
  or just below it (where the larger Windows menu lies hidden): the menu closes and nothing is chosen.
* **D5-7, rewritten for D6fS-a (the box's size and its Windows dialog).**  Screen: in play with the DOS graphics press
  Ctrl+T (or `=`, or GAME > Tax Rate): the game's tax-rate menu (Windows dialog 136) appears as a DOS menu box at twice
  the size at the Windows dialog's place (gray box 7, bevel 15 and 8, black rows of 8 pixels in DOS font 1; textured as
  DOS draws in play), as large as its text as in DOS.  Up and Down move the bar; Return or Space choose the highlighted
  rate; a press on a row, a drag to another row and the release there choose that row; no Go Back or Cancel row.  A
  box near the screen's edge is moved fully inside.  **Escape closes the box and the tax rate stays as it was** (the
  status panel's rates unchanged), as DOS's Escape does; the same with Ctrl+L (the luxuries rate).  Nothing of the
  Windows dialog (its frame, its OK button, a radio item) shows beside or below the DOS box, or at any moment while it
  closes.  Build: `build/user-builds/d6fsa/`.  (Which row is highlighted and when: D6fS-b's rewrite, ruling H2.)
* **D6f-8, rewritten (the zoom with DOS menus and boxes).**  Zoom the map to -1 (Ctrl+Shift+Minus) and, separately, +1
  (Ctrl+Shift+Plus); open the GAME menu and, separately, the tax box (Ctrl+T) where they lie over the map: the DOS
  drop-down and box are drawn whole, no part covered by the zoomed map; the zoomed map shows around them, also where
  the larger Windows menu or dialog lies hidden beside them; closing them leaves no remnant of the box, the Windows
  dialog or the Windows menu at any moment.

Not part of this check: the menu bar's look and titles, the drop-downs' contents, the highlight, the keys (D6fS-b);
the city screen and the other in-game screens (D7).

## For the records

* **F-new-1 (FIDELITY):** the DOS boxes and drop-downs in play are as large as their content, as DOS's R:1D05 sizes
  them (R:1D05:059D..05B7; the tax box R:0403:35CE..368B): replaces D6f's entry (g) ("an A box at least its Windows
  window's size", Choice D6f-6) and Choice D6f-2 (a drop-down at least its popup's size).
* **F-new-2 (FIDELITY):** the Windows windows and popups the DOS boxes replace (the drop-downs' popups, #MsgBox, the
  dialogs of the MenuZ boxes of 136 and 145) are hidden from their show until the screen beneath them is repainted:
  their place shows the screen as it was when they appeared, with the DOS art of the windows beneath drawn over it.
  Where no DOS art lies beneath (a Windows-only area, such as a part of the desktop), that area shows its Windows
  pixels of the moment the box appeared (inferred; DOS has no window beneath its boxes).
* **F-new-3 (FIDELITY):** at a box's close the A frame keeps the DOS picture of that moment, the box removed, over the
  closed window until the windows beneath have repainted it (Choice D6fS-a-2); a box that opens there within that time
  shows at the release (one core present later).
* **F-new-4 (FIDELITY):** a press in a hidden popup outside its smaller DOS drop-down ends the menu loop without a
  choice (Choice D6fS-a-3; DOS: the row is -1 outside the box's x range, R:1D05:01A1..01B2; the whole click model is
  D6fS-b's, ruling 2 M2).
* **F-new-5 (FIDELITY):** a MenuZ box of dialogs 136 and 145 goes at the destruction of its first item control (Choice
  D6fS-a-4): no frame shows it without its rows.
* **DESIGN 12.9 "As implemented (D6fS-a)":** the covers (members, underlay `PDOS_R_COVER_ID` at the bottom of A,
  lifetime, the release at a core present without a pending update region), the hold (`pdos_compose_hold`), the A
  consumers' regions without the hidden windows (`w16q_wnd_vis_skip` / `w16q_wnd_client_vis_skip`,
  `pdos_reskin_popups_shown`), M_dos under a closing cover, the DOS sizes, the neutral point, `item_gone`; the
  read-only w16 queries `w16q_upd_pending` and `w16q_menu_saved`.  Draft B 11.2 / 11.3: Choices D6f-2 and D6f-6
  reversed.
* **RUNNING.md:** the harness's `--tick-period-us N` (0: every damaged tick presented, `PRESENT_TICK_EVERY`);
  presentation-diag.log's `preskin` new fields (`drop2_ax`, `drop2_ay`, `drop2_w`, `drop2_hh`, `popup_l/t/r/b`,
  `popup2_l/t/r/b`, `cover_opens`, `cover_closes`, `cover_releases`, `cover_kept`, `cover_full`); ext_adapt's f6s-*
  cases (f6s-tax-ret, f6s-tax-esc, f6s-lux-esc, f6s-rev-esc, f6s-msgbox, f6s-game, f6s-options, f6s-tax-esc-p0) and
  f6-zcover's D6fS-a criterion.
* **FEATURES.md:** the DOS boxes in play at their DOS sizes, with no Windows window around them or while they close
  (D6fS-a), with the runners above.
* **manual-checklist-ext.md:** D5-7 and D6f-8 rewritten as above (D6fS-b rewrites D5-7's highlight wording again, with
  D6-1, D6f-1, D6f-4, D6f-5 and D6f-7); new items D6fSa-1..D6fSa-3; user build `build/user-builds/d6fsa/`.
* **DOS-PROFILE.md:** no generated section changed (no adapter row, no observer site, no registry row); its prose on
  the play screen's boxes (D6f's) may note the DOS sizes and the hidden windows.
* Not edited by this unit: DESIGN.md, FIDELITY.md, STATUS.md, RUNNING.md, FEATURES.md, DOS-PROFILE.md,
  manual-checklist-ext.md, the D1 drafts and the D0 documents.

## Landing

D6fS-a landed alone at the build slot of session E4, 2026-10-17, after D7j's landing (its RELEASE_OK 13:34:07 UTC and
`build/user-builds/d7j/`), as the orchestrator ordered (D6fS-a accepted as staged; no docs pass in between: the joint
docs pass D7j + D6fS-a follows).  The user checks D6fSa-1..D6fSa-3 and the rewritten D5-7 and D6f-8 are in the user
build `d6fsa`.

* **Bases:** D7j's landing changed three staged files' bases (`present/dos/pdos_profile.c`,
  `tests/harness/ext_adapt.py`, `tests/headless/harness.c`); `build/d6fsa-prep/rebase_d7j.py --write` (13:35:17 UTC)
  checked the tree's three files equal to D7j's landed hashes, put the three-way merges (pure unions, Rebase notes)
  into the stage and their bases into `obj/base/`; `obj/mkbases.py` wrote `BASE-SHA256.txt` again (29 rows, every
  base equal to the tree, BASES problems 0).  `build/d6fsa-prep/land.py` rechecked every base (DRY_RUN_OK 29), took
  the snapshot `build/d6fsa-prep/before` (the tree's `build/test/Checked` outputs of D7j's cycle, 65 files) and
  `tree-before` (the replaced files), and copied in at 13:36:26 UTC (`landed.sha256`: the 28 files and this record;
  build.cmd and test.cmd unchanged; `landed-at.txt` "unit d6fsa").  Predictions `build/d6fsa-prep/predictions.txt`,
  written before the copy-in.
* **The three-step cycle** (`build/d6fsa-status.txt`): 1 `build.cmd checked` BUILD_OK 13:36:35..13:42:26 (351 s;
  portable sources checked 300); 2 `test.cmd checked` TESTS_OK 13:42:26..14:19:02 (2196 s; no flake rerun); 3
  `ext_g1.py check` EXT_G1_OK runs 77 (amended 1) unchanged: **ALL_GREEN** 14:19:04.  4 `build.cmd` (Release)
  BUILD_OK 14:19:13..14:25:51 (398 s): **RELEASE_OK**.
* **Against the predictions** (`build/d6fsa-prep/compare.py` against the snapshot: 58 of 65 files equal, host times
  left out): as predicted, unit.log test_map 338 -> 342, test_observer 115 -> 126, test_pdos_compose 68 -> 90,
  test_pdos_reskin 121 -> 147, test_present 951 -> 956, every other count equal; EXT_ADAPT_OK checks 208 -> 237 (the
  29 f6s lines; f6-zcover-m1 and -p1 with D6fS-a's texts: the tax box A 203,101..485,311, its content's size, 59220
  of its pixels the A frame's, the hidden dialog's part beside it as the views before the box; f6-zcover-menu
  unchanged); OBS_LINT_OK files 132 probes 203 callsites 101, ADAPT_OK rows 130 steps 25, OBS_TABLES_OK, pdos-scene-check
  (1084), REGISTRY_OK, EXT_FRAMES_OK, ZOOM_OK (no golden change), EXT_DBL_OK, EXT_TIMELINE_OK, P0_OK checks 476,
  REPLAY_OK checks 70, MIRROR_OK runs 29 and every other section unchanged.  Informational, as the predictions
  allowed: coverage.txt "other functions entered" 671 -> 664 (informational: the merge of the coverage files the
  test programs and harness runs leave, D7j's landing moved it 667 -> 671); nodos files 1779 -> 1780 (this record), 0
  hits; unit.log's OBS_COST line (host timing).
* **User build** `build/user-builds/d6fsa/` (14:26 UTC): `civ64.exe` (the Release build, SHA-256 bc2bb4e2...),
  `CIVWIN.zip` and `civdos.zip` from `build/user-builds/d4/`, `WHAT-TO-CHECK.txt` (D6fSa-1..D6fSa-3, the rewritten D5-7
  and D6f-8, the earlier builds up to "d7j", and the 85 items still pending in the checklist at 14:26 UTC).
* Not done at this slot: the checklist sections and STATUS rows (the orchestrator's) and the docs pass for D6fS-a (with
  D7j's); the tree's CheckedNoObs build is not part of the three-step cycle (the private overlay builds and units of
  the three variants are in "Results").

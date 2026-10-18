# Phase-4 review 2: P4-3 (menu tracking), F14 (review-1 fixes), P4-4 (scroll-bar tracking)

Reviewer: independent read-only reviewer (subagent), 2026-10-09.  Nothing was built, compiled or
run; no test, harness, game or port program was executed.  Project files were read with
Read/Grep/Glob only; the shell was used only to create the scratch folder `rv2` and to run
`claude/tools/showfunc.py` (1098:02D1, 1098:062F, 1208:0367..03E6) with its output written there.
Paths below are relative to `claude/port` unless they start with `claude/`.  Statements about
Windows 3.1 behaviour that are not proved in this repository are marked **(inference)**; where they
rest on memory of Wine sources they are not Windows 3.1 evidence.

Classification: **DEFECT** = wrong behaviour, or a record that misstates the code; **RISK** =
latent or fragile; **NOTE** = wording or test gap.

---

## P4-3 menu tracking

Files: `platform/w16/user_menutrack.c` (whole), `queue.c`/`queue.h` (system keys, `w16_queue_post`,
header byte 15), `user_wnd.c` (overlays, bar highlight, services, DefWindowProc cases, reset),
`user_menu.c` (`w16_menu_command_popup`, `w16_menu_count`, `w16_menu_item_id`), `user_misc.c`
TranslateAccelerator, `w16_int.h`, `tests/test_user.c` test_menu_track and test_menus,
`tests/test_queue.c` test_syskeys, DESIGN 5 "Menus"/Q5/10 "System keys", FIDELITY F76, FEATURES 65.

Checked and found correct: the system-key conversion (queue.c:205-219; Alt state kept also while
Ctrl is down; bit 29; F10 without bit 29; `xlat` attached after the conversion, 266-269) and
header byte 15 bit 0x40 (638); `w16_queue_post`/`post_front` (274-311, full-queue check first);
arming/disarming and SC_KEYMENU entry (user_menutrack.c:865-897), including the repeat-disarm
the header states; WM_SYSCOMMAND dispatch (899-909); WM_INITMENU before SetCapture (781-788);
WM_INITMENUPOPUP(popup, MAKELONG(pos, 0)) (514); WM_MENUSELECT wParam/flags/HIWORD and the
`(0, 0x0000FFFF)` close (433-436, 851); WM_COMMAND posted after the menus close and the highlight
is removed (848-858); WM_QUIT re-posted (829-831); `alive()` after every send and iteration;
every key rule of the header (key() 618-675; `first_item` wraps and skips separators; no
`% 0` with n = 0); the mouse rules (mouse() 727-766, point_at 703-725) including the
"click on the open item closes" and "release on a cascade item keeps it open" cases; bounds
(MT_LEVELS 4 → depth ≤ 3 → at most 9 of `g_overlay[12]`, set_overlays 306-314,
user_wnd.c:2643-2652; MT_ITEMS 48 = user_menu.c MAX_ITEMS; `disp[64]` with MAX_TEXT 64);
`host_alloc`/`host_free` pairs (vis_of/draw_popup/redraw_item, track's `Mt`) and the scratch mark
(814-847) on every non-longjmp path; overlays subtracted in vis_region (user_wnd.c:613-615) and
desktop_expose (1318-1320), so nc_paint, window DCs, BeginPaint and the bar redraw
(`w16_wnd_menu_hilite`, 2624-2641) stay off open popups; stale handles cleared at the loop end
(`w16_wnd_menu_hilite(0, -1)`) and in w16_user_reset (3391-3397); progress of the loop (each
iteration removes a message or charges `W16_COST_PEEK_FALSE_US`, plus `VM_API_STEP`); Q5 in
TranslateAccelerator (user_misc.c:321-341) as recorded (taken without messages for a grayed or
disabled item or a disabled window; INITMENU/INITMENUPOPUP only without a capture; WM_COMMAND
alone for a command outside the menu; the window destroyed during WM_INITMENU returns 1 without
WM_COMMAND); `w16_menu_command_popup`/`w16_menu_count`/`w16_menu_item_id` (user_menu.c:302-338).
The test expectations of test_menu_track (MENU 128 of the game: bar mnemonics F E O A W P C H are
unique, `claude/docs/resources.md` 10-98) were followed by hand and match the code.

### RISK R1: menu-bar command items cannot be chosen by Return, Down or a click

`user_menutrack.c:664-667` (VK_RETURN on the bar) and 649-653 (VK_DOWN/UP) call `open_popup`,
which returns at once for an item without MF_POPUP (507-508); WM_LBUTTONUP chooses only at
`k > 0` (750-755), and a press on the bar item only selects it (point_at 705-712).  Only a mnemonic
chooses such an item (mnemonic_key 602-609 → act).  Scenario: a program whose bar has a command
item (MENUITEM at the top level): Alt, Return does nothing; clicking it leaves the menu open with
the item selected.  Windows chooses it on Return or on the release **(inference)**.  Latent: all
eight bar items of MENU 128 are popups.  The header (35) states only "Return on the bar opens the
popup".  Fix: at depth 0, Return (and the release on a bar item) calls `act()` when the item is not
a popup.

### RISK R2: re-entrant modal code inside the loop runs under the popups and the capture

The loop keeps `g_overlay`, `g_hilite_hwnd` and the capture for its whole duration and dispatches
WM_PAINT/WM_TIMER/other messages (842-843) and sends WM_INITMENU/WM_INITMENUPOPUP/WM_MENUSELECT.
A procedure that opens a dialog (its own PeekMessage loop) from one of these gets every mouse
message routed to the capture window as client input (user_wnd.c:2981-2983) and dispatches it to
the menu window's procedure, while the dialog cannot paint under the popups; a procedure that
sends WM_SYSCOMMAND(SC_KEYMENU) starts a second `track()`, whose end clears the outer loop's
overlays (`set_overlays` with depth 0), highlight and capture (`w16_ReleaseCapture`, 855).  The
same single-instance state is what P44-R1(b) below reaches with real input.  Latent for menus: the
game handles none of the three menu messages (user_menu.c:11-12; no match in `claude/src/c`) and
its dispatched handlers (WdwMapProc WM_TIMER 1208:019D, WM_PAINT 1208:02CD, TimerProc 1008:0D68)
open nothing.  Fix direction: refuse (or end the outer loop) when a loop is already active, and
end the loop when `w16_wnd_capture() != hwnd`.

### NOTEs

- **N1** Header wording vs code (`user_menutrack.c`): 22-24 "with a character, opens the popup of
  the bar item" — a bar command is chosen (602-609); 38-41 "when it is the only match the item
  acts" — on the bar the first match acts even with several matches (602-609); 43-44 "a button
  press outside ... ends the loop" — WM_MBUTTONDOWN/DBLCLK do not (no case, 763); 45-46 release
  outside — also ends a keyboard-opened menu (747-749 does not test `t->mouse`), e.g. a mouse
  button held on the map while Alt is tapped; 52-53 "so the game's next PeekMessage returns it" —
  only an unfiltered one (IsKeyPending's KEYFIRST..KEYLAST pump, 1098:02DE, leaves it queued).
- **N2** The chosen command is dropped silently when the 120-entry queue (input and posted messages
  share it) is full: `w16_queue_post` returns -1 (queue.c:295-297), ignored at 857.
- **N3** Both loops take the MSG's pt as the screen point (user_menutrack.c:833, offsets 14/16).  Harness mouse
  lines addressed to a window pass client coordinates as the cursor position
  (`tests/headless/harness.c:425-428` → `queue.c:221-223`), so such lines would be hit-tested
  wrongly inside the loops.  Test path only (no checked-in script has such lines).
- **N4** `w16_int.h:260` still describes `w16_menu_item_text`/`_flags` as "(tests; ...)"; they now
  serve user_wnd.c and user_menutrack.c.
- **N5** Test gaps: F10 entry and the child → parent passing of system keys (test_user); Left/Right
  with a popup open, Up from the bar, Home/End, Escape on the bar, VK_MENU ending the loop; a
  mnemonic with two matches (Orders: "Found New &City", "&Clean Up Pollution"); a grayed popup item
  not opening; checked tick and the accelerator column; cascade to the left and the on-screen
  clamp; remaining popups redrawn after a cascade closes; desktop exposure excluding overlays
  (only `w16_wnd_client_vis` is checked, test_user.c:204-205); WM_QUIT, window destruction and
  scratch release in the loop; right button; Q5's disabled-window and capture branches and a
  command outside the menu (test_menus covers only the enabled and grayed items, 704-729).

---

## F14 (fixes for RV1)

Every F14-01..F14-25 change is present.  Verified against RV1 and the code: F14-01/17 (raise_top
3049-3095 → expose_tree_rgn 1340-1376: WM_NCPAINT, sync erase, children), F14-02 (owned_by
3035-3045, cycle-bounded; relink keeps relative order, test_user.c:1166-1168), F14-03 (coalescing
230-239: only ROUTED entries come from raw input; an entry being routed is excluded; plain moves
need the same window), F14-04 (hook_route 2989-2992, HTERROR outside the double-click logic 3003),
F14-05/07/11/12/13 (records: F75, DESIGN 963-990 and 1316, header 65-99), F14-06 (mark and
re-find 446-475; see F14-R1), F14-08 (raw_admitted 338-344), F14-09 (memset 425, 538), F14-10
(3131), F14-14 (test_user.c:1408), F14-15 (restart test 617-626 distinguishes restart from
continuing; MK_CONTROL 631-637; raise/disabled tests 1142-1198), F14-16 (`input.script:5-12`; the
stub core pumps unfiltered, `stub_core.c:60`, so the raw move is routed and dropped), F14-18/22
(acknowledged, unchanged), F14-19 (draw_scroll_bar clips to `b.all` 1109-1111, nc_triangle to its
box 897-898; the open item is accurate: the system-box bar 1180-1183 is unclipped), F14-20/21/23
(user_wnd.c header 30-41, menu_display 950, user_menu.c 7-12, FEATURES 65, F26), F14-24 (open, as
stated), F14-25 (out-of-range.md 171-178, 190-191; DESIGN 306-311).

ROUTING mark, asked specifically: it cannot loop (each pass routes a RAW entry once; ROUTING
entries are skipped; the eaten restart follows a removal).  A mark is left behind only when
`g_route` is left by longjmp (a fault inside WM_NCHITTEST, or the harness watchdog,
harness.c:520-525); the run then ends, the snapshot taken shows the in-flight entry (flag 0x08,
queue.c:669), and w16_queue_reset clears it.  The fault at 463-467 can fire only when no ROUTING
entry is left, i.e. after a reset inside the hook.  It can pick the wrong entry: F14-R1.

### RISK F14-R1: nested routing re-finds the wrong entry and reorders the queue

`queue.c:459-474` re-finds "the first ROUTING entry".  With nesting there are several.  Scenario:
queue [A raw, B raw], an unfiltered PeekMessage marks A and sends WM_NCHITTEST; the procedure calls
PeekMessage(PM_NOREMOVE) (or a filter that does not take B): the nested call marks B, routes it,
re-finds A's slot (index 0) and writes routed B there; the outer call then re-finds B's slot and
writes routed A there.  Result [B, A]: e.g. a button up delivered before its down.  Also, after
routing the scan resumes at the entry (`i = j`), so a message posted at the front during the hook
(post_front, e.g. a TranslateMessage character) is returned after the routed input, against the
posted-first rule (queue.c:10-12).  A nested route that drops its message removes the first ROUTING
slot (the outer one) without the recorded fault (content stays consistent because both slots are
marked).  Latent: no game procedure handles WM_NCHITTEST; the test (test_queue.c:570-579, 643-655) nests only
a PM_NOREMOVE peek that finds a key.  Fix: store a nesting level (or a per-entry sequence number) in
the marked entry and re-find that one; restart the scan at 0 after routing, as the eaten path does.

### RISK F14-R2: child iteration after a re-entrant DestroyWindow

expose_tree_rgn iterates `for (s = w->child; s; s = W(s)->next)` around a recursive call that
sends WM_NCPAINT and WM_ERASEBKGND (user_wnd.c:1365-1375); `expose()` does the same over the
top-level list (1393-1395).  A procedure that destroys its own window (or its next sibling) while
handling either message makes `W(s)` NULL: a host NULL dereference, not a vm_fault.  The pattern
predates F14 (RV1's expose_tree) but F14-01 now runs it from the click path (hook_mouse_taken →
raise_top 3119 → 3088).  Latent: the game's WM_NCPAINT/WM_ERASEBKGND handling is DefWindowProc's.
Fix: read `next` before the recursive call and stop when `W(h)` is gone afterwards.

### NOTEs

- **F14-N1** F14-15 (round8-fixes.md:144) lists "the serialised RAW/ROUTED/ROUTING flags" as
  tested; test_queue.c:607 and 612 test only RAW/ROUTED (mask 0x06), nothing serialises an entry
  while it is ROUTING (0x08).  The file header (test_queue.c:15) says RAW/ROUTED only.
- **F14-N2** F14-19 and F26 say the scroll bars' parts are "clipped to their rectangles"; they are
  clipped to the bar's rectangle (1109-1111): in a bar shorter than 30 pixels the two arrows still
  overlap and draw over each other (bar_parts 1070-1079).
- **F14-N3** Test gaps: coalescing into a routed WM_NCMOUSEMOVE (test_queue.c:609-616 starts from a
  client move); a nested PeekMessage that routes another raw entry (F14-R1); the raise test
  accepts WM_NCPAINT *or* WM_ERASEBKGND for the child (test_user.c:1169-1170).

---

## P4-4 scroll-bar tracking

Files: `platform/w16/user_scrolltrack.c` (whole), `user_wnd.c` (`g_sb_*`, bar_parts 1084-1086,
draw_scroll_bar 1124-1143, services 2666-2699, WM_NCLBUTTONDOWN 3277-3281, reset 3394-3396),
`user_menutrack.c:905-907`, `w16_int.h:294-307`, test_scroll_track, DESIGN 1014-1023, F77.

Checked and found correct: entry codes 0xF077/0xF086 (3278-3280); part_at (67-84; the black line
and the separators are no part); LINE/PAGE codes with lParam 0 and the thumb's position in LOWORD
(86-89); thumb_pos rounding and clamping (92-100, int64, result within [min, max]); the drag clamp
(162-168) and its drawing (bar_parts clamps `g_sb_at`); the page repeat re-reading the thumb
(187-197); the pressed arrow redrawn on entering/leaving (175-177); SB_THUMBPOSITION and
SB_ENDSCROLL only while the window lives (201-208); state cleared with hwnd 0 when it is gone
(210) and on reset; capture released; scratch mark released; each iteration charges the PeekMessage
cost or removes a message.  Hand check of test_scroll_track: track rows 16..267, len 252, thumb
(100·100+118)/236 = 42; pixel (385,269) distinguishes pressed from raised.

### DEFECT P44-D1: a quick second click on a scroll arrow or the track is lost

hook_route makes a second button down at the same non-client hit within 500 ms and ±2 pixels a
double click for every class (user_wnd.c:3003-3013).  The scroll loop sees only the first click's
release (no down), so the next click on the arrow becomes WM_NCLBUTTONDBLCLK, and DefWindowProc has
no case for it (3274-3282; default returns 0).  Scenario (game): the player clicks the map's down
arrow twice quickly: the first click sends SB_LINEDOWN, the second nothing; a third click starts a
new pair and scrolls.  Rapid clicking scrolls on every other click only.  Windows 3.1's
DefWindowProc performs the click's action for WM_NCLBUTTONDBLCLK on a scroll bar, so a double click
on an arrow scrolls twice (**inference**, SDK's description of WM_NCLBUTTONDBLCLK; also Wine's
NC_HandleNCLButtonDblClk from memory).  FIDELITY F75 (line 110) states the default actions of the
scroll bars' non-client button messages as modelled.  test_scroll_track's clicks are ≥ 180 pixels
apart (test_user.c:1584-1627), so no test meets this.  Fix: treat WM_NCLBUTTONDBLCLK on
HTVSCROLL/HTHSCROLL as WM_NCLBUTTONDOWN; add a two-click test.

### RISK P44-R1: the loop ends only on a WM_LBUTTONUP it removes itself

`user_scrolltrack.c:144-185`: the loop ends on WM_LBUTTONUP, WM_QUIT or the window's destruction,
never on a lost capture or a released button.  (a) Game scenario: the player presses on the map's
down arrow while the game is busy and releases over the map's client area; WaitForKeyOrClick
(1038:0C1D) first calls FlushInputEvents, whose 0x200..0x209 drain (11F0:4F0F) routes both: the
down becomes WM_NCLBUTTONDOWN (outside the filter, stays), the client WM_LBUTTONUP is removed;
WaitForKeyOrClick's own loop then dispatches the down (1038:0CEB) and the scroll loop starts with no
release pending: SB_LINEDOWN every ≈110 ms (the pointer position is the down's) until the player
clicks again, and that click is eaten.  (b) During a drag, Alt pressed and released is dispatched
(180-183) to WdwMapProc → DefWindowProc → SC_KEYMENU: the nested menu loop eats the mouse release
and releases the capture (user_menutrack.c:855); the scroll loop continues (repeat, or the thumb
following moves with the button up) until the next click.  Whether Windows 3.1 also ends on the
button state is not known (**inference**; Wine's tracking also ends when GetCapture() is no longer
the window, from memory).  Fix direction: also end when `w16_wnd_capture() != hwnd`, and when the
posted-input left button is up (`g_async`/key state) and no WM_LBUTTONUP is queued.

### NOTEs

- **P44-N1** Repeat timing: `next` is compared with `w16_clock_tick_count()` (188, 197), which
  moves in 54.925 ms steps (clock.h:7-8, 32): the first repeat comes 7-8 ticks (≈385-439 ms)
  after the click and then every 2 ticks (≈110 ms).  DESIGN 1017-1018, F77 and the header (21-22)
  say 400 ms and 100 ms of virtual time.  The test (n 6..12, test_user.c:1590) accepts either.
- **P44-N2** At the end the bar is redrawn at its old position (201-202) before SB_THUMBPOSITION
  (203-205); the program's SetScrollPos then moves it again, so a frame presented in between shows
  the thumb snapping back.  Not recorded among F77's choices.
- **P44-N3** Unrecorded choices: a held track part has no pressed feedback; `thumb_pos` uses the
  range read when the drag started (`p`, 118), so SetScrollRange during a drag is not followed.
- **P44-N4** Test gaps: repeat stopping when the pointer leaves the arrow and resuming on return;
  the page repeat stopping at the thumb (the test procedure never calls SetScrollPos); the thumb's
  drawing during the drag and its clamping at both ends; WM_QUIT and window destruction in the loop;
  key dispatch during the loop; the horizontal bar beyond one arrow click; P44-D1.

---

## Effects on the game

- **Keyboard menus.**  WM_SYSKEYDOWN/WM_SYSKEYUP/WM_SYSCHAR reach DefWindowProc through
  ProcessKeyboardMessage (TranslateMessage returns 1, so they are dispatched at 1098:0395 / 0353),
  WaitForKeyOrClick (1038:0CEB), DelayTimerTicks (11E8:02D4) and PumpOneMessage (1098:069E);
  WdwMapProc passes them on (1208:0619).  The menu loop therefore runs nested inside those loops,
  e.g. inside IsKeyPending (11E8:02FB).  Alt+letter no longer reaches EnqueueKey as WM_CHAR: it
  opens a menu by mnemonic or beeps; F10 opens the menu bar (as in Windows, **inference**).
- **The posted WM_COMMAND** is handled when PumpOneMessage removes it (dispatch → 1208:057A sets
  g_pendingCommand → HandleMenuCommand at 1098:06B4).  If WaitForKeyOrClick or DelayTimerTicks
  removes it first, WdwMapProc sets g_pendingCommand without handling it and the next
  PumpOneMessage clears it (1098:0639): the command is lost (faithful mechanism, **inference**).
  Posting, not sending, is what makes a menu chosen inside ProcessKeyboardMessage's dispatch work
  at all, since that path handles g_pendingCommand only after an accelerator.
- **Q5.**  The Orders accelerators N, K, P, H, J, D (FEATURES 87-102) on items that
  UpdateOrdersMenu grays (`claude/src/c/seg037_1120.c`) are now taken without a message; then
  ProcessKeyboardMessage executes HandleMenuCommand(g_pendingCommandId) at 1098:039E whenever
  g_pendingCommand is still 1 from an earlier command (only 1098:0639 clears it), i.e. the previous
  command runs again — the listing's own note at 1098:02D1 calls this a possible original bug.
  Faithful if Windows 3.1's TranslateAccelerator returns non-zero for a grayed item
  (**inference**).  Enabled accelerators (Ctrl+S in the load/save scripts) now also send
  WM_INITMENU and WM_INITMENUPOPUP to WdwMapProc, which only count them (g_mapWndProcMsgCount,
  1208:0069): game memory differs from pre-P4-3 runs by that counter.
- **During the menu loop** WdwMapProc gets the three menu messages (DefWindowProc), WM_PAINT
  (1208:02CD blits rcPaint, clipped off the popups), WM_TIMER (palette cycling, 1208:019D) and
  TimerProc's WM_TIMER (1008:0D68); none of them destroys a window, changes the capture or opens a
  dialog, so nothing the game does breaks the loop.  Closing a popup erases the map with its class
  brush (black) at once and repaints it on the next WM_PAINT (F76 choice).  A keyboard-opened menu
  eats the release of a mouse button held on the map, so WdwMapProc never sees WM_LBUTTONUP and
  g_mouseButtonDown stays 1 until the next click (presumably as in Windows, **inference**).
- **Scroll bars.**  WdwMapProc reads SB_THUMBPOSITION's LOWORD(lParam) (`shr ax,5` at 1208:0379 /
  03BA) and passes every other code to ScrollMapHorizontal/Vertical, whose switches ignore codes
  above 3 (seg064_11F8.c:800-818, 893-906): SB_THUMBTRACK and SB_ENDSCROLL are harmless.  Each
  auto-repeat at the top or bottom row leaks one GlobalLock of the map data (return without unlock
  at 1208:076C; Q16 saturates, no fault) — faithful.  The game never sets the horizontal position
  after a drag (only 0x500, seg064_11F8.c:938, 1044), so that thumb returns to the centre.  Keys
  typed during a drag are dispatched to the map: WM_KEYDOWN reaches DefWindowProc (navigation keys
  are lost, they bypass 1098:0372), and WM_CHAR becomes EnqueueKey(TranslateNavKeyToDigit(ch)) at
  1208:0355, i.e. key 0 for ordinary characters.  While ProcessCity locks the map
  (g_mapWindowLocked) the scroll messages go to DefWindowProc and do nothing.  P44-D1 halves rapid
  arrow clicking on the map; P44-R1(a) can scroll the map to its edge without input.
- **Scenarios.**  No checked-in script contains Alt, F10, a menu-bar or scroll-bar click, or a key
  of a grayed accelerator ('B' in new-game.script:44 is "menu text only", FEATURES 88); the only raw
  mouse line (input.script:12) is dropped.  The loops are not reached by the scenario gates.

---

## Rule deviations by this reviewer

None.

---

## Summary table

| Item | Verdict | DEFECT | RISK | NOTE |
|---|---|---|---|---|
| P4-3 | Pass with notes (no defect; bar command items unreachable by Return/click, re-entrancy under open popups — both latent) | 0 | 2 | 5 |
| F14 | Pass with notes (all 25 changes present and accurate except F14-15's ROUTING-flag test claim; nested-routing reorder and child-iteration NULL dereference latent) | 0 | 2 | 3 |
| P4-4 | Needs a fix (D1: a quick second click on a scroll arrow is a WM_NCLBUTTONDBLCLK that DefWindowProc ignores) | 1 | 1 | 4 |

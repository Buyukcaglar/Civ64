# Phase-4 review 3: P4-5 (system commands, window states), F15 (review-2 fixes), P4-6 (MessageBox)

Reviewer: independent read-only reviewer (subagent), 2026-10-09.  Nothing was built, compiled or
run; no test, harness, game or port program was executed and no UI was launched.  Project files
were read with Read/Grep/Glob (two shell listings excepted, see "Rule deviations").  The shell was
otherwise used only to create the scratch folder `rv3` and to run `claude/tools/showfunc.py` for
1000:4124 (`_ErrorMessage`) and 1218:0386 (`WdwStatusOpen`), with the output written there.
Paths are relative to `claude/port` unless they start with `claude/`.  Statements about Windows
3.1 behaviour that this repository does not prove are marked **(inference)**; memory of Wine is
not used as evidence.

Classification: **DEFECT** = wrong behaviour, or a record that misstates the code; **RISK** =
latent or fragile; **NOTE** = wording, a choice worth recording, or a test gap.

---

## P4-5 system commands and window states

Files: `platform/w16/user_syscmd.c` (whole); `user_wnd.c` (header 100-151, the state fields, shown,
nc_parts/draw_caption/draw_icon/nc_paint, the icon titles 1477-1560, activate/activate_next
1746-1803, show/hide sequences, ShowWindow 2188-2237, set_rect 2459-2509, MoveWindow 2511-2570,
owned_popups/icon_place/max_rect/set_state 2575-2702, the services, hit_test/child_at/paint_walk,
DefWindowProc 3723-3904); `user_menutrack.c` (whole: system menu, Alt+F4, the box double click,
`w16_menu_syscommand`); `user_menu.c` `w16_menu_system` (131-172); `user_misc.c`
`w16_icon_decode` (225-288); `queue.c` (the no-focus conversion, 496-499); DESIGN 5 "System
commands and window states", Q12, FIDELITY F78; `tests/test_user.c` test_sys_commands.

Checked and found correct:
- **WM_SYSCOMMAND** (`user_syscmd.c:309-332`): SC_CLOSE sends WM_CLOSE, SC_MINIMIZE / SC_MAXIMIZE /
  SC_RESTORE are ShowWindow's, SC_MOVE / SC_SIZE run the loop; the other codes do nothing, as the
  header (11-14) and DESIGN 5 say.  SC_KEYMENU / SC_MOUSEMENU / the scroll codes stay in
  `w16_menu_syscommand` (`user_menutrack.c:1044-1063`).
- **Move/size loop** (`movesize`, 160-307): the style gates (181-202) match header 19-23
  (maximized SC_MOVE, SC_SIZE without WS_THICKFRAME or not normal, `low > 8`); WM_GETMINMAXINFO
  once through `w16_wnd_track_limits` with max ≥ min (194-200); one system loop at a time (203);
  the outline is self-inverse (XOR 0xFF where x + y is even, clipped to the screen, dirty rectangle
  reported, 94-119), removed around every dispatch (276-283) and at the end (297-299); `moved`
  keeps the dragged edges within the limits and anchors the opposite edge (122-153); WM_QUIT is
  posted again (234-236).  Progress: `VM_API_STEP` every iteration plus a removed message or the
  empty-peek cost (218-226).  The capture is released only while the loop still owns it
  (300-302), `w16_sys_loop_end` comes before MoveWindow (303-306), so WM_SIZE / WM_MOVE handlers
  may start another loop.  Keyboard mode ends only on Return, Escape, a left press, WM_QUIT or
  the capture's loss.
- **Box tracking** (`w16_syscmd_box`, 336-405): the press must be on the box (346); the pressed
  drawing follows the pointer (380-383); the command is sent after the capture is released and
  the loop ended, with the release point (395-404); WM_QUIT cancels it (367-370).
- **States** (`user_wnd.c`): ShowWindow's mapping (2203-2236) is header 122-148 exactly
  (restore_max, SW_SHOWNORMAL restoring a maximized window, SW_MINIMIZE's `activate_next`, the
  activating set 2133-2136).  `set_state` (2658-2702) saves the normal rectangle only from the
  normal state, hides owned popups before the focus leaves, drops the update region, places the
  icon, and on leaving the minimized state shows the popups again (SW_PARENTOPENING, no
  activation) and returns the focus.  `owned_popups` (2575-2605) collects its list before any
  send and re-fetches each window; only the popups it hid come back (`owner_hid`).  `icon_place`
  (2608-2634): ten slots x = 64k + 16, y = 420, the last reused when all are taken (choice,
  recorded).  MoveWindow does not limit an icon and remembers its position (2531-2532, 2565-2568).
  `max_rect` (2637-2656) clamps to the tracking sizes only with WS_THICKFRAME and returns 0 when
  the procedure destroyed the window.  `show_sequence` / `hide_sequence` re-fetch after
  WM_SHOWWINDOW (2141-2146, 2165-2169).
- **Drawing**: minimized `nc_parts` has no frame and the whole icon as client area; `draw_icon`
  uses `w16_icon_decode` (`user_misc.c:225-288`: 1/4/8 bits per pixel with the AND mask, at most
  32 x 32 read, header and offsets bounded); the titles are drawn on the desktop and re-exposed on
  every move, state change and WM_NCACTIVATE (3749-3757, `title_expose`); `expose_tree_rgn` treats a
  drawn icon as a non-client repaint (1583).  `hit_test` returns HTCAPTION for an icon; `child_at`
  and `paint_walk` skip a minimized window's children.
- **DefWindowProc**: WM_NCLBUTTONDOWN (3862-) and WM_NCLBUTTONDBLCLK (3890-3904) match header
  100-108 (SC_RESTORE for an icon or a maximized window, SC_MAXIMIZE only with WS_MAXIMIZEBOX,
  SC_CLOSE on HTSYSMENU); WM_SHOWWINDOW (3758-3767) acts only for an owned WS_POPUP with the two
  parent codes; WM_CLOSE destroys (3799-3801).
- **System menu**: `w16_menu_system` (`user_menu.c:131-172`) builds the nine items and the
  dialog-frame pair with the graying of `user_menutrack.c:31-36`; Alt+F4 needs lParam bit 29 and
  posts SC_CLOSE (1020-1022); a second click on the box within 500 ms of the loop's opening click
  chooses SC_CLOSE (834-842).
- **queue.c:496-499**: only key downs/ups queued without a window are converted, only when there
  is no focus and a target exists; the key-state array sees the converted number, as on the Alt
  path.
- **Records**: DESIGN 5 (1027-1046), the header and F78 agree with the code except as listed below.
- **test_sys_commands** (`tests/test_user.c:1780-1962`), checked by hand: the maximized rectangle
  (-3,-3)-(643,483) is the screen with the 3-pixel frame outside (default tracking maximum 646 x
  486 does not clamp it); (370,62) is on the minimize box 361..378; the icon (16,420)-(48,452) is
  slot 0 and WM_SIZE(1, 32 x 32); the popup gets WM_SHOWWINDOW(0, 1) and later (1, 3); with the
  popup hidden no other window is visible, so active = focus = 0; the title row is y = 454 (two
  below the icon); the icon click activates without focus and 'A' arrives as WM_SYSKEYDOWN; the
  icon double click is routed after the move loop ended on the first release; the drags give
  (150,90,450,340), (150,90,401,201) and the 100 x 28 minimum; Escape cancels; Alt+Space, M, two
  Rights and a Down move by (16, 8); nine system-menu items with Restore grayed; Alt+F4 destroys
  the window and its owned popup; the box double click gives 0xF093 then SC_CLOSE.  All expectations
  follow from the code.

### DEFECT P45-D1: activating an icon leaves the focus on another window

`activate` (`user_wnd.c:1779-1782`) only *gives* the focus to a window that is not minimized; when
`h` is minimized and the focus is in another top-level window, the focus stays there.  The header
(147-148: "Activating a minimized window does not give it the focus: keyboard input goes to it as
system keys") and DESIGN 5 (1039: "an active icon receives system keys") state otherwise: queue.c
converts keys only when there is no focus (496-499), so the keys go as WM_KEYDOWN / WM_CHAR to the
other window while the icon is active.

Scenario: the map is minimized; the game then shows a window it owns or focuses a control in it
(GR_DialogOpen's modeless dialogs, `claude/src/c/seg020_1098_p1.c:818`, `seg047_1170_p2.c:705`,
`seg069_1220_p2.c:307` set the focus in their dialogs); the user clicks the map's icon.  The map is
active (its title in the caption colour) but keys reach the dialog.  test_sys_commands covers only
the case where no window had the focus (1844, 1860).  A related path: `w16_SetFocus` (1805-1820)
and MessageBox's focus restoration (`user_msgbox.c:514-516`) can put the focus on a minimized
window itself, after which keys arrive as WM_KEYDOWN rather than system keys.

Fix: in `activate`, when `h` is minimized and the focus is not 0, `set_focus_raw(0)`; decide (and
record) whether SetFocus into a minimized top-level window is allowed **(inference: Windows 3.1
lets a program set the focus to an icon)**; add a test with a focused second window.

### RISK P45-R1: window pointers and child lists used after sends (new P4-5 call paths)

- `set_rect` (2485-2488) calls `invalidate_tree(W(hwnd))` right after `expose()`, which sends
  WM_NCPAINT / WM_ERASEBKGND to other windows; if one of them destroys `hwnd`, `invalidate_tree`
  dereferences NULL (2116).  `set_rect` now runs on every state change and every MoveWindow with
  repaint.
- `hide_sequence` (2172-2179) reads `w->style` and `is_top(w)` after `expose(&old, h)`; `w` is
  freed by `wnd_free` (1889) if a procedure destroyed `h` meanwhile: a use after free.
- `invalidate_tree` (2127-2129) reads `W(s)->next` after the recursive call that sends WM_NCPAINT
  and the synchronous erase, and passes `W(s)` unchecked; `destroy_tree` (2251-2256) reads the
  next sibling before WM_DESTROY of the current one, which may destroy that sibling.  This is the
  pattern F15-06 removed from `expose_tree_rgn` / `expose` (1598-1606, 1624-1632).

Latent: the game's WM_NCPAINT / WM_ERASEBKGND / WM_DESTROY handling destroys no window.  A fault
here is a host crash, not a `vm_fault`.  Fix: re-fetch `W(hwnd)` and return in `set_rect`,
re-fetch `w` after `expose` in `hide_sequence`, and give `invalidate_tree` / `destroy_tree` the
F15-06 loop.

### NOTE P45-N1: stale TranslateAccelerator justification; accelerators of an active icon

`user_misc.c:27-28` still says the minimized-window rules are not modelled because "the game does
not minimize its menu window".  P4-5 lets the user minimize the map (style 0x02FF0000 has
WS_MINIMIZEBOX, `claude/src/c/seg064_11F8.c:970-972`).  The game passes every message to
TranslateAccelerator with the map (`seg019_1090.c:652, 781`); the rule "exactly the Shift/Ctrl/Alt
states" also matches the no-focus WM_SYSKEYDOWN of a plain key, so an accelerator sends
WM_INITMENU / WM_INITMENUPOPUP / WM_COMMAND to the minimized map and the game runs the command.
**(inference)** Windows 3.1 sends no WM_COMMAND for an accelerator of a menu item while the window
is iconic.  Fix: model that rule or record the choice, and update the justification.

### NOTE P45-N2: an icon's hidden menu bar stays reachable

`user_menutrack.c` has no minimized-window case except the popup placement (626).  For the map's
icon, Alt or F10 starts the loop with WM_INITMENU(menu bar) (header 37-38), and Right or an
Alt+letter mnemonic reaches the bar items, which are not drawn (`nc_parts` gives an icon no bar);
their popups open at the hidden bar's item positions.  **(inference)** Windows 3.1 offers only the
system menu for an icon.  Fix: treat a minimized window as having no bar in the loop, or record
the choice.

### NOTE P45-N3: unrecorded loop details in `user_syscmd.c`

- The box loop translates and dispatches key messages (384-388); the header (15-18) does not say
  so.  It ends on the capture's loss (389-391) with `on` unchanged, so the command is still sent
  when the pointer was on the box; the header records only the idle case (359, F15).
  **(inference)** Windows 3.1 cancels the tracking without a command on WM_CANCELMODE.
- The keyboard offset (`kx`, `ky`, 266-268) is unbounded: the window can be moved entirely off
  the screen, and the int16 casts in `moved` wrap after about 4096 presses.
Fix: record both, or clamp the outline to keep part of it on the screen.

### NOTE P45-N4: Q12's status-window example

DESIGN Q12 (1101) says WdwStatusOpen's MoveWindow "is limited to the smaller maximum".  showfunc
1218:0386 shows MoveWindow at 1218:050A before the data block's GlobalAlloc at 1218:0522, and
WdwStatusProc fills MINMAXINFO only when `g_hStatusWindowData != 0`
(`claude/src/c/seg068_1218.c:56-58, 271-277`).  That MoveWindow therefore sees only the default
tracking sizes, as MoveWindow's own comment already says for the map (`user_wnd.c:2527-2529`).
Behaviour is unaffected.  Fix: reword the example.

### NOTE P45-N5: the game draws over its own icon

Minimizing sends WM_SIZE(SIZE_MINIMIZED, 32 x 32).  WdwMapProc calls `ResizeMapWindow`
(`seg064_11F8.c:756-759`), which rebuilds the back buffer at 32 x 32, sets a 1 x 1-square view
(`seg066_1208_p1.c:197-199`) and redraws through the window's kept DC into the icon's client area,
over the class icon that the window manager drew.  Restoring rebuilds the full view.  The header's
"the window gets no WM_PAINT" is true, but nothing stops this direct drawing.  **(inference)**
Windows 3.1 also lets an iconic window's DC draw over its icon.  No test shows the icon after a
procedure draws.  Fix: record the observable result in F78, or clip the DCs of a minimized window
that has a class icon.

### NOTE P45-N6: an icon's title is not redrawn after WM_SETTEXT

DefWindowProc WM_SETTEXT (3802-3812) repaints only a caption, so a minimized window keeps its old
title.  There is no game effect: the only window that renames itself is the small map
(`seg066_1208_p2.c:396-400`), which has no WS_MINIMIZEBOX (207-210), so its Minimize item is
grayed (`user_menu.c:161`).  Fix: call `title_expose` for a shown icon.

### NOTE P45-N7: test gaps

These are not covered: SW_SHOWMINNOACTIVE / SW_SHOWMINIMIZED; a second icon slot and a moved icon
(position remembered); maximizing through the box and the restore box; a window with
WS_THICKFRAME clamped when maximized; WM_QUIT, capture loss and destruction inside the move/size
and box loops; a release off the box; keyboard SC_SIZE; and P45-D1's focused-other-window case.

---

## F15 (fixes for review 2)

Files: `verify/round8-fixes.md:156-178` against `verify/phase4-review-2.md`; the code named there;
`tests/test_queue.c` test_mouse_review2 (611-627); `tests/test_user.c` test_scroll_track (the
quick second click, the filtered release, Alt during a held arrow) and test_bar_command.

Checked and found correct:
- **F15-01**: DefWindowProc WM_NCLBUTTONDBLCLK on HTVSCROLL / HTHSCROLL of any window sends the
  scroll SC_ code (`user_wnd.c:3899-3903`); header 105-108, F75/F77 and DESIGN 1054 say so.
- **F15-02**: `w16_wnd_track_lost` (1839-1842) and its use in the scroll loop
  (`user_scrolltrack.c:154-157, 196-198`), move/size (`user_syscmd.c:219-226, 284-287`) and box
  (357-361, 389-391) loops; `w16_queue_buttons` reflects the posted input.
- **F15-03**: `w16_sys_loop_begin` / `_end` (`user_menutrack.c:202-214`) bracket all four loops,
  are cleared by `w16_menu_track_reset` from `w16_user_reset` (4025), and every early return
  after a successful begin reaches the end; the menu loop ends on capture loss (951, 978).
- **F15-04**: Return on a bar command item and the release on it call `act` (768-770, 866-868).
- **F15-05**: the routing level kept in `hit` while ROUTING and the restart from the front
  (`queue.c:461-490`), `g_route_level` cleared by the reset; header updated.
- **F15-06**: `expose_tree_rgn` and `expose` read the next sibling first and stop when the parent
  or the sibling is gone (1598-1606, 1624-1632).
- **F15-07..F15-12** (records): the tick-count delays (DESIGN 1050-1051, F77); SB_THUMBPOSITION
  sent before the bar is redrawn at its position (`user_scrolltrack.c:215-220`); the range and
  held-track choices (`user_scrolltrack.c:35-36`); the `user_menutrack.c` header wording (66-82);
  F14-15 and F14-19 corrected in place (round8-fixes 144, 148).  F15-13 is honestly marked open.
- **Tests, by hand**: test_mouse_review2. The first PeekMessage routes the down; the nested peek
  routes the up, skipping the ROUTING entry, so g_routes = 2; the WM_COMMAND posted meanwhile is
  found first after the restart; then come the down and the up, and nothing else.  The quick
  second click on an arrow gives SB_LINEDOWN, SB_ENDSCROLL twice (1, 8, 1, 8).  The filtered
  release gives 1, 8 with the idle end.  Alt during a held arrow gives SC_KEYMENU without
  WM_INITMENU, because the second loop is refused.  test_bar_command: Return on the Edit item
  (made a command item with ModifyMenu) posts its WM_COMMAND.  All expectations follow from the
  code.

### NOTE F15-N1: the F15-06 pattern remains elsewhere

RV2 F14-R2 cited only `expose_tree_rgn` and `expose`, and F15-06 fixed exactly those.  F15-06's
parenthesis "no NULL dereference when a procedure destroys a window during WM_NCPAINT /
WM_ERASEBKGND" is broader than the fix: `invalidate_tree` sends the same two messages with the
old loop, and `destroy_tree` has the same shape around WM_DESTROY (P45-R1).  Fix: as P45-R1, then
reword F15-06.

### NOTE F15-N2: the idle end relies on the back end posting every release

`w16_wnd_track_lost(hwnd, 1)` asks the posted-input button state (`g_async`), not the host's
physical state.  If the back end ever loses a release (for example, a release outside its
window), the scroll, move/size and box loops keep running until the next press or release.
**(inference)** Windows 3.1 follows the physical button.  Fix: record the back-end requirement
(P4-8), or post a release on host focus or capture loss.

---

## P4-6 MessageBox

Files: `platform/w16/user_msgbox.c` (whole); `user_wnd.c` the "#MsgBox" class and BI_MSGBOX,
`w16_wnd_msgbox_class` (1844-1854), `w16_wnd_top_level` (1856-1859), `w16_user_reset` (3991-,
`w16_msgbox_reset` 4026, no "#MsgBox" at reset 4027); the stub's removal from `user_misc.c`
(header 4, 33; no MessageBox body remains); `w16_int.h` declarations; DESIGN 5 "MessageBox"
(1014-1026) and the error-exit note (916-919); F79; `tests/test_user.c` test_msgbox (2040-2108);
`tests/test_start.c` the MessageBox hook (470-529).

Checked and found correct:
- **Button sets and ids** (380-381, 422-428): the six MB_ codes with the header's ids; unknown codes
  give MB_OK; the default button from bits 8-9, else the first (429); the icon codes 0x10..0x40
  only (430).
- **Strings**: `read_cstr` always terminates (124-134); text ≤ 1023 bytes, title ≤ 127, "Error"
  for a NULL caption; `add_line` bounds both the line count and the line length (136-147);
  `layout_text` always advances (`fit` ≥ 1 for n ≥ 1; spaces skipped; `\r\n` handled, 150-193).
- **Scratch**: every `w16_scratch_mark` has its release on the non-longjmp paths (210/231,
  236/256, 457/474, 482/505); `scratch_str` results are used before the release.
- **Allocation**: `host_alloc` never returns NULL (`host.h:16`); `b` is freed on every normal
  return (517).
- **Ownership and enabling**: the owner is `hwndParent`'s top-level window, disabled only when it
  was enabled and re-enabled before the box is destroyed (448-455, 508-513), as the header and
  DESIGN say; the instance comes from GWW_HINSTANCE.
- **Nesting**: `b->outer` is saved at entry and `g_mb` is restored before any further send (507);
  `w16_msgbox_proc` finds the box through the chain (281-287), so an outer box keeps painting and
  keeps a choice made while an inner loop runs; the static `text` buffer is consumed by
  `layout_text` before anything that can re-enter.
- **The loop** (484-504): progress by `VM_API_STEP` plus a removed message or the empty-peek cost;
  ends on a result, the box's destruction (IDCANCEL) or WM_QUIT (posted again, IDCANCEL); keys go
  to `box_key` only for the box or its children; `% b->nbtn` with nbtn ≥ 1.
- **Class**: "#MsgBox" is registered on first use with CS_DBLCLKS and COLOR_WINDOW + 1, so the
  program's class atoms do not move; BI_MSGBOX dispatches to `w16_msgbox_proc`.
- **test_msgbox, by hand**:
  - Box owned by the child `c`: top-level `a` is disabled, the focus is on Yes (6), and Return gives
    IDYES.  The probe's timers still run because the loop dispatches WM_TIMER.
  - Centring; the icon frame at client (16,16), the face at (18,18), white at (8,8).
  - After the box: `a` is enabled and the focus is back on `c`.
  - DEFBUTTON2 gives the focus to No (7).
  - YESNO: Escape gives 0, so the box stays open; then 'y' via WM_CHAR gives IDYES.
  - Hand: caption "Error", Escape gives IDOK, red face (COLORREF 0x0000FF).
  - Tab moves to Cancel.
  - A click on Retry sends BN_CLICKED with HIWORD 0.
  - DEFBUTTON3 with Space gives Ignore (5): WM_CHAR ' ' is passed on.
  - Alt+F4 goes through DefWindowProc's SC_CLOSE to WM_CLOSE, giving IDCANCEL.
  - With no owner, nothing is disabled.
  - 120 'W's are broken at characters (box 400..450 wide).
  - A pending WM_QUIT gives IDCANCEL; the quit is posted again with code 3; the owner is enabled.
- **test_start's hook**: it returns before any allocation (403-408) and stops each error-exit path
  at the call with the expected text offset and caption.

All expectations follow from the code.

### DEFECT P46-D1: the desktop as hwndParent (the game's `_ErrorMessage`)

`_ErrorMessage` calls `MessageBox(GetDesktopWindow(), msg, caption, 0x1010)`
(`claude/src/c/seg001_1000_p4.c:471-472`; showfunc 1000:4124).  `w16_wnd_top_level(desktop)`
returns the desktop (`top_of` stops at parent 0, 447-455), so:
1. the "owner" disabled at 451-453 is the desktop, which routing never consults (only the target
   window's own top-level window is checked, 3563); the map and the other game windows stay
   enabled and take mouse input and menu commands during a system-modal error box;
2. CreateWindow makes the desktop the box's owner (1948); when the box is destroyed,
   `activate_next` (1791-1794) activates its owner, so `g_active` and the focus become the desktop
   (1759, 1779-1781).  The desktop gets WM_QUERYNEWPALETTE / WM_NCACTIVATE / WM_ACTIVATE /
   WM_SETFOCUS; the map gets WM_ACTIVATE(0) and no reactivation.  If `prev_focus` was 0 (map
   minimized, or no focus), the desktop keeps the activation and the focus, and keys are lost
   until the user clicks a game window.

This breaks the rule that the active window is a top-level window (DESIGN 5: input over the
desktop is dropped because "the desktop window belongs to the system").  The path matters:
`_matherr` continues after the box (`seg001_1000_p1.c:2014-2026`).  The fatal paths (`_ErrorExit`,
`seg001_1000_p4.c:479-483`) run game procedures re-entrantly from inside the error handler while the box is open,
because the map stays enabled.  **(inference)** In Windows 3.1, MB_SYSTEMMODAL keeps input from
every other window.  The test seam stops `test_start` before the box exists, and test_msgbox has
no desktop-owner case, so nothing exercises this.

Fix: treat `hwndParent == g_desktop` as no owner for ownership and activation.  For
MB_SYSTEMMODAL / MB_TASKMODAL (or a desktop or NULL owner, if that is chosen), disable the task's
enabled top-level windows for the loop and re-enable them afterwards (record the choice in F79).
Add a test with `w16_GetDesktopWindow()`.

### RISK P46-R1: a box opened under someone else's capture cannot be clicked

Neither MessageBox nor `EnableWindow(owner, 0)` cancels a capture or a running system loop: there
is no WM_CANCELMODE (`user_wnd.c:2961-2983`; DESIGN records none).  If a procedure opens a box
while a window holds the capture, every mouse message routes to the capture window as client
input (DESIGN 5 "Routing"), so the box's buttons and caption cannot be used.  Only Return,
Escape, Tab and the mnemonics work.  The capture can come from the game's own SetCapture before
WaitForKeyOrClick (`seg030_10E8_p1.c:516-518`) or from a menu, scroll, move/size or box loop that
dispatched the procedure.  A drag of the box's caption inside a system loop is also refused
(`w16_sys_loop_begin`).  This is the capture side of F15-03's recorded "dialog opened during a
loop" limitation.  It is latent: no game path found opens a box from a procedure dispatched
under a capture.  **(inference)** Windows 3.1 sends WM_CANCELMODE when a window is disabled and
when a modal dialog or box starts.  Fix: release a capture held by the disabled owner (or any
capture) when the box opens, and record what happens to a running system loop.

### NOTE P46-N1: MessageBeep argument

The header (16) says `MessageBeep(fuStyle & 0xF0)`; the code passes `b->icon` (480), which is 0
for 0x50..0xF0.  There is no observable difference: `w16_MessageBeep` ignores its argument
(`user_misc.c:433-437`).  Fix: align the wording.

### NOTE P46-N2: layout limits and the trailing line break

- Lines beyond 24 are dropped by `add_line`, but `layout_text` still counts their widths (171-173).
- A 24-line box is 24 x 16 + 48 + 28 = 460 client pixels plus caption and frame (about 487), so it
  is centred at y ≈ -3 and its caption starts above the screen.
- A trailing "\n" adds an empty line: the inner loop runs once with n = 0 and `add_line(…, 0)`.
  `_matherr`'s format ends with "\n" (`seg001_1000_p1.c:2015`), so its box is one line taller.

**(inference)** Windows 3.1 limits the box to the screen.  Fix: record these as choices in F79,
or clamp the height and keep the caption on the screen.

### NOTE P46-N3: longjmp out of the loop

A fault in a dispatched procedure leaves `b` allocated (409; freed only at 517).  The owner is
left disabled and the scratch marks unreleased.  `w16_user_reset` rebuilds the window tree and
clears `g_mb` and the system-loop flag, so the only cost is one MsgBox (about 4 KB) of host memory
per faulted run.  Fix: none required; mention it in the header's reset note.

### NOTE P46-N4: keyboard details

For MB_YESNO the system menu's Close and Alt+F4 stay enabled but do nothing (escape_id 0).
Alt+Y / Alt+N arrive as WM_SYSKEYDOWN and are not mnemonics: they become SC_KEYMENU on the box,
find no system-menu match and beep.  **(inference)** Windows 3.1 grays Close for such boxes and
accepts Alt+mnemonic in dialogs.  Fix: record as choices.

### NOTE P46-N5: test gaps

These are not covered: a desktop owner (P46-D1); nested boxes and an outer choice made during an
inner loop; the box destroyed by another party; `\r\n`, more than 24 lines and a trailing "\n";
Shift+Tab / Left / Up wrapping; a box opened under a capture (P46-R1).

---

## Effects on the game

- **Minimizing the map** (CIV class with LoadIcon 128, style 0x02FF0000):
  - The status window, the small map and the modeless dialogs it owns are hidden
    (WM_SHOWWINDOW, SW_PARENTCLOSING) and shown again on restore without activation.
  - WM_SIZE(SIZE_MINIMIZED) rebuilds a 32 x 32 view drawn over the icon (P45-N5).
  - WM_MOVE stores the icon's rectangle as the map's window rectangle (`seg064_11F8.c:582-596`).
    If the game quits while minimized, civ.prf may keep a 32 x 32 rectangle, which WdwMapOpen
    rejects (< 160) in favour of the default geometry.
  - Keys go to the active icon as system keys, so the game's own key handling sees no WM_KEYDOWN.
    Accelerators still act (P45-N1); a focused dialog does not (P45-D1).
  - While `g_mapWindowLocked` is set, WdwMapProc defers WM_SIZE and ignores WM_CLOSE
    (`seg064_11F8.c:520-541`); the replayed WM_SIZE carries the last state.
- **Maximizing**: WdwMapProc's ptMaxTrackSize (`seg064_11F8.c:547-564`) limits the maximized size
  for this WS_THICKFRAME window (header rule, inferred from the SDK).
- **Close**: Alt+F4 or the system menu's Close on the map sends WM_CLOSE, which WdwMapProc turns
  into WM_COMMAND 0x73, Quit (751-754).  On the small map it toggles the window off
  (`seg066_1208_p2.c:143-146`).
- **WaitForKeyOrClick** (`seg008_1038.c:399-435`) returns only on WM_CHAR or a client
  WM_LBUTTONDOWN and dispatches everything else.  A caption, box, border or scroll-bar click
  during it runs the move/size, box or scroll loop inside the wait.  The menu loop's end releases
  a capture the game set before the wait (`seg030_10E8_p1.c:516-518`; recorded choice).
- **MessageBox callers**:
  - Owned by the map: ShowErrorMessage (`seg020_1098_p2.c:509`) and the low-memory warnings
    (`seg062_11E8.c:60, 93, 106`, owner possibly 0 at start-up).
  - No owner: "only one game" and "too many timers" (`seg002_1008.c:133, 145`), the artwork
    YESNOCANCEL prompts (`seg023_10B0_p2.c:218, 394`) and "Memory Resources Used"
    (`seg062_11E8.c:157`).  Nothing is disabled, so the game windows stay usable, as the code
    states.
  - Owned by the desktop: `_ErrorMessage` (P46-D1).

---

## Summary table

| Item | Verdict | DEFECT | RISK | NOTE |
|---|---|---|---|---|
| P4-5 | Needs a fix (D1: activating an icon leaves the focus on another window, contrary to the header and DESIGN); otherwise correct, with post-send pointer use latent | 1 | 1 | 7 |
| F15 | Pass with notes (F15-01..12 present and accurate; F15-06 complete for the cited sites only; idle end depends on the back end) | 0 | 0 | 2 |
| P4-6 | Needs a fix (D1: the desktop as hwndParent disables nothing and leaves the desktop active and focused after the box); box under a capture latent | 1 | 1 | 5 |

## Rule deviations by this reviewer

Early in the review the Bash tool was used twice for directory listings (`ls` of `claude/port` and
its subfolders, and of `claude/src` and `claude/docs`).  The rules allow the shell only for
creating `rv3` and running showfunc.py.  Both listings were read-only, of allowed paths, and
changed nothing; every later lookup used Read/Grep/Glob.  No forbidden path was read and no other
rule was departed from.

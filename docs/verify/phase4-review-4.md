# Phase-4 review 4: F16 (review-3 fixes), P4-7 (list boxes, statics, DIBs)

Reviewer: independent read-only reviewer (subagent), 2026-10-09.  Nothing was built, compiled or
run; no test, harness, game or port program was executed and no UI was launched.  Project files
were read with Read/Grep/Glob (one early shell listing excepted, see "Rule deviations").
`claude/tools/showfunc.py` was not needed: the machine code was read from `claude/src/asm`
directly, so no `rv4` folder was created.  Paths are relative to `claude/port` unless they start
with `claude/`.  Statements about Windows 3.1 behaviour that this repository does not prove are
marked **(inference)**; memory of Wine is not used as evidence.

Classification: **DEFECT** = wrong behaviour, or a record that misstates the code; **RISK** =
latent or fragile; **NOTE** = wording, a choice worth recording, or a test gap.

---

## F16 (fixes for review 3)

Files: `verify/round8-fixes.md:180-195` against `verify/phase4-review-3.md`; `user_wnd.c` header
(119-151), `activate` / `activate_next` / `w16_SetFocus` (1746-1823), `invalidate_tree` /
`show_sequence` / `hide_sequence` (2115-2197), `destroy_tree` / `free_tree` / `w16_DestroyWindow`
(2254-2353), `set_rect` (2472-2524), `w16_EnableWindow` (2976-2998); `user_msgbox.c` (whole);
`user_misc.c` header (1-35); DESIGN Q12 (1118) and DESIGN 5 "MessageBox" (1031-1043); FIDELITY
F76, F78, F79 (111, 113, 114); STATUS 107-108; `tests/test_user.c` mb_run / mb_probe (1974-2046)
and test_review3 (2266-2294); `claude/src/c/seg068_1218.c:223-224, 271-277`,
`claude/src/asm/seg068_1218.asm:607-622`, `claude/src/c/seg001_1000_p4.c:471-472`, and the game's
WM_DESTROY / WM_ACTIVATE / SetFocus uses in `claude/src/c`.

Checked and found correct:
- **F16-01** (`user_wnd.c:1779-1782`): after WM_ACTIVATE, an active minimized window with any focus
  set calls `set_focus_raw(0)`, so queue.c's no-focus conversion delivers system keys, as the
  header (147-148) and DESIGN 5 (1056) say.  test_review3 (2273-2284): the icon is slot 0,
  (16,420)-(48,452); (32,436) is on it; `c` holds the focus; the expectation active `a` / focus 0
  follows from the code.
- **F16-02** (`user_msgbox.c`): the desktop counts as no owner (400-401); `fuStyle & 0x3000`
  disables every visible enabled top-level window other than the owner (465-473) and they are
  re-enabled with the owner before the box is destroyed (529-536); a capture is released before
  the box exists (474-476); the box then has no owner, so `activate_next` (`user_wnd.c:1789-1806`)
  activates the topmost visible top-level window, never the desktop; the earlier focus is
  restored when it still exists, else the earlier active window unless it is minimized (540-545).
  `_ErrorMessage` passes `GetDesktopWindow()` and 0x1010 (`claude/src/c/seg001_1000_p4.c:471-472`).
  Header 30-34 and 46-48 describe this (with the omissions in F16-N1).  test_review3 (2285-2293):
  `c` focused, a 0x1010 box with the desktop as parent; the probe on `c`'s timer sees `c`
  disabled; Return gives IDOK; afterwards both are enabled and `c` is active and focused — this
  follows from the code.
- **F16-03**: `set_rect` checks `W(hwnd)` before `invalidate_tree` and re-fetches after it
  (2500-2507); `hide_sequence` re-fetches `w` after `expose` and returns when it is gone
  (2183-2186); `title_expose` only repaints the desktop (1555-1560); `invalidate_tree` reads the
  next sibling first and stops when the parent or that sibling is gone (2131-2138).  Its three
  callers (2133, 2158, 2501) all pass a live window.
- **F16-04**: the release is unconditional and recorded as a choice in the header (34); a running
  system loop is not cancelled, as the row says (its loops end on capture loss, F15-02).
- **F16-05**: `user_misc.c:27-29` now records that the minimized map still receives its accelerator
  commands; DESIGN Q12 (1118) is correct: WdwStatusOpen's window style 0x80CC0000 has
  WS_THICKFRAME (`seg068_1218.c:223-224`) and MoveWindow at 1218:050A precedes the data block's
  GlobalAlloc at 1218:0522 (`seg068_1218.asm:611, 617-619`).  The open list matches RV3's P45-N2,
  N3 (both points), N5, N6 and N7.
- **F16-06**: the header (16-17) states MessageBeep's argument as the code passes it (501).  The
  open list matches P46-N3, N4 and N5 (see F16-N1 for P46-N2's wording).
- **F16-07**: the acknowledgement is accurate; the back-end requirement stays open.
- STATUS 107-108 and the F16 row's check counts are consistent (238 + 3 test_review3 checks = 241;
  + 17 test_listbox checks = 258).  The counts themselves were not re-run.

### RISK F16-R1: destroy_tree is not safe as F16-03 states

F16-03 keeps `destroy_tree` unchanged because it "already reads the next sibling first and its
windows live until free_tree".  Reading the next sibling first is the hazard RV3 named, and only
windows already marked `destroying` are protected from an independent DestroyWindow (2310):
- A child's WM_DESTROY handler that calls DestroyWindow on its **next sibling** (not yet marked,
  2261 marks each window only on entry) destroys and frees it at once (2341-2347).  The loop then
  sets `s = n` and reads `W(s)->next` (2266) on a freed handle: a host NULL dereference.
- The **root's** WM_DESTROY handler calling DestroyWindow on the root's parent (not marked) runs
  `destroy_tree(root)` a second time (no `destroying` test at 2256-2262, so WM_DESTROY is sent
  twice), then `free_tree(parent)` frees the root; back in the first call, `w = W(h)` is NULL and
  `w->child` (2263-2264) dereferences it.

Latent: the game's only WM_DESTROY handler posts WM_QUIT (`claude/src/c/seg064_11F8.c:761-764`).
A fault here is a host crash, not a `vm_fault`.  Fix: give the loop F15-06's shape (re-check
`W(h)` and `W(n)` / `W(n)->parent == h` after each call), return from `destroy_tree` when
`W(h)` is NULL after WM_DESTROY, and skip a window already `destroying` at entry; correct the
F16-03 wording.

### NOTE F16-N1: records not brought up to date with F16-02 / F16-04

- DESIGN 5 "MessageBox" (1031-1043) still says only that the loop "disables the owner's top-level
  window" and that "the earlier focus" is restored; it does not mention the desktop as no owner,
  the MB_SYSTEMMODAL / MB_TASKMODAL disabling, the capture release or the earlier active window,
  and its test list has no desktop case.
- FIDELITY F79 (114) says MB_SYSTEMMODAL and MB_TASKMODAL are "treated as application-modal".  In
  Win16 terms MB_APPLMODAL disables only the owner; the code disables every visible enabled
  top-level window of the program (task-modal semantics).  F79 also omits the capture-release
  choice and the 32-window limit.
- The header (46-48) omits the code's exception: an earlier active window that is minimized is not
  re-activated (543-544), which the F16-02 row does state ("not an icon").  The 32-window limit of
  the disabling loop (`MB_OFF`, 94, 467) is not recorded either.
- `user_misc.c:27-29` cites F78 for the minimized map receiving accelerator commands; F78 (113)
  says nothing about accelerators.  F76 (111) is the row that lists "the minimized-window rules of
  TranslateAccelerator" as not modelled.
- STATUS 108 says RV3's "three notes open"; F16-05..07 leave about thirteen RV3 notes open.  F16-06's
  "more than 24 lines" does not cover P46-N2's point that a box of exactly 24 lines is about 487
  pixels high and its caption starts above the screen.

Fix: update DESIGN 5 and F79 ("treated as task-modal: every visible enabled top-level window of
the program", capture release, the limit), the header's last sentence, the cross-reference, and
the STATUS wording.

### NOTE F16-N2: SetFocus into an icon is still undecided and unrecorded

RV3 asked to "decide (and record) whether SetFocus into a minimized top-level window is allowed".
F16 does neither and does not list it as open.  `w16_SetFocus(icon)` (1816-1821) activates the
icon, whose new branch clears the focus, and then gives the icon the focus, so keys arrive as
WM_KEYDOWN instead of system keys.  The new branch (1779-1782) also clears a focus that a
WM_ACTIVATE handler set, unlike the normal branch ("unless the procedure moved the focus").  No
game effect: no game procedure handles WM_ACTIVATE (only WM_ACTIVATEAPP,
`claude/src/c/seg064_11F8.c:611`), and the game's five SetFocus calls never target a minimized
window.  MessageBox's restoration avoids the case by not re-activating an icon (543-544), so an
icon that was active before the box stays inactive afterwards.  **(inference)** Windows 3.1 allows
SetFocus to an iconic window.  Fix: record the choice in the header and F78, or list it open.

### NOTE F16-N3: test gaps

test_review3 probes only `c`'s enabled state (mb_probe 1994), not `a`'s.  These are not covered:
MB_TASKMODAL; the earlier-active fallback (focus window destroyed during the box, or no earlier
focus); the minimized-earlier-active exception; the capture release; more than 32 top-level
windows; windows destroyed during `set_rect`, `hide_sequence`, `invalidate_tree` or
`destroy_tree` (F16-03 claims no test; F16-R1).

---

## P4-7 list boxes, statics and DIBs

Files: `platform/w16/user_listbox.c` (whole); `user_ctl.c` header (1-89), `w16_ctl_reset` /
`w16_ctl_window_gone` (194-207), `w16_ctl_class_supported` (226-241), STATIC (1008-1152), routing
(1156-1170); `user_wnd.c` the predefined classes (4043-4049), the creation check (1926-1933),
`vis_region` / `upd_add` / `sync_erase` (694-827), `expose` (1565-1633), `w16_BeginPaint`
(2767-2812), standard scroll bars (3310-3402), reset (4006-4065); `user_dlg.c` header (20-46) and
IsDialogMessage (770-834); `gdi_obj.c` header (1-34), `w16_bitmap_new` (261-278),
`w16_CreateDIBitmap` (358-415); `vm.c` accessors (520-638); `gdi_dc.c` ReleaseDC (191-203);
`gdi_font.c` header (1-43), TextOut / GetTextExtent / DrawText entry (665-809); `queue.c`
TranslateMessage (601-623); `dos.c` `component83` (57-94); `w16_int.h` (227-257, 279-280);
`w16_unimpl.c`; DESIGN 3.7 (778-784), DESIGN 5 (1015-1030) and the Q table (1110-1122); FIDELITY
F80 (115); STATUS 107-108 and 467-470; `tests/test_user.c` test_listbox (2118-2263);
`tests/test_io.c` Q17 (425-445).  Game side: `claude/src/c/seg020_1098_p1.c` (GR_DialogOpen
398-554, DlgProc 606-663, CivDialogProc 672-697, RunListBoxDialog 720-923, ListDialogSubclassProc
933-999), `claude/src/asm/seg020_1098.asm:3810-3939`, `claude/src/c/seg047_1170_p2.c:61-135,
137-276, 703-717`, `seg047_1170_p3.c:40-111`, `seg013_1060.c:385-457, 469-567`,
`seg023_10B0_p2.c:225-249`, `seg021_10A0.c:167-200`, `seg033_1100.c:643-652`, and
`claude/docs/resources.md:133-147, 149-157, 198-206, 291-303`.

Checked and found correct:
- **The game's use is covered.**  Every SendMessage / SendDlgItemMessage site in `claude/src/c`
  was listed; the list-box ones are RunListBoxDialog (`seg020_1098_p1.c:814-901`: LB_SETCOLUMNWIDTH,
  WM_SETFONT, LB_ADDSTRING, LB_GETCOUNT, LB_GETITEMRECT, LB_SETCURSEL, LB_GETCURSEL, LB_GETTEXT) and
  ChooseCityProduction (`seg047_1170_p2.c:131, 175, 245, 274, 708, 716`: WM_SETFONT, LB_ADDSTRING,
  LB_SETCURSEL, LB_GETCURSEL).  `SendDlgItemMessage(…, 0x401, …)` (`seg033_1100.c:650`) is SelIText's
  EM_SETSEL to edit items (callers `seg031_10F0.c:112`, `seg069_1220_p2.c:309`), not a list box.
  Each message is handled with the result the game reads: LB_GETCURSEL's LB_ERR (-1) gives
  `items[0]` (`seg047_1170_p2.c:716-717`); LB_GETTEXT writes `len + 1` bytes into the game's
  32-byte `selText` through bounds-checked emulated memory, so the original's unbounded copy is
  reproduced, not a host overflow (`user_listbox.c:918-919`); notifications use
  MAKELONG(list, code) (552), so HIWORD(lParam) == 2 is read as LBN_DBLCLK at 1098:1E41 and
  1170:20A3 (`seg020_1098_p1.c:972-978`, `seg047_1170_p3.c:101-104`).
- **LB_GETITEMRECT** writes the game's own RECT: 1098:1B6A is `lea ax, [bp-0x2C]` pushed with SS
  (`seg020_1098.asm:3910-3916`), and 1B74-1B7A reads bottom (bp-0x26) minus top (bp-0x2A).  The
  code writes through `lParam` (`user_listbox.c:943-951`), as DESIGN 3.7 (782-783) now says.
- **The other notifications are harmless to the game**: LBN_SETFOCUS / KILLFOCUS / SELCHANGE reach
  DlgProc (ids 103/104 are not 0x65/0x66 and not 0x0D, `seg020_1098_p1.c:641-658`),
  ListDialogSubclassProc (103 without LBN_DBLCLK breaks to DefDlgProc, 972-974) and
  ModalDialogSubclassProc (104 without code 2 breaks, `seg047_1170_p3.c:101-107`).  LBN_SETFOCUS from
  `SetFocus(hList)` (1098:1AF6) arrives before either subclass is installed and is ignored too.
- **LB_ messages and constants**: 0x401..0x419 as listed; the game's own defines agree
  (`seg020_1098_p1.c:15-28`, `claude/src/include/win16.h:233-236`); others in 0x400..0x42F fault
  (953-957).  CTLCOLOR_LISTBOX 2, DLGC_WANTARROWS | DLGC_WANTCHARS 0x81, LBN_ 1/2/4/5 and SB_/VK_
  values are the standard ones.
- **Insertion and removal**: LBS_SORT inserts after equal items with the case-insensitive compare
  (865-871, 604-619); `insert` (621-654) grows the array before shifting, keeps the selection on its
  item and returns the index; `remove_at` (656-669) clears or shifts the selection; LB_RESETCONTENT
  resets the top; LB_ERRSPACE at 4096 items; strings are read at most 255 bytes (586-602).
- **Bounds**: every wParam index is tested against `[0, n)` (or `[-1, n)` for LB_SETCURSEL) before
  use; `item_at`, `visible`, `ensure_visible`, `user_select`, the WM_CHAR search (`% n` with n > 0)
  and `keydown` (n == 0 returns) never index outside the items; the 256-byte scratch string holds
  every item (480, 502); emulated reads and writes go through `vm_resolve`'s selector checks
  (`vm.c:520-546`), so a bad pointer faults instead of touching host memory.
- **Layout**: `rows_of`, `col_w` and `item_h` are at least 1; `layout` (295-342) is bounded to three
  passes and guarded by `busy` against the WM_SIZE its bar changes send; a bar is shown before the
  second pass recomputes the range for the smaller client, and hiding a bar only adds rows, so the
  passes settle (no oscillation).  Multicolumn `clamp_top` keeps the top at a column start.
- **Painting**: WM_CTLCOLOR(hdc, MAKELONG(list, 2)) to the parent; the check `lb_of(hwnd) != b`
  after it (475) prevents use of a freed record; the brush (DlgProc's gray, else WHITE_BRUSH)
  fills the client; the selection is a (0,0,128) fill with white transparent text; disabled grey
  text; the font is restored only while the window exists; ReleaseDC frees a non-own DC whatever
  the window (`gdi_dc.c:191-203`).
- **Input**: keys, letters, clicks and double clicks as the header says (673-708, 807-858); the
  WM_LBUTTONDOWN path re-checks `lb_of(hwnd) == b` after SetFocus and after `user_select` (820-842);
  the drag uses the actual capture (844); the class is registered with CS_DBLCLKS
  (`user_wnd.c:4047`).  With the dialog manager, arrows reach the list (DLGC_WANTARROWS), PgUp /
  PgDn / Home / End are dispatched, WM_CHAR is dispatched to it, and Return / Escape stay with the
  dialog (`user_dlg.c:779-833`).
- **Re-entrancy elsewhere**: `user_select`, `scroll`, LB_SETCURSEL, LB_SETTOPINDEX, WM_SETFOCUS and
  WM_KILLFOCUS touch `b` only before their sends, and `notify` uses only the handle (GetParent of
  a destroyed window is 0).  `insert`'s `repaint` after `layout` reads nothing of `b` before the
  475 check (but see P47-R1 for `layout` itself).
- **Lifetime**: WM_NCCREATE allocates (replacing a stale record, 741-753); WM_NCDESTROY and
  `free_tree`'s `w16_ctl_window_gone` free it once (the second call finds NULL, 185-192);
  `w16_user_reset` → `w16_ctl_reset` → `w16_listbox_reset` (`user_wnd.c:4021`,
  `user_ctl.c:194-198`).  `w16_listbox_style_supported` (205-209) admits exactly the six recorded
  styles; the creation check faults otherwise (`user_wnd.c:1926-1933`); the game's styles
  0x50A00001 and 0x40900203 pass.
- **STATIC**: low word ≤ 2 only (`user_ctl.c:234-235`); DrawText format `style & 3` gives DT_LEFT 0,
  DT_CENTER 1, DT_RIGHT 2 per line (1102-1103).  DIALOG 666's item 103 is 0x50020001
  (`resources.md:302`), opened at `seg023_10B0_p2.c:235` with WM_SETFONT lParam 0 (no repaint).
  DIALOG 133's SS_CENTER statics and DIALOG 150's SS_ICON are in templates the game never opens
  (no GR_DialogOpen of 0x85 or 0x96).
- **SetScrollRange** (`user_wnd.c:3345-3369`): the range is stored and the position clamped first;
  an equal range on a window with the bar, or a non-empty range on one without it, flips the
  style bit and calls `set_rect` with the same rectangle and repaint (WM_SIZE when the client size
  changes; a WS_MAXIMIZE window gets SIZE_MAXIMIZED); otherwise fRedraw repaints the bar.  The header rule
  (3318-3324) matches, and the game's own ranges are never empty
  (`claude/src/c/seg064_11F8.c:1042-1043`, `seg066_1208_p1.c:183-185`).
- **CreateDIBitmap** (`gdi_obj.c:358-415`): header offsets 4/8/14/16/32 are BITMAPINFOHEADER's;
  RGBQUAD B,G,R is turned into COLORREF 0x00BBGGRR (400-401); rows are `(w + 3) & ~3` bytes,
  bottom-up for a positive height (404-412); width and |height| ≤ 0x7FFF keep every product in
  32 bits; the host array index stays inside `w * ah`; all DIB reads are emulated and checked.
  The game's call (`seg021_10A0.c:190-191`) passes CBM_INIT, the packed DIB as both headers and
  DIB_RGB_COLORS, as the header says; the device has RC_PALETTE (F25), so the call is not reached.
- **Declarations and stubs**: `w16_int.h:253-257` declares the four list-box entry points;
  `w16_unimpl.c` has no stubs left; CreateDIBitmap and SetScrollRange are in `w16_api.h:18, 140`.
- **Q decisions**: Q6 (`queue.c:621-622`: 1 for 0x100, 0x101, 0x104, 0x105); Q10 (`user_dlg.c:39-46`,
  804-826); Q11 (`gdi_font.c:34-35, 682-684, 729-731`); Q17 (`dos.c:84-90` keeps three extension
  characters, so "LOSE2.wav " is LOSE2.WAV; `test_io.c:425-445`); Q22's header (`gdi_font.c:13-15`)
  agrees with DESIGN (1122) (the enumeration code itself was not re-traced).
- **Records**: DESIGN 5 (1015-1030), F80 and the STATUS note (467-470, whose "the list box with
  WM_DRAWITEM" is corrected by its own parenthesis) agree with the code, except as listed below.
  The survey claims hold: no owner-drawn list, no '&' in any dialog text (`resources.md`).
- **test_listbox, by hand** (system font 16 pixels assumed only for the arithmetic; the test
  computes `rows` itself): the empty list's bar is hidden by the creation WM_SIZE; three items
  fit; ten items show the bar with range 0..10-rows; LB_SETCURSEL 8 sets top 9-rows; item 8 is
  the last visible row; the highlight is drawn at once by `repaint`; focus and Down give
  LBN_SETFOCUS and LBN_SELCHANGE; 'c' finds Carthage from 9 by wrapping and scrolls the top to 2;
  the double click on row 1 is Delhi with LBN_DBLCLK; WM_CTLCOLOR carries 2; the sorted list is
  alpha..Delta in one column, and 44 items in 60-pixel columns need more than three columns; the
  4 x 2 DIB comes back top row red, bottom row blue.  All expectations follow from the code.

### DEFECT P47-D1: a click on the partly visible column selects the item to its left

`paint` draws one extra, partly visible column (490-493), but `item_at` clamps the column to the
fully visible ones (386-390), so a point in the partial column is mapped to the previous column of
the same row.  The header says the click selects "the item under the point" (52).

The Civilopedia's list hits this every time: RunListBoxDialog sets (16,16)-(496,274), shrinks it
by 1, takes `columnWidth = 478 / 3 = 159` and snaps the width to 477 (`seg020_1098_p1.c:764,
791-805`).  With WS_BORDER the client is 475 pixels wide, so `vis_cols` is 475 / 159 = 2
(256-264) while the third column is drawn at x 318..474 (157 of its 159 pixels).  A click at
x = 400 gives `col = 2`, clamped to 1: the item one column to the left is selected; a double click
opens that topic through OnCivilopediaListSelect.  The same clamp applies to the drag (845).
Related effects of counting only full columns: Right from the second column scrolls the list by a
column although the target is on the screen (`ensure_visible`, 419-426, via `visible`, 407-408), the
focus rectangle is not drawn on a selection in that column (520), and the horizontal bar appears as
soon as the items need more than two columns.  The sections with more than two columns of topics
(advances: 67 entries, `seg013_1060.c:521-525`) all show it.  **(inference)** Windows 3.1 hit-tests a
partly visible column like a full one.  test_listbox's multicolumn list (198 / 60) is never clicked.

Fix (smallest): in `item_at`, limit `col` with the number of columns at least partly visible,
`(cw + colw - 1) / colw`, instead of `vis_cols`; decide (and record in F80) whether `visible`,
the page and the bar also count the partial column.  Add a click test on the Civilopedia geometry.

### RISK P47-R1: use after free when a list box is destroyed during `layout`'s sends

`layout` calls `w16_SetScrollRange` (323, 335), whose `set_rect` sends WM_NCPAINT and the
synchronous WM_ERASEBKGND to the parent and siblings, WM_NCPAINT to the list and WM_SIZE to the
list (whose `repaint` sends WM_CTLCOLOR to the parent).  If any of these handlers destroys the list
or its parent, WM_NCDESTROY frees `b` (758-760).  The loop then stops on `w16_wnd_is_window`, but
`b->busy = 0u` (341) writes the freed record; if the handle was meanwhile reused by a new window,
`w16_wnd_is_window` is true and `clamp_top` / the next pass read and write freed memory.
LB_DELETESTRING returns `b->n` (885) after `layout` and `repaint` (883-884), a read after free on the
same sequence.  Latent: the game's WM_CTLCOLOR / WM_ERASEBKGND / WM_NCPAINT handling (DlgProc,
DefDlgProc) destroys nothing.  It is a host heap corruption, not a `vm_fault`.  Fix: in `layout`,
after each SetScrollRange / SetScrollPos return at once, without touching `b`, when
`lb_of(hwnd) != b`; in LB_DELETESTRING keep the count in a local before `layout`.

### RISK P47-R2: the game's list dialogs paint their snapshot over the list's scroll bar

RunListBoxDialog takes a snapshot of the dialog's client area (1098:19EC) before the list is
filled or created, and ListDialogSubclassProc's WM_PAINT copies it back over its update region
(`seg020_1098_p1.c:773-785, 943-957`).  The dialog (0x80400080) has no WS_CLIPCHILDREN, so its paint
DC includes the children (`user_wnd.c:737-745, 756`).  In the port:
1. GR_DialogOpen shows the dialog (0x40, `seg020_1098_p1.c:507-508`): its whole client becomes its
   update region, and nothing validates it until the busy loop's first PeekMessage.
2. The list's frame and bars are drawn synchronously (WM_NCPAINT from `invalidate_tree` or from the
   SetScrollRange path) when the bar first appears (Find City, while filling the visible template
   list) or when the list is shown at 1098:1BD0 (Civilopedia, created after the snapshot).
3. The first WM_PAINT goes to the dialog (parent before child), which copies the old snapshot over
   the whole list rectangle; the list's WM_PAINT then repaints only its client area (BeginPaint
   sends no WM_NCPAINT, 2767-2812).

Result: in Find City (DIALOG 131) with more cities than rows, the vertical bar's strip shows the
snapshot's gray; in the Civilopedia the horizontal bar and the list's own border disappear (the
outer QdFrameRect frame remains), until a scroll action calls SetScrollPos with redraw.  The
Civilopedia's hide/show around each selection (1098:1C72, 1C8F) repeats it.  ChooseCityProduction
(DIALOG 140) is not affected: its list is filled while the dialog is hidden and DlgProc's WM_PAINT
draws nothing (`seg020_1098_p1.c:617-629`).  Whether Windows 3.1 showed the same artifact is not
known: it depends on whether its deferred painting redraws a child's frame after a parent without
WS_CLIPCHILDREN painted over it **(inference either way)**.  Related choice: the SetScrollRange
hide/show path repaints "as by MoveWindow to the same rectangle" (3319-3321), which exposes the
window's whole rectangle in the parent (WM_NCPAINT, synchronous erase and a later WM_PAINT) although
nothing was uncovered; **(inference)** Windows 3.1 redraws only the window's frame.  Not recorded, not
tested.  Fix: confirm the expected picture with the user (phase 7), and either record it in F80 or
send WM_NCPAINT to the visible children a parent without WS_CLIPCHILDREN painted over before their
WM_PAINT; let the bar hide/show redraw the window's frame and client only.

**Status (2026-10-15): fixed** by base-track fix RV4 P47-R2 after the user's decision of 2026-10-11
(`docs/p47r2-record.md`; independent review `verify/p47r2-review.md`, verdict accept; its changes are
covered by D4b3's combined eight-step cycle, ALL_GREEN, `build/d4b3-status.txt`); the user's visual check
is pending (`manual-checklist-ext.md` P47-1). A frame that a non-clipping parent's paint covered is drawn
again by the window's next BeginPaint (WM_NCPAINT first). **Related choice: resolved** by the fix's rule 2:
a bar shown or hidden by SetScrollRange now repaints the window itself only (its frame at once, its
client area invalidated, WM_SIZE when the client size changes) and exposes nothing in the parent or
below; recorded in F80 and DESIGN 5 and in `user_wnd.c`'s SetScrollRange comment. **Status of the
related choice (2026-10-15, P47b):** tested directly since base-track unit P47b (`test_user` `test_p47b`
(2): the bar hidden and shown with nothing reaching the popup or the lower window; `p49-findcity-bar` must
stop at its virtual-time limit, not at the step watchdog; review finding 2). The old path also exposed the
map window, whose WM_PAINT stalled RunListBoxDialog's loop (1098:1BEE) when Find City needed its bar; that
case is fixed. The loop's stall on any other window's exposure while a list dialog is open (review finding
1, pre-existing; in civ64 a hang, F86) is **fixed** by base-track unit P47b (2026-10-15,
`docs/p47b-record.md`; three-step cycle ALL_GREEN, `build/p47b-status.txt`): the loop still gets that
window's WM_PAINT again and again, as in Windows 3.1 **(inference)**, but a repeat with no validation and
no time charged since is an idle poll that takes host input (`queue.c` "An undispatched WM_PAINT";
choice), so the dialog answers keys and closes and the window is painted after it closes; the user's check
is pending (`manual-checklist-ext.md` P47-2). The Civilopedia's hide/show does not repeat the artifact in
the port (review finding 3: RunPediaModalLoop dispatches every message while the list is hidden), so the
fix is verified after the hide/show rather than needed there. Whether Windows 3.1 showed the
artifact remains not known **(inference)**.

### NOTE P47-N1: header wording against the code

- PgUp / PgDn move "by a page (the rows ...)" (46-47), but a single-column list moves by `rows - 1`
  (694-695).
- "An index outside the items returns LB_ERR" (23), but LB_INSERTSTRING with wParam below -1 appends
  (873-877, 629-631).
- The multicolumn mouse rule "the item under the point" (52) is contradicted by P47-D1.

No game effect.  Fix: align the wording (or the code).

### NOTE P47-N2: CreateDIBitmap details

- `ah = h < 0 ? -h : h` (375) is signed overflow (undefined) for biHeight = INT32_MIN; in practice it
  stays negative and faults.  Compute in a wider type or reject INT32_MIN first.
- A negative biHeight is accepted as a top-down DIB (405); **(inference)** Windows 3.1 knows no
  top-down DIBs.  Not recorded as a choice.
- biPlanes is not checked.
- Pixel values at or above biClrUsed map to physical entry 0 (`map` zero-filled, 395-397) instead
  of reading further table entries; not recorded.
- Dimensions up to 32767 x 32767 make `w16_bitmap_new` request up to 1 GiB of host memory
  (`gdi_obj.c:276`), as CreateBitmap already can.

Unreachable in the game (RC_PALETTE).  Fix: record or tighten.

### NOTE P47-N3: limits and 16-bit coordinates

`item_rect` stores `(i - top) * ih`, `col * w` and their sums in int16 (356-364).  With LB_MAX 4096
items a row more than about 2047 rows (16-pixel rows) away from the top wraps, so LB_GETITEMRECT of
a far item returns a wrong rectangle; a large LB_SETCOLUMNWIDTH wraps `col * w` likewise.  Items are
cut to 255 bytes and LB_GETTEXT / LB_GETTEXTLEN report the cut length (choice, F80).  The game asks
only for item 0's rectangle, and its item strings are far shorter than 255 bytes (RunListBoxDialog
copies each through a 64-byte buffer, `seg020_1098_p1.c:823`; the production lines are about 40
characters).  Fix: none needed; mention the int16 limit beside LB_MAX in the header.

### NOTE P47-N4: test gaps

test_listbox does not cover: LB_INSERTSTRING, LB_DELETESTRING, LB_RESETCONTENT, LB_SETTOPINDEX,
LB_GETTEXTLEN, an unsupported LB_ message or style (the faults); WM_VSCROLL / WM_HSCROLL and a bar
drag; PgUp / PgDn / Home / End / Left / Right (multicolumn); the capture drag; a bar hidden again
after removals; LBN_KILLFOCUS; disabled drawing; LB_ERRSPACE and the 255-byte cut; a click in a
partial column (P47-D1); destruction inside a callback (P47-R1); the dialog repaint (P47-R2).  The
SS_CENTER static is only created, not drawn or checked.  The DIB test uses a 4-pixel width, so row
padding, a top-down DIB, biClrUsed 0 and the fault paths are not exercised.  Q17's test covers the
name and the return value, not the back end's playing (phase 5).

**Status (2026-10-15):** the dialog repaint (P47-R2) is now covered by `test_user` (`test_p47r2`) and
`p4tests.py` (`findcity`, `listbar`; `docs/p47r2-record.md`); since base-track unit P47b also by
`test_user` `test_p47b` (rule 2 directly, a bordered grandchild below a WS_CLIPCHILDREN child, a window
destroyed by its own WM_NCPAINT inside BeginPaint) and the `listbar` runs `p49-findcity-bar` (must stop
at its virtual-time limit) and `p49-findcity-resize` (`docs/p47b-record.md`); the other gaps listed here
stay.

---

## Effects on the game

- **Civilopedia** (DIALOG 130 with the created "Listbox", 3 x 159-pixel columns in a 475-pixel
  client): the third column is drawn but a click on it selects the item in the second column of the
  same row, and a double click opens that topic (P47-D1); moving into the third column with Right
  scrolls the list; the horizontal bar appears from three columns of topics.  The horizontal bar
  and the list's border are shown once the dialog has opened (P47-R2 fixed 2026-10-15; before, they
  were painted over by the dialog's snapshot until the user scrolled). A host resize (or any other
  window's exposure) while the list dialog is open no longer hangs the game (P47b, 2026-10-15,
  `docs/p47b-record.md`; the user's check pending).
  Sorting is case-insensitive ASCII (choice); OnCivilopediaListSelect maps the chosen text back by
  strcmp, so the order does not affect which topic opens.
- **Find City** (DIALOG 131, template list 103): items in the game's own qsort order (no
  LBS_SORT); Return gives DM_GETDEFID's 101 ("Go To City"); a double click accepts; the vertical bar,
  when needed, is shown once the dialog has opened (P47-R2 fixed 2026-10-15; before, it was hidden
  under the snapshot until a scroll).  A list that needs its bar no longer stalls the dialog's loop
  (the map window is no longer exposed). A host resize (or any other window's exposure) while the
  dialog is open no longer hangs the game (review `verify/p47r2-review.md` finding 1, fixed by
  base-track unit P47b, 2026-10-15, `docs/p47b-record.md`): the loop still gets that window's WM_PAINT
  again and again, but each repeat is an idle poll that takes input, so the dialog answers keys and
  closes, and the window is painted after it closes (run `p49-findcity-resize`; the user's check
  pending).
- **City production** (DIALOG 140, list 104): filled while hidden; the current production is
  preselected by LB_SETCURSEL; a double click or OK returns the selection; LB_ERR maps to the
  current production.  No visible artifact found.
- **Artwork conversion** (DIALOG 666): the title static is centred on each line.
- **CreateDIBitmap**: not reached on the emulated palette device.
- **`_ErrorMessage`** (F16-02): every visible game window is disabled while the system-modal error
  box is open (clicks on them get HTERROR and a beep, P4-1); afterwards the earlier focus and
  activation return.
- **Minimized map** (F16-01): clicking the icon now leaves no focus in another window, so keys
  reach the icon as system keys.

---

## Summary table

| Item | Verdict | DEFECT | RISK | NOTE |
|---|---|---|---|---|
| F16 | Pass with notes (F16-01..04 as stated; F16-03's "no change" for destroy_tree rests on a wrong premise; DESIGN 5 / F79 / header / cross-reference not updated; SetFocus into an icon undecided) | 0 | 1 | 3 |
| P4-7 | Needs a fix (D1: a click in the Civilopedia's partly visible third column selects the item to its left); otherwise sufficient for every message and notification the game uses; use after free in `layout` latent; scroll bars hidden by the game's snapshot repaint unconfirmed | 1 | 2 | 4 |

## Rule deviations by this reviewer

At the very start the Bash tool was used once for `ls` of `claude/port/docs/verify` and `wc -l` of
`phase4-review-3.md` and `round8-fixes.md`.  The rules allow the shell only for creating `rv4` and
running showfunc.py.  The command was read-only, on allowed paths, and changed nothing; every later
lookup used Read/Grep/Glob.  No forbidden path was read, showfunc.py was not run, no scratch folder
was created, and no other rule was departed from.

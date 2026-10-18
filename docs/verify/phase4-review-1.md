# Phase-4 review 1: P4-1 (mouse routing), P4-2 (non-client drawing), F13 (record wording)

Reviewer: independent read-only reviewer (subagent), 2026-10-09.  Nothing was built, compiled or
run; no test, harness or game execution.  The code and records were read with Read/Grep; listing
claims were checked with `claude/tools/showfunc.py` (outputs in the scratch folder `rv1`).
Statements about Windows 3.1 behaviour that are not in this repository are marked **(inference)**;
where they come from memory of Wine/OTVDM sources they are not Windows 3.1 evidence.

Classification: **DEFECT** = wrong behaviour, or a record that misstates the code; **RISK** =
latent or fragile; **NOTE** = wording or test gap.

---

## P4-1 mouse routing

Files: `platform/w16/queue.c`, `queue.h`, `platform/w16/user_wnd.c` (hit_test, child_at,
window_at, hook_route, raise_top, hook_mouse_taken, DefWindowProc WM_NCHITTEST /
WM_MOUSEACTIVATE / WM_SETCURSOR), `tests/headless/harness.c`, `tests/harness/input.script`,
`tests/test_queue.c` test_mouse_raw, `tests/test_user.c` test_mouse, DESIGN 5 "Mouse input",
DESIGN 10 rows, FIDELITY F75.

Checked and found correct: W16Msg initialisation on the posting paths (queue.c:209-219;
TranslateMessage's post 513-524); the pre-check (382-386) and its interaction with the game's
filters (KEYFIRST..KEYLAST skips raw mouse input without routing; 0x200..0x209 routes and leaves
non-client results queued); the drop path (396-399, no key-state change); key_state's non-client
mapping (283-285); the MK_ state (155-182, including the DBLCLK numbers); capture routing
(2764-2766); the HTCLIENT / non-client parameter conversion (2805-2812); the double-click
time test with unsigned wrap (2789); hook_mouse_taken after a destroyed window (2877-2879,
2895, 2898); DefWindowProc's parent-first chains (3011-3036); C17 types (no VLA, no
implementation-specific extensions; see N9 for conversions).

### DEFECT D1: raise_top never repaints the raised windows' children

`user_wnd.c:2845-2863`.  For the raised top-level window and each owned window it computes the
newly visible part of the window rectangle, calls `nc_paint(w)` and `upd_add(w, ...)` on that
window only.  Child windows are neither invalidated nor sent WM_NCPAINT.  The other exposure
path does it right: `expose_tree` (1263-1287) recurses into children with `upd_add`, WM_NCPAINT
and `sync_erase`.

Scenario (game): MenuZ (`seg069_1220_p1.c`, 1220:0156) creates its options as RanDoMRadio child
windows (1220:0964) and runs an unfiltered loop (1220:0AC0, `PeekMessage(&g_msg, 0, 0, 0,
PM_REMOVE)`), so a click on another top-level window is removed and runs hook_mouse_taken.  The
user clicks the Small Map or Status window (activated and raised, now covering part of the MenuZ
dialog), then clicks the MenuZ dialog: raise_top(dialog) invalidates only the dialog's client
area.  The options' pixels under the formerly overlapping window are never repainted: with
WS_CLIPCHILDREN on the dialog they keep the other window's pixels; without it the dialog's erase
paints over them and they vanish.  The records (user_wnd.c:79-83, DESIGN 977-978 "the uncovered
client areas are invalidated with erase") do not say children are excluded.

Fix direction: invalidate the newly visible region through the same recursion as `expose_tree`
(per moved window, children included), or call `expose_tree` with the uncovered area.

### DEFECT D2: raise_top keeps only directly owned windows above the raised window

`user_wnd.c:2827-2844` collects `W(s)->owner == h` only.  A window owned by an owned window
(owner chain) stays where it was, so after the raise it is below its owner's owner.  Windows
keeps an owned window above its owner (SDK description of owned windows; **inference** that
Windows 3.1 applies it transitively here, which follows from the rule applied to each link).

Scenario (game): GR_DialogOpen (`seg020_1098_p1.c:420-424`, 1098:1268) makes the current dialog
the owner of a new dialog, and the dialog stack (`g_dialogPortStack`, 546-573) nests them, so a
ShowTextDialog/MenuZ prompt D2 opened while another GR dialog D1 is open has the chain map → D1 →
D2.  In MenuZ's unfiltered loop the user clicks the map: WM_MOUSEACTIVATE → MA_ACTIVATE →
raise_top(map) moves the map and its directly owned D1 / Status / Small Map windows to the top;
D2 ends below the map (z-order D1, Status, Small Map, map, …, D2).  The prompt D2, whose loop is
still running, is hidden behind the map; keys now go to the map (focus) and MenuZ drops them
(IsDialogMessage(D2) fails, 1220:0ADA).  Only a click on D1 (which raises D2 with it) recovers.
The 32-entry `owned[]` cap (2827) is also silent.

The records (user_wnd.c:81-82, DESIGN 977) say "with its owned windows above it"; literally true
for direct ownership, but the resulting z-order contradicts the SDK rule the record implies.

Fix direction: collect owned windows transitively (owner chain to h), preserving their relative
order, or relink each owned window directly above its owner after the move.

### DEFECT D3: raw mouse moves no longer coalesce once the last move was routed

`queue.c:199-202` coalesces a new move into the last entry only when that entry is a
WM_MOUSEMOVE with the same hwnd and the same kind.  A raw move has hwnd 0 and kind RAW; once
PeekMessage has examined the previous raw move it is ROUTED with a window handle (400-401), so
every later raw move appends a new entry.  A routed move that the current pump does not take
stays in the queue indefinitely.

Scenario (game): the window-filtered busy loops RunTextEntryDialog (`seg031_10F0.c:118-121`,
10F0:014B, `PeekMessage(&g_msg, port->hwnd, 0, 0, PM_REMOVE)`) and RunModalDialogLoop
(`seg047_1170_p3.c:48-55`, 1170:1FDA, filter `dlg->hwnd`) examine every queued message on each
iteration.  Moving the mouse over the map while such a dialog is up routes each move to the map
window; none is removed; each new move adds an entry.  After W16_INPUT_MAX (120) entries
`w16_queue_post_input` returns -1 and the harness drops every later event ("queue full",
harness.c:538-545): the typed name, Enter, and clicks in the dialog are lost and the dialog
cannot be completed.  Before P4-1 the same hwnd-0 moves stayed plain with hwnd 0 and coalesced
into one entry.  Reachable today through harness `hwnd 0` mouse lines (no checked-in scenario has
them yet); DESIGN 955 says the back end will post its mouse input the same way.  Windows 3.1
coalesced mouse moves in the system queue (**inference**).  (Pre-existing and unchanged: while
any input is queued no WM_TIMER is generated, queue.c:440, so stuck routed moves also hold back
timers for the dialog's duration.)

Fix direction: let a raw move replace a trailing move that originated as raw input, whether RAW
or ROUTED, resetting it to RAW so it is routed again at the new position; add a test that
routes a move with a non-matching window filter and then posts more moves.

### RISK R1: a disabled top-level window routes HTERROR to its deepest enabled child

`user_wnd.c:2768-2773`: `h = window_at(...)` descends into children (child_at checks only the
child's own `disabled`, 2732), then `W(top_of(h))->disabled` gives HTERROR for `h`, the child.
WM_SETCURSOR(HTERROR) then goes to the child; DefWindowProc asks the parent first (3021-3024),
the parent beeps and returns 0 (3025-3029), and the child beeps again: one beep per level (two
for a dialog control, three for a nested one).  A second click within the double-click limits
becomes a non-client DBLCLK (2793-2794), whose client number 0x0203 is not a button down for
3026, so it does not beep at all.  Windows routes the point to the disabled top-level window
itself with HTERROR (**inference**, also Wine's behaviour from memory, not Windows 3.1
evidence).  The record (user_wnd.c:69, DESIGN 965) does not name the receiving window.  Latent:
the game disables only child controls (`seg020_1098_p2.c:440-445`, `seg069_1220_p1.c:356-423`);
system-modal disabling arrives with MessageBox/DialogBox (P4-6).  test_user disables only a
childless top-level window (test_user.c:1022-1030).

### RISK R2: HTTRANSPARENT is not handled

hook_route (2775-2812) treats any non-HTCLIENT code, including HTTRANSPARENT (-1), as a
non-client hit for that window (wParam 0xFFFF).  Windows passes HTTRANSPARENT to the window below
in the same task (**inference** from the SDK).  No port procedure returns it today (static and
group-box controls use DefWindowProc → HTCLIENT), so a click on the city-name dialog's static
item 104 goes to the static control, not the dialog (**inference** that Windows 3.1's static
returned HTTRANSPARENT; no game procedure relies on such clicks).

### RISK R3: routing re-entrancy and the queue-change fault

`queue.c:387-395`: the entry stays RAW while `g_route` runs.  A window procedure that calls
PeekMessage/GetMessage while handling WM_NCHITTEST finds the same RAW entry and routes it again,
recursively without bound (host stack overflow, no fault).  The fault check (390-395) also fires
for any posting during the send: the harness posts due events at every API step
(harness.c:527-546), so a WM_NCHITTEST handler that advances the virtual clock (GetTickCount,
clock.c:189-195; a PeekMessage that finds nothing, queue.c:452) and then makes any API call
would fault with "the input queue changed".  Latent: no game window procedure handles
WM_NCHITTEST (they reach DefWindowProc, which does not advance the clock).  Marking the entry
"being routed" (and skipping it in nested calls) would make both safe.

### RISK R4: double-click rectangle bound

hook_route (2788-2790) accepts |dx| <= 2 and |dy| <= 2 inclusive, a 5 x 5 square; the
time test is `<=` 500 ms.  Wine uses strict `<` on both distance (half of SM_CXDOUBLECLK) and
time (memory of Wine's message.c; **inference**, not Windows 3.1 evidence).  The bound matters
to the game: all of its classes have CS_DBLCLKS (CIV 0x2B, WdwSmMap 0x28, WdwStatus 0x2B,
CIVDIALOG 0x28) and WdwMapProc (`seg064_11F8.c`) has no WM_LBUTTONDBLCLK case, so a second map
click that qualifies as a double click goes to DefWindowProc and is lost (faithful in mechanism;
which clicks qualify depends on this bound).  The test at test_user.c:1051 fixes the inclusive
edge (dx 2, dy -2) as expected behaviour.  See also N4.

### RISK R5: the pre-check ignores the DBLCLK numbers; routing order under partial filters

`queue.c:382-386` tests the raw (client) number and its non-client number only.  A filter that
selects only a DBLCLK message (e.g. 0x0203..0x0203) skips a raw 0x0201 that would route to
WM_LBUTTONDBLCLK, so it never retrieves it.  Under a partial filter, later raw messages are
routed before earlier skipped ones (hit tests at different times, window positions possibly
changed in between).  Latent: the game's filters are 0/0, KEYFIRST..KEYLAST and 0x200..0x209
(`seg033_1100.c:773`, `seg063_11F0_p2.c:394-397`, `seg019_1090.c:647/697`), none DBLCLK-only.

### RISK R6: W16Msg locals with indeterminate mouse fields

The QUIT / PAINT / TIMER results in PeekMessage (queue.c:360-370, 429-437, 442-449) and
DispatchMessage's `m` (464-471, passed to `g_call_wndproc(&m)` at 494) leave `xlat`, `posted`,
`mouse` and `hit` uninitialised.  Today only the 18 message bytes are read, so there is no
undefined behaviour; a future reader of `m->mouse`/`m->hit` in the dispatch hook would read
indeterminate values.  `memset`/designated initialisation would remove the hazard.

### NOTEs

- **N1** `user_wnd.c:2657`: the class_brush comment is now detached from its function (2901);
  the P4-1 block was inserted between them.
- **N2** Records omit: WM_MOUSEACTIVATE is suppressed while the capture is set (2884; header
  79-83 and DESIGN 975-976 say only "outside the active top-level window"); the HTERROR check
  precedes WM_MOUSEACTIVATE (2880-2883); the MOUSEACTIVATE/SETCURSOR high word is the client
  number for non-client clicks too (2873-2876; DESIGN 976 says "message").
- **N3** FIDELITY F75 (line 110) lists "a disabled child passes the point to its parent" under
  **Choices**; the header (user_wnd.c:66-67) labels it "platform fact (inferred)".  One label.
- **N4** DESIGN 10 (line 1266): "SM_CXDOUBLECLK x SM_CYDOUBLECLK = 4 x 4 pixels around the first
  click", whereas the code accepts a 5 x 5 square (±2 inclusive).  DESIGN 970-971 and the header
  (74-78) state "2 pixels" consistently with the code; the 10 row should say the same.
- **N5** DESIGN 990-992 says test_user covers "every hit-test code"; HTMENU is not tested (the
  test windows have no menu; test_user.c:937-958).
- **N6** Test gaps: the eaten-message restart is not distinguished from continuing at the same
  index (test_queue.c:161-164 passes either way); `g_routes > 0` (166) is cumulative and does not
  show that call routed; no test of the queue-change fault, of raw-after-routed moves (D3), of
  MK_CONTROL, of the serialised RAW/ROUTED flags and MK_ byte (queue.c:550, 590-593), of
  MA_ACTIVATEANDEAT, of owned windows raised with their owner (or chains, D2), of children on
  raise (D1), of the WM_SETCURSOR parent chain, of a disabled top-level window with children
  (R1); the "new window" double-click case (test_user.c:1067-1071) uses a class without
  CS_DBLCLKS, so the per-window pair reset is not exercised.
- **N7** `harness.c:428` exceeds the file's line width.  `input.script:5-7` now sends its moves
  to a dead handle 2001, so the harness gate no longer exercises raw `hwnd 0` routing at all.
- **N8** raise_top paints frames with `nc_paint` directly and leaves the erase to BeginPaint,
  while the show/expose path sends WM_NCPAINT and erases synchronously (`sync_erase`, FIDELITY
  F36).  No game procedure handles WM_NCPAINT, so no effect today; unrecorded difference.
- **N9** `(int16_t)(m->y - w->cr.t)` (2806-2807) and `(int16_t)w16_send(...)` (2775) are
  implementation-defined conversions when out of range (C17 6.3.1.3p3), e.g. a captured move far
  from the capture window; two's-complement truncation on every target compiler, as elsewhere in
  the port.

---

## P4-2 non-client drawing

Files: `user_wnd.c` nc_rect … nc_paint_bar (822-1227), SetScrollRange/SetScrollPos (2543-2586),
WM_NCACTIVATE / WM_SETTEXT redraw (2944-2948, 2983-2993), test_nc_drawing (test_user.c:1089-),
FIDELITY F26 (line 100), DESIGN 5 "Non-client drawing" (993-1000).

Checked and found correct: all drawing is clipped to the window's visible region less the client
area (1155-1157), and text additionally to its part (nc_text 881-882); the thumb position
`(len - 16) * (pos - min) / (max - min)` in int64 (1036) with pos clamped by SetScrollPos /
SetScrollRange (2556-2561, 2575-2580); "none when the track is shorter than a thumb" (1034,
1045-1046); menu_display's "&&" handling and buffer bound (902); menu items clipped to the bar
(982-984) and limited to 48 like user_menu.c's MAX_ITEMS; the caption text between the system
box and the min/max boxes (1102-1128); the redraw paths.  The pixel expectations of
test_nc_drawing were recomputed by hand from the geometry and match.  F26 and the DESIGN text
agree with the code apart from the notes below.

### RISK P2-R1: parts of very small windows are drawn outside their part rectangles

bar_parts (1022-1032) lets the two arrow buttons overlap when the bar is shorter than 30 pixels,
and the separator lines at `a1.b`/`a2.t - 1` (1061-1062, 1065-1066) can fall outside the bar;
nc_triangle (851-866) draws a fixed-size triangle about the centre without clipping to the box;
the system-menu bar (1107-1110) assumes a box at least 8 pixels wide.  Everything stays inside
the window's own non-client region, so other windows are unaffected, but the frame would be
garbled.  Latent: the minimum tracking size limits only WS_THICKFRAME windows, and the game's
windows are far larger.

### NOTEs

- **P2-N1** A reversed range (SetScrollRange with nMin > nMax) gives `range <= 0` and the thumb
  at the track start (1036); SetScrollRange then leaves pos = nMin (2556-2561).  Not recorded in
  F26 or the header.
- **P2-N2** A caption wider than its space is left-aligned at the system box and clipped
  (1134-1137); F26 and the header say only "centred".
- **P2-N3** menu_display (907-909): an '&' directly before '\t' sets the mnemonic index to the
  end of the display text, so an underline is drawn just after the text (width of the NUL
  glyph).  Not reachable with the game's menu texts as far as checked.
- **P2-N4** menu_bar_rects (937-938) narrows the running x to int16; 48 items of 63 wide
  characters could wrap.  Theoretical.
- **P2-N5** Stale records: `user_menu.c:9-14` still says "until then user_wnd.c paints the menu
  bar's SM_CYMENU rows light grey"; `docs/FEATURES.md:65` still says "the menu bar is not drawn
  yet".  F26's thumb formula "track + (track - 16) * …" uses "track" for both the start and the
  length.
- **P2-N6** Test gaps: SetScrollRange with redraw, a hidden window (no drawing), clipping by an
  overlapping window, the WM_SETTEXT caption redraw, the down and right triangles, a reversed
  range.

---

## F13 record wording (round-12 R12A N1..N5)

Files: `docs/inventory/out-of-range.md` preamble (171-178), P8 (189), P9 (190); FIDELITY F74;
DESIGN 3.2 body-push sentence (305-312); `core/acc.h` acc_ix1 (95-98) and acc_fx1 (210-214)
comments; `docs/verify/round8-fixes.md` "Round-12 fixes (F13 …)" (108-118).

Verified against the listing (showfunc) and the translator:
- **F13-01 / P9**: TextBoxSetup 1068:2072 stores (2232, 224F) and TextBoxDraw reads (2612, 261F)
  as stated; the overlap arithmetic (lineLength +0x1A, lineOffset +0x9A, text +0x11A, block
  0x51A) gives exactly "line 64 + k overwrites lineOffset[k] and text bytes 2k, 2k+1"; the
  block-exit indexes 576 (lineOffset) and 640 (lineLength) are right; the bare-CR run ends after
  130 lines (line 128's store writes 0x0080 at text 128..129; the 0x00 byte ends the text).
- **F13-02**: the preamble now says P9 carries `/* OOB: findings C9 */`.
- **F13-03**: the acc_ix1/acc_fx1 comments match `translate.py` `w()` (width 0 for structures and
  arrays) and the `lval_index`/`lval_member` paths that call them.
- **F13-04**: TakeAdvanceFromCiv 1038:0BA9 (taker test 0A8F), MoveCivUnits 11F0:28AB (2882..2890)
  and CompleteResearch's AI path 22F9 test only `g_humanPlayer` (listings 1038:0A8F/0BA9,
  11F0:2882..28AB, 1170:2280..22F9); FIDELITY F74 and P8 say so.
- **F13-05**: the body-push sentence matches `emit_value_pushes`, which only `lval` (3681) and
  `rv` (3893) call.

### NOTEs

- **F13-N1** P9: "(lineLength +0x1A, lineOffset +0x9A, text +0x11A, 64 words each; block 0x51A)"
  reads as if `text` were 64 words; it is 0x400 bytes.
- **F13-N2** The hand section's heading and first sentence (out-of-range.md:171-173) still say
  "not in findings.md" / "that findings.md does not document", while P9's statements sit in
  findings C9's tables (which the new preamble sentence acknowledges): N2 is only partly resolved.
- **F13-N3** P8 (189) adds the F13-04 wording but its citation list does not name
  verify/round12-R12A.md N5 (F74 is cited instead).
- **F13-N4** DESIGN 3.2 (308-309): the enumeration of global-array nodes omits `g[i]` of
  `g[i][j][k]` and `table` of `table.b[i]`, which build their addresses the same way; line 311
  exceeds the file's line width.

---

## Effects on the game (claude/src/c, read-only)

- Client messages, MK_ wParam and client lParam suit WdwMapProc (`seg064_11F8.c` LBUTTONDOWN /
  UP / MOUSEMOVE with client coordinates), CivDialogProc (1098:189D/1859, coordinates recorded),
  the RanDoM control procedures (`seg011_1050_p2.c`) and the popups (`seg066_1208_p2.c`,
  `seg068_1218.c`).  RanDoMRadio's DBLCLK → WM_COMMAND path needs CS_DBLCLKS, which its class has.
- ProcessKeyboardMessage (1098:02D1, filter KEYFIRST..KEYLAST) does not route raw mouse input; it
  enqueues translated keys regardless of the focus window, so a click that moves the focus to the
  Small Map or Status window does not break the main keyboard path.
- The 0x200..0x209 flushes (`seg033_1100.c:773`, `seg063_11F0_p2.c:397`) remove client messages
  and leave routed non-client messages, which later unfiltered pumps dispatch to DefWindowProc
  (no default action yet): harmless.  Their removals run hook_mouse_taken, so a flushed click
  still activates (faithful mechanism, **inference**).
- MenuZ's unfiltered loop removes clicks on other windows, so they activate and raise those
  windows (faithful mechanism, **inference**); this is the path that exposes D1 and D2.
- The window-filtered loops (10F0:014B, 1170:1FDA) never remove other windows' mouse input: the
  path that exposes D3.
- SetCapture(dlg) with WaitForKeyOrClick (`seg030_10E8_p1.c`) routes everything to the dialog as
  client input without WM_NCHITTEST/WM_SETCURSOR/WM_MOUSEACTIVATE, as recorded.
- No checked-in scenario script contains mouse lines, so recorded scenario hashes are unaffected
  by P4-1 routing.

---

## Rule deviations by this reviewer

1. A Bash `cp` copied 11 project files (queue.c, queue.h, user_wnd.c, harness.c, input.script,
   test_queue.c, test_user.c, DESIGN.md, FIDELITY.md, out-of-range.md, round8-fixes.md) into the
   scratch folder `rv1` (as `RV1_*`) for diffing; a shell command touched project files (read
   only; nothing in the project changed).
2. A Bash `head -40` read `claude/tools/showfunc.py` (a shell read of a project file instead of
   the Read tool).

After noticing, project files were read only with Read/Grep/Glob and the shell was used only on
scratch copies and for showfunc.py.  No other file outside the scratch folder was written except
this report.

---

## Summary table

| Item | Verdict | DEFECT | RISK | NOTE |
|---|---|---|---|---|
| P4-1 | Needs fixes (D1 children not repainted on raise; D2 owner chains fall below the raised owner; D3 routed moves stop coalescing → queue full in window-filtered dialog loops) | 3 | 6 | 9 |
| P4-2 | Pass with notes | 0 | 1 | 6 |
| F13 | Pass with notes (all five changes accurate) | 0 | 0 | 4 |

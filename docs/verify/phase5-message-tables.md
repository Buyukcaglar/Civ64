# Phase 5 gate review: the message tables (P5-5)

Independent read-only review, 2026-10-10. Nothing was built, run or edited; the only write is this
file.

## Scope and files read

The translations host Win32 message -> `HostEvent` -> emulated Win16 message, and the clock/wait
rules of the bridge.

* `claude/port/platform/w16/host.h` (HostEvent, host interface)
* `claude/port/platform/win32/host_win32.c` (whole file; input, pump, window procedure, capture,
  cursor, DPI) and `host_win32.h`
* `claude/port/platform/w16/host_sync.c` (whole file)
* `claude/port/platform/w16/queue.h`, `queue.c` (posting, SYSKEY conversion, key state,
  PeekMessage, TranslateMessage)
* For consequences only: `user_dlg.c` (IsDialogMessage, `dlg_child_of`, `next_tab`),
  `user_menutrack.c` 1091-1126 (system-key entry), `clock.c` 189-197, `w16_int.h` 403-413,
  `win64/civ64_main.c`, `win64/civ64.manifest`, `tests/headless/harness.c` 749-880,
  `tests/harness/load-save.script`
* Requirements: `claude/docs/x64-port-prompt.md` 2.1 "Host isolation", 5.5 "Virtual screen
  geometry" (DPI), "Presentation", "Input"; `claude/port/docs/DESIGN.md` 5 "Win32 back end"
  (934-978, as updated 12:58), 6 items 5 and 7 (1204-1251); `docs/FIDELITY.md` F81, F82
* Tests: `claude/port/tests/win32/test_host_win32.c`

Not reviewed: the "input quirks of findings V and H" (prompt 5.5) and the window manager's routing
beyond the calls above.

## Verified correct

* **Message and code numbers** (Windows 3.1 values, shared by Win32): WM_KEYDOWN 0x100, KEYUP 0x101,
  CHAR 0x102, SYSKEYDOWN 0x104, SYSKEYUP 0x105, SYSCHAR 0x106, KEYLAST 0x108, TIMER 0x113,
  MOUSEMOVE/MOUSEFIRST 0x200, MOUSELAST 0x209, NCMOUSEMOVE 0xA0..0xA9 (queue.h:24-39);
  LBUTTONDOWN 0x201, LBUTTONUP 0x202, RBUTTONDOWN 0x204, RBUTTONUP 0x205, SYSCOMMAND 0x112,
  SC_CLOSE 0xF060 (host_sync.c:38-43); VK_NUMPAD0 0x60 + digit, VK_DECIMAL 0x6E, VK_NUMLOCK 0x90
  (host_sync.c:63, 92); MK_LBUTTON 1, MK_RBUTTON 2, MK_SHIFT 4, MK_CONTROL 8, MK_MBUTTON 0x10,
  VK_SHIFT 0x10, VK_CONTROL 0x11, VK_MENU 0x12, VK_F10 0x79 (queue.c:177-225); the keypad digit
  table 0x47..0x53 -> 7 8 9 - 4 5 6 + 1 2 3 0 . (host_sync.c:61).
* **Key lParam** (host_sync.c:69-82): repeat 1 (bits 0-15), scan bits 16-23 from host bits 16-23
  (host_win32.c:495-498), extended bit 24 from host bit 24, previous state bit 30 (set for every
  key up; for a down from the bridge's own `g_down`, so host auto-repeat gives bit 30 = 1), transition
  bit 31 for key up. Bit 29 is not set by the bridge; queue.c:211-225 converts KEYDOWN/KEYUP to
  SYSKEYDOWN/SYSKEYUP while the posted Alt is down (or for VK_MENU / VK_F10, not while Ctrl is
  down) and sets bit 29 then, as queue.h:88-89 and DESIGN 6.7 state. F10 alone gets SYS without
  bit 29. The bridge always posts the non-SYS numbers, so the queue is the only SYS authority:
  consistent.
* **Translation contract**: the host TranslateMessage character is peeked and removed at once
  (host_win32.c:516-528), so the host's DefWindowProc never sees WM_SYSCHAR (no host SC_KEYMENU)
  and the character is attached as `0x8000|byte` (host.h:65-68); host_sync.c:99-104 posts it with
  `w16_queue_post_key`, which keeps it after a SYS conversion (queue.c:272-275), and the emulated
  TranslateMessage posts WM_CHAR / WM_SYSCHAR with the key's lParam (queue.c:604-626). A key
  producing several characters (dead key + non-combining key, ligature layouts): the first is
  attached, the rest stay posted in the host queue, are retrieved by `pump` before the next input
  (posted before input) and arrive as HOST_EV_CHAR after the key down: no loss, no duplicate, order
  kept when the game translates the key. Dead keys: WM_DEADCHAR/WM_SYSDEADCHAR drained
  (host_win32.c:526-528), the dead key's down posted without a character (F81).
* **Windows-1252**: `hw_char_1252` uses WC_NO_BEST_FIT_CHARS plus the used-default flag and rejects
  0 and non-BMP (host_win32.c:476-488); characters without a byte are dropped and counted in both
  paths (host_win32.c:519-524, 950-960).
* **Mouse**: `coord` takes the signed low/high word, divides by k and clamps to 0..639 / 0..479
  (host_win32.c:500-504, 561-562); the bridge posts raw input with hwnd 0 (host_sync.c:115-129),
  whose wParam/lParam the queue replaces with the posted MK state and the screen position
  (queue.c:227-234), as queue.h:11-14 documents; client coordinates relative to the emulated capture
  window (possibly negative, signed 16-bit) are produced by the routing, from a screen position
  that, as on Windows 3.1, never leaves the screen. SetCapture on each button down, ReleaseCapture
  when no button remains (host_win32.c:565-570). The host class has no CS_DBLCLKS
  (host_win32.c:1024-1031), so the host never synthesizes double clicks; the emulation does.
* **Close and system keys**: WM_CLOSE -> HOST_EV_QUIT, window kept (host_win32.c:920-926); host WM_QUIT
  -> HOST_EV_QUIT (541-547); HOST_EV_QUIT -> WM_SYSCOMMAND SC_CLOSE posted to the active emulated
  window, nothing without one (host_sync.c:130-134; F82). Host key downs never reach the host
  DefWindowProc (pump intercept 536-539; window procedure returns 0 for keys and characters), so
  host Alt+F4, Alt, F10 and Alt+Space go to the game only; emulated Alt+F4 posts SC_CLOSE
  (user_menutrack.c:1104-1105), the same command as the close box. SC_KEYMENU is swallowed as a
  backstop (963-967); other SC_ codes (the host system menu's Close) reach DefWindowProc.
* **Isolation**: no keybd_event/SendInput/SetKeyboardState/GetKeyState/clipboard/registry/profile
  call in `platform/win32` or `win64` (search); NumLock forcing stays emulated. Host input reaches
  the core only at w16_host_sync, called from PeekMessage (queue.c:437, 546), GetKeyboardState
  (594), GetCursorPos (635) and GetTickCount (clock.c:192); `pump` only fills the ring, also when
  called from host_present and host_sleep_until_us. Presentation posts nothing.
* **DPI**: the manifest declares PerMonitorV2 (civ64.manifest:6-7); mouse divided by k; DWM does not
  scale (but see P5MT-7).

## Findings

| ID | Severity | File:line | Statement | Suggested fix |
|---|---|---|---|---|
| P5MT-1 | defect | host_sync.c:86, 100-113; queue.c:23-29, 108-116, 497-500; user_dlg.c:780-820, 183-192, 209-227 | Key, key-up and character messages are posted with `hwnd = w16_wnd_active()` taken at sync time, not with hwnd 0. queue.c keeps a non-zero hwnd, so keyboard input goes to the active **top-level** window, never to the focus window, and the target is fixed when posted, not when read. This contradicts queue.c's own rule (keyboard input goes to the focus window when read; platform fact (inferred) for Windows 3.1) and the harness's tested path (`load-save.script` 27-29: "Enter to the focus window, its OK button", `hwnd 0`), and it bypasses the no-focus SYSKEY conversion at queue.c:497 (an active minimized window). Consequences (traced in code): in a dialog passed to IsDialogMessage, WM_GETDLGCODE goes to the dialog, `focus_ctl` is 0, so Tab always selects the first tab stop (no cycling) and Enter uses DM_GETDEFID / IDOK instead of the focused button; characters and arrows for a focused EDIT or LISTBOX child reach the dialog window instead; type-ahead posted before a dialog activates stays with the old window. Neither host_sync.c's header, DESIGN 6.7 nor F81/F82 records this target choice. | Post HOST_EV_KEYDOWN/KEYUP/CHAR with hwnd 0 (queue.c already routes to focus, else active, at read time, with the minimized-window SYS rule); keep `w16_wnd_active()` only for HOST_EV_QUIT. Before changing, check the MenuZ dialogs: `load-save.script` 34-41 posts their characters straight to the dialog (`hwnd 2040`), a shortcut a real keyboard under focus routing may not reproduce. If the active-window target is deliberate, record it (DESIGN 6.7, FIDELITY) with the dialogs it affects, and test it. |
| P5MT-2 | defect | host_win32.c:906-987 (no WM_KILLFOCUS / WM_ACTIVATE(APP) / WM_CAPTURECHANGED / WM_CANCELMODE case); host_sync.c:105, 109; queue.c:211-226, 357-405 | Keys or buttons released while the host window lacks focus or capture are never released in the emulation. Alt+Tab is the common case: the host window gets WM_SYSKEYDOWN VK_MENU, the Alt release goes to the task switcher. The queue's `g_alt` stays 1, so every later key is queued as WM_SYSKEYDOWN with bit 29 and every typed character is translated to WM_SYSCHAR, which DefWindowProc turns into SC_KEYMENU (user_menutrack.c:1116-1120). F4 alone becomes Alt+F4 and posts SC_CLOSE (1104-1105). The next Alt press carries a stale previous-state bit 30 and does not arm the menu (1100). The same happens with Shift/Ctrl (MK_SHIFT/MK_CONTROL and the key-state array stuck, a stuck Ctrl disables SYS conversion) and with a mouse button when capture is lost. Windows 3.1's global key state could not stick this way (inference). | Track keys and buttons the back end has reported down. On WM_KILLFOCUS / WM_ACTIVATEAPP(FALSE) push HOST_EV_KEYUP for each held key, and on WM_CAPTURECHANGED / WM_CANCELMODE push the button-up at the last position, so the queue's Alt/MK/key state and `g_down` resynchronize. A read-only GetKeyState comparison on WM_SETFOCUS is an alternative. Add a test: Alt down, WM_KILLFOCUS, then 'A' must arrive as WM_KEYDOWN without bit 29. |
| P5MT-3 | risk | host_sync.c:89-96 | The keypad rule forces VK_NUMPADn plus a digit character regardless of modifiers. (a) Alt+keypad (Alt codes): the host gives no character for the digits, but the forced digit is attached, the queue makes it WM_SYSKEYDOWN, and TranslateMessage posts WM_SYSCHAR digits, which reach SC_KEYMENU (mnemonic search or beep). The host's composed WM_CHAR then arrives as well. (b) Ctrl+keypad gains a digit WM_CHAR. (c) Shift+keypad: Windows 3.1 with NumLock on gave the navigation key (VK_END ...) without a character (inference, general knowledge); here it gives the digit. The prompt's "as Windows 3.1 did with NumLock on" covers these cases. | Force the digit only when neither Alt nor Ctrl is down in the posted state (`w16_queue_key(0x12/0x11) & 0x80` or `w16_queue_buttons()`). Decide Shift (inversion to the navigation VKs without a character, or record the deviation) in DESIGN 6.7/FIDELITY. |
| P5MT-4 | risk | host_sync.c:59-67, 90-92, 105-109 | The key-up is remapped with the NumLock toggle as it is at the up, not as it was at the down. If the toggle changes in between (the user's NumLock retrieved, or SetKeyboardState), the down is VK_NUMPADn and the up is VK_END (etc.), or the reverse. Then `g_down[VK_NUMPADn]` and the emulated key-state 0x80 bit stay set: GetKeyboardState reports the key down, and the next press has bit 30 set. | Remember the posted VK per scan code at the down (a 256-entry table) and use it for the matching up. |
| P5MT-5 | note | host_sync.c:63, 93 | (a) The rule is one-sided. With the emulated toggle off (the user pressed NumLock, which toggles the emulated and host states together), the host translation passes through, so host NumLock on gives digits where Windows 3.1 with NumLock off gave navigation keys (inference). The prompt only specifies the set case. (b) The toggle is sampled when the key is moved into the queue, not when it is read. (c) VK_DECIMAL's character is always '.' (on Windows 3.1 it depended on the keyboard driver and country, e.g. ','). | Record (a)-(c) as choices in DESIGN 6.7/F81, or implement the symmetric off-rule. |
| P5MT-6 | note | queue.c:217-221 | Bit 29 is set on the Alt key's own WM_SYSKEYUP (`vk == VK_MENU`). Win32 reports VK_MENU's release with context 0 (lParam 0xC0380001: inference from general Win32 knowledge, not verified for Windows 3.1). It is harmless for the emulated menu entry (user_menutrack.c:1109-1115 ignores bit 29). | Record it as a choice, or clear bit 29 for VK_MENU key-up. |
| P5MT-7 | risk | host_win32.c:981-982; DESIGN.md:954-955 | WM_DPICHANGED returns 0 without resizing. DESIGN says this "keeps the client size", but it keeps the **window** rectangle. Under PerMonitorV2 the system rescales the non-client area (caption, borders) at the new DPI, so the client is no longer 640k x 480k (inference, platform behaviour): the bottom/right of the picture is clipped, or an unpainted margin appears. The mouse mapping stays correct (origin-anchored, clamped). | On WM_DPICHANGED, recompute the window rectangle for the new DPI with AdjustWindowRectExForDpi and the same k, then SetWindowPos (the suggested position, the recomputed size). |
| P5MT-8 | note | host_sync.c:111-113; host_win32.c:948-957, 495-498 | (a) HOST_EV_CHAR is posted with lParam = 1 \| scan<<16 only: no extended bit, context or previous state. On Windows a character message carries its key's lParam (inference). (b) A host WM_SYSCHAR that reaches the window procedure (one not attached to a key down) is posted as WM_CHAR, losing the SYS class. (c) The host repeat count (bits 0-15) is discarded: a host WM_KEYDOWN with count n > 1 becomes one emulated down (Win32 normally sends n = 1). | Add a flag to HostEvent for SYS characters and post WM_SYSCHAR for it, or record (a)-(c) in F81. |
| P5MT-9 | note | host_win32.c:455-463, 490-493; host_sync.c:100-133; DESIGN.md:991 | Dropped input is never counted or reported in civ64. (a) A full 1,024-entry host ring drops silently. (b) `w16_queue_post*` failures in the bridge (the 120-entry emulated queue full) are discarded with `(void)`, while DESIGN 5 says refused input is counted and logged (harness only). (c) `hw_dropped_chars` (prompt: "dropped; record this") is read only by the test. (d) A surrogate pair counts as two drops. | Count all three drop kinds and report them at exit (host_log or the run log). Count a surrogate pair once. |
| P5MT-10 | note | host_win32.c:927-937, 508-517 | The window-procedure path of `key_down` calls TranslateMessage itself. If a WM_KEYDOWN reaches `wndproc` through a loop that already translated it (a host modal loop doing TranslateMessage + DispatchMessage), the character is posted twice: once attached to the key and once as HOST_EV_CHAR. Not reachable today (`pump` intercepts key downs; host dialogs disable the window), but `hw_window_message` makes it the tested path. | Note it in a comment, or have the window-procedure path not translate (peek only). |
| P5MT-11 | note | host_sync.c:148-163; host_win32.c:433-435; DESIGN.md:1236-1243, 1204-1207 | Clock/wait rules match DESIGN 6.7, with two points to record. (a) Input moved into the queue during a WAIT sync does not shorten that sleep: the ring was just emptied, and the sleep is bounded by the emulated lead. (b) An emulated lead built up from poll costs during CPU-bound work (POLL syncs never sleep, host timing never pulls the clock back) is slept off whole at the next wait. CPU-bound work is not slowed, but its accumulated cost is paid at the following PeekMessage FALSE. DESIGN 6 item 5 still lists WaitMessage, which the program does not import (API-MAP has none). | Record (a)/(b) in DESIGN 6.7, or cap the sleep at a wait. Drop WaitMessage from 6 item 5. |
| P5MT-12 | note | host_win32.c:563; host_sync.c:115-129; queue.c:230-233; DESIGN.md:960-961 | `HostEvent.buttons` (host MK flags) is unused: raw posting replaces wParam with the queue's own MK state, derived from posted button and VK_SHIFT/VK_CONTROL messages. DESIGN 5 "Mouse ... with the button state" suggests otherwise. Agreement with the host depends on no key event being lost (P5MT-2). | Document that the field is informational, or drop it. |
| P5MT-13 | note | test_host_win32.c:180-217, 279-315 | Test gaps. (1) The bridge's lParam bits (scan, ext, prev, transition) are not checked; neither are WM_KEYUP / WM_CHAR / mouse numbers in the emulated queue; only count == 1 (281) and the keypad wParam (312-315) are. (2) The translation path is unverified: Enter accepts "no character" (188-190); the keypad digit's TranslateMessage character and VK_DECIMAL / '-' / '+' / extended arrows / NumLock off / key-up remap are untested. (3) There are no WM_SYSKEYDOWN, WM_SYSKEYUP, WM_SYSCHAR, dead-key or Alt -> SYSKEYDOWN bit-29 tests. (4) HOST_EV_QUIT -> SC_CLOSE posting is untested, including with no active window. (5) Capture (GetCapture after down, kept while the other button is down, released after both) is untested. (6) Raw mouse posting (hwnd 0, MK state, virtual position) through the bridge is untested. (7) Ring overflow, WM_DPICHANGED and the system menu's SC_CLOSE reaching DefWindowProc are untested. (8) Nothing covers P5MT-1 (target window) or P5MT-2 (focus loss). | Add bridge-level checks with PeekMessage on the emulated queue for each row of the tables, and a dialog with a focused child for P5MT-1. |

## Verdict

**Defects found.** The message and command numbers, the key lParam bit layout, the 1252 conversion,
the mouse scaling, clamping and capture, and the close/system-key handling are correct. Two defects:
P5MT-1 sends keyboard input to the active top-level window instead of the focus window, and P5MT-2
leaves Alt, Shift, Ctrl and buttons stuck after a focus or capture loss. Both should be fixed (or
P5MT-1 recorded as a deliberate choice with its consequences) before the tables are accepted. P5MT-3,
P5MT-4 and P5MT-7 are risks to fix or record. The rest are notes.

## Resolution (orchestrator, 2026-10-10 10:15–10:40 UTC)

Each finding was checked against the code and handled as below. "Test" names the check added to
`tests/win32/test_host_win32.c`.

| ID | Handling |
|---|---|
| P5MT-1 | **Fixed.** `host_sync.c` posts keys, key ups and characters with hwnd 0; the queue gives them to the focus window when read (else, as system keys, to the active window). Headless experiment (Checked harness, scratch scripts, run directories removed afterwards): S3 with every character sent as a key press without a window ran without a fault through setup and turns 1 to 3. At the title menu (dialog 139, MenuZ) a first Enter press is turned by IsDialogMessage into WM_COMMAND IDOK (probe at 1220:14F9: id 1, no control; the template's OK 101 is a BS_PUSHBUTTON and the focus is not on it), which MenuZSubclassWndProc ignores; MenuZ took the Enter only when another game pump (the WM_TIMER animation path, ProcessKeyboardMessage 1098:0339) translated the key into the game key queue first (WM_CHAR 0x0D through 1220:0AA9, probe hit 4 at 28.0 s), or after a letter. Posting to the active window (the previous code) gave the same IDOK for both Enters, and could not reach a focused EDIT. The user then reported the original's behaviour (the first Enter starts a new game); cause and fix: MenuZ's title mode keeps WM_ACTIVATE from DefDlgProc, so activation now gives a dialog the control CreateDialog chose (`user_wnd.c`, `user_dlg.c`); after the fix the first Enter press is WM_COMMAND 101 (FIDELITY F85, closed). |
| P5MT-2 | **Fixed.** `host_win32.c`: WM_KILLFOCUS releases every key still down in key order, with a Tab press first when Alt is down (as Windows 3.1's Alt+Tab gave the program WM_SYSKEYDOWN VK_TAB; inferred), so releasing Alt does not open the menu bar; WM_CAPTURECHANGED releases the buttons still down at the last mouse position. Test: focus lost with Alt and Shift down; capture lost with the left button down; no second release. |
| P5MT-3 | **Fixed (choice).** The keypad rule applies only while neither Shift, Ctrl nor Alt is down in the posted input; otherwise the host's key passes. Alt+keypad character codes are not composed (FIDELITY F81). Test: Shift+keypad 1 is VK_END. |
| P5MT-4 | **Fixed.** A key up takes the key that the same scan code's key down was posted as. Test: keypad 1 up after the emulated NumLock went off is VK_NUMPAD1 with lParam bits 30 and 31. |
| P5MT-5 | Recorded (DESIGN 6 item 7): the rule is one-sided by design (prompt 5.5 asks only for NumLock on); the state is read when the key is posted. |
| P5MT-6 | Note kept: the queue's bit 29 on VK_MENU's own key up is the phase-4 rule (`queue.c` header); no game code reads bit 29 of a key up. |
| P5MT-7 | **Fixed.** After creation and at WM_DPICHANGED the window is sized for the 640k x 480k client at the new DPI (AdjustWindowRectExForDpi), at the suggested position. Not tested headless (needs a second monitor); agent-observed check pending. |
| P5MT-8 | Note kept: HOST_EV_CHAR (a character without its own key down, after a dead key) has lParam 1 \| scan << 16 (choice). |
| P5MT-9 | **Fixed.** A full host ring and a full emulated queue each log once (`host_log`); `w16_host_dropped` counts the latter. Test: no input dropped. |
| P5MT-10 | Note kept: only the test path reaches `key_down` from the window procedure. |
| P5MT-11 | **Fixed.** At a sync point that is not a wait, an emulated clock ahead of the host moves the host origin, so poll costs of CPU-bound work are never slept off at a later wait; each wait sleeps about what it charged. DESIGN 6 item 5 no longer lists WaitMessage. Test: time charged before a poll is not slept at the next wait; a wait still sleeps. |
| P5MT-12 | Note kept: the queue derives the button state from the posted messages. |
| P5MT-13 | Partly closed by the tests above (lParam bits, key-up mapping, Shift, focus and capture loss, drops). Still untested: SC_CLOSE posting with an active window, WM_DPICHANGED, ring overflow. |

**Verdict after the fixes: tables correct with notes** (orchestrator's judgement; the fixes have not
had a second independent review).

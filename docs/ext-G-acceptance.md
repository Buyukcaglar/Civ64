# Extension phase G — acceptance record

Phase G is a user addition, not one of the prompt's phases. It covers:
- the user's requirement 2 of 2026-10-10 about 21:00 UTC: the title, intro, Birth and setup screens stay 4:3, the game uses the host window's area, and `stretch` is removed;
- the user's additions of the same evening (2026-10-10 21:25–22:40 UTC; 2026-10-11 local).

Design: DESIGN.md 12.2 and 12.4. FIDELITY F105..F112. Asan is deferred to the end of all queued work (user direction 21:20).

## Gate

| Item | Method | Result |
|---|---|---|
| Game screen at the game's start (F105) | `user_wnd.c` switch at the first top-level CIV window (WdwMapOpen); `present_game_screen`; layout following; `w16_screen_resize`; metrics; the integer fallback to fit | `test_user` `test_game_screen`, `test_present` `game_screen`, p4tests p49-prf-game; headless new and loaded games at 960x540 and 1280x720 and from the view; agent UI check in a 1920x1080 client |
| Following the window during the game (F110) | `w16_screen_follow` at PeekMessage calls without a range, outside system modal loops. The scale is the game start's, or a smaller one when 640x480 no longer fits. Windows follow by edge, inside and maximized rules. Regained strips are repainted | `test_user` `test_screen_follow`; `test_present` `game_screen_follow`. Agent UI check, Checked civ64, a loaded game in the default 1920x1440 window: 640x480; maximized (client 2560x1529) 853x509; restored 640x480; client 2400x1300 1200x650 at 2x. The map window stretched to the edges; World Map and Status stayed |
| `stretch` removed | the policy, menu item 0x1030, `--scale-mode stretch`, test groups; a remembered `stretch` reads as integer | `test_present`, `test_start` parse, `test_host_win32` menu check |
| Title (F106) | "Sid Meier's Civilization" on the host window and civ64's message boxes | agent capture |
| Black desktop (F107) | `w16_desktop_rgb` black in civ64 only | `test_user` `test_black_desktop`; agent capture of the title screen |
| About box (F108) | the system menu's last item; the user's lines, link and MIT licence | `test_host_win32` menu check; agent captures |
| Colour preference (F109) | DWM title bar, uxtheme ordinals for menus, About box colours and owner-drawn OK button, live change | `test_host_win32` (system mode, forced dark and light, WM_SETTINGCHANGE); agent captures in dark mode. The user's check: title bar and menu passed; the OK button was reported light and is now owner-drawn |
| Placement (F111) | `window` and `maximized` in civ64.cfg; saved at move or size end, maximize or restore, and the game's end; taken unless `--window` or `--scale` | `test_host_win32` `test_placement`. Agent check with the user's civ64.cfg backed up and restored byte for byte: 200,100..1700,1100 taken exactly; `maximized=1` starts maximized; a rectangle on no monitor is ignored (default 4:3 window) |
| No Close (F112) | Close removed from the system menu; CS_NOCLOSE greys the close button | `test_host_win32` (no Close, no doubled separator, CS_NOCLOSE); agent capture: the close button greyed |
| Full Checked suite and G-1 | `test.cmd checked`, `ext_g1.py check` | before F107: TESTS_OK and EXT_G1_OK 77 (2026-10-10 21:31–21:36 UTC); with F107..F111: TESTS_OK and EXT_G1_OK 77, every run directory rewritten (22:35–22:40 UTC); F112 (host only): `w32_test_host_win32` PASS 148 (22:45 UTC) |
| User check | — | **passed** (the user, 2026-10-11 about 07:50 UTC: "visual confirmation of phase G passed"): F105/F110 (the live game desktop), F107, F108, F111, F112 and the About box's OK button; title bar and menu colours had passed earlier (22:20) |

## Not verified

- Asan builds and tests (deferred by the user's direction).
- A real move between monitors of different DPI with a remembered placement.
- The light-mode About box: the agent cannot change the system's colour setting; the light path draws the system's themed push button.
- The system-menu popup's dark colours were seen only by the user; the agent could not open the menu from a background script.
- Live following was exercised by maximize, restore and SetWindowPos, not by a mouse drag of the frame. A drag ends in the same WM_SIZE and WM_EXITSIZEMOVE.
- Same-seed play across different window sizes is not expected to match (F105, F110).

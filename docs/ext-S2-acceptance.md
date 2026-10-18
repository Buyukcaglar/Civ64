# Extension phase S2 — acceptance record

Prompt: `claude/docs/x64-port-scaling-dos-prompt.md`, phase S2 (section 9): "Win32: resizable window, full
screen, DPI, cursor, chord audit (Windows profile), system menu, options." Gate: "7.2 passes; `RUNNING.md`;
agent UI check; user check pending." Session E1, 2026-10-10. Design: DESIGN.md 12.2; FIDELITY F99..F101.

## Gate

| Item | Method | Result |
|---|---|---|
| Options | `win64/civ64_start.c`: `--scale auto\|1..8`, `--window WxH`, `--fullscreen`, `--scale-mode`, `--filter`, `--aspect`, `--dump-presented`, `--dos-data`; bad values and `--window` with `--scale k` refused | `test_start` parse checks in `w32_test_host_win32` |
| Settings | `win64/civ64_cfg.c` (`%LOCALAPPDATA%\civ64\civ64.cfg`); command line, else remembered, else integer/nearest/square/windowed; the system menu and Alt+Enter save at once | `w32_test_locate` cfg round trip (unknown keys and comments kept, non-ASCII path, a later line wins, no per-user folder: nothing saved) |
| 7.2 Win32-headless | `tests/win32/test_host_win32.c` `test_window_s2` (hidden window): style and maximize box; minimum 640x480 client; full screen over the hidden window's monitor (WS_POPUP, not topmost) and back (style, placement); WM_DPICHANGED; cursor recreation (factors 2x2, 1x1 after a resize, 3x2 under stretch at 1600x900; hotspots and sizes from the icon); chords and the Alt rule through `hw_window_message` (Alt+Enter with repeat and releases: no event; Alt+F after a chord; Alt alone; focus loss with a held Alt); system-menu commands and marks; presses outside the image; `--dump-presented` (24-bit BMP, its size and first pixel) | Checked: PASS (137 checks; 2026-10-10 about 18:40 UTC); Checked, Asan and Release: PASS 137 checks each, TESTS_OK (20:01..20:32 UTC, with R and F103 in the tree) |
| Chord audit | DESIGN.md 12.2: the core reads no WM_SYSKEYDOWN/WM_SYSCHAR; GetKeyboardState only for Num Lock; ACCELERATOR 128 has no Alt entry | Alt+Enter is the one chord of S2 |
| `RUNNING.md` | where civ64 finds the game, the new options, the system menu, Alt+Enter, civ64.cfg, files written | updated |
| Agent UI check | `scratchpad/ui-s2.ps1`: Checked civ64.exe `--data build\gamedata --dos-data none --scale 1` on this machine (2560x1600 monitor); SetWindowPos, ShowWindow, WM_SYSCOMMAND of the system-menu ids; PrintWindow captures (scratch, not kept) | window 656x519 (client 640x480); resized client 1384x781: integer k=1 centred with black borders; fit nearest/sharp 1041x781 centred (sharp edges blended); stretch fills; maximized client 2560x1529; full screen 2560x1600 style 0x95000000 (WS_POPUP), integer k=3, 1920x1440 at (320,80), no caption; leaving full screen restored the maximized window (client 2560x1529), restore gave 1384x781 again. The intro credits kept running throughout. Agent observation, not user acceptance |
| User check | — | **passed** (the user, 2026-10-10 about 21:00 UTC: "Inspection of S2 and R passed"); the same message adds the game desktop (phase G) and the map zoom levels (phase M) |

The 8 ms target (D12) was measured offscreen in S1 (whole 640x480 frame into 3840x2160; Checked): integer
3.7 ms, fit-nearest 3.1, fit-sharp 8.1, stretch-nearest 2.7, stretch-sharp 8.9 (the sharp filter is near
the target in the Checked build; the Release build is faster).

## Superseded checks

* `w32_test_host_win32` `test_window`: a press at x=2000 of a 1280x960 client used to be delivered
  clamped; under F100 a press outside the image is not delivered, so the check presses on the image's
  last column (x=1279) and keeps the captured release outside, delivered clamped.
* `--scale` accepted 1..3; it now accepts 1..8 (extension 5.7); the parse check expects `--scale 9` refused.

## Not verified

The user's check passed (2026-10-10 about 21:00 UTC). Multi-monitor DPI changes were exercised only by a synthetic
WM_DPICHANGED; a real move between monitors of different DPI was not tried. The system menu was driven by
WM_SYSCOMMAND, not opened by mouse.

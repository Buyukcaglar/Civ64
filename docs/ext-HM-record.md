# Extension unit HM (the host window menu with submenus) - record

Unit HM of the "civ64" extension puts the host window's menu (the system menu, "window menu") into the user's layout:
Full screen, the submenus Display, Map zoom and Graphics, About… and Close (STATUS.md "User directions", rows
"2026-10-17 about 10:08" and "about 10:28"; the brief `docs/verify/BRIEF-hm.md`, which holds the user's text verbatim).
Session E4, 2026-10-17. Host only, plus one separable hunk the orchestrator added after the first staging (about
12:26 UTC): the DOS-profile refusal's hint names the item's new place and, after a Locate in the run, the restart
(Decision 10; `present/present.c`, `present/profile.h`, `tests/test_input.c`). Staged in `build/hm-stage/` (the
orchestrator's staging protocol, `build/e4-orchestrator/AGENT-RULES.md`). Bases (`BASE-SHA256.txt`): the four host
files taken 11:11:43 UTC (no landing since has changed them); the three files of the hint hunk first taken 12:29:44
UTC and, on the orchestrator's request, taken again 17:30:30 UTC from the tree after D6fS-a, D7d, D7j, D7l, D7m and
the e4d docs had landed (D7m RELEASE_OK 17:08:34 UTC; no landing step running): their changes there (D6fS-a's
`PRESENT_TICK_EVERY` in present.c and profile.h, D7d's, D7j's and later rows in test_input.c) are elsewhere, and
HM's three hunks were re-applied unchanged (the same lines; only profile.h's line numbers moved by one). At the
build slot (2026-10-17 18:22 UTC, after D6fS-b's landing: ALL_GREEN 18:16:46, RELEASE_OK 18:20:37 UTC) only
`tests/test_input.c` had moved (D6fS-b: 579 -> 611 checks); it was taken again 18:23:04 UTC and HM's hunk
re-applied unchanged (the same lines, 177 lines further down). The private overlay (`obj/mkoverlay.py`) was made
again at 18:23:10 UTC from that tree, with the seven staged files on top (`obj/sync.sh` keeps them in step). The
earlier bases are kept in `obj/base-1229/` and `obj/base-1730/`.

Labels:

* **compiled**: `obj/cc.cmd` (build.cmd's compiler, flags and include order; outputs only under `obj/o-src*`):
  `cc.cmd all VARIANT` (every portable source c17 `/W4 /WX /permissive- /fp:precise`, the headless tests named by
  TESTS, here `test_input test_present`, the harness except in Release, the Win32 files, civ64.exe and the five
  Win32-headless tests) and `cc.cmd strict VARIANT FILE...` (`/std:c11` and `/std:c17` with `/W4 /WX`, and the
  clang-tidy C99 parse with warnings as errors); `obj/w32t.cmd` recompiles host_win32.c and test_host_win32.c and
  relinks `w32_test_host_win32.exe`.
* **headless**: the overlay's `test_input.exe` and `test_present.exe` (test.cmd's arguments: argv[1] the tree's
  `build/gamedata`, read only; argv[2] under `obj/run3/`, before the rebase `obj/run2/`).
* **Win32-headless**: the overlay's `w32_test_*.exe` (hidden windows, quiet mode; the same arguments).
* **observed (probe)**: `obj/probe/probe.c`, a stand-alone Win32 program (not part of the product or the tests): a
  window with a system menu holding two submenus, the real menu loop on a private desktop of this window station, the
  messages logged (`obj/probe/probe-out.txt`). It is evidence about Windows' menu behaviour on this PC, not about the
  original game.
* **inferred**, **unknown**: as in the other records. No "DOS file", "DOS listing" or "DOS oracle" evidence applies:
  HM changes nothing the original game (Windows or DOS) draws, reads or decides; the window menu and the refusal
  message are the port's own (FIDELITY F108, F112, F117, F118, F160).

Scope: no DOS program was executed; nothing was written to `C:\Projects\Civ1RE\dos`, `C:\Projects\Civ1RE\original`,
`build/dosdata`, `build/gamedata`, `build/x64`, the user's `%LOCALAPPDATA%\civ64` or any other shared output;
build.cmd and test.cmd of the tree were not run; civ64 was not launched and no window was shown on the user's desktop
(hidden test windows, and the menu-loop windows of the probe and of the test's child on private desktops that are never
switched to); no git command that writes was run; no global hook was installed. Not edited: `core/`, `rt/`, `res/`,
`platform/w16/`, `present/` other than `present.c` and `profile.h`, `build.cmd`, `test.cmd`, the generated tables
and every document other than this record ("For the records").


## Status

**LANDED 2026-10-17** (copy-in 18:30:46 UTC, ALL_GREEN 19:22:16 UTC, RELEASE_OK 19:26:37 UTC; user build
`build/user-builds/hm/`; section "Landing"). The user's checks HM-1..HM-9 are pending on build "hm".

At staging: **READY_TO_BUILD**, rebased (2026-10-17 17:40 UTC; first reported 12:24 UTC, reworked on the
orchestrator's decisions at 12:50 UTC: the refusal hint, Decision 10; the menu-loop child's retry, "Tests"; Finding
5's wording; rebased onto the tree after D7l, D7m and the e4d docs at 17:30 UTC, and onto D6fS-b's landing at
18:23 UTC). The landing is in section "Landing". Staged and tested
privately (compiled, headless, Win32-headless; Checked, CheckedNoObs, Release; section "Results"); the static checks
test.cmd runs pass on the overlay. The new tests fail on the base product and pass with the change (section
"Tests"). Its build slot comes after D6fS-b's landing and user build (the orchestrator: copy-in about 19:00 UTC;
the user's "after current set of work completed"). The user's checks HM-1..HM-9 are pending a user build "hm".


## The user's words

STATUS.md "User directions", 2026-10-17 about 10:08 UTC (verbatim with the full layout in `docs/verify/BRIEF-hm.md`):

> "Interim task to be done after current set of work completed. Update host application context menu as outlined
> below;"

followed by the layout (top level, DISPLAY SUBMENU, MAP ZOOM SUBMENU, GRAPHICS SUBMENU) and:

> "Host application context menu shall display 'DOS files present' as disabled item instead of 'Locate DOS files...'
> if and when dos files are already present."

2026-10-17 about 10:28 UTC, on "Normal zoom" (after the orchestrator noted that the layout's "Ctrl+Shift+0" would leave
UX4b's Ctrl+Shift+Home working but unnamed), verbatim:

> "Ctrl+Shift+0, Home"

The orchestrator's decisions on the first staging (2026-10-17 about 12:26 UTC, not the user's words): include the
refusal hint in HM as a small separable hunk naming the new place, and saying, after a Locate in the run, that civ64
must be restarted; correct this record's wording about the zoom marks; make the menu-loop child's retry robust and
record it under "Test open items"; the other-languages note and the old comment names accepted as proposed.


## Findings

1. **A submenu's command reaches the window procedure as WM_SYSCOMMAND** (observed (probe), 2026-10-17 about 11:14
   UTC, `obj/probe/probe-out.txt`): in the real menu loop, Display > Fit arrived as `WM_SYSCOMMAND wParam=0x1020`,
   Map zoom > Zoom out as `0x10C0` and the top-level About as `0x1080`, each with lParam 0, and no WM_COMMAND
   ("RESULT sys=3 cmd=0"). So the existing handler (`civ_command((unsigned)(w & 0xFFF0u))`) serves the submenus with no
   new path; every id is a multiple of 16, so Windows' own use of the low four bits leaves it whole.
2. **WM_INITMENUPOPUP of a submenu carries the system-menu flag** (observed (probe)): `fSystemMenu=1` for the window
   menu (index 0) and for each submenu as it opens (index 8, 9). UX2's handler (`HIWORD(l) != 0` -> `hw_update_menu`)
   therefore runs at each submenu's opening too.
3. **WM_INITMENU names a menu handle other than GetSystemMenu's** (observed (probe): `menu=...0D62129F (GetSystemMenu
   ...62CE1705)`); the WM_INITMENUPOPUP of the top level names GetSystemMenu's own. This confirms UX2's inference
   (`ext-UX2-record.md`: Windows tracks the window menu through its own wrapper menu); UX2's handler is unchanged.
4. **By-command calls through GetSystemMenu's handle reach the submenus' items** (observed (probe):
   `CheckMenuRadioItem`, `GetMenuState`, `EnableMenuItem` and `SetMenuItemInfoW` with `MF_BYCOMMAND`/`FALSE` on the
   window menu changed or read the items inside its submenus). So `hw_update_menu` keeps its by-command calls.
5. **The zoom items' radio marks exist since M** (DESIGN.md 12.2: "radio items marking the level"; `hw_update_menu`'s
   `CheckMenuRadioItem` over 0x10C0..0x10E0; `test_window_d3b2` "the zoom items, Normal zoom marked"). HM adds no mark
   there: the three items keep their radio group and marks inside the Map zoom submenu. (The brief's "Today they are
   commands with no mark" is mistaken; the brief stays as recorded.)
6. **The DOS asset store holds the DOS files for the whole run**: `pdos_assets_open()` runs once at start-up
   (`win64/civ64_main.c`) and reads every file it needs then; a "Locate DOS files…" that succeeds records them for the
   next start only (`civ64_locate.h`: "The running game, its profiles and the DOS asset store are untouched", and its
   message "The DOS files are recorded. The DOS graphics become available the next time civ64 starts."). This decides
   the "DOS files present" rule (Decision 4) and the second form of the refusal's hint (Decision 10).
7. **The refusal is raised in one place**: `present_player_profile` (`present/present.c`), the shared path of the
   chord, the profile items and "Switch graphics". A refused switch's reason comes from `refusal(p)` (the DOS profile's
   `available()` sentence, from the store; under `CIV_OBSERVER 0` "The DOS graphics are not in this build."); the run's
   first refusal shows it with the hint in one `host_message`, later ones beep. `host_message` widens its text with
   code page 1252 (`platform/win32/host_win32.c`), so U+2026 is the byte 0x85 there. Before HM the hint read
   `To use them, choose "Locate DOS files..." in the window menu; the DOS graphics become available the next time
   civ64 starts.`, also after a Locate in the run.


## Decisions

1. **Layout, ids and texts** (`platform/win32/host_win32.c` `add_menu`). Every command keeps its id and its handler;
   new are the three submenus, the texts, one command and the Locate item's second text:

   | Menu | Item (text as shown; & = mnemonic) | Id | Kind |
   |---|---|---|---|
   | top | the system's Restore, Move, Size, Minimize, Maximize | SC_* | Windows' own |
   | top | separator; "&Full screen  Alt+Enter" | 0x1070 | check |
   | top | "&Display", "Map &zoom", "&Graphics" | (popups) | submenus |
   | top | separator; "&About…" (U+2026) | 0x1080 | command |
   | top | separator; "&Close  Alt+F4" | SC_CLOSE | command, the default item |
   | Display | "&Integer scaling (whole steps)", "&Fit to window" | 0x1010, 0x1020 | radio group |
   | Display | separator; "&Nearest-pixel filter", "&Sharp filter" | 0x1040, 0x1050 | radio group (grayed under integer, as before) |
   | Display | separator; "&Correct 320 × 200 to 4:3" (U+00D7) | 0x1060 | check |
   | Map zoom | "Zoom &out (half)  Ctrl+Shift+Minus", "&Normal zoom  Ctrl+Shift+0, Home", "Zoom &in (double)  Ctrl+Shift+Plus" | 0x10C0, 0x10D0, 0x10E0 | radio group, as since M ("Zoom in" grayed while +1 is refused, as before) |
   | Map zoom | separator; "&Mouse wheel zooms map" | 0x10F0 | check |
   | Graphics | "&Windows graphics", "&DOS graphics" (no accelerator text) | 0x1090, 0x10A0 | radio group |
   | Graphics | separator; "&Switch graphics  Ctrl+Shift+Backspace" | 0x1100 (new, `SC_CIV_SWITCH`) | command |
   | Graphics | separator; "&Locate DOS files…" (U+2026), or "DOS files present" disabled | 0x10B0 | command / note |

   The texts are written with `\u2026` and `\u00D7` escapes, so the source files stay ASCII. 0x1100 is the next free
   multiple of 16 (the audit of LP repeated in the source: the ids 0x1010..0x10F0 with 0x1030 retired, the system's
   from 0xF000 up, the emulation's WM_SYSCOMMANDs never reach this window procedure, w16 never calls GetSystemMenu).
2. **Mnemonics, unique within each menu**: top level f, d, z, g, a, c besides the system's own (on this PC's Windows:
   r, m, s, n, x; "Map &zoom" because Move has m); Display i, f, n, s, c; Map zoom o, n, i, m; Graphics w, d, s, l
   ("DOS files present" has none). UX3's t and a, LP's M and UX1's E leave with the old texts. The system items'
   mnemonics are Windows' and follow its display language (unknown for other languages; the test counts them on this
   PC's Windows; the orchestrator accepted this note).
3. **The marks** stay with `hw_update_menu` (unchanged logic; by command through GetSystemMenu's handle, Finding 4):
   it runs at WM_INITMENU, at every WM_INITMENUPOPUP with the system-menu flag (the window menu and, Finding 2, each
   submenu), after each of the menu's commands, the chords (profile and zoom), the wheel, Alt+Enter, and from
   civ64_main.c after the start's profile (UX2/K7: `hw_start_profile`), the remembered or `--zoom` level, the
   remembered wheel and aspect settings. Radio marks (`MFT_RADIOCHECK`) for the three radio groups and the profile
   group; check marks for Correct 320 × 200 to 4:3, Mouse wheel zooms map and Full screen.
4. **"DOS files present"** (the user's rule; the brief's open question "what happens if the DOS files later go
   missing"): the Graphics submenu's last item reads "DOS files present", disabled, while civ64's new hook
   `hw_set_dos_present_hook(fn)` answers 1, else "&Locate DOS files…", enabled. civ64 answers 1 when the run's DOS
   graphics are available (`pdos_assets_status() == PDOS_OK`: the files were found at start-up) or a "Locate DOS
   files…" succeeded in this run (`civ64_locate_dos_choose` returned 1; the files are recorded for the next start).
   The answer is asked at every update of the menu (Decision 3), so the item follows the state at each opening of the
   window menu and of the Graphics submenu, and at once after a successful Locate. Files removed from the disk while
   civ64 runs do not change it: the run's DOS graphics stay available (Finding 6), and the next start without them
   asks for them as before. Reason: "present" names what the player can use now; a disk check at each opening would
   show "Locate DOS files…" while DOS graphics still work, and a Locate then would only matter for the next start,
   where the start-up question asks anyway. The item keeps its id; its command, which Windows never sends for a
   disabled item, does nothing while the files are present (`civ_command` returns before the hook).
   `dos_item()` changes the item (`SetMenuItemInfoW`, `MIIM_STRING | MIIM_STATE`) only when its grayed state differs
   from the answer. A build without the observer (`CIV_OBSERVER 0`, no DOS profile) keeps "Locate DOS files…" grayed
   whatever the hook says, as before HM; its command still calls the Locate hook, as before.
5. **"Switch graphics"** (`SC_CIV_SWITCH`): `player_profile(PRESENT_PROFILE_TOGGLE)`, the very call of the chord
   Ctrl+Shift+Backspace: the same request, withdrawal, profile hook (civ64 saves `graphics`), marks, and the same
   refusal (Decision 10). Nothing reaches the game. The accelerator text "Ctrl+Shift+Backspace" moves from the two
   profile items to this item.
6. **Close**: SC_CLOSE's text is "&Close\tAlt+F4" (`g_exit_item`, `hw_exit_text(4)`), replacing UX1's "&Exit Sid
   Meier's Civilization 64bit\tAlt+F4". The command, the default item, the caption's close button (enabled through
   the enabled SC_CLOSE), Alt+F4 and UX1's exit (no warning before the game, the in-game warning "A game is in
   progress. If you exit now, any unsaved progress will be lost." with Exit Anyway / Cancel) are unchanged.
7. **Submenu ownership**: the three popups are created by `CreatePopupMenu` and appended with `MF_POPUP`
   (`append_submenu`; a popup that cannot be appended is destroyed). The window menu owns them from then on; Windows
   destroys them with it (`GetSystemMenu(h, TRUE)` is never called).
8. **Dark mode**: unchanged code. The app mode (`SetPreferredAppMode`, uxtheme ordinal 135, LP/F109) applies to
   every menu of the process, so the submenus follow the window menu (inferred; the user checks it, HM-8).
9. **P0 and the game**: no core, w16, resource or harness change; nothing of the emulation, the frames, the events or
   the checkpoints changes (the refusal hint is a host message outside the frame trace). The keyboard rules are
   unchanged: the window menu opens by the mouse (the icon at the left of the title bar, or a right click on the title
   bar); Alt, Alt+Space and F10 stay the game's (SC_KEYMENU refused, as before).
10. **The refusal's hint** (the orchestrator's decision; Finding 7). In `present_player_profile`, observer builds, the
    run's first refusal shows the store's sentence followed by one of two hints:
    * no Locate in this run: ` To use them, choose Graphics > "Locate DOS files…" in the window menu; the DOS
      graphics become available the next time civ64 starts.` (the ellipsis as the menu shows it, `\x85` in the
      source: Windows-1252, `host_message`'s code page);
    * after a Locate that recorded the DOS files in this run: ` The DOS files you located are used from the next
      start: restart civ64 to use the DOS graphics.` (no pointer to Locate, which then reads "DOS files present").
    The state is `present_set_dos_located(int)` (new, `present/profile.h`; a static flag in present.c), which
    civ64_main.c's `locate_dos` sets to 1 when `civ64_locate_dos_choose` returns 1. `present_reset` does not clear it
    (a fact of the process, not of a run's cadence); tests clear it with 0. The cadence (one message, then beeps), the
    reason sentence, the CIV_OBSERVER 0 message and the 640-byte buffer's bound are unchanged. The hunk is separable:
    the menu works without it, and it touches only the hint's lines, the setter and its declaration.


## Deviations

* "Normal zoom" shows "Ctrl+Shift+0, Home" (the user's correction of 10:28 UTC), not the layout's "Ctrl+Shift+0";
  it supersedes UX4b's "Ctrl+Shift+0, Ctrl+Shift+Home" (F114).
* UX1's menu text "Exit Sid Meier's Civilization 64bit" is replaced by "Close" (the user's layout); F112/F160's
  behaviour is unchanged.
* The menu texts the user wrote with "…" and "×" use those characters (U+2026, U+00D7); the user's own sentence
  about the present item writes 'Locate DOS files...' with three dots: the layout's "Locate DOS files…" is used, and
  the refusal's hint names it the same way.
* Comments elsewhere that name the old texts ("4:3 aspect ratio for 320 x 200 screens" in `present/dos/pdos_seq.h`,
  `win64/civ64_cfg.h`, `win64/civ64_main.c`, `test.cmd`, `tests/harness/ext_aspect.py`, `tests/test_pdos_aspect.c`;
  "Mouse wheel zooms the map" in `present/input.h`, `win64/civ64_cfg.h`, `win64/civ64_main.c`) are left as the
  history of their units (only comments; accepted by the orchestrator).


## What was built

* `platform/win32/host_win32.c`: the header paragraph "Extension HM"; `g_dos_present_hook` and
  `hw_set_dos_present_hook`; the block "extension HM (begin) .. (end)" after `SC_CIV_WHEEL`: `SC_CIV_SWITCH 0x1100`,
  `g_locate_item`, `dos_present()`, and under the observer `g_dos_present_item` and `dos_item()`; `hw_update_menu`
  calls `dos_item(m)` (observer builds); `g_exit_item` "&Close\tAlt+F4"; `append_submenu()`; `add_menu`'s items
  rebuilt into the layout (Decision 1); `civ_command`: `case SC_CIV_SWITCH`, and `SC_CIV_DOS_LOCATE` returns at once
  while the files are present and updates the menu after the Locate hook; comments at WM_INITMENUPOPUP,
  WM_SYSCOMMAND, the view flush (TLD) and the About box.
* `platform/win32/host_win32.h`: the declaration of `hw_set_dos_present_hook` with the layout; the comments of
  `hw_update_menu`, the About box, UX1's exit and `hw_exit_text(4)`.
* `win64/civ64_main.c`: the header comment; `g_dos_recorded` (set when `civ64_locate_dos_choose` returns 1, together
  with `present_set_dos_located(1)`), `dos_present()`, `hw_set_dos_present_hook(dos_present)` after
  `hw_set_locate_hook(locate_dos)`.
* `present/present.c` (the hint hunk): `g_dos_located` after `g_player_refusals`; in `present_player_profile` the
  comment, the two hints and the choice between them (`h`, `hn` in place of `hint`, `sizeof hint`);
  `present_set_dos_located()` after `present_player_refusals()`.
* `present/profile.h` (the hint hunk): two comment lines in `present_player_profile`'s contract; the declaration of
  `present_set_dos_located` with its comment after `present_player_refusals`.
* `tests/win32/test_host_win32.c`, `tests/test_input.c`: section "Tests".
* This record.

Not changed: `build.cmd`, `test.cmd` (no BUILD-TEST-ADDITIONS), civ64's settings (`civ64.cfg` keys and their meaning
unchanged), the About box, the exit warning, the refusal's reason sentence and cadence.


## Tests

`tests/win32/test_host_win32.c` (hidden window, `hw_window_message`, quiet mode):

* Existing checks moved to the layout: `test_window_s2`'s menu-position check (Close last, a separator, About…, a
  separator, the three submenus, Full screen, a separator; no Stretch item); the UX1 Close check (text
  "&Close\tAlt+F4"); `test_window_d3b2`'s texts (the profile items without accelerator text, "&Locate DOS files…",
  "&Normal zoom\tCtrl+Shift+0, Home", "&Mouse wheel zooms map"); `test_ux3`'s texts and mnemonics (0x1010 "&Integer
  scaling (whole steps)", 0x1060 "&Correct 320 × 200 to 4:3"; i and c unique in Display, w only Windows graphics' in
  Graphics; `mnemonic_count` now counts the items of the menu it is given); `test_exit`'s `hw_exit_text(4)`. Their
  counts are unchanged. New helper `hm_submenu_of()`; macros `HM_ABOUT`, `HM_LOCATE`, `HM_ASPECT` (written with
  `\x2026`, `\x00D7`).
* New block "extension HM", `test_hm(outdir)` after `test_ux3`, 43 checks in observer builds, 27 in CheckedNoObs:
  * the structure (4): the top level's 14 items in order (the five system items by id, then kinds, ids and texts),
    each submenu's items, kinds, ids and texts at its position;
  * Unicode (1): About… and Locate DOS files… end in U+2026 (no "..."), Correct 320 × 200 to 4:3 has U+00D7 (no "x");
  * mnemonics (1): no letter twice in any of the four menus, the system's items included; f d z g a c at the top;
  * Close (1): last, enabled, the default item;
  * the marks at opening (1): integer and nearest radio-marked with the filters grayed, 4:3 checked, Normal zoom
    radio-marked, the wheel checked, Windows graphics radio-marked, Full screen and Switch graphics unmarked;
  * Display (7): Fit, Sharp, 4:3 off (square) and on, Nearest and Integer again (filters grayed), Full screen on/off;
  * Map zoom, observer builds (12): the three items' levels and marks; Ctrl+Shift+Minus, +0, +Plus and +Home (gray)
    with their marks and no event to the game; the wheel over a test map window (`pmap_test_map`): Zoom in marked; the
    start's level (`pmap_request_zoom` as civ64_main.c's `--zoom`/key) marked at once; the wheel item off/on and the
    remembered `wheel_zoom=0` (`hw_set_wheel_zoom`) unchecked at once. CheckedNoObs (1): the items grayed and inert,
    as before;
  * Normal zoom marked at the end (1);
  * Graphics (7): a DOS start (`hw_start_profile`, K7) marks DOS graphics; Switch graphics requests Windows (the
    profile hook called, marked, nothing to the game); after the tick Switch graphics again requests DOS; the chord
    withdraws it; the two items; Switch graphics without the DOS profile gives the chord's refusal (a message or a
    beep), nothing recorded;
  * Locate / present, observer builds (7): not present: "Locate DOS files…" enabled; its command calls the Locate
    hook; present: at the Graphics submenu's WM_INITMENUPOPUP the item reads "DOS files present", disabled, no
    mnemonic, still 6 items; its command then does nothing; the files gone: Locate again at the next WM_INITMENU; a
    Locate that succeeds: "DOS files present" at once; no hook: Locate. CheckedNoObs (2): Locate stays grayed with
    the hook answering 1; its command calls the hook as before;
  * the real menu loop (1): the child `--hm-loop` (`child_hm_loop`) creates a private desktop of this window
    station (never switched to), shows a host window there and opens its window menu as Alt+Space would
    (`DefWindowProcW(h, WM_SYSCOMMAND, SC_KEYMENU, ' ')`, called directly: civ64's own window procedure refuses
    SC_KEYMENU) with the items' mnemonics posted as WM_CHAR before it: Display > Fit to window and > Integer scaling,
    Map zoom > Zoom out and > Normal zoom (observer builds), Graphics > Switch graphics, > Windows graphics and
    > Locate DOS files… (observer builds) each reach the window procedure (their effects are written as markers), and
    Close ends the run with exit code 0 (`hm_loop_ok`).
* **The menu-loop child's robustness** (the orchestrator's decision; "Test open items"):
  * each step sets a thread timer (`SetTimer(NULL, 0, 3000, hm_menu_timer)`; the menu loop dispatches the thread's
    timers): a menu still open after 3 s (its keys lost) is closed with `EndMenu()` and "[menu closed]" is written,
    so a step never hangs (observed: an experiment in the overlay only, a first step with no item, the child alone,
    `obj/run/exp/loop.txt`: "[menu closed]" after 3 s, the later steps went on, the run ended with code 0 in 4.3 s;
    the overlay was rebuilt from the stage afterwards);
  * a watchdog thread ends a child stuck outside a menu after 14 s with code 6 ("[watchdog]");
  * `child()` (shared by the test's children) now ends a child still running after its 30 s wait
    (`TerminateProcess`, code 97) instead of leaving it running, where it would hold the test program's file for the
    next link;
  * the parent: a first run that does not complete (any of: a code other than 0, a missing step marker, "[menu
    closed]", "[watchdog]", "[went on]") is run once more, with one line `NOTE: test_hm: the menu-loop child's first
    run did not complete (code N, <reason>; its output: ...\w32-hm-loop-1.txt); running it once more (a failure
    only if the second run does not complete either)`; the check fails only when the second run does not complete
    either, and its text then names both codes (the experiment above in a full run, `obj/run/exp.log`, where every
    run is incomplete, gave that NOTE line and one FAIL naming "first run's code 0").

`tests/test_input.c`, `cadence()` (the refusal cadence):

* the first refusal's text check now expects `choose Graphics > "Locate DOS files\x85" in the window menu; the DOS
  graphics become available the next time civ64 starts.` (the same check);
* new, observer builds (1 check): `present_set_dos_located(1)`, a new run's cadence (`setup()`), the DOS item
  refused: one message containing `The DOS files you located are used from the next start: restart civ64 to use
  the DOS graphics.` and no "Locate DOS files"; then `present_set_dos_located(0)`.

**Fails on the base, passes with the change** (the AGENT-RULES requirement):

* the new `test_host_win32.c` compiled against the base host_win32.c (`obj/src-hmbase`: the base product with a no-op
  `hw_set_dos_present_hook` shim so it links) gives 15 failures in each variant (`obj/run/w32host-hmbase-*.log`):
  lines 497, 549, 1019, 1023, 1028 (CheckedNoObs 1031), 1051, 1079, 2807, 2810, 2817, 2931, 3210, 3213, 3216, 3219
  (the menu's order, Close's text, the profile items' and Locate's texts, the zoom and wheel texts, the UX3 texts and
  mnemonics, the exit text, the four structure checks; `test_hm` stops after the structure there); a 16th, line 2510
  "civ64.exe has version information (0 bytes)", is an artefact of that experiment's folder (no civ64.exe beside the
  test). (Line numbers of that run, before the retry rework.)
* the new `test_input.c` linked with the base present.c (`obj/tibase/ti.cmd`, a no-op `present_set_dos_located`
  shim; Checked) gives 2 failures (`obj/tibase/run3.log`, on D6fS-b's tree): line 3128 (the hint names no Graphics
  submenu) and line 3152 (after a Locate the hint still points at Locate) (2951 and 2975 on D7m's tree,
  `run2.log`; 2728 and 2752 on DBL's, `run.log`).
* With the change: 0 failures (section "Results").

Known flake (unchanged, RUNNING.md "Tests"): the `GetKeyState` checks of the real-key tests can fail under load; in
the staged file they are at lines 1219 ("Ctrl+Backspace ...") and 1253 ("later refusals ...") (1207 and 1241 in the
base). One Release run failed once at line 224 ("Enter down, its translation: 0x800A", a real-key check of the
same kind) and passed on the rerun.


## Results

Private, 2026-10-17 (Istanbul time is UTC+3); the overlay of 18:23:10 UTC (the tree after D6fS-b's landing) with
the seven staged files.

| variant | compiled (`cc.cmd all`, TESTS `test_input test_present`) | headless | `w32_test_host_win32` (base -> HM) | other Win32-headless |
|---|---|---|---|---|
| Checked | CC_ALL_OK 18:23:13..18:24:09 UTC | `test_input` 611 -> 612, `test_present` 956 | 410 -> 453, 0 failures, no NOTE | `test_dos_host` 56, `test_locate` 36, `test_single` 50, `test_slots_host` 19: PASS |
| CheckedNoObs | CC_ALL_OK 18:24:09..18:25:16 | `test_input` 555 (unchanged), `test_present` 956 | 381 -> 408, 0 failures, no NOTE | the same four: PASS |
| Release | CC_ALL_OK 18:25:16..18:26:05 | `test_input` 611 -> 612, `test_present` 956 | 410 -> 453, 0 failures, no NOTE | the same four: PASS |

Logs: `obj/run4/` (earlier: `obj/run3/` over D7m's tree, `test_input` 579 -> 580 and 523; `obj/run2/` over DBL's,
522 -> 523 and 466). The base counts are D6fS-b's landing run (`build/d6fsb-2-test-checked.log`: `test_input` 611,
`test_present` 956, `test_host_win32` 410), D6fS-b's prediction for CheckedNoObs (`test_input` 555) and RUNNING.md
(381 in `checked noobs`); on D7m's tree the base `test_input.c` built in CheckedNoObs against the overlay gave 523
(`obj/tibase/tin.cmd`). `cc.cmd strict` (c11, c17 /W4 /WX, the
C99 parse) is clean for host_win32.c, civ64_main.c and present.c in the three variants and for test_host_win32.c in
Checked and Release (after the rebase, 17:35 UTC). The C99 parse of the two test files reports only the base's own
findings (no gate: build.cmd does not parse tests that way): `test_input.c` line 182 (176 before D7d's header
lines) "missing field 'square_only' initializer" (the same in the base file), and under CheckedNoObs
`test_host_win32.c`'s unused `wheel_lp`, `ux4_level1`, `ux4_post_pad0`; c11 and c17 compile both cleanly. HM's
observer-only helpers (`hm_chord`, `hm_loop_locate`) are guarded.

The refusal text as shown (the Checked host test's quiet-mode log, the store's sentence first): `Civilization for DOS
was not found (CivDos.zip, Civ-Dos.zip, Civ_Dos.zip or a CivDos folder next to civ64.exe, or --dos-data). To use
them, choose Graphics > "Locate DOS files…" in the window menu; the DOS graphics become available the next time civ64
starts.`

The menu-loop child after the rework: 8 runs one after another and 6 runs at once, each code 0 with every marker, no
"[menu closed]", no watchdog (`obj/run2/loops/`). Before the rework it hung once (only "[desktop]", watchdog code 6)
in the first full run, made while D7c's Release build ran; it did not recur in 6 later full runs and 20 runs of the
child alone; cause unknown ("Test open items").

Static checks test.cmd runs, on the overlay (`obj/chk_priv.py`, the tree's scripts; logs `obj/chk-*.log`, 17:38 UTC,
on D7m's tree; the landing's test.cmd runs them on the final tree): `gen/dos/registry.py check` REGISTRY_OK;
`tests/harness/obs_lint.py` OBS_LINT_OK files 138 probes 203 callsites 101; adapters check ADAPT_OK rows 138 steps
25; `pdos_scene_check` PASS 1084 checks (141 scene rows, 10 font rows); `gen/dos/nodos.py check` over the staged
files and the private Checked binaries: NODOS_OK, 0 hits (19 files). `gen/obs_tables.py --check` is not needed
(no DOS-PROFILE.md edit). Not run privately: the harness sections, G-1, P0 and the other headless `test_*` programs
(the build slot's cycle runs them; present.c's change is the refusal path only).


## Expected changes at the build slot

* `w32_test_host_win32`: Checked 410 -> 453, Release 410 -> 453, CheckedNoObs 381 -> 408. New output files under the
  test folder: `w32-hm-loop.txt` (and `w32-hm-loop-1.txt` only after a retry, with a NOTE line in the log).
* `test_input`: Checked 611 -> 612, Release 611 -> 612, CheckedNoObs 555 (unchanged).
* `test_present` 956 (unchanged).
* (From the current bases; a unit landing before HM that changes one of these files moves both counts by its own
  delta.)
* Nothing else: no golden, no G-1 run (`EXT_G1_OK` as at the preceding landing), P0 unchanged (no core, w16 or
  harness change; the refusal message is a host message, never in the frame trace or the checkpoints), coverage
  unchanged (core only), no build.cmd or test.cmd change. NODOS: the seven files hold no DOS bytes.


## Rebase notes

`present/present.c`, `present/profile.h` and `tests/test_input.c` are shared with other units (D6fS-a, D7d, D7j,
D7l and D7m changed them since HM's first bases); HM's hunks were rebased onto the tree of 17:30 UTC (head of this
record), and `tests/test_input.c` again onto D6fS-b's landed copy at the slot (18:23 UTC). The four host
files were touched by no unit since HM's bases (equal to the tree at 18:22 UTC). Line endings: all seven files LF but
`tests/test_input.c` (CRLF); all ASCII. Re-apply:

* `platform/win32/host_win32.c`: the header paragraph "Extension HM" after UX4b's; the static `g_dos_present_hook`
  after `g_locate_hook`; the block "extension HM (begin) .. (end)" after `#define SC_CIV_WHEEL`; `dos_item(m)` at the
  end of `hw_update_menu`; `g_exit_item`, `append_submenu` and `add_menu`'s items from the "extension HM (begin)"
  comment to "(end)"; `hw_set_dos_present_hook` after `hw_set_locate_hook`; in `civ_command` the `SC_CIV_SWITCH` case
  and the two lines of the `SC_CIV_DOS_LOCATE` case; the comments at WM_INITMENUPOPUP and WM_SYSCOMMAND. A unit that
  adds a window-menu item puts it into this structure (brief: A43 and CRT in Display, AMS at the top level below
  Graphics) and moves `test_hm`'s tables with it.
* `platform/win32/host_win32.h`: the `hw_set_dos_present_hook` declaration after `hw_set_locate_hook`'s comment
  block; four comment edits.
* `win64/civ64_main.c`: the header sentence; `g_dos_recorded`, `locate_dos`'s result with
  `present_set_dos_located(1)`, `dos_present()`; the hook's registration after `hw_set_locate_hook(locate_dos);`.
* `present/present.c`: the line `static int g_dos_located;` after `g_player_refusals`; in `present_player_profile`'s
  `#if CIV_OBSERVER` refusal block the comment's added sentence, `hint[]`'s new text, `located[]`, `h`/`hn` and their
  three uses; `present_set_dos_located()` after `present_player_refusals()`. A unit that rewords the refusal keeps the
  two forms (or changes test_input's two checks with them).
* `present/profile.h`: the two comment lines before "present_reset starts a new run's cadence." and the declaration
  block after `present_player_refusals`.
* `tests/test_input.c` (CRLF): the expected hint text of the first refusal check in `cadence()`; the `#if
  CIV_OBSERVER` block after "its first refusal: a message again".
* `tests/win32/test_host_win32.c`: the three macros after `CHECK`; `hm_submenu_of` after `marked()`; `child()`'s
  timeout end (code 97); the edits in `test_window_s2`, `test_window_d3b2`, `mnemonic_count`, `test_ux3`,
  `test_exit`; the block "extension HM" (with `hm_loop_ok`, `hm_menu_timer`) before "/* extension D4b4"; in `main`
  the `--hm-loop` child dispatch after the `--close-` children and `test_hm(argv[2]);` after `test_ux3`.


## Build-slot steps

1. From the port root: check the 7 bases of `build/hm-stage/BASE-SHA256.txt` and that this record is absent from
   `docs/`. A base that changed (expected for the three hint-hunk files): re-apply HM's hunks onto the tree's copy
   ("Rebase notes"), keeping its line endings, then refresh the overlay (`obj/mkoverlay.py`, `obj/sync.sh`),
   recompile privately (`obj/cc.cmd all VARIANT` with `TESTS=test_input test_present`) and rerun `test_input` and the
   Win32-headless tests.
2. Copy the 7 staged files into the tree at the same paths (`STAGED-SHA256.txt`); copy this record to
   `docs/ext-HM-record.md`. No build.cmd or test.cmd change.
3. The three-step cycle: `build.cmd checked`, `test.cmd checked`, `C:/Python314/python -B tests/harness/ext_g1.py
   check`; then `build.cmd` (Release). A NOTE line of `test_hm` in the test log is a retried flake, not a failure.
4. A user build "hm" (`build/user-builds/hm/`: the Release civ64.exe; CIVWIN.zip and civdos.zip as before) with
   `WHAT-TO-CHECK.txt` from "What the user checks"; the docs pass applies "For the records".


## What the user checks

Open the window menu by clicking the small icon at the left of civ64's title bar, or by right-clicking the title bar.

* **HM-1** (the top level): the menu shows, from the top: Restore, Move, Size, Minimize, Maximize; a line; "Full
  screen" with "Alt+Enter" at the right; "Display", "Map zoom" and "Graphics", each with an arrow at the right (moving
  the pointer onto one opens its submenu); a line; "About…"; a line; "Close" with "Alt+F4" at the right, in bold.
  Choose "Full screen": civ64 fills the screen; open the menu again: "Full screen" has a check mark; choose it again
  (or press Alt+Enter): back to the window, no check mark.
* **HM-2** (Display): the submenu shows "Integer scaling (whole steps)" and "Fit to window"; a line; "Nearest-pixel
  filter" and "Sharp filter"; a line; "Correct 320 × 200 to 4:3" (with a real × sign). The chosen scaling and the
  chosen filter each have a dot; the 4:3 item has a check mark when it is on. Choose "Fit to window": the picture
  fills the window and the dot moves to it; the two filter items become available (under "Integer scaling" they are
  gray). Choose "Sharp filter": the dot moves there. Switch to the DOS graphics and choose "Correct 320 × 200 to 4:3":
  the DOS screens (not Birth) change between the 4:3 shape and square pixels, and the check mark follows. Close civ64
  and start it again: your choices are kept and marked.
* **HM-3** (Map zoom, during play with the map visible): "Zoom out (half)" with "Ctrl+Shift+Minus", "Normal zoom" with
  "Ctrl+Shift+0, Home", "Zoom in (double)" with "Ctrl+Shift+Plus"; a line; "Mouse wheel zooms map" with a check mark.
  The current zoom has a dot (as before in the old menu). Choose each zoom item: the map zooms and the dot follows.
  Then use the keys instead (Ctrl+Shift+Minus, Ctrl+Shift+Plus, Ctrl+Shift+Home, the mouse wheel over the map) and open
  the submenu after each: the dot always shows the zoom you see. Choose "Mouse wheel zooms map": the check mark goes
  away and the wheel no longer zooms; choose it again to turn it back on.
* **HM-4** (Graphics): "Windows graphics" and "DOS graphics" (no key text next to them), the one in use with a dot;
  a line; "Switch graphics" with "Ctrl+Shift+Backspace"; a line; then the DOS-files item (HM-6). Choose "Switch
  graphics": civ64 changes to the other graphics, as Ctrl+Shift+Backspace does, and the dot moves. Choose "Windows
  graphics" or "DOS graphics": civ64 changes to that one. Press Ctrl+Shift+Backspace, then open the submenu: the dot
  shows the graphics you see.
* **HM-5** (the dot at start-up): close civ64 while in the DOS graphics and start it again: civ64 starts in the DOS
  graphics and the Graphics submenu's dot is on "DOS graphics" at the first opening (and on "Windows graphics" after a
  start in the Windows graphics).
* **HM-6** (DOS files present, and the message without them): with the DOS files found (civ64 can show the DOS
  graphics), the Graphics submenu's last item reads "DOS files present" in gray and cannot be chosen. To see the other
  state, civ64 has to run without the DOS files: for example start civ64.exe from a copy of the "hm" folder without
  civdos.zip; if civ64 says "Civilization for DOS was not found ... Locate it now?", answer No, and Yes to "Ask again
  the next time civ64 starts?" (if civ64 still finds the DOS files through a location it remembers from earlier, this
  half can be skipped). Then:
  * open the Graphics submenu: the last item reads "Locate DOS files…" and can be chosen;
  * choose "Switch graphics" (or "DOS graphics"): a message says why the DOS graphics are not available and ends
    'To use them, choose Graphics > "Locate DOS files…" in the window menu; the DOS graphics become available the
    next time civ64 starts.'; choosing it again only beeps;
  * choose "Locate DOS files…" and press Cancel: nothing changes. Choose it again and pick civdos.zip: civ64 says "The
    DOS files are recorded. The DOS graphics become available the next time civ64 starts."; open the Graphics submenu
    again: the item now reads "DOS files present" in gray;
  * to see the message after a Locate, use a fresh start of the copy without the DOS files and choose "Locate DOS
    files…" (pick civdos.zip) before trying the DOS graphics; then choose "Switch graphics": the message ends "The DOS
    files you located are used from the next start: restart civ64 to use the DOS graphics." Start civ64 again: the
    DOS graphics work and the item reads "DOS files present".
* **HM-7** (About and Close): "About…" opens the About box as before. "Close" (or Alt+F4, or the close button at the
  top right of the window) closes civ64 at once on the title menu and the setup pages; during a game it first asks
  "A game is in progress. If you exit now, any unsaved progress will be lost." with "Exit Anyway" and "Cancel":
  Cancel keeps the game running, Exit Anyway closes civ64.
* **HM-8** (dark mode): with Windows set to dark app mode, the window menu and its three submenus are all dark; in
  light mode all are light.
* **HM-9** (the keyboard in the open menu): with the menu open, pressing a letter underlined in it chooses that item
  (for example D opens Display, then F chooses "Fit to window"). No letter is used twice in the same menu. (Alt+Space
  and Alt still go to the game, as before; the menu opens with the mouse.)


## For the records

For the docs pass (HM edits no document other than this record):

* **DESIGN.md 12.2**, bullet "System menu" (`add_menu`; the paragraph from "the standard items without Close" to the
  ids' audit, about lines 1844-1895): describe the HM layout and table (Decision 1), the mnemonics (Decision 2), the new
  id 0x1100 `SC_CIV_SWITCH` with the audit, the submenus' WM_SYSCOMMAND and WM_INITMENUPOPUP behaviour (Findings 1, 2,
  4, observed by HM's probe), and that UX2's wrapper-menu inference is now observed (Finding 3); the Close text; the
  UX4b "Normal map zoom" text now "&Normal zoom\tCtrl+Shift+0, Home". Keep the history (UX1, UX3, LP, M, UX4b) in the
  usual "since"/"until" form. The refusal text (about line 2501): the two hints of Decision 10 and
  `present_set_dos_located`. The "Chord, menu and Locate" bullet (D3b2, about line 2561): "Switch graphics" calls
  `player_profile(PRESENT_PROFILE_TOGGLE)` as the chord; the present hook `hw_set_dos_present_hook` and civ64's rule
  (Decision 4). The test paragraph (about line 2161): HM's `test_hm` (section "Tests"; 410 -> 453 checks in Checked
  and Release, 381 -> 408 in CheckedNoObs) and the menu-loop child's retry.
* **FIDELITY.md**: F108 (About… is above a separator and Close, written with U+2026); F112 (the SC_CLOSE item's text
  "Close  Alt+F4" since HM); F114 (UX4b's menu text now "Normal zoom  Ctrl+Shift+0, Home"); F116 (the option's name
  in the menu "Correct 320 × 200 to 4:3", same meaning); F117 ("Locate DOS files…" is in the Graphics submenu and reads
  "DOS files present", disabled, while the run's DOS graphics are available or a Locate succeeded in the run); F118
  (the hint's two forms, Decision 10); F160 (the item's text); **F-new-1**: the window menu's layout with submenus,
  "Switch graphics" and the "DOS files present" note (not part of the original; the original's Windows 3.1 window
  menu was Windows' standard one) (**choice**, the user's request of 2026-10-17 about 10:08 and 10:28 UTC; the
  orchestrator's refusal-hint decision of about 12:26 UTC; `test_hm`, `test_input` `cadence`; user checks
  HM-1..HM-9).
* **RUNNING.md**: the menu paragraph (about lines 527-536) in the new structure and names; "Closing civ64" (about
  lines 545 and 804): "the window menu's **Close**"; the Locate paragraph (about line 449): "the Graphics submenu's
  **Locate DOS files…**", and "DOS files present" replacing it while the DOS files are present; the refusal paragraph
  (about lines 696-700): the hint names Graphics > **Locate DOS files…**, and after a Locate in the run it says to
  restart civ64; the Map zoom rows (about lines 714-715): "Map zoom" submenu, "Normal zoom", "Mouse wheel zooms map";
  the aspect option (about lines 521, 529, 614): "Correct 320 × 200 to 4:3"; the tests rows (about lines 135 and
  143): `test_hm` and its counts, `test_input` 612 in Checked and Release (555 in `checked noobs`) with the located
  hint; the "Tests" known-flake note: `test_hm`'s NOTE line is a retried run, not a failure.
* **FEATURES.md**: row about line 251 (Close's text); rows about 254-257 (names of the items); a new row "the window
  menu with the submenus Display, Map zoom and Graphics, Switch graphics, DOS files present, and the refusal's hint
  naming the Graphics submenu or the restart (HM)" with `w32_test_host_win32` `test_hm` and `test_input` `cadence`,
  status pending HM-1..HM-9.
* **DOS-PROFILE.md** line about 155: the option's name "Correct 320 × 200 to 4:3" (a text change only; then
  `gen/obs_tables.py --check` as usual, no call addresses added).
* **manual-checklist-ext.md**: HM-1..HM-9 ("What the user checks").
* **STATUS.md**: HM's row (the orchestrator).
* **Test open items** (for the checklist's or RUNNING's test notes):
  * `w32_test_host_win32` `test_hm`'s menu-loop child hung once under load before the rework (only "[desktop]"
    written, ended by its watchdog with code 6; the first full run, while D7c's Release build ran; cause unknown, not
    reproduced in 6 full runs, 20 + 8 runs of the child alone and 6 children at once). Since the rework a stuck menu
    is closed by its step's timer after 3 s, a child stuck elsewhere is ended by its watchdog after 14 s, a child
    still running after 30 s is ended by `child()`, and an incomplete first run is retried once with a `NOTE:
    test_hm: ...` line (its output kept as `w32-hm-loop-1.txt`); the check fails only if the second run is
    incomplete too. A NOTE line in a landing's log is worth recording (frequency), not a failure.
  * The mnemonic check counts Windows' own system items, whose letters follow the Windows display language; it
    passes on this PC's Windows. On another display language it could report a clash with Display or Graphics
    (accepted by the orchestrator; the menu still works there).


## Open points for the orchestrator

None open from the first staging: the refusal hint is in HM (Decision 10), the zoom-mark wording is corrected
(Finding 5), and the comment names and the other-language note are accepted ("Deviations", "Test open items").


## Landing

HM landed alone at the build slot of session E4, 2026-10-17, after D6fS-b's landing (ALL_GREEN 18:16:46, RELEASE_OK
18:20:37 UTC, `build/user-builds/d6fsb/`), landed by its implementer as the orchestrator directed (its message of
about 18:22 UTC: the slot is HM's; a joint docs pass for D6fS-b and HM prepares during HM's cycle and applies after
HM's RELEASE_OK). The user checks are in the user build `hm`: HM-1..HM-9 ("What the user checks").

* **Bases:** `tests/test_input.c` rebased onto D6fS-b's landed copy at 18:23:04 UTC (HM's hunk unchanged); the six
  other bases unchanged since their rebase (head of this record). The overlay rebuilt and the Win32-headless and
  headless tests rerun on that tree ("Results"). `build/hm-prep/land.py` rechecked every base (all seven equal), the
  record's absence and build.cmd and test.cmd (D6fS-b's copies, unchanged): DRY_RUN_OK 8. Scripts in
  `build/hm-prep/`: `land.py` (from D6fS-b's, for this stage's BASE/STAGED rows), `hm-cycle.ps1` and `compare.py`
  (from D6fS-b's), `mk_userbuild.py` (from D6fS-b's), `fill_stillopen.py` (from D6fS-b's: the group "d6fsb" added,
  holding D6-1, D6f-1, D6fSb-1..D6fSb-6, D6f-4, D6f-5, D6f-7 and D5-7 whatever build the checklist names; HM's own
  rows left out; the ux5b group's wording names the new item "Correct 320 x 200 to 4:3"). Snapshot
  `build/hm-prep/before` (the tree's `build/test/Checked` outputs of D6fS-b's cycle, 65 files) and `tree-before` (the
  seven replaced files); copy-in at 18:30:46 UTC (`landed.sha256`: the 8 files, build.cmd and test.cmd unchanged;
  `landed-at.txt` "unit hm"). Predictions `build/hm-prep/predictions.txt`, written before the copy-in.
* **The three-step cycle** (`build/hm-status.txt`, each step guarded by its log's OK marker): 1 `build.cmd checked`
  BUILD_OK 18:30:52..18:38:48 (477 s; portable sources checked 304); 2 `test.cmd checked` TESTS_OK 18:38:48..19:22:16
  (2608 s; TEST_SECTIONS 30 failed 0; no flake rerun, no `NOTE: test_hm` line); 3 `ext_g1.py check` EXT_G1_OK runs
  77 (amended 1) unchanged: **ALL_GREEN** (19:22:16 UTC). 4 `build.cmd` (Release) BUILD_OK 19:22:37..19:26:37
  (241 s): **RELEASE_OK**.
* **Against the predictions** (`build/hm-prep/compare.py` against the snapshot; `compare.txt`: 60 of 66 files equal,
  host times left out): as predicted, unit.log `test_input` 611 -> 612 with its new "[message]" line ("... The DOS
  files you located are used from the next start: restart civ64 to use the DOS graphics."), `test_host_win32` 410 ->
  453, every other count equal; the existing "[message]" lines read 'To use them, choose Graphics > "Locate DOS
  files<0x85>" in the window menu; ...' (compare.py leaves them out as "time" lines; read directly);
  `w32-hm-loop.txt` new (every step's marker, Close); NODOS_OK 0 hits (files 1800 -> 1802); REGISTRY_OK,
  OBS_LINT_OK files 140, ADAPT_OK rows 147 steps 27, OBS_TABLES_OK, pdos_scene_check 1084, P0_OK checks 476 and
  every harness section as before. Not predicted in detail, explained: coverage.txt "other functions entered" 667 ->
  668 (informational: `present_set_dos_located`); unit.log's OBS_COST line (host timing).
* **User build** `build/user-builds/hm/`: `civ64.exe` (the Release build, SHA-256 f0ad3c77...), `CIVWIN.zip` and
  `civdos.zip` from `build/user-builds/d4/`, `WHAT-TO-CHECK.txt` (HM-1..HM-9 and the 115 items still pending at
  19:26 UTC, by build, D6fS-b's 12 first).
* Not done at this slot: the checklist rows HM-1..HM-9, STATUS and the docs pass ("For the records"; the joint
  D6fS-b/HM docs pass, after this RELEASE_OK); the tree's CheckedNoObs build is not part of the three-step cycle (the
  private overlay's three variants are in "Results").

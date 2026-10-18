# Brief for the M implementers (extension phase M: map renderer and zoom, Windows profile)

Written 2026-10-11 by the orchestrator. Phase M of the extension prompt
`claude/docs/x64-port-scaling-dos-prompt.md` (section 9): "The map renderer (Windows rules) and zoom (Z)
in the Windows profile." Gate: "7.5 passes; Z-1..Z-3 for the Windows profile; agent UI check." By
decision C2 (`ext-d1-decisions.md`, area D) M's 7.5 is the M1 checks (key, render, settled); the
per-present comparison M2 is built and gated with D6. Asan runs are deferred to the end of the queue
(the user's direction of 2026-10-10 21:20).

M starts after the D3 gate (`ext-D3-acceptance.md`). It is done in two sequential units, each by one
implementer with exclusive ownership of the files it changes: **Ma** (zoom, layer, in-view source,
input, commands, the w16 queries) and then **Mb** (snapshots, the Windows rules, the ring, the mirror
proofs, zoomed-frame goldens). Mb writes the gate record.

## Authority and design

* The design is DESIGN.md 12.9 (summary), 12.10 (admitted w16 changes), 12.11 (scope of P0) and the
  detailed design `claude/port/docs/verify/ext-d1-draft-D.md` (Revision 3: M1 = section 2's row M1),
  with the resolutions in `ext-d1-decisions.md` (area D: C1..C7). Area A's side (draft A Revision 3
  and D's section 17 A-1..A-8) is D3's code: use what D3 built (`ext-D3a-record.md`,
  `ext-D3-acceptance.md`) and add D's items that D3 left for M. Implement as written; where the code
  shows the design is wrong or incomplete, make the smallest correct fix and record it as a deviation
  (design section, what and why) in your record. Never widen 12.10's list of w16 changes without
  recording why.
* **The user's directions** (STATUS.md "User directions"): the zoom levels are -1, 0, +1, halving or
  doubling the default (decision C1; draft D 4.1); the game's screen follows the host window (phase G).
* The extension prompt (1 P0, 4 Z-1..Z-3, 5.2, 5.3, 5.6 I1, I2, I7, I8, 5.8, 5.11, 7.3, 7.4, 7.5, 7.8)
  and the base prompt `claude/docs/x64-port-prompt.md` sections 1 (language rules), 5.0 (build),
  7 (tests) and 9 (determinism) govern. Follow the conventions, style and comment density of the
  surrounding code (`present/`, `present/dos/`).
* Game facts for the Windows rules come from the port's own sources (`claude/src`, the reviewed
  translation) and the base project's listing tools the base prompt allows (showfunc); never from
  memory.

## Rules

* **P0 above all.** The zoom never feeds `present_game_screen` (V4); the layer is drawn after the
  scaler; no core function is called, nothing in the emulation is written, no random number is drawn,
  no handle is allocated in w16. After every build: `test.cmd checked` (all base tests, gate3b
  references, scenarios, D3's `ext_p0.py` and `ext_frames.py`) and
  `C:/Python314/python -B C:/Projects/Civ1RE/claude/port/tests/harness/ext_g1.py check` on Checked and
  CheckedNoObs must stay green (EXT_G1_OK). A failure is fixed before anything else.
* **Builds are yours alone** during your unit: `cmd /c C:\Projects\Civ1RE\claude\port\build.cmd checked`,
  `... test.cmd checked`, `build.cmd checked noobs` as D3 defined it, then Release (`build.cmd`,
  `test.cmd`). No Asan (deferred). Timeout 600000 ms; logs under `claude/port/build/`.
* **Files.** Edit the code, tests and build files your unit needs and write your record. Do not edit
  `DESIGN.md`, `FIDELITY.md`, `STATUS.md`, `RUNNING.md`, `FEATURES.md`, `manual-checklist-ext.md`, the
  D1 drafts or the D0 documents: list the needed entries under "For the records" in your record.
* **Independence and DOS rules** as before: never read the main project's excluded paths
  (`claude/port/docs/verify/BRIEF-d0.md` lists them) or use AGENTS.md's GFX/DOS/Modern/Mac/SNES
  sections; no DOS bytes in the repository or a binary (`gen/dos/nodos.py check` must pass); never write
  `C:\Projects\Civ1RE\dos` or `claude/port/build/dosdata`; never execute a DOS program.
* **UI.** Win32-headless tests use hidden windows. The gate needs an agent UI check (Mb): a visible civ64
  window at 1920x1440 or the nearest the desktop allows, zoom -1/0/+1 by chord and wheel, a ring click,
  screenshots under `claude/port/build/ext-m-ui/`; civ64 windows only (the UI-launch grant); close it
  promptly. An agent observation is not user acceptance; the user checks C1 and C6 of
  `manual-checklist-ext.md` stay pending.
* No git writes. Use absolute paths; do not chain `cd` into shell commands. Python only as
  `C:/Python314/python -B` (never `-I`). Write files containing backslashes (C escapes, Windows paths)
  with the Write or Edit tool, never through heredocs or sed.
* Keep your context lean: read the sections of draft D you implement, not the whole of every draft.

## Tasks

* **Ma: zoom, layer, in-view source, input, commands.**
  * Draft D sections 3 (files; build.cmd and clang-tidy include lists gain `present\map`), 4 (levels,
    geometry, limits, wrap and poles), 5 (the layer: activity, clip, composition, sampling, damage),
    6.1 (the Windows in-view source `M`, including the map port's bitmap under dialogs), 11 (anchoring,
    clamps, the active-unit rule), 12 (input: mapping at arrival, `pmap_filter_ring` and frame 4, the
    wheel I8, the cursor), 13 (chords Ctrl+Shift+Plus/Minus/0 with the ACCELERATOR 128 audit, system-menu
    items 0x10C0..0x10E0, `--zoom default|-1|0|+1`, settings key `zoom`, the harness `zoom` command,
    `presented.log` `zoom L view CWxCH view_sha256`, `view-NNNNN.bmp`).
  * Area A items of draft D 17 that D3 did not deliver: A-1 (tick step 4 with `pmap_pending`), A-2
    (`pmap_overlay` after scaling, `pmap_on_core_present`), A-3 with A-3a (`g_outline`, `g_outline_on`
    in user_syscmd.c) and A-3b (the DC-free rasteriser split in gdi_draw.c and gdi_font.c; the virtual
    screen draws through the same code, so every core frame hash must stay equal), A-4, A-5 (frame 3
    and 4 in D3's arrival and filter stages, replacing D3's stubs), A-6, A-8. Check each against D3's
    record first; do not redo what exists.
  * Out of view at level -1 the ring is black until Mb (record it in your record as the interim state).
  * Tests: `tests/test_map.c` (draft D 16.1: geometry, anchors, limits, input, `pmap_filter_ring`,
    wheel accumulation), added to build.cmd/test.cmd in Checked and Release; 7.8 chord and wheel runs
    (16.5) in D3's 7.8 mode; V4 in `ext_p0.py` (16.4, Windows profile; DOS combinations come with D6);
    the `CIV_OBSERVER=0` refusal of zoom.
  * Open item D8 (posted button state after `FlushInputEvents`), answered by the 7.8 run.
  * Record: `claude/port/docs/ext-Ma-record.md` (what was built, tests and counts, measured layer costs
    against draft D 18, deviations, "For the records").
* **Mb: snapshots, the Windows rules, the ring, the proofs, the gate.**
  * Draft D sections 7 (the state snapshot and its triggers at probes, `PmapSrc` over a snapshot or live
    memory, the Windows rules in `pmap_win.c` reimplementing DrawMapTile, ComputeTileAppearanceKey,
    RenderTileFromKey, DrawUnitAt, DrawCityLabels and the unexplored-edge rule from `claude/src`, the
    world canvas), 8 (the view snapshot and in-view rectangle), 10 (mirror checks `key`, `render`,
    `settled` under `--mirror 1`; harness), the ring at -1 replacing Ma's black.
  * Tests: `test_map.c` rules on synthetic snapshots (16.1, last items), `tests/harness/ext_mirror.py`
    (16.2: `--mirror 1` clean on every scenario and S1..S5), `tests/harness/ext_zoom.py` (16.3: the named
    host sizes and policies, levels -1 and +1, goldens in `tests/harness/ext-zoom-golden.txt`,
    determinism across two runs; the profile-switch half of 16.3 comes with D6), both added to
    `test.cmd checked`.
  * Open item D4 (sight updates per AI turn; S4 measurement of snapshot cost).
  * The agent UI check (above).
  * Records: `claude/port/docs/ext-Mb-record.md`, then the gate record
    `claude/port/docs/ext-M-acceptance.md` in the style of the other `ext-*-acceptance.md` records: the
    gate table (7.5 M1 checks, Z-1..Z-3 for Windows, agent UI check) with methods (compiled, headless,
    agent-observed) and results, Ma's record and yours linked, deviations, Asan deferred, "For the
    records" (DESIGN 12.9 "As implemented (M)", FIDELITY, RUNNING, FEATURES), the user checks left
    pending, not verified.

Each implementer's final message: result, files changed, test counts, measured costs, deviations and the
"For the records" list.

## Unit LP: the low-priority requests (after the M gate)

### M+W (the user's request of 2026-10-11 about 18:35)

The user: "Add an option to disable mouse wheel zoom operations to the host application context menu.
This is low priority, implement after all checks done for the M phase." After `ext-M-acceptance.md`:

* A checkable item in civ64's system menu (the host window's context menu, next to Ma's zoom items),
  "Mouse wheel zooms the map", checked by default. Unchecked, the wheel does nothing over the map (the
  wheel never reaches the game in either state, I8); the zoom chords, the zoom menu items, `--zoom` and the
  harness `zoom` command are unaffected. The state is remembered in the settings file (a new key, written
  on change; an invalid value is ignored). Grayed together with the zoom items without the observer.
* Audit that the item's id is unused (as Ma did for 0x10C0..0x10E0). Win32-headless test (hidden window:
  the item toggles, the wheel then gives no zoom command, the key is written and read back); the 7.8 wheel
  run unchanged with the default. P0 unchanged (test.cmd checked, G-1 on Checked and CheckedNoObs,
  Release).
* Record `claude/port/docs/ext-MW-record.md`, with "For the records" (DESIGN 12.2, RUNNING, FIDELITY if a
  choice is made, manual-checklist-ext.md: a pending user check of the item).

### Version 1.0 and the About title (the user's request of 2026-10-11 about 20:15)

The user: "Set application version to 1.0 and update about dialog box title text to "About Sid Meier's
Civilization x64 v1.0" this is also low priority and implement with other low priority tasks."

* `win64/civ64.rc` gains a VERSIONINFO resource: FILEVERSION and PRODUCTVERSION 1,0,0,0; StringFileInfo
  FileVersion and ProductVersion "1.0", ProductName "Sid Meier's Civilization x64", FileDescription and
  OriginalFilename as fits civ64.exe (no original game data). Check with a Win32 query (GetFileVersionInfoW)
  in a test or the record.
* The host About box's title (`platform/win32/host_win32.c`, the `t_str(&t, L"About Sid Meier's
  Civilization")` line) becomes exactly "About Sid Meier's Civilization x64 v1.0"; if a test pins the
  old title, update it. Host-only: the game's own dialogs and every core frame are unchanged.
* One record for the unit: `claude/port/docs/ext-LP-record.md` (replacing `ext-MW-record.md`), with "For
  the records" (DESIGN 12.2, RUNNING, FIDELITY F108's About entry, manual-checklist-ext.md: pending user
  checks of the wheel item, the About title and the file version in Explorer's properties).

### Titles (the user's request of 2026-10-11 about 22:00; supersedes the About title above)

The user: "Make host application title bar text to "Sid Meier's Civilization 64bit" and About title bar text
to "About Sid Meier's Civilization 64bit v1.0"". The host window (class `Civ64Host`) title becomes "Sid Meier's
Civilization 64bit"; the About box title "About Sid Meier's Civilization 64bit v1.0"; VERSIONINFO ProductName
"Sid Meier's Civilization 64bit". Message-box captions stay unchanged (superseded: the user, 22:05, "yes update Error
and message-box captions also": every host error and message-box caption becomes "Sid Meier's Civilization 64bit").

### Window placement (the user's request of 2026-10-11 about 22:15)

The user: "The host application shall start both vertically and horizontally centered on the screen on initial
startup. Must remember its last position on the subsequent launches. And if it is for some reason out of display
area, it should re align itself top left corner of the primary screen on startup (display check)." Implemented in
LP as forwarded to its agent: first start centred in the primary monitor's work area; F111's remembering kept; a
remembered rectangle entirely off-screen (meeting no monitor; the user, 22:20: "entirely off-screen" is the rule)
goes to the primary work area's top-left
(size kept if it fits, else the default clamped; maximized state kept); a pure helper with unit tests.

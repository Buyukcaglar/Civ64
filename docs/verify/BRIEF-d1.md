# Brief for the D1 design agents (extension phase D1)

Written 2026-10-11 by the orchestrator. Phase D1 of the extension prompt
`claude/docs/x64-port-scaling-dos-prompt.md` (section 9) is the design of the observer and
presentation tick, composition and shadow surfaces, classes, timelines, adapters, the map renderer,
the palette rule and text, written as the "Extension" section of `DESIGN.md` (12.5 onwards), with
an independent design review. Each design agent drafts one area in its own file; the orchestrator
merges the drafts into `DESIGN.md` and has them reviewed. Read this whole brief first.

## Rules

* **Files.** Write only your draft `claude/port/docs/verify/ext-d1-draft-<id>.md` and scratch files
  under `claude/port/build/d1/scratch-<id>/`. Do not edit source, tests, `DESIGN.md`, `STATUS.md`,
  other drafts or any other file. Do not build, do not run the harness or tests (the orchestrator
  serializes builds), do not commit or stage. Read-only greps and Python scripts of your own are
  fine (`C:/Python314/python -B`, never `-I`).
* **Independence (base prompt 2.3, extension 2.0 item 1 and 2.3).** Never read the main project's
  paths: `C:\Projects\Civ1RE\reconstructed`, `analysis`, `symbols`, `reports`, `plan`,
  `RECONSTRUCTION_PLAN.md`, the root `README.md`, root `tests`, `scripts`, `mac`, `snes`, `assets`,
  `Civilization`. Ignore every `AGENTS.md` section (GFX, DOS, Modern, Mac, SNES). Windows facts come
  from `claude/docs`, `claude/src` (the recovered C), the port's own sources and docs, and
  `C:/Python314/python -B C:/Projects/Civ1RE/claude/tools/showfunc.py <addr>`. DOS facts come only
  from `claude/port/docs/dos/*.md` (the D0 drafts, under independent review: cite them by document
  and section so that corrections can be traced) and, where needed, the listings in
  `claude/port/build/dos/disasm/` and the files in `claude/port/build/dosdata/`. Never fill a gap
  from memory of the game. Never execute a DOS program.
* **Authority.** The extension prompt (whole text; sections 1, 2.0, 4, 5, 7, 8 above all) and the
  base prompt `claude/docs/x64-port-prompt.md` (sections 1, 5, 7, 9) govern. The user's later
  directions recorded in `claude/port/docs/STATUS.md` ("User directions" and "Extension track") and
  the delivered design `DESIGN.md` 12.1 to 12.4 win over the prompt's text where they differ (for
  example: `stretch` is removed; the game's virtual screen follows the host client during play,
  F105/F110; M is a backlog item with the user's zoom levels -1, 0, +1; Asan runs are deferred to
  the end of the queue). Name every such point you rely on.
* **Design quality.** Concrete and implementable: files and modules, data structures, function
  signatures, the exact w16 call sites (file and function, line numbers where stable), costs, error
  and limit behaviour, and the test that proves each property. For every rule of the prompt in your
  area (O1..O7, T1..T7, I1..I8, 5.3, 5.4, 5.8, 5.9, 5.10), say how the design meets it and how a test
  shows it. Keep P0 (extension 1) explicit: argue why nothing in the design can change a checkpoint,
  the virtual screen or the base event trace, and which test would catch a breach. Mark every
  decision that is a choice (not forced by the prompt or the evidence) as **Choice**, with the
  alternatives considered in one line. Mark unknowns as **Open**, with what resolves them.
* **Style.** Match `claude/port/docs/DESIGN.md` 12.x: plain English, short sentences, bullets and
  tables, addresses as `SSSS:OOOO` (Windows) or with the DOS prefixes `R:`, `O<n>:`, `G:`.
* **Final message** to the orchestrator: the draft path, a list of the main decisions (Choices),
  the open items, and anything in the prompt or the delivered design that conflicts with your
  design and needs the orchestrator's or the user's decision.

## Areas

* **A: observer, probes, read-only queries, presentation tick, profile switching, P0 tests.**
  Extension 5.1 (layers, host.h), 5.2 O1..O7, 5.6 I2 and I7 (the input filter's placement and the
  chord audit for Ctrl+Shift+Backspace), 5.11 (`--graphics`, the system-menu profile item, the
  settings key), 7.3, 7.4, 7.8, G-1. Decide: the event types and the exact w16 emission sites; the
  probe mechanism in `fr_enter` (lookup by original address, its cost, how `vm_steps`, statement
  markers and checked-build diagnostics stay untouched); the probe list as far as D0's
  `WINDOWS-INVENTORY.md` fixes it; the read-only query API and its guarantees (no fault, no
  diagnostics, no allocation); how O4 is enforced and verified (unit by unit verification, a guard
  in Checked builds, the spin test in `host_sync.c`); the presentation tick's call sites, rate, and
  its separation from `w16_present`'s dirty state, `g_last_present_us` and the harness's frame
  counter; the headless presented-frame trace for ticks; profile state and switching at the next
  tick with both profiles always current (O6, T2); the `CIV_OBSERVER=0` build; the harness commands
  for profile switches, zoom, policy and host size (not input); the P0 runner over
  `tests/harness/scenarios.py` and S1..S5 and its comparison; the 7.8 harness mode (HostEvents
  through `present/input`, then posted as `host_sync.c` does). The DOS profile in D3 may still show
  the Windows frame; design the switching so that D4..D7 add renderers without changing it.
* **B: composition, shadow surfaces, logical replay, classes, palette rule, text and fonts.**
  Extension 5.3, 5.4 (classes, "Logical replay", "The core's decisions", the scene table's use at
  run time), 5.9 "Palette", 5.10, 8 ("Colour spaces", "Pixels read as data", "Fonts and text",
  "The 640x480 versus 320x200 frames"). Decide: the N canvas and the A canvas, their palettes and
  damage, when a presented frame is N, A or the Windows frame, "W over N"; the DOS shadow surface
  for each emulated port or bitmap that logical drawing reaches, how replay follows the core's
  ports (`SetGrPort`, `g_currentGrPort`, front/back movie ports, `CopyPortToWindow`) and blits;
  the renderer's drawing primitives as a portable C model of the DOS driver functions the profile
  needs (`docs/dos/DRIVER.md`), with the DOS sprite, fill, blit, text and pointer semantics; the
  per-scene colour mapping (Windows colour bases and the +10 god-palette shift against DOS bases;
  EGA colour c against each scene's palette entries 0..15, OPEN P4); the 6-to-8-bit DAC rule; the
  font mapping and how it is derived from corresponding call sites (CORRESPONDENCE.md), the glyph
  semantics (spacing, colours, shadow, clipping, colour switches inside strings: OPEN P5),
  alignment from the observer's captured intent, the Windows-1252 coverage rule; class R re-skins
  rendered from the `w16` control tree; how class A substitutes art in the Windows layout. Settle
  OPEN.md P4, P5, P11 (by the pixel check it names, done read-only in your scratch) and say which
  of the other P items belong to areas C, D or E.
* **C: timelines, adapters and the input filter.** Extension 5.5 T1..T7, 5.6 I1, I3..I6, I8, 7.7,
  7.8, 8 ("Birth inside world generation", "RNG-driven presentation in the core", "Inverting the
  logical scale"). Decide: the DOS clock model for presentation-only sequences from
  `docs/dos/TIMING.md` (PIT ticks, the display rate, the sound tick: OPEN P1, P2, P7) and how a
  timeline maps emulated virtual time to its frame; the credits, intro, title-menu and Birth
  timelines (their data, start points per T1, the T4 hand-off, T5 skips that end all, T6 pauses);
  the presentation-local generators with the DOS algorithm for DOS-only random effects (OPEN P3)
  and how the core's own decisions (dissolve order, leader frame, blink phase) drive the DOS view;
  the scene state machine that follows the core through observer events; the adapter table format
  (`DOS-PROFILE.md` 1.7) and its DOS-form actions to Windows-form host events; the pending
  translation queue (I4) with its expected states and virtual-time limits; I5's per-scene mouse
  conversions (`PollMouseClick` 1108:017A/018F signed `*10/16`, `WaitForKeyOrClick` `>>4`,
  `ScaleLogicalX/Y`), proven from the listing for each consumer; I6 consumption. Settle OPEN.md P1,
  P2, P6, P7, P10 (as far as timing is concerned).
* **D: the map renderer and zoom (phase M, a backlog item, and D6's DOS map).** Extension 5.8 with
  the user's decisions recorded in STATUS.md (levels -1, 0, +1; the 5.8 design; the planned shape in
  the M row). Decide: the map layer and its clipping to the map window's visible client region; in
  view, the core's own map-client pixels (Windows profile) and the DOS composition (DOS profile);
  out of view, a read-only renderer from game state (terrain keys after ComputeTileAppearanceKey
  and RenderTileFromKey, fog edges, cities, units, labels) with mirror equality as its proof (7.5);
  anchoring, the active-unit rule, east-west wrap and poles; input mapping inside the layer and the
  out-of-view press rule; the zoom state, chords (Ctrl+Shift+Plus/Minus/0, the wheel), `--zoom`
  and the system menu; the DOS profile's map rules from `docs/dos/SCENES-PLAY.md` and `SPRITES.md`
  (terrain composition, coasts, rivers, specials, improvements, units, cities, labels, unexplored
  edges, the DOS palette animation; OPEN P9). Note the user's phase-G screen-follow design (the map
  window's size changes with the host client).
* **E: DOS assets at run time (phase D2).** Extension 5.9, 7.6, D-1, 2.3 "No DOS bytes". Decide:
  the read-only host service for the DOS directory or the DOS ZIP that phase R already locates
  (`win64/civ64_locate.c`, DESIGN.md 12.3: a DOS ZIP is kept in memory, never extracted), its
  `host.h` interface and its headless implementation; per-file pinning (`tests/dos-files.txt`:
  names, sizes, SHA-256, no bytes) checked at first use; the failure behaviour of 5.9 (explicit
  `--graphics dos` exits with code 2 naming the file; otherwise the profile is unavailable with one
  message); the portable bounds-checked EXEPACK decoder and the `CIV_UNP.EXE` alternative; overlay
  reading; the PIC (`E0`, `M0`, `X0`, `X1`), PAL, `FONTS.CV`, text-file and pointer decoders,
  following the DOS listing's routines as `docs/dos/FORMATS.md` records them; the data tables read
  from the DOS image at recorded offsets (sprite rectangles, layouts, colours, palette-cycle ranges
  and timings), with an offset registry in `docs/dos/`; never writing the DOS files (OPEN P8);
  memory safety on malformed input and the 7.6 test plan (every file parses, decoded hashes,
  EXEPACK equality, truncation and corruption vectors under ASan, with the user's Asan deferral);
  the `present/dos/` module layout. Settle OPEN.md P8.

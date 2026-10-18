# D1 draft C: DOS clock, timelines, scene sequencing, adapters and the input filter

Design agent D1-C, 2026-10-11. Extension phase D1 (`claude/docs/x64-port-scaling-dos-prompt.md` 9),
area "C: timelines, adapters and the input filter" of [BRIEF-d1.md](BRIEF-d1.md).

* **Scope.** Prompt 5.5 T1..T7; 5.6 I1, I3..I6, I8; tests 7.7 and 7.8; section 8 "Birth inside world
  generation", "RNG-driven presentation in the core" and "Inverting the logical scale"; the OPEN.md
  P items about time and input.
* **Boundary.** Area C owns time, sequence state, the scene state machine, adapters, pending
  translations and the mouse conversion. Area B owns pixels: shadow surfaces, the N and A canvases,
  fonts, palettes as colours, the DOS pointer's image. Area A owns the observer, probes, `w16q_*`, the
  tick, the arrival stage and the place of the filter. Area D owns the map layer and frames 3 and 4.
  Area E owns the DOS files, the offset registry and the decoders.
* **Status.** Revision 3 (after RV2; lists below). Nothing is implemented. Aligned with draft B
  (`ext-d1-draft-B.md`) after it appeared: the timelines draw through B's DOS machine (B 3..5), the
  generator module and the P16, P18, P20, P21, P24 settlements are B's, hit geometry is B's
  `pdos_r_hit` (B 11.4). Every C↔B interface is listed in C.21 for RV2 to check.
* **Evidence labels.** As the D0 documents: **DOS listing**, **DOS file**, **inferred**, **unknown**;
  Windows facts by showfunc (scratch `build/d1/scratch-C/sf_*.txt`) and `claude/src`. Windows
  addresses `SSSS:OOOO`; DOS addresses `R:`, `O<n>:`, `G:`, `DGROUP:`. "Choice" marks a design
  decision with its rejected alternatives; "Open" marks what this draft leaves undecided.

## Revision 3 (after RV2)

This revision applies [ext-d1-review-rv2.md](ext-d1-review-rv2.md) as
[ext-d1-decisions.md](ext-d1-decisions.md) "Design review RV2" resolves it, and the merge item C-11.

* **RV2-2 (major).** C.11.2's CustomizeWorldDialog and RunNewGameSetup rows now cite A 4.3's new
  caller rows (`ra` 11E0:0826 and 11E0:020A); WI 10.7 filters those functions only by the GR_DialogOpen
  calls inside them, so Revision 2's "yes" was wrong. The `ra` values were checked (call at 11E0:0821
  and 11E0:0205).
* **RV2-3 (major).** C.20.2 item 2 is confirmed: A 10.1 and D 12.1 latch a press's class until its
  release, so every part of a ring press is frame 4 (C.12.2, C.21 D-1).
* **RV2-4.** `pdos_seq_reset` resolves C.11.2's call-site pairs with A's `obs_callsite` (C.11.2).
* **RV2-5 and C-11.** C.12.1's code block uses the note's return value; the note's comment and C.12.1's
  text say so; C.12.2's fallback is withdrawn; C.15.2 gains the frame-0 release of a press consumed on
  frame 1. C.19's C-11 and C.20.2 item 1 are closed.
* **RV2-9.** C.5.5 and C.8.3 use E's file ids `PDOS_F_CREDITS_TXT`, `PDOS_F_STORY_TXT` and the
  three-argument `pdos_text_line(id, i, &len)` (C.21 E-1).
* **RV2-12.** C.21 B-8 records B's exit order (Choice B24): C's timelines reach the probe's time, B
  draws, the scene pops, then `pdos_seq_on_probe`.
* **RV2-13.** C.14.2: the RanDoMRadio items are created at 1220:09B0 only (1220:08D5 creates
  `g_dialogTitleStatic`); C.5.4 cites B 4.4 for `pdos_menubox_*`; C.10.1 cites B's `uint16_t`
  `pdos_srand`.
* **C-10** is closed: RV2 found B's final signatures match C.12.5 and C.8.7.

## Revision 2 (before RV2)

This revision applies the orchestrator's resolutions in [ext-d1-decisions.md](ext-d1-decisions.md)
("Area C" C.20-1..10, "Area B", "Design review RV1") and area A's Revision 2
([ext-d1-draft-A.md](ext-d1-draft-A.md): its "Area C" block, 4.2, 4.3, 6.2, 8.1, 10.1, 12.2, 12.4
and 17). It also takes the names that area B's Revision 2 has published so far
([ext-d1-draft-B.md](ext-d1-draft-B.md) 2.1, 4.4, 5.3). The boundary is unchanged: C owns time,
sequence state, adapters and input; B owns pixels.

* **A's three changes, adopted.**
  * **Cancellation on frames 0, 3 and 4** (A 10.1, 17). New `pdos_adapt_note(ev)`. A calls it for
    every event of frames 0, 3 and 4 while the DOS profile is registered. It applies C.12.2's action
    rule: a key press that is not a repeat, a character, or a button press (on frame 4, a ring-square
    press) is a user action and cancels a pending DOS translation (C.13.4). It never changes, consumes
    or posts an event (C.12.1).
  * **Open C-1 closed** (A 12.4). `ext_adapt.py` writes the Windows-form events of an I4 release as a
    `sync <n>` host-form line. n comes from the release line of the DOS-form run's `adapt.log`, which
    carries the input-sync ordinal. An `at <ms>` line cannot target a sync, because several syncs can
    share one virtual time: a PeekMessage that finds a message costs none (queue.c:552) (C.15.4).
  * **Lint.** The `RandomBelow` rule covers only calls and declarations of the core function. Probe-row
    names such as `OBS_P_RandomBelow` are allowed (A 6.2; C.15.5).
* **A's definitions, adopted.**
  * Frame stamps come from the profile callback `input_frame` (A 8.1). The values are 0 Windows; 1 N,
    with N-canvas pixels; 2 A, with virtual-screen pixels; 3 a layer point; 4 a ring square. Every
    event is stamped, keys and characters included (C.12.1).
  * `ObsProbe` is A 4.2's record: `id`, `phase`, `far_ret`, `addr`, `ra`, `site`, `t_us`, `arg_base`.
    Handlers test `site` and read arguments with `w16q_arg16(p, i)` (C.11.2).
  * The filter returns at most `PI_MAX_OUT` = 16 events per host event. C's bound is 8 (C.12.1).
  * The I4 release runs once per input-taking sync, after that sync's own host events (C.13.2).
  * Logs go through `present_log` (A 12.2).
  * The probe rows are in A 4.3 (C.20-9). GR_DialogClose is 1098:1612. DrawUnitStackList is called by
    `push cs` plus a near call, so its frame returns far and its row compares the full `ra` 11C0:334F.
    Revision 1 called it near (C.11.2).
  * D3's DOS profile gives `input_frame` 2, so C sees no N scene before D4 (C.12.1).
* **New: pairing across frames** (C.12.2). A press and its release can arrive with different frames:
  a key held across a profile switch, or a drag from a DOS box (frame 2) that ends over D's map layer
  (frame 3). `pdos_adapt_note` records presses on frames 0, 3 and 4, so a later part that reaches
  `pdos_adapt_filter` passes. **Request to A (C.20.2 item 1):** `pdos_adapt_note` returns 1 for a part
  of an action C decided other than by "pass", and A then hands that event to `pdos_adapt_filter`
  instead of its frame's path. Without it, the release of a translated key can be lost. A fallback
  that needs no change in A is described.
* **The orchestrator's resolutions, applied in the text.**
  * C.20-1: the P15 citation is corrected at the merge (C.14.2).
  * C.20-2: P25 is accepted, with a FIDELITY entry and a user check (C.12.6, C.17).
  * C.20-3: Birth's T4 setup page is accepted. DOS-PROFILE row 9 and 3.1 are corrected at the merge
    (C.8.7).
  * C.20-4: N, L, E, C count "during the pan". DOS-PROFILE 1.7 is corrected (C.6.4).
  * C.20-5: OPEN P22 is corrected. The 10 s limit covers the 237-movie-frame wait (C.13.4).
  * C.20-6: TIMING 5.3 is corrected (C.6.2).
  * C.20-7 and C.20-8: FIDELITY entries (C.12.3, C.4.1, C.7.4).
  * C.20-9 and C.20-10: accepted in A's and B's revisions.
  * C.20 now records these as resolved and lists only the new points.
* **Area B's names, taken over.**
  * The N machine is `pdos_mn` (Revision 1: `g_mn`).
  * The menu-box row query is `pdos_menubox_row(b, mx, my, &disabled)` (B 4.4; C.12.5).
  * The cycling shortcut is `pdos_cycle_advance` (B 5.3; C.5.4).
  * `pdos_profile.c` calls C in the order of B 2.1. B asks C for `pdos_seq_reset()`, which is added
    (C.11.1).
  * Decision X3 (the 4:3 default for 320x200 frames) changes only the host-to-N mapping, which is A's.
    Frame-1 points stay N-canvas pixels, so C.14 is unchanged.

## C.0 Authority points relied on

| Id | Source | What it fixes here |
|---|---|---|
| AU1 | Prompt 1, P0 | Checkpoints, virtual screen and base trace independent of presentation (C.2) |
| AU2 | Prompt 5.2 O1..O7 | Events stamped with virtual time; probes in `fr_enter`/`fr_leave`; read-only queries; O4 prohibitions; every profile consumes everything (O6); the tick (O7) |
| AU3 | Prompt 5.4 "Flow", "The core's decisions", generators | Windows order; DOS renderer follows core decisions; presentation-local generators with the DOS algorithm, never `g_randSeed` |
| AU4 | Prompt 5.5 T1..T7 | Timelines (C.5..C.9) |
| AU5 | Prompt 5.6 I1..I8 | Filter, adapters, pending translations, mouse, consumption, wheel (C.12..C.14) |
| AU6 | Prompt 7.3, 7.4, 7.7, 7.8 | Tests (C.15) |
| AU7 | Prompt 8 | The three hard parts named in the scope |
| AU8 | `ext-d1-decisions.md` K1, K3, K5, E.18-5, C6, RV1-5, RV1-7, RV1-18, RV1-19; "Area B" X3; "Area C" C.20-1..10 | Scoped P0; modifier hold rule; `HostEvent.frame`; immediates as C constants with their DOS address, data tables through the registry; ring press; `--dos-data` in DOS variations; the cursor route; `pdos_` file names; call-site rows of near callees; the 4:3 default for 320x200 frames (X3); the resolutions of C.20.1 |
| AU9 | User directions in STATUS.md: 2026-10-09 06:47 and 06:50; 2026-10-10 about 10:50 and about 11:35 | Birth skippable by any key once the world exists; world generation at full speed; first Enter starts New Game, a second Enter skips Birth when the world is done; any key in the credits or intro jumps to the title menu after the logo |
| AU10 | DESIGN.md 6 (virtual clock in µs, poll costs, TickCount 1100:02E1 = GetTickCount·60/1000), 6 item 7 (F86: when a PeekMessage takes host input), 9 (harness), 12.1..12.4 | Time base and the sync points the filter runs at |
| AU11 | Draft A Revision 2: 3 (ObsEvent), 4.2 (`ObsProbe`), 4.3 (probe rows), 5 (`w16q_*`), 6.2 (lint), 7 (tick), 8.1 (`PresentProfile`, `input_frame`), 10.1 (filter, note and release placement, `HostEvent.frame`), 10.2 (chords, K3), 12.2 (logs), 12.4 (7.8 mode, `sync <n>` lines, `coreinput.log`), 13, 17 | Interfaces this design plugs into |
| AU12 | Draft D 12.1, 12.2, 14.6, 17 | Frames 3 and 4 in the filter; the map follows the core's timing (P6) |
| AU13 | Draft E E.2.1 (prefix `pdos_`), E.8.1 (`pdos_text_line`), E.10 (registry: `BIRTH_CYCLE`, `BIRTH_SCHEDULE`, `TITLE_MENU`) | Data access |
| AU14 | TIMING.md 1..5, SCENES.md 4..10, PALETTE.md 4, DRIVER.md G#10, CORRESPONDENCE.md finding 7, OPEN.md P/O items, DOS-PROFILE.md 0.2, 0.6, 1.1, 1.7, 1.7.1, 3 | DOS facts |

## C.1 Summary

* **One DOS clock model** (`pdos_clock`): the VGA frame of 17,024 PIT clocks (P1), NSOUND's sound tick
  on six of every seven frames with the divider reset at every tune start (P2, P29), full-palette fade
  batches (P7), and an "ideal DOS machine" on which DOS code takes no time. Frame k of a timeline
  happens at `t0 + ⌈k · 17,024 · 10^6 / 1,193,182⌉` µs. All durations are integers in frames.
* **One timeline engine** (`pdos_tl`): each DOS sequence is a C transcription of the listing's control
  flow at the level of its waits. It runs on the emulated virtual time read through the free
  accessor. Its inputs are observer events and probes, virtual time, and "view actions" from the
  filter. It draws by calling area B's DOS machine primitives (B 3..5) at each step's instant, as the
  DOS code calls its driver. Before an
  event is applied the timeline runs up to the event's time, so its output does not depend on when
  ticks happen.
* **One scene state machine** (`pdos_seq`) follows the core through probes (C.11). When the core enters
  a scene, the DOS view goes there too; a DOS sequence the core has left is abandoned. When the DOS
  sequence ends first, the view shows the DOS program's next screen if it is fully known (the title
  box; the first setup page), otherwise it holds (T4).
* **Skips** (T5): a skip from the core (its own skip probes) or from a DOS-form user action ends the DOS
  sequence the way the DOS listing does (next column, next hold step, next due Birth event). The input
  reaches the core only while the core is in the matching state.
* **The filter stage for the DOS profile** (`pdos_adapt`) passes, consumes or translates each host event
  by the scene state and the event's stamped frame. A press and everything belonging to it (repeats,
  release, moves while held) share one decision, whatever frame each part arrives with. Events of the
  Windows frame and D's frames pass, but C observes them (`pdos_adapt_note`).
* **Pending translations** (`pdos_pend`, I4): at most one, of at most six steps, each released at the
  first input-taking sync after its expected core state is seen; cancelled by any other user action on
  any frame, or after 10,000,000 µs of virtual time in one step.
* **Mouse conversion** (I5): proven per consumer: d = ⌈16L/10⌉ for PollMouseClick, WaitForKeyOrClick and
  CityScreenWndProc; d = ScaleLogical(L) for forward-scaled rectangles; a point of the control's visible
  region for control rectangles.
* **Generators** (P3): area B's presentation-local DOS `rand` (B 9.3; R:2045:2AEA, 214,013·s +
  2,531,011, checked against the listing here); the core's decisions are followed wherever they exist;
  area C owns only the timing of the effects that use them.

## C.2 P0 for area C

**Claim.** Nothing in area C can change a checkpoint, the virtual screen, the base event trace, the
emulated clock, `vm_steps`, `vm_site`, a handle number, a checked-build diagnostic, `g_randSeed`, the
emulated queue or the key state, except through user input that the filter passes on by design (I3),
which P0 does not cover.

**Argument, step by step.**

1. **Where the code is.** Every area-C function is in `present/` (`pdos_*.c` and the filter dispatch in
   `present/input.c`). It includes no `vm.h`, `w16_int.h`, `w16_api.h`, `queue.h`, `clock.h`, core or rt
   header. It reads the emulation only through `w16q_*` (no faults, no checked records, no allocation;
   A 5) and the clock through `w16q_now_us()` (the free accessor; no poll cost; A 5).
2. **Timelines and the scene machine have no output into the emulation.** They consume `obs_event` and
   `obs_probe` callbacks and call area B's DOS-machine primitives on presentation state (C.5.4). They never call a
   `w16_<Api>`, post, send, change the cursor, capture, focus or key state, or touch `vm_steps`,
   `vm_site` or `g_randSeed` (O4).
3. **The only path into the emulation is the filter and its release**, both returning `HostEvent`s that
   `host_sync.c`'s `post_event` posts (A 10.1). They run only in `w16_host_sync` when the sync takes
   input, inside A's Checked guard. `pdos_adapt_note` returns no events; its return value (C-11, adopted
   by A 10.1) only moves an event from A's identity path to `pdos_adapt_filter`.
4. **In the P0 runs the filter has nothing to decide.** 7.3 injects core input as now (scripted posting
   straight into the emulated queue, A 12.3, X0 D28), not through `host_poll_event`. Either
   `w16_host_sync` returns before its input block (`W16_TIMING_NONE`, host_sync.c) or the host ring is
   empty, so `present_input_filter` never sees an event. No user action exists, so no pending translation
   exists, so `present_input_release` returns 0 (I1: nothing time-driven produces input). Therefore V1
   (`--graphics dos`) and V2 (switching) cannot differ from V0 through area C.
5. **The clock.** The filter and the release do no polls. Reading control rectangles through `w16q_*`
   costs no virtual time. Running the DOS timeline up to the sync's time inside the filter (C.12.1) is
   presentation work only.
6. **Key state.** Outside P0 (7.8 and play), the pairing rule (C.12.2) makes every posted press have a
   posted release, so no key or button stays down in the emulated state because of a presentation
   decision. Across frames this holds through A's routing of the parts of C's actions (C-11, C.12.2) and
   A's press latch for ring presses (RV2-3).
7. **Scoped P0 (K1).** The I5 conversion reads the core's window rectangles. With `--game-screen view`
   they follow the host size; with a fixed game screen they do not. This is the K1 scope; area C adds
   nothing to it.
8. **`--timing host`** (T6, FIDELITY): presentation work takes real time and so virtual time. Area C's
   work per tick is small (C.5.7). P0 is defined for injected virtual time.

**Tests that catch a breach.**

* 7.3 `ext_p0.py` V1, V2, V6 (A 13.1): any input or clock change from area C changes `events.log` or
  the `frame `/`snapshot ` lines.
* `obs_lint.py` gains the area-C rules of C.15.5 (no `w16_` call other than `w16q_`, no
  `g_randSeed`/`1420:4EE0`, no call or declaration of the core's `RandomBelow`, no
  `post_event`/`host_poll_event`, no `vm_` symbol in `pdos_*.c`).
* `test_input.c` (C.15.2): `present_input_release` returns 0 without a pending translation created by a
  user action; every emitted press has its release; the Windows profile at the default zoom is the
  identity (A).
* `test_timeline.c` (C.15.1) runs without an emulation at all: the timelines link against no w16 code.

## C.3 Modules and files

All new files carry the `pdos_` prefix (E E.2.1, RV1-18); object names stay unique for build.cmd.

| File | Role |
|---|---|
| `present/dos/pdos_clock.h/.c` | The clock model of C.4: frame grid, sound ticks, fade weights, cycle steps, primitive durations. Pure functions. |
| `present/dos/pdos_tl.h/.c` | The timeline engine (C.5): instances, `pdos_tl_run`, abandon and finish, view actions, the per-frame effects and the step log; calls B's primitives (C.5.4). |
| `present/dos/pdos_intro.c` | The intro, credits and logo program (C.6) and the title box state (C.7). |
| `present/dos/pdos_birth.c` | The Birth program (C.8) and the post-Birth transition to the first setup page. |
| `present/dos/pdos_fx.c` | TX effects of other scenes (C.9): fades, dissolves, cycling, strip reveals, text-cursor blink. |
| `present/dos/pdos_seq.h/.c` | The flow state machine (C.11): listens to B's scene stack (`pdos_scene_listen`, B 9.2) and adds the flow state the timelines and adapters need (MenuZ readiness and selection, world flags, skips, setup step); drives the timelines. |
| `present/dos/pdos_adapt.h/.c` | The DOS filter stage (C.12): dispatch by frame and scene, pairing, the menu-box model. |
| `present/dos/pdos_adapt_tab.c` | The adapter rows of C.12.6..C.12.8 as tables (generated into DOS-PROFILE.md 1.7 v2 by `gen/dos/adapters.py`, C.12.4). |
| `present/dos/pdos_pend.h/.c` | Pending translations (C.13). |
| `present/dos/pdos_mouse.h/.c` | The I5 conversions (C.14). |
| `present/input.c` (area A's file) | `present_input_filter` calls `pdos_adapt_filter` for frames 1 and 2 and D's ring translation for frame 4; `present_input_release` calls `pdos_pend_release` (C.12.1). |
| `tests/test_timeline.c` | Unit tests of C.15.1 (portable, no emulation). |
| `tests/test_input.c` (area A's file) | Additions of C.15.2. |
| `tests/harness/ext_timeline.py` | 7.7 (C.15.3). |
| `tests/harness/ext_adapt.py` (area A's file) | DOS-form scripts of 7.8 (C.15.4); scripts in `tests/harness/dosform/`. |
| `gen/dos/adapters.py` | Writes DOS-PROFILE.md 1.7 v2 rows from `pdos_adapt_tab.c`'s source table and checks they agree (C.12.4). |

* Language: portable C as DESIGN.md 1. Includes: `host.h` (HostEvent), `present/observe.h` (ObsEvent,
  ObsProbe, `w16q_*`), `present/profile.h`, E's `pdos_assets.h`, B's pure headers `pdos_mach.h`, `pdos_draw.h`,
  `pdos_glyph.h`, `pdos_ui.h`, `pdos_pal.h` and `pdos_scene.h` (C.21), their own headers. B's
  `pdos_profile.c` (the DOS `PresentProfile`) calls `pdos_seq_on_event`, `pdos_seq_on_probe` and
  `pdos_seq_advance` from its `on_event`, `on_probe` and `advance` (C.21 B-8). `present/` behaves the
  same in every variant (O1): no `#if CIV_CHECKED`.
* Build: E's line `"%PORT%\present\dos\*.c"` in build.cmd's portable loop covers these files.
  `test_timeline.exe` joins test.cmd's generic loop; `ext_timeline.py` runs where A's `ext_*.py` run.

## C.4 The DOS clock (P1, P2, P7, P29)

### C.4.1 The ideal DOS machine (model rules)

The DOS program measures its own display and runs on real hardware; the port needs one deterministic
model. Rules M1..M12, each with its source. "Instant of frame k" means the virtual time at which the
k-th frame routine of the timeline runs.

| Rule | Model | Source | Label |
|---|---|---|---|
| M1 | **Frame grid.** Each timeline has its own grid anchored at its start event t0 (C.5). Frame k (k ≥ 1) happens at t0 + k·P/1,193,182 s with P = 17,024 clocks (70.088 Hz nominal) | TIMING 1, 2.2 (VGA `P`, `k` = 4) | P1 Choice |
| M2 | **DOS code takes no time.** Drawing, picture and text loads, disk access and computation happen at the instant of the last frame boundary (or t0) | – | Choice |
| M3 | **Retrace waits return at once** (R:0000:0554, G:0000:01A1, G#23/24); a palette load through G#26..G#28 takes 0 frames | TIMING 3.5, 3.7 | Choice (real: up to 1 frame each) |
| M4 | **The first palette fade of a DOS session** spends one extra frame in the measurement R:0000:0573: interrupts are off from R:0000:0580 to the `sti` at R:0000:05B3, one frame boundary passes and its routine runs before R:0000:054F stores the frame count, so it carries no fade step. Later fades reuse the cached DGROUP:0066 | DOS listing R:0000:050C..054F, 0573..05B6 | inferred |
| M5 | **Fades** (P7): `E` = 256 entries per frame, so every frame of a fade writes the whole palette. A fade of `steps` takes F = 6·steps frames; frame j (1..F) writes weight t_j = min(65,535, j·⌊65,536/(F − 1)⌋), each component round-half-up of (s·(65,535 − t_j) + d·t_j)/65,536. Duration F (+1 by M4) | R:0000:050C (`[0x64]` = 256 when M/14 ≥ 256; initial weight = step at 0549), 05B7..062A (pass, weight advance and saturation at 061B..0624), 0631 | DOS listing; E = 256 P7 Choice |
| M6 | **Cycling.** A slot started (R:0000:03FA) at the instant of frame a steps at frames a + rate·i, i ≥ 1, until stopped (R:0000:042B); stopping keeps the DAC as it is. `rate` is stored as a byte (300 → 44) | TIMING 3.6 | DOS listing |
| M7 | **Sound tick** (P2, P29). NSOUND: `S#3` runs in every frame routine except every seventh after the last `S#1`. After f frames from a tune start S(f) = f − ⌊f/7⌋ ticks; tick n ≥ 1 falls on frame n + ⌊(n − 1)/6⌋ | TIMING units, 2.5 step 5, 3.4 | P2, P29 Choice |
| M8 | **Waits.** `wait(n)` (R:0182:0134) called at the instant of frame a returns at the instant of frame a + n (n ≥ 1; n ≤ 0 at once). A poll of `S#5` for tick ≥ v returns at the instant of tick v's frame. A `kbhit` test at instant u sees a key whose arrival time ≤ u | TIMING 3.3 | DOS listing; arrival model Choice |
| M9 | **No catch-up.** The skips O2:0476, O2:07D0, O2:10A9 never fire: on M2 the tick at a column's test equals the previous column's target, and targets increase by at least 5 ticks | arithmetic of TIMING 5.3 | proven (model) |
| M10 | **Dissolve** `G#10(page, c)`: the BIOS-tick wait (0000:0440) and the first-use calibration take 0 frames; then n = max(1, ⌊8,800/c⌋) pixels per frame from the next frame, so after j frames min(64,000, j·n) pixels are copied in LFSR order; duration ⌈64,000/n⌉ frames (c = 20: 440 per frame, 146 frames, 2.083 s) | DRIVER G#10, TIMING 3.7 | Choice (real: 0..54.9 ms + about 2 frames; O2) |
| M11 | **Key flush** R:0403:4545 takes 0 frames (no button held in the model) | TIMING 3.7 | Choice |
| M12 | **Birth's step function** is called at every instant while DOS Birth runs, so an event starts exactly when due | TIMING 4 (O7:17CF "never early") | Choice |

Rejected alternatives:

* **P1:** the 60 Hz fallback (19,886 clocks): it is the calibration failure path (R:0000:02DF..02EA), not
  the VGA behaviour. The exact refresh 25.175 MHz/(800·449) = 70.086 Hz: it differs from 17,024 clocks
  by 0.47 µs per frame (1.9 ms over the intro) and is not an integer number of PIT clocks; 7.7 counts
  PIT ticks.
* **P29:** a free-running divider from the run's start: its phase in the DOS program depends on disk
  and set-up time and is arbitrary (TIMING Open 11). Resetting it at `S#1` gives TIMING's "a" values
  exactly, so 7.7 can compare with the tables.
* **One global grid** from the run's start: a 0..1 frame offset at every sequence start for no gain.
* **Modelling CPU time** for M2/M3/M10: not derivable from the listing; DOS-oracle questions O1, O2.

### C.4.2 Virtual time to a timeline frame

> **C passage condensed for the public copy.** The original record has here a block of 21 lines of C code (statements or function bodies): types `PdosGrid`; functions `pdos_frames_done`, `pdos_frame_us`, `pdos_tick_frame`, `pdos_ticks_after`, `pdos_fade_weight`, `pdos_cycle_steps`; constants `PDOS_PIT_HZ`, `PDOS_FRAME_CLK`, `PDOS_SPAN_MAX`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* `d · 1,193,182` stays below 2^64 for `d` ≤ 2^40 µs; `k · 17,024,000,000` stays below 2^64 for
  k < 2^29 (89 days of frames). Every DOS sequence ends within minutes; saturation is a limit, never
  reached in a run.
* The two functions are inverse: `pdos_frames_done(g, pdos_frame_us(g, k)) == k` and one microsecond
  earlier it is k − 1 (checked for k ≤ 10^7 in C.15.1).
* `pdos_tick_frame` and `pdos_ticks_after` are inverse in the same sense (checked for n ≤ 20,000;
  scratch `intro_model.py`).
* Example (TIMING 1, the logo wait): tick 3,463 → frame 4,040 → 57,641,634 µs after the tune start
  (the "a" value 57.64 s).

### C.4.3 Primitive durations on the model

| Primitive | Frames | Skippable | Source |
|---|---|---|---|
| `wait(n)` R:0182:0134 | n | no | M8 |
| `S#5` poll until tick ≥ v (from a tune start at frame a) | until frame a + pdos_tick_frame(v) | only where the loop tests `kbhit` | M7, M8 |
| Fade R:0000:04AA / 04D4 (`steps`) | 6·steps (+1 for the session's first fade) | no | M4, M5 |
| Cycling step | every `rate` frames | – | M6 |
| Dissolve `G#10(page, c)` | ⌈64,000/max(1, ⌊8,800/c⌋)⌉ | no | M10 |
| Palette load `G#26..28`, picture load, text read, drawing | 0 | – | M2, M3 |
| Key flush R:0403:4545 | 0 | – | M11 |
| Menu box confirmation R:1D05:0441 | 20 (the box stays) | no | TIMING 5.4 |
| Text-entry cursor O23:04B9..0518 | 10 on, 10 off while no key | – | SCENES 10.4 |

## C.5 The timeline engine (`pdos_tl`)

### C.5.1 Inputs

A timeline is a pure function of three ordered inputs, each stamped with virtual time:

1. **Observer events and probes** (A 3, 4), delivered through `pdos_seq` (C.11).
2. **Virtual time** at each presentation tick (A 7), at each event, and at each filter call.
3. **View actions** from the DOS filter stage (C.12): a DOS-form user action the DOS program would see
   (a pending key, a highlight move, a choice in a box the core has not opened yet). They exist only when
   the filter runs (7.8 mode and play), never in base harness runs.

### C.5.2 Programs and instances

> **C passage condensed for the public copy.** The original record has here a block of 26 lines of C declarations: types `PdosTl`; functions `pdos_tl_start`, `pdos_tl_run`, `pdos_tl_key`, `pdos_tl_abandon`, `pdos_tl_finish`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* **One program per sequence**, hand-transcribed from the listing at the level of its waits. Each label of
  `pc` names the DOS address it resumes at (for example `PC_O2_04C1` after loop A's wait). Within a run
  between two waits the program performs the DOS steps in listing order and emits them (C.5.4).
* **`pdos_tl_run`**: while the current wait ends at an instant ≤ `t_us` (frames by M8, ticks by M7, a
  key test by `key_us`), advance `frame` to that instant and resume the program. The wait's end is
  computed in closed form; no per-frame loop is needed. Cost is linear in the DOS steps passed, not in
  frames.
* **Keys.** `pdos_tl_key` records the earliest pending key. The program consumes it where the listing
  reads the key (O2:09EC, R:0403:4545, the title box) and ignores it where the listing only tests
  `kbhit` (the key stays pending, as DOS `kbhit` does not consume).
* **Abandon** (the core moved on): the timeline stops at the last DOS step with instant ≤ `t_us`.
  Running cycling slots are stopped at that frame (M6: the DAC stays). Area B keeps the shadows, so the
  next DOS scene starts from the screen as it was.
* **Finish** (Choice): a sequence may name a non-interactive tail that completes at once when it is
  abandoned during it. Only the intro's dissolve has one (C.6.6): at the abandon instant C calls B's
  `pdos_dissolve_frame` until it returns 1 (at most 146 calls; the result equals a copy of the source page),
  so the next scene starts from the logo on black. Alternative: freeze mid-dissolve
  (rejected: a half-dissolved screen under the first Birth fade).

### C.5.3 Event-time ordering and tick independence

* `pdos_seq` calls `pdos_tl_run(tl, e->t_us)` for every live timeline **before** it applies an event or
  probe. The presentation tick calls `pdos_tl_run(tl, now)`. The filter calls it with the sync's
  virtual time before deciding (C.12.1).
* Hence the DOS steps, their frames and the timeline state at any virtual time t depend only on the
  inputs of C.5.1 with times ≤ t, never on how ticks partition time. A Win32 run with ticks at the
  monitor's refresh and a headless run with ticks every 16,667 µs produce the same DOS steps for the
  same inputs.
* A DOS step and an event at the same microsecond: the step comes first (frame instants are "≤").
* **Property test** (C.15.1): random tick partitions give identical step lists and states.

### C.5.4 Drawing: the DOS program on area B's machine

The transcribed programs are the DOS code; area B's `pdos_mach`, `pdos_draw`, `pdos_glyph`, `pdos_ui`
and `pdos_pal` are the driver and the screen (B 3..5, B 20 "Area C"). At each step's instant the
program calls B's primitives on the N machine `pdos_mn`, as the DOS code calls the driver:

| DOS step (C.6, C.8) | B primitive |
|---|---|
| pan column, logo strip, page copies (G#20) | `pdos_copy_rect` (B 4.2) |
| page show (G#31) | `pdos_show_page` |
| logo sprite (G#32) | `pdos_sprite` |
| page clear (R:0000:0BFA) | `pdos_fill_rect` |
| credit and Birth text (R:0182:*, G#21) | `pdos_glyph` text helpers (B 4.3, 10.2) |
| dissolve (G#10) | `pdos_dissolve_start`, then `pdos_dissolve_frame` once per DOS frame (B 4.2) |
| fade (R:0000:04AA/04D4) | `pdos_fade_step(out, start, target, w)` with C's weight `w` = t_j (M5; B 5.3) |
| cycling (R:0000:0382/03FA/042B/044A) | `pdos_cycle_setup(c, d, lo, hi)`, then `pdos_cycle_step(c, d, dir)` at each step frame, or `pdos_cycle_advance(c, d, dir, n)` for n steps at once (M6; B 5.3) |
| picture and palette loads | B's loaders through E (B 5.2) |
| menu box (R:1D05:0031) drawn by a program (title box in T4, C.7) | `pdos_menubox_*` (B 4.4; RV2-13) |

* **Per-frame work.** For every DOS frame passed, in frame order, `pdos_tl_run` applies the frame routine's
  effects (fade step, then cycling steps; TIMING 2.5 steps 2, 3), then the program's steps scheduled at that
  instant. Shortcuts that give the same state are used when no program step intervenes: only the last fade
  weight of a run of frames matters (each fade frame writes the whole palette from the same start and
  target, M5), and n cycling steps of a slot are applied as n mod count steps (`pdos_cycle_advance`, B 5.3).
* **Step log.** Every program step also writes a `PdosLogStep` record (op name, sequence, frame, instant,
  DOS address) to `timeline.log` in the headless harness (C.15.3; A-4); the log is not an input of B.
* `pdos_tl_frame_at(tl, t_us)` gives the frame a tick renders.
* **Pointer mode** (RV1-7, P21): C.11.5 adds a scene rule to B's cursor table (B 6.7).

### C.5.5 Data sources

* **Code immediates** are C constants with their DOS address in a comment (E.18-5, the user's D6): the
  column rates 21/4 and +6720 (O2:0476, O2:07D0), cue columns and lines (TIMING 5.3 table, O2:0522..05F3,
  O2:089F..0989), the logo tick 0D87h (O2:0A1E), 80 strips of 4 (O2:0AEB, 0AEF), 100 × `wait(5)`
  (O2:0B0C, 0AFD), `G#10(1, 20)` (O2:0B83..0B8B), cycling set-ups (O2:02F4, O2:0A90..0AAC), Birth's waits
  5/10/180 (O7:18D2..1BB8), fade steps 8 (O7:1A39, 1A93) and 5 (R:01A8:05B6, 0840), 45 ticks per `w`,
  the 19-character test (O7:1B35), the 40-line test (O7:18D2), the blink period 60 (O7:1820..1847), the
  menu confirmation `wait(20)` (R:1D05:0441).
* **Data-segment tables** through E's registry (E.10): `PDOS_T_BIRTH_SCHEDULE` (R:2710:0083, 45 words,
  last FFFFh) and `PDOS_T_BIRTH_CYCLE` (R:2710:0000, eight zero-terminated groups); `PDOS_T_TITLE_MENU`
  (DGROUP:1AE2) for the hotkeys of the title box (C.7.3).
* **Line files** through `pdos_text_line(PDOS_F_CREDITS_TXT, i, &len)` and
  `pdos_text_line(PDOS_F_STORY_TXT, i, &len)` (E.8.1: E's generated file ids, one per pinned file with
  its extension, and the three-argument form; RV2-9). The line is `len` bytes; NULL past the end
  (`pdos_text_count` gives the record count: 24 and 52). Past the end: CREDITS keeps the previous line
  (FORMATS 3.6); STORY ends the story ("End", C.8.3).

### C.5.6 Switching and the hidden profile (T2, O6)

* The DOS profile receives every event and probe and advances at every tick whether visible or not
  (A 8.2). Its timelines therefore stay current, and a switch shows the DOS view at the same virtual
  time (T2), even with one profile at its title menu and the other in its intro.
* View actions exist only while the DOS profile is visible (they come from DOS-form input). That is an
  input of the DOS view, not a property of the switch: in base runs (7.4) there are none.

### C.5.7 Costs, limits, errors

* **Time per tick:** frame arithmetic (two 64-bit divisions) plus the DOS steps passed. The intro emits
  about one column per 6 frames; a catch-up after a pause emits at most one step per column and strip
  (≤ 724 for the whole intro); each is one B primitive (a 4×80 strip or a page copy). Per-frame effects
  use the shortcuts of C.5.4, so a long pause costs at most one fade write, ≤ 16 cycling steps per slot and
  146 dissolve frames.
* **Memory:** static; `PdosTl` under 2 KB; at most four live timelines (intro, Birth, one TX effect, the
  text-cursor blink).
* **Errors** never fault: an out-of-range table read gives E's defined value and a presentation
  diagnostic (E.10.2); an unexpected core order abandons the DOS sequence and lets the core-driven scene
  draw (C.11.6), with diagnostic `PDOS_DIAG_SEQ`. Virtual time never decreases; an older time is ignored.

## C.6 Intro, credits and logo (DOS-PROFILE row 1)

### C.6.1 Start (T1)

* t0 = the virtual time of the probe **CreateSequencePlayer 10B0:008A entry with ra 11E0:00A5** (the call
  at 11E0:00A0 in RunIntroAndTitleMenu 11E0:0000): the creation of the intro movie.
* The DOS steps before O2:0334 (slot 1 set up and started at O2:02F4/030B, the `credits.txt` open) are
  untimed and placed at t0 (M2). So slot 1 (DAC 146..152, `rate` 14, +1) starts at frame 0, and the tune
  (`S#1(3)`, O2:0339) starts at frame 0.

### C.6.2 Program

Transcription of O2:0334..0BD6 (TIMING 5.3, SCENES 4, 5; DOS listing):

1. **Loop A**, x = 0..319: cue test and credit (C.5.5), `PAN_COLUMN(A, x)`, wait for tick ≥ ⌊21x/4⌋ (no key
   test inside, O2:04A0..04BF), then the key test O2:04C1 (a pending key ends the loop).
2. **Loop B**, x = 0..319: cue, `PAN_COLUMN(B, x)`, wait for tick ≥ ⌊(21x + 6720)/4⌋ with `kbhit` on every
   poll (O2:07FD..0828), key test O2:082A.
3. **O2:09D7** shortcut test: if a key is pending, read it: N, L, E, C (either case) preselect title item 0,
   1, 2, 3 (DGROUP:6B32); another key leaves −1; jump to step 8 (O2:0A16 → O2:0B26).
4. **Logo wait** O2:0A19: until tick ≥ 3,463, no key test.
5. **Logo set-up** O2:0A53..0AB1 (slot 4: DAC 224..239, `rate` 14, started).
6. **Reveal**: 80 × (`LOGO_STRIP(i)`, `wait(1)`), no key test.
7. **Hold**: up to 100 × (test `kbhit`, `wait(5)`) (O2:0AF6..0B19); then the key flush R:0403:4545 (the key
   is read and discarded) and DGROUP:6B32 = −1.
8. **Cycles off** O2:0B26..0B48: slots 1..4 stopped (with and without a key).
9. **Dissolve** O2:0B52..0B90: page 1 cleared, logo drawn, `G#10(1, 20)` (146 frames, M10).
10. **Show** O2:0B93..0BCF. Then the title (C.7): the box, or, after a shortcut, no box.

Correction to TIMING 5.3's totals paragraph (applied at the merge, C.20-6): with a key the jump at
O2:0A16 lands on O2:0B26, so "Cycles
off" still runs; only the key flush and the reset of DGROUP:6B32 are skipped (DOS listing O2:0A0F..0B26;
SCENES 5 "End (with or without a key)" agrees).

### C.6.3 Reference frames without a key (7.7 goldens of durations)

Frames from t0 on the model (scratch `intro_model.py`); equal to TIMING 5.3's "a" values.

| Event | Tick | Frame | s |
|---|---|---|---|
| Line 1 (A, 10) | 47 | 54 | 0.770 |
| Cleared (A, 50) | 257 | 299 | 4.266 |
| Line 2 / 3 (A, 70 / 120) | 362 / 624 | 422 / 727 | 6.021 / 10.373 |
| Cleared (A, 160) | 834 | 972 | 13.868 |
| Lines 4..11 (A, 170..310 by 20) | 887 .. 1,622 | 1,034, 1,157, 1,279, 1,402, 1,524, 1,647, 1,769, 1,892 | 14.753 .. 26.995 |
| Loop A ends | 1,674 | 1,952 | 27.851 |
| Lines 12, 13 (B, 10, 30) | 1,727, 1,832 | 2,014, 2,137 | 28.735, 30.490 |
| Cleared (B, 50); lines 14, 15 (B, 64, 84) | 1,937; 2,010, 2,115 | 2,259; 2,344, 2,467 | 32.231; 33.444, 35.198 |
| Cleared (B, 116) | 2,283 | 2,663 | 37.995 |
| Lines 16..24 (B, 130..290 by 20) | 2,357 .. 3,197 | 2,749, 2,872, 2,994, 3,117, 3,239, 3,362, 3,484, 3,607, 3,729 | 39.222 .. 53.204 |
| Cleared (B, 310) | 3,302 | 3,852 | 54.959 |
| Loop B ends | 3,354 | 3,912 | 55.815 |
| Logo wait ends; strip 0 | 3,463 | 4,040 | 57.642 |
| Strip 79; reveal ends | – | 4,119; 4,120 | 58.783 |
| Hold ends; cycles off | – | 4,620 | 65.918 |
| Dissolve ends; title box | – | 4,766 | 68.000 |

* The column shown at tick S in loop A is min(319, 1 + ⌊(4S + 3)/21⌋) (column x appears at tick
  ⌊21(x − 1)/4⌋; checked by brute force in scratch).
* Slot 1 has made ⌊4,620/14⌋ = 330 steps when stopped; slot 4 ⌊(4,620 − 4,040)/14⌋ = 41 (P10).

### C.6.4 Skips (T5)

**Sources of the DOS key** (`pdos_tl_key`), the earliest wins:

1. **The core's intro skip**: probe SetGameCursor 1098:096C entry with ra **11E0:08D7** (the call at
   11E0:08D2 after PumpMessagesCheckSkipInput 11E0:095F returned TRUE; `g_movieSkipRequested` is set at
   11E0:08C8 just before). This covers skips made in the Windows profile, base harness input and keys the
   DOS filter passed. Code `PDOS_KEY_ANY`.
2. **A view action** from the DOS filter (C.12.6): a key press (any key reaching the filter, C.12.3), or a
   left press (P25, C.12.6). Code `PDOS_KEY_ANY`, or the shortcut letter for N, L, E, C.

The core's seek to 1164 (SeekSequence at 11E0:090D, ra 11E0:0912) is not a source: it happens only for
movie frames 141..1163 (11E0:08E8..08FF), while the flag is set at any frame.

**DOS reaction by phase** (DOS listing; frames on the model):

| Phase at the key | Reaction |
|---|---|
| Loop A | the loop ends at the first key test at or after the key (after the current column's wait); loop B draws its column 0 at that instant and ends at once (its wait polls `kbhit`); step 3 reads the key; cycles off; dissolve (146 frames); show |
| Loop B | the loop ends at once (the column being waited for is already drawn); step 3 as above |
| Logo wait, reveal | no effect until the hold's first test (frame 4,120): the hold ends there; flush; cycles off; dissolve |
| Hold | ends at the next 5-frame boundary (4,120 + 5i ≥ key); flush; cycles off; dissolve |
| Dissolve | none; the key would be flushed by the title box (R:01A8:0486 → R:0238:0008 → R:1D05:0018, which calls R:1D05:0031 with the flush flag 1; SCENES 10.1) |

* A shortcut (N, L, E, C) counts only when the key is read at O2:09D7, that is when it arrived by the end
  of loop B (frame 3,912). DOS-PROFILE 1.7's "N, L, E, C after or during the pan" is corrected to "during
  the pan" at the merge (C.20-4).
* Worst-case DOS reaction from a key in the pan to the title box: 6 frames (one column) + 146 = 152 frames
  (2.17 s). The core: at most 20 movie frames to its poll, then a seek at movie frame 141 at the
  earliest and 96 frames to the title at 1260: at most 237 movie frames (3.95 s at 60 per second) when
  the key comes in the first 2.3 s, otherwise at most 116 (1.93 s). Both orders occur; C.7.1 covers the
  DOS box arriving first (T4).

### C.6.5 Cycling and the title palette (P10, timing part)

* Slots stop without restore (M6, O2:0B26..0B48). The title therefore shows slot 1 after
  ⌊F_off/14⌋ steps and, when the logo path ran, slot 4 after ⌊(F_off − F_logo)/14⌋ steps, F_off being the
  frame of "cycles off". With a shortcut or a key in the pan slot 4 never starts. Area B renders the
  colours (index 8 with the logo palette; PALETTE Open 10). **Reproduce** (P10).

### C.6.6 When the core leaves first

* The core waits at its title menu from about 21.2 s while the DOS intro runs to 68.0 s (T2): the DOS intro
  continues; nothing is abandoned.
* **The core leaves the title** (MenuZ exit at ra 11E0:0729 with a choice; possible when the choice was
  made in the Windows profile) while the DOS intro still runs: the intro is abandoned with **finish**
  (C.5.2): the dissolve completes at once, and the title box is shown with the chosen row (C.7.2).
  Choice; alternative: freeze the pan (rejected: the DOS program never shows a choice without its box).
* **The core starts Birth** (SeekSequence ra 11E0:01AA) while the DOS dissolve still runs (possible after a
  shortcut, C.13.6 example 1): abandon with finish, then DOS Birth starts at its T1.

## C.7 Title menu and branches (rows 2..8, 16, 20)

### C.7.1 When the DOS box shows (T4)

* The DOS title box appears at the end of step 10 of C.6.2 without a preselection. Its content is fully
  known: the five DOS items (DGROUP:1AE2) and the added Quit row (DOS-PROFILE 3.2; area B draws it).
  T4 therefore shows it even when the core is still in its intro.
* With a preselection (shortcut) the DOS program shows no box (SCENES 6): the view holds the logo on black
  until the core's next scene (T4 hold), while the translation (C.13) drives the core there.

### C.7.2 The highlighted row

| Situation | Row shown | Source |
|---|---|---|
| Core's title MenuZ ready (C.11.2) | the core's selection (OBS_CTL_CHECK on ids 500..520 of the MenuZ dialog) | the core's decision (5.4) |
| Core still in its intro (T4) | the view's own row: 0 at first, moved by Up/Down (view actions) | DOS menu box |
| A mouse drag in the box | the row under the pointer while the left button is down | DOS menu box (SCENES 10.1) |
| After a choice | the chosen row; the box stays (R:1D05:0441 does not erase it) | DOS listing |

### C.7.3 Hotkeys

The DOS title box's hotkeys are the first letters of its items (S, L, E, C, V for DGROUP:1AE2), compared on
their low 5 bits (SCENES 10.1). They are read from the registry string at activation, not typed into C.
The added Quit row has no DOS hotkey; Q is given to it (no DOS item starts with Q). Choice.

### C.7.4 After a choice

* **Omitted DOS waits:** the confirmation `wait(20)`, the phrase-boundary wait R:01A8:04C2..04DA and the tune
  stop: the view keeps the box with the chosen row until the core's next scene begins (the core decides
  when, T3). Their only visible effect in DOS is the box staying up, which the hold reproduces. Choice.
* **0, 2 (New Game, EARTH):** the box stays until DOS Birth's first fade (SCENES 7.1); DOS Birth starts at the
  core's T1 (C.8.1). The core's outro (SeekSequence ra 11E0:0889, frames 100000..100040) shows nothing
  new in the DOS view.
* **3 (Customize):** at the core's dialog 143 (GR_DialogOpen exit, ra 1108:0290) a TX fade to black of 5
  steps (R:01A8:05B6; 30 frames, +1 for the session's first fade) starts; then area B shows `CUSTOM.PIC`
  and the first question (C.12.7 I-custom). On OK the core plays its outro and Birth follows.
* **1 (Load):** the core's file chooser is class W (DOS-PROFILE row 4; W over N, 4.1).
* **4 (Hall of Fame):** an N scene drawn from the core's events (TS).
* **5 (Quit):** nothing (ShutdownGame at 11E0:07CC).
* **Back to the menu** (Load cancelled, Hall of Fame closed, Customize cancelled): the core opens dialog 139
  again; the DOS view draws the box again over the current DOS screen, as R:01A8:0807 does for a failed
  load and the Hall of Fame. Applied also to Customize's cancel (no DOS counterpart). Choice; alternative:
  restore the logo screen first.

## C.8 Birth (row 9)

### C.8.1 Start (T1) and core inputs

| Core probe | Meaning for DOS Birth |
|---|---|
| SeekSequence 10B0:005B entry, ra **11E0:01AA**, frame argument 1000 | t0 of the Birth grid (T1); state 0 |
| BeginWorldCreation 1108:01BC entry (ra 11E0:01B2 at exit) | world generation running |
| BeginWorldCreation exit | world done: DGROUP:67FC = 1 in the model (O7:059A) |
| SetGameCursor 1098:096C entry, ra **11E0:094E**, argument 132 | the core's Birth skip: a DOS key becomes pending |
| DestroySequencePlayer 10B0:0287 entry, ra **11E0:01E8** | the core's Birth ends: abandon (C.8.7) |
| RunNewGameSetup 10E8:0000 entry, ra 11E0:020A | setup begins (C.11) |

* The DOS world generation is replaced by the core's: the DOS program's own world-generation time is not
  modelled; only the flag DGROUP:67FC follows the core (5.4 "the core's decisions"). The Birth story runs
  continuously (M12).
* **EARTH**: the same (DOS sets 67FC before Birth for EARTH, DOS-PROFILE row 5; in the port the core's
  EARTH load is short, and the flag follows the core).

### C.8.2 Schedule

* "now" = the sound tick since tune 4's start, or 0 before the first text line (TIMING 5.5).
* An event runs when now ≥ due. After it, due = clamp(T[m], now + 45·w, 32,767) with m the lines shown
  so far, T = `PDOS_T_BIRTH_SCHEDULE`, w = 2 for a text line, 3 for one longer than 19 characters, 0 for a
  picture line (R:1DC4:007C clamp, signed).
* The first text line (O7:19AB) restarts the tune: `S#1(1)`, `S#1(4)`, frame counter cleared. The tick
  origin and the 6-of-7 divider restart at that instant (M7, P29).

### C.8.3 One event (TIMING 5.5 table; D4 transcribes O7:17CF..1BB8 exactly)

| Step | Frames | Ops |
|---|---|---|
| Dim the previous line (while lines < 40 and state ≠ 2) | 5 | `BIRTH_TEXT(prev, 3)` |
| Read the line (`pdos_text_line(PDOS_F_STORY_TXT, i, &len)`, E.8.1; RV2-9); end of file (NULL) → End | 0 | – |
| Skip test O7:1912: a pending key and 67FC = 1 → End without its `wait(180)` | 0 | – |
| Clear the strip (after the first picture) | 0 | `BIRTH_STRIP_RESTORE` |
| Pause | 10 | – |
| Text in | 5 | `BIRTH_TEXT(line, 3)`, then `BIRTH_TEXT(line, 11)` |
| Text line: lines + 1, w | 0 | (tune start on the first) |
| Picture line (1..3 characters): cycles off; load `BIRTHn.PIC`; fade out 8 steps; show; fade in to `BIRTHn.PAL` 8 steps; cycles on from group n of `PDOS_T_BIRTH_CYCLE` (slot i, `rate` = byte(⌊300/speed⌋), +i) | 48 + 48 (+1 for the session's first fade) | `BIRTH_PICTURE(n)`, `PAGE_SHOW(2)`, fade and slot state |
| End (end of file): `wait(180)`, tune 1, slots stopped, state 2 | 180 | – |

A text event takes 20 frames (15 without the dim step), a picture event 116 (+1). The marker line is drawn
(SCENES 8.3).

### C.8.4 Skip (T5)

* DOS keys come from the core's Birth skip probe (ra 11E0:094E) and from DOS-form view actions (C.12.6).
* The DOS model ends the story at the first due event after the world is done (O7:1912). The core leaves
  Birth as soon as the world is done and its flag is set (11E0:01BD..01DB), which is earlier; its
  DestroySequencePlayer then abandons DOS Birth (C.8.7). So the visible reaction is the core's (the user's
  direction AU9), and both profiles leave Birth at the same virtual time.

### C.8.5 Pauses (T6) and world generation at full speed

* World generation is CPU-bound. The core's Birth movie advances only through UpdateActiveAnimation
  1098:0157 → StepActiveSequence 10B0:0000 from the generator's loops, and the presentation ticks happen
  at the pumps and clock queries those make (A 7.1). DOS Birth frames therefore appear only at those
  ticks (prompt 8).
* Virtual time advances by poll costs (DESIGN 6: 50 µs per GetTickCount, 1,000 µs per empty
  PeekMessage), about 1.7 s during a generation that takes about 0.5 s of real time (user direction
  2026-10-09 06:50). Both profiles' Birth therefore run fast during generation, identically. FIDELITY
  entry: "During world generation both Birth sequences advance by virtual time, faster than real time."

### C.8.6 "BUILDING NEW WORLD..."

* Shown only when the DOS story has ended (state ≥ 2) while the core's world generation is still running
  (between BeginWorldCreation entry and exit). Then the three calls O7:17F4 advance the state to 5 at once
  (M12), `BIRTH_BUILDING(-1)` clears (40, 160, 240, 8), and the message blinks with phase
  ⌊f/60⌋ mod 2, f = frames since the end of the last `wait` (the `wait(180)` of End). Area B maps the phase
  to colours 15 and 3 per O7:1820..1847.
* With the core's world generation at full speed this practically never shows; it is kept because it is the
  DOS behaviour.

### C.8.7 The end of DOS Birth and the T4 next screen

* **The core leaves Birth first** (its skip, or its movie end at frame 11500 if the DOS story is longer):
  DOS Birth is abandoned at the core's DestroySequencePlayer; the DOS post-Birth fade (C.8.8) starts.
* **The DOS story ends first** (the normal case: DOS about 148 s, the core 175 s) and the world is done:
  the DOS program's next screens are fully known, so the view continues (T4): the 5-step fade to black
  (R:01A8:0840, 30 frames), then the first setup page (`SETUP_PAGE(0, row 0)`: `DIFFS.PIC`, the DOS
  header and five levels of DGROUP:3526, the Go Back row disabled as the core's step 0 has it, SCENES 9.1).
  It holds there. A choice made on that page is translated into the Birth skip followed by the choice
  (C.13.6 example 4). When the core arrives at setup the page is already up and the core's MenuZ state
  takes over.
* **Choice.** Alternative: hold the last Birth frame until the core leaves (rejected: a still frame for
  about 27 s where the DOS program shows the setup page). DOS-PROFILE row 9 and 3.1 named "BUILDING NEW
  WORLD..." as the T4 hold, which would be false with the world done. Accepted and corrected at the merge;
  listed for the user's check (C.20-3). B's setup renderer draws the page (B 11.5, C.21 B-6).

### C.8.8 Post-Birth transition

* At the core's DestroySequencePlayer (ra 11E0:01E8) after an abandoned DOS Birth: a TX fade to black of 5
  steps (R:01A8:0840; 30 frames), then the setup page driven by the core (C.11). If the T4 page of C.8.7 is
  already shown, nothing happens.
* Input during this fade: consumed (C.12.7; the DOS menu box would flush it).

## C.9 Timing in the other N and R scenes (D5..D7)

* **TS** (static): no timing of its own; the scene redraws from the core's drawing events.
* **TC** (the core's timing, T3, T7): game-logic animations keep the core's pace in both profiles (unit
  moves, combat, the map's palette cycling, city animations). P6: the DOS move animation (17 one-pixel
  frames) and blink (10 off, 10 on) are not used; the core's 9 frames and its blink phase drive the view
  (draft D 14.6).
* **TX** (DOS-only effects inside a scene, T7 last sentence): a TX effect starts at the core event that
  opens the scene (the scene's probe time), on its own grid (M1), with the durations of C.4.3. When the
  core leaves the scene first, the effect is abandoned (C.5.2). Instances:

| Effect | Where | Duration | Start event |
|---|---|---|---|
| Fade to black, 5 steps | Customize (R:01A8:05B6), after Birth (R:01A8:0840), other scenes TIMING 5.8 | 30 frames (+1 first) | the scene's dialog open or probe |
| Fade in, n steps | discovery (R:0ADE:1584), others per TIMING 5.8 | 6n (+1 first) | the scene's probe |
| `G#10` dissolve | palace (O17), conqueror (O9) | M10 with the scene's `c` | the scene's probe |
| Cycling | Birth (C.8), the space sequence, others (TIMING 5.6) | M6 | the scene's probe |
| Text-entry cursor | name and city entries (SCENES 10.4) | 10 on, 10 off | phase restarts at each OBS_EDIT event of the EDIT control (key, caret move, focus) |
| Menu confirmation | every DOS menu box (R:1D05:0441) | none modelled | the box keeps the chosen row until the core closes its dialog (T3) |

* Input during a TX transition before the scene's DOS screen is complete is consumed when the DOS program
  would have flushed it (its next box flushes keys, SCENES 10.1; R:1459:0918 flushes first), otherwise
  passed. Choice (C.12.2 lists the cases).

**As built in D7a (2026-10-17; [D7a record](../ext-D7a-record.md) "The return to the map"; DESIGN.md 12.7 "As
implemented (D7a; areas B and C)"; decision 3, ruling 3).** The return to the map after an N scene: the scene's
renderer names an exit kind (none, R:0238:1B44 from black, R:0238:1BEB from the scene's DAC); at
RestoreMapAfterDialog's entry 1B44 and 1BEB start a fade-in of 5 steps = 30 frames (R:0000:04AA, M5) on the A
canvas's play-palette layers, the map's cycling slots held while it runs; the fade-out of 1B44 is not shown (the
core has left the scene first). Abandonment as C.5.2: an N scene wanted again before the fade's end, or a new
trigger, completes it at once to its target (FIDELITY F204). The O14 reports name none (O14:013B); Intelligence
after a dossier names 1B44 (D7b).

## C.10 Generators (P3, timing part) and the core's decisions

### C.10.1 The DOS generator is area B's

* Area B owns the generator module, its seeding and P20 (B 9.3): `PdosRand`, `pdos_srand`,
  `pdos_rand`, `pdos_random`, with per-effect seeds FNV-1a-32 of the effect name and the instance
  ordinal (Choice B11; never `g_randSeed`, never time). P20 is settled by B as "follow the core's
  placements". Area C defines no generator and no seed.
* Confirmation from the listing (checked here, agreeing with B's cited addresses): multiplier 343FDh
  (R:2045:2AEA..2AF0), increment 269EC3h (R:2045:2AFF..2B02), result the high word & 7FFFh
  (R:2045:2B0C..2B0E); `srand` stores the seed in the low word and clears the high word
  (R:2045:2ADE..2AE1); `random(n)` multiplies as 32-bit signed and shifts right by 15
  (R:1DC4:0063..0075). CORRESPONDENCE finding 7 agrees. The DOS `srand` takes a 16-bit seed and clears
  the high word; B's `pdos_srand(PdosRand *, uint16_t)` (B 9.3, Revision 2) takes the same 16 bits, so a
  test that replays a DOS sequence from a DOS seed passes it unchanged (RV2-13; this draft's Revision 1
  cited a `uint32_t` form).
* Nothing in area C reads or writes `g_randSeed` (1420:4EE0) or calls a core generator (O4; obs_lint,
  C.15.5).

### C.10.2 Uses: who decides, and what area C times

| Use | DOS source | Decision owner | Area C's part |
|---|---|---|---|
| Intro and other `G#10` dissolves | G:0000:06B7, LFSR B400h from 1 | DOS-only, deterministic (B's `pdos_dissolve_*`) | one `pdos_dissolve_frame` per DOS frame of the timeline (M10, C.5.4) |
| Map redraw order | R:1AEA:0008 `random(256)` then p = 5p + 1 | **core** (DrawTilesToPort 1208:1866 mode 1) | none: follow the core (draft D 14.6; DOS-PROFILE 0.6 rule 1) |
| Active-unit blink, leader idle animation, newspaper form/tag/slogan, starfield, city disaster | SCENES-PLAY 6.1, 7.9, 7.7, 7.16, 7.6 | **core** (RandomBelow exits at ra 1138:01BD, 1138:03C7 and the scenes' probes, A 4.3) | none: follow the core |
| Newspaper torn edge, ornamental border tiles | SCENES-PLAY 7.7; R:0866:260E through R:1DC4:005D | DOS-only: B's generator, seed B11 | none (drawn when the scene's DOS screen is drawn) |
| City view layout (P20) | O19:0000 `srand(name sum)` | settled by B: the core's placements | none |

* A use added in D6/D7 gets a row in B 9.3 and in DOS-PROFILE 0.6 rule 2; area C adds a timing row only
  when the effect is stepped over frames.
* **"RNG-driven presentation in the core"** (prompt 8): dissolve redraws, leader portraits and the starfield
  are the core's choices; the DOS view never redraws them with its own numbers. The only reads of the
  core's random results are A's RandomBelow exit probes (AX), never the seed. Area C's timelines draw no
  random number at all: the intro and Birth programs are fixed sequences (C.6, C.8).

## C.11 Scene sequencing (`pdos_seq`)

### C.11.1 Core state

> **C passage condensed for the public copy.** The original record has here a block of 22 lines of C declarations: types `PdosCoreScene`, `PdosCore`; functions `pdos_seq_core`, `pdos_seq_on_probe`, `pdos_seq_on_event`, `pdos_seq_advance`, `pdos_seq_reset`, `pdos_seq_pointer_hidden`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

### C.11.2 Probes and events used (all read-only; A 4.3, WI 10)

| Probe or event | ra filter | Use | In A 4.3 / WI 10 |
|---|---|---|---|
| RunIntroAndTitleMenu 11E0:0000 entry | – | BOOT → (await intro) | yes |
| GR_DialogOpen 1098:124F exit, dialog 148 | ra 11E0:0044 | `movie_wnd` | A 4.3 (C.20-9) |
| CreateSequencePlayer 10B0:008A entry | ra 11E0:00A5 | INTRO; intro t0 (C.6.1) | yes (call site 11E0:00A0) |
| SetGameCursor 1098:096C entry | ra 11E0:08D7 | the core's intro skip (C.6.4) | A 4.3 (C.20-9) |
| GR_DialogOpen exit, dialog 139 | ra 11E0:06C5 | TITLE | yes |
| MenuZ 1220:0156 entry, exit (AX = choice) | ra 11E0:0729, 10E8:0528, other | `mz_active`, `mz_kind`, `title_choice` | A 4.3 (C.20-9) |
| IsKeyPending 11E8:02FB entry | ra **1220:0AA5** | `mz_ready`: MenuZ's busy loop polls keys, after its FlushInputEvents call at 1220:0248 | A 4.3 (new key; C.20-9) |
| OBS_WND_CREATE / OBS_CTL_CHECK / OBS_WND_ENABLE / OBS_WND_DESTROY on children of the MenuZ dialog | – | items, selection, Go Back enabled | A 3 events |
| LoadGameFromFileDialog 1130:000E entry, exit | ra 11E0:0807 | LOAD | yes |
| CustomizeWorldDialog 1108:0243 entry, exit; GR_DialogOpen exit dialog 143 | ra 11E0:0826; 1108:0290 | CUSTOM; the fade start | key: WI 10.7; caller row ra 11E0:0826: A 4.3 (RV2-2; WI 10.7 filters only the GR_DialogOpen call inside, 1108:028B → 1108:0290) |
| ShowHallOfFame 1080:0119 entry, exit | ra 11E0:0847 | HOF | yes |
| SeekSequence 10B0:005B entry | ra 11E0:0889 (100000) | OUTRO | yes (call site 11E0:0884) |
| DestroySequencePlayer 10B0:0287 entry | ra 11E0:0114; 11E0:01E8 | intro movie gone; Birth ends | A 4.3 (C.20-9) |
| SeekSequence entry | ra 11E0:01AA (1000) | BIRTH; Birth t0 | yes |
| BeginWorldCreation 1108:01BC entry, exit | – | `world_running`, `world_done` | yes |
| SetGameCursor entry | ra 11E0:094E | the core's Birth skip | yes (call site 11E0:0949) |
| RunNewGameSetup 10E8:0000 entry, exit | ra 11E0:020A | SETUP; then PLAY | key: WI 10.7; caller row ra 11E0:020A: A 4.3 (RV2-2; WI 10.7 filters only the GR_DialogOpen calls inside) |
| GR_DialogOpen exit, dialogs 144, 151 | ra 10E8:0067, 10E8:10BE | setup pages | yes |
| RunTextInputDialog 1220:16FD entry, exit | ra 10E8:056F | name pages | yes |
| GR_DialogClose 1098:1612 entry | ra 11E0:0217 | the Load path ends in PLAY | A 4.3 (C.20-9) |
| DrawUnitStackList 11C0:3407 entry (`push cs` + near call: far return, full `ra` compare) | ra 11C0:334F | P26 predicate (C.13.3) | A 4.3 (new key; C.20-9) |
| OBS_FOCUS, OBS_EDIT on the EDIT control 450 | – | name pages ready; cursor blink | A 3 events |
| OBS_CURSOR | – | pointer mode (C.11.5) | A 3 |

* Handlers receive A's `ObsProbe` (A 4.2): `id`, `phase`, `far_ret`, `addr`, `ra`, `site`, `t_us`,
  `arg_base`. A call-site filter is a test of `site` (the matching `OBS_CALLSITES` row, -1 for none); C
  never compares `ra` itself. `pdos_seq_reset` resolves every (callee, ra) pair of this table once with
  A's `obs_callsite` (A 4.2; RV2-4) and keeps the row indices; an unresolved pair is a configuration error
  (a Checked fault and A's obs_lint check), so a missing row such as RV2-2's fails loudly instead of never
  matching. Arguments are read with `w16q_arg16(p, i)`, exit values with `w16q_ret_ax()`.
  The record is valid during the callback only, so `pdos_seq` copies what it keeps.

### C.11.3 Transitions and their DOS effect

| Core transition (probe) | DOS view |
|---|---|
| → INTRO (CreateSequencePlayer ra 11E0:00A5) | start the intro timeline at t0 |
| core intro skip (SetGameCursor ra 11E0:08D7) | `pdos_tl_key(intro, t, ANY)` |
| → TITLE, MenuZ ready | the box highlight follows the core (C.7.2); pending translations may release |
| title choice c (MenuZ exit ra 11E0:0729) | intro still running: abandon with finish; box with row c (C.6.6, C.7.4) |
| → CUSTOM / LOAD / HOF and back | C.7.4 |
| → OUTRO | nothing new |
| → BIRTH (SeekSequence ra 11E0:01AA) | abandon the intro if live (finish); start Birth at t0 |
| world running / done | C.8.1 |
| core Birth skip (SetGameCursor ra 11E0:094E) | `pdos_tl_key(birth, t, ANY)` |
| Birth ends (DestroySequencePlayer ra 11E0:01E8) | abandon Birth; post-Birth fade unless the T4 page is up (C.8.7, C.8.8) |
| → SETUP (RunNewGameSetup entry) | setup pages from the core (C.11.4) |
| → PLAY (RunNewGameSetup exit, or GR_DialogClose ra 11E0:0217) | play scenes (areas B, D) |

### C.11.4 Setup step identification

* Steps 0..2 are MenuZ calls at ra 10E8:0528; steps 3..4 RunTextInputDialog at ra 10E8:056F.
* At MenuZ's ready probe (the items are created by then): more than five items → step 2 (tribe list, first
  item "Custom."); otherwise the Go Back button (id 102) disabled → step 0 (`g_dialogMenuMode = -1`,
  RunNewGameSetup header), enabled → step 1.
* RunTextInputDialog: the first one after a step-2 MenuZ exit with result 0 ("Custom.") is step 3; any other
  is step 4 (step 3 is entered only for Custom and is skipped going back; RunNewGameSetup header).
* Open C-3: D5 confirms these discriminators against the listing; the alternative is an argument read of
  the setup text pointer.

### C.11.5 Pointer: the scene rule on top of B's table (P21)

Area B's table (B 6.7, `pdos_cursor_current`) maps the Windows cursor id to the DOS pointer: 129, 130,
134 torch; 133 the GO arrow; 131 and 132 hidden (P21 settled by B, Choice B5); 136..143 the Windows
cursor. Area C adds one scene rule, which B's function consults through `pdos_seq_pointer_hidden()`:

| `pdos_seq` state | Pointer |
|---|---|
| a DOS intro or Birth timeline is live (C.6, C.8), whatever the Windows cursor | hidden (the DOS program hides it, SCENES 7.1, 7.3) |
| any other | B's table |

* Why the rule is needed: during Birth the core sets cursor 129 at 11E0:01B5, which B's table alone would
  show as the torch. The DOS program shows no pointer there.
* Choice. Alternative: a per-cursor table only (rejected: the same id 129 means "hidden" during Birth and
  "torch" elsewhere).
* `int pdos_seq_pointer_hidden(void)` is pure: it reads `pdos_seq`'s state, set at host_sync (C.11.3). A
  change of the result bumps B's `gen` so A's cursor route re-issues the image (C.21 B-4).

### C.11.6 Robustness

An event out of the expected order (for example a MenuZ of unknown kind during the intro) abandons the
running DOS sequence and lets the core-driven scene draw; it logs `PDOS_DIAG_SEQ` with the probe's address.
It never asserts and never changes core state.

## C.12 The filter stage in the DOS profile (I2, I3, I6)

### C.12.1 Placement and order

Area A's dispatch (A 10.1, under `CIV_OBSERVER`), with C's entries:

> **C passage condensed for the public copy.** The original record has here a block of 21 lines of C code (statements or function bodies): functions `present_input_filter`, `pdos_adapt_filter`, `present_input_release`, `pdos_adapt_note`, `pdos_adapt_reset`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* **Frames** (A 8.1, 10.1). The arrival stage stamps every event with the frame visible at arrival,
  through the profile callback `input_frame`. Keys, characters, focus loss and capture loss are stamped
  too. The values:
  * 0: the Windows frame; virtual-screen points;
  * 1: the N canvas; N-canvas pixels 0..319 x 0..199;
  * 2: the A canvas; virtual-screen pixels (C4: the A canvas has the screen's size and the Windows
    layout);
  * 3: a map-layer point; virtual-screen pixels;
  * 4: a ring square; `x = col`, `y = row`.

  The filter uses the stamped frame, never the one visible at the sync.
* **`pdos_adapt_filter`** first runs every live timeline to the sync's time (C.5.3), so the decision
  uses the DOS view at that instant. Choice: `HostEvent` carries no arrival time, and the difference is
  at most one poll interval.
* **`pdos_adapt_note`** applies C.12.2's action rule to frames 0, 3 and 4. A key press that is not a
  repeat, a character, or a left or right press (on frame 4, a ring-square press) is a user action. It
  cancels the pending translation (C.13.4) before the event is posted. Releases, repeats and moves are not
  actions. The note also records presses for the pairing rule (C.12.2). It never changes or posts an event
  itself. It returns 1 for a later part of an action C decided on frame 1 or 2 with a decision other than
  "pass", and A's filter then hands that part to `pdos_adapt_filter` (C-11, adopted in A 10.1; RV2-5).
  Otherwise it returns 0 and the event takes its frame's path, so with the Windows profile visible and no
  DOS action open the filter stays the identity (I2; A's test). Cost: one table update per event.
* **Output bound.** One host event gives at most `PDOS_PEND_EVENTS` (8) events: a pass (1), a 1:1
  translation (1), or the first step of a translation released at once (at most 8, C.13.2). That is
  within A's `PI_MAX_OUT` of 16. `pdos_adapt.c` asserts `PDOS_PEND_EVENTS <= PI_MAX_OUT` at compile time.
  If `max` is smaller at run time, the action is consumed with `PDOS_DIAG_PEND`; nothing partial is
  posted.
* **D3.** D3's DOS profile shows the Windows frame and gives `input_frame` 2 (A 8.1). With no adapter
  row for a scene the filter passes, and there are no rows before D4, so D3's input reaches the core
  unchanged.
* Chords never reach the filter; lone modifiers arrive at their release (A 10.2; C.12.3).

### C.12.2 Actions and the pairing rule

* **User actions** (I1, I4): a key press that is not a repeat, a HOST_EV_CHAR, a left or right button press.
  Key releases, repeats, moves, button releases, focus and capture loss are parts of an action, not actions.
* **Pairing.** The decision taken for a press applies to everything that belongs to it:
  * keys: `fd_key[vk]` holds the decision until the key's release; a HOST_EV_KEYDOWN for a vk already down
    is a repeat (HostEvent carries no repeat flag; `post_event` derives it the same way);
  * buttons: `fd_btn[L|R]` holds the decision until the release; moves while held follow it.
* **Outcomes:**

| Decision of the press | Repeats | Release | Moves while held |
|---|---|---|---|
| pass | pass | pass | pass (frame 2) or consumed (frame 1, C.12.5) |
| consume | consume | consume | consume |
| translate 1:1 (one key into another key) | consumed | translated into the release of the produced key | – |
| translate into complete pairs (or an I4 queue) | consumed | consumed | consumed |
| drag (menu box) | – | the translation happens here (C.12.5) | view highlight only |

* Every posted press has a posted release (I7's consistency, C.2 step 6). Focus and capture loss generate
  releases at arrival (A 10.2); they follow the rule.
* A profile switch between a press and its release does not change the decision (the tables are not per
  profile).
* **Across frames** (Revision 2). A press and the rest of its action can arrive with different frames: a
  key held across a profile switch, or a drag from a DOS box (frame 2) that ends over D's map layer
  (frame 3, from M on). The decision belongs to the action, not to the frame.
  * **Press on frame 0, 3 or 4.** `pdos_adapt_note` records it as decided elsewhere
    (`PDOS_FD_ELSEWHERE`), with its frame and, for a button, the virtual-screen point of the press or of
    the last move. A part of that action that reaches `pdos_adapt_filter` on frame 1 or 2 passes:
    * a key part unchanged;
    * a frame-2 button part at its own virtual-screen point;
    * a frame-1 button release at the recorded point; frame-1 moves while held are consumed.

    So the core gets the release of a press it got. A ring press (frame 4) has no recorded point. A's
    press latch (A 10.1, D 12.1; RV2-3) stamps every move while a ring press is held and its release
    with frame 4, wherever they happen, so none reaches C (C.20.2 item 2, confirmed by RV2). As a
    defensive rule, if one did, a frame-2 part would pass at its point and a frame-1 part would be
    consumed, with `PDOS_DIAG_PAIR`.
  * **Press on frame 1 or 2 that C decided.** Its later parts can arrive on frame 0, 3 or 4, and A's
    dispatch passes those unchanged. That is right for a pass decision. For the others it is not: the
    release of a consumed press reaches the core without its press, and the key produced by a 1:1
    translation is never released. **Choice (C-11; adopted by A 10.1 in Revision 3, RV2-5):**
    `pdos_adapt_note` returns 1 for such a part when the press's decision is not "pass", and A then calls
    `pdos_adapt_filter` for it instead of its frame's path. The filter applies the press's decision.
    Frame 0 and 3 coordinates are virtual-screen points; a frame-4 part counts as outside every DOS
    row. A's `present_input_filter` (C.12.1, A 10.1) has the line:

    > **C passage condensed for the public copy.** The original record has here a block of 2 lines of C code (statements or function bodies): functions `pdos_adapt_filter`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

    Revision 2's fallback for an observe-only note (an owed release through `pdos_pend_release`, with
    the original release still passing) is withdrawn: A adopted the routing (C-11).

### C.12.3 Key forms

* DOS-form keys are recognised from `vk` (arrows 25h..28h, Return 0Dh, Space 20h, Escape 1Bh, Ins 2Dh,
  Del 2Eh, Backspace 08h, F1..F10 70h..79h) and letters from `ch` (low byte, case-insensitive like the DOS
  low-5-bit compare). Alt+H and Alt+V: the letter with Alt held, which the arrival stage delivers as Alt's
  press followed by the letter (F101); the filter's own `fd_key[VK_MENU]` tells Alt is down.
* **Produced keys** are complete HostEvents: `vk`, `scan` (extended bit 100h for arrows, so
  `post_event`'s keypad rule never turns them into digits), `ch` = 8000h | character where the key has one.
  A produced letter uses the core item's first character as `ch` and its VK; Return is vk 0Dh, scan 1Ch,
  ch 800Dh.
* **Lone modifiers** (K3: a lone Ctrl or Shift reaches the filter at its release, press then release): a
  key like any other. In DOS sequences that makes them skip keys, as in the Windows profile (the user's
  "any key", AU9); DOS `kbhit` would not see them. FIDELITY entry beside K3's (C.20-7).

### C.12.4 Adapter table format (DOS-PROFILE 1.7, version 2)

Columns of each row:

| Column | Content |
|---|---|
| Row | stable id, for example `I-title/hotkey` |
| Scene condition | DOS view phase and core scene (C.11) for which the row applies |
| DOS-form action | key, letter class, button and DOS region (row of a box, rectangle in DOS pixels) |
| Decision | pass, consume, translate 1:1, translate (pairs), queue (I4 steps) |
| Windows-form events | the produced events, or the I4 steps with their predicates |
| View action | what the DOS timeline is told (C.5.1 input 3), or none |
| I5 class | position irrelevant, ⌈16L/10⌉, ScaleLogical, control rectangle (C.14) |
| Evidence | DOS (SCENES, SCENES-PLAY) and Windows (showfunc) facts |
| Recorded | Windows-only keys and FIDELITY deviations |

`pdos_adapt_tab.c` holds the rows as data; `gen/dos/adapters.py` checks that DOS-PROFILE.md 1.7 v2 lists the
same rows (run in test.cmd; ADAPT_OK).

### C.12.5 The menu-box model (shared by I-title, I-setup, I-custom, I-menu)

DOS menu box rules (SCENES 10.1, DOS listing) and their Windows form:

| DOS-form action | DOS meaning | Windows form (core's MenuZ ready) |
|---|---|---|
| Up, Down | move the bar (may land on disabled items) | pass; MenuZ moves through ProcessKeyboardMessage 1098:02D1 → TranslateNavKeyToDigit 1208:0000 → '8'/'2' (MenuZSubclassWndProc 1220:1289, wraps, skips disabled) |
| Return | choose | pass (WM_CHAR 0Dh → OK 101) |
| Space | choose | translate 1:1 into Return (MenuZ re-checks the current item on a space) |
| hotkey letter of row k | select and choose | `letter_k` + Return when MenuZ's cyclic search from the current selection lands on k (simulated on the control texts read through `w16q`); otherwise a click on control 500+k, then [selection = k] Return (C.13) |
| left press in a row; moves while held | highlight | view highlight only (consumed) |
| left release in row k (not disabled) | choose | click on control 500+k (control rectangle), then [selection = k] Return |
| left release outside the rows | nothing chosen | consumed |
| right button, Alt+H | help flag | per scene (I-menu: the Help button of dialog 145; title: consumed) |
| Escape | −1 | per scene (C.12.6, C.12.7) |
| Alt+V | toggle sound | per scene (I-menu: command 109; title, setup: consumed) |
| any other key | ignored | consumed |

* Rows map by identity: DOS row k ↔ core item k in the DOS order; added rows (Quit, Go Back, Cancel) map
  to their core controls. Hit geometry is area B's: `pdos_r_hit(frame, x, y, &hit)` (B 11.4) for boxes
  that re-skin a core control tree, giving the row and the child control with its screen rectangle; for a
  box a C program draws before the core has one (the title box in T4, the setup page of C.8.7) B's
  `pdos_menubox_row(b, mx, my, &disabled)` (B 4.4) on that box's model, with frame-1 points. A disabled
  row keeps the previous row, as DOS does (C.21 B-3).
* Letter and Return travel through the same game-key queue in order (IsKeyPending → ProcessKeyboardMessage
  → WM_CHAR), so `letter + Return` is released in one step. A click is a mouse message; IsKeyPending's
  ranged peek would take a following Return first, so a click is followed by Return only after the
  selection is seen (C.13.3).

### C.12.6 D4 rows: I-intro, I-title, I-birth

**I-intro** (the DOS view in its intro, C.6.2 steps 1..9):

| DOS phase | Action | Core in its intro (INTRO, until MenuZ ready) | Core at its title or later |
|---|---|---|---|
| pan (loops A, B) | N, L, E, C | view key (shortcut k); pass the key (the core's skip); queue [MenuZ ready, title] `letter_k` + Return | view key (shortcut k); consume; queue [none] `letter_k` + Return |
| pan, logo, hold | any other key | view key; pass | view key; consume (I6) |
| dissolve | any key | none (DOS would flush it); pass | consume (I6) |
| pan .. dissolve | left press | view key (P25, accepted as C.20-2; not in the dissolve); pass the click at the movie window's client centre (the core's skip) | view key (not in the dissolve); consume press and release |
| any | right press, moves, HOST_EV_CHAR | consume | consume |

* `letter_k` is the core's item k (Start a New Game, Load a Saved Game, Play on EARTH, Customize World:
  S, L, P, C, read from the controls' texts at release, C.12.5).
* After a shortcut the DOS view shows no box (C.7.1).

**I-title** (the DOS box shown, C.7):

| Action | Core MenuZ ready (title) | Core still in its intro (T4) |
|---|---|---|
| Up, Down | pass | view row ±1 (wrap as the DOS box); consume |
| Return; Space | pass; translate into Return | queue: pass the key as the core's skip; [MenuZ ready, title] `letter_k` + Return for the view row k |
| hotkey of row k (S, L, E, C, V; Q for Quit) | select and choose (C.12.5) | queue: skip; [ready] select and choose k |
| left release in row k | click control 500+k; [selection = k] Return | queue: click at the movie window (skip); [ready] click control 500+k; [selection = k] Return |
| Escape, Alt+H, Alt+V, right press | consume (DOS −1 or help; the core's title has none) | consume |
| after a choice (box chosen) | pass everything (the core's outro and Birth start flush input: FlushInputEvents at 11E0:0159) | – |

**I-birth** (DOS Birth live, core in BIRTH):

| Action | Decision | View action |
|---|---|---|
| any key | pass (the core's skip; it waits for the world) | DOS key pending |
| left press | pass (the core's skip test takes WM_LBUTTONDOWN; P25-consistent) | DOS key pending |
| right press, moves, HOST_EV_CHAR | consume | – |
| on the T4 setup page (C.8.7) | I-setup in T4 mode (C.12.7) | – |

### C.12.7 D5 rows: I-setup, I-custom, I-text, I-wait

**I-setup** (dialog 144 pages; the menu-box model for steps 0..2):

| Action | Decision |
|---|---|
| menu-box actions | C.12.5 on the core's MenuZ (kind setup) |
| difficulty page, left release at DOS x < 135 | choose item clamp((y − 12)/35, 0, 4) (SCENES 9.1): select and choose |
| Escape on the difficulty page | choose item 0 (the DOS −1 becomes 0, SCENES 9.1) |
| Escape on the competition page | consume (DOS asks again, SCENES 9.2) |
| Escape on the tribe page | choose "Custom." (core item 0; DOS random slot and tribe name, SCENES 9.3; DOS-PROFILE 3.3) |
| the added Go Back row (P17) | click button 102 (control rectangle); enabled as the core's button |
| name pages | I-text |
| during the post-Birth fade (C.8.8) | consume |
| **T4 mode** (the DOS page shown while the core is still in Birth, C.8.7) | Up/Down: view row; a choice k: queue [pass the key as the Birth skip, or a click at the movie window for a release]; [MenuZ ready, setup step 0] select and choose k |

**I-custom** (dialog 143; four DOS questions over `CUSTOM.PIC`):

* View state q = 0..3, the question shown; it starts at 0 when dialog 143 opens and advances with each DOS
  choice made through the adapter. The highlight of question q is the core's current selection in its
  group q (the core's decision).
* A choice i in question q: click the Region control of group q item i (control rectangle; ids in
  0x323..0x332, D5 maps them, Open C-4); after q = 3, a second step [group 3 selection = i] Return (OK).
* Escape: consume (DOS asks again, SCENES 7.4). The added Cancel row (P17): click the dialog's Cancel.
* Right button or Alt+H on question q: queue [none] the core's help request (cursor 134 mode,
  CustomizeWorldWndProc 1108:0705); [cursor 134 seen] click the Region group q. The exact control is D5's
  (Open C-4).

**I-text** (EDIT controls of dialogs 137, 144 steps 3..4): printable keys, Left, Right, Del, Backspace, Return,
Escape pass; Ins translates into a space then Left; a left press translates into Return (SCENES 10.4).

**I-wait**: any key or left press passes (WaitForKeyOrClick 1038:0C1D, WaitTicksOrInput 11D8:0BD2); clicks at
the I5 point or the window's centre (position irrelevant).

### C.12.8 D6 and D7 rows (outline; each phase completes its rows)

| Adapter | Decision summary | P item |
|---|---|---|
| I-menu | menu-box model on MenuZ, list boxes and buttons; help → the Help button of dialog 145; Alt+V → command 109 through its menu path | – |
| I-stack (dialog 141) | Up/Down: view highlight; Return, Space or a click on row r: queue [none] click on row r (device y = 5 + 33r + 16, UnitStackDialogSubclassProc 11C0:3702), [DrawUnitStackList entered from ra 11C0:334F] Return (OK); Escape: Return | **P26 Choice:** row then OK (one DOS choice closes the popup, SCENES-PLAY 7.19). Alternative: the click only (rejected: the DOS popup closes) |
| I-city | shared keys a, c, b, v, r, i, h, m pass; DOS region clicks → the key of the same function or the core's region point (⌈16L/10⌉); other DOS keys open (OPEN L20) | – |
| I-report | close on any input (pass); Intelligence INFO buttons at ⌈16L/10⌉ | – |
| I-pedia | arrows, `m`, Escape, `x`, rows → list selection and buttons of dialog 130 | – |
| I-palace | keys pass; clicks at the shared label positions, ⌈16L/10⌉ | – |
| I-space | pass; arrival clicks ⌈16L/10⌉ | – |
| I-play | F1..F10 → Ctrl+1..Ctrl+9, Ctrl+0 (complete pairs: Ctrl down, digit, Ctrl up; commands 401..406, 501..504); Alt+V → command 109; all else passes | – |
| I-menubar | pass unchanged: B draws the bar at the Windows title extents (P24 settled by B, B 11.2: clicks unchanged), so a click maps by identity | P24 (B's); input side consistent |
| Find City (dialog 131) | I-menu on the core's sorted list, which B draws as a DOS menu box (P16 settled by B, B 11.2); rows map through `pdos_r_hit` | P16 (B's); input side: the menu-box model. The DOS typed-name box is not offered (whether both pick the same city for a name is unchecked, CORR Open 11) |
| Hall of Fame entry "Clear" | not offered, so no key or click maps to it | P18 (B's: omit); input side consistent. Reopen if L-work finds a core counterpart |
| I-pass, I-none | pass | – |

**As built in D6f (2026-10-17; [D6f record](../ext-D6f-record.md) "I-play, I-menubar, I-menu and I-pass on frame 2";
DESIGN.md 12.9 "As implemented (D6f; areas B and C)").** Frame 2 is decided by rows (18 new with O1's, 116 in all, 25
step sequences; DOS-PROFILE 1.7.2), by the A scene at the sync: the menu loop running (I-menubar), a re-skinned MenuZ
box on top (I-menu at the A hit geometry), a re-skinned message box on top, the menu bar's window active (I-play), else
I-pass. **Choice D6f-1:** I-play only while the menu bar's window is active (the menu paths need its bar). I-play as
the row above, with Alt+V through command 109's menu path, and **extended (OPEN L3)** by the DOS-only keys with a core
counterpart: Alt+G opens the File menu by its mnemonic, Alt+Q reaches command 115 through its menu path; **Choice
D6f-5:** Alt+C and Alt+H pass with their Windows meaning (the City and Help menus). I-menubar as the row above, and a
frame-2 press, its moves and its release inside a DOS drop-down go to the centre of the Windows item of the row under
them. **Choice D6f-4 (differs from the I-menu row's outline):** Alt+V on a MenuZ box is consumed, since MenuZ's loop
takes its dialog's keys only, so no posted path reaches command 109 while it runs. Escape on the tax and luxuries rates
and the revolution, quit and retire questions is the new row I-menu/escape-row (O1: a click on the row selected at the
opening, then Return; FIDELITY F200); on every other box I-menu/return-escape's pass is kept. The message box on A:
keys pass, a release in a button row clicks that button. C.15.4 case 13: a release on another frame than the press's
posts no click. Escape on the core's list, modal and name dialogs in the DOS graphics (Find City's included) is unit
FCE's rule, decided before these rows (DESIGN.md 12.8 "As implemented (FCE; area C)"; FIDELITY F193).

**Changed by D6fS-b (2026-10-17; [D6fS-b record](../ext-D6fS-b-record.md) "The keys", "M2: the mouse"; DESIGN.md
12.9 "As implemented (D6fS-b)"; DOS-PROFILE 1.7.2, ADAPT_OK rows 147 steps 27).** I-menubar no longer passes the
keyboard navigation and no longer maps a click by identity: on the AMENU state its rows dead, edge, updown, hotkey,
choose, escape, key, press and rpress take DOS's box loop (R:1D05:0031..0456): Up and Down move the DOS highlight
without wrap, a hotkey moves it to the next row with that letter below it, Return and Space choose the highlighted row
(the act `PDOS_A_DCHOOSE`: a press and release at its Windows item, an Options row's reopening path after it), Escape
ends the loop (`PDOS_A_DEND`: Alt down and up), every other key and a right press are consumed; a press on the bar goes
to the Windows title of its DOS zone (I-menubar/title, x / 60 with 184..239 WORLD), a press or held move in a drop-down
highlights the row under it and the release chooses at its Windows item (ruling M2). I-play adds Alt+O, Alt+A, Alt+W
and Alt+C to Alt+G (the five DOS menus through the Windows titles' mnemonics); Alt alone, Alt+O without an active
unit and a press on the dead ORDERS zone are consumed with their release (I-play/dead, the action bit `PDOS_AA_DEAD`
0x80000000), every other Alt key is consumed (I-play/altkey); **Choice D6f-5 is reversed** (FIDELITY F253, F255,
F256).

**As built in D7a and D7b (2026-10-17; [D7a record](../ext-D7a-record.md) "The adapter rows I-report", [D7b
record](../ext-D7b-record.md) "Intelligence's wait for INFO, the dossier and the return"; DESIGN.md 12.7 "As
implemented (D7a; areas B and C)" and "(D7b; areas B and C)"; DOS-PROFILE 1.7.2).** I-report while a report of
the DOS report renderer shows (the N frame; scene `PDOS_AS_REPORT`): a lone modifier consumed; any key passed
(the report's wait ends); a left press passed with its release at the I5 point in the report's dialog 148, else
at its centre (class X, position irrelevant, as C.12.7's I-wait); the right button consumed (C.12.7 passes the
left press only, where DOS's any button ends the wait: FIDELITY F207). I-report/info while Intelligence waits
for INFO (scene `PDOS_AS_REPORT_INFO`, from its first PollMouseClick until CloseReportScreen or the dossier's
opener; the DOS pointer shown): a lone modifier consumed; any key passed ('1'..'7' choose a dossier in both);
either button passed at the class-P point of the DOS point in dialog 148 (C.14.2: the client origin +
ceil(16L/10)), consumed without the window or outside it (class P has no fallback); `adapters.py` allows class P
for that scene only. The core's CloseReportScreen after the INFO poll keeps a second wait that DOS's O14:0D43
does not have (FIDELITY F210).

### C.12.9 Windows-only keys (recorded, I3)

* In N scenes: none pass except where the row says so (I-text's edit keys, I-wait's any key). Clicks pass as
  skips in the intro and Birth (P25, I-birth), which the DOS program ignores.
* In A frames (play): every Windows key and accelerator passes (I-play); recorded as "Windows-only, pass".
* **Chord audit (A's Open A3):** no adapter uses a Ctrl+Shift combination or Alt+Enter; F1..F10 produce
  Ctrl+digit pairs after arrival, so they never form a chord. No conflict.
* **As built in D6f (2026-10-17):** in A frames with the menu bar's window active F1..F10 are I-play's, so F10 is not
  the Windows menu key in the DOS graphics (O2; Alt still arms the bar); with the World Map or Status window active,
  or a Windows-layout dialog, every key passes; the DOS right button on the map (OPEN L3) passes as Windows-only. The
  chord audit holds: no D6f act produces a Ctrl+Shift combination or Alt+Enter (FIDELITY F198).
* **Since D6fS-b (2026-10-17):** in A frames with the menu bar's window active Alt alone, Alt+F, Alt+E, Alt+H and the
  other Alt keys without a DOS meaning are consumed, not passed (the Windows menu bar's keyboard mode and the City and
  Help menus are Windows-only: they are reached in the Windows graphics); in a DOS menu box the w16 loop's own keys
  (the bar moves, Home, End, the mnemonics) are consumed. The chord audit holds: the produced paths post Alt down and
  up and the mnemonics, never a Ctrl+Shift combination or Alt+Enter (FIDELITY F253).

## C.13 Pending translations (I4, P22)

### C.13.1 Structures

> **C passage condensed for the public copy.** The original record has here a block of 21 lines of C declarations: types `PdosPred`, `PdosPendStep`, `PdosPend`; functions `pdos_pend_start`, `pdos_pend_release`, `pdos_pend_cancel`; constants `PDOS_PEND_STEPS`, `PDOS_PEND_EVENTS`, `PDOS_PEND_LIMIT_US`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

### C.13.2 Release

* `present_input_release` runs once per input-taking sync, after all of that sync's host events have been
  through the filter and the note (A 10.1). The input-taking syncs are: a ranged PeekMessage at its start,
  an unranged one at its end when nothing was found, GetKeyboardState, GetCursorPos and GetTickCount. So a
  new user action at the same sync cancels before the release is considered (C.13.4), and released events
  are posted after the user's own events of that sync. If a translation is
  active and the current step's predicate holds on `pdos_seq_core()`, the step's events are returned for
  posting and the next step is armed (`armed_us` = now). At most one step is released per sync: the next
  step's predicate normally needs the core to process the events just posted. So one call returns at most
  `PDOS_PEND_EVENTS` events.
* The first step of a translation is released by the filter itself when its predicate is NONE (so the
  user's own key or click is posted at its own sync).
* Release follows F86 (DESIGN 6 item 7): a ranged PeekMessage takes host input at its start. MenuZ's ready
  probe (IsKeyPending entry, ra 1220:0AA5) fires in `fr_enter` before IsKeyPending's ranged PeekMessage,
  whose sync then releases; the released keys are seen by that same PeekMessage.

### C.13.3 Predicates

| Predicate | Holds when | Source |
|---|---|---|
| NONE | always | – |
| MZ_READY(kind, step) | `mz_ready` and `mz_kind` = kind (and `setup_step` = step for setup) | IsKeyPending ra 1220:0AA5 after MenuZ entry at ra 11E0:0729 / 10E8:0528 |
| MZ_SEL(k) | `mz_sel` = k | OBS_CTL_CHECK |
| DLG_OPEN(id) | dialog id open, enabled, not being destroyed | GR_DialogOpen exit, OBS_WND_ENABLE, OBS_WND_DESTROY |
| EDIT_FOCUS | the EDIT control 450 has the focus | OBS_FOCUS |
| CURSOR(id) | the core's cursor is id | OBS_CURSOR |
| STACK_WOKEN(r) | DrawUnitStackList 11C0:3407 entered from ra 11C0:334F with row r | probe (request) |

Predicates read only the scene machine's state; none reads time.

### C.13.4 Cancellation and the limit (P22)

* **Another user action** (C.12.2) cancels the active translation before the new action is decided, on
  any frame: frames 1 and 2 in `pdos_adapt_filter`; frames 0, 3 and 4 in `pdos_adapt_note` (a press on the
  Windows profile after a switch, on D's map layer or on a ring square; A 10.1). Without the note, a DOS
  translation could be released after the user's own Windows input. A new action on frame 1 or 2 may
  start its own translation. Releases, repeats, moves, chords and profile switches do not cancel (a chord
  is a host command, not input; the translation belongs to the action that made it).
* **State lost:** the predicate's scene ended (for example MenuZ exited by another path): cancelled.
* **Timeout:** a step waiting more than `PDOS_PEND_LIMIT_US` of virtual time since `armed_us` is cancelled; it
  never produces input. **Choice: 10,000,000 µs.** The longest expected wait is the intro skip to the title:
  a skip flag set in the first movie frames seeks only at frame 141 and reaches the title at 1260, at most
  237 movie frames (3.95 s; IntroMovieCallback 11E0:08D8..090D), plus the title set-up (LoadGameSpriteSheet,
  dialog 139, MenuZ's flush), which is CPU-bound and costs little virtual time. OPEN.md P22's "20 + 96
  frames" missed the frame-141 rule; P22 is corrected at the merge (C.20-5). Under `--timing host` the
  limit is real time too.
* A user action whose translation would exceed the structure (more than six steps or eight events in one
  step) is consumed with diagnostic `PDOS_DIAG_PEND`; it never posts part of a translation.
* Every start, release and cancellation is logged (headless `adapt.log`, C.15.4).

### C.13.5 I1 conformance

* Every produced event is of a kind a user can produce on the Windows profile: keys, characters, left and
  right button presses and releases and moves at device points inside the core's own windows.
* A translation exists only because of one user action; nothing time-driven creates or releases one; the
  timeout only cancels.

### C.13.6 Worked examples

1. **N during the DOS pan, core at its title** (t ≈ 30 s): view key (shortcut 0) at the sync → DOS loop ends,
   dissolve; the N press is consumed; step [NONE] `S` + Return released at once → the core chooses New Game →
   outro → Birth T1 abandons the DOS dissolve with finish (C.6.6).
2. **N during the DOS pan, core in its intro** (t ≈ 5 s): the N press passes (the core's skip); step [MZ_READY
   title] `S` + Return. The core seeks to 1164, reaches the title, MenuZ flushes, then its key poll releases
   the step.
3. **Return on the DOS title box, core in its intro** (after an early skip, T4): queue [NONE] the Return
   passes (the core's skip); [MZ_READY title] `letter_k` + Return.
4. **Choice on the T4 setup page, core still in Birth** (world done): queue [NONE] the key passes (the core's
   Birth skip; the core leaves Birth at once); [MZ_READY setup 0] select and choose k.
5. **Title mouse release on row 3, core ready:** [NONE] move + left down + left up at a point of control 503;
   [MZ_SEL 3] Return.
6. **Unit stack (P26):** [NONE] click on row r; [STACK_WOKEN r] Return.

## C.14 Mouse conversion (I5, P15; prompt 8 "Inverting the logical scale")

### C.14.1 From a DOS point to a device point

* A frame-1 point L = (lx, ly) is a DOS-canvas pixel; it equals the logical point of the core's N scene
  (graphics.md 4.7: the logical layer is 320×200, drawn at ×1.6 into the 512×320 dialog client). The 4:3
  default for 320x200 frames (decision X3) changes only A's host-to-N mapping, not L.
* The adapter row names the target window (the scene's dialog, read through `w16q_wnd`) and the I5 class.
  The device point d (client coordinates) is computed by the class; the posted point is the client's screen
  origin plus d (`HostEvent.x/y` are virtual-screen coordinates, host.h).
* A point outside the class's valid range or outside the window's visible region is consumed.

### C.14.2 Proofs per class

**Class P: PollMouseClick 1108:0000** (signed: `g_clickX = (int)LOWORD(lParam) * 10 / 16` with `idiv` at
1108:0169..018F, stored at 1108:017A and 1108:018F; `g_mouseX/Y` are set by CivDialogProc 1098:1838 from
`(int)LOWORD/HIWORD(lParam)`).

* Choose d = ⌈16L/10⌉ = ⌈8L/5⌉. For d ≥ 0 signed division truncates, so g = ⌊10d/16⌋.
* g ≥ L because 10d/16 ≥ L ⇔ d ≥ 1.6L, true by the ceiling.
* g < L + 1 because d < 1.6L + 1 < 1.6(L + 1), so 10d/16 < L + 1.
* Range: L ≤ 319 → d ≤ ⌈510.4⌉ = 511 < 512; L ≤ 199 → d ≤ ⌈318.4⌉ = 319 < 320. Both inside the 512×320
  client; 10d ≤ 5,110 has no 16-bit overflow.
* Note: OPEN.md P15's and the prompt's store addresses for PollMouseClick ("1038:0CB6/0CCE") are
  WaitForKeyOrClick's; PollMouseClick's stores are 1108:017A and 1108:018F (C.20-1; OPEN P15 corrected at the merge).

**Class W: WaitForKeyOrClick 1038:0C1D** (stores `(uint16_t)(LOWORD(lParam)·10) >> 4` at 1038:0CB6..0CE2 when
the click is on the dialog window) **and CityScreenWndProc 1030:9C17** (the same form at 1030:9CD0..9D3B).

* For 0 ≤ d ≤ 6,553, (u16)(10d) = 10d and 10d >> 4 = ⌊10d/16⌋: the same function as class P, so the same
  d = ⌈16L/10⌉ maps back to L.

**Class S: rectangles scaled forward with ScaleLogicalX/Y 11E8:0D81/0DA8** (`(long)v·160/100`, `idiv`;
for v ≥ 0 that is ⌊1.6v⌋).

* A logical rectangle [L0, L1) is hit-tested in device pixels as [⌊1.6L0⌋, ⌊1.6L1⌋).
* Choose d = ⌊1.6L⌋. Floor is monotone, so L ≥ L0 gives d ≥ ⌊1.6L0⌋. And L ≤ L1 − 1 gives
  d ≤ ⌊1.6L1 − 1.6⌋ ≤ ⌊1.6L1⌋ − 1, so d < ⌊1.6L1⌋. The point is strictly inside under both the half-open and
  the closed right-edge test.
* Class P's d would fail here: L = 1 gives ⌈1.6⌉ = 2, which lies outside a rectangle [⌊1.6·0⌋, ⌊1.6·1⌋) =
  [0, 1) that contains L = 0 only, whereas d = ⌊1.6⌋ = 1 maps to the rectangle of L = 1 exactly (the
  prompt's example, reversed).

**Class C: control rectangles** (MenuZ's `RanDoMRadio` children 500..520, created at 1220:09B0 in MenuZ's item loop; 1220:08D5 creates `g_dialogTitleStatic`, showfunc 1220:0156; RV2-13;
Region controls of dialog 143; buttons 101, 102 and Cancel; EDIT 450; list boxes; dialog 141's list area;
the city buttons 96h..98h).

* Choose the centre of the largest rectangle of the control's visible region (`w16q_wnd_vis`), in screen
  coordinates. w16's hit test delivers a point to the topmost visible window containing it, and a point of a
  window's visible region is by definition not covered by another window, so the control receives it.
* Proof obligation for D4: a `test_input.c` case creates a dialog with overlapping children through the w16
  fixtures and checks that the produced point is delivered to the intended control id (C.15.2).
* No logical conversion is involved, so the DOS row's position does not matter: rows map by identity.

**Class X: position irrelevant** (the skip tests of PumpMessagesCheckSkipInput 11E0:095F, which drain the queue
and take any WM_LBUTTONDOWN; WaitTicksOrInput 11D8:0BD2): the I5 point if it lies in the window, else the
client's centre.

### C.14.3 Class per scene (P15 settled)

| Adapter (scene) | Class | Consumer evidence |
|---|---|---|
| I-intro, I-birth (movie window 148) | X | PumpMessagesCheckSkipInput 11E0:095F |
| I-title, I-setup (menu rows, Go Back, OK) | C | MenuZ 1220:0156; RunNewGameSetup 10E8:0000 |
| I-setup difficulty portraits (x < 135) | C (the chosen item's control, not a position) | SCENES 9.1 rule translated to an item |
| I-custom | C | CustomizeWorldWndProc 1108:0705 Region controls |
| I-text | C (EDIT, buttons); a click = Return | RunTextEntryDialog 10F0:0066, RunTextInputDialog 1220:16FD |
| I-wait | X (and W for WaitForKeyOrClick's stored point) | 1038:0C1D, 11D8:0BD2 |
| I-menu, I-pedia | C | MenuZ, RunListBoxDialog 1098:1909 |
| I-stack | C (dialog 141 list area, row = (y − 5)/33) | UnitStackDialogSubclassProc 11C0:3702 |
| I-city | W (map squares, citizens: g_mouseX/Y) and C (buttons 96h..98h) | CityScreenWndProc 1030:9C17 |
| I-report | X to close; P for the Intelligence INFO buttons | CloseReportScreen 1018:0380; PollMouseClick at 1018:1641 |
| I-palace | W (WaitForKeyOrClick, then g_clickX/Y at 1158:027A..029D, 1158:084D) | showfunc |
| I-space | C (MenuZ) and X; P in the arrival (PollMouseClick at 11D8:07DB) | showfunc |
| Rectangles from ScaleLogical (any D7 scene whose core hit test scales forward) | S | 11E8:0D81/0DA8 |
| I-play, I-menubar (A frames) | Windows positions: pass | the A layout is the Windows layout |

## C.15 Tests

### C.15.1 `tests/test_timeline.c` (portable unit test; no emulation)

Links `pdos_clock.c`, `pdos_tl.c`, `pdos_intro.c`, `pdos_birth.c`, `pdos_fx.c`, `pdos_seq.c` with area B's pure
machine modules (`pdos_mach.c`, `pdos_draw.c`, `pdos_glyph.c`, `pdos_pal.c`, `pdos_ui.c`; no window, no w16) and
E's store (real files from `build\dosdata`, as `test_dos`, E E.2.2). Probes are synthesized as `ObsProbe`
records. The program steps are also read back from the `PdosLogStep` log (C.5.4) for the timing checks.

1. **Clock:** `pdos_frames_done`/`pdos_frame_us` inverse for k ≤ 10^7; `pdos_tick_frame`/`pdos_ticks_after`
   inverse for n ≤ 20,000; tick 3,463 → frame 4,040; `pdos_fade_weight(j, 48)` = min(65,535, 1,394j).
2. **Intro without a key:** every frame of C.6.3; strips 4,040..4,119; slot steps 330 and 41; total 4,766.
3. **Intro skips:** keys at random instants in each phase; reaction frames per C.6.4; a shortcut read at
   O2:09D7 only up to frame 3,912; cycles off in both paths.
4. **Tick independence:** 200 random partitions of 0..70 s into ticks of 1 µs .. 1 s give identical step logs
   and an identical machine (`pdos_mn` pages, shown page and DAC, compared by hash) at 1,000 sample times
   (C.5.3).
5. **Birth:** a text event 20 frames, 15 without the dim step; a picture event 116 (+1 for the first fade);
   due clamp; the skip only with world done; the tune restart at the first text line; BUILDING only with the
   world running; the T4 setup page only with the world done (C.8.7).
6. **Abandon and finish:** the dissolve completes at once on abandon; slots freeze.
7. **No generator use:** the intro and Birth programs never call `pdos_rand` (a link-time stub that fails if
   called). The generator's own test is area B's (B 9.3, B 15).
8. **T2:** two instances fed the same inputs, one ticked every 16,667 µs and one every 1 ms, are equal at
   every sample.

### C.15.2 `tests/test_input.c` additions (area A's file)

* Pairing: pass, consume, translate 1:1, translate pairs, drag; repeats; focus loss after a consumed press; a
  switch between press and release.
* Every emitted press has a release; `present_input_release` returns 0 without a translation.
* I4: start, release on each predicate, cancellation by another action, not by release, repeat, move, chord or
  switch; timeout at 10,000,000 µs produces nothing; overflow consumed.
* `pdos_adapt_note` (Revision 2): a frame-0 key press, a frame-0 character, a frame-3 left press and a
  frame-4 ring press each cancel a pending translation; a frame-0 release, repeat or move does not; the
  note never changes the filter's output (the Windows profile stays the identity).
* Pairing across frames: press on frame 0, release on frame 1 (posted at the recorded point); press on
  frame 2 consumed in a menu box, release on frame 3 (A's routing: consumed); a left press consumed on
  frame 1, released on frame 0 (the note returns 1, `pdos_adapt_filter` consumes it; RV2-5); Space
  translated into Return on frame 1, a switch, Space released on frame 0 (the routing posts Return's
  release).
* Output bound: no host event yields more than 8 events.
* I5: for L = 0..319 and 0..199, signed ⌊10d/16⌋ and unsigned (u16)(10d) >> 4 give L for d = ⌈16L/10⌉; for every
  logical rectangle [L0, L1) with 0 ≤ L0 < L1 ≤ 320, ⌊1.6L⌋ lies in [⌊1.6L0⌋, ⌊1.6L1⌋) for every L inside.
* Class C: a w16 fixture dialog with overlapping children; the produced point is delivered to the intended id.
* Adapter rows: each row of C.12.6..C.12.7 on synthetic scene states produces its listed events.

### C.15.3 `tests/harness/ext_timeline.py` (7.7)

Headless runs with `--graphics dos --dos-data build\dosdata` (RV1-5), `--presented 1`, `--profile-samples`:

| Run | Checks |
|---|---|
| `start` (S1): intro to the title without input | the timeline log (`timeline.log`: `step <seq> <op> frame F us U dos ADDR`) has the frames of C.6.3 exactly; t0 equals the logged probe time of CreateSequencePlayer ra 11E0:00A5; DOS frame hashes at t0 + `pdos_frame_us(k)` for k = 54, 1,952, 4,040, 4,120, 4,620, 4,766 equal the D4 goldens (labelled "DOS listing (model)") |
| `start` with a base `key` line at 10 s | the DOS reaction starts at the core's skip probe time (source 1, C.6.4); the box at the computed frame |
| `birth` | Birth t0 at SeekSequence ra 11E0:01AA; event frames against the schedule; the T4 setup page after the story; the abandon at the core's DestroySequencePlayer |
| `start` and `birth` with `--switch-every 997` | DOS samples equal the DOS-all-along run (T2; also 7.4) |
| host-input `start` with a DOS key at 5 s (7.8 mode) | view action source 2; the core receives the key as its skip (T5); the DOS box before the core's title (T4); a title choice released by I4 |
| `start` with a long CPU-bound gap (a scripted `burn` line) | the DOS frame does not change during the gap and catches up after it (T6) |

Durations are compared in frames (PIT ticks) with the listing's values; seconds are only reported.

### C.15.4 `tests/harness/ext_adapt.py` DOS-form scripts (7.8)

* Each case is a pair: a DOS-form host script (`--graphics dos`) and a Windows-form host script
  (`--graphics windows`). Both must give the same `coreinput.log` (messages and virtual times) and the same
  checkpoints.
* For translations released by I4 the Windows-form events must post at the release sync. Each release
  line of the DOS-form run's `adapt.log` carries the input-sync ordinal `sync N` and the virtual time
  (A 12.2). `ext_adapt.py` writes the Windows-form events as host-form lines starting `sync N` (A 12.4).
  Their events enter the ring at the start of the N-th input-taking sync and post there. The events come
  from the adapter row, not from the log; mouse points are the host pixels that `present_view_point` maps
  to the produced virtual-screen point in the Windows-form run's layout. The ordinals agree in both runs
  up to that sync because their core input agrees up to there, which is what the comparison checks. An
  `at <ms>` line could not do this: several syncs can share one virtual time, because a PeekMessage that
  finds a message costs none (queue.c:552). This closes Revision 1's Open C-1.
* Cases (D4, D5; D6/D7 add theirs):
  1. a key in the DOS pan while the core is in its intro ↔ the same key (core skip);
  2. a key in the DOS pan with the core at its title ↔ no input (consumed; core input empty);
  3. N in the pan (core at its title) ↔ `S`, Return;
  4. N in the pan (core in its intro) ↔ N, then `S`, Return at the release;
  5. title Down, Down, Return ↔ the same; Space ↔ Return;
  6. title hotkey E ↔ `P`, Return; the Quit row ↔ `Q`, Return;
  7. title mouse release on row 3 ↔ a click on control 503, Return;
  8. Birth: a key after world generation ↔ the same key;
  9. setup: Escape on the difficulty page ↔ `C` (Chieftain), Return; a portrait click ↔ the level's letter,
     Return; Escape on the tribe page ↔ the "Custom." choice; the Go Back row ↔ a click on button 102;
  10. Customize: four DOS choices ↔ four Region clicks, OK;
  11. A's chord cases (unchanged);
  12. cancellation across frames: N in the DOS pan with the core in its intro, a profile switch, then a
      Windows key before the release ↔ N, then that key (no `S`, Return: the note cancelled the
      translation);
  13. from M on: a drag from a DOS menu-box row onto the map layer ↔ no click (consumed by the press's
      decision; through A's routing, C-11).

### C.15.5 Checks

* `obs_lint.py` (A 6.2) gains for `present/dos/pdos_*.c` and the filter part of `present/input.c`: no
  identifier starting `w16_` except `w16q_`; no `g_randSeed` or `1420:4EE0`; no call or declaration of the
  core's `RandomBelow` (probe-row names such as `OBS_P_RandomBelow` are allowed); no `post_event`,
  `host_poll_event`, `vm_`; no `#if CIV_CHECKED`.
* `gen/dos/adapters.py check` (C.12.4): ADAPT_OK.

## C.16 Rule coverage

| Rule | How met | Test |
|---|---|---|
| P0 | C.2 | 7.3 V1, V2, V6; obs_lint; test_input; test_timeline |
| O4 | C.2 steps 1..3; C.10 | obs_lint (C.15.5); A's Checked guard |
| O6 | C.5.6 | 7.4 (A 13.2); C.15.1 item 8 |
| 5.4 core decisions, generators | C.10 | C.15.1 item 7; D6/D7 scene tests |
| T1 | C.6.1, C.8.1: t0 at CreateSequencePlayer ra 11E0:00A5 and SeekSequence ra 11E0:01AA | C.15.3 rows 1, 3 |
| T2 | C.5.6; the intro runs on while the core waits at its title | C.15.3 row 4; 7.4 |
| T3 | the filter never waits; releases follow core states; omitted DOS waits (C.7.4) | 7.3; C.15.2 |
| T4 | C.7.1 (title box), C.8.7 (setup page), holds otherwise; choices via I4 | C.15.3 rows 3, 5; C.15.4 cases 4, 8, 9 |
| T5 | C.6.4, C.8.4: the core's skips end DOS sequences; DOS skips pass while the core is in the matching state, else consumed | C.15.1 item 3; C.15.3 rows 2, 5; C.15.4 cases 1, 2 |
| T6 | C.5.3, C.8.5; frames at ticks only; FIDELITY note | C.15.3 row 6 |
| T7 | C.9 (TC, TX); P6 | D6 tests (draft D) |
| I1 | C.13.5 | C.15.2 |
| I3 | C.12.4..C.12.8 | C.15.2; C.15.4; ADAPT_OK |
| I4 | C.13; cancellation on every frame through the note (C.12.1) | C.15.2; C.15.4 cases 3, 4, 6, 7, 9, 12 |
| I5 | C.14 | C.15.2 (I5 and class C) |
| I6 | C.12.6 (consume when the core has left), C.12.7 | C.15.4 case 2 |
| I8 | the wheel never reaches the filter (A 10.1, D 12.3); no adapter uses it | A's test_input |
| 7.7 | C.15.1, C.15.3 | – |
| 7.8 | C.15.4 | – |
| Prompt 8: Birth inside world generation | C.8.5 | C.15.3 row 3 |
| Prompt 8: RNG-driven presentation | C.10 | obs_lint; C.15.1 item 7 |
| Prompt 8: inverting the logical scale | C.14.2 | C.15.2 |

## C.17 OPEN.md items settled here

| Id | Resolution |
|---|---|
| P1 | VGA: 17,024 PIT clocks per frame (M1). Choice |
| P2 | NSOUND: the tick always runs (M7). Choice (the proposal) |
| P3 (timing part) | C.10: core decisions followed; the generator model and seeds are area B's (B 9.3, B11); C's timelines draw no random number; `G#10` is stepped once per DOS frame (M10) |
| P6 | the core's moves and blink (C.9; draft D 14.6) |
| P7 | `E` = 256 (M5). Choice (the proposal) |
| P10 (timing) | slots stop without restore; step counts C.6.5. Reproduce |
| P15 | C.14.3 |
| P16 | settled by B (B 11.2); input side: the menu-box model on the core's list (C.12.8) |
| P17 | added DOS rows (Go Back, Cancel) mirroring the core's buttons; Escape keeps its DOS meaning per page (C.12.7). Choice |
| P18 | settled by B (omit, B 11.2); no input maps to it (C.12.8) |
| P20 | settled by B (follow the core's placements, B 9.3); no timing part |
| P21 | settled by B (B 6.7, Choice B5); C adds the scene rule "hidden while a DOS intro or Birth timeline is live" (C.11.5). Choice |
| P22 | 10,000,000 µs per step (C.13.4). Choice; it covers the 237-movie-frame wait (C.20-5) |
| P24 | settled by B (B 11.2: clicks unchanged); input side: identity at the Windows extents (C.12.8) |
| P25 | a left press ends the DOS intro in every phase but the dissolve; it passes as the core's skip while the core is in its intro and is consumed afterwards (C.12.6). Choice, FIDELITY; accepted (C.20-2), listed for the user's check |
| P26 | a DOS choice → click on the row, then OK (C.12.8). Choice |
| P29 | the divider is reset at every `S#1` (M7). Choice |

P4, P5, P11..P14, P19, P23, P27 are area B's or E's; P8, P28 are settled by E.

## C.18 Choices (summary)

1. **Clock** (C.4.1): VGA frame 17,024 clocks; NSOUND; divider reset at `S#1`; `E` = 256; ideal machine M1..M12
   (retrace waits, palette loads, key flush, the dissolve's BIOS wait and calibration take no time; the first
   fade's measurement takes one frame). Alternatives in C.4.1.
2. **One grid per timeline**, anchored at its start event.
3. **Event-sourced engine** with closed-form waits; the programs call area B's DOS-machine primitives on `pdos_mn`
   at each step's instant (C.5.4), with C's fade weight and cycling step frames; per-frame shortcuts (last fade
   weight, cycling steps mod count) only where the result is identical.
4. **Two sources for a DOS key**: the core's skip probes and the filter's view actions; the DOS listing's own
   reaction per phase.
5. **Abandon on the core's next scene; finish only the intro's dissolve.**
6. **T4 next screens**: the title box; after the DOS story with the world done, the post-Birth fade and the first
   setup page. Otherwise hold.
7. **"BUILDING NEW WORLD..."** only while the core's world generation runs.
8. **Omitted DOS waits** after a menu choice (confirmation, phrase boundary): the box stays until the core moves.
9. **Back to the title**: the box over the current DOS screen for every branch, as R:01A8:0807.
10. **Title hotkeys** from the DOS text; Q for the added Quit row.
11. **Filter decision at the sync's time**; keys stamped with the arrival frame (A-1).
12. **Pairing rule** for keys and buttons; repeats of translations consumed.
13. **Lone modifiers are skip keys** in DOS sequences (the user's "any key").
14. **Letters before clicks** for MenuZ selections; clicks wait for the selection before Return.
15. **One pending translation**, six steps, cancelled by other actions only; chords and switches do not cancel.
16. **Timeout 10 s** per step.
17. **Control-rectangle point** = centre of the largest visible-region rectangle.
18. **P17, P22, P25, P26** and the P3 timing part as C.17 (P16, P18, P20, P21, P24 are B's; C's input side follows).
19. **Pointer scene rule**: hidden while a DOS intro or Birth timeline is live, else B's table (C.11.5).
20. **Setup step identification** by item count and Go Back state (C.11.4).
21. **Input during DOS-only transitions** consumed where the DOS program would flush it.
22. **The note on frames 0, 3 and 4** (Revision 2): user actions there cancel a pending translation;
    pairing holds across frames through A's routing of the note's return value (C-11, adopted in A
    10.1; C.12.1, C.12.2).

## C.19 Open items

| Id | Item | Phase |
|---|---|---|
| C-1 | Closed in Revision 2: A's `sync <n>` host-form lines (A 12.4; C.15.4) | – |
| C-2 | Model rules M3, M10, M11 and M4 are unobserved; DOS-oracle O1/O2 would replace them with measured values (TIMING Open 1, 4) | D4 (oracle) |
| C-3 | Setup step discriminators (C.11.4) checked against the listing | D5 |
| C-4 | Dialog 143's Region control ids per group and item, and the help request's control (C.12.7) | D5 |
| C-5 | The exact O7:17CF transcription (the "now" of the first text event, the dim step at the first event) from the listing; C.8.3 follows TIMING 5.5 | D4 |
| C-6 | The DOS title box's wrap on Up/Down when the core is not ready (view row) | D4 |
| C-7 | I-city's other DOS keys (OPEN L20) and region map | D7 |
| C-8 | Whether any D7 scene's hit test scales forward with ScaleLogical (class S); none is named yet | D7 |
| C-9 | The goldens of C.15.3 are recorded at D4 from the model; they are model fixtures, not DOS-oracle results | D4 |
| C-10 | **Closed in Revision 3.** RV2 checked B's final signatures (`pdos_menubox_layout`, `pdos_menubox_row`, B 4.4; `pdos_setup_page`, `pdos_ui_box(PDOS_BOX_SETUP)`, B 11.5) against C.12.5 and C.8.7: they match (RV2, interfaces B ↔ C). B 4.4 gained RV2-11's `h8` input and row clamp; C's title box and setup page leave `h8` 0 | – |
| C-11 | **Closed in Revision 3.** A's filter uses the note's return value (A 10.1; decision C-11, RV2-5); C.12.2's fallback is withdrawn | – |

## C.20 Conflicts and corrections

### C.20.1 Resolved (ext-d1-decisions.md, "Area C")

| Id | Point | Resolution, as applied here |
|---|---|---|
| C.20-1 | PollMouseClick's stores are 1108:017A and 1108:018F, not 1038:0CB6/0CCE (those are WaitForKeyOrClick's) | OPEN P15 corrected at the merge; d = ⌈16L/10⌉ is unaffected (C.14.2) |
| C.20-2 | P25: a left click ends the DOS intro, which the DOS program ignores | Accepted (T5); FIDELITY; listed for the user's check (C.12.6, C.17) |
| C.20-3 | Birth's T4: the DOS setup page after the story when the world is done; a choice there is "Birth skip + choice" | Accepted; the Birth skip still waits for the world; DOS-PROFILE row 9 and 3.1 corrected at the merge; listed for the user's check (C.8.7) |
| C.20-4 | N, L, E, C count "during the pan", not "after" | The listing wins; DOS-PROFILE 1.7 corrected (C.6.4) |
| C.20-5 | P22's longest wait is 237 movie frames (3.95 s) | Covered by the 10 s limit per step; OPEN P22 corrected (C.13.4) |
| C.20-6 | TIMING 5.3's totals: with a key, "cycles off" still runs | TIMING.md 5.3 corrected at the merge (C.6.2) |
| C.20-7, 8 | Lone modifiers skip DOS sequences; omitted DOS waits and the ideal machine M1..M12 | FIDELITY entries, with K3's (C.12.3, C.4.1, C.7.4) |
| C.20-9 | C's probe rows | Accepted; in A 4.3 (C.11.2) |
| C.20-10 | C's requests to B, B-1..B-8 | Accepted; B's Revision 2 adopts them (C.21) |

Revision 1's alignment with draft B stands: generators, seeds, P20, P16, P18, P21, P24, hit geometry
and the drawing interface are B's. B's Revision 2 also takes the 16-bit `srand` seed (C.10.1).

### C.20.2 New points for RV2

1. **Parts of a C-decided action on frames 0, 3 and 4** (C.12.2). A's dispatch passes them unchanged and
   calls the note only to observe. Then a key held across a profile switch, or (from M on) a drag from a
   DOS menu box onto D's map layer, posts a release without its press, or loses the release of a
   translated key. **Request:** A uses the note's return value to hand such a part to
   `pdos_adapt_filter` (one line in `present_input_filter`). Fallback without A's change: owed releases
   through `pdos_pend_release`, and lone releases reach the core. For RV2 to settle with A.
   **Settled (Revision 3):** decision C-11 accepts the request; A 10.1 and C.12.1 carry the line
   (RV2-5).
2. **Parts of a ring press.** C assumes A's arrival stamps every part of a ring press with frame 4 (D 12.1's
   table, "left: frame 4 release"), so D's ring translation always gets its release. If a part reached C,
   C could not know D's translated point. RV2 to confirm with A and D.
   **Confirmed (Revision 3):** RV2-3 found that Revision 2 did not guarantee it; A 10.1 and D 12.1 now
   latch each press's class until its release, so every move and the release of a ring press are frame
   4 (decision RV2-3; C.20.2-2 confirmed).

## C.21 Interfaces with other areas

| Id | Area | Interface | Direction |
|---|---|---|---|
| A-1 | A | `input_frame` (A 8.1) and `HostEvent.frame` on every event: 0 Windows, 1 N (N-canvas pixels), 2 A (virtual-screen pixels), 3 layer point (virtual-screen), 4 ring square (col, row) (A 10.1) | C uses |
| A-2 | A | the probe rows of C.11.2, in A 4.3 (C.20-9); `ObsProbe` of A 4.2 (`id`, `phase`, `far_ret`, `addr`, `ra`, `site`, `t_us`, `arg_base`); `w16q_arg16(p, i)`, `w16q_ret_ax()` | C uses |
| A-3 | A | `present_input_filter`: `pdos_adapt_note` for frames 0, 3, 4 and `pdos_adapt_filter` for frames 1, 2; `present_input_release` → `pdos_pend_release`, once per input-taking sync after its host events; `PI_MAX_OUT` 16 (A 10.1; C.12.1). **Request:** use the note's return value (C.20.2 item 1). **Adopted** in A Revision 3 (C-11, RV2-5) | A implements, C supplies |
| A-4 | A | `present_log(PRESENT_LOG_TIMELINE / PRESENT_LOG_ADAPT, line)`: `timeline.log`, `adapt.log` (CIV_OBSERVER, DOS profile registered); release lines carry `sync N` (A 12.2); not part of the base trace | A writes, C fills |
| A-5 | A | the DOS profile's cursor handler (RV1-7) takes B's `pdos_cursor_current()`, which consults C's `pdos_seq_pointer_hidden()` (C.11.5) | A calls B; B calls C |
| A-6 | A | `obs_lint.py` rules of C.15.5; the `RandomBelow` rule covers calls and declarations only (A 6.2) | A owns the script |
| A-7 | A | `sync <n>` host-form lines, the input-sync counter and its hook `w16_host_input_sync_fn` in host_sync.c (A 12.4) | C's `ext_adapt.py` uses |
| B-1 | B | the DOS-machine primitives the programs call on `pdos_mn` (C.5.4): `pdos_copy_rect`, `pdos_show_page`, `pdos_sprite`, `pdos_fill_rect` (B 4.2), the glyph and `pdos_ui` helpers (B 4.3), the DAC loads and splices (B 5.2) | C calls B |
| B-2 | B | `pdos_fade_step(out, start, target, w)`, `pdos_cycle_setup(c, d, lo, hi)`, `pdos_cycle_step(c, d, dir)` and `pdos_cycle_advance(c, d, dir, n)` (B 5.3): B does the arithmetic and holds the colours and position; the weight `w` (M5, `pdos_fade_weight`) and the frames at which a cycling step happens are C's | C calls B with C's values |
| B-3 | B | `pdos_r_hit(frame, x, y, &hit)` (B 11.4) for R elements; `pdos_menubox_row(b, mx, my, &disabled)` (B 4.4; adopted) for a box a C program draws with no core control behind it (the title box in T4, the T4 setup page of C.8.7) | C calls B |
| B-4 | B | B's `pdos_cursor_current()` (B 6.7) consults C's `pdos_seq_pointer_hidden()` (C.11.5) and bumps `gen` when it changes | B calls C |
| B-5 | B | `pdos_dissolve_start`/`pdos_dissolve_frame` (B 4.2): C calls `pdos_dissolve_frame` once per DOS frame of the timeline (M10); on abandon C calls it until it returns 1 (C.6.6) | C calls B |
| B-6 | B | adopted (B 11.5, Choice B21): the D5 setup-page renderer can draw `SETUP_PAGE(0, row 0)` on `pdos_mn` page 0 from DOS static content alone (`DIFFS.PIC`, the DOS header, the five levels of DGROUP:3526, Go Back disabled) before the core's dialog 144 exists, for the T4 page of C.8.7; when the core's MenuZ arrives, B's scene renderer takes over the same page without a redraw flash | C calls B |
| B-7 | B | the scene stack and `pdos_scene_listen` (B 9.2): `pdos_seq` registers a listener and reads the top row's `renderer`, `timeline` and `adapter` fields; C writes no row | C uses B |
| B-8 | B | B's `pdos_profile.c` (A 8.1, RV1-18) forwards every event and entry probe to `pdos_seq_on_event`/`pdos_seq_on_probe` after its scene-stack update and before its own drawing, and calls `pdos_seq_advance(now)` from `advance`, visible or not (O6, C.5.6; B 2.1, Choice B22). At an exit probe (RV2-12, Choice B24) B first calls `pdos_seq_advance(p->t_us)`, then draws, then pops the scene (C's listener runs there), then calls `pdos_seq_on_probe(p)`, so C's timelines still reach the probe's time before B draws | B calls C |
| B-9 | B | `reset` calls C's `pdos_seq_reset()` after B's own resets (B 2.1) | B calls C |
| D-1 | D | A's dispatch calls `pmap_filter_ring` for frame 4 (declared in D's `pmap.h`, D 3, 12.2; RV2-6) and passes frame 3; C sees both through `pdos_adapt_note` (cancellation; routing of parts of C's own actions, C-11). Every part of a ring press stays frame 4 by A's and D's press latch (RV2-3; C.20.2 item 2 confirmed) | A calls D; C observes |
| E-1 | E | `pdos_text_line(id, i, &len)`, `pdos_text_count(id)` with `PDOS_F_CREDITS_TXT`, `PDOS_F_STORY_TXT` (E.4.1, E.8.1; RV2-9); `pdos_table_u16`/`pdos_table` for `BIRTH_SCHEDULE`, `BIRTH_CYCLE`, `TITLE_MENU` | C calls E |

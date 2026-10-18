# D1: the orchestrator's resolutions of the design drafts' conflicts

Extension phase D1 (`claude/docs/x64-port-scaling-dos-prompt.md` 9). The design agents of
[BRIEF-d1.md](BRIEF-d1.md) list conflicts with the prompt or the delivered design in their final
messages and drafts. The orchestrator resolves them here, under the user's standing directions
(STATUS.md "User directions": autonomous continuation, 2026-10-10 late evening and 2026-10-11
about 06:00). A resolution that changes behaviour the user has already checked is listed for the
user's information in the final report and, where visible, in `manual-checklist-ext.md`.

## Area A ([ext-d1-draft-A.md](ext-d1-draft-A.md))

| Id | Conflict | Resolution |
|---|---|---|
| K1 | P0 says the checkpoints do not depend on the window size or the scaling policy; since phase G (F105, F110, the user's directions of 2026-10-10 21:00 and 22:05) the game's virtual screen follows the host client, so under `--game-screen view` (and in civ64) the host size and the policy are core inputs | **Scoped P0.** P0 holds for the graphics profile, the switch history and the map zoom in every mode; for the host size and the policy it holds with a fixed game screen (the harness default, or `--game-screen WxH`). Recorded in DESIGN.md 12.5 and FIDELITY. The zoom (phase M) never feeds `present_game_screen_follow`: the game screen comes from the 640x480 layout only. |
| K2 | 5.1 lists only a few w16 changes; the design also changes `vm.c` (probe hooks), `host_sync.c` (the input filter, the 7.8 mode, a post hook) and adds Checked-only guards | Accepted; DESIGN.md 12.5 lists every w16 change with its reason (as the X0 review B1.9 and D14 asked). |
| K3 | The S2 Alt hold rule extended to Ctrl and Shift (a lone Ctrl or Shift reaches the game at its release, with its press), because PumpMessagesCheckSkipInput (11E0:095F) takes any key press as a skip in the intro, Birth and About movies, so the chord's Ctrl press would skip the intro (against T2) | Accepted as a Choice, recorded in FIDELITY next to F101; the user's S2 check covered Alt+Enter only, so the changed timing of a lone Ctrl or Shift is listed for the user's check. |
| K4 | The S2 arrival code (chords, the Alt rule, mouse mapping) moves from `host_win32.c` into portable `present/input` | Accepted: behaviour kept, guarded by the 7.2 tests and the new 7.8 mode. |
| K5 | `HostEvent.frame` (the presentation frame at arrival) is a `host.h` change | Accepted; area C uses it for I5. |
| K6 | DOS-PROFILE.md's probe column holds call-instruction addresses, not function starts | Sent to fixer F3 (D0): the probe list gives the function start (the probe key) and, where needed, the call site separately. |
| K7 | Remembering the profile goes beyond 5.11's "default windows" | Not a conflict: the extension's 2.1 "Settings file" bullet (granted) lists "the last graphics profile". With nothing remembered the profile is `windows`. |
| K8 | Asan deferred | As the user's direction of 2026-10-10 21:20: gate records say "Asan deferred", and one Asan pass runs at the end of the queue. |
| K9 | M is a backlog item | The D3 gate is 7.3 without zoom; the zoom command and variation stay inactive until M. |

## Area E ([ext-d1-draft-E.md](ext-d1-draft-E.md))

| Id | Conflict | Resolution |
|---|---|---|
| E.18-1 | 5.9 forbids a DOS directory inside the data directory; phase R's step 4a (the program's folder as the data directory) with step 3 (a `CivDos` subfolder) produces exactly that | **Refuse only when the two paths are equal.** The core cannot reach a subfolder (`dos.c` `resolve` and `host_dir_list` list and open files of the data directory only), so the reason of 5.9 holds. Recorded in FIDELITY. |
| E.18-2 | 5.9 accepts `CIV_UNP.EXE` instead of `CIV.EXE`; phase R's validity rule requires the pinned `CIV.EXE` | Phase R unchanged (the user's accepted design); the asset store supports `CIV_UNP.EXE`, reachable headless. |
| E.18-3 | D2 gate "7.6 passes under Asan" | Asan deferred (K8); D2 records Checked and Release; `test_dos` joins the final Asan pass. |
| E.18-4 | 5.9 "checked the first time it is needed" read as "at activation, before the profile can first need it" | Accepted. |
| E.18-5 | 5.9 "sprite rectangles and layouts never copied into source" against the user's X0 decision D6 ("Allow immediates": DOS instruction immediates may be C constants with their DOS address) | The user's decision wins for immediates inside DOS code; tables in the DOS data segment are read at run time through the offset registry. |

## Area D ([ext-d1-draft-D.md](ext-d1-draft-D.md))

| Id | Conflict | Resolution |
|---|---|---|
| C1 | The user's levels -1, 0, +1 (2026-10-10 21:00: "every step halves or doubles with respect to default resolution") replace 5.8's integer steps and `--zoom <m>`; at an odd frame factor k (the user's own window is k = 3) Windows level -1 cannot be pixel-perfect, against Z-1; under `fit` the design doubles the real factor | **The user's direction wins.** Level -1 at odd k is the recorded 2:1 reduction of 5.8's "half level" (not pixel-perfect), labelled so in RUNNING.md and FIDELITY; at even k and in the DOS profile it is pixel-perfect. Under `fit` the levels halve and double the actual factor. `--zoom default|-1|0|+1`. |
| C2 | 7.5 asks for mirror equality "at every present"; the user's planned shape says "mirror equality on in-view squares" | M's gate is the M1 checks of the draft (key, render and settled port-bitmap equality); the per-present comparison (M2) is built and gated with D6. |
| C3 | Z-2's pixel-identical default renderer | Met by construction: at level 0 there is no layer, and in view the layer shows the core's own pixels. Recorded so that the review reads Z-2 this way. |
| C4 | During play the A canvas has the virtual screen's size and the Windows layout (phase G) | Accepted; area B designs the A canvas at the screen's current size. |
| C5 | The map model needs map-specific shadow handlers | Area B's shadow engine offers handler hooks; the map model registers its handlers there (one engine). |
| C6 | A press outside the core's view becomes a small-map click that recentres the map | Kept: it is 5.8's own example of a proven equivalent original input (CenterMapOnSmMapClick 1210:056E); recorded in FIDELITY with the rule, listed for the user's check. |
| C7 | Owner of the DOS small map, status window and unit panel in D6 (DOS-PROFILE rows 136, 138, 139) | Area B (class A art substitution in the Windows layout). |

## Design review RV1 (areas A, D, E; [ext-d1-review-rv1.md](ext-d1-review-rv1.md))

| Id | Resolution (applied by the draft's author) |
|---|---|
| RV1-1 (blocker) | **Area E owns a shape-cut module `pdos_shapes`** that reproduces the DOS start-up cut O5:1455 from the decoded pictures: the rectangles as constants citing their O5 addresses (the user's X0 decision D6), the recolouring (eight unit copies), the TER257 row rule (SPRITES.md 4; DGROUP:1A3E taken as 0, recorded), and copies such as D4DC from 6E92. It runs at activation with the rest of the store. D asks for shapes by family and index; only tables below DGROUP:6B30h (1946, 1956, ...) go through OFFSETS.md. |
| RV1-2 | D renames its function `pmap_layer_point` (no clash with `present_map_point` of `scale.c`). |
| RV1-3 | D's files take the `pmap_` prefix (`present/map/pmap_*.c`); build.cmd's portable loop gains `present\map\*.c` (as E adds `present\dos\*.c`). |
| RV1-4 | D's section-17 requests to A (A-1..A-8) are **accepted**; A adds them to its sections 2, 5, 7.2, 8.3, 10.1 (`HostEvent.frame` 3 the layer point, 4 a ring square). K2's list of w16 changes gains the outline state of `user_syscmd.c` (for `w16q_sys_track`) and the rasteriser refactor of `gdi_draw.c`/`gdi_font.c` (drawing on a caller surface, for `w16q_draw_on`), both guarded by G-1 and the base tests. D's requests to B (B-1..B-4) are B's to adopt (RV2 checks). |
| RV1-5 | Every DOS variation of 7.3 and 7.4 passes `--dos-data build\dosdata`; the runner asserts from `profiles.log` that the switches happened and none was refused. A's line "the DOS profile needs no `--dos-data`" is limited to civ64 (phase R). |
| RV1-6 | **"Locate DOS files..." during a run records the choice only** (phase R's browse and civ64.cfg `dos_data`); its message says the DOS profile becomes available at the next start. E's store stays built once before the emulation. |
| RV1-7 | A designs the cursor route: `w16_SetCursor` no longer calls `host_set_cursor` directly; it emits the observer event and calls a present entry (`present_cursor`), and the visible profile decides what the host shows: the game's RT_CURSOR bytes (Windows profile, as now) or the DOS pointer as pixels with a hot spot through a new `host.h` entry (`host_set_cursor_pixels`); a switch re-issues the current one. K2/K5 list the `host.h` and `user_cursor.c` changes. |
| RV1-8 | A's cadence (one message per run, then beeps) with E's message alone plus the "Locate" hint; E.4.3 corrected. |
| RV1-9 | `OBS_PAL_ANIMATE` is emitted after the entries change, with the `moved` flag. |
| RV1-10 | ResyncMovieClock 10B0:14F4 dropped from the probe list (not ported). |
| RV1-11 | `obs_init()` in `civ64_main.c` before `civ64_run_game`, after E's activation. |
| RV1-12 | A's P0 argument names `present_game_screen(_follow)` (must stay profile-independent) and says how the view functions become profile-aware while the harness's relation check keeps reading the Windows frame. |
| RV1-13 | The arrival stage lives in its own always-compiled file; `CIV_OBSERVER=0` removes only the filter stage. |
| RV1-14 | The observer depth is reset in `obs_init`/`hh_run` and after each expected fault in tests. |
| RV1-15 | The arrival stage masks MK_SHIFT/MK_CONTROL of held keys in moves; recorded with K3's FIDELITY entry. |
| RV1-16 | The TER257 row rule is in E's shape module (RV1-1); D cites it. |
| RV1-17 | RV2 checks B and C's interfaces. |
| RV1-18 | `present/dos/profile_dos.c` becomes `pdos_profile.c`. |
| RV1-19 | Near callees' call-site rows compare offsets; cite MenuZSubclassWndProc 1220:1289. |
| RV1-20 | D: 450x350 is the window's minimum, not the client's; the +1 rule's square count corrected. |

## Area B ([ext-d1-draft-B.md](ext-d1-draft-B.md))

| Id | Conflict | Resolution |
|---|---|---|
| X1 | 5.4 asks to verify per scene that the DOS palette's entries 0..15 are the EGA colours; PALETTE.md 6 shows they often are not, and the DOS program uses entry c anyway | Read 5.4 as "record a report per scene, no correction": the DOS profile shows what the DOS program shows (entry c of the scene's palette). The per-scene report is part of D4..D7's records. |
| X2 | Two font-map rows (labels, report titles) rest on the inherited font 1, not on a corresponding call-site pair (5.10) | Accepted as **inferred** while B's OB4 (trace the 66 font writes) stays open; D6/D7 settle it. |
| X3 | The user's direction of 2026-10-10 21:00 says the start-up, credits and intro, title menu, Birth and setup screens "shall stay 4:3"; the DOS profile shows them as 320x200 frames, which `--aspect square` (the S2 default) shows at 16:10 | **The aspect default becomes 4:3** for 320x200 frames (the only frames it affects): the user's direction decides it. `--aspect square` and the system-menu item stay for the player's override, remembered as before (the user's decision D7). Recorded in FIDELITY and listed for the user's check. |
| X4 | The DOS menu-bar text at 1x while the other A art is at 2x (the eight titles take 314 px at 1x, 628 px at 2x; the bar is about 475 px) | B's Choice B15 kept; listed for the user's visual check at D6. |
| X5 | D's request B-4 cites L17 for the label font; the register entry is L23 | Corrected at the merge. |
| X6 | E's `pdos_shapes` cuts units at the DOS rectangle with the +1 | As SPRITES.md 6.4; P11's pixel check confirms it. |

B's requests to A (A-B1..A-B8: exit probes on every logical primitive and text probe; probes on GR_PortDataToBitmap, PlotSmMapSquare, DrawMiniPalace and WI 10.2's text probes; queries `w16q_msgbox`, `w16q_menu_item`; `present_core_xrgb`; re-layout when the visible profile's frame size changes; the cursor route taking `pdos_cursor_current()`; 8-bit N-frame dumps) are **accepted** and sent to A's revision.

## Area C ([ext-d1-draft-C.md](ext-d1-draft-C.md))

| Id | Conflict | Resolution |
|---|---|---|
| C.20-1 | Prompt 5.6 I5 and OPEN P15 give PollMouseClick's stores as 1038:0CB6/0CCE; they are WaitForKeyOrClick's; PollMouseClick stores at 1108:017A/018F (the X0 review found the same) | Citation corrected in OPEN P15 at the merge; the rule is unaffected. |
| C.20-2 | P25: a left click ends the DOS intro (the DOS program ignores clicks there), because a click skips the Windows core's intro (PumpMessagesCheckSkipInput 11E0:095F) and T5 ends every profile's sequence | Accepted (T5); recorded in FIDELITY and listed for the user's check. |
| C.20-3 | Birth's T4: when the DOS Birth story ends and the world is done, the DOS setup page is shown (up to about 27 s before the core leaves Birth), and a choice there becomes "Birth skip + choice"; DOS-PROFILE row 9 and 3.1 named "BUILDING NEW WORLD..." as the hold | Accepted: T4 allows the next screen when its content is fully known, and the Birth skip still waits for the world (the user's directions of 2026-10-09 06:47 and 2026-10-10 10:50). DOS-PROFILE row 9 and 3.1 corrected at the merge; listed for the user's check. |
| C.20-4 | DOS-PROFILE 1.7 allows N/L/E/C "after or during the pan"; the listing narrows it to "during the pan" | The listing wins; DOS-PROFILE 1.7 corrected at the merge. |
| C.20-5 | P22's longest wait is 237 movie frames (3.95 s; the seek at movie frame 141) | C's I4 timeout of 10 s per step covers it; OPEN P22 corrected. |
| C.20-6 | TIMING.md 5.3's totals paragraph is wrong: with a key, "cycles off" still runs | TIMING.md 5.3 corrected at the merge. |
| C.20-7, 8 | Lone modifiers skip the DOS sequences (with K3); omitted DOS waits and the "ideal DOS machine" model (M1..M12) | FIDELITY entries (with K3's). **C.20-7 superseded for the DOS profile** by the user's direction on D4-3 (2026-10-15: Ctrl, Shift, Alt and the lock keys; D4cF): with the DOS profile visible a lone Ctrl, Shift, Alt, Caps Lock, Num Lock or Scroll Lock does not skip the DOS intro or Birth (FIDELITY F115); the Windows profile is unchanged (F114). Item 8 unchanged. |
| C.20-9 | New probe rows from A (SetGameCursor ra 11E0:08D7; IsKeyPending 11E8:02FB ra 1220:0AA5; MenuZ ra 11E0:0729, 10E8:0528; DestroySequencePlayer ra 11E0:0114, 11E0:01E8; GR_DialogOpen ra 11E0:0044; GR_DialogClose ra 11E0:0217; DrawUnitStackList 11C0:3407 ra 11C0:334F) | **Accepted**, sent to A's revision. |
| C.20-10 | C's requests to B (B-1..B-8, among them B-3 a menu-box row query for boxes a C program draws, B-6 the T4 setup page from DOS static content before dialog 144 exists, B-8 `pdos_seq_on_event/on_probe/advance` forwarding) | **Accepted**, sent to B's revision with D's requests B-1..B-5. |
| C-11 | (C Revision 2, C.20.2 item 1) A's filter passes frame 0, 3 and 4 events unchanged and uses `pdos_adapt_note` only to observe, so the release of a press C consumed or translated on frame 1 or 2 can arrive on another frame | **Accepted**: `present_input_filter` uses the note's return value; when it returns 1 (a later part of an action C decided other than "pass"), the event goes to `pdos_adapt_filter` instead. A's text is amended at the merge. |
| C.20.2-2 | Every part of a ring press stays on frame 4 (D 12.1) | RV2 confirms against A and D. |

## Design review RV2 (areas B and C, every cross-area interface; [ext-d1-review-rv2.md](ext-d1-review-rv2.md))

| Id | Resolution (applied at the merge, Revision 3 of the drafts) |
|---|---|
| RV2-1 (blocker) | A 4.3 gives entry **and exit** probes to DrawMapTile, DrawUnitAt, DrawCityLabels, DrawSmTiles, RedrawSmMap, RedrawStatusWindow, DrawStatusCivPanels, DrawUnitInfoPanel and WdwMapOpen (WINDOWS-INVENTORY.md 10.6/10.7 list them entry only; B's and D's brackets and "at exit" consumers need the exit). A's lint (`obs_lint.py`) checks that every macro key, every exit-0 scene row and every "at exit" consumer of B, C and D has the X phase. |
| RV2-2 | `OBS_CALLSITES` gains RunNewGameSetup ra 11E0:020A and CustomizeWorldDialog ra 11E0:0826 (C's SETUP and CUSTOM filters). |
| RV2-3 | The arrival stage latches each press's frame class (and D's layer or ring decision) until its release: moves while held and the release keep the press's frame; recorded in A 10.1 and D 12.1. C.20.2-2 is then confirmed. |
| RV2-4..18 | The minors and notes are applied as RV2 proposes (names, declarations, citations, B 4.4's DGROUP:3936 and the (192-y)/h clamp, B 2.1's pop order, K2's list with E's host.h additions, C-11 in A's filter code block). |

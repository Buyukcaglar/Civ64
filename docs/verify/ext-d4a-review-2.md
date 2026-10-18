# D4a second review: shadow, compose, scene, font map, profile (independent, read-only)

Reviewer: independent read-only review (2026-10-12) of `present/dos/pdos_shadow.c/.h`,
`pdos_compose.c/.h`, `pdos_scene.c`, `pdos_scene_tab.c`, `pdos_fontmap.c`, `pdos_profile.c` against
draft B revision 3 (`docs/verify/ext-d1-draft-B.md`) sections 2.1, 6, 7, 8.2 (for the flush case only),
9, 10.1, and the record `docs/ext-D4a-record.md` (deviations, review fixes, what is left). Supporting
reads, no more: `present/observe.h` (`ObsProbe`, `ObsDraw`), `present/observe.c` (`obs_probe`),
`present/present.c` (the O6 loops and `cursor_issue`), `platform/w16/user_dlg.c` (event order of
`OBS_DLG_CREATE`), `platform/w16/gdi_draw.c` (what `ObsDraw.changed` holds), `present/dos/pdos_mach.c`
(surface init/resize/damage). No build, test, git or DOS program.

Status: COMPLETE for items 1..5 within the limits in "Not reviewed".

## Summary

* BLOCKER: 0. MAJOR: 6. S1 and S4 are reachable with D4a's engine. S2, S3, S5 and F1 are latent
  until D4b..D7 add `leave`s, macros, WIN owners or report scenes. MINOR: 7 (S6..S9, C1, P1, F2),
  plus the test gaps listed at the end. Observations: 3.
* P0: clean. The six files read the emulation only through `w16q_*`, inside `#if CIV_OBSERVER`.
  Nothing writes emulation memory, posts or sends, and nothing touches `g_randSeed`.
* O6 and 7.4: clean. No callback depends on visibility. `present.c` feeds every registered profile.
  The shadow table is a flat array scanned in index order, and `peek` keeps the damage.
* Callback order (2.1, B22, B24): matches, entry and exit.
* The MAJOR findings are in the shadow engine's bracket and N-canvas logic:
  * a lost inner exit leaves brackets open forever (S1);
  * `PdosBracket.changed` mixes screen and client coordinates (S2);
  * flushes inside `leave`-drawing brackets copy content that is not yet drawn (S3, design gap);
  * the N window's page-0 binding is decided once and aliases (S4);
  * DOS-only brackets drop the WIN rule set's events (S5);
  * the 10.1 report-header font row is missing (F1).
  S1 needs a macro and a lost exit; S4 needs two logical N windows open at once.

## Findings

### S1 (MAJOR) A lost inner exit leaves brackets open forever
* `present/dos/pdos_shadow.c:1061..1080`.
* Design 7.3 "Exit": `leave` is called, then the bracket closes; 9.2 (same rule for the scene stack):
  the exit pops its entry "and everything pushed above it, which a correct core never leaves". The
  code's own comment at line 1062 says "the mark and everything above it".
* Code: `g_nmark = mi` discards the marks above the matched one, but the bracket loop pops only while
  the top bracket's `group == group`. Brackets of the discarded marks sit above (higher group), so the
  loop stops at once and neither those brackets nor this group's own brackets are closed.
* Sequence: macro A (DROP, target bitmap X) enters: mark 0 / group 1 / bracket 0. Macro B (DROP,
  target X or Y) enters: mark 1 / group 2 / bracket 1. B's function is left without its exit probe
  (a non-local exit: Throw, task end, or any missed exit). A's exit: `mi = 0`, `g_nmark = 0`, top
  bracket has group 2 != 1, loop ends. `g_nbr` stays 2; every later draw to X (and Y) is dropped and
  recorded for the rest of the run (`drop_event`), `on_draw` hooks and copies into them never run, the
  shadows freeze, and `pdos_shadow_context` keeps answering. Each further lost exit leaks more, and
  at `PDOS_BRACKET_MAX` (32) no bracket opens any more.
* Severity MAJOR (wrong frames for the rest of the run, but only when an exit is lost).
* Fix: pop while `g_nbr > 0 && g_br[g_nbr - 1].group >= group` (groups increase with the stack). Close
  brackets of a higher group without `leave` (or with it, as decided) and count them (for example
  `exit_orphan`).

### S2 (MAJOR) `PdosBracket.changed` mixes two coordinate spaces
* `present/dos/pdos_shadow.c:701..716` (`record_event`).
* Design 7.3: `changed` is "the union of the suppressed device rectangles" of the target, which a
  `leave` maps with 8.3 into the target's shadow.
* Code: uses `d->changed` when it is non-empty, else `d->rect`. Per `observe.h:94..95` and
  `gdi_draw.c:565..573` (`sx = nXPos + t.ox`), `changed` is in **target-surface** coordinates (the
  virtual screen for a window DC: client origin added, and clipped to the visible region), while
  `rect` is in **DC** coordinates (client coordinates). `engine_copy` and `note_unexplained` use
  `rect`.
* Sequence: a bracket whose target is a window (a logical dialog, an N scene window) at client
  origin (100, 80). A suppressed `FillRect(10, 10, 50, 50)` records (110, 90)-(150, 130). A second
  suppressed draw fully covered by another window has an empty `changed` and records its `rect`
  (10, 10)-(...). `b->changed` is now the union of a screen rectangle and a client rectangle; a
  `leave` that maps it (8.3) draws at the wrong place, or over a too-large area. For bitmap targets
  the two spaces agree (origin 0), but `changed` is still clipped where `rect` is not.
* Severity MAJOR (reachable for every window target as soon as a `leave` reads `changed`; no `leave`
  exists in D4a).
* Fix: record `d->rect` only (DC coordinates, as the rest of the engine), or convert `changed` to
  client coordinates before the union. Document which one `PdosBracket.changed` holds.

### S3 (MAJOR, design gap for D4b) A flush inside a leave-drawing bracket copies content not yet drawn
* `present/dos/pdos_shadow.c:829..845` (`on_draw` -> `do_copy`) with draft B 7.3 "Dropping" and
  8.2 (DrawShapeAndFlush, "DOS drawing at exit").
* Design 7.3 says that copies *from* a DROP target to another surface (the flushes to the window,
  `CopyPortToWindow`, `DrawShapeAndFlush` with `g_autoFlushToWindow`) are applied. The engine applies
  them when the BITBLT event arrives.
* For a macro that draws at `leave` (all of B's replay, 8.2), the flush happens **inside** the
  bracket, before `leave` has drawn the DOS version into the target shadow.
* Sequence: DrawShapeAndFlush(port P, x, y, shape) with auto flush on. Entry opens the B bracket
  (target pending). The core's shape blit to P binds the bracket to P and is dropped. The core's
  flush P -> window W arrives and `engine_copy` copies P's shadow **without** the shape into W's
  shadow. At exit, `leave` draws the DOS shape into P's shadow. No further flush follows, so W (the
  shown surface) lacks the shape until the next flush of that square.
* D's macros draw at `enter` (from state), so the rule works for them; it fails for every `leave`
  drawer whose function flushes itself.
* Severity MAJOR (wrong frames in normal use once D4b registers such a macro; not reachable in D4a).
* Fix: in `on_draw`, when a BITBLT's **source** is the target of an open, unmuted DROP bracket whose
  macro has a `leave`, queue the copy in that bracket and apply the queued copies in order after
  `leave` at its exit. The alternative is a design note that 8.2 leave-drawers must redo their own
  function's flushes in `leave`. Either way, D4b needs the rule written down.

### S4 (MAJOR) The N-canvas binding aliases page 0 and never detaches
* `present/dos/pdos_shadow.c:385..393` (`pdos_shadow_get`), `434..437` (`pdos_shadow_set_n_window`),
  `920..925` (window destroy); `present/dos/pdos_profile.c:51..63` (`update_n_window`).
* Design 7.2: "The N canvas is the shadow of the **current** N scene window's client ... is page 0 of
  `pdos_mn` (no copy). A smaller client sits at its logical position inside page 0; a larger one is
  clipped (counted)."
* Code: whether a window shadow is page 0 is decided once, when the shadow is created lazily, by
  `key == g_nwin`. `pdos_shadow_set_n_window` only stores the handle. A shadow made on page 0 keeps
  page 0 after its window stops being the N window. A window that becomes the N window after its
  shadow was made keeps its private surface, which nothing composes. A smaller client is a private
  surface, never placed in page 0.
* Sequence: N row 1 binds logical dialog A (512 x 320); A draws, so A's shadow is page 0. A nested
  logical N dialog B (512 x 320) opens; its row binds and `g_nwin = B`; B draws, so B's shadow is
  also page 0. Two shadows now alias one surface. A WM_PAINT or a timer redraw of A (under B)
  writes into page 0 over B's scene. When B is destroyed, page 0 keeps B's pixels as A's content
  until A repaints all of them.
* The record defers "the N-canvas window binding of 7.2 beyond `update_n_window`" to D5. This
  finding says that the present mechanism cannot be extended as it is: it must be replaced.
* Severity MAJOR (two concurrent logical N windows; whether WI 4.2's dialogs nest was not checked
  here).
* Fix: keep at most one shadow attached to page 0. On a change of `g_nwin`, detach the old one
  (give it a private surface with a copy of page 0, or free it) and re-attach the new one (copy its
  private content into page 0 at its logical position, clipped and counted).

### S5 (MAJOR, latent until D's `--mirror 2`) DOS-only brackets drop the Windows-rule shadow's events
* `present/dos/pdos_shadow.c:727..739` (`drop_event`), `838..841`.
* Design 7.5 table, row "other drawing to P, S, Wn outside D's macros": inside a B replay bracket,
  B's `leave` draws on the DOS shadow, and "the Windows shadow gets nothing from B and goes to D's
  `on_draw`". 7.5 "Rule sets": "B's replay never touches" a Windows-rule shadow.
* Code: `drop_event` ignores `PdosMacro.rule_sets`. Any DROP bracket on the surface drops the event
  for **both** rule sets, and `on_draw` returns before the rule-set loop. So D's WIN-rule `on_draw`
  never sees events that B's DOS-only bracket suppresses.
* Sequence (`--mirror 2`): FillRectLogical on the map port P inside B's replay bracket (rule set DOS
  only). The event is dropped: the DOS shadow gets B's `leave` (right), and the WIN shadow of P gets
  nothing (wrong; D's `on_draw` should replay it).
* Severity MAJOR once D registers WIN-rule owners; not reachable in D4a (no owner registers).
* Fix: make the drop per rule set. `drop_event` returns a mask of the rule sets suppressed (the union
  of `rule_sets` of the DROP brackets on the target); in `on_draw`, only the rule sets outside that
  mask go to the hooks or are counted as unexplained.

### S6 (MINOR) A pending outer bracket that binds late can take a surface an inner bracket already owns
* `present/dos/pdos_shadow.c:680..699` (`bind_pending`), `990..992` (`push_bracket`).
* Design 7.3 / Choice B20: "the outermost open DROP bracket on a surface owns it"; an inner bracket on
  the same surface is muted.
* Code: muting is decided once, against the brackets that already have a target. An outer bracket
  whose target is still pending (macro `target` NULL) does not mute an inner named-target bracket
  opened before the outer one binds. When the outer one binds to the same surface, `owned_by_outer`
  looks only below it and leaves it unmuted. The inner one stays unmuted too.
* Sequence: an outer B replay macro (target NULL) is open. An inner D macro (DROP, target P) opens
  unmuted, and its `enter` draws from state. The first event to P binds the outer bracket to P,
  unmuted. Both `leave`s run, and B's replay draws over D's macro.
* Severity MINOR: B's pending-target macros are leaf primitives (8.2), so this needs a scene-level
  macro with a NULL target around a named one.
* Fix: in `bind_pending`, after binding bracket i to (kind, key), set `muted = 1` on every bracket
  above i with the same target (their `enter` has run; skip their `leave`). Alternatively, refuse
  NULL-target macros that are not leaves.

### S7 (MINOR) Open brackets keep a freed or reused handle as their target
* `present/dos/pdos_shadow.c:439..448`, `884`, `888`, `918`, `921`.
* Design 7.1: the shadow lives from create to delete. A reused handle "starts again" (the code frees
  at create).
* Code: `free_surface_shadows` frees the shadows but leaves `g_br[].tkind/tkey`. While the bracket
  is open, events to a **new** surface with the recycled handle are dropped and recorded into the old
  bracket, and its `leave` (`pdos_shadow_find` at exit) draws into the new surface's shadow.
* Sequence: a DROP bracket targets bitmap 0x1234. Inside it, the core deletes 0x1234 and creates a new
  bitmap that gets 0x1234. The first draws to the new bitmap are dropped, and `leave` paints the old
  macro's drawing on it.
* Fix: in `free_surface_shadows`, mark brackets on that (kind, key) as detached. They neither drop nor
  call `leave`; count the case.

### S8 (MINOR) `pdos_shadow_rebind` does less than 7.1 asks; no caller yet
* `present/dos/pdos_shadow.c:946..959`.
* Design 7.1 (GR_PortDataToBitmap): the shadows of the old bitmap move to the new handle; "a
  different size calls the owner's `on_resize`".
* Code: moves `key` only. It does not compare or update the size (`g_bw/g_bh` of the new handle,
  `dev_w/dev_h`), does not call `on_resize`, and does not retarget open brackets or the registry. The
  record lists the wiring as left (D6). This note is so that D6 does not take the function as
  complete.
* Fix: take the new handle's size from `g_bw/g_bh`. When it differs, call `resize_shadow`, which calls
  `on_resize`. Retarget open brackets with the old key.

### S9 (MINOR) Re-registering macros while brackets are open shifts `g_br[].mac`
* `present/dos/pdos_shadow.c:510..543`.
* Code: `pdos_shadow_macros` rebuilds `g_mac` (other owners first, then the new table), so a bracket's
  `mac` index can name another macro. Then `leave` calls the wrong function with the wrong context,
  and `owned_by_outer` reads the wrong flags.
* Design 7.3: modules register "when [they are] reset", in any order. That is safe only if no
  bracket is open at that moment. `pmap_reset` runs at `present` initialisation after the profiles'
  reset, so this is not reached today.
* Fix: refuse a registration (or close all brackets without `leave`, counted) while `g_nbr > 0`.
  Store the owner and the macro pointer in `Br` instead of an index.

### C1 (MINOR) One surface used by two elements loses damage on one of them
* `present/dos/pdos_compose.c:281`, `355` (`pdos_surf_take_damage` in `refresh_n` / `refresh_a`).
* Design 6.1, 6.2: damage includes "element damages scaled by k". The `PdosElem` contract says
  "`s` stays the caller's; its damage is taken at every composition" and does not forbid sharing.
* Code: the damage of a surface is taken by whichever canvas is refreshed first. If an R box is set as
  both an N and an A element with one surface (11.3 places R boxes on both canvases), drawing while N
  is shown is consumed by `refresh_n`. After the kind changes to A, `refresh_a` sees no damage. The
  host redraws the whole client, but from a `g_af` that was not recomposed there, so it shows the old
  box.
* Fix: state in `pdos_compose.h` that one surface belongs to one element, or keep a per-element
  `gen` (the surface's `gen` at the last composition) and damage the whole element when it differs.

### P1 (MINOR) `update_wover` assumes the N scene window is top-level
* `present/dos/pdos_profile.c:85..103`.
* Design 6.4: count "the visible top-level windows above the N scene window".
* Code: walks the desktop's children from the top until `h == scene`. If the scene window is a child
  (WS_CHILD dialog) or an owned window not in the desktop's child list, the loop never meets it.
  Every intersecting top-level window, including the main frame below it, is then counted, so the
  profile shows the A frame for the whole scene.
* Whether any N-scene dialog is a child window was not checked here.
* Fix: compare against the scene window's top-level ancestor (follow `parent` until it is the
  desktop) and stop there.

### F1 (MAJOR, latent until D7) The 10.1 row "id 7 at the report header sites -> DOS font 1" is missing
* `present/dos/pdos_fontmap.c:16..34`.
* Design 10.1 table, row 3: id 7 at the report header sites (O14 frame counterparts) -> DOS font 1,
  inferred (DOS-PROFILE F7 also says "report headers: ... DOS current font").
* Code: no such row. The rule row `{1, 8, 0, 0}` maps every id 7 to font 7. The record lists neither
  the omission nor an open item.
* Sequence: a report header drawn after SetCivFont(7) at a report site: `pdos_fontmap_current()`
  answers 7 instead of 1. The header is in the CIVTIMES-like font 7 instead of the font in effect.
* Fix: add the report-header SetCivFont sites with `dos = 1` (`PDOS_FM_INFERRED`). If the sites are
  not yet enumerated, record it as an open item for D7 and add a test that fails until then.

### F2 (MINOR) The font tracker is global, not per graf, and the leader index is inferred
* `present/dos/pdos_fontmap.c:47..50`, `121..163`, `92..93`.
* Design 10.1 "Tracking the Windows id": logical text reads word +10h of `g_pScreenPort` at entry;
  other text uses the last SetCivFont id "set on the current graf (`g_graf` ..., read at the
  SetCivFont probe)", or SetTextFontSizeColor's (id, size). Leader faces: `t = g_playerCivId[n]`
  (read with `w16q_rd16`), `b = LEADER_FONT[t]`.
* Code: one global (id, ra). It does not record `g_graf`, so SetCivFont on port A, then on port B,
  then text on A answers B's font. The size of SetTextFontSizeColor is dropped. Leader faces use
  `g_leader[id - 200]` ("the tribe is id - 200 (inferred)") instead of `g_playerCivId[n]`. That is
  equal only if the Windows face id is always 200 + `g_playerCivId[n]`, which is not shown (and 10.1
  names 207 and 213 separately).
* Severity MINOR (no consumer in D4a). D4b's replay must read the port's word +10h for logical text,
  as 10.1 says.
* Fix: key the tracker by the `g_graf` value read at the probe. Record the size. Either implement the
  `g_playerCivId` read or record the `id - 200` equivalence as a deviation, with its evidence.

## Observations (no severity)

* **O1 Page 0 is attached without clearing.** `pdos_shadow_get` (line 389) makes the N window's
  logical shadow on page 0 as it is, while private shadows start black (7.1, 7.5 "starts black").
  Areas that the replay never draws keep the previous scene's DOS pixels. This may be intended (11.5:
  N pages drawn before the core's dialog exists), but no section says so.
* **O2 Cost.** `update_n_window` and `update_wover` (`pdos_profile.c:140..141, 173..174`) run after
  every event and probe, including every `OBS_DRAW`, and walk the stack and the top-level window
  list. This is correct and deterministic, but it is the profile's largest per-event cost.
* **O3 `PdosBracket.text` is read at event time** through `q_read` (`w16q_read`) of
  `d->text_vptr`, which `observe.h:103` guarantees only during the callback. Correct as written:
  the bytes are copied immediately.

## Confirmed correct

Each item was traced against the design section named.

**pdos_profile.c (2.1, B22, B24, O6)**
* `dos_on_event`: scene stack, then (C), then shadow engine, then the window/overlay updates and
  the pointer. Matches 2.1 rows 1..4; `pdos_compose_on_event`'s screen-size duty is done by
  `refresh_a` from `core->w/h`.
* `dos_on_probe` entry: scene push, then (C), font map, shadow engine, then the play cycle step.
  Exit: (C advance), shadow engine (`leave` sees the returning row), font map, the WdwMapOpen play
  palette, then the scene pop. This is exactly 2.1's entry and exit rows and Choice B24.
* O6: no callback tests visibility. `present.c` calls `on_core_present` (lines 186..189) and
  `advance` (lines 622..626) for every registered profile, and `on_event`/`on_probe` arrive through
  observer listeners registered for every profile (lines 395..416). The cursor's `changed` state
  (`g_cur_reported`, `g_cur_gen`) is the only state that only the visible path touches. It affects
  only re-issuing, and `cursor_issue` re-issues unconditionally at a switch (`present.c:321..336`,
  `616`).
* `dos_reset`: every B module's reset, the page-2 art of both machines, the first play palette, then
  the pointer. `dos_frame`/`dos_peek`/`dos_indexed`/`dos_input_frame` only compose.
* P0: the only emulation reads are `w16q_wnd`, `w16q_wnd_first`, `w16q_wnd_next`, `w16q_desktop`,
  `w16q_cursor` (profile), `w16q_dc`, `w16q_wnd`, `w16q_read` (shadow) and `w16q_arg16` (font map),
  all inside `#if CIV_OBSERVER`. No write to emulation memory, no post or send, no `g_randSeed` in
  any of the six files.

**pdos_shadow.c (7)**
* `pdos_shadow_find`, `make_shadow`, `free_shadow` (owner's `on_free` before the surface is freed;
  an external surface is not freed), `pdos_shadow_reset` (keeps registrations, resolves call sites
  again).
* `pdos_shadow_get`: owners asked first in registration order, filtered by their `rule_sets`; B's
  table only for the DOS rule set; logical dialogs 130/142/143/144/146..149/151 by the template
  recorded at `OBS_DLG_CREATE`. `OBS_DLG_CREATE` follows `OBS_WND_CREATE` (`user_dlg.c:784`), so the
  reset of `g_wdlg` at window creation cannot erase it. 512 x 320 maps to exactly 320 x 200.
* Mapping: `pdos_shadow_dev_to_px`, `px_to_dev`, `map_rect` (LOGICAL `[L(l), L(r - 1) + 1)`; HALF
  `floor(x / 2)`, `ceil(r / 2)` as 7.4; MAP identity), `pdos_shadow_logical_size` (ceil(10 d / 16)),
  `floordiv` for negatives.
* `engine_copy`: destination mapped and clipped to the surface, source mapped per pixel by the
  destination's mapping (nearest, `res_mismatch` counted), out-of-range source pixels keep the
  destination, and the read is completed into a temporary before writing, so a copy within one
  surface is overlap-safe (7.4: mirrors BitBlt, not G#20). It damages the destination (page 0 damage
  reaches the N frame).
* `do_copy`: `on_copy` of either end's owner first; SRCCOPY between shadows copied; another ROP or an
  unshadowed source is unexplained. A ROP inside a DROP bracket on the destination is dropped before
  this (7.4 row 3).
* `on_draw`: target binding, drop, copy, then the owner's `on_draw` only outside a DROP bracket on the
  surface (7.5), otherwise unexplained (7.6).
* `push_bracket`: `target` 0 means no bracket; outermost-owner muting for named targets; `enter` per
  rule set with a shadow (created if needed), once with `dst` NULL for a pending target.
* `pdos_shadow_on_probe` entry/exit pairing by (id, ra) with a group per entry. The call-site filter
  uses `ObsProbe.site`, which `obs_probe` recomputes at the exit too (`observe.c:69`). Exits of an
  unmatched call site are ignored (deviation 8). `leave` runs in reverse push order and is skipped
  for muted brackets. The exception is S1.
* `pdos_shadow_context`, `check_macro` (DROP or CONTEXT required, exit phase required, `ra`
  resolved), `pdos_shadow_macros` (others' macros kept, invalid ones counted and skipped),
  `note_unexplained` ring (last 16, oldest first, innermost probe).
* `resize_shadow` / `OBS_WND_RECT`: a non-external shadow is reallocated black (`pdos_surf_resize`
  then `pdos_surf_init`, damage whole) and `on_resize` is called; the external page-0 shadow is
  dropped and made again.
* Determinism: the shadow table is a flat array scanned in index order (no hash table); every
  decision depends on the event and probe stream and the emulation state read at that moment; no
  timer, visibility or host input is read.

**pdos_compose.c (6)**
* `pdos_compose_kind`: 6.3 items 1..3 in order; item 2 uses `pdos_scene_wants_n` (top non-R row is N
  and ready) and `g_wover`.
* `refresh_n`: DAC change damages the whole 320 x 200; page-0 and N-element damage scaled by k;
  element palette generation; the base is redrawn under the elements before they are drawn
  (transparent index 0 correct).
* `refresh_a`: the core frame itself while no A element exists (whole damage on the transitions 0 -> 1
  and 1 -> 0 elements); otherwise base copy in the damaged rectangle plus elements; play-table change
  damages elements that use it; screen-size change recomposes all.
* `frame_of` / `pdos_compose_frame` / `pdos_compose_peek`: peek composes but keeps the damage, so any
  number of peeks gives the same frame and the next take returns the union (7.4). Damage that arrives
  while the other kind is shown stays in the surfaces and in `g_core_dmg` until that kind is
  refreshed.
* `pdos_compose_elem_set/remove/damage`: old and new areas are damaged; the z order is kept on
  replace.
* `pdos_compose_indexed`: page 0 itself when no N element is visible, else a composed copy with the
  same transparency and clip rules as `draw_elem`; the table through `pdos_dac_to_rgb8`.
* `pdos_compose_set_wover`: counts the first case of a run, only while an N scene would show.

**pdos_scene.c, pdos_scene_tab.c (9; deviations 1..3)**
* Deviation 1: keys are `OBS_P_*` row numbers, `PDOS_NO_KEY` = 0xFFFF; `PDOS_AT_ENTER/EXIT` equal
  `OBS_ENTER/EXIT` (`observe.h:134`), so `exit_at` can be compared with `p->phase` and masked with
  `obs_probe_phases`.
* Deviation 2: rows 2 (SeekSequence entry from 11E0:0889), 5 (BeginWorldCreation exit, call site
  11E0:01B2), 9 (DestroySequencePlayer entry from 11E0:01E8) and 98 (CloseReportScreen entry) are
  encoded as the record says; `pdos_scene_reset` checks the phase and resolves `exit_ra`.
* Deviation 3: the pop scan goes on below a popped slot; `own_done` pairs a return with one entry,
  so the return of BeginWorldCreation pops row 5 (configured exit) and row 3 (own exit), and a
  recursive entry pops one level per return. A bound window row is not popped by its function's
  return; a still-pending one is.
* `best_row` (call-site rows beat wildcard rows, then the lowest row), `push_row` (depth 16,
  counted), `pop_to` (listener per popped row, top first), re-targeting by template on
  `OBS_DLG_CREATE` (old row "exited", new row "entered"), window-destroy pops, `wants_n`,
  `top_non_r`, ready flags. All of them are deterministic.

**pdos_fontmap.c (10.1)**
* Site rows beat the rule row (`lookup`); ids 1..8 keep their number; 333 and 216 not drawn; an
  unmapped id gives font 1 and counts `font_unmapped`; `pdos_leader_font` = 8 + b with 10 -> 3
  (b = 0, 1, 2 gives 8, 9, 3); the coverage log (id, site, font, count) is capped at 64 pairs.

## Not reviewed

* `pdos_scene_tab.c` row by row: only the header, the `ROW` macro, rows 1..13 and the four
  configured-exit rows (2, 5, 9, 98) were read. The other rows' classes, keys, call sites, templates
  and adapters are left to `pdos_scene_check.py` (1075 checks) and `obs_lint.py`.
* The return addresses of the font map's site rows (`0x10680A0E` and the others) against the core's
  SetCivFont calls (`pdos_scene_check.py` checks them).
* Whether WI 4.2's logical dialogs can nest (S4) or are child windows (P1); whether any probed
  function can be left without its exit probe (S1). These need the core or WI, which were not read.
* The unit tests (`test_pdos_shadow.c`, `test_pdos_compose.c`, `test_pdos_scene.c`,
  `test_pdos_profile.c`) and their vectors; design 8 (replay) apart from the 8.2 rows that S3 needs;
  6.6 and 6.7 beyond the profile's cursor callback; `pdos_cursor.c` (covered by the first review).
* Test gaps seen in passing: no test covers a lost inner exit (S1), a window-target bracket's
  `changed` (S2), a flush inside a `leave`-drawing bracket (S3), two logical N windows (S4), or a
  WIN-rule owner under a DOS-only bracket (S5).

# Extension phase D5, unit D5a (the N-window binding and the sequencer's title-branch and setup states) - record

Draft of the staging implementer (session E3, 2026-10-15), written in `build/d5a-stage/docs/`; the build
slot moves it to `claude/port/docs/ext-D5a-record.md` and completes "Status" and "Results (build slot)".

Authority: `docs/verify/BRIEF-d5.md` (decisions and the orchestrator's Rulings; unit D5a), the Rules of
`BRIEF-d4.md`, `EXT-HANDOFF.md` "Session E3", `ext-D4-acceptance.md`; design: draft B 7.2 "Open for D5" (the
D4a second review's S4, O1, O2, O3, P1), 7.3 (S3); draft C C.11.2, C.11.3, C.11.4 (Open C-3), C.11.6;
`ext-D4b2b1-record.md` Deviation 3 (the C.11.2 rows D4 left), `ext-D4b3-record.md`, `ext-D4c2-record.md`.

## Status

Staged in `build/d5a-stage/` (full copies of 11 files, `BASE-SHA256.txt`); nothing in the tree, no build.cmd
or test.cmd change (`BUILD-TEST-ADDITIONS.md`).  Private checks over an overlay of the tree and the stages
before it that change C sources (BS12, BS34 and the UX1 files BS34 built with; CY changes none; D4cF was in
progress and is tried separately): see "Results (private)".  The build slot's three-step cycle has not run
on it.

## What was built

### S4 with O1: the N-window binding (`present/dos/pdos_shadow.c/.h`)

D4a decided once, at a window shadow's lazy creation, whether a 512 x 320 logical window's shadow *was*
page 0 of `pdos_mn()` (the alias, when the window was the N window then), and dropped the page-0 shadow of a
resized window; nothing ever detached it.  Two logical dialogs could both alias page 0, and the lower one's
redraw while the upper was the N window went onto the upper's screen (the second review's S4).

Now every logical window shadow has its own private surface, and **at most one is attached to page 0**: the
N window's (`g_att`).  `pdos_shadow_set_n_window(hwnd)` (the profile calls it after every event and probe,
as before) detaches the old one on a change and attaches the new one as soon as its shadow exists (at once,
or at its lazy creation in `pdos_shadow_get`):

* **detach**: pending changes are copied first; then page 0's part under the client is copied into the
  private surface, which is the window's surface again (its later drawing stays private);
* **attach**, 320 x 200 logical client (512 x 320 device): it sits at (0, 0) and its surface *is* page 0, no
  copy (7.2's case, as D4a);
* **attach**, any other size: it sits at its **logical position**, the new fourth query
  `PdosShadowQ.wnd_place` (the client's offset from the 512 x 320 rectangle centred on the desktop's client,
  where a 320 x 200 logical dialog sits; default `w16q_wnd` under the observer, nothing without it, so (0, 0))
  mapped by L(d) (8.3).  It keeps its own surface; each change is copied into page 0 after the engine's
  event or probe (`n_sync`, also at `pdos_shadow_set_n_window`), clipped; a client that does not fit counts
  `pdos_diag` **`n_clip`** once per attach;
* **O1 decided: page 0 is never cleared at an attach.**  The private surface is copied into page 0 only when
  it changed after the shadow's creation, resize or last detach (it was drawn while it was not the N
  window); otherwise page 0 keeps what it shows and the window takes it over as it is (draft B 11.5's
  takeover without a redraw: the DOS screen stays until the DOS view draws over it).  Clearing would blank
  the DOS view's own drawing (the intro, Birth, the title box) whenever the core's N window changes under it;
  copying an unchanged private surface would bring back the stale Windows pixels of an older screen;
* a resized attached window is detached, resized (black, no content) and attached again; a destroyed
  attached window leaves page 0 as it is.

`pdos_shadow_logical_template(tmpl)` (7.2's templates 130, 142, 143, 144, 146..149, 151) and
`pdos_shadow_n_attached()` (tests) are new.  The `n_clip` counter is `PDOS_DIAG_N_CLIP`
(`pdos_common.h`, its name in `pdos_assets.c`'s table): `presentation-diag.log`'s `pdos` line gains
`n_clip N` at its end.

### Which window is the N window (`present/dos/pdos_profile.c`)

`update_n_window` takes the topmost N row with a bound window **of a logical-layer template** (7.2's table,
"else the topmost visible window of the logical-layer templates"); only those have a logical shadow to
attach.  D4a took any N row's window: dialog 139 (row 2, the title menu, not logical) over 148 made 139 the
N window, which had no effect then because 148's alias was already fixed; with S4 it would have detached
148.  Now 148 stays the N window under the title menu, as D4a's frames showed.

### P1: the generic fallback's window list (`pdos_profile.c`)

`update_wover` walks the visible top-level windows from the top down to the N scene window's **top-level
ancestor** (`top_level_of`: the parent chain up to the desktop, bounded at 32, 0 when a window of it is
unknown, then nothing is counted), not to the scene window itself; for a child scene window D4a's loop never
met it among the top-level windows and counted every window below it too.  Every 7.2 dialog is top-level,
so nothing changes for the current rows.

### O3: `OBS_DLG_CREATE` with more than one pending window-bound slot (`present/dos/pdos_scene.c`)

D4a looked at the topmost pending slot only: a template it did not name (and could not re-target to)
withdrew it even when a lower pending slot was the dialog's.  Now every pending slot is considered from the
top: the first whose row's template is the dialog's, or that the template re-targets among the rows of its
call site, is bound; only when none is, the topmost pending slot is withdrawn (as in D4a).  Every
window-bound row is a GR_DialogOpen 1098:124F entry, which creates exactly its own dialog, so in a correct
run the topmost slot is bound; a lower one is bound only when an inner push was spurious, which then pops
with its own GR_DialogOpen return.

### O2: the cost of `update_n_window` and `update_wover` per event

Measured privately (a timing copy of `pdos_profile.c` in the stage's overlay, `obj/o2patch.py`; never
staged): see "Results (private)", O2.  About 0.25..0.30 us per event or probe for both together
(`update_wover` four fifths of it), 13..26 % of the DOS profile's own callback time and 0.3..2 % of a
headless run's wall time.  Decision: no change of the call pattern (both still run after every event and
probe).  Calling them only after the events and probes that can change the scene stack or a window would
save at most those 2 % and would have to prove that no change is missed (scene pushes and pops happen at
probes, window changes at events); revisit if D5..D7's renderers make the window walk costlier.

### The sequencer: C.11.2's rows that D4 left (`present/dos/pdos_seq.c/.h`)

New call-site rows (all in `OBS_CALLSITES`, resolved at the reset): GR_DialogOpen exits at ra 1108:0290
(dialog 143), 10E8:0067 (144), 10E8:10BE (151); RunTextInputDialog 1220:16FD at ra 10E8:056F (entry and
exit).  New `PdosCore` fields (read only for D5b..D5f; the block "extension D5a" at its end):

* the dialogs: `dlg_custom` (143), `dlg_setup` (144), `dlg_intro_text` (151) and, corrected, `movie_wnd`
  (148): the window of the dialog **created inside** that GR_DialogOpen call (`OBS_DLG_CREATE` with the
  expected template since the call's entry), each forgotten at its `OBS_WND_DESTROY`.  GR_DialogOpen returns
  only its status in AL (1098:1604), so D4b2b1's `movie_wnd = AX` was the status, not the window (Deviation
  1);
* the MenuZ children (`OBS_WND_CREATE` while a MenuZ runs): `mz_dlg`, the parent of its first static 400
  ('RanDomStatic', 1220:0156 header step 6) or radio 500..520 (CreateWindow at 1220:09B0), and `mz_items`,
  its radios; Go Back, control 102 of a dialog, from its creation style (WS_DISABLED) and `OBS_WND_ENABLE`
  (MenuZ 1220:07B6..080E enables or disables it), `mz_goback` at the MenuZ's first key poll (1, 0, -1
  unknown); `mz_sel` stays g_menuSelection read at the key poll (D4b2b2; the core emits no `OBS_CTL_CHECK`,
  Deviation 2);
* the EDIT control 450 (RunTextInputDialog creates it and gives it the focus): `edit_wnd`, `edit_focus`
  (`OBS_FOCUS`), `edit_events` and `edit_t_us` (`OBS_FOCUS` and `OBS_EDIT` on it: C.9's text-entry cursor
  restarts its phase at each);
* `setup_mz_result` / `setup_mz_step` (the setup MenuZ's AX at its exit and the step it was), `text_active`
  / `text_result` (RunTextInputDialog: 1 OK, -1 Go Back, 1220:1928), `branch_result` (AX of Load's or
  Customize's exit).

### C.11.3: the title's branches

LoadGameFromFileDialog's exit (ra 11E0:0807) returns to TITLE only when cancelled (AX -1, 11E0:0808);
CustomizeWorldDialog's (ra 11E0:0826) only when not confirmed (AX != 0, 11E0:0829); ShowHallOfFame's (ra
11E0:0847) always.  Otherwise the scene stays LOAD / CUSTOM until the core goes on: Load to play
(GR_DialogClose ra 11E0:0217: PLAY, as D4), Customize to its outro (SeekSequence ra 11E0:0889: OUTRO) and
Birth.  D4b2b1 set TITLE at every branch exit, which a chosen game or a confirmed world contradicted.
RunNewGameSetup's entry (SETUP) and exit (PLAY) and GR_DialogClose were D4's already.

### C.11.4: the setup steps (Open C-3 settled against RunNewGameSetup 10E8:0000)

`setup_step` (read by `pdos_pend.c`'s MZ_READY(setup, step) since D4c2) is now identified:

* at a setup MenuZ's **first key poll** (IsKeyPending ra 1220:0AA5; its radios and Go Back exist by then,
  1220:09B0 and 1220:07FC/080E come before 1220:0AA0): more than five radios is step 2 (the tribe list:
  "Custom." and two names per civilization); otherwise Go Back disabled is step 0 (g_dialogMenuMode -1,
  10E8:01F1), enabled step 1 (mode 1, 10E8:0280; step 2's at 10E8:0376); an unknown Go Back keeps the step
  and counts PDOS_DIAG_SEQ;
* at RunTextInputDialog's entry (ra 10E8:056F): step 3 when the last setup dialog to return was the step-2
  MenuZ with result 0 ("Custom.": no skip at 10E8:092E), else step 4 (step 3 is skipped going back,
  10E8:05E3).

So the alternative C.11.4 named (counting the setup dialogs) is not needed: the step comes from the
dialog's own controls, which survives Go Back in any order.  Observed in the private harness runs (a state
trace of the timing copy, `new`, `s3`, `earth`, `custom`, `birth`): the setup MenuZ's dialog is dialog 144
itself (`mz_dlg` = `dlg_setup`), five radios with Go Back disabled (step 0), five with Go Back enabled (step
1), fifteen radios (step 2), result 1 (a civilization) and RunTextInputDialog as step 4 with the EDIT
control focused, its OK (1), then dialog 151.  No scenario takes "Custom." (step 3) or Go Back; those are
covered by the unit tests only.

### C.11.6 for the new states

An unexpected order (the running DOS sequence abandoned, PDOS_DIAG_SEQ, as C.11.6): a setup MenuZ,
RunTextInputDialog, or the exit of dialog 144 / 151 outside SETUP; dialog 143's exit outside CUSTOM; a title
branch's entry outside TITLE.  No dialog, or one of another template, at one of the dialog call sites only
counts PDOS_DIAG_SEQ and leaves that window 0 (Deviation 3).

### S3 (draft B 7.3): stays open for D6

No D5a macro draws at `leave`, and D5a adds no macro.  The D5 scenes are drawn by their renderers and the
sequencer from probes and events; a D5 unit that adds a macro drawing at `leave` must resolve S3 first
(option (a) or (b) with its vector), otherwise S3 stays open for D6.

### `pdos_compose.c/.h`: unchanged

The frame kind (`pdos_compose_kind`) and the N frame read page 0 and the scene rows' readiness, not which
shadow is page 0, so S4 needs no compose change; `test_pdos_compose.c` passes unchanged.

## Tests

* `tests/test_pdos_shadow.c`: the fourth query injected (`q_place`); `test_n_binding`, S4's vector: two 512
  x 320 logical dialogs (144 lower, 151 upper), the lower one drawn as the N window, the upper becoming the N
  window (the lower detached with page 0's pixels, page 0 not cleared), a redraw of the lower one while the
  upper is the N window (private only), the upper's destruction and the lower attached again (its redraw
  copied in); an attach without a redraw (page 0 kept, O1) and the repaint reaching page 0; a smaller client
  (143, 400 x 240) at its logical position (64, 32) device = (40, 20); a larger one (142, 640 x 400) at (-20,
  0), clipped and counted once; no N window.  `test_window_and_n`'s D4a expectation "a resized N window: the
  page-0 shadow is dropped" changes: window 9 was detached when 10 became the N window, so its resize keeps a
  private shadow, black at the new size; the 640 x 480 N window 10 is attached at (0, 0), its clipping
  counted once.
* `tests/test_pdos_scene.c`: `test_o3`: dialog 144 binds the lower pending slot under a spurious one (D4a
  withdrew the upper and left the lower pending), the spurious slot pops with its own return; the upper slot's
  re-target is tried before a lower slot; an unknown template withdraws only the topmost pending slot.
* `tests/test_pdos_seq.c`: `test_d5a_setup` (steps 0, 1 (Go Back enabled after its creation; only the first
  poll counts), 2, 3 after "Custom.", 4, Go Back back to the tribe list, a civilization (4 directly), Custom
  again (3); the EDIT control, its focus and changes; dialogs 144 and 151 and their destruction; no
  PDOS_DIAG_SEQ; PLAY at the exit); `test_d5a_branches` (Load cancelled / chosen, Customize not confirmed /
  confirmed then the outro, the Hall of Fame, dialog 143); `test_d5a_unexpected` (C.11.6: a setup MenuZ in the
  running intro, branches outside TITLE, RunTextInputDialog and dialogs 144 / 151 / 143 out of their scene,
  dialog 139 or none at the movie's call site (counted, the intro runs on), no Go Back known).
* `test_pdos_profile.c` (UX1 changes it too) is not changed by D5a: its `PdosShadowQ` initializer names
  three members, the fourth is NULL (the default, `w16q_wnd`; nothing is placed for its 512 x 320 window),
  and its 512 x 320 N window is still page 0.

## Results (private, `build/d5a-stage/obj/`)

Labels: static compile checks and headless unit tests and harness runs of this port; no original program,
no DOS program, nothing of the tree or a shared output folder written.

* **Overlay** (`obj/mkoverlay.py`): the tree, BS12's stage (host_win32.c as the tree's copy with BS1's
  block), UX1's present.c/.h, profile.h, scale.c/.h and test_present.c, BS34's stage, then this stage.
  UX1's other files (pdos_cursor.c/.h, arrive.c, input.h, host_win32.c/.h, test_pdos_cursor.c,
  test_pdos_profile.c, test_host_win32.c) are not in it; none overlaps D5a's files, and UX1's change of
  test_pdos_profile.c is its pointer checks only (its `PdosShadowQ` initializer and N-window check are the
  tree's).
* **Strict compile** (`obj/cc.cmd strict`, build.cmd's flags: /std:c11 and /std:c17 /W4 /WX, the clang-tidy
  C99 `-pedantic -Wall -Wextra` parse) of pdos_shadow.c, pdos_scene.c, pdos_seq.c, pdos_profile.c,
  pdos_assets.c: CC_STRICT_OK in Checked, CheckedNoObs and Release.
* **Everything built** (`cc.cmd all`: the portable sources, all 42 unit tests but test_ne, the harness, the
  Win32 host and civ64.exe): CC_ALL_OK in all three variants.
* **Unit tests** (argv `build\gamedata obj\test\<variant>`): 42 of 42 pass in each variant; the changed
  ones: test_pdos_shadow 157 / 155 / 157 checks (Checked / CheckedNoObs / Release), test_pdos_scene 136 /
  137 / 136, test_pdos_seq 170 / 170 / 170; unchanged and passing: test_pdos_profile 38 / 36 / 38,
  test_pdos_adapt 48, test_pdos_pend 102, test_pdos_compose 68.
* **obs_lint.py** over the overlay (`obj/lint_priv.py`, read only): OBS_LINT_OK files 97 probes 203
  callsites 98.
* **P0 and the DOS frames against the base** (`obj/hpriv.py`): the base build (the same overlay without
  this stage) and the D5a build ran ext_p0.py's 25 runs (its scenarios and gate3b's `s3`; not gate3b's
  s2/s2b/s2c save chain), scripts generated into `obj/h/scripts`, with V1's options (`--dos-data`,
  `--graphics dos`, `--presented 1`) and `--profile-samples 100`.  All 25: the core trace (run.log frame,
  snapshot and result lines, events.log) and the exit status equal the base's; **0 of the profiles.log
  sample lines differ** (every registered profile's frame at each sample, so no DOS frame changed);
  presentation-diag.log differs only by the new `pdos n_clip 0` and the host wall-clock fields
  `pmap snap_us` / `snap_turn_max_us`; `pdos seq` stays 0 (no D5a C.11.6 case fires on a real flow).
* **ext_timeline's goldens** on the D5a build (`start` with `--dos-watch`, `birth` with
  `--dos-birth-watch`): the 6 intro and 8 Birth golden frames equal ext-timeline-golden.txt.
* **O2** (the timing copy, QueryPerformanceCounter at 10 MHz; each interval includes one counter read):

  | run | events | probes | update_n_window | update_wover | profile callbacks | run wall | share |
  |-----|--------|--------|-----------------|--------------|-------------------|----------|-------|
  | start | 9,599 | 862,370 | 41.4 ms | 220.6 ms | 1,012 ms | 13.2 s | 2.0 % |
  | new | 24,628 | 1,064,447 | 52.1 ms | 271.5 ms | 1,240 ms | 28.9 s | 1.1 % |
  | orders | 27,610 | 938,753 | 64.7 ms | 217.1 ms | 1,330 ms | 26.9 s | 1.05 % |
  | menus | 71,015 | 1,168,842 | 59.9 ms | 251.0 ms | 2,409 ms | 105.2 s | 0.30 % |

* **The D4cF rebase trial** (`obj/mkmerge.py`, D4cF's stage as of this record): `git merge-file -p` (stdout
  only) gives 1 conflict in pdos_seq.c and 2 in pdos_seq.h, all adjacent insertions; kept both, D4cF's
  first (`obj/merge-trial2/resolved/`).  With D4cF's other staged files over the overlay, everything builds
  (Checked), all 42 unit tests pass (test_pdos_seq 170, test_pdos_pend 104, test_pdos_adapt 145,
  test_input 234, test_pdos_mouse 38 checks), the resolved pair compiles strictly (Checked, CheckedNoObs)
  and obs_lint passes.

## Deviations

1. **`movie_wnd` corrected** (D4b2b1/D4c1): it was GR_DialogOpen's AX, which is only the status (AL,
   1098:1604); now the window of dialog 148 created inside the call.  `pdos_adapt.c`'s movie default reads
   it as before; `test_pdos_adapt.c` and `test_pdos_pend.c` already synthesized `OBS_DLG_CREATE` 148 with
   the expected window, so their expectations are unchanged.
2. **No `OBS_CTL_CHECK`**: the brief lists it for `mz_sel`; the core's MenuZ emits none (D4b2b2), so
   `mz_sel` stays g_menuSelection read at the key poll.  `OBS_WND_CREATE` / `OBS_WND_ENABLE` /
   `OBS_WND_DESTROY` are used as listed.
3. **A missing or foreign dialog at a dialog call site only counts** PDOS_DIAG_SEQ (and leaves the window 0)
   instead of C.11.6's abandon: nothing of the flow depends on the window, and an abandon would end a running
   intro or Birth for a bookkeeping gap.
4. **Files beyond the unit's list**: `pdos_common.h` (`PDOS_DIAG_N_CLIP`) and `pdos_assets.c` (its name
   `n_clip`), for S4's "counted".
5. **`update_n_window` takes logical templates only** (7.2's wording); D4a took any N row's window (see
   above; no frame changes in the private comparison).
6. **`pdos_compose.c/.h` and `test_pdos_compose.c` unchanged** (listed in the unit's files; nothing to
   change).

## Rebase (the build slot)

The stage's copies are based on the tree, except `pdos_profile.c`, `pdos_seq.c`, `pdos_seq.h` and
`test_pdos_seq.c`, which are based on BS34's staged copies (BS34's delimited blocks are included).  D4cF
(landing order 2) staged its own `pdos_seq.c` / `pdos_seq.h` after these copies were made; merge its
delimited D4cF blocks into this stage's copies:

* `pdos_seq.h`: `uint32_t mz_polls` after `t_scene_us` in `PdosCore` (this stage adds its D5a block there
  too and changes the `movie_wnd` comment two lines above: keep both blocks, D4cF's first); the
  `pdos_seq_pend_cancelled` declaration block before "state (tests, D4b2b2)"; the title-box comment's
  "unless the shortcut's translation is cancelled" wording;
* `pdos_seq.c`: `TitleBox.pre_void`; `title_check`'s `&& !g_tb.pre_void`; the `pdos_seq_pend_cancelled`
  block after `title_again` (this stage's D5a helper block follows `title_again` too: keep both, D4cF's
  first); `g_core.mz_polls++` in on_enter's SR_MZ_READY branch (this stage adds `setup_mz_step()` and
  `g_d5.mz_polled` at the end of the same `if (g_core.mz_active)` block: keep both).

No other stage changes these 11 files.  A resolved trial of this merge (against D4cF's stage as it was) is
in `build/d5a-stage/obj/merge-trial2/resolved/` (see "Results (private)"); redo it if D4cF changes.

Line endings: the tree mixes them per file; every staged copy keeps its base's (CRLF: pdos_assets.c,
pdos_common.h, pdos_profile.c, pdos_seq.c, pdos_seq.h, pdos_shadow.c, test_pdos_shadow.c; LF:
pdos_scene.c, pdos_shadow.h, test_pdos_scene.c, test_pdos_seq.c).

## What needs the build slot

1. Rebase (above), copy the 11 files into the tree, move this record to `claude/port/docs/`.
2. The three-step cycle: `build.cmd checked`, `test.cmd checked`, `ext_g1.py check` (and the slot's usual
   variants).  test.cmd's `unit` section runs the changed tests by its `test_*.exe` loop (no list to edit);
   `d3a_obs_lint` checks the new `OBS_AT_EXIT(OBS_P_RunTextInputDialog)` (RunTextInputDialog has its exit
   phase in `obs_tables.c`).
3. Expected harness changes: **none** in any recorded expectation.  The private comparison found no DOS
   frame, core trace or golden change in any of the 25 runs, including those where dialog 144 follows 148
   as the N window (`birth`, `new`, `s3`, `earth`, `custom`): no current N renderer shows page 0 across such
   a change in a way the samples see, and no attached N window was clipped (`n_clip` 0);
   presentation-diag.log's `pdos` line gains `n_clip 0` (read by name).  7.3 (ext_p0) and 7.4 (ext_frames)
   compare runs with each other, so they are unaffected by construction; ext_timeline's goldens hold.

## For the records

* DESIGN.md 12.7 / 12.8: "As implemented (D5a)": the N-window binding (one shadow attached to page 0, O1:
  no clear, copy only a changed private surface, `wnd_place` / L(d), `n_clip`), N windows of logical
  templates only, P1, O3, the D5a sequencer state (C.11.2..C.11.4, C.11.6) and Open C-3 settled.
* Draft B 7.2 "Open for D5" (S4, O1, O2, O3, P1) resolved by D5a; 7.3's S3 stays open for D6 (above).
  Draft C C.11.4 Open C-3 settled (the step from the MenuZ dialog's radios and Go Back); C.11.6's new cases.
* `ext-D4b2b1-record.md` Deviation 3: the rows listed for D5 are implemented; `movie_wnd` corrected
  (Deviation 1 here).
* RUNNING.md (where the `pdos` diag counters are described): the new `n_clip` counter.
* No DOS-PROFILE.md, OFFSETS.md, FEATURES.md or manual-checklist change; no new user check (D5a draws no
  new scene).

## Landing (build slot, 2026-10-16)

D5 stager, in the build slot after the BS phase gate (`build/bs-status.txt` ALL_GREEN 00:10:04 UTC) and the
BS docs pass (`build/docs-bs-done.txt` 00:24:28 UTC).  One landing in the planned order: UX1b, then D5a + D5b,
then D5c (the latest copy of every file the three D5 stages changed).

* **Copy** (00:24:40 UTC, `build/d5l-prep/land.py`): 46 files, each only while the tree's file still had the
  expected SHA-256 (the base its copy or merge was made on; a new file had to be absent).  Manifest
  `build/d5l-prep/landed.sha256`; the tree's previous files in `build/d5l-prep/tree-before/`.
* **Rebase.** BS34 landed its staged copies unchanged for every file the D5 chain had based on them
  (`pdos_profile.c`, `test_pdos_seq.c`, `registry.py`, `ext-timeline-golden.txt`, ...), so 40 of the 46 files
  landed as staged.  `pdos_seq.c` / `pdos_seq.h`: the tree's (BS's merge of BS34 with D4cF, 918254a5... /
  199f161a...) is contained in D5c's copies: the change from the tree to D5b's merge (471a14fa... /
  7b0fdd69..., D5c's base) is D5a's own change (BS34's pre-merge to D5a) line for line, apart from one blank
  line (`build/d5l-prep/cmpdiff.py`), so D5c's copies landed as staged.  Three clean three-way merges
  (`git merge-file -p`, output to `build/d5l-prep/merge/` only, no conflict): `present/profile.h` (UX1b's
  comment on BS's file), `docs/DOS-PROFILE.md` (D5c's on the tree's UX1 paragraph and C2 row; base D4cF's
  staged copy) and `tests/harness/ext_timeline.py` (D5c's checks on BS's `bs_birth` / `bs_skip` scripts).
* **Regenerated / checked on the tree:** `gen/dos/registry.py gen` (159 files, 19 tables, unchanged) and
  `check` REGISTRY_OK; `gen/dos/adapters.py gen` (DOS-PROFILE.md unchanged by it: 1.7.2 with 75 rows) and
  `check` ADAPT_OK rows 75 steps 19; `gen/obs_tables.py --check` OBS_TABLES_OK probes 203 sites 98;
  `gen/dos/nodos.py check` NODOS_OK; `tests/harness/pdos_scene_check.py` PASS 1075 checks;
  `tests/harness/testpar.py check test.cmd` exit 0.  build.cmd and test.cmd are unchanged (the new sources and
  tests are found by their wildcards).
* **One fix at the slot** (the only failure): the first `test.cmd checked` failed one of its 24 sections,
  ext_continue: `FAIL dos: the DOS view follows the core into its setup: the 640x480 A frame shown at None
  us`.  BS4's check expected the A frame after Birth's hand-over; since D5c the DOS view shows the DOS setup
  page there (the same change as ext_timeline's `birth` 3 / `birth_skip`).  D5c's private harness did not run
  ext_continue, so its prediction did not list it.  `tests/harness/ext_continue.py` check 1 now requires
  timeline.log's `setup_page` step at the hand-over, the first DOS show within one second of it and every DOS
  show from the hand-over on the 320x200 N frame (re-evaluated over the failed run's outputs first: PASS, the
  setup page shown at 172402350 us).  No compiled source changed, so the cycle was rerun from step 2.
* **The cycle** (`build/d5l-status.txt`, logs `build/d5l-<n>-<step>[-r2].log`):

| step | result |
|---|---|
| 1 `build.cmd checked` | exit 0, BUILD_OK, 283 portable sources (c11, c17, c99 parse).  The build ended at 00:34:39; the step's 727 s include the wait for the compiler's telemetry helper (vctip.exe), which the build left running and the cycle's process wait included, until it was stopped at 00:43 |
| 2 `test.cmd checked` | first run exit 1 (ext_continue, above); rerun `-r2` exit 0, TESTS_OK, 24 sections, 0 failed, 1043 s |
| 3 `ext_g1.py check` | `-r2` exit 0, EXT_G1_OK runs 77 (amended 1: game/p4-menus frames events) |

ALL_GREEN at 01:20:28 UTC.  Only the Checked variant ran (the slot's three steps); CheckedNoObs and Release
were built and tested privately in the stages only.

* **Differences from the BS gate's Checked outputs** (`build/d5l-prep/compare.py` against the snapshot
  `build/d5l-prep/before/`, taken before the cycle):
  * presentation-diag.log (178 runs): `pdos unexplained` lower exactly as D5c predicted (V1, V2, ... runs of
    birth 680 -> 670, new and s3 675 -> 615, earth 602 -> 541, custom 640 -> 580, settlers 670 -> 610; 30
    runs); the new fields `setup_text_diff 0` (D5c) and `n_clip 0` (D5a, S4) in every run; nothing else but
    the pmap timing fields, which vary run to run.
  * profiles.log: all 90 equal.  ext_p0: P0 PASS in every scenario (TESTS_OK).
  * ext_timeline: `birth` 3 and `birth_skip` with the DOS setup page at the hand-over, `birth` 4 (the Birth
    goldens, including frame 12000 = d67d465f..., the T4 difficulty page) equal the landed golden;
    EXT_TIMELINE_OK, the bs group (bs3_timeline) EXT_TIMELINE_OK unchanged.
  * ext_adapt: EXT_ADAPT_OK checks 56 -> 68: D5c's four pairs d-setup-escape, d-setup-portrait,
    d-setup-tribe and d-setup-goback, three PASS lines each.
  * ext_frames: `s3` and `birth` presented.log lengths (s3 671 -> 672 lines, 645 -> 643 tick shows; birth
    3054 -> 3050, 3032 -> 3031): the DOS frames after the hand-over are now the setup page; every A against A'
    comparison still passes.
  * adapters-check rows 38 -> 75, steps 12 -> 19 (D5b's I-menu and D5c's I-setup rows); dos-decoded.txt and
    registry-check: D5c's 8 rows; obs-lint files 97 -> 101 (the four new files); nodos files scanned
    1671 -> 1680; coverage's informational "other functions entered" 661 -> 662 and 665 in the two runs of
    the same landed build (it varies run to run).
  * Nothing else differs.
* D5a's tests in the slot's run: test_pdos_shadow 157, test_pdos_scene 136, test_pdos_seq 170 checks (now
  D5c's copy), all PASS; d3a_obs_lint OBS_LINT_OK (the `OBS_AT_EXIT(OBS_P_RunTextInputDialog)` marker).
  As predicted ("What needs the build slot" 3), no recorded expectation changed through D5a: its only visible
  trace is the `n_clip 0` field.

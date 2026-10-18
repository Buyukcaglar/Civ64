# Phase 8 audit B: items 3 (Features), 5 (Files), 9 (Fidelity register)

Method: static review plus read-only Python (hashlib, parsing). Nothing was built, run or written
except this file. Paths are relative to `C:\Projects\Civ1RE\claude\port` unless stated.

| Item | Verdict |
|---|---|
| 3 Features | MET WITH CAVEATS |
| 5 Files | MET WITH CAVEATS |
| 9 Fidelity register | NOT MET as a "complete" register (documentation gaps only; B12 BLOCKER) |

## Item 3: FEATURES.md

### What I checked and found sound

* **Coverage vs the required list.** `docs/FEATURES.md` has 108 rows. I parsed
  `claude/docs/resources.md`: all 67 MENU 128 command ids (101..115, 201..205/207/208, 301..313/315/316/318,
  401..406, 501..506, 601..606, 701..709, 801, 803) have a row; all 24 ACCELERATOR 128 entries appear in
  the Accelerator column with the correct command (D/H/J/K/N/P, Ctrl+R/0..9/D/P/F/L/Q/S/T). The 19 dialog
  templates (129, 130, 131, 135, 136, 137, 139..149, 151, 666) each have a row. The six title branches,
  intro, Birth, and the window/screen/effect rows are present (13 rows).
* **Hashes vs `build/harness/features.txt`.** I compared every row in file order: run id, event id, event
  time, frame number, frame time, held time and SHA-256 match for all 107 hashed rows (0 mismatches).
  The set of 87 distinct hashes is identical in both files. `title.quit` is the one "animated" row.
  The 109th line of features.txt is the "reached 108 of 108" trailer.
* **civ64 statuses vs `build/frames/c7-*/result.txt`.** I parsed every `MATCH`/`differs` line and
  compared run name, frame number, pixel count and palette-entry count quoted in each row. All agree
  except `cmd.503` (B5).
* **Counts.** 56 equal + 32 phase + 9 cause-viewed (4 "another world" + 5 "scrolled") + 9 not viewed
  = 106 compared; plus Quit and dialog 666 = 108. Matches `phase-7-acceptance.md:13` and
  `verify/phase7-bringup.md:73`. Per-run counts in bringup section 3 (c7-menus 19/24, c7-menus-c64 22/21,
  c7-city 1/10, c7-settlers 0/7, ...) match the result files. "21 runs" matches the table.
* **No false "looks the same".** No row is labelled oracle-compared or user-confirmed; header
  (`FEATURES.md:11-12`) and `phase-7-acceptance.md:29` say none yet.
* **Spot checks on "cause seen" rows.** `cmd.405/406/601` (c7-menus-c64): the 4 differing pixels are the
  2x2 block at (79..80, 408..409) in all three, as claimed. `cmd.115` (59,547 px): differences lie in the
  main map window (x 71..639, y 88..415) and a horizontal shift of 64 px matches 80% of sampled pixels, so
  "map scrolled" is plausible.

### Findings

**B1 MAJOR. 22 of the 24 ACCELERATOR 128 entries were never pressed; the doc implies otherwise.**
`FEATURES.md:71-76` says the scenarios "send accelerators" and rows 78-144 show an Accelerator column,
but each row's scenario is the first *menu* event (e.g. row 102 "menu command 102"). In all
`build/harness/game/*/events.log` only `accel 65` (Ctrl+S, 30 events) and `accel 68` (Ctrl+F, only
`p49-findcity`) exist; no `accel` event exists for N, K, P, H, J, D, Ctrl+R, Ctrl+0..9, Ctrl+D, Ctrl+P,
Ctrl+L, Ctrl+Q, Ctrl+T. The c7 civ64 runs replay the same scripts. `tests/test_user.c:748-771` tests
TranslateAccelerator for Ctrl+S only. So "every item of ACCELERATOR 128" has a headless scenario for 2
entries. Fix: add scenarios (or a data-driven unit test over the loaded table) and `accel` rows in
`tests/harness/features.map`; otherwise state per row "accelerator not exercised" and drop "send accelerators".

**B2 MAJOR. The Sound row is labelled "agent-observed" but no sound was ever played or observed.**
`FEATURES.md:162`: "agent-observed: civ64 run c7-start, frame 9 equal to the headless frame". That is a
video-frame hash, and every c7 run used a copy with the `.wav` files removed
(`verify/phase7-bringup.md:11`, `phase-7-acceptance.md:14`). Only 4 of the 23 named wav files
(OPENING, SHAK, CEAS, WINTUNE) are requested in any p4 trace; the PlaySoundW path
(`platform/win32/host_win32.c:797-807`) has no recorded run with a real file. `phase-7-acceptance.md:32`
itself lists "sound output" as unverified, contradicting the row. Fix: status "reached headless (call
traced)"; list the other wav names as not reached.

**B3 MINOR. "agent-observed" is applied to hash-equality and to templated causes.**
(a) The 56 "equal" rows compare civ64 against a headless frame that was not viewed (port against port;
nothing about the original). (b) For 32 "phase" rows the cause text is a template written by the script
(scratch `p7/c7status.py`, lines 26-33): any row with <=16 differing pixels gets "a blinking world-map
marker ... the cycling phase". 22 rows therefore read "(0 pixels, a blinking world-map marker, and N
palette entries ...)", which contradicts itself (0 pixels cannot include a marker). (c) "the same screen"
is port-vs-port wording that a reader may take as an appearance claim. Fix: define "agent-observed" in the
header (viewed vs hash-compared); drop the marker clause where pixels = 0.

**B4 MINOR. Several rows' first stable frame cannot show the feature.** 87 distinct hashes for 108
rows. Dialogs 146 and 147 share f239c031...; the two scenarios `p4-research` and `p4-research2` produce
bit-identical stable frames for all 17 frames and `final.bmp` (compared by SHA-256 of
`build/frames/p4-research*/stable-*.bmp`), so the hash cannot discriminate the two templates. Commands
105/112/202 share 268346e0...; 106/204 share 83496ae1...; Start a New Game, Play on EARTH and Birth share
b567ca37.... The rows prove "reached" (by the event trace) but not appearance; the doc says so only
generally.

**B5 MINOR. cmd.503 contradicts the stated "best result per row".** `verify/phase7-bringup.md:73` says best
result per row, but `build/frames/c7-menus/result.txt` has `MATCH cmd.503 ... civ64 frame 884` while
`FEATURES.md:124` reports the weaker c7-menus-c64 result (4 pixels / 8 palette entries). `c7status.py`
skips the whole `c7-menus` run by name. Under the stated rule the totals would be 57 equal / 31 phase.

**B6 MINOR. Required features lack their own scenario/hash row.** (a) Quit has no hash
(`FEATURES.md:40`, "animated"; a hash of present 457 could be given). (b) "City screen and city view" is one
row/hash; the city view (`marker city-view`, p4-city) has none. (c) "Palette cycling and fades": the
only match is `CyclePaletteColors` (`features.map` screen.palette); no fade is reached. (d) "End-game
sequences" lists the conqueror, arrival and destroyed endings in prose only; one hash (retirement).
(e) Map, world-map and status windows share one hash. (f) Hall of Fame row is the *empty* table
(`p4-fame-quit`, no famehall.civ); the populated table (`p4-fame-reload`) has no hash. (g) Palace view
is taken from the edited-save scenario although an unedited route exists in `p4-city` (disclosed in the row).

**B7 MINOR. Stale "Last run" cells.** `FEATURES.md:26` (p4-NAME) dates the runs "2026-10-10 04:3x..04:4x
UTC"; the current `events.log` files were rewritten at 14:48-14:50 UTC and Asan at ~15:01 UTC. The title-menu
hash changed with F85 (847c3957... in `p7/FEATURES.md.bak` -> f551c811... now), so the S1 row
(`FEATURES.md:22`, g-26, 2026-10-09, "every frame hash as in g-22") describes a pre-F85 state.

**B8 MINOR. Release test evidence for the final tree is missing.** `phase-7-acceptance.md:19` and
`STATUS.md` say TESTS_OK in all three variants with `test_host_win32` 101 checks. The 101-check logs exist
for Checked (`p7/t-checked.log:197`) and Asan (`p7/t-asan.log:197`). The only Release test log after F86,
`p7/test-f86.log` (16:37 local), shows 98 checks (`:197`); the final Release build
(`p7/b-release.log`, 15:04 UTC) has no test run after it; `build/test-release.log` is dated 2026-10-08.

## Item 5: Files

### Verified

* **CAE3540B.SAV loads and plays on.** Headless: `docs/phase-3b-acceptance.md:15-17` (S2 plays turns
  23..25; S4 soak 92 turns). Oracle: the original under OTVDM loaded it (`build/oracle/port-save/log.txt`).
  civ64 loaded it (c7-load).
* **Oracle file hashes (Python hashlib).** `build/oracle/port-save/SAVE1-original.SAV` = 6b38a674...eb31,
  14,281 bytes; equals `build/run/p4-load/SAVE1.SAV`, `build/run/c7-load/SAVE1.SAV` and
  `build/run/gate3b-s2/SAVE1.SAV`. `build/oracle/port-port2/ORIG2.SAV` = aaa142a7...76e, 14,299 bytes;
  equals civ64's `build/run/c7-t-port2/RESAVE2.SAV`. `PORT2.SAV` = 8a117942..., 14,301 bytes; equals
  headless `p4-load/SAVE2.SAV` and the oracle copy. The original's shipped CAE3540B.SAV is 14,283 bytes.
  All claims in `phase-7-acceptance.md:14` and `phase7-bringup.md:44,46` check out. `q1-map-2.png` shows the
  original displaying the map and Rome from the port-written PORT2.SAV ("the original loads a port save").
* **Save path and stale tail.** `gate3b-s2b/CAE3540B.SAV` is 14,283 bytes: first 14,281 bytes = SAVE1.SAV,
  last 2 bytes (0200) = the original's tail; `gate3b-s2c/STALE.SAV` identical; `RESAVE.SAV` = SAVE1.SAV.
  `tests/harness/savecheck.py` compares the file with independent RLLEncode/RLLDecode models of
  `CivSaveGame`'s buffer (self-consistency, labelled so in `phase-3b-acceptance.md:16`). The oracle equality of
  SAVE1/RESAVE2 independently supports the whole serialize+RLL path for load-then-save.
* **Layouts.** `FAMEHALL.CIV` is 468 bytes = 6 x 78 (score -1 = 0xFFFF for empty slots) as in
  `claude/docs/subsystems/game-flow.md` 2.4; `REPLAY.REP` is 50 x 81-byte lines (80 chars + CR) followed by
  LF-terminated event lines (4.16.3); `civ.prf` is 26 bytes (three RECTs + word), rewritten at in-game quit with
  the rectangles unchanged and bit 0x10 toggled (`tests/harness/p4tests.py:348-378`, run `p49-prf`).
  famehall.civ is created when absent (`scenarios.py:652-654`) and reloaded unchanged (`:655-659`).

### Findings

**B9 MAJOR. "Files written after a synchronized scenario are compared byte for byte" is met only
trivially, and the record does not say so.** Prompt item 5 and section 7 (`x64-port-prompt.md:1240-1249`)
require an R1 resynchronization (city screen > View, `ShowCityView(city,-1)`) and then deterministic actions
before saving in both programs, and "record the synchronization used and which bytes were exact". The
only oracle comparisons are load-then-save at once (SAVE1; ORIG2/RESAVE2). No turn is played, no R1 reseed
is done, and no famehall.civ, civ.prf or .rep was written by the original and compared (the OTVDM runs
end by stopping the launcher tree; `build/oracle/*/log.txt`). `phase-7-acceptance.md:14` presents "Files,
byte for byte" as the gate result and `:11-19` lists no open item. "The port loads original saves" rests on
the shipped CAE3540B.SAV only; an original-written save (SAVE1-original/ORIG2) was never fed to the port
(they are byte-identical to port outputs, so this is inferred, not run). Fix: record this bullet as
partly met (load-save-at-once only) and an open item, or run an R1-synchronized scenario.

**B10 MINOR. Stale-tail and layout evidence is narrower than the prompt lists.** Prompt 5.4 names three
no-truncate writers: CivSaveGame, SaveHallOfFame (O_RDWR at 1080:00B2) and the replay file. A game-level
stale-tail test exists only for CivSaveGame (`gate3b.py:139`). No test overwrites a longer famehall.civ or
.rep (`test_io.c` checks rt O_TRUNC/O_APPEND only). Layout checks for famehall.civ and .rep are weak
(`scenarios.py:653-663`: size 0x1D4 and "reload leaves file unchanged"; .rep size > 4000 and a CR in the
first 100 bytes); I confirmed the layouts against game-flow.md myself, but no test does. The stale-tail
rule was not compared with the original (the oracle saved to new names).

## Item 9: FIDELITY.md

### Verified

* Entries F1..F87 are all present (no gaps), 87 rows; each has Address, Reason, Port behaviour, Ref columns.
  Sections: memory/handles/stack, faults and OOB, class (b), time, Win16 emulation, host.
* Expected kinds present: window and pixel model (F24-F36, F75-F80), help (F84), handles (F2), class (b)
  sites (F13, F15-F23, F37-F70; I matched the 33 rows of `docs/inventory/uninit.md`: all class (b) sites are
  covered; the 4 uncovered rows are class (c) in `DESIGN.md:635,636,673`), CPU-speed draw counts (F12, F87),
  fault behaviour (F10, F11, F33, F58-F66, F72-F74).
* Samples against code: F12 poll costs (`platform/w16/clock.h:18-19`: 1000/50 us); F14 constants
  (`kernel_misc.c:12-17`); F25 device caps (`gdi_dc.c:307-329`: 0x030A, 208, 156, 0x3F99, 36); F27
  base units (`user_dlg.c:8`); F77 400/100 ms (`user_scrolltrack.c:62-63`); F83 `PlaySoundW` flags
  (`host_win32.c:807`); F1 first dynamic selector (`vm.h:27`, 0x1428); F33 `VM_FAULT_RETURN` (`vm.h:76`);
  F58/F66 cite addresses present in `core/`. All consistent.
* No entry lacks an address or reason. RECOVERY-ERRATA E18 cited by F71 exists.

### Findings

**B12 BLOCKER (for "complete"). No entry for fonts.** Prompt item 9 lists fonts as an expected entry
kind and `phase-7-acceptance.md:17` says the category is present. A search of `docs/FIDELITY.md` for
`vgasys`, `civfonts`, `Q22`, `face` (as typeface) finds nothing; "font" occurs only incidentally (F26/F27
"system font", F34). Undocumented in the register: the system face is read from the host's
`Fonts\vgasys.fon` (`DESIGN.md:957`, `RUNNING.md:14`), not from a Windows 3.1 driver; civfonts.fon face
order (open question Q22, decided in `DESIGN.md:1199` and `gdi_font.c`); text metrics. Fix: add entries.

**B13 MAJOR. Timing is one entry.** The Time section is only F12 (poll costs). Not registered although
decided in `DESIGN.md` 6/10: the `--timing classic|host` modes, the 54.925 ms tick and 55 ms
GetTickCount granularity ("platform fact (inferred)", `DESIGN.md:1582-1584`), WM_TIMER periods and
coalescing, the random per-process boot offset, `time()`/TZ and the srand seed taken from the host start
time (so same-seed behaviour is never reproducible; item 4 requires such results be labelled "not
reproducible"; `phase-7-acceptance.md:32` mentions it only in Unverified). Open questions Q1-Q4 (segment
limit of 12D8, clobbered timer id, window-less timer, timer granularity) are touched by the port but absent.

**B14 MAJOR. Open-question coverage.** Prompt 3 requires "record what the port does for each [Q1..Q93] it
touches, in FIDELITY.md". FIDELITY.md cites only Q5, Q6, Q10, Q17, Q89. `DESIGN.md:1189-1199` tabulates
12 more (Q5-Q8, Q10-Q12, Q14, Q16, Q17, Q22; Q7, Q8, Q11, Q12, Q14, Q16, Q22 are decided there but not in the
register). The remaining 76 are in neither document, with no statement that the port does not touch them.

**B15 MAJOR. F1 misstates the selector policy.** F1 (`FIDELITY.md:16`): "freed selectors are quarantined, so
a stale far pointer faults instead of aliasing another block". The implemented policy
(`DESIGN.md:121-137`) reuses the oldest freed selectors once the never-used ones are exhausted (about
3,450 allocations), a deviation from the prompt's "never reused" that `STATUS.md:156` lists as "pending
user confirmation". `DESIGN.md:134-135` promises the entry "selector values and reuse order differ from
Windows 3.1; a stale far pointer faults until its selector is reused"; it is not in the register (F2
mentions FIFO reuse for handles only). Fix: amend F1.

**B16 MAJOR. Fault-policy sites without entries.** Prompt 5.3: "Each site gets a fidelity entry."
`build/cache/oob-allowlist.txt` (353 sites) includes C4 (1070:1BAF), C8 (5 sites, PlanZoneWaypoint
1128:0A02..0B52), C14, C15 (10B8:1AD4, 1AFF), C16, C19 (19 sites; 10F8:009B, 049E) and C11. The
register has no entry and no mention of C4, C8, C14, C15 or C19 (they appear in none of FIDELITY, DESIGN,
STATUS, TRACE). C19 (oversized file overruns the 0x1A2BA block; findings.md:796-810 says original outcome is
heap corruption or a fault "depending on selector limits", inferred) and C8 (index far outside segment 1338)
are exactly the "original unknown, port faults" cases. Fix: one entry per site or a table of allowlisted
sites with the port outcome.

**B17 MINOR. F10 names the wrong address.** F10 and `DESIGN.md:153` say the dialog names 1030:298E. The
dialog (`platform/win32/host_win32.c:121-126`) prints the data address and the statement marker; the C2
fault run `build/harness/game/p49-c2-fault/run.log` reports site 1030:28A7, address 12D8:4642, and
`phase-4-acceptance.md:37` also says 28A7. The prompt asks that the dialog name the original address.

**B18 MINOR. Missing ids.** F4, F5, F8 have no finding/open-question id (Ref "—"); F7 and F9 cite only
"5.2 item N". The item requires "the findings or open-question id".

**B19 MINOR (outside my items; for the phase-8 re-hash).** `docs/hashes/20261010T050021Z-after.txt`
predates the phase-7 original runs (OTVDM, 13:2x-14:4x UTC) by about eight hours.

## Summary of findings

* BLOCKER: B12 (no fonts entry; register not complete).
* MAJOR: B1 (accelerators), B2 (sound label), B9 (synchronized oracle scenario), B13 (timing), B14 (Q ids),
  B15 (selector reuse in F1), B16 (fault sites).
* MINOR: B3, B4, B5, B6, B7, B8, B10, B17, B18, B19.
* Not found wrong: every FEATURES hash and civ64 status except cmd.503; the quoted counts; the oracle
  SAVE1/ORIG2/RESAVE2 hashes; the stale-tail result for CivSaveGame; the sampled FIDELITY code citations.
* (Numbering note: B11 is unused.)

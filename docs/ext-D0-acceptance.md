# Extension phase D0 — acceptance record

Prompt: `claude/docs/x64-port-scaling-dos-prompt.md`, phase D0 (section 9): "DOS tools and the executable
map (6.1 to 6.4). Windows inventory: pictures, shapes, fonts, dialogs, cursors, movies, logical-layer call
sites, pixels-as-data. Counterpart table and scene table v1." Gate: "`docs/dos/*` drafts; independent
review recorded." Sessions E1 (2026-10-11 to about 00:55 UTC: tools, drafts) and E2 (2026-10-11: the
review, the fixes, this record). Briefs: verify/BRIEF-d0.md,
[verify/BRIEF-d0-review.md](verify/BRIEF-d0-review.md), [verify/BRIEF-d0-fixes.md](verify/BRIEF-d0-fixes.md).

All DOS facts are labelled DOS file, DOS listing, inferred or unknown. No DOS-oracle run was made in D0
(the grant exists; the O group of [dos/OPEN.md](dos/OPEN.md) lists what an observation would settle).

## Gate

| Item | Method | Result |
|---|---|---|
| Tools (6.1) | `gen/dos/dosexe.py` (MZ, EXEPACK, overlay directory), `disasm.py` (relocation-aware recursive descent over the root, 23 overlays, `MGRAPHIC.EXE`, `MISC.EXE`; cross-references, strings, ports, interrupts, driver slots), `ovlsummary.py`, viewers `pic.py`, `fontcv.py`, `texts.py`, `png.py` (outputs only under `build/`, refused elsewhere since F2) | `dosexe.py check`: EXEPACK_OK (load module 203,584 bytes, 0 differing from `CIV_UNP.EXE`; 2,525 relocations, same set and order; 23 overlays ending at the end of the file); `pic.py check`: PIC_OK (106 PIC, 38 PAL, 0 failing); `fontcv.py check`: FONTCV_OK (9 fonts); `texts.py check`: TEXTS_OK (13 texts) — run 2026-10-11 E2 (headless tools on `build/dosdata`). `disasm.py` after F1's fix: 695 functions, 91,284 instructions, root 142,996 of 145,216 code bytes, overlays 99.9 %, MGRAPHIC 4,460 of 6,630 |
| Executable map, address notation, overlays, driver interface (6.2, 6.3) | [dos/EXECUTABLE.md](dos/EXECUTABLE.md), [dos/DRIVER.md](dos/DRIVER.md) | drafted, reviewed (R1), fixed (F1) |
| Clock (6.4) | [dos/TIMING.md](dos/TIMING.md): INT 08h handler, PIT programming, calibration, counters, waits, fades, cycling, every duration of the credits, intro, title hand-off and Birth in ticks and seconds, CPU-speed assumptions | drafted, reviewed (R1: every duration re-derived), fixed (F1) |
| Contracts (6.5) | [dos/FORMATS.md](dos/FORMATS.md) (PIC, PAL, FONTS.CV, texts, pointer; section 6: data tables and code constants the profile reads), [dos/PALETTE.md](dos/PALETTE.md), [dos/SPRITES.md](dos/SPRITES.md), [dos/SCENES.md](dos/SCENES.md), [dos/SCENES-PLAY.md](dos/SCENES-PLAY.md), [dos/OPEN.md](dos/OPEN.md) (P 29, L 28, O 8, X 15 items) | drafted, reviewed (R2, R3), fixed (F2, F3) |
| Correspondence (6.6) | [dos/CORRESPONDENCE.md](dos/CORRESPONDENCE.md) | drafted, reviewed (R3), fixed (F3) |
| Windows inventory | [dos/WINDOWS-INVENTORY.md](dos/WINDOWS-INVENTORY.md): 199 pictures, shape tables, fonts, 16 cursors, dialogs, movies, logical-layer call sites, pixels read as data; section 10 the probe list (182 rows, 175 functions, 34 call-site filters; prompt 5.2 O2) | drafted, reviewed (R3: 21 claims sampled, all agreed), fixed (F3) |
| Scene table and counterpart table v1 (5.4) | [DOS-PROFILE.md](DOS-PROFILE.md): scene table 141 rows (108 FEATURES rows: 45 N, 35 R, 21 A, 7 W, 0 open; 33 probe rows), counterpart table 139 rows over all 199 picture ids, shapes, fonts, cursors and palette effects (0 with the class open), flow differences, static-text sources, class W list | drafted, reviewed (R3: complete in rows and counts), fixed (F3: dialog 141 class R, picture 5590 class W, probe column as function starts) |
| Independent review | three read-only reviewers, at least 15 load-bearing claims re-derived per document (R2: 81 claims), [verify/ext-d0-review.md](verify/ext-d0-review.md) | recorded: 2 blockers (both fixed), 21 majors, 36 minors, 16 notes; every finding resolved (fixed, registered in OPEN.md, or noted without defect), none rejected |
| No DOS bytes (2.3) | reviewers' checks of every document and tool | none found |
| DOS immutability (2.3) | hash check of `dos/` at session start (E2) | DOS_HASH_BEFORE_OK 176 of 176, attributes and times equal ([hashes/20261011T055556Z-dos-before.txt](hashes/20261011T055556Z-dos-before.txt)); the session-end check follows at E2's end |

**Gate met** (2026-10-11, E2): the drafts exist for every item of 6.1 to 6.6 and the D0 row, and the
independent review is recorded with resolutions.

## Carried forward

* The P group of [dos/OPEN.md](dos/OPEN.md) (29 design decisions) goes to D1; its areas settle them
  ([verify/BRIEF-d1.md](verify/BRIEF-d1.md)).
* The L group (listing work for later phases) and the O group (DOS-oracle observations) stay open
  with their phases named.
* The documents remain drafts in the sense of 6.5: later phases correct them where implementation
  or an observation shows more, with a note in the document.

## Not verified

* No DOS behaviour has been observed (no DOS-oracle run): every timing and appearance claim is
  "DOS listing (model)" until 7.9.
* `disasm.py` coverage leaves 2,220 root code bytes and 2,170 MGRAPHIC bytes undecoded (data,
  tables and unreached code; EXECUTABLE.md 10, OPEN.md L16).

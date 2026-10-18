# D0 independent review: index and resolutions

Extension phase D0 (`claude/docs/x64-port-scaling-dos-prompt.md` 9: "`docs/dos/*` drafts; independent
review recorded"). Session E2, 2026-10-11. The review ran in three read-only parts under
[BRIEF-d0-review.md](BRIEF-d0-review.md); each part's findings were verified again and applied by a
separate fixer under [BRIEF-d0-fixes.md](BRIEF-d0-fixes.md). A first attempt of the review
(2026-10-11 00:44..00:55 UTC, session E1) was cut off by the session's end before any report; its
scratch was not used.

| Part | Scope | Report | Findings (blocker / major / minor / note) | Fixer record | Resolutions |
|---|---|---|---|---|---|
| R1 | `EXECUTABLE.md`, `DRIVER.md`, `TIMING.md`; `gen/dos/dosexe.py`, `disasm.py`, `ovlsummary.py` | [ext-d0-review-r1.md](ext-d0-review-r1.md) | 0 / 6 / 14 / 5 | [ext-d0-fixes-r1.md](ext-d0-fixes-r1.md) (F1) | 27 fixed (with items routed from R2 and F2), 2 registered, 3 noted without defect, 0 rejected |
| R2 | `FORMATS.md`, `PALETTE.md`, `SPRITES.md`; `gen/dos/pic.py`, `fontcv.py`, `texts.py`, `png.py` | [ext-d0-review-r2.md](ext-d0-review-r2.md) | 2 / 5 / 11 / 6 | [ext-d0-fixes-r2.md](ext-d0-fixes-r2.md) (F2) | 19 fixed, 3 fixed and registered, 2 applied by F1/F3, 2 items of design agent D1-E fixed, 0 rejected |
| R3 | `SCENES.md`, `SCENES-PLAY.md`, `WINDOWS-INVENTORY.md`, `CORRESPONDENCE.md`, `OPEN.md`, `DOS-PROFILE.md` | [ext-d0-review-r3.md](ext-d0-review-r3.md) | 0 / 10 / 11 / 5 | [ext-d0-fixes-r3.md](ext-d0-fixes-r3.md) (F3) | 46 items (R3 and those routed from R2, F1, F2): 32 fixed, 7 fixed and registered, 7 registered, 0 rejected |

## Blockers and their resolution

| Id | Finding | Resolution |
|---|---|---|
| R2-1 | "R:0403:10AB picks one of 8 pointer shapes" was wrong | Fixed (F2, F3): the in-play pointer is the torch, except that dispatch value 67h (inferred GoTo, key `g`) toggles a flag (R:0403:10B3) that shows the "GO" arrow D4CE[2] until a map click stores the destination in the unit record (81DA/81DB) and restores the torch (R:0403:09D9..0AEC); FORMATS.md 4, SPRITES.md 6.3, OPEN.md L5/L10, DOS-PROFILE.md 0.6, 2.5, C6, SCENES-PLAY Open 3, CORRESPONDENCE |
| R2-2 | Every ICONPG picture was said to have its own palette file | Fixed (F2, F3): only `ICONPG1.PAL` and `ICONPGA.PAL` exist and are used by fixed name; `ICONPGT` uses `SP256.PAL` with a fixed grey in DAC entry 253 (SPRITES.md 8, PALETTE.md, DOS-PROFILE E11) |

No finding showed a memory-filled fact, a main-project source or DOS bytes in a document or tool.

## Items the orchestrator applied

* The corrected listing (F1's `disasm.py`: strict string references, `loop` targets, `cbw`/`cwd`,
  ports, stops at INT 20h and INT 21h AH=4Ch) replaced `build/dos/disasm/` at about 07:4x UTC; the
  previous listing is kept as `build/dos/disasm-prev-20261011/`. Comparison (F1): 89,561 instruction
  lines identical, every difference intended, no instruction's bytes changed.
* F1's items for F2's finished files: FORMATS.md 2.1 (slot 11/16 formula 0630h + the word at
  data:(0020h + 2n)), FORMATS.md 1.4 (the DAC writer is now wholly in the listing), SPRITES.md 8
  (`cbw`). F3's items for F2's files: SPRITES.md 6.4 (unit rectangles differ from Windows by one
  logical pixel in x; R3-1), PALETTE.md 4 (the Hall of Fame after a game loads no palette; R3-15).
* R3-21: WINDOWS-INVENTORY.md's header facts read from `build/gamedata/` (the verified copy of the
  pinned original files, base prompt 3) are ratified as a source; header fields only.
* `BRIEF-d0.md`: the coverage numbers after F1's fix.
* Not applied: F1's optional item 8 (`dosexe.py` comparing relocations as (offset, segment) pairs):
  R1 verified the pairs independently (2,525 pairs equal, in order); the tool's set-and-order check
  stays.
* D1-A's scratch `probe_sites.txt` counted the old probe column; the consolidated probe list is now
  WINDOWS-INVENTORY.md 10 (182 rows, 175 functions, 34 call-site filters), checked with showfunc by F3.

## Process deviations reported by the agents

Read-only only, with no effect on results: R1 two shell commands starting with `cd`; D1-A one; F3
one `cd` and one `git --no-optional-locks show` (against the briefs' "no git"; read-only).

## Verdicts

All three reviewers: the drafts in their scope are a sound base for D1 once the findings are
applied. They have been applied (records above).

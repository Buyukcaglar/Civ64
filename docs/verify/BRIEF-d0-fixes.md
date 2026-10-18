# Brief for the D0 fixers (extension phase D0, after the independent review)

Written 2026-10-11 by the orchestrator. The independent review of the D0 drafts is in
[ext-d0-review-r1.md](ext-d0-review-r1.md), [ext-d0-review-r2.md](ext-d0-review-r2.md) and
[ext-d0-review-r3.md](ext-d0-review-r3.md) (brief [BRIEF-d0-review.md](BRIEF-d0-review.md)). Each
fixer applies one review's findings to the documents it owns. Read this whole brief first.

## Rules

* All rules of BRIEF-d0.md apply (independence, sources of DOS facts, labels, no DOS
  bytes, never execute DOS programs, tools, unknowns stay unknown, style).
* **Files.** Edit only the documents your task names, write your resolution record
  `claude/port/docs/verify/ext-d0-fixes-<review>.md`, and scratch files under
  `claude/port/build/dos/scratch-f<review>/`. Do not edit the review reports, the tools, `STATUS.md`,
  `DESIGN.md` or any other file. Do not commit or stage. Other agents may be reading the same
  documents meanwhile; that is fine.
* **Every finding gets a resolution.** For each finding of your review (blockers, majors, minors and
  notes): verify it yourself first (a reviewer can be wrong: re-derive from the listing, the DOS
  files, `claude/docs`, `claude/src` or showfunc), then either apply a correction or record why not.
  Resolution kinds: **fixed** (what changed, where), **registered** (the question is real but needs
  a decision or work of a later phase: entered in `docs/dos/OPEN.md` with the phase that settles it),
  **rejected** (the finding is wrong: your evidence). Findings that ask for a design decision (how
  the profile will do something) are not decided by you: record the question in OPEN.md's P group
  with the facts the decision needs, and correct any draft text that pre-empted the decision
  against the prompt's rules.
* **Prompt rules win over drafts.** Where a draft contradicts the extension prompt
  (`claude/docs/x64-port-scaling-dos-prompt.md`) or a user direction recorded in
  `claude/port/docs/STATUS.md`, correct the draft. Notably: the DOS play-screen layout add-on is
  withheld, so class A and R elements during play keep the Windows layout and positions (5.3, 5.4);
  input aimed at a DOS sequence that the core has left is consumed (I6, T5); presentation never
  injects input on its own (I1).
* **Consistency.** When you change a fact, search all of `claude/port/docs/dos/*.md` and
  `claude/port/docs/DOS-PROFILE.md` for other statements of it. Fix those in your own files; list
  those in other files in your record under "for other documents" with file, section and the
  needed change.
* **Record format** (`ext-d0-fixes-<review>.md`): a header comment (who, when, which review), then a
  table: finding id, severity, resolution kind, what changed (file and section) or the evidence for
  rejecting, and a final list "for other documents". Your final message: the record path, counts by
  resolution kind, and the items for other documents.

## Tasks

* **F3 (review R3).** Owns `docs/dos/SCENES.md`, `SCENES-PLAY.md`, `WINDOWS-INVENTORY.md`,
  `CORRESPONDENCE.md`, `OPEN.md` and `claude/port/docs/DOS-PROFILE.md`. Also: the consolidated probe
  list that R3-6 asks for belongs in `WINDOWS-INVENTORY.md` (prompt 5.2 O2 "The D0 inventory fixes
  the probe list"): every probe with its Windows address, purpose, arguments read and the O2 bullet
  it serves. The class of dialog 141 and of ShowCivilizationDestroyed / picture 5590 (R3-8) is a
  D0 table decision under 5.4's rules: decide it from the evidence, or register it if the evidence
  does not settle it.
* **F1 (review R1).** Owns `docs/dos/EXECUTABLE.md`, `DRIVER.md`, `TIMING.md`, and (orchestrator's
  assignment, 2026-10-11) `gen/dos/disasm.py` and `gen/dos/ovlsummary.py` for R1's tool findings
  (R1-2 string references, the robustness items). Other agents are reading
  `build/dos/disasm/` meanwhile, so never write there: run the fixed tools into
  `claude/port/build/dos/disasm-next/` (and `summary.txt` there), and check with a script that every
  listing line other than the `str?` annotations (and the lines your other fixes intend to change)
  is identical to `build/dos/disasm/`; report the counts. The orchestrator swaps the directories
  when no reader is active. Base your document corrections on the fixed listing where R1-1 needs it
  (file attribution by real references only).
* **F2 (review R2).** Owns `docs/dos/FORMATS.md`, `PALETTE.md`, `SPRITES.md`, and (orchestrator's
  assignment, 2026-10-11) the viewers `gen/dos/pic.py`, `fontcv.py`, `texts.py`, `png.py` for R2's
  tool findings (R2-18: refuse an output directory outside `claude/port/build/`). R2-7 (a registry
  that separates true DOS data tables with their offsets from constants inside code) belongs in a
  new section of `FORMATS.md`, "Data tables and code constants the profile reads", listing each
  item the D0 documents name, its address, width, count and the document that describes it.

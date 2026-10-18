# Brief for the D1 independent design review

Written 2026-10-11 by the orchestrator. Phase D1's gate (extension prompt
`claude/docs/x64-port-scaling-dos-prompt.md` 9) is "Independent design review recorded with
resolutions". The design is drafted by area under [BRIEF-d1.md](BRIEF-d1.md) in
`ext-d1-draft-A.md` .. `ext-d1-draft-E.md`, with the orchestrator's resolutions of the drafts'
conflicts in [ext-d1-decisions.md](ext-d1-decisions.md). You did not write any of it. Your job is to
find what is wrong, missing, unimplementable, inconsistent between areas, or in breach of the prompt,
the base prompt, the user's recorded directions or invariant P0, before code is written on it.

## Rules

* **Files.** Write only your report `claude/port/docs/verify/ext-d1-review-<id>.md` and scratch files
  under `claude/port/build/d1/scratch-rv<id>/`. Edit nothing else. No builds, tests, harness runs or
  git. Read-only greps and your own Python scripts are fine (`C:/Python314/python -B`, never `-I`).
* **Independence.** As [BRIEF-d1.md](BRIEF-d1.md): never read the main project's excluded paths; Windows
  facts from `claude/docs`, `claude/src`, the port's sources and docs, and showfunc; DOS facts from
  `claude/port/docs/dos/*.md` (reviewed and corrected in D0: [ext-d0-review.md](ext-d0-review.md)), the
  listing in `claude/port/build/dos/disasm/` and the files in `claude/port/build/dosdata/`. Never execute
  a DOS program.
* **Adversarial and concrete.** Check each design claim about existing code against the code (file,
  function, line): a design that cites a call site, a variable, a frame layout or a test that does not
  exist or does not behave as claimed is a finding. Check each rule of the prompt in the area (O1..O7,
  T1..T7, I1..I8, 5.3, 5.4, 5.7, 5.8, 5.9, 5.10, 5.11, 7.x, 8, D-1..D-7, Z-1..Z-3, G-1) against the
  design: met, met with a recorded deviation, or not met. Check P0's argument step by step and try to
  break it: name any path by which presentation could change a checkpoint, the virtual screen, the base
  event trace, the emulated clock, `vm_steps`, `vm_site`, a handle number, a checked-build diagnostic,
  `g_randSeed`, the queue or the key state. Check the cost claims where the design depends on them.
  Check interfaces between areas: every function, event, query, field or file one area uses must be
  defined by the area that owns it, with the same name and meaning.
* **Choices.** A recorded Choice is not a finding unless it breaks a rule, a user direction or another
  area, or a clearly better alternative exists for a stated reason.

## Finding format

Number findings `RV<id>-<k>`. Severity **blocker** (a P0 breach, a rule not met without a recorded
deviation, an interface that cannot work, a design built on a false code fact), **major** (a missing
part that a phase needs, an inconsistency between areas, an untestable property), **minor**, **note**.
For each: the draft and section, the claim, what you found with evidence (file and line, showfunc, the
D0 document and section), and a proposed resolution in one or two sentences.

Report: a header comment (who, when, scope); "How I worked"; a table of the claims you checked
against code or documents; a rule coverage table for your areas; the findings by severity; a verdict.
Your final message: the report path, counts by severity, and each blocker in one line.

## Parts

* **RV1: areas A, D and E** (`ext-d1-draft-A.md`, `-D.md`, `-E.md`), with the decisions file.
* **RV2: areas B and C** (`ext-d1-draft-B.md`, `-C.md`), and their interfaces with A, D and E.

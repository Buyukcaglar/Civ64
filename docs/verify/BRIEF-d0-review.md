# Brief for the D0 independent review (extension phase D0 gate)

Written 2026-10-11 by the orchestrator for three parallel read-only reviewers R1, R2 and R3. The
D0 gate (extension prompt `claude/docs/x64-port-scaling-dos-prompt.md`, section 9) is "`docs/dos/*`
drafts; independent review recorded". The drafts were written by agents D0-A..F under
BRIEF-d0.md. You did not write them. Your job is to find what is wrong, missing,
unsupported or inconsistent, so that the orchestrator can correct it before D1 designs on top of it.

A first attempt of this review (2026-10-11 00:44..00:55 UTC) was cut off by the end of the session
before any report was written. Its scratch files may still be in `claude/port/build/dos/scratch-r1..3/`.
They are unreviewed; you may delete or overwrite them, and you must not rely on them without
re-deriving their content.

## Rules

Read BRIEF-d0.md first: its rules (files, independence, sources of DOS facts, no DOS
bytes in docs, never execute DOS programs, tools, unknowns, style) apply to you unchanged, with these
differences:

* **Files.** Write only your report `claude/port/docs/verify/ext-d0-review-r<n>.md` and scratch files
  under `claude/port/build/dos/scratch-r<n>/`. Do not edit the drafts, the tools, `STATUS.md` or
  anything else. Do not commit or stage. You may run the read-only tools in `claude/port/gen/dos/`
  (`C:/Python314/python -B <tool>`), but direct their outputs only into your scratch folder where
  they take an output argument; do not rerun `disasm.py` into `build/dos/disasm/` (the drafts cite
  that listing). Your own decoding scripts are welcome and expected (capstone 5.0.7 for
  `C:/Python314/python`, user site-packages; never `-I`).
* **Read the DOS files only from `claude/port/build/dosdata/`.**
* **Adversarial, evidence-based.** Re-derive claims yourself from the DOS files and the listing (and
  for Windows facts from `claude/docs` and `C:/Python314/python -B claude/tools/showfunc.py <addr>`).
  Do not trust a draft's citation without opening it. Sample broadly: for every document in your
  scope, re-check at least 15 load-bearing claims (addresses, offsets, widths, counts, durations,
  rectangles, colour ranges, formats), weighted toward those that later phases will build code on.
  Say which claims you checked and how, so that the sample is visible.
* **Completeness.** Check each document against what the extension prompt requires of it (section
  3 "Observed facts" which D0 must verify; 5.4 tables; 5.9; 5.10; 6.1 to 6.7; 8 "pixels read as
  data"; 9 D0 row). Name every required item that is absent or only asserted.
* **Labels and guessing.** Flag every DOS fact without one of the labels DOS file, DOS listing,
  inferred, unknown (or DOS oracle, of which there are none yet), every "inferred" that the listing
  could settle cheaply, and every claim that looks filled from memory of the game or of other
  versions rather than from these files (that is a blocker).
* **No DOS bytes.** Check the documents and the tools in `claude/port/gen/dos/` for DOS bytes:
  machine code, data tables, palettes, fonts, pictures, more than a few words of DOS text. Any hit
  is a blocker. Hashes, offsets, sizes and short identifying quotes are allowed.
* **Consistency.** The same routine, variable or rectangle must have the same address, name and
  meaning across documents. Note conflicts with the precise locations.

## Finding format

Number findings `R<n>-<k>`. For each: severity (**blocker**: wrong or unsupported fact a later phase
would build on, a memory-filled fact, DOS bytes; **major**: a required item missing, a wrong but
non-load-bearing fact, a misleading label; **minor**: wording, precision, a citation; **note**),
the document and section (or tool and line), the claim, what you found with its evidence label and
your method, and a proposed correction in one or two sentences.

Report structure: a header comment as in [ext-x0-review.md](ext-x0-review.md) (who, when, scope);
"How I worked"; a table of the claims you checked (claim, document, result, method); the findings
by severity; a completeness table per document (required item, present / partial / absent); and
a short verdict: whether the drafts in your scope are a sound base for D1 once the findings are
applied. Your final message to the orchestrator: the report path, the counts by severity and the
blockers in one line each.

## Scopes

* **R1: executable, driver, timing and the tools.** `docs/dos/EXECUTABLE.md`, `DRIVER.md`,
  `TIMING.md`; `gen/dos/dosexe.py`, `disasm.py`, `ovlsummary.py` (correctness: EXEPACK decoding
  equals CIV_UNP.EXE's load module and relocations (7.6); MZ and overlay parsing; the recursive
  descent and its coverage numbers; the false-positive behaviour of the string references; whether
  overlay `INT 3Fh` calls and driver slot calls are resolved correctly). Prompt items: section 3
  facts on `CIV.EXE`, `CIV_UNP.EXE`, the clock and the strings; 6.1 to 6.4; `MISC.EXE`'s role;
  every duration expressed in PIT ticks and seconds; CPU-speed assumptions.
* **R2: formats, palette, sprites and the viewers.** `docs/dos/FORMATS.md`, `PALETTE.md`,
  `SPRITES.md`; `gen/dos/pic.py`, `fontcv.py`, `texts.py`, `png.py` (correctness against the DOS
  listing's own decoding routines, not against general knowledge of the format: chunk handling,
  LZW details, `X0` versus `X1`, palette ranges of `M0`, the 6-to-8-bit rule, `FONTS.CV` layout
  and metrics, the text prefixes and character handling, the pointer). Prompt items: section 3
  facts on `*.PIC`, `*.PAL`, `FONTS.CV` and the texts; 5.9 decoders and data tables; 6.5
  FORMATS/PALETTE/SPRITES content (set, fade, cycle; colour bases per scene; rectangles of SP257,
  TER257, SP299, SPRITES and ICONPG*). Decoded images may be written as PNG to your scratch folder
  and viewed.
* **R3: scenes, inventory, correspondence, profile tables and open items.** `docs/dos/SCENES.md`,
  `SCENES-PLAY.md`, `WINDOWS-INVENTORY.md`, `CORRESPONDENCE.md`, `OPEN.md` and
  `claude/port/docs/DOS-PROFILE.md`. Check the Windows inventory against `claude/docs` and
  showfunc (pictures 199, shape tables of graphics.md 4.9, fonts, 16 cursors, dialogs, movies,
  logical-layer call sites, pixels read as data: picture 137, GetPortPixelIndex, row 399 keys,
  GetPixel); the scene table against `FEATURES.md`'s 108 rows, every dialog template the game opens
  and every scene probe; the counterpart table against all 199 picture ids, every shape table, font,
  cursor and palette effect; classes N/R/A/W per 5.4 (each W with a reason; "W over N" cases);
  timeline codes per 5.5; adapters per 5.6 (I5's conversions per scene); CORRESPONDENCE pairs and
  their evidence; whether OPEN.md lists every Open item of the other documents and whether its
  P-group is complete for D1. The two withheld add-ons (main-project DOS research, DOS play-screen
  layout) must not have been used: the play layout stays Windows (class A).

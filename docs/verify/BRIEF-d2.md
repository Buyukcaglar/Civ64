# Brief for the D2 implementer (extension phase D2: DOS assets)

Written 2026-10-11 by the orchestrator. Phase D2 of the extension prompt
`claude/docs/x64-port-scaling-dos-prompt.md` (section 9): "DOS assets: EXEPACK, PIC, PAL, `FONTS.CV`,
texts, pointer, data-table readers." Gate: "7.6 passes under Asan" — under the user's direction of
2026-10-10 21:20 Asan runs are deferred to the end of the queue, so the D2 gate is 7.6 passing in
Checked and Release, with the Asan run recorded as deferred (decision E.18-3).

**Pipelining note.** D2 starts before the D1 gate: area E's design (`ext-d1-draft-E.md`, revision 2)
has passed the design review RV1 and its revision; the review RV2 of areas B and C runs meanwhile.
If RV2 changes an interface E offers to B, C or D, the orchestrator forwards it and you apply it.

## Authority and design

* The design is `claude/port/docs/verify/ext-d1-draft-E.md` (revision 2), with the orchestrator's
  resolutions in `ext-d1-decisions.md` (sections "Area E", "Design review RV1"). Implement it as written;
  where the code shows the design is wrong or incomplete, choose the smallest correct fix, and record it
  as a deviation (design section, what and why) in your acceptance record. Do not redesign other areas.
* The extension prompt (2.3 "No DOS bytes", "DOS immutability", 4 D-1, 5.1, 5.9, 7.6, G-1, G-2) and the
  base prompt `claude/docs/x64-port-prompt.md` section 1 (the language rules: portable C17, the three
  language checks, `/W4 /WX`, no undefined behaviour, the coding rules of `present/` and `res/`) and
  section 5.0 (build) govern. `claude/port/docs/DESIGN.md` 1, 2 and 12.1..12.4 describe the delivered
  build and layers; follow their conventions and the surrounding code's style and comment density.
* DOS facts: `claude/port/docs/dos/*.md` (reviewed and corrected in D0), the listing in
  `claude/port/build/dos/disasm/`, the files in `claude/port/build/dosdata/`. The Python tools in
  `claude/port/gen/dos/` (`dosexe.py`, `pic.py`, `fontcv.py`, `texts.py`) are the independent models
  the C decoders are tested against.

## Rules

* **Exclusive ownership.** You own, for this phase: `claude/port/present/dos/` (new),
  `claude/port/platform/w16/host.h` (the DOS read service only), the DOS-read parts of
  `platform/win32/host_win32.c` and `tests/headless/host_headless.c` and the harness option
  `--dos-data`, `win64/civ64_main.c` and `win64/civ64_locate.c` as far as E needs them,
  `claude/port/build.cmd` and `test.cmd` (adding the new sources, `test_dos`, the registry and no-DOS
  checks), `claude/port/tests/test_dos.c`, `claude/port/tests/dos-files.txt`,
  `claude/port/docs/dos/OFFSETS.md`, and new tools `claude/port/gen/dos/registry.py`,
  `shapes.py`, `nodos.py`, and your acceptance record `claude/port/docs/ext-D2-acceptance.md`. Do not
  edit `DESIGN.md`, `FIDELITY.md`, `STATUS.md`, `RUNNING.md` or the D1 drafts: list the entries they need
  in your acceptance record ("For the records"), and the orchestrator applies them.
* **No DOS bytes** in any repository file or in a built binary (prompt 2.3): no DOS code, tables,
  strings, pictures, palettes, fonts or text, not even as test vectors. Tests read the DOS files at run
  time from `claude/port/build/dosdata/` and store only hashes, offsets, sizes and hand-written
  vectors. `nodos.py check` must pass over the repository's port tree and the built binaries.
* **DOS immutability.** Never write, rename or change attributes of anything in `C:\Projects\Civ1RE\dos`
  or `claude/port/build/dosdata/`; never execute a DOS program. Fault-injection tests work on copies
  under `claude/port/build/test/` or in memory.
* **Builds are yours alone during D2**; the orchestrator runs no build meanwhile. Use
  `cmd /c C:\Projects\Civ1RE\claude\port\build.cmd checked` and `... test.cmd checked`, then Release
  (`build.cmd`, `test.cmd`). After `test.cmd checked`, run
  `C:/Python314/python -B C:/Projects/Civ1RE/claude/port/tests/harness/ext_g1.py check` (G-1 must stay
  EXT_G1_OK). No Asan build (deferred). Use a 600000 ms timeout for these commands. Logs go under
  `claude/port/build/`. Tools: `C:/Python314/python -B` (never `-I`).
* **Do not break the delivered product.** Every existing test must keep passing in Checked and Release;
  civ64 must still start without DOS files. The base tests, gate3b references and G-1 are the guard.
* No git commands that write (no add, commit, stash, checkout). Use absolute paths; do not chain `cd`
  into shell commands.

## Deliverables

1. The asset store and decoders of E (`pdos_assets`, `pdos_exe`, `pdos_pic`, `pdos_font`, `pdos_text`,
   `pdos_tables`, `pdos_shapes`, the generated registry), the host service (`host_dos_read`,
   `host_dos_where`; Win32, headless, harness `--dos-data`), activation in civ64 before the emulation
   with the failure behaviour of 5.9 and decisions RV1-6/RV1-8 (the chord message itself is D3's; D2
   stores the message and exposes availability).
2. `tests/dos-files.txt` (pins), `docs/dos/OFFSETS.md` (registry), `gen/dos/registry.py`
   (`gen`, `check`), `gen/dos/shapes.py` (independent shape-cut model for goldens), `gen/dos/nodos.py`
   (`check`).
3. `tests/test_dos.c` covering 7.6 as E.13 plans it: every DOS PIC, PAL, CV and text file parses with
   recorded decoded hashes (equal to the Python models'), EXEPACK equal to `CIV_UNP.EXE`'s load module
   with the relocation table explained, truncation and corruption vectors rejected cleanly, the shape
   cut, the folder and in-memory ZIP sources, injected failures, nothing written, determinism.
4. `claude/port/docs/ext-D2-acceptance.md` in the style of the other `ext-*-acceptance.md` records:
   gate table with methods and results (compiled, headless), deviations from the design, measured
   activation cost (Release), "Asan deferred", "For the records" (DESIGN/FIDELITY/RUNNING/STATUS
   entries), not verified.

Your final message: the gate result, the files changed, the test counts, deviations, and the "For the
records" list.

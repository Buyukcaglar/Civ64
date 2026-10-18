# Sid Meier's Civilization 64bit: how much of the original was recovered

> **Status:** accepted by the user on 2026-10-12.
>
> **Publication note:** published in the public repository `Buyukcaglar/Civ1` (the documentation and the `v1.0` release). The summary, tables and the figure hold only function addresses, sizes and counts, no original bytes. The recovered C, the listings and the port's sources are not published (see the repository README). The figure and the generated block below were regenerated with `claude/tools/recovery_coverage.py` on 2026-10-18 (`--check`: COVERAGE_OK).

The original source code of Sid Meier's Civilization for Windows has never been released, so none
of it was literally "recovered". What this work has is a reverse-engineered reconstruction of the
pinned Windows 3.1 executable (`original/CIVWIN/civ.exe`, a 16-bit Win16 New Executable, SHA-256
`a66ec640…1788`): every function rewritten as readable C from its machine code
(`../src/c` (`src/README.md`)), and the live functions translated into the portable C core of the
native Windows x64 program `civ64.exe`, Sid Meier's Civilization 64bit
([`../port`](final-report.md)). The port runs the whole game, from the intro to the
end games, on the player's own copy of the game's data files.

![Recovery coverage of civ.exe: summary figures, where every code byte went, every function in address order and the recovery stages](recovery-coverage.svg)

## Summary

<!-- coverage:begin -->
Every one of the 1,065 functions in `civ.exe` has been recovered to C, and all 699 live game functions are ported into civ64. That covers **91.5% of the executable's code bytes**. The remaining 8.5% splits into two parts:

* **3.6% is the Borland C/C++ run-time library** (155 functions). civ64 replaces it with its own `rt` layer rather than translating it.
* **4.9% is dead code** (211 functions). 178 of them are never referenced, and 33 are reachable only from other dead code.

So all of the code that actually runs is covered (854 live functions, 395,929 bytes). Leaving out the run-time library segment, 95.9% of the game code is ported; the other 4.1% is dead.

| Disposition in civ64 | Functions | Code bytes | Share of code bytes |
|---|---:|---:|---:|
| Ported into civ64 (translated C in `port/core`) | 699 | 380,936 | 91.5% |
| Borland runtime, replaced by rt (`port/rt`) | 155 | 14,993 | 3.6% |
| Dead code, not ported (178 unreferenced, 33 reachable only from dead code) | 211 | 20,456 | 4.9% |
| **Total** | **1,065** | **416,385** | **100%** |

| Part of the executable | Functions | Code bytes | Ported | Replaced by rt | Dead |
|---|---:|---:|---:|---:|---:|
| Game code (segments 1008..1220) | 859 | 397,052 | 699 fn, 380,936 B (95.9%) | – | 160 fn, 16,116 B (4.1%) |
| Borland run-time library (segment 1000) | 206 | 19,333 | – | 155 fn, 14,993 B (77.6%) | 51 fn, 4,340 B (22.4%) |

| Source | Coverage | Size |
|---|---|---|
| Recovered C, `claude/src/c` | 1,065 of 1,065 functions have a header | 89 files, 67,014 lines |
| Inferred names, `docs/db/names.json` | 1,063 of 1,065 functions named | – |
| civ64 game core, `claude/port/core` | 699 port functions (`SSSS:OOOO  Name` headers) | 184 files, 124,100 lines |

### Dead code

"Dead code" means functions that are in `civ.exe` but that nothing in the program can ever run: no call, jump, data pointer or relocation reaches them. 178 functions have no reference at all; 33 more are referenced only by those or by each other (found as a fixed point over all callers, call sites and pointer relocations). Together they are 211 functions and 20,456 bytes (4.9% of the code), of three kinds:

| Kind | Functions | Code bytes | Examples |
|---|---:|---:|---|
| Run-time library routines linked in but never called | 51 | 4,340 | `atoi`, `realloc`, `vsprintf`, `signal`, the x87 sine, cosine and tangent entries |
| Empty and constant-return stubs | 68 | 1,131 | placeholder routines that do nothing or return a constant; several are named for the Macintosh Toolbox calls that the Windows version emulates (`MacStubReturnZero_1140_0071`, `UnimplementedToolboxStub_1100_0A20`) |
| Other game routines never called | 92 | 14,985 | diagnostics and reports (`ShowDisplayDriverChecklist`, `DumpResourceMap`, `ShowResourceUsageReport`), an unused dialog-template builder (`CreateDlgTemplate`, `GR_DialogOpenIndirect`), Macintosh Toolbox helpers left from the port (`DisposeHandle`, `ShowDItem`, byte swapping), unused game helpers (`CanPlaceSpaceshipPartAt`, `FindBestAiStrategicGoal`) |

civ64 leaves these functions out because nothing can call them; they stay in the recovered C and are documented in findings.md D1. Unreachable branches inside live functions are kept as they are. The kinds are assigned from the recorded function names. The finding is static: a call through an address computed at run time cannot be ruled out, so it is recorded with high, not absolute, confidence.
<!-- coverage:end -->

## Where the numbers come from

All inputs are inside `claude/`:

* **Function list and sizes:** `db/functions.json`, from this work's own
  recursive-descent disassembler (`../tools/build.py`): 1,065 functions whose sizes add up to all
  416,385 code bytes.
* **Ported, replaced or left out:** the "Functions" table of
  [`../port/docs/TRACE.md`](TRACE.md), generated by `../port/gen/trace.py` from the
  `/* SSSS:OOOO  Name */` headers in `port/core`, the `rt` definitions and findings D1. `test.cmd`
  rebuilds it and compares it with the sources (TRACE_OK), so it cannot silently drift.
* **Recovered C:** a function counts when `../src/c` (`src/README.md`) holds its header comment
  (` * SSSS:OOOO  Name`, or an address range or list for grouped stubs). The port's translated game
  code is `port/core`. Line counts are physical lines of the `.c` and `.h` files.
* **Game code and run-time library:** segment 1000 (selector `1000`) is the Borland C/C++ run-time
  library; segments 1008 to 1220 are the game.
* **"Verified"** means that an independent reviewer compared each translated function line by line
  against the original disassembly, over 11 review rounds. All 699 passed, covering all 137,887
  instructions ([phase-3c-acceptance.md](phase-3c-acceptance.md)).
* The port's final audit also recorded headless runs reaching all 108 feature rows, and the
  original game producing byte-identical save files ([final report](final-report.md)).

## Evidence beyond the counts

Each line is labelled with its method, as in the port's [final report](final-report.md).

| Stage | Result | Method and record |
|---|---|---|
| Disassembly | 99.93 % of the 416,385 code bytes decoded as instructions or jump tables; the other 290 bytes are mostly unreachable jumps, padding and x87 constants | static; README.md, coverage.md |
| Recovered C | every function, syntax-checked with MSVC `/Zs` against a Win16 shim header; independently re-verified against the machine code per work unit | static review; README.md "How it was produced" |
| Translation into civ64 | 699 of 699 port functions PASS an independent instruction-by-instruction comparison with the listing (137,887 of 137,887 instructions, verifier rounds 1 to 11) | static review; [phase-3c-acceptance.md](phase-3c-acceptance.md) |
| Traceability | `TRACE.md` maps all 1,065 functions to a port function, an `rt` replacement or a recorded dead-code reason; `test.cmd` rebuilds and compares it (TRACE_OK) | headless-tested; [TRACE.md](TRACE.md) |
| Features | 108 of 108 feature rows (menus, accelerators, the 19 dialogs, title branches, intro and Birth, advisors, Civilopedia, diplomacy, spaceship, replay, end games, …) reached | headless-tested; [FEATURES.md](FEATURES.md) |
| Rules | 24 checkpoint snapshots of scripted games equal their recorded reference; two world-generator random-draw vectors reproduced | headless-tested (model self-consistency, not the original); final report item 4 |
| Save files | the original's load-and-save of a save file is byte-identical to civ64's; the original loads a civ64 save and both re-saves are byte-identical | oracle-compared (the original under OTVDM on Windows 11); final report item 5 |
| Original bugs | 93 of the 94 reachable G, C and R findings (probable original bugs and anomalies, findings.md) have a cited statement executed in the port | headless-tested; final report item 6 |
| Play | the user's visual confirmation of civ64 passed (2026-10-11) | user-confirmed; final report section 3 |

## What "recovered" doesn't mean yet

Per the port's own open items ([final report](final-report.md) section 3):

* It doesn't behave identically to the original when given the same random seed: civ64 seeds from
  its start time.
* Sound output has never been heard.
* 22 of the 24 keyboard shortcuts were only triggered through the menus, never pressed as keys.
* No full turn sequence has been played side by side with the original, and no original-written
  `famehall.civ`, `civ.prf` or `.rep` file has been compared.
* A review of every 32-bit arithmetic spot in the code is still outstanding.

Also:

* **Not the original source.** The C is a reconstruction from the machine code. Function and
  variable names are inferred from evidence in the binary, with recorded confidence; the original
  names are unknown except the few the binary reveals.
* **Static verification for most rules.** Every port function was checked against the listing,
  but rules and screens beyond the scripted scenarios are not exercised at run time.
* **Dead code is recovered, not ported.** The dead functions are in the recovered C and the
  documentation; the port leaves them out by rule (see [Dead code](#dead-code)).
* **Base port only.** The counts cover the original program. civ64's later additions (scaling,
  map zoom, the DOS graphics profile; [STATUS.md](STATUS.md) "Extension track") are
  new presentation code outside these figures.

The user's own visual check of civ64 passed on 2026-10-11.

## Regenerating

From the repository root (Python 3, standard library only; reads no original bytes):

```bash
python claude/tools/recovery_coverage.py
```

It rewrites the block between the `coverage:begin` and `coverage:end` markers above and
[recovery-coverage.svg](recovery-coverage.svg) (always drawn in a dark theme). The figure's
disassembly, verification and feature counts are read from README.md,
[phase-3c-acceptance.md](phase-3c-acceptance.md) and the
[final report](final-report.md); the script stops with an error if it cannot find
them. `--check` reports `COVERAGE_OK`, or `COVERAGE_STALE` with exit code 1 when either output
differs from the current sources. The hand-written sections (sources, evidence, caveats) cite the
port's records and are updated by hand.

# Phase 1 acceptance record

Phase 1 (prompt section 9): design decisions of sections 5 to 8; the layout, accessor, frame and
dispatch generators and the NE loader; the `core`-facing interfaces of `rt` and `w16` covering
all 156 imports. Gate: generated headers and interfaces pass the section 1 checks; the NE loader
reproduces `segments.json` and `relocations.json`; every import is mapped; an independent
design review is recorded.

| Gate item | Method | Result |
|---|---|---|
| Generated headers and interfaces pass the section 1 checks | compiled: `build.cmd` (Release and Checked), every portable source with MSVC `/std:c11` and `/std:c17` (`/W4 /WX /permissive- /fp:precise`) and the C99 parse of Visual Studio's clang front end | BUILD_OK both variants, 19 portable sources (2026-10-08 14:33 UTC). The generated `civ_layout.h`, `civ_frames.h/.c`, `civ_dispatch.h/.c`, `civ_adapters.h`, `civ_core.h`, `civ_api.h/.c`, `rt_api.h`, `rt_unimpl.c`, `w16_api.h`, `w16_unimpl.c` are covered through the generated `.c` files and `core/civ_headers.c` (every header, every accessor form, static layout checks) |
| NE loader reproduces `segments.json` and `relocations.json` | headless test `test_ne` + `tests/check_ne.py` | PASS both variants: 133 segments, 20,124 relocation records (20,124 locations), 60 resources (reference 60), 63 relocated DGROUP far pointers, 0 errors |
| Every import is mapped | generator `gen/interfaces.py`; [API-MAP.md](API-MAP.md) | 156 imports: 141 implemented behind generated API glue (w16 fault stubs until written), 10 dead, 5 replaced; 0 findings |
| Independent design review recorded | independent subagent (read-only), report verbatim in [phase-1-review.md](phase-1-review.md) | 2 blockers, 4 major, 11 minor findings, 5 notes. Every finding has a recorded resolution (section 2 there); B1, B2, M3, M4, m2..m8, m10 and N1 changed code and are compiled and, where stated, headless-tested; M1, M2, m1, m9, m11, N2, N3 and N5 are design decisions in `DESIGN.md` |

Generators (each exits non-zero on an unexplained cross-check finding; run 2026-10-08):

| Generator | Result |
|---|---|
| `gen/inventory.py` | 854 live, 211 dead functions; 43 run-time callees of live game code; inventories regenerated (with the C2 mask table) |
| `gen/layout.py` | 78 structures (496 documented offsets, 61 sizes agree), 806 globals agree with names.json; accessor tags `ACC_T_*` with per-index counts |
| `gen/frames.py` | 1,065 frames (854 live descriptors); kinds all/live: FR_WIN_FAR 859/699, FR_FAR_BP 115/91, FR_BP 35/27, FR_NONE 53/34, FR_JUMP 3/3; 1,896 parameter locations agree with names.json; every epilogue agrees with the accepted frame saves; 1 explained finding (N_LUMOD's dead entry stub), 0 unexplained |
| `gen/dispatch.py` | 50 live code-pointer targets in 9 signature classes; 4 game indirect call sites (listing = C); 2 adapters; 0 findings |
| `gen/interfaces.py` | 699 core prototypes; 141 API glue functions; 155 rt entries (117 fault stubs at the end of phase 1); 0 findings |

**What was compiled:** all portable sources (`platform/w16`, `rt`, `core`, `core/gen`) in both
variants under the three language checks; the headless back end and the test programs with
`/std:c17`.

**What was tested headless** (`test.cmd`, both variants, 2026-10-08 14:33 UTC): `test_ne`
(+ `check_ne.py`) PASS; `test_vm` 48 checks (selector and handle reuse policy, stale and double
frees, exhaustion, frame descriptors after B1/m3/N1, pop cx teardown); `test_acc` 8 checks in
Release, 17 in Checked (effective addresses; per-index, member, extent and pointer records; site
restore); `test_float` 53 checks (exact binary32/binary64/80-bit encodings); `test_sha` 5 checks
(FIPS 180-4 vectors, the pinned `civ.exe` hash of the run data copy); and the phase-2 work in
progress `test_rt` 321 checks and `test_printf` 62 checks. All pass.

**Agent-observed, oracle-compared, user-confirmed:** nothing. No original or civ64 window was
run; no oracle was prepared.

**Unverified / open:**

* **B2 deviation, pending the user's confirmation:** selectors and handles are reused (the one
  released longest ago, after the never-used ones run out), against the prompt's literal "freed
  selectors are quarantined, never reused" (DESIGN 3.1, 3.6).
* **M1 decision (a):** 32-byte granularity is a platform fact (inferred) without a Windows 3.1
  observation; C2 masks 0xEF..0xFF fault in the port. Option (b) remains open.
* N3 (huge-tile limits) is an open question.
* Every design decision about later phases (start-up, KERNEL memory, queue, watchdog, frame
  hashes, the translator rules of section 7) is a design decision only; it is checked when
  implemented.

**Gate: met** (2026-10-08 14:35 UTC). Phase 2 continues in the same session (section 11).

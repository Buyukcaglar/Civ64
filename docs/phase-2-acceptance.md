# Phase 2 acceptance record

Phase 2 (prompt section 9) covers `rt` with unit tests; the `w16` skeleton (memory, selectors,
handle tables, queue, clock); the headless back end; and the harness. Gate: "`rt` tests pass.
The harness runs a stub core under the checked build."

| Gate item | Method | Result |
|---|---|---|
| `rt` tests pass | headless tests through `test.cmd` in all three variants: Release (`/MT /O2`), Checked (`CIV_CHECKED=1`: image bounds, argument-slot checks, statement markers) and Asan (Checked plus `/fsanitize=address`) | **PASS** in every variant, 2026-10-08: Release 17:27 UTC, Checked 17:24 UTC, Asan 17:28 UTC. All 155 rt entries are implemented (0 fault stubs). The rt tests are `test_rt` 321 checks, `test_printf` 62, `test_io` 133, `test_dir` 103, `test_time` 140, `test_heap` 99, `test_stdio` 400, `test_start` 110, `test_math` 174 and `test_float` 53. Measured coverage: 145 of 155 entries ran; the other ten are the unproven float entries, which fault at entry, as `test_math` checks |
| The harness runs a stub core under the checked build | `civ_harness.exe` (Checked and Asan builds) with `tests/headless/stub_core.c`, scenarios in `test.cmd` | **PASS**. Every scenario meets its expectation in Checked and in Asan (details below) |

**Harness scenarios** (each a fresh run directory under `build/run/`; the outputs are under
`build/harness/<variant>/`):

| Scenario | Inputs | Expectation | Result |
|---|---|---|---|
| normal | boot units 1234, date 1992-01-01 12:00:00, checkpoint `stub-pumped` = 1008:F070 | EXIT, code 0 | met: 23,103 steps, 1,098,600 virtual µs, boot_ms 20,567, two snapshots |
| normal2 | the same inputs | EXIT 0; the `stub-pumped` and `exit` snapshots equal the first run's | met: COMPARE EQUAL twice (repeat-run determinism, port against port) |
| boot | boot units 31000 | EXIT 0; a plain compare with normal differs; a masked compare differs only in `g_msg`+10..13, the MSG time, a GetTickCount value | met: plain DIFFER (`g_msg`+0x0A and the clock record); masked DIFFER with 0 bytes outside `g_msg+10:4` |
| mask | `normal/exit.snap` with 17 altered RTL selector/handle bytes (`_psp`, `_hInstance`, `_envseg`, `g_subHeap`, FILE buffer/curp, `tzname`, `_atexittbl`, the heap segment header's next/prev) | plain compare differs; masked compare is equal; altered offset words (FILE buffer, `tzname`, heap header next) still differ | met |
| input | `tests/harness/input.script` (two coalescing moves, A down/up, Q) | EXIT, code 3 | met |
| overflow | `tests/harness/overflow.script` (121 key-downs at once against the 120-message queue, then Q) | EXIT, code 120, 1 dropped event | met; `run.log` records the dropped event |
| hang | `--stub-mode hang --max-steps 200000` | WATCHDOG at site 1008:F0F0 | met: 200,000 steps |
| vtime | input mode without input, `--max-virtual-ms 3000` | WATCHDOG at site 1008:F0C0 | met: 3,000,000 virtual µs |

**What was compiled** (`build.cmd`, 2026-10-08, every variant BUILD_OK):
- all 33 portable sources (`platform/w16`, `rt`, `core`, `core/gen`) under MSVC `/std:c11` and
  `/std:c17` (`/W4 /WX /permissive- /fp:precise`) and the C99 parse of Visual Studio's clang
  front end;
- the headless back end, 15 test programs and (Checked, Asan) `civ_harness.exe`, linked with the
  stub core and with `core/gen/civ_unported.c` compiled under `CIV_STUB_CORE=1`.

All Asan executables import `clang_rt.asan_dynamic-x86_64.dll` and contain the instrumentation.

**What was tested headless**, besides the rt tests above:
- `test_vm` 48 checks;
- `test_acc` 8 checks in Release and 17 in Checked/Asan;
- `test_queue` 59 checks: the clock, GetTickCount, timers, PeekMessage order and filters, MSG
  written only on TRUE (Q8), key states, DispatchMessage of TIMERPROCs;
- `test_sha` 5 checks;
- `test_ne` with `check_ne.py`;
- the harness scenarios.

The labels are "model (self-consistency)" for tests derived from the recovered C and listing,
and "platform fact (inferred)" or "choice" for the Win16 rules (`DESIGN.md` 5, 6, 10).

**Agent-observed, oracle-compared, user-confirmed:** nothing. No original or civ64 window was
run, and no oracle was prepared. The determinism results are port-against-port only.

**Decided in this phase** (`DESIGN.md`):
- Q7 (window filter: the window and its descendants through a hook; choice), Q8 (MSG only on
  TRUE), Q14 and Q16 (3.1);
- the x87 state words 0x037F/0x3000 (4; choice);
- the RTL byte list of the comparison mask (9);
- the snapshot format, comparison output and harness options (9);
- the clock and timer rules (6) and the queue rules (5).

The per-entry contracts are in `rt/README.md`.

**Unverified / open:**

* **B2 deviation, pending the user's confirmation** (unchanged from phase 1): selectors and
  handles are reused after the never-used ones run out.
* **M1 decision (a)** (unchanged): C2 masks 0xEF..0xFF fault under the 32-byte granularity.
* **Untested until phase 4:** the error-exit chain ends at USER GetDesktopWindow/MessageBox,
  which are fault stubs; `test_start` follows every path up to that call. Window messages fault
  in DispatchMessage until the window manager exists, and Q7's descendant matching is untested
  until then.
* **Open until the first comparison with a non-port snapshot:** the mask of handle-typed game
  globals and of pointer/handle fields inside structures and arrays (`DESIGN.md` 9).
* **Not proven exact:** every float path besides those listed in `rt/README.md` faults.
* **Windows 3.1 behaviour not observed:** the queue order, the WM_QUIT position, the
  input-queue size, the poll costs, the timer rounding and the x87 initial words are choices or
  platform facts (inferred), not Windows 3.1 observations. OTVDM is not Windows 3.1 evidence.
* The step watchdog and frame hashes are implemented. The frame-hash path is untested, since the
  stub core draws no frames; that comes in phase 3a with the title screen.

**Gate: met** (2026-10-08 17:28 UTC). Phase 3a follows (section 11).

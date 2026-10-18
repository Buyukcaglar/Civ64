# Extension phase S1 — acceptance record

Prompt: `claude/docs/x64-port-scaling-dos-prompt.md`, phase S1 (section 9): "`present/frame` (a single
logical frame, no composition yet) and `present/scale`, inverse mapping, the `host.h` present change; the
headless back end presents through `present/`." Gate: "7.1 goldens pass in all variants; G-1 holds."
Session E1, 2026-10-10. Design: DESIGN.md 12.1.

## Gate

| Item | Method | Result |
|---|---|---|
| Portable layer | `present/frame.[ch]`, `present/scale.[ch]`, `present/present.[ch]` in the portable loop of `build.cmd` (`/std:c11`, `/std:c17` `/W4 /WX`, clang-tidy C99 parse) | compiled in Checked and Asan (BUILD_OK); Release: see below |
| 7.1 scaler goldens | `tests/test_present.c`: 5 policy/filter combinations x 3 frame kinds x 12 client sizes, per-group digests in the source; inverse mapping, damage = whole rendering, the 6/5 pairs, the facade | Checked PASS (745 checks; TESTS_OK 17:43 UTC); Asan PASS (745 checks; TESTS_OK 18:15 UTC); all three variants again with S2, R and F103 in the tree: PASS 745 checks each, TESTS_OK (2026-10-10 20:01..20:32 UTC) |
| `host.h` present change | `host_show` added; `host_present` unchanged in signature, called by `present_core` with the unchanged arguments | headless and Win32 back ends; `w32_test_host_win32` PASS (105 checks) in Checked and Asan |
| G-1 | `tests/harness/ext_g1.py check` against `ext-g1-baseline.txt` (77 runs: core frame lines, snapshot/result lines, `events.log`) | Checked: EXT_G1_OK runs 77; Asan: EXT_G1_OK runs 77; again with S2, R and F103 (20:06 and 20:29 UTC): EXT_G1_OK runs 77 in both (the baseline unchanged) |
| Presented trace | Checked new-game scenario (72 s virtual, checkpoints after-worldgen, after-setup, turn, space): plain; `--presented 1 --host-size 1920x1080 --scale-mode fit --filter sharp`; `--presented 1 --host-size 1366x768 --scale-mode integer --aspect 4:3` | run.log (763 core frames, 12 snapshots), events.log and every snapshot byte-equal across the three runs except the run-directory line (P0 holds for host size, policy and filter). presented.log: 764 presents, 763 with the relation (presented frame = RGB of the virtual screen through the system palette) holding; the one other was the show of attaching the view before the core's first present, which has no core screen to compare. The harness now labels that show `view_attached` (DESIGN.md 12.1). Rerun (s1-pres3, 1920x1080 fit sharp, harness with the fix): "end presents 764 relation_mismatches 0", every presented hash equal to the first run's, run.log equal to the plain run but for the run-directory line |

Timing (informational, D12; Checked, whole 640x480 frame into 3840x2160, offscreen): integer 3.7 ms,
fit-nearest 3.1, fit-sharp 8.1, stretch-nearest 2.7, stretch-sharp 8.9.

## Superseded checks (review D3)

* `w32_test_host_win32`: the check of a 640x480 `hw_pixels` DIB is replaced by checks of the logical
  frame (`present_shown_frame`, the RGB conversion of the dirty rectangle only, clipping) and of the
  client's picture (2x2 blocks of a 1280x960 client at scale 2).
* F98's GDI HALFTONE fit is replaced by the deterministic scaler (FIDELITY F99; the user's decision D7).

## Not verified

Nothing in S1 is a user visual check. The Win32 picture was checked headless (hidden window) only; the
agent UI check and the user's check belong to S2.

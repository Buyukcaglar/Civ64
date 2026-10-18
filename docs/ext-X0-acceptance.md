# Extension phase X0 — acceptance record

Prompt: `claude/docs/x64-port-scaling-dos-prompt.md` (the extension), phase X0 (section 9).
Session E1, 2026-10-10 16:40..17:50 UTC.

## Gate

"Review recorded, corrections listed (ask the user only for a conflict that needs a decision)."
**Met** (2026-10-10 about 17:50 UTC).

| Item | Method | Result |
|---|---|---|
| Hash `original/CIVWIN` (session start) | PowerShell, base prompt 10 | HASH_BEFORE_OK, 38 of 38 ([hashes/20261010T170031Z-before.txt](hashes/20261010T170031Z-before.txt)) |
| Hash `dos/`, reference list | PowerShell, extension 10 | DOS_HASH_BEFORE_OK, 176 of 176; reference [dos/dos-hashes.txt](dos/dos-hashes.txt) written after checking every key entry of extension 3 (sizes and SHA-256 of CIV.EXE, CIV_UNP.EXE, MGRAPHIC.EXE, FONTS.CV, MISC.EXE; prefixes of EGRAPHIC/TGRAPHIC) ([hashes/20261010T170101Z-dos-before.txt](hashes/20261010T170101Z-dos-before.txt), with attributes and LastWriteTimeUtc) |
| `build/dosdata/` | copy + SHA-256 | 176 files, every hash equal to the reference; read-only attribute set |
| Session start (base 11): builds and tests | compiled; headless | Checked BUILD_OK (226 portable sources) and TESTS_OK 17:01..17:13 UTC on the base sources; Asan and Release were not repeated (unchanged sources since the base track's 16:57 all-variant TESTS_OK; the run was stopped to start S1) |
| STATUS reconciled | ledger | "Extension track" section; base track delivered with open items; the user confirmed the base fixes stopped |
| Independent adversarial review | separate read-only reviewer agent | [verify/ext-x0-review.md](verify/ext-x0-review.md) (verbatim): facts A1/A2, conflicts B1..B3, risks C, 34 corrections D |
| User decisions | chat (2026-10-10 about 16:55 and 17:45 UTC) | see STATUS "User directions"; below |
| G-1 baseline frozen (review D4) | script | `tests/harness/ext_g1.py` and `ext-g1-baseline.txt`: per run, the hashes of the core frame lines, the snapshot/result lines and `events.log` of the 77 harness runs of the pre-extension Checked `test.cmd` run (stub runs, gate3b, p4 scenarios, p49 tests, UNINIT soaks). `ext_g1.py check` compares a later run |

Agent observation is not user acceptance; nothing in X0 needed a visible window.

## Resolutions of the review's corrections (verify/ext-x0-review.md D)

User decisions:
* **D1 (browse UI)**: the Windows system picker. Its registry writes (the common dialogs' most-recently-used
  state under `HKCU\...\ComDlg32`) are a recorded deviation from base 2.3 (FIDELITY, phase R).
* **D6 (DOS immediates)**: allowed as C constants with their DOS address (`R:ssss:oooo` / `O<n>:oooo`); data-
  segment tables, pictures, palettes, fonts and texts are read at run time.
* **D7 (default scaling, supersedes F98)**: "both and player selectable, persisted and can be changed later":
  `integer` and `fit` (filters `nearest`, `sharp`) and `stretch` are offered by option and by the host
  window's system menu, the choice is remembered in `%LOCALAPPDATA%\civ64\civ64.cfg` (the kept Settings-file
  grant); `integer` is the default only when nothing is remembered. F98's GDI HALFTONE fit is replaced by
  the deterministic `fit` + `sharp`.
* **D8 (R order)**: the program's own folder is kept as step 4a (after the `CivWin`/`CivDos` subfolders,
  before the remembered location), when it holds `civ.exe`. Phase R supersedes extension 5.9/5.11 "`--dos-data`
  … no default"; `--data` and `--dos-data` override every lookup step.

Agent decisions (recorded here; each is applied in its phase):
* **D2 (mirror equality)**: redefined for M — equality at the stable frames after each completed core map
  redraw or flush, with a recorded list of transient overlays; or the in-view layer as a replay of the core's
  map-port drawing (decided in D1's design).
* **D3 (G-1 wording)**: G-1 covers core, rt, w16, the harness and the headless unit tests, compared with the
  frozen baseline (D4). Win32-headless checks that the extension changes on purpose are listed in the S1/S2
  acceptance records with the rule that replaces them (S1: the 640x480 `hw_pixels` DIB check becomes a check of
  the logical frame and the client picture).
* **D4**: done (`ext_g1.py`).
* **D5 (`CIV_OBSERVER=0`)**: removes events, probes, the presentation tick, the input-filter hook and the 7.8
  mode; own build variant directory (D3).
* **D9, D10, D25, D30..D33 (R design)**: own portable ZIP reader and inflate (methods 0 and 8; encrypted,
  multi-disk, symlink, duplicate and unsafe names refused; ZIP64 refused with a message; caps on sizes and
  counts; CRC-32), verified in memory before any write; extraction into a temporary folder renamed into place;
  refresh replaces only files unchanged since the last extraction (manifest outside the data directory); DOS
  ZIPs read in memory; exe-folder lookup by ASCII case-insensitive enumeration with a fixed order; a present
  but invalid candidate stops with a message naming it (exit 2), a refused or invalid browsed choice is asked
  again and never remembered; `SHGetKnownFolderPath(FOLDERID_LocalAppData)`; test seams for the program folder,
  the per-user root and quiet prompts; agent runs keep passing `--data`/`--dos-data`.
* **D11**: the DOS clock is calibrated to the VGA retrace (load-module 0x215/0x258/0x276, port 0x3DA): D0's
  TIMING.md expresses durations in DOS ticks with a measured divisor.
* **D12**: the 8 ms 3840x2160 target is measured offscreen (no 4K display here), per policy, recorded at S2.
  S1 measurement (Checked build, `test_present`, whole frame into a 3840x2160 buffer, informational):
  integer 3.7 ms, fit-nearest 3.1, fit-sharp 8.1, stretch-nearest 2.7, stretch-sharp 8.9.
* **D13 (O7)**: the tick is throttled by virtual time in headless and by host refresh in Win32 (D1); the
  Windows-profile frame is built inside `w16_present` from the presented screen (S1 already does so), so the
  relation of the two hashes holds.
* **D14..D22, D24, D26..D29, D34**: corrections to the prompt's facts and wording, applied when their phase
  starts (I5 store addresses 1108:017A/018F and WaitForKeyOrClick 1038:0CB6/0CCE; Q86 dropped; the logical
  layer's x < 0 and the dialog port in city-tile mode; the map's pixel scroll offsets 1408:00C6/00C4; PIC chunk
  length excludes the 4-byte header; BLURB3 at 532; "Allocated 1Mb" not tied to the driver loader;
  progress reports stopped by the user; `--scale auto|<k>` with k at most 8; host modal loops block the game
  thread (recorded at S2); 7.4 compares runs with identical core input; a shorter 7.3 matrix at intermediate
  gates; the stale `host_sync.c` comment).
* **D23 (DOS oracle sound question)**: answer "No sounds please" (DOS sound is out of scope, 5.9); recorded at
  D4 with its possible effect on timing.

## Not verified

Nothing in X0 is a visual, oracle or user check. The review's DOS listing observations (EXEPACK decodes to
CIV_UNP.EXE byte for byte; the retrace-calibrated clock) are scratch results to be redone by D0's own tools.

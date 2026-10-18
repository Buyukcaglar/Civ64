# Extension phase R (the user's resource-lookup requirements) — acceptance record

Not a phase of the extension prompt: the user's requirements of 2026-10-10 (verbatim in STATUS.md
"Extension track"), placed after S2 and before D0 by the user, with the decisions D1 (the Windows system
picker), D8 (the program's folder as step 4a) and D9 (agent design) of `ext-X0-acceptance.md`.
Session E1, 2026-10-10. Design: DESIGN.md 12.3; FIDELITY F102; RUNNING.md "Where civ64 finds the game".

## The requirements and where each is met

| # | Requirement (user) | Implementation | Test |
|---|---|---|---|
| 1 | ZIP `CivWin.zip`, `Civ-Win.zip` or `Civ_Win.zip` for the Windows version, name case-insensitive | `civ64_locate.c` `locate_windows` step 2 (enumeration, ASCII case folding, that order); extraction to `%LOCALAPPDATA%\civ64\CivWin` with refresh (user decision 2026-10-10) | `w32_test_locate`: `CIVWIN.ZIP` found and extracted, a second start writes nothing, a changed ZIP keeps the player's change and a save; `CivWin.zip` before `Civ-Win.zip`; a damaged `Civ-Win.zip` named |
| 2 | ZIP `CivDos.zip`, `Civ-Dos.zip` or `Civ_Dos.zip` for the DOS version | `locate_dos` step 2; read into memory, checked, kept (never extracted) | `Civ_Dos.ZIP` found; a wrong CIV.EXE inside named |
| 3 | Subfolder `CivWin` of the program's folder, case-insensitive | `locate_windows` step 3 | `civwin` found; a wrong civ.exe stops with a message |
| 4 | Subfolder `CivDos`, case-insensitive | `locate_dos` step 3 | `CivDos` with `Civ.Exe` found |
| 4a | (user decision D8) the program's folder when it holds civ.exe | `locate_windows` step 4a | `CIV.EXE` in the program's folder found |
| 5 | Otherwise ask and browse the Windows and DOS versions separately, remember the choices; DOS optional | remembered `windows_data` / `dos_data` in civ64.cfg; asking: message box, then IFileOpenDialog (civ.exe or a ZIP); DOS: "Locate it now?", then "Ask again next time?" (`dos_ask=never`) | remembered folder found; a remembered folder that is gone is skipped; quiet mode (tests): Windows not found fails with a message, DOS is skipped. The dialogs themselves are not exercised by tests (they would need a person) |
| 6 | Preserve `--data` | `--data` wins over every step, unchanged meaning (checked by `civ64_open_data`); `--dos-data DIR\|ZIP\|none` added | `--data` wins over a civ.exe in the program's folder; `--dos-data` folder and `none` |

ZIP reader (`res/zip.c`, portable, compiled with the language checks: 230 portable sources c11/c17/c99
parse): `tests/test_zip.c` PASS 5869 checks in Checked (CRC-32 check value; 9 zlib-made vectors incl.
stored, fixed, dynamic, Huffman-only, RLE, 100000-byte runs, used length, one byte too little room or too
much declared, every truncation; hand-built fixed streams: lengths 3..258, distance 32768, distance beyond
the output, length codes 286/287, distance codes 30/31, block type 3, no final block; two stored blocks and
a bad NLEN; dynamic HLIT/HDIST out of range; 1800 bit-flipped streams and 300 random ones, each a clean
result; archives: valid with comment holding a fake end signature, data descriptors, an empty archive,
safe names; 24 unsafe names, duplicates in case and separator, every refusal of zip.h with its message;
extraction: CRC mismatch, declared size + 1, corrupted data).

| Item | Result |
|---|---|
| Checked tests | `test_zip` PASS (5869), `w32_test_locate` PASS (31 checks incl. the DOS cases with `build\dosdata\CIV.EXE`), 2026-10-10 about 18:40 UTC |
| All variants (Checked, Asan, Release) | `test_zip` PASS 5869 and `w32_test_locate` PASS 31 in each, TESTS_OK (2026-10-10 20:01..20:32 UTC, with F103 in the tree) |
| Agent check of a real start without `--data` | not done: it would ask with the system dialog or extract into the user's own per-user folder; the steps run in `w32_test_locate` with injected folders |
| User check | **passed** (the user, 2026-10-10 about 21:00 UTC: "Inspection of S2 and R passed"). Earlier: the user ran the Checked civ64 without options with `CIVWIN.zip` next to it (extracted to `%LOCALAPPDATA%\civ64\CivWin`, 18:54 UTC) and later `civdos.zip` (found without a question, 19:02). The user reports having chosen not to be asked about DOS, but `civ64.cfg` holds no `dos_ask=never` (so the question was not switched off; the answers given are not known). Not yet seen: a CivWin folder, the Windows question and file dialog |

## Not verified

The Windows file dialog and the message boxes were not shown (tests run quiet). A refresh interrupted
half-way (power loss) is handled by design (the manifest is written last, so the next start refreshes again;
files already replaced equal the new content and are left as they are) but not tested. ZIP64 archives, other compression methods and encrypted
entries are refused with a message, by design.
